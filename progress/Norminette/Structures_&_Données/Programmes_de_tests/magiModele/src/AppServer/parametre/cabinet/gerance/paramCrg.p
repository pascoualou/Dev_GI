/*------------------------------------------------------------------------
File        : paramCrg.p
Purpose     : Paramètres du du compte rendu de gestion
Author(s)   : GGA 2017/10/31
Notes       : reprise pgm adb/prmcl/pcledcrg.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/codePeriode.i}

using parametre.pclie.pclie.
using parametre.pclie.parametrageSauveCRG.
using parametre.pclie.parametrageDetailCRG.
using parametre.pclie.parametrageEditionCRG.
using parametre.pclie.parametrageDocumentCRG.
using parametre.syspr.syspr.
using parametre.pclie.parametrageCrg123.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gerance/include/paramCrg.i}
{parametre/cabinet/gerance/include/paramCrg123.i}
{application/include/glbsepar.i}
{application/include/combo.i}
{application/include/error.i}
{adblib/include/pclie.i}
{tache/include/tache.i}
{mandat/include/rcpertrt.i}    // procedure RcPerTrt

procedure getParamCrg:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres crg du mandat de gérance
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamCrg.
    define output parameter table for ttParamCrgSelectionDocument.

    define variable vhproc as handle no-undo.

    empty temp-table ttParamCrg.
    empty temp-table ttParamCrgSelectionDocument.
    run lectureParamCrg.
    //appel pour completer la table avec les autre parametres CRG (de l'ecran parametre defaut mandat)
    run parametre/cabinet/gerance/defautMandatGerance.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run completeParamCrg in vhproc(input-output table ttParamCrg by-reference).
    run destroy in vhproc.

end procedure.

procedure getComboScenariosCrg123:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des listes et combos utilisées dans le paramétrage des scénarios CRG 123
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.
    define output parameter table for ttFamillesRubriquesQuitt.
    define output parameter table for ttRubriquesQuitt.

    define variable vhproc as handle no-undo.
    define variable viNumero as integer no-undo.

    define buffer rubqt     for rubqt.
    define buffer famqt     for famqt.
    define buffer aruba     for aruba.
    define buffer aparm     for aparm.

    empty temp-table ttFamillesRubriquesQuitt.
    empty temp-table ttRubriquesQuitt.

    /*Liste des familles/sous-familles de quittancement*/
    for each famqt no-lock:
        create ttFamillesRubriquesQuitt.
        assign
            ttFamillesRubriquesQuitt.cCodeFamille        = string(famqt.cdfam,"99")
            ttFamillesRubriquesQuitt.cCodeSousFamille    = if famqt.cdsfa = 0 then "-" else string(famqt.cdsfa, "99")
            ttFamillesRubriquesQuitt.cLibelleSousFamille = caps(outilTraduction:getLibelle(famqt.nome1))
        .
    end.

    /*Liste des rubriques de quittancement*/
    run bail/quittancement/rubriqueQuitt.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    for each rubqt no-lock:
        create ttRubriquesQuitt.
        assign
            ttRubriquesQuitt.cCodeRubrique    = string(rubqt.cdrub,"999")
            ttRubriquesQuitt.cCodeLibelle     = if rubqt.cdlib = 0 then "-" else string(rubqt.cdlib, "99")
            ttRubriquesQuitt.cLibelleRubrique = caps(dynamic-function('getLibelleRubrique' in vhproc,
                                                                           rubqt.cdrub,
                                                                           rubqt.cdlib,
                                                                           0,
                                                                           0,
                                                                           ?,                    /* date comptable */
                                                                           integer(mtoken:cRefGerance),
                                                                           0))
        .
    end.
    run destroy in vhproc.

    //Combo des rubriques et sous-rubriques analytiques
    for each aruba no-lock
        where aruba.soc-cd = integer(mToken:cRefGerance):
        create ttCombo.
        assign
            viNumero          = viNumero + 1
            ttCombo.iSeqId    = viNumero
            ttCombo.cCode     = aruba.rub-cd
            ttCombo.cLibelle  = aruba.lib
            ttCombo.cNomCombo = if aruba.fg-rub then "RUBRIQUESANA" else "SOUSRUBRIQUESANA"
        .
    end.

    //Combo des codes fiscalité
    for each aparm no-lock
        where aparm.tppar = "TFISC":
        create ttCombo.
        assign
            viNumero          = viNumero + 1
            ttCombo.iSeqId    = viNumero
            ttCombo.cCode     = aparm.cdpar
            ttCombo.cLibelle  = aparm.lib
            ttCombo.cNomCombo = "CODESFISCALITE"
        .
    end.

end procedure.

procedure getListeScenariosCrg123:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des scénarios CRG 123
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define output parameter table for ttScenarioCrg123.

    define variable voParametrageCrg123  as class parametrageCrg123 no-undo.

    voParametrageCrg123 = new parametrageCrg123().
    voParametrageCrg123:getListeScenarios(output table ttScenarioCrg123 by-reference).
    delete object voParametrageCrg123.

end procedure.

procedure getRubriquesQuitCrg123:
    /*------------------------------------------------------------------------------
    Purpose: Récupération du paramétrage des rubriques de quittancement
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeScenario as character no-undo.
    define output parameter table for ttScenarioCrg123.
    define output parameter table for ttRubriquesQuitScenarioCrg123.

    define variable voParametrageCrg123  as class parametrageCrg123 no-undo.

    empty temp-table ttRubriquesQuitScenarioCrg123.
    voParametrageCrg123 = new parametrageCrg123().
    voParametrageCrg123:getRubriquesQuit(pcCodeScenario, output table ttScenarioCrg123 by-reference, output table ttRubriquesQuitScenarioCrg123 by-reference).
    delete object voParametrageCrg123.

end procedure.

procedure getRubriquesAnaCrg123:
    /*------------------------------------------------------------------------------
    Purpose: Récupération du paramétrage des codes analytiques
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeScenario as character no-undo.
    define output parameter table for ttScenarioCrg123.
    define output parameter table for ttRubriquesAnaScenarioCrg123.

    define variable voParametrageCrg123  as class parametrageCrg123 no-undo.

    empty temp-table ttRubriquesQuitScenarioCrg123.
    voParametrageCrg123 = new parametrageCrg123().
    voParametrageCrg123:getRubriquesAna(pcCodeScenario, output table ttScenarioCrg123 by-reference, output table ttRubriquesAnaScenarioCrg123 by-reference).
    delete object voParametrageCrg123.

end procedure.

procedure getCombo:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des combos
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo.

end procedure.

procedure getParamCrgSimplifie:
    /*------------------------------------------------------------------------------
    Purpose: liste des mandats avec tache CRG pour la selection des crg simplifie
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamCrgListeCrgSimplifie.

    define buffer tache for tache.
    define buffer ctrat for ctrat.

    empty temp-table ttParamCrgListeCrgSimplifie.
    for each tache no-lock
        where tache.tptac = {&TYPETACHE-compteRenduGestion}                          /*CRG*/
          and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
      , first ctrat no-lock
        where ctrat.tpcon = tache.tpcon
          and ctrat.nocon = tache.nocon
          and ctrat.dtree = ?:
        create ttParamCrgListeCrgSimplifie.
        assign
            ttParamCrgListeCrgSimplifie.iNumeroContrat = tache.nocon
            ttParamCrgListeCrgSimplifie.cNomMandant    = ctrat.lbnom
            ttParamCrgListeCrgSimplifie.lSelection     = tache.fgsimplifie
            ttParamCrgListeCrgSimplifie.iNumeroTache   = tache.noita
            ttParamCrgListeCrgSimplifie.dtTimestamp    = datetime(tache.dtmsy, tache.hemsy)
            ttParamCrgListeCrgSimplifie.CRUD           = "R"
            ttParamCrgListeCrgSimplifie.rRowid         = rowid(tache)
        .
    end.

end procedure.

procedure setParamCrg:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres crg du mandat de gérance
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamCrg.
    define input parameter table for ttParamCrgSelectionDocument.
    define input parameter table for ttParamCrgSuiviTrt.
    define input parameter table for ttError.

    define variable vlCtrlOk                   as logical no-undo.
    define variable vlConfMajPresDetailCalcHon as logical no-undo.

    if not can-find(first ttParamCrg where ttParamCrg.CRUD = "U") then return.

    run verZonSai(output vlCtrlOk, output vlConfMajPresDetailCalcHon).
    if mError:erreur() or vlCtrlOk = no then return.

    run savEcrPrm(vlConfMajPresDetailCalcHon).

end procedure.

procedure setParamCrgSimplifie:
    /*------------------------------------------------------------------------------
    Purpose: mise a jour indicateur crg simplifie (a partir de la liste des mandats avec tache crg)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamCrgListeCrgSimplifie.

    define variable vhTache                     as handle    no-undo.
    define variable vcListeDocumentCrgSimplifie as character no-undo.
    define variable vcListeDocumentCrgStandard  as character no-undo.
    define variable voDocumentCRG as class parametrageDocumentCRG no-undo.

    //Récupération de la liste des documents édités dans le paramétrage cabinet
    voDocumentCRG = new parametrageDocumentCRG().
    if voDocumentCRG:isDbParameter
    then assign
        vcListeDocumentCrgStandard  = voDocumentCRG:getListeDocument()
        vcListeDocumentCrgSimplifie = (if lookup("00001", vcListeDocumentCrgStandard) > 0 then "00001,00004" else "00004")
    .
    delete object voDocumentCRG.
    empty temp-table ttTache.
    for each ttParamCrgListeCrgSimplifie
       where ttParamCrgListeCrgSimplifie.CRUD = "U":
        create ttTache.
        assign
            ttTache.noita       = ttParamCrgListeCrgSimplifie.iNumeroTache
            ttTache.fgsimplifie = ttParamCrgListeCrgSimplifie.lSelection
            ttTache.lbdiv3      = if ttParamCrgListeCrgSimplifie.lSelection
                                  then vcListeDocumentCrgSimplifie
                                  else vcListeDocumentCrgStandard
            ttTache.CRUD        = ttParamCrgListeCrgSimplifie.CRUD
            ttTache.dtTimestamp = ttParamCrgListeCrgSimplifie.dtTimestamp
            ttTache.rRowid      = ttParamCrgListeCrgSimplifie.rRowid
        .
    end.
    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).

end procedure.

procedure setScenarioCrg123:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des scénarios CRG 123
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttScenarioCrg123.
    define input parameter table for ttRubriquesQuitScenarioCrg123.
    define input parameter table for ttRubriquesAnaScenarioCrg123.
    define input parameter table for ttError.

    define variable voParametrageCrg123  as class parametrageCrg123 no-undo.
    define buffer pclie for pclie.

    /*run verZonSai(output vlCtrlOk, output vlConfMajPresDetailCalcHon).
    if mError:erreur() or vlCtrlOk = no then return.*/

    voParametrageCrg123 = new parametrageCrg123().
    for first ttScenarioCrg123
        where lookup(ttScenarioCrg123.CRUD, "C,U,D") > 0:
        if ttScenarioCrg123.CRUD = "U" then do:
            find first pclie no-lock
                where rowid(pclie) = ttScenarioCrg123.rRowid no-error.
            //On teste le timestamp sur l'enregistrement pclie d'entête du scénario
            if outils:isUpdated(buffer pclie:handle, 'pclie ', 'Scénario CRG 123', ttScenarioCrg123.dtTimestamp)
            then return.
        end.
        create ttPclie.
        buffer-copy ttScenarioCrg123 to ttPclie
        assign
            ttPclie.zon01 = "SCEN"
            ttPclie.zon10 = ttScenarioCrg123.cCodeScenario
            ttPclie.lbdiv = ttScenarioCrg123.cLibelleScenario
        .
        if ttScenarioCrg123.crud <> "D" then do: //En cas de suppression globale du scénario, on n'envoie pas les lignes car elles vont être supprimées
            for each ttRubriquesQuitScenarioCrg123
                where lookup(ttRubriquesQuitScenarioCrg123.CRUD, "C,U,D") > 0:
                create ttPclie.
                buffer-copy ttRubriquesQuitScenarioCrg123 to ttPclie
                assign
                    ttPclie.zon01 = "QTT"
                    ttPclie.zon10 = ttRubriquesQuitScenarioCrg123.cCodeScenario
                    ttPclie.int01 = integer(ttRubriquesQuitScenarioCrg123.cCodeFamille)
                    ttPclie.int02 = integer(ttRubriquesQuitScenarioCrg123.cCodeSousFamille)
                    ttPclie.zon02 = ttRubriquesQuitScenarioCrg123.cCodeRubrique
                    ttPclie.zon03 = ttRubriquesQuitScenarioCrg123.cCodeLibelle
                    ttPclie.int03 = integer(ttRubriquesQuitScenarioCrg123.cNumeroReleve)
                .
            end.
            for each ttRubriquesAnaScenarioCrg123
                where lookup(ttRubriquesAnaScenarioCrg123.CRUD, "C,U,D") > 0:
                create ttPclie.
                buffer-copy ttRubriquesAnaScenarioCrg123 to ttPclie
                assign
                    ttPclie.zon01 = "ANA"
                    ttPclie.zon10 = ttRubriquesAnaScenarioCrg123.cCodeScenario
                    ttPclie.zon02 = ttRubriquesAnaScenarioCrg123.cCodeRubrique
                    ttPclie.zon03 = ttRubriquesAnaScenarioCrg123.cCodeSousRubrique
                    ttPclie.zon04 = ttRubriquesAnaScenarioCrg123.cCodeFiscalite
                    ttPclie.int03 = integer(ttRubriquesAnaScenarioCrg123.cNumeroReleve)
                .
            end.
        end.
        voParametrageCrg123:setScenarioCrg123(input table ttPclie by-reference).
    end.
    delete object voParametrageCrg123.

end procedure.

procedure lectureParamCrg private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres crg du mandat de gérance
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vlSpeDef        as logical   no-undo.
    define variable viI             as integer   no-undo.
    define variable vcListeDocument as character no-undo.
    define variable voOdtrm       as class pclie                  no-undo.
    define variable voEditionCRG  as class parametrageEditionCRG  no-undo.
    define variable voDocumentCRG as class parametrageDocumentCRG no-undo.
    define variable voDetailCRG   as class parametrageDetailCRG   no-undo.
    define buffer aparm   for aparm.
    define buffer aprmcrg for aprmcrg.
    define buffer sys_pr for sys_pr.

    vlSpeDef = (integer(mToken:cRefPrincipale) = 01543).
    for each sys_pr no-lock
        where sys_pr.tppar = "DCCRG":
        create ttParamCrgSelectionDocument.
        assign
            ttParamCrgSelectionDocument.iNumeroOrdre    = 99999
            ttParamCrgSelectionDocument.cCodeDocument   = sys_pr.cdpar
            ttParamCrgSelectionDocument.cNomDocument    = outilTraduction:getLibelle(string(sys_pr.nome1))
            ttParamCrgSelectionDocument.lEditionCabinet = no
        .
    end.
    if not can-find(first ttParamCrg) then do:                 //si on vient de defautMandatGestion.p, l'enregistrement existe deja, c'est pour completer
        create ttParamCrg.
        ttParamCrg.CRUD = "R".
    end.
    voEditionCRG = new parametrageEditionCRG().
    if voEditionCRG:isDbParameter
    then assign
        ttParamCrg.cCodeTypeEdition              = voEditionCRG:getCodeTypeEdition()
        ttParamCrg.lPresentationJustifBaseHonFac = voEditionCRG:isPresentationJustifBaseHonFac()
        ttParamCrg.lDetailHonoraireMensuel       = voEditionCRG:isDetailHonoraireMensuel()
        ttParamCrg.lTrimesDecalePartielFinAnnee  = voEditionCRG:isTrimesDecalePartielFinAnnee()
    .
    else assign
        ttParamCrg.cCodeTypeEdition              = "00001"
        ttParamCrg.lPresentationJustifBaseHonFac = no
        ttParamCrg.lDetailHonoraireMensuel       = no
        ttParamCrg.lTrimesDecalePartielFinAnnee  = vlSpeDef
    .
    delete object voEditionCRG.
    assign
        voOdtrm                                 = new pclie("ODTRM")
        ttParamCrg.lTrimesDecalePartielFinAnnee = false when ttParamCrg.lDetailHonoraireMensuel
        ttParamCrg.cLibelleTypeEdition          = outilTraduction:getLibelleParam("EDCRG", ttParamCrg.cCodeTypeEdition)
        ttParamCrg.lGenererOdrtFinPeriode       = if voOdtrm:isDbParameter then (voOdtrm:zon01 = "00001") else false
    .
    delete object voOdtrm.
    voDocumentCRG = new parametrageDocumentCRG().
    if voDocumentCRG:isDbParameter
    then do:
        assign
            ttParamCrg.cCodeClassementCrg            = voDocumentCRG:getCodeClassement()
            ttParamCrg.lEditerDGSiResultantEgal0     = voDocumentCRG:isEditerDGSiResultantEgal0()
            ttParamCrg.lEditerCoordonnesGestionnaire = voDocumentCRG:isEditerCoordonnesGestionnaire()
            ttParamCrg.lReleveRecapitulatifFinAnnee  = voDocumentCRG:isReleveRecapitulatifFinAnnee()
            ttParamCrg.cTriDetailSituationProp       = voDocumentCRG:getTriDetailSituationProp()
            ttParamCrg.cRegroupementEncaissement     = voDocumentCRG:getRegroupementEncaissement()
            ttParamCrg.lEditerSituationLocataire     = voDocumentCRG:isEditerSituationLocataire()
            ttParamCrg.cCodeScenarioPresentation     = voDocumentCRG:getCodeScenarioPresentation()
            ttParamCrg.cCodeEditionFacture           = voDocumentCRG:getCodeEditionFacture()
            ttParamCrg.cEdSitCompteProprietaire      = voDocumentCRG:getEdSitCompteProprietaire()
            ttParamCrg.cPeriodeTitreDocument         = voDocumentCRG:getPeriodeTitreDocument()
            ttParamCrg.lRecapRubriqueVentilEncais    = voDocumentCRG:isRecapRubriqueVentilEncais()
            ttParamCrg.lTotMandatVentilEncais        = voDocumentCRG:isTotMandatVentilEncais()
            ttParamCrg.lTotMandantVentilEncais       = voDocumentCRG:isTotMandantVentilEncais()
            ttParamCrg.lEdTvaEncais                  = voDocumentCRG:isEdTvaEncais()
            ttParamCrg.lEdTvaDepenseSurCrgSimplifie  = voDocumentCRG:isEdTvaDepenseSurCrgSimplifie()
            ttParamCrg.lTotSousTitreSurCrg           = voDocumentCRG:isTotSousTitreSurCrg()
            ttParamCrg.lEdSoldePropPartiSurPgIndex   = voDocumentCRG:isEdSoldePropPartiSurPgIndex()
            ttParamCrg.lEdVentilParMandat            = voDocumentCRG:isEdVentilParMandat()
            vcListeDocument                          = voDocumentCRG:getListeDocument()
        .
        do viI = 1 to num-entries(vcListeDocument):
            for first ttParamCrgSelectionDocument
                where ttParamCrgSelectionDocument.cCodeDocument = entry(viI, vcListeDocument):
                assign
                    ttParamCrgSelectionDocument.lEditionCabinet = yes
                    ttParamCrgSelectionDocument.iNumeroOrdre   = viI
                .
            end.
        end.
    end.
    else assign
        ttParamCrg.cCodeClassementCrg           = "00002"
        ttParamCrg.cEdSitCompteProprietaire     = "L+N"
        ttParamCrg.cPeriodeTitreDocument        = "Dates"
        ttParamCrg.lRecapRubriqueVentilEncais   = true
        ttParamCrg.lTotMandatVentilEncais       = true
        ttParamCrg.lTotMandantVentilEncais      = true
        ttParamCrg.lEdTvaEncais                 = true
        ttParamCrg.lEdTvaDepenseSurCrgSimplifie = true
        ttParamCrg.lTotSousTitreSurCrg          = true
        ttParamCrg.lEdSoldePropPartiSurPgIndex  = false
        ttParamCrg.lEdVentilParMandat           = false
    .
    delete object voDocumentCRG.
    assign
        ttParamCrg.cLibelleClassementCrg           = outilTraduction:getLibelleParam("CLCRG", ttParamCrg.cCodeClassementCrg)
        ttParamCrg.cLibTriDetailSituationProp      = outilTraduction:getLibelleParam("TRCRG", ttParamCrg.cTriDetailSituationProp)
        ttParamCrg.cLibelleEditionFacture          = outilTraduction:getLibelleParam("EDHON", ttParamCrg.cCodeEditionFacture)
        ttParamCrg.lAffichCrgLibre                 = can-find(first iparm no-lock where iparm.tppar = "CRGL" and iparm.cdpar = "01")
        ttParamCrg.lPresentationDetailCalculHono-2 = can-find(first aparm no-lock
                                                          where aparm.tppar = "THONO"
                                                            and aparm.cdpar = "AFCRG"
                                                            and aparm.zone2 = "OUI")
    .
    for first aprmcrg no-lock
        where aprmcrg.soc-cd     = integer(mToken:cRefGerance)
          and aprmcrg.type-ligne = 'SCENARIO'
          and aprmcrg.scen-cle   = ttParamCrg.cCodeScenarioPresentation:
        ttParamCrg.cLibelleScenarioPresentation = aprmcrg.lib.
    end.
    if ttParamCrg.cEdSitCompteProprietaire = "L+N"
    then ttParamCrg.cLibEdSitCompteProprietaire = outilTraduction:getLibelle(1000500).            // Let. + Non Let.
    else if ttParamCrg.cEdSitCompteProprietaire = "N"
         then ttParamCrg.cLibEdSitCompteProprietaire = outilTraduction:getLibelle(1000501).       // Non Lettrées

    if ttParamCrg.cPeriodeTitreDocument = "Mois/Trim"
    then ttParamCrg.cLibPeriodeTitreDocument = outilTraduction:getLibelle(1000502).               // Mois/Trim"
    else if ttParamCrg.cPeriodeTitreDocument = "Dates"
         then ttParamCrg.cLibPeriodeTitreDocument = outilTraduction:getLibelle(1000503).          // Dates

    if ttParamCrg.cRegroupementEncaissement = "00001"
    then ttParamCrg.cLibRegroupementEncaissement = outilTraduction:getLibelle(1000504).           //Par mois
    else if ttParamCrg.cRegroupementEncaissement = "00002"
         then ttParamCrg.cLibRegroupementEncaissement = outilTraduction:getLibelle(102086).       // Non
         else if ttParamCrg.cRegroupementEncaissement = "00003"
              then ttParamCrg.cLibRegroupementEncaissement = outilTraduction:getLibelle(1000505). // Par règlement
              else if ttParamCrg.cRegroupementEncaissement = "00004"
              then ttParamCrg.cLibRegroupementEncaissement = outilTraduction:getLibelle(1000506). // Par locataire

    voDetailCRG = new parametrageDetailCRG().
    if voDetailCRG:isDbParameter
    then assign
        ttParamCrg.lPresentationFactureLocataire = voDetailCRG:isPresentationFactureLocataire()
        ttParamCrg.lCrgLibre                     = voDetailCRG:isCrgLibre()
    .
    else assign
        ttParamCrg.lPresentationFactureLocataire = no
        ttParamCrg.lCrgLibre                     = no
    .
    delete object voDetailCRG.

    find first aparm no-lock
        where aparm.tppar = "PROVPERM" no-error.
    if available aparm
    then assign
        ttParamCrg.lProvisionPermanente        = true
        ttParamCrg.cLibelleProvisionPermanente = aparm.lib
    .
    else assign
        ttParamCrg.lProvisionPermanente        = false
        ttParamCrg.cLibelleProvisionPermanente = ""
    .
    /*--> Chargement : Edition duplicata (avec initialisation à OUI pour 1078 - Sofigest)*/
    find first aparm no-lock
         where aparm.tppar = "DUPLICRG" no-error.
    if not available aparm and integer(mToken:cRefPrincipale) = 1078 then do:
        create aparm.
        assign
            aparm.tppar = "DUPLICRG"
            aparm.zone2 = "00001"
        .
    end.
    ttParamCrg.lEditionDuplicata = if available aparm then (aparm.zone2 = "00001") else false.
    /*--> Chargement : Regroupement Garanties Loyers (avec initialisation à OUI pour certaines références)*/
    find first aparm no-lock
         where aparm.tppar = "RGTGLCRG" no-error.
    if not available aparm
    and lookup(mToken:cRefPrincipale, "1685,1003,2000,1158,5013,4864,1457,1319,1296,1361,1586,3085,1325,3088,6505,6506,3060") > 0
    then do:
        create aparm.
        assign
            aparm.tppar = "RGTGLCRG"
            aparm.zone2 = "00001"
        .
    end.
    ttParamCrg.lRegroupementGarantieLoyer = if available aparm then (aparm.zone2 = "00001") else false.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspr as class syspr no-undo.
    define variable viNumeroItem as integer no-undo.
    define buffer aprmcrg for aprmcrg.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("CLCRG", "CRG-CLASSEMENT", output table ttCombo by-reference).
    voSyspr:getComboParametre("EDCRG", "CRG-MODEED"    , output table ttCombo by-reference).
    for each ttCombo
        where ttCombo.cNomCombo = "CRG-MODEED":
        if lookup(ttCombo.cCode, "00001,00009,00021") = 0 then delete ttCombo.
    end.
    voSyspr:getComboParametre("TRCRG", "CRG-TRIDETAILSITUPROP", output table ttCombo by-reference).
    voSyspr:getComboParametre("EDHON", "CRG-EDFACTURE"        , output table ttCombo by-reference).
    for last ttCombo:
        viNumeroItem = ttcombo.iSeqId.
    end.
    for each aprmcrg no-lock
        where aprmcrg.soc-cd = integer(mToken:cRefGerance)
          and aprmcrg.type-ligne = 'SCENARIO':
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttcombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CRG-SCENPRESENTATION"
            ttCombo.cCode     = aprmcrg.scen-cle
            ttCombo.cLibelle  = aprmcrg.lib
        .
    end.
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CRG-EDSITUATIONCOMPTEPROPRIETAIRE"
        ttCombo.cCode     = "L+N"
        ttCombo.cLibelle  = outilTraduction:getLibelle(1000500).       //Let. + Non Let."
    .
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CRG-EDSITUATIONCOMPTEPROPRIETAIRE"
        ttCombo.cCode     = "N"
        ttCombo.cLibelle  = outilTraduction:getLibelle(1000501).       //Non Lettrées"
    .
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CRG-PERIODETITREDOCUMENT"
        ttCombo.cCode     = "Mois/Trim"
        ttCombo.cLibelle  = outilTraduction:getLibelle(1000502).       //Mois/Trim."
    .
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CRG-PERIODETITREDOCUMENT"
        ttCombo.cCode     = "Dates"
        ttCombo.cLibelle  = outilTraduction:getLibelle(1000503).       //Dates
    .
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CRG-REGRPOUPEMENTENCAISSEMENT"
        ttCombo.cCode     = "00001"
        ttCombo.cLibelle  = outilTraduction:getLibelle(1000504).       //Par mois"
    .
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CRG-REGRPOUPEMENTENCAISSEMENT"
        ttCombo.cCode     = "00002"
        ttCombo.cLibelle  = outilTraduction:getLibelle(102086).  //Non
    .
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CRG-REGRPOUPEMENTENCAISSEMENT"
        ttCombo.cCode     = "00003"
        ttCombo.cLibelle  = outilTraduction:getLibelle(1000505).       //Par règlement"
    .
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttcombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CRG-REGRPOUPEMENTENCAISSEMENT"
        ttCombo.cCode     = "00004"
        ttCombo.cLibelle  = outilTraduction:getLibelle(1000506).       //Par locataire"
    .
end procedure.

procedure VerZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de Vérification des zones saisies.
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter plCtrlOk                   as logical no-undo.
    define output parameter plConfMajPresDetailCalcHon as logical no-undo.

    define variable viRetQuestion  as integer no-undo.
    define variable vlPerATraiter  as logical no-undo.
    define variable vdaDebPer      as date    no-undo.
    define variable vdaFinPer      as date    no-undo.
    define variable vlCRGDecale    as logical no-undo.
    define variable vlCRGActif     as logical no-undo.
    define variable vlPresentation as logical no-undo.
    define variable voEditionCRG as class parametrageEditionCRG no-undo.

    define buffer ietab for ietab.
    define buffer agest for agest.
    define buffer tache for tache.

    assign
        voEditionCRG   = new parametrageEditionCRG()
        vlCRGActif     = voEditionCRG:isDbParameter
        vlCRGDecale    = voEditionCRG:isTrimesDecalePartielFinAnnee()
        vlPresentation = voEditionCRG:isPresentationJustifBaseHonFac()
    .
    delete object voEditionCRG.
    find first ttParamCrg where ttParamCrg.CRUD = "U" no-error.
    if not available ttParamCrg then return.

    if ttParamCrg.lGenererOdrtFinPeriode = ?
    then do:
        mError:createError({&error}, 1000497). //Le paramètre Générer les ODRT fin de période doit être renseigné
        return.
    end.

    if vlCRGActif then do:
        if vlPresentation <> ttParamCrg.lPresentationJustifBaseHonFac
        and ttParamCrg.lPresentationDetailCalculHono-2 = no
        then do:
            mError:createError({&error}, 1000498).   //Modification présentation justif. base honoraires/facture impossible si présentation détail calcul des honoraires est à non
            return.
        end.
        if ttParamCrg.lTrimesDecalePartielFinAnnee <> vlCRGDecale
        and ttParamCrg.lDetailHonoraireMensuel = no
        then do:
            run verCmbSpe(ttParamCrg.lTrimesDecalePartielFinAnnee, vlCRGDecale).
            if mError:erreur() then return.
        end.
    end.

    //si modification de presentation detail calcul des honoraires
    if ttParamCrg.lPresentationDetailCalculHono-2 <> can-find(first aparm no-lock
                                                              where aparm.tppar = "THONO"
                                                                and aparm.cdpar = "AFCRG"
                                                                and aparm.zone2 = "OUI")
    then do:
        plConfMajPresDetailCalcHon = yes.
        if ttParamCrg.lPresentationDetailCalculHono-2
        then for first ietab no-lock
            where ietab.soc-cd    = integer(mToken:cRefGerance)
              and ietab.profil-cd = 21
          , first agest no-lock
            where agest.soc-cd   = ietab.soc-cd
              and agest.gest-cle = ietab.gest-cle:
boucle-tache:
            for each tache no-lock
               where tache.tptac = {&TYPETACHE-compteRenduGestion}
                 and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                 and tache.pdges <> {&PERIODICITEGESTION-mensuel}:
                run rcPerTrt(vlCRGDecale, tache.tpcon, tache.nocon, {&TYPETACHE-compteRenduGestion}, "O_PRD", agest.dafin, output vlPerATraiter, output vdaDebPer, output vdaFinPer).
                if vdaDebPer <> agest.dadeb then do:
                    /*--> Le détail du calcul des honoraires sera incomplet si vous changez le paramètre au milieu de la période du CRG. Confirmez-vous la saisie ?*/
                    viRetQuestion = outils:questionnaire(109052, table ttError by-reference).
                    if viRetQuestion < 2 then return.

                    plConfMajPresDetailCalcHon = (viRetQuestion = 3).
                    leave boucle-tache.
                end.
            end.
        end.
    end.
    plCtrlOk = true.

end procedure.

procedure SavEcrPrm private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de sauvegarde des paramètres
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter plConfMajPresDetailCalcHon as logical no-undo.

    define buffer tache   for tache.
    define buffer aparm   for aparm.

    define variable viNoSauvegarde                   as integer   no-undo initial 1.
    define variable vlAncReleveRecapitulatifFinAnnee as logical   no-undo.
    define variable vcListeDocument                  as character no-undo.
    define variable voEditionCRG  as class parametrageEditionCRG  no-undo.
    define variable voDocumentCRG as class parametrageDocumentCRG no-undo.
    define variable voSauveCRG    as class parametrageSauveCRG    no-undo.
    define variable voDetailCRG   as class parametrageDetailCRG   no-undo.
    define variable voOdtrm       as class pclie                  no-undo.

    find first ttParamCrgSuiviTrt no-error.
    find first ttParamCrg where ttParamCrg.CRUD = "U" no-error.
    if not available ttParamCrg then return.
    assign
        voSauveCRG     = new parametrageSauveCRG()
        viNoSauvegarde = voSauveCRG:getLastSauveCRG()
    .
    voEditionCRG   = new parametrageEditionCRG().
    if voEditionCRG:isDbParameter
    then run voSauveCRG:sauvePclieCRG(voEditionCRG, viNoSauvegarde).
    else voEditionCRG:create().
    assign
        voEditionCRG:zon01 = ttParamCrg.cCodeTypeEdition
        voEditionCRG:zon04 = string(ttParamCrg.lPresentationJustifBaseHonFac, "00001/00002")     /*Edition justif. base honoraires/facture*/
        voEditionCRG:zon05 = string(ttParamCrg.lDetailHonoraireMensuel, "00001/00002")           /*Detail des honoraires mensuels*/
        voEditionCRG:fgact = "YES"
    .
    if ttParamCrg.lDetailHonoraireMensuel = no
    then voEditionCRG:zon06 = string(ttParamCrg.lTrimesDecalePartielFinAnnee, "00001/00002").      /** Ajout SY le 10/01/2006 : Trimestriels décalés partiels en fin d’année (specif MARNEZ) */
    voEditionCRG:update().
    delete object voEditionCRG.

    voOdtrm = new pclie("ODTRM").
    if voOdtrm:isDbParameter
    then run voSauveCRG:sauvePclieCRG(voOdtrm, viNoSauvegarde).
    else voOdtrm:create().
    voOdtrm:zon01 = string(ttParamCrg.lGenererOdrtFinPeriode, "00001/00002").
    voOdtrm:update().
    delete object voOdtrm.

    voDocumentCRG = new parametrageDocumentCRG().
    if voDocumentCRG:isDbParameter
    then run voSauveCRG:sauvePclieCRG(voDocumentCRG, viNoSauvegarde).
    else voDocumentCRG:create().
    assign
        voDocumentCRG:zon01 = ttParamCrg.cCodeClassementCrg
        voDocumentCRG:zon05 = ttParamCrg.cCodeEditionFacture
        voDocumentCRG:fgact = "YES"
    .
    if can-find(first pclie no-lock where pclie.tppar = "NVCRG")
    then do:
        assign
            vlAncReleveRecapitulatifFinAnnee = (if num-entries(voDocumentCRG:zon02, "|") > 2 then entry(3, voDocumentCRG:zon02, "|") = "00001" else false)
            voDocumentCRG:zon02 = substitute("&2&1&3&1&4&1&5&1&6&1&7", "|",
                              string(ttParamCrg.lEditerDGSiResultantEgal0    , "00001/00002"),
                              string(ttParamCrg.lEditerCoordonnesGestionnaire, "00001/00002"),
                              string(ttParamCrg.lReleveRecapitulatifFinAnnee , "00001/00002"),
                              ttParamCrg.cTriDetailSituationProp,
                              ttParamCrg.cRegroupementEncaissement,
                              string(ttParamCrg.lEditerSituationLocataire    , "00001/00002"))
            voDocumentCRG:zon03 = ttParamCrg.cCodeScenarioPresentation
            voDocumentCRG:zon06 = ttParamCrg.cEdSitCompteProprietaire
            voDocumentCRG:zon07 = ttParamCrg.cPeriodeTitreDocument
            voDocumentCRG:zon08 = substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9", "¤",
                              string(ttParamCrg.lRecapRubriqueVentilEncais  , "00001/00002"),
                              string(ttParamCrg.lTotMandatVentilEncais      , "00001/00002"),
                              string(ttParamCrg.lTotMandantVentilEncais     , "00001/00002"),
                              string(ttParamCrg.lEdTvaEncais                , "00001/00002"),
                              string(ttParamCrg.lEdTvaDepenseSurCrgSimplifie, "00001/00002"),
                              string(ttParamCrg.lTotSousTitreSurCrg         , "00001/00002"),
                              string(ttParamCrg.lEdSoldePropPartiSurPgIndex , "00001/00002"),
                              string(ttParamCrg.lEdVentilParMandat          , "00001/00002"))
        .
        if ttParamCrg.lReleveRecapitulatifFinAnnee <> vlAncReleveRecapitulatifFinAnnee
        and (available ttParamCrgSuiviTrt and ttParamCrgSuiviTrt.lReportRecapAnnuel = yes)
        then for each tache exclusive-lock
           where tache.tptac = {&TYPETACHE-compteRenduGestion}
             and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
             and tache.fgrev <> ttParamCrg.lReleveRecapitulatifFinAnnee:
            tache.fgrev = ttParamCrg.lReleveRecapitulatifFinAnnee.
        end.
        //liste des documents
        for each ttParamCrgSelectionDocument
            where ttParamCrgSelectionDocument.lEditionCabinet:
            vcListeDocument = vcListeDocument + "," + ttParamCrgSelectionDocument.cCodeDocument.
        end.
        vcListeDocument = trim(vcListeDocument, ",").
        if vcListeDocument <> voDocumentCRG:zon04        //Ajout OF le 26/01/09 - Report de la sélection des documents sur tous les mandats
        and (available ttParamCrgSuiviTrt and ttParamCrgSuiviTrt.lReportSelectionDoc = yes)
        then for each tache exclusive-lock
            where tache.tptac = {&TYPETACHE-compteRenduGestion}                       /*CRG*/
              and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.fgsimplifie = false:                 /**Ajout OF le 07/12/09**/
            tache.lbdiv3 = vcListeDocument.
        end.
        voDocumentCRG:zon04 = vcListeDocument.
        /*--> Edition Duplicata */
        find first aparm exclusive-lock
            where aparm.tppar = "DUPLICRG" no-error.
        if not available aparm then do:
            create aparm.
            assign
                aparm.tppar    = "DUPLICRG"
                aparm.usrid    = mtoken:cUser
                aparm.dacrea   = today
                aparm.ihcrea   = mtime
                aparm.usridmod = mtoken:cUser
                aparm.damod    = aparm.dacrea
                aparm.ihmod    = aparm.ihcrea
            .
        end.
        else assign
             aparm.usridmod = mtoken:cUser
             aparm.damod    = today
             aparm.ihmod    = mtime
        .
        aparm.zone2 = string(ttParamCrg.lEditionDuplicata, "00001/00002").
        /*--> Regroupement Garanties Loyers */
        find first aparm exclusive-lock
             where aparm.tppar = "RGTGLCRG" no-error.
        if not available aparm then do:
            create aparm.
            assign
                aparm.tppar    = "RGTGLCRG"
                aparm.usrid    = mtoken:cUser
                aparm.dacrea   = today
                aparm.ihcrea   = mtime
                aparm.usridmod = mtoken:cUser
                aparm.damod    = aparm.dacrea
                aparm.ihmod    = aparm.ihcrea
            .
        end.
        else assign
             aparm.usridmod = mtoken:cUser
             aparm.damod    = today
             aparm.ihmod    = mtime
        .
        aparm.zone2 = string(ttParamCrg.lRegroupementGarantieLoyer, "00001/00002").
    end.
    voDocumentCRG:update().
    delete object voDocumentCRG.

    voDetailCRG = new parametrageDetailCRG().
    if voDetailCRG:isDbParameter
    then run voSauveCRG:sauvePclieCRG(voDetailCRG, viNoSauvegarde).
    else voDetailCRG:create().
    assign
        voDetailCRG:zon02 = string(ttParamCrg.lPresentationFactureLocataire, "00001/00002")
        voDetailCRG:fgact = "YES"
    .
    if can-find(first iparm no-lock where iparm.tppar = "CRGL" and iparm.cdpar = "01")
    and ttParamCrg.lTrimesDecalePartielFinAnnee = no
    then voDetailCRG:zon01 = string(ttParamCrg.lCrgLibre, "00003/00002").
    voDetailCRG:update().
    delete object voDetailCRG.

    //si modification de presentation detail calcul des honoraires
    if ttParamCrg.lPresentationDetailCalculHono-2 <> can-find(first aparm no-lock
                                                              where aparm.tppar = "THONO"
                                                                and aparm.cdpar = "AFCRG"
                                                                and aparm.zone2 = "OUI")
    then do:
        if plConfMajPresDetailCalcHon = yes
        then do:
            find first aparm exclusive-lock
                 where aparm.tppar = "THONO"
                   and aparm.cdpar = "AFCRG" no-error.
            if not available aparm
            then do:
                create aparm.
                assign
                    aparm.soc-cd   = 0
                    aparm.etab-cd  = 0
                    aparm.tppar    = "THONO"
                    aparm.cdpar    = "AFCRG"
                    aparm.nome1    = 0
                    aparm.nome2    = 0
                    aparm.lib      = "Affichage des barèmes honoraires dans CRG"
                    aparm.usrid    = mtoken:cUser
                    aparm.dacrea   = today
                    aparm.ihcrea   = mtime
                    aparm.usridmod = mtoken:cUser
                    aparm.damod    = aparm.dacrea
                    aparm.ihmod    = aparm.ihcrea
                .
            end.
            else assign
                    aparm.usridmod = mtoken:cUser
                    aparm.damod    = today
                    aparm.ihmod    = mtime
            .
            aparm.zone2 = string(ttParamCrg.lPresentationDetailCalculHono-2, "OUI/NON").
        end.
    end.

    find first aparm exclusive-lock
         where aparm.tppar = "PROVPERM" no-error.
    if ttParamCrg.lProvisionPermanente
    then do:
        if not available aparm
        then do:
            create aparm.
            assign
                aparm.tppar    = "PROVPERM"
                aparm.usrid    = mtoken:cUser
                aparm.dacrea   = today
                aparm.ihcrea   = mtime
                aparm.usridmod = mtoken:cUser
                aparm.damod    = aparm.dacrea
                aparm.ihmod    = aparm.ihcrea
            .
        end.
        else assign
            aparm.usridmod = mtoken:cUser
            aparm.damod    = today
            aparm.ihmod    = mtime
        .
        aparm.lib = ttParamCrg.cLibelleProvisionPermanente.
   end.
   else if available aparm then delete aparm.

end procedure.

procedure VerCmbSpe private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle du changement "trim decalés partiels en fin d'année"
             a/ L’activation est impossible si le mois en cours en gérance est « Janvier »
                et s’il existe des mandats trimestriels décalés « Fév-Avr » mouvementés en Novembre ou Décembre de l’année précédente.
             b/ L’activation est impossible si le mois en cours en gérance est « Février »
                et s’il existe des mandats trimestriels décalés « Mar-Mai » mouvementés en Décembre de l’année précédente.
             c/ S’il existe un mandat de gérance dont le CRG est « Trimestriel décalé »
                et dont la périodicité des honoraires n’est pas « Mensuelle »,  l’activation
                de l’option « Trimestriels décalés partiels en fin d’année » déclenche un message d’alerte :
             « Attention, certains mandats ont des honoraires trimestriels (ou semestriels) »
             , le CRG partiel en fin d’année sera édité sans les honoraires  »
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter plNouvTrimesDecalePartielFinAnnee as logical no-undo.
    define input parameter plAncTrimesDecalePartielFinAnnee  as logical no-undo.

    define variable viNbHonDec as integer   no-undo.
    define variable vcLsHonDec as character no-undo.
    define variable vcCdcrgrch as character no-undo.
    define variable vdaDebEcr  as date      no-undo.
    define variable vdaFinEcr  as date      no-undo.
    define variable viNoMdtTrv as integer   no-undo.
    define variable vdaCompta  as date      no-undo.

    define buffer ietab     for ietab.
    define buffer agest     for agest.
    define buffer ctrat     for ctrat.
    define buffer tache     for tache.
    define buffer iprd      for iprd.
    define buffer csscptcol for csscptcol.
    define buffer cecrln    for cecrln.
    define buffer vbtache   for tache.

    /*--> Recherche du mois comptable en cours de gérance */
    for first ietab no-lock
        where ietab.soc-cd    = integer(mToken:cRefGerance)
          and ietab.profil-cd = 21
      , first agest no-lock
        where agest.soc-cd   = ietab.soc-cd
          and agest.gest-cle = ietab.gest-cle:
        vdaCompta = agest.dadeb.
    end.

    if vdaCompta <> ? and (month(vdaCompta) = 01 or month(vdaCompta) = 02)
    then do:
        if month(vdaCompta) = 01
        then assign
            vcCdcrgrch = {&PERIODICITEGESTION-trimestrielFevAvril}
            vdaDebEcr  = date(11, 01, year(vdaCompta) - 1)
            vdaFinEcr  = date(12, 31, year(vdaCompta) - 1)
        .
        else if month(vdaCompta) = 02
        then assign
            vcCdcrgrch = {&PERIODICITEGESTION-trimestrielMarsMai}
            vdaDebEcr  = date(12, 01, year(vdaCompta) - 1)
            vdaFinEcr  = date(12, 31, year(vdaCompta) - 1)
        .
boucleContrat:
        for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and (ctrat.dtree = ? or ctrat.dtree > today)
          , last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-compteRenduGestion}
              and tache.pdges = vcCdcrgrch:
            /* recherche s'il y a des écritures */
boucleEcriture:
            for each iprd no-lock
                where iprd.soc-cd   = integer(mToken:cRefGerance)
                  and iprd.etab-cd  = ctrat.nocon
                  and iprd.dadebprd <= vdaFinEcr
                  and iprd.dafinprd <= vdaFinEcr
                  and iprd.dadebprd >= vdaDebEcr
                  and iprd.dafinprd >= vdaDebEcr
              , each csscptcol no-lock
                where csscptcol.soc-cd  = iprd.soc-cd
                  and csscptcol.etab-cd = iprd.etab-cd
              , each cecrln no-lock
                where cecrln.soc-cd     = csscptcol.soc-cd
                  and cecrln.etab-cd    = csscptcol.etab-cd
                  and cecrln.sscoll-cle = csscptcol.sscoll-cle
                  and cecrln.prd-cd     = iprd.prd-cd
                  and cecrln.prd-num    = iprd.prd-num:
                viNoMdtTrv = ctrat.nocon.
                leave boucleEcriture.
            end.
            if viNoMdtTrv <> 0 then leave boucleContrat.
        end.
        if viNoMdtTrv <> 0
        then do:
            /* La modification de l'option <Trimestriels décalés partiels en fin d'année> n'est pas possible pour ce mois comptable (%1)%sCar il existe des mandats à CRG trimestriel décalé qui ont été mouvementés sur la période partielle %2 (ex : mandat %3)*/
            mError:createErrorGestion({&error}, 109884, substitute('&2&1&3-&4&1&5', separ[1], string(vdaCompta, "99/99/9999"), string(vdaDebEcr, "99/99/9999"), string(vdaFinEcr, "99/99/9999"), string(viNoMdtTrv))).
            return.
        end.
    end.

    if plNouvTrimesDecalePartielFinAnnee <> plAncTrimesDecalePartielFinAnnee
    and plNouvTrimesDecalePartielFinAnnee = yes
    then do:
        for each ctrat no-lock
           where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
             and (ctrat.dtree = ? or ctrat.dtree > today)
         , last tache no-lock
           where tache.tpcon = ctrat.tpcon
             and tache.nocon = ctrat.nocon
             and tache.tptac = {&TYPETACHE-compteRenduGestion}
             and (tache.pdges = {&PERIODICITEGESTION-trimestrielFevAvril} or tache.pdges = {&PERIODICITEGESTION-trimestrielMarsMai})
         , last vbtache no-lock
           where vbtache.tpcon = ctrat.tpcon
             and vbtache.nocon = ctrat.nocon
             and vbtache.tptac = {&TYPETACHE-Honoraires}
             and vbtache.pdges <> {&PERIODICITEHONORAIRES-mensuel}
             and vbtache.pdges <> "00000":
            viNbHonDec = viNbHonDec + 1.
            /* on affichera les 5 premiers */
            if viNbHonDec < 5 then vcLsHonDec = vcLsHonDec + "," + string(ctrat.nocon).
        end.
        vcLsHonDec = trim(vcLsHonDec, ",").
        if viNbHonDec <> 0
        then mError:createErrorGestion({&information}, 109881, substitute('&2&1&3', separ[1], string(viNbHonDec), vcLsHonDec + (if viNbHonDec > num-entries( vcLsHonDec, "," ) then "..." else ""))).
    end.

end procedure.

procedure completeParamCrg:
    /*------------------------------------------------------------------------------
    Purpose: pour completer la table initialisee avec les parametres CRG de l'ecran parametre defaut mandat
             avec les parametres de l'ecran parameter crg
    Notes  : service externe (defautMandatGestion.p)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttParamCrg.

    run lectureParamCrg.

end procedure.
