/*------------------------------------------------------------------------
File        : quittancement.p
Purpose     :
Author(s)   : kantena  -  2017/11/29
Notes       : sylbxqtt.p
derniere revue: 2018/05/23 - phm: KO
        traduction
        todo
        ...
----------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/referenceClient.i}

using parametre.pclie.parametrageDefautBail.
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageImmobilierEntreprise.
using parametre.pclie.parametragePeriodiciteQuittancement.
using parametre.pclie.parametragePrelevementAutomatique.
using parametre.pclie.parametrageProlongationExpiration.
using parametre.pclie.parametrageRelocation.
using parametre.pclie.parametrageSEPA.
using parametre.syspg.syspg.
using parametre.syspr.parametrageMAD.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}
{bail/include/quittancement.i}
{bail/include/tmprub.i}
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/familleRubrique.i}
{adblib/include/rlctt.i}

define temp-table ttBanquePrelevement no-undo
    field cdBqu     as character
    field NoMDt     as integer
    field fmtprl    as character   /* Ajout SY le 15/01/2013 format prélèvements : CFONB /  SEPA */
    field fmtvir    as character   /* Ajout SY le 15/01/2013 futur format virements : CFONB /  SEPA */
    field fg-defaut as logical
.
    
function isFinMehaignerie returns logical private(
    pcTypeBail   as character,
    piNumeroBail as integer,
    piGlMoiMdf   as integer,
    piGlMoiMEc   as integer,
    piGlMoiQtt   as integer
):
/*------------------------------------------------------------------------
    Purpose:
    Notes:
  ----------------------------------------------------------------------*/
    define variable vdaFinMehaignerie as date    no-undo.
    define buffer equit for equit.
    define buffer Tache for Tache.

    /* Verification PEC de la tache Majoration MEH */
    if not can-find(first cttac no-lock
                    where cttac.tpcon = pcTypeBail
                      and cttac.nocon = piNumeroBail
                      and cttac.tptac = {&TYPETACHE-majorationMermaz}) then return false. /* Majoration mehaignerie */

    /* Recherche de la prochaine quittance du locataire  */
    {&_proparse_ prolint-nowarn(use-index)}
    find first equit no-lock
         where equit.noloc = piNumeroBail
          and ((equit.cdter = "00001" and equit.msqtt >= piGlMoiMdf)
            or (equit.cdter = "00002" and equit.msqtt >= piGlMoiMEc))
        use-index ix_equit03 no-error.
    if not available equit then return false.

    /* Recuperation des donn‚es dans la table TACHE */
    find last tache no-lock
        where tache.tpcon = pcTypeBail
          and tache.nocon = piNumeroBail
          and tache.tptac = {&TYPETACHE-majorationMermaz} no-error. /* Majoration mehaignerie */
    if not available tache then return false. /* Pas de tache Majoration mehaignerie */

    vdaFinMehaignerie = tache.dtfin.  /* Date de fin de la majoration MEH */
    /* Fin de majoration si date de fin dans la quittance en cours, ou depasse */
    if (equit.dtdpr <= vdaFinMehaignerie and vdaFinMehaignerie < equit.dtfpr)
    or vdaFinMehaignerie < equit.dtdpr then do:
        /*
           Si majoration s'arrete dans quittance du mois de quittance en cours
           ou majoration terminee avant la la prochaine quittance du locataire
        */
        if piGlMoiQtt >= equit.msqtt or vdaFinMehaignerie < equit.dtdpr then return true. /* Fin de MEHAIGNERIE effectuer*/ 
    end.
    return false.
end function.

function IsColocation returns logical private (pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
      Purpose:     
      Notes:       
    ------------------------------------------------------------------------------*/
    define buffer tache for tache.
    /* Ce bail est-il une colocation */
    for first tache no-lock 
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-Colocation}:
        if tache.tpges = "00001" then return true.  /* Gestion multiple des colocataires ? */
    end.
    return false.

end function.

function isDepotGarantie returns logical private (piNumeroContrat as integer, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: Test si la tache depot de garantie a ete creee
    Notes: reprise de la procédure interne EnaObjTch de prmobqtt_srv.p
    ------------------------------------------------------------------------------*/
    return can-find(first tache no-lock
                    where tache.tpcon = pcTypeContrat
                      and tache.nocon = piNumeroContrat 
                      and tache.tptac = {&TYPETACHE-depotGarantieBail}).

end function.

function getLibelleFamille returns character private(piCodeFamille as integer):
    /*------------------------------------------------------------------------------
      Purpose:   Procedure de recherche des libelles des familles
      Notes:
    ------------------------------------------------------------------------------*/
    define buffer famqt for famqt.

    for first famqt no-lock
        where famqt.cdfam = piCodeFamille
          and famqt.cdsfa = 0:
        return outilTraduction:getLibelle(famqt.nome1).
    end.
    return "".
end function.

function getFinApplicationMax returns date private(plTacheReconduction as logical, pdaFinBail as date, pdaSortieLocataire as date, pdaResiliationBail as date):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vdaFinApplicationMax as date    no-undo.
    define variable vlProlongation       as logical no-undo.
    define variable vdaFapCal            as date    no-undo.
    define variable voProlongationExpiration as class parametrageProlongationExpiration no-undo.

    /* Mode : prolongation du quittancement après expiration */
    assign
        voProlongationExpiration = new parametrageProlongationExpiration()
        vlProlongation           = voProlongationExpiration:isQuittancementProlonge()
    .
    delete object voProlongationExpiration.

    /* Specifique manpower */
    /* On ne tient pas compte de la date de fin de bail pour calculer la date de fin d'application de la rubrique */
    if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER}
    then assign
        pdaFinBail = 12/31/2299         /* Ajout SY le 14/10/2013 : 31/12/2299 */
        vdaFapCal  = pdaFinBail
    .
    else vdaFapCal = date(12, 31, year(pdaFinBail) + 2).

    if plTacheReconduction and vlProlongation and (vdaFapCal = ? or vdaFapCal < today)
    then vdaFapCal = 12/31/2950.

    /* Prendre la plus petite des dates de sorties */
    if pdaSortieLocataire <> ? and pdaResiliationBail <> ?
    then vdaFinApplicationMax = minimum(pdaSortieLocataire, pdaResiliationBail).
    else vdaFinApplicationMax = if pdaResiliationBail <> ? then pdaResiliationBail else pdaSortieLocataire.

    if not plTacheReconduction    /* Mode: Non Tacite Reconduction */
    then if vlProlongation 
         then vdaFinApplicationMax = if vdaFinApplicationMax = ? then 12/31/2950 else vdaFinApplicationMax.                      /* On garde la date de sortie si il en existe une*/
         else vdaFinApplicationMax = if vdaFinApplicationMax = ? then pdaFinBail else minimum(vdaFinApplicationMax, pdaFinBail). /* Mode : "Normal"*/
    else vdaFinApplicationMax = (if vdaFinApplicationMax = ? then vdaFapCal else vdaFinApplicationMax).
    return vdaFinApplicationMax.

end function.

procedure getQuittance:
    /*------------------------------------------------------------------------------
      Purpose: Procedure principale pour la récupération de la quittance
      Notes:   service appelé par beQuittancement.cls
    ------------------------------------------------------------------------------*/
    define input parameter poGlobalCollection as class collection no-undo.
    define input parameter poCollection       as class collection no-undo.
    define output parameter table for ttQuittancement.
    define output parameter table for ttFamilleRubrique.

    define variable vhttCollection as handle no-undo.
    define variable vhBuffer       as handle no-undo.

    run getIdentifiantQuittance(input-output poCollection).
    run getMontantQuittance    (poGlobalCollection, input-output poCollection).
    create ttQuittancement.
    assign 
        ttQuittancement.CRUD        = "R"
        ttQUittancement.dtTimestamp = now
    .
    poCollection:toTemptable(output table-handle vhttCollection).
    vhBuffer = vhttCollection:default-buffer-handle no-error.
    vhBuffer:find-first().
    outils:copyValidField(vhBuffer, temp-table ttQuittancement:default-buffer-handle).
    delete object poCollection.

end procedure.

procedure getParametrage:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes: Utilisée par beQuittancement.cls
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define output parameter table for ttQuittancement.

    define variable viNumeroContrat     as integer   no-undo.
    define variable vcTypeContrat       as character no-undo.
    define variable viNumeroMandat      as integer   no-undo.
    define variable viNumeroAppartement as integer   no-undo.
    define variable vhBuffer            as handle    no-undo.
    define variable vhttCollection      as handle    no-undo.
    
    assign
        viNumeroContrat     = poCollection:getInteger("iNumeroContrat")
        vcTypeContrat       = poCollection:getCharacter("cTypeContrat")
        viNumeroMandat      = truncate(viNumeroContrat / 100000, 0)
        viNumeroAppartement = truncate((viNumeroContrat modulo 100000) / 100, 0)  // integer(substring(string(viNumeroContrat, "9999999999"), 6 ,3))
    .
    poCollection:set("iNumeroMandat",      viNumeroMandat).
    poCollection:set("iNumeroAppartement", viNumeroAppartement).
    poCollection:set("lDepotGarantie",     isDepotGarantie(viNumeroContrat, vcTypeContrat)).

    run chargeProprietaire(input-output poCollection, viNumeroContrat, vcTypeContrat).
    run chargeBanqueMandat(viNumeroMandat). /* TEMP-TABLE ttBanquePrelevement */
    run chargeParametreGESFL(input-output poCollection).
    run chargeParemetrePeriodicite(input-output poCollection).
    run chargeParametreClientPrelevement(input-output poCollection).
    run chargeInfoRUM(input-output poCollection).
    run enaObjTch (input-output poCollection).
    run loadObjTch(input-output poCollection).
    create ttQuittancement.
    assign 
        ttQuittancement.CRUD        = "R"
        ttQUittancement.dtTimestamp = now
    .
    poCollection:toTemptable(output table-handle vhttCollection).
    vhBuffer = vhttCollection:default-buffer-handle no-error.
    vhBuffer:find-first().
    outils:copyValidField(vhBuffer, temp-table ttQuittancement:default-buffer-handle).
    delete object poCollection.

end procedure.

procedure getIdentifiantQuittance private:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes: Extrait de sylbqtt_srv.p
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection  as class collection no-undo.

    define variable vcTypeContrat          as character no-undo.
    define variable viNumeroRole           as integer   no-undo.
    define variable vcCodeModeReglement    as character no-undo.
    define variable vcLibelleReglement     as character no-undo.
    define variable viNombreJoursPrelevLoc as integer   no-undo.
    define variable vdaMaxQuittance        as date      no-undo.
    define variable vdaEntreeLocataire     as date      no-undo.
    define variable vcLibelleDateEntree    as character no-undo.
    define variable vdaSortieLocataire     as date      no-undo.
    define variable vcLibelleDateSortie    as character no-undo.
    define variable vdaDateDebut           as date      no-undo.
    define variable vdaDateFin             as date      no-undo.
    define variable vdaResiliationBail     as date      no-undo.
    define variable vdaFinBail             as date      no-undo.
    define variable vdaDateEmission        as date      no-undo.
    define variable vcCodePeriodicite      as character no-undo.
    define variable vcCodeTerme            as character no-undo.
    define variable vlTacheReconduction    as logical   no-undo initial true.
    define variable viNombreMoisAvance     as integer   no-undo.
    define variable vcCodeMoisPrelevLoc    as character no-undo.
    define variable viNumeroQuittance      as integer   no-undo.
    define variable vlpquit                as logical   no-undo.
    define variable vlequit                as logical   no-undo.
    define variable vlaquit                as logical   no-undo.
    define variable voPeriodiciteQuittancement as class parametragePeriodiciteQuittancement no-undo.
    define variable voPrelevementAutomatique   as class parametragePrelevementAutomatique   no-undo.
    define buffer aquit  for aquit.
    define buffer equit  for equit.
    define buffer pquit  for pquit.
    define buffer tache  for tache.
    define buffer iftsai for iftsai.
    define buffer ctrat  for ctrat.

    assign
        vcTypeContrat       = poCollection:getCharacter("cTypeContrat")
        viNumeroRole        = poCollection:getInteger("iNumeroRole")
        vcCodeModeReglement = {&MODEREGLEMENT-cheque}
    .
/*
    run _recupLibMulti
    ( input "100132,100040,100634,101644,100640,100641,100632,100642,100643,~
      100633,100095,107349,101690" /* CHARACTER */,
      output ret /* LOGICAL */).
*/
    /* Recherche des parametres de Qtt du Locataire. */
    for last tache no-lock
        where tache.tpcon = vcTypeContrat
          and tache.nocon = viNumeroRole
          and tache.tptac = {&TYPETACHE-quittancement}:
        assign 
            vdaEntreeLocataire     = tache.Dtdeb
            vdaSortieLocataire     = tache.DtFin
            vcCodeModeReglement    = tache.cdreg
            viNombreJoursPrelevLoc = tache.duree
            vcCodeMoisPrelevLoc    = tache.dcreg
            viNombreMoisAvance     = tache.nbmav
        .
    end.
    /* Recherche de la date de resiliation du bail */
    for first ctrat no-lock
        where ctrat.TpCon = vcTypeContrat
          and ctrat.NoCon = viNumeroRole:
        assign 
            vdaFinBail          = ctrat.DtFin
            vdaResiliationBail  = ctrat.DtRee
            vlTacheReconduction = (ctrat.TpRen = "00001") /* Info "Tacite Reconduction ?"*/
        .
    end.
    assign
        /* Calcul de la date de fin d'application maximum */
        vdaMaxQuittance     = getFinApplicationMax(vlTacheReconduction, vdaFinBail, vdaSortieLocataire, vdaResiliationBail) /* utilisation include vdaFapMax.i */
        /* Formatage de la date en lettres */
        vcLibelleDateEntree = if vdaEntreeLocataire <> ? then outilFormatage:getDateFormat(vdaEntreeLocataire, "L") else ""
        vcLibelleDateSortie = if vdaSortieLocataire <> ? then outilFormatage:getDateFormat(vdaSortieLocataire, "L") else ""
    .
    if lookup(vcCodeModeReglement, substitute('&1,&2', {&MODEREGLEMENT-especes}, {&MODEREGLEMENT-virement})) > 0
    then do:    /* SY 1013/0126 */
        /* Recherche du paramètre Cabinet des prélèvements */
        if viNombreJoursPrelevLoc = 0 or vcCodeMoisPrelevLoc = ""
        then voPrelevementAutomatique = new parametragePrelevementAutomatique().
        if viNombreJoursPrelevLoc = 0  then viNombreJoursPrelevLoc = voPrelevementAutomatique:getNombreJoursPrelevement().
        if viNombreJoursPrelevLoc > 0  then vcLibelleReglement = " " + string(viNombreJoursPrelevLoc).
        {&_proparse_ prolint-nowarn(weakchar)}
        if vcCodeMoisPrelevLoc    = "" then vcCodeMoisPrelevLoc = voPrelevementAutomatique:getCodeMoisPrelevement().
        if vcCodeMoisPrelevLoc    = "00001" 
        then vcLibelleReglement = vcLibelleReglement + outilTraduction:getLibelleParam("PRLOC", vcCodeMoisPrelevLoc, "C").
        delete object voPrelevementAutomatique no-error.
    end.

    if vcTypeContrat = {&TYPECONTRAT-preBail}
    then for first pquit no-lock
        where pquit.NoLoc = viNumeroRole:
        assign 
            vlpquit              = true
            viNumeroQuittance    = pquit.noqtt
            vdaDateDebut         = pquit.dtdeb
            vdaDateFin           = pquit.dtfin
            vcCodePeriodicite    = pquit.pdqtt
        .
    end.
    else do:
        {&_proparse_ prolint-nowarn(use-index)}
boucle:
        for each aquit no-lock
           where aquit.NoLoc = viNumeroRole
            and (aquit.fgfac = false or lookup(aquit.type-fac, "E,S") > 0)
            use-index ix_aquit10:                /* SY 18/06/2013 : Noloc + msqtt + noqtt */
            if aquit.num-int-fac <> 0
            then for first iftsai no-lock    /* rechercher la facture en compta*/
                where iftsai.soc-cd    = integer(mtoken:cRefGerance)
                  and iftsai.etab-cd   = integer(truncate(aquit.noloc / 100000, 0))   /* substring(string(aquit.noloc, "9999999999"), 1, 5)*/
                  and iftsai.tprole    = 19
                  and iftsai.sscptg-cd = substring(string(aquit.noloc, "9999999999"), 6, 5, "character")
                  and iftsai.fg-edifac
                  and iftsai.num-int   = aquit.num-int-fac:
                if iftsai.annul begins "Annulation" or iftsai.annul begins "Origine" then next boucle.
            end.
            viNumeroQuittance = aquit.noqtt.
        end.
        
        if viNumeroQuittance > 0 
        then for first aquit no-lock
            where aquit.NoLoc = viNumeroRole
              and aquit.noqtt = viNumeroQuittance:
            assign 
                vlaquit               = true
                vdaDateDebut          = aquit.dtdeb
                vdaDateFin            = aquit.dtfin
                vdaDateEmission       = aquit.dtems
                vcCodePeriodicite     = aquit.pdqtt
                vcCodeTerme           = aquit.cdter
            .
        end.
        else for first equit no-lock 
            where equit.NoLoc = viNumeroRole:
            if vdaMaxQuittance = ? or equit.dtdpr <= vdaMaxQuittance
            then assign 
                vlequit              = true
                vdaDateDebut         = equit.dtdeb
                vdaDateFin           = equit.dtfin
                vcCodePeriodicite    = equit.pdqtt
                vcCodeTerme          = equit.cdter
                viNumeroQuittance    = equit.NoQtt
            .
        end.
    end.
    /* Emission de quittances à l'avance*/
    voPeriodiciteQuittancement = new parametragePeriodiciteQuittancement().
    poCollection:set("lHistorique",        vlaquit).
    poCollection:set("iNumeroQuittance",   viNumeroQuittance).
    poCollection:set("daMaxQuittance",     vdaMaxQuittance).
    poCollection:set("daDateEntree",       vdaEntreeLocataire).
    poCollection:set("daDateSortie",       vdaSortieLocataire).
    poCollection:set("daDateEmission",     vdaDateEmission).
    poCollection:set("daDateDebut",        vdaDateDebut).
    poCollection:set("daDateFin",          vdaDateFin).
    poCollection:set("cCodeModeReglement", vcCodeModeReglement).
    poCollection:set("lQuittanceAvance",   voPeriodiciteQuittancement:isAvance()).
    poCollection:set("iNombreMoisAvance",  viNombreMoisAvance).
    poCollection:set("cCodeTerme",         vcCodeTerme).
    poCollection:set("cCodePeriodicite",   vcCodePeriodicite).
    poCollection:set("lpquit",             vlpquit).
    poCollection:set("lequit",             vlequit).
    poCollection:set("laquit",             vlaquit).
    if valid-object(voPeriodiciteQuittancement) then delete object voPeriodiciteQuittancement.

end procedure.

procedure getMontantQuittance private:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes:
    ------------------------------------------------------------------------------*/
    define input        parameter poGlobalCollection as class collection no-undo.
    define input-output parameter poCollection       as class collection no-undo.

    define variable viNumeroRole      as integer   no-undo.
    define variable viNumeroQuittance as integer   no-undo.
    define variable vlHistorique      as logical   no-undo.
    define variable vdMontantTotal    as decimal   no-undo.

    assign
        viNumeroRole      = poCollection:getInteger("iNumeroRole")
        viNumeroQuittance = poCollection:getInteger("iNumeroQuittance")
        vlHistorique      = poCollection:getLogical("lHistorique")
    .
    if vlHistorique 
    then run getHistorique(viNumeroRole, viNumeroQuittance).
    else run getEnCours(poGlobalCollection, poCollection).

    empty temp-table ttFamilleRubrique.
    for first ttQtt 
        where ttQtt.NoLoc = viNumeroRole 
          and ttQtt.NoQtt = viNumeroQuittance:
        /* Calcul des montants cumules par famille
            1 = Loyers, 2 = Charges, 3 = Divers, 4 = Administratif, 5 = Impots,taxes, 8 = Honraire lcataires, 9 = Tva sur honraires
        */
        if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER}
        then for each ttRub 
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt:
            if not((ttRub.norub = 160 or ttRub.norub = 200) and ttRub.nolib = 2) then do:
                if ttRub.norub = 160
                then run cumulMontant(2, ttRub.vlmtq). /* Cumul sur charges */
                else run cumulMontant(ttRub.cdfam, ttRub.vlmtq).
                vdMontantTotal = vdMontantTotal + ttRub.vlmtq.
            end.
        end.
        else for each ttRub
            where ttRub.noloc = ttQtt.noloc
              and ttRub.noqtt = ttQtt.noqtt:
              run cumulMontant(ttRub.cdfam, ttRub.vlmtq).
            vdMontantTotal = vdMontantTotal + ttRub.vlmtq.
        end.
    end.
    poCollection:set("dMontantTotal", vdMontantTotal).

end procedure.

procedure cumulMontant private:
    /*------------------------------------------------------------------------------
      Purpose: Cumul les montants par code famille
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piCodeFamille as integer no-undo.
    define input parameter pdeMontant     as decimal no-undo.

    find first ttFamilleRubrique
         where ttFamilleRubrique.iCodeFamille = piCodeFamille no-error.
    if not available ttFamilleRubrique then do:
        create ttFamilleRubrique.
        assign 
            ttFamilleRubrique.iCodeFamille    = piCodeFamille
            ttFamilleRubrique.cLibelleFamille = getLibelleFamille(piCodeFamille)
            ttFamilleRubrique.dMontant        = 0
        .
    end.
    ttFamilleRubrique.dMontant = ttFamilleRubrique.dMontant + pdeMontant.

end procedure.

procedure getHistorique private:
    /*------------------------------------------------------------------------------
      Purpose: Récupère les tables de travail ttQtt et ttRub pour l'historique
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroRole      as integer   no-undo.
    define input parameter piNumeroQuittance as integer   no-undo.
    define variable vhHistorique as handle no-undo.

    run bail/quittancement/quittanceHistorique.p persistent set vhHistorique.
    run getTokenInstance in vhHistorique(mToken:JSessionId).
    run getQuittance in vhHistorique(piNumeroRole, piNumeroQuittance, output table ttQtt by-reference, output table ttRub by-reference).
    if valid-handle(vhHistorique) then run destroy in vhHistorique.

end procedure.

procedure getEnCours private:
    /*------------------------------------------------------------------------------
      Purpose: Récupère les tables de travail ttQtt et ttRub pour l'encours
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter poGlobalCollection as class collection no-undo.
    define input parameter poCollection       as class collection no-undo.

    define variable vcTypeRole        as character no-undo.
    define variable viNumeroRole      as integer   no-undo.
    define variable viNumeroQuittance as integer   no-undo.
    define variable vlIsMehaignerie   as logical   no-undo.
    define variable vhProc            as handle    no-undo.

    assign
        vcTypeRole        = poCollection:getCharacter("cTypeRole")
        viNumeroRole      = poCollection:getInteger("iNumeroRole")
        viNumeroQuittance = poCollection:getInteger("iNumeroQuittance")
    .
    run bail/quittancement/quittanceEncours.p persistent set vhProc.
    run getTokenInstance in vhProc (mToken:JSessionId).

    if vcTypeRole <> {&TYPEROLE-candidatLocataire}
    then vlIsMehaignerie = isFinMehaignerie({&TYPECONTRAT-bail},
                                            viNumeroRole,
                                            poGlobalCollection:getInteger("GlMoiMdf"),
                                            poGlobalCollection:getInteger("GlMoiMEc"),
                                            poGlobalCollection:getInteger("GlMoiQtt")).
    if vlIsMehaignerie 
    then run getListeQuittance in vhProc (vcTypeRole,  /* Chargement de TOUTES les Quittances + MajLocQt.p */
                                          viNumeroRole,
                                          poGlobalCollection,
                                          output table ttQtt by-reference,
                                          output table ttRub by-reference).
    else run getQuittance in vhProc (vcTypeRole,       /* Chargement d'une quittance */
                                     viNumeroRole, 
                                     viNumeroQuittance, 
                                     output table ttQtt by-reference, 
                                     output table ttRub by-reference).
    if valid-handle(vhProc) then run destroy in vhproc.

end procedure.

procedure initCombo:
    /*------------------------------------------------------------------------------
      Purpose: Procedure de chargement des combos de la fiche quittance
      Notes:   Service utilisé par beQuittancement.cls
    ------------------------------------------------------------------------------*/
     define input parameter pcTypeContrat   as character no-undo.
     define input parameter piNumeroContrat as integer   no-undo.
     define output parameter table for ttCombo.

     define variable vhProcLabel     as handle      no-undo.
     define variable voModeReglement as class syspg no-undo.

     run application/libelle/labelLadb.p persistent set vhProcLabel.
     run getTokenInstance in vhProcLabel (mToken:JSessionId).

     run getCombolabel in vhProcLabel ("CMBECHEANCELOYER,CMBPERIODICITEQTT,CMBMOISPRELEVQTT,CMBREPRISESOLDE,CMBOUINON,CMBTYPEEDITIONQUITTANCE", output table ttCombo).
     run chargeComboMAD (pcTypeContrat, piNumeroContrat, output table ttCombo by-reference).
     voModeReglement = new syspg().
     voModeReglement:creationComboSysPgZonXX("R_MDC", "CMBMODEREGLEMENTQTT", "L", pcTypeContrat, output table ttCombo by-reference).
     if valid-handle(vhProcLabel) then run destroy in vhProcLabel.
     if valid-object(voModeReglement) then delete object voModeReglement.

end procedure.

procedure chargeComboMAD private:
/*------------------------------------------------------------------------------
  Purpose:
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter table for ttCombo.
    
    define variable voParametreMAD as class parametrageMAD no-undo.

    voParametreMAD = new parametrageMAD().
    if IsColocation(pcTypeContrat, piNumeroContrat)
    then voParametreMAD:getComboMAD(output table ttCombo by-reference).
    else voParametreMAD:getComboParametre("MDNET", "CMBMAD", output table ttCombo by-reference).
    if valid-object(voParametreMAD) then delete object voParametreMAD.
 
end procedure.

procedure chargeParametreGESFL private:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes:
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.
    define variable voParametreFournisseurLoyer as class parametrageFournisseurLoyer no-undo.
    define variable vlFournisseurLoyer   as logical   no-undo.
    define variable vcCodeModeleFlo      as character no-undo.
    define variable viNumeroMandatFlo    as integer   no-undo.
    define variable viNombreMoisQuittFlo as integer   no-undo.
    define variable viNumeroDebFlo       as integer   no-undo.
    define variable viNumeroFinFlo       as integer   no-undo.
    
    /* Recuperation du parametre GESFL (gestion fourn loyer, periodicite du Quitt. Fournisseurs loyer Mensuelle/Trimestrielle) */
    voParametreFournisseurLoyer = new parametrageFournisseurLoyer().
    assign
        vlFournisseurLoyer   = voParametreFournisseurLoyer:isGesFournisseurLoyer()
        viNumeroMandatFlo    = voParametreFournisseurLoyer:getNumeroMandant()
        vcCodeModeleFlo      = voParametreFournisseurLoyer:getCodeModele()
        viNumeroDebFlo       = voParametreFournisseurLoyer:getFournisseurLoyerDebut()
        viNumeroFinFlo       = voParametreFournisseurLoyer:getFournisseurLoyerFin()
        viNombreMoisQuittFlo = voParametreFournisseurLoyer:getNombreMoisQuittance()
    .
    poCollection:set("lFournisseurLoyer",   vlFournisseurLoyer).
    poCollection:set("iNumeroMandatFlo",    viNumeroMandatFlo).
    poCollection:set("cCodeModeleFlo",      vcCodeModeleFlo).
    poCollection:set("iNumeroDebFlo",       viNumeroDebFlo).
    poCollection:set("iNumeroFinFlo",       viNumeroFinFlo).
    poCollection:set("iNombreMoisQuittFlo", viNombreMoisQuittFlo).
    if valid-object(voParametreFournisseurLoyer) then delete object voParametreFournisseurLoyer.

end procedure.

procedure chargeParemetrePeriodicite private:
    /*------------------------------------------------------------------------------
      Purpose: 
      Notes:
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.
    define variable voParametrePeriodiciteQuittancement as class parametragePeriodiciteQuittancement no-undo.
    define variable vlQuittanceAvance as logical   no-undo.
    define variable viPeriodicite     as integer   no-undo.
    define variable vcCodeEdition     as character no-undo.
    define variable CdTypEdt          as character no-undo.
    
    voParametrePeriodiciteQuittancement = new parametragePeriodiciteQuittancement().
    assign 
        viPeriodicite     = 1
        vlQuittanceAvance = false
        vcCodeEdition     = "00001"
        vlQuittanceAvance = voParametrePeriodiciteQuittancement:isAvance()
        viPeriodicite     = voParametrePeriodiciteQuittancement:periodiciteQuittancement()  /* Quitt Trimestriel */
        vcCodeEdition     = voParametrePeriodiciteQuittancement:geCodeEditCab()
        vcCodeEdition     = if vcCodeEdition > "" then vcCodeEdition else CdTypEdt
    .
    poCollection:set("lQuittanceAvance", vlQuittanceAvance).
    poCollection:set("iPeriodicite"   ,  viPeriodicite).
    poCollection:set("cCodeEdition",     vcCodeEdition).
    if valid-object(voParametrePeriodiciteQuittancement) then delete object voParametrePeriodiciteQuittancement.

end procedure.

procedure chargeProprietaire private:
    /*------------------------------------------------------------------------------
      Purpose: 
      Notes: reprise de la procédure interne EnaObjTch de prmobqtt_srv.p
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable vcNomProprietaire as character no-undo.
    define variable viNumeroMandant   as integer   no-undo.

    define buffer intnt for intnt.

    /* Recherche du proprietaire */
    find first intnt no-lock
         where intnt.tpcon = pcTypeContrat
           and intnt.nocon = piNumeroContrat
           and intnt.tpidt = {&TYPEROLE-mandant} no-error.
    if available intnt 
    then assign
        vcNomProprietaire = outilFormatage:getCiviliteNomTiers(intnt.tpidt, intnt.noidt, false)
        viNumeroMandant   = intnt.noidt 
    .
    else 
        mError:createError(0, substitute("intnt inconnu tpcon = &1 nocon = &2 tpidt = '&3'",
                              pcTypeContrat,
                              piNumeroContrat,
                              "00022")).
    poCollection:set("cNomProprietaire", vcNomProprietaire).
    poCollection:set("iNumeroMandant",   viNumeroMandant).

end procedure.

procedure enaObjTch private:
    /*------------------------------------------------------------------------------
      Purpose: 
      Notes: reprise de la procédure interne EnaObjTch de prmobqtt_srv.p
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.

    define variable vcTypeContrat       as character no-undo.
    define variable viNumeroContrat     as integer   no-undo.
    define variable vlSepa              as logical   no-undo.
    define variable vdaDateFin          as date      no-undo.
    define variable vdaDateDeb          as date      no-undo.
    define variable vdaDateRes          as date      no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    /* Recherche si la periodicite du Quittancement Locataires est Trimestrielle */
    assign 
        viNumeroContrat     = poCollection:getInteger("iNumeroContrat")
        vcTypeContrat       = poCollection:getCharacter("cTypeContrat")
        vlSepa              = can-find(first iparm no-lock where iparm.tppar = "SEPA"). /* Ajout SY le 15/01/2013 SEPA */
    .
    /* Recherche du Contrat en Cours. */
    find first ctrat no-lock
        where ctrat.tpcon = vcTypeContrat
          and ctrat.nocon = viNumeroContrat no-error.
    if not available ctrat then do:
        // if ret then ret = dynamic-function('createData':U,"aig", 5).
        mError:createError(0, substitute('Contrat N°&1 de type &2 non trouvé.', viNumeroContrat, vcTypeContrat)).
        return.
    end.

    /* Recuperation des Infos du Contrat. */
    assign
        vdaDateDeb = ctrat.Dtini  /* 06/10/2000 STRING(ctrat.DtDeb)*/
        vdaDateFin = ctrat.DtFin
        vdaDateRes = ctrat.DtRee
    .
    /* Recuperation des Infos du Renouvellement */
    find last tache no-lock
        where tache.tpcon = vcTypeContrat
          and tache.nocon = viNumeroContrat
          and tache.tptac = {&TYPETACHE-renouvellement} no-error.
    if available tache then case tache.tpfin:
        /* Procedure de renouvellement encours */
        when "10" then vdaDateFin = tache.dtfin.
        /* Bail a renouveller sur la base de */
        when "20" then case entry(2, entry(num-entries(tache.cdhon, "#"), tache.cdhon, "#"), "&"):
            when "00009" then vdaDateFin = tache.dtfin.      /* du bail     */ 
            when "00010" then vdaDateFin = tache.dtreg - 1.  /* de l'offre  */
            when "00011" then vdaDateFin = tache.dtreg - 1.  /* du jugement */
        end case.
        /* Bail a resilier */
        when "40" then case entry(2, entry(num-entries(tache.cdhon, "#"), tache.cdhon, "#"), "&"):
             when "00004" then vdaDateFin = tache.dtreg - 1.  /* Conges Manuel    */ 
             when "00015" then vdaDateFin = tache.dtfin.      /* Conges Systeme   */
             when "00016" then vdaDateFin = tache.dtfin.      /* Demnde de congés */
        end case.
    end case.
    poCollection:set("lSEPA",                vlSEPA).
    poCollection:set("daDateDebut",          vdaDateDeb).
    poCollection:set("daDateFin",            vdaDateFin).
    poCollection:set("daDateResiliation",    vdaDateRes).
    poCollection:set("daDateRenouvellement", vdaDateFin + 1).

end procedure.

procedure loadObjTch private:
    /*------------------------------------------------------------------------------
      Purpose: reprise de LoaObjTch
      Notes: Utilisée par beQuittancement.cls
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.

    define variable viNumeroLocataire          as integer   no-undo.
    define variable viNumeroMandat             as integer   no-undo.
    define variable vcNatureMandat             as character no-undo.
    define variable viNumeroTiers              as integer   no-undo.
    define variable vlFournisseurLoyer         as logical   no-undo.
    define variable viNumeroContrat            as integer   no-undo.
    define variable vcTypeContrat              as character no-undo.
    define variable vlGenerationAvis           as logical   no-undo.
    define variable vlSepa                     as logical   no-undo.
    define variable vlPrelevementSEPA          as logical   no-undo.
    define variable vcListeCompteTiers         as character no-undo.
    define variable viNombreCompteTiers        as integer   no-undo.
    define variable viNumeroContratBanqueTiers as integer   no-undo.
    define variable vlBanquePrelevVirement     as logical   no-undo.
    define variable viNumeroQttTache           as integer   no-undo.
    define variable viNombreQttHisto           as integer   no-undo.
    define variable vlQuittanceEmise           as logical   no-undo.
    define variable vcCodeModeReglement        as character no-undo.
    define variable viNumeroAppartement        as integer   no-undo.
    define variable vlBailFournisseurLoyer     as logical   no-undo.
    define variable viMoisModifiable           as integer   no-undo.
    define variable viMoisEchus                as integer   no-undo.
    define variable viMoisQuittance            as integer   no-undo.
    define variable vhProcSEPA                 as handle    no-undo.
    define variable vhRlctt                    as handle    no-undo.
    define variable viComp-Etab-cd             as integer   no-undo.
    define variable vcComp-cptg-cd             as character no-undo.
    define variable vcComp-sscpt-cd            as character no-undo.
    define variable vcIBAN-BICUse              as character no-undo.
    define variable voParametreSEPA       as class parametrageSEPA       no-undo.
    define variable vcMdVisUse                 as character no-undo. // TODO Sortir le code de mise à jour de cette procédure

    define buffer vbRoles  for roles.
    define buffer rlctt    for rlctt.
    define buffer ctanx    for ctanx.
    define buffer pquit    for pquit.
    define buffer aquit    for aquit.
    define buffer equit    for equit.
    define buffer ctrat    for ctrat.
    define buffer tache    for tache.

    assign
        viNumeroLocataire   = poCollection:getInteger("iNumeroLocataire")
        viNumeroContrat     = poCollection:getInteger("iNumeroContrat")
        vcTypeContrat       = poCollection:getCharacter("vcTypeContrat")
        viNumeroMandat      = poCollection:getInteger("iNumeroMandat")
        viNumeroAppartement = poCollection:getInteger("iNumeroAppartement")
        vlGenerationAvis    = poCollection:getLogical("lGenerationAvis")
        vlSepa              = poCollection:getLogical("lSepa")
        vlFournisseurLoyer  = poCollection:getLogical("lFournisseurLoyer")
        viMoisModifiable    = poCollection:getInteger("GlMoiMdf")
        viMoisEchus         = poCollection:getInteger("GlMoiMEc")
        viMoisQuittance     = poCollection:getInteger("GlMoiQtt")
        voParametreSEPA     = new parametrageSEPA().
    .

    /* Recuperation du no Tiers du Locataire */
    for first vbRoles no-lock
        where vbRoles.TpRol = {&TYPEROLE-locataire} // vcTypeRole
          and vbRoles.NoRol = viNumeroLocataire:
        viNumeroTiers = vbRoles.NoTie.
    end.
    if voParametreSEPA:isPrelevementSEPA() then vlPrelevementSEPA = true.
    /* Recherche si le tiers a au moins 1 banque */
    run getListeCompteTiers(input viNumeroTiers, output vcListeCompteTiers, output viNombreCompteTiers).

    /* Si le tiers a des banques mais pas le bail alors creer le lien banque du contrat bail avec la banque par defaut */
    if viNombreCompteTiers > 0 then do:
        find first rlCtt no-lock 
             where rlCtt.Tpidt = {&TYPEROLE-locataire} // vcTypeRole
               and rlCtt.Noidt = viNumeroLocataire
               and rlCtt.Tpct1 = vcTypeContrat
               and rlctt.Noct1 = viNumeroContrat
               and rlCtt.Tpct2 = {&TYPECONTRAT-prive} no-error.
        if not available rlctt
        then for first ctanx no-lock 
            where ctanx.tpcon = {&TYPECONTRAT-prive}
              and ctanx.tprol = {&TYPEROLE-tiers}
              and ctanx.Norol = viNumeroTiers
              and ctanx.tpact = "DEFAU":
            create ttRlctt.
            assign
                ttRlctt.tpidt = {&TYPEROLE-locataire} // vcTypeRole
                ttRlctt.noidt = viNumeroLocataire
                ttRlctt.tpct1 = vcTypeContrat
                ttRlctt.noct1 = viNumeroContrat
                ttRlctt.tpct2 = ctanx.Tpcon
                ttRlctt.noct2 = ctanx.nocon
                ttRlctt.lbdiv = ""
                ttRlctt.CRUD  = "C"
            .
            run adblib/rlctt_CRUD.p persistent set vhRlctt.
            run getTokenInstance in vhRlctt(mToken:JSessionId).
            run setRlctt in vhRlctt(table ttRlctt by-reference).
            viNumeroContratBanqueTiers = ctanx.nocon.
        end.
        else viNumeroContratBanqueTiers = rlctt.Noct2.

        run outils/controleBancaire.p persistent set vhProcSEPA.
//        run getTokenInstance in vhProcSEPA.

        if viNumeroContratBanqueTiers > 0 then do:
            find first ctanx no-lock
                where ctanx.Tpcon = {&TYPECONTRAT-prive}
                  and ctanx.nocon = viNumeroContratBanqueTiers no-error.
            if available ctanx then do:
                vcIBAN-BICUse = substitute('&1-&2', ctanx.iban, ctanx.bicod).
                /* Ajout SY le 15/01/2013 : Rechercher si le locataire est dans la zone RIB ou la zone SEPA */  
                if dynamic-function('isZoneRIB' in vhprocSEPA, ctanx.iban, ctanx.bicod)
                then vlBanquePrelevVirement = true.
                if vlSEPA and dynamic-function('isZoneSEPA' in vhprocSEPA, ctanx.iban, ctanx.bicod)
                then vlBanquePrelevVirement = true.
            end.
            else viNumeroContratBanqueTiers = 0.
        end.
    end.
    /* Recherche Nature du Mandat */
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = viNumeroMandat:
        vcNatureMandat = ctrat.ntcon.
    end.
    /* Ajout Sy le 24/09/2008 */
    vlBailFournisseurLoyer = lookup(vcNatureMandat, substitute('&1,&2,&3', {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatLocationIndivision}, {&NATURECONTRAT-mandatLocationDelegue})) > 0.
    if vcMdVisUse <> 'A' then do:
        /* Compensation */
        for last tache no-lock
            where tache.tpcon = vcTypeContrat
              and tache.nocon = viNumeroContrat
              and tache.tptac = {&TYPETACHE-quittancement}:
            assign
                viComp-Etab-cd  = tache.etab-cd
                vcComp-cptg-cd  = tache.cptg-cd
                vcComp-sscpt-cd = tache.sscpt-cd
            .
        end.
        /* tester si on est en 1er transfert ou valid.
           si 1er trf => on peut modifier la date d'appli, la periodicité et le terme
           si validation: on grise les zones.
           SIMULATION DE QUITTANCE EMISE OU NON EMISE
        */
        {&_proparse_ prolint-nowarn(use-index)}
        if vcTypeContrat = {&TYPECONTRAT-preBail}
        then for first pquit no-lock
            where pquit.noloc = viNumeroLocataire
            use-index ix_pquit03:
            assign
                viNumeroQttTache    = pquit.noqtt
                vcCodeModeReglement = pquit.mdreg
            .
        end.
        else do:
            /* Test si le locataire a des quittances historisees */
            for first aquit no-lock
                where aquit.noloc = viNumeroLocataire
                  and aquit.noqtt > 0:
                viNombreQttHisto = 1.
            end.
            /* Test si la prochaine quittance a ete mise */
            {&_proparse_ prolint-nowarn(use-index)}
            for first equit no-lock
                where equit.noloc = viNumeroLocataire
                  and equit.msqtt >= (if vlBailFournisseurLoyer then viMoisModifiable else viMoisEchus)  /* AJout SY le 12/01/2015 pour ne pas prendre les Avis d'échéance périmés (Pb plantage PEC, equit non historisé) */
                use-index ix_equit03:
                assign 
                    viNumeroQttTache    = equit.noqtt
                    vcCodeModeReglement = equit.mdreg
                .
                // TODO   simplifier le calcul de vlQuittanceEmise, seule la valeur TRUE modifie la valeur initiale.
                if vlFournisseurLoyer and vlBailFournisseurLoyer 
                then do: /* modif SY le 16/09/2008 */
                    if viMoisModifiable = viMoisQuittance or equit.msqtt > viMoisModifiable 
                    then vlQuittanceEmise = false.
                end.
                else if (equit.cdter = "00001" and equit.msqtt > viMoisModifiable)
                     or (equit.cdter = "00002" and equit.msqtt > viMoisEchus)
                then vlQuittanceEmise = false.
                else do:
                    if (equit.cdter = "00001" and viMoisModifiable = viMoisQuittance)
                    or (equit.cdter = "00002" and viMoisEchus  = viMoisQuittance) 
                    then vlQuittanceEmise = false. /* 1er transfert non fait */
                    else vlQuittanceEmise = true.
                end.
            end.
        end.
        if vlGenerationAvis then do:
            /* Regeneration des avis d'echeance a partir de l'offre */
            /* modif SY le 21/09/2010 : dernier no SAUF FACTURES DIVERSES (>= 800) */
            /* modif SY le 24/01/2013 : prendre en compte Fac Entrée (si fac Entrée no 1 => prochain no = 2 ) */
            viNumeroQttTache = 1.
            {&_proparse_ prolint-nowarn(use-index)}
            for last aquit no-lock 
                where aquit.noloc = viNumeroLocataire
                  and aquit.noqtt > 0
                  and (not aquit.fgfac or aquit.type-fac = "E")  /* SY 24/01/2013 */
                 use-index ix_aquit01:
                viNumeroQttTache = aquit.noqtt + 1.
            end.
            /* ajout SY le 21/09/2010 : repartir des no < 800 */
            if viNumeroQttTache >= 800 then do:
                {&_proparse_ prolint-nowarn(use-index)}
                find last aquit no-lock 
                    where aquit.noloc = viNumeroLocataire
                      and aquit.noqtt > 0
                      and aquit.noqtt < 800
                      and (not aquit.fgfac or aquit.type-fac = "E") /* SY 24/01/2013 */
                    use-index ix_aquit01 no-error.
                viNumeroQttTache = if available aquit then aquit.noqtt + 1 else 10. /* SY 11/02/2011 */
            end.
        end.
        poCollection:set("iComp-Etab-cd",         viComp-Etab-cd).
        poCollection:set("cComp-cptg-cd",         vcComp-cptg-cd).
        poCollection:set("cComp-sscpt-cd",        vcComp-sscpt-cd).
        poCollection:set("lQuittanceEmise",       vlQuittanceEmise).
        poCollection:set("iNumeroQuittance",      viNumeroQttTache).
        poCollection:set("cCodeModeReglement",    vcCodeModeReglement).
        poCollection:set("iNombreQuittanceHisto", viNombreQttHisto).
    end.
    poCollection:set("lQuittanceEmise",           vlQuittanceEmise).
    poCollection:set("cIBAN-BICUse",              vcIBAN-BICUse).
    poCollection:set("lBailFournisseurLoyer",     vlBailFournisseurLoyer).
    poCollection:set("cNatureMandat",             vcNatureMandat).
    poCollection:set("iNumeroMandat",             viNumeroMandat).
    poCollection:set("iNumeroTiers",              viNumeroTiers).
    poCollection:set("iNombreCompteTiers",        viNombreCompteTiers).
    poCollection:set("iNumeroContratBanqueTiers", viNumeroContratBanqueTiers).
    poCollection:set("lBanquePrelevVirement",     vlBanquePrelevVirement).
    poCollection:set("lPrelevementSEPA",          vlPrelevementSEPA).

    if valid-handle(vhRlctt)         then run destroy in vhRlctt.
    if valid-handle(vhProcSEPA)      then run destroy in vhProcSEPA.
    if valid-object(voParametreSEPA) then delete object voParametreSEPA.

end procedure.

procedure chargeBanqueMandat private:
/*------------------------------------------------------------------------------
  Purpose:
  Notes:
------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    define variable viNbBquMandat as integer no-undo.

    define buffer ietab   for ietab.
    define buffer vbietab for ietab.
    define buffer ijou    for ijou.
    define buffer ibque   for ibque.
    define buffer aetabln for aetabln.

    for first ietab no-lock
        where ietab.soc-cd  = integer(mtoken:cRefGerance)
          and ietab.etab-cd = piNumeroMandat
      , each aetabln no-lock
        where aetabln.soc-cd  = integer(mtoken:cRefGerance)
          and aetabln.etab-cd = piNumeroMandat:
        create ttBanquePrelevement.
        assign
            ttBanquePrelevement.cdBqu     = aetabln.jou-cd
            ttBanquePrelevement.NoMDt     = aetabln.mandat-cd
            /*--> Banque par défaut du mandat */
            ttBanquePrelevement.fg-defaut = (aetabln.jou-cd = ietab.bqjou-cd) 
                                             and can-find(first vbietab no-lock
                                                     where vbietab.soc-cd    = aetabln.soc-cd
                                                       and vbietab.etab-cd   = aetabln.mandat-cd
                                                       and vbietab.profil-cd = ietab.bqprofil-cd)
            viNbBquMandat                 = viNbBquMandat + 1
        .
        /** Ajout SY le 15/01/2013 */
        for first ijou no-lock
            where ijou.soc-cd  = integer(mtoken:cRefGerance)
              and ijou.etab-cd = aetabln.mandat-cd
              and ijou.jou-cd  = aetabln.jou-cd
          , first ibque no-lock
            where ibque.soc-cd  = ijou.soc-cd
              and ibque.etab-cd = ijou.etab-cd
              and ibque.cpt-cd  = ijou.cpt-cd:
            assign
                ttBanquePrelevement.fmtprl = ibque.fmtprl     /* CFONB / SEPA */
                ttBanquePrelevement.fmtvir = ibque.fmtvir
            .
        end.
//        create ttCombo.
//        ttCombo.cLibelle = aetabln.jou-cd.
    end.
end procedure.

procedure chargeParametreClientPrelevement private:
    /*------------------------------------------------------------------------------
    Purpose: charge les paramètres de prélèvement du client
    Notes:
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.

    define variable vlPrelevementAuto as logical   no-undo.
    define variable viJourPrelevement as integer   no-undo.
    define variable vcMoisPrelevement as character no-undo initial "00000".
    define variable vlPrelevementMens as logical   no-undo.
    define variable voParametrePrelevement as class parametragePrelevementAutomatique no-undo.

    voParametrePrelevement = new parametragePrelevementAutomatique().
    if valid-object(voParametrePrelevement) 
    then do:
        assign 
            vlPrelevementAuto = voParametrePrelevement:isPrelevementAutomatique()
            viJourPrelevement = voParametrePrelevement:getNombreJoursPrelevement()
            vcMoisPrelevement = voParametrePrelevement:getCodeMoisPrelevement()
            vlPrelevementMens = voParametrePrelevement:isPrelevementMensuel()
        .
        delete object voParametrePrelevement.
    end.
    poCollection:set("lPrelevementAuto",  vlPrelevementAuto).
    poCollection:set("iNumeroJourPrelev", viJourPrelevement).
    poCollection:set("cMoisPrelevement",  vcMoisPrelevement).
    poCollection:set("lPrelevementMens",  vlPrelevementMens).
    if valid-object(voParametrePrelevement) then delete object voParametrePrelevement.

end procedure.

procedure getListeCompteTiers private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des comptes du tiers
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroRole       as integer   no-undo.
    define output parameter pcListeCompteTiers as character no-undo.

    define variable vhProcCtAnx as handle no-undo.

    run adblib/ctanx_CRUD.p persistent set vhProcCtAnx.
    run getTokenInstance in vhProcCtAnx(mToken:JSessionId).
    /* Recuperation du nombre de compte du tiers. */
    run getListeContratAnnexe in vhProcCtAnx({&TYPECONTRAT-prive}, {&TYPEROLE-tiers}, piNumeroRole, output pcListeCompteTiers).
    run destroy in vhProcCtAnx.

end procedure.

procedure controleLancementParametrage:
    /*------------------------------------------------------------------------------
    Purpose:     
    Notes:       TODO  pas utilisée, pas fini ...
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable voImmobilierEntreprise as class parametrageImmobilierEntreprise no-undo.
    define variable voSyspg as class syspg no-undo.
    define buffer ctrat for ctrat.

    /*--> On regarde si le contrat existe */
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then return.

    /*--> On regarde si la nature du contrat est commerciale */
    voSyspg = new syspg("R_CTA").
    if not voSyspg:isDbParameter(ctrat.ntcon, {&TYPETACHE-franchise}) then return.

    /*--> On regarde si on peut lancer l'ecran en fonction du parametrage */
    voImmobilierEntreprise = new parametrageImmobilierEntreprise().
    if not voImmobilierEntreprise:isOkEcran() then return.

    /*--> On regarde si la tache quittencement est PEC */
    if not can-find(first tache no-lock
                    where tache.tpcon = pcTypeContrat
                      and tache.nocon = piNumeroContrat
                      and tache.tptac = {&TYPETACHE-quittancement})
    then return.
    // todo   Et alors ?

end procedure.

procedure setParametre:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes: repris à partir de EnaObjTch de prmobqtt_srv.p Cas IF CdActUse <> "00"
    todo A finaliser.
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    
    define variable vlAfficheQuitt    as logical   no-undo.
    define variable vlGenerationAvis  as logical   no-undo.
    define variable viNombreLotUL     as integer   no-undo.
    define variable vcTypeContrat     as character no-undo.
    define variable viNumeroContrat   as integer   no-undo.
    define variable FgRepMes1         as logical   no-undo.
    define variable FgRepMes2         as logical   no-undo.
    define variable viMoisModifiable  as integer   no-undo.
    define variable viMoisEchu        as integer   no-undo.
    define variable viMoisQuittance   as integer   no-undo.

    define buffer ctrat for ctrat.
    define buffer unite for unite.
    define buffer cpuni for cpuni.
    define buffer equit for equit.

    assign
        vlAfficheQuitt    = true
        vlGenerationAvis  = false
        vcTypeContrat     = poCollection:getCharacter("cTypeContrat")
        viNumeroContrat   = poCollection:getInteger("iNumeroContrat")
        viMoisQuittance   = poCollection:getInteger("GlMoiQtt")
        viMoisModifiable  = poCollection:getInteger("GlMoiMdf")
        viMoisEchu        = poCollection:getInteger("GlMoiMEc")
    .
    /* Gestion des avis d echeance */
    if vcTypeContrat <> {&TYPECONTRAT-Bail} then return.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-Bail}
          and ctrat.nocon = viNumeroContrat
          and ctrat.dtree = ?:
        /* Ajout SY le 25/09/2014 - fiche 0814/0054 : vérifier qu'il y a des lots dans l'UL */
        for each unite no-lock
            where unite.nomdt = integer(truncate(viNumeroContrat / 100000, 0)) 
              and unite.noapp = integer(truncate((viNumeroContrat modulo 100000) / 100, 0))
              and unite.noact = 0
          , each cpuni no-lock
            where cpuni.nomdt = Unite.nomdt
              and cpuni.noapp = Unite.noapp
              and cpuni.nocmp = Unite.nocmp:
            viNombreLotUL = viNombreLotUL + 1.
        end.
        if viNombreLotUL = 0 then return.

        if not can-find(first equit no-lock where equit.noloc = viNumeroContrat)
        then do:
            /* (105671) Ce locataire n'a plus d'avis d'echeance. Voulez-vous les générer à partie de l'offre */
            // if aig = 0 then do:
                //if ret then ret = dynamic-function('createData':U,"aig", 1).
            // end.
            if FgRepMes1 then assign
                vlGenerationAvis = true
                vlAfficheQuitt   = true
            .
        end.
        /* Ajout SY le 05/01/2010 - fiche 1209/0212: avis d'échéance erronés */
        else if not can-find(first equit no-lock
                             where equit.noloc = viNumeroContrat
                               and ((equit.cdter = "00001" and equit.msqtt >= viMoisModifiable)
                                 or (equit.cdter = "00002" and equit.msqtt >= viMoisEchu)))
        then do:
            // if aig = 2 then do:
                // if ret then ret = dynamic-function('createData':U, "aig", 3).
            // end.
            if FgRepMes2 then do:
                for each equit exclusive-lock
                   where equit.noloc = viNumeroContrat
                     and ((equit.cdter = "00001" and equit.msqtt < viMoisModifiable)
                       or (equit.cdter = "00002" and equit.msqtt < viMoisEchu)):
                    delete equit.
                end.
                assign
                    vlGenerationAvis = true
                    vlAfficheQuitt   = true
                .
            end.
        end.
    end.
end procedure.

procedure verificationPeriodicite:
    /* -------------------------------------------------------------------------
    Purpose: Procedure de controle du changement de terme ou de périodicité
    Notes: Fiches 0107/0149 + 0607/0222
           si le locataire a une quittance historisée (ou FL entrée ?) pour qu'un mois ne soit pas quittancé 2 fois. 
    todo : Pas encore utilisée. pas terminée....
   ----------------------------------------------------------------------- */
    define input parameter piNumeroRole  as integer   no-undo.
    define input parameter pcTypeContrat as character no-undo.

    define variable viCptRub         as integer   no-undo.
    define variable vcRubQtt         as character no-undo.
    define variable vcNumeroRubRch   as character no-undo.
    define variable vlQttVid         as logical   no-undo.
    define variable vcLibelleMessage as character no-undo.

    define buffer aquit for aquit.

    {&_proparse_ prolint-nowarn(use-index)}
    find last aquit no-lock
        where aquit.noloc = piNumeroRole
          and aquit.fgfac = no
        use-index ix_aquit03  no-error.
    if not available aquit then return.

    vlQttVid = yes.
    if aquit.mtqtt <> 0 
    then vlQttVid = no.
    else do viCptRub = 1 to 20:
        vcRubQtt = aquit.tbrub[viCptRub].
        if num-entries(vcRubQtt, "|" ) < 13 then next.

        vcNumeroRubRch = entry(1, vcRubQtt, "|").
        if integer(vcNumeroRubRch) = 0 then leave.

        if decimal(entry(6, vcRubQtt, "|" )) <> 0 
        then do:
            vlQttVid = no.
            leave.
        end.
    end.
    if vlQttVid then return.

    /* Nouvelles quittances */
    find first ttQtt where ttQtt.noloc = piNumeroRole no-error.
    if not available ttqtt then return.

    /* PL 20/01/2011 Ajout restriction test sur bail*/
    if pcTypeContrat = {&TYPECONTRAT-bail} and ttqtt.dtdpr <= aquit.dtfpr
    then vcLibelleMessage = substitute("ATTENTION: Modification à confirmer. La nouvelle période de quittancement (&1-&2)"
                          + "chevauche la dernière quittance historisée (&3-&4)."
                          + " Voulez quand même effectuer la modification (pensez à corriger le quittancement en conséquence) ?",
                            string(ttqtt.dtdpr, "99/99/9999"),
                            string(ttqtt.dtfpr, "99/99/9999"),
                            aquit.dtdpr,
                            aquit.dtfpr)
    .
end procedure.

procedure verificationDateFin:
    /*------------------------------------------------------------------------------
    Purpose: vérification de la date de fin saisie sur l'écran de paramétrage  
    Notes: pas encore utilisée
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroApp    as integer no-undo.
    define input parameter piNumeroMandat as integer no-undo.
    define input parameter pdaFin         as date    no-undo.
    define input parameter piNumeroRole   as integer no-undo.

    define buffer aquit for aquit.
    define buffer unite for unite.

    if pdaFin = ? then return.
    {&_proparse_ prolint-nowarn(use-index)}
    find last aquit no-lock
        where aquit.noloc = piNumeroRole
          and aquit.fgfac = no
          use-index ix_aquit03 no-error.
    if available aquit and pdaFin < aquit.dtfin
    then mError:createError(0, "").              // Todo message à positionné
    else for first unite no-lock                 // Controle avec les dates d'indisponibilite de l'UL
         where unite.nomdt = piNumeroMandat
           and unite.noapp = piNumeroApp
           and unite.noact = 0:
        if pdaFin >= unite.dtdebindis and pdaFin <= unite.dtfinindis
        then mError:createError(0, "").          // Todo message à positionné
    end.

end procedure.

procedure chargeTempOffre:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de l'offre
    Notes: Pas encore utilisée
    todo : A reprendre ou a jeter.   getOffre n'existe pas dans adb/genoffqt.p
    ------------------------------------------------------------------------------*/
    define variable vcCodeRetour       as character no-undo.
    define variable vcMessage          as character no-undo.
    define variable vcLibelleMois1GI   as character no-undo.
    define variable vcLibelleAnnee1GI  as character no-undo.
    define variable vdaDateQtt1GI      as date      no-undo.
    /* Todo A transformer en input, d'où viennent ces infos ? */
    define variable vcTypeBail         as character no-undo.
    define variable viNumeroBail       as integer   no-undo.
    define variable viNumeroQuittance  as integer   no-undo.
    define variable vcCodeTerme        as character no-undo.
    define variable vcCodePeriode      as character no-undo.
    define variable vhGenOffre         as handle    no-undo.
    define variable vdaDateApplication as date      no-undo.

    run adb/genoffqt.p persistent set vhGenOffre.
    run getTokenInstance in vhGenOffre(mToken:JSessionId).
    run getOffre in vhGenOffre(false,
                               vcTypeBail, 
                               viNumeroBail,
                               viNumeroQuittance,
                               vcCodeTerme,
                               vcCodePeriode,
                               vdaDateApplication,
                               output vcCodeRetour,
                               output vcMessage, 
                               output table ttQtt by-reference, 
                               output table ttRub by-reference).
    if valid-handle(vhGenOffre) then run destroy in vhGenOffre.
    /* Reinitialisation de la date 1ère Quitt GI */
    for first ttQtt
        where ttQtt.NoLoc = viNumeroBail
          and ttQtt.Noqtt = viNumeroQuittance:
        assign
            vcLibelleMois1GI  = substring(string(ttQtt.MsQtt), 5, 2, "character")
            vcLibelleAnnee1GI = substring(string(ttQtt.MsQtt), 1, 4, "character")
            vdaDateQtt1GI     = date(integer(vcLibelleMois1GI), 01, integer(vcLibelleAnnee1GI))
        .
    end.

end procedure.

procedure chargeParametreDefaut:
    /*------------------------------------------------------------------------------
    Purpose: reprise de LoaObjTch
    Notes: TODO  service A utiliser pour charger les paramètres par défaut en cas d'ajout.
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.

    define variable vcTypeContrat       as character no-undo.
    define variable viNumeroContrat     as integer   no-undo.
    define variable vcNatureContrat     as character no-undo.
    define variable viNumeroMandat      as integer   no-undo.
    define variable viNumeroAppartement as integer   no-undo.
    define variable voParametreRelocation as class parametrageRelocation no-undo.
    define variable voParametreDefautBail as class parametrageDefautBail no-undo.
    define buffer location for location.
    define buffer ctrat    for ctrat.

    assign
        viNumeroContrat       = poCollection:getInteger("iNumeroContrat")
        vcTypeContrat         = poCollection:getCharacter("cTypeContrat")
        viNumeroMandat        = truncate(viNumeroContrat / 100000, 0)
        viNumeroAppartement   = truncate((viNumeroContrat modulo 100000) / 100, 0)
        voParametreDefautBail = new parametrageDefautBail("")
        voParametreRelocation = new parametrageRelocation()
    .
    poCollection:set("lParametreDFBX", voParametreDefautBail:isDbParameter).
    poCollection:set("lReleveAppelFond", voParametreDefautBail:isReleveAppelFondsActif()).

    /*--> PEC : Rechercher les paramŠtres par defaut de la nature du bail */
    for first ctrat no-lock 
         where ctrat.tpcon = vcTypeContrat
           and ctrat.nocon = viNumeroContrat:
        vcNatureContrat = ctrat.ntcon.
    end.
    voParametreDefautBail:reload(vcNatureContrat).
    poCollection:set("lParametreDEFBXNatureContrat", voParametreDefautBail:isDbParameter).
    poCollection:set("iNombreMoisAvance", voParametreDefautBail:getNombreMoisAvance()).
    poCollection:set("lLocation", false).
    if voParametreRelocation:isActif()
    then for last location no-lock
        where location.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and location.nocon = viNumeroMandat
          and location.noapp = viNumeroAppartement
          and not location.fgarch:
        poCollection:set("lLocation",        true).
        poCollection:set("cCodePeriodicite", location.qtt-cdper).
        poCollection:set("cCodeTerme",       location.qtt-terme).
    end.
    if valid-object(voParametreRelocation) then delete object voParametreRelocation.
    if valid-object(voParametreDefautBail) then delete object voParametreDefautBail.

end procedure.

procedure chargeInfoRUM private:
    /*------------------------------------------------------------------------------
    Purpose: reprise de 
    Notes: A utiliser pour charger les paramètres par défaut en cas d'ajout.
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.
    define variable viNumeroMandat  as integer   no-undo.
    define variable vcTypeContrat   as character no-undo.
    define variable viNumeroContrat as integer   no-undo.
    define variable viNumeroRole    as integer   no-undo.
    define variable vcTypeRole      as character no-undo.
    define buffer mandatsepa for mandatsepa.

    assign
        viNumeroMandat  = poCollection:getInteger("iNumeroMandat")
        vcTypeContrat   = poCollection:getCharacter("cTypeContrat")
        viNumeroContrat = poCollection:getInteger("iNumeroContrat")
        vcTypeRole      = poCollection:getCharacter("cTypeRole")
        viNumeroRole    = poCollection:getInteger("iNumeroRole")
    .
    for last mandatsepa no-lock
        where mandatsepa.Tpmandat = {&TYPECONTRAT-sepa}
          and mandatsepa.ntcon    = {&NATURECONTRAT-recurrent}
          and mandatsepa.nomdt    = viNumeroMandat
          and mandatsepa.tpcon    = vcTypeContrat
          and mandatsepa.nocon    = viNumeroContrat
          and mandatsepa.tprol    = vcTypeRole
          and mandatsepa.norol    = viNumeroRole: 
        poCollection:set("iNumeroMPrelSEPA", mandatsepa.noMPrelSEPA).
        poCollection:set("cCodeRUM",         mandatsepa.codeRUM).
        poCollection:set("daDateSignature",  mandatsepa.dtsig).
    end.
end procedure.
