/*------------------------------------------------------------------------
File        : beChargeLocativePrestation.cls
Purpose     :
Author(s)   : GGA - 2018/01/22
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2compteur.i}

@program FILE(name="beChargeLocativePrestation.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beChargeLocativePrestation", URI="/beChargeLocativePrestation", schemaName="dsbeChargeLocativePrestation", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class tache.beChargeLocativePrestation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    define variable ghProc as handle    no-undo.  // plutôt que définir dans chacune des procédures.
    {application/include/error.i}
    {application/include/combo.i}
    {tache/include/periodeChargeLocative.i}
    {tache/include/relevePeriodeCharge.i &nomTable=ttReleveEauFroidePeriode}
    {tache/include/relevePeriodeCharge.i &nomTable=ttReleveEauChaudePeriode}
    {tache/include/relevePeriodeCharge.i &nomTable=ttReleveThermiesPeriode}
    {tache/include/imputationParticulierePeriodeCharge.i}
    {tache/include/depenseCommunePeriodeChargLoc.i}
    {tache/include/provisionChargeLocative.i}

    define dataset dsbeChargeLocativePrestation for
                   ttListePeriode,
                   ttDepenseCommunePeriode,
                   ttReleveEauFroidePeriode, ttReleveEauChaudePeriode, ttReleveThermiesPeriode,
                   ttImputationParticulierePeriode,
                   ttRubriqueProvisionPeriode,
                   ttCombo, ttError
    .

    constructor public beChargeLocativePrestation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeChargeLocativePrestation(pcFiltre as longchar, output dataset dsbeChargeLocativePrestation):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable viNumeroContrat as int64     no-undo.
        define variable vcVue           as character no-undo.
        define variable vcTypeTrt       as character no-undo.
        define variable viNumeroPeriode as integer   no-undo.
        define variable vcHistoEnCours  as character no-undo.

        dataset dsbeChargeLocativePrestation:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroContrat = vhBuffer::iNumeroContrat no-error.
                vcVue           = vhBuffer::cVue           no-error.
                vcTypeTrt       = vhBuffer::cTypeTrt       no-error.
                viNumeroPeriode = vhBuffer::iNumeroPeriode no-error.
                vcHistoEnCours  = vhBuffer::cHistoEnCours  no-error.  
            end.
        end.
        delete object vhttFilter no-error.

// DEBUG message "readbeChargeLocativePrestation " vcVue "//" viNumeroContrat "//" viNumeroPeriode "//" vcTypeTrt.        
        case vcVue:
            when 'PERIODE'         then readPeriode(viNumeroContrat, vcTypeTrt, vcHistoEnCours).
            when 'DEPENSE-RELEVE'  then readDepenseReleve(viNumeroContrat, viNumeroPeriode).
            when 'PROVISIONCHARGE' then readProvisionChargeLocative(viNumeroContrat, vcTypeTrt, viNumeroPeriode).
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        {outils/include/tryCatch.i}

    end method.

    method private logical readPeriode(piNumeroContrat as int64, pcTypeTrt as character, pcHistoEnCours as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/chargeLocative/periodeChargeLocative.p").
        case pcTypeTrt:
            when "COMBO"          then run comboPeriodeChargeLocativePrestation in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, output table ttCombo).
            when "INITIALISATION" then run initPeriodeChargeLocativePrestation  in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, output table ttListePeriode).
            otherwise                  run getPeriodeChargeLocativePrestation   in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, pcHistoEnCours, output table ttListePeriode).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readDepenseReleve(piNumeroContrat as int64, piNumeroPeriode as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/chargeLocative/periodeChargeLocative.p").
        run getDepensePeriode                in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, piNumeroPeriode, output table ttDepenseCommunePeriode).
        run getRelevePeriode                 in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, piNumeroPeriode, {&TYPECOMPTEUR-EauFroide}, output table ttReleveEauFroidePeriode).
        run getRelevePeriode                 in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, piNumeroPeriode, {&TYPECOMPTEUR-EauChaude}, output table ttReleveEauChaudePeriode).
        run getRelevePeriode                 in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, piNumeroPeriode, {&TYPECOMPTEUR-Thermie},  output table ttReleveThermiesPeriode).
        run getImputationParticulierePeriode in ghProc(piNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, piNumeroPeriode, output table ttImputationParticulierePeriode).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readProvisionChargeLocative(piNumeroContrat as int64, pcTypeTrt as character, piNumeroPeriode as integer):
        /*------------------------------------------------------------------------------
        Purpose: Extraction des provisions locataires de la période (en détail + cumul ou uniquement cumul)
        Notes  : pcTypeTrt = DETAILRUB pour l'écran de visu/saisie ("V" dans contbpro.i)
                             CUMULRUB  pour le traitement des charges locatives ("D" dans contbpro.i) 
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/chargeLocative/provisionChargeLocative.p").
        run getProvisionChargeLocative   in ghProc( {&TYPECONTRAT-mandat2Gerance}, piNumeroContrat, piNumeroPeriode, pcTypeTrt, output table ttRubriqueProvisionPeriode).
        run getErrors in ghProc(output table ttError).
    end method.
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeChargeLocativePrestation(pcFiltre as longchar, input-output dataset dsbeChargeLocativePrestation):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.
        define variable vcTypeTrt  as character no-undo.

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
        delete object vhttFilter no-error.
        case vcVue:
            when 'PERIODE'         then updatePeriode(vcTypeTrt).
            when "PROVISIONCHARGE" then updateProvisionChargeLocative().
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        {outils/include/tryCatch.i}
    end method.

    method private logical updatePeriode(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/chargeLocative/periodeChargeLocative.p").
        case pcTypeTrt: 
            when "CALCULDATE" 
            then run initDatePeriodeChargeLocativePrestation in ghProc(input-output table ttListePeriode). 
            otherwise do:
                run setPeriodeChargeLocativePrestation in ghProc(table ttListePeriode, table ttError).
                dataset dsbeChargeLocativePrestation:empty-dataset().
            end.
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

   method private logical updateProvisionChargeLocative():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/chargeLocative/provisionChargeLocative.p").
        run setProvisionChargeLocative in ghProc(table ttRubriqueProvisionPeriode).
        dataset dsbeChargeLocativePrestation:empty-dataset().
        run getErrors in ghProc(output table ttError).        
    end method. 
    
    destructor public beChargeLocativePrestation ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
