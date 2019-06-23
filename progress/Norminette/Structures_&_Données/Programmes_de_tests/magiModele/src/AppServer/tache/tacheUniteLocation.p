/*------------------------------------------------------------------------
File        : tacheUniteLocation.p
Purpose     : tache unite de location
Author(s)   : GGA  2017/08/21
Notes       : a partir de adb/tach/creapp00.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2contrat.i}

using parametre.pclie.parametrageMotifIndisponibilite.
using parametre.pclie.parametrageRelocation.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheUniteLocation.i}
{mandat/include/uniteComposition.i}
{mandat/include/uniteLocation.i}
{application/include/combo.i}
{adblib/include/unite.i}
{adblib/include/aspno.i}
{immeubleEtLot/include/cpuni.i}
{application/include/glbsepar.i}
{preprocesseur/type2bien.i}

define variable gINumeroImmeuble as integer no-undo.
define variable giNumeroMandant  as integer no-undo.
define variable ghUnite          as handle  no-undo.
define variable ghCpuni          as handle  no-undo.

function attPre998 returns logical private(piNoMdt as integer):
    /*------------------------------------------------------------------------------
    Purpose: retour présence appartement 998
    Notes  :
    ------------------------------------------------------------------------------*/
    return can-find(first cpuni no-lock
                where cpuni.nomdt = piNoMdt
                  and cpuni.noapp = 998).
end function.

function ULExist returns logical private (piNoMdt as integer, piNoApp as integer, piNoAct as integer):
    /*------------------------------------------------------------------------------
    Purpose: test existance UL
    Notes  :
    ------------------------------------------------------------------------------*/
    return can-find(first unite no-lock
                where unite.nomdt = piNoMdt
                  and unite.noapp = piNoApp
                  and unite.noact = piNoAct).
end function.

function codeNature returns character private (pcTypeParam as character, piZone1 as decimal, pcZone2 as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : gga todo a partir de adb/tach/creapp00.p adb/lib/l_paruti.p pour trouver le code nature associe a ul 997 comment faire ce genre de recherche ?
    ------------------------------------------------------------------------------*/
    define variable vcCode as character no-undo.
    define buffer sys_pr for sys_pr.

    for first sys_pr no-lock
        where sys_pr.tppar = pcTypeParam
          and (sys_pr.zone1 = piZone1 or piZone1 = 0)
          and (sys_pr.zone2 = pcZone2 or pcZone2 = ""):
        vcCode = trim(sys_pr.cdpar).
    end.
    return vcCode.
end function.

function getUsageUL returns character private(pcNatureUL as character, pcCodeUsage as character):
    /*------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------*/
    define buffer usage for usage.

    find first usage no-lock
        where usage.ntapp = pcNatureUL
          and usage.cdusa = pcCodeUsage no-error.
    if not available usage and pcCodeUsage > ""
    then find first usage no-lock
        where usage.ntapp = "00000"
          and usage.cdusa = pcCodeUsage no-error.
    if available usage then return usage.lbusa.
    return "".

end function.

procedure getUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttUniteLocation.
    define output parameter table for ttCompositionUnite.

    empty temp-table ttUniteLocation.
    empty temp-table ttCompositionUnite.
        
    run lectureUniteLocation (pcTypeMandat, piNumeroMandat).

end procedure.

procedure getHistoriqueCompositionUL:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroUL     as integer   no-undo.
    define output parameter table for ttUniteLocation.
    define output parameter table for ttCompositionUnite.

    empty temp-table ttUniteLocation.
    empty temp-table ttCompositionUnite.
    run lectureHistoriqueCompositionUL (pcTypeMandat, piNumeroMandat, piNumeroUL).

end procedure.

procedure setUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter table for ttUniteLocation.
    define input parameter table for ttCompositionUnite.

    define variable vlNouvelCompo       as logical no-undo.
    define variable vlModifUnite        as logical no-undo.
    define variable vlModifLotPrincipal as logical no-undo.
    define variable viAncLotPrincipal   as integer no-undo.

    define buffer ctrat for ctrat.
    define buffer unite for unite.
    define buffer intnt for intnt.

    find first ctrat no-lock                                             //recherche mandat
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    giNumeroMandant = ctrat.norol.
    find first intnt no-lock                                            //recherche immeuble
         where intnt.tpcon = ctrat.tpcon
           and intnt.nocon = ctrat.nocon
           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
    if not available intnt
    then do:
        mError:createError({&error}, 1000513).                  //pas d'immeuble pour ce contrat
        return.
    end.
    gINumeroImmeuble = intnt.noidt.

bloc-maj:
    do:
        for first ttUniteLocation
           where ttUniteLocation.CRUD = "C":
            run ctrlAvantModif (buffer ttUniteLocation).
            if mError:erreur() = yes then leave bloc-maj.
            run creationUnite (buffer ttUniteLocation).
            if mError:erreur() = yes then leave bloc-maj.
            run modifComposition (buffer ttUniteLocation).
            if mError:erreur() = yes then leave bloc-maj.
            run modifComposition998 (buffer ttUniteLocation).
            if mError:erreur() = yes then leave bloc-maj.
            leave bloc-maj.   
        end.
        for first ttUniteLocation
            where ttUniteLocation.CRUD = "U":
            run ctrlAvantModif (buffer ttUniteLocation).
            if mError:erreur() = yes then leave bloc-maj.
            find first unite no-lock
                where unite.nomdt = ttUniteLocation.iNumeroContrat
                  and unite.noapp = ttUniteLocation.iNumeroAppartement
                  and unite.noact = 0 no-error.
            if ttUniteLocation.iNumeroComposition = unite.nocmp
            and ttUniteLocation.iNumeroAppartement <> 998                                     //changement sans nouvelle composition
            then do:
                empty temp-table ttUnite.
                create ttUnite.                                                               //creation de la table d'echange avec le pgm de maj. sera complete en fonction des modifications dans les procedure suivantes
                assign
                    ttUnite.nomdt       = ttUniteLocation.iNumeroContrat
                    ttUnite.noapp       = ttUniteLocation.iNumeroAppartement
                    ttUnite.noact       = ttUniteLocation.iCodeActif
                    ttUnite.CRUD        = ttUniteLocation.CRUD
                    ttUnite.dtTimestamp = ttUniteLocation.dtTimestamp
                    ttUnite.rRowid      = ttUniteLocation.rRowid
                .
                if ttUniteLocation.cCodeMotifIndisponibilite  <> unite.cdmotindis               //changement indisponibilite
                or ttUniteLocation.daDateDebutIndisponibilite <> unite.dtdebindis
                or ttUniteLocation.daDateFinIndisponibilite   <> unite.dtfinindis
                then do:
                    vlModifUnite = yes.
                    run ctrlModifIndisponibilite (buffer ttUniteLocation).
                    if mError:erreur() = yes then leave bloc-maj.
                    assign
                        ttUnite.cdmotindis = ttUniteLocation.cCodeMotifIndisponibilite
                        ttUnite.dtdebindis = ttUniteLocation.daDateDebutIndisponibilite
                        ttUnite.dtfinindis = ttUniteLocation.daDateFinIndisponibilite
                        ttUnite.lbdiv      = (if ttUniteLocation.daDateDebutIndisponibilite <> ? then string(ttUniteLocation.daDateDebutIndisponibilite,"99/99/9999") else "") +
                                             "&" +
                                             (if ttUniteLocation.daDateFinIndisponibilite <> ? then string(ttUniteLocation.daDateFinIndisponibilite,"99/99/9999") else "") + 
                                             "&" + 
                                             cCodeMotifIndisponibilite
                    .
                end.
                if ttUniteLocation.cCodeUsage <> unite.cdusa
                or ttUniteLocation.cCodeNatureUL <> unite.cdcmp                                 //changement nature
                then do:
                    vlModifUnite = yes.
                    run ctrlModifNature (buffer ttUniteLocation).
                    if mError:erreur() = yes then leave bloc-maj.
                    assign
                        ttunite.cdcmp = ttUniteLocation.cCodeNatureUL
                        ttunite.cdusa = ttUniteLocation.cCodeUsage
                    .
                end.
                if ttUniteLocation.iNumeroLotPrincipal <> unite.nolot                           //changement lot principal
                then do:
                    assign
                        vlModifUnite        = yes
                        vlModifLotPrincipal = yes
                        viAncLotPrincipal   = unite.nolot.
                    run modifLotPrincipal (ttUniteLocation.iNumeroContrat, ttUniteLocation.iNumeroAppartement, ttUniteLocation.iNumeroComposition, ttUniteLocation.iNumeroLotPrincipal, unite.nolot).
                    if mError:erreur() = yes then leave bloc-maj.
                end.
                if vlModifUnite = yes
                then do:
                    if not valid-handle(ghUnite)
                    then do:
                        run adblib/unite_CRUD.p persistent set ghUnite.
                        run getTokenInstance in ghUnite(mToken:JSessionId).
                    end.
                    run setUnite in ghUnite(table ttUnite by-reference).
                    if mError:erreur() = yes then leave bloc-maj.
                end.
            end.
            if ttUniteLocation.iNumeroComposition <> unite.nocmp                                //nouvelle composition
            and ttUniteLocation.iNumeroAppartement <> 998
            then do:
                vlNouvelCompo = yes.
                if ttUniteLocation.iNumeroLotPrincipal <> unite.nolot                           //changement lot principal
                then assign
                         vlModifLotPrincipal = yes
                         viAncLotPrincipal   = unite.nolot
                .
                if ttUniteLocation.cCodeUsage <> unite.cdusa
                or ttUniteLocation.cCodeNatureUL <> unite.cdcmp                                 //changement nature
                then do:                
                    run ctrlModifNature (buffer ttUniteLocation).                                   
                    if mError:erreur() = yes then leave bloc-maj.
                end.
                run majDateFinUnite (buffer ttUniteLocation).
                if mError:erreur() = yes then leave bloc-maj.
                run creationUnite (buffer ttUniteLocation).
                if mError:erreur() = yes then leave bloc-maj.
                run modifComposition (buffer ttUniteLocation).
                if mError:erreur() = yes then leave bloc-maj.
            end.
            if vlNouvelCompo = yes
            then do:
                run modifComposition998 (buffer ttUniteLocation).
                if mError:erreur() = yes then leave bloc-maj.
            end.   
            if vlModifLotPrincipal = yes
            then do:
                run modifAssurancePno (buffer ttUniteLocation, viAncLotPrincipal). 
            end.       
            leave bloc-maj.
        end.
    end.
    if valid-handle(ghUnite) then run destroy in ghUnite.
    if valid-handle(ghCpuni) then run destroy in ghCpuni.

end procedure.

procedure verUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose: procedure de controle sans mise a jour (correspond a la procedure setUniteLocation
    mais sans la mise à jour)  
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter table for ttUniteLocation.
    define input parameter table for ttCompositionUnite.

    define buffer ctrat for ctrat.
    define buffer unite for unite.
    define buffer intnt for intnt.

    find first ctrat no-lock                                             //recherche mandat
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    giNumeroMandant = ctrat.norol.
    find first intnt no-lock                                            //recherche immeuble
         where intnt.tpcon = ctrat.tpcon
           and intnt.nocon = ctrat.nocon
           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
    if not available intnt
    then do:
        mError:createError({&error}, 1000513).                            //pas d'immeuble pour ce contrat
        return.
    end.
    gINumeroImmeuble = intnt.noidt.

    for first ttUniteLocation
        where ttUniteLocation.CRUD = "C":
        run ctrlAvantModif (buffer ttUniteLocation).
        if mError:erreur() = yes then return.
    end.
    for first ttUniteLocation
        where ttUniteLocation.CRUD = "U":
        run ctrlAvantModif (buffer ttUniteLocation).
        if mError:erreur() = yes then return.
        find first unite no-lock
             where unite.nomdt = ttUniteLocation.iNumeroContrat
               and unite.noapp = ttUniteLocation.iNumeroAppartement
               and unite.noact = 0 no-error.
        if ttUniteLocation.iNumeroComposition = unite.nocmp
        and ttUniteLocation.iNumeroAppartement <> 998
        then do:
            if ttUniteLocation.cCodeMotifIndisponibilite  <> unite.cdmotindis               //changement indisponibilite
            or ttUniteLocation.daDateDebutIndisponibilite <> unite.dtdebindis
            or ttUniteLocation.daDateFinIndisponibilite   <> unite.dtfinindis
            then do:
                run ctrlModifIndisponibilite (buffer ttUniteLocation).
                if mError:erreur() = yes then return.
            end.
            if ttUniteLocation.cCodeUsage <> unite.cdusa
            or ttUniteLocation.cCodeNatureUL <> unite.cdcmp                                 //changement nature
            then do:
                run ctrlModifNature (buffer ttUniteLocation).
                if mError:erreur() = yes then return.
            end.
        end.        
    end.

end procedure.

procedure ctrlModifNature private:
    /*------------------------------------------------------------------------------
    Purpose: changement nature
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.

    define variable voSyspr as class syspr no-undo.

    voSyspr = new syspr().
    if voSyspr:isParamExist("NTAPP", ttUniteLocation.cCodeNatureUL) = no     
    then do:
        mError:createError({&error}, 1000507, ttUniteLocation.cCodeNatureUL).   //nature de location &1 inexistante
        delete object voSyspr.
        return.
    end.
    delete object voSyspr.
 
    if ttUniteLocation.cCodeUsage > ""
    and not can-find(first usage no-lock
                     where usage.ntapp = ttUniteLocation.cCodeNatureUL
                       and usage.cdusa = ttUniteLocation.cCodeUsage)
    then do:
        mError:createError({&error}, 1000508, ttUniteLocation.cCodeNatureUL).  //usage UL &1 inexistant
        return.
    end.

end procedure.

procedure ctrlModifIndisponibilite private:
    /*------------------------------------------------------------------------------
    Purpose: changement indisponibilite
    Notes  : a partir de adb/tach/modappin.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.

    define variable vlFicLoc as logical no-undo.
    define variable voMotifIndisponibilite as class parametrageMotifIndisponibilite no-undo.
    define variable voRelocation           as class parametrageRelocation no-undo.

    define buffer tache    for tache.
    define buffer ctrat    for ctrat.
    define buffer location for location.
    define buffer unite    for unite.

    voMotifIndisponibilite = new parametrageMotifIndisponibilite(ttUniteLocation.cCodeMotifIndisponibilite).
    if voMotifIndisponibilite:isDbParameter = no  
    then do:
        delete object voMotifIndisponibilite.
        mError:createError({&error}, 1000514).             //Motif indisponibilité inexistant
        return.
    end.
    if ttUniteLocation.daDateDebutIndisponibilite <> ?
    and ttUniteLocation.daDateFinIndisponibilite <> ?
    and ttUniteLocation.daDateDebutIndisponibilite > ttUniteLocation.daDateFinIndisponibilite
    then do:
        mError:createError({&error}, 1000509).           //Date début indisponibilité > à date de fin
        return.
    end.
    if ttUniteLocation.daDateDebutIndisponibilite <> ?
    then do:
        for first unite no-lock
             where unite.nomdt = ttUniteLocation.iNumeroContrat
               and unite.noapp = ttUniteLocation.iNumeroAppartement
               and unite.noact = 0:
            for last tache no-lock
               where tache.tpcon = {&TYPECONTRAT-bail}
                 and tache.nocon = unite.norol
                 and tache.tptac = {&TYPETACHE-quittancement}:
                if ttUniteLocation.daDateDebutIndisponibilite < tache.dtfin
                then do:
                    mError:createError({&error}, 1000510).  //Il y a chevauchement entre la date de sortie du locataire et la date d'indisponibilité
                    return.
                end.
            end.
            for first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-bail}
                  and ctrat.nocon = unite.norol:
                if ttUniteLocation.daDateDebutIndisponibilite < ctrat.dtree
                then do:
                    mError:createError({&error}, 1000511).  //Il y a chevauchement entre la date de résiliation du bail et la date d'indisponibilité
                    return.
                end.
            end.
        end.    
    end.

    /* Fiche 1106/0142 : Si module location activé et existe fiche location non archivée  */
    /* et non validée sur cette UL alors le motif doit être un motif du module location */
    voRelocation = new parametrageRelocation().
    if voRelocation:isActif()
    then do:
        /* Recherche fiche de relocation */
        find last location no-lock
            where location.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and location.nocon = ttUniteLocation.iNumeroContrat
              and location.noapp = ttUniteLocation.iNumeroAppartement
              and location.fgarch = no no-error.
        if available location
        then do:
            vlFicLoc = yes.
            /* si fiche validée et pré-bail accepté alors le gestionnaire peut retirer le motif d'indisponibilité */
            if location.cdstatut = {&STATUTINTERVENTION-refuse}
            and can-find(first ctrat no-lock
                         where ctrat.tpcon = {&TYPECONTRAT-preBail}
                           and ctrat.nocon >= location.nocon * 100000 + location.noapp * 100 + 1
                           and ctrat.nocon <= location.nocon * 100000 + location.noapp * 100 + 99
                           and ctrat.cdstatut = "00099")
            then vlFicLoc = no.
        end.
        if vlFicLoc and voMotifIndisponibilite:int01 <> 1                /* module location */
        then do:
            delete object voMotifIndisponibilite.
            delete object voRelocation.
            mError:createError({&error}, 1000512).  //Modif incompatible avec la location, il y a une fiche de location active pour cette UL. Vous ne pouvez saisir qu'un motif d'indisponibilité associé au module Location
            return.
        end.
    end.
    if valid-object(voMotifIndisponibilite) then delete object voMotifIndisponibilite.
    if valid-object(voRelocation) then delete object voRelocation.

end procedure.

procedure modifLotPrincipal private:
    /*------------------------------------------------------------------------------
    Purpose: changement lot principal
    Notes  :  extrait lisctapp.p (WHEN "LOTPR")
    ------------------------------------------------------------------------------*/
    define input        parameter piNoMdt        as integer no-undo.
    define input        parameter piNoApp        as integer no-undo.
    define input        parameter piNoCmp        as integer no-undo.
    define input        parameter piNouvLotPrinc as integer no-undo.
    define input        parameter piAncLotPrinc  as integer no-undo.

    define variable viOrdAncPrinc as integer no-undo.

    define buffer cpuni for cpuni.
    define buffer vbcpuni for cpuni.
    define buffer local for local.
    define buffer ladrs for ladrs.

    {&_proparse_ prolint-nowarn(nowait)}
    find first cpuni exclusive-lock                                   //lecture ancien lot principal
         where cpuni.nomdt = piNoMdt
           and cpuni.noapp = piNoApp
           and cpuni.nocmp = piNoCmp
           and cpuni.nolot = piNouvLotPrinc no-error.
    if not available cpuni
    then do:
        mError:createError({&error}, 100350).
        return.
    end.
    assign
        viOrdAncPrinc = cpuni.noord                                   //Sauvegarde du nø d'ordre ancien lot principal
        cpuni.noord   = 0                                             //Mise en attente du lot
    .
    {&_proparse_ prolint-nowarn(nowait)}
    find first vbcpuni exclusive-lock                                 //lecture nouveau role principal
         where vbcpuni.nomdt = piNoMdt
           and vbcpuni.noapp = piNoApp
           and vbcpuni.nocmp = piNoCmp
           and vbcpuni.nolot = piAncLotPrinc no-error.
    if not available vbcpuni
    then do:
        mError:createError({&error}, 100350).
        return.
    end.
    assign
        vbcpuni.noord = viOrdAncPrinc
        cpuni.noord  = 1
    .
    ttUnite.nolot = cpuni.nolot.
    for first local no-lock
        where local.noimm = cpuni.noimm
          and local.nolot = cpuni.nolot                               //nouveau lot principal
    , first ladrs no-lock
      where ladrs.tpidt = "02002"
        and ladrs.noidt = local.noloc
        and ladrs.tpadr = "00001":
        ttUnite.nolie = ladrs.nolie.
    end.

end procedure.

procedure initComboUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo. 

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspr                as class syspr no-undo.
    define variable voMotifIndisponibilite as class parametrageMotifIndisponibilite no-undo.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametreZone1("NTAPP", 0, "NATUREUL", output table ttCombo by-reference).
    voMotifIndisponibilite = new parametrageMotifIndisponibilite().
    voMotifIndisponibilite:creationttCombo("MOTIFINDISPONIBILITE", "00000", "-", output table ttCombo by-reference).
    voMotifIndisponibilite:getComboParametre("MOTIFINDISPONIBILITE", output table ttCombo by-reference).
    delete object voSyspr.
end procedure.

procedure ctrlAvantModif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.
    
    define variable vdaMax       as date no-undo.
    define variable vdaFinLot    as date no-undo.
    define variable vdaDebCmp    as date no-undo.
    define variable vdaDebMin    as date no-undo.

    define buffer unite for unite.
    define buffer ctrat for ctrat.

    if ttUniteLocation.CRUD = "C"
    then do:
        case ttUniteLocation.iNumeroAppartement:
            when 0 then do:
                mError:createError({&error}, 100628).
                return.
            end.
            when 997 then do:
                if codeNature ("NTAPP", 997, "") <> ttUniteLocation.cCodeNatureUL
                then do:
                    mError:createErrorGestion({&error}, 100630, ttUniteLocation.cCodeNatureUL).
                    return.
                end.
            end.
            when 998 then do:
                mError:createErrorGestion({&error}, 100626, "").
                return.
            end.
            when 999 then do:
                mError:createErrorGestion({&error}, 107753, "").
                return.
            end.
            otherwise do:
                if can-find (first unite no-lock
                             where unite.nomdt = ttUniteLocation.iNumeroContrat
                               and unite.noapp = ttUniteLocation.iNumeroAppartement)
                then do:
                    mError:createErrorGestion({&error}, 100627, string(ttUniteLocation.iNumeroAppartement)).
                    return.
                end.
            end.
        end case.
        if ttUniteLocation.iNumeroComposition <> 10
        then do:
            mError:createError({&error}, 1000515).            //en création le numéro de composition doit être = 10
            return.
        end.
        if not can-find (first ttCompositionUnite
                         where ttCompositionUnite.iNumeroContrat     = ttUniteLocation.iNumeroContrat
                           and ttCompositionUnite.iNumeroAppartement = ttUniteLocation.iNumeroAppartement
                           and ttCompositionUnite.iNumeroComposition = ttUniteLocation.iNumeroComposition)
        then do:
            mError:createError({&error}, 100648).
            return.
        end.
    end.
    else do:
        if ttUniteLocation.iNumeroAppartement = 998
        then return.
        find first unite no-lock
             where unite.nomdt = ttUniteLocation.iNumeroContrat
               and unite.noapp = ttUniteLocation.iNumeroAppartement
               and unite.noact = 0 no-error.
        if not available unite
        then do:
            mError:createError({&error}, 1000519).          //enregistrement unité inexistant //devrait toujours exister
            return.
        end.
        if ttUniteLocation.iNumeroComposition = unite.nocmp              //les controles suivants ne sont pas a faire si pas de nouvelle composition
        then return.
        if ttUniteLocation.iNumeroComposition <> unite.nocmp + 1
        then do:
            mError:createError({&error}, 1000516).         //en création de composition le numéro de composition doit être +1 par rapport au numéro de composition actif
            return.
        end.
        if not can-find (first ttCompositionUnite
                         where ttCompositionUnite.CRUD <> "D"
                           and ttCompositionUnite.iNumeroContrat     = ttUniteLocation.iNumeroContrat
                           and ttCompositionUnite.iNumeroAppartement = ttUniteLocation.iNumeroAppartement
                           and ttCompositionUnite.iNumeroComposition = ttUniteLocation.iNumeroComposition)
        then for first ctrat no-lock
                 where ctrat.tpcon = {&TYPECONTRAT-bail}
                   and ctrat.nocon = unite.norol:
            if ctrat.dtree = ?
            or ctrat.dtree >= ttUniteLocation.daDateDebutComposition
            then do:                 
                // Vous ne pouvez pas supprimer tous les lots de cette unite de location car le bail X est actif a cette date
                mError:createErrorGestion({&error}, 105225, string(unite.norol)).
                return.
            end.
        end.        
    end.
    if can-find(first ttCompositionUnite
                where ttCompositionUnite.iNumeroContrat     = ttUniteLocation.iNumeroContrat
                  and ttCompositionUnite.iNumeroAppartement = ttUniteLocation.iNumeroAppartement
                  and ttCompositionUnite.iNumeroComposition <> ttUniteLocation.iNumeroComposition)
    then do:
        mError:createError({&error}, 1000517).              //détail composition avec mauvais numéro de composition
        return.
    end.
    if ttUniteLocation.iNumeroLotPrincipal = ? or ttUniteLocation.iNumeroLotPrincipal = 0
    then do:
        mError:createError({&error}, 1000518).             //le lot principal doit être renseigné
        return.
    end.
    if ttUniteLocation.daDateDebutComposition = ?
    then do:
        mError:createError({&error}, 100853).            //La date de debut est obligatoire
        return.
    end.
    for each ttCompositionUnite
       where ttCompositionUnite.iNumeroContrat     = ttUniteLocation.iNumeroContrat
         and ttCompositionUnite.iNumeroAppartement = ttUniteLocation.iNumeroAppartement
         and ttCompositionUnite.iNumeroComposition = ttUniteLocation.iNumeroComposition:
        run RecDatFinMax (gINumeroImmeuble, ttCompositionUnite.iNumeroLot, ttUniteLocation.iNumeroContrat, output vdaMax).
        if vdaMax <> ?
        then do:
            if vdaFinLot = ?
            then vdaFinLot = vdaMax.
            else vdaFinLot = maximum(vdaFinLot, vdaMax).
        end.
    end.

    if ttUniteLocation.CRUD = "C"
    then vdaDebMin = ?.
    else vdaDebMin = unite.dtdeb + 1.
    if vdaFinLot <> ?
    then vdaDebCmp = vdaFinLot + 1.
    else vdaDebCmp = vdaDebMin.
    if ttUniteLocation.daDateDebutComposition < vdaDebCmp
    then do:
        mError:createErrorGestion({&error}, 100673, string(vdaDebCmp)). //La date saisie est anterieure a la date de debut possible %1
        return.
    end.

end procedure.

procedure RecDatFinMax private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : depuis adb/lib/RecDatFinMax
    ------------------------------------------------------------------------------*/
    define input  parameter piNoImm   as integer no-undo.
    define input  parameter piNoLot   as integer no-undo.
    define input  parameter piNoMdt   as integer no-undo.
    define output parameter pdaFinMax as date    no-undo.

    define variable vdaDebMax as date no-undo.

    define buffer cpuni  for cpuni.
    define buffer local  for local.
    define buffer unite  for unite.

    for each cpuni no-lock
       where cpuni.noimm = piNoImm
         and cpuni.nolot = piNoLot
         and cpuni.nomdt = piNoMdt
         and cpuni.noapp < 997               /* 22/05/2003 - SY : pas d'histo des lots vacants ou prop */
      , first local no-lock
        where local.noimm = cpuni.noimm
          and local.nolot = cpuni.nolot
          and local.fgdiv = no
      , first unite no-lock
        where unite.nomdt = cpuni.nomdt
          and unite.noapp = cpuni.noapp
          and unite.nocmp = cpuni.nocmp:
        assign
            vdaDebMax = if vdaDebMax = ? then unite.dtdeb else maximum(vdaDebMax, unite.dtdeb)
            pdaFinMax = if pdaFinMax = ? then unite.dtfin else maximum(pdaFinMax, unite.dtfin)
        .
    end.
    /*--> Si la dernière UL n'est pas cloturé on prend la dernière date de début */
    if pdaFinMax = ? then pdaFinMax = vdaDebMax.

end procedure.

procedure creationUnite private:
    /*------------------------------------------------------------------------------
    Purpose: creation unite
    Notes  : a partir de adb/tach/creapp00.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.

    define buffer ladrs for ladrs.
    define buffer local for local.

    empty temp-table ttUnite.
    create ttUnite.
    assign
        ttUnite.CRUD        = "C"
        ttUnite.nomdt       = ttUniteLocation.iNumeroContrat
        ttUnite.noapp       = ttUniteLocation.iNumeroAppartement
        ttUnite.noact       = 0
        ttUnite.noman       = giNumeroMandant
        ttUnite.nocmp       = ttUniteLocation.iNumeroComposition
        ttUnite.cdcmp       = ttUniteLocation.cCodeNatureUL
        ttunite.cdusa       = ttUniteLocation.cCodeUsage
        ttUnite.dtdeb       = ttUniteLocation.daDateDebutComposition
        ttUnite.noimm       = gINumeroImmeuble
        ttUnite.nolot       = ttUniteLocation.iNumeroLotPrincipal
        ttUnite.cdocc       = ttUniteLocation.cCodeOccupation       //"00002" en creation
        ttUnite.tprol       = {&TYPEROLE-locataire}
        ttUnite.norol       = if ttUniteLocation.iNumeroAppartement <> 998 then ttUniteLocation.iNumeroLocataire else 0
        ttUnite.lbdiv       = (if ttUniteLocation.daDateDebutIndisponibilite <> ? then string(ttUniteLocation.daDateDebutIndisponibilite,"99/99/9999") else "") +
                              "&" +
                              (if ttUniteLocation.daDateFinIndisponibilite <> ? then string(ttUniteLocation.daDateFinIndisponibilite,"99/99/9999") else "") + 
                              "&" + 
                              cCodeMotifIndisponibilite
        ttUnite.cdmotindis  = ttUniteLocation.cCodeMotifIndisponibilite
        ttUnite.dtdebindis  = ttUniteLocation.daDateDebutIndisponibilite
        ttUnite.dtfinindis  = ttUniteLocation.daDateFinIndisponibilite
     .
     for first local no-lock
        where local.noimm = gINumeroImmeuble
          and local.nolot = ttUniteLocation.iNumeroLotPrincipal
      , first ladrs no-lock
        where ladrs.tpidt = {&TYPEBIEN-lot}
          and ladrs.noidt = local.noloc
          and ladrs.tpadr = {&TYPEADRESSE-Principale}:
        ttUnite.nolie = ladrs.nolie.
    end.
    if not valid-handle(ghUnite)
    then do:
        run adblib/unite_CRUD.p persistent set ghUnite.
        run getTokenInstance in ghUnite(mToken:JSessionId).
    end.
    run setUnite in ghUnite(table ttUnite by-reference).
    if mError:erreur() then return.

/*gga todo
        /* Ajout SY le 06/09/2006 : si param charges locatives sur UL vacantes */
        /* alors création auto du bail de rang 00                              */
        IF FgChgVac THEN DO:
            ChArgPrg = ""
                    + "|" + ""
                    + "|" + TpRolUse
                    + "|" + STRING(NoRolUse)
                    + "|" + TpCttUse
                    + "|" + STRING(NoCttUse)
                    + "|" + HwNumApp:SCREEN-VALUE
                    + "|" + "01033"
                    + "|" + "03094"         /* spécial vacant (propriétaire) */
            .
            RUN VALUE (RpRunCtt + "CreBail.p") (INPUT-OUTPUT ChArgPrg ).
        END.
gga*/

end procedure.

procedure majDateFinUnite private:
    /*------------------------------------------------------------------------------
    Purpose: maj date de fin sur l'unite active actuelle (avant creation de la nouvelle composition)
    Notes  : a partir de adb/tach/creapp00.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.

    empty temp-table ttUnite.
    create ttUnite.
    assign
        ttUnite.nomdt       = ttUniteLocation.iNumeroContrat
        ttUnite.noapp       = ttUniteLocation.iNumeroAppartement
        ttUnite.noact       = ttUniteLocation.iNumeroComposition - 1     //code actif = valeur de la composition avant creation de la nouvelle composition
        ttUnite.dtFin       = ttUniteLocation.daDateDebutComposition
        ttUnite.CRUD        = "U"
        ttUnite.dtTimestamp = ttUniteLocation.dtTimestamp
        ttUnite.rRowid      = ttUniteLocation.rRowid
    .
    if not valid-handle(ghUnite)
    then do:
        run adblib/unite_CRUD.p persistent set ghUnite.
        run getTokenInstance in ghUnite(mToken:JSessionId).
    end.
    run setUnite in ghUnite(table ttUnite by-reference).

end procedure.

procedure modifComposition private:
    /*------------------------------------------------------------------------------
    Purpose: changement composition
    Notes  : a partir de adb/tach/creapp00.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.

    define buffer vbttCompositionUnite for ttCompositionUnite.
    define buffer cpuni for cpuni.

    for each ttCompositionUnite
        where ttCompositionUnite.iNumeroContrat     = ttUniteLocation.iNumeroContrat
          and ttCompositionUnite.iNumeroAppartement = ttUniteLocation.iNumeroAppartement
          and ttCompositionUnite.iNumeroComposition = ttUniteLocation.iNumeroComposition:
              
        if not can-find (first vbttCompositionUnite
                         where vbttCompositionUnite.iNumeroContrat     = ttUniteLocation.iNumeroContrat
                           and vbttCompositionUnite.iNumeroAppartement = 998
                           and vbttCompositionUnite.iNumeroComposition = 10
                           and vbttCompositionUnite.iNumeroLot         = ttCompositionUnite.iNumeroLot)
        then do:
            //si plus dans la composition du lot 998, suppression du cpuni  
            find last cpuni no-lock
                where cpuni.nomdt = ttUniteLocation.iNumeroContrat
                  and cpuni.noimm = gINumeroImmeuble
                  and cpuni.nolot = ttCompositionUnite.iNumeroLot
                  and cpuni.noapp = 998 
                  and cpuni.nocmp = 10 no-error.
            if available cpuni
            then do: 
                if not valid-handle(ghCpuni)
                then do:
                    run immeubleEtLot/cpuni_crud.p persistent set ghCpuni.
                    run getTokenInstance in ghCpuni(mToken:JSessionId).
                end.
                empty temp-table ttCpuni.
                create ttCpuni.
                assign
                    ttCpuni.nomdt       = cpuni.nomdt
                    ttCpuni.noimm       = cpuni.noimm
                    ttCpuni.nolot       = cpuni.nolot
                    ttCpuni.noapp       = cpuni.noapp
                    ttCpuni.nocmp       = cpuni.nocmp
                    ttCpuni.noord       = cpuni.noord
                    ttCpuni.dtTimestamp = datetime(cpuni.dtmsy, cpuni.hemsy)
                    ttCpuni.CRUD        = 'D'
                    ttCpuni.rRowid      = rowid(cpuni)
                .
                run setCpuni in ghCpuni(table ttCpuni by-reference).
                if mError:erreur() = yes then return.
            end.
        end.
        if not valid-handle(ghCpuni)
        then do:
            run immeubleEtLot/cpuni_crud.p persistent set ghCpuni.
            run getTokenInstance in ghCpuni(mToken:JSessionId).
        end.
        empty temp-table ttCpuni.
        create ttCpuni.
        assign
            ttCpuni.nomdt = ttUniteLocation.iNumeroContrat
            ttCpuni.noapp = ttUniteLocation.iNumeroAppartement
            ttCpuni.nocmp = ttUniteLocation.iNumeroComposition
            ttCpuni.noman = giNumeroMandant
            ttCpuni.noimm = gINumeroImmeuble
            ttCpuni.nolot = ttCompositionUnite.iNumeroLot
            ttCpuni.cdori = ""
            ttCpuni.sflot = ttCompositionUnite.dSurface
            ttCpuni.CRUD  = "C"
        .
        run createCompositionUnite in ghCpuni(table ttCpuni by-reference).
        if mError:erreur() = yes then return.
    end.

end procedure.

procedure modifComposition998 private:
    /*------------------------------------------------------------------------------
    Purpose: changement composition unite 998
    Notes  : a partir de adb/tach/creapp00.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.

    define buffer cpuni for cpuni.

    for each ttCompositionUnite
        where ttCompositionUnite.iNumeroContrat     = ttUniteLocation.iNumeroContrat
          and ttCompositionUnite.iNumeroAppartement = 998
          and ttCompositionUnite.iNumeroComposition = 10:

        //Recherche si ce lot etait dejà non attribue
        find last cpuni no-lock
            where cpuni.nomdt = ttUniteLocation.iNumeroContrat
              and cpuni.noimm = gINumeroImmeuble
              and cpuni.nolot = ttCompositionUnite.iNumeroLot
              and cpuni.noapp = 998
              and cpuni.nocmp = 10 no-error.

        if not available cpuni
        then do:
            find last cpuni no-lock
                where cpuni.nomdt = ttUniteLocation.iNumeroContrat
                  and cpuni.noimm = gINumeroImmeuble
                  and cpuni.nolot = ttCompositionUnite.iNumeroLot
                  and cpuni.noapp = ttUniteLocation.iNumeroAppartement
                  and cpuni.nocmp = (ttUniteLocation.iNumeroComposition - 1) no-error.

            if not available cpuni then do:
                mError:createErrorGestion({&error}, 100658, string(ttCompositionUnite.iNumeroLot)). //Cas qui ne doit jamais arrive
                return.
            end.
            if not valid-handle(ghCpuni)
            then do:
                run immeubleEtLot/cpuni_crud.p persistent set ghCpuni.
                run getTokenInstance in ghCpuni(mToken:JSessionId).
            end.
            empty temp-table ttCpuni.
            create ttCpuni.
            assign
                ttCpuni.nomdt       = cpuni.nomdt
                ttCpuni.nolot       = cpuni.nolot
                ttCpuni.noapp       = cpuni.noapp
                ttCpuni.nocmp       = cpuni.nocmp
                ttCpuni.noord       = cpuni.noord
                ttCpuni.cdori       = "F"
                ttCpuni.dtTimestamp = datetime(cpuni.dtmsy, cpuni.hemsy)
                ttCpuni.CRUD        = 'U'
                ttCpuni.rRowid      = rowid(cpuni)
            .

            run updateCompositionUnite in ghCpuni(table ttCpuni by-reference).
            if mError:erreur() = yes then return.

            empty temp-table ttCpuni.
            create ttCpuni.
            assign
                ttCpuni.nomdt = ttUniteLocation.iNumeroContrat
                ttCpuni.noapp = 998
                ttCpuni.nocmp = 10
                ttCpuni.noman = giNumeroMandant
                ttCpuni.noimm = gINumeroImmeuble
                ttCpuni.nolot = ttCompositionUnite.iNumeroLot
                ttCpuni.cdori = ""
                ttCpuni.sflot = ttCompositionUnite.dSurface
                ttCpuni.CRUD  = "C"
            .
            run createCompositionUnite in ghCpuni(table ttCpuni by-reference).
            if mError:erreur() = yes then return.
        end.
        else do:
            if not valid-handle(ghCpuni)
            then do:
                run immeubleEtLot/cpuni_crud.p persistent set ghCpuni.
                run getTokenInstance in ghCpuni(mToken:JSessionId).
            end.
            empty temp-table ttCpuni.
            create ttCpuni.
            assign
                ttCpuni.nomdt       = cpuni.nomdt
                ttCpuni.nolot       = cpuni.nolot
                ttCpuni.noapp       = 998
                ttCpuni.nocmp       = 10
                ttCpuni.noord       = cpuni.noord
                ttcpuni.sflot       = ttCompositionUnite.dSurface
                ttCpuni.dtTimestamp = datetime(cpuni.dtmsy, cpuni.hemsy)
                ttCpuni.CRUD        = 'U'
                ttCpuni.rRowid      = rowid(cpuni)
            .
            run updateCompositionUnite in ghCpuni (table ttCpuni by-reference).
            if mError:erreur() = yes then return.
        end.
    end.

end procedure.

procedure lectureUniteLocation private:
    /*------------------------------------------------------------------------------
    Purpose: Liste des UL d'un mandat (a partir de lisctapp.p)
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat   as character no-undo.
    define input  parameter piNumeroMandat as integer   no-undo.

    define variable vlAppUn            as logical no-undo.
    define variable viNbrElComposition as integer no-undo.
    define variable voMotifIndisponibilite as class parametrageMotifIndisponibilite no-undo.

    define buffer ctrat   for ctrat.
    define buffer unite   for unite.
    define buffer vbunite for unite.
    define buffer tache   for tache.

    voMotifIndisponibilite = new parametrageMotifIndisponibilite("").  // on instantie l'object une fois, et on utilise reload.
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat
      , each unite no-lock
        where unite.nomdt = ctrat.nocon:

        /*--> Recherche si composition unique */
        vlAppUn = can-find(first vbunite no-lock
                           where vbunite.nomdt = ctrat.nocon
                             and vbunite.noapp = unite.noapp
                             and vbunite.nocmp <> unite.nocmp)
                  or (unite.dtdeb < today or unite.dtdeb = ?).  // Attention de ne pas changer l'ordre des items can-find et 'or'
        if vlAppUn = false or (unite.dtdeb < today and (unite.dtfin = ? or unite.dtfin >= today))
        then do:
            create ttUniteLocation.
            assign
                ttUniteLocation.CRUD                       = 'R'
                ttUniteLocation.cCodeTypeContrat           = ctrat.tpcon
                ttUniteLocation.iNumeroContrat             = ctrat.nocon
                ttUniteLocation.iNumeroAppartement         = unite.noapp
                ttUniteLocation.iCodeActif                 = unite.noact
                ttUniteLocation.iNumeroComposition         = unite.nocmp
                ttUniteLocation.cCodeNatureUL              = unite.cdcmp
                ttUniteLocation.cLibelleNatureUL           = outilTraduction:getLibelleParam("NTAPP", unite.cdcmp)
                ttUniteLocation.cCodeUsage                 = unite.cdusa
                ttUniteLocation.cLibelleUsage              = getUsageUL (unite.cdcmp, unite.cdusa)
                ttUniteLocation.cCodeOccupation            = unite.cdocc
                ttUniteLocation.cLibelleOccupation         = outilTraduction:getLibelleParam("NTOCC", if Unite.NoApp = 997 then "00003" else unite.cdocc)
                ttUniteLocation.iNumeroLocataire           = unite.norol
                ttUniteLocation.cNomLocataire              = if unite.norol = 0 then "" else outilFormatage:getNomTiers("00019", unite.norol)
                ttUniteLocation.daDateDebutComposition     = unite.dtdeb
                ttUniteLocation.cCodeMotifIndisponibilite  = unite.cdmotindis
                ttUniteLocation.daDateDebutIndisponibilite = unite.dtdebindis
                ttUniteLocation.daDateFinIndisponibilite   = unite.dtfinindis
                ttUniteLocation.iNumeroLotPrincipal        = unite.nolot
                ttUniteLocation.dtTimestamp                = datetime(unite.dtmsy, unite.hemsy)
                ttUniteLocation.rRowid                     = rowid(unite)
            .
            /*--> Date de Sortie du locataire */
            if unite.cdOcc = "00002"
            then for first tache no-lock
                where tache.tpcon = {&TYPECONTRAT-bail}
                  and tache.nocon = unite.norol
                  and tache.tptac = {&TYPETACHE-quittancement}
                  and tache.dtfin <> ?:
                ttUniteLocation.daDateSortie = tache.dtfin.
            end.
            if unite.cdmotindis > ""
            then do:
                voMotifIndisponibilite:reload(unite.cdmotindis).
                if voMotifIndisponibilite:isDbParameter
                then ttUniteLocation.cLibelleMotifIndisponibilite = voMotifIndisponibilite:getLibelleMotif().
            end.
            run lectureCompositionUniteLocation(unite.nomdt, unite.noapp, unite.nocmp, output viNbrElComposition).
            run GerEtaMod (buffer ttUniteLocation, viNbrElComposition).

        end.
    end.
    delete object voMotifIndisponibilite.
end procedure.

procedure lectureHistoriqueCompositionUL private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter piNumeroUL     as integer   no-undo.

    define variable vlAppUn            as logical no-undo.
    define variable viNbrElComposition as integer no-undo.
    define variable voMotifIndisponibilite as class parametrageMotifIndisponibilite no-undo.

    define buffer ctrat   for ctrat.
    define buffer unite   for unite.
    define buffer tache   for tache.

    voMotifIndisponibilite = new parametrageMotifIndisponibilite("").  // on instantie l'object une fois, et on utilise reload.
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat
      , each unite no-lock
        where unite.nomdt = ctrat.nocon
          and unite.noapp = piNumeroUL:
        create ttUniteLocation.
        assign
            ttUniteLocation.CRUD                       = 'R'
            ttUniteLocation.cCodeTypeContrat           = ctrat.tpcon
            ttUniteLocation.iNumeroContrat             = ctrat.nocon
            ttUniteLocation.iNumeroAppartement         = unite.noapp
            ttUniteLocation.iCodeActif                 = unite.noact
            ttUniteLocation.iNumeroComposition         = unite.nocmp
            ttUniteLocation.cCodeNatureUL              = unite.cdcmp
            ttUniteLocation.cLibelleNatureUL           = outilTraduction:getLibelleParam("NTAPP", unite.cdcmp)           
            ttUniteLocation.cCodeUsage                 = unite.cdusa
            ttUniteLocation.cLibelleUsage              = getUsageUL (unite.cdcmp, unite.cdusa)
            ttUniteLocation.cCodeOccupation            = unite.cdocc
            ttUniteLocation.cLibelleOccupation         = outilTraduction:getLibelleParam("NTOCC", if Unite.NoApp = 997 then "00003" else unite.cdocc)
            ttUniteLocation.iNumeroLocataire           = unite.norol
            ttUniteLocation.cNomLocataire              = if unite.norol = 0 then "" else outilFormatage:getNomTiers("00019", unite.norol)
            ttUniteLocation.daDateDebutComposition     = unite.dtdeb
            ttUniteLocation.cCodeMotifIndisponibilite  = unite.cdmotindis
            ttUniteLocation.daDateDebutIndisponibilite = unite.dtdebindis
            ttUniteLocation.daDateFinIndisponibilite   = unite.dtfinindis
            ttUniteLocation.iNumeroLotPrincipal        = unite.nolot
            ttUniteLocation.dtTimestamp                = datetime(unite.dtmsy, unite.hemsy)
            ttUniteLocation.rRowid                     = rowid(unite)
        .
        /*--> Date de Sortie du locataire */
        if unite.cdOcc = "00002"
        then for first tache no-lock
            where tache.tpcon = {&TYPECONTRAT-bail}
              and tache.nocon = unite.norol
              and tache.tptac = {&TYPETACHE-quittancement}
              and tache.dtfin <> ?:
            ttUniteLocation.daDateSortie = tache.dtfin.
        end.
        if unite.cdmotindis > ""
        then do:
            voMotifIndisponibilite:reload(unite.cdmotindis).
            if voMotifIndisponibilite:isDbParameter
            then ttUniteLocation.cLibelleMotifIndisponibilite = voMotifIndisponibilite:getLibelleMotif().
        end.
        run lectureCompositionUniteLocation(unite.nomdt, unite.noapp, unite.nocmp, output viNbrElComposition).
        run GerEtaMod (buffer ttUniteLocation, viNbrElComposition).

    end.
    delete object voMotifIndisponibilite.
end procedure.

procedure lectureCompositionUniteLocation private:
    /*------------------------------------------------------------------------------
    Purpose: recherche composition unite de location (a partir de lstlotap.i)
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNoMdt            as integer no-undo.
    define input  parameter piNoApp            as integer no-undo.
    define input  parameter piNoCmp            as integer no-undo.
    define output parameter piNbrElComposition as integer no-undo.

    define buffer cpuni for cpuni.
    define buffer local for local.
    define buffer usagelot for usagelot.

    for each cpuni no-lock
        where cpuni.nomdt = piNoMdt
          and cpuni.noapp = piNoApp
          and cpuni.nocmp = piNoCmp
      , first local no-lock
        where local.nolot = cpuni.nolot
          and local.noimm = cpuni.noimm:
        create ttCompositionUnite.
        assign
            piNbrElComposition                     = piNbrElComposition + 1
            ttCompositionUnite.CRUD                = 'R'
            ttCompositionUnite.dtTimestamp         = datetime(cpuni.dtmsy, cpuni.hemsy)
            ttCompositionUnite.rRowid              = rowid(cpuni)
            ttCompositionUnite.iNumeroContrat      = cpuni.nomdt
            ttCompositionUnite.iNumeroAppartement  = cpuni.noapp
            ttCompositionUnite.iNumeroComposition  = cpuni.nocmp
            ttCompositionUnite.iNumeroLot          = cpuni.nolot
            ttCompositionUnite.iNumeroOrdreLot     = cpuni.noord
            ttCompositionUnite.lDivisible          = local.fgdiv
            ttCompositionUnite.dSurface            = if local.fgdiv then cpuni.sflot else local.sfree
            ttCompositionUnite.cBatiment           = local.cdbat
            ttCompositionUnite.cEscalier           = local.cdesc
            ttCompositionUnite.cPorte              = local.cdpte
            ttCompositionUnite.cEtage              = local.cdeta
            ttCompositionUnite.cNature             = local.ntlot
            ttCompositionUnite.cLibNature          = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
            ttCompositionUnite.lLotPrincipal       = (cpuni.noord = 1)
            ttCompositionUnite.dLoyerMandat        = local.montantFamille[1]
        .
        case local.usnon:
            when ""      then ttCompositionUnite.dSurfaceCarrez = local.sfnon.
            when "00001" then ttCompositionUnite.dSurfaceCarrez = local.sfnon.
            when "00002" then ttCompositionUnite.dSurfaceCarrez = (local.sfnon * 1000).
            when "00003" then ttCompositionUnite.dSurfaceCarrez = (local.sfnon / 100).
        end.
        {&_proparse_ prolint-nowarn(wholeindex)}
        for first usagelot no-lock
            where usagelot.cdusa = local.cdusage:
            ttCompositionUnite.cLibUsageLot = usagelot.lbusa.
        end.
        if ttCompositionUnite.iNumeroAppartement = 998
        then run RecDatFinMax (local.noimm, local.nolot, cpuni.nomdt, output ttCompositionUnite.daDisponible).
    end.

end procedure.

procedure GerEtaMod private:
    /*------------------------------------------------------------------------------
    Purpose: gestion du type de maj autorisé
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.
    define input parameter piNbrElComposition as integer no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    ttUniteLocation.cChangementAutorise = "1111".                                                    //Gestion de l'activite de la barre d'icones 2
    if ttUniteLocation.iNumeroAppartement = 998 then ttUniteLocation.cChangementAutorise = "0000".   //MAJ du code action des boutons modif
    if piNbrElComposition <= 1
    then substring(ttUniteLocation.cChangementAutorise, 1, 1, 'character') = "0".                    //Bouton lot principal
    if ttUniteLocation.iNumeroAppartement = 997
    then substring(ttUniteLocation.cChangementAutorise, 2, 1, 'character') = "0".                    //Bouton nature
    if piNbrElComposition = 0 and not attPre998(ttUniteLocation.iNumeroContrat )
    then substring(ttUniteLocation.cChangementAutorise, 3, 1, 'character') = "0".                    //L'appart a aucun lot et il n'y a pas de lot non attribue : btn changement de la composition

    /*--> Si UL loué :  bouton modif indisponibilité insensitif "INDIS" */
    substring(ttUniteLocation.cChangementAutorise, 4, 1, 'character') = "0".
    for first ctrat no-lock                                                                          //Recherche du bail
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.nocon = ttUniteLocation.iNumeroLocataire
          and ctrat.dtree <> ?:
            substring(ttUniteLocation.cChangementAutorise, 4, 1, 'character') = "1".
    end.
    for first tache no-lock                                                                          //Recherche de la sortie locataire
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = ttUniteLocation.iNumeroLocataire
          and tache.tptac = {&TYPETACHE-quittancement}
          and tache.dtfin <> ?:
        substring(ttUniteLocation.cChangementAutorise, 4, 1, 'character') = "1".
    end.
    if ttUniteLocation.cCodeOccupation = "00002" then substring(ttUniteLocation.cChangementAutorise, 4, 1, 'character') = "1".  //Ajout SY le 01/09/2011: les vacants jamais loués aussi

end procedure.

procedure modifAssurancePno private:
    /*------------------------------------------------------------------------------
    Purpose: changement lot principal si tache assurance pno existe 
    Notes  : a partir de adb/tach/creapp00.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttUniteLocation for ttUniteLocation.
    define input parameter piAncLotPrincipal as integer no-undo.

    define variable vhAspno as handle no-undo.

    if can-find(first tache no-lock
                where tache.tpcon = ttUniteLocation.cCodeTypeContrat
                  and tache.nocon = ttUniteLocation.iNumeroContrat
                  and tache.tptac = {&TYPETACHE-proprietaireNonOccupant})
    then do:
        run adblib/aspno_CRUD.p persistent set vhAspno.
        run getTokenInstance in vhAspno(mToken:JSessionId).
        empty temp-table ttAspno.
        run readAspno in vhAspno(
            ttUniteLocation.cCodeTypeContrat,
            ttUniteLocation.iNumeroContrat,
            1,
            piAncLotPrincipal,
            table ttAspno by-reference
        ).
        for first ttAspno:
            assign
                ttAspno.nolot = ttUniteLocation.iNumeroLotPrincipal
                ttAspno.CRUD  = "U"
            .
            run setAspno in vhAspno(table ttAspno by-reference).
        end.
        run destroy in vhAspno.
    end.
end procedure.
