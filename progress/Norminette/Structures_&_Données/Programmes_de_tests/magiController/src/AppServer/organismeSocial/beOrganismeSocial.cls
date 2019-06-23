/*------------------------------------------------------------------------
File        : beOrganismeSocial.cls
Purpose     :
Author(s)   : GGA - 2017/08/10
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beOrganismeSocial.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beOrganismeSocial", URI="/beOrganismeSocial", schemaName="dsbeOrganismeSocial", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class organismeSocial.beOrganismeSocial:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {organismeSocial/include/organismeSocial.i}

    define dataset dsbeOrganismeSocial for ttOrganismeSocial, ttError.

    constructor public beOrganismeSocial():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/

    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeOrganismeSocial(pcFiltre as longchar, output dataset dsbeOrganismeSocial):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc       as handle    no-undo.
        define variable vhttFilter   as handle    no-undo.
        define variable vhBuffer     as handle    no-undo.
        define variable vcTypeListe  as character no-undo.
        define variable vcSerialName as character no-undo.
        
        dataset dsbeOrganismeSocial:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeListe = vhBuffer::cTypeListe no-error.
            end.
        end.
        delete object vhttFilter no-error.
        vhProc = outilHandle:connectMaGIModele("organismeSocial/organismeSocial.p").
        run getOrganismeSocial in vhProc(vcTypeListe, output table ttOrganismeSocial).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beOrganismeSocial ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
