/*------------------------------------------------------------------------
File        : labelLadb.p
Purpose     :
Author(s)   : kantena - 2016/02/08
Notes       :
Tables      : BASE sadb : inter PrmTv roles ctrat secte ssecteurs tache
              BASE ladb : sys_rf
----------------------------------------------------------------------*/
{preprocesseur/codePeriode.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/codeFinancier2commercialisation.i}

using parametre.pclie.parametrageNatureBien.
using parametre.pclie.parametrageTypeImmeuble.
using parametre.pclie.parametrageCategorieImmeuble.
using parametre.pclie.parametrageTypeCentre.
using parametre.pclie.parametrageOrientation.
using parametre.pclie.parametrageTheme.
using parametre.pclie.parametrageTypeGestion.
using parametre.pclie.parametrageTypeContrat.
using parametre.pclie.parametrageLibelleMoyen.
using parametre.pclie.parametrageMotifIndisponibilite.
using parametre.pclie.parametrageOrigineClient.
using parametre.syspr.parametrageDesignation.
using parametre.syspr.parametrageTypeBaremeHonoraire.
using parametre.syspr.syspr.
using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/labelLadb.i}
{application/include/combo.i}

define variable giNumeroItem  as integer no-undo.
define variable gcNomCombo    as character no-undo.

function createttCombo returns logical private(pcCode as character, pcLibelle as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    create ttCombo.
    assign
        giNumeroItem      = giNumeroItem + 1
        ttcombo.iSeqId    = giNumeroItem
        ttCombo.cNomCombo = gcNomCombo
        ttCombo.cCode     = pcCode
        ttCombo.cLibelle  = pcLibelle
    .
end function.

function createttCombo2Libelle returns logical private(pcCode as character, pcLibelle as character, pcLibelle2 as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    create ttCombo.
    assign
        giNumeroItem      = giNumeroItem + 1
        ttcombo.iSeqId    = giNumeroItem
        ttCombo.cNomCombo = gcNomCombo
        ttCombo.cCode     = pcCode
        ttCombo.cLibelle  = pcLibelle
        ttCombo.cLibelle2 = pcLibelle2
    .
end function.

function createttCombo3Libelle returns logical private(pcCode as character, pcLibelle as character, pcLibelle2 as character, pcLibelle3 as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    create ttCombo.
    assign
        giNumeroItem      = giNumeroItem + 1
        ttcombo.iSeqId    = giNumeroItem
        ttCombo.cNomCombo = gcNomCombo
        ttCombo.cCode     = pcCode
        ttCombo.cLibelle  = pcLibelle
        ttCombo.cLibelle2 = pcLibelle2
        ttCombo.cLibelle3 = pcLibelle3
    .
end function.

function createttComboWithParent returns logical private(pcCode as character, pcLibelle as character, pcParent as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    create ttCombo.
    assign
        giNumeroItem      = giNumeroItem + 1
        ttcombo.iSeqId    = giNumeroItem
        ttCombo.cNomCombo = gcNomCombo
        ttCombo.cCode     = pcCode
        ttCombo.cParent   = pcParent
        ttCombo.cLibelle  = pcLibelle
    .
end function.

function createSyspg returns logical private(pcTppar as character, pcCdpar as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg as class syspg no-undo.
    voSyspg = new syspg().
    if pcCdpar > ""
    then voSyspg:getComboParametre(pcTppar, pcCdpar, gcNomCombo, output table ttCombo by-reference).
    else voSyspg:getComboParametre(pcTppar, gcNomCombo, output table ttCombo by-reference).
    delete object voSyspg.
end function.
function createSyspgParent returns logical private(pcTppar as character, pcZone2 as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg as class syspg no-undo.
    voSyspg = new syspg(pcTppar, gcNomCombo).
    voSyspg:getComboParametreWithParent(pcZone2, output table ttCombo by-reference).
    delete object voSyspg.
end function.

function createPrmtv returns logical private(pcTppar as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer prmtv for prmtv.
    for each prmtv no-lock
        where prmtv.tppar = pcTppar
        by PrmTv.NoOrd:
        createttCombo(prmtv.cdpar, trim(prmtv.lbpar)).
    end.
end function.

function getLastNoInter returns character private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer inter for inter.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for last inter no-lock:
        return string(inter.noint, "999999999").
    end.
    return string(0, "999999999").
end function.

procedure getListelabel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beLabelLadb.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcListeChamps as character no-undo.
    define output parameter table for ttsys_lb.

    define variable vi      as integer no-undo.
    define variable viEntry as integer no-undo.
    define buffer ttsys_lb for ttsys_lb.

boucle:
    do vi = 1 to num-entries(pcListeChamps, ","):
        viEntry = integer(entry(vi, pcListeChamps, ",")) no-error.
        if error-status:error then next boucle.

        create ttsys_lb.
        assign
            ttsys_lb.nomes = viEntry
            ttsys_lb.lbmes = outilTraduction:getLibelle(viEntry)
        .
    end.
    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value

end procedure.

procedure getPagelabel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beLabelLadb.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcPage     as character no-undo.
    define output parameter table for ttsys_lb.

    define variable vi      as integer   no-undo.
    define variable vcEntry as character no-undo.
    define buffer sys_rf for sys_rf.
    define buffer ttsys_lb for ttsys_lb.

    empty temp-table ttsys_lb.
    do vi = 1 to num-entries(pcPage, ","):
        vcEntry = entry(vi, pcPage, ",").
        {&_proparse_ prolint-nowarn(wholeindex)}
        for each sys_rf no-lock
            where sys_rf.tpmes = vcEntry:
            create ttsys_lb.
            assign
                ttsys_lb.nomes = integer(sys_rf.nomes)
                ttsys_lb.lbmes = outilTraduction:getLibelle(sys_rf.nomes)
            .
        end.
    end.
    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value

end procedure.

procedure getCombolabel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beLabelLadb.cls
    ------------------------------------------------------------------------------*/
    define input parameter pComboFilter as character no-undo.
    define output parameter table for ttcombo.

    define variable viNumeroCombo as integer     no-undo.
    define variable voSyspr       as class syspr no-undo.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    do viNumeroCombo = 1 to num-entries (pComboFilter, ","):
        gcNomCombo = entry(viNumeroCombo, pComboFilter, ",").
        case gcNomCombo:
            /***************************************** IMMEUBLE ET LOT ******************************************/
            when 'CMBTYPECENTRE'            then run createTypeCentre.
            when "CMBARCHITECTE"            then run createTypeRole({&TYPEROLE-architecte}, false).
            when "CMBGARDIEN"               then run createTypeRoleGardien.
            when "CMBPROMOTEUR"             then run createTypeRole({&TYPEROLE-promoteur}, false).
            when "CMBTYPEDOMMAGEOUVRAGE"    then voSyspr:getComboParametre("TPOUV", gcNomCombo, output table ttCombo by-reference).
            when "CMBNOTAIRE"               then run createTypeRole({&TYPEROLE-notaire}, false).
            when "CMBSERVICE"               then run createServiceGestion.
            when "CMBRESPONSABLE"           then run createTypeRole({&TYPEROLE-gestionnaire}, true).
            when "CMBTYPEIMMEUBLE"          then run createTypeImmeuble.
            when "CMBNATUREBIEN"            then run createNatureBien.
            when "CMBCATEGORIEIMMEUBLE"     then run createCategorieImmeuble.
            when "CMBQUALITEIMMEUBLE"       then voSyspr:getComboParametre("CLMQA", gcNomCombo, output table ttCombo by-reference).
            when "CMBLOCALISATIONIMMEUBLE"  then voSyspr:getComboParametre("CLMLO", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPEPROPRIETE"         then voSyspr:getComboParametre("CLMPR", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPEOUVRAGE"           then voSyspr:getComboParametre("TPOUV", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPECONSTRUCTION"      then voSyspr:getComboParametre("TPCST", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPETOITURE"           then voSyspr:getComboParametre("TPTOI", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPECHAUFFAGE"         then voSyspr:getComboParametre("TPCHA", gcNomCombo, output table ttCombo by-reference).
            when "CMBMODECHAUFFAGE"         then voSyspr:getComboParametre("MDCHA", gcNomCombo, output table ttCombo by-reference).
            when "CMBMODECLIMATISATION"     then voSyspr:getComboParametre("MDCLI", gcNomCombo, output table ttCombo by-reference).
            when "CMBMODEEAUCHAUDE"         then voSyspr:getComboParametre("MDCHD", gcNomCombo, output table ttCombo by-reference).
            when "CMBMODEEAUFROIDE"         then voSyspr:getComboParametre("MDFRA", gcNomCombo, output table ttCombo by-reference).
            when "CMBLISTEUSAGE"            then run createListeUsageLot.
            when "CMBORIENTATION"           then run createOrientation.
            when "CMBANNEXE"                then voSyspr:getComboParametre("TPANX", gcNomCombo, output table ttCombo by-reference).
            when "CMBACQUISITION"           then voSyspr:getComboParametre("TPACQ", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPEROLEIMMEUBLE"      then run createTypeRoleImmeuble.
            when "CMBEQUIPEMENTIMMEUBLE"    then run createEquipement("immeuble").
            when "CMBSECTEURGEO"            then run createSecteurGeographique.
            when "CMBSOUSSECTEURGEO"        then run createSousSecteurGeographique.
            /*****************************************      QUITTANCEMENT      ******************************************/
            when "CMBECHEANCELOYER"         then voSyspr:getComboParametre("TEQTT", gcNomCombo, output table ttCombo by-reference).
            when "CMBPERIODICITEQTT"        then voSyspr:getComboParametreCourt("PDQTT", gcNomCombo, output table ttCombo by-reference).
            when "CMBMOISPRELEVQTT"         then voSyspr:getComboParametreCourt("PRLOC", gcNomCombo, output table ttCombo by-reference).
            when "CMBREPRISESOLDE"          then voSyspr:getComboParametre("EDTSD", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPEEDITIONQUITTANCE"  then run createTypeEditionQuittance.
            /***************************************** TRAVAUX ET INTERVENTION ******************************************/
            when "CMBTYPINTER"              then run createTypeIntervention.
            when "CMBSIG"                   then run createTypeRoleSig.
            when "CMBMODESIGNALEMENT"       then createPrmtv("MDAPP").
            when "CMBMOTIFSCLOTUREINTER"    then createPrmtv("CDCLO").
            when "CMBSTATUTINTER"           then run createStatutIntervention.
            when "CMBSTATUTVOTE"            then run createStatutVote.
            when "CMBDELAI"                 then createPrmtv("DLINT").
            /***************************************** GED ******************************************/
            when "CMBREFERENCESOCIETE"      then run createReferenceSociete.
            when "CMBNATUREDOCUMENT"        then run createNatureDocument.
            when "CMBTHEME"                 then run createTheme("").
            when "CMBTHEMEGED"              then run createTheme("GED").
            when "CMBTHEMEGIEXTRANET"       then run createTheme("GIEXTRANET").
            when "CMBTHEMETRAVAUX"          then run createThemeTravaux.
            when "CMBFACTURABLEA"           then run createFacturableA.
            when "CMBDIAGETUDE"             then run createDiagnostiqueEtude.     /* Etude      */
            when "CMBTYPECOPRO"             then voSyspr:getComboParametre("TPSYN", gcNomCombo, output table ttCombo by-reference). /* Web_Immeuble */
            when "CMBNATURELOT"             then voSyspr:getComboParametre("NTLOT", gcNomCombo, output table ttCombo by-reference). /* Web_lot      */
            when "CMBTYPEOCCUPANT"          then voSyspr:getComboParametre("TPOCC", gcNomCombo, output table ttCombo by-reference).
            when "CMBRESULTATDIAG"          then voSyspr:getComboParametre("CDPOS", gcNomCombo, output table ttCombo by-reference).
            when "CMBDISPOSITIONDIAG"       then voSyspr:getComboParametre("CDDIA", gcNomCombo, output table ttCombo by-reference).
            when "CMBDISPOSITIONETU"        then voSyspr:getComboParametre("CDETU", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPETRAVAUX"           then voSyspr:getComboParametre("TPTRA", gcNomCombo, output table ttCombo by-reference).
            when "CMBNATUREPLAN"            then voSyspr:getComboParametre("CDPLA", gcNomCombo, output table ttCombo by-reference).
            when "CMBNATUREUL"              then voSyspr:getComboParametre("NTAPP", gcNomCombo, output table ttCombo by-reference).
            when "CMBINSTALLATEURASC"       then run createAscenceur({&TYPETACHE-ascenseurs}).
            when "CMBORGANISMEASC"          then run createAscenceur({&TYPETACHE-ctlTechniqueAscenseur}).
            when "CMBUNITESURFACE"          then voSyspr:getComboParametreCourt("UTSUR", gcNomCombo, output table ttCombo by-reference).
            when "CMBOUINON"                then voSyspr:getComboParametreCourt("CDOUI", gcNomCombo, output table ttCombo by-reference).
            when "CMBFORMATADRESSE"         then voSyspr:getComboParametre("FTADR", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPEADRESSE"           then voSyspr:getComboParametre("TPADR", gcNomCombo, output table ttCombo by-reference).
            when "CMBNUMEROBIS"             then voSyspr:getComboParametre("CDADR", gcNomCombo, output table ttCombo by-reference).
            when "CMBNATUREVOIE"            then voSyspr:getComboParametre("NTVOI", gcNomCombo, output table ttCombo by-reference).
            when "CMBCATFOURNISSEUR"        then run createCategorieFournisseur.
            when "CMBDOMFOURNISSEUR"        then run createDomaineFournisseur.
            when "CMBCONDITIONREGL"         then run createConditionReglement.
            when "CMBTYPEGESTION"           then run createTypeGestion.
            when "CMBTYPECONTRAT"           then run createTypeContrat.
            when "CMBLIBELLEMOYEN"          then run createLibelleMoyen.
            when "CMBTYPEMOYEN"             then run voSyspr:getComboParametreCdpar("CDTE2", gcNomCombo, output table ttCombo by-reference).
            when "CMBEQUIPEMENTLOT"         then run createEquipement("lot").
            when "CMBDESIGNATIONPIECE"      then run createComboDesignation.
            // spécifique commercialisation
            when "CMBTYPELOYER"             then run createTypeLoyer.
            when "CMBDETAILLOYER"           then voSyspr:getComboParametreZone1("GLCHF", {&TYPEFINANCE-LOYER}, gcNomCombo, output table ttCombo by-reference).
            when "CMBFRAISGESTION"          then voSyspr:getComboParametre("LBFRS", gcNomCombo, output table ttCombo by-reference).
            when "CMBPERIODICITELOYER"      then run createPeriodicite.
            when "CMBINDICELOYER"           then run createIndiceLoyer.
            when "CMBDETAILDEPOT"           then voSyspr:getComboParametreZone1("GLCHF", {&TYPEFINANCE-DEPOT}, gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPEHONORAIRE1"        then run createTypeHonoraire1.
            when "CMBTYPEHONORAIRE2"        then run createTypeHonoraire2.
            when "CMBDETAILHONORAIRE19"     then voSyspr:getComboParametreZone2("GLCHF", {&TYPEFINANCE-HONORAIRE}, {&TYPEROLE-locataire}, gcNomCombo, output table ttCombo by-reference).
            when "CMBDETAILHONORAIRE22"     then voSyspr:getComboParametreZone2("GLCHF", {&TYPEFINANCE-HONORAIRE}, {&TYPEROLE-mandant}, gcNomCombo, output table ttCombo by-reference). 
            when "CMBLOCGARANTIE"           then run createLocationGarantie.
            when "CMBPUBLICATIONWEB"        then voSyspr:getComboParametre("GLWEB", gcNomCombo, output table ttCombo by-reference).
            when "CMBLOCATTRIBUT"           then voSyspr:getComboParametre("GLATB", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPEZONEALUR"          then voSyspr:getComboParametre("GLZON", gcNomCombo, output table ttCombo by-reference).
            when "CMBPROXIMITE"             then voSyspr:getComboParametre("GLPRO", gcNomCombo, output table ttCombo by-reference).
            when "CMBTYPEBAREMEHON"         then run createTypeBaremeHonoraire.
            when "CMBTYPEHONORAIRE"         then createSyspg("O_TPH", "").
            when "CMBNATUREHONORAIRE"       then run createNatureHonoraire.
            when "CMBINDICEREVISION"        then run createIndiceRevision.
            when "CMBPRESENTATIONCOMPTABLE" then voSyspr:getComboParametre("TTHON", gcNomCombo, output table ttCombo by-reference).
            when "CMBWORKFLOW"              then voSyspr:getComboParametre("GLWFW", gcNomCombo, output table ttCombo by-reference).  // NPO encours dépend d'un parent voir avec NL
            when "CMBLOCCREATION"           then voSyspr:getComboParametre("GLMCR", gcNomCombo, output table ttCombo by-reference).
            when "CMBTPROLECOMM"            then run createTypeRoleCommercialisation.
            when "CMBMODEPAIEMENT"          then run createModePaiement.
            when "CMBRAISONSOCIALE"         then run createRaisonSociale.
            when "CMBMOTIFINDISPONIBILITE"  then run createMotifFinDisponibilite.
            when "CMBUNITEDUREE"            then voSyspr:getComboParametre("UTDUR", gcNomCombo, output table ttCombo by-reference).
            when "CMBORIGINECLIENT"         then run createOrigineClient.
            when "CMBTYPEACTE"              then voSyspr:getComboParametre("TPACT", gcNomCombo, output table ttCombo by-reference).
            when "CMBMODEENVOICRG"          then voSyspr:getComboParametre("MDNET", gcNomCombo, output table ttCombo by-reference).
            when "CMBMOTIFRESILIATION"      then voSyspr:getComboParametre("TPMOT", gcNomCombo, output table ttCombo by-reference).
        end case.
    end.
    delete object voSyspr no-error.
    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value
end procedure.

procedure createTypeCentre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voTypeCentre as class parametrageTypeCentre no-undo.
    voTypeCentre = new parametrageTypeCentre().
    if voTypeCentre:isGesTypeCentre()
    then createttCombo('SIE', outilTraduction:getLibelle(110180)).
    else do:
        createttCombo('CDI', outilTraduction:getLibelle(701187)).
        createttCombo('ODB', outilTraduction:getLibelle(701191)).
        createttCombo('OTS', outilTraduction:getLibelle(103499)).
    end.
    delete object voTypeCentre.
end procedure.
procedure createTypeRole private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTprol as character no-undo.
    define input  parameter plAll   as logical   no-undo.
    define buffer vbRoles for roles.
    if plAll then createttCombo('all', outilTraduction:getLibelle(704831)).  /* tous              */
    for each vbRoles no-lock where vbRoles.tprol = pcTprol:
        createttCombo3Libelle(string(vbRoles.norol), outilFormatage:getNomTiers(vbRoles.tprol, vbRoles.norol), vbRoles.tprol, outilTraduction:getLibelleProg('O_ROL', vbRoles.tprol)).
    end.
end procedure.
procedure createTypeRoleGardien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run createTypeRole({&TYPEROLE-salariePegase}, false).
    run createTypeRole({&TYPEROLE-gardienExterne}, false).
end procedure.
procedure createTypeRoleImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&TYPEROLE-locataire},     outilTraduction:getLibelle(100039)).
    createttCombo({&TYPEROLE-coproprietaire}, outilTraduction:getLibelle(101185)).
    createttCombo({&TYPEROLE-colocataire},   outilTraduction:getLibelle(701818)).
    createttCombo({&TYPEROLE-salarie},       outilTraduction:getLibelle(104186)).
end procedure.
procedure createServiceGestion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    createttCombo('all', outilTraduction:getLibelle(704831)).  /* tous              */
    for each ctrat no-lock where ctrat.tpcon = {&TYPECONTRAT-serviceGestion}:
        createttCombo(string(ctrat.nocon, "99999"), ctrat.noree).
    end.
end procedure.
procedure createTypeImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voTypeImmeuble as class parametrageTypeImmeuble no-undo.
    define variable voSyspr        as class syspr                   no-undo.
    voTypeImmeuble = new parametrageTypeImmeuble().
    if voTypeImmeuble:isDbParameter                                                    // Paramétrage type immeuble dans pclie
    then voTypeImmeuble:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    else do:
        voSyspr = new syspr().
        voSyspr:getComboParametre("TPIMM", gcNomCombo, output table ttCombo by-reference).
    end.
    delete object voTypeImmeuble.
end procedure.
procedure createNatureBien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voNatureBien as class parametrageNatureBien no-undo.
    voNatureBien = new parametrageNatureBien().
    voNatureBien:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    delete object voNatureBien.
end procedure.
procedure createCategorieImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voCategorieImmeuble as class parametrageCategorieImmeuble no-undo.
    voCategorieImmeuble = new parametrageCategorieImmeuble().
    voCategorieImmeuble:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    delete object voCategorieImmeuble.
end procedure.
procedure createListeUsageLot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer usageLot for usageLot.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for each usagelot no-lock:
        createttCombo(usagelot.cdusa, usagelot.lbusa).
    end.
end procedure.
procedure createOrientation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voOrientation as class parametrageOrientation no-undo.
    voOrientation = new parametrageOrientation().
    voOrientation:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    delete object voOrientation.
end procedure.
procedure createSecteurGeographique private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer secte for secte.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for each secte no-lock:
        createttCombo(secte.cdsec, secte.lbsec).
    end.
end procedure.
procedure createSousSecteurGeographique private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ssecteurs for ssecteurs.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for each ssecteurs no-lock:
        createttComboWithParent(ssecteurs.cdsse, ssecteurs.lbsec, ssecteurs.cdsec).
    end.
end procedure.
procedure createTypeIntervention private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo('all',                             outilTraduction:getLibelle(704831)).  /* tous              */
    createttCombo({&TYPEINTERVENTION-signalement},   outilTraduction:getLibelle(702037)).  /* signalement       */
    createttCombo({&TYPEINTERVENTION-demande2devis}, outilTraduction:getLibelle(702038)).  /* devis             */
    createttCombo({&TYPEINTERVENTION-reponseDevis},  outilTraduction:getLibelle(702039)).  /* réponse devis     */
    createttCombo({&TYPEINTERVENTION-ordre2service}, outilTraduction:getLibelle(702040)).  /* ordre de service  */
    createttCombo({&TYPEINTERVENTION-facture},       outilTraduction:getLibelle(100460)).  /* réception facture */
end procedure.
procedure createTypeRoleSig private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&TYPEROLE-locataire},      outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-locataire})).      /* Locataire               */
    createttCombo({&TYPEROLE-mandant},        outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-mandant})).        /* Mandant                 */
    createttCombo({&TYPEROLE-coproprietaire},  outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-coproprietaire})).  /* copropietaire           */
    createttCombo("FOU",                      outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-fournisseur})).    /* fournisseur             */
    createttCombo({&TYPEROLE-salarie},        outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-salarie})).        /* Salarié                 */
    createttCombo({&TYPEROLE-syndicat2copro}, outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-syndicat2copro})). /* Syndicat de copropriété */
end procedure.
procedure createStatutIntervention private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcListeStatut as character no-undo.
    define variable viCpt         as integer   no-undo.
    assign
        vcListeStatut = substitute('&1,&2,&3,&4,&5,&6,&7,&8,&9',
                          {&STATUTINTERVENTION-initie},
                          {&STATUTINTERVENTION-complementInfo},
                          {&STATUTINTERVENTION-enCours},
                          {&STATUTINTERVENTION-envoye},
                          {&STATUTINTERVENTION-relance},
                          {&STATUTINTERVENTION-repondu},
                          {&STATUTINTERVENTION-nonRepondu},
                          {&STATUTINTERVENTION-accepte},
                          {&STATUTINTERVENTION-refuse})
        vcListeStatut = substitute('&1,&2,&3,&4,&5,&6,&7,&8,&9',
                          vcListeStatut,
                          {&STATUTINTERVENTION-termine},
                          {&STATUTINTERVENTION-nonComptabilise},
                          {&STATUTINTERVENTION-comptabilise},
                          {&STATUTINTERVENTION-bonAPayer},
                          {&STATUTINTERVENTION-vote},
                          {&STATUTINTERVENTION-voteResp},
                          {&STATUTINTERVENTION-VoteProp},
                          {&STATUTINTERVENTION-voteCS})
        vcListeStatut = substitute('&1,&2',
                          vcListeStatut,
                          {&STATUTINTERVENTION-voteAG})
    .
    createttCombo("all", outilTraduction:getLibelle(704831)).
    do viCpt = 1 to num-entries(vcListeStatut, ","):
        createttCombo(entry(viCpt, vcListeStatut), outilTraduction:getLibelleParam("STTRV", entry(viCpt, vcListeStatut))).
    end.
end procedure.
procedure createStatutVote private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&STATUTINTERVENTION-voteCS},   outilTraduction:getLibelle(1000196)).
    createttCombo({&STATUTINTERVENTION-voteAG},   outilTraduction:getLibelle(1000197)).
    createttCombo({&STATUTINTERVENTION-voteResp}, outilTraduction:getLibelle(1000193)).
    createttCombo({&STATUTINTERVENTION-VoteProp}, outilTraduction:getLibelle(1000194)).
end procedure.
procedure createReferenceSociete private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer isoc for isoc.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for each isoc no-lock where isoc.specif-cle = 1000:
        createttCombo(string(isoc.soc-cd, "99999"), isoc.nom).
    end.
end procedure.
procedure createNatureDocument private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer aparm for aparm.
    for each aparm no-lock where aparm.tppar = "GEDNAT":
        createttCombo(aparm.cdpar, aparm.lib).
    end.
end procedure.
procedure createThemeTravaux private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer prmtv for prmtv.
    run createTheme("TRAVAUX").
    /* Ajout des thèmes travaux */
    for each prmtv no-lock where prmtv.tppar = "DOMAI" and prmtv.fgdef by PrmTv.NoOrd:
        createttCombo(string(10000 + integer(prmtv.cdpar), "99999"), trim(prmtv.lbpar)).
    end.
end procedure.
procedure createTheme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTheme    as character no-undo.
    define variable voTheme as class parametrageTheme no-undo.
    voTheme = new parametrageTheme().
    case pcTheme:
        when "GED"        then giNumeroItem = voTheme:getComboParametreThemeGED       (gcNomCombo, output table ttCombo by-reference).
        when "GIEXTRANET" then giNumeroItem = voTheme:getComboParametreThemeGIExtranet(gcNomCombo, output table ttCombo by-reference).
        when "TRAVAUX"    then giNumeroItem = voTheme:getComboParametreThemeTravaux   (gcNomCombo, output table ttCombo by-reference).
        when ""           then giNumeroItem = voTheme:getComboParametre               (gcNomCombo, output table ttCombo by-reference).
    end case.
    delete object voTheme.
end procedure.
procedure createFacturableA private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&TYPECONTRAT-mandat2Syndic},  outilTraduction:getLibelle(701337)).
    createttCombo({&TYPEROLE-coproprietaire},     outilTraduction:getLibelle(101185)).
    createttCombo({&TYPECONTRAT-mandat2Gerance}, outilTraduction:getLibelle(701793)).
    createttCombo({&TYPEROLE-locataire},         outilTraduction:getLibelle(100039)).
end procedure.
procedure createDiagnostiqueEtude private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&TYPETACHE-diagnosticTechnique}, outilTraduction:getLibelle('1000008')). /* diagnostic */
    createttCombo({&TYPETACHE-miseEnConformite}, outilTraduction:getLibelle('701403')).     /* Etude      */
end procedure.
procedure createAscenceur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTache as character no-undo.
    define buffer tache for tache.
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = pcTypeTache
        break by tache.tpfin:
        if first-of(tache.tpfin) then createttCombo(tache.tpfin, outilFormatage:getNomFour("F", integer(tache.tpfin))).
    end.
end procedure.
procedure createCategorieFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer icatfour for icatfour.
    createttCombo('all', outilTraduction:getLibelle(704831)).  /* tous              */
    for each icatfour no-lock
        where icatfour.soc-cd = integer(mtoken:cRefPrincipale)
        by icatfour.lib:
        createttCombo(string(icatfour.categ-cd), icatfour.lib).
    end.
end procedure.
procedure createDomaineFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo('all', outilTraduction:getLibelle(704831)).  /* tous              */
    createPrmtv("DOMAI").
end procedure.
procedure createConditionReglement private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer iregl for iregl.
    for each iregl no-lock
        where iregl.soc-cd = integer(mtoken:cRefPrincipale):
        createttCombo(string(iregl.regl-cd), iregl.lib).
    end.
end procedure.
procedure createTypeGestion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voTypeGestion as class parametrageTypeGestion no-undo.
    voTypeGestion = new parametrageTypeGestion().
    giNumeroItem = voTypeGestion:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    delete object voTypeGestion.
end procedure.
procedure createTypeContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voTypeContrat as class parametrageTypeContrat no-undo.
    voTypeContrat = new parametrageTypeContrat().
    giNumeroItem = voTypeContrat:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    delete object voTypeContrat.
end procedure.
procedure createLibelleMoyen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voLibelleMoyen as class parametrageLibelleMoyen no-undo.
    voLibelleMoyen = new parametrageLibelleMoyen().
    giNumeroItem = voLibelleMoyen:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    delete object voLibelleMoyen.
end procedure.
procedure createEquipement private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcType as character no-undo.
    define buffer equipements for equipements.
    case pcType:
        when "immeuble" then for each equipements no-lock where equipements.fgImmeuble:
           createttCombo2Libelle(equipements.cCodeEquipement, equipements.cDesignation, equipements.cListeValeurs).
        end.
        when "lot" then for each equipements no-lock where equipements.fgLot:
           createttCombo2Libelle(equipements.cCodeEquipement, equipements.cDesignation, equipements.cListeValeurs).
        end.
    end case.
end procedure.
procedure createPeriodicite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&PERIODICITEPNO-mensuel},     outilTraduction:getLibelle("1000057")).  // mensuel
    createttCombo({&PERIODICITEPNO-trimestriel}, outilTraduction:getLibelle("1000058")).  // trimestriel
    createttCombo({&PERIODICITEPNO-semestriel},  outilTraduction:getLibelle("1000059")).  // semestriel
    createttCombo({&PERIODICITEPNO-annuel},      outilTraduction:getLibelle("1000060")).  // annuel
end procedure.
procedure createTypeLoyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&TYPELOYER-Habitation89},  outilTraduction:getLibelle("1000055")).
    createttCombo({&TYPELOYER-commercial},    outilTraduction:getLibelle("1000053")).
    createttCombo({&TYPELOYER-Stationnement}, outilTraduction:getLibelle("1000056")).
    createttCombo({&TYPELOYER-Habitation},    outilTraduction:getLibelle("1000054")).
end procedure.
procedure createIndiceLoyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo("00006", outilTraduction:getLibelle("1000063")).  // N° indice dans indrv: ICC=6
    createttCombo("00201", outilTraduction:getLibelle("1000061")).  // N° indice dans indrv: IRL=201
    createttCombo("00210", outilTraduction:getLibelle("1000062")).  // N° indice dans indrv: ILC=210
    createttCombo("00211", outilTraduction:getLibelle("1000064")).  // N° indice dans indrv: ILAT=211
end procedure.
procedure createTypeHonoraire1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&TYPEROLEHONORAIRE},      outilTraduction:getLibelle("0102127")).  // Honoraires
    createttCombo({&TYPEROLEHONORAIRE-Alur}, outilTraduction:getLibelle("1000069")).  // Honoraires ALUR
end procedure.
procedure createTypeHonoraire2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&TYPEROLEHONORAIRE-Locataire},    outilTraduction:getLibelle("0701067")).
    createttCombo({&TYPEROLEHONORAIRE-Proprietaire}, outilTraduction:getLibelle("0100051")).
end procedure.
procedure createLocationGarantie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg as class syspg no-undo.
    voSyspg = new syspg().
    voSyspg:getComboParametre("O_TAE", {&TYPETACHE-GarantieLoyer}, gcNomCombo, output table ttCombo by-reference).
    voSyspg:getComboParametre("O_TAE", {&TYPETACHE-VacanceLocative}, gcNomCombo, output table ttCombo by-reference).
    delete object voSyspg.
end procedure.
procedure createTypeBaremeHonoraire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voTypeBaremeHonoraire as class parametrageTypeBaremeHonoraire no-undo.
    voTypeBaremeHonoraire = new parametrageTypeBaremeHonoraire().
    voTypeBaremeHonoraire:getComboTypeBaremeHonoraire(mtoken:cRefGerance, output table ttCombo by-reference).
    delete object voTypeBaremeHonoraire.
end procedure.
procedure createNatureHonoraire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcListeCode as character no-undo. 
    define buffer pclie for pclie.
    for first pclie no-lock where pclie.tppar = "EDCRG": 
        if pclie.zon02 <> "00001" then vcListeCode = "14009". // pas de forfait locatif 
    end.      
    createSyspgParent("R_TNH", vcListeCode).
end procedure.
procedure createIndiceRevision private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer lsirv for lsirv.
    for each lsirv no-lock where lsirv.cdirv >= 0 :
        createttCombo(string(lsirv.cdirv), lsirv.lbcrt).
    end.                        
end procedure.
procedure createTypeRoleCommercialisation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo({&TYPEROLE-mandant},               outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-mandant})).
    createttCombo({&TYPEROLE-gestionnaire},          outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-gestionnaire})).
    createttCombo({&TYPEROLE-agenceGestion},         outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-agenceGestion})).
    createttCombo({&TYPEROLE-GardienBordereauCrg},   outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-GardienBordereauCrg})).
    createttCombo({&TYPEROLE-agenceDelegataire},     outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-agenceDelegataire})).
    createttCombo({&TYPEROLE-commercial},            outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-commercial})).
    createttCombo({&TYPEROLE-responsableCommercial}, outilTraduction:getLibelleProg("O_ROL", {&TYPEROLE-responsableCommercial})).
end procedure.
procedure createModePaiement private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo("00003", caps(outilTraduction:getLibelleCompta(101204))). // CHEQUE
    createttCombo("00007", caps(outilTraduction:getLibelleCompta(102480))). // VIREMENT
end procedure.
procedure createRaisonSociale private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ilibrais for ilibrais.
    for each ilibrais no-lock
        where ilibrais.soc-cd = integer(mtoken:cRefPrincipale):
        createttCombo(string(ilibrais.librais-cd, "99999"), ilibrais.lib).
    end.
end procedure.
procedure createMotifFinDisponibilite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voMotifIndisponibilite as class parametrageMotifIndisponibilite no-undo.
    voMotifIndisponibilite = new parametrageMotifIndisponibilite().
    giNumeroItem = voMotifIndisponibilite:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    delete object voMotifIndisponibilite.
end procedure.
procedure createOrigineClient private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voOrigineClient as class parametrageOrigineClient no-undo.
    voOrigineClient = new parametrageOrigineClient().
    giNumeroItem = voOrigineClient:getComboParametre(gcNomCombo, output table ttCombo by-reference).
    delete object voOrigineClient.
end procedure.
procedure createComboDesignation private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes  :
    ------------------------------------------------------------------------------*/
    define variable voDesignation as class parametrageDesignation no-undo.
    voDesignation = new parametrageDesignation().
    voDesignation:getComboDesignation(output table ttCombo by-reference).
    delete object voDesignation.
end procedure.

procedure createTypeEditionQuittance private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes  :
    ------------------------------------------------------------------------------*/
    createttCombo("00001", outilTraduction:getLibelle(100460)). // Facture
    createttCombo("00002", outilTraduction:getLibelle(108947)). // Quittance
end procedure.

procedure getInitValue:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beLabelLadb.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcValueListe as character no-undo.
    define output parameter table for ttInitValue.
    define variable vi as integer   no-undo.

    do vi = 1 to num-entries(pcValueListe, ","):
        case entry(vi, pcValueListe, ","):
            when "LastNoInter" then do:
                create ttInitValue.
                assign
                    ttInitValue.code   = "LastNoInter"
                    ttInitValue.valeur = getLastNoInter()
                .
            end.
        end case.
    end.
    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value
end procedure.
