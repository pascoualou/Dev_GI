/*------------------------------------------------------------------------
File        : extractionSignalement.p
Description : Recherche des donnees de fusion du signalement
Author(s)   : kantena - 2019/01/07
Notes       : appelé par extraction.p
derniere revue:
----------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionSignalement.i}
using bureautique.fusion.classe.fusionSignalement.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionBanque.
using parametre.pclie.parametrageRepertoireMagi.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}
{comm/include/procclot.i}

//define stream LbCheEnt.
//define stream LbCheDon.
define stream LbCheBas.
define variable vcRpTmpOut                     as character no-undo initial "C:\ADB\WORD\".


function getLibelleCle return character(piNumeroImmeuble as int64, pcTypeContrat as character, piNumeroContrat as int64, pcCodeCle as character):
    /*------------------------------------------------------------------------------
     Purpose: Retourne la cle de repartition
     Notes:
    ------------------------------------------------------------------------------*/
    define buffer clemi for clemi.

    for first clemi no-lock
        where clemi.noimm = (if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} then piNumeroImmeuble else piNumeroContrat + 10000)
          and clemi.cdcle = pcCodeCle:
        return clemi.lbcle.
    end.
    return "".
end function.

function donneInfosArticle return character(pcCodeArticle as character):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo initial "####".

    define buffer artic for artic.
    define buffer prmrg for prmrg.
    define buffer prmar for prmar.
    define buffer prmtv for prmtv.

    /* Recherche de l'article */
    for first artic no-lock
         where artic.cdart = pcCodeArticle:
        /* Recherche des infos en fonction du code regroupement */
        if Artic.cdrgt <> "00000"
        then for first prmrg no-lock
            where prmrg.cdrgt = Artic.cdrgt:
            vcRetour = substitute("&1#&2#&3##", prmrg.norub, prmrg.nossr, prmrg.nofis).
        end.
        else for first prmar no-lock
            where prmar.cdart = artic.cdart:
            vcRetour = substitute("&1#&2#&3##", prmar.norub, prmar.nossr, prmar.nofis).
        end.
        /* SY 0316/0037 */
        find first prmtv no-lock
             where prmtv.tppar = "DOMAI" 
               and prmtv.cdpar = artic.cddom no-error.
        if available prmtv then entry(4, vcRetour, "#" ) = prmtv.lbpar.
        entry(5, vcRetour, "#") = artic.lbart.       /* SY 0416/0079 */
    end.
    return vcRetour.
end function. 
 
procedure extractionSignalement:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroSignalement as integer   no-undo.
    define input        parameter piNumeroDocument    as int64     no-undo.
    define input        parameter pcTypeRole          as character no-undo.
    define input        parameter piNumeroRole        as integer   no-undo.
    define input        parameter pcListeChamp        as character no-undo.
    define input-output parameter poFusionSignalement as class fusionSignalement no-undo.

    // Variables techniques
    define variable viCompteur as integer   no-undo.
    define variable vlBloc1    as logical   no-undo.
    define variable vlBloc2    as logical   no-undo.
    define variable vcChr9     as character no-undo.
    define variable vcChr10    as character no-undo.
    define variable voAdresse  as class fusionAdresse no-undo.
    define variable voRole     as class fusionRole    no-undo.

    // Info signalement
    define variable vcTableComplInfo                       as character no-undo.
    define variable vcListeDesignationSignalement          as character no-undo.
    define variable vcListeRefArticleSignalement           as character no-undo.
    define variable vcListeQteSignalement                  as character no-undo.
    define variable vcListeDelaiSignalement                as character no-undo.
    define variable vcListeCommentaireSignalement          as character no-undo.
    define variable vcListeCleSignalement                  as character no-undo.
    define variable vcListeCleLibelleSignalement           as character no-undo.
    define variable vcListeLotsSignalement                 as character no-undo.
    define variable vcListeNatureLotsSignalement           as character no-undo.
    define variable vcListeBatLotsSignalement              as character no-undo.
    define variable vcListeEntreeLotsSignalement           as character no-undo.
    define variable vcListeEscLotsSignalement              as character no-undo.
    define variable vcListeEtageLotsSignalement            as character no-undo.
    define variable vcListePorteLotsSignalement            as character no-undo.
    define variable vcListeOccupantLotsSignalement         as character no-undo.
    define variable vcListeTelOccupantLotsSignalement      as character no-undo.
    define variable vcListeEmailOccupantLotsSignalement    as character no-undo.
    define variable vcListePortableOccupantLotsSignalement as character no-undo.  /* NP 1015/0106 */
    define variable vcListeRubArtSignalement               as character no-undo.  /* PL : 03/03/2015 (0115/0260) */
    define variable vcListeSSRubArtSignalement             as character no-undo.  /* PL : 03/03/2015 (0115/0260) */
    define variable vcListeCodeFiscArtSignalement          as character no-undo.  /* PL : 03/03/2015 (0115/0260) */
    define variable vcTableLotsSignalement                 as character no-undo.
    define variable vcTableLotsOccupantsSignalement        as character no-undo.
    define variable vcinfosArticle                         as character no-undo.
    define variable vcListeDomaiArtSignalement             as character no-undo.
    define variable vcListeLibelleArtSignalement           as character no-undo.

    //Info lot et occupant
    define variable viNumeroBailleur                       as integer   no-undo.
    define variable viNumeroContratProprietaire            as integer   no-undo.
    define variable vcTypeCoproprietaire                   as character no-undo.
    define variable NoCopUse                               as integer   no-undo.
    define variable vdaAchatLot                            as date      no-undo.
    define variable vcCodeRegroupementLot                  as character no-undo.
    define variable vcNomOccupantLot                       as character no-undo.
    define variable vdaEntreeOccupantLot                   as date      no-undo.
    define variable vcTypeOccupantLot                      as character no-undo.
    define variable vcTypeRoleOccupantLot                  as character no-undo.
    define variable viNumeroRoleOccupant                   as integer   no-undo.
    define variable vcTelephoneOccupantLot                 as character no-undo.
    define variable vcPortableOccupantLot                  as character no-undo.
    define variable vcEmailOccupantLot                     as character no-undo.
    define variable vcNumTelOcc                            as character no-undo.
    define variable vcTypeSignalePar                       as character no-undo.
    define variable viNumeroSignalePar                     as integer   no-undo.

    define buffer inter for inter.
    define buffer prmtv for prmtv.
    define buffer intnt for intnt.
    define buffer local for local.
    define buffer dtlot for dtlot.

    assign
        vcChr9  = chr(9)
        vcChr10 = chr(10)
    .
    
    output stream LbCheBas to value("C:\ADB\WORD\base.txt").
    
    message "pcListeChamp === " pcListeChamp.
    
boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-NumSignalement} or when {&FUSION-DelaiSignalement} or when "111707" 
            then do:
                if vlBloc1 then next boucleCHamp.
                assign vlBloc1 = true.
                find first inter no-lock
                     where inter.nosig = piNumeroSignalement
                       and inter.nosig > 0 no-error.             /* SY 0416/0079 */ 
                if available inter then do:
                    assign
                        poFusionSignalement:NumSignalement = trim(string(inter.nosig))
                        poFusionSignalement:NumDossierTravSignalement = (if inter.nodos > 0 then string(inter.nodos) else "")
                    .
                    find first prmtv no-lock
                         where prmtv.tppar = "DLINT"
                           and prmtv.cdpar = inter.dlint no-error.
                    if available prmtv then poFusionSignalement:DelaiSignalement = PrmTv.lbpar.
                end.
            end.
            when {&FUSION-TableSignalement}                   or when {&FUSION-ListeDesignationSignalement}  or when {&FUSION-ListeRefarticleSignalement} 
            or when {&FUSION-ListeQteSignalement}             or when {&FUSION-ListeDelaiSignalement}        or when {&FUSION-ListeCommentaireSignalement}
            or when {&FUSION-ListeCleSignalement}             or when {&FUSION-ListeCleLibelleSignalement}   or when {&FUSION-ListeLotsSignalement}
            or when {&FUSION-ListeNatureLotsSignalement}      or when {&FUSION-ListeBatLotsSignalement}      or when {&FUSION-ListeentreeLotsSignalement}
            or when {&FUSION-ListeescLotsSignalement}         or when {&FUSION-ListeetageLotsSignalement}    or when {&FUSION-ListePorteLotsSignalement}
            or when {&FUSION-ListeoccupantLotsSignalement}    or when {&FUSION-TableLotsSignalement}         or when {&FUSION-TableLotsoccupantsSignalement}
            or when {&FUSION-ListeTeloccupantLotsSignalement} or when {&FUSION-RoleSignalantSignalement}     or when {&FUSION-TitreSignalantSignalement}
            or when {&FUSION-TitreLSignalantSignalement}      or when {&FUSION-CiviliteSignalantSignalement} or when {&FUSION-NomSignalantSignalement}
            or when {&FUSION-NomCompletSignalantSignalement}  or when {&FUSION-adresseSignalantSignalement}  or when {&FUSION-SuiteadresseSignalantSignalement}
            or when {&FUSION-CodePostalSignalantSignalement}  or when {&FUSION-VilleSignalantSignalement}    or when {&FUSION-VilleCedexSignalantSignalement}
            or when {&FUSION-TelSignalantSignalement}         or when {&FUSION-PortableSignalantSignalement} or when {&FUSION-ListeemailoccupantSignalement}
            or when {&FUSION-ListeRubartSignalement}          or when {&FUSION-ListeSSRubartSignalement}     or when {&FUSION-ListeCodeFiscartSignalement}
            or when "111705" or when "111706" /* PL : 03/03/2015 (0115/0260) */
            then do:
                if vlBloc2 then next boucleCHamp.
                assign vlBloc2 = true.
                put stream LbCheBas unformatted "NoSig" vcChr9 "Réf" vcChr9 "Désignation" vcChr9 "Qté" vcChr9 "Rub" vcChr9 "ssRub" vcChr9 "Fisc" vcChr9 vcChr10.

                for each inter no-lock 
                    where inter.nosig = piNumeroSignalement
                      and inter.nosig > 0            /* SY 0216/0050 */ 
                  , first prmtv no-lock    
                    where prmtv.tppar = "DLINT"
                      and prmtv.cdpar = inter.dlint:
                    find first intnt no-lock
                         where intnt.tpcon = inter.tpcon
                           and intnt.nocon = inter.nocon
                           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
                    vcinfosArticle = DonneInfosArticle(inter.cdart).
                    assign
                         vcListeDesignationSignalement   = vcListeDesignationSignalement + string(inter.lbint,"X(120)")               + vcChr10
                         vcListeRefArticleSignalement    = vcListeRefArticleSignalement  + inter.cdart                                + vcChr10
                         vcListeQteSignalement           = vcListeQteSignalement         + montantToCharacter(inter.qtint, false)     + vcChr10
                         vcListeDelaiSignalement         = vcListeDelaiSignalement       + dateToCharacter(inter.dtcsy + prmtv.nbpar) + vcChr10
                         vcListeCommentaireSignalement   = vcListeCommentaireSignalement + inter.lbcom                                + vcChr10
                         vcListeCleSignalement           = vcListeCleSignalement         + inter.cdcle                                + vcChr10
                         vcListeRubArtSignalement        = vcListeRubArtSignalement      + entry(1, vcInfosArticle, "#")              + vcChr10
                         vcListeSSRubArtSignalement      = vcListeSSRubArtSignalement    + entry(2, vcInfosArticle, "#")              + vcChr10
                         vcListeCodeFiscArtSignalement   = vcListeCodeFiscArtSignalement + entry(3, vcInfosArticle, "#")              + vcChr10
                         vcListeDomaiArtSignalement      = vcListeDomaiArtSignalement    + entry(4, vcInfosArticle, "#")              + vcChr10
                         vcListeLibelleArtSignalement    = vcListeLibelleArtSignalement  + entry(5, vcInfosArticle, "#")              + vcChr10
                    .
                    if available intnt
                    then vcListeCleLibelleSignalement   = vcListeCleLibelleSignalement + getLibelleCle(intnt.noidt, inter.tpcon, inter.nocon, inter.cdcle) + vcChr10.

                    put stream LbCheBas unformatted inter.nosig                           vcChr9
                                                    inter.cdart                           vcChr9
                                                    string(inter.lbint,"X(120)")          vcChr9
                                                    montantToCharacter(inter.qtint,false) vcChr9
                                                    entry(1, vcInfosArticle, "#")         vcChr9
                                                    entry(2, vcInfosArticle, "#")         vcChr9
                                                    entry(3, vcInfosArticle, "#")         vcChr9
                                                    vcChr10
                    .

                    assign
                        vcTypeSignalePar   = inter.tppar
                        viNumeroSignalePar = inter.nopar
                    .
                end.

                poFusionSignalement:TableSignalement = "~"" + replace(vcRpTmpOut,"\","\\") + "base.txt~"".

                assign
                    poFusionSignalement:ListeCleSignalement        = vcListeCleSignalement
                    poFusionSignalement:ListeCleLibelleSignalement = vcListeCleLibelleSignalement
                    poFusionSignalement:ListeDomaiArtSignalement   = vcListeDomaiArtSignalement
                    poFusionSignalement:ListeLibelleArtSignalement = vcListeLibelleArtSignalement
                .

                if vcTypeSignalePar <> "" and viNumeroSignalePar <> 0 
                then do:
                    assign
                        poFusionSignalement:RoleSignalantSignalement       = (if vcTypeSignalePar = "FOU" then outilTraduction:getLibelle(100124) else outilTraduction:getLibelleProg("O_ROL", vcTypeSignalePar))
                        voRole                                             = chargeRole(vcTypeSignalePar, viNumeroSignalePar, piNumeroDocument)
                        poFusionSignalement:TitreSignalantSignalement      = voRole:Titre
                        poFusionSignalement:TitreLSignalantSignalement     = voRole:titreLettre
                        poFusionSignalement:CiviliteSignalantSignalement   = voRole:civilite
                        poFusionSignalement:NomSignalantSignalement        = voRole:nom
                        poFusionSignalement:NomCompletSignalantSignalement = voRole:nomComplet
                    .
                    voAdresse = chargeAdresse(vcTypeSignalePar, viNumeroSignalePar, piNumeroDocument).
                    assign
                        poFusionSignalement:AdresseSignalantSignalement      = voAdresse:Adresse
                        poFusionSignalement:SuiteAdresseSignalantSignalement = voAdresse:complementVoie
                        poFusionSignalement:CodePostalSignalantSignalement   = voAdresse:CodePostal
                        poFusionSignalement:VilleSignalantSignalement        = voAdresse:Ville
                        poFusionSignalement:VilleCedexSignalantSignalement   = voAdresse:Cedex
                        poFusionSignalement:TelSignalantSignalement          = voAdresse:Telephone.
                        poFusionSignalement:PortableSignalantSignalement     = voAdresse:Portable.
                    .
                end.
                

                /* Ajout SY le 17/01/2011 */
                for each dtlot no-lock
                    where dtlot.tptrt = {&TYPEINTERVENTION-signalement} 
                      and dtlot.notrt = piNumeroSignalement
                  , first local no-lock
                    where local.noloc = dtlot.noloc
                    by local.nolot:
                    assign
                        vcTypeRoleOccupantLot  = ""
                        viNumeroSignalePar     = 0
                        vcPortableOccupantLot  = ""
                        vcTelephoneOccupantLot = ""
                    .
                    run OccupLot (output vcNomOccupantLot,
                                  output vdaEntreeOccupantLot,
                                  output viNumeroBailleur,
                                  output viNumeroContratProprietaire,
                                  output vcTypeCoproprietaire,
                                  output NoCopUse,
                                  output vdaAchatLot,
                                  output vcTypeOccupantLot,
                                  output vcCodeRegroupementLot).
                    if viNumeroBailleur <> 0 
                    then assign 
                        vcTypeRoleOccupantLot = {&TYPEROLE-locataire}
                        viNumeroSignalePar    = viNumeroBailleur
                    .
                    else if vcTypeOccupantLot = "00001" /* occupant */ 
                         then assign
                             vcTypeRoleOccupantLot = vcTypeCoproprietaire
                             viNumeroSignalePar    = NoCopUse
                         .
                    if viNumeroSignalePar <> 0 then do:
                        voAdresse = chargeAdresse(vcTypeRoleOccupantLot, viNumeroSignalePar, piNumeroDocument).
                        assign
                            poFusionSignalement:TelephoneOcc   = voAdresse:Telephone
                            poFusionSignalement:PortableOcc    = voAdresse:Portable
                            poFusionSignalement:EmailOcc       = voAdresse:Mail
                            vcNumTelOcc                        = voAdresse:telephone
                        .
                    end.
                    vcListeLotsSignalement       = vcListeLotsSignalement 
                                               + (if vcListeLotsSignalement = "" then "" else vcChr10) + string(local.nolot).
                    vcListeNatureLotsSignalement = vcListeNatureLotsSignalement
                                               + (if vcListeNatureLotsSignalement = "" then "" else vcChr10) + outilTraduction:getLibelleParam("NTLOT", local.ntlot).
                    vcListeBatLotsSignalement    = vcListeBatLotsSignalement
                                               + (if vcListeBatLotsSignalement = "" then "" else vcChr10) + trim(local.cdbat).
                    vcListeEntreeLotsSignalement = vcListeEntreeLotsSignalement
                                               + (if vcListeEntreeLotsSignalement = "" then "" else vcChr10) + trim(local.lbdiv).
                    vcListeEscLotsSignalement    = vcListeEscLotsSignalement
                                               + (if vcListeEscLotsSignalement = "" then "" else vcChr10) + trim(local.cdesc).
                    vcListeEtageLotsSignalement  = vcListeEtageLotsSignalement   
                                               + (if vcListeEtageLotsSignalement = "" then "" else vcChr10) + trim(local.cdeta).
                    vcListePorteLotsSignalement  = vcListePorteLotsSignalement   
                                               + (if vcListePorteLotsSignalement = "" then "" else vcChr10) + trim(local.cdpte).
                    vcListeOccupantLotsSignalement = vcListeOccupantLotsSignalement
                                                 + (if vcListeOccupantLotsSignalement = "" then "" else vcChr10) + trim(vcNomOccupantLot).
                    vcListeTelOccupantLotsSignalement = vcListeTelOccupantLotsSignalement
                                                    + (if vcListeTelOccupantLotsSignalement = "" then "" else vcChr10) + trim(vcNumTelOcc).
                    vcListeEmailOccupantLotsSignalement = vcListeEmailOccupantLotsSignalement
                                                      + (if vcListeEmailOccupantLotsSignalement = "" then "" else vcChr10) + trim(vcEmailOccupantLot).
                    /* NP 1015/0106 */
                    vcListePortableOccupantLotsSignalement = vcListePortableOccupantLotsSignalement
                                                         + (if vcListePortableOccupantLotsSignalement = "" then "" else vcChr10) + trim(vcPortableOccupantLot).
                    vcTableLotsSignalement = vcTableLotsSignalement
                                         + (if vcTableLotsSignalement = "" then "" else vcChr10) 
                                         + string(local.nolot, ">>>>9")                          + vcChr9
                                         + string(outilTraduction:getLibelleParam("NTLOT", local.ntlot), "X(22)") + vcChr9
                                         + trim(local.cdbat)                                     + vcChr9
                                         + trim(local.lbdiv)                                     + vcChr9
                                         + trim(local.cdesc)                                     + vcChr9
                                         + trim(local.cdeta)                                     + vcChr9
                                         + trim(local.cdpte).

                    vcTableLotsOccupantsSignalement = vcTableLotsOccupantsSignalement
                                                  + (if vcTableLotsOccupantsSignalement = "" then "" else vcChr10) 
                                                  + string(local.nolot, ">>>>9")                          + vcChr9
                                                  + string(outilTraduction:getLibelleParam("NTLOT", local.ntlot), "X(18)") + vcChr9
                                                  + trim(local.cdbat)                                     + vcChr9
                                                  + trim(local.lbdiv)                                     + vcChr9
                                                  + trim(local.cdesc)                                     + vcChr9
                                                  + trim(local.cdeta)                                     + vcChr9
                                                  + trim(local.cdpte)                                     + vcChr9
                                                  + trim(local.nmocc)                                     + vcChr9
                                                  + trim(vcNumTelOcc)                                     + vcChr9
                                                  + trim(vcPortableOccupantLot)     /* NP 1015/0106 */
                    .
                end.
                assign
                    poFusionSignalement:ListeLotsSignalement                 = vcListeLotsSignalement
                    poFusionSignalement:ListeNatureLotsSignalement           = vcListeNatureLotsSignalement
                    poFusionSignalement:ListeBatLotsSignalement              = vcListeBatLotsSignalement
                    poFusionSignalement:ListeEntreeLotsSignalement           = vcListeEntreeLotsSignalement
                    poFusionSignalement:ListeEscLotsSignalement              = vcListeEscLotsSignalement
                    poFusionSignalement:ListeEtageLotsSignalement            = vcListeEtageLotsSignalement
                    poFusionSignalement:ListePorteLotsSignalement            = vcListePorteLotsSignalement
                    poFusionSignalement:ListeOccupantLotsSignalement         = vcListeOccupantLotsSignalement
                    poFusionSignalement:TableLotsSignalement                 = vcTableLotsSignalement
                    poFusionSignalement:TableLotsOccupantsSignalement        = vcTableLotsOccupantsSignalement
                    poFusionSignalement:ListeTelOccupantLotsSignalement      = vcListeTelOccupantLotsSignalement
                    poFusionSignalement:ListeEmailOccupantLotsSignalement    = vcListeEmailOccupantLotsSignalement
                    poFusionSignalement:ListePortableOccupantLotsSignalement = vcListePortableOccupantLotsSignalement /* NP 1015/0106 */
                .
            end.
            when {&FUSION-TableComplInfo} then do:

                put stream LbCheBas unformatted "NoSig" vcChr9 "Réf" vcChr9 "Désignation" vcChr9 "Qté" vcChr10.

                for each inter no-lock
                   where inter.nosig = piNumeroSignalement
                     and inter.nosig > 0           /* SY 0216/0050 */
                     and inter.cdsta = "00020"
                 , first trint no-lock
                   where trint.noint = inter.noint
                     and trint.tptrt = {&TYPEINTERVENTION-signalement}
                     and trint.notrt = inter.nosig
                     and trint.cdsta = inter.cdsta:

                    put stream LbCheBas unformatted inter.nosig                     vcChr9
                                                    inter.cdart                     vcChr9
                                                    string(inter.lbint,"X(120)")    vcChr9
                                                    montantToCharacter(inter.qtint, false) vcChr10.
                    put stream LbCheBas unformatted inter.nosig                     vcChr9
                                                    ""                              vcChr9
                                                    trint.lbcom                     vcChr9
                                                    ""                              vcChr10.
                end.
                vcTableComplInfo = "~"" + REPLACE(vcRpTmpOut,"\","\\") + "base.txt~"".

            end.
        end case.
    end.
    output STREAM LbCheBas CLOSE.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.

