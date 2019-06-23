/*------------------------------------------------------------------------
File        : beCommercialisation.cls
Purpose     :
Author(s)   : LGI/NPO - 2016/12/07
Notes       :
derniere revue: 2018/05/23 - phm: KO
        enlever les messages
------------------------------------------------------------------------*/
{preprocesseur/type2fiche.i}

@program FILE(name="beCommercialisation.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beCommercialisation", URI="/beCommercialisation", schemaName="dsbeCommercialisation", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class commercialisation.beCommercialisation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {commercialisation/include/ficheCommercialisation.i}
    {commercialisation/include/codeDivers.i &nomTable=ttAttributsDivers}
    {commercialisation/include/codeDivers.i &nomTable=ttSiteWebFiche}
    {commercialisation/include/historiqueFiche.i}
    {commercialisation/include/histoEncadrementLoyer.i}
    {commercialisation/include/siteWeb.i}
    {commercialisation/include/libellecommercialisation.i}
    {commercialisation/include/sequence.i}
    {commercialisation/include/sequence.i &nomTable=ttSequenceHisto}
    {commercialisation/include/tiersCommercialisation.i}
    {commercialisation/include/tiersCommercialisation.i &nomTable=ttTiersCommercialisationHisto}
    {commercialisation/include/loyerCommercialisation.i}
    {commercialisation/include/loyerCommercialisation.i &nomTable=ttLoyerCommercialisationHisto}
    {commercialisation/include/depotCommercialisation.i}
    {commercialisation/include/honoraireCommercialisation.i}
    {commercialisation/include/detailFinance.i &nomTable=ttDetailFinanceHonoraire}
    {commercialisation/include/detailFinance.i &nomTable=ttDetailFinanceLoyer}
    {commercialisation/include/detailFinance.i &nomTable=ttDetailFinanceLoyerHisto}
    {commercialisation/include/detailFinance.i &nomTable=ttDetailFinanceDepot}
    {commercialisation/include/histoWorkflow.i}
    {commercialisation/include/plafonnementEncadrementLoyer.i}

    {adresse/include/proximite.i}
    {adresse/include/coordonnee.i &nomTable=ttCoordonneeTiers}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationTiers}
    {adresse/include/adresse.i &nomTable=ttAdresseFiche}
    {adresse/include/adresse.i &nomTable=ttAdresseTiers}

    {mandat/include/mandat.i}
    {mandat/include/uniteLocation.i}

    {application/include/error.i}
    {application/include/combo.i &nomTable=ttComboCommercialisation &serialName=ttCombo}

    define buffer gbttError2 for ttError.
    define buffer gbttError3 for ttError.
    define buffer gbttError4 for ttError.
    define buffer gbttError5 for ttError.
    define buffer gbttError6 for ttError.
    define buffer gbttError7 for ttError.
    define buffer gbttHistoEncadrementLoyer2 for ttHistoEncadrementLoyer.

    define dataset dsbeCommercialisation
        for ttFicheCommercialisation, ttAdresseFiche, ttSiteWebFiche,
            ttAttributsDivers, ttProximite,
            ttSequence,
            ttHistoEncadrementLoyer,
            ttHistoriqueFiche, ttSequenceHisto, ttTiersCommercialisationHisto, ttLoyerCommercialisationHisto, ttDetailFinanceLoyerHisto,
            ttDetailFinanceDepot,ttDepotCommercialisation,
            ttDetailFinanceLoyer,ttLoyerCommercialisation,
            ttDetailFinanceHonoraire,ttHonoraireCommercialisation,
            ttTiersCommercialisation, ttCoordonneeTiers,
            ttMoyenCommunicationTiers, ttAdresseTiers,
            ttMandat,
            ttLibelle,
            ttHistoWorkflow,
            ttError
    /* HISTORIQUE FICHE ----------------------------------------------------------------------------*/
            data-relation FicheHistorique           for ttHistoriqueFiche, ttSequenceHisto               nested foreign-key-hidden
                relation-fields (ttHistoriqueFiche.iNumerohisto, ttSequenceHisto.iNumeroHisto)
            data-relation FicheHistoTiers           for ttHistoriqueFiche, ttTiersCommercialisationHisto nested foreign-key-hidden
                relation-fields (ttHistoriqueFiche.iNumeroHisto, ttTiersCommercialisationHisto.iNumeroHistorique)
            data-relation FicheHistoLoyer           for ttHistoriqueFiche, ttLoyerCommercialisationHisto nested foreign-key-hidden
                relation-fields (ttHistoriqueFiche.iNumerohisto, ttLoyerCommercialisationHisto.iNumerohisto)
            data-relation FicheHistoFinanceLoyer    for ttLoyerCommercialisationHisto, ttDetailFinanceLoyerHisto nested foreign-key-hidden
                relation-fields (ttLoyerCommercialisationHisto.iNumeroElementFinance, ttDetailFinanceLoyerHisto.iNumeroElementFinance)
    /* MOYEN COMMUNICATION -------------------------------------------------------------------------*/
            data-relation FicheTiersMoyenComm       for ttTiersCommercialisation, ttMoyenCommunicationTiers    nested foreign-key-hidden
                relation-fields (ttTiersCommercialisation.cJointure, ttMoyenCommunicationTiers.cJointure)
    /* ADRESSE TIERS -------------------------------------------------------------------------*/
            data-relation FicheTiersAdresse         for ttTiersCommercialisation, ttAdresseTiers         nested foreign-key-hidden
                relation-fields (ttTiersCommercialisation.cJointure, ttAdresseTiers.cJointure)
    /* Depot de garantie */
            data-relation FicheDetailDepot          for ttDepotCommercialisation, ttDetailFinanceDepot         nested foreign-key-hidden
                relation-fields (ttDepotCommercialisation.iNumeroElementFinance, ttDetailFinanceDepot.iNumeroElementFinance)
    /* 1ère quittance */
            data-relation FicheDetailLoyer          for ttLoyerCommercialisation, ttDetailFinanceLoyer         nested foreign-key-hidden
                relation-fields (ttLoyerCommercialisation.iNumeroElementFinance, ttDetailFinanceLoyer.iNumeroElementFinance)
   /* Honoraires  */
            data-relation FicheDetailHonoraire      for ttHonoraireCommercialisation, ttDetailFinanceHonoraire nested foreign-key-hidden
                relation-fields (ttHonoraireCommercialisation.iNumeroElementFinance, ttDetailFinanceHonoraire.iNumeroElementFinance)
    .
    define dataset dsbeCombo for ttComboCommercialisation, gbttError2
    .
    define dataset dsbeUniteLocation for ttUniteLocation, gbttError3
    .
    define dataset dsbeBareme for ttBaremeHonoraireComm, ttCalculBareme, gbttError4
            data-relation NoBareme for ttBaremeHonoraireComm, ttCalculBareme nested foreign-key-hidden
                relation-fields (ttBaremeHonoraireComm.iNumeroBareme, ttCalculBareme.iNumeroBareme)
    .
    define dataset dsbeSiteWeb for ttSiteWeb, ttFichierSiteWeb, gbttError5
    .
    define dataset dsbeEncadrementLoyer for ttDemandeEncadrementLoyer,
                                            gbttHistoEncadrementLoyer2,
                                            gbttError6
    .
    define dataset dsbePlafonnementEncadrementLoyer for ttPlafonnementEncadrementLoyer,
                                                        gbttError7
    .

    constructor public beCommercialisation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeCommercialisation(pcFiltre as longchar, output dataset dsbeCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc           as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhttField        as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable viNumeroFiche    as integer   no-undo.
        define variable viTypeLibelle    as integer   no-undo.
        define variable vcVue            as character no-undo.
        define variable vcListeLot       as character no-undo.
        define variable viI              as integer   no-undo.

        dataset dsbeCommercialisation:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                viNumeroFiche = vhBuffer::iNumeroFiche no-error.
                viTypeLibelle = vhBuffer::iTypeLibelle no-error.
                vcVue         = vhBuffer::cVue         no-error.
                vhttField     = vhBuffer:buffer-field("cListeLot") no-error.
                if valid-handle(vhttField)
                then if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcListeLot = substitute('&1,&2', vcListeLot, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcListeLot = vhttField:buffer-value().
                vcListeLot = trim(vcListeLot, ",").
            end.
        end.
        delete object vhttFilter no-error.

message "readbeCommercialisation  "  " vcVue " vcVue " iNumeroFiche " viNumeroFiche.

        case vcVue:
            when 'FICHE' then do:
                vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
                run readInfoFiche in vhProc(viNumeroFiche, output table ttFicheCommercialisation, output table ttHistoWorkflow).
            end.
            when 'LIBELLECOMMERCIALISATION' then do:
                vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
                run getLibelleCommercialisation in vhProc(viTypeLibelle, output table ttLibelle).
            end.
            when 'CARACTERISTIQUE' then do:   // vue 1
                vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
                run readAdresseFiche         in vhProc(viNumeroFiche, output table ttAdresseFiche).
                run getSiteWeb               in vhProc(viNumeroFiche, output table ttSiteWebFiche).
                run getAttributsDivers       in vhProc(viNumeroFiche, output table ttAttributsDivers).
                run getProximite             in vhProc(viNumeroFiche, output table ttProximite).
                run getHistoEncadrementLoyer in vhProc(viNumeroFiche, ?, output table ttHistoEncadrementLoyer).
                run getHistoriqueFiche       in vhProc(viNumeroFiche, output table ttHistoriqueFiche,
                                                                      output table ttSequenceHisto,
                                                                      output table ttTiersCommercialisationHisto,
                                                                      output table ttLoyerCommercialisationHisto,
                                                                      output table ttDetailFinanceLoyerHisto).
                run getSequence              in vhProc(viNumeroFiche, 0, output table ttSequence).
            end.
            when 'PIECEJOINTE' then .
            when 'TIERCONTRAT' then do:  // vues 4 & 5
                vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
                run getMandatCommercialisation     in vhProc(viNumeroFiche, output table ttMandat).
                run getTiersFicheCommercialisation in vhProc(viNumeroFiche, 0, output table ttTiersCommercialisation,
                                                                               output table ttCoordonneeTiers,
                                                                               output table ttMoyenCommunicationTiers,
                                                                               output table ttAdresseTiers).
            end.
            when 'GESTIONFINANCIERE' then do:  // vues 6
                vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
                run readDepotFicheCommercialisation     in vhProc(viNumeroFiche, output table ttDepotCommercialisation, output table ttDetailFinanceDepot).
                run readLoyerFicheCommercialisation     in vhProc(viNumeroFiche, 0, output table ttLoyerCommercialisation, output table ttDetailFinanceLoyer).
                run readHonoraireFicheCommercialisation in vhProc(viNumeroFiche, output table ttHonoraireCommercialisation, output table ttDetailFinanceHonoraire).
            end.
            otherwise do:
                vhProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProc({&error}, 211691, vcVue).          // vue demandée inexistante.
            end.
        end case.
        if valid-handle(vhProc) then run getErrors in vhProc(output table ttError).  // on teste valid-handle, car PIECEJOINTE ne lance pas de service.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void rechercheCommercialisation(pcfiltre as longchar, output dataset dsbeCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcCommercial as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable vhttField        as handle    no-undo.
        define variable viI              as integer   no-undo.
        define variable vcSiteWeb        as character no-undo.
        define variable vcWorkflow       as character no-undo.
        define variable vcCodeUsage      as character no-undo.

        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                goCollection:set('iNumeroImmeuble'   , integer(vhBuffer::iNumeroImmeuble))  no-error.
                goCollection:set('iNumeroMandat'     , integer(vhBuffer::iNumeroMandat))    no-error.
                goCollection:set('iNumeroFiche'      , integer(vhBuffer::iNumeroFiche))     no-error.
                goCollection:set('iNombrePieceDeb'   , integer(vhBuffer::iNombrePieces1))   no-error.
                goCollection:set('iNombrePieceFin'   , integer(vhBuffer::iNombrePieces2))   no-error.
                goCollection:set('iNombrePhotoDeb'   , integer(vhBuffer::iNombrePhotos1))   no-error.
                goCollection:set('iNombrePhotoFin'   , integer(vhBuffer::iNombrePhotos2))   no-error.
                goCollection:set('dLoyerDeb'         , decimal(vhBuffer::dMontantLoyerCC1)) no-error.
                goCollection:set('dLoyerFin'         , decimal(vhBuffer::dMontantLoyerCC2)) no-error.
                goCollection:set('iSurfaceDeb'       , integer(vhBuffer::iSurface1))        no-error.
                goCollection:set('iSurfaceFin'       , integer(vhBuffer::iSurface2))        no-error.
                goCollection:set('cServiceGestion'   , vhBuffer::cServiceGestion)           no-error.
                goCollection:set('cCodePostal'       , vhBuffer::cCodePostal)               no-error.
                goCollection:set('cVille'            , vhBuffer::cVille)                    no-error.
                goCollection:set('iJourVacantDeb'    , integer(vhBuffer::iJourVacant1))     no-error.
                goCollection:set('iJourVacantFin'    , integer(vhBuffer::iJourVacant2))     no-error.
                vhttField = vhBuffer:buffer-field('cSiteWeb') no-error.                              /* EXTENT SiteWeb */
                if valid-handle(vhttField) then do:
                    if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcSiteWeb = substitute('&1,&2', vcSiteWeb, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcSiteWeb = vhttField:buffer-value().
                    goCollection:set('cSiteWeb', trim(vcSiteWeb, ",")) no-error.
                end.
                vhttField = vhBuffer:buffer-field('cWorkflow') no-error.                             /* EXTENT Workflow */
                if valid-handle(vhttField) then do:
                    if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcWorkflow = substitute('&1,&2', vcWorkflow, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcWorkflow = vhttField:buffer-value().
                    goCollection:set('cWorkflow', trim(vcWorkflow, ",")) no-error.
                end.
                vhttField  = vhBuffer:buffer-field('cCodeUsage') no-error.                           /* EXTENT CodeUsage */
                if valid-handle(vhttField) then do:
                    if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                        vcCodeUsage = substitute('&1,&2', vcCodeUsage, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcCodeUsage = vhttField:buffer-value().
                    goCollection:set('cCodeUsage', trim(vcCodeUsage, ",")) no-error.
                end.
            end.
        end.
        delete object vhttFilter no-error.

message "rechercheCommercialisation apres gocollection  ".

        dataset dsbeCommercialisation:empty-dataset().
        vhProcCommercial = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run rechercheCommercialisation in vhProcCommercial(goCollection, output table ttFicheCommercialisation).
        run getErrors in vhProcCommercial(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void createbeFicheCommercialisation(input-output dataset dsbeUniteLocation):
        /*------------------------------------------------------------------------------
        Purpose: Creation des fiches de location à partir de la liste des UL sélectionnées
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc      as handle    no-undo.
        define variable viTypeFiche as integer   no-undo.

message "gga createbeFicheCommercialisation".

        assign
            vhProc      = outilHandle:connectMaGIModele("commercialisation/createFiche.p")
            viTypeFiche = {&TYPEFICHE-location}                 // Pour le moment seulement fiche Location
        .
        run createFiche in vhProc(viTypeFiche, input-output table ttUniteLocation).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeCommercialisation(pcFiltre as longchar, input-output dataset dsbeCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcVue         as character no-undo.
        define variable viNumeroFiche as integer   no-undo.
        define variable vhProcErreur  as handle    no-undo.
        define variable vhttFilter    as handle    no-undo.
        define variable vhBuffer      as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcVue         = vhBuffer::cVue no-error.
                viNumeroFiche = vhBuffer::iNumeroFiche no-error.
            end.
        end.
        delete object vhttFilter no-error.

message "updatebeCommercialisation  "  " vcVue " vcVue " iNumeroFiche " viNumeroFiche.

        case vcVue:
            when 'FICHE'                then vueFicheUpdate().
            when 'CARACTERISTIQUE'      then vueCaracteristiqueUpdate(input viNumeroFiche).
        //  when 'PIECEJOINTE'          then vuePieceJointeUpdate().
            when 'TIERCONTRAT'          then vueTiersContratUpdate().
            when 'GESTIONFINANCIERE'    then vueGestionFinanciereUpdate().
            otherwise do:
                vhProcErreur = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProcErreur({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in vhProcErreur(output table ttError).
            end.
        end case.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void CalculEncadrementLoyer(input-output dataset dsbeEncadrementLoyer):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle    no-undo.

message "gga ReadbeEncadrementLoyer : " .

        empty temp-table ttHistoEncadrementLoyer.
        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run appelServiceEncadrementLoyer in vhProc(table ttDemandeEncadrementLoyer, output table ttHistoEncadrementLoyer).
        run getErrors in vhProc(output table ttError).  /* ici il ne faut pas annuler les maj en cas d'erreur */
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void majbePlafonnementEncadrementLoyer(input-output dataset dsbePlafonnementEncadrementLoyer):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:  ttError en input sur saisiePlafonnementEncadrementLoyer car jeu de questions/reponses
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle    no-undo.

message "gga majbePlafonnementEncadrementLoyer : " .

        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run saisiePlafonnementEncadrementLoyer in vhProc(input-output table ttPlafonnementEncadrementLoyer, table ttError).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void MajbeFichierSiteWeb(input-output dataset dsbeSiteWeb):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle    no-undo.

message "gga MajbeFichierSiteWeb : " .

        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run MajFichierSiteWeb in vhProc (input-output table ttFichierSiteWeb).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void readbeBareme(output dataset dsbeBareme):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle    no-undo.

message "gga ReadbeBareme".

        dataset dsbeBareme:empty-dataset().
        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run readBareme in vhProc (output table ttBaremeHonoraireComm, output table ttCalculBareme).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void readbeSiteWeb(output dataset dsbeSiteWeb):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle    no-undo.

message "gga ReadbeSiteWeb".

        dataset dsbeBareme:empty-dataset().
        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run readSiteWeb in vhProc(output table ttSiteWeb).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void readbeFichierSiteWeb(pcFiltre as longchar, output dataset dsbeSiteWeb):
        /*------------------------------------------------------------------------------
        Purpose: lecture table des fichiers a ne pas publier par site web
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc       as handle    no-undo.
        define variable vhttFilter   as handle    no-undo.
        define variable vhBuffer     as handle    no-undo.
        define variable vcListePhoto as character no-undo.
        define variable vhttField    as handle    no-undo.
        define variable viI          as integer   no-undo.

        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vhttField = vhBuffer:buffer-field('cListePhoto') no-error.
                if valid-handle(vhttField)
                then if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                       vcListePhoto = substitute('&1,&2', vcListePhoto, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcListePhoto = vhttField:buffer-value().
                vcListePhoto = trim(vcListePhoto, ",").
            end.
        end.

message "gga ReadbeFichierSiteWeb " vcListePhoto.

        dataset dsbeSiteWeb:empty-dataset().
        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run readFichierSiteWeb in vhProc(vcListePhoto, output table ttFichierSiteWeb).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    method private logical vueGestionFinanciereUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcCommercial as handle  no-undo.

message "vueGestionFinanciereUpdate".
blocmaj:
        do:
            vhProcCommercial = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
            run setDepotFicheCommercialisation in vhProcCommercial (table ttDepotCommercialisation, table ttDetailFinanceDepot).
            run getErrors in vhProcCommercial(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocmaj.

            run setLoyerFicheCommercialisation in vhProcCommercial (table ttLoyerCommercialisation, table ttDetailFinanceLoyer).
            run getErrors in vhProcCommercial(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocmaj.

            run setHonoraireFicheCommercialisation in vhProcCommercial (table ttHonoraireCommercialisation, table ttDetailFinanceHonoraire).
        end.
        dataset dsbeCommercialisation:empty-dataset().
        run getErrors in vhProcCommercial(output table ttError).
    end method.

    method private logical vueFicheUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcCommercial as handle  no-undo.

message "vueFicheUpdate".

        vhProcCommercial = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run setinfofiche in vhProcCommercial (table ttFicheCommercialisation).
        dataset dsbeCommercialisation:empty-dataset().
        run getErrors in vhProcCommercial(output table ttError).
    end method.

    method private logical vueCaracteristiqueUpdate(piNumeroFiche as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcCommercial as handle  no-undo.

message "vueCaracteristiqueUpdate " piNumeroFiche.

blocmaj:
        do:
            vhProcCommercial = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
            run setcaracteristiqueproximite in vhProcCommercial (table ttProximite).
            run getErrors in vhProcCommercial(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocmaj.

            run setcaracteristiquesiteweb in vhProcCommercial (piNumeroFiche, table ttSiteWebFiche).
            run getErrors in vhProcCommercial(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocmaj.

            run setcaracteristiqueAttributsDivers in vhProcCommercial (piNumeroFiche, table ttAttributsDivers).
            run getErrors in vhProcCommercial(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocmaj.

            run setcaracteristiquesequence in vhProcCommercial (table ttSequence).
            /*
            run getErrors in vhProcCommercial(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocmaj.
            run setCaracteristiqueTiers in vhProcCommercial (table ttTiersCommercialisation).
            run getErrors in vhProcCommercial(output table ttError).
            */   /* nath plus bas */

        end.
        dataset dsbeCommercialisation:empty-dataset().
        run getErrors in vhProcCommercial(output table ttError).
    end method.

    method private logical vueTiersContratUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle  no-undo.

message "vueTiersContratUpdate".
blocmaj:
        do:
            vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
            run setTiersContratCommercialisation in vhProc(table ttTiersCommercialisation).
            run getErrors in vhProc(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocmaj.

            vhProc = outilHandle:connectMaGIModele("adresse/adresse.p").
            run setAdresseTiersCommercial in vhProc(table ttAdresseTiers).
            run getErrors in vhProc(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocmaj.

            vhProc = outilHandle:connectMaGIModele("adresse/moyenCommunication.p").
            run setMoyenCommunicationTiersCommercial in vhProc(table ttMoyenCommunicationTiers).
        end.
        dataset dsbeCommercialisation:empty-dataset().
        run getErrors in vhProc(output table ttError).            // geterror sur un seul programme car ttError partagé
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void createFamilleDepotFicheCommercialisation(pcfiltre as longchar, output dataset dsbeCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: création d'une famille "dépot de garantie" de la gestion financière
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc        as handle    no-undo.
        define variable viNumeroFiche as integer   no-undo.
        define variable vhttFilter    as handle    no-undo.
        define variable vhBuffer      as handle    no-undo.

message "gga createFamilleDepotFicheCommercialisation".

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroFiche = vhBuffer::iNumeroFiche no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run createFamilleDepotFicheCommercialisation in vhProc(viNumeroFiche, output table ttDepotCommercialisation, output table ttDetailFinanceDepot).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void createFamilleHonoraireFicheCommercialisation(pcfiltre as longchar, output dataset dsbeCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: création d'une famille "Honoraire" de la gestion financière
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc           as handle    no-undo.
        define variable viNumeroFiche    as integer   no-undo.
        define variable viTypeHonoraire1 as integer   no-undo.
        define variable viTypeHonoraire2 as integer   no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                // Garder plusieurs assign pour récupérer les champs OK dans le cas d'une erreur.
                viNumeroFiche    = vhBuffer::iNumeroFiche    no-error.
                viTypeHonoraire1 = vhBuffer::iTypeHonoraire1 no-error.
                viTypeHonoraire2 = vhBuffer::iTypeHonoraire2 no-error.
            end.
        end.
        delete object vhttFilter no-error.

message "createFamilleHonoraireFicheCommercialisation: viNumeroFiche = " viNumeroFiche
                                                       " viTypeHonoraire1 = " viTypeHonoraire1
                                                       " viTypeHonoraire2 = " viTypeHonoraire2.

        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run createFamilleHonoraireFicheCommercialisation in vhProc(viNumeroFiche,
                                                                   viTypeHonoraire1,
                                                                   viTypeHonoraire2,
                                                                   output table ttHonoraireCommercialisation,
                                                                   output table ttDetailFinanceHonoraire).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void createFamilleLoyerFicheCommercialisation(pcfiltre as longchar, output dataset dsbeCommercialisation):
        /*------------------------------------------------------------------------------
        Purpose: création d'une famille "dépot de garantie" de la gestion financière
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc        as handle  no-undo.
        define variable viNumeroFiche as integer no-undo.
        define variable vhttFilter    as handle  no-undo.
        define variable vhBuffer      as handle  no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroFiche = integer(vhBuffer::iNumeroFiche) no-error.
            end.
        end.
        delete object vhttFilter no-error.

message "createFamilleLoyerFicheCommercialisation: viNumeroFiche = " viNumeroFiche.

        vhProc = outilHandle:connectMaGIModele("commercialisation/commercialisation.p").
        run createFamilleLoyerFicheCommercialisation in vhProc(viNumeroFiche, output table ttLoyerCommercialisation, output table ttDetailFinanceLoyer).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beCommercialisation ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
