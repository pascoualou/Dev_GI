/*-----------------------------------------------------------------------------
File        : ExtTfLy1.p
Purpose     : Extraction Grille Loyer Eurostudiomes
Author(s)   : Kantena -  2017/12/15
Notes       : reprise de adb/src/ext/ExtTfLy1.p
derniere revue: 2018/04/26 - phm: OK

01  21/01/2008  PL    0108/0012: montants autres et parking : saisie à la ligne et non plus en entête.
02  04/04/2008  SY    0408/0002: pb code tva autre à ? probablement depuis qu'il est saisi (fiche 0108/0012)
03  29/04/2008  SY    correction test NON GERE dans local.euges et pas dans local.euctt
04  17/06/2008  PL    0608/0119: pb de recherche du mandat du lot.
05  30/03/2010  SY    0310/0196: Modification recherche dernière composition où se trouvait un lot
06  06/10/2010  SY    1010/0037: Modification recherche dernière composition où se trouvait un lot
07  06/09/2012  NP    0912/0046: Adaptations pour BNP
-----------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/nature2lot.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageInsitu.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{adb/include/ttEdition.i}

define input  parameter plFlagImmeuble        as logical   no-undo.
define input  parameter plSelectionImmeuble   as logical   no-undo.
define input  parameter piNumeroImmeubleDebut as int64     no-undo.
define input  parameter piNumeroImmeubleFin   as int64     no-undo.
define input  parameter pcSelectionImmeuble   as character no-undo.
define input  parameter plFlagDate            as logical   no-undo.
define input  parameter pdaEdition            as date      no-undo.
define input  parameter pcFormatEdition       as character no-undo.
define output parameter table for ttEdition.

    define variable gcSelectionImmeuble  as character no-undo.
    define variable gcSelectionDate      as character no-undo.
    define variable gcTypeContratEuroS   as character no-undo.
    define variable gcTypeGestionEuroS   as character no-undo.
    define variable gcNumeroMandat       as character no-undo.
    define variable gcNumeroMandant      as character no-undo.
    define variable gcIdentifiantParking as character no-undo.
    define variable giNumeroAppartement  as integer   no-undo.
    define variable giNumeroBail         as integer   no-undo.
    define variable gdaFinReelle         as date      no-undo.
    define variable glFinReelle          as logical   no-undo.
    define variable gcIntervenant        as character no-undo.
    define variable gcNatureGestion      as character no-undo.
    define variable gdeChargeTTC         as decimal   no-undo.
    define variable gcLoyerCodeTVA       as character no-undo.
    define variable gdeLoyerHT           as decimal   no-undo.
    define variable gdeLoyerTVA          as decimal   no-undo.
    define variable gdeLoyerTTC          as decimal   no-undo.
    define variable gcPrestationCodeTVA  as character no-undo.
    define variable gdePrestationHT      as decimal   no-undo.
    define variable gdePrestationTVA     as decimal   no-undo.
    define variable gdePrestationTTC     as decimal   no-undo.
    define variable gcAutreCodeTVA       as character no-undo.
    define variable gdeAutreHT           as decimal   no-undo.
    define variable gdeAutreTVA          as decimal   no-undo.
    define variable gdeAutreTTC          as decimal   no-undo.
    define variable gdeMobilierHT        as decimal   no-undo.
    define variable gdeMobilierTVA       as decimal   no-undo.
    define variable gdeMobilierTTC       as decimal   no-undo.
    define variable gcParkingCodeTVA     as character no-undo.
    define variable gdeParkingHT         as decimal   no-undo.
    define variable gdeParkingTVA        as decimal   no-undo.
    define variable gdeParkingTTC        as decimal   no-undo.
    define variable gcParkingExterieur   as character no-undo.
    define variable gdeTotalTTC          as decimal   no-undo.
    define variable gdeTotalTVA          as decimal   no-undo.
    define variable gdeDGLoyerTTC        as decimal   no-undo.
    define variable gdeDGLoyerMeubleTTC  as decimal   no-undo.
    define variable gdeQuittancementTTC  as decimal   no-undo.
    define variable gdeDossierTTC        as decimal   no-undo.
    define variable gdeHonoraireTTC      as decimal   no-undo.
    define variable goSyspr              as class syspr no-undo.

    goSyspr = new syspr("CDTVA", "").                          // instancié avant boucle.
    run extraction.
    delete object goSyspr.

function frmDate return character(pdatUse as date):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    if pdatUse <> ? then return " " + string(pdatUse, "99/99/9999").
    return "".
end function.
function chrDate return character(pdatUse as date):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    if pdatUse <> ?
    then return string(year(pdatUse), "9999") + string(month(pdatUse), "99") + string(day(pdatUse), "99").
    return "".
end function.
function calTva return decimal(piCodeTvaUse as integer, pdeMtHhtUse as decimal):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    goSyspr:reload("CDTVA", string(piCodeTvaUse, "99999")).
    return if goSyspr:isDbParameter then round(pdeMtHhtUse * decimal(goSyspr:zone1) / 100, 4) else 0.
end function.

procedure extraction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vlInSituActif as logical    no-undo.
    define variable voInsitu      as class parametrageInsitu no-undo.
    define buffer imble for imble.
    define buffer tfent for tfent.

    /*--> Libelle de la selection */
    assign
        gcSelectionImmeuble = if not plFlagImmeuble
                              then "Tous"
                              else if plSelectionImmeuble
                                   then pcSelectionImmeuble
                                   else substitute("de &1 au &2", piNumeroImmeubleDebut, piNumeroImmeubleFin)
        gcSelectionDate      = if not plFlagDate then "Tous" else ("au " + string(pdaEdition, "99/99/9999"))
        voInsitu             = new parametrageInsitu()
        vlInSituActif        = voInsitu:isActif()
    .
    delete object voInsitu.
    {&_proparse_ prolint-nowarn(wholeindex)}
boucle:
    for each imble no-lock:
        /* On ne doit pas prendre en compte les immeubles gérés via In Situ */
        if vlInSituActif and can-find(first pclie no-lock
                                      where pclie.tppar = "INSITU-IMMEUBLE"
                                        and pclie.zon01 = string(imble.noimm)) then next boucle.    /* NP 0912/0046 */
        /*--> Filtre sur l'immeuble */
        if plFlagImmeuble then do:
            /*--> Filtre sur selection / tranche */
            if plSelectionImmeuble
            then do:
                if lookup(string(imble.noimm), pcSelectionImmeuble) = 0 then next boucle.
            end.
            else if imble.noimm < piNumeroImmeubleDebut or imble.noimm > piNumeroImmeubleFin then next boucle.
        end.
        if plFlagDate then for last tfent no-lock
            where tfent.noimm = imble.noimm
              and tfent.dtrev <= pdaEdition:
            run ExtTarif(imble.noimm, buffer tfent).
        end.
        else for each tfent no-lock
            where tfent.noimm = imble.noimm:
            run ExtTarif(imble.noimm, buffer tfent).
        end.
    end.
end procedure.

procedure ExtTarif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define parameter buffer tfent for tfent.

    define variable vcFormatSauve as character no-undo.
    define variable vrCpuni       as rowid     no-undo.
    define variable vcTmp         as character no-undo.
    define buffer vbCpuni for cpuni.
    define buffer local   for local.
    define buffer vbLocal for local.
    define buffer tache   for tache.
    define buffer ctrat   for ctrat.
    define buffer ctctt   for ctctt.
    define buffer unite   for unite.
    define buffer cpuni   for cpuni.
    define buffer tfdet   for tfdet.
    define buffer vbttEdition for ttEdition.

boucleLocal:
    for each local no-lock
        where local.noimm = piNumeroImmeuble
          and local.nolot < 70000
          and local.ntlot <> {&NATURELOT-parking}
          and local.ntlot <> {&NATURELOT-parkingExterieur}
          and local.ntlot <> {&NATURELOT-parkingInterieur}
          and local.euges <> "NON GERE":
        /*--> Recherche d'un tarif au lot */
        find first tfdet no-lock
            where tfdet.noimm = piNumeroImmeuble
              and tfdet.dtrev = tfent.dtrev
              and tfdet.nolot = local.nolot no-error.
        if not available tfdet then do:
            vcTmp = outilTraduction:getLibelleParam("NTLOT", local.ntlot).
            /*--> Recherche d'un regroupement nature + etage + surface + balcon*/
            find last tfdet no-lock
                where tfdet.noimm = piNumeroImmeuble
                  and tfdet.dtrev = tfent.dtrev
                  and tfdet.nolot = 0
                  and tfdet.euctt = local.euctt
                  and tfdet.lbnat = vcTmp
                  and tfdet.lbeta = local.cdeta
                  and tfdet.sfree <= local.sfree
                  and tfdet.euges = local.euges no-error.
            if not available tfdet then do:
                /*--> Recherche d'un regroupement nature + surface + balcon */
                find last tfdet no-lock
                    where tfdet.noimm = piNumeroImmeuble
                      and tfdet.dtrev = tfent.dtrev
                      and tfdet.nolot = 0
                      and tfdet.euctt = local.euctt
                      and tfdet.lbnat = vcTmp
                      and tfdet.lbeta = "Tous"
                      and tfdet.sfree <= local.sfree
                      and tfdet.euges = local.euges no-error.
                if not available tfdet then do:
                    /*--> Recherche d'un regroupement etage + surface + balcon */
                    find last tfdet no-lock
                        where tfdet.noimm = piNumeroImmeuble
                          and tfdet.dtrev = tfent.dtrev
                          and tfdet.nolot = 0
                          and tfdet.euctt = local.euctt
                          and tfdet.lbnat = "Tous"
                          and tfdet.lbeta = local.cdeta
                          and tfdet.sfree <= local.sfree
                          and tfdet.euges = local.euges no-error.
                    if not available tfdet  /*--> Recherche d'un regroupement surface + balcon */
                    then find last tfdet no-lock
                        where tfdet.noimm = piNumeroImmeuble
                          and tfdet.dtrev = tfent.dtrev
                          and tfdet.nolot = 0
                          and tfdet.euctt = local.euctt
                          and tfdet.lbnat = "Tous"
                          and tfdet.lbeta = "Tous"
                          and tfdet.sfree <= local.sfree
                          and tfdet.euges = local.euges no-error.
                end.
            end.
        end.
        if available tfdet then do:
            assign
                gdeLoyerHT          = tfdet.mtloy
                gcLoyerCodeTVA      = if tfdet.cdloy <> ? then string(tfdet.cdloy, "99999") else "00000"
                gdeLoyerTVA         = CALTVA(tfdet.cdloy, tfdet.mtloy)
                gdeLoyerTTC         = gdeLoyerHT + gdeLoyerTVA
                gdeChargeTTC        = tfdet.mtchg
                gdeDGLoyerTTC       = tfdet.mtdgl
                gdeQuittancementTTC = tfent.mtqtt
                gdeDossierTTC       = tfent.mtdos
                gdeHonoraireTTC     = tfent.mthon
                gdePrestationHT     = 0
                gdePrestationTVA    = 0
                gdePrestationTTC    = 0
                gcPrestationCodeTVA = "00000"
                gdeAutreHT          = 0
                gdeAutreTVA         = 0
                gdeAutreTTC         = 0
                gcAutreCodeTVA      = "00000"
                gdeMobilierHT       = 0
                gdeMobilierTVA      = 0
                gdeMobilierTTC      = 0
                gdeDGLoyerMeubleTTC = 0
                gcTypeContratEuroS  = if tfdet.nolot = 0 then tfdet.euctt else local.euctt
                gcTypeGestionEuroS  = if tfdet.nolot = 0 then tfdet.euges else local.euges
            .
            if gcTypeContratEuroS = "R" then assign
                gdePrestationHT     = tfent.mtpre
                gdePrestationTVA    = calTVA(tfent.cdpre, tfent.mtpre)
                gdePrestationTTC    = gdePrestationHT + gdePrestationTVA
                gcPrestationCodeTVA = if tfent.cdpre <> ? then string(tfent.cdpre, "99999") else gcPrestationCodeTVA
            .
            assign
                gdeAutreHT     = tfdet.mtaut
                gcAutreCodeTVA = if tfdet.cdaut <> ? then string(tfdet.cdaut, "99999") else gcAutreCodeTVA
                gdeAutreTVA    = calTVA(integer(gcAutreCodeTVA), gdeAutreHT)
                gdeAutreTTC    = gdeAutreHT + gdeAutreTVA
            .
            if gcTypeContratEuroS = "L+M" then assign
                gdeMobilierHT       = tfent.mtmob
                gdeMobilierTVA      = calTVA(tfent.cdmob, tfent.mtmob)
                gdeMobilierTTC      = gdeMobilierHT + gdeMobilierTVA
                gdeDGLoyerMeubleTTC = tfent.mtdgm
            .
            assign            /*--> Recherche du parking */
                gcIdentifiantParking = ""
                gcNumeroMandat       = ""
                gcNumeroMandant      = ""
                gdeParkingHT         = 0
                gdeParkingTVA        = 0
                gdeParkingTTC        = 0
                gcParkingCodeTVA     = "00000"
                gcParkingExterieur   = ""
                giNumeroAppartement  = 0
                giNumeroBail         = 0
                gdaFinReelle         = ?
                glFinReelle          = false
                gcIntervenant        = ""
                gcNatureGestion      = "00001"
                vrCpuni              = ?
            .
            /* On veut la dernière compo du dernier mandat à avoir le lot
                ATTENTION, ce n'est pas forcèment le mandat le plus élevé en valeur */
            /* Modif SY le 30/03/2010: unite.dtdeb n'est pas fiable => tri par la date du mandat */
boucleCpuni:
            for each cpuni no-lock
                where cpuni.noimm = piNumeroImmeuble
                  and cpuni.nolot = local.NoLot
                  and cpuni.nomdt < 6000
              , first unite no-lock
                where unite.nomdt = cpuni.nomdt
                  and unite.noapp = cpuni.noapp
                  and unite.noact = 0                    /* Ajout SY le 06/10/2010 */
                  and unite.nocmp = cpuni.nocmp
                  and unite.noapp <> 998                 /* Ajout SY le 06/10/2010 */
              , first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and ctrat.nocon = unite.nomdt
                  and ctrat.ntcon <> {&NATURECONTRAT-mandatLocation}            /* sauf mandat Fournisseur de loyer */
                  and ctrat.ntcon <> {&NATURECONTRAT-mandatLocationDelegue}
                  and ctrat.ntcon <> {&NATURECONTRAT-mandatLocationIndivision}
                by ctrat.dtdeb descending by cpuni.nomdt descending by cpuni.nocmp descending:
                vrCpuni = rowid(cpuni).
                leave boucleCpuni.
            end.
            if vrCpuni = ? then next boucleLocal.

            for first cpuni no-lock where rowid(cpuni) = vrCpuni:
                assign
                    gcNumeroMandat      = string(cpuni.nomdt)
                    gcNumeroMandant     = string(cpuni.noman)
                    giNumeroAppartement = cpuni.noapp
                .
                /* Modif SY le 30/03/2010: Recherche du lot parking ici */
                for last ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                      and ctctt.noct1 = cpuni.nomdt
                      and ctctt.tpct2 = {&TYPECONTRAT-bail}
                      and ctctt.noct2 >= cpuni.nomdt * 100000 + giNumeroAppartement * 100
                      and ctctt.noct2 <= cpuni.nomdt * 100000 + giNumeroAppartement * 100 + 99
                  , first ctrat no-lock
                        where ctrat.tpcon = ctctt.tpct2
                          and ctrat.nocon = ctctt.noct2:
                    assign
                        gdaFinReelle  = ctrat.dtree
                        glFinReelle   = (ctrat.dtree = ?)
                        gcIntervenant = if ctrat.lbnom = ? then "" else ctrat.lbnom
                        giNumeroBail  = ctrat.nocon
                    .
                    for first tache no-lock
                        where tache.tpcon = ctrat.tpcon
                          and tache.nocon = ctrat.nocon
                          and tache.tptac = {&TYPETACHE-quittancement}:
                        gcNatureGestion = tache.ntges.
                    end.
                end.
premierCpuni:
                for each vbCpuni no-lock
                    where vbCpuni.nomdt = cpuni.nomdt
                      and vbCpuni.noapp = cpuni.noapp
                      and vbCpuni.noapp <> 998
                      and vbCpuni.nocmp = cpuni.nocmp
                      and vbCpuni.nolot <> local.NoLot
                  , first vbLocal no-lock
                    where vbLocal.noimm = vbCpuni.noimm
                      and vbLocal.nolot = vbCpuni.nolot
                      and (vbLocal.ntlot = {&NATURELOT-parking}
                        or vbLocal.ntlot = {&NATURELOT-parkingExterieur}
                        or vbLocal.ntlot = {&NATURELOT-parkingInterieur}):
                    assign
                        gcIdentifiantParking = string(vbLocal.nolot)
                        gcParkingCodeTVA     = string(if vbLocal.ntlot = {&NATURELOT-parkingInterieur} then tfent.cdpks else tfent.cdpke, "99999")
                        gcParkingCodeTVA     = if gcTypeContratEuroS = "R" then gcParkingCodeTVA else gcLoyerCodeTVA
                        gdeParkingHT         = if tfdet.ntpkg = "S" then tfdet.mtpks else tfdet.mtpke
                        gdeParkingTVA        = calTVA(integer(gcParkingCodeTVA), gdeParkingHT)
                        gdeParkingTTC        = gdeParkingHT + gdeParkingTVA
                        gcParkingExterieur   = string(vbLocal.ntlot = {&NATURELOT-parkingInterieur}, "INT/EXT")
                    .
                    leave premierCpuni.
                end.
                if gcLoyerCodeTVA = "00000" then
            end.
            assign
                gdeTotalTTC = gdeLoyerTTC + gdeChargeTTC + gdePrestationTTC + gdeAutreTTC + gdeMobilierTTC + gdeParkingTTC + gdeQuittancementTTC
                gdeTotalTVA = gdeLoyerTVA + gdePrestationTVA + gdeAutreTVA + gdeMobilierTVA + gdeParkingTVA
                /*--> Creation de la ligne tarif */
                vcFormatSauve          = session:numeric-format
                session:numeric-format = pcFormatEdition
            .
            create ttEdition.
            assign
                ttEdition.Class = substitute("&1&2&31&4", string(piNumeroImmeuble, "999999"), chrdate(tfent.dtrev), string(local.nolot, "999999"), gcTypeGestionEuroS)
                ttEdition.Refer = substitute("&1&21&3", string(piNumeroImmeuble, "999999"), chrdate(tfent.dtrev), gcTypeGestionEuroS)
                ttEdition.Ligne = substitute("&1&2&3&4&5&6&7",
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //                 01,              02,               03,                   04,          05,                 06,                 07,                                                  08
                                                 gcSelectionImmeuble, gcSelectionDate, piNumeroImmeuble, FRMDATE(tfent.dtrev), local.nolot, gcTypeContratEuroS, gcTypeGestionEuroS, outilTraduction:getLibelleParam("NTLOT",local.ntlot)),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //         09,          10,          11,             12,                   13,         14,          15,          16
                                                 local.cdeta, local.sfree, local.sfter, gcNumeroMandat, gcIdentifiantParking, gdeLoyerHT, gdeLoyerTVA, gdeLoyerTTC),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //          17,              18,               19,               20,         21,          22,          23,           24
                                                 gdeChargeTTC, gdePrestationHT, gdePrestationTVA, gdePrestationTTC, gdeAutreHT, gdeAutreTVA, gdeAutreTTC, gdeMobilierHT),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //            25,             26,           27,            28,            29,          30,            31,                  32
                                                 gdeMobilierTVA, gdeMobilierTTC, gdeParkingHT, gdeParkingTVA, gdeParkingTTC, gdeTotalTTC, gdeDGLoyerTTC, gdeDGLoyerMeubleTTC),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //                 33,            34,              35,                36,                37,             38,                  39,             40
                                                 gdeQuittancementTTC, gdeDossierTTC, gdeHonoraireTTC, trim(local.cdbat), trim(local.cdpte), gcLoyerCodeTVA, gcPrestationCodeTVA, gcAutreCodeTVA),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //              41,                  42,           43,                    44,          45,            46,              47,          48
                                                 gcParkingCodeTVA, giNumeroAppartement, giNumeroBail, FRMDATE(gdaFinReelle), glFinReelle, gcIntervenant, gcNatureGestion, local.ntlot),
                                      substitute("&2&1&3&1&4&1&5", SEPAR[1],
                                               //         49,              50,                 51,          52
                                                 local.lbgrp, gcNumeroMandant, gcParkingExterieur, gdeTotalTVA)
                                  )
                session:numeric-format = vcFormatSauve
            .
        end.
    end.
    assign    /*--> Sous-total */
        vcFormatSauve          = session:numeric-format
        session:numeric-format = pcFormatEdition
    .
    for each ttEdition
        where ttEdition.Refer begins substitute("&1&21", string(piNumeroImmeuble, "999999"), chrdate(tfent.dtrev))
        break by ttEdition.Refer:
        if first-of(ttEdition.Refer)
        then assign
            gcTypeGestionEuroS  = trim(substring(ttEdition.Refer, 16, length(ttEdition.Class, "character"), "character"))
            gdeLoyerHT          = 0
            gdeLoyerTVA         = 0
            gdeLoyerTTC         = 0
            gdeChargeTTC        = 0
            gdePrestationHT     = 0
            gdePrestationTVA    = 0
            gdePrestationTTC    = 0
            gdeAutreHT          = 0
            gdeAutreTVA         = 0
            gdeAutreTTC         = 0
            gdeMobilierHT       = 0
            gdeMobilierTVA      = 0
            gdeMobilierTTC      = 0
            gdeParkingHT        = 0
            gdeParkingTVA       = 0
            gdeParkingTTC       = 0
            gdeTotalTTC         = 0
            gdeTotalTVA         = 0
            gdeDGLoyerTTC       = 0
            gdeDGLoyerMeubleTTC = 0
            gdeQuittancementTTC = 0
            gdeDossierTTC       = 0
            gdeHonoraireTTC     = 0
        .
        assign
            gdeLoyerHT          = gdeLoyerHT          + decimal(entry(14, ttEdition.Ligne, SEPAR[1]))
            gdeLoyerTVA         = gdeLoyerTVA         + decimal(entry(15, ttEdition.Ligne, SEPAR[1]))
            gdeLoyerTTC         = gdeLoyerTTC         + decimal(entry(16, ttEdition.Ligne, SEPAR[1]))
            gdeChargeTTC        = gdeChargeTTC        + decimal(entry(17, ttEdition.Ligne, SEPAR[1]))
            gdePrestationHT     = gdePrestationHT     + decimal(entry(18, ttEdition.Ligne, SEPAR[1]))
            gdePrestationTVA    = gdePrestationTVA    + decimal(entry(19, ttEdition.Ligne, SEPAR[1]))
            gdePrestationTTC    = gdePrestationTTC    + decimal(entry(20, ttEdition.Ligne, SEPAR[1]))
            gdeAutreHT          = gdeAutreHT          + decimal(entry(21, ttEdition.Ligne, SEPAR[1]))
            gdeAutreTVA         = gdeAutreTVA         + decimal(entry(22, ttEdition.Ligne, SEPAR[1]))
            gdeAutreTTC         = gdeAutreTTC         + decimal(entry(23, ttEdition.Ligne, SEPAR[1]))
            gdeMobilierHT       = gdeMobilierHT       + decimal(entry(24, ttEdition.Ligne, SEPAR[1]))
            gdeMobilierTVA      = gdeMobilierTVA      + decimal(entry(25, ttEdition.Ligne, SEPAR[1]))
            gdeMobilierTTC      = gdeMobilierTTC      + decimal(entry(26, ttEdition.Ligne, SEPAR[1]))
            gdeParkingHT        = gdeParkingHT        + decimal(entry(27, ttEdition.Ligne, SEPAR[1]))
            gdeParkingTVA       = gdeParkingTVA       + decimal(entry(28, ttEdition.Ligne, SEPAR[1]))
            gdeParkingTTC       = gdeParkingTTC       + decimal(entry(29, ttEdition.Ligne, SEPAR[1]))
            gdeTotalTTC         = gdeTotalTTC         + decimal(entry(30, ttEdition.Ligne, SEPAR[1]))
            gdeTotalTVA         = gdeTotalTVA         + decimal(entry(52, ttEdition.Ligne, SEPAR[1]))
            gdeDGLoyerTTC       = gdeDGLoyerTTC       + decimal(entry(31, ttEdition.Ligne, SEPAR[1]))
            gdeDGLoyerMeubleTTC = gdeDGLoyerMeubleTTC + decimal(entry(32, ttEdition.Ligne, SEPAR[1]))
            gdeQuittancementTTC = gdeQuittancementTTC + decimal(entry(33, ttEdition.Ligne, SEPAR[1]))
            gdeDossierTTC       = gdeDossierTTC       + decimal(entry(34, ttEdition.Ligne, SEPAR[1]))
            gdeHonoraireTTC     = gdeHonoraireTTC     + decimal(entry(35, ttEdition.Ligne, SEPAR[1]))
        .
        if last-of(ttEdition.Refer) then do:
            create vbttEdition.
            assign
                vbttEdition.Class = substitute("&1&29999992&3", string(piNumeroImmeuble, "999999"), chrdate(tfent.dtrev), gcTypeGestionEuroS)
                vbttEdition.Refer = substitute("&1&22&3", string(piNumeroImmeuble, "999999"), chrdate(tfent.dtrev), gcTypeGestionEuroS)
                vbttEdition.Ligne = substitute("&1&2&3&4&5&6&7",
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //                 01,              02,               03,                   04,      05, 06,                 07, 08
                                                 gcSelectionImmeuble, gcSelectionDate, piNumeroImmeuble, FRMDATE(tfent.dtrev), "TOTAL", "", gcTypeGestionEuroS, ""),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //09, 10, 11, 12, 13,         14,          15,          16
                                                 "", "", "", "", "", gdeLoyerHT, gdeLoyerTVA, gdeLoyerTTC),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //          17,              18,               19,               20,         21,          22,          23,            24
                                                 gdeChargeTTC, gdePrestationHT, gdePrestationTVA, gdePrestationTTC, gdeAutreHT, gdeAutreTVA, gdeAutreTTC, gdeMobilierHT),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //            25,             26,           27,            28,            29,          30,            31,                  32
                                                 gdeMobilierTVA, gdeMobilierTTC, gdeParkingHT, gdeParkingTVA, gdeParkingTTC, gdeTotalTTC, gdeDGLoyerTTC, gdeDGLoyerMeubleTTC),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //                 33,            34,              35, 36, 37, 38, 39, 40
                                                 gdeQuittancementTTC, gdeDossierTTC, gdeHonoraireTTC, "", "", "", "", ""),
                                      substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                               //41, 42, 43, 44, 45, 46, 47, 48
                                                 "", "", "", "", "", "", "", ""),
                                      substitute("&2&1&3&1&4&1&5", SEPAR[1],
                                               //49, 50, 51,          52
                                                 "", "", "", gdeTotalTVA)
                                  )
            .
        end.
    end.
    assign
        /*--> TOTAL */
        session:numeric-format = pcFormatEdition
        gcTypeGestionEuroS     = " "
        gdeLoyerHT             = 0
        gdeLoyerTVA            = 0
        gdeLoyerTTC            = 0
        gdeChargeTTC           = 0
        gdePrestationHT        = 0
        gdePrestationTVA       = 0
        gdePrestationTTC       = 0
        gdeAutreHT             = 0
        gdeAutreTVA            = 0
        gdeAutreTTC            = 0
        gdeMobilierHT          = 0
        gdeMobilierTVA         = 0
        gdeMobilierTTC         = 0
        gdeParkingHT           = 0
        gdeParkingTVA          = 0
        gdeParkingTTC          = 0
        gdeTotalTTC            = 0
        gdeTotalTVA            = 0
        gdeDGLoyerTTC          = 0
        gdeDGLoyerMeubleTTC    = 0
        gdeQuittancementTTC    = 0
        gdeDossierTTC          = 0
        gdeHonoraireTTC        = 0
    .
    for each ttEdition
        where ttEdition.Refer begins (string(piNumeroImmeuble, "999999") + CHRDATE(tfent.dtrev) + "2")
        by ttEdition.Refer:
        assign
            gdeLoyerHT          = gdeLoyerHT          + decimal(entry(14, ttEdition.Ligne, SEPAR[1]))
            gdeLoyerTVA         = gdeLoyerTVA         + decimal(entry(15, ttEdition.Ligne, SEPAR[1]))
            gdeLoyerTTC         = gdeLoyerTTC         + decimal(entry(16, ttEdition.Ligne, SEPAR[1]))
            gdeChargeTTC        = gdeChargeTTC        + decimal(entry(17, ttEdition.Ligne, SEPAR[1]))
            gdePrestationHT     = gdePrestationHT     + decimal(entry(18, ttEdition.Ligne, SEPAR[1]))
            gdePrestationTVA    = gdePrestationTVA    + decimal(entry(19, ttEdition.Ligne, SEPAR[1]))
            gdePrestationTTC    = gdePrestationTTC    + decimal(entry(20, ttEdition.Ligne, SEPAR[1]))
            gdeAutreHT          = gdeAutreHT          + decimal(entry(21, ttEdition.Ligne, SEPAR[1]))
            gdeAutreTVA         = gdeAutreTVA         + decimal(entry(22, ttEdition.Ligne, SEPAR[1]))
            gdeAutreTTC         = gdeAutreTTC         + decimal(entry(23, ttEdition.Ligne, SEPAR[1]))
            gdeMobilierHT       = gdeMobilierHT       + decimal(entry(24, ttEdition.Ligne, SEPAR[1]))
            gdeMobilierTVA      = gdeMobilierTVA      + decimal(entry(25, ttEdition.Ligne, SEPAR[1]))
            gdeMobilierTTC      = gdeMobilierTTC      + decimal(entry(26, ttEdition.Ligne, SEPAR[1]))
            gdeParkingHT        = gdeParkingHT        + decimal(entry(27, ttEdition.Ligne, SEPAR[1]))
            gdeParkingTVA       = gdeParkingTVA       + decimal(entry(28, ttEdition.Ligne, SEPAR[1]))
            gdeParkingTTC       = gdeParkingTTC       + decimal(entry(29, ttEdition.Ligne, SEPAR[1]))
            gdeTotalTTC         = gdeTotalTTC         + decimal(entry(30, ttEdition.Ligne, SEPAR[1]))
            gdeTotalTVA         = gdeTotalTVA         + decimal(entry(52, ttEdition.Ligne, SEPAR[1]))
            gdeDGLoyerTTC       = gdeDGLoyerTTC       + decimal(entry(31, ttEdition.Ligne, SEPAR[1]))
            gdeDGLoyerMeubleTTC = gdeDGLoyerMeubleTTC + decimal(entry(32, ttEdition.Ligne, SEPAR[1]))
            gdeQuittancementTTC = gdeQuittancementTTC + decimal(entry(33, ttEdition.Ligne, SEPAR[1]))
            gdeDossierTTC       = gdeDossierTTC       + decimal(entry(34, ttEdition.Ligne, SEPAR[1]))
            gdeHonoraireTTC     = gdeHonoraireTTC     + decimal(entry(35, ttEdition.Ligne,SEPAR[1])).
    end.
    create vbttEdition.
    assign
        vbttEdition.Class = substitute("&1&29999993&3", string(piNumeroImmeuble, "999999"), chrdate(tfent.dtrev), gcTypeGestionEuroS)
        vbttEdition.Refer = substitute("&1&23&3", string(piNumeroImmeuble, "999999"), chrdate(tfent.dtrev), gcTypeGestionEuroS)
        vbttEdition.Ligne = substitute("&1&2&3&4&5&6&7",
                              substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                       //                 01,              02,               03,                   04,      05, 06,                 07, 08
                                         gcSelectionImmeuble, gcSelectionDate, piNumeroImmeuble, FRMDATE(tfent.dtrev), "TOTAL", "", gcTypeGestionEuroS, ""),
                              substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                       //09, 10, 11, 12, 13,         14,          15,          16
                                         "", "", "", "", "", gdeLoyerHT, gdeLoyerTVA, gdeLoyerTTC),
                              substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                       //          17,              18,               19,               20,         21,          22,          23,            24
                                         gdeChargeTTC, gdePrestationHT, gdePrestationTVA, gdePrestationTTC, gdeAutreHT, gdeAutreTVA, gdeAutreTTC, gdeMobilierHT),
                              substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                       //            25,             26,           27,            28,            29,          30,            31,                  32
                                         gdeMobilierTVA, gdeMobilierTTC, gdeParkingHT, gdeParkingTVA, gdeParkingTTC, gdeTotalTTC, gdeDGLoyerTTC, gdeDGLoyerMeubleTTC),
                              substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                       //                 33,            34,              35, 36, 37, 38, 39, 40
                                         gdeQuittancementTTC, gdeDossierTTC, gdeHonoraireTTC, "", "", "", "", ""),
                              substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", SEPAR[1],
                                       //41, 42, 43, 44, 45, 46, 47, 48
                                         "", "", "", "", "", "", "", ""),
                              substitute("&2&1&3&1&4&1&5", SEPAR[1],
                                       //49, 50, 51,          52
                                         "", "", "", gdeTotalTVA)
                          )
        session:numeric-format = vcFormatSauve
    .
end procedure.
