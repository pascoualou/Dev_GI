/*------------------------------------------------------------------------
File        : adeeclat.i
Purpose     : PEclatement des encaissements
Author(s)   : CC - 2000/02/15, Kantena - 2018/01/11
Notes       : vient de cadb/src/batch/adeeclat.i
01  21/03/2000  CC    Calcul du deja encaisse faux
02  27/06/2000  CC    Prise en compte parametre cabinet 0500/01024
03  10/07/2000  CC    Probleme sur les priorites
04  12/07/2000  CC    Fiche 0700/0060 + 4852
05  23/10/2000  PS    modif pour journal ODT
06  09/11/2000  PS    ajout du chemein rprunadb (recup de données)
07  22/11/2000  MP    Fiche 1100/0991 pas de ventilation sur ODT
08  24/01/2001  CC    Eclatement pour les quittancements manuels OD
09  28/08/2001  CC    Optimisation (merci PROFILER)
10  10/01/2002  CC    Optimisation + passage des arrondis sur 2 decimales
11  16/01/2002  CC    LAFORET
12  0405/0320   DM    montant aligtva.mttva à diviser par 100
13  27/06/2005  OF    0605/0102 Pouvoir lancer dans Utilitaires INS
14  20/02/2006  OF    0205/0031 Il faut garder en memoire le montant ayant servi au calcul des honoraires 
                      dans les adbtva et aligtva (ne pas les supprimer pour les recreer)
15  10/04/2006  DM    1205/0160 activation tache TVA en cours de declaration
16  22/09/2006  DM    0906/0145 Pb ventil si lettrage multiple
17  24/11/2006  DM    1106/0082 Prise en compte des OD/Avoirs
18  17/04/2008  DM    0607/0253 Ventilation manuelle encaissements
19  37/07/2008  JR    Migration GECOP: AccesDirect Lancement en automatique de l'éclatement des encaissements depuis la migration
20  12/08/2008  DM    0508/0177 Régularisation ventil encaissements
21  19/09/2008  DM    0608/0065 Mandat 5 chiffres
22  02/12/2008  DM    0408/0032 Hono par le quit
23  20/01/2009  DM    0109/0115: Régul : Pb annulation des ventils
24  13/02/2009  DM    0209/0071: Pv ventile HT+TVA montant 0.03 €
25  29/01/2009  DM    0109/0232: Eclater les AN de treso et d'ODT
26  20/02/2009  DM    0209/0181: Pb tva si signe inversé
27  13/03/2009  DM    0109/0115: Pb si relettrage avec ecr sur mois suivant
28  18/03/2009  JR    0309/0088
29  23/09/2009  DM    0208/0074 Gestion des avoirs en lettrage total
30  30/03/2010  DM    0310/0197 Pb prise en compte des annulations de réguls sur périodes suivantes
31  18/05/2010  DM    0510/0002 Réactiver les ecritures lettrées à blanc
32  03/01/2011  DM    ????/???? Desport regule
33  10/02/2011  DM    0211/0063 Taux de tva du bail par défaut
34  29/11/2011  DM    1111/0017 Ordre éclatement
35  16/12/2014  SY    1214/0150 Ajout test retour datetrt.r
36  12/02/2015  DM    0115/0246 BNP Lettrage total, encaissements au débit et au credit
37  17/02/2015  DM    0413/0088 TVA Manuelle
------------------------------------------------------------------------*/

function getTauxBail returns decimal private(pdeDefaut as decimal, piNocon as int64):
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------------------*/
    define buffer tache  for tache.
    define buffer sys_pr for sys_pr.
    for last tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = piNocon
          and tache.tptac = {&TYPETACHE-TVABail}
      , first sys_pr no-lock
        where sys_pr.tppar = "CDTVA"
          and sys_pr.cdpar = tache.ntges:
        return sys_pr.zone1.
    end.
    return pdeDefaut.
end function.

function getMouvement returns character private(piCodeSociete as integer, piEtablissement as integer):
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------------------*/
    define variable vcListe as character no-undo.
    define buffer itypemvt for itypemvt.
    for each itypemvt no-lock
        where itypemvt.soc-cd    = piCodeSociete
          and itypemvt.etab-cd   = piEtablissement
          and itypemvt.natjou-cd = 9
          and (itypemvt.typenat-cd = 50 or itypemvt.typenat-cd = 51 or itypemvt.type-cle = "ODT"):
        vcListe = vcListe + "," + itypemvt.type-cle.
    end.
    return trim(vcListe, ",").
end function.

procedure Rec_enc:
/*-----------------------------------------------------------------------------
Purpose:
Notes:
-----------------------------------------------------------------------------*/
    // todo  rechercher RpRunTmp RpRunBat
    define variable RpRunTmp as character  no-undo.
    define variable vcListeMouvement       as character no-undo. /* DM 0208/0074 */
    define variable vdeMontantTTC          as decimal   no-undo.
    define variable vdeMontantRest         as decimal   no-undo.
    define variable vdeMontantReste        as decimal   no-undo.
    define variable vdaDebutPeriode        as date      no-undo.
    define variable vlRegul                as logical   no-undo. /* DM 0508/0177 */
    define variable vdaProchainTraitement  as date      no-undo. /* DM 0508/0177 */
    define variable vcProchainTraitement   as character no-undo. /* DM 0508/0177 */
    define variable vdaDebutTraitement     as date      no-undo. /* DM 0508/0177 */
    define variable vdaFinTraitement       as date      no-undo. /* DM 0508/0177 */
    define variable viPeriodeTrt           as integer   no-undo. /* DM 0508/0177 */
    define variable viPeriodeProchainTt    as integer   no-undo. /* DM 0508/0177 */
    define variable vdeMtTTC               as decimal   no-undo. /* DM 0209/0071 */
    define variable vdeTauxBail            as decimal   no-undo. /* DM 0211/0063 */
    define variable vlRecetteConnue        as logical   no-undo.
    define variable viMandat               as integer   no-undo.
    define variable vdeReste               as decimal   no-undo.
    define variable vdeMontantTVA          as decimal   no-undo.
    define variable vcCodeTVA              as character no-undo.
    define variable vcListeJournal         as character no-undo.
    define variable vcListeJournalOD       as character no-undo.
    define variable vcListeJournalAN       as character no-undo.
    define variable vdeTauxOld             as decimal   no-undo.
    define variable vdeTresorerieADeclarer as decimal   no-undo.
    define variable vdeDeclaration         as decimal   no-undo.
    define variable vdaFinPeriode          as date      no-undo. 
    define variable viNumeroInterne        as integer   no-undo.

    define buffer aFamqtOrd        for aFamqtOrd.
    define buffer cecrln-buf       for cecrln.
    define buffer bcecrln          for cecrln.   /* DM 0109/0115 */
    define buffer cecrln-bufreste  for cecrln.   /* 0310/0197 */
    define buffer cecrln-Val       for cecrln.
    define buffer aecrdtva-buf     for aecrdtva.
    define buffer vb2adbtva       for adbtva.
    define buffer vbAdbtva         for adbtva.
    define buffer adbtva           for adbtva.
    define buffer vb2adbtvareste  for adbtva.
    define buffer aligtva          for aligtva.
    define buffer aligtva-bufreste for aligtva.
    define buffer rubqt            for rubqt.
    define buffer aecrdtva         for aecrdtva.
    define buffer ccptcol          for ccptcol.
    define buffer csscptcol        for csscptcol.
    define buffer iprd             for iprd.
    define buffer ijou             for ijou.
    define buffer itypemvt         for itypemvt.

    /**  RECHERCHE DU COMPTE FACTURABLE  sscoll-cpt = '4112'  **/
    {&_proparse_ prolint-nowarn(allfinds)}
    find ccptcol no-lock  // pas first dans ce cas
        where ccptcol.soc-cd = giCodesoc
          and ccptcol.tprole = {&Role_loc} no-error.
    if not available ccptcol then do:
        if ambiguous ccptcol
        then mError:createError({&error}, substitute("Plusieurs regroupements locataire (L) pour la société &1", giCodesoc)).
        else mError:createError({&error}, substitute("Pas de regroupement locataire (L) pour la société &1", giCodesoc)).
        return.
    end.

    find first csscptcol no-lock
        where csscptcol.soc-cd     = ccptcol.soc-cd
          and csscptcol.coll-cle   = ccptcol.coll-cle
          and csscptcol.etab-cd    = giEtablissement
          and csscptcol.facturable = true no-error.
    if not available csscptcol then do:
        mError:createError({&error}, substitute("Pas de collectifs locataire (L) pour le mandat ", giEtablissement)).
        return.
    end.

    if search (RpRunTmp + "AccesDirect/AccesDirect.01") <> ?
    then run readPeriodeFromFile(RpRunTmp, giCodesoc, giEtablissement, gdaDeclaration, output gdaDebutPeriode, output vdaFinPeriode).
    else do:
        &IF DEFINED(Utilitaire) &THEN
            vdaDebutPeriode = gdaDeclaration.
        &ELSE
            vdaDebutPeriode = today.
        &ENDIF
        run calcul-periode(giCodesoc, giEtablissement, vdaDebutPeriode, output gdaDebutPeriode, output vdaFinPeriode).
    end.
    /* DM 0508/0177 Date de prochain traitement */
    run datetrt(giEtablissement, gdaDeclaration, output vcProchainTraitement).  // procedure dans datetrt.i
    if mError:erreur() then return.

    assign
        vdaDebutTraitement = date(entry(1, vcProchainTraitement, chr(9)))
        vdaFinTraitement   = date(entry(2, vcProchainTraitement, chr(9)))
        viPeriodeTrt       = integer(entry(3, vcProchainTraitement, chr(9)))
    .
    find first iprd no-lock
        where iprd.soc-cd   =  giCodeSoc
          and iprd.etab-cd  =  giEtablissement
          and iprd.dadebprd <= gdaDeclaration
          and iprd.dafinprd >= gdaDeclaration no-error.
    if not available iprd then return.

    run getJournauxOdtOdAn(output vcListeJournal, output vcListeJournalOD, output vcListeJournalAN).
    vcListeMouvement = getMouvement(GiCodeSoc, giEtablissement).
    if (giPreprocesseurEclat = 0  and (glTmp-cron = false or gcCompte > ""))
    or (giPreprocesseurEclat <> 0 and gcCompte > "") then run lettrage(csscptcol.sscoll-cle).

boucleCsscpt:
    for each csscpt no-lock
        where csscpt.soc-cd   = giCodeSoc
          and csscpt.etab-cd  = giEtablissement
          and csscpt.coll-cle = ccptcol.coll-cle
          and (if gcCompte > "" then csscpt.cpt-cd = gcCompte else true):
        /* DM 0211/0063 Taux de tva du bail */
        vdeTauxBail = getTauxBail(gdeTauxDefaut, integer(string(giEtablissement) + csscpt.cpt-cd)).
        if can-find(first csscptcol no-lock
            where csscptcol.soc-cd = giCodeSoc
              and csscptcol.etab-cd = giEtablissement
              and csscptcol.sscoll-cle = csscpt.sscoll-cle
              and csscptcol.coll-cle = ccptcol.coll-cle
              and not(csscptcol.facturable or csscptcol.douteux or csscptcol.sscoll-cle = "LF")) then next boucleCsscpt.

        /* DM 0607/0253 Test si compte verrouillé en saisie (L/LF) - M = tester ce compte */
        // todo PhM - nécessite une explication!  à priori à ne pas faire.
        run batch/blocecla.p("M", giCodesoc, string(giEtablissement), csscpt.sscoll-cle, csscpt.cpt-cd, "ECLATA", "").
        if return-value = "FALSE" then next boucleCsscpt.

        run extractionReglementReactive(giCodeSoc, giEtablissement, csscpt.sscoll-cle, csscpt.cpt-cd, vdaFinPeriode, vcListeMouvement, vcListeJournalOD, vcListeJournalAN).
        /* DM 0109/0115 13/03/09 REINITIALISATION : Il faut réinitialiser les ventilations avant de faire l'éclatement */
        run reinitialisationVentilation(giCodeSoc, giEtablissement, csscpt.sscoll-cle, csscpt.cpt-cd, iprd.prd-cd, iprd.prd-num, iprd.dafinprd, vdaDebutTraitement, vdaFinTraitement, viPeriodeTrt, input-output vdaProchainTraitement).
        /** DM 1205/0160 Si la tache est activée en cours de déclaration, rattacher adbtva au nouveau type de declaration (type-decla) **/
        if giTypeDeclaration >= 1 and giTypeDeclaration <= 5
        then run ratachementAdbtva(giCodeSoc, giEtablissement, giTypeDeclaration, csscpt.sscoll-cle, csscpt.cpt-cd, iprd.prd-cd, iprd.prd-num). 

        /* REGLEMENTS                                                             ***/
boucleCecrln:
        for each cecrln no-lock
            where cecrln.soc-cd     = giCodeSoc
              and cecrln.etab-cd    = giEtablissement
              and cecrln.sscoll-cle = csscpt.sscoll-cle
              and cecrln.cpt-cd     = csscpt.cpt-cd
              and cecrln.prd-cd     = iprd.prd-cd
              &IF DEFINED(Utilitaire) = 0 &THEN
              and cecrln.fg-reac    = true
              &ENDIF
              and cecrln.prd-num    = iprd.prd-num:
            find first ijou no-lock
                where ijou.soc-cd  = cecrln.soc-cd
                  and ijou.etab-cd = cecrln.mandat-cd
                  and ijou.jou-cd  = cecrln.jou-cd no-error.
            {&_proparse_ prolint-nowarn(release)}
            release itypemvt.
            if available ijou
            then find first itypemvt no-lock
                where itypemvt.soc-cd    = cecrln.soc-cd
                  and itypemvt.etab-cd   = cecrln.mandat-cd
                  and itypemvt.natjou-cd = ijou.natjou-cd
                  and itypemvt.type-cle  = cecrln.type-cle no-error.
            if not available ijou
            or (ijou.natjou-gi <> 46
               and not(cecrln.type-cle = "ODT" and ijou.natjou-cd = 9) /* DM 0109/0232 Passer sur les AN d'ODT et AN de tréso */
               and not(available itypemvt and (itypemvt.typenat-cd = 50 or itypemvt.typenat-cd = 51) and ijou.natjou-cd = 9) /* AN de tréso */
               and not can-find(first ilibnatjou no-lock
                                where ilibnatjou.soc-cd = ijou.soc-cd
                                  and ilibnatjou.natjou-cd = ijou.natjou-cd
                                  and ilibnatjou.treso = true)) then next boucleCecrln.

            assign
                vlRegul               = false            /* DM 0508/0177 */
                vdaProchainTraitement = gdaDeclaration   /* DM 0508/0177 */
                viPeriodeProchainTt   = giNumeroPeriode  /* DM 0508/0177 */
            .
            for first adbtva no-lock
                where adbtva.soc-cd     = cecrln.soc-cd
                  and adbtva.etab-cd    = cecrln.etab-cd
                  and adbtva.jou-cd     = cecrln.jou-cd
                  and adbtva.prd-cd     = cecrln.prd-cd
                  and adbtva.prd-num    = cecrln.prd-num
                  and adbtva.piece-int  = cecrln.piece-int
                  and adbtva.lig        = cecrln.lig
                  and adbtva.date_decla <= vdaFinTraitement:
                vlRegul = iprd.dafinprd <> vdaFinTraitement /* c'est une regul, elle ne sera pas sur le mois de l'encaissement */
                        or ijou.natjou-gi = 93. /* Les ventilations sur les tréso reportées en ANC sont des régules */
                if vlRegul then assign
                    vdaProchainTraitement    = vdaFinTraitement
                    viPeriodeProchainTt = viPeriodeTrt
                .
            end.
            assign
                vlRecetteConnue   = false
                vdeTresorerieADeclarer = 0
                vdeDeclaration  = 0
                vcCodeTVA = "0"
            .
            if can-find(first cecrln-buf
                where cecrln-buf.soc-cd = giCodeSoc
                  and cecrln-buf.etab-cd    = giEtablissement
                  and cecrln-buf.sscoll-cle = cecrln.sscoll-cle
                  and cecrln-buf.cpt-cd     = cecrln.cpt-cd
                  and cecrln-buf.lettre     = cecrln.lettre
                  and (cecrln-buf.jou-cd    = gcJournalQuittancement or lookup(cecrln-buf.jou-cd, vcListeJournalOD) > 0
                   or (lookup(cecrln-buf.jou-cd,vcListeJournalAN) > 0 and lookup(cecrln-buf.type-cle, vcListeMouvement) = 0)) /* DM 0208/0074 Pas les AN de tréso */
                  and cecrln-buf.dacompta  >= gdaDebutPeriode
                  and cecrln-buf.dacompta  <= vdaFinPeriode) then vlRecetteConnue = true.
            vdeTresorerieADeclarer = if cecrln.sens then - cecrln.mt else cecrln.mt.  /* montant de la tréso à déclarer */
            /* DM 0607/0253 Prise en compte des ventils non supprimées */
            for each adbtva no-lock
                where adbtva.soc-cd = cecrln.soc-cd
                  and adbtva.etab-cd = cecrln.etab-cd
                  and adbtva.jou-cd = cecrln.jou-cd
                  and adbtva.prd-cd = cecrln.prd-cd
                  and adbtva.prd-num = cecrln.prd-num
                  and adbtva.piece-int = cecrln.piece-int
                  and adbtva.lig = cecrln.lig
                  and adbtva.date_decla <= vdaProchainTraitement:
                vdeTresorerieADeclarer = vdeTresorerieADeclarer - adbtva.mt.
            end.
            repeat while if cecrln.flag-lettre
                         then vdeTresorerieADeclarer <> 0
                         else (if not cecrln.sens then vdeTresorerieADeclarer > 0 else vdeTresorerieADeclarer < 0):
                for each cecrln-buf no-lock
                    where cecrln-buf.soc-cd     = giCodeSoc
                      and cecrln-buf.etab-cd    = giEtablissement
                      and cecrln-buf.sscoll-cle = cecrln.sscoll-cle
                      and cecrln-buf.cpt-cd     = cecrln.cpt-cd
                      and cecrln-buf.lettre     = cecrln.lettre
                      and cecrln-buf.dacompta  >= gdaDebutPeriode
                      and cecrln-buf.dacompta  <= vdaFinPeriode
                      and (cecrln-buf.jou-cd    = gcJournalQuittancement or lookup(cecrln-buf.jou-cd, vcListeJournalOD) > 0
                       or (lookup(cecrln-buf.jou-cd,vcListeJournalAN) > 0 and lookup(cecrln-buf.type-cle,vcListeMouvement) = 0)) /* DM 0208/0074 Pas les AN de tréso */
                    by (if cecrln-buf.flag-lettre then (if cecrln.sens = cecrln-buf.sens then 1 else 2) else 1) /* DM 0208/0074 Faire passer les avoirs en 1ers */
                    by cecrln-buf.dacompta:
    
                    vdeDeclaration = (if cecrln-buf.sens then cecrln-buf.mt else - cecrln-buf.mt). /* Montant de la quittance/avoirs/od */
                    /**  RECHERCHE DES ENCAISSEMENTS DEJA AFFECTES SUR LA RECETTE  **/
                    for each adbtva no-lock
                        where adbtva.soc-cd          = giCodesoc
                          and adbtva.etab-cd         = giEtablissement
                          and adbtva.ecrln-jou-cd    = cecrln-buf.jou-cd
                          and adbtva.ecrln-prd-cd    = cecrln-buf.prd-cd
                          and adbtva.ecrln-prd-num   = cecrln-buf.prd-num
                          and adbtva.ecrln-prd-cd    = cecrln-buf.prd-cd
                          and adbtva.ecrln-piece-int = cecrln-buf.piece-int
                          and adbtva.ecrln-lig       = cecrln-buf.lig
                          and adbtva.date_decla     <= vdaFinTraitement:
                        /* Cet encaissement est sur une periode suivante, son lettrage est modifié, la ventilation sera
                           annulée lors du passage sur cette période -> il ne faut donc pas prendre cette ventilation */
                        if can-find(first bcecrln no-lock
                                    where bcecrln.soc-cd    = adbtva.soc-cd
                                      and bcecrln.etab-cd   = adbtva.etab-cd
                                      and bcecrln.jou-cd    = adbtva.jou-cd
                                      and bcecrln.prd-cd    = adbtva.prd-cd
                                      and bcecrln.prd-num   = adbtva.prd-num
                                      and bcecrln.piece-int = adbtva.piece-int
                                      and bcecrln.lig       = adbtva.lig
                                      and bcecrln.dacompta > gdaDeclaration
                                      and bcecrln.fg-reac) then next.

                        vdeDeclaration = vdeDeclaration - adbtva.mt.
                    end.
                    if (if not cecrln.sens then vdeDeclaration > 0 and vdeTresorerieADeclarer > 0  else vdeDeclaration < 0 and vdeTresorerieADeclarer < 0)
                    or (cecrln.flag-lettre and (vdeTresorerieADeclarer <> 0
                                             or can-find(first aecrdtva no-lock
                                                 where aecrdtva.soc-cd   = cecrln-buf.soc-cd
                                                   and aecrdtva.etab-cd   = cecrln-buf.etab-cd
                                                   and aecrdtva.jou-cd    = cecrln-buf.jou-cd
                                                   and aecrdtva.prd-cd    = cecrln-buf.prd-cd
                                                   and aecrdtva.prd-num   = cecrln-buf.prd-num
                                                   and aecrdtva.piece-int = cecrln-buf.piece-int
                                                   and aecrdtva.lig       = cecrln-buf.lig))) /* DM 0208/0074 En lettrage total : Prise en compte des avoirs et facture à 0 avec rub + et rub -*/
                    then do:
                        find last vbAdbtva no-lock
                            where vbAdbtva.soc-cd  = giCodesoc
                              and vbAdbtva.etab-cd = giEtablissement no-error.
                        viNumeroInterne = if available vbAdbtva then vbAdbtva.num-int + 1 else 1.
                        create adbtva.
                        assign
                            adbtva.usridcre       = mToken:cUser
                            adbtva.ihcre          = time
                            adbtva.dacre          = today
                            adbtva.soc-cd         = cecrln.soc-cd
                            adbtva.etab-cd        = cecrln.etab-cd
                            adbtva.num-int        = viNumeroInterne
                            adbtva.jou-cd         = cecrln.jou-cd
                            adbtva.prd-cd         = cecrln.prd-cd
                            adbtva.prd-num        = cecrln.prd-num
                            adbtva.piece-int      = cecrln.piece-int
                            adbtva.lig            = cecrln.lig
                            adbtva.cpt-cd         = csscpt.cpt-cd
                            adbtva.dacompta       = cecrln.dacompta
                            adbtva.ecrln-jou-cd   = cecrln-buf.jou-cd
                            adbtva.sens           = cecrln.sens
                            adbtva.ecrln-prd-cd   = cecrln-buf.prd-cd
                            adbtva.ecrln-prd-num  = cecrln-buf.prd-num
                            adbtva.ecrln-piece-int= cecrln-buf.piece-int
                            adbtva.ecrln-lig      = cecrln-buf.lig
                            adbtva.mt             = if cecrln.flag-lettre
                                                    then if vdeTresorerieADeclarer >= 0 and vdeDeclaration >= 0
                                                    then minimum(vdeTresorerieADeclarer, vdeDeclaration)
                                                    else if vdeTresorerieADeclarer <= 0 and vdeDeclaration <= 0
                                                          then maximum(vdeTresorerieADeclarer, vdeDeclaration)
                                                          else minimum(vdeTresorerieADeclarer, vdeDeclaration) /* sens opposé */
                                                    else (if vdeTresorerieADeclarer > 0 then if vdeTresorerieADeclarer > vdeDeclaration
                                                          then vdeDeclaration else vdeTresorerieADeclarer
                                                          else if vdeTresorerieADeclarer < vdeDeclaration
                                                          then vdeDeclaration else vdeTresorerieADeclarer)
                            adbtva.mtht          = 0
                            adbtva.mttva         = 0
                            adbtva.date-quit     = cecrln-buf.dacompta
                            adbtva.periode       = giNumeroPeriode
                            adbtva.date_decla    = gdaDeclaration
                            adbtva.let           = true
                            adbtva.type-decla    = giTypeDeclaration
                        .
                        /* DM 0508/0177 Affectation de la date de prochain traitement si regul */
                        if vlRegul then assign
                            adbtva.lib-trt    = "AR"     /* -> A Regulariser */
                            adbtva.date-trt   = vdaProchainTraitement /* date de prochain traitement */
                            adbtva.date_decla = vdaProchainTraitement
                            adbtva.periode    = viPeriodeProchainTt
                        .
                        vdeTresorerieADeclarer = vdeTresorerieADeclarer - adbtva.mt.
                    end.
                end.
                leave.
            end.
            /*****   RECETTE NON CONNUE  *****/
            if vlRecetteConnue = false or (if not cecrln.sens then vdeTresorerieADeclarer > 0 else vdeTresorerieADeclarer < 0)
            then do:
                vdeTauxOld = vdeTauxBail.
                if cecrln.dacompta < 04/01/2000 then vdeTauxBail = gdeTauxAvant.
                find last vbAdbtva no-lock
                    where vbAdbtva.soc-cd  = giCodesoc
                      and vbAdbtva.etab-cd = giEtablissement no-error.
                viNumeroInterne = if available vbAdbtva then vbAdbtva.num-int + 1 else 1.
                create vb2adbtva.
                assign
                    vb2adbtva.usridcre   = mToken:cUser
                    vb2adbtva.ihcre      = time
                    vb2adbtva.dacre      = today
                    vb2adbtva.soc-cd     = cecrln.soc-cd
                    vb2adbtva.etab-cd    = cecrln.etab-cd
                    vb2adbtva.num-int    = viNumeroInterne
                    vb2adbtva.jou-cd     = cecrln.jou-cd
                    vb2adbtva.prd-cd     = cecrln.prd-cd
                    vb2adbtva.prd-num    = cecrln.prd-num
                    vb2adbtva.piece-int  = cecrln.piece-int
                    vb2adbtva.lig        = cecrln.lig
                    vb2adbtva.cpt-cd     = csscpt.cpt-cd
                    vb2adbtva.dacompta   = cecrln.dacompta
                    vb2adbtva.sens       = cecrln.sens
                    vb2adbtva.mt         = (if vlRecetteConnue = false then (if cecrln.sens then - cecrln.mt else cecrln.mt) else vdeTresorerieADeclarer)
                    vb2adbtva.mtht       = (if vlRecetteConnue = false then (if cecrln.sens then - cecrln.mt else cecrln.mt) else vdeTresorerieADeclarer) / ((100 + vdeTauxBail) / 100)
                    vb2adbtva.mttva      = (if vlRecetteConnue = false then (if cecrln.sens then - cecrln.mt else cecrln.mt) else vdeTresorerieADeclarer) - vb2adbtva.mtht
                    vb2adbtva.taux       = vdeTauxBail
                    vb2adbtva.periode    = giNumeroPeriode
                    vb2adbtva.date_decla = gdaDeclaration
                    vb2adbtva.date-quit  = cecrln.dacompta
                    vb2adbtva.let        = false
                    vb2adbtva.type-decla = giTypeDeclaration
                .
                /* DM 0508/0177 Affectation de la date de prochain traitement si regul */
                if vlRegul then assign
                    vb2adbtva.lib-trt    = "AR"      /* -> A Regulariser */
                    vb2adbtva.date-trt   = vdaProchainTraitement  /* date de prochain traitement */
                    vb2adbtva.date_decla = vdaProchainTraitement
                    vb2adbtva.periode    = viPeriodeProchainTt
                .
                assign
                    vcCodeTVA            = isbaitva(integer(string(giEtablissement, "99999") + cecrln.cpt-cd))
                    /** report d'arrondi suite à TVA **/
                    vb2adbtva.mtht = vb2adbtva.mtht + (vb2adbtva.mt - (vb2adbtva.mtht + vb2adbtva.mttva))
                    vdeTauxBail       = vdeTauxOld
                .
                if vcCodeTVA = "1" then assign
                    vb2adbtva.mtht  = vb2adbtva.mt
                    vb2adbtva.mttva = 0
                    vb2adbtva.taux  = 0
                .
            end.
            /***  CALCUL DE LA PART D'ENCAISSEMENT SUR UNE RECETTE - CALCUL DE PRORATA ***/
            {&_proparse_ prolint-nowarn(sortaccess)}
            for each adbtva no-lock
                where adbtva.soc-cd    = cecrln.soc-cd
                  and adbtva.etab-cd   = cecrln.etab-cd
                  and adbtva.jou-cd    = cecrln.jou-cd
                  and adbtva.prd-cd    = cecrln.prd-cd
                  and adbtva.prd-num   = cecrln.prd-num
                  and adbtva.piece-int = cecrln.piece-int
                  and adbtva.lig       = cecrln.lig
                  and adbtva.reactiv   = false
                  and adbtva.date_decla >= gdaDeclaration
                  and adbtva.date_decla <= vdaProchainTraitement /* ventiler aussi les adbtva tva créés sur le prochain mois de traitement */
                  and not can-find(first aligtva no-lock
                                   where aligtva.soc-cd = adbtva.soc-cd
                                     and aligtva.etab-cd = adbtva.etab-cd
                                      and aligtva.num-int = adbtva.num-int)  /**Ajout OF le 20/02/06**/
                by adbtva.num-int descending:
                find first cecrln-buf no-lock
                    where cecrln-buf.soc-cd    = giCodesoc
                      and cecrln-buf.etab-cd   = giEtablissement
                      and cecrln-buf.jou-cd    = adbtva.ecrln-jou-cd
                      and cecrln-buf.piece-int = adbtva.ecrln-piece-int
                      and cecrln-buf.prd-cd    = adbtva.ecrln-prd-cd
                      and cecrln-buf.prd-num   = adbtva.ecrln-prd-num
                      and cecrln-buf.lig       = adbtva.ecrln-lig no-error.
                if available cecrln-buf then do:           /**   RECETTE CONNUE  **/
                    if adbtva.mt = cecrln-buf.mt * (if cecrln-buf.sens then 1 else -1) /* DM 1106/0082 */
                    then for each {&Detail} no-lock
                        where {&Detail}.soc-cd    = giCodesoc
                          and {&Detail}.etab-cd   = giEtablissement
                          and {&Detail}.jou-cd    = cecrln-buf.jou-cd
                          and {&Detail}.piece-int = cecrln-buf.piece-int
                          and {&Detail}.prd-cd    = cecrln-buf.prd-cd
                          and {&Detail}.prd-num   = cecrln-buf.prd-num
                          and {&Detail}.lig       = cecrln-buf.lig:
                        create aligtva.
                        assign
                            aligtva.soc-cd  = giCodesoc
                            aligtva.etab-cd = giEtablissement
                            aligtva.num-int = adbtva.num-int
                            aligtva.cdrub   = {&Detail}.cdrub
                            aligtva.cdlib   = {&Detail}.cdlib
                            aligtva.cat-cd  = {&Detail}.cat-cd
                            aligtva.periode = adbtva.periode
                            aligtva.taux    = (if {&Detail}.cat-cd = 3
                                               or lookup(string({&Detail}.cdrub), {&ListeRubQtTVA-Manu}) > 0 /* DM 0413/0088 */
                                               then 0 else {&Detail}.taux).
                        if aligtva.cat-cd <> 4
                        then do:
                            assign
                                aligtva.mttva = 0
                                aligtva.mtht  = ({&Detail}.mtht)
                            .
                            if {&Detail}.mttva <> 0 and aligtva.taux <> 0  /*** pièces OD  008 ***/
                            then aligtva.mttva = aligtva.mtht * (aligtva.taux / 100).
                        end.
                        else assign
                            aligtva.mttva = {&Detail}.mttva
                            aligtva.mtht  = 0
                        .
                    end.
                    else do:                    /** Calcul du reste par rubrique **/
                        empty temp-table ttResteRubrique.
boucleAdbtva:
                        for each vb2adbtvareste no-lock
                            where vb2adbtvareste.soc-cd          = giCodesoc
                              and vb2adbtvareste.etab-cd         = giEtablissement
                              and vb2adbtvareste.ecrln-jou-cd    = adbtva.ecrln-jou-cd
                              and vb2adbtvareste.ecrln-piece-int = adbtva.ecrln-piece-int
                              and vb2adbtvareste.ecrln-prd-cd    = adbtva.ecrln-prd-cd
                              and vb2adbtvareste.ecrln-prd-num   = adbtva.ecrln-prd-num
                              and vb2adbtvareste.ecrln-lig       = adbtva.ecrln-lig
                              and rowid(vb2adbtvareste) <> rowid(adbtva)
                              and vb2adbtvareste.date_decla <= vdaFinTraitement:
                              /* DM 0310/0197 29/03/2010  */
                            find first cecrln-bufreste no-lock
                                where cecrln-bufreste.soc-cd    = vb2adbtvareste.soc-cd
                                  and cecrln-bufreste.etab-cd   = vb2adbtvareste.etab-cd
                                  and cecrln-bufreste.jou-cd    = vb2adbtvareste.jou-cd
                                  and cecrln-bufreste.prd-cd    = vb2adbtvareste.prd-cd
                                  and cecrln-bufreste.prd-num   = vb2adbtvareste.prd-num
                                  and cecrln-bufreste.piece-int = vb2adbtvareste.piece-int
                                  and cecrln-bufreste.lig       = vb2adbtvareste.lig no-error.
                            /* Cet encaissement est sur une periode suivante, son lettrage est modifié, la ventilation sera
                               annulée lors du passage sur cette période -> il ne faut donc pas prendre cette ventilation */
                            if available cecrln-bufreste
                            and cecrln-bufreste.dacompta > gdaDeclaration
                            and cecrln-bufreste.fg-reac = true then next boucleAdbtva.
    
                            /* FIN DM 0310/0197 */
                            for each aligtva-bufreste no-lock
                                where aligtva-bufreste.soc-cd = vb2adbtvareste.soc-cd
                                  and aligtva-bufreste.etab-cd = vb2adbtvareste.etab-cd
                                  and aligtva-bufreste.num-int = vb2adbtvareste.num-int:
                                find first ttResteRubrique
                                    where ttResteRubrique.cdrub = aligtva-bufreste.cdrub
                                      and ttResteRubrique.cdlib = aligtva-bufreste.cdlib no-error.
                                if not available ttResteRubrique then do:
                                    create ttResteRubrique.
                                    assign
                                        ttResteRubrique.cdrub = aligtva-bufreste.cdrub
                                        ttResteRubrique.cdlib = aligtva-bufreste.cdlib
                                    .
                                end.
                                ttResteRubrique.mt = ttResteRubrique.mt + (if aligtva-bufreste.cat-cd <> 4 then aligtva-bufreste.mtht else aligtva-bufreste.mttva).
                            end.
                        end.
                        viMandat = -1.
                        /** Recherche de règles sur le mandat **/
                        if cecrln.sscoll-cle <> "LF"  then do: /* DM 0408/0032 Rajout du IF, le LF est ventilé sur la famille 8 qui n'existe pas dans afamqtord */
                            find first aFamqtOrd no-lock
                                where aFamqtOrd.soc-cd  = giCodesoc
                                  and aFamqtOrd.etab-cd = cecrln.etab-cd no-error.
                            if available aFamqtOrd
                            then viMandat = cecrln.etab-cd.
                            else for first aFamqtOrd no-lock                            /** Recherche de règles sur le cabinet **/
                                where aFamqtOrd.soc-cd  = giCodesoc
                                  and aFamqtOrd.etab-cd = 0:
                                viMandat = 0.
                            end.
                        end.
                        if cecrln.flag-lettre
                        and can-find(first pclie no-lock where pclie.tppar = "NVCRG" and pclie.zon01 = "00001") /* DM ????/???? Pour Desport il faut passer par l'ordre des rubriques paramétrées */
                        then viMandat = -1. /* DM 0208/0074 Lettré total, ordre des rubriques pas nécessaire*/
    
                        /** Recherche de règles éventuelles pour l'éclatement **/
                        if viMandat >= 0 then do:
                            assign
                                vdeMontantTTC           = 0
                                vdeMontantReste = adbtva.mt
                            .
                            {&_proparse_ prolint-nowarn(sortaccess)}
                            for each aFamqtOrd no-lock
                                where aFamqtOrd.soc-cd  = giCodesoc
    /**  CC 0500/01024 **/        and aFamqtOrd.etab-cd = (if viMandat = 0 then 0 else cecrln.etab-cd)
                              , each aecrdtva no-lock
                                where aecrdtva.soc-cd    = giCodesoc
                                  and aecrdtva.etab-cd   = giEtablissement
                                  and aecrdtva.jou-cd    = cecrln-buf.jou-cd
                                  and aecrdtva.piece-int = cecrln-buf.piece-int
                                  and aecrdtva.prd-cd    = cecrln-buf.prd-cd
                                  and aecrdtva.prd-num   = cecrln-buf.prd-num
                                  and aecrdtva.lig       = cecrln-buf.lig
                                  and (aecrdtva.cat-cd < 4 or lookup(string(aecrdtva.cdrub), {&ListeRubQtTVA-Manu}) > 0)
                              , each RubQt no-lock
                                where aecrdtva.CdRub = RubQt.CdRub
                                  and aecrdtva.CdLib = RubQt.CdLib
                                  and RubQt.cdFam    = aFamqtOrd.cdFam
                                  and RubQt.cdsfa    = aFamqtOrd.cdsfa
                                break by (if lookup(string(aecrdtva.cdrub), {&ListeRubQtTVA-Manu}) = 0
                                          then (if aecrdtva.mtht < 0  then aecrdtva.mtht  else aFamqtOrd.OrdNum)
                                          else (if aecrdtva.mttva < 0 then aecrdtva.mttva else aFamqtOrd.OrdNum))
                                      by aFamqtOrd.OrdNum:
                                create aligtva.
                                assign
                                    vdeReste = (if lookup(string(aecrdtva.cdrub), {&ListeRubQtTVA-Manu}) > 0 then aecrdtva.mttva else aecrdtva.mtht)
                                    aligtva.soc-cd  = giCodesoc
                                    aligtva.etab-cd = giEtablissement
                                    aligtva.num-int = adbtva.num-int
                                    aligtva.cdrub   = aecrdtva.cdrub
                                    aligtva.cdlib   = aecrdtva.cdlib
                                    aligtva.cat-cd  = aecrdtva.cat-cd
                                    aligtva.periode = adbtva.periode
                                    aligtva.taux    = (if aecrdtva.cat-cd = 3
                                                       or lookup(string(aecrdtva.cdrub), {&ListeRubQtTVA-Manu}) > 0 /* DM 0413/0088 */
                                                       then 0 else aecrdtva.taux)
                                .
                                find first ttResteRubrique
                                    where ttResteRubrique.cdrub = RubQt.CdRub
                                      and ttResteRubrique.cdlib = RubQt.CdLib no-error.
                                vdeReste = round((if available ttResteRubrique then vdeReste - ttResteRubrique.mt else vdeReste) * (1 + (aligtva.taux / 100)), 2).
                                if vdeMontantReste <> 0 then do:
                                    assign
                                        vdeMontantTVA = 0
                                        vdeMtTTC = (if vdeMontantReste > 0 then (if vdeMontantReste >= vdeReste then vdeReste else vdeMontantReste)
                                                                        else (if vdeMontantReste <= vdeReste and vdeReste <= 0
                                                                              then vdeReste else vdeMontantReste))
                                    .
                                    if lookup(string(aligtva.cdrub), {&ListeRubQtTVA-Manu}) = 0 /* DM 0413/0088 */
                                    then aligtva.mtht  = vdeMtTTC / (1 + aligtva.taux / 100).
                                    else aligtva.mttva = vdeMtTTC / (1 + aligtva.taux / 100).
                                    vdeMontantTVA = round((aligtva.mtht * aligtva.taux) / 100, 2).
                                    if vdeMtTTC = aligtva.mtht + aligtva.mttva then vdeMontantTVA = 0.
                                    /** Cacul pour le report d'arrondi **/
                                    vdeMontantTTC = vdeMontantTTC + aligtva.mtht + vdeMontantTVA + aligtva.mttva. /* DM 0413/0088 */
                                    if aligtva.taux <> 0
                                    and aligtva.mtht <> 0 /* DM 1106/0082 */
                                    and lookup(string(aligtva.cdrub), {&ListeRubQtTVA-Manu}) = 0 /* DM 0413/0088 */
                                    then do:
                                        /** Calcul du montant de TVA **/
                                        {&_proparse_ prolint-nowarn(nowait)}
                                        find first aligtva-bufreste exclusive-lock
                                            where aligtva-bufreste.soc-cd  = giCodesoc
                                              and aligtva-bufreste.etab-cd = giEtablissement
                                              and aligtva-bufreste.num-int = adbtva.num-int
                                              and aligtva-bufreste.cat-cd  = 4
                                              and aligtva-bufreste.taux    = aligtva.taux
                                              and lookup(string(aligtva-bufreste.cdrub), {&ListeRubQtTVA-Manu}) = 0 no-error.  /* DM 0413/0088 */
                                        if not available aligtva-bufreste then do:
                                            find first aecrdtva-buf no-lock
                                                where aecrdtva-buf.soc-cd  = giCodesoc
                                                  and aecrdtva-buf.etab-cd   = giEtablissement
                                                  and aecrdtva-buf.jou-cd    = cecrln-buf.jou-cd
                                                  and aecrdtva-buf.piece-int = cecrln-buf.piece-int
                                                  and aecrdtva-buf.prd-cd    = cecrln-buf.prd-cd
                                                  and aecrdtva-buf.prd-num   = cecrln-buf.prd-num
                                                  and aecrdtva-buf.lig       = cecrln-buf.lig
                                                  and aecrdtva-buf.taux      = aligtva.taux
                                                  and aecrdtva-buf.cat-cd    = 4
                                                  and lookup(string(aecrdtva-buf.cdrub), {&ListeRubQtTVA-Manu}) = 0 no-error.  /* DM 0413/0088 */
                                            if available aecrdtva-buf then do:
                                                create aligtva-bufreste.
                                                assign
                                                    aligtva-bufreste.soc-cd  = giCodesoc
                                                    aligtva-bufreste.etab-cd = giEtablissement
                                                    aligtva-bufreste.num-int = adbtva.num-int
                                                    aligtva-bufreste.cdrub   = aecrdtva-buf.cdrub
                                                    aligtva-bufreste.cdlib   = aecrdtva-buf.cdlib
                                                    aligtva-bufreste.cat-cd  = 4
                                                    aligtva-bufreste.periode = adbtva.periode
                                                    aligtva-bufreste.taux    = aligtva.taux
                                                .
                                            end.
                                        end.
                                        if available aligtva-bufreste
                                        then aligtva-bufreste.mttva = aligtva-bufreste.mttva + vdeMontantTVA.
                                        else aligtva.mttva = aligtva.mtht * (aligtva.taux / 100).
                                    end.
                                end.
                                else vdeMontantTVA = 0. /* DM 1106/0082 */
                                vdeMontantReste = vdeMontantReste
                                               - (aligtva.mtht + vdeMontantTVA + (if lookup(string(aligtva.cdrub), {&ListeRubQtTVA-Manu}) > 0 then aligtva.mttva else 0)). /* DM 0413/0088 */
                                /*** REPORT D'ARRONDI  **/
                                if last(aFamqtOrd.OrdNum) and vdeMontantTTC <> adbtva.mt then do:
                                    if lookup(string(aligtva.cdrub), {&ListeRubQtTVA-Manu}) = 0 /* DM 0413/0088 */
                                    then aligtva.mtht  = round(aligtva.mtht + (adbtva.mt - vdeMontantTTC), 2).
                                    else aligtva.mttva = round(aligtva.mtht + (adbtva.mt - vdeMontantTTC), 2).
                                end.
                                if aligtva.mtht = 0 and aligtva.mttva = 0 then delete aligtva.
                            end.
                        end.
                        else do:
                            /* DM 0115/0246  Ajout du IF. Si lettré total -> prorata qq soit le solde de la rubrique */
                            if not cecrln.flag-lettre then do:
                                if can-find(first ttResteRubrique) then do:
                                    vdeMontantRest = 0.
                                    for each ttResteRubrique: vdeMontantRest = vdeMontantRest + ttResteRubrique.mt. end.
                                    vdeMontantRest = (if cecrln-buf.sens then 1 else -1) * cecrln-buf.mt - vdeMontantRest.
                                end.
                                else vdeMontantRest = if cecrln-buf.sens then cecrln-buf.mt else - cecrln-buf.mt.
                            end.
                            else do:
                                empty temp-table ttResteRubrique.
                                vdeMontantRest = if cecrln-buf.sens then cecrln-buf.mt else - cecrln-buf.mt.
                            end.
                            /** Proratisation **/
                            assign
                                vdeMontantTTC           = 0
                                vdeMontantReste = cecrln.mt * (if not cecrln.sens then 1 else -1)
                            .
                            {&_proparse_ prolint-nowarn(sortaccess)}
                            for each {&Detail} no-lock
                                where {&Detail}.soc-cd    = giCodesoc
                                  and {&Detail}.etab-cd   = giEtablissement
                                  and {&Detail}.jou-cd    = cecrln-buf.jou-cd
                                  and {&Detail}.piece-int = cecrln-buf.piece-int
                                  and {&Detail}.prd-cd    = cecrln-buf.prd-cd
                                  and {&Detail}.prd-num   = cecrln-buf.prd-num
                                  and {&Detail}.lig       = cecrln-buf.lig
                                break by (if lookup(string({&Detail}.cdrub), {&ListeRubQtTVA-Manu}) = 0 then {&Detail}.mtht else {&Detail}.mttva):
                                create aligtva.
                                assign
                                    aligtva.soc-cd  = giCodesoc
                                    aligtva.etab-cd = giEtablissement
                                    aligtva.num-int = adbtva.num-int
                                    aligtva.cdrub   = {&Detail}.cdrub
                                    aligtva.cdlib   = {&Detail}.cdlib
                                    aligtva.cat-cd  = {&Detail}.cat-cd
                                    aligtva.periode = adbtva.periode
                                    aligtva.taux    = (if {&Detail}.cat-cd = 3
                                                       or lookup(string({&Detail}.cdrub), {&ListeRubQtTVA-Manu}) > 0 /* DM 0413/0088 */
                                                       then 0 else {&Detail}.taux).
                                find first ttResteRubrique
                                    where ttResteRubrique.Cdrub = aligtva.cdrub
                                      and ttResteRubrique.CdLib = aligtva.CdLib no-error.
                                if vdeMontantRest <> 0
                                then do:
                                    if aligtva.cat-cd <> 4 then do:
                                        assign
                                            aligtva.mttva = 0
                                            aligtva.mtht  = adbtva.mt * (if available ttResteRubrique then {&Detail}.mtht - ttResteRubrique.mt else {&Detail}.mtht) / vdeMontantRest
                                        .
                                        if {&Detail}.mttva <> 0 and aligtva.taux <> 0  /*** pièces OD  008 ***/
                                        then aligtva.mttva = aligtva.mtht * (aligtva.taux / 100).
                                    end.
                                    else assign
                                        aligtva.mttva = adbtva.mt * (if available ttResteRubrique then {&Detail}.mttva - ttResteRubrique.mt else {&Detail}.mttva) / vdeMontantRest
                                        aligtva.mtht  = 0
                                    .
                                end.
                                vdeMontantTTC = vdeMontantTTC + aligtva.mtht + aligtva.mttva.
                                /*** REPORT D'ARRONDI  **/
                                if vdeMontantTTC <> adbtva.mt
                                and last(if lookup(string({&Detail}.cdrub), {&ListeRubQtTVA-Manu}) = 0 then {&Detail}.mtht else {&Detail}.mttva)
                                then if lookup(string(aligtva.cdrub), {&ListeRubQtTVA-Manu}) = 0 /* DM 0413/0088 */
                                     then aligtva.mtht  = round(aligtva.mtht + (adbtva.mt - vdeMontantTTC), 2).
                                     else aligtva.mttva = round(aligtva.mttva + (adbtva.mt - vdeMontantTTC), 2).
                                if aligtva.mtht = 0 and aligtva.mttva = 0 then delete aligtva.
                            end.
                        end.
                    end.
                end.
                if adbtva.mt = 0 and adbtva.cmthon = ?
                and not can-find(first aligtva no-lock
                                 where aligtva.soc-cd = adbtva.soc-cd
                                   and aligtva.etab-cd = adbtva.etab-cd
                                   and aligtva.num-int = adbtva.num-int)
                then for first vb2adbtva exclusive-lock
                    where rowid(vb2adbtva) = rowid(adbtva):
                    delete vb2adbtva.
                end.
            end.
            for first cecrln-Val exclusive-lock
                where rowid(cecrln-Val) = rowid(cecrln):
                cecrln-Val.fg-reac = false.
            end.
        end.
        /* DM 0607/0253 Débloquer le compte */
        // todo PhM - nécessite une explication!  à priori à ne pas faire.
        run batch/blocecla.p("DU", giCodesoc, string(giEtablissement), csscpt.sscoll-cle, csscpt.cpt-cd, "ECLATA", "").
    end.
    output close.
end procedure.

procedure getJournauxOdtOdAn:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define output parameter pcListeODT as character no-undo.
    define output parameter pcListeOD  as character no-undo.
    define output parameter pcListeAN  as character no-undo.
    define buffer ijou       for ijou.
    define buffer ilibnatjou for ilibnatjou.

    /*** LE JOURNAL ODT EST COMME UN JOURANL DE TRESO ***/
    for each ijou no-lock
        where ijou.soc-cd  = giCodesoc
          and ijou.etab-cd = giEtablissement
          and (ijou.natjou-gi = 46 or can-find(first ilibnatjou no-lock
                                              where ilibnatjou.soc-cd    = ijou.soc-cd 
                                                and ilibnatjou.natjou-cd = ijou.natjou-cd
                                                and ilibnatjou.treso     = true)):
        pcListeODT = pcListeODT + "|" + ijou.jou-cd.
    end.
    for each ijou no-lock
        where ijou.soc-cd  = giCodesoc
          and ijou.etab-cd = giGeranceGlobale
          and (ijou.natjou-gi = 46 or can-find(first ilibnatjou no-lock
                                              where ijou.soc-cd      = ilibnatjou.soc-cd
                                                and ijou.natjou-cd   = ilibnatjou.natjou-cd
                                                and ilibnatjou.treso = true)):
        pcListeODT = pcListeODT + "|" + ijou.jou-cd.
    end.
    for each ijou no-lock
        where ijou.soc-cd  = giCodesoc
          and ijou.etab-cd = giGestionCommune
          and (ijou.natjou-gi = 46 or can-find(first ilibnatjou no-lock
                                              where ijou.soc-cd      = ilibnatjou.soc-cd
                                                and ijou.natjou-cd   = ilibnatjou.natjou-cd
                                                and ilibnatjou.treso = true)):
        pcListeODT = pcListeODT + "|" + ijou.jou-cd.
    end.

    /**  RECHERCHE DES JOURNAUX OD,  ON NE PRENDS PAS LE JOURNAL ODT **/
    find first ilibnatjou no-lock
        where ilibnatjou.soc-cd = giCodesoc
          and ilibnatjou.od     = true no-error.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = gicodesoc
          and ijou.etab-cd   = giEtablissement
          and ijou.natjou-cd = ilibnatjou.natjou-cd
          and ijou.natjou-gi <> 46 /* EXCLUSION ODT */
        use-index jou-i:
        pcListeOD = pcListeOD + "," + ijou.jou-cd.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = giCodeSoc
          and ijou.etab-cd   = giGeranceGlobale
          and ijou.natjou-cd = ilibnatjou.natjou-cd
          and ijou.natjou-gi <> 46 /* EXCLUSION ODT */
        use-index jou-i:
        pcListeOD = pcListeOD + "," + ijou.jou-cd.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = giCodeSoc
          and ijou.etab-cd   = giGestionCommune
          and ijou.natjou-cd = ilibnatjou.natjou-cd
          and ijou.natjou-gi <> 46 /* EXCLUSION ODT */
        use-index jou-i:
        pcListeOD = pcListeOD + "," + ijou.jou-cd.
    end.

    /**  RECHERCHE DES JOURNAUX AN  **/
    find first ilibnatjou no-lock
        where ilibnatjou.soc-cd   = giCodesoc
          and ilibnatjou.anouveau = true no-error.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = gicodesoc
          and ijou.etab-cd   = giEtablissement
          and ijou.natjou-cd = ilibnatjou.natjou-cd
        use-index jou-i:
        pcListeAN = pcListeAN + "," + ijou.jou-cd.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = giCodeSoc
          and ijou.etab-cd   = giGeranceGlobale
          and ijou.natjou-cd = ilibnatjou.natjou-cd
        use-index jou-i:
        pcListeAN = pcListeAN + "," + ijou.jou-cd.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = giCodeSoc
          and ijou.etab-cd   = giGestionCommune
          and ijou.natjou-cd = ilibnatjou.natjou-cd
        use-index jou-i:
        pcListeAN = pcListeAN + "," + ijou.jou-cd.
    end.
end procedure.

procedure readPeriodeFromFile:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter pcRepertoire        as character no-undo.
    define input  parameter piCodesoc           as integer   no-undo.
    define input  parameter piCodeEtablissement as integer   no-undo.    
    define input  parameter pdaDeclaration      as date      no-undo.        
    define output parameter pdaDebutPeriode     as date      no-undo.
    define output parameter pdaFinPeriode       as date      no-undo.

    define variable vcLigne as character no-undo.
    define buffer iprd   for iprd.
    define buffer vbIprd for iprd.

    input stream dm2 from value(pcRepertoire + "AccesDirect/AccesDirect.01").
    repeat:
        import stream dm2 unformatted vcLigne.
        vcLigne = trim(vcLigne).
        if vcLigne > "" then do:
            if (entry(1, vcLigne, ":")      = "MODULE"
           and trim(entry(2, vcLigne, ":")) = "MIGRATION ECLATEMENT DES ENCAISSEMENTS")
            or (entry(1, vcLigne, ":")      = "MODULE"
           and trim(entry(2, vcLigne, ":")) = "ECLATEMENT DES ENCAISSEMENTS")
            then for first iprd no-lock
                where iprd.soc-cd   =  piCodesoc
                  and iprd.etab-cd  =  piCodeEtablissement
                  and iprd.dadebprd <= pdaDeclaration
                  and iprd.dafinprd >= pdaDeclaration:
                find first vbIprd no-lock
                    where vbIprd.soc-cd  = piCodesoc
                      and vbIprd.etab-cd = piCodeEtablissement
                      and vbIprd.prd-cd  = iprd.prd-cd no-error.
                pdaDebutPeriode = vbIprd.dadebprd.
                find last vbIprd no-lock
                    where vbIprd.soc-cd  = piCodesoc
                      and vbIprd.etab-cd = piCodeEtablissement
                      and vbIprd.prd-cd  = iprd.prd-cd no-error.
                pdaFinPeriode = vbIprd.dafinprd.
            end.
            else if entry (1, vcLigne, ":") = "INFORMATIONS" then .
        end.
    end.
    input stream dm2 close.
end procedure.

procedure extractionReglementReactive private:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------------------*/
    define input  parameter piCodeSociete    as integer   no-undo.
    define input  parameter piEtablissement  as integer   no-undo.
    define input  parameter pcCodeCollectif  as character no-undo.
    define input  parameter pcCompte1        as character no-undo.
    define input  parameter pdaFinPeriode    as date      no-undo.
    define input  parameter pcListeMouvement as character no-undo.
    define input  parameter pcListeJournalOD as character no-undo.
    define input  parameter pcListeJournalAN as character no-undo.

    define buffer vbCercln  for cecrln.   /* DM 0109/0115 */
    define buffer vb2cercln for cecrln.
    define buffer vbAdbtva  for adbtva.
    define buffer adbtva    for adbtva.
    define buffer cecrln    for cecrln.
    define buffer itypemvt  for itypemvt.
    define buffer ijou      for ijou.

boucleBcecrln:
    for each vbCercln no-lock
        where vbCercln.soc-cd = piCodeSociete
          and vbCercln.etab-cd    = piEtablissement
          and vbCercln.sscoll-cle = pcCodeCollectif
          and vbCercln.cpt-cd     = pcCompte1
          and vbCercln.dacompta  >= gdaDebutPeriode
          and vbCercln.dacompta  <= pdaFinPeriode
          and vbCercln.fg-reac    = true
          and vbCercln.lettre    <> "":
        find first ijou no-lock
            where ijou.soc-cd  = vbCercln.soc-cd
              and ijou.etab-cd = vbCercln.mandat-cd
              and ijou.jou-cd  = vbCercln.jou-cd no-error.
        {&_proparse_ prolint-nowarn(release)}
        release itypemvt.
        if available ijou
        then find first itypemvt no-lock
            where itypemvt.soc-cd    = vbCercln.soc-cd
              and itypemvt.etab-cd   = vbCercln.mandat-cd
              and itypemvt.natjou-cd = ijou.natjou-cd
              and itypemvt.type-cle  = vbCercln.type-cle no-error.
        if not available ijou
        or (ijou.natjou-gi <> 46
           and not(vbCercln.type-cle = "ODT" and ijou.natjou-cd = 9)
           and not(available itypemvt and (itypemvt.typenat-cd = 50 or itypemvt.typenat-cd = 51) and ijou.natjou-cd = 9) /* AN de tréso */
           and not can-find(first ilibnatjou no-lock
                        where ilibnatjou.soc-cd    = ijou.soc-cd 
                          and ilibnatjou.natjou-cd = ijou.natjou-cd
                          and ilibnatjou.treso     = true)) then next boucleBcecrln. /* ce n'est pas un règlement */

        /* Extraction des quittances lettrées avec ce règlement */
        empty temp-table ttQuittanceReglement.
        for each vb2cercln no-lock
            where vb2cercln.soc-cd     = piCodeSociete
              and vb2cercln.etab-cd    = piEtablissement
              and vb2cercln.sscoll-cle = vbCercln.sscoll-cle
              and vb2cercln.cpt-cd     = vbCercln.cpt-cd
              and vb2cercln.lettre     = vbCercln.lettre
              and vb2cercln.dacompta  >= gdaDebutPeriode
              and vb2cercln.dacompta  <= pdaFinPeriode
              and (vb2cercln.jou-cd = gcJournalQuittancement or lookup(vb2cercln.jou-cd, pcListeJournalOD) > 0
                 or (lookup(vb2cercln.jou-cd, pcListeJournalAN) > 0 and lookup(vb2cercln.type-cle, pcListeMouvement) = 0)): /* Pas les AN de tréso */
            create ttQuittanceReglement.
            ttQuittanceReglement.rrowid = rowid(vb2cercln).
            /* certaines ventilations peuvent porter sur des quittances des exercices précédents, il faut donc aussi les parcourir */
            for each cecrln no-lock
                where cecrln.soc-cd     = vb2cercln.soc-cd
                  and cecrln.etab-cd    = vb2cercln.etab-cd
                  and cecrln.sscoll-cle = vb2cercln.sscoll-cle
                  and cecrln.cpt-cd     = vb2cercln.cpt-cd
                  and cecrln.sens       = vb2cercln.sens
                  and cecrln.mt         = vb2cercln.mt
                  and cecrln.ref-num    = vb2cercln.ref-num
                  and cecrln.lib-ecr[1] = vb2cercln.lib-ecr[1]
                  and cecrln.datecr    = vb2cercln.datecr
                  and (cecrln.jou-cd   = gcJournalQuittancement or lookup(cecrln.jou-cd, pcListeJournalOD) > 0
                       or (lookup(cecrln.jou-cd, pcListeJournalAN) > 0 and lookup(cecrln.type-cle, pcListeMouvement) = 0)) /* Pas les AN de tréso */
                  and cecrln.dacompta < gdaDebutPeriode
                break by cecrln.prd-cd:
                if first-of(cecrln.prd-cd) and last-of(cecrln.prd-cd)
                then do: /* Il ne doit y avoir qu'une seule ecriture par exercice */
                    create ttQuittanceReglement.
                    ttQuittanceReglement.rrowid = rowid(cecrln).
                end.
            end.
        end.
        for each ttQuittanceReglement:
            find first vb2cercln no-lock where rowid(vb2cercln) = ttQuittanceReglement.rrowid no-error.
            /* Extraction des ventilations affectées à cette quittance */
BCL:
            for each adbtva no-lock
                where adbtva.Soc-cd          = vb2cercln.soc-cd
                  and adbtva.etab-cd         = vb2cercln.etab-cd
                  and adbtva.ecrln-jou-cd    = vb2cercln.jou-cd
                  and adbtva.ecrln-prd-cd    = vb2cercln.prd-cd
                  and adbtva.ecrln-prd-num   = vb2cercln.prd-num
                  and adbtva.ecrln-piece-int = vb2cercln.piece-int
                  and adbtva.ecrln-lig       = vb2cercln.lig:
                /* Recherche de l'encaissement rattaché, lettré à blanc et non activé */
                find first cecrln exclusive-lock
                    where cecrln.soc-cd    = adbtva.soc-cd
                      and cecrln.etab-cd   = adbtva.etab-cd
                      and cecrln.jou-cd    = adbtva.jou-cd
                      and cecrln.prd-cd    = adbtva.prd-cd
                      and cecrln.prd-num   = adbtva.prd-num
                      and cecrln.piece-int = adbtva.piece-int
                      and cecrln.lig       = adbtva.lig
                      and cecrln.fg-reac   = false
                      and cecrln.lettre    = ""
                      and cecrln.dacompta >= gdaDebutPeriode no-error.
                if available cecrln
                then for each vbAdbtva no-lock
                    where vbAdbtva.soc-cd    = cecrln.soc-cd
                      and vbAdbtva.etab-cd   = cecrln.etab-cd
                      and vbAdbtva.jou-cd    = cecrln.jou-cd
                      and vbAdbtva.prd-cd    = cecrln.prd-cd
                      and vbAdbtva.prd-num   = cecrln.prd-num
                      and vbAdbtva.piece-int = cecrln.piece-int
                      and vbAdbtva.lig       = cecrln.lig
                    by vbAdbtva.num-int descending:
                    if vbAdbtva.reactiv then next BCL. /* on s'arrete à la derniere annulation */

                    if vbAdbtva.ecrln-jou-cd     = adbtva.ecrln-jou-cd
                    and vbAdbtva.ecrln-prd-cd    = adbtva.ecrln-prd-cd
                    and vbAdbtva.ecrln-prd-num   = adbtva.ecrln-prd-num
                    and vbAdbtva.ecrln-piece-int = adbtva.ecrln-piece-int
                    and vbAdbtva.ecrln-lig       = adbtva.ecrln-lig
                    then do:
                        cecrln.fg-reac = true. /* cette quittance fait partie de la derniere ventilation "+" de l'encaissement -> on reactive */
                        next BCL.
                    end.
                end.
            end.
        end.
    end.
end procedure.

procedure reinitialisationVentilation private:
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes:    pdaProchainTraitement est vraiment input-output ????
    -----------------------------------------------------------------------------*/
    define input        parameter piCodeSociete      as integer   no-undo.
    define input        parameter piEtablissement    as integer   no-undo.
    define input        parameter pcCodeCollectif    as character no-undo.
    define input        parameter pcCompte1          as character no-undo.
    define input        parameter piCodePeriode      as integer   no-undo.
    define input        parameter piNumeroPeriode    as integer   no-undo.
    define input        parameter pdaFinPeriode      as date      no-undo.
    define input        parameter pdaDebutTraitement as date      no-undo.
    define input        parameter pdaFinTraitement   as date      no-undo.
    define input        parameter piPeriodeTrt       as integer no-undo.
    define input-output parameter pdaProchainTraitement as date      no-undo.

    define variable viDerniereVentilation  as integer   no-undo.
    define variable viNumeroInterne        as integer   no-undo.
    define variable vlRegul                as logical   no-undo.
    define variable viPeriodeProchainTt    as integer   no-undo.
    define buffer cecrln    for cecrln.
    define buffer aligtva   for aligtva.
    define buffer vbAligtva for aligtva.
    define buffer ijou      for ijou.
    define buffer itypemvt  for itypemvt.
    define buffer adbtva    for adbtva.
    define buffer vbAdbtva  for adbtva.
    define buffer vb2adbtva for adbtva.
    define buffer vb3adbtva for adbtva.
    define buffer vb4adbtva for adbtva.

boucleCecrln:
    for each cecrln no-lock
        where cecrln.soc-cd     = piCodeSociete
          and cecrln.etab-cd    = piEtablissement
          and cecrln.sscoll-cle = pcCodeCollectif
          and cecrln.cpt-cd     = pcCompte1
          and cecrln.prd-cd     = piCodePeriode
          &IF DEFINED(Utilitaire) = 0 &THEN
          and cecrln.fg-reac    = true
          &ENDIF
          and cecrln.prd-num    = piNumeroPeriode:
        find first ijou no-lock
            where ijou.soc-cd  = cecrln.soc-cd
              and ijou.etab-cd = cecrln.mandat-cd
              and ijou.jou-cd  = cecrln.jou-cd no-error.
        {&_proparse_ prolint-nowarn(release)}
        release itypemvt.
        if available ijou
        then find first itypemvt no-lock
            where itypemvt.soc-cd    = cecrln.soc-cd
              and itypemvt.etab-cd   = cecrln.mandat-cd
              and itypemvt.natjou-cd = ijou.natjou-cd
              and itypemvt.type-cle  = cecrln.type-cle no-error.
        if not available ijou
        or (ijou.natjou-gi <> 46
           and not(cecrln.type-cle = "ODT" and ijou.natjou-cd = 9)
           and not(available itypemvt and (itypemvt.typenat-cd = 50 or itypemvt.typenat-cd = 51) and ijou.natjou-cd = 9) /* AN de tréso */
           and not can-find(first ilibnatjou no-lock
                            where ilibnatjou.soc-cd    = ijou.soc-cd 
                              and ilibnatjou.natjou-cd = ijou.natjou-cd
                              and ilibnatjou.treso     = true)) then next boucleCecrln.
boucleAdbtva:
        for each adbtva exclusive-lock
            where adbtva.soc-cd    = cecrln.soc-cd
              and adbtva.etab-cd   = cecrln.etab-cd
              and adbtva.jou-cd    = cecrln.jou-cd
              and adbtva.prd-cd    = cecrln.prd-cd
              and adbtva.prd-num   = cecrln.prd-num
              and adbtva.piece-int = cecrln.piece-int
              and adbtva.lig       = cecrln.lig
              and adbtva.cmthon    = ?
              and not can-find(first aligtva no-lock
                               where aligtva.soc-cd = adbtva.soc-cd
                                 and aligtva.etab-cd = adbtva.etab-cd
                                 and aligtva.num-int = adbtva.num-int
                                 and aligtva.cmthon <> ?):
            if adbtva.date_decla >= pdaDebutTraitement
            then .
            else next boucleAdbtva. /* on ne supprime pas les elements déclarés (sur decla tva,crg,irf,hono) */

            if adbtva.fg-regul = false and adbtva.usridcre <> "maj_ecr_regul.p" /* DM 0109/0115 */
            then do: /* DM 0607/0253 Ne pas supprimer les ventils manu dont fg-reac a été forcé dans ctrlecla.p) */
                for each aligtva exclusive-lock
                    where aligtva.soc-cd  = adbtva.soc-cd
                      and aligtva.etab-cd = adbtva.etab-cd
                      and aligtva.num-int = adbtva.num-int:
                    delete AligTva.
                end.
                delete adbtva.
            end.
        end.
        /**  RECHERCHE DE LA MEMOIRE TVA  **/
        if can-find(first adbtva no-lock
            where adbtva.soc-cd    = cecrln.soc-cd
              and adbtva.etab-cd   = cecrln.etab-cd
              and adbtva.jou-cd    = cecrln.jou-cd
              and adbtva.prd-cd    = cecrln.prd-cd
              and adbtva.prd-num   = cecrln.prd-num
              and adbtva.piece-int = cecrln.piece-int
              and adbtva.lig       = cecrln.lig) then do:
            /**   ECRITURE NEGATIVE   **/
            for last adbtva no-lock
                where adbtva.soc-cd     = cecrln.soc-cd
                  and adbtva.etab-cd    = cecrln.etab-cd
                  and adbtva.jou-cd     = cecrln.jou-cd
                  and adbtva.prd-cd     = cecrln.prd-cd
                  and adbtva.prd-num    = cecrln.prd-num
                  and adbtva.piece-int  = cecrln.piece-int
                  and adbtva.lig        = cecrln.lig
                  and adbtva.reactiv    = false
                  and adbtva.date_decla <= pdaFinTraitement:
                /* DM 0109/0115 Recherche de la derniere ventilation positive de la déclaration précédente */
                viDerniereVentilation = ?.
boucleAdbtva2:
                for each vb3adbtva no-lock
                    where vb3adbtva.soc-cd     = cecrln.soc-cd
                      and vb3adbtva.etab-cd    = cecrln.etab-cd
                      and vb3adbtva.jou-cd     = cecrln.jou-cd
                      and vb3adbtva.prd-cd     = cecrln.prd-cd
                      and vb3adbtva.prd-num    = cecrln.prd-num
                      and vb3adbtva.piece-int  = cecrln.piece-int
                      and vb3adbtva.lig        = cecrln.lig
                      and vb3adbtva.date_decla = adbtva.date_decla
                    by vb3adbtva.num-int descending:
                    if vb3adbtva.reactiv then leave boucleAdbtva2.

                    viDerniereVentilation = vb3adbtva.num-int.
                end.
                for each vb3adbtva exclusive-lock
                    where vb3adbtva.soc-cd     = cecrln.soc-cd
                      and vb3adbtva.etab-cd    = cecrln.etab-cd
                      and vb3adbtva.jou-cd     = cecrln.jou-cd
                      and vb3adbtva.prd-cd     = cecrln.prd-cd
                      and vb3adbtva.prd-num    = cecrln.prd-num
                      and vb3adbtva.piece-int  = cecrln.piece-int
                      and vb3adbtva.lig        = cecrln.lig
                      and vb3adbtva.date_decla = adbtva.date_decla
                      and (if viDerniereVentilation = ? then false else vb3adbtva.num-int >= viDerniereVentilation)
                    by vb3adbtva.num-int:
                    if vb3adbtva.fg-regul = false then do : /* Rajout du if DM 0607/0253 Ne pas annuler les ventils manu dont fg-reac a été forcé dans ctrlecla.p */
                        find last vbAdbtva no-lock
                            where vbAdbtva.soc-cd  = piCodeSociete
                              and vbAdbtva.etab-cd = piEtablissement no-error.
                        viNumeroInterne = if available vbAdbtva then vbAdbtva.num-int + 1 else 1.
                        create vb2adbtva.
                        assign
                            vb2adbtva.usridcre        = mToken:cUser
                            vb2adbtva.ihcre           = time
                            vb2adbtva.dacre           = today
                            vb2adbtva.soc-cd          = cecrln.soc-cd
                            vb2adbtva.etab-cd         = cecrln.etab-cd
                            vb2adbtva.num-int         = viNumeroInterne
                            vb2adbtva.jou-cd          = cecrln.jou-cd
                            vb2adbtva.prd-cd          = cecrln.prd-cd
                            vb2adbtva.prd-num         = cecrln.prd-num
                            vb2adbtva.piece-int       = cecrln.piece-int
                            vb2adbtva.lig             = cecrln.lig
                            vb2adbtva.dacompta        = cecrln.dacompta
                            vb2adbtva.ecrln-jou-cd    = vb3adbtva.ecrln-jou-cd
                            vb2adbtva.ecrln-prd-cd    = vb3adbtva.ecrln-prd-cd
                            vb2adbtva.ecrln-prd-num   = vb3adbtva.ecrln-prd-num
                            vb2adbtva.ecrln-piece-int = vb3adbtva.ecrln-piece-int
                            vb2adbtva.ecrln-lig       = vb3adbtva.ecrln-lig
                            vb2adbtva.sens            = vb3adbtva.sens
                            vb2adbtva.cpt-cd          = vb3adbtva.cpt-cd
                            vb2adbtva.mt              = - vb3adbtva.mt
                            vb2adbtva.mtht            = - vb3adbtva.mtht
                            vb2adbtva.mttva           = - vb3adbtva.mttva
                            vb2adbtva.taux            = vb3adbtva.taux
                            vb2adbtva.date-quit       = vb3adbtva.date-quit
                            vb2adbtva.period          = giNumeroPeriode
                            vb2adbtva.date_decla      = gdaDeclaration
                            vb2adbtva.reactiv         = true
                            vb2adbtva.let             = vb3adbtva.let
                            vb2adbtva.type-decla      = giTypeDeclaration
                            vb2adbtva.fg-man          = vb3adbtva.fg-man /* DM 0607/0253 */
                            /* DM 0508/0177 Affectation de la date de prochain traitement */
                            pdaProchainTraitement      = pdaFinTraitement
                            viPeriodeProchainTt        = piPeriodeTrt
                            vlRegul                    = (pdaFinPeriode <> pdaFinTraitement /* c'est une regul, elle ne sera pas sur le mois de l'encaissement */
                                                       or ijou.natjou-gi = 93)              /* Les ventilations sur les tréso reportées en ANC sont des régules */
                        .
                        if vlRegul then assign               /* C'est une régularisation, la ventilation + aura la meme date de traitement que la ventilation -  */
                            vb2adbtva.lib-trt    = "AR"     /* -> A Regulariser */
                            vb2adbtva.date-trt   = pdaProchainTraitement
                            vb2adbtva.date_decla = pdaProchainTraitement
                            vb2adbtva.periode    = viPeriodeProchainTt
                        .
                        for each aligtva no-lock
                            where aligtva.soc-cd = vb3adbtva.soc-cd
                              and aligtva.etab-cd = vb3adbtva.etab-cd
                              and aligtva.num-int = vb3adbtva.num-int:
                            create vbAligtva.
                            assign
                                vbAligtva.soc-cd  = piCodeSociete
                                vbAligtva.etab-cd = piEtablissement
                                vbAligtva.num-int = vb2adbtva.num-int
                                vbAligtva.cdrub   = aligtva.cdrub
                                vbAligtva.cdlib   = aligtva.cdlib
                                vbAligtva.cat-cd  = aligtva.cat-cd
                                vbAligtva.periode = vb2adbtva.periode
                                vbAligtva.taux    = aligtva.taux
                                vbAligtva.mtht    = - aligtva.mtht
                                vbAligtva.mttva   = - aligtva.mttva
                            .
                        end.
                        /* DM 0109/0115 Ne pas annuler si déjà annulé par moulinette (dauchez) */
                        find last vb4adbtva no-lock
                            where vb4adbtva.soc-cd     = cecrln.soc-cd
                              and vb4adbtva.etab-cd    = cecrln.etab-cd
                              and vb4adbtva.jou-cd     = cecrln.jou-cd
                              and vb4adbtva.prd-cd     = cecrln.prd-cd
                              and vb4adbtva.prd-num    = cecrln.prd-num
                              and vb4adbtva.piece-int  = cecrln.piece-int
                              and vb4adbtva.lig        = cecrln.lig
                              and vb4adbtva.usridcre   = "maj_ecr_regul.p"
                              and vb4adbtva.date_decla = vb2adbtva.date_decla no-error.
                        if available vb4adbtva
                        then do:
                            for each vbAligtva exclusive-lock
                                where vbAligtva.soc-cd  = vb2adbtva.soc-cd
                                  and vbAligtva.etab-cd = vb2adbtva.etab-cd
                                  and vbAligtva.num-int = vb2adbtva.num-int:
                                delete vbAligtva.
                            end.
                            delete vb2adbtva.
                        end.
                    end.
                    vb3adbtva.fg-regul = false. /* DM 0607/0253 */
                end.
            end.
        end.
    end.
end procedure.

procedure ratachementAdbtva private: 
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes:  (giCodeSoc, giEtablissement, giTypeDeclaration). 
    -----------------------------------------------------------------------------*/
    define input  parameter piCodeSociete     as integer   no-undo.
    define input  parameter piEtablissement   as integer   no-undo.
    define input  parameter piTypeDeclaration as integer   no-undo.
    define input  parameter pcCodeCollectif   as character no-undo.
    define input  parameter pcCompte1         as character no-undo.
    define input  parameter piCodePeriode     as integer   no-undo.
    define input  parameter piNumeroPeriode   as integer   no-undo.
    define buffer cecrln for cecrln.
    define buffer adbtva for adbtva.

    for each cecrln no-lock
        where cecrln.soc-cd     = piCodeSociete
          and cecrln.etab-cd    = piEtablissement
          and cecrln.sscoll-cle = pcCodeCollectif
          and cecrln.cpt-cd     = pcCompte1
          and cecrln.prd-cd     = piCodePeriode
          and cecrln.prd-num    = piNumeroPeriode:
        if can-find(first adbtva no-lock
            where adbtva.soc-cd     = cecrln.soc-cd
              and adbtva.etab-cd    = cecrln.etab-cd
              and adbtva.jou-cd     = cecrln.jou-cd
              and adbtva.prd-cd     = cecrln.prd-cd
              and adbtva.prd-num    = cecrln.prd-num
              and adbtva.piece-int  = cecrln.piece-int
              and adbtva.lig        = cecrln.lig
              and adbtva.type-decla = 10)              /* 10 =  Eclatement des encaissements sans declaration (cf adecla1.p) **/
        then for each adbtva exclusive-lock
            where adbtva.soc-cd    = cecrln.soc-cd
              and adbtva.etab-cd   = cecrln.etab-cd
              and adbtva.jou-cd    = cecrln.jou-cd
              and adbtva.prd-cd    = cecrln.prd-cd
              and adbtva.prd-num   = cecrln.prd-num
              and adbtva.piece-int = cecrln.piece-int
              and adbtva.lig       = cecrln.lig:
            adbtva.type-decla = piTypeDeclaration.
        end.
    end.
end procedure.
