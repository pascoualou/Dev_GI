/*-----------------------------------------------------------------------------
File        : adecla1.p
Purpose     : Eclatement des encaissements
Author(s)   : GT - , Kantena - 2018/01/11 
Notes       :
01  15/02/2000  CC    Refonte
02  06/03/2000  FR    Choix des mandats et de la periode de fin fiche 4423
03  28/06/2000  PS    MODIF pour cron
04  23/12/2004  JR    1204/0321: La sélection des mandats ne marchait pas. Déclaration de la table ttMandatTravail en NEW SHARED dans ce programme.
05  16/03/2005  DM    Definition ttMandatTravail 0305/0274
06  11/05/2005  DM    0305/0334 Gestion des erreurs d'exécution
07  20/02/2006  OF    0205/0031 Modif adeeclat.i 
08  10/02/2006  OF    0205/0031 Modif adeeclat.i
09  10/04/2006  DM    1205/0160 activation tache TVA en cours de declaration (adeeclat.i) 
10  22/09/2006  DM    0906/0145 Pb ventil si lettrage multiple     | 
11  17/04/2008  DM    0607/0253 Ventilation manuelle encaissements | 
12  37/07/2008  JR    Migration GECOP:
                         AccesDirect Lancement en automatique de l'éclatement des encaissements depuis la migration
                         Modification de adeeclat.i
13  12/08/2008  DM    0508/0177 Régularisation ventil encaissements| 
14  19/09/2008  DM    0608/0065 : Mandat 5 chiffres
15  17/12/2008  DM    0408/0032 : Hono par le quitt
16  29/01/2009  DM    0109/0232 : Eclater les AN de treso et d'ODT
17  23/09/2009  DM    0208/0074 Prise en compte des avoirs en lettrage total et des factures à 0
18  30/03/2010  DM    0310/0197 Pb prise en compte des annulations de réguls sur périodes suivantes
19  18/05/2010  DM    0510/0002 Réactiver les ecritures lettrées à blanc
20  10/02/2011  DM    0211/0063 Taux de tva du bail par défaut     |
21  23/01/2012  DM    1010/0218  TVA EDI
22  16/12/2014  SY    1214/0150 Ajout test retour datetrt.r dans include adeeclat.i
23  12/02/2015  DM    0115/0246 BNP Lettrage total, encaissements au débit et au credit
24  17/02/2015  DM    0413/0088 TVA Manuelle
-----------------------------------------------------------------------------*/
{preprocesseur/codePeriode.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
&SCOPED-DEFINE Detail     aecrdtva
&SCOPED-DEFINE Cod_Quit   QUIT
&SCOPED-DEFINE Role_four  12
&SCOPED-DEFINE Role_loc   19
&SCOPED-DEFINE Role_mand  22
&SCOPED-DEFINE Natjou-od  4 
&SCOPED-DEFINE Natjou-ach 4
&SCOPED-DEFINE Natjou-gi  53
&SCOPED-DEFINE Taxe-cd    5
&SCOPED-DEFINE Eclat 1
using parametre.pclie.parametrageNouveauCRG.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adb/include/chgprtva.i}                    // function getPeriodeTVA2Mandat (ex chgprtva.p)
define variable giPreprocesseurEclat as integer no-undo initial 1.
define temp-table ttMandatTravail no-undo          // extrbbpr.p
    field soc-cd    as integer
    field gest-cle  as character
    field libtype   as character
    field profil-cd as integer
    field etab-cd   as integer
    field nom       as character
    field cpt-cd    as character
    index primaire cpt-cd etab-cd ascending
.
define temp-table ttQuittanceReglement no-undo
    field rRowid as rowid /* DM 0510/0002 */
.
define temp-table ttResteRubrique no-undo
    field cdrub as integer
    field cdlib as integer
    field mt    as decimal decimals 2
.

define input parameter poCollection as class collection no-undo.
define input parameter table for ttMandatTravail.

define stream dm2.
// variables adeeclat.i &  alettrau.i
define variable giCodeSoc         as integer   no-undo.
define variable gdaDeclaration    as date      no-undo.
define variable gdaDebutPeriode   as date      no-undo. 
// variables adeeclat.i
define variable giNumeroPeriode   as integer   no-undo.
define variable giTypeDeclaration as integer   no-undo.
define variable gdeTauxDefaut     as decimal   no-undo.
define variable gdeTauxAvant      as decimal   no-undo.
define variable giGestionCommune  as integer   no-undo.
define variable glTmp-cron        as logical   no-undo.
define variable gcCompte          as character no-undo.
define variable gcJournalQuittancement as character no-undo.
define variable giGeranceGlobale  as integer   no-undo.
define variable giEtablissement   as integer   no-undo.
// variables alettrau.i
define variable giCodeEtab        as integer   no-undo.

run adecla1Private.

procedure adecla1Private private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcCodePeriode  as character no-undo.
    define variable vcGestionnaire as character no-undo.
    define variable viDebutMandat  as integer   no-undo.
    define variable viFinMandat    as integer   no-undo.
    define variable vlSelection    as logical   no-undo.
    define variable vcListeMandatGerance as character no-undo.
    define buffer iparmdt for iparmdt.
    define buffer isoc    for isoc.
    define buffer ijou    for ijou.
    define buffer ietab   for ietab.
    define buffer itaxe   for itaxe.
    define buffer agest   for agest.

    assign
        giCodeSoc      = poCollection:getInteger  ("iCodeSoc")
        giCodeEtab     = poCollection:getInteger  ("iCodeEtab")
        vcGestionnaire = poCollection:getCharacter("cGestionnaire")
        giNumeroPeriode= poCollection:getInt64    ("i6NumeroPeriode")
        gdaDeclaration = poCollection:getDate     ("dDeclaration")
        glTmp-cron     = poCollection:getLogical  ("lCron")
        viDebutMandat  = poCollection:getInteger  ("iDebutMandat")
        viFinMandat    = poCollection:getInteger  ("iFinMandat")
        vlSelection    = poCollection:getLogical  ("lSelection")
        gcCompte       = poCollection:getCharacter("cCompte")
    .
    find first agest no-lock
        where agest.soc-cd   = giCodeSoc
          and agest.gest-cle = vcGestionnaire no-error.
    if not available agest then do:
        mError:createError({&error}, 105873).
       return.
    end.  
    /**  DETERMINATION DU TAUX PAR DEFAUT  **/  
    find first itaxe no-lock
        where itaxe.soc-cd = giCodesoc
          and itaxe.port-emb = true no-error.
    if not available itaxe
    then do:
        mError:createError({&error}, 106668, 'c5').
        return.
    end.
    assign
        gdeTauxDefaut = itaxe.taux
        gdeTauxAvant  = gdeTauxDefaut
    .
    for first itaxe no-lock
        where itaxe.soc-cd = giCodesoc
          and itaxe.taxe-cd = 5:
        gdeTauxAvant = itaxe.taux.
    end.
    /**  RECHERCHE DU JOURNAL DE QUITTANCEMENT   **/
    find first ietab no-lock
        where ietab.soc-cd = giCodesoc  
          and ietab.profil-cd = 20 no-error.
    if not available ietab then return.
    
    find first ijou no-lock
        where ijou.soc-cd    = giCodesoc
          and ijou.etab-cd   = ietab.etab-cd 
          and ijou.natjou-cd = {&Natjou-od}
          and ijou.natjou-gi = {&Natjou-gi} no-error.
    if not available ijou then do:
        mError:createError({&error}, 106894).
        return.
    end.    
    gcJournalQuittancement = ijou.jou-cd.
    
    find first isoc no-lock
       where isoc.soc-cd = giCodesoc no-error.
    if not available isoc then return.
    
    for first ietab no-lock
        where ietab.soc-cd = giCodeSoc                     /***  GERANCE GLOBALE   ***/
          and ietab.profil-cd = 20:
        giGeranceGlobale = ietab.etab-cd.
    end.
    for first ietab no-lock
        where ietab.soc-cd = giCodeSoc                     /***  GESTION COMMUNE   ***/
          and ietab.profil-cd = 10:
        giGestionCommune = ietab.etab-cd.
    end.
    /***  RECHERCHE DES MANDATS DE GERANCE DONT LA PERIODE CORRESPOND  ****/
    for each ttMandatTravail:
        vcListeMandatGerance = vcListeMandatGerance + "," + string(ttMandatTravail.etab-cd).
    end.
    vcListeMandatGerance = trim(vcListeMandatGerance, ",").
boucle:
    for each ietab no-lock
        where ietab.soc-cd   = giCodeSoc
          and ietab.gest-cle = vcGestionnaire
          and (if vlSelection
               then (ietab.etab-cd >= viDebutMandat and ietab.etab-cd <= viFinMandat)
               else lookup(string(ietab.etab-cd), vcListeMandatGerance) > 0)
          and ietab.profil-cd = 21:
        if gdaDeclaration < (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1) then next boucle.  /* DM 0109/0232 Ne pas passer sur les exercices cloturés */

        assign
            giTypeDeclaration = 10               /**  Eclatement des encaissements sans declaration **/
            giEtablissement   = ietab.etab-cd    // problème de buffer si on garde ietab
        .
        for first iparmdt no-lock
            where iparmdt.soc-cd  = ietab.soc-cd
              and iparmdt.etab-cd = ietab.etab-cd
              and iparmdt.fg-soumis:
            if iparmdt.fg-type-decla-rec and iparmdt.fg-type-decla-dep
            then giTypeDeclaration = 1.
            else if not iparmdt.fg-type-decla-rec and not iparmdt.fg-type-decla-dep and iparmdt.fg-regime
                 then giTypeDeclaration = 2.
                 else if not iparmdt.fg-type-decla-rec and iparmdt.fg-type-decla-dep and iparmdt.fg-regime
                      then giTypeDeclaration = 3.
                      else if not iparmdt.fg-type-decla-rec and not iparmdt.fg-type-decla-dep and not iparmdt.fg-regime
                           then giTypeDeclaration = 4.
                           else if not iparmdt.fg-type-decla-rec and iparmdt.fg-type-decla-dep and not iparmdt.fg-regime
                                then giTypeDeclaration = 5.
        end.
        // TODO  pourquoi ce getPeriodeTVA2Mandat? que fait-on de vcCodePeriode?
        vcCodePeriode = getPeriodeTVA2Mandat(ietab.etab-cd).
        run rec_enc.  /* dans {batch/adeeclat.i} */
    end.
    return "1".
end procedure.

{batch/datetrt.i}         // procedure datetrt
{adb/include/isbaitva.i}  // fonction isbaitva utilisée par rec_enc
{batch/adeeclat.i}        // procedure rec_enc

procedure calcul-periode:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : todo  a voir - paramètres si  ---> service utilisé par dossierTravaux.p
             Si l'exercice en cours est le 1, alors la période doit couvrir tout l'exercice 1.
             Si l'exercice en cours est le 2 et le 1 est cloturé, alors la période doit couvrir tout l'execice 2.
             Par contre si le 1 n'est pas cloturé, la période doit couvrir les deux exercices. 
    ------------------------------------------------------------------------------*/
    define input  parameter piSociete       as integer no-undo.
    define input  parameter piEtablissement as integer no-undo.    
    define input  parameter pdaDebutPeriode as date    no-undo.        
    define output parameter pdaPeriodeDebut as date    no-undo.
    define output parameter pdaPeriodeFin   as date    no-undo.
    define buffer iprd  for iprd.
    define buffer ietab for ietab.

    for first iprd no-lock
        where iprd.soc-cd   = piSociete
          and iprd.etab-cd  = piEtablissement
          and iprd.dadebprd <= pdaDebutPeriode
          and iprd.dafinprd >= pdaDebutPeriode
      , first ietab no-lock
            where ietab.soc-cd  = piSociete
              and ietab.etab-cd = piEtablissement:
        if iprd.prd-cd = ietab.prd-cd-2
        then if not ietab.exercice                     /* Exercice en cours = 2 */
            then run periode(piSociete,                /* exercice 1 non cloturé */
                             piEtablissement,
                             ietab.prd-cd-1,           /* 1 */
                             ietab.prd-cd-2,           /* 2 */
                             output pdaPeriodeDebut,
                             output pdaPeriodeFin).
            else run periode(piSociete,                /* exercice 1 cloturé */
                             piEtablissement,
                             ietab.prd-cd-2,           /* 2 */
                             ietab.prd-cd-2,           /* 2 */
                             output pdaPeriodeDebut,
                             output pdaPeriodeFin).
        else if iprd.prd-cd = ietab.prd-cd-1
            then run periode(piSociete,                /* Exercice en cours = 1 */
                             piEtablissement,
                             ietab.prd-cd-1,           /* 1 */
                             ietab.prd-cd-2,           /* 2 */
                             output pdaPeriodeDebut,
                             output pdaPeriodeFin).
    end.
END PROCEDURE.

procedure periode:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter piSociete       as integer no-undo.
    define input  parameter piEtablissement as integer no-undo.    
    define input  parameter piExercice-1    as integer no-undo.
    define input  parameter piExercice-2    as integer no-undo.
    define output parameter pdaPeriodeDebut as date    no-undo.
    define output parameter pdaPeriodeFin   as date    no-undo.
    define buffer iprd for iprd.
    
    for first iprd no-lock
        where iprd.soc-cd  = piSociete
          and iprd.etab-cd = piEtablissement
          and iprd.prd-cd  = piExercice-1:
        pdaPeriodeDebut = iprd.dadebprd.
    end.
    for last iprd no-lock
        where iprd.soc-cd  = piSociete
          and iprd.etab-cd = piEtablissement
          and iprd.prd-cd  = piExercice-2:
        pdaPeriodeFin = iprd.dafinprd.
    end.
END PROCEDURE.

PROCEDURE Lettrage:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter pcSousCodeCollectif as character no-undo.

    define buffer csscpt   for csscpt.
    define buffer ccpt-buf for ccpt.

COMPTE:
    for each csscpt no-lock 
        where csscpt.soc-cd     = giCodeSoc
          and csscpt.etab-cd    = giCodeEtab
          and csscpt.sscoll-cle = pcSousCodeCollectif
          and (if gcCompte > "" then csscpt.cpt-cd = gcCompte else true) /* DM 0607/0253 */
      , first ccpt-buf no-lock
            where ccpt-buf.soc-cd   = giCodeSoc
              and ccpt-buf.coll-cle = csscpt.coll-cle
              and ccpt-buf.cpt-cd   = csscpt.cpt-cd
              and ccpt-buf.libtype-cd = 1:            /*** COMPTES NON LETTRABLES ***/
        {batch/alettrau.i}
    end.
END PROCEDURE.
 