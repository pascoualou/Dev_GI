/*------------------------------------------------------------------------
File        : beSignalement.cls
Description :
Author(s)   : kantena - 2016/02/12
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}

@program FILE(name="beSignalement.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beSignalement", URI="/beSignalement", schemaName="dsbeSignalement", schemaFile="magiController/src/AppServer/travaux/include/signalement.i").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.intervention.beSignalement:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy as logical no-undo initial true private get. public set.
    {travaux/include/signalement.i}
    {travaux/include/detailsIntervention.i}
    {immeubleEtLot/include/lot.i}
    {application/include/error.i}

    define buffer gbttListeLot for ttListeLot.
    define buffer gbttError    for ttError.
    define dataset dsbeSignalement  for ttSignalement, ttDetailsIntervention, ttListeLot, ttError
    data-relation lots for ttSignalement, ttListeLot
        relation-fields (ttSignalement.iNumeroSignalement, ttListeLot.iNumeroTraitement).
    define dataset dsbeLot for gbttListeLot, gbttError.

    constructor public beSignalement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void ReadbeSignalement(pcFiltre as longchar, output dataset dsbeSignalement):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vrRowId    as rowid     no-undo.

        empty temp-table ttSignalement.
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
                vrRowId = to-rowid(vhBuffer::rRowid) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/signalement.p").
        if vrRowId = ?
        then run getSignalement      in vhProc (goCollection, output table ttSignalement, output table ttDetailsIntervention).
        else run getSignalementRowId in vhProc (vrRowId, output table ttSignalement, output table ttDetailsIntervention).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeSignalement (input-output dataset dsbeSignalement):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc1  as handle no-undo.
        define variable vhProc2  as handle no-undo.

        assign
            vhProc1 = outilHandle:connectMaGIModele("travaux/intervention/signalement.p")
            vhProc2 = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
        .
        run createSignalement in vhProc1(input-output table ttSignalement).          // en creation, on a besoin de la mise à jour de iNumeroSignalement
        run getErrors         in vhProc1(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run updateLienLot in vhProc2({&TYPEINTERVENTION-signalement}, table ttSignalement, table ttListeLot).
        dataset dsbeSignalement:empty-dataset().
        run getErrors         in vhProc1(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void UpdatebeSignalement (input-output dataset dsbeSignalement):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc1 as handle no-undo.
        define variable vhProc2 as handle no-undo.

        assign
            vhProc1 = outilHandle:connectMaGIModele("travaux/intervention/signalement.p")
            vhProc2 = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
        .
        run updateSignalement in vhProc1(table ttSignalement).
        run getErrors         in vhProc1(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run updateLienLot in vhProc2 ({&TYPEINTERVENTION-signalement}, table ttSignalement, table ttListeLot).
        dataset dsbeSignalement:empty-dataset().
        run getErrors         in vhProc1(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void DeletebeSignalement (pcfiltre as longchar, output dataset dsbeSignalement):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
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
                goCollection:set('iNumeroTraitement', int64(vhBuffer::iNumeroTraitement)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/signalement.p").
        run deleteSignalement in vhProc(goCollection).
        run getErrors         in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="", alias="", mediaType="application/json").
    method public void ReadbeSignalementExtranet(pcFiltre as longchar, output dataset dsbeSignalement):
        /*------------------------------------------------------------------------------
        Purpose: Récupère les information de ticketing extranet
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/signalement.p").
        run getSignalementExtranet in vhProc(output table ttSignalement).
        run getErrors              in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void cloturebeSignalement(pcFiltre as longchar):
        /*------------------------------------------------------------------------------
        Purpose: cloture un signalement
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
                goCollection:set('iNumeroIntervention', integer(vhBuffer::iNumeroIntervention)) no-error.
                goCollection:set('iNumeroTraitement',   int64(vhBuffer::iNumeroTraitement)) no-error.
                goCollection:set('cCodeCloture',        vhBuffer::cCodeCloture) no-error.
                goCollection:set('cCommentaireCloture', vhBuffer::cCommentaireCloture) no-error.
                goCollection:set('cLibelleCloture',     vhBuffer::cLibelleCloture) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        goCollection:set('cCodeTraitement', {&TYPEINTERVENTION-signalement}).
        vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
        run cloture   in vhProc(goCollection).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beSignalement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
