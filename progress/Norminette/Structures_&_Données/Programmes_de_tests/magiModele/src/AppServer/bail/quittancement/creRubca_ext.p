/*-----------------------------------------------------------------------------
File        : creRubca_ext.p
Purpose     : Module de lancement de toutes les procédures de calcul concernant une quittance.
Author(s)   : LG - 1996/04/17, Kantena - 2017/12/15 
Notes       : reprise de adb/src/quit/creRubca_ext.p
 01  06/05/1996   LG  Ajout module de création des rubriques soumises à taxe.
 02  06/12/1996   SP  Ajout module de calcul du prorata en fonction de la date de résiliation du bail (fiche 700)
 03  18/12/1996   SC  Ajout Procédure de Recalcul total de Quittance pour palier au problèmes d'arrondis.
 04  06/01/1997   SP  Affectation du code retour
 05  20/03/1997   RT  Ajout module de calcul des révisions loyer.
 06  01/06/1999   AF  Ajout module de calcul du depot de garantie
 07  04/06/1999   JC  Ajout module de calcul de l'indexation loyer
 08  07/06/1999   AF  Ajout module de calcul de la franchise
 09  27/07/1999   AF  Ajout module de modification de la tache revision lors d'une modification du loyer
 10  09/09/1999   AF  Passage dans caldpgar si en PEC
 11  18/03/2003   SY  Pas de maj tache revision si loyer inchangé
 12  22/05/2003   SY  Modif maj tache pour ne pas écraser lbdiv2 dans lequel est mémorisé le mois de quitt dans lequel a été faite la dernière révision
 13  16/01/2004   SY  Fiche 0104/0139: suppression maj du loyer stock‚ dans la tache revision (tache.mtreg) car cela écrase le montant révisé calculé
       TODO - remarque GI      (NB : je me demande pourquoi on met a jour ici alors que c'est calrevlo qui le crée - Usage ???)
 14  05/05/2004   SY  0103/0210: Ajout calcul loyer pour fourn. loy. associés à une garantie locative (04263)
 15  01/07/2004   AF  0104/0509: Indemnite d'occupation pour proc de renouvellement
 17  26/04/2006   PL  0205/0453: DG en reprise de bail
 18  21/12/2006   SY  0905/0335: plusieurs libellés autorisés pour les rubriques loyer si param RUBML
 19  08/08/2007   SY  0905/0335: regroupement quit/calmehqt.p avec event/calmehqt.p (=> nouveaux param IN-OUT)|
 20  09/12/2008   PL  0408/0032: honoraire locataire pas le quit
 21  04/06/2009   SY  0509/0277: calculs utilisés pour le Pré-bail => il ne faut pas mettre "01033" mais le type de contrat reçu en entrée!!
 22  21/09/2009   SY  0909/0115: Proc. renouvellement - congés gestion no libellé rubrique 101 et vérifier existence rub 101.15 avant changmt libellé
 23  30/11/2009   SY  1108/0397: Quittancement rubriques calculées
 24  05/06/2012   PL  0212/0155: Bail proportionnel
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
define input  parameter pcTypeContrat              as character no-undo.
define input  parameter piNumeroContrat            as int64     no-undo.
define input  parameter pcNatureContrat            as character no-undo.
define input  parameter piNumeroQuittance          as integer   no-undo.
define input  parameter pdaDebutPeriode            as date      no-undo.
define input  parameter pdaFinPeriode              as date      no-undo.
define input  parameter pdaDebutQuittancement      as date      no-undo.
define input  parameter pdaFinQuittancement        as date      no-undo.
define input  parameter piCodePeriodeQuittancement as integer   no-undo.
define input  parameter plRevision                 as logical   no-undo.
define input  parameter plIndexationLoyer          as logical   no-undo.
define input  parameter poCollection               as class collection no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour as character no-undo.

define variable giLibelleRubrique          as integer   no-undo.
define variable gcLibelleErreur            as character no-undo.
define variable glReactualisationAuto      as logical   no-undo initial true.
define variable goRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.

assign
    gcLibelleErreur = substitute("&1&2: &3 - procedure: ",
                         outilTraduction:getLibelle(101073),
                         if pcTypeContrat = {&TYPECONTRAT-bail} then  " Bail" else " Pré-Bail",
                         string(piNumeroContrat, ">999999999"))
    goRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
.
run creRubcaPrivate.
delete object goRubriqueQuittHonoCabinet no-error.
/* Lancement du Calcul de correction des arrondis */
if pcCodeRetour = "00" then run calculMontantQuittance(piNumeroContrat, piNumeroQuittance). 

procedure creRubcaPrivate private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define buffer tache  for tache.
    define buffer rubqt  for rubqt.
    define buffer ctrat  for ctrat.
    define buffer sys_lb for sys_lb.
    /* Modification Loyer en Indemnité d'occupation si procedure de renouvellement - Congés */
    find last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-renouvellement} no-error.
    if available tache and tache.tpfin = "40"
    then for first ttQtt
        where ttQtt.noLoc = piNumeroContrat
          and ttQtt.noQtt = piNumeroQuittance
          and ttQtt.dtDpr > date(tache.cdreg):
        /*--> Modification du libelle Loyer en Indemnité d'occupation */
        /* ajout SY le 21/09/2009: rechercher la 1ère rubrique "loyer xxx" et vérifier que la rub 101.15 n'existe pas déjà */
boucleRubrique:
        for each ttRub
            where ttRub.noLoc = piNumeroContrat
              and ttRub.noQtt = piNumeroQuittance
              and ttRub.noRub = 101
              and ttRub.nolib <> 15
          , first rubqt no-lock
            where rubqt.cdrub = ttRub.noRub
              and rubqt.cdlib = ttRub.nolib
          , first sys_lb no-lock
            where sys_lb.cdlng = 0 
              and sys_lb.nomes = rubqt.nome1
              and sys_lb.lbmes begins "Loyer":
            giLibelleRubrique = ttRub.nolib.
            leave boucleRubrique.
        end.
        if giLibelleRubrique > 0
        and not can-find(first ttRub
                         where ttRub.noLoc = piNumeroContrat
                           and ttRub.noQtt = piNumeroQuittance
                           and ttRub.noRub = 101
                           and ttRub.nolib = 15)
        then for each ttRub
            where ttRub.noLoc = piNumeroContrat      /* modif SY le 21/12/2006 : sur la 1ère rub loyer Uniquement */
              and ttRub.noQtt = piNumeroQuittance
              and ttRub.noRub = 101
              and ttRub.nolib = giLibelleRubrique:
            ttRub.noLib = 15.
            leave.
        end.
    end.
    /* Lancement de la procédure de calcul du prorata en fonction de la date de résiliation */
    run adb/calproqt.p(
        pcTypeContrat,
        piNumeroContrat,
        piNumeroQuittance,
        input-output pdaFinQuittancement,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference,
        output pcCodeRetour
    ).
    if pcCodeRetour = '01' then do: 
        mError:createError({&error}, gcLibelleErreur + " calproqt.p").
        return.
    end.
    /* Lancement de la procédure de calcul de la rubrique 111: Majoration Méhaignerie */
    run adb/calmehqt.p(
        pcTypeContrat,
        piNumeroContrat,
        piNumeroQuittance,
        pdaDebutPeriode,
        pdaFinPeriode,
        pdaDebutQuittancement,
        pdaFinQuittancement,
        piCodePeriodeQuittancement,
        true,
        poCollection,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference,
        output pcCodeRetour
    ).
    if pcCodeRetour = '01' then do: 
        mError:createError({&error}, gcLibelleErreur + "calmehqt.p").
        return.
    end.
    /* Lancement de la procédure de calcul de la rubrique 101 pour le F.L. sous garantie locative (04263) */
    run adb/calgarlo.p(
        piNumeroContrat,
        piNumeroQuittance,
        pdaDebutPeriode,
        pdaFinPeriode,
        pdaDebutQuittancement,
        pdaFinQuittancement,
        piCodePeriodeQuittancement,
        poCollection,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference,
        output pcCodeRetour
    ).
    if pcCodeRetour = '01' then do: 
        mError:createError({&error}, gcLibelleErreur + "calgarlo.p").
        return.
    end.
    /* Lancement de la procédure de calcul de la rubrique 101 pour le F.L. sous Bail proportionnel (04369) */
    run adb/calbaipr.p(
        pcTypeContrat,
        piNumeroContrat,
        piNumeroQuittance,
        pdaDebutPeriode,
        pdaFinPeriode,
        pdaDebutQuittancement,
        pdaFinQuittancement,
        poCollection,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference,
        output pcCodeRetour
    ).
    if pcCodeRetour = '01' then do: 
        mError:createError({&error}, gcLibelleErreur + "calbaipr.p").
        return.
    end.
    /* Lancement de la procedure de calcul des indexations loyer. */
    if plIndexationLoyer then do:
        run adb/calindlo.p(
            pcTypeContrat,
            piNumeroContrat,
            piNumeroQuittance,
            pdaDebutPeriode,
            pdaFinPeriode,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference,
            output pcCodeRetour
        ).
        if pcCodeRetour = '01' then do: 
            mError:createError({&error}, gcLibelleErreur + "calindlo.p").
            return.
        end.
    end.
    /* Lancement de la procédure de calcul des révisions loyer. */
    if plRevision then do:
        run adb/calrevlo.p(
            pcTypeContrat,
            piNumeroContrat,
            piNumeroQuittance,
            pdaDebutPeriode,
            pdaFinPeriode,
            pdaDebutQuittancement,
            pdaFinQuittancement,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference,
            output pcCodeRetour
        ).
        if pcCodeRetour = '01' then do: 
            mError:createError({&error}, gcLibelleErreur + " calrevlo.p").
            return.
        end.
    end.
    /* Lancement de la procédure de calcul du dépot de garantie */
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        if piNumeroQuittance = 1
        or can-find(first equit no-lock
                    where equit.noloc = ctrat.norol
                      and equit.noqtt = piNumeroQuittance)
        then do:
            /* facturation auto du Dépot de Garantie en PEC BAIL oui/non */
            /* modif SY le 04/06/2009: QUE pour le bail pas pour le pré-bail */
            if pcTypeContrat = {&TYPECONTRAT-bail} then do:
                find first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail} 
                      and tache.nocon = piNumeroContrat
                      and tache.tptac = {&TYPETACHE-depotGarantieBail} no-error.
                if (available tache and tache.pdges <> "00001")                          /* Pas de reactualisation automatique DG */
                or (piNumeroQuittance = 1 and available tache and tache.tphon = "00002") /* Si 1ere quittance et pas de facturation DG */
                then glReactualisationAuto = false.
            end.
            if glReactualisationAuto then do:
                run adb/caldpgar.p(
                    pcTypeContrat,
                    piNumeroContrat,
                    piNumeroQuittance,
                    piCodePeriodeQuittancement,
                    pdaDebutQuittancement,
                    pdaFinQuittancement,
                    poCollection,
                    input-output table ttQtt by-reference,
                    input-output table ttRub by-reference,
                    output pcCodeRetour).
                if pcCodeRetour = '01' then do: 
                    mError:createError({&error}, gcLibelleErreur + " caldpgar.p").
                    return.
                end.
            end.
        end.
    end.
    run adb/calfraLo.p(
        pcTypeContrat,
        piNumeroContrat,
        piNumeroQuittance,
        pdaDebutPeriode,
        pdaFinPeriode,
        pdaDebutQuittancement,
        pdaFinQuittancement,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference,
        output pcCodeRetour).
    if pcCodeRetour = '01' then do:
        mError:createError({&error}, gcLibelleErreur + " calfraLo.p").
        return.
    end.
    /* Ajout SY le 30/11/2009: Quittancement rubriques calculées */
    for last tache no-lock 
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-quittancementRubCalculees}:
        run adb/calrubqt.p(
            pcTypeContrat,
            piNumeroContrat,
            piNumeroQuittance,
            pdaDebutQuittancement,
            pdaFinQuittancement,
            piCodePeriodeQuittancement,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference,
            output pcCodeRetour).
    end.
    /* Lancement de la procédure de calcul des rubriques soumises à taxe.(TVA, DBT,TAXE ADDI) */
    run adb/caltaxqt.p(
              pcTypeContrat,
              piNumeroContrat,
              pcNatureContrat,
              piNumeroQuittance,
              pdaDebutPeriode,
              pdaFinPeriode,
              pdaDebutQuittancement,
              pdaFinQuittancement,
              piCodePeriodeQuittancement,
              poCollection,
              input-output table ttQtt by-reference,
              input-output table ttRub by-reference,
              output pcCodeRetour).
    if pcCodeRetour = '01' then do: 
        mError:createError({&error}, gcLibelleErreur + " caltaxqt.p").
        return.
    end.

    /* Calcul de la tva sur les honoraires locataire si nécessaire */
    if goRubriqueQuittHonoCabinet:isActif() then do:
        run adb/caltvaho.p(
            piNumeroContrat,
            piNumeroQuittance,
            pdaDebutQuittancement,
            pdaFinQuittancement,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference,
            output pcCodeRetour).
        if pcCodeRetour = '01' then do: 
            mError:createError({&error}, gcLibelleErreur + " caltvaho.p").
            return.
        end.
    end.
    /* Lancement de la procédure de calcul de la rubrique assurance locative (504) */
    run adb/calasslo.p(
          pcTypeContrat,
          piNumeroContrat,
          piNumeroQuittance,
          pdaDebutPeriode,
          pdaFinPeriode,
          pdaDebutQuittancement,
          pdaFinQuittancement,
          poCollection,
          input-output table ttQtt by-reference,
          input-output table ttRub by-reference,
          output pcCodeRetour).
    if pcCodeRetour = '01' then do: 
        mError:createError({&error}, gcLibelleErreur + " calasslo.p").
        return.
    end.
end procedure.

procedure calculMontantQuittance private:
    /*-----------------------------------------------------------------------------
    Purpose: recalcul du Total de la Quittance (Pour Pb d'arrondis...)
    Notes  :
    -----------------------------------------------------------------------------*/
    define input parameter piNumeroLocation as integer  no-undo.
    define input parameter piQuittance      as integer  no-undo.

    define variable vdeMontant as decimal  no-undo.

    /* Remise à Zéro du Montant de la Quittance. */
    for each ttRub
        where ttRub.NoLoc = piNumeroLocation 
          and ttRub.NoQtt = piQuittance:
        vdeMontant = truncate(round(vdeMontant + ttRub.VlMtQ, 2), 2).
    end.
    /* Mise à Jour du Montant Total de la Quittance. */
    find first ttQtt 
        where ttQtt.NoLoc = piNumeroLocation
          and ttQtt.NoQtt = piQuittance no-error.
    if available ttQtt then ttQtt.MtQtt = vdeMontant.

end procedure.
