/*------------------------------------------------------------------------
File        : beIntervention.cls
Purpose     :
Author(s)   : kantena - 2016/02/11
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}

@program FILE(name="beIntervention.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beIntervention", URI="/beIntervention", schemaName="dsbeIntervention", schemaFile="magiController/src/AppServer/travaux/include/intervention.i").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.intervention.beIntervention:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy as logical no-undo initial true private get. public set.
    {travaux/include/intervention.i}
    {application/include/error.i}
    {outils/include/methodConversionDate.i}
    define buffer gbttError for ttError.
    define dataset dsbeIntervention      for ttIntervention, ttHistoriqueIntervention, ttError.
    define dataset dsbeListeIntervention for ttListeIntervention, gbttError.

    constructor public beIntervention():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void rechercheIntervention(pcFiltre as longchar, output dataset dsbeIntervention):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc               as handle    no-undo.
        define variable vhttFilter           as handle    no-undo.
        define variable vhBuffer             as handle    no-undo.
        define variable vcDateFormat         as character no-undo.
        define variable vcTypeIntervention   as character no-undo.
        define variable vcStatutIntervention as character no-undo.
        define variable vhttField            as handle    no-undo.
        define variable viI                  as integer   no-undo.

        empty temp-table ttIntervention.
        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('cCodeService',         vhBuffer::cCodeService) no-error.
                goCollection:set('iNumeroImmeuble',      integer(vhBuffer::iNumeroImmeuble)) no-error.
                goCollection:set('iNumeroImmeuble1',     integer(vhBuffer::iNumeroImmeuble1)) no-error.
                goCollection:set('iNumeroImmeuble2',     integer(vhBuffer::iNumeroImmeuble2)) no-error.
                goCollection:set('iNumeroMandat',        integer(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroMandat1',       integer(vhBuffer::iNumeroMandat1)) no-error.
                goCollection:set('iNumeroMandat2',       integer(vhBuffer::iNumeroMandat2)) no-error.
                goCollection:set('iNumeroIntervention1', integer(vhBuffer::iNumeroIntervention1)) no-error.
                goCollection:set('iNumeroIntervention2', integer(vhBuffer::iNumeroIntervention2)) no-error.
                vcDateFormat = vhBuffer::cDateFormat no-error.
                goCollection:set('daDateIntervention1',  conversionDate(vcDateFormat, vhBuffer::daDateIntervention1)) no-error.
                goCollection:set('daDateIntervention2',  conversionDate(vcDateFormat, vhBuffer::daDateIntervention2)) no-error.
                /* EXTENT TYPE INTERVENTION */
                vhttField = vhBuffer:buffer-field('cTypeIntervention') no-error.
                if valid-handle(vhttField)
                then if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcTypeIntervention = substitute('&1,&2', vcTypeIntervention, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcTypeIntervention = vhttField:buffer-value().
                vcTypeIntervention = trim(vcTypeIntervention, ",").
                goCollection:set('cTypeIntervention', vcTypeIntervention) no-error.
                /* EXTENT STATUT INTERVENTION */
                assign
                    vhttField = ?     // sinon, en cas d'erreur, on garde la dernière valeur de vhttField.
                    vhttField = vhBuffer:buffer-field('cStatutIntervention')
                no-error.
                if valid-handle(vhttField)
                then if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcStatutIntervention = substitute('&1,&2', vcStatutIntervention, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcStatutIntervention = vhttField:buffer-value().
                vcStatutIntervention = trim(vcStatutIntervention, ",").
                goCollection:set('cStatutIntervention', vcStatutIntervention) no-error.
                goCollection:set('iNumeroResponsable',  integer(vhBuffer::iNumeroResponsable)) no-error.
                goCollection:set('iNumeroDossier1',     integer(vhBuffer::iNumeroDossier1)) no-error.
                goCollection:set('iNumeroDossier2',     integer(vhBuffer::iNumeroDossier2)) no-error.
                goCollection:set('cCodeFournisseur',    vhBuffer::cCodeFournisseur) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
        run rechercheIntervention in vhProc(goCollection, output table ttIntervention).
        run getErrors             in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeIntervention(pcFiltre as longchar, output dataset dsbeListeIntervention):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle   no-undo.
        define variable vhttFilter as handle   no-undo.
        define variable vhBuffer   as handle   no-undo.

        empty temp-table ttListeIntervention.
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('cTypeMandat',             vhBuffer::cTypeMandat) no-error.
                goCollection:set('iNumeroMandat',           integer(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroDossierTravaux',   integer(vhBuffer::iNumeroDossierTravaux)) no-error.
                goCollection:set('cCodeStatutIntervention', vhBuffer::cCodeStatutIntervention) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
        run getListeInterventions in vhProc(goCollection, output table ttListeIntervention).
        run getErrors             in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeIntervention(input-output dataset dsbeIntervention):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeIntervention(input-output dataset dsbeIntervention):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeIntervention (pcFiltre as longchar, output dataset dsbeIntervention):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc           as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable vcCodeTraitement as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcCodeTraitement = vhBuffer::cCodeTraitement.
                goCollection:set('cCodeTraitement',     vhBuffer::valeur) no-error.
                goCollection:set('iNumeroTraitement',   int64(vhBuffer::iNumeroTraitement)) no-error.
                goCollection:set('iNumeroIntervention', integer(vhBuffer::iNumeroIntervention)) no-error.
                goCollection:set('iNumeroMandat',       int64(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('cTypeMandat',         vhBuffer::cTypeMandat) no-error.
                goCollection:set('iNumeroDossier',      int64(vhBuffer::iNumeroDossier)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        case vcCodeTraitement:
            when {&TYPEINTERVENTION-signalement}   then do:
                vhProc = outilHandle:connectMaGIModele("travaux/intervention/signalement.p").
                run deleteSignalement in vhProc(goCollection).
            end.
            when {&TYPEINTERVENTION-demande2devis} then do:
                vhProc = outilHandle:connectMaGIModele("travaux/intervention/demandeDeDevis.p").
                run deleteDemandeDeDevis in vhProc(goCollection).
            end.
            when {&TYPEINTERVENTION-ordre2service} then do:
                vhProc = outilHandle:connectMaGIModele("travaux/intervention/ordreDeService.p").
                run deleteOrdreDeService in vhProc(goCollection).
            end.
            when {&TYPEINTERVENTION-reponseDevis}  then do:
                vhProc = outilHandle:connectMaGIModele("travaux/intervention/reponseFournisseur.p").
                run deleteReponseFournisseur in vhProc(goCollection).
            end.
        end case.
        dataset dsbeIntervention:empty-dataset().
        if valid-handle(vhProc) then run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeHistoriqueIntervention(pcFiltre as longchar, output dataset dsbeIntervention):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc               as handle  no-undo.
        define variable vhttFilter           as handle  no-undo.
        define variable vhBuffer             as handle  no-undo.
        define variable viNumeroIntervention as integer no-undo.

        dataset dsbeIntervention:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroIntervention = integer(vhBuffer::iNumeroIntervention) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
        run getHistoriqueIntervention in vhProc(viNumeroIntervention, output table ttHistoriqueIntervention).
        run getErrors                 in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void cloturebeIntervention(pcFiltre as longchar, output dataset dsbeIntervention):
        /*------------------------------------------------------------------------------
        Purpose: cloture un signalement
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc               as handle    no-undo.
        define variable vhttFilter           as handle    no-undo.
        define variable vhBuffer             as handle    no-undo.

        dataset dsbeIntervention:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroIntervention', integer(vhBuffer::iNumeroIntervention)) no-error.
                goCollection:set('iNumeroTraitement',   int64(vhBuffer::iNumeroTraitement)) no-error.
                goCollection:set('cCodeTraitement',     vhBuffer::cCodeTraitement) no-error.
                goCollection:set('cCodeCloture',        vhBuffer::cCodeCloture) no-error.
                goCollection:set('cCommentaireCloture', vhBuffer::cCommentaireCloture) no-error.
                goCollection:set('cLibelleCloture',     vhBuffer::cLibelleCloture) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
        run cloture   in vhProc(goCollection).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="/xlsIntervention", alias="", mediaType="application/msexcel").
    method public void xlsIntervention(pcFiltre as longchar, output cFile as character, output dataset dsbeIntervention):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: Attention, cette méthode appelle une autre méthode de l'objet. Utilisation de selfDestroy
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        dataset dsbeIntervention:empty-dataset().
        empty temp-table ttIntervention.
        // Permet de désactiver le ménage intensif lors du tryCatch de la méthode rechercheIntervention. Sinon, détruit aussi l'environnement courant!
        selfDestroy = false.      // attention de ne pas supprimer l'objet intempestivement !!!
        this-object:rechercheIntervention(pcFiltre, output dataset dsbeIntervention).
        selfDestroy = true.       // attention, on peut supprimer l'objet maintenant!
        if not can-find(first ttError where ttError.iType = {&erreur})
        then do:
            vhProc = outilHandle:connectMaGIModele("travaux/intervention/intervention.p").
            run EditionListeIntervention in vhProc(input-output dataset dsbeIntervention, output cFile).
            run getErrors                in vhProc(output table ttError).
            if not can-find(first ttError where ttError.iType = {&erreur})
            then dataset dsbeIntervention:empty-dataset().  /* on ne renvoit rien s'il n'y a pas d'erreur */
        end.
        {outils/include/tryCatch.i}
    end method.

    destructor public beIntervention( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
