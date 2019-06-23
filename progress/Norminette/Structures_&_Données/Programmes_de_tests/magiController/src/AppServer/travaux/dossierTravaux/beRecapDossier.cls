/*------------------------------------------------------------------------
File        : beRecapDossier.cls
Purpose     :
Author(s)   : gga - 2017/04/05
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
@program FILE(name="beRecapDossier.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beRecapDossier", URI="/beRecapDossier", schemaName="dsbeRecapDossier", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.dossierTravaux.beRecapDossier:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {travaux/include/DossierTravaux.i}
    {application/include/error.i}
    define dataset dsbeRecapDossier for ttRecapDossierTravaux, ttError.
    
    constructor public beRecapDossier():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void readbeRecapDossier(pcFiltre as longchar, output dataset dsbeRecapDossier):
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

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/recapDossier.p").       
        run getrecapDossier in vhProc (goCollection, output table ttRecapDossierTravaux).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beRecapDossier ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
