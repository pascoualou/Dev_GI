/*------------------------------------------------------------------------
File        : beWorkflow.cls
Purpose     :
Author(s)   : GGA - 2017/04/19
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beWorkflow.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beWorkflow", URI="/beWorkflow", schemaName="dsbeWorkflow", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class commercialisation.beWorkflow:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {commercialisation/include/workflow.i}

    define dataset dsbeWorkflow for ttworkflow, ttError.

    constructor public beWorkflow():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeWorkflow(output dataset dsbeWorkflow):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        dataset dsbeWorkflow:empty-dataset().
        vhProc = outilHandle:connectMaGIModele("commercialisation/workflow.p").
        run getRelationWorkflow in vhProc(output table ttWorkflow).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

   destructor public beWorkflow( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
