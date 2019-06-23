/*------------------------------------------------------------------------
File        : defautMandatGerance.p
Purpose     : Paramètres par défaut du mandat de gérance
Author(s)   : OFA  2017/10
Notes       : reprise pgm adb/prmcl/pcldefma.p
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametrageDossierMandat.
using parametre.syspg.syspg.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gerance/include/paramChargeLocative.i}
{parametre/cabinet/gerance/include/paramCommentaire.i}
{parametre/cabinet/gerance/include/paramCommercial.i}
{parametre/cabinet/gerance/include/paramDossierMandat.i}
{parametre/cabinet/gerance/include/paramGeneraux.i}
{parametre/cabinet/gerance/include/paramCrg.i}
{parametre/cabinet/gerance/include/paramCrl.i}
{parametre/cabinet/gerance/include/paramDas2.i}
{parametre/cabinet/gerance/include/paramDepotGarantie.i}
{parametre/cabinet/gerance/include/paramHonoraireGestion.i}
{parametre/cabinet/gerance/include/paramIrf.i}
{parametre/cabinet/gerance/include/paramIsf.i}
{parametre/cabinet/gerance/include/paramTva.i}

{adblib/include/pclie.i}

{application/include/glbsepar.i}
{application/include/combo.i}
{application/include/error.i}

define variable ghHonor as handle no-undo.

function typeHonoraire returns character private (pcTypeTache as character):
    /*------------------------------------------------------------------------------
     Purpose: retourne type honoraire selon tache
     Notes:
    ------------------------------------------------------------------------------*/    
    define buffer sys_pg for sys_pg.

    for first sys_pg no-lock
        where sys_pg.tppar = "R_TTH"
          and sys_pg.zone1 = pcTypeTache:
        return sys_pg.zone2. 
    end.
    return "".

end function.

function initDepuisCombo returns character private (pcNomCombo as character):
    /*------------------------------------------------------------------------------
     Purpose: retourne premier element d'une combo
     Notes:
    ------------------------------------------------------------------------------*/    
    for first ttCombo 
        where ttCombo.cNomCombo = pcNomCombo:
        return ttCombo.cCode.
    end.
    return "".

end function.

procedure getParamChargeLocative:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres charge locative par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamChargeLocative.
    empty temp-table ttCombo.
    empty temp-table ttParamChargeLocative.
    run lectureParamChargeLocative.

end procedure.

procedure getParamCommentaire:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres commentaire par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamCommentaire.
    empty temp-table ttParamCommentaire.  
    run lectureParamCommentaire.

end procedure.

procedure getParamCommercial:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres commercial par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamCommercial.
    empty temp-table ttParamCommercial.     
    run lectureParamCommercial. 

end procedure.

procedure getParamDossierMandat:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres dossier mandat par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamDossierMandat.
    define output parameter table for ttParamListeDossierMandat.
    empty temp-table ttParamDossierMandat.
    empty temp-table ttParamListeDossierMandat.
    run lectureParamDossierMandat. 

end procedure.

procedure getParamGeneraux:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres generaux par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamGeneraux.
    empty temp-table ttParamGeneraux.
    empty temp-table ttCombo.
    run lectureParamGeneraux. 

end procedure.

procedure getParamCrg:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres crg par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamCrg.
    define variable vhproc as handle no-undo. 
    empty temp-table ttParamCrg.
    empty temp-table ttCombo.
    run lectureParamCrg. 
    //appel pour completer la table avec les autre parametres CRG (de l'ecran parametre crg)
    run parametre/cabinet/gerance/paramCrg.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run completeParamCrg in vhproc (input-output table ttParamCrg by-reference).
    run destroy in vhproc.

end procedure.

procedure getParamCrl:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres crl par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamCrl.
    empty temp-table ttParamCrl.
    empty temp-table ttCombo.
    run lectureParamCrl. 

end procedure.

procedure getParamDas2:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres das2 par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamDas2.

    empty temp-table ttParamDas2.
    run lectureParamDas2. 

end procedure.

procedure getParamDepotGarantie:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres depot de garantie par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamDepotGarantie.
    empty temp-table ttParamDepotGarantie.
    empty temp-table ttCombo.
    run lectureParamDepotGarantie. 

end procedure.

procedure getParamHonoraireGestion:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres honoraire de gestion par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamHonoraireGestion.
    empty temp-table ttParamHonoraireGestion.    
    empty temp-table ttCombo.
    run lectureParamHonoraireGestion. 

end procedure.

procedure getParamIrf:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres irf par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamIrf.
    empty temp-table ttParamIrf.     
    empty temp-table ttCombo.
    run lectureParamIrf. 

end procedure.

procedure getParamIsf:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres isf par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamIsf.
    empty temp-table ttParamIsf.     
    empty temp-table ttCombo.
    run lectureParamIsf. 

end procedure.

procedure getParamTva:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres tva par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamTva.
    empty temp-table ttParamTva.     
    empty temp-table ttCombo.
    run lectureParamTva. 

end procedure.

procedure getCombo:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des combos en fonction du type en entree
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCombo as character no-undo.
    define output parameter table for ttCombo.
    run chargeCombo(pcTypeCombo).

end procedure.

procedure setParamChargeLocative:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres charge locative par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamChargeLocative.
    if can-find(first ttParamChargeLocative where ttParamChargeLocative.CRUD = "U")
    then run SavEcrPrm.

end procedure.

procedure setParamCommentaire:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres commentaire par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamCommentaire.
    if can-find(first ttParamCommentaire where ttParamCommentaire.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamCommercial:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres commercial par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamCommercial.
    if can-find(first ttParamCommercial where ttParamCommercial.CRUD = "U")        
    then run SavEcrPrm.

end procedure.

procedure setParamDossierMandat:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres dossier mandat par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamDossierMandat.
    define input parameter table for ttParamListeDossierMandat.
 
    define variable vcTempActTch       as character no-undo. 
    define variable vlParametrageActif as logical   no-undo. 
    define variable voDefautMandat     as class parametrageDefautMandat  no-undo.
    define variable voDossierMandat    as class parametrageDossierMandat no-undo.

    run VerZonSai.
    if mError:erreur() then return.

    if can-find(first ttParamDossierMandat where ttParamDossierMandat.CRUD = "U")  
    then run savEcrPrm.
    if can-find(first ttParamListeDossierMandat where lookup(ttParamListeDossierMandat.CRUD, "C,U,D") > 0)     
    then run Crepclie.

    // controle coherence entre parametrage actif et liste des dossiers apres la maj 
    if can-find(first ttParamDossierMandat where ttParamDossierMandat.CRUD = "U")  
    or can-find(first ttParamListeDossierMandat where lookup(ttParamListeDossierMandat.CRUD, "C,U,D") > 0)
    then do: 
        voDefautMandat = new parametrageDefautMandat().  // attention, pas avant car modif enregistrement pclie
        if voDefautMandat:getDossierMandatParametrageActif()
        then do:
            voDossierMandat = new parametrageDossierMandat().
            if not voDossierMandat:isDbParameter or voDossierMandat:zon02 = ""
            /* Pour utiliser la tache <Dossier mandat> vous devez définir les pièces à fournir */
            then mError:createError({&error}, 109732). 
        end.
    end.    
    delete object voDossierMandat no-error.
    delete object voDefautMandat  no-error.
end procedure.

procedure setParamGeneraux:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres generaux par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamGeneraux.
    
    run VerZonSai.
    if mError:erreur() then return.

    if can-find(first ttParamGeneraux where ttParamGeneraux.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamCrg:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres crg par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamCrg.
    
    run VerZonSai.
    if mError:erreur() then return.

    if can-find(first ttParamCrg where ttParamCrg.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamCrl:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres crl par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamCrl.

    if can-find(first ttParamCrl where ttParamCrl.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamDas2:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres das2 par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamDas2.
    
    run VerZonSai.
    if mError:erreur() then return.

    if can-find(first ttParamDas2 where ttParamDas2.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamDepotGarantie:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres depot de garantie par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamDepotGarantie.

    if can-find(first ttParamDepotGarantie where ttParamDepotGarantie.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamHonoraireGestion:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres honoraire de gestion par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamHonoraireGestion.
    
    if can-find(first ttParamHonoraireGestion where ttParamHonoraireGestion.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamIrf:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres irf par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamIrf.
 
    if can-find(first ttParamIrf where ttParamIrf.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamIsf:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres isf par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamIsf.

    if can-find(first ttParamIsf where ttParamIsf.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure setParamTva:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètres tva par défaut du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamTva.
    
    run VerZonSai.
    if mError:erreur() then return.

    if can-find(first ttParamTva where ttParamTva.CRUD = "U")    
    then run SavEcrPrm.

end procedure.

procedure lectureParamChargeLocative private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres charge locative par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("CHARGELOCATIVE").
    create ttParamChargeLocative. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamChargeLocative.CRUD                     = 'R'
        ttParamChargeLocative.cTypeTache               = voDefautMandat:getChargeLocativeTypeTache()
        ttParamChargeLocative.cCodePresentation        = voDefautMandat:getChargeLocativeCodePresentation()
        ttParamChargeLocative.cCodeRepartition         = voDefautMandat:getChargeLocativeCodeRepartition()
        ttParamChargeLocative.lIntegrationDirectCompta = voDefautMandat:getChargeLocativeIntegrationDirectCompta() 
        ttParamChargeLocative.lParametrageActif        = voDefautMandat:getChargeLocativeParametrageActif()
        ttParamChargeLocative.lActivation              = voDefautMandat:getChargeLocativeActivation()
    .
    else assign
        ttParamChargeLocative.lParametrageActif        = no                                 
        ttParamChargeLocative.lActivation              = no
        ttParamChargeLocative.cCodePresentation        = initDepuisCombo("CHARGE-PRESENTATION")
        ttParamChargeLocative.cCodeRepartition         = initDepuisCombo("CHARGE-REPARTITION")
        ttParamChargeLocative.lIntegrationDirectCompta = no    
    .
    assign
        ttParamChargeLocative.cLibellePresentation = outilTraduction:getLibelleParam("CDCUM", ttParamChargeLocative.cCodePresentation)
        ttParamChargeLocative.cLibelleRepartition  = outilTraduction:getLibelleParam("CDLOT", ttParamChargeLocative.cCodeRepartition)        
    .
    delete object voDefautMandat.
end procedure.

procedure lectureParamCommentaire private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres commentaire par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    create ttParamCommentaire. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamCommentaire.CRUD              = 'R'
        ttParamCommentaire.cTypeTache        = voDefautMandat:getCommentaireTypeTache()
        ttParamCommentaire.lParametrageActif = voDefautMandat:getCommentaireParametrageActif()
        ttParamCommentaire.lActivation       = voDefautMandat:getCommentaireActivation()
        ttParamCommentaire.lAutomatique      = voDefautMandat:getCommentaireAutomatique()
    .
    else assign
        ttParamCommentaire.lParametrageActif = no
        ttParamCommentaire.lActivation       = no
        ttParamCommentaire.lAutomatique      = no
    .
    delete object voDefautMandat.
end procedure.

procedure lectureParamCommercial private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres commercial par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    create ttParamCommercial. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamCommercial.CRUD              = 'R'
        ttParamCommercial.cTypeTache        = voDefautMandat:getCommercialTypeTache()
        ttParamCommercial.lParametrageActif = voDefautMandat:getCommercialParametrageActif()
        ttParamCommercial.lActivation       = voDefautMandat:getCommercialActivation()
        ttParamCommercial.lAutomatique      = voDefautMandat:getCommercialAutomatique()
    .
    else assign
        ttParamCommercial.lParametrageActif = no    
        ttParamCommercial.lActivation       = no
        ttParamCommercial.lAutomatique      = no   
    .
    delete object voDefautMandat.
end procedure.

procedure lectureParamDossierMandat private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres dossier mandat par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.
    define variable viNbPieDos   as integer   no-undo.
    define buffer pclie for pclie.

    voDefautMandat = new parametrageDefautMandat().
    create ttParamDossierMandat. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamDossierMandat.CRUD                     = 'R'
        ttParamDossierMandat.cTypeTache               = voDefautMandat:getDossierMandatTypeTache()
        ttParamDossierMandat.lParametrageActif        = voDefautMandat:getDossierMandatParametrageActif()
        ttParamDossierMandat.lActivation              = voDefautMandat:getDossierMandatActivation()
        ttParamDossierMandat.lAutomatique             = voDefautMandat:getDossierMandatAutomatique()
        ttParamDossierMandat.lReglementChargeAuSyndic = voDefautMandat:getDossierMandatChargeSyndic()
    .
    else assign
        ttParamDossierMandat.lParametrageActif        = no
        ttParamDossierMandat.lActivation              = no
        ttParamDossierMandat.lAutomatique             = no
        ttParamDossierMandat.lReglementChargeAuSyndic = no
    .
    delete object voDefautMandat.

    for first pclie no-lock
        where pclie.tppar = "DOMDT":
        do viNbPieDos = 1 to pclie.int01: 
            create ttParamListeDossierMandat.   
            assign   
                ttParamListeDossierMandat.CRUD              = 'R'
                ttParamListeDossierMandat.iNumeroPiece      = integer(entry(viNbPieDos, pclie.zon02, separ[1]))
                ttParamListeDossierMandat.cLibellePiece     = entry(viNbPieDos, pclie.zon03,separ[1])
                ttParamListeDossierMandat.lPieceObligatoire = (entry(viNbPieDos, pclie.Zon04, separ[1]) = "00001")
            .
        end.
    end.

end procedure.

procedure lectureParamGeneraux private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres generaux par défaut du mandat de gérance
    Notes  :  
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("GENERAUX").
    create ttParamGeneraux. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamGeneraux.CRUD                    = 'R'
        ttParamGeneraux.iDureeMandat            = voDefautMandat:getGenerauxDuree()
        ttParamGeneraux.cCodeDureeMandat        = voDefautMandat:getGenerauxUniteDuree()
        ttParamGeneraux.iDelaiPreavis           = voDefautMandat:getGenerauxDelaiResiliation()
        ttParamGeneraux.cCodeDelaiPreavis       = voDefautMandat:getGenerauxUniteDelaiResiliation()
        ttParamGeneraux.cCodeRepartitionTerme   = voDefautMandat:getGenerauxCodeRepartitionTerme()
        ttParamGeneraux.lEtionFicheFinPec       = voDefautMandat:getGenerauxFicheFinPec()
        ttParamGeneraux.lModifAutoReglementProp = voDefautMandat:getGenerauxModifAuto()
    .
    else assign 
        ttParamGeneraux.iDureeMandat            = 1
        ttParamGeneraux.cCodeDureeMandat        = initDepuisCombo("GENERAUX-DUREE")
        ttParamGeneraux.iDelaiPreavis           = 3
        ttParamGeneraux.cCodeDelaiPreavis       = "00002"   
        ttParamGeneraux.cCodeRepartitionTerme   = initDepuisCombo("GENERAUX-REPARTITION")  
        ttParamGeneraux.lEtionFicheFinPec       = no
        ttParamGeneraux.lModifAutoReglementProp = no
    .
    assign
        ttParamGeneraux.cLibelleDureeMandat      = outilTraduction:getLibelleParam("UTDUR", ttParamGeneraux.cCodeDureeMandat)
        ttParamGeneraux.cLibelleDelaiPreavis     = outilTraduction:getLibelleParam("UTDUR", ttParamGeneraux.cCodeDelaiPreavis)
        ttParamGeneraux.cLibelleRepartitionTerme = outilTraduction:getLibelleParam("CDA_S", ttParamGeneraux.cCodeRepartitionTerme)
    .
    delete object voDefautMandat.
end procedure.

procedure lectureParamCrg private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres crg par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("CRG").
    find first ttParamCrg no-error.                 //si on vient de paramCrg.p, l'enregistrement existe deja, c'est pour completer 
    if not available ttParamCrg
    then create ttParamCrg.
    if voDefautMandat:isDbParameter
    then assign
        ttParamCrg.CRUD                          = 'R'
        ttParamCrg.cTypeTache                    = voDefautMandat:getCRGTypeTache()
        ttParamCrg.lParametrageActif             = voDefautMandat:getCRGParametrageActif()
        ttParamCrg.lActivation                   = voDefautMandat:getCRGActivation()
        ttParamCrg.lAutomatique                  = voDefautMandat:getCRGAutomatique()
        ttParamCrg.cCodePresentationCrg          = voDefautMandat:getCRGCodePresentation()
        ttParamCrg.cCodePeriodicite              = voDefautMandat:getCRGCodePeriodicite()
        ttParamCrg.cCodeTraitementAvisEcheance   = voDefautMandat:getCRGAvisEcheance()
        ttParamCrg.lPresentationDetailCalculHono = voDefautMandat:getCRGPresentationHono()
    .
    else assign
        ttParamCrg.lParametrageActif             = no
        ttParamCrg.lActivation                   = no
        ttParamCrg.lAutomatique                  = no 
        ttParamCrg.cCodePresentationCrg          = initDepuisCombo("CRG-PRESENTATION")
        ttParamCrg.cCodePeriodicite              = initDepuisCombo("CRG-PERIODICITE")
        ttParamCrg.cCodeTraitementAvisEcheance   = "00004"
        ttParamCrg.lPresentationDetailCalculHono = can-find(first aparm no-lock
                                                            where aparm.tppar = "THONO"
                                                              and aparm.cdpar = "AFCRG"
                                                              and aparm.zone2 = "OUI")
    .
    assign
        ttParamCrg.cLibellePresentationCrg        = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-compteRenduGestion}, ttParamCrg.cCodePresentationCrg)
        ttParamCrg.cLibellePeriodicite            = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-compteRenduGestion}, ttParamCrg.cCodePeriodicite)
        ttParamCrg.cLibelleTraitementAvisEcheance = outilTraduction:getLibelleParam("TRTEC", ttParamCrg.cCodeTraitementAvisEcheance) 
    .
    delete object voDefautMandat.
end procedure.

procedure lectureParamCrl private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres crl par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("CRL").
    create ttParamCrl.
    if voDefautMandat:isDbParameter
    then assign
        ttParamCrl.CRUD              = 'R'
        ttParamCrl.cTypeTache        = voDefautMandat:getCRLTypeTache()
        ttParamCrl.lParametrageActif = voDefautMandat:getCRLParametrageActif()
        ttParamCrl.lActivation       = voDefautMandat:getCRLActivation()
        ttParamCrl.cCodeEncaissement = voDefautMandat:getCRLCodeEncaissement()
        ttParamCrl.cCodeDeclaration  = voDefautMandat:getCRLCodeDeclaration()
        ttParamCrl.cCodePeriode      = voDefautMandat:getCRLCodePeriode()
        ttParamCrl.lComptabilisation = voDefautMandat:getCRLComptabilisation()
        ttParamCrl.cCodeHonoraire    = voDefautMandat:getCRLCodeHonoraire()
    .
    else assign
        ttParamCrl.lParametrageActif = no                              
        ttParamCrl.lActivation       = no 
        ttParamCrl.cCodeEncaissement = initDepuisCombo("CRL-ENCAISSEMENT") 
        ttParamCrl.cCodeDeclaration  = initDepuisCombo("CRL-DECLARATION") 
        ttParamCrl.cCodePeriode      = "20006"
        ttParamCrl.lComptabilisation = yes
    .
    assign
        ttParamCrl.cLibelleEncaissement = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-CRL}, ttParamCrl.cCodeEncaissement)
        ttParamCrl.cLibelleDeclaration  = outilTraduction:getLibelleProgZone2("R_TAD", {&TYPETACHE-CRL}, ttParamCrl.cCodeDeclaration)
        ttParamCrl.cLibellePeriode      = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-CRL}, ttParamCrl.cCodePeriode)
    .
    delete object voDefautMandat.
end procedure.

procedure lectureParamDas2 private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres das2 par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    create ttParamDas2. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamDas2.CRUD              = 'R'
        ttParamDas2.cTypeTache        = voDefautMandat:getDAS2TypeTache()
        ttParamDas2.lParametrageActif = voDefautMandat:getDAS2ParametrageActif()
        ttParamDas2.lActivation       = voDefautMandat:getDAS2Activation()
        ttParamDas2.lAutomatique      = voDefautMandat:getDAS2Automatique()
        ttParamDas2.lDeclaration      = voDefautMandat:getDAS2Comptabilisation()
        ttParamDas2.cCodeHonoraire    = voDefautMandat:getDAS2CodeHonoraire()
    .
    else assign
        ttParamDas2.lParametrageActif = no
        ttParamDas2.lActivation       = no
        ttParamDas2.lAutomatique      = no 
        ttParamDas2.lDeclaration      = yes
        ttParamDas2.cCodeHonoraire    = initDepuisCombo("DAS2-LISTEHONORAIRE")    
    .
    delete object voDefautMandat.
end procedure.

procedure lectureParamDepotGarantie private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres depot de garantie par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("DEPOTGARANTIE").  
    create ttParamDepotGarantie. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamDepotGarantie.CRUD               = 'R'
        ttParamDepotGarantie.cTypeTache         = voDefautMandat:getDepotGarantieTypeTache()
        ttParamDepotGarantie.lParametrageActif  = voDefautMandat:getDepotGarantieParametrageActif()
        ttParamDepotGarantie.lActivation        = voDefautMandat:getDepotGarantieActivation()
        ttParamDepotGarantie.lAutomatique       = voDefautMandat:getDepotGarantieAutomatique()
        ttParamDepotGarantie.cCodeDepotGarantie = voDefautMandat:getDepotGarantieCode()
    .
    else assign
        ttParamDepotGarantie.lParametrageActif  = no
        ttParamDepotGarantie.lActivation        = no
        ttParamDepotGarantie.lAutomatique       = no
        ttParamDepotGarantie.cCodeDepotGarantie = initDepuisCombo("DEPOT-DEPOTGARANTIE")
    . 
    ttParamDepotGarantie.cLibelleDepotGarantie = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-depotGarantieMandat}, ttParamDepotGarantie.cCodeDepotGarantie).     
    delete object voDefautMandat.
end procedure.

procedure lectureParamHonoraireGestion private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres honoraire de gestion par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("HONORAIREGESTION").
    create ttParamHonoraireGestion. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamHonoraireGestion.CRUD               = 'R'
        ttParamHonoraireGestion.cTypeTache         = voDefautMandat:getHonoraireGestionTypeTache()
        ttParamHonoraireGestion.lParametrageActif  = voDefautMandat:getHonoraireGestionParametrageActif()
        ttParamHonoraireGestion.lActivation        = voDefautMandat:getHonoraireGestionActivation()
        ttParamHonoraireGestion.lAutomatique       = voDefautMandat:getHonoraireGestionAutomatique()
        ttParamHonoraireGestion.cCodePeriodeCalcul = voDefautMandat:getHonoraireGestionCodePeriode()
        ttParamHonoraireGestion.cCodeHonoraire     = voDefautMandat:getHonoraireGestionCodeHonoraire()
        ttParamHonoraireGestion.cCodeFrais         = voDefautMandat:getHonoraireGestionCodeFrais()
    .
    else assign
        ttParamHonoraireGestion.lParametrageActif  = no                               
        ttParamHonoraireGestion.lActivation        = no
        ttParamHonoraireGestion.lAutomatique       = no
        ttParamHonoraireGestion.cCodePeriodeCalcul = initDepuisCombo("HONORAIRE-PERIODE")
        ttParamHonoraireGestion.cCodeHonoraire     = initDepuisCombo("HONORAIRE-LISTEHONORAIRE")  
        ttParamHonoraireGestion.cCodeFrais         = initDepuisCombo("HONORAIRE-LISTEFRAIS")  
    .
    ttParamHonoraireGestion.cLibellePeriodeCalcul = outilTraduction:getLibelleProg("O_PDH", ttParamHonoraireGestion.cCodePeriodeCalcul, "c").
    delete object voDefautMandat.
end procedure.

procedure lectureParamIrf private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres irf par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("IRF").
    create ttParamIrf. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamIrf.CRUD                           = 'R'
        ttParamIrf.cTypeTache                     = voDefautMandat:getIRFTypeTache()
        ttParamIrf.lParametrageActif              = voDefautMandat:getIRFParametrageActif()
        ttParamIrf.lActivation                    = voDefautMandat:getIRFActivation()
        ttParamIrf.lAutomatique                   = voDefautMandat:getIRFAutomatique()
        ttParamIrf.cCodeDeclaration               = voDefautMandat:getIRFCodeDeclaration()
        ttParamIrf.lDeclaration2072               = voDefautMandat:getIRFDeclaration2072()
        ttParamIrf.lMicroFoncier                  = voDefautMandat:getIRFMicroFoncier()
        ttParamIrf.lCalculTvaProratee             = voDefautMandat:getIRFTVAProratee()
        ttParamIrf.lCalculAutoProrataMandant      = voDefautMandat:getIRFProrataMandant()
        ttParamIrf.cCodeHonoraire                 = voDefautMandat:getIRFCodeHonoraire()
        ttParamIrf.dDeductForfaitaireFraisGestion = voDefautMandat:getIRFDeductionFrais()
        ttParamIrf.dTauxDeductionMicrofoncier     = voDefautMandat:getIRFTauxDeductionMicro()
    .
    else assign
        ttParamIrf.lParametrageActif              = no                               
        ttParamIrf.lActivation                    = no
        ttParamIrf.lAutomatique                   = no
        ttParamIrf.cCodeDeclaration               = initDepuisCombo("IRF-DECLARATION")
        ttParamIrf.lDeclaration2072               = no
        ttParamIrf.lMicroFoncier                  = no
        ttParamIrf.lCalculTvaProratee             = yes
        ttParamIrf.lCalculAutoProrataMandant      = yes
        ttParamIrf.cCodeHonoraire                 = initDepuisCombo("IRF-LISTEHONORAIRE")  
        ttParamIrf.dDeductForfaitaireFraisGestion = 20       
        ttParamIrf.dTauxDeductionMicrofoncier     = 30     
    .  
    ttParamIrf.cLibelleDeclaration = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-ImpotRevenusFonciers}, ttParamIrf.cCodeDeclaration).
    delete object voDefautMandat.
end procedure.

procedure lectureParamIsf private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres isf par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("ISF").
    create ttParamIsf.
    if voDefautMandat:isDbParameter
    then assign
        ttParamIsf.CRUD               = 'R'
        ttParamIsf.cTypeTache         = voDefautMandat:getISFTypeTache()
        ttParamIsf.lParametrageActif  = voDefautMandat:getISFParametrageActif()
        ttParamIsf.lActivation        = voDefautMandat:getISFActivation()
        ttParamIsf.lAutomatique       = voDefautMandat:getISFAutomatique()
        ttParamIsf.cCodeDeclaration   = voDefautMandat:getISFCodeDeclaration()
        ttParamIsf.cCodePeriode       = voDefautMandat:getISFCodePeriode()
        ttParamIsf.cCodeHonoraire     = voDefautMandat:getISFCodeHonoraire()
    .
    else assign
        ttParamIsf.lParametrageActif  = no                                
        ttParamIsf.lActivation        = no
        ttParamIsf.lAutomatique       = no 
        ttParamIsf.cCodeDeclaration   = initDepuisCombo("ISF-DECLARATION")
        ttParamIsf.cCodePeriode       = initDepuisCombo("ISF-PERIODE")
        ttParamIsf.cCodeHonoraire     = initDepuisCombo("ISF-LISTEHONORAIRE")  
    .
    assign
        ttParamIsf.cLibelleDeclaration = outilTraduction:getLibelleProgZone2("R_TAD", {&TYPETACHE-ImpotSolidariteFortune}, ttParamIsf.cCodeDeclaration)
        ttParamIsf.cLibellePeriode     = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-ImpotSolidariteFortune}, ttParamIsf.cCodePeriode)    
    .
    delete object voDefautMandat.
end procedure.

procedure lectureParamTva private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des paramètres tva par défaut du mandat de gérance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    run chargeCombo("TVA").
    create ttParamTva. 
    if voDefautMandat:isDbParameter
    then assign
        ttParamTva.CRUD                 = 'R'
        ttParamTva.cTypeTache           = voDefautMandat:getTVATypeTache()
        ttParamTva.lParametrageActif    = voDefautMandat:getTVAParametrageActif()
        ttParamTva.lActivation          = voDefautMandat:getTVAActivation()
        ttParamTva.cCodeRegime          = voDefautMandat:getTVACodeRegime()
        ttParamTva.cCodeDeclaration     = voDefautMandat:getTVACodeDeclaration()
        ttParamTva.cCodePeriode         = voDefautMandat:getTVACodePeriode()
        ttParamTva.lReglement           = voDefautMandat:getTVAReglement()
        ttParamTva.cCodeConserve        = voDefautMandat:getTVACodeConserve()
        ttParamTva.iProrataNumerateur   = voDefautMandat:getTVAProrataNumerateur()
        ttParamTva.iProrataDenominateur = voDefautMandat:getTVAProrataDenominateur()
        ttParamTva.cCodeRecette         = voDefautMandat:getTVACodeRecette()
        ttParamTva.cCodeDepense         = voDefautMandat:getTVACodeDepense()
        ttParamTva.cCodeHonoraire       = voDefautMandat:getTVACodeHonoraire()
    .
    else assign
        ttParamTva.lParametrageActif    = no                                
        ttParamTva.lActivation          = no 
        ttParamTva.cCodeRegime          = initDepuisCombo("TVA-REGIME")
        ttParamTva.cCodeDeclaration     = initDepuisCombo("TVA-DECLARATION")
        ttParamTva.cCodePeriode         = initDepuisCombo("TVA-PERIODE")
        ttParamTva.lReglement           = yes
        ttParamTva.cCodeConserve        = initDepuisCombo("TVA-CONSERVE")
        ttParamTva.iProrataDenominateur = 100
        ttParamTva.iProrataNumerateur   = 100
        ttParamTva.cCodeRecette         = initDepuisCombo("TVA-RECETTE")
        ttParamTva.cCodeDepense         = initDepuisCombo("TVA-DEPENSE")
        ttParamTva.cCodeHonoraire       = initDepuisCombo("TVA-LISTEHONORAIRE")  
    .
    assign
        ttParamTva.cLibelleRegime      = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-Tva}, ttParamTva.cCodeRegime)
        ttParamTva.cLibelleDeclaration = outilTraduction:getLibelleProgZone2("R_TAD", {&TYPETACHE-Tva}, ttParamTva.cCodeDeclaration)
        ttParamTva.cLibellePeriode     = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-Tva}, ttParamTva.cCodePeriode)
        ttParamTva.cLibelleRecette     = (if ttParamTva.cCodeRecette  = "1" then outilTraduction:getLibelle(100169) /*Débit*/    else outilTraduction:getLibelle(701217) /*Encaissement*/ )
        ttParamTva.cLibelleDepense     = (if ttParamTva.cCodeDepense  = "1" then outilTraduction:getLibelle(100169) /*Débit*/    else outilTraduction:getLibelle(103781) /*Décaissement*/ )
        ttParamTva.cLibelleConserve    = (if ttParamTva.cCodeConserve = "1" then outilTraduction:getLibelle(701268) /*Conservé*/ else outilTraduction:getLibelle(701270) /*Reversé*/ )
    .  
    delete object voDefautMandat.
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCombo as character no-undo.
    
    define variable voSyspg as class syspg  no-undo.
    define variable voSyspr as class syspr  no-undo.
    define variable viNumeroItem as integer no-undo.

    case pcTypeCombo:
        when 'CHARGELOCATIVE' then do:
            voSyspr = new syspr().
            voSyspr:getComboParametre("CDCUM", "CHARGE-PRESENTATION", output table ttCombo by-reference).
            voSyspr:getComboParametre("CDLOT", "CHARGE-REPARTITION" , output table ttCombo by-reference).
        end.
        when 'GENERAUX' then do:
            voSyspr = new syspr().
            voSyspr:getComboParametre("UTDUR", "GENERAUX-DUREE"      , output table ttCombo by-reference).
            voSyspr:getComboParametre("UTDUR", "GENERAUX-DELAI"      , output table ttCombo by-reference).
            voSyspr:getComboParametre("CDA_S", "GENERAUX-REPARTITION", output table ttCombo by-reference).
            for first ttCombo
                where ttCombo.cNomCombo = "GENERAUX-DELAI"
                  and ttCombo.cCode     = "00001":
                delete ttCombo.
            end.
        end.
        when 'CRG' then do:
            voSyspg = new syspg().
            voSyspg:creationComboSysPgZonXX("R_TAG", "CRG-PRESENTATION", "C", {&TYPETACHE-compteRenduGestion}, output table ttCombo by-reference).
            voSyspg:creationComboSysPgZonXX("R_TPR", "CRG-PERIODICITE" , "C", {&TYPETACHE-compteRenduGestion}, output table ttCombo by-reference).
            voSyspr = new syspr().
            voSyspr:getComboParametre("TRTEC", "CRG-TRTAVISECHEANCE", output table ttCombo by-reference).
        end.    
        when 'CRL' then do:
            voSyspg = new syspg().
            voSyspg:creationComboSysPgZonXX("R_TAG", "CRL-ENCAISSEMENT", "C", {&TYPETACHE-CRL}, output table ttCombo by-reference).
            voSyspg:creationComboSysPgZonXX("R_TAD", "CRL-DECLARATION" , "C", {&TYPETACHE-CRL}, output table ttCombo by-reference).
            voSyspg:creationComboSysPgZonXX("R_TPR", "CRL-PERIODE"     , "C", {&TYPETACHE-CRL}, output table ttCombo by-reference).
            for each ttCombo                                    //Période CRL toujours Fiscale (pas de maj possible)
                where ttCombo.cNomCombo = "CRL-PERIODE"
                  and ttCombo.cCode <> "20006":
                delete ttCombo.
            end.
            run ChgCodHon ({&TYPETACHE-CRL}, "CRL-LISTEHONORAIRE").
        end.  
        when 'DAS2' then run ChgCodHon ({&TYPETACHE-Das2Gerance}, "DAS2-LISTEHONORAIRE").             
        when 'DEPOTGARANTIE' then do:
            voSyspg = new syspg().
            voSyspg:creationComboSysPgZonXX("R_TAG", "DEPOT-DEPOTGARANTIE", "C", {&TYPETACHE-depotGarantieMandat}, output table ttCombo by-reference).
        end.    
        when 'HONORAIREGESTION' then do:
            voSyspg = new syspg().
            voSyspg:getComboParametre("O_PDH", "HONORAIRE-PERIODE", output table ttCombo by-reference).
            run ChgCodHon ({&TYPETACHE-Honoraires}  , "HONORAIRE-LISTEHONORAIRE").
            run ChgCodHon ({&TYPETACHE-fraisGestion}, "HONORAIRE-LISTEFRAIS"    ).
        end.    
        when 'IRF' then do:
            voSyspg = new syspg().
            voSyspg:creationComboSysPgZonXX("R_TAG", "IRF-DECLARATION", "C", {&TYPETACHE-ImpotRevenusFonciers}, output table ttCombo by-reference).
            run ChgCodHon ({&TYPETACHE-ImpotRevenusFonciers}, "IRF-LISTEHONORAIRE").             
        end.    
        when 'ISF' then do:
            voSyspg = new syspg().
            voSyspg:creationComboSysPgZonXX("R_TAD", "ISF-DECLARATION", "C", {&TYPETACHE-ImpotSolidariteFortune}, output table ttCombo by-reference).
            voSyspg:creationComboSysPgZonXX("R_TPR", "ISF-PERIODE"    , "C", {&TYPETACHE-ImpotSolidariteFortune}, output table ttCombo by-reference).
            run ChgCodHon ({&TYPETACHE-ImpotSolidariteFortune}, "ISF-LISTEHONORAIRE").             
        end.    
        when 'TVA' then do:
            voSyspg = new syspg().
            voSyspg:creationComboSysPgZonXX("R_TAG", "TVA-REGIME",      "C", {&TYPETACHE-Tva}, output table ttCombo by-reference).
            voSyspg:creationComboSysPgZonXX("R_TAD", "TVA-DECLARATION", "C", {&TYPETACHE-Tva}, output table ttCombo by-reference).
            voSyspg:creationComboSysPgZonXX("R_TPR", "TVA-PERIODE",     "C", {&TYPETACHE-Tva}, output table ttCombo by-reference).
            voSyspg:creationttCombo("TVA-CONSERVE", "1", outilTraduction:getLibelle(701268), output table ttCombo by-reference).  //Conservé
            voSyspg:creationttCombo("TVA-CONSERVE", "2", outilTraduction:getLibelle(701270), output table ttCombo by-reference).  //Reversé
            voSyspg:creationttCombo("TVA-RECETTE",  "1", outilTraduction:getLibelle(100169), output table ttCombo by-reference).  //Débit
            voSyspg:creationttCombo("TVA-RECETTE",  "2", outilTraduction:getLibelle(701217), output table ttCombo by-reference). //Encaissement
            voSyspg:creationttCombo("TVA-DEPENSE",  "1", outilTraduction:getLibelle(100169), output table ttCombo by-reference).  //Débit
            voSyspg:creationttCombo("TVA-DEPENSE",  "2", outilTraduction:getLibelle(103781), output table ttCombo by-reference). //Décaissement
            run ChgCodHon ({&TYPETACHE-Tva}, "TVA-LISTEHONORAIRE").
        end.
    end case.
    if valid-handle(ghHonor) then run destroy in ghHonor.
    if valid-object(voSyspg) then delete object voSyspg.
    if valid-object(voSyspr) then delete object voSyspr.

end procedure.

procedure ChgCodHon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTache as character no-undo.
    define input parameter pcNomCombo  as character no-undo.

    define variable viNumeroCombo as integer no-undo.
    define buffer sys_pg for sys_pg.
    
    for first sys_pg no-lock
        where sys_pg.tppar = "R_TTH"
          and sys_pg.zone1 = pcTypeTache
          and sys_pg.zone2 > "":
        if not valid-handle(ghHonor)
        then do:
            run tache/baremeHonoraire.p persistent set ghHonor.
            run getTokenInstance in ghHonor(mToken:JSessionId).
        end.   
        run createComboBaremeHonoraire in ghHonor(sys_pg.zone2, pcNomCombo, output table ttCombo by-reference).
    end.

end procedure.

procedure VerZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de vérification des zones saisies.
    Notes  :
    ------------------------------------------------------------------------------*/  
    define variable viNoPieUse    as integer   no-undo.
    define variable vcListeMandat as character no-undo.

    for first ttParamGeneraux
        where ttParamGeneraux.CRUD = "U":
        if ttParamGeneraux.iDureeMandat = 0 or ttParamGeneraux.iDureeMandat = ?
        then do:
            mError:createError({&error}, 108465).
            return.
        end.
        if ttParamGeneraux.iDelaiPreavis = 0 or ttParamGeneraux.iDelaiPreavis = ?
        then do:
            mError:createError({&error}, 108466).
            return.
        end.
    end.
    for first ttParamCrg
        where ttParamCrg.CRUD = "U":
        /* CRG : si traitement Avis echéance = au gardien alors activation Auto interdite */
        if ttParamCrg.lAutomatique and ttParamCrg.cCodeTraitementAvisEcheance = "00003"
        then do:  
            mError:createError({&error}, 109716).
            return.  
        end.
    end.
    for first ttParamDas2
        where ttParamDas2.CRUD = "U":
        /* DAS2T : declaration incompatible avec activation auto */
        if ttParamDas2.lParametrageActif and ttParamDas2.lActivation
        and ttParamDas2.lAutomatique     and ttParamDas2.lDeclaration
        then do:
            mError:createError({&error}, 109717).
            return.
        end.    
    end.
    for first ttParamTva
        where ttParamTva.CRUD = "U":
        if ttParamTva.iProrataNumerateur > ttParamTva.iProrataDenominateur
        then do:
            mError:createError({&error}, 103842).
            return.            
        end.       
        if ttParamTva.cCodeRegime = "18002"
        and ttParamTva.cCodeRecette = "1" 
        and ttParamTva.cCodeDepense = "2" 
        then do:
            /* Pas le droit de selectionner regime 'reel' avec recettes 'debits' et depenses 'encaissement' */
            mError:createError({&error}, 103789).
            return.
        end.
    end.
    for each ttParamListeDossierMandat
        where ttParamListeDossierMandat.CRUD = "D"
      , each tache no-lock
        where tache.tptac = {&TYPETACHE-DossierMandat}
          and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}:
        do viNoPieUse = 1 to num-entries(tache.cdreg):
            if integer(entry(viNoPieUse, tache.cdreg, separ[1])) = ttParamListeDossierMandat.iNumeroPiece
            and entry(viNoPieUse, tache.ntreg, separ[1]) = "00001" 
            then vcListeMandat = substitute("&1,&2", vcListeMandat, tache.nocon).
        end.
    end.
    vcListeMandat = trim(vcListeMandat, ",").
    if vcListeMandat > ""
    then do:
        mError:createErrorGestion({&error}, 109731, vcListeMandat).
        return.
    end.

end procedure.

procedure SavEcrPrm private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de sauvegarde des paramètres 
    Notes  :
    ------------------------------------------------------------------------------*/  
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    voDefautMandat = new parametrageDefautMandat().
    /*--> Parametres generaux */
    for first ttParamGeneraux
        where ttParamGeneraux.CRUD = "U":
        voDefautMandat:setGenerauxDuree(ttParamGeneraux.iDureeMandat).
        voDefautMandat:setGenerauxUniteDuree(substitute("pr&1UTDUR&1&2", separ[2], ttParamGeneraux.cCodeDureeMandat)).
        voDefautMandat:setGenerauxDelaiResiliation(ttParamGeneraux.iDelaiPreavis).
        voDefautMandat:setGenerauxUniteDelaiResiliation(substitute("pr&1UTDUR&1&2", separ[2], ttParamGeneraux.cCodeDureeMandat)).
        voDefautMandat:setGenerauxCodeRepartitionTerme(substitute("pr&1CDA_S&1&2", separ[2], ttParamGeneraux.cCodeRepartitionTerme)).
        voDefautMandat:setGenerauxFicheFinPec(substitute("pr&1CDOUI&1&2", separ[2], string(ttParamGeneraux.lEtionFicheFinPec, "00001/00002"))).
        voDefautMandat:setGenerauxModifAuto(substitute("pr&1CDOUI&1&2", separ[2], string(ttParamGeneraux.lModifAutoReglementProp, "00001/00002"))).
    end.
    /*--> Depots de garantie */
    for first ttParamDepotGarantie
        where ttParamDepotGarantie.CRUD = "U":
        voDefautMandat:setDepotGarantieTypeTache({&TYPETACHE-depotGarantieMandat}).
        voDefautMandat:setDepotGarantieParametrageActif(ttParamDepotGarantie.lParametrageActif).
        voDefautMandat:setDepotGarantie3(substitute("pg&1R_TAG&1&2&3&4&1&5&1&6",
                                                    separ[2], ttParamDepotGarantie.cCodeDepotGarantie, separ[3],
                                                    string(ttParamDepotGarantie.lParametrageActif, "yes/no"),
                                                    string(ttParamDepotGarantie.lActivation, "yes/no"),
                                                    string(ttParamDepotGarantie.lAutomatique, "A/M"))).
    end.
    /*--> Honoraires de gestion */ 
    for first ttParamHonoraireGestion
        where ttParamHonoraireGestion.CRUD = "U":
        voDefautMandat:setHonoraireGestionTypeTache({&TYPETACHE-Honoraires}).
        voDefautMandat:setHonoraireGestionParametrageActif(ttParamHonoraireGestion.lParametrageActif).
        voDefautMandat:setHonoraireGestion3(substitute("pg&1O_PDH&1&2", separ[2], ttParamHonoraireGestion.cCodePeriodeCalcul)).
        voDefautMandat:setHonoraireGestion4(substitute("&1NULL&1", separ[2])).
        voDefautMandat:setHonoraireGestion5(substitute("honor&1&2&1&3", separ[2], typeHonoraire({&TYPETACHE-Honoraires}), ttParamHonoraireGestion.cCodeHonoraire)).
        voDefautMandat:setHonoraireGestion6(substitute("honor&1&2&1&3&4&5&1&6&1&7", separ[2], typeHonoraire({&TYPETACHE-fraisGestion}),
                                                       ttParamHonoraireGestion.cCodeFrais, separ[3],
                                                       string(ttParamHonoraireGestion.lParametrageActif, "yes/no"),
                                                       string(ttParamHonoraireGestion.lActivation, "yes/no"),
                                                       string(ttParamHonoraireGestion.lAutomatique,"A/M"))).
    end.
    /*--> Compte rendu de gestion */
    for first ttParamCrg
        where ttParamCrg.CRUD = "U":
            voDefautMandat:setCRGTypeTache({&TYPETACHE-compteRenduGestion}).
            voDefautMandat:setCRGParametrageActif(ttParamCrg.lParametrageActif).
            voDefautMandat:setCRGCodePresentation(substitute("pg&1R_TAG&1&2", separ[2], ttParamCrg.cCodePresentationCrg)).
            voDefautMandat:setCRGCodePeriodicite(substitute("pg&1R_TPR&1&2", separ[2], ttParamCrg.cCodePeriodicite)).
            voDefautMandat:setCRG5(substitute("&1NULL&1", separ[2])).
            voDefautMandat:setCRG6(substitute("pr&1MDTRT&100002", separ[2])).
            voDefautMandat:setCRG7(substitute("pr&1TRTEC&1&2", separ[2], ttParamCrg.cCodeTraitementAvisEcheance)).
            voDefautMandat:setCRG8(substitute("pr&1CDOUI&1&2&3&4&1&5&1&6", separ[2],
                                              string(ttParamCrg.lPresentationDetailCalculHono, "00001/00002"), separ[3],
                                              string(ttParamCrg.lParametrageActif, "yes/no"),
                                              string(ttParamCrg.lActivation, "yes/no"),
                                              string(ttParamCrg.lAutomatique, "A/M"))).
    end.
    /*--> I.R.F. */
    for first ttParamIrf
        where ttParamIrf.CRUD = "U":
        voDefautMandat:setIRFTypeTache({&TYPETACHE-ImpotRevenusFonciers}).
        voDefautMandat:setIRFParametrageActif(ttParamIrf.lParametrageActif).
        voDefautMandat:setIRFCodeDeclaration(substitute("pg&1R_TAG&1&2", separ[2], ttParamIrf.cCodeDeclaration)).
        voDefautMandat:setIRF4(substitute("pr&1CDOUI&1&2", separ[2], string(ttParamIrf.lDeclaration2072, "00001/00002"))).
        voDefautMandat:setIRF5(substitute("pr&1CDOUI&1&2", separ[2], string(ttParamIrf.lMicroFoncier, "00001/00002"))).
        voDefautMandat:setIRF6(substitute("pg&1R_CRG&1&2", separ[2], string(ttParamIrf.lCalculTvaProratee, "21001/21002"))).
        voDefautMandat:setIRF7(substitute("pg&1R_CRG&1&2", separ[2], string(ttParamIrf.lCalculAutoProrataMandant, "21001/21002"))).
        voDefautMandat:setIRF8(substitute("honor&1&2&1&3", separ[2], typeHonoraire({&TYPETACHE-ImpotRevenusFonciers}), ttParamIrf.cCodeHonorair)).
        voDefautMandat:setIRF9(string(ttParamIrf.dDeductForfaitaireFraisGestion)).
        voDefautMandat:setIRF10(substitute("&1&2&3&4&5&4&6", string(ttParamIrf.dTauxDeductionMicrofoncier), separ[3],
                                           string(ttParamIrf.lParametrageActif, "yes/no"), separ[2],
                                           string(ttParamIrf.lActivation,"yes/no"), string(ttParamIrf.lAutomatique,"A/M"))).
    end.
    /*--> I.S.F. */   
    for first ttParamIsf
        where ttParamIsf.CRUD = "U":
        voDefautMandat:setISFTypeTache({&TYPETACHE-ImpotSolidariteFortune}).
        voDefautMandat:setISFParametrageActif(ttParamIsf.lParametrageActif).
        voDefautMandat:setISF3(substitute("pg&1R_TAD&1&2", separ[2], ttParamIsf.cCodeDeclaration)).
        voDefautMandat:setISF4(substitute("pg&1R_TPR&1&2", separ[2], ttParamIsf.cCodePeriode)).
        voDefautMandat:setISF5(substitute("honor&1&2&1&3&4&5&1&6&1&7", separ[2], typeHonoraire({&TYPETACHE-ImpotSolidariteFortune}),
                                          ttParamIsf.cCodeHonoraire, separ[3],
                                          string(ttParamIsf.lParametrageActif, "yes/no"),
                                          string(ttParamIsf.lActivation, "yes/no"),
                                          string(ttParamIsf.lAutomatique,"A/M"))).
    end.
    /*--> D.A.S. 2T */
    for first ttParamDas2
        where ttParamDas2.CRUD = "U":
        voDefautMandat:setDAS2TypeTache({&TYPETACHE-Das2Gerance}).
        voDefautMandat:setDAS2ParametrageActif(ttParamDas2.lParametrageActif).
        voDefautMandat:setDAS23(substitute("pg&1R_CRG&1&2", separ[2], string(ttParamDas2.lDeclaration, "21001/21002"))).
        voDefautMandat:setDAS24(substitute("honor&1&2&1&3&4&5&1&6&1&7", separ[2], typeHonoraire({&TYPETACHE-Das2Gerance}),
                                           ttParamDas2.cCodeHonoraire, separ[3],
                                           string(ttParamDas2.lParametrageActif, "yes/no"),
                                           string(ttParamDas2.lActivation, "yes/no"),
                                           string(ttParamDas2.lAutomatique, "A/M"))).
    end.
    /*--> CRL (ex Droit de bail - taxe additionnelle ) */
    for first ttParamCrl
        where ttParamCrl.CRUD = "U":
        voDefautMandat:setCRLTypeTache({&TYPETACHE-CRL}).
        voDefautMandat:setCRLParametrageActif(ttParamCrl.lParametrageActif).
        voDefautMandat:setCRL3(substitute("pg&1R_TAG&1&2", separ[2], ttParamCrl.cCodeEncaissement)).
        voDefautMandat:setCRL4(substitute("pg&1R_TAD&1&2", separ[2], ttParamCrl.cCodeDeclaration)).
        voDefautMandat:setCRL5(substitute("pg&1R_TPR&1&2", separ[2], ttParamCrl.cCodePeriode)).
        voDefautMandat:setCRL6(substitute("pg&1R_CRG&1&2", separ[2], string(ttParamCrl.lComptabilisation, "21001/21002"))). 
        voDefautMandat:setCRL7(substitute("honor&1&2&1&3&4&5&1&6&1M", separ[2], typeHonoraire({&TYPETACHE-CRL}),
                                          ttParamCrl.cCodeHonoraire, separ[3],
                                          string(ttParamCrl.lParametrageActif, "yes/no"),
                                          string(ttParamCrl.lActivation, "yes/no"))).
    end.
    /*--> Charges locatives */
    for first ttParamChargeLocative
        where ttParamChargeLocative.CRUD = "U":
        voDefautMandat:setChargeLocativeTypeTache({&TYPETACHE-chargesLocativesPrestations}).
        voDefautMandat:setChargeLocativeParametrageActif(ttParamChargeLocative.lParametrageActif).
        voDefautMandat:setChargeLocative3(substitute("pr&1CDCUM&1&2", separ[2], ttParamChargeLocative.cCodePresentation)).
        voDefautMandat:setChargeLocative4(substitute("pr&1CDLOT&1&2", separ[2], ttParamChargeLocative.cCodeRepartition)).
        voDefautMandat:setChargeLocative5(substitute("&1&2&3&4&5&4M", string(ttParamChargeLocative.lIntegrationDirectCompta, "yes/no"), separ[3],
                                                     string(ttParamChargeLocative.lParametrageActif, "yes/no"), separ[2],
                                                     string(ttParamChargeLocative.lActivation, "yes/no"))).
    end.
    /*--> TVA */
    for first ttParamTva
        where ttParamTva.CRUD = "U":      
        if ttParamTva.cCodeDeclaration = "19002" 
        then ttParamTva.lReglement = no.
        if ttParamTva.lReglement = no
        then ttParamTva.cCodeConserve = "1".
        voDefautMandat:setTVATypeTache({&TYPETACHE-Tva}).
        voDefautMandat:setTVAParametrageActif(ttParamTva.lParametrageActif).
        voDefautMandat:setTVA3(substitute("pg&1R_TAG&1&2", separ[2], ttParamTva.cCodeRegime)).
        voDefautMandat:setTVA4(substitute("pg&1R_TAD&1&2", separ[2], ttParamTva.cCodeDeclaration)).
        voDefautMandat:setTVA5(substitute("pg&1R_TPR&1&2", separ[2], ttParamTva.cCodePeriode)).
        voDefautMandat:setTVA6(substitute("pg&1R_CRG&1&2", separ[2], string(ttParamTva.lReglement, "21001/21002"))).
        voDefautMandat:setTVA7(ttParamTva.cCodeConserve).
        voDefautMandat:setTVA8(substitute("&1&2&3", ttParamTva.iProrataNumerateur, separ[2], ttParamTva.iProrataDenominateur)).
        voDefautMandat:setTVA9(ttParamTva.cCodeRecette).
        voDefautMandat:setTVA10(ttParamTva.cCodeDepense).
        voDefautMandat:setTVA11(substitute("honor&1&2&1&3&4&5&1&6&1M", separ[2], typeHonoraire({&TYPETACHE-Tva}),
                                ttParamTva.cCodeHonoraire, separ[3],
                                string(ttParamTva.lParametrageActif, "yes/no"),
                                string(ttParamTva.lActivation, "yes/no"))).
    end.
    /*--> Dossier mandat */
    for first ttParamDossierMandat
        where ttParamDossierMandat.CRUD = "U":
        voDefautMandat:setDossierMandatTypeTache("").
        voDefautMandat:setDossierMandatParametrageActif(ttParamDossierMandat.lParametrageActif).
        voDefautMandat:setDossierMandat3(substitute("pr&1CDOUI&1&2", separ[2], string(ttParamDossierMandat.lReglementChargeAuSyndic, "00001/00002"))).
        voDefautMandat:setDossierMandat4(substitute("pclie&1DOMDT&2&3&1&4&1&5", separ[2], separ[3],  
                                   string(ttParamDossierMandat.lParametrageActif, "yes/no"),
                                   string(ttParamDossierMandat.lActivation, "yes/no"),
                                   string(ttParamDossierMandat.lAutomatique, "A/M"))).
    end.
    /*--> Commentaires */
    for first ttParamCommentaire
        where ttParamCommentaire.CRUD = "U":
        voDefautMandat:setCommentaireTypeTache({&TYPETACHE-Commentaires}).
        voDefautMandat:setCommentaire2(substitute("&1&2&3&4&5&4&6",
                                                  string(ttParamCommentaire.lParametrageActif, "yes/no"), separ[3],
                                                  string(ttParamCommentaire.lParametrageActif, "yes/no"), separ[2],
                                                  string(ttParamCommentaire.lActivation, "yes/no"),
                                                  string(ttParamCommentaire.lAutomatique, "A/M"))).
    end.
    /*--> Gestion des commerciaux */
    for first ttParamCommercial
        where ttParamCommercial.CRUD = "U":
        voDefautMandat:setCommercialTypeTache({&TYPETACHE-gestionCommerciaux}).
        voDefautMandat:setCommercial2(substitute("&1&2&3&4&5&4&6",
                                                 string(ttParamCommercial.lParametrageActif, "yes/no"), separ[3],
                                                 string(ttParamCommercial.lParametrageActif, "yes/no"), separ[2],
                                                 string(ttParamCommercial.lActivation, "yes/no"),
                                                 string(ttParamCommercial.lAutomatique, "A/M"))).
    end.    
    if voDefautMandat:isDbParameter then voDefautMandat:update(). else voDefautMandat:create().
    delete object voDefautMandat no-error.

end procedure.

procedure Crepclie private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure sauvegarde liste dossier mandat (DOMDT)
    Notes  :
    ------------------------------------------------------------------------------*/  
    define variable voDossierMandat as class parametrageDossierMandat no-undo.
    define variable vcLstNoPie as character no-undo.
    define variable vcLstLbPie as character no-undo.
    define variable vcLstFgObl as character no-undo.

    voDossierMandat = new parametrageDossierMandat().
    voDossierMandat:int01 = 0.
    for each ttParamListeDossierMandat
       where lookup(ttParamListeDossierMandat.CRUD,"C,U") > 0:
        assign
            voDossierMandat:int01 = voDossierMandat:int01 + 1
            vcLstNoPie = vcLstNoPie + string(ttParamListeDossierMandat.iNumeroPiece) + separ[1]
            vcLstLbPie = vcLstLbPie + ttParamListeDossierMandat.cLibellePiece + separ[1]
            vcLstFgObl = vcLstFgObl + string(ttParamListeDossierMandat.lPieceObligatoire, "00001/00002") + separ[1]
        .       
    end.
    assign
        voDossierMandat:zon02 = trim(vcLstNoPie, separ[1])
        voDossierMandat:zon03 = trim(vcLstLbPie, separ[1])
        voDossierMandat:zon04 = trim(vcLstFgObl, separ[1])
    .
    if voDossierMandat:isDbParameter then voDossierMandat:update(). else voDossierMandat:create().
    delete object voDossierMandat no-error.
end procedure.

procedure completeParamCrg:
    /*------------------------------------------------------------------------------
    Purpose: pour completer la table initialisee avec les parametres CRG de l'ecran parametre crg
             avec les parametres de l'ecran parametre defaut mandat
    Notes  : service externe (paramCrg.p) 
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttParamCrg.
  
    empty temp-table ttCombo.
    run lectureParamCrg.

end procedure.
