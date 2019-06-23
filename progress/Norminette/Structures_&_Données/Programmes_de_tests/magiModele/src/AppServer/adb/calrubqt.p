/*-----------------------------------------------------------------------------
File        : calrubqt.p
Purpose     : Quittancement rubriques calculées (tache 04360, {&TYPETACHE-quittancementRubCalculees})
Author(s)   : SY - 2009/11/30, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calrubqt.p
              > Bases de calcul TTC interdites car incompatibles avec les calculs de Taxes (caltaxqt.p) qui sont effectués APRES calrubqt.p
              > Bases de calcul 'Total Quittance' interdites aussi bien sûr
derniere revue: 2018/04/26 - phm: KO
         traiter les todo

Fiche       : 1108/0397 - Quittancement\QuitRubriqueCalculeeV02.doc
01  03/12/2009  SY    Adaptations pour mise en commun avec compta
02  01/03/2012  SY    0212/0264 Gestion du code signe rubrique include <prrubCal.i>
03  01/03/2012  SY    0212/0264 Gestion du code signe rubrique include <prrubCal.i>
04  07/11/2013  SY    1013/0167 Filtrer Nlle rub TVA 10% et 20% include <prrubCal.i>
05  04/03/2016  SY    1111/0183 DAUCHEZ - Quitt Rubriques calculées Ajout base de calcul 15007 Loyer + Charges HT
06  03/03/2016  SY    0412/0026 Gestion base de calcul paramétrées au cabinet (rubsel)
-----------------------------------------------------------------------------*/
{preprocesseur/codePeriode.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}
&scoped-define NoRub504 504
&scoped-define NoLib504  01

using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
{bail/include/tmprubcal.i}
{bail/include/isTaxCRL.i}    /* recherche si bail soumis à CRL */

define input  parameter pcTypeBail            as character no-undo.
define input  parameter piNumeroBail          as int64     no-undo.
define input  parameter piNumeroQuittance     as integer   no-undo.
define input  parameter pdaDebutQuittancement as date      no-undo.
define input  parameter pdaFinQuittancement   as date      no-undo.
define input  parameter piCodePeriode         as integer   no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour          as character no-undo initial "00".

define variable giNumeroRubrique    as integer   no-undo.
define variable giCodeLibelle       as integer   no-undo.
define variable gdeTotalQuittance   as decimal   no-undo.
define variable gdeMontantQuittance as decimal   no-undo.

run calrubqtPrivate.

function f_librubqt returns character
    (piRubrique as integer, piLibelle as integer, piRole as integer, piMois as integer):
    /*---------------------------------------------------------------------------
    Purpose : Récupération du libellé d'une rubrique de quittancement en tenant compte
              du libellé spécial locataire/mois ou du libellé Cabinet
    Notes   : repris de adb/comm/rclibrub.i  procédure RecLibRub
              utilisé dans prrubcal.i
    ---------------------------------------------------------------------------*/
    define buffer prrub for prrub.
    define buffer rubqt for rubqt.

    /* Récuperation du libelle client de la rubrique.
       On cherche s'il existe un parametrage pour le locataire puis pour le cabinet. */
    /* Libellé specifique locataire/Mois */
    find first prrub no-lock
        where prrub.CdRub = piRubrique
          and prrub.CdLib = piLibelle
          and prrub.NoLoc = piRole
          and prrub.MsQtt = piMois
          and prrub.MsQtt <> 0 no-error.
    if not available prrub
    then find first prrub no-lock        /* Libellé Cabinet */
        where prrub.CdRub = piRubrique
          and prrub.CdLib = piLibelle
          and prrub.NoLoc = 0
          and prrub.MsQtt = 0
          and prrub.LbRub <> "" no-error.
    if available prrub then return prrub.LbRub.
    /* Récupération du no du libellé de  la rubrique */
    for first rubqt no-lock
        where rubqt.cdrub = piRubrique
          and rubqt.cdlib = piLibelle:
        /* Récupération du libellé de la rubrique */
        return outilTraduction:getLibelle(rubqt.nome1).
    end.
    return "".
end function.

procedure calrubqtPrivate private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define variable voSyspr             as class syspr no-undo.
    define variable vdeLoyerMinimum     as decimal   no-undo.
    define variable viMoisQuittancement as integer   no-undo.
    define variable vlCreation          as logical   no-undo.
    define variable vdeTotalLoyer       as decimal   no-undo.
    define variable vdeCumulLoyer       as decimal   no-undo.
    define variable vdeLoyerMensuel     as decimal   no-undo.
    define buffer rubqt for rubqt.

    assign
        voSyspr         = new syspr("MTEUR", "00001")
        vdeLoyerMinimum = if voSyspr:isDbParameter then voSyspr:zone1 else 0
    .
    delete object voSyspr no-error.
    /* Recherche du mois de quittancement */
    for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance:
        viMoisQuittancement = ttQtt.MsQui.
    end.
    /* loyer HT pour loyer mensuel dans IsTaxCRL */
    run calMntRub(2, "15005" /* code O_BSH */, "", output vdeTotalLoyer, output vdeCumulLoyer).
    vdeLoyerMensuel = vdeTotalLoyer / piCodePeriode.
    run chgRubcal(pcTypeBail, piNumeroBail, viMoisQuittancement, vdeLoyerMensuel, vdeLoyerMinimum, output vlCreation).   // output table ttRubCal by-reference).
    /* balayage de la table temporaire pour création/maj/suppression physique des rubriques*/
boucleTtrubcal:
    for each ttRubCal
      , first rubqt no-lock
        where rubqt.cdrub = ttRubCal.cdrub
          and rubqt.cdlib = ttRubCal.cdlib
        by ttRubCal.cdrub by ttRubCal.cdlib:
        /* Affectation des variables de travail */
        assign
            giNumeroRubrique = ttRubCal.cdrub
            giCodeLibelle = ttRubCal.cdlib
            gdeTotalQuittance = ttRubCal.mttot
            gdeMontantQuittance = ttRubCal.vlmtq
        .
        if gdeMontantQuittance = 0 then do:
            for first ttRub
                where ttRub.NoLoc = piNumeroBail
                  and ttRub.NoQtt = piNumeroQuittance
                  and ttRub.NoRub = giNumeroRubrique
                  and ttRub.Nolib = giCodeLibelle:
                delete ttRub.
            end.
            next boucleTtrubcal.
        end.
        find first ttRub
            where ttRub.NoLoc = piNumeroBail
              and ttRub.NoQtt = piNumeroQuittance
              and ttRub.NoRub = giNumeroRubrique
              and ttRub.Nolib = giCodeLibelle no-error.
        if available ttRub then assign
            ttRub.MtTot = gdeTotalQuittance
            ttRub.VlMtq = gdeMontantQuittance
            ttRub.CdPro = 0
            ttRub.VlNum = 0
            ttRub.VlDen = 0
            ttRub.DtDap = pdaDebutQuittancement
            ttRub.DtFap = pdaFinQuittancement
        .
        else run creRubCal(buffer rubqt).            /* Appel de la création de la rubrique */
    end.
    if vlCreation then run majTmQtt.     /* Maj total quittance */
end procedure.

{bail/include/prrubcal.i}    /* ChgRubcal */

procedure creRubCal private:
    /*------------------------------------------------------------------------
    Purpose : Procedure de création d'une rubrique taxe dans ttRub
    Notes   :
    ------------------------------------------------------------------------*/
    define parameter buffer rubqt for rubqt.

    create ttRub.
    assign
        ttRub.NoLoc = piNumeroBail
        ttRub.NoQtt = piNumeroQuittance
        ttRub.CdFam = rubqt.cdfam
        ttRub.CdSfa = rubqt.cdsfa
        ttRub.NoRub = giNumeroRubrique
        ttRub.NoLib = giCodeLibelle
        ttRub.LbRub = ttRubCal.lib
        ttRub.CdGen = rubqt.cdgen
        ttRub.CdSig = rubqt.CdSig
        ttRub.CdDet = "0"
        ttRub.VlQte = 0
        ttRub.VlPun = 0
        ttRub.MtTot = gdeTotalQuittance
        ttRub.CdPro = 0
        ttRub.VlNum = 0
        ttRub.VlDen = 0
        ttRub.VlMtq = gdeMontantQuittance
        ttRub.DtDap = pdaDebutQuittancement
        ttRub.DtFap = pdaFinQuittancement
        ttRub.NoLig = 0
    .
end procedure.

procedure majTmQtt private:
    /*------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    todo    : vérifier pourquoi  Zéro dans ttQtt.MtQtt dans le code d'origine ????
    ------------------------------------------------------------------------*/
    define variable vdeMontantCalcule as decimal  no-undo.
    define variable viNumeroRubrique  as integer  no-undo.

    /* Maj du nombre de rubriques et du montant */
    for each ttRub
        where ttRub.NoLoc = piNumeroBail
          and ttRub.NoQtt = piNumeroQuittance:
        assign
            vdeMontantCalcule = vdeMontantCalcule + ttRub.vlmtq
            viNumeroRubrique  = viNumeroRubrique + 1
        .
    end.
    for first ttQtt
        where ttQtt.noLoc = piNumeroBail
          and ttQtt.noQtt = piNumeroQuittance:
        assign
            ttQtt.nbrub = viNumeroRubrique
            ttQtt.mtQtt = vdeMontantCalcule
            ttQtt.cdMaj = 1
        .
    end.
end procedure.

procedure calMntRub private:
    /*------------------------------------------------------------------------
    Purpose : Procedure d'extraction du montant de la base de calcul
    Notes   : utilisé par l'include prrubcal.i qui utilise pdeMontantCumul
    ------------------------------------------------------------------------*/
    define input  parameter piBaseCalcul     as integer   no-undo.
    define input  parameter pcCodeBaseCalcul as character no-undo.
    define input  parameter pcCodeLibelle    as character no-undo.
    define output parameter pdeTotalCumul    as decimal   no-undo.
    define output parameter pdeMontantCumul  as decimal   no-undo.

    define buffer ttRub  for ttRub.
    define buffer rubsel for rubsel.

    if piBaseCalcul = 1
    then for first ttRub
        where ttRub.NoLoc = piNumeroBail
          and ttRub.NoQtt = piNumeroQuittance
          and ttRub.norub = integer(pcCodeBaseCalcul)
          and ttRub.nolib = integer(pcCodeLibelle):
        assign
            pdeTotalCumul   = ttRub.MtTot
            pdeMontantCumul = ttRub.vlmtq
        .
    end.
    else if piBaseCalcul = 2
    then case pcCodeBaseCalcul:
        when "15005" then for each ttRub            /* Loyer HT */
            where ttRub.noloc = piNumeroBail
              and ttRub.noqtt = piNumeroQuittance
              and ttRub.cdfam = 01
              and ttRub.cdsfa <> 04:
            assign
                pdeTotalCumul   = pdeTotalCumul   + ttRub.MtTot
                pdeMontantCumul = pdeMontantCumul + ttRub.vlmtq
            .
        end.
        when "15007" then for each ttRub            /* Loyer + Charges HT */
            where ttRub.noloc = piNumeroBail
              and ttRub.noqtt = piNumeroQuittance
              and ((ttRub.cdfam = 01 and ttRub.cdsfa <> 04) or ttRub.cdfam = 02):
            assign
                pdeTotalCumul   = pdeTotalCumul   + ttRub.MtTot
                pdeMontantCumul = pdeMontantCumul + ttRub.vlmtq
            .
        end.
    end case.
    else if piBaseCalcul = 3
    then for each ttRub        /* SY 0412/0026 */
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
      , first rubsel no-lock
        where rubsel.tpmdt = ""
          and rubsel.nomdt = 0
          and rubsel.tpct2 = ""
          and rubsel.noct2 = 0
          and rubsel.tptac = {&TYPETACHE-quittancementRubCalculees}
          and rubsel.ixd01 = pcCodeBaseCalcul
          and rubsel.tprub = "Q"
          and integer(rubsel.cdrub) = ttRub.norub
          and integer(rubsel.cdlib) = ttRub.nolib:
        assign
            pdeTotalCumul   = pdeTotalCumul   + ttRub.mtTot
            pdeMontantCumul = pdeMontantCumul + ttRub.vlmtq
        .
    end.
end procedure.
