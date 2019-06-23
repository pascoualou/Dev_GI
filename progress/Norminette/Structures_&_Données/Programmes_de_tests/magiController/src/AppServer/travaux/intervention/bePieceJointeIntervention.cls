/*------------------------------------------------------------------------
File        : bePieceJointe.cls
Purpose     :
Author(s)   : kantena - 2016/02/11
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/

@program FILE(name="bePieceJointe.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="bePieceJointe", URI="/bePieceJointe", schemaName="dsbePieceJointe", schemaFile="magiController/src/AppServer/travaux/include/pieceJointe.i").

using outils.outilHandle.
using outils.outilFileTransfert.
using outils.collection.

block-level on error undo, throw.

class travaux.intervention.bePieceJointeIntervention:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy as logical no-undo initial true private get. public set.
    define variable goOutilTransfert as class outils.outilFileTransfert no-undo.
    {outils/include/pieceJointe.i}
    {application/include/error.i}
    define dataset dsbePieceJointe for ttpiecejointe, ttError.

    constructor public bePieceJointeIntervention():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void ReadbePieceJointe (pcFiltre as longchar, output dataset dsbePieceJointe):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter          as handle    no-undo.
        define variable vhBuffer            as handle    no-undo.
        define variable vcLibelleTraitement as character no-undo.
        define variable viNumeroTraitement  as integer   no-undo.

        empty temp-table ttpiecejointe.
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcLibelleTraitement = vhBuffer::cLibelleTraitement         no-error.
                viNumeroTraitement  = integer(vhBuffer::iNumeroTraitement) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        goOutilTransfert = new outilFileTransfert().
        goOutilTransfert:getFileList(substitute("&1/&2", vcLibelleTraitement, viNumeroTraitement), output table ttPieceJointe).
        delete object goOutilTransfert.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void createbePieceJointe (input-output dataset dsbePieceJointe):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void DeletebePieceJointe (pcFiltre as longchar, output dataset dsbePieceJointe):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter          as handle    no-undo.
        define variable vhBuffer            as handle    no-undo.
        define variable vcLibelleTraitement as character no-undo.
        define variable viNumeroTraitement  as integer   no-undo.
        define variable vcNomFichier        as character no-undo.

        empty temp-table ttpiecejointe.
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcLibelleTraitement = vhBuffer::cLibelleTraitement no-error.
                viNumeroTraitement  = integer(vhBuffer::iNumeroTraitement) no-error.
                vcNomFichier        = vhBuffer::nomFichier no-error.
            end.
        end.
        delete object vhttFilter no-error.

        goOutilTransfert = new outilFileTransfert().
        goOutilTransfert:deleteFile(substitute("&1/&2/&3", vcLibelleTraitement, viNumeroTraitement, vcNomFichier), output table ttPieceJointe).
        delete object goOutilTransfert.
        {outils/include/tryCatch.i}
    end method.

    destructor public bePieceJointeIntervention ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
