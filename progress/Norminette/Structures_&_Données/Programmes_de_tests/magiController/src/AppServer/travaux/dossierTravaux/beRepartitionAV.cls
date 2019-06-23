/*------------------------------------------------------------------------
File        : beRepartitionAV.cls
Syntax      : 
Author(s)   : gg  -  2017/03/07
Notes       : 
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beRepartitionAV.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beRepartitionAV", URI="/beRepartitionAV", schemaName="dsbeRepartitionAV", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.dossierTravaux.beRepartitionAV:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {travaux/include/dossierTravaux.i}
    {travaux/include/repartitionAV.i}
    {travaux/include/editionAno.i}
    {application/include/combo.i}
    {application/include/error.i}
    define dataset dsbeRepartitionAV for ttDossierTravaux,
                                         ttRepartitionAV, 
                                         ttInfSelRepartitionAV, 
                                         ttCombo, 
                                         ttEdtAno, 
                                         ttError.

    constructor public beRepartitionAV():
        /*------------------------------------------------------------------------------
        Purpose: 
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="get", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void GetRepartitionAV(input pcFiltre as longchar, output DATASET dsbeRepartitionAV):
        /*------------------------------------------------------------------------------
        Purpose: 
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
                goCollection:set('iNumeroMandat',         integer(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroDossierTravaux', integer(vhBuffer::iNumeroDossierTravaux)) no-error.
                goCollection:set('iNumeroImmeuble',       integer(vhBuffer::iNumeroImmeuble)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        dataset dsbeRepartitionAV:empty-dataset().        
        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/repartitionAV.p").       
        run getRepartitionAV in vhProc (goCollection, 
                                        input-output table ttDossierTravaux,
                                        output table ttRepartitionAV,
                                        output table ttInfSelRepartitionAV,
                                        output table ttCombo).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void UpdateRepartitionAV(input pcFiltre as longchar, input-output DATASET dsbeRepartitionAV):
        /*------------------------------------------------------------------------------
        Purpose: 
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
                goCollection:set('cTypeMandat', vhBuffer::cTypeMandat) no-error.
                goCollection:set('iNumeroMandat', integer(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroDossierTravaux', integer(vhBuffer::iNumeroDossierTravaux)) no-error.
                goCollection:set('iNumeroImmeuble', integer(vhBuffer::iNumeroImmeuble)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/repartitionAV.p").       
        run validationrepartition in vhProc (
            table ttError,
            input-output table ttDossierTravaux,
            input-output table ttRepartitionAV,
            input-output table ttInfSelRepartitionAV,
            input-output table ttCombo,
            output table ttEdtAno
        ).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void CalculPrctRepartitionAV(input pcFiltre as longchar, input-output DATASET dsbeRepartitionAV):
        /*------------------------------------------------------------------------------
        Purpose: 
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
                goCollection:set('iNumeroMandat',         integer(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroDossierTravaux', integer(vhBuffer::iNumeroDossierTravaux)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/repartitionAV.p").       
        run CalculPrctRepartitionAV in vhProc (goCollection, 
                                               table ttDossierTravaux,
                                               input-output table ttRepartitionAV,
                                               input-output table ttInfSelRepartitionAV).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.
    
    destructor public beRepartitionAV( ):
        /*------------------------------------------------------------------------------
        Purpose: 
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
