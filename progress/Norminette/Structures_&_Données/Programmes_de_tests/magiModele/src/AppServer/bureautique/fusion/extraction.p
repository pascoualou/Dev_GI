/*-----------------------------------------------------------------------------
File        : extract.p
Purpose     : 
Description : 
Author(s)   : 
Created     : Tue Oct 24 11:09:50 CEST 2017
Notes       :
Derniere revue: 2018/03/20 - phm
-----------------------------------------------------------------------------*/
using parametre.pclie.parametragePayePegase.
using bureautique.fusion.classe.*.
using System.Collections.ArrayList.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}

define variable viCpt                as integer   no-undo.
define variable giNiveauPaiePegase   as integer   no-undo. /* SY 0114/0244 */
define variable giNumeroGarant       as integer   no-undo.
define variable giNumeroOrdreService as integer   no-undo.
define variable giNumeroTraitement   as integer   no-undo.
define variable giNumeroMandat       as integer   no-undo.
define variable giNumeroSalarie      as integer   no-undo.
define variable giNumeroSyndic       as integer   no-undo.
define variable gcTypeRoleSalarie    as character no-undo.
define variable gcTypeContratSalarie as character no-undo.
define variable giNumeroImmeuble     as integer   no-undo.
define variable giNumeroLocal        as integer   no-undo.
define variable giNumeroBail         as integer   no-undo.

define variable goFusionAssurance    as class bureautique.fusion.classe.fusionAssurance.
define variable goFusionBail         as class bureautique.fusion.classe.fusionBail.
define variable goFusionDestinataire as class bureautique.fusion.classe.fusionDestinataire.
define variable goFusionDocument     as class bureautique.fusion.classe.fusionDocument.
define variable goFusionGarant       as class bureautique.fusion.classe.fusionGarant.
define variable goFusionGeneral      as class bureautique.fusion.classe.fusionGeneral.
define variable goFusionImmeuble     as class bureautique.fusion.classe.fusionImmeuble.
define variable goFusionLot          as class bureautique.fusion.classe.fusionLot.
define variable goFusionMandat       as class bureautique.fusion.classe.fusionMandat.
define variable goFusionOrdreService as class bureautique.fusion.classe.fusionOrdreservice.
define variable goFusionSalarie      as class bureautique.fusion.classe.fusionSalarie.
define variable goFusionSyndic       as class bureautique.fusion.classe.fusionSyndic.

define variable ghExtractionAssurance    as handle no-undo.
define variable ghExtractionBail         as handle no-undo.
define variable ghExtractionDestinataire as handle no-undo.
define variable ghExtractionDocument     as handle no-undo.
define variable ghExtractionGarant       as handle no-undo.
define variable ghExtractionGeneral      as handle no-undo.
define variable ghExtractionImmeuble     as handle no-undo.
define variable ghExtractionMandat       as handle no-undo.
define variable ghExtractionOrdreService as handle no-undo.
define variable ghExtractionLot          as handle no-undo.
define variable ghExtractionSalarie      as handle no-undo.
define variable ghExtractionSyndic       as handle no-undo.

function extraction returns fusionWord (piNumeroDocument as integer, pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/

    define variable vcListechamp   as character no-undo.
    define variable voFusionGlobal as class fusionWord no-undo.
    define variable voPayePegaze   as class parametre.pclie.parametragePayePegase no-undo.

    define buffer docum for docum.
    define buffer lidoc for lidoc.
    define buffer refcl for refcl.
    define buffer champ for champ.

    assign
        voPayePegaze = new parametragePayePegase()
        giNiveauPaiePegase = voPayePegaze:iNiveauPaiePegase
    .
    find first docum no-lock
         where docum.nodoc = piNumeroDocument no-error.
    if available docum then do:
        /* Recherche des critere supplementaire */
        giNumeroTraitement = docum.notrt.
        for each lidoc no-lock where lidoc.nodoc = piNumeroDocument:
            viCpt = integer(lidoc.tpidt) no-error.
            if not error-status:error and viCpt >= 1000 
            then do:
                case tpidt:
                    when {&TYPECONTRAT-mandat2Syndic}  then giNumeroSyndic = lidoc.noidt.
                    when {&TYPECONTRAT-mandat2Gerance} then giNumeroMandat = lidoc.noidt.
                    when {&TYPECONTRAT-bail}           then giNumeroBail   = lidoc.noidt.
                    when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then do:       /* SY 0114/0244 */
                        assign
                            giNumeroSalarie      = lidoc.noidt
                            gcTypeContratSalarie = lidoc.tpidt
                        .
                        if giNumeroSalarie > 999999 then gcTypeContratSalarie = {&TYPECONTRAT-SalariePegase}. /* Ajout SY le 08/02/2017 - pb lidoc avec mauvais type contrat à trouver (erreur chez SGA, OS mandat 9040) */
                        gcTypeRoleSalarie = (if gcTypeContratSalarie = {&TYPECONTRAT-SalariePegase} then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie}).
                    end.
                    when {&TYPEINTERVENTION-ordre2service} then giNumeroOrdreService = lidoc.noidt.
                    when {&TYPEBIEN-immeuble}              then giNumeroImmeuble     = lidoc.noidt.
                    when {&TYPEBIEN-lot}                   then giNumeroLocal        = lidoc.noidt.
                    when {&TYPETACHE-garantieLocataire}    then giNumeroGarant       = lidoc.noidt. /* attention tache.noita 1er garant */
                end.
            end.
        end.
        /* Reference Client */
        find first refcl no-lock
             where refcl.nodot = docum.nodot no-error.
        if available refcl
        then for each refcl no-lock
            where refcl.nodot = docum.nodot
          , first champ no-lock
            where champ.nochp = refcl.nochp
            break by refcl.nodot by champ.cdcrt:
            if first-of(champ.cdcrt) then vcListechamp = "".

            vcListechamp = substitute('&1,&2', vcListechamp, champ.lbchp).

            if last-of(cdcrt) then run parcours(champ.cdcrt, trim(vcListechamp, ","), piNumeroDocument, pcTypeRole, piNumeroRole).
        end.
        else for each refgi no-lock /* Reference GI */
            where refgi.nodot = docum.nodot
          , first champ no-lock
            where champ.nochp = refgi.nochp
            break by refgi.nodot by champ.cdcrt:
            if first-of(champ.cdcrt) then vcListechamp = "".

            vcListechamp = substitute('&1,&2', vcListechamp, champ.lbchp).

            if last-of(cdcrt) then run parcours (champ.cdcrt, trim(vcListechamp, ","), piNumeroDocument, pcTypeRole, piNumeroRole).
        end.
    end.
    if valid-object(voPayePegaze) then delete object voPayePegaze.

    // Création de l'objet de fusion global
    assign
        voFusionGlobal = new fusionWord()
    .
/* DEBUG
message "VALID-object(goFusionAssurance) ------------------------" valid-object(goFusionAssurance).
message "VALID-object(goFusionBail) -----------------------------" valid-object(goFusionBail).
message "VALID-object(goFusionDestinataire) ---------------------" valid-object(goFusionDestinataire).
message "VALID-object(goFusionDocument) -------------------------" valid-object(goFusionDocument).
message "VALID-object(goFusionGarant)----------------------------" valid-object(goFusionGarant).
message "VALID-object(goFusionGeneral) --------------------------" valid-object(goFusionGeneral).
message "VALID-object(goFusionImmeuble) -------------------------" valid-object(goFusionImmeuble).
message "VALID-object(goFusionLot) ------------------------------" valid-object(goFusionLot).
message "VALID-object(goFusionMandat) ---------------------------" valid-object(goFusionMandat).
message "VALID-object(goFusionOrdreService) ---------------------" valid-object(goFusionOrdreService).
message "VALID-object(goFusionSalarie) --------------------------" valid-object(goFusionSalarie).
message "VALID-object(goFusionSyndic) ---------------------------" valid-object(goFusionSyndic).
*/
    if valid-object(goFusionAssurance)    then voFusionGlobal:merge(goFusionAssurance).
    if valid-object(goFusionBail)         then voFusionGlobal:merge(goFusionBail).
    if valid-object(goFusionDestinataire) then voFusionGlobal:merge(goFusionDestinataire).
    if valid-object(goFusionDocument)     then voFusionGlobal:merge(goFusionDocument).
    if valid-object(goFusionGarant)       then voFusionGlobal:merge(goFusionGarant).
    if valid-object(goFusionGeneral)      then voFusionGlobal:merge(goFusionGeneral).
    if valid-object(goFusionImmeuble)     then voFusionGlobal:merge(goFusionImmeuble).
    if valid-object(goFusionLot)          then voFusionGlobal:merge(goFusionLot).
    if valid-object(goFusionMandat)       then voFusionGlobal:merge(goFusionMandat).
    if valid-object(goFusionOrdreService) then voFusionGlobal:merge(goFusionOrdreService).
    if valid-object(goFusionSalarie)      then voFusionGlobal:merge(goFusionSalarie).
    if valid-object(goFusionSyndic)       then voFusionGlobal:merge(goFusionSyndic).

    return voFusionGlobal.

end function.

procedure parcours:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcCritere        as character no-undo.
    define input parameter pcListechamp     as character no-undo.
    define input parameter piNumeroDocument as int64     no-undo.
    define input parameter pcTypeRole       as character no-undo.
    define input parameter piNumeroRole     as integer   no-undo.

//    if Champ.tpchp = "00003" then run CodeCalcul.
//    else do:


        case pcCritere:
//            when "00000" then run CodeRemplir.
            when "00001" then do:
                goFusionGeneral = new fusionGeneral().
                run bureautique/fusion/extractionGeneral.p persistent set ghExtractionGeneral.
                run getTokenInstance  in ghExtractionGeneral(mtoken:JSessionId).
                run extractionGeneral in ghExtractionGeneral(piNumeroDocument, pcListechamp, input-output goFusionGeneral).
                run destroy in ghExtractionGeneral.
            end.
            when "00002" then do:
                goFusionMandat = new fusionMandat().
                run bureautique/fusion/extractionMandat.p persistent set ghExtractionMandat.
                run getTokenInstance in ghExtractionMandat(mtoken:JSessionId).
                run extractionMandat in ghExtractionMandat (giNumeroMandat, piNumeroDocument, pcListechamp, input-output goFusionMandat).
                run destroy in ghExtractionMandat.
            end.
            when "00003" then do:
                goFusionBail = new fusionBail().
                run bureautique/fusion/extractionBail.p persistent set ghExtractionBail.
                run getTokenInstance in ghExtractionBail(mtoken:JSessionId).
                run extractionBail   in ghExtractionBail (giNumeroBail, piNumeroDocument, pcTypeRole, piNumeroRole, giNumeroTraitement, pcListechamp, input-output goFusionBail).
                run destroy in ghExtractionBail.
            end.
            when "00004" then do:
                goFusionImmeuble = new fusionImmeuble().
                run bureautique/fusion/extractionImmeuble.p persistent set ghExtractionImmeuble.
                run getTokenInstance   in ghExtractionImmeuble(mtoken:JSessionId).
                run extractionImmeuble in ghExtractionImmeuble (giNumeroImmeuble, piNumeroDocument, pcTypeRole, piNumeroRole, pcListechamp, input-output goFusionImmeuble).
                run destroy in ghExtractionImmeuble.
            end.
            when "00005" then do:
                goFusionLot = new fusionLot().
                run bureautique/fusion/extractionLot.p persistent set ghExtractionLot.
                run getTokenInstance in ghExtractionLot(mtoken:JSessionId).
                run extractionLot    in ghExtractionLot(giNumeroLocal, piNumeroDocument, pcListechamp, input-output goFusionLot).
                run destroy in ghExtractionLot.
            end.
            when "00006" then do:
                goFusionDocument = new fusionDocument().
                run bureautique/fusion/extractionDocument.p persistent set ghExtractionDocument.
                run getTokenInstance   in ghExtractionDocument(mtoken:JSessionId).
                run extractionDocument in ghExtractionDocument(piNumeroDocument, pcListechamp, input-output goFusionDocument).
                run destroy in ghExtractionDocument.
            end.
            when "00007" then do:
                goFusionDestinataire = new fusionDestinataire().
                run bureautique/fusion/extractionDestinataire.p persistent set ghExtractionDestinataire.
                run getTokenInstance       in ghExtractionDestinataire (mtoken:JSessionId).
                run extractionDestinataire in ghExtractionDestinataire (piNumeroDocument, pcTypeRole, piNumeroRole, pcListechamp, input-output goFusionDestinataire).
                run destroy in ghExtractionDestinataire.
            end.
            when "00008" then do:
                goFusionSalarie = new fusionSalarie().
                run bureautique/fusion/extractionSalarie.p persistent set ghExtractionSalarie.
                run getTokenInstance  in ghExtractionSalarie (mtoken:JSessionId).
                run extractionSalarie in ghExtractionSalarie (giNumeroSalarie, piNumeroDocument, gcTypeContratSalarie, gcTypeRoleSalarie, pcListechamp, input-output goFusionSalarie).
                run destroy in ghExtractionSalarie.
            end.
            when "00009" then do:
                goFusionAssurance = new fusionAssurance().
                run bureautique/fusion/extractionAssurance.p persistent set ghExtractionAssurance.
                run getTokenInstance    in ghExtractionAssurance(mtoken:JSessionId).
                run extractionAssurance in ghExtractionAssurance(giNumeroSyndic, piNumeroDocument, giNumeroMandat, pcListechamp, input-output goFusionAssurance).
                run destroy in ghExtractionAssurance.
            end.
//            when "00010" then run extractionTitreCopropriete.
            when "00011" then do:
                goFusionSyndic = new fusionSyndic().
                run bureautique/fusion/extractionSyndic.p persistent set ghExtractionSyndic.
                run getTokenInstance in ghExtractionSyndic(mtoken:JSessionId).
                run extractionSyndic in ghExtractionSyndic(giNumeroSyndic, piNumeroDocument, pcListechamp, input-output goFusionSyndic).
                run destroy in ghExtractionSyndic.
            end.
//            when "00012" then run extractionOrdreSociaux.
//            when "00013" then run extractionMutation.
//            when "00014" then run extractionDossierMutation.
//            when "00015" then run extractionContratFournisseur.
//            when "00016" then run extractionPreBail.p.
//            when "00017" then run extractionSignalement.p.
//            when "00018" then run extractionDevis.p.
            when "00019" then do:
                goFusionOrdreService = new fusionOrdreService().
                run bureautique/fusion/extractionOrdreService.p persistent set ghExtractionOrdreService.
                run getTokenInstance       in ghExtractionOrdreService (mtoken:JSessionId).
                run extractionOrdreService in ghExtractionOrdreService (giNumeroOrdreService, piNumeroDocument, pcListechamp, input-output goFusionOrdreService).
                run destroy in ghExtractionOrdreService.
            end.
//            when "00020" then run extractionAccordReglement.
//            when "00021" then run extractionAccessoire.
            when "00022" then do:
                goFusionGarant = new fusionGarant().
                run bureautique/fusion/extractionGarant.p persistent set ghExtractionGarant.
                run getTokenInstance in ghExtractionGarant (mtoken:JSessionId).
                run extractionGarant in ghExtractionGarant (giNumeroGarant, giNumeroBail, piNumeroDocument, piNumeroRole, pcListechamp, input-output goFusionGarant).
                run destroy in ghExtractionGarant.
            end. 
//            when "00023" then run extractionEvenemen.p.
//            when "00024" then run extractionFiclocat.p.
//            when "00025" then run extractionMandatLocataire.p.
//            when "00026" then run extractionDossierTravaux.p.
        end case.
//    end.

end procedure.
