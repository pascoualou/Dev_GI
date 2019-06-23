/*-----------------------------------------------------------------------------
File        : calrubqt.p
Purpose     : Quittancement rubriques calculées (tache 04360, {&TYPETACHE-quittancementRubCalculees})
Fiche       : 1108/0397 - Quittancement\QuitRubriqueCalculeeV02.doc
Author(s)   : SY - 2009/11/30, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calrubqt.p
              > Bases de calcul TTC interdites car incompatibles avec les calculs de Taxes (caltaxqt.p) qui sont effectués APRES calrubqt.p
              > Bases de calcul 'Total Quittance' interdites aussi bien sûr
derniere revue: 2018/08/14 - phm: 

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
{preprocesseur/base2honoraire.i}

&scoped-define NoRub504 504
&scoped-define NoLib504  01

using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i}  // Doit être positionnée juste après using

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{bail/include/tmprubcal.i}
{bail/include/isTaxCRL.i}                    // fonction isTaxCRL
{outils/include/lancementProgramme.i}        // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable gcTypeBail            as character no-undo.
define variable giNumeroBail          as int64     no-undo.
define variable giNumeroQuittance     as integer   no-undo.
define variable gdaDebutQuittancement as date      no-undo.
define variable gdaFinQuittancement   as date      no-undo.
define variable giCodePeriode         as integer   no-undo.
define variable giNumeroRubrique      as integer   no-undo.
define variable giCodeLibelle         as integer   no-undo.
define variable gdeTotalQuittance     as decimal   no-undo.
define variable gdeMontantQuittance   as decimal   no-undo.

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

procedure lancementCalrubqt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign
        gcTypeBail            = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroBail          = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroQuittance     = poCollectionQuittance:getInteger("iNumeroQuittance")
        gdaDebutQuittancement = poCollectionQuittance:getDate("daDebutQuittancement")
        gdaFinQuittancement   = poCollectionQuittance:getDate("daFinQuittancement")        
        giCodePeriode         = poCollectionQuittance:getInteger("iCodePeriodeQuittancement")
        goCollectionHandlePgm = new collection()
    .

message "lancementCalrubqt " gcTypeBail "/" giNumeroBail "/" giNumeroQuittance "/" gdaDebutQuittancement "/" gdaFinQuittancement "/" giCodePeriode "/".

    run calrubqtPrivate.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

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
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        viMoisQuittancement = ttQtt.iMoisReelQuittancement.
    end.
    /* loyer HT pour loyer mensuel dans IsTaxCRL */
    run calMntRub(2, {&BASEHONORAIRE-loyerHT} /* code O_BSH */, "", output vdeTotalLoyer, output vdeCumulLoyer).
    vdeLoyerMensuel = vdeTotalLoyer / giCodePeriode.
    run chgRubcal(gcTypeBail, giNumeroBail, viMoisQuittancement, vdeLoyerMensuel, vdeLoyerMinimum, output vlCreation).
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
                where ttRub.iNumeroLocataire = giNumeroBail
                  and ttRub.iNoQuittance = giNumeroQuittance
                  and ttRub.iNorubrique = giNumeroRubrique
                  and ttRub.iNoLibelleRubrique = giCodeLibelle:
                delete ttRub.
            end.
            next boucleTtrubcal.
        end.
        find first ttRub
            where ttRub.iNumeroLocataire = giNumeroBail
              and ttRub.iNoQuittance = giNumeroQuittance
              and ttRub.iNorubrique = giNumeroRubrique
              and ttRub.iNoLibelleRubrique = giCodeLibelle no-error.
        if available ttRub
        then assign
            ttRub.dMontantTotal = gdeTotalQuittance
            ttRub.dMontantQuittance = gdeMontantQuittance
            ttRub.iProrata = 0
            ttRub.iNumerateurProrata = 0
            ttRub.iDenominateurProrata = 0
            ttRub.daDebutApplication = gdaDebutQuittancement
            ttRub.daFinApplication = gdaFinQuittancement
        .
        else run creRubCal(buffer rubqt).            /* Appel de la création de la rubrique */
    end.
    if vlCreation then run majTmQtt.                 /* Maj total quittance */
end procedure.

{bail/include/prrubcal.i}    /* procedure chgRubcal */

procedure creRubCal private:
    /*------------------------------------------------------------------------
    Purpose : Procedure de création d'une rubrique taxe dans ttRub
    Notes   :
    ------------------------------------------------------------------------*/
    define parameter buffer rubqt for rubqt.

    create ttRub.
    assign
        ttRub.iNumeroLocataire = giNumeroBail
        ttRub.iNoQuittance = giNumeroQuittance
        ttRub.iFamille = rubqt.cdfam
        ttRub.iSousFamille = rubqt.cdsfa
        ttRub.iNorubrique = giNumeroRubrique
        ttRub.iNoLibelleRubrique = giCodeLibelle
        ttRub.cLibelleRubrique = ttRubCal.lib
        ttRub.cCodeGenre = rubqt.cdgen
        ttRub.cCodeSigne = rubqt.CdSig
        ttRub.CdDet = "0"
        ttRub.dQuantite = 0
        ttRub.dPrixunitaire = 0
        ttRub.dMontantTotal = gdeTotalQuittance
        ttRub.iProrata = 0
        ttRub.iNumerateurProrata = 0
        ttRub.iDenominateurProrata = 0
        ttRub.dMontantQuittance = gdeMontantQuittance
        ttRub.daDebutApplication = gdaDebutQuittancement
        ttRub.daFinApplication = gdaFinQuittancement
        ttRub.iNoOrdreRubrique = 0
    .
end procedure.

procedure majTmQtt private:
    /*------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    ------------------------------------------------------------------------*/
    define variable vdeMontantCalcule as decimal no-undo.
    define variable viNombreRubrique  as integer no-undo.

    /* Maj du nombre de rubriques et du montant */
    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance:
        assign
            vdeMontantCalcule = vdeMontantCalcule + ttRub.dMontantQuittance
            viNombreRubrique  = viNombreRubrique + 1
        .
    end.
    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        assign
            ttQtt.iNombreRubrique = viNombreRubrique
            ttQtt.dMontantQuittance = vdeMontantCalcule
            ttQtt.cdMaj = 1
        .
    end.
end procedure.
