/*-----------------------------------------------------------------------------
File        : caldpgar.p
Purpose     : calcul du depot de garantie
Author(s)   : AF - 1999/06/01, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/caldpgar.p
ATTENTION   : toute modification est à reporter en évènementiel dans adb/src/event/calrevis.p
derniere revue: 2018/04/26 - phm: OK

01  07/09/1999  AF   Ajout du mode de calcul 'loyer contractuel' Rubrique 580 genere en prise en charge
02  21/09/1999  AF   suppression d'un message de debug
03  29/10/1999  AF   incrementation correct sur ttQtt.mtqtt & ttQtt.nbrub
04  25/11/1999  AF   generation de la rubrique 580 si solde compta = à 0 si mode de calcul vide alors loyer facturé
05  12/01/2000  AF   Fiche 3331: suppression de la rubrique 580 avant recalcul si on est en DG automatique
06  10/02/2000  AF   Fiche 4147: mauvais find sur ttQtt
07  05/07/2000  AF   fiche 0700/0026: ne rien faire en validation
08  29/11/2001  SY   CREDIT LYONNAIS: les fournisseurs loyer n'existent pas en compta ADB => pas de calcul du DG
09  24/11/2002  AF   Ajout de la rubrique 140 dans le calcul de la base de loyer
10  04/12/2006  SY   1106/0230: nlle règles de gestion de la date du solde au transfert de Quitt
                     ATTENTION: A LIVRER AVEC include DtSolQtt.i
11  25/04/2008  NP   1206/0214: Lot 6 Révision Dépôt de garantie
12  06/05/2008  SY   0107/0373: AGF Lot 6 - Ajout DEBUG (le recalcul dans le passé donne n'importe quoi)
13  16/09/2008  SY   0608/0065: Gestion mandats 5 chiffres détection bail FL par la nature du mandat maitre et non plus les bornes noflodeb
14  09/12/2008  SY   1208/0093: suite 1206/0214 Révision à la baisse il ne faut pas créer une rub à 0
15  03/06/2009  SY   0509/0277: pas de calcul auto DG pour le Pré-bail
16  04/06/2009  SY   0509/0277: calcul auto DG remis pour le Pré-bail mais ne pas rechercher le solde comptable car pas de compta pour le pré-bail => on prend le solde du locataire de même numéro
17  04/06/2009  SY   0609/0189: prise en compte des quittances historisées mais non comptabilisées dans le montant "actuel" du DG
18  04/09/2009  SY   0909/0021 recalcul du montant et nombre réel de rubriques pour maj nbrub / mtqtt
19  09/07/2010  SY   0610/0156: prise en compte des Fact. entrée historisées mais non comptabilisées dans le montant "actuel" du DG
20  15/06/2017  SY   #2641: Pb perte rub complément DG si résiliation du bail (même si résilié dans la période ou futur)
                     NB: il faut appliquer la même règle pour date de sortie et résiliation
21  26/06/2017  SY   #2641: en attendant la réponse officielle, Option appliquée = calcul du DG dans l'Avis Ech de la sortie du locataire
-----------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageRubriqueDepotGarantie.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}

define input  parameter pcTypeBail            as character no-undo.
define input  parameter piNumeroBail          as int64     no-undo.
define input  parameter piNumeroQuittance     as integer   no-undo.
define input  parameter pcCodePeriode         as character no-undo.
define input  parameter pdaDebutQuittancement as date      no-undo.
define input  parameter pdaFinQuittancement   as date      no-undo.
define input  parameter poCollection          as class collection no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour          as character no-undo initial "00".

define variable giMoisEchu       as integer   no-undo.
define variable giMoisModifiable as integer   no-undo.
define variable giMoisQuittance  as integer   no-undo.
define variable gdaSolde         as date      no-undo.
define variable giMoisTraitement as integer   no-undo.
define variable glRubrique580    as logical   no-undo.
define variable gdeSolde580      as decimal   no-undo.
define variable gdeSolde581      as decimal   no-undo.
define variable gcCodeReglement  as character no-undo.
define variable goRubriqueDepotGarantie as class parametrageRubriqueDepotGarantie no-undo.

function isQttCpta returns logical private(piMandat as integer, piSousCompte as integer, piNumeroMandat as integer):
    /*-------------------------------------------------------------------------
    Purpose :
    Notes   :
    -------------------------------------------------------------------------*/
    define variable vdaComptabilisation as date   no-undo.  // todo  date non initialisée !!!! (pas plus dans la version originale.
    define buffer iprd   for iprd.
    define buffer cecrln for cecrln.

    if can-find(first ietab no-lock
                where ietab.soc-cd  = integer(mToken:cRefGerance)   //  todo  NoRefGer remplacé par  mToken:cRefGerance
                  and ietab.etab-cd = piMandat)
    then for first iprd no-lock
        where iprd.soc-cd  = integer(mToken:cRefGerance)   //  todo  NoRefGer remplacé par  mToken:cRefGerance
          and iprd.etab-cd = piMandat
          and iprd.dadebprd <= vdaComptabilisation
          and iprd.dafinprd >= vdaComptabilisation
      , first cecrln no-lock
        where cecrln.soc-cd     = iprd.soc-cd                    // index ecrln-mvt utilisé.
          and cecrln.etab-cd    = iprd.etab-cd                   // index ecrln-mvt utilisé.
          and cecrln.sscoll-cle = "L"                            // index ecrln-mvt utilisé.
          and cecrln.cpt-cd     = string(piSousCompte, "99999")  // index ecrln-mvt utilisé.
          and cecrln.prd-cd     = iprd.prd-cd                    // index ecrln-mvt utilisé.
          and cecrln.prd-num    = iprd.prd-num                   // index ecrln-mvt utilisé.
          and cecrln.jou-cd     = "QUIT"
          and cecrln.TYPE-cle   = "ODQTT"
          and not cecrln.ref-num begins "FL"                 /* quittances std (pas facture locataire) */
          and cecrln.ref-num    = string(piNumeroMandat):    /** N° Quittance **/
        return true.
    end.
    return false.
end function.

goRubriqueDepotGarantie = new parametrageRubriqueDepotGarantie().
if can-find(first ctrat no-lock
    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
      and ctrat.nocon = integer(truncate(piNumeroBail / 100000, 0))
      and ctrat.ntcon = {&NATURECONTRAT-mandatLocation})
or can-find(first ctrat no-lock
    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
      and ctrat.nocon = integer(truncate(piNumeroBail / 100000, 0))
      and ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision})
then return.

assign
    giMoisQuittance  = poCollection:getInteger("GlMoiQtt")
    giMoisModifiable = poCollection:getInteger("GlMoiMdf")
    giMoisEchu       = poCollection:getInteger("GlMoiMec")
.
run caldpgarPrivate.
delete object goRubriqueDepotGarantie.

procedure caldpgarPrivate private:
    /*-------------------------------------------------------------------------
    Purpose :
    Notes   :
    -------------------------------------------------------------------------*/
    define variable vdeAncienDepotGarantie  as decimal  no-undo.
    define variable vdeNouveauDepotGarantie as decimal  no-undo.
    define variable vdeNombreMois           as decimal  no-undo.
    define variable vdaPremierTransfert     as date     no-undo.
    define variable vdaSoldeTransfert       as date     no-undo.
    define variable vlRevisionBaisse        as logical  no-undo.    /* NP 1206/0214 */
    define variable vdaResiliation          as date     no-undo.    /* SY #2641 */
    define buffer ctrat for ctrat.
    define buffer tache for tache.
    define buffer rubqt for rubqt.

    find first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.noqtt = piNumeroQuittance no-error.
    if not available ttQtt then return.

    /* Si on est en phase de validation: date des soldes au 1er transfert */
    /* si avis futurs: solde à début de période, sinon today */
    assign
        gdaSolde         = if today < ttQtt.dtdpr then ttQtt.dtdpr else today
        giMoisTraitement = ttQtt.msqtt
    .
    if ttQtt.msqtt < giMoisEchu
    or (ttQtt.cdter = "00002" and giMoisQuittance <> giMoisEchu)
    or (ttQtt.cdter = "00001" and giMoisQuittance <> giMoisModifiable) then do:
        run DtSolQtt(ttQtt.msqtt, output vdaPremierTransfert, output vdaSoldeTransfert).
        if vdaSoldeTransfert <> ? then gdaSolde = vdaSoldeTransfert.
    end.
    /*--> Suppression de rubriques 582 */
    /* Modif Sy le 04/09/2009: révision à la baisse ou pas : on supprime TOUTES les rub calculées 582 */
    for each ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = 582:
        delete ttRub.
    end.
    run calMntQtt.    /* Ajout SY le 04/09/2009 : recalcul nbrub et mtqtt */
    /*--> Lecture de la tache depot de garantie en reactualisation automatique */
    find first tache no-lock
        where tache.tpcon = pcTypeBail
          and tache.nocon = piNumeroBail
          and tache.tptac = {&TYPETACHE-depotGarantieBail}
          and tache.pdges = "00001" no-error.
    if not available tache then return.

    find first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.noqtt = piNumeroQuittance no-error.
    /*--> Suppression de la rubrique 580 */
    for first rubqt no-lock
        where rubqt.cdrub = 580
          and rubqt.cdlib = 1
      , each ttRub
         where ttRub.noloc = piNumeroBail
           and ttRub.noqtt = piNumeroQuittance
           and ttRub.norub = 580:
         assign
            ttQtt.MtQtt = ttQtt.MtQtt - ttRub.MtTot
            ttQtt.nbrub = ttQtt.nbrub - 1
        .
        delete ttRub.
    end.
    assign
        vlRevisionBaisse = (tache.utreg = "00001")    /* NP 1206/0214 */
        vdeNombreMois    = decimal(tache.tpges)
        gcCodeReglement  = tache.cdreg
    .
    /*--> Recherche de la date de resiliation du contrat et date de sortie */
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeBail
          and ctrat.nocon = piNumeroBail no-error.
    if not available ctrat then return.

    find last tache no-lock
        where tache.tpcon = pcTypeBail
          and tache.nocon = piNumeroBail
          and tache.tptac = {&TYPETACHE-quittancement} no-error.
    if not available tache then return.

    vdaResiliation = ctrat.dtree.
    if tache.dtfin <> ?
    then vdaResiliation = if vdaResiliation = ? then tache.dtfin else minimum(tache.dtfin, vdaResiliation).
    if vdaResiliation <> ?
    /* SY #2641: date de résiliation inférieure à la date de début ou de fin du quitt ? */ /* Question posée à Dina le 16/06/2017, en attente de réponse */
    and vdaResiliation < ttQtt.dtdpr then do:
        mLogger:writeLog(9, substitute("Locataire &1/&2 Sorti depuis le &3 => plus de réactualisation DG pour l'avis echeance du &4 au &5.",
                                       pcTypeBail, piNumeroBail, ctrat.dtree, ttQtt.dtdpr, ttQtt.dtfpr)).
        return.
    end.

    /*--> montant actuel et calculé du depot de garantie  */
    run calMtDpt(vdeNombreMois, output vdeAncienDepotGarantie, output vdeNouveauDepotGarantie).
    /*--> Creation de la rubrique */
    /* Ajout Sy le 09/12/2008 Fiche 1208/0093: il ne faut pas créer une rub à 0 */
    if vdeNouveauDepotGarantie <> vdeAncienDepotGarantie then do:
        if vlRevisionBaisse then do:
            if (glRubrique580 and vdeNouveauDepotGarantie > vdeAncienDepotGarantie)
            or (not glRubrique580) then run creRubDpt(true, vdeAncienDepotGarantie, vdeNouveauDepotGarantie).
        end.
        else if vdeNouveauDepotGarantie > vdeAncienDepotGarantie then run creRubDpt(false, vdeAncienDepotGarantie, vdeNouveauDepotGarantie).
    end.
    /* Ajout SY le 04/09/2009 : recalcul nbrub et mtqtt */
    run calMntQtt.
end procedure.

procedure calMtDpt:
    /*-------------------------------------------------------------------------
    Purpose : Calcul de l'ancien et du nouveau montant de depot de garantie
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter pdeNombreMois   as decimal no-undo.
    define output parameter pdeAncienDepot  as decimal no-undo.
    define output parameter pdeNouveauDepot as decimal no-undo.

    define variable viCompteur          as integer   no-undo.
    define variable vcItem              as character no-undo.
    define variable vcRubrique          as character no-undo.
    define variable viMandat            as integer   no-undo.
    define variable viSousCompte        as integer   no-undo.
    define variable vdeMontantDepot     as decimal   no-undo.
    define variable vdeMontantProvision as decimal   no-undo.
    define variable vdeNonComptabilise  as decimal   no-undo.
    define variable vdeMontantLoyer     as decimal   no-undo.
    define buffer tache  for tache.
    define buffer aquit  for aquit.
    define buffer iftsai for iftsai.

    /* Ajout Sy le 04/06/2009 */
    if pcTypeBail = {&TYPECONTRAT-bail} then do:
        assign
            viMandat     = truncate(piNumeroBail / 100000, 0)   // substring(string(piNumeroBail,"9999999999"),1,5)
            viSousCompte = piNumeroBail modulo 100000           // substring(string(piNumeroBail,"9999999999"),6,5))
        .
        /*--> DG conserve au cabinet */
        run lecSolCpt(viMandat, 2751, viSousCompte, gdaSolde, output vdeMontantDepot).
        /*--> DG reverse au proprietaire */
        run lecSolCpt(viMandat, 2752, viSousCompte, gdaSolde, output vdeMontantProvision).
        /* Si quittance émise à l'avance mais non comptabilisée: rubriques DG */
        for each aquit no-lock
            where aquit.noloc = piNumeroBail
              and aquit.msqtt >= giMoisModifiable
              and aquit.msqtt < giMoisTraitement
              and aquit.fgfac = no:    /* quittances std (pas facture locataire) */
            if not isQttCpta(viMandat, viSousCompte, aquit.noqtt)
            then
boucleRubrique1:
            do viCompteur = 1 to 20:                /* Cumul rub DG */
                vcItem = aquit.tbrub[viCompteur].
                if num-entries(vcItem, "|") < 13 then next boucleRubrique1.

                vcRubrique = entry(1, vcItem, "|").
                if integer(vcRubrique) = 0 then leave boucleRubrique1.

                if vcRubrique >= "580" and vcRubrique <= "582"
                then vdeNonComptabilise = vdeNonComptabilise + decimal(entry(6, vcItem, "|")).
            end.
        end.
        /* Ajout SY le 09/07/2010 : Si facture d'entrée non encore comptabilisée : rubriques DG */
        for each aquit no-lock
            where aquit.noloc    = piNumeroBail
              and aquit.fgfac    = yes
              and aquit.type-fac = "E"
              and aquit.num-int-fac > 0
          , first iftsai no-lock                                                  /* Recherche de la Facture en compta */
             where iftsai.soc-cd    = integer(mToken:cRefGerance)                 //  todo  NoRefGer remplacé par  mToken:cRefGerance
               and iftsai.etab-cd   = integer(truncate(aquit.noloc / 100000, 0))  // substring(string(aquit.noloc, "9999999999"), 1 , 5))
               and iftsai.tprole    = 19
               and iftsai.sscptg-cd = string(aquit.noloc modulo 100000, "99999")  // substring(string(aquit.noloc, "9999999999"), 6 , 5)
               and iftsai.num-int   = aquit.num-int-fac
               and iftsai.dacompta  = ?:
            /* Cumul rub DG */
boucleRubrique2:
            do viCompteur = 1 to 20:
                vcItem = aquit.tbrub[viCompteur].
                if num-entries(vcItem, "|") < 13 then next boucleRubrique2.

                vcRubrique = entry(1, vcItem, "|").
                if integer(vcRubrique) = 0 then leave boucleRubrique2.

                if vcRubrique >= "580" and vcRubrique <= "582"
                then vdeNonComptabilise = vdeNonComptabilise + decimal(entry(6, vcItem, "|")).
            end.
        end.
    end.

    glRubrique580 = (vdeMontantDepot + vdeMontantProvision - vdeNonComptabilise = 0).
    /*--> Rub 580 du locataire */
    for each ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = 580:
        gdeSolde580 = gdeSolde580 + ttRub.MtTot.
    end.
    /*--> Rub 581 du locataire */
    for each ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.cdfam = 3
          and ttRub.cdsfa = 3
          and ttRub.norub = 581:
        gdeSolde581 = gdeSolde581 + ttRub.MtTot.
    end.
    /*--> Ancien Montant de depot de garantie */
    pdeAncienDepot = vdeNonComptabilise + gdeSolde580 + gdeSolde581 - vdeMontantDepot - vdeMontantProvision.
    if gcCodeReglement = "00001" or gcCodeReglement = ? or gcCodeReglement = "" then do:
        if goRubriqueDepotGarantie:isDbParameter
        then for each ttRub            /*--> Mode de Calcul 'Loyer facturé' en tenant des rubriques saisies par le client */
            where ttRub.noloc = piNumeroBail
              and ttRub.noqtt = piNumeroQuittance
              and lookup(string(ttRub.norub), goRubriqueDepotGarantie:getListeRubrique(), ";") > 0:
            vdeMontantLoyer = vdeMontantLoyer + ttRub.MtTot.
        end.
        else for each ttRub             /*--> Mode de Calcul 'Loyer facturé' */
            where ttRub.noloc = piNumeroBail
              and ttRub.noqtt = piNumeroQuittance
              and (ttRub.norub = 101 or ttRub.NoRub = 140):
            vdeMontantLoyer = vdeMontantLoyer + ttRub.MtTot.
        end.
        /*--> Nouveau Montant de depot de garantie */
        pdeNouveauDepot = round((vdeMontantLoyer / integer(pcCodePeriode)) * pdeNombreMois, 2).
    end.
    else for first tache no-lock             /*--> Mode de calcul 'loyer contractuel' */
        where tache.tptac = {&TYPETACHE-loyerContractuel}
          and tache.tpcon = pcTypeBail
          and tache.nocon = piNumeroBail:
        pdeNouveauDepot = round((tache.mtreg / 12) * pdeNombreMois, 2).
    end.
end procedure.

procedure creRubDpt:
    /*-------------------------------------------------------------------------
    Purpose : Creation de la rubrique calculée 582
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter plRevisionBaisse as logical no-undo.
    define input  parameter pdeAncienDepotGarantie as decimal no-undo.
    define input  parameter pdeNouveauDepotGarantie as decimal no-undo.
    define buffer rubqt for rubqt.

    mLogger:writeLog(9, substitute("caldpgar.p - creRubDpt - Locataire &1 Mois de quitt = &2 gdaSolde = &3 Creation rub DG &4",
                                   ttQtt.noloc, ttQtt.msqtt, gdaSolde, pdeNouveauDepotGarantie - pdeAncienDepotGarantie)).
    if not plRevisionBaisse
    then find first rubqt no-lock
        where rubqt.cdrub = (if glRubrique580 and gdeSolde580 = 0 then 580 else 582)
          and rubqt.cdlib = 1 no-error.
    else if glRubrique580 and gdeSolde580 = 0
         then find first rubqt no-lock
             where rubqt.cdrub = 580
               and rubqt.cdlib = 1 no-error.
         else if not glRubrique580
              then if pdeNouveauDepotGarantie - pdeAncienDepotGarantie > 0
                   then find first rubqt no-lock
                       where rubqt.cdrub = 582
                         and rubqt.cdlib = 1 no-error.
                   else if pdeNouveauDepotGarantie - pdeAncienDepotGarantie < 0
                        then find first rubqt no-lock
                            where rubqt.cdrub = 582
                              and rubqt.cdlib = 51 no-error.
    if available rubqt
    then for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.noqtt = piNumeroQuittance:
        create ttRub.
        assign
            ttRub.NoLoc = piNumeroBail
            ttRub.NoQtt = piNumeroQuittance
            ttRub.CdFam = rubqt.cdfam
            ttRub.CdSfa = rubqt.cdsfa
            ttRub.NoRub = rubqt.cdrub
            ttRub.NoLib = rubqt.cdlib
            ttRub.CdGen = rubqt.cdgen
            ttRub.CdSig = rubqt.cdsig
            ttRub.CdDet = "0"
            ttRub.VlQte = 0
            ttRub.VlPun = 0
            ttRub.MtTot = pdeNouveauDepotGarantie - pdeAncienDepotGarantie
            ttRub.CdPro = 0
            ttRub.VlNum = 0
            ttRub.VlDen = 0
            ttRub.VlMtq = pdeNouveauDepotGarantie - pdeAncienDepotGarantie
            ttRub.DtDap = pdaDebutQuittancement
            ttRub.DtFap = pdaFinQuittancement
            ttRub.NoLig = 0
            ttQtt.MtQtt = ttQtt.MtQtt + ttRub.MtTot
            ttQtt.nbrub = ttQtt.nbrub + 1
            ttRub.LbRub = outilTraduction:getLibelle(rubqt.nome1)
        .
    end.
end procedure.

procedure calMntQtt:
    /*-------------------------------------------------------------------------
    Purpose :
    Notes   :
    -------------------------------------------------------------------------*/
    define variable vdeMontant as decimal no-undo.
    define variable viNombre   as integer no-undo.

    for each ttRub
        where ttRub.NoLoc = piNumeroBail
         and ttRub.NoQtt  = piNumeroQuittance:
        assign
            vdeMontant = truncate(round(vdeMontant + ttRub.VlMtQ, 2), 2)
            viNombre = viNombre + 1
        .
    end.
    /*--> Mise a Jour du Montant Total de la Quittance et nombre de rubriques */
    for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance:
        assign
            ttQtt.MtQtt = vdeMontant
            ttQtt.nbrub = viNombre
        .
    end.
end procedure.

procedure dtSolQtt:
    /*-------------------------------------------------------------------------
    Purpose : Recherche de la date de transfert du 1er transfert d'un mois de quitt et date du solde (arreté des comptes) associée
    Notes   : vient de adb/comm/DtSolQtt.i
              Nouvelles règles de gestion:
                  Date du solde pour le 1er transfert de quitt
                  = TODAY si date du jour < 1er jour du mois de quitt
                  = dernier jour du mois précédent du quitt (nouveau)
    -------------------------------------------------------------------------*/
    define input  parameter piMoisTraitement    as integer  no-undo.
    define output parameter pdaPremierTransfert as date     no-undo.
    define output parameter pdaSolde            as date     no-undo.

    define variable vdaDebutPeriode as date    no-undo.
    define variable viMois          as integer no-undo.
    define variable viAnnee         as integer no-undo.
    define buffer svtrf for svtrf.

    assign
        viAnnee         = integer(truncate(piMoisTraitement / 100, 0))  // substring(string(piMoisTraitement, "999999"), 1, 4))
        viMois          = piMoisTraitement modulo 100                   // substring(string(piMoisTraitement, "999999"), 5, 2))
        vdaDebutPeriode = date( viMois, 01 , viAnnee)
    .
    for first svtrf no-lock
        where svtrf.CdTrt = "QUIT"
          and svtrf.MsTrt = piMoisTraitement
          and svtrf.Noord > 0
          and svtrf.NoPha = "N00":
        assign
            pdaPremierTransfert = svtrf.Dttrf
            pdaSolde            = if pdaPremierTransfert < vdaDebutPeriode then pdaPremierTransfert else (vdaDebutPeriode - 1)
        .
    end.
end procedure.

procedure lecSolCpt:
    /*-------------------------------------------------------------------------
    Purpose : TODO quoi prendre? revoir solcpt.p, soldeCompte.p et calculeSolde.p
    Notes   : vient de adb/comm/incliadb.i, procedure LecSolCpt.
    -------------------------------------------------------------------------*/
    define input  parameter piMandat        as integer  no-undo.
    define input  parameter piCompte        as integer  no-undo.
    define input  parameter piSousCompte    as integer  no-undo.
    define input  parameter pdaSolde        as date     no-undo.
    define output parameter pdeMontantSolde as decimal  no-undo.

    define variable vcEntree    as character    no-undo.
    define variable vcSortie    as character    no-undo.

    vcEntree = substitute("&1|&2|&3|&4|S|&5|||",
                          mToken:cRefPrincipale,      // todo  vérifier  NoRefUse emplacé par mToken:cRefPrincipale
                          // todo  solcpt.p   attend un gicodeEtab en deuxième paramètre !!!!!!!
                          // todo  adb/src/envt/solcpt.p, pas de gicodeEtab, mais je ne vois pas comment ça marche !!!!
                          piMandat,
                          string(piCompte, "9999"),
                          string(piSousCompte, "99999"),
                          pdaSolde)
    .
    run compta/souspgm/solcpt.p(vcEntree, output vcSortie).
    pdeMontantSolde = decimal(entry(1, vcSortie, '|')) / 100.
end procedure.
