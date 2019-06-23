/*------------------------------------------------------------------------
File        : beDemandeDeDevis
Purpose     :
Author(s)   : kantena - 2016/07/20
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}

@program FILE(name="beDemandeDeDevis.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beDemandeDeDevis", URI="/beDemandeDeDevis", schemaName="dsbeDemandeDeDevis", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.intervention.beDemandeDeDevis:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy as logical no-undo initial true private get. public set.
    {travaux/include/demandeDeDevis.i}
    {travaux/include/detailsIntervention.i}
    {application/include/error.i}
    {immeubleEtLot/include/lot.i}
    {tiers/include/fournisseur.i}

    define buffer gbttLot   for ttListeLot.
    define buffer gbttError for ttError.
    define dataset dsbeDemandeDeDevis for ttDemandeDeDevis, ttDetailsIntervention, ttFournisseur, ttListeLot, ttError
    data-relation lots for ttDemandeDeDevis, ttListeLot
        relation-fields (ttDemandeDeDevis.iNumeroDemandeDeDevis, ttListeLot.iNumeroTraitement).
    define dataset dsbeLot for gbttLot, gbttError.

    constructor public beDemandeDeDevis():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeDemandeDeDevis(pcFiltre as longchar, output dataset dsbeDemandeDeDevis):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle no-undo.
        define variable vhttFilter as handle no-undo.
        define variable vhBuffer   as handle no-undo.
        define variable vrRowid    as rowid  no-undo.

        empty temp-table ttDemandeDeDevis.
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

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/demandeDeDevis.p").
        if vrRowid = ?
        then run getDemandeDeDevis      in vhProc(goCollection, output table ttDemandeDeDevis, output table ttDetailsIntervention).
        else run getDemandeDeDevisRowid in vhProc(vrRowid, output table ttDemandeDeDevis, output table ttDetailsIntervention).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeDemandeDeDevis(input-output dataset dsbeDemandeDeDevis):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc1 as handle no-undo.
        define variable vhProc2 as handle no-undo.

        assign
            vhProc1 = outilHandle:connectMaGIModele("travaux/intervention/demandeDeDevis.p")
            vhProc2 = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
        .
        run createDemandeDeDevis in vhProc1(table ttDemandeDeDevis, table ttFournisseur, table ttError, output table ttDemandeDeDevis2).  // en creation, on a besoin de la mise à jour de iNumeroDemandeDeDevis
        run getErrors            in vhProc1(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run updateLienLot in vhProc2({&TYPEINTERVENTION-demande2devis}, table ttDemandeDeDevis2, table ttListeLot).
        dataset dsbeDemandeDeDevis:empty-dataset().
        run getErrors in vhProc1(output table ttError).
        /* MAJ des temp tables CRUD et timestamp et validation de la transaction */
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeDemandeDeDevis(input-output dataset dsbeDemandeDeDevis):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc1 as handle no-undo.
        define variable vhProc2 as handle no-undo.

        assign
            vhProc1 = outilHandle:connectMaGIModele("travaux/intervention/demandeDeDevis.p")
            vhProc2 = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
        .
        run UpdateDemandeDeDevis in vhProc1(table ttDemandeDeDevis, output table ttDemandeDeDevis2).
        run getErrors            in vhProc1(output table ttError).
        if not can-find(first ttError where ttError.iType >= {&error})
        then run updateLienLot   in vhProc2({&TYPEINTERVENTION-demande2devis}, table ttDemandeDeDevis2, table ttListeLot).
        dataset dsbeDemandeDeDevis:empty-dataset().
        run getErrors in vhProc1(output table ttError).
        /* MAJ des temp tables CRUD et timestamp et validation de la transaction */
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeDemandeDeDevis(pcfiltre as longchar, output dataset dsbeDemandeDeDevis):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle  no-undo.
        define variable vhttFilter as handle  no-undo.
        define variable vhBuffer   as handle  no-undo.

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

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/demandeDeDevis.p").
        run deleteDemandeDeDevis in vhProc(goCollection).
        run getErrors            in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void duplicateDemandeDeDevis(input-output dataset dsbeDemandeDeDevis):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/demandeDeDevis.p").
        run duplicationDemandeDeDevis in vhProc(table ttDemandeDeDevis, table ttFournisseur, table ttError).
        dataset dsbeDemandeDeDevis:empty-dataset().
        run getErrors in vhProc(output table ttError).
        /* MAJ des temp tables CRUD et timestamp et validation de la transaction */
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void cloturebeDemandeDeDevis (pcFiltre as longchar):
        /*------------------------------------------------------------------------------
        Purpose: cloture un signalement
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

        goCollection:set('cCodeTraitement', {&TYPEINTERVENTION-demande2devis}).
        vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
        run cloture in vhProc(goCollection).
        dataset dsbeDemandeDeDevis:empty-dataset().
        run getErrors in vhProc(output table ttError).
        /* MAJ des temp tables CRUD et timestamp et validation de la transaction */
        {outils/include/tryCatch.i}
    end method.

    destructor public beDemandeDeDevis( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
