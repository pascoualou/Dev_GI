/*------------------------------------------------------------------------
File        : beMandatSyndic.cls 
Syntax      :
Author(s)   : 
Notes       :
derniere revue:
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

@program FILE(name="beMandatSyndic.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beMandatSyndic", URI="/beMandatSyndic", schemaName="dsbeMandatSyndic", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class mandat.syndic.beMandatSyndic:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/combo.i}
    {application/include/error.i}
    define variable ghProc           as handle no-undo.  // plutôt que définir dans chacune des procédures
    define variable ghttAutorisation as handle no-undo.
    define variable ghttError        as handle no-undo.
    {mandat/include/creationMandat.i &nomtable=ttCreationMandatSyndic &serialName=ttCreationMandatSyndic}
    {mandat/include/listeMandat.i &nomtable=ttListeMandatSyndic &serialName=ttListeMandatSyndic}    
    {mandat/include/listeNumeroContratDispo.i}
    {mandat/include/objetMandatSyndic.i}
    {mandat/include/listeTache.i &nomtable=ttListeTacheMandatSyndic &serialName=ttListeTacheMandatSyndic}
    {mandat\include\periodeChargesCopro.i} 
    {mandat\include\titreCopropriete.i}
    {tache/include/tacheService.i}
    {tache/include/tacheCleRepartition.i &nomTableDetailCle=ttDetailCleCopro   &serialNameDetailCle=ttDetailCleCopro}    //la description de la table est differente si nom de la table contient copro
    {mandat/include/clemi.i}
    {mandat/include/clemi.i &nomtable=ttCleRepartition &serialName=ttCleRepartition}
            
    define dataset dsbeMandatSyndic for
        ttCreationMandatSyndic,
        ttListeMandatSyndic,
        ttListeNumeroContratDispo,
        ttObjetMandatSyndic,
        ttListeTacheMandatSyndic,
        ttPeriodeChargesCopro,
        ttTacheService, ttListeService,
        ttTacheCleRepartition, ttCleRepartition, ttDetailCleCopro, ttClemi,
        ttTitreCopropriete, ttIntervenantsTitreCopropriete,
        ttCombo, ttError
       data-relation TitreCoproprieteIntervenants for ttTitreCopropriete, ttIntervenantsTitreCopropriete nested foreign-key-hidden
            relation-fields (ttTitreCopropriete.iNumeroMandat, ttIntervenantsTitreCopropriete.iNumeroMandat,
                             ttTitreCopropriete.iNumeroCoproprietaire, ttIntervenantsTitreCopropriete.iNumeroCoproprietaire)      
       data-relation tacheCleRepartition for ttTacheCleRepartition, ttCleRepartition nested
           relation-fields(ttTacheCleRepartition.cTypeContrat, ttCleRepartition.cTypeContrat,
                           ttTacheCleRepartition.iNumeroContrat, ttCleRepartition.iNumeroContrat)
       data-relation detailCle for ttCleRepartition, ttDetailCleCopro nested
           relation-fields(ttCleRepartition.cTypeContrat, ttDetailCleCopro.cTypeContrat,
                           ttCleRepartition.iNumeroContrat, ttDetailCleCopro.iNumeroContrat,
                           ttCleRepartition.cCodeCle, ttDetailCleCopro.cCodeCle)
    .

    constructor public beMandatSyndic():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void rechercheMandatSyndic(pcFiltre as longchar, output dataset dsbeMandatSyndic):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter as handle  no-undo.
        define variable vhBuffer   as handle  no-undo.

        dataset dsbeMandatSyndic:empty-dataset().
        goCollection:set('cTypeContrat', {&TYPECONTRAT-mandat2Syndic}) no-error.
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroMandat'     , int64(vhBuffer::iNumeroMandat))      no-error.
                goCollection:set('iNumeroMandatDeb'  , int64(vhBuffer::iNumeroMandat1))     no-error.
                goCollection:set('iNumeroMandatFin'  , int64(vhBuffer::iNumeroMandat2))     no-error.
                goCollection:set('iNumeroMandant'    , integer(vhBuffer::iNumeroMandant))   no-error.
                goCollection:set('iNumeroMandantDeb' , integer(vhBuffer::iNumeroMandant1))  no-error.
                goCollection:set('iNumeroMandantFin' , integer(vhBuffer::iNumeroMandant2))  no-error.
                goCollection:set('iNumeroImmeuble'   , integer(vhBuffer::iNumeroImmeuble))  no-error.
                goCollection:set('iNumeroImmeubleDeb', integer(vhBuffer::iNumeroImmeuble1)) no-error.
                goCollection:set('iNumeroImmeubleFin', integer(vhBuffer::iNumeroImmeuble2)) no-error.
                goCollection:set('cNomMandant'       , string(vhBuffer::cNomMandant))       no-error.
                goCollection:set('cNatureMandat'     , string(vhBuffer::cNatureMandat))     no-error.
                goCollection:set('lActif'            , logical(vhBuffer::lActif))           no-error.
                goCollection:set('lInactif'          , logical(vhBuffer::lInactif))         no-error.
                goCollection:set('lProvisoire'       , logical(vhBuffer::lProvisoire))      no-error.
                goCollection:set('lEnCoursCreation'  , logical(vhBuffer::lEnCoursCreation)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        ghProc = outilHandle:connectMaGIModele("mandat/mandat.p").
        run getListeMandat in ghProc(goCollection, output table ttListeMandatSyndic).
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    //method public void readbeMandatSyndic(pcFiltre as longchar, output dataset dsbeMandatSyndic):
    method public void readbeMandatSyndic(pcFiltre as longchar, output pcBeMandatSyndic as longchar):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter         as handle     no-undo.
        define variable vhBuffer           as handle     no-undo.
        define variable vhDynamicDataSet   as handle     no-undo.
        define variable viNumeroContrat    as int64      no-undo.
        define variable vcVue              as character  no-undo.
        define variable vcTypeTrt          as character  no-undo.
        define variable vcNatureContrat    as character  no-undo.

        dataset dsbeMandatSyndic:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                    viNumeroContrat    = vhBuffer::iNumeroContrat no-error.
                    vcVue              = vhBuffer::cVue           no-error.
                    vcTypeTrt          = vhBuffer::cTypeTrt       no-error.
                    vcNatureContrat    = vhBuffer::cNatureContrat no-error.
            end.
        end.
        if vcTypeTrt = "AUTORISATION" then do:
            create dataset vhDynamicDataSet.
            vhDynamicDataSet:name = "dsbeAutorisation".
        end.
        case vcVue:
            when 'MANDAT'              then readMandat(vcTypeTrt, viNumeroContrat, vcNatureContrat).
            when 'MANDATOBJET'         then readObjet(vcTypeTrt, viNumeroContrat).
            when 'PERIODE'             then readPeriode(vcTypeTrt, viNumeroContrat, vcNatureContrat).
            when 'TACHESERVICE'        then readTacheService(vcTypeTrt, viNumeroContrat).    
            when 'TITRECOPROPRIETE'    then readTitreCopropriete(viNumeroContrat). 
            when 'TACHECLEREPARTITION' then readTacheCleRepartition(vcTypeTrt, viNumeroContrat, vhbuffer).
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        delete object vhttFilter.
        if vcTypeTrt = "AUTORISATION" then do:
            vhDynamicDataSet:set-buffers(ghttAutorisation, ghttError).
            vhDynamicDataSet:write-json("LONGCHAR", pcBeMandatSyndic, false, ?, false, false, false).
            // 5eme parametre = false pour conserver les valeurs d'initialisation dans le flux (au moins pour les tests)
        end.
        else dataset dsbeMandatSyndic:write-json("LONGCHAR", pcBeMandatSyndic, false, ?, false, false, false).
        // 5eme parametre = false pour conserver les valeurs d'initialisation dans le flux (au moins pour les tests)

        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeMandatSyndic(pcFiltre as longchar, input-output dataset dsbeMandatSyndic):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable vcVue           as character no-undo.
        define variable viNumeroContrat as int64     no-undo.        
        define variable vcTypeTrt       as character no-undo.
        define variable vcTypeDetail    as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                    vcVue           = vhBuffer::cVue           no-error.
                    viNumeroContrat = vhBuffer::iNumeroContrat no-error.                
                    vcTypeTrt       = vhBuffer::cTypeTrt       no-error.
                    vcTypeDetail    = vhBuffer::cTypeDetail    no-error.
            end.
        end.
        case vcVue:
            when 'MANDAT'              then updateMandat(viNumeroContrat).            
            when 'MANDATOBJET'         then updateObjet(vcTypeTrt).
            when 'TACHESERVICE'        then updateTacheService(no).            
            when 'PERIODE'             then updatePeriode().        
            when 'TACHECLEREPARTITION' then updateTacheCleRepartition(vcTypeTrt, vhBuffer).                
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        delete object vhttFilter no-error. // vhBuffer utilisé par updateTacheCleRepartition, updateTacheHonoraire...        
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void createbeMandatSyndic(input-output dataset dsbeMandatSyndic):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/mandat.p").
        run createMandat in ghProc(table ttCreationMandatSyndic).
        dataset dsbeMandatSyndic:empty-dataset().
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeTache(pcFiltre as longchar, output dataset dsbeMandatSyndic):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroContrat as integer   no-undo.
        define variable vcVue           as character no-undo.

        dataset dsbeMandatSyndic:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroContrat = vhBuffer::iNumeroContrat no-error.
                vcVue           = vhBuffer::cVue           no-error.
            end.
        end.
        delete object vhttFilter no-error.

        ghProc = outilHandle:connectMaGIModele("mandat/outilMandat.p").
        case vcVue:
            when 'TACHE' then run getListeTache in ghProc({&TYPECONTRAT-mandat2Syndic}, viNumeroContrat, output table ttListeTacheMandatSyndic).
//            when 'OBJET' then run getListeObjet in ghProc({&TYPECONTRAT-mandat2Syndic}, viNumeroContrat, output table ttListeObjetMandatSyndic).
            otherwise do:
                run getListeTache in ghProc({&TYPECONTRAT-mandat2Syndic}, viNumeroContrat, output table ttListeTacheMandatSyndic).
//                run getListeObjet in ghProc({&TYPECONTRAT-mandat2Syndic}, viNumeroContrat, output table ttListeObjetMandatSyndic).
            end.
        end case.
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    method private logical readMandat(pcTypeTrt as character, piNumeroContrat as int64, pcNatureContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        case pcTypeTrt:
            when "LISTECATEGORIECONTRAT" then do:
                ghProc = outilHandle:connectMaGIModele("mandat/listeCategorieContrat.p").
                run getListeCategorieContrat in ghProc({&TYPECONTRAT-mandat2Syndic}, output table ttCombo).
            end.
            when "LISTENUMEROCONTRATDISPONIBLE" then do:
                ghProc = outilHandle:connectMaGIModele("crud/ctrat_CRUD.p").
                run getListeNumeroMandatDispo in ghProc({&TYPECONTRAT-mandat2Syndic}, pcNatureContrat, output table ttListeNumeroContratDispo).
            end.  
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("mandat/mandat.p").
                if pcTypeTrt = "INITIALISATION"
                then run initMandat in ghProc({&TYPECONTRAT-mandat2Syndic}, pcNatureContrat, output table ttCreationMandatSyndic).
                else if pcTypeTrt = "CONTROLE"
                then run controleMandat in ghProc({&TYPECONTRAT-mandat2Syndic}, piNumeroContrat).
            end.
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readObjet(pcTypeTrt as character, piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/syndic/objetMandatSyndic.p").
        case pcTypeTrt:
            when "COMBO" then run initComboObjet in ghProc(output table ttCombo).
            when "AUTORISATION" then do:
                run initAutorisationObjet in ghProc(piNumeroContrat, output table-handle ghttAutorisation).
                run getErrors in ghProc(output table-handle ghttError).
            end.
            otherwise run getObjet in ghProc(pcTypeTrt, piNumeroContrat, output table ttObjetMandatSyndic).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateMandat(piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
 message "updateMandat "   .       
        ghProc = outilHandle:connectMaGIModele("mandat/mandat.p").
        run validationMandat in ghProc({&TYPECONTRAT-mandat2Syndic}, piNumeroContrat).
        dataset dsbeMandatSyndic:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateObjet(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/syndic/objetMandatSyndic.p").
        run setObjet in ghProc(pcTypeTrt, input-output table ttObjetMandatSyndic, table ttError).
        dataset dsbeMandatSyndic:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheService(pcTypeTrt as character, piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheService.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initService        in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Syndic}, output table ttTacheService, output table ttListeService).
            when "LISTE"          then run listeServiceMandat in ghProc(output table ttListeService).
            otherwise                  run getService         in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Syndic}, output table ttTacheService, output table ttListeService).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheService(plRegroupementTache as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheService.p").
        run setService in ghProc(table ttTacheService).
        if not plRegroupementTache then dataset dsbeMandatSyndic:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readPeriode(pcTypeTrt as character, piNumeroContrat as int64, pcNatureContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/syndic/periodeChargesCopro.p").
        case pcTypeTrt:
            when "CREATION" then run InitPeriodesCopro in ghProc(piNumeroContrat, output table ttPeriodeChargesCopro).
            when "LISTE" then run getPeriodesCopro in ghProc(piNumeroContrat, output table ttPeriodeChargesCopro).
            when "COMBO" then run getComboPeriodicite in ghProc(pcNatureContrat, output table ttCombo).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updatePeriode():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
message "**********updatePeriode ".
        ghProc = outilHandle:connectMaGIModele("mandat/syndic/periodeChargesCopro.p").
        run SetPeriodesCopro in ghProc(input-output table ttPeriodeChargesCopro, table ttError).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheCleRepartition(pcTypeTrt as character, piNumeroContrat as int64, phbuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vcNatureCle as character no-undo.

        ghProc = outilHandle:connectMaGIModele("tache/tacheCleRepartitionSyndic.p").
        if phBuffer:available then vcNatureCle = phBuffer::cNatureCle no-error.
        case pcTypeTrt:
            when "COMBO"           then run initComboCleRepartition in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Syndic}, output table ttCombo,  output table ttClemi).   
            when "AUTORISATION"    then do:
                run initAutorisation in ghProc(vcNatureCle, output table-handle ghttAutorisation).
                run getErrors        in ghProc(output table-handle ghttError).
            end.
            otherwise                   run getCleRepartition       in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Syndic}, output table ttTacheCleRepartition, output table ttCleRepartition, output table ttDetailCleCopro).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheCleRepartition(pcTypeTrt as character, phBuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vcNatureCle  as character no-undo.
        define variable vcCodeCle    as character no-undo.
        define variable vcFiltre     as character no-undo.

        if phBuffer:available then do:
            vcNatureCle  = phBuffer::cNatureCle no-error.
            vcCodeCle    = phBuffer::cCodeCle   no-error.
            vcFiltre     = phBuffer::cFiltre    no-error.
        end.
        ghProc = outilHandle:connectMaGIModele("tache/tacheCleRepartitionSyndic.p").
        case pcTypeTrt:
            when "CONTROLE"        then run verCleRepartition   in ghProc(table ttTacheCleRepartition, input-output table ttCleRepartition, input-output table ttDetailCleCopro).
            when "COMBOLIBELLECLE" then run initComboLibelleCle in ghProc(vcNatureCle, vcCodeCle, vcFiltre, input table ttCleRepartition, output table ttCombo).
            otherwise do :
                run setCleRepartition in ghProc(table ttTacheCleRepartition, table ttCleRepartition, table ttDetailCleCopro).
                dataset dsbeMandatSyndic:empty-dataset().                
            end.                
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTitreCopropriete(piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/syndic/titreCopropriete.p").
        run getTitreCopropriete in ghProc(piNumeroContrat, output table ttTitreCopropriete, output table ttIntervenantsTitreCopropriete).
        run getErrors in ghProc(output table ttError).
    end method.

    destructor public beMandatSyndic( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
 