/*-----------------------------------------------------------------------------
File        : extractionMandat.p
Description : Recherche des donnees de fusion mandat
Author(s)   : kantena - 2018/01/30
Notes       :
-----------------------------------------------------------------------------*/
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2role.i}
{preprocesseur/famille2tiers.i}

using bureautique.fusion.classe.fusionMandat.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionBanque.
using parametre.pclie.parametrageDossierMandat.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{bureautique/fusion/include/valorisationTtChampFusion.i}  // procedure valoriseChampFusion
{bureautique/fusion/include/fctexport.i}
{preprocesseur/fusion/fusionMandat.i}
{bureautique/fusion/include/decodorg.i}

procedure extractionMandat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroMandat   as integer          no-undo.
    define input        parameter piNumeroDocument as int64            no-undo.
    define input        parameter pcListeChamp     as character        no-undo.
    define input-output parameter pofusionMandat as class fusionMandat no-undo.

    define variable i as integer no-undo.
    define variable vdSoldeCpt                  as decimal no-undo.
    define variable vcSoldeProprietaire         as character no-undo.    // todo   pas utilisé ???
    define variable vcSoldeProprietaireEnLettre as character no-undo.    // todo   pas utilisé ???
    define variable vcSoldeCompteDebit          as character no-undo.
    define variable vcSoldeCompteCredit         as character no-undo.
    define variable LbTmpPdt               as character no-undo.
    define variable CpUseInc               as integer   no-undo.
    define variable vcListeLot             as character no-undo.
    define variable vcTmp                  as character no-undo.
    define variable viCompteur             as integer   no-undo.
    define variable vlBloc1                as logical   no-undo.
    define variable vlBloc2                as logical   no-undo.
    define variable vlBloc3                as logical   no-undo.
    define variable vlBloc4                as logical   no-undo.
    define variable vlBloc5                as logical   no-undo.
    define variable vlBloc6                as logical   no-undo.
    define variable vlBloc7                as logical   no-undo.
    define variable vlBloc8                as logical   no-undo.
    define variable vlBloc9                as logical   no-undo.
    define variable voRole                 as class fusionRole               no-undo.
    define variable voAdresse              as class fusionAdresse            no-undo.
    define variable voDossierMandat        as class parametrageDossierMandat no-undo.

    define buffer ctrat   for ctrat.
    define buffer intnt   for intnt.
    define buffer ctctt   for ctctt.
    define buffer bietab  for ietab.
    define buffer tache   for tache.
    define buffer local   for local.
    define buffer piece   for piece.
    define buffer honor   for honor.
    define buffer ctrlb   for ctrlb.
    define buffer ijou    for ijou.
    define buffer ietab   for ietab.
    define buffer milli   for milli.
    define buffer tiers   for tiers.
    define buffer clemi   for clemi.
    define buffer ctanx   for ctanx.
    define buffer ibque   for ibque.
    define buffer rlctt   for rlctt.


boucleChamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-Nom_mandant}             or when {&FUSION-Titre_mandant}          or when {&FUSION-Civilite_mandant}
         or when {&FUSION-Date_naissance_Mandant}  or when {&FUSION-Lieu_naissance_Mandant} or when {&FUSION-adresse_mandant}
         or when {&FUSION-Suite_adresse_mandant}   or when {&FUSION-Code_Postal_mandant}    or when {&FUSION-Ville_mandant}
         or when {&FUSION-Profession_mandant}      or when {&FUSION-Descriptif_Indivisaire} or when {&FUSION-DescriptifMandant}
         or when {&FUSION-NomManContact}           or when {&FUSION-TitreManContact}        or when {&FUSION-NumMandant}
         or when {&FUSION-DateL_Naissance_Mandant} or when {&FUSION-NomCompletMandant}      or when {&FUSION-NomCompletManContact}
         or when {&FUSION-NomCompletManCo}         or when {&FUSION-NomCompletManRep}       or when {&FUSION-TitreLMandant}
         or when {&FUSION-FormeLgJuridMandant}     or when {&FUSION-FormeCtJuridMandant}    or when {&FUSION-PolitesseMandant}
         or when {&FUSION-adresseMandantRep}       or when {&FUSION-NationaliteMandantRep}  or when {&FUSION-TelephoneMandant}
         or when {&FUSION-PortableMandant}         or when {&FUSION-FaxMandant}             or when {&FUSION-emailMandant}
         or when {&FUSION-VilleCedex_mandant}      or when {&FUSION-NationaliteMandant}     or when {&FUSION-TypeMandant}
         or when {&FUSION-ComplementAdresseIdent_Mandant}
            then do:
                if vlBloc1 then next boucleCHamp.

                vlBloc1 = true.
                for first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and ctrat.nocon = piNumeroMandat:
                    for first intnt no-lock
                         where intnt.tpcon = ctrat.tpcon
                           and intnt.nocon = ctrat.nocon
                           and intnt.tpidt = "00022":
                        assign
                            voRole                                = chargeRole(intnt.tpidt, intnt.noidt, piNumeroDocument)  /* Etat Civil Mandant Principal */
                            poFusionMandat:Titre_Mandant          = voRole:titre
                            poFusionMandat:TitreLMandant          = voRole:titreLettre
                            poFusionMandat:Civilite_Mandant       = voRole:civilite
                            poFusionMandat:Nom_Mandant            = voRole:nom
                            poFusionMandat:Date_Naissance_Mandant = voRole:dateNaissance
                            poFusionMandat:Lieu_Naissance_Mandant = voRole:lieuNaissance
                            poFusionMandat:Profession_Mandant     = voRole:profession
                            poFusionMandat:TitreManContact        = voRole:titreBis
                            poFusionMandat:NomManContact          = voRole:nomBis
                            poFusionMandat:NomCompletMandant      = voRole:nomComplet
                            poFusionMandat:NomCompletManCO        = voRole:nomCompletC-O
                            poFusionMandat:NomCompletManRep       = voRole:nomCompletRep
                            poFusionMandat:NomCompletManContact   = voRole:nomCompletContact
                            poFusionMandat:FormeLgJuridMandant    = voRole:formeJuridiqueLong
                            poFusionMandat:FormeCtJuridMandant    = voRole:formeJuridiqueCourt
                            poFusionMandat:PolitesseMandant       = voRole:formulePolitesse
                            poFusionMandat:NationaliteMandantRep  = voRole:nationaliteRep
                            poFusionMandat:NationaliteMandant     = voRole:nationalite
                            poFusionMandat:TypeMandant            = voRole:typeTiers
                        .
                        /* Coordonnees Mandant */
// TODO  ATTENTION, roles UTILISé SANS LE FIND ADEQUAT
                        assign
                            voAdresse                                     = chargeAdresse (intnt.tpidt, intnt.noidt, piNumeroDocument)
                            poFusionMandat:adresse_mandant                = voAdresse:getLibelleAdresse()
                            poFusionMandat:Suite_adresse_mandant          = voAdresse:complementVoie
                            poFusionMandat:Code_Postal_mandant            = voAdresse:codePostal
                            poFusionMandat:Ville_mandant                  = voAdresse:ville
                            poFusionMandat:PaysMandant                    = voAdresse:codePays
                            poFusionMandat:TelephoneMandant               = voAdresse:telephone
                            poFusionMandat:PortableMandant                = voAdresse:portable
                            poFusionMandat:FaxMandant                     = voAdresse:fax
                            poFusionMandat:EmailMandant                   = voAdresse:mail
                            poFusionMandat:VilleCedex_mandant             = voAdresse:ville
                            poFusionMandat:ComplementAdresseIdent_Mandant = voAdresse:identAdresse
                            /* Adresse du representant */
                            /* NP 0507/0008 ajout condition si nom représentant saisi **/
                            poFusionMandat:AdresseMandantRep = if poFusionMandat:NomCompletManRep > "" then outilFormatage:formatageAdresse(roles.tprol, roles.norol, "00007") else "".
                            /* Descriptif Mandant */
                            poFusionMandat:DescriptifMandant = description(intnt.tpidt, intnt.noidt, poFusionMandat:DescriptifMandant, piNumeroDocument)
                        .
                    end.
                    /* Indivision */
                    if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision} or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}
                    then for each intnt no-lock
                        where intnt.tpcon = ctrat.tpcon
                          and intnt.nocon = ctrat.nocon
                          and intnt.tpidt = {&TYPEROLE-coIndivisaire}
                          and intnt.noidt <> ctrat.norol: 
                        poFusionMandat:Descriptif_Indivisaire = description(intnt.tpidt, intnt.noidt, poFusionMandat:Descriptif_Indivisaire, piNumeroDocument). /* Descriptif */
                    end.
                end.
            end.
            when {&FUSION-NoMandat}                      or when {&FUSION-NumRegistre}           or when {&FUSION-NumMandatannexe}        or
            when {&FUSION-DateFinMandat}                 or when {&FUSION-DureeMandat}           or when {&FUSION-DatelFinMandat}         or
            when {&FUSION-DateFinMandatLettre}           or when {&FUSION-DateDebutMandatG}      or when {&FUSION-DateLDebutMandatG}      or
            when {&FUSION-DateDebutMandatGLettre}        or when {&FUSION-DateFinContrat}        or when {&FUSION-DateLFinContrat}        or
            when {&FUSION-DateFinContratenLettre}        or when {&FUSION-DateSigMandatG}        or when {&FUSION-DateLSigMandatG}        or
            when {&FUSION-DateSigMandatGenLettre}        or when {&FUSION-DateIniMandatG}        or when {&FUSION-DateLIniMandatG}        or
            when {&FUSION-DateIniMandatGenLettre}        or when {&FUSION-DateexpirationMandatG} or when {&FUSION-DateLexpirationMandatG} or
            when {&FUSION-DateexpirationMandatGenLettre} or when {&FUSION-DureeMaximale}
            then do:
                if vlBloc2 then next boucleCHamp.

                assign 
                    vlBloc2                 = true
                    poFusionMandat:NoMandat = string(piNumeroMandat)
                .
                for first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and ctrat.nocon = piNumeroMandat:
                    assign
                        poFusionMandat:numRegistre            = ctrat.noree
                        poFusionMandat:DateDebutMandatG       = dateToCharacter(ctrat.dtdeb)
                        poFusionMandat:DateLDebutMandatG      = outilFormatage:getDateFormat(ctrat.dtdeb, "L")
                        poFusionMandat:DateDebutMandatGLettre = outilFormatage:getDateFormat(ctrat.dtdeb, "LL")
                        poFusionMandat:DateFinMandat          = dateToCharacter(ctrat.dtfin)
                        poFusionMandat:DateLFinMandat         = outilFormatage:getDateFormat(ctrat.dtfin, "L")
                        poFusionMandat:DateFinMandatLettre    = outilFormatage:getDateFormat(ctrat.dtfin, "LL")
                        poFusionMandat:DureeMandat            = string(ctrat.nbdur) + " " + outilTraduction:getLibelleParam("UTDUR", ctrat.cddur)
                    .
                    /*
                    run CalDtMax (input ctrat.dtini
                                , input ctrat.nbdur
                                , input ctrat.cddur
                                , input (if ctrat.fgdurmax = no and ctrat.nbrenmax <> 0 then "NO" else "YES")
                                , input ctrat.nbannmax
                                , input ctrat.cddurmax
                                , input ctrat.nbrenmax 
                                , output DtMaxCtt).
                    if DtMaxCtt ne ?
                    then do:
                        run valoriseChampFusion(110439, "DateFinContrat"        ,    dateToCharacter(DtMaxCtt)).
                        run valoriseChampFusion(110440, "DateLFinContrat"       ,    outilFormatage:getDateFormat(DtMaxCtt, "L")).
                        run valoriseChampFusion(110441, "DateFinContratEnLettre",    outilFormatage:getDateFormat(DtMaxCtt, "LL")).
                    end.
                    run valoriseChampFusion(110442, "DateSigMandatG",                dateToCharacter(ctrat.dtsig)).
                    run valoriseChampFusion(110443, "DateLSigMandatG",               outilFormatage:getDateFormat(ctrat.dtsig, "L")).
                    run valoriseChampFusion(110444, "DateSigMandatGenLettre",        outilFormatage:getDateFormat(ctrat.dtsig, "LL")).
                    run valoriseChampFusion(110445, "DateIniMandatG",                dateToCharacter(ctrat.dtini)).
                    run valoriseChampFusion(110446, "DateLIniMandatG",               outilFormatage:getDateFormat(ctrat.dtini, "L")).
                    run valoriseChampFusion(110447, "DateIniMandatGenLettre",        outilFormatage:getDateFormat(ctrat.dtini, "LL")).
                    run valoriseChampFusion(110448, "DateExpirationMandatG",         dateToCharacter(ctrat.dtfin)).
                    run valoriseChampFusion(110449, "DateLExpirationMandatG",        outilFormatage:getDateFormat(ctrat.dtfin, "L")).
                    run valoriseChampFusion(110450, "DateExpirationMandatGenLettre", outilFormatage:getDateFormat(ctrat.dtfin, "LL")).
                    run valoriseChampFusion(110451, "DureeMaximale",                 string(ctrat.nbannmax) + " " + outilTraduction:getLibelleParam("UTDUR", ctrat.cddurmax)).
                    */
                end.
            end.
            when {&FUSION-Liste_des_lots_mandat} or when {&FUSION-DescriptifLotsMandat} 
            then do:
                if vlBloc3 then next boucleCHamp.

                vlBloc3 = true.                
                for each intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and intnt.nocon = piNumeroMandat
                      and intnt.tpidt = {&TYPEBIEN-lot}
                  , first local no-lock
                    where local.noloc = intnt.noidt
                    break by local.noimm by local.nolot:
                    if vcListeLot > "" 
                    then vcListeLot = substitute('&1, &2&3 &4', vcListeLot, outilTraduction:getLibelle(48), string(local.nolot), outilTraduction:getLibelleParam("NTLOT", local.ntlot)).
                    else vcListeLot = substitute('&1&2 &3', outilTraduction:getLibelle(48), string(local.nolot), outilTraduction:getLibelleParam("NTLOT", local.ntlot)).
    
                    poFusionMandat:DescriptifLotsMandat = substitute('&1&2 &3 : &4&5&6&7&8',
                                                                     poFusionMandat:DescriptifLotsMandat,
                                                                     outilTraduction:getLibelle(100361),
                                                                     local.nolot,
                                                                     outilTraduction:getLibelleParam("NTLOT", local.ntlot),
                                                                     (if local.nbpie <> 0 then " " + string(local.nbpie) else ""),
                                                                     (if local.cdeta > "" then ", " + outilTraduction:getLibelle(100360) + " " + local.cdeta else ""),
                                                                     (if local.cdpte > "" then ", " + outilTraduction:getLibelle(100611) + " " + local.cdeta else ""),
                                                                     chr(10)).
                    for each piece no-lock
                       where piece.noloc = local.noloc
                         break by piece.noloc:
                        if first(piece.noloc) 
                        then poFusionMandat:PiecesLotsMandat = substitute('&1&2 &3 : ',
                                                                          poFusionMandat:PiecesLotsMandat,
                                                                          outilTraduction:getLibelle(100361),
                                                                          string(local.nolot)).
                        assign
                            vcTmp = if piece.sfpie <> 0
                                    then " (" + montantToCharacter(piece.sfpie, false) + " " + outilTraduction:getLibelleParam("UTPIE", piece.uspie) + ")"
                                    else ""
                            poFusionMandat:PiecesLotsMandat = poFusionMandat:PiecesLotsMandat + outilTraduction:getLibelleParam("NTPIE", piece.ntpie) + LbTmpPdt.
                        if last(piece.noloc) 
                        then poFusionMandat:PiecesLotsMandat = poFusionMandat:PiecesLotsMandat + "." + chr(10). 
                        else poFusionMandat:PiecesLotsMandat = poFusionMandat:PiecesLotsMandat + ", ".
                    end.
                end.
            end.
            when {&FUSION-echCompteRendu}
            then for first tache no-lock
                where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-compteRenduGestion}
                  and tache.notac = 1: 
                poFusionMandat:EchCompteRendu = outilTraduction:getLibelleProg("O_PRD",tache.pdges).
            end.
            when {&FUSION-FgassuGarantieLoyerMdt}
            then poFusionMandat:FgAssuGarantieLoyerMdt = string(can-find(first tache no-lock
                                                                where tache.TpTac = {&TYPETACHE-AssurancesLoyer}
                                                                  and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                                                  and tache.nocon = piNumeroMandat
                                                                  and (tache.ntges > "00" or tache.tpges > "00")), "Oui/Non").
            when {&FUSION-PourRemuMand}
            then for last tache no-lock
                where tache.tptac = {&TYPETACHE-Honoraires}
                  and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and tache.nocon = piNumeroMandat
              , first honor no-lock
                where honor.tphon  = tache.tphon
                  and honor.cdhon  = integer(tache.cdhon)
                  and (honor.dtdeb = ? or (honor.dtdeb <> ? and honor.dtdeb <= today))
                  and (honor.dtfin = ? or (honor.dtfin <> ? and honor.dtfin >= today)):
                poFusionMandat:PourRemuMand = if honor.txhon <> 0 
                                              then string(honor.txhon) + " %"
                                              else montantToCharacter(honor.mthon, true).
            end.      
            when {&FUSION-SoldeProprietaire}            or when {&FUSION-SoldeProprietaireenLettre} or when {&FUSION-SoldeDebiteurMandant} or
            when {&FUSION-SoldeDebiteurMandantEnLettre} or when {&FUSION-SoldeCrediteurMandant}     or when {&FUSION-SoldeCrediteurMandantEnLettre}
            then do:
                if vlBloc4 then next boucleCHamp.

                assign
                    vlBloc4             = true
                    vcSoldeCompteDebit  = "0"
                    vcSoldeCompteCredit = "0"
                .
                for first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and ctrat.nocon = piNumeroMandat:
                    assign
                        vdSoldeCpt                  = SOLDECPT({&TYPECONTRAT-mandat2Gerance}, ctrat.nocon, ctrat.norol, "4111", today)
                        vcSoldeProprietaire         = montantToCharacter(vdSoldeCpt, true)
                        vcSoldeProprietaireEnLettre = CONVCHIFFRE(vdSoldeCpt)
                    .
                    if vdSoldeCpt > 0 
                    then assign
                        vcSoldeCompteDebit                           = montantToCharacter(vdSoldeCpt, true)
                        pofusionMandat:SoldeDebiteurMandantEnLettre  = CONVCHIFFRE(vdSoldeCpt)
                        pofusionMandat:SoldeCrediteurMandantEnLettre = CONVCHIFFRE(0)
                    .
                    else assign
                        vcSoldeCompteCredit                          = montantToCharacter(vdSoldeCpt,true)
                        pofusionMandat:SoldeDebiteurMandantEnLettre  = CONVCHIFFRE(0)
                        pofusionMandat:SoldeCrediteurMandantEnLettre = CONVCHIFFRE(vdSoldeCpt)
                    .
                    assign
                        poFusionMandat:SoldeDebiteurMandant  = vcSoldeCompteDebit
                        poFusionMandat:SoldeCrediteurMandant = vcSoldeCompteCredit
                    .
                end.
            end.
            when {&FUSION-NumRCS} or when {&FUSION-VilleRCS} or when {&FUSION-VilleCedexRCS}
            then do:
                if vlBloc5 then next boucleCHamp.

                vlBloc5 = true.
                for first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and ctrat.nocon = piNumeroMandat
                  , first roles no-lock
                    where roles.tprol = ctrat.tprol
                      and roles.norol = ctrat.norol
                  , first tiers no-lock
                    where tiers.notie = roles.notie:
                    for first ctanx  no-lock
                        where ctanx.tpcon = {&TYPECONTRAT-Association}
                          and ctanx.nocon = tiers.nocon:
                        poFusionMandat:NumRCS = ctanx.lbprf.
                    end.
                    for first ctanx no-lock
                        where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                          and ctanx.tprol = "99999"
                          and ctanx.norol = tiers.notie:
                        poFusionMandat:VilleRCS = suppCedex(ctanx.lbreg).
                    end.
                end.
            end.
            when {&FUSION-Capital}                         or when {&FUSION-QualiteContMandant}                or when {&FUSION-CapitalenLettre}                        or
            when {&FUSION-activiteMandant}                 or when {&FUSION-DtMariageMandant}                  or when {&FUSION-DtLMariageMandant}                      or
            when {&FUSION-DtMariageMandantLettre}          or when {&FUSION-LieuMariageMandant}                or when {&FUSION-RegimeMatrimonialMandant}               or
            when {&FUSION-NomNotaireContratMariageMandant} or when {&FUSION-VilleNotaireContratMariageMandant} or when {&FUSION-VilleCedexNotaireContratMariageMandant} or 
            when {&FUSION-111620}    /* PL : 11/01/2016 - (Fiche : 0711/0069) */
            then do:
                if vlBloc6 then next boucleCHamp.

                vlBloc6 = true.
                for first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and ctrat.nocon = piNumeroMandat
                  , first roles no-lock
                    where roles.tprol = ctrat.tprol
                      and roles.norol = ctrat.norol
                  , first tiers no-lock
                    where tiers.notie = roles.notie:
                    poFusionMandat:QualiteContMandant = tiers.lprf4.
                    for first ctanx no-lock
                        where ctanx.tpcon = {&TYPECONTRAT-Association}
                          and ctanx.nocon = tiers.nocon:
                        poFusionMandat:ActiviteMandant = entry(1,ctanx.cdobj,SEPAR[1]) + (if num-entries(ctanx.cdobj, SEPAR[1]) >= 2 then (chr(10) + ENTRY(2, ctanx.cdobj, SEPAR[1])) else "").
                        /* Information Mariage */
                        if tiers.cdsft = "06003" 
                        then assign
                            poFusionMandat:DtMariageMandant                       = dateToCharacter(ctanx.dtsig)
                            poFusionMandat:DtLMariageMandant                      = outilFormatage:getDateFormat(ctanx.dtsig, "L")
                            poFusionMandat:DtMariageMandantLettre                 = outilFormatage:getDateFormat(ctanx.dtsig, "LL")
                            poFusionMandat:LieuMariageMandant                     = ctanx.lisig
                            poFusionMandat:RegimeMatrimonialMandant               = outilTraduction:getLibelleParam("UNION", ctanx.cdreg)
                            poFusionMandat:NomNotaireContratMariageMandant        = ctanx.lnnot
                            poFusionMandat:VilleNotaireContratMariageMandant      = suppCedex(ctanx.liexe)
                            poFusionMandat:VilleCedexNotaireContratMariageMandant = ctanx.liexe
                            poFusionMandat:ComplementAdresseIdentNotaireContratMariageMandant = voAdresse:identAdresse
                        .
                        assign
                            poFusionMandat:Capital = replace(ctanx.mtcap, " ",      "")
                            poFusionMandat:Capital = replace(poFusionMandat:Capital, "Euros",  "")
                            poFusionMandat:Capital = replace(poFusionMandat:Capital, "Francs", "")
                            poFusionMandat:Capital = replace(poFusionMandat:Capital, "Euro",   "")
                            poFusionMandat:Capital = replace(poFusionMandat:Capital, "Franc",  "")
                        .
                        if num-entries(poFusionMandat:Capital, ",") > 1 and session:numeric-format = "American" 
                        then poFusionMandat:Capital = replace(poFusionMandat:Capital, ",", ".").
                        assign
                            poFusionMandat:CapitalEnLettre = CONVCHIFFRE(decimal(poFusionMandat:Capital))
                            poFusionMandat:Capital         = montantToCharacter(decimal(poFusionMandat:Capital), true) 
                        no-error.
                        if error-status:error or poFusionMandat:Capital = ? then poFusionMandat:Capital = ctanx.mtcap.
                    end.
                end.
            end.
            when {&FUSION-NomGestionnaireGerance}        or when {&FUSION-TitreDirecteuragenceGerance} or when {&FUSION-TitreLDirecteuragenceGerance} or
            when {&FUSION-NomDirecteuragenceGerance}     or when {&FUSION-NomagenceGerance}            or when {&FUSION-adresseagenceGerance}         or
            when {&FUSION-SuiteadresseagenceGerance}     or when {&FUSION-CodePostalagenceGerance}     or when {&FUSION-VilleagenceGerance}           or
            when {&FUSION-Tel1agenceGerance}             or when {&FUSION-TelGestionnaireGerance}      or when {&FUSION-FaxGestionnaireGerance}       or
            when {&FUSION-PortableGestionnaireGerance}   or when {&FUSION-emailGestionnaireGerance}    or when {&FUSION-VilleCedexagenceGerance}      or
            when {&FUSION-NomCompletGestionnaireGerance} or when {&FUSION-FonctionGestionnaireGerance} or when {&FUSION-111599}
            then do:
                if vlBloc7 then next boucleCHamp.

                assign
                    vlBloc7                               = true
                    poFusionMandat:NomGestionnaireGerance = outilTraduction:getLibelle(102281)
                .
                for first ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
                      and ctctt.tpct2 = {&TYPECONTRAT-mandat2Gerance}
                      and ctctt.noct2 = piNumeroMandat
                  , first ctrat no-lock
                    where ctrat.tpcon = ctctt.tpct1
                      and Ctrat.nocon = ctctt.noct1:
                    assign
                        voRole                                       = chargeRole(ctrat.tprol, ctrat.norol, piNumeroDocument)
                        // NomGestionnaireGerance = VALORISER("Nom", LbTmpPdt).
                        poFusionMandat:NomGestionnaireGerance        = voRole:nom
                        // run valoriseChampFusion(111055, "NomCompletGestionnaireGerance", VALORISER("Civilite",   LbTmpPdt) + " " + VALORISER("Nom", LbTmpPdt)).
                        poFusionMandat:NomCompletGestionnaireGerance = substitute('&1 &2', voRole:civilite, voRole:nom)
                        // run valoriseChampFusion(111543, "FonctionGestionnaireGerance",   VALORISER("Profession", LbTmpPdt)).
                        poFusionMandat:NomCompletGestionnaireGerance = voRole:profession
                        voAdresse                                  = chargeAdresse(ctrat.tprol, ctrat.norol, piNumeroDocument)
                        poFusionMandat:TelGestionnaireGerance      = voAdresse:telephone
                        poFusionMandat:TelGestionnaireGerance      = voAdresse:fax
                        poFusionMandat:PortableGestionnaireGerance = voAdresse:portable
                        poFusionMandat:EmailGestionnaireGerance    = voAdresse:mail
                    .
                    for first intnt no-lock 
                        where intnt.tpcon = ctrat.tpcon
                          and intnt.nocon = ctrat.nocon
                          and intnt.tpidt = {&TYPEROLE-directeurAgence}:
                        assign
                            voRole = chargeRole(intnt.tpidt, intnt.noidt, piNumeroDocument)
                            poFusionMandat:TitreDirecteurAgenceGerance  = voRole:titre
                            poFusionMandat:TitreLDirecteurAgenceGerance = voRole:titreLettre
                            poFusionMandat:NomDirecteurAgenceGerance    = voRole:nom
                        .
                    end.
                    assign
                        poFusionMandat:NomAgenceGerance = ctrat.noree
                        /* Coordonnees Mandant */
                        voAdresse                                = chargeAdresse(ctrat.tpcon, ctrat.nocon, piNumeroDocument)
                        poFusionMandat:AdresseAgenceGerance      = voAdresse:getLibelleAdresse()
                        poFusionMandat:SuiteAdresseAgenceGerance = voAdresse:complementVoie
                        poFusionMandat:CodePostalAgenceGerance   = voAdresse:codePostal
                        poFusionMandat:VilleAgenceGerance        = voAdresse:ville
                        poFusionMandat:Tel1AgenceGerance         = voAdresse:telephone
                        poFusionMandat:villeCedex                = voAdresse:cedex
                        poFusionMandat:ComplementAdresseIdentAgenceGerance = voAdresse:cedex
                    .
                end.
            end.
            when {&FUSION-MilliemesLotsMandat}
            then for each intnt no-lock
                where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and intnt.nocon = piNumeroMandat
                  and intnt.tpidt = {&TYPEBIEN-lot}
              , first local no-lock
                where local.noloc = intnt.noidt
              , each milli no-lock 
                where milli.noimm = local.noimm
                  and milli.nolot = local.nolot
                  and milli.cdcle = "A"
              , first clemi no-lock
                where clemi.noimm = local.noimm
                  and clemi.cdcle = milli.cdcle
                by local.noimm by local.nolot:
                poFusionMandat:MilliemesLotsMandat = poFusionMandat:MilliemesLotsMandat
                                                   + (if poFusionMandat:MilliemesLotsMandat = "" then "" else chr(10))
                                                   + outilTraduction:getLibelle(100361) + " " + string(milli.nolot) + " "
                                                   + outilTraduction:getLibelle(103157) + " " + string(milli.nbpar) + "/" + string(clemi.nbtot).
            end.
          when {&FUSION-BanqueMandant}           or when {&FUSION-NoCompteBancaireMandant} or when {&FUSION-TituRibMandant} or
          when {&FUSION-NatioemetteurBquMandant} or when {&FUSION-NoBICMandant}            or when {&FUSION-NoIBaNMandat}   or
          when {&FUSION-BanqueMandat}            or when {&FUSION-NoBICMandat}
          then do:
              if vlBloc8 then next boucleCHamp.

              vlBloc8 = true.
              release ctanx no-error.
              find first ctrat no-lock
                  where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                    and ctrat.nocon = piNumeroMandat no-error.
              if available ctrat then do:
                  find first rlctt no-lock
                      where rlctt.tpidt = ctrat.tprol
                        and rlctt.noidt = ctrat.norol
                        and rlctt.tpct2 = {&TYPECONTRAT-prive} no-error.
                  if available rlctt 
                  then find first ctanx no-lock
                      where ctanx.tpcon = rlctt.tpct2
                        and ctanx.nocon = rlctt.noct2 no-error.
                  else do:
                      find first roles no-lock
                          where roles.tprol = ctrat.tprol
                            and roles.norol = ctrat.norol no-error.
                      if available roles 
                      then find first ctanx no-lock
                          where ctanx.tprol = "99999"
                            and ctanx.norol = roles.notie
                            and ctanx.tpact = "DEFAU"
                            and ctanx.tpcon = {&TYPECONTRAT-prive} no-error.
                  end.
                  if available ctanx
                  then assign
    //                  poFusionMandat:Banque           = ctanx.lbdom
    //                  poFusionMandat:NoCompteBancaire = ctanx.iban
    //                  poFusionMandat:TituRib          = ctanx.lbtit
                      poFusionMandat:NoBICMandant     = ctanx.bicod.
                  .
              end.
              /* Numero National d'emetteur */
              for first ietab no-lock
                  where ietab.soc-cd = integer(mtoken:cRefGerance)
                    and ietab.etab-cd = piNumeroMandat:
                  case ietab.bqprofil-cd:
                      when 21 or when 91 then CpUseInc = ietab.etab-cd.
                      when 20            then CpUseInc = 8000.
                      when 90            then CpUseInc = 9000.
                      otherwise               CpUseInc = 8500.
                  end case.
                  for first ijou no-lock
                      where ijou.soc-cd  = ietab.soc-cd
                        and ijou.etab-cd = CpUseInc
                        and ijou.jou-cd  = ietab.bqjou-cd
                    , first ibque no-lock
                      where ibque.soc-cd  = ijou.soc-cd
                        and ibque.etab-cd = ijou.etab-cd 
                        and ibque.cpt-cd  = ijou.cpt-cd:
                      poFusionMandat:NatioEmetteurBquMandant = ibque.nne.
                  end.
                  /* Ajout SY le 13/05/2013 (Vu avec OF) */
                  /*** banque globale ***/
                  if ietab.bqprofil-cd modulo 10 = 0 then do:
                      find first bietab no-lock
                          where bietab.soc-cd = ietab.soc-cd 
                            and bietab.profil-cd = ietab.bqprofil-cd no-error.
                      find first ijou no-lock
                          where ijou.soc-cd  = bietab.soc-cd
                            and ijou.etab-cd = bietab.etab-cd
                            and ijou.jou-cd  = ietab.bqjou-cd no-error.
                  end.
                  else find first ijou no-lock
                      where ijou.soc-cd  = ietab.soc-cd
                        and ijou.etab-cd = ietab.etab-cd
                        and ijou.jou-cd  = ietab.bqjou-cd no-error.
                  if available ijou 
                  then for first ibque no-lock
                      where ibque.soc-cd  = ijou.soc-cd
                        and ibque.etab-cd = ijou.etab-cd
                        and ibque.cpt-cd  = ijou.cpt-cd:
                      assign
                          poFusionMandat:NoIBANMandat = ibque.iban
                          poFusionMandat:BanqueMandat = ibque.bic
                          poFusionMandat:NoBICMandat  = ibque.nom
                      .
                 end.
             end.
         end.
         when {&FUSION-LstBeneficiaireMandat}
         then for each ctrlb no-lock
                 where ctrlb.tpctt = {&TYPECONTRAT-mandat2Gerance}
                   and ctrlb.noctt = piNumeroMandat
                   and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                   and ctrlb.nbnum <> 0:
              assign
                  voRole = chargeRole(ctrlb.tpid2, ctrlb.noid2, piNumeroDocument)
                  vcTmp  = voRole:nomComplet
                  poFusionMandat:LstBeneficiaireMandat = poFusionMandat:LstBeneficiaireMandat 
                                                       + (if poFusionMandat:LstBeneficiaireMandat > "" then ", " else "") + vcTmp
              .
         end.
         when {&FUSION-FgIRFMdt}
         then do:
             poFusionMandat:FgIRFMdt = "NON".
             for first tache no-lock
                 where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                   and tache.nocon = piNumeroMandat
                   and tache.tptac = {&TYPETACHE-ImpotRevenusFonciers}:
                 poFusionMandat:FgIrfMdt = "OUI".
             end.
        end.
        when {&FUSION-FgPieceMdt100} or when {&FUSION-FgGarantieSpecialeMdt} or when {&FUSION-FgGarantieLoyerMdt} or
        when {&FUSION-FgPieceMdt101} or when {&FUSION-FgPieceMdt102}         or when {&FUSION-FgPieceMdt103}      or
        when {&FUSION-FgPieceMdt104} or when {&FUSION-FgPieceMdt105}         or when {&FUSION-FgPieceMdt106}      or
        when {&FUSION-FgPieceMdt107} or when {&FUSION-FgPieceMdt108}         or when {&FUSION-FgPieceMdt109}      or
        when {&FUSION-FgPieceMdt110}
        then do:
            if vlBloc9 then next boucleCHamp.

            assign
                vlBloc9                              = true
                poFusionMandat:FgPieceMdt100         = "NON"
                poFusionMandat:FgPieceMdt101         = "NON"
                poFusionMandat:FgPieceMdt102         = "NON"
                poFusionMandat:FgPieceMdt103         = "NON"
                poFusionMandat:FgPieceMdt104         = "NON"
                poFusionMandat:FgPieceMdt105         = "NON"
                poFusionMandat:FgPieceMdt106         = "NON"
                poFusionMandat:FgPieceMdt107         = "NON"
                poFusionMandat:FgPieceMdt108         = "NON"
                poFusionMandat:FgPieceMdt109         = "NON"
                poFusionMandat:FgPieceMdt110         = "NON"
                poFusionMandat:FgGarantieSpecialeMdt = "NON"
                poFusionMandat:FgGarantieLoyerMdt    = "NON"
            .
            for first tache no-lock
                where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-DossierMandat}:
                voDossierMandat = new parametrageDossierMandat().
                if voDossierMandat:isOuvert()
                then do i = 1 to voDossierMandat:nombrePiece():
                    /* NP 1110/0136 Même si on a 'Non' à l'affichage de la tâche 'Dossier Mandat', 
                       tache.ntreg = "" sur certains mandats -> il faut les exclure sinon plantage */
                    if entry(i, voDossierMandat:pieceObligatoire(), SEPAR[1]) = "00001" and tache.ntreg > ""
                    then case entry(i, voDossierMandat:listePiece(), SEPAR[1]):
                        when "100" then poFusionMandat:FgPieceMdt100 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "101" then poFusionMandat:FgPieceMdt101 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "102" then poFusionMandat:FgPieceMdt102 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "103" then poFusionMandat:FgPieceMdt103 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "104" then poFusionMandat:FgPieceMdt104 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "105" then poFusionMandat:FgPieceMdt105 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "106" then poFusionMandat:FgPieceMdt106 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "107" then poFusionMandat:FgPieceMdt107 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "108" then poFusionMandat:FgPieceMdt108 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "109" then poFusionMandat:FgPieceMdt109 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                        when "110" then poFusionMandat:FgPieceMdt110 = caps(outilTraduction:getLibelleParam("CDOUI", entry(i, Tache.ntreg, SEPAR[1]))).
                    end case.
                end.
                if valid-object(voDossierMandat) then delete object voDossierMandat.
                assign
                    poFusionMandat:FgGarantieSpecialeMdt = caps(outilTraduction:getLibelleParam("CDOUI", tache.tphon))
                    poFusionMandat:FgGarantieLoyerMdt    = caps(outilTraduction:getLibelleParam("CDOUI", tache.utreg))
                .
            end.
        end.
        end case.
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.
end procedure.

procedure CalDtMax:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pdaInitialContrat  as date      no-undo.
    define input  parameter piDureeContrat     as integer   no-undo.
    define input  parameter pcCodeDureeContrat as character no-undo.
    define input  parameter pcFlagDuree        as character no-undo.
    define input  parameter piDureeMax         as integer   no-undo.
    define input  parameter pcCodeDureeMax     as character no-undo.
    define input  parameter piNombreMax        as integer   no-undo.
    define output parameter pdaMaxContrat      as date      no-undo.

    define variable viNombreMoisDuree as integer  no-undo.
    define variable vdaCalculee       as date     no-undo.
    define variable vdaFinCalculee    as date     no-undo.
    define variable viBoucle          as integer  no-undo.

    if pdaInitialContrat = ? then return.

    if pcFlagDuree = "YES" then do:
        if piDureeMax = 0 then return.

        assign
            viNombreMoisDuree = if pcCodeDureeMax = '00001' then 12 * piDureeMax else piDureeMax
            vdaFinCalculee    = add-interval(pdaInitialContrat, viNombreMoisDuree, "months")
            vdaFinCalculee    = date(month(vdaFinCalculee), 28, year(vdaFinCalculee)) + 4
            vdaFinCalculee    = vdaFinCalculee - day(vdaFinCalculee)
        .
        if vdaFinCalculee = ? then return.

        /* Recuperation de la Date d'Expiration calculee */
        pdaMaxContrat = vdaFinCalculee - 1.
    end.
    else do:
        if piNombreMax = 0 or piDureeContrat = 0 then return.

        assign
            viNombreMoisDuree = if pcCodeDureeContrat = '00001' then 12 * piDureeContrat else piDureeContrat
            vdaCalculee       = pdaInitialContrat
        .
        do viBoucle = 1 to piNombreMax:
            assign
                vdaFinCalculee = add-interval(vdaCalculee, viNombreMoisDuree, "months")
                vdaFinCalculee = date(month(vdaFinCalculee), 28, year(vdaFinCalculee)) + 4
                vdaFinCalculee = vdaFinCalculee - day(vdaFinCalculee)
            .
            if vdaFinCalculee = ? then return.

            /* Recuperation de la Date d'Expiration calculee */
            pdaMaxContrat = vdaFinCalculee - 1.
        end.
    end.

end procedure.
