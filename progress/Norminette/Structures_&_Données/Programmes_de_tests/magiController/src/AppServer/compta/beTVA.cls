/*------------------------------------------------------------------------
File        : beTva.cls
Purpose     :
Author(s)   : kantena - 2016/07/27
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beTVA.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beTVA", URI="/beTVA", schemaName="dsbeTVA", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class compta.beTVA:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {compta/include/tva.i}
    define dataset dsbeTVA for ttTVA, ttError.

    constructor public beTVA():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void ReadbeTVA(pcFiltre as longchar, output dataset dsbeTVA):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcTVA    as handle    no-undo.
        define variable vhttFilter   as handle    no-undo.
        define variable vhBuffer     as handle    no-undo.
        define variable viCodeTVA    as integer   no-undo.
        define variable vcOrigineTVA as character no-undo.

        dataset dsbeTVA:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viCodeTVA    = vhBuffer::iCodeTVA no-error.
                vcOrigineTVA = vhBuffer::cOrigineTVA no-error.
            end.
        end.
        delete object vhttFilter no-error.
        vhProcTVA = outilHandle:connectMaGIModele("compta/outilsTVA.p").
        if vcOrigineTVA = "CDTVA" then run getCodeTVA in vhProcTVA(output table ttTVA).
        else run getTVACompta in vhProcTVA(viCodeTVA, output table ttTVA).
        run getErrors in vhProcTVA(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeTVA(input-output dataset dsbeTVA):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeTVA(input-output dataset dsbeTVA):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeTVA(input-output dataset dsbeTVA):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beTVA ( ):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes  :
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
