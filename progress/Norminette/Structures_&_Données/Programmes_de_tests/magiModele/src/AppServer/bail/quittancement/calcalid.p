/*-----------------------------------------------------------------------------
File        : calcalid.p
Purpose     : Generation du nouveau calendrier suite a l'indexation, puis recalcul du loyer avec le nouveau calendrier
Author(s)   : JC - 1999/06/03, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calcalid.p
derniere revue: 2018/09/13 - phm: OK

01 17/05/1999  JC    Developpement specifique AGF
02 10/01/2002  AF    Passer les parametres � MajLoyQt
03 21/12/2004  SY    1204/0282: Correction r�vision paliers calev
04 29/09/2005  AF    0905/0267: Si la quittance � reviser etait sur la derniere perdiode du calendrier il etait impossible de lancer MajLoyQt
05 23/11/2005  PL    0705/0179:Eclatement du palier si date de rev incluse dans le palier.
06 20/06/2006  SY    0606/0175: ajout info type traitement pour majloyqt.p
10 28/01/2008  SY    0108/0167: DAUCHEZ, Modification recherche no p�riode � partir de laquelle on doit recalculer les montants et les rappels/avoirs
11 29/02/2008  SY    0107/0373 - AGF Lot 6 - correction g�n�ration palier de r�vision si on est sur le dernier et qu'il n'a pas de date de fin
12 03/03/2008  SY    0107/0373 - AGF Lot 6 - taux rev sur 10 d�c.
13 06/03/2008  SY    0107/0373 - AGF Lot 6 - nouveau calcul, Ajout g�n�ration rub 105 rappel/avoir r�v.
14 19/06/2009  SY    1106/0142 : adaptation pour Pr�-bail. ATTENTION nouveau param entr�e majloyqt.p
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}  // Doit �tre positionn�e juste apr�s using

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{crud/include/calev.i}

{outils/include/lancementProgramme.i}        // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable goCollectionContrat   as class collection no-undo.
define variable goCollectionQuittance as class collection no-undo.

procedure lancementCalcalid:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign   
        goCollectionContrat   = poCollectionContrat
        goCollectionQuittance = poCollectionQuittance
        goCollectionHandlePgm = new collection()   
    .        

message "gga lancementCalcalid ".

    run calcalidPrivate.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure calcalidPrivate private:
    /*-------------------------------------------------------------------------
    Purpose :
    Notes   :
    -------------------------------------------------------------------------*/
    define variable vhProcCalev        as handle    no-undo.
    define variable vhProcMajloyqt     as handle    no-undo.
    define variable vcTypeContrat      as character no-undo.
    define variable viNumeroContrat    as int64     no-undo.
    define variable vdeTauxLoyer       as decimal   no-undo.
    define variable vdaIndexation      as date      no-undo.
    define variable viNumeroCalendrier as integer   no-undo initial 1.
    define variable viNumeroPeriode    as integer   no-undo.
    define variable viPremierPalier    as integer   no-undo.
    define variable vdaDebutCalendrier as date      no-undo.
    define variable vdeLoyerPeriode    as decimal   no-undo.
    define buffer calev for calev.

    empty temp-table ttCalev.
    assign
        vhProcCalev     = lancementPgm("crud/calev_CRUD.p", goCollectionHandlePgm)
        vcTypeContrat   = goCollectionContrat:getCharacter("cTypeContrat")
        viNumeroContrat = goCollectionContrat:getInt64("iNumeroContrat")
        vdeTauxLoyer    = goCollectionQuittance:getDecimal("TxIndLoy10000") / 10000
        vdaIndexation   = goCollectionQuittance:getDate("daIndexation")           /* date de prochaine indexation */
    .
    if goCollectionQuittance:getDecimal("TxIndLoy") > 0     /* Ajout SY le 03/03/2008: taux avec 10 d�cimales */
    then vdeTauxLoyer = goCollectionQuittance:getDecimal("TxIndLoy") / 10000000000.
    
message "gga calcalidPrivate " vcTypeContrat  viNumeroContrat  vdeTauxLoyer vdaIndexation.  
    
    for last calev no-lock
        where calev.tpcon = vcTypeContrat
          and calev.nocon = viNumeroContrat:
        viNumeroCalendrier = calev.nocal + 1.
    end.
    for each calev no-lock
        where calev.tpcon = vcTypeContrat
          and calev.nocon = viNumeroContrat
          and calev.nocal = viNumeroCalendrier - 1:
        assign
            /* Gestion du numero de p�riode */
            viNumeroPeriode    = if viNumeroPeriode = 0 then calev.noper else (viNumeroPeriode + 1)
            /* Gestion de la date de d�but de periode */
            vdaDebutCalendrier = calev.dtdeb
            /* 21/12/2004 - SY : Recherche si le palier doit �tre r�vis� */
            vdeLoyerPeriode    = if calev.dtfin <> ? and calev.dtfin < vdaIndexation
                                 then calev.mtper
                                 else round(calev.mtper + (calev.mtper * (vdeTauxLoyer / 100)), 2)
        .
        /* s�paration du palier en 2 palier si date de r�vision incluse dans la p�riode du palier */
        /* modif SY le 29/02/2008 : gestion dernier palier => pas de date de fin */
        if vdaIndexation > calev.dtdeb
        and ((calev.dtfin <> ? and vdaIndexation < calev.dtfin) or calev.dtfin = ?) then do:
            create ttCalev.
            assign 
                ttCalev.CRUD  = "C" 
                ttCalev.tpcon = vcTypeContrat
                ttCalev.nocon = viNumeroContrat
                ttCalev.nocal = viNumeroCalendrier
                ttCalev.noper = viNumeroPeriode
                ttCalev.dtcal = vdaIndexation
                ttCalev.dtdeb = calev.dtdeb
                ttCalev.dtfin = vdaIndexation - 1
                ttCalev.mtper = calev.mtper
                ttCalev.lbdiv = "I"
                viNumeroPeriode    = viNumeroPeriode + 1  /* gestion du numero de periode suivante */
                vdaDebutCalendrier = vdaIndexation        /* Gestion de la date de debut de la p�riode suivante */
            .
        end.
        create ttCalev.
        assign 
            ttCalev.CRUD  = "C" 
            ttCalev.tpcon = vcTypeContrat
            ttCalev.nocon = viNumeroContrat
            ttCalev.nocal = viNumeroCalendrier
            ttCalev.noper = viNumeroPeriode
            ttCalev.dtcal = vdaIndexation
            ttCalev.dtdeb = vdaDebutCalendrier
            ttCalev.dtfin = calev.dtfin
            ttCalev.mtper = vdeLoyerPeriode
            ttCalev.lbdiv = "I"
        .
        /* M�moriser le 1er palier modifi� */
        if vdeLoyerPeriode <> calev.mtper and viPremierPalier = 0 then viPremierPalier = viNumeroPeriode.
    end.
    run setCalev in vhProcCalev(table ttCalev by-reference).
    delete object vhProcCalev.
    if viPremierPalier = 0
    or not can-find(first equit no-lock
                    where equit.noloc = viNumeroContrat) then return.

    /* Mise � jour des calendriers d'evolution dans le quittancement � partir de la 1�re p�riode modifi�e */    
    goCollectionQuittance:set("iNumeroPeriode", viPremierPalier).
    goCollectionQuittance:set("cTypeTraitement", "CALID").
    goCollectionQuittance:set("deTauxRevision", vdeTauxLoyer * 10000000000).
    vhProcMajloyqt = lancementPgm("bail/quittancement/majloyqt.p", goCollectionHandlePgm).
    run lancementMajloyqt in vhProcMajloyqt(input-output goCollectionQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    run destroy in vhProcMajloyqt.

end procedure.
