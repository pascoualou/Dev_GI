/*------------------------------------------------------------------------
File        : beTiersCommercialisation.cls
Purpose     :
Author(s)   : KANTENA - 2016/08/04
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beTiersCommercialisation.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beTiersCommercialisation", URI="/beTiersCommercialisation", schemaName="beTiersCommercialisation", schemaFile="").

using outils.outilHandle.
using outils.collection.
block-level on error undo, throw.

class tiers.commercialisation.beTiersCommercialisation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {tiers/include/tiers.i}
    define dataset dsbeTiers for ttTiers, ttError.

    constructor public beTiersCommercialisation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeTiersCommercialisation(pcFiltre as longchar, output dataset dsbeTiers):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcTiers   as handle    no-undo.
        define variable vhttFilter    as handle    no-undo.
        define variable vhBuffer      as handle    no-undo.
        define variable viNumeroFiche as integer   no-undo.

        dataset dsbeTiers:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroFiche = integer(vhBuffer::iNumeroFiche) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcTiers = outilHandle:connectMaGIModele("tiers/tiers.p").
        run getTiersFicheCommercialisation in vhProcTiers(viNumeroFiche, output table ttTiers).
        run getErrors in vhProcTiers(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeTiersCommercialisation(input-output dataset dsbeTiers):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeTiersCommercialisation(input-output dataset dsbeTiers):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeTiersCommercialisation(input-output dataset dsbeTiers):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beTiersCommercialisation( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
