/*------------------------------------------------------------------------
File        : beImmeuble.cls
Purpose     :
Author(s)   : kantena - 2016/07/13
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
@program FILE(name="beImmeuble.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beImmeuble", URI="/beImmeuble", schemaName="dsbeImmeuble", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class immeubleEtLot.beImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: selfDestroy est positionné à faux par la classe qui aura instancié beImmeuble.
           Sinon, le destructeur de beImmeuble fait un 'ménage' intensif et détruit aussi l'appelant!!
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/combo.i}
    {application/include/error.i}
    {immeubleEtLot/include/ascenseur.i}
    {immeubleEtLot/include/batiment.i}
    {immeubleEtLot/include/cleMagnetique.i}
    {immeubleEtLot/include/diagnostic.i}
    {immeubleEtLot/include/digicode.i}
    {immeubleEtLot/include/dommageOuvrage.i}
    {immeubleEtLot/include/equipementBien.i}
    {immeubleEtLot/include/fichierJoint.i}
    {immeubleEtLot/include/gardienLoge.i}
    {immeubleEtLot/include/horairesOuverture.i "Loge" "Loge"}
    {immeubleEtLot/include/horairesOuverture.i "Gardien" "Gardien"}
    {immeubleEtLot/include/immeuble.i}
    {immeubleEtLot/include/immeubleAutre.i}
    {immeubleEtLot/include/lot.i}
    {immeubleEtLot/include/mesureAdministrative.i}
    {immeubleEtLot/include/impotTaxeImmeuble.i}
    {immeubleEtLot/include/plan.i}
    {immeubleEtLot/include/reglementCopropriete.i}
    {immeubleEtLot/include/surface.i &nomTable=ttSurfaceImmeuble}
    {immeubleEtLot/include/surface.i &nomTable=ttSurfaceLot &serialName=ttSurfaceLot}
    {immeubleEtLot/include/surface.i &nomTable=ttSurfaceBatiment}
    {immeubleEtLot/include/tantieme.i}
    {note/include/notes.i &nomTable=ttNotes &serialName=ttNote}
    {adresse/include/adresse.i &nomTable=ttAdresseImmeuble &serialName=ttAdresseImmeuble}
    {adresse/include/coordonnee.i &nomTable=ttCoordonneeImmeuble &serialName=ttCoordonnee}
    {adresse/include/coordonnee.i &nomTable=ttCoordonneeLocataire}
    {adresse/include/coordonnee.i &nomTable=ttCoordonneeCoproprietaire}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationImmeuble}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationLoca}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationCopro}
    {role/include/role.i &nomTable=ttRolePrivatif}
    {role/include/role.i &nomTable=ttRoleGardien}
    {role/include/role.i &nomTable=ttRoleProprietaire}
    {role/include/roleContrat.i}
    {serviceGestion/include/gestionnaire.i}
    {serviceGestion/include/serviceGestion.i}

    define buffer gbttError  for ttError.
    define buffer gbttError2 for ttError.
    define dataset dsbeListeImmeuble
        for ttListeImmeuble, gbttError.

    define dataset dsbeImmeuble
    for ttImmeuble,
        ttContratImmeuble, ttMandatImmeuble, ttRoleContrat, ttServiceGestion, ttGestionnaire, ttRoleProprietaire, ttCoordonneeImmeuble, ttMoyenCommunicationImmeuble,
        ttBatiment, ttListeLot, ttSurfaceLot,
        ttTravaux, ttFournisseur,
        ttAdresseImmeuble, ttLoge, ttHorairesOuvLogeSerie1, ttHorairesOuvLogeSerie2, ttHorairesOuvGardienSerie1, ttHorairesOuvGardienSerie2,
        ttCoordonneeLocataire, ttCoordonneeCoproprietaire, ttMoyenCommunicationLoca, ttMoyenCommunicationCopro,
        ttDigicodeImmeuble, ttDigicode,
        ttSurfaceImmeuble, ttSurfaceBatiment,
        ttCleMagnetique, ttCleMagnetiqueDetail,
        ttEquipementBien,
        ttDiagnosticEtude, ttRolePrivatif,
        ttFichierJoint, ttFichierJointEquipement,
        ttImpotTaxe,
        ttDommageOuvrage,
        ttReglementCopropriete,
        ttMesureAdministrative,
        ttAscenseur, ttControleTechnique,
        ttGardien, ttRoleGardien,
        ttNotes,
        ttPlan,
        ttCleTantieme, ttTantieme,
        ttError
/* CONTRATS IMMEUBLE ------------------------------------------------------------------------------*/
        data-relation ContratMandat        for ttContratImmeuble, ttMandatImmeuble nested foreign-key-hidden
            relation-fields (ttContratImmeuble.iNumeroImmeuble, ttMandatImmeuble.iNumeroImmeuble,
                             ttContratImmeuble.iNumeroContrat, ttMandatImmeuble.iNumeroContrat,
                             ttContratImmeuble.cTypeContrat, ttMandatImmeuble.cTypeContrat)
        data-relation ContratRole          for ttContratImmeuble, ttRoleContrat nested foreign-key-hidden
            relation-fields (ttContratImmeuble.iNumeroContrat, ttRoleContrat.iNumeroContrat,
                             ttContratImmeuble.cTypeContrat, ttRoleContrat.cTypeContrat)
        data-relation ContratService       for ttContratImmeuble, ttServiceGestion nested foreign-key-hidden
            relation-fields (ttContratImmeuble.iNumeroImmeuble, ttServiceGestion.iNumeroImmeuble,
                             ttContratImmeuble.iNumeroContrat, ttServiceGestion.iNumeroContrat,
                             ttContratImmeuble.cTypeContrat, ttServiceGestion.cTypeContrat)
        data-relation ContratGestionnaire  for ttContratImmeuble, ttGestionnaire nested foreign-key-hidden
            relation-fields (ttContratImmeuble.iNumeroImmeuble, ttGestionnaire.iNumeroImmeuble,
                             ttContratImmeuble.iNumeroContrat, ttGestionnaire.iNumeroContrat,
                             ttContratImmeuble.cTypeContrat, ttGestionnaire.cTypeContrat)
/* TRAVAUX ----------------------------------------------------------------------------------------*/
        data-relation TravauxFournisseur   for ttTravaux, ttFournisseur nested foreign-key-hidden
            relation-fields (ttTravaux.iNumeroContrat, ttFournisseur.iNumeroContrat,
                             ttTravaux.cTypeContrat, ttFournisseur.cTypeContrat,
                             ttTravaux.iNumeroTache, ttFournisseur.iNumeroTache,
                             ttTravaux.iNumeroDossier, ttFournisseur.iNumeroDossier)
/* LOGES ------------------------------------------------------------------------------------------*/
        data-relation logeHoraire1         for ttLoge, ttHorairesOuvLogeSerie1 nested
            relation-fields (ttLoge.iNumeroLoge, ttHorairesOuvLogeSerie1.iNumeroIdentifiant)
        data-relation logeHoraire2         for ttLoge, ttHorairesOuvLogeSerie2 nested
            relation-fields (ttLoge.iNumeroLoge, ttHorairesOuvLogeSerie2.iNumeroIdentifiant)
/* DIGICODE ---------------------------------------------------------------------------------------*/
        data-relation DigicodeDetail       for ttDigicodeImmeuble, ttDigicode nested foreign-key-hidden
            relation-fields (ttDigicodeImmeuble.iNumeroDigicode, ttDigicode.iNumeroDigicode,
                             ttDigicodeImmeuble.iNumeroImmeuble, ttDigicode.iNumeroImmeuble)
/* EQUIPEMENTS ------------------------------------------------------------------------------------*/
        data-relation EquipementFichier   for ttEquipementBien, ttFichierJointEquipement nested foreign-key-hidden
            relation-fields (ttEquipementBien.cTypeBien, ttFichierJointEquipement.cTypeBien,
                             ttEquipementBien.iNumeroBien, ttFichierJointEquipement.iNumeroBien,
                             ttEquipementBien.cCodeEquipement, ttFichierJointEquipement.cCodeEquipement)
        data-relation diagnosticRole       for ttdiagnosticEtude, ttRolePrivatif nested foreign-key-hidden
            relation-fields (ttdiagnosticEtude.iNumeroTache, ttRolePrivatif.iNumeroIdentifiant)
/* CLE MAGNETIQUE ---------------------------------------------------------------------------------*/
        data-relation CleMagnetiqueDetail    for ttCleMagnetique, ttClemagnetiqueDetail nested
            relation-fields (ttCleMagnetique.iNumeroCle, ttClemagnetiqueDetail.iNumeroCle,
                             ttCleMagnetique.iNumeroImmeuble, ttClemagnetiqueDetail.iNumeroImmeuble)
/* CLE TANTIEME -----------------------------------------------------------------------------------*/
        data-relation CleDetailTantieme    for ttCleTantieme, ttTantieme nested foreign-key-hidden
            relation-fields (ttCleTantieme.iNumeroImmeuble, ttTantieme.iNumeroImmeuble,
                             ttCleTantieme.cCodeCle, ttTantieme.cCodeCle)
/* LISTE DES LOTS ---------------------------------------------------------------------------------*/
        data-relation ListeLotSurface      for ttListeLot, ttSurfaceLot nested
            relation-fields (ttListeLot.iNumeroBien,  ttSurfaceLot.iNumeroBien)
/* SURFACES BATIMENTS -----------------------------------------------------------------------------*/
        data-relation BatimentSurface      for ttBatiment, ttSurfaceBatiment nested
            relation-fields (ttBatiment.iNumeroBatiment, ttSurfaceBatiment.iNumeroBien)
/* ASCENSEUR --------------------------------------------------------------------------------------*/
        data-relation ControleAscenseur    for ttAscenseur, ttControleTechnique nested foreign-key-hidden
            relation-fields (ttAscenseur.iNumeroTache, ttControleTechnique.iNumeroLien)
/* GARDIEN ----------------------------------------------------------------------------------------*/
        data-relation GardienRole          for ttGardien, ttRoleGardien nested
            relation-fields (ttGardien.iNumeroTache, ttRoleGardien.iNumeroIdentifiant)
        data-relation gardienHoraire1      for ttGardien, ttHorairesOuvGardienSerie1 nested
            relation-fields (ttGardien.iNumeroTache, ttHorairesOuvGardienSerie1.iNumeroIdentifiant)
        data-relation gardienHoraire2      for ttGardien, ttHorairesOuvGardienSerie2 nested
            relation-fields (ttGardien.iNumeroTache, ttHorairesOuvGardienSerie2.iNumeroIdentifiant)
/* COORDONNEES IMMEUBLE ---------------------------------------------------------------------------*/
        data-relation CoordonneesMoyensImm        for ttCoordonneeImmeuble, ttMoyenCommunicationImmeuble nested foreign-key-hidden
            relation-fields (ttCoordonneeImmeuble.cJointure, ttMoyenCommunicationImmeuble.cJointure)
/* COORDONNEES LOTS -------------------------------------------------------------------------------*/
        data-relation LotCoordonneesLoca   for ttListeLot, ttCoordonneeLocataire nested foreign-key-hidden
            relation-fields (ttListeLot.iNumeroLot, ttCoordonneeLocataire.iNumeroIdentifiant)
        data-relation LotCoordonneesCopro  for ttListeLot, ttCoordonneeCoproprietaire nested foreign-key-hidden
            relation-fields (ttListeLot.iNumeroLot, ttCoordonneeCoproprietaire.iNumeroIdentifiant)
        data-relation CoordonneesMoyensL   for ttCoordonneeLocataire, ttMoyenCommunicationLoca nested foreign-key-hidden
            relation-fields (ttCoordonneeLocataire.cJointure, ttMoyenCommunicationLoca.cJointure)
        data-relation CoordonneesMoyensC   for ttCoordonneeCoproprietaire, ttMoyenCommunicationCopro nested foreign-key-hidden
            relation-fields (ttCoordonneeCoproprietaire.cJointure, ttMoyenCommunicationCopro.cJointure)
    .
    define dataset dsbeCombo for ttCombo, gbttError2.

    constructor public beImmeuble():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeImmeuble (pcFiltre as longchar, output pcImmeuble as longchar):
        /*------------------------------------------------------------------------------
        Purpose: renvoie un dataset lié à la vue 'cVue' demandée.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable viNumeroImmeuble as integer   no-undo.
        define variable vcListeLot       as character no-undo.
        define variable vlIsPrincipal    as logical   no-undo.
        define variable vcVue            as character no-undo.
        define variable vhProcErreur     as handle    no-undo.
        define variable vhttField        as handle    no-undo.
        define variable viI              as integer   no-undo.

        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroImmeuble = vhBuffer::iNumeroImmeuble no-error.
                vlIsPrincipal    = vhBuffer::vlIsPrincipal   no-error.
                vcVue            = vhBuffer::cVue            no-error.
                vhttField = vhBuffer:buffer-field("cListeLot") no-error.
                if valid-handle(vhttField)
                then if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcListeLot = substitute('&1,&2', vcListeLot, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcListeLot = vhttField:buffer-value() no-error.
                vcListeLot = trim(vcListeLot, ",") no-error.
            end.
        end.
        delete object vhttFilter no-error.

        if vlIsPrincipal = ? then assign vlIsPrincipal = false.
        case vcVue:
            when 'IMMEUBLE'             then vueImmeubleRead(viNumeroImmeuble).
            when 'SITUATION'            then vueSituationRead(viNumeroImmeuble).
            when 'GENERAL'              then vueGeneralRead(viNumeroImmeuble).
            when 'DESCRIPTION'          then vueDescriptionRead(viNumeroImmeuble).
            when 'GARDIEN'              then vueGardienRead(viNumeroImmeuble).
            when 'CONTRAT'              then vueContratRead(viNumeroImmeuble).
            when 'IMPOTTAXE'            then vueImpotTaxeRead(viNumeroImmeuble).
            when 'COPROPRIETE'          then vueCoproprieteRead(viNumeroImmeuble).
            when 'LOT'                  then vueLotRead(viNumeroImmeuble, vlIsPrincipal).
            when 'TANTIEME'             then vueTantiemeRead(viNumeroImmeuble).
            when 'MESUREADMINISTRATIVE' then vueMesureAdministrativeRead(viNumeroImmeuble).
            when 'NOTE'                 then vueNoteRead(viNumeroImmeuble).
            when 'FOURNISSEUR'          then vueFournisseurRead(viNumeroImmeuble).
            when 'DOMMAGEOUVRAGE'       then vueDommageOuvrageRead(viNumeroImmeuble).
            when 'DIAGNOSTICETUDE'      then vueDiagnosticEtudeRead(viNumeroImmeuble).
            when 'ASCENSEUR'            then vueAscenseurRead(viNumeroImmeuble).
            when 'EQUIPEMENT'           then vueEquipementRead(viNumeroImmeuble).
            when 'DOMOTIQUE'            then vueDomotiqueRead(viNumeroImmeuble).
            when 'TRAVAUX'              then vueTravauxRead(viNumeroImmeuble).
            when 'FICHIERJOINT'         then vueFichierJointRead(viNumeroImmeuble).
            when 'PLAN'                 then vuePlanRead(viNumeroImmeuble).
            when 'CONSTRUCTION'         then vueConstruction(viNumeroImmeuble).
            when 'TOUS' then do:    // TODO: est-ce bien nécessaire.
                vueImmeubleRead(viNumeroImmeuble).
                vueSituationRead(viNumeroImmeuble).
                vueGeneralRead(viNumeroImmeuble).
                vueDescriptionRead(viNumeroImmeuble).
                vueGardienRead(viNumeroImmeuble).
                vueContratRead(viNumeroImmeuble).
                vueImpotTaxeRead(viNumeroImmeuble).
                vueCoproprieteRead(viNumeroImmeuble).
                vueLotRead(viNumeroImmeuble, vlIsPrincipal).
                vueTantiemeRead(viNumeroImmeuble).
                vueMesureAdministrativeRead(viNumeroImmeuble).
                vueNoteRead(viNumeroImmeuble).
                vueFournisseurRead(viNumeroImmeuble).
                vueDommageOuvrageRead(viNumeroImmeuble).
                vueDiagnosticEtudeRead(viNumeroImmeuble).
                vueAscenseurRead(viNumeroImmeuble).
                vueEquipementRead(viNumeroImmeuble).
                vueDomotiqueRead(viNumeroImmeuble).
                vueTravauxRead(viNumeroImmeuble).
                vueFichierJointRead(viNumeroImmeuble).
                vuePlanRead(viNumeroImmeuble).
            end.
            otherwise do: 
                vhProcErreur = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProcErreur({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in vhProcErreur(output table ttError).
            end.
        end case.
        // permet de générer le Json sans les champs ayant leur valeur par défaut - réduit la taille du flux!
        dataset dsbeImmeuble:write-json("LONGCHAR", pcImmeuble, false, ?, true, false, false).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void rechercheImmeuble(pcFiltre as longchar, output dataset dsbeListeImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: Recherche générique activée par magiRecherche/rechercheEtendue.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle no-undo.
        define variable vhttFilter     as handle no-undo.
        define variable vhBuffer       as handle no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set("cAdresseImmeuble",       vhBuffer::cAdresseImmeuble)          no-error.
                goCollection:set("cNomImmeuble",           vhBuffer::cNomImmeuble)              no-error.
                goCollection:set("iNumeroImmeuble",        integer(vhBuffer::iNumeroImmeuble))  no-error.
                goCollection:set("iNumeroImmeuble1",       integer(vhBuffer::iNumeroImmeuble1)) no-error.
                goCollection:set("iNumeroImmeuble2",       integer(vhBuffer::iNumeroImmeuble2)) no-error.
                goCollection:set("iNumeroMandat",          integer(vhBuffer::iNumeroMandat))    no-error.
                goCollection:set("iNumeroMandat1",         integer(vhBuffer::iNumeroMandat1))   no-error.
                goCollection:set("iNumeroMandat2",         integer(vhBuffer::iNumeroMandat2))   no-error.
                goCollection:set("cCodeStatut",            vhBuffer::cCodeStatut)               no-error.
                goCollection:set("cCodeService",           vhBuffer::cCodeService)              no-error.
                goCollection:set("cCodeTypeImmeuble",      vhBuffer::cCodeTypeImmeuble)         no-error.
                goCollection:set("cCodeSecteur",           vhBuffer::cCodeSecteur)              no-error.
                goCollection:set("cCodeNatureBien",        vhBuffer::cCodeNatureBien)           no-error.
                goCollection:set("cCodeCategorieImmeuble", vhBuffer::cCodeCategorieImmeuble)    no-error.
            end.
        end.
        delete object vhttFilter no-error.

        empty temp-table ttListeImmeuble.
        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run rechercheImmeuble in vhProcImmeuble(goCollection, output table ttListeImmeuble).
        run getErrors         in vhProcImmeuble(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeImmeuble (input-output dataset dsbeImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeImmeuble(pcFiltre as longchar, input-output dataset dsbeImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: mise à jour d'une vue 'cVue' d'un immeuble.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable vcVue            as character no-undo.
        define variable vhProcErreur     as handle    no-undo.
        define variable viNumeroImmeuble as integer   no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroImmeuble = vhBuffer::iNumeroImmeuble  no-error.
                vcVue            = vhBuffer::cVue no-error.
            end.
        end.        
        else vcVue = pcFiltre.
        delete object vhttFilter no-error.

        case vcVue:
            when 'IMMEUBLE'             then vueImmeubleUpdate().
            when 'SITUATION'            then vueSituationUpdate().
            when 'GENERAL'              then vueGeneralUpdate().
            when 'DESCRIPTION'          then vueDescriptionUpdate().
            when 'GARDIEN'              then vueGardienUpdate(viNumeroImmeuble).
            when 'IMPOTTAXE'            then vueImpotTaxeUpdate(viNumeroImmeuble).
            when 'COPROPRIETE'          then vueCoproprieteUpdate(viNumeroImmeuble).
            when 'MESUREADMINISTRATIVE' then vueMesureAdministrativeUpdate().
            when 'NOTE'                 then vueNoteUpdate().
            when 'FOURNISSEUR'          then vueFournisseurUpdate().
            when 'DOMMAGEOUVRAGE'       then vueDommageOuvrageUpdate(viNumeroImmeuble).
            when 'DIAGNOSTICETUDE'      then vueDiagnosticEtudeUpdate(viNumeroImmeuble).
            when 'ASCENSEUR'            then vueAscenseurUpdate(viNumeroImmeuble).
            when 'EQUIPEMENT'           then vueEquipementUpdate().
            when 'DOMOTIQUE'            then vueDomotiqueUpdate(viNumeroImmeuble).
            when 'TRAVAUX'              then vueTravauxUpdate(viNumeroImmeuble).
            when 'FICHIERJOINT'         then .    /*TODO: attente GED*/
            when 'PLAN'                 then vuePlanUpdate(viNumeroImmeuble).
            otherwise do: 
                vhProcErreur = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProcErreur({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in vhProcErreur(output table ttError).
            end.
        end case.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeImmeuble (input-output dataset dsbeImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readInfoImmeubleParMandat (pcFiltre as longchar, output immeuble as longchar):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble  as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroContrat as int64     no-undo.
        define variable vcTypeContrat   as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroContrat = int64(vhBuffer::iNumeroContrat) no-error.
                vcTypeContrat   = vhBuffer::cTypeContrat          no-error.
            end.
        end.
        delete object vhttFilter no-error.
 
        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getInfoImmeubleParMandat in vhProcImmeuble(viNumeroContrat, vcTypeContrat, output table ttImmeuble).
        run getErrors                in vhProcImmeuble(output table ttError).
        // permet de générer le Json sans les champs ayant leur valeur par défaut - réduit la taille du flux!
        dataset dsbeImmeuble:write-json("LONGCHAR", immeuble, false, ?, true, false, false).
        {outils/include/tryCatch.i}
    end method. 

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readContratFournisseurParMandat (pcFiltre as longchar, output dataset dsbeImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble  as handle  no-undo.
        define variable vhttFilter      as handle  no-undo.
        define variable vhBuffer        as handle  no-undo.
        define variable viReference     as integer no-undo.
        define variable viNumeroMandat  as integer no-undo.
        define variable vlResilie       as logical no-undo initial true.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viReference    = vhBuffer::iReference    no-error.
                viNumeroMandat = vhBuffer::iNumeroMandat no-error.
                vlResilie      = vhBuffer::lResilie      no-error.
            end.
        end.
        delete object vhttFilter no-error.
        
        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getContratFournisseurParMandat in vhProcImmeuble(viReference, viNumeroMandat, vlResilie, output table ttContratImmeuble).
        run getErrors                      in vhProcImmeuble(output table ttError).
        {outils/include/tryCatch.i}
    end method. 

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void ReadCombo (pcFiltre as longchar, output dataset dsbeCombo):
        /*------------------------------------------------------------------------------
        Purpose: récupération de la liste des combos nécessaires à une vue.
        Notes: La liste est donnée par la vue.
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble   as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable viNumeroImmeuble as integer   no-undo.
        define variable vcComboFilter    as character no-undo.

        dataset dsbeCombo:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroImmeuble = vhBuffer::iNumeroImmeuble no-error.
                vcComboFilter    = vhBuffer::ComboFilter     no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getCombo  in vhProcImmeuble(viNumeroImmeuble, vcComboFilter, output table ttCombo).
        run getErrors in vhProcImmeuble(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void getNextNumeroImmeuble(pcFiltre as longchar, output piNumeroImmeuble as integer, output table ttError):
        /*------------------------------------------------------------------------------
        Purpose: donne le prochain numéro immeuble à créer
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle  no-undo.

        vhProc = outilHandle:connectMaGIModele("immeubleEtLot/imble_crud.p").
        run getNextImmeuble in vhProc(output piNumeroImmeuble).
        run getErrors       in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void testNumeroImmeuble(pcFiltre as longchar, output table ttError):
        /*------------------------------------------------------------------------------
        Purpose: Vérification du numéro immeuble.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc           as handle  no-undo.
        define variable viNumeroImmeuble as integer no-undo.
        define variable vhttFilter       as handle  no-undo.
        define variable vhBuffer         as handle  no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroImmeuble = integer(vhBuffer::iNumeroImmeuble) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("immeubleEtLot/imble_crud.p").
        dynamic-function('testNumeroImmeuble' in vhproc, viNumeroImmeuble, true).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void controleDateAchevement(pcFiltre as longchar, output table ttError):
        /*------------------------------------------------------------------------------
        Purpose: Vérification de la date d'achèvement de l'immeuble
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble   as handle  no-undo.
        define variable viNumeroImmeuble as integer no-undo.
        define variable vhttFilter       as handle  no-undo.
        define variable vhBuffer         as handle  no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroImmeuble = integer(vhBuffer::iNumeroImmeuble) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        dynamic-function('controleDateAchevement' in vhProcImmeuble, viNumeroImmeuble).
        run getErrors in vhProcImmeuble (output table ttError).
        {outils/include/tryCatch.i}
    end method.
        
    destructor public beImmeuble( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

    method private logical vueImmeubleRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle no-undo.
        define variable vhProcAdresse  as handle no-undo.

        assign
            vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcAdresse  = outilHandle:connectMaGIModele("adresse/adresse.p")
        .
        run getImmeuble in vhProcImmeuble(piNumeroImmeuble, output table ttImmeuble).
        run getAdresse  in vhProcAdresse ({&TYPEBIEN-immeuble}, piNumeroImmeuble, "", "1", output table ttAdresseImmeuble, output table ttCoordonneeImmeuble, output table ttMoyenCommunicationImmeuble).        
        run getErrors   in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueImmeubleUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run setImmeuble in vhProcImmeuble(table ttImmeuble).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors          in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueSituationRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle no-undo.
        define variable vhProcBatiment as handle no-undo.
        define variable vhProcSurface  as handle no-undo.

        assign
            vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcBatiment = outilHandle:connectMaGIModele("immeubleEtLot/batiment.p")
            vhProcSurface  = outilHandle:connectMaGIModele("immeubleEtLot/surface_crud.p")
        .
        run getLogeImmeuble in vhProcImmeuble(piNumeroImmeuble, output table ttLoge, output table ttHorairesOuvLogeSerie1, output table ttHorairesOuvLogeSerie2).
        run getBatiment     in vhProcBatiment(piNumeroImmeuble, output table ttBatiment).
        run readSurface     in vhProcSurface({&TYPEBIEN-batiment}, piNumeroImmeuble, "", output table ttSurfaceBatiment). 
        run getErrors       in vhProcSurface(output table ttError).
    end method.

    method private logical vueSituationUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : getErrors est fait entre chaque run pour éviter les run suivant en cas d'erreur
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle no-undo.
        define variable vhProcSurface  as handle no-undo.
        define variable vhProcBatim    as handle no-undo.
        define variable vhProcTache    as handle no-undo.

        assign
            vhProcImmeuble = outilHandle:connectMaGIModele('ImmeubleEtLot/immeuble.p')
            vhProcSurface  = outilHandle:connectMaGIModele('ImmeubleEtLot/surface_crud.p')
            vhProcBatim    = outilHandle:connectMaGIModele('ImmeubleEtLot/batiment.p')
            vhProcTache    = outilHandle:connectMaGIModele('tache/tacheImmeuble.p')
        .
        run setImmeuble in vhProcImmeuble(table ttImmeuble).
        run getErrors   in vhProcImmeuble(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then do:
            run setAdresseImmeuble in vhProcImmeuble(table ttAdresseImmeuble, table ttCoordonneeImmeuble, table ttMoyenCommunicationImmeuble). 
            run getErrors   in vhProcImmeuble(output table ttError).
            if not can-find(first ttError where ttError.iType >= {&error})
            then do:
                run setSurface in vhProcSurface({&TYPEBIEN-batiment}, table ttSurfaceBatiment, input-output table ttBatiment).
                run getErrors  in vhProcSurface(output table ttError).
                if not can-find(first ttError where ttError.iType >= {&error})
                then do:
                    run setBatiment        in vhProcBatim(input-output table ttBatiment).
                    run setAdresseBatiment in vhProcBatim(table ttBatiment).
                    run getErrors   in vhProcBatim(output table ttError).
                    if not can-find(first ttError where ttError.iType >= {&error})
                    then run setLoges  in vhProcTache(table ttLoge, table ttHorairesOuvLogeSerie1, table ttHorairesOuvLogeSerie2).
                end.
            end.
        end.
        dataset dsbeImmeuble:empty-dataset().
        run getErrors in vhProcImmeuble(output table ttError).  // Attention, getErrors après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueGeneralRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcSurface  as handle  no-undo.

        vhProcSurface  = outilHandle:connectMaGIModele("immeubleEtLot/surface_crud.p").
        run readSurface in vhProcSurface({&TYPEBIEN-immeuble}, piNumeroImmeuble, "", output table ttSurfaceImmeuble). 
        run getErrors   in vhProcSurface (output table ttError).
    end method.

    method private logical vueGeneralUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : getErrors est fait entre chaque run pour éviter les run suivant en cas d'erreur
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.
        define variable vhProcSurface  as handle  no-undo.

        assign
            vhProcImmeuble = outilHandle:connectMaGIModele('ImmeubleEtLot/immeuble.p')
            vhProcSurface  = outilHandle:connectMaGIModele('ImmeubleEtLot/surface_crud.p')
        .
        run setSurface in vhProcSurface({&TYPEBIEN-immeuble}, table ttSurfaceImmeuble, input-output table ttImmeuble).
        run getErrors  in vhProcSurface  (output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run setImmeuble in vhProcImmeuble(table ttImmeuble).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors in vhProcImmeuble(output table ttError).  // Attention, getErrors après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueDescriptionRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcBatiment as handle  no-undo.

        vhProcBatiment = outilHandle:connectMaGIModele("immeubleEtLot/batiment.p").
        run getBatiment in vhProcBatiment(piNumeroImmeuble, output table ttBatiment).
        run getErrors   in vhProcBatiment(output table ttError).
    end method.

    method private logical vueDescriptionUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : getErrors est fait entre chaque run pour éviter les run suivant en cas d'erreur
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.
        define variable vhProcBatim    as handle  no-undo.

        assign
            vhProcImmeuble = outilHandle:connectMaGIModele('ImmeubleEtLot/immeuble.p')
            vhProcBatim    = outilHandle:connectMaGIModele('ImmeubleEtLot/batiment.p')
        .
        run setImmeuble in vhProcImmeuble(table ttImmeuble).
        run getErrors   in vhProcImmeuble(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then do:
            run setBatiment        in vhProcBatim(input-output table ttBatiment).
            run setAdresseBatiment in vhProcBatim(table ttBatiment).
        end.
        dataset dsbeImmeuble:empty-dataset().
        run getErrors in vhProcImmeuble(output table ttError).  // Attention, getErrors après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueGardienRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getGardien in vhProcImmeuble(piNumeroImmeuble, output table ttGardien, output table ttRoleGardien, output table ttHorairesOuvGardienSerie1, output table ttHorairesOuvGardienSerie2).
        run getErrors  in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueGardienUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcTache    as handle  no-undo.
        define variable vhProcImmeuble as handle  no-undo.
        define variable viNumeroContratConstruction as int64 no-undo.
        assign
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .        
        run setGardien in vhProcTache(viNumeroContratConstruction, table ttGardien, table ttRoleGardien, table ttHorairesOuvGardienSerie1, table ttHorairesOuvGardienSerie2).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors in vhProcTache(output table ttError).  // Attention, getErrors après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueContratRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getContratImmeuble in vhProcImmeuble(piNumeroImmeuble, output table ttContratImmeuble, output table ttMandatImmeuble, output table ttRoleContrat, output table ttServiceGestion, output table ttGestionnaire, output table ttFichierJoint).                
        run getErrors          in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueimpotTaxeRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getImpotTaxe in vhProcImmeuble(piNumeroImmeuble, output table ttImpotTaxe).
        run getErrors    in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueImpotTaxeUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble              as handle no-undo.
        define variable vhProcTache                 as handle no-undo.
        define variable viNumeroContratConstruction as int64  no-undo.
        assign
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .      
        if not can-find(first ttError where ttError.iType >= {&error})
        then run setImpotTaxe in vhProcTache(viNumeroContratConstruction, table ttImpotTaxe).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors in vhProcTache(output table ttError).
    end method.
    
    method private logical vueCoproprieteRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getReglementCopropriete in vhProcImmeuble(piNumeroImmeuble, output table ttReglementCopropriete, output table ttFichierJoint).
        run getErrors               in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueCoproprieteUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : getErrors est fait entre chaque run pour éviter les run suivant en cas d'erreur
        ------------------------------------------------------------------------------*/
        define variable vhProcTache    as handle  no-undo.
        define variable vhProcImmeuble as handle  no-undo.
        define variable viNumeroContratConstruction as int64 no-undo.
        
        assign
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .        
        run setImmeuble in vhProcImmeuble(table ttImmeuble).
        run getErrors   in vhProcImmeuble(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run setReglementCopropriete in vhProcTache(viNumeroContratConstruction, table ttReglementCopropriete).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors in vhProcImmeuble(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueLotRead(piNumeroImmeuble as integer, plIsPrincipal as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcLot     as handle  no-undo.
        define variable vhProcSurface as handle  no-undo.

        assign
            vhProcLot     = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
            vhProcSurface = outilHandle:connectMaGIModele("immeubleEtLot/surface_crud.p")
        .
        run getListeLotsImmeuble      in vhProcLot    (piNumeroImmeuble, plIsPrincipal, output table ttListeLot).
        run getCoordonneeSelectionLot in vhProcLot (table ttListeLot, output table ttCoordonneeLocataire, output table ttCoordonneeCoproprietaire, output table ttMoyenCommunicationLoca, output table ttMoyenCommunicationCopro).
        run readSurfaceSelectionLot   in vhProcSurface("PRINCIPALE", table ttListeLot, output table ttSurfaceLot).
        run getErrors                 in vhProcSurface(output table ttError).
    end method.

    method private logical vueTantiemeRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcTantieme as handle  no-undo.

        vhProcTantieme = outilHandle:connectMaGIModele("immeubleEtLot/tantieme.p").
        run getCleImmeuble in vhProcTantieme(piNumeroImmeuble, output table ttCleTantieme, output table ttTantieme).
        run getErrors      in vhProcTantieme(output table ttError).
    end method.

    method private logical vueMesureAdministrativeRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getMesureAdministrative in vhProcImmeuble(piNumeroImmeuble, output table ttMesureAdministrative).
        run getErrors               in vhProcImmeuble(output table ttError).
    end method.
    
    method private logical vueMesureAdministrativeUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcTache as handle  no-undo.

        vhProcTache = outilHandle:connectMaGIModele("tache/tacheImmeuble.p").
        run setMesureAdministrative in vhProcTache(table ttMesureAdministrative).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors               in vhProcTache(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueNoteRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmble as handle  no-undo.

        vhProcImmble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getNotesImmeuble in vhProcImmble(piNumeroImmeuble, output table ttNotes).
        run getErrors        in vhProcImmble(output table ttError).
    end method.

    method private logical vueNoteUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : la mise à jour nécessite un ttImmeuble restreint (iNumeroImmeuble)
        ------------------------------------------------------------------------------*/
        define variable vhProcNote     as handle no-undo.
        define variable vhProcImmeuble as handle no-undo.

        assign
            vhProcNote     = outilHandle:connectMaGIModele("note/notes_CRUD.p")
            vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
        .
blocUpdate:
        do:
            run setNotes in vhProcNote(input-output table ttNotes).
            run getErrors in vhProcNote(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            for each ttNotes
              , first ttImmeuble
                where ttImmeuble.iNumeroImmeuble = ttNotes.iNumeroIdentifiant:
                ttImmeuble.iNumeroBlocNote = ttNotes.iNumeroBlocNote.
            end.
            run setImmeuble in vhProcImmeuble(table ttImmeuble).
        end.
        dataset dsbeImmeuble:empty-dataset().
        run getErrors in vhProcNote(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueFournisseurRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getContratImmeuble in vhProcImmeuble(piNumeroImmeuble, output table ttContratImmeuble, output table ttMandatImmeuble, output table ttRoleContrat, output table ttServiceGestion, output table ttGestionnaire, output table ttFichierJoint).
        run getErrors          in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueFournisseurUpdate():
        /*------------------------------------------------------------------------------
        Purpose: TODO non implémenté
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run setContratsImmeuble in vhProcImmeuble(table ttContratImmeuble, table ttMandatImmeuble, table ttRoleContrat, table ttServiceGestion, table ttGestionnaire, table ttFichierJoint).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors    in vhProcImmeuble(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueDommageOuvrageRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getDommageOuvrage in vhProcImmeuble(piNumeroImmeuble, output table ttDommageOuvrage).
        run getErrors         in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueDommageOuvrageUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble              as handle no-undo.
        define variable vhProcTache                 as handle no-undo.
        define variable viNumeroContratConstruction as int64  no-undo.

        assign
            vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcTache    = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .
        run setDommageOuvrage in vhProcTache(viNumeroContratConstruction, table ttDommageOuvrage).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors         in vhProcTache(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueDiagnosticEtudeRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble              as handle no-undo.
        define variable vhProcDiagnostic            as handle no-undo.
        define variable viNumeroContratConstruction as int64  no-undo.

        assign
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcDiagnostic            = outilHandle:connectMaGIModele("immeubleEtLot/diagnostic.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .
        run getdiagnosticEtudeImmeuble in vhProcDiagnostic(piNumeroImmeuble, viNumeroContratConstruction, output table ttdiagnosticEtude).
        run getErrors                  in vhProcDiagnostic(output table ttError).
    end method.

    method private logical vueDiagnosticEtudeUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/        
        define variable vhProcImmeuble as handle no-undo.
        define variable vhProcTache    as handle no-undo.
        define variable viNumeroContratConstruction as int64 no-undo.

        assign
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .
        run setDiagnosticEtude in vhProcTache(viNumeroContratConstruction, 0, table ttdiagnosticEtude).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors          in vhProcTache(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueAscenseurRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getAscenseurs in vhProcImmeuble(piNumeroImmeuble, output table ttAscenseur, output table ttControleTechnique, output table ttFichierJoint).
        run getErrors     in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueAscenseurUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcTache                 as handle no-undo.
        define variable vhProcImmeuble              as handle no-undo.
        define variable viNumeroContratConstruction as int64  no-undo.

        assign
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .
        run setAscenseur in vhProcTache(viNumeroContratConstruction, table ttAscenseur, table ttControleTechnique).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors    in vhProcTache(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueEquipementRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.
        define variable vhProcBatiment as handle  no-undo.

        assign
            vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcBatiment = outilHandle:connectMaGIModele("immeubleEtLot/batiment.p")
        .
        run getEquipementImmeuble in vhProcImmeuble(piNumeroImmeuble, output table ttEquipementBien, output table ttFichierJointEquipement).
        run getEquipementBatiment in vhProcBatiment(piNumeroImmeuble, output table ttEquipementBien append, output table ttFichierJointEquipement append).
        run getErrors             in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueEquipementUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcEqBien as handle  no-undo.

        vhProcEqBien = outilHandle:connectMaGIModele("immeubleEtLot/equipementBien.p").
        run setEquipementBien in vhProcEqBien(table ttEquipementBien, table ttFichierJointEquipement).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors         in vhProcEqBien(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueDomotiqueRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getCleMagnetique in vhProcImmeuble(piNumeroImmeuble, output table ttCleMagnetique, output table ttCleMagnetiqueDetail).
        run getDigicode      in vhProcImmeuble(piNumeroImmeuble, output table ttDigicode, output table ttDigicodeImmeuble).
        run getErrors        in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueDomotiqueUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : getErrors est fait entre chaque run pour éviter les run suivant en cas d'erreur
        ------------------------------------------------------------------------------*/
        define variable vhProcTache                 as handle no-undo.
        define variable vhProcImmeuble              as handle no-undo.
        define variable viNumeroContratConstruction as int64  no-undo.

        assign
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .
        run setCleMagnetique in vhProcTache(viNumeroContratConstruction, table ttCleMagnetique, table ttCleMagnetiqueDetail).
        run getErrors        in vhProcTache(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run setDigicode in vhProcTache(viNumeroContratConstruction, table ttDigicode, table ttDigicodeImmeuble).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors        in vhProcTache(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueTravauxRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getDossierTravaux in vhProcImmeuble(piNumeroImmeuble, output table ttTravaux, output table ttFournisseur).
        run getTravauxManuels in vhProcImmeuble(piNumeroImmeuble, output table ttTravaux append, output table ttFournisseur append).
        run getErrors         in vhProcImmeuble(output table ttError).
    end method.

    method private logical vueTravauxUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcTache                 as handle no-undo.
        define variable vhProcImmeuble              as handle no-undo.
        define variable viNumeroContratConstruction as int64  no-undo.

        assign
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .
        run setTravaux in vhProcTache(viNumeroContratConstruction, table ttTravaux, table ttFournisseur).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors  in vhProcTache(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vueFichierJointRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle  no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getFichiersJoints in vhProcImmeuble(piNumeroImmeuble, output table ttFichierJoint).
        run getErrors         in vhProcImmeuble(output table ttError).
    end method.

    method private logical vuePlanRead(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble              as handle no-undo.
        define variable vhProcPlan                  as handle no-undo.
        define variable viNumeroContratConstruction as int64  no-undo.

        assign
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcPlan                  = outilHandle:connectMaGIModele("immeubleEtLot/plan.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .
        run getPlanImmeuble in vhProcPlan(piNumeroImmeuble, viNumeroContratConstruction, output table ttPlan).
        run getErrors       in vhProcPlan(output table ttError).
    end method.

    method private logical vuePlanUpdate(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcTache                 as handle no-undo.
        define variable vhProcImmeuble              as handle no-undo.
        define variable viNumeroContratConstruction as int64  no-undo.
        
        assign
            vhProcTache    = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, piNumeroImmeuble)
        .
        
        run setPlan in vhProcTache(viNumeroContratConstruction, 0, table ttPlan).
        dataset dsbeImmeuble:empty-dataset().
        run getErrors  in vhProcTache(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.


    method private logical vueConstruction(piNumeroImmeuble as integer):
        /*------------------------------------------------------------------------------
        Purpose: lecture des informations construction (comme il n'y a pas de table specifique pour ces infos,
                 retour dans la table ttImmeuble. avec le write-json, la taille de la table sera reduite avec uniquement 
                 ces infos construction)
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble as handle no-undo.

        vhProcImmeuble = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p").
        run getConstruction in vhProcImmeuble(piNumeroImmeuble, output table ttImmeuble).
        run getErrors   in vhProcImmeuble(output table ttError).
    end method.

end class.
