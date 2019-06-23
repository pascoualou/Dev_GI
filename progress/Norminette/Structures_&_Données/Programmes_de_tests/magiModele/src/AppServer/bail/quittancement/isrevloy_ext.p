/*------------------------------------------------------------------------
    File        : isrevloy_ext.p
    Purpose     : 
    Description : 
    Author(s)   : KANTENA - 2018/01/04
    Created     : 
    Notes       : reprise de isrevloy_ext.p
  ----------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/referenceClient.i}

using parametre.pclie.parametrageProlongationExpiration. // lié a filtrelo.i
using parametre.pclie.parametrageFournisseurLoyer.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/equit.i &nomtable=ttqtt}
{tache/include/tache.i}

{bail/include/filtreLo.i}          /* Include pour Filtrage locataire à prendre */
{bail/include/isgesflo.i}


function dateFinBail returns logical private (pcTypeBail as character, piNumeroRole as integer, pdaProchaineRevision as date):
    /*-------------------------------------------------------------------
    Purpose: Procedure de recherche date fin bail ou date resiliation contrat.
    Notes:
  ----------------------------------------------------------------------*/
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeBail
           and ctrat.nocon = piNumeroRole no-error.
    if available ctrat then do:
        /* Date de resiliation du contrat bail. */
        if ctrat.dtree <> ? and ctrat.dtree < pdaProchaineRevision 
        then return true. /* pas de revision */

        /* Si pas Tacite reconduction : tester Expiration */
        if ctrat.TpRen <> "00001" 
        then do:
            /*--> Uniquement si module prolongation apres expiration non ouvert */
            find first pclie no-lock 
                 where pclie.tppar = "FGEXP" no-error.
            if not available pclie or pclie.zon01 = "00002" 
            then do:
                /*--> Date de fin du contrat bail */
                if ctrat.dtfin < pdaProchaineRevision 
                then return true.    /* pas de revision */
            end.
        end.
    end.
    else return true.    /* pas de revision */

end function.

procedure tauxRevision private :
    /*-------------------------------------------------------------------
    Purpose: Procedure de recuperation du taux de revision. 
    Notes:
  ----------------------------------------------------------------------*/
    define input  parameter piTypeIndiceCou         as character no-undo.
    define input  parameter piAnneeCou              as integer   no-undo.
    define input  parameter piNumeroPeriodeCou      as integer   no-undo.
    define input  parameter piNombrePeriodeRevision as integer   no-undo.
    define output parameter pdValeurRevision        as decimal   no-undo.
    define output parameter pdTauxRevision          as decimal   no-undo.

    define variable vhProcIndrv  as handle no-undo.
    define variable poCollection as class collection no-undo.

    run adblib/indiceRevision_CRUD.p persistent set vhProcIndrv.
    run getTokenInstance in vhProcIndrv(mToken:JSessionId).

    if piNombrePeriodeRevision = 1 
    then run readIndiceRevision2 in vhProcIndrv (piTypeIndiceCou,  /* Type d'indice              */
                                         piAnneeCou,               /* Annee de reference         */
                                         piNumeroPeriodeCou,       /* Numero de periode          */
                                         piNombrePeriodeRevision,  /* Periodicite revision loyer */
                                         output poCollection)
        .
    else run readIndiceRevision3 in vhProcIndrv (piTypeIndiceCou,              /* Type d'indice              */
                                         piAnneeCou + piNombrePeriodeRevision, /* Annee de reference         */
                                         piNumeroPeriodeCou,                   /* Numero de perdiode         */
                                         piNombrePeriodeRevision,              /* Periodicite revision loyer */
                                         output poCollection).
    if poCollection:getLogical("lTrouve") 
    then assign
        pdValeurRevision = poCollection:getDecimal("dValeurRevision")
        pdTauxRevision   = poCollection:getDecimal("dTauxRevision")
    .
    if valid-handle(vhProcIndrv) then run destroy in vhProcIndrv.

end procedure.

procedure isrevloy:
    /*-------------------------------------------------------------------
    Purpose: isrevloy 
    Notes:
  ----------------------------------------------------------------------*/
    define input  parameter pcTypeBail             as character no-undo.
    define input  parameter piNumeroRole           as integer   no-undo.
    define input  parameter piNumeroQuittance      as integer   no-undo.
    define input  parameter pdaDebutPeriode        as date      no-undo.
    define input  parameter pdaFinPeriode          as date      no-undo.
    define input  parameter pdaDebutQuittance      as date      no-undo.
    define input  parameter pdaFinQuittance        as date      no-undo.
    define input  parameter GlMoiMdf               as integer   no-undo.
    define input  parameter GlMoiMec               as integer   no-undo.
    define input  parameter GlMoiQtt               as integer   no-undo.
    define input  parameter GlMflMdf               as integer   no-undo.
    define input  parameter GlMflQtt               as integer   no-undo.
    define input  parameter GlDevUse               as character no-undo.
    define input  parameter GlDevRef               as character no-undo.
    define output parameter vlARevis               as character no-undo.
    define output parameter vlRevisionEvenementiel as logical   no-undo.

    define variable FgRevConventionnelle    as character no-undo.
    define variable vdaProchaineRevision    as date      no-undo.
    define variable viTypeIndiceCou         as integer   no-undo.
    define variable viAnneeCou              as integer   no-undo.
    define variable viNumeroPeriodeCou      as integer   no-undo.
    define variable viNombrePeriodeRevision as integer   no-undo.
    define variable dTauxRevisionLoyer      as decimal   no-undo.
    define variable dValeurRevisionLoyer    as decimal   no-undo.
    define variable vlFournisseurLoyer      as logical   no-undo.
    define variable vlBailFournisseurLoyer  as logical   no-undo.
    define variable viMsQttTmp              as integer   no-undo.
    define variable vlTaciteReconduction    as logical   no-undo.
    define variable vdaFinBail              as date      no-undo.
    define variable vdaSortieLocataire      as date      no-undo.
    define variable vdaResiliationBail      as date      no-undo.
    define variable viMoisQttMEchu          as integer   no-undo.
    define variable viMoisQttModifiable     as integer   no-undo.
    define variable viMoisQttEncours        as integer   no-undo.
    define variable oFournisseurLoyer       as class parametrageFournisseurLoyer no-undo.
    define variable vcCodeModele            as character no-undo.
    define variable viNumeroFourLoyerDebut  as integer   no-undo.
    define variable viNumeroFourLoyerFin    as integer   no-undo.
    define variable viNombreMoisGesfl       as integer   no-undo.

    define variable CdTerLoc   as character no-undo.

    /* VARIABLE pour FiltreLo.i */
    define variable vlPrendre         as logical   no-undo.

    define buffer m_ctrat for ctrat.

    /* Tests des dates de debut de quittance et de quittancement et des dates de fin de quittance et de quittancement */
    if (pdaDebutQuittance < pdaDebutPeriode) 
    or (pdaFinQuittance > pdaFinPeriode)
    or (pdaFinPeriode < pdaDebutPeriode) 
    then return.

    /* Recuperation du parametre GESFL */
    oFournisseurLoyer = new parametrageFournisseurLoyer().
    assign
        vcCodeModele           = oFournisseurLoyer:getCodeModele()
        viNumeroFourLoyerDebut = oFournisseurLoyer:getFournisseurLoyerDebut()
        viNumeroFourLoyerFin   = oFournisseurLoyer:getFournisseurLoyerFin()
        viNombreMoisGesfl      = oFournisseurLoyer:getNombreMoisQuittance()
    .
    delete object oFournisseurLoyer.

    vlBailFournisseurLoyer = no.
    find first m_ctrat no-lock
         where m_ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and m_ctrat.nocon = integer(truncate(piNumeroRole / 100000, 0)) no-error.
    if lookup(m_ctrat.ntcon, "03075,03093") > 0 then vlBailFournisseurLoyer = true.

    /* Filtre (= Qtt locataire … prendre ?) */
    run filtreLoc (pdaDebutPeriode, piNumeroRole, output vlTaciteReconduction, output vdaFinBail, output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre).
    if not vlPrendre then return.
  
    /* Init mois modifiable du locataire */
    assign
        viMoisQttModifiable = GlMoiMdf
        viMoisQttMEchu      = GlMoiMec
        viMoisQttEncours    = GlMoiQtt
    .
    if vlFournisseurLoyer 
    and vlBailFournisseurLoyer
    then assign
        viMoisQttModifiable = GlMflMdf
        viMoisQttMEchu      = viMoisQttModifiable
        viMoisQttEncours    = GlMflQtt
    .
    find first ttQtt no-lock
         where ttQtt.NoLoc = piNumeroRole
           and ttQtt.NoQtt = piNumeroQuittance no-error.
    if available ttQtt 
    then assign
        CdTerLoc   = ttQtt.cdter
        viMsQttTmp = ttQtt.msqtt
    .
    else for first equit no-lock
         where equit.NoLoc = piNumeroRole
           and equit.NoQtt = piNumeroQuittance:
        assign
            CdTerLoc   = equit.cdter
            viMsQttTmp = equit.msqtt
        .
    end.
    if viMsQttTmp <> 0 then do:
        /*-----------------------------------------------*
         | On ne peut reviser que dans le mois de quitt  |
         | modifiable ou en cours                        |
         | modif SY le 18/01/2008 :                      |
         | OU SI Quittance > Quitt                       |
         |    et PAS D'AUTRE Avis Echéance avant         |
         *-----------------------------------------------*/
        if CdTerLoc = "00002" then do:
            if viMsQttTmp < viMoisQttMEchu then return.
        end.
        else do:
            if viMsQttTmp < viMoisQttModifiable then return.
        end.
        if viMsQttTmp > viMoisQttEncours then do:
            if can-find (first equit 
                         where equit.noloc = piNumeroRole
                           and equit.noqtt <> piNumeroQuittance
                           and equit.msqtt < viMsQttTmp) 
            then return.
        end.
    end.
    else if viMoisQttEncours < integer(string(year(pdaDebutQuittance), "9999" ) + string(month(pdaDebutQuittance), "99" )) then return.

    /* Lecture de la tache revision loyer pour savoir si le locataire est en traitement manuel. */
    run getTacheRevision(pcTypeBail, piNumeroRole, output table ttTache by-reference).
    if not available ttTache then return.

    /* Si pas de révision conventionnelle : on quitte. */
    if not ttTache.fgrev then return.
        
    /* Si révision manuelle : on quitte. */
    if logical(ttTache.tphon) then return.

    /* Date de revision > date de fin quittance.*/
    if vdaProchaineRevision > pdaFinQuittance then return.

    /* Recherche de la date de fin du contrat bail ou date de resiliation du contrat. */
    if dateFinBail(pcTypeBail, piNumeroRole, ttTache.dtfin) then return.

    /* Si devise encours <> de devise Cabinet pas de revision possible */
    if GlDevUse <> GlDevRef then return.

    /* Ajout SY le 29/09/2006 : Si on a préparé cette révision dans l'événementiel */
    /* il ne faut plus réviser en automatique                                      */
    vlRevisionEvenementiel = no.
    for each trait no-lock
        where trait.cdtrt = "26005"
          and trait.noact = 0
       , each suivi no-lock
        where suivi.notrt  = trait.notrt 
          and suivi.tpidt  = {&TYPEROLE-locataire}
          and suivi.noidt  = piNumeroRole
          and suivi.lbdiv2 = "TRUE":

        if date(suivi.lbdiv) <> ? and date(suivi.lbdiv) = vdaProchaineRevision
        then do:
            vlRevisionEvenementiel = yes.
            leave.
        end.
    end.
    if vlRevisionEvenementiel = yes then return.

    /* Recuperation du taux de revision. */
    assign
        viTypeIndiceCou         = integer(ttTache.dcreg)
        viAnneeCou              = integer(ttTache.cdreg)
        viNumeroPeriodeCou      = integer(ttTache.ntreg)
        viNombrePeriodeRevision = ttTache.duree
    .
    run tauxRevision(viTypeIndiceCou, 
                     viAnneeCou, 
                     viNumeroPeriodeCou, 
                     viNombrePeriodeRevision, 
                     output dValeurRevisionLoyer, 
                     output dTauxRevisionLoyer).

    /* On ne connait pas le taux pour la revision locataire revisable non revise */
    if dTauxRevisionLoyer = 0 then do:

        run updateTacheRevision("1","",""). /* Mise a jour de la tache.*/

        /* Mise a jour de la quittance */
        find first ttQtt
             where ttQtt.NoLoc = piNumeroRole
               and ttQtt.NoQtt = piNumeroQuittance no-error.
        if available ttQtt 
        then assign 
            ttQtt.cdrev = "00001"
            ttQtt.cdmaj = 1
        .
        assign vlARevis = "00".
        return.
    end.
    /* Revision a effectuer */
    assign vlARevis = "01".

end procedure.

procedure getTacheRevision:
    /*-------------------------------------------------------------------
    Purpose: Procedure de lecture de la tache revision loyer.
    Notes:
  ----------------------------------------------------------------------*/
    define input parameter pcTypeBail   as character no-undo.
    define input parameter piNumeroRole as integer   no-undo.
    define variable vhProcTache as handle no-undo.
    
    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).

    run getTache in vhProcTache(pcTypeBail, piNumeroRole, {&TYPETACHE-revision}, table ttTache by-reference).
    if valid-handle(vhProcTache) then run destroy in vhProcTache.

end procedure.

procedure updateTacheRevision:
    /*-------------------------------------------------------------------
    Purpose: Procedure de mise a jour de la table tache (Revision loyer).
    Notes:
  ----------------------------------------------------------------------*/
    define input parameter piNumeroInterneTache    as integer   no-undo.
    define input parameter pcLocataireRevision     as character no-undo.
    define input parameter pcNouvelleDateRevision  as character no-undo.
    define input parameter pcProchaineDateRevision as character no-undo.

    define variable vhProcTache as handle no-undo.

    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).

    run ma2Tache in vhProcTache(piNumeroInterneTache, pcLocataireRevision, pcNouvelleDateRevision, pcProchaineDateRevision).
    if valid-handle(vhProcTache) then run destroy in vhProcTache.

end procedure.


