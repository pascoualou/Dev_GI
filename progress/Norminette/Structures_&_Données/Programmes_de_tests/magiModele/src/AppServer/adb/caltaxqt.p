/*-----------------------------------------------------------------------------
File        : caltaxqt.p
Purpose     : Module de calcul de TOUTES LES RUBRIQUES TAXE d'une quittance (param sys_pg O_TAE; zon08 = T@Taxe|)
Author(s)   : LG - 1996/05/03, Kantena - 2017/12/21
Notes       :
    ATTENTION: En cas d'ajout d'un nouveau code calcul TVA il faut penser à modifier la comptabilite
             - factures Locataires: fdiv/tfacrbqt.p
             - chargement rubriques quit/type pour la compta: chgrubqt.p
    ATTENTION: Toute modification est à reporter dans les modules compta
             - factures Locataires: fdiv/tfacrbqt.p
             - chargement rubriques quit/type pour la compta: chgrubqt.p
             - Refacturation aux locataires des dépenses mandat: vtlfac01.p
             - Evenementiel: simu révision event/calrevis.p
derniere revue: 2018/04/26 - phm: OK

01 09/05/1996  SP    Correction du calcul du nombre de rubriques
02 21/05/1996  SP    Modif recherche des taches de type taxe qui ont été prises en charge pour ce contrat
03 16/06/1996  LG    Génération des montants totaux proratés de la quittance pour chaque taxe. (MtTotQt)
04 04/07/1996  LG    Modif du for each bxrbp: inversion.
05 27/01/1997  LG    Calcul droit de bail si loyer > 1000 mais modif. provisoire. A REVOIR!!
06 07/05/1997  SY    Ajout argument "mois quittancement" pour la procédure IsTaxAdd.
07 09/05/1997  SP    Remplacement de "CDDBT" par "TXFIS"
08 07/07/1997  SY    Remplacement test provisoire pour droit de bail (mtloy < 1000) par procédure IsDrtBai
09 09/12/1997  SY    Correction (en accord avec M.B.)
                      Pour le cumul du loyer, on n'utilise plus bxrbp mais on prend la famille '01'.
                      sauf la sous-famille '04' (APL) (code tva faux dans bxrbp pour les rubriques APL)                º
10 10/12/1997  SY    Fiche 1289: 2 modes de calcul TVA;
                      soit sur total loyer (valeur par d‚faut) soit sur total quittance (sauf APL & TVA)             º
11 11/01/1998  BV    Ajout des modes de calcul "Total loyer + Charges" et "Total loyer + Charges + Impots et Taxes".                                   º
12 21/01/1998  BV    CdCalTVA = "00001" si le champ PdGes de la tache n'est pas renseigné.
13 31/01/1998  SC    CdCalTVA => vcModeCalcul car cette variable intervient dans le mode de calcul de toutes les Rubriques
                      de Type Taxe (pas seulement T.V.A.). De ce fait, si Bail soumis au Droit de Bail ou Taxe Add,
                      on force cette Variable à 00001 (Calcul sur Somme des Rub. Loyer hors A.P.L).
14 22/05/1998  SY    Fiche 1389: Recherche si locataire soumis au droit de Bail
                       1) Avec le cumul loyer Principal+Annexe
                       2) Avec le cumul loyer Principal+Annexe FIXE
15 16/06/1998  SY    Initialisation pcCodeRetour à "00" sinon on considère que l'absence de calcul des taxes est une erreur.
16 12/03/1999  SY    Fiche 2416: correction sortie prématurée si calcul sur loyer+charges et pas de loyer (=> la rub TVA n'était pas générée)
17 27/10/1999  SY    AGF/ALLIANZ: Pb nbrub qui s'incrémente trop car le no lib de la rub taxe est à 0 dans la tache
                      => on ne trouve pas bxrbp => on ne supprime pas les rub taxes => on ne décrémente plus avant d'incrémenter
18 09/02/2000  SY    Ajout calcul TVA sur services (hôteliers, tâche 04109).
                      Pour le calcul de la TVA sur le Bail, on ne cumule pas les services hôteliers (fam 04, sfa 03) dans le total quittance
                      car on ne peut pas calculer 2 fois la TVA sur une même rubrique.
                      Plus de sortie du programme en plein milieu de la boucle sur les taches
19 11/02/2000  LG    gestion de la régul du droit de bail pour la loi de finance 1999 et gestion du droit de bail (assujetti ou non)
                     par rapport à la situation de 1999.
20 14/02/2000  LG    gestion de la taxe additionnelle sans tenir compte du droit de bail et si loyer annuel > 12000.
                      Modif de IsTaxadd (ajout du montant dans les paramètres).
21 16/02/2000  LG    modif. dans le calcul de la regul.: tenir compte d'assujetti ou non.
22 17/02/2000  LG    Gérer les problèmes d'arrondis. Et ne lancer la régul que si assujetti en totalité(loyer > 12000).
23 18/02/2000  LG    tenir compte des rub. 750 et 760 qui peuvent etre prises en charge et aussi des avances échus pour la régul.
24 06/03/2000  SY    Modif calcul TVA sur services Annexe (tâche 04109).
                      Il peut y avoir des taux différents selon les sous-familles de rubriques
                      (20.6% pour les services hoteliers, 5.5% pour la redevance, 20.6% pour d'autres services)
                       Rubriques concernées: Famille 04; sous-familles 03, 05 et 06
25 08/03/2000  LG    Modif calcul regul. droit de bail=> generer la regul. que si on a bien l'info. exonéré ou assujetti.
26 04/04/2000  LG    Gestion d'un paramètrage client pour gérer ou non la rub. 760 dans le calcul de la crdb. par défaut à OUI
27 02/05/2000  SY    Fiche 5077/5099: (pour Marie ST germain) Ajout mode de calcul Loyer + Taxes (& impots)
                     + correction montants total/quittancé inversés pour calcul Loyer+charges+impots & taxes
28 06/09/2000  PL    Gestion Double affichage Euro/Devise.
29 14/09/2000  LG    Calcul sur le total de la quittance: ne pas tenir compte des rub. assurances locatives.
30 06/10/2000  JC    Manpower: Pas de rubrique droit de bail
31 08/11/2000  LG    Pb dans calcul TVA sur total quittance de à la modif. sur les assurances locatives
32 07/12/2000  LG    Plus de calcul droit de bail pour Janvier 2001.
33 13/05/2005  SY    0405/0409: changement mode de calcul TVA. On fait le cumul des TVA calculées/Rub et non plus le calcul TVA sur le cumul des rubriques
34 30/08/2005  SY    0805/0142: Essai optimisation remplacement Lectache par FIND (bof)
35 05/10/2005  SY    1005/0055: Pb raz variables gdeTaxeQuittance et gdeTotalQuittance => la rub TVA contenanait le cumul TVA + droit de bail
                     + On ignore la tache Droit de Bail (04036)
36 14/06/2006  SY    0606/0134: On ignore les cttac Droit de Bail qui ne devrait plus exister depuis 2001.
37 19/12/2007  SY    1207/0285: suite fiche 1207/0247 on ne peut pas calculer de la TVA sur rub Hono TTC => famille 04 sfam 02 à exclure du total Qtt
38 19/12/2007  SY    1207/0285: nouveau calcul TVA CDCAL 00006 Total quittance - charges
39 08/12/2008  PL    0408/0032: Hono Loc par le quit.
40 30/11/2009  SY    1108/0397: Quittancement rubriques calculées
*******************   ATTENTION V10.08+ spéciale h:\gi\maj\delta\91126\ixdetail.df (DROP INDEX "ixdet01" ON "detail")
41 18/01/2010  SY    correction perte rub TVA/services annexes suite modif précédente
42 14/04/2010  SY    0410/0084: Demande ALLIANZ : générer les rub TVA loyer à 0
43 18/10/2010  SY    1010/0051: correctif rub tva à 0 pour DAUCHEZ pas de rub TVA si pas de rub soumises à TVA
44 13/01/2012  SY    1111/0177: TVA réduite passe de 5,5% à 7% Nouvelle sous-famille 08 pour fam 04 Admin
45 04/12/2014  SY    1014/0226: Pb no lib rubrique non initialisé suite modifs n-tiers dans prmobtad.p
46 06/02/2017  SY    1011/0158: La rubrique 629 interets sur arrieres n'est pas soumise à TVA
47 08/02/2017  SY    1011/0158: Nlle fonction f_isRubSoumiseTVABail
-----------------------------------------------------------------------------*/
{preprocesseur/codePeriode.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}
&scoped-define NoRub504 504
&scoped-define NoLib504  01

using parametre.syspr.syspr.
using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/rubqt.i}       /* attention, rubqt, pas prrub !!!??? */
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
/* Table des rubriques de services annexes soumis à TVA sur services annexes */
define temp-table ttRubriqueServiceAnnexe no-undo
    field noLoc as integer          /* Locataire      */
    field norub as integer          /* rubrique quitt */
    field nolib as integer          /* no lib rubrique quitt */
    field CdTva as character        /* code taux TVA    */
    field rbTva as integer          /* Rub TVA associ‚e     */
    field lbTva as integer          /* Lib Rub TVA associ‚e     */
    field vlmtq as decimal          /* Montant quittanc‚ rubrique */
    field Mttot as decimal          /* Montant total rubrique */
    index Ix_TbSvc01 is primary unique NoLoc NoRub NoLib
    index Ix_TbSvc02 NoLoc cdtva
.
/* Table des rubriques soumis à TVA */
define temp-table ttRubriqueSoumisTva no-undo
    field noLoc as integer          /* Locataire      */
    field norub as integer          /* rubrique quitt */
    field nolib as integer          /* no lib rubrique quitt */
    field norub-TVA as integer      /* rubrique TVA */
    field nolib-TVA as integer      /* no lib rubrique TVA */
    field vlmtq-TVA as decimal      /* Montant TVA quittanc‚ rubrique */
    field Mttot-TVA as decimal      /* Montant TVA total rubrique */
    index Ix_TbCal01 is primary unique NoLoc NoRub NoLib
.

    define input  parameter pcTypeBail            as character no-undo.
    define input  parameter piNumeroBail          as integer   no-undo.
    define input  parameter pcNatureBail          as character no-undo.
    define input  parameter piNumeroQuittance     as integer   no-undo.
    define input  parameter pdaDebutPeriode       as date      no-undo.
    define input  parameter pdaFinPeriode         as date      no-undo.
    define input  parameter pdaDebutQuittancement as date      no-undo.
    define input  parameter pdaFinQuittancement   as date      no-undo.
    define input  parameter piCodePeriode         as integer   no-undo.
    define input  parameter poCollection           as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.
    define output parameter pcCodeRetour           as character no-undo initial "00".

    define variable goSyspr                       as class syspr no-undo.
    define variable goSyspg                       as class syspg no-undo.
    define variable giMoisModifiable              as integer   no-undo.
    define variable ghProcRubqt                   as handle    no-undo.
    define variable gcRubriqueFiscaliteSpecifique as character no-undo.    /* rubriques calculées avec fiscalité spécifique */
    define variable giNumeroRubriqueTaxe          as integer   no-undo.
    define variable giLibelleRubriqueTaxe         as integer   no-undo.
    define variable gdeTotalQuittance             as decimal   no-undo.
    define variable gdeTaxeQuittance              as decimal   no-undo.
    define variable gdeMontantQuittanceRubrique   as decimal   no-undo.
    define variable giNombreRubrique              as integer   no-undo.
    define variable gdeValeurTaux                 as decimal   no-undo.

    {adb/include/fcttvaru.i}    /* fonctions f_isRubSoumiseTVABail, f_donnerubtva, donneTauxTvaArticleDate, f_donnetauxtvarubqt */
    {bail/include/isTaxCrl.i}   /* {IncCalQt.i}   IsTaxAdd appelle simplement isTaxCRL !!!!   */
    {bail/include/isdrtbai.i}

function lecTauTax returns decimal(pcTypeParametre as character, pcCodeParametre as character):
    /*------------------------------------------------------------------------
    Purpose : fonction de lecture du taux à appliquer
    Notes   :
    ------------------------------------------------------------------------*/
    goSyspr:reload(pcTypeParametre, pcCodeParametre).
    if goSyspr:isDbParameter then return goSyspr:zone1.
    return 0.
end function.

function crettRubriqueSoumisTva returns logical(phttrub as handle):
    /*--------------------------------------------------------------------------
    Purpose : Procedure de création d'une rubrique soumise à TVA du Bail en Table tempo à partir de vbttRub
    Notes   :
    ---------------------------------------------------------------------------*/
    /* Ajout SY le 30/11/2009: sauf rubrique calculée avec régime fiscal spécifique */
    if lookup(string(phttrub::norub, "999") + string(phttrub::nolib, "99"), gcRubriqueFiscaliteSpecifique) = 0
    then do:
        /* Stockage Rubriques pour application tva Bail */
        create ttRubriqueSoumisTva.
        assign
            ttRubriqueSoumisTva.noLoc     = piNumeroBail
            ttRubriqueSoumisTva.norub     = phttrub::norub
            ttRubriqueSoumisTva.nolib     = phttrub::nolib
            ttRubriqueSoumisTva.norub-TVA = giNumeroRubriqueTaxe
            ttRubriqueSoumisTva.nolib-TVA = giLibelleRubriqueTaxe
            ttRubriqueSoumisTva.vlmtq-TVA = round(phttrub::vlmtq * gdeValeurTaux / 100 , 2)   /* total proraté */
            ttRubriqueSoumisTva.mttot-TVA = round(phttrub::mttot * gdeValeurTaux / 100 , 2)   /* total periode */
        .
    end.
end function.

run bail/quittancement/rubqt_crud.p persistent set ghProcRubqt.
run getTokenInstance in ghProcRubqt(mToken:JSessionId).
giMoisModifiable = poCollection:getInteger("GlMoiMdf").     /* GlMoiMdf */
run caltaxqtPrivate.
run destroy in ghProcRubqt.
delete object goSyspr no-error.
delete object goSyspg no-error.

procedure caltaxqtPrivate private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define variable viMoisQuittancement     as integer   no-undo.
    define variable vdeMontantLoyerTaxe     as decimal   no-undo.
    define variable vdeMontantLoyerTotal    as decimal   no-undo.
    define variable vdeMontantChragesTaxe   as decimal   no-undo.
    define variable vdeMontantChargesTotal  as decimal   no-undo.
    define variable vdeQuittanceTaxe        as decimal   no-undo.
    define variable vdeQuittanceTotal       as decimal   no-undo.
    define variable vdeImpotTaxe            as decimal   no-undo.
    define variable vdeImpotTotal           as decimal   no-undo.
    define variable vdeTaxeLoyer            as decimal   no-undo.
    define variable vdeTotalLoyer           as decimal   no-undo.
    define variable vdeTaxe006              as decimal   no-undo.
    define variable vdeTotal006             as decimal   no-undo.
    define variable vcCodeTauxTaxe          as character no-undo.
    define variable vcCodeQuotePart         as character no-undo.
    define variable vcModeCalcul            as character no-undo.
    define variable vcTypeParametre         as character no-undo.
    define variable vdeLoyerDroitBail       as decimal   no-undo.
    define variable vcCodeTypeExoneration   as character no-undo.
    define variable viMoisTraitement        as integer   no-undo.
    define variable viNumeroRubriqueTvaBail as integer   no-undo.    /* Ajout SY le 18/10/2010 */
    define variable vcTableauTva            as character no-undo extent 10 initial "00000".    /* Taux de TVA et rubrique Tva par sous-famille (de la famille 04) */
    define variable viTableauRubrique       as integer   no-undo extent 10.
    define variable viTableauLibelle        as integer   no-undo extent 10.
    define variable viPosition              as integer   no-undo.
    define variable vdeLoyerMinimum         as decimal   no-undo.
    define variable viCompteur              as integer   no-undo.
    define variable vlTaxable               as logical   no-undo.
    define variable vcItem                  as character no-undo.
    define buffer bxrbp  for bxrbp.
    define buffer detail for detail.
    define buffer cttac  for cttac.
    define buffer tache  for tache.

    /* Ajout Sy le 30/11/2009 */
    for each detail no-lock
        where detail.cddet = pcTypeBail
          and detail.nodet = piNumeroBail
          and detail.iddet = integer({&TYPETACHE-quittancementRubCalculees}):
        if detail.ixd03 = {&TYPETACHE-TVABail} or detail.ixd03 = {&TYPETACHE-CRLBail}
        then gcRubriqueFiscaliteSpecifique = gcRubriqueFiscaliteSpecifique + "," + detail.ixd01.
    end.
    assign
        gcRubriqueFiscaliteSpecifique = trim(gcRubriqueFiscaliteSpecifique, ",")
        goSyspg = new syspg()
    .
boucleCttac1:
    /* Suppression de tous les enreg concernant la quittance dans ttRub pour la rubrique taxe */
    for each cttac  no-lock
        where cttac.TpCon = pcTypeBail
          and cttac.NoCon = piNumeroBail:
        if cttac.TpTac = {&TYPETACHE-droit2Bail} then next boucleCttac1. /*** Modif SY le 14/06/2006 : le Droit de Bail n'existe plus depuis 2001. **/

        goSyspg:reloadUnique("O_TAE", cttac.tptac).
        if goSyspg:zone8 = "T@Taxe|" then do:
            /* TVA: mémorisation mode de calcul */
            if cttac.tptac = {&TYPETACHE-TVABail} then do:
                /* Récupération Tâche TVA */
                vcModeCalcul = "".
                for last tache no-lock
                    where tache.tpcon = pcTypeBail
                      and tache.nocon = piNumeroBail
                      and tache.tptac = cttac.tptac:
                    vcModeCalcul = tache.pdges.
                    if vcModeCalcul = ? or vcModeCalcul = "" then vcModeCalcul = {&MODECALCUL-loyer}.    /* Par défaut Calcul sur Loyers. */
                end.
            end.
            /* Tva sur services Divers (pas sur loyer) */
            if cttac.tptac = {&TYPETACHE-TVAServicesAnnexes} then do:
                vcModeCalcul = {&TYPETACHE-TVAServicesAnnexes}.
                /* Chargement des taux de TVA par sous-famille */
                for last tache no-lock
                    where tache.tpCon = pcTypeBail
                      and tache.nocon = piNumeroBail
                      and integer(tache.tptac) = integer(cttac.tptac):
                    do viCompteur = 1 to num-entries(tache.lbdiv, "@"):
                        vcItem = entry(viCompteur, tache.lbdiv, "@").
                        if num-entries(vcItem, "#") >= 5 then assign
                            viPosition                    = integer(entry(4, vcItem, "#"))
                            viTableauRubrique[viPosition] = integer(entry(1, vcItem, "#"))
                            viTableauLibelle[viPosition]  = integer(entry(2, vcItem, "#"))
                            vcTableauTva[viPosition]      = entry(5, vcItem, "#")
                        .
                    end.
                end.
            end.
            for each ttRub
                where ttRub.NoLoc = piNumeroBail
                  and ttRub.NoQtt = piNumeroQuittance
              , first bxrbp no-lock
                where bxrbp.ntbai = pcNatureBail
                  and bxrbp.prg05 = cttac.tptac
                  and Bxrbp.NoRub = ttRub.norub:
                assign
                    gdeMontantQuittanceRubrique = gdeMontantQuittanceRubrique + ttRub.vlmtq
                    giNombreRubrique            = giNombreRubrique + 1
                .
                delete ttRub no-error.
            end.
        end.
    end.
    /* Mise a jour du total de la quittance déduction du total des rubriques supprimées */
    assign
        gdeMontantQuittanceRubrique = - gdeMontantQuittanceRubrique
        giNombreRubrique            = - giNombreRubrique
    .
    /* Si modif, MAJ montant quittance pour la rubrique. */
    if giNombreRubrique <> 0 then run majTmQtt.

    /* Tests des dates de d‚but de quittance et quittancement et des dates de fin de quittance et de quittancement */
    if pdaDebutQuittancement < pdaDebutPeriode or pdaFinQuittancement > pdaFinPeriode or pdaFinPeriode < pdaDebutPeriode
    then do:
        pcCodeRetour = "01".
        return.
    end.
    /* Recherche du mois de quittancement */
    for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance:
        assign
            viMoisQuittancement = ttQtt.MsQui
            viMoisTraitement    = ttQtt.MsQtt
        .
    end.
    assign
        goSyspr         = new syspr("MTEUR", "00001")
        vdeLoyerMinimum = if goSyspr:isDbParameter then goSyspr:zone1 else 0
    .
    /* Ajout SY le 18/01/2010 : stockage rubriques extournables soumises à TVA / services annexes */
    /* perdues depuis modif SY du 01/12/2009 */
    for each ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.cdfam = 04:
        create ttRubriqueServiceAnnexe.
        assign
            ttRubriqueServiceAnnexe.noLoc = piNumeroBail
            ttRubriqueServiceAnnexe.norub = ttRub.norub
            ttRubriqueServiceAnnexe.nolib = ttRub.noLib
            ttRubriqueServiceAnnexe.vlmtq = ttRub.vlmtq    /* total proraté */
            ttRubriqueServiceAnnexe.mttot = ttRub.mttot    /* total periode */
            ttRubriqueServiceAnnexe.CdTva = vcTableauTva[ttRub.cdsfa]
            ttRubriqueServiceAnnexe.rbTva = viTableauRubrique[ttRub.cdsfa]
            ttRubriqueServiceAnnexe.lbTva = viTableauLibelle[ttRub.cdsfa]
        .
    end.
boucle2Cttac:
    /* Recherche des taxes */
    for each cttac no-lock
        where cttac.TpCon = pcTypeBail
          and cttac.NoCon = piNumeroBail:
        goSyspg:reloadUnique("O_TAE", cttac.tptac).
        if goSyspg:zone8 = "T@Taxe|" then do:
            /* Récupération Tâche TAXE */
            assign
                giNumeroRubriqueTaxe  = 0
                giLibelleRubriqueTaxe = 0
            .
            find last tache no-lock
                where tache.tpcon = pcTypeBail
                  and tache.nocon = piNumeroBail
                  and tache.tptac = cttac.tptac no-error.
            if available tache then do:
                assign
                    vcCodeTauxTaxe       = tache.ntges      /* Code Taux de Tva */
                    vcCodeQuotePart      = tache.tpges      /* Taxe Add : Quote part locataire */
                    vcModeCalcul         = tache.pdges      /* Mode de Calcul pour Tƒche T.V.A. */
                    /* Sy 1014/0226 - Pb no lib rubrique non initialisé suite modifs n-tiers*/
                    giNumeroRubriqueTaxe = integer(entry(1, tache.lbdiv, "#")).
                .
                if vcModeCalcul = ? or vcModeCalcul = "" then vcModeCalcul = {&MODECALCUL-loyer}. /* Par défaut Calcul sur Loyers. */
                if num-entries(tache.lbdiv, "#") >= 2 then giLibelleRubriqueTaxe = integer(entry(2, tache.lbdiv, "#")).
                if giNumeroRubriqueTaxe > 0 and giLibelleRubriqueTaxe = 0 then do:
                    if tache.tptac = {&TYPETACHE-TVABail} then giLibelleRubriqueTaxe = 01.
                    if tache.tptac = {&TYPETACHE-CRLBail} then giLibelleRubriqueTaxe = 02.
                end.
                /* Suppression de la rubrique si elle existe */
                for first ttRub
                    where ttRub.noloc = piNumeroBail
                      and ttRub.noqtt = piNumeroQuittance
                      and ttRub.norub = giNumeroRubriqueTaxe
                      and ttRub.nolib = giLibelleRubriqueTaxe:
                    delete ttRub.
                end.
                /* RAZ montants calculés */
                assign
                    gdeTaxeQuittance  = 0
                    gdeTotalQuittance = 0
                .
                empty temp-table ttRubriqueSoumisTva.
                case cttac.tptac:
                    when {&TYPETACHE-TVABail} then do:
                        assign
                            vcTypeParametre = "CDTVA"
                            gdeValeurTaux   = lecTauTax("CDTVA", vcCodeTauxTaxe)
                        .
                        if gdeValeurTaux <> 0 then do:
                            case vcModeCalcul:
                                when {&MODECALCUL-loyer}                 then run calTotLoy(output vdeMontantLoyerTaxe,   output vdeMontantLoyerTotal).    /* Calcul TVA sur rubriques Loyer */
                                when {&MODECALCUL-quittance}             then run calTotQtt(output vdeQuittanceTaxe,      output vdeQuittanceTotal).      /* Calcul somme quittance sauf APL & TVA & services hoteliers & hono TTC */
                                when {&MODECALCUL-loyerEtCharges}        then run calTotLch(output vdeMontantChragesTaxe, output vdeMontantChargesTotal). /* Calcul TVA sur rubriques Loyer  + charges */
                                when {&MODECALCUL-loyerEtChargesEtTaxes} then run calTotImp(output vdeImpotTaxe,          output vdeImpotTotal).      /* Calcul somme loyer + charges +Impots et taxes */
                                when {&MODECALCUL-loyerEtTaxes}          then run calLoyTax(output vdeTaxeLoyer,          output vdeTotalLoyer).      /* Calcul somme loyer + Impots et taxes */
                                when {&MODECALCUL-quittanceEtCharges}    then run calTotQtt-Chg(output vdeTaxe006, output vdeTotal006).       /* Total quittance - charges */
                            end case.
                            /* Création rubrique de TVA du Bail */
                            viNumeroRubriqueTvaBail = 0.
                            for each ttRubriqueSoumisTva where ttRubriqueSoumisTva.noloc = piNumeroBail:
                                assign
                                    gdeTaxeQuittance        = gdeTaxeQuittance + ttRubriqueSoumisTva.vlmtq-TVA
                                    gdeTotalQuittance       = gdeTotalQuittance + ttRubriqueSoumisTva.mttot-TVA
                                    viNumeroRubriqueTvaBail = viNumeroRubriqueTvaBail + 1
                                .
                            end.
                            if viNumeroRubriqueTvaBail > 0 then run creRubTax.          /* Modif SY le 18/10/2010 : rub TVA à 0 si rub soumises à TVA */
                            /* Tache suivante */
                            next boucle2Cttac.
                        end.    /* Taux TVA Bail <> 0 */
                    end.
                    when {&TYPETACHE-droit2Bail} then next boucle2Cttac.  /* SY le 05/10/2005: le Droit de Bail n'existe plus depuis 2001.*/
                    when {&TYPETACHE-CRLBail} then assign
                        vcTypeParametre = "CDTAD"
                        vcModeCalcul    = {&MODECALCUL-loyer} /* Taxe Add : Somme des Loyers. */
                    .
                    when {&TYPETACHE-TVAServicesAnnexes} then do:           /* Tva sur services */
                        assign
                            vcTypeParametre = "CDTVA"
                            vcModeCalcul    = {&TYPETACHE-TVAServicesAnnexes}  /* Somme des rub services annexes */
                        .
                        for each ttRubriqueServiceAnnexe
                            break by ttRubriqueServiceAnnexe.noloc by ttRubriqueServiceAnnexe.cdtva:
                            if first-of(ttRubriqueServiceAnnexe.cdtva) then assign
                                gdeTaxeQuittance      = 0
                                gdeTotalQuittance     = 0
                                vcCodeTauxTaxe        = ttRubriqueServiceAnnexe.cdtva
                                giNumeroRubriqueTaxe  = ttRubriqueServiceAnnexe.rbtva
                                giLibelleRubriqueTaxe = ttRubriqueServiceAnnexe.lbtva
                                gdeValeurTaux         = lecTauTax("CDTVA", vcCodeTauxTaxe)
                            .
                            assign
                                gdeTaxeQuittance  = gdeTaxeQuittance  + round(ttRubriqueServiceAnnexe.vlmtq * gdeValeurTaux / 100, 2)  /* total proraté */
                                gdeTotalQuittance = gdeTotalQuittance + round(ttRubriqueServiceAnnexe.mttot * gdeValeurTaux / 100, 2)  /* total période */
                            .
                            if last-of(ttRubriqueServiceAnnexe.cdtva) and gdeTaxeQuittance <> 0 then run creRubTax. /* Mise à jour de ttRub */
                        end.    /* Boucles sur les différentes TVA sur services annexes */
                        next boucle2Cttac. /* Tache suivante */
                    end.
                end case.

                gdeValeurTaux = lecTauTax(vcTypeParametre, vcCodeTauxTaxe).
                if gdeValeurTaux <> 0 then do:
                    case vcModeCalcul:
                        when {&MODECALCUL-loyer} then do:   /* Calcul CRL : Loyers. */
                            run calTotLoy(output vdeMontantLoyerTaxe, output vdeMontantLoyerTotal).
                            assign
                                gdeTaxeQuittance  = (vdeMontantLoyerTaxe  * gdeValeurTaux) / 100
                                gdeTotalQuittance = (vdeMontantLoyerTotal * gdeValeurTaux) / 100
                            .
                        end.
                    end case.
                    if integer(mToken:cRefPrincipale /* TODO à vérifier la bonne référence !!!NoRefUse*/ ) <> 10
                    and (vcTypeParametre = "TXFIS" or vcTypeParametre = "CDTAD")
                    then do:
                        /* Recherche si locataire Calcul du droit de bail Pour le mois traité
                         ³ 1) Avec le cumul loyer
                         ³ 2) Avec le cumul loyer FIXE */
                        vdeLoyerDroitBail = vdeMontantLoyerTotal / piCodePeriode.
                        run isdrtbai(piNumeroBail, "2", vdeLoyerDroitBail, output vlTaxable, output vcCodeTypeExoneration).
                    end.

                    if vcTypeParametre = "TXFIS" then do:
                        /* NOUVELLE LOI POUR 2001: PLUS DBT */
                        if viMoisTraitement > 200012 then next boucle2Cttac.

                        /* Regul. droit de bail loi finance 1999 */
                        if (giMoisModifiable = viMoisTraitement) then run clRegDbt.
                        if not vlTaxable then next boucle2Cttac.
                    end.
                    /* SC/RT: gestion de la taxe additionnelle - Ne plus tester par rapport au DROIT de BAIL, la TAD est une taxe comme les autres. */
                    if vcTypeParametre = "CDTAD" and vcCodeQuotePart = "00000"
                    then next boucle2Cttac.
                end.

                if gdeTaxeQuittance = 0 then next boucle2Cttac.   /* tache suivante */

                if vcCodeQuotePart > "" then do:
                    goSyspr:reload("CDQPL", vcCodeQuotePart).
                    if goSyspr:zone1 <> 0 then do:
                        /* Teste si l'immeuble a plus de 15 ans. */
                        if vcTypeParametre = "CDTAD" then do:
                            if not isTaxCRL(integer(truncate(piNumeroBail / 100000, 0)), viMoisQuittancement, vdeLoyerDroitBail, vdeLoyerMinimum) then next boucle2Cttac.
                        end.
                        assign
                            gdeTaxeQuittance  = (gdeTaxeQuittance  * goSyspr:zone1) / 100
                            gdeTotalQuittance = (gdeTotalQuittance * goSyspr:zone1) / 100
                        .
                    end.
                    else if vcTypeParametre = "CDTAD" then next boucle2Cttac.
                end.
                run creRubTax.    /* Mise à jour de ttRub */
            end.
        end.
    end.
end procedure.

procedure creRubTax private:
    /*------------------------------------------------------------------------
    Purpose : Procedure de création d'une rubrique taxe dans ttRub
    Notes   :
    ------------------------------------------------------------------------*/
    empty temp-table ttRubqt.
    run readRubqt in ghProcRubqt(giNumeroRubriqueTaxe, giLibelleRubriqueTaxe, table ttRubqt by-reference).
    for first ttRubqt:
        create ttRub.
        assign
            ttRub.NoLoc = piNumeroBail
            ttRub.NoQtt = piNumeroQuittance
            ttRub.CdFam = ttRubqt.cdFam
            ttRub.CdSfa = ttRubqt.cdSfa
            ttRub.NoRub = giNumeroRubriqueTaxe
            ttRub.NoLib = giLibelleRubriqueTaxe
            ttRub.LbRub = outilTraduction:getLibelle(ttRubqt.nome1)
            ttRub.CdGen = ttRubqt.cdgen
            ttRub.CdSig = ttRubqt.cdsig
            ttRub.CdDet = "0"
            ttRub.VlQte = 0
            ttRub.VlPun = 0
            ttRub.MtTot = gdeTotalQuittance
            ttRub.CdPro = 0
            ttRub.VlNum = 0
            ttRub.VlDen = 0
            ttRub.VlMtq = gdeTaxeQuittance
            ttRub.DtDap = pdaDebutQuittancement
            ttRub.DtFap = pdaFinQuittancement
            ttRub.NoLig = 0
            /* Modification du montant de la quittance. Dans ttQtt.mtqtt */
            gdeMontantQuittanceRubrique     = gdeTaxeQuittance
            giNombreRubrique     = 1
        .
        run majTmQtt.
    end.
end procedure.

procedure majTmQtt private:
    /*------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    ------------------------------------------------------------------------*/
    for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance:
        assign
            ttQtt.MtQtt = ttQtt.MtQtt + gdeMontantQuittanceRubrique
            ttQtt.NbRub = ttQtt.NbRub + giNombreRubrique
            ttQtt.CdMaj = 1
        .
    end.
end procedure.

procedure calTotQtt private:
    /*------------------------------------------------------------------------
    Purpose : Procedure qui calcule le total de la quittance
              (sauf APL et TVA et DG et Services soumis à TVA annexe et Assurance locative)
    Notes   :
    Ajout SY le 19/12/2007 : Sauf hono TTC => Fam 04 sfam 02 sauf rub 635 (modif SY le 03/12/2009)
    Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal     as decimal  no-undo.
    define buffer rubqt   for rubqt.
    define buffer vbttRub for ttRub.

    for each vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt = piNumeroQuittance
      , first rubqt no-lock
        where rubqt.cdrub = vbttRub.norub
          and rubqt.cdlib = vbttRub.nolib:
        /* SY 1011/0158 : réécriture du code et mise en include */
        if f_isRubSoumiseTVABail({&MODECALCUL-quittance}, rubqt.cdfam, rubqt.cdsfa, rubqt.cdrub, integer(rubqt.prg05))
        then do:
            crettRubriqueSoumisTva(input buffer vbttRub:handle).
            assign
                pdeMontantQuittance = pdeMontantQuittance + vbttRub.vlmtq
                pdeMontantTotal     = pdeMontantTotal     + vbttRub.mttot
            .
        end.
    end.
    /* Ajout SY le 30/11/2009 : Plus rubriques calculées avec régime fiscal du bail */
    run ajouterRubCal (input-output pdeMontantQuittance, input-output pdeMontantTotal).

end procedure.

procedure calTotQtt-chg private:
    /*--------------------------------------------------------------------------
    Purpose : Procedure qui calcule le total de la quittance SAUF charges (fam 02)
             (sauf APL et TVA et DG et Services soumis à TVA annexe et Assurance locative)
    Notes   :
    Ajout SY le 19/12/2007 : Sauf hono TTC => Fam 04 sfam 02 sauf rub 635 (modif SY le 03/12/2009)
    Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal     as decimal  no-undo.
    define buffer rubqt   for rubqt.
    define buffer vbttRub for ttRub.

    for each vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt = piNumeroQuittance
      , first rubqt no-lock
        where rubqt.cdrub = vbttRub.norub
          and rubqt.cdlib = vbttRub.nolib:
        /* SY 1011/0158 : réécriture du code et mise en include */
        if f_isRubSoumiseTVABail({&MODECALCUL-quittanceEtCharges}, rubqt.cdfam, rubqt.cdsfa, rubqt.cdrub, integer(rubqt.prg05)) then do:
            crettRubriqueSoumisTva(input buffer vbttRub:handle).
            assign
                pdeMontantQuittance = pdeMontantQuittance + vbttRub.vlmtq
                pdeMontantTotal     = pdeMontantTotal     + vbttRub.mttot
            .
        end.
    end.
    /* Ajout SY le 30/11/2009 : Plus rubriques calculées avec régime fiscal du bail */
    run ajouterRubCal(input-output pdeMontantQuittance, input-output pdeMontantTotal).

end procedure.

procedure calTotImp private:
    /*--------------------------------------------------------------------------
    Purpose : Procedure qui calcule le total loyer + Charges + Impots et Taxes (sauf APL et TVA)
    Notes   :
    Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ---------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal     as decimal  no-undo.
    define buffer rubqt   for rubqt.
    define buffer vbttRub for ttRub.

    for each vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt = piNumeroQuittance
      , first rubqt no-lock
        where rubqt.cdrub = vbttRub.norub
          and rubqt.cdlib = vbttRub.nolib:
        /* SY 1011/0158 : réécriture du code et mise en include */
        if f_isRubSoumiseTVABail({&MODECALCUL-loyerEtChargesEtTaxes}, rubqt.cdfam, rubqt.cdsfa, rubqt.cdrub, integer(rubqt.prg05))
        then do:
            crettRubriqueSoumisTva(input buffer vbttRub:handle).
            assign
                pdeMontantQuittance = pdeMontantQuittance + vbttRub.vlmtq
                pdeMontantTotal     = pdeMontantTotal     + vbttRub.mttot
            .
        end.
    end.
    /* Ajout SY le 30/11/2009 : Plus rubriques calculées avec régime fiscal du bail */
    run ajouterRubCal(input-output pdeMontantQuittance, input-output pdeMontantTotal).

end procedure.

procedure calLoyTax private:
    /*--------------------------------------------------------------------------
    Purpose : Procedure qui calcule le total loyer + Impots et Taxes (sauf APL et TVA)
    Notes   :
    Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ---------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal     as decimal  no-undo.
    define buffer rubqt   for rubqt.
    define buffer vbttRub for ttRub.

    for each vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt = piNumeroQuittance
      , first rubqt no-lock
        where rubqt.cdrub = vbttRub.norub
          and rubqt.cdlib = vbttRub.nolib:
        /* SY 1011/0158 : réécriture du code et mise en include */
        if f_isRubSoumiseTVABail({&MODECALCUL-loyerEtTaxes}, rubqt.cdfam, rubqt.cdsfa, rubqt.cdrub, integer(rubqt.prg05))
        then do:
            crettRubriqueSoumisTva(input buffer vbttRub:handle).
            assign
                pdeMontantQuittance = pdeMontantQuittance + vbttRub.vlmtq
                pdeMontantTotal     = pdeMontantTotal     + vbttRub.mttot
            .
        end.
    end.
    /* Ajout SY le 30/11/2009 : Plus rubriques calculées avec régime fiscal du bail */
    run ajouterRubCal(input-output pdeMontantQuittance, input-output pdeMontantTotal).

end procedure.

procedure calTotLoy private:
    /*--------------------------------------------------------------------------
    Purpose : Procedure pour extraire les rubriques loyer uniquement
    Notes   :
    ---------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal     as decimal  no-undo.
    define buffer vbttRub for ttRub.

    for each vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt = piNumeroQuittance
          and vbttRub.cdfam = 01
          and vbttRub.cdsfa <> 04:
        crettRubriqueSoumisTva(input buffer vbttRub:handle).
        assign
            pdeMontantQuittance = pdeMontantQuittance + vbttRub.vlmtq
            pdeMontantTotal     = pdeMontantTotal     + vbttRub.mttot
        .
    end.
    /* Ajout SY le 30/11/2009 : Plus rubriques calculées avec régime fiscal du bail */
    run ajouterRubCal (input-output pdeMontantQuittance, input-output pdeMontantTotal).

end procedure.

procedure calTotLch private:
    /*--------------------------------------------------------------------------
    Purpose : Procedure pour extraire les rubriques loyer et charges
    Notes   :
    ---------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal     as decimal  no-undo.
    define buffer vbttRub for ttRub.

    for each vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt = piNumeroQuittance
          and ((vbttRub.cdfam = 01 and vbttRub.cdsfa <> 04) or vbttRub.cdfam = 02):
        crettRubriqueSoumisTva(input buffer vbttRub:handle).
        assign
            pdeMontantQuittance = pdeMontantQuittance + vbttRub.vlmtq
            pdeMontantTotal     = pdeMontantTotal     + vbttRub.mttot
        .
    end.
    /* Ajout SY le 30/11/2009 : Plus rubriques calculées avec régime fiscal du bail */
    run ajouterRubCal(input-output pdeMontantQuittance, input-output pdeMontantTotal).

end procedure.

procedure ajouterRubCal private:
    /*--------------------------------------------------------------------------
    Purpose : Procedure pour ajouter les rubriques calculées avec régime fiscal du bail
    Notes   :
    ---------------------------------------------------------------------------*/
    define input-output parameter pdeMontantQuittance as decimal  no-undo.
    define input-output parameter pdeMontantTotal     as decimal  no-undo.
    define buffer detail  for detail.
    define buffer vbttRub for ttRub.

boucle:
    for each detail no-lock
        where detail.cddet    = pcTypeBail
          and detail.nodet    = piNumeroBail
          and detail.iddet    = integer({&TYPETACHE-quittancementRubCalculees})
          and detail.tblog[1] = yes
      , first vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt = piNumeroQuittance
          and vbttRub.norub = integer(substring(detail.ixd01, 1, 3, "character"))
          and vbttRub.nolib = integer(substring(detail.ixd01, 4, 2, "character")):
        /* ignorer rubrique faisant déjà partie de l'extraction */
        find first ttRubriqueSoumisTva
            where ttRubriqueSoumisTva.noLoc = piNumeroBail
              and ttRubriqueSoumisTva.norub = vbttRub.norub
              and ttRubriqueSoumisTva.nolib = vbttRub.nolib no-error.
        if available ttRubriqueSoumisTva then next boucle.

        crettRubriqueSoumisTva(input buffer vbttRub:handle).
        assign
            pdeMontantQuittance = pdeMontantQuittance + vbttRub.vlmtq
            pdeMontantTotal     = pdeMontantTotal     + vbttRub.mttot
        .
    end.
end procedure.

procedure clRegDbt private:
    /*--------------------------------------------------------------------------
    Purpose : Procedure calcul de la regul. du droit de bail
    Notes   :
    ---------------------------------------------------------------------------*/
    define variable viMoisTraitement  as integer   no-undo.
    define variable vcCodeTauxTaxe    as character no-undo.
    define variable vdeDroitBailPro   as decimal   no-undo.
    define variable vdeDroitBailTotal as decimal   no-undo.
    define variable vdeLoyerPro       as decimal   no-undo.
    define variable vdeMontantPro     as decimal   no-undo.
    define variable vdeLoyerTotal     as decimal   no-undo.
    define variable vdeTaxeDroitBail  as decimal   no-undo.
    define variable vdeTotalDroitBail as decimal   no-undo.
    define variable vdeTaxeDbt        as decimal   no-undo.
    define variable vdeTotalDbt       as decimal   no-undo.
    define variable vcCodeDroit       as character no-undo.
    define variable viCompteur        as integer   no-undo.
    define variable vdeMontantLoyer   as decimal   no-undo.
    define variable vdeTaux           as decimal   no-undo.
    define variable viNumeroRubrique  as integer   no-undo.
    define variable viItem            as integer   no-undo.
    define variable vlGestion760      as logical   no-undo.
    define variable vlCalculTaxe      as logical   no-undo.
    define variable viLibelle         as integer   no-undo.
    define buffer aquit for aquit.
    define buffer tache for tache.

    /* Tenir compte des avances echus donc prendre le premier quit. en histo. qui commence par 2000 */
    find first aquit no-lock
        where aquit.noloc = piNumeroBail
          and aquit.msqui >= 200000
          and aquit.msqui < 200100 no-error.
    if not available aquit then return.

    assign
        viMoisTraitement = aquit.msqtt
        /* Gérer ou non la rub. 760 dans calcul de CRDB */
        vlGestion760     = not can-find(first pclie no-lock
                                        where pclie.tppar = "GESDB"
                                          and pclie.zon01 = "00002")
    .
    /* Récupération Tâche TAXE */
    find last Tache no-lock
        where tache.tpcon = pcTypeBail
          and tache.nocon = piNumeroBail
          and tache.tptac = {&TYPETACHE-droit2Bail} no-error.  /* todo  vérifier la variable pré-proc ???? */
    if available tache then assign
        vcCodeDroit    = tache.dcreg
        vcCodeTauxTaxe = tache.ntges
    .
    vdeTaux = lecTauTax("TXFIS", vcCodeTauxTaxe).
    /* REGULARISATION DU DROIT DE BAIL: L.F. 1999 Générer du rappel ou avoir CRDB RUB 777 */
    for each aquit no-lock
        where aquit.noloc = piNumeroBail
          and aquit.msqtt >= viMoisTraitement
          and aquit.msqtt <= giMoisModifiable:
        do viCompteur = 1 to aquit.nbrub:
            viItem = integer(entry(1, aquit.tbrub[viCompteur], "|")) no-error.
            if viItem > 0 then do:
                if  integer(entry(12, aquit.tbrub[viCompteur], "|")) = 01
                and integer(entry(13, aquit.Tbrub[viCompteur], "|")) <> 04
                then assign    /* Calcul somme loyer. */
                    vdeMontantPro = vdeMontantPro + decimal(entry(6, aquit.tbrub[viCompteur], "|"))
                    vdeMontantLoyer = vdeMontantLoyer + decimal(entry(5, aquit.tbrub[viCompteur], "|"))
                .
                if viItem = 770 or viItem = 777 or viItem= 750 or (vlGestion760 and viItem = 760)
                then assign
                    vdeDroitBailPro   = vdeDroitBailPro   + decimal(entry(6, aquit.tbrub[viCompteur], "|"))
                    vdeDroitBailTotal = vdeDroitBailTotal + decimal(entry(5, aquit.tbrub[viCompteur], "|"))
                .
            end.
        end.
        assign
            vdeLoyerPro     = vdeLoyerPro   + round((vdeMontantPro   * vdeTaux) / 100, 2)
            vdeLoyerTotal   = vdeLoyerTotal + round((vdeMontantLoyer * vdeTaux) / 100, 2)
            vdeMontantPro   = 0
            vdeMontantLoyer = 0
        .
    end.
    if vcCodeDroit > "" then do:
        if vcCodeDroit = "E"
        then assign
            vdeTaxeDroitBail  = 0
            vdeTotalDroitBail = 0
        .
        else assign             /* calcul droit de bail sur la période depuis janvier 2000 */
            vdeTaxeDroitBail  = vdeLoyerPro
            vdeTotalDroitBail = vdeLoyerTotal
        .
        /* Tester si le droit de bail calcul‚ sur les loyers depuis janvier 2000
            est différent du droit de bail quittancé pour la même période*/
        /* Si Dbt sur loyers < droit de bail cumulé alors avoir */
        if vdeTaxeDroitBail < vdeDroitBailPro
        then assign
            viNumeroRubrique = 777
            viLibelle        = 51
            vlCalculTaxe     = true
            vdeTaxeDbt       = vdeTaxeDroitBail  - vdeDroitBailPro
            vdeTotalDbt      = vdeTotalDroitBail - vdeDroitBailTotal
        .
        else if vdeTaxeDroitBail > vdeDroitBailPro
             then assign
                 viNumeroRubrique = 777
                 viLibelle        = 01
                 vlCalculTaxe     = true
                 vdeTaxeDbt       = vdeTaxeDroitBail  - vdeDroitBailPro
                 vdeTotalDbt      = vdeTotalDroitBail - vdeDroitBailTotal
             .
    end.
    else vlCalculTaxe = false.
    if vlCalculTaxe then do:
        empty temp-table ttRubqt.
        run readRubqt in ghProcRubqt(viNumeroRubrique, viLibelle, table ttRubqt by-reference).
        for first ttRubqt:
            create ttRub.
            assign
                ttRub.NoLoc = piNumeroBail
                ttRub.NoQtt = piNumeroQuittance
                ttRub.CdFam = ttRubqt.cdFam
                ttRub.CdSfa = ttRubqt.cdSfa
                ttRub.NoRub = viNumeroRubrique
                ttRub.NoLib = viLibelle
                ttRub.LbRub = outilTraduction:getLibelle(ttRubqt.nome1)
                ttRub.CdGen = ttRubqt.cdgen
                ttRub.CdSig = ttRubqt.cdsig
                ttRub.CdDet = "0"
                ttRub.VlQte = 0
                ttRub.VlPun = 0
                ttRub.MtTot = vdeTotalDbt
                ttRub.CdPro = 0
                ttRub.VlNum = 0
                ttRub.VlDen = 0
                ttRub.VlMtq = vdeTaxeDbt
                ttRub.DtDap = pdaDebutQuittancement
                ttRub.DtFap = pdaFinQuittancement
                ttRub.NoLig = 0
                /* Modification du montant de la quittance. Dans ttQtt.mtqtt */
                gdeMontantQuittanceRubrique = vdeTaxeDbt
                giNombreRubrique            = 1
            .
            run majTmQtt.
            pcCodeRetour = "00".
        end.
    end.
end procedure.
