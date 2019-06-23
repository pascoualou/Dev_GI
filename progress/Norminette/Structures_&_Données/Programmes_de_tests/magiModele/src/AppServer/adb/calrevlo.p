/*-----------------------------------------------------------------------------
File        : calrevlo.p
Purpose     : calcul des révisions loyer selon les indices.
Author(s)   : RT - 1997/03/11, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calrevlo.p
              ATTENTION CE PROGRAMME A ETE DUPLIQUE DANS ADB/SRC/EVENT
              => TOUTE MODIFICATION EST A DUPLIQUER DANS ADB/SRC/EVENT/CALREVLO.P
derniere revue: 2018/04/26 - phm: OK    reste un todo de traduction

01  22/04/1997  RT     Le calcul ne se fait que ssi taux année indice + période existe, mois traité <= mois quittance (GlMoiQtt)
02  28/04/1997  RT     Modification assignation DtMoiQtt
03  05/05/1997  RT     Si révision création des enregistrements dans Equit pour les quittances futures.
04  25/06/1997  RT     MajLocRb met à jour 1 seule rubrique.
05  01/07/1997  RT     Révision = rubrique 105. On ne teste plus si le locataire est révisabl non révisé (tache) mais sur date de révision
06  04/09/1997  RT     RecTauRev : modif recherche du taux
07  10/10/1997  LG     fiche 1210: cdrev = "00002" qd revise et "00001" qd revisable mais non revise.
08  16/06/1998  SY     Modification test sur date de fin de Bail pour tenir compte de la Tacite reconduction + remplacement Lecctrat par FIND direct
09  13/07/1998  SY     Fiche 1365: Gestion des révisions pour les Baux Méhaignerie
10  08/09/1998  LG/SC  Fiche 1781: Correction Pb sur Dt de Bail : Le fait de ne pas pouvoir réviser un locataire ne provoquait pas la mise à jour de EQUIT...
11  13/11/1998  JC     Si le module recanmeh renvoie 0 dans le numero de progression, on ne fait rien derriere
12  30/05/1999  AF     Mise en place de revision * la baisse et pourcentage de variation de l'indice
13  27/07/1999  AF     Date réelle de revision = date du jour
14  24/08/1999  SY     Correction no libellé rub rappel révision MEH
15  08/09/1999  AF     ajout de la revision du loyer contractuel
16  22/09/1999  LG     Dans trtrevrub, tester par rapport à la date de début et de fin de période au lieu des dates de quittancement.(calcul de l'avoir/rappel)
17  21/07/2000  PL     Gestion Double affichage Euro/Devise.
18  20/09/2000  AF     900/403 ne pas mettre * zero * chq rub loyer les champs cumul rappel et avoir dans TrtRevRub
19  16/10/2000  SY     Correction formatage indice courant dans tache.lbdiv (on formatait tjs en trimestriel)
20  19/01/2001  SY     Fiche 0101/0133: Revisions MEH/Mermaz
                       1) Remise RAZ cumul rappel/avoir avant de traiter les revisions MEH
                       2) Sauter les rub 111 dans la 1ère boucle (sinon révisée 2 fois !)
21  03/05/2001  SY     Fiche 1200/1353: Gauriau...
                       Gestion du début de majoration meh à une date différente du 1er du mois avec présentation calculs sur 2 rubriques
                       111.xx: palier de l'année
                       114.xx: Avoir (ou rappel ?) chgt palier
22  17/10/2001  AF     Gestion des revisions lors d'une procedure de renouvellement
23  24/10/2001  AF     Flag du bail si Revision pour transfert des MAJ
24  03/12/2001  SY     CREDIT LYONNAIS: les fournisseurs loyer ont leur mois de qtt & mois modifiable différent de celui des locataires (GlMflQtt & GlMflMdf)
25  03/12/2001  SY     Si le montant d'une rubrique change après révision alors sa date de début d'application doit changer aussi
26  19/05/2003  SY     Fiche 0503/0161: AGF - Correction pb tache MEH non révisée si chgt palier en cours de période (Rub 114) ET révision dans la mˆme quittance.
27  22/05/2003  SY     Ajout stockage mois de quitt de la quittance dans laquelle a eu lieu la derniŠre révision
28  03/07/2003  SY     Fiche 0603/0307: correction révision MEH - On ne doit pas réviser les paliers inférieurs à la date de révision
29  01/12/2003  SY     Fiche 1003/0035: Ajout maj ttQtt.dtprv avec la date du jour du traitement de la révision (tache.dtreg)
30  16/01/2004  SY     Fiche 0104/0139: correction calcul du loyer stocké dans la tache revision. il ne faut cumuler que les rub loyer FIXES
31  05/02/2004  SY     Fiche 0104/0289: correction révision MEH - On révisait toujours le dernier palier sans tenir compte de la fin de MEH
32  11/02/2004  PL     Fiche 0204/0195: pb pas rub 105 si dtrev le dernier jour du mois (AGF).
33  06/05/2004  SY     0103/0210: EUROSTUDIOMES - Ajout révision tache garantie locative (04263) lors de la révision des baux FL
34  07/05/2004  AF     0404/0298: On test la revision * la baisse non plus sur le montant de la revision mais sur le taux
35  22/09/2004  SY     0904/0215: Ajout revision fam 04 sfa 06 (redevance soumise à TVA EUROSTUDIOMES)
36  24/09/2004  SY     0904/0257: correction non repercussion révision rub 652 si pas de rub 101 ou 200
                       ATTENTION: A LIVRER AVEC revgarlo.i formamnt.i et src/event/calrevlo.p
37  18/01/2006  SY     1205/0605: correction calcul du loyer stocké dans la tache revision. Le palier MEH (rub 111) est à prendre aussi
                       + pas d'application des arrondis pour MEH (modif faite sur mttot dans event/calrevlo.p)
38  12/12/2006  SY     0905/0335: plusieurs libellés autorisés pour les rubriques loyer si param RUBML
                       ATTENTION: nouveaux param entrée/sortie pour majlocrb.p
39  18/10/2007  NP     1007/0022 Remplacement NoRefUse par NoRefGer
40  08/11/2007  SY     0607/0148: correction calcul date prochaine révision (addmoidat et non Cl2Datfin) pour conserver le jour (pb 28/02)
41  01/10/2009  SY     0909/0232 correction suite modif mandats 5 ch. include <revgarlo.i>
42  21/05/2010  SY     Révision à la baisse = NON pas gérée pour la révision de la tache Garantie Locative des mandats Location (Icade)
                       + Init variables revision dans lectacrev A LIVRER AVEC revgarlo.i
43  29/10/2010  SY     0908/0110 Révisions légale + conventionnelle création ligne de traitement dans revtrt lors d'une révision + conservation motif
44  06/04/2011  SY     Anticipation sur fiche 1108/0399 Stockage equit AVANT révision
45  02/08/2013  PL     0713/0076:libellé rappel/avoir révision pas le bon sur rub 101.
46  17/09/2014  SY     0714/0326 Correction utilisation paramètre
                       REVBA: si pas ouvert alors ne pas prendre l'option indexation à la baisse de la tache révision
47  28/11/2017  SY     #9211 ajout NO-LOCK et DO TRANS
-----------------------------------------------------------------------------*/

{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
using parametre.pclie.parametrageTypeArrondi.
using parametre.pclie.parametrageRevisionBail.
using parametre.pclie.parametrageProlongationExpiration.
using parametre.pclie.parametrageCategorieBail.
using parametre.pclie.parametrageCategorieBail1.
using parametre.pclie.parametrageRenouvellement.
using parametre.pclie.parametrageRenouvellement1.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tache.i}
{bail/include/rubqt.i}       /* attention, rubqt, pas prrub !!!??? */
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
{bail/include/tmprub.i &nomTable=ttRub2}
{application/include/glbsepar.i}
{bail/include/equitrev.i}     /* procedure SavEquitrev        */
{adb/include/formamnt.i}      /* fonction  PrcForMnt          */

define input  parameter pcTypeBail            as character no-undo.
define input  parameter piNumeroBail          as integer   no-undo.
define input  parameter piNumeroQuittance     as integer   no-undo.
define input  parameter pdaDebutPeriode       as date      no-undo.
define input  parameter pdaFinPeriode         as date      no-undo.
define input  parameter pdaDebutQuittancement as date      no-undo.
define input  parameter pdaFinQuittancement   as date      no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour          as character no-undo initial "00".

define variable glBaisseAutorisee    as logical no-undo.
define variable gdaDateRevision      as date    no-undo.
define variable giNombrePouRevision  as integer no-undo.
define variable gdeValeurRevision    as decimal no-undo.
define variable gdeTauxRevision      as decimal no-undo.
define variable gdeNvoLoyer          as decimal no-undo.
define variable giMoisTraitement     as integer no-undo.
define variable giNumeroLibRappel    as integer no-undo.
define variable gdeMontantNonRevise  as decimal no-undo.
define variable gdeMontantProrata    as decimal no-undo.
define variable ghProcRubqt          as handle  no-undo.
define variable ghProcTache          as handle  no-undo.
define variable ghProcAlimaj         as handle  no-undo.
define variable ghProcIndiceRevision as handle  no-undo.
define variable goTypeArrondi            as class parametrageTypeArrondi            no-undo.
define variable goRevisionBail           as class parametrageRevisionBail           no-undo.
define variable goProlongationExpiration as class parametrageProlongationExpiration no-undo.
define variable goCategorieBail          as class parametrageCategorieBail          no-undo.
define variable goCategorieBailUn        as class parametrageCategorieBail1         no-undo.
define variable goRenouvellement         as class parametrageRenouvellement         no-undo.
define variable goRenouvellement1        as class parametrageRenouvellement1        no-undo.

function lecTacRev returns logical private():
    /*----------------------------------------------------------------------------
    Purpose : lecture de la tache révision loyer.
    Notes   :
    ----------------------------------------------------------------------------*/
    define variable vcTemp as character no-undo.

    empty temp-table ttTache.
    run getTache in ghProcTache(pcTypeBail, piNumeroBail, {&TYPETACHE-revision}, table ttTache by-reference).
    find first ttTache no-error.
    if not available ttTache then return true.

    /* Par défaut toutes les révisions autorisées pour le bail */
    assign
        glBaisseAutorisee   = true
        vcTemp              = if num-entries(ttTache.lbdiv, "&") > 2 then entry(3, ttTache.lbdiv, "&") else ""
        giNombrePouRevision = if num-entries(vcTemp, "#") > 1 then integer(entry(2, vcTemp, "#")) else 100
    .
    /* modif SY le 17/09/2014 : n'utiliser l'option de la tâche révision QUE si le paramètre Cabinet le permet */
    if goRevisionBail:isActif()
    then glBaisseAutorisee = (entry(1, vcTemp, "#") <> "00002").
    mLogger:writeLog(9,
                     substitute("LecTacRev: Contrat &1 &2 Noqtt = &3 lbdiv = &4 REVBA = &5 glBaisseAutorisee = &6 giNombrePouRevision = &7",
                                pcTypeBail, piNumeroBail, piNumeroQuittance, ttTache.lbdiv, goRevisionBail:isActif(), glBaisseAutorisee, giNombrePouRevision)).
    return false.
end function.

function recDatBai returns logical private(output pcNatureContrat as character, output piNumeroDoc as integer):
    /*----------------------------------------------------------------------------
    Purpose : recherche date fin bail ou date résiliation contrat.
    Notes   :
    ----------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeBail
          and ctrat.nocon = piNumeroBail:
        assign
            pcNatureContrat = ctrat.ntcon
            piNumeroDoc     = ctrat.nodoc
        .
        /*--> Date de resiliation du contrat bail. */
        if ctrat.dtree <> ? and ctrat.dtree < ttTache.dtfin then return true. /* pas de revision */

        if ctrat.TpRen <> "00001"                                  /* Si pas Tacite reconduction: tester Expiration */
        and not goProlongationExpiration:isQuittancementProlonge() /* Uniquement si module prolongation apres expiration non ouvert */
        and ctrat.dtfin < ttTache.dtfin
        then return true.                                          /* pas de revision */
        return false.
    end.
    return true. /* pas de revision */
end function.

run bail/quittancement/rubqt_crud.p persistent set ghProcRubqt.
run getTokenInstance in ghProcRubqt(mToken:JSessionId).
run tache/tache.p persistent set ghProcTache.
run getTokenInstance in ghProcTache(mToken:JSessionId).
run application/transfert/gi_alimaj.p persistent set ghProcAlimaj.
run getTokenInstance in ghProcAlimaj(mToken:JSessionId).
run adblib/indiceRevision_CRUD.p persistent set ghProcIndiceRevision.
run getTokenInstance in ghProcIndiceRevision(mToken:JSessionId).
assign
    goTypeArrondi            = new parametrageTypeArrondi()
    goRevisionBail           = new parametrageRevisionBail()
    goProlongationExpiration = new parametrageProlongationExpiration()
    goCategorieBail          = new parametrageCategorieBail()
    goRenouvellement         = new parametrageRenouvellement()
.
run calrevloPrivate.
run destroy in ghProcRubqt.
run destroy in ghProcAlimaj.
run destroy in ghProcTache.
run destroy in ghProcIndiceRevision.
delete object goTypeArrondi            no-error.
delete object goRevisionBail           no-error.
delete object goCategorieBail          no-error.
delete object goCategorieBailUn        no-error.
delete object goProlongationExpiration no-error.
delete object goRenouvellement         no-error.
delete object goRenouvellement1        no-error.

procedure calrevloPrivate private:
    /*----------------------------------------------------------------------------
    Purpose : Procedure de lecture de la tache révision loyer.
    Notes   :
    ----------------------------------------------------------------------------*/
    define variable vcNatureContrat   as character no-undo.
    define variable viNumeroDocument  as integer   no-undo.
    define variable vdeLoyerGaranti   as decimal   no-undo.
    define variable viNombreRubrique  as integer   no-undo.
    define variable vlRetour          as logical   no-undo.
    define variable vdaFinMehaignerie as date      no-undo.
    define variable viDuree           as integer   no-undo.
    define variable vdeMontantRealise as decimal   no-undo.
    define variable vcListePalier     as character no-undo.
    define variable vcTypeRevision    as character no-undo.
    define variable viPeriodeIndice   as integer   no-undo.
    define variable vcRetour          as character no-undo.
    define variable vcParametre       as character no-undo.
    define buffer bxrbp for bxrbp.

    if lecTacRev()                                                              /* Lecture de la tâche révision loyer */
    or recDatBai(output vcNatureContrat, output viNumeroDocument) then return.  /* Recherche de la date de fin du contrat bail ou date de résiliation du contrat. */

    run recPrcRen(vcNatureContrat, output vcTypeRevision).                      /* Revision lors d'une procedure de renouvellement */
    /*--> Si Revision gelée on ne fait pas la révision */
    if vcTypeRevision = "00002" then return.

    run recTauRev.  /* Recuperation du taux de revision. */
    /*--> Si révision bloquée tx de révision * 0 */
    if vcTypeRevision = "00001" then gdeTauxRevision = 0.
    /* Sauvegarde equit Avant révision 1108/0399 */
    run savEquitrev(piNumeroBail, piNumeroQuittance, ttTache.dtfin, integer(ttTache.dcreg), integer(ttTache.cdreg) + ttTache.duree, integer(ttTache.ntreg), gdeValeurRevision, gdeTauxRevision).
    run calPrcDat.                     /* Calcul de la date de révision. */
    run calRevLoy(gdeTauxRevision).    /* Revision du loyer contractuel */
    /* Suppression de tous les enreg concernant la quittance dans ttRub pour la rubrique 105 Rappel ou avoir révision loyer */
    for each ttRub
        where ttRub.NoLoc = piNumeroBail
          and ttRub.NoQtt = piNumeroQuittance
          and ttRub.NoRub = 105:
        delete ttRub no-error.
    end.
    /* Suppression de tous les enreg concernant la quittance dans ttRub pour la rubrique 118 Rappel ou avoir révision majoration loyer(MEH) */
    for each ttRub
        where ttRub.NoLoc = piNumeroBail
          and ttRub.NoQtt = piNumeroQuittance
          and ttRub.NoRub = 118:
        delete ttRub no-error.
    end.
    /* Suppression de la rubrique de revision 642 Rappel ou avoir redevance soumise TVA révisée */
    for each ttRub
        where ttRub.NoLoc = piNumeroBail
          and ttRub.NoQtt = piNumeroQuittance
          and ttRub.NoRub = 642:
        delete ttRub no-error.
    end.
    /* ATTENTION: reporter les modifications sur les programmes utilisant rubqt.prg02 ou bxrbp.prg02 : calrevlo.p, RvNxQt00.p, ExtRubQu.p, rqgen006.p, GenQtRenxxx.p, visrebau.p... */
    /* Calcul de la révision pour la quittance en cours et les suivantes. */
    find first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance no-error.
    if available ttQtt then do:
        for each ttRub
            where ttRub.NoLoc = ttQtt.NoLoc
              and ttRub.NoQtt = ttQtt.NoQtt
              and ttRub.NoRub <> 111
              and ttRub.NoRub <> 114:
            find first bxrbp no-lock
                where bxrbp.ntbai = ttQtt.ntbai
                  and bxrbp.norub = ttRub.norub
                  and bxrbp.nolib = ttRub.nolib no-error.
            if available bxrbp
                and bxrbp.cdfam < 2
                and bxrbp.prg02 = "00001" then run TrtRevRub.  /* Traitement de révision de la rubrique */
        end.
        /* Récupération Infos Méhaignerie */
        run lecTacMeh(output vdaFinMehaignerie, output viDuree, output vdeMontantRealise, output vcListePalier, output vlRetour).
        if vlRetour then do:
            assign
                gdeMontantProrata = 0
                gdeMontantNonRevise = 0
                giNumeroLibRappel = 01
            .
            for each ttRub
                where ttRub.NoLoc = ttQtt.NoLoc
                  and ttRub.NoQtt = ttQtt.NoQtt
                  and (ttRub.NoRub = 111 or ttRub.NoRub = 114)
                by ttRub.norub:
                if ttRub.norub = 111 then giNumeroLibRappel = ttRub.nolib.
                run TrtRevRub.           /* Traitement de révision de la rubrique */
            end.
            run majTabMeh(vdaFinMehaignerie, viDuree, vdeMontantRealise).
        end.
        /* Revision des redevances soumise à TVA Fam 04 - Sous Fam 06 */
        assign
            gdeMontantProrata = 0
            gdeMontantNonRevise = 0
        .
        for each ttRub
            where ttRub.NoLoc = ttQtt.NoLoc
              and ttRub.NoQtt = ttQtt.NoQtt
          , first bxrbp no-lock
            where bxrbp.ntbai = ttQtt.ntbai
              and bxrbp.norub = ttRub.norub
              and bxrbp.nolib = ttRub.nolib
              and bxrbp.cdfam = 04
              and bxrbp.cdsfa = 06
              and bxrbp.prg02 = "00001":
            /* Traitement de révision de la rubrique */
            run trtRevRub.
        end.
        assign
            ttQtt.cdmaj = 1
            ttQtt.cdrev = "00002" /*locataire ayant subi une révision auto.*/
            ttQtt.dtrev = gdaDateRevision
            ttQtt.dtprv = today
            ttQtt.noidc = ttQtt.noidc + ttTache.duree
            giMoisTraitement = ttQtt.msqtt
        .
        for each ttRub2:
            create ttRub.
            buffer-copy ttRub2 to ttRub.
        end.
        assign
            ttQtt.cdmaj = 1
            ttQtt.dtrev = gdaDateRevision
        .
        for each ttRub
            where ttRub.NoLoc = ttQtt.NoLoc
              and ttRub.NoQtt = ttQtt.NoQtt
          , first bxrbp no-lock
            where bxrbp.ntbai = ttQtt.ntbai
              and bxrbp.norub = ttRub.norub
              and bxrbp.nolib = ttRub.nolib
              and bxrbp.prg02 = "00001"
            by ttRub.Norub:
            /* Lancement du module de répercussion sur les quittances futures et sauvegarde dans Equit */
            run bail/quittancement/majlocrb.p(
                piNumeroBail,
                ttQtt.noqtt,
                ttRub.NoRub,
                ttRub.nolib,
                /* SY - 03/12/2001: récupération ancienne date de début d'application de la rubrique révisée */
                if date(ttRub.chfil) <> ? then date(ttRub.chfil) else ttRub.dtdap,
                ttRub.dtfap,
                input-output vcParametre,
                input-output table ttQtt by-reference,
                input-output table ttRub by-reference,
                output vcRetour
            ).
        end.
        viPeriodeIndice = ttQtt.noidc.

        for each ttQtt
            where ttQtt.NoLoc = piNumeroBail
              and ttQtt.NoQtt > piNumeroQuittance:
            assign
                ttQtt.cdmaj = 1
                ttQtt.dtrev = gdaDateRevision
                ttQtt.dtprv = today
                ttQtt.noidc = viPeriodeIndice
            .
        end.
    end.
    /* Création de la prochaine tache révision loyer. */
    run creTacRev("0", ttTache.dtfin, gdaDateRevision, viNumeroDocument).
    /* Revision garantie locative mandat Location */
    /* Calcul du loyer annuel garanti */
    run calMtAnnGar(pcTypeBail, piNumeroBail, output vdeLoyerGaranti).
    if vdeLoyerGaranti > 0 then run revgarlo(pcTypeBail,
                      string(piNumeroBail , "9999999999"),            /* modif SY le 01/10/2009 */
                      gdeTauxRevision,
                      giNombrePouRevision,
                      ttTache.dtfin,
                      goTypeArrondi:getTypeTroncatureLoyer(),
                      goTypeArrondi:getTypeArrondiLoyer(),
                      glBaisseAutorisee            /* ajout SY le 21/05/2010 */
                     ).
    /* Maj du nombre de rubriques apres revision */
    viNombreRubrique = 0.
    for each ttRub
        where ttRub.NoLoc = piNumeroBail
          and ttRub.NoQtt = piNumeroQuittance:
        viNombreRubrique = viNombreRubrique + 1.
    end.
    find first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance no-error.
    if available ttQtt then ttQtt.nbrub = viNombreRubrique.
end procedure.

procedure lecTacMeh private:
    /*----------------------------------------------------------------------------
    Purpose : Procedure de lecture de la tache Méhaignerie
    Notes   :
    ----------------------------------------------------------------------------*/
    define output parameter pdaFinMehaignerie  as date      no-undo.
    define output parameter piDuree            as integer   no-undo.
    define output parameter pdeMontantReaalise as decimal   no-undo.
    define output parameter pcListePalier      as character no-undo.
    define output parameter plMehaignerie      as logical   no-undo.

    define variable vcDateMontant as character no-undo.
    define variable viBoucle      as integer   no-undo.
    define buffer tache for tache.

    find last Tache no-lock        /* SY #9211 ajout NO-LOCK */
        where Tache.tptac = {&TYPETACHE-majorationMermaz}
          and Tache.tpcon = pcTypeBail
          and Tache.nocon = piNumeroBail no-error.
    if not available Tache then return.

    assign
        pcListePalier      = ""
        pdaFinMehaignerie  = tache.dtFin
        piDuree            = tache.duree
        pdeMontantReaalise = decimal(entry(2, tache.lbdiv, "#"))    /* montant réactualisé */
    no-error.
    if error-status:error then return.

    do viBoucle = 3 to num-entries(tache.lbdiv, '#'):
        vcDateMontant = vcDateMontant + '|' + entry(viBoucle, tache.lbdiv, '#').
    end.
    vcDateMontant = trim(vcDateMontant, '|').
    do viBoucle = 1 to num-entries(vcDateMontant, '|'):            /* Liste des dates */
        pcListePalier = pcListePalier + '|' + entry(1, entry(viBoucle, vcDateMontant, '|'), '@').
    end.
    assign
        pcListePalier = trim(pcListePalier, '|') + "|||||||"
        plMehaignerie = yes
    .
end procedure.

procedure creTacRev private:
    /*----------------------------------------------------------------------------
    Purpose : Procedure de création de la prochaine table tache (Révision loyer).
    Notes   :
    ----------------------------------------------------------------------------*/
    define input parameter pcLibelle        as character no-undo.
    define input parameter pdaPrecedente    as date      no-undo.
    define input parameter pdaSuivante      as date      no-undo.
    define input parameter piNumeroDocument as integer   no-undo.

    define variable vcLibelleIndice      as character no-undo.
    define variable vcCodePeriode        as character no-undo.
    define variable viNextRevision       as integer   no-undo initial 1.
    define variable vcPeriodeTraitement  as character no-undo.
    define variable viNombreMois         as integer   no-undo.
    define variable vcLibelleCourtIndice as character no-undo.
    define buffer tache   for tache.
    define buffer vbTache for tache.
    define buffer indrv   for indrv.
    define buffer revtrt  for revtrt.
    define buffer lsirv   for lsirv.

    /*--> Constitution de la chaine nouvel indice */
    vcCodePeriode = "03".
    /*--> Recherche periodicite indice (trim,annuel) */
    find first lsirv no-lock
        where lsirv.CdIrv = integer(ttTache.dcreg) no-error.
    if available lsirv then assign
        vcCodePeriode        = string(lsirv.cdper)
        vcLibelleCourtIndice = lsirv.lbcrt
    .
    run getLibelleIndice in ghProcIndiceRevision(vcCodePeriode, integer(ttTache.cdreg) + ttTache.duree, ttTache.ntreg, "c", output vcLibelleIndice).
    /* Creation nouvel enregistrement revision loyer */
    assign
        ttTache.lbdiv  = substitute("&1&&&2#&3#&4&5&6",
                             entry(1, ttTache.lbdiv, "&"), vcLibelleIndice, gdeValeurRevision, gdeTauxRevision,
                             if num-entries(ttTache.lbdiv, "&") > 2 then "&" + entry(3, ttTache.lbdiv, "&") else "")
        ttTache.dtdeb  = pdaPrecedente
        ttTache.dtfin  = pdaSuivante
        ttTache.utreg  = pcLibelle
        ttTache.dtreg  = today
        ttTache.mtreg  = gdeNvoLoyer
        ttTache.lbdiv2 = string(giMoisTraitement)
        ttTache.cdreg  = string(integer(ttTache.cdreg) + ttTache.duree)
        ttTache.crud   = "C"
    .
    run setTache in ghProcTache(table ttTache by-reference).
    /* Ajout SY le 29/10/2010 : création ligne de traitement */
    {&_proparse_ prolint-nowarn(wholeindex)}
    find last revtrt no-lock no-error.
    if available revtrt then viNextRevision = revtrt.inotrtrev + 1.

    for first ttTache
      , first tache no-lock
        where tache.noita = ttTache.noita:
        find last vbTache no-lock
            where vbTache.tpcon = tache.tpcon
              and vbTache.nocon = tache.nocon
              and vbTache.tptac = {&TYPETACHE-quittancement} no-error.
        if available vbTache then vcPeriodeTraitement = vbTache.pdges.
        create revtrt.
        assign
            revtrt.inotrtrev = viNextRevision
            revtrt.tpcon = tache.tpcon
            revtrt.nocon = tache.nocon
            revtrt.cdtrt = "00300"        /* traitement des révisions (c.f. RVCTR) */
            revtrt.notrt = tache.notac    /* No ordre traitement */
            revtrt.cdact = "00301"        /* Indexation automatique (c.f. RVCAC) */
            revtrt.dtdeb = tache.dtdeb
            revtrt.dtfin = tache.dtcsy    /* date du traitement de l'action */
            revtrt.msqtt = integer(tache.lbdiv2)
            revtrt.cdirv = integer(tache.dcreg)
            revtrt.anirv = integer(tache.cdreg)
            revtrt.noirv = integer(tache.ntreg)
            revtrt.lbcom = substitute("Révision traitée le &1 à &2&3taux de révision = &4%",    // todo   traduction
                                      string(tache.dtcsy, "99/99/9999"), string(tache.hecsy, "HH:MM:SS"), separ[1], gdeTauxRevision)
            revtrt.tprol = tache.tptac
            revtrt.norol = tache.noita
            revtrt.dtcsy = today
            revtrt.hecsy = time
            revtrt.cdcsy = mToken:cUser
        .
        find first indrv no-lock
            where indrv.cdirv = revtrt.cdirv
              and indrv.anper = revtrt.anirv
              and Indrv.noper = revtrt.noirv no-error.
        if available indrv then revtrt.vlirv = indrv.vlirv.
        /* montant loyer */
        viNombreMois = integer(substring(vcPeriodeTraitement, 1, 3, "character")).
        if viNombreMois <> 0 then revtrt.mtloyann = round((12 / viNombreMois) * gdeNvoLoyer, 2).
        /* Taux de la révision */
        revtrt.tphis = string(gdeTauxRevision).
        mLogger:writeLog(9, substitute("Revision auto - locataire &1 - &2 Date de révision &3 Indice &4 &5-&6/&7 taux = &8 mois de quitt = &9",
                                   tache.tpcon, tache.nocon, string(tache.dtdeb, "99/99/9999"),
                                   revtrt.cdirv, vcLibelleCourtIndice, revtrt.anirv, revtrt.noirv, gdeTauxRevision, tache.lbdiv2)).
    end.
    /* Flager le bail pour MAJ lors du transfert */
    run majTrace in ghProcAlimaj(integer(mToken:cRefGerance), 'SADB', 'ctrat', string(piNumeroDocument, '>>>>>>>>9')).    // NoRefGer remplacé par
end procedure.

procedure recPrcRen private:
    /*----------------------------------------------------------------------------
    Purpose : Procedure qui determine l'etat de la révision lors d'une procedure de renouvellement.
    Notes   :
    ----------------------------------------------------------------------------*/
    define input  parameter pcNatureContrat as character no-undo.
    define output parameter pcTypeRevision  as character no-undo.

    define variable vdaRenouvellement as date      no-undo.
    define variable vcAction          as character no-undo.
    define variable vcCategorieBail   as character no-undo.
    define variable vcTypeRevision    as character no-undo.
    define buffer tache for tache.

    /*--> Recherche de la catégorie du bail */
    goCategorieBailUn = new parametrageCategorieBail1(pcNatureContrat).
    if goCategorieBailUn:isActif()
    then vcCategorieBail = goCategorieBailUn:getCategorie().  // bypass le général pour le particulier.
    else if goCategorieBail:isActif()
         then vcCategorieBail = goCategorieBail:getCategorie().
         else do:
             pcTypeRevision = "00000".
             return.
         end.
    /*--> Recherche du parametrage des renouvellements */
    goRenouvellement1 = new parametrageRenouvellement1(vcCategorieBail).
    if goRenouvellement1:isDbParameter
    then vcTypeRevision = goRenouvellement1:getTypeRevision().
    else if goRenouvellement:isDbParameter
         then vcTypeRevision = goRenouvellement:getTypeRevision().
         else do:
             pcTypeRevision = "00000".
             return.
         end.
    /* Si il n'existe pas de procedure de renouvellement revision normale */
    find last tache no-lock
        where tache.tptac = {&TYPETACHE-renouvellement}
          and Tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = piNumeroBail no-error.
    if not available tache or tache.tpfin = "00"
    then do:
        pcTypeRevision = "00000".
        return.
    end.
    /*--> Recherche de la date de renouvellement */
    if tache.dtree <> ? then vdaRenouvellement = tache.dtree.
    if tache.dtreg <> ? then vdaRenouvellement = tache.dtreg.
    /*--> Determiner si révision sur ancienne période d'effet */
    if ttTache.dtfin < tache.dtfin + 1 and (tache.dtfin + 1 <= vdaRenouvellement or vdaRenouvellement = ?)
    then pcTypeRevision = "00000".
    else do:
        /*--> Si en demande de congés: revision bloqué */
        if tache.tpfin = "40" then do:
            pcTypeRevision = "00001".
            return.
        end.
        /*--> Recuperer la dernière action */
        assign
            vcAction = if num-entries(tache.cdhon, "#") > 0 then entry(num-entries(tache.cdhon, "#"), tache.cdhon, "#") else ""
            vcAction = if num-entries(vcAction   , "&") > 1 then entry(2, vcAction, "&") else ""
        .
        /*--> En prolongation réviser en fonction du parametre */
        if tache.tpfin = "10" and (vcAction = "00003" or vcAction = "00014")
        then pcTypeRevision = entry(09, vcTypeRevision, "|").
        else do:
            /*--> Determiner si la révision est normale / bloquée / gelée */
            pcTypeRevision = if tache.tpfin = "30"
                       then "00000"
                       else entry(if vdaRenouvellement = ? or ttTache.dtfin <= vdaRenouvellement then 09 else 10, vcTypeRevision, "|").
            /*--> Revision bloquée si date de revision = date de renouvellement */
            if ttTache.dtfin = vdaRenouvellement then pcTypeRevision = "00001".
        end.
    end.
end procedure.

procedure recTauRev private:
    /*----------------------------------------------------------------------------
    Purpose : récupération du taux de révision.
    Notes
    -----------------------------------------------------------------------------*/
    define variable voCollection as class collection no-undo.

    if ttTache.duree = 1 then do:
        run readIndiceRevision2 in ghProcIndiceRevision(ttTache.dcreg, integer(ttTache.cdreg), ttTache.ntreg, ttTache.duree, output voCollection).
        if voCollection:getLogical("lTrouve")
        then assign
            gdeValeurRevision = voCollection:getDecimal("dValeurRevision")
            gdeTauxRevision = voCollection:getDecimal("dTauxRevision")
        .
        delete object voCollection.
    end.
    if ttTache.duree > 1 then do:
        run readIndiceRevision3 in ghProcIndiceRevision(ttTache.dcreg, integer(ttTache.cdreg) + ttTache.duree, ttTache.ntreg, ttTache.duree, output voCollection).
        if voCollection:getLogical("lTrouve")
        then assign
            gdeValeurRevision = voCollection:getDecimal("dValeurRevision")
            gdeTauxRevision   = voCollection:getDecimal("dTauxRevision")
        .
        delete object voCollection.
    end.
end procedure.

procedure calPrcDat private:
    /*----------------------------------------------------------------------------
    Purppose : Procedure de mise à jour des dates de révision.
    Notes    :
    ----------------------------------------------------------------------------*/
    define variable viNombreMois    as integer    no-undo.
    assign
        viNombreMois    = if ttTache.pdreg = '00001' then 12 * ttTache.duree else ttTache.duree
        gdaDateRevision = add-interval(ttTache.dtfin, viNombreMois, "months")
    .
end procedure.

procedure trtRevRub private:
    /*----------------------------------------------------------------------------
    Purpose : Procedure de traitement de la révision d'une rubrique
    Notes   :
    ----------------------------------------------------------------------------*/
    define variable viRubriqueRappel  as integer  no-undo.
    define variable viSruRappel       as integer  no-undo.
    define variable viSruAvoir        as integer  no-undo.
    define variable vdeAncienMontant  as decimal  no-undo.
    define variable vdaDebut          as date     no-undo.
    define variable vdaFin            as date     no-undo.
    define variable viNombrePeriode   as integer  no-undo.
    define variable viPeriodeIndice   as integer  no-undo.
    define variable vdeMontantCalcule as decimal  no-undo.
    define variable viAvoirRappel     as integer  no-undo.

    /* Calcule du nouveau loyer. */
    assign
        vdeAncienMontant = ttRub.vlmtq
        ttRub.vlmtq = ttRub.vlmtq + (if glBaisseAutorisee or gdeTauxRevision >= 0 then (ttRub.vlmtq * gdeTauxRevision * giNombrePouRevision) / 10000 else 0)
        ttRub.mttot = ttRub.mttot + (if glBaisseAutorisee or gdeTauxRevision >= 0 then (ttRub.mttot * gdeTauxRevision * giNombrePouRevision) / 10000 else 0)
        ttRub.chfil = ""
    .
    /* SY - 03/12/2001: Si le loyer change: changer date début appli et mémoriser ancienne pour majlocrb.p */
    if vdeAncienMontant <> ttRub.vlmtq then assign
        ttRub.chfil = string(ttRub.dtdap)
        ttRub.dtdap = pdaDebutQuittancement
    .
    /* Mise à jour des totaux selon les types arrondi */
    if ttRub.norub = 111 or ttRub.norub = 114 then assign
        ttRub.mttot = round(ttRub.mttot, 2)
        ttRub.vlmtq = round(ttRub.vlmtq, 2)
    .
    else assign
        ttRub.mttot = PrcForMnt(goTypeArrondi:getTypeTroncatureLoyer(), goTypeArrondi:getTypeArrondiLoyer(), ttRub.mttot)
        ttRub.vlmtq = PrcForMnt(goTypeArrondi:getTypeTroncatureLoyer(), goTypeArrondi:getTypeArrondiLoyer(), ttRub.vlmtq)
    .
    /* Nouveau loyer : cumul des rub revisées fixes */
    if ttRub.cdgen = "00001" then gdeNvoLoyer = gdeNvoLoyer + ttRub.mttot.
    /* Modif SY le 18/01/2006 : + rub palier MEH */
    if ttRub.norub = 111 then gdeNvoLoyer = gdeNvoLoyer + ttRub.mttot.
    ttQtt.MtQtt = ttQtt.MtQtt + (ttRub.vlmtq - vdeAncienMontant).
    case ttRub.norub:
        when 101 then assign     /* PL 02/08/2013 (0713/0076) */
            viRubriqueRappel = 105
            viSruRappel      = 00 + ttRub.nolib
            viSruAvoir       = 50 + ttRub.nolib
        .
        when 111 or when 114 then assign
            viRubriqueRappel = 118
            viSruRappel      = giNumeroLibRappel
            viSruAvoir       = 50 + giNumeroLibRappel
        .
        when 652 then assign
            viRubriqueRappel = 642
            viSruRappel      = 01
            viSruAvoir       = 51
        .
        otherwise assign
            viRubriqueRappel = 105
            viSruRappel      = 01
            viSruAvoir       = 51
        .
    end case.

    /* Si date de révision < date de début quittance prorata pour la ou les qtts précédentes */
    if ttTache.dtfin < pdaDebutPeriode then do:
        assign
            vdaDebut        = pdaDebutPeriode
            vdaFin          = pdaFinPeriode
            viNombrePeriode = 0
            viPeriodeIndice = - (interval(vdaFin, vdaDebut, "months") + 1)
        .
        /* Parcours des anciennes quittances pour savoir à laquelle appartient la révision */
boucle:
        do while true:
            /* Retrait de la périodicité dtdeb */
            run cl2DatFin(vdaDebut, viPeriodeIndice, '00002', output vdaDebut).
            /* Retrait de la périodicité dtfin */
            run cl2DatFin(vdaFin, viPeriodeIndice, '00002', output vdaFin).
            if ttTache.dtfin >= vdaDebut and ttTache.dtfin <= vdaFin then leave boucle.

            viNombrePeriode = viNombrePeriode + 1.
        end.
        gdeMontantNonRevise = gdeMontantNonRevise + ((integer(vdaFin - ttTache.dtfin + 1) * (ttRub.vlmtq - vdeAncienMontant)) / integer(vdaFin - vdaDebut + 1)) + ((ttRub.vlmtq - vdeAncienMontant) * viNombrePeriode).
        /* Modif SY le 18/01/2006 : pas d'arrondis pour les MEH */
        if viRubriqueRappel = 118
        then gdeMontantNonRevise = round(gdeMontantNonRevise, 2).
        else gdeMontantNonRevise = PrcForMnt(goTypeArrondi:getTypeTroncatureRevision(), goTypeArrondi:getTypeArrondiRevision(), gdeMontantNonRevise).
    end.
    /* Si date de révision comprise entre la date de début et date de fin quittance: prorata.
       Création rubrique d'avoir sur la période comprise entre date de début qtt et date révis */
    if ttTache.dtfin > pdaDebutQuittancement and ttTache.dtfin <= pdaFinQuittancement then do:
        gdeMontantProrata = gdeMontantProrata + (integer(ttTache.dtfin - pdaDebutQuittancement) * (ttRub.vlmtq - vdeAncienMontant)) / integer(pdaFinQuittancement - pdaDebutQuittancement + 1).
        /* Modif SY le 18/01/2006 : pas d'arrondis pour les MEH */
        if viRubriqueRappel = 118
        then gdeMontantProrata = round(gdeMontantProrata, 2).
        else gdeMontantProrata = PrcForMnt(goTypeArrondi:getTypeTroncatureRevision(), goTypeArrondi:getTypeArrondiRevision(), gdeMontantProrata).
    end.

    /******************************************************************************/
    /* 3 possibilités pour le montant de l'avoir ou du rappel révision loyer:     */
    /*  (Nrv = montant prorata anciennes quittances non révisées)                 */
    /*  (Pro = montant prorata depuis le début de la quittance)                   */
    /*  1 - Locataire révisable non révisé: calcul prorata anciennces quittances  */
    /*  ex1:   Nrv =  2000 (rappel)                                               */
    /*         Nrv = -2000 (avoir)                                                */
    /*  2 - Locataire révisable non révisé et prorata sur la quittance en cours   */
    /*  ex1:   Nrv = 2000  (rappel)                                               */
    /*         Pro =  20   (avoir)   => 2000 - (20)     = 1980 (rappel)           */
    /*         Pro = -20   (rappel)  => 2000 - (-20)    = 2020 (rappel)           */
    /*  ex2:   Nrv = -2000 (avoir)                                                */
    /*         Pro =  20   (avoir)   => (-2000) - (20)  = -2020 (avoir)           */
    /*         Pro = -20   (rappel)  => (-2000) - (-20) = -1980 (avoir)           */
    /*  3 - Locataire révisable : calcul prorata depuis le début de la quittance  */
    /*  ex1:   Pro =  20   (avoir)                                                */
    /*         Pro = -20   (rappel)                                               */
    /******************************************************************************/

    empty temp-table ttRubqt.
    /* Si rubrique rappel ou avoir loyer <> 0 */
    if gdeMontantProrata <> 0 and gdeMontantNonRevise = 0 then do:
        /* Création nouvelle rubrique avoir ou rappel */
        /* Récupération des infos dans RUBQT */
        assign
            vdeMontantCalcule = - gdeMontantProrata
            viAvoirRappel     = if gdeMontantProrata > 0 then viSruAvoir else viSruRappel
       .
        run readRubqt in ghProcRubqt(viRubriqueRappel, viAvoirRappel, table ttRubqt by-reference).
        if can-find(first ttRubqt) then ttQtt.MtQtt = ttQtt.MtQtt - vdeMontantCalcule.
    end.
    /* Si rubrique de rappel ou avoir révision loyer révisable non révisé. */
    if gdeMontantProrata = 0 and gdeMontantNonRevise <> 0 then do:
        /* Création nouvelle rubrique avoir ou rappel */
        /* Récupération des infos dans RUBQT */
        viAvoirRappel = if gdeMontantNonRevise > 0 then viSruRappel else viSruAvoir.
        run readRubqt in ghProcRubqt(viRubriqueRappel, viAvoirRappel, table ttRubqt by-reference).
        assign
            vdeMontantCalcule = gdeMontantNonRevise
            ttQtt.MtQtt       = ttQtt.MtQtt + vdeMontantCalcule
        .
    end.
    /* Calcul de l'avoir ou du rappel selon le prorata sur une quittance en cours et la révision sur les mois précédents. */
    if gdeMontantProrata <> 0 and gdeMontantNonRevise <> 0 then do:
        /* Création nouvelle rubrique avoir ou rappel */
        assign
            vdeMontantCalcule = gdeMontantNonRevise - gdeMontantProrata
            viAvoirRappel     = if vdeMontantCalcule > 0 then viSruRappel else viSruAvoir
        .
        run readRubqt in ghProcRubqt(viRubriqueRappel, viAvoirRappel, table ttRubqt by-reference).
        if can-find(first ttRubqt) then ttQtt.MtQtt = ttQtt.MtQtt + vdeMontantCalcule.
    end.
    /* S'il y a eu révision. */
    for first ttRubqt:
        find first ttRub2
            where ttRub2.NoLoc = piNumeroBail
              and ttRub2.NoQtt = piNumeroQuittance
              and ttRub2.NoRub = viRubriqueRappel no-error.
        if not available ttRub2
        then do:
            create ttRub2.
            assign
                ttRub2.noLoc = piNumeroBail
                ttRub2.noQtt = piNumeroQuittance
                ttRub2.cdFam = ttRubqt.cdfam
                ttRub2.cdSfa = ttRubqt.cdsfa
                ttRub2.noRub = viRubriqueRappel
                ttRub2.NoLib = viAvoirRappel
                ttRub2.LbRub = outilTraduction:getLibelle(ttRubqt.nome1)
                ttRub2.CdGen = ttRubqt.cdGen
                ttRub2.CdSig = ttRubqt.cdsig
                ttRub2.CdDet = "0"
                ttRub2.VlQte = 0
                ttRub2.VlPun = 0
                ttRub2.CdPro = 0
                ttRub2.VlNum = 0
                ttRub2.VlDen = 0
                ttRub2.DtDap = pdaDebutQuittancement
                ttRub2.DtFap = pdaFinQuittancement
                ttRub2.NoLig = 0
            .
        end.
        assign
            ttRub2.MtTot = vdeMontantCalcule
            ttRub2.VlMtq = vdeMontantCalcule
        .
    end.
end procedure.

procedure majTabMeh private:
    /*----------------------------------------------------------------------------
    Purpose : Procedure de révision des rubriques Méhaignerie
    Notes   :
    ----------------------------------------------------------------------------*/
    define input  parameter pdaFinMehaignerie  as date      no-undo.
    define input  parameter piDuree            as integer   no-undo.
    define input  parameter pdeMontantReaalise as decimal   no-undo.
    define input  parameter pcListePalier      as character no-undo.
    define variable vcItem           as character no-undo.
    define variable viBoucle         as integer   no-undo.
    define variable viPalierRevision as integer   no-undo.
    define buffer tache for tache.

    /* Recherche du 1er palier concerné par la révision */
boucle:
    do viBoucle = 1 to num-entries(pcListePalier, '|'):
        /* récupération de la date d'application */
        if date(entry(1, entry(viBoucle, pcListePalier, '|'), '@')) = ?
        or date(entry(1, entry(viBoucle, pcListePalier, '|'), '@')) > ttTache.dtfin then leave boucle.

        viPalierRevision = viBoucle.
    end.
    /* Verifier que le dernier palier est concerne par la revision */
    if viPalierRevision = piDuree and ttTache.dtfin > pdaFinMehaignerie then viPalierRevision = 0.
    if viPalierRevision >= 1
    then for last tache exclusive-lock         /* Application du taux sur les montants modifiables. */
        where tache.tptac = {&TYPETACHE-majorationMermaz}
          and tache.tpcon = pcTypeBail
          and tache.nocon = piNumeroBail:
        entry(2, tache.Lbdiv, "#") = string(pdeMontantReaalise * (1 + gdeTauxRevision / 100), "->>>>>>>>>9.99"). /* montant réactualisé */
        do viBoucle = viPalierRevision + 2 to num-entries(Tache.LbDiv, '#'):
            assign
                vcItem = entry(viBoucle, Tache.lbdiv, "#")
                entry(3, vcItem, "@") = string(decimal(entry(3, vcItem, "@")) * (1 + gdeTauxRevision / 100), "->>>>>>>>>9.99") /* montant réactualisé */
                entry(viBoucle, Tache.Lbdiv, "#") = vcItem
            .
        end.
        run majZonDev(buffer tache).
    end.
end procedure.

procedure calRevLoy private:
    /*----------------------------------------------------------------------------
    Purpose : Procedure de revision du loyer contractuel
    Notes   :
    ----------------------------------------------------------------------------*/
    define input  parameter pdeRevisionLoyer as decimal no-undo.
    define input  parameter piPouRevision    as integer no-undo.
    define buffer tache for tache.

    /*--> Mise a jour de la tache 'loyer contractuel' */
    for first tache exclusive-lock
        where tache.tptac = {&TYPETACHE-loyerContractuel}
          and tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = piNumeroBail:
        tache.mtreg = round(tache.mtreg + if glBaisseAutorisee or pdeRevisionLoyer >= 0 then (tache.mtreg * pdeRevisionLoyer * piPouRevision) / 10000 else 0, 2).
    end.
end procedure.

procedure majZonDev:
    /*----------------------------------------------------------------------------
    Purpose : Procedure pour la simulation du trigger EURO/DEVISE : Maj -dev
    Notes   :
    ----------------------------------------------------------------------------*/
    define parameter buffer tache for tache.

    define variable viBoucle as integer   no-undo.
    define variable vcTemp1  as character no-undo.
    define variable vcTemp2  as character no-undo.

    if tache.tptac = {&TYPETACHE-majorationMermaz} then do:
        assign
            tache.lbdiv-dev = tache.lbdiv
            entry(1, tache.lbdiv-dev, "#") = trim(string(decimal(entry(1, tache.lbdiv, "#")), "->>>>>>>>>9.99"))
            entry(2, tache.lbdiv-dev, "#") = trim(string(decimal(entry(2, tache.lbdiv, "#")), "->>>>>>>>>9.99"))
        .
        do viBoucle = 3 to num-entries(tache.lbdiv, "#"):
            assign
                vcTemp1 = entry(viBoucle, tache.lbdiv-dev, "#")
                vcTemp2 = entry(viBoucle, tache.lbdiv, "#")
                entry(2, vcTemp1, "@") = trim(string(decimal(entry(2, vcTemp2, "@")), "->>>>>>>>>9.99"))
                entry(3, vcTemp1, "@") = trim(string(decimal(entry(3, vcTemp2, "@")), "->>>>>>>>>9.99"))
                entry(viBoucle, tache.lbdiv-dev, "#") = vcTemp1
                entry(viBoucle, tache.lbdiv, "#")     = vcTemp2
            .
         end.
     end.
     if tache.tptac = {&TYPETACHE-empruntISF} then do:
         tache.lbdiv-dev = tache.lbdiv.
         do viBoucle = 1 to num-entries(tache.lbdiv, "&"):
            assign
                vcTemp1 = entry(viBoucle, tache.lbdiv-dev, "&")
                vcTemp2 = entry(viBoucle, tache.lbdiv, "&")
                entry(2, vcTemp1, "@") = trim(string(integer(entry(2, vcTemp2, "@")), "->>>>>>>>>>>9"))
                entry(3, vcTemp1, "@") = trim(string(integer(entry(3, vcTemp2, "@")), "->>>>>>>>>>>9"))
                entry(viBoucle, tache.lbdiv-dev, "&") = vcTemp1
            .
         end.
     end.

end procedure.
