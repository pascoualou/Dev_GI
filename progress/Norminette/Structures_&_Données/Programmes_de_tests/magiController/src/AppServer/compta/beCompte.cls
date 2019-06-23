/*------------------------------------------------------------------------
File        : beCompte.cls
Syntax      :
Author(s)   : GI/Rfa - 2017/01/16
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beCompte.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beCompte", URI="/beCompte", schemaName="dsbeCompte", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class compta.beCompte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {compta/include/listeCompte.i}
    define dataset dsbeListeCompte for ttListeCompte, ttError.

    constructor public beCompte():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeCompte(pcFiltre as longchar, output dataset dsbeListeCompte):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcCompte      as handle    no-undo.
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroSociete',   integer(vhBuffer::iNumeroSociete))   no-error.
                goCollection:set('cRegroupement',    vhBuffer::cRegroupement)             no-error.
                goCollection:set('iTypeCompteDebut', integer(vhBuffer::iTypeCompteDebut)) no-error.
                goCollection:set('iTypeCompteFin',   integer(vhBuffer::iTypeCompteFin))   no-error. 
            end.
        end.
        delete object vhttFilter no-error.
                  
        dataset dsbeListeCompte:empty-dataset().
        vhProcCompte = outilHandle:connectMaGIModele("compta/compte.p").
        run getListeCompte in vhProcCompte(goCollection, output table ttListeCompte).
        run getErrors      in vhProcCompte(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beCompte( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
