/*------------------------------------------------------------------------
File        : majlocrb.p
Purpose     : Mise � jour des rubriques d'un locataire sur les quittances futures
Author(s)   : SP 1996/01/31  -  Kantena - 2017/12/25
Notes       :
 Param�tres d'entr�es:
   - pcTypeRole : Type de role (TOUJOURS LOCATAIRE)
   - piNumeroRole : Numero de locataire (N� Mandat + N� Apt + Rang)
   - piNumeroQuittance : Numero de quittance corrig�e
   - piNumeroRubrique : Numero de rubrique modifi�e ou cr��e
   - piNumeroLibelle : Numero de libell� rubrique modifi�e ou cr��e (12/12/2006)
   - pdaDebutApplication : Ancienne date de d�but d'application
   - pdaFinApplication : Ancienne date de fin d'application
   En mode CREATION, pdaFinApplication est la date de fin de p�riode de la quittance qui a �t� corrig�e                          �
   - pcDiversParametre : Param divers (12/12/2006)
 01  18/11/1996  SP    Fiche n�652 (r�percution du montant de la rubrique sur les autres quittances)
 02  23/12/1998  SY    Recherche si rubrique n'existe pas d�j� avant de la cr�er                                  �
 03  15/03/2000  SY    Plus de comparaison sur la date de fin d'une rubrique pour r�percuter la modification
                       (Pb dates de fin diff�rentes alors que c'est la m�me rubrique)
 04  10/04/2004  EK    1202/0173: PB perte de rubrique 101 suite � r�vision.
                       A livrer avec suplocrb.p et suprubqu.p
 05  12/12/2006  SY    0905/0335: plusieurs libell�s autoris�s pour les rubriques loyer si param RUBML
     |                 ATTENTION: nouveaux param entr�e/sortie
 06  15/11/2012  SY    Ajout trace Mlog
 07  09/10/2015  PL    0915/0226: pb ttQtt avec 1 seul enregistrement au retour de la facture locataire.
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit �tre positionn�e juste apr�s using */

{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
{bail/include/tmprub.i &nomTable=ttRub2}

define input  parameter piNumeroRole        as integer   no-undo.
define input  parameter piNumeroQuittance   as integer   no-undo.
define input  parameter piNumeroRubrique    as integer   no-undo.
define input  parameter piNumeroLibelle     as integer   no-undo.        /* Ajout SY le 12/12/2006 */
define input  parameter pdaDebutApplication as date      no-undo.
define input  parameter pdaFinApplication   as date      no-undo.
define input-output parameter pcDiversParametre as character no-undo.   /* Ajout SY le 12/12/2006 */
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour        as character no-undo.

define variable giNumeroLibelleOld as integer no-undo.
define variable gdaFinPrc          as date    no-undo.
define variable gdeMontantOld      as decimal no-undo.

giNumeroLibelleOld = integer(entry(1, pcDiversParametre, "@")).       /* ajout SY le 13/12/2006: gestion changement no libell� */
find first ttQtt
    where ttQtt.noLoc = piNumeroRole
      and ttQtt.noQtt = piNumeroQuittance no-error.
IF NOT AVAILABLE ttQtt THEN DO:
    pcCodeRetour = "01".
    RETURN.
END.
for first ttRub
    where ttRub.NoLoc = piNumeroRole
      and ttRub.NoQtt = piNumeroQuittance
      and ttRub.NoRub = piNumeroRubrique
      and ttRub.NoLib = piNumeroLibelle:
    create ttRub2.
    buffer-copy ttRub to ttRub2.
END.
/* R�cup�ration des infos de la quit pr�c�dente */
find prev ttQtt no-error.
if available ttQtt
then gdaFinPrc = ttQtt.DtFpr. /* Date de fin de p�riode de la quit pr�c */
if available ttRub2 and ttRub2.DtDAp = pdaDebutApplication and ttRub2.DtFAp = pdaFinApplication
then gdaFinPrc = ttRub2.DtFAp.

/* MODIFICATION D'UNE RUBRIQUE */
/* Acc�s � la rubrique dans les autres quittances.
   On peut consid�rer que c'est la meme rubrique si la date de d�but d'application est identique */
boucleRubrique:
for each ttRub
    where ttRub.NoLoc = piNumeroRole
      and ttRub.NoQtt <> piNumeroQuittance
      and ttRub.NoRub = piNumeroRubrique
      and ttRub.NoLib = (if giNumeroLibelleOld <> 0 then giNumeroLibelleOld else piNumeroLibelle)    /* ajout SY le 13/12/2006 : gestion changement no libell� */
      and ttRub.DtDap = pdaDebutApplication:
    /* PL : 09/10/2015 - (0915/0226) Attention, si on revient de la facture locataire sans avoir valid�, on a les 12 quittances dans ttRub mais pas dans ttQtt. 
       Seule la modification de la premi�re quittance importe, puisqu'elle sera report�e sur les autres */
    find first ttQtt
        where ttQtt.NoLoc = piNumeroRole
          and ttQtt.NoQtt = ttRub.NoQtt no-error. 
    if not available ttQtt then next boucleRubrique.

    if ttRub.NoQtt < piNumeroQuittance then assign        /* Quittance ant�rieure */
        ttRub.DtFap = gdaFinPrc
        ttQtt.CdMaj = 1
    .
    else do:
        if available ttRub2 then assign
            ttRub.vlMtq = if ttRub.CdPro = 1 then ttRub2.MtTot * ttRub.VlNum / ttRub.VlDen else ttRub2.MtTot
            ttRub.lbRub = ttRub2.LbRub
            ttRub.vlQte = ttRub2.VlQte
            ttRub.vlPun = ttRub2.VlPun
            ttRub.mtTot = ttRub2.MtTot
            ttRub.dtDap = ttRub2.DtDap
            ttRub.dtFap = ttRub2.DtFap
        .
        assign                                   /* Quittance post�rieure */
            gdeMontantOld = ttRub.VlMtq          /* Ancien montant de la rubrique */
            ttRub.NoLib   = piNumeroLibelle      /* nouveau libell� */
            ttQtt.MtQtt   = ttQtt.MtQtt + ttRub.VlMtq - gdeMontantOld
            ttQtt.CdMaj   = 1
        .
    END.
end.

/* CREATION D'UNE RUBRIQUE
 � pdaFinApplication = Date de fin de p�riode de la quittance corrig�e */
/* Parcours des quittances qui devront contenir la nouvelle rubrique */
for each ttQtt
    where ttQtt.NoLoc = piNumeroRole
      and ttQtt.NoQtt > piNumeroQuittance
      and ttQtt.DtDpr > pdaFinApplication
      and (if available ttRub2 then ttQtt.dtFpr <= ttRub2.DtFap else true):
    find first ttRub
        where ttRub.NoLoc = piNumeroRole
          and ttRub.NoQtt = ttQtt.NoQtt
          and ttRub.NoRub = piNumeroRubrique
          and ttRub.NoLib = piNumeroLibelle no-error.
    IF NOT AVAILABLE ttRub THEN DO:
        CREATE ttRub.
        if available ttRub2
        then assign
            ttRub.VlMtq = if ttQtt.CdQuo = 1 then ttRub2.MtTot * ttQtt.NbNum / ttQtt.NbDen else ttRub2.MtTot
            ttRub.CdFam = ttRub2.CdFam
            ttRub.CdSfa = ttRub2.CdSfa
            ttRub.LbRub = ttRub2.LbRub
            ttRub.CdGen = ttRub2.CdGen
            ttRub.CdSig = ttRub2.CdSig
            ttRub.CdDet = ttRub2.CdDet
            ttRub.VlQte = ttRub2.VlQte
            ttRub.VlPun = ttRub2.VlPun
            ttRub.MtTot = ttRub2.MtTot
            ttRub.DtDap = ttRub2.DtDap
            ttRub.DtFap = ttRub2.DtFap
            ttRub.ChFil = ttRub2.ChFil
            ttRub.NoLig = ttRub2.NoLig
        .
        assign
            ttRub.NoLoc = piNumeroRole
            ttRub.NoQtt = ttQtt.NoQtt
            ttRub.CdPro = ttQtt.CdQuo
            ttRub.VlNum = ttQtt.NbNum
            ttRub.VlDen = ttQtt.NbDen
            ttRub.NoRub = piNumeroRubrique
            ttRub.NoLib = piNumeroLibelle
            ttQtt.MtQtt = ttQtt.MtQtt + ttRub.VlMtq
            ttQtt.NbRub = ttQtt.NbRub + 1
            ttQtt.CdMaj = 1
        .
    END.
END.
pcCodeRetour = "00".
