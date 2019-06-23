/*------------------------------------------------------------------------
File        : beFournisseur.cls
Purpose     :
Author(s)   : kantena - 2016/09/12
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beFournisseur.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beFournisseur", URI="/beFournisseur", schemaName="dsbeFournisseur", schemaFile="").

using outils.outilHandle.
using outils.collection.
block-level on error undo, throw.

class tiers.beFournisseur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {tiers/include/fournisseur.i}
    {tiers/include/ibanFournisseur.i}
    define dataset dsbeFournisseur  for ttFournisseur, ttibanFournisseur, ttError
        data-relation ibanSimple for ttFournisseur, ttibanFournisseur nested foreign-key-hidden
            relation-fields (ttFournisseur.cCodeFournisseur, ttibanFournisseur.cCodeFournisseur,
                             ttFournisseur.iCodeSociete,     ttibanFournisseur.iCodeSociete).

    constructor public beFournisseur():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeFournisseur(pcFiltre as longchar, output dataset dsbeFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcFournisseur as handle    no-undo.
        define variable vcTypeMandat      as character no-undo.
        define variable viNumeroDevis     as integer   no-undo.
        define variable vcAction          as character no-undo.
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.

        dataset dsbeFournisseur:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeMandat  = vhBuffer::cTypeMandat no-error.
                viNumeroDevis = vhBuffer::iNumeroDevis no-error.
                vcAction      = vhBuffer::cAction no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcFournisseur = outilHandle:connectMaGIModele("tiers/fournisseur.p").
        case vcAction:
            when 'DUPLICATION_DEVIS' then run getListeFournisseurDuplicationDevis in vhProcFournisseur(viNumeroDevis, vcTypeMandat, output table ttFournisseur).
        end case.
        run getErrors in vhProcFournisseur(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeFournisseur(input-output dataset dsbeFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeFournisseurSimple(input-output dataset dsbeFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcFournisseur as handle no-undo.

        vhProcFournisseur = outilHandle:connectMaGIModele("tiers/fournisseur.p").
        run createFournisseurSimple in vhProcFournisseur(table ttFournisseur, table ttibanFournisseur, table ttError).
        dataset dsbeFournisseur:empty-dataset().
        run getErrors in vhProcFournisseur(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void readbeFournisseurSimple(pcFiltre as longchar, output dataset dsbeFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcFournisseur as handle no-undo.
        define variable vhttFilter        as handle no-undo.
        define variable vhBuffer          as handle no-undo.

        define variable vrRowId           as rowid     no-undo.
        define variable viCodeSociete     as integer   no-undo.
        define variable vcCodeFournisseur as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vrRowId           = to-rowid(vhBuffer::rRowid)      no-error.
                viCodeSociete     = integer(vhBuffer::iCodeSociete) no-error.
                vcCodeFournisseur = vhBuffer::cCodeFournisseur      no-error.
            end.
        end.
        delete object vhttFilter no-error.

        dataset dsbeFournisseur:empty-dataset().
        vhProcFournisseur = outilHandle:connectMaGIModele("tiers/fournisseur.p").
        if vrRowid <> ?
        then run getFournisseurSimpleByRowid in vhProcFournisseur(vrRowid, output table ttFournisseur, output table ttibanFournisseur).
        else run getFournisseurSimple        in vhProcFournisseur(viCodeSociete, vcCodeFournisseur, output table ttFournisseur, output table ttibanFournisseur).
        run getErrors  in vhProcFournisseur(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeFournisseur(input-output dataset dsbeFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeFournisseur(input-output dataset dsbeFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beFournisseur( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
