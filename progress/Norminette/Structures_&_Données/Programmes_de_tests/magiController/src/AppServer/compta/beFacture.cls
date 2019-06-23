/*------------------------------------------------------------------------
File        : beFacture.cls
Description :
Author(s)   : kantena - 2017/05/02
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beFacture.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beFacture", URI="/beFacture", schemaName="dsbeFacture", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class compta.beFacture:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {compta/include/facture.i}
    define dataset dsbeFacture for ttFacture, ttError.

    constructor public beFacture():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    {outils/include/methodConversionDate.i}

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void rechercheFacture(pcFiltre as longchar, output dataset dsbefacture):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc           as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable vcFormatDate     as character no-undo.

        empty temp-table ttFacture.
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroFacture',      integer(vhBuffer::iNumeroFacture))  no-error.
                goCollection:set('iNumeroFactureDebut', integer(vhBuffer::iNumeroFacture1)) no-error.
                goCollection:set('iNumeroFactureFin',   integer(vhBuffer::iNumeroFacture2)) no-error.
                goCollection:set('iNumeroMandat',       integer(vhBuffer::iNumeroMandat))   no-error.
                goCollection:set('iNumeroMandatDebut',  integer(vhBuffer::iNumeroMandat1))  no-error.
                goCollection:set('iNumeroMandatFin',    integer(vhBuffer::iNumeroMandat2))  no-error.
                vcFormatDate = vhBuffer::cDateformat no-error.
                goCollection:set('daDateFactureDebut',  conversionDate(vcFormatDate, vhBuffer::daDateFacture1)) no-error.
                goCollection:set('daDateFactureFin',    conversionDate(vcFormatDate, vhBuffer::daDateFacture2)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("compta/facture.p").
        run rechercheFacture in vhProc(goCollection, output table ttFacture).
        run getErrors        in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeFacture(pcFiltre as longchar, output dataset dsbeFacture):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcFacture   as handle  no-undo.
        define variable vhttFilter      as handle  no-undo.
        define variable vhBuffer        as handle  no-undo.
        define variable viNumeroFacture as integer no-undo initial ?.
        define variable vrRowid         as rowid   no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroFacture = integer(vhBuffer::iNumeroFacture) no-error.
                vrRowid         = to-rowid(vhBuffer::rRowid)        no-error.
            end.
        end.
        delete object vhttFilter no-error.

        dataset dsbeFacture:empty-dataset().
        vhProcFacture = outilHandle:connectMaGIModele("compta/facture.p").
        if vrRowid <> ?
        then run getFactureByRowid in vhProcFacture(vrRowid, output table ttFacture).
        else run getFacture        in vhProcFacture(viNumeroFacture, output table ttFacture).
        run getErrors  in vhProcFacture(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeFacture(input-output dataset dsbeFacture):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeFacture(input-output dataset dsbeFacture):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeFacture(input-output dataset dsbeFacture):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beFacture( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
