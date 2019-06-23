/*------------------------------------------------------------------------
File        : bail.p
Purpose     :
Author(s)   : SPo - 20/01/2017
Notes       :
derniere revue: 2018/05/04 - phm: OK
----------------------------------------------------------------------*/
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/nature2voie.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/referenceClient.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2telephone.i}
{preprocesseur/type2role.i}
{preprocesseur/type2occupant.i}
{preprocesseur/unite2surface.i}

using parametre.pclie.parametrageComptabilisationEchus.
using parametre.pclie.parametragePeriodiciteQuittancement.
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/bail.i}
{bail/include/outilbail.i}    // fonctions isBailCommercial, donneCategorieBail, isBailResilie

function rubLoyer returns decimal private(piRubriqueQuittancement as integer, pdMontantRubrique as decimal):
    /*------------------------------------------------------------------------------
    Purpose: filtre rubrique loyer
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer rubqt for rubqt.

    /* récupération du genre de la rubrique */
    find first rubqt no-lock
        where rubqt.cdrub = piRubriqueQuittancement
          and rubqt.cdlib > 0 no-error.
    if not available rubqt
    or rubqt.cdgen = {&GenreRubqt-Variable}                                        /* On ne prend pas la rubrique variable */
    or (rubqt.cdgen <> {&GenreRubqt-Fixe} and rubqt.cdsig > {&SigneRubqt-Negatif}) /* On ne prend rubrique autre que fixe si Positif (ex : 111,116) ou negatif (ex : 112)  (pas Rappel/Avoir...) */
    or rubqt.cdrub = {&RubriqueQuitt-Franchise}                                    /* On ne prend pas la Franchise */
    then return 0.

    /* on ne prend que la famille 01 - Loyer et 04 - Sfa 06 Redevance soumise à TVA */
    if (rubqt.cdfam = {&FamilleRubqt-Loyer}         and rubqt.cdsfa <> {&SousFamilleRubqt-ChargeForfaitaire})
    or (rubqt.cdfam = {&FamilleRubqt-Administratif} and rubqt.cdsfa = {&SousFamilleRubqt-RedevanceSoumiseTVA})
    then do:
        if rubqt.cdfam = {&FamilleRubqt-Loyer}
        then case rubqt.cdsfa:
            /* On ne prend pas les équipements sauf pour ALLIANZ (ex : 120) */
            when {&SousFamilleRubqt-Equipement}
                then if mtoken:cRefGerance <> "{&REFCLIENT-ALLIANZ}" and mtoken:cRefGerance <> "{&REFCLIENT-ALLIANZRECETTE}" then return 0.
            /* On ne prend pas l'APL sauf pour ALLIANZ (ex : 130,135) */
            when {&SousFamilleRubqt-APL}
                then if mtoken:cRefGerance <> "{&REFCLIENT-ALLIANZ}" and mtoken:cRefGerance <> "{&REFCLIENT-ALLIANZRECETTE}" then return 0.
            /* Spécifique St Victor: sauf Autre loyer */ /* ajout SY le 24/03/2016 c.f. fiche 0610/0146 */
            when {&SousFamilleRubqt-AutreLoyer}
                then if mtoken:cRefGerance = "{&REFCLIENT-SAINT-VICTOR}" then return 0.
        end case.
        return pdMontantRubrique.
    end.
    /* On ne prend pas les charges sauf pour ALLIANZ la Rub 404 Indemnité complémentaire prestation */
    else if rubqt.cdfam = {&FamilleRubqt-Charge} and rubqt.cdsfa = {&SousFamilleRubqt-ChargeDiverse}
        and rubqt.cdrub = {&RubriqueQuitt-IndemniteComplementairePrestation}
        and (mtoken:cRefGerance = "{&REFCLIENT-ALLIANZ}" or mtoken:cRefGerance = "{&REFCLIENT-ALLIANZRECETTE}")
    then return pdMontantRubrique.
    return 0.

end function.

function rubCharge returns decimal private(piRubriqueQuittancement as integer, pdMontantRubrique as decimal):
    /*------------------------------------------------------------------------------
    Purpose: filtre rubrique charge
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer rubqt for rubqt.

    /* récupération du genre de la rubrique */
    find first rubqt no-lock
        where rubqt.cdrub = piRubriqueQuittancement
          and rubqt.cdlib > 0 no-error.
    if not available rubqt
    or rubqt.cdgen = {&GenreRubqt-Variable}                                        /* On ne prend pas la rubrique variable */
    or (rubqt.cdgen <> {&GenreRubqt-Fixe} and rubqt.cdsig > {&SigneRubqt-Negatif}) /* On ne prend rubrique autre que fixe si Positif (ex : 111,116) ou negatif (ex : 112)  (pas Rappel/Avoir...) */
    then return 0.

    /* on ne prend que la famille 02 - Charges  */
    /* mais pour ALLIANZ la Rub 404 Indemnité complémentaire prestation est une rubrique de Loyer */
    if rubqt.cdfam = {&FamilleRubqt-Charge}
    and not (rubqt.cdrub = {&RubriqueQuitt-IndemniteComplementairePrestation}
    and (mtoken:cRefGerance = "{&REFCLIENT-ALLIANZ}" or mtoken:cRefGerance = "{&REFCLIENT-ALLIANZRECETTE}"))
    then return pdMontantRubrique.

    return 0.
end function.

function rubSurLoyer returns decimal(piRubriqueQuittancement as integer, pdMontantRubrique as decimal):
    /*------------------------------------------------------------------------------
    Purpose: filtre rubrique complément loyer
    Notes  : todo: pas utilisée
    ------------------------------------------------------------------------------*/
    case piRubriqueQuittancement:
        when {&RubriqueQuitt-SurLoyer} then return pdMontantRubrique.
    end case.
    return 0.
end function.

function rubMeh returns decimal(piRubriqueQuittancement as integer, pdMontantRubrique as decimal):
    /*------------------------------------------------------------------------------
    Purpose: filtre rubrique majoration loyer
    Notes  : todo: pas utilisée
    ------------------------------------------------------------------------------*/
    case piRubriqueQuittancement:
         when {&RubriqueQuitt-MajorationLoyerMEH}
      or when {&RubriqueQuitt-RappelouAvoirMajorationLoyerMEH}
      or when {&RubriqueQuitt-RappelouAvoirRevisionMajorationLoyerMEH} then return pdMontantRubrique.
    end case.
    return 0.
end function.

procedure getMoisQuittancement :
    /*------------------------------------------------------------------------------
    Purpose: Récupération du mois de quittancement en cours et suivant
    Notes  : Service appelé par tachePNO.p
    ------------------------------------------------------------------------------*/
    define output parameter piErreur   as integer no-undo.
    define output parameter piGlMoiQtt as integer no-undo.
    define output parameter piGlMoiMdf as integer no-undo.
    define output parameter piGlMoiMEc as integer no-undo.

    define variable viPeriodiciteQuittancement as integer no-undo.   // 1 mois, 3 mois
    define variable viNoAnnPrc                 as integer no-undo.
    define variable viNoMoiPrc                 as integer no-undo.
    define variable viMoisPrec                 as integer no-undo.
    define variable voComptabilisationEchus    as class parametrageComptabilisationEchus    no-undo.
    define variable voPeriodiciteQuittancement as class parametragePeriodiciteQuittancement no-undo.

    define buffer svtrf for svtrf.

    // Recherche si Quittancement Trimestriel
    assign
        voPeriodiciteQuittancement = new parametragePeriodiciteQuittancement()
        viPeriodiciteQuittancement = if voPeriodiciteQuittancement:periodiciteQuittancement() = 3 then 3 else 1
    .
    delete object voPeriodiciteQuittancement.
    // Lecture Mois de quittancement en cours
    find first svtrf no-lock
        where svtrf.cdtrt = "QUIT"
          and svtrf.noord = 0 no-error.
    if not available svtrf then do:
        piErreur = 10. /* Pas Trouvé. */
        return.
    end.
    assign
        piGlMoiQtt = svtrf.mstrt
        // Lecture phases Mois de quittancement précédent pour Recherche du premier mois modifiable standard et échus
        viNoAnnPrc  = truncate(piGlMoiQtt / 100, 0)
        viNoMoiPrc  = piGlMoiQtt modulo 100 - viPeriodiciteQuittancement
    .
    if viNoMoiPrc < 1
    then assign
        viNoAnnPrc = viNoAnnPrc - 1
        viNoMoiPrc = viNoMoiPrc + 12
    .
    assign
        viMoisPrec = viNoAnnPrc * 100 + viNoMoiPrc
        piGlMoiMdf = piGlMoiQtt
        piGlMoiMEc = piGlMoiQtt
    .
boucle:
    for each svtrf no-lock
        where svtrf.cdtrt = "QUIT"
          and svtrf.noord > 0
          and svtrf.mstrt = viMoisPrec
          and svtrf.ettrf = "F"   /* transfert Fini */
        by svtrf.nopha descending:
        /* Mois précédent terminé */
        if svtrf.nopha = "N99" then leave boucle.

        if svtrf.nopha = "N98" then do:
            /* Mois précédent terminé pour les échus, Modifiable en standard */
            piGlMoiMdf = viMoisPrec.
            leave boucle.
        end.
        assign   /* Mois précédent pas encore validé */
            piGlMoiMdf = viMoisPrec
            piGlMoiMEc = viMoisPrec
        .
    end.
    // Recherche si Validation séparée des échus
    voComptabilisationEchus = new parametrageComptabilisationEchus().
    if not voComptabilisationEchus:isValidationEchuSepare() then piGlMoiMEc = piGlMoiMdf.
    delete object voComptabilisationEchus.
end procedure.

procedure getMoisQuittancementInvestisseur private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération du mois de quittancement investisseur en cours et suivant
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter piErreur   as integer no-undo.
    define output parameter piGlMflQtt as integer no-undo.
    define output parameter piGlMflMdf as integer no-undo.

    define variable viNoAnnPrc as integer no-undo.
    define variable viNoMoiPrc as integer no-undo.
    define variable viMoisPrec as integer no-undo.
    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

    define buffer svtrf for svtrf.
    
    // Lecture Mois de quittancement en cours
    find first svtrf no-lock
        where svtrf.cdtrt = "QUFL"
          and svtrf.noord = 0 no-error.
    if not available svtrf then do:
        piErreur = 10. /* Pas Trouvé. */
        return.
    end.
    assign
        voFournisseurLoyer = new parametrageFournisseurLoyer()
        piGlMflQtt         = svtrf.mstrt
        // Lecture phases Mois de quittancement précédent pour Recherche du premier mois modifiable standard et échus
        viNoAnnPrc         = truncate(piGlMflQtt / 100, 0)
        viNoMoiPrc         = piGlMflQtt modulo 100 - voFournisseurLoyer:getNombreMoisQuittance()  //Recherche si Quittancement Trimestriel
    .
    delete object voFournisseurLoyer.
    if viNoMoiPrc < 1
    then assign
        viNoAnnPrc = viNoAnnPrc - 1
        viNoMoiPrc = viNoMoiPrc + 12
    .
    assign
        viMoisPrec = viNoAnnPrc * 100 + viNoMoiPrc
        piGlMflMdf = piGlMflQtt
    .
boucle:
    for each svtrf no-lock
        where svtrf.cdtrt = "QUFL"
          and svtrf.noord > 0
          and svtrf.mstrt = viMoisPrec
          and svtrf.ettrf = "F"   /* transfert Fini */
        by svtrf.nopha descending:
        if svtrf.nopha = "N99" then leave boucle.  /* Mois précédent terminé */

        piGlMflMdf = viMoisPrec.                   /* Mois précédent pas encore validé */
    end.

end procedure.

procedure readBail:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des infos du bail
    Notes  : service utilisé par beBail.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter table for ttBail.

    /* Visualisation de la date expiration contrat ou tache renouvellement (04160) */
    define variable vlVisExp         as logical no-undo initial true.
    define variable viNbMoisPeriode  as integer no-undo.
    define variable vdCoeffPeriode   as decimal no-undo.
    define variable viBoucle         as integer no-undo.
    define variable viNumeroRubrique as integer no-undo.
    define variable vdMontantLoyer   as decimal no-undo.
    define variable vdMontantCharge  as decimal no-undo.
    define variable viNumeroErreur   as integer no-undo.
    define variable viGlMoiQtt       as integer no-undo.
    define variable viGlMoiMdf       as integer no-undo.
    define variable viGlMoiMec       as integer no-undo.
    define variable viGlMflQtt       as integer no-undo.
    define variable viGlMflMdf       as integer no-undo.

    define buffer ctrat     for ctrat.
    define buffer vbCtrat   for ctrat.
    define buffer tache     for tache.
    define buffer aquit     for aquit.
    define buffer equit     for equit.
    define buffer vbTacheQuittancement  for tache.
    define buffer vbTacheRevision       for tache.
    define buffer vbTacheRenouvellement for tache.

    empty temp-table ttBail.
    // Recherche mois de quittancement en cours locataires
    run getMoisQuittancement(output viNumeroErreur, output viGlMoiQtt, output viGlMoiMdf, output viGlMoiMec).
    // Recherche mois de quittancement en cours fournisseurs de loyer (investisseurs)
    run getMoisQuittancementInvestisseur(output viNumeroErreur, output viGlMflQtt, output viGlMflMdf).

    for each ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        create ttBail.
        assign
            ttBail.cTypeContrat             = ctrat.tpcon
            ttBail.iNumeroContrat           = ctrat.nocon
            ttBail.cLibelleTypeContrat      = outilTraduction:getLibelleProg("O_CLC", ctrat.tpcon)
            ttBail.cCodeNatureContrat       = ctrat.ntcon
            ttBail.cLibelleNatureContrat    = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            ttBail.daDateSignature          = ctrat.dtsig
            ttBail.daDateDebut              = ctrat.dtdeb      /* Date début contrat - effet */
            ttBail.daDateFin                = ctrat.dtfin
            ttBail.daDateInitiale           = ctrat.dtini
            ttBail.daDateReelleFin          = ctrat.dtree
            ttBail.cMotifResiliation        = ctrat.tpfin     /* motif de résiliation    */
            ttBail.cLibelleMotifResiliation = outilTraduction:getLibelleParam("TPMOT", ctrat.tpfin)
            ttBail.daDateCreation           = ctrat.dtcsy
            ttBail.cNumeroReel              = ctrat.noree      /* Numéro réel du contrat - Registre */
            ttBail.cCodeExterne             = ctrat.cdext      /* code client    */
            ttBail.lresiliationTriennale    = ctrat.fgrestrien
            ttBail.CRUD                     = 'R'
            ttBail.dtTimestamp              = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttBail.rRowid                   = rowid(ctrat)
        .
        for last vbTacheRenouvellement no-lock
            where vbTacheRenouvellement.tpcon = ctrat.tpcon
              and vbTacheRenouvellement.nocon = ctrat.nocon
              and vbTacheRenouvellement.tptac = {&TYPETACHE-renouvellement}:
            /*--> Date d'expiration theorique / invisible */
            case vbTacheRenouvellement.tpfin:
                when "00" then vlVisExp = true.
                when "10" then vlVisExp = false.
                when "20" then vlVisExp = false.
                when "30" then vlVisExp = false.
                when "40" then vlVisExp = false.
                when "50" then vlVisExp = true.
            end case.
            if not vlVisExp then ttBail.daDateFin = vbTacheRenouvellement.dtfin.
        end.
        for last vbTacheQuittancement no-lock
            where vbTacheQuittancement.tpcon = ctrat.tpcon
              and vbTacheQuittancement.nocon = ctrat.nocon
              and vbTacheQuittancement.tptac = {&TYPETACHE-quittancement}:
            assign
                ttBail.daDateEntree       = vbTacheQuittancement.dtdeb
                ttBail.daDateSortie       = vbTacheQuittancement.dtfin
                ttBail.cPeriodiciteQuitt  = vbTacheQuittancement.pdges
                ttBail.cTermeQuitt        = vbTacheQuittancement.ntges
                ttBail.cLibelleTermeQuitt = outilTraduction:getLibelleParam("TEQTT", vbTacheQuittancement.ntges).
            .
            if length(vbTacheQuittancement.pdges, 'character') = 5 then assign
                ttBail.iNombreMoisQuitt = integer(substring(vbTacheQuittancement.pdges, 1, 3, 'character'))
                ttBail.iNumeroMoisDebut = integer(substring(vbTacheQuittancement.pdges, 4, 2, 'character'))
            .
        end.
        for last vbTacheRevision no-lock
            where vbTacheRevision.tpcon = ctrat.tpcon
              and vbTacheRevision.nocon = ctrat.nocon
              and vbTacheRevision.tptac = {&TYPETACHE-revision}:
            ttBail.daDateDerniereRevision = vbTacheRevision.dtdeb.
        end.
        for last tache no-lock
            where tache.tptac = {&TYPETACHE-loyerContractuel}
              and tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon:
            ttBail.dMontantLoyerContractuel = tache.mtreg.
        end.
        for first vbCtrat no-lock
            where vbCtrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and vbCtrat.nocon = integer(substring(string(ctrat.nocon, "9999999999"), 1, 5, 'character')):
            ttBail.lBailInvestisseur = vbCtrat.fgfloy.
        end.
        assign
            vdMontantLoyer  = 0
            vdMontantCharge = 0
        .
        /* dernière quittance historisée HORS facture locataire */
        {&_proparse_ prolint-nowarn(use-index)}
        find last aquit no-lock
            where aquit.noloc = ctrat.nocon
              and aquit.fgfac = false            // sauf facture locataire
            use-index ix_aquit03 no-error.       // trié par noloc, msqtt
        if available aquit then do:
            assign
                viNbMoisPeriode = if length(aquit.pdqtt, 'character') = 5 then integer(substring(aquit.pdqtt, 1, 3, 'character')) else ttBail.iNombreMoisQuitt
                vdMontantLoyer  = 0
            .
boucle:
            do viBoucle = 1 to aquit.nbrub:
                viNumeroRubrique = integer(entry(1, aquit.tbrub[viBoucle], "|")).
                if viNumeroRubrique = 0 then leave boucle.

                assign
                    vdMontantLoyer  = vdMontantLoyer  + rubLoyer(viNumeroRubrique,  decimal(entry(5, aquit.tbrub[viBoucle], "|")))
                    vdMontantCharge = vdMontantCharge + rubCharge(viNumeroRubrique, decimal(entry(5, aquit.tbrub[viBoucle], "|")))
                .
            end.
            assign
                ttBail.dMontantLoyer  = vdMontantLoyer
                ttBail.dMontantCharge = vdMontantCharge
            .
        end.    /* aquit */
        else for first equit no-lock
            where equit.noloc = ctrat.nocon
              and equit.msqtt >= (if ttBail.lBailInvestisseur then viGlMflMdf else viGlMoiMec):  /* AJout SY le 12/01/2015 pour ne pas prendre les Avis d'échéance périmés (Pb plantage PEC, equit non historisé) */
            viNbMoisPeriode = if length(equit.pdqtt, 'character') = 5 then integer(substring(equit.pdqtt, 1, 3, 'character')) else ttBail.iNombreMoisQuitt.
            do viBoucle = 1 to equit.nbrub:
                assign
                    viNumeroRubrique = equit.tbrub[viBoucle]
                    vdMontantCharge  = vdMontantCharge + RubCharge(viNumeroRubrique, equit.tbtot[viBoucle])
                .
            end.
        end.
        assign
            vdCoeffPeriode             = 12 / (if viNbMoisPeriode > 0 then viNbMoisPeriode else 1)
            ttBail.dMontantLoyerAnnuel = ttBail.dMontantLoyer * vdCoeffPeriode
        .
    end. // for each ctrat

end procedure.

procedure getCategorieBail:
    /*------------------------------------------------------------------------------
    Purpose: Récupération de la catégorie d'un bail donné (COM/HAB)
    Notes  : service externe (beBailGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroBail  as int64     no-undo.
    define input parameter pcTypeContrat as character no-undo.
    define output parameter table for ttEchangesBail.

    empty temp-table ttEchangesBail.
    
    // Stockage de l'information sur la catégorie de bail
    create ttEchangesBail.
    assign
        ttEchangesBail.cCode   = "CATEGORIE_BAIL"
        ttEchangesBail.cValeur = donneCategorieBail(pcTypeContrat,piNumeroBail)
    .

end procedure.
