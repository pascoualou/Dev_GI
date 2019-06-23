/*------------------------------------------------------------------------
File        : beMajInfoGpsSurAdresse.cls
Purpose     :
Author(s)   : LGI/NPO - 2016/12/07
Notes       :
derniere revue: 2018/05/22 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beMajInfoGpsSurAdresse.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beMajInfoGpsSurAdresse", URI="/beMajInfoGpsSurAdresse", schemaName="dsbeMajInfoGpsSurAdresse", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class adresse.beMajInfoGpsSurAdresse:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {adresse/include/listeMajInfoGpsSurAdresse.i}
    {application/include/error.i}

    define dataset dsbeMajInfoGpsSurAdresse
        for ttListeMajInfoGpsSurAdresse, ttError.

    constructor public beMajInfoGpsSurAdresse():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readListeAdresse(pcFiltre as longchar, output dataset dsbeMajInfoGpsSurAdresse):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle no-undo.
        define variable vhttFilter as handle no-undo.
        define variable vhBuffer   as handle no-undo.

        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iSociete'   , integer(vhBuffer::iCodeSociete)) no-error.
                goCollection:set('iImm'       , integer(vhBuffer::iImm))         no-error.
                goCollection:set('iImmDeb'    , integer(vhBuffer::iImm1))        no-error.
                goCollection:set('iImmFin'    , integer(vhBuffer::iImm2))        no-error.
                goCollection:set('cFourCle'   , vhBuffer::cFourCle)   no-error.
                goCollection:set('cFourCleDeb', vhBuffer::cFourCle1)  no-error.
                goCollection:set('cFourCleFin', vhBuffer::cFourCle2)  no-error.
                goCollection:set('cCp'        , vhBuffer::cCp)        no-error.
                goCollection:set('cCpDeb'     , vhBuffer::cCp1)       no-error.
                goCollection:set('cCpFin'     , vhBuffer::cCp2)       no-error.
            end.
        end.
        delete object vhttFilter no-error.

        dataset dsbeMajInfoGpsSurAdresse:empty-dataset().
        vhProc = outilHandle:connectMaGIModele("adresse/majInfoGpsSurAdresse.p").
        run listeadresse in vhProc(goCollection, output table ttListeMajInfoGpsSurAdresse).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beMajInfoGpsSurAdresse( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
