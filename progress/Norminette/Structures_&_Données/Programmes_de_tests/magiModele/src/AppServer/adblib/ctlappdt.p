/*---------------------------------------------------------------------------
File        : ctlappdt.p
Purpose     : Controle des dates d'aplication. 
Author(s)   : TM 26/01/1996   -  GGA 2018/07/12
Notes       : reprise adb/lib/ctlappdt.p
derniere revue: 2018/08/08 - phm: 

04  25/04/1997  SP    Gestion des dates d'application pour les quittances n‚gatives + qqes corrections
05  10/03/1999  SY    Pb baux de 1 mois: Calcul date de fin d'application RUB Fixes 'loin dans le futur'(dans 2 ans)
06  11/03/1999  SY    Fiche 2416: si pas tacite reconduction, utilisation de dtfin sans prolongation
07  25/07/2000  SY    Fiche 5206: Pb for‡age date de fin d'une rubrique fixe avec la date de fin de période 
                      car on calculait la date de fin de bail sans tenir compte de celle saisie
08  07/07/2003  SY    Fiche 0703/0070: suppression du for‡age 3bis qui reculait d'un mois la date de fin d'appli saisie lorsqu'elle était > DtFinBai          
09  05/04/2004  AF    Module prolongation apres expiration
10  12/12/2006  SY    0905/0335: plusieurs libellés autorisés pour les rubriques loyer si param RUBML.
---------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/codeTaciteReconduction.i}

using parametre.pclie.parametrageProlongationExpiration.

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

{outils/include/lancementProgramme.i}            // fonctions lancementPgm, suppressionPgmPersistent.

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghPrgdat as handle no-undo.

procedure lanceCtlappdt:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input parameter        piNumeroLocataire   as integer   no-undo.
    define input parameter        piNumeroQuittance   as integer   no-undo.
    define input parameter        piNumeroRubrique    as integer   no-undo.
    define input parameter        piNumeroLibelle     as integer   no-undo.    /* Ajout SY le 12/12/2006 */
    define input parameter        pcCodeGenre         as character no-undo.
    define input-output parameter pdaDebutApplication as date      no-undo.
    define input-output parameter pdaFinApplication   as date      no-undo.
    define output parameter       pcCodeRetour        as character no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign
        goCollectionHandlePgm = new collection()
        ghPrgdat              = lancementPgm("application/l_prgdat.p", goCollectionHandlePgm)
    . 
    run ctrlDate(piNumeroLocataire, piNumeroQuittance, piNumeroRubrique, piNumeroLibelle, pcCodeGenre,
                  input-output pdaDebutApplication, input-output pdaFinApplication, output pcCodeRetour).
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure ctrlDate private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter        piNumeroLocataire   as integer   no-undo.
    define input parameter        piNumeroQuittance   as integer   no-undo.
    define input parameter        piNumeroRubrique    as integer   no-undo.
    define input parameter        piNumeroLibelle     as integer   no-undo.
    define input parameter        pcCodeGenre         as character no-undo.
    define input-output parameter pdaDebutApplication as date      no-undo.
    define input-output parameter pdaFinApplication   as date      no-undo.
    define output parameter       pcCodeRetour        as character no-undo.

    define variable vdaFinBail               as date    no-undo.
    define variable vlTaciteReconduction     as logical no-undo initial true.
    define variable viMoisFinApplication     as integer no-undo.
    define variable viAnneeFinApplication    as integer no-undo.
    define variable viPeriodeFinApplication  as integer no-undo.
    define variable vdaFinApplicationMax     as date    no-undo.
    define variable viMoisFinPeriode         as integer no-undo.
    define variable viAnneeFinPeriode        as integer no-undo.
    define variable viPeriodeFinPeriode      as integer no-undo.
    define variable viNombreMoisPeriode      as integer no-undo.
    define variable vlProlongationExpiration as logical no-undo.
    define variable voProlongationExpiration as class parametrageProlongationExpiration no-undo.

    define buffer vbttQtt for ttQtt.
    define buffer vbttRub for ttRub.
    define buffer ctrat for ctrat.

    /* Controle du genre de la rubrique Doit etre fixe ("00001") ou variable ("00003") */
    if pcCodeGenre <> {&GenreRubqt-Fixe} and pcCodeGenre <> {&GenreRubqt-Variable} then do:
        pcCodeRetour = "03".
        return.
    end.
    /* Controle d'existance de la quittance dans la table temporaire */
    find first ttQtt
        where ttQtt.iNumeroLocataire = piNumeroLocataire
          and ttQtt.iNoQuittance = piNumeroQuittance no-error.
    if not available ttQtt then do:
        pcCodeRetour = "02".
        return.
    end.
    assign
        voProlongationExpiration = new parametrageProlongationExpiration()
        vlProlongationExpiration = voProlongationExpiration:isQuittancementProlonge()
    .  
    delete object voProlongationExpiration no-error.
    /* Calcul de la date de fin de bail (au cas ou on ne la trouverait pas) */
    run cl2DatFin in ghPrgdat(ttQtt.daEffetBail, ttQtt.iDureeBail, ttQtt.cUniteDureeBail, output vdaFinBail).
    vdaFinBail = vdaFinBail - 1.
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.nocon = piNumeroLocataire:
        assign
            vdaFinBail           = ctrat.dtfin
            vlTaciteReconduction = (ctrat.tpRen = {&TACITERECONDUCTION-YES})
        .
    end.
    /* Pb Baux de 1 mois en tacite reconduction : Calcul Date de fin application pour RUB Fixes loin dans le futur */
    if vdaFinBail <> ?
    then vdaFinApplicationMax = if vlTaciteReconduction 
                                then date(12, 31, year(vdaFinBail) + 2)
                                else if vlProlongationExpiration then 12/31/2950 else vdaFinBail.
    else vdaFinApplicationMax = date(12, 31, year(today) + 2).

    if pdaDebutApplication = ?           /* Pas de date de debut */
    then if pcCodeGenre = {&GenreRubqt-Fixe}
        then assign                      /* Rubrique fixe */
            pdaDebutApplication = ttQtt.daEffetBail
            pcCodeRetour        = "01"
        .
        else assign                      /* Rubrique variable */
            pdaDebutApplication = ttQtt.daDebutPeriode
            pcCodeRetour        = "01"
        .
    if pdaFinApplication = ?             /* Pas de date de fin */
    then if pcCodeGenre = {&GenreRubqt-Fixe}
        then assign                      /* Rubrique fixe */
            pdaFinApplication = if ttQtt.iNoQuittance > 0 then vdaFinApplicationMax else ttQtt.daFinPeriode
            pcCodeRetour = "01"
        .
        else assign                      /* Rubrique variable */
            pdaFinApplication = ttQtt.daFinPeriode
            pcCodeRetour      = "01"
        .
    /* Si les dates de debut et de fin correspondent a la periode --> fin ok */
    if pdaDebutApplication = ttQtt.daDebutPeriode and pdaFinApplication = ttQtt.daFinPeriode then return.

    /* Rectification de la date de debut de periode */
    /* Doit etre toujours superieure ou egale a la date de debut du bail */
    if pdaDebutApplication < ttQtt.daEffetBail 
    then assign
        pdaDebutApplication = ttQtt.daEffetBail
        pcCodeRetour        = "01"
    .
    /* Rectification de la date de fin de periode */
    /* (1) Doit etre toujours inferieure ou egale a la date de fin maxi /*du bail*/ */
    if ttQtt.iNoQuittance > 0 and pdaFinApplication > vdaFinApplicationMax
    then assign                                               
        pdaFinApplication = vdaFinApplicationMax
        pcCodeRetour      = "01"
    .
    /* (1) Doit etre toujours inferieure ou egale a la date de fin des quittances negatives */
    if ttQtt.iNoQuittance < 0 and pdaFinApplication > ttQtt.daFinPeriode 
    then assign
        pdaFinApplication = ttQtt.daFinPeriode
        pcCodeRetour      = "01"
    .
    /* (2) Doit etre toujours superieure ou egale a la date de fin de periode */
    if pdaFinApplication < ttQtt.daFinPeriode 
    then assign
        pdaFinApplication = ttQtt.daFinPeriode
        pcCodeRetour = "01"
    .
    /* (3) Doit etre toujours egale a une fin de periode */
    /* Si la date de fin d'application ne correspond pas a celle de fin de periode a controler */
    if pdaFinApplication <> ttQtt.daFinPeriode then do:
        assign
            viMoisFinApplication    = month(pdaFinApplication)
            viAnneeFinApplication   = year(pdaFinApplication)
            viPeriodeFinApplication = viAnneeFinApplication * 100 + viMoisFinApplication
            viMoisFinPeriode        = month(ttQtt.daFinPeriode)
            viAnneeFinPeriode       = year(ttQtt.daFinPeriode)
            viPeriodeFinPeriode     = viAnneeFinPeriode * 100 + viMoisFinPeriode
        .
        /* Recherche du nombre de mois d'une periode */
        run nbrMoiPer in ghPrgdat(ttQtt.cPeriodiciteQuittancement, output viNombreMoisPeriode).
        /* Tant que la date de fin d'application n'est pas inferieure a la date de fin d'une periode */
        do while viPeriodeFinApplication > viPeriodeFinPeriode:
            /* incrementation d'une periode */
            viMoisFinPeriode = viMoisFinPeriode + viNombreMoisPeriode.
            do while viMoisFinPeriode > 12:
                assign
                    viMoisFinPeriode  = viMoisFinPeriode - 12
                    viAnneeFinPeriode = viAnneeFinPeriode + 1
                .
            end.
            viPeriodeFinPeriode = viAnneeFinPeriode * 100 + viMoisFinPeriode.
        end.
        /* Pour trouver le dernier jour du mois, on enleve un jour au premier du mois suivant. */
        viMoisFinPeriode = viMoisFinPeriode + 1.
        do while viMoisFinPeriode > 12:
            assign
                viMoisFinPeriode  = viMoisFinPeriode - 12
                viAnneeFinPeriode = viAnneeFinPeriode + 1
            .
        end.
        assign
            pdaFinApplication = date(viMoisFinPeriode, 1, viAnneeFinPeriode) - 1
            pcCodeRetour      = "01"
        .
    end.

    /* (4) Doit etre toujours inferieure a une date de debut de quittance possedant la meme rubrique avec des dates differentes */
boucleCtrlDateRubrique:
    for each vbttQtt
        where vbttQtt.iNumeroLocataire = ttQtt.iNumeroLocataire
          and vbttQtt.daDebutPeriode > ttQtt.daFinPeriode
      , each vbttRub
        where vbttRub.iNumeroLocataire = vbttQtt.iNumeroLocataire
          and vbttRub.iNoQuittance = vbttQtt.iNoQuittance
          and vbttRub.iNorubrique = piNumeroRubrique
          and vbttRub.iNoLibelleRubrique = piNumeroLibelle       /* Ajout SY le 12/12/2006 */
          and (vbttRub.daDebutApplication <> pdaDebutApplication or vbttRub.daFinApplication <> pdaFinApplication):
        if pdaFinApplication > (vbttRub.daDebutApplication - 1) and pdaDebutApplication < vbttRub.daDebutApplication
        then do:
            assign
                pdaFinApplication = vbttRub.daDebutApplication - 1
                pcCodeRetour      = "01"
            .
            leave boucleCtrlDateRubrique.
        end.    
    end.

end procedure.
