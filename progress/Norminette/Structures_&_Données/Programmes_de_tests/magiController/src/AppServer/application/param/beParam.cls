/*------------------------------------------------------------------------
File        : beParam.cls
Purpose     : 
Author(s)   : kantena - 2016/07/12
Notes       : 
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beParam.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beParam", URI="/beParam", schemaName="dsbeParam", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class application.param.beParam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {application/include/param.i}
    define dataset dsbeparam for ttparam.

    constructor public beParam():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeParam(pcFiltre as longchar, output dataset dsbeParam):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc      as handle    no-undo.
        define variable vhttFilter  as handle    no-undo.
        define variable vhBuffer    as handle    no-undo.
        define variable vcNomTable  as character no-undo.
        define variable vcTypeParam as character no-undo.

        empty temp-table ttparam.
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcNomTable  = vhBuffer::cNomTable  no-error.
                vcTypeParam = vhBuffer::cTypeParam no-error.
            end.
        end.
        delete object vhttFilter no-error.
        vhProc = outilHandle:connectMaGIModele("application/param/parametre.p").
        run getParam  in vhProc(vcNomTable, vcTypeParam, output table ttparam).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeParam(input-output dataset dsbeParam):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeParam(input-output dataset dsbeParam):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeParam(input-output dataset dsbeParam):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beParam ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
