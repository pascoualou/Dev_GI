/*------------------------------------------------------------------------
File        : extractionDevis.p
Description : Recherche des donnees de fusion de la demande de devis
Author(s)   : kantena - 2019/01/07
Notes       : appelé par extraction.p
derniere revue:
----------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/fusion/fusionDevis.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}

using bureautique.fusion.classe.fusionDevis.
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
//define stream LbCheBas.

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

procedure extractionDevis:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroDevis      as integer   no-undo.
    define input        parameter piNumeroDocument   as int64     no-undo.
    define input        parameter pcTypeRole         as character no-undo.
    define input        parameter piNumeroRole       as integer   no-undo.
    define input        parameter pcListeChamp       as character no-undo.
    define input-output parameter poFusionDevis      as class fusionDevis no-undo.

    // variables techniques
    define variable viCompteur as integer   no-undo.
    define variable vlBloc1    as logical   no-undo.
    define variable vlBloc2    as logical   no-undo.
    define variable vcChr9     as character no-undo.
    define variable vcChr10    as character no-undo.
    define variable vcLbTmpPdt as character no-undo.
    define variable vcRpTmpOut as character no-undo.

    // Information sur le devis
    define variable vcTableDevis                     as character no-undo.
    define variable CondPaiemDevis                   as character no-undo.
    define variable CondPortDevis                    as character no-undo.
    define variable vcListeDesignationDevis          as character no-undo.
    define variable vcListeRefArticleDevis           as character no-undo.
    define variable vcListeQteDevis                  as character no-undo.
    define variable vcListeDelaiDevis                as character no-undo.
    define variable vcListeCommentaireDevis          as character no-undo.
    define variable vcListePUDevis                   as character no-undo.
    define variable vcListeTxRemiseDevis             as character no-undo.
    define variable vcListeMontantDevis              as character no-undo.
    define variable vcListeCleDevis                  as character no-undo.
    define variable vcListeCleLibelleDevis           as character no-undo.
    define variable vcListeLotsDevis                 as character no-undo.
    define variable vcListeNatureLotsDevis           as character no-undo.
    define variable vcListeBatLotsDevis              as character no-undo.
    define variable vcListeEntreeLotsDevis           as character no-undo.
    define variable vcListeEscLotsDevis              as character no-undo.
    define variable vcListeEtageLotsDevis            as character no-undo.
    define variable vcListePorteLotsDevis            as character no-undo.
    define variable vcListeOccupantLotsDevis         as character no-undo.
    define variable vcListeTelOccupantLotsDevis      as character no-undo.
    define variable vcListeEmailOccupantLotsDevis    as character no-undo.
    define variable vcListePortableOccupantLotsDevis as character no-undo.    /* NP 1015/0106 */
    define variable vcListeRubArtDevis               as character no-undo.    /* PL : 03/03/2015 (0115/0260) */
    define variable vcListeSSRubArtDevis             as character no-undo.    /* PL : 03/03/2015 (0115/0260) */
    define variable vcListeCodeFiscArtDevis          as character no-undo.    /* PL : 03/03/2015 (0115/0260) */
    define variable vcTableLotsDevis                 as character no-undo.
    define variable vcTableLotsOccupantsDevis        as character no-undo.
    define variable vcListeDomaiArtDevis             as character no-undo.
    define variable vcListeLibelleArtDevis           as character no-undo.
    define variable dPUDevis                         as decimal   no-undo.
    define variable dTxRemiseDevis                   as decimal   no-undo.
    define variable dMontantDevis                    as decimal   no-undo.

    // Info lot et occupant
    define variable viNoLigLot                  as integer   no-undo.
    define variable vcinfosArticle              as character no-undo.
    define variable viNumeroBailleur            as integer   no-undo.
    define variable viNumeroContratProprietaire as integer   no-undo.
    define variable vcTypeCoproprietaire        as character no-undo.
    define variable NoCopUse                    as integer   no-undo.
    define variable vdaAchatLot                 as date      no-undo.
    define variable vcCodeRegroupementLot       as character no-undo.
    define variable vcNomOccupantLot            as character no-undo.
    define variable vdaEntreeOccupantLot        as date      no-undo.
    define variable vcTypeOccupantLot           as character no-undo.
    define variable vcTypeRoleOccupantLot       as character no-undo.
    define variable viNumeroRoleOccupantLot     as integer   no-undo.
    define variable vcTelephoneOccupantLot      as character no-undo.
    define variable vcPortableOccupantLot       as character no-undo.
    define variable NumTelOcc                   as character no-undo.
    define variable vcEmailOccupantLot          as character no-undo.

    define variable voAdresse  as class fusionAdresse no-undo.
    define variable voRole     as class fusionRole    no-undo.

    define buffer devis    for devis.
    define buffer dtdev    for dtdev.
    define buffer prmtv    for prmtv.
    define buffer CcptCol  for CcptCol.
    define buffer ilibport for ilibport.
    define buffer iregl    for iregl.
    define buffer ifour    for ifour.
    define buffer inter    for inter.
    define buffer local    for local.
    define buffer tarif    for tarif.
    define buffer dtlot    for dtlot.
    define buffer bintnt   for intnt.
    define buffer bbintnt  for intnt.

    assign
        vcChr9  = chr(9)
        vcChr10 = chr(10)
    .

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-NumDevis}                     or when {&FUSION-DateCreationDevis}       or when {&FUSION-DateLCreationDevis}
            or when {&FUSION-NumFourniDevis}            or when {&FUSION-DelaiDevis}              or when {&FUSION-CondPaiemDevis}
            or when {&FUSION-CondPortDevis}             or when {&FUSION-DateCreationDevisLettre} or when {&FUSION-ListeLotsDevis} 
            or when {&FUSION-ListeNatureLotsDevis}      or when {&FUSION-ListeBatLotsDevis}       or when {&FUSION-ListeentreeLotsDevis}
            or when {&FUSION-ListeescLotsDevis}         or when {&FUSION-ListeetageLotsDevis}     or when {&FUSION-ListePorteLotsDevis}
            or when {&FUSION-ListeoccupantLotsDevis}    or when {&FUSION-TableLotsDevis}          or when {&FUSION-TableLotsoccupantsDevis}
            or when {&FUSION-ListeTeloccupantLotsDevis} or when {&FUSION-110956}                  or when {&FUSION-110957}
            or when {&FUSION-110958}                    or when {&FUSION-110959}                  or when {&FUSION-110960}
            or when {&FUSION-110961}                    or when {&FUSION-110962}                  or when {&FUSION-110963} 
            or when {&FUSION-110964}                    or when {&FUSION-110965}                  or when {&FUSION-110966}
            or when {&FUSION-TelSignalantDevis}         or when {&FUSION-PortableSignalantDevis}  or when {&FUSION-ListeEmailoccupantLotDevis}
            or when {&FUSION-ComplementAdresseIdentSignalantDevis}     /* PL : 11/01/2016 - (Fiche : 0711/0069) */
            or when {&FUSION-NumDossierTravDevis}     /* SY 0416/0079 */ 
            then do:
                if vlBloc1 then next boucleCHamp.
                assign vlBloc1 = true.

                for first devis no-lock 
                    where devis.nodev = piNumeroDevis
                  , first dtdev no-lock
                    where dtdev.nodev = devis.nodev
                  , first prmtv no-lock
                    where prmtv.tppar = "DLINT"
                      and prmtv.cdpar = dtdev.dlint:
                    assign
                        poFusionDevis:DateCreationDevis       = dateToCharacter(devis.dtcsy)
                        poFusionDevis:DateLCreationDevis      = outilFormatage:getDateFormat(devis.dtcsy, "L")
                        poFusionDevis:DateCreationDevisLettre = outilFormatage:getDateFormat(devis.dtcsy, "LL")
                        poFusionDevis:DelaiDevis              = prmtv.lbpar
                        poFusionDevis:NumFourniDevis          = string(devis.nofou)
                    .
                    for first CcptCol no-lock
                        where ccptCol.tprol = 12
                          and ccptcol.soc-cd = integer(mtoken:cRefPrincipale)
                      , first ifour no-lock
                        where ifour.soc-cd = ccptcol.soc-cd
                          and ifour.coll-cle = ccptcol.coll-cle
                          and integer(ifour.cpt-cd) = devis.nofou:
                        find first iregl no-lock
                             where iregl.soc-cd = integer(mtoken:cRefPrincipale)
                               and iregl.regl-cd = ifour.regl-cd no-error.
                        if available iregl then CondPaiemDevis = iregl.lib.
                        find first ilibport no-lock 
                             where ilibport.soc-cd = integer(mtoken:cRefPrincipale)
                               and ilibport.port-cd = ifour.port-cd no-error.
                        if available ilibport then CondPortDevis = ilibport.lib.
                    end.

                    // Ajout Sy le 17/01/2011 - signalé par 
                    if devis.tpPar <> "" and devis.NoPar <> 0 then do:
                        assign 
                            poFusionDevis:RoleSignalantDevis          = (if devis.tpPar = "FOU" then outilTraduction:getLibelle(100124) else outilTraduction:getLibelleProg("O_ROL", devis.tpPar))
                            voRole                                    = chargeRole(devis.tppar, devis.nopar, piNumeroDocument)
                            poFusionDevis:TitreSignalantDevis         = voRole:Titre
                            poFusionDevis:TitreLSignalantDevis        = voRole:titreLettre
                            poFusionDevis:CiviliteSignalantDevis      = voRole:civilite
                            poFusionDevis:NomSignalantDevis           = voRole:nom
                            poFusionDevis:NomCompletSignalantDevis    = voRole:nomComplet
                        .
                        voAdresse = chargeAdresse(Devis.tpPar, Devis.NoPar, piNumeroDocument).
                        assign
                            poFusionDevis:AdresseSignalantDevis       = voAdresse:Adresse
                            poFusionDevis:SuiteAdresseSignalantDevis  = voAdresse:complementVoie
                            poFusionDevis:CodePostalSignalantDevis    = voAdresse:CodePostal
                            poFusionDevis:VilleSignalantDevis         = voAdresse:Ville
                            poFusionDevis:VilleCedexSignalantDevis    = voAdresse:cedex
                            poFusionDevis:TelSignalantDevis           = voAdresse:Telephone
                            poFusionDevis:PortableSignalantDevis      = voAdresse:Portable
                            poFusionDevis:ComplementAdresseIdentSignalantDevis = voAdresse:identAdresse. // PL : 11/01/2016 - (Fiche : 0711/0069)
                        . 
                    end.
                    
                    // Ajout SY le 17/01/2011
                    viNoLigLot = 0.
                    for each dtlot no-lock
                       where dtlot.tptrt = {&TYPEINTERVENTION-demande2devis}     /* TpDevUse */ 
                         and dtlot.notrt = piNumeroDevis
                     , first local no-lock
                       where local.noloc = dtlot.noloc
                         by local.nolot:
                        assign
                            vcTypeRoleOccupantLot   = ""
                            viNumeroRoleOccupantLot = 0
                            vcPortableOccupantLot   = ""
                            vcTelephoneOccupantLot  = ""
                            NumTelOcc               = ""
                            viNoLigLot              = viNoLigLot + 1
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
                            vcTypeRoleOccupantLot   = {&TYPEROLE-locataire}
                            viNumeroRoleOccupantLot = viNumeroBailleur
                        .
                        else if vcTypeOccupantLot = "00001" 
                        then assign 
                            vcTypeRoleOccupantLot   = vcTypeCoproprietaire
                            viNumeroRoleOccupantLot = NoCopUse
                        .
                        if viNumeroRoleOccupantLot <> 0 then do:
                            voAdresse = chargeAdresse(vcTypeRoleOccupantLot, viNumeroRoleOccupantLot, piNumeroDocument).
                            assign
                                vcTelephoneOccupantLot = voAdresse:Telephone
                                vcPortableOccupantLot  = voAdresse:Portable
                                vcEmailOccupantLot     = voAdresse:Mail
                                NumTelOcc              = voAdresse:Telephone
                            .
                        end.
                        vcListeLotsDevis              = vcListeLotsDevis              + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(string(local.nolot)).
                        vcListeNatureLotsDevis        = vcListeNatureLotsDevis        + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(outilTraduction:getLibelleParam("NTLOT", local.ntlot)).
                        vcListeBatLotsDevis           = vcListeBatLotsDevis           + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(trim(local.cdbat)).
                        vcListeEntreeLotsDevis        = vcListeEntreeLotsDevis        + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(trim(local.lbdiv)).
                        vcListeEscLotsDevis           = vcListeEscLotsDevis           + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(trim(local.cdesc)).
                        vcListeEtageLotsDevis         = vcListeEtageLotsDevis         + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(trim(local.cdeta)).
                        vcListePorteLotsDevis         = vcListePorteLotsDevis         + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(trim(local.cdpte)).
                        vcListeOccupantLotsDevis      = vcListeOccupantLotsDevis      + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(trim(vcNomOccupantLot)).
                        vcListeTelOccupantLotsDevis   = vcListeTelOccupantLotsDevis   + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:frmSpe64b(trim(NumTelOcc)).
                        vcListeEmailOccupantLotsDevis = vcListeEmailOccupantLotsDevis + (if vcListeEmailOccupantLotsDevis = "" then "" else vcChr10) + trim(vcEmailOccupantLot).

                        /* NP 1015/0106 */
                        vcListePortableOccupantLotsDevis = vcListePortableOccupantLotsDevis + (if viNoLigLot = 1 then "" else vcChr10) + outilFormatage:FrmSpe64b(trim(vcPortableOccupantLot)).

                        vcTableLotsDevis = vcTableLotsDevis
                                       + (if viNoLigLot = 1 then "" else vcChr10) 
                                       + string(local.nolot, ">>>>9")                                           + vcChr9
                                       + string(outilTraduction:getLibelleParam("NTLOT", local.ntlot), "X(22)") + vcChr9
                                       + trim(local.cdbat)                                                      + vcChr9
                                       + trim(local.lbdiv)                                                      + vcChr9
                                       + trim(local.cdesc)                                                      + vcChr9
                                       + trim(local.cdeta)                                                      + vcChr9
                                       + trim(local.cdpte)
                        .
                        vcTableLotsOccupantsDevis = vcTableLotsOccupantsDevis
                                                + (if viNoLigLot = 1 then "" else vcChr10) 
                                                + string(local.nolot, ">>>>9")                                           + vcChr9
                                                + string(outilTraduction:getLibelleParam("NTLOT", local.ntlot), "X(18)") + vcChr9
                                                + trim(local.cdbat)                                                      + vcChr9
                                                + trim(local.lbdiv)                                                      + vcChr9
                                                + trim(local.cdesc)                                                      + vcChr9
                                                + trim(local.cdeta)                                                      + vcChr9
                                                + trim(local.cdpte)                                                      + vcChr9
                                                + trim(local.nmocc)                                                      + vcChr9
                                                + trim(NumTelOcc)                                                        + vcChr9
                                                + trim(vcPortableOccupantLot) /* NP 1015/0106 */
                        .
                    end.
                    assign
                        poFusionDevis:ListeLotsDevis                 = vcListeLotsDevis
                        poFusionDevis:ListeNatureLotsDevis           = vcListeNatureLotsDevis
                        poFusionDevis:ListeBatLotsDevis              = vcListeBatLotsDevis
                        poFusionDevis:ListeEntreeLotsDevis           = vcListeEntreeLotsDevis
                        poFusionDevis:ListeEscLotsDevis              = vcListeEscLotsDevis
                        poFusionDevis:ListeEtageLotsDevis            = vcListeEtageLotsDevis
                        poFusionDevis:ListePorteLotsDevis            = vcListePorteLotsDevis
                        poFusionDevis:ListeOccupantLotsDevis         = vcListeOccupantLotsDevis
                        poFusionDevis:TableLotsDevis                 = vcTableLotsDevis
                        poFusionDevis:TableLotsOccupantsDevis        = vcTableLotsOccupantsDevis
                        poFusionDevis:ListeTelOccupantLotsDevis      = vcListeTelOccupantLotsDevis
                        poFusionDevis:ListeEmailOccupantLotsDevis    = vcListeEmailOccupantLotsDevis
                        poFusionDevis:ListePortableOccupantLotsDevis = vcListePortableOccupantLotsDevis /* NP 1015/0106 */
                    .  
                end.
                for first dtdev no-lock
                    where dtdev.nodev = piNumeroDevis
                  , first inter no-lock
                    where inter.noint = dtdev.noint:
                    poFusionDevis:NumDossierTravDevis = (if inter.nodos > 0 then string(inter.nodos) else "").
                end.
            end.
            when {&FUSION-TableDevis}       or when {&FUSION-ListeDesignationDevis} or when {&FUSION-ListeRefarticleDevis} 
            or when {&FUSION-ListeQteDevis} or when {&FUSION-ListeDelaiDevis}       or when {&FUSION-ListeCommentaireDevis}
            or when {&FUSION-ListePUDevis}  or when {&FUSION-ListeTxRemiseDevis}    or when {&FUSION-ListeMontantDevis}
            or when {&FUSION-ListeCleDevis} or when {&FUSION-ListeCleLibelleDevis}  or when {&FUSION-111424}
            or when {&FUSION-111425}        or when {&FUSION-111426}                or when {&FUSION-ListeDomaiArtDevis}
            or when {&FUSION-ListeLibelleArtDevis}
            then do:
                if vlBloc2 then next boucleCHamp.
                assign vlBloc2 = true.
/*
            put stream LbCheBas unformatted 
               "NoDev"         vcChr9
               "Réf"           vcChr9
               "Désignation"   vcChr9
               "Date Inter"    vcChr9
               "Qté"           vcChr9
               "PU HT"         vcChr9
               "Rem"           vcChr9
               "Montant"       vcChr9
               "Rub"           vcChr9
               "ssRub"         vcChr9
               "Fisc"          vcChr9
               vcChr10
            .
*/
                for first devis no-lock 
                    where devis.nodev = piNumeroDevis
                   , each dtdev no-lock
                    where dtdev.nodev = devis.nodev
                  , first inter no-lock
                    where inter.noint = dtdev.noint
                  , first prmtv no-lock
                    where prmtv.tppar = "DLINT"
                      and prmtv.cdpar = dtdev.dlint:
                    vcinfosArticle = DonneInfosArticle(inter.cdart).

                    assign
                        vcLbTmpPdt                = DateToCharacter(dtdev.dtcsy + prmtv.nbpar)
                        vcListeDesignationDevis   = vcListeDesignationDevis + outilFormatage:frmSpe64b(string(dtdev.lbint, "X(120)"))          + vcChr10
                        vcListeRefArticleDevis    = vcListeRefArticleDevis  + outilFormatage:frmSpe64b(inter.cdart)                            + vcChr10
                        vcListeQteDevis           = vcListeQteDevis         + outilFormatage:frmSpe64b(montantToCharacter(dtdev.qtint, false)) + vcChr10
                        vcListeDelaiDevis         = vcListeDelaiDevis       + outilFormatage:frmSpe64b(vcLbTmpPdt)                             + vcChr10
                        vcListeCommentaireDevis   = vcListeCommentaireDevis + outilFormatage:frmSpe64b(dtdev.lbcom)                            + vcChr10
                        vcListeCleDevis           = vcListeCleDevis         + outilFormatage:frmSpe64b(dtdev.cdcle)                            + vcChr10
                        vcListeRubArtDevis        = vcListeRubArtDevis      + outilFormatage:frmSpe64b(entry(1, vcInfosArticle, "#"))          + vcChr10
                        vcListeSSRubArtDevis      = vcListeSSRubArtDevis    + outilFormatage:frmSpe64b(entry(2, vcInfosArticle, "#"))          + vcChr10
                        vcListeCodeFiscArtDevis   = vcListeCodeFiscArtDevis + outilFormatage:frmSpe64b(entry(3, vcInfosArticle, "#"))          + vcChr10
                        vcListeDomaiArtDevis      = vcListeDomaiArtDevis    + outilFormatage:frmSpe64b(entry(4, vcInfosArticle, "#"))          + vcChr10
                        vcListeLibelleArtDevis    = vcListeLibelleArtDevis  + outilFormatage:frmSpe64b(entry(5, vcInfosArticle, "#"))          + vcChr10

                        // Initialisation des montants tarifaires
                        dPUDevis         = 0
                        dTxRemiseDevis   = 0
                        dMontantDevis    = 0
                    .

                    // Recherche du tarif pour cet article ce fournisseur cet immeuble
                    find first intnt no-lock
                         where intnt.tpcon = inter.tpcon
                           and intnt.nocon = inter.nocon
                           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.

                    if available intnt then do:
                        vcListeCleLibelleDevis = vcListeCleLibelleDevis + outilFormatage:frmSpe64b(getLibelleCle(intnt.noidt, inter.tpcon, inter.nocon, dtdev.cdcle)) + vcChr10.
//                        release tarif no-error.           THK Pourquoi release tarif ?

                        find first tarif no-lock
                             where tarif.cdart = inter.cdart
                               and tarif.noimm = intnt.noidt
                               and tarif.nofou = devis.nofou no-error.
                        if not available tarif then do:
                            // Recherche du tarif pour cet article ce fournisseur
                            find first tarif no-lock
                                 where tarif.cdart = inter.cdart
                                   and tarif.noimm = 0
                                   and tarif.nofou = devis.nofou no-error.
                        end.
                        if available tarif 
                        then assign
                            dPUDevis       = tarif.pxuni
                            dTxRemiseDevis = tarif.txrem
                        .
                    end.
                    assign
                        // Calcul du montant
                        dMontantDevis = dtdev.qtint * dPUDevis
                        dMontantDevis = round(dMontantDevis - (dMontantDevis * dTxRemiseDevis / 100), 2)
                        // Valorisation
                        vcListePUDevis       = vcListePUDevis       + outilFormatage:frmSpe64b(montantToCharacter(dPUDevis,       false)) + vcChr10
                        vcListeTxRemiseDevis = vcListeTxRemiseDevis + outilFormatage:frmSpe64b(montantToCharacter(dTxRemiseDevis, false)) + vcChr10
                        vcListeMontantDevis  = vcListeMontantDevis  + outilFormatage:frmSpe64b(montantToCharacter(dMontantDevis,  false)) + vcChr10
                .
                    /*
                    put stream LbCheBas unformatted 
                        dtdev.nodev                              vcChr9
                        inter.cdart                              vcChr9
                        string(dtdev.lbint,"X(120)")             vcChr9
                        LbTmpPdt                                 vcChr9
                        montantToCharacter(dtdev.qtint, false)   vcChr9
                        montantToCharacter(PUDevis, false)       vcChr9
                        montantToCharacter(TxRemiseDevis, false) vcChr9
                        montantToCharacter(MontantDevis, false)  vcChr9
                        entry(1, cInfosArticle, "#")             vcChr9
                        entry(2, cInfosArticle, "#")             vcChr9
                        entry(3, cInfosArticle, "#")             vcChr9
                        vcChr10
                    .
                    */
                end.
//                vcTableDevis = "~"" + REPLACE(vcRpTmpOut,"\","\\") + "base.txt~"".
                assign
                    poFusionDevis:ListePUDevis         = vcListePUDevis
                    poFusionDevis:ListeTxRemiseDevis   = vcListeTxRemiseDevis
                    poFusionDevis:ListeMontantDevis    = vcListeMontantDevis
                    poFusionDevis:ListeCleDevis        = vcListeCleDevis 
                    poFusionDevis:ListeCleLibelleDevis = vcListeCleLibelleDevis
                    poFusionDevis:ListeDomaiArtDevis   = vcListeDomaiArtDevis
                    poFusionDevis:ListeLibelleArtDevis = vcListeLibelleArtDevis
                .
            end.
        end case.
    end. /* boucle do */
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.   