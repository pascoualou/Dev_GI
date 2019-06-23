/*------------------------------------------------------------------------
File        : beAssuranceImmeuble.cls
Purpose     :
Author(s)   : GGA - 2017/08/10
Notes       :
derniere revue: 2018/04/11 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

@program FILE(name="beAssuranceImmeuble.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beAssuranceImmeuble", URI="/beAssuranceImmeuble", schemaName="dsbeAssuranceImmeuble", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class tache.beAssuranceImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    define variable ghProc as handle    no-undo.  // plutôt que définir dans chacune des procédures.
    {application/include/error.i}
    {application/include/combo.i}
    {tache/include/tacheAssuranceImmeuble.i}
    {note/include/notes.i}
    {mandat/include/roleMandat.i &nomtable=ttRoleContractant}
    {mandat/include/roleMandat.i &nomtable=ttRoleCourtier}
    {mandat/include/listeTache.i &nomtable=ttListeTacheContrat}
    {mandat/include/listeObjet.i &nomtable=ttlisteObjetContrat}

    define dataset dsbeAssuranceImmeuble for ttObjetAssImm, 
                                             ttGarantieAssImm, ttTypeGarantieAssImm, ttAttestationAssImm, ttBatimentAssImm, 
                                             ttNotes,
                                             ttRoleContractant, ttRoleCourtier, 
                                             ttListeTacheContrat, ttlisteObjetContrat, 
                                             ttCombo, ttError
    data-relation NumeroContrat for ttObjetAssImm, ttRoleContractant nested             // foreign-key-hidden
    relation-fields (ttObjetAssImm.cTypeContrat, ttRoleContractant.cTypeContrat,
                     ttObjetAssImm.iNumeroContrat, ttRoleContractant.iNumeroContrat)
    data-relation NumeroContrat for ttObjetAssImm, ttRoleCourtier nested                // foreign-key-hidden
    relation-fields (ttObjetAssImm.cTypeContrat, ttRoleCourtier.cTypeContrat,
                     ttObjetAssImm.iNumeroContrat, ttRoleCourtier.iNumeroContrat)
    data-relation NumeroContrat for ttObjetAssImm, ttBatimentAssImm nested              // foreign-key-hidden
    relation-fields (ttObjetAssImm.cTypeContrat, ttBatimentAssImm.cTypeContrat,
                     ttObjetAssImm.iNumeroContrat, ttBatimentAssImm.iNumeroContrat)
    .

    constructor public beAssuranceImmeuble():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeAssuranceImmeubleMandat(pcFiltre as longchar, output dataset dsbeAssuranceImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroMandat  as int64     no-undo.

        dataset dsbeAssuranceImmeuble:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available
            then viNumeroMandat = vhBuffer::iNumeroContrat no-error.
        end.
        delete object vhttFilter no-error.

blocLect:
        do:
            ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/objetAssImm.p").
            run getListeAssuranceImmeubleMandat in ghProc(viNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-assuranceGerance}, output table ttObjetAssImm).
            run getErrors in ghProc(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocLect.

            ghProc = outilHandle:connectMaGIModele("mandat/contractantContrat.p").
            for each ttObjetAssImm:
                run getRoleContractant in ghProc(ttObjetAssImm.iNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttRoleContractant append).
                run getErrors in ghProc(output table ttError).
                if can-find(first ttError where ttError.iType >= {&error}) then leave blocLect.
            end.
        end.
        {outils/include/tryCatch.i}

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeAssuranceImmeuble(pcFiltre as longchar, output dataset dsbeAssuranceImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroContrat as int64     no-undo.
        define variable vcVue           as character no-undo.
        define variable vcTypeTrt       as character no-undo.

        dataset dsbeAssuranceImmeuble:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroContrat = vhBuffer::iNumeroContrat no-error.
                vcVue           = vhBuffer::cVue           no-error.
                vcTypeTrt       = vhBuffer::cTypeTrt       no-error.
            end.
        end.
        delete object vhttFilter no-error.

        case vcVue:
            when 'CONTRAT' then do:
                readRoleContractant(vcTypeTrt, viNumeroContrat).  
                if not can-find(first ttError where ttError.iType >= {&error}) 
                then readObjet(vcTypeTrt, viNumeroContrat). 
                if not can-find(first ttError where ttError.iType >= {&error}) 
                then readRoleCourtier(vcTypeTrt, viNumeroContrat).      
                if not can-find(first ttError where ttError.iType >= {&error}) 
                then readTacheAffectBatiment(viNumeroContrat).     
            end.
            when 'NOTES'            then readNotes(viNumeroContrat).
            when 'TACHEATTESTATION' then readTacheAttestation(viNumeroContrat).
            when 'TACHEGARANTIE'    then readTacheGarantie(vcTypeTrt, viNumeroContrat).
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        {outils/include/tryCatch.i}
    end method.

    method private logical readRoleContractant(pcTypeTrt as character, piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/contractantContrat.p").
        case pcTypeTrt:
            when "COMBO" then run initComboContractant in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttCombo).   
            otherwise         run getRoleContractant   in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttRoleContractant).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readRoleCourtier(pcTypeTrt as character, piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/roleAnnexeContrat.p").
        case pcTypeTrt:
            when "COMBO" then run initComboRoleAnnexe in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttCombo append).   
            otherwise         run getRoleAnnexe in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttRoleCourtier).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readObjet(pcTypeTrt as character, piNumeroContrat as int64): 
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/objetAssImm.p").
        case pcTypeTrt:
            when "COMBO" then run initComboObjet in ghProc({&TYPECONTRAT-assuranceGerance}, output table ttCombo append).   
            otherwise         run getObjet       in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttObjetAssImm).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readNotes(piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/commentaireContrat.p").
        run getNotesContrat in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttNotes).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheAffectBatiment(piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/tacheAssImmBatiment.p").
        run getBatiment in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttBatimentAssImm).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheAttestation(piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/tacheAssImmAttestation.p").
        run getAttestation  in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttAttestationAssImm).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheGarantie(pcTypeTrt as character, piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/tacheAssImmGarantie.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initGarantie in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttGarantieAssImm, output table ttTypeGarantieAssImm).
            otherwise                  run getGarantie  in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttGarantieAssImm, output table ttTypeGarantieAssImm).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeAssuranceImmeuble(pcFiltre as longchar, input-output dataset dsbeAssuranceImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroContrat as int64     no-undo.
        define variable vcVue           as character no-undo.
        define variable vcTypeTrt       as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroContrat = vhBuffer::iNumeroContrat no-error.
                vcVue           = vhBuffer::cVue           no-error.
                vcTypeTrt       = vhBuffer::cTypeTrt       no-error.
            end.
        end.
        delete object vhttFilter no-error.
        case vcVue:
            when 'CONTRAT' then do:
                updateObjet(vcTypeTrt).
                if not can-find(first ttError where ttError.iType >= {&error}) 
                then do:
                    updateRoleContractant().
                    if not can-find(first ttError where ttError.iType >= {&error})                 
                    then do:
                        updateRoleCourtier().
                        if not can-find(first ttError where ttError.iType >= {&error}) 
                        then do:
                            updateTacheAffectBatiment(viNumeroContrat). 
                        end.
                    end.
                end.
            end.
            when 'NOTES'            then updateNotes(viNumeroContrat).
            when 'TACHEATTESTATION' then updateTacheAttestation().
            when 'TACHEGARANTIE'    then updateTacheGarantie().
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
            end.
        end case.
        dataset dsbeAssuranceImmeuble:empty-dataset().
        run getErrors in ghProc(output table ttError).    //meme si on a deja lu la table ttError au niveau traitement contrat, on relit la table suite empty-ataset
        {outils/include/tryCatch.i}
    end method.

    method private logical updateRoleContractant():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/contractantContrat.p").
        run setRoleContractant in ghProc(table ttRoleContractant).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateObjet(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/objetAssImm.p").
        run setObjet in ghProc(pcTypeTrt, table ttObjetAssImm).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateRoleCourtier():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/roleAnnexeContrat.p").
        run setRoleAnnexe in ghProc(table ttRoleCourtier).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateNotes(piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/commentaireContrat.p").
        run setNotesContrat in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, table ttNotes).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheAffectBatiment(piNumeroContrat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/tacheAssImmBatiment.p").
        run setBatiment in ghProc(piNumeroContrat, {&TYPECONTRAT-assuranceGerance}, table ttBatimentAssImm).
    end method.
    
    method private logical updateTacheAttestation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/tacheAssImmAttestation.p").
        run setAttestation in ghProc(table ttAttestationAssImm).
        run getErrors in ghProc(output table ttError).
    end method.
    
    method private logical updateTacheGarantie():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/tacheAssImmGarantie.p").
        run setGarantie in ghProc(table ttGarantieAssImm, table ttTypeGarantieAssImm).
        run getErrors in ghProc(output table ttError).
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeAssuranceImmeuble(pcFiltre as longchar, input-output dataset dsbeAssuranceImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: creation contrat assurance immeuble
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter               as handle    no-undo.
        define variable vhBuffer                 as handle    no-undo.
        define variable vcTypeContratPrincipal   as character no-undo.
        define variable viNumeroContratPrincipal as int64     no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeContratPrincipal   = vhBuffer::cTypeContratPrincipal no-error.
                viNumeroContratPrincipal = vhBuffer::iNumeroContratPrincipal no-error.
            end.
        end.
        delete object vhttFilter no-error.
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/assuranceImmeuble.p").
        run CreateAssurance in ghProc(vcTypeContratPrincipal, viNumeroContratPrincipal, table ttRoleContractant, table ttObjetAssImm, table ttRoleCourtier, table ttBatimentAssImm).
        dataset dsbeAssuranceImmeuble:empty-dataset().        
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeAssuranceImmeuble(input-output dataset dsbeAssuranceImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: suppression assurance
        Notes:
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/assuranceImmeuble/assuranceImmeuble.p").
        run delAssurance in ghProc(table ttObjetAssImm, table ttError).
        dataset dsbeAssuranceImmeuble:empty-dataset().
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeTacheObjet(pcFiltre as longchar, output dataset dsbeAssuranceImmeuble):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroContrat as int64     no-undo.
        define variable vcVue           as character no-undo.

        dataset dsbeAssuranceImmeuble:empty-dataset().
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
            when 'TACHE' then run getListeTache in ghProc(viNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttListeTacheContrat).
            when 'OBJET' then run getListeObjet in ghProc(viNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttListeObjetContrat).
            otherwise do:
                run getListeTache in ghProc(viNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttListeTacheContrat).
                run getListeObjet in ghProc(viNumeroContrat, {&TYPECONTRAT-assuranceGerance}, output table ttListeObjetContrat).
            end.
        end case.
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beAssuranceImmeuble ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
