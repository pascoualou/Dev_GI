/*------------------------------------------------------------------------
File        : beOrdreDeService
Purpose     :
Author(s)   : kantena - 2016/08/10
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}

@program FILE(name="beOrdreDeService.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beOrdreDeService", URI="/beOrdreDeService", schemaName="dsbeOrdreDeService", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.intervention.beOrdreDeService:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy as logical no-undo initial true private get. public set.
    {travaux/include/ordreDeService.i}
    {travaux/include/detailsIntervention.i}
    {immeubleEtLot/include/lot.i}
    {application/include/error.i}

    define buffer gbttListeLot for ttListeLot.
    define buffer gbttError    for ttError.
    define dataset dsbeOrdreDeService for ttOrdreDeService, ttDetailsIntervention, ttListeLot, ttError
    data-relation lots for ttOrdreDeService, ttListeLot
        relation-fields (ttOrdreDeService.iNumeroOrdreDeService, ttListeLot.iNumeroTraitement).
    define dataset dsbeLot for gbttListeLot, gbttError.

    constructor public beOrdreDeService():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void ReadbeOrdreDeService(pcFiltre as longchar, output dataset dsbeOrdreDeService):
    /*------------------------------------------------------------------------------
    Purpose: Get one or more records, based on a filter string
    Notes:
    ------------------------------------------------------------------------------*/
        define variable vhProc               as handle    no-undo.
        define variable vhttFilter           as handle    no-undo.
        define variable vhBuffer             as handle    no-undo.
        define variable vrRowid              as rowid     no-undo.

        dataset dsbeOrdreDeService:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('cTypeMandat',         vhBuffer::cTypeMandat) no-error.
                goCollection:set('iNumeroMandat',       int64(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroTraitement',   int64(vhBuffer::iNumeroTraitement)) no-error.
                goCollection:set('iNumeroIntervention', integer(vhBuffer::iNumeroIntervention)) no-error.
                vrRowid = to-rowid(vhBuffer::rRowid) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/ordreDeService.p").
        if vrRowId = ?
        then run getOrdreDeService      in vhProc (goCollection, output table ttOrdreDeService, output table ttDetailsIntervention).
        else run getOrdreDeServiceRowid in vhProc (vrRowId, output table ttOrdreDeService, output table ttDetailsIntervention).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeOrdreDeService (input-output dataset dsbeOrdreDeService):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc1 as handle no-undo.
        define variable vhProc2 as handle no-undo.

        assign
            vhProc1 = outilHandle:connectMaGIModele("travaux/intervention/ordreDeService.p")
            vhProc2 = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
        .
        run createOrdreDeService in vhProc1(input-output table ttOrdreDeService, table ttDetailsIntervention, table ttError).         // en creation, on a besoin de la mise à jour de iNumeroOrdreDeService
        run getErrors            in vhProc1(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run updateLienLot in vhProc2({&TYPEINTERVENTION-ordre2service}, table ttOrdreDeService, table ttListeLot).
        dataset dsbeOrdreDeService:empty-dataset().
        run getErrors in vhProc1(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeOrdreDeService (input-output dataset dsbeOrdreDeService):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc1 as handle no-undo.
        define variable vhProc2 as handle no-undo.

        assign
            vhProc1 = outilHandle:connectMaGIModele("travaux/intervention/ordreDeService.p")
            vhProc2 = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
        .
        run updateOrdreDeService in vhProc1(input-output table ttOrdreDeService, table ttDetailsIntervention, table ttError).
        run getErrors            in vhProc1(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run updateLienLot in vhProc2({&TYPEINTERVENTION-ordre2service}, table ttOrdreDeService, table ttListeLot).
        dataset dsbeOrdreDeService:empty-dataset().
        run getErrors in vhProc1(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeOrdreDeService (pcfiltre as longchar, output dataset dsbeOrdreDeService):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc                as handle    no-undo.
        define variable vhttFilter            as handle    no-undo.
        define variable vhBuffer              as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroTraitement', int64(vhBuffer::iNumeroTraitement)) no-error.
                goCollection:set('iNumeroMandat',     integer(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('cTypeMandat',       vhBuffer::cTypeMandat) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/ordreDeService.p").
        run deleteOrdreDeService in vhProc (goCollection).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void cloturebeOrdreDeService(pcFiltre as longchar, output dataset dsbeOrdreDeService):
        /*------------------------------------------------------------------------------
        Purpose: cloture un ordre de service
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle no-undo.
        define variable vhttFilter as handle no-undo.
        define variable vhBuffer   as handle no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroIntervention', integer(vhBuffer::iNumeroIntervention)) no-error.
                goCollection:set('iNumeroTraitement',   int64(vhBuffer::iNumeroTraitement)) no-error.
                goCollection:set('cCodeCloture',        vhBuffer::cCodeCloture) no-error.
                goCollection:set('cCommentaireCloture', vhBuffer::cCommentaireCloture) no-error.
                goCollection:set('cLibelleCloture',     vhBuffer::cLibelleCloture) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        goCollection:set('cCodeTraitement', {&TYPEINTERVENTION-ordre2service}).
        vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
        run cloture in vhProc (goCollection).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void updateBAPbeOrdreDeService(pcFiltre as longchar, output dataset dsbeOrdreDeService):
        /*------------------------------------------------------------------------------
        Purpose: Bon à payer
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc               as handle    no-undo.
        define variable vhttFilter           as handle    no-undo.
        define variable vhBuffer             as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroOrdreService', int64(vhBuffer::iNumeroOrdreService)) no-error.
                goCollection:set('iNumeroMandat',       int64(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('cTypeMandat',         vhBuffer::cTypeMandat) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/ordreDeService.p").
        run bonAPayer in vhProc (goCollection).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beOrdreDeService ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
