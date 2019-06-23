/*------------------------------------------------------------------------
File        : beSoldeCompte.cls
Syntax      :
Author(s)   : gg  -  2017/03/21
Notes       : appel solde compte
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beSoldeCompte.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beSoldeCompte", URI="/beSoldeCompte", schemaName="dsbeSoldeCompte", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class compta.beSoldeCompte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {compta/include/soldeCompte.i}
    define dataset dsbeSoldeCompte for ttSoldeCompte, ttError.

    constructor public beSoldeCompte():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readSoldeCompte(pcFiltre as longchar, output dataset dsbeSoldeCompte):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        {&_proparse_ prolint-nowarn(varusage)}
        define variable vhProcSoldeCompte as handle    no-undo.
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.
        define variable vcTypeMandat      as character no-undo.
        define variable viNumeroMandat    as int64     no-undo.
        define variable vcCpt             as character no-undo.
        define variable vcTypeSolde       as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeMandat   = vhBuffer::cTypeMandat   no-error.
                viNumeroMandat = vhBuffer::iNumeroMandat no-error.
                vcCpt          = vhBuffer::cCpt          no-error.
                vcTypeSolde    = vhBuffer::cTypeSolde    no-error.
            end.
        end.

        vhProcSoldeCompte = outilHandle:connectMaGIModele("compta/soldeCompte.p").
        run getSoldeCompte in vhProcSoldeCompte(vcTypeMandat, viNumeroMandat, vcCpt, vcTypeSolde, output table ttSoldeCompte).
        run getErrors      in vhProcSoldeCompte(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beSoldeCompte( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
