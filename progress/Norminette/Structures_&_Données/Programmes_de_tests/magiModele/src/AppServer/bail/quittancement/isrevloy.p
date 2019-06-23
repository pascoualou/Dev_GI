/*------------------------------------------------------------------------
File        : isrevloy.p
Purpose     : 
Author(s)   : KANTENA - 2018/01/04
Notes       : reprise de isrevloy_ext.p
derniere revue: 2018/08/14 - phm: KO
        traiter les todo
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/referenceClient.i}

using parametre.pclie.parametrageProlongationExpiration. // lié a filtrelo.i

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/tbtmpqtt.i}
{tache/include/tache.i}

{bail/include/filtreLo.i}                            // Filtrage locataire à prendre, procedure filtreLoc
{outils/include/lancementProgramme.i}                // fonctions lancementPgm, suppressionPgmPersistent
{bail/quittancement/procedureCommuneQuittance2.i}    // fonction dateFinBail, procédure chgTaux

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghProc as handle no-undo.


procedure lancementIsrevloy:
    /*-------------------------------------------------------------------
    Purpose: 
    Notes:   service externe
  ----------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input-output parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.  

    goCollectionHandlePgm = new collection().
    poCollectionQuittance:set("cRevision", "00").
    run isrevloy (poCollectionContrat, input-output poCollectionQuittance).
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure isrevloy private:
    /*-------------------------------------------------------------------
    Purpose: isrevloy 
    Notes:
    ----------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input-output parameter poCollectionQuittance as class collection no-undo.

    define variable vcTypeContrat             as character no-undo.
    define variable viNumeroContrat           as integer   no-undo.
    define variable viNumeroQuittance         as integer   no-undo.
    define variable vdaDebutPeriode           as date      no-undo.
    define variable vdaFinPeriode             as date      no-undo.
    define variable vdaDebutQuittance         as date      no-undo.
    define variable vdaFinQuittance           as date      no-undo.  
    define variable vlBailFournisseurLoyer    as logical   no-undo.
    define variable vlRevisionEvenementiel    as logical   no-undo.    
    define variable GlDevUse                  as character no-undo.    //gga todo a revoir
    define variable GlDevRef                  as character no-undo.    //gga todo a revoir 
    define variable vdTauxRevisionLoyer       as decimal   no-undo.
    define variable vdValeurRevisionLoyer     as decimal   no-undo.
    define variable vlIndParu                 as logical   no-undo.
    define variable viMsQttTmp                as integer   no-undo.
    define variable vlTaciteReconduction      as logical   no-undo.
    define variable vdaFinBail                as date      no-undo.
    define variable vdaSortieLocataire        as date      no-undo.
    define variable vdaResiliationBail        as date      no-undo.
    define variable vdaFinApplicationRubrique as date no-undo.
    define variable viMoisQttMEchu            as integer   no-undo.
    define variable viMoisQttModifiable       as integer   no-undo.
    define variable viMoisQttEncours          as integer   no-undo.
    define variable vcCdTerLoc                as character no-undo.
    define variable vlPrendre                 as logical   no-undo.

    define buffer trait for trait.
    define buffer equit for equit.
    define buffer tache for tache.
    define buffer suivi for suivi.

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
    or vdaFinPeriode < vdaDebutPeriode 
    then return.

    /* Filtre (= Qtt locataire … prendre ?) */
    run filtreLoc (vdaDebutPeriode, viNumeroContrat, output vlTaciteReconduction, output vdaFinBail, output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre, output vdaFinApplicationRubrique).
    if not vlPrendre then return.
 
    //les infos mois modifiable, encours et echu sont renseignees en fonction du type bail fournisseur loyer dans le pgm de plus haut niveau       
    assign 
        viMoisQttModifiable = poCollectionContrat:getInteger("iMoisModifiable")  
        viMoisQttEncours    = poCollectionContrat:getInteger("iMoisQuittancement")   
        viMoisQttMEchu      = if vlBailFournisseurLoyer
                              then viMoisQttModifiable else poCollectionContrat:getInteger("iMoisEchu")
    .
    find first ttQtt
         where ttQtt.iNumeroLocataire = viNumeroContrat
           and ttQtt.iNoQuittance = viNumeroQuittance no-error.
    if available ttQtt 
    then assign
        vcCdTerLoc = ttQtt.cCodeTerme
        viMsQttTmp = ttQtt.iMoisTraitementQuitt
    .
    else for first equit no-lock
         where equit.NoLoc = viNumeroContrat
           and equit.NoQtt = viNumeroQuittance:
        assign
            vcCdTerLoc   = equit.cdter
            viMsQttTmp = equit.msqtt
        .
    end.
    if viMsQttTmp <> 0 then do:
        /*-----------------------------------------------*
         On ne peut reviser que dans le mois de quitt modifiable ou en cours
         modif SY le 18/01/2008:
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

    /* Lecture de la tache revision loyer pour savoir si le locataire est en traitement manuel. */
    find last tache no-lock
        where tache.tpcon = vcTypeContrat
          and tache.nocon = viNumeroContrat
          and tache.tptac = {&TYPETACHE-revision} no-error.
    if not available tache
    or not tache.fgidxconv                                  /* Si pas de révision conventionnelle : on quitte. */ 
    or tache.tphon = "true" or tache.tphon = "yes"          /* Si révision manuelle : on quitte. */
    or tache.dtfin > vdaFinQuittance                        /* Date de revision > date de fin quittance.*/
    or dateFinBail(vcTypeContrat, viNumeroContrat, tache.dtfin)   /* Recherche de la date de fin du contrat bail ou date de resiliation du contrat. */
    or GlDevUse <> GlDevRef                                 /* Si devise encours <> de devise Cabinet pas de revision possible */
    then return.

    /* Ajout SY le 29/09/2006: Si on a préparé cette révision dans l'événementiel il ne faut plus réviser en automatique */
    vlRevisionEvenementiel = no.
    for each trait no-lock
        where trait.cdtrt = "26005"
          and trait.noact = 0
      , each suivi no-lock
        where suivi.notrt  = trait.notrt 
          and suivi.tpidt  = {&TYPEROLE-locataire}
          and suivi.noidt  = viNumeroContrat
          and suivi.lbdiv2 = "TRUE":
        if date(suivi.lbdiv) <> ? and date(suivi.lbdiv) = tache.dtfin then do:
            vlRevisionEvenementiel = yes.
            leave.
        end.
    end.
    if vlRevisionEvenementiel then return.

    /* Recuperation du taux de revision. */
    run chgTaux(
        integer(tache.dcreg), 
        integer(tache.cdreg), 
        integer(tache.ntreg), 
        tache.duree, 
        output vdValeurRevisionLoyer, 
        output vdTauxRevisionLoyer,
        output vlIndParu
    ).
    /* On ne connait pas le taux pour la revision locataire revisable non revise */
    if vdTauxRevisionLoyer = 0 and not vlIndParu then do:
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.tpcon = tache.tpcon 
            ttTache.nocon = tache.nocon
            ttTache.tptac = tache.tptac
            ttTache.notac = tache.notac 
            ttTache.utreg = "1"
            ttTache.CRUD        = "U"
            ttTache.rRowid      = rowid(tache)
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ghProc              = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm)
        .
        run settache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.

        /* Mise a jour de la quittance */
        for first ttQtt
            where ttQtt.iNumeroLocataire = viNumeroContrat
              and ttQtt.iNoQuittance = viNumeroQuittance:
            assign 
                ttQtt.cCodeRevisionDeLaQuittance = "00001"
                ttQtt.cdmaj = 1
            .
        end.
        return.
    end.
    /* Revision a effectuer */
    poCollectionQuittance:set("cRevision", "01").
end procedure.
