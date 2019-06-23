/*------------------------------------------------------------------------
File        : convocAG.p
Purpose     : Synchronisation des AG
Author(s)   : DMI 20181012
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}

using parametre.syspg.syspg.
using parametre.syspr.syspr.
using parametre.pclie.parametrageFormulePolitesse.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{oerealm/include/utilisateur.i &nomTable=ttListeUtilisateur}
{adresse/include/adresse.i &nomTable=ttAdresseImmeuble}
{adresse/include/adresse.i &nomTable=ttAdresseTiers}
{adresse/include/coordonnee.i &nomTable=ttCoordonneeImmeuble}
{adresse/include/coordonnee.i &nomTable=ttCoordonneeTiers}
{adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationImmeuble}
{adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationTiers}
{adresse/include/coordonnee.i &nomTable=ttCoordonneeUtilisateur}
{adresse/include/adresse.i &nomTable=ttAdresseUtilisateur}
{adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationUtilisateur}
{adresse/include/codePostal.i}
{mandat/include/listeMandat.i &nomtable=ttListeMandatImmeuble &serialName=ttListeMandatImmeuble}
{immeubleEtLot/include/tantieme.i}
{immeubleEtLot/include/lotSimplifie.i} // ttListeLot
{tiers/include/tiers.i}
{adb/include/demembrement.i &nomtable=ttUsufruitier    &serialName=ttUsufruitier}
{adb/include/demembrement.i &nomtable=ttNuProprietaire &serialName=ttNuProprietaire}
{parametre/cabinet/gestionImmobiliere/include/formulePolitesse.i}
{application/include/combo.i}

function fIsNull returns logical(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.
end function.

procedure getSynchroImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les infos d'un immeuble pour la synchro des AG
    Notes:  service utilisé par beConvocAG.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64 no-undo.
    define output parameter table for ttListeMandatImmeuble.
    define output parameter table for ttAdresseImmeuble.
    define output parameter table for ttCleTantieme.
    define output parameter table for ttTantieme.
    define output parameter table for ttTiers.
    define output parameter table for ttAdresseTiers.
    define output parameter table for ttMoyenCommunicationTiers.
    define output parameter table for ttListeLot.
    define output parameter table for ttUsufruitier. 
    define output parameter table for ttNuProprietaire.

    define variable vhProcAdresse  as handle           no-undo.
    define variable vhProcTantieme as handle           no-undo.
    define variable vhProcMandat   as handle           no-undo.
    define variable vhProcTiers    as handle           no-undo.
    define variable vhProcLot      as handle           no-undo.
    define variable vhProcDemembr  as handle           no-undo.
    define variable voCollection   as class collection no-undo.
    define variable voCollection2  as class collection no-undo.

    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    
    empty temp-table ttListeMandatImmeuble.
    empty temp-table ttAdresseImmeuble.
    empty temp-table ttCleTantieme.
    empty temp-table ttTantieme.
    empty temp-table ttTiers.
    empty temp-table ttAdresseTiers.
    empty temp-table ttCoordonneeTiers.
    empty temp-table ttMoyenCommunicationTiers.
    empty temp-table ttListeLot.

    run adresse/adresse.p persistent set vhProcAdresse.
    run getTokenInstance in vhProcAdresse (mToken:JSessionId).
    run immeubleEtLot/tantieme.p persistent set vhProcTantieme.
    run getTokenInstance in vhProcTantieme (mToken:JSessionId).
    run immeubleEtLot/lot.p persistent set vhProcLot.
    run getTokenInstance in vhProclot (mToken:JSessionId).
    run mandat/mandat.p persistent set vhProcMandat.
    run getTokenInstance in vhProcMandat (mToken:JSessionId).
    run tiers/tiers.p persistent set vhProcTiers.
    run getTokenInstance in vhProcTiers (mToken:JSessionId).
    run adb/bien/demembrement.p persistent set vhProcDemembr.
    run getTokenInstance in vhProcDemembr (mToken:JSessionId).
    
    voCollection  = new collection().
    voCollection2 = new collection().
    for first intnt no-lock // Immeuble lié
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.nocon = piNumeroMandat
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        voCollection:set('iNumeroImmeubleDeb' , intnt.noidt) no-error.
        voCollection:set('iNumeroImmeubleFin' , intnt.noidt) no-error.
        voCollection:set('lInactif'           , false) no-error.
        voCollection:set('cTypeContrat'       , {&TYPECONTRAT-mandat2Syndic}) no-error.
        voCollection:set('lPECImmeubleEnCours', false) no-error.
        run getListeMandat in vhProcMandat(voCollection, output table ttListeMandatImmeuble by-reference).
        run getAdresseSimplifiee in vhProcAdresse({&TYPEBIEN-immeuble}, intnt.noidt, {&TYPEADRESSE-Principale}, ?, "1",
                                                  output table ttAdresseImmeuble by-reference).
        run getAdresseSimplifiee in vhProcAdresse({&TYPEBIEN-immeuble}, intnt.noidt, {&TYPEADRESSE-Secondaire}, ?, "1",
                                                  output table ttAdresseImmeuble by-reference).
        run getCleImmeuble in vhProcTantieme(intnt.noidt, output table ttCleTantieme, output table ttTantieme by-reference).
        run getDetailTiersContrat in vhProcTiers({&TYPECONTRAT-mandat2Syndic}, piNumeroMandat, {&TYPEROLE-coproprietaire}, output table ttTiers by-reference).
        run getDetailTiersContrat in vhProcTiers({&TYPECONTRAT-mandat2Syndic}, piNumeroMandat, {&TYPEROLE-coIndivisaire} , output table ttTiers by-reference).
        run getDetailTiersContrat in vhProcTiers({&TYPECONTRAT-mandat2Syndic}, piNumeroMandat, {&TYPEROLE-mandataire}    , output table ttTiers by-reference).
        run getRattachementLot in vhprocDemembr(intnt.noidt, true, output table ttUsufruitier, output table ttNuProprietaire).
        for each ttUsufruitier :
            if not can-find(first ttTiers where ttTiers.cCodeTypeRole = ttUsufruitier.cCodeTypeRole
                                            and ttTiers.iNumeroRole   = ttUsufruitier.iNumeroRole)
            then do :                                            
                voCollection2:set('cTypeRole',           ttUsufruitier.cCodeTypeRole)    no-error.
                voCollection2:set('iNumeroRole',         ttUsufruitier.iNumeroRole)      no-error.
                voCollection2:set('cTypeContratTiers',   ttUsufruitier.cCodeTypeContrat) no-error.        
                voCollection2:set('iNumeroContratTiers', ttUsufruitier.iNumeroContrat)   no-error.
                run getTiers in vhProcTiers (voCollection2, output table ttTiers by-reference).
            end.                
        end.
        for each ttNuProprietaire :
            if not can-find(first ttTiers where ttTiers.cCodeTypeRole = ttNuProprietaire.cCodeTypeRole
                                            and ttTiers.iNumeroRole   = ttNuProprietaire.iNumeroRole)
            then do :                                            
                voCollection2:set('cTypeRole',           ttNuProprietaire.cCodeTypeRole)    no-error.
                voCollection2:set('iNumeroRole',         ttNuProprietaire.iNumeroRole)      no-error.
                voCollection2:set('cTypeContratTiers',   ttNuProprietaire.cCodeTypeContrat) no-error.        
                voCollection2:set('iNumeroContratTiers', ttNuProprietaire.iNumeroContrat)   no-error.
                run getTiers in vhProcTiers (voCollection2, output table ttTiers by-reference).
            end.                
        end.       
        for each ttTiers :
            ttTiers.iNumeroImmeuble = intnt.noidt.
            run getAdresse in vhProcAdresse(
                ttTiers.cCodeTypeRole,
                ttTiers.iNumeroRole,
                {&TYPEADRESSE-Principale},
                ?,
                "1",
                output table ttAdresseTiers by-reference,
                output table ttCoordonneeTiers by-reference,
                output table ttMoyenCommunicationTiers by-reference).
            if lookup(ttTiers.cCodeTypeRole, substitute("&1,&2,&3,&4,&5",
                                                        {&TYPEROLE-coproprietaire}, 
                                                        {&TYPEROLE-usufruitier}, 
                                                        {&TYPEROLE-coUsufruitier}, 
                                                        {&TYPEROLE-nuProprietaire}, 
                                                        {&TYPEROLE-coNuProprietaire})) > 0
            then do :
                run getListeLotsContratImmeuble in vhProcLot({&TYPECONTRAT-titre2copro}, 
                                                              (ctrat.nocon * 100000) + ttTiers.iNumeroRole, 
                                                              ttTiers.iNumeroImmeuble, 
                                                              output table ttListeLot by-reference).
                for each ttListeLot where ttListeLot.iNumeroProprietaire =  ttTiers.iNumeroRole :
                    ttListeLot.cCodeTypeProprietaire = ttTiers.cCodeTypeRole.
                end.                    
            end.
        end.
    end.
    delete object voCollection.
    delete object voCollection2.
    run destroy in vhProcTiers.
    run destroy in vhProcAdresse.
    run destroy in vhProcTantieme.
    run destroy in vhProcMandat.
    run destroy in vhProcLot.
    run destroy in vhProcDemembr.
end procedure.

procedure getSynchroCabinet:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les infos du cabinet
    Notes:  service utilisé par beConvocAG.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttTiers.
    define output parameter table for ttAdresseTiers.
    define output parameter table for ttMoyenCommunicationTiers.
    define output parameter table for ttTiersSiret.
    define output parameter table for ttListeUtilisateur.
    define output parameter table for ttMoyenCommunicationUtilisateur.
    define output parameter table for ttTiersContrats.

    define variable vhProcAdresse     as handle           no-undo.
    define variable vhProcTiers       as handle           no-undo.
    define variable vhProcUtilisateur as handle           no-undo.
    define variable voCollection      as class collection no-undo.

    define buffer roles for roles.
    
    empty temp-table ttTiers.
    empty temp-table ttAdresseTiers.
    empty temp-table ttCoordonneeTiers.
    empty temp-table ttMoyenCommunicationTiers.
    empty temp-table ttTiersSiret.
    empty temp-table ttAdresseUtilisateur.
    empty temp-table ttCoordonneeUtilisateur.
    empty temp-table ttMoyenCommunicationUtilisateur.
    empty temp-table ttTiersContrats.
    run adresse/adresse.p persistent set vhProcAdresse.
    run getTokenInstance in vhProcAdresse (mToken:JSessionId).
    run tiers/tiers.p persistent set vhProcTiers.
    run getTokenInstance in vhProcTiers (mToken:JSessionId).
    run oerealm/utilisateur.p persistent set vhProcUtilisateur.
    run getTokenInstance in vhProcUtilisateur (mToken:JSessionId).
    voCollection = new collection().
    for first roles no-lock
        where roles.norol = 1
          and roles.tprol = {&TYPEROLE-syndic2copro} :
        voCollection:set('iNumeroTiers' , 0) no-error.
        voCollection:set('cTypeRole' , roles.tprol ) no-error.
        voCollection:set('iNumeroRole', roles.norol) no-error.
        voCollection:set('cTypeContratTiers', "") no-error.
        voCollection:set('iNumeroContratTiers', 0) no-error.
        run getTiers in vhProcTiers (voCollection, output table ttTiers by-reference).
        run getAdresse in vhProcAdresse(
            roles.tprol,
            roles.norol,
            {&TYPEADRESSE-Principale},
            ?,
            "1",
            output table ttAdresseTiers by-reference,
            output table ttCoordonneeTiers by-reference,
            output table ttMoyenCommunicationTiers by-reference).
        run getTiersSiret in vhProcTiers(voCollection, output table ttTiersSiret by-reference).
    end.
    run getListeUtilisateur in vhProcUtilisateur(output table ttListeUtilisateur by-reference).
    for each ttListeUtilisateur :
        run getAdresse in vhProcAdresse(
            ttListeUtilisateur.cTypeRole,
            ttListeUtilisateur.iNumeroRole,
            {&TYPEADRESSE-Principale},
            ?,
            "1",
            output table ttAdresseUtilisateur by-reference,
            output table ttCoordonneeUtilisateur by-reference,
            output table ttMoyenCommunicationUtilisateur by-reference).
    end.
    run getGestionnaireService in vhProcTiers(output table ttTiersContrats by-reference). // Liste des collaborateurs / service
    for each roles no-lock
        where roles.tprol = {&TYPEROLE-agenceGestion} :
        voCollection:set('iNumeroTiers' , 0) no-error.
        voCollection:set('cTypeRole' , roles.tprol ) no-error.
        voCollection:set('iNumeroRole', roles.norol) no-error.
        voCollection:set('cTypeContratTiers', "") no-error.
        voCollection:set('iNumeroContratTiers', 0) no-error.
        run getTiers in vhProcTiers (voCollection, output table ttTiers by-reference).
        run getAdresse in vhProcAdresse(
            roles.tprol,
            roles.norol,
            {&TYPEADRESSE-Principale},
            ?,
            "1",
            output table ttAdresseTiers by-reference,
            output table ttCoordonneeTiers by-reference,
            output table ttMoyenCommunicationTiers by-reference).
    end.
    delete object voCollection.
    run destroy in vhProcTiers.
    run destroy in vhProcAdresse.
    run destroy in vhProcUtilisateur.
end procedure.

procedure getSynchroAnnuaire :
    /*------------------------------------------------------------------------------
    Purpose: Récupère les infos annuaire
    Notes:  service utilisé par beConvocAG.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodePostaux as character no-undo. // "A" ou "" ou  null = Avec, "S" = Sans, "U" = Uniquement 
    define output parameter table for ttCodePostal.
    define output parameter table for ttCombo.
    define output parameter table for ttFormulePolitesse.

    define variable vhProcAdresse as handle no-undo.
    define variable vhlabelLadb   as handle no-undo.
    
    define variable voParametrageFormulePolitesse as class parametrageFormulePolitesse no-undo.
    define variable voSyspg as class syspg no-undo.
    define variable voSyspr as class syspr no-undo.

    empty temp-table ttCodePostal.
    empty temp-table ttFormulePolitesse.
    
    
    if fIsNull(pcCodePostaux) or lookup(pcCodePostaux,"U,A") > 0 
    then do :   
        run adresse/adresse.p persistent set vhProcAdresse.
        run getTokenInstance in vhProcAdresse (mToken:JSessionId).
        run getCodePostaux in vhProcAdresse(output table ttCodePostal by-reference).
        run destroy in vhProcAdresse.        
    end.        

    if pcCodePostaux <> "U" then do :
        voSyspg = new syspg().
        voSyspr = new syspr().
        run application/libelle/labelLadb.p persistent set vhlabelLadb.
        run getTokenInstance in vhlabelLadb (mToken:JSessionId).
        run getCombolabel in vhlabelLadb ("CMBNATURELOT,CMBNATUREVOIE,CMBNUMEROBIS", output table ttcombo by-reference).
        voSyspg:getComboParametreLongCourt("O_CVT","CMBCIVILITE", output table ttCombo by-reference).
        voSyspr:getComboParametre("CDPAY","CMBPAYS", output table ttCombo by-reference).
        voParametrageFormulePolitesse = new parametrageFormulePolitesse().
        voParametrageFormulePolitesse:getListeFormulePolitesse(false, output table ttFormulePolitesse by-reference).
        delete object voParametrageFormulePolitesse.
        delete object voSyspg.
        delete object voSyspr.
        run destroy in vhlabelLadb.
    end.        
end procedure.

