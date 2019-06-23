/*-----------------------------------------------------------------------------
File        : calbaipr.p
Purpose     : Module de calcul de la rubrique de quittancement 101 des Fournisseurs
              de loyer associées à la tache 'Bail proportionnel' (04369) du mandat de location.
Author(s)   : PL - 2012/06/05, Kantena - 2017/12/21
Notes       : reprise de adb/srtc/quit/calbaipr.p
derniere revue: 2018/04/26 - phm: KO
              attention, bail/include/isgesflo.i KO
              faire les traductions

01 26/07/2012  PL    Demande FR le 29/07/2012: procédé interdit retrait annulation de 100% des charges
02 22/08/2012  SY    Ajout infos noqtt, msqtt dans Mlog
03 05/11/2013  SY    réduction nombre Mlog
04 04/09/2014  SY    0914/0007: Pb doublon TOM car la suppression préliminaire ne fonctionnait pas
05 17/12/2014  SY    1214/0150 Gros problème Eclatement encaissement effectués sur TOUS les mandats de gérance alors qu'il ne faudrait
                     QUE les mandat de sous-location si bail proportionnel dans l'immeuble
06 22/12/2014  SY    Etat pré-quitt: ne pas relancer l'Eclatement encaissement si rien en compta
07 22/12/2014  SY    Ajout info mandat location résilié pour affiner WARNING ou ERREUR
*--------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
{preprocesseur/type2tache.i}
{preprocesseur/codeRubrique.i}
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageBailProportionnel.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
define temp-table ttResultat no-undo    /* {tblbpr.i}  Table ttResultat pour extraction des encaissements */
    field NoMdt as integer
    field NoUl  as integer
    field MtHTom as decimal extent 12
    field MtTom  as decimal extent 12
    field MtChg  as decimal extent 12
    field MtTva  as decimal extent 12
.
{bail/include/isgesflo.i}    //  fonctions: donneBailSousLoc, donneBailSousLocDeleguee, donneMandatLoc, donneMandatSousLoc, chargementListeFamilles. procédures: donneLoyerQuittance

define input  parameter pcTypeBail            as character no-undo.
define input  parameter piNumeroBail          as int64     no-undo.
define input  parameter piNumeroQuittance     as integer   no-undo.
define input  parameter pdaDebutPeriode       as date      no-undo.
define input  parameter pdaFinPeriode         as date      no-undo.
define input  parameter pdaDebutQuittancement as date      no-undo.
define input  parameter pdaFinQuittancement   as date      no-undo.
define input  parameter poCollection          as class collection no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour          as character no-undo initial "00".

run calbaiprPrivate.

procedure calbaiprPrivate private:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define variable viNumeroMandat          as integer   no-undo.
    define variable vdeMontantRubrique      as decimal   no-undo.
    define variable viNumeroRubrique        as integer   no-undo.
    define variable viNumeroLibelleRubrique as integer   no-undo.
    define variable viNumeroQuittance       as integer   no-undo.
    define variable vdeMontantLoyer         as decimal   no-undo.
    define variable vdeMontantCharges       as decimal   no-undo.
    define variable vdeMontantTva           as decimal   no-undo.
    define variable vdeMontantTom           as decimal   no-undo.
    define variable vdePourcentageRevision  as decimal   no-undo.
    define variable vcCodeRubriqueLoyer     as character no-undo.
    define variable viLibelleLoyer          as integer   no-undo.
    define variable viMoisQuittance         as integer   no-undo.
    define variable viMoisModifiable        as integer   no-undo.
    define variable viMoisEchu              as integer   no-undo.
    define variable voBailProportionnel     as class parametrageBailProportionnel no-undo.

    define buffer equit for equit.
    define buffer tache for tache.

    /* Recherche si tache Bail proportionnel F.L */
    viNumeroMandat = integer(truncate(piNumeroBail / 100000, 0)). // integer(substring( string(piNumeroBail, "9999999999"), 1 , 5))
    find first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = viNumeroMandat
          and tache.tptac = {&TYPETACHE-bailProportionnel} no-error.
    if not available tache then return.

    /* Au passage, récupération des infos de la tache */
    if tache.tpfin = "00000" then do:
        voBailProportionnel = new parametrageBailProportionnel().
        if not voBailProportionnel:isDbParameter then do:
            // todo   traduction
            merror:createError({&error}, "Le paramètrage du Bail proportionnel au niveau du cabinet n'est pas renseigné. Vous devez d'abord le renseigner.").
            return.
        end.
        assign
            vdePourcentageRevision = voBailProportionnel:getPourcentageRevision()
            vcCodeRubriqueLoyer    = voBailProportionnel:getCodeRubriqueLoyer()
            viLibelleLoyer         = voBailProportionnel:getNumeroRubriqueLoyer()
        .
    end.
    else assign            /* Sinon on prend le paramétrage spécifique */
        vdePourcentageRevision = decimal(tache.mtreg)
        vcCodeRubriqueLoyer    = entry(1, tache.lbdiv, "#")
        viLibelleLoyer         = integer(entry(2, tache.lbdiv, "#")) when num-entries(tache.lbdiv, "#") >= 2
    .
    /* Tests des dates de début de quittance et quittancement et des dates de fin de quittance et de quittancement */
    if (pdaDebutQuittancement < pdaDebutPeriode)
    or (pdaFinQuittancement > pdaFinPeriode)
    or (pdaFinPeriode < pdaDebutPeriode) then do:
        pcCodeRetour = "01".
        return.
    end.
    /* Recherche mois de quitt selon Locat ou FL */
    run iniMsQttMdt(viNumeroMandat, output viMoisQuittance, output viMoisModifiable, output viMoisEchu).
    /* Recherche si TOUTES les quittances chargées */
    /* Parcours des quittances en cours du locataire */
boucleEquit:
    for each equit no-lock
        where equit.noLoc = piNumeroBail
          and ((equit.cdter = "00001" and equit.msqtt >= viMoisEchu)
            or (equit.cdter = "00002" and equit.msqtt >= viMoisModifiable))
        by equit.msqtt by equit.nomdt:
        /* Recherche de la 1ère quittance >= Mois Quitt */
        if viNumeroQuittance = 0 and equit.noqtt > 0 and equit.msQtt >= viMoisQuittance
        then do:
            viNumeroQuittance = equit.noqtt.
            leave boucleEquit.
        end.
    end.
    /* Recherche mois quitt de la quittance traitée */
    find first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance no-error.
    if not available ttQtt then do:
        pcCodeRetour = "01".
        return.
    end.
    /* Calcul du loyer en fonction des encaissements */
    if ttQtt.noqtt = viNumeroQuittance    /* Pour l'AE en cours */
    then run calculeLoyerEncaisse(piNumeroBail, output vdeMontantLoyer, output vdeMontantTom, output vdeMontantCharges, output vdeMontantTva).
    for each ttRub    /* Il ne doit y avoir qu'une seule rubrique générée */
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = integer(vcCodeRubriqueLoyer):
        delete ttRub.
    end.
    for each ttRub    /* IDem pour la TOM */
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = {&RUBRIQUE-taxeOrduresMenageres}:
        delete ttRub.
    end.
    for each ttRub    /* IDem pour Les charges */
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = {&RUBRIQUE-charges}:
        delete ttRub.
    end.
    /* Rubrique de loyer */
    if vdeMontantLoyer <> 0 then do:
        assign
            viNumeroRubrique        = integer(vcCodeRubriqueLoyer)
            viNumeroLibelleRubrique = viLibelleLoyer
            vdeMontantRubrique      = round((vdeMontantLoyer * vdePourcentageRevision) / 100, 2) /* Pas de prorata de présence*/
        .
        run trtRubEnc(vdeMontantRubrique, viNumeroRubrique, viNumeroLibelleRubrique).
        run creDetail(viNumeroRubrique, vdeMontantLoyer).
    end.
    /* Rubrique de Taxe ordures ménagères */
    if vdeMontantTom <> 0 then do:
        assign
            viNumeroRubrique        = {&RUBRIQUE-taxeOrduresMenageres}
            viNumeroLibelleRubrique = {&LIBELLE-RUBRIQUE-taxeOrduresMenageres}
            vdeMontantRubrique      = vdeMontantTom /* Pas de pourcentage de recupération, Pas de prorata de présence */
        .
        run trtRubEnc(vdeMontantRubrique, viNumeroRubrique, viNumeroLibelleRubrique).
    end.
    /* Rubrique de Charges 91.85% */
    if vdeMontantCharges <> 0 then do:
        assign
            viNumeroRubrique        = {&RUBRIQUE-charges}
            viNumeroLibelleRubrique = {&LIBELLE-RUBRIQUE-charges}
            vdeMontantRubrique      = round((vdeMontantCharges * vdePourcentageRevision) / 100, 2) /* Pas de prorata de présence*/
        .
        run trtRubEnc(vdeMontantRubrique, viNumeroRubrique, viNumeroLibelleRubrique).
        run creDetail(viNumeroRubrique, vdeMontantCharges).
    end.
end procedure.

procedure trtRubEnc:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour ou crée la rubrique
    Notes   : (TOUTES LES QUITTANCES DOIVENT ETRE CHARGEES)
    ---------------------------------------------------------------------------*/
    define input  parameter pdeMontantRubrique      as decimal no-undo.
    define input  parameter piNumeroRubrique        as integer no-undo.
    define input  parameter piNumeroLibelleRubrique as integer no-undo.

    define variable vdaDebutRubrique   as date      no-undo.
    define variable vdaFinRubrique     as date      no-undo.
    define variable vdaDebutQuittance  as date      no-undo.
    define variable vdaFinQuittance    as date      no-undo.
    define variable vcCodeRetour       as character no-undo.
    define variable vcParametresDivers as character no-undo.

    define buffer rubqt   for rubqt.
    define buffer vbttRub for ttRub.

    /* Calcul dates d'application */
    assign
        vdaDebutRubrique = ttQtt.dtdpr
        vdaFinRubrique   = pdaFinQuittancement
    .
    /* Positionnement sur la Rubrique  101-xx */
    find first rubqt no-lock
        where rubqt.cdrub = piNumeroRubrique
          and rubqt.cdlib = piNumeroLibelleRubrique no-error.
    if not available rubQt then do:
        mError:createError({&error}, 104126, string(piNumeroRubrique)).
        pcCodeRetour = "01".
        return.
    end.
    find first ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = piNumeroRubrique
          and ttRub.nolib = piNumeroLibelleRubrique no-error.
    if not available ttRub then do:
        create ttRub.
        assign
            vdaDebutQuittance = vdaDebutRubrique
            vdaFinQuittance   = ttQtt.dtfpr  /* date de fin quittance corrigée */
            ttRub.NoLoc = piNumeroBail
            ttRub.NoQtt = piNumeroQuittance
            ttRub.NoRub = piNumeroRubrique
            ttRub.NoLib = piNumeroLibelleRubrique
            ttRub.LbRub = outilTraduction:getLibelle(rubqt.nome1)
            ttRub.CdFam = rubqt.cdfam
            ttRub.CdSfa = rubqt.cdsfa
            ttRub.CdGen = rubqt.CdGen
            ttRub.CdSig = rubqt.CdSig
            ttRub.CdDet = "0"
            ttRub.VlQte = 0
            ttRub.VlPun = 0
            ttRub.MtTot = pdeMontantRubrique
            ttRub.CdPro = ttQtt.cdquo   /* cdpro */
            ttRub.VlNum = ttQtt.Nbnum   /* nbnum */
            ttRub.VlDen = ttQtt.Nbden   /* nbden */
            ttRub.VlMtq = pdeMontantRubrique
            ttRub.DtDap = vdaDebutRubrique
            ttRub.DtFap = vdaFinRubrique
            ttRub.NoLig = 0
        .
        run majttQtt(piNumeroBail, piNumeroQuittance, pdeMontantRubrique, 1).    /* Modification du montant de la quittance et nb rub dans ttQtt */
    end.
    else do:
        assign
            vdaDebutQuittance = ttRub.DtDap
            vdaFinQuittance   = ttRub.DtFap
            /* Modification rubrique Loyer */
            ttRub.MtTot       = pdeMontantRubrique
            ttRub.VlMtq       = pdeMontantRubrique
            ttRub.DtFap       = vdaFinRubrique
        .
        run majttQtt(piNumeroBail, piNumeroQuittance, pdeMontantRubrique - ttRub.mttot, 0).     /* Modification du montant de la quittance et nb rub dans ttQtt */
    end.

    /* Verification existence de la rubrique avec un autre libellé dans les quittances futures et forçage avec libellé piNumeroLibelleRubrique */
    for each vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt > piNumeroQuittance
          and vbttRub.norub = piNumeroRubrique
          and vbttRub.nolib <> piNumeroLibelleRubrique:
        /* Forcage dates d'application et libelle */
        assign
            vbttRub.nolib = piNumeroLibelleRubrique
            vbttRub.dtdap = ttRub.dtdap
            vbttRub.dtfap = ttRub.dtfap
        .
    end.
    /* Lancement du module de répercussion sur les quittances futures */
    run bail/quittancement/majlocrb.p(
        pcTypeBail,
        piNumeroBail,
        piNumeroQuittance,
        piNumeroRubrique,
        piNumeroLibelleRubrique,
        vdaDebutQuittance,
        vdaFinQuittance,
        input-output vcParametresDivers,
        input-output table ttQtt,
        input-output table ttRub,
        output vcCodeRetour
    ).

end procedure.

procedure iniMsQttMdt:
    /*---------------------------------------------------------------------------
    Purpose : Procedure d'init du mois de quittancement selon mandat (Floyer ou non)
    Notes   : todo   c'est la même dans calgarlo.p
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat   as int64    no-undo.
    define output parameter piMoisQuittance  as integer  no-undo.
    define output parameter piMoisModifiable as integer  no-undo.
    define output parameter piMoisEchu       as integer  no-undo.

    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

    /* Prochain Mois de Quittancement du mandat */
    assign
        voFournisseurLoyer = new parametrageFournisseurLoyer()
        piMoisQuittance    = poCollection:getInteger("GlMoiQtt")
        piMoisModifiable   = poCollection:getInteger("GlMoiMdf")
        piMoisEchu         = poCollection:getInteger("GlMoiMec")
    .
    if voFournisseurLoyer:isGesFournisseurLoyer()
    and can-find(first ctrat no-lock
        where ctrat.tpcon  = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon  = piNumeroMandat
          and (ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
            or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}))
    then assign
        piMoisQuittance  = poCollection:getInteger("GlMflQtt")
        piMoisEchu       = poCollection:getInteger("GlMflMdf")
        piMoisModifiable = piMoisEchu
    .
    delete object voFournisseurLoyer.
end procedure.

procedure majttQtt:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroBailQuittance as int64   no-undo.
    define input  parameter piNumeroQuittanceMaj  as integer no-undo.
    define input  parameter pdeMontantRubrique    as decimal no-undo.
    define input  parameter piNumeroRubrique      as integer no-undo.

    for first ttQtt
        where ttQtt.NoLoc = piNumeroBailQuittance
          and ttQtt.NoQtt = piNumeroQuittanceMaj:
        assign
            ttQtt.MtQtt = ttQtt.MtQtt + pdeMontantRubrique
            ttQtt.NbRub = ttQtt.NbRub + piNumeroRubrique
            ttQtt.CdMaj = 1
        .
    end.

end procedure.

procedure calculeLoyerEncaisse:
    /*---------------------------------------------------------------------------
    Purpose : Lancement de la procédure de calcul du loyer FL pour le mandat type bail proportionnel = fonction des encaissements des sous-locataires
    Notes   :
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroBailLoyer as integer no-undo.
    define output parameter pdeMontantLoyer   as decimal no-undo.
    define output parameter pdeMontantTOM     as decimal no-undo.
    define output parameter pdeMontantCharges as decimal no-undo.
    define output parameter pdeMontantTVA     as decimal no-undo.

    define variable vcListeRubriquesLoyer   as character no-undo.
    define variable vcListeRubriquesCharges as character no-undo.
    define variable vcListeRubriquesTOM     as character no-undo.
    define variable vcListeRubriquesTVA     as character no-undo.
    define variable viMandatLocation        as integer   no-undo.
    define variable viULMandatLocation      as integer   no-undo.
    define variable viBailSousLocation      as int64     no-undo.
    define variable viMandatSousLocation    as integer   no-undo.
    define variable viULSousLocation        as integer   no-undo.
    define variable viBoucle                as integer   no-undo.
    define variable vlTrtMasse              as logical   no-undo.
    define variable viMandatATraiter        as integer   no-undo.
    define variable viULATraiter            as integer   no-undo.
    define variable vlExtractionFL          as logical   no-undo.
    define variable vhProcRubqt             as handle    no-undo.

    define buffer unite      for unite.
    define buffer cpuni      for cpuni.
    define buffer ctrat      for ctrat.
    define buffer vbCtratLoc for ctrat.
    define buffer intnt      for intnt.
    define buffer vbIntntLoc for intnt.
    define buffer tache      for tache.

    /* Récupération du mandat de location */
    assign
        viMandatLocation   = truncate(piNumeroBailLoyer / 100000, 0)              // integer(substring(string(piNumeroBailLoyer,"9999999999"),1,5))
        viULMandatLocation = truncate((piNumeroBailLoyer modulo 100000) / 100, 0) // integer(substring(string(piNumeroBailLoyer,"9999999999"),6,3))
    .
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = viMandatLocation
          and ctrat.dtree <> ?:
         mLogger:writeLog(9, substitute("WARNING CalculeLoyerEncaisse - mandat de location n° &1 résilié au &2", viMandatLocation, ctrat.dtree)).
    end.
    /* Balayage de toutes les unités actives du mandat de location ... */
    find first unite no-lock
        where unite.nomdt = viMandatLocation
          and unite.noapp = viULMandatLocation
          and unite.noact = 0 no-error.
    if not available unite then return.

    /* ... puis le lot de l'unite (NB: dans ce modèle : 1 bail = 1 UL = 1 lot ... */
    find first cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp no-error.
    if not available cpuni then return.

    /* ... Recherche d'une composition d'un mandat de sous/location contenant ce lot */
    viBailSousLocation = donneBailSousLoc(cpuni.noimm, cpuni.nolot).
    if viBailSousLocation = 0 then return.

    /* A ce niveau on a le bail du mandat de sous-location correspondant à ce lot */
    /* Il faut obtenir les encaissements du locataire */
    assign
        /* Récupération des identifiants */
        viMandatSousLocation = truncate(viBailSousLocation / 100000, 0)              // integer(substring(string(viBailSousLocation,"9999999999"),1,5))
        viULSousLocation     = truncate((viBailSousLocation modulo 100000) / 100, 0) // integer(substring(string(viBailSousLocation,"9999999999"),6,3))
        /* Appel de la boite noire d'extraction des encaissements */
        viMandatATraiter     = 0  /* Par defaut, on traite tous les mandats */
        /* Traitement en masse ou quittance unique */
        /* Normalement, quand on arrive ici depuis le quittancement, l'éclatement a déjà été lancé
           et l'extraction aussi sinon cela plante, donc on ne peut pas lancer un pont compta depuis un pont gestion depuis les transferts */
        vlExtractionFL = poCollection:getCharacter("PREQUITTANCEMENT_FL") = "OUI"
                      or poCollection:getCharacter("PREQUITTANCEMENT_FL") = "ECLAT_FAIT"
        vlTrtMasse     = poCollection:getCharacter("QUITTANCEMENT_FL")    = "OUI"
    .
    if not vlTrtMasse then do:
        empty temp-table ttResultat.
        viMandatATraiter = viMandatSousLocation.
    end.
    viULATraiter = viULSousLocation.

    /* Si pas d'enregistrement dans la table, il faut lancer l'éclatement ET l'extraction */
    find first ttResultat no-error.
    if not available ttResultat then do:
        /* Ne pas lancer le pont si quittancement FL car plante */
        /* Ajout SY le 22/12/2014: ne pas lancer l'éclatement des encaissement si déjà fait mais aucune écritures comptables */
        if not vlTrtMasse
        and poCollection:getCharacter("PREQUITTANCEMENT_FL") <> "ECLAT_FAIT" then do:
            /* SY 1214/0150 : Optimisation */
            for each ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and ctrat.fgfloy = no
                  and ctrat.dtree = ?
                  and ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation}
              , first intnt no-lock
                where intnt.tpcon = ctrat.tpcon
                  and intnt.nocon = ctrat.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}
              , each vbIntntLoc no-lock
                where vbIntntLoc.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and vbIntntLoc.tpidt = intnt.tpidt
                  and vbIntntLoc.noidt = intnt.noidt
              , first vbCtratLoc no-lock
                where vbCtratLoc.tpcon = vbIntntLoc.tpcon
                  and vbCtratLoc.nocon = vbIntntLoc.nocon
                  and (vbCtratLoc.ntcon = {&NATURECONTRAT-mandatLocation}
                    or vbCtratLoc.ntcon = {&NATURECONTRAT-mandatLocationIndivision})
              , last tache no-lock
                where tache.tpcon = vbCtratLoc.tpcon
                  and tache.nocon = vbCtratLoc.nocon
                  and tache.tptac = {&TYPETACHE-bailProportionnel}
                break by ctrat.tpcon by ctrat.nocon by vbCtratLoc.nocon:
                if first-of(ctrat.nocon) then do:
                    viMandatATraiter = ctrat.nocon.
                    /* 1 - Lancement de l'éclatement des encaissements */
                    mLogger:writeLog(9, substitute(
                        "Lancement de l'éclatement des encaissements:&1pdaDebutQuittancement = &2&1pdaFinQuittancement = &3&1viMandatATraiter = &4&1",
                        chr(10),
                        string(pdaDebutQuittancement, "99/99/9999"),
                        string(pdaFinQuittancement, "99/99/9999"),
                        viMandatATraiter)
                    ).
                    poCollection:set("cCodeTraitement", "ECLAT").    /* Code Traitement: ECLAT-EXTRACT-VALID */
                    poCollection:set("daDebutQuittance", pdaDebutQuittancement).
                    poCollection:set("daFinQuittance",   pdaFinQuittancement).
                    poCollection:set("iMandatATraiter",  viMandatATraiter).
                    poCollection:set("iNumeroUnite",     0).
                    poCollection:set("cListeHonoraireTOM", "").
                    poCollection:set("cListeTOM",          "").
                    poCollection:set("cListeCharges",      "").
                    poCollection:set("cListeTVA",          "").
                    run compta/extrbbpr.p(poCollection).
                end.
            end.
            if vlExtractionFL then poCollection:set("PREQUITTANCEMENT_FL", "ECLAT_FAIT").  /* Ajout SY le 22/12/2014 */
        end.
    end.

    find first ttResultat
        where ttResultat.nomdt = viMandatSousLocation no-error.
    if not available ttResultat then do:
        /* Ne pas lancer le pont si quittancement FL car plante */
        if poCollection:getCharacter("QUITTANCEMENT_FL") <> "OUI" then do:
            /* Si on est sur le prequitt, on lance pour toutes les UL du mandat, sinon juste sur l'UL qui nous concerne */
            viULATraiter = (if vlTrtMasse then 0 else viULSousLocation).
            /* Chargement de la liste des rubriques à prendre en compte pour le calcul */
            run bail/quittancement/rubqt_crud.p persistent set vhProcRubqt.
            run getTokenInstance in vhProcRubqt(mToken:JSessionId).
            run getRubriqueEncaissement in vhProcRubqt(
                 output vcListeRubriquesLoyer,
                 output vcListeRubriquesCharges,
                 output vcListeRubriquesTOM,
                 output vcListeRubriquesTVA
            ).
            delete procedure vhProcRubqt no-error.
            poCollection:set("cCodeTraitement",  "EXTRACT").    /* Code Traitement: ECLAT-EXTRACT-VALID */
            poCollection:set("daDebutQuittance", pdaDebutQuittancement).
            poCollection:set("daFinQuittance",   pdaFinQuittancement).
            poCollection:set("iMandatATraiter",  viMandatATraiter).
            poCollection:set("iNumeroUnite",     viULATraiter).
            poCollection:set("cListeHonoraireTOM", vcListeRubriquesLoyer).
            poCollection:set("cListeTOM",          vcListeRubriquesTOM).
            poCollection:set("cListeCharges",      vcListeRubriquesCharges).
            poCollection:set("cListeTVA",          vcListeRubriquesTVA).
            run compta/extrbbpr.p(poCollection).              // todo  programme à reprendre !!!! bon courage
        end.
    end.

    /* Positionnement sur le bon enregistrement */
    find first ttResultat
        where ttResultat.nomdt = viMandatSousLocation
          and ttResultat.noul = viULSousLocation no-error.
    if not available ttResultat then do:
        mLogger:writeLog(9, substitute(
            "** WARNING ** Recherche/Cumul des encaissements: aucun enregistrement correspondant dans ttResultat&1 viMandatSousLocation = &2&1 viULSousLocation = &3",
            chr(10),
            viMandatSousLocation,
            viULSousLocation)).
        return.
    end.
    /* Cumul sur les 12 mois */
    do viBoucle = 1 to 12:
        assign
            pdeMontantLoyer    = pdeMontantLoyer   + ttResultat.mthtom[viBoucle]
            pdeMontantTOM      = pdeMontantTOM     + ttResultat.mttom[viBoucle]
            pdeMontantCharges  = pdeMontantCharges + ttResultat.mtchg[viBoucle]
            pdeMontantTVA      = pdeMontantTVA     + ttResultat.mttva[viBoucle]
        .
    end.
    mLogger:writeLog(9, substitute(
        "Cumul des encaissements:&1 viMandatSousLocation = &2 viULSousLocation = &3&1 pdeMontantLoyer = &4&1 pdeMontantTOM = &5&1 pdeMontantCharges = &6&1pdeMontantTVA = &7",
        chr(10),
        viMandatSousLocation,
        viULSousLocation,
        pdeMontantLoyer,
        pdeMontantTOM,
        pdeMontantCharges,
        pdeMontantTVA
    )).

end procedure.

procedure creDetail:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define input parameter piRubrique as integer no-undo.
    define input parameter pdeMontant as decimal no-undo.

    define variable viBoucle          as integer no-undo.
    define variable viRubriqueTrouvee as integer no-undo.

    mLogger:writeLog(9, substitute(
        "Credetail - Création du détail des encaissements:&1 piNumeroBail = &2&1 piNumeroQuittance = &3&1 piRubrique = &4&1 pdeMontant = &5",
        piNumeroBail,
        piNumeroQuittance,
        piRubrique,
        pdeMontant
        )).
    find first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance no-error.
    if not available ttQtt then return.

    /* Recherche de la position de la rubrique si elle existe */
boucle:
    do viBoucle = 1 to 20:
        if (ttQtt.tbrubenc[viBoucle] = 0 or ttQtt.tbrubenc[viBoucle] = ?) and viRubriqueTrouvee = 0 then do:
            viRubriqueTrouvee = viBoucle.
            leave boucle.
        end.
        if ttQtt.tbrubenc[viBoucle] = piRubrique then do:
            viRubriqueTrouvee = viBoucle.
            leave boucle.
        end.
    end.
    if viRubriqueTrouvee > 0 then assign
        ttQtt.tbrubenc[viRubriqueTrouvee] = piRubrique
        ttQtt.tbmntenc[viRubriqueTrouvee] = pdeMontant
    .
end procedure.
