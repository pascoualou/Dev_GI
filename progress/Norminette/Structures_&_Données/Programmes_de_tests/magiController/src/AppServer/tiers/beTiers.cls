/*------------------------------------------------------------------------
File        : beTiers
Purpose     :
Author(s)   : KANTENA - 2013/08/04
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beTiers.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beTiers", URI="/beTiers", schemaName="dsbeTiers", schemaFile="").

using outils.outilHandle.
using outils.collection.
block-level on error undo, throw.

class tiers.beTiers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/error.i}
    {tiers/include/tiers.i}
    {preprocesseur/type2role.i}
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    define buffer bttError for ttError.    
    define dataset dsbeTiers for ttTiers, ttError.
    define dataset dsbeListeTiers for ttListeTiers, bttError.

    constructor public beTiers():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    //method public void rechercheTiers(pcfiltre as longchar, output pcTiers as longchar): gestion write-json ne marche pas car beRecherche.cls attend un dataset
    method public void rechercheTiers(pcfiltre as longchar, output dataset dsbeListeTiers):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc                as handle    no-undo.
        define variable vhttFilter            as handle    no-undo.
        define variable vhBuffer              as handle    no-undo.
        define variable vhttField             as handle    no-undo.
        define variable viI                   as integer   no-undo.
        define variable vcListeRoleFicheTiers as character no-undo.

        empty temp-table ttListeTiers.
        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                /* Entrée: dépend d'où je viens */
                goCollection:set('cTypRoleEntree', vhBuffer::cTypRoleEntree) no-error.
                goCollection:set('cLstTprolEntree', vhBuffer::cLstTprolEntree) no-error.
                goCollection:set('cLstTpCttEntree', vhBuffer::cLstTpCttEntree) no-error.
                goCollection:set('iNumeroImmeuble', integer(vhBuffer::iNumeroImmeuble)) no-error.
                /* Tiers */
                goCollection:set('cNomTiers', vhBuffer::cNomTiers) no-error.
                goCollection:set('cPrenomTiers', vhBuffer::cPrenomTiers) no-error.
                goCollection:set('iNumeroTiers', int64(vhBuffer::iNumeroTiers)) no-error.
                goCollection:set('iNumeroTiers1', int64(vhBuffer::iNumeroTiers1)) no-error.
                goCollection:set('iNumeroTiers2', int64(vhBuffer::iNumeroTiers2)) no-error.
                goCollection:set('cAdresseTiers', vhBuffer::cAdresseTiers) no-error.
                goCollection:set('cTypeRechercheTiers', vhBuffer::cTypeRechercheTiers) no-error.
                goCollection:set('lTiersSansRole', logical(vhBuffer::lTiersSansRole)) no-error.
                goCollection:set('lRolesAssocies', logical(vhBuffer::lRolesAssocies)) no-error.

                /* EXTENT LISTE ROLES */
                vhttField = vhBuffer:buffer-field('cListeRoleFicheTiers') no-error.
                if valid-handle(vhttField) then do:
                    if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                       vcListeRoleFicheTiers = substitute('&1,&2', vcListeRoleFicheTiers, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcListeRoleFicheTiers = vhttField:buffer-value().
                    vcListeRoleFicheTiers = trim(vcListeRoleFicheTiers, ",") no-error.
                end.
                goCollection:set('cListeRoleFicheTiers', vcListeRoleFicheTiers) no-error.

                /* Immeuble */
                goCollection:set('cNomImmeuble', vhBuffer::cNomImmeuble) no-error.
                goCollection:set('iNumeroImmeuble1', integer(vhBuffer::iNumeroImmeuble1)) no-error.
                goCollection:set('iNumeroImmeuble2', integer(vhBuffer::iNumeroImmeuble2)) no-error.
                goCollection:set('cAdresseImmeuble', vhBuffer::cAdresseImmeuble) no-error.
                /* Contrat */
                goCollection:set('iNumeroContrat', int64(vhBuffer::iNumeroContrat)) no-error.
                goCollection:set('iNumeroContrat1', int64(vhBuffer::iNumeroContrat1)) no-error.
                goCollection:set('iNumeroContrat2', int64(vhBuffer::iNumeroContrat2)) no-error.
                goCollection:set('cTypeContrat', vhBuffer::cTypeContrat) no-error.
                goCollection:set('lContratsAssocies', logical(vhBuffer::lContratsAssocies)) no-error.
                /* Service */
                goCollection:set('cCodeService', vhBuffer::cCodeService) no-error.
                /* Autres critères */
                goCollection:set('cNomJeuneFilleTiers', vhBuffer::cNomJeuneFilleTiers) no-error.
                goCollection:set('iNumeroSiret', integer(vhBuffer::iNumeroSiret)) no-error.
                goCollection:set('cNumeroSecu', vhBuffer::cNumeroSecu) no-error.
                goCollection:set('cDomaineFournisseur', vhBuffer::cDomaineFournisseur) no-error.
                goCollection:set('cCategorieFournisseur', vhBuffer::cCategorieFournisseur) no-error.
                goCollection:set('cStatutFournisseur', vhBuffer::cStatutFournisseur) no-error.
                goCollection:set('cFournisseurReferencmt', vhBuffer::cFournisseurReferencmt) no-error.
                goCollection:set('cCodeSociete', vhBuffer::cCodeSociete) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("tiers/rechercheTiers.p").
        run rechercheTiersTroncCommun in vhProc(goCollection, output table ttListeTiers).
        run getErrors      in vhProc(output table ttError).
        /* permet de générer le Json sans les champs ayant leur valeur par défaut - réduit la taille du flux! */
        /* dataset dsbeListeTiers:write-json("LONGCHAR", pcTiers, false, ?, true, false, false). */
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeTiers(pcFiltre as longchar, output dataset dsbeTiers):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcTiers     as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable vcTypeTiers     as character no-undo.
        define variable viNumeroContrat as integer   no-undo.
        define variable vcTypeContrat   as character no-undo.

        dataset dsbeTiers:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeTiers     = vhBuffer::cTypeTiers no-error.
                viNumeroContrat = vhBuffer::iNumeroContrat no-error.
                vcTypeContrat   = vhBuffer::cTypeContrat no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcTiers = outilHandle:connectMaGIModele("tiers/tiers.p").
        case vcTypeTiers:
            /* Locataires ou Coproprietaires*/
            when "L"              then run getListeTiersContrat   in vhProcTiers(vcTypeContrat, viNumeroContrat, {&TYPEROLE-locataire},     output table ttTiers).
            when "C"              then run getListeTiersContrat   in vhProcTiers(vcTypeContrat, viNumeroContrat, {&TYPEROLE-coproprietaire}, output table ttTiers).
            when "Gestionnaire"   then run getTiersGestionnaire   in vhProcTiers(viNumeroContrat, vcTypeContrat, output table ttTiers).
            when "ServiceGestion" then run getTiersServiceGestion in vhProcTiers(viNumeroContrat, vcTypeContrat, output table ttTiers).
        end case.
        run getErrors in vhProcTiers(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeTiers(input-output dataset dsbeTiers):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeTiers(input-output dataset dsbeTiers):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeTiers(input-output dataset dsbeTiers):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beTiers( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
