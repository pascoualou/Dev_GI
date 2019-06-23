/*-----------------------------------------------------------------------------
File        : majechqt_ext.p
Purpose     : Mise à jour des quittances à partir de l'echelle mobile des loyers
Author(s)   : SB - 1999/05/21, Kantena - 2018/01/05
Notes       : reprise de adb/src/quit/majechqt_ext.p
01 08/09/1999  SB    la famille et la sous famille de equit pour la rubrique 101 n'etaient pas renseignees (Correction suite test Anne-Marie).
02 11/01/2002  SY    Optimisation: changement index find last tache Révision (04030)
03 19/06/2009  SY    1106/0142: adaptation pour Pré-bail ATTENTION nouveau param entrée majEchqt.p
04 21/12/2009  SY    1209/0174: Emprunt programme oublié
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
{tache/include/tache.i}

define input  parameter pcTypeContrat   as character no-undo.
define input  parameter piNumeroContrat as integer   no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour    as character no-undo initial "00".

define variable ghProcTache             as handle    no-undo.
define variable glRegularisation        as logical   no-undo.
define variable glMontantRegularisation as logical   no-undo.
define variable glRegulVersement        as logical   no-undo.
define variable giPeriodeEchelle        as integer   no-undo.
define variable giNumeroPeriode         as integer   no-undo.
define variable gdeLoyerVariable        as decimal   no-undo.
define variable glPenaliteRetard        as logical   no-undo.
define variable gdePenaliteRetard       as decimal   no-undo.
define variable gdeChiffreAffaire       as decimal   no-undo.
define variable gcLbDiv                 as character no-undo.
define variable gdeLoyerFixe            as decimal   no-undo.
define variable gdeLoyerPlafond         as decimal   no-undo.
define variable gdeLoyerMinimum         as decimal   no-undo.
define variable gdeLoyerCalcule         as decimal   no-undo.
define variable giMoisPeriode           as integer   no-undo.
define variable gdeSommePenalite        as decimal   no-undo.
define variable gdeRegularisation       as decimal   no-undo.
define variable giFamilleRubrique       as integer   no-undo.
define variable giDureeProrata          as integer   no-undo.
define variable giNumeroCalendrier      as integer   no-undo.
define variable gdeLoyerMensuel         as decimal   no-undo.
define variable gdeSommeLoyer           as decimal   no-undo.

run tache/tache.p persistent set ghProcTache.
run getTokenInstance in ghProcTache(mToken:JSessionId).
run majechqtPrivate.
run destroy in ghProcTache.

function determinationPeriodicite returns integer():
    /*-------------------------------------------------------------------------
    Purpose : détermine la périodicité du quittancement
    Notes :
    -------------------------------------------------------------------------*/
    case ttQtt.pdqtt:
        when "00101"                                 then return 12.     /* Mesuelle */
        when "00201" or when "00202"                 then return  6.     /* Bimensuelle */
        when "00301" or when "00302" or when "00303" then return  4.     /* Trimestrielle */
        when "00601" or when "00602" or when "00603"
     or when "00604" or when "00605" or when "00606" then return  2.     /* Semestrielle */
        when "01201" or when "01202" or when "01203"
     or when "01204" or when "01205" or when "01206"
     or when "01207" or when "01208" or when "01209"
     or when "01210" or when "01211" or when "01212" then return  1.     /* Annuelle */
    end case.
    return 0.
end function.

function calculRegularisation returns decimal(pdeMontantRegul as decimal):
    /*-------------------------------------------------------------------------
    Purpose : calcul de la régularisation.
    Notes : anciennement calRegul
    -------------------------------------------------------------------------*/
    define variable vdeNouvelleRegul as decimal no-undo.
    define buffer tache for tache.
    define buffer chaff for chaff.

    for each chaff no-lock
        where chaff.tpcon = pcTypeContrat
          and chaff.nocon = piNumeroContrat
        by chaff.noper descending by chaff.nocal descending:
        for each tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-EchelleMobileLoyer}
              and tache.notac < ttQtt.msqtt
              and entry(1, tache.tpfin, SEPAR[2]) = string(chaff.noper):
            /** calcul du montant de la regul sans prendre la pénalité (si elle existe) **/
            vdeNouvelleRegul = vdeNouvelleRegul + pdeMontantRegul - tache.mtreg + decimal(tache.tpges) / 100.
        end.
        return vdeNouvelleRegul. /* on ne prend que le dernier chiffre d'affaire */
    end.
    return 0.
end function.

procedure majechqtPrivate private:
    /*-------------------------------------------------------------------------
    Purpose :
    Notes :
    -------------------------------------------------------------------------*/
    define variable vdaFin             as date    no-undo.
    define variable vlUneEchelleMobile as logical no-undo.
    define buffer tache for tache.
    define buffer echlo for echlo.

    /* Recherche si mode de calcul Echelle mobile des loyers */
    find last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-revision} no-error.
    if not available tache
    or tache.cdhon <> "00002" then return.

    /* Recherche dates fin et début de bail. */
    for last tache no-lock
        where tache.tptac = {&TYPETACHE-quittancement}
          and tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat:
        vdaFin = tache.dtfin.
    end.
    /* Maj ttQtt */
boucleQuittance:
    for each ttQtt
        where ttQtt.noloc = piNumeroContrat:
        giMoisPeriode = determinationPeriodicite().
        /* Sortie du locataire */
        if vdaFin <> ? and vdaFin < ttQtt.dtfin then leave boucleQuittance.

boucleEchlo:
        for each echlo no-lock
            where echlo.tpcon = pcTypeContrat
              and echlo.nocon = piNumeroContrat
              and echlo.dtdeb <= ttQtt.dtdeb
              and (echlo.dtfin > ttQtt.dtdeb or echlo.dtfin = ?)
            by echlo.noper descending by echlo.nocal descending:
            giNumeroCalendrier = echlo.nocal.
            leave boucleEchlo.
        end.
        for each echlo no-lock
            where echlo.tpcon = pcTypeContrat
              and echlo.nocon = piNumeroContrat
              and echlo.nocal = giNumeroCalendrier
              and echlo.dtdeb <= ttQtt.dtdeb
              and (echlo.dtfin > ttQtt.dtdeb or echlo.dtfin = ?):
            giFamilleRubrique = integer(trim(entry(2, echlo.norub, "-"))).    /* famille de la rubrique */
            if (echlo.dtfin = ? or echlo.dtfin >= ttQtt.dtfin)
            then do:  /* quittancement sur une seule echelle mobile */
                giNumeroPeriode = 1.
                /* calcul du loyer variable */
                run calculLoyerVariable(buffer echlo).
                gcLbDiv = substitute("&2&1&3&1&4", SEPAR[2], echlo.noper, Echlo.Nocal, round(gdeLoyerVariable / giMoisPeriode * 100, 0)).
                run maJTache.
                assign
                    gcLbDiv            = ""
                    gdeLoyerFixe       = echlo.loyfx
                    gdeLoyerPlafond    = echlo.loypl / giMoisPeriode
                    gdeLoyerMinimum    = echlo.loymg / giMoisPeriode
                    vlUneEchelleMobile = no
                    giNumeroPeriode    = 0
                .
            end.
            /* quittancement sur plusieurs echelles mobiles */
            else do:
                assign
                    vlUneEchelleMobile = yes
                    giPeriodeEchelle   = echlo.NoPer
                .
                leave.
            end.
        end.
        /* Une seule echelle mobile */
        if vlUneEchelleMobile = no then do:
            gdeLoyerCalcule = (gdeLoyerFixe + gdeLoyerVariable) / giMoisPeriode.
            for first tache exclusive-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-EchelleMobileLoyer}
                  and tache.notac = ttQtt.msqtt:
                tache.ntges = string(round(gdeLoyerCalcule * 100, 0)).
            end.
            if (gdeLoyerCalcule > gdeLoyerPlafond) and (gdeLoyerPlafond <> 0.00) then gdeLoyerCalcule = gdeLoyerPlafond. /* d,pacement du plafond de loyer */
            if  gdeLoyerCalcule < gdeLoyerMinimum then gdeLoyerCalcule = gdeLoyerMinimum. /* loyer inf,rieur au LMG */
            assign
                gdeRegularisation = if glRegularisation or glRegulVersement then calculRegularisation(gdeLoyerCalcule) else 0
                glRegularisation  = no
                glRegulVersement  = no
            .
            if glPenaliteRetard then gdeSommePenalite = gdeSommePenalite + (gdePenaliteRetard * gdeLoyerCalcule / 100).
            gdeLoyerCalcule  = gdeLoyerCalcule + gdeRegularisation + gdeSommePenalite.
            for last tache exclusive-lock
                where tache.tptac = {&TYPETACHE-EchelleMobileLoyer}
                  and tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.notac = ttQtt.msqtt:
                assign
                    tache.mtreg = gdeLoyerCalcule
                    tache.pdges = string(round((gdeRegularisation * 100), 0))
                    tache.tpges = string(round((gdeSommePenalite  * 100), 0))
                .
            end.
            gdeSommePenalite = 0.
            run majttQtt.
        end.
        else do:
            /* calcul du loyer variable por chaque echelle mobile */
            run LoyPlsEch.
            run MajttQtt.
        end.
    end.
end procedure.

procedure calculLoyerVariable:
    /*-------------------------------------------------------------------------
    Purpose : Calcul le loyer variable en fonction des tranches de chaque activité de l'entreprise.
    Notes : anciennement CalLoyVar
    -------------------------------------------------------------------------*/
    define parameter buffer echlo for echlo.

    define variable viBoucle          as integer  no-undo.
    define variable vdeChiffreAffaire as decimal  no-undo.
    define buffer chaff for chaff.

boucle:
    do viBoucle = 1 to 40:
        /* stop s'il n'existe plus de tranche de CA */
        if echlo.fintc[viBoucle] = 0.00 then leave boucle.

        /* recherche du dernier exercice correspondant */
        for each chaff no-lock
            where chaff.tpcon = pcTypeContrat
              and chaff.nocon = piNumeroContrat
              and chaff.lbact = echlo.lbact
            by chaff.noper descending by chaff.nocal descending:
            gdeChiffreAffaire = if chaff.cavec <> 0 then chaff.cavec else if chaff.cacoc <> 0 then chaff.cacoc else chaff.cacal.
            /* Régularisation avec CA communiqué */
            if chaff.cacoc <> 0 and chaff.dtcom <= ttQtt.dtfin and chaff.dtcom >= ttQtt.Dtdeb
            then do:
                assign
                    glRegularisation        = yes
                    glMontantRegularisation = yes
                .
                /* pénalité de retard */
                if chaff.dtcom <= ttQtt.dtfin and chaff.dtcom >= ttQtt.dtdeb
                and date(echlo.mscom, echlo.jrcom, year(chaff.dtcom)) < chaff.dtcom
                then assign
                    glPenaliteRetard  = yes
                    gdePenaliteRetard = echlo.penal
                .
            end.
            else assign
                glRegularisation        = no
                glMontantRegularisation = no
                glPenaliteRetard        = no
            .
            /* Régularisation avec CA vérifié */
            assign
                glRegulVersement  = (chaff.cavec <> 0.00 and chaff.dtver <= ttQtt.dtfin and chaff.dtver >= ttQtt.Dtdeb)
                vdeChiffreAffaire = (if gdeChiffreAffaire > echlo.fintc[viBoucle] then echlo.fintc[viBoucle] else gdeChiffreAffaire) - echlo.debtc[viBoucle]
                /* somme des montants variables de chaque tranche de CA */
                gdeLoyerVariable  = gdeLoyerVariable + (echlo.prctc[viBoucle] * vdeChiffreAffaire / 100)
            .
            /* sortie de la boucle si le CA correspond a la dernière tranche de CA */
            if gdeChiffreAffaire < echlo.fintc[viBoucle] then return.
            next boucle.  // prochaine tranche
        end.
        return.
    end.
end procedure.

procedure loyPlsEch:
    /*-------------------------------------------------------------------------
    Purpose : Calcul du loyer en fonction des tranches de chaque activité de l'entreprise
              si la quittance est sur plusieurs echelles mobiles.
            ATTENTION, RECURSIF.
    Notes : anciennement loyPlsEch
    -------------------------------------------------------------------------*/
    define variable viNombreJourAnnee as integer  no-undo.
    define variable vdeRatio          as decimal  no-undo.
    define buffer tache for tache.
    define buffer echlo for echlo.

    assign
        viNombreJourAnnee = interval(date(01, 01, year(ttQtt.dtdeb) + 1), date(01, 01, year(ttQtt.dtdeb)), "days")
        giNumeroPeriode   = giNumeroPeriode + 1
    .
    for each echlo no-lock
        where echlo.tpcon = pcTypeContrat
          and echlo.nocon = piNumeroContrat
          and echlo.noper = giPeriodeEchelle
          and echlo.dtdeb <= ttQtt.dtfin
        by echlo.nocal descending:
        giNumeroCalendrier = echlo.nocal.
        leave.
    end.
    gcLbDiv = "".
    for each echlo no-lock
        where echlo.tpcon = pcTypeContrat
          and echlo.nocon = piNumeroContrat
          and echlo.noper = giPeriodeEchelle
          and echlo.nocal = giNumeroCalendrier
          and echlo.dtdeb <= ttQtt.dtfin:
        assign
            gdeLoyerFixe    = echlo.loyfx
            gdeLoyerPlafond = echlo.loypl
            gdeLoyerMinimum = echlo.loymg
            giDureeProrata  = (if echlo.dtfin = ? or echlo.dtfin > ttQtt.dtfin
                               then absolute(ttQtt.dtfin - echlo.dtdeb)
                               else if echlo.dtdeb <= ttQtt.dtdeb
                                    then absolute(echlo.dtfin - ttQtt.dtdeb)
                                    else absolute(echlo.dtfin - echlo.dtdeb)) + 1
            vdeRatio = viNombreJourAnnee / giDureeProrata
         .
        run calculLoyerVariable(buffer echlo).
        gcLbDiv = substitute("&2&3&1&4&1&5&6", SEPAR[2], gcLbDiv, echlo.noper, echlo.Nocal, round(gdeLoyerVariable / vdeRatio * 100, 0), SEPAR[1]).
        run maJTache.
    end.
    assign
        giPeriodeEchelle = giPeriodeEchelle + 1
        gdeLoyerCalcule = (gdeLoyerFixe + gdeLoyerVariable)
        gdeLoyerVariable = 0
    .
    if  (gdeLoyerCalcule > gdeLoyerPlafond) and (gdeLoyerPlafond <> 0.00) then gdeLoyerCalcule = gdeLoyerPlafond. /* dépacement du plafond de loyer */
    if  gdeLoyerCalcule < gdeLoyerMinimum then gdeLoyerCalcule = gdeLoyerMinimum. /* loyer inférieur au LMG */
    if glMontantRegularisation then assign
        gdeLoyerMensuel         = round(gdeLoyerCalcule / giMoisPeriode, 2)
        glMontantRegularisation = no
    .
    gdeLoyerCalcule = gdeLoyerCalcule / viNombreJourAnnee * giDureeProrata.       /* prorata du loyer */
    for each echlo no-lock
        where echlo.tpcon = pcTypeContrat
          and echlo.nocon = piNumeroContrat
          and echlo.noper = giPeriodeEchelle
          and echlo.dtdeb <= ttQtt.dtfin
        by echlo.nocal descending:
        leave.    // permet de se positionner sur le dernier en utilisant un bon index.
    end.
    if available echlo then do:
        assign
            gdeSommeLoyer   = gdeSommeLoyer + gdeLoyerCalcule
            gdeLoyerCalcule = 0
        .
        run loyPlsEch.
    end.
    else do:
        /* pénalité de retard */
        if glPenaliteRetard then gdeSommePenalite = gdeSommePenalite + (gdePenaliteRetard * gdeLoyerMensuel / 100).
        assign
            gdeRegularisation = if glRegularisation or glRegulVersement then calculRegularisation(gdeLoyerMensuel) else 0
            gdeLoyerCalcule   = (gdeSommeLoyer + gdeLoyerCalcule)
            giPeriodeEchelle  = 0
            /* calcul du loyer total ramené a la période de quittancement.
               loyer tot de la periode de quittancement = loyer tot * nb jours dans l'année ( = loyer tot annuel)
                      / périodicité de quittancement 
                      / nb de jour de la période de quittancement */
            gdeLoyerCalcule   = round(gdeLoyerCalcule * viNombreJourAnnee / giMoisPeriode / (ABS(ttQtt.dtfin - ttQtt.dtdeb) + 1), 2)
            gdeLoyerCalcule   = gdeLoyerCalcule + gdeRegularisation + gdeSommePenalite
        .
        for first tache exclusive-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-EchelleMobileLoyer}
              and tache.notac = ttQtt.msqtt:
            assign
                tache.mtreg = gdeLoyerCalcule
                tache.ntges = string(round(gdeLoyerCalcule   * 100, 0))
                tache.pdges = string(round(gdeRegularisation * 100, 0))
                tache.tpges = string(round(gdeSommePenalite  * 100, 0))
            .
        end.
        assign
            gdeSommePenalite = 0
            glRegularisation = no
            glRegulVersement = no
        .
        return.
    end.

end procedure.

procedure majttQtt:
    /*-------------------------------------------------------------------------
    Purpose : MAJ de ttQtt
    Notes :
    -------------------------------------------------------------------------*/
    define variable vdeMontant    as decimal no-undo.
    define buffer rubqt for rubqt.
    define buffer tache for tache.

    assign
        gdeLoyerCalcule = round(gdeLoyerCalcule, 2)
        vdeMontant      = round(gdeLoyerCalcule, 2)
    .
    /* Recherche si la rubrique 101 existe */
    find first ttRub
        where ttRub.noloc = ttQtt.noloc
          and ttRub.noqtt = ttQtt.noqtt
          and ttRub.norub = 101 no-error.
    if available ttRub then do:
        if gdeLoyerCalcule = 0
        then do:   /* La rubrique 101 existe et le montant calcule est nul, suppression de la rubrique 101 */
            ttQtt.nbrub = ttQtt.nbrub - 1.
            delete ttRub.
        end.
        else do:   /* La rubrique 101 existe et le montant calcule est non nul, Modification de la rubrique 101 */
            if ttRub.vlnum <> ttRub.vlden
            then for last tache no-lock
                where tache.tptac = {&TYPETACHE-EchelleMobileLoyer}
                  and tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.notac = ttQtt.msqtt:
                /* ne pas proraté les montants de la régalarisation et de la pénalité */
                assign
                    ttRub.cdpro = 1
                    vdeMontant    = ((gdeLoyerCalcule - integer(tache.pdges) / 100 - integer(tache.tpges) / 100) * ttRub.vlden)
                                / ttRub.vlnum  + integer(tache.pdges) / 100 + integer(tache.tpges) / 100
                    vdeMontant    = round(vdeMontant, 2)
                .
            end.
            assign
                ttRub.nolib = giFamilleRubrique
                ttRub.dtdap = ttQtt.dtdpr
                ttRub.dtfap = ttQtt.dtfpr
                ttRub.vlmtq = vdeMontant
                ttRub.mttot = gdeLoyerCalcule
            .
        end.
    end.
    else do:
    /* La rubrique 101 n'existe pas et le montant calcule est non nul --> creation de la rubrique 101 en 1ere position */
        find first rubqt no-lock
            where rubqt.cdrub = 101
              and rubqt.cdlib = giFamilleRubrique no-error.
        if gdeLoyerCalcule <> 0 then do:
            create ttRub.
            assign
                ttRub.noloc = ttQtt.noloc
                ttRub.noqtt = ttQtt.noqtt
                ttRub.cdfam = if available rubqt then rubqt.cdfam else 0
                ttRub.cdsfa = if available rubqt then rubqt.cdsfa else 0
                ttRub.norub = 101
                ttRub.nolib = giFamilleRubrique
                ttRub.cdgen = if available rubqt then rubqt.cdgen else ""
                ttRub.cdsig = if available rubqt then rubqt.cdsig else ""
                ttRub.cddet = "0"
                ttRub.vlqte = 0
                ttRub.vlpun = 0
                ttRub.mttot = gdeLoyerCalcule
                ttRub.cdpro = ttQtt.cdquo
                ttRub.vlnum = ttQtt.nbnum
                ttRub.vlden = ttQtt.nbden
                ttRub.vlmtq = round(((gdeLoyerCalcule * ttQtt.nbnum) / ttQtt.nbden),2)
                ttRub.dtdap = ttQtt.dtdpr
                ttRub.dtfap = ttQtt.dtfpr
                ttRub.chfil = ""
                ttQtt.nbrub = ttQtt.nbrub + 1
            .
        end.
    end.
    /* Mise a jour du montant de la quittance */
    for each ttRub where ttRub.noloc = ttQtt.noloc
        and ttRub.noqtt = ttQtt.noqtt:
        gdeLoyerCalcule = gdeLoyerCalcule + ttRub.vlmtq.
    end.
    assign
        ttQtt.mtqtt      = gdeLoyerCalcule
        ttQtt.cdmaj      = 1
        gdeLoyerCalcule  = 0
        gdeLoyerVariable = 0
    .
end procedure.

procedure maJTache:
    /*-------------------------------------------------------------------------
    Purpose : création de Tache (TYPETACHE-EchelleMobileLoyer = 04135)
    Notes :
    -------------------------------------------------------------------------*/
    define variable viIdTache     as int64   no-undo.
    define variable viNumeroTache as integer no-undo.
    define buffer chaff for chaff.

    /* recherche du dernier exercice correspondant */
    empty temp-table ttTache.
    find last chaff where chaff.tpcon = pcTypeContrat
            and chaff.nocon = piNumeroContrat
            no-lock no-error.
    if available chaff then do:
        run readTache in ghProcTache(pcTypeContrat, piNumeroContrat, {&TYPETACHE-EchelleMobileLoyer}, ttQtt.msqtt, table ttTache by-reference).
        find first ttTache no-error.
        if available ttTache
        then ttTache.crud  = "U".
        else do:
            /*--> Recherche prochain N°interne et N° de tache libre */
            run getNextTache(pcTypeContrat, piNumeroContrat, {&TYPETACHE-EchelleMobileLoyer}, output viIdTache, output viNumeroTache).
            create ttTache.
            assign
                ttTache.crud  = "C"
                ttTache.noita = viIdTache
                ttTache.tpcon = pcTypeContrat
                ttTache.nocon = piNumeroContrat
                ttTache.tptac = {&TYPETACHE-EchelleMobileLoyer}
                ttTache.notac = ttQtt.msqtt  // on prend le mois de traitement
            .
        end.
        assign
            ttTache.dtdeb = 01/01/0001
            ttTache.dtfin = 01/01/0001
            ttTache.tpfin = string(chaff.noper) + SEPAR[2] + string(chaff.nocal)
            ttTache.duree = 0
            ttTache.dtree = 01/01/0001
            ttTache.ntges = ""
            ttTache.tpges = ""
            ttTache.pdges = ""
            ttTache.cdreg = ""
            ttTache.ntreg = ""
            ttTache.pdreg = ""
            ttTache.dcreg = ""
            ttTache.dtreg = 01/01/0001
            ttTache.mtreg = 0
            ttTache.utreg = ""
            ttTache.tphon = ""
            ttTache.cdhon = ""
            ttTache.lbdiv = gcLbDiv
        .
        run setTache in ghProcTache(table ttTache by-reference).
    end.

end procedure.
