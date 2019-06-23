/*------------------------------------------------------------------------
File        : beDossierTravaux.cls
Purpose     :
Author(s)   : kantena - 2016/10/18
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/

@program FILE(name="beDossierTravaux.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beDossierTravaux", URI="/beDossierTravaux", schemaName="dsbeDossierTravaux", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.dossierTravaux.beDossierTravaux:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: selfDestroy est positionné à faux par la classe qui aura instancié cette classe.
           Sinon, le destructeur de classe fait un 'ménage' intensif et détruit aussi l'appelant!!
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.    
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {travaux/include/dossierTravaux.i}
    {travaux/include/intervention.i}
    {travaux/include/appelDefond.i}
    {travaux/include/comptabilisationReliquat.i}
    {travaux/include/editionAno.i}
    {application/include/error.i}
    {compta/include/ctrlclot.i}

    define buffer gbttError for ttError.   
    define dataset dsbeDossierTravaux for ttDossierTravaux, 
                                          ttListeIntervention, 
                                          ttComptabilisationReliquat, 
                                          ttEdtAno, 
                                          tttmperr, 
                                          ttTmpCop,
                                          ttApatTmp,
                                          ttApipTmp,
                                          ttError.
    define dataset dsbeListeDossierTravaux for ttListeDossierTravaux, gbttError.

    constructor public beDossierTravaux():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void readbeDossierTravaux(pcFiltre as longchar, output dataset dsbeDossierTravaux):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('cTypeMandat',           vhBuffer::cTypeMandat) no-error.
                goCollection:set('iNumeroMandat',         int64(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroDossierTravaux', integer(vhBuffer::iNumeroDossierTravaux)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/dossierTravaux.p").
        run getDossierTravaux in vhProc (goCollection, output table ttDossierTravaux).
        run getErrors         in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void readbeListeDossierTravaux(pcFiltre as longchar, output dataset dsbeListeDossierTravaux):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string                                                                     
        Notes:                                                                        
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('cTypeMandat',   vhBuffer::cTypeMandat) no-error.
                goCollection:set('iNumeroMandat', int64(vhBuffer::iNumeroMandat)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/dossierTravaux.p").
        run getListeDossierTravaux in vhProc (goCollection, output table ttListeDossierTravaux).
        run getErrors              in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.
     
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void rechercheDossierTravaux(pcFiltre as longchar, output dataset dsbeListeDossierTravaux):
        /*------------------------------------------------------------------------------
        Purpose: Recherche générique activée par magiRecherche/rechercheEtendue.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set("iNumeroImmeuble" , integer(vhBuffer::iNumeroImmeuble))  no-error.
                goCollection:set("iNumeroImmeuble1", integer(vhBuffer::iNumeroImmeuble1)) no-error.
                goCollection:set("iNumeroImmeuble2", integer(vhBuffer::iNumeroImmeuble2)) no-error.
                goCollection:set("iNumeroMandat"   , integer(vhBuffer::iNumeroMandat))    no-error.
                goCollection:set("iNumeroMandat1"  , integer(vhBuffer::iNumeroMandat1))   no-error.
                goCollection:set("iNumeroMandat2"  , integer(vhBuffer::iNumeroMandat2))   no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/dossierTravaux.p").
        run rechercheDossierTravaux in vhProc(goCollection, output table ttListeDossierTravaux).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.
      
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeDossierTravaux(pcFiltre as longchar, input-output dataset dsbeDossierTravaux):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcTypeTrt  as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeTrt = vhBuffer::cTypeTrt no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/dossierTravaux.p").
        case vcTypeTrt:
            when "cloture" then run cloturedossiertravaux in vhProc(
                table ttDossierTravaux,
                table ttError,
                input-output table ttComptabilisationReliquat,
                output table ttEdtAno,
                output table ttTmpErr,
                output table ttTmpCop,
                output table ttApatTmp,
                output table ttApipTmp
            ).                     
            when "create" then do:
                run creationModificationDosTravaux in vhProc(input-output table ttDossierTravaux).
                run miseAJourIntervention          in vhProc(table ttDossierTravaux, table ttListeIntervention).
                run miseAJourMtFactures            in vhProc(table ttDossierTravaux).
            end. 
            when "validationAppelExterne" then run validationAppelExterne in vhProc(
                table ttError,
                input-output table ttDossierTravaux,
                input-output table ttEnteteAppelDeFond, 
                input-output table ttAppelDeFond, 
                input-output table ttAppelDeFondRepCle, 
                input-output table ttAppelDeFondRepMat, 
                input-output table ttInfoSaisieAppelDeFond,
                input-output table ttRepartitionCle,
                input-output table ttRepartitionCopro,
                input-output table ttRepartitionPourcentage,
                input-output table ttDossierAppelDeFond
            ).
            otherwise run createError in vhProc({&error}, 1000495, string(vcTypeTrt)). //type de traitement demandé inexistant     
        end case. 
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeDossierTravaux(input-output dataset dsbeDossierTravaux):
        /*------------------------------------------------------------------------------
        Purpose: suppression d'un dossier travaux 
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/dossierTravaux.p").
        run SuppressionDossierTravaux in vhProc(table ttDossierTravaux, table ttError).
        dataset dsbeDossierTravaux:empty-dataset().
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beDossierTravaux( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor. 

end class.
