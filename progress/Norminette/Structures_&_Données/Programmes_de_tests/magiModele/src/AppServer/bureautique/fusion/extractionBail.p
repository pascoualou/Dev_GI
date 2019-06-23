/*------------------------------------------------------------------------
File        : extractionBail.p
Description : Recherche des donnees de fusion bail
Author(s)   : kantena - 2018/01/30
Notes       : appelé par extract.p
----------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionBail.i}
{preprocesseur/listeRubQuit2TVA.i}

using bureautique.fusion.classe.fusionBail.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionQuittance.
using bureautique.fusion.classe.fusionBanque.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bureautique/fusion/include/fctdatin.i} /* FUNCTION Date2Integer, Integer2Date */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/solcptec.i}
{bureautique/fusion/include/valorisationTtChampFusion.i}  // procedure valoriseChampFusion
{bail/include/isGesflo.i}

procedure extractionBail:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroBail       as integer          no-undo.
    define input        parameter piNumeroDocument   as int64            no-undo.
    define input        parameter pcTypeRole         as character        no-undo.
    define input        parameter piNumeroRole       as integer          no-undo.
    define input        parameter piNumeroTraitement as integer          no-undo.
    define input        parameter pcListeChamp       as character        no-undo.
    define input-output parameter poFusionBail       as class fusionBail no-undo.

    define variable SfTotUtil               as decimal   no-undo.
    define variable SfTotPond               as decimal   no-undo.
    define variable ChLoyAnn                as character no-undo.
    define variable DcLoyerMensuelEnCours   as decimal   no-undo.
    define variable viNumeroContrat         as integer   no-undo.
    define variable viNumeroApp             as integer   no-undo.
    define variable dMontantTmpDep          as decimal   no-undo.
    define variable NoMloUse                as integer   no-undo.
    define variable NoFicheL                as integer   no-undo.
    define variable DtFinBai                as date      no-undo.
    define variable FgVisExp                as logical   no-undo.
    define variable FgCatCOM-CIV            as logical   no-undo.
    define variable dValHono                as decimal   no-undo.
    define variable vcTmp                   as character no-undo.
    define variable viNoJouPrl-Cab          as integer   no-undo.
    define variable viJourPaiement          as integer   no-undo.
    define variable dPoucentageVariation    as decimal   no-undo.
    define variable vcListeNumero           as character no-undo.
    define variable vcListeDebut            as character no-undo.
    define variable vcListeFin              as character no-undo.
    define variable vcListeMontant          as character no-undo.
    define variable vcListeEtat             as character no-undo.
    define variable vdaDateSoldeLocataire   as date      no-undo.
    define variable vdSoldeCpt                          as decimal   no-undo.
    define variable dMontantTempo                       as decimal   no-undo.
    define variable iNomandatSEPA                       as int64     no-undo.
    define variable LbDivParRUM                         as character no-undo.
    define variable LbZone                              as character no-undo.
    define variable DateDebPSEPA                        as date      no-undo.
    define variable viCptLotUL                          as integer   no-undo.
    define variable vdSoldeDateDocLocataire             as decimal   no-undo.
    define variable vdSfTotUse                          as decimal   no-undo.
    define variable vdSfTotUtil                         as decimal   no-undo.
    define variable vdSfTotPond                         as decimal   no-undo.
    define variable vdSfTotCarrez                       as decimal   no-undo.
    define variable viCompteur                          as integer   no-undo.
    define variable viBoucle                            as integer   no-undo.
    define variable vcAssuGarantieLoyerLoc              as character no-undo.
    define variable viNbPerUse                          as integer   no-undo.
    define variable vdMtTotalPremiereEchperiodecomplete as decimal   no-undo.
    define variable vhrumlotct                          as handle    no-undo.
    define variable RUMLocataire                        as character no-undo.
    define variable ICSCreancierLocataire               as character no-undo.
    define variable NomCreancierLocataire               as character no-undo.
    define variable NoIdtUs1                            as integer   no-undo.
    define variable vdaDateDerLoyer                     as date      no-undo.
    define variable chretSol                            as character no-undo.
    define variable chretSLF                            as character no-undo.
    define variable FgExeMth                            as logical   no-undo.
    define variable vcCapitalLocataire                  as character no-undo.
    define variable viMandatLocation                    as int64     no-undo.
    define variable voAdresse               as class fusionAdresse   no-undo.
    define variable voRole                  as class fusionRole      no-undo.
    define variable voQuittance             as class fusionQuittance no-undo.
    define variable voBanque                as class fusionBanque    no-undo.

    define variable vlBloc1          as logical    no-undo.
    define variable vlBloc2          as logical    no-undo.
    define variable vlBloc3          as logical    no-undo.
    define variable vlBloc4          as logical    no-undo.
    define variable vlBloc5          as logical    no-undo.
    define variable vlBloc6          as logical    no-undo.
    define variable vlBloc7          as logical    no-undo.
    define variable vlBloc8          as logical    no-undo.
    define variable vlBloc9          as logical    no-undo.
    define variable vlBloc10         as logical    no-undo.
    define variable vlBloc11         as logical    no-undo.
    define variable vlBloc12         as logical    no-undo.
    define variable vlBloc13         as logical    no-undo.
    define variable vlBloc14         as logical    no-undo.
    define variable vlBloc15         as logical    no-undo.
    define variable vlBloc16         as logical    no-undo.
    define variable vlBloc17         as logical    no-undo.
    define variable vlBloc18         as logical    no-undo.
    define variable vlBloc19         as logical    no-undo.
    define variable vlBloc20         as logical    no-undo.
    define variable vlBloc21         as logical    no-undo.
    define variable vlBloc22         as logical    no-undo.
    define variable vlBloc23         as logical    no-undo.
    define variable vlBloc24         as logical    no-undo.
    define variable vlBloc25         as logical    no-undo.
    define variable vlBloc26         as logical    no-undo.
    define variable vlBloc27         as logical    no-undo.
    define variable vlBloc28         as logical    no-undo.
    define variable vlBloc29         as logical    no-undo.
    define variable vlBloc30         as logical    no-undo.

    define buffer mlo_ctrat for ctrat.
    define buffer flo_intnt for intnt.
    define buffer m_ctrat   for ctrat.
    define buffer prc_tache for tache.    /* NP 0415/0251 */
    define buffer intnt     for intnt.
    define buffer bintnt    for intnt.
    define buffer bbintnt   for intnt.
    define buffer clemi     for clemi.
    define buffer bclemi    for clemi.  /* NP 0209/0030 */
    define buffer ctanx     for ctanx.
    define buffer calev     for calev.
    define buffer cpuni     for cpuni.
    define buffer lsirv     for lsirv.
    define buffer taint     for taint.
    define buffer local     for local.
    define buffer indrv     for indrv.
    define buffer echlo     for echlo.
    define buffer aquit     for aquit.
    define buffer location  for location.
    define buffer restrien  for restrien.
    define buffer tbEbnt    for tbEnt.

    /* Ajout SY le 26/06/2009 - Fiche relocation ou mandat location */
    if piNumeroBail = 0 and (NoFicheL <> 0 or NoMloUse <> 0) 
    then do:
        if NoFicheL = 0 
        then do:
            find first mlo_ctrat no-lock
                 where mlo_ctrat.tpcon = {&TYPECONTRAT-MandatLocation}
                   and mlo_ctrat.nocon = NoMloUse no-error.
            if available mlo_ctrat 
            then do:
                /* fiche de relocation */
                find first flo_intnt no-lock   /* fiche location */
                     where flo_intnt.tpcon = mlo_ctrat.tpcon
                       and flo_intnt.nocon = mlo_ctrat.nocon
                       and flo_intnt.tpidt = "06000" no-error.
                if available flo_intnt then NoFicheL = flo_intnt.noidt.
            end.
        end.
        if NoFicheL <> 0
        then for first location no-lock
                 where location.nofiche = NoFicheL: 
            assign
                NoFicheL = location.nofiche
                piNumeroBail = location.noderloc
            .
        end.
    end.
boucleChamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-adresse_Locataire}   or when {&FUSION-Suite_adresse_Locataire} or when {&FUSION-Code_Postal_Locataire}
         or when {&FUSION-VilleLocataire}      or when {&FUSION-TelephoneLocataire}      or when {&FUSION-adresseLocataireRep}
         or when {&FUSION-PortableLocataire}   or when {&FUSION-FaxLocataire}            or when {&FUSION-emailLocataire}
         or when {&FUSION-VilleCedexLocataire} or when {&FUSION-ComplementAdresseIdentLocataire} then do:   /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                if vlBloc1 then next boucleCHamp.
                vlBloc1 = true.

                voAdresse = chargeAdresse({&TYPEROLE-locataire}, piNumeroBail, piNumeroDocument).
                assign
                    poFusionBail:adresse_Locataire               = voAdresse:adresse
                    poFusionBail:Suite_adresse_Locataire         = voAdresse:complementVoie
                    poFusionBail:Code_Postal_Locataire           = voAdresse:codePostal
                    poFusionBail:VilleLocataire                  = voAdresse:ville
                    poFusionBail:PaysLocataire                   = voAdresse:codePays
                    poFusionBail:TelephoneLocataire              = voAdresse:telephone
                    poFusionBail:faxLocataire                    = voAdresse:fax
                    poFusionBail:EmailLocataire                  = voAdresse:mail
                    poFusionBail:PortableLocataire               = voAdresse:portable
                    poFusionBail:VilleCedexLocataire             = voAdresse:cedex
                    poFusionBail:ComplementAdresseIdentLocataire = voAdresse:identAdresse
                    poFusionBail:adresseLocataireRep             = outilFormatage:formatageAdresse({&TYPEROLE-locataire}, piNumeroBail, "00007")
                .
            end.
            when {&FUSION-NoLocataire}               or when {&FUSION-Titre_Locataire}               or when {&FUSION-} "178"
         or when {&FUSION-Nom_Locataire}             or when {&FUSION-Date_naissance_locataire}      or when {&FUSION-Lieu_naissance_locataire}
         or when {&FUSION-Profession_Locataire}      or when {&FUSION-NomLocContact}                 or when {&FUSION-TitreLocContact}
         or when {&FUSION-DateL_Naissance_Locataire} or when {&FUSION-NomCompletLocataire}           or when {&FUSION-NomCompletLocContact}
         or when {&FUSION-NomCompletLocCo}           or when {&FUSION-NomCompletLocRep}              or when {&FUSION-TitreLLocataire}
         or when {&FUSION-FormeLgJuridLocataire}     or when {&FUSION-FormeCtJuridLocataire}         or when {&FUSION-PolitesseLocataire}
         or when {&FUSION-NationaliteLocataireRep}   or when {&FUSION-NationaliteLocataire}          or when {&FUSION-CiviliteLocataireTiers2}
         or when {&FUSION-NomCompletLocataireTiers2} or when {&FUSION-DateLNaissanceLocataireTiers2} or when {&FUSION-LieuNaissanceLocataireTiers2} 
         or when {&FUSION-PaysNaissanceLocataire}    or when {&FUSION-PaysNaissanceLocataireTiers2}  or when {&FUSION-NationaliteLocataireTiers2} 
            then do:
                if vlBloc2 then next boucleCHamp.
                vlBloc2 = true.

                voRole = chargeRole({&TYPEROLE-locataire}, piNumeroBail, piNumeroDocument).
                assign
                    poFusionBail:NoLocataire                 = string(piNumeroBail)
                    poFusionBail:Titre_Locataire             = voRole:titre
                    poFusionBail:TitreLLocataire             = voRole:titreLettre
                    poFusionBail:Civilite_Locataire          = voRole:civilite
                    poFusionBail:Nom_Locataire               = voRole:Nom
                    poFusionBail:Date_naissance_locataire    = voRole:dateNaissance
                    poFusionBail:DateL_naissance_locataire   = outilFormatage:getDateFormat(date(voRole:dateNaissance), "L")
                    poFusionBail:Lieu_Naissance_Locataire    = voRole:lieuNaissance
                    poFusionBail:Profession_Locataire        = voRole:profession
                    poFusionBail:TitreLocContact             = voRole:titreBis
                    poFusionBail:NomLocContact               = voRole:nomBis
                    poFusionBail:NomCompletLocataire         = voRole:nomComplet
                    poFusionBail:NomCompletLocCO             = voRole:nomCompletC-O
                    poFusionBail:NomCompletLocRep            = voRole:nomCompletRep
                    poFusionBail:NomCompletLocContact        = voRole:nomCompletContact
                    poFusionBail:FormeLgJuridLocataire       = voRole:formeJuridiqueLong
                    poFusionBail:FormeCtJuridLocataire       = voRole:formeJuridiqueCourt
                    poFusionBail:PolitesseLocataire          = voRole:formulePolitesse
                    poFusionBail:NationaliteLocataireRep     = voRole:NationaliteRep
                    poFusionBail:NationaliteLocataire        = voRole:Nationalite
                .
                /* SY 0516/0027 */
                assign 
                    poFusionBail:PaysLocataire                   = voRole:paysNaissance
                    poFusionBail:Pays_Naissance_LocataireTiers2  = voRole:PaysNaissanceBis
                    poFusionBail:CiviliteLocataireTiers2         = voRole:CiviliteBis
                    poFusionBail:NomCompletLocataireTiers2       = voRole:nomCompletBis
                    poFusionBail:DateLNaissanceLocataireTiers2   = outilFormatage:getDateFormat(date(voRole:DateNaissanceBis), "L")
                    poFusionBail:LieuNaissanceLocataireTiers2    = voRole:LieuNaissanceBis
                    poFusionBail:NationaliteLocataireTiers2      = voRole:NationaliteBis
                .
            end.
            when {&FUSION-Descriptif_Locataire} then do:
                poFusionBail:Descriptif_Locataire = DESCRIPTION({&TYPEROLE-locataire}, piNumeroBail, poFusionBail:Descriptif_Locataire, piNumeroDocument).
                for each intnt no-lock
                   where intnt.tpcon = {&TYPECONTRAT-bail}
                     and intnt.nocon = piNumeroBail
                     and intnt.tpidt = "00051":
                    poFusionBail:Descriptif_Locataire = DESCRIPTION(intnt.tpidt, intnt.noidt, poFusionBail:Descriptif_Locataire, piNumeroDocument).
                end.
            end. 
            when {&FUSION-DescriptifLocatNationalite} then do:
                poFusionBail:DescriptifLocatNationalite = DESCRIPTNAT({&TYPEROLE-locataire}, piNumeroBail, poFusionBail:DescriptifLocatNationalite, piNumeroDocument).
                for each intnt 
                   where intnt.tpcon = {&TYPECONTRAT-bail}
                     and intnt.nocon = piNumeroBail
                     and intnt.tpidt = "00051" no-lock:
                    poFusionBail:DescriptifLocatNationalite = DESCRIPTNAT(intnt.tpidt, intnt.noidt, poFusionBail:DescriptifLocatNationalite, piNumeroDocument).
                end.
                run valoriseChampFusion(110548, "DescriptifLocatNationalite", poFusionBail:DescriptifLocatNationalite).
            end.
            when {&FUSION-SoldeCompteDebiteur}                 or when {&FUSION-SoldeCompteCrediteur}        or when {&FUSION-SoldeLocataire}
         or when {&FUSION-SoldeCompteCrediteurenLettre}        or when {&FUSION-SoldeCompteDebiteurenLettre} or when {&FUSION-SoldeLocataireenLettre}
         or when {&FUSION-NumPoliceLoc}                        or when {&FUSION-SoldeDateDocLocataire}       or when {&FUSION-SoldeDateDocLocataireEnLettre} 
            then do:
               if vlBloc3 then next boucleCHamp.
               vlBloc3 = true.
               assign
                    vdSoldeCpt                     = SOLDECPT({&TYPECONTRAT-bail}, piNumeroBail, 0, "4112", (if vdaDateSoldeLocataire <> ? then vdaDateSoldeLocataire else today))
                                                   + SOLDECPT({&TYPECONTRAT-bail}, piNumeroBail, 0, "4118", (if vdaDateSoldeLocataire <> ? then vdaDateSoldeLocataire else today))
                    poFusionBail:SoldeCompteDebiteur  = "0"
                    poFusionBail:SoldeCompteCrediteur = "0"
                .
                if vdSoldeCpt > 0
                then assign
                    poFusionBail:SoldeCompteDebiteur          = montantToCharacter (vdSoldeCpt, true)
                    poFusionBail:SoldeCompteDebiteurEnLettre  = CONVCHIFFRE(vdSoldeCpt)
                .
                else assign
                    poFusionBail:SoldeCompteCrediteur         = montantToCharacter (vdSoldeCpt, true)
                    poFusionBail:SoldeCompteCrediteurEnLettre = CONVCHIFFRE(vdSoldeCpt)
                .
                assign
                    poFusionBail:SoldeLocataire           = montantToCharacter (vdSoldeCpt, true)
                    poFusionBail:SoldeLocataireEnLettre   = CONVCHIFFRE(vdSoldeCpt)
                .
                /* SY 1016/0014 */
                vdSoldeDateDocLocataire                   = f_solcptec(integer(mtoken:cRefGerance),
                                                                       integer(substring(string(piNumeroBail, "9999999999"), 1, 5)),
                                                                       "L",
                                                                       substring(string(piNumeroBail, "9999999999"), 6, 5),
                                                                       "S",
                                                                       (if vdaDateSoldeLocataire <> ? then vdaDateSoldeLocataire else today),
                                                                       "",
                                                                       "").
                poFusionBail:DateSoldeLocataire            = string((if vdaDateSoldeLocataire <> ? then vdaDateSoldeLocataire else today), "99/99/9999").
                poFusionBail:SoldeDateDocLocataire         = montantToCharacter (vdSoldeDateDocLocataire, true).
                poFusionBail:SoldeDateDocLocataireEnLettre = CONVCHIFFRE(vdSoldeDateDocLocataire).
            end.
            when {&FUSION-Debut_Bail}            or when {&FUSION-Fin_Bail}                 or when {&FUSION-Duree_Bail}
         or when {&FUSION-Date_de_resiliation}   or when {&FUSION-DelaisPreavis}            or when {&FUSION-DateSigBail}
         or when {&FUSION-UsageLocaux}           or when {&FUSION-MotifResiliation}         or when {&FUSION-DateRenouvel}
         or when {&FUSION-DtLimiteRenou}         or when {&FUSION-DateIniBail}              or when {&FUSION-DateLRenouvel}
         or when {&FUSION-DateL_de_resiliation}  or when {&FUSION-DebutL_Bail}              or when {&FUSION-DtLLimiteRenou}
         or when {&FUSION-FinL_Bail}             or when {&FUSION-DtLimitReponsePro}        or when {&FUSION-DtLLimitReponsePro}
         or when {&FUSION-DateDebutBailLettre}   or when {&FUSION-DatelSigBail}             or when {&FUSION-DateSigBailLettre}
         or when {&FUSION-DatelIniBail}          or when {&FUSION-DateIniBailLettre}        or when {&FUSION-FinBailLettre}
         or when {&FUSION-DateRenouvelLettre}    or when {&FUSION-DtLimiteRenouLettre}      or when {&FUSION-DtLimitReponseProLettre}
         or when {&FUSION-DateResiliationLettre} or when {&FUSION-NatureBail}               or when {&FUSION-DureeBailenLettre}
         or when {&FUSION-DateResilTrienPrec}    or when {&FUSION-DureeResilTrienPrec}      or when {&FUSION-DateResilTrien}
         or when {&FUSION-DureeResilTrien}       or when {&FUSION-DateResilTrienPrecLettre} or when {&FUSION-DateResilTrienLettre} then do:
                if vlBloc4 then next boucleCHamp.
                vlBloc4 = true.

                find first ctrat no-lock
                     where ctrat.tpcon = {&TYPECONTRAT-bail}
                       and ctrat.nocon = piNumeroBail no-error.
                if available ctrat 
                then do:
                    DtFinBai = ctrat.dtfin.
                    find last tache no-lock
                        where tache.tpcon = ctrat.tpcon
                          and tache.nocon = ctrat.nocon
                          and tache.tptac = {&TYPETACHE-renouvellement} no-error.
                    /*IF AVAILABLE tache THEN DtFinBai = tache.dtfin.*/
                    /* Modif SY le 30/08/2010 */  
                    if available tache then do: 
                        /*  Date d'expiration theorique / invisible */
                        case tache.tpfin:
                            when "00" then FgVisExp = true.
                            when "10" then FgVisExp = false.
                            when "20" then FgVisExp = false.
                            when "30" then FgVisExp = false.
                            when "40" then FgVisExp = false.
                            when "50" then FgVisExp = true.
                        end case.
                        if not FgVisExp then DtFinBai = tache.dtfin.
                    end.
                    /* Ajout SY le 12/01/2011 : Si Bail et que sa catégorie de bail est associée à une durée an+mois+jour (Bail COM ou Code Civil) */
                    FgCatCOM-CIV = no.
                    find first sys_pg no-lock 
                         where sys_pg.tppar = "R_RST" 
                           and sys_pg.cdpar = ctrat.ntcon no-error.
                    if available sys_pg then FgCatCOM-CIV = yes.
                    assign
                        poFusionBail:Debut_Bail                  = dateToCharacter (ctrat.dtdeb)
                        poFusionBail:DebutL_Bail                 = outilFormatage:getDateFormat(ctrat.dtdeb, "L")
                        poFusionBail:DateDebutBailLettre         = outilFormatage:getDateFormat(ctrat.dtdeb, "LL")
                        poFusionBail:DateSigBail                 = dateToCharacter (ctrat.dtsig)
                        poFusionBail:DateLSigBail                = outilFormatage:getDateFormat(ctrat.dtsig, "L")
                        poFusionBail:DateSigBailLettre           = outilFormatage:getDateFormat(ctrat.dtsig, "LL")
                        poFusionBail:DateIniBail                 = dateToCharacter (ctrat.dtini)
                        poFusionBail:DateLIniBail                = outilFormatage:getDateFormat(ctrat.dtini, "L")
                        poFusionBail:DateIniBailLettre           = outilFormatage:getDateFormat(ctrat.dtini, "LL")
                        poFusionBail:Fin_bail                    = dateToCharacter (DtFinBai)
                        poFusionBail:FinL_bail                   = outilFormatage:getDateFormat(DtFinBai, "L")
                        poFusionBail:FinBailLettre               = outilFormatage:getDateFormat(DtFinBai, "LL")
                        poFusionBail:DateRenouvel                = dateToCharacter (DtFinBai + 1)
                        poFusionBail:DateLRenouvel               = outilFormatage:getDateFormat(DtFinBai + 1, "L")
                        poFusionBail:DateRenouvelLettre          = outilFormatage:getDateFormat(DtFinBai + 1, "LL")
                        poFusionBail:DtLimiteRenou               = dateToCharacter (add-interval(DtFinBai, -6, "months"))
                        poFusionBail:DtLLimiteRenou              = outilFormatage:getDateFormat(add-interval(DtFinBai, -6, "months"), "L")
                        poFusionBail:DtLimiteRenouLettre         = outilFormatage:getDateFormat(add-interval(DtFinBai, -6, "months"), "LL")
                        poFusionBail:DtLimitReponsePro           = dateToCharacter (add-interval(DtFinBai, -6, "months") - 15)
                        poFusionBail:DtLLimitReponsePro          = outilFormatage:getDateFormat(add-interval(DtFinBai, -6, "months") - 15, "L")
                        poFusionBail:DtLimitReponseProLettre     = outilFormatage:getDateFormat(add-interval(DtFinBai, -6, "months") - 15, "LL")
                        poFusionBail:Duree_Bail                  = string(ctrat.nbdur) + " " + outilTraduction:getlibelleParam("UTDUR", ctrat.cddur)
                        poFusionBail:Date_de_Resiliation         = dateToCharacter (ctrat.dtree)
                        poFusionBail:DateL_de_resiliation        = outilFormatage:getDateFormat(ctrat.dtree, "L")
                        poFusionBail:DateResiliationLettre       = outilFormatage:getDateFormat(ctrat.dtree, "LL")
                        poFusionBail:DelaisPreavis               = string(ctrat.nbres) + " " + outilTraduction:getlibelleParam("UTDUR", ctrat.utres)
                        poFusionBail:UsageLocaux                 = USAGE (ctrat.ntcon)
                        poFusionBail:MotifResiliation            = outilTraduction:getlibelleParam("TPMOT", ctrat.tpfin)
                        poFusionBail:NatureBail                  = outilTraduction:getLibelleProg("O_COT",  ctrat.ntcon)
                        poFusionBail:TaciteReconduction          = string(ctrat.tpren = "00001", "Oui/Non")
                        poFusionBail:DureeBailenLettre           = ""
                    .
                    /* Modif SY le 12/01/2011 : Si bail com ou code civil (c.f. param "O_RST") alors durée An+mois+jour */
                    /* RF 1108/0490 - suppression des espaces  " AN" et " MOIS", il y a déjà un en fin de ConvChifLet() */
      
                    case ctrat.cddur:
                        when "00001" then poFusionBail:DureeBailenLettre = ConvchifLet(decimal(ctrat.nbdur)) + "AN" + (if ctrat.nbdur > 1 then "S" else "").
                        when "00002" then poFusionBail:DureeBailenLettre = ConvchifLet(decimal(ctrat.nbdur)) + "MOIS".
                    end case.
                    /* Ajout SY l 30/08/2010 : Durée 1er bail An+mois+jour */
                    /* Modif SY le 12/01/2011 : selon categorie de bail */
                    if FgCatCOM-CIV
                    and (ctrat.nbann1bai > 0 or ctrat.nbmois1bai > 0 or ctrat.nbjou1bail > 0)
                    then assign
                        poFusionBail:Duree_Bail        = outilFormatage:formatDureeAMJ (ctrat.nbann1bai, ctrat.nbmois1bai, ctrat.nbjou1bail, 0)
                        poFusionBail:DureeBailenLettre = (if ctrat.nbann1bai  > 0 then ConvchifLet( decimal(ctrat.nbann1bai)) + "AN" + (if ctrat.nbann1bai > 1 then "S" else "") else "")
                                                       + (if ctrat.nbmois1bai > 0 then " " + ConvchifLet( decimal(ctrat.nbmois1bai)) + "MOIS" else "")
                                                       + (if ctrat.nbjou1bail > 0 then " ET " + ConvchifLet( decimal(ctrat.nbjou1bail)) + "JOUR" + (if ctrat.nbjou1bail > 1 then "S" else "") else "")    /* Modif SY le 25/07/2011 - fiche 0311/0221 : ajout du "et" */
                    .
                    /* Ajout Sy le 21/10/2010 - résiliations triennales */
                    if ctrat.fgrestrien 
                    then for each restrien no-lock
                            where restrien.tpcon   = ctrat.tpcon
                              and restrien.nocon   = ctrat.nocon
                              and restrien.dtresil > ctrat.dtdeb
                              and restrien.dtresil < DtFinBai
                            break by restrien.dtresil:
                        if restrien.dtresil <= today
                        then assign
                            poFusionBail:DateResilTrienPrec  = string(restrien.dtresil , "99/99/9999")
                            poFusionBail:DureeResilTrienPrec = (if restrien.nbanndur  > 0 then string(restrien.nbanndur)        + " " + outilTraduction:getLibelle(105401) else "")
                                                             + (if restrien.nbmoisdur > 0 then " " + string(restrien.nbmoisdur) + " " + outilTraduction:getLibelle(100680) else "")
                                                             + (if restrien.nbjoudur  > 0 then " " + string(restrien.nbjoudur)  + " " + outilTraduction:getLibelle(705253) else "")
                        .
                        else do:
                            assign
                                poFusionBail:DateResilTrien  = string(restrien.dtresil , "99/99/9999")
                                poFusionBail:DureeResilTrien = (if restrien.nbanndur > 0 then string(restrien.nbanndur)
                                                             + " "
                                                             + outilTraduction:getLibelle(105401) else "" )
                                                             + (if restrien.nbmoisdur > 0 then " " + string(restrien.nbmoisdur) + " " + outilTraduction:getLibelle(100680) else "")
                                                             + (if restrien.nbjoudur  > 0 then " " + string(restrien.nbjoudur)  + " " + outilTraduction:getLibelle(705253) else "").
                            leave.
                        end.
                    end.
                    assign
                        poFusionBail:DateResilTrienPrecLettre = outilFormatage:getDateFormat(date(poFusionBail:DateResilTrienPrec), "LL")
                        poFusionBail:DateResilTrienLettre     = outilFormatage:getDateFormat(date(poFusionBail:DateResilTrien),     "LL")
                    .
                end.
            end.
            when {&FUSION-LoyerBail}                      or when {&FUSION-LoyerBailenLettre}    or when {&FUSION-ChargeBail}
         or when {&FUSION-ChargeBailenLettre}             or when {&FUSION-Loyer}                or when {&FUSION-Loyer_en_Lettre}
         or when {&FUSION-Charges}                        or when {&FUSION-Charges_en_Lettre}    or when {&FUSION-Frais_Correspondance}
         or when {&FUSION-FraisDossier}                   or when {&FUSION-TVa}                  or when {&FUSION-Droit}
         or when {&FUSION-HonorLocat}                     or when {&FUSION-etatLieux}            or when {&FUSION-TotalHonoraireLocation}
         or when {&FUSION-TotalQuittanceProratee}         or when {&FUSION-FraisBail}            or when {&FUSION-DossierBail}
         or when {&FUSION-TVaBail}                        or when {&FUSION-DroitBail}            or when {&FUSION-HonoraireBail}
         or when {&FUSION-etatBail}                       or when {&FUSION-Depot_de_garantie}    or when {&FUSION-DepotGarantieenLettre}
         or when {&FUSION-DescriptifLoyerBail}            or when {&FUSION-DescriptifLoyer}      or when {&FUSION-ChargesFixe}
         or when {&FUSION-TotalQuittanceProrateeenLettre} or when {&FUSION-TaxeaddBail}          or when {&FUSION-Taxeadd}
         or when {&FUSION-ChargesFixeenLettre}            or when {&FUSION-DossierBailenLettre}  or when {&FUSION-DroitenLettre}
         or when {&FUSION-DroitBailenLettre}              or when {&FUSION-etatBailenLettre}     or when {&FUSION-etatLieuxenLettre}
         or when {&FUSION-FraisBailenLettre}              or when {&FUSION-FraisDossierenLettre} or when {&FUSION-FraisCorrespondanceenLettre}
         or when {&FUSION-TaxeaddenLettre}                or when {&FUSION-TaxeaddBailenLettre}  or when {&FUSION-TVaenLettre}
         or when {&FUSION-TVaBailenLettre}                or when {&FUSION-PrixM2}               or when {&FUSION-LoyerannuelBail}
         or when {&FUSION-LoyerannuelBailLettre}          or when {&FUSION-SurfUtilesUL}         or when {&FUSION-SurfPondereeUL}
         or when {&FUSION-PrixM2SurfPonderee}             or when {&FUSION-PrixM2annuel}         or when {&FUSION-LoyerannuelenCours}
         or when {&FUSION-LoyerannuelenCoursenLettre}     or when {&FUSION-LoyerMensuelenCours}  or when {&FUSION-PrixM2Mensuel}
         or when {&FUSION-RUMLocataire}                   or when {&FUSION-111828} then do:  /* NP #5501  NP 0707/1046 */
                if vlBloc5 then next boucleCHamp.
                vlBloc5 = true.
                assign
                    dMontantTmpDep = abs(SOLDECPT({&TYPECONTRAT-bail}, piNumeroBail, 0, "2751", ?)) +
                                     abs(SOLDECPT({&TYPECONTRAT-bail}, piNumeroBail, 0, "2752", ?)) +
                                     abs(SOLDECPT({&TYPECONTRAT-bail}, piNumeroBail, 0, "2754", ?))
                    poFusionBail:Depot_de_garantie = montantToCharacter(dMontantTmpDep, true)
                .
                voQuittance = chargeQuittance(piNumeroBail).
                assign
                    poFusionBail:Loyer                   = montantToCharacter (voQuittance:montantLoyer, true)
                    poFusionBail:LoyerEnLettre           = CONVCHIFFRE(voQuittance:montantLoyer)
                    poFusionBail:LoyerBail               = montantToCharacter (voQuittance:montantLoyerBail, true)
                    poFusionBail:LoyerBailEnLettre       = CONVCHIFFRE(voQuittance:montantLoyerBail)
                    poFusionBail:Charges                 = montantToCharacter (voQuittance:montantCharge, true)
                    poFusionBail:ChargeEnLettre          = CONVCHIFFRE(voQuittance:montantCharge)
                    poFusionBail:ChargeBail              = montantToCharacter (voQuittance:montantChargeBail, true)
                    poFusionBail:ChargeBailenLettre      = CONVCHIFFRE(voQuittance:montantChargeBail)
                    poFusionBail:ChargesFixe             = montantToCharacter (voQuittance:montantChargeFixe, true)
                    poFusionBail:ChargesFixeEnLettre     = CONVCHIFFRE(voQuittance:montantChargeFixe)
                    poFusionBail:Frais                   = montantToCharacter (voQuittance:montantFrais, true)
                    poFusionBail:FraisEnLettre           = CONVCHIFFRE(voQuittance:montantFrais)
                    poFusionBail:FraisBail               = montantToCharacter (voQuittance:montantFraisBail, true)
                    poFusionBail:FraisBailEnLettre       = CONVCHIFFRE(voQuittance:montantFraisBail)
                    poFusionBail:Dossier                 = montantToCharacter (voQuittance:montantDossier, true)
                    poFusionBail:DossierEnLettre         = CONVCHIFFRE(voQuittance:montantDossier)
                    poFusionBail:DossierBail             = montantToCharacter (voQuittance:montantDossierBail, true)
                    poFusionBail:DossierBailEnLettre     = CONVCHIFFRE(voQuittance:montantDossierBail)
                    poFusionBail:TVA                     = montantToCharacter (voQuittance:montantTVA, true)
                    poFusionBail:TVAEnLettre             = CONVCHIFFRE(voQuittance:montantTVA)
                    poFusionBail:TVABail                 = montantToCharacter (voQuittance:montantTVABail, true)
                    poFusionBail:TVABailEnLettre         = CONVCHIFFRE(voQuittance:montantTVABail)
                    poFusionBail:Droit                   = montantToCharacter (voQuittance:montantDroit, true)
                    poFusionBail:DroitEnLettre           = CONVCHIFFRE(voQuittance:montantDroit)
                    poFusionBail:DroitBail               = montantToCharacter (voQuittance:montantDroitBail, true)
                    poFusionBail:DroitBailEnLettre       = CONVCHIFFRE(voQuittance:montantDroitBail)
                    poFusionBail:Etat                    = montantToCharacter (voQuittance:montantEtat, true)
                    poFusionBail:EtatEnLettre            = CONVCHIFFRE(voQuittance:montantEtat)
                    poFusionBail:EtatBail                = montantToCharacter (voQuittance:montantEtatBail, true)
                    poFusionBail:EtatBailEnLettre        = CONVCHIFFRE(voQuittance:montantEtatBail)
                    poFusionBail:TaxeAdd                 = montantToCharacter (voQuittance:montantChargesAnnuel, true)
                    poFusionBail:TaxeAddEnLettre         = CONVCHIFFRE(voQuittance:montantChargesAnnuel)
                    poFusionBail:TaxeAddBail             = montantToCharacter (voQuittance:montantChargesAnnuelBail, true)
                    poFusionBail:TaxeAddBailEnLettre     = CONVCHIFFRE(voQuittance:montantChargesAnnuelBail)
                    poFusionBail:Honoraire               = montantToCharacter (voQuittance:montantHonoraire, true)
                    poFusionBail:HonoraireBail           = montantToCharacter (voQuittance:montantHonoraireBail, true)
                    poFusionBail:Depot_de_garantie       = montantToCharacter (voQuittance:montantDepotGarantie, true)
                    poFusionBail:DepotGarantieEnLettre   = CONVCHIFFRE(DECMONTANT(poFusionBail:Depot_de_garantie))
                    poFusionBail:DescriptifLoyer         = voQuittance:DescriptifLoyer
                    poFusionBail:DescriptifLoyerBail     = voQuittance:DescriptifLoyerBail
                    poFusionBail:TotalQuittance          = montantToCharacter (voQuittance:montantTotalQuittance, true)
                    poFusionBail:TotalQuittanceEnLettre  = CONVCHIFFRE(voQuittance:montantTotalQuittance)
                    dValHono                             = (DECMONTANT(poFusionBail:Honoraire) 
                                                         + DECMONTANT(poFusionBail:Etat) 
                                                         + DECMONTANT(poFusionBail:Dossier)) * (1 + (decimal(entry(1, outilTraduction:getlibelleParam("CDTVA", "00202"), "%")) / 100)) / 2
                    poFusionBail:TotalHonoraire = montantToCharacter(dValHono, true)
                    vdSfTotUse                    = 0
                    vdSfTotUtil                   = 0
                    vdSfTotPond                   = 0
                    vdSfTotCarrez                 = 0
                    poFusionBail:LoyerAnnuelBail              = montantToCharacter (voQuittance:montantLoyerAnnuelBail, true)
                    poFusionBail:LoyerAnnuelBailLettre        = CONVCHIFFRE(voQuittance:montantLoyerAnnuelBail)
                    poFusionBail:LoyerChargesAnnuelBail       = montantToCharacter (voQuittance:montantLoyerChargesAnnuelBail, true)
                    poFusionBail:LoyerChargesAnnuelBailLettre = CONVCHIFFRE(voQuittance:montantLoyerChargesAnnuelBail)
                .
                /* Ajout SY le 23/03/2009 -  fiche 0309/0164 */
                /* Loyer annuel equit si existe (sinon last aquit) */
                assign
                    poFusionBail:LoyerAnnuelEnCours         = montantToCharacter(voQuittance:montantLoyerAnnuel, true)
                    DcLoyerMensuelEnCours                   = decimal(voQuittance:montantLoyerAnnuel) / 12
                    poFusionBail:LoyerMensuelEnCours        = montantToCharacter(DcLoyerMensuelEnCours, true)
                    poFusionBail:LoyerAnnuelEnCoursEnlettre = CONVCHIFFRE(DcLoyerMensuelEnCours)
                .
                /*  Prix au M2 */
                for each unite no-lock
                   where unite.nomdt = integer(substring(string(piNumeroBail, "9999999999"), 1, 5))
                     and unite.noapp = integer(substring(string(piNumeroBail, "9999999999"), 6, 3))
                     and unite.noact = 0
                  , each cpuni no-lock
                   where cpuni.Nomdt = unite.nomdt
                     and cpuni.noapp = unite.noapp
                     and cpuni.nocmp = unite.nocmp
                 , first local no-lock
                   where local.noimm = unite.noimm 
                     and local.Nolot = cpuni.Nolot:
                    assign
                        vdSfTotUse    = vdSfTotUse    + if Local.FgDiv then cpuni.sflot else local.sfree
                        vdSfTotUtil   = vdSfTotUtil   + outilFormatage:ConvSurface(local.sfree, local.usree)
                        vdSfTotPond   = vdSfTotPond   + outilFormatage:ConvSurface(local.sfpde, local.uspde)
                        vdSfTotCarrez = vdSfTotCarrez + outilFormatage:ConvSurface(local.sfnon, local.usnon)
                    .
                end.
                assign
                    poFusionBail:PrixM2             = montantToCharacter(DECMONTANT(poFusionBail:Loyer) / vdSfTotUse, true) + "/M²"
                    poFusionBail:PrixM2SurfPonderee = montantToCharacter(DECMONTANT(poFusionBail:Loyer) / vdSfTotPond,true) + "/M²"
                    poFusionBail:PrixM2Annuel       = montantToCharacter(DECMONTANT(poFusionBail:LoyerAnnuelBail) / vdSfTotUse, true) + "/M²"
                    poFusionBail:PrixM2Mensuel      = montantToCharacter(DcLoyerMensuelEnCours / vdSfTotUse, true) + "/M²"
                    poFusionBail:PrixM2Carrez       = montantToCharacter(DECMONTANT(poFusionBail:Loyer) / vdSfTotCarrez, true) + "/M²"
                    poFusionBail:SurfUtilesUL       = montantToCharacter(vdSfTotUtil, false) + " M²"
                    poFusionBail:SurfPondereeUL     = montantToCharacter(vdSfTotPond, false) + " M²"
                .
            end.
            when {&FUSION-millieme_lot}                  or when {&FUSION-DescriptifUL}             or when {&FUSION-NoLotPrincipal}
         or when {&FUSION-NatureLot}                     or when {&FUSION-MilliemeLotCleGene}       or when {&FUSION-adresseLotPrincipal}
         or when {&FUSION-VilleLotPrincipal}             or when {&FUSION-SuiteadresseLotPrincipal} or when {&FUSION-CodePostalLotPrincipal}
         or when {&FUSION-ListeLotsSurfaceUL}            or when {&FUSION-NumUL}                    or when {&FUSION-DescriptifULSurface}
         or when {&FUSION-DtDebutIndisponibiliteUL}      or when {&FUSION-DtFinIndisponibiliteUL}   or when {&FUSION-MotifIndisponibiliteUL}
         or when {&FUSION-VilleCedexLotPrincipal}        or when {&FUSION-BurDistLotPrincipal}      or when {&FUSION-ComplementAdresseIdentLotPrincipal}
         or when {&FUSION-NbPiecesLotPrincipalEnLettres} or when {&FUSION-NoLot2UL}                 or when {&FUSION-BatimentLot2UL}
         or when {&FUSION-EtageLot2UL}                   or when {&FUSION-EscalierLot2UL}           or when {&FUSION-NatureLot2UL}
         or when {&FUSION-NoLot3UL}                      or when {&FUSION-BatimentLot3UL}           or when {&FUSION-EtageLot3UL}
         or when {&FUSION-EscalierLot3UL}                or when {&FUSION-NatureLot3UL}             or when {&FUSION-NoLot4UL}
         or when {&FUSION-BatimentLot4UL}                or when {&FUSION-EtageLot4UL}              or when {&FUSION-EscalierLot4UL}
         or when {&FUSION-NatureLot4UL} then do:
                if vlBloc6 then next boucleCHamp.
                vlBloc6 = true.

                /* Ajout SY le 29/04/2009 - Fiche relocation ou mandat location */
                if piNumeroBail = 0 and (NoFicheL <> 0 or NoMloUse <> 0) then do:
                    if NoFicheL = 0 then do:
                        find first mlo_ctrat no-lock
                             where mlo_ctrat.tpcon = {&TYPECONTRAT-MandatLocation}
                               and mlo_ctrat.nocon = NoMloUse no-error.
                        if available mlo_ctrat then do:
                            /* fiche de relocation */
                            find first flo_intnt no-lock   /* fiche location */
                                 where flo_intnt.tpcon = mlo_ctrat.tpcon
                                   and flo_intnt.nocon = mlo_ctrat.nocon
                                   and flo_intnt.tpidt = "06000" no-error.
                            if available flo_intnt then NoFicheL = flo_intnt.noidt.
                        end.
                    end.
                    if NoFicheL <> 0 then do:
                        find first location no-lock 
                             where location.nofiche = NoFicheL no-error.
                        if available location then do:
                            assign 
                                NoFicheL = location.nofiche
                                viNumeroContrat = location.nocon
                                viNumeroApp = location.noapp
                            .
                        end.
                    end.
                end.
                else assign
                    viNumeroContrat = integer(substring(string(piNumeroBail, "9999999999"), 1, 5))
                    viNumeroApp     = integer(substring(string(piNumeroBail, "9999999999"), 6, 3))
                .
                poFusionBail:NumUL = string(viNumeroApp , "999").
                find first unite no-lock
                     where unite.nomdt = viNumeroContrat
                       and unite.noapp = viNumeroApp
                       and unite.noact = 0 no-error.
                if available unite 
                then do:
                    if num-entries(unite.lbdiv, "&") >= 1
                    then vcTmp = entry(1, unite.lbdiv, "&").
                    else vcTmp = "". 

                    poFusionBail:DtDebutIndisponibiliteUL = dateToCharacter(date(vcTmp)).

                    if num-entries(unite.lbdiv, "&") >= 2
                    then vcTmp = entry(2, unite.lbdiv, "&").
                    else vcTmp = "". 

                    poFusionBail:DtFinIndisponibiliteUL = dateToCharacter(date(vcTmp)).

                    if num-entries(unite.lbdiv,"&") >= 3
                    then do:
                        find first pclie no-lock
                             where pclie.tppar = "SLO00"
                               and pclie.zon01 = ENTRY(3,unite.lbdiv,"&") no-error.
                        vcTmp = if available pclie then pclie.zon02 else "".
                    end.
                    else vcTmp = "".
                    poFusionBail:MotifIndisponibiliteUL = vcTmp.
                    find first cpuni no-lock                   /* Modif SY le 02/07/2015 : Lot principal */
                         where cpuni.nomdt = unite.nomdt
                           and cpuni.noapp = unite.noapp
                           and cpuni.nocmp = unite.nocmp no-error.
                    if available cpuni then do:
                        poFusionBail:NoLotPrincipal = string(unite.nolot).
                        find first local no-lock
                             where local.nolot = unite.nolot
                               and local.noimm = unite.noimm no-error.
                        if available local 
                        then do:
                            poFusionBail:NatureLot = outilTraduction:getlibelleParam("NTLOT", local.ntlot).
                            run chargeAdresse({&TYPEBIEN-lot}, local.noloc, output voAdresse).
                            assign
                                poFusionBail:AdresseLotPrincipal                = voAdresse:Adresse
                                poFusionBail:SuiteAdresseLotPrincipal           = voAdresse:ComplementVoie
                                poFusionBail:CodePostalLotPrincipal             = voAdresse:CodePostal
                                poFusionBail:VilleLotPrincipal                  = voAdresse:Ville
                                poFusionBail:VilleCedexLotPrincipal             = voAdresse:Cedex
                                poFusionBail:ComplementAdresseIdentLotPrincipal = voAdresse:IdentAdresse
                                poFusionBail:BurDistLotPrincipal                = BureauDistrib({&TYPEBIEN-lot}, local.noloc, 1)
                                poFusionBail:NbPiecesLotPrincipalEnLettres      = ConvChifLet(local.nbprf)
                            .
                        end.
                    end.
                    viCptLotUL = 0.
                    for each cpuni no-lock
                       where cpuni.nomdt = unite.nomdt
                         and cpuni.noapp = unite.noapp
                         and cpuni.nocmp = unite.nocmp
                     , first local no-lock
                       where local.noimm = cpuni.noimm
                         and local.nolot = cpuni.nolot:
                        for each milli no-lock
                           where milli.noimm = local.noimm
                             and milli.nolot = local.nolot
                          , each clemi no-lock
                           where clemi.noimm = local.noimm
                             and clemi.cdcle = milli.cdcle
                          break by milli.nolot:
                            if first-of(milli.nolot) 
                            then do:
                                /*  Recherche 1ère clé générale que l'on trouve **/
                                find first bClemi
                                     where bClemi.noimm = local.noimm
                                       and bClemi.cdcle = milli.cdcle
                                       and bClemi.tpcle = "00001" no-lock no-error.
                                if available bclemi
                                then poFusionBail:MilliemeLotCleGene = poFusionBail:MilliemeLotCleGene 
                                                                     + (if poFusionBail:MilliemeLotCleGene = "" then "" else chr(10)) 
                                                                     + outilTraduction:getLibelle(100361) 
                                                                     + " " 
                                                                     + string(milli.nolot) 
                                                                     + " " 
                                                                     + outilTraduction:getLibelle(103157) + " " + string(milli.nbpar) + "/" + string(bclemi.nbtot)
                                .
                            end.
                            poFusionBail:Millieme_Lot = poFusionBail:Millieme_Lot 
                                                      + outilTraduction:getLibelle(100598)
                                                      + " : "
                                                      + string(milli.nolot)
                                                      + " " 
                                                      + outilTraduction:getLibelle(103157)
                                                      + " "
                                                      + clemi.lbcle
                                                      + chr(9)
                                                      + string(milli.nbpar)
                                                      + "/" 
                                                      + string(clemi.nbtot)
                                                      + chr(10)
                            .
                        end.
                        /*  Descriptif UL */
                        assign
                            poFusionBail:DescriptifUL        = poFusionBail:DescriptifUL 
                                                             + (if poFusionBail:DescriptifUL = "" then "" else chr(10)) 
                                                             + trim(string(local.nolot))
                                                             + chr(9) 
                                                             + trim(string(outilTraduction:getlibelleParam("NTLOT", local.ntlot),"X(30)"))
                                                             + chr(9) 
                                                             + trim(string(local.cdeta))
                                                             + chr(9) 
                                                             + trim(string(local.cdpte))
                            poFusionBail:DescriptifULSurface = poFusionBail:DescriptifULSurface 
                                                             + (if poFusionBail:DescriptifULSurface = "" then "" else chr(10)) 
                                                             + trim(string(local.nolot))                          
                                                             + chr(9) 
                                                             + trim(string(outilTraduction:getlibelleParam("NTLOT", local.ntlot), "X(30)"))
                                                             + chr(9) 
                                                             + trim(string(local.cdeta))
                                                             + chr(9) 
                                                             + trim(string(local.cdpte))
                                                             + chr(9) 
                                                             + trim(montantToCharacter(local.sfree,false)) + outilTraduction:getlibelleParam("UTSUR", local.usree)
                        /*  Liste des Lots avec leurs surfaces */
                            poFusionBail:ListeLotsSurfaceUL  = poFusionBail:ListeLotsSurfaceUL
                                                             + (if poFusionBail:ListeLotsSurfaceUL = "" then "" else chr(10))
                                                             + trim(string(local.nolot))
                                                             + chr(9)
                                                             + trim(string(outilTraduction:getlibelleParam("NTLOT", local.ntlot), "X(30)"))
                                                             + chr(9)
                                                             + trim(montantToCharacter(local.sfree, false)) + outilTraduction:getlibelleParam("UTSUR", local.usree) 
                                                             + chr(9)
                                                             + trim(montantToCharacter(local.sfpde, false)) + outilTraduction:getlibelleParam("UTSUR", local.uspde)
                        .
                        /* SY 0516/0027 */
                        viCptLotUL = viCptLotUL + 1.
                        case viCptLotUL:
                            when 2 then assign
                                poFusionBail:NoLot2UL       = string(local.nolot)
                                poFusionBail:BatimentLot2UL = local.cdbat
                                poFusionBail:EtageLot2UL    = local.cdeta
                                poFusionBail:EscalierLot2UL = local.cdesc
                                poFusionBail:NatureLot2UL   = outilTraduction:getlibelleParam("NTLOT", local.ntlot)
                            .
                            when 3 then assign
                                poFusionBail:NoLot3UL       = string(local.nolot)
                                poFusionBail:BatimentLot3UL = local.cdbat
                                poFusionBail:EtageLot3UL    = local.cdeta
                                poFusionBail:EscalierLot3UL = local.cdesc
                                poFusionBail:NatureLot3UL   = outilTraduction:getlibelleParam("NTLOT", local.ntlot)
                            .
                            when 4 then assign
                                poFusionBail:NoLot4UL       = string(local.nolot)
                                poFusionBail:BatimentLot4UL = local.cdbat
                                poFusionBail:EtageLot4UL    = local.cdeta
                                poFusionBail:EscalierLot4UL = local.cdesc
                                poFusionBail:NatureLot4UL   = outilTraduction:getlibelleParam("NTLOT", local.ntlot)
                            .
                        end case. 
                    end. /* FOR EACH cpuni */
                end.
            end.
            when {&FUSION-Type_Indice}                 or when {&FUSION-Date_Indice}                     or when {&FUSION-Periodicite_Revision}
         or when {&FUSION-JourMoisRevision}            or when {&FUSION-Valeur_indice_Revision}          or when {&FUSION-Taux_Revision}
         or when {&FUSION-TypeIndicePrec}              or when {&FUSION-ValeurIndicePrec}                or when {&FUSION-LoyerPrec}
         or when {&FUSION-DateDerRevision}             or when {&FUSION-DateNouvRevision}                or when {&FUSION-DateIndiceSuiv}
         or when {&FUSION-PourVariationSuiv}           or when {&FUSION-ValeurIndiceSuiv}                or when {&FUSION-LoyerPrecenLettre}
         or when {&FUSION-DateLDerRevision}            or when {&FUSION-DateLNouvRevision}               or when {&FUSION-DateDerRevisionLettre}
         or when {&FUSION-DateNouvRevisionLettre}      or when {&FUSION-DateaparutionIndice}             or when {&FUSION-DateLaparutionIndice}
         or when {&FUSION-DateaparutionIndiceenLettre} or when {&FUSION-TacheCalendrier}                 or when {&FUSION-DateaparutionIndiceSuiv}
         or when {&FUSION-DateLaparutionIndiceSuiv}    or when {&FUSION-DateaparutionIndiceSuivenLettre} or when {&FUSION-MtVariationLoyer}
         or when {&FUSION-ProchainIndiceBail} then do:
                if vlBloc7 then next boucleCHamp.
                vlBloc7 = true.

                find last Tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-revision} no-error.
                if available Tache then do:
                    /* PeriodeRevision JourMoisRevision */
                    assign
                         poFusionBail:Periodicite_Revision    = string(Tache.duree) 
                                                              + " " 
                                                              + outilTraduction:getlibelleParam("UTPER", "00001")
                         poFusionBail:JourMoisRevision        = outilFormatage:getDateFormat(tache.dtdeb, "C")
                         poFusionBail:DateDerRevision         = dateToCharacter(tache.dtdeb)
                         poFusionBail:DateLDerRevision        = outilFormatage:getDateFormat(tache.dtdeb, "L")
                         poFusionBail:DateDerRevisionLettre   = outilFormatage:getDateFormat(tache.dtdeb, "LL")
                         poFusionBail:DateNouvRevision        = dateToCharacter(tache.dtfin)
                         poFusionBail:DateLNouvRevision       = outilFormatage:getDateFormat(tache.dtfin, "L")
                         poFusionBail:DateNouvRevisionLettre  = outilFormatage:getDateFormat(tache.dtfin, "LL")
                         /* Sauvegarde du montant du loyer */
                         dMontantTempo = tache.mtreg
                         poFusionBail:TacheCalendrier = string(tache.cdhon = "00001", "Oui/Non").
                    .
                    /* Indice en cours */
                    find first indrv no-lock
                         where indrv.cdirv = integer(tache.dcreg)
                           and indrv.anper = integer(tache.cdreg)
                           and indrv.noper = integer(tache.ntreg) no-error.
                    if available indrv then do:
                        assign
                            poFusionBail:Valeur_indice_Revision      = montantToCharacter(indrv.vlirv, false)
                            poFusionBail:Taux_Revision               = string(indrv.TxIrv, "->>9.9999")
                            poFusionBail:DateAparutionIndice         = dateToCharacter(indrv.dtpjo)   
                            poFusionBail:DateLAparutionIndice        = outilFormatage:getDateFormat(indrv.dtpjo, "L")
                            poFusionBail:DateAparutionIndiceEnLettre = outilFormatage:getDateFormat(indrv.dtpjo, "LL")
                        .
                        find first lsirv no-lock
                             where lsirv.cdirv = indrv.cdirv no-error.
                        if available lsirv then do:
                            poFusionBail:Type_Indice = lsirv.lblng.
                            poFusionBail:Date_Indice = frmDateIndice (lsirv.cdper, indrv.anper, indrv.noper).
                            poFusionBail:ProchainIndiceBail = frmDateIndice (lsirv.cdper, indrv.anper + tache.duree, indrv.noper).
                        end.
                    end.
                    /*  Indice Suivant */
                    find first indrv no-lock
                         where indrv.cdirv = integer(tache.dcreg)
                           and indrv.anper = integer(tache.cdreg) + tache.duree
                           and indrv.noper = integer(tache.ntreg) no-error.
                    if available indrv then do:
                        assign
                            poFusionBail:valeurIndiceSuiv    = montantToCharacter(indrv.vlirv, false)
                            poFusionBail:PourVariationSuiv   = string(truncate(indrv.vlirv * 100 / indrv.vlirv - 100, 4), "->>9.9999")        /** 1109/0076 **/
                        .
                        assign
                            poFusionBail:DateAparutionIndiceSuiv         = dateToCharacter(indrv.dtpjo)
                            poFusionBail:DateLAparutionIndiceSuiv        = outilFormatage:getDateFormat(indrv.dtpjo, "L")
                            poFusionBail:DateAparutionIndiceSuivenLettre = outilFormatage:getDateFormat(indrv.dtpjo, "LL")
                        .
    
                        find lsirv no-lock where lsirv.cdirv = indrv.cdirv no-error.
                        if available lsirv /*  Recherche du libelle explicite de l'indice */ 
                        then poFusionBail:dateIndiceSuiv = frmDateIndice (lsirv.cdper, indrv.anper, indrv.noper).
                    end.
                    /* Indice Precedent */
                    find prev tache no-lock
                        where tache.tpcon = {&TYPECONTRAT-bail}
                          and tache.nocon = piNumeroBail
                          and tache.tptac = {&TYPETACHE-revision} no-error.
                    if available Tache then do:
                        /* LoyerPrec */
                        assign
                            poFusionBail:LoyerPrec         = montantToCharacter(tache.MtReg, true)
                            poFusionBail:LoyerPrecEnLettre = CONVCHIFFRE(tache.MtReg)
                        .
                        poFusionBail:MtVariationLoyer = montantToCharacter(dMontantTempo - tache.MtReg, true).
                        /*  ValeurIndice Taux_Revision*/
                        find first indrv no-lock
                             where indrv.cdirv = integer(tache.dcreg)
                               and indrv.anper = integer(tache.cdreg)
                               and indrv.noper = integer(tache.ntreg) no-error.
                        if available indrv then do:
                            poFusionBail:valeurIndicePrec    = montantToCharacter(indrv.vlirv,false).
                            find first lsirv no-lock
                                 where lsirv.cdirv = indrv.cdirv no-error.
                            if available lsirv then poFusionBail:typeIndicePrec = lsirv.lblng.
                        end.
                    end.
                end.
                else poFusionBail:TacheCalendrier = "".
            end.
            when {&FUSION-Terme_paiement}         or when {&FUSION-Periodicite_paiement} or when {&FUSION-ModePaiement}
         or when {&FUSION-DateSortieBail}         or when {&FUSION-DateL_de_Sortie}      or when {&FUSION-DateSortieBailLettre}
         or when {&FUSION-FgassuGarantieLoyerLoc} or when {&FUSION-JourPaiement}         or when {&FUSION-JourPaiementenLettre} then do:
                if vlBloc8 then next boucleCHamp.
                vlBloc8 = true.

                find pclie where pclie.TpPar = "PRLAU" and pclie.zon01 = "00001" no-lock no-error.
                if available pclie then viNoJouPrl-Cab = integer(trim(Pclie.zon02)).
                find last tache no-lock
                    where tache.TpTac = {&TYPETACHE-quittancement}
                      and tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail no-error.
                if available tache then do:
                    assign
                        poFusionBail:DateSortieBail       = dateToCharacter(tache.dtfin)
                        poFusionBail:Date_de_Sortie       = dateToCharacter(tache.dtfin)
                        poFusionBail:DateL_de_Sortie      = outilFormatage:getDateFormat(tache.dtfin, "L")
                        poFusionBail:DateSortieBailLettre = outilFormatage:getDateFormat(tache.dtfin, "LL")
                        poFusionBail:Periodicite_paiement = outilTraduction:getlibelleParam("PDQTT", tache.pdges)   /* modif SY le 10/09/2015 - libellé long remis dans sys_pr.nome1 dans version >= 12.6  */
                        poFusionBail:Terme_paiement       = outilTraduction:getlibelleParam("TEQTT", tache.ntges)
                        poFusionBail:ModePaiement         = outilTraduction:getLibelleProg("O_MDG", tache.cdreg)
                        viJourPaiement                    = tache.duree
                    .
                    if viJourPaiement = 0 and lookup(tache.cdreg, "22003,22013") > 0 then viJourPaiement = viNoJouPrl-Cab.
                end.
                if viJourPaiement = 0 then viJourPaiement = 1.
                poFusionBail:JourPaiement = string(viJourPaiement).
                poFusionBail:JourPaiementEnLettre = ConvChifLet (viJourPaiement).
        
                vcAssuGarantieLoyerLoc = "Non".
                find last tache no-lock
                    where tache.TpTac = {&TYPETACHE-GarantieLoyer}
                      and tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.duree > 0 no-error.
                if available tache then vcAssuGarantieLoyerLoc = "Oui".
                assign poFusionBail:fgAssuGarantieLoyerLoc = vcAssuGarantieLoyerLoc.         /* SY 1213/0071 */
            end.
            when {&FUSION-TpDepotGarantie} or when {&FUSION-NbMoisDG}
            then do:
                find first tache no-lock
                     where tache.tptac = {&TYPETACHE-depotGarantieBail}
                       and tache.notac = 1
                       and tache.tpcon = {&TYPECONTRAT-bail}
                       and tache.nocon = piNumeroBail no-error.
                if available tache 
                then assign
                    poFusionBail:TpDepotGarantie = if tache.ntges = "18008" then lc(outilTraduction:getLibelle(101184)) else outilTraduction:getLibelle(104782)
                    poFusionBail:NbMoisDG        = replace(string(decimal(if tache.tpges = "" then "0" else tache.tpges)),".",",")
                .
            end.
            when {&FUSION-Listeactivite} or when {&FUSION-DateCommunicationCa} or when {&FUSION-PourPenaliteCa}
            then do:
                for each chaff no-lock
                   where chaff.tpcon = {&TYPECONTRAT-bail}
                     and chaff.nocon = piNumeroBail
                break by chaff.tpcon by chaff.nocon by chaff.noper by chaff.noact by chaff.nocal:
                if last-of(chaff.nocal) 
                then poFusionBail:ListeActivite = if poFusionBail:ListeActivite = ""
                                                  then chaff.lbact
                                                  else poFusionBail:ListeActivite + chr(10) + chaff.lbact.
                if last(chaff.nocal) 
                then do:
                    find last echlo no-lock
                        where echlo.tpcon = chaff.tpcon
                          and echlo.nocon = chaff.nocon no-error.
                    if available echlo then do:
                        assign
                            poFusionBail:PourPenaliteCA      = string(echlo.penal)
                            poFusionBail:DateCommunicationCA = string(echlo.jrcom, "99") + "/" +
                                                               string(echlo.mscom, "99") + "/" +
                                                               string(year(chaff.dtfin))
                            .
                            do while date(poFusionBail:DateCommunicationCA) < chaff.dtfin:
                                poFusionBail:DateCommunicationCA = string(echlo.jrcom, "99") + "/" +
                                                                   string(echlo.mscom, "99") + "/" +
                                                                   string(year(date(poFusionBail:DateCommunicationCA)) + 1).
                            end.
                        end.
                    end.
                end.
            end.
            when {&FUSION-LoyerContractuel} or when {&FUSION-LoyerContractuelenLettre} or when {&FUSION-CalEvLoyerContractuelInitial} 
         or when {&FUSION-CalEvVariationPourcentage} then do:
                if vlBloc9 then next boucleCHamp.
                vlBloc9 = true.

                find first tache no-lock
                     where tache.tptac = {&TYPETACHE-loyerContractuel}
                       and tache.notac = 1
                       and tache.tpcon = {&TYPECONTRAT-bail}
                       and tache.nocon = piNumeroBail no-error.
                if available tache 
                then do:
                    assign
                        poFusionBail:LoyerContractuel             = montantToCharacter(tache.mtreg, true)
                        poFusionBail:LoyerContractuelEnLettre     = CONVCHIFFRE(tache.mtreg)
                        dPoucentageVariation                      = ((tache.mtreg - (decimal(tache.lbdiv) / 100)) / (decimal(tache.lbdiv) / 100)) * 100
                        poFusionBail:CalEvLoyerContractuelInitial = montantToCharacter(decimal(tache.lbdiv) / 100, true)
                        poFusionBail:CalEvVariationPourcentage    = string(decMontant(string(dPoucentageVariation)))
                    .
                end.
            end.
            when {&FUSION-Loyerannuel} then do:   /* LoyerAnnuel */
                find last tache no-lock
                    where tache.TpTac = {&TYPETACHE-quittancement}
                      and tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail no-error.
                if available tache then viNbPerUse = 12 / integer(substring(tache.pdges, 1, 3)).
                /* dernière quittance historisée HORS facture locataire */
                find last aquit no-lock
                    where aquit.noloc = piNumeroBail
                      and aquit.fgfac = false                /* modif SY le 19/03/2009 */
                      use-index ix_aquit03 no-error.
                if available aquit 
                then do:
                    vdSoldeCpt = 0.
                    do viBoucle = 1 to aquit.nbrub: 
                        if entry(1, aquit.tbrub[viBoucle], "|") = "101" 
                        then vdSoldeCpt = vdSoldeCpt + decimal(entry(5, aquit.tbrub[viBoucle], "|")).
                    end.
                    assign
                        poFusionBail:LoyerAnnuel         = montantToCharacter(vdSoldeCpt * viNbPerUse, true)
                        poFusionBail:LoyerAnnuelEnLettre = CONVCHIFFRE(vdSoldeCpt * viNbPerUse)
                    .
                end.
            end.
            when {&FUSION-LstGarantLocataire} or when {&FUSION-LstadresseGarant}       or when {&FUSION-DescriptifGarant}
         or when {&FUSION-PortableGarant}     or when {&FUSION-TelephoneGarant}        or when {&FUSION-BanqueGarant}
         or when {&FUSION-TituRibGarant}      or when {&FUSION-NoCompteBancaireGarant} or when {&FUSION-NoBICGarant}
            then do:
                if vlBloc10 then next boucleCHamp.
                vlBloc10 = true.

                poFusionBail:LstGarantLocataire = caps(outilTraduction:getLibelle(701061)) + chr(9) +
                                                  caps(outilTraduction:getLibelle(105414)) + chr(9) +
                                                  caps(outilTraduction:getLibelle(105430)) + chr(9) +
                                                  caps(outilTraduction:getLibelle(103650)) + chr(9) +
                                                  caps(outilTraduction:getLibelle(103651)) + chr(9) +
                                                  caps(outilTraduction:getLibelle(703468))
                .
                for each Intnt no-lock
                   where intnt.tpidt = "00013"
                     and intnt.tpcon = {&TYPECONTRAT-bail}
                     and intnt.nocon = piNumeroBail:
                     /*  Adresse Garant */
                    poFusionBail:LstAdresseGarant = if poFusionBail:LstAdresseGarant <> "" then poFusionBail:LstAdresseGarant + chr(10) else "".

                    voRole = chargeRole("00013", intnt.noidt, piNumeroDocument).
                    assign poFusionBail:LstAdresseGarant = poFusionBail:LstAdresseGarant + voRole:nomComplet.

                    voAdresse = chargeAdresse("00013", intnt.noidt, piNumeroDocument).
                    poFusionBail:LstAdresseGarant = poFusionBail:LstAdresseGarant
                                                  + chr(9) 
                                                  + voAdresse:adresse
                                                  + chr(9) 
                                                  + voAdresse:codePostal
                                                  + chr(9) 
                                                  + voAdresse:ville
                    .
                    poFusionBail:LstAdresseGarant = poFusionBail:LstAdresseGarant + chr(10) + chr(9) + voAdresse:complementVoie.
                    poFusionBail:LstAdresseGarant = poFusionBail:LstAdresseGarant + chr(10) + chr(9) + voAdresse:telephone.
                    assign
                        poFusionBail:PortableGarant   = voAdresse:Portable
                        poFusionBail:TelephoneGarant  = voAdresse:Telephone
                    .
                    /* Liste des Garants du Locataire */
                    poFusionBail:LstGarantLocataire = poFusionBail:LstGarantLocataire +
                                                      (if poFusionBail:LstGarantLocataire = "" then "" else chr(10)) + outilFormatage:getNomTiers("00013", intnt.noidt).
                    for each tache no-lock
                       where tache.tpcon = intnt.tpcon
                         and tache.nocon = intnt.nocon
                         and tache.tptac = "04131":
                        poFusionBail:LstGarantLocataire = poFusionBail:LstGarantLocataire
                                                        + chr(9)
                                                        + tache.tpfin 
                                                        + chr(9) 
                                                        + outilTraduction:getlibelleParam("TPACT",tache.pdges) 
                                                        + chr(9) 
                                                        + dateToCharacter(tache.dtdeb)
                                                        + chr(9) 
                                                        + dateToCharacter(tache.dtfin)
                                                        + chr(9)
                                                        + montantToCharacter(tache.mtreg,true).
                    end.

                    /* Descriptif Garant */
                    poFusionBail:DescriptifGarant = description(intnt.tpidt, intnt.noidt, poFusionBail:DescriptifGarant, piNumeroDocument).
                    voBanque = chargeBanque("00013", intnt.noidt).
                    assign
                        poFusionBail:BanqueGarant           = voBanque:Banque-Domiciliation
                        poFusionBail:TituRibGarant          = voBanque:Banque-Titulaire
                        poFusionBail:NoCompteBancaireGarant = voBanque:Banque-IBAN
                        poFusionBail:NoBICGarant            = voBanque:Banque-BIC
                    .
                end.
            end.
            when {&FUSION-LstallocataireCaF} or when {&FUSION-NoCaFLocataire} then do:
                if vlBloc11 then next boucleCHamp.
                vlBloc11 = true.

                for each tbEnt no-lock
                   where integer(entry(1,iden2,separ[1])) = piNumeroBail
                     and tbent.cdent = "00001":
                    if num-entries(Tbent.iden2,separ[1]) = 2 
                    then poFusionBail:LstAllocataireCAF = poFusionBail:LstAllocataireCAF +
                                                          (if poFusionBail:LstAllocataireCAF = "" then "" else chr(10)) +
                                                          tbent.iden1 + chr(9) + outilFormatage:getNomTiers2("00051", integer(entry(2, Tbent.iden2, SEPAR[1])), true).
                    else assign
                        poFusionBail:NoCAFLocataire    = tbent.iden1
                        poFusionBail:LstAllocataireCAF = poFusionBail:LstAllocataireCAF +
                                                         (if poFusionBail:LstAllocataireCAF = "" then "" else chr(10)) +
                                                         tbent.iden1 + chr(9) + outilFormatage:getNomTiers2({&TYPEROLE-locataire}, piNumeroBail, false)
                    .
                end.
            end.
            when {&FUSION-Date1erQuit}                     or when {&FUSION-Datel1erQuit} or when {&FUSION-Date1erQuitLettre}
         or when {&FUSION-TotalPremiereechperiodecomplete} or when {&FUSION-TotalPremiereechperiodecompleteenLettre}
            then do:
                if vlBloc12 then next boucleCHamp.
                vlBloc12 = true.

                find first aquit no-lock
                     where aquit.noloc = piNumeroBail no-error.
                do while available aquit and aquit.mtqtt = 0:
                    find next aquit no-lock
                        where aquit.noloc = piNumeroBail no-error.
                end.
                if available aquit 
                then do:
                    assign
                        poFusionBail:Date1erQuit       = dateToCharacter(aquit.dtdeb)
                        poFusionBail:DateL1erQuit      = outilFormatage:getDateFormat(aquit.dtdeb, "L")
                        poFusionBail:Date1erQuitLettre = outilFormatage:getDateFormat(aquit.dtdeb, "LL")
                    .
                    /* SY 0715/0009 */
                    vdMtTotalPremiereEchperiodecomplete = 0.
                    do viBoucle = 1 to aquit.nbrub:
                        if entry(1, aquit.tbrub[viBoucle], "|") = "104" then next.        /* sauf franchise */
                        if num-entries(aquit.tbrub[viBoucle], "|") < 6 then next. 
                        vdMtTotalPremiereEchperiodecomplete = vdMtTotalPremiereEchperiodecomplete + decimal(entry(5, aquit.tbrub[viBoucle], "|")).    /* montant Brut */
                    end.
                end.
                else do:
                    find first equit no-lock
                         where equit.noloc = piNumeroBail no-error.
                    do while available equit and equit.mtqtt = 0:
                        find next equit no-lock
                            where equit.noloc = piNumeroBail no-error.
                    end.
                    if available equit
                    then do:
                        assign
                            poFusionBail:Date1erQuit       = dateToCharacter(equit.dtdeb)
                            poFusionBail:DateL1erQuit      = outilFormatage:getDateFormat(equit.dtdeb, "L")
                            poFusionBail:Date1erQuitLettre = outilFormatage:getDateFormat(equit.dtdeb, "LL")
                        .
                        /* SY 0715/0009 */
                        vdMtTotalPremiereEchperiodecomplete = 0.
                        do viBoucle = 1 to equit.nbrub:
                            if equit.tbrub[viBoucle] = 104 then next.        /* sauf franchise */
                            vdMtTotalPremiereEchperiodecomplete = vdMtTotalPremiereEchperiodecomplete + equit.tbtot[viBoucle].
                        end.
                    end.
                end.
                assign
                    poFusionBail:TotalPremiereEchperiodecomplete         = montantToCharacter(vdMtTotalPremiereEchperiodecomplete, true)
                    poFusionBail:TotalPremiereEchperiodecompleteEnLettre = CONVCHIFFRE(vdMtTotalPremiereEchperiodecomplete)
                .
            end.
            when {&FUSION-NoBICLocataire}                  or when {&FUSION-BanqueLocataire}            or when {&FUSION-TituRibLoc}
         or when {&FUSION-NoBICLocataire}                  or when {&FUSION-RUMLocataire}               or when {&FUSION-DateSignatureRUMLocataire}
         or when {&FUSION-DateDernUtilisationRUMLocataire} or when {&FUSION-NomReclamPrelSePaLocataire} or when {&FUSION-NomModifPrelSePaLocataire}
         or when {&FUSION-NomCreancierLocataire}           or when {&FUSION-ICSCreancierLocataire}      or when {&FUSION-IBaNCreancierLocataire}
         or when {&FUSION-BICCreancierLocataire}           or when {&FUSION-BanqueCreancierLocataire}
            then do:
                if vlBloc13 then next boucleCHamp.
                vlBloc13 = true.

                find first rlctt no-lock
                     where rlctt.tpidt = {&TYPEROLE-locataire}
                       and rlctt.noidt = piNumeroBail
                       and rlctt.tpct2 = "01038" no-error.
                if available rlctt 
                then find first ctanx no-lock
                          where ctanx.tpcon = rlctt.tpct2
                            and ctanx.nocon = rlctt.noct2 no-error.
                else do:
                    find first roles no-lock
                         where roles.tprol = {&TYPEROLE-locataire}
                           and roles.norol = piNumeroBail no-error.
                    if available roles 
                    then find first ctanx no-lock
                             where ctanx.tprol = {&TYPEROLE-tiers}
                               and ctanx.norol = roles.notie
                               and ctanx.tpact = "DEFAU"
                               and ctanx.tpcon = {&TYPECONTRAT-prive} no-error.
                end.
                if available ctanx 
                then assign
                    poFusionBail:BanqueLocataire             = ctanx.lbdom
                    poFusionBail:NoCompteBancaireLocataire   = ctanx.iban
                    poFusionBail:TituRibLoc                  = ctanx.lbtit
                    poFusionBail:NoBICLocataire              = ctanx.bicod.
                .
                /* SY 0511/0023 Recherche de la banque de prélèvement du locataire si elle existe */
                run compta/rumrolct.p persistent set vhrumlotct.
                run rumRoleContrat in vhrumlotct( integer(mtoken:cRefGerance) 
                                                , integer(substring(string(piNumeroBail, "9999999999"), 1, 5)) 
                                                , {&TYPEROLE-locataire}
                                                , input piNumeroBail
                                                , {&TYPECONTRAT-bail}
                                                , input piNumeroBail
                                                , today                        /* (date de prélèvement si connue) */
                                                , output iNomandatSEPA
                                                , output RUMLocataire
                                                , output ICSCreancierLocataire
                                                , output NomCreancierLocataire
                                                , output LbDivParRUM).
                run destroy in vhrumlotct.
                if iNomandatSEPA > 0 
                then do:
                    find first mandatSepa no-lock
                         where mandatSEPA.noMPrelSEPA = iNomandatSEPA  no-error.
                    if available mandatsepa
                    then do:
                        poFusionBail:DateSignatureRUMLocataire       = dateToCharacter(mandatSEPA.dtsig).
                        poFusionBail:DateDernUtilisationRUMLocataire = dateToCharacter(mandatSEPA.dtUtilisation).
                        poFusionBail:LieuSignatureRUMLocataire       = mandatSEPA.lisig.
                        poFusionBail:DatePreNotifRUMLocataire        = dateToCharacter(mandatSEPA.dtNotif).
                        poFusionBail:DateEcheanceRUMLocataire        = dateToCharacter(mandatSEPA.dtEchNotif).
                        poFusionBail:MontantEcheanceRUMLocataire     = montantToCharacter(mandatSEPA.MtNotif, true).
                    end.
                    if num-entries(LbDivParRUM , "|") >= 4 
                    then do:
                        assign
                            poFusionBail:IBANCreancierLocataire = entry(3, LbDivParRUM , "|")
                            poFusionBail:BICCreancierLocataire  = entry(4, LbDivParRUM , "|")
                        .
                    end.
                end. 
                find first pclie where pclie.tppar = "SEPA" no-lock no-error.        /* Modif SY le 12/02/2014 : ajout NO-LOCK */
                if available pclie 
                then do:
                    if num-entries(pclie.zon03, "|") >= 2 
                    then DateDebPSEPA = integer2Date(integer(entry(1, pclie.zon03, "|"))).        /* AAAAMMJJ -> DATE */
                    poFusionBail:DatePassagePrelSEPALocataire = dateToCharacter(DateDebPSEPA).
                    if num-entries(pclie.zon05, "|" ) >= 2 
                    then poFusionBail:DelaiNotifPrelSEPALocataire = entry(1 , pclie.zon05, "|" ).
                    LbZone = entry(1, pclie.zon07, "|" ).    /* gérance */
                    poFusionBail:NomReclamPrelSEPALocataire = trim(entry(1, LbZone, separ[2])) + " " + trim(entry(2, LbZone , separ[2])).
                    LbZone = entry(1, pclie.zon08, "|" ).    /* gérance */
                    poFusionBail:NomModifPrelSEPALocataire = trim(entry(1, LbZone, separ[2])) + " " + trim(entry(2, LbZone , separ[2])).
                end.
                assign
                    poFusionBail:RUMLocataire                    = RUMLocataire
                    poFusionBail:NomCreancierLocataire           = NomCreancierLocataire
                    poFusionBail:ICSCreancierLocataire           = ICSCreancierLocataire
                    // poFusionBail:BanqueCreancierLocataire        = BanqueCreancierLocataire
                    // poFusionBail:LieuSignatureRUMLocataire       = LieuSignatureRUMLocataire
                    // poFusionBail:DatePreNotifRUMLocataire        = DatePreNotifRUMLocataire
                    // poFusionBail:DateEcheanceRUMLocataire        = DateEcheanceRUMLocataire
                    // poFusionBail:MontantEcheanceRUMLocataire     = MontantEcheanceRUMLocataire
                .
            end.
            when {&FUSION-Dateeffetofferte}  or when {&FUSION-Loyeroffert}            or when {&FUSION-DateeffetDefinitive}
         or when {&FUSION-LoyerDefinitif}    or when {&FUSION-LoyerDefinitifenLettre} or when {&FUSION-LoyeroffertenLettre}
         or when {&FUSION-Dateleffetofferte} or when {&FUSION-DateeffetofferteLettre} or when {&FUSION-DateleffetDefinitive}
         or when {&FUSION-DateeffetDefinitiveLettre}
            then do:
                if vlBloc14 then next boucleCHamp.
                vlBloc14 = true.

                find last Tache no-lock 
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and Tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-renouvellement} no-error.
                if available tache 
                then assign
                    poFusionBail:DateEffetOfferte            = dateToCharacter(tache.dtree)
                    poFusionBail:DateLEffetOfferte           = outilFormatage:getDateFormat(tache.dtree, "L")
                    poFusionBail:DateEffetOfferteLettre      = outilFormatage:getDateFormat(tache.dtree, "LL")
                    poFusionBail:DateEffetDefinitive         = dateToCharacter(tache.dtreg)
                    poFusionBail:DateLEffetDefinitive        = outilFormatage:getDateFormat(tache.dtreg, "L")
                    poFusionBail:DateEffetDefinitiveLettre   = outilFormatage:getDateFormat(tache.dtreg, "LL")
                    poFusionBail:LoyerOffert                 = montantToCharacter(decimal(entry(1, tache.lbdiv,  "&")), true)
                    poFusionBail:LoyerOffertEnLettre         = CONVCHIFFRE(decimal(entry(1, tache.lbdiv, "&")))
                    poFusionBail:LoyerDefinitif              = if num-entries(tache.lbdiv, "&") > 1
                                                               then montantToCharacter(decimal(entry(2, tache.lbdiv, "&")), true)
                                                               else montantToCharacter(decimal(0), true)
                    poFusionBail:LoyerDefinitifEnLettre      = if num-entries(tache.lbdiv, "&") > 1
                                                               then CONVCHIFFRE(decimal(entry(2, tache.lbdiv, "&")))
                                                               else CONVCHIFFRE(decimal(0))
                .
            end.
            when {&FUSION-NumLocatairePrec}               or when {&FUSION-TitreLocatairePrec}      or when {&FUSION-TitreLLocatairePrec}
         or when {&FUSION-NomLocatairePrec}               or when {&FUSION-NomCompletLocatairePrec} or when {&FUSION-LoyerLocatairePrec}
         or when {&FUSION-DateDebutBailLocPrec}           or when {&FUSION-DateLDebutBailLocPrec}   or when {&FUSION-DateDebutBailLocPrecLettre}
         or when {&FUSION-DureeBailLocPrec}               or when {&FUSION-UsageLocauxLocPrec}      or when {&FUSION-PolitesseLocatairePrec}
         or when {&FUSION-PortableLocatairePrec}          or when {&FUSION-DateFinBailLocPrec}      or when {&FUSION-DateLFinBailLocPrec}
         or when {&FUSION-DateFinBailLocPrecLettre}       or when {&FUSION-DateDerLoyerLocPrec}     or when {&FUSION-DateLDerLoyerLocPrec}
         or when {&FUSION-DateDerLoyerLocPrecLettre}      or when {&FUSION-DateDerRevisionLocPrec}  or when {&FUSION-DateLDerRevisionLocPrec}
         or when {&FUSION-DateDerRevisionLocPrecenLettre} or when {&FUSION-LoyerLocatairePrecenLettre}
            then do:
                if vlBloc15 then next boucleCHamp.
                vlBloc15 = true.

                assign
                    vcTmp = string(piNumeroBail, "9999999999")
                    NoIdtUs1 = integer(substring(vcTmp, 1, 5) + substring(vcTmp, 6, 3) + "00")
                .
                find last ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-bail}
                      and ctrat.nocon > NoIdtUs1
                      and ctrat.nocon < piNumeroBail
                      and ctrat.fgannul = false
                      and ctrat.ntcon <> "03094"
                    use-index ix_ctrat02 no-error.
                if available Ctrat
                then do:
                    /*  Information sur le locataire */
                    voRole = chargeRole(ctrat.tprol, ctrat.norol, piNumeroDocument).
                    assign
                        poFusionBail:NumLocatairePrec            = string(ctrat.nocon)
                        poFusionBail:TitreLocatairePrec          = voRole:Titre
                        poFusionBail:TitreLLocatairePrec         = voRole:TitreLettre
                        poFusionBail:NomLocatairePrec            = voRole:Nom
                        poFusionBail:NomCompletLocatairePrec     = voRole:nomComplet
                        poFusionBail:PolitesseLocatairePrec      = voRole:formulePolitesse
                        poFusionBail:DateDebutBailLocPrec        = dateToCharacter(ctrat.dtdeb)
                        poFusionBail:DateLDebutBailLocPrec       = outilFormatage:getDateFormat(ctrat.dtdeb, "L")
                        poFusionBail:DateDebutBailLocPrecLettre  = outilFormatage:getDateFormat(ctrat.dtdeb, "LL")
                        // poFusionBail:DureeBailLocPrec            = string(ctrat.nbdur) + " " + outilTraduction:getlibelleParam("UTDUR", ctrat.cddur)
                        poFusionBail:UsageLocauxLocPrec          = USAGE(ctrat.ntcon)
                    .
                    /* NP 0415/0251 */
                    find last prc_tache no-lock
                        where prc_tache.TpTac = {&TYPETACHE-quittancement}
                          and prc_tache.tpcon = ctrat.tpcon
                          and prc_tache.nocon = ctrat.nocon no-error.
                    if available prc_tache 
                    then assign
                        poFusionBail:DateFinBailLocPrec        = dateToCharacter(prc_tache.dtfin)
                        poFusionBail:DateLFinBailLocPrec       = outilFormatage:getDateFormat(prc_tache.dtfin, "L")
                        poFusionBail:DateFinBailLocPrecLettre  = outilFormatage:getDateFormat(prc_tache.dtfin, "LL")
                    .
                    /* SY 0715/0009 */
                    find last prc_tache no-lock
                        where prc_tache.TpTac = {&TYPETACHE-revision}
                          and prc_tache.tpcon = ctrat.tpcon
                          and prc_tache.nocon = ctrat.nocon no-error.
                    if available prc_tache
                    then assign
                        poFusionBail:DateDerRevisionLocPrec         = dateToCharacter(prc_tache.dtdeb)
                        poFusionBail:DateLDerRevisionLocPrec        = outilFormatage:getDateFormat(prc_tache.dtdeb, "L")
                        poFusionBail:DateDerRevisionLocPrecEnLettre = outilFormatage:getDateFormat(prc_tache.dtdeb, "LL")
                    .
                    run Last_Versement_Locat (ctrat.nocon , output vdaDateDerLoyer). /* SY 0715/0204 */
                    assign
                        poFusionBail:DateDerLoyerLocPrec        = dateToCharacter(vdaDateDerLoyer)
                        poFusionBail:DateLDerLoyerLocPrec       = outilFormatage:getDateFormat(vdaDateDerLoyer, "L")
                        poFusionBail:DateDerLoyerLocPrecLettre  = outilFormatage:getDateFormat(vdaDateDerLoyer, "LL")
                    .
                    /* Information quittance */
                    voQuittance = chargeQuittance(ctrat.nocon).
                    assign
                        poFusionBail:LoyerLocatairePrec         = string(voQuittance:montantloyer)
                        vcTmp                                   = replace(poFusionBail:LoyerLocatairePrec, "Euros", "")
                        vcTmp                                   = trim(replace(vcTmp, "Euro", ""))
                        poFusionBail:LoyerLocatairePrecEnLettre = CONVCHIFFRE(decimal(vcTmp))
                    .
                    /* Adresse locataire */
                    voAdresse = chargeAdresse({&TYPEROLE-locataire}, ctrat.nocon, piNumeroDocument).
                    poFusionBail:PortableLocatairePrec = voAdresse:portable.
                end.
            end.
            when {&FUSION-NomassuranceLoc} or when {&FUSION-NumPoliceLoc}
            then do:
                find first tache no-lock
                     where tache.tpcon = {&TYPECONTRAT-bail}
                       and tache.nocon = piNumeroBail
                       and tache.tptac = {&TYPETACHE-attestationsLocatives}
                       and tache.notac = 1 no-error.
                if available tache 
                then assign
                    poFusionBail:NomAssuranceLoc = tache.tpges
                    poFusionBail:NumPoliceLoc    = tache.ntges
                .
            end.
            when {&FUSION-DateDbtassuranceLoc}  or when {&FUSION-DateLDbtassuranceLoc}      or when {&FUSION-DateFinassuranceLoc}
         or when {&FUSION-DateLFinassuranceLoc} or when {&FUSION-DateDbtassuranceLocLettre} or when {&FUSION-DateFinassuranceLocLettre} then do:
                if vlBloc16 then next boucleCHamp.
                vlBloc16 = true.

                find first taint no-lock
                     where taint.tpcon = {&TYPECONTRAT-bail}
                       and taint.nocon = piNumeroBail
                       and taint.tptac = {&TYPETACHE-attestationsLocatives}
                       and taint.notac = 1
                       and taint.tpidt = pcTypeRole
                       and taint.noidt = piNumeroRole no-error.
                if available taint 
                then assign
                    poFusionBail:DateDbtAssuranceLoc       = dateToCharacter (date(entry(4, taint.lbdiv, "@")))
                    poFusionBail:DateLDbtAssuranceLoc      = outilFormatage:getDateFormat(date(entry(4, taint.lbdiv, "@")), "L")
                    poFusionBail:DateDbtAssuranceLocLettre = outilFormatage:getDateFormat(date(entry(4, taint.lbdiv, "@")), "LL")
                    poFusionBail:DateFinAssuranceLoc       = dateToCharacter (date(entry(5, taint.lbdiv, "@")))
                    poFusionBail:DateLFinAssuranceLoc      = outilFormatage:getDateFormat(date(entry(5, taint.lbdiv, "@")), "L")
                    poFusionBail:DateFinAssuranceLocLettre = outilFormatage:getDateFormat(date(entry(5, taint.lbdiv, "@")), "LL")
                .
                else do:
                    find first tache no-lock
                         where tache.tpcon = {&TYPECONTRAT-bail}
                           and tache.nocon = piNumeroBail
                           and tache.tptac = {&TYPETACHE-attestationsLocatives}
                           and tache.notac = 1  no-error.
                    if available tache 
                    then assign
                        poFusionBail:DateDbtAssuranceLoc         = dateToCharacter(tache.dtdeb)
                        poFusionBail:DateLDbtAssuranceLoc        = outilFormatage:getDateFormat(tache.dtdeb, "L")
                        poFusionBail:DateDbtAssuranceLocLettre   = outilFormatage:getDateFormat(tache.dtdeb, "LL")
                        poFusionBail:DateFinAssuranceLoc         = dateToCharacter(tache.dtfin)
                        poFusionBail:DateLFinAssuranceLoc        = outilFormatage:getDateFormat(tache.dtfin, "L")
                        poFusionBail:DateFinAssuranceLocLettre   = outilFormatage:getDateFormat(tache.dtfin, "LL")
                    .
                end.
            end.
            when {&FUSION-DateDbtRamonage}    or when {&FUSION-DateLDbtRamonage}      or when {&FUSION-DateFinRamonage}
         or when {&FUSION-DateLFinRamonage}   or when {&FUSION-DateDbtRamonageLettre} or when {&FUSION-DateFinRamonageLettre}
         or when {&FUSION-NumContratRamonage} or when {&FUSION-NomFournisseurRamonage}
            then do:
                if vlBloc17 then next boucleCHamp.
                vlBloc17 = true.

                if pcTypeRole = {&TYPEROLE-colocataire} then do:
                    find first taint no-lock
                         where taint.tpcon = {&TYPECONTRAT-bail}
                           and taint.nocon = piNumeroBail
                           and taint.tptac = {&TYPETACHE-attestationsLocatives}
                           and taint.notac = 2
                           and taint.tpidt = pcTypeRole
                           and taint.noidt = piNumeroRole no-error.
                    if available taint 
                    then assign
                        poFusionBail:DateDbtRamonage         = dateToCharacter (date(entry(4, taint.lbdiv, "@")))
                        poFusionBail:DateLDbtRamonage        = outilFormatage:getDateFormat(date(entry(4, taint.lbdiv, "@")), "L")
                        poFusionBail:DateDbtRamonageLettre   = outilFormatage:getDateFormat(date(entry(4, taint.lbdiv, "@")), "LL")
                        poFusionBail:DateFinRamonage         = dateToCharacter (date(entry(5, taint.lbdiv, "@")))
                        poFusionBail:DateLFinRamonage        = outilFormatage:getDateFormat(date(entry(5, taint.lbdiv, "@")), "L")
                        poFusionBail:DateFinRamonageLettre   = outilFormatage:getDateFormat(date(entry(5, taint.lbdiv, "@")), "LL")
                    .
                    else do:
                        find first tache no-lock
                             where tache.tpcon = {&TYPECONTRAT-bail}
                               and tache.nocon = piNumeroBail
                               and tache.tptac = {&TYPETACHE-attestationsLocatives}
                               and tache.notac = 2 no-error.
                        if available tache 
                        then do:    /* NP 1212/0151 */
                            assign
                                poFusionBail:DateDbtRamonage         = dateToCharacter(tache.dtdeb)
                                poFusionBail:DateLDbtRamonage        = outilFormatage:getDateFormat(tache.dtdeb, "L")
                                poFusionBail:DateDbtRamonageLettre   = outilFormatage:getDateFormat(tache.dtdeb, "LL")
                                poFusionBail:DateFinRamonage         = dateToCharacter(tache.dtfin)
                                poFusionBail:DateLFinRamonage        = outilFormatage:getDateFormat(tache.dtfin, "L")
                                poFusionBail:DateFinRamonageLettre   = outilFormatage:getDateFormat(tache.dtfin, "LL")
                            .
                            poFusionBail:NumContratRamonage     = tache.ntges. /* PL 28/02/2012 : 0211/0164 */
                            poFusionBail:NomFournisseurRamonage = tache.tpges. /* PL 28/02/2012 : 0211/0164 */
                        end.    /* NP 1212/0151 */
                    end.
                end.
            end.
            when {&FUSION-DateDbtChaudiere}    or when {&FUSION-DateLDbtChaudiere}      or when {&FUSION-DateFinChaudiere}
         or when {&FUSION-DateLFinChaudiere}   or when {&FUSION-DateDbtChaudiereLettre} or when {&FUSION-DateFinChaudiereLettre}
         or when {&FUSION-NumContratChaudiere} or when {&FUSION-NomFournisseurChaudiere}
            then do:
                if vlBloc18 then next boucleCHamp.
                vlBloc18 = true.

                if pcTypeRole = {&TYPEROLE-colocataire}
                then do:
                    find first taint no-lock
                         where taint.tpcon = {&TYPECONTRAT-bail}
                           and taint.nocon = piNumeroBail
                           and taint.tptac = {&TYPETACHE-attestationsLocatives}
                           and taint.notac = 3
                           and taint.tpidt = pcTypeRole
                           and taint.noidt = piNumeroRole no-error.
                    if available taint 
                    then assign
                        poFusionBail:DateDbtChaudiere        = dateToCharacter (date(entry(4, taint.lbdiv, "@")))
                        poFusionBail:DateLDbtChaudiere       = outilFormatage:getDateFormat(date(entry(4, taint.lbdiv, "@")), "L")
                        poFusionBail:DateDbtChaudiereLettre  = outilFormatage:getDateFormat(date(entry(4, taint.lbdiv, "@")), "LL")
                        poFusionBail:DateFinChaudiere        = dateToCharacter (date(entry(5, taint.lbdiv, "@")))
                        poFusionBail:DateLFinChaudiere       = outilFormatage:getDateFormat(date(entry(5, taint.lbdiv, "@")), "L")
                        poFusionBail:DateFinChaudiereLettre  = outilFormatage:getDateFormat(date(entry(5, taint.lbdiv, "@")), "LL")
                    .
                end.
                else do:
                    find first tache no-lock
                         where tache.tpcon = {&TYPECONTRAT-bail}
                           and tache.nocon = piNumeroBail
                           and tache.tptac = {&TYPETACHE-attestationsLocatives}
                           and tache.notac = 3 no-error.
                    if available tache 
                    then do: /* NP 1212/0151 */
                        assign
                            poFusionBail:DateDbtChaudiere        = dateToCharacter (tache.dtdeb)
                            poFusionBail:DateLDbtChaudiere       = outilFormatage:getDateFormat(tache.dtdeb, "L")
                            poFusionBail:DateDbtChaudiereLettre  = outilFormatage:getDateFormat(tache.dtdeb, "LL")
                            poFusionBail:DateFinChaudiere        = dateToCharacter (tache.dtfin)
                            poFusionBail:DateLFinChaudiere       = outilFormatage:getDateFormat(tache.dtfin, "L")
                            poFusionBail:DateFinChaudiereLettre  = outilFormatage:getDateFormat(tache.dtfin, "LL")
                            poFusionBail:NumContratChaudiere     = tache.ntges. /* PL 28/02/2012 : 0211/0164 */
                            poFusionBail:NomFournisseurChaudiere = tache.tpges. /* PL 28/02/2012 : 0211/0164 */
                        .
                    end. /* NP 1212/0151 */
                end.
            end.
            when {&FUSION-Tauxaugmentation}
            then do:
                  find trait no-lock where trait.notrt = piNumeroTraitement no-error.
                  if available trait then poFusionBail:TauxAugmentation = entry(3, trait.lbtrt, SEPAR[1]).
            end.
            when {&FUSION-ListeLocacaires}
            then do:
                /* Locataire principale */
                voRole = chargeRole({&TYPEROLE-locataire}, piNumeroBail, piNumeroDocument).
                poFusionBail:ListeLocataires = voRole:nomComplet.
        
                /*  Colocataires */
                for each intnt no-lock
                   where intnt.tpcon = {&TYPECONTRAT-bail}
                     and intnt.nocon = piNumeroBail
                     and intnt.tpidt = "00051":
                    voRole = chargeRole(intnt.tpidt, intnt.noidt, piNumeroDocument). /*  Colocataire */
                    poFusionBail:ListeLocataires = poFusionBail:ListeLocataires + ", " + voRole:nomComplet.
                end.
            end.
            when {&FUSION-DateNotificationRevision} or when {&FUSION-DateLNotificationRevision} or when {&FUSION-DateNotificationRevisionLettre}
            then do:
                if vlBloc19 then next boucleCHamp.
                vlBloc19 = true.

                find last tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-suiviAdministratif}
                      and tache.tpfin = "26018" no-error.
                if available tache 
                then assign
                    poFusionBail:DateNotificationRevision        = dateToCharacter(tache.dtdeb)
                    poFusionBail:DateLNotificationRevision       = outilFormatage:getDateFormat(tache.dtdeb, "L")
                    poFusionBail:DateNotificationRevisionLettre  = outilFormatage:getDateFormat(tache.dtdeb, "LL")
                .
            end.
            when {&FUSION-DateSituaLocataire}          or when {&FUSION-MtSituaLocataire}          or when {&FUSION-MtInteretSituaLocataire} 
         or when {&FUSION-MtFraisaccessSituaLocataire} or when {&FUSION-MtPrincipalSituaLocataire} 
            then do:
                if vlBloc20 then next boucleCHamp.
                vlBloc20 = true.

                /*  Date de Situation */
                poFusionBail:DateSituaLocataire = "31/12/" + string(year(today) - 1, "9999").

                /*  Solde */
                assign
                    vdSoldeCpt = 0
                    vcTmp      = mtoken:cRefGerance
                               + "|"   +
                               substring(string(piNumeroBail, "9999999999"), 1, 5)
                               + "|"   +
                               "4112"
                               + "|"   +
                               substring(string(piNumeroBail, "9999999999"), 6, 5)
                               + "|S|" +
                               poFusionBail:DateSituaLocataire
                               + "|"
                .
                /* ToDo : THK A reprendre
                {RunPgExp.i &Path       =   RpRunLie
                            &Prog       =   "'SolCpt.p'"
                            &Parameter  =   "LbTmpPdt,OUTPUT chretSol"}
                */
                /* Ajout SY le 10/12/2007 : Solde collectif LF compte 4118 */
                vcTmp = mtoken:cRefGerance 
                      + "|"
                      + substring(string(piNumeroBail, "9999999999"), 1, 5) 
                      + "|" 
                      + "4118"
                      + "|" 
                      + substring(string(piNumeroBail, "9999999999"), 6, 5)
                      + "|S|" 
                      + poFusionBail:DateSituaLocataire 
                      + "|"
                .
                /* ToDo : THK A reprendre
                {RunPgExp.i &Path       =   RpRunLie
                              &Prog       =   "'SolCpt.p'"
                              &Parameter  =   "LbTmpPdt, OUTPUT chretSLF"} */
                if chretSol <> "" or chretSLF <> "" 
                then assign
                    vdSoldeCpt       = decimal(entry(1, chretSol, "|")) / 100 + decimal(entry(1, chretSLf, "|")) / 100
                    poFusionBail:MtSituaLocataire = montantToCharacter(vdSoldeCpt, true)
                .
                /*  Interet */
                /* ToDo : THK A reprendre
                {RunPgExp.i &Path       =   RpRunCpt
                            &Prog       =   "'Interet.p'"
                            &Parameter  =   "piNumeroBail,DATE(DateSituaLocataire), OUTPUT SoldeCpt, OUTPUT FgExeMth"}
                */
                if not FgExeMth then poFusionBail:MtInteretSituaLocataire = montantToCharacter(vdSoldeCpt, true).

                /*  Interet */
                /* ToDo : THK A reprendre
                {RunPgExp.i &Path       =   RpRunCpt
                            &Prog       =   "'FraiAces.p'"
                            &Parameter  =   "piNumeroBail,DATE(DateSituaLocataire),OUTPUT SoldeCpt,OUTPUT FgExeMth"}
                */
                if not FgExeMth then poFusionBail:MtFraisaccessSituaLocataire = montantToCharacter(vdSoldeCpt, true).
                assign
                    vdSoldeCpt = DECMONTANT(poFusionBail:MtSituaLocataire)
                               - DECMONTANT(poFusionBail:MtInteretSituaLocataire)
                               - DECMONTANT(poFusionBail:MtFraisaccessSituaLocataire)
                    poFusionBail:MtPrincipalSituaLocataire = montantToCharacter(vdSoldeCpt, true)
                .
            end.
            when {&FUSION-NumRCSLocataire}                          or when {&FUSION-CapitalLocataire}           or when {&FUSION-VilleRCSLocataire}
         or when {&FUSION-DtMariageLocataire}                       or when {&FUSION-DtLMariageLocataire}        or when {&FUSION-DtMariageLocataireLettre}
         or when {&FUSION-LieuMariageLocataire}                     or when {&FUSION-RegimeMatrimonialLocataire} or when {&FUSION-NomNotaireContratMariageLocataire}
         or when {&FUSION-VilleNotaireContratMariageLocataire}      or when {&FUSION-activiteLocataire}          or when {&FUSION-VilleCedexRCSLocataire}
         or when {&FUSION-VilleCedexNotaireContratMariageLocataire} or when {&FUSION-ComplementAdresseIdentNotaireContratMariageLocataire}
            then do:
                if vlBloc21 then next boucleCHamp.
                vlBloc21 = true.

                find first ctrat no-lock
                     where ctrat.tpcon = {&TYPECONTRAT-bail}
                       and ctrat.nocon = piNumeroBail no-error.
                if available ctrat then do:
                    find first roles no-lock
                         where roles.tprol = ctrat.tprol
                           and roles.norol = ctrat.norol no-error.
                    if available roles
                    then do:
                        find first tiers no-lock where tiers.notie = roles.notie no-error.
                        if available tiers 
                        then do:
                            find first ctanx no-lock
                                 where ctanx.tpcon = {&TYPECONTRAT-Association}
                                   and ctanx.nocon = tiers.nocon no-error.
                            if available ctanx 
                            then do:
                                assign
                                    poFusionBail:NumRCSLocataire   = ctanx.lbprf
                                    poFusionBail:ActiviteLocataire = entry(1,ctanx.cdobj,SEPAR[1]) + (if num-entries(ctanx.cdobj,SEPAR[1]) >= 2 then (chr(10) + ENTRY(2,ctanx.cdobj,SEPAR[1])) else "")
                                .
                                /*  Information Mariage */
                                if tiers.cdsft = "06003" 
                                then do:
                                    assign
                                        poFusionBail:DtMariageLocataire                  = dateToCharacter(ctanx.dtsig)
                                        poFusionBail:DtLMariageLocataire                 = outilFormatage:getDateFormat(ctanx.dtsig, "L")
                                        poFusionBail:DtMariageLocataireLettre            = outilFormatage:getDateFormat(ctanx.dtsig, "LL")
                                        poFusionBail:LieuMariageLocataire                = ctanx.lisig
                                        poFusionBail:RegimeMatrimonialLocataire          = outilTraduction:getlibelleParam("UNION",ctanx.cdreg)
                                        poFusionBail:NomNotaireContratMariageLocataire   = ctanx.lnnot
                                        poFusionBail:VilleNotaireContratMariageLocataire = suppCedex(ctanx.liexe)
                                        poFusionBail:VilleCedexNotaireContratMariageLocataire = ctanx.liexe. 
                                        poFusionBail:ComplementAdresseIdentNotaireContratMariageLocataire = voAdresse:IdentAdresse.
                                    .
                                end.
                                assign
                                    vcCapitalLocataire = replace(ctanx.mtcap, " ", "")
                                    vcCapitalLocataire = replace(vcCapitalLocataire, "Euros",  "")
                                    vcCapitalLocataire = replace(vcCapitalLocataire, "Francs", "")
                                    vcCapitalLocataire = replace(vcCapitalLocataire, "Euro",   "")
                                    vcCapitalLocataire = replace(vcCapitalLocataire, "Franc",  "")
                                .
                                if num-entries(vcCapitalLocataire, ",") > 1 and session:numeric-format = "American" 
                                then vcCapitalLocataire = replace(vcCapitalLocataire, ",", ".").
                                poFusionBail:CapitalLocataire = montantToCharacter(decimal(vcCapitalLocataire), true) no-error.
                                if error-status:error or vcCapitalLocataire = ? 
                                then poFusionBail:CapitalLocataire = ctanx.mtcap.
                            end.
                            find first ctanx no-lock
                                 where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                                   and ctanx.tprol = {&TYPEROLE-tiers}
                                   and ctanx.norol = tiers.notie no-error.
                            if available ctanx 
                            then assign
                                poFusionBail:VilleRCSLocataire      = SuppCedex(ctanx.lbreg)
                                poFusionBail:VilleCedexRCSLocataire = ctanx.lbreg /* 0109/0192 */
                            .
                        end.
                    end.
                end.
            end.
            when {&FUSION-MajorationavantIndexation} or when {&FUSION-MajorationapresIndexation}
            then do:
                if vlBloc22 then next boucleCHamp.
                vlBloc22 = true.
                viCompteur = 0.
                find last tache no-lock
                    where tache.tptac = {&TYPETACHE-quittancement}
                      and tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.notac = 1
                      and tache.nocon = piNumeroBail no-error.
                if available tache 
                then viCompteur = integer(substring(tache.pdges, 1, 3)).
                find last tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-majorationMermaz} no-error.
                if available tache 
                then assign
                    poFusionBail:majorationAvantIndexation = montantToCharacter(decimal(trim(entry(1, tache.lbdiv, "#"))) * viCompteur, true)
                    poFusionBail:majorationApresIndexation = montantToCharacter(decimal(trim(entry(2, tache.lbdiv, "#"))) * viCompteur, true)
                .
            end.
            when {&FUSION-TauxTVaBail} or when {&FUSION-TacheTVa}
            then do:
                if vlBloc23 then next boucleCHamp.
                vlBloc23 = true.
                find last tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-TVABail} no-error.
                if available tache 
                then vcTmp = outilTraduction:getlibelleParam("CDTVA", Tache.ntges).
                else vcTmp = "".
                assign
                    poFusionBail:TauxTVABail = vcTmp
                    poFusionBail:TacheTVA    = string(available tache, "Oui/Non")
                .
            end.
            when {&FUSION-QuotePartLocTaxeBureau} or when {&FUSION-TacheTaxeBureau}
            then do:
                if vlBloc24 then next boucleCHamp.
                vlBloc24 = true.
                find last tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-taxeBureauStationnement} no-error.
                if available tache 
                then vcTmp = montantToCharacter(tache.TxNo1,false) + " %".
                else vcTmp = "".
                assign 
                    poFusionBail:QuotePartLocTaxeBureau = vcTmp
                    poFusionBail:TacheTaxeBureau        = string(available tache, "Oui/Non")
                .
            end.
            when {&FUSION-QuotePartLocCRL} or when {&FUSION-TacheCRL}
            then do:
                if vlBloc25 then next boucleCHamp.
                vlBloc25 = true.

                find last tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-CRLBail} no-error.
                if available tache 
                then vcTmp = outilTraduction:getlibelleParam("CDQPL", tache.TPges).
                else vcTmp = "".
                assign
                    poFusionBail:QuotePartLocCRL = vcTmp
                    poFusionBail:TacheCRL        = string(available tache, "Oui/Non")
                    poFusionBail:ExonerationCRL  = string(available tache and tache.cdreg = "00001", "Oui/Non") /* Ajout SY le 26/01/2011 */
                .
            end.
            when {&FUSION-QuotePartLocIF} or when {&FUSION-TacheImpotFoncier}
            then do:
                if vlBloc26 then next boucleCHamp.
                vlBloc26 = true.

                find last tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-ImpotFoncier} no-error.
                if available tache 
                then vcTmp = montantToCharacter(tache.mtreg, false) + " %".
                else vcTmp = "".
                assign
                    poFusionBail:QuotePartLocIF    = vcTmp
                    poFusionBail:TacheImpotFoncier = string(available tache, "Oui/Non")
                .
            end.
            when {&FUSION-ReactualisationDG}
            then do:
                find last tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-depotGarantieBail} no-error.
                if available tache 
                then vcTmp = string(tache.pdges = "00001").
                else vcTmp = "".
                poFusionBail:ReactualisationDG = vcTmp.
            end.
            when {&FUSION-CalEvRubriqueLoyer}              or when {&FUSION-CalEvUtilisation}              or when {&FUSION-CalEvPeriodeEnCoursNumero}
         or when {&FUSION-CalEvPeriodeEnCoursDateDebut}    or when {&FUSION-CalEvPeriodeEnCoursDateLDebut} or when {&FUSION-CalEvPeriodeEnCoursDateDebutLettre}
         or when {&FUSION-CalEvPeriodeEnCoursDateFin}      or when {&FUSION-CalEvPeriodeEnCoursDateLFin}   or when {&FUSION-CalEvPeriodeEnCoursDateFinLettre}
         or when {&FUSION-CalEvMontantAnnuel}              or when {&FUSION-CalEvListeNumeroPeriode}       or when {&FUSION-CalEvListeDateDebutPeriode}
         or when {&FUSION-CalEvListeDateFinPeriode}        or when {&FUSION-CalEvListeMontantAnnuel}       or when {&FUSION-CalEvListeEtatTraitement}
         or when {&FUSION-CalEvLoyerContractuelInitial}    or when {&FUSION-CalEvVariationPourcentage}
            then do:
                if vlBloc27 then next boucleCHamp.
                vlBloc27 = true.

                find first tache no-lock
                     where tache.tpcon = {&TYPECONTRAT-bail}
                       and tache.nocon = piNumeroBail
                       and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}
                       and tache.notac = 0 no-error.
                if available(tache) 
                then assign
                    poFusionBail:CalEvRubriqueLoyer = string(integer(tache.ntges), "999") + " - " + string(integer(tache.pdges), "99")
                    poFusionBail:CalEvUtilisation   = (if tache.tphon = "yes" then "Oui" else "Non")
                .
                find last tache no-lock 
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer} no-error.
                if available(tache) 
                then do:
                    /* Recherche du calendrier */
                    assign 
                        vcListeNumero  = ""
                        vcListeDebut   = ""
                        vcListeFin     = ""
                        vcListeMontant = ""
                        vcListeEtat    = ""
                    .
                    for each calev no-lock
                       where calev.tpcon = tache.tpcon
                         and calev.nocon = tache.nocon
                         and calev.nocal = tache.duree:
                         /* Période en cours */
                        if calev.dtdeb >= tache.dtfin 
                        then assign
                            poFusionBail:CalEvPeriodeEnCoursNumero          = string    (calev.noper)
                            poFusionBail:CalEvPeriodeEnCoursDateDebut       = dateToCharacter   (calev.dtdeb)
                            poFusionBail:CalEvPeriodeEnCoursDateLDebut      = outilFormatage:getDateFormat  (calev.dtdeb, "L")
                            poFusionBail:CalEvPeriodeEnCoursDateDebutLettre = outilFormatage:getDateFormat  (calev.dtdeb, "LL")
                            poFusionBail:CalEvPeriodeEnCoursDateFin         = dateToCharacter   (calev.dtfin)
                            poFusionBail:CalEvPeriodeEnCoursDateLFin        = outilFormatage:getDateFormat  (calev.dtfin, "L")
                            poFusionBail:CalEvPeriodeEnCoursDateFinLettre   = outilFormatage:getDateFormat  (calev.dtfin, "LL")
                            poFusionBail:CalEvMontantAnnuel                 = montantToCharacter(calev.mtper, true)
                        .
                        end.
                        /* Création des champs liste */
                        vcListeNumero  = vcListeNumero  + chr(10) + string(calev.noper).
                        vcListeDebut   = vcListeDebut   + chr(10) + dateToCharacter(calev.dtdeb).
                        vcListeFin     = vcListeFin     + chr(10) + dateToCharacter(calev.dtfin).
                        vcListeMontant = vcListeMontant + chr(10) + montantToCharacter(calev.mtper, true).
                        vcListeEtat    = vcListeEtat    + chr(10) + (if calev.dtdeb >= tache.dtfin then " " else "Historique").
                    end.
                    assign
                        poFusionBail:CalEvListeNumeroPeriode    = substring(vcListeNumero,  2)
                        poFusionBail:CalEvListeDateDebutPeriode = substring(vcListeDebut,   2)
                        poFusionBail:CalEvListeDateFinPeriode   = substring(vcListeFin,     2)
                        poFusionBail:CalEvListeMontantAnnuel    = substring(vcListeMontant, 2)
                        poFusionBail:CalEvListeEtatTraitement   = substring(vcListeEtat,    2)
                    .
                end.
            /* Ajout Sy le 30/09/2013 : Locataire en sous-location : informations Mandant Investisseur */  
            when {&FUSION-TitreLMandantInvest}     or when {&FUSION-adresseMandantInvest}      or when {&FUSION-SuiteadresseMandantInvest}
         or when {&FUSION-CodePostalMandantInvest} or when {&FUSION-VilleMandantInvest}        or when {&FUSION-VillecedexMandantInvest}
         or when {&FUSION-NomCompletMandantInvest} or when {&FUSION-NomCompletCoMandantInvest} or when {&FUSION-PaysMandantInvest}
         or when {&FUSION-NumMandantInvest}        or when {&FUSION-NoMandatInvest}            or when {&FUSION-TelephoneMandantInvest}
         or when {&FUSION-emailMandantInvest}      or when {&FUSION-FaxMandantInvest}          or when {&FUSION-111617}
            then do:
                if vlBloc28 then next boucleCHamp.
                vlBloc28 = true.

                /* Recherche du mandat maitre */
                find first m_ctrat no-lock
                     where m_ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                       and m_ctrat.nocon = integer(substring(string(piNumeroBail, "9999999999"), 1, 5)) no-error.
                if available m_ctrat 
                then do:
                    if lookup(m_ctrat.ntcon, "03076,03086") > 0 
                    then do:
                        /* Recherche du lot principal pour retrouver le Vrai propriétaire */
                        viNumeroApp = integer(substring(string(piNumeroBail, "9999999999"), 6, 3)).
                        for each unite no-lock
                           where unite.nomdt = m_ctrat.nocon
                             and unite.noapp = viNumeroApp
                             and unite.noact = 0
                         , first cpuni no-lock
                           where cpuni.nomdt = unite.nomdt
                             and cpuni.noapp = unite.noapp
                             and cpuni.nocmp = unite.nocmp:
                            viMandatLocation = DonneMandatLoc(cpuni.noimm, cpuni.nolot).
                        end.
                        find first ctrat no-lock
                             where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                               and ctrat.nocon = viMandatLocation no-error.
                        if available ctrat 
                        then do:
                            voRole = chargeRole(ctrat.tprol, ctrat.norol, piNumeroDocument).
                            assign
                                poFusionBail:NoMandatInvest              = string(viMandatLocation)
                                poFusionBail:NumMandantInvest            = string(ctrat.norol)
                                poFusionBail:TitreLMandantInvest         = voRole:titreLettre
                                poFusionBail:NomCompletMandantInvest     = voRole:nomComplet
                                poFusionBail:NomCompletCOMandantInvest   = voRole:nomCompletC-O
                            .
                            voAdresse = chargeAdresse(ctrat.tprol, ctrat.norol, piNumeroDocument).
                            assign
                                poFusionBail:AdresseMandantInvest        = voAdresse:adresse
                                poFusionBail:SuiteAdresseMandantInvest   = voAdresse:complementVoie
                                poFusionBail:CodePostalMandantInvest     = voAdresse:codePostal
                                poFusionBail:VilleMandantInvest          = voAdresse:ville
                                poFusionBail:VilleCedexMandantInvest     = voAdresse:cedex
                                poFusionBail:PaysMandantInvest           = voAdresse:codePays
                                poFusionBail:TelephoneMandantInvest      = voAdresse:telephone
                                poFusionBail:EmailMandantInvest          = voAdresse:mail
                                poFusionBail:FaxMandantInvest            = voAdresse:fax
                            . 
                            /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                            poFusionBail:ComplementAdresseIdentMandatInvest = voAdresse:identAdresse.
                        end.
                    end.
                end.
            end.
            when {&FUSION-FgLocContentieux}                        or when {&FUSION-DtDebutContentieuxLoc}           or when {&FUSION-DtLDebutContentieuxLoc}
         or when {&FUSION-DtDebutContentieuxenLettreLoc}           or when {&FUSION-etat-contentieuxLoc}             or when {&FUSION-Commentaire-ContentieuxLoc}
         or when {&FUSION-IndiceImpayesContentieuxLoc}             or when {&FUSION-DtDepIndiceContentieuxLoc}       or when {&FUSION-DtLDepIndiceContentieuxLoc}
         or when {&FUSION-DtDepIndiceContentieuxLocenLettre}       or when {&FUSION-DtDelivCommandContentieuxLoc}    or when {&FUSION-DtLDelivCommandContentieuxLoc}
         or when {&FUSION-DtDelivCommandContentieuxLocenLettre}    or when {&FUSION-DtDelivSignassignContentieuxLoc} or when {&FUSION-DtLDelivSignassignContentieuxLoc}
         or when {&FUSION-DtDelivSignassignContentieuxLocenLettre} or when {&FUSION-DtaudienceContentieuxLoc}        or when {&FUSION-DtLaudienceContentieuxLoc}
         or when {&FUSION-DtaudienceContentieuxLocenLettre}        or when {&FUSION-111821}                          or when {&FUSION-111822}
         or when {&FUSION-DtRequisForceContentieuxLocEnLettre}
            then do:
                if vlBloc29 then next boucleCHamp.
                vlBloc29 = true.
                find last tache no-lock 
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail
                      and tache.tptac = {&TYPETACHE-locataireContentieux} no-error.
                if available tache 
                then do:
                    assign
                        poFusionBail:FgLocContentieux                        = string(tache.tpges = "00001", "OUI/NON")
                        poFusionBail:DtDebutContentieuxLoc                   = dateToCharacter(tache.dtdeb)
                        poFusionBail:DtLDebutContentieuxLoc                  = outilFormatage:getDateFormat(tache.dtdeb, "L")
                        poFusionBail:DtDebutContentieuxEnLettreLoc           = outilFormatage:getDateFormat(tache.dtdeb, "LL")
                        poFusionBail:Etat-contentieuxLoc                     = tache.dcreg
                        poFusionBail:Commentaire-ContentieuxLoc              = tache.ntreg
                        poFusionBail:DtDepIndiceContentieuxLoc               = dateToCharacter(tache.dtreg)
                        poFusionBail:DtLDepIndiceContentieuxLoc              = outilFormatage:getDateFormat(tache.dtreg, "L")
                        poFusionBail:DtDepIndiceContentieuxLocEnLettre       = outilFormatage:getDateFormat(tache.dtreg, "LL")
                        poFusionBail:DtDelivCommandContentieuxLoc            = dateToCharacter(tache.dtree)
                        poFusionBail:DtLDelivCommandContentieuxLoc           = outilFormatage:getDateFormat(tache.dtree, "L")
                        poFusionBail:DtDelivCommandContentieuxLocEnLettre    = outilFormatage:getDateFormat(tache.dtree, "LL")
                        poFusionBail:DtDelivSignAssignContentieuxLoc         = dateToCharacter(tache.dtrev)
                        poFusionBail:DtLDelivSignAssignContentieuxLoc        = outilFormatage:getDateFormat(tache.dtrev, "L")
                        poFusionBail:DtDelivSignAssignContentieuxLocEnLettre = outilFormatage:getDateFormat(tache.dtrev, "LL")
                        poFusionBail:DtAudienceContentieuxLoc                = dateToCharacter(date(tache.lbdiv))
                        poFusionBail:DtLAudienceContentieuxLoc               = outilFormatage:getDateFormat(date(tache.lbdiv), "L")
                        poFusionBail:DtAudienceContentieuxLocEnLettre        = outilFormatage:getDateFormat(date(tache.lbdiv), "LL")
                        poFusionBail:IndiceImpayesContentieuxLoc             = montantToCharacter(tache.mtreg, false)    /* NP 1015/0146 */
                        poFusionBail:DtRequisForceContentieuxLoc             = dateToCharacter(date(entry(1, tache.LbDiv2, separ[5])))
                        poFusionBail:DtLRequisForceContentieuxLoc            = outilFormatage:getDateFormat(date(entry(1, tache.LbDiv2, separ[5])), "L")
                        poFusionBail:DtRequisForceContentieuxLocEnLettre     = outilFormatage:getDateFormat(date(entry(1, tache.LbDiv2, separ[5])), "LL")
                    .
                end.
                else do:
                    assign
                        poFusionBail:FgLocContentieux                         = "NON"
                        poFusionBail:DtDebutContentieuxLoc                    = ""
                        poFusionBail:DtLDebutContentieuxLoc                   = ""
                        poFusionBail:DtDebutContentieuxEnLettreLoc            = ""
                        poFusionBail:Etat-contentieuxLoc                      = ""
                        poFusionBail:Commentaire-ContentieuxLoc               = ""
                        poFusionBail:DtDepIndiceContentieuxLoc                = ""
                        poFusionBail:DtLDepIndiceContentieuxLoc               = ""
                        poFusionBail:DtDepIndiceContentieuxLocEnLettre        = ""
                        poFusionBail:DtDelivCommandContentieuxLoc             = ""
                        poFusionBail:DtLDelivCommandContentieuxLoc            = ""
                        poFusionBail:DtDelivCommandContentieuxLocEnLettre     = ""
                        poFusionBail:DtDelivSignAssignContentieuxLoc          = ""
                        poFusionBail:DtLDelivSignAssignContentieuxLoc         = ""
                        poFusionBail:DtDelivSignAssignContentieuxLocEnLettre  = ""
                        poFusionBail:DtAudienceContentieuxLoc                 = ""
                        poFusionBail:DtLAudienceContentieuxLoc                = ""
                        poFusionBail:DtAudienceContentieuxLocEnLettre         = ""
                        poFusionBail:IndiceImpayesContentieuxLoc              = ""    /* NP 1015/0146 */
                    .
                end.
            end. 
            /* SY 0516/0001 */
            when {&FUSION-DernierTraitementImpayesLocataire} or when {&FUSION-CommentaireImpayesLocataire}
            then do:
                if vlBloc30 then next boucleCHamp.
                vlBloc30 = true.
                find last tache no-lock
                    where tache.tptac = {&TYPETACHE-suiviImpayesLocataires}
                      and tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = piNumeroBail no-error.
                   if available tache and tache.duree = 0 
                   then assign
                       poFusionBail:DernierTraitementImpayesLocataire = tache.tpges 
                       poFusionBail:CommentaireImpayesLocataire       = tache.ntreg
                   .
            end.
        end case.
    end.
    delete object voAdresse   no-error.
    delete object voBanque    no-error.
    delete object voRole      no-error.
    delete object voQuittance no-error.

end procedure.
