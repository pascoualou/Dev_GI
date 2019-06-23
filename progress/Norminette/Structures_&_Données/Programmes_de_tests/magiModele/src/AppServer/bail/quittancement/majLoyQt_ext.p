/*-----------------------------------------------------------------------------
File        : majLoyQt_ext.p
Purpose     : 
Author(s)   : KANTENA - 2017/11/27
Notes       : reprise de majLoyQt_ext.p
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
using parametre.pclie.parametrageCalendrierLoyer.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmpRub.i}

define variable glDebug  as logical   no-undo.
define stream stFicSor.

define temp-table ttCalendrierEvolutionLoyer no-undo
    field noper as integer
    field dtdeb as date
    field dtfin as date
    field mtper as decimal decimals 2
index primaire dtdeb.

define temp-table ttCalendrierEvolutionLoyer-Prc no-undo
    field noper as integer
    field dtdeb as date
    field dtfin as date
    field mtper as decimal decimals 2
index primaire dtdeb.

define input  parameter poCollection as class collection no-undo.
define output parameter pcCodeRetour  as character no-undo initial "00".

if glDebug then output stream StFicSor to value(substitute("&1majloyqt-&2.txt", session:temp-directory, mtoken:cRefGerance)) unbuffered append.
run majloyqt.
if glDebug then output stream StFicSor close.

procedure majloyqt private:
    /*--------------------------------------------------------------------------- 
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define variable vcTypeContrat       as character no-undo.
    define variable viNumeroLocataire   as int64     no-undo.
    define variable viNumeroCalendrier  as integer   no-undo.
    define variable viNumeroQuittance   as integer   no-undo.
    define variable vdaDateEntree       as date      no-undo.
    define variable vdaDateSortie       as date      no-undo.
    define variable vdaDebutCalendrier  as date      no-undo.
    define variable vdaFinCalendrier    as date      no-undo.
    define variable vdaDebutPeriode     as date      no-undo.
    define variable vdaFinPeriode       as date      no-undo.
    define variable vdaFinBail          as date      no-undo.
    define variable vdaResiliationBail  as date      no-undo.
    define variable vdaSortieLocataire  as date      no-undo.
    define variable viNombreMois        as integer   no-undo.
    define variable vcTypeTraitement    as character no-undo.
    define variable viNumeroRubrique    as integer   no-undo.
    define variable viNumeroPeriode     as integer   no-undo.
    define variable vdMontantHistorique as decimal   no-undo.
    define variable vdMontantReg        as decimal   no-undo.
    define variable viCpt               as integer   no-undo.
    define variable vdaIndexation       as date      no-undo.
    define variable viNumeroLibelle     as integer   no-undo.
    define variable vdeMontantQuittance as decimal   no-undo.
    define variable vdMontantRubrique   as decimal   no-undo.
    define variable vlTaciteReconduit   as logical   no-undo.
    define variable vcLbdivcal          as character no-undo.
    define variable vlCalendrierEvolution       as logical   no-undo.
    define variable viCalendrierPrecedent       as integer   no-undo.
    define variable vdMontantLoyerContractuel   as decimal   no-undo.
    define variable vdMontantQuittance          as decimal   no-undo.
    define variable vcLibelleHistoriqueQtt      as character no-undo.
    define variable viNumeroCalendrierPrecedent as integer   no-undo.
    define variable vlModificationMontant       as logical   no-undo.
    define variable viNumeroLibelleRappelAvoir  as integer   no-undo.    /* no libellé rappel/Avoir rub 103 */
    define variable voCalendrierLoyer           as class parametrageCalendrierLoyer no-undo.

    define buffer rubqt for rubqt.
    define buffer tache for tache.
    define buffer ctrat for ctrat.
    define buffer calev for calev.
    define buffer aquit for aquit.
    define buffer pclie for pclie.

    /* Recuperation des parametres */
    assign
        vcTypeContrat         = poCollection:getCharacter("cTypeContrat")
        viNumeroLocataire     = poCollection:getInt64("i64NumeroContrat")
        vlModificationMontant = poCollection:getLogical("lRegularisation")
        viNumeroPeriode       = poCollection:getInteger("iNumeroPeriode")
        vcTypeTraitement      = poCollection:getCharacter("cTypeTraitement")
        vdaIndexation         = poCollection:getDate("daIndexation")
        viNumeroQuittance     = poCollection:getInteger("iNumeroTraitement") 
        vdaDebutPeriode       = poCollection:getDate("daDebutPeriode")
        vdaFinPeriode         = poCollection:getDate("daFinPeriode")
        voCalendrierLoyer     = new parametrageCalendrierLoyer()
        vlCalendrierEvolution = voCalendrierLoyer:isCalendrierEvolution()
    .
    delete object voCalendrierLoyer.
    /* Si aucun calendrier de saisi: aucun calcul a effectuer */
    if not can-find(first calev where calev.tpcon = vcTypeContrat and calev.nocon = viNumeroLocataire) then return.

    /* Ajout SY le 07/03/2008 : nouveau calcul => si revision pas de déclenchement de la régul */
    if vlCalendrierEvolution and vcTypeTraitement = "CALID" then vlModificationMontant = no.

    /*** Modif SY le 03/03/2008 : plus de calcul au jour
    /*- Tableau des annees bissextiles -*/  
    DO viCpt = 1950 TO 2500:
       DtDatFev = DATE(02,29,viCpt) NO-ERROR.
       TbAnnBis[viCpt] = IF ERROR-STATUS:ERROR THEN 365 ELSE 366.
    END.   
    ***/ 
    /* Recherche si mode de calcul calendrier d'evolution des loyers */
    find last tache no-lock
        where tache.tptac = {&TYPETACHE-revision}
          and tache.tpcon = vcTypeContrat
          and tache.nocon = viNumeroLocataire no-error.
    /* Pas de calcul "calendrier d'evolution des loyers ====> pas de tache calendrier */
    if not available tache or tache.cdhon <> "00001" then return.

    /* Recherche si calendrier utilise pour le calcul */
    find first tache no-lock
        where tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}
          and tache.notac = 0
          and tache.tpcon = vcTypeContrat
          and tache.nocon = viNumeroLocataire no-error.
    if not available tache or tache.tphon = "no" then return.

    assign
        viNumeroRubrique = integer(tache.ntges)
        viNumeroLibelle  = integer(tache.tpges)
    .
    /* Recherche des dates d'entree et de sortie du locataire */
    find first tache no-lock 
        where tache.tptac = {&TYPETACHE-quittancement}
          and tache.tpcon = vcTypeContrat
          and tache.nocon = viNumeroLocataire no-error.
    if available tache then assign
        vdaDateEntree      = tache.dtdeb
        vdaSortieLocataire = tache.dtfin
        viNombreMois       = integer(substring(tache.pdges, 1, 3, "character"))
    .
    /* Recherche du loyer contractuel */
    find first tache no-lock
        where tache.tpcon = vcTypeContrat
          and tache.nocon = viNumeroLocataire
          and tache.tptac = {&TYPETACHE-loyerContractuel} no-error.
    vdMontantLoyerContractuel = if available tache then tache.mtreg else 0.
    for first ctrat no-lock
        where ctrat.tpcon = vcTypeContrat
          and ctrat.noCon = viNumeroLocataire:
            assign 
            vdaFinBail         = ctrat.dtfin
            vdaResiliationBail = ctrat.dtree
            vlTaciteReconduit  = (ctrat.tpren = "00001")    /* Info "Tacite Reconduction ? */
        .
    end.
    if vdaSortieLocataire <> ? and vdaResiliationBail <> ?
    then vdaSortieLocataire = minimum(vdaSortieLocataire, vdaResiliationBail).
    else do:
       if vdaResiliationBail <> ? then vdaDateSortie = vdaResiliationBail.
       if vdaSortieLocataire <> ? then vdaDateSortie = vdaSortieLocataire.
    end.

    /* Uniquement si module prolongation apres expiration non ouvert */
    find first pclie no-lock where pclie.tppar = "FGEXP" no-error.
    if not available pclie or pclie.zon01 = "00002" 
    then if not vlTaciteReconduit and vdaDateSortie = ? then vdaDateSortie = vdaFinBail.

    if vcTypeContrat = {&TYPECONTRAT-preBail} or vcTypeTraitement <> "CHGQTT-SIM"
    then for last calev no-lock    /* Recherche du dernier calendrier saisi: calendrier utilise  pour le calcul */
        where calev.tpcon = vcTypeContrat
          and calev.nocon = viNumeroLocataire:
        assign
            viNumeroCalendrier = calev.nocal
            vdaFinCalendrier   = calev.dtfin
        .
    end.
    else do:
        /* Recherche du calendrier à utiliser pour la quittance en cours */
blocCalev:
        for each calev no-lock
            where calev.tpcon = vcTypeContrat
              and calev.nocon = viNumeroLocataire:
            if calev.dtcal > vdaFinPeriode then leave blocCalev.

            viNumeroCalendrier = calev.nocal.
        end.
        /* Recherche du calendrier utilisé pour la quittance précédente */
        {&_proparse_ prolint-nowarn(use-index)}
blocQuittPrec:
        for last aquit no-lock
            where aquit.noloc = viNumeroLocataire 
              and Aquit.noqtt > 0 
              and Aquit.noqtt < viNumeroQuittance 
              and aquit.fgfac = no            /* ajout SY le 03/03/2008 */
            use-index ix_aquit03
          , each calev no-lock
            where calev.tpcon = vcTypeContrat
              and calev.nocon = viNumeroLocataire:
            if calev.dtcal > aquit.dtfpr then leave blocQuittPrec.

            viCalendrierPrecedent = calev.nocal.
        end.
    end.
    /* calendrier précédent pour calcul rub 105 */
    find last calev no-lock
        where calev.tpcon = vcTypeContrat
          and calev.nocon = viNumeroLocataire
          and calev.nocal < viNumeroCalendrier no-error.
    if available calev then viNumeroCalendrierPrecedent = calev.nocal.
    if glDebug then do:
        put stream StFicSor unformatted skip(1)
            ">>> " string(today, "99/99/9999") " " string(time, "HH:MM:SS") skip
            "Locataire  " viNumeroLocataire "  Calendrier no: " viNumeroCalendrier skip
            "Traitement = " vcTypeTraitement " vlModificationMontant = " vlModificationMontant 
            " viNumeroPeriode = " viNumeroPeriode "  Nouveau calcul : " string(vlCalendrierEvolution) skip.
        if vcTypeTraitement  = "CALID"
        then put stream StFicSor unformatted "Date rev = " string(vdaIndexation, "99/99/9999").
        put stream StFicSor unformatted
            " Quitt " viNumeroQuittance " du " string(vdaDebutPeriode,"99/99/9999") "-" string(vdaFinPeriode, "99/99/9999") skip.
    end.
    {&_proparse_ prolint-nowarn(release)}
    release calev no-error.
    for each calev no-lock
        where calev.tpcon = vcTypeContrat
          and calev.nocon = viNumeroLocataire
          and calev.nocal = viNumeroCalendrier:
        create ttCalendrierEvolutionLoyer.
        assign
            ttCalendrierEvolutionLoyer.noper = calev.noper
            ttCalendrierEvolutionLoyer.dtdeb = calev.dtdeb
            ttCalendrierEvolutionLoyer.dtfin = calev.dtfin
            ttCalendrierEvolutionLoyer.mtper = calev.mtper
        .
    end.
    if available calev and calev.dtfin <> ? then do:
        create ttCalendrierEvolutionLoyer.
        assign
            ttCalendrierEvolutionLoyer.noper = calev.noper + 1
            ttCalendrierEvolutionLoyer.dtdeb = calev.dtfin + 1
            ttCalendrierEvolutionLoyer.dtfin = ?
            ttCalendrierEvolutionLoyer.mtper = vdMontantLoyerContractuel
        .
    end.

    /* Ajout SY le 30/04/2008 : forçage calculs rappel/avoir changement valeur calendrier */
    if vcTypeTraitement = "CHGQTT-SIM" 
    and viCalendrierPrecedent <> 0 and viNumeroCalendrier <> viCalendrierPrecedent   /* si changement de calendrier par rapport à la quittance précédente */
    then do:
        /* Recherche du palier contenant le dernier jour du terme */
        viNumeroPeriode = 0.
        for each ttCalendrierEvolutionLoyer:
            if vdaDebutPeriode >= ttCalendrierEvolutionLoyer.dtdeb 
            and ((ttCalendrierEvolutionLoyer.dtfin <> ? and vdaFinPeriode <= ttCalendrierEvolutionLoyer.dtfin)
               or ttCalendrierEvolutionLoyer.dtfin = ?)
            then viNumeroPeriode = ttCalendrierEvolutionLoyer.noper.
        end.
        if viNumeroPeriode > 0 then vlModificationMontant = yes.
    end.
    if vlCalendrierEvolution and viNumeroCalendrierPrecedent > 0 
    then do:
        {&_proparse_ prolint-nowarn(release)}
        release calev no-error.
        for each calev no-lock
            where calev.tpcon = vcTypeContrat
              and calev.nocon = viNumeroLocataire
              and calev.nocal = viNumeroCalendrierPrecedent:
            create ttCalendrierEvolutionLoyer-prc.
            assign
                ttCalendrierEvolutionLoyer-prc.noper = calev.noper 
                ttCalendrierEvolutionLoyer-prc.dtdeb = calev.dtdeb
                ttCalendrierEvolutionLoyer-prc.dtfin = calev.dtfin
                ttCalendrierEvolutionLoyer-prc.mtper = calev.mtper
            .
        end.
        if available calev and calev.dtfin <> ? then do:
            create ttCalendrierEvolutionLoyer-prc.
            assign
                ttCalendrierEvolutionLoyer-prc.noper = calev.noper + 1
                ttCalendrierEvolutionLoyer-prc.dtdeb = calev.dtfin + 1
                ttCalendrierEvolutionLoyer-prc.dtfin = ?
                ttCalendrierEvolutionLoyer-prc.mtper = vdMontantLoyerContractuel. 
        end.
    end.
    if glDebug then do:
        put stream StFicSor unformatted "Echeancier ttCalendrierEvolutionLoyer" skip.
        for each ttCalendrierEvolutionLoyer:
            export stream StFicSor ttCalendrierEvolutionLoyer.
        end.
        put stream StFicSor unformatted skip "Echeancier précédent ttCalendrierEvolutionLoyer-prc" skip.
        for each ttCalendrierEvolutionLoyer-prc:
            export stream StFicSor ttCalendrierEvolutionLoyer-prc.
        end.
        put stream StFicSor unformatted " " skip.
    end.

    if vlCalendrierEvolution
    then run calculCalno2(viNumeroLocataire, viNumeroRubrique, viNumeroQuittance, viNombreMois, viNumeroLibelle, vdaIndexation, output vcLbdivcal).
    else run calculCalno1(viNumeroLocataire, viNumeroRubrique, viNumeroQuittance, viNombreMois, viNumeroLibelle, output vcLbdivcal).

    /* Calcul du montant de regularisation dans le cas ou on modifie le montant d'une periode
       qui a deja ete utilise pour calculer un loyer deja quittance */
    if vlModificationMontant
    then for first ttQtt 
        where ttQtt.noloc = viNumeroLocataire
          and ttQtt.noqtt = (if vcTypeTraitement = "CHGQTT-SIM" then viNumeroQuittance else ttQtt.noqtt):

        if glDebug then put stream StFicSor unformatted skip(1)
            "Calcul Regul " vcTypeTraitement " - Quittancement de " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999") " viNumeroPeriode = " viNumeroPeriode skip
        .
        {&_proparse_ prolint-nowarn(sortaccess)}
boucleAquit:
        for each aquit no-lock
            where aquit.noloc = viNumeroLocataire 
              and aquit.fgfac = no            /* Ajout SY le 28/01/2008 */
            by aquit.msqtt:
            if vcTypeTraitement = "CHGQTT-SIM" and aquit.noqtt >= viNumeroQuittance then leave boucleAquit.   /* Modif SY le 30/04/2008 pour CHGQTT-SIM */

            vdMontantRubrique = 0.
            /* filtre sur la période modifiée si existe sinon calcul Régul sur TOUT le quittancement */
            find first ttCalendrierEvolutionLoyer where ttCalendrierEvolutionLoyer.noper = viNumeroPeriode no-error.
            if available ttCalendrierEvolutionLoyer 
            then do:
                assign
                    vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer.dtdeb,vdaDateEntree)
                    vdaFinCalendrier   = if vdaDateSortie = ? 
                                         then if ttCalendrierEvolutionLoyer.dtfin <> ? then ttCalendrierEvolutionLoyer.dtfin else 12/31/9999
                                         else if ttCalendrierEvolutionLoyer.dtfin <> ? then minimum(ttCalendrierEvolutionLoyer.dtfin,vdaDateSortie) else vdaDateSortie
                .
                if vdaDebutCalendrier > vdaFinCalendrier
                or vdaFinCalendrier < aquit.dtdpr or vdaDebutCalendrier > aquit.dtfpr then next boucleAquit.
            end.
            run calRubLoy(aquit.dtdpr, aquit.dtfpr, output vdMontantRubrique).
            if glDebug then put stream StFicSor unformatted
                "Regul modif montant  - Quit concerne = " string(aquit.dtdpr, "99/99/9999") "-" string(aquit.dtfpr, "99/99/9999")
                " Montant calculé = " vdMontantRubrique " Cumul = " (vdMontantReg + vdMontantRubrique) skip.
            if vdMontantRubrique <> 0 then do:
                vdMontantHistorique = 0.
                if vcTypeTraitement <> "CHGQTT-SIM" then do:
                    /* La nouvelle 04130 n'est pas encore créée, donc on récupère le dernière indexation du calendrier */
                    find last tache no-lock
                        where tache.tpcon = vcTypeContrat
                          and tache.nocon = viNumeroLocataire
                          and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer} no-error.
                    if available tache
                    then do viCpt = 1 to num-entries(tache.lbdiv, "#"):
                        if integer(entry(1, entry(viCpt, tache.lbdiv, "#"), "@")) = aquit.msqtt 
                        then vdMontantHistorique = decimal(entry(3, entry(viCpt, tache.lbdiv, "#"), "@")) / 100.
                    end.
                end.
                if vdMontantHistorique = 0 
                then vdMontantHistorique = (if integer(entry(1, aquit.tbrub[1], "|")) = viNumeroRubrique
                                           and integer(entry(2, aquit.tbrub[1], "|")) = viNumeroLibelle
                                            then decimal(entry(5, aquit.tbrub[1], "|"))
                                            else vdMontantHistorique).
                assign
                    vdMontantReg           = vdMontantReg + vdMontantRubrique
                    vdeMontantQuittance    = vdeMontantQuittance + vdMontantHistorique
                    vcLibelleHistoriqueQtt = substitute("&1&2@&3@&4#",
                                                 vcLibelleHistoriqueQtt,
                                                 string(aquit.msqtt, "999999"),
                                                 string(vdMontantHistorique * 100, "999999999999"),
                                                 string(vdMontantRubrique * 100, "999999999999"))
                .
            end.
        end.
        if glDebug then put stream StFicSor unformatted
             "Ecart Montant Calculé Calendrier - Montant Quittancé = " vdMontantReg " - " vdeMontantQuittance " = " (vdMontantReg - vdeMontantQuittance) skip.
        vdMontantReg = round(vdMontantReg - vdeMontantQuittance, 2).
        if vdMontantReg <> 0 then do:
            viNumeroLibelleRappelAvoir = if vdMontantReg > 0 then 48 else 98. /* Rappel / Avoir loyer */
            if glDebug then put stream StFicSor unformatted
                "Quitt " ttQtt.msqtt " create/maj  rub 103." viNumeroLibelleRappelAvoir " " vdMontantReg skip.
            find first rubqt no-lock
                where rubqt.cdrub = 103
                  and rubqt.cdlib = viNumeroLibelleRappelAvoir no-error.
            find first ttRub 
                where ttRub.noloc = ttQtt.noloc
                  and ttRub.noqtt = ttQtt.noqtt
                  and ttRub.norub = 103
                  and (ttRub.nolib = 48 or ttRub.nolib = 98) no-error.
            if not available ttRub then do:
                create ttRub.
                assign
                    ttRub.noloc = ttQtt.noloc
                    ttRub.noqtt = ttQtt.noqtt
                    ttRub.cdfam = if available rubqt then rubqt.cdfam else 0
                    ttRub.cdsfa = if available rubqt then rubqt.cdsfa else 0
                    ttRub.norub = 103
                    ttRub.nolib = viNumeroLibelleRappelAvoir
                    ttRub.cdgen = if available rubqt then rubqt.cdgen else ""
                    ttRub.cdsig = if available rubqt then rubqt.cdsig else ""
                    ttRub.cddet = "0"
                    ttRub.vlqte = 0
                    ttRub.vlpun = 0
                    ttRub.mttot = vdMontantReg
                    ttRub.cdpro = 0
                    ttRub.vlnum = ttQtt.nbnum
                    ttRub.vlden = ttQtt.nbden
                    ttRub.vlmtq = vdMontantReg
                    ttRub.dtdap = ttQtt.dtdpr
                    ttRub.dtfap = ttQtt.dtfpr
                    ttRub.chfil = ""
                    ttQtt.nbrub = ttQtt.nbrub + 1.
            end.
            else do:
                if vdMontantReg + ttRub.mttot = 0 then do:
                   ttQtt.nbrub = ttQtt.nbrub - 1.
                   delete ttRub.
                end.
                else do:
                    viNumeroLibelleRappelAvoir = if vdMontantReg + ttRub.mttot > 0 then 48 else 98. /* Rappel / Avoir loyer */
                    find first rubqt no-lock
                       where rubqt.cdrub = 103
                         and rubqt.cdlib = viNumeroLibelleRappelAvoir no-error.
                   if (ttRub.nolib  < 51 and vdMontantReg + ttRub.mttot >= 0) 
                   or (ttRub.nolib >= 51 and vdMontantReg + ttRub.mttot  < 0)
                   then assign 
                       ttRub.mttot = ttRub.mttot + vdMontantReg
                       ttRub.vlmtq = ttRub.vlmtq + vdMontantReg
                   .
                   else assign
                       ttRub.cdfam = if available rubqt then rubqt.cdfam else 0
                       ttRub.cdsfa = if available rubqt then rubqt.cdsfa else 0
                       ttRub.nolib = viNumeroLibelleRappelAvoir
                       ttRub.cdgen = if available rubqt then rubqt.cdgen else ""
                       ttRub.cdsig = if available rubqt then rubqt.cdsig else ""
                       ttRub.mttot = ttRub.mttot + vdMontantReg
                       ttRub.vlmtq = ttRub.mttot + vdMontantReg
                    .
                end.
            end.
        end.
    end.

    /* Mise a jour du montant des quittances */
    for each ttQtt
        where ttQtt.noloc = viNumeroLocataire
          and ttQtt.noqtt >= (if vcTypeTraitement = "CHGQTT-SIM" then viNumeroQuittance else ttQtt.noqtt):
        vdMontantQuittance = 0.
        for each ttRub 
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt:
            vdMontantQuittance = vdMontantQuittance + ttRub.vlmtq.
        end.
        assign
            ttQtt.mtqtt = vdMontantQuittance
            ttQtt.cdmaj = 1
        .
    end.
    /* CHGQTT : pas de modification du calendrier, juste maj qtt selon période */ 
    if not vcTypeTraitement begins "CHGQTT" then do:
        /* stockage de l'historique du calcul dans la table tache */
/* avec tache.p, pas la peine de recherche NxtTache.
        run AffecIdt(0, "NxtTache").
        run AffecIdt(1, {&TYPETACHE-calendrierEvolutionLoyer}).
        run AffecIdt(2, vcTypeContrat).
        run AffecIdt(3, string(viNumeroLocataire)).
/*        {RunPgExp.i &Path = RpRunLibADB &Prog = "'L_Tache_ext.p'"} */
        run RecupIdt(1, output LbTmpPdt).
        if LbTmpPdt = "0" 
        then do:
            pcCodeRetour = '01'.
            return.
        end.
        run RecupIdt(2, output LbIntRec).
        run RecupIdt(3, output LbTacRec).
*/
        run AffecIdt(0, "NewTache").
/*        run AffecIdt(1,  "").
        run AffecIdt(2,  LbIntRec).*/
        run AffecIdt(3,  {&TYPETACHE-calendrierEvolutionLoyer}).
/*        run AffecIdt(4,  LbTacRec).*/
        run AffecIdt(5,  vcTypeContrat).
        run AffecIdt(6,  string(viNumeroLocataire)).
        run AffecIdt(7,  "").
        run AffecIdt(8,  (if vdaIndexation <> ? then string(vdaIndexation , "99/99/9999") else "")).
        run AffecIdt(9,  "").
        run AffecIdt(10, string(viNumeroCalendrier)).
        run AffecIdt(11, (if vdaFinCalendrier = ? then "" else string(vdaFinCalendrier , "99/99/9999"))).   /* Modif SY le 07/05/2008 */
        run AffecIdt(12, "").
        run AffecIdt(13, "").
        run AffecIdt(14, (if viNumeroQuittance <> 0 then string(viNumeroQuittance) else "")).  /* PdGes */
        run AffecIdt(15, "").
        run AffecIdt(16, vcTypeTraitement).      /* ntreg */
        run AffecIdt(17, "").
        run AffecIdt(18, "").
        run AffecIdt(19, "").
        run AffecIdt(20, "").
        run AffecIdt(21, "").
        run AffecIdt(22, "").
        run AffecIdt(23, "").
        run AffecIdt(24, vcLibelleHistoriqueQtt + trim(vcLbdivcal, "#")).

/*        {RunPgExp.i &Path = RpRunLibADB &Prog = "'L_Tache_ext.p'"} */

 /*     run RecupIdt(1,output LbTmpPdt).
        if LbTmpPdt = "0" then pcCodeRetour = '02'.  */   /* La creation/maj de la tache %1 a echoue */
    end.

end procedure.

procedure CalculCalno1:
/* -------------------------------------------------------------------------
   Procedure de calcul des rubriques calendrier version no 1 : 
    - rub 101 proratée
    - pas de rub 105
   ----------------------------------------------------------------------- */
    define input  parameter piNumeroLocataire as integer no-undo.
    define input  parameter piNumeroRubrique  as integer no-undo.
    define input  parameter piNumeroQuittance as integer no-undo.
    define input  parameter piNombreMois      as integer no-undo.
    define input  parameter piNumeroLibelle   as integer no-undo.
    define output parameter pcLbdivcal        as character no-undo.

    /* Génération rub loyer sur toutes les quittances */
    run majRubLoy(
        piNumeroLocataire,
        piNumeroRubrique,
        piNumeroLibelle,
        piNumeroQuittance,
        false,
        piNombreMois,
        output pcLbdivcal
    ).
 
end procedure.

procedure CalculCalno2:
    /* -------------------------------------------------------------------------
     Purpose : Procedure de calcul des rubriques calendrier version no 2 (AGF) :
     notes   :
         - rub 101 = loyer complet du palier contenant la date de fin de période quitt
         - rub ??? = rappel/avoir changement de palier
         - rub 105 = rappel/avoir révision
   ----------------------------------------------------------------------- */
    define input  parameter piNumeroLocataire as integer   no-undo.
    define input  parameter piNumeroRubrique  as integer   no-undo.
    define input  parameter piNumeroQuittance as integer   no-undo.
    define input  parameter piNombreMois      as integer   no-undo.
    define input  parameter piNumeroLibelle   as integer   no-undo.
    define input  parameter pdaIndexation     as date      no-undo.
    define output parameter pcLbdivcal        as character no-undo.

    define variable viNombreJourPeriode        as integer   no-undo.
    define variable vdaDebutCalendrier         as date      no-undo.
    define variable vdaFinCalendrier           as date      no-undo.
    define variable vdaDateEntree              as date      no-undo.
    define variable vdaDateSortie              as date      no-undo.
    define variable vcTypeTraitement           as character no-undo.
    define variable vdaDebutPeriode            as date      no-undo.
    define variable vdaFinPeriode              as date      no-undo.
    define variable vdMontantTmp               as decimal   no-undo.
    define variable vdaDateDebut               as date      no-undo.
    define variable vdaDateFin                 as date      no-undo.
    define variable vdaDebutTmp                as date      no-undo.
    define variable vdaFinTmp                  as date      no-undo.
    define variable vhProcDate                 as handle    no-undo.
    define variable viNumeroLibelleRappelAvoir as integer   no-undo. /* no libellé rappel/Avoir rub 103 */
    define variable vdNouveauMontant           as decimal   no-undo.
    define variable vdMontantPeriode           as decimal   no-undo.
    define variable vdMontant105               as decimal   no-undo.
    define variable viNombreMoisPeriode        as integer   no-undo.
    define variable vdeMontantPro              as decimal   no-undo.
    define variable vdeMontantNrv              as decimal   no-undo.
    define variable viCompteur                 as integer   no-undo.
    define variable vlFuret                    as logical   no-undo.

    define buffer rubqt for rubqt.
    define buffer vbCalendrierEvolutionLoyer for ttCalendrierEvolutionLoyer.

    run application/l_prgdat.p persistent set vhProcDate.
    run getTokenInstance in vhProcDate(mToken:JSessionId).

    /* Génération rub loyer sur toutes les quittances */
    run majRubLoy(
        piNumeroLocataire,
        piNumeroRubrique,
        piNumeroLibelle,
        piNumeroQuittance,
        true,
        piNombreMois,
        output pcLbdivcal
    ).
    if vcTypeTraitement = "CALID"
    then do:
        /* Calcul rub 105 rappel/avoir loyer révisé sur quittance révisée */
        find first ttqtt
             where ttqtt.noloc = piNumeroLocataire
               and ttqtt.noqtt = piNumeroQuittance no-error.
        /* Suppression de tous les enreg concernant la quittance dans ttRub pour
           la rubrique 105 Rappel ou avoir révision loyer */
        for each ttRub
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt
              and ttRub.norub = 105
              and (ttRub.nolib = piNumeroLibelle or  ttRub.nolib = 50 + piNumeroLibelle):
            delete ttRub.
            ttQtt.nbrub = ttQtt.nbrub - 1.
        end.
        /* Loyer BRUT APRES révision (= palier complet) */
        find first ttRub
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt
              and ttRub.norub = piNumeroRubrique
              and ttRub.nolib = piNumeroLibelle no-error. 
        if available ttRub then vdNouveauMontant = ttRub.mttot.
        /* Si date de révision < date de début quittance Rappel pour la ou les qtts précédentes */
        if pdaIndexation < vdaDebutPeriode then do: 
            /* Recherche du terme de la révision */
            assign
                vdaDebutTmp = vdaDebutPeriode
                vdaFinTmp   = vdaFinPeriode
            .
            run nbrMoiPr2 in vhProcDate(vdaDebutTmp, vdaFinTmp, output viNombreMoisPeriode).
            assign 
                viCompteur = viNombreMoisPeriode * -1
                vlFuret = true
            .
            do while vlFuret:
                /* Retrait de la périodicité dtdeb */
                run cl2DatFin in vhProcDate(vdaDebutTmp, viCompteur, "00002", output vdaDebutTmp).
                /* Retrait de la périodicité dtfin */
                run cl2DatFin in vhProcDate(vdaFinTmp, viCompteur, "00002", output vdaFinTmp).
                if pdaIndexation >= vdaDebutTmp and pdaIndexation <= vdaFinTmp
                then vlFuret = false.
            end.
            /* Calcul Rappel loyer terme par terme Pour chaque palier du terme sauf le dernier */
            do while vdaDebutTmp < vdaDebutPeriode:
                viNombreJourPeriode = vdaFinTmp - vdaDebutTmp + 1.

                if glDebug then put stream StFicSor unformatted 
                    "CALID - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                    " Révision au " string(pdaIndexation, "99/99/9999")
                    " Boucle Termes précédents : " string(vdaDebutTmp, "99/99/9999") "-" string(vdaFinTmp, "99/99/9999") skip
                .
                /* si la révision n'est pas dans ce terme : rappel sur terme complet */
                if pdaIndexation < vdaDebutTmp then do:
                    if glDebug then put stream StFicSor unformatted
                        fill(" " , 8) "Rappel Terme Complet   Montant periode  = " vdMontantPeriode "  Cumul rappel = " vdeMontantNrv skip
                    .
boucleEvo:
                    for each ttCalendrierEvolutionLoyer-prc
                        where ttCalendrierEvolutionLoyer-prc.dtdeb < vdaFinTmp:
                        vdMontantPeriode = (ttCalendrierEvolutionLoyer-prc.mtper * piNombreMois) / 12.

                        if glDebug then put stream StFicSor unformatted 
                            "CALID - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                            " Boucle palier no " ttCalendrierEvolutionLoyer-prc.noper
                            " du " ttCalendrierEvolutionLoyer-prc.dtdeb " au " (if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then string(ttCalendrierEvolutionLoyer-prc.dtfin) else fill(" " , 10))
                            " montant rub 101 = " vdMontantPeriode skip
                        .
                        /* Recherche si le palier concerne le terme */
                        if ttCalendrierEvolutionLoyer-prc.dtfin <> ?
                        and ttCalendrierEvolutionLoyer-prc.dtfin < vdaDebutTmp then next boucleEvo.

                        if ttCalendrierEvolutionLoyer-prc.dtdeb > vdaFinTmp then leave boucleEvo.

                        assign
                            vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer-prc.dtdeb, vdaDateEntree, vdaDebutTmp)
                            vdaFinCalendrier   = if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then ttCalendrierEvolutionLoyer-prc.dtfin else 12/31/9999
                            vdaFinCalendrier   = minimum(vdaFinCalendrier, vdaFinTmp)
                        .
                        if vdaDebutCalendrier > vdaFinCalendrier
                        or vdaFinCalendrier < vdaDebutTmp or vdaDebutCalendrier > vdaFinTmp then next boucleEvo.

                        assign
                            vdMontantTmp = (vdNouveauMontant - vdMontantPeriode) * (vdaFinCalendrier - vdaDebutCalendrier + 1) / (vdaFinTmp - vdaDebutTmp + 1)
                            vdMontantTmp = round(vdMontantTmp, 2)
                            vdeMontantNrv     = vdeMontantNrv + vdMontantTmp
                        .
                        if glDebug then put stream StFicSor unformatted
                            "CALID - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                            " rappel/avoir calculé = " vdMontantTmp 
                            "     Détail : nb jours = " (vdaFinCalendrier - vdaDebutCalendrier + 1) 
                            " du " vdaDebutCalendrier " au " vdaFinCalendrier skip
                        .
                    end.
                end.
                else do:
boucleEvo-prc:
                    for each ttCalendrierEvolutionLoyer-prc:    /* rappel à partir de la date de révision */
                        if (ttCalendrierEvolutionLoyer-prc.dtfin <> ? and ttCalendrierEvolutionLoyer-prc.dtfin < vdaDebutTmp)
                        or (ttCalendrierEvolutionLoyer-prc.dtfin <> ? and ttCalendrierEvolutionLoyer-prc.dtfin < pdaIndexation) then next boucleEvo-prc.
    
                        if ttCalendrierEvolutionLoyer-prc.dtdeb > vdaFinTmp then leave boucleEvo-prc. 
    
                        vdMontantPeriode = (ttCalendrierEvolutionLoyer-prc.mtper * piNombreMois) / 12.

                        if glDebug then put stream StFicSor unformatted
                            "CALID - Terme concerne = " string(vdaDebutTmp, "99/99/9999") "-" string(vdaFinTmp, "99/99/9999")              
                            " Boucle palier no " ttCalendrierEvolutionLoyer-prc.noper
                            " du " ttCalendrierEvolutionLoyer-prc.dtdeb " au " (if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then string(ttCalendrierEvolutionLoyer-prc.dtfin) else fill(" " , 10))
                            " montant rub 101 = " vdMontantPeriode skip
                        .
                        assign 
                            vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer-prc.dtdeb, vdaDateEntree, pdaIndexation)
                            vdaFinCalendrier   = if vdaDateSortie = ? 
                                                 then if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then ttCalendrierEvolutionLoyer-prc.dtfin else 12/31/9999
                                                 else if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then minimum(ttCalendrierEvolutionLoyer-prc.dtfin, vdaDateSortie) else vdaDateSortie
                        .
                        if vdaDebutCalendrier > vdaFinCalendrier
                        or vdaFinCalendrier < vdaDebutTmp or vdaDebutCalendrier > vdaFinTmp then next boucleEvo-prc.
    
                        /* periode concernee : [dtdpr,dtfin] */
                        if vdaDebutCalendrier < vdaDebutTmp and vdaFinCalendrier >= vdaDebutTmp and vdaFinCalendrier <= vdaFinTmp
                        then assign
                            vdaDateDebut = vdaDebutTmp
                            vdaDateFin   = vdaFinCalendrier
                        .
                        /* periode concernee : [dtdpr,dtfpr] */
                        if vdaDebutCalendrier < vdaDebutTmp and vdaFinCalendrier > vdaFinTmp 
                        then assign
                            vdaDateDebut = vdaDebutTmp
                            vdaDateFin   = vdaFinTmp
                        .
                        /* periode concernee : [ttCalendrierEvolutionLoyer-prc.dtdeb,ttCalendrierEvolutionLoyer-prc.dtfin] */
                        if vdaDebutCalendrier >= vdaDebutTmp and vdaFinCalendrier <= vdaFinTmp 
                        then assign
                            vdaDateDebut = vdaDebutCalendrier
                            vdaDateFin = vdaFinCalendrier
                        .
                        /* periode concernee : [ttCalendrierEvolutionLoyer-prc.dtdeb,vdaFinTmp] */
                        if vdaDebutCalendrier >= vdaDebutTmp and vdaDebutCalendrier <= vdaFinTmp and vdaFinCalendrier > vdaFinTmp 
                        then assign
                            vdaDateDebut = vdaDebutCalendrier
                            vdaDateFin   = vdaFinTmp
                        .
                        assign
                            vdMontantTmp = (vdNouveauMontant - vdMontantPeriode) * (vdaDateFin - vdaDateDebut + 1) / viNombreJourPeriode
                            vdeMontantNrv = vdeMontantNrv + vdMontantTmp
                        .
                        if glDebug then put stream StFicSor unformatted
                            fill(" " , 8) "Prorata Terme de la révision - periode concernee = " string(vdaDebutTmp, "99/99/9999") "-" string(vdaFinTmp, "99/99/9999") 
                            " montant annuel = " ttCalendrierEvolutionLoyer-prc.mtper
                            " nb jours = " (vdaDateFin - vdaDateDebut + 1)
                            " Montant periode  = " vdMontantPeriode " Prorata = " vdMontantTmp skip
                        .
                    end.
                end.
                /* Terme suivant */
                run cl2DatFin in vhProcDate(vdaDebutTmp, viNombreMoisPeriode, "00002", output vdaDebutTmp).
                run cl2DatFin in vhProcDate(vdaFinTmp,   viNombreMoisPeriode, "00002", output vdaFinTmp).
            end.
            vdeMontantNrv = round(vdeMontantNrv, 2).
        end.

        /* Si date de révision comprise entre la date de début et date de fin quittance: prorata.
           Création rubrique d'Avoir sur la période comprise entre date de début qtt et date révis */
        if pdaIndexation > vdaDebutPeriode and pdaIndexation <= vdaFinPeriode
        then for each ttCalendrierEvolutionLoyer:      /* Recherche du palier contenant le dernier jour du terme */
            /* recherche palier Rub loyer 101 */
            if ttQtt.dtfpr >= ttCalendrierEvolutionLoyer.dtdeb 
            and (ttCalendrierEvolutionLoyer.dtfin = ? or ttQtt.dtfpr <= ttCalendrierEvolutionLoyer.dtfin)
            then do:
                if glDebug then put stream StFicSor unformatted skip(1)
                    "CALID - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                    " Palier utilisé = " ttCalendrierEvolutionLoyer.noper
                    " du " ttCalendrierEvolutionLoyer.dtdeb " au " (if ttCalendrierEvolutionLoyer.dtfin <> ? then string(ttCalendrierEvolutionLoyer.dtfin) else fill(" " , 10) )
                    " " ttCalendrierEvolutionLoyer.mtper " montant rub 101 = " (ttCalendrierEvolutionLoyer.mtper * piNombreMois) / 12 skip
                .
                /* il faut boucler sur les paliers < date de révision */
boucleEvo:
                for each vbCalendrierEvolutionLoyer
                   where vbCalendrierEvolutionLoyer.noper < ttCalendrierEvolutionLoyer.noper
                     and vbCalendrierEvolutionLoyer.dtdeb < pdaIndexation:
                    vdMontantPeriode = (vbCalendrierEvolutionLoyer.mtper * piNombreMois) / 12.

                    if glDebug then put stream StFicSor unformatted
                        "CALID - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                        " Boucle palier précédents: no " vbCalendrierEvolutionLoyer.noper
                        " du " vbCalendrierEvolutionLoyer.dtdeb " au " (if vbCalendrierEvolutionLoyer.dtfin <> ? then string(vbCalendrierEvolutionLoyer.dtfin) else fill(" " , 10))
                        " montant rub 101 = " vdMontantPeriode skip
                    .
                    /* Recherche si le palier concerne le terme */
                    if vbCalendrierEvolutionLoyer.dtfin <> ? and ttCalendrierEvolutionLoyer.dtfin < vdaDebutPeriode then next boucleEvo.

                    if vbCalendrierEvolutionLoyer.dtdeb > vdaFinPeriode then leave boucleEvo.

                    assign
                        vdaDebutCalendrier = maximum(vbCalendrierEvolutionLoyer.dtdeb,vdaDateEntree, ttQtt.dtdpr)
                        vdaFinCalendrier   = if vdaDateSortie = ?
                                             then if vbCalendrierEvolutionLoyer.dtfin <> ? then vbCalendrierEvolutionLoyer.dtfin else 12/31/9999
                                             else if vbCalendrierEvolutionLoyer.dtfin <> ? then minimum(vbCalendrierEvolutionLoyer.dtfin,vdaDateSortie) else vdaDateSortie
                    .
                    if vdaDebutCalendrier > vdaFinCalendrier
                    or vdaFinCalendrier < vdaDebutPeriode or vdaDebutCalendrier > vdaFinPeriode then next boucleEvo.                         /* Aucun calcul */

                    assign
                        vdMontantTmp = (vdNouveauMontant - vdMontantPeriode) * (vbCalendrierEvolutionLoyer.dtfin - vdaDebutCalendrier + 1) / (vdaFinPeriode - vdaDebutPeriode + 1)
                        vdMontantTmp = round(vdMontantTmp, 2)
                        vdeMontantPro     = vdeMontantPro + vdMontantTmp
                    .
                    if glDebug then put stream StFicSor unformatted
                        "CALID - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                        " rappel/avoir calculé = " vdMontantTmp 
                        "     Détail : nb jours = " (vbCalendrierEvolutionLoyer.dtfin - vdaDebutCalendrier + 1) 
                        " du " vdaDebutCalendrier " au " (if vbCalendrierEvolutionLoyer.dtfin <> ? then string( vbCalendrierEvolutionLoyer.dtfin ) else fill(" " , 10)) skip
                    .
                end.
                leave.
            end. /* palier trouvé */
        end.
        if vdeMontantPro <> 0 then vdMontant105 = - vdeMontantPro.
        if vdeMontantNrv <> 0 then vdMontant105 = vdeMontantNrv.
        if vdMontant105 <> 0 then for first ttQtt
            where ttQtt.noloc = piNumeroLocataire
              and ttQtt.noqtt = piNumeroQuittance:
            /* Rappel loyer ou avoir loyer */
            viNumeroLibelleRappelAvoir = if vdMontant105 > 0 then piNumeroLibelle else (50 + piNumeroLibelle).
            find first rubqt no-lock
                where rubqt.cdrub = 105
                  and rubqt.cdlib = viNumeroLibelleRappelAvoir no-error.
            find first ttRub
                where ttRub.noloc = ttQtt.noloc
                  and ttRub.noqtt = ttQtt.noqtt
                  and ttRub.norub = 105
                  and ttRub.nolib = viNumeroLibelleRappelAvoir no-error.
            if not available ttRub then do:
                create ttRub.
                assign
                    ttRub.noloc = ttQtt.noloc
                    ttRub.noqtt = ttQtt.noqtt
                    ttRub.cdfam = if available rubqt then rubqt.cdfam else 0
                    ttRub.cdsfa = if available rubqt then rubqt.cdsfa else 0
                    ttRub.norub = 105
                    ttRub.nolib = viNumeroLibelleRappelAvoir
                    ttRub.cdgen = if available rubqt then rubqt.cdgen else ""
                    ttRub.cdsig = if available rubqt then rubqt.cdsig else ""
                    ttRub.cddet = "0"
                    ttRub.vlqte = 0
                    ttRub.vlpun = 0
                    ttRub.mttot = vdMontant105
                    ttRub.cdpro = 0
                    ttRub.vlnum = ttQtt.nbnum
                    ttRub.vlden = ttQtt.nbden
                    ttRub.vlmtq = vdMontant105
                    ttRub.dtdap = ttQtt.dtdpr
                    ttRub.dtfap = ttQtt.dtfpr
                    ttRub.chfil = ""
                    ttQtt.nbrub = ttQtt.nbrub + 1
               .
            end.
            else do:
                if vdMontant105 + ttRub.mttot = 0 
                then do:
                   ttQtt.nbrub = ttQtt.nbrub - 1.
                   delete ttRub.
                end.
                else do:
                    if vdMontant105 + ttRub.mttot > 0 
                    then find first rubqt no-lock             /*- Rappel loyer -*/
                        where rubqt.cdrub = 105
                          and rubqt.cdlib = 01 no-error.
                    else find first rubqt no-lock             /*- Avoir loyer -*/
                        where rubqt.cdrub = 105
                          and rubqt.cdlib = 51 no-error.
                    if (ttRub.nolib  < 51 and vdMontant105 + ttRub.mttot >= 0) 
                    or (ttRub.nolib >= 51 and vdMontant105 + ttRub.mttot  < 0)
                    then assign 
                        ttRub.mttot = ttRub.mttot + vdMontant105
                        ttRub.vlmtq = ttRub.vlmtq + vdMontant105
                    .
                    else assign
                        ttRub.cdfam = if available rubqt then rubqt.cdfam else 0
                        ttRub.cdsfa = if available rubqt then rubqt.cdsfa else 0
                        ttRub.nolib = ttRub.nolib + (50 * (if ttRub.nolib < 51 then 1 else -1))
                        ttRub.cdgen = if available rubqt then rubqt.cdgen else ""
                        ttRub.cdsig = if available rubqt then rubqt.cdsig else ""
                        ttRub.mttot = ttRub.mttot + vdMontant105
                        ttRub.vlmtq = ttRub.mttot + vdMontant105
                    .
                end.
            end.
        end.
    end.
    /* Sur toutes les quittances: Calcul Rappel/Avoir changement de palier => Génération rub 103.xx */
    run majRubEcart(piNumeroLocataire, piNumeroQuittance, piNombreMois).
    if valid-handle(vhProcDate) then run destroy in vhProcDate.

end procedure.

procedure CalRubLoy:
    /* ----------------------------------------------------------------------
     Procedure de calcul du montant de la rubrique soumise au calendrier
     pour un mois de quitt                                              
    ----------------------------------------------------------------------- */
    define input  parameter pdaDebutPeriode    as date    no-undo.
    define input  parameter pdaFinPeriode      as date    no-undo.
    define input  parameter piNombreMois       as integer no-undo.
    define output parameter pdMontantRubrique  as decimal no-undo.

    define variable vdaDebutCalendrier  as date     no-undo.
    define variable vdaFinCalendrier    as date     no-undo.
    define variable vdMontantTmp        as decimal  no-undo.
    define variable vdaDateEntree       as date     no-undo.
    define variable vdaDateSortie       as date     no-undo.
    define variable vdaDateDebut        as date     no-undo.
    define variable vdaDateFin          as date     no-undo.
    define variable viNombreJourPeriode as integer  no-undo.

    viNombreJourPeriode = pdaFinPeriode - pdaDebutPeriode + 1.
boucleEvo:
    for each ttCalendrierEvolutionLoyer:
        /* Ajout SY le 06/05/2008 : Calendrier > quittance traitée */
        if ttCalendrierEvolutionLoyer.dtdeb > pdaFinPeriode then leave boucleEvo.

        if glDebug then put stream StFicSor unformatted
            "boucle ttCalendrierEvolutionLoyer Qtt du " string(pdaFinPeriode, "99/99/9999") " au " (if pdaFinPeriode <> ? then string(pdaFinPeriode, "99/99/9999") else "")
            " Periode no " ttCalendrierEvolutionLoyer.noper
            " du " string(ttCalendrierEvolutionLoyer.dtdeb, "99/99/9999") " au " (if ttCalendrierEvolutionLoyer.dtfin <> ? then string(ttCalendrierEvolutionLoyer.dtfin, "99/99/9999") else "")
            " montant annuel = " ttCalendrierEvolutionLoyer.mtper
            " montant periode = " (ttCalendrierEvolutionLoyer.mtper * piNombreMois) / 12
            " nb jour periode = " viNombreJourPeriode skip
        .
        assign
            vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer.dtdeb, vdaDateEntree)
            vdaFinCalendrier   = if vdaDateSortie = ? 
                                 then if ttCalendrierEvolutionLoyer.dtfin <> ? then ttCalendrierEvolutionLoyer.dtfin else 12/31/9999
                                 else if ttCalendrierEvolutionLoyer.dtfin <> ? then minimum(ttCalendrierEvolutionLoyer.dtfin, vdaDateSortie) else vdaDateSortie
        .
        if vdaDebutCalendrier > vdaFinCalendrier
        or vdaFinCalendrier < pdaDebutPeriode or vdaDebutCalendrier > pdaFinPeriode then next boucleEvo.

        /* Si la periode de quittancement est totalement comprise dans une periode du   */
        /* calendrier, on divise le montant par le nombre de periode(s) de quittancment */
        /* dans une annee                                                               */
        if vdaDebutCalendrier <= pdaDebutPeriode and vdaFinCalendrier >= pdaFinPeriode 
        then assign
            vdMontantTmp      = (ttCalendrierEvolutionLoyer.mtper * piNombreMois) / 12
            pdMontantRubrique = pdMontantRubrique + vdMontantTmp
        .
        else do:
            /* periode concernee : [dtdpr,dtfin] */
            if vdaDebutCalendrier < pdaDebutPeriode and vdaFinCalendrier >= pdaDebutPeriode and vdaFinCalendrier <= pdaFinPeriode
            then assign
                vdaDateDebut = pdaDebutPeriode
                vdaDateFin   = vdaFinCalendrier
            .
            /* periode concernee : [dtdpr,dtfpr] */
            if vdaDebutCalendrier < pdaDebutPeriode and vdaFinCalendrier > pdaFinPeriode
            then assign
                vdaDateDebut = pdaDebutPeriode
                vdaDateFin   = pdaFinPeriode
            .
            /* periode concernee : [ttCalendrierEvolutionLoyer.dtdeb,ttCalendrierEvolutionLoyer.dtfin] */
            if vdaDebutCalendrier >= pdaDebutPeriode and vdaFinCalendrier <= pdaFinPeriode
            then assign
                vdaDateDebut = vdaDebutCalendrier
                vdaDateFin   = vdaFinCalendrier
            .
            /* periode concernee : [ttCalendrierEvolutionLoyer.dtdeb,ttQtt.dtfpr] */
            if vdaDebutCalendrier >= pdaDebutPeriode and vdaDebutCalendrier <= pdaFinPeriode and vdaFinCalendrier > pdaFinPeriode
            then assign
                vdaDateDebut = vdaDebutCalendrier
                vdaDateFin   = pdaFinPeriode
            .
            if year(vdaDateDebut) <> YEAR(vdaDateFin)
            then vdMontantTmp = (((ttCalendrierEvolutionLoyer.mtper * piNombreMois) / 12) / viNombreJourPeriode)
                                * (date(12, 31, year(vdaDateDebut)) - vdaDateDebut + 1)
                              + (((ttCalendrierEvolutionLoyer.mtper * piNombreMois) / 12) / viNombreJourPeriode)
                                * (vdaDateFin - date(01, 01, year(vdaDateFin)) + 1).
            else vdMontantTmp = (((ttCalendrierEvolutionLoyer.mtper * piNombreMois) / 12) / viNombreJourPeriode)
                                * (vdaDateFin - vdaDateDebut + 1).
            pdMontantRubrique = pdMontantRubrique + vdMontantTmp.
            if glDebug then put stream StFicSor unformatted
                "periode concernee = " string(vdaDateDebut, "99/99/9999") + "-" + string(vdaDateFin, "99/99/9999")
                " montant annuel = " ttCalendrierEvolutionLoyer.mtper
                " nb jours = " (vdaDateFin - vdaDateDebut + 1)
                " Montant periode = " vdMontantTmp skip
            .
        end.
    end.
    pdMontantRubrique = round(pdMontantRubrique, 2).

end procedure.

procedure CalRubLoy-prc:
/* -------------------------------------------------------------------------
   Procedure de calcul du montant de la rubrique soumise au calendrier
   précédent pour un mois de quitt
   ----------------------------------------------------------------------- */
    define input  parameter pdaDebPeriode     as date    no-undo.
    define input  parameter pdaFinPeriode     as date    no-undo.
    define output parameter pdMontantRubrique as decimal no-undo.

    define variable vdaDebutCalendrier  as date    no-undo.
    define variable vdaFinCalendrier    as date    no-undo.
    define variable vdaDateDebut        as date    no-undo.
    define variable vdaDateFin          as date    no-undo.
    define variable vdaDateEntree       as date    no-undo.
    define variable vdaDateSortie       as date    no-undo.
    define variable viNombreMois        as integer no-undo.
    define variable viNombreJourPeriode as integer no-undo.

    viNombreJourPeriode = pdaFinPeriode - pdaDebPeriode + 1.
boucleEvo:
    for each ttCalendrierEvolutionLoyer-prc:

        if glDebug then put stream StFicSor unformatted 
            "boucle ttCalendrierEvolutionLoyer-prc Qtt du " string(pdaDebPeriode, "99/99/9999") " au " (if pdaFinPeriode <> ? then string(pdaFinPeriode, "99/99/9999") else "")
            " Periode no " ttCalendrierEvolutionLoyer-prc.noper
            " du " string(ttCalendrierEvolutionLoyer-prc.dtdeb, "99/99/9999") " au " (if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then string(ttCalendrierEvolutionLoyer-prc.dtfin, "99/99/9999") else "")
            " montant annuel = " ttCalendrierEvolutionLoyer-prc.mtper
            " montant periode = " (ttCalendrierEvolutionLoyer-prc.mtper * viNombreMois) / 12
            " nb jour periode = " viNombreJourPeriode skip
        .
        assign
            vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer-prc.dtdeb,vdaDateEntree)
            vdaFinCalendrier   = if vdaDateSortie = ? 
                                 then if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then ttCalendrierEvolutionLoyer-prc.dtfin else 12/31/9999
                                 else if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then minimum(ttCalendrierEvolutionLoyer-prc.dtfin, vdaDateSortie) else vdaDateSortie
        .
        if vdaDebutCalendrier > vdaFinCalendrier
        or vdaFinCalendrier < pdaDebPeriode or vdaDebutCalendrier > pdaFinPeriode then next boucleEvo.

        /* Si la periode de quittancement est totalement comprise dans une periode du   */
        /* calendrier, on divise le montant par le nombre de periode(s) de quittancment */
        /* dans une annee                                                               */
        if vdaDebutCalendrier <= pdaDebPeriode and vdaFinCalendrier >= pdaFinPeriode
        then pdMontantRubrique = pdMontantRubrique + (ttCalendrierEvolutionLoyer-prc.mtper * viNombreMois) / 12.
        else do:
            /* periode concernee : [dtdpr,dtfin] */
            if vdaDebutCalendrier < pdaDebPeriode and vdaFinCalendrier >= pdaDebPeriode and vdaFinCalendrier <= pdaFinPeriode
            then assign
                vdaDateDebut = pdaDebPeriode
                vdaDateFin   = vdaFinCalendrier
            .
            /* periode concernee : [dtdpr,dtfpr] */
            if vdaDebutCalendrier < pdaDebPeriode and vdaFinCalendrier > pdaFinPeriode
            then assign
                vdaDateDebut = pdaDebPeriode
                vdaDateFin   = pdaFinPeriode
            .
            /* periode concernee : [ttCalendrierEvolutionLoyer-prc.dtdeb,ttCalendrierEvolutionLoyer-prc.dtfin] */
            if vdaDebutCalendrier >= pdaDebPeriode and vdaFinCalendrier <= pdaFinPeriode
            then assign
                vdaDateDebut = vdaDebutCalendrier
                vdaDateFin   = vdaFinCalendrier
            .
            /* periode concernee : [ttCalendrierEvolutionLoyer-prc.dtdeb,ttQtt.dtfpr] */
            if vdaDebutCalendrier >= pdaDebPeriode and vdaDebutCalendrier <= pdaFinPeriode and vdaFinCalendrier > pdaFinPeriode
            then assign
                vdaDateDebut = vdaDebutCalendrier
                vdaDateFin   = pdaFinPeriode
            .
            if glDebug then put stream StFicSor unformatted
                "periode concernee = " string(vdaDateDebut, "99/99/9999") "-" string(vdaDateFin, "99/99/9999")
                " montant annuel = " ttCalendrierEvolutionLoyer-prc.mtper
                " nb jours = " (vdaDateFin - vdaDateDebut + 1)
                " Montant periode = " ((ttCalendrierEvolutionLoyer-prc.mtper * viNombreMois) / 12) * (vdaDateFin - vdaDateDebut + 1) skip
            .
            if year(vdaDateDebut) <> YEAR(vdaDateFin)
            then pdMontantRubrique = pdMontantRubrique
                                   + (((ttCalendrierEvolutionLoyer-prc.mtper * viNombreMois) / 12) / viNombreJourPeriode)
                                    * (date(12, 31, year(vdaDateDebut)) - vdaDateDebut + 1)
                                   + (((ttCalendrierEvolutionLoyer-prc.mtper * viNombreMois) / 12) / viNombreJourPeriode )
                                    * (vdaDateFin - date(01, 01, year(vdaDateFin)) + 1).
            else pdMontantRubrique = pdMontantRubrique + (((ttCalendrierEvolutionLoyer-prc.mtper * viNombreMois) / 12) / viNombreJourPeriode)
                                    * (vdaDateFin - vdaDateDebut + 1).
        end.
    end.
    pdMontantRubrique = round(pdMontantRubrique, 2).

end procedure.

procedure MajRubLoy:
    /*-------------------------------------------------------------------------
    Purpose: génération des rub loyer dans ttQtt/ttRub pour tous les mois
    Notes: NB si entrée/sortie locataire, cette rubrique sera ensuite proratée par calproqt.p
    ----------------------------------------------------------------------- */
    define input  parameter piNumeroLocataire as integer   no-undo.
    define input  parameter piNumeroRubrique  as integer   no-undo.
    define input  parameter piNumeroLibelle   as integer   no-undo.
    define input  parameter piNumeroQuittance as integer   no-undo.
    define input  parameter plFlagNew         as logical   no-undo.
    define input  parameter piNombreMois      as integer   no-undo.
    define output parameter pcLbdivcal        as character no-undo.

    define variable vdMontantQuittance  as decimal   no-undo.
    define variable vcTypeTraitement    as character no-undo.
    define variable vdMontantTotalLoyer as decimal   no-undo.
    define variable vdMontantQttLoyer   as decimal   no-undo.
    define variable vdMontantRubrique   as decimal   no-undo.
    define buffer rubqt for rubqt.
    define buffer pclie for pclie.

    find first rubqt no-lock
        where rubqt.cdrub = piNumeroRubrique
          and rubqt.cdlib = piNumeroLibelle no-error.
    /* Calcul du montant loyer suivant le calendrier */
    for each ttQtt 
       where ttQtt.noloc = piNumeroLocataire
         and ttQtt.noqtt >= (if vcTypeTraitement = "CHGQTT-SIM" then piNumeroQuittance else ttQtt.noqtt):
        if plFlagNew then do:
            /* Recherche du palier contenant le dernier jour du terme */
            vdMontantRubrique = 0.
            for each ttCalendrierEvolutionLoyer:
                if ttQtt.dtfpr >= ttCalendrierEvolutionLoyer.dtdeb 
                and (ttCalendrierEvolutionLoyer.dtfin = ? or ttQtt.dtfpr <= ttCalendrierEvolutionLoyer.dtfin)
                then vdMontantRubrique = (ttCalendrierEvolutionLoyer.mtper * piNombreMois) / 12.
            end.
        end.
        else run CalRubLoy(ttQtt.dtdpr, ttQtt.dtfpr, output vdMontantRubrique).

        /* Si pas multilibellé : suppression des rubriques 101 déjà présentes */ 
        find first pclie no-lock
             where pclie.tppar = "RUBML" no-error.
        if not available pclie or pclie.zon01 <> "00001"
        then for each ttRub
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt
              and ttRub.norub = 101:
            delete ttRub.
        end.
        /* Recherche si la rubrique 101 existe */
        find first ttRub 
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt
              and ttRub.norub = piNumeroRubrique
              and ttRub.nolib = piNumeroLibelle no-error.  /* Ajout SY le 03/12/2007 - Conflit multi-libellé et calendrier */
        pcLbDivCal = pcLbDivCal + substitute('&1@&2@&3#',
                                      string(ttQtt.msqtt, "999999"),
                                      string((if available ttRub then ttRub.vlmtq else 0) * 100, "999999999999"),
                                      string(vdMontantRubrique * 100, "999999999999")).
        if available ttRub then do:
            /* La rubrique 101 existe et le montant calcule est nul --> suppression de la rubrique 101 */
            if vdMontantRubrique = 0
            then do:
                ttQtt.nbrub = ttQtt.nbrub - 1.
                delete ttRub.
            end.
            /* La rubrique 101 existe et le montant calcule est non nul Modification de la rubrique 101 */
            else do:
                assign
                    vdMontantTotalLoyer = vdMontantRubrique
                    vdMontantQttLoyer   = vdMontantRubrique
                .
                if ttRub.vlnum <> ttRub.vlden
                then assign
                    ttRub.cdpro       = 1
                    vdMontantQttLoyer = (vdMontantQttLoyer * ttRub.vlnum ) / ttRub.vlden
                    vdMontantQttLoyer = round(vdMontantQttLoyer, 2)
                .
                assign
                    ttRub.nolib = piNumeroLibelle
                    ttRub.dtdap = ttQtt.dtdpr
                    ttRub.dtfap = ttQtt.dtfpr
                    ttRub.vlmtq = vdMontantQttLoyer
                    ttRub.mttot = vdMontantTotalLoyer
                .
            end.
        end.
        else do:
            /* La rubrique 101 n'existe pas et le montant calcule est non nul --> creation de la rubrique 101 en 1ere position */
            if vdMontantRubrique <> 0 then do:
                create ttRub.
                assign
                    ttRub.noloc = ttQtt.noloc
                    ttRub.noqtt = ttQtt.noqtt
                    ttRub.cdfam = if available rubqt then rubqt.cdfam else 0
                    ttRub.cdsfa = if available rubqt then rubqt.cdsfa else 0
                    ttRub.norub = piNumeroRubrique
                    ttRub.nolib = piNumeroLibelle
                    ttRub.cdgen = if available rubqt then rubqt.cdgen else ""
                    ttRub.cdsig = if available rubqt then rubqt.cdsig else ""
                    ttRub.cddet = "0"
                    ttRub.vlqte = 0
                    ttRub.vlpun = 0
                    ttRub.mttot = vdMontantRubrique
                    ttRub.cdpro = ttQtt.cdquo
                    ttRub.vlnum = ttQtt.nbnum
                    ttRub.vlden = ttQtt.nbden
                    ttRub.vlmtq = round(((vdMontantRubrique * ttQtt.nbnum) / ttQtt.nbden),2)
                    ttRub.dtdap = ttQtt.dtdpr
                    ttRub.dtfap = ttQtt.dtfpr
                    ttRub.chfil = ""
                    ttQtt.nbrub = ttQtt.nbrub + 1
                .
            end.
        end.
        /* Mise a jour du montant de la quittance */
        vdMontantQuittance = 0.
        for each ttRub
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt:
            vdMontantQuittance = vdMontantQuittance + ttRub.vlmtq.
        end.
        assign
            ttQtt.mtqtt = vdMontantQuittance
            ttQtt.cdmaj = 1
        .
    end.
end procedure.

procedure majRubEcart private:
    /* -------------------------------------------------------------------------
     Purpose: Génération de la rubrique de changement de palier dans le terme
     Notes:
    ----------------------------------------------------------------------- */
    define input parameter piNumeroLocataire as integer no-undo.
    define input parameter piNumeroQuittance as integer no-undo.

    define variable vdMontantEcart             as decimal   no-undo.
    define variable vcTypeTraitement           as character no-undo.
    define variable viNombreMois               as integer   no-undo.
    define variable viNombreJourPeriode        as integer   no-undo.
    define variable vdMontantPalier            as decimal   no-undo.
    define variable viNumeroLibelleRappelAvoir as integer   no-undo.
    define variable vdMontantLoyerPrecedent    as decimal   no-undo.
    define variable vdNouveauMontant           as decimal   no-undo.
    define variable vdaCalendrierPrecedent     as date      no-undo.
    define variable vdeAvoirRevision           as decimal   no-undo.
    define variable vdeRappelRevision          as decimal   no-undo.    /* Ajout SY le 11/03/201 : taux revision négatif */
    define variable viNumeroLibelle            as integer   no-undo.

    define buffer rubqt for rubqt.
    define buffer vbCalendrierEvolutionLoyer for ttCalendrierEvolutionLoyer.

    for each ttQtt
        where ttQtt.noloc = piNumeroLocataire
          and ttQtt.noqtt >= (if vcTypeTraitement = "CHGQTT-SIM" then piNumeroQuittance else ttQtt.noqtt):
        assign
            viNombreJourPeriode     = ttQtt.dtfpr - ttQtt.dtdpr + 1
            vdMontantLoyerPrecedent = 0
            vdMontantPalier         = 0
            vdMontantEcart          = 0
        .
        /* Recherche du palier contenant le dernier jour du terme */
boucle101:
        for each ttCalendrierEvolutionLoyer:
            /* recherche palier Rub loyer 101 */
            if ttQtt.dtfpr >= ttCalendrierEvolutionLoyer.dtdeb 
            and (ttCalendrierEvolutionLoyer.dtfin = ? or ttQtt.dtfpr <= ttCalendrierEvolutionLoyer.dtfin)
            then do:
                vdNouveauMontant = (ttCalendrierEvolutionLoyer.mtper * viNombreMois) / 12.

                if glDebug then put stream StFicSor unformatted skip(1)
                    "MajRubEcart - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                    " Palier utilisé = " string(ttCalendrierEvolutionLoyer.noper)
                    " du " string(ttCalendrierEvolutionLoyer.dtdeb) " au " (if ttCalendrierEvolutionLoyer.dtfin <> ? then string(ttCalendrierEvolutionLoyer.dtfin) else fill(" " , 10))
                    " " string(ttCalendrierEvolutionLoyer.mtper) " Nouveau montant = " string( vdNouveauMontant) skip
                .
                /* il faut boucler sur les paliers < celui utilisé et qui sont utilisés dans le terme */
                vdaCalendrierPrecedent = ttQtt.dtdpr.
                for each vbCalendrierEvolutionLoyer
                    where vbCalendrierEvolutionLoyer.noper <= ttCalendrierEvolutionLoyer.noper:

                    if glDebug then put stream StFicSor unformatted
                        "MajRubEcart - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")               
                        " Boucle palier précédents : " vbCalendrierEvolutionLoyer.noper
                        " du " vbCalendrierEvolutionLoyer.dtdeb " au " (if vbCalendrierEvolutionLoyer.dtfin <> ? then string(vbCalendrierEvolutionLoyer.dtfin) else fill(" " , 10))
                        " " vbCalendrierEvolutionLoyer.mtper " montant rub 101 = " + string( (vbCalendrierEvolutionLoyer.mtper * viNombreMois) / 12 ) skip
                    .
                    /* Recherche si le palier commence dans le terme */ 
                    if vbCalendrierEvolutionLoyer.dtdeb > ttQtt.dtdpr and vbCalendrierEvolutionLoyer.dtdeb < ttQtt.dtfpr 
                    and vdMontantLoyerPrecedent <> 0 then do:  /* Calcul rappel/avoir changement de palier */
                        assign
                             vdMontantEcart  = (vdNouveauMontant - vdMontantLoyerPrecedent)
                                             * (vbCalendrierEvolutionLoyer.dtdeb - vdaCalendrierPrecedent) / viNombreJourPeriode
                             vdMontantEcart  = round(vdMontantEcart, 2)
                             vdMontantPalier = vdMontantPalier + vdMontantEcart
                        .
                        if glDebug then put stream StFicSor unformatted 
                            "MajRubEcart - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                            " rappel/avoir calculé = " vdMontantEcart skip
                            fill(" ",14) "Detail : montant préc. rub 101 = " vdMontantLoyerPrecedent
                            " nb jours = " (vbCalendrierEvolutionLoyer.dtdeb - vdaCalendrierPrecedent) 
                            " du " vdaCalendrierPrecedent " au " (vbCalendrierEvolutionLoyer.dtdeb - 1) skip
                        .
                    end.
                    /* loyer palier précédent */
                    assign
                        vdMontantLoyerPrecedent = (vbCalendrierEvolutionLoyer.mtper * viNombreMois) / 12
                        vdaCalendrierPrecedent  = maximum(vbCalendrierEvolutionLoyer.dtdeb, ttQtt.dtdpr)
                    .
                end.
                leave boucle101.
            end.
        end. 
        /* Si révision dans le terme: Soustraire le montant avoir révision */
        assign 
            vdeAvoirRevision = 0
            vdeRappelRevision = 0
        .
        for each ttRub
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt
              and ttRub.norub = 105
              and ttRub.nolib = 50 + viNumeroLibelle:
            vdeAvoirRevision = vdeAvoirRevision + absolute(ttRub.vlmtq).
        end.
        for each ttRub
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt
              and ttRub.norub = 105
              and ttRub.nolib = viNumeroLibelle:
            vdeRappelRevision = vdeRappelRevision + absolute(ttRub.vlmtq).
        end.
        /* Ajuster le changement de palier uniquement s'il y en a un */
        if vdMontantPalier <> 0 then do:
            if vdeAvoirRevision <> ? and vdeAvoirRevision <> 0 then do:
                if glDebug then put stream StFicSor unformatted
                    "MajRubEcart - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                    fill(" ", 14) " Avoir révision loyer = " vdeAvoirRevision
                    " => montant changement palier = " vdMontantPalier " - " vdeAvoirRevision skip
                .
                vdMontantPalier = vdMontantPalier - vdeAvoirRevision.
            end.    
            /* Ajout Sy le 11/03/2010 - Taux révision négatif */
            if vdeRappelRevision <> ? and vdeRappelRevision <> 0 then do:
                if glDebug then put stream StFicSor unformatted
                    "MajRubEcart - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                    fill(" ", 14) " Rappel révision loyer = " vdeRappelRevision
                    " => montant changement palier = " vdMontantPalier " + " vdeRappelRevision skip
                .
                vdMontantPalier = vdMontantPalier + vdeRappelRevision.
            end.
        end.
        /* Génération rub 103.xx */
        for each ttRub
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt
              and ttRub.norub = 103
              and (ttRub.nolib = viNumeroLibelle or ttRub.nolib = 50 + viNumeroLibelle):
            delete ttRub.
            ttQtt.nbrub = ttQtt.nbrub - 1.
        end.
        if vdMontantPalier <> 0 then do:
            assign
                vdMontantPalier            = - vdMontantPalier
                viNumeroLibelleRappelAvoir = if vdMontantPalier > 0 then viNumeroLibelle else (50 + viNumeroLibelle)   /* Rappel loyer ou Avoir loyer */
            .
            find first rubqt no-lock
                where rubqt.cdrub = 103
                  and rubqt.cdlib = viNumeroLibelleRappelAvoir no-error.

            if glDebug then put stream StFicSor unformatted
                "MajRubEcart - Quit concerne = " string(ttQtt.dtdpr, "99/99/9999") "-" string(ttQtt.dtfpr, "99/99/9999")
                " create/maj  rub 103." viNumeroLibelleRappelAvoir " montant = " vdMontantPalier skip(1)
            .
            find first ttRub
                where ttRub.noloc = ttQtt.noloc
                  and ttRub.noqtt = ttQtt.noqtt
                  and ttRub.norub = 103
                  and ttRub.nolib = viNumeroLibelleRappelAvoir no-error.
            if not available ttRub 
            then do:
                create ttRub.
                assign
                    ttRub.noloc = ttQtt.noloc
                    ttRub.noqtt = ttQtt.noqtt
                    ttRub.cdfam = if available rubqt then rubqt.cdfam else 0
                    ttRub.cdsfa = if available rubqt then rubqt.cdsfa else 0
                    ttRub.norub = 103
                    ttRub.nolib = viNumeroLibelleRappelAvoir
                    ttRub.cdgen = if available rubqt then rubqt.cdgen else ""
                    ttRub.cdsig = if available rubqt then rubqt.cdsig else ""
                    ttRub.cddet = "0"
                    ttRub.vlqte = 0
                    ttRub.vlpun = 0
                    ttRub.cdpro = 0
                    ttRub.vlnum = ttQtt.nbnum
                    ttRub.vlden = ttQtt.nbden
                    ttRub.dtdap = ttQtt.dtdpr
                    ttRub.dtfap = ttQtt.dtfpr
                    ttRub.chfil = ""
                    ttQtt.nbrub = ttQtt.nbrub + 1
                .
            end.
            assign
                ttRub.mttot = vdMontantPalier
                ttRub.vlmtq = vdMontantPalier
            .
        end.
    end.
end procedure.
