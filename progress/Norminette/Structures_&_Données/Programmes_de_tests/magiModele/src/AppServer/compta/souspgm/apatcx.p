/*------------------------------------------------------------------------
File        : apatcx.p
Purpose     : Traitement des APAT pour cloture travaux. Liste les appels de fonds comptabilisés d'un dossier
Author(s)   : JR - 2006/05/11;  gga  -  2017/04/07
Notes       : reprise du pgm trans\src\gene\apatcx.p

01 |  29/09/06  |  JR  | 0906/0124 : Ajout 0
02 |  08/01/07  |  DM  | 0906/0124 : Ajout Montant appel
03 |  22/02/07  |  JR  | 0906/0124 : Complément pour le montant de TVA
04 |  07/03/07  |  JR  | 0307/0105
05 |  20/03/07  |  JR  | 0906/0124
06 |  23/05/07  |  DM  | 0507/0179 Ne plus envoyer de 7020 dans APAT
07 |  09/11/07  |  NP  | 1007/0022 Remplacement GiCodeSoc par NoRefCop
08 |  26/03/08  |  DM  | 0208/0368 Controle cloture travaux
09 |  07/05/08  |  DM  | 0208/0368 Controle cloture travaux
10 |  18/06/08  |  JR  | 0308/0239 Ajout des OD de mutation dans le calcul des Annulations d'appels de fonds
11 |  16/07/08  |  RF  | 306/0215  Solde des CHB à la cloture
12 |  08/01/09  |  DM  | 0109/0038 Pb si pas de trfpm
13 |  19/02/09  |  DM  | 0209/0018 Annulation sur appels manuels
14 |  20/02/09  |  NP  | 0209/0145 Annulation sur mandats dupliqués
15 |  04/03/09  |  JR  | 0309/0027 GESTION DES DOSSIERS CREES PAR MIGRATION GECOP
16 |  07/04/09  |  JR  | 0309/0299 Ajout du test,  Somme des APCO (hors appels manuels)= somme des CECRLN
   |            |      |L'annulation ne se calcule qu' à partir des APBCO
17 |  15/05/09  |  JR  | Lors de la dupplication d'un mandat, tous les APBCO du dossier sont créés,
   |            |      | mais seules les écritures de l'exercice courant sont créées.
18 |  24/09/09  |  OF  | 0909/0118 doublon entre APBCO de la migration et ceux saisis par le client en appels manuels
19 |  25/09/09  |  JR  | Pour 03082 : le module 'Gener_Lignes_Annulation_Migration' n'est pas nécessaire
   |            |      | . Soit le client fait un appel de fonds manuel, donc apbco généré
   |            |      | . Soit il annule les appels de fonds travaux créés en migration par une OD
   |            |      |    OD de la classe 7 vers la classe 6, ainsi la répartition se fera au niveau des charges
20 |  06/10/09  |  JR  | 0909/0004 retour du 06/10/09
21 |  12/10/09  |  DM  | 1009/0072 Cloture dossier avec appel FRS
22 |  14/10/09  |  JR  | 1009/0024
23 |  18/11/09  |  RF  | 1009/0070 Correction
24 |  20/11/09  |  JR  | 1109/0104 Meilleur gestion des  message d'anomalies
25 |  26/11/09  |  JR  | Le test par clé ne doit pas tenir compte des apbco des  écritures CPHB lors d'un retirage
26 |  10/12/09  |  DM  | 1209/0082 Filtrer la clé XX (app au matricule)
27 |  11/01/10  |  RF  | 1209/0274 Total Appel à Annuler faux
28 |  23/03/10  |  JR  | 0310/0185 Les dosap FRS et FRL ne doivent pas être répartis. Il génére des ODT
29 | 15/04/2010 |  JR  | Modif de TbTmpDos.i
30 | 10/05/2010 |  JR  | 0508/0072 Ajout des OD ventilées en apbco
31 | 04/06/2010 |  JR  | 0110/0240 APAT est maitenant par appel , par copro, et par lot
32 | 16/07/2010 |  JPM | Ajout procedure Chargembap pour édition locale des appels de fonds
33 | 30/07/2010 |  JR  | Migration GECOP : Prise des appels de reprise
34 |  19/08/10  |  OF  | 0810/0065 Suite 1209/0274 Le montant à annuler ne déduit pas les appels fonds de réserve
35 |  20/12/10  |  OF  | 1210/0126 Suite 0810/0065 Le total des appels à annuler est faux pour des appels manuels
36 | 03/03/2011 |  DM  | 0311/0022 mutation et appel FRS/FRL
37 | 11/04/2012 |  OF  | 0412/0056 Pb écritures de migration sur journal ODGC et non AFTX chez Gérer
38 | 20/11/2012 |  SY  | 1112/0068 modif include prorata.i
39 | 20/02/2013 |  SY  | 0911/0112 tables tempo en include ttTmpSld.i et ttTmpErr.i
40 | 11/04/2012 |  OF  | 0313/0194 Pb écritures de migration sur journal OD chez Orlarei
41 | 22/11/2013 |  RF  | 1113/0093 Cloture Avec Emp./Indemn./Subv.
42 | 27/11/2013 |  RF  | 1113/0181 Appels de fonds manuels reprise. Prendre éventuels A NOUVEAUX sur 702X 00000
43 | 03/06/2014 |  DM  | 0514/0111 pb controle dossier migrés
44 | 08/10/2015 | JPM  | 0115/0119 Montant total des appels émis par copropriétaire
45 | 11/02/2016 | JPM  | Annulation appels emis : total à répartir faux
46 | 28/06/2016 |  NP  | 0616/0239 Pb format dans Mlog
47 | 24/08/2016 |  SY  | 0816/0049 Annulation appels emis: total à répartir faux si financement FRS/FRL
48 | 24/01/2017 |  OF  | 1114/0274 Fonds travaux ALUR
----------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/typeAppel.i}
{preprocesseur/typeAppel2fonds.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/tbTmpSld.i}
{compta/include/tbartappels.i}             /*gga todo voir info dans include */
{application/include/error.i}
{application/include/glbsepar.i}

{travaux/include/editionAno.i}

/*gga plus utilise on est toujours en mode apres bascule avec date >= isoc.dat-decret
{dadecret.i INT(NoRefCop)}
gga*/

define temp-table ttEcrApat no-undo
    field cpt-cd       as character
    field NumTrait     as character
    field Mt           as decimal
    field SigneMt      as character
    field Mttva        as decimal
    field taxe-cd      as integer
    field SigneMttva   as character
    field cpt-ctp      as character
    field MtAppel      as decimal
    field SigneMtAppel as character
    index primaire cpt-cd
.
/** Pour la phase de tests uniquement : test_apbco_cecrln **/
define temp-table ttCecrlnTst no-undo
    like cecrln
    field noapp as integer
    index i-nocop noapp cpt-cd
.
define temp-table ttApbcoTst no-undo
    like apbco
    index i-noapp noapp cdcle nolot
    index i-nocop noapp nocop
.
define temp-table ttReguleTmp no-undo
    like apbco
    index primaire nobud noapp nomdt noimm
.
define temp-table ttDosapTmp no-undo
    like dosap
    field FgRegule             as logical
    field FgDiffApbcoCecrln    as logical
    field FgAnomalieAppelApbco as logical
    field FgAnomalieCle        as logical
    index primaire nocon nodos noapp
    index secondaire FgAnomalieAppelApbco
.
define temp-table ttCle no-undo
    field cdcle       as character
    field mtcle       as decimal
    field mtcle_apbco as decimal
    field nocop       as integer
    index i-cle   cdcle nocop
    index i-nocop nocop cdcle
.
define variable giNoRefTrans        as integer   no-undo.
define variable gcTypeBudget        as character no-undo.
define variable giNumeroBudget      as integer   no-undo.
define variable giNumeroImmeuble    as integer   no-undo.
define variable gcTypeAppelRoulAlur as character no-undo.
define variable giSeuil             as integer   no-undo.

define stream sFichier.

{compta/include/prorata.i}   /** définition de ttApbcoTmp et ttApbcoTmpPro + définition de la procédure 'prorata' **/
{compta/include/defligne.i}

procedure apatcxTrtApat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par ctrltrav.p
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define input-output parameter table for ttTmpSld.
    define input  parameter table for ttError.
    define output parameter pdMtTotOut as decimal no-undo.
    define output parameter plRetourOk as logical no-undo.
    define output parameter table for ttTmpErr.

    define variable viNumeroMandat         as integer   no-undo.
    define variable viNumeroDossierTravaux as integer   no-undo.
    define variable vlStop                 as logical   no-undo.
    define variable vcTrfRpRunTmp          as character no-undo.
    define variable vlTest                 as logical   no-undo.
    define variable vcFichier              as character no-undo.

    define buffer apbco for apbco.
    define buffer intnt for intnt.
    define buffer trdos for trdos.
    define buffer ietab for ietab.

    assign
        giSeuil                = 0
        viNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        viNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        gcTypeAppelRoulAlur    = substitute("&1,&2,&3", {&TYPEAPPEL2FONDS-financementRoulement}, {&TYPEAPPEL2FONDS-financementReserve}, {&TYPEAPPEL2FONDS-fondtravauxAlur})
        giNoRefTrans           = poCollection:getInteger("iNoRefTrans")
        vcTrfRpRunTmp          = session:temp-directory + "adb~\tmp~\"
        vlTest                 = poCollection:getLogical("lTest")
        vcFichier              = poCollection:getCharacter("cFichier")
    .
    find first ietab no-lock
        where ietab.soc-cd  = integer(mToken:cRefCopro)
          and ietab.etab-cd = viNumeroMandat no-error.
    if not available ietab
    then do:
        mError:createError({&error}, "table ietab inexistante (gga todo a revoir impossible)").
        return.
    end.
    for each trdos no-lock
        where trdos.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and trdos.nocon = ietab.etab-cd
          and trdos.nodos = viNumeroDossierTravaux
      , first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and intnt.nocon = trdos.nocon:
        assign
            giNumeroImmeuble = intnt.noidt
            gcTypeBudget     = {&TYPEBUDGET-travaux}
            giNumeroBudget   = intnt.nocon * 100000 + trdos.nodos
        .
        /** Test si égalité entre les apbco et la comptabilisation, hors appels de fond manuel **/
        run test_Apbco_Cecrln(buffer ietab, buffer trdos, output vlStop).
        if not vlStop then do:
            empty temp-table ttApbcoTmp.
            for each apbco no-lock
                where apbco.tpbud = gcTypeBudget
                  and apbco.nobud = giNumeroBudget
                  and apbco.nomdt = trdos.nocon
                  and apbco.noimm = giNumeroImmeuble
                  and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}   /** (apbco.tpapp = "TX" OR apbco.tpapp = "CX") les apbco CX sont créés pas apipcx.p lors de la cloture , ils représentent des dépenses **/
                  and (lookup(apbco.typapptrx, gcTypeAppelRoulAlur) = 0 or apbco.noord <> 0): /* DM 0311/0022 Prendre les mutations de FRS-FRL */
                create ttApbcoTmp.
                buffer-copy apbco to ttApbcoTmp.
            end.
            run prorata(buffer trdos, vcTrfRpRunTmp).
            run apbco_od_manuelle (buffer trdos).
            run annulation_avec_apbco (buffer trdos).
        end.
    end.
    if vlStop then return.

    /*-----------------------------------------------------------------------------
      ENVOI DES LIGNES D'ANNULATION DANS LE FICHIER DE COPRO
    ------------------------------------------------------------------------------*/
    output stream sFichier to value(vcFichier) append.
    for each ttEcrApat:
        pdMtTotOut = pdMtTotOut - absolute(ttEcrApat.mt) * if ttEcrApat.SigneMt = "-" then -1 else 1. /*  DM 0208/0368 07/05/08 */
        /** APAT : Montant de l'annulation des appels de fonds par appel , par copro et par lot **/
        run article_APAT_lot (buffer ttEcrApat, buffer ietab, "A", vlTest).
    end.
    run EcrLigneSurFichier.
    output stream sFichier close.

    /* RF 1113/0093 */

    /* Dossier Travaux avec Emprunt/Indemnité/Subvention                                        */
    /* On ne doit annuler le montant réel appelé = Mt Appel - Mt Emprunt/indemnite/Subvention   */
    /* Pour faire la répartition aux copros - génération des articles                           */
    /*   - MAIS -   */
    /* Pour le test de cloture, on doit prendre le montant des Appel SANS ces subvention        */
    /* Sinon Solde 6 + 7 <> Mt Appel - Mt Dépenses                                              */
    /* Emprunt/indemnite/Subvention = classe 7 mais soldés!! - Sinon on a pas reçu les fonds!!  */

    /* 1113/0093 - Sortie des Emprunt/Indemnité/Subvention du Montant Total Appelé              */
    for each ttApbcoTmp
        where lookup(ttApbcoTmp.typapptrx, "00006,00007,00008") > 0:
        pdMtTotOut = pdMtTotOut + ttApbcoTmp.mtlot.
    end.

    /* RF 0306/0215 - LOT 3 - appel cloture par copro pour éventuelle od de solde               */
    if vlTest then for each ttEcrApat:
        find first ttTmpSld
            where ttTmpSld.nomdt = ietab.etab-cd
              and ttTmpSld.nocop = integer(ttEcrApat.cpt-cd) no-error.
        if not available ttTmpSld
        then do:
            create ttTmpSld.
            assign
                ttTmpSld.nomdt = ietab.etab-cd
                ttTmpSld.nocop = integer(ttEcrApat.cpt-cd)
            .
        end.
        ttTmpSld.mtappan = ttTmpSld.mtappan + ttEcrApat.mt * (if ttEcrApat.SigneMt = "+" then 1 else -1).
    end.

message "gga apatcx.p fin traitement ".
    plRetourOk = yes.

end procedure.

procedure Article_APAT_lot private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer ttEcrApat for ttEcrApat.
    define parameter buffer ietab for ietab.
    define input parameter pcEditionAvecTva as character no-undo.
    define input parameter plFgTestIn       as logical   no-undo.

    define variable viNoDos  as integer   no-undo.
    define variable viNoApp  as integer   no-undo.
    define variable viNoBud  as int64     no-undo.
    define variable vcChaine as character no-undo.

    assign
        viNoDos = integer(substring(ttEcrApat.numtrait, 1, 2, 'character'))
        viNoApp = integer(substring(ttEcrApat.numtrait, 3, 2, 'character'))
        viNoBud = ietab.etab-cd * 100000 + viNoDos
    .
    for each ttApbcoTmp
        where ttApbcoTmp.nocop = integer(ttEcrApat.cpt-cd)
          and ttApbcoTmp.tpbud = {&TYPEBUDGET-travaux}
          and ttApbcoTmp.nobud = viNoBud
          and ttApbcoTmp.noapp = viNoApp
        by ttApbcoTmp.nocop by ttApbcoTmp.noapp by ttApbcoTmp.nolot:
        assign
            vcChaine = substitute('&1&2&3&4&5&6&7&8&9'
                                 , string(ietab.etab-cd, "99999")
                                 , string(ttEcrApat.numtrait, "x(4)")
                                 , string(ttEcrApat.cpt-cd, "x(5)")
                                 , string(absolute(ttApbcoTmp.mtlot) * 100, "99999999999")
                                 , if ttApbcoTmp.mtlot >= 0 then "+" else "-"
                                 , ttEcrApat.Cpt-ctp
                                 , string(absolute(ttApbcoTmp.tvlot) * 100, "99999999999")
                                 , if ttApbcoTmp.tvlot >= 0 then "+" else "-"
                                 , string(absolute(ttEcrApat.mtappel) * 100, "99999999999"))   /* DM 0906/0124 */
                     + substitute('&1&2&3'
                                 , ttEcrApat.SigneMtAppel                                     /* DM 0906/0124 */
                                 , pcEditionAvecTva                                           /*  0906/0124 du 20/03/07 */
                                 , string(ttApbcoTmp.nolot, "99999"))
            vcChaine = vcChaine + fill(" ", 137 - length(vcChaine, 'character'))
        .
        if plFgTestIn = false
        then run chargeMbAp ("APAT", vcChaine).     /* modif jpm du 12/07 car articles APAT stockés 2 fois (cgapfco & copro.w) */
        run ligne("APAT", giNoRefTrans, vcChaine).
    end.

end procedure. /* Article_APAT_lot */

procedure apbco_od_manuelle private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer trdos for trdos.

    define buffer apbco for apbco.

    for each apbco no-lock
        where apbco.tpbud     = gcTypeBudget
          and apbco.nobud     = giNumeroBudget
          and apbco.tpapp     = "OD"
          and apbco.nomdt     = trdos.nocon
          and apbco.typapptrx = "":
        create ttApbcoTmp.
        buffer-copy apbco to ttApbcoTmp.
    end.

end procedure.

procedure ChargeMbAp private:
    /*------------------------------------------------------------------------------
     Purpose: Procedure de chargement des mandats transmis au site central pour traitement
              local à suivre (Appels de fonds)
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcNmArtUse as character no-undo.
    define input parameter pcChaine as character no-undo.

    create ttArtappels.
    assign
        ttArtappels.noref = string(giNoRefTrans, "99999")
        ttArtappels.art   = pcChaine
        ttArtappels.cdart = pcNmArtUse
    .
end procedure.

procedure Test_Apbco_Cecrln private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab for ietab.
    define parameter buffer trdos for trdos.
    define output parameter plStop-Out as logical no-undo.

    /** Cumul de la comptabilisation des appels **/
    define variable vdCumulCecrln        as decimal   no-undo.
    define variable vcJouAppel           as character no-undo.
    define variable vcTypeAppel          as character no-undo initial "ODTX".
    define variable vcJouOdMutation      as character no-undo.
    define variable vcTypeOdMutation     as character no-undo initial "ODB".
    define variable vdCumulApbco         as decimal   no-undo.
    define variable vlStop               as logical   no-undo.
    define variable vlDiffApbcoCecrlnCop as logical   no-undo.
    define variable vlDiffApbcoCecrln    as logical   no-undo.
    define variable vlRegule             as logical   no-undo.
    define variable vlAnomalieAppelApbco as logical   no-undo.
    define variable vlAnomalieCle        as logical   no-undo.
    define variable vlAuMoinsUnApbco     as logical   no-undo.
    define variable vlDup                as logical   no-undo.
    define variable vcRefnum             as character no-undo.
    define variable vcRefnum2            as character no-undo.
    define variable vclstAppels          as character no-undo.
    define variable vdTotRepartition     as decimal   no-undo extent 100.
    define variable viRetQuestion        as integer   no-undo.

    define buffer ijou   for ijou.
    define buffer dosap  for dosap.
    define buffer apbco  for apbco.
    define buffer cecrln for cecrln.

    empty temp-table ttApbcoTst.
    empty temp-table ttCecrlnTst.
    empty temp-table ttReguleTmp.
    empty temp-table ttDosapTmp.

    if num-entries(ietab.usrid, "|") >= 2
    and entry(2, ietab.usrid, "|") begins "DUPLICATION" then vlDup = true.
    /** Journal Appel de fonds Travaux : AFTX **/
    for first ijou no-lock
        where ijou.soc-cd    = ietab.soc-cd
          and ijou.etab-cd   = ietab.etab-cd
          and ijou.natjou-gi = 65:
        vcJouAppel = ijou.jou-cd.
    end.
    /** Journal OD Mutation : ODSC **/
    for first ijou no-lock
        where ijou.soc-cd    = ietab.soc-cd
          and ijou.etab-cd   = ietab.etab-cd
          and ijou.natjou-gi = 91:
        vcJouOdMutation = ijou.jou-cd.
    end.

message "gga debut Test_Apbco_Cecrln ".

    for each dosap no-lock
        where dosap.TpCon     = trdos.tpcon
          and dosap.NoCon     = trdos.nocon
          and dosap.NoDos     = trdos.nodos
          and dosap.fgemi     = true
          and dosap.modetrait <> "M" /* appels manuels */
        break by dosap.noapp:

        if first-of(dosap.noapp) then do:
            assign
                vlAnomalieCle        = false     /** Flag qui permet de savoir si il y a une différence au niveau des clé entre apbco et dosdt **/
                vlAnomalieAppelApbco = false     /** Flag qui permet de savoir si il y a une différence entre dosap.mttot et la somme des apbco : appel par appel **/
                vlDiffApbcoCecrln    = false     /** Flag qui permet de savoir si il y a une différence entre les apbco et les cecrln en globalité : différence > 1 euro **/
                vlDiffApbcoCecrlnCop = false     /** Flag qui permet de savoir si il y a une différence entre les apbco et les cecrln au niveau de chaque cop : différence > 1 euro  **/
                vdTotRepartition[dosap.noapp] = dosap.mttot /** Total des appels de fonds par répartition : ces appels sont comptabilisés et ventilés par lots dans apbco **/
            .
            /** 0310/0185 Les dosap FRS et FRL ne doivent pas être répartis. Il génére des ODT. **/
            /** On les filtre au niveau du total de l'appel et on les filtre au niveau des apbco (détails par lot)**/
            for each apbco no-lock
                where apbco.tpbud = gcTypeBudget
                  and apbco.nobud = giNumeroBudget
                  and apbco.nomdt = trdos.nocon
                  and apbco.noimm = giNumeroImmeuble
                  and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
                  and apbco.noapp = dosap.noapp
                  and lookup(apbco.typapptrx, gcTypeAppelRoulAlur) <> 0
                  and apbco.noord = 0:                                   /* DM 0311/0022 Prendre les mutations de FRS-FRL */
                vdTotRepartition[dosap.noapp] = vdTotRepartition[dosap.noapp] - apbco.mtlot.
            end.
            /** Cumul de la comptabilisation des apbco hors appels de fonds manuel **/
            assign
                vdCumulApbco     = 0
                vlAuMoinsUnApbco = false
            .
            for each apbco no-lock
                where apbco.tpbud = gcTypeBudget
                  and apbco.nobud = giNumeroBudget
                  and apbco.nomdt = trdos.nocon
                  and apbco.noimm = giNumeroImmeuble
                  and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}                             /** OR apbco.tpapp = "CX" les apbco CX sont créés pas apipcx.p lors de la cloture **/
                  and apbco.noapp = dosap.noapp
                  and (lookup(apbco.typapptrx, gcTypeAppelRoulAlur) = 0 or apbco.noord > 0):  /* DM 0311/0022 Prendre les mutations de FRS-FRL */
                vdCumulApbco = vdCumulApbco + apbco.mtlot.
                create ttApbcoTst.
                buffer-copy apbco to ttApbcoTst.
                vlAuMoinsUnApbco = true.
            end.
            /** Cumul de la comptabilisation des appels **/
            assign
                vdCumulCecrln = 0
                vcRefNum      = substitute("AFTX.&1&2", string(trdos.nodos, "99"), string(dosap.noapp, "99"))
            .
            for each ijou no-lock
                where ijou.soc-cd  = ietab.soc-cd
                  and ijou.etab-cd = ietab.etab-cd
                  and (ijou.jou-cd = vcJouAppel or ijou.jou-cd = vcJouOdMutation)
              , each cecrln no-lock
                where cecrln.soc-cd     = ietab.soc-cd
                  and cecrln.etab-cd    = ietab.etab-cd
                  and cecrln.jou-cd     = ijou.jou-cd
                  and cecrln.affair-num = trdos.nodos
                  and cecrln.ref-num    = vcRefNum
                  and (cecrln.type-cle = vcTypeAppel or cecrln.type-cle = vcTypeOdMutation)
                  and cecrln.sscoll-cle <> "":
                if cecrln.sens
                then vdCumulCecrln = vdCumulCecrln + cecrln.mt.
                else vdCumulCecrln = vdCumulCecrln - cecrln.mt.
                create ttCecrlnTst.
                buffer-copy cecrln to ttCecrlnTst
                    assign ttCecrlnTst.noapp = dosap.noapp
                .
            end.
            /** Enregistrement de l'anomalie **/
            if absolute(vdTotRepartition[dosap.noapp] - vdCumulApbco) > 0
            then do:
                run Anomalie01(vdTotRepartition[dosap.noapp], vdCumulApbco, trdos.nocon, trdos.nodos, dosap.noapp, output vlStop).
                if vlStop then assign
                    plStop-Out           = true
                    vlAnomalieAppelApbco = true
                .
                /** Le détail par lot ne correspond pas à l'appel de fonds gestion : le programme rajoute un test au nniveau
                    des clés . Ca permet de trouver plus rapidement le problème. **/
                if vlAnomalieAppelApbco
                then do:
                    run test_Par_Cle (trdos.nocon, trdos.nodos, dosap.noapp, output vlStop).
                    if not vlStop then assign
                        plStop-Out           = false
                        vlAnomalieAppelApbco = false
                    .
                end.
            end.
            else do:
                /** Comparaison au niveau des clés entre dosdt et apbco **/
                run test_Par_Cle (trdos.nocon, trdos.nodos, dosap.noapp, output vlStop). /** 1009/0024 **/
                if vlStop then assign
                    plStop-Out    = true
                    vlAnomalieCle = true
                .
                if (absolute(vdCumulCecrln - vdCumulApbco) > 0 and vlDup and vdCumulCecrln <> 0)
                or (absolute(vdCumulCecrln - vdCumulApbco) > 0 and not vlDup)
                then do:
                    vlDiffApbcoCecrln = true.
                    run anomalie (vdCumulApbco, vdCumulCecrln, dosap.tpcon, trdos.nocon, trdos.nodos, dosap.noapp, trdos.lorep, output vlStop).
                    if vlStop then plStop-Out = true.
                end.
            end.

            find first ttDosapTmp
                where ttDosapTmp.nocon = trdos.nocon
                  and ttDosapTmp.nodos = trdos.nodos
                  and ttDosapTmp.noapp = dosap.noapp no-error.
            if not available ttDosapTmp
            then do:
                create ttDosapTmp.
                buffer-copy dosap to ttDosapTmp.
            end.
            assign
                ttDosapTmp.FgDiffApbcoCecrln    = if not ttDosapTmp.FgDiffApbcoCecrln    then vlDiffApbcoCecrln    else ttDosapTmp.FgDiffApbcoCecrln
                ttDosapTmp.FgAnomalieAppelApbco = if not ttDosapTmp.FgAnomalieAppelApbco then vlAnomalieAppelApbco else ttDosapTmp.FgAnomalieAppelApbco
                ttDosapTmp.FgAnomalieCle        = if not ttDosapTmp.FgAnomalieCle        then vlAnomalieCle        else ttDosapTmp.FgAnomalieCle
            .
            /**** TEST AU NIVEAU DE CHAQUE COPROPRIETAIRE ****/
            if not vlDup or vdCumulCecrln <> 0
            then do:
                if not ttDosapTmp.FgDiffApbcoCecrln
                and not ttDosapTmp.FgAnomalieAppelApbco /** 0909/0004 retour du 06/10/09 **/
                and not ttDosapTmp.FgAnomalieCle
                then do:
                    run Test_Apbco_cecrln_cop(buffer trdos, buffer dosap, vdTotRepartition, output vlDiffApbcoCecrlnCop, output vlStop).
                    if vlStop then plStop-Out = true.
                    if vlDiffApbcoCecrlnCop
                    then do:
                        vlRegule = vlAuMoinsUnApbco.
                        find first ttDosapTmp
                            where ttDosapTmp.nocon = trdos.nocon
                              and ttDosapTmp.nodos = trdos.nodos
                              and ttDosapTmp.noapp = dosap.noapp no-error.
                        if available ttDosapTmp then ttDosapTmp.FgRegule = vlRegule.
                    end.
                end.
                else if ttDosapTmp.FgDiffApbcoCecrln
                and not ttDosapTmp.FgAnomalieAppelApbco /** 0909/0004 retour du 06/10/09 **/
                and not ttDosapTmp.FgAnomalieCle
                then do:
                    run Test_Apbco_cecrln_cop(buffer trdos, buffer dosap, vdTotRepartition, output vlDiffApbcoCecrlnCop, output vlStop).
                    if vlStop then assign
                        plStop-Out = true
                        vlRegule   = vlAuMoinsUnApbco
                    .
                    find first ttDosapTmp
                        where ttDosapTmp.nocon = trdos.nocon
                          and ttDosapTmp.nodos = trdos.nodos
                          and ttDosapTmp.noapp = dosap.noapp no-error.
                    if available ttDosapTmp then ttDosapTmp.FgRegule = vlRegule.
                end.
            end.
        end. /** IF FIRST-OF(dosap.noapp) **/
    end. /** FOR EACH dosap **/

    vclstAppels = "".
    for each ttDosapTmp
        where ttDosapTmp.FgAnomalieAppelApbco:
        vclstAppels = substitute('&1,&2', vclstAppels, string(ttDosapTmp.noapp)).
    end.
    vclstAppels = trim(vclstAppels, ',').
    if vclstAppels > "" then mError:createError({&information}, 4000026,
                                                 substitute('&2&1&3&1&4', separ[1], trdos.nocon, trdos.nodos, vclstAppels)).
    vclstAppels = "".
    for each ttDosapTmp
        where ttDosapTmp.FgDiffApbcoCecrln
          and ttDosapTmp.FgAnomalieAppelApbco = false: /* = false pour prendre l'index */
        vclstAppels = substitute('&1,&2', vclstAppels, string(ttDosapTmp.noapp)).
    end.
    vclstAppels = trim(vclstAppels, ',').
    if vclstAppels > "" then mError:createError({&information}, 4000027,
                                                 substitute('&2&1&3&1&4', separ[1], trdos.nocon, trdos.nodos, vclstAppels)).
    vclstAppels = "".
    for each ttDosapTmp
        where ttDosapTmp.FgAnomalieCle
          and ttDosapTmp.FgAnomalieAppelApbco = false:  /* = false pour prendre l'index */
        vclstAppels = substitute('&1,&2', vclstAppels, string(ttDosapTmp.noapp)).
    end.
    vclstAppels = trim(vclstAppels, ',').
    if vclstAppels > "" then mError:createError({&information}, 4000028,
                                                 substitute('&2&1&3&1&4', separ[1], trdos.nocon, trdos.nodos, vclstAppels)).
    /** Régule des différences entre le détail des appels de fonds et la comptabilisation au niveau de chaque copro. **/
    vclstAppels = "".
    for each ttDosapTmp
        where ttDosapTmp.FgRegule:
        vclstAppels = substitute('&1,&2', vclstAppels, string(ttDosapTmp.noapp)).
    end.
    vclstAppels = trim(vclstAppels, ',').
    if vclstAppels > ""
    then do:
        mError:createError({&information}, 4000029,
                            substitute('&2&1&3&1&4', separ[1], trdos.nocon, trdos.nodos, vclstAppels)).
        if mToken:cUser = "INS"
        and not can-find(first ttReguleTmp where ttReguleTmp.mtlot > 1)
        then do:
            viRetQuestion = outils:questionnaire(4000030, table ttError by-reference).
            if viRetQuestion < 2
            then do:
                plStop-Out = yes.
                return.
            end.
            if viRetQuestion = 3 then for each ttDosapTmp         /* si question pose et reponse oui alors création d'un apbco de régul **/
                where ttDosapTmp.FgRegule
              , each ttReguleTmp
                where ttReguleTmp.nobud = giNumeroBudget
                  and ttReguleTmp.noapp = ttDosapTmp.noapp
                  and ttReguleTmp.nomdt = ttDosapTmp.nocon
                  and ttReguleTmp.noimm = giNumeroImmeuble:
                create apbco.
                buffer-copy ttReguleTmp to apbco.
            end.

            message "gga apatcx.p apres test tterror  " .

        /*gga correspond au nouveau traitement au dessus voir nicolas pour retour question et saisie mot de passe
                    message  "Pour corriger en créant une régularisation au niveau des détails sur chaque copropriétaire, choisissez OUI. "
                        skip
                        "Il faudra relancer la clôture du dossier."
                        view-as alert-box question buttons yes-no update lreponse as logical.
                    if lreponse then do:
                        run VALUE( TrfRpRunGen + "motpasse.w" ) (input "", output vlErrMotPasse).
                        if vlErrMotPasse or vlErrMotPasse = ? then do:
                            if vlErrMotPasse <> ? then do:
                                 {mestrans.i "100038" "'E'"}
                            end.
                        end.
                        else do:
                            /** Création d'un apbco de régul **/
                            for each ttDosapTmp where ttDosapTmp.FgRegule :
                                for each ttReguleTmp where ttReguleTmp.nobud = giNumeroBudget
                                    and   ttReguleTmp.noapp = ttDosapTmp.noapp
                                    and   ttReguleTmp.nomdt = ttDosapTmp.nocon
                                    and   ttReguleTmp.noimm = giNumeroImmeuble:
                                    create apbco.
                                    buffer-copy ttReguleTmp to apbco.
                                end.
                            end. /** FOR EACH ttDosapTmp : **/
                        end. /** IF vlErrMotPasse **/
                    end. /** IF lreponse **/
        gga*/

        end.
    end.

    /** Dossier Travaux créé par la migration GECOP **/
    /** Remarque : la migration GECOP n'a pas créé de APBCO pour Gosselin 03082
        OF le 24/09/09: les APBCO ont été créés sur la ref 3089 mais le client
        a saisi des appels de fonds manuels, ce qui fait doublon. J'ai donc
        supprimé les APBCO créés par la migration (NOAPP = 0)**/
    if trdos.cdcsy = "MIGRATION GECOP" and lookup(string(ietab.soc-cd), "3082,3089") = 0
    then do:
        /** Cumul de la comptabilisation des apbco, N° Appel = 0 **/
        vdCumulApbco = 0.
        for each apbco no-lock
            where apbco.tpbud = gcTypeBudget
              and apbco.nobud = giNumeroBudget
              and apbco.nomdt = trdos.nocon
              and apbco.noimm = giNumeroImmeuble
              and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}  /** OR apbco.tpapp = "CX" Pas de apbco CX en migration GECOP **/
              and (apbco.noapp = 0 or apbco.noapp >= 50):
            vdCumulApbco = vdCumulApbco + apbco.mtlot.
        end.

        /*--------------------------------------------------------------------------------------------------
        Les écritures d'appels de fonds travaux migrées depuis GECOP:
        Journal : AFTX
        Les copro sont sur le compte C et non-pas CHB
        Le numéro de document ne commencent par AFTX ou CPHB
        L'écriture sur le C n'a pas le numéro, mais celle sur le compte 7 oui
        ---------------------------------------------------------------------------------------------------*/
        assign
            vdCumulCecrln = 0
            vcRefnum      = "AFTX." + string(trdos.nodos, "99")
            vcRefnum2     = "CPHB." + string(trdos.nodos, "99")
        .
        for each cecrln no-lock
            where cecrln.soc-cd     = ietab.soc-cd
              and cecrln.etab-cd    = ietab.etab-cd
              and cecrln.affair-num = trdos.nodos
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     > "700000000"
              and not cecrln.ref-num begins vcRefnum           /* DM 0514/0111 = */
              and not cecrln.ref-num begins vcRefnum2          /* DM 0514/0111 = */
              and lookup(cecrln.jou-cd, "AFTX,ODGC,OD,AN") > 0 /* RF 27/11/2013 - 1113/0181 - Inclure A Nouveaux de reprise !!*/
              and lookup(cecrln.type-cle, "ODTX,ODB,OD") > 0:
            if cecrln.sens                                     /** Le sens est inversé par rapport aux écritures sur les copropriétaires . **/
            then vdCumulCecrln = vdCumulCecrln - cecrln.mt.
            else vdCumulCecrln = vdCumulCecrln + cecrln.mt.
        end.

        /** Enregistrement de l'anomalie **/
        if vdCumulCecrln - vdCumulApbco <> 0
        then do:
            run anomalie(vdCumulApbco, vdCumulCecrln, dosap.tpcon, trdos.nocon, trdos.nodos, 0, trdos.lorep, output vlStop).
            if vlStop then plStop-Out = true.
        end.
    end.

end procedure.

procedure Test_Par_Cle private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piNoMdtIn as integer no-undo.
    define input  parameter piNoDosIn as integer no-undo.
    define input  parameter piNoAppIn as integer no-undo.
    define output parameter plStop    as logical no-undo.

    define buffer dosap for dosap.
    define buffer doset for doset.
    define buffer dosdt for dosdt.
    define buffer apbco for apbco.

    empty temp-table ttCle.
    for each doset no-lock
        where doset.TpCon = {&TYPECONTRAT-mandat2Syndic} /* "01003" */
          and doset.nocon = piNoMdtIn
          and doset.nodos = piNoDosIn
          and doset.tpsur = "00001"                     /*--> sur immeuble */
      , each dosap no-lock
        where dosap.TpCon = doset.TpCon
          and dosap.NoCon = doset.nocon
          and dosap.NoDos = doset.nodos
          and dosap.noapp = piNoAppIn
      , each dosdt no-lock
        where dosdt.noidt = doset.noidt
          and dosdt.NoApp = dosap.noapp
          and dosdt.cdapp > "":
        find first ttCle
            where ttCle.cdcle = dosdt.cdapp no-error.
        if not available ttCle
        then do:
            create ttCle.
            ttCle.cdcle = dosdt.cdapp.
        end.
        ttCle.mtcle = ttCle.mtcle + dosdt.mtapp.
    end.

    for each apbco no-lock
        where apbco.tpbud = {&TYPEBUDGET-travaux} /* "01080" */
          and apbco.nobud = piNoMdtIn * 100000 + piNoDosIn
          and apbco.noapp = piNoAppIn
          and apbco.tpapp = {&TYPEAPPEL-dossierTravaux} /* "TX" */
          and apbco.cdcle <> "XX":                /* DM 1209/0082 */
        find first ttCle
            where ttCle.cdcle = apbco.cdcle no-error.
        if not available ttCle
        then do:
            create ttCle.
            ttCle.cdcle = apbco.cdcle.
        end.
        ttCle.mtcle_apbco = ttCle.mtcle_apbco + apbco.mtlot.
    end.
    for each ttCle
        where ttCle.mtcle <> ttCle.mtcle_apbco:
        if ttCle.cdcle > "" then plStop = true.
        create ttTmpErr.
        assign
            ttTmpErr.noerr    = 1
            ttTmpErr.nomdt    = piNoMdtIn
            ttTmpErr.nodos    = piNoDosIn
            ttTmpErr.noapp    = piNoAppIn
            ttTmpErr.lberr[1] = substitute("MANDAT : &1 DOSSIER : &2", string(piNoMdtIn, ">>>>9"), string(piNoDosIn, ">>9"))
            ttTmpErr.lberr[2] = "    APPEL N° : " + string(piNoAppIn, ">9")
            ttTmpErr.lberr[3] = "    CLE      : " + ttCle.cdcle
            ttTmpErr.lberr[4] = "    APPEL DE FONDS                     : " + string(ttCle.mtcle, "->,>>>,>>>,>>9.99")
            ttTmpErr.lberr[5] = "    DETAIL DES APPELS DE FONDS PAR LOT : " + string(ttCle.mtcle_apbco, "->,>>>,>>>,>>9.99")
        .
    end.

end procedure.

procedure Test_Apbco_cecrln_cop private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer trdos for trdos.
    define parameter buffer dosap for dosap.
    define input  parameter pdTotRepartition     as decimal no-undo extent 100.
    define output parameter plDiffApbcoCecrlnCop as logical no-undo.
    define output parameter plStop-Out           as logical no-undo.

    define variable vdTotEcrCop   as decimal no-undo.
    define variable vdTotApbcoCop as decimal no-undo.
    define variable vdSommeDiff   as decimal no-undo.
    define variable vlStop        as logical no-undo.

    for each ttCecrlnTst
        where ttCecrlnTst.noapp = dosap.noapp
        break by ttCecrlnTst.cpt-cd:

        if first-of (ttCecrlnTst.cpt-cd) then vdTotEcrCop = 0.

        vdTotEcrCop = vdTotEcrCop + (if ttCecrlnTst.sens then 1 else - 1) * ttCecrlnTst.mt.

        if last-of (ttCecrlnTst.cpt-cd) then do:
            assign
                vdTotEcrCop = vdTotEcrCop
                vdTotApbcoCop = 0
            .
            for each ttApbcoTst
                where ttApbcoTst.nocop = integer (ttCecrlnTst.cpt-cd)
                  and ttApbcoTst.noapp = ttCecrlnTst.noapp:
                vdTotApbcoCop = vdTotApbcoCop + ttApbcoTst.mtlot.
            end.
            if vdTotApbcoCop <> vdTotEcrCop
            then do:
                vdSommeDiff = vdSommeDiff + vdTotEcrCop - vdTotApbcoCop.
                if absolute (vdTotEcrCop - vdTotApbcoCop) > giSeuil then plDiffApbcoCecrlnCop = true.
                run Anomalie03(buffer dosap,
                               pdTotRepartition,
                               vdTotEcrCop,
                               vdTotApbcoCop,
                               trdos.nocon,
                               trdos.nodos,
                               ttCecrlnTst.noapp,
                               integer(ttCecrlnTst.cpt-cd),
                               output vlStop).
                if vlStop then plStop-Out = true.
            end.
        end.
    end.
    if plDiffApbcoCecrlnCop then do:
        run anomalie04(vdSommeDiff, trdos.nocon, trdos.nodos, dosap.noapp).
        plStop-Out = yes.
    end.

    for each ttApbcoTst
        where ttApbcoTst.noapp = dosap.noapp
        break by ttApbcoTst.nocop:

        if first-of (ttApbcoTst.nocop) then vdTotApbcoCop = 0.

        vdTotApbcoCop = vdTotApbcoCop + ttApbcoTst.mtlot.

        if last-of (ttApbcoTst.nocop) then do:
            vdTotEcrCop = 0.
            for each ttCecrlnTst
                where ttApbcoTst.nocop = integer (ttCecrlnTst.cpt-cd)
                  and ttApbcoTst.noapp = ttCecrlnTst.noapp:
                vdTotEcrCop = vdTotEcrCop + (if ttCecrlnTst.sens then 1 else - 1) * ttCecrlnTst.mt.
            end.
            vdTotEcrCop = vdTotEcrCop.
            if vdTotApbcoCop <> vdTotEcrCop
            then do:
                if absolute(vdTotEcrCop - vdTotApbcoCop) > giSeuil then plDiffApbcoCecrlnCop = true.
                run Anomalie03(buffer dosap,
                               pdTotRepartition,
                               vdTotEcrCop,
                               vdTotApbcoCop,
                               trdos.nocon,
                               trdos.nodos,
                               ttApbcoTst.noapp,
                               ttApbcoTst.nocop,
                               output vlStop).
                if vlStop then plStop-Out = true.
            end.
        end.
    end.

end procedure.

procedure Anomalie private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pdCumulApbco  as decimal   no-undo.
    define input  parameter pdCumulCecrln as decimal   no-undo.
    define input  parameter pcTpConIn     as character no-undo.
    define input  parameter piNoMdt       as integer   no-undo.
    define input  parameter piNoDos       as integer   no-undo.
    define input  parameter piNoApp       as integer   no-undo.
    define input  parameter piLoRep       as integer   no-undo.
    define output parameter plStop        as logical   no-undo.

    define variable vdArrondis as decimal no-undo.

    define buffer apbco for apbco.
    define buffer dosrp for dosrp.

    if absolute(pdCumulCecrln - pdCumulApbco) >= giSeuil
    then do:
        create ttTmpErr.
        assign
            plStop            = true
            ttTmpErr.noerr    = 1
            ttTmpErr.nomdt    = piNoMdt
            ttTmpErr.nodos    = piNoDos
            ttTmpErr.noapp    = piNoApp
            ttTmpErr.lberr[1] = substitute("MANDAT : &1 DOSSIER : &2", string(piNoMdt, ">>>>9"), string(piNoDos, ">>9"))
            ttTmpErr.lberr[2] = "    APPEL N° : " + string(piNoApp, ">9")
            ttTmpErr.lberr[3] = "    DIFFERENCE ENTRE LE DETAIL DES APPELS DE FONDS PAR LOT ET LA COMPTABILISATION !"
            ttTmpErr.lberr[4] = "    DETAIL DES APPELS DE FONDS PAR LOT : " + string(pdCumulApbco, "->,>>>,>>>,>>9.99")
            ttTmpErr.lberr[5] = "    COMPTABILISATION                   : " + string(pdCumulCecrln, "->,>>>,>>>,>>9.99")
        .
    end.
    else do:
        /** Gestion des reliquats **/
        /** Ce cas de figure apparait sur les vieux appels quand APBCO n'a pas été créé au moment de l'appel:
        D'oû une différence entre la comptabilisation et la répartition au  lot **/
        vdArrondis = pdCumulCecrln - pdCumulApbco.
        find first dosrp no-lock
            where dosrp.tpcon = pcTpConIn
              and dosrp.nocon = piNoMdt
              and dosrp.nodos = piNoDos
              and dosrp.nolot = piLoRep
              and dosrp.porep <> 0 no-error.
        if available dosrp
        then do:
            {&_proparse_ prolint-nowarn(nowait)}
            find first apbco exclusive-lock
                where apbco.tpbud = gcTypeBudget
                  and apbco.nobud = giNumeroBudget
                  and apbco.nomdt = piNoMdt
                  and apbco.noimm = giNumeroImmeuble
                  and apbco.noapp = piNoApp
                  and apbco.nocop = dosrp.nocop
                  and apbco.nolot = dosrp.nolot no-error.
            {&_proparse_ prolint-nowarn(nowait)}
            if not available apbco
            then find first apbco exclusive-lock
                where apbco.tpbud = gcTypeBudget
                  and apbco.nobud = giNumeroBudget
                  and apbco.nomdt = piNoMdt
                  and apbco.noimm = giNumeroImmeuble
                  and apbco.noapp = piNoApp
                  and apbco.nocop = dosrp.nocop no-error.
            {&_proparse_ prolint-nowarn(nowait)}
            if not available apbco
            then find first apbco exclusive-lock
                where apbco.tpbud = gcTypeBudget
                  and apbco.nobud = giNumeroBudget
                  and apbco.nomdt = piNoMdt
                  and apbco.noimm = giNumeroImmeuble
                  and apbco.noapp = piNoApp no-error.
            if available apbco then apbco.mtlot = apbco.mtlot + vdArrondis.
        end.
        else do:
            create ttTmpErr.
            assign
                plStop            = true
                ttTmpErr.noerr    = 2
                ttTmpErr.nomdt    = piNoMdt
                ttTmpErr.nodos    = piNoDos
                ttTmpErr.noapp    = piNoApp
                ttTmpErr.lberr[1] = substitute("MANDAT : &1 DOSSIER : &2", string(piNoMdt, ">>>>9"), string(piNoDos, ">>9"))
                ttTmpErr.lberr[2] = "    SAISIR LE LOT SUR LEQUEL ON REPERCUTE LES ARRONDIS !"
            .
        end.
    end.

end procedure.

procedure Anomalie01 private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pdCumulAppel as decimal no-undo.
    define input parameter pdCumulApbco as decimal no-undo.
    define input parameter piNoMdt      as integer no-undo.
    define input parameter piNoDos      as integer no-undo.
    define input parameter piNoApp      as integer no-undo.
    define output parameter plStop      as logical no-undo.

    if absolute (pdCumulAppel - pdCumulApbco) >= 1
    then do:
        create ttTmpErr.
        assign
            plStop            = true
            ttTmpErr.noerr    = 1
            ttTmpErr.nomdt    = piNoMdt
            ttTmpErr.nodos    = piNoDos
            ttTmpErr.noapp    = piNoApp
            ttTmpErr.lberr[1] = substitute("MANDAT : &1 DOSSIER : &2", string(piNoMdt, ">>>>9"), string(piNoDos, ">>9"))
            ttTmpErr.lberr[2] = "    APPEL N° : " + string(piNoApp, ">9")
            ttTmpErr.lberr[3] = "    DIFFERENCE ENTRE LE DETAIL DES APPELS DE FONDS PAR LOT ET L'APPEL DE FONDS !"
            ttTmpErr.lberr[4] = "    DETAIL DES APPELS DE FONDS PAR LOT : " + string(pdCumulApbco, "->,>>>,>>>,>>9.99")
            ttTmpErr.lberr[5] = "    APPEL DE FONDS                     : " + string(pdCumulAppel, "->,>>>,>>>,>>9.99")
        .
    end.

end procedure.

procedure Anomalie03 private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer dosap for dosap.
    define input parameter  pdTotRepartition as decimal no-undo extent 100.
    define input parameter  pdCumulAppel     as decimal no-undo.
    define input parameter  pdCumulApbco     as decimal no-undo.
    define input parameter  piNoMdt          as integer no-undo.
    define input parameter  piNoDos          as integer no-undo.
    define input parameter  piNoApp          as integer no-undo.
    define input parameter  piNoCop          as integer no-undo.
    define output parameter plStop-Out       as logical no-undo.

    if can-find(first ttTmpErr
        where ttTmpErr.noerr = 3
          and ttTmpErr.nomdt = piNoMdt
          and ttTmpErr.nodos = piNoDos
          and ttTmpErr.noapp = piNoApp
          and ttTmpErr.lberr[1] = substitute("MANDAT : &1 DOSSIER : &2 APPEL N° : &3 COPROPRIETAIRE : &4"
                                           , string(piNoMdt, ">>>>9"), string(piNoDos, ">>9"), string(piNoApp, ">9"), string(piNoCop, "99999")))
    then return.

    find first ttReguleTmp
        where ttReguleTmp.tpbud = {&TYPEBUDGET-travaux}
          and ttReguleTmp.nobud = giNumeroBudget
          and ttReguleTmp.tpapp = {&TYPEAPPEL-dossierTravaux}
          and ttReguleTmp.noapp = dosap.noapp
          and ttReguleTmp.dtapp = dosap.dtapp
          and ttReguleTmp.nomdt = dosap.nocon
          and ttReguleTmp.noimm = giNumeroImmeuble
          and ttReguleTmp.nocop = piNoCop no-error.
    if not available ttReguleTmp
    then do:
        create ttReguleTmp.
        assign
            ttReguleTmp.tpbud     = {&TYPEBUDGET-travaux}
            ttReguleTmp.nobud     = giNumeroBudget
            ttReguleTmp.tpapp     = {&TYPEAPPEL-dossierTravaux}
            ttReguleTmp.noapp     = dosap.noapp
            ttReguleTmp.dtapp     = dosap.dtapp
            ttReguleTmp.typapptrx = ""
            ttReguleTmp.cdcle     = ""
            ttReguleTmp.noord     = 0
            ttReguleTmp.nomdt     = dosap.nocon
            ttReguleTmp.noimm     = giNumeroImmeuble
            ttReguleTmp.nolot     = 0
            ttReguleTmp.nocop     = piNoCop
            ttReguleTmp.mttot     = pdTotRepartition[dosap.noapp] /** dosap.mttot **/
            ttReguleTmp.dtcsy     = today
            ttReguleTmp.hecsy     = 1
            ttReguleTmp.cdcsy     = mToken:cUser + "@apatcx.p"
            ttReguleTmp.mtlot     = pdCumulAppel - pdCumulApbco
            ttReguleTmp.tvlot     = 0
            ttReguleTmp.lbdiv     = "REGUL DETAIL PAR LOT ET PAR CLE : apatcx.p"
            ttReguleTmp.dtmsy     = ttReguleTmp.dtcsy
            ttReguleTmp.hemsy     = ttReguleTmp.hecsy
            ttReguleTmp.cdmsy     = ttReguleTmp.cdcsy
            ttReguleTmp.dtems     = today
        .
    end.

    if absolute(pdCumulAppel - pdCumulApbco) >= giSeuil
    then do:
        /** Appel en anômalie **/
        find first ttDosapTmp
            where ttDosapTmp.nocon = piNoMdt
              and ttDosapTmp.nodos = piNoDos
              and ttDosapTmp.noapp = piNoApp no-error.
        if not available ttDosapTmp
        then do:
            create ttDosapTmp.
            buffer-copy dosap to ttDosapTmp.
        end.
        create ttTmpErr.
        assign
            plStop-Out        = true
            ttTmpErr.noerr    = 3
            ttTmpErr.nomdt    = piNoMdt
            ttTmpErr.nodos    = piNoDos
            ttTmpErr.noapp    = piNoApp
            ttTmpErr.lberr[1] = substitute("MANDAT : &1 DOSSIER : &2 APPEL N° : &3 COPROPRIETAIRE : &4"
                                         , string(piNoMdt, ">>>>9"), string(piNoDos, ">>9"), string(piNoApp, ">9"), string(piNoCop, "99999"))
            ttTmpErr.lberr[2] = "    DIFFERENCE ENTRE LE DETAIL DES APPELS DE FONDS PAR LOT ET L'APPEL DE FONDS (COMPTABILISATION) AU NIVEAU DU COPROPRIETAIRE!"
            ttTmpErr.lberr[3] = "    DETAIL DES APPELS DE FONDS PAR LOT : " + string(pdCumulApbco, "->,>>>,>>>,>>9.99")
            ttTmpErr.lberr[4] = "    APPEL DE FONDS                     : " + string(pdCumulAppel, "->,>>>,>>>,>>9.99")
            ttTmpErr.lberr[5] = "    DIFFERENCE                         : " + string(pdCumulAppel - pdCumulApbco, "->,>>>,>>>,>>9.99")
        .
    end.

end procedure.

procedure Anomalie04 private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pdSommeDiff as decimal no-undo.
    define input parameter piNoMdt as integer no-undo.
    define input parameter piNoDos as integer no-undo.
    define input parameter piNoApp as integer no-undo.

    if can-find(first ttTmpErr
        where ttTmpErr.noerr = 4
          and ttTmpErr.nomdt = piNoMdt
          and ttTmpErr.nodos = piNoDos
          and ttTmpErr.noapp = piNoApp
          and ttTmpErr.lberr[1] = substitute("MANDAT : &1 DOSSIER : &2 APPEL N° : &3", string(piNoMdt, ">>>>9"), string(piNoDos, ">>9"), string(piNoApp, ">9")))
    then return.

    create ttTmpErr.
    assign
        ttTmpErr.noerr    = 4
        ttTmpErr.nomdt    = piNoMdt
        ttTmpErr.nodos    = piNoDos
        ttTmpErr.noapp    = piNoApp
        ttTmpErr.lberr[1] = substitute("MANDAT : &1 DOSSIER : &2 APPEL N° : &3", string(piNoMdt, ">>>>9"), string(piNoDos, ">>9"), string(piNoApp, ">9"))
        ttTmpErr.lberr[2] = "    SOMME DES DIFFERENCES ENTRE LE DETAIL DES APPELS DE FONDS PAR LOT ET L'APPEL DE FONDS AU NIVEAU DES COPROPRIETAIRES :"
        ttTmpErr.lberr[3] = "    SOMME DES DIFFERENCES  : " + string(pdSommeDiff, "->,>>>,>>>,>>9.99")
    .
end procedure.

procedure annulation_avec_apbco private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes: DM 0209/0018
    ------------------------------------------------------------------------------*/
    define parameter buffer trdos for trdos.

    define variable vdCumul       as decimal   no-undo.
    define variable vdCumulTva    as decimal   no-undo.
    define variable vdCumuMtAppel as decimal   no-undo.
    define variable vdCumulMtTva  as decimal   no-undo.
    define variable vcCptCtp      as character no-undo.

    define buffer apbco for apbco.

    vcCptCtp = if integer(trdos.tpurg) = 0 then "702100" else "702200".
    for each ttApbcoTmp
        break by ttApbcoTmp.noapp
              by ttApbcoTmp.nocop
              by ttApbcoTmp.cdcle
              by ttApbcoTmp.nolot:

        if first-of(ttApbcoTmp.nocop) then assign
            vdCumul       = 0
            vdCumulTva    = 0
            vdCumuMtAppel = 0 /* JPM 0115/0119 */
        .
        /* remettre à jour ttApbcoTmp.tvlot (tva) car erroné après sortie de prorata.i */
        vdCumulMtTva = 0.
        for each apbco no-lock
            where apbco.tpbud = ttApbcoTmp.tpbud
              and apbco.nobud = ttApbcoTmp.nobud
              and apbco.tpapp = ttApbcoTmp.tpapp
              and apbco.noapp = ttApbcoTmp.noapp
              and apbco.nocop = ttApbcoTmp.nocop
              and apbco.noimm = ttApbcoTmp.noimm
              and apbco.nolot = ttApbcoTmp.nolot
              and apbco.cdcle = ttApbcoTmp.cdcle:
            vdCumulMtTva = vdCumulMtTva + apbco.tvlot.
        end.
        assign
            ttApbcoTmp.tvlot = vdCumulMtTva
            vdCumul          = vdCumul    + ttApbcoTmp.mtlot
            vdCumulTva       = vdCumulTva + ttApbcoTmp.tvlot
        .
        if first-of(ttApbcoTmp.cdcle) and first-of(ttApbcoTmp.nolot)
        then for each apbco no-lock
            /* JPM suite fiche 0115/0119 le 11/02/2016:  pas de fiche mais document remis par E Guidoux (04139 09079 APTRX 1901)
               il faut faire cette boucle car ttApbcoTmp résulte d'un cumul (prorata.i) et il peut y avoir 2 dépenses sur la même clé
            */
            where apbco.tpbud = ttApbcoTmp.tpbud
              and apbco.nobud = ttApbcoTmp.nobud
              and apbco.tpapp = ttApbcoTmp.tpapp
              and apbco.noapp = ttApbcoTmp.noapp
              and apbco.nocop = ttApbcoTmp.nocop
              and apbco.noimm = ttApbcoTmp.noimm
              and apbco.nolot = ttApbcoTmp.nolot
              and apbco.cdcle = ttApbcoTmp.cdcle
              and apbco.typapptrx = ttApbcoTmp.typapptrx:     /* SY 0816/0049 */
            vdCumuMtAppel = vdCumuMtAppel + apbco.mttot. /* JPM 0115/0119 */
        end.

        if last-of(ttApbcoTmp.nocop) then do:
            create ttEcrApat.
            assign
                vdCumuMtAppel          = - vdCumuMtAppel  /* JPM 0115/0119 */
                ttEcrApat.cpt-cd       = string(ttApbcoTmp.nocop,"99999")
                ttEcrApat.numtrait     = string(trdos.nodos,"99") + STRING(ttApbcoTmp.noapp,"99")
                ttEcrApat.mt           = absolute(vdCumul)
                ttEcrApat.SigneMt      = (if vdCumul >= 0 then "+" else "-")
                ttEcrApat.cpt-ctp      = vcCptCtp
                ttEcrApat.mtappel      = absolute(vdCumuMtAppel)  /* JPM 0115/0119 */
                ttEcrApat.SigneMtAppel = (if vdCumuMtAppel >= 0 then "+" else "-")
                ttEcrApat.mttva        = vdCumulTva
            .
        end.
    end.

end procedure.
