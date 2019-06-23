/*------------------------------------------------------------------------
File        : tacheRevisionLoyer.p
Purpose     : Tâche Révision Loyer dans bail
Author(s)   : npo - 2017/11/29
Notes       : à partir de adb\src\tache\prmobrev.p + \tache\hisbxrev.p
derniere revue: 2018/05/04 - phm: KO
        traiter les todo
------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
{preprocesseur/categorie2bail.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageDefautBail.
using parametre.pclie.parametrageRelocation.
using parametre.pclie.parametrageCalendrierLoyer.
using parametre.syspr.syspr.
using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/cttac.i}
{bail/include/equit.i &nomtable=ttQtt}
{bail/include/tmprub.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{application/include/error.i}
{tache/include/tacheRevisionLoyer.i}
{bail/include/outilBail.i}      // fonction isBailCommercial
{tache/include/tache.i}

function tacheObligatoire returns logical private (piNumeroContrat as integer, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:  determine si tache obligatoire
    Notes  :
    TODO  A SUPPRIMER  fonction pas appelée.
    ------------------------------------------------------------------------------*/
    define variable vlTachObl        as logical no-undo.
    define variable vhProcOutilTache as handle  no-undo.

    run tache/outilsTache.p persistent set vhProcOutilTache.
    run getTokenInstance in vhProcOutilTache(mToken:JSessionId).
    run detTacObl in vhProcOutilTache(piNumeroContrat, pcTypeContrat, {&TYPETACHE-revision}, output vlTachObl).
    run destroy in vhProcOutilTache.
    return vlTachObl.

end function.

function isBailSoumisRevisionTriennale returns logical private (pcNatureBail as character):
    /*------------------------------------------------------------------------------
    Purpose:  determine si bail soumis à révision triennale (et autres traitement de révision)
    Notes  :
    ------------------------------------------------------------------------------*/
    return can-find(first sys_pg no-lock 
                    where sys_pg.tppar = "O_RVT"
                      and sys_pg.zone2 = pcNatureBail).
end function.

function isTraitementsRevisionIdentiques returns logical private(buffer revtrt for revtrt):
    /*------------------------------------------------------------------------------
    Purpose: determine si les Traitements de Revision ont été modifiés ou non
    Notes  : TODO - pas tres joli. pas moyen de faire à la mode isUpdated (label du champs) ????
    ------------------------------------------------------------------------------*/
    return not (revtrt.inotrtrev <> ttHistoriqueRevisionLoyer.iNumeroTraitementRevision
             or revtrt.tpcon     <> ttHistoriqueRevisionLoyer.cTypeContrat
             or revtrt.nocon     <> ttHistoriqueRevisionLoyer.iNumeroContrat 
             or revtrt.cdtrt     <> ttHistoriqueRevisionLoyer.cCodeTraitement
             or revtrt.notrt     <> ttHistoriqueRevisionLoyer.iNumeroTraitement  
             or revtrt.cdact     <> ttHistoriqueRevisionLoyer.cCodeAction    
             or revtrt.dtdeb     <> ttHistoriqueRevisionLoyer.daDateReference    
             or revtrt.dtfin     <> ttHistoriqueRevisionLoyer.daDateAction   
             or revtrt.lbcom     <> ttHistoriqueRevisionLoyer.cLibelleCommentaires   
             or revtrt.mtloyann  <> ttHistoriqueRevisionLoyer.dMontantAnnuel 
             or revtrt.fgloyref  <> ttHistoriqueRevisionLoyer.lLoyerReference    
             or revtrt.msqtt     <> ttHistoriqueRevisionLoyer.iPeriodeQuittancement  
             or revtrt.cdirv     <> ttHistoriqueRevisionLoyer.iCodeIndiceRevision    
             or revtrt.anirv     <> ttHistoriqueRevisionLoyer.iAnneeIndice   
             or revtrt.noirv     <> ttHistoriqueRevisionLoyer.iNumeroPeriodAnnee 
             or revtrt.vlirv     <> ttHistoriqueRevisionLoyer.dValeurIndice
             or revtrt.tprol     <> ttHistoriqueRevisionLoyer.cTypeRoleDemandeur 
             or revtrt.norol     <> ttHistoriqueRevisionLoyer.iNumeroRoleDemandeur
             or revtrt.fghis     <> ttHistoriqueRevisionLoyer.lTraitementHistorise
             or revtrt.dthis     <> ttHistoriqueRevisionLoyer.daTermineLe
             or revtrt.usrhis    <> ttHistoriqueRevisionLoyer.cHistorisePar  
             or revtrt.tphis     <> ttHistoriqueRevisionLoyer.cMotifFin)
    .
end function.

function isNatureCommercial return logical(pcCodeNatureBail as character):
    /*------------------------------------------------------------------------------
    Purpose:  determine les natures de baux Commerciaux
    Notes  :
    ------------------------------------------------------------------------------*/
    return pcCodeNatureBail = {&NATURECONTRAT-usageCommercial1953}
        or pcCodeNatureBail = {&NATURECONTRAT-usageCommercial-2ans}
        or pcCodeNatureBail = {&NATURECONTRAT-usageCommercialAccessoire}
        or pcCodeNatureBail = {&NATURECONTRAT-usageProfessionnel1948}
        or pcCodeNatureBail = {&NATURECONTRAT-usageProfessionnel1986}
        or pcCodeNatureBail = {&NATURECONTRAT-usageProfessionnel1989}
        or pcCodeNatureBail = {&NATURECONTRAT-usageLocationBureau}
        or pcCodeNatureBail = {&NATURECONTRAT-usageEmplacementPublicitaire}
        or pcCodeNatureBail = {&NATURECONTRAT-commercialVacant}.
end function. 

procedure isCalendrierEvolution private:
    /*------------------------------------------------------------------------------
    Purpose: determine si paramétrage calendrier évolution ouvert + return parametrage associé
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcListeNatureBauxAutorises as character        no-undo.
    define output parameter poCollection               as class collection no-undo.

    define variable vcListeNatureBauxAutorises as character no-undo.
    define variable voCalendrierLoyer          as class parametrageCalendrierLoyer no-undo.

    assign
        voCalendrierLoyer = new parametrageCalendrierLoyer()
        poCollection      = new collection()
    .
    if voCalendrierLoyer:isDbParameter then do:
        vcListeNatureBauxAutorises = voCalendrierLoyer:getNaturesBailAutorise().
        if vcListeNatureBauxAutorises = ""
        // Anomalie d'installation. La moulinette 01070373.p n'a pas été passée. Veuillez contacter la Gestion Intégrale
        then mError:createError({&error}, 1000627).
    end.
    else vcListeNatureBauxAutorises = pcListeNatureBauxAutorises.
    poCollection:set("lCalendrierEvolution",      voCalendrierLoyer:isCalendrierEvolution()). 
    poCollection:set("lIndexationParDefaut",      voCalendrierLoyer:isIndexationParDefaut()).
    poCollection:set("lCalendrie1erBailOnly",     voCalendrierLoyer:isSeulementCalendrie1erBail()).
    poCollection:set("cListeNatureBauxAutorises", vcListeNatureBauxAutorises).
    delete object voCalendrierLoyer.

end procedure.

procedure chercheParametres private:
    /*------------------------------------------------------------------------------
    Purpose: recherche tous les paramètres dont a besoin la vue
    Notes  : TODO  creer un plcie "REVBA". creer un pclie "GESIE"
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter poCollection    as class collection no-undo.

    define variable vlDeclenchementRevision       as logical   no-undo.
    define variable vlRevisionAlaBaisse           as logical   no-undo.
    define variable vlGestionSIE                  as logical   no-undo.
    define variable vlFournisseurLoyer            as logical   no-undo.
    define variable vcListeNatureBauxAutorises    as character no-undo.
    define variable vlCalendrierEvolution         as logical   no-undo.
    define variable vlIndexationParDefaut         as logical   no-undo.
    define variable vlCalendrie1erBailOnly        as logical   no-undo.
    define variable vlBailComProf                 as logical   no-undo.
    define variable vlBailSoumisRevisionTriennale as logical   no-undo.
    define variable vlFlagBailFourniLoyer         as logical   no-undo.
    define variable voCollection       as class collection                  no-undo.
    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

    define buffer sys_pg  for sys_pg.
    define buffer pclie   for pclie.
    define buffer ctrat   for ctrat.
    define buffer vbCtrat for ctrat.

    // todo  utiliser parametrage. Recherche param pour déclenchement révision + Révision à la baisse
    find first pclie no-lock
        where pclie.tppar = "REVBA" no-error.
    vlDeclenchementRevision = available pclie and pclie.zon02 = "00001".
    if available pclie
    then vlRevisionAlaBaisse = (pclie.zon01 = "00001").
    else vlRevisionAlaBaisse = true.
    // todo  utiliser parametrage. Recherche Gestion Immobilière d'Entreprise
    find first pclie no-lock
        where pclie.tppar = "GESIE" no-error.
    assign
        vlGestionSIE       = available pclie and pclie.zon01 = "00001"
        // Recuperation du paramètre GESFL
        voFournisseurLoyer = new parametrageFournisseurLoyer()
        vlFournisseurLoyer = voFournisseurLoyer:isGesFournisseurLoyer()
    .
    delete object voFournisseurLoyer.
    /* initialisation liste des nature de baux autorisées pour le calendrier */
    /*      Dauchez : tout sauf MEH et Loi 48                               */
    /*      AGF et autres : Comm (sauf Us. Prof loi 1948) + certains Hab    */
    if mtoken:cRefGerance = "{&REFCLIENT-DAUCHEZGERANCE}"
    then for each sys_pg no-lock
        where sys_pg.tppar = "R_CBA" 
          and sys_pg.zone2 <> {&NATURECONTRAT-usageMixte1948}
          and sys_pg.zone2 <> {&NATURECONTRAT-usageMixteMehaignerie}
          and sys_pg.zone2 <> {&NATURECONTRAT-usageProfessionnel1948}
        by sys_pg.zone2:
        vcListeNatureBauxAutorises = vcListeNatureBauxAutorises + "," + sys_pg.zone2.
    end.
    else do:
        vcListeNatureBauxAutorises = substitute("&1,&2,&3,&4,&5",
                                                {&NATURECONTRAT-bauxRuraux}, {&NATURECONTRAT-contratLocation},
                                                {&NATURECONTRAT-usageMixteDroitCommun}, {&NATURECONTRAT-habitationVacant},
                                                {&NATURECONTRAT-locationIsolee}).
        if mtoken:cRefGerance = "{&REFCLIENT-DESPORT}"
        then vcListeNatureBauxAutorises = substitute("&1,&2", vcListeNatureBauxAutorises, {&NATURECONTRAT-habitationLoyerLibre}). 
    end.
    vcListeNatureBauxAutorises = trim(vcListeNatureBauxAutorises, ",").
    // Calendrier d'évolution
    run isCalendrierEvolution(vcListeNatureBauxAutorises, output voCollection).
    assign
        vlCalendrierEvolution      = (voCollection:getLogical("lCalendrierEvolution") = true)
        vlIndexationParDefaut      = (voCollection:getLogical("lIndexationParDefaut") = true)
        vlCalendrie1erBailOnly     = (voCollection:getLogical("lCalendrie1erBailOnly") = true)
        vcListeNatureBauxAutorises = voCollection:getCharacter("cListeNatureBauxAutorises")
    .
    // On ne peut utiliser le % variation de l'indice que si le bail est commercial
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat 
          and ctrat.nocon = piNumeroContrat:   
        if isBailCommercial(ctrat.ntcon) then assign
            vlBailComProf                 = true
            vlBailSoumisRevisionTriennale = isBailSoumisRevisionTriennale(ctrat.ntcon)
        .
        // Gestion des mandats de location   
        find first vbCtrat no-lock
            where vbCtrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and vbCtrat.nocon = int64(truncate(piNumeroContrat / 100000, 0)) no-error.
        if lookup(vbCtrat.ntcon, substitute("&1,&2", {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatLocationIndivision})) > 0 then vlFlagBailFourniLoyer = yes.
    end.
    poCollection = new collection().
    //Affectation des variables retour
    poCollection:set("lDeclenchementRevision",       vlDeclenchementRevision).
    poCollection:set("lRevisionAlaBaisse",           vlRevisionAlaBaisse).
    poCollection:set("lGestionSIE",                  vlGestionSIE).
    poCollection:set("lFournisseurLoyer",            vlFournisseurLoyer).
    poCollection:set("vcListeNatureBauxAutorises",   vcListeNatureBauxAutorises).
    poCollection:set("lCalendrierEvolution",         vlCalendrierEvolution).
    poCollection:set("lIndexationParDefaut",         vlIndexationParDefaut).
    poCollection:set("lCalendrie1erBailOnly",        vlCalendrie1erBailOnly).
    poCollection:set("lBailComProf",                 vlBailComProf).
    poCollection:set("lBailSoumisRevisionTriennale", vlBailSoumisRevisionTriennale).
    poCollection:set("lFlagBailFourniLoyer",         vlFlagBailFourniLoyer).

end procedure.

procedure getTacheRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheRevisionLoyer.
    define output parameter table for ttHistoriqueRevisionLoyer.

    define variable voCollection         as class collection no-undo.
    define variable vcLibelleCourtIndice as character        no-undo.
    define variable vcLibelleLongIndice  as character        no-undo.
    define variable vhProcIndiceCRUD     as handle           no-undo.

    define buffer tache for tache.
    define buffer lsirv for lsirv.

    // Ajout SY le 04/11/2010 : suite au passage en "Direct" de la tache, report des traitements spécifiques de synbxrev.p
    // 0008 | 15/10/2003 | SY : Fiche 0603/0083 : ajout recalcul/maj des quittances afin de prendre en compte une éventuelle révision à effectuer
    run reCalculQuittances(piNumeroContrat, pcTypeContrat).
    // Recherche de tous les paramètres d'initialisation
    run chercheParametres(piNumeroContrat, pcTypeContrat, output voCollection).
    // Recuperation des infos de la table
    find last tache no-lock
        where tache.TpCon = pcTypeContrat 
          and tache.nocon = piNumeroContrat
          and integer(tache.tptac) = integer({&TYPETACHE-revision}) no-error.
    if available tache then do:
        create ttTacheRevisionLoyer.
        assign
            ttTacheRevisionLoyer.CRUD                            = 'R'
            ttTacheRevisionLoyer.cCodeUnitePerioIndexation       = tache.utreg
            ttTacheRevisionLoyer.cTypeContrat                    = pcTypeContrat
            ttTacheRevisionLoyer.iNumeroContrat                  = piNumeroContrat
            ttTacheRevisionLoyer.cTypeTache                      = tache.tptac
            ttTacheRevisionLoyer.iChronoTache                    = tache.noita
            ttTacheRevisionLoyer.iNumeroTache                    = tache.notac
            ttTacheRevisionLoyer.daDebutPeriodeRevision          = tache.dtdeb
            ttTacheRevisionLoyer.daProchaineRevision             = tache.dtfin
            //ttTacheRevisionLoyer.daFinBail                       = tache.dtfin    // date de fin de bail nath
            ttTacheRevisionLoyer.iPeriodiciteIndexation          = tache.duree
            ttTacheRevisionLoyer.cCodeUnitePerioIndexation       = tache.pdreg
            ttTacheRevisionLoyer.cLibelleUnitePerioIndexation    = outilTraduction:getLibelleParam("UTPER", ttTacheRevisionLoyer.cCodeUnitePerioIndexation)
            ttTacheRevisionLoyer.cCodeMotifFin                   = tache.tpfin
            //ttTacheRevisionLoyer.cCodeDateProchaineIndexation    = tache.tpfin
            //ttTacheRevisionLoyer.cCodeDateFinBail                = tache.tpfin
            ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceDeBase  = tache.ntges
            ttTacheRevisionLoyer.cCodeTypeIndiceDeBase           = tache.tpges
            ttTacheRevisionLoyer.cCodeAnneeIndiceDeBase          = tache.pdges
            ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant = tache.ntreg
            ttTacheRevisionLoyer.cCodeTypeIndiceCourant          = tache.dcreg
            ttTacheRevisionLoyer.cCodeAnneeIndiceCourant         = tache.cdreg
            ttTacheRevisionLoyer.daDateReelleTraitementRevision  = tache.dtreg
            ttTacheRevisionLoyer.dMontantLoyerEncours            = tache.mtreg
            ttTacheRevisionLoyer.cCodeEtatRevision               = tache.utreg                             
            ttTacheRevisionLoyer.cCodeFlagIndexationManuelle     = tache.tphon
            ttTacheRevisionLoyer.cCodeFlagIndexationAutomatique  = tache.tphon
            ttTacheRevisionLoyer.cLibelleMotifRevisionManuelle   = tache.lbmotif
            ttTacheRevisionLoyer.lRevisionConventionnelle        = tache.fgidxconv
            ttTacheRevisionLoyer.cLibelleRevConventionnelle      = outilTraduction:getLibelleParam("CDA_S", if tache.fgidxconv then "00001" else "00002")
            ttTacheRevisionLoyer.cCodeModeCalcul                 = tache.cdhon
            ttTacheRevisionLoyer.cLibelleModeCalcul              = outilTraduction:getLibelleParam("TPCAL", tache.cdhon)
            ttTacheRevisionLoyer.cListeHistoriqueIndices         = tache.lbdiv
            ttTacheRevisionLoyer.cMoisQuittContratRevise         = tache.lbdiv2
        .
        run adblib/quittancement/indiceRevision_CRUD.p persistent set vhProcIndiceCRUD.
        run getTokenInstance in vhProcIndiceCRUD(mToken:JSessionId).
        run getLibelleIndice in vhProcIndiceCRUD(ttTacheRevisionLoyer.cCodeTypeIndiceDeBase, ttTacheRevisionLoyer.cCodeAnneeIndiceDeBase, ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceDeBase, "l", output vcLibelleLongIndice).
        ttTacheRevisionLoyer.cLibelleIndiceDeBase = vcLibelleLongIndice.
        run getLibelleIndice in vhProcIndiceCRUD(ttTacheRevisionLoyer.cCodeTypeIndiceCourant, ttTacheRevisionLoyer.cCodeAnneeIndiceCourant, ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant, "l", output vcLibelleLongIndice).
        ttTacheRevisionLoyer.cLibelleIndiceCourant = vcLibelleLongIndice.

        for last lsirv no-lock
            where lsirv.cdirv = integer(ttTacheRevisionLoyer.cCodeTypeIndiceCourant):
            ttTacheRevisionLoyer.cLibelleTypeIndiceCourant = lsirv.lblng.
        end.
        // Révision à la baisse + pourcentage de variation
        if num-entries(tache.lbdiv, '&') >= 3 then do:
            assign
                ttTacheRevisionLoyer.cCodeIndexationAlaBaisse    = entry(1, entry(3, tache.lbdiv, "&"), "#")
                ttTacheRevisionLoyer.cLibelleIndexationAlaBaisse = outilTraduction:getLibelleParam("CDOUI", ttTacheRevisionLoyer.cCodeIndexationAlaBaisse)
            .
            if num-entries(entry(3, tache.lbdiv, "&"), "#") >= 2
            then ttTacheRevisionLoyer.cPourcentageVariation = entry(2, entry(3, tache.lbdiv, "&"), "#").
        end.
    end.
    // Locataire révisable non révisé
    if today >= ttTacheRevisionLoyer.daProchaineRevision then do:            
        if not can-find(first indrv no-lock
                        where indrv.cdirv = integer(ttTacheRevisionLoyer.cCodeTypeIndiceCourant) 
                          and indrv.anper = integer(ttTacheRevisionLoyer.cCodeAnneeIndiceCourant) + ttTacheRevisionLoyer.iPeriodiciteIndexation
                          and indrv.noper = integer(ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant))
        then do:
            run getLibelleIndice in vhProcIndiceCRUD(
                integer(ttTacheRevisionLoyer.cCodeTypeIndiceCourant),
                integer(ttTacheRevisionLoyer.cCodeAnneeIndiceCourant) + ttTacheRevisionLoyer.iPeriodiciteIndexation,
                integer(ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant),
                "c",
                output vcLibelleCourtIndice
            ).
            ttTacheRevisionLoyer.cLibelleNextIndiceNonParu = substitute("Indice &1 &2 non paru", ttTacheRevisionLoyer.cLibelleIndiceCourant, vcLibelleCourtIndice).
        end.
    end.

    // Ajout SY le 03/03/2008 : gestion de la tache Indexation 04137
    // Modif SY le 12/05/2008 : Pour les calendriers actifs uniquement
    if ttTacheRevisionLoyer.cCodeFlagIndexationManuelle = string(true)
    then do:
        if ttTacheRevisionLoyer.cCodeModeCalcul >= "00001"
        then do:
            find last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-indexationLoyer} no-error.   
            if available tache then do:
                assign
                    ttTacheRevisionLoyer.cCodeTypeIndiceCourant         = tache.dcreg
                    ttTacheRevisionLoyer.iPeriodiciteIndexation         = tache.duree
                    ttTacheRevisionLoyer.daProchaineRevision            = tache.dtfin
                    ttTacheRevisionLoyer.cCodeFlagIndexationAutomatique = tache.tphon
                .
                run getLibelleIndice in vhProcIndiceCRUD(
                    ttTacheRevisionLoyer.cCodeTypeIndiceCourant,
                    ttTacheRevisionLoyer.cCodeAnneeIndiceCourant, 
                    ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant, 
                    "l", 
                    output vcLibelleLongIndice
                ).
                ttTacheRevisionLoyer.cLibelleIndiceCourant = vcLibelleLongIndice.
                for last lsirv no-lock
                    where lsirv.cdirv = integer(tache.dcreg):
                    ttTacheRevisionLoyer.cLibelleTypeIndiceCourant = lsirv.lblng.
                end.
            end.
        end.
    end.
    if valid-handle(vhProcIndiceCRUD) then run destroy in vhProcIndiceCRUD.
    // Chargement Tableau des historiques
    run historiqueTacheRevisionLoyer(piNumeroContrat, pcTypeContrat, output table ttHistoriqueRevisionLoyer).  

    // Chargement Tableau des fichiers joints Traitements révisions
    // Remplacé par un appel au websevice de la GED

end procedure.

procedure historiqueTacheRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttHistoriqueRevisionLoyer.

    define variable vcLibelleIndice    as character no-undo.
    define variable vcMotCletraitement as character no-undo.
    define variable vdeNombre          as decimal   no-undo.
    define variable vhProcIndice       as handle    no-undo.
    define variable viNombrebActions   as integer   no-undo.

    define buffer revtrt for revtrt.
    define buffer tache  for tache.
    define buffer sys_pr for sys_pr.
    define buffer vbttHistoriqueRevisionLoyer for ttHistoriqueRevisionLoyer.

    run bail/quittancement/indiceRevision.p persistent set vhProcIndice.
    run getTokenInstance in vhProcIndice(mToken:JSessionId).

    empty temp-table ttHistoriqueRevisionLoyer.
boucleRevtrt:
    for each revtrt no-lock
        where revtrt.tpcon = pcTypeContrat
          and revtrt.nocon = piNumeroContrat:
        find last tache no-lock
            where tache.tpcon  = revtrt.tpcon
              and tache.nocon  = revtrt.nocon
              and tache.tptac  = {&TYPETACHE-revision}
              and tache.notac  = revtrt.notrt no-error.   // No ordre traitement   
        if not available tache then next boucleRevtrt.

        create ttHistoriqueRevisionLoyer.
        assign
            ttHistoriqueRevisionLoyer.cTypeContrat                 = tache.tpcon
            ttHistoriqueRevisionLoyer.iNumeroContrat               = tache.nocon
            ttHistoriqueRevisionLoyer.iNumeroTache                 = tache.noita
            ttHistoriqueRevisionLoyer.iNumeroTraitement            = revtrt.notrt
            ttHistoriqueRevisionLoyer.iNumeroTraitementTemp        = revtrt.notrt
            //ttHistoriqueRevisionLoyer.cNumeroTraitement            = string(revtrt.notrt)
            ttHistoriqueRevisionLoyer.cCodeTraitement              = revtrt.cdtrt
            ttHistoriqueRevisionLoyer.iNumeroTraitementRevision    = revtrt.inotrtrev
            ttHistoriqueRevisionLoyer.iNumeroTraitementRevisiontmp = revtrt.inotrtrev
            ttHistoriqueRevisionLoyer.cCodeAction                  = revtrt.cdact
            ttHistoriqueRevisionLoyer.iPeriodeQuittancement        = revtrt.msqtt
            ttHistoriqueRevisionLoyer.iMoisQuittancement           = revtrt.msqtt modulo 100
            ttHistoriqueRevisionLoyer.iAnneeQuittancement          = int64(truncate(revtrt.msqtt / 100, 0))
            ttHistoriqueRevisionLoyer.dValeurIndice                = revtrt.vlirv
            ttHistoriqueRevisionLoyer.iAnneeIndice                 = revtrt.anirv
            ttHistoriqueRevisionLoyer.iNumeroPeriodAnnee           = revtrt.noirv
            ttHistoriqueRevisionLoyer.daDateReference              = revtrt.dtdeb
            ttHistoriqueRevisionLoyer.daDateAction                 = revtrt.dtfin
            ttHistoriqueRevisionLoyer.dMontantAnnuel               = revtrt.mtloyann
            ttHistoriqueRevisionLoyer.lLoyerReference              = revtrt.fgloyref
            ttHistoriqueRevisionLoyer.cTypeRoleDemandeur           = revtrt.tprol
            ttHistoriqueRevisionLoyer.iNumeroRoleDemandeur         = revtrt.norol
            ttHistoriqueRevisionLoyer.dMontantMensuel              = tache.mtreg
            ttHistoriqueRevisionLoyer.cLibelleCommentaires         = revtrt.lbcom
            ttHistoriqueRevisionLoyer.CRUD                         = 'R'
            vcLibelleIndice = "||"
        .
        if revtrt.cdirv <> 0 then do:
            //run bail/quittancement/indiceRevision.p persistent set vhProcIndice.
            //run getTokenInstance in vhProcIndice(mToken:JSessionId).
            run getLibelleIndice3Lignes in vhProcIndice('INDICE', revtrt.cdirv, string(revtrt.anirv, '9999') + '/' + string(revtrt.noirv), 22, output vcLibelleIndice).
            //run destroy in vhProcIndice.
        end.
        find first sys_pr no-lock 
            where sys_pr.tppar = "RVCTR"
              and sys_pr.cdpar = revtrt.cdtrt no-error.
        if available sys_pr then do:
            assign
                ttHistoriqueRevisionLoyer.lLigneSaisissable = (sys_pr.zone1 = 1)
                vcMotCletraitement = sys_pr.zone2
            .
            find first sys_pr no-lock 
                where sys_pr.tppar = "RVCNA"
                  and sys_pr.zone2 begins substring(vcMotCletraitement, 1, 3, "character") no-error.
            if available sys_pr then ttHistoriqueRevisionLoyer.cLibelleNatureTraitement = outilTraduction:getLibelle(sys_pr.nome1).
        end.
        assign
            ttHistoriqueRevisionLoyer.cLibelletraitement = outilTraduction:getLibelleParam("RVCTR", revtrt.cdtrt)
            ttHistoriqueRevisionLoyer.cLibelleAction     = outilTraduction:getLibelleParam("RVCAC", revtrt.cdact)
            ttHistoriqueRevisionLoyer.cLibelleTypeIndice = entry(1, vcLibelleIndice, "|")                                          // libellé type d'indice (cdirv)
        .
        if num-entries(vcLibelleIndice, "|") >= 2 then ttHistoriqueRevisionLoyer.cLibelleIndice = entry(2, vcLibelleIndice, "|").  // libellé indice (trimestre)    
        if ttHistoriqueRevisionLoyer.cValeurIndice = "0" and num-entries(vcLibelleIndice, "|") >= 3 then ttHistoriqueRevisionLoyer.cValeurIndice = entry(3, vcLibelleIndice, "|").    /* valeur de l'indice */
        if num-entries(vcLibelleIndice, "|") >= 4 then vdeNombre = decimal(entry(4, vcLibelleIndice, "|")).
        if vdeNombre = 0
        then ttHistoriqueRevisionLoyer.cValeurIndice = string(revtrt.vlirv, ">>>>>9").
        else if vdeNombre = 2
             then ttHistoriqueRevisionLoyer.cValeurIndice = string(revtrt.vlirv, ">>>>>9.99").
             else ttHistoriqueRevisionLoyer.cValeurIndice = string(revtrt.vlirv).                     
        if num-entries(vcLibelleIndice, "|") >= 5 then ttHistoriqueRevisionLoyer.cLibelleIndice = entry(5, vcLibelleIndice, "|").  // libellé court

        //if revtrt.msqtt <> 0 then
        //    ttHistoriqueRevisionLoyer.cPeriodeQuittancement = substring(string(revtrt.msqtt, "999999"), 5, 2) + "." + substring(string(revtrt.msqtt, "999999"), 1, 4).

        // traitement des révisions (c.f. RVCTR)             
        if revtrt.cdtrt = "00300" and revtrt.cdact = "00301"
        then assign
            ttHistoriqueRevisionLoyer.cLibelleLoyer = 'Loyer révisé'
            ttHistoriqueRevisionLoyer.iNumeroTache  = revtrt.norol     // no interne tache
            ttHistoriqueRevisionLoyer.cTauxRevision = revtrt.tphis     // taux de la révision
        .
        else ttHistoriqueRevisionLoyer.cLibelleLoyer = (if ttHistoriqueRevisionLoyer.lLoyerReference then 'Loyer de référence' else 'Loyer offert').
    end.
    run destroy in vhProcIndice.

    //Maj du flag 'Action suivante possible'
    /* Action suivante possible ? si ligne loyer de référence => forcément fin de procédure,  pas d'action suivante */
    /* 1) il faut qu'il y ait des actions > possibles */
    /* 2) il faut qu'on soit sur la dernière ligne action de la procédure */
    /* 3) il faut que la procédure soit "en cours" */
    for each ttHistoriqueRevisionLoyer:
        ttHistoriqueRevisionLoyer.lActionSuivante = false.
        if ttHistoriqueRevisionLoyer.lLigneSaisissable and not ttHistoriqueRevisionLoyer.lLoyerReference
        then do:
            run chgListeAction (ttHistoriqueRevisionLoyer.cCodeAction, ttHistoriqueRevisionLoyer.cCodeTraitement, output viNombrebActions).
            if viNombrebActions > 0
            and not can-find(first vbttHistoriqueRevisionLoyer
                             where vbttHistoriqueRevisionLoyer.cTypeContrat         = ttHistoriqueRevisionLoyer.cTypeContrat
                              and vbttHistoriqueRevisionLoyer.iNumeroContrat        = ttHistoriqueRevisionLoyer.iNumeroContrat
                              and vbttHistoriqueRevisionLoyer.cCodeTraitement       = ttHistoriqueRevisionLoyer.cCodeTraitement
                              and vbttHistoriqueRevisionLoyer.iNumeroTraitementTemp = ttHistoriqueRevisionLoyer.iNumeroTraitementTemp
                              and vbttHistoriqueRevisionLoyer.cCodeAction           > ttHistoriqueRevisionLoyer.cCodeAction)
            then ttHistoriqueRevisionLoyer.lActionSuivante = true.
        end.
    end.

end procedure.

procedure chargeListeAction private:
    /*------------------------------------------------------------------------------
    Purpose: charge la liste des actions
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeAction     as character no-undo.
    define input  parameter pcCodeTraitement as character no-undo.
    define output parameter piNombrebActions as integer   no-undo.

    define variable vcCodeTraitMin as character no-undo.
    define variable vcCodeTraitMax as character no-undo.
    define buffer sys_pr for sys_pr.

    empty temp-table ttActionTraitement.
    assign
        vcCodeTraitMin = if pcCodeAction > ""
                         then string(integer(pcCodeAction) + 01, "99999")
                         else string(integer(pcCodeTraitement) + 01, "99999") 
        vcCodeTraitMax = string(integer(pcCodeTraitement) + 99, "99999")
    .
    for each sys_pr no-lock
        where sys_pr.tppar = "RVCAC"
          and sys_pr.cdpar >= vcCodeTraitMin
          and sys_pr.cdpar <= vcCodeTraitMax:         
        create ttActionTraitement.
        assign
            ttActionTraitement.cCodeTraitement    = sys_pr.cdpar
            ttActionTraitement.cLibelleTraitement = outilTraduction:getLibelle(sys_pr.nome2)
            piNombrebActions = piNombrebActions + 1
        .
    end.

end procedure.

procedure initComboTacheRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose: appel programme pour creation combo Indice Révision + Année
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo.
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable viNumeroItem     as integer no-undo.
    define variable vhProcIndice     as handle  no-undo.
    define variable vhProcIndiceCRUD as handle  no-undo.
    define variable voSyspr          as class syspr no-undo.
    //define variable vlCreationCombo as logical no-undo.

    define buffer indrv  for indrv.
    define buffer sys_pg for sys_pg.

    empty temp-table ttCombo.
    // Indexation à la baisse  Oui/Non  CDOUI
    voSyspr = new syspr().
    // Indexation à la baisse  Oui/Non  CDOUI
    voSyspr:getComboParametre("CDOUI", "CMBOUINON",             output table ttcombo by-reference).
    // Indexation conventionnelle  Avec/Sans    CDA_S
    voSyspr:getComboParametre("CDA_S", "CMBINDEXCONVREVISION",  output table ttcombo by-reference).
    // Mode de calcul       TPCAL
    voSyspr:getComboParametre("TPCAL", "CMBMODECALCULREVISION", output table ttCombo by-reference).
    // Nature du traitement RVCNA
    //voSyspr:getComboParametre("RVCNA", "CMBNATURETRMTREVISION", output table ttCombo by-reference).
    // Traitement           RVCTR
    voSyspr:getComboParametre("RVCTR", "CMBTRAITEMENTREVISION", output table ttCombo by-reference).
    // Action           RVCAC
    viNumeroItem = voSyspr:getComboParametre("RVCAC", "CMBACTIONREVISION",     output table ttCombo by-reference).

    // Indice de révision
    run bail/quittancement/indiceRevision.p persistent set vhProcIndice.
    run getTokenInstance in vhProcIndice (mToken:JSessionId).
    run getcomboIndiceRevision in vhProcIndice(viNumeroItem, "l", output table ttcombo by-reference).
    run destroy in vhProcIndice.

    // Autres combo
    for last ttCombo:
        viNumeroItem = ttCombo.iSeqId.
    end.
    // Période de révision
    run adblib/indiceRevision_CRUD.p persistent set vhProcIndiceCRUD.
    run getTokenInstance in vhProcIndiceCRUD(mToken:JSessionId).
    for each indrv no-lock
        by indrv.cdirv by indrv.anper:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBPERIOINDICEREVISION"
            ttCombo.cCode     = substitute("&1-&2", indrv.anper, indrv.noper)
            ttCombo.cParent   = string(indrv.cdirv)
        .
        run getLibelleIndice in vhProcIndiceCRUD(indrv.cdirv, indrv.anper, indrv.noper, "c", output ttCombo.cLibelle).
    end.
    run destroy in vhProcIndiceCRUD.
    // Demandé par
    create ttCombo.
    assign
        viNumeroItem      = viNumeroItem + 1
        ttCombo.iSeqId    = viNumeroItem
        ttCombo.cNomCombo = "CMBDEMANDEPAR"
        ttCombo.cCode     = "00000"
        ttCombo.cLibelle  = "-"
        ttCombo.cParent   = ""
    .
    for each sys_pg no-lock
        where sys_pg.tppar ="O_ROL"
          and lookup(sys_pg.cdpar, "00019,00022") > 0:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBDEMANDEPAR"
            ttCombo.cCode     = sys_pg.cdpar
            ttCombo.cLibelle  = sys_pg.lbpar
            ttCombo.cParent   = ""
        .
    end.

end procedure.

procedure comboParTypeIndiceRevision:
    /*------------------------------------------------------------------------------
    Purpose: Combo par type d'indice de révision
    Notes  : Service Externe beBail.cls
    ------------------------------------------------------------------------------*/
    //define input  parameter piNumeroContrat as int64     no-undo.
    //define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter pcCodeTypeIndiceCourant as character no-undo.
    define output parameter table for ttCombo.

    define variable viNumeroItem     as integer   no-undo.
    define variable vhProcIndiceCRUD as handle    no-undo.
    define buffer indrv for indrv.

    // Indice de révision
    run adblib/indiceRevision_CRUD.p persistent set vhProcIndiceCRUD.
    run getTokenInstance in vhProcIndiceCRUD(mToken:JSessionId).
    // Période de révision
    for each indrv no-lock
        where indrv.cdirv = integer(pcCodeTypeIndiceCourant)    //viCodeIndice 
        by indrv.anper by indrv.noper:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBPERIOINDICEREVISION"
            ttCombo.cCode     = substitute("&1-&2", indrv.anper, indrv.noper)
            ttCombo.cParent   = string(indrv.cdirv)
        .
        run getLibelleIndice in vhProcIndiceCRUD(indrv.cdirv, indrv.anper, indrv.noper, "c", output ttCombo.cLibelle).
    end.
    run destroy in vhProcIndiceCRUD.

end procedure.

procedure comboModeCalcul:
    /*------------------------------------------------------------------------------
    Purpose: Combo Mode de Calcul : dépend de la tache Calendrier Evolution des Loyers
    Notes  : Service Externe beBail.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttCombo.

    define buffer tache for tache.

    define variable voCollection as class collection no-undo.
    define variable voSyspr      as class syspr      no-undo.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("TPCAL", "CMBMODECALCULREVISION", output table ttCombo by-reference).

    // Recherche de tous les paramètres d'initialisation
    run chercheParametres(piNumeroContrat, pcTypeContrat, output voCollection).
    // 12/05/2008 Si option calendrier sur le 1er bail uniquement et calendrier terminé => on ne peut plus réactiver un calendrier
    if voCollection:getLogical('llCalendrie1erBailOnly')
    then for first tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer} 
          and tache.notac = 0:
        // Modif SY le 29/01/2013 : changement critère : utiliser les champs modifiés par fincalev.p
        // tache.tphon = "NO"  : utilisation du calendrier pour calculer le loyer
        // tache.dtreg = date de traitement de la fin du calendrier
        if tache.tphon = "NO" and tache.dtreg <> ?
        then for first ttCombo    // pas ou plus de gestion par calendrier
            where ttCombo.cCode = "00001":
            delete ttCombo.
        end.
    end.
end procedure.

procedure comboParTypeIndexConvention:
    /*------------------------------------------------------------------------------
    Purpose: Combo Nature de traitement par type indexation conventionnelle
    Notes  : Service Externe beBail.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat           as int64     no-undo.
    define input  parameter pcTypeContrat             as character no-undo.
    define input  parameter plRevisionConventionnelle as logical   no-undo.
    define output parameter table for ttCombo.

    define variable viNumeroItem as integer   no-undo.
    define buffer sys_pr   for sys_pr.
    define buffer vbsys_pr for sys_pr.
    define buffer revtrt   for revtrt.

    empty temp-table ttCombo.
boucleSyspr:
    for each sys_pr no-lock
        where sys_pr.tppar = "RVCNA"
      , first vbsys_pr no-lock
        where vbsys_pr.tppar = "RVCTR"
          and vbsys_pr.zone2 begins sys_pr.zone2
          and vbsys_pr.zone1 = 1:
        // une seule ligne PEC Bail autorisée 
        if vbsys_pr.cdpar = "00100"
        and can-find(first revtrt no-lock
                     where revtrt.tpcon = pcTypeContrat
                       and revtrt.nocon = piNumeroContrat
                       and revtrt.cdtrt = "00100") then next boucleSyspr.

        // procédure seuil 25% (00400) autorisée si bail AVEC révision conventionnelle   
        if vbsys_pr.cdpar = "00400" and not plRevisionConventionnelle then next boucleSyspr. 

        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBPARIDXCONV"
            ttCombo.cCode     = sys_pr.cdpar
            ttCombo.cLibelle  = outilTraduction:getLibelleParam(sys_pr.tppar, sys_pr.cdpar)
            ttCombo.cParent   = sys_pr.zone2
        .
    end.

end procedure.

procedure comboParTypeNatureTraitmt:
    /*------------------------------------------------------------------------------
    Purpose: Combos par type de nature de traitement : Traitement et Action (si une seule ligne de traitement)
    Notes  : Service Externe beBail.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeNatureTraitement as character no-undo.
    define output parameter table for ttCombo.

    define variable viNumeroItem     as integer   no-undo.
    define variable vcMotCleNature   as character no-undo.
    define variable vdeZone1         as decimal   no-undo.
    define variable viNbTraitement   as integer   no-undo.
    define variable vcCodeTraitement as character no-undo.
    define buffer sys_pr for sys_pr.

    empty temp-table ttCombo.
    /* récupération du mot clé associé */
    run recupMotCleAssocie("RVCNA", pcCodeNatureTraitement, output vdeZone1, output vcMotCleNature).  
    // Chargement combo Traitement
    for each sys_pr no-lock
        where sys_pr.tppar = "RVCTR"
          and sys_pr.zone2 begins vcMotCleNature
          and sys_pr.zone1 = 1:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBPARNATTRMT"
            ttCombo.cCode     = sys_pr.cdpar
            ttCombo.cLibelle  = outilTraduction:getLibelleParam(sys_pr.tppar, sys_pr.cdpar)
            ttCombo.cParent   = sys_pr.zone2
            viNbTraitement = viNbTraitement + 1
        .
    end.
    if viNbTraitement = 1 then do:  // On charge les actions tout de suite
        // Autres combo
        for last ttCombo:
            assign
                viNumeroItem     = ttCombo.iSeqId
                vcCodeTraitement = ttCombo.cCode
            .
        end.
        // Chargement combo Action
        run chargeComboAction(string(vcCodeTraitement), viNumeroItem).
    end.

end procedure.

procedure comboParTypeTraitement:
    /*------------------------------------------------------------------------------
    Purpose: Combos par type de traitement : Action
    Notes  : Service Externe beBail.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeTraitement as character no-undo.
    define output parameter table for ttCombo.

    run chargeComboAction(pcCodeTraitement, 0).

end procedure.

procedure chargeComboAction private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de la combo Action
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeTraitement as character no-undo.
    define input  parameter piNumeroItem     as integer   no-undo.
      
    define variable viNbAction as integer   no-undo.
    define buffer sys_pr for sys_pr.

    for each sys_pr no-lock
        where sys_pr.tppar = "RVCAC"
          and sys_pr.cdpar = string(integer(pcCodeTraitement) + 01, "99999") :
        create ttCombo.
        assign
            piNumeroItem      = piNumeroItem + 1
            ttCombo.iSeqId    = piNumeroItem
            ttCombo.cNomCombo = "CMBPARTRAIMT"
            ttCombo.cCode     = sys_pr.cdpar
            ttCombo.cLibelle  = outilTraduction:getLibelleParam(sys_pr.tppar, sys_pr.cdpar)
            ttCombo.cParent   = sys_pr.zone2
            viNbAction = viNbAction + 1
        .
    end.

end procedure.

procedure recupMotCleAssocie private:
    /*------------------------------------------------------------------------------
    Purpose: récupération du mot clé associé
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeCode     as character no-undo.
    define input  parameter pcCodeNature   as character no-undo.
    define output parameter pdeZone1       as decimal   no-undo.
    define output parameter pcMotCleNature as character no-undo.
    define buffer sys_pr for sys_pr.

    for first sys_pr no-lock
        where sys_pr.tppar = pcTypeCode
          and sys_pr.cdpar = pcCodeNature:
        assign
            pdeZone1       = sys_pr.zone1  
            pcMotCleNature = sys_pr.zone2
        .
    end.
end procedure.

procedure controleTacheRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose: Contrôles des zones de saisie avant la maj des données
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheRevisionLoyer.
    define input parameter table for ttError.

    define variable voCollection as class collection no-undo.
    define variable vcSvgModeCal as character        no-undo.
    define buffer tache for tache.

    // Vérification que pour la création et la modif
    if ttTacheRevisionLoyer.CRUD <> 'D' then do:
        // Controle périodicité de révision
        if ttTacheRevisionLoyer.iPeriodiciteIndexation = 0 then do:
            // La périodicité de révision est obligatoire !!!
            mError:createError({&error}, 101086).
            return.
        end.
        // Controle date de révision
        if ttTacheRevisionLoyer.daProchaineRevision = ?
        then do:
            // La date de la prochaine révision doit être supérieure ou égale  au %1
            mError:createErrorGestion({&error}, 101039, substitute("&1", string(ttTacheRevisionLoyer.daDebutPeriodeRevision, '99/99/9999'))).
            return.
            //run GestMess in HdLibPrc(100344,"",101039,"",HwDatDeb:SCREEN-VALUE,"ERROR",output FgRepMes).
            //assign HwDatRev:SCREEN-VALUE = LbTmpPdt.  ?????
        end.
        
        // Confirmation de la modif du mode de calcul
        for last tache no-lock
            where tache.tpCon = ttTacheRevisionLoyer.cTypeContrat
              and tache.nocon = ttTacheRevisionLoyer.iNumeroContrat
              and tache.tptac = {&TYPETACHE-revision}:
            vcSvgModeCal = tache.cdhon.
        end.
        if vcSvgModeCal <> ttTacheRevisionLoyer.cCodeModeCalcul and ttTacheRevisionLoyer.CRUD <> 'C'
        then do:
            if ttTacheRevisionLoyer.cCodeModeCalcul = "00001" then
              // Le mode de calcul est passé à %1. Les rubriques 101 et 103 saisies seront écrasées par celles calculées. Confirmez-vous cette modification ?
                if outils:questionnaire(1000565, ttTacheRevisionLoyer.cLibelleModeCalcul, table ttError by-reference) <= 2 then return.
            else do:
                // Ajout SY le 29/01/2013 : controle changement mode de calcul
                if vcSvgModeCal = "00001" then do:
                    if can-find(first tache no-lock
                                where tache.tpcon = ttTacheRevisionLoyer.cTypeContrat
                                  and tache.nocon = ttTacheRevisionLoyer.iNumeroContrat
                                  and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}
                                  and tache.notac = 0
                                  and tache.tphon <> "no")
                    then do:
                      // Vous avez un calendrier d'évolution actif mais vous allez changer le mode de calcul et désactiver le calendrier.%sConfirmez-vous cette modification ?
                        if outils:questionnaire(1000555, table ttError by-reference) <= 2 then return.
                    end.
                    else do:
                        // Le mode de calcul est passé à %1. %sConfirmez vous cette modification?
                        if outils:questionnaire(105233, table ttError by-reference) <= 2 then return.
                    end.
                end.
                else do:
                    // Le mode de calcul est passé à %1. %sConfirmez vous cette modification?
                    if outils:questionnaire(105233, table ttError by-reference) <= 2 then return.
                end.
            end.
            if mError:erreur() then return.
        end.
        
        // Recherche de tous les paramètres d'initialisation
        run chercheParametres(ttTacheRevisionLoyer.iNumeroContrat, ttTacheRevisionLoyer.cTypeContrat, output voCollection).
        // Ajout Sy le 30/01/2015 : contrôle saisie Indexation à la baisse si combo visible
        if (voCollection:getLogical('lRevisionAlaBaisse') = true) and ttTacheRevisionLoyer.cCodeModeCalcul = "00000"  // Condition pour Combo Révision à la baisse :VISIBLE
        then do:
            if lookup(ttTacheRevisionLoyer.cCodeIndexationAlaBaisse, "00001,00002") = 0
            then do:
              // Blocage des indexations à la baisse", 0, "Vous n'avez pas saisi l'option d'indexation pour autoriser ou pas l'indexation à la baisse
                mError:createError({&error}, 1000552).
                return.
            end.
        end.
    end.

end procedure.

procedure controleDetailTacheRevision:
    /*------------------------------------------------------------------------------
    Purpose: Contrôles des zones de saisie concernant le détail (partie basse) avant la maj des données
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttHistoriqueRevisionLoyer.

    define variable voCollection   as class collection no-undo.
    define variable vcMotCleAction as character no-undo.
    define variable vdeZone1       as decimal   no-undo.
    define buffer vbttHistoriqueRevisionLoyer for ttHistoriqueRevisionLoyer.

    // Recherche de tous les paramètres d'initialisation
    run chercheParametres(ttHistoriqueRevisionLoyer.iNumeroContrat, ttHistoriqueRevisionLoyer.cTypeContrat, output voCollection).
    if ttHistoriqueRevisionLoyer.daDateReference = ? then do:
        // La date de référence est obligatoire
        mError:createError({&error}, 1000556).
        return.
    end.
    if (voCollection:getLogical('lBailSoumisRevisionTriennale') = true) and ttHistoriqueRevisionLoyer.CRUD = 'C'
    then do:
        if ttHistoriqueRevisionLoyer.cLibelleNatureTraitement = ? or ttHistoriqueRevisionLoyer.cLibelleNatureTraitement = ""
        // La nature du traitement est obligatoire (révision légale (triennale), avenant au bail ...)
        then mError:createError({&error}, 1000557).
        else if ttHistoriqueRevisionLoyer.cLibelletraitement = ? or ttHistoriqueRevisionLoyer.cLibelletraitement = ""
        // Traitement/Procédure",0,"Vous n'avez pas sélectionné le traitement (Demande en révision, procédure de renégociation...)
        then mError:createError({&error}, 1000558).
        // Action/étape",0,"Vous n'avez pas sélectionné l'action (Demande , Accord, Jugement...)
        else if ttHistoriqueRevisionLoyer.cCodeAction = ? or ttHistoriqueRevisionLoyer.cCodeAction = ""
        then mError:createError({&error}, 1000560).
        if mError:erreur() then return.
    end.
    // date de l'action obligatoire car elle sert au tri
    if ttHistoriqueRevisionLoyer.daDateAction = ? then do:
        // La date de l'action est obligatoire
        mError:createError({&error}, 1000559).
        return.
    end.    
    // loyer de référence
    // Récupération du mot clé associé
    run recupMotCleAssocie("RVCAC", ttHistoriqueRevisionLoyer.cCodeAction, output vdeZone1, output vcMotCleAction). 
    if vdeZone1 = 1 then do:
        if ttHistoriqueRevisionLoyer.dMontantMensuel = 0 then do:
            // Le loyer de référence est obligatoire
            mError:createError({&error}, 1000561).
            return.
        end.                        
    end.    
    if ttHistoriqueRevisionLoyer.iNumeroTraitementRevisiontmp > 0 and ttHistoriqueRevisionLoyer.daDateAction <> ?
    then do: 
        // Date de l'action : doit respecter l'ordre des étapes      
        find last vbttHistoriqueRevisionLoyer
            where vbttHistoriqueRevisionLoyer.cCodeTraitement       = ttHistoriqueRevisionLoyer.cCodeTraitement
              and vbttHistoriqueRevisionLoyer.iNumeroTraitementTemp = ttHistoriqueRevisionLoyer.iNumeroTraitement    // nath pb à vérifier
              and vbttHistoriqueRevisionLoyer.cCodeAction           < ttHistoriqueRevisionLoyer.cCodeAction
              and vbttHistoriqueRevisionLoyer.iNumeroContrat        = ttHistoriqueRevisionLoyer.iNumeroContrat
              and vbttHistoriqueRevisionLoyer.cTypeContrat          = ttHistoriqueRevisionLoyer.cTypeContrat no-error.
        if available vbttHistoriqueRevisionLoyer 
        and vbttHistoriqueRevisionLoyer.daDateAction <> ? 
        and vbttHistoriqueRevisionLoyer.daDateAction > ttHistoriqueRevisionLoyer.daDateAction then do:  // nath
            // La date de l'action ne peut pas être inférieure à la date de l'action précédente : " +  b3tt_revtrt.lbact + " le " + STRING(b3tt_revtrt.dtfin,"99/99/9999")
            mError:createErrorGestion({&error}, 1000566, substitute("&1&2&3", vbttHistoriqueRevisionLoyer.cLibelleAction, separ[1], string(vbttHistoriqueRevisionLoyer.daDateAction, "99/99/9999"))).
            return.
        end.    
        find first vbttHistoriqueRevisionLoyer
            where vbttHistoriqueRevisionLoyer.cCodeTraitement       = ttHistoriqueRevisionLoyer.cCodeTraitement
              and vbttHistoriqueRevisionLoyer.iNumeroTraitementTemp = ttHistoriqueRevisionLoyer.iNumeroTraitement    // nath pb à vérifier
              and vbttHistoriqueRevisionLoyer.cCodeAction           > ttHistoriqueRevisionLoyer.cCodeAction
              and vbttHistoriqueRevisionLoyer.iNumeroContrat        = ttHistoriqueRevisionLoyer.iNumeroContrat
              and vbttHistoriqueRevisionLoyer.cTypeContrat          = ttHistoriqueRevisionLoyer.cTypeContrat no-error.
        if  available vbttHistoriqueRevisionLoyer 
        and vbttHistoriqueRevisionLoyer.daDateAction <> ? 
        and vbttHistoriqueRevisionLoyer.daDateAction < ttHistoriqueRevisionLoyer.daDateAction then do:  // nath
            // La date de l'action ne peut pas être supérieure à la date de l'action suivante : " +  b3tt_revtrt.lbact + " le " + STRING(b3tt_revtrt.dtfin,"99/99/9999")
            mError:createErrorGestion({&error}, 1000567, substitute("&1&2&3", vbttHistoriqueRevisionLoyer.cLibelleAction, separ[1], string(vbttHistoriqueRevisionLoyer.daDateAction, "99/99/9999"))).
            return.
        end.                                    
    end.

end procedure.

procedure setDetailTraitements:
    /*------------------------------------------------------------------------------
    Purpose: MAJ des zones de saisie concernant le détail (partie basse)
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeDetail as character no-undo.
    define input parameter table for ttHistoriqueRevisionLoyer.

    define variable viNumNextTrtmtRevision as integer   no-undo.
    define variable viNumOrdreTraitement   as integer   no-undo.
    define variable vcMotCleTraitement     as character no-undo.
    define variable vdeZone1               as decimal   no-undo.
    define variable vcMotCleRvcac          as character no-undo.
    define variable viAnneeIndice          as integer   no-undo.
    define variable viNumeroPeriode        as integer   no-undo.
    define variable vhProcIndice           as handle    no-undo.
    define variable vcLibelleIndice        as character no-undo.
    define variable vdeNombre              as decimal   no-undo.

    define buffer vbttHistoriqueRevisionLoyer  for ttHistoriqueRevisionLoyer.
    define buffer vb2ttHistoriqueRevisionLoyer for ttHistoriqueRevisionLoyer.

    for first ttHistoriqueRevisionLoyer
        where lookup(ttHistoriqueRevisionLoyer.CRUD, "C,U,D") > 0:
        if not can-find(first tache no-lock
             where tache.tpcon = ttHistoriqueRevisionLoyer.cTypeContrat
               and tache.nocon = ttHistoriqueRevisionLoyer.iNumeroContrat
               and tache.tptac = {&TYPETACHE-revision})
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
    end.

    run bail/quittancement/indiceRevision.p persistent set vhProcIndice.
    run getTokenInstance in vhProcIndice(mToken:JSessionId).

    for each ttHistoriqueRevisionLoyer
        where lookup(ttHistoriqueRevisionLoyer.CRUD, "C,U,D") > 0:
        case ttHistoriqueRevisionLoyer.CRUD:
            when "U" then run majDetail(buffer ttHistoriqueRevisionLoyer). // Modification de l'enregistrement
            when "D" then delete ttHistoriqueRevisionLoyer.
            when "C" then do:
                if pcTypeDetail = 'DETCRE' then do:
                    viNumNextTrtmtRevision = 1.
                    find last vbttHistoriqueRevisionLoyer no-error.
                    if available vbttHistoriqueRevisionLoyer then viNumNextTrtmtRevision = vbttHistoriqueRevisionLoyer.iNumeroTraitementRevisiontmp + 1.
                    viNumOrdreTraitement = 1.
                    find last vbttHistoriqueRevisionLoyer
                        where vbttHistoriqueRevisionLoyer.cCodeTraitement = ttHistoriqueRevisionLoyer.cCodeTraitement no-error.
                    if available vbttHistoriqueRevisionLoyer then viNumOrdreTraitement = vbttHistoriqueRevisionLoyer.iNumeroTraitementTemp + 1.
                    create vbttHistoriqueRevisionLoyer.
                    assign
                        vbttHistoriqueRevisionLoyer.lLigneSaisissable            = yes
                        vbttHistoriqueRevisionLoyer.iNumeroTraitementRevisiontmp = viNumNextTrtmtRevision
                        vbttHistoriqueRevisionLoyer.iNumeroTraitementRevision    = 0
                        vbttHistoriqueRevisionLoyer.iNumeroTraitementTemp        = viNumOrdreTraitement
                        //ttHistoriqueRevisionLoyer.affnotrt                     = string(ttHistoriqueRevisionLoyer.iNumeroTraitementTemp) nath pb
                        vbttHistoriqueRevisionLoyer.iNumeroTraitement            = 0
                        vbttHistoriqueRevisionLoyer.cTypeContrat                 = ttHistoriqueRevisionLoyer.cTypeContrat
                        vbttHistoriqueRevisionLoyer.iNumeroContrat               = ttHistoriqueRevisionLoyer.iNumeroContrat
                        vbttHistoriqueRevisionLoyer.cCodeNatureTraitement        = ttHistoriqueRevisionLoyer.cCodeNatureTraitement
                        vbttHistoriqueRevisionLoyer.cCodeTraitement              = ttHistoriqueRevisionLoyer.cCodeTraitement 
                        vbttHistoriqueRevisionLoyer.cCodeAction                  = ttHistoriqueRevisionLoyer.cCodeAction
                        //vbttHistoriqueRevisionLoyer.dtcsy                      = today
                        //vbttHistoriqueRevisionLoyer.hecsy                      = mtime
                        //vbttHistoriqueRevisionLoyer.cdcsy                      = mToken:cUser
                        vbttHistoriqueRevisionLoyer.daDateReference              = ttHistoriqueRevisionLoyer.daDateReference
                        vbttHistoriqueRevisionLoyer.cLibelleNatureTraitement     = ttHistoriqueRevisionLoyer.cLibelleNatureTraitement 
                        vbttHistoriqueRevisionLoyer.cLibelletraitement           = ttHistoriqueRevisionLoyer.cLibelletraitement 
                        vbttHistoriqueRevisionLoyer.cLibelleAction               = ttHistoriqueRevisionLoyer.cLibelleAction 
                        vbttHistoriqueRevisionLoyer.CRUD                         = 'C'
                    . 
                    // Récupération du mot clé associé
                    run recupMotCleAssocie("RCVTR", ttHistoriqueRevisionLoyer.cCodeTraitement, output vdeZone1, output vcMotCleTraitement). 
                    vbttHistoriqueRevisionLoyer.motcletraitement = vcMotCleTraitement.
                    // maj lLoyerReference en fonction du traitement+action (RVCAC zone1)
                    run recupMotCleAssocie("RVCAC", ttHistoriqueRevisionLoyer.cCodeAction, output vdeZone1, output vcMotCleRvcac).
                    assign
                        vbttHistoriqueRevisionLoyer.lLoyerReference = ( vdeZone1 = 1 )
                        vbttHistoriqueRevisionLoyer.cLibelleLoyer = (if vbttHistoriqueRevisionLoyer.lLoyerReference then "Loyer de référence" else "Loyer offert")
                    . 
                    // Indice de référence
                    if ttHistoriqueRevisionLoyer.cCodeAction = "00101" or ttHistoriqueRevisionLoyer.cCodeAction = "00501"
                    then do:
                        run calculPeriodeIndice(ttHistoriqueRevisionLoyer.daDateReference, output viAnneeIndice, output viNumeroPeriode).
                        assign
                            vbttHistoriqueRevisionLoyer.iCodeIndiceRevision = 6                   // INSEE
                            vbttHistoriqueRevisionLoyer.iAnneeIndice        = viAnneeIndice       // Année de indice revisi anirv
                            vbttHistoriqueRevisionLoyer.iNumeroPeriodAnnee  = viNumeroPeriode     // No période de l'année  noirv
                        .
                        // vlirv Valeur de l'indice 
                        //run bail/quittancement/indiceRevision.p persistent set vhProcIndice.
                        //run getTokenInstance in vhProcIndice(mToken:JSessionId).
                        run getLibelleIndice3Lignes in vhProcIndice('INDICE',
                                                                     vbttHistoriqueRevisionLoyer.iCodeIndiceRevision,
                                                                     string(vbttHistoriqueRevisionLoyer.iAnneeIndice, '9999') + '/' + string(vbttHistoriqueRevisionLoyer.iNumeroPeriodAnnee),
                                                                     22,
                                                                     output vcLibelleIndice).
                        //run destroy in vhProcIndice.
                        vbttHistoriqueRevisionLoyer.cLibelleTypeIndice = entry(1, vcLibelleIndice, "|").                   // libellé type d'indice (cdirv)               
                        if num-entries(vcLibelleIndice, "|") >= 3 then vbttHistoriqueRevisionLoyer.dValeurIndice = decimal(entry(3, vcLibelleIndice, "|")).
                        if num-entries(vcLibelleIndice, "|") >= 4 then vdeNombre = decimal(entry(4, vcLibelleIndice, "|")).
                        if vdeNombre = 0
                        then vbttHistoriqueRevisionLoyer.cValeurIndice = string(vbttHistoriqueRevisionLoyer.dValeurIndice, ">>>>>9").
                        else if vdeNombre = 2
                             then vbttHistoriqueRevisionLoyer.cValeurIndice = string(vbttHistoriqueRevisionLoyer.dValeurIndice, ">>>>>9.99").
                             else vbttHistoriqueRevisionLoyer.cValeurIndice = string(vbttHistoriqueRevisionLoyer.dValeurIndice).         
                        if num-entries(vcLibelleIndice, "|") >= 5 then vbttHistoriqueRevisionLoyer.cLibelleIndice = entry(5, vcLibelleIndice, "|").  // libellé court                                    
                    end.
                    // Modification de l'enregistrement
                    run majDetail(buffer vbttHistoriqueRevisionLoyer).
                    // Procédure terminée si loyer ref ou si Prescription
                    if vbttHistoriqueRevisionLoyer.lLoyerReference or vbttHistoriqueRevisionLoyer.cCodeAction = "00599"
                    then run HistProc(buffer vbttHistoriqueRevisionLoyer).       // Historiser la procédure 
                    // répercuter le no de traitement temporaire sur les fichiers joints
                    // GED ??? npo
                end.
                if pcTypeDetail = 'DETSUIV' then do:
                    find first vb2ttHistoriqueRevisionLoyer 
                        where vb2ttHistoriqueRevisionLoyer.iNumeroTraitementRevisiontmp = ttHistoriqueRevisionLoyer.iNumeroTraitementRevisiontmp no-error.
                    viNumNextTrtmtRevision = 1.
                    find last vbttHistoriqueRevisionLoyer no-error.
                    if available vbttHistoriqueRevisionLoyer then viNumNextTrtmtRevision = vbttHistoriqueRevisionLoyer.iNumeroTraitementRevisiontmp + 1.
                    create vbttHistoriqueRevisionLoyer.
                    buffer-copy vb2ttHistoriqueRevisionLoyer except iNumeroTraitementRevisiontmp to vbttHistoriqueRevisionLoyer.
                    assign
                        vbttHistoriqueRevisionLoyer.iNumeroTraitementRevisiontmp = viNumNextTrtmtRevision
                        vbttHistoriqueRevisionLoyer.iNumeroTraitementRevision    = 0             
                        vbttHistoriqueRevisionLoyer.cCodeAction                  = ttHistoriqueRevisionLoyer.cCodeAction    
                        //vbttHistoriqueRevisionLoyer.dtcsy = today
                        //vbttHistoriqueRevisionLoyer.hecsy = mtime
                        //vbttHistoriqueRevisionLoyer.cdcsy = mToken:cUser
                        vbttHistoriqueRevisionLoyer.daDateReference              = ttHistoriqueRevisionLoyer.daDateReference
                        vbttHistoriqueRevisionLoyer.cLibelleNatureTraitement     = ttHistoriqueRevisionLoyer.cLibelleNatureTraitement
                        vbttHistoriqueRevisionLoyer.cLibelletraitement           = ttHistoriqueRevisionLoyer.cLibelletraitement 
                        vbttHistoriqueRevisionLoyer.cLibelleAction               = ttHistoriqueRevisionLoyer.cLibelleAction
                        vbttHistoriqueRevisionLoyer.CRUD                         = 'C'
                    .
                    // maj lLoyerReference en fonction du traitement+action (RVCAC zone1)
                    run recupMotCleAssocie("RVCAC", ttHistoriqueRevisionLoyer.cCodeAction, output vdeZone1, output vcMotCleRvcac).
                    assign
                        vbttHistoriqueRevisionLoyer.lLoyerReference = (vdeZone1 = 1) 
                        vbttHistoriqueRevisionLoyer.cLibelleLoyer   = (if vbttHistoriqueRevisionLoyer.lLoyerReference then "Loyer de référence" else "Loyer offert")
                    . 
                    // Modification de l'enregistrement
                    run majDetail(buffer vbttHistoriqueRevisionLoyer).
                    // Procédure terminée si loyer ref ou si Prescription
                    if vbttHistoriqueRevisionLoyer.lLoyerReference or vbttHistoriqueRevisionLoyer.cCodeAction = "00599"
                    then run HistProc(buffer vbttHistoriqueRevisionLoyer).      /* Historiser la procédure */ 
                end.
            end.
        end case.
    end.
    run destroy in vhProcIndice.

end procedure.

procedure majDetail private:
    /*------------------------------------------------------------------------------
    Purpose: maj ttHistoriqueRevisionLoyer
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttHistoriqueRevisionLoyer for ttHistoriqueRevisionLoyer.
    define buffer intnt for intnt.

    // Maj du numéro de rôle demandeur
    if ttHistoriqueRevisionLoyer.cTypeRoleDemandeur = {&TYPEROLE-mandant}
    then for first intnt no-lock
        where intnt.tpidt = ttHistoriqueRevisionLoyer.cTypeRoleDemandeur
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = int64(truncate(ttHistoriqueRevisionLoyer.iNumeroContrat / 100000, 0)) :
        ttHistoriqueRevisionLoyer.iNumeroRoleDemandeur = intnt.noidt.  
    end.
    else if ttHistoriqueRevisionLoyer.cTypeRoleDemandeur = {&TYPEROLE-locataire} 
         then ttHistoriqueRevisionLoyer.iNumeroRoleDemandeur = ttHistoriqueRevisionLoyer.iNumeroContrat.

    // Maj libellé mois quittancement
    if ttHistoriqueRevisionLoyer.iMoisQuittancement > 0 and ttHistoriqueRevisionLoyer.iAnneeQuittancement > 0
    then assign
        ttHistoriqueRevisionLoyer.iPeriodeQuittancement = ttHistoriqueRevisionLoyer.iAnneeQuittancement * 100 + ttHistoriqueRevisionLoyer.iMoisQuittancement
        //ttHistoriqueRevisionLoyer.cPeriodeQuittancement = substring(string(ttHistoriqueRevisionLoyer.iPeriodeQuittancement, "999999"), 5, 2) + "." 
        //                                                + substring(string(ttHistoriqueRevisionLoyer.iPeriodeQuittancement, "999999"), 1, 4)
    .
end procedure.

procedure setTacheRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose: MAJ des zones de saisie de tout l'écran
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheRevisionLoyer.
    define input parameter table for ttHistoriqueRevisionLoyer.
    define input parameter table for ttError.

    // Confirmez-vous la suppression ?
    if ttHistoriqueRevisionLoyer.CRUD = "D"
    and outils:questionnaire(100257, table ttError by-reference) <= 2 then return.        // Confirmez-vous la suppression ?

    run majTacheRevision(buffer ttTacheRevisionLoyer, "MAJ").       // MAJ des tables
    // Mise à jour de la tache calendrier du loyer selon révision manuelle ou non
    run majTacheCalendrier(buffer ttTacheRevisionLoyer, "MAJ").
    run majTraitementsRevision(buffer ttHistoriqueRevisionLoyer).    // MAJ table de traitement révisions

end procedure.

procedure majTacheRevision private:
    /*------------------------------------------------------------------------------
    Purpose: MAJ des zones de saisie de tout l'écran : de toutes les tables liées à la tâche
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheRevisionLoyer for ttTacheRevisionLoyer.
    define input  parameter pcTypeAction as character no-undo.

    define variable vhProcIndrv         as handle    no-undo.
    define variable vhProcTache         as handle    no-undo.
    define variable vdTauxRevisionLoyer as decimal   no-undo.
    define variable vdValeurRevisionLoy as decimal   no-undo.
    define variable vcTauxRevisionLoyer as character no-undo.
    define variable vcValeurRevisionLoy as character no-undo.
    define variable vcListeIndiceSaisi  as character no-undo.
    define variable vcPreparationListe  as character no-undo.
    define variable vcLibelleIndiceBase as character no-undo.
    define variable vlRetour            as logical   no-undo.
    define variable voCollection        as class collection no-undo.

    define buffer tache for tache.
    define buffer cttac for cttac.
    define buffer pquit for pquit.
    define buffer equit for equit.

    // Recherche du taux pour la révision
    // Modif SY le 06/11/2013 - 1013/0058 : toujours recalculer le taux selon la périodicité de révision
    run adblib/indiceRevision_CRUD.p persistent set vhProcIndrv.
    run getTokenInstance in vhProcIndrv(mToken:JSessionId).
    run readIndiceRevision3 in vhProcIndrv (ttTacheRevisionLoyer.cCodeTypeIndiceCourant, 
                                            ttTacheRevisionLoyer.cCodeAnneeIndiceCourant, 
                                            ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant,
                                            output voCollection)
    .
    if voCollection:getLogical("lTrouve") then do:
        assign
            vdTauxRevisionLoyer = voCollection:getDecimal("dTauxRevision")
            vdValeurRevisionLoy = voCollection:getDecimal("dValeurRevision")
        .
        if vdTauxRevisionLoyer <> 0 then vcTauxRevisionLoyer = string(vdTauxRevisionLoyer).
        if vdValeurRevisionLoy <> 0 then vcValeurRevisionLoy = string(vdValeurRevisionLoy).
    end.
    if valid-handle(vhProcIndrv) then run destroy in vhProcIndrv.

    // Revision à la baisse et variation de l'indice 
    vcPreparationListe = substitute("&&&1#&2", ttTacheRevisionLoyer.cCodeIndexationAlaBaisse, ttTacheRevisionLoyer.cPourcentageVariation).
    if pcTypeAction = "INIT"        // PEC / creation bail
    then vcListeIndiceSaisi = substitute("&1#&2#&3&&&1&2&3&4",
                                        ttTacheRevisionLoyer.cLibelleIndiceCourant, vcValeurRevisionLoy, vcTauxRevisionLoyer, vcPreparationListe).
    else do:
        if vcPreparationListe > ""
        then vcLibelleIndiceBase = entry(1, entry(10, vcPreparationListe, "@"), "&").
        else vcLibelleIndiceBase = substitute("&1#&2#&3", ttTacheRevisionLoyer.cLibelleIndiceCourant, vcValeurRevisionLoy, vcTauxRevisionLoyer).
        vcListeIndiceSaisi = substitute("&1&&&2#&3#&4&5", 
                             vcLibelleIndiceBase, ttTacheRevisionLoyer.cLibelleIndiceCourant, vcValeurRevisionLoy, vcTauxRevisionLoyer, vcPreparationListe).
        if ttTacheRevisionLoyer.iNumeroTache = 1
        then assign
            vcListeIndiceSaisi = substitute("&1#&2#&3&&&1&2&3&4", 
                                            ttTacheRevisionLoyer.cLibelleIndiceCourant, vcValeurRevisionLoy, vcTauxRevisionLoyer, vcPreparationListe).
    end.
    // modif SY le 27/10/2010 mais je ne comprends pas à quoi ça sert !!! (tache.tpfin)
    if ttTacheRevisionLoyer.daProchaineRevision = ttTacheRevisionLoyer.daFinBail
    then ttTacheRevisionLoyer.cCodeMotifFin = "00006".
    else ttTacheRevisionLoyer.cCodeMotifFin = "00008".

    if ttTacheRevisionLoyer.cCodeModeCalcul <> "00000" then ttTacheRevisionLoyer.cCodeFlagIndexationManuelle = "YES".   // Modif SY le 04/03/2008
    // Manpower : Revision manuelle dans tous les cas
    if integer(mToken:cRefGerance) = 10 then ttTacheRevisionLoyer.cCodeFlagIndexationManuelle = "YES". 

    for first ttTacheRevisionLoyer
        where lookup(ttTacheRevisionLoyer.CRUD, "C,U") > 0:
        if ttTacheRevisionLoyer.CRUD = "C" then ttTacheRevisionLoyer.daDateReelleTraitementRevision = ?.
        if ttTacheRevisionLoyer.CRUD = "U" then do:
            // Récupération infos tache en cours
            find last tache no-lock
                where tache.tpcon = ttTacheRevisionLoyer.cTypeContrat
                  and tache.nocon = ttTacheRevisionLoyer.iNumeroContrat
                  and tache.tptac = ttTacheRevisionLoyer.cTypeTache no-error.
            if not available tache then do:
                // Modification non effectuée !!!
                mError:createError({&error}, 100350).
                return.
            end.
            assign
                ttTacheRevisionLoyer.daDateReelleTraitementRevision = tache.dtreg
                ttTacheRevisionLoyer.cCodeEtatRevision = if ttTacheRevisionLoyer.lRevisionConventionnelle then "1" else ""
            .
        end.
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.noita       = ttTacheRevisionLoyer.iNumeroTache
            ttTache.tpcon       = ttTacheRevisionLoyer.cTypeContrat
            ttTache.nocon       = ttTacheRevisionLoyer.iNumeroContrat
            ttTache.tptac       = ttTacheRevisionLoyer.cTypeTache
            ttTache.notac       = ttTacheRevisionLoyer.iChronoTache

            ttTache.dtdeb       = ttTacheRevisionLoyer.daDebutPeriodeRevision
            //ttTache.dtfin       = ttTacheRevisionLoyer.daProchaineRevision
            ttTache.tpfin       = ttTacheRevisionLoyer.cCodeMotifFin
            ttTache.duree       = ttTacheRevisionLoyer.iPeriodiciteIndexation
            ttTache.ntges       = ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceDeBase
            ttTache.tpges       = ttTacheRevisionLoyer.cCodeTypeIndiceDeBase
            ttTache.pdges       = ttTacheRevisionLoyer.cCodeAnneeIndiceDeBase
            ttTache.cdreg       = ttTacheRevisionLoyer.cCodeAnneeIndiceCourant
            ttTache.ntreg       = ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant
            ttTache.pdreg       = ttTacheRevisionLoyer.cCodeUnitePerioIndexation        // '00001' An(s)
            ttTache.dcreg       = ttTacheRevisionLoyer.cCodeTypeIndiceCourant
            ttTache.dtreg       = ttTacheRevisionLoyer.daDateReelleTraitementRevision
            ttTache.mtreg       = ttTacheRevisionLoyer.dMontantLoyerEncours
            ttTache.utreg       = ttTacheRevisionLoyer.cCodeEtatRevision
            ttTache.tphon       = ttTacheRevisionLoyer.cCodeFlagIndexationManuelle      // ???? cCodeFlagIndexationAutomatique as character label "tphon"  /* no/yes */
            ttTache.cdhon       = ttTacheRevisionLoyer.cCodeModeCalcul
            ttTache.lbdiv       = vcListeIndiceSaisi
            ttTache.lbmotif     = ttTacheRevisionLoyer.cLibelleMotifRevisionManuelle
            ttTache.fgidxconv   = ttTacheRevisionLoyer.lRevisionConventionnelle

            ttTache.CRUD        = ttTacheRevisionLoyer.CRUD
            ttTache.dtTimestamp = ttTacheRevisionLoyer.dtTimestamp
            ttTache.rRowid      = ttTacheRevisionLoyer.rRowid
        .
/*
        if ttTacheRevisionLoyer.CRUD = "U" then
            assign
                ttTache.lbdiv2  = ttTacheRevisionLoyer.
                ttTache.lbdiv3  = ttTacheRevisionLoyer.
                ttTache.TxNo1   = ttTacheRevisionLoyer.
                ttTache.TxNo2   = ttTacheRevisionLoyer.
*/
        run tache/tache.p persistent set vhProcTache.
        run getTokenInstance in vhProcTache(mToken:JSessionId).
        run setTache in vhProcTache(table ttTache by-reference).
        run destroy in vhProcTache.

        if not mError:erreur() and ttTacheRevisionLoyer.CRUD = "C" then do:
            empty temp-table ttCttac.
            run adblib/cttac_CRUD.p persistent set vhProcTache.
            run getTokenInstance in vhProcTache (mToken:JSessionId).
            find first cttac no-lock
                 where cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                   and cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat
                   and cttac.tptac = ttTacheRevisionLoyer.cTypeTache no-error.
            if not available cttac then do:
                create ttCttac.
                assign
                    ttCttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                    ttCttac.nocon = ttTacheRevisionLoyer.iNumeroContrat
                    ttCttac.tptac = ttTacheRevisionLoyer.cTypeTache
                    ttCttac.CRUD  = "C"
                .
                run setCttac in vhProcTache(table ttCttac by-reference).
            end.
            run destroy in vhProcTache.
        end.
        if vlRetour and ttTacheRevisionLoyer.CRUD = "U" then do:
            // Maj des quittances
            if ttTacheRevisionLoyer.cTypeContrat = {&TYPECONTRAT-preBail}
            then for each pquit exclusive-lock // NP 0413/0033
                where pquit.noloc = ttTacheRevisionLoyer.iNumeroContrat:
                assign  
                    pquit.tpidc = ttTacheRevisionLoyer.cCodeTypeIndiceDeBase
                    pquit.noidc = integer(ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant + ttTacheRevisionLoyer.cCodeAnneeIndiceCourant)
                    pquit.dtrev = ttTacheRevisionLoyer.daProchaineRevision
                    pquit.dtprv = tache.dtreg
                    pquit.fgtrf = false
                .
            end.
            else for each equit exclusive-lock
                where equit.noloc = ttTacheRevisionLoyer.iNumeroContrat:
                assign  
                    equit.tpidc = ttTacheRevisionLoyer.cCodeTypeIndiceDeBase
                    equit.noidc = integer(ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant + ttTacheRevisionLoyer.cCodeAnneeIndiceCourant)
                    equit.dtrev = ttTacheRevisionLoyer.daProchaineRevision
                    equit.dtprv = tache.dtreg
                    equit.fgtrf = false
                .
            end.
        end.
        // Ajout SY le 04/03/2008 : Mise à jour tache Indexation 04137
        if ttTacheRevisionLoyer.cCodeModeCalcul = "00000"
        then for each tache exclusive-lock
            where tache.tpcon = ttTacheRevisionLoyer.cTypeContrat
              and tache.nocon = ttTacheRevisionLoyer.iNumeroContrat
              and tache.tptac = {&TYPETACHE-indexationLoyer}:
            delete tache.
        end.
        else do:
            empty temp-table ttTache.
            find last tache no-lock
                where tache.tpcon = ttTacheRevisionLoyer.cTypeContrat
                  and tache.nocon = ttTacheRevisionLoyer.iNumeroContrat
                  and tache.tptac = {&TYPETACHE-indexationLoyer} no-error.
            if not available tache then do:
                create ttTache.
                assign
                    ttTache.noita = ttTacheRevisionLoyer.iNumeroTache
                    ttTache.tpcon = ttTacheRevisionLoyer.cTypeContrat
                    ttTache.nocon = ttTacheRevisionLoyer.iNumeroContrat
                    ttTache.tptac = {&TYPETACHE-indexationLoyer}
                    ttTache.notac = ttTacheRevisionLoyer.iChronoTache
                .
            end.
            else do:
                create ttTache.
                assign
                    ttTache.noita = tache.noita
                    ttTache.tpcon = tache.tpcon
                    ttTache.nocon = tache.nocon
                    ttTache.tptac = tache.tptac
                    ttTache.notac = tache.notac
                .
            end.                            
            assign
                //ttTache.dtfin     = ttTacheRevisionLoyer.
                ttTache.duree       = ttTacheRevisionLoyer.iPeriodiciteIndexation
                ttTache.cdreg       = ttTacheRevisionLoyer.cCodeAnneeIndiceCourant
                ttTache.ntreg       = ttTacheRevisionLoyer.cCodeNombrePeriodeIndiceCourant
                ttTache.pdreg       = ttTacheRevisionLoyer.cCodeUnitePerioIndexation        // '00001' An(s)
                ttTache.dcreg       = ttTacheRevisionLoyer.cCodeTypeIndiceCourant
                ttTache.tphon       = ttTacheRevisionLoyer.cCodeFlagIndexationAutomatique   // ???? cCodeFlagIndexationManuelle as character label "tphon"  /* no/yes */
                ttTache.cdhon       = ttTacheRevisionLoyer.cCodeModeCalcul
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy) when available tache
                ttTache.CRUD        = (if available tache then 'U' else 'C')
                ttTache.rRowid      = rowid(tache) when available tache
            .
            run tache/tache.p persistent set vhProcTache.
            run getTokenInstance in vhProcTache(mToken:JSessionId).
            run setTache in vhProcTache(table ttTache by-reference).
            run destroy in vhProcTache.
        end.
    end.

end procedure.

procedure majTacheCalendrier private:
    /*------------------------------------------------------------------------------
    Purpose: MAJ des zones de saisie de tout l'écran
    Notes  : Création/Suppression du lien Bail - tache Calendrier Loyer
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheRevisionLoyer for ttTacheRevisionLoyer.
    define input parameter pcTypeAction as character no-undo.

    define buffer tache for tache.
    define buffer cttac for cttac.

    if pcTypeAction <> "INIT"
    then for last tache no-lock
        where tache.tpcon = ttTacheRevisionLoyer.cTypeContrat
          and tache.nocon = ttTacheRevisionLoyer.iNumeroContrat
          and tache.tptac = {&TYPETACHE-revision}:
        case tache.cdhon:
            when "00001" then do:
                // Tache calendrier d'évolution des loyers
                if not can-find(first cttac no-lock
                                where cttac.tptac = {&TYPETACHE-calendrierEvolutionLoyer}
                                  and cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                                  and cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat)
                then do:
                    create cttac.
                    assign 
                        cttac.tptac = {&TYPETACHE-calendrierEvolutionLoyer}
                        cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                        cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat
                    .
                end.
                // Tache échelle mobile des loyers
                for each cttac exclusive-lock
                    where cttac.tptac = {&TYPETACHE-echelleMobileLoyer}
                      and cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                      and cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat:
                    delete cttac.
                end.
                // Tache chiffre d'affaires
                for each cttac exclusive-lock
                    where cttac.tptac = {&TYPETACHE-chiffredAffaires}
                      and cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                      and cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat:
                    delete cttac.
                end.
            end.
            when "00002" then do:
                // Tache échelle mobile des loyers
                if not can-find(first cttac no-lock
                                where cttac.tptac = {&TYPETACHE-echelleMobileLoyer}
                                  and cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                                  and cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat)
                then do:
                    create cttac.
                    assign
                        cttac.tptac = {&TYPETACHE-echelleMobileLoyer}
                        cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                        cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat
                    .
                end.
                // Tache chiffre d'affaires
                if not can-find(first cttac no-lock
                                where cttac.tptac = {&TYPETACHE-chiffredAffaires}
                                  and cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                                  and cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat) then do:
                    create cttac.
                    assign
                        cttac.tptac = {&TYPETACHE-chiffredAffaires}       
                        cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                        cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat
                    .
                end.
                run desactiverCalendrier(ttTacheRevisionLoyer.cTypeContrat, ttTacheRevisionLoyer.iNumeroContrat).
            end.
            otherwise do:
                run desactiverCalendrier(ttTacheRevisionLoyer.cTypeContrat, ttTacheRevisionLoyer.iNumeroContrat).               
                // Tache échelle mobile des loyers
                for each cttac exclusive-lock
                    where cttac.tptac = {&TYPETACHE-echelleMobileLoyer}     
                      and cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                      and cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat:
                    delete cttac.
                end.
                // Tache chiffre d'affaires
                for each cttac exclusive-lock
                    where cttac.tptac = {&TYPETACHE-chiffredAffaires}       
                      and cttac.tpcon = ttTacheRevisionLoyer.cTypeContrat
                      and cttac.nocon = ttTacheRevisionLoyer.iNumeroContrat:
                    delete cttac.
                end.
            end.
        end case.
     end.
end procedure.

procedure desactiverCalendrier private:                                         
    /*------------------------------------------------------------------------------
    Purpose: Désactiver le calendrier d'évolution
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define buffer tache for tache.
    define buffer cttac for cttac.

    // Ajout Sy le 29/01/2013 : désactiver le calendrier d'évolution
    for first tache exclusive-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer} 
          and tache.notac = 0
          and tache.tphon <> "NO":
        assign
            tache.tphon = "NO"      // utilisation du calendrier pour calculer le loyer
            tache.dtreg = today     // date de traitement de la fin du calendrier
            tache.dtmsy = today
            tache.hemsy = mtime
            tache.cdmsy = mToken:cUser + "@prmobrev.p"
            // Ajout SY le 29/01/2013 
            tache.lbdiv2 = substitute("Changement mode de calcul &1 par &2 (prmobrev.p)", string(today, "99/99/9999"), mToken:cUser)
        .
    end.
    for each cttac exclusive-lock
        where cttac.tptac = {&TYPETACHE-calendrierEvolutionLoyer}     
          and cttac.tpcon = pcTypeContrat
          and cttac.nocon = piNumeroContrat:
        delete cttac.
    end.

end procedure.

procedure majTraitementsRevision private:
    /*------------------------------------------------------------------------------
    Purpose: MAJ des zones de saisie de tout l'écran
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttHistoriqueRevisionLoyer for ttHistoriqueRevisionLoyer.

    define buffer revtrt                   for revtrt.
    define buffer vbttHistoriqueRevisionLoyer for ttHistoriqueRevisionLoyer.

    define variable viNumNextTrtmtRevision as integer no-undo.
    define variable viNumOrdreTraitement   as integer no-undo.

    // 1) Mettre en histo puis supprimer les traitements supprimés
    for each revtrt exclusive-lock 
        where revtrt.tpcon = ttHistoriqueRevisionLoyer.cTypeContrat
          and revtrt.nocon = ttHistoriqueRevisionLoyer.iNumeroContrat:
        find first vbttHistoriqueRevisionLoyer
            where vbttHistoriqueRevisionLoyer.cTypeContrat              = revtrt.tpcon
              and vbttHistoriqueRevisionLoyer.iNumeroContrat            = revtrt.nocon
              and vbttHistoriqueRevisionLoyer.cCodeTraitement           = revtrt.cdtrt    
              and vbttHistoriqueRevisionLoyer.iNumeroTraitementRevision = revtrt.inotrtrev no-error.
        if not available vbttHistoriqueRevisionLoyer then do:
            // créer une trace dans histo
            assign
                revtrt.cdsta = "SUPPR"
                revtrt.tphis = substitute("Supprimé le &1 par &2", today, mToken:cUser)
            .
            run createHistoriqueRevision(buffer revtrt).  
            // suppression
            delete revtrt.
        end.
    end.
    // 2) Création/modification des traitements
    for each ttHistoriqueRevisionLoyer
        where ttHistoriqueRevisionLoyer.lLigneSaisissable
        use-index ix_tt_revtrt02:
        if ttHistoriqueRevisionLoyer.iNumeroTraitementRevision = 0
        then do:
            viNumNextTrtmtRevision = 1.
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last revtrt no-lock no-error.
            if available revtrt then viNumNextTrtmtRevision = revtrt.inotrtrev + 1.    
            // Répercuter le no de traitement sur les fichiers joints
            // GED ??? npo                                                           
        end.
        else viNumNextTrtmtRevision = ttHistoriqueRevisionLoyer.iNumeroTraitementRevision.
        if ttHistoriqueRevisionLoyer.iNumeroTraitement = 0
        then do:
            viNumOrdreTraitement = 1.
            find last revtrt no-lock
                where revtrt.tpcon = ttHistoriqueRevisionLoyer.cTypeContrat
                  and revtrt.nocon = ttHistoriqueRevisionLoyer.iNumeroContrat
                  and revtrt.cdtrt = ttHistoriqueRevisionLoyer.cCodeTraitement no-error.
            if available revtrt then viNumOrdreTraitement = revtrt.notrt + 1.   
 
            // répercuter le no de traitement sur toutes les lignes de la procédure
            for each vbttHistoriqueRevisionLoyer    
                where vbttHistoriqueRevisionLoyer.cTypeContrat          = ttHistoriqueRevisionLoyer.cTypeContrat
                  and vbttHistoriqueRevisionLoyer.iNumeroContrat        = ttHistoriqueRevisionLoyer.iNumeroContrat
                  and vbttHistoriqueRevisionLoyer.cCodeTraitement       = ttHistoriqueRevisionLoyer.cCodeTraitement
                  and vbttHistoriqueRevisionLoyer.iNumeroTraitementTemp = ttHistoriqueRevisionLoyer.iNumeroTraitementTemp:
                vbttHistoriqueRevisionLoyer.iNumeroTraitement = viNumOrdreTraitement.
            end.
        end.
        else viNumOrdreTraitement = ttHistoriqueRevisionLoyer.iNumeroTraitement.
        find first revtrt exclusive-lock
            where revtrt.inotrtrev = viNumNextTrtmtRevision
              and revtrt.tpcon     = ttHistoriqueRevisionLoyer.cTypeContrat
              and revtrt.nocon     = ttHistoriqueRevisionLoyer.iNumeroContrat no-error.
        if not available revtrt then do:
            create revtrt.
            assign
                revtrt.inotrtrev = viNumNextTrtmtRevision
                revtrt.notrt     = viNumOrdreTraitement
            .
        end.
        else if not isTraitementsRevisionIdentiques(buffer revtrt) then do:
            // Créer une trace dans histo
            run createHistoriqueRevision(buffer revtrt).
            /*assign
                ttHistoriqueRevisionLoyer.dtmsy = today
                ttHistoriqueRevisionLoyer.hemsy = time
                ttHistoriqueRevisionLoyer.cdmsy = NmUsrUse
            .*/
        end.
        assign
            //revtrt.dtcsy     = ttHistoriqueRevisionLoyer.
            //revtrt.hecsy     = ttHistoriqueRevisionLoyer.
            //revtrt.cdcsy     = ttHistoriqueRevisionLoyer.
            //revtrt.dtmsy     = ttHistoriqueRevisionLoyer.
            //revtrt.hemsy     = ttHistoriqueRevisionLoyer.
            //revtrt.cdmsy     = ttHistoriqueRevisionLoyer.
            revtrt.inotrtrev = ttHistoriqueRevisionLoyer.iNumeroTraitementRevision
            revtrt.tpcon     = ttHistoriqueRevisionLoyer.cTypeContrat
            revtrt.nocon     = ttHistoriqueRevisionLoyer.iNumeroContrat
            revtrt.cdtrt     = ttHistoriqueRevisionLoyer.cCodeTraitement
            revtrt.notrt     = ttHistoriqueRevisionLoyer.iNumeroTraitement
            revtrt.cdact     = ttHistoriqueRevisionLoyer.cCodeAction
            //revtrt.cdsta     = ttHistoriqueRevisionLoyer.
            revtrt.dtdeb     = ttHistoriqueRevisionLoyer.daDateReference
            revtrt.dtfin     = ttHistoriqueRevisionLoyer.daDateAction
            revtrt.lbcom     = ttHistoriqueRevisionLoyer.cLibelleCommentaires
            revtrt.mtloyann  = ttHistoriqueRevisionLoyer.dMontantAnnuel
            revtrt.fgloyref  = ttHistoriqueRevisionLoyer.lLoyerReference
            revtrt.msqtt     = ttHistoriqueRevisionLoyer.iPeriodeQuittancement
            revtrt.cdirv     = ttHistoriqueRevisionLoyer.iCodeIndiceRevision
            revtrt.anirv     = ttHistoriqueRevisionLoyer.iAnneeIndice
            revtrt.noirv     = ttHistoriqueRevisionLoyer.iNumeroPeriodAnnee
            revtrt.vlirv     = ttHistoriqueRevisionLoyer.dValeurIndice
            revtrt.tprol     = ttHistoriqueRevisionLoyer.cTypeRoleDemandeur
            revtrt.norol     = ttHistoriqueRevisionLoyer.iNumeroRoleDemandeur
            //revtrt.NoEve     = ttHistoriqueRevisionLoyer.
            revtrt.fghis     = ttHistoriqueRevisionLoyer.lTraitementHistorise
            revtrt.dthis     = ttHistoriqueRevisionLoyer.daTermineLe
            revtrt.usrhis    = ttHistoriqueRevisionLoyer.cHistorisePar
            revtrt.tphis     = ttHistoriqueRevisionLoyer.cMotifFin
            //revtrt.lbdiv     = ttHistoriqueRevisionLoyer.
            //revtrt.lbdiv2    = ttHistoriqueRevisionLoyer.
            //revtrt.lbdiv3    = ttHistoriqueRevisionLoyer.
        .
    end.
    // 3) Fichiers joints  --  GED ??? npo
    //if ttHistoriqueRevisionLoyer.cTypeContrat = {&TYPECONTRAT-bail} then  /* NP 0413/0033 */
        //run RevTrt-Fichiers-Joints (buffer ttFichierJointRevision).

end procedure.

procedure createHistoriqueRevision private:
    /*------------------------------------------------------------------------------
    Purpose: Création d'une trace des traitements dans l'historique (revhis)
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer revtrt for revtrt.

    define variable viProchainHisto as integer no-undo initial 1.
    define buffer revhis for revhis.

    {&_proparse_ prolint-nowarn(wholeindex)}
    find last revhis no-lock no-error.
    if available revhis then viProchainHisto = revhis.nohis + 1.
    create revhis.
    buffer-copy revtrt to revhis
        assign
            revhis.nohis = viProchainHisto
    .
end procedure.

procedure initTacheRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose:     Purpose: Création automatique de la tache sans afficher l'écran
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheRevisionLoyer.
    define buffer ctrat for ctrat.

    if can-find(last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-revision})
    then do:
        mError:createError({&error}, 1000410).   // Demande d'initialisation pour une tache deja existante
        return.
    end.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run chargeCombo.
    run InfoParDefautRevisionLoyer(buffer ctrat).

end procedure.

procedure creationAutoRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose: creation automatique de la tache sans afficher l'écran (Relocation ALLZ) 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define buffer tache for tache.
    define buffer ctrat for ctrat.

    if can-find(last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-revision})
    then do:
        mError:createError({&error}, 1000412).  // création d'une tache déjà existante
        return.
    end.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run chargeCombo.
    run InfoParDefautRevisionLoyer(buffer ctrat).
    if mError:erreur() then return.

    // Lancement de la verification des zones
    run controleTacheRevisionLoyer(buffer ttTacheRevisionLoyer).
    if mError:erreur() then return.

    // MAJ des tables
    run majTacheRevision(buffer ttTacheRevisionLoyer, "INIT").
end procedure.

procedure InfoParDefautRevisionLoyer private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttTacheRevisionLoyer avec les informations par defaut pour creation de la tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable voCollection             as class collection no-undo.
    define variable vcListeValeursMensuelles as character no-undo.
    define variable viBoucle                 as integer   no-undo.
    define variable voDefautBail             as class parametrageDefautBail no-undo.
    define variable voRelocation             as class parametrageRelocation no-undo.
    define variable vhProcIndiceCRUD         as handle    no-undo.
    define variable vdaProchaineRevision     as date      no-undo.
    define variable vcCodeIndexBaisse        as character no-undo.

    define buffer offlc    for offlc.
    define buffer location for location.
    define buffer indrv    for indrv.
    define buffer lsirv    for lsirv.

    empty temp-table ttTacheRevisionLoyer.
    create ttTacheRevisionLoyer.
    assign
        ttTacheRevisionLoyer.iNumeroTache   = 0
        ttTacheRevisionLoyer.cTypeContrat   = ctrat.tpcon
        ttTacheRevisionLoyer.iNumeroContrat = ctrat.nocon
        ttTacheRevisionLoyer.cTypeTache     = {&TYPETACHE-revision}
        ttTacheRevisionLoyer.iChronoTache   = 0
        ttTacheRevisionLoyer.CRUD           = 'C'
    .
    // Recherche de tous les paramètres d'initialisation
    run chercheParametres(ctrat.nocon, ctrat.tpcon, output voCollection).
    // NP 0516/0190 : Forçage avec le paramétrage par défaut si pré-bail
    if ttTacheRevisionLoyer.cTypeContrat = {&TYPECONTRAT-preBail}
    then do:
        run RchIdxBaisse(ctrat.ntcon, output vcCodeIndexBaisse).
        if vcCodeIndexBaisse <> "00000" then ttTacheRevisionLoyer.cCodeIndexationAlaBaisse = vcCodeIndexBaisse.
    end.
    //  Init Variation de l'indice
    assign
        ttTacheRevisionLoyer.cPourcentageVariation  = "100"
        ttTacheRevisionLoyer.cCodeModeCalcul        = "00000"       // entry 1 de la combo
        ttTacheRevisionLoyer.daDebutPeriodeRevision = ctrat.dtdeb   // Récupération de la Date de Début du Contrat
    .
    // Recherche du montant du loyer
    find first offlc no-lock
        where offlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and offlc.nocon = int64(truncate(ttHistoriqueRevisionLoyer.iNumeroContrat / 100000, 0))
          and offlc.noapp = integer(truncate(ttHistoriqueRevisionLoyer.iNumeroContrat modulo 100000 / 100, 0)) no-error .
    if available offlc then do:
        vcListeValeursMensuelles = "".
        do viBoucle = 1 to 6:
            vcListeValeursMensuelles = vcListeValeursMensuelles + '@' + string(offlc.tbfam[viBoucle]).
        end.
        assign
            vcListeValeursMensuelles                  = substring(vcListeValeursMensuelles, 2)
            ttTacheRevisionLoyer.dMontantLoyerEncours = decimal(entry(1, vcListeValeursMensuelles, "@"))
        .
    end.
    else ttTacheRevisionLoyer.dMontantLoyerEncours = 0.

    run adblib/indiceRevision_CRUD.p persistent set vhProcIndiceCRUD.
    run getTokenInstance in vhProcIndiceCRUD(mToken:JSessionId).
    // Recherche des parametres par defaut du bail
    voDefautBail = new parametrageDefautBail(ctrat.ntcon).
    if voDefautBail:isDbParameter
    then do:
        assign 
            ttTacheRevisionLoyer.iPeriodiciteIndexation = integer(entry(3, voDefautBail:zon06, separ[1]))
            ttTacheRevisionLoyer.cCodeTypeIndiceCourant = entry(4, voDefautBail:zon06, separ[1])
         .
        for last lsirv no-lock
            where lsirv.cdirv = integer(ttTacheRevisionLoyer.cCodeTypeIndiceCourant):
            ttTacheRevisionLoyer.cLibelleTypeIndiceCourant = lsirv.lblng.
        end.
        // MAJ no indice
        for last indrv no-lock
            where indrv.cdirv = integer(ttTacheRevisionLoyer.cCodeTypeIndiceCourant):
            run getLibelleIndice in vhProcIndiceCRUD(indrv.cdirv, indrv.anper, indrv.noper, "l", output ttTacheRevisionLoyer.cLibelleIndiceCourant).
        end.
    end.
    delete object voDefautBail.
    
    // Ajout Sy le 18/02/2009 : AGF RELOCATIONS : initialisation avec Fiche relocation
    voRelocation  = new parametrageRelocation().
    if voRelocation:isActif() then do:
        // Recherche fiche de relocation
        find last location no-lock
            where location.tpcon  = {&TYPECONTRAT-mandat2Gerance}
              and location.nocon  = int64(truncate(ttHistoriqueRevisionLoyer.iNumeroContrat / 100000, 0))
              and location.noapp  = integer(truncate(ttHistoriqueRevisionLoyer.iNumeroContrat modulo 100000 / 100, 0))
              and location.fgarch = no no-error.
        if available location then do:  
            assign 
                ttTacheRevisionLoyer.iPeriodiciteIndexation = location.rev-nbdur
                ttTacheRevisionLoyer.cCodeTypeIndiceCourant = string(location.cdirv)
            .
            for last lsirv no-lock
                where lsirv.cdirv = integer(ttTacheRevisionLoyer.cCodeTypeIndiceCourant):
                ttTacheRevisionLoyer.cLibelleTypeIndiceCourant = lsirv.lblng.
            end.
            // MAJ no indice
            run getLibelleIndice in vhProcIndiceCRUD(location.cdirv, location.anper, location.noper, "l", output ttTacheRevisionLoyer.cLibelleIndiceCourant).                              
        end.    
    end.
    run destroy in vhProcIndiceCRUD.

    // Initialisation de la date prochaine révision à partir de la date d'effet du bail
    vdaProchaineRevision = ctrat.dtdeb.
    if ttTacheRevisionLoyer.iPeriodiciteIndexation > 0
    then do:
        do while vdaProchaineRevision <= ttTacheRevisionLoyer.daDebutPeriodeRevision:
            vdaProchaineRevision = date(month(vdaProchaineRevision), day(vdaProchaineRevision), year(vdaProchaineRevision) + ttTacheRevisionLoyer.iPeriodiciteIndexation).
        end.
        assign
            ttTacheRevisionLoyer.daProchaineRevision    = vdaProchaineRevision
            ttTacheRevisionLoyer.daDebutPeriodeRevision = date(month(vdaProchaineRevision), day(vdaProchaineRevision), year(vdaProchaineRevision) - ttTacheRevisionLoyer.iPeriodiciteIndexation)
        .
    end.

end procedure.

procedure calculPeriodeIndice private:
    /*------------------------------------------------------------------------------
    Purpose: Calcul des infos de l'indice
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pdaDateReference as date     no-undo.
    define output parameter piAnneeIndice    as integer  no-undo.
    define output parameter piNumeroPeriode  as integer  no-undo.

    define variable viMoisIndice as integer no-undo.

    if pdaDateReference = ? then return.

    piAnneeIndice = year(pdaDateReference) no-error.
    viMoisIndice  = month(pdaDateReference) no-error.
    case viMoisIndice:
        when 01 or when 02 or when 03 then piNumeroPeriode = 01.
        when 04 or when 05 or when 06 then piNumeroPeriode = 02.
        when 07 or when 08 or when 09 then piNumeroPeriode = 03.
        when 10 or when 11 or when 12 then piNumeroPeriode = 04.
    end case.   

end procedure.

procedure HistProc private:
    /*------------------------------------------------------------------------------
    Purpose: maj ttHistoriqueRevisionLoyer
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttHistoriqueRevisionLoyer for ttHistoriqueRevisionLoyer.
    
    define buffer vbttHistoriqueRevisionLoyer for ttHistoriqueRevisionLoyer.
    
    for each vbttHistoriqueRevisionLoyer
        where vbttHistoriqueRevisionLoyer.cTypeContrat          = ttHistoriqueRevisionLoyer.cTypeContrat
          and vbttHistoriqueRevisionLoyer.iNumeroContrat        = ttHistoriqueRevisionLoyer.iNumeroContrat
          and vbttHistoriqueRevisionLoyer.cCodeTraitement       = ttHistoriqueRevisionLoyer.cCodeTraitement
          and vbttHistoriqueRevisionLoyer.iNumeroTraitementTemp = ttHistoriqueRevisionLoyer.iNumeroTraitementTemp:
        assign
            vbttHistoriqueRevisionLoyer.lTraitementHistorise = yes
            vbttHistoriqueRevisionLoyer.daTermineLe          = ttHistoriqueRevisionLoyer.daDateAction   // date de la dernière action de la procédure
            vbttHistoriqueRevisionLoyer.cHistorisePar        = mToken:cUser
            vbttHistoriqueRevisionLoyer.cMotifFin            = ttHistoriqueRevisionLoyer.cCodeAction    // dernière action (Accord, jugement final...)
        .
    end.

end procedure.

procedure RchIdxBaisse private:
    /*------------------------------------------------------------------------------
    Purpose: Procédure de recherche du paramétrage par défaut de l'indexation à la baisse
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeNatureBail  as character    no-undo.
    define output parameter pcCodeIndexBaisse as character    no-undo.

    define buffer pclie for pclie.

    // TODO  Utiliser parametrage pclie. On utilise le paramètre de la tâche révision 'Indexation à la baisse' sinon NORMAL
    for first pclie no-lock    
        where pclie.tppar = "REVBA"
          and pclie.zon01 = "00001":
        pcCodeIndexBaisse = if isNatureCommercial(pcCodeNatureBail)
                            then pclie.zon03     // Commerciaux
                            else pclie.zon04.    // Habitation
    end.

end procedure.

procedure RchDatesContrat private:
    /*------------------------------------------------------------------------------
    Purpose: Procédure de recherche des dates concernant le contrat
    Notes  : Dates utilisées lors des controles
    TODO  A SUPPRIMER? Procédure non utilisée.
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.
    define output parameter pdaDateCreateBail as date no-undo.
    define output parameter pdaDateLastTrf    as date no-undo.
    define output parameter pdaDateFinContrat as date no-undo.

    define buffer tache   for tache.
    define buffer svtrf   for svtrf.

    define variable vcCodeTermeLocataire as character no-undo.
    define variable vhProcTransfert      as handle    no-undo.
    define variable viGlMoiMdf           as integer   no-undo.
    define variable viGlMoiMEc           as integer   no-undo.
    define variable viGlMflMdf           as integer   no-undo.
    define variable viMsMoiMdf           as integer   no-undo.
    define variable voCollection         as class collection no-undo.
    define variable voCollectionQuit     as class collection no-undo.
    define variable voCollectionQuitFL   as class collection no-undo.

     // Recherche si locataire Avance ou Echu  (PEC:on ne sait pas encore si Avance ou échu)
    vcCodeTermeLocataire = "00001".
    find last tache no-lock 
        where tache.tpcon = ctrat.tpcon
          and tache.nocon = ctrat.nocon
          and tache.tptac = {&TYPETACHE-quittancement} no-error.   
    if available tache then vcCodeTermeLocataire = tache.ntges.
    // Recherche de tous les paramètres d'initialisation
    run chercheParametres(ctrat.nocon, ctrat.tpcon, output voCollection).
    run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert.
    run getTokenInstance in vhProcTransfert(mToken:JSessionId).
    voCollectionQuit = new collection().
    //voCollectionQuit:set("cCodeTraitement", "QUIT").
    run getInfoTransfert in vhProcTransfert("QUIT", input-output voCollectionQuit).
    voCollectionQuitFL = new collection().
    //voCollectionQuitFL:set("cCodeTraitement", "QUITFL").
    run getInfoTransfert in vhProcTransfert("QUFL", input-output voCollectionQuitFL).
    assign
        viGlMoiMdf     = voCollectionQuit:getInteger("iMoisModifiable")
        viGlMoiMEc     = voCollectionQuit:getInteger("iMoisMEchu")
        viGlMflMdf     = voCollectionQuitFL:getInteger("iMoisModifiable")
        pdaDateLastTrf = 01/01/1990
    .
    if valid-handle(vhProcTransfert) then run destroy in vhProcTransfert.
    // Mois modifiable de quittancement
    if  voCollection:getLogical('lFlagBailFourniLoyer') and voCollection:getLogical('lFournisseurLoyer')
    then viMsMoiMdf = viGlMflMdf.
    else if vcCodeTermeLocataire = "00002"
         then viMsMoiMdf = viGlMoiMEc.
         else viMsMoiMdf = viGlMoiMdf.
    /*---------------------------------------------------------------------*
     | Recherche Date et Heure de transfert du 1er quittancement précédent |
     | (= date de cr‚ation du suivi du quitt)                              |
     *---------------------------------------------------------------------*/
    find last svtrf no-lock
        where svtrf.cdtrt = "QUIT"
          and svtrf.noord > 0
          and svtrf.mstrt = viMsMoiMdf
          and svtrf.nopha = "N00" no-error.
    if available svtrf then pdaDateLastTrf = svtrf.dttrf.
    assign
        pdaDateCreateBail = if ctrat.dtcsy <> ? then ctrat.dtcsy else ctrat.dtini
        pdaDateFinContrat = ctrat.dtfin
    .
    run destroy in vhProcTransfert.

end procedure.

procedure reCalculQuittances private:
    /*------------------------------------------------------------------------------
    Purpose: Recalcul des quittances (au cas où il y aurait une révision à faire)
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.

    define buffer tache for tache.

    define variable voCollection    as class collection no-undo.
    define variable voGlobalCollection as class collection no-undo.
    define variable vhProcTransfert as handle no-undo.
    define variable vhProcQuitt     as handle no-undo.

    // Ajout SY le 04/11/2010 : suite au passage en "Direct" de la tache, report des traitements spécifiques de synbxrev.p
    // 0008 | 15/10/2003 | SY : Fiche 0603/0083 : ajout recalcul/maj des quittances afin de prendre en compte une éventuelle révision à effectuer

    run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert.
    run getTokenInstance in vhProcTransfert(mToken:JSessionId).
    voGlobalCollection = new collection().
    run getInfoTransfert in vhProcTransfert("QUIT", input-output voGlobalCollection).
    // Recherche de tous les paramètres d'initialisation
    run chercheParametres(piNumeroContrat, pcTypeContrat, output voCollection).
    // Recherche param pour déclenchement révision
    if  (voCollection:getLogical('lDeclenchementRevision') = true) 
    then do:
        // Recherche si revision automatique
        // Si oui : recalcul quittances (au cas où il y aurait une révision à faire)
        find last tache no-lock
            where tache.tptac = {&TYPETACHE-revision}
              and tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat no-error.
        if available tache and tache.tphon = "NO"
        then do:
            if pcTypeContrat = {&TYPECONTRAT-prebail}
            then run bail/quittancement/quittanceEncours.p persistent set vhProcQuitt.  // Recalcul quittances/Maj equit
            run getTokenInstance in vhProcQuitt (mToken:JSessionId).
            // Chargement de TOUTES les Quittances + MajLocQt.p
            run getListeQuittance in vhProcQuitt(if pcTypeContrat = {&TYPECONTRAT-prebail} then {&TYPEROLE-candidatLocataire}
                                                                                           else {&TYPEROLE-locataire},
                                                 piNumeroContrat, 
                                                 voGlobalCollection,
                                                 output table ttQtt by-reference, 
                                                 output table ttRub by-reference)
            .
            if valid-handle(vhProcQuitt)     then run destroy in vhprocQuitt.
            if valid-handle(vhProcTransfert) then run destroy in vhProcTransfert.
            
            /*{RunPgExp.i &Path      = RpRunQtt
                          &Prog      = "'chglocqt.p'"
                          &Parameter = "INPUT TpRolUse, INPUT NoCttUse, OUTPUT LbTmpPdt"}*/
        end.
    end.

end procedure.
