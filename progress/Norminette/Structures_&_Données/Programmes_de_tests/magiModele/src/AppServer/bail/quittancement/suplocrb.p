/*------------------------------------------------------------------------
File        : suplocrb.p
Purpose     : Mise a jour des quittances suite a une suppression de rubrique
Author(s)   : EK 10/04/2003   -  GGA 2018/07/16
Notes       : reprise adb/quit/suplocrb.p
derniere revue: 2018/08/16 - phm: KO
        messages

 Parametres d'entrees:
   - piNumeroRole        : Numero de locataire (Nø Mandat + Nø Apt + Rang)
   - piNumeroQuittance   : Numero de quittance corrigee
   - piNumeroRubrique    : Numero de rubrique modifiee
   - piNumeroLibelle     : Numero de libellé rubrique modifiee ou cree(12/12/2006)
   - pdaDebutApplication : Ancienne date de debut d'application
   - pdaFinApplication   : Ancienne date de fin d'application

 Parametres de sorties :
   - pcCodeRetour : Code retour

 0001  13/12/2006    SY    0905/0335 : plusieurs libellés autorisés pour
                           les rubriques loyer si param RUBML
                           ATTENTION : nouveaux param entrée/sortie
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{bail/include/tbtmprub.i &nomTable=ttRub2}

procedure trtSuplocrb:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter piNumeroRole        as int64   no-undo.
    define input parameter piNumeroQuittance   as integer no-undo.
    define input parameter piNumeroRubrique    as integer no-undo.
    define input parameter piNumeroLibelle     as integer no-undo.
    define input parameter pdaDebutApplication as date    no-undo.
    define input parameter pdaFinApplication   as date    no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    define variable vdaFinPrc     as date    no-undo.
    define variable vdeMontantOld as decimal no-undo.

message "gga suplocrb " piNumeroRole piNumeroQuittance piNumeroRubrique piNumeroLibelle  pdaDebutApplication pdaFinApplication.

    find first ttQtt
        where ttQtt.iNumeroLocataire = piNumeroRole
          and ttQtt.iNoQuittance = piNumeroQuittance no-error.
    if not available ttQtt then do:
        mError:createError({&error}, 1000853, string(piNumeroQuittance)).   //problème maj quittance &1, erreur sur table quittance
        return.
    end.
    empty temp-table ttRub2.
    for first ttRub
        where ttRub.iNumeroLocataire = piNumeroRole
          and ttRub.iNoQuittance = piNumeroQuittance
          and ttRub.iNorubrique = piNumeroRubrique
          and ttRub.iNoLibelleRubrique = piNumeroLibelle:
        create ttRub2.
        buffer-copy ttRub to ttRub2.
    end.
    /* Récupération des infos de la quit précédente */
    find prev ttQtt no-error.
    if available ttQtt
    then vdaFinPrc = ttQtt.daFinPeriode. /* Date de fin de période de la quit préc */
    if available ttRub2 and ttRub2.daDebutApplication = pdaDebutApplication and ttRub2.daFinApplication = pdaFinApplication
    then vdaFinPrc = ttRub2.daFinApplication.

    /* MODIFICATION D'UNE RUBRIQUE */
    /* Accès à la rubrique dans les autres quittances.
       On peut considérer que c'est la meme rubrique si la date de début d'application est identique */
boucleRubrique:
    for each ttRub
        where ttRub.iNumeroLocataire = piNumeroRole
          and ttRub.iNoQuittance <> piNumeroQuittance
          and ttRub.iNorubrique = piNumeroRubrique
          and ttRub.iNoLibelleRubrique = piNumeroLibelle
          and ttRub.daDebutApplication = pdaDebutApplication:
        find first ttQtt
            where ttQtt.iNumeroLocataire = piNumeroRole
              and ttQtt.iNoQuittance = ttRub.iNoQuittance no-error.
        if not available ttQtt then next boucleRubrique.

        if ttRub.iNoQuittance < piNumeroQuittance                             /* Quittance antérieure */
        then assign
            ttRub.daFinApplication = vdaFinPrc
            ttQtt.CdMaj = 1
        .
        else do:
            vdeMontantOld = ttRub.dMontantQuittance.
            if available ttRub2 and ttRub2.daFinApplication >= ttQtt.daFinPeriode
            then assign
                ttRub.dMontantQuittance = if ttRub.iProrata = 1 then ttRub2.dMontantTotal * ttRub.iNumerateurProrata / ttRub.iDenominateurProrata else ttRub2.dMontantTotal
                ttRub.cLibelleRubrique = ttRub2.cLibelleRubrique
                ttRub.dQuantite = ttRub2.dQuantite
                ttRub.dPrixunitaire = ttRub2.dPrixunitaire
                ttRub.dMontantTotal = ttRub2.dMontantTotal
                ttRub.daDebutApplication = ttRub2.daDebutApplication
                ttRub.daFinApplication = ttRub2.daFinApplication
                ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + ttRub.dMontantQuittance - vdeMontantOld
                ttQtt.CdMaj = 1
            .
            else do:
                delete ttRub.
                assign
                    ttQtt.dMontantQuittance = ttQtt.dMontantQuittance - vdeMontantOld
                    ttQtt.iNombreRubrique = ttQtt.iNombreRubrique - 1
                    ttQtt.CdMaj = 1
                .
            end.
        end.
    end.
    /* CREATION D'UNE RUBRIQUE pdaFinApplication = Date de fin de période de la quittance corrigée */
    /* Parcours des quittances qui devront contenir la nouvelle rubrique */
    for each ttQtt
        where ttQtt.iNumeroLocataire = piNumeroRole
          and ttQtt.iNoQuittance > piNumeroQuittance
          and ttQtt.daDebutPeriode > pdaFinApplication
          and (if available ttRub2 then ttQtt.daFinPeriode <= ttRub2.daFinApplication else true):
        find first ttRub
            where ttRub.iNumeroLocataire = piNumeroRole
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = piNumeroRubrique
              and ttRub.iNoLibelleRubrique = piNumeroLibelle no-error.
        if not available ttRub then do:
            create ttRub.
            if available ttRub2
            then assign
                ttRub.dMontantQuittance = if ttQtt.iProrata = 1 then ttRub2.dMontantTotal * ttQtt.iNumerateurProrata / ttQtt.iDenominateurProrata else ttRub2.dMontantTotal
                ttRub.iFamille = ttRub2.iFamille
                ttRub.iSousFamille = ttRub2.iSousFamille
                ttRub.cLibelleRubrique = ttRub2.cLibelleRubrique
                ttRub.cCodeGenre = ttRub2.cCodeGenre
                ttRub.cCodeSigne = ttRub2.cCodeSigne
                ttRub.CdDet = ttRub2.CdDet
                ttRub.dQuantite = ttRub2.dQuantite
                ttRub.dPrixunitaire = ttRub2.dPrixunitaire
                ttRub.dMontantTotal = ttRub2.dMontantTotal
                ttRub.daDebutApplication = ttRub2.daDebutApplication
                ttRub.daFinApplication = ttRub2.daFinApplication
                ttRub.daDebutApplicationPrecedente = ttRub2.daDebutApplicationPrecedente
                ttRub.iNoOrdreRubrique = ttRub2.iNoOrdreRubrique
            .
            assign
                ttRub.iNumeroLocataire = piNumeroRole
                ttRub.iNoQuittance = ttQtt.iNoQuittance
                ttRub.iProrata = ttQtt.iProrata
                ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata
                ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata
                ttRub.iNorubrique = piNumeroRubrique
                ttRub.iNoLibelleRubrique = piNumeroLibelle
                ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + ttRub.dMontantQuittance
                ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
                ttQtt.CdMaj = 1
            .
        end.
    end.

end procedure.
