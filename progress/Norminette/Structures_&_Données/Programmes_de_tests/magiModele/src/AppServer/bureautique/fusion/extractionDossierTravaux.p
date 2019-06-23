/*-----------------------------------------------------------------------------
File        : extractionDossierTravaux.p
Description : Recherche des donnees de fusion dossier travaux
Author(s)   : KANTENA - 2018/09/04
Notes       : origine dostrvx.p
-----------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionDossierTravaux.i}
{preprocesseur/listeRubQuit2TVA.i}

using bureautique.fusion.classe.fusionDossierTravaux.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionBanque.
using bureautique.fusion.classe.fusionRole.
using parametre.pclie.parametrageRepertoireMagi.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}
{comm/include/tantiemeMandat.i}

procedure extractionDossierTravaux:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroDossier  as integer   no-undo.
    define input        parameter piNumeroDocument as integer   no-undo.
    define input        parameter piNumeroMandat   as integer   no-undo.
    define input        parameter pcTypeRole       as character no-undo.
    define input        parameter piNumeroRole     as integer   no-undo.
    define input        parameter pcListeChamp     as character no-undo.
    define input-output parameter poFusionDossierTravaux as class fusionDossierTravaux no-undo.

    /* Information sur le dossier travaux */
    define variable vdaEchTrvxTreso            as character no-undo.
    define variable vcLibelleEchTrvxTreso      as character no-undo.
    define variable vcMontantEchTrvxTreso      as character no-undo.
    define variable vcLibelleTantiemeTrvxTreso as character no-undo.
    define variable vcMontantTantiemeTrvxTreso as character no-undo.
    define variable vdMontantTantieme          as decimal   no-undo.
    define variable vdMtTotApp                 as decimal   no-undo.
    define variable vcCharSep                  as character no-undo.
    define variable viCompteur                 as integer   no-undo.
    define variable vlBloc1                    as logical   no-undo.
    define variable vlBloc2                    as logical   no-undo.
    define variable vlBloc3                    as logical   no-undo.
    define variable vlBloc4                    as logical   no-undo.

    vcCharSep = chr(10).

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-LbAppTrvxTreso} or when {&FUSION-NoDosTrvx} then do:
                if vlBloc1 then next boucleCHamp.
                assign
                    vlBloc1                               = true
                    poFusionDossierTravaux:LbAppTrvxTreso = ""
                    poFusionDossierTravaux:NoDosTrvx      = if piNumeroDossier > 0 then string(piNumeroDossier) else ""
                .
            end.
            when {&FUSION-MtappTrvxTreso}      or when {&FUSION-LbechTrvxTreso}      or when {&FUSION-MtechTrvxTreso}
         or when {&FUSION-LbTantiemeTrvxTreso} or when {&FUSION-MtTantiemeTrvxTreso} or when {&FUSION-DtechTrvxTreso} then do:
                if vlBloc2 then next boucleCHamp.
                assign
                    vlBloc2    = true
                    vdMtTotApp = 0
                .
                find first ctrat no-lock
                     where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                       and ctrat.nocon = piNumeroMandat no-error.
                if available ctrat then do:

                    /* Calcul des indivisions de tout le mandat */
                    run comm/lst_indi.p (ctrat.nocon).

                    /* Mdt avec Indivision / CoIndivision / Mdt Location avec Indivision */
                    if lookup(ctrat.ntcon, "03030,03046,03093") > 0 then do:
                        for each intnt no-lock
                            where intnt.tpidt = "00016"
                              and intnt.tpcon = ctrat.tpcon
                              and intnt.nocon = ctrat.nocon
                              and intnt.noidt = piNumeroRole:
                            find first ttTantiemeMandat no-lock
                                 where ttTantiemeMandat.imdt = ctrat.nocon
                                   and ttTantiemeMandat.iNumeroIndivisaire = intnt.noidt no-error.
                            if available ttTantiemeMandat then do:
                                for each doset no-lock
                                    where doset.tpcon = ctrat.tpcon
                                      and doset.nocon = ctrat.nocon
                                      and doset.nodos = piNumeroDossier
                                  ,  each dosdt no-lock
                                    where dosdt.noidt = doset.noidt
                                      and dosdt.cdapp = ""
                                  , first dosap no-lock
                                    where dosap.tpcon = doset.tpcon
                                      and dosap.nocon = doset.nocon
                                      and dosap.nodos = doset.nodos
                                      and dosap.noapp = dosdt.noapp
                                    by dosap.dtapp :
                                    assign
                                        vcLibelleEchTrvxTreso = (if vcLibelleEchTrvxTreso = ""
                                                                 then dosdt.lbapp[1]
                                                                 else vcLibelleEchTrvxTreso + vcCharSep + dosdt.lbapp[1])
                                        vcLibelleTantiemeTrvxTreso = (if vcLibelleTantiemeTrvxTreso = ""
                                                                      then ttTantiemeMandat.lib_calcul
                                                                      else vcLibelleTantiemeTrvxTreso + vcCharSep + ttTantiemeMandat.lib_calcul)
                                        vdMontantTantieme      = (if ttTantiemeMandat.iDen_reel <> 0
                                                                 then ((dosdt.mtapp * ttTantiemeMandat.iNum_reel) / ttTantiemeMandat.iDen_reel)
                                                                 else 0)
                                        vdMtTotApp             = vdMtTotApp + vdMontantTantieme
                                        vcMontantEchTrvxTreso  = (if vcMontantEchTrvxTreso = ""
                                                                  then montantToCharacter(dosdt.mtapp, true)
                                                                  else vcMontantEchTrvxTreso + vcCharSep + montantToCharacter(dosdt.mtapp, true))
                                        vdaEchTrvxTreso        = (if vdaEchTrvxTreso = ""
                                                                  then "le " + dateToCharacter(dosap.dtapp)
                                                                  else vdaEchTrvxTreso + vcCharSep + "le " + dateToCharacter(dosap.dtapp))
                                        vcMontantTantiemeTrvxTreso = (if vcMontantTantiemeTrvxTreso = "" 
                                                                      then montantToCharacter(vdMontantTantieme, true)
                                                                      else vcMontantTantiemeTrvxTreso + vcCharSep + montantToCharacter(vdMontantTantieme, true))
                                    .
                                end.
                            end.
                        end.
                    end.
                    else do:
                        for each doset no-lock
                            where doset.tpcon = ctrat.tpcon
                              and doset.nocon = ctrat.nocon
                              and doset.nodos = piNumeroDossier
                           , each dosdt no-lock
                            where dosdt.noidt = doset.noidt
                              and dosdt.cdapp = ""
                          , first dosap no-lock
                            where dosap.tpcon = doset.tpcon
                              and dosap.nocon = doset.nocon
                              and dosap.nodos = doset.nodos
                              and dosap.noapp = dosdt.noapp
                            by dosap.dtapp:
                            assign
                                vcLibelleEchTrvxTreso      = (if vcLibelleEchTrvxTreso = ""
                                                              then dosdt.lbapp[1]
                                                              else vcLibelleEchTrvxTreso + vcCharSep + dosdt.lbapp[1])
                                vcLibelleTantiemeTrvxTreso = (if vcLibelleTantiemeTrvxTreso = ""
                                                              then ""
                                                              else vcLibelleTantiemeTrvxTreso + vcCharSep + "")
                                vcMontantEchTrvxTreso      = (if vcMontantEchTrvxTreso = ""
                                                              then ""
                                                              else vcMontantEchTrvxTreso + vcCharSep + "")
                                vdMtTotApp                 = vdMtTotApp + dosdt.mtapp
                                vcMontantTantiemeTrvxTreso = (if vcMontantTantiemeTrvxTreso = ""
                                                              then montantToCharacter(dosdt.mtapp, true)
                                                              else vcMontantTantiemeTrvxTreso + vcCharSep + montantToCharacter(dosdt.mtapp, true))
                                poFusionDossierTravaux:DtEchTrvxTreso = (if poFusionDossierTravaux:DtEchTrvxTreso = ""
                                                                         then "le " + dateToCharacter(dosap.dtapp)
                                                                         else poFusionDossierTravaux:DtEchTrvxTreso + vcCharSep + "le " + dateToCharacter(dosap.dtapp))
                            .
                        end.
                    end.
                    poFusionDossierTravaux:MtAppTrvxTreso  = montantToCharacter(vdMtTotApp, true).
                end.
                assign
                    poFusionDossierTravaux:LbEchTrvxTreso      = vcLibelleEchTrvxTreso
                    poFusionDossierTravaux:MtEchTrvxTreso      = vcMontantEchTrvxTreso
                    poFusionDossierTravaux:LbTantiemeTrvxTreso = vcLibelleTantiemeTrvxTreso
                    poFusionDossierTravaux:MtTantiemeTrvxTreso = vcMontantTantiemeTrvxTreso
                .
            end.
        end case.
    end.

end procedure.