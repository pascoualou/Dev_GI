/*------------------------------------------------------------------------
File        : beUniteLocation.cls
Purpose     : Unite de location (UL ou noapp)
Author(s)   : SPo  -  2017/03/09
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beUniteLocation.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beUniteLocation", URI="/beUniteLocation", schemaName="dsbeUniteLocation", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class mandat.gerance.beUniteLocation:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
	------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {mandat/include/uniteLocation.i}
    {mandat/include/uniteComposition.i}
    define dataset dsbeUniteLocation for ttUniteLocation, ttCompositionUnite, ttError
        data-relation CompoUL for ttUniteLocation, ttCompositionUnite nested foreign-key-hidden
            relation-fields (ttUniteLocation.iNumeroContrat    , ttCompositionUnite.iNumeroContrat,
                             ttUniteLocation.iNumeroAppartement, ttCompositionUnite.iNumeroAppartement,
                             ttUniteLocation.iNumeroComposition, ttCompositionUnite.iNumeroComposition)
    .

    constructor public beUniteLocation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeUniteLocation(pcFiltre as longchar, output dataset dsbeUniteLocation):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc                as handle    no-undo.
        define variable vcTypeContrat         as character no-undo.
        define variable viNumeroContrat       as integer   no-undo.
        define variable viNumeroUniteLocation as integer   no-undo.
        define variable vhttFilter            as handle    no-undo.
        define variable vhBuffer              as handle    no-undo.

        empty temp-table ttUniteLocation.
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                vcTypeContrat         = vhBuffer::cTypeContrat         no-error.
                viNumeroContrat       = vhBuffer::iNumeroContrat       no-error.
                viNumeroUniteLocation = vhBuffer::iNumeroUniteLocation no-error.
            end.
        end.
        delete object vhttFilter no-error.
        vhProc = outilHandle:connectMaGIModele("mandat/UniteLocation.p").
        run getUniteLocation in vhProc(vcTypeContrat, viNumeroContrat, viNumeroUniteLocation, output table ttUniteLocation).
        run getErrors        in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void readbeListeUniteLocation(pcFiltre as longchar, output dataset dsbeUniteLocation):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc               as handle    no-undo.
        define variable vhttFilter           as handle    no-undo.
        define variable vhBuffer             as handle    no-undo.
        define variable vhProcErreur         as handle    no-undo.
        define variable vcVue                as character no-undo.
        define variable vdaDateVacanteAu     as date      no-undo.
        define variable vlMandatInvestisseur as logical   no-undo.
        
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                vcVue                = vhBuffer::cVue                no-error.
                vdaDateVacanteAu     = vhBuffer::daDateVacanteAu     no-error.
                vlMandatInvestisseur = vhBuffer::lMandatInvestisseur no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("mandat/UniteLocation.p").
        if vcVue = "" or vcVue = "ULVACANTE"
        then run getListeUniteLocation in vhProc(vcVue, vdaDateVacanteAu, vlMandatInvestisseur, output table ttUniteLocation).
        else do:
            vhProcErreur = outilHandle:connectMaGIModele("outils/erreur.p").
            run createError in vhProcErreur({&error}, 211691, vcVue).          // vue demandée inexistante.
        end.
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeUniteLocation(input-output dataset dsbeUniteLocation):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/  
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeUniteLocation(pcFiltre as longchar, input-output dataset dsbeUniteLocation):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc       as handle    no-undo.
        define variable vhttFilter   as handle    no-undo.
        define variable vhBuffer     as handle    no-undo.
        define variable vhProcErreur as handle    no-undo.
        define variable vcVue        as character no-undo.
        
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                vcVue = vhBuffer::cVue no-error.
            end.
        end.
        delete object vhttFilter no-error.
        vhProc = outilHandle:connectMaGIModele("mandat/UniteLocation.p").
        if vcVue = "" or vcVue = "ULVACANTE"
        then run majIndisponibiliteUniteLocation in vhProc(table ttUniteLocation).
        else do:
            vhProcErreur = outilHandle:connectMaGIModele("outils/erreur.p").
            run createError in vhProcErreur({&error}, 211691, vcVue).          // vue demandée inexistante.
        end.
        dataset dsbeUniteLocation:empty-dataset().
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeULMandat(pcFiltre as longchar, input-output dataset dsbeUniteLocation):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                vcVue = vhBuffer::cVue no-error.
            end.
        end.
        delete object vhttFilter no-error.
        vhProc = outilHandle:connectMaGIModele("mandat/UniteLocation.p").
        run setNatureUniteLocation in vhProc(table ttUniteLocation).
        dataset dsbeUniteLocation:empty-dataset().
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeUniteLocation(input-output dataset dsbeUniteLocation):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beUniteLocation( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
