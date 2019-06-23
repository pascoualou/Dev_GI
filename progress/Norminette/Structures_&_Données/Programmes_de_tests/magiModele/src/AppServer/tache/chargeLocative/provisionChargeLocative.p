/*-----------------------------------------------------------------------------
File        : provisionChargeLocative.p
Purpose     : Rubriques de provision quittancées pour une période de charges locatives
Description : Saisie des provisions réellement versées par le locataire pendant la période de charges
              Remarque : Création d'un enregistrement dans eprov uniquement si l'utilisateur contrepasse le montant total réellement quittancé
Author(s)   : Spo  -  2018/01/12
Notes       : a partir de adb/tach/viscnpro.p & ConTbpro.i
derniere revue: 2018/04/12 - phm: KO
                enlever les messages pour deploiement.
                enlever les todo
Intégration du 19/04/2018 suite à revue de code :
    procedure getProvisionChargeLocative : je souhaite conserver un "then do:" que j'ai signalé
             + les commentaires de "end." boucles imbriquées
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2charge.i}
{preprocesseur/param2locataire.i}
{preprocesseur/codePeriode.i}
{preprocesseur/codeRubrique.i}
{preprocesseur/profil2rubQuit.i}

using parametre.syspg.parametrageTache.
using parametre.pclie.parametrageChargeLocative.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/provisionChargeLocative.i}
{application/include/glbsepar.i}
{adb/include/fctTVAru.i}            // function f_isRubSoumiseTVABail
{bail/include/libelleRubQuitt.i}    // function f_librubqt

define variable goSyspr as class syspr no-undo.

function lecTauTax returns decimal(pcTypeTva as character):
    /*---------------------------------------------------------------------------
    Purpose : Procedure de lecture du taux à appliquer
    Notes   :
    ---------------------------------------------------------------------------*/
    goSyspr:reload("CDTVA", pcTypeTva).
    return if goSyspr:isDbParameter then goSyspr:zone1 else 0.
end function.

procedure getProvisionChargeLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beChargeLocativePrestation.cls)
    @param pcTypeExtraction Type d'extraction = "DETAILRUB": Visualisation (écran)
                                                "CUMULRUB" : Disquette (Traitement charges locatives)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat     as character no-undo.
    define input  parameter piNumeroMandat   as int64     no-undo.
    define input  parameter piNumeroPeriode  as integer   no-undo.
    define input  parameter pcTypeExtraction as character no-undo.
    define output parameter table for ttRubriqueProvisionPeriode.

    define variable voChargeLocative as class parametrageChargeLocative no-undo.
    define variable vdaDateDebutPeriode               as date      no-undo.
    define variable vdaDateFinPeriode                 as date      no-undo.
    define variable vcCritereExtractionRubrique       as character no-undo.
    define variable vdaDateDebutExtraction            as date      no-undo.
    define variable viNombreRubriqueProvisionExtraite as integer   no-undo.
    define variable vcCodeTauxTaxe                    as character no-undo.
    define variable vdValeurTaux                      as decimal   no-undo.
    define variable vcNomLocataire                    as character no-undo.
    define variable viMoisDebut                       as integer   no-undo.
    define variable viMoisFin                         as integer   no-undo.
    define variable vcTermeQuitt                      as character no-undo.
    define variable vdaDateEntree                     as date      no-undo.
    define variable vdaDateSortie                     as date      no-undo.
    define variable viMandat                          as integer   no-undo.
    define variable viSousCompte                      as integer   no-undo.
    define variable viTypeRoleLocataire               as integer   no-undo.
    define variable viCompteurRubrique                as integer   no-undo.
    define variable vcCodeRubriqueQuit                as character no-undo.
    define variable vcCodeLibelleRubriqueQuit         as character no-undo.
    define variable vcModeCalcul                      as character no-undo.
    define variable viNumeroLigne                     as integer   no-undo.
    define variable vcLibelleRubrique                 as character no-undo.
    define variable vlSoumisTVABail                   as logical   no-undo.
    define variable vdMontantQuittance                as decimal   no-undo.
    define variable vdcumulMontantRubrique            as decimal   no-undo.
    define variable vdcumulTVARubrique                as decimal   no-undo.

    define buffer perio   for perio.
    define buffer eprov   for eprov.
    define buffer ctctt   for ctctt.
    define buffer tache   for tache.
    define buffer ctrat   for ctrat.
    define buffer aquit   for aquit.
    define buffer iftsai  for iftsai.
    define buffer vbtache for tache.
    define buffer rubqt   for rubqt.
    define buffer vbttRubriqueProvisionPeriode for ttRubriqueProvisionPeriode.

    empty temp-table ttRubriqueProvisionPeriode.
    viTypeRoleLocataire = integer({&TYPEROLE-locataire}).
    for first perio no-lock
        where perio.tpctt = pcTypeMandat
          and perio.nomdt = piNumeroMandat
          and perio.noexo = piNumeroPeriode
          and perio.noper = 0:
        assign
            vdaDateDebutPeriode    = perio.dtdeb
            vdaDateFinPeriode      = perio.dtfin
            vdaDateDebutExtraction = add-interval(vdaDateDebutPeriode, -2 , "YEAR")     // pour ne pas boucler sur les vieilles quittances
        .
    end.
    if vdaDateDebutPeriode = ? then do:
        // 105312 Période de charges %1 non trouvée pour le mandat %2
        mError:createErrorGestion({&error}, 105312, substitute('&2&1&3', separ[1], string(piNumeroPeriode), string(piNumeroMandat))).
        return.
    end.
    assign
        pcTypeExtraction            = "DETAILRUB" when pcTypeExtraction <> "CUMULRUB"
        voChargeLocative            = new parametrageChargeLocative()
        vcCritereExtractionRubrique = voChargeLocative:getCodeCritereExtractionRubriqueChargeLocative()
        viMoisDebut                 = year(vdaDateDebutPeriode) * 10000 + month(vdaDateDebutPeriode)
        viMoisFin                   = year(vdaDateFinPeriode)   * 10000 + month(vdaDateFinPeriode)
        goSyspr                     = new syspr("CDTVA", "")      // instancié avant boucle.
    .
    delete object voChargeLocative.
    /* parcours de tous les locataires(baux) du mandat */
    for each ctctt no-lock
        where ctctt.tpct1 = pcTypeMandat
          and ctctt.noct1 = piNumeroMandat
          and ctctt.tpct2 = {&TYPECONTRAT-bail}
      , first ctrat no-lock
        where ctrat.tpcon = ctctt.tpct2
          and ctrat.nocon = ctctt.noct2
          and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}
          and ctrat.fgannul = false
      ,  last tache no-lock
         where tache.tpcon = {&TYPECONTRAT-bail}
           and tache.nocon = ctctt.noct2
           and tache.tptac = {&TYPETACHE-quittancement}:
        /* recherche du code terme pour le locataire : avance ou echu, du nom formate du locataire */
        assign
            vcTermeQuitt                      = tache.ntges
            vdaDateEntree                     = tache.dtdeb
            vdaDateSortie                     = tache.dtfin
            viMandat                          = truncate(ctctt.noct2 / 100000, 0)
            viSousCompte                      = ctctt.noct2 modulo 100000
            viNombreRubriqueProvisionExtraite = 0
            vcNomLocataire                    = outilFormatage:getCiviliteNomTiers(ctrat.tprol, ctrat.norol, false)
            vcModeCalcul                      = ""
            vdValeurTaux                      = 0
        .
        /* sy 29/11/2017 : recherche si tâche tva du bail , mode de calcul ( par défaut calcul sur loyers) , taux de tva */
        for last vbtache no-lock
            where vbtache.tpcon = ctrat.tpcon
              and vbtache.nocon = ctrat.nocon
              and vbtache.tptac = {&TYPETACHE-TVABail}:
            assign
                vcModeCalcul   = (if vbtache.pdges > "" then vbtache.pdges else {&MODECALCUL-loyer})
                vcCodeTauxTaxe = vbtache.ntges
                vdValeurTaux   = lecTauTax(vcCodeTauxTaxe)
            .
        end.
boucleAquit:
        for each aquit no-lock
            where aquit.noloc = ctrat.nocon
              and aquit.dtdeb > vdaDateDebutExtraction:
            /* standard:                                                           */
            /* avance: toutes les periodes de quittancement dont la date de debut est comprise dans la periode de charges */
            /* echu  : toutes les periodes de quittancement dont la date de fin est comprise dans la periode de charges   */
            /* décalé (duthoit)                                                     */
            /* avance & echus: toutes les quittances dont le mois de traitement est compris dans la periode de charges    */
            /*                 facture afin de vérifier en compta sur elle porte sur l'exercice     */
            if (vcCritereExtractionRubrique = {&TYPEEXTRACTION2RUBPROVISION-decale} and aquit.msqtt >= viMoisDebut and aquit.msqtt <= viMoisFin )
            or aquit.fgfac
            or (vcCritereExtractionRubrique = {&TYPEEXTRACTION2RUBPROVISION-std}
              and ((vcTermeQuitt = {&TERMEQUITTANCEMENT-avance} and aquit.dtdeb >= vdaDateDebutPeriode and aquit.dtdeb <= vdaDateFinPeriode)
                or (vcTermeQuitt = {&TERMEQUITTANCEMENT-echu}   and aquit.dtfin >= vdaDateDebutPeriode and aquit.dtfin <= vdaDateFinPeriode))
               ) then do:
                /* verifier que la facture est bien sur l'exercice */
                if aquit.fgfac then do:
                    find first iftsai  no-lock
                        where iftsai.soc-cd    = integer(mtoken:cRefGerance)
                          and iftsai.etab-cd   = viMandat
                          and iftsai.tprole    = viTypeRoleLocataire
                          and iftsai.sscptg-cd = string(viSousCompte,"99999")
                          and iftsai.fg-edifac
                          and iftsai.num-int   = aquit.num-int-fac no-error.
                    if not available iftsai   // facture introuvable...on ne fait rien
                    /* ignorer les facture annulées et les factures d'annulation */
                    or iftsai.annul begins "annulation" or iftsai.annul begins "origine"
                    then next boucleAquit.    // facture non retenue: locataire aquit.noloc, qtt no aquit.noqtt, info annul = iftsai.annul.

                    /* si la facture est hors période .... */
                    if (vdaDateDebutPeriode > iftsai.dacompta or iftsai.dacompta > vdaDateFinPeriode)
                    then do:
                        if vdaDateEntree < vdaDateDebutPeriode or vdaDateEntree > vdaDateFinPeriode  /* date d'entrée hors période...on ne prend pas */
                        or iftsai.dacompta > vdaDateFinPeriode                                        /* date comptable facture > date fin période...on ne prend pas */
                        then next boucleAquit.
                    end.
                    /* si la facture est dans la période ....*/
                    else if vdaDateEntree > vdaDateFinPeriode then next boucleAquit.  /* si la date entrée du loc est après la fin de la période...on ne prend pas */
                    /* a ce niveau, la facture existe et il faut la prendre en compte */
                end.
boucleRubrique:
                do viCompteurRubrique = 1 to aquit.nbrub:
                    if num-entries(aquit.tbrub[viCompteurRubrique], "|") < 13 then next boucleRubrique.

                    assign
                        vcCodeRubriqueQuit        = entry(1,aquit.tbrub[viCompteurRubrique],"|")
                        vcCodeLibelleRubriqueQuit = entry(2,aquit.tbrub[viCompteurRubrique],"|")
                        vcLibelleRubrique         = ""
                        vcLibelleRubrique         = f_librubqt(integer(vcCodeRubriqueQuit), integer(vcCodeLibelleRubriqueQuit), aquit.noloc, aquit.msqtt, aquit.noqtt,  0,  0)
                    .
                    find first rubqt no-lock
                        where rubqt.cdrub = integer(vcCodeRubriqueQuit)
                          and rubqt.cdlib = integer(vcCodeLibelleRubriqueQuit) no-error.
                    if not available rubqt then next boucleRubrique.

                    assign
                        /* sy 29/11/2017 : allianz */
                        vlSoumisTVABail    = f_isrubsoumisetvabail(vcModeCalcul, rubqt.cdfam, rubqt.cdsfa, rubqt.cdrub, integer(rubqt.prg05))
                        vdMontantQuittance = decimal(entry(6, aquit.tbrub[viCompteurRubrique], "|"))
                    no-error.
                    if error-status:error then do:
                        // todo : à mettre dans fichier LOG
                        message "locataire " aquit.noloc "historique " aquit.msqtt " rubrique " vcCodeRubriqueQuit + "." + vcCodeLibelleRubriqueQuit " : montant absent ".
                        vdMontantQuittance = 0.
                    end.

                    // rubriques provision :
                    //   - "CUMULRUB" : traitement des charges : on ne transfere que les cumuls, PAS DE CRUD  (PAS ENCORE UTILISE EN WEB)
                    //   - "DETAILRUB" : visualisation/Modification cumul : on stocke tous les montants et on génère les lignes total modifiables pour eprov
                    /* mlog ( "rub : " + vcCodeRubriqueQuit + "." + vcCodeLibelleRubriqueQuit + " filtre famille/sous-famille : " + entry(12,aquit.tbrub[viCompteurRubrique],"|") + "/" + entry(13,aquit.tbrub[viCompteurRubrique],"|") ).*/
                    if pcTypeExtraction = "CUMULRUB" then do:
                        if (rubqt.cdfam = {&FamilleRubqt-Charge} and rubqt.cdsfa = {&SousFamilleRubqt-Provision})
                        or (rubqt.cdfam = {&FamilleRubqt-Loyer}  and rubqt.cdsfa = {&SousFamilleRubqt-ChargeForfaitaire})
                        then do:
                            find first ttRubriqueProvisionPeriode
                                where ttRubriqueProvisionPeriode.cTypeContrat       = ctrat.tpcon
                                  and ttRubriqueProvisionPeriode.iNumeroContrat     = ctrat.nocon
                                  and ttRubriqueProvisionPeriode.iNumeroPeriode     = piNumeroPeriode
                                  and ttRubriqueProvisionPeriode.iRubriqueProvision = rubqt.cdrub no-error.
                            if not available ttRubriqueProvisionPeriode then do:
                                create ttRubriqueProvisionPeriode.
                                assign
                                    viNumeroLigne = viNumeroLigne + 1
                                    ttRubriqueProvisionPeriode.iNumeroInterne        = viNumeroLigne
                                    ttRubriqueProvisionPeriode.cTypeContrat          = ctrat.tpcon
                                    ttRubriqueProvisionPeriode.iNumeroContrat        = ctrat.nocon
                                    ttRubriqueProvisionPeriode.cTypeMandat           = pcTypeMandat
                                    ttRubriqueProvisionPeriode.iNumeroMandat         = piNumeroMandat
                                    ttRubriqueProvisionPeriode.iNumeroPeriode        = piNumeroPeriode
                                    ttRubriqueProvisionPeriode.cNumeroCompte         = string(viSousCompte, "99999")
                                    ttRubriqueProvisionPeriode.cTypeRubrique         = rubqt.prg06
                                    ttRubriqueProvisionPeriode.cNomCompletLocataire  = vcNomLocataire
                                    ttRubriqueProvisionPeriode.daDateEntree          = vdaDateEntree
                                    ttRubriqueProvisionPeriode.daDateSortie          = vdaDateSortie
                                    ttRubriqueProvisionPeriode.cModeCalculTvaBail    = vcModeCalcul
                                    ttRubriqueProvisionPeriode.dTauxTVABail          = vdValeurTaux
                                    ttRubriqueProvisionPeriode.iMoisQuittancement    = 0
                                    ttRubriqueProvisionPeriode.iRubriqueProvision    = rubqt.cdrub
                                    ttRubriqueProvisionPeriode.cLibelleRubrique      = vcLibelleRubrique
                                    ttRubriqueProvisionPeriode.lSoumisTVABail        = vlSoumisTVABail
                                    ttRubriqueProvisionPeriode.dMontantQuittance     = 0
                                    ttRubriqueProvisionPeriode.dMontantTVAQuittance  = 0
                                    ttRubriqueProvisionPeriode.dQuantiteRubrique     = 0
                                    ttRubriqueProvisionPeriode.dPrixUnitaireRubrique = 0
                                    ttRubriqueProvisionPeriode.dMontantReel          = 0
                                    ttRubriqueProvisionPeriode.dMontantTVAReel       = 0
                                    ttRubriqueProvisionPeriode.dtTimestamp           = ?
                                    ttRubriqueProvisionPeriode.CRUD                  = ""     //  lignes non concernée par CRUD
                                    ttRubriqueProvisionPeriode.rRowid                = ?
                                    ttRubriqueProvisionPeriode.lMontantModifiable    = false
                                .
                                /* montant total saisi */
                                for first eprov no-lock
                                    where eprov.tpctt = pcTypeMandat
                                      and eprov.nomdt = piNumeroMandat
                                      and eprov.noexo = piNumeroPeriode
                                      and eprov.noloc = ctrat.nocon
                                      and eprov.cdrub = rubqt.cdrub:
                                    assign
                                        ttRubriqueProvisionPeriode.dMontantReel    = eprov.mtree
                                        ttRubriqueProvisionPeriode.dMontantTVAReel = (if vlSoumisTVABail then round(decimal(ttRubriqueProvisionPeriode.dMontantReel) * vdValeurTaux / 100, 2) else 0)   /* sy 29/11/2017 allianz */
                                    .
                                end.
                            end.
                            /* cumul montants quittancés par rubrique */
                            assign
                                ttRubriqueProvisionPeriode.dMontantQuittance    = ttRubriqueProvisionPeriode.dMontantQuittance + vdMontantQuittance
                                ttRubriqueProvisionPeriode.dMontantTVAQuittance = ttRubriqueProvisionPeriode.dMontantTVAQuittance + (if vlSoumisTVABail then round( vdMontantQuittance * vdValeurTaux / 100 , 2) else 0)
                            .
                        end.
                    end.    /* "CUMULRUB" rubrique provision pour traitement des charges locatives */
                    else do:
                        if (rubqt.cdfam = {&FamilleRubqt-Charge} and rubqt.cdsfa = {&SousFamilleRubqt-Provision})
                        or (rubqt.cdfam = {&FamilleRubqt-Loyer}  and rubqt.cdsfa = {&SousFamilleRubqt-ChargeForfaitaire})
                        or (rubqt.cdfam = {&FamilleRubqt-Charge} and rubqt.cdsfa = {&SousFamilleRubqt-Consommation}) then do:
                            create ttRubriqueProvisionPeriode.
                            assign
                                viNumeroLigne = viNumeroLigne + 1
                                ttRubriqueProvisionPeriode.iNumeroInterne        = viNumeroLigne
                                ttRubriqueProvisionPeriode.cTypeContrat          = ctrat.tpcon
                                ttRubriqueProvisionPeriode.iNumeroContrat        = ctrat.nocon
                                ttRubriqueProvisionPeriode.cTypeMandat           = pcTypeMandat
                                ttRubriqueProvisionPeriode.iNumeroMandat         = piNumeroMandat
                                ttRubriqueProvisionPeriode.iNumeroPeriode        = piNumeroPeriode
                                ttRubriqueProvisionPeriode.cNumeroCompte         = string(viSousCompte,"99999")
                                ttRubriqueProvisionPeriode.cTypeRubrique         = rubqt.prg06
                                ttRubriqueProvisionPeriode.cNomCompletLocataire  = vcNomLocataire
                                ttRubriqueProvisionPeriode.daDateEntree          = vdaDateEntree
                                ttRubriqueProvisionPeriode.daDateSortie          = vdaDateSortie
                                ttRubriqueProvisionPeriode.cModeCalculTvaBail    = vcModeCalcul
                                ttRubriqueProvisionPeriode.dTauxTVABail          = vdValeurTaux
                                ttRubriqueProvisionPeriode.iMoisQuittancement    = aquit.msqtt
                                ttRubriqueProvisionPeriode.iRubriqueProvision    = rubqt.cdrub
                                ttRubriqueProvisionPeriode.cLibelleRubrique      = vcLibelleRubrique
                                ttRubriqueProvisionPeriode.lSoumisTVABail        = vlSoumisTVABail
                                ttRubriqueProvisionPeriode.dMontantQuittance     = vdMontantQuittance
                                ttRubriqueProvisionPeriode.dMontantTVAQuittance  = (if vlSoumisTVABail then round( vdMontantQuittance * vdValeurTaux / 100 , 2) else 0)
                                ttRubriqueProvisionPeriode.dQuantiteRubrique     = 0
                                ttRubriqueProvisionPeriode.dPrixUnitaireRubrique = 0
                                ttRubriqueProvisionPeriode.dMontantReel          = 0
                                ttRubriqueProvisionPeriode.dMontantTVAReel       = 0
                                ttRubriqueProvisionPeriode.dtTimestamp           = ?
                                ttRubriqueProvisionPeriode.CRUD                  = ""       //  ligne non concernée par CRUD
                                ttRubriqueProvisionPeriode.rRowid                = ?
                                ttRubriqueProvisionPeriode.lMontantModifiable    = false
                            .
                            /*- rubriques consommation d'eau -*/
                            if rubqt.cdfam = {&FamilleRubqt-Charge} and rubqt.cdsfa = {&SousFamilleRubqt-Consommation}
                            and num-entries(aquit.tbrub[viCompteurRubrique], "|") >= 4
                            then assign
                                ttRubriqueProvisionPeriode.dQuantiteRubrique     = decimal(entry(3, aquit.tbrub[viCompteurRubrique], "|"))
                                ttRubriqueProvisionPeriode.dPrixUnitaireRubrique = decimal(entry(4, aquit.tbrub[viCompteurRubrique], "|"))
                            .
                            if (rubqt.cdfam = {&FamilleRubqt-Charge} and rubqt.cdsfa = {&SousFamilleRubqt-Provision})
                            or (rubqt.cdfam = {&FamilleRubqt-Loyer}  and rubqt.cdsfa = {&SousFamilleRubqt-ChargeForfaitaire})
                            then viNombreRubriqueProvisionExtraite = viNombreRubriqueProvisionExtraite + 1.        /* sy #6353 */
                        end.    // rubrique provision ou consommation
                    end.  // "DETAILRUB"
                end.  // boucleRubrique
            end.  // filtre des quittances
        end.
        /* sy #6353 ajouter ligne provision 200.01 vierge ou saisie pour locataires de la période sans rub provision quittancées */
        if pcTypeExtraction = "DETAILRUB" then do:
            if   viNombreRubriqueProvisionExtraite = 0
            and vdaDateEntree <> ? and vdaDateEntree <= vdaDateFinPeriode
            and (vdaDateSortie = ? or vdaDateSortie > vdaDateDebutPeriode)
            and not can-find (first ttRubriqueProvisionPeriode
                              where ttRubriqueProvisionPeriode.cTypeContrat   = ctrat.tpcon
                               and  ttRubriqueProvisionPeriode.iNumeroContrat = ctrat.nocon
                               and  ttRubriqueProvisionPeriode.iNumeroPeriode = piNumeroPeriode) then do:   // Merci de laisser le then do
                for each eprov no-lock
                    where eprov.tpctt = pcTypeMandat
                    and   eprov.nomdt = piNumeroMandat
                    and   eprov.noexo = piNumeroPeriode
                    and   eprov.noloc = ctrat.nocon
                    ,first rubqt no-lock
                    where rubqt.cdrub = eprov.cdrub
                    and   rubqt.cdlib > 0:
                    create ttRubriqueProvisionPeriode.
                    assign
                        viNumeroLigne                                    = viNumeroLigne + 1
                        vcLibelleRubrique = f_librubqt(rubqt.cdrub, rubqt.cdlib, ctrat.nocon, 0, 0, 0, 0)
                        vlSoumisTVABail   = f_isrubsoumisetvabail(vcModeCalcul, rubqt.cdfam, rubqt.cdsfa, rubqt.cdrub, integer(rubqt.prg05))
                        ttRubriqueProvisionPeriode.iNumeroInterne        = viNumeroLigne
                        ttRubriqueProvisionPeriode.cTypeContrat          = ctrat.tpcon
                        ttRubriqueProvisionPeriode.iNumeroContrat        = ctrat.nocon
                        ttRubriqueProvisionPeriode.cTypeMandat           = pcTypeMandat
                        ttRubriqueProvisionPeriode.iNumeroMandat         = piNumeroMandat
                        ttRubriqueProvisionPeriode.iNumeroPeriode        = piNumeroPeriode
                        ttRubriqueProvisionPeriode.cNumeroCompte         = string(viSousCompte,"99999")
                        ttRubriqueProvisionPeriode.cTypeRubrique         = rubqt.prg06
                        ttRubriqueProvisionPeriode.cNomCompletLocataire  = vcNomLocataire
                        ttRubriqueProvisionPeriode.daDateEntree          = vdaDateEntree
                        ttRubriqueProvisionPeriode.daDateSortie          = vdaDateSortie
                        ttRubriqueProvisionPeriode.cModeCalculTvaBail    = vcModeCalcul
                        ttRubriqueProvisionPeriode.dTauxTVABail          = vdValeurTaux
                        ttRubriqueProvisionPeriode.iMoisQuittancement    = 0
                        ttRubriqueProvisionPeriode.iRubriqueProvision    = rubqt.cdrub
                        ttRubriqueProvisionPeriode.cLibelleRubrique      = vcLibelleRubrique
                        ttRubriqueProvisionPeriode.lSoumisTVABail        = vlSoumisTVABail
                        ttRubriqueProvisionPeriode.dMontantQuittance     = vdMontantQuittance
                        ttRubriqueProvisionPeriode.dMontantTVAQuittance  = (if vlSoumisTVABail then round( vdMontantQuittance * vdValeurTaux / 100 , 2) else 0)
                        ttRubriqueProvisionPeriode.dQuantiteRubrique     = 0
                        ttRubriqueProvisionPeriode.dPrixUnitaireRubrique = 0
                        ttRubriqueProvisionPeriode.dMontantReel          = eprov.mtree
                        ttRubriqueProvisionPeriode.dMontantTVAReel       = (if vlSoumisTVABail then round( decimal(ttRubriqueProvisionPeriode.dMontantReel) * vdValeurTaux / 100 , 2) else 0)   /* sy 29/11/2017 allianz */
                        ttRubriqueProvisionPeriode.dtTimestamp           = ?
                        ttRubriqueProvisionPeriode.CRUD                  = ""       //  ligne d'affichage non concernée par CRUD
                        ttRubriqueProvisionPeriode.rRowid                = ?
                        ttRubriqueProvisionPeriode.lMontantModifiable    = false
                        viNombreRubriqueProvisionExtraite                = viNombreRubriqueProvisionExtraite + 1
                        .
                end.    /* for each eprov */

                if viNombreRubriqueProvisionExtraite = 0 then do:
                    assign
                        vlSoumisTVABail   = false
                        vcLibelleRubrique = ""
                    .
                    for first rubqt no-lock
                        where rubqt.cdrub = {&RUBRIQUE-charges}
                          and rubqt.cdlib = {&LIBELLE-RUBRIQUE-charges}:
                        create ttRubriqueProvisionPeriode.
                        assign
                        viNumeroLigne     = viNumeroLigne + 1
                        vcLibelleRubrique = f_librubqt(rubqt.cdrub, rubqt.cdlib, ctrat.nocon, 0, 0, 0, 0)
                        vlSoumisTVABail   = f_isrubsoumisetvabail(vcModeCalcul, rubqt.cdfam, rubqt.cdsfa, rubqt.cdrub, integer(rubqt.prg05))  // sy 29/11/2017 : allianz
                        ttRubriqueProvisionPeriode.iNumeroInterne        = viNumeroLigne
                        ttRubriqueProvisionPeriode.cTypeContrat          = ctrat.tpcon
                        ttRubriqueProvisionPeriode.iNumeroContrat        = ctrat.nocon
                        ttRubriqueProvisionPeriode.cTypeMandat           = pcTypeMandat
                        ttRubriqueProvisionPeriode.iNumeroMandat         = piNumeroMandat
                        ttRubriqueProvisionPeriode.iNumeroPeriode        = piNumeroPeriode
                        ttRubriqueProvisionPeriode.cNumeroCompte         = string(viSousCompte,"99999")
                        ttRubriqueProvisionPeriode.cTypeRubrique         = rubqt.prg06
                        ttRubriqueProvisionPeriode.cNomCompletLocataire  = vcNomLocataire
                        ttRubriqueProvisionPeriode.daDateEntree          = vdaDateEntree
                        ttRubriqueProvisionPeriode.daDateSortie          = vdaDateSortie
                        ttRubriqueProvisionPeriode.cModeCalculTvaBail    = vcModeCalcul
                        ttRubriqueProvisionPeriode.dTauxTVABail          = vdValeurTaux
                        ttRubriqueProvisionPeriode.iMoisQuittancement    = 0
                        ttRubriqueProvisionPeriode.iRubriqueProvision    = rubqt.cdrub
                        ttRubriqueProvisionPeriode.cLibelleRubrique      = vcLibelleRubrique
                        ttRubriqueProvisionPeriode.lSoumisTVABail        = vlSoumisTVABail
                        ttRubriqueProvisionPeriode.dMontantQuittance     = 0
                        ttRubriqueProvisionPeriode.dMontantTVAQuittance  = 0
                        ttRubriqueProvisionPeriode.dQuantiteRubrique     = 0
                        ttRubriqueProvisionPeriode.dPrixUnitaireRubrique = 0
                        ttRubriqueProvisionPeriode.dMontantReel          = 0
                        ttRubriqueProvisionPeriode.dMontantTVAReel       = 0
                        ttRubriqueProvisionPeriode.dtTimestamp           = ?
                        ttRubriqueProvisionPeriode.CRUD                  = ""       //  ligne d'affichage non concernée par CRUD
                        ttRubriqueProvisionPeriode.rRowid                = ?
                        ttRubriqueProvisionPeriode.lMontantModifiable    = false
                        .
                    end. //for first rubqt
                end.    // if viNombreRubriqueProvisionExtraite = 0
            end.
        end.    // if pcTypeExtraction = "DETAILRUB"
    end.
    if pcTypeExtraction = "DETAILRUB"
    then for each vbttRubriqueProvisionPeriode      // générer les lignes cumul par rubrique qui seront stockées dans eprov (pour les provisions uniquement) c.f. viscnpro
        where vbttRubriqueProvisionPeriode.cTypeRubrique      = ""
          and vbttRubriqueProvisionPeriode.lMontantModifiable = false
        break by vbttRubriqueProvisionPeriode.cTypeContrat by vbttRubriqueProvisionPeriode.iNumeroContrat by vbttRubriqueProvisionPeriode.iNumeroPeriode by vbttRubriqueProvisionPeriode.iRubriqueProvision:

        if first-of(vbttRubriqueProvisionPeriode.iRubriqueProvision)
        then assign
            vdcumulMontantRubrique = 0
            vdcumulTVARubrique     = 0
        .

        assign
            vdcumulMontantRubrique = vdcumulMontantRubrique + vbttRubriqueProvisionPeriode.dMontantQuittance
            vdcumulTVARubrique     = vdcumulTVARubrique     + vbttRubriqueProvisionPeriode.dMontantTVAQuittance
        .
        if last-of(vbttRubriqueProvisionPeriode.iRubriqueProvision) then do:
            create ttRubriqueProvisionPeriode.
            assign
                viNumeroLigne = viNumeroLigne + 1
                ttRubriqueProvisionPeriode.iNumeroInterne        = viNumeroLigne
                ttRubriqueProvisionPeriode.cTypeContrat          = vbttRubriqueProvisionPeriode.cTypeContrat
                ttRubriqueProvisionPeriode.iNumeroContrat        = vbttRubriqueProvisionPeriode.iNumeroContrat
                ttRubriqueProvisionPeriode.cTypeMandat           = pcTypeMandat
                ttRubriqueProvisionPeriode.iNumeroMandat         = piNumeroMandat
                ttRubriqueProvisionPeriode.iNumeroPeriode        = piNumeroPeriode
                ttRubriqueProvisionPeriode.cNumeroCompte         = string(viSousCompte,"99999")
                ttRubriqueProvisionPeriode.cTypeRubrique         = "TOTAL"
                ttRubriqueProvisionPeriode.cNomCompletLocataire  = vbttRubriqueProvisionPeriode.cNomCompletLocataire
                ttRubriqueProvisionPeriode.daDateEntree          = vbttRubriqueProvisionPeriode.daDateEntree
                ttRubriqueProvisionPeriode.daDateSortie          = vbttRubriqueProvisionPeriode.daDateSortie
                ttRubriqueProvisionPeriode.cModeCalculTvaBail    = vbttRubriqueProvisionPeriode.cModeCalculTvaBail
                ttRubriqueProvisionPeriode.dTauxTVABail          = vbttRubriqueProvisionPeriode.dTauxTVABail
                ttRubriqueProvisionPeriode.iMoisQuittancement    = 0
                ttRubriqueProvisionPeriode.iRubriqueProvision    = vbttRubriqueProvisionPeriode.iRubriqueProvision
                ttRubriqueProvisionPeriode.cLibelleRubrique      = vbttRubriqueProvisionPeriode.cLibelleRubrique
                ttRubriqueProvisionPeriode.lSoumisTVABail        = vbttRubriqueProvisionPeriode.lSoumisTVABail
                ttRubriqueProvisionPeriode.dMontantQuittance     = vdcumulMontantRubrique
                ttRubriqueProvisionPeriode.dMontantTVAQuittance  = vdcumulTVARubrique
                ttRubriqueProvisionPeriode.dQuantiteRubrique     = 0
                ttRubriqueProvisionPeriode.dPrixUnitaireRubrique = 0
                ttRubriqueProvisionPeriode.dMontantReel    = 0
                ttRubriqueProvisionPeriode.dMontantTVAReel = 0
                ttRubriqueProvisionPeriode.dtTimestamp     = ?
                ttRubriqueProvisionPeriode.CRUD            = ""
                ttRubriqueProvisionPeriode.rRowid          = ?
                ttRubriqueProvisionPeriode.lMontantModifiable = true
            .
            /* montant total saisi  */
            for first eprov no-lock
                where eprov.tpctt = pcTypeMandat
                  and eprov.nomdt = piNumeroMandat
                  and eprov.noexo = piNumeroPeriode
                  and eprov.noloc = vbttRubriqueProvisionPeriode.iNumeroContrat
                  and eprov.cdrub = vbttRubriqueProvisionPeriode.iRubriqueProvision:
                assign
                    ttRubriqueProvisionPeriode.dMontantReel    = eprov.mtree
                    ttRubriqueProvisionPeriode.dMontantTVAReel = (if ttRubriqueProvisionPeriode.lSoumisTVABail then round(decimal(ttRubriqueProvisionPeriode.dMontantReel) * ttRubriqueProvisionPeriode.dTauxTVABail / 100 , 2) else 0)   /* sy 29/11/2017 allianz */
                    ttRubriqueProvisionPeriode.dtTimestamp     = datetime(eprov.dtmsy ,eprov.hemsy)
                    ttRubriqueProvisionPeriode.CRUD            = "R"
                    ttRubriqueProvisionPeriode.rRowid          = rowid(eprov)
                .
            end.
        end.
    end.
    delete object goSyspr.
end procedure.

procedure setProvisionChargeLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttRubriqueProvisionPeriode.

    define variable vhEprov as handle no-undo.

    run ctrlAvantMaj.
    if not mError:erreur() then do:
        run adblib/eprov_CRUD.p persistent set vhEprov.
        run getTokenInstance in vhEprov(mToken:JSessionId).
        run seteprov in vhEprov(table ttRubriqueProvisionPeriode by-reference).
        run destroy in vhEprov.
    end.
end procedure.

procedure ctrlAvantMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Contrôles avant appel CRUD
    ------------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    define buffer perio for perio.
    define buffer eprov for eprov.
    define buffer ttRubriqueProvisionPeriode for ttRubriqueProvisionPeriode.

boucleCtrlAvantMaj:
    for each ttRubriqueProvisionPeriode
        where lookup(ttRubriqueProvisionPeriode.CRUD, "C,U,D") > 0:
        if not can-find(first ctrat no-lock
                        where ctrat.tpcon = ttRubriqueProvisionPeriode.cTypeContrat
                          and ctrat.nocon = ttRubriqueProvisionPeriode.iNumeroContrat)
        then do:
            mError:createErrorGestion({&error}, 107473, substitute('&2&1', separ[1], string(ttRubriqueProvisionPeriode.iNumeroContrat))).   // Le bail No %1 n'existe pas.
            leave boucleCtrlAvantMaj.
        end.
        if not can-find(first perio no-lock
                        where perio.tpctt = ttRubriqueProvisionPeriode.cTypeMandat
                          and perio.nomdt = ttRubriqueProvisionPeriode.iNumeroMandat
                          and perio.noexo = ttRubriqueProvisionPeriode.iNumeroPeriode
                          and perio.noper = 0) then do:
            mError:createErrorGestion({&error}, 105312, substitute('&2&1&3', separ[1], string(ttRubriqueProvisionPeriode.iNumeroPeriode), string(ttRubriqueProvisionPeriode.iNumeroMandat))).   // Période de charges %1 non trouvée pour le mandat %2
            leave boucleCtrlAvantMaj.
        end.
        if not ttRubriqueProvisionPeriode.lMontantModifiable then do:
            mError:createError({&error}, 1000633, substitute('&2&1&3', separ[1], ttRubriqueProvisionPeriode.iNumeroContrat, ttRubriqueProvisionPeriode.iRubriqueProvision)).   // "Mofification d'une ligne de rubrique non modifiable (locataire &1 rubrique &2)"
            leave boucleCtrlAvantMaj.
        end.
        find first eprov no-lock
            where eprov.tpctt = ttRubriqueProvisionPeriode.cTypeMandat
              and eprov.nomdt = ttRubriqueProvisionPeriode.iNumeroMandat
              and eprov.noexo = ttRubriqueProvisionPeriode.iNumeroPeriode
              and eprov.noloc = ttRubriqueProvisionPeriode.iNumeroContrat
              and eprov.cdrub = ttRubriqueProvisionPeriode.iRubriqueProvision no-error.
        if not available eprov and lookup(ttRubriqueProvisionPeriode.CRUD, "U,D") > 0
        then do:
            mError:createError({&error}, 1000634, substitute('&2&1&3', separ[1], ttRubriqueProvisionPeriode.iNumeroContrat, ttRubriqueProvisionPeriode.iRubriqueProvision)).  // "Mofification d'une ligne de rubrique inexistante (locataire &1 rubrique &2)"
            leave boucleCtrlAvantMaj.
        end.
        if available eprov and ttRubriqueProvisionPeriode.CRUD = "C"
        then do:
            mError:createError({&error}, 1000635, substitute('&2&1&3', separ[1], ttRubriqueProvisionPeriode.iNumeroContrat, ttRubriqueProvisionPeriode.iRubriqueProvision)).   // "Création d'une ligne de rubrique qui existe déjà (locataire &1 rubrique &2)"
            leave boucleCtrlAvantMaj.
        end.
    end.
end procedure.
