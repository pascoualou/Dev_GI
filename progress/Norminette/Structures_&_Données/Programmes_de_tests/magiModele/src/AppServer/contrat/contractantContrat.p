/*------------------------------------------------------------------------
File        : contractantContrat.p
Purpose     : contractants d'un contrat
Author(s)   : GGA  -  2017/08/31
Notes       : reprise du pgm adb/cont/gespcc00.p
derniere revue: 2018/04/11 - phm. OK
------------------------------------------------------------------------*/
{preprocesseur/type2adresse.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/referenceClient.i}

using parametre.syspg.syspg.
using parametre.pclie.parametrageRoleDefaut.
using parametre.pclie.parametrageRoleTemporaire.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{contrat/include/roleContrat.i &nomtable=ttRoleContractant}
{crud/include/intnt.i}
{crud/include/unite.i}
{immeubleEtLot/include/cpuni.i}
{crud/include/ctrat.i}
{compta/include/ietab.i}
{tache/include/tache.i}
{crud/include/aecha.i}
{crud/include/acpte.i}
{crud/include/etabl.i}
{crud/include/roles.i}
{crud/include/ilienadresse.i}
{crud/include/ttDbTiers.i}
{crud/include/rlctt.i}

define variable gcRolePrincipal     as character no-undo.
define variable gcTypeParametreRole as character no-undo.
define variable gcCleParametreRole  as character no-undo.

function lancementPgm return handle private(pcProgramme as character, pcProcedure as character, table-handle phTable ):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    run value(pcProgramme) persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run value(pcProcedure) in vhProc(table-handle phTable by-reference).
    run destroy in vhProc.

end function.

function NoMandant returns integer private(pcTypeMandat as character, piNumeroMandat as integer):
    /*------------------------------------------------------------------------
    Purpose: retourne numero du mandant du mandat
    Notes  :
    ------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    for first intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.tpidt = {&TYPEROLE-mandant}
          and intnt.nocon = piNumeroMandat:
        return intnt.noidt.
    end.
    return ?.

end function.

procedure initTypeCleRoleEtRolePrincipal private:
    /*------------------------------------------------------------------------------
    Purpose: initialisation type de role et cle du role a utiliser dans les recherches sur sys_pg
             et du role principal.
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcNatureContrat as character no-undo.
    define buffer sys_pg for sys_pg.

    if pcTypeContrat = {&TYPECONTRAT-preBail}
    then assign
        gcTypeParametreRole = "R_CLR"
        gcCleParametreRole  = pcTypeContrat
    .
    else assign
        gcTypeParametreRole = "R_CR1"
        gcCleParametreRole  = pcNatureContrat
    .
    for first sys_pg no-lock
        where sys_pg.tppar = gcTypeParametreRole
          and sys_pg.zone1 = gcCleParametreRole
          and sys_pg.zone7 = "P":
        gcRolePrincipal = sys_pg.zone2.
    end.
    if gcRolePrincipal = ? or gcRolePrincipal = ""
    then mError:createError({&error}, 1000606).             //Rôle principal non défini pour cette nature de contrat

end procedure.

procedure getRoleContractant:
    /*------------------------------------------------------------------------------
    Purpose: affichage role contractant d'un contrat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttRoleContractant.

    define buffer ctrat  for ctrat.
    define buffer intnt  for intnt.
    define buffer sys_pg for sys_pg.

    empty temp-table ttRoleContractant.
    
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run initTypeCleRoleEtRolePrincipal(ctrat.tpcon, ctrat.ntcon).
    if mError:erreur() then return.

    for each sys_pg no-lock
        where sys_pg.tppar = gcTypeParametreRole
          and sys_pg.zone1 = gcCleParametreRole
      , each intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = sys_pg.zone2:
        create ttRoleContractant.
        assign
            ttRoleContractant.cTypeContrat   = intnt.tpcon
            ttRoleContractant.iNumeroContrat = intnt.nocon
            ttRoleContractant.cTypeRole      = intnt.tpidt
            ttRoleContractant.cLibTypeRole   = outilTraduction:getLibelleProgZone2(gcTypeParametreRole, gcCleParametreRole, intnt.tpidt)
            ttRoleContractant.iNumeroRole    = intnt.noidt
            ttRoleContractant.cNom           = outilFormatage:getNomTiers(intnt.tpidt, intnt.noidt)
            ttRoleContractant.cAdresse       = outilFormatage:formatageAdresse(intnt.tpidt, intnt.noidt)
            ttRoleContractant.lRolePrincipal = (intnt.tpidt = gcRolePrincipal)
            ttRoleContractant.dtTimestamp    = datetime(intnt.dtmsy, intnt.hemsy)
            ttRoleContractant.CRUD           = "R"
            ttRoleContractant.rRowid         = rowid(intnt)
        .
    end.

end procedure.

procedure setRoleContractant:
    /*------------------------------------------------------------------------------
    Purpose: maj role d'un contrat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttRoleContractant.

    define variable viNouveauNumeroRole as int64 no-undo.
    define variable viAncienNumeroRole  as int64 no-undo.
    define buffer ctrat for ctrat.

    find first ttRoleContractant where lookup(ttRoleContractant.CRUD, "C,D") > 0 no-error.
    if not available ttRoleContractant then return.

    find first ctrat no-lock
         where ctrat.tpcon = ttRoleContractant.cTypeContrat
           and ctrat.nocon = ttRoleContractant.iNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run initTypeCleRoleEtRolePrincipal(ctrat.tpcon, ctrat.ntcon).
    if mError:erreur() then return.

    run ctrlAvantMaj(buffer ctrat, output viNouveauNumeroRole, output viAncienNumeroRole).
    if mError:erreur() then return.

    run majContractant.
    if mError:erreur() then return.

    if viNouveauNumeroRole <> 0 and viAncienNumeroRole <> 0                  // changement contractant
    and viNouveauNumeroRole <> viAncienNumeroRole
    then run chgContractant(ctrat.tpcon, ctrat.nocon, viNouveauNumeroRole, viAncienNumeroRole).
    else if viNouveauNumeroRole <> 0 and viAncienNumeroRole = 0             // si viAncienNumeroRole = 0 c'est que l'on est en creation du role
    then run nouveauContractant(buffer ctrat, viNouveauNumeroRole).

end procedure.

procedure ctrlAvantMaj private:
    /*------------------------------------------------------------------------------
    Purpose: controle avant maj role contractant d'un contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.
    define output parameter piNouveauNumeroRole as int64 no-undo.
    define output parameter piAncienNumeroRole  as int64 no-undo.

    define variable voSyspg as class syspg no-undo.
    define variable viNbrCre as integer no-undo.
    define variable viNbrSup as integer no-undo.

    define buffer vbroles for roles.

    empty temp-table ttIntnt.
    voSyspg = new syspg().
    for each ttRoleContractant where lookup(ttRoleContractant.CRUD, "C,D") > 0:
        if not voSyspg:isParamExist(gcTypeParametreRole, gcCleParametreRole, ttRoleContractant.cTypeRole)then do:
            mError:createError({&error}, 1000607, ttRoleContractant.cTypeRole).   //type de rôle &1 non autorisé
            return.
        end.
        if ttRoleContractant.cTypeRole <> gcRolePrincipal and lookup(ttRoleContractant.cTypeContrat, substitute("&1,&2",{&TYPECONTRAT-preBail},{&TYPECONTRAT-bail})) = 0
        then do:
            mError:createError({&error}, 1000608, outilTraduction:getLibelleProgZone2(gcTypeParametreRole, gcCleParametreRole, gcRolePrincipal)). //Mise à jour seulement autorisé sur rôle principal (&1)
            return.
        end.
        if lookup(ttRoleContractant.cTypeContrat, substitute("&1,&2",{&TYPECONTRAT-preBail},{&TYPECONTRAT-bail})) > 0 and
           available ctrat and ctrat.fgprov <> true then do : // Le contrat n'est plus provisoire -> ne plus permettre le rattachement de locataire 
            mError:createError({&error}, 1000935). // 1000935 0 "Ce contrat est définitif, modification des rôles impossible"
            return.
        end.            
        if ttRoleContractant.CRUD = "C" then do:
            assign
                viNbrCre            = viNbrCre + 1
                piNouveauNumeroRole = ttRoleContractant.iNumeroRole
            .
            if not can-find(first vbroles no-lock
                            where vbroles.tprol = ttRoleContractant.cTypeRole
                              and vbroles.norol = ttRoleContractant.iNumeroRole)
            then do:
                mError:createError({&error}, 1000599, substitute("&2&1&3", separ[1], ttRoleContractant.cTypeRole, ttRoleContractant.iNumeroRole)). //rôle &1 &2 inexistant
                return.
            end.
            create ttIntnt.
            assign
                ttIntnt.tpidt = ttRoleContractant.cTypeRole
                ttIntnt.noidt = ttRoleContractant.iNumeroRole
                ttIntnt.tpcon = ttRoleContractant.cTypeContrat
                ttIntnt.nocon = ttRoleContractant.iNumeroContrat
                ttIntnt.nbnum = 0
                ttIntnt.idsui = 0
                ttIntnt.nbden = 0
                ttIntnt.cdreg = ""
                ttIntnt.lbdiv = ""
                ttIntnt.CRUD  = 'C'
            .
        end.
        else if ttRoleContractant.CRUD = "D" then do:
            create ttIntnt.
            assign
                viNbrSup            = viNbrSup + 1
                piAncienNumeroRole  = ttRoleContractant.iNumeroRole
                ttIntnt.tpidt       = ttRoleContractant.cTypeRole
                ttIntnt.noidt       = ttRoleContractant.iNumeroRole
                ttIntnt.tpcon       = ttRoleContractant.cTypeContrat
                ttIntnt.nocon       = ttRoleContractant.iNumeroContrat
                ttIntnt.rRowid      = ttRoleContractant.rRowid
                ttIntnt.dtTimestamp = ttRoleContractant.dtTimestamp
                ttIntnt.CRUD        = 'D'
            .
        end.
    end.
    if can-find(first intnt no-lock                                 //recherche si role principal deja existant
                where intnt.tpcon = ctrat.tpcon
                  and intnt.nocon = ctrat.nocon
                  and intnt.tpidt = gcRolePrincipal)
    then do:
        if lookup(ctrat.tpcon,substitute("&1,&2",{&TYPECONTRAT-preBail},{&TYPECONTRAT-bail})) = 0 then do :
            if viNbrCre <> viNbrSup
            then mError:createError({&error}, 1000639).   // seulement le changement du rôle principal est autorisé (pas la création ou la suppression)
        end.            
    end.
    else do:
        if viNbrCre <> 1 and viNbrSup <> 0
        then mError:createError({&error}, 1000609).   // le rôle principal est obligatoire (et doit être unique) */
    end.

end procedure.

procedure initComboContractant:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe appelé par beMandatGerance.cls, beAssuranceImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter pcNatureContrat as character no-undo.
    define output parameter table for ttCombo.

    define variable voSyspg as class syspg no-undo.
    define buffer ctrat for ctrat.

    empty temp-table ttCombo.
    // si contrat existe nature de contrat = ctrat.ntcon 
    // si non (en creation de contrat on ne connait pas encore le numero) nature de contrat en parametre
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        pcNatureContrat = ctrat.ntcon.
    end.
    if pcNatureContrat = ? or pcNatureContrat = "" then return.

    voSyspg = new syspg().
    if pcTypeContrat = {&TYPECONTRAT-preBail}
    then voSyspg:creationComboSysPgZonXX("R_CLR", "CMBROLECONTRACTANT", "L", pcTypeContrat,   output table ttCombo by-reference).
    else voSyspg:creationComboSysPgZonXX("R_CR1", "CMBROLECONTRACTANT", "L", pcNatureContrat, output table ttCombo by-reference).
    delete object voSyspg.

end procedure.

procedure majContractant private:
    /*------------------------------------------------------------------------------
    Purpose: maj role contractant d'un contrat
             la table ttIntnt pour la mise a jour a ete prepare dans la procedure de controle (ctrlAvantMaj) en modification de
             contrat ou la procedure de creation (creationContrat) en creation de contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    lancementPgm("crud/intnt_CRUD.p", "setIntnt", table ttIntnt by-reference).

end procedure.

procedure controleContractant:
    /*------------------------------------------------------------------------------
    Purpose: controle contractant
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer ctrat  for ctrat.
    define buffer sys_pg for sys_pg.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run initTypeCleRoleEtRolePrincipal(ctrat.tpcon, ctrat.ntcon).
    if mError:erreur() then return.

    for each sys_pg no-lock
        where sys_pg.tppar = gcTypeParametreRole
          and sys_pg.zone1 = gcCleParametreRole:
        if not can-find(first intnt no-lock
                        where intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.tpidt = sys_pg.zone2)
        then do:
            mError:createError({&error}, 1000610, substitute("&1 (&2)", outilTraduction:getLibelleProgZone2(gcTypeParametreRole, gcCleParametreRole, sys_pg.zone2), sys_pg.zone2)).   //contractant incomplet, manque rôle &1
            return.
        end.
    end.

end procedure.

procedure creationContrat:
    /*------------------------------------------------------------------------------
    Purpose: creation contractant par defaut a la creation d un contrat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define variable vlNumeroParDefaut as logical   no-undo.
    define variable viNumeroRole      as int64     no-undo.
    define variable voRoleDefaut      as class parametrageRoleDefaut     no-undo.
    define variable voRoleTemporaire  as class parametrageRoleTemporaire no-undo. 
    define variable vhProcImmeuble    as handle no-undo.
    define variable vcNomImmeuble     as character no-undo.
    define variable viNumeroImmeuble  as int64 no-undo.

    define buffer ctrat for ctrat.
    define buffer ctctt for ctctt.
    define buffer sys_pg  for sys_pg.
    define buffer vbroles for roles.

    empty temp-table ttIntnt.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run initTypeCleRoleEtRolePrincipal(ctrat.tpcon, ctrat.ntcon).
    if mError:erreur() then return.

    if integer(mtoken:cRefPrincipale) <> {&REFCLIENT-MANPOWER}
    then do:
        voRoleDefaut     = new parametrageRoleDefaut().
        voRoleTemporaire = new parametrageRoleTemporaire().
        
        for each sys_pg no-lock
           where sys_pg.tppar = gcTypeParametreRole
             and sys_pg.zone1 = gcCleParametreRole:
            // Recherche s'il existe une Valeur par Defaut pour ce role. Si OUI et s'il existe dans role Selection automatique.
            if sys_pg.zone2 = {&TYPEROLE-syndicat2copro} then do:
                voRoleTemporaire:reload(?, ?, ?).
                assign
                    viNumeroRole = voRoleTemporaire:getSyndicatParDefaut(sys_pg.zone2, pcTypeContrat, ctrat.ntcon) 
                    vlNumeroParDefaut = voRoleTemporaire:isDbParameter                  //attention il y a des numeros de role = 0 donc il faut ce test 
                .
            end.
            else if sys_pg.zone2 = {&TYPEROLE-mandant}
            then for first ctctt no-lock
                where ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat:
                assign
                    viNumeroRole      = NoMandant(ctctt.tpct1, ctctt.noct1)
                    vlNumeroParDefaut = yes
                .
            end.
            else if sys_pg.zone2 = {&TYPEROLE-locataire}
            then vlNumeroParDefaut = no.
            else do:
                voRoleDefaut:reload(?, ?, ?, logical(?)).       // reload avec parametre inexistant!  Ajout de "logical" sinon probleme mappage signature
                assign
                    viNumeroRole = voRoleDefaut:getRoleParDefaut(sys_pg.zone2, pcTypeContrat, ctrat.ntcon) 
                    vlNumeroParDefaut = voRoleDefaut:isDbParameter                         //attention il y a des numeros de role = 0 donc il faut ce test 
                .
            end.
            find first vbroles no-lock                                         
                 where vbroles.tprol = sys_pg.zone2
                   and vbroles.norol = viNumeroRole
                   no-error.
            if vlNumeroParDefaut and available vbroles then do:
                create ttIntnt.
                assign
                    ttIntnt.tpidt = sys_pg.zone2
                    ttIntnt.noidt = viNumeroRole
                    ttIntnt.tpcon = pcTypeContrat
                    ttIntnt.nocon = piNumeroContrat
                    ttIntnt.nbnum = 0
                    ttIntnt.idsui = 0
                    ttIntnt.nbden = 0
                    ttIntnt.cdreg = ""
                    ttIntnt.lbdiv = ""
                    ttIntnt.CRUD  = 'C'
                .
                // Cas particulier pour le mandat de syndic, on doit créer le rôle syndicat si inexistant, et/ou modifier le tiers associé 
                // pour mettre le nom de l'immeuble dans le nom du tiers  
                /* ---
                if sys_pg.zone2 = {&TYPEROLE-syndicat2copro} then do:
                    // Récupération de l'immeuble du mandat
                    for first intnt no-lock
                        where intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.tpidt = {&TYPEBIEN-immeuble}
                          :
                          viNumeroImmeuble = intnt.noidt.  
                    end.
                    
                    run immeubleEtLot/immeuble.p persistent set vhProcImmeuble.
                    vcNomImmeuble = dynamic-function("getNomImmeuble" in vhProcImmeuble, viNumeroImmeuble).
                    run destroy in vhProcImmeuble.
                    
                    // Surcharge du numero de role Syndicat dans intnt
                    ttIntnt.noidt = viNumeroImmeuble.
                    
                    // Recherche et création/modification du rôle syndicat
                    find first roles no-lock
                         where roles.tprol = {&TYPEROLE-syndicat2copro}
                           and roles.norol = viNumeroImmeuble
                           no-error.
                    if not available roles then do:
                        create ttRoles.
                        assign
                            ttRoles.tprol = {&TYPEROLE-syndicat2copro}
                            ttRoles.norol = viNumeroImmeuble
                        .
                    end.
                    
                end.
                --- */ // TODO : A revoir quand la création tiers et rôle sera faite
            end.
        end.
        delete object voRoleDefaut. 
        delete object voRoleTemporaire.
    end.
    if can-find (first ttIntnt)
    then run majContractant.
    
end procedure.

procedure chgContractant private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure suite au changement des parties contractantes
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter piNouvNumeroRole as int64     no-undo.
    define input parameter piAncNumeroRole  as int64     no-undo.

    define variable viNumeroTiers        as integer   no-undo.
    define variable vcLibelleNomTiers    as character no-undo.
    define variable vcLibelleIntervenant as character no-undo.
    define variable viNumeroSiret        as integer   no-undo.
    define variable viCompteBanque       as integer   no-undo.
    define variable viNumeroImmeuble     as int64     no-undo.
    define variable vlMandatCoproActif   as logical   no-undo.
    define variable vhProcFcttelep       as handle    no-undo.

    define buffer ctrat          for ctrat.
    define buffer vbRoles        for roles.
    define buffer vb2roles       for roles.
    define buffer iLienAdresse   for iLienAdresse.
    define buffer vbiLienAdresse for iLienAdresse.
    define buffer intnt          for intnt.
    define buffer vbintnt        for intnt.
    define buffer ietab          for ietab.
    define buffer unite          for unite.
    define buffer cpuni          for cpuni.
    define buffer tiers          for tiers.
    define buffer ctanx          for ctanx.
    define buffer etabl          for etabl.
    define buffer acpte          for acpte.
    define buffer aecha          for aecha.
    define buffer tache          for tache.

    empty temp-table ttCtrat.
    empty temp-table ttIntnt.
    empty temp-table ttUnite.
    empty temp-table ttCpuni.
    empty temp-table ttIetab.
    empty temp-table ttAecha.
    empty temp-table ttAcpte.
    empty temp-table ttTache.
    empty temp-table ttEtabl.
    empty temp-table ttRoles.
    empty temp-table ttILienAdresse.
    empty temp-table ttTiers.

    for first vbRoles no-lock
        where vbRoles.tprol = gcRolePrincipal
          and vbRoles.norol = piNouvNumeroRole:
        assign
            viNumeroTiers        = vbRoles.notie
            vcLibelleIntervenant = outilFormatage:getNomTiers(gcRolePrincipal, piNouvNumeroRole)              //remplace appel formtie0.p
            vcLibelleNomTiers    = outilFormatage:getCiviliteNomTiers(gcRolePrincipal, piNouvNumeroRole, no)  //remplace appel FormTiea.p
            vcLibelleNomTiers    = entry(1, vcLibelleNomTiers, "|")                                         // ajout SY le 18/08/2009 pour ne pas prendre le C/O qui a été ajouté au formatage
        .
        /* Mettre à jour le type de role et norol dans la table ctrat */
        for first ctrat no-lock
            where ctrat.tpcon = pcTypeContrat
              and ctrat.nocon = piNumeroContrat:
            if ctrat.lbnom > ""
            then for first ietab no-lock
                where ietab.soc-cd = integer(mtoken:cRefPrincipale)
                  and ietab.etab-cd = ctrat.nocon
                  and ietab.lbrech > "":
                create ttIetab.
                assign
                    ttIetab.soc-cd      = ietab.soc-cd
                    ttIetab.etab-cd     = ietab.etab-cd
                    ttIetab.CRUD        = "U"
                    ttIetab.rRowid      = rowid(ietab)
                    ttIetab.dtTimestamp = datetime(ietab.damod, ietab.ihmod)
                    ttIetab.lbrech      = replace(ietab.lbrech, ctrat.lbnom, vcLibelleIntervenant).
            end.
            create ttCtrat.
            assign
                ttCtrat.tpcon = ctrat.tpcon
                ttCtrat.nocon = ctrat.nocon
                ttCtrat.tprol = gcRolePrincipal
                ttCtrat.norol = piNouvNumeroRole
                ttCtrat.lbnom = vcLibelleIntervenant
                ttCtrat.lnom2 = vcLibelleNomTiers
                ttCtrat.CRUD        = "U"
                ttCtrat.rRowid      = rowid(ctrat)
                ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            .
        end.
        /* Mettre à jour le num. mandant dans UNITE */
        for each unite no-lock
           where unite.nomdt = piNumeroContrat
             and unite.noact = 0:
            create ttUnite.
            assign
                ttUnite.nomdt = unite.nomdt
                ttUnite.noapp = unite.noapp
                ttUnite.noact = unite.noact
                ttUnite.noman = piNouvNumeroRole
                ttUnite.CRUD        = "U"
                ttUnite.rRowid      = rowid(unite)
                ttUnite.dtTimestamp = datetime(unite.dtmsy, unite.hemsy)
            .
        end.
        /* Mettre à jour le num. mandant dans CPUNI */
        for each cpuni no-lock
            where cpuni.nomdt = piNumeroContrat:
            create ttCpuni.
            assign
                ttCpuni.nomdt = cpuni.nomdt
                ttCpuni.noapp = cpuni.noapp
                ttCpuni.nocmp = cpuni.nocmp
                ttCpuni.noord = cpuni.noord
                ttCpuni.noman = piNouvNumeroRole
                ttCpuni.CRUD        = "U"
                ttCpuni.rRowid      = rowid(cpuni)
                ttCpuni.dtTimestamp = datetime(cpuni.dtmsy, cpuni.hemsy)
            .
        end.
        /* Mettre à jour le lien Bail-Mandant */
        for each intnt no-lock
            where intnt.tpidt = gcRolePrincipal
              and intnt.noidt = piAncNumeroRole
              and intnt.tpcon = {&TYPECONTRAT-bail}
              and intnt.nocon >= piNumeroContrat * 100000
              and intnt.nocon <= piNumeroContrat * 100000 + 99999
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon:
            create ttIntnt.
            assign
                ttIntnt.tpcon       = intnt.tpcon
                ttIntnt.nocon       = intnt.nocon
                ttIntnt.tpidt       = intnt.tpidt
                ttIntnt.noidt       = piNouvNumeroRole
                ttIntnt.nbnum       = intnt.nbnum
                ttIntnt.idpre       = intnt.idpre
                ttIntnt.idsui       = intnt.idsui
                ttIntnt.CRUD        = "U"
                ttIntnt.rRowid      = rowid(intnt)
                ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
            .
            /* Bail spécial vacant (propriétaire) */
            if ctrat.ntcon = {&NATURECONTRAT-specialVacant} then do:
                /* changer no tiers */
                for first vb2roles no-lock
                    where vb2roles.tprol = ctrat.tprol
                      and vb2roles.norol = ctrat.norol:
                    create ttRoles.
                    assign
                        ttRoles.tprol       = vb2roles.tprol
                        ttRoles.norol       = vb2roles.norol
                        ttRoles.CRUD        = "U"
                        ttRoles.rRowid      = rowid(vb2roles)
                        ttRoles.dtTimestamp = datetime(vb2roles.dtmsy, vb2roles.hemsy)
                        ttRoles.notie       = viNumeroTiers
                        ttRoles.lbmsy       = "CHPTC"
                    .
                end.
                /* changer nom */
                create ttCtrat.
                assign
                    ttCtrat.tpcon = ctrat.tpcon
                    ttCtrat.nocon = ctrat.nocon
                    ttCtrat.lbnom = vcLibelleIntervenant
                    ttCtrat.lnom2 = vcLibelleNomTiers
                    ttCtrat.lbmsy       = "CHPTC"
                    ttCtrat.CRUD        = "U"
                    ttCtrat.rRowid      = rowid(ctrat)
                    ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
                .
                /* changer adresse */
                for first iLienAdresse no-lock
                    where iLienAdresse.cTypeIdentifiant        = gcRolePrincipal
                      and iLienAdresse.iNumeroIdentifiant      = piNouvNumeroRole
                      and iLienAdresse.cTypeAdresse            = {&TYPEADRESSE-Principale}
                  , first vbiLienAdresse no-lock
                    where vbiLienAdresse.cTypeIdentifiant        = ctrat.tprol
                      and vbiLienAdresse.iNumeroIdentifiant      = ctrat.norol
                      and vbiLienAdresse.cTypeAdresse            = {&TYPEADRESSE-Principale}:
                    create ttILienAdresse.
                    assign
                        ttILienAdresse.cTypeIdentifiant        = vbiLienAdresse.cTypeIdentifiant
                        ttILienAdresse.iNumeroIdentifiant      = vbiLienAdresse.iNumeroIdentifiant
                        ttILienAdresse.cTypeAdresse            = vbiLienAdresse.cTypeAdresse
                        ttILienAdresse.iLienAdresseFournisseur = vbiLienAdresse.iLienAdresseFournisseur
                        ttILienAdresse.iNumeroAdresse          = iLienAdresse.iNumeroAdresse
                        ttILienAdresse.cComplementDestinataire = iLienAdresse.cComplementDestinataire
                        ttILienAdresse.cComplementGeographique = iLienAdresse.cComplementGeographique
                        ttILienAdresse.lbmsy              = "CHPTC"
                        ttILienAdresse.CRUD               = "U"
                        ttILienAdresse.rRowid             = rowid(vbiLienAdresse)
                        ttILienAdresse.dtTimestamp        = datetime(vbiLienAdresse.dtmsy, vbiLienAdresse.hemsy)
                    .
                    /* 0507/0195 - duplication table telephones */
                    if not valid-handle(vhProcFcttelep) then do:
                        run adresse/fcttelep.p persistent set vhProcFcttelep.
                        run getTokenInstance in vhProcFcttelep(mToken:JSessionId).
                    end.
                    run dupliqueTelephones in vhProcFcttelep(gcRolePrincipal, piNouvNumeroRole, vbiLienAdresse.cTypeIdentifiant, vbiLienAdresse.iNumeroIdentifiant).
                end.
            end.
        end.
        /* Ajout 24/11/2000: Mettre à jour le lien Contrat Salarié-Mandant */
        for each intnt no-lock
            where intnt.tpidt = gcRolePrincipal
              and intnt.noidt = piAncNumeroRole
              and intnt.tpcon = {&TYPECONTRAT-Salarie}
              and intnt.nocon >= piNumeroContrat * 100
              and intnt.nocon <= piNumeroContrat * 100 + 99:
            create ttIntnt.
            assign
                ttIntnt.tpcon       = intnt.tpcon
                ttIntnt.nocon       = intnt.nocon
                ttIntnt.tpidt       = intnt.tpidt
                ttIntnt.noidt       = piNouvNumeroRole
                ttIntnt.nbnum       = intnt.nbnum
                ttIntnt.idpre       = intnt.idpre
                ttIntnt.idsui       = intnt.idsui
                ttIntnt.CRUD        = "U"
                ttIntnt.rRowid      = rowid(intnt)
                ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
            .
        end.
        /* "Toper" le nouveau mandant pour renvoi */
        for first tiers no-lock
            where tiers.notie = viNumeroTiers:
            create ttTiers.
            assign
                ttTiers.notie       = tiers.notie
                ttTiers.CRUD        = "U"
                ttTiers.rRowid      = rowid(tiers)
                ttTiers.dtTimestamp = datetime(tiers.dtmsy, tiers.hemsy)
                ttTiers.pgmsy       = "gespcc00.p"
            .
            for first ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = tiers.notie:
                assign
                    viNumeroSiret  = ctanx.nosir
                    viCompteBanque = ctanx.cptbq
                .
            end.
            /* Maj Siret etabl associés */
            for each etabl no-lock
                where etabl.tpcon = pcTypeContrat
                  and etabl.nocon = piNumeroContrat
                  and etabl.tptac = {&TYPETACHE-organismesSociaux}:
                create ttEtabl.
                assign
                    ttEtabl.tpcon       = etabl.tpcon
                    ttEtabl.nocon       = etabl.nocon
                    ttEtabl.tptac       = etabl.tptac
                    ttEtabl.siren       = viNumeroSiret
                    ttEtabl.nonic       = viCompteBanque
                    ttEtabl.pgmsy       = "gespcc00.p"
                    ttEtabl.CRUD        = "U"
                    ttEtabl.rRowid      = rowid(etabl)
                    ttEtabl.dtTimestamp = datetime(etabl.dtmsy, etabl.hemsy)
                .
            end.
        end.

        // Ajout 04/07/2001: Mettre à jour les acomptes et echéancier
        // Ajout 30/07/2002: Mettre à jour les echeancier non comptabilisés
        if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance}
        then for each acpte no-lock
            where acpte.tpcon = pcTypeContrat
              and acpte.nocon = piNumeroContrat
              and acpte.norol = piAncNumeroRole:
            for each aecha no-lock
               where aecha.soc-cd    = integer(mtoken:cRefPrincipale)
                 and aecha.etab-cd   = acpte.nocon
                 and aecha.cpt-cd    = string(acpte.norol, "99999")
                 and aecha.fg-compta = no:
                create ttAecha.
                assign
                    ttAecha.soc-cd   = aecha.soc-cd
                    ttAecha.etab-cd  = aecha.etab-cd
                    ttAecha.cpt-cd   = string(piNouvNumeroRole, "99999")
                    ttAecha.mois-cpt = aecha.mois-cpt
                    ttAecha.daech    = aecha.daech
                    ttAecha.CRUD     = "U"
                    ttAecha.rRowid   = rowid(aecha)
                .
            end.
            create ttAcpte.
            assign
                ttAcpte.norol       = piNouvNumeroRole
                ttAcpte.CRUD        = "U"
                ttAcpte.rRowid      = rowid(acpte)
                ttAcpte.dtTimestamp = datetime(acpte.dtmsy, acpte.hemsy)
            .
        end.

        /* Mettre à jour le type de role et norol dans la table ctrat (acte de propriété: {&TYPECONTRAT-acte2propriete}) si pas de mandat de syndic actif */
        /* Recherche No Immeuble */
        for first intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat:
            assign
                viNumeroImmeuble   = intnt.noidt
                vlMandatCoproActif = no
            .
        end.
        /* Recherche si mandat de copro actif */
        for first intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = viNumeroImmeuble
              and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.dtree = ?:
            vlMandatCoproActif = yes.
        end.

        /* si pas de mandat de copro sur l'immeuble => modif tprol et norol de l'acte de propriété */
        if vlMandatCoproActif = no
        then for each intnt no-lock
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-lot}
          , first vbintnt no-lock
            where vbintnt.tpidt = {&TYPEBIEN-lot}
              and vbintnt.noidt = intnt.noidt
              and vbintnt.tpcon = {&TYPECONTRAT-acte2propriete}
          , first ctrat no-lock
            where ctrat.tpcon = vbintnt.tpcon
              and ctrat.nocon = vbintnt.nocon:
              create ttCtrat.
              assign
                  ttCtrat.tpcon = ctrat.tpcon
                  ttCtrat.nocon = ctrat.nocon
                  ttCtrat.tprol = gcRolePrincipal
                  ttCtrat.norol = piNouvNumeroRole
                  ttCtrat.lbnom = vcLibelleIntervenant
                  ttCtrat.lnom2 = vcLibelleNomTiers
                  ttCtrat.CRUD        = "U"
                  ttCtrat.rRowid      = rowid(ctrat)
                  ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
              .
        end.
        /* Controle sur mode de reglement */
        find first ctanx no-lock
            where ctanx.tpcon = {&TYPECONTRAT-RIB}
              and ctanx.tprol = {&TYPEROLE-tiers}
              and ctanx.Norol = viNumeroTiers
              and ctanx.tpact = "DEFAU" no-error.
        if not available ctanx
        then for first tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-quittancement}
              and tache.notac = 1:
            create ttTache.
            assign
                ttTache.tpcon = tache.tpcon
                ttTache.nocon = tache.nocon
                ttTache.tptac = tache.tptac
                ttTache.notac = tache.notac
                ttTache.cdreg = {&MODEREGLEMENT-cheque}
                ttTache.CRUD        = "U"
                ttTache.rRowid      = rowid(tache)
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            .
        end.
    end.
    lancementPgm("crud/ctrat_CRUD.p"       , "setCtrat"                   , table ttCtrat by-reference).
    lancementPgm("crud/intnt_CRUD.p"       , "setIntnt"                   , table ttIntnt by-reference).
    lancementPgm("crud/unite_CRUD.p"       , "setUnite"                   , table ttUnite by-reference).
    lancementPgm("crud/cpuni_CRUD.p"       , "setCpuni"                   , table ttCpuni by-reference).
    lancementPgm("crud/ietab_CRUD.p"       , "setIetab"                   , table ttIetab by-reference).
    lancementPgm("crud/aecha_CRUD.p"       , "setAecha"                   , table ttAecha by-reference).
    lancementPgm("crud/acpte_CRUD.p"       , "setAcpte"                   , table ttAcpte by-reference).
    lancementPgm("crud/tache_CRUD.p"       , "setTache"                   , table ttTache by-reference).
    lancementPgm("crud/etabl_CRUD.p"       , "setEtabl"                   , table ttEtabl by-reference).
    lancementPgm("crud/roles_CRUD.p"       , "setRoles"                   , table ttRoles by-reference).
    lancementPgm("crud/ilienadresse_CRUD.p", "setILienAdresse"            , table ttILienAdresse by-reference).
    lancementPgm("crud/tiers_CRUD.p"       , "setTiersSansConfirmationMaj", table ttTiers by-reference).
    if valid-handle(vhProcFcttelep) then run destroy in vhProcFcttelep.

end procedure.

procedure nouveauContractant private:
    /*------------------------------------------------------------------------------
    Purpose: creation des informations lie au contractant en creation de contrat (1ere maj du role pricipal)
             on retrouve les maj de fin de creation de contrat (adb/cont/gesctt01.p, adb/lib/l_pecct.p )
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.
    define input parameter piNouvNumeroRole as int64 no-undo.

    define variable vcLibelleNomTiers    as character no-undo.
    define variable vcLibelleIntervenant as character no-undo.
    define variable vhRlctt              as handle    no-undo.

    define buffer rlctt   for rlctt.
    define buffer ctanx   for ctanx.
    define buffer vbroles for roles.

    empty temp-table ttCtrat.
    create ttCtrat.
    assign
        vcLibelleIntervenant = outilFormatage:getNomTiers(gcRolePrincipal, piNouvNumeroRole)              //remplace appel formtie0.p
        vcLibelleNomTiers    = outilFormatage:getCiviliteNomTiers(gcRolePrincipal, piNouvNumeroRole, no)  //remplace appel FormTiea.p
        vcLibelleNomTiers    = entry(1, vcLibelleNomTiers, "|")                                         // ajout SY le 18/08/2009 pour ne pas prendre le C/O qui a été ajouté au formatage
        ttCtrat.tpcon        = ctrat.tpcon
        ttCtrat.nocon        = ctrat.nocon
        ttCtrat.tprol        = gcRolePrincipal
        ttCtrat.norol        = piNouvNumeroRole
        ttCtrat.lbnom        = vcLibelleIntervenant
        ttCtrat.lnom2        = vcLibelleNomTiers
        ttCtrat.CRUD         = "U"
        ttCtrat.rRowid       = rowid(ctrat)
        ttCtrat.dtTimestamp  = datetime(ctrat.dtmsy, ctrat.hemsy)
    .
    lancementPgm("crud/ctrat_CRUD.p", "setCtrat", table ttCtrat by-reference).
    if mError:erreur() then return.

    if can-find(first ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-RIB}
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = roles.notie)
    then do:
        run crud/rlctt_CRUD.p persistent set vhRlctt.
        run getTokenInstance in vhRlctt(mToken:JSessionId).
        find first rlctt no-lock
            where rlctt.tpidt = gcRolePrincipal
              and rlctt.noidt = piNouvNumeroRole
              and rlctt.tpct1 = ctrat.tpcon
              and rlctt.noct1 = ctrat.nocon
              and rlctt.tpct2 = {&TYPECONTRAT-RIB} no-error.
        if not available rlctt
        then for first vbroles no-lock
            where vbroles.tprol = gcRolePrincipal
              and vbroles.norol = piNouvNumeroRole
          , first ctanx no-lock
            where ctanx.tpcon = {&TYPECONTRAT-RIB}
              and ctanx.tprol = {&TYPEROLE-tiers}
              and ctanx.norol = vbroles.notie
              and ctanx.tpact = "DEFAU":
            create ttRlctt.
            assign
                ttRlctt.tpidt = gcRolePrincipal
                ttRlctt.noidt = piNouvNumeroRole
                ttRlctt.tpct1 = ctrat.tpcon
                ttRlctt.noct1 = ctrat.nocon
                ttRlctt.tpct2 = {&TYPECONTRAT-RIB}
                ttRlctt.noct2 = ctanx.nocon
                ttRlctt.lbdiv = ""
                ttRlctt.CRUD  = ""                     // pas d'init du crud, sera mis a jour dans rlctt_CRUD.p/bquRlctt
            .
            run bquRlCtt in vhRlctt(input-output table ttRlctt by-reference).
            run setRlctt in vhRlctt(table ttRlctt by-reference).
        end.
        else run creationCompteBancaire in vhRlctt(rlctt.tpct1, rlctt.noct1, rlctt.tpidt, rlctt.noidt, rlctt.noct2).
        run destroy in vhRlctt.
    end.

end procedure.
