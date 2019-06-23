/*------------------------------------------------------------------------
File        : beBail.cls
Syntax      :
Author(s)   : LGI/SPO - 2017/01/23
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

@program FILE(name="beBail.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beBail", URI="/beBail", schemaName="dsbeBail", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class bail.beBail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/combo.i}
    {application/include/error.i}
    {bail/include/bail.i}
    {bail/include/indiceRevisionLoyer.i}
    {tache/include/tacheAttestationLocative.i}
    {tache/include/tacheDepotGarantieBail.i}
    {tache/include/tacheDossierLocataire.i}
    {tache/include/tacheRevisionLoyer.i}
    {tache/include/tacheGarantieLoyer.i}
    {tache/include/tacheTvaBail.i}
    {tache/include/tacheTvaServiceAnnexe.i}
    {tache/include/tacheVacanceLocative.i}
    {tache/include/tacheProtectionJuridique.i}
    {tache/include/tacheRisqueLocatif.i}

    define dataset dsbeBail
        for ttBail, ttTacheDepotGarantieBail, ttTacheDossierLocataire, ttTacheAttestationLocative
          , ttTacheRevisionLoyer, ttHistoriqueRevisionLoyer, ttIndiceRevisionLoyer
          , ttTacheTvaBail, ttTacheTvaServiceAnnexe, ttTacheVacanceLocative, ttBaremeVacanceLocative
          , ttTacheProtectionJuridique, ttCombo, ttError
          , ttTacheGarantieLoyer, ttEchangesGLO, ttEchangesBail
          ,ttTacheRisqueLocatif, ttEchangesGRL
        data-relation HistoRevision for ttTacheRevisionLoyer, ttHistoriqueRevisionLoyer nested foreign-key-hidden
            relation-fields(ttTacheRevisionLoyer.cTypeContrat,   ttHistoriqueRevisionLoyer.cTypeContrat,
                            ttTacheRevisionLoyer.iNumeroContrat, ttHistoriqueRevisionLoyer.iNumeroContrat)
        data-relation BaremeVacance for ttTacheVacanceLocative, ttBaremeVacanceLocative nested
            relation-fields(ttTacheVacanceLocative.iNumeroVacanceLocative, ttBaremeVacanceLocative.iNumeroContrat,
                            ttTacheVacanceLocative.cTypeBaremeVacance,     ttBaremeVacanceLocative.cTypeBareme)
    .

    constructor public beBail():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeBail(pcFiltre as longchar, output dataset dsbeBail):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc           as handle    no-undo.
        define variable vhttFilter       as handle    no-undo.
        define variable vhBuffer         as handle    no-undo.
        define variable viNumeroContrat  as int64     no-undo.
        define variable vcTypeContrat    as character no-undo.
        define variable vcVue            as character no-undo.
        define variable vcTypeTrt        as character no-undo.
        define variable viCodeRevision   as integer   no-undo.
        define variable viAnneeRevision  as integer   no-undo.
        define variable viNumeroVacance  as integer   no-undo.
        define variable viNumeroGarantie as integer   no-undo.

        if pcFiltre > "" then do:
            pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
            create temp-table vhttFilter.
            vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
            if not error-status:error then do:
                vhBuffer = vhttFilter:default-buffer-handle.
                vhBuffer:find-first() no-error.
                if vhBuffer:available then do:
                    vcTypeContrat   = vhBuffer::cTypeContrat   no-error.
                    viNumeroContrat = vhBuffer::iNumeroContrat no-error.
                    vcVue           = vhBuffer::cVue           no-error.
                    vcTypeTrt       = vhBuffer::cTypeTrt       no-error.
                    viCodeRevision  = vhBuffer::iCodeRevision  no-error.
                    viAnneeRevision = vhBuffer::iAnneeRevision no-error.
                    viNumeroVacance = vhBuffer::iNumeroVacance no-error.
                    viNumeroGarantie = vhBuffer::iNumeroGarantie no-error.      // no de garantie (GLo, GRL, PNO etc...)
                end.
            end.
        end.
        case vcVue:
            when 'TACHEDEPOTGARANTIEBAIL'   then readTacheDepotGarantieBail(vcTypeTrt, viNumeroContrat, vcTypeContrat).
            when 'TACHEDOSSIERLOCATAIRE'    then readTacheDossierLocataire(vcTypeTrt, viNumeroContrat, vcTypeContrat).
            when 'TACHEATTESTATIONLOCATIVE' then readTacheAttestationLocative(vcTypeTrt, viNumeroContrat, vcTypeContrat).
            when 'TACHEREVISIONLOYER'       then readTacheRevisionLoyer(vcTypeTrt, vhBuffer).
            when 'INDICEREVISIONLOYER'      then readIndiceRevisionLoyer(vcTypeTrt, viCodeRevision, viAnneeRevision).
            when 'TACHETVABAIL'             then readTacheTvaBail(vcTypeTrt, viNumeroContrat, vcTypeContrat).
            when 'TACHETVASERVICEANNEXE'    then readTacheTvaServiceAnnexe(vcTypeTrt, viNumeroContrat, vcTypeContrat).
            when 'TACHEVACANCELOCATIVE'     then readTacheVacanceLocative(vcTypeTrt, viNumeroContrat, vcTypeContrat, viNumeroVacance).
            when 'TACHEPROTECTIONJURIDIQUE' then readTacheProtectionJuridique(vcTypeTrt, viNumeroContrat, vcTypeContrat).
            when 'TACHEGARANTIELOYER'       then readTacheGarantieLoyer(vcTypeTrt, viNumeroContrat,vcTypeContrat,viNumeroGarantie).
            when 'TACHERISQUELOCATIF'       then readTacheRisqueLocatif(vcTypeTrt, viNumeroContrat,vcTypeContrat,viNumeroGarantie).
            when 'CATEGORIEBAIL'            then readCategorieBail(viNumeroContrat,vcTypeContrat).
            otherwise do:
                vhProc = outilHandle:connectMaGIModele("bail/bail.p").
                run readBail  in vhProc(vcTypeContrat, viNumeroContrat, output table ttBail).
                run getErrors in vhProc(output table ttError).
            end.
        end case.
        delete object vhttFilter.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeBail(pcFiltre as longchar, input-output dataset dsbeBail):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc          as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable vcVue           as character no-undo.
        define variable vcTypeTrt       as character no-undo.
        define variable vcTypeDetail    as character no-undo.

        if pcFiltre > "" then do:
            pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
            create temp-table vhttFilter.
            vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
            if not error-status:error then do:
                vhBuffer = vhttFilter:default-buffer-handle.
                vhBuffer:find-first() no-error.
                if vhBuffer:available then do:
                    vcVue        = vhBuffer::cVue        no-error.
                    vcTypeTrt    = vhBuffer::cTypeTrt    no-error.
                    vcTypeDetail = vhBuffer::cTypeDetail no-error.
                end.
            end.
            delete object vhttFilter.
        end.

        case vcVue:
            when 'TACHEDEPOTGARANTIEBAIL'   then updateTacheDepotGarantieBail(vcTypeTrt, vcTypeDetail).
            when 'TACHEDOSSIERLOCATAIRE'    then updateTacheDossierLocataire().
            when 'TACHEATTESTATIONLOCATIVE' then updateTacheAttestationLocative().
            when 'TACHEREVISIONLOYER'       then updateTacheRevisionLoyer(vcTypeTrt, vcTypeDetail).
            when 'INDICEREVISIONLOYER'      then updateIndiceRevisionLoyer().
            when 'TACHETVABAIL'             then updateTacheTvaBail().
            when 'TACHETVASERVICEANNEXE'    then updateTacheTvaServiceAnnexe().
            when 'TACHEVACANCELOCATIVE'     then updateTacheVacanceLocative().
            when 'TACHEPROTECTIONJURIDIQUE' then updateTacheProtectionJuridique().
            when 'TACHEGARANTIELOYER'       then updateTacheGarantieLoyer().
            when 'TACHERISQUELOCATIF'       then updateTacheRisqueLocatif().
            otherwise do:
                vhProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in vhProc(output table ttError).
            end.
        end case.
        {outils/include/tryCatch.i}
    end method.

    method private logical readTacheDepotGarantieBail(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheDepotGarantieBail.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initCreationDepotGarantieBail in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheDepotGarantieBail).
            when "INITRELOC"      then run creationAutoDepotGarantieBail in vhProc(piNumeroContrat, {&TYPECONTRAT-bail}, table ttError, output table ttTacheDepotGarantieBail).
            when "COMBO"          then run initComboDepotGarantieBail    in vhProc(output table ttCombo append).
            otherwise                  run getDepotGarantieBail          in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheDepotGarantieBail).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheDossierLocataire(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheDossierLocataire.p").
        case pcTypeTrt:
            when "COMBO" then run initComboTacheDossierLocataire in vhProc(output table ttCombo).
            otherwise         run getTacheDossierLocataire in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheDossierLocataire).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheAttestationLocative(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheAttestationLocative.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTacheAttestationLocative in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheAttestationLocative).
            when "COMBO"          then run initComboTacheAttestationLocative in vhProc(piNumeroContrat, pcTypeContrat, output table ttCombo).
            otherwise                  run getTacheAttestationLocative in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheAttestationLocative).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheRevisionLoyer(pcTypeTrt as character, phbuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc                    as handle    no-undo.
        define variable viNumeroContrat           as int64     no-undo.
        define variable vcTypeContrat             as character no-undo.
        define variable vcCodeTypeIndiceCourant   as character no-undo.
        define variable vlRevisionConventionnelle as logical   no-undo.
        define variable vcCodeNatureTraitement    as character no-undo.
        define variable vcCodeTraitement          as character no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheRevisionLoyer.p").
        if phBuffer:available then do:
            viNumeroContrat           = phBuffer::iNumeroContrat           no-error.
            vcTypeContrat             = phBuffer::cTypeContrat             no-error.
            vcCodeTypeIndiceCourant   = phBuffer::cCodeTypeIndiceCourant   no-error.
            vlRevisionConventionnelle = phBuffer::lRevisionConventionnelle no-error.
            vcCodeNatureTraitement    = phBuffer::cCodeNatureTraitement    no-error.
            vcCodeTraitement          = phBuffer::cCodeTraitement          no-error.
        end.

        case pcTypeTrt:
            when "HISTO"           then run historiqueTacheRevisionLoyer in vhProc(viNumeroContrat, vcTypeContrat, output table ttHistoriqueRevisionLoyer).
            when "INITIALISATION"  then run initTacheRevisionLoyer       in vhProc(viNumeroContrat, vcTypeContrat, output table ttTacheRevisionLoyer).
            when "COMBO"           then run initComboTacheRevisionLoyer  in vhProc(output table ttCombo).
            when "COMBOPARTYPEIND" then run comboParTypeIndiceRevision   in vhProc(vcCodeTypeIndiceCourant, output table ttCombo).
            when "COMBOPARIDXCONV" then run comboParTypeIndexConvention  in vhProc(viNumeroContrat, vcTypeContrat, vlRevisionConventionnelle, output table ttCombo).
            when "COMBOPARNATTRMT" then run comboParTypeNatureTraitmt    in vhProc(vcCodeNatureTraitement, output table ttCombo).
            when "COMBOPARTRAIMT"  then run comboParTypeTraitement       in vhProc(vcCodeTraitement, output table ttCombo).
            when "COMBOMODECALC"   then run comboModeCalcul              in vhProc(viNumeroContrat, vcTypeContrat, output table ttCombo).
            otherwise                   run getTacheRevisionLoyer        in vhProc(viNumeroContrat, vcTypeContrat, output table ttTacheRevisionLoyer, output table ttHistoriqueRevisionLoyer).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheGarantieLoyer(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character, piNumeroGarantie as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheGarantieLoyer.p").
        case pcTypeTrt:
            when "INITIALISATION"  then run initTacheGarantieLoyer       in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheGarantieLoyer).
            when "COMBOS"          then run CombosTacheGarantieLoyer     in vhProc(piNumeroContrat, pcTypeContrat, piNumeroGarantie, output table ttCombo).
            when "DATEAPPLICATION" then run DateApplicationGarantieLoyer in vhProc(piNumeroContrat, pcTypeContrat, output table ttEchangesGLO).
            otherwise                   run getTacheGarantieLoyer        in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheGarantieLoyer).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheRisqueLocatif(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character, piNumeroGarantie as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.
        vhProc = outilHandle:connectMaGIModele("tache/tacheRisqueLocatif.p").
        case pcTypeTrt:
            when "INITIALISATION"   then run initTacheRisqueLocatif       in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheRisqueLocatif).
            when "COMBOS"           then run combosTacheRisqueLocatif     in vhProc(piNumeroContrat, pcTypeContrat, piNumeroGarantie, output table ttCombo).
            when "DATEAPPLICATION"  then run dateApplicationRisqueLocatif in vhProc(piNumeroContrat, pcTypeContrat, output table ttEchangesGRL).
            otherwise                    run getTacheRisqueLocatif        in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheRisqueLocatif).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readCategorieBail(piNumeroContrat as int64, pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("bail/bail.p").
        run getCategorieBail in vhProc(piNumeroContrat, pcTypeContrat, output table ttEchangesBail).
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readIndiceRevisionLoyer(pcTypeTrt as character, piCodeRevision as integer, piAnneeRevision as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("bail/quittancement/indiceRevision.p").
        case pcTypeTrt:
            when "INDICEDEFAUT" then run defautIndiceRevisionLoyer    in vhProc(output table ttIndiceRevisionLoyer).
            when "INITINDICE"   then run initIndiceRevisionLoyer      in vhProc(piCodeRevision, piAnneeRevision, output table ttIndiceRevisionLoyer).
            when "COMBOINDICE"  then run initComboIndiceRevisionLoyer in vhProc(piCodeRevision, piAnneeRevision, output table ttCombo).
            otherwise                run getIndiceRevisionLoyer       in vhProc(piCodeRevision, piAnneeRevision, output table ttIndiceRevisionLoyer).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheTvaBail(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheTvaBail.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTvaBail      in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheTvaBail).
            when "COMBO"          then run initComboTvaBail in vhProc(piNumeroContrat, pcTypeContrat, output table ttCombo).
            otherwise                  run getTvaBail       in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheTvaBail).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheTvaServiceAnnexe(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheTvaServiceAnnexe.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTvaServiceAnnexe in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheTvaServiceAnnexe).
            when "COMBO"          then run initComboTvaServiceAnnexe in vhProc(piNumeroContrat, pcTypeContrat, output table ttCombo).
            otherwise                  run getTvaServiceAnnexe in vhProc(piNumeroContrat, pcTypeContrat, output table ttTacheTvaServiceAnnexe).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheVacanceLocative(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character, piNumeroVacance as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheVacanceLocative.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initVacanceLocative      in vhProc(piNumeroContrat, pcTypeContrat, piNumeroVacance, output table ttTacheVacanceLocative, output table ttBaremeVacanceLocative).
            when "COMBO"          then run initComboVacanceLocative in vhProc(piNumeroContrat, pcTypeContrat, output table ttCombo).
            otherwise                  run getVacanceLocative       in vhProc(piNumeroContrat, pcTypeContrat, piNumeroVacance, output table ttTacheVacanceLocative, output table ttBaremeVacanceLocative).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readTacheProtectionJuridique(pcTypeTrt as character, piNumeroContrat as int64, pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle  no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheProtectionJuridique.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initProtectionJuridiqueBail in vhProc(pcTypeContrat, piNumeroContrat, output table ttTacheProtectionJuridique).
            otherwise                  run getProtectionJuridiqueBail  in vhProc(pcTypeContrat, piNumeroContrat, output table ttTacheProtectionJuridique).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheDepotGarantieBail(pcTypeTrt as character, pcTypeDetail as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheDepotGarantieBail.p").
        case pcTypeTrt:
            when "CONTROLE" then run controleDepotGarantieBail in vhProc(pcTypeDetail, table ttTacheDepotGarantieBail).
            otherwise            run setTacheDepotGarantieBail in vhProc(table ttTacheDepotGarantieBail, table ttError).
        end case.
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheDossierLocataire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheDossierLocataire.p").
        run setTacheDossierLocataire in vhProc(table ttTacheDossierLocataire).
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheAttestationLocative():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheAttestationLocative.p").
        run setTacheAttestationLocative in vhProc(table ttTacheAttestationLocative).
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheRevisionLoyer(pcTypeTrt as character, pcTypeDetail as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheRevisionLoyer.p").
        case pcTypeTrt:
            when "CONTROLE"       then run controleTacheRevisionLoyer  in vhProc(table ttTacheRevisionLoyer, table ttError).
            when "CONTROLEDETAIL" then run controleDetailTacheRevision in vhProc(table ttHistoriqueRevisionLoyer).
            when "SETDETAIL"      then run setDetailTraitements        in vhProc(pcTypeDetail, table ttHistoriqueRevisionLoyer).
            otherwise                  run setTacheRevisionLoyer       in vhProc(table ttTacheRevisionLoyer, table ttHistoriqueRevisionLoyer, table ttError).
        end case.
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateIndiceRevisionLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("bail/quittancement/indiceRevision.p").
        run setIndiceRevisionLoyer in vhProc(table ttIndiceRevisionLoyer, table ttCombo, table ttError).   // besoin ttCombo pour savoir quelle période on modifie
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheGarantieLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheGarantieLoyer.p").
        run setTacheGarantieLoyer in vhProc(table ttTacheGarantieLoyer).
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheRisqueLocatif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheRisqueLocatif.p").
        run setTacheRisqueLocatif in vhProc(table ttTacheRisqueLocatif).
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheTvaBail():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheTvaBail.p").
        run setTvaBail in vhProc(table ttTacheTvaBail).
        dataset dsbeBail:empty-dataset().
        run getErrors  in vhProc(output table ttError).
    end method.

    method private logical updateTacheTvaServiceAnnexe():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheTvaServiceAnnexe.p").
        run setTvaServiceAnnexe in vhProc(table ttTacheTvaServiceAnnexe).
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheVacanceLocative():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheVacanceLocative.p").
        run setVacanceLocative in vhProc(table ttTacheVacanceLocative, table ttBaremeVacanceLocative, table ttError).
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateTacheProtectionJuridique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("tache/tacheProtectionJuridique.p").
        run setProtectionJuridiqueBail in vhProc(table ttTacheProtectionJuridique).
        dataset dsbeBail:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    destructor public beBail( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
