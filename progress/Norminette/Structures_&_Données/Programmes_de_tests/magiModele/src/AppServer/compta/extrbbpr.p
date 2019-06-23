/*-----------------------------------------------------------------------------
File        : extrbbpr.p
Purpose     : Extraction de l'eclatement des encaissements pour le reporting quittancement des baux proportionnels
Author(s)   : DM - 2012/06/28, Kantena - 2017/12/21 
Notes       : SPECIF BNP - Fiche 0212/0155 - reprise de cadb/src/gestion/extrbpr.p
            - Aucun encaissement ne doit etre saisi sur le mois de quitt fl après le traitement du quitt
            - Les réguls générées apres le quitt fl sont affectées sur le mois suivant
 01  16/12/2014  SY   1214/0150 Ajout test mandat rattaché en compta => Mlog
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageNouveauCRG.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

/* phm 2017/12/22 
include global standard (ne pas modifier)
{comm/allincmn.i}
{comm/glblibpr.i}     
include global standard pour la compta
{comm/gstcptdf.i}    
*/

define input  parameter poCollection  as class collection no-undo.
/* Pas utilisée, définition pour compatibilité des paramètres à adecla1.p */ 
define temp-table ttMandatTravail no-undo 
    field soc-cd    as integer
    field gest-cle  as character
    field libtype   as character
    field profil-cd as integer
    field etab-cd   as integer
    field nom       as character
    field cpt-cd    as character
    index primaire cpt-cd etab-cd ascending.
{comm/include/tbeclat02.i}              /* Declaration table aligtva-tmp */
define temp-table ttResultat no-undo    /* {tblbpr.i}  Table ttResultat pour extraction des encaissements */
    field NoMdt as integer
    field NoUl  as integer
    field MtHTom as decimal extent 12
    field MtTom  as decimal extent 12
    field MtChg  as decimal extent 12
    field MtTva  as decimal extent 12
    index primaire NoMdt NoUl
.

/* todo  PhM   a reprendre
{comm/tblbpr.i} /* ttResultat La suppression de la table est gérée dans les programmes appelants */
{comm/include/datean.i}
{comm/datean2.i}
*/
define variable gdaDebutQuittance   as date      no-undo. /* Date de début de quittance   */
define variable gdaFinQuittance     as date      no-undo. /* Date de fin de quittance     */
define variable giMandatATraiter    as integer   no-undo.
define variable giNumeroUnite       as integer   no-undo.
define variable gcListeHonoraireTOM as character no-undo.
define variable gcListeTOM          as character no-undo.
define variable gcListeCharges      as character no-undo.
define variable gcListeTVA          as character no-undo.

// Attention, variables globales dans l'ancienne appli
define variable giCodeSoc     as integer   no-undo.    //  TODO  Bien vérifier la mise à disposition de iCodeSoc
define variable giCodeEtab    as integer   no-undo.    //  TODO  Bien vérifier la mise à disposition de iCodeEtab
define variable glTmp-cron    as logical   no-undo.    //  tmp-cron
define variable gdaFinPeriode as date      no-undo.

define buffer bietab for ietab.

function f_daFinClot returns date private(piNumeroSociete as integer, piNumeroMandat as integer, pdtDate as date):
    /*------------------------------------------------------------------------------
    Purpose: Retourne la date de fin d'exercice s'il est cloturé
    Notes: todo  la même dans consultationCompte.p !!!!!
    ------------------------------------------------------------------------------*/
    define buffer iprd   for iprd.
    define buffer vbIprd for iprd.
    define buffer ietab  for ietab.

    for first ietab no-lock
        where ietab.soc-cd  = piNumeroSociete
          and ietab.etab-cd = piNumeroMandat
      , first iprd no-lock
        where iprd.soc-cd    = piNumeroSociete
          and iprd.etab-cd   = piNumeroMandat
          and iprd.dadebprd <= pdtDate
          and iprd.dafinprd >= pdtDate
      , last vbIprd no-lock
        where vbIprd.soc-cd  = piNumeroSociete
          and vbIprd.etab-cd = piNumeroMandat
          and vbIprd.prd-cd  = iprd.prd-cd:
        if vbIprd.daFinprd <= (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1) - 1 then return vbIprd.daFinprd.
    end.
    return ?.
end function.

// todo  -  vérifier que "iCodeSoc" et "iCodeEtab" sont bien dans la collection à l'appel (de genoffqt.p).
assign
    gdaDebutQuittance   = poCollection:getDate("daDebutQuittance")
    gdaFinQuittance     = poCollection:getDate("daFinQuittance")
    giMandatATraiter    = poCollection:getInteger("iMandatATraiter")
    giNumeroUnite       = poCollection:getInteger("iNumeroUnite")
    gcListeHonoraireTOM = poCollection:getCharacter("cListeHonoraireTOM")
    gcListeTOM          = poCollection:getCharacter("cListeTOM")
    gcListeCharges      = poCollection:getCharacter("cListeCharges")
    gcListeTVA          = poCollection:getCharacter("cListeTVA")
    giCodeSoc           = poCollection:getInteger("iCodeSoc")
    giCodeEtab          = poCollection:getInteger("iCodeEtab")
    glTmp-cron          = true
.
if GiCodeSoc <> 2053 then return. /* Uniquement pour BNP */

/* Eclatement des encaissements */
case poCollection:getCharacter("cCodeTraitement"):
    when "ECLAT"   then run eclat.         /* Calcul eclatement des encaissements sur le mandat en entrée ou tous les mandats  **/
    when "EXTRACT" then run extract_eclat. /* Extraction eclatement des encaissements sur le mandat/UL en entrée  **/
    when "VALID"   then run valid_regul.   /* Validation de l'éclatement sur le mandat spécifié **/
end case.

return.

{batch/datetrt.i}

procedure eclat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : todo  a voir - paramètres si  ---> service utilisé par dossierTravaux.p
    ------------------------------------------------------------------------------*/
    define buffer ietab  for ietab.
    define buffer agest  for agest.
    define buffer iprd   for iprd.
    define buffer vbIprd for iprd.

    /**  PERIODE EN COURS **/
    find first ietab no-lock
        where ietab.soc-cd    = gicodesoc 
          and ietab.profil-cd = 20 no-error.
    if not available ietab then return.

    find first agest no-lock
        where agest.soc-cd   = gicodesoc 
          and agest.gest-cle = ietab.gest-cle no-error.
    if not available agest then do:
        mError:CreateError({&error}, 105873).
        return.
    end.  

    find first iprd no-lock
        where iprd.soc-cd   = giCodeSoc
          and iprd.etab-cd  = ietab.etab-cd
          and iprd.dadebprd = agest.dafin + 1 no-error.
    if not available iprd
    then find first iprd no-lock
        where iprd.soc-cd   = giCodeSoc
          and iprd.etab-cd  = ietab.etab-cd
          and iprd.dadebprd = agest.dadeb no-error.
    if not available iprd then return.

    find first vbIprd no-lock
        where vbIprd.soc-cd   = giCodeSoc
          and vbIprd.etab-cd  = ietab.etab-cd
          and vbIprd.dadebprd > iprd.dadebprd no-error.
    if available vbIprd then gdaFinPeriode = vbIprd.dafinprd.
    find first aprof no-lock
        where aprof.profil-cd = 21 no-error.
    if not available aprof then return.

    /* Fourchette de mandats */
    if giMandatATraiter = 0 then do:
        for first bietab no-lock
            where bietab.soc-cd    = gicodesoc
              and bietab.profil-cd = aprof.profil-cd: 
            poCollection:set("iDebutMandat", bietab.etab-cd).
        end.
        for last bietab no-lock
            where bietab.soc-cd = gicodesoc
              and bietab.profil-cd = aprof.profil-cd:
            poCollection:set("iFinMandat", bietab.etab-cd).
        end.
    end. 
    else do:
        poCollection:set("iDebutMandat", giMandatATraiter).
        poCollection:set("iFinMandat", giMandatATraiter).
    end.
    poCollection:set("dFinPeriode", gdaFinPeriode).
    poCollection:set("lSelection",  true).
    poCollection:set("cCompte",     "").
    poCollection:set("lStop",       false).
    poCollection:set("lCron",       glTmp-cron).
    for each agest no-lock
        where agest.soc-cd = gicodesoc: /* on boucle sur tous les gestionnaires ==> au cas ou pls gest pour gerance */
        poCollection:set("cGestionnaire", agest.gest-cle).
        for each iprd no-lock
            where iprd.soc-cd    = giCodeSoc
              and iprd.etab-cd   = ietab.etab-cd         /* mandat global */
              and iPrd.dadebprd <= gdaFinPeriode
              and iPrd.dafinprd >= (if ietab.exercice then ietab.dadebex2 else ietab.Dadebex1):
            poCollection:set("i6NumeroPeriode", iprd.prd-num).
            poCollection:set("dDeclaration",    iprd.dafinprd).
            run batch/adecla1.p(poCollection, table ttMandatTravail by-reference).
        end.
    end.

end procedure.

procedure extract_eclat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : todo  a voir - paramètres si  ---> service utilisé par dossierTravaux.p
    ------------------------------------------------------------------------------*/
    define variable vcRetour       as character no-undo.
    define variable viIndice       as integer   no-undo.
    define variable vcCodeRubrique as character no-undo.
    /* Extraction */
    find first ietab no-lock
        where ietab.soc-cd  = GiCodeSoc
          and ietab.etab-cd = giMandatATraiter no-error.
    if not available ietab then return.

    /* Chargement de la table aligtva-tmp */
    run batch/extencqt.p(
        giCodeSoc,
        ietab.etab-cd,
        gdaDebutQuittance,
        gdaFinQuittance,
        "O",                         /* Simulation = TRUE -> prendre les réguls AR */
        output table aligtva-tmp by-reference,
        output vcRetour).
    /** Cumul par UL **/
    for each aligtva-tmp 
        where giNumeroUnite = 0 
           or substring(aligtva-tmp.compte, 6, 3, "character") = string(giNumeroUnite, "999"):
        vcCodeRubrique = string(aligtva-tmp.coderub).
        if lookup(vcCodeRubrique, gcListeTOM)  > 0 
        or lookup(vcCodeRubrique, gcListeHonoraireTOM) > 0
        or lookup(vcCodeRubrique, gcListeCharges)  > 0
        or lookup(vcCodeRubrique, gcListeTVA)  > 0
        then do: 
            mLogger:writeLog(9, substitute("extraction aligtva-tmp pour mandat &1 UL &2 compte &3: rub &4 datecompta = &5 Montant = &6",
                                           aligtva-tmp.etab-cd, string(giNumeroUnite, "999"), aligtva-tmp.compte, aligtva-tmp.coderub, aligtva-tmp.datecompta,aligtva-tmp.mtrub)).
            viIndice = integer(substring(aligtva-tmp.compte, 6, 3, "character")).
            find first ttResultat
                where ttResultat.NoMdt = aligtva-tmp.etab-cd
                  and ttResultat.NoUl  = viIndice no-error.
            if not available ttResultat then do:
                create ttResultat.
                assign
                    ttResultat.NoMdt = aligtva-tmp.etab-cd
                    ttResultat.NoUl  = viIndice
                .
            end.
            viIndice = integer(substring(aligtva-tmp.datecompta, 5, 2, "character")).
            if lookup(vcCodeRubrique, gcListeTOM) > 0
            then ttResultat.MtTom[viIndice]  = ttResultat.MtTom[viIndice]  + aligtva-tmp.mtrub.  /* Familles Ordure Menagere */
            else if lookup(vcCodeRubrique, gcListeHonoraireTOM) > 0 
            then ttResultat.MtHTom[viIndice] = ttResultat.MtHTom[viIndice] + aligtva-tmp.mtrub.  /* Familles Hors Ordure Menagere */
            else if lookup(vcCodeRubrique, gcListeCharges) > 0 
            then ttResultat.MtChg[viIndice]  = ttResultat.MtChg[viIndice]  + aligtva-tmp.mtrub.  /* Familles Charges */
            else if lookup(vcCodeRubrique, gcListeTVA) > 0 
            then ttResultat.MtTVA[viIndice]  = ttResultat.MtTVA[viIndice]  + aligtva-tmp.mtrub.  /* Familles TVA */             
        end.
    end.
    output CLOSE.
end procedure.

procedure valid_regul:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable cTmpParam-In  as character no-undo.
    define variable cTmpParam-Out as character no-undo.
    define variable dDateTva      as date      no-undo.
    define variable dDateCrg      as date      no-undo.
    define variable dDateIrf      as date      no-undo.
    define variable dDateHono     as date      no-undo.
    
    define buffer b2iprd for iprd.

    for each ietab no-lock
        where ietab.soc-cd = GiCodeSoc
          and ietab.profil-cd = 21 
          and ietab.etab-cd = giMandatATraiter:
        find agest of ietab no-lock no-error.
        if not available ietab then do:
            mLogger:writeLog(9, substitute("*** Erreur *** valid_regul : Le mandat &1 n'est pas rattache a un responsable comptable", ietab.etab-cd)).
            next.
        end.
        /* date de dernier traitement */
        cTmpParam-In = string(ietab.etab-cd) + chr(9) + string(gdaFinQuittance).
        run datetrt(ietab.etab-cd, gdaFinQuittance, output cTmpParam-Out).
        assign
            dDateTva  = date(entry(4, cTmpParam-Out, chr(9))) /* derniere tva validée      */
            dDateCrg  = date(entry(5, cTmpParam-Out, chr(9))) /* dernier crg editée        */
            dDateIrf  = date(entry(6, cTmpParam-Out, chr(9))) /* dernier irf/qufl validé   */
            dDateHono = date(entry(7, cTmpParam-Out, chr(9))) /* dernier honoraire calculé */
        .
        /* On ne prend pas les réguls en attente si les autres états ont été validés */                      
        if gdaFinQuittance <= dDateTva or gdaFinQuittance <= dDateIrf
        or gdaFinQuittance <  dDateCrg or gdaFinQuittance <  dDateHono then next.

        for each adbtva exclusive-lock
            where adbtva.soc-cd  = GiCodeSoc
              and adbtva.etab-cd = ietab.etab-cd
              and adbtva.lib-trt = "AR":
            /* l'écriture doit être antérieure à la date de fin */
            find first cecrln no-lock
                where cecrln.soc-cd    = adbtva.soc-cd
                  and cecrln.etab-cd   = adbtva.etab-cd
                  and cecrln.jou-cd    = adbtva.jou-cd
                  and cecrln.prd-cd    = adbtva.prd-cd
                  and cecrln.prd-num   = adbtva.prd-num
                  and cecrln.piece-int = adbtva.piece-int
                  and cecrln.lig       = adbtva.lig
                  and cecrln.sscoll-cle = "L" no-error.
            if not available cecrln or cecrln.dacompta > gdaFinQuittance then next. 

            find first ijou no-lock
                where ijou.soc-cd  = cecrln.soc-cd
                  and ijou.etab-cd = cecrln.mandat-cd
                  and ijou.jou-cd  = cecrln.jou-cd
                  and (ijou.natjou-cd = 2 
                    or ijou.natjou-gi = 46
                    or ijou.natjou-gi = 93
                    or (ijou.natjou-gi = 40 and giCodeSoc <> 3073)) no-error.
            if not available ijou
            /* Hors AN : ne pas prendre les regules >= date de fin d'exercice si exercice cloturé, elles sont reportées en AN et traitées avec les AN */
            or (ijou.natjou-cd <> 9 and adbtva.lib-trt > "" and (adbtva.date_decla > f_DaFinClot(GiCodeSoc,ietab.etab-cd,cecrln.dacompta)))
            or (ijou.natjou-cd =  9 and not(adbtva.lib-trt > "" and adbtva.date_decla >= cecrln.dacompta
                     /* DM 0109/0232 24/04/09 la régule n'est pas sur l'exercice de l'écriture : on ne la prend pas */
                 and f_DaFinClot(GiCodeSoc,ietab.etab-cd,cecrln.dacompta) = f_DaFinClot(GiCodeSoc,ietab.etab-cd,adbtva.date_decla)))
            then next.
          
            adbtva.lib-trt = "R". /* -> Affecté à cette periode */
            for first b2iprd no-lock
                where b2iprd.soc-cd   = GiCodeSoc
                  and b2iprd.etab-cd  = adbtva.etab-cd
                  and b2iprd.dadebprd <= gdaFinQuittance
                  and b2iprd.dafinprd >= gdaFinQuittance:
                assign
                    adbtva.date_decla = b2iprd.dafinprd
                    adbtva.periode    = b2iprd.prd-num
                    adbtva.date-trt   = b2iprd.dafinprd
                .
                for each aligtva exclusive-lock
                    where aligtva.soc-cd = adbtva.soc-cd
                      and aligtva.etab-cd = adbtva.etab-cd
                      and aligtva.num-int = adbtva.num-int:
                    aligtva.periode = adbtva.periode.
                end.
            end.
        end.
    end.

end procedure.
