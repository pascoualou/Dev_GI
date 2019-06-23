/*------------------------------------------------------------------------
File        : baremeHonoraire.p
Purpose     :
Author(s)   : DM 2017/10/03
Notes       : à partir de adb/src/tiers/barhon02.p
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2honoraire.i}
{preprocesseur/nature2honoraire.i}
{preprocesseur/listeRubQuit2TVA.i}

using parametre.pclie.parametrageCodeTVA.
using parametre.pclie.parametrageHonoraireLocataire.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{compta/include/tva.i}
{tache/include/paramBaseRubrique.i}
{tache/include/honoraire.i}
{tache/include/baremeHonoraire.i}
{adblib/include/honor.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{application/include/error.i}

function fIsNull returns logical(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.

end function.

function fIsCronEclatEncais return logical(piSoc-cd as integer):
    /*------------------------------------------------------------------------------
    Purpose: Eclatement des encaissements paramétré dans le cron ?
    Notes:
    ------------------------------------------------------------------------------*/
    return can-find(first icron no-lock
                    where icron.soc-cd    = piSoc-cd
                      and icron.type-cron = 2
                      and icron.Code-cron = 3
                      and icron.flag).
end function.
		      
function fHonLoc returns logical private  :
    /*------------------------------------------------------------------------------
    Purpose: retourne vrai param honoraires locataire ouvert
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vlHonoraireLocataire as logical no-undo.
    define variable voParametrageHonoraire as class parametrageHonoraireLocataire no-undo.

    voparametrageHonoraire = new parametrageHonoraireLocataire().
    vlHonoraireLocataire   = voParametrageHonoraire:isActif().
    delete object voparametrageHonoraire.
    return vlHonoraireLocataire.
end function.

function fBaremePlusieursMandat returns logical private (pcTypeHonoraire as character, piCodeHonoraire as integer) :
    /*------------------------------------------------------------------------------
    Purpose: retourne vrai si bareme utilisé par plusieurs mandats
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNbMandat      as integer   no-undo.
    define variable vcTmpBareme     as character no-undo.
    define variable viI1            as integer   no-undo.
    define variable viCodeHonoraire as integer   no-undo.
    define buffer tache for tache.
    define buffer ctrat for ctrat.

    viNbMandat = 0.
    case pcTypeHonoraire:
        when {&TYPEHONORAIRE-gestion}
        then for each tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.tphon = pcTypeHonoraire
          , each ctrat no-lock
            where ctrat.tpcon = tache.tpcon
              and ctrat.nocon = tache.nocon
              and ctrat.dtree = ?:
            do viI1 = 1 to num-entries(tache.lbdiv, separ[1]):
                assign
                    vcTmpBareme     = entry(viI1, tache.lbdiv, separ[1])
                    viCodeHonoraire = integer(entry(1 , vcTmpBareme, separ[2]))
                .
                if viCodeHonoraire = piCodeHonoraire then viNbMandat = viNbMandat + 1.
                if viNbMandat > 1 then return true.
            end.
        end.

        when {&TYPEHONORAIRE-frais-gestion}
        then for each tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.cdreg = pcTypeHonoraire
              and tache.ntreg = STRING(piCodeHonoraire ,"99999")
          , each ctrat no-lock
            where ctrat.tpcon = tache.tpcon
              and ctrat.nocon = tache.nocon
              and ctrat.dtree = ?:
            viNbMandat = viNbMandat + 1.
            if viNbMandat > 1 then return true.
        end.
    end case.
    return viNbMandat > 1.
end function.

function fBaremeTache returns logical private (pcTypeHonoraire  as character, piCodeHonoraire as integer) :
    /*------------------------------------------------------------------------------
    Purpose: retourne vrai si bareme utilisé par une tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viI1             as integer   no-undo.
    define variable vcTmpBareme      as character no-undo.
    define variable viCodeHonoraire  as integer   no-undo.

    define buffer tache for tache.
    define buffer ctrat for ctrat.

    case pcTypeHonoraire:
        when {&TYPEHONORAIRE-gestion}
        then for each tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.tphon = pcTypeHonoraire
          , each ctrat no-lock
            where ctrat.tpcon = tache.tpcon
              and ctrat.nocon = tache.nocon and ctrat.dtree = ?:
            do viI1 = 1 to num-entries(tache.lbdiv, separ[1]):
                assign
                    vcTmpBareme     = entry(viI1, tache.lbdiv, separ[1])
                    viCodeHonoraire = integer(entry(1, vcTmpBareme, separ[2]))
                .
                if viCodeHonoraire = piCodeHonoraire then return true.
            end.
        end.
        when {&TYPEHONORAIRE-frais-gestion}
        then return can-find(first tache no-lock      // TODO  -  WHOLE INEDX
                             where tache.cdreg = pcTypeHonoraire
                               and tache.ntreg = string(piCodeHonoraire, "99999")).

        otherwise return can-find(first tache no-lock      // TODO  -  WHOLE INEDX
                                  where tache.cdhon = string(piCodeHonoraire, "99999")
                                    and tache.tphon = pcTypeHonoraire).
    end case.
    return false.
end function.

function getListeContrat returns character private (pcTypeHonoraire as character) :
    /*------------------------------------------------------------------------------
    Purpose: Retourne la liste des contrats acssociés à un type d'honoraire
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcListeContrat as character no-undo.
    define buffer sys_pg for sys_pg.

    for each sys_pg no-lock
        where sys_pg.tppar = "R_CLH"
          and sys_pg.zone2 = pcTypeHonoraire:
        vcListeContrat = vcListeContrat + "," + sys_pg.zone1.
    end.
    return trim(vcListeContrat, ",").
end function.

procedure getControlebareme:
    /*------------------------------------------------------------------------------
    Purpose: Contrôle 1 barème
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttBaremeHonoraire.
    define input-output parameter table for ttTranche.

    define variable voParametrageHonoraire as class parametrageHonoraireLocataire no-undo.

    voparametrageHonoraire = new parametrageHonoraireLocataire().
    for first ttBaremeHonoraire
        where lookup(ttBaremeHonoraire.CRUD, 'C,U,D') > 0
          and ttBaremeHonoraire.lControle:
        run controleValiditeBareme(voParametrageHonoraire:isActif()).
    end.
    delete object voParametrageHonoraire.
end procedure.

procedure updateBaremeHonoraire:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour des barèmes d'honoraire
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttBaremeHonoraire.
    define input parameter table for ttTranche.

    define variable vlMaj as logical.         /* Pas de no-undo TODO  POURQUOI, PAS D'ACCORD  !!!!*/
    define variable vlSup as logical.         /* Pas de no-undo */
    define variable voParametrageHonoraire as class parametrageHonoraireLocataire no-undo.

    if not can-find(first ttBaremeHonoraire where lookup(ttBaremeHonoraire.CRUD, 'C,U,D') > 0)
    then do:
        mError:createError({&error}, outilTraduction:getLibelle(1000331)). // 1000331 "Aucune modification à enregistrer"
        return.
    end.
    voparametrageHonoraire = new parametrageHonoraireLocataire().

blocTrans:
    do transaction:
        /* Contrôle des lignes modifiées/ajoutées/Supprimées */
        for each ttBaremeHonoraire where lookup(ttBaremeHonoraire.CRUD, 'C,U,D') > 0:
            run controleValiditeBareme(voParametrageHonoraire:isActif()).
            if merror:erreur() then undo blocTrans, leave blocTrans.
        end.

        if can-find(first ttBaremeHonoraire where ttBaremeHonoraire.CRUD = "D") then do:
            run deleteHonor.
            if merror:erreur() then undo blocTrans, leave blocTrans.
            vlsup = true.
        end.
        if can-find(first ttBaremeHonoraire where ttBaremeHonoraire.CRUD = "U") then do:
            run updateHonor.
            if merror:erreur() then undo blocTrans, leave blocTrans.
            vlmaj = true.
        end.
        if can-find(first ttBaremeHonoraire where ttBaremeHonoraire.CRUD = "C") then do:
            run createHonor.
            if merror:erreur() then undo blocTrans, leave blocTrans.
            vlmaj = true.
        end.

        if vlMaj then mError:createError({&info}, 1000254, " "). /* Mise à jour effectuée */
        if vlSup then mError:createError({&info}, 103340).       /* Suppression effectuée */
    end.
    delete object voParametrageHonoraire.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure controleValiditeBareme private:
    /*------------------------------------------------------------------------------
    Purpose: controle un enregistrement ttBaremeHonoraire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter plHonoraireLocataire as logical no-undo.
    define variable viQuestionnaire as integer no-undo.
    define buffer vbttBaremeHonoraire for ttbaremeHonoraire.

    if ttBaremeHonoraire.CRUD = "D" then do: // Question "Voulez-vous supprimer le barème ? posée dans l'IHM
        /* TODO controler mot de passe
        if not lgInitMoPasse then /* NP 0115/0131 */
        do:
            /*--> Demande d'un mot de passe */
            run MotPasse(input 0, input '00002' , output LbTmpPdt).
            /*--> Si mot de passe incorrect, alors pas d'action (quitte la procédure) */
            if LbTmpPdt = "01" then
                return no-apply.
        end.
        */
        if ttBaremeHonoraire.iCodeHonoraire = 0
        or (ttBaremeHonoraire.iCodeHonoraire > 0
          and fBaremeTache(ttBaremeHonoraire.cTypeHonoraire, ttBaremeHonoraire.iCodeHonoraire)
          and not can-find(first vbttBaremeHonoraire
                           where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire // Pour supprimer une nlle valeur saisie pour un barème
                             and vbttBaremeHonoraire.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
                             and vbttBaremeHonoraire.daDateFinApplication >= today
                             and rowid(vbttBaremeHonoraire) <> rowid(ttBaremeHonoraire)))
        then do:
            mError:createError({&error}, substitute(outilTraduction:getLibelle(1000327)
                                                 , ttBaremeHonoraire.cLibelleTypeHonoraire
                                                 , ttBaremeHonoraire.iCodeHonoraire)). // 1000327 "Le barème &1 numéro &2 ne peut être supprimé"
            return.
        end.
    end.
    else do:
        run majChampsCalcules(plHonoraireLocataire).
        if mError:erreur() then return.
        run controleChamps.
        if merror:erreur() then return.
        // --> Si barème Gestion ou Frais de Gestion : Recherche si barème utilisé par plusieurs mandats
        if ttBaremeHonoraire.CRUD = "U"
           and fBaremePlusieursMandat(ttBaremeHonoraire.cTypeHonoraire, ttBaremeHonoraire.iCodeHonoraire)
           and outils:questionnaire(1000336, table ttError by-reference) <= 2 // Confirmez-vous la modification des barèmes utilisés par plusieurs mandat ?"
           then ttBaremeHonoraire.CRUD = 'R'. // Pas modifié
    end.
end procedure.

procedure getBaremeHonoraire:
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des honoraires
    Notes  : service externe (beBaremeHonoraire.cls, tacheHonoraire.p)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeHonoraire   as character no-undo.
    define input  parameter piNumeroHonoraire as integer   no-undo.
    define input  parameter piCodeHonoraire   as integer   no-undo.
    define input  parameter pcTypeContrat     as character no-undo.
    define input  parameter plDateApplication as logical   no-undo.    
    define input  parameter plTranche         as logical   no-undo.
    define output parameter table for ttBaremeHonoraire.
    define output parameter table for ttTranche.

    define variable vcWhereClause 	 as character no-undo.
    define variable vhBuffer      	 as handle    no-undo.
    define variable vhquery       	 as handle    no-undo.
    define variable vhProcIndice         as handle    no-undo.
    define variable vcListeTypeHonoraire as character no-undo.
     
    define buffer sys_pg for sys_pg.

    run chargeLibelle.
    run adblib/indiceRevision_CRUD.p persistent set vhProcIndice.
    run getTokenInstance in vhProcIndice(mToken:JSessionId).

    create buffer vhBuffer for table "honor".
    create query vhquery.
    vhquery:set-buffers(vhBuffer).
    vcWhereClause = "where honor.cdHon <= 10000".

    if pcTypeContrat > "" then do :
        for each sys_pg no-lock
                where sys_pg.tppar = "R_CLH"
                and   sys_pg.zone1 = pcTypeContrat :
            vcListeTypeHonoraire = substitute("&1,&2", vcListeTypeHonoraire,  sys_pg.zone2).
        end.            
        vcListeTypeHonoraire = trim(vcListeTypeHonoraire,",").
    end.            
    if pcTypeHonoraire   > ""    then vcwhereClause = substitute("&1 and honor.tpHon = '&2'", vcWhereClause, pcTypeHonoraire).
    if piNumeroHonoraire > 0     then vcwhereClause = substitute("&1 and honor.nohon = '&2'", vcWhereClause, piNumeroHonoraire).
    if vcListeTypeHonoraire > "" then vcwhereClause = substitute("&1 and lookup(honor.tphon, '&2') > 0", vcWhereClause, vcListeTypeHonoraire).
    if piCodeHonoraire      <> ? then vcwhereClause = substitute("&1 and honor.cdhon = '&2'", vcWhereClause, piCodeHonoraire).
    
    vhquery:query-prepare(substitute('for each honor no-lock &1', vcWhereClause)).
    vhquery:query-open().
boucle:
    repeat:
        vhquery:get-next().
        if vhquery:query-off-end then leave boucle.
        run crettBaremeHonoraire (vhbuffer, vhProcIndice, plTranche).
    end.
    if plDateApplication 
    then for each ttBaremeHonoraire break by ttBaremeHonoraire.cTypeHonoraire by ttBaremeHonoraire.iCodeHonoraire :
            if not last-of(ttBaremeHonoraire.iCodeHonoraire) then delete ttBaremeHonoraire.
    end.        
    run destroy   in vhProcIndice.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure crettBaremeHonoraire private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement bareme honoraire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter phBuffer      as handle  no-undo.
    define input parameter phProcIndice  as handle  no-undo.
    define input parameter plAvecTranche as logical no-undo.

    define variable viCodeSocCAB           as integer   no-undo.
    define variable vcLibelleDernierIndice as character no-undo.
    define variable cListeContrat          as character no-undo.

    define buffer ifdart  for ifdart.
    define buffer ifdfam  for ifdfam.
    define buffer ifdsfam for ifdsfam.
    define buffer trhon   for trhon.
    define buffer lsirv   for lsirv.

    find first ttBaseCalcul where ttBaseCalcul.cCodeBaseCalcul = phbuffer::bshon no-error.
    find first ttTVA where ttTVA.cCodeTVA = phbuffer::cdtva no-error.
    find first lsirv no-lock where lsirv.cdirv = phbuffer::CdiRv no-error.

    /* Génération des Enr. dans la Table Temporaire. */
    create ttBaremeHonoraire.
    outils:copyValidLabeledField(phbuffer, buffer ttbaremehonoraire:handle).
    run getLibelleIndice in phProcIndice(phbuffer::CdiRv, phbuffer::aniRv, phbuffer::noiRv, "c", output vcLibelleDernierIndice).
    assign
        ttBaremeHonoraire.cLibelleTypeHonoraire  = trim(outilTraduction:getLibelleProg("O_TPH", phbuffer::tphon))
        ttBaremeHonoraire.cLibelleNature         = trim(outilTraduction:getLibelleProg("O_NTH", phbuffer::nthon))
        ttBaremeHonoraire.cLibelleBaseCalcul     = (if integer (phbuffer::bshon) = 0 then "-" else if available ttBaseCalcul then ttBaseCalcul.cLibelleCourt else trim(outilTraduction:getLibelleProg("O_BSH", phbuffer::bshon)))
        ttBaremeHonoraire.dTauxMontant           = (if phbuffer::nthon = {&NATUREHONORAIRE-forfaitaire} or phbuffer::nthon = {&NATUREHONORAIRE-forfait-locatif} or phbuffer::bshon = "15010" then phbuffer::mthon else phbuffer::txhon)
        ttBaremeHonoraire.cLibelleTva            = (if available ttTVA then ttTVA.cLibelleTVA  else "-")
        ttBaremeHonoraire.cLibellePresentation   = (if integer(phbuffer::cdtot) = 0 then "-" else trim(outilTraduction:getLibelleParam("TTHON", phbuffer::CdTot)))
        ttBaremeHonoraire.cLibelleHonoraire      = trim(phbuffer::LbHon) // c'est un code pour {&TYPEHONORAIRE-frais-gestion} sinon libellé en clair
        ttBaremeHonoraire.cLibelleIndiceRevision = trim(if available lsirv then lsirv.lbCrt else "")
        ttBaremeHonoraire.cCodeDernierIndice     = substitute("&1-&2-&3",string(phbuffer::cdirv), string(phbuffer::anirv), string(phbuffer::noirv))
        ttBaremeHonoraire.cLibelleDernierIndice  = trim(vcLibelleDernierIndice)
        ttBaremeHonoraire.dforfaitM2             = phbuffer::surfo(1)
        ttBaremeHonoraire.dM2Occupe              = phbuffer::surfo(2)
        ttBaremeHonoraire.dM2Shon                = phbuffer::surfo(3)
        ttBaremeHonoraire.dM2Vacant              = phbuffer::surfo(4)
    .
    run getReferenceCabinet(getlistecontrat(ttBaremeHonoraire.cTypeHonoraire), output viCodeSocCAB).
    for first ifdart no-lock
         where ifdart.soc-cd  = viCodeSocCAB
          and ifdart.art-cle = phbuffer::art-cle:
        ttBaremeHonoraire.cLibelleArticle = ifdart.desig1.              
    end. 
    for first ifdfam no-lock
        where ifdfam.soc-cd  = viCodeSocCAB
          and ifdfam.fam-cle = phbuffer::fam-cle:
        ttBaremeHonoraire.cLibelleFamille = ifdfam.lib.
    end.
    for first ifdsfam no-lock
        where ifdsfam.soc-cd   = viCodeSocCAB
          and ifdsfam.sfam-cle = phbuffer::sfam-cle:
        ttBaremeHonoraire.cLibelleSousFamille = ifdsfam.lib.
    end.
    if plAvecTranche and (phbuffer::tphon = {&TYPEHONORAIRE-travaux} or phbuffer::tphon = {&TYPEHONORAIRE-travaux-urgent})
    then for each trhon no-lock
        where trhon.tphon = phbuffer::tphon
          and trhon.noHon = phbuffer::cdHon : // !!! nohon / cdhon
        create ttTranche.
        outils:copyValidLabeledField(buffer trhon:handle, buffer ttTranche:handle).
    end.
end procedure.

procedure chargeLibelle private:
    /*------------------------------------------------------------------------------
    Purpose: Charge les libellés
    Notes  : Appelé par baremeHonoraire.p
    ------------------------------------------------------------------------------*/
    define variable vhProcBase       as handle    no-undo.
    define variable vhProcTVA        as handle    no-undo.

    define buffer sys_pg for sys_pg.
    define buffer sys_lb for sys_lb.
    
    // bases de calcul 
    run tache/paramBaseRubrique.p persistent set vhProcBase.
    run getTokenInstance in vhProcBase(mToken:JSessionId).
    run getBaseCalcul in vhProcBase("", {&TYPETACHE-Honoraires}, "", output table ttBaseCalcul).
    for each sys_pg where sys_pg.tppar = 'R_TBH' no-lock,
        first sys_lb where sys_lb.nomes = sys_pg.nome1 no-lock:
        create ttBaseCalcul.
        assign
            ttBaseCalcul.cCodeBaseCalcul = sys_pg.zone2
            ttBaseCalcul.cLibelleCourt   = sys_lb.lbmes
            ttBaseCalcul.CRUD            = "R"
            ttBaseCalcul.cLibelleLong    = sys_lb.lbmes
            ttBaseCalcul.cTypeBase       = "GI"
            ttBaseCalcul.cTypeHonoraire  = sys_pg.zone1
            .
    end.
    // TVA
    run compta/outilsTVA.p persistent set vhProcTVA.
    run getTokenInstance in vhProcTVA(mToken:JSessionId).
    run getCodeTVA in vhProcTVA(output table ttTVA).

    run destroy in vhProcBase.
    run destroy in vhProcTVA.
end procedure.

procedure initComboBareme:
    /*------------------------------------------------------------------------------
    Purpose: Charges les combos statiques
    Notes  : service Appelé par baremeHonoraire.p et beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat as character no-undo.
    define output parameter table for ttCombo.
    
    define variable viNumeroItem     as integer   no-undo.
    define variable vhlabelLadb      as handle    no-undo.
    define variable vhTacheHonoraire as handle    no-undo.

    run chargeLibelle.
    empty temp-table ttCombo.

/*
    define variable vcListeInterdite as character no-undo.
    for first pclie no-lock where pclie.tppar = "EDCRG":  // todo   - créer la classe paramétrage edcrg
        if pclie.zon02 <> "00001" then vcListeInterdite = {&NATUREHONORAIRE-forfait-locatif}. // pas de forfait locatif
    end.
*/
    run application/libelle/labelLadb.p persistent set vhlabelLadb.
    run getTokenInstance in vhlabelLadb (mToken:JSessionId).
    run tache/tacheHonoraire.p persistent set vhTacheHonoraire.
    run getTokenInstance in vhTacheHonoraire (mToken:JSessionId).
    
    // run getCombolabel in vhlabelLadb ("CMBTYPEHONORAIRE,CMBNATUREHONORAIRE,CMBINDICEREVISION,CMBPRESENTATIONCOMPTABLE,CMBFRAISGESTION", output table ttcombo).
    run getCombolabel in vhlabelLadb ("CMBNATUREHONORAIRE,CMBINDICEREVISION,CMBPRESENTATIONCOMPTABLE,CMBFRAISGESTION", output table ttcombo).
    // Combo type d'honoraire
    run getComboFiltreHonoraire in vhTacheHonoraire(pcTypeContrat, input-output table ttcombo). 
    // Autres combo
    for last ttCombo:
        viNumeroItem = ttCombo.iSeqId.
    end.
    // base de calcul
    for each ttBaseCalcul by ttBaseCalcul.cTypeHonoraire by ttBaseCalcul.cCodeBaseCalcul:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBBASECALCUL"
            ttCombo.cCode     = ttBaseCalcul.cCodeBaseCalcul
            ttCombo.cLibelle  = ttBaseCalcul.cLibelleCourt
            ttCombo.cParent   = ttBaseCalcul.cTypeHonoraire
        .
    end.
    // TVA
    for each ttTva by ttTva.cCodeTva:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBTVA"
            ttCombo.cCode     = ttTVA.cCodeTva
            ttCombo.cLibelle  = ttTVA.cLibelleTVA
        .
    end.
    run destroy in vhlabelLadb.
    run destroy in vhTacheHonoraire.
end procedure.

procedure getArticle:
    /*------------------------------------------------------------------------------
    Purpose: Charges les combos famille/sous-famille/article
    Notes  : service Appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeHonoraire as character no-undo.
    define output parameter table for ttFamilleArticle.
    define output parameter table for ttSousFamilleArticle.
    define output parameter table for ttArticle.

    define variable viCodeSocCAB as integer no-undo.

    define buffer ifdfam    for ifdfam.
    define buffer ifdsfam   for ifdsfam.
    define buffer ifdlart   for ifdlart.
    define buffer ifdart    for ifdart.
    define buffer vbifdlart for ifdlart.

    run getReferenceCabinet(pcTypeHonoraire, output viCodeSocCAB).
    for each ifdfam no-lock where ifdfam.soc-cd = viCodeSocCAB:
        create ttFamilleArticle.
        outils:copyValidLabeledField(buffer ifdfam:handle, buffer ttFamilleArticle:handle).
        for each ifdsfam no-lock
            where ifdsfam.soc-cd = viCodeSocCAB
              and ifdsfam.sfam-cle >= ''
          , first ifdlart no-lock
            where ifdlart.soc-cd = ifdsfam.soc-cd
              and ifdlart.fam-cle = ifdfam.fam-cle
              and ifdlart.sfam-cle = ifdsfam.sfam-cle:
            create ttSousFamilleArticle.
            outils:copyValidLabeledField(buffer ifdsFam:handle, buffer ttSousFamilleArticle:handle).
            outils:copyValidLabeledField(buffer ifdlart:handle, buffer ttSousFamilleArticle:handle).
            if pcTypeHonoraire <> {&TYPEHONORAIRE-gestion}
            then for each vbifdlart no-lock
                where vbifdlart.soc-cd   = viCodeSocCAB
                  and vbifdlart.fam-cle  = ifdfam.fam-cle
                  and vbifdlart.sfam-cle = ifdsfam.sfam-cle
              , first ifdart no-lock
                where ifdart.soc-cd  = vbifdlart.soc-cd
                  and ifdart.art-cle = vbifdlart.art-cle:
                create ttArticle.
                outils:copyValidLabeledField(buffer ifdart:handle, buffer ttArticle:handle).
                outils:copyValidLabeledField(buffer vbifdlart:handle, buffer ttArticle:handle). // copie des codes familles / sous-famille
            end.
            else for each ifdart no-lock
                where ifdart.soc-cd = viCodeSocCAB
                  and can-find(first ifdartcg no-lock
                               where ifdartcg.soc-cd = ifdart.soc-cd
                                 and ifdartcg.etab-cd = 1
                                 and ifdartcg.soc-dest = integer(mtoken:cRefPrincipale)
                                 and ifdartcg.art-cle = ifdart.art-cle
                                 and ifdartcg.typefac-cle = '1'):
                create ttArticle.
                outils:copyValidLabeledField(buffer ifdlart:handle, buffer ttArticle:handle). // Ordre important -> copie des codes familles / sous-famille
                outils:copyValidLabeledField(buffer ifdart:handle, buffer ttArticle:handle).  // Ordre important -> copie du code article
            end.
        end.
    end.
end procedure.

procedure getReferenceCabinet private:
    /*------------------------------------------------------------------------------
    Purpose: Donne la référence cabinet selon le type de contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcListeContrat as character no-undo.
    define output parameter piCodeSocCab   as integer   no-undo.

    define variable viCodeSocCAB-ger as integer no-undo.
    define variable viCodeSocCAB-cop as integer no-undo.

    define buffer ifdparam for ifdparam.

    for first ifdparam no-lock where ifdparam.soc-dest = integer(mToken:cRefGerance):
        viCodeSocCAB-ger = ifdparam.soc-cd.
    end.
    for first ifdparam no-lock where ifdparam.soc-dest = integer(mToken:cRefCopro):
        viCodeSocCAB-cop = ifdparam.soc-cd.
    end.
    piCodeSocCab = integer(if lookup({&TYPECONTRAT-mandat2Syndic} , pcListeContrat ) > 0 then viCodeSocCAB-cop else viCodeSocCAB-ger).
end procedure.

procedure getListeDernierIndice:
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des derniers indices de révision selon un code indice
    Notes  : service Appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piCodeIndiceRevision as integer no-undo.
    define output parameter table for ttCombo.

    define variable vhProcIndice as handle  no-undo.
    define variable viNumeroItem as integer no-undo.

    define buffer indrv for indrv.

    run adblib/indiceRevision_CRUD.p persistent set vhProcIndice.
    run getTokenInstance in vhProcIndice(mToken:JSessionId).

    /*--> Parcours des périodes de l'indice courant */
    for each indrv no-lock where indrv.cdirv = piCodeIndiceRevision:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBDERNIERINDICEREVISION"
            ttCombo.cCode     = substitute("&1-&2-&3", indrv.cdirv, indrv.anper, indrv.noper)
        .
        run getLibelleIndice in vhProcIndice(indrv.cdirv, indrv.anper, indrv.noper, "c", output ttCombo.cLibelle).
    end.
    run destroy in vhProcIndice.
end procedure.

procedure calculDateFinApplication private:
    /*------------------------------------------------------------------------------
    Purpose: Calcule la date de derniere application et controle les chevauchements
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.

    /* date début ne doit pas chevaucher avec un autre barème */
    for last vbttBaremeHonoraire
        where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
          and vbttBaremeHonoraire.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
          and vbttBaremeHonoraire.CRUD <> "D"
          and vbttBaremeHonoraire.daDateDebutApplication < ttBaremeHonoraire.daDateDebutApplication
          and vbttBaremeHonoraire.daDateFinApplication <> ?
          and vbttBaremeHonoraire.daDateFinApplication > ttBaremeHonoraire.daDateDebutApplication :
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000328), string(vbttBaremeHonoraire.daDateDebutApplication))). // 1000328 0 "La date de début d'application chevauche avec les dates de validité d'un autre barème (&1) !"
        return.
    end.
    /* Mise à jour de la date de fin du barème précédent */
    for last vbttBaremeHonoraire
        where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
          and vbttBaremeHonoraire.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
          and vbttBaremeHonoraire.CRUD <> "D"
          and vbttBaremeHonoraire.daDateDebutApplication < ttBaremeHonoraire.daDateDebutApplication :
        assign
            vbttBaremeHonoraire.daDateFinApplication = ttBaremeHonoraire.daDateDebutApplication - 1
            vbttBaremeHonoraire.CRUD                 = "U"
        .
    end.
    if ttBaremeHonoraire.daDateFinApplication = ? // date début ne doit pas chevaucher avec un autre barème
    then for first vbttBaremeHonoraire
        where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
          and vbttBaremeHonoraire.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
          and vbttBaremeHonoraire.CRUD <> "D"
          and vbttBaremeHonoraire.daDateDebutApplication > ttBaremeHonoraire.daDateDebutApplication:
        mError:createError({&info}, substitute(outilTraduction:getLibelle(1000329), vbttBaremeHonoraire.daDateDebutApplication)). // 1000329 0 "Un autre barème du même type existe avec une date d'application qui commence au &1 ! Dans ce cas la date d'application du barème présent va s'arrêter un jour avant !"
        ttBaremeHonoraire.daDateFinApplication = vbttBaremeHonoraire.daDateDebutApplication - 1.
    end.
end procedure.

procedure controleChamps private:
    /*------------------------------------------------------------------------------
    Purpose:  Validation des modifications de la ligne courante des tranches
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viCodeSocCAB     as integer no-undo.
    define buffer vbttTranche for ttTranche.
    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.
    define buffer ifdlart for ifdlart.

    run getReferenceCabinet(getlistecontrat(ttBaremeHonoraire.cTypeHonoraire), output viCodeSocCAB).
    run getChampsSaisissable(ttBaremeHonoraire.CRUD = "C", ttBaremeHonoraire.cTypeHonoraire, ttBaremeHonoraire.cCodeNature, ttBaremeHonoraire.cCodeBaseCalcul, ttBaremeHonoraire.iCodeHonoraire, output table ttChampsSaisissable).
    // Modification impossible des baremes travaux si dossiers encours liés à ce bareme
    
    if lookup(ttBaremeHonoraire.CRUD,"C,U") > 0 
       and can-find(first vbttBaremeHonoraire 
                    where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
                      and vbttBaremeHonoraire.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
                      and vbttBaremeHonoraire.CRUD <> "D"
                      and vbttBaremeHonoraire.daDateDebutApplication = ttBaremeHonoraire.daDateDebutApplication
                      and rowid(vbttBaremeHonoraire) <> rowid(ttBaremeHonoraire))
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                   ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                   ,ttBaremeHonoraire.iCodeHonoraire
                                                   ,substitute(outilTraduction:getLibelle(1000353),ttBaremeHonoraire.daDateDebutApplication))). // 1000353 Un autre barème existe avec la date d'application &1
                                                   
    if ttBaremeHonoraire.CRUD <> "C" and
       lookup(ttBaremeHonoraire.cTypeHonoraire,substitute("&1,&2",{&TYPEHONORAIRE-travaux-urgent},{&TYPEHONORAIRE-travaux})) > 0
    then for first trdos no-lock where trdos.dtree = ?
                           and trdos.noHon = ttBaremeHonoraire.iNumeroHonoraire :
            mError:createError({&error}, substitute(outilTraduction:getLibelle(1000332) // 1000332 "Barème honoraire &1 numéro &2 utilisé par un dossier travaux non clôturé, modification impossible"
                                                   ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                   ,ttBaremeHonoraire.iCodeHonoraire)).
    end.
    if ttBaremeHonoraire.cCodeTva = ? // La tva est obligatoire
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,outilTraduction:getLibelle(101082))). /* 101082 Le taux de TVA est obligatoire */
    if ttBaremeHonoraire.cLibellePresentation = ? // Présentation comptable obligatoire
    and fIsNull(ttBaremeHonoraire.cCodeNature) = false
    then do:
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                               ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                               ,ttBaremeHonoraire.iCodeHonoraire
                                               ,outilTraduction:getLibelle(1000334))). // 1000334 "Présentation comptable obligatoire"
        return.
    end.

    /* barème gestion : détaillé ou TTC */
    if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion}
    and ttBaremeHonoraire.iCodeHonoraire <> 0
    and ttBaremeHonoraire.cLibellePresentation = "-" then do:
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                               ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                               ,ttBaremeHonoraire.iCodeHonoraire
                                               ,outilTraduction:getLibelle(1000335))). // 1000335 "La présentation comptable doit être détaillée ou TTC"
        return.
    end.

    if fIsNull(ttBaremeHonoraire.cTypeHonoraire)
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,outilTraduction:getLibelle(1000337))). // 1000337 "La saisie du type d'honoraire est obligatoire"
    if fIsNull(ttBaremeHonoraire.cCodeNature)
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,outilTraduction:getLibelle(1000338))). // 1000338 0 "La saisie de la nature d'honoraire est obligatoire"
    for first ttChampsSaisissable where ttChampsSaisissable.lSaisieLibelleBaseCalcul :
        if fIsNull(ttBaremeHonoraire.cCodeBaseCalcul)
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                    ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                    ,ttBaremeHonoraire.iCodeHonoraire
                                                    ,outilTraduction:getLibelle(1000339))). // 1000339 "La saisie de la base d'honoraires est obligatoire"
    end.

    if ttBaremeHonoraire.dTauxMontant = 0.00
    and ttBaremeHonoraire.cCodeNature <> {&NATUREHONORAIRE-gratuit}
    and ttBaremeHonoraire.cCodeNature <> {&NATUREHONORAIRE-assietteM2}
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,outilTraduction:getLibelle(1000340))). // 1000340 "Montant ou taux d'honoraires non-nul obligatoire"
    if ttBaremeHonoraire.cCodeNature = {&NATUREHONORAIRE-assietteM2}
    and ttBaremeHonoraire.dforfaitM2 = 0
    and ttBaremeHonoraire.dM2Occupe  = 0
    and ttBaremeHonoraire.dM2Shon    = 0
    and ttBaremeHonoraire.dM2Vacant  = 0
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,outilTraduction:getLibelle(1000351))). // 1000351 La saisie des forfaits au m² est obligatoire
    // honoraires sur encaissement autres que Total impossible si le  paramétrage déclaration de TVA non ouvert
    // Fiche 0113/0191 : ce n'est pas la déclaration de TVA qui compte mais il faut que l'éclatement des encaissement soit activé dans le CRON
    if ttBaremeHonoraire.cCodeNature = {&NATUREHONORAIRE-encaissement} /* Encaissement */
    and ttBaremeHonoraire.cCodeBaseCalcul <> {&baseHonoraire-ttc}      /* Total */
    and not fIsCronEclatEncais (integer(mtoken:cRefGerance))
    and (integer(mtoken:cRefGerance) <> 6505 and integer(mtoken:cRefGerance) <> 6506) // Sauf pour 06505 et 06506
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,outilTraduction:getLibelle(107376))). // "Sans le paramétrage <Eclatement des encaissements> dans les traitements planifiés, les honoraires sur Encaissement doivent porter sur le Total.%SVeuillez contacter la Gestion Intégrale pour activer ce traitement." /*Lib(107376)*/
    /* Le 08/04/2008 - Fiche 0408/0034 */
    /* base   15004 Total HT interdit si "Quittancement"  */
    /*        15007 Loyer+charges HT interdit si encaissemt */
    if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion}
    or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-fact-cab-locataire}
    then do:
        /* Quittancement */
        if ttBaremeHonoraire.cCodeNature = {&NATUREHONORAIRE-quittancement} and ttBaremeHonoraire.cCodeBaseCalcul = {&baseHonoraire-hht}
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                    ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                    ,ttBaremeHonoraire.iCodeHonoraire
                                                    ,substitute(outilTraduction:getLibelle(1000341)
                                                              , outilTraduction:getLibelleProg("O_BSH"
                                                                                              , ttBaremeHonoraire.cCodeBaseCalcul)))). // 1000341 "La base de calcul &1 est réservé au calcul sur Encaissement."
        /* Encaissement */
        if ttBaremeHonoraire.cCodeNature = {&NATUREHONORAIRE-encaissement} and ttBaremeHonoraire.cCodeBaseCalcul = "15007"
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                    ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                    ,ttBaremeHonoraire.iCodeHonoraire
                                                    ,substitute(outilTraduction:getLibelle(1000342)
                                                               ,outilTraduction:getLibelleProg("O_BSH"
                                                                                               ,ttBaremeHonoraire.cCodeBaseCalcul)))). // 1000342 "La base de calcul &1 est réservé au calcul sur Encaissement."

    end.

    /* Validation des dates de début et de fin d'application */
    if ttBaremeHonoraire.daDateDebutApplication = ?
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,substitute(outilTraduction:getLibelle(104869)))).
    else if can-find(first vbttBaremeHonoraire where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire // date début ne doit pas chevaucher avec un autre barème
                                                and vbttBaremeHonoraire.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
                                                and vbttBaremeHonoraire.CRUD <> "D"
                                                and vbttBaremeHonoraire.daDateDebutApplication < ttBaremeHonoraire.daDateDebutApplication
                                                and (vbttBaremeHonoraire.daDateFinApplication <> ? and vbttBaremeHonoraire.daDateFinApplication > ttBaremeHonoraire.daDateDebutApplication))
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,substitute(outilTraduction:getLibelle(1000343)))).   // 1000343 "La date de début d'application chevauche avec les dates de validité d'un autre barème"
    if ttBaremeHonoraire.daDateFinApplication <> ?
    then do:
        // ça doit jamais arriver mais on fait le test quand-même
        if ttBaremeHonoraire.daDateFinApplication < ttBaremeHonoraire.daDateDebutApplication
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                    ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                    ,ttBaremeHonoraire.iCodeHonoraire
                                                    ,substitute(outilTraduction:getLibelle(101797)))).
        // date début ne doit pas chevaucher avec un autre barème
        if can-find(first vbttBaremeHonoraire where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
                                               and vbttBaremeHonoraire.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
                                               and vbttBaremeHonoraire.CRUD <> "D"
                                               and vbttBaremeHonoraire.daDateDebutApplication < ttBaremeHonoraire.daDateFinApplication
                                               and (vbttBaremeHonoraire.daDateFinApplication <> ? and vbttBaremeHonoraire.daDateFinApplication > ttBaremeHonoraire.daDateFinApplication))
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                    ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                    ,ttBaremeHonoraire.iCodeHonoraire
                                                    ,substitute(outilTraduction:getLibelle(1000344)))). // 1000344 "La date de fin d'application chevauche avec les dates de validité d'un autre barème"
    end.
    // Validation des tranches si tranches il doit y avoir
    if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux}
    or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux-urgent}
    then do:
        /* Tranches obligatoires? */
        if can-find(first vbttTranche
            where vbttTranche.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
              and vbttTranche.iNumeroHonoraire = ttBaremeHonoraire.iCodeHonoraire
              and vbttTranche.CRUD <> "D")
        then for each vbttTranche
            where vbttTranche.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
              and vbttTranche.iNumeroHonoraire = ttBaremeHonoraire.iCodeHonoraire
              and vbttTranche.CRUD <> "D":
            run controleTranche(rowid(vbttTranche)).
        end.
    end.

    /* Famille/Ss-famille/Article Obligatoires pour les barèmes facturation cabinet */
    if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-fact-cab-locataire}
    or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-fact-cab-proprietaire}
    or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-fact-cab-copro}
    or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion-UL}
    or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-frais-gest-UL}
    then do:
        if fIsNull(ttBaremeHonoraire.cCodeArticle)
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                   ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                   ,ttBaremeHonoraire.iCodeHonoraire
                                                   ,substitute(outilTraduction:getLibelle(107787)))).
        if fIsNull(ttBaremeHonoraire.cCodeFamille)
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                   ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                   ,ttBaremeHonoraire.iCodeHonoraire
                                                   ,substitute(outilTraduction:getLibelle(107785)))).
        if fIsNull(ttBaremeHonoraire.cCodeSousFamille)
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                    ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                    ,ttBaremeHonoraire.iCodeHonoraire
                                                    ,substitute(outilTraduction:getLibelle(107786)))).
        /* controle de cohérence déplacé pour les barèmes facturation cabinet uniquement */
        /* Controle cohérence article-(famille/sous-famille) */
        if not can-find(first ifdlart no-lock
            where ifdlart.soc-cd   = viCodeSocCAB
              and ifdlart.fam-cle  = ttBaremeHonoraire.cCodeFamille
              and ifdlart.sfam-cle = ttBaremeHonoraire.cCodeSousFamille
              and ifdlart.art-cle  = ttBaremeHonoraire.cCodeArticle)
        then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                    ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                    ,ttBaremeHonoraire.iCodeHonoraire
                                                    ,substitute(outilTraduction:getLibelle(1000345)))). // 1000345 "Ce code article est inconnu pour cette Famille/Sous-famille"
    end.

    // Normalement cela ne devait etre obligatoire que pour les frais de gestion !?!?
    if fIsNull(ttBaremeHonoraire.cLibelleHonoraire)
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,substitute(outilTraduction:getLibelle(1000352)))). // 1000352 Le libellé du barème est obligatoire
    /* Date de révision oblibatoire si indice renseigné */
    if  not fIsNull(ttBaremeHonoraire.cCodeDernierIndice)
        and ttBaremeHonoraire.cCodeDernierIndice <> "0-0-0"
        and ttBaremeHonoraire.daDateRevision = ?
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                ,ttBaremeHonoraire.iCodeHonoraire
                                                ,substitute(outilTraduction:getLibelle(1000346)))). // 1000346 "La date de révision n'est pas renseignée""
end procedure.

procedure majChampsCalcules private:
    /*------------------------------------------------------------------------------
    Purpose: Forçage des champs selon type et nature d'honoraire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter plHonoraireLocataire as logical no-undo.

    /*--> Changement du format du champ taux ou montant */
    /* cas "forfaitaire" */

    if ttBaremeHonoraire.cCodeNature <> {&NATUREHONORAIRE-forfaitaire}
    and ttBaremeHonoraire.cCodeNature <> {&NATUREHONORAIRE-forfait-locatif}
    and ttBaremeHonoraire.cCodeBaseCalcul <> "15010"
    and ttBaremeHonoraire.dTauxMontant >= 100
    then ttBaremeHonoraire.dTauxMontant = 0.

    if ttBaremeHonoraire.cCodeNature = {&NATUREHONORAIRE-gratuit}
    then assign
        ttBaremeHonoraire.cCodeBaseCalcul      = "0"
        ttBaremeHonoraire.cLibelleBaseCalcul   = "-"
        ttBaremeHonoraire.dTauxMontant         = 0.00
        ttBaremeHonoraire.cLibellePresentation = "-"
        ttBaremeHonoraire.cCodePresentation    = "0"
        ttBaremeHonoraire.cCodeTva             = "0"
        ttBaremeHonoraire.cLibelleTva          = "-"
    .
    if ttBaremeHonoraire.cTypeHonoraire <> {&TYPEHONORAIRE-frais-gestion} /* frais de gestion */
    then do:
        if ttBaremeHonoraire.cCodeNature = {&NATUREHONORAIRE-assietteM2} /* Assiette M² */
        then ttBaremeHonoraire.dTauxMontant = 0.
        /*--> Presentation comptable = détaillé + insensitif si hono = travaux generaux, spéciaux ou Syndic */
        if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux-generaux}
        or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux-speciaux}
        or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux-syndic}
        or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux}
        or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux-urgent}
        then assign
            ttBaremeHonoraire.cCodePresentation = "00001"
            ttBaremeHonoraire.cLibellePresentation = outilTraduction:getLibelleParam("TTHON", ttBaremeHonoraire.cCodePresentation)
        .
    end.

    /* % affectation propriétaire : gestion et facturation cabinet locataire uniquement */
    if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion}
    then if ttBaremeHonoraire.cCodeNature = {&NATUREHONORAIRE-forfait-locatif}             /* Forfait Locatif -> affectation proprietaire nulle et non modifiable */
            then ttBaremeHonoraire.dPourcAffProp = 0.
            else if not plHonoraireLocataire
                    then ttBaremeHonoraire.dPourcAffProp = 100. /* param honoraires locataire non ouvert => affectation propriétaire = 100% non modifiable */

    /* affectation du montant des honoraires si tranches d'honoraires */
    if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux}
    or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-travaux-urgent}
    then do:
        find first ttTranche
            where ttTranche.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
              and ttTranche.iNumeroHonoraire = ttBaremeHonoraire.iCodeHonoraire
              and ttTranche.CRUD <> "D" no-error.
        if available ttTranche
        then ttBaremeHonoraire.dTauxMontant = ttTranche.dMontant. // RAPPEL: ttBaremeHonoraire.dTauxMontant sert à stocker un taux (honor.txHon) ou un montant (honor.mtHon) selon le type d'honoraires */
        else ttBaremeHonoraire.dTauxMontant = 0.00.
    end.

    if ttBaremeHonoraire.daDateDebutApplication = ?
    then mError:createError({&error}, substitute(outilTraduction:getLibelle(1000330), ttBaremeHonoraire.cLibelleTypeHonoraire, ttBaremeHonoraire.iCodeHonoraire)). // 1000330 "Barème &1 numéro &2 - La date de début est obligatoire"
    else if ttBaremeHonoraire.CRUD = "C"
         then run calculDateFinApplication.
end procedure.

procedure deleteHonor private:
    /*------------------------------------------------------------------------------
    Purpose:  Suppression dans la base d'un bareme d'honoraires
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcHonor as handle no-undo.

    run adblib/honor_CRUD.p persistent set vhProcHonor.
    run getTokenInstance in vhProcHonor(mToken:JSessionId).
    empty temp-table ttHonor.
    for each ttBaremeHonoraire where ttBaremeHonoraire.CRUD = "D":
        create ttHonor.
        outils:copyValidLabeledField(buffer ttHonor:handle, buffer ttbaremehonoraire:handle, "R", mtoken:cUser).
        run setttHonor.
        run majTranche(buffer ttHonor). // déchargement des tranches d'honoraire
    end.
    run setHonor in vhProcHonor(table ttHonor by-reference).
    run destroy in vhProcHonor.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure setttHonor private:
    /*------------------------------------------------------------------------------
    Purpose:  Assignation de tthonor
    Notes  :
    ------------------------------------------------------------------------------*/
    assign
        ttHonor.dtTimestamp = ttBaremeHonoraire.dtTimestamp
        ttHonor.CRUD        = ttBaremeHonoraire.CRUD
        ttHonor.rRowid      = ttBaremeHonoraire.rRowid
        ttHonor.dtrev       = (if ttBaremeHonoraire.daDateRevision = ? then 01/01/0001 else ttBaremeHonoraire.daDateRevision)
        tthonor.anIrv       = (if num-entries(ttBaremeHonoraire.cCodeDernierIndice,"-") >= 3 then integer(entry(2,ttBaremeHonoraire.cCodeDernierIndice, "-")) else 0)
        tthonor.noIrv       = (if num-entries(ttBaremeHonoraire.cCodeDernierIndice,"-") >= 3 then integer(entry(3,ttBaremeHonoraire.cCodeDernierIndice, "-")) else 0)
        ttHonor.dtfin       = (if ttBaremeHonoraire.daDateFinApplication = ? then 01/01/0001 else ttBaremeHonoraire.daDateFinApplication)
        tthonor.txhon       = (if lookup(ttHonor.ntHon, substitute("&1,&2",{&NATUREHONORAIRE-forfaitaire},{&NATUREHONORAIRE-forfait-locatif})) > 0 or ttHonor.bshon = "15010" then 0 else ttBaremeHonoraire.dTauxMontant)
        tthonor.mthon       = (if lookup(ttHonor.ntHon, substitute("&1,&2",{&NATUREHONORAIRE-forfaitaire},{&NATUREHONORAIRE-forfait-locatif})) > 0 or ttHonor.bshon = "15010" then ttBaremeHonoraire.dTauxMontant else 0)
        tthonor.surfo[1]    = (if ttBaremeHonoraire.dforfaitM2 <> ? then ttBaremeHonoraire.dforfaitM2 else tthonor.surfo[1])
        tthonor.surfo[2]    = (if ttBaremeHonoraire.dM2Occupe  <> ? then ttBaremeHonoraire.dM2Occupe  else tthonor.surfo[2])
        tthonor.surfo[3]    = (if ttBaremeHonoraire.dM2Shon    <> ? then ttBaremeHonoraire.dM2Shon    else tthonor.surfo[3])
        tthonor.surfo[4]    = (if ttBaremeHonoraire.dM2Vacant  <> ? then ttBaremeHonoraire.dM2Vacant  else tthonor.surfo[4])
        tthonor.fguti       = false
        tthonor.tpcon       = ""
        tthonor.nocon       = 0
        tthonor.mtmin       = 0
        tthonor.fgrev       = (ttHonor.dtrev <> ?)
    .
end procedure.

procedure updateHonor private:
    /*------------------------------------------------------------------------------
    Purpose:  Modification dans la base d'un bareme d'honoraires
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcHonor as handle no-undo.
    define buffer honor for honor.

    run adblib/honor_CRUD.p persistent set vhProcHonor.
    run getTokenInstance in vhProcHonor(mToken:JSessionId).
    empty temp-table ttHonor.
    for each ttBaremeHonoraire where ttBaremeHonoraire.CRUD = "U"
      , first honor no-lock
        where honor.nohon = ttBaremeHonoraire.iNumeroHonoraire:
        create ttHonor.
        outils:copyValidLabeledField(buffer ttHonor:handle, buffer ttbaremehonoraire:handle, "R", mtoken:cUser).
        run setttHonor.
        ttHonor.dtdeb = ttBaremeHonoraire.daDateDebutApplication.
        run majTranche(buffer ttHonor). // déchargement des tranches d'honoraire
    end.
    run setHonor in vhProcHonor(table ttHonor by-reference). /* Modification enregistrement de honor */
    run destroy in vhProcHonor.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure createHonor private:
    /*------------------------------------------------------------------------------
    Purpose:  Creation d'un barème dans la base d'un bareme d'honoraires
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcHonor as handle no-undo.
    define variable viCodeHonoraire as integer no-undo.
    define variable viNumeroHonoraire as integer no-undo.

    run adblib/honor_CRUD.p persistent set vhProcHonor.
    run getTokenInstance in vhProcHonor(mToken:JSessionId).

    empty temp-table ttHonor.
    for each ttBaremeHonoraire where ttBaremeHonoraire.CRUD = "C" :
        create ttHonor.
        outils:copyValidLabeledField(buffer ttHonor:handle, buffer ttbaremehonoraire:handle, "R", mtoken:cUser).
        run setttHonor.
        run NxtHonor in vhProcHonor(ttHonor.tphon, output viCodeHonoraire, output viNumeroHonoraire).
        assign  
            ttHonor.dtdeb = (if ttBaremeHonoraire.daDateDebutApplication = ? then 01/01/0001 else ttBaremeHonoraire.daDateDebutApplication)
            tthonor.cdhon = viCodeHonoraire when ttBaremeHonoraire.lNouvelleValeur <> true
            ttHonor.nohon = viNumeroHonoraire
        .
        run majTranche(buffer ttHonor). // déchargement des tranches d'honoraire
    end.
    run setHonor in vhProcHonor(table ttHonor by-reference). // Création enregistrement de honor
    run destroy in vhProcHonor.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure controleTranche private:
    /*------------------------------------------------------------------------------
    Purpose:  controle de la validité de la tranche en cours
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter prRowidTranche as rowid no-undo.

    define variable vdMaximumPrecedent  as decimal no-undo.

    define buffer vbttTranche  for ttTranche.
    define buffer vbttTranche2 for ttTranche.
    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.

    find first vbttTranche where rowid(vbttTranche) = prRowidTranche no-error.
    if not available vbttTranche
    then do:
       mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                              ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                              ,ttBaremeHonoraire.iCodeHonoraire
                                              ,substitute(outilTraduction:getLibelle(1000348)))).   // 1000343 "Tranche d'honoraires non trouvée"
        return.
    end.
    find first vbttBaremeHonoraire
        where vbttBaremeHonoraire.cTypeHonoraire = vbttTranche.cTypeHonoraire
          and vbttBaremeHonoraire.iCodeHonoraire = vbttTranche.iNumeroHonoraire
          and vbttBaremeHonoraire.CRUD <> "D" no-error.
    if not available vbttBaremeHonoraire
    then do:
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000349) // 1000349 "Barème non trouvé pour la tranche de type &1 numéro de barème &2"
                                               ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                               ,ttBaremeHonoraire.iCodeHonoraire)).
        return.
    end.

    /* Tranche maximum doit être > tranche minimum */
    if vbttTranche.dMaximum <> 0
    and vbttTranche.dMaximum <= vbttTranche.dMinimum
    then do:
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                               ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                               ,ttBaremeHonoraire.iCodeHonoraire
                                               ,substitute(outilTraduction:getLibelle(1000348)))).   // 1000343 "Tranche d'honoraires non trouvée"
        return.
    end.
    if vbttTranche.dMinimum  >= 1000000000 then
    do:
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                   ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                   ,ttBaremeHonoraire.iCodeHonoraire
                                                   ,substitute(outilTraduction:getLibelle(1000350)))).   // 1000350 "Veuillez baisser la borne maximum de la précédente tranche"
        return.
    end.
    /* Vérifier qu'il n'y a pas de tranches qui se chevauchent */
    for each vbttTranche2
        where vbttTranche2.cTypeHonoraire = vbttTranche.cTypeHonoraire
          and vbttTranche2.iNumeroHonoraire = vbttTranche.iNumeroHonoraire
          and vbttTranche2.CRUD <> "D"
        by vbttTranche2.cTypeHonoraire
        by vbttTranche2.iNumeroHonoraire
        by vbttTranche2.dMinimum:

        /* tranches inversées ou tranches se chevauchent */
        if (vdMaximumPrecedent   <> 0 and vbttTranche2.dMinimum < vdMaximumPrecedent)
        or (vbttTranche2.dMaximum <> 0 and vbttTranche2.dMinimum > vbttTranche2.dMaximum)
        then do:
            mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                   ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                   ,ttBaremeHonoraire.iCodeHonoraire
                                                   ,outilTraduction:getLibelle(110083))). // Incohérence(s) détectée(s) dans les tranches d'honoraire
            return.
        end.
        vdMaximumPrecedent = vbttTranche2.dMaximum.
    end.

    for each vbttTranche2
        where vbttTranche2.cTypeHonoraire = vbttTranche.cTypeHonoraire
          and vbttTranche2.iNumeroHonoraire = vbttTranche.iNumeroHonoraire
          and vbttTranche2.CRUD <> "D"
        by vbttTranche2.cTypeHonoraire
        by vbttTranche2.iNumeroHonoraire
        by vbttTranche2.dMinimum:
        /* gestion du format des tranches */
        if vbttBaremeHonoraire.cCodeNature = {&NATUREHONORAIRE-taux} /* Taux */
        and vbttTranche2.dMontant > 100
        then do:
            mError:createError({&error}, substitute(outilTraduction:getLibelle(1000333) // 1000333 "Barème honoraire &1 numéro &2 &3 &4"
                                                   ,ttBaremeHonoraire.cLibelleTypeHonoraire
                                                   ,ttBaremeHonoraire.iCodeHonoraire
                                                   ,substitute(outilTraduction:getLibelle(110054),string(vbttTranche2.dMontant) + "% > 100%"))). // 110054 Le taux d'honoraire est invalide (%1)
            return.
        end.
    end.
end procedure.

procedure majTranche private:
  /*------------------------------------------------------------------------------
    Purpose:  Mise à jour des tranches de la ligne de barème
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttHonor for ttHonor.

    define variable vdaCsyUse       as date      no-undo.
    define variable viCsyUse        as integer   no-undo.
    define variable vcCsyUse        as character no-undo.
    define variable viNumeroTranche as integer   no-undo.

    define buffer trhon       for trhon.
    define buffer vbttTranche for ttTranche.

blocTrans :
    do transaction:
        /* annule et remplace */
        for each trhon exclusive-lock
            where trhon.tphon = ttBaremeHonoraire.cTypeHonoraire
              and trhon.noHon = ttBaremeHonoraire.iCodeHonoraire:
            assign // sauvegarder les infos de création
               vdaCsyUse = trhon.dtcsy
               viCsyUse  = trhon.hecsy
               vcCsyUse  = trhon.cdcsy
            .
            delete trhon.
        end.
        for each vbttTranche
            where vbttTranche.cTypeHonoraire   = ttBaremeHonoraire.cTypeHonoraire
              and vbttTranche.iNumeroHonoraire = ttBaremeHonoraire.iCodeHonoraire // Attention -> iNumeroHonoraire = iCodeHonoraire !!
            by vbttTranche.cTypeHonoraire
            by vbttTranche.iNumeroHonoraire
            by vbttTranche.dMinimum:
            create trhon.
            if not outils:copyValidLabeledField(buffer trhon:handle, buffer vbttTranche:handle, "C", mtoken:cUser) then undo blocTrans, leave blocTrans.
            assign
                viNumeroTranche = viNumeroTranche + 1
                trhon.notrc     = viNumeroTranche
                trhon.nohon     = tthonor.cdhon // Attention -> trhon.nohon = tthonor.cdhon  !!
                trhon.fgtau     = (ttBaremeHonoraire.cCodeNature <> {&NATUREHONORAIRE-forfaitaire})
                trhon.dtcsy     = vdaCsyUse when vdaCsyUse <> ?
                trhon.hecsy     = viCsyUse when viCsyUse > 0
                trhon.cdcsy     = vcCsyUse when vcCsyUse > ""
            .
        end.
    end.
end procedure.

procedure getChampsSaisissable:
  /*------------------------------------------------------------------------------
    Purpose:  Champs saisissables saisissables selon contexte
    Notes  :  service Appelé par beMandatGerance.cls, et en interne par controleChamps
    ------------------------------------------------------------------------------*/
    define input parameter  plCreation       as logical   no-undo.
    define input parameter  pcTypeHonoraire  as character no-undo.
    define input parameter  pcCodeNature     as character no-undo.
    define input parameter  pcCodeBaseCalcul as character no-undo.
    define input parameter  piCodeHonoraire  as integer   no-undo.
    define output parameter table for ttChampsSaisissable.

    define variable vlNonGer   as logical   no-undo.
    define variable viNbMdtTrv as integer   no-undo.
    define variable vcLsMdtUse as character no-undo.
    define variable voParametrageHonoraire as class parametrageHonoraireLocataire no-undo.

    run getMandatBareme(pcTypeHonoraire, piCodeHonoraire , output vlNonGer, output viNbMdtTrv, output vcLsMdtUse).
    empty temp-table ttChampsSaisissable.
    create ttChampsSaisissable.
    assign
        voparametrageHonoraire = new parametrageHonoraireLocataire()
        ttChampsSaisissable.lSaisieLibelleTypeHonoraire  = (plCreation = true)
        ttChampsSaisissable.lSaisieLibelleNature         = (pcTypeHonoraire <> {&TYPEHONORAIRE-agence})
        ttChampsSaisissable.lSaisieLibelleBaseCalcul     = if lookup(pcCodeNature, substitute("&1,&2", {&NATUREHONORAIRE-gratuit}, {&NATUREHONORAIRE-assietteM2})) > 0
                                                           then false
                                                           else if pcTypeHonoraire = {&TYPEHONORAIRE-agence}
                                                                or pcTypeHonoraire = {&TYPEHONORAIRE-gestion-UL}
                                                                or pcTypeHonoraire = {&TYPEHONORAIRE-frais-gest-UL}
                                                                then false
                                                                else if lookup(pcCodeNature, "14002,14009") > 0
                                                                     then lookup(pcTypeHonoraire, substitute("&1,&2", {&TYPEHONORAIRE-travaux}, {&TYPEHONORAIRE-travaux-urgent})) > 0
                                                                     else true
        ttChampsSaisissable.lSaisieTauxMontant           =     lookup(pcCodeNature   , substitute("&1,&2", {&NATUREHONORAIRE-gratuit}, {&NATUREHONORAIRE-assietteM2})) = 0
                                                           and lookup(pcTypeHonoraire, substitute("&1,&2", {&TYPEHONORAIRE-travaux}  , {&TYPEHONORAIRE-travaux-urgent})) = 0
        ttChampsSaisissable.lSaisieLibelleTva            =     lookup(pcCodeNature, {&NATUREHONORAIRE-gratuit}) = 0
                                                           and lookup(pcTypeHonoraire, {&TYPEHONORAIRE-agence}) = 0 /* Frais d'agence */
        ttChampsSaisissable.lSaisiePourcAffProp          = if lookup(pcTypeHonoraire, "13000,13030") > 0
                                                           then if pcTypeHonoraire = {&TYPEHONORAIRE-fact-cab-locataire}
                                                                then true
                                                                else if pcCodeNature = {&NATUREHONORAIRE-forfait-locatif}
                                                                     then false
                                                                     else voParametrageHonoraire:isActif() /* param honoraires locataire non ouvert => affectation propriétaire = 100% non modifiable */
                                                           else false
        ttChampsSaisissable.lSaisieLibellePresentation   = if pcTypeHonoraire = {&TYPEHONORAIRE-frais-gestion} /* Frais de gestion */
                                                           then false
                                                           else if pcCodeNature = {&NATUREHONORAIRE-gratuit} /* Gratuit */
                                                                then false
                                                                else (lookup(pcTypeHonoraire, substitute("&1,&2,&3,&4,&5",
                                                                                                       {&TYPEHONORAIRE-travaux-generaux},
                                                                                                       {&TYPEHONORAIRE-travaux-speciaux},
                                                                                                       {&TYPEHONORAIRE-travaux-syndic},
                                                                                                       {&TYPEHONORAIRE-travaux},
                                                                                                       {&TYPEHONORAIRE-travaux-urgent})) = 0)
        ttChampsSaisissable.lSaisieLibelleFamille        = lookup(pcTypeHonoraire, substitute("&1,&2,&3,&4,&5,&6"
                                                                      ,{&TYPEHONORAIRE-gestion}
                                                                      ,{&TYPEHONORAIRE-gestion-UL}
                                                                      ,{&TYPEHONORAIRE-frais-gest-UL}
                                                                      ,{&TYPEHONORAIRE-fact-cab-locataire}
                                                                      ,{&TYPEHONORAIRE-fact-cab-proprietaire}
                                                                      ,{&TYPEHONORAIRE-fact-cab-copro})) > 0
        ttChampsSaisissable.lSaisieLibelleSousFamille    = ttChampsSaisissable.lSaisieLibelleFamille
        ttChampsSaisissable.lSaisieCodeArticle           = ttChampsSaisissable.lSaisieLibelleFamille
        ttChampsSaisissable.lSaisieLibelleIndiceRevision = if lookup(pcCodeNature, substitute("&1,&2",{&NATUREHONORAIRE-forfaitaire},{&NATUREHONORAIRE-forfait-locatif})) > 0
                                                          and lookup(pcTypeHonoraire, substitute("&1,&2",{&TYPEHONORAIRE-travaux},{&TYPEHONORAIRE-travaux-urgent})) = 0
                                                          then true
                                                          else (pcCodeBaseCalcul = "15010")
        ttChampsSaisissable.lSaisieLibelleDernierIndice  = ttChampsSaisissable.lSaisieLibelleIndiceRevision
        ttChampsSaisissable.lSaisieDateRevision          = ttChampsSaisissable.lSaisieLibelleIndiceRevision
        ttChampsSaisissable.lSaisieDateDebutApplication  = (plCreation or (vlNonGer = false and vcLsMdtUse = "")) /* Modifiable si barème non rattaché à un mandat */
        ttChampsSaisissable.lSaisieforfaitM2             = (pcTypeHonoraire = {&TYPEHONORAIRE-gestion} and pcCodeNature = {&NATUREHONORAIRE-assietteM2})
        ttChampsSaisissable.lSaisieM2Occupe              = ttChampsSaisissable.lSaisieforfaitM2
        ttChampsSaisissable.lSaisieM2Shon                = ttChampsSaisissable.lSaisieforfaitM2
        ttChampsSaisissable.lSaisieM2Vacant              = ttChampsSaisissable.lSaisieforfaitM2
    .
    delete object voParametrageHonoraire.
end procedure.

procedure initBareme:
  /*------------------------------------------------------------------------------
    Purpose: Valeurs par défaut selon le type de barème
    Notes  : service Appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeHonoraire as character no-undo.
    define output parameter table for ttBaremeHonoraire.

    define variable voParametrageTVA as class parametrageCodeTVA no-undo.
    define variable viNbParTrv       as integer   no-undo.
    define variable vcBsHonUse       as character no-undo.

    define buffer sys_pg for sys_pg.

    empty temp-table ttBaremeHonoraire.
    create ttBaremeHonoraire.
    if fisNull(pcTypeHonoraire) then ttBaremehonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion}.
    /* Creation d'un nouvelle ligne d'honoraire */
    assign
        voParametrageTVA                        = new parametrageCodeTVA()
        ttBaremeHonoraire.cTypeHonoraire        = pcTypeHonoraire
        ttBaremeHonoraire.cLibelleTypeHonoraire = trim(outilTraduction:getLibelleProg("O_TPH", ttBaremeHonoraire.cTypeHonoraire))
        ttBaremeHonoraire.cCodeNature           = (if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-agence} then {&NATUREHONORAIRE-taux} else "")
        ttBaremeHonoraire.cLibelleNature        = (if ttBaremeHonoraire.cCodeNature > "" then trim(outilTraduction:getLibelleProg("O_NTH", ttBaremeHonoraire.cCodeNature)) else "")
        ttBaremeHonoraire.dPourcAffProp         = (if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-agence}
                                                   then 0.00
                                                   else if ttBaremeHonoraire.cTypeHonoraire >= {&TYPEHONORAIRE-fact-cab-locataire}
                                                       and ttBaremeHonoraire.cTypeHonoraire <= {&TYPEHONORAIRE-fact-cab-copro}
                                                        then 0.00
                                                        else if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion}
                                                            and ttBaremeHonoraire.cCodeNature    = {&NATUREHONORAIRE-forfait-locatif}
                                                             then 0.00
                                                             else 100.00)
        ttBaremeHonoraire.cCodePresentation     = (if lookup(ttBaremeHonoraire.cTypeHonoraire, substitute("&1,&2,&3,&4,&5"
                                                                ,{&TYPEHONORAIRE-travaux-generaux}
                                                                ,{&TYPEHONORAIRE-travaux-speciaux}
                                                                ,{&TYPEHONORAIRE-travaux-syndic}
                                                                ,{&TYPEHONORAIRE-travaux}
                                                                ,{&TYPEHONORAIRE-travaux-urgent})) > 0
                                                   then "00001"
                                                   else if lookup(ttBaremeHonoraire.cTypeHonoraire, {&TYPEHONORAIRE-agence}) > 0
                                                        then "00000"
                                                        else "")
        ttBaremeHonoraire.cCodeTva              = voParametrageTVA:getCodeTVA()
        ttBaremeHonoraire.cLibelleTva           = outilTraduction:getLibelleParam("CDTVA", ttBaremeHonoraire.cCodeTva, "")
        ttBaremeHonoraire.cLibellePresentation  = (if lookup(ttBaremeHonoraire.cTypeHonoraire, substitute("&1,&2,&3,&4,&5"
                                                                   ,{&TYPEHONORAIRE-travaux-generaux}
                                                                   ,{&TYPEHONORAIRE-travaux-speciaux}
                                                                   ,{&TYPEHONORAIRE-travaux-syndic}
                                                                   ,{&TYPEHONORAIRE-travaux}
                                                                   ,{&TYPEHONORAIRE-travaux-urgent})) > 0
                                                   then outilTraduction:getLibelle(700302) /* Détaillé */
                                                   else if lookup(ttBaremeHonoraire.cTypeHonoraire, {&TYPEHONORAIRE-agence}) > 0
                                                        then "-"
                                                        else "")
        ttBaremeHonoraire.daDateDebutApplication = today
        ttBaremeHonoraire.CRUD                   = "C"
    .
    delete object voParametrageTVA.
    /* Mise à jour de chaque champ selon le type d'honoraires */
    /* base de calcul */
    for each sys_pg no-lock
        where sys_pg.tppar = "R_TBH"
          and sys_pg.zone1 = ttBaremeHonoraire.cTypeHonoraire:
        assign
            vcBsHonUse = sys_pg.zone2
            viNbParTrv = viNbParTrv + 1
        .
    end.
    if viNbParTrv = 1 then assign
        ttBaremeHonoraire.cCodeBaseCalcul = vcBsHonUse
        ttBaremeHonoraire.cLibelleBaseCalcul = trim(outilTraduction:getLibelleParam("O_BSH", vcBsHonUse))
    .
    /* Code article par défaut */
    for first sys_pg no-lock
        where sys_pg.tppar = "O_TPH"
          and sys_pg.cdpar = ttBaremeHonoraire.cTypeHonoraire:
        if sys_pg.zone6 > ""
        then ttBaremeHonoraire.cCodeArticle = trim(sys_pg.zone6).
    end.

end procedure.

procedure getMandatBareme private:
    /*------------------------------------------------------------------------------
    Purpose: Liste des mandats utilisant le barème
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeHonoraire  as character no-undo.
    define input  parameter piCodeHonoraire  as integer   no-undo.
    define output parameter plNonGere        as logical   no-undo.
    define output parameter piNombreMandat   as integer   no-undo.
    define output parameter pcListeMandat    as character no-undo.

    define variable vcListeHono     as character no-undo.
    define variable vcTmp           as character no-undo.
    define variable viCodeHonoraire as integer   no-undo.
    define variable viI1            as integer   no-undo.
    define variable vcTypeTache     as character no-undo.

    define buffer ctrat  for ctrat.
    define buffer tache  for tache.
    define buffer sys_pg for sys_pg.
    define buffer honmd  for honmd.

    case pcTypeHonoraire:
        when {&TYPEHONORAIRE-gestion}
        then for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          , last Tache no-lock    /* Honoraires de la tache Honoraires de gestion */
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-Honoraires}:
            vcListeHono = Tache.lbdiv.
            do viI1 = 1 to num-entries(vcListeHono, separ[1] ):
                assign
                    vcTmp           = entry(viI1, vcListeHono, separ[1])
                    viCodeHonoraire = integer(entry(1 ,vcTmp, separ[2]))
                .
                if viCodeHonoraire = piCodeHonoraire and lookup(string(ctrat.nocon), pcListeMandat) = 0
                then assign
                     pcListeMandat  = pcListeMandat + "," + string(ctrat.nocon)
                     piNombreMandat = piNombreMandat + 1
                 .
            end.
            {&_proparse_ prolint-nowarn(blocklabel)}
            if piNombreMandat > 5 then leave.
        end.
        when {&TYPEHONORAIRE-frais-gestion}
        then for each tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.tptac = {&TYPETACHE-Honoraires}
              and integer(tache.ntreg) = piCodeHonoraire:
            if lookup(string(tache.nocon), pcListeMandat) = 0
            then assign
                 pcListeMandat  = pcListeMandat + "," + string(tache.nocon)
                 piNombreMandat = piNombreMandat + 1
            .
            {&_proparse_ prolint-nowarn(blocklabel)}
            if piNombreMandat > 5 then leave.
        end.
        /* Taches TVA, DAS-2T, ISF, IRF...*/
        when {&TYPEHONORAIRE-TVA}   or when {&TYPEHONORAIRE-DAS2T}       or when {&TYPEHONORAIRE-ISF}
     or when {&TYPEHONORAIRE-IRF}   or when {&TYPEHONORAIRE-taxe-bureau} or when {&TYPEHONORAIRE-CRL}
        then for first sys_pg no-lock
            where sys_pg.tppar = "R_TTH"
              and sys_pg.zone2 = pcTypeHonoraire:
            vcTypeTache = sys_pg.zone1.
            for each Tache no-lock
                where (tache.tpcon >= {&TYPECONTRAT-mandat2Syndic} and tache.tpcon <= {&TYPECONTRAT-mandat2Gerance})
                  and tache.tptac = vcTypeTache
                  and tache.tphon = pcTypeHonoraire
                  and integer(tache.cdhon) = piCodeHonoraire:
                if lookup(string(tache.nocon), pcListeMandat) = 0
                then assign
                    pcListeMandat = pcListeMandat + "," + string(tache.nocon)
                    piNombreMandat = piNombreMandat + 1
                .
                {&_proparse_ prolint-nowarn(blocklabel)}
                if piNombreMandat > 5 then leave.
            end.
        end.
        /* facturation cabinet-locataire, propriétaire ,  Gestion UL */
        when {&TYPEHONORAIRE-gestion-UL} or when {&TYPEHONORAIRE-frais-gest-UL} or when {&TYPEHONORAIRE-fact-cab-locataire}
     or when {&TYPEHONORAIRE-fact-cab-proprietaire}
        then for each honmd no-lock
            where honmd.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and honmd.tphon = pcTypeHonoraire
              and honmd.cdhon = piCodeHonoraire
            break by honmd.nocon by honmd.tptac by honmd.tphon by honmd.cdhon by honmd.catbai by honmd.noapp:
            if first-of(honmd.cdhon) then do:
                if lookup(string(honmd.nocon), pcListeMandat) = 0
                then assign
                    pcListeMandat = pcListeMandat + "," + string(honmd.nocon)
                    piNombreMandat = piNombreMandat + 1
                .
                {&_proparse_ prolint-nowarn(blocklabel)}
                if piNombreMandat > 5 then leave.
            end.
        end.
        /* facturation cabinet co-propriétaire */
        when {&TYPEHONORAIRE-fact-cab-copro}
        then for each honmd no-lock
            where honmd.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and honmd.tphon = pcTypeHonoraire
              and honmd.cdhon = piCodeHonoraire
            break by honmd.nocon by honmd.tptac by honmd.tphon by honmd.cdhon by honmd.catbai by honmd.noapp:
            if first-of (honmd.cdhon) then do:
                if lookup( string(honmd.nocon) , pcListeMandat ) = 0
                then assign
                     pcListeMandat = pcListeMandat + "," + STRING(honmd.nocon)
                     piNombreMandat = piNombreMandat + 1
                .
                {&_proparse_ prolint-nowarn(blocklabel)}
                if piNombreMandat > 5 then leave.
            end.
        end.
        otherwise plNonGere = true. /* type d'honoraire non géré ici pour le moment */
    end case.
    if piNombreMandat > 0 then pcListeMandat = substring(pcListeMandat, 2).
end procedure.

procedure createComboBaremeHonoraire:
    /*------------------------------------------------------------------------------
    Purpose: creation dans table combo liste bareme
             gga todo a voir avec Nicolas (combos pour ecran de parametrage mandat) pour voir si utilisation combo ou table bareme avec beaucoup plus de champs
    Notes  : service externe
             a partir de la procedure LstHonor du pgm l_honor.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypBareme   as character no-undo.
    define input parameter pcNomCombo    as character no-undo.
    define output parameter table for ttCombo.

    define variable viNumeroCombo as integer no-undo.
    define buffer honor for honor.

    for last ttCombo:  // quand appel by-reference, il peut y avoir des lignes dans ttCombo !!!!!
        viNumeroCombo = ttcombo.iSeqId.
    end.
    for each honor no-lock
        where honor.tphon = pcTypBareme
        break by honor.cdhon by honor.dtdeb:
        if last-of(honor.cdhon)            // SY le 27/09/2007: ajout LAST-OF suite nlle zone date début dans clé primaire
        then do:
            create ttCombo.
            assign
                viNumeroCombo     = viNumeroCombo + 1
                ttcombo.iSeqId    = viNumeroCombo
                ttCombo.cNomCombo = pcNomCombo
                ttCombo.cCode     = string(honor.cdhon, "99999")
                ttCombo.cLibelle  = ""
            .
        end.
    end.

end procedure.
