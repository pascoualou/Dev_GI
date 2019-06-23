/*------------------------------------------------------------------------
File        : beLot.cls
Purpose     :
Author(s)   : KANTENA - 2016/08/04
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}

@program FILE(name="beLot.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beLot", URI="/beLot", schemaName="dsbeLot", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class immeubleEtLot.beLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: selfDestroy est positionné à faux par la classe qui aura instancié beLot.
           Sinon, le destructeur de beLot fait un 'ménage' intensif et détruit aussi l'appelant!!
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/combo.i}
    {application/include/error.i}
    {immeubleEtLot/include/diagnostic.i}
    {immeubleEtLot/include/equipementBien.i}
    {immeubleEtLot/include/fichierJoint.i}
    {immeubleEtLot/include/lot.i}
    {note/include/notes.i &nomTable=ttNotes &serialName=ttNote}
    {immeubleEtLot/include/piece.i}
    {immeubleEtLot/include/plan.i}
    {immeubleEtLot/include/surface.i &nomTable=ttSurfaceLot &serialName=ttSurfaceLot}
    {immeubleEtLot/include/tantieme.i}    
    {immeubleEtLot/include/cpuni.i}
    {mandat/include/uniteComposition.i}
    {adresse/include/adresse.i &nomTable=ttAdresseLot &serialName=ttAdresseLot}
    {adresse/include/moyenCommunication.i}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationLoca}
    {adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationCopro}
    {adresse/include/coordonnee.i}
    {adresse/include/coordonnee.i &nomTable=ttCoordonneeLocataire}
    {adresse/include/coordonnee.i &nomTable=ttCoordonneeCoproprietaire}
    {role/include/roleContrat.i}   
    {role/include/role.i &nomTable=ttRolePrivatif}
    {serviceGestion/include/serviceGestion.i}
    {serviceGestion/include/gestionnaire.i}
    

    define buffer gbttError                    for ttError.
    define buffer gbttError2                   for ttError.
    define buffer gbttError3                   for ttError.
    define buffer gbttMoyenCommunicationLoca   for ttMoyenCommunicationLoca.
    define buffer gbttMoyenCommunicationCopro  for ttMoyenCommunicationCopro.
    define buffer gbttCoordonneeCoproprietaire for ttCoordonneeCoproprietaire.
    define buffer gbttCoordonneeLocataire      for ttCoordonneeLocataire.
    define buffer gbttSurfaceLot               for ttSurfaceLot.
    define buffer gbttAdresseLot               for ttAdresseLot.
    define temp-table ttPourcentageTauxReduit no-undo
     field dPourcentageTauxReduit as decimal.
    
    define dataset dsbeLot 
    for ttLot, ttAdresseLot, ttContratLot, ttRoleContrat, ttServiceGestion, ttGestionnaire, ttEquipementBien, ttFichierJointEquipement, 
        ttMoyenCommunicationLoca, ttMoyenCommunicationCopro, ttCoordonneeCoproprietaire, ttCoordonneeLocataire, ttSurfaceLot, ttPiece, 
        ttDiagnosticEtude, ttPlan, ttTantiemeLot, ttNotes, ttError
        data-relation ContratRole          for ttContratLot, ttRoleContrat nested foreign-key-hidden
            relation-fields (ttContratLot.iNumeroContrat, ttRoleContrat.iNumeroContrat,
                             ttContratLot.cTypeContrat, ttRoleContrat.cTypeContrat)
        data-relation ContratService       for ttContratLot, ttServiceGestion nested foreign-key-hidden
            relation-fields (ttContratLot.iNumeroImmeuble, ttServiceGestion.iNumeroImmeuble,
                             ttContratLot.iNumeroContrat, ttServiceGestion.iNumeroContrat,
                             ttContratLot.cTypeContrat, ttServiceGestion.cTypeContrat)
        data-relation ContratGestionnaire  for ttContratLot, ttGestionnaire nested foreign-key-hidden
            relation-fields (ttContratLot.iNumeroImmeuble, ttGestionnaire.iNumeroImmeuble,
                             ttContratLot.iNumeroContrat, ttGestionnaire.iNumeroContrat,
                             ttContratLot.cTypeContrat, ttGestionnaire.cTypeContrat)
      /* COORDONNEES LOT -------------------------------------------------------------------------------*/
        data-relation LotCoordonneesLoca   for ttLot, ttCoordonneeLocataire nested foreign-key-hidden
            relation-fields (ttLot.iNumeroBien, ttCoordonneeLocataire.iNumeroIdentifiant)
        data-relation LotCoordonneesCopro  for ttLot, ttCoordonneeCoproprietaire nested foreign-key-hidden
            relation-fields (ttLot.iNumeroBien, ttCoordonneeCoproprietaire.iNumeroIdentifiant)
        data-relation CoordonneesMoyensL   for ttCoordonneeLocataire, ttMoyenCommunicationLoca nested foreign-key-hidden
            relation-fields (ttCoordonneeLocataire.cJointure, ttMoyenCommunicationLoca.cJointure)
        data-relation CoordonneesMoyensC   for ttCoordonneeCoproprietaire, ttMoyenCommunicationCopro nested foreign-key-hidden
            relation-fields (ttCoordonneeCoproprietaire.cJointure, ttMoyenCommunicationCopro.cJointure)
    /* ttEquipementBienS LOT ------------------------------------------------------------------------*/
        data-relation lotEquipementFichier for ttEquipementBien, ttFichierJointEquipement nested foreign-key-hidden
            relation-fields (ttEquipementBien.cTypeBien, ttFichierJointEquipement.cTypeBien,
                             ttEquipementBien.iNumeroBien, ttFichierJointEquipement.iNumeroBien)
    .

    define dataset     dsbeListeLot  for ttListeLot, gbttAdresseLot, gbttMoyenCommunicationLoca, gbttMoyenCommunicationCopro, gbttCoordonneeCoproprietaire, gbttCoordonneeLocataire, gbttSurfaceLot, gbttError
     /* ADRESSES LOT -------------------------------------------------------------------------------*/
        data-relation ListeLotAdresse      for ttListeLot, gbttAdresseLot nested foreign-key-hidden
            relation-fields (ttListeLot.iNumeroBien, gbttAdresseLot.iNumeroIdentifiant)
    /* COORDONNEES LOTS -------------------------------------------------------------------------------*/
        data-relation lotCoordonneesLoca   for ttListeLot, gbttCoordonneeLocataire nested foreign-key-hidden
            relation-fields (ttListeLot.iNumeroLot, gbttCoordonneeLocataire.iNumeroIdentifiant)
        data-relation lotCoordonneesCopro  for ttListeLot, gbttCoordonneeCoproprietaire nested foreign-key-hidden
            relation-fields (ttListeLot.iNumeroLot, gbttCoordonneeCoproprietaire.iNumeroIdentifiant)
        data-relation coordonneesMoyensL   for gbttCoordonneeLocataire, gbttMoyenCommunicationLoca nested foreign-key-hidden
            relation-fields (gbttCoordonneeLocataire.cJointure, gbttMoyenCommunicationLoca.cJointure)
        data-relation coordonneesMoyensC   for gbttCoordonneeCoproprietaire, gbttMoyenCommunicationCopro nested foreign-key-hidden
            relation-fields (gbttCoordonneeCoproprietaire.cJointure, gbttMoyenCommunicationCopro.cJointure)
    /* SURFACE LOT -------------------------------------------------------------------------------*/
        data-relation listeLotSurface           for ttListeLot, gbttSurfaceLot nested foreign-key-hidden
            relation-fields (ttListeLot.iNumeroBien, gbttSurfaceLot.iNumeroBien)
    .
    define dataset dsbeCombo for ttCombo, gbttError2.
    define dataset dsPourcentageTauxReduit for ttPourcentageTauxReduit, gbttError3.

    constructor public beLot():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void rechercheLot(pcFiltre as longchar, output dataset dsbeListeLot):
        /*------------------------------------------------------------------------------
        Purpose: Recherche générique activée par magiRecherche/rechercheEtendue.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcLot  as handle no-undo.
        define variable vhttFilter as handle no-undo.
        define variable vhBuffer   as handle no-undo.

        empty temp-table ttListeLot.
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set("cAdresseImmeuble",     vhBuffer::cAdresseImmeuble)          no-error.
                goCollection:set("iNumeroImmeuble",      integer(vhBuffer::iNumeroImmeuble))  no-error.
                goCollection:set("iNumeroImmeuble1",     integer(vhBuffer::iNumeroImmeuble1)) no-error.
                goCollection:set("iNumeroImmeuble2",     integer(vhBuffer::iNumeroImmeuble2)) no-error.
                goCollection:set("iNumeroMandat",        integer(vhBuffer::iNumeroMandat))    no-error.
                goCollection:set("iNumeroMandat1",       integer(vhBuffer::iNumeroMandat1))   no-error.
                goCollection:set("iNumeroMandat2",       integer(vhBuffer::iNumeroMandat2))   no-error.
                goCollection:set("lGerance",             vhBuffer::lGerance)                  no-error.
                goCollection:set("lCopropriete",         vhBuffer::lCopropriete)              no-error.
                goCollection:set("lAucun",               vhBuffer::lAucun)                    no-error.
                goCollection:set("cStatut",              vhBuffer::cStatut)                   no-error.
                goCollection:set("cService",             vhBuffer::cCodeService)              no-error.
                goCollection:set("iNumeroLot1",          integer(vhBuffer::iNumeroLot1))      no-error.
                goCollection:set("iNumeroLot2",          integer(vhBuffer::iNumeroLot2))      no-error.
                goCollection:set("cNatureLot",           vhBuffer::cNatureLot)                no-error.
                goCollection:set("cTypeImmeuble",        vhBuffer::cTypeImmeuble)             no-error.
                goCollection:set("cSecteurGeographique", vhBuffer::cSecteurGeographique)      no-error.
                goCollection:set("cNatureBien",          vhBuffer::cNatureBien)               no-error.
                goCollection:set("cCategorieBien",       vhBuffer::cCategorieBien)            no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        run rechercheLot in vhProcLot(goCollection, output table ttListeLot, output table ttAdresseLot, output table ttSurfacelot).
        run getErrors    in vhProcLot(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void readbeLot(pcFiltre as longchar, output cLot as longchar):
        /*------------------------------------------------------------------------------
        Purpose: renvoie un dataset lié à la vue 'cVue' demandée.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcLot      as handle    no-undo.
        define variable vhProcNote     as handle    no-undo.
        define variable vhProcTantieme as handle    no-undo.
        define variable vhProcAdresse  as handle    no-undo.
        define variable vhProcSurface  as handle    no-undo.
        define variable vhProcErreur   as handle    no-undo.
        define variable vhttFilter     as handle    no-undo.
        define variable vhBuffer       as handle    no-undo.
        define variable viNumeroBien   as int64     no-undo.
        define variable vcVue          as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroBien = int64(vhBuffer::iNumeroBien) no-error.
                vcVue        = vhBuffer::cVue               no-error.
            end.
        end.
        delete object vhttFilter no-error.

        case vcVue:
            when 'LOT'             then vueLotRead(viNumeroBien).
            when 'CONTRAT'         then vueContratRead(viNumeroBien).
            when 'DIAGNOSTICETUDE' then vueDiagnosticEtudeRead(viNumeroBien).
            when 'EQUIPEMENT'      then vueEquipementRead(viNumeroBien).
            when 'NOTE'            then vueNoteRead(viNumeroBien).
            when 'PLAN'            then vuePlanRead(viNumeroBien).
            when 'SURFACE'         then vueSurfaceRead(viNumeroBien).
            when 'TANTIEME'        then vueTantiemeRead(viNumeroBien).
            when 'TOUS'            then do:
                assign
                    vhProcLot      = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
                    vhProcTantieme = outilHandle:connectMaGIModele("immeubleEtLot/tantieme.p")
                    vhProcSurface  = outilHandle:connectMaGIModele("immeubleEtLot/surface_crud.p")
                    vhProcNote     = outilHandle:connectMaGIModele("note/notes_CRUD.p").
                    vhProcAdresse  = outilHandle:connectMaGIModele("adresse/adresse.p").
                .
                run getLot           in vhProcLot (viNumeroBien, output table ttLot).
                run getAdresse       in vhProcAdresse({&TYPEBIEN-lot}, viNumeroBien, "", "1", output table ttAdresseLot, output table ttCoordonnee, output table ttMoyenCommunication).
                run getContratLot    in vhProcLot (viNumeroBien, output table ttContratLot, output table ttRoleContrat, output table ttServiceGestion, output table ttGestionnaire).
                run getCoordonneeLot in vhProcLot (viNumeroBien, output table ttCoordonneeLocataire, output table ttCoordonneeCoproprietaire, output table ttMoyenCommunicationLoca, output table ttMoyenCommunicationCopro).
                run readSurface      in vhProcSurface({&TYPEBIEN-lot}, viNumeroBien, "", output table ttSurfaceLot). 
                run getEquipementLot in vhProcLot (viNumeroBien, output table ttEquipementBien, output table ttFichierJointEquipement).
                run getPiece         in vhProcLot (viNumeroBien, output table ttPiece).
                run getNotesLot      in vhProcLot (viNumeroBien, output table ttNotes).
                run getTantiemeLot   in vhProcTantieme(viNumeroBien, output table ttTantiemeLot).
            end.
            otherwise do:
                vhProcErreur = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProcErreur({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in vhProcErreur(output table ttError).
            end.
        end case.
        // non formaté, UTF-8, omit initial-values, outer-most object, pas write before-image 
        dataset dsbeLot:write-json("LONGCHAR", cLot, false, ?, true, false, false).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeLot(pcFiltre as longchar, output dataset dsbeListeLot):
        /*------------------------------------------------------------------------------
        Purpose: renvoie la liste des lots des interventions, détaillée si 'iNumeroImmeuble' est donné.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcLot          as handle    no-undo.
        define variable vhProcSurface      as handle    no-undo.
        define variable vhProcAdresse      as handle    no-undo.
        define variable vcTypeContrat      as character no-undo.
        define variable viNumeroContrat    as integer   no-undo.
        define variable viNumeroTraitement as integer   no-undo.
        define variable vcTypeIntervention as character no-undo.
        define variable viNumeroImmeuble   as integer   no-undo.
        define variable vhttFilter         as handle    no-undo.
        define variable vhBuffer           as handle    no-undo.
        define variable vlIsPrincipal      as logical   no-undo.

        dataset dsbeLot:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeContrat      = vhBuffer::cTypeContrat               no-error.
                viNumeroContrat    = integer(vhBuffer::iNumeroContrat)    no-error.    
                viNumeroTraitement = integer(vhBuffer::iNumeroTraitement) no-error.
                vcTypeIntervention = vhBuffer::cTypeIntervention          no-error.
                viNumeroImmeuble   = integer(vhBuffer::iNumeroImmeuble)   no-error.
                vlIsPrincipal      = logical(vhBuffer::lIsPrincipal)      no-error.
            end.
        end.
        delete object vhttFilter no-error.

        assign
            vhProcLot     = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
            vhProcSurface = outilHandle:connectMaGIModele("immeubleEtLot/surface_crud.p")
            vhProcAdresse = outilHandle:connectMaGIModele("adresse/adresse.p")
        .
        if viNumeroImmeuble > 0
        then do:
            run getListeLotsImmeuble      in vhProcLot(viNumeroImmeuble, vlIsPrincipal, output table ttListeLot).
            run getAdresseSelection       in vhProcAdresse({&TYPEBIEN-lot}, "", "1", table ttListeLot, output table ttAdresseLot, output table ttCoordonnee, output table ttMoyenCommunication).
            run getCoordonneeSelectionLot in vhProcLot(table ttListeLot, output table ttCoordonneeLocataire, output table ttCoordonneeCoproprietaire, output table ttMoyenCommunicationLoca, output table ttMoyenCommunicationCopro).
            run readSurfaceSelectionLot   in vhProcSurface("PRINCIPALE", table ttListeLot, output table ttSurfaceLot).
        end.
        else run getListeLotsIntervention in vhProcLot(vcTypeContrat, viNumeroContrat, vcTypeIntervention, viNumeroTraitement, output table ttListeLot).
        run getErrors in vhProcLot(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeLotImmeuble(pcFiltre as longchar, output pcLot as longchar):
        /*------------------------------------------------------------------------------
        Purpose: renvoie la liste des lots d'un immeuble
        Notes: localhost:8810/rest/magiImmeubleEtLot/listeLotImmeuble?filter={"filters":{"iNumeroImmeuble":12}}
        ------------------------------------------------------------------------------*/
        define variable vhProcLot        as handle no-undo.
        define variable vhttFilter       as handle no-undo.
        define variable vhBuffer         as handle no-undo.
        define variable viNumeroImmeuble as integer no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroImmeuble   = integer(vhBuffer::iNumeroImmeuble) no-error.
            end.
        end.
        delete object vhttFilter no-error.
        
        if viNumeroImmeuble > 0
        then do:
            vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
            run getListeLotsImmeubleSimplifiee in vhProcLot (viNumeroImmeuble, output table ttlot).
            run getErrors                      in vhProcLot (output table ttError).
            dataset dsbeLot:write-json("LONGCHAR", pcLot, false, ?, true, false, false).
        end.
        {outils/include/tryCatch.i}
    end method.
      
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeLotContratSimplifie(pcFiltre as longchar, output pcLot as longchar):
        /*------------------------------------------------------------------------------
        Purpose: renvoie la liste des lots simplifie d'un contrat (parametre en entree : numero de contrat, type de contrat)
        Notes: localhost:8810/rest/magiImmeubleEtLot/listeLotContratSimplifie?filter={"filters": {"iNumeroContrat":"695","cTypeContrat":"01030"}}
        ------------------------------------------------------------------------------*/
        define variable vhProcLot        as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable vcTypeContrat    as character no-undo.
        define variable viNumeroContrat  as int64     no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroContrat  = int64(vhBuffer::iNumeroContrat) no-error.
                vcTypeContrat    = vhBuffer::cTypeContrat          no-error.
            end.
        end.
        delete object vhttFilter no-error.
        
        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        run getListeLotContratSimplifie in vhProcLot (viNumeroContrat, vcTypeContrat, output table ttlot).
        run getErrors in vhProcLot (output table ttError).
        dataset dsbeLot:write-json("LONGCHAR", pcLot, false, ?, true, false, false).
        {outils/include/tryCatch.i}

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeLotContratImmeuble(pcFiltre as longchar, output dataset dsbeListeLot):
        /*------------------------------------------------------------------------------
        Purpose: renvoie la liste des lots d'un contrat ou d'un immeuble
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcLot        as handle    no-undo.
        define variable vcTypeContrat    as character no-undo.
        define variable viNumeroContrat  as integer   no-undo.
        define variable viNumeroImmeuble as integer   no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.

        dataset dsbeListeLot:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroContrat  = integer(vhBuffer::iNumeroContrat) no-error.
                vcTypeContrat    = vhBuffer::cTypeContrat no-error.
                viNumeroImmeuble = integer(vhBuffer::iNumeroImmeuble) no-error.
            end.            
        end.
        delete object vhttFilter no-error.

        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        run getListeLotsContratImmeuble in vhProcLot(vcTypeContrat, viNumeroContrat, viNumeroImmeuble, output table ttListeLot).
        run getErrors in vhProcLot(output table ttError).
        {outils/include/tryCatch.i}
    end method.
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeLotMandat(pcFiltre as longchar, output dataset dsbeListeLot):
        /*------------------------------------------------------------------------------
        Purpose: renvoie la liste des lots d'un mandat
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcLot        as handle    no-undo.
        define variable viNumeroMandat   as integer   no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.

        dataset dsbeListeLot:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroMandat = integer(vhBuffer::iNumeroMandat) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        run getLotsMandat in vhProcLot(viNumeroMandat, output table ttListeLot).
        run getErrors in vhProcLot(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeLot(input-output dataset dsbeLot):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeLot(pcFiltre as longchar, input-output dataset dsbeLot):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter     as handle    no-undo.
        define variable vhBuffer       as handle    no-undo.
        define variable viNumeroBien   as int64     no-undo.
        define variable vcVue          as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroBien = int64(vhBuffer::iNumeroBien) no-error.
                vcVue        = vhBuffer::cVue               no-error.
            end.
        end.
        delete object vhttFilter no-error.

        case vcVue:
            when 'LOT'             then vueLotUpdate().
            when 'LOTSIMPLIFIE'    then vueLotSimplifieUpdate().
            when 'DIAGNOSTICETUDE' then vueDiagnosticEtudeUpdate(viNumeroBien).
            when 'NOTE'            then vueNoteUpdate().
            when 'PLAN'            then vuePlanUpdate(viNumeroBien).
            when 'SURFACE'         then vueSurfaceUpdate().
            when 'EQUIPEMENT'      then vueEquipementUpdate().
        end case.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeLot(input-output dataset dsbeLot):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbePourcentageTauxReduit(pcFiltre as longchar, output dataset dsPourcentageTauxReduit):
        /*------------------------------------------------------------------------------
        Purpose: renvoie le pourcentage de tva réduit en fonction du type des lots 
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable viNumeroImmeuble as integer   no-undo.
        define variable vcCodeCle        as character no-undo.
        define variable vhProcLot        as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroImmeuble = integer(vhBuffer::iNumeroImmeuble) no-error.
                vcCodeCle        = vhBuffer::cCodeCle no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        create ttPourcentageTauxReduit.
        ttPourcentageTauxReduit.dPourcentageTauxReduit = dynamic-function('calculPourcentageTauxReduit' in vhProcLot, viNumeroImmeuble, vcCodeCle).
        run getErrors in vhProcLot(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    method private logical vueLotRead(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcLot     as handle no-undo.
        define variable vhProcAdresse as handle no-undo.
        assign
            vhProcLot     = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
            vhProcAdresse = outilHandle:connectMaGIModele("adresse/adresse.p")
        .
        run getLot     in vhProcLot(piNumeroBien, output table ttLot).
        run getAdresse in vhProcAdresse({&TYPEBIEN-lot}, piNumeroBien, "", "1", output table ttAdresseLot, output table ttCoordonnee, output table ttMoyenCommunication).
        run getErrors  in vhProcLot(output table ttError).

    end method.

    method private logical vueLotUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcLot     as handle no-undo.

        vhProcLot = outilHandle:connectMaGIModele('ImmeubleEtLot/lot.p').
blocUpdate:
        do:
            run controleSaisieSituation in vhProcLot(input  table ttLot).
            run getErrors               in vhProcLot(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            run controleSaisieProprietaire in vhProcLot(input  table ttLot).
            run getErrors                  in vhProcLot(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            run setLot    in vhProcLot(table ttLot).
            run getErrors in vhProcLot(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.
            
            run setAdresseLot in vhProcLot(table ttAdresseLot, table ttCoordonnee, table ttMoyenCommunication). 
            run getErrors     in vhProcLot(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.
        end.
        dataset dsbeLot:empty-dataset().
        run getErrors in vhProcLot(output table ttError).  // Attention, getErrors après empty-dataset, sinon ttError est vide !

    end method.

    method private logical vueLotSimplifieUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : 
        ------------------------------------------------------------------------------*/
        define variable vhProcLot     as handle no-undo.
        define variable vhProcSurface as handle no-undo.

        assign
            vhProcLot     = outilHandle:connectMaGIModele('ImmeubleEtLot/lot.p')
            vhProcSurface = outilHandle:connectMaGIModele("immeubleEtLot/surface_crud.p")
        .
blocUpdate:
        do:
            run setSurfaceLot in vhProcSurface({&TYPEBIEN-lot}, table ttSurfaceLot, input-output table ttLot).
            run getErrors     in vhProcSurface(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            run controleSaisieSurface in vhProcLot(input table ttLot).
            run getErrors             in vhProcLot(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            run setLot     in vhProcLot(table ttLot).
            run getErrors  in vhProcLot(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.
        end.
        dataset dsbeLot:empty-dataset().
        run getErrors in vhProcLot(output table ttError).  // Attention, getErrors après empty-dataset, sinon ttError est vide !

    end method.

    method private logical vueSurfaceRead(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : 
        ------------------------------------------------------------------------------*/
        define variable vhProcSurface as handle no-undo.
        define variable vhProcPiece   as handle no-undo.

        assign
            vhProcSurface = outilHandle:connectMaGIModele("immeubleEtLot/surface_crud.p")
            vhProcPiece   = outilHandle:connectMaGIModele("immeubleEtLot/piece.p")
        .
        run getPiece    in vhProcPiece (piNumeroBien, output table ttPiece).
        run readSurface in vhProcSurface({&TYPEBIEN-lot}, piNumeroBien, "", output table ttSurfaceLot).
        run getErrors   in vhProcSurface(output table ttError).

    end method.

    method private logical vueSurfaceUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : getErrors est fait entre chaque run pour éviter les run suivant en cas d'erreur
        ------------------------------------------------------------------------------*/
        define variable vhProcLot     as handle no-undo.
        define variable vhProccpuni   as handle no-undo.
        define variable vhProcSurface as handle no-undo.
        define variable vhProcPiece   as handle no-undo.
        
        assign 
            vhProcLot     = outilHandle:connectMaGIModele('ImmeubleEtLot/lot.p')
            vhProccpuni   = outilHandle:connectMaGIModele('ImmeubleEtLot/cpuni_crud.p')
            vhProcSurface = outilHandle:connectMaGIModele("immeubleEtLot/surface_crud.p")
            vhProcPiece   = outilHandle:connectMaGIModele("immeubleEtLot/piece.p").
        .
blocUpdate:
        do:
            run setSurfaceLot in vhProcSurface({&TYPEBIEN-lot}, table ttSurfaceLot, input-output table ttLot).
            run getErrors     in vhProcSurface(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            run controleSaisieSurface in vhProcLot(input table ttLot).
            run getErrors             in vhProcLot(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            run setLot              in vhProcLot(table ttLot).
            run setUniteLocationLot in vhProcLot(table ttLot, output table ttCpUni).
            run getErrors           in vhProcLot(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            run setPiece    in vhProcPiece (table ttPiece).
            run getErrors   in vhProcPiece (output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            run updateCompositionUnite in vhProccpuni(table ttCpUni).
            run getErrors              in vhProccpuni(output table ttError).

        end.
        dataset dsbeLot:empty-dataset().
        run getErrors in vhProcSurface(output table ttError).

    end method.

    method private logical vueTantiemeRead(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : 
        ------------------------------------------------------------------------------*/
        define variable vhProcTantieme as handle no-undo.

        vhProcTantieme = outilHandle:connectMaGIModele("immeubleEtLot/tantieme.p").
        run getTantiemeLot in vhProcTantieme(piNumeroBien, output table ttTantiemeLot).
        run getErrors      in vhProcTantieme(output table ttError).

    end method.
    
    method private logical vueContratRead(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : 
        ------------------------------------------------------------------------------*/
        define variable vhProcLot as handle no-undo.

        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        run getContratLot in vhProcLot(piNumeroBien, output table ttContratLot, output table ttRoleContrat, output table ttServiceGestion, output table ttGestionnaire).
        run getErrors     in vhProcLot(output table ttError).

    end method.

    method private logical vueNoteRead(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :  
        ------------------------------------------------------------------------------*/
        define variable vhProcLot as handle no-undo.

        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        run getNotesLot in vhProcLot(piNumeroBien, output table ttNotes).
        run getErrors   in vhProcLot(output table ttError).

    end method.

    method private logical vueDiagnosticEtudeRead(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble              as handle  no-undo.
        define variable vhProcLot                   as handle  no-undo.
        define variable vhProcDiagnostic            as handle  no-undo.
        define variable viNumeroContratConstruction as int64   no-undo.
        define variable viNumeroImmeuble            as integer no-undo.

        assign
            vhProcLot                   = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcDiagnostic            = outilHandle:connectMaGIModele("immeubleEtLot/diagnostic.p")
            viNumeroImmeuble            = dynamic-function("getNumeroImmeuble" in vhProcLot, piNumeroBien)
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, viNumeroImmeuble)
        .
        run getdiagnosticEtudelot in vhProcDiagnostic(viNumeroImmeuble, piNumeroBien, viNumeroContratConstruction, output table ttdiagnosticEtude).
        run getErrors             in vhProcDiagnostic(output table ttError).

    end method.

    method private logical vueDiagnosticEtudeUpdate(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/        
        define variable vhProcLot        as handle no-undo.
        define variable vhProcImmeuble   as handle no-undo.
        define variable vhProcTache      as handle no-undo.
        define variable viNumeroImmeuble as integer no-undo.
        define variable viNumeroContratConstruction as int64 no-undo.

        assign
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            vhProcLot                   = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            viNumeroImmeuble            = dynamic-function("getNumeroImmeuble" in vhProcLot, piNumeroBien)
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, viNumeroImmeuble)
        .
        run setDiagnosticEtude in vhProcTache(viNumeroContratConstruction, piNumeroBien, table ttdiagnosticEtude).
        dataset dsbeLot:empty-dataset().
        run getErrors          in vhProcTache(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !

    end method.

    method private logical vueNoteUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcNote  as handle no-undo.
        define variable vhProcLot   as handle no-undo.

        assign 
            vhProcNote = outilHandle:connectMaGIModele("note/notes_CRUD.p")
            vhProcLot  = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
        .
blocUpdate:
        do:
            run setNotes in vhProcNote(input-output table ttNotes).
            run getErrors in vhProcNote(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocUpdate.

            for each ttNotes
              , first ttLot
                where ttLot.iNumeroBien = ttNotes.iNumeroIdentifiant:
                ttLot.iNumeroBlocNote = ttNotes.iNumeroBlocNote.
            end.
            run setLot in vhProcLot(table ttLot).
        end.
        dataset dsbeLot:empty-dataset().
        run getErrors in vhProcLot(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !
    end method.

    method private logical vuePlanRead(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble              as handle  no-undo.
        define variable vhProcLot                   as handle  no-undo.
        define variable vhProcPlan                  as handle  no-undo.
        define variable viNumeroContratConstruction as int64   no-undo.
        define variable viNumeroImmeuble            as integer no-undo.

        assign
            vhProcLot                   = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
            vhProcPlan                  = outilHandle:connectMaGIModele("immeubleEtLot/plan.p")
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            viNumeroImmeuble            = dynamic-function("getNumeroImmeuble" in vhProcLot, piNumeroBien)
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, viNumeroImmeuble)
        .
        run getPlanLot in vhProcPlan(viNumeroImmeuble, piNumeroBien, viNumeroContratConstruction, output table ttPlan).
        run getErrors  in vhProcPlan(output table ttError).

    end method.

    method private logical vuePlanUpdate(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcImmeuble              as handle  no-undo.
        define variable vhProcLot                   as handle  no-undo.
        define variable vhProcPlan                  as handle  no-undo.
        define variable vhProcTache                 as handle  no-undo.
        define variable viNumeroContratConstruction as int64   no-undo.
        define variable viNumeroImmeuble            as integer no-undo.

        assign
            vhProcTache                 = outilHandle:connectMaGIModele("tache/tacheImmeuble.p")
            vhProcLot                   = outilHandle:connectMaGIModele("immeubleEtLot/lot.p")
            vhProcImmeuble              = outilHandle:connectMaGIModele("immeubleEtLot/immeuble.p")
            viNumeroImmeuble            = dynamic-function("getNumeroImmeuble" in vhProcLot, piNumeroBien)
            viNumeroContratConstruction = dynamic-function("getNumeroContratConstruction" in vhProcImmeuble, viNumeroImmeuble)
        .
        run setPlan   in vhProcTache(viNumeroContratConstruction, piNumeroBien, table ttPlan).
        dataset dsbeLot:empty-dataset().
        run getErrors in vhProcTache(output table ttError).

    end method.

    method private logical vueEquipementRead(piNumeroBien as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : 
        ------------------------------------------------------------------------------*/
        define variable vhProcLot as handle no-undo.

        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        run getEquipementLot in vhProcLot(piNumeroBien, output table ttEquipementBien, output table ttFichierJointEquipement).
        run getErrors        in vhProcLot(output table ttError).

    end method.

    method private logical vueEquipementUpdate():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProcEqBien as handle no-undo.

        vhProcEqBien = outilHandle:connectMaGIModele("immeubleEtLot/equipementBien.p").
        run setEquipementBien in vhProcEqBien(table ttEquipementBien, table ttFichierJointEquipement).
        dataset dsbeLot:empty-dataset().
        run getErrors in vhProcEqBien(output table ttError).  // Attention, getErrors sur n'importe quel hProc, après empty-dataset, sinon ttError est vide !

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void testNumeroLot(pcFiltre as longchar, output dataset dsbeLot):
        /*------------------------------------------------------------------------------
        Purpose: Vérification du numéro de lot d'un immeuble.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcLot        as handle  no-undo.
        define variable viNumeroImmeuble as integer no-undo.
        define variable viNumeroLot      as integer no-undo.
        define variable vhttFilter       as handle  no-undo.
        define variable vhBuffer         as handle  no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroImmeuble = integer(vhBuffer::iNumeroImmeuble) no-error.
                viNumeroLot      = integer(vhBuffer::iNumeroLot)      no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProcLot = outilHandle:connectMaGIModele("immeubleEtLot/lot.p").
        dynamic-function('testNumeroLot' in vhprocLot, viNumeroImmeuble, viNumeroLot).
        run getErrors in vhProcLot (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beLot( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle(). 
    end destructor. 

end class.
