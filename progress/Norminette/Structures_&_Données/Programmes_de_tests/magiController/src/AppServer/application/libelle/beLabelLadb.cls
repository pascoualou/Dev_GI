/*------------------------------------------------------------------------
File        : beLabelLadb.cls
Purpose     :
Author(s)   : kantena - 2016/02/11
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beLabelLadb.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beLabelLadb", URI="/beLabelLadb", schemaName="dsbeLabelLadb", schemaFile="magiController/src/AppServer/application/include/labelLadb.i").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class application.libelle.beLabelLadb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {application/include/labelLadb.i}
    {application/include/combo.i}
    define dataset dsbeLabelLadb for ttsys_lb, ttCombo, ttInitValue, ttError.

    constructor public beLabelLadb():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeLabelLadb(pcFiltre as longchar, output dataset dsbeLabelLadb):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc        as handle    no-undo.
        define variable vhttFilter    as handle    no-undo.
        define variable vhBuffer      as handle    no-undo.
        define variable vcListeChamp  as character no-undo.
        define variable vcComboFilter as character no-undo.
        define variable vcPage        as character no-undo.
        define variable vcInitValue   as character no-undo.

        dataset dsbeLabelLadb:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first('WHERE champ = "listeChamps"') no-error.
            if vhBuffer:available then vcListeChamp = vhBuffer::valeur.
            vhBuffer:find-first('WHERE champ = "ComboFilter"') no-error.
            if vhBuffer:available then vcComboFilter = vhBuffer::valeur.
            vhBuffer:find-first('WHERE champ = "cPage"') no-error.
            if vhBuffer:available then vcPage = vhBuffer::valeur.
            vhBuffer:find-first('WHERE champ = "cInitValue"') no-error.
            if vhBuffer:available then vcInitValue = vhBuffer::valeur.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("application/libelle/labelLadb.p").
        if vcListeChamp > ''  then run getListelabel in vhProc(vcListeChamp,  output table ttsys_lb) no-error.
        if vcPage > ''        then run getPagelabel  in vhProc(vcPage,        output table ttsys_lb append) no-error.
        if vcComboFilter > '' then run getCombolabel in vhProc(vcComboFilter, output table ttcombo) no-error.
        if vcInitValue > ''   then run getInitValue  in vhProc(vcInitValue,   output table ttInitValue) no-error.
        run getErrors in vhProc (output table ttError) no-error.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeLabelLadb(input-output dataset dsbeLabelLadb):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeLabelLadb(input-output dataset dsbeLabelLadb):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeLabelLadb(input-output dataset dsbeLabelLadb):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beLabelLadb ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
