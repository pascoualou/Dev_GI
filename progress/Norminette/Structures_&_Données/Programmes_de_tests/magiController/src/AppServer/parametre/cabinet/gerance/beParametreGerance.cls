/*------------------------------------------------------------------------
File        : beParametreGerance.cls
Purpose     :
Author(s)   : GGA - 2017/04/19
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beParametreGerance.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beParametreGerance", URI="/beParametreGerance", schemaName="dsbeParametreGerance", schemaFile="").

using OpenEdge.BusinessLogic.BusinessEntity.
using outils.outilHandle.
using oerealm.beMagiToken.
using outils.logHandler.

block-level on error undo, throw.

class parametre.cabinet.gerance.beParametreGerance inherits BusinessEntity:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property mLogger     as class logHandler no-undo private get. private set.
    define public  property selfDestroy as logical no-undo initial true private get. public set.

    {parametre/cabinet/gerance/include/paramChargeLocative.i}
    {parametre/cabinet/gerance/include/paramCommentaire.i}
    {parametre/cabinet/gerance/include/paramCommercial.i}
    {parametre/cabinet/gerance/include/paramDossierMandat.i}
    {parametre/cabinet/gerance/include/paramGeneraux.i}
    {parametre/cabinet/gerance/include/paramCrg.i}
    {parametre/cabinet/gerance/include/paramCrg123.i}
    {parametre/cabinet/gerance/include/paramTexteCrg.i}
    {parametre/cabinet/gerance/include/paramCrl.i}
    {parametre/cabinet/gerance/include/paramDas2.i}
    {parametre/cabinet/gerance/include/paramDepotGarantie.i}
    {parametre/cabinet/gerance/include/paramHonoraireGestion.i}
    {parametre/cabinet/gerance/include/paramIrf.i}
    {parametre/cabinet/gerance/include/paramIsf.i}
    {parametre/cabinet/gerance/include/paramTva.i}
    {parametre/cabinet/gerance/include/tarifCirconscription.i}
    {application/include/error.i}
    {application/include/combo.i}

    define buffer vbttError for ttError.
    define buffer vbttCombo for ttCombo.

    define dataset dsbeParametreGerance
        for ttParamChargeLocative, ttParamCommentaire, ttParamCommercial,
            ttParamDossierMandat, ttParamListeDossierMandat, ttParamGeneraux,
            ttParamCrg, ttParamCrgSelectionDocument, ttParamCrgListeCrgSimplifie, ttParamCrgSuiviTrt,
            ttScenarioCrg123, ttRubriquesQuitScenarioCrg123, ttRubriquesAnaScenarioCrg123, ttFamillesRubriquesQuitt, ttRubriquesQuitt,
            ttParamTexteCrg, ttParamCrl, ttParamDas2,
            ttParamDepotGarantie, ttParamHonoraireGestion, ttParamIrf,
            ttParamIsf, ttParamTva, ttError, ttCombo
    .
    define dataset dsbeParametrageGeranceMandat 
        for ttAnneeTarifCirconscription, ttTarifCirconscription, vbttError, vbttCombo
        data-relation tarifCirconscription for ttAnneeTarifCirconscription, ttTarifCirconscription nested foreign-key-hidden
            relation-fields (ttAnneeTarifCirconscription.iAnnee    , ttTarifCirconscription.iAnnee)
    .
    
    constructor public beParametreGerance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super (dataset dsbeParametreGerance:handle).
        beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
        mLogger = beMagiToken:mLogger.

    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeDefautMandatGestion(pcFiltre as longchar, output dataset dsbeParametreGerance):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.
        define variable vcTypeTrt  as character no-undo.

        dataset dsbeParametreGerance:empty-dataset().
        if pcFiltre > "" then do:
            create temp-table vhttFilter. 
            vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
            if not error-status:error then do:
                vhBuffer = vhttFilter:default-buffer-handle.
                vhBuffer:find-first() no-error.
                if vhBuffer:available then do:
                    vcVue     = vhBuffer::cVue     no-error.
                    vcTypeTrt = vhBuffer::cTypeTrt no-error.
                end.
            end.
            delete object vhttFilter.
        end.
        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/defautMandatGerance.p").
        if vcTypeTrt = "COMBO"
        then case vcVue:
            when 'CHARGELOCATIVE'   then run getCombo in vhProc("CHARGELOCATIVE",   output table ttCombo).
            when 'COMMENTAIRE'      then .
            when 'COMMERCIAL'       then .
            when 'DOSSIERMANDAT'    then .
            when 'GENERAUX'         then run getCombo in vhProc("GENERAUX",         output table ttCombo).
            when 'CRG'              then run getCombo in vhProc("CRG",              output table ttCombo).
            when 'CRL'              then run getCombo in vhProc("CRL",              output table ttCombo).
            when 'DAS2'             then run getCombo in vhProc("DAS2",             output table ttCombo).
            when 'DEPOTGARANTIE'    then run getCombo in vhProc("DEPOTGARANTIE",    output table ttCombo).
            when 'HONORAIREGESTION' then run getCombo in vhProc("HONORAIREGESTION", output table ttCombo).
            when 'IRF'              then run getCombo in vhProc("IRF",              output table ttCombo).
            when 'ISF'              then run getCombo in vhProc("ISF",              output table ttCombo).
            when 'TVA'              then run getCombo in vhProc("TVA",              output table ttCombo).
            otherwise do:
                run getCombo in vhProc("CHARGELOCATIVE",   output table ttCombo).
                run getCombo in vhProc("GENERAUX",         output table ttCombo).
                run getCombo in vhProc("CRG",              output table ttCombo).
                run getCombo in vhProc("CRL",              output table ttCombo).
                run getCombo in vhProc("DAS2",             output table ttCombo).
                run getCombo in vhProc("DEPOTGARANTIE",    output table ttCombo).
                run getCombo in vhProc("HONORAIREGESTION", output table ttCombo).
                run getCombo in vhProc("IRF",              output table ttCombo).
                run getCombo in vhProc("ISF",              output table ttCombo).
                run getCombo in vhProc("TVA",              output table ttCombo).
            end.
        end case.
        else case vcVue:
            when 'CHARGELOCATIVE'   then run getParamChargeLocative   in vhProc(output table ttParamChargeLocative  ).
            when 'COMMENTAIRE'      then run getParamCommentaire      in vhProc(output table ttParamCommentaire     ).
            when 'COMMERCIAL'       then run getParamCommercial       in vhProc(output table ttParamCommercial      ).
            when 'DOSSIERMANDAT'    then run getParamDossierMandat    in vhProc(output table ttParamDossierMandat, output table ttParamListeDossierMandat).
            when 'GENERAUX'         then run getParamGeneraux         in vhProc(output table ttParamGeneraux        ).
            when 'CRG'              then run getParamCrg              in vhProc(output table ttParamCrg             ).
            when 'CRL'              then run getParamCrl              in vhProc(output table ttParamCrl             ).
            when 'DAS2'             then run getParamDas2             in vhProc(output table ttParamDas2            ).
            when 'DEPOTGARANTIE'    then run getParamDepotGarantie    in vhProc(output table ttParamDepotGarantie   ).
            when 'HONORAIREGESTION' then run getParamHonoraireGestion in vhProc(output table ttParamHonoraireGestion).
            when 'IRF'              then run getParamIrf              in vhProc(output table ttParamIrf             ).
            when 'ISF'              then run getParamIsf              in vhProc(output table ttParamIsf             ).
            when 'TVA'              then run getParamTva              in vhProc(output table ttParamTva             ).
            otherwise do:
                run getParamChargeLocative   in vhProc(output table ttParamChargeLocative  ).
                run getParamCommentaire      in vhProc(output table ttParamCommentaire     ).
                run getParamCommercial       in vhProc(output table ttParamCommercial      ).
                run getParamDossierMandat    in vhProc(output table ttParamDossierMandat, output table ttParamListeDossierMandat).
                run getParamGeneraux         in vhProc(output table ttParamGeneraux        ).
                run getParamCrg              in vhProc(output table ttParamCrg             ).
                run getParamCrl              in vhProc(output table ttParamCrl             ).
                run getParamDas2             in vhProc(output table ttParamDas2            ).
                run getParamDepotGarantie    in vhProc(output table ttParamDepotGarantie   ).
                run getParamHonoraireGestion in vhProc(output table ttParamHonoraireGestion).
                run getParamIrf              in vhProc(output table ttParamIrf             ).
                run getParamIsf              in vhProc(output table ttParamIsf             ).
                run getParamTva              in vhProc(output table ttParamTva             ).
            end.
        end case.
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.
       
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeDefautMandatGestion(pcFiltre as longchar, input-output dataset dsbeParametreGerance):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.

        if pcFiltre > "" then do:
            create temp-table vhttFilter.
            vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
            if not error-status:error then do:
                vhBuffer = vhttFilter:default-buffer-handle.
                vhBuffer:find-first() no-error.
                if vhBuffer:available then do:
                    vcVue = vhBuffer::cVue no-error.
                end.
            end.
            delete object vhttFilter.
        end.
        empty temp-table ttCombo.
        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/defautMandatGerance.p").
        case vcVue:
            when 'CHARGELOCATIVE'   then run setParamChargeLocative   in vhProc(table ttParamChargeLocative  ).
            when 'COMMENTAIRE'      then run setParamCommentaire      in vhProc(table ttParamCommentaire     ).
            when 'COMMERCIAL'       then run setParamCommercial       in vhProc(table ttParamCommercial      ).
            when 'DOSSIERMANDAT'    then run setParamDossierMandat    in vhProc(table ttParamDossierMandat, table ttParamListeDossierMandat).
            when 'GENERAUX'         then run setParamGeneraux         in vhProc(table ttParamGeneraux        ).
            when 'CRG'              then run setParamCrg              in vhProc(table ttParamCrg             ).
            when 'CRL'              then run setParamCrl              in vhProc(table ttParamCrl             ).
            when 'DAS2'             then run setParamDas2             in vhProc(table ttParamDas2            ).
            when 'DEPOTGARANTIE'    then run setParamDepotGarantie    in vhProc(table ttParamDepotGarantie   ).
            when 'HONORAIREGESTION' then run setParamHonoraireGestion in vhProc(table ttParamHonoraireGestion).
            when 'IRF'              then run setParamIrf              in vhProc(table ttParamIrf             ).
            when 'ISF'              then run setParamIsf              in vhProc(table ttParamIsf             ).
            when 'TVA'              then run setParamTva              in vhProc(table ttParamTva             ).
            otherwise do:
                run setParamChargeLocative   in vhProc(table ttParamChargeLocative  ).
                run setParamCommentaire      in vhProc(table ttParamCommentaire     ).
                run setParamCommercial       in vhProc(table ttParamCommercial      ).
                run setParamDossierMandat    in vhProc(table ttParamDossierMandat, table ttParamListeDossierMandat).
                run setParamGeneraux         in vhProc(table ttParamGeneraux        ).
                run setParamCrg              in vhProc(table ttParamCrg             ).
                run setParamCrl              in vhProc(table ttParamCrl             ).
                run setParamDas2             in vhProc(table ttParamDas2            ).
                run setParamDepotGarantie    in vhProc(table ttParamDepotGarantie   ).
                run setParamHonoraireGestion in vhProc(table ttParamHonoraireGestion).
                run setParamIrf              in vhProc(table ttParamIrf             ).
                run setParamIsf              in vhProc(table ttParamIsf             ).
                run setParamTva              in vhProc(table ttParamTva             ).
            end.
        end case.
        dataset dsbeParametreGerance:empty-dataset().
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}

    end method.
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeParametrageGeranceMandat(pcFiltre as longchar, output dataset dsbeParametrageGeranceMandat):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.
        define variable vcTypeTrt  as character no-undo.
        define variable vhProc     as handle    no-undo.

        dataset dsbeParametrageGeranceMandat:empty-dataset().
        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcVue     = vhBuffer::cVue     no-error.
                vcTypeTrt = vhBuffer::cTypeTrt no-error.
            end.
        end.
        case vcVue:
            when 'TARIFCIRCONSCRIPTION' then readTarifCirconscription(vcTypeTrt, vhBuffer).
            otherwise do:
                vhProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in vhProc(output table ttError).
            end.
        end case.
        delete object vhttFilter no-error.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeParamCrg(pcFiltre as longchar, output dataset dsbeParametreGerance):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc         as handle    no-undo.
        define variable vhttFilter     as handle    no-undo.
        define variable vhBuffer       as handle    no-undo.
        define variable vcTypeTrt      as character no-undo.
        define variable vcCodeScenario as character no-undo.

        dataset dsbeParametreGerance:empty-dataset().
        if pcFiltre > "" then do:
            create temp-table vhttFilter. 
            vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
            if not error-status:error then do:
                vhBuffer = vhttFilter:default-buffer-handle.
                vhBuffer:find-first() no-error.
                if vhBuffer:available then do:
                    vcTypeTrt       = vhBuffer::cTypeTrt no-error.
                    vcCodeScenario  = vhBuffer::cCodeScenario no-error.
                end.
            end.
            delete object vhttFilter.
        end.
        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/paramCrg.p").
        case vcTypeTrt:
            when 'COMBO'                then run getCombo                   in vhProc(output table ttCombo).
            when 'CRGSIMPLIFIE'         then run getParamCrgSimplifie       in vhProc(output table ttParamCrgListeCrgSimplifie).
            when 'LISTESCENARIOSCRG123' then run getListeScenariosCrg123    in vhProc(output table ttScenarioCrg123).
            when 'RUBRIQUESQUITCRG123'  then run getRubriquesQuitCrg123     in vhProc(vcCodeScenario, output table ttScenarioCrg123, output table ttRubriquesQuitScenarioCrg123).
            when 'RUBRIQUESANACRG123'   then run getRubriquesAnaCrg123      in vhProc(vcCodeScenario, output table ttScenarioCrg123, output table ttRubriquesAnaScenarioCrg123).
            when 'COMBOSCENARIOSCRG123' then run getComboScenariosCrg123    in vhProc(output table ttCombo, output table ttFamillesRubriquesQuitt, output table ttRubriquesQuitt).
            otherwise                        run getParamCrg                in vhProc(output table ttParamCrg, output table ttParamCrgSelectionDocument).
        end case.
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void updatebeParametrageGeranceMandat(pcFiltre as longchar, input-output dataset dsbeParametrageGeranceMandat):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.

        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcVue = vhBuffer::cVue no-error.
            end.
        end.
        case vcVue:
            when 'TARIFCIRCONSCRIPTION' then do:
                vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/tarifCirconscription.p").
                run updateTarifCirconscription in vhProc(table ttAnneeTarifCirconscription, table ttTarifCirconscription).
            end.
            otherwise do:
                vhProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in vhProc(output table ttError).
            end.
        end case.
        dataset dsbeParametrageGeranceMandat:empty-dataset().
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void updatebeParamCrg(pcFiltre as longchar, input-output dataset dsbeParametreGerance):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcTypeTrt  as character no-undo.

        if pcFiltre > "" then do:
            create temp-table vhttFilter. 
            vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
            if not error-status:error then do:
                vhBuffer = vhttFilter:default-buffer-handle.
                vhBuffer:find-first() no-error.
                if vhBuffer:available then do:
                    vcTypeTrt = vhBuffer::cTypeTrt no-error.
                end.
            end.
            delete object vhttFilter.
        end.
        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/paramCrg.p").
        case vcTypeTrt:
            when 'CRGSIMPLIFIE'   then run setParamCrgSimplifie in vhProc(table ttParamCrgListeCrgSimplifie).
            when 'SCENARIOCRG123' then run setScenarioCrg123    in vhProc(table ttScenarioCrg123, table ttRubriquesQuitScenarioCrg123, table ttRubriquesAnaScenarioCrg123, table ttError).
            otherwise                  run setParamCrg          in vhProc(table ttParamCrg, table ttParamCrgSelectionDocument, table ttParamCrgSuiviTrt, table ttError).  
        end case.
        dataset dsbeParametreGerance:empty-dataset().
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeParamTexteCrg(output dataset dsbeParametreGerance):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        dataset dsbeParametreGerance:empty-dataset().
        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/paramTexteCrg.p").
        run getParamTexteCrg in vhProc(output table ttParamTexteCrg).  
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method. 

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void updatebeParamTexteCrg(input-output dataset dsbeParametreGerance):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/paramTexteCrg.p").
        run setParamTexteCrg in vhProc(table ttParamTexteCrg).  
        dataset dsbeParametreGerance:empty-dataset().
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    method private logical readTarifCirconscription(pcTypeTrt as character, phBuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viAnnee as integer no-undo initial ?.
        define variable vhProc  as handle  no-undo.
        
        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/tarifCirconscription.p").
        if phBuffer:available then viAnnee = phBuffer::iAnnee no-error.
        case pcTypeTrt:
            when "COMBO"          then run initComboTarifCirconscription in vhProc(output table ttCombo).
            when "INITIALISATION" then run initTarifCirconscription in vhProc(output table ttAnneeTarifCirconscription, output table ttTarifCirconscription).
            otherwise run getTarifCirconscription in vhProc(viAnnee
                                                          , output table ttAnneeTarifCirconscription
                                                          , output table ttTarifCirconscription).
        end.
        run getErrors in vhProc(output table ttError).
    end method.

    destructor public beParametreGerance ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
