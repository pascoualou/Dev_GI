/*-----------------------------------------------------------------------------
File        : majLoyQt.p
Purpose     : 
Author(s)   : KANTENA - 2017/11/27
Notes       : reprise de majLoyQt_ext.p
              par rapport au programme de l'appli les parametres TxIndLoy, DtDebQtt, DtFinQtt ne sont pas repris (pas utilise)
derniere revue: 2018/08/14 - phm: 
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/codeTaciteReconduction.i}

using parametre.pclie.parametrageCalendrierLoyer.
using parametre.pclie.parametrageProlongationExpiration.
using parametre.pclie.parametrageRubriqueLibelleMultiple.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{tache/include/tache.i}

define variable glDebug                 as logical   no-undo initial yes.
define variable gcTypeTraitement        as character no-undo.
define variable gcTypeContrat           as character no-undo.
define variable giNumeroLocataire       as int64     no-undo.
define variable giNumeroQuittance       as integer   no-undo.
define variable giNombreMois            as integer   no-undo.
define variable gdaDateEntree           as date      no-undo.
define variable gdaDateSortie           as date      no-undo.
define variable giNumeroLibelle         as integer   no-undo.
define variable giNumeroRubrique        as integer   no-undo.
define variable gdaIndexation           as date      no-undo.
define variable glCalendrierEvolution   as logical   no-undo.
define variable glQuittancementProlonge as logical   no-undo.
define variable glLibelleMultiple       as logical   no-undo.

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

procedure lancementMajloyqt:
    /*--------------------------------------------------------------------------- 
    Purpose :
    Notes   : service externe
    ---------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    define variable voProlongationExpiration  as class parametrageProlongationExpiration no-undo.
    define variable voRubriqueLibelleMultiple as class parametrageRubriqueLibelleMultiple no-undo.
    
    assign
        voProlongationExpiration  = new parametrageProlongationExpiration()
        glQuittancementProlonge   = voProlongationExpiration:isQuittancementProlonge()
        voRubriqueLibelleMultiple = new parametrageRubriqueLibelleMultiple()
        glLibelleMultiple         = voRubriqueLibelleMultiple:isLibelleMultiple()
    .
    delete object voProlongationExpiration no-error.
    delete object voRubriqueLibelleMultiple no-error.    
    if glDebug then output stream StFicSor to value(substitute("&1majloyqt-&2.txt", session:temp-directory, mtoken:cRefGerance)) unbuffered append.
    run majloyqt(poCollectionContrat, poCollectionQuittance).
    if glDebug then output stream StFicSor close.

end procedure.

procedure majloyqt private:
    /*--------------------------------------------------------------------------- 
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.

    define variable viNumeroCalendrier          as integer   no-undo.
    define variable vdaDebutCalendrier          as date      no-undo.
    define variable vdaFinCalendrier            as date      no-undo.
    define variable vdaDebutPeriode             as date      no-undo.
    define variable vdaFinPeriode               as date      no-undo.
    define variable vdaFinBail                  as date      no-undo.
    define variable vdaResiliationBail          as date      no-undo.
    define variable vdaSortieLocataire          as date      no-undo.
    define variable viNumeroPeriode             as integer   no-undo.
    define variable vdMontantHistorique         as decimal   no-undo.
    define variable vdMontantReg                as decimal   no-undo.
    define variable viCpt                       as integer   no-undo.
    define variable vdeMontantQuittance         as decimal   no-undo.
    define variable vdMontantRubrique           as decimal   no-undo.
    define variable vlTaciteReconduit           as logical   no-undo.
    define variable vcLbdivcal                  as character no-undo.
    define variable viCalendrierPrecedent       as integer   no-undo.
    define variable vdMontantLoyerContractuel   as decimal   no-undo.
    define variable vdMontantQuittance          as decimal   no-undo.
    define variable vcLibelleHistoriqueQtt      as character no-undo.
    define variable viNumeroCalendrierPrecedent as integer   no-undo.
    define variable vlModificationMontant       as logical   no-undo.
    define variable viNumeroLibelleRappelAvoir  as integer   no-undo.    /* no libellé rappel/Avoir rub 103 */
    define variable voCalendrierLoyer           as class     parametrageCalendrierLoyer no-undo.
    define variable vhProcTache                 as handle    no-undo.

    define buffer rubqt for rubqt.
    define buffer tache for tache.
    define buffer ctrat for ctrat.
    define buffer calev for calev.
    define buffer aquit for aquit.

    /* Recuperation des parametres */
    assign
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroLocataire     = poCollectionContrat:getInt64("iNumeroContrat")
        vlModificationMontant = poCollectionQuittance:getLogical("lRegularisation")
        viNumeroPeriode       = poCollectionQuittance:getInteger("iNumeroPeriode")
        gcTypeTraitement      = poCollectionQuittance:getCharacter("cTypeTraitement")
        voCalendrierLoyer     = new parametrageCalendrierLoyer()
        glCalendrierEvolution = voCalendrierLoyer:isCalendrierEvolution()
    .
    delete object voCalendrierLoyer.
    if gcTypeTraitement = "CALID" 
    then assign
        gdaIndexation     = poCollectionQuittance:getDate("daRevision")
        giNumeroQuittance = poCollectionQuittance:getInteger("iNumeroQuittance") 
        vdaDebutPeriode   = poCollectionQuittance:getDate("daDebutPeriode")
        vdaFinPeriode     = poCollectionQuittance:getDate("daFinPeriode")
    .
    if gcTypeTraitement = "CHGQTT-SIM" 
    then assign
        giNumeroQuittance = poCollectionQuittance:getInteger("iNumeroQuittance") 
        vdaDebutPeriode   = poCollectionQuittance:getDate("daDebutPeriode")
        vdaFinPeriode     = poCollectionQuittance:getDate("daFinPeriode")
    .

    /* Si aucun calendrier de saisi: aucun calcul a effectuer */
    if not can-find(first calev no-lock
                    where calev.tpcon = gcTypeContrat and calev.nocon = giNumeroLocataire) then return.

    /* Ajout SY le 07/03/2008 : nouveau calcul => si revision pas de déclenchement de la régul */
    if glCalendrierEvolution and gcTypeTraitement = "CALID" then vlModificationMontant = no.
    /* Recherche si mode de calcul calendrier d'evolution des loyers */
    find last tache no-lock
        where tache.tptac = {&TYPETACHE-revision}
          and tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroLocataire no-error.
    /* Pas de calcul "calendrier d'evolution des loyers ====> pas de tache calendrier */
    if not available tache or tache.cdhon <> "00001" then return.

    /* Recherche si calendrier utilise pour le calcul */
    find first tache no-lock
        where tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}
          and tache.notac = 0
          and tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroLocataire no-error.
    if not available tache or tache.tphon = "no" then return.

    assign
        giNumeroRubrique = integer(tache.ntges)
        giNumeroLibelle  = integer(tache.tpges)
    .
    /* Recherche des dates d'entree et de sortie du locataire */
    find first tache no-lock 
        where tache.tptac = {&TYPETACHE-quittancement}
          and tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroLocataire no-error.
    if available tache 
    then assign
        gdaDateEntree      = tache.dtdeb
        vdaSortieLocataire = tache.dtfin
        giNombreMois       = integer(substring(tache.pdges, 1, 3, "character"))
    .
    /* Recherche du loyer contractuel */
    find first tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroLocataire
          and tache.tptac = {&TYPETACHE-loyerContractuel} no-error.
    vdMontantLoyerContractuel = if available tache then tache.mtreg else 0.
    for first ctrat no-lock
        where ctrat.tpcon = gcTypeContrat
          and ctrat.noCon = giNumeroLocataire:
        assign 
            vdaFinBail         = ctrat.dtfin
            vdaResiliationBail = ctrat.dtree
            vlTaciteReconduit  = (ctrat.tpren = {&TACITERECONDUCTION-YES})    /* Info "Tacite Reconduction ? */
        .
    end.
    if vdaSortieLocataire <> ? and vdaResiliationBail <> ?
    then gdaDateSortie = minimum(vdaSortieLocataire, vdaResiliationBail).
    else do:
       if vdaResiliationBail <> ? then gdaDateSortie = vdaResiliationBail.
       if vdaSortieLocataire <> ? then gdaDateSortie = vdaSortieLocataire.
    end.
    /* Uniquement si module prolongation apres expiration non ouvert */
    if not glQuittancementProlonge
    then if not vlTaciteReconduit and gdaDateSortie = ? then gdaDateSortie = vdaFinBail.

    if gcTypeContrat = {&TYPECONTRAT-preBail} or gcTypeTraitement <> "CHGQTT-SIM"
    then for last calev no-lock    /* Recherche du dernier calendrier saisi: calendrier utilise  pour le calcul */
        where calev.tpcon = gcTypeContrat
          and calev.nocon = giNumeroLocataire:
        assign
            viNumeroCalendrier = calev.nocal
            vdaFinCalendrier   = calev.dtfin
        .
    end.
    else do:
        /* Recherche du calendrier à utiliser pour la quittance en cours */
blocCalev:
        for each calev no-lock
            where calev.tpcon = gcTypeContrat
              and calev.nocon = giNumeroLocataire:
            if calev.dtcal > vdaFinPeriode then leave blocCalev.

            viNumeroCalendrier = calev.nocal.
        end.
        /* Recherche du calendrier utilisé pour la quittance précédente */
        {&_proparse_ prolint-nowarn(use-index)}
blocQuittPrec:
        for last aquit no-lock
            where aquit.noloc = giNumeroLocataire 
              and aquit.noqtt > 0 
              and aquit.noqtt < giNumeroQuittance 
              and aquit.fgfac = no            /* ajout SY le 03/03/2008 */
            use-index ix_aquit03              // noloc, msqtt
          , each calev no-lock
            where calev.tpcon = gcTypeContrat
              and calev.nocon = giNumeroLocataire:
            if calev.dtcal > aquit.dtfpr then leave blocQuittPrec.

            viCalendrierPrecedent = calev.nocal.
        end.
    end.

    /* calendrier précédent pour calcul rub 105 */
    find last calev no-lock
        where calev.tpcon = gcTypeContrat
          and calev.nocon = giNumeroLocataire
          and calev.nocal < viNumeroCalendrier no-error.
    if available calev then viNumeroCalendrierPrecedent = calev.nocal.
    if glDebug then do:
        put stream StFicSor unformatted skip(1)
            ">>> " string(today, "99/99/9999") " " string(time, "HH:MM:SS") skip
            "Locataire  " giNumeroLocataire "  Calendrier no: " viNumeroCalendrier skip
            "Traitement = " gcTypeTraitement " vlModificationMontant = " vlModificationMontant 
            " viNumeroPeriode = " viNumeroPeriode "  Nouveau calcul : " string(glCalendrierEvolution) skip.
        if gcTypeTraitement  = "CALID"
        then put stream StFicSor unformatted "Date rev = " string(gdaIndexation, "99/99/9999").
        if gcTypeTraitement  = "CHGQTT-SIM"
        then put stream StFicSor unformatted " Quitt " giNumeroQuittance " du " string(vdaDebutPeriode,"99/99/9999") "-" string(vdaFinPeriode, "99/99/9999") skip.
    end.

    {&_proparse_ prolint-nowarn(sortaccess)}
    for each calev no-lock
        where calev.tpcon = gcTypeContrat
          and calev.nocon = giNumeroLocataire
          and calev.nocal = viNumeroCalendrier
        break by calev.tpcon by calev.nocon by calev.nocal:
        create ttCalendrierEvolutionLoyer.
        assign
            ttCalendrierEvolutionLoyer.noper = calev.noper
            ttCalendrierEvolutionLoyer.dtdeb = calev.dtdeb
            ttCalendrierEvolutionLoyer.dtfin = calev.dtfin
            ttCalendrierEvolutionLoyer.mtper = calev.mtper
        .
        if last-of(calev.nocal) and calev.dtfin <> ? then do:
            create ttCalendrierEvolutionLoyer.
            assign
                ttCalendrierEvolutionLoyer.noper = calev.noper + 1
                ttCalendrierEvolutionLoyer.dtdeb = calev.dtfin + 1
                ttCalendrierEvolutionLoyer.dtfin = ?
                ttCalendrierEvolutionLoyer.mtper = vdMontantLoyerContractuel
            .
        end.
    end.

    /* Ajout SY le 30/04/2008 : forçage calculs rappel/avoir changement valeur calendrier */
    if gcTypeTraitement = "CHGQTT-SIM" 
    and viCalendrierPrecedent <> 0 and viNumeroCalendrier <> viCalendrierPrecedent   /* si changement de calendrier par rapport à la quittance précédente */
    then do:
        /* Recherche du palier contenant le dernier jour du terme */
        viNumeroPeriode = 0.
        for each ttCalendrierEvolutionLoyer:
            if vdaDebutPeriode >= ttCalendrierEvolutionLoyer.dtdeb 
            and (ttCalendrierEvolutionLoyer.dtfin = ? or vdaFinPeriode <= ttCalendrierEvolutionLoyer.dtfin)
            then viNumeroPeriode = ttCalendrierEvolutionLoyer.noper.
        end.
        if viNumeroPeriode > 0 then vlModificationMontant = yes.
    end.

    if glCalendrierEvolution and viNumeroCalendrierPrecedent > 0 then do:
        {&_proparse_ prolint-nowarn(release)}
        release calev no-error.
        {&_proparse_ prolint-nowarn(sortaccess)}
        for each calev no-lock
            where calev.tpcon = gcTypeContrat
              and calev.nocon = giNumeroLocataire
              and calev.nocal = viNumeroCalendrierPrecedent
            break by calev.tpcon by calev.nocon by calev.nocal:
            create ttCalendrierEvolutionLoyer-prc.
            assign
                ttCalendrierEvolutionLoyer-prc.noper = calev.noper 
                ttCalendrierEvolutionLoyer-prc.dtdeb = calev.dtdeb
                ttCalendrierEvolutionLoyer-prc.dtfin = calev.dtfin
                ttCalendrierEvolutionLoyer-prc.mtper = calev.mtper
            .
            if last-of(calev.nocal) and calev.dtfin <> ? then do:
                create ttCalendrierEvolutionLoyer-prc.
                assign
                    ttCalendrierEvolutionLoyer-prc.noper = calev.noper + 1
                    ttCalendrierEvolutionLoyer-prc.dtdeb = calev.dtfin + 1
                    ttCalendrierEvolutionLoyer-prc.dtfin = ?
                    ttCalendrierEvolutionLoyer-prc.mtper = vdMontantLoyerContractuel
                .
            end.
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

    if glCalendrierEvolution
    then run calculCalno2(output vcLbdivcal).
    else run calculCalno1(output vcLbdivcal).

    /* Calcul du montant de regularisation dans le cas ou on modifie le montant d'une periode
       qui a deja ete utilise pour calculer un loyer deja quittance */
    if vlModificationMontant
    then for first ttQtt 
        where ttQtt.iNumeroLocataire = giNumeroLocataire
          and ttQtt.iNoQuittance = (if gcTypeTraitement = "CHGQTT-SIM" then giNumeroQuittance else ttQtt.iNoQuittance):

        if glDebug then put stream StFicSor unformatted skip(1)
            "Calcul Regul " gcTypeTraitement " - Quittancement de " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999") " viNumeroPeriode = " viNumeroPeriode skip
        .
        {&_proparse_ prolint-nowarn(sortaccess)}
boucleAquit:
        for each aquit no-lock
            where aquit.noloc = giNumeroLocataire 
              and aquit.fgfac = no            /* Ajout SY le 28/01/2008 */
            by aquit.msqtt:
            if gcTypeTraitement = "CHGQTT-SIM" and aquit.noqtt >= giNumeroQuittance then leave boucleAquit.   /* Modif SY le 30/04/2008 pour CHGQTT-SIM */

            vdMontantRubrique = 0.
            /* filtre sur la période modifiée si existe sinon calcul Régul sur TOUT le quittancement */
            find first ttCalendrierEvolutionLoyer where ttCalendrierEvolutionLoyer.noper = viNumeroPeriode no-error.
            if available ttCalendrierEvolutionLoyer then do:
                assign
                    vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer.dtdeb,gdaDateEntree)
                    vdaFinCalendrier   = if gdaDateSortie = ? 
                                         then if ttCalendrierEvolutionLoyer.dtfin <> ? then ttCalendrierEvolutionLoyer.dtfin else 12/31/9999
                                         else if ttCalendrierEvolutionLoyer.dtfin <> ? then minimum(ttCalendrierEvolutionLoyer.dtfin,gdaDateSortie) else gdaDateSortie
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
                if gcTypeTraitement <> "CHGQTT-SIM"
                then for last tache no-lock    /* La nouvelle 04130 n'est pas encore créée, donc on récupère le dernière indexation du calendrier */
                    where tache.tpcon = gcTypeContrat
                      and tache.nocon = giNumeroLocataire
                      and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}:
                    do viCpt = 1 to num-entries(tache.lbdiv, "#"):
                        if integer(entry(1, entry(viCpt, tache.lbdiv, "#"), "@")) = aquit.msqtt 
                        then vdMontantHistorique = decimal(entry(3, entry(viCpt, tache.lbdiv, "#"), "@")) / 100.
                    end.
                end.
                if vdMontantHistorique = 0 
                then vdMontantHistorique = (if integer(entry(1, aquit.tbrub[1], "|")) = giNumeroRubrique
                                           and integer(entry(2, aquit.tbrub[1], "|")) = giNumeroLibelle
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
                "Quitt " ttQtt.iMoisTraitementQuitt " create/maj  rub 103." viNumeroLibelleRappelAvoir " " vdMontantReg skip.
            find first rubqt no-lock
                where rubqt.cdrub = 103
                  and rubqt.cdlib = viNumeroLibelleRappelAvoir no-error.
            find first ttRub 
                where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                  and ttRub.iNoQuittance = ttQtt.iNoQuittance
                  and ttRub.iNorubrique = 103
                  and (ttRub.iNoLibelleRubrique = 48 or ttRub.iNoLibelleRubrique = 98) no-error.
            if not available ttRub
            then do:
                create ttRub.
                assign
                    ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                    ttRub.iNoQuittance = ttQtt.iNoQuittance
                    ttRub.iFamille = if available rubqt then rubqt.cdfam else 0
                    ttRub.iSousFamille = if available rubqt then rubqt.cdsfa else 0
                    ttRub.iNorubrique = 103
                    ttRub.iNoLibelleRubrique = viNumeroLibelleRappelAvoir
                    ttRub.cCodeGenre = if available rubqt then rubqt.cdgen else ""
                    ttRub.cCodeSigne = if available rubqt then rubqt.cdsig else ""
                    ttRub.cddet = "0"
                    ttRub.dQuantite = 0
                    ttRub.dPrixunitaire = 0
                    ttRub.dMontantTotal = vdMontantReg
                    ttRub.iProrata = 0
                    ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata
                    ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata
                    ttRub.dMontantQuittance = vdMontantReg
                    ttRub.daDebutApplication = ttQtt.daDebutPeriode
                    ttRub.daFinApplication = ttQtt.daFinPeriode
                    ttRub.daDebutApplicationPrecedente = ""
                    ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1.
            end.
            else do:
                if vdMontantReg + ttRub.dMontantTotal = 0
                then do:
                   ttQtt.iNombreRubrique = ttQtt.iNombreRubrique - 1.
                   delete ttRub.
                end.
                else do:
                    viNumeroLibelleRappelAvoir = if vdMontantReg + ttRub.dMontantTotal > 0 then 48 else 98. /* Rappel / Avoir loyer */
                    find first rubqt no-lock
                        where rubqt.cdrub = 103
                          and rubqt.cdlib = viNumeroLibelleRappelAvoir no-error.
                    if (ttRub.iNoLibelleRubrique  < 51 and vdMontantReg + ttRub.dMontantTotal >= 0) 
                    or (ttRub.iNoLibelleRubrique >= 51 and vdMontantReg + ttRub.dMontantTotal  < 0)
                    then assign 
                        ttRub.dMontantTotal = ttRub.dMontantTotal + vdMontantReg
                        ttRub.dMontantQuittance = ttRub.dMontantQuittance + vdMontantReg
                    .
                    else assign
                        ttRub.iFamille = if available rubqt then rubqt.cdfam else 0
                        ttRub.iSousFamille = if available rubqt then rubqt.cdsfa else 0
                        ttRub.iNoLibelleRubrique = viNumeroLibelleRappelAvoir
                        ttRub.cCodeGenre = if available rubqt then rubqt.cdgen else ""
                        ttRub.cCodeSigne = if available rubqt then rubqt.cdsig else ""
                        ttRub.dMontantTotal = ttRub.dMontantTotal + vdMontantReg
                        ttRub.dMontantQuittance = ttRub.dMontantTotal + vdMontantReg
                    .
                end.
            end.
        end.
    end.

    /* Mise a jour du montant des quittances */
    for each ttQtt
        where ttQtt.iNumeroLocataire = giNumeroLocataire
          and ttQtt.iNoQuittance >= (if gcTypeTraitement = "CHGQTT-SIM" then giNumeroQuittance else ttQtt.iNoQuittance):
        vdMontantQuittance = 0.
        for each ttRub 
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance:
            vdMontantQuittance = vdMontantQuittance + ttRub.dMontantQuittance.
        end.
        assign
            ttQtt.dMontantQuittance = vdMontantQuittance
            ttQtt.cdmaj = 1
        .
    end.
    /* CHGQTT : pas de modification du calendrier, juste maj qtt selon période */ 
    if not gcTypeTraitement begins "CHGQTT" then do:
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.tpcon = gcTypeContrat 
            ttTache.nocon = giNumeroLocataire
            ttTache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}
            ttTache.notac = 0
            ttTache.noita = 0
            ttTache.CRUD  = "C"
            ttTache.dtdeb = ?
            ttTache.dtfin = gdaIndexation
            ttTache.tpfin = ""
            ttTache.duree = viNumeroCalendrier
            ttTache.dtree = vdaFinCalendrier
            ttTache.ntges = ""
            ttTache.tpges = ""
            ttTache.pdges = string(giNumeroQuittance)
            ttTache.cdreg = ""
            ttTache.ntreg = gcTypeTraitement
            ttTache.pdreg = ""
            ttTache.dcreg = ""
            ttTache.dtreg = ?
            ttTache.mtreg = 0
            ttTache.utreg = ""
            ttTache.tphon = ""
            ttTache.cdhon = ""
            ttTache.lbdiv = vcLibelleHistoriqueQtt + trim(vcLbdivcal, "#")
        .
        run crud/tache_CRUD.p persistent set vhProcTache.
        run getTokenInstance in vhProcTache(mToken:JSessionId).
        run setTache in vhProcTache(table ttTache by-reference).
        run destroy in vhProcTache.
    end.

end procedure.

procedure calculCalno1 private:
/* -------------------------------------------------------------------------
   Procedure de calcul des rubriques calendrier version no 1 : 
    - rub 101 proratée
    - pas de rub 105
   ----------------------------------------------------------------------- */
    define output parameter pcLbdivcal as character no-undo.

    /* Génération rub loyer sur toutes les quittances */
    run majRubLoy(output pcLbdivcal).
 
end procedure.

procedure calculCalno2 private:
    /* -------------------------------------------------------------------------
     Purpose : Procedure de calcul des rubriques calendrier version no 2 (AGF) :
     notes   :
         - rub 101 = loyer complet du palier contenant la date de fin de période quitt
         - rub ??? = rappel/avoir changement de palier
         - rub 105 = rappel/avoir révision
   ----------------------------------------------------------------------- */
    define output parameter pcLbdivcal as character no-undo.

    define variable viNombreJourPeriode        as integer   no-undo.
    define variable vdaDebutCalendrier         as date      no-undo.
    define variable vdaFinCalendrier           as date      no-undo.
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
    run majRubLoy(output pcLbdivcal).
    if gcTypeTraitement = "CALID"
    then do:
        /* Calcul rub 105 rappel/avoir loyer révisé sur quittance révisée */
        find first ttqtt
             where ttQtt.iNumeroLocataire = giNumeroLocataire
               and ttQtt.iNoQuittance = giNumeroQuittance no-error.
        /* Suppression de tous les enreg concernant la quittance dans ttRub pour
           la rubrique 105 Rappel ou avoir révision loyer */
        for each ttRub
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = 105
              and (ttRub.iNoLibelleRubrique = giNumeroLibelle or  ttRub.iNoLibelleRubrique = 50 + giNumeroLibelle):
            delete ttRub.
            ttQtt.iNombreRubrique = ttQtt.iNombreRubrique - 1.
        end.
        /* Loyer BRUT APRES révision (= palier complet) */
        find first ttRub
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = giNumeroRubrique
              and ttRub.iNoLibelleRubrique = giNumeroLibelle no-error. 
        if available ttRub then vdNouveauMontant = ttRub.dMontantTotal.
        /* Si date de révision < date de début quittance Rappel pour la ou les qtts précédentes */
        if gdaIndexation < vdaDebutPeriode then do: 
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
                if gdaIndexation >= vdaDebutTmp and gdaIndexation <= vdaFinTmp
                then vlFuret = false.
            end.
            /* Calcul Rappel loyer terme par terme Pour chaque palier du terme sauf le dernier */
            do while vdaDebutTmp < vdaDebutPeriode:
                viNombreJourPeriode = vdaFinTmp - vdaDebutTmp + 1.

                if glDebug then put stream StFicSor unformatted 
                    "CALID - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                    " Révision au " string(gdaIndexation, "99/99/9999")
                    " Boucle Termes précédents : " string(vdaDebutTmp, "99/99/9999") "-" string(vdaFinTmp, "99/99/9999") skip
                .
                /* si la révision n'est pas dans ce terme : rappel sur terme complet */
                if gdaIndexation < vdaDebutTmp
                then do:
                    if glDebug then put stream StFicSor unformatted
                        fill(" " , 8) "Rappel Terme Complet   Montant periode  = " vdMontantPeriode "  Cumul rappel = " vdeMontantNrv skip
                    .
boucleEvo:
                    for each ttCalendrierEvolutionLoyer-prc
                        where ttCalendrierEvolutionLoyer-prc.dtdeb < vdaFinTmp:
                        vdMontantPeriode = (ttCalendrierEvolutionLoyer-prc.mtper * giNombreMois) / 12.

                        if glDebug then put stream StFicSor unformatted 
                            "CALID - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                            " Boucle palier no " ttCalendrierEvolutionLoyer-prc.noper
                            " du " ttCalendrierEvolutionLoyer-prc.dtdeb " au " (if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then string(ttCalendrierEvolutionLoyer-prc.dtfin) else fill(" " , 10))
                            " montant rub 101 = " vdMontantPeriode skip
                        .
                        /* Recherche si le palier concerne le terme */
                        if ttCalendrierEvolutionLoyer-prc.dtfin <> ?
                        and ttCalendrierEvolutionLoyer-prc.dtfin < vdaDebutTmp then next boucleEvo.

                        if ttCalendrierEvolutionLoyer-prc.dtdeb > vdaFinTmp then leave boucleEvo.

                        assign
                            vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer-prc.dtdeb, gdaDateEntree, vdaDebutTmp)
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
                            "CALID - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                            " rappel/avoir calculé = " vdMontantTmp 
                            "     Détail : nb jours = " (vdaFinCalendrier - vdaDebutCalendrier + 1) 
                            " du " vdaDebutCalendrier " au " vdaFinCalendrier skip
                        .
                    end.
                end.
                else
boucleEvo-prc:
                for each ttCalendrierEvolutionLoyer-prc:    /* rappel à partir de la date de révision */
                    if (ttCalendrierEvolutionLoyer-prc.dtfin <> ? and ttCalendrierEvolutionLoyer-prc.dtfin < vdaDebutTmp)
                    or (ttCalendrierEvolutionLoyer-prc.dtfin <> ? and ttCalendrierEvolutionLoyer-prc.dtfin < gdaIndexation) then next boucleEvo-prc.

                    if ttCalendrierEvolutionLoyer-prc.dtdeb > vdaFinTmp then leave boucleEvo-prc. 

                    vdMontantPeriode = (ttCalendrierEvolutionLoyer-prc.mtper * giNombreMois) / 12.

                    if glDebug then put stream StFicSor unformatted
                        "CALID - Terme concerne = " string(vdaDebutTmp, "99/99/9999") "-" string(vdaFinTmp, "99/99/9999")              
                        " Boucle palier no " ttCalendrierEvolutionLoyer-prc.noper
                        " du " ttCalendrierEvolutionLoyer-prc.dtdeb " au " (if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then string(ttCalendrierEvolutionLoyer-prc.dtfin) else fill(" " , 10))
                        " montant rub 101 = " vdMontantPeriode skip
                    .
                    assign 
                        vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer-prc.dtdeb, gdaDateEntree, gdaIndexation)
                        vdaFinCalendrier   = if gdaDateSortie = ? 
                                             then if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then ttCalendrierEvolutionLoyer-prc.dtfin else 12/31/9999
                                             else if ttCalendrierEvolutionLoyer-prc.dtfin <> ? then minimum(ttCalendrierEvolutionLoyer-prc.dtfin, gdaDateSortie) else gdaDateSortie
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
                /* Terme suivant */
                run cl2DatFin in vhProcDate(vdaDebutTmp, viNombreMoisPeriode, "00002", output vdaDebutTmp).
                run cl2DatFin in vhProcDate(vdaFinTmp,   viNombreMoisPeriode, "00002", output vdaFinTmp).
            end.
            vdeMontantNrv = round(vdeMontantNrv, 2).
        end.

        /* Si date de révision comprise entre la date de début et date de fin quittance: prorata.
           Création rubrique d'Avoir sur la période comprise entre date de début qtt et date révis */
        if gdaIndexation > vdaDebutPeriode and gdaIndexation <= vdaFinPeriode
        then
recherchePalier:
        for each ttCalendrierEvolutionLoyer:      /* Recherche du palier contenant le dernier jour du terme */
            /* recherche palier Rub loyer 101 */
            if ttQtt.daFinPeriode >= ttCalendrierEvolutionLoyer.dtdeb 
            and (ttCalendrierEvolutionLoyer.dtfin = ? or ttQtt.daFinPeriode <= ttCalendrierEvolutionLoyer.dtfin) then do:
                if glDebug then put stream StFicSor unformatted skip(1)
                    "CALID - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                    " Palier utilisé = " ttCalendrierEvolutionLoyer.noper
                    " du " ttCalendrierEvolutionLoyer.dtdeb " au " (if ttCalendrierEvolutionLoyer.dtfin <> ? then string(ttCalendrierEvolutionLoyer.dtfin) else fill(" " , 10) )
                    " " ttCalendrierEvolutionLoyer.mtper " montant rub 101 = " (ttCalendrierEvolutionLoyer.mtper * giNombreMois) / 12 skip
                .
                /* il faut boucler sur les paliers < date de révision */
boucleEvo:
                for each vbCalendrierEvolutionLoyer
                   where vbCalendrierEvolutionLoyer.noper < ttCalendrierEvolutionLoyer.noper
                     and vbCalendrierEvolutionLoyer.dtdeb < gdaIndexation:
                    vdMontantPeriode = (vbCalendrierEvolutionLoyer.mtper * giNombreMois) / 12.

                    if glDebug then put stream StFicSor unformatted
                        "CALID - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                        " Boucle palier précédents: no " vbCalendrierEvolutionLoyer.noper
                        " du " vbCalendrierEvolutionLoyer.dtdeb " au " (if vbCalendrierEvolutionLoyer.dtfin <> ? then string(vbCalendrierEvolutionLoyer.dtfin) else fill(" " , 10))
                        " montant rub 101 = " vdMontantPeriode skip
                    .
                    /* Recherche si le palier concerne le terme */
                    if vbCalendrierEvolutionLoyer.dtfin <> ? and ttCalendrierEvolutionLoyer.dtfin < vdaDebutPeriode then next boucleEvo.

                    if vbCalendrierEvolutionLoyer.dtdeb > vdaFinPeriode then leave boucleEvo.

                    assign
                        vdaDebutCalendrier = maximum(vbCalendrierEvolutionLoyer.dtdeb,gdaDateEntree, ttQtt.daDebutPeriode)
                        vdaFinCalendrier   = if gdaDateSortie = ?
                                             then if vbCalendrierEvolutionLoyer.dtfin <> ? then vbCalendrierEvolutionLoyer.dtfin else 12/31/9999
                                             else if vbCalendrierEvolutionLoyer.dtfin <> ? then minimum(vbCalendrierEvolutionLoyer.dtfin,gdaDateSortie) else gdaDateSortie
                    .
                    if vdaDebutCalendrier > vdaFinCalendrier
                    or vdaFinCalendrier < vdaDebutPeriode or vdaDebutCalendrier > vdaFinPeriode then next boucleEvo.                         /* Aucun calcul */

                    assign
                        vdMontantTmp = (vdNouveauMontant - vdMontantPeriode) * (vbCalendrierEvolutionLoyer.dtfin - vdaDebutCalendrier + 1) / (vdaFinPeriode - vdaDebutPeriode + 1)
                        vdMontantTmp = round(vdMontantTmp, 2)
                        vdeMontantPro     = vdeMontantPro + vdMontantTmp
                    .
                    if glDebug then put stream StFicSor unformatted
                        "CALID - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                        " rappel/avoir calculé = " vdMontantTmp 
                        "     Détail : nb jours = " (vbCalendrierEvolutionLoyer.dtfin - vdaDebutCalendrier + 1) 
                        " du " vdaDebutCalendrier " au " (if vbCalendrierEvolutionLoyer.dtfin <> ? then string( vbCalendrierEvolutionLoyer.dtfin ) else fill(" " , 10)) skip
                    .
                end.
                leave recherchePalier.
            end. /* palier trouvé */
        end.
        if vdeMontantPro <> 0 then vdMontant105 = - vdeMontantPro.
        if vdeMontantNrv <> 0 then vdMontant105 = vdeMontantNrv.
        if vdMontant105 <> 0
        then for first ttQtt
            where ttQtt.iNumeroLocataire = giNumeroLocataire
              and ttQtt.iNoQuittance = giNumeroQuittance:
            /* Rappel loyer ou avoir loyer */
            viNumeroLibelleRappelAvoir = if vdMontant105 > 0 then giNumeroLibelle else (50 + giNumeroLibelle).
            find first rubqt no-lock
                where rubqt.cdrub = 105
                  and rubqt.cdlib = viNumeroLibelleRappelAvoir no-error.
            find first ttRub
                where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                  and ttRub.iNoQuittance = ttQtt.iNoQuittance
                  and ttRub.iNorubrique = 105
                  and ttRub.iNoLibelleRubrique = viNumeroLibelleRappelAvoir no-error.
            if not available ttRub then do:
                create ttRub.
                assign
                    ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                    ttRub.iNoQuittance = ttQtt.iNoQuittance
                    ttRub.iFamille = if available rubqt then rubqt.cdfam else 0
                    ttRub.iSousFamille = if available rubqt then rubqt.cdsfa else 0
                    ttRub.iNorubrique = 105
                    ttRub.iNoLibelleRubrique = viNumeroLibelleRappelAvoir
                    ttRub.cCodeGenre = if available rubqt then rubqt.cdgen else ""
                    ttRub.cCodeSigne = if available rubqt then rubqt.cdsig else ""
                    ttRub.cddet = "0"
                    ttRub.dQuantite = 0
                    ttRub.dPrixunitaire = 0
                    ttRub.dMontantTotal = vdMontant105
                    ttRub.iProrata = 0
                    ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata
                    ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata
                    ttRub.dMontantQuittance = vdMontant105
                    ttRub.daDebutApplication = ttQtt.daDebutPeriode
                    ttRub.daFinApplication = ttQtt.daFinPeriode
                    ttRub.daDebutApplicationPrecedente = ""
                    ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
               .
            end.
            else do:
                if vdMontant105 + ttRub.dMontantTotal = 0 
                then do:
                   ttQtt.iNombreRubrique = ttQtt.iNombreRubrique - 1.
                   delete ttRub.
                end.
                else do:
                    if vdMontant105 + ttRub.dMontantTotal > 0 
                    then find first rubqt no-lock             /*- Rappel loyer -*/
                        where rubqt.cdrub = 105
                          and rubqt.cdlib = 01 no-error.
                    else find first rubqt no-lock             /*- Avoir loyer -*/
                        where rubqt.cdrub = 105
                          and rubqt.cdlib = 51 no-error.
                    if (ttRub.iNoLibelleRubrique  < 51 and vdMontant105 + ttRub.dMontantTotal >= 0) 
                    or (ttRub.iNoLibelleRubrique >= 51 and vdMontant105 + ttRub.dMontantTotal  < 0)
                    then assign 
                        ttRub.dMontantTotal = ttRub.dMontantTotal + vdMontant105
                        ttRub.dMontantQuittance = ttRub.dMontantQuittance + vdMontant105
                    .
                    else assign
                        ttRub.iFamille = if available rubqt then rubqt.cdfam else 0
                        ttRub.iSousFamille = if available rubqt then rubqt.cdsfa else 0
                        ttRub.iNoLibelleRubrique = ttRub.iNoLibelleRubrique + (50 * (if ttRub.iNoLibelleRubrique < 51 then 1 else -1))
                        ttRub.cCodeGenre = if available rubqt then rubqt.cdgen else ""
                        ttRub.cCodeSigne = if available rubqt then rubqt.cdsig else ""
                        ttRub.dMontantTotal = ttRub.dMontantTotal + vdMontant105
                        ttRub.dMontantQuittance = ttRub.dMontantTotal + vdMontant105
                    .
                end.
            end.
        end.
    end.
    /* Sur toutes les quittances: Calcul Rappel/Avoir changement de palier => Génération rub 103.xx */
    run majRubEcart.
    if valid-handle(vhProcDate) then run destroy in vhProcDate.

end procedure.

procedure calRubLoy private:
    /* ----------------------------------------------------------------------
     Procedure de calcul du montant de la rubrique soumise au calendrier
     pour un mois de quitt                                              
    ----------------------------------------------------------------------- */
    define input  parameter pdaDebutPeriode   as date    no-undo.
    define input  parameter pdaFinPeriode     as date    no-undo.
    define output parameter pdMontantRubrique as decimal no-undo.

    define variable vdaDebutCalendrier  as date     no-undo.
    define variable vdaFinCalendrier    as date     no-undo.
    define variable vdMontantTmp        as decimal  no-undo.
    define variable vdaDateDebut        as date     no-undo.
    define variable vdaDateFin          as date     no-undo.
    define variable viNombreJourPeriode as integer  no-undo.

    viNombreJourPeriode = pdaFinPeriode - pdaDebutPeriode + 1.
boucleEvo:
    for each ttCalendrierEvolutionLoyer:
        /* Ajout SY le 06/05/2008 : Calendrier > quittance traitée */
        if ttCalendrierEvolutionLoyer.dtdeb > pdaFinPeriode then leave boucleEvo.

        if glDebug then put stream StFicSor unformatted
            "boucle ttCalendrierEvolutionLoyer Qtt du " string(pdaDebutPeriode, "99/99/9999") " au " (if pdaFinPeriode <> ? then string(pdaFinPeriode, "99/99/9999") else "")
            " Periode no " ttCalendrierEvolutionLoyer.noper
            " du " string(ttCalendrierEvolutionLoyer.dtdeb, "99/99/9999") " au " (if ttCalendrierEvolutionLoyer.dtfin <> ? then string(ttCalendrierEvolutionLoyer.dtfin, "99/99/9999") else "")
            " montant annuel = " ttCalendrierEvolutionLoyer.mtper
            " montant periode = " (ttCalendrierEvolutionLoyer.mtper * giNombreMois) / 12
            " nb jour periode = " viNombreJourPeriode skip
        .
        assign
            vdaDebutCalendrier = maximum(ttCalendrierEvolutionLoyer.dtdeb, gdaDateEntree)
            vdaFinCalendrier   = if gdaDateSortie = ? 
                                 then if ttCalendrierEvolutionLoyer.dtfin <> ? then ttCalendrierEvolutionLoyer.dtfin else 12/31/9999
                                 else if ttCalendrierEvolutionLoyer.dtfin <> ? then minimum(ttCalendrierEvolutionLoyer.dtfin, gdaDateSortie) else gdaDateSortie
        .
        if vdaDebutCalendrier > vdaFinCalendrier
        or vdaFinCalendrier < pdaDebutPeriode or vdaDebutCalendrier > pdaFinPeriode then next boucleEvo.

        /* Si la periode de quittancement est totalement comprise dans une periode du   */
        /* calendrier, on divise le montant par le nombre de periode(s) de quittancment */
        /* dans une annee                                                               */
        if vdaDebutCalendrier <= pdaDebutPeriode and vdaFinCalendrier >= pdaFinPeriode 
        then assign
            vdMontantTmp      = (ttCalendrierEvolutionLoyer.mtper * giNombreMois) / 12
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
            /* periode concernee : [ttCalendrierEvolutionLoyer.dtdeb,ttQtt.daFinPeriode] */
            if vdaDebutCalendrier >= pdaDebutPeriode and vdaDebutCalendrier <= pdaFinPeriode and vdaFinCalendrier > pdaFinPeriode
            then assign
                vdaDateDebut = vdaDebutCalendrier
                vdaDateFin   = pdaFinPeriode
            .
            if year(vdaDateDebut) <> YEAR(vdaDateFin)
            then vdMontantTmp = (((ttCalendrierEvolutionLoyer.mtper * giNombreMois) / 12) / viNombreJourPeriode)
                                * (date(12, 31, year(vdaDateDebut)) - vdaDateDebut + 1)
                              + (((ttCalendrierEvolutionLoyer.mtper * giNombreMois) / 12) / viNombreJourPeriode)
                                * (vdaDateFin - date(01, 01, year(vdaDateFin)) + 1).
            else vdMontantTmp = (((ttCalendrierEvolutionLoyer.mtper * giNombreMois) / 12) / viNombreJourPeriode)
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

procedure MajRubLoy private:
    /*-------------------------------------------------------------------------
    Purpose: génération des rub loyer dans ttQtt/ttRub pour tous les mois
    Notes: NB si entrée/sortie locataire, cette rubrique sera ensuite proratée par calproqt.p
    ----------------------------------------------------------------------- */
    define output parameter pcLbdivcal as character no-undo.

    define variable vdMontantQuittance  as decimal   no-undo.
    define variable vdMontantTotalLoyer as decimal   no-undo.
    define variable vdMontantQttLoyer   as decimal   no-undo.
    define variable vdMontantRubrique   as decimal   no-undo.
    define buffer rubqt for rubqt.

    find first rubqt no-lock
        where rubqt.cdrub = giNumeroRubrique
          and rubqt.cdlib = giNumeroLibelle no-error.
    /* Calcul du montant loyer suivant le calendrier */
    for each ttQtt 
        where ttQtt.iNumeroLocataire = giNumeroLocataire
          and ttQtt.iNoQuittance >= (if gcTypeTraitement = "CHGQTT-SIM" then giNumeroQuittance else ttQtt.iNoQuittance):

        if glCalendrierEvolution then do:
            /* Recherche du palier contenant le dernier jour du terme */
            vdMontantRubrique = 0.
            for each ttCalendrierEvolutionLoyer:
                if ttQtt.daFinPeriode >= ttCalendrierEvolutionLoyer.dtdeb 
                and (ttCalendrierEvolutionLoyer.dtfin = ? or ttQtt.daFinPeriode <= ttCalendrierEvolutionLoyer.dtfin)
                then vdMontantRubrique = (ttCalendrierEvolutionLoyer.mtper * giNombreMois) / 12.
            end.
        end.
        else run calRubLoy(ttQtt.daDebutPeriode, ttQtt.daFinPeriode, output vdMontantRubrique).

        /* Si pas multilibellé: suppression des rubriques 101 déjà présentes */
        if not glLibelleMultiple
        then for each ttRub
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = 101:
            delete ttRub.
        end.
        /* Recherche si la rubrique 101 existe */
        find first ttRub 
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = giNumeroRubrique
              and ttRub.iNoLibelleRubrique = giNumeroLibelle no-error.  /* Ajout SY le 03/12/2007 - Conflit multi-libellé et calendrier */
        pcLbDivCal = pcLbDivCal + substitute('&1@&2@&3#',
                                      string(ttQtt.iMoisTraitementQuitt, "999999"),
                                      string((if available ttRub then ttRub.dMontantQuittance else 0) * 100, "999999999999"),
                                      string(vdMontantRubrique * 100, "999999999999")).
        if available ttRub then do:
            /* La rubrique 101 existe et le montant calcule est nul --> suppression de la rubrique 101 */
            if vdMontantRubrique = 0
            then do:
                ttQtt.iNombreRubrique = ttQtt.iNombreRubrique - 1.
                delete ttRub.
            end.
            /* La rubrique 101 existe et le montant calcule est non nul Modification de la rubrique 101 */
            else do:
                assign
                    vdMontantTotalLoyer = vdMontantRubrique
                    vdMontantQttLoyer   = vdMontantRubrique
                .
                if ttRub.iNumerateurProrata <> ttRub.iDenominateurProrata
                then assign
                    ttRub.iProrata       = 1
                    vdMontantQttLoyer = (vdMontantQttLoyer * ttRub.iNumerateurProrata ) / ttRub.iDenominateurProrata
                    vdMontantQttLoyer = round(vdMontantQttLoyer, 2)
                .
                assign
                    ttRub.iNoLibelleRubrique = giNumeroLibelle
                    ttRub.daDebutApplication = ttQtt.daDebutPeriode
                    ttRub.daFinApplication = ttQtt.daFinPeriode
                    ttRub.dMontantQuittance = vdMontantQttLoyer
                    ttRub.dMontantTotal = vdMontantTotalLoyer
                .
            end.
        end.
        /* La rubrique 101 n'existe pas et le montant calcule est non nul --> creation de la rubrique 101 en 1ere position */
        else if vdMontantRubrique <> 0 then do:
            create ttRub.
            assign
                ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                ttRub.iNoQuittance = ttQtt.iNoQuittance
                ttRub.iFamille = if available rubqt then rubqt.cdfam else 0
                ttRub.iSousFamille = if available rubqt then rubqt.cdsfa else 0
                ttRub.iNorubrique = giNumeroRubrique
                ttRub.iNoLibelleRubrique = giNumeroLibelle
                ttRub.cCodeGenre = if available rubqt then rubqt.cdgen else ""
                ttRub.cCodeSigne = if available rubqt then rubqt.cdsig else ""
                ttRub.cddet = "0"
                ttRub.dQuantite = 0
                ttRub.dPrixunitaire = 0
                ttRub.dMontantTotal = vdMontantRubrique
                ttRub.iProrata = ttQtt.iProrata
                ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata
                ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata
                ttRub.dMontantQuittance = round(((vdMontantRubrique * ttQtt.iNumerateurProrata) / ttQtt.iDenominateurProrata),2)
                ttRub.daDebutApplication = ttQtt.daDebutPeriode
                ttRub.daFinApplication = ttQtt.daFinPeriode
                ttRub.daDebutApplicationPrecedente = ""
                ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
            .
        end.
        /* Mise a jour du montant de la quittance */
        vdMontantQuittance = 0.
        for each ttRub
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance:
            vdMontantQuittance = vdMontantQuittance + ttRub.dMontantQuittance.
        end.
        assign
            ttQtt.dMontantQuittance = vdMontantQuittance
            ttQtt.cdmaj = 1
        .
    end.
end procedure.

procedure majRubEcart private:
    /* -------------------------------------------------------------------------
     Purpose: Génération de la rubrique de changement de palier dans le terme
     Notes:
    ----------------------------------------------------------------------- */
    define variable vdMontantEcart             as decimal   no-undo.
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
        where ttQtt.iNumeroLocataire = giNumeroLocataire
          and ttQtt.iNoQuittance >= (if gcTypeTraitement = "CHGQTT-SIM" then giNumeroQuittance else ttQtt.iNoQuittance):
        assign
            viNombreJourPeriode     = ttQtt.daFinPeriode - ttQtt.daDebutPeriode + 1
            vdMontantLoyerPrecedent = 0
            vdMontantPalier         = 0
            vdMontantEcart          = 0
        .
        /* Recherche du palier contenant le dernier jour du terme */
boucle101:
        for each ttCalendrierEvolutionLoyer:
            /* recherche palier Rub loyer 101 */
            if ttQtt.daFinPeriode >= ttCalendrierEvolutionLoyer.dtdeb 
            and (ttCalendrierEvolutionLoyer.dtfin = ? or ttQtt.daFinPeriode <= ttCalendrierEvolutionLoyer.dtfin)
            then do:
                vdNouveauMontant = (ttCalendrierEvolutionLoyer.mtper * giNombreMois) / 12.

                if glDebug then put stream StFicSor unformatted skip(1)
                    "MajRubEcart - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                    " Palier utilisé = " string(ttCalendrierEvolutionLoyer.noper)
                    " du " string(ttCalendrierEvolutionLoyer.dtdeb) " au " (if ttCalendrierEvolutionLoyer.dtfin <> ? then string(ttCalendrierEvolutionLoyer.dtfin) else fill(" " , 10))
                    " " string(ttCalendrierEvolutionLoyer.mtper) " Nouveau montant = " string( vdNouveauMontant) skip
                .
                /* il faut boucler sur les paliers < celui utilisé et qui sont utilisés dans le terme */
                vdaCalendrierPrecedent = ttQtt.daDebutPeriode.
                for each vbCalendrierEvolutionLoyer
                    where vbCalendrierEvolutionLoyer.noper <= ttCalendrierEvolutionLoyer.noper:

                    if glDebug then put stream StFicSor unformatted
                        "MajRubEcart - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")               
                        " Boucle palier précédents : " vbCalendrierEvolutionLoyer.noper
                        " du " vbCalendrierEvolutionLoyer.dtdeb " au " (if vbCalendrierEvolutionLoyer.dtfin <> ? then string(vbCalendrierEvolutionLoyer.dtfin) else fill(" " , 10))
                        " " vbCalendrierEvolutionLoyer.mtper " montant rub 101 = " + string( (vbCalendrierEvolutionLoyer.mtper * giNombreMois) / 12 ) skip
                    .
                    /* Recherche si le palier commence dans le terme */ 
                    if vbCalendrierEvolutionLoyer.dtdeb > ttQtt.daDebutPeriode and vbCalendrierEvolutionLoyer.dtdeb < ttQtt.daFinPeriode 
                    and vdMontantLoyerPrecedent <> 0 then do:  /* Calcul rappel/avoir changement de palier */
                        assign
                             vdMontantEcart  = (vdNouveauMontant - vdMontantLoyerPrecedent)
                                             * (vbCalendrierEvolutionLoyer.dtdeb - vdaCalendrierPrecedent) / viNombreJourPeriode
                             vdMontantEcart  = round(vdMontantEcart, 2)
                             vdMontantPalier = vdMontantPalier + vdMontantEcart
                        .
                        if glDebug then put stream StFicSor unformatted 
                            "MajRubEcart - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                            " rappel/avoir calculé = " vdMontantEcart skip
                            fill(" ",14) "Detail : montant préc. rub 101 = " vdMontantLoyerPrecedent
                            " nb jours = " (vbCalendrierEvolutionLoyer.dtdeb - vdaCalendrierPrecedent) 
                            " du " vdaCalendrierPrecedent " au " (vbCalendrierEvolutionLoyer.dtdeb - 1) skip
                        .
                    end.
                    /* loyer palier précédent */
                    assign
                        vdMontantLoyerPrecedent = (vbCalendrierEvolutionLoyer.mtper * giNombreMois) / 12
                        vdaCalendrierPrecedent  = maximum(vbCalendrierEvolutionLoyer.dtdeb, ttQtt.daDebutPeriode)
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
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = 105
              and ttRub.iNoLibelleRubrique = 50 + viNumeroLibelle:
            vdeAvoirRevision = vdeAvoirRevision + absolute(ttRub.dMontantQuittance).
        end.
        for each ttRub
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = 105
              and ttRub.iNoLibelleRubrique = viNumeroLibelle:
            vdeRappelRevision = vdeRappelRevision + absolute(ttRub.dMontantQuittance).
        end.
        /* Ajuster le changement de palier uniquement s'il y en a un */
        if vdMontantPalier <> 0 then do:
            if vdeAvoirRevision <> ? and vdeAvoirRevision <> 0 then do:
                if glDebug then put stream StFicSor unformatted
                    "MajRubEcart - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                    fill(" ", 14) " Avoir révision loyer = " vdeAvoirRevision
                    " => montant changement palier = " vdMontantPalier " - " vdeAvoirRevision skip
                .
                vdMontantPalier = vdMontantPalier - vdeAvoirRevision.
            end.    
            /* Ajout Sy le 11/03/2010 - Taux révision négatif */
            if vdeRappelRevision <> ? and vdeRappelRevision <> 0 then do:
                if glDebug then put stream StFicSor unformatted
                    "MajRubEcart - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                    fill(" ", 14) " Rappel révision loyer = " vdeRappelRevision
                    " => montant changement palier = " vdMontantPalier " + " vdeRappelRevision skip
                .
                vdMontantPalier = vdMontantPalier + vdeRappelRevision.
            end.
        end.
        /* Génération rub 103.xx */
        for each ttRub
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = 103
              and (ttRub.iNoLibelleRubrique = viNumeroLibelle or ttRub.iNoLibelleRubrique = 50 + viNumeroLibelle):
            delete ttRub.
            ttQtt.iNombreRubrique = ttQtt.iNombreRubrique - 1.
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
                "MajRubEcart - Quit concerne = " string(ttQtt.daDebutPeriode, "99/99/9999") "-" string(ttQtt.daFinPeriode, "99/99/9999")
                " create/maj  rub 103." viNumeroLibelleRappelAvoir " montant = " vdMontantPalier skip(1)
            .
            find first ttRub
                where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                  and ttRub.iNoQuittance = ttQtt.iNoQuittance
                  and ttRub.iNorubrique = 103
                  and ttRub.iNoLibelleRubrique = viNumeroLibelleRappelAvoir no-error.
            if not available ttRub then do:
                create ttRub.
                assign
                    ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                    ttRub.iNoQuittance = ttQtt.iNoQuittance
                    ttRub.iFamille = if available rubqt then rubqt.cdfam else 0
                    ttRub.iSousFamille = if available rubqt then rubqt.cdsfa else 0
                    ttRub.iNorubrique = 103
                    ttRub.iNoLibelleRubrique = viNumeroLibelleRappelAvoir
                    ttRub.cCodeGenre = if available rubqt then rubqt.cdgen else ""
                    ttRub.cCodeSigne = if available rubqt then rubqt.cdsig else ""
                    ttRub.cddet = "0"
                    ttRub.dQuantite = 0
                    ttRub.dPrixunitaire = 0
                    ttRub.iProrata = 0
                    ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata
                    ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata
                    ttRub.daDebutApplication = ttQtt.daDebutPeriode
                    ttRub.daFinApplication = ttQtt.daFinPeriode
                    ttRub.daDebutApplicationPrecedente = ""
                    ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
                .
            end.
            assign
                ttRub.dMontantTotal = vdMontantPalier
                ttRub.dMontantQuittance = vdMontantPalier
            .
        end.
    end.
end procedure.
