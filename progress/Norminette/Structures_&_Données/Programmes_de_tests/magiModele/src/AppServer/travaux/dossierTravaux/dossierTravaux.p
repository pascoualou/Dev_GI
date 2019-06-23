/*------------------------------------------------------------------------
File        : dossierTravaux.p
Purpose     :
Author(s)   : kantena - 2016/11/14
Notes       :
Derniere revue : 2018/04/09 - phm
------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/typeAppel2fonds.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2contrat.i}
{preprocesseur/typeAppel.i}

&SCOPED-DEFINE NATUREDOSSIER-forfait            "00001" /*gga todo creation include */
&SCOPED-DEFINE ETATTRAITEMENTTRANSFERT-00003    "00003" /*gga todo creation include */
&SCOPED-DEFINE ETATTRAITEMENTTRANSFERT-00013    "00013" /*gga todo creation include */
&SCOPED-DEFINE ETATTRAITEMENTTRANSFERT-00099    "00099" /*gga todo creation include */

using parametre.pclie.parametrageChaineTravaux.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{application/include/error.i}
{travaux/include/dossierTravaux.i}
{travaux/include/intervention.i}
{travaux/include/appelDefond.i}
{travaux/include/repartitionAV.i}
{travaux/include/suivifinancier.i}
{travaux/include/comptabilisationReliquat.i}
{travaux/include/editionAno.i}
{compta/include/tbTmpSld.i}
{compta/include/tbcptaprov.i}
{compta/include/ctrlclot.i}

function f-isNull returns logical private(pcChaine as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    return pcChaine = ? or pcChaine = "".
end function.

function lstcpthb returns character private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : gga todo voir comment rendre ce code commun ctrlclot.p
    ------------------------------------------------------------------------------*/
    define variable vcLstCptHb as character no-undo.
    define buffer aparm for aparm.

    for each aparm no-lock
        where aparm.tppar = "TSIFC"
          and aparm.cdpar begins "HB":
        vcLstCptHb = substitute('&1,&2', vcLstCptHb, aparm.zone2).
    end.
    return trim(vcLstCptHb, ',').

end function.
/*
function isExistAppelFonds returns logical private(piNumDossierTravaux as integer, piNumContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return can-find(first dosAp no-lock
        where dosAp.FgEmi = true
          and dosAp.tpcon = pcTypeContrat
          and dosAp.nocon = piNumContrat
          and dosAp.nodos = piNumDossierTravaux).

end function.
*/
function deMontantFactureTTC returns decimal private(piNumeroContrat as integer, piNumeroDossierTravaux as integer, output pdTotalFacturesHT as decimal):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vdTotalFacturesTTC as decimal no-undo.
    define variable viSens             as integer no-undo.  // 1 ou -1
    define variable viCodeSociete      as integer no-undo.

    define buffer devis  for devis.
    define buffer svdev  for svdev.
    define buffer itaxe  for itaxe.
    define buffer ordse  for ordse.
    define buffer dtord  for dtord.
    define buffer factu  for factu.
    define buffer dtfac  for dtfac.
    define buffer cecrln for cecrln.

    viCodeSociete = integer(mtoken:cRefGerance).
    for each ttListeIntervention
        break by ttListeIntervention.iNumeroIntervention:

        if last-of(ttListeIntervention.iNumeroIntervention)
        then do:
            if ttListeIntervention.cCodeTraitement = {&TYPEINTERVENTION-reponseDevis}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-accepte}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-termine}    // toutes les réponses, sauf acceptée et terminée
            then for each devis no-lock
                where devis.nodev = ttListeIntervention.iNumeroTraitement
              , first svdev no-lock
                where svdev.noint = ttListeIntervention.iNumeroIntervention
                  and svdev.nodev = devis.Nodev:
                find first itaxe no-lock
                    where itaxe.soc-cd  = viCodeSociete
                      and itaxe.taxe-cd = svdev.cdtva no-error.
                assign
                    pdTotalFacturesHT  = pdTotalFacturesHT  + svdev.mtint
                    vdTotalFacturesTTC = vdTotalFacturesTTC + svdev.mtint + (if available itaxe then round((svdev.mtint * itaxe.taux) / 100, 2) else 0)
                .
            end.
            if ttListeIntervention.cCodeTraitement = {&TYPEINTERVENTION-ordre2service}
            and (ttListeIntervention.cCodeStatut = {&STATUTINTERVENTION-enCours}
              or ttListeIntervention.cCodeStatut = {&STATUTINTERVENTION-relance})
            then for each ordse no-lock
                where ordse.noord = ttListeIntervention.iNumeroTraitement
              , first dtord no-lock
                where dtord.noint = ttListeIntervention.iNumeroIntervention
                  and dtord.noord = ordse.Noord:
                find first itaxe no-lock
                    where itaxe.soc-cd  = viCodeSociete
                      and itaxe.taxe-cd = dtord.cdtva no-error.
                assign
                    pdTotalFacturesHT  = pdTotalFacturesHT  + dtord.mtint
                    vdTotalFacturesTTC = vdTotalFacturesTTC + dtord.mtint + (if available itaxe then round((dtord.mtint * itaxe.taux) / 100, 2) else 0)
                .
            end.
            if ttListeIntervention.cCodeTraitement = {&TYPEINTERVENTION-facture}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-termine}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-bonAPayer}  // Toutes les factures, sauf terminées et bap
            then for each factu no-lock
                where factu.nofac = ttListeIntervention.iNumeroTraitement
                  and factu.fgcpt = false                                           // Non Comptabilisé
              , first dtfac no-lock
                where dtfac.noint = ttListeIntervention.iNumeroIntervention
                  and dtfac.nofac = factu.Nofac:
                assign
                    viSens             = if factu.fgfac then 1 else -1
                    vdTotalFacturesTTC = vdTotalFacturesTTC + factu.mtttc * viSens
                    pdTotalFacturesHT  = pdTotalFacturesHT + (factu.mtttc - factu.mttva) * viSens
                .
            end.
        end.
        /*--> Factures saisies en compta **/
        for each cecrln no-lock
            where cecrln.soc-cd     = viCodeSociete
              and cecrln.etab-cd    = piNumeroContrat
              and cecrln.sscoll-cle = "M"
              and cecrln.cpt-cd     = "00000"
              and cecrln.affair-num = piNumeroDossierTravaux:
            assign
                viSens             = if cecrln.sens then 1 else -1
                pdTotalFacturesHT  = pdTotalFacturesHT + (cecrln.mt - cecrln.mttva) * viSens
                vdTotalFacturesTTC = vdTotalFacturesTTC + cecrln.mt * viSens
            .
        end.
    end.
    return vdTotalFacturesTTC.

end function.

procedure SuppressionDossierTravaux:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:    service externe (beDossierTravaux.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttDossierTravaux.
    define input parameter table for ttError.

    define variable vlCtrlOk as logical no-undo.

    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then mError:createError({&error}, 4000011).  /* table ttDossierTravaux inexistante */
    else if ttDossierTravaux.CRUD <> "D"
    then mError:createError({&error}, 4000020). /* type CRUD n'est pas de type suppression */
    else do:
        run suppressionDossierTravauxCtrl(buffer ttDossierTravaux, output vlCtrlOk).
        if vlCtrlOk then run suppressionDossierTravauxMaj (ttDossierTravaux.cCodeTypeMandat, ttDossierTravaux.iNumeroMandat, ttDossierTravaux.iNumeroDossierTravaux).
    end.
    error-status:error = false no-error.  // reset error-status.
    return.                               // reset return-value.
end procedure.

procedure SuppressionDossierTravauxCtrl private:
    /*------------------------------------------------------------------------------
     Purpose:  extrait gesdossi.p procedure suppression
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plCtrlOk as logical no-undo.

    define buffer dosap  for dosap.
    define buffer trint  for trint.
    define buffer inter  for inter.
    define buffer cecrln for cecrln.

message "gga SuppressionDossierTravauxCtrl".

    /*--> Suppression impossible si appel de fond emis */
    /* Modif SY le 15/11/2007 -Fiche 1107/0116 : on se base sur tpconUse/NoconUse et les bases réelles */
    if can-find(first dosap no-lock
                where dosap.tpcon = ttDossierTravaux.cCodeTypeMandat
                  and dosap.nocon = ttDossierTravaux.iNumeroMandat
                  and dosap.nodos = ttDossierTravaux.iNumeroDossierTravaux
                  and dosap.fgemi
                  and Dosap.ModeTrait <> "M")    /* modif SY le 12/12/2008 : test pour VRAIS appels et non pas reconstitution histo */
    then do:
        mError:createError({&error}, 108152).
        return.
    end.
    /*--> Suppression impossible si facture sur le dossier */
    for each inter no-lock
        where inter.tpcon = ttDossierTravaux.cCodeTypeMandat
          and inter.nocon = ttDossierTravaux.iNumeroMandat
          and inter.nodos = ttDossierTravaux.iNumeroDossierTravaux
      , each trint no-lock
        where trint.noint = inter.noint
          and trint.tptrt = {&TYPEINTERVENTION-facture}:
        mError:createError({&error}, 108153).
        return.
    end.
    /*--> Suppression impossible dès lors qu'il y a des écritures sur le dossier */
    find first cecrln no-lock
        where cecrln.soc-cd     = integer(if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance else mtoken:cRefCopro)
          and cecrln.etab-cd    = ttDossierTravaux.iNumeroMandat
          and cecrln.affair-num = ttDossierTravaux.iNumeroDossierTravaux no-error.
    if available cecrln
    then mError:createError({&error}, 211662, substitute('&2&1&3&1&4', separ[1], cecrln.lib-ecr[1], cecrln.mt, cecrln.dacompta)).
    else if outils:questionnaire(100257, table ttError by-reference) > 2 then plCtrlOk = yes.      /* question confirmation suppression */

end procedure.

procedure appelSuppressionDossierTravaux:
    /*------------------------------------------------------------------------------
     Purpose: appel suppression dossier travaux depuis autre programme 
       Notes: service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat           as character no-undo.
    define input parameter piNumeroMandat         as integer   no-undo.
    define input parameter piNumeroDossierTravaux as integer   no-undo.

    run suppressionDossierTravauxMaj (pcTypeMandat, piNumeroMandat, piNumeroDossierTravaux).

end procedure.

procedure SuppressionDossierTravauxMaj private:
    /*------------------------------------------------------------------------------
     Purpose:  correspond au programme suptrdos.p (reprise adb/lib/suptrdos.p)
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat           as character no-undo.
    define input parameter piNumeroMandat         as integer   no-undo.
    define input parameter piNumeroDossierTravaux as integer   no-undo.

    define variable viNoCon as integer no-undo.

    define buffer trdos   for trdos.
    define buffer notes   for notes.
    define buffer inter   for inter.
    define buffer dosap   for dosap.
    define buffer doset   for doset.
    define buffer dosdt   for dosdt.
    define buffer dosrp   for dosrp.
    define buffer apbco   for apbco.
    define buffer entip   for entip.
    define buffer detip   for detip.
    define buffer trfpm   for trfpm.
    define buffer trfev   for trfev.
    define buffer ifdhono for ifdhono.

message "gga SuppressionDossierTravauxMaj".

    viNoCon = piNumeroMandat * 100000 + piNumeroDossierTravaux.  // integer(string(piNumeroMandat) + string(piNumeroDossierTravaux, "99999")).
    for each trdos exclusive-lock
        where trdos.tpcon = pcTypeMandat
          and trdos.nocon = piNumeroMandat
          and trdos.nodos = piNumeroDossierTravaux:
        /* suppression bloc-notes */
        if trdos.noblc > 0
        then for each notes exclusive-lock
            where notes.noblc = trdos.noblc:
            delete notes.
        end.
        for each inter exclusive-lock
            where inter.tpcon = trdos.tpcon
              and inter.nocon = trdos.nocon
              and inter.nodos = trdos.nodos:
            inter.nodos = 0.
        end.
        for each dosap exclusive-lock
            where dosap.tpcon = trdos.tpcon
              and dosap.nocon = trdos.nocon
              and dosap.nodos = trdos.nodos:
            delete dosap.
        end.
        for each doset exclusive-lock
            where doset.tpcon = trdos.tpcon
              and doset.nocon = trdos.nocon
              and doset.nodos = trdos.nodos:
            for each dosdt exclusive-lock
                where dosdt.noidt = doset.noidt:
                delete dosdt.
            end.
            delete doset.
        end.
        for each dosrp exclusive-lock
            where dosrp.tpcon = trdos.tpcon
              and dosrp.nocon = trdos.nocon
              and dosrp.nodos = trdos.nodos:
            delete dosrp.
        end.
        for each apbco exclusive-lock
            where apbco.tpbud = {&TYPEBUDGET-travaux} /*"01080"*/
              and apbco.nobud = viNoCon
              and (apbco.tpapp = {&TYPEAPPEL-dossierTravaux} or apbco.tpapp = {&TYPEAPPEL-clotureTravaux})
              and apbco.nomdt = piNumeroMandat:
            delete apbco.
        end.
        for each entip exclusive-lock
            where entip.nocon = viNoCon:
            delete entip.
        end.
        for each detip exclusive-lock
            where detip.nocon = viNoCon:
            delete detip.
        end.
        /* todo   whole index car il manque soc-cd présent sur tous les index  !!!!!!!!!!!!! si toutes sociétés, faire un for each isoc ...*/
        for each ifdhono exclusive-lock
            where ifdhono.etab-cd     = trdos.nocon
              and ifdhono.typefac-cle = "13"
              and ifdhono.affair-num  = trdos.nodos:
            delete ifdhono.
        end.
        for each trfpm exclusive-lock
            where trfpm.tptrf = {&TYPETRANSFERT-appel}
              and (trfpm.tpapp = {&TYPEAPPEL-dossierTravaux} or trfpm.tpapp = {&TYPEAPPEL-clotureTravaux})
              and trfpm.nomdt = trdos.nocon
              and trfpm.noexe = trdos.nodos:
            delete trfpm.
        end.
        for each trfev exclusive-lock
            where trfev.tptrf = {&TYPETRANSFERT-appel}
              and (trfev.tpapp = {&TYPEAPPEL-dossierTravaux} or trfev.tpapp = {&TYPEAPPEL-clotureTravaux})
              and trfev.nomdt = trdos.nocon
              and trfev.noexe = trdos.nodos:
            delete trfev.
        end.
        delete trdos.
    end.

end procedure.

procedure getDossierTravaux:
    /*------------------------------------------------------------------------------
    Purpose: extraction information pour un dossier travaux
    Notes  : service externe (beDossierTravaux.cls repartitionAV.p)
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define output parameter table for ttDossierTravaux.

    define variable vcTypeMandat           as character no-undo.
    define variable viNumeroMandat         as int64     no-undo.
    define variable viNumeroDossierTravaux as integer   no-undo.
    define variable vcNumeroImmeuble       as character no-undo.
    define variable vcLibelleImmeuble      as character no-undo.

    define buffer trdos for trdos.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer Imble for Imble.
    define buffer batim for batim.
    define buffer adres for adres.
    define buffer ladrs for ladrs.

    assign
        vcTypeMandat           = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        viNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
    .

message "debut getDossierTravaux "  vcTypeMandat "//" viNumeroMandat "//" viNumeroDossierTravaux .

    for first trdos no-lock
        where trdos.TpCon = vcTypeMandat
          and trdos.NoCon = viNumeroMandat
          and trdos.NoDos = viNumeroDossierTravaux:
        find first ctrat no-lock
            where ctrat.tpcon = trdos.TpCon
              and ctrat.nocon = trdos.Nocon no-error.
        /* Immeuble lié */
        for first intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.nocon = viNumeroMandat
              and intnt.tpcon = vcTypeMandat:
            for first Imble no-lock
                where Imble.noimm = intnt.noidt:
                assign
                    vcNumeroImmeuble  = string(imble.noimm)
                    vcLibelleImmeuble = imble.lbnom
                .
                find first batim no-lock
                    where batim.noimm = imble.noimm
                      and batim.cdbat = entry(1, trdos.LbDiv1, separ[1]) no-error.
            end.
            // chercher la ville
            for first ladrs no-lock
                where ladrs.tpadr = {&TYPEADRESSE-Principale}
                  and ladrs.tpidt = intnt.tpidt
                  and ladrs.noidt = intnt.noidt:
                find first adres no-lock
                    where adres.noadr = ladrs.noadr no-error.
            end.
        end.
        create ttDossierTravaux.
        assign
            ttDossierTravaux.CRUD                   = 'R'
            ttDossierTravaux.iNumeroDossierTravaux  = trdos.NoDos
            ttDossierTravaux.cLibelleDossierTravaux = trdos.LbDos
            ttDossierTravaux.iNumeroMandat          = trdos.nocon
            ttDossierTravaux.cCodeTypeMandat        = trdos.tpCon
            ttDossierTravaux.cLibelleMandat         = if available ctrat then ctrat.lbnom else ''
            ttDossierTravaux.iNumeroImmeuble        = vcNumeroImmeuble
            ttDossierTravaux.cLibelleImmeuble       = vcLibelleImmeuble
            ttDossierTravaux.daDateVote             = trdos.DtSig
            ttDossierTravaux.daDateDebut            = trdos.DtDeb
            ttDossierTravaux.daDateDebutChantier    = trdos.DtDebCha
            ttDossierTravaux.daDateFin              = trdos.DtFin
            ttDossierTravaux.cVille                 = if available adres then adres.lbvil else ""
            ttDossierTravaux.iDuree                 = trdos.NbDur
            ttDossierTravaux.cCodeDuree             = trdos.CdDur
            ttDossierTravaux.cLibelleDuree          = outilTraduction:getLibelle(if trdos.CdDur = "00002" then 705253 else 705013)          // Jours, Mois
            ttDossierTravaux.lUrgent                = (trdos.tpurg = "00001")
            ttDossierTravaux.lAppelDeFond           = (trdos.cdnat = "" or trdos.CdNat = "00002")
            ttDossierTravaux.cCodeBatiment          = entry(1, trdos.LbDiv1, SEPAR[1])
            ttDossierTravaux.cLibelleBatiment       = if available batim then batim.LbBat else ""
            ttDossierTravaux.lAApprouverEnAg        = trdos.nocon-dec <> ?
            /*ttDossierTravaux.lExistAppelFond        = isExistAppelFonds(trdos.NoDos,trdos.nocon,trdos.tpCon)*/ /*A quoi ça sert ?*/
            ttDossierTravaux.dRetenueGarantie       = trdos.TxDGr
            ttDossierTravaux.cTypePrevisionnel      = trdos.TpPrevis
            ttDossierTravaux.dMontantPrevisionnel   = trdos.MtPrevis
            ttDossierTravaux.daDateCloture          = trdos.DtRee
            ttDossierTravaux.cUtilisateurCloture    = trdos.cdcsy
            ttDossierTravaux.lMandatResilie         = ctrat.dtree <> ?
            ttDossierTravaux.daDateApprobationAG    = date(integer(trdos.nocon-dec))
            ttDossierTravaux.iNombreEcheance        = trdos.NbEch
            ttDossierTravaux.iCodeBaremeHonoraire   = trdos.NoHon
            ttDossierTravaux.cLibelleStatut         = outilTraduction:getLibelle(if trdos.dtree <> ? then 704868 else 103810)
            ttDossierTravaux.cCodePresentation      = trdos.CdPre
            ttDossierTravaux.cCdNat                 = trdos.CdNat
            ttDossierTravaux.iLoRep                 = trdos.LoRep
            ttDossierTravaux.cTpArr                 = trdos.TpArr
            ttDossierTravaux.cCdArr                 = trdos.CdArr
            ttDossierTravaux.dtTimestamp            = datetime(trdos.Dtmsy, trdos.hemsy)
            ttDossierTravaux.rRowid                 = rowid(trdos)
        .
    end.

end procedure.

procedure rechercheDossierTravaux:
    /*------------------------------------------------------------------------------
    Purpose: liste dossier travaux a partir d une selection sur immeuble, mandat
    Notes  : service externe (beDossierTravaux.cls a travers recherche etendue)
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define output parameter table for ttListeDossierTravaux.

    define variable viNumeroImmeuble  as integer   no-undo.
    define variable viNumeroImmeuble1 as integer   no-undo.
    define variable viNumeroImmeuble2 as integer   no-undo.
    define variable viNumeroMandat    as integer   no-undo.
    define variable viNumeroMandat1   as integer   no-undo.
    define variable viNumeroMandat2   as integer   no-undo.

    define buffer TrDos for trdos.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    assign
        viNumeroImmeuble  = poCollection:getInteger("iNumeroImmeuble")
        viNumeroImmeuble1 = poCollection:getInteger("iNumeroImmeuble1")
        viNumeroImmeuble2 = poCollection:getInteger("iNumeroImmeuble2")
        viNumeroMandat    = poCollection:getInteger("iNumeroMandat")
        viNumeroMandat1   = poCollection:getInteger("iNumeroMandat1")
        viNumeroMandat2   = poCollection:getInteger("iNumeroMandat2")
    .

message "debut rechercheDossierTravaux " viNumeroImmeuble "//" viNumeroImmeuble1 "//" viNumeroImmeuble2 "/////"
                                         viNumeroMandat   "//" viNumeroMandat1   "//" viNumeroMandat2.

    if viNumeroMandat <> ? and viNumeroMandat <> 0
    then assign
        viNumeroMandat1 = viNumeroMandat
        viNumeroMandat2 = viNumeroMandat
    .
    if viNumeroMandat1 = ? then viNumeroMandat1 = 0.
    if viNumeroMandat2 = ? or viNumeroMandat2 = 0
    then viNumeroMandat2 = 999999999.

    if viNumeroImmeuble <> ? and viNumeroImmeuble <> 0
    then assign
        viNumeroImmeuble1 = viNumeroImmeuble
        viNumeroImmeuble2 = viNumeroImmeuble
    .
    if viNumeroImmeuble1 = ? then viNumeroImmeuble1 = 0.
    if viNumeroImmeuble2 = ? or viNumeroImmeuble2 = 0
    then viNumeroImmeuble2 = 999999999.

message "rechercheDossierTravaux " viNumeroImmeuble "//" viNumeroImmeuble1 "//" viNumeroImmeuble2 "/////"
                                         viNumeroMandat   "//" viNumeroMandat1   "//" viNumeroMandat2.

    for each trdos no-lock
        where trdos.nocon >= viNumeroMandat1
          and trdos.nocon <= viNumeroMandat2
      , first intnt no-lock
        where intnt.tpcon = trdos.tpcon
          and intnt.nocon = trdos.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt >= viNumeroImmeuble1
          and intnt.noidt <= viNumeroImmeuble2:
        /*--> Si pas déjà créé */
        if not can-find(first ttListeDossierTravaux
            where ttListeDossierTravaux.cCodeTypeMandat       = trdos.tpcon
              and ttListeDossierTravaux.iNumeroMandat         = trdos.nocon
              and ttListeDossierTravaux.iNumeroDossierTravaux = trdos.nodos)
        then do:
            find first ctrat no-lock
                where ctrat.tpcon = trdos.tpcon
                  and ctrat.nocon = trdos.nocon no-error.
            /*--> Creation de la table de selection */
            create ttListeDossierTravaux.
            assign
                ttListeDossierTravaux.CRUD                  = 'R'
                ttListeDossierTravaux.iNumeroImmeuble       = intnt.noidt
                ttListeDossierTravaux.cCodeTypeMandat       = trdos.tpcon
                ttListeDossierTravaux.iNumeroMandat         = trdos.nocon
                ttListeDossierTravaux.iNumeroDossierTravaux = trdos.nodos
                ttListeDossierTravaux.daDateCreation        = trdos.dtcsy
                ttListeDossierTravaux.cLibelleDossier       = trdos.lbdos
                ttListeDossierTravaux.cCodeStatut           = string(trdos.dtree = ?, "00001/00002")
                ttListeDossierTravaux.lUrgent               = (trdos.tpurg = "00001")
                ttListeDossierTravaux.lVote                 = (trdos.dtsig <> ?)
                ttListeDossierTravaux.daDateVote            = trdos.dtsig
                ttListeDossierTravaux.daDateDebut           = trdos.dtdeb
                ttListeDossierTravaux.daDateFin             = trdos.dtfin
                ttListeDossierTravaux.dtTimestamp           = datetime(trdos.Dtmsy, trdos.hemsy)
                ttListeDossierTravaux.cLibelleStatut        = if trdos.dtree <> ?            // cloturé
                                                              then outilTraduction:getLibelle(704868)
                                                              else if available ctrat and ctrat.dtree <> ?  // résilié, en cours
                                                                   then outilTraduction:getLibelle(103404)
                                                                   else outilTraduction:getLibelle(103810)
                ttListeDossierTravaux.dtTimestamp           = datetime(trdos.dtmsy, trdos.hemsy)
                ttListeDossierTravaux.rRowid                = rowid(trdos)
            .
        end.
    end.

end procedure.

procedure creationModificationDosTravaux:
    /*------------------------------------------------------------------------------
    Purpose:   creation ou maj table principal (trdos) dossier travaux
    Notes:     service externe (beDossierTravaux.cls)  gga todo test avec l'appli
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttDossierTravaux.
    define variable viNumeroDossier as integer no-undo.
    define buffer trdos for trdos.

    repeat preselect each ttDossierTravaux   // Preselect car on a un index sur iNumeroDemandeDeDevis qu'on met à jour !!!
        where lookup(ttDossierTravaux.CRUD, "U,C") > 0:
        {&_proparse_ prolint-nowarn(noerror)}
        find next ttDossierTravaux.
        if ttDossierTravaux.iNumeroDossierTravaux = 0
        or ttDossierTravaux.iNumeroDossierTravaux = ?
        then do:
            find last trdos no-lock
                where trdos.TpCon = ttDossierTravaux.cCodeTypeMandat
                  and trdos.NoCon = ttDossierTravaux.iNumeroMandat no-error.
            viNumeroDossier = if available trdos then trdos.NoDos + 1 else 1.
            /* Combler les trous, TODO et si c'est plein ???  */
            if viNumeroDossier > 99
            then do viNumeroDossier = 1 to 99:
                if not can-find(first trdos no-lock
                    where trdos.TpCon = ttDossierTravaux.cCodeTypeMandat
                      and trdos.NoCon = ttDossierTravaux.iNumeroMandat
                      and trdos.nodos = viNumeroDossier) then leave.
            end.
            // todo : si viNumeroDossier > 99, gérer l'erreur !!!
            create trdos.
            assign
                trdos.TpCon = ttDossierTravaux.cCodeTypeMandat
                trdos.NoCon = ttDossierTravaux.iNumeroMandat
                trdos.NoDos = viNumeroDossier
                trdos.cdcsy = mtoken:cUser
                trdos.Dtcsy = today
                trdos.Hecsy = mtime
                ttDossierTravaux.iNumeroDossierTravaux = viNumeroDossier
            .
        end.
        else do:
            find first trdos exclusive-lock
                where trdos.TpCon = ttDossierTravaux.cCodeTypeMandat
                  and trdos.NoCon = ttDossierTravaux.iNumeroMandat
                  and trdos.NoDos = ttDossierTravaux.iNumeroDossierTravaux no-wait no-error.
            if outils:isUpdated(buffer trdos:handle, 'contrat: ', string(ttDossierTravaux.iNumeroMandat), ttDossierTravaux.dtTimestamp)
            then return.
            assign
                trdos.cdmsy = mtoken:cUser
                trdos.dtmsy = today
                trdos.hemsy = mtime
                ttDossierTravaux.dtTimestamp = datetime(trdos.dtmsy, trdos.hemsy)
            .
        end.
        assign
            trdos.LbDiv1    = ttDossierTravaux.cCodeBatiment + SEPAR[1] //+ STRING(ttDossierTravaux.NoLie)
            trdos.DtDeb     = ttDossierTravaux.daDateDebut
            trdos.DtFin     = ttDossierTravaux.daDateFin
            trdos.DtDebCha  = ttDossierTravaux.daDateDebutChantier
            trdos.DtSig     = ttDossierTravaux.daDateVote
            trdos.LbDos     = ttDossierTravaux.cLibelleDossierTravaux
            trdos.NbDur     = ttDossierTravaux.iDuree
            trdos.TpUrg     = if ttDossierTravaux.lUrgent then "00000" else "00001"
            trdos.nocon-dec = if ttDossierTravaux.lAApprouverEnAg then ttDossierTravaux.iNumeroMandat else ?
            trdos.MtPrevis  = ttDossierTravaux.dMontantPrevisionnel
        .
    end.

end procedure.

procedure getListeDossierTravaux:
    /*------------------------------------------------------------------------------
    Purpose:  liste des dossiers pour un mandat
    Notes:    service externe (beDossierTravaux.cls)
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define output parameter table for ttListeDossierTravaux.

    define variable vcTypeMandat   as character no-undo.
    define variable viNumeroMandat as int64     no-undo.

    define buffer trdos for trdos.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    assign
        vcTypeMandat   = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat = poCollection:getInteger("iNumeroMandat")
    .

message "debut getListeDossierTravaux "  vcTypeMandat "//" viNumeroMandat  .

    for each trdos no-lock
        where trdos.tpcon = vcTypeMandat
          and trdos.nocon = viNumeroMandat
      , first intnt no-lock
        where intnt.tpcon = trdos.tpcon
          and intnt.nocon = trdos.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        /*--> Si pas déjà créé */
        if not can-find(first ttListeDossierTravaux
            where ttListeDossierTravaux.cCodeTypeMandat       = vcTypeMandat
              and ttListeDossierTravaux.iNumeroMandat         = viNumeroMandat
              and ttListeDossierTravaux.iNumeroDossierTravaux = trdos.nodos)
        then do:
            find first ctrat no-lock
                where ctrat.tpcon = vcTypeMandat
                  and ctrat.nocon = viNumeroMandat no-error.
            /*--> Creation de la table de selection */
            create ttListeDossierTravaux.
            assign
                ttListeDossierTravaux.CRUD                  = 'R'
                ttListeDossierTravaux.iNumeroImmeuble       = intnt.noidt
                ttListeDossierTravaux.cCodeTypeMandat       = vcTypeMandat
                ttListeDossierTravaux.iNumeroMandat         = viNumeroMandat
                ttListeDossierTravaux.iNumeroDossierTravaux = trdos.nodos
                ttListeDossierTravaux.daDateCreation        = trdos.dtcsy
                ttListeDossierTravaux.cLibelleDossier       = trdos.lbdos
                ttListeDossierTravaux.cCodeStatut           = string(trdos.dtree = ?, "00001/00002")
                ttListeDossierTravaux.lUrgent               = (trdos.tpurg = "00001")
                ttListeDossierTravaux.lVote                 = (trdos.dtsig <> ?)
                ttListeDossierTravaux.daDateVote            = trdos.dtsig
                ttListeDossierTravaux.daDateDebut           = trdos.dtdeb
                ttListeDossierTravaux.daDateFin             = trdos.dtfin
                ttListeDossierTravaux.dtTimestamp           = datetime(trdos.Dtmsy, trdos.hemsy)
                ttListeDossierTravaux.cLibelleStatut        = if trdos.dtree <> ?            // cloturé
                                                              then outilTraduction:getLibelle(704868)
                                                              else if available ctrat and ctrat.dtree <> ?   // résilié, en cours
                                                                   then outilTraduction:getLibelle(103404)
                                                                   else outilTraduction:getLibelle(103810)
                ttListeDossierTravaux.dtTimestamp           = datetime(trdos.dtmsy, trdos.hemsy)
                ttListeDossierTravaux.rRowid                = rowid(trdos)
            .
        end.
    end.

end procedure.

procedure miseAJourIntervention:
    /*------------------------------------------------------------------------------
     Purpose: Rattachement Dossier - Interventions extrait gesdossi.p procedure validation)
     Notes:   service externe (beDossierTravaux.cls) gga todo test avec l'appli
    ------------------------------------------------------------------------------*/
    define input parameter table for ttDossierTravaux.
    define input parameter table for ttListeIntervention.

    define buffer Inter for Inter.

bloc:
    for first ttDossierTravaux transaction:
        for each ttListeIntervention:
            find first inter exclusive-lock
                where inter.noint = ttListeIntervention.iNumeroIntervention no-wait no-error.
            if outils:isUpdated(buffer inter:handle, 'inter: ', string(ttListeIntervention.iNumeroIntervention), ttListeIntervention.dtTimestamp)
            then undo bloc, leave bloc.

            assign
                inter.nodos = ttDossierTravaux.iNumeroDossierTravaux
                inter.cdmsy = mtoken:cUser
                inter.Dtmsy = today
                inter.Hemsy = mtime
                ttListeIntervention.dtTimestamp = datetime(inter.Dtmsy, inter.Hemsy)
            .
        end.
        /*--> Desaffecation Dossier - Interventions */
        for each inter exclusive-lock
            where inter.tpcon = ttDossierTravaux.cCodeTypeMandat
              and inter.nocon = ttDossierTravaux.iNumeroMandat
              and inter.nodos = ttDossierTravaux.iNumeroDossierTravaux:
            find first ttListeIntervention
                where ttListeIntervention.iNumeroIntervention = inter.noint no-error.
            if not available ttListeIntervention
            then assign
                inter.nodos = 0
                inter.cdmsy = mtoken:cUser
                inter.dtmsy = today
                inter.hemsy = mtime
                ttListeIntervention.dtTimestamp = datetime(inter.Dtmsy, inter.Hemsy)
            .
        end.
    end.

end procedure.

procedure miseAJourMtFactures:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:    service externe (beDossierTravaux.cls) gga todo test avec l'appli
    ------------------------------------------------------------------------------*/
    define input parameter table for ttDossierTravaux.

    define variable vdTotalFacture    as decimal no-undo.
    define variable vdTotalFactureTTC as decimal no-undo.
    define variable vdTotalFactureHT  as decimal no-undo.

    define buffer trdos for trdos.

blockFirst:
    for first ttDossierTravaux:
        if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Gerance}
        then do:
            find first trdos exclusive-lock
                where trdos.tpcon = ttDossierTravaux.cCodeTypeMandat
                  and trdos.nocon = ttDossierTravaux.iNumeroMandat
                  and trdos.NoDos = ttDossierTravaux.iNumeroDossierTravaux no-wait no-error.
            if outils:isUpdated(buffer trdos:handle, 'dossier: ', string(ttDossierTravaux.iNumeroMandat), ttDossierTravaux.dtTimestamp)
            then undo blockFirst, leave blockFirst.

            assign
                vdTotalFactureTTC = deMontantFactureTTC(ttDossierTravaux.iNumeroMandat, ttDossierTravaux.iNumeroDossierTravaux, output vdTotalFactureHT)
                vdTotalFacture    = if ttDossierTravaux.cTypePrevisionnel = "TTC" then vdTotalFactureTTC else vdTotalFactureHT
            .
            if trdos.mtfactu <> vdTotalFacture
            then assign
                trdos.mtfactu = vdTotalFacture
                trdos.dtmajMF = today
                trdos.hemajMF = mtime
            .
            assign
                trdos.fgdepas = (trdos.mtfactu > ttDossierTravaux.dMontantPrevisionnel)   // MAJ du flag dépassement
                trdos.cdmsy   = mtoken:cUser
                trdos.dtmsy   = today
                trdos.hemsy   = mtime
                ttDossierTravaux.dtTimestamp = datetime(trdos.Dtmsy, trdos.Hemsy)
            .
        end.
    end.

end procedure.

procedure getDossierTravauxComplet private:
    /*------------------------------------------------------------------------------
    Purpose: chargement de toutes les tables utiles pour cloture dossier
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define parameter buffer ttDossierTravaux for ttDossierTravaux.

    define variable vhProc as handle no-undo.

/*gga todo appel chargement de toute les table utiles pour le trt de cloture. voir apres si il ne faudrait pas plutot un dataset contenant
toutes ces tables avec appel du chargement 1 fois cote client pour eviter de recharger a chaque fois ici ou de faire les controles
directement sur les tables quand c'est possible */

    run travaux/dossierTravaux/appelDeFond.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run getAppelDeFond   in vhProc(poCollection,
                                   output table ttEnteteAppelDeFond by-reference,
                                   output table ttAppelDeFond by-reference,
                                   output table ttAppelDeFondRepCle by-reference,
                                   output table ttAppelDeFondRepMat by-reference,
                                   output table ttDossierAppelDeFond by-reference).
    run destroy in vhProc.

    run travaux/dossierTravaux/repartitionAV.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run getRepartitionAV in vhProc(poCollection,
                                   input-output table ttDossierTravaux by-reference,
                                   output table ttrepartitionAV by-reference,
                                   output table ttInfSelRepartitionAV by-reference,
                                   output table ttCombo by-reference).
    run destroy in vhProc.

    run travaux/dossierTravaux/suiviFinancier.p persistent set vhProc.
    run getTokenInstance  in vhProc(mToken:JSessionId).
    run getSuiviFinancier in vhProc(ttDossierTravaux.cCodeTypeMandat,                  /*gga equivalent gessodi.p ttListeSuiviFinancierClient.i */
                                    ttDossierTravaux.iNumeroMandat,
                                    ttDossierTravaux.iNumeroDossierTravaux,
                                    "LISTE",
                                    ?,
                                    output table ttListeSuiviFinancierClient by-reference,
                                    output table ttDetailSuiviFinancierClient by-reference,
                                    output table ttListeSuiviFinancierTravaux by-reference).
    run destroy in vhProc.

    run travaux/dossierTravaux/recapDossier.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run getrecapDossier  in vhProc(poCollection, output table ttRecapDossierTravaux by-reference).
    run destroy in vhProc.

end procedure.

procedure cloturedossiertravaux:
    /*------------------------------------------------------------------------------
    Purpose: correspond a procedure gesdossi.p 'ON "{&Change_Objet}" OF EmMenVer DO:'
    Notes  : service externe (beDossierTravaux.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttDossierTravaux.
    define input parameter table for ttError.
    define input-output parameter table for ttComptabilisationReliquat.
    define output parameter table for ttEdtAno.
    define output parameter table for ttTmpErr.
    define output parameter table for ttTmpCop.
    define output parameter table for ttApatTmp.
    define output parameter table for ttApipTmp.

    define variable voCollection    as class collection no-undo.
    define variable voChaineTravaux as class parametrageChaineTravaux no-undo.
    
    define variable vhProc        as handle    no-undo.
    define variable vlRetour      as logical   no-undo.
    define variable vlRetValid    as logical   no-undo.
    define variable vcRefOdt      as character no-undo.
    define variable viNoCodret    as integer   no-undo.
    define variable vcCHB         as character no-undo.
    define variable vdSolde       as decimal   no-undo.
    define variable vcLstCptHb    as character no-undo.
    define variable viRetQuestion as integer   no-undo.
    define variable viNoRefTrans  as integer   no-undo.

    define buffer ietab     for ietab.
    define buffer trdos     for trdos.
    define buffer ctrat     for ctrat.
    define buffer vbCtrat   for ctrat.
    define buffer ifdsai    for ifdsai.
    define buffer ifdln     for ifdln.
    define buffer aeappel   for aeappel.
    define buffer cecrsai   for cecrsai.
    define buffer cecrln    for cecrln.
    define buffer csscptcol for csscptcol.
    define buffer inter     for inter.
    define buffer vbEvent   for event.

    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then do:
        /* Table ttDossierTravaux inexistante */
        mError:createError({&error}, 4000011).
        return.
    end.


if 1 = 1 then mError:createError({&error}, 12345678). /*gga pour annuler toutes les maj en test*/


message "cloturedossiertravaux" ttDossierTravaux.cCodeTypeMandat
                                ttDossierTravaux.iNumeroMandat
                                ttDossierTravaux.iNumeroDossierTravaux
                                ttDossierTravaux.iNumeroImmeuble
                                mtoken:cRefCopro
                                mtoken:cRefGerance
                                mtoken:cRefPrincipale.
    assign
        viNoRefTrans = integer(if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
        voCollection = new collection()
    .
    voCollection:set('cTypeMandat',           ttDossierTravaux.cCodeTypeMandat) no-error.
    voCollection:set('iNumeroMandat',         ttDossierTravaux.iNumeroMandat) no-error.
    voCollection:set('iNumeroDossierTravaux', ttDossierTravaux.iNumeroDossierTravaux) no-error.
    voCollection:set('iNoImmUse',             ttDossierTravaux.iNumeroImmeuble) no-error.
    voCollection:set('cJSessionId',           mToken:JSessionId) no-error.
    voCollection:set('iNoRefTrans',           viNoRefTrans) no-error.

    /* gga todo pour le test sur mandat resilie relire la table ctrat ou se baser sur le champ ttDossierTravaux.lMandatResilie charge au moment du get */
    /* if ttDossierTravaux.lMandatResilie */
    find first ctrat no-lock
        where ctrat.tpcon = ttDossierTravaux.cCodeTypeMandat
          and ctrat.nocon = ttDossierTravaux.iNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 4000057). /* table ctrat inexistante */ /* gga normalement impossible */
        return.
    end.
    if ctrat.dtree <> ?
    then do:
        mError:createError({&error}, 4000024). /* mandat résilié, clôture impossible */
        return.
    end.
    /* LockDossier */
    find first trdos exclusive-lock
        where trdos.tpcon = ttDossierTravaux.cCodeTypeMandat
          and trdos.nocon = ttDossierTravaux.iNumeroMandat
          and trdos.nodos = ttDossierTravaux.iNumeroDossierTravaux no-wait no-error.
    if locked trdos
    then do:
        mError:createError({&error}, 4000057). /* table trdos (dossier travaux) bloqué par un autre utilisateur */
        return.
    end.
    if not available trdos
    then do:
        mError:createError({&error}, 4000058). /* table trdos (dossier travaux) inexistante */ /* gga normalement impossible */
        return.
    end.
    if trdos.dtree <> ?
    then do:
        mError:createError({&error}, 4000060). /* dossier déjà clôturé */
        return.
    end.
    run getDossierTravauxComplet (voCollection, buffer ttDossierTravaux).

    /* RF 0306/0215 - 17/07/08 */
    empty temp-table ttTmpSld.

    /* 0507/0226 */
    /*--> Pour un dossier 'Forfait = NON' , interdire la cloture si aucun appel n'a été créé*/
    /* trdos.cdnat = "00001" signifie 'Forfait = OUI' */
    if trdos.cdnat <> {&NATUREDOSSIER-forfait}
    and ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
    and trdos.cdcsy <> "MIGRATION GECOP"
    and not can-find(first ttAppelDeFond)
    then do:
        /* Impossible de clore le dossier. Aucun appel de fonds n'a été émis ! */
        mError:createError({&error}, 4000001).
        return.
    end.

    for each ifdsai no-lock
        where ifdsai.soc-dest = viNoRefTrans
          and ifdsai.etab-dest = ttDossierTravaux.iNumeroMandat
          and ifdsai.fg-edifac = false
      , each ifdln no-lock
        where ifdln.soc-cd     = ifdsai.soc-cd
          and ifdln.etab-cd    = ifdsai.etab-cd
          and ifdln.com-num    = ifdsai.com-num
          and ifdln.affair-num = ttDossierTravaux.iNumeroDossierTravaux:
        /* Impossible de clore le dossier. La facture &1 du &2 est provisoire ! */
        mError:createError({&error},
                           4000003,
                           substitute('&2&1&3&1&4', separ[1], ifdsai.com-num, string(ifdsai.dafac, "99/99/9999"), "", "")).
        return.
    end.

    /*--> Impossible de clore si lot de répartition nul ou inconnue */
    if ttDossierTravaux.cCodeTypeMandat <> {&TYPECONTRAT-mandat2Gerance}
    then do: /**Ajout du test par OF le 13/09/11**/
        find first ttRepartitionAV
            where ttRepartitionAV.iNoLot = ttDossierTravaux.iLoRep no-error.
        if ttDossierTravaux.iLoRep = 0
        or ttDossierTravaux.iLoRep = ?
        or not available ttRepartitionAV
        then do:
            find first ttEnteteAppelDeFond no-error.
            if available ttEnteteAppelDeFond
            or ttDossierTravaux.cCdNat = {&NATUREDOSSIER-forfait} /* "00001" */
            or not available ttRepartitionAV
            then do:
                mError:createError({&error}, 108149).
                return.
            end.
        end.
    end.

/*gga todo zone ttAppelDeFond.FgRepDef non utilise voir dans appeldefond.p */
        /* Ajout SY le 14/10/2008 : impossible si la répartition manuelle est Provisoire */
    if can-find(first ttAppelDeFond
                where ttAppelDeFond.cModeTraitement = "M")
/*gga              gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
                 and ttAppelDeFond.FgRepDef = false)
gga*/
    then do:
        mError:createError({&error}, 4000023).     // Impossible de clore le dossier. Il reste des appels manuels dont la répartition est PROVISOIRE
        return.
    end.

/*gga todo remettre apres test
    /*--> Impossible s'il y a des appels de fonds à emettre */
    if can-find(first ttAppelDeFond
                where ttAppelDeFond.cModeTraitement <> "M"
                  and ttAppelDeFond.lFlagEmis = no)
    then do:
        mError:createError({&error}, 4000004).    // Impossible de clore le dossier. Il reste des appels de fonds à émettre
        return.
    end.
    /*--> Impossible s'il le dernier appel n'est pas receptionné et incorporé en compta */
    if ttDossierTravaux.cCodeTypeMandat ne {&TYPECONTRAT-mandat2Gerance}
    then for last ttAppelDeFond    /**Ajout du test par OF le 13/09/11**/
        where ttAppelDeFond.cModeTrait <> "M":
        if not can-find(first trfpm no-lock
            where trfpm.tptrf = {&TYPETRANSFERT-appel}
              and trfpm.tpapp = {&TYPEAPPEL-dossierTravaux}
              and trfpm.nomdt = ttDossierTravaux.iNumeroMandat
              and trfpm.noexe = ttDossierTravaux.iNumeroDossierTravaux
              and trfpm.noapp = ttAppelDeFond.iNumeroAppel
              and (trfpm.ettrt = {&ETATTRAITEMENTTRANSFERT-00003}
                or trfpm.ettrt = {&ETATTRAITEMENTTRANSFERT-00013}
                or trfpm.ettrt = {&ETATTRAITEMENTTRANSFERT-00099})) /* NP 02/02/12 add pour dossier dupliqué */
        /* Ajout SY le 14/11/2008 - Fiche 0708/0126 : si duplication de mandat trfpm n'existe pas */
        /* => vérifier la présence de la répartition */
        and not can-find(first apbco no-lock
            where apbco.tpbud = {&TYPEBUDGET-travaux}
              and apbco.nobud = INT(string(ttDossierTravaux.iNumeroMandat) + STRING(ttDossierTravaux.iNumeroDossierTravaux,"99999"))
              and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
              and apbco.noapp = ttAppelDeFond.iNumeroAppel
              and apbco.nomdt = ttDossierTravaux.iNumeroMandat)
        then do:
            mError:createError({&error}, 4000005).    // Impossible de clore le dossier. Vous n'avez pas comptabilisé votre dernier appel
            return.
        end.
    end.
gga*/

    /*-------------------------------------------------------------------------------------------
    0508/0072 : Lancement de la fenètre 'Répartition Acheteur / Vendeur' en premier
    -------------------------------------------------------------------------------------------*/

    /**Ajout OF le 05/06/08 - Appel Frame Répartition Acheteur/Vendeur en modification**/
    if ttDossierTravaux.cCodeTypeMandat <> {&TYPECONTRAT-mandat2Gerance}
    then do: /**Ajout du test par OF le 13/09/11**/
        run validationDossier (buffer ttDossierTravaux, output vlRetValid).
        /*gga normalement message erreur cree dans la procedure ValidationDossier */
        if not vlRetValid then return.
    end.

    /*-------------------------------------------------------------------------------------------
                  0508/0072 : Factures d"honoraires
    -------------------------------------------------------------------------------------------*/
    /*--> Generation des Factures d'Honoraires */
    voChaineTravaux = new parametrageChaineTravaux().
    if voChaineTravaux:isFactureHonoraire() then run genHonoraire (buffer ttDossierTravaux).
    delete object voChaineTravaux.
    /*-------------------------------------------------------------------------------------------
             0508/0072 : Lancement de la fenètre qui récapitule la cloture
    -------------------------------------------------------------------------------------------*/
    /*gga todo a revoir :
    pour l'instant pas d'appel de gesclotu.p pour affichage de l'ecran recap et suite du trt de cloture mais les
    calcul recap sont fait avant dans le pgm recapdossier.p avec creation table ttRecapDossierTravaux */
    find first ttRecapDossierTravaux no-error.
    if not available ttRecapDossierTravaux                        /*gga normalement impossible table doit toujours exister */
    then do:
        mError:createError({&error}, 4000061).  /* table recapitulatif dossier travaux inexistante */
        return.
    end.

    /*-------------------------------------------------------------------------------------------
         0508/0072 : Verifier s'il existe des factures d'honoraire non comptabilisées sur le dossier
    -------------------------------------------------------------------------------------------*/
    if ttRecapDossierTravaux.dHonManuFacturer <> ?
    and ttRecapDossierTravaux.dHonManuFacturer <> 0
    then do:
        /*gga todo a revoir mais si la reponse a la question suivante est oui, alors appel pgm CADB\EXE\FDIV\ldfac01.r (ON "CHOOSE"
        OF HwBtnHonManuCptProv dans gesclotu.p) donc l'appli devrait ouvrir directement ce pgm et dans les 2 cas de reponse oui
        ou non arret du trt de cloture (donc ici affichage message et fin trt cloture) */
        /* Il reste des factures manuelles d'honoraires non comptabilisées. Voulez-vous les comptabiliser ? */
        mError:createError({&question}, 4000006).
/*ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg*/
        return.
    end.
    else do:
        viRetQuestion = outils:questionnaire(4000032, table ttError by-reference).
        if viRetQuestion < 2 then return.
        /*gga todo a revoir mais si la reponse a la question suivante est oui, alors appel pgm CADB\EXE\FDIV\ldfac01.r (ON "CHOOSE"
        OF hHwBtnHonAuto dans gesclotu.p) donc l'appli devrait ouvrir directement ce pgm
        si reponse non on continue le trt de cloture si oui voir si pgm lance directement depuis l'appli si ensuite
        reappel cloture avec non comme repo,se pour continuer le trt de cloture
        if viRetQuestion = 3 then do:
            /* ?????????????? */
        end.
        */
    end.

message "cloturedossier apres 400006".

/*ggg procedure FinCloturea et FinCloture2 pas reprise car FinCloture2 est appele par FinCloture1 qui n'est jamais appele
et code de FinCloture3 deplace ici  */

    /*
    0208/0368 : PL le 13/05/2008 : Controle des soldes comptables lors de la cloture du dossier
    Ce controle est issu des transferts (copro.w)
    */
    /**Ajout OF le 13/09/11**/
    if ttDossierTravaux.cCodeTypeMandat <> {&TYPECONTRAT-mandat2Gerance}
    then do:
        run controleCompta("CLOTURE", voCollection, buffer trdos, buffer ctrat, buffer ttDossierTravaux, output vlRetour).
        if vlretour = no then return.
    end.

    /**Ajout OF le 02/06/08 - Confirmation de la cloture**/
    /* recherche si retour dans le traitement apres etre passe une premiere fois et posé la question */
    viRetQuestion = outils:questionnaire(4000033, table ttError by-reference).
    if viRetQuestion <= 2 then return.

    /* RF 18/07/08 -                                             */
    /* En cas de retirage, il est nécessaire d'annuler ou        */
    /* contrepasser l'eventuelle ODT de solde des CHB            */
    /* qui est gérée le bloc suivant                             */

message "cloture dossier avant Solde1060 " ttDossierTravaux.cCodeTypeMandat.

    /**Ajout OF le 13/09/11**/
    if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Gerance} /* "01030" */
    then run solde1060 (input-output voCollection, buffer ttDossierTravaux).
    /** **/
    else do:

message "gga cloture dossier travaux avant appel supodtx.p : " trdos.lbdiv2.

        if num-entries(trdos.lbdiv2, "|") = 6 then do:
/*gga
            {RunPgExp.i &Path       = RpRunLie
                        &Prog       = "'supodtx.p'"
                        &Parameter  = "INPUT INTEGER(NoRefUse)                       /** Ref        **/
                                      ,INPUT ttDossierTravaux.iNumeroMandat          /** Mandat     **/
                                      ,INPUT ttDossierTravaux.iNumeroDossierTravaux  /** N° Dossier **/
                                      ,INPUT trdos.lbdiv2                            /** Reference pièce a annuler **/
                                      ,OUTPUT NoCodret" }
gga*/

            voCollection:set('trdos-lbdiv2', trdos.lbdiv2) no-error.

            run compta/souspgm/supodtx.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            run supodtxAnnulOd in vhProc(voCollection, output viNoCodret).
            run destroy in vhProc.
            /*gga todo voir pour message erreur non gere dans supodtx.p */
            if viNoCodret <> 0 then return.
        end.

message "gga cloture dossier travaux apres appel supodtx.p : " viNoCodret.

        /* RF 17/07/08 - A ce stade, la cloture est possible         */
        /* la table ttTmpSld contient les infos du dossier par copro */
        /* --> mtappcx  (charges)                                    */
        /* --> mtappan  (recettes)                                   */
        /* Il reste a calculer les soldes des CHB de ce dossier      */
        /* --> mtsolde                                               */
        /* Puis a déduire le montant de l'ODT à passer pour solder   */
        /* le CHB.                                                   */
        /* --> mtodt = mtappan - mtappcx - mtsolde                                                */
        /* 4 champs distincts facilitent le débogage!                */
        vcLstCptHb = lstCptHb().
        for first csscptcol no-lock
            where csscptcol.soc-cd = integer(mtoken:cRefPrincipale)
              and csscptcol.etab-cd = ttDossierTravaux.iNumeroMandat
              and csscptcol.coll-cle = "C"
              and lookup(csscptcol.sscoll-cpt, vcLstCptHb) > 0:
            vcCHB = csscptcol.sscoll-cpt.
        end.
        find first ietab no-lock
            where ietab.soc-cd = viNoRefTrans
              and ietab.etab-cd = ttDossierTravaux.iNumeroMandat no-error.
        run compta/souspgm/solcptch.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        for each ttTmpSld:
message "gga cloture dossier travaux avant appel SolCptCh.p : ".
            voCollection:set('iCodeSoc',    integer(mtoken:cRefPrincipale)) no-error.
            voCollection:set('cCpt',        vcCHB) no-error.
            voCollection:set('cCssCpt',     ttTmpSld.nocop) no-error.
            voCollection:set('daDateSolde', ietab.dafinex2) no-error.
            voCollection:set('lExtraCpta',  false) no-error.
            run solcptchCalculSolde in vhProc (input-output voCollection).
            ttTmpSld.mtsolde = voCollection:getDecimal("dSolde").
message "gga cloture dossier travaux apres appel SolCptCh.p : " vdSolde.
            /* DM 0409/0131 Pour un retirage la pièce CPHB/ODCP2 sera supprimée au retour, il faut donc la déduire du calcul du solde */
            for last aeappel no-lock
                where aeappel.soc-cd = integer(mtoken:cRefPrincipale)
                  and aeappel.etab-cd = ietab.etab-cd
                  and aeappel.natjou-gi = "72"     /* CPHB */
                  and aeappel.appel-num begins string(ttDossierTravaux.iNumeroDossierTravaux, "99")
              , first cecrsai no-lock
                where cecrsai.soc-cd    = aeappel.soc-cd
                  and cecrsai.etab-cd   = aeappel.etab-cd
                  and cecrsai.jou-cd    = aeappel.jou-cd
                  and cecrsai.prd-cd    = aeappel.prd-cd
                  and cecrsai.prd-num   = aeappel.prd-num
                  and cecrsai.piece-int = aeappel.piece-int
              , each cecrln no-lock
                where cecrln.soc-cd         = cecrsai.soc-cd
                  and cecrln.mandat-cd      = cecrsai.etab-cd
                  and cecrln.jou-cd         = cecrsai.jou-cd
                  and cecrln.mandat-prd-cd  = cecrsai.prd-cd
                  and cecrln.mandat-prd-num = cecrsai.prd-num
                  and cecrln.piece-int      = cecrsai.piece-int
                  and cecrln.etab-cd        = ietab.etab-cd
                  and cecrln.sscoll-cle     = "CHB"
                  and cecrln.cpt-cd         = string(ttTmpSld.nocop, "99999")
                  and cecrln.affair-num     = ttDossierTravaux.iNumeroDossierTravaux:
                ttTmpSld.mtsolde = ttTmpSld.mtsolde + (cecrln.mt * (if cecrln.sens then -1 else 1)).
            end.
            /* Montant ODT de solde CHB dossier en cours. + = DEBIT / - = CREDIT */
            ttTmpSld.mtodt = ttTmpSld.mtappan - ttTmpSld.mtappcx - ttTmpSld.mtsolde.
        end. /* for each ttTmpSld */
        run destroy in vhProc.

        /* 0306/0215 - Solde éventuel des CHB avec plafond */
        /** 1209/0192 **/
        for each ttTmpSld
          , first vbCtrat no-lock
            where vbCtrat.tpcon = {&TYPECONTRAT-titre2copro}
              and vbCtrat.nocon = integer(string(ttTmpSld.nomdt, "99999") + string(ttTmpSld.nocop, "99999"))
              and num-entries(vbCtrat.lbdiv, "#") >= 4
              and entry(4, vbCtrat.lbdiv, "#") = "22005": /** Mode de règlement = compensation **/
            ttTmpSld.mtodt = 0.
        end.
message "gga cloturedossiertravaux avant appel comptabilisationReliquat.p".
for each tterror:
    message tterror.iErrorId tterror.itype.
end.

        /* ici ce n'est pas une question utilisateur, mais on gère avec le meme methode pour
        indiquer que ce traitement a deja ete realise */
        /* gga todo et à ce retour Nicolas doit appeler le trt de validation reliquat dans
        beComptabilisationReliquat.cls */
        if outils:questionnaire(4000034, table ttError by-reference) <= 2
        then do:
            run compta/souspgm/comptabilisationReliquat.p persistent set vhProc.     // ex soldechb.p
            run getTokenInstance in vhProc(mToken:JSessionId).
            run initialisationTrt in vhProc(voCollection, output table ttComptabilisationReliquat by-reference).
            run destroy in vhProc.
message "gga cloturedossiertravaux apres appel comptabilisationReliquat.p dans le if".
            return.
        end.

message "gga cloturedossiertravaux apres appel comptabilisationReliquat.p".

        for first ttComptabilisationReliquat:
message "gga cloturedossiertravaux avant appel odreltx.p".
            voCollection:set('iSociete',            integer(mtoken:cRefPrincipale)) no-error.
            voCollection:set('iNumDossier',         ttComptabilisationReliquat.iNumDossier) no-error.
            voCollection:set('daComptable',         ttComptabilisationReliquat.daDateComptable) no-error.
            voCollection:set('cLibelle',            ttComptabilisationReliquat.cLibelle) no-error.
            voCollection:set('cJournal',            ttComptabilisationReliquat.cJournal) no-error.
            voCollection:set('cTypeMouvement',      ttComptabilisationReliquat.cTypeMouvement) no-error.
            voCollection:set('cCodCollectif01',     ttComptabilisationReliquat.cCodCollectif01) no-error.
            voCollection:set('cCodCollectif02',     ttComptabilisationReliquat.cCodCollectif02) no-error.
            voCollection:set('lLimitePlafond',      ttComptabilisationReliquat.lLimitePlafond) no-error.
            voCollection:set('dConfirmPlafond',     ttComptabilisationReliquat.dConfirmPlafond) no-error.
            voCollection:set('lCloture',            true) no-error.
            voCollection:set('lCoproDebUniquement', ttComptabilisationReliquat.lCoproDebUniquement) no-error.
            run compta/souspgm/odreltx.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            run odreltxComptReliquat in vhProc(voCollection,
                input-output table ttTmpSld by-reference,
                input-output table ttListeSuiviFinancierClient by-reference,
                output viNoCodret,
                output vcRefOdt).                                /* Clé de la pièce générée */
            run destroy in vhProc.
            if viNoCodRet <> 0 then
/*gga       RUN GestMess IN HdLibPrc(2,"",110131,"",STRING(NoCodret),"ERROR",OUTPUT FgExeMth). gga*/
                mError:createError({&error}, 110131). /* gga todo a voir pour affichage nocodret */
        end. /* IF cdParUse NE "" */
    end. /* ELSE IF pcTypeContrat = "01030" */
    assign
        trdos.dtree  = today
        trdos.cdRee  = mToken:cUser
        trdos.lbdiv2 = vcRefOdt
    .
    /* Ajout SY le 12/11/2008 : cloture de tous les evènements liés aux interventions du dossier */
    for each inter no-lock
        where inter.tpcon = ttDossierTravaux.cCodeTypeMandat
          and inter.nocon = ttDossierTravaux.iNumeroMandat
          and inter.nodos = ttDossierTravaux.iNumeroDossierTravaux
      , each vbEvent exclusive-lock
        where vbEvent.tpcon = ttDossierTravaux.cCodeTypeMandat
          and vbEvent.nocon = ttDossierTravaux.iNumeroMandat
          and vbEvent.noint = inter.noint:
        assign
            vbEvent.cdsta  = "00002"
            vbEvent.dtree  = today
            vbEvent.heree  = time
            vbEvent.cdree  = mToken:cUser
            vbEvent.lbdiv1 = "CLOTURE DOSSIER TRAVAUX NO " + string(ttDossierTravaux.iNumeroDossierTravaux , "99999")
            vbEvent.dtmsy  = today
            vbEvent.hemsy  = time
            vbEvent.cdmsy  = mToken:cUser
        .
    end.

end procedure.

procedure GenHonoraire private:
    /*------------------------------------------------------------------------------
    Purpose: Generation des factures d'honoraires sur cloture
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.

    define variable vdMontantHonoraireApp as decimal no-undo.
    define variable vdMontantHonoraireFac as decimal no-undo.
    define variable vdaIncUse as date no-undo.
    define variable vhTva as handle no-undo.

    define buffer ietab for ietab.
    define buffer agest for agest.
    define buffer DosEt for DosEt.
    define buffer dosdt for dosdt.
    define buffer ifdhono for ifdhono.

message "GenHonoraire ".

    for first ietab no-lock
        where ietab.soc-cd  = integer(if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
          and ietab.etab-cd = ttDossierTravaux.iNumeroMandat
      , first agest no-lock
        where agest.soc-cd   = ietab.soc-cd
          and agest.gest-cle = ietab.gest-cle:
        assign
            vdaIncUse = maximum(today, add-interval(agest.dadeb, -1, "months"))
            vdaIncUse = minimum(vdaIncUse, agest.dafin)
        .
    end.
    if vdaIncUse = ?
    then do:
        /* Génération des Factures d'honoraire impossible.Aucune période comptable pour le gestionnaire */
        mError:createError({&information}, 4000031).
        return.
    end.

    run compta/outilsTVA.p persistent set vhTva.
    run getTokenInstance in vhTva(mToken:JSessionId).
    for each doset no-lock
        where doset.tpcon = ttDossierTravaux.cCodeTypeMandat
          and doset.nocon = ttDossierTravaux.iNumeroMandat
          and doset.nodos = ttDossierTravaux.iNumeroDossierTravaux
          and doset.tpapp = {&TYPEAPPEL2FONDS-honoraire}
          and doset.tpsur = "00001"
      , each dosdt no-lock
        where dosdt.noidt = doset.noidt
          and dosdt.cdapp > ""
        break by dosdt.noidt by dosdt.cdapp:

        /*--> Si premiere occurence de clé pour l'appel : initialisation des cumuls par clés */
        if first-of(dosdt.cdapp) then do:
            assign
                vdMontantHonoraireFac = 0
                vdMontantHonoraireApp = 0
            .
            /*--> Cumul des montants d'honoraires facturés pour cet appel et pour cette la clé */
            for each ifdhono no-lock
                where ifdhono.soc-cd      = integer(if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                  and ifdhono.etab-cd     = ttDossierTravaux.iNumeroMandat
                  and ifdhono.NoIdt       = DosDt.NoIdt
                  and ifdhono.ana4-cd     = dosdt.cdapp
                  and ifdhono.typefac-cle = (if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic} then "13" else "14"):
                vdMontantHonoraireFac = vdMontantHonoraireFac + ifdhono.Mt.
            end.
        end.

        /*--> Honoraire appelé */
        vdMontantHonoraireApp = vdMontantHonoraireApp + dosdt.mtapp.

        /*--> Derniere occurence de clé de l'appel : creation de la facture d'hononaire =  montant appelé - déjà facturé */
        if last-of(dosdt.cdapp) then do:
            assign
                /*--> Calcul du montant NET appelé */
                vdMontantHonoraireApp = round(vdMontantHonoraireApp - dynamic-function("calculTVAdepuisTTC" in vhTva, doset.CdTva, vdMontantHonoraireApp), 2)
                /*--> Nouveau montant d'honoraire */
                vdMontantHonoraireFac = vdMontantHonoraireApp - vdMontantHonoraireFac
            .
            /*--> Generation de la facture */
            if vdMontantHonoraireFac <> 0
            then do:
                create ifdhono.
                assign
                    ifdhono.soc-cd      = integer(if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                    ifdhono.etab-cd     = doset.nocon
                    ifdhono.affair-num  = doset.nodos
                    ifdhono.mois-cpt    = year(vdaIncUse) * 100 + month(vdaIncUse)
                    ifdhono.daech       = vdaIncUse
                    ifdhono.noidt       = doset.noidt
                    ifdhono.fg-compta   = false
                    ifdhono.typefac-cle = string(ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic}, "13/14")
                    ifdhono.mt          = vdMontantHonoraireFac
                    ifdhono.taxe-cd     = doset.cdtva
                    ifdhono.ana4-cd     = dosdt.cdapp
                    ifdhono.lib         = "Honoraires Travaux Dossier n° " + string(doset.nodos, "99")   /*gga todo voir si utiliser traduction */
                .
            end.
        end.
    end.
    run destroy in vhTva.

end procedure.

procedure ControleCompta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt    as character no-undo.
    define input parameter poCollection as collection no-undo.
    define parameter buffer trdos for trdos.
    define parameter buffer ctrat for ctrat.
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plRetourOk as logical no-undo.

    define variable vcFichierTest as character no-undo.
    define variable viNoLgn       as integer   no-undo.
    define variable vlFgSolde     as logical   no-undo initial true.
    define variable vlRetourOk    as logical   no-undo.
    define variable vhProc        as handle    no-undo.

message "gga debut ControleCompta".

    empty temp-table ttEdtAno.
    /** On ne fait pas le test pour un dossier cloturé d'un mandat dupliqué **/
    /** On ne fait pas le test pour un mandat résilié **/
    if ctrat.dtree = ? and (not trdos.cdcsy matches "*@DUPLI*" or trdos.dtree = ?)
//    if (trdos.cdcsy matches "*@DUPLI*" and trdos.dtree <> ?) or ctrat.dtree <> ? then . else ....
    then for each ttListeSuiviFinancierClient
        where ttListeSuiviFinancierClient.lAnomalie:
        vlFgSolde = false.
        if pcTypeTrt <> "TEST SUR TOUTE LA BASE"
        then do:
            create ttEdtAno.
            assign
                viNoLgn         = viNoLgn + 1
                ttEdtAno.cClass = string(viNoLgn, "9999999999")
                ttEdtAno.cLigne = " "
                viNoLgn         = viNoLgn + 1
            .
            create ttEdtAno.
            assign
                ttEdtAno.cClass = string(viNoLgn, "9999999999")
                ttEdtAno.cLigne = substitute("COPROPRIETAIRE : &1 &2, MANDAT : &3 - DOSSIER : &4", string(ttListeSuiviFinancierClient.iNumeroCoproprietaire, ">>>>9"), ttListeSuiviFinancierClient.cNomCoproprietaire, string(ttDossierTravaux.iNumeroMandat), string(ttDossierTravaux.iNumeroDossierTravaux))    /* 0411/0087 */
                viNoLgn         = viNoLgn + 1
            .
            create ttEdtAno.
            assign
                ttEdtAno.cClass = string(viNoLgn, "9999999999")
                ttEdtAno.cLigne = substitute("DIFFERENCE ENTRE LE SOLDE COMPTABLE DU COMPTE CHB &1 ET LA COLONNE 'Reste Du'", string(ttListeSuiviFinancierClient.iNumeroCoproprietaire, ">>>>9"))
                viNoLgn         = viNoLgn + 1
            .
            create ttEdtAno.
            assign
                ttEdtAno.cClass = string(viNoLgn, "9999999999")
                ttEdtAno.cLigne = "          COLONNE 'Reste Du' Hors appels manuels : " + string(ttListeSuiviFinancierClient.dMontantResteDu, "->>>,>>>,>>9.99")
            .
        end. /* if pcTypeTrt <> "TEST SUR TOUTE LA BASE" */
    end.

    if vlFgSolde = no and pcTypeTrt <> "TEST SUR TOUTE LA BASE"
    then do:
        /* Il y a des écarts entre le solde des copropriétaires et la colonne 'Reste du' hors appels manuels ! */
        mError:createError({&error}, 4000041).
        /* La clôture du dossier est impossible */
        mError:createError({&error}, 4000042).
        return.
    end.
    if vlFgSolde = no and pcTypeTrt = "TEST SUR TOUTE LA BASE"
    then do:
        vcFichierTest = session:temp-directory + "adb/tmp/gesdossi_test_toute_la_base.lg". /*todo replace (RpRunTrv,"adb\exe\trav\","adb\tmp\") + "gesdossi_test_toute_la_base.lg". */
        output to value(vcFichierTest) append.
        put unformatted
            skip " "
            skip "Anomalies au niveau du suivi financier client : "
                 if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance
            " " ttDossierTravaux.iNumeroMandat
            " " ttDossierTravaux.iNumeroDossierTravaux
            " " trdos.cdcsy
            " le " trdos.dtcsy
            " date de cloture : " trdos.dtree
            skip
        .
        output close.
    end.
    if pcTypeTrt = "TEST SUR TOUTE LA BASE" then return.

    /*---------------------------------- SIMULATION DU FICHIER DE TRANSFERT ------------------------------------------------*/
message "gga avant appel ctrltrav.p".
    run compta/souspgm/ctrltrav.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run controleTrav in vhProc(poCollection,
                               input-output table ttTmpSld by-reference,
                               table ttError by-reference,
                               output table ttTmpErr by-reference,
                               output vlRetourOk).
    run destroy in vhProc.
    if vlRetourOk = no then return.

message "gga avant ctrllot.p ".

    if pcTypeTrt <> "TESTCLOTURE"
    then do:
        /** Pas d'erreurs: contrôle des soldes des copros aprês la clôture
        Pour l'instant , réservé aux tests et à INS **/
        if ((integer(mtoken:cRefPrincipale) >= 6500 and integer(mtoken:cRefPrincipale) <= 6550) or mToken:cUser = "INS")
        and outils:questionnaire(4000056, table ttError by-reference) <= 2
            /* ici ce n'est pas une question utilisateur, mais on gere avec le meme methode pour
            indiquer que ce traitement a deja ete realise */
        then do:
            run compta/souspgm/ctrlclot.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            run ctrlclotControleLot in vhProc(poCollection,
                                              table ttTmpSld by-reference,
                                              output table ttTmpCop by-reference,
                                              output table ttApatTmp by-reference,
                                              output table ttApipTmp by-reference).
            return.
        end.
    end.
    else trdos.nocon-dec = decimal(today).     /*gga lu en exclusive-lock dans cloturedossiertravaux et passe en parameter buffer */
    plRetourOk = yes.

end procedure.

procedure Solde1060 private:
    /*------------------------------------------------------------------------------
    Purpose: Solde du compte 1060 à la clôture du dossier
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as collection no-undo.
    define parameter buffer ttDossierTravaux for ttDossierTravaux.

    define variable vdMtSol1060 as decimal no-undo.
    define variable vdaSolde    as date    no-undo.
    define variable vhProc      as handle  no-undo.
    define buffer ietab for ietab.

    empty temp-table ttTmpProv.
    for first ietab no-lock
        where ietab.soc-cd = integer(mtoken:cRefGerance)
          and ietab.etab-cd = ttDossierTravaux.iNumeroMandat:
        vdaSolde = ietab.dafinex2.
    end.

message "gga solde1060 mtoken:cRefGerance : " mtoken:cRefGerance " mtoken:cRefCopro : " mtoken:cRefCopro.

/*gga
    vcLbTmpPdt = mtoken:cRefGerance
                 + "|" + STRING(ttDossierTravaux.iNumeroMandat)
                 + "|" + ""
                 + "|" + "106000000"
                 + "|" + "S"
                 + "|" + STRING(vdaSolde)
                 + "|||" + STRING(ttDossierTravaux.iNumeroDossierTravaux).
    {RunPgExp.i &Path       =   RpRunLie
                &Prog       =   "'solcptch.p'"
                &Parameter  =   "LbTmpPdt,OUTPUT LbTmpPdt"}
gga*/

    poCollection:set('iCodeSoc', integer(mtoken:cRefGerance)) no-error.
    poCollection:set('cCssCpt', ttDossierTravaux.iNumeroDossierTravaux) no-error.
    poCollection:set('daDateSolde', vdaSolde) no-error.
    poCollection:set('lExtraCpta', false) no-error.
    run compta/souspgm/solcptch.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run solcptchCalculSolde in vhProc (input-output poCollection).
    vdMtSol1060 = poCollection:getDecimal("dSolde").
    run destroy in vhProc.
message "gga Solde1060 " vdMtSol1060.

    if vdMtSol1060 <> 0   /*gga todo a virer apres test */ or 1 = 1
    then do:
        create ttTmpProv.
        assign
            ttTmpProv.etab-cd       = ttDossierTravaux.iNumeroMandat
            ttTmpProv.dacompta      = today
            ttTmpProv.sens          = vdMtSol1060 < 0
            ttTmpProv.mt            = vdMtSol1060
            ttTmpProv.nodos         = ttDossierTravaux.iNumeroDossierTravaux
            ttTmpProv.natjou-gi     = 67 /*AFTXA*/
            ttTmpProv.lib-ecr[1]    = "SOLDE PROVISIONS DOSSIER N°" + string(ttDossierTravaux.iNumeroDossierTravaux)
            ttTmpProv.lib-ecr[2]    = ""
            ttTmpProv.cdcle         = ""
            ttTmpProv.cdenr         = ""
        .
/*gga a virer mais pour le test chgt date si non table iprd inexistante*/ if 1 = 1 then ttTmpProv.dacompta = today - 600.
        poCollection:set('cTypeTrait', "") no-error.
        run compta/souspgm/cptaprov.p persistent set vhProc.
        run getTokenInstance  in vhProc(mToken:JSessionId).
        run cptaprovMajOdProv in vhProc (poCollection, table ttTmpProv by-reference).
        run destroy in vhProc.
    end.

end procedure.

procedure ValidationAppelExterne:
    /*------------------------------------------------------------------------------
    Purpose: appel externe de la procedure de validation
    Notes  : service externe (beDossierTravaux.cls)
    ------------------------------------------------------------------------------*/
    define input        parameter table for ttError.
    define input-output parameter table for ttDossierTravaux.
    define input-output parameter table for ttEnteteAppelDeFond.
    define input-output parameter table for ttAppelDeFond.
    define input-output parameter table for ttAppelDeFondRepCle.
    define input-output parameter table for ttAppelDeFondRepMat.
    define input-output parameter table for ttInfoSaisieAppelDeFond.
    define input-output parameter table for ttRepartitionCle.
    define input-output parameter table for ttRepartitionCopro.
    define input-output parameter table for ttRepartitionPourcentage.
    define input-output parameter table for ttDossierAppelDeFond.

    define variable vlRetValid as logical no-undo.

    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then do:
        /* Table ttDossierTravaux inexistante */
        mError:createError({&error}, 4000011).
        return.
    end.
    run validationDossier(buffer ttDossierTravaux, output vlRetValid).

end procedure.

procedure ValidationDossier private:
    /*------------------------------------------------------------------------------
    Purpose: correspond aux procedures de gesdossi.p Validation et CtrlValidation
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plCtrlOk as logical no-undo.

    define variable vhProcRepart as handle  no-undo.
    define variable vhProcAppel  as handle  no-undo.

message "gga ValidationDossier ".

    find first ttInfSelRepartitionAV no-error.
    if not available ttInfSelRepartitionAV
    then do:
        mError:createError({&information}, 999999).   /*todo creer message enregistrement doit exister*/
        return.
    end.

    /*ggg todo pour le moment decoupage de cette procedure avec CtrlValidationInfoDossier pour controle info dossier dans ce pgm,
    CtrlValidationappeldefond pour controle partie appel dans le pgm appeldefond.p et CtrlValidationrepartition pour le controle de la repartition
    dans le pgm repartitionav.p. comme je ne sais pas trop encore si on garde le bouton validation globale ou alors par type d'information
    mais il faudra peut etre tout reporte ici pour des problemes de performance et il faut de toute facon tout controler sur
    le traitement de cloture */

    /* correspond a gesdossi/CtrlValidation pour la partie entete du dossier */
    run ctrlValidationInfoDossier(buffer ttDossierTravaux, output plCtrlOk).
    if not plCtrlOk then return.

    run travaux/dossierTravaux/appelDeFond.p persistent set vhProcAppel.
    run getTokenInstance in vhProcAppel(mToken:JSessionId).
    run travaux/dossierTravaux/repartitionAV.p persistent set vhProcRepart.
    run getTokenInstance in vhProcRepart(mToken:JSessionId).
    /* correspond a gesdossi/CtrlValidation pour la partie appel de fond */
    run ctrlValidationInfoAppel in vhProcAppel(
        buffer ttDossierTravaux,
        table ttError by-reference,
        input-output table ttEnteteAppelDeFond by-reference,
        input-output table ttAppelDeFond by-reference,
        input-output table ttAppelDeFondRepCle by-reference,
        input-output table ttAppelDeFondRepMat by-reference,
        input-output table ttInfoSaisieAppelDeFond by-reference,
        input-output table ttRepartitionCle by-reference,
        input-output table ttRepartitionCopro by-reference,
        input-output table ttDossierAppelDeFond by-reference,
        output plCtrlOk
    ).
    /* correspond a gesdossi/CtrlValidation pour la partie repartition */
    if plCtrlOk then run ctrlValidationInfoRepartition in vhProcRepart(
        buffer ttInfSelRepartitionAV,
        buffer ttDossierTravaux,
        table ttRepartitionAV by-reference,
        table ttError by-reference,
        output table ttEdtAno by-reference,
        output plCtrlOk
    ).
    /*ggg todo pour le moment decoupage de cette procedure avec ValidationInfoAppel pour validation partie appel dans le pgm
    appeldefond.p et ValidationInfoRepartition pour le controle de la repartition dans le pgm repartitionav.p. comme je ne sais pas trop
    encore si on garde le bouton validation globale ou alors par type d'information mais il faudra peut etre tout reporte ici pour
    des problemes de performance et il faut de toute facon tout controler sur le traitement de cloture */

    /* correspond a gesdossi/Validation pour la partie appel de fond */
    if plCtrlOk then run validationInfoAppel in vhProcAppel(
        buffer ttDossierTravaux,
        input-output table ttEnteteAppelDeFond,
        input-output table ttAppelDeFond,
        input-output table ttAppelDeFondRepCle,
        input-output table ttAppelDeFondRepMat,
        input-output table ttInfoSaisieAppelDeFond,
        input-output table ttRepartitionCle,
        input-output table ttRepartitionCopro,
        input-output table ttDossierAppelDeFond,
        input-output table ttError,
        output plCtrlOk
    ).
    /* correspond a gesdossi/Validation pour la partie appel de fond */
    if plCtrlOk
    then run validationInfoRepartition in vhProcRepart(
        buffer ttDossierTravaux,
        input-output table ttRepartitionAV by-reference,
        output plCtrlOk
    ).

/*ggg ????????????????
            if available(trdos) then
            do: /* PL : 20/07/2015 (0715/0005) */ /* Cas ou il n'y a encore aucun dossier travaux sur ce mandat */
                /**Ajout OF le 25/11/13**/
                if HwTglAAG:CHECKED in frame HwFrmObj = true and trdos.nocon-dec = ? then run ControleCompta(input "TESTCLOTURE", output lRetour).
                else if HwTglAAG:CHECKED in frame HwFrmObj = false and trdos.nocon-dec ne ? then
                    do:
                        find first btrdos where btrdos.TpCon = pcTypeContrat
                            and btrdos.NoCon = NoConUse
                            and btrdos.NoDos = NoDosUse
                            exclusive-lock no-error.
                        if available btrdos then btrdos.nocon-dec = ?.
                        find first btrdos where btrdos.TpCon = pcTypeContrat
                            and btrdos.NoCon = NoConUse
                            and btrdos.NoDos = NoDosUse
                            no-lock no-error.
                    end.
            /** **/
            end.
            hgggggggggggggggggggggggggg*/


/*ggg procedure pour appel ecran en fonction erreur attention a maj plFgRetUse en cas d'erreur plus haut
    if viNoOrdUse <> 0 then
    do:
        reposition QuBrwFrm to row viNoOrdUse no-error.
        run GestAction(viNoOrdUse).
        plCtrlOk = false.
        return.
    end.
ggg*/

/*ggg
    if FgEcaPrm then
    do:
        /*--> Sortir directement si ecart en entrée */
        apply "{&Fin_Menub}" to EmMenGes.
    end.
    else
    do:
        /*--> Retour */
        CdSenUse = "VISU".
        /* Maj bornes */
        if NoImmUse > NoImmFin or NoImmFin = 0 then NoImmFin = NoImmUse.
        if NoImmUSe < NoImmDeb or NoImmDeb = 0 then NoImmDeb = NoImmUSe.
        if NoconUse > NoconFin or NoconFin = 0 then NoconFin = NoconUse.
        if NoconUSe < NoconDeb or NoconDeb = 0 then NoconDeb = NoconUSe.
        /* NP 0608/0001 */
        if lgdepass then do:
            LbMessPr = "La somme des montants des diverses actions saisies dans ce dossier " +
                       "est supérieure au montant prévisionnel du dossier travaux".
            run GestMess in HdLibPrc(2,"",0,LbMessPr,"","INFORMATION",output FgExeMth).
        end.
        run GestSensitive.
        /*RUN NavigImmeuble.*/
        run NavigMandat.
    end.

ggg*/
    run destroy in vhProcAppel.
    run destroy in vhProcRepart.

end procedure.

procedure CtrlValidationInfoDossier private:
    /*------------------------------------------------------------------------------
    Purpose: correspond a procedure gesdossi.p CtrlValidation pour la partie information du dossier
    Notes  :
    -----------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plCtrlOk as logical no-undo.

    if f-isNull(ttDossierTravaux.cLibelleDossierTravaux)  // Titre du dossier obligatoire
    then mError:createError({&error}, 108110).
    else if ttDossierTravaux.daDateVote = ?               // Date de Signature obligatoire
    then mError:createError({&error}, if ttDossierTravaux.lUrgent then 108111 else 108264).
    else if f-isNull(ttDossierTravaux.cVille)             // Lieu de Signature obligatoire
    then mError:createError({&error}, 108112).
    else if ttDossierTravaux.daDateDebut = ?              // Date de début obligatoire
    then mError:createError({&error}, 108113).
    else if ttDossierTravaux.iDuree = 0                   // Durée obligatoire
    then mError:createError({&error}, 108114).
    else if ttDossierTravaux.daDateFin = ?                // Date de Fin obligatoire
    then mError:createError({&error}, 108115).
    else plCtrlOk = yes.                                  // Retour bon

end procedure. /* procedure CtrlValidationInfoDossier */
