/*------------------------------------------------------------------------
File        : beReponseFournisseur.cls
Purpose     :
Author(s)   : kantena - 2016/08/29
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}

@program FILE(name="beReponseFournisseur.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beReponseFournisseur", URI="/beReponseFournisseur", schemaName="dsbeReponseFournisseur", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.intervention.beReponseFournisseur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy as logical no-undo initial true private get. public set.
    {travaux/include/reponseFournisseur.i}
    {travaux/include/detailsIntervention.i}
    {application/include/error.i}
    define dataset dsbeReponseFournisseur for ttReponseFournisseur, ttDetailsIntervention, ttError
        data-relation lienDetailsIntervention for ttReponseFournisseur, ttDetailsIntervention
            relation-fields(iNumeroDemandeDeDevis, iNumeroTraitement).

    constructor public beReponseFournisseur():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeReponseFournisseur (pcFiltre as longchar, output dataset dsbeReponseFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc               as handle    no-undo.
        define variable vhttFilter           as handle    no-undo.
        define variable vhBuffer             as handle    no-undo.
        define variable vrRowid              as rowid     no-undo.

        empty temp-table ttReponseFournisseur.
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

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/reponseFournisseur.p").
        if vrRowid = ?
        then run getReponseFournisseur      in vhProc (goCollection, output table ttReponseFournisseur, output table ttDetailsIntervention).
        else run getReponseFournisseurRowid in vhProc (vrRowid, output table ttReponseFournisseur, output table ttDetailsIntervention).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeReponseFournisseur (input-output dataset dsbeReponseFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/reponseFournisseur.p").
        run createReponseFournisseur in vhProc(table ttReponseFournisseur, table ttDetailsIntervention).
        dataset dsbeReponseFournisseur:empty-dataset().
        run getErrors                in vhProc(output table ttError).
        {outils/include/tryCatch.i}

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeReponseFournisseur(input-output dataset dsbeReponseFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc    as handle    no-undo.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/reponseFournisseur.p").
        run updateReponseFournisseur in vhProc(table ttReponseFournisseur, table ttDetailsIntervention).
        dataset dsbeReponseFournisseur:empty-dataset().
        run getErrors                in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeReponseFournisseur (pcfiltre as longchar, output dataset dsbeReponseFournisseur):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroTraitement', int64(vhBuffer::iNumeroTraitement)) no-error.
                goCollection:set('iNumeroDossier',    int64(vhBuffer::iNumeroDossier)) no-error.
                goCollection:set('iNumeroMandat',     int64(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('cTypeMandat',       vhBuffer::cTypeMandat) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/reponseFournisseur.p").
        run deleteReponseFournisseur in vhProc(goCollection).
        run getErrors                in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void cloturebeReponseFournisseur (pcFiltre as longchar):
        /*------------------------------------------------------------------------------
        Purpose: cloture une reponse devis
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc               as handle    no-undo.
        define variable vhttFilter           as handle    no-undo.
        define variable vhBuffer             as handle    no-undo.
        define variable viNumeroIntervention as integer   no-undo.
        define variable viNumeroTraitement   as integer   no-undo.
        define variable vcCodeCloture        as character no-undo.
        define variable vcLibelleCloture     as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroIntervention = integer(vhBuffer::iNumeroIntervention) no-error.
                viNumeroTraitement   = integer(vhBuffer::iNumeroTraitement)   no-error.
                vcCodeCloture        = vhBuffer::cCodeCloture                 no-error.
                vcLibelleCloture     = vhBuffer::cLibelleCloture              no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
        run cloture   in vhProc(viNumeroIntervention, viNumeroTraitement, {&TYPEINTERVENTION-reponseDevis}, vcCodeCloture, vcLibelleCloture).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void voteAG(input-output dataset dsbeReponseFournisseur):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/reponseFournisseur.p").
        run voteAG    in vhProc (table ttReponseFournisseur, table ttError).
        dataset dsbeReponseFournisseur:empty-dataset().
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beReponseFournisseur ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
