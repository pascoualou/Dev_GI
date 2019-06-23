/*------------------------------------------------------------------------
File        : beSuiviFinancier.cls
Syntax      : 
Author(s)   : OF - 2016-11-23
Notes       : 
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beSuiviFinancier.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beSuiviFinancier", URI="/beSuiviFinancier", schemaName="dsbeSuiviFinancier", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.dossierTravaux.beSuiviFinancier:
    /*------------------------------------------------------------------------------
    Purpose:                                                                      
    Notes:                                                                        
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {travaux/include/SuiviFinancier.i}
    define buffer gbttError for ttError.   
    define dataset dsbeListeSuiviFinancier  for ttListeSuiviFinancierClient, ttListeSuiviFinancierTravaux, ttError.
    define dataset dsbeDetailSuiviFinancier for ttDetailSuiviFinancierClient, gbttError.

    constructor public beSuiviFinancier():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void readbeListeSuiviFinancier(pcFiltre as longchar, output dataset dsbeListeSuiviFinancier):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc          as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroDossier as integer   no-undo.
        define variable viNumeroMandat  as integer   no-undo.
        define variable vcTypeMandat    as character no-undo.

        dataset dsbeListeSuiviFinancier:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeMandat    = vhBuffer::valeur          no-error.
                viNumeroMandat  = integer(vhBuffer::valeur) no-error.
                viNumeroDossier = integer(vhBuffer::valeur) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/suiviFinancier.p").       
        run getSuiviFinancier in vhProc (vcTypeMandat, viNumeroMandat, viNumeroDossier, "LISTE", ?, output table ttListeSuiviFinancierClient, output table ttDetailSuiviFinancierClient, output table ttListeSuiviFinancierTravaux).
        run getErrors         in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beSuiviFinancier( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
