/*------------------------------------------------------------------------
File        : extractionGeneral.p
Description : Recherche des donnees de fusion generale
Author(s)   : RF - 2008/04/11, kantena - 2018/01/15
Notes       :
----------------------------------------------------------------------*/
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/famille2tiers.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2adresse.i}
{preprocesseur/fusion/fusionGeneral.i}

using bureautique.fusion.classe.fusionGeneral.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionBanque.
using parametre.pclie.parametrageSEPA.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bureautique/fusion/include/fctdatin.i} /* FUNCTION Date2Inte et FUNCTION Inte2Date */
{application/include/glbsepar.i}
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

procedure extractionGeneral:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroDocument as int64               no-undo.
    define input        parameter pcListeChamp     as character           no-undo.
    define input-output parameter poFusionGeneral  as class fusionGeneral no-undo.

    /* Prélèvement SEPA */
    define variable vcLibelleZone    as character no-undo.
    define variable vdaDateDebPSEPA  as date      no-undo.
    define variable viCompteur       as integer   no-undo.
    define variable vlBloc1          as logical   no-undo.
    define variable vlBloc2          as logical   no-undo.
    define variable vlBloc3          as logical   no-undo.
    define variable vlBloc4          as logical   no-undo.
    define variable vlBloc5          as logical   no-undo.
    define variable vlBloc6          as logical   no-undo.
    define variable voRole           as class fusionRole    no-undo.
    define variable voAdresse        as class fusionAdresse no-undo.

    define buffer intnt   for intnt.
    define buffer roles   for roles.
    define buffer ctrat   for ctrat.
    define buffer ctanx   for ctanx.
    define buffer honor   for honor.
    define buffer rlctt   for rlctt.
    define buffer tache   for tache.

    define variable voParametreSEPA as class parametrageSEPA no-undo.

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-Adresse_cabinet} or when {&FUSION-Suite_Adresse_cabinet} or when {&FUSION-Code_postal_cabinet}
         or when {&FUSION-Ville_cabinet}   or when {&FUSION-TelephoneCabinet}      or when {&FUSION-FaxCabinet}
         or when {&FUSION-EmailCabinet}    or when {&FUSION-VilleCedex_cabinet}    or when {&FUSION-ComplementAdresseIdent_Cabinet}
            then do:
                if vlBloc1 then next boucleCHamp.

                assign
                    vlBloc1                                        = true
                    voAdresse                                      = chargeAdresse({&TYPEROLE-mandataire}, 1, piNumeroDocument)
                    poFusionGeneral:Adresse_cabinet                = voAdresse:adresse
                    poFusionGeneral:Suite_adresse_cabinet          = voAdresse:complementVoie
                    poFusionGeneral:Code_postal_cabinet            = voAdresse:codePostal
                    poFusionGeneral:Ville_Cabinet                  = voAdresse:ville
                    poFusionGeneral:TelephoneCabinet               = voAdresse:telephone
                    poFusionGeneral:FaxCabinet                     = voAdresse:fax
                    poFusionGeneral:EmailCabinet                   = voAdresse:mail
                    poFusionGeneral:VilleCedex_Cabinet             = voAdresse:cedex
                    poFusionGeneral:ComplementAdresseIdent_Cabinet = voAdresse:identAdresse.
                .
            end.
            when {&FUSION-Titre_cabinet} or when {&FUSION-Nom_Cabinet} or when {&FUSION-Gerant_Cabinet} /* OR when {&FUSION-}110580" */
            then do:
                if vlBloc2 then next boucleCHamp.

                assign 
                    vlBloc2                              = true
                    voRole                               = chargeRole({&TYPEROLE-mandataire}, 1, piNumeroDocument)
                    poFusionGeneral:Titre_Cabinet        = voRole:getTitre()
                    poFusionGeneral:Nom_Cabinet          = voRole:getNom()
                    poFusionGeneral:Titre_Gerant_Cabinet = voRole:getTitreBis()
                    poFusionGeneral:Nom_Gerant_Cabinet   = voRole:getNomBis()
                .
            end.
            when {&FUSION-Numero_Carte_Prof} or when {&FUSION-Date_Obtention_carte} or when {&FUSION-DatelObtentionCarte} or when {&FUSION-DateObtentionCarteLettre}
            then do:
                if vlBloc3 then next boucleCHamp.

                vlBloc3 = true.
                for first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-CarteProfessionnelle}
                      and ctrat.nocon = 1:
                    assign
                        poFusionGeneral:NumeroCarteProf          = ctrat.noree
                        poFusionGeneral:DateObtentionCarte       = dateToCharacter(ctrat.dtdeb)
                        poFusionGeneral:DatelObtentionCarte      = outilFormatage:getDateFormat(ctrat.dtdeb, "L")
                        poFusionGeneral:DateObtentionCarteLettre = outilFormatage:getDateFormat(ctrat.dtdeb, "LL")
                    .
                end.
            end.
            when {&FUSION-Lieu_obtention_carte}
            then for first intnt no-lock
                    where intnt.tpidt = {&TYPEROLE-prefecture}
                      and intnt.nocon = 1
                      and intnt.tpcon = {&TYPECONTRAT-CarteProfessionnelle}:
                 run chargeRole(intnt.tpidt, intnt.noidt, output voRole).
                 poFusionGeneral:LieuObtentionCarte = voRole:getNom().
            end.
            when {&FUSION-Banque_cabinet} or when {&FUSION-NoCompteBancaireCabinet} or when {&FUSION-NoBICCabinet}
            then do:
                if vlBloc4 then next boucleCHamp.

                vlBloc4 = true.
                {&_proparse_ prolint-nowarn(release)}
                release ctanx no-error.
                find first rlctt no-lock
                    where rlctt.tpidt = {&TYPEROLE-mandataire}
                      and rlctt.noidt = 1
                      and rlctt.tpct2 = {&TYPECONTRAT-prive} no-error.
                if available rlctt 
                then find first ctanx no-lock
                    where ctanx.tpcon = rlctt.tpct2
                      and ctanx.nocon = rlctt.noct2 no-error.
                else do:
                    find first roles no-lock
                        where roles.tprol = {&TYPEROLE-mandataire}
                          and roles.norol = 1 no-error.
                    if available roles 
                    then find first ctanx no-lock
                        where ctanx.tprol = "99999"
                          and ctanx.norol = roles.notie
                          and ctanx.tpact = "DEFAU"
                          and ctanx.tpcon = {&TYPECONTRAT-prive} no-error.
                end.
                if available ctanx
                then assign
                    poFusionGeneral:BanqueCabinet           = ctanx.lbdom
                    poFusionGeneral:NoCompteBancaireCabinet = ctanx.iban
                    poFusionGeneral:NoBICCabinet            = ctanx.bicod
                .
            end.
            when {&FUSION-Honoraire_cabinet} or when {&FUSION-Honoraire_cabinetenlettre}
            then do:
                if vlBloc5 then next boucleCHamp.

                vlBloc5 = true.
                for first tache no-lock
                    where tache.tptac = {&TYPETACHE-Honoraires}
                  , first honor no-lock
                    where honor.tphon = tache.tphon
                      and honor.cdhon = integer(tache.cdhon):
                    assign
                        poFusionGeneral:Honoraire_Cabinet         = montantToCharacter(honor.mthon, true)
                        poFusionGeneral:Honoraire_cabinetenlettre = convChiffre(honor.mthon)
                    .
                end.
            end.
            when {&FUSION-Syndicat_professionnel}
            then for first intnt no-lock
                    where intnt.tpidt = {&TYPEROLE-syndicatProfessionnel}
                      and intnt.nocon = 1
                      and intnt.tpcon = {&TYPECONTRAT-AdhesionFedeSyndicPro}:
                assign
                    voRole                              = chargeRole(intnt.tpidt, intnt.noidt, piNumeroDocument)
                    voAdresse                           = chargeAdresse(intnt.tpidt, intnt.noidt, piNumeroDocument)
                    poFusionGeneral:DescriptionSyndicat = substitute('&1, &2 &3 &4 &5',
                                                                     voRole:getNom(),
                                                                     voAdresse:adresse,
                                                                     voAdresse:complementVoie,
                                                                     voAdresse:codePostal,
                                                                     voAdresse:ville)
                .
            end.
            when {&FUSION-DescriptionGarant}
            then for first intnt no-lock
                    where intnt.tpidt = {&TYPEROLE-mutuelleCaution}
                      and intnt.nocon = 1:
                assign
                    voRole                            = chargeRole   (intnt.tpidt, intnt.noidt, piNumeroDocument)
                    voAdresse                         = chargeAdresse(intnt.tpidt, intnt.noidt, piNumeroDocument)
                    poFusionGeneral:DescriptionGarant = substitute('&1, &2 &3 &4 &5',
                                                                   voRole:nom,
                                                                   voAdresse:adresse,
                                                                   voAdresse:complementVoie,
                                                                   voAdresse:codePostal,
                                                                   voAdresse:ville)
                .
            end.
            when {&FUSION-DatePassagePrelSEPACopropriete} or when {&FUSION-DelaiNotifPrelSEPACopropriete} or when {&FUSION-NomReclamPrelSEPACopropriete} 
         or when {&FUSION-NomModifPrelSEPACopropriete}    or when {&FUSION-DatePassagePrelSEPAGerance}    or when {&FUSION-DelaiNotifPrelSEPAGerance}    
         or when {&FUSION-NomReclamPrelSEPAGerance}       or when {&FUSION-NomModifPrelSEPAGerance}
            then do:
                if vlBloc6 then next boucleCHamp.

                assign
                    vlBloc6         = true
                    voParametreSEPA = new parametrageSEPA()
                .
                if voParametreSEPA:isOuvert()
                then do:
                    /* Gérance */
                    vdaDateDebPSEPA = if num-entries(voParametreSEPA:zon03, "|") >= 2 
                                      then integer2Date(integer(entry(1, voParametreSEPA:zon03, "|")))     /* AAAAMMJJ -> DATE */
                                      else ?.
                    if num-entries(voParametreSEPA:zon05, "|") >= 2
                    then poFusionGeneral:DelaiNotifPrelSEPAGerance = entry(1, voParametreSEPA:zon05, "|").  /* Nbj avant notification SEPA  gérance */
                    assign
                        poFusionGeneral:DatePassagePrelSEPAGerance = dateToCharacter(vdaDateDebPSEPA)
                        vcLibelleZone                              = entry(1, voParametreSEPA:zon07, "|")
                        poFusionGeneral:NomReclamPrelSEPAGerance   = substitute('&1 &2', trim(entry(1, vcLibelleZone, separ[2])), trim(entry(2, vcLibelleZone, separ[2])))
                        vcLibelleZone                              = entry(1, voParametreSEPA:zon08, "|")
                        poFusionGeneral:NomModifPrelSEPAGerance    = substitute('&1 &2', trim(entry(1, vcLibelleZone, separ[2])), trim(entry(2, vcLibelleZone, separ[2])))
                    /* Copro */
                        vdaDateDebPSEPA = if num-entries(voParametreSEPA:zon03, "|") >= 2
                                          then integer2Date(integer(entry(2, voParametreSEPA:zon03 , "|")))  /* AAAAMMJJ -> DATE */
                                          else ?
                    .
                    if num-entries(voParametreSEPA:zon05, "|" ) >= 2
                    then poFusionGeneral:DelaiNotifPrelSEPACopropriete = entry(2, voParametreSEPA:zon05, "|").
                    assign
                        poFusionGeneral:DatePassagePrelSEPACopropriete = dateToCharacter(vdaDateDebPSEPA)
                        vcLibelleZone                                  = entry(2, voParametreSEPA:zon07, "|")
                        poFusionGeneral:NomReclamPrelSEPACopropriete   = trim(entry(1, vcLibelleZone , separ[2])) + " " + trim(entry(2, vcLibelleZone, separ[2]))
                        vcLibelleZone                                  = entry(2, voParametreSEPA:zon08, "|")
                        poFusionGeneral:NomModifPrelSEPACopropriete    = trim(entry(1, vcLibelleZone, separ[2])) + " " + trim(entry(2, vcLibelleZone, separ[2]))
                    .
                end.
            end.
        end case.
    end.
    delete object voParametreSEPA no-error.
    delete object voAdresse       no-error.
    delete object voRole          no-error.

end procedure.
