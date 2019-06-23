/*------------------------------------------------------------------------
File        : beImmeuble.cls
Purpose     :
Author(s)   : kantena - 2017/06/30
Notes       :
derniere revue: 2018/05/18 - OK
------------------------------------------------------------------------*/
  
@program FILE(name="beRole.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beRole", URI="/beRole", schemaName="dsbeRole", schemaFile="").

using outils.outilHandle.
using outils.collection.
using oerealm.beMagiToken.

block-level on error undo, throw.

class role.beRole:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {preprocesseur/type2role.i}
    {role/include/typeRole.i}
    {role/include/role.i}
    {role/include/roleContrat.i}
    {role/include/roleVersement.i &serialName=ttRoleVersement}
    {mandat/include/coloc.i &nomTable=ttColoc &serialIdentifiant=iIdentifiantGed}
    define dataset dsbeRole for ttRole, ttRoleVersement, ttColoc, ttError.

    constructor public beRole():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/        
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeRole(pcFiltre as longchar, output pcRole as longchar):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable vcVue            as character no-undo.
        define variable vcTypeRole       as character no-undo.
        define variable vcParamTypeRole  as character no-undo.
        define variable viNumeroImmeuble as integer   no-undo.
        define variable vhProcErreur     as handle    no-undo.
        define variable vhProcRole       as handle    no-undo.
        define variable vhProcImmeuble   as handle    no-undo.
        define variable vhttRole         as handle    no-undo.
        define variable vhttError        as handle    no-undo.
        define variable vhDynamicDataSet as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeRole       = vhBuffer::cTypeRole       no-error.
                viNumeroImmeuble = vhBuffer::iNumeroImmeuble no-error.
                vcVue            = vhBuffer::cVue            no-error.
            end.
        end.
        else vcTypeRole = pcFiltre.
        delete object vhttFilter no-error.

        create dataset vhDynamicDataSet.
        assign 
            vhDynamicDataSet:name = "dsbeRole"
            vhProcRole            = outilHandle:connectMaGIModele("role/role.p")
            vhProcImmeuble        = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcErreur          = outilHandle:connectMaGIModele("outils/erreur.p")
        .
        case vcVue:
            when 'DOMOTIQUE' then do:
                if viNumeroImmeuble <> ? and viNumeroImmeuble <> 0 then do:
                    run getlisteRoleImmeuble in vhProcImmeuble(viNumeroImmeuble, output table-handle vhttRole).
                    run getErrors            in vhProcImmeuble(output table-handle vhttError).
                    vhDynamicDataSet:set-buffers(vhttRole, vhttError).
                end.
            end.
            otherwise do:
                case vcTypeRole:
                    when 'ASSURANCE'          then vcParamTypeRole = {&TYPEROLE-compagnie}.
                    when 'VENDEUR'            then vcParamTypeRole = {&TYPEROLE-vendeur}.
                    when 'ACHETEUR'           then vcParamTypeRole = {&TYPEROLE-acheteur}.
                    when 'COPROPRIETAIRE'     then vcParamTypeRole = {&TYPEROLE-coproprietaire}.
                    when 'COURTIER'           then vcParamTypeRole = {&TYPEROLE-courtier}.
                    when 'LOCATAIRE'          then vcParamTypeRole = {&TYPEROLE-locataire}.
                    when 'CANDIDATLOCATAIRE'  then vcParamTypeRole = {&TYPEROLE-candidatLocataire}.
                    when 'COLOCATAIRE'        then vcParamTypeRole = {&TYPEROLE-colocataire}.
                    when 'COINDIVISAIRE'      then vcParamTypeRole = {&TYPEROLE-coIndivisaire}.
                    when 'GARANT'             then vcParamTypeRole = {&TYPEROLE-garant}.
                    when 'MANDANT'            then vcParamTypeRole = {&TYPEROLE-mandant} .
                    when 'SYNDICCOPRO'        then vcParamTypeRole = {&TYPEROLE-syndicat2copro}.
                    when 'SALARIE'            then vcParamTypeRole = {&TYPEROLE-salarie}.
                    when 'SALARIEPEGASE'      then vcParamTypeRole = {&TYPEROLE-salariePegase}.
                    when 'SOCIETEACTIONNAIRE' then vcParamTypeRole = {&TYPEROLE-societeActionnaires}.
                    otherwise run createError in vhProcErreur({&error}, 211691, vcTypeRole).          // vue demandée inexistante.
                end case.
                run getRoleParType in vhProcRole(vcParamTypeRole, output table-handle vhttRole).
                run getErrors      in vhProcRole(output table-handle vhttError).
                vhDynamicDataSet:set-buffers(vhttRole, vhttError).
            end.
        end case.                       
        vhDynamicDataSet:write-json("LONGCHAR", pcRole, false, ?, true, false, false).
        {outils/include/tryCatch.i}
    end method.
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    method public void readbeListeColoc(pcFiltre as longchar, output dataset dsbeRole):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcLoca       as handle    no-undo.    
        define variable vhProcRole       as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.        
        define variable vcTypeContrat    as character no-undo.
        define variable viNumeroContrat  as int64     no-undo.
        define variable vcTypeRole       as character no-undo.
        define variable vcNumeroRole     as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                vcTypeContrat   = vhBuffer::cTypeContrat   no-error.
                viNumeroContrat = vhBuffer::iNumeroContrat no-error.
                vcTypeRole      = vhBuffer::cTypeRole      no-error.
                vcNumeroRole    = vhBuffer::cNumeroRole    no-error.
            end.
        end.
        delete object vhttFilter no-error.

        assign
            vhProcLoca = outilhandle:connectMaGIModele("mandat/uniteLocation.p")
            vhProcRole = outilhandle:connectMaGIModele("role/role.p")
        .
        beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
        run getTypeRoleParReference in vhProcRole(beMagiToken:mToken:cRefGerance, output table ttTypeRole).
        run getListeColoc in vhProcLoca(vcTypeContrat, viNumeroContrat, vcTypeRole, vcNumeroRole, table ttTypeRole, output table ttColoc).
        run getErrors in vhProcLoca(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDatasetBeforeImage="false").
    method public void readbeListeRoleContrat(pcFiltre as longchar, output dataset dsbeRole):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcRole       as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable viReference      as integer   no-undo.
        define variable vcRecherche      as character no-undo.
        define variable viNumeroMandat   as integer   no-undo.
        define variable viNumeroImmeuble as integer   no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                viReference      = vhBuffer::iReference      no-error.
                viNumeroMandat   = vhBuffer::iNumeroMandat   no-error.
                viNumeroImmeuble = vhBuffer::iNumeroImmeuble no-error.
                vcRecherche      = vhBuffer::cRecherche      no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcRole = outilhandle:connectMaGIModele("role/role.p").
        if viReference > 0 
        and (vcRecherche > ""
             or viNumeroMandat > 0 
             or viNumeroImmeuble > 0)
        then do:
            run getTypeRoleParReference in vhProcRole (viReference, output table ttTypeRole).
            run getRoleMandatImmeuble in vhProcRole (viReference, viNumeroMandat, viNumeroImmeuble, table ttTypeRole, output table ttRoleContrat).
            run getListeRoleContrat in vhProcRole(viReference, vcRecherche, table ttTypeRole, table ttRoleContrat, output table ttRoleVersement).
            run getErrors in vhProcRole(output table ttError).
        end.
        {outils/include/tryCatch.i}
    end method.

    destructor public beRole( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
