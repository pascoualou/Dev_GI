/*-----------------------------------------------------------------------------
File        : extractionSyndic.p
Description : Recherche des donnees de fusion mandat de syndic
Author(s)   : RF - 2008/04/18, KANTENA - 2018/02/26
Notes       :
01  23/10/2008  NP    0608/0065 Gestion Mandats à 5 chiffres
02  28/04/2009  SY    ne pas initialiser les variables globales d'extraction Fgxxxxx à TRUE (Init dans extract.p uniquement).
03  27/08/2010  NP    0810/0096 Modif ds fctexpor.i
04  25/05/2011  PL    0211/0163 Nouveaux champs prè-bail
05  31/12/2012  NP    0912/0002 Add coord. bancaires du syndicat
06  18/03/2015  SY    0315/0143 Banque du mandat de syndic en COMPTA
07  19/03/2015  SY    0315/0143 retour arrière sauf correction pb champ "PAS VALORISE"
08  19/08/2015  SY    0115/0185 Nouveau champ FonctionGestionnaireCopro
09  11/01/2016  PL    0711/0069 Normalisation adresses sur 6 lignes
10  25/01/2016  PL    0711/0069 Normalisation adresses sur 6 lignes
-----------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionSyndic.i}
{preprocesseur/listeRubQuit2TVA.i}

using bureautique.fusion.classe.fusionSyndic.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionBanque.
using bureautique.fusion.classe.fusionRole.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

procedure extractionSyndic:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroSyndic   as integer   no-undo.
    define input        parameter piNumeroDocument as integer   no-undo.
    define input        parameter pcListeChamp     as character no-undo.
    define input-output parameter poFusionSyndic   as class fusionSyndic no-undo.

    /* NP 0912/0002 */
    define variable vcNumSyndCopro as character no-undo.
    define variable viCompteur     as integer   no-undo.
    define variable vlBloc1        as logical   no-undo.
    define variable vlBloc2        as logical   no-undo.
    define variable vlBloc3        as logical   no-undo.
    define variable vlBloc4        as logical   no-undo.
    define variable vlBloc5        as logical   no-undo.
    define variable voAdresse      as class fusionAdresse no-undo.
    define variable voRole         as class fusionRole    no-undo.

    define buffer ctrat for ctrat.
    define buffer ctanx for ctanx.
    define buffer intnt for intnt.
    define buffer clemi for clemi.
    define buffer milli for milli.
    define buffer local for local.
    define buffer tache for tache.
    define buffer ctctt for ctctt.
    define buffer rlctt for rlctt.
    define buffer taint for taint.
    define buffer vbRoles for roles.

    assign
        vcNumSyndCopro = string(piNumeroSyndic, "99999")
        poFusionSyndic:NoMandat = vcNumSyndCopro
    .

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-TitreSyndCopro} or when {&FUSION-TitreLSyndCopro} or when {&FUSION-CiviliteSyndCopro}
         or when {&FUSION-NomSyndCopro} then do:
                if vlBloc1 then next boucleCHamp.

                assign
                    vlBloc1                          = true
                    voRole                           = chargeRole({&TYPEROLE-syndicat2copro}, integer(vcNumSyndCopro), piNumeroDocument)
                    poFusionSyndic:TitreSyndCopro    = voRole:Titre
                    poFusionSyndic:TitreLSyndCopro   = voRole:TitreLettre
                    poFusionSyndic:CiviliteSyndCopro = voRole:civilite
                    poFusionSyndic:NomSyndCopro      = voRole:Nom
                .
            end.
            when {&FUSION-AdresseSyndCopro} or when {&FUSION-SuiteAdresseSyndCopro} or when {&FUSION-CodePostalSyndCopro}
         or when {&FUSION-VilleSyndCopro}   or when {&FUSION-TelSyndCopro}          or when {&FUSION-VilleCedexSyndCopro}
         or when {&FUSION-ComplementAdresseIdentSyndCopro} then do:   /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                if vlBloc2 then next boucleCHamp.

                assign
                    vlBloc2                                        = true
                    voAdresse                                      = chargeAdresse({&TYPEROLE-syndicat2copro}, integer(vcNumSyndCopro), piNumeroDocument)
                    poFusionSyndic:AdresseSyndCopro                = voAdresse:Adresse
                    poFusionSyndic:SuiteAdresseSyndCopro           = voAdresse:complementVoie
                    poFusionSyndic:CodePostalSyndCopro             = voAdresse:CodePostal
                    poFusionSyndic:VilleSyndCopro                  = voAdresse:VilleSansCedex()
                    poFusionSyndic:TelSyndCopro                    = voAdresse:Telephone
                    poFusionSyndic:VilleCedexSyndCopro             = voAdresse:Ville
                    poFusionSyndic:ComplementAdresseIdentSyndCopro = voAdresse:IdentAdresse
                . 
            end.
            when {&FUSION-NumRegSyn}           or when {&FUSION-DateSigSyn}               or when {&FUSION-LieSigSyn}
         or when {&FUSION-DateDebSyn}          or when {&FUSION-DateFinSyn}               or when {&FUSION-DureeSyn}
         or when {&FUSION-DelaiSyn}            or when {&FUSION-DateResiliationSyn}       or when {&FUSION-MotifResiliationSyn}
         or when {&FUSION-DatelDebSyn}         or when {&FUSION-DateDebSynLettre}         or when {&FUSION-DatelSigSyn}
         or when {&FUSION-DateSigSynLettre}    or when {&FUSION-DatelFinSyn}              or when {&FUSION-DateFinSynLettre}
         or when {&FUSION-DatelResiliationSyn} or when {&FUSION-DateResiliationSynLettre} or when {&FUSION-DateIniSyn}
         or when {&FUSION-DateLIniSyn}         or when {&FUSION-DateIniSynenLettre}
            then do:
                if vlBloc3 then next boucleCHamp.

                vlBloc3 = true.
                for first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and ctrat.nocon = piNumeroSyndic:
                    assign
                        poFusionSyndic:NumRegSyn                = ctrat.noree
                        poFusionSyndic:DateDebSyn               = dateToCharacter(ctrat.dtdeb)
                        poFusionSyndic:DateLDebSyn              = outilFormatage:getDateFormat(ctrat.dtdeb, "L")
                        poFusionSyndic:DateDebSynLettre         = outilFormatage:getDateFormat(ctrat.dtdeb, "LL")
                        poFusionSyndic:DateSigSyn               = dateToCharacter(ctrat.dtsig)
                        poFusionSyndic:DateLSigSyn              = outilFormatage:getDateFormat(ctrat.dtsig, "L")
                        poFusionSyndic:DateSigSynLettre         = outilFormatage:getDateFormat(ctrat.dtsig, "LL")
                        poFusionSyndic:LieSigSyn                = ctrat.lisig
                        poFusionSyndic:DateFinSyn               = dateToCharacter(ctrat.dtfin)
                        poFusionSyndic:DateLFinSyn              = outilFormatage:getDateFormat(ctrat.dtfin, "L")
                        poFusionSyndic:DateFinSynLettre         = outilFormatage:getDateFormat(ctrat.dtfin, "LL")
                        poFusionSyndic:DureeSyn                 = string(ctrat.nbdur) + " " + outilTraduction:getLibelleParam("UTDUR", ctrat.cddur)
                        poFusionSyndic:DateResiliationSyn       = dateToCharacter(ctrat.dtree)
                        poFusionSyndic:DateLResiliationSyn      = outilFormatage:getDateFormat(ctrat.dtree, "L")
                        poFusionSyndic:DateResiliationSynLettre = outilFormatage:getDateFormat(ctrat.dtree, "LL")
                        poFusionSyndic:DelaiSyn                 = string(ctrat.nbres)
                        poFusionSyndic:MotifResiliationSyn      = outilTraduction:getLibelleParam("TPMOT", ctrat.tpfin)
                        poFusionSyndic:DateIniSyn               = dateToCharacter(ctrat.dtini)
                        poFusionSyndic:DateLIniSyn              = outilFormatage:getDateFormat(ctrat.dtini, "L")
                        poFusionSyndic:DateIniSynenLettre       = outilFormatage:getDateFormat(ctrat.dtini, "LL")
                    .
                end.
            end.
            when {&FUSION-Tantieme} then do:
                find first intnt no-lock
                     where intnt.tpidt = {&TYPEBIEN-immeuble}
                       and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                       and intnt.nocon = piNumeroSyndic no-error.
                if available intnt
                then for each clemi no-lock
                   where clemi.noimm = intnt.noidt
                     and clemi.nbtot <> 0
                     and clemi.cdeta = "V"
                  , each milli no-lock
                   where milli.noimm = clemi.noimm
                     and milli.cdcle = clemi.cdcle
                     and milli.nbpar <> 0
                 , first local no-lock
                   where local.noimm = milli.noimm
                     and local.nolot = milli.nolot
                 , first intnt no-lock
                   where intnt.tpidt = {&TYPEBIEN-lot}
                     and intnt.noidt = local.noloc
                     and intnt.tpcon = {&TYPECONTRAT-titre2copro}
                     and intnt.nocon > integer(vcNumSyndCopro + "00000")
                     and intnt.nocon < integer(vcNumSyndCopro + "99999")
                     and intnt.nbden = 0
                 , first ctrat no-lock 
                   where ctrat.tpcon = intnt.tpcon
                     and ctrat.nocon = intnt.nocon
                     break by milli.cdcle by milli.nolot:
                    if first-of(milli.cdcle)
                    then poFusionSyndic:Tantieme = substitute("&1&2 &3&4&5 - &6&7&4&8&4&9&4",
                                                       poFusionSyndic:Tantieme,
                                                       outilTraduction:getLibelle(100032),
                                                       clemi.cdcle,
                                                       chr(9),
                                                       clemi.nbtot,
                                                       clemi.lbcle,
                                                       chr(10),
                                                       outilTraduction:getLibelle(100361),
                                                       outilTraduction:getLibelle(104823))
                                                 + outilTraduction:getLibelle(101185) + chr(10).
                    poFusionSyndic:Tantieme = substitute("&1&2&3&2&4&2&5&6",
                                                  poFusionSyndic:Tantieme, chr(9), string(milli.nolot, "99999"),
                                                  milli.nbpar, outilFormatage:getNomTiers(ctrat.tprol, ctrat.norol), chr(10)).
                end.
            end.
            when {&FUSION-TitrePresident}        or when {&FUSION-TitreLPresident}     or when {&FUSION-NomPresident}
         or when {&FUSION-NomPresidentSeul}      or when {&FUSION-PrenomPresidentSeul} or when {&FUSION-AdressePresident}
         or when {&FUSION-SuiteAdressePresident} or when {&FUSION-CodePostalPresident} or when {&FUSION-VillePresident}
         or when {&FUSION-TelephonePresident}    or when {&FUSION-NumPresident}        or when {&FUSION-PortablePresident}
         or when {&FUSION-FaxPresident}          or when {&FUSION-EmailPresident}      or when {&FUSION-VilleCedexPresident}
         or when {&FUSION-ComplementAdresseIdentPresident}    /* PL : 11/01/2016 - (Fiche : 0711/0069) */
            then do:
                if vlBloc4 then next boucleCHamp.

                vlBloc4 = true.
                for last tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and tache.nocon = piNumeroSyndic
                      and tache.tptac = {&TYPETACHE-conseilSyndical}
                  , each Taint no-lock
                    where taint.tpcon = tache.tpcon
                      and taint.nocon = tache.nocon
                      and taint.tpidt = {&TYPEROLE-presidentConseilSyndical}
                      and taint.tptac = tache.tptac
                      and taint.notac = tache.notac:
                    assign
                        voRole                             = chargeRole(taint.tpidt, taint.noidt, piNumeroDocument)
                        poFusionSyndic:NumPresident        = string(taint.noidt)
                        poFusionSyndic:TitrePresident      = voRole:Titre
                        poFusionSyndic:TitreLPresident     = voRole:TitreLettre
                        poFusionSyndic:NomPresident        = voRole:NomComplet
                        poFusionSyndic:NomPresidentSeul    = voRole:Nom
                        poFusionSyndic:PrenomPresidentSeul = voRole:Prenom
                        voAdresse                                      = chargeAdresse(taint.tpidt, taint.noidt, piNumeroDocument)
                        poFusionSyndic:AdressePresident                = voAdresse:Adresse
                        poFusionSyndic:SuiteAdressePresident           = voAdresse:complementVoie
                        poFusionSyndic:CodePostalPresident             = voAdresse:CodePostal
                        poFusionSyndic:VillePresident                  = voAdresse:Ville
                        poFusionSyndic:TelephonePresident              = voAdresse:Telephone
                        poFusionSyndic:PortablePresident               = voAdresse:Portable
                        poFusionSyndic:FaxPresident                    = voAdresse:Fax
                        poFusionSyndic:EmailPresident                  = voAdresse:Mail
                        poFusionSyndic:VilleCedexPresident             = voAdresse:Ville
                        poFusionSyndic:ComplementAdresseIdentPresident = voAdresse:IdentAdresse
                    .
                end.
            end.
            when {&FUSION-NomGestionnaireCopro}        or when {&FUSION-TitreDirecteurAgenceCopro} or when {&FUSION-TitreLDirecteurAgenceCopro}
         or when {&FUSION-NomDirecteurAgenceCopro}     or when {&FUSION-NomAgenceCopro}            or when {&FUSION-adresseagenceCopro}
         or when {&FUSION-SuiteAdresseAgenceCopro}     or when {&FUSION-CodePostalAgenceCopro}     or when {&FUSION-VilleAgenceCopro}
         or when {&FUSION-Tel1AgenceCopro}             or when {&FUSION-TelGestionnaireCopro}      or when {&FUSION-FaxGestionnaireCopro}
         or when {&FUSION-PortableGestionnaireCopro}   or when {&FUSION-EmailGestionnaireCopro}    or when {&FUSION-VilleCedexAgenceCopro}
         or when {&FUSION-NomCompletGestionnaireCopro} or when {&FUSION-FonctionGestionnaireCopro} or when {&FUSION-ComplementAdresseIdentAgenceCopro}
            then do:
                if vlBloc5 then next boucleCHamp.

                vlBloc5 = true.
                for first ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
                      and ctctt.tpct2 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.noct2 = piNumeroSyndic
                  , first ctrat no-lock
                    where ctrat.tpcon = ctctt.tpct1
                      and Ctrat.nocon = ctctt.noct1:
                    assign
                        voRole                                     = chargeRole(ctrat.tprol, ctrat.norol, piNumeroDocument)
                        poFusionSyndic:NomGestionnaireCopro        = voRole:Nom
                        poFusionSyndic:NomCompletGestionnaireCopro = substitute('&1 &2', voRole:Civilite, voRole:Nom)
                        poFusionSyndic:FonctionGestionnaireCopro   = voRole:profession
                        voAdresse                                  = chargeAdresse(ctrat.tprol, ctrat.norol, piNumeroDocument)
                        poFusionSyndic:TelGestionnaireCopro        = voAdresse:Telephone
                        poFusionSyndic:FaxGestionnaireCopro        = voAdresse:Fax
                        poFusionSyndic:PortableGestionnaireCopro   = voAdresse:Portable
                        poFusionSyndic:EmailGestionnaireCopro      = voAdresse:Mail
                    .
                    for first intnt no-lock
                        where intnt.tpcon = ctrat.tpcon
                          and intnt.nocon = ctrat.nocon
                          and intnt.tpidt = {&TYPEROLE-directeurAgence}:
                        assign
                            voRole                                    = chargeRole(intnt.tpidt, intnt.noidt, piNumeroDocument)
                            poFusionSyndic:TitreDirecteurAgenceCopro  = voRole:Titre
                            poFusionSyndic:TitreLDirecteurAgenceCopro = voRole:TitreLettre
                            poFusionSyndic:NomDirecteurAgenceCopro    = voRole:Nom
                        .
                    end.
                    /* Coordonnees Mandant */
                    assign
                        voAdresse                                        = chargeAdresse(ctrat.tpcon, ctrat.nocon, piNumeroDocument)
                        poFusionSyndic:NomAgenceCopro                    = ctrat.noree
                        poFusionSyndic:adresseagenceCorpo                = voAdresse:Adresse
                        poFusionSyndic:SuiteAdresseAgenceCopro           = voAdresse:complementVoie
                        poFusionSyndic:CodePostalAgenceCopro             = voAdresse:CodePostal
                        poFusionSyndic:VilleAgenceCopro                  = voAdresse:Ville
                        poFusionSyndic:Tel1AgenceCopro                   = voAdresse:Telephone
                        poFusionSyndic:VilleCedexAgenceCopro             = voAdresse:ville
                        poFusionSyndic:ComplementAdresseIdentAgenceCopro = voAdresse:IdentAdresse
                    .
                end.
            end.
            when {&FUSION-BanqueSyndicat} or when {&FUSION-NoCompteBancaireSyndicat} or when {&FUSION-TitulaireBanqueSyndicat}
         or when {&FUSION-NoBICSyndicat} then do:
                if vlBloc5 then next boucleCHamp.

                vlBloc5 = true.
                {&_proparse_ prolint-nowarn(release)}
                release ctanx no-error.
                /* Infos Banque */
                find first rlctt no-lock
                    where rlctt.tpidt = {&TYPEROLE-syndicat2copro}
                      and rlctt.noidt = piNumeroSyndic
                      and rlctt.tpct2 = {&TYPECONTRAT-prive} no-error.
                if available rlctt
                then find first ctanx no-lock
                    where ctanx.tpcon = rlctt.tpct2
                      and ctanx.nocon = rlctt.noct2  no-error.
                else do:
                    find first vbRoles no-lock
                        where vbRoles.tprol = {&TYPEROLE-syndicat2copro}
                          and vbRoles.norol = piNumeroSyndic no-error.
                    if available vbRoles 
                    then find first ctanx no-lock
                        where ctanx.tprol = "99999"
                          and ctanx.norol = vbRoles.notie
                          and ctanx.tpact = "DEFAU"
                          and ctanx.tpcon = {&TYPECONTRAT-prive} no-error.
                end.
                if available ctanx 
                then assign
                    poFusionSyndic:BanqueSyndicat           = ctanx.lbdom
                    poFusionSyndic:NoCompteBancaireSyndicat = ctanx.iban
                    poFusionSyndic:TitulaireBanqueSyndicat  = ctanx.lbtit
                    poFusionSyndic:NoBICSyndicat            = ctanx.bicod
                .
            end.
        end case.
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
