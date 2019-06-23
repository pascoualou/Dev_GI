/*--------------------------------------------------------------------------------
File        : soldmdt2.p
Purpose     : Solde d'un mandat resilié par OD - ODFM    
Author(s)   : PS 20/03/02  -  GGA 18/01/19
Notes       : reprise cadb/gestion/soldmdt2.p
derniere revue: 2018/03/20 - phm
01  16/04/2002  PS    0302/0869: modif du format de prd-cd dans la trace 
02  20/06/2002  SG    0602/1236: recharge environnement gestion Même quand compte soldé
03  04/07/2002  PS    0602/1251: pas de od si uniquement M ou compte général non soldé
04  21/01/2003  PBP   0103/0216: recharge environnement gestion
05  22/09/2003  PS    0903/0211: erreur dans la creation de BAP si mt = 0.
06  15/01/2004  JR    1103/0263
07  13/04/2004  OF    0404/0110: pb arrondis avec calculs tantiemes
08  11/04/2005  SY    0205/0262: plages mandats copro/gerance
09  10/07/2007  DM    0707/1039: ODFM avant cloture ex n-1
10  22/03/2008  OF    0108/0181 Suite modif précédente, l'ODFM ne se fait plus pour les mandats de gérance
11  06/05/2008  OF    0408/0300 Les montants des comptes P sont faux + modif indivisions successives Dauchez
12  30/06/2008  OF    0608/0217 Mise au point modif précédente
14  02/10/2008  DM    0908/0155 Problème appel chgper01
15  19/09/2008  DM    0608/0065: Mandat 5 chiffres
16  17/10/2008  MB    0708/0038: ODFM
17  05/11/2008  JR    1108/0272: suite de modif 15 + 16
18  07/11/2008  JR    0708/0038: Quand aucune écriture sur le mandat, créer une ligne (gcSscollCle + gcCptCd) à 0
19  10/02/2009  JR    0209/0062: debug de 0708/0038: Le bug créait des écritures avec une trace et avec dadoss = TODAY
20  01/07/2009  DM    0609/0212: cbap sur 4999
21  04/01/2012  PL    PB remise à false de tmp-cron avant tous les return.
22  30/01/2018  OF    #12053: Il ne faut pas solder les comptes par dossier travaux en gérance
--------------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/flagLettre-cLettre-inumpiec.i}
{compta/include/tbdelettrage.i}
{comm/include/tantiemeMandat.i}

define temp-table ttDossier no-undo 
    field affair-num as integer
    field sscoll-cle as character
    field cpt-cd     as character
    field sens       as logical
    field mt         as decimal decimals 2
    index dossier affair-num sscoll-cle cpt-cd
.
define temp-table ttPeriod no-undo 
    field dadeb  as date
    field dafin  as date
    field traite as logical
    index prd-i dadeb
.
define temp-table ttPiece no-undo 
    field cRwd          as character
    field UneSeuleLigne as logical
.
define temp-table cecrsai-tmp no-undo like cecrsai
    index primaire soc-cd etab-cd jou-cd prd-cd prd-num piece-compta
.
define temp-table cecrln-tmp no-undo like cecrln
    index primaire     soc-cd etab-cd   jou-cd prd-cd        prd-num        piece-int lig  
    index ecrln-mandat soc-cd mandat-cd jou-cd mandat-prd-cd mandat-prd-num piece-int lig
.
define temp-table cecrlnana-tmp no-undo like cecrlnana
    index primaire soc-cd etab-cd jou-cd prd-cd prd-num piece-int lig pos ana-cd
. 
define temp-table aecrdtva-tmp no-undo like aecrdtva
    index primaire soc-cd etab-cd jou-cd prd-cd prd-num piece-int lig cdrub cdlib
.
define variable giCodeSociete   as integer   no-undo.      /* société */
define variable giMandatASolder as integer   no-undo.      /* mandat a solder */
define variable gdaResil        as date      no-undo.      /* date comptable du solde */
define variable gcSscollCle     as character no-undo.
define variable gcCptCd         as character no-undo.

procedure soldmmdt2Lancement:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSociete   as integer no-undo.
    define input  parameter piMandatASolder as integer no-undo.
    define input  parameter pdaComptableOD  as date    no-undo.
    define input  parameter pdaResiliation  as date    no-undo.
    define output parameter piCodeRetour    as integer no-undo initial 1. // code retour 0 = OK

    define variable vcListePeriode   as character no-undo.
    define variable vdaDebutExercice as date      no-undo.
    define variable viCompteur       as integer   no-undo.  
    define variable vhOutilMandat    as handle    no-undo.
    define variable vcRetour         as character no-undo.

    define buffer ietab for ietab.
    define buffer aparm for aparm.
    define buffer iprd  for iprd.
 
    assign 
        giCodeSociete   = piCodeSociete
        giMandatASolder = piMandatASolder
        gdaResil        = pdaResiliation.  
    
    empty temp-table ttPiece.
    if not can-find(first isoc no-lock 
                    where isoc.soc-cd = giCodeSociete)
    then do:
        piCodeRetour = 2. /* société compta absente */
        return.
    end.
    find first ietab no-lock
         where ietab.soc-cd  = giCodeSociete
           and ietab.etab-cd = giMandatASolder no-error.
    if not available ietab
    then do:
        piCodeRetour = 3. /* mandat absent */
        return.
    end.
    if ietab.profil-cd = 21
    then assign
        gcCptCd       = "00000"
        gcSscollCle   = "M"
    .
    else do:
        find first aparm no-lock
             where aparm.tppar = "RESOD"
               and aparm.cdpar = "CPT" no-error.
        assign 
            gcCptCd       = aparm.zone2 when available aparm
            gcSscollCle   = ""
        .
        run mandat/outilMandat.p persistent set vhOutilMandat.
        run getTokenInstance in vhOutilMandat(mToken:JSessionId).
        run chargePeriodesMandat in vhOutilMandat(giCodeSociete,
                                                  giMandatASolder,
                                                  ietab.dafinex1,
                                                  "T",
                                                  output vcRetour,
                                                  output vcListePeriode).
        run destroy in vhOutilMandat.
        /* Periodes d'arrete des charges */
        empty temp-table ttPeriod.
        if vcRetour = "000"
        then do viCompteur = 1 to num-entries(vcListePeriode, "|"):
            create ttPeriod.
            assign
                ttPeriod.dadeb  = date(entry(2, entry(viCompteur, vcListePeriode, "|"), "@"))
                ttPeriod.dafin  = date(entry(3, entry(viCompteur, vcListePeriode, "|"), "@"))
                ttPeriod.traite = (integer(entry(4, entry(viCompteur, vcListePeriode, "|"), "@")) = 3)
            .
        end.
        find first ttPeriod 
             where ttPeriod.dadeb <= ietab.dadebex1 
               and ttPeriod.dafin >= ietab.dafinex1 
               and ttPeriod.traite = false no-error.
    end.
    vdaDebutExercice = if ietab.exercice then ietab.dadebex2 else ietab.dadebex1.
    if ietab.exercice = false and pdaComptableOD > ietab.dafinex1 and available ttPeriod
    then do:
        find first iprd no-lock 
             where iprd.soc-cd   = giCodeSociete
               and iprd.etab-cd  = giMandatASolder
               and iprd.dadebprd <= ietab.dafinex1
               and iprd.dafinprd >= ietab.dafinex1 no-error.
        if not available iprd 
        then do:
            piCodeRetour = 4. /* periode inexistante */
            return.
        end.
        vdaDebutExercice = ietab.dadebex2.
        run validation(buffer ietab, ietab.dadebex1, ietab.dafinex1).
    end.
    find first iprd no-lock
         where iprd.soc-cd   = giCodeSociete
           and iprd.etab-cd  = giMandatASolder
           and iprd.dadebprd <= pdaComptableOD
           and iprd.dafinprd >= pdaComptableOD no-error.
    if not available iprd 
    then do:
        piCodeRetour = 4. /* periode inexistante */
        return.
    end.
    run validation(buffer ietab, vdaDebutExercice, pdaComptableOD).
    run validation-piece(buffer ietab).
    piCodeRetour = 0.

end procedure.

procedure validation private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab for ietab.
    define input parameter pdaDebutExercice as date no-undo.
    define input parameter pdaFinExercice   as date no-undo.

    define variable vdeReste          as decimal no-undo.
    define variable vdeSoldeDossier   as decimal no-undo.
    define variable vdeSoldeCptPartie as decimal no-undo.
    define variable vdeSoldeM         as decimal no-undo.
    define variable vdeSoldeP         as decimal no-undo.
    define variable viLigne           as integer no-undo.
    define variable vlUneSeuleLigne   as logical no-undo.
    define variable viNoDossier       as integer no-undo. 
    define variable vrRowidCecrsaiTmp as rowid   no-undo. 
    define variable vhLstIndi         as handle  no-undo.

    define buffer cecrln for cecrln.
    define buffer csscpt for csscpt.
    empty temp-table ttDossier.
    
// TODO  cecrln est une très grosse table, 20 000 000 dans ma base, 
// TODO  et l'index soc-cd, etab-cd n'est pas terrible. N'y a t'il pas un autre moyen ?????
    for each cecrln no-lock 
        where cecrln.soc-cd   = giCodeSociete
          and cecrln.etab-cd  = giMandatASolder 
          and cecrln.dacompta >= pdaDebutExercice
          and cecrln.dacompta <= pdaFinExercice
          and not(cecrln.sscoll-cle = "" and cecrln.cpt-cd begins "5"):
        find first ttDossier
             where ttDossier.affair-num = (if ietab.profil-cd = 91 then cecrln.affair-num else 0) /**Ajout phm suite ajout ci-dessous par OF le 30/01/18**/
               and ttDossier.sscoll-cle = cecrln.sscoll-cle
               and ttDossier.cpt-cd     = cecrln.cpt-cd no-error.
        if not available ttDossier 
        then do:
            create ttDossier.
            assign 
                ttDossier.affair-num = if ietab.profil-cd = 91 then cecrln.affair-num else 0 /**Ajout du test copro/gérance par OF le 30/01/18**/
                ttDossier.sscoll-cle = cecrln.sscoll-cle
                ttDossier.cpt-cd     = cecrln.cpt-cd.
        end.
        if cecrln.sens 
        then ttDossier.mt = ttDossier.mt - cecrln.mt.
        else ttDossier.mt = ttDossier.mt + cecrln.mt.
    end.
    for each ttDossier where ttDossier.mt = 0:
        delete ttDossier.
    end.
    if not can-find(first ttDossier) then do:
        create ttDossier.
        assign 
            vlUneSeuleLigne       = true
            ttDossier.affair-num = 0
            ttDossier.sscoll-cle = gcSscollCle
            ttDossier.cpt-cd     = gcCptCd
            ttDossier.mt         = 0
        .
    end.
    run creation-Entete(buffer ietab, pdaFinExercice, viNoDossier, output vrRowidCecrsaiTmp).
    find first cecrsai-tmp where rowid(cecrsai-tmp) = vrRowidCecrsaiTmp no-error.
    create ttPiece.
    assign 
        ttPiece.cRwd          = string(rowid(cecrsai-tmp))
        ttPiece.UneSeuleLigne = vlUneSeuleLigne
    .
    for each ttDossier 
        where ttDossier.sscoll-cle <> "P"
        break by ttDossier.affair-num:

        if first-of(ttDossier.affair-num) 
        then assign 
            vdeSoldeDossier = 0 
            viNoDossier     = ttDossier.affair-num
        .
        if ttDossier.sscoll-cle = "M" then vdeSoldeM = ttDossier.mt.
        viLigne = viLigne + 10.
        if ttDossier.sscoll-cle <> "M" 
        then run creation-Ligne(buffer ietab,
                                pdaFinExercice,
                                ttDossier.sscoll-cle,
                                ttDossier.cpt-cd,
                                ttDossier.mt,
                                viLigne,
                                cecrsai-tmp.lib,
                                viNoDossier).
        vdeSoldeDossier = vdeSoldeDossier - ttDossier.mt.

        /******* CONTREPARTIE ******/
        if last-of(ttDossier.affair-num) then do:
            viLigne = viLigne + 10.
            /** GERANCE **/
            if gcSscollCle = "M" 
            then do:                /***** Contrepartie du dossier ******/
                vdeSoldeCptPartie = vdeSoldeCptPartie + vdeSoldeDossier.
                run creation-Ligne(buffer ietab,
                                   pdaFinExercice, 
                                   gcSscollCle,
                                   gcCptCd,
                                   vdeSoldeDossier + vdeSoldeM,
                                   viLigne,
                                   cecrsai-tmp.lib,
                                   viNoDossier).
            end.
            else         /** COPROPRIETE **/
            if vdeSoldeDossier <> 0 then do:
                /***** Contrepartie du dossier ******/
                vdeSoldeCptPartie = vdeSoldeCptPartie + vdeSoldeDossier.
                run creation-Ligne(buffer ietab,
                                   pdaFinExercice, 
                                   gcSscollCle,
                                   gcCptCd,
                                   vdeSoldeDossier,
                                   viLigne,
                                   cecrsai-tmp.lib,
                                   viNoDossier).
            end.
        end.
    end.

    if ietab.profil-cd = 91 and vdeSoldeCptPartie < 0
    then for last cecrln-tmp
        where cecrln-tmp.soc-cd         = cecrsai-tmp.soc-cd
          and cecrln-tmp.mandat-cd      = cecrsai-tmp.etab-cd
          and cecrln-tmp.jou-cd         = cecrsai-tmp.jou-cd
          and cecrln-tmp.mandat-prd-cd  = cecrsai-tmp.prd-cd
          and cecrln-tmp.mandat-prd-num = cecrsai-tmp.prd-num
          and cecrln-tmp.piece-int      = cecrsai-tmp.piece-int
          and cecrln-tmp.sscoll-cle     = gcSscollCle
          and cecrln-tmp.cpt-cd         = gcCptCd:
        run creation-cbap(buffer ietab, buffer cecrln-tmp, absolute(vdeSoldeCptPartie)).
    end.

    /*** a ce niveau c OK pour la copro, mais reste a repartir par propriétaire en gerance */
    if ietab.profil-cd = 21 and vdeSoldeCptPartie <> 0 then do:
        assign
            viNoDossier =  0
            viLigne     = viLigne + 10
        .
        /*** SOLDE DU COMPTE M ***/ 
        run creation-Ligne(buffer ietab,
                           pdaFinExercice, 
                           gcSscollCle,
                           gcCptCd,
                           - vdeSoldeCptPartie,
                           viLigne,
                           cecrsai-tmp.lib,
                           viNoDossier). 
        /*** Répartition du compte M sur les propriétaires ***/
        vdeReste = vdeSoldeCptPartie.
        empty temp-table ttTantiemeMandat. 
        run comm/lst_indi.p persistent set vhLstIndi.
        run getTokenInstance in vhLstIndi(mToken:JSessionId).
        run lstIndiLancement in vhLstIndi(giMandatASolder, output table ttTantiemeMandat by-reference).
        run destroy in vhLstIndi.
boucle:
        for each ttTantiemeMandat 
            where ttTantiemeMandat.imdt      = giMandatASolder
              and ttTantiemeMandat.iNum_reel <> 0
            break by ttTantiemeMandat.iNumeroIndivisaire:
            find first csscpt no-lock
                 where csscpt.soc-cd       = giCodeSociete
                   and csscpt.etab-cd      = ttTantiemeMandat.imdt
                   and csscpt.sscoll-cle   = "P"
                   and csscpt.cpt-cd       = string(ttTantiemeMandat.iNumeroIndivisaire,"99999") no-error.
            if not available csscpt then next boucle. /** Pour les indivisaires de role 00018 **/

            viLigne = viLigne + 10.
            if not last(ttTantiemeMandat.iNumeroIndivisaire) then do: 
                vdeReste = vdeReste - round(vdeSoldeCptPartie  * ttTantiemeMandat.iNum_reel / ttTantiemeMandat.iDen_reel, 2).
                run creation-Ligne(buffer ietab,
                                   pdaFinExercice, 
                                   "P",
                                   csscpt.cpt-cd,
                                   round(vdeSoldeCptPartie * ttTantiemeMandat.iNum_reel / ttTantiemeMandat.iDen_reel, 2),
                                   viLigne,
                                   cecrsai-tmp.lib,
                                   viNoDossier).
            end.
            else run creation-Ligne(buffer ietab,
                                    pdaFinExercice,
                                    "P",
                                    csscpt.cpt-cd,
                                    vdeReste,
                                    viLigne,
                                    cecrsai-tmp.lib, 
                                    viNoDossier).
                                    
            find first ttDossier
                 where ttDossier.sscoll-cle = "P"
                   and ttDossier.cpt-cd = csscpt.cpt-cd no-error.
            vdeSoldeP = cecrln-tmp.mt * (if cecrln-tmp.sens then -1 else 1) + (if available ttDossier then ttDossier.mt else 0).
            if vdeSoldeP > 0 then run creation-cbap(buffer ietab, buffer cecrln-tmp, input vdeSoldeP).     
        end.
    end.

end procedure.

procedure creation-Entete private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define        parameter buffer ietab for ietab.
    define input  parameter pdaExercice       as date    no-undo.
    define input  parameter piNoDossier       as integer no-undo. 
    define output parameter prRowidCecrsaiTmp as rowid   no-undo. 
    
    define buffer ijou     for ijou.
    define buffer iprd     for iprd.
    define buffer cnumpiec for cnumpiec.
                  
    find first ijou no-lock 
         where ijou.soc-cd  = giCodeSociete
           and ijou.etab-cd = giMandatASolder
           and ijou.jou-cd  = "OD" no-error.
    if not available ijou then return.

    find first iprd no-lock
         where iprd.soc-cd   = ijou.soc-cd
           and iprd.etab-cd  = ijou.etab-cd
           and iprd.dadebprd = date(month(pdaExercice), 01, year(pdaExercice)) no-error.
    if not available iprd then return.

    create cecrsai-tmp.
    assign  
        prRowidCecrsaiTmp          = rowid(cecrsai-tmp)
        cecrsai-tmp.soc-cd         = giCodeSociete
        cecrsai-tmp.etab-cd        = giMandatASolder
        cecrsai-tmp.jou-cd         = ijou.jou-cd
        cecrsai-tmp.daecr          = gdaResil
        cecrsai-tmp.lib            = "SOLDE DU MANDAT " + string(pdaExercice)
        cecrsai-tmp.dacrea         = today
        cecrsai-tmp.dev-cd         = ietab.dev-cd
        cecrsai-tmp.consol         = false
        cecrsai-tmp.bonapaye       = true
        cecrsai-tmp.situ           = ?
        cecrsai-tmp.cours          = 1
        cecrsai-tmp.mtregl         = 0
        cecrsai-tmp.type-cle       = "ODFM":U
        cecrsai-tmp.piece-compta   = -1 /* Provisoire mise a jour dans Validation-piece */
        cecrsai-tmp.dossier-num    = 0
        cecrsai-tmp.affair-num     = piNoDossier
        cecrsai-tmp.prd-cd         = iprd.prd-cd
        cecrsai-tmp.prd-num        = iprd.prd-num
        cecrsai-tmp.mtdev          = 0
        cecrsai-tmp.natjou-cd      = ijou.natjou-cd
        cecrsai-tmp.dadoss         = ?
        cecrsai-tmp.daaff          = ?
        cecrsai-tmp.dacompta       = pdaExercice
        cecrsai-tmp.ref-num        = "SFM" + (if giMandatASolder <= 9999 then string(giMandatASolder, "9999") else string(giMandatASolder, "99999"))
        cecrsai-tmp.coll-cle       = ""
        cecrsai-tmp.mtimput        = 0
        cecrsai-tmp.acompte        = false
        cecrsai-tmp.acpt-jou-cd    = ""
        cecrsai-tmp.acpt-type      = ""
        cecrsai-tmp.adr-cd         = 0
        cecrsai-tmp.typenat-cd     = 1
        cecrsai-tmp.usrid-eff      = ""
        cecrsai-tmp.daeff          = ?
        cecrsai-tmp.profil-cd      = ietab.profil-cd 
        cecrsai-tmp.regl-mandat-cd = 0
        cecrsai-tmp.regl-jou-cd    = ""
    .
    //Numérotation de la piece
    find first cnumpiec exclusive-lock
        where cnumpiec.soc-cd   = cecrsai-tmp.soc-cd
          and cnumpiec.etab-cd  = cecrsai-tmp.etab-cd
          and cnumpiec.jou-cd   = cecrsai-tmp.jou-cd
          and cnumpiec.prd-cd   = cecrsai-tmp.prd-cd
          and cnumpiec.prd-num  = cecrsai-tmp.prd-num no-error.
    if available cnumpiec 
    then cnumpiec.piece-int = cnumpiec.piece-int + 1.
    else do:
        create cnumpiec.
        assign
            cnumpiec.soc-cd       = cecrsai-tmp.soc-cd
            cnumpiec.etab-cd      = cecrsai-tmp.etab-cd
            cnumpiec.jou-cd       = cecrsai-tmp.jou-cd
            cnumpiec.prd-cd       = cecrsai-tmp.prd-cd
            cnumpiec.prd-num      = cecrsai-tmp.prd-num
            cnumpiec.piece-compta = inumpiecNumerotationPiece(ijou.fpiece, cecrsai-tmp.dacompta)
            cnumpiec.piece-int    = 1
        .
    end.
    cecrsai-tmp.piece-int = cnumpiec.piece-int.

end procedure.

procedure creation-Ligne private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab for ietab.
    define input parameter pdaExercice as date      no-undo.
    define input parameter pcCollectif as character no-undo.
    define input parameter pcCompte    as character no-undo.
    define input parameter pdMontant   as decimal   no-undo.
    define input parameter piLigne     as integer   no-undo.
    define input parameter pcLibelle   as character no-undo.
    define input parameter piNoDossier as integer   no-undo. 
  
    define buffer iprd      for iprd.
    define buffer csscptcol for csscptcol.
    define buffer ccptcol   for ccptcol.
    define buffer ccpt      for ccpt.
    
    find first iprd no-lock
         where iprd.soc-cd   = cecrsai-tmp.soc-cd
           and iprd.etab-cd  = giMandatASolder
           and iprd.dadebprd = date(month(pdaExercice), 01, year(pdaExercice)) no-error.
    if not available iprd then return.

    create cecrln-tmp.    
    assign  
        cecrln-tmp.soc-cd           = cecrsai-tmp.soc-cd
        cecrln-tmp.etab-cd          = giMandatASolder
        cecrln-tmp.jou-cd           = cecrsai-tmp.jou-cd
        cecrln-tmp.piece-int        = cecrsai-tmp.piece-int
        cecrln-tmp.sscoll-cle       = pcCollectif
        cecrln-tmp.cpt-cd           = pcCompte
        cecrln-tmp.lib              = pcLibelle
        cecrln-tmp.sens             = pdMontant >= 0
        cecrln-tmp.mt               = absolute (pdMontant)          
        cecrln-tmp.dev-cd           = cecrsai-tmp.dev-cd          
        cecrln-tmp.type-cle         = cecrsai-tmp.type-cle            
        cecrln-tmp.datecr           = cecrsai-tmp.daecr
        cecrln-tmp.prd-cd           = iprd.prd-cd
        cecrln-tmp.prd-num          = iprd.prd-num
        cecrln-tmp.lig              = piLigne 
        cecrln-tmp.coll-cle         = ""
        cecrln-tmp.paie-regl        = false
        cecrln-tmp.tva-enc-deb      = false            
        cecrln-tmp.analytique       = pcCollectif = "M"
        cecrln-tmp.dacompta         = cecrsai-tmp.dacompta
        cecrln-tmp.ref-num          = cecrsai-tmp.ref-num
        cecrln-tmp.flag-lettre      = false
        cecrln-tmp.daech            = cecrsai-tmp.dacompta
        cecrln-tmp.type-ecr         = if cecrln-tmp.analytique then 2 else 1
        cecrln-tmp.mandat-cd        = cecrsai-tmp.etab-cd
        cecrln-tmp.mandat-prd-cd    = cecrsai-tmp.Prd-cd
        cecrln-tmp.mandat-prd-num   = cecrsai-tmp.Prd-num
        cecrln-tmp.fourn-sscoll-cle = if cecrln-tmp.sscoll-cle = "M" then "F" else ""
        cecrln-tmp.fourn-cpt-cd     = if cecrln-tmp.sscoll-cle = "M" then "00000" else ""
        cecrln-tmp.mttva            = 0
        cecrln-tmp.profil-cd        = ietab.profil-cd
        cecrln-tmp.lib-ecr[1]       = cecrln-tmp.lib
    .
    if pcCollectif > ""
    then for first csscptcol no-lock
        where csscptcol.soc-cd     = giCodeSociete
          and csscptcol.etab-cd    = giMandatASolder
          and csscptcol.sscoll-cle = pcCollectif:
        find first ccptcol no-lock
            where ccptcol.soc-cd   = csscptcol.soc-cd
              and ccptcol.coll-cle = csscptcol.coll-cle no-error.
        assign
            cecrln-tmp.coll-cle = csscptcol.coll-cle
            cecrln-tmp.fg-ana100  = (available ccptcol and ccptcol.libimp-cd = 1)
            cecrln-tmp.analytique = cecrln-tmp.fg-ana100
        .
    end.
    else do:
        find first ccpt no-lock
             where ccpt.soc-cd   = giCodeSociete 
               and ccpt.coll-cle = ""
               and ccpt.cpt-cd   = pcCompte no-error.
        assign 
            cecrln-tmp.fg-ana100  = (available ccpt and ccpt.libimp-cd = 1)
            cecrln-tmp.analytique = cecrln-tmp.fg-ana100
        .
    end.
    /*** Si l'écriture n'est pas une écriture de contre-partie ***/
    if not (cecrln-tmp.sscoll-cle = gcSscollCle and cecrln-tmp.cpt-cd = gcCptCd)
    then cecrln-tmp.affair-num = piNoDossier.
    else cecrln-tmp.affair-num = 0.
    if cecrln-tmp.sens then cecrsai-tmp.mtdev = cecrsai-tmp.mtdev + cecrln-tmp.mt.
    /* Creation ligne analytique */
    if cecrln-tmp.analytique then do:
        create cecrlnana-tmp.
        assign  
            cecrlnana-tmp.soc-cd     = cecrln-tmp.soc-cd
            cecrlnana-tmp.etab-cd    = cecrln-tmp.etab-cd
            cecrlnana-tmp.jou-cd     = cecrln-tmp.Jou-cd
            cecrlnana-tmp.prd-cd     = cecrln-tmp.Prd-cd
            cecrlnana-tmp.prd-num    = cecrln-tmp.Prd-num
            cecrlnana-tmp.type-cle   = cecrln-tmp.Type-cle
            cecrlnana-tmp.doss-num   = ""
            cecrlnana-tmp.datecr     = cecrln-tmp.datecr
            cecrlnana-tmp.cpt-cd     = cecrln-tmp.cpt-cd
            cecrlnana-tmp.lib        = cecrln-tmp.lib
            cecrlnana-tmp.sens       = cecrln-tmp.sens
            cecrlnana-tmp.mt         = cecrln-tmp.mt          
            cecrlnana-tmp.pourc      = 100
            cecrlnana-tmp.report-cd  = 0
            cecrlnana-tmp.budg-cd    = 0
            cecrlnana-tmp.lig        = cecrln-tmp.lig
            cecrlnana-tmp.piece-int  = cecrsai-tmp.piece-int
            cecrlnana-tmp.ana1-cd    = "999"
            cecrlnana-tmp.ana2-cd    = "999"
            cecrlnana-tmp.ana3-cd    = "1"
            cecrlnana-tmp.ana4-cd    = (if ietab.profil-cd >= 90 then "A" else "")
            cecrlnana-tmp.ana-cd     = cecrlnana-tmp.ana1-cd +
                                       cecrlnana-tmp.ana2-cd +
                                       cecrlnana-tmp.ana3-cd +
                                       cecrlnana-tmp.ana4-cd
            cecrlnana-tmp.pos        = 10
            cecrlnana-tmp.typeventil = true
            cecrlnana-tmp.sscoll-cle = cecrln-tmp.sscoll-cle
            cecrlnana-tmp.dacompta   = cecrln-tmp.dacompta
            cecrlnana-tmp.dev-cd     = cecrln-tmp.dev-cd
            cecrlnana-tmp.taxe-cd    = cecrln-tmp.taxe-cd
            cecrlnana-tmp.analytique = cecrln-tmp.analytique
            cecrlnana-tmp.mtdev      = 0
            cecrlnana-tmp.devetr-cd  = ""
            cecrlnana-tmp.affair-num = piNoDossier
            cecrlnana-tmp.tva-cd     = 0
            cecrlnana-tmp.mttva      = cecrln-tmp.mttva
            cecrlnana-tmp.taux-cle   = 100
            cecrlnana-tmp.tantieme   = 0
            cecrlnana-tmp.mttva-dev  = 0
            cecrlnana-tmp.lib-ecr[1] = cecrln-tmp.lib-ecr[1]
            cecrlnana-tmp.regrp      = "" 
        .
    end.

end procedure.

procedure Validation-Piece private:
    /*------------------------------------------------------------------------------
    purpose: Passage des tables temporaires aux tables reelles pour les tables cecrsai, cecrln et cecrlnana
    Note   :
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab for ietab.
    
    define variable vhCecrgval  as handle no-undo.
    define variable vhAlimaj    as handle no-undo.
    define variable vrRecno-sai as rowid  no-undo.

    define buffer cecrsai for cecrsai.

    run compta/souspgm/cecrgval.p persistent set vhCecrgval.
    run getTokenInstance in vhCecrgval(mToken:JSessionId).
    run application/transfert/gi_alimaj.p persistent set vhAlimaj.
    run getTokenInstance in vhAlimaj(mToken:JSessionId).

    for each cecrsai-tmp:
        vrRecno-sai = ?.
        run cecrgvalValEcrOdAchat in vhCecrgval(input-output table cecrsai-tmp   by-reference,
                                                input-output table cecrln-tmp    by-reference,
                                                input-output table cecrlnana-tmp by-reference,
                                                input-output table aecrdtva-tmp  by-reference,
                                                input-output table ttDelettrage  by-reference,
                                                cecrsai-tmp.soc-cd,
                                                cecrsai-tmp.etab-cd,
                                                input-output vrRecno-sai,
                                                rowid(cecrsai-tmp),
                                                ?,
                                                false,
                                                cecrsai-tmp.jou-cd,
                                                cecrsai-tmp.prd-cd,
                                                cecrsai-tmp.prd-num,
                                                cecrsai-tmp.piece-int,
                                                0,
                                                0,
                                                "").
        for first cecrsai no-lock
            where rowid(cecrsai) = vrRecno-sai:
            find first ttPiece 
                 where ttPiece.cRwd = string(rowid(cecrsai-tmp)) no-error.
            if available ttPiece and ttPiece.UneSeuleLigne           //On ne trace pas une pièce avec une seule ligne à zéro 
            then do:
                 find current cecrsai exclusive-lock.
                 assign
                     cecrsai.dadoss = today
                     cecrsai.situ   = true
                 .
            end.
            else run majTraceCompta in vhAlimaj(cecrsai.soc-cd, 
                                                'compta', 
                                                'cecrsai', 
                                                substitute("&1&2&3&4&5&6&7", string(cecrsai.soc-cd, '>>>>9'),
                                                                             string(cecrsai.etab-cd, '>>>>9'),
                                                                             string(cecrsai.jou-cd, 'x(5)'),
                                                                             string(cecrsai.prd-cd, '>>9'),
                                                                             string(cecrsai.prd-num, '>>>9'),
                                                                             string(cecrsai.piece-int, '>>>>>>>>9'),
                                                                             string(0, ">>>>>9")),
                                                cecrsai.dacompta,
                                                ietab.gest-cle,
                                                string(cecrsai.etab-cd)).
        end.
        delete cecrsai-tmp.
    end.

end procedure.

procedure creation-cbap private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab      for ietab.
    define parameter buffer cecrln-tmp for cecrln-tmp.
    define input parameter pdMtRglt as decimal no-undo.

    define variable viManuInt as int64 no-undo.
    define buffer csscptcol for csscptcol.
    define buffer cbap      for cbap.

    if pdMtRglt = 0 then return.

    find first csscptcol no-lock
         where csscptcol.soc-cd     = giCodeSociete
           and csscptcol.etab-cd    = giMandatASolder
           and csscptcol.coll-cle   = cecrln-tmp.coll-cle
           and csscptcol.facturable = true no-error.
    find last cbap no-lock
        where cbap.soc-cd   = giCodeSociete
          and cbap.etab-cd  = giMandatASolder  
          and cbap.manu-int >= 0 no-error.
    viManuInt = if available cbap then cbap.manu-int + 1 else 1.
    create cbap.
    assign
        cbap.soc-cd           = giCodeSociete
        cbap.etab-cd          = giMandatASolder 
        cbap.coll-cle         = cecrln-tmp.coll-cle
        cbap.sscoll-cle       = cecrln-tmp.sscoll-cle 
        cbap.cpt-cd           = cecrln-tmp.cpt-cd
        cbap.lib              = cecrln-tmp.lib
        cbap.sens             = false
        cbap.mt               = absolute(pdMtRglt)
        cbap.fg-statut        = true
        cbap.pourcentage      = 100
        cbap.regl-cd          = 300
        cbap.daech            = cecrln-tmp.dacompta
        cbap.paie             = false
        cbap.dev-cd           = ietab.dev-cd
        cbap.libtier-cd       = csscptcol.libtier-cd when available csscptcol
        cbap.analytique       = false
        cbap.manu-int         = viManuInt
        cbap.gest-cle         = ietab.gest-cle
        cbap.lib-ecr[1]       = cecrln-tmp.lib
        cbap.fg-ana100        = false
        cbap.taxe-cd          = 9
        cbap.mttva-dev        = 0
        cbap.tiers-sscoll-cle = ""
        cbap.tiers-cpt-cd     = ""
        cbap.type-reg         = 0
        cbap.ref-num          = cecrln-tmp.ref-num
        cbap.mtdev            = cbap.mt 
    .
end procedure.
 