/*------------------------------------------------------------------------
File        : beCle.cls
Purpose     : 
Author(s)   : KANTENA - 2016/07/27
Notes       : 
derniere revue: 2018/05/23 - phm : OK
------------------------------------------------------------------------*/

@program FILE(name="beCle.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beCle", URI="/beCle", schemaName="dsbeClemi", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class mandat.beCle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {mandat/include/clemi.i}
    define dataset dsbeclemi for ttClemi, ttError.

    constructor public beCle():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeCle(pcFiltre as longchar, output dataset dsbeClemi):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc           as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable viNumeroMandat   as int64     no-undo.
        define variable vcTypeMandat     as character no-undo.
        define variable viNumeroImmeuble as integer   no-undo.
        define variable vcStatutCle      as character no-undo.

        dataset dsbeclemi:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroMandat   = vhBuffer::iNumeroMandat   no-error.
                vcTypeMandat     = vhBuffer::cTypeMandat     no-error.
                viNumeroImmeuble = vhBuffer::iNumeroImmeuble no-error.
                vcStatutCle      = vhBuffer::cStatutCle      no-error.      // "TOUT" Toutes les clés sinon que les valides
            end.
        end.
        delete object vhttFilter no-error.
        vhProc = outilHandle:connectMaGIModele("mandat/clemi.p").
        run getClemi  in vhProc(viNumeroMandat, vcTypeMandat, viNumeroImmeuble, vcStatutCle, output table ttClemi).  
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeCle(input-output dataset dsbeClemi):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeCle(input-output dataset dsbeClemi):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeCle(input-output dataset dsbeClemi):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beCle( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor. 

end class.
