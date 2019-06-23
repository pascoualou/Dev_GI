/*-----------------------------------------------------------------------------
File        : creRubca.p
Purpose     : Module de lancement de toutes les procédures de calcul concernant une quittance.
Author(s)   : LG - 1996/04/17, Kantena - 2017/12/15 
Notes       : reprise de adb/src/quit/creRubca_ext.p
derniere revue: 2018/08/14 - phm: 

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
                     (NB : je me demande pourquoi on met a jour ici alors que c'est calrevlo qui le crée - Usage ???)
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

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

{outils/include/lancementProgramme.i}

define variable goCollectionHandlePgm      as class collection no-undo.
define variable goCollectionContrat        as class collection no-undo.
define variable goCollectionQuittance      as class collection no-undo.
define variable goRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
define variable ghProc                as handle no-undo.
define variable gcTypeContrat         as character no-undo.
define variable giNumeroContrat       as int64     no-undo.
define variable giNumeroQuittance     as integer   no-undo.
define variable glRevision            as logical   no-undo.
define variable glIndexationLoyer     as logical   no-undo.
define variable giLibelleRubrique     as integer   no-undo.
define variable glReactualisationAuto as logical   no-undo initial true.

procedure lancementCrerubca:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input-output parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.
 
    define variable vdaDebutPeriode       as date    no-undo.
    define variable vdaFinPeriode         as date    no-undo.
    define variable vdaDebutQuittancement as date    no-undo.
    define variable vdaFinQuittancement   as date    no-undo.
   
    assign
        gcTypeContrat              = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroContrat            = poCollectionContrat:getInteger("iNumeroContrat")
        giNumeroQuittance          = poCollectionQuittance:getInteger("iNumeroQuittance")
        glRevision                 = poCollectionQuittance:getLogical("lRevision")
        glIndexationLoyer          = poCollectionQuittance:getLogical("lIndexationLoyer")
        goCollectionContrat        = poCollectionContrat
        goCollectionQuittance      = poCollectionQuittance
        goCollectionHandlePgm      = new collection()
        goRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
        vdaDebutPeriode            = poCollectionQuittance:getDate("daDebutPeriode")
        vdaFinPeriode              = poCollectionQuittance:getDate("daFinPeriode")
        vdaDebutQuittancement      = poCollectionQuittance:getDate("daDebutQuittancement")
        vdaFinQuittancement        = poCollectionQuittance:getDate("daFinQuittancement")  
    . 
    /* Tests des dates de début de quittance et quittancement et des dates de fin de quittance et de quittancement */
    if vdaDebutQuittancement < vdaDebutPeriode
    or vdaFinQuittancement > vdaFinPeriode
    or vdaFinPeriode < vdaDebutPeriode then do:
        mError:createError({&error}, 1000856, string(giNumeroQuittance)).   //problème génération quittance &1, erreur sur date quittance
        return.
    end.
    run creRubcaPrivate.
    delete object goRubriqueQuittHonoCabinet no-error.
    if not mError:erreur() then run calculMontantQuittance.                   /* Lancement du Calcul de correction des arrondis */
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure creRubcaPrivate private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/    
    define buffer tache  for tache.
    define buffer rubqt  for rubqt.
    define buffer ctrat  for ctrat.
    define buffer sys_lb for sys_lb.
    define buffer equit  for equit.

    /* Modification Loyer en Indemnité d'occupation si procedure de renouvellement - Congés */
    find last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-renouvellement} no-error.
    if available tache and tache.tpfin = "40"
    then for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroContrat
          and ttQtt.iNoQuittance = giNumeroQuittance
          and ttQtt.daDebutPeriode > date(tache.cdreg):
        /*--> Modification du libelle Loyer en Indemnité d'occupation */
        /* ajout SY le 21/09/2009: rechercher la 1ère rubrique "loyer xxx" et vérifier que la rub 101.15 n'existe pas déjà */
boucleRubrique:
        for each ttRub
            where ttRub.iNumeroLocataire = giNumeroContrat
              and ttRub.iNoQuittance = giNumeroQuittance
              and ttRub.iNorubrique = 101
              and ttRub.iNoLibelleRubrique <> 15
          , first rubqt no-lock
            where rubqt.cdrub = ttRub.iNorubrique
              and rubqt.cdlib = ttRub.iNoLibelleRubrique
          , first sys_lb no-lock
            where sys_lb.cdlng = 0 
              and sys_lb.nomes = rubqt.nome1
              and sys_lb.lbmes begins "Loyer":
            giLibelleRubrique = ttRub.iNoLibelleRubrique.
            leave boucleRubrique.
        end.
        if giLibelleRubrique > 0
        and not can-find(first ttRub
                         where ttRub.iNumeroLocataire = giNumeroContrat
                           and ttRub.iNoQuittance = giNumeroQuittance
                           and ttRub.iNorubrique = 101
                           and ttRub.iNoLibelleRubrique = 15)
        then for each ttRub
            where ttRub.iNumeroLocataire = giNumeroContrat      /* modif SY le 21/12/2006 : sur la 1ère rub loyer Uniquement */
              and ttRub.iNoQuittance = giNumeroQuittance
              and ttRub.iNorubrique = 101
              and ttRub.iNoLibelleRubrique = giLibelleRubrique:
            ttRub.iNoLibelleRubrique = 15.
            leave.
        end.
    end.

    /* Lancement de la procédure de calcul du prorata en fonction de la date de résiliation */
    ghProc = lancementPgm("bail/quittancement/calproqt.p", goCollectionHandlePgm).    
    run lancementCalproqt in ghProc(
        goCollectionContrat,
        input-output goCollectionQuittance,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.

    /* Lancement de la procédure de calcul de la rubrique 111: Majoration Méhaignerie */
    ghProc = lancementPgm("bail/quittancement/calmehqt.p", goCollectionHandlePgm).    
    run lancementCalmehqt in ghProc(
        goCollectionContrat,
        goCollectionQuittance,
        true,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.

    /* Lancement de la procédure de calcul de la rubrique 101 pour le F.L. sous garantie locative (04263) */
    ghProc = lancementPgm("bail/quittancement/calgarlo.p", goCollectionHandlePgm).    
    run lancementCalgarlo in ghProc(
        goCollectionContrat,
        goCollectionQuittance,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.
    
    /* Lancement de la procédure de calcul de la rubrique 101 pour le F.L. sous Bail proportionnel (04369) */
    ghProc = lancementPgm("bail/quittancement/calbaipr.p", goCollectionHandlePgm).    
    run lancementCalbaipr in ghProc(
        goCollectionContrat,
        goCollectionQuittance,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.

    /* Lancement de la procedure de calcul des indexations loyer. */
    if glIndexationLoyer then do:
        ghProc = lancementPgm("bail/quittancement/calindlo.p", goCollectionHandlePgm).    
        run lancementCalindlo in ghProc(
            goCollectionContrat,
            goCollectionQuittance,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference
        ).
        if mError:erreur() then return.    
    end.
    
    /* Lancement de la procédure de calcul des révisions loyer. */
    if glRevision then do:
        ghProc = lancementPgm("bail/quittancement/calrevlo.p", goCollectionHandlePgm).    
        run lancementCalrevlo in ghProc(
            goCollectionContrat,
            goCollectionQuittance,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference
        ).
        if mError:erreur() then return.
    end.    
 
    /* Lancement de la procédure de calcul du dépot de garantie */
    for first ctrat no-lock
        where ctrat.tpcon = gcTypeContrat
          and ctrat.nocon = giNumeroContrat:
        if giNumeroQuittance <> 1
        then find first equit no-lock
            where equit.noloc = ctrat.norol no-error.
        if giNumeroQuittance = 1 or (available equit and equit.noqtt = giNumeroQuittance) then do:
            /* facturation auto du Dépot de Garantie en PEC BAIL oui/non */
            /* modif SY le 04/06/2009: QUE pour le bail pas pour le pré-bail */
            if gcTypeContrat = {&TYPECONTRAT-bail}
            then for first tache no-lock
                where tache.tpcon = {&TYPECONTRAT-bail} 
                  and tache.nocon = giNumeroContrat
                  and tache.tptac = {&TYPETACHE-depotGarantieBail}:
                if tache.pdges <> "00001"                            /* Pas de reactualisation automatique DG */
                or (giNumeroQuittance = 1 and tache.tphon = "00002") /* Si 1ere quittance et pas de facturation DG */
                then glReactualisationAuto = false.
            end.
            if glReactualisationAuto then do:
                ghProc = lancementPgm("bail/quittancement/caldpgar.p", goCollectionHandlePgm).
                run lancementCaldpgar in ghProc(
                    goCollectionContrat,
                    goCollectionQuittance,
                    input-output table ttQtt by-reference,
                    input-output table ttRub by-reference
                ).
                if mError:erreur() then return.
            end.
        end.
    end.
    ghProc = lancementPgm("bail/quittancement/calfraLo.p", goCollectionHandlePgm).
    run lancementCalfralo in ghProc(
        goCollectionContrat,
        goCollectionQuittance,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.    /* Ajout SY le 30/11/2009: Quittancement rubriques calculées */

    for last tache no-lock 
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-quittancementRubCalculees}:
        ghProc = lancementPgm("bail/quittancement/calrubqt.p", goCollectionHandlePgm).
        run lancementCalrubqt in ghProc(
            goCollectionContrat,
            goCollectionQuittance,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference
        ).
        if mError:erreur() then return.                                         
    end.
    
    /* Lancement de la procédure de calcul des rubriques soumises à taxe.(TVA, DBT,TAXE ADDI) */
    ghProc = lancementPgm("bail/quittancement/caltaxqt.p", goCollectionHandlePgm).    
    run lancementCaltaxqt in ghProc(
        goCollectionContrat,
        goCollectionQuittance,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.
    
    /* Calcul de la tva sur les honoraires locataire si nécessaire */
    if goRubriqueQuittHonoCabinet:isActif() then do:
        ghProc = lancementPgm("bail/quittancement/caltvaho.p", goCollectionHandlePgm).    
        run lancementCaltvaho in ghProc(
            goCollectionContrat,
            goCollectionQuittance, 
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference
        ).
        if mError:erreur() then return.
    end.
    
    /* Lancement de la procédure de calcul de la rubrique assurance locative (504) */
    ghProc = lancementPgm("bail/quittancement/calasslo.p", goCollectionHandlePgm).    
    run lancementCalasslo in ghProc(
        goCollectionContrat,
        goCollectionQuittance,  
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    
end procedure.

procedure calculMontantQuittance private:
    /*-----------------------------------------------------------------------------
    Purpose: recalcul du Total de la Quittance (Pour Pb d'arrondis...)
    Notes  :
    -----------------------------------------------------------------------------*/
    define variable vdeMontant as decimal no-undo.

    /* Remise à Zéro du Montant de la Quittance. */
    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroContrat 
          and ttRub.iNoQuittance = giNumeroQuittance:
        vdeMontant = truncate(round(vdeMontant + ttRub.dMontantQuittance, 2), 2).
    end.
    /* Mise à Jour du Montant Total de la Quittance. */
    for first ttQtt 
        where ttQtt.iNumeroLocataire = giNumeroContrat
          and ttQtt.iNoQuittance = giNumeroQuittance:
        ttQtt.dMontantQuittance = vdeMontant.
    end.
end procedure.
