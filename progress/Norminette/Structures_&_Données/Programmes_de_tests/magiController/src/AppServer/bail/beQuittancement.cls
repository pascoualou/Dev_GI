/*-----------------------------------------------------------------------------
File        : beQuittancement.cls
Syntax      :
Description :
Author(s)   : kantena - 2017/11/28
Notes       :
derniere revue: 2018/05/23 - phm: OK
-----------------------------------------------------------------------------*/
@program FILE(name="beBail.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beQuittancement", URI="/beQuittancement", schemaName="dsbeQuittancement", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class bail.beQuittancement: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goGlobalCollection as class collection no-undo private get. private set.
    define private property goCollection       as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {application/include/combo.i}
    {bail/include/quittancement.i}
    {bail/include/familleRubrique.i}
    define dataset dsbeQuittancement for ttQuittancement, ttFamilleRubrique, ttCombo, ttError.
    
    constructor public beQuittancement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            goGlobalCollection = new collection()
            goCollection       = new collection()
        .
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeQuittancement(pcFiltre as longchar, output pcQuittancement as longchar):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.

        dataset dsbeQuittancement:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set("cTypeRole",      vhBuffer::cTypeRole)               no-error.
                goCollection:set("iNumeroRole",    integer(vhBuffer::iNumeroRole))    no-error.
                goCollection:set("cTypeContrat",   vhBuffer::cTypeContrat)            no-error.
                goCollection:set("iNumeroContrat", integer(vhBuffer::iNumeroContrat)) no-error.
                vcVue = vhBuffer::cVue no-error.
            end.
        end.
        delete object vhttFilter no-error.
        
        case vcVue:
            when "COMBOPARAMETRAGE" then initCombo().
            when "SYNTHESE"         then readQuittancement().
            when "ENCOURS"          then.
            when "HISTORIQUE"       then.
            when "PARAMETRAGE"      then readParametrage().
        end case.
        // permet de générer le Json sans les champs ayant leur valeur par défaut - réduit la taille du flux!
        dataset dsbeQuittancement:write-json("LONGCHAR", pcQuittancement, false, ?, false, false, false).
        {outils/include/tryCatch.i}
    end method.

    method private void readQuittancement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc          as handle no-undo.
        define variable vhProcTransfert as handle no-undo.

        assign
            vhProc          = outilHandle:connectMaGIModele("bail/quittancement/quittancement.p")
            vhProcTransfert = outilHandle:connectMaGIModele("adblib/transfert/suiviTransfert_CRUD.p")
        .
        run getInfoTransfert in vhProcTransfert("QUIT", input-output goGlobalCollection).
        run getQuittance     in vhProc         (goGlobalCollection, goCollection, output table ttQuittancement, output table ttFamilleRubrique).
        run getErrors        in vhProc         (output table ttError).
    end method.

    method private void readParametrage():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc          as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("bail/quittancement/quittancement.p").
        run getParametrage in vhProc(goCollection, output table ttQuittancement).
        run getErrors      in vhProc(output table ttError).
    end method.

    method private void initCombo(): 
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("bail/quittancement/quittancement.p").
        run initCombo in vhProc(goCollection:getCharacter("cTypeContrat"), goCollection:getInteger("iNumeroContrat"), output table ttCombo).
        run getErrors in vhProc(output table ttError).
    end method.

    destructor public beQuittancement ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
