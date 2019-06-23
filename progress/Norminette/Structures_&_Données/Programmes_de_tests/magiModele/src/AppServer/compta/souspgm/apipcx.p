/*------------------------------------------------------------------------
File        : apipcx.p
Purpose     : Traitement des APIP pour cloture travaux
Author(s)   : AF - 2005/02/09;  gga  -  2017/04/07
Notes       : reprise du pgm trans\src\gene\apipcx.p

01 | 18/07/2005 |  AF  | Pas d'envoie appel à zero meme pour le lot de recuperation d'arrondi
02 | 08/11/2005 |  DM  | 0505/0074 Nouveau plan comptable
03 | 27/02/2006 |  JR  | 0206/0422 Sens des dépenses non-géré
04 | 07/03/2006 |  JR  | 0306/0131 Debug de 0206/0422
   |            |      | Dans le cas d'un remboursement de dépenses: Gestion des sens pour la Repercution d'arrondi
05 | 04/07/2006 |  JR  | 0606/0196 : dans l'article APIP était envoyé en dur 6710 (analytique 110 260)
   |            |      | quelque soit la nature du dossier et quelque soit les dépenses
06 | 11/09/2006 |  JR  | 0906/0037
07 | 13/11/2006 |  SY  | 1106/0063: dans l'article APIP était envoyé en dur la clé "IP" au lieu de la clé d'imput.
08 | 01/03/2007 |  OF  | 0207/0444 On borne la date de fin à la fin de mois au lieu de la date du jour
09 | 21/03/2007 |  JR  | 0307/0182 On borne la date de fin à la fin de l'exercice N° 2 Pour prendre large et ainsi avoir toutes les écritures du dossier
10 | 24/05/2007 |  DM  | 0706/0310 Article APEM appels emprunts
11 | 09/11/2007 |  DM  | 0907/0182 Cloture APEM
12 | 09/11/2007 |  NP  | 1007/0022 Remplacement GiCodeSoc par NoRefCop
19 | 19/11/2007 |  DM  | 0706/0310 MtTot non assigné
20 | 20/11/2007 |  DM  | 0706/0310 annulation emprunt/subvention
21 | 07/02/2008 |  JR  | 0208/0022
   |            |      | 1. Pour la cloture, il ne faut pas arrondir les montants répartis. Cet appel solde les comptes.
   |            |      | Si les montants à répartir sont arrondis, le dossier ne sera jamais soldé. La fonction Arrondir n'est valable que pour les appels de fonds.
   |            |      | 2.Mauvaise gestion du lot de répercussion des arrondis
22 | 27/02/2008 |  OF  | 0208/0300 Pb de signe dans le formatage
23 | 21/03/2008 |  DM  | 0308/0201 Pb de totalisation montants signés
24 | 26/03/2008 |  DM  | 0208/0368 Controle cloture travaux
25 | 19/05/2008 |  SY  | 0408/0240 Gestion dossier sans répartition A/V  (pas de dosrp) dans depenses et NoLot_Par_Defaut
26 | 03/06/2008 |  SY  | 0608/0033 même modif que ci-dessus pour les IP
27 | 05/06/2008 |  OF  | 0608/0033 Pb Signe + Arrondi + fichier .lg
28 | 16/06/2008 |  DM  | 0508/0129 compte emprunt
29 | 20/06/2008 |  SY  | 0306/0215 : Ajout creation apbco CX avec total APIP par clé/copro/lot
30 | 23/06/2008 |  SY  | 0306/0215 : maj zone apbco.dtems
31 | 23/07/2008 |  RF  | 0306/0215:bascule des soldes CHB (tx lot 3)
32 | 04/09/2009 |  JR  | 0909/0004
33 | 15/01/2010 |  OF  | 0110/0133 Pb Arrondi géré différemment entre les appels et la récupération des IP
34 | 16/07/2010 | JPM  | Ajout procedure Chargembap pour édition locale des appels de fonds
35 | 17/11/2010 |  DM  | 1010/0244 Pb cloture travaux avec emprunt
36 | 22/02/2012 | JPM  | 1009/0001 Transfert de la quote part TVA via nouvel article API2 (suite APIP)
37 | 28/11/2012 |  OF  | 1112/0138 Pb signe suite modif précédente
38 | 20/02/2013 |  SY  | 0911/0112 table tempo en include ttTmpSld.i
39 | 06/02/2015 |  SY  | Optimisation index milli
40 | 25/02/2015 |  OF  | Perte du GiCodeSoc chez Dauchez (devient 3073)
41 | 13/07/2015 |  NP  | 0715/0032 Pb recalcul tva avec add article API2 pour les imputations + gestion tva du lot qui a l'arrondi                                       |
42 | 04/12/2015 |  OF  | 1115/0265 Pb mttva = ?
43 | 05/02/2016 |  SY  | 0216/0043 Correction Pb APCX pour les IP il manquait l'info "QPT"
44 | 23/06/2016 |  NP  | 0616/0192 Gestion de plus de 99 lignes APIP-CX
----------------------------------------------------------------------*/
{preprocesseur/typeAppel.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/typeAppel2fonds.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

message "chargement apipcx.p".

define stream sFichier.

{application/include/glbsepar.i}
{compta/include/tbTmpSld.i}
{compta/include/tbartappels.i}                      /*gga todo voir info dans include */
{compta/include/TbTmpAna.i}

{compta/include/defligne.i}

define temp-table ttTmpCop no-undo           // Nombre d'appel par coproprietaire lot
    field NoCop as integer
    field NoLot as integer
    field CdCle as character
    field NbApp as integer
index primaire nocop nolot cdcle.

define temp-table ttTmpApp no-undo           // Table temporaire appel de fond DM 0706/0310
    field NoLig as integer
    field FgHon as logical
    field FgDer as logical
    field NoCtt as character
    field TpApp as character
    field NoCop as character
    field NoLot as character
    field CdCle as character
    field LbApp as character
    field MtApp as character
    field SgApp as character
    field NoCpt as character
    field NbLig as character
    field MtTva as character
    field NbApp as character
    field SsCpt as character
    field MtTot as character
    field SgTot as character
    field NbPar as character
    field NbTot as character
    field LbEnt as character
    field LbFil as character
    field NoOrd as integer
.
define temp-table ttTmpTot no-undo
    field tpapp  as integer
    field mt-tot as decimal
.
define temp-table ttTmpapbco no-undo like apbco
    index primaire tpbud nobud tpapp noapp noimm nolot cdcle noord nocop
.

define variable giNoAppUse             as integer   no-undo.
define variable gdaDtAppUse            as date      no-undo.
define variable giNumeroImmeuble       as integer   no-undo.
define variable giNumeroMandat         as integer   no-undo.
define variable giNumeroDossierTravaux as integer   no-undo.
define variable giRefCopro             as integer   no-undo.
define variable giLgCpt                as integer   no-undo.
define variable giLgCum                as integer   no-undo.
define variable gdMtAppTot             as decimal   no-undo.
define variable gdMtTvaTot             as decimal   no-undo.
define variable giNoRefTrans           as integer   no-undo.
define variable glTest                 as logical   no-undo.
define variable gdMontantTotOut        as decimal   no-undo.

procedure apipcxPrepaControle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par ctrltrav.p
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.
    define input-output parameter table for ttTmpSld.
    define output parameter plRetourOk  as logical no-undo.
    define output parameter pdMtTotOut  as decimal no-undo.

    /*gga plus utilise on est toujours en mode apres bascule avec date >= isoc.dat-decret
    {dadecret.i INT(NoRefCop)}     gga*/

    define variable vhProc    as handle no-undo.
    define variable vcFichier as character no-undo.

    define buffer ietab for ietab.
    define buffer intnt for intnt.
    define buffer trfev for trfev.
    define buffer trdos for trdos.
    define buffer apbco for apbco.

message "gga apipcx.p 01 ".

    assign
        giNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        giNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        giNoRefTrans           = poCollection:getInteger("iNoRefTrans")
        glTest                 = poCollection:getLogical("lTest")
        vcFichier              = poCollection:getCharacter("cFichier")
        giRefCopro             = integer(mToken:cRefCopro)
    .

message "gga apipcx.p debut traitement " vcFichier "//" mToken:cRefCopro "//" giNumeroMandat "//" giNumeroDossierTravaux "//" giNoRefTrans "//" giRefCopro.

    find first ietab no-lock
        where ietab.soc-cd  = giRefCopro
          and ietab.etab-cd = giNumeroMandat no-error.
    if not available ietab
    then do:
        mError:createError({&error}, "table ietab inexistante (gga todo a revoir impossible)").
        return.
    end.
    assign
        giLgCpt = ietab.lgcpt
        giLgCum = ietab.lgcum
    .

message "gga apipcx.p avant appel extraihb.p ".

    poCollection:set('dtDatFin', ietab.dafinex2) no-error.
    poCollection:set('cCpt', "670000000") no-error.
    run compta/souspgm/extraihb.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run extraihbExtraitAnalytique in vhProc (poCollection, output table tmp-ana by-reference).
    run destroy in vhProc.

    message "gga apipcx.p apres appel extraihb.p ".

    /*--> Recherche de l'immeuble */
    find first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic} /* "01003" */
          and intnt.nocon = giNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble} /* "02001" */ no-error.
    if not available intnt
    then do:
        mError:createError({&error}, "table intnt inexistante (gga todo a revoir impossible)").
        return.
    end.
    giNumeroImmeuble = intnt.noidt.
    output stream sFichier to value(vcFichier).
    /*--> Information dossier */
    for first trdos no-lock
        where trdos.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and trdos.nocon = giNumeroMandat
          and trdos.nodos = giNumeroDossierTravaux:
        /** 0306/0215 **/
        for first trfev no-lock
            where trfev.tptrf = {&TYPETRANSFERT-appel}
              and trfev.nomdt = giNumeroMandat
              and trfev.tpapp = {&TYPEAPPEL-clotureTravaux}
              and trfev.noexe = giNumeroDossierTravaux:
            assign
                giNoAppUse  = trfev.noapp
                gdaDtAppUse = trfev.dtapp
            .
        end.
        if glTest = false
        then for each apbco exclusive-lock
            where apbco.tpbud = {&TYPEBUDGET-travaux}
              and apbco.nobud = trdos.nocon * 100000 + trdos.nodos
              and apbco.tpapp = {&TYPEAPPEL-clotureTravaux} /* "CX" */
              and apbco.nomdt = trdos.nocon:
            delete apbco.
        end.
        empty temp-table ttTmpapbco.
        run depenses(buffer trdos).                            // ANALYTIQUE
        run entetes_Imputations_Particulieres(buffer trdos).   // CLE RECUPERATION ANALYTIQUE
        run details_Imputations_Particulieres(trdos.nocon * 100000 + trdos.nodos). //IMPUTATION PARTICULIERE
        run emprunts(buffer trdos).                            // EMPRUNTS/SUBVENTIONS/INDEMNITES, DM 0706/0310
        if glTest = false then run majDetailLotCopro.
    end.

    message "gga apipcx.p avant writfich.i "  gdMontantTotOut "//" glTest.

    /**Ajout OF le 05/06/08 - Pour mettre les lignes restantes dans le fichier  **/
    if glTest then run ecrLigneSurFichier.
    /* RF 0306/0215 - LOT 3 - appel cloture par copro pour éventuelle od de solde                     */
    if glTest then for each ttTmpapbco
        by ttTmpapbco.nomdt
        by ttTmpapbco.nocop:
        find first ttTmpSld
            where ttTmpSld.nomdt = ttTmpapbco.nomdt
              and ttTmpSld.nocop = ttTmpapbco.nocop no-error.
        if not available ttTmpSld
        then do:
            create ttTmpSld.
            assign
                ttTmpSld.nomdt = ttTmpapbco.nomdt
                ttTmpSld.nocop = ttTmpapbco.nocop
            .
        end.
        ttTmpSld.mtappcx = ttTmpSld.mtappcx + ttTmpapbco.mtlot.
    end.
    output stream sFichier close.

message "gga apipcx.p fin traitement " gdMontantTotOut.

    assign
        plRetourOk = yes
        pdMtTotOut = gdMontantTotOut
    .
end procedure.

function Formatage return character (pdMntIn as decimal, piDec as integer, piNbChar as integer):
    /*------------------------------------------------------------------------------
     Purpose: renvoit la chaine 12345- pour
     Notes:
    ------------------------------------------------------------------------------*/
    define variable vcDecimal as character no-undo.
    define variable vcMntOut  as character no-undo.

    assign
        pdMntIn   = absolute(pdMntIn)
        vcDecimal = string(pdMntIn, ">>>,>>>,>>>,>99.999999999")
        vcDecimal = entry(2, vcDecimal, if session:numeric-format = "EUROPEAN" then "," else ".")
        vcDecimal = substring(vcDecimal, 1, piDec, 'character')
        vcMntOut  = string(truncate(pdMntIn, 0))
        vcMntOut  = vcMntOut + vcDecimal
        vcMntOut  = string(decimal(vcMntOut), "99999999999999" )
        vcMntOut  = substring(vcMntOut, 15 - piNbChar, piNbChar, 'character')
    .
    return vcMntOut.

end function.

function formatageSignePlus return character (pdMntIn as decimal, piDec as integer, piNbChar as integer):
    /*------------------------------------------------------------------------------
     Purpose: renvoit la chaine 12345- pour
     Notes:
    ------------------------------------------------------------------------------*/
    return formatage(pdMntIn, piDec, piNbChar) + (if pdMntIn >= 0 then "+" else "-").

end function.

function formatageSigneMoins return character (pdMntIn as decimal, piDec as integer, piNbChar as integer):
    /*------------------------------------------------------------------------------
     Purpose: renvoit la chaine 12345- pour
     Notes:
    ------------------------------------------------------------------------------*/
    return formatage(pdMntIn, piDec, piNbChar) + (if pdMntIn >= 0 then "-" else "+").

end function.

/*gga plus utilise
/*==A R R O N D I R========================================================================================================*/
function Arrondir return decimal(MtAppUse as decimal,TpArrUse as character,CdArrUse as character):
    define variable LbTmpPdt as character no-undo.
    define variable CpUseInc as integer   no-undo.

    case TpArrUse:
        when "00001" then case CdArrUse:                         /*--> Tronqué */
            when "00001" then MtAppUse = truncate(MtAppUse,2).   /*--> centime */
            when "00002" then MtAppUse = truncate(MtAppUse,0).   /*--> unite */
            when "00003" then assign                             /*--> dizaine */
                LbTmpPdt = string(INT(MtAppUse))
                LbTmpPdt = substring(LbTmpPdt,1,length(LbTmpPdt) - 1) + "0"
                MtAppUse = integer(LbTmpPdt).
            when "00004" then assign                             /*--> centaine */
                LbTmpPdt = string(INT(MtAppUse))
                LbTmpPdt = substring(LbTmpPdt,1,length(LbTmpPdt) - 2) + "00"
                MtAppUse = integer(LbTmpPdt).
            when "00005" then assign                              /*--> millier */
                LbTmpPdt = string(INT(MtAppUse))
                LbTmpPdt = substring(LbTmpPdt,1,length(LbTmpPdt) - 3) + "000"
                MtAppUse = integer(LbTmpPdt).
        end case.
        when "00002" then case CdArrUse:                         /*--> Arrondi */
            when "00001" then MtAppUse = round(MtAppUse,2).      /*--> centime */
            when "00002" then MtAppUse = round(MtAppUse,0).      /*--> unite */
            when "00003" then assign                             /*--> dizaine */
                MtAppUse = integer(MtAppUse)
                LbTmpPdt = string(MtAppUse)
                CpUseInc = integer(substring(LbTmpPdt,length(LbTmpPdt),1))
                MtAppUse = MtAppUse + (if CpUseInc > 5 then 10 else 0) - CpUseInc .
            when "00004" then do:                                 /*--> centaine */
                assign
                    MtAppUse = integer(MtAppUse)
                    LbTmpPdt = string(MtAppUse).
                if length(LbTmpPdt) > 2 then assign
                    CpUseInc = integer(substring(LbTmpPdt,length(LbTmpPdt)- 1,2))
                    MtAppUse = MtAppUse + (if CpUseInc > 50 then 100 else 0) - CpUseInc.
            end.
            when "00005" then do:                                  /*--> millier */
                assign
                    MtAppUse = integer(MtAppUse)
                    LbTmpPdt = string(MtAppUse).
                if length(LbTmpPdt) > 3 then assign
                    CpUseInc = integer(substring(LbTmpPdt,length(LbTmpPdt)- 2,3))
                    MtAppUse = MtAppUse + (if CpUseInc > 500 then 1000 else 0) - CpUseInc.
            end.
        end case.
    end.
    return MtAppUse.
end.
gga*/

/*==M T T V A==============================================================================================================*/
/*--> Calcul d'un montant de tva à partir du montant TTC et du code tva utilisé */

/*gga plus utilise appel tva.p
/*FUNCTION MtTva RETURN DECIMAL(MtTtcUse AS DECIMAL,CdTvaUse AS INTEGER)*/ /**Modif OF le 22/08/11**/
function MtTva return decimal(MtTtcUse as decimal,CdTvaUse as integer, MtPrcTva as decimal):
    define variable MtRetUse as decimal no-undo.

    /**Ajout OF le 04/12/15 - Pour éviter les divisions par zéro**/
    if MtPrcTva = ? then return 0.
    if CdTvaUse = 9 and MtPrcTva = 0 then return 0.
    /** **/
    find itaxe where itaxe.soc-cd = /*gga INT(NoRefCop) gga*/ GiCodeSoc
        and itaxe.taxe-cd = CdTvaUse no-lock no-error.
    /*IF AVAILABLE itaxe THEN
    MtRetUse =  MtTtcUse - (MtTtcUse / (100 + itaxe.Taux) * 100).*/ /**Modif OF le 22/08/11**/
    if available itaxe and itaxe.taxe-cd ne 9
    then MtRetUse = MtTtcUse - ROUND(MtTtcUse / (100 + itaxe.Taux) * 100,2).
    else MtRetUse = round(MtTtcUse / MtPrcTva,2).
    return MtRetUse.
end.
gga*/

procedure depenses private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer trdos for trdos.

    define variable vcAnalytique as character no-undo.
    define variable vcCpt        as character no-undo.
    define variable vlSensDep    as logical   no-undo.
    define variable vdMtAppRep   as decimal   no-undo.
    define variable vdMtAppTva   as decimal   no-undo.
    define variable vcSigne      as character no-undo format "(x)".
    define variable vdMtQpTva    as decimal   no-undo.
    define variable viNoCopRep   as integer   no-undo.
    define variable viNoLotRep   as integer   no-undo.
    define variable viNbLigLib   as integer   no-undo.
    define variable viNoconNodos as integer   no-undo.
    define variable vi           as integer   no-undo.

    define buffer alrub for alrub.
    define buffer dosrp for dosrp.
    define buffer intnt for intnt.
    define buffer clemi for clemi.
    define buffer milli for milli.
    define buffer local for local.
    define buffer ctrat for ctrat.

    viNoconNodos = trdos.nocon * 100000 + trdos.nodos.
    for each tmp-ana:                        /*--> Parcours des Analytiques */
/*gga on est toujours en mode apres bascule
        /** 0606/0196  **/
        if not ApresBascule(input giNumeroMandat, input /** tmp-ana.datecr 0906/0037 **/ agest.dadeb)
        then do:
            if trdos.tpurg = "00000"
            then vcCpt = "671000000".
            else if trdos.tpurg = "00001" then vcCpt = "672000000".
            vcAnalytique = tmp-ana.rub-cd + tmp-ana.ssrub-cd + tmp-ana.fisc.
        end.
        else do:
            find first alrub
                where alrub.soc-cd = piGicodeSoc
                and alrub.rub-cd   = tmp-ana.rub-cd
                and alrub.ssrub-cd = tmp-ana.ssrub-cd
                no-lock no-error.
            assign
                vcCpt        = alrub.cpt-cd + fill("0",giLgCpt - LENGTH(alrub.cpt-cd))
                vcAnalytique = alrub.rub-cd + alrub.ssrub-cd + tmp-ana.fisc.
        end.
gga*/
        for first alrub no-lock
            where alrub.soc-cd   = giRefCopro
              and alrub.rub-cd   = tmp-ana.rub-cd
              and alrub.ssrub-cd = tmp-ana.ssrub-cd:
            assign
                vcCpt        = alrub.cpt-cd + fill("0", giLgCpt - length(alrub.cpt-cd, 'character'))
                vcAnalytique = alrub.rub-cd + alrub.ssrub-cd + tmp-ana.fisc
            .
        end.
        /*--> Initialisation du montant total de l'appel */
        assign
            gdMtAppTot = 0
            gdMtTvaTot = 0
            viNbLigLib = 0
        .
        /*--> On calcul le nombre de ligne de libelle */
boucle:
        do vi = 1 to 9:
            if tmp-ana.lib-ecr[vi] = ? or tmp-ana.lib-ecr[vi] = "" then leave boucle.
            viNbLigLib = viNbLigLib + 1.
        end.
        /*--> Lot de répercussions des arrondis : 0208/0022*/
        run noLot_Par_Defaut (trdos.nocon, trdos.nodos, giNumeroImmeuble, tmp-ana.cle, trdos.lorep, output viNoLotRep, output viNoCopRep).

        /*--> pour chaque lot de la clé de repartition, je recherche la repartition achat / vente */
        for first clemi no-lock
            where clemi.noimm = giNumeroImmeuble
              and clemi.cdcle = tmp-ana.cle
          , each milli no-lock
            where milli.noimm = giNumeroImmeuble
              and milli.cdcle = clemi.cdcle
          , first local no-lock
            where local.noimm = milli.noimm
              and local.nolot = milli.nolot:
            /* Modif SY le 16/05/2008 : si la répartition exite pour le Dossier travaux on la prend */
            /*                          sinon : dernier copro du lot                                */
            find first dosrp no-lock
                where dosrp.tpcon = {&TYPECONTRAT-mandat2Syndic} /* "01003" */
                  and dosrp.nocon = giNumeroMandat
                  and dosrp.nodos = giNumeroDossierTravaux
                  and dosrp.nolot = milli.nolot
                  and dosrp.porep <> 0 no-error.
            if not available dosrp
            then for last intnt no-lock
                where intnt.tpidt = "02002"
                  and intnt.noidt = local.NoLoc
                  and intnt.tpcon = "01004"
                  and intnt.nbden = 0
              , first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                  and ctrat.nocon = intnt.nocon
                  and (ctrat.norol <> viNoCopRep or milli.nolot <> viNoLotRep):  // Ne pas prendre le coproprietaire de repercution d'arrondi
                run gesAPIP-CX(buffer tmp-ana, buffer milli, buffer clemi, viNoconNodos, ctrat.norol, 100, viNbLigLib, vcAnalytique, vcCpt).
            end.
            else for each dosrp exclusive-lock
                where dosrp.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and dosrp.nocon = giNumeroMandat
                  and dosrp.nodos = giNumeroDossierTravaux
                  and dosrp.nolot = milli.nolot
                  and (dosrp.nocop <> viNoCopRep or dosrp.nolot <> viNoLotRep):   // Ne pas prendre le coproprietaire de repercution d'arrondi
                run gesAPIP-CX (buffer tmp-ana, buffer milli, buffer clemi, viNoconNodos, dosrp.nocop, dosrp.porep, viNbLigLib, vcAnalytique, vcCpt).
            end.     /* répartition acheteur/vendeur dossier travaux */
        end.

        /*--> Repercution des arrondis - uniquement sur les repartitions sur immeuble */
        for first clemi no-lock
            where clemi.noimm = giNumeroImmeuble
              and clemi.cdcle = tmp-ana.cle
          , first milli no-lock
            where milli.noimm = giNumeroImmeuble
              and milli.cdcle = clemi.cdcle
              and milli.nolot = viNoLotRep:
            /*--> Nombre d'appel par coproprietaire lot  */
            find first ttTmpCop
                where ttTmpCop.NoCop = viNoCopRep
                  and ttTmpCop.NoLot = milli.nolot
                  and ttTmpCop.CdCle = milli.CdCle no-error.
            if not available ttTmpCop
            then do:
                create ttTmpCop.
                assign
                    ttTmpCop.NoCop = viNoCopRep
                    ttTmpCop.NoLot = milli.nolot
                    ttTmpCop.CdCle = milli.cdcle.
            end.
            assign
                ttTmpCop.NbApp = ttTmpCop.NbApp + 1
                vlSensDep      = (tmp-ana.mt >= 0)
            .
            if not tmp-ana.sens then vlSensDep = not vlSensDep.
            /*--> Calcul de l'appel repercuté */
            assign
                vdMtAppRep = (if vlSensDep then tmp-ana.mt else - 1 * tmp-ana.mt /** 0306/0131 **/ )  - gdMtAppTot
                vcSigne    = if vdMtAppRep >= 0 then "+" else "-"                /* Ajout OF le 05/06/08 */
                vdMtAppTva = tmp-ana.mttva
                vdMtQpTva  = 0                                                   /* Ajout JPM 21022012 : calcul quote part tva */
            .
            if vdMtAppTva <> 0 then vdMtQpTva = (if vlSensDep then tmp-ana.mttva else - 1 * tmp-ana.mttva) - gdMtTvaTot.
            if vdMtAppRep <> 0    /*--> Ne pas envoyer d'article si montant de l'appel à zero */
            then run APIP-CX(buffer tmp-ana, buffer milli, buffer clemi, viNoconNodos, viNoCopRep, ttTmpCop.NbApp, viNbLigLib, vcSigne, vdMtQpTva, vdMtAppRep, vdMtAppTva, vcAnalytique, vcCpt).
        end.
    end.

end procedure.

procedure noLot_Par_Defaut private:
    /*------------------------------------------------------------------------------
     Purpose: Recherche du lot de répercution des arrondis
     Notes:  Ordre de priorité
             1. Le lot paramétré dans le dossier
             2. Si PAS DE LOT PAR DEFAUT OU ce lot n'a pas de millièmes sur la clé , alors on prends le lot de plus grand millième
    ------------------------------------------------------------------------------*/
    define input  parameter piNoMdtUseIN  as integer   no-undo.
    define input  parameter piNoDosUseIN  as integer   no-undo.
    define input  parameter piNoImmUseIN  as integer   no-undo.
    define input  parameter pcCdCleIn     as character no-undo.
    define input  parameter piNoLotDefIN  as integer   no-undo.
    define output parameter piNoLotRepOut as integer   no-undo.
    define output parameter piNoCopRepOut as integer   no-undo.

    define buffer milli for milli.
    define buffer dosrp for dosrp.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    define buffer local for local.

    if piNoLotDefIN > 0
    then for first milli no-lock
        where milli.noimm = piNoImmUseIN
          and milli.cdcle = pcCdCleIn
          and milli.nolot = piNoLotDefIN
          and milli.nbpar > 0:
        piNoLotRepOut = piNoLotDefIN.
    end.
    {&_proparse_ prolint-nowarn(sortaccess)}
    if piNoLotRepOut = 0
    then for each milli fields(nolot) no-lock
        where milli.noimm = piNoImmUseIN
          and milli.cdcle = pcCdCleIn
          and milli.norep = 0                    /* SY 06/02/2015 optim index milli */
          and milli.nolot > 0
          and milli.nbpar > 0
        by milli.nbpar by milli.nolot descending:
        piNoLotRepOut = milli.nolot.
        leave.
    end.
    /* Recherche du copropriétaire concerné pour ce lot */
    find last dosrp no-lock
        where dosrp.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and dosrp.nocon = piNoMdtUseIN
          and dosrp.nodos = piNoDosUseIN
          and dosrp.nolot = piNoLotRepOut
          and dosrp.porep <> 0 no-error.
    if available dosrp
    then piNoCopRepOut = dosrp.nocop.
    else for first local no-lock         /* copropriétaire actuel */
        where local.noimm = piNoImmUseIN
          and local.nolot = piNoLotRepOut
      , last intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.noidt = local.noLoc
          and intnt.tpcon = {&TYPECONTRAT-titre2copro}
          and intnt.nbden = 0
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        piNoCopRepOut = ctrat.norol.
//        leave.  a remettre si for each!
    end.

end procedure.

procedure Details_Imputations_Particulieres private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piNoconNodos as integer no-undo.

    define variable vcAnalytique as character no-undo.
    define variable vcCpt        as character no-undo.
    define variable vdMtAppRep   as decimal   no-undo.
    define variable vdMtAppTva   as decimal   no-undo.
    define variable vcChaine     as character no-undo.

    define buffer detip for detip.
    define buffer entip for entip.
    define buffer alrub for alrub.

    for each detip no-lock
        where detip.nocon = giNumeroMandat * 100000 + giNumeroDossierTravaux
      , first entip no-lock
        where entip.nocon = detip.nocon
          and entip.noimm = detip.noimm
          and entip.dtimp = detip.dtimp:
        vcAnalytique = detip.cdana.
        for first alrub no-lock
            where alrub.soc-cd   = giRefCopro
              and alrub.rub-cd   = substring(vcAnalytique, 1, 3, 'character')
              and alrub.ssrub-cd = substring(vcAnalytique, 4, 3, 'character'):
            vcCpt = alrub.cpt-cd + fill("0", giLgCpt - length(alrub.cpt-cd, 'character')).
        end.
        /*--> Nombre d'appel par coproprietaire lot  */
        find first ttTmpCop
            where ttTmpCop.NoCop = detip.nocop
              and ttTmpCop.NoLot = detip.nolot
              and ttTmpCop.CdCle = entip.nocle  no-error.     /* modif SY le 13/11/2006 "IP" */
        if not available ttTmpCop
        then do:
            create ttTmpCop.
            assign
                ttTmpCop.NoCop = detip.nocop
                ttTmpCop.NoLot = detip.nolot
                ttTmpCop.CdCle = entip.nocle        /* modif SY le 13/11/2006 "IP" */
            .
        end.
        /*--> Montant de l'appel */
        assign
            ttTmpCop.NbApp = ttTmpCop.NbApp + 1
            vdMtAppRep     = detip.mtttc
            vdMtAppTva     = detip.mttva
            vcChaine       = substitute("&1CX&2&3&4&5&6&7&8"
                                      , string(giNumeroMandat, "9999")
                                      , string(detip.nocop, "99999")
                                      , string(detip.nolot, "99999")
                                      , string(entip.nocle, "X(2)")               /* modif SY le 13/11/2006 "IP" */
                                      , string(detip.lbcom, "X(35)")
                                      , formatageSignePlus(vdMtAppRep, 2, 11)         /** 0208/0026  string(ABSOLUTE(vdMtAppRep) * 100 ,"99999999999") **/
                                      /*gga on est toujours en mode apres bascule
                                        + string("0" + if ApresBascule(giNumeroMandat,/*TODAY*/ DtTrtUse) then substring(vcCpt,1,giLgCum)    else "6700" ,"99999")
                                        + string(      if ApresBascule(giNumeroMandat,/*TODAY*/ DtTrtUse) then substring(vcCpt,giLgCum + 1,5) else "00000","99999")  gga*/
                                      , "0" + substring(vcCpt, 1, giLgCum, 'character')
                                      , substring(vcCpt, giLgCum + 1, 5, 'character'))
                           + substitute("0&1&2&3&4&5&6&7"
                                      , formatage(vdMtAppTva, 2, 11)        /** 0208/0026 string(ABSOLUTE(vdMtAppTva) * 100 ,"99999999999") **/
                                      /* + string(ttTmpCop.NbApp,"99")*/    /* NP 0616/0192  on gère désormais après vcChaine en local sinon en erreur au site central */
                                      , if ttTmpCop.NbApp > 99 then "**" else string(ttTmpCop.NbApp,"99")
                                      , vcAnalytique
                                      , formatageSignePlus(vdMtAppRep, 2, 11) /** 0208/0026 string(ABSOLUTE(vdMtAppRep) * 100 ,"99999999999") **/
                                      , string(100, "9999999999")
                                      , string(100, "9999999999")
                                      , fill(" ", 9))
        .
        if glTest = false then run chargeMbAp ("APIP", vcChaine, string(ttTmpCop.NbApp, "9999")).
        run ligne("APIP", giNoRefTrans, vcChaine).
        gdMontantTotOut = gdMontantTotOut + vdMtAppRep.                   /* DM 0208/0368 Cumul du montant des dépenses */
        run majttTmpapbco(piNoconNodos, entip.nocle, detip.nocop, detip.nolot, detip.mtttc).
    end.

end procedure.

procedure Entetes_Imputations_Particulieres private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer trdos for trdos.

    define variable vcAnalytique as character no-undo.
    define variable vcCpt        as character no-undo.
    define variable vdMtTotTva   as decimal   no-undo.
    define variable viNoCopRep   as integer   no-undo.
    define variable viNoLotRep   as integer   no-undo.
    define variable viNoconNodos as integer   no-undo.
    define variable vdMtAppRep   as decimal   no-undo.
    define variable vdMtAppTva   as decimal   no-undo.
    define variable vdMtQpTva    as decimal   no-undo.

    define buffer entip for entip.
    define buffer alrub for alrub.
    define buffer intnt for intnt.
    define buffer clemi for clemi.
    define buffer milli for milli.
    define buffer local for local.
    define buffer dosrp for dosrp.
    define buffer ctrat for ctrat.

    viNoconNodos = trdos.nocon * 100000 + trdos.nodos.
    /*--> Parcours des clés de récuperation IP */
    for each entip no-lock
        where entip.nocon = giNumeroMandat * 100000 + giNumeroDossierTravaux:
        vcAnalytique = entip.cdana.         /** 0606/0196  **/
        for first alrub no-lock
            where alrub.soc-cd = giRefCopro
              and alrub.rub-cd   = substring(vcAnalytique, 1, 3, 'character')
              and alrub.ssrub-cd = substring(vcAnalytique, 4, 3, 'character'):
            vcCpt = alrub.cpt-cd + fill("0", giLgCpt - length(alrub.cpt-cd, 'character')).
        end.
        /*--> Initialisation du montant total de l'appel */
        assign
            gdMtAppTot = 0
            vdMtTotTva = 0    /* NP 0715/0032 */
        .
        /*--> Lot de répercussions des arrondis : 0208/0022*/
        run noLot_Par_Defaut(trdos.nocon, trdos.nodos, giNumeroImmeuble, entip.nocre, trdos.lorep, output viNoLotRep, output viNoCopRep).
        /*--> pour chaque lot de la clé de repartition, je recherche la repartition achat / vente */
        for first clemi no-lock
            where clemi.noimm = giNumeroImmeuble
              and clemi.cdcle = entip.nocre
          , each milli no-lock
            where milli.noimm = giNumeroImmeuble
              and milli.cdcle = clemi.cdcle
          , first local no-lock
            where local.noimm = milli.noimm
              and local.nolot = milli.nolot:
            find first dosrp no-lock
                where dosrp.tpcon = {&TYPECONTRAT-mandat2Syndic} /* "01003" */
                  and dosrp.nocon = giNumeroMandat
                  and dosrp.nodos = giNumeroDossierTravaux
                  and dosrp.nolot = milli.nolot
                  and dosrp.porep <> 0 no-error.
            if not available dosrp
            then for last intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = local.NoLoc
                  and intnt.tpcon = {&TYPECONTRAT-titre2copro}
                  and intnt.nbden = 0
              , first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                  and ctrat.nocon = intnt.nocon
                  and (ctrat.norol <> viNoCopRep or milli.nolot <> viNoLotRep):    // Ne pas prendre le coproprietaire de repercution d'arrondi
                run gesAPIP-CX2(buffer milli, buffer entip, buffer clemi, viNoconNodos, ctrat.norol, 100, vcAnalytique, vcCpt).
            end.    /* dernier copro */
            else for each dosrp exclusive-lock
                where dosrp.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and dosrp.nocon = giNumeroMandat
                  and dosrp.nodos = giNumeroDossierTravaux
                  and dosrp.nolot = milli.nolot
                  and (dosrp.nocop <> viNoCopRep or dosrp.nolot <> viNoLotRep):  // Ne pas prendre le coproprietaire de repercution d'arrondi
                run gesAPIP-CX2(buffer milli, buffer entip, buffer clemi, viNoconNodos, dosrp.nocop, dosrp.porep, vcAnalytique, vcCpt).
            end.     /* répartition acheteur/vendeur dossier travaux */
        end.

        /*--> Repercution des arrondis */
        for first clemi no-lock
            where clemi.noimm = giNumeroImmeuble
              and clemi.cdcle = entip.nocre
          , first milli no-lock
            where milli.noimm = giNumeroImmeuble
              and milli.cdcle = clemi.cdcle
              and milli.nolot = viNoLotRep:
            /*--> Nombre d'appel par coproprietaire lot  */
            find first ttTmpCop
                where ttTmpCop.NoCop = viNoCopRep
                  and ttTmpCop.NoLot = viNoLotRep
                  and ttTmpCop.CdCle = milli.CdCle no-error.
            if not available ttTmpCop
            then do:
                create ttTmpCop.
                assign
                    ttTmpCop.NoCop = viNoCopRep
                    ttTmpCop.NoLot = viNoLotRep
                    ttTmpCop.CdCle = milli.cdcle
                .
            end.
            /*--> Calcul de l'appel repercuté */
            assign
                ttTmpCop.NbApp = ttTmpCop.NbApp + 1
                vdMtAppRep     = entip.mtttc - gdMtAppTot
                vdMtAppTva     = entip.mttva
                gdMtAppTot     = gdMtAppTot + vdMtAppRep
                /* NP 0715/0032 calcul de la tva de l'appel répercuté */
                vdMtQpTva      = entip.mttva - vdMtTotTva
                vdMtTotTva     = vdMtTotTva + vdMtQpTva
            .
            if vdMtAppRep <> 0            /*--> Ne pas envoyer d'article si montant de l'appel à zero */
            then run APIP-CX2(buffer milli, buffer clemi, buffer entip, viNoconNodos, viNoCopRep, ttTmpCop.NbApp, vdMtQpTva, vdMtAppRep, vdMtAppTva, vcAnalytique, vcCpt).
        end.
    end.

end procedure.

procedure emprunts private:
    /*------------------------------------------------------------------------------
     Purpose: DM 0706/0310
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer trdos for trdos.

    define variable vcCompte   as character no-undo. /* DM 0907/0182 */
    define variable vcLbEntUse as character no-undo.  /** DM 0706/0310 **/
    define variable viNoCopRep as integer   no-undo.
    define variable viNoLotRep as integer   no-undo.
    define variable vhTva      as handle    no-undo.
    define variable vdMtAppRep as decimal   no-undo.
    define variable vdMtAppTva as decimal   no-undo.
    define variable viNoLigUse as integer   no-undo.  /** DM 0706/0310 **/
    define variable vcChaine   as character no-undo.
    define variable vcliste    as character no-undo.
    define variable viSigne    as integer   no-undo. /* +1 ou -1 */

    define buffer doset for doset.
    define buffer dosrp for dosrp.
    define buffer dosdt for dosdt.
    define buffer dosap for dosap.
    define buffer milli for milli.
    define buffer clemi for clemi.

    empty temp-table ttTmpApp.
    empty temp-table ttTmpTot.

    run compta/outilsTVA.p persistent set vhTva.
    run getTokenInstance in vhTva(mToken:JSessionId).
    vcListe = substitute("&1,&2,&3", {&TYPEAPPEL2FONDS-emprunt}, {&TYPEAPPEL2FONDS-subvention}, {&TYPEAPPEL2FONDS-indemniteAssurance}).
    for each doset no-lock
        where doset.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and doset.nocon = trdos.nocon
          and doset.nodos = trdos.nodos
          and lookup(doset.TpApp, vcListe) > 0
        by doset.noord:

/*gga on est toujours en mode apres bascule
        /* DM 0508/0129 */
        if not VlBascule or (VlBascule and not ApresBascule(ietab.etab-cd,agest.dadeb) )
        then vcCompte = "0702000000".
        else do: gga*/
        vcCompte = entry(lookup(doset.tpApp, vcListe),
                         if integer(trdos.tpurg) = 1
                         then "0712200000,0711200000,0713200000"   // TRAVAUX URGENTS
                         else "0712100000,0711100000,0713100000"). // ASSEMBLEE GENERALE
/*gga
        end.
gga*/

        /*--> Parcours de tous les appels */
        {&_proparse_ prolint-nowarn(sortaccess)}
        for each dosdt no-lock
            where dosdt.noidt = doset.noidt
              and dosdt.cdapp <> ""
          , first dosap no-lock
            where dosap.tpcon = trdos.tpcon
              and dosap.nocon = trdos.nocon
              and dosap.nodos = trdos.nodos
              and dosap.noapp = dosdt.noapp
              and dosap.fgemi = true
            break by dosap.noapp
                  by dosdt.cdapp:

            if first-of(dosdt.cdapp) then gdMtAppTot = 0.     // Initialisation du montant total de l'appel

            /*--> Identifiant d'entete */
            vcLbEntUse = string(integer(doset.tpApp), "9") + string(doset.noFou, "99999").
            /*--> Lot de répercussions des arrondis : 0208/0022*/
            run noLot_Par_Defaut (trdos.nocon, trdos.nodos, giNumeroImmeuble, dosdt.cdapp, trdos.lorep, output viNoLotRep, output viNoCopRep).
            /*--> Type de repartition */
            case doset.tpsur:
                when "00001" then for first clemi no-lock                /*--> sur immeuble */
                    /*--> pour chaque lot de la clé de repartition, je recherche la repartition achat / vente */
                    where clemi.noimm = giNumeroImmeuble
                      and clemi.cdcle = dosdt.cdapp
                  , each milli no-lock
                    where milli.noimm = giNumeroImmeuble
                      and milli.cdcle = dosdt.cdapp
                  , each dosrp exclusive-lock
                    where dosrp.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and dosrp.nocon = giNumeroMandat
                      and dosrp.nodos = trdos.nodos
                      and dosrp.nolot = milli.nolot
                      and (dosrp.nocop <> viNoCopRep or dosrp.nolot <> viNoLotRep):   // Ne pas prendre le coproprietaire de repercution d'arrondi
                    /*--> Calcul de l'appel arrondi */
                    assign
                        vdMtAppRep = ((dosdt.mtapp * milli.nbpar / clemi.nbtot) * dosrp.porep) / 100
                        vdMtAppRep = decimal(formatageSignePlus(vdMtAppRep, 2, 11)) / 100   /* DM 0208/0368 */
                        vdMtAppTva = dynamic-function("calculTVAdepuisTTC" in vhTva,doset.CdTva,dosdt.mtapp)
                        gdMtAppTot = gdMtAppTot + vdMtAppRep
                    .
                    /*--> Ne pas envoyer d'article si pas montant de l'appel à zero */
                    if vdMtAppRep <> 0 then do:
                        /*--> Construction de la table temporaire des appels de fonds */
                        find first ttTmpApp
                            where ttTmpApp.NoCop = string(dosrp.nocop, "99999")
                              and ttTmpApp.NoLot = string(dosrp.nolot, "99999")
                              and ttTmpApp.CdCle = string(milli.cdcle, "X(2)")
                              and ttTmpApp.NbPar = string(milli.nbpar, "9999999999")
                              and ttTmpApp.NbTot = string(clemi.nbtot, "9999999999")
                              and ttTmpApp.noord = doset.noord /* DM 0706/0310 */ no-error.
                        if not available ttTmpApp
                        then do:
                            create ttTmpApp.
                            assign
                                viNoLigUse     = viNoLigUse + 1
                                ttTmpApp.NoLig = viNoLigUse
                                ttTmpApp.NbApp = string(integer(doset.tpapp), "99") /* DM 0706/0310 Type d'appel (Emprunt = 6, Subv = 7, Indemnites = 8 */
                                ttTmpApp.noord = doset.noord                        /* DM 0706/0310 */
                            .
                        end.
                        assign
                            ttTmpApp.FgHon = false
                            ttTmpApp.FgDer = true
                            ttTmpApp.NoCtt = string(giNumeroMandat, "9999")
                            ttTmpApp.TpApp = "CX"
                            ttTmpApp.NoCop = string(dosrp.nocop, "99999")
                            ttTmpApp.NoLot = string(dosrp.nolot, "99999")
                            ttTmpApp.CdCle = string(milli.cdcle, "X(2)")
                            ttTmpApp.LbApp = string(doset.Lbint[1], "X(35)")
                            viSigne        = if ttTmpApp.SgApp = "+" then 1 else -1
                            ttTmpApp.MtApp = string(absolute(vdMtAppRep + ((integer(ttTmpApp.MtApp) / 100) * viSigne)) * 100, "99999999999")
                            ttTmpApp.MtTva = string(absolute(vdMtAppTva + ((integer(ttTmpApp.MtTva) / 100) * viSigne)) * 100, "99999999999")
                            ttTmpApp.SgApp = if vdMtAppRep + (integer(ttTmpApp.MtApp) / 100) * viSigne >= 0 then "+" else "-"
                            ttTmpApp.NoCpt = vcCompte
                            ttTmpApp.NbLig = "0"
                            /* DM 0706/0310 ttTmpApp.NbApp = string(ttTmpCop.NbApp,"99") */
                            /* DM 0907/0182 ttTmpApp.SsCpt = "   " + "   " + " "         */
                            ttTmpApp.SsCpt = "1102604"
                            /* DM 0907/0182
                            ttTmpApp.MtTot = string(ABSOLUTE(dosdt.mtapp) * 100 ,"99999999999")
                            ttTmpApp.SgTot = IF dosdt.mtapp >= 0 THEN "+" ELSE "-"
                            */
                            /* DM 0706/0310
                            ttTmpApp.MtTot = string(ABSOLUTE(dosdt.mtapp + ((integer(ttTmpApp.MtTot) / 100) * (IF ttTmpApp.SgTot = "+" THEN 1 ELSE -1))) * 100 ,"99999999999")
                            ttTmpApp.SgTot = IF dosdt.mtapp + ((integer(ttTmpApp.MtTot) / 100) * (IF ttTmpApp.SgApp = "+" THEN 1 ELSE -1)) >= 0 THEN "+" ELSE "-"
                            */
                            ttTmpApp.NbPar = string(milli.nbpar, "9999999999")
                            ttTmpApp.NbTot = string(clemi.nbtot, "9999999999")
                            ttTmpApp.LbEnt = vcLbEntUse
                            ttTmpApp.LbFil = fill(" ",3)
                        .
                    end.
                end.
                when "00002" then for first dosrp exclusive-lock            /*--> Matricule */
                    where dosrp.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and dosrp.nocon = giNumeroMandat
                      and dosrp.nodos = trdos.nodos
                      and dosrp.nocop = integer(entry(1, dosdt.cdapp, SEPAR[1]))
                      and dosrp.nolot = integer(entry(2, dosdt.cdapp, SEPAR[1])):
                    /*--> Montant de l'appel */
                    assign
                        vdMtAppRep = dosdt.mtapp
                        /*vdMtAppTva = MTTVA(vdMtAppRep,doset.CdTva).*/ /**Modif OF le 22/08/11**/
                        vdMtAppTva = dynamic-function("calculTVAdepuisTTC" in vhTva, doset.CdTva, vdMtAppRep)
                    .
                    /*--> Construction de la table temporaire des appels de fonds */
                    find first ttTmpApp
                        where ttTmpApp.NoCop = string(integer(entry(1, dosdt.cdapp, SEPAR[1])), "99999")
                          and ttTmpApp.NoLot = string(integer(entry(2, dosdt.cdapp, SEPAR[1])), "99999")
                          and ttTmpApp.CdCle = "XX"
                          and ttTmpApp.NbPar = string(100, "9999999999")
                          and ttTmpApp.NbTot = string(100, "9999999999")
                          and ttTmpApp.noord = doset.noord /* DM 0706/0310 */ no-error.
                    if not available ttTmpApp
                    then do:
                        create ttTmpApp.
                        assign
                            viNoLigUse     = viNoLigUse + 1
                            ttTmpApp.NoLig = viNoLigUse
                            ttTmpApp.NbApp = string(integer(doset.tpapp), "99") /* DM 0706/0310 Type d'appel (Emprunt = 6, Subv = 7, Indemnites = 8 */
                            ttTmpApp.noord = doset.noord                        /* DM 0706/0310 */
                        .
                    end.
                    assign
                        ttTmpApp.FgHon = false
                        ttTmpApp.FgDer = true
                        ttTmpApp.NoCtt = string(giNumeroMandat, "9999")
                        ttTmpApp.TpApp = "CX"
                        ttTmpApp.NoCop = string(integer(entry(1, dosdt.cdapp, SEPAR[1])), "99999")
                        ttTmpApp.NoLot = string(integer(entry(2, dosdt.cdapp, SEPAR[1])), "99999")
                        ttTmpApp.CdCle = "XX"
                        ttTmpApp.LbApp = string(doset.Lbint[1], "X(35)")
                        viSigne        = if ttTmpApp.SgApp = "+" then 1 else -1
                        ttTmpApp.MtApp = string(absolute(vdMtAppRep + ((integer(ttTmpApp.MtApp) / 100) * viSigne)) * 100, "99999999999")
                        ttTmpApp.MtTva = string(absolute(vdMtAppTva + ((integer(ttTmpApp.MtTva) / 100) * viSigne)) * 100, "99999999999")
                        ttTmpApp.SgApp = if vdMtAppRep + (integer(ttTmpApp.MtApp) / 100) * viSigne >= 0 then "+" else "-"
                        ttTmpApp.NoCpt = vcCompte
                        ttTmpApp.NbLig = "0"
                        /* ttTmpApp.NbApp = string(ttTmpCop.NbApp,"99") DM 0706/0310 */
                        ttTmpApp.SsCpt = "1102604"
                        /* DM 0706/0310
                        ttTmpApp.MtTot = string(ABSOLUTE(vdMtAppRep) * 100 ,"99999999999")
                        ttTmpApp.SgTot = IF vdMtAppRep >= 0 THEN "+" ELSE "-"
                        */
                        ttTmpApp.NbPar = string(100, "9999999999")
                        ttTmpApp.NbTot = string(100, "9999999999")
                        ttTmpApp.LbEnt = vcLbEntUse
                        ttTmpApp.LbFil = fill(" ", 3)
                    .
                end.
            end case.

            /*--> Repercution des arrondis - uniquement sur les repartitions sur immeuble */
            if last-of(dosdt.cdapp) and doset.TpSur = "00001" then do:
                for first clemi no-lock
                    where clemi.noimm = giNumeroImmeuble
                      and clemi.cdcle = dosdt.cdapp
                  , first milli no-lock
                    where milli.noimm = giNumeroImmeuble
                      and milli.cdcle = dosdt.cdapp
                      and milli.nolot = viNoLotRep
                  , first dosrp exclusive-lock
                    where dosrp.tpcon = {&TYPECONTRAT-mandat2Syndic} /* "01003" */
                      and dosrp.nocon = giNumeroMandat
                      and dosrp.nodos = trdos.nodos
                      and dosrp.nocop = viNoCopRep
                      and dosrp.nolot = viNoLotRep:
                    /*--> Calcul de l'appel repercuté */
                    assign
                        vdMtAppRep = dosdt.mtapp - gdMtAppTot
                        vdMtAppTva = dynamic-function("calculTVAdepuisTTC" in vhTva,doset.CdTva,dosdt.mtapp)
                        gdMtAppTot = gdMtAppTot + vdMtAppRep     /* DM 0706/0310 */
                    .
                    /*--> Construction de la table temporaire des appels de fonds */
                    find first ttTmpApp
                        where ttTmpApp.NoCop = string(dosrp.nocop, "99999")
                          and ttTmpApp.NoLot = string(dosrp.nolot, "99999")
                          and ttTmpApp.CdCle = string(milli.cdcle, "X(2)")
                          and ttTmpApp.NbPar = string(milli.nbpar, "9999999999")
                          and ttTmpApp.NbTot = string(clemi.nbtot, "9999999999")
                          and ttTmpApp.noord = doset.noord /* DM 0706/0310 */ no-error.
                    if not available ttTmpApp
                    then do:
                        create ttTmpApp.
                        assign
                            viNoLigUse     = viNoLigUse + 1
                            ttTmpApp.NoLig = viNoLigUse
                            ttTmpApp.NbApp = string(integer(doset.tpapp), "99") /* DM 0706/0310 Type d'appel (Emprunt = 6, Subv = 7, Indemnites = 8 */
                            ttTmpApp.noord = doset.noord                        /* DM 0706/0310 */
                            ttTmpApp.NbApp = string(integer(doset.tpapp) ,"99") /* DM 0706/0310 Type d'appel (Emprunt = 6, Subv = 7, Indemnites = 8 */
                        .
                    end.
                    assign
                        ttTmpApp.FgHon = false
                        ttTmpApp.FgDer = true
                        ttTmpApp.NoCtt = string(giNumeroMandat, "9999")
                        ttTmpApp.TpApp = "CX"
                        ttTmpApp.NoCop = string(dosrp.nocop, "99999")
                        ttTmpApp.NoLot = string(dosrp.nolot, "99999")
                        ttTmpApp.CdCle = string(milli.cdcle, "X(2)")
                        ttTmpApp.LbApp = string(doset.Lbint[1], "X(35)")
                        viSigne        = if ttTmpApp.SgApp = "+" then 1 else -1
                        ttTmpApp.MtApp = string(absolute(vdMtAppRep + ((integer(ttTmpApp.MtApp) / 100) * viSigne)) * 100 ,"99999999999")
                        ttTmpApp.MtTva = string(absolute(vdMtAppTva + ((integer(ttTmpApp.MtTva) / 100) * viSigne)) * 100 ,"99999999999")
                        /* DM 0706/0310 ttTmpApp.NbApp = string(ttTmpCop.NbApp,"99")                    */
                        ttTmpApp.SgApp = if vdMtAppRep + (integer(ttTmpApp.MtApp) / 100) * viSigne >= 0 then "+" else "-"
                        ttTmpApp.NoCpt = vcCompte
                        ttTmpApp.NbLig = "0"
                        ttTmpApp.SsCpt = "1102604"
                        /* DM 0907/0182
                        ttTmpApp.MtTot = string(ABSOLUTE(dosdt.mtapp) * 100 ,"99999999999")
                        ttTmpApp.SgTot = IF dosdt.mtapp >= 0 THEN "+" ELSE "-"
                        */
                        ttTmpApp.NbPar = string(milli.nbpar, "9999999999")
                        ttTmpApp.NbTot = string(clemi.nbtot, "9999999999")
                        ttTmpApp.LbEnt = vcLbEntUse
                        ttTmpApp.LbFil = fill(" ", 3)
                    .
                end.
            end.

            /* DM 0706/0310 Mise a jour du montant total par nature (emprunt/subvention/indemnité) */
            if last-of(dosdt.cdapp) then do:
                find first ttTmpTot
                    where ttTmpTot.tpapp = integer(doset.tpapp) no-error.
                if not available ttTmpTot
                then do:
                    create ttTmpTot.
                    ttTmpTot.TpApp = integer(doset.tpapp).
                end.
                ttTmpTot.mt-tot = ttTmpTot.mt-tot + gdMtAppTot.
            end.
        end.
    end.
    run destroy in vhTva.

    /*--> Exporter les appels de fond Emprunt dans l'article APEM */
    for each ttTmpApp
        by ttTmpApp.noord:
        find first ttTmpTot
            where ttTmpTot.TpApp = integer(ttTmpApp.NbApp) no-error.
        assign
            ttTmpApp.MtTot = string(if available ttTmpTot then absolute(ttTmpTot.mt-tot * 100) else 0, "99999999999")
            ttTmpApp.SgTot = if (integer(ttTmpApp.MtTot) / 100) * (if ttTmpApp.SgApp = "+" then 1 else -1) >= 0 then "+" else "-"
            vcChaine       = ttTmpApp.NoCtt
                           + ttTmpApp.TpApp
                           + ttTmpApp.NoCop
                           + ttTmpApp.NoLot
                           + ttTmpApp.CdCle
                           + ttTmpApp.LbApp
                           + ttTmpApp.MtApp
                           + ttTmpApp.SgApp
                           + ttTmpApp.NoCpt
                           + ttTmpApp.NbLig
                           + ttTmpApp.MtTva
                           + ttTmpApp.NbApp
                           + ttTmpApp.SsCpt
                           + ttTmpApp.MtTot
                           + ttTmpApp.SgTot
                           + ttTmpApp.NbPar
                           + ttTmpApp.NbTot
                           + ttTmpApp.LbEnt
                           + ttTmpApp.LbFil
        .
        if glTest = false then run chargeMbAp ("APEM", vcChaine, "").
        run ligne("APEM", giNoRefTrans, vcChaine).
    end.

end procedure.

procedure GesAPIP-CX private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer tmp-ana for tmp-ana.
    define parameter buffer milli for milli.
    define parameter buffer clemi for clemi.
    define input parameter piNoconNodos as integer   no-undo.
    define input parameter piNoCopUseIN as integer   no-undo.
    define input parameter pdPcRepartIN as decimal   no-undo.
    define input parameter piNbLigLib   as integer   no-undo.
    define input parameter pcAnalytique as character no-undo.
    define input parameter pcCpt        as character no-undo.

    define variable vdMtAppRep  as decimal   no-undo.
    define variable vdMtAppTva  as decimal   no-undo.
    define variable vdMtQpTva   as decimal   no-undo.
    define variable vcSigne     as character no-undo format "(x)".
    define variable vcSigneTVA  as character no-undo format "(x)".

    /*--> Nombre d'appel par coproprietaire lot  */
    find first ttTmpCop
        where ttTmpCop.NoCop = piNoCopUseIN
          and ttTmpCop.NoLot = milli.nolot
          and ttTmpCop.CdCle = milli.cdcle no-error.
    if not available ttTmpCop
    then do:
        create ttTmpCop.
        assign
            ttTmpCop.NoCop = piNoCopUseIN
            ttTmpCop.NoLot = milli.nolot
            ttTmpCop.CdCle = milli.cdcle
        .
    end.
    /*--> Calcul de l'appel arrondi */
    assign
        ttTmpCop.NbApp = ttTmpCop.NbApp + 1
        vdMtAppRep     = ((tmp-ana.mt * milli.nbpar / clemi.nbtot) * pdPcRepartIN) / 100
        vdMtAppRep     = round(vdMtAppRep,2)  /**Ajout OF le 05/06/08**/
        vdMtAppRep     = if tmp-ana.sens then vdMtAppRep else - vdMtAppRep /** 0206/0422 **/
        vcSigne        = if vdMtAppRep >= 0 then "+" else "-"  /**Ajout OF le 27/02/08**/
        vdMtAppRep     = decimal(formatage(vdMtAppRep, 2, 11)) / 100
        gdMtAppTot     = gdMtAppTot + vdMtAppRep * (if vcSigne = "+" then 1 else -1)
        vdMtAppTva     = tmp-ana.mttva
        vdMtAppTva     = decimal(formatage(vdMtAppTva, 2, 11)) / 100
        vdMtQpTva      = 0
    .
    /* Ajout JPM le 21022012 : calcul quote part tva */
    if vdMtAppTva <> 0
    then assign
        vdMtQpTva  = ((tmp-ana.mttva * milli.nbpar / clemi.nbtot) * pdPcRepartIN) / 100
        vdMtQpTva  = round(vdMtQpTva, 2)
        vdMtQpTva  = if tmp-ana.sens then vdMtQpTva else - vdMtQpTva
        /**Modif OF le 28/11/12 - Remplacement vcSigne par vcSigneTVA ci-dessous**/
        vcSigneTVA = if vdMtQpTva >= 0 then "+" else "-"
        vdMtQpTva  = decimal(formatage(vdMtQpTva, 2, 11)) / 100
        gdMtTvaTot = gdMtTvaTot + vdMtQpTva * (if vcSigneTVA = "+" then 1 else -1)
    .
    /*--> Ne pas envoyer d'article si montant de l'appel à zero */
    if vdMtAppRep <> 0
    then run APIP-CX(buffer tmp-ana,        /*--> Construction de l'article */
                     buffer milli,
                     buffer clemi,
                     piNoconNodos,
                     piNoCopUseIN,
                     ttTmpCop.NbApp,
                     piNbLigLib,
                     vcSigne,
                     vdMtQpTva,
                     vdMtAppRep,
                     vdMtAppTva,
                     pcAnalytique,
                     pcCpt).

end procedure.

procedure APIP-CX private:
    /*------------------------------------------------------------------------------
     Purpose: Procedure article APIP par ligne analytique/copro/lot
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer tmp-ana for tmp-ana.
    define parameter buffer milli for milli.
    define parameter buffer clemi for clemi.
    define input parameter piNoconNodos as integer   no-undo.
    define input parameter piNoCopUseIN as integer   no-undo.
    define input parameter piNbAppUseIN as integer   no-undo.
    define input parameter piNbLigLib   as integer   no-undo.
    define input parameter pcSigne      as character no-undo format "(x)".
    define input parameter pdMtQpTva    as decimal   no-undo.
    define input parameter pdMtAppRep   as decimal   no-undo.
    define input parameter pdMtAppTva   as decimal   no-undo.
    define input parameter pcAnalytique as character no-undo.
    define input parameter pcCompte     as character no-undo.

    define variable vlSensDep as logical   no-undo.
    define variable vi        as integer   no-undo.
    define variable vcChaine  as character no-undo.

    vlSensDep = (tmp-ana.mt >= 0).
    if not tmp-ana.sens then vlSensDep = not vlSensDep.
    do vi = 1 to piNbLigLib:
        vcChaine = substitute("&1CX&2&3&4&5&6&7&8&9"
                            , string(giNumeroMandat, "9999")
                            , string(piNoCopUseIN, "99999")
                            , string(milli.nolot, "99999")
                            , string(tmp-ana.cle, "X(2)")
                            , string(tmp-ana.lib-ecr[vi], "X(35)")
                            , if vi = piNbLigLib then formatage(pdMtAppRep, 2, 11) else fill("0", 11) /** 0208/0026 string(absolute(pdMtAppRep) * 100 ,"99999999999") **/
                            , if vi = piNbLigLib then pcSigne else "+"                                /**Modif OF le 27/02/08**/
            /*gga on est toujours en mode apres bascule
                               + string("0" + if ApresBascule(giNumeroMandat,/*TODAY*/ DtTrtUse) then substring(pcCompte,1,giLgCum)    else "6700" ,"99999")
                               + string(      if ApresBascule(giNumeroMandat,/*TODAY*/ DtTrtUse) then substring(pcCompte,giLgCum + 1,5) else "00000","99999")
            gga*/           , "0" + substring(pcCompte, 1, giLgCum, 'character')
                            , substring(pcCompte, giLgCum + 1, 5, 'character'))
                 + substitute("&1&2&3&4&5&6&7&8      &9"
                            , if piNbLigLib = 1 then "0" else string(vi)
                            , if vi = piNbLigLib then formatage(pdMtAppTva, 2, 11) else fill("0", 11)
                            , if piNbAppUseIN > 99 then "**" else string(piNbAppUseIN, "99")
                            , pcAnalytique
                            , formatage(tmp-ana.mt, 2, 11)               /** 0208/0026  string(absolute(tmp-ana.mt) * 100 ,"99999999999") **/
                            , if vlSensDep then "+" else "-"             /** (IF tmp-ana.mt >= 0 THEN "+" ELSE "-") 0206/0422 **/
                            , string(milli.nbpar, "9999999999")
                            , string(clemi.nbtot, "9999999999")
                            , if pdMtQpTva <> 0 then "QPT" else fill(" ", 3))
        .
        if glTest = false then run chargeMbAp ("APIP", vcChaine, string(piNbAppUseIN, "9999")).
        run ligne("APIP", giNoRefTrans, vcChaine).
    end.

    /* Ajout JPM 21022012 envoi quote part tva  */
    if pdMtQpTva <> 0
    then do:
        vcChaine = substitute("&1CX&2&3&4&5"
                            , string(giNumeroMandat, "9999")
                            , string(piNoCopUseIN, "99999")
                            , string(milli.nolot, "99999")
                            , formatage(pdMtQpTva, 2, 11)
                            , fill(" ", 110)).
        if glTest = false then run chargeMbAp ("API2", vcChaine, "").
        run ligne ("API2", giNoRefTrans, vcChaine).
    end.
    gdMontantTotOut = gdMontantTotOut + absolute(pdMtAppRep) * (if pcSigne = "+" then 1 else -1) . /* DM 0208/0368 Cumul du montant des dépenses */
    run majttTmpapbco(piNoconNodos, tmp-ana.cle, piNoCopUseIN, milli.nolot, absolute(pdMtAppRep) * (if pcSigne = "+" then 1 else -1)).

end procedure.

procedure GesAPIP-CX2 private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure article APIP par ligne analytique/copro/lot - Entip
    Notes:
   ------------------------------------------------------------------------------*/
    define parameter buffer milli for milli.
    define parameter buffer entip for entip.
    define parameter buffer clemi for clemi.
    define input parameter piNoconNodos as integer   no-undo.
    define input parameter piNoCopUseIN as integer   no-undo.
    define input parameter pdPcRepartIN as decimal   no-undo.
    define input parameter pcAnalytique as character no-undo.
    define input parameter pcCpt        as character no-undo.

    define variable vdMtAppRep as decimal   no-undo.
    define variable vdMtAppTva as decimal   no-undo.
    define variable vdMtQpTva  as decimal   no-undo.
    define variable vdMtTotTva as decimal   no-undo.   /* NP 0715/0032 */

    /*--> Nombre d'appel par coproprietaire lot  */
    find first ttTmpCop
        where ttTmpCop.NoCop = piNoCopUseIN
          and ttTmpCop.NoLot = milli.nolot
          and ttTmpCop.CdCle = milli.cdcle no-error.
    if not available ttTmpCop
    then do:
        create ttTmpCop.
        assign
            ttTmpCop.NoCop = piNoCopUseIN
            ttTmpCop.NoLot = milli.nolot
            ttTmpCop.CdCle = milli.cdcle
        .
    end.
    /*--> Calcul de l'appel arrondi */
    assign
        ttTmpCop.NbApp = ttTmpCop.NbApp + 1
        vdMtAppRep     = ((entip.mtttc * milli.nbpar / clemi.nbtot) * pdPcRepartIN) / 100
        vdMtAppRep     = round(vdMtAppRep , 2)
        vdMtAppTva     = entip.mttva
        gdMtAppTot     = gdMtAppTot + vdMtAppRep
        vdMtQpTva      = 0
    .
    /* NP 0715/0032 Add calcul quote part tva */
    if vdMtAppTva <> 0
    then assign
        vdMtQpTva = ((entip.mttva * milli.nbpar / clemi.nbtot) * pdPcRepartIN) / 100
        vdMtQpTva = round(vdMtQpTva, 2)
    .
    vdMtTotTva = vdMtTotTva + vdMtQpTva.
    /*--> Ne pas envoyer d'article si montant de l'appel à zero */
    if vdMtAppRep <> 0
    then run APIP-CX2(buffer milli,  /*--> Construction de l'article */
                      buffer clemi,
                      buffer entip,
                      piNoconNodos,
                      piNoCopUseIN,
                      ttTmpCop.NbApp,
                      vdMtQpTva,
                      vdMtAppRep,
                      vdMtAppTva,
                      pcAnalytique,
                      pcCpt).

end procedure.

procedure APIP-CX2 private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer milli for milli.
    define parameter buffer clemi for clemi.
    define parameter buffer entip for entip.
    define input parameter piNoconNodos  as integer   no-undo.
    define input parameter piNoCopUseIN  as integer   no-undo.
    define input parameter piNbAppUseIN  as integer   no-undo.
    define input parameter pdMtQpTva     as decimal   no-undo.
    define input parameter pdMtAppRep    as decimal   no-undo.
    define input parameter pdMtAppTva    as decimal   no-undo.
    define input parameter pcAnalytique  as character no-undo.
    define input parameter pcCompte      as character no-undo.

    define variable vcChaine as character no-undo.

    vcChaine = substitute("&1CX&2&3&4&5&6&7&8"
                         , string(giNumeroMandat, "9999")
                         , string(piNoCopUseIN, "99999")
                         , string(milli.nolot, "99999")
                         , string(milli.cdcle, "X(2)")
                         , string(entip.lbimp, "X(35)")
                         , formatageSigneMoins(pdMtAppRep, 2, 11)              /** 0208/0026 string(ABSOLUTE(pdMtAppRep) * 100 ,"99999999999") **/
        /*gga on est toujours en mode apres bascule
                       + string("0" + if ApresBascule(giNumeroMandat,/*TODAY*/ DtTrtUse) then substring(pcCompte,1,giLgCum)    else "6700" ,"99999")
                       + string(      if ApresBascule(giNumeroMandat,/*TODAY*/ DtTrtUse) then substring(pcCompte,giLgCum + 1,5) else "00000","99999")
        gga*/            , "0" + substring(pcCompte, 1, giLgCum, 'character')
                         , substring(pcCompte, giLgCum + 1, 5, 'character'))
               + substitute("0&1&2&3&4&5&6&7      &8"
                         , formatage(pdMtAppTva, 2, 11)                                   /** 0208/0026 string(ABSOLUTE(pdMtAppTva) * 100 ,"99999999999") **/
                         , if piNbAppUseIN > 99 then "**" else string(piNbAppUseIN, "99") /* NP 0616/0192  on gère désormais après vcChaine en local sinon en erreur au site central */
                         , pcAnalytique
                         , formatage(entip.mtttc, 2, 11)                                  /** 0208/0026 string(ABSOLUTE(entip.mtttc) * 100 ,"99999999999") **/
                         , if entip.mtttc >= 0 then "-" else "+"
                         , string(milli.nbpar, "9999999999")
                         , string(clemi.nbtot, "9999999999")
                         , if pdMtQpTva <> 0 then "QPT" else fill(" ", 3))     /* SY 0216/0043 */
    .
    if glTest = false then run chargeMbAp ("APIP", vcChaine, string(piNbAppUseIN, "9999")).
    run ligne ("APIP", giNoRefTrans, vcChaine).

    if pdMtAppTva <> 0
    then do:
        vcChaine = substitute("&1CX&2&3&4&5"
                            , string(giNumeroMandat, "9999")
                            , string(piNoCopUseIN, "99999")
                            , string(milli.nolot, "99999")
                            , formatage(pdMtQpTva, 2, 11)
                            , fill(" ", 110)).
        if glTest = false then run chargeMbAp("API2", vcChaine, "").
        run ligne("API2", giNoRefTrans, vcChaine).
    end.
    gdMontantTotOut = gdMontantTotOut - pdMtAppRep.                                  /* DM 0208/0368 Cumul du montant des dépenses */
    run majttTmpapbco(piNoconNodos, milli.cdcle, piNoCopUseIN, milli.nolot, - pdMtAppRep).

end procedure.

procedure ChargeMbAp private:
    /*------------------------------------------------------------------------------
     Purpose: Procedure de chargement des mandats transmis au site central pour traitement
              local à suivre (Appels de fonds)
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcNmArtUse as character no-undo.
    define input parameter pcChaine   as character no-undo.
    define input parameter pcParamSup as character no-undo.

    create ttArtappels.
    assign
        ttArtappels.noref = string(giNoRefTrans, "99999")
        ttArtappels.art   = pcChaine + pcParamSup
        ttArtappels.cdart = pcNmArtUse
    .
end procedure.

procedure MajttTmpapbco private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNoconNodos as integer   no-undo.
    define input parameter pcCdCleUseIN as character no-undo.
    define input parameter piNoCopUseIN as integer   no-undo.
    define input parameter piNoLotUseIN as integer   no-undo.
    define input parameter pdMtImpUseIN as decimal   no-undo.

    find first ttTmpapbco
        where ttTmpapbco.tpbud = {&TYPEBUDGET-travaux} /* "01080" */
          and ttTmpapbco.nobud = piNoconNodos
          and ttTmpapbco.tpapp = {&TYPEAPPEL-clotureTravaux} /* "CX" */
          and ttTmpapbco.noapp = giNoAppUse
          and ttTmpapbco.cdcle = pcCdCleUseIN
          and ttTmpapbco.noord = 0
          and ttTmpapbco.nomdt = giNumeroMandat
          and ttTmpapbco.noimm = giNumeroImmeuble
          and ttTmpapbco.nolot = piNoLotUseIN
          and ttTmpapbco.nocop = piNoCopUseIN no-error.
    if not available ttTmpapbco
    then do:
        create ttTmpapbco.
        assign
            ttTmpapbco.tpbud  = {&TYPEBUDGET-travaux}
            ttTmpapbco.nobud  = piNoconNodos
            ttTmpapbco.tpapp  = {&TYPEAPPEL-clotureTravaux}
            ttTmpapbco.noapp  = giNoAppUse
            ttTmpapbco.dtapp  = gdaDtAppUse
            ttTmpapbco.cdcle  = pcCdCleUseIN
            ttTmpapbco.noord  = 0
            ttTmpapbco.nomdt  = giNumeroMandat
            ttTmpapbco.noimm  = giNumeroImmeuble
            ttTmpapbco.nolot  = piNoLotUseIN
            ttTmpapbco.nocop  = piNoCopUseIN
            ttTmpapbco.lbdiv2 = ""                            /* réservé OD mutation (c.f.mutapbu.p) */
            ttTmpapbco.dtcsy = today
            ttTmpapbco.hecsy = mtime
            ttTmpapbco.cdcsy = mToken:cUser + "@cgapfco.i"    /*"D07"    */ /* Modif SY le 18/06/2008 */
        .
    end.
    assign
        ttTmpapbco.mtlot = ttTmpapbco.mtlot + pdMtImpUseIN
        ttTmpapbco.dtmsy = today
        ttTmpapbco.hemsy = mtime
        ttTmpapbco.cdmsy = mToken:cUser + "@cgapfco.i"
        ttTmpapbco.dtems = today
    .

end procedure.

procedure MajDetailLotCopro private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define buffer apbco for apbco.

    for each ttTmpapbco:
        create apbco.
        buffer-copy ttTmpapbco to apbco.
    end.

end procedure.
