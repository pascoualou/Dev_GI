/*------------------------------------------------------------------------
File        : isindloy.p
Purpose     : Module pour savoir s'il faut appliquer ou non le module de calcul des indexations loyer 
              (Copie de IsRevLoy.p)
Author(s)   : 04/06/1999 JC   -    2018/07/02  GGA
Notes       : reprise de adb/quit/isindloy_ext.p
derniere revue: 2018/08/14 - phm: 

01  03/12/2001  SY    CREDIT LYONNAIS: les fournisseurs loyer ont leur mois de qtt & mois modifiable différent de celui des locataires (GlMflQtt & GlMflMdf)
02  29/03/2004  SY    On ne doit pas réviser un locataire sorti ou expiré ou résilié (quittance inactive)
03  29/03/2004  SY    Ne pas déclencher la révision si quittance historisée (msqtt < GlMoiMdf) ou supérieure au prochain quitt (> GlMoiQtt) 
04  05/04/2004  AF    Module Prolongation apres expiration
05  16/06/2004  SY    0504/0086 - pb suite modif 0304/0246: Tmqtt n'existe pas lorsque isrevloy.p est appelé par le majequit des transfert (appel a partir de equit)
06  28/06/2004  SY    0604/0349 - pb suite modif prolongation: "parametre client absent" (FGEXP)
07  10/01/2005  SY    0105/0090 - duplication corrections isrevloy
08  16/09/2008  SY    0608/0065 Gestion mandats 5 chiffres
09  28/09/2009  NP    0909/0164 : Emission quittances à l'avance (DAUCHEZ) Ouverture révision aux mois > QUITT si pas d'autre Avis d'échéance avant
10  11/12/2017  SY    #9521 Gestion des baux à indexer dont le taux calculé est à 0 (idem 0117/0142)
11  01/04/2018  JPM   #13535  Passage en INT64
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.pclie.parametrageProlongationExpiration. // lié a filtrelo.i

{oerealm/include/instanciateTokenOnModel.i}          // Doit être positionnée juste après using
{bail/include/tbtmpqtt.i}
{tache/include/tache.i}

{bail/include/filtreLo.i}                            // Filtrage locataire à prendre, procedure filtreLoc
{outils/include/lancementProgramme.i}                // fonctions lancementPgm, suppressionPgmPersistent
{bail/quittancement/procedureCommuneQuittance2.i}    // fonction dateFinBail, procédure chgTaux

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghProc as handle no-undo.

procedure lancementIsindloy:
    /*-------------------------------------------------------------------
    Purpose: 
    Notes:   service externe
  ----------------------------------------------------------------------*/
    define input        parameter poCollectionContrat   as class collection no-undo.
    define input-output parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.  

    goCollectionHandlePgm = new collection().
    poCollectionQuittance:set("cIndexationLoyer", "00").
    run isindloy (poCollectionContrat, input-output poCollectionQuittance).
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure isindloy private:
    /*-------------------------------------------------------------------
    Purpose: isindloy 
    Notes:
  ----------------------------------------------------------------------*/
    define input        parameter poCollectionContrat   as class collection no-undo.
    define input-output parameter poCollectionQuittance as class collection no-undo.

    define variable vcTypeContrat             as character no-undo.
    define variable viNumeroContrat           as integer   no-undo.
    define variable viNumeroQuittance         as integer   no-undo.
    define variable vdaDebutPeriode           as date      no-undo.
    define variable vdaFinPeriode             as date      no-undo.
    define variable vdaDebutQuittance         as date      no-undo.
    define variable vdaFinQuittance           as date      no-undo.
    define variable vlBailFournisseurLoyer    as logical   no-undo.
    define variable vdeTauxIndexationLoyer    as decimal   no-undo.
    define variable vdeValeurIndexationLoyer  as decimal   no-undo.
    define variable vlIndParu                 as logical   no-undo.
    define variable viMsQttTmp                as integer   no-undo.
    define variable vlTaciteReconduction      as logical   no-undo.
    define variable vdaFinBail                as date      no-undo.
    define variable vdaSortieLocataire        as date      no-undo.
    define variable vdaResiliationBail        as date      no-undo.
    define variable vdaFinApplicationRubrique as date      no-undo.
    define variable viMoisQttMEchu            as integer   no-undo.
    define variable viMoisQttModifiable       as integer   no-undo.
    define variable viMoisQttEncours          as integer   no-undo.
    define variable vcCodeModele              as character no-undo.
    define variable viNumeroFourLoyerDebut    as integer   no-undo.
    define variable viNumeroFourLoyerFin      as integer   no-undo.
    define variable viNombreMoisGesfl         as integer   no-undo.
    define variable vcCdTerLoc                as character no-undo.
    define variable vlPrendre                 as logical   no-undo.

    define buffer equit for equit.
    define buffer tache for tache.

    assign
        vcTypeContrat          = poCollectionContrat:getCharacter("cTypeContrat")
        viNumeroContrat        = poCollectionContrat:getInteger("iNumeroContrat")
        vlBailFournisseurLoyer = poCollectionContrat:getLogical("lBailFournisseurLoyer")
        viNumeroQuittance      = poCollectionQuittance:getInteger("iNumeroQuittance")
        vdaDebutPeriode        = poCollectionQuittance:getDate("daDebutPeriode")
        vdaFinPeriode          = poCollectionQuittance:getDate("daFinPeriode")
        vdaDebutQuittance      = poCollectionQuittance:getDate("daDebutQuittancement")
        vdaFinQuittance        = poCollectionQuittance:getDate("daFinQuittancement")
    .

    /* Tests des dates de debut de quittance et de quittancement et des dates de fin de quittance et de quittancement */
    if vdaDebutQuittance < vdaDebutPeriode 
    or vdaFinQuittance > vdaFinPeriode
    or vdaFinPeriode < vdaDebutPeriode then return.

    /* Filtre (= Qtt locataire … prendre ?) */
    run filtreLoc (vdaDebutPeriode, viNumeroContrat, output vlTaciteReconduction, output vdaFinBail, output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre, output vdaFinApplicationRubrique).
    if not vlPrendre then return.
 
    //les infos mois modifiable, encours et echu sont renseignees en fonction du type bail fournisseur loyer dans le pgm de plus haut niveau       
    assign 
        viMoisQttModifiable = poCollectionQuittance:getInteger("iMoisModifiable")  
        viMoisQttEncours    = poCollectionQuittance:getInteger("iMoisQuittancement")   
        viMoisQttMEchu      = if vlBailFournisseurLoyer
                              then viMoisQttModifiable else poCollectionQuittance:getInteger("iMoisEchu")
    .
    find first ttQtt
        where ttQtt.iNumeroLocataire = viNumeroContrat
          and ttQtt.iNoQuittance     = viNumeroQuittance no-error.
    if available ttQtt 
    then assign
        vcCdTerLoc = ttQtt.cCodeTerme
        viMsQttTmp = ttQtt.iMoisTraitementQuitt
    .
    else for first equit no-lock
        where equit.NoLoc = viNumeroContrat
          and equit.NoQtt = viNumeroQuittance:
        assign
            vcCdTerLoc = equit.cdter
            viMsQttTmp = equit.msqtt
        .
    end.

    if viMsQttTmp <> 0 then do:
        /*-----------------------------------------------*
         On ne peut reviser que dans le mois de quitt modifiable ou en cours
         modif NP le 28/09/2009 0909/0164:
         OU SI Quittance > Quitt et PAS D'AUTRE Avis Echéance avant
         *-----------------------------------------------*/
        if vcCdTerLoc = "00002" then do:
            if viMsQttTmp < viMoisQttMEchu then return.
        end.
        else if viMsQttTmp < viMoisQttModifiable then return.

        if viMsQttTmp > viMoisQttEncours
        and can-find(first equit no-lock 
                     where equit.noloc = viNumeroContrat
                       and equit.noqtt <> viNumeroQuittance
                       and equit.msqtt < viMsQttTmp) then return.
    end.
    else if viMoisQttEncours < integer(string(year(vdaDebutQuittance), "9999" ) + string(month(vdaDebutQuittance), "99" )) then return.

    /* Lecture de la tache indexation loyer pour savoir si le locataire utilise l'indexation automatique Toggle-box dans l'ecran de saisie de l'indexation */
    find last tache no-lock
        where tache.tpcon = vcTypeContrat
          and tache.nocon = viNumeroContrat
          and tache.tptac = {&TYPETACHE-indexationLoyer} no-error.
    if not available tache then return.  
   
    if tache.tphon = "false" or tache.tphon = "no"        /* Si pas d'indexation automatique : on quitte. */
    or tache.dtfin > vdaFinQuittance                      /* Date d'indexation > date de fin quittance.*/
    or dateFinBail(vcTypeContrat, viNumeroContrat, tache.dtfin) /* Recherche de la date de fin du contrat bail ou date de resiliation du contrat. */
    then return.

    /* Recuperation du taux d'indexation. */
    run chgTaux(
        integer(tache.dcreg), 
        integer(tache.cdreg), 
        integer(tache.ntreg), 
        tache.duree, 
        output vdeValeurIndexationLoyer, 
        output vdeTauxIndexationLoyer,
        output vlIndParu
    ).
    /* On ne connait pas le taux pour pour l'indexation locataire indexable non indexe */
    /* SY #9521 FgIndParu pour distinguer un taux calculé à 0 d'un indice non paru */
    if vdeTauxIndexationLoyer = 0 and not vlIndParu then do:
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.tpcon = tache.tpcon 
            ttTache.nocon = tache.nocon
            ttTache.tptac = tache.tptac
            ttTache.notac = tache.notac 
            ttTache.utreg = "1"
            ttTache.CRUD  = "U"
            ttTache.rRowid      = rowid(tache)
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ghProc              = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm)
        .
        run settache in ghProc(table ttTache by-reference).
        return.
    end.
    /* Indexation a effectuer */
    poCollectionQuittance:set("cIndexationLoyer", "01").

end procedure.
