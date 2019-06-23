/*------------------------------------------------------------------------
File        : beVersement.cls
Syntax      :
Author(s)   : LGI/devweb1  -  2017/01/13
Notes       :
derniere revue: 2018/05/24 - phm: KO
        traiter les todo
------------------------------------------------------------------------*/

@program FILE(name="beVersement.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writedatasetBeforeImage="false").
@progress.service.resource FILE(name="beVersement", URI="/beVersement", schemaName="dsbeVersement", schemaFile="").

using outils.outilhandle.
using outils.collection.
using Progress.Json.ObjectModel.JsonObject.

block-level on error undo, throw.

class ged.beVersement:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {application/include/combo.i}
    {ged/include/versement.i}
    {ged/include/visibiliteExtranet.i}
    {ged/include/documentGidemat.i}
    {ged/include/recherche.i}
    {ged/include/ged.i}
    {role/include/typeRole.i}
    {mandat/include/coloc.i &nomTable=ttColoc &serialIdentifiant=iIdentifiantGed}

    define buffer gbttDocumentGed2        for ttDocumentGed.
    define buffer gbttAttributChamps2     for ttAttributChamps.
    define buffer gbttFichierVerse2       for ttFichierVerse.
    define buffer gbttError2              for ttError.
    define buffer gbttRepertoireScan2     for ttRepertoireScan.
    define buffer gbttFichierScan2        for ttFichierScan.
    define buffer gbttVisibiliteExtranet2 for ttVisibiliteExtranet.
    define buffer gbttColoc               for ttColoc.
    define buffer gbttError3              for ttError.

    define dataset dsbeVersement for ttGedTypeDocument, ttDocumentGidemat, ttcombo, ttAttributChamps, ttDocumentGed,  ttVisibiliteExtranet, ttParamVersement, ttFichierVerse, ttRepertoireScan, ttFichierScan, ttRepertoireScanUtilisateur, ttError
                data-relation scan for ttRepertoireScan, ttFichierScan nested foreign-key-hidden
                relation-fields(ttRepertoireScan.cNomDossier, ttFichierScan.cNomDossier)
                data-relation scanUtilisateur for ttRepertoireScan, ttRepertoireScanUtilisateur nested foreign-key-hidden
                relation-fields(ttRepertoireScan.cNomDossier, ttRepertoireScanUtilisateur.cNomDossier)
                data-relation visibilite for ttDocumentGed, ttVisibiliteExtranet nested foreign-key-hidden
                relation-fields(ttDocumentGed.iIdentifiantGed, ttVisibiliteExtranet.id-fich).
                .
    define dataset dsbeCreate    for gbttDocumentGed2, gbttFichierVerse2, gbttAttributChamps2, gbttRepertoireScan2, gbttFichierScan2, gbttColoc, gbttError2
                data-relation fichierVerse for gbttDocumentGed2, gbttFichierVerse2 nested foreign-key-hidden
                relation-fields (gbttDocumentGed2.iIdentifiantGed, gbttFichierVerse2.id-fich)
                data-relation attributChamps for gbttDocumentGed2, gbttAttributChamps2 nested foreign-key-hidden
                relation-fields (gbttDocumentGed2.iIdentifiantGed, gbttAttributChamps2.id-fich)
                data-relation repertoireScan for gbttDocumentGed2, gbttRepertoireScan2 nested foreign-key-hidden
                relation-fields(gbttDocumentGed2.iIdentifiantGed, gbttRepertoireScan2.iIdentifiantGed)
                data-relation fichierScan for gbttRepertoireScan2, gbttFichierScan2 nested
                relation-fields(gbttRepertoireScan2.iIdentifiantGed, gbttFichierScan2.iIdentifiantGed,
                                gbttRepertoireScan2.cNomDossier, gbttFichierScan2.cNomDossier)
                data-relation coloc for gbttDocumentGed2, gbttColoc nested foreign-key-hidden
                relation-fields(gbttDocumentGed2.iIdentifiantGed, gbttColoc.identifiant)
                .
    define dataset dsbeVisibilite for gbttVisibiliteExtranet2, gbttError3.

    constructor public beVersement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    method public void ReadbeDocumentParId(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement    as handle    no-undo.
        define variable vhttFilter         as handle    no-undo.
        define variable vhBuffer           as handle    no-undo.
        define variable vcTypeIdentifiant  as character no-undo initial ?.
        define variable vhttField          as handle    no-undo.
        define variable viI                as integer   no-undo.
        define variable vcListeIdentifiant as character no-undo.

        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeIdentifiant = vhBuffer::cTypeIdentifiant no-error.
                vhttField = vhBuffer:buffer-field('iIdentifiant') no-error.
                if valid-handle(vhttField)
                then if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcListeIdentifiant = substitute('&1,&2', vcListeIdentifiant, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcListeIdentifiant = vhttField:buffer-value().
                vcListeIdentifiant = trim(vcListeIdentifiant, ",").
            end.
        end.
        delete object vhttFilter no-error.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        run getDocumentParId in vhProcVersement(vcTypeIdentifiant, vcListeIdentifiant, output table ttDocumentGidemat).
        run getErrors        in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    method public void ReadbeDocumentScan(input-output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement as handle    no-undo.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        run getDocumentScan in vhProcVersement(table ttRepertoireScan, input-output table ttFichierScan).
        run getErrors       in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.


    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    method public void ReadbeScan(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement   as handle    no-undo.
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.
        define variable vcChemin          as character no-undo.
        define variable vcVue             as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcChemin = vhBuffer::cChemin no-error.
                vcVue    = vhBuffer::cVue    no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        run getScan   in vhProcVersement(vcChemin, vcVue, output table ttRepertoireScan, output table ttFichierScan, output table ttRepertoireScanUtilisateur).
        run getErrors in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    method public void ReadbeDocumentGED(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcRecherche as handle     no-undo.
        define variable vhttFilter      as handle     no-undo.
        define variable vhBuffer        as handle     no-undo.
        define variable vrRowid         as rowid      no-undo.
        define variable voJson          as JsonObject no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                voJson = new JsonObject( ).
                voJson:Read(input vhbuffer).
                vrRowid = voJson:GetRowid("rRowid") no-error. // Impossible d'extraire le rowid sans passer par GetRowid()
                delete object voJson no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcRecherche = outilhandle:connectMaGIModele("ged/rechercheGed.p").
        run getDocumentGED in vhProcRecherche(vrRowid, output table ttDocumentGed, output table ttVisibiliteExtranet).
        run getErrors      in vhProcRecherche(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    method public void ReadbeComboTypeDocument(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement     as handle    no-undo.
        define variable vhttFilter          as handle    no-undo.
        define variable vhBuffer            as handle    no-undo.
        define variable viReference         as integer   no-undo.
        define variable viNumeroMandat      as integer   no-undo.
        define variable vcCodeThemeGed      as character no-undo.
        define variable vcListeCodeOrigine  as character no-undo.
        define variable vcListeTypeDocument as character no-undo.
        define variable vcFiltre            as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                vireference         = vhBuffer::iReference         no-error.
                viNumeroMandat      = vhBuffer::iNumeroMandat      no-error.
                vcCodeThemeGed      = vhBuffer::cCodeThemeGed      no-error.
                vcListeCodeOrigine  = vhBuffer::cListeCodeOrigine  no-error.
                vcListeTypeDocument = vhBuffer::cListeTypeDocument no-error.
                vcFiltre            = vhBuffer::cFiltre            no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        run getComboTypeDocument in vhProcVersement(viReference, viNumeroMandat, vcCodeThemeGed, vcListeCodeOrigine, vcListeTypeDocument, vcFiltre, output table ttGedTypeDocument).
        run getErrors in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    method public void ReadbeVisibiliteRoleExtranet(pcFiltre as longchar, output dataset dsbeVisibilite):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement  as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable vcTypeRole       as character no-undo.
        define variable viNumeroImmeuble as integer   no-undo.
        define variable viNumeroMandat   as integer   no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                vcTypeRole       = string(integer(vhBuffer::cTypeRole), "99999") no-error.
                viNumeroImmeuble = vhBuffer::iNumeroImmeuble                     no-error.
                viNumeroMandat   = vhBuffer::iNumeroMandat                       no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        run getVisibiliteRoleExtranet in vhProcVersement(vcTypeRole, viNumeroImmeuble, viNumeroMandat, output table ttVisibiliteExtranet).
        run getErrors in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    method public void ReadbeRecherche(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcRecherche        as handle  no-undo.
        define variable vhProcRole             as handle  no-undo.
        define variable vhttFilter             as handle  no-undo.
        define variable vhBuffer               as handle  no-undo.
        define variable viCodeReferenceSociete as integer no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viCodeReferenceSociete = vhBuffer::iCodeReferenceSociete no-error.
            end.
        end.
        delete object vhttFilter no-error.

        assign
            vhProcRole      = outilhandle:connectMaGIModele("role/role.p")
            vhProcRecherche = outilhandle:connectMaGIModele("ged/rechercheGed.p")
        .
        run getTypeRoleParReference in vhProcRole (viCodeReferenceSociete, output table ttTypeRole).
        run getRecherche in vhProcRecherche(pcFiltre, table ttTypeRole, output table ttDocumentGed, output table ttVisibiliteExtranet).
        run getErrors    in vhProcRecherche(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDatasetBeforeImage="false").
    method public void readbeAttributEcranVersement(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement   as handle    no-undo.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        run getAttributEcranVersement in vhProcVersement(output table ttParamVersement, output table ttAttributChamps).
        run getErrors in vhProcVersement (output table ttError).
        {outils/include/tryCatch.i}
   end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeDocumentGED(pcfiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement      as handle  no-undo.
        define variable viIdentifiantGed     as int64 no-undo.
        define variable vhttFilter           as handle  no-undo.
        define variable vhBuffer             as handle  no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viIdentifiantGed = vhBuffer::iIdentifiantGed no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcVersement = outilHandle:connectMaGIModele("ged/versement.p").
        run deleteDocumentGED in vhProcVersement(viIdentifiantGed).
        run getErrors      in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeScan(input-output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Suppression de plusieurs répertoires et des utilisateurs associés
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement as handle  no-undo.

        vhProcVersement = outilHandle:connectMaGIModele("ged/versement.p").
        run deleteScan in vhProcVersement(input table ttRepertoireScan).
        dataset dsbeVersement:empty-dataset().
        run getErrors      in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void UpdatebeDocumentGED(pcFiltre as longchar, input-output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Update one record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement   as handle    no-undo.
        define variable vhProcRole        as handle    no-undo.
        define variable vhProcErreur      as handle    no-undo.
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.
        define variable vcVue             as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcVue = vhBuffer::cVue no-error.
            end.
        end.
        delete object vhttFilter no-error.

        if vcVue = "" or vcVue = "GIEXTRANET" then do:
            assign
                vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p")
                vhProcRole      = outilhandle:connectMaGIModele("role/role.p")
            .
            delete procedure outilHandle:hTransactionManager no-error. /* Forcé pour réduire la portée de la transaction au .p, TransactionCommit ne réduit pas la portée */
            for first ttDocumentGED
                where ttDocumentGED.CRUD = "U":
                run getTypeRoleParReference in vhProcRole (ttDocumentGED.iCodeReferenceSociete, output table ttTypeRole).
                run updateDocumentGED in vhProcVersement(input-output table ttDocumentGED, table ttAttributChamps, table ttTypeRole, vcVue).
                dataset dsbeVersement:empty-dataset().
                run getErrors   in vhProcVersement(output table ttError).
            end.
        end.
        else do:
            dataset dsbeVersement:empty-dataset().
            vhProcErreur = outilHandle:connectMaGIModele("outils/erreur.p").
            run createError in vhProcErreur({&error}, 211691, vcVue).          // vue demandée inexistante.
            run getErrors   in vhProcErreur(output table ttError).
        end.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void UpdatebeSendDocumentFileWatcher(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Update one record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable vcNomFichier    as character no-undo initial ?.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcNomFichier = vhBuffer::cNomFichier no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        delete procedure outilHandle:hTransactionManager no-error. /* Réduire la portée de la transaction au .p */
        run sendDocumentFileWatcher in vhProcVersement(vcNomFichier).
        dataset dsbeVersement:empty-dataset().
        run getErrors   in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void UpdatebeSendDocumentGED(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Update one record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement  as handle no-undo.
        define variable vhttFilter       as handle no-undo.
        define variable vhBuffer         as handle no-undo.
        define variable viIdentifiantGed as int64  no-undo initial ?.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viIdentifiantGed = vhBuffer::iIdentifiantGed no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        delete procedure outilHandle:hTransactionManager. /* Forcé pour réduire la portée de la transaction au .p, TransactionCommit ne réduit pas la portée */
        run sendDocumentGED in vhProcVersement(viIdentifiantGed).
        dataset dsbeVersement:empty-dataset().
        run getErrors   in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.


    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void CreatebeDocumentGED(input-output dataset dsbeCreate):
        /*------------------------------------------------------------------------------
        Purpose: Create one record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement as handle no-undo.
        define variable vhProcRole      as handle no-undo.

        for first ttDocumentGED
            where ttDocumentGED.CRUD = "C":
            assign
                vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p")
                vhProcRole      = outilhandle:connectMaGIModele("role/role.p")
            .
            run getTypeRoleParReference in vhProcRole (ttDocumentGED.iCodeReferenceSociete, output table ttTypeRole).
            delete procedure outilHandle:hTransactionManager no-error. /* Réduire la portée de la transaction au .p */
            run createDocumentGed in vhProcVersement(table ttDocumentGED, table ttTypeRole, table ttFichierVerse, table ttAttributChamps, table ttRepertoireScan, table ttFichierScan, table ttColoc).
            dataset dsbeCreate:empty-dataset().
            run getErrors   in vhProcVersement(output table ttError).
        end.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void CreatebeScan(input-output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Create one record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement as handle  no-undo.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        run createScan in vhProcVersement(table ttRepertoireScan, table ttRepertoireScanUtilisateur).
        dataset dsbeVersement:empty-dataset().
        run getErrors   in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void UpdatebeScan(input-output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Modification du repertoire scan et de la liste des utilisateurs associés
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement as handle    no-undo.

        vhProcVersement = outilhandle:connectMaGIModele("ged/versement.p").
        run updateScan in vhProcVersement(table ttRepertoireScan, table ttRepertoireScanUtilisateur).
        dataset dsbeVersement:empty-dataset().
        run getErrors   in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeTypeDocument(pcFiltre as longchar, output dataset dsbeVersement):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcVersement           as handle    no-undo.
        define variable vhttFilter                as handle    no-undo.
        define variable vhBuffer                  as handle    no-undo.
        define variable vhttField                 as handle    no-undo.
        define variable viI                       as integer   no-undo.
        define variable vcListeNumeroTypeDocument as character no-undo.

        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:                     /* EXTENT TYPE DOCUMENT */
                vhttField = vhBuffer:buffer-field('iNumeroTypeDocument') no-error.
                if valid-handle(vhttField)
                    then if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcListeNumeroTypeDocument = substitute('&1,&2', vcListeNumeroTypeDocument, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcListeNumeroTypeDocument = vhttField:buffer-value().
                vcListeNumeroTypeDocument = trim(vcListeNumeroTypeDocument, ",").
            end.
        end.
        delete object vhttFilter no-error.

        vhProcVersement = outilHandle:connectMaGIModele("ged/versement.p").
        run getListeTypeDocumentGed in vhProcVersement (vcListeNumeroTypeDocument, output table ttGedTypeDocument).
        run getErrors               in vhProcVersement(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beVersement( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilhandle:deletehandle().
    end destructor.

end class.
