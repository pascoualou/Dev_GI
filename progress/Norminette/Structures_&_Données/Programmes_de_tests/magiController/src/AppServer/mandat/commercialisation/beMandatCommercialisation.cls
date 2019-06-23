/*------------------------------------------------------------------------
File        : beMandatCommercialisation.cls
Purpose     :
Author(s)   : KANTENA - 2016/08/04
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beMandatCommercialisation.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beMandatCommercialisation", URI="/beMandatCommercialisation", schemaName="dsbeMandatCommercialisation", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class mandat.commercialisation.beMandatCommercialisation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {mandat/include/mandat.i &nomtable=ttMandatCommercialisation &serialName=ttMandatCommercialisation}
    define dataset dsbeMandatCommercialisation for ttMandatCommercialisation, ttError.

    constructor public beMandatCommercialisation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeMandatCommercialisation(pcFiltre as longchar, output dataset dsbeMandatCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcMandat    as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroContrat as integer   no-undo.
        define variable vcTypeContrat   as character no-undo.

        dataset dsbeMandatCommercialisation:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroContrat = integer(vhBuffer::valeur) no-error.
                vcTypeContrat   = vhBuffer::valeur no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcMandat = outilHandle:connectMaGIModele("mandat/mandat.p").
        run getMandat in vhProcMandat(viNumeroContrat, vcTypeContrat, output table ttMandatCommercialisation).
        run getErrors in vhProcMandat(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeMandatCommercialisation(input-output dataset dsbeMandatCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeMandatCommercialisation(input-output dataset dsbeMandatCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeMandatCommercialisation(input-output dataset dsbeMandatCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beMandatCommercialisation( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
