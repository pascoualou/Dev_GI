/*------------------------------------------------------------------------
File        : beConvocAG.cls
Purpose     : Synchronisation des AG
Author(s)   : DMI - 20181010
Notes       :
derniere revue:
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2adresse.i}

@program FILE(name="beConvocAG.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beConvocAG", URI="/beConvocAG", schemaName="dsbeConvocAG", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class convocAG.beConvocAG:
    /*------------------------------------------------------------------------------
    Purpose: Synchronisation des convocs AG
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.

    {application/include/combo.i}
    {application/include/error.i}
    {oerealm/include/utilisateur.i &nomTable=ttListeUtilisateur}
    {mandat/include/listeMandat.i &nomtable=ttListeMandatImmeuble &serialName=ttListeMandatImmeuble}
    {adresse/include/adresse.i &nomTable=ttAdresseImmeuble}
    {adresse/include/adresse.i &nomTable=ttAdresseTiers}
    {adresse/include/coordonnee.i &nomTable=ttCoordonneeImmeuble}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationImmeuble}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationTiers}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationUtilisateur}
    {adresse/include/codePostal.i}
    {immeubleEtLot/include/tantieme.i}
    {immeubleEtLot/include/lotSimplifie.i} // ttListeLot
    {tiers/include/tiers.i}
    {adb/include/demembrement.i &nomtable=ttUsufruitier    &serialName=ttUsufruitier}
    {adb/include/demembrement.i &nomtable=ttNuProprietaire &serialName=ttNuProprietaire}
    {parametre/cabinet/gestionImmobiliere/include/formulePolitesse.i}

    define buffer gbttTiers                   for ttTiers.
    define buffer gbttMoyenCommunicationTiers for ttMoyenCommunicationTiers.
    define buffer gbttAdresseTiers            for ttAdresseTiers.
    define buffer gbttError                   for ttError.
    define buffer gb2ttError                  for ttError.

    define dataset dsbeConvocImmeuble for ttListeMandatImmeuble, ttAdresseImmeuble, ttCleTantieme, ttTiers, ttAdresseTiers, ttMoyenCommunicationTiers, ttListeLot, ttTantieme, ttUsufruitier, ttNuProprietaire, ttError
    data-relation adresseImmeuble for ttListeMandatImmeuble, ttAdresseImmeuble nested
            relation-fields (ttListeMandatImmeuble.iNumeroImmeuble, ttAdresseImmeuble.iNumeroIdentifiant)
    data-relation cleTantieme for ttListeMandatImmeuble, ttCleTantieme nested
            relation-fields (ttListeMandatImmeuble.iNumeroImmeuble, ttCleTantieme.iNumeroImmeuble)
    data-relation tiers for ttListeMandatImmeuble, ttTiers nested
            relation-fields (ttListeMandatImmeuble.iNumeroImmeuble, ttTiers.iNumeroImmeuble)
    data-relation adresseTiers for ttTiers, ttAdresseTiers nested
            relation-fields (ttTiers.cCodeTypeRole, ttAdresseTiers.cTypeIdentifiant,
                             ttTiers.iNumeroRole, ttAdresseTiers.iNumeroIdentifiant)
    data-relation lot for ttTiers, ttListeLot nested
            relation-fields (ttTiers.cCodeTypeRole, ttListeLot.cCodeTypeProprietaire,
                             ttTiers.iNumeroRole, ttListeLot.iNumeroProprietaire)
    data-relation LotTantieme for ttListeLot, ttTantieme nested
            relation-fields (ttListeLot.iNumeroImmeuble, ttTantieme.iNumeroImmeuble,
                             ttListeLot.iNumeroLot, ttTantieme.iNumeroLot)
    data-relation moyenCommunicationTiers for ttTiers, ttMoyenCommunicationTiers nested
            relation-fields (ttTiers.cCodeTypeRole, ttMoyenCommunicationTiers.cTypeIdentifiant,
                             ttTiers.iNumeroRole, ttMoyenCommunicationTiers.iNumeroIdentifiant)
    data-relation usufruitier for ttListeMandatImmeuble, ttUsufruitier nested
            relation-fields (ttListeMandatImmeuble.iNumeroImmeuble, ttUsufruitier.iNumeroImmeuble)
    data-relation nuproprietaire for ttListeMandatImmeuble, ttNuProprietaire nested
            relation-fields (ttListeMandatImmeuble.iNumeroImmeuble, ttNuProprietaire.iNumeroImmeuble)
    .

    define dataset dsbeConvocCabinet for gbttTiers, gbttAdresseTiers, gbttMoyenCommunicationTiers, ttTiersSiret, ttListeUtilisateur, ttMoyenCommunicationUtilisateur, ttTiersContrats, gbttError
    data-relation adresseTiers for gbttTiers, gbttAdresseTiers nested
            relation-fields (gbttTiers.cCodeTypeRole, gbttAdresseTiers.cTypeIdentifiant,
                             gbttTiers.iNumeroRole, gbttAdresseTiers.iNumeroIdentifiant)
    data-relation moyenCommunicationTiers for gbttTiers, gbttMoyenCommunicationTiers nested
            relation-fields (gbttTiers.cCodeTypeRole, gbttMoyenCommunicationTiers.cTypeIdentifiant,
                             gbttTiers.iNumeroRole, gbttMoyenCommunicationTiers.iNumeroIdentifiant)
    data-relation siretTiers for gbttTiers, ttTiersSiret nested
            relation-fields (gbttTiers.iNumeroTiers, ttTiersSiret.iNumeroTiers)
    data-relation moyenCommunicationUtilisateur for ttListeUtilisateur, ttMoyenCommunicationUtilisateur nested
            relation-fields (ttListeUtilisateur.cTypeRole, ttMoyenCommunicationUtilisateur.cTypeIdentifiant,
                             ttListeUtilisateur.iNumeroRole, ttMoyenCommunicationUtilisateur.iNumeroIdentifiant)
    .

    define dataset dsbeConvocAnnuaire for ttCodePostal, ttFormulePolitesse, ttCombo, gb2ttError.

    constructor public beConvocAG():
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
        define variable vhttFilter as handle  no-undo.
        define variable vhBuffer   as handle  no-undo.
        define variable vcVue      as character no-undo.
        define variable viNumeroImmeuble as integer initial ? no-undo.
        define variable viNumeroMandat   as int64   initial ? no-undo.

        dataset dsbeConvocImmeuble:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcVue            = vhBuffer::cVue            no-error.
                viNumeroImmeuble = vhBuffer::iNumeroImmeuble no-error.
                viNumeroMandat   = vhBuffer::iNumeroMandat   no-error.
            end.
        end.
        case vcVue :
            when "LISTEMANDATIMMEUBLE" then readListeMandatImmeuble(viNumeroImmeuble).
            when "DETAILIMMEUBLE"      then readDetailImmeuble(viNumeroMandat).
        end.
        delete object vhttFilter no-error.
        // permet de générer le Json sans les champs ayant leur valeur par défaut - réduit la taille du flux!
        dataset dsbeConvocImmeuble:write-json("LONGCHAR", pcImmeuble, false, ?, true, false, false).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeCabinet (output pcCabinet as longchar):
        /*------------------------------------------------------------------------------
        Purpose: renvoie un dataset lié à la vue 'cVue' demandée.
        Notes:
        ------------------------------------------------------------------------------*/
        dataset dsbeConvocCabinet:empty-dataset().
        readInfoCabinet().
        // permet de générer le Json sans les champs ayant leur valeur par défaut - réduit la taille du flux!
        dataset dsbeConvocCabinet:write-json("LONGCHAR", pcCabinet, false, ?, true, false, false).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeAnnuaire (pcFiltre as longchar, output pcAnnuaire as longchar):
        /*------------------------------------------------------------------------------
        Purpose: renvoie un dataset lié à la vue 'cVue' demandée.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCodePostaux as character no-undo.
        define variable vhttFilter    as handle    no-undo.
        define variable vhBuffer      as handle    no-undo.
        
        dataset dsbeConvocAnnuaire:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available 
            then vcCodePostaux = vhBuffer::cCodePostaux no-error.
        end.
        delete object vhttFilter no-error.
        readAnnuaire(vcCodePostaux).
        // permet de générer le Json sans les champs ayant leur valeur par défaut - réduit la taille du flux!
        dataset dsbeConvocAnnuaire:write-json("LONGCHAR", pcAnnuaire, false, ?, true, false, false).
        {outils/include/tryCatch.i}
    end method.

    method private void readListeMandatImmeuble(piNumeroImmeuble as integer) :
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("mandat/mandat.p").
        if piNumeroImmeuble <> ? then do :
            goCollection:set('iNumeroImmeubleDeb' , piNumeroImmeuble) no-error.
            goCollection:set('iNumeroImmeubleFin' , piNumeroImmeuble) no-error.
        end.
        else goCollection:set('iNumeroImmeubleDeb' , 1) no-error. // Pour déclencher la recherche par numéro d'immeuble
        goCollection:set('lInactif'           , false) no-error.
        goCollection:set('cTypeContrat'       , {&TYPECONTRAT-mandat2Syndic}) no-error.
        goCollection:set('lPECImmeubleEnCours', false) no-error.
        run getListeMandat in vhProc(goCollection, output table ttListeMandatImmeuble).
        run getErrors in vhProc(output table ttError).
        delete object goCollection.
    end method.

    method private void readDetailImmeuble(input piNumeroMandat as int64) :
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcConvocAG  as handle no-undo.

        vhProcConvocAG = outilHandle:connectMaGIModele("convocAG/convocAG.p").
        run getSynchroImmeuble in vhProcConvocAG (piNumeroMandat,
                                                  output table ttListeMandatImmeuble,
                                                  output table ttAdresseImmeuble,
                                                  output table ttCleTantieme,
                                                  output table ttTantieme,
                                                  output table ttTiers,
                                                  output table ttAdresseTiers,
                                                  output table ttMoyenCommunicationTiers,
                                                  output table ttListeLot,
                                                  output table ttUsufruitier,
                                                  output table ttNuProprietaire).
        run getErrors in vhProcConvocAG(output table ttError).
    end method.

    method private void readInfoCabinet() :
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcConvocAG  as handle no-undo.

        vhProcConvocAG = outilHandle:connectMaGIModele("convocAG/convocAG.p").
        run getSynchroCabinet in vhProcConvocAG (output table ttTiers,
                                                 output table ttAdresseTiers,
                                                 output table ttMoyenCommunicationTiers,
                                                 output table ttTiersSiret,
                                                 output table ttListeUtilisateur,
                                                 output table ttMoyenCommunicationUtilisateur,
                                                 output table ttTiersContrats).
        run getErrors in vhProcConvocAG(output table ttError).
    end method.

    method private void readAnnuaire(pcCodePostaux as character) :
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcConvocAG  as handle no-undo.

        vhProcConvocAG = outilHandle:connectMaGIModele("convocAG/convocAG.p").
        run getSynchroAnnuaire in vhProcConvocAG (pcCodePostaux,
                                                  output table ttCodePostal,
                                                  output table ttCombo,
                                                  output table ttFormulePolitesse).
        run getErrors in vhProcConvocAG(output table ttError).
    end method.

end class.
