/*------------------------------------------------------------------------
File        : procecla.i
Purpose     : Include de procedures communes aux programmes suivants:
                    TRANS/SRC/GENE/CGEC.P
                    CADB/SRC/BATCH/EXTENCQT.P + EXTENCQT1.P
                    CADB\SRC\EDIGENE\XVENTENC.P
Author(s)   : OF - 2006/06/06, Kantena - 2018/01/11
Notes       : reprise comm/procecla.i
01  07/06/2006  DM    0706/0055 Faire apparaitre tva d'aligtva-tmp
02  16/08/06    OF    0706/0175 Mt doublé quand pas de adbtva
03  13/10/06    OF    0906/0125 Mauvais montants dans les RBHO si l'encaissement n'est pas éclaté
04  03/11/06    DM    1006/0282 Edition detail encaissement ne pas prendre les ecr lettrees dans le solde init
05  07/11/2006  DM    1106/0030 Faire apparaitre tva d'impaye
06  24/11/06    DM    1106/0082 Prise en compte des OD col quitt
07  10/01/08    OF    0108/0160 Modif pour édition ventilation des encaissements ds les CRG (xventenc.p)
08  14/02/08    JR    0108/0343 Qd pas d'éclatement,toujours mettre par défaut 101 (loyer)
                      + La date de début pour extraire les impayés était mal-gérée
09  26/05/08    OF    0508/0116 Mise au point modif précédente
10  27/08/08    DM    0508/0177 Integration des réguls d'eclatement
11  03/11/08    JR    1008/0296 Pb de signe dans les impayes en début d'exercice|
12  26/01/09    OF    1208/0236 CRG décalés
13  02/02/09    DM    0109/0220 Filtre OD
14  02/02/09    DM    0109/0115 Mise au point regule
15  02/02/09    DM    0109/0232 Prise en compte des regules d'AN
16  11/02/09    DM    0209/0075 Pb 1er CRG
17  13/02/09    DM    0209/0071 Pb annulation
18  07/04/09    DM    0409/0037 Rajout Simulation
19  15/04/09    OF    0409/0150 Pb si num-crg = 0 au lieu de ?
20  15/06/09    DM    0409/0180 Fiche 0109/0220 pour Dauchez
21  30/07/09    DM    0409/0037b Pb reguls sur situation locataire
22  22/09/09    OF    0909/0113 Pb rubrique de quitt par défaut
23  06/10/09    DM    0809/0042 Pb période solde début etat excel
24  29/10/09    DM    1009/0159 Pb filtre crg mode test
25  05/05/10    OF    0410/0120 Récapitulatif fin d'année
26  20/08/10    OF    0810/0067 les OD du journal CLOC ne sont pas des encaissements mais du quittancement
27  10/02/2011  DM    0211/0063 Taux de tva du bail par défaut
28  21/02/12    OF    0511/0024 IRF 2011 - Optimisation
29  27/06/12    DM    Pas de fiche - Pb extraction regule d'ODT
30  17/06/13    DM    0113/0150 Extraction hono CRG cardif
31  30/01/14    OF    0114/0086 Optimisation
32  05/08/14    OF    0714/0239 Mauvais taux TVA du bail
33  12/01/16    DM    0116/0070 Probleme 1er CRG local
34  20/04/17    DM    #1415 pb tva par défaut si pas de aquit sur le mois du crg
----------------------------------------------------------------------*/
{preprocesseur/listeRubQuit2TVA.i}

PROCEDURE creation-aligtva-tmp:
    /*------------------------------------------------------------------------------
    purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define variable viNombreJourCRG     as integer   no-undo. /* DM 0113/0150 */
    define variable vcParametre         as character no-undo. /* DM 0508/0177 */
    define variable vdaTVA              as date      no-undo. /* DM 0508/0177 */
    define variable vdaCRG              as date      no-undo. /* DM 0508/0177 */
    define variable vdaIRF              as date      no-undo. /* DM 0508/0177 */
    define variable vdaHono             as date      no-undo. /* DM 0508/0177 */
    define variable vdeTotalVentilation as decimal   no-undo.  /* DM 0508/0177 */
    define variable vdaFiltre           as date      no-undo. /* DM 1009/0159 */
    define variable vdeTauxBail         as decimal   no-undo. /* DM 0211/0063 */
    define variable vlFiltre            as logical   no-undo. /* DM 0116/0070 */
    // todo   introduire une variable pour simplifier le can-find !!!
    define variable vlReportEtExtract   as logical   no-undo.
    define variable vlVentilation       as logical   no-undo.

    define buffer ijou  for ijou.
    define buffer tache for tache.

    run RCLOC(integer(string(ietab.etab-cd) + csscpt.cpt-cd), tmp-dafin).
    IF NOT VlRBHO THEN DO:
        EMPTY TEMP-TABLE cecrln-enc.
        EMPTY TEMP-TABLE aligtva-tmp.
    END.
    run datetrt(piCodeSoc, ietab.etab-cd, tmp-dafin, vcParametre). // dans datetrt.i
    /* Date des derniers traitements effectués */
    assign
        viNombreJourCRG   = (&IF DEFINED(REPORT) &then IF glExtractCRG then 60 ELSE 0 &ELSE 0 &ENDIF)
        vdeTauxBail    = dynamic-function("getTauxTvaBail" in ghOutilsTva, integer(string(csscpt.etab-cd) + csscpt.cpt-cd))
        vdaFiltre    = tmp-dadeb
        vdaTVA     = date(entry(4, vcParametre, chr(9)))
        vdaCRG     = date(entry(5, vcParametre, chr(9)))
        vdaIRF     = date(entry(6, vcParametre, chr(9)))
        vdaHono    = date(entry(7, vcParametre, chr(9)))
    .
    &IF DEFINED(RLVPRO) &THEN
    if goNouveauCrg:isNouveauCRGActif() then vdaFiltre = date(month(tmp-dadeb-in - 1), 01, year(tmp-dadeb-in - 1)).
    &ENDIF
Ecriture:
    for each cecrln no-lock
        where cecrln.soc-cd     = mtoken:iCodeSociete
          and cecrln.etab-cd    = ietab.etab-cd
          and cecrln.sscoll-cle = csscpt.sscoll-cle
          and cecrln.cpt-cd     = csscpt.cpt-cd
          and cecrln.dacompta   >= tmp-dadeb - viNombreJourCRG /* DM 0113/0150 */
          and cecrln.dacompta   <= tmp-dafin
      , first  ijou no-lock
        where ijou.soc-cd = cecrln.soc-cd
          and ijou.etab-cd = cecrln.mandat-cd
          and ijou.jou-cd  = cecrln.jou-cd
          and (ijou.natjou-cd = 2 or ijou.natjou-gi = 46 or (ijou.natjou-gi = 40 and mtoken:iCodeSociete <> 3073)):
        /**Ajout OF le 10/01/08**/
        &IF DEFINED(RLVPRO) &THEN
        if not VlRecapAnnuel then do: /**Ajout du test par OF le 05/05/10**/
            /*Filtre pour l'édition de la ventilation des encaissements dans les CRG*/
            if can-find(first ahistcrg where ahistcrg.soc-cd   = ietab.soc-cd
            and ahistcrg.etab-cd  = ietab.etab-cd)
            then do:
                if not VlRecapAnnuel and cecrln.num-crg <> ? and cecrln.num-crg ne 0 and ABS(cecrln.num-crg) <> ViNumCRG then next Ecriture.
            END.
            else do:
                /*Si on est sur le 1er CRG micro, on ne peut pas utiliser le champ num-crg
                  -> il faut filtrer les écritures du mois antérieur si elles ont été créées
                     avant le transfert de la compta de ce mois*/
                find first cecrsai no-lock
                    where cecrsai.soc-cd    = cecrln.soc-cd
                      and cecrsai.etab-cd   = cecrln.mandat-cd
                      and cecrsai.jou-cd    = cecrln.jou-cd
                      and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                      and cecrsai.prd-num   = cecrln.mandat-prd-num
                      and cecrsai.piece-int = cecrln.piece-int no-error.
                find first suivtrf no-lock
                    where suivtrf.soc-cd = ietab.soc-cd
                      and suivtrf.cdtrait = "CPTE"
                      and suivtrf.gest-cle = ietab.gest-cle
                      and suivtrf.moiscpt = INTEGER(string(month(vdaFiltre), "99") + string(year(vdaFiltre), "9999")) no-error.
                if available suivtrf and available cecrsai and cecrsai.dadoss <= suivtrf.jcretrf then next.
            end.
        end.
        &ENDIF
        find first cecrln-enc
            where cecrln-enc.soc-cd = cecrln.soc-cd
              and cecrln-enc.etab-cd = cecrln.etab-cd
              and cecrln-enc.jou-cd = cecrln.jou-cd
              and cecrln-enc.prd-cd = cecrln.prd-cd
              and cecrln-enc.prd-num = cecrln.prd-num
              and cecrln-enc.piece-int = cecrln.piece-int
              and cecrln-enc.lig = cecrln.lig no-error.            /* DM 1110/0064 Rajout du find */
        if not available cecrln-enc then do : /* DM 1110/0064 Rajout du if */
            create cecrln-enc.
            buffer-copy cecrln to cecrln-enc.
        end.
    end.
    run regule(vdaTVA, vdaCRG, vdaIRF, vdaHono). /* DM 0109/0232 mis en procedure */
    /** MONTANT ENCAISSEMENT PAR RUBRIQUE **/
    for each cecrln-enc
        where cecrln-enc.sscoll-cle = csscpt.sscoll-cle
          and cecrln-enc.cpt-cd = csscpt.cpt-cd:
        assign
            dMtAdbtva      = 0
            dMtAdbtva-Euro = 0
        .
        /* DM 0508/0177 On retire du montant de l'encaissement les ventilations non editées */
        find first cecrln no-lock
            where cecrln.soc-cd = mtoken:iCodeSociete
              and cecrln.etab-cd = ietab.etab-cd
              and cecrln.jou-cd = cecrln-enc.jou-cd
              and cecrln.prd-cd = cecrln-enc.prd-cd
              and cecrln.prd-num = cecrln-enc.prd-num
              and cecrln.piece-int = cecrln-enc.piece-int
              and cecrln.lig = cecrln-enc.lig no-error.
        if available cecrln then do:
            assign
                vlReportEtExtract = &IF DEFINED(REPORT)
                                    &then if glExtractCRG
                                          then not can-find(first ahistcrg
                                                            where ahistcrg.soc-cd = cecrln.soc-cd
                                                              and ahistcrg.etab-cd = cecrln.etab-cd
                                                              and ahistcrg.num-crg = absolute(cecrln.num-crg)
                                                              and ahistcrg.dtdeb >= tmp-dadeb
                                                              and ahistcrg.dtfin <= tmp-dafin)
                                          else true
                                    &ELSE true
                                    &ENDIF
                vlVentilation = &IF DEFINED(RLVPRO) &then if not VlRecapAnnuel and cecrln.num-crg <> ? and cecrln.num-crg <> 0 and absolute(cecrln.num-crg) <> ViNumCRG then false else true &ELSE true &ENDIF
                vlFiltre      = false
            .
            &IF DEFINED(RLVPRO) &THEN
            if not VlRecapAnnuel then do:
                /*Filtre pour l'édition de la ventilation des encaissements dans les CRG*/
                if can-find(first ahistcrg where ahistcrg.soc-cd   = ietab.soc-cd
                                             and ahistcrg.etab-cd  = ietab.etab-cd
                                             and ahistcrg.num-crg > 1) then do:
                    if vlVentilation then vlFiltre = true.
                END.
                else do:
                    /*Si on est sur le 1er CRG micro, on ne peut pas utiliser le champ num-crg
                      -> il faut filtrer les écritures du mois antérieur si elles ont été créées
                      avant le transfert de la compta de ce mois*/
                    find first cecrsai no-lock
                        where cecrsai.soc-cd    = cecrln.soc-cd
                          and cecrsai.etab-cd   = cecrln.mandat-cd
                          and cecrsai.jou-cd    = cecrln.jou-cd
                          and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                          and cecrsai.prd-num   = cecrln.mandat-prd-num
                          and cecrsai.piece-int = cecrln.piece-int no-error.
                    find first suivtrf no-lock
                        where suivtrf.soc-cd = ietab.soc-cd
                          and suivtrf.cdtrait = "CPTE"
                          and suivtrf.gest-cle = ietab.gest-cle
                          and suivtrf.moiscpt = INTEGER(string(month(vdaFiltre),"99")  + string(year(vdaFiltre),"9999")) no-error.
                    if available suivtrf and available cecrsai and cecrsai.dadoss <= suivtrf.jcretrf then vlFiltre = true.
                end.
            end.
            &ENDIF
            vdeTotalVentilation = if cecrln-enc.sens then - cecrln-enc.mt else cecrln-enc.mt.
            FOR EACH adbtva NO-LOCK
                where adbtva.soc-cd = mtoken:iCodeSociete
                  and adbtva.etab-cd = ietab.etab-cd
                  and adbtva.jou-cd = cecrln-enc.jou-cd
                  and adbtva.prd-cd = cecrln-enc.prd-cd
                  and adbtva.prd-num = cecrln-enc.prd-num
                  and adbtva.piece-int = cecrln-enc.piece-int
                  and adbtva.lig = cecrln-enc.lig :
                if ((adbtva.lib-trt = ""   and cecrln-enc.dacompta >= tmp-dadeb - viNombreJourCRG
                  and cecrln-enc.dacompta <= tmp-dafin and not vlFiltre  and vlReportEtExtract and vlVentilation)
                 or (adbtva.lib-trt = "R"  and adbtva.date-trt >= &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF and adbtva.date-trt <= tmp-dafin)
                 or (adbtva.lib-trt = "AR" and (&IF DEFINED(REPORT) &then glSimulation &ELSE TRUE &ENDIF)
                      and not(tmp-dafin <= vdaTVA or tmp-dafin <= vdaIRF or tmp-dafin < vdaCRG or tmp-dafin < vdaHono))
                    )
                then .  /* ventil éditée */
                else vdeTotalVentilation = vdeTotalVentilation - adbtva.mt. /* ventile non editée */
            END. /* for each */
            assign
                vdeTotalVentilation        = - vdeTotalVentilation
                cecrln-enc.mt   = absolute(vdeTotalVentilation)
                cecrln-enc.sens = vdeTotalVentilation >= 0
            .
        END.
        if available cecrln then
        for each adbtva  no-lock
            where adbtva.soc-cd    = mtoken:iCodeSociete
              and adbtva.etab-cd   = ietab.etab-cd
              and adbtva.jou-cd    = cecrln-enc.jou-cd
              and adbtva.prd-cd    = cecrln-enc.prd-cd
              and adbtva.prd-num   = cecrln-enc.prd-num
              AND adbtva.piece-int = cecrln-enc.piece-int
              and adbtva.lig       = cecrln-enc.lig
              and (if goNouveauCrg:isNouveauCRGActif()
                   then ((adbtva.lib-trt = ""   and vlReportEtExtract
                      and cecrln-enc.dacompta >= tmp-dadeb - viNombreJourCRG and cecrln-enc.dacompta <= tmp-dafin
                      and not vlFiltre and vlVentilation)
                      or (adbtva.lib-trt = "R"  and adbtva.date-trt >= &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF and adbtva.date-trt <= tmp-dafin)
                      or (adbtva.lib-trt = "AR" and (&IF DEFINED(REPORT) &then glSimulation &ELSE true &ENDIF) /* DM 0409/0037 */
                          and not(tmp-dafin <= vdaTVA or tmp-dafin <= vdaIRF or tmp-dafin < vdaCRG or tmp-dafin < vdaHono)))
                    else true):
            ASSIGN
                dMtAdbtva      = dMtAdbtva + adbtva.mt
                dMtAdbtva-Euro = dMtAdbtva-Euro + adbtva.mt-euro
            .
            if not can-find(first aligtva no-lock
                where aligtva.soc-cd  = adbtva.soc-cd
                  and aligtva.etab-cd = adbtva.etab-cd
                  and aligtva.num-int = adbtva.num-int) then do:
                find first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = integer(string(ietab.etab-cd, "99999") + csscpt.cpt-cd)
                      and tache.tptac = {&TYPETACHE-TVABail} no-error.
                IF AVAILABLE tache THEN DO: /* Bail commercial assujetti à TVA */
                    ASSIGN
                        dMtEnc         = adbtva.mt / ((100 + vdeTauxBail) / 100)
                        dMtEnc-Euro    = adbtva.mt-euro / ((100 + vdeTauxBail) / 100)
                        dMtEncTva      = adbtva.mt - dMtEnc
                        dMtEncTva-Euro = adbtva.mt-euro - dMtEnc-Euro
                    /* Report de l'arrondi */
                        dMtEnc         = round(dMtEnc, 2)
                        dMtEncTva      = round(dMtEncTva, 2)
                        dMtEnc         = dMtEnc + (adbtva.mt - (dMtEnc + dMtEncTva))
                    .
                    find first aligtva-tmp
                        where aligtva-tmp.Soc-cd = adbtva.soc-cd
                          and aligtva-tmp.Etab-cd = adbtva.etab-cd
                          and (string(aligtva-tmp.CodeRub) begins "77" or string(aligtva-tmp.CodeRub) begins "78")
                          and  aligtva-tmp.DateCompta = (string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta),"99") + string(day(cecrln-enc.dacompta), "99"))
                          and aligtva-tmp.jou-cd = cecrln-enc.jou-cd
                          and aligtva-tmp.type-cle = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                          and aligtva-tmp.piece-int = cecrln-enc.piece-int
                          and aligtva-tmp.lig = cecrln-enc.lig no-error.
                    &IF DEFINED(REPORT) &THEN RELEASE aligtva-tmp. &ENDIF /* DM 0809/0042 */
                    if available aligtva-tmp then assign
                        aligtva-tmp.MtRub    = aligtva-tmp.MtRub + round(dMtEncTva, 2)
                        aligtva-tmp.MtRubTva = aligtva-tmp.MtRubTva + round(dMtEncTva, 2) /* DM 0705/0055 */
                        aligtva-tmp.Sens     = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                        aligtva-tmp.MtEuro   = aligtva-tmp.MtEuro + round(dMtEncTva-Euro, 2)
                    .
                    ELSE DO:
                        CREATE aligtva-tmp.
                        BUFFER-COPY cecrln-enc TO aligtva-tmp
                        assign aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                               aligtva-tmp.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                               aligtva-tmp.CodeRub    = if cecrln-enc.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old
                               aligtva-tmp.CodeLib    = iCdLibTva
                               aligtva-tmp.MtRub      = aligtva-tmp.MtRub + round(dMtEncTva, 2)
                               aligtva-tmp.MtRubTva   = aligtva-tmp.MtRubTva + round(dMtEncTva, 2) /* DM 0705/0055 */
                               aligtva-tmp.Sens       = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                               aligtva-tmp.MtEuro     = aligtva-tmp.MtEuro + round(dMtEncTva-Euro, 2)
                               aligtva-tmp.mois       = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                               aligtva-tmp.cmthono    = "0"
                               &IF DEFINED(RLVPRO) &THEN
                               &ELSE
                               aligtva-tmp.ecrln-jou-cd = adbtva.ecrln-jou-cd
                               aligtva-tmp.ecrln-prd-cd = adbtva.ecrln-prd-cd
                               aligtva-tmp.ecrln-prd-num = adbtva.ecrln-prd-num
                               aligtva-tmp.ecrln-piece-int = adbtva.ecrln-piece-int
                               aligtva-tmp.ecrln-lig = adbtva.ecrln-lig
                               &ENDIF
                        .
                    end.
                end.
                else assign
                    dMtEnc      = adbtva.mt
                    dMtEnc-Euro = adbtva.mt-euro
                .
                find first aligtva-tmp
                    where aligtva-tmp.Soc-cd = adbtva.soc-cd
                      and aligtva-tmp.Etab-cd = adbtva.etab-cd
                      and string(aligtva-tmp.CodeRub) begins "1"
                      and aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta),"99") + string(day(cecrln-enc.dacompta), "99")
                      and aligtva-tmp.jou-cd = cecrln-enc.jou-cd
                      and aligtva-tmp.type-cle = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                      and aligtva-tmp.piece-int = cecrln-enc.piece-int
                      and aligtva-tmp.lig = cecrln-enc.lig no-error.
                &IF DEFINED(REPORT) &THEN RELEASE aligtva-tmp. &ENDIF /* DM 0409/0037 */
                if available aligtva-tmp then assign
                    aligtva-tmp.MtRub   = aligtva-tmp.MtRub + round(dMtEnc, 2)
                    aligtva-tmp.Sens    = (if aligtva-tmp.MtRub >= 0 then "+" else "-")
                    aligtva-tmp.MtEuro  = aligtva-tmp.MtEuro + round(dMtEnc-Euro, 2)
                    aligtva-tmp.cmthono = if cecrln-enc.cmthono <> ? then string(aligtva-tmp.MtRub * 100)
                                          else if adbtva.cmthono = ? then aligtva-tmp.cmthono
                                          else string(decimal(aligtva-tmp.cmthono) + decimal(adbtva.cmthono))
                .
                ELSE DO:
                    CREATE aligtva-tmp.
                    BUFFER-COPY cecrln-enc TO aligtva-tmp
                    ASSIGN
                        aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta),"99") + string(day(cecrln-enc.dacompta),"99")
                        aligtva-tmp.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                        aligtva-tmp.CodeRub    = iCdRub
                        aligtva-tmp.CodeLib    = iCdLib
                        aligtva-tmp.MtRub      = aligtva-tmp.MtRub + round(dMtEnc, 2)
                        aligtva-tmp.Sens       = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                        aligtva-tmp.MtEuro     = aligtva-tmp.MtEuro + round(dMtEnc-Euro, 2)
                        aligtva-tmp.cmthono    = if cecrln-enc.cmthono <> ? then string(aligtva-tmp.MtRub * 100)
                                                 else if adbtva.cmthono = ? then "0"
                                                 else adbtva.cmthono
                        aligtva-tmp.mois = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                        &IF DEFINED(RLVPRO) &THEN
                        &ELSE
                        aligtva-tmp.ecrln-jou-cd    = adbtva.ecrln-jou-cd
                        aligtva-tmp.ecrln-prd-cd    = adbtva.ecrln-prd-cd
                        aligtva-tmp.ecrln-prd-num   = adbtva.ecrln-prd-num
                        aligtva-tmp.ecrln-piece-int = adbtva.ecrln-piece-int
                        aligtva-tmp.ecrln-lig       = adbtva.ecrln-lig
                        &ENDIF
                    .
                END.
            END.
            else for each aligtva no-lock
                where aligtva.soc-cd  = adbtva.soc-cd
                  and aligtva.etab-cd = adbtva.etab-cd
                  and aligtva.num-int = adbtva.num-int
                break by aligtva.cdrub by aligtva.cdlib:
                find first aligtva-tmp
                    where aligtva-tmp.Soc-cd = aligtva.soc-cd
                      and aligtva-tmp.Etab-cd = aligtva.etab-cd
                      and aligtva-tmp.CodeRub = aligtva.cdrub
                      and aligtva-tmp.CodeLib = aligtva.cdlib
                      and aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                      and aligtva-tmp.jou-cd = cecrln-enc.jou-cd
                      and aligtva-tmp.type-cle = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                      and aligtva-tmp.piece-int = cecrln-enc.piece-int
                      and aligtva-tmp.lig = cecrln-enc.lig no-error.
                &IF DEFINED(REPORT) &then release aligtva-tmp. &ENDIF /* DM 0809/0042 */
                if available aligtva-tmp then assign
                    aligtva-tmp.MtRub    = aligtva-tmp.MtRub + aligtva.mtht + aligtva.mttva
                    aligtva-tmp.MtRubTva = aligtva-tmp.MtRubTva + aligtva.mtTVa /* DM 0706/0055 */
                    aligtva-tmp.Sens     = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                    aligtva-tmp.MtEuro   = aligtva-tmp.MtEuro + (aligtva.mtht-euro + aligtva.mttva-euro)
                    aligtva-tmp.cmthono  = if cecrln-enc.cmthono <> ? then string(aligtva-tmp.MtRub * 100)
                                           else if aligtva.cmthono = ? then aligtva-tmp.cmthono
                                           else string(decimal(aligtva-tmp.cmthono) + decimal(aligtva.cmthono))
                .
                else do:
                    create aligtva-tmp.
                    buffer-copy cecrln-enc to aligtva-tmp
                    assign
                        aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                        aligtva-tmp.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                        aligtva-tmp.CodeRub    = aligtva.cdrub
                        aligtva-tmp.CodeLib    = aligtva.cdlib
                        aligtva-tmp.MtRub      = aligtva-tmp.MtRub + (aligtva.mtht + aligtva.mttva)
                        aligtva-tmp.MtRubTva   = aligtva-tmp.MtRubTva + (aligtva.mtTVa) /* DM 0706/0055 */
                        aligtva-tmp.Sens       = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                        aligtva-tmp.MtEuro     = aligtva-tmp.MtEuro + aligtva.mtht-euro + aligtva.mttva-euro
                        aligtva-tmp.cmthono    = if cecrln-enc.cmthono ne ? then string(aligtva-tmp.MtRub * 100)
                                                 else if aligtva.cmthono = ? then "0"
                                                 else aligtva.cmthono
                        aligtva-tmp.mois       = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                        &IF DEFINED(RLVPRO) &THEN
                        &ELSE
                        aligtva-tmp.ecrln-jou-cd    = adbtva.ecrln-jou-cd
                        aligtva-tmp.ecrln-prd-cd    = adbtva.ecrln-prd-cd
                        aligtva-tmp.ecrln-prd-num   = adbtva.ecrln-prd-num
                        aligtva-tmp.ecrln-piece-int = adbtva.ecrln-piece-int
                        aligtva-tmp.ecrln-lig       = adbtva.ecrln-lig
                        &ENDIF
                    .
                END.
            END.
        END.
        if can-find(first adbtva no-lock
                    where adbtva.soc-cd = cecrln-enc.soc-cd
                      and adbtva.etab-cd = cecrln-enc.etab-cd
                      and adbtva.jou-cd = cecrln-enc.jou-cd
                      and adbtva.prd-cd = cecrln-enc.prd-cd
                      and adbtva.prd-num = cecrln-enc.prd-num
                      and adbtva.piece-int = cecrln-enc.piece-int
                      and adbtva.lig = cecrln-enc.lig
                      and available cecrln
                      and (if goNouveauCrg:isNouveauCRGActif()
                           then (adbtva.lib-trt = ""   and vlReportEtExtract and cecrln-enc.dacompta >= tmp-dadeb - viNombreJourCRG
                            and cecrln-enc.dacompta <= tmp-dafin and vlVentilation
                             or (adbtva.lib-trt = "R"  and adbtva.date-trt >= &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF and adbtva.date-trt <= tmp-dafin)
                             or (adbtva.lib-trt = "AR" and (&IF DEFINED(REPORT) &then glSimulation &ELSE true &ENDIF)
                                  and not(tmp-dafin <= vdaTVA or tmp-dafin <= vdaIRF or tmp-dafin < vdaCRG or tmp-dafin < vdaHono)))
                            else true))
                      and (if cecrln-enc.sens then - cecrln-enc.mt else cecrln-enc.mt) - dMtAdbtva <> 0
        then DO:
            find first tache no-lock
                where tache.tpcon = {&TYPECONTRAT-bail}
                  and tache.nocon = integer(string(ietab.etab-cd, "99999") + csscpt.cpt-cd)
                  and tache.tptac = {&TYPETACHE-TVABail} no-error.
            IF AVAILABLE tache THEN DO: /* Bail commercial assujetti à TVA */
                ASSIGN
                    dMtEnc         = ((if cecrln-enc.sens then - cecrln-enc.mt     else cecrln-enc.mt)     - dMtAdbtva) / (1 + (vdeTauxBail / 100))
                    dMtEnc-Euro    = ((if cecrln-enc.sens then - cecrln-enc.mtEuro else cecrln-enc.mtEuro) - dMtAdbtva-Euro) / (1 + (vdeTauxBail / 100))
                    dMtEncTva      = (if cecrln-enc.sens then - cecrln-enc.mt     else cecrln-enc.mt)     - dMtAdbtva - dMtEnc
                    dMtEncTva-Euro = (if cecrln-enc.sens then - cecrln-enc.mtEuro else cecrln-enc.mtEuro) - dMtAdbtva-Euro - dMtEnc-Euro
                    /* Report de l'arrondi */
                    dMtEnc         = round(dMtEnc, 2)
                    dMtEncTva      = round(dMtEncTva, 2)
                    dMtEnc         = dMtEnc + (if cecrln-enc.sens then - cecrln-enc.mt else cecrln-enc.mt) - dMtAdbtva - (dMtEnc + dMtEncTva)
                .
                find first aligtva-tmp
                    where aligtva-tmp.Soc-cd     = cecrln-enc.soc-cd
                      and aligtva-tmp.Etab-cd    = cecrln-enc.etab-cd
                      and (string(aligtva-tmp.CodeRub) begins "77" or string(aligtva-tmp.CodeRub) begins "78")
                      and aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                      and aligtva-tmp.jou-cd     = cecrln-enc.jou-cd
                      and aligtva-tmp.type-cle   = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                      and aligtva-tmp.piece-int  = cecrln-enc.piece-int
                      and aligtva-tmp.lig        = cecrln-enc.lig no-error.
                &IF DEFINED(REPORT) &THEN RELEASE aligtva-tmp. &ENDIF /* DM 0809/0042 */
                if available aligtva-tmp then assign
                    aligtva-tmp.MtRub    = aligtva-tmp.MtRub + round(dMtEncTva, 2)
                    aligtva-tmp.MtRubTva = aligtva-tmp.MtRubTVa + round(dMtEncTva, 2) /* DM 0706/0055 */
                    aligtva-tmp.Sens     = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                    aligtva-tmp.MtEuro   = aligtva-tmp.MtEuro + round(dMtEncTva-Euro, 2)
                    aligtva-tmp.cmthono  = string(decimal(aligtva-tmp.cmthono) + (decimal(cecrln-enc.cmthono) * (if cecrln-enc.sens then -1 else 1)))
                .
                ELSE DO:
                    CREATE aligtva-tmp.
                    BUFFER-COPY cecrln-enc TO aligtva-tmp
                    assign
                        aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                        aligtva-tmp.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                        aligtva-tmp.CodeRub    = if cecrln-enc.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old
                        aligtva-tmp.CodeLib    = iCdLibTva
                        aligtva-tmp.MtRub      = aligtva-tmp.MtRub + round(dMtEncTva, 2)
                        aligtva-tmp.MtRubTva   = aligtva-tmp.MtRubTVa + round(dMtEncTva, 2) /* DM 0706/0055 */
                        aligtva-tmp.Sens       = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                        aligtva-tmp.MtEuro     = aligtva-tmp.MtEuro + round(dMtEncTva-Euro, 2)
                        aligtva-tmp.cmthono    = if cecrln-enc.cmthono = ? then "0" else string(decimal(cecrln-enc.cmthono) * (if cecrln-enc.sens then -1 else 1))
                        aligtva-tmp.mois       = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                        &IF DEFINED(RLVPRO) &THEN
                        &ELSE
                        aligtva-tmp.ecrln-jou-cd    = cecrln-enc.jou-cd
                        aligtva-tmp.ecrln-prd-cd    = cecrln-enc.prd-cd
                        aligtva-tmp.ecrln-prd-num   = cecrln-enc.prd-num
                        aligtva-tmp.ecrln-piece-int = cecrln-enc.piece-int
                        aligtva-tmp.ecrln-lig       = cecrln-enc.lig
                        &ENDIF
                    .
                end.
            end.
            else assign
                dMtEnc      = (if cecrln-enc.sens then - cecrln-enc.mt     else cecrln-enc.mt) - dMtadbtva
                dMtEnc-Euro = (if cecrln-enc.sens then - cecrln-enc.mtEuro else cecrln-enc.mtEuro) - dMtAdbtva-Euro
            .
            find first aligtva-tmp
                where aligtva-tmp.Soc-cd = cecrln-enc.soc-cd
                  and aligtva-tmp.Etab-cd = cecrln-enc.etab-cd
                  and string(aligtva-tmp.CodeRub) begins "1"
                  and aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                  and aligtva-tmp.jou-cd = cecrln-enc.jou-cd
                  and aligtva-tmp.type-cle = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                  and aligtva-tmp.piece-int = cecrln-enc.piece-int
                  and aligtva-tmp.lig = cecrln-enc.lig no-error.
            &IF DEFINED(REPORT) &then release aligtva-tmp. &ENDIF /* DM 0409/0037 */
            if available aligtva-tmp then assign
                aligtva-tmp.MtRub  = aligtva-tmp.MtRub + round(dMtEnc, 2)
                aligtva-tmp.Sens   = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                aligtva-tmp.MtEuro = aligtva-tmp.MtEuro + round(dMtEnc-Euro, 2)
                aligtva-tmp.cmthono = string(decimal(aligtva-tmp.cmthono) + (decimal(cecrln-enc.cmthono) * (if cecrln-enc.sens then -1 else 1)))
            .
            ELSE DO:
                CREATE aligtva-tmp.
                BUFFER-COPY cecrln-enc TO aligtva-tmp
                assign
                    aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                    aligtva-tmp.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                    aligtva-tmp.CodeRub    = iCdRub
                    aligtva-tmp.CodeLib    = iCdLib
                    aligtva-tmp.MtRub      = aligtva-tmp.MtRub + round(dMtEnc, 2)
                    aligtva-tmp.Sens       = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                    aligtva-tmp.MtEuro     = aligtva-tmp.MtEuro + round(dMtEnc-Euro, 2)
                    aligtva-tmp.cmthono    = if cecrln-enc.cmthono = ? then "0" else string(decimal(cecrln-enc.cmthono) * (if cecrln-enc.sens then -1 else 1))
                    aligtva-tmp.mois       = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                    &IF DEFINED(RLVPRO) &THEN
                    &ELSE
                    aligtva-tmp.ecrln-jou-cd    = cecrln-enc.jou-cd
                    aligtva-tmp.ecrln-prd-cd    = cecrln-enc.prd-cd
                    aligtva-tmp.ecrln-prd-num   = cecrln-enc.prd-num
                    aligtva-tmp.ecrln-piece-int = cecrln-enc.piece-int
                    aligtva-tmp.ecrln-lig       = cecrln-enc.lig
                    &ENDIF
                .
            end.
        end.
        else do:
            for each aecrdtva no-lock
                where aecrdtva.soc-cd    = cecrln-enc.soc-cd
                  and aecrdtva.etab-cd   = cecrln-enc.etab-cd
                  and aecrdtva.jou-cd    = cecrln-enc.jou-cd
                  and aecrdtva.prd-cd    = cecrln-enc.prd-cd
                  and aecrdtva.prd-num   = cecrln-enc.prd-num
                  and aecrdtva.piece-int = cecrln-enc.piece-int
                  and aecrdtva.lig       = cecrln-enc.lig:
                find first aligtva-tmp
                    where aligtva-tmp.Soc-cd = aecrdtva.soc-cd
                      and aligtva-tmp.Etab-cd = aecrdtva.etab-cd
                      and aligtva-tmp.CodeRub = aecrdtva.cdrub
                      and aligtva-tmp.CodeLib = aecrdtva.cdlib
                      and aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                      and aligtva-tmp.jou-cd = cecrln-enc.jou-cd
                      and aligtva-tmp.type-cle = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                      and aligtva-tmp.piece-int = cecrln-enc.piece-int
                      and aligtva-tmp.lig = cecrln-enc.lig no-error.
                &IF DEFINED(REPORT) &THEN RELEASE aligtva-tmp. &ENDIF /* DM 0809/0042 */
                if available aligtva-tmp then assign
                    aligtva-tmp.MtRub    = aligtva-tmp.MtRub - (aecrdtva.mtht + aecrdtva.mttva)
                    aligtva-tmp.MtRubTva = aligtva-tmp.MtRubTva - (aecrdtva.mttva) /* DM 0706/0055 */
                    aligtva-tmp.Sens     = (if aligtva-tmp.MtRub >= 0 then "+" else "-")
                    aligtva-tmp.MtEuro   = aligtva-tmp.MtEuro - (aecrdtva.mtht-euro + aecrdtva.mttva-euro)
                    aligtva-tmp.cmthono  = if cecrln-enc.cmthono ne ? then string(aligtva-tmp.MtRub * 100)
                                           else string(decimal(aligtva-tmp.cmthono) + decimal(aecrdtva.cmthono))
                .
                ELSE DO:
                    CREATE aligtva-tmp.
                    BUFFER-COPY cecrln-enc TO aligtva-tmp
                    assign
                        aligtva-tmp.DateCompta  = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                           aligtva-tmp.Compte   = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                           aligtva-tmp.CodeRub  = aecrdtva.cdrub
                           aligtva-tmp.CodeLib  = aecrdtva.cdlib
                           aligtva-tmp.MtRub    = aligtva-tmp.MtRub - (aecrdtva.mtht + aecrdtva.mttva)
                           aligtva-tmp.MtRubTva = aligtva-tmp.MtRubTva - (aecrdtva.mttva) /* DM 0706/0055 */
                           aligtva-tmp.Sens     = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                           aligtva-tmp.MtEuro   = aligtva-tmp.MtEuro - (aecrdtva.mtht-euro + aecrdtva.mttva-euro)
                           aligtva-tmp.cmthono  = if cecrln-enc.cmthono ne ? then string(aligtva-tmp.MtRub * 100)
                                                  else if aecrdtva.cmthono = ? then "0"
                                                  else aecrdtva.cmthono
                           aligtva-tmp.mois     = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                           &IF DEFINED(RLVPRO) &then &ELSE
                           aligtva-tmp.ecrln-jou-cd    = cecrln-enc.jou-cd
                           aligtva-tmp.ecrln-prd-cd    = cecrln-enc.prd-cd
                           aligtva-tmp.ecrln-prd-num   = cecrln-enc.prd-num
                           aligtva-tmp.ecrln-piece-int = cecrln-enc.piece-int
                           aligtva-tmp.ecrln-lig       = cecrln-enc.lig
                           &ENDIF
                       .
                end.
            end.
            if not can-find(first aecrdtva
                            where aecrdtva.soc-cd = cecrln-enc.soc-cd
                              and aecrdtva.etab-cd = cecrln-enc.etab-cd
                              and aecrdtva.jou-cd = cecrln-enc.jou-cd
                              and aecrdtva.prd-cd = cecrln-enc.prd-cd
                              and aecrdtva.prd-num = cecrln-enc.prd-num
                              and aecrdtva.piece-int = cecrln-enc.piece-int
                              and aecrdtva.lig = cecrln-enc.lig) then do:
                find first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = integer(string(ietab.etab-cd, "99999") + csscpt.cpt-cd)
                      and tache.tptac = {&TYPETACHE-TVABail} no-error.
                IF AVAILABLE tache THEN DO: /* Bail commercial assujetti à TVA */
                    ASSIGN
                        dMtEnc         = if cecrln-enc.sens = false then (cecrln-enc.mt / (1 + (vdeTauxBail  / 100)))
                                                            else (- cecrln-enc.mt / (1 + (vdeTauxBail  / 100)))
                        dMtEnc-Euro    = if cecrln-enc.sens = false then (cecrln-enc.mtEuro / (1 + (vdeTauxBail  / 100)))
                                         else (- cecrln-enc.mtEuro / (1 + (vdeTauxBail  / 100)))
                        dMtEncTva      = cecrln-enc.mt * (if cecrln-enc.sens then -1 else 1) - dMtEnc
                        dMtEncTva-Euro = cecrln-enc.mtEuro * (IF cecrln-enc.sens THEN -1 ELSE 1) - dMtEnc-Euro
                    /* Report de l'arrondi */
                        dMtEnc         = round(dMtEnc, 2)
                        dMtEncTva      = round(dMtEncTva, 2)
                    .
                    find first aligtva-tmp
                        where aligtva-tmp.Soc-cd = cecrln-enc.soc-cd
                          and aligtva-tmp.Etab-cd = cecrln-enc.etab-cd
                          and (string(aligtva-tmp.CodeRub) begins "77" or string(aligtva-tmp.CodeRub) begins "78")
                          and aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                          and aligtva-tmp.jou-cd = cecrln-enc.jou-cd
                          and aligtva-tmp.type-cle = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                          and aligtva-tmp.piece-int = cecrln-enc.piece-int
                          and aligtva-tmp.lig = cecrln-enc.lig no-error.
                    &IF DEFINED(REPORT) &THEN RELEASE aligtva-tmp. &ENDIF /* DM 0809/0042 */
                    if available aligtva-tmp then assign
                        aligtva-tmp.MtRub    = aligtva-tmp.MtRub    + round(dMtEncTva, 2)
                        aligtva-tmp.MtRubTva = aligtva-tmp.MtRubTva + round(dMtEncTva, 2) /* DM 0706/0055 */
                        aligtva-tmp.Sens     = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                        aligtva-tmp.MtEuro   = aligtva-tmp.MtEuro   + round(dMtEncTva-Euro, 2)
                    .
                    ELSE DO:
                        CREATE aligtva-tmp.
                        BUFFER-COPY cecrln-enc TO aligtva-tmp
                        ASSIGN
                            aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                            aligtva-tmp.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                            aligtva-tmp.CodeRub    = if cecrln-enc.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old
                            aligtva-tmp.CodeLib    = iCdLibTva
                            aligtva-tmp.MtRub      = aligtva-tmp.MtRub    + round(dMtEncTva, 2)
                            aligtva-tmp.MtRubTva   = aligtva-tmp.MtRubTva + round(dMtEncTva, 2) /* DM 0706/0055 */
                            aligtva-tmp.Sens       = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                            aligtva-tmp.MtEuro     = aligtva-tmp.MtEuro   + round(dMtEncTva-Euro, 2)
                            aligtva-tmp.cmthono    = if cecrln-enc.cmthono = ? then "0"
                                                     else string(decimal(cecrln-enc.cmthono) * (if cecrln-enc.sens then -1 else 1))
                            aligtva-tmp.mois       = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                            &IF DEFINED(RLVPRO) &then &ELSE
                            aligtva-tmp.ecrln-jou-cd    = cecrln-enc.jou-cd
                            aligtva-tmp.ecrln-prd-cd    = cecrln-enc.prd-cd
                            aligtva-tmp.ecrln-prd-num   = cecrln-enc.prd-num
                            aligtva-tmp.ecrln-piece-int = cecrln-enc.piece-int
                            aligtva-tmp.ecrln-lig       = cecrln-enc.lig
                            &ENDIF
                        .
                    end.
                    find first aligtva-tmp
                        where aligtva-tmp.Soc-cd     = cecrln-enc.soc-cd
                          and aligtva-tmp.Etab-cd    = cecrln-enc.etab-cd
                          and string(aligtva-tmp.CodeRub) begins "1"
                          and aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                          and aligtva-tmp.jou-cd     = cecrln-enc.jou-cd
                          and aligtva-tmp.type-cle   = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                          and aligtva-tmp.piece-int  = cecrln-enc.piece-int
                          and aligtva-tmp.lig        = cecrln-enc.lig no-error.
                    &IF DEFINED(REPORT) &then release aligtva-tmp. &ENDIF
                    if available aligtva-tmp then assign
                        aligtva-tmp.MtRub    = aligtva-tmp.MtRub + round(dMtEnc, 2)
                        aligtva-tmp.MtRubTva = 0
                        aligtva-tmp.Sens     = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                        aligtva-tmp.MtEuro   = aligtva-tmp.MtEuro + round(dMtEncTva-Euro, 2)
                    .
                    ELSE DO:
                        CREATE aligtva-tmp.
                        BUFFER-COPY cecrln-enc TO aligtva-tmp
                        assign
                            aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                            aligtva-tmp.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                            aligtva-tmp.CodeRub    = iCdRub
                            aligtva-tmp.CodeLib    = iCdLib
                            aligtva-tmp.MtRub      = aligtva-tmp.MtRub + round(dMtEnc, 2)
                            aligtva-tmp.MtRubTva   = 0
                            aligtva-tmp.Sens       = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                            aligtva-tmp.MtEuro     = aligtva-tmp.MtEuro + round(dMtEncTva-Euro, 2)
                            aligtva-tmp.cmthono    = if cecrln-enc.cmthono = ? then "0"
                                                     else string(decimal(cecrln-enc.cmthono) * (if cecrln-enc.sens then -1 else 1))
                            aligtva-tmp.mois       = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                            &IF DEFINED(RLVPRO) &THEN
                            &ELSE
                            aligtva-tmp.ecrln-jou-cd    = cecrln-enc.jou-cd
                            aligtva-tmp.ecrln-prd-cd    = cecrln-enc.prd-cd
                            aligtva-tmp.ecrln-prd-num   = cecrln-enc.prd-num
                            aligtva-tmp.ecrln-piece-int = cecrln-enc.piece-int
                            aligtva-tmp.ecrln-lig       = cecrln-enc.lig
                            &ENDIF
                        .
                    end.
                end.
                else do:
                    assign
                        dMtEnc      = if cecrln-enc.sens then - cecrln-enc.mt     else cecrln-enc.mt
                        dMtEnc-Euro = if cecrln-enc.sens then - cecrln-enc.mtEuro else cecrln-enc.mtEuro
                    .
                    find first aligtva-tmp
                        where aligtva-tmp.Soc-cd     = cecrln-enc.soc-cd
                          and aligtva-tmp.Etab-cd    = cecrln-enc.etab-cd
                          and string(aligtva-tmp.CodeRub) begins "1"
                          and aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                          and aligtva-tmp.jou-cd     = cecrln-enc.jou-cd
                          and aligtva-tmp.type-cle   = cecrln-enc.type-cle /**Ajout OF le 30/01/14 pour optimisation**/
                          and aligtva-tmp.piece-int  = cecrln-enc.piece-int
                          and aligtva-tmp.lig        = cecrln-enc.lig no-error.
                    &IF DEFINED(REPORT) &THEN RELEASE aligtva-tmp. &ENDIF /* DM 0409/0037 */
                    if available aligtva-tmp then assign
                        aligtva-tmp.MtRub   = aligtva-tmp.MtRub + round(dMtEnc, 2)
                        aligtva-tmp.Sens    = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                        aligtva-tmp.MtEuro  = aligtva-tmp.MtEuro + round(dMtEnc-Euro, 2)
                        aligtva-tmp.cmthono = string(decimal(aligtva-tmp.cmthono) + (decimal(cecrln-enc.cmthono) * (if cecrln-enc.sens then -1 else 1)))
                    .
                    ELSE DO:
                        CREATE aligtva-tmp.
                        BUFFER-COPY cecrln-enc TO aligtva-tmp
                        assign
                            aligtva-tmp.DateCompta = string(year(cecrln-enc.dacompta), "9999") + string(month(cecrln-enc.dacompta), "99") + string(day(cecrln-enc.dacompta), "99")
                            aligtva-tmp.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                            aligtva-tmp.CodeRub    = iCdRub
                            aligtva-tmp.CodeLib    = iCdLib
                            aligtva-tmp.MtRub      = aligtva-tmp.MtRub + round(dMtEnc, 2)
                            aligtva-tmp.Sens       = if aligtva-tmp.MtRub >= 0 then "+" else "-"
                            aligtva-tmp.MtEuro     = aligtva-tmp.MtEuro + round(dMtEnc-Euro, 2)
                            aligtva-tmp.cmthono    = if cecrln-enc.cmthono = ? then "0"
                                                     else string(decimal(cecrln-enc.cmthono) * (if cecrln-enc.sens then -1 else 1))
                            aligtva-tmp.mois       = year(cecrln-enc.dacompta) * 100 + month(cecrln-enc.dacompta)
                            &IF DEFINED(RLVPRO) &THEN
                            &ELSE
                            aligtva-tmp.ecrln-jou-cd    = cecrln-enc.jou-cd
                            aligtva-tmp.ecrln-prd-cd    = cecrln-enc.prd-cd
                            aligtva-tmp.ecrln-prd-num   = cecrln-enc.prd-num
                            aligtva-tmp.ecrln-piece-int = cecrln-enc.piece-int
                            aligtva-tmp.ecrln-lig       = cecrln-enc.lig
                            &ENDIF
                       .
                    end.
                end.
            end.
        END.
    end.
    if VlRBHO then for each aligtva-tmp
        where aligtva-tmp.soc-cd  = ietab.soc-cd /**Ajout soc-cd par OF le 30/01/14 pour optimisation**/
          and aligtva-tmp.etab-cd = ietab.etab-cd
          and aligtva-tmp.MtRub = 0
          and (decimal(aligtva-tmp.cmthono) = 0 or aligtva-tmp.cmthono = ?):
        delete aligtva-tmp.
    end.
    else for each aligtva-tmp
        where aligtva-tmp.soc-cd  = ietab.soc-cd /**Ajout soc-cd par OF le 30/01/14 pour optimisation**/
          and aligtva-tmp.etab-cd = ietab.etab-cd
          and aligtva-tmp.MtRub = 0:
        delete aligtva-tmp.
    end.
END PROCEDURE.

PROCEDURE creation-impaye:
    /*-------------------------------------------------------------------------
    Purpose :
    notes :
    -------------------------------------------------------------------------*/
    define variable vdaDebutExercice as date no-undo.
    define buffer iprd   for iprd.
    define buffer vbIprd for iprd.

    if not VlRBHO then empty temp-table impaye.
    /*DATE DEBUT DE L'EXERCICE PAR RAPPORT A LA DATE DE DEBUT DE L'EXTRACTION */
    vdaDebutExercice = (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1).
    &IF DEFINED(REPORT) &THEN
    if glExtractCRG then do:
        find first iprd no-lock
            where iprd.soc-cd   = ietab.soc-cd
              and iprd.etab-cd  = ietab.etab-cd
              and iprd.dadebprd <= tmp-dadeb
              and iprd.dafinprd >= tmp-dadeb no-error.
        find first vbIprd no-lock
            where vbIprd.soc-cd  = ietab.soc-cd
              and vbIprd.etab-cd = ietab.etab-cd
              and vbIprd.prd-cd  = iprd.prd-cd no-error.
        if available vbIprd then vdaDebutExercice = vbIprd.dadebprd.
    END.
    &ENDIF
    if vdaDebutExercice > tmp-dadeb
    then for first iprd no-lock
        where iprd.soc-cd   = ietab.soc-cd
          and iprd.etab-cd  = ietab.etab-cd
          and iprd.dadebprd = tmp-dadeb
      , first vbIprd no-lock
        where vbIprd.soc-cd  = ietab.soc-cd
          and vbIprd.etab-cd = ietab.etab-cd
          and vbIprd.prd-cd  = iprd.prd-cd:
        vdaDebutExercice = vbIprd.dadebprd.
    END.
    if vdaDebutExercice <> tmp-dadeb
    then run impayes_Debut_Exercice(input vdaDebutExercice).  /* LISTE DES IMPAYES DU DEBUT DE L'EXERCICE A LA DATE DE DEBUT DE L'EXTRACTION */
    else run impayes_Anouveaux(input vdaDebutExercice).       /* LISTE DES IMPAYES AU DEBUT DE L'EXERCICE : ANOUVEAUX */
    for each impaye where impaye.MtRub = 0:
        DELETE impaye.
    END.

END PROCEDURE.

PROCEDURE RCLOC:
    /*-------------------------------------------------------------------------
    Purpose :
    notes :
    -------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER NoLocUse-In AS INTEGER NO-UNDO.
    define input parameter DtCptUse-In as date    no-undo.

    define variable iCpt                 as integer   no-undo.
    DEFINE VARIABLE ListeRubqtTVA-Toutes AS CHARACTER NO-UNDO.

    ASSIGN
        ListeRubqtTVA-Toutes = substitute("&1,&2,&3,&4,&5", {&ListeRubqtTVA-Variable}, {&ListeRubqtTVA-RappelAvoir},
                                         {&ListeRubqtTVA-Calcul}, {&ListeRubqtTVAService-Calcul}, {&ListeRubqtTVAHono-Calcul})
        iCdRub    = 0
        iCdLib    = 0
        iCdRubTVA = 0
        iCdLibTVA = 0
    .
    find first aquit no-lock
        where aquit.noloc = NoLocUse-IN
          and aquit.msqtt = (integer(string(year(DtCptUse-IN), "9999") + string(month(DtCptUse-In), "99"))) no-error.
    if not available aquit
    then find last aquit no-lock
        where aquit.noloc = NoLocUse-IN    /* Modif OF le 05/08/14 */
        use-index ix_aquit03 no-error.     /* DM #1415 - noloc, msqtt */
    /* DM 0409/0037 Determination de la rubrique par défaut pour etat excel */
    IF AVAILABLE aquit THEN DO:
        DO iCpt = 1 TO EXTENT(aquit.tbrub):
            IF aquit.tbrub[iCpt] BEGINS "1" THEN DO:
                ASSIGN
                    iCdRub = integer(entry(1, aquit.tbrub[iCpt], "|"))
                    iCdLib = integer(entry(2, aquit.tbrub[iCpt], "|"))
                .
                LEAVE.
            END.
        END.
        if iCdRub = 0 then assign
            iCdRub = 101
            iCdLib = 01
        .
        /*Recherche de la rubrique de TVA*/
        DO iCpt = 1 TO EXTENT(aquit.tbrub):
            if lookup(entry(1, aquit.tbrub[iCpt], "|"), ListeRubqtTVA-Toutes) > 0
            THEN DO:
                ASSIGN
                    iCdRubTVA = integer(entry(1, aquit.tbrub[iCpt], "|"))
                    iCdLibTVA = integer(entry(2, aquit.tbrub[iCpt], "|"))
                .
                LEAVE.
            END.
        END.
    END.
    else assign
        iCdRub        = 101
        iCdLib        = 01
        iCdRubTva     = 778
        iCdRubTva-old = 776
        iCdLibTva     = 01
    .
    if iCdRub = 0 then assign
        iCdRub = 101
        iCdLib = 01
    .
    if iCdRubTVA = 0 then assign
        iCdRubTva     = 778
        iCdRubTva-old = 776
        iCdLibTva     = 01
    .
END PROCEDURE.

PROCEDURE Impayes_Debut_Exercice :
    /*------------------------------------------------------------------------------
    purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pdaDebutExercice as date no-undo.

    define variable viNombreJourCRG   as integer   no-undo. /* DM 0113/0150 */
    define variable vcParametre       as character no-undo. /* DM 0508/0177 */
    define variable viNumeroInterne   as integer   no-undo. /* DM 0209/0071 */
    define variable vdeTauxBail       as decimal   no-undo. /* DM 0211/0063 */
    // todo   introduire une variable pour simplifier le can-find !!!
    define variable vlReportEtExtract as logical   no-undo.
    define buffer cecrln   for cecrln.
    define buffer cecrsai  for cecrsai.
    define buffer aecrdtva for aecrdtva.
    define buffer adbtva   for adbtva.
    define buffer tache    for tache.

    assign
        viNombreJourCRG = (&IF DEFINED(REPORT)   &then IF glExtractCRG then 1 ELSE 0 &ELSE 0 &ENDIF)
        vdeTauxBail     = dynamic-function("getTauxTvaBail" in ghOutilsTva, integer(string(csscpt.etab-cd) + csscpt.cpt-cd))
    .
    /* Date des derniers traitements effectués */
    run datetrt(piCodesoc, ietab.etab-cd, tmp-dafin, vcParametre). // dans datetrt.i
    run RCLOC(integer(string(ietab.etab-cd) + csscpt.cpt-cd), pdaDebutExercice).  /**Ajout OF le 22/09/09**/
    dSoldeL = 0.
    for each cecrln no-lock
        where cecrln.soc-cd     = mtoken:iCodeSociete
          and cecrln.etab-cd    = ietab.etab-cd
          and cecrln.sscoll-cle = csscpt.sscoll-cle
          and cecrln.cpt-cd     = csscpt.cpt-cd
          &IF DEFINED(REPORT) &THEN
          and (glExtractCRG
            or (cecrln.flag-lettre = false or (cecrln.flag-lettre = true and cecrln.dalettrage >= tmp-dadeb)))
          &ENDIF
          and cecrln.dacompta   < tmp-dadeb + viNombreJourCRG
          and cecrln.dacompta   >= pdaDebutExercice:
        assign
            vlReportEtExtract = &IF DEFINED(REPORT)
                                &then if glExtractCRG
                                then not can-find(first ahistcrg
                                                  where ahistcrg.soc-cd = cecrln.soc-cd
                                                    and ahistcrg.etab-cd = cecrln.etab-cd
                                                    and ahistcrg.num-crg = absolute(cecrln.num-crg)
                                                    and ahistcrg.dtdeb >= tmp-dadeb
                                                    and ahistcrg.dtfin <= tmp-dafin)
                                else true
                                &ELSE true
                                &ENDIF
        .
        &IF DEFINED(REPORT) &THEN
        if glExtractCRG then do: /* Filtrer les écritures du jour de début de crg */
            if cecrln.num-crg <> 0 then do:
                find first ahistcrg no-lock
                where ahistcrg.soc-cd  = cecrln.soc-cd
                  and ahistcrg.etab-cd = cecrln.etab-cd
                  and ahistcrg.num-crg = absolute(cecrln.num-crg)
                  and ahistcrg.dtdeb  >= tmp-dadeb
                  and ahistcrg.dtfin  <= tmp-dafin no-error.
                if available ahistcrg then next.
            end.
        end.
        &ENDIF
        /* DM 0809/0042 */
        find first cecrsai no-lock
            where cecrsai.soc-cd    = cecrln.soc-cd
              and cecrsai.etab-cd   = cecrln.mandat-cd
              and cecrsai.jou-cd    = cecrln.jou-cd
              and cecrsai.prd-cd    = cecrln.mandat-prd-cd
              and cecrsai.prd-num   = cecrln.mandat-prd-num
              and cecrsai.piece-int = cecrln.piece-int no-error.
        empty temp-table adbtva-tmp.
        dSoldeL = dSoldeL + (if cecrln.sens then cecrln.mt else - cecrln.mt).
        for each aecrdtva no-lock
            where aecrdtva.soc-cd    = cecrln.soc-cd
              and aecrdtva.etab-cd   = cecrln.etab-cd
              and aecrdtva.jou-cd    = cecrln.jou-cd
              and aecrdtva.prd-cd    = cecrln.prd-cd
              and aecrdtva.prd-num   = cecrln.prd-num
              and aecrdtva.piece-int = cecrln.piece-int
              and aecrdtva.lig       = cecrln.lig:
            find first impaye
                where impaye.Soc-cd  = aecrdtva.soc-cd
                  and impaye.Etab-cd = aecrdtva.etab-cd
                  and impaye.CodeRub = aecrdtva.cdrub
                  &IF DEFINED(REPORT) &THEN
                  and impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                  and impaye.lib-ecr[1] = cecrln.lib-ecr[1]
                  and impaye.Dacompta   = cecrln.dacompta
                  &ENDIF
                  and impaye.CodeLib = aecrdtva.cdlib no-error.
            /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
            &IF DEFINED(REPORT) &THEN
                release impaye.
            &ENDIF
            if available impaye then assign
                impaye.MtRub    = impaye.MtRub + aecrdtva.mtht + aecrdtva.mttva
                impaye.MtRubTva = impaye.MtRubTva + aecrdtva.mttva /* DM 1106/0030 Dont TVA */
                impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                impaye.MtEuro   = impaye.MtEuro + aecrdtva.mtht-euro + aecrdtva.mttva-euro
            .
            else do:
                create impaye.
                buffer-copy cecrln to impaye
                ASSIGN
                    impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                    impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                    impaye.CodeRub    = aecrdtva.cdrub
                    impaye.CodeLib    = aecrdtva.cdlib
                    impaye.MtRub      = impaye.MtRub + (aecrdtva.mtht + aecrdtva.mttva)
                    impaye.MtRubTva   = impaye.MtRubTva + (aecrdtva.mttva) /* DM 1106/0030 Dont TVA */
                    impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                    impaye.MtEuro     = impaye.MtEuro + (aecrdtva.mtht-euro + aecrdtva.mttva-euro)
                .
                if available cecrsai and cecrsai.natjou-cd = 9 then assign /* pour rechercher la periodicite dans faedetq.w */
                    impaye.ecrln-jou-cd    = cecrsai.jou-cd
                    impaye.ecrln-prd-cd    = cecrsai.prd-cd
                    impaye.ecrln-prd-num   = cecrsai.prd-num
                    impaye.ecrln-piece-int = cecrsai.piece-int
                    impaye.ecrln-lig       = cecrln.lig
                .
                else impaye.fg-quit = true.
            end.
        end.
        if not can-find(first aecrdtva no-lock
                        where aecrdtva.soc-cd    = cecrln.soc-cd 
                          and aecrdtva.etab-cd   = cecrln.etab-cd 
                          and aecrdtva.jou-cd    = cecrln.jou-cd 
                          and aecrdtva.prd-cd    = cecrln.prd-cd 
                          and aecrdtva.prd-num   = cecrln.prd-num 
                          and aecrdtva.piece-int = cecrln.piece-int 
                          and aecrdtva.lig       = cecrln.lig)
        then do:
            assign
                dMtAdbtva      = 0
                dMtAdbtva-Euro = 0
                viNumeroInterne = 0
            .
            /* DM 0209/0071 recherche de la derniere ventilation + */
            for each adbtva no-lock
                where adbtva.soc-cd = cecrln.soc-cd
                  and adbtva.etab-cd = cecrln.etab-cd
                  and adbtva.jou-cd = cecrln.jou-cd
                  and adbtva.prd-cd = cecrln.prd-cd
                  and adbtva.prd-num = cecrln.prd-num
                  and adbtva.piece-int = cecrln.piece-int
                  and adbtva.lig = cecrln.lig
                  and (if goNouveauCrg:isNouveauCRGActif()
                    then (adbtva.lib-trt = "" and vlReportEtExtract
                      or (adbtva.lib-trt = "R" and adbtva.date-trt < &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF))
                    else true)
                 BY adbtva.date_decla descending by adbtva.num-int descending:
                 if adbtva.reactiv = true then leave.
                 viNumeroInterne = adbtva.num-int.
                 leave.
            end.
            for each adbtva no-lock
                where adbtva.soc-cd = cecrln.soc-cd
                  and adbtva.etab-cd = cecrln.etab-cd
                  and adbtva.jou-cd = cecrln.jou-cd
                  and adbtva.prd-cd = cecrln.prd-cd
                  and adbtva.prd-num = cecrln.prd-num
                  and adbtva.piece-int = cecrln.piece-int
                  and adbtva.lig = cecrln.lig
                  &IF DEFINED(REPORT) &then &ELSE
                  and adbtva.num-int >= viNumeroInterne
                  &ENDIF
                  and (if goNouveauCrg:isNouveauCRGActif()
                       then (adbtva.lib-trt = "" and vlReportEtExtract
                         or (adbtva.lib-trt = "R" and adbtva.date-trt < &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF))
                       else true)
                  break by adbtva.date_decla:
                create adbtva-tmp.
                buffer-copy adbtva to adbtva-tmp.
                if last(adbtva.date_decla) then tmp-date = adbtva.date_decla.
            end.
            for each adbtva-tmp
                where &IF DEFINED(REPORT) &then &ELSE adbtva-tmp.date_decla = tmp-date &ENDIF:
                assign
                    dMtAdbtva      = dMtAdbtva      + adbtva-tmp.mt
                    dMtAdbtva-Euro = dMtAdbtva-Euro + adbtva-tmp.mt-euro
                .
                if not can-find(first aligtva no-lock
                                where aligtva.soc-cd = adbtva-tmp.soc-cd
                                  and aligtva.etab-cd = adbtva-tmp.etab-cd
                                  and aligtva.num-int = adbtva-tmp.num-int) then do:
                    find first tache no-lock
                        where tache.tpcon = {&TYPECONTRAT-bail}
                          and tache.nocon = integer(string(ietab.etab-cd, "99999") + csscpt.cpt-cd)
                          and tache.tptac = {&TYPETACHE-TVABail} no-error.
                    if available tache then do: /* Bail commercial assujetti à TVA */
                        assign
                            dMtRegl         = (- adbtva-tmp.mt) / (1 + (vdeTauxBail / 100))
                            dMtRegl-Euro    = (- adbtva-tmp.mt-euro) / (1 + (vdeTauxBail / 100))
                            dMtReglTva      = (- adbtva-tmp.mt) - dMtRegl
                            dMtReglTva-Euro = (- adbtva-tmp.mt-euro) - dMtRegl-euro
                            /* Report de l'arrondi */
                            dMtRegl         = round(dMtRegl, 2)
                            dMtReglTva      = round(dMtReglTva, 2)
                            dMtRegl         = dMtRegl + (- adbtva-tmp.mt - (dMtRegl + dMtReglTva))
                        .
                        find first impaye
                            where impaye.Soc-cd = adbtva-tmp.soc-cd
                              and impaye.Etab-cd = adbtva-tmp.etab-cd
                              &IF DEFINED(REPORT) &THEN
                              and impaye.Compte   = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                              and impaye.lettre   = cecrln.lettre
                              and impaye.Dacompta = cecrln.dacompta
                              &ENDIF
                              and (string(impaye.CodeRub) begins "77" or string(impaye.CodeRub) begins "78") no-error.
                        /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                        &IF DEFINED(REPORT) &then release impaye. &ENDIF
                        if available impaye then assign
                            impaye.MtRub    = impaye.MtRub + round(dMtReglTva, 2)
                            impaye.MtRubTva = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 Dont TVA */
                            impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                            impaye.MtEuro   = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                        .
                        ELSE DO:
                            CREATE impaye.
                            BUFFER-COPY cecrln TO impaye
                            ASSIGN
                                impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                                impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                                impaye.CodeRub    = if cecrln.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old
                                impaye.CodeLib    = iCdLibTva
                                impaye.MtRub      = impaye.MtRub + round(dMtReglTva, 2)
                                impaye.MtRubTva   = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 Dont TVA */
                                impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                                impaye.MtEuro     = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                                /* DM 0809/0042 */
                                impaye.ecrln-jou-cd    = adbtva-tmp.ecrln-jou-cd
                                impaye.ecrln-prd-cd    = adbtva-tmp.ecrln-prd-cd
                                impaye.ecrln-prd-num   = adbtva-tmp.ecrln-prd-num
                                impaye.ecrln-piece-int = adbtva-tmp.ecrln-piece-int
                                impaye.ecrln-lig       = adbtva-tmp.ecrln-lig
                            .
                        end.
                    end.
                    else assign
                        dMtRegl = - adbtva-tmp.mt
                        dMtRegl-Euro = - adbtva-tmp.mt-euro.
                    .
                    find first impaye
                        where impaye.Soc-cd = adbtva-tmp.soc-cd
                          and impaye.Etab-cd = adbtva-tmp.etab-cd
                          &IF DEFINED(REPORT) &THEN
                          and impaye.Compte    = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                          and impaye.lettre   = cecrln.lettre
                          and impaye.Dacompta = cecrln.dacompta
                          &ENDIF
                          and string(impaye.CodeRub) begins "1" no-error.
                    &IF DEFINED(REPORT) &then release impaye. &ENDIF /* DM 0409/0037 */
                    if available impaye then assign
                        impaye.MtRub  = impaye.MtRub + round(dMtRegl, 2)
                        impaye.Sens   = if impaye.MtRub >= 0 then "+" else "-"
                        impaye.MtEuro = impaye.MtEuro + round(dMtRegl-Euro, 2)
                    .
                    ELSE DO:
                        create impaye.
                        buffer-copy cecrln to impaye
                        assign
                            impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                            impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                            impaye.CodeRub    = iCdRub
                            impaye.CodeLib    = iCdLib
                            impaye.MtRub      = impaye.MtRub + round(dMtRegl, 2)
                            impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                            impaye.MtEuro     = impaye.MtEuro + round(dMtRegl-Euro, 2)
                            /* DM 0809/0042 */
                            impaye.ecrln-jou-cd    = adbtva-tmp.ecrln-jou-cd
                            impaye.ecrln-prd-cd    = adbtva-tmp.ecrln-prd-cd
                            impaye.ecrln-prd-num   = adbtva-tmp.ecrln-prd-num
                            impaye.ecrln-piece-int = adbtva-tmp.ecrln-piece-int
                            impaye.ecrln-lig       = adbtva-tmp.ecrln-lig
                        .
                    end.
                end.
                else do:
                    for each aligtva no-lock
                        where aligtva.soc-cd = adbtva-tmp.soc-cd
                          and aligtva.etab-cd = adbtva-tmp.etab-cd
                          and aligtva.num-int = adbtva-tmp.num-int:
                        find first impaye
                            where impaye.Soc-cd = aligtva.soc-cd
                              and impaye.Etab-cd = aligtva.etab-cd
                              and impaye.CodeRub = aligtva.cdrub
                              &IF DEFINED(REPORT) &THEN
                              and impaye.Compte   = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                              and impaye.lettre   = cecrln.lettre
                              and impaye.Dacompta = cecrln.dacompta
                              &ENDIF
                              and impaye.CodeLib = aligtva.cdlib no-error.
                        /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                        &IF DEFINED(REPORT) &then release impaye. &ENDIF
                        if available impaye then assign
                            impaye.MtRub    = impaye.MtRub - (aligtva.mtht + aligtva.mttva)
                            impaye.MtRubTva = impaye.MtRubTva - aligtva.mttva
                            impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                            impaye.MtEuro   = impaye.MtEuro - (aligtva.mtht-euro + aligtva.mttva-euro)
                        .
                        ELSE DO:
                            CREATE impaye.
                            BUFFER-COPY cecrln TO impaye
                            ASSIGN
                                impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                                impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                                impaye.CodeRub    = aligtva.cdrub
                                impaye.CodeLib    = aligtva.cdlib
                                impaye.MtRub      = impaye.MtRub - (aligtva.mtht + aligtva.mttva)
                                impaye.MtRubTva   = impaye.MtRubTva - (aligtva.mttva) /* DM 1106/0030 */
                                impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                                impaye.MtEuro     = impaye.MtEuro - (aligtva.mtht-euro + aligtva.mttva-euro)
                                /* DM 0809/0042 */
                                impaye.ecrln-jou-cd    = adbtva-tmp.ecrln-jou-cd
                                impaye.ecrln-prd-cd    = adbtva-tmp.ecrln-prd-cd
                                impaye.ecrln-prd-num   = adbtva-tmp.ecrln-prd-num
                                impaye.ecrln-piece-int = adbtva-tmp.ecrln-piece-int
                                impaye.ecrln-lig       = adbtva-tmp.ecrln-lig
                            .
                        end.
                    end.
                END.
            end.
            if can-find(first adbtva-tmp
                        where adbtva-tmp.soc-cd = cecrln.soc-cd
                          and adbtva-tmp.etab-cd = cecrln.etab-cd
                          and adbtva-tmp.jou-cd = cecrln.jou-cd
                          and adbtva-tmp.prd-cd = cecrln.prd-cd
                          and adbtva-tmp.prd-num = cecrln.prd-num
                          and adbtva-tmp.piece-int = cecrln.piece-int
                          and adbtva-tmp.lig = cecrln.lig)
            and (cecrln.mt * (if cecrln.sens then -1 else 1)) - dMtAdbtva <> 0
            THEN DO:
                find first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = integer(string(ietab.etab-cd,/* DM 0608/0065 "9999" */ "99999") + csscpt.cpt-cd)
                      and tache.tptac = {&TYPETACHE-TVABail} no-error.
                IF AVAILABLE tache THEN DO: /* Bail commercial assujetti à TVA */
                    assign
                        dMtRegl         = (- ((((if cecrln.sens then -1 else 1) * cecrln.mt) - dMtAdbtva) / (1 + (vdeTauxBail / 100))))
                        dMtRegl-Euro    = (- ((((if cecrln.sens then -1 else 1) * cecrln.mt-euro) - dMtAdbtva-euro) / (1 + (vdeTauxBail / 100))))
                        dMtReglTva      = (- ((((if cecrln.sens then -1 else 1) * cecrln.mt) - dMtAdbtva))) - dMtRegl
                        dMtReglTva-Euro = (- ((((if cecrln.sens then -1 else 1) * cecrln.mt-euro) - dMtAdbtva-euro))) - dMtRegl-euro
                        /* Report de l'arrondi */
                        dMtRegl    = round(dMtRegl, 2)
                        dMtReglTva = round(dMtReglTva, 2)
                        dMtRegl    = dMtRegl + (- ((((if cecrln.sens then -1 else 1) * cecrln.mt) - dMtAdbtva))) - (dMtRegl + dMtReglTva)
                    .
                    find first impaye
                        where impaye.Soc-cd = cecrln.soc-cd
                          and impaye.Etab-cd = cecrln.etab-cd
                          &IF DEFINED(REPORT) &THEN
                          and impaye.Compte   = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                          and impaye.lettre   = cecrln.lettre
                          and impaye.Dacompta = cecrln.dacompta
                          &ENDIF
                          and (string(impaye.CodeRub) begins "77" or string(impaye.CodeRub) begins "78") no-error.
                    /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                    &IF DEFINED(REPORT) &then release impaye. &ENDIF
                    if available impaye then assign
                        impaye.MtRub    = impaye.MtRub + round(dMtReglTva, 2)
                        impaye.MtRubTva = impaye.MtRubTVa + round(dMtReglTva, 2) /* DM 1106/0030 */
                        impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                        impaye.MtEuro   = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                    .
                    ELSE DO:
                        CREATE impaye.
                        BUFFER-COPY cecrln TO impaye
                        ASSIGN
                            impaye.DateCompta      = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                            impaye.Compte          = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                            impaye.CodeRub         = if cecrln.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old
                            impaye.CodeLib         = iCdLibTva
                            impaye.MtRub           = impaye.MtRub + round(dMtReglTva, 2)
                            impaye.MtRubTva        = impaye.MtRubTVa + round(dMtReglTva, 2) /* DM 1106/0030 */
                            impaye.Sens            = if impaye.MtRub >= 0 then "+" else "-"
                            impaye.MtEuro          = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                            impaye.ecrln-jou-cd    = cecrln.jou-cd
                            impaye.ecrln-prd-cd    = cecrln.prd-cd
                            impaye.ecrln-prd-num   = cecrln.prd-num
                            impaye.ecrln-piece-int = cecrln.piece-int
                            impaye.ecrln-lig       = cecrln.lig
                        .
                    end.
                END.
                else assign
                    dMtRegl      = - ((cecrln.mt * (if cecrln.sens then -1 else 1)) - dMtAdbtva)
                    dMtRegl-Euro = - ((cecrln.mt-euro * (if cecrln.sens then -1 else 1)) - dMtAdbtva-euro)
                .
                find first impaye
                    where impaye.Soc-cd = cecrln.soc-cd
                      and impaye.Etab-cd = cecrln.etab-cd
                      &IF DEFINED(REPORT) &THEN
                      and impaye.Compte   = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                      and impaye.lettre   = cecrln.lettre
                      and impaye.Dacompta = cecrln.dacompta
                      &ENDIF
                      and string(impaye.CodeRub) begins "1" no-error.
                &IF DEFINED(REPORT) &THEN RELEASE impaye. &ENDIF /* DM 0409/0037 */
                if available impaye then assign
                    impaye.MtRub  = impaye.MtRub + round(dMtRegl, 2)
                    impaye.Sens   = if impaye.MtRub >= 0 then "+" else "-"
                    impaye.MtEuro = impaye.MtEuro + round(dMtRegl-Euro, 2)
                .
                else do:
                    create impaye.
                    buffer-copy cecrln to impaye
                    ASSIGN
                        impaye.DateCompta      = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                        impaye.Compte          = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                        impaye.CodeRub         = iCdRub
                        impaye.CodeLib         = iCdLib
                        impaye.MtRub           = impaye.MtRub + round(dMtRegl, 2)
                        impaye.Sens            = if impaye.MtRub >= 0 then "+" else "-"
                        impaye.MtEuro          = impaye.MtEuro + round(dMtRegl-Euro, 2)
                        impaye.ecrln-jou-cd    = cecrln.jou-cd
                        impaye.ecrln-prd-cd    = cecrln.prd-cd
                        impaye.ecrln-prd-num   = cecrln.prd-num
                        impaye.ecrln-piece-int = cecrln.piece-int
                        impaye.ecrln-lig       = cecrln.lig
                    .
                end.
            end.
        end.
        if not can-find(first adbtva no-lock
                        where adbtva.soc-cd = cecrln.soc-cd
                          and adbtva.etab-cd = cecrln.etab-cd
                          and adbtva.jou-cd = cecrln.jou-cd
                          and adbtva.prd-cd = cecrln.prd-cd
                          and adbtva.prd-num = cecrln.prd-num
                          and adbtva.piece-int = cecrln.piece-int
                          and adbtva.lig = cecrln.lig
                          and (if goNouveauCrg:isNouveauCRGActif()
                               then adbtva.lib-trt = "" and vlReportEtExtract
                                or (adbtva.lib-trt = "R" and adbtva.date-trt < &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF)
                               else true))
          and not can-find(first aecrdtva no-lock
                           where aecrdtva.soc-cd = cecrln.soc-cd
                             and aecrdtva.etab-cd = cecrln.etab-cd
                             and aecrdtva.jou-cd = cecrln.jou-cd
                             and aecrdtva.prd-cd = cecrln.prd-cd
                             and aecrdtva.prd-num = cecrln.prd-num
                             and aecrdtva.piece-int = cecrln.piece-int
                             and aecrdtva.lig = cecrln.lig)
        then DO:
            find first tache no-lock
                where tache.tpcon = {&TYPECONTRAT-bail}
                  and tache.nocon = integer(string(ietab.etab-cd, "99999") + csscpt.cpt-cd)
                  and tache.tptac = {&TYPETACHE-TVABail} no-error.
            if available tache then do: /* Bail commercial assujetti à TVA */
                assign
                    dMtRegl         = ((if cecrln.sens then 1 else -1) * cecrln.mt) / (1 + ((vdeTauxBail) / 100))
                    dMtRegl-Euro    = ((if cecrln.sens then 1 else -1) * cecrln.mt-euro) / (1 + ((vdeTauxBail) / 100))
                    dMtReglTva      = ((if cecrln.sens then 1 else -1) * cecrln.mt) - dMtRegl
                    dMtReglTva-Euro = ((if cecrln.sens then 1 else -1) * cecrln.mt-euro) - dMtRegl-euro
                    /* Report de l'arrondi */
                    dMtRegl         = round(dMtRegl, 2)
                    dMtReglTva      = round(dMtReglTva, 2)
                    dMtRegl         = dMtRegl + (((if cecrln.sens then 1 else -1) * cecrln.mt) - (dMtRegl + dMtReglTva))
                .
                find first impaye
                    where impaye.Soc-cd = cecrln.soc-cd
                      and impaye.Etab-cd = cecrln.etab-cd
                      &IF DEFINED(REPORT) &THEN
                      and impaye.Compte   = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                      and impaye.lettre   = cecrln.lettre
                      and impaye.Dacompta = cecrln.dacompta
                      &ENDIF
                      and (string(impaye.CodeRub) begins "77" or string(impaye.CodeRub) begins "78") no-error.
                /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                &IF DEFINED(REPORT) &then release impaye. &ENDIF
                if available impaye then assign
                    impaye.MtRub    = impaye.MtRub    + round(dMtReglTva, 2)
                    impaye.MtRubTva = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 */
                    impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                    impaye.MtEuro   = impaye.MtEuro   + round(dMtReglTva-Euro, 2)
                .
                ELSE DO:
                    CREATE impaye.
                    BUFFER-COPY cecrln TO impaye
                    ASSIGN
                        impaye.DateCompta      = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                        impaye.Compte          = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                        impaye.CodeRub         = if cecrln.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old
                        impaye.CodeLib         = iCdLibTva
                        impaye.MtRub           = impaye.MtRub    + round(dMtReglTva, 2)
                        impaye.MtRubTva        = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 */
                        impaye.Sens            = if impaye.MtRub >= 0 then "+" else "-"
                        impaye.MtEuro          = impaye.MtEuro   + round(dMtReglTva-Euro, 2)
                        impaye.ecrln-jou-cd    = cecrln.jou-cd
                        impaye.ecrln-prd-cd    = cecrln.prd-cd
                        impaye.ecrln-prd-num   = cecrln.prd-num
                        impaye.ecrln-piece-int = cecrln.piece-int
                        impaye.ecrln-lig       = cecrln.lig
                        .
                end.
            end.
            else assign
                dMtRegl      = (if cecrln.sens then cecrln.mt else - cecrln.mt)
                dMtRegl-Euro = (if cecrln.sens then cecrln.mt-euro else - cecrln.mt-euro)
            .
            find first impaye
                where impaye.Soc-cd = cecrln.soc-cd
                  and impaye.Etab-cd = cecrln.etab-cd
                  &IF DEFINED(REPORT) &THEN
                  and impaye.Compte   = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                  and impaye.lettre   = cecrln.lettre
                  and impaye.Dacompta = cecrln.dacompta
                  &ENDIF
                  and string(impaye.CodeRub) begins "1" no-error.
            &IF DEFINED(REPORT) &then release impaye. &ENDIF /* DM 0409/0037 */
            if available impaye then assign
                impaye.MtRub  = impaye.MtRub  + round(dMtRegl, 2)
                impaye.Sens   = if impaye.MtRub >= 0 then "+" else "-"
                impaye.MtEuro = impaye.MtEuro + round(dMtRegl-Euro, 2)
            .
            else do:
                create impaye.
                buffer-copy cecrln to impaye
                assign
                    impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                    impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                    impaye.CodeRub    = iCdRub
                    impaye.CodeLib    = iCdLib
                    impaye.MtRub      = impaye.MtRub + round(dMtRegl, 2)
                    impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                    impaye.MtEuro     = impaye.MtEuro + round(dMtRegl-Euro, 2)
                    /* DM 0809/0042 */
                    impaye.ecrln-jou-cd    = cecrln.jou-cd
                    impaye.ecrln-prd-cd    = cecrln.prd-cd
                    impaye.ecrln-prd-num   = cecrln.prd-num
                    impaye.ecrln-piece-int = cecrln.piece-int
                    impaye.ecrln-lig        = cecrln.lig
                .
            end.
        end.
    END.

end procedure.

procedure Impayes_Anouveaux:
    /*------------------------------------------------------------------------------
    purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pdaDebutExercice as date   no-undo.

    define variable vlReportEtExtract as logical   no-undo.
    define variable vcParametre       as character no-undo. /* DM 0508/0177 */
    define variable vdeTauxBail       as decimal   no-undo. /* DM 0211/0063 */

    define buffer tache    for tache.
    define buffer cecrln   for cecrln.
    define buffer ijou     for ijou.
    define buffer cecrsai  for cecrsai.
    define buffer aecrdtva for aecrdtva.
    define buffer aligtva  for aligtva.
    define buffer adbtva   for adbtva.

    vdeTauxBail  = dynamic-function("getTauxTvaBail" in ghOutilsTva, integer(string(csscpt.etab-cd) + csscpt.cpt-cd)).
    /* Date des derniers traitements effectués */
    run datetrt(piCodeSoc, ietab.etab-cd, tmp-dafin, vcParametre). // dans datetrt.i
    run RCLOC(integer(string(ietab.etab-cd) + csscpt.cpt-cd), pdaDebutExercice).  /**Ajout OF le 22/09/09**/
    EMPTY TEMP-TABLE ijou-tmp2.
    dSoldeL = 0.  /**Ajout OF le 26/05/08**/
    for each ijou no-lock
        where ijou.soc-cd = mtoken:iCodeSociete
          and ijou.etab-cd = iMdGesCom
          and ijou.natjou-gi = 93
        use-index jou-i:
        FIND FIRST ijou-tmp2 WHERE ijou-tmp2.cd-jou = ijou.jou-cd NO-ERROR.
        IF NOT AVAILABLE ijou-tmp2 THEN DO:
            CREATE ijou-tmp2.
            ASSIGN ijou-tmp2.cd-jou = ijou.jou-cd.
        END.
    END.
    for each ijou no-lock
        where ijou.soc-cd = mtoken:iCodeSociete
          and ijou.etab-cd = iMdGerGlb
          and ijou.natjou-gi = 93
        use-index jou-i:
        FIND FIRST ijou-tmp2 WHERE ijou-tmp2.cd-jou = ijou.jou-cd NO-ERROR.
        IF NOT AVAILABLE ijou-tmp2 THEN DO:
            CREATE ijou-tmp2.
            ASSIGN ijou-tmp2.cd-jou = ijou.jou-cd.
        END.
    END.
    for each ijou no-lock
        where ijou.soc-cd = mtoken:iCodeSociete
          and ijou.etab-cd = ietab.etab-cd
          and ijou.natjou-gi = 93
        use-index jou-i:
        find first ijou-tmp2 where ijou-tmp2.cd-jou = ijou.jou-cd no-error.
        if not available ijou-tmp2 then do:
            create ijou-tmp2.
            assign ijou-tmp2.cd-jou = ijou.jou-cd.
        END.
    end.
    for each ijou-tmp2:
        for each cecrln no-lock
            where cecrln.soc-cd = mtoken:iCodeSociete
              and cecrln.etab-cd = ietab.etab-cd
              and cecrln.jou-cd = ijou-tmp2.cd-jou
              and cecrln.sscoll-cle = csscpt.sscoll-cle
              and cecrln.cpt-cd = csscpt.cpt-cd
              &IF DEFINED(REPORT) &THEN
              and (glExtractCRG or (cecrln.flag-lettre = false or (cecrln.flag-lettre = true and cecrln.dalettrage >= tmp-dadeb)))
              &ENDIF
              and cecrln.dacompta = pdaDebutExercice:
                /* DM 0113/0150 */
            &IF DEFINED(REPORT) &THEN
            if glExtractCRG then do: /* Filtrer les écritures du jour de début de crg */
                if cecrln.num-crg <> 0 then do:
                    find first ahistcrg no-lock
                        where ahistcrg.soc-cd = cecrln.soc-cd
                          and ahistcrg.etab-cd = cecrln.etab-cd
                          and ahistcrg.num-crg = ABS(cecrln.num-crg)
                          and ahistcrg.dtdeb >= tmp-dadeb
                          and ahistcrg.dtfin <= tmp-dafin no-error.
                    if available ahistcrg then next.
                end.
            end.
            &ENDIF
            assign
                vlReportEtExtract = &IF DEFINED(REPORT)
                                    &then if glExtractCRG
                                          then not can-find(first ahistcrg
                                                            where ahistcrg.soc-cd = cecrln.soc-cd
                                                              and ahistcrg.etab-cd = cecrln.etab-cd
                                                              and ahistcrg.num-crg = absolute(cecrln.num-crg)
                                                              and ahistcrg.dtdeb >= tmp-dadeb
                                                              and ahistcrg.dtfin <= tmp-dafin)
                                          else true
                                    &ELSE true
                                    &ENDIF
            .
            /* DM 0809/0042 */
            find first cecrsai no-lock
                where cecrsai.soc-cd    = cecrln.soc-cd
                  and cecrsai.etab-cd   = cecrln.mandat-cd
                  and cecrsai.jou-cd    = cecrln.jou-cd
                  and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                  and cecrsai.prd-num   = cecrln.mandat-prd-num
                  and cecrsai.piece-int = cecrln.piece-int no-error.
            dSoldeL = dSoldeL + (if cecrln.sens then cecrln.mt else - cecrln.mt).
            for each aecrdtva no-lock
                where aecrdtva.soc-cd    = cecrln.soc-cd
                  and aecrdtva.etab-cd   = cecrln.etab-cd
                  and aecrdtva.jou-cd    = cecrln.jou-cd
                  and aecrdtva.prd-cd    = cecrln.prd-cd
                  and aecrdtva.prd-num   = cecrln.prd-num
                  and aecrdtva.piece-int = cecrln.piece-int
                  and aecrdtva.lig       = cecrln.lig:
                find first impaye
                    where impaye.Soc-cd  = aecrdtva.soc-cd
                      and impaye.Etab-cd = aecrdtva.etab-cd
                      and impaye.CodeRub = aecrdtva.cdrub
                      &IF DEFINED(REPORT) &THEN
                      and impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                      and impaye.lib-ecr[1] = cecrln.lib-ecr[1]
                      and impaye.Dacompta   = cecrln.dacompta
                      &ENDIF
                      and impaye.CodeLib = aecrdtva.cdlib no-error.
                /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                &IF DEFINED(REPORT) &then release impaye. &ENDIF
                if available impaye then assign
                    impaye.MtRub    = impaye.MtRub + (aecrdtva.mtht + aecrdtva.mttva)
                    impaye.MtRubTva = impaye.mtrubtva + aecrdtva.mttva /* DM 1106/0030 */
                    impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                    impaye.MtEuro   = impaye.MtEuro + (aecrdtva.mtht-euro + aecrdtva.mttva-euro)
                .
                else do:
                    create impaye.
                    buffer-copy cecrln to impaye
                    ASSIGN
                        impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                        impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                        impaye.CodeRub    = aecrdtva.cdrub
                        impaye.CodeLib    = aecrdtva.cdlib
                        impaye.MtRub      = impaye.MtRub + aecrdtva.mtht + aecrdtva.mttva
                        impaye.MtRubTva   = impaye.mtrubtva + aecrdtva.mttva
                        impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                        impaye.MtEuro     = impaye.MtEuro + (aecrdtva.mtht-euro + aecrdtva.mttva-euro)
                    .
                    if available cecrsai and cecrsai.natjou-cd = 9 then assign /* pour rechercher la periodicite dans faedetq.w */
                        impaye.ecrln-jou-cd    = cecrsai.jou-cd
                        impaye.ecrln-prd-cd    = cecrsai.prd-cd
                        impaye.ecrln-prd-num   = cecrsai.prd-num
                        impaye.ecrln-piece-int = cecrsai.piece-int
                        impaye.ecrln-lig       = cecrln.lig
                    .
                    else impaye.fg-quit = true.
                end.
            end.
            if not can-find(first aecrdtva no-lock
                where aecrdtva.soc-cd    = cecrln.soc-cd
                  and aecrdtva.etab-cd   = cecrln.etab-cd
                  and aecrdtva.etab-cd   = cecrln.etab-cd
                  and aecrdtva.jou-cd    = cecrln.jou-cd
                  and aecrdtva.prd-cd    = cecrln.prd-cd
                  and aecrdtva.prd-num   = cecrln.prd-num
                  and aecrdtva.piece-int = cecrln.piece-int
                  and aecrdtva.lig       = cecrln.lig) then do:
                assign
                    dMtAdbtva      = 0
                    dMtAdbtva-Euro = 0
                .
                for each adbtva no-lock
                    where adbtva.soc-cd = cecrln.soc-cd
                      and adbtva.etab-cd = cecrln.etab-cd
                      and adbtva.jou-cd = cecrln.jou-cd
                      and adbtva.prd-cd = cecrln.prd-cd
                      and adbtva.prd-num = cecrln.prd-num
                      and adbtva.piece-int = cecrln.piece-int
                      and adbtva.lig = cecrln.lig
                      and (if goNouveauCrg:isNouveauCRGActif()
                           then (adbtva.lib-trt = ""   and vlReportEtExtract
                             or (adbtva.lib-trt = "R"  and adbtva.date-trt >= &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF))
                            else TRUE):
                    assign
                        dMtAdbtva      = dMtAdbtva      + adbtva.mt       /** 1008/0296 + ABSOLUTE(adbtva.mt) **/
                        dMtAdbtva-Euro = dMtAdbtva-Euro + adbtva.mt-euro  /** 1008/0296 + ABSOLUTE(adbtva.mt-euro) **/
                    .
                    if not can-find(first aligtva no-lock
                        where adbtva.soc-cd  = aligtva.soc-cd
                          and adbtva.etab-cd = aligtva.etab-cd
                          and adbtva.num-int = aligtva.num-int) then do:
                        find first tache no-lock
                            where tache.tpcon = {&TYPECONTRAT-bail}
                              and tache.nocon = integer(string(ietab.etab-cd, "99999") + csscpt.cpt-cd)
                              and tache.tptac = {&TYPETACHE-TVABail} no-error.
                        if available tache then do: /* Bail commercial assujetti à TVA */
                            assign
                                dMtRegl         = - adbtva.mt / (1 + (vdeTauxBail / 100))
                                dMtRegl-Euro    = - adbtva.mt-euro / (1 + (vdeTauxBail / 100))
                                dMtReglTva      = - adbtva.mt - dMtRegl
                                dMtReglTva-Euro = - adbtva.mt-euro - dMtRegl-euro
                                /* Report de l'arrondi */
                                dMtRegl         = round(dMtRegl, 2)
                                dMtReglTva      = round(dMtReglTva, 2)
                                dMtRegl         = dMtRegl - adbtva.mt - (dMtRegl + dMtReglTva)
                            .
                            find first impaye
                                where impaye.Soc-cd = adbtva.soc-cd
                                  and impaye.Etab-cd = adbtva.etab-cd
                                  &IF DEFINED(REPORT) &THEN
                                  and impaye.Compte  = ("0" + csscptcol.sscoll-cpt + csscpt.cpt-cd)
                                  and impaye.lettre = cecrln.lettre
                                  and impaye.Dacompta = cecrln.dacompta
                                  &ENDIF
                                  and (string(impaye.CodeRub) begins "77" or string(impaye.CodeRub) begins "78") no-error.
                            /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                            &IF DEFINED(REPORT) &then release impaye. &ENDIF
                            if available impaye then assign
                                impaye.MtRub    = impaye.MtRub + round(dMtReglTva, 2)
                                impaye.MtRubTva = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 */
                                impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                                impaye.MtEuro   = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                            .
                            ELSE DO:
                                CREATE impaye.
                                BUFFER-COPY cecrln TO impaye
                                ASSIGN
                                    impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                                    impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                                    impaye.CodeRub    = if cecrln.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old
                                    impaye.CodeLib    = iCdLibTva
                                    impaye.MtRub      = impaye.MtRub + round(dMtReglTva, 2)
                                    impaye.MtRubTva   = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 */
                                    impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                                    impaye.MtEuro     = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                                    impaye.ecrln-jou-cd    = adbtva.ecrln-jou-cd
                                    impaye.ecrln-prd-cd    = adbtva.ecrln-prd-cd
                                    impaye.ecrln-prd-num   = adbtva.ecrln-prd-num
                                    impaye.ecrln-piece-int = adbtva.ecrln-piece-int
                                    impaye.ecrln-lig       = adbtva.ecrln-lig
                                .
                            end.
                        end.
                        else assign
                            dMtRegl      = - adbtva.mt
                            dMtRegl-euro = - adbtva.mt-euro
                        .
                        find first impaye
                            where impaye.Soc-cd = adbtva.soc-cd
                              and impaye.Etab-cd = adbtva.etab-cd
                              &IF DEFINED(REPORT) &THEN
                              and impaye.Compte  = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                              and impaye.lettre = cecrln.lettre
                              and impaye.Dacompta = cecrln.dacompta
                              &ENDIF
                              and string(impaye.CodeRub) begins "1" no-error.
                        &IF DEFINED(REPORT) &THEN RELEASE impaye. &ENDIF /* DM 0409/0037 */
                        if available impaye then assign
                            impaye.MtRub  = impaye.MtRub  + round(dMtRegl, 2)
                            impaye.Sens   = if impaye.MtRub >= 0 then "+" else "-"
                            impaye.MtEuro = impaye.MtEuro + round(dMtRegl-Euro, 2)
                        .
                        ELSE DO:
                            CREATE impaye.
                            BUFFER-COPY cecrln TO impaye
                            ASSIGN
                                impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb),"99") + "00"
                                impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                                impaye.CodeRub    = iCdRub
                                impaye.CodeLib    = iCdLib
                                impaye.MtRub      = impaye.MtRub + round(dMtRegl, 2)
                                impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                                impaye.MtEuro     = impaye.MtEuro + round(dMtRegl-Euro, 2)
                            .
                        end.
                    END.
                    else for each aligtva of adbtva no-lock:
                        find first impaye
                            where impaye.Soc-cd = aligtva.soc-cd
                              and impaye.Etab-cd = aligtva.etab-cd
                              and impaye.CodeRub = aligtva.cdrub
                              &IF DEFINED(REPORT) &THEN
                              and impaye.Compte   = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                              and impaye.lettre   = cecrln.lettre
                              and impaye.Dacompta = cecrln.dacompta
                              &ENDIF
                              and impaye.CodeLib = aligtva.cdlib no-error.
                        /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                        &IF DEFINED(REPORT) &then release impaye. &ENDIF
                        if available impaye then assign
                            impaye.MtRub    = impaye.MtRub - (aligtva.mtht + aligtva.mttva)
                            impaye.MtRubTva = impaye.MtRubTva - (aligtva.mttva) /* DM 1106/0030 */
                            impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                            impaye.MtEuro   = impaye.MtEuro - (aligtva.mtht-euro + aligtva.mttva-euro)
                        .
                        ELSE DO:
                            CREATE impaye.
                            BUFFER-COPY cecrln TO impaye
                            ASSIGN
                                impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                                impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                                impaye.CodeRub    = aligtva.cdrub
                                impaye.CodeLib    = aligtva.cdlib
                                impaye.MtRub      = impaye.MtRub - (aligtva.mtht + aligtva.mttva)
                                impaye.MtRubTva   = impaye.MtRubTva - (aligtva.mttva) /* DM 1106/0030 */
                                impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                                impaye.MtEuro     = impaye.MtEuro - (aligtva.mtht-euro + aligtva.mttva-euro)
                                impaye.ecrln-jou-cd    = adbtva.ecrln-jou-cd
                                impaye.ecrln-prd-cd    = adbtva.ecrln-prd-cd
                                impaye.ecrln-prd-num   = adbtva.ecrln-prd-num
                                impaye.ecrln-piece-int = adbtva.ecrln-piece-int
                                impaye.ecrln-lig       = adbtva.ecrln-lig
                            .
                        end.
                    end.
                end.
                if can-find(first adbtva
                            where adbtva.soc-cd = cecrln.soc-cd
                              and adbtva.etab-cd = cecrln.etab-cd
                              and adbtva.jou-cd = cecrln.jou-cd
                              and adbtva.prd-cd = cecrln.prd-cd
                              and adbtva.prd-num = cecrln.prd-num
                              and adbtva.piece-int = cecrln.piece-int
                              and adbtva.lig = cecrln.lig
                              and (IF goNouveauCrg:isNouveauCRGActif()
                                then ((adbtva.lib-trt = "" and vlReportEtExtract)
                                   or (adbtva.lib-trt = "R" and adbtva.date-trt < &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF))
                                ELSE TRUE))
                and ((cecrln.mt * (IF cecrln.sens then - 1 ELSE 1)) - dMtAdbtva) <> 0 then DO:
                find first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = integer(string(ietab.etab-cd, "99999") + csscpt.cpt-cd)
                      and tache.tptac = {&TYPETACHE-TVABail} no-error.
                if available tache then do: /* Bail commercial assujetti à TVA */
                    assign
                        dMtRegl         = - (((if cecrln.sens then -1 else 1) * cecrln.mt) - dMtAdbtva) / (1 + (vdeTauxBail / 100))
                        dMtRegl-Euro    = - (((if cecrln.sens then -1 else 1) * cecrln.mt-euro) - dMtAdbtva-euro) / (1 + (vdeTauxBail / 100))
                        dMtReglTva      = (- (((if cecrln.sens then -1 else 1) * cecrln.mt) - dMtAdbtva)) - dMtRegl
                        dMtReglTva-Euro = (- (((if cecrln.sens then -1 else 1) * cecrln.mt-euro) - dMtAdbtva-euro)) - dMtRegl-euro
                        /* Report de l'arrondi */
                        dMtRegl    = round(dMtRegl, 2)
                        dMtReglTva = round(dMtReglTva, 2)
                        dMtRegl    = dMtRegl + (- (((if cecrln.sens then -1 else 1) * cecrln.mt) - dMtAdbtva)) - (dMtRegl + dMtReglTva)
                    .
                    find first impaye
                        where impaye.Soc-cd = cecrln.soc-cd
                          and impaye.Etab-cd = cecrln.etab-cd
                          &IF DEFINED(REPORT) &THEN
                          and impaye.Compte  = ("0" + csscptcol.sscoll-cpt + csscpt.cpt-cd)
                          and impaye.lettre = cecrln.lettre
                          and impaye.Dacompta = cecrln.dacompta
                          &ENDIF
                          and (string(impaye.CodeRub) begins "77" or string(impaye.CodeRub) begins "78") no-error.
                    /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                    &IF DEFINED(REPORT) &THEN
                        release impaye.
                    &ENDIF
                    if available impaye then assign
                        impaye.MtRub    = impaye.MtRub + round(dMtReglTva, 2)
                        impaye.MtRubTva = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 */
                        impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                        impaye.MtEuro   = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                    .
                    else do:
                        create impaye.
                        buffer-copy cecrln to impaye
                        assign
                            impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                            impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                            impaye.CodeRub    = if cecrln.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old
                            impaye.CodeLib    = iCdLibTva
                            impaye.MtRub      = impaye.MtRub + round(dMtReglTva, 2)
                            impaye.MtRubTva   = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 */
                            impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                            impaye.MtEuro     = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                        .
                    end.
                end.
                else assign
                    dMtRegl      = if cecrln.sens then (cecrln.mt - dMtAdbtva) else - (cecrln.mt - dMtAdbtva)
                    dMtRegl-Euro = if cecrln.sens then (cecrln.mt-euro - dMtAdbtva-Euro) else - (cecrln.mt-euro - dMtAdbtva-Euro)
                .
                find first impaye
                    where impaye.Soc-cd = cecrln.soc-cd
                      and impaye.Etab-cd = cecrln.etab-cd
                      &IF DEFINED(REPORT) &THEN
                      and impaye.Compte   = ("0" + csscptcol.sscoll-cpt + csscpt.cpt-cd)
                      and impaye.lettre   = cecrln.lettre
                      and impaye.Dacompta = cecrln.dacompta
                      &ENDIF
                      and string(impaye.CodeRub) begins "1" no-error.
                    &IF DEFINED(REPORT) &THEN RELEASE impaye. &ENDIF /* DM 0409/0037 */
                    if available impaye then assign
                        impaye.MtRub  = impaye.MtRub + round(dMtRegl, 2)
                        impaye.Sens   = (if impaye.MtRub >= 0 then "+" else "-")
                        impaye.MtEuro = impaye.MtEuro + round(dMtRegl-Euro, 2)
                    .
                    else do:
                        create impaye.
                        buffer-copy cecrln to impaye
                        ASSIGN
                            impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                            impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                            impaye.CodeRub    = iCdRub
                            impaye.CodeLib    = iCdLib
                            impaye.MtRub      = impaye.MtRub + round(dMtRegl, 2)
                            impaye.Sens       = (if impaye.MtRub >= 0 then "+" else "-")
                            impaye.MtEuro     = impaye.MtEuro + round(dMtRegl-Euro, 2)
                        .
                    end.
                end.
            end.
            if not can-find(first adbtva no-lock
                            where adbtva.soc-cd    = cecrln.soc-cd
                              and adbtva.etab-cd   = cecrln.etab-cd
                              and adbtva.jou-cd    = cecrln.jou-cd
                              and adbtva.prd-cd    = cecrln.prd-cd
                              and adbtva.prd-num   = cecrln.prd-num
                              and adbtva.piece-int = cecrln.piece-int
                              and adbtva.lig       = cecrln.lig
                              and (IF goNouveauCrg:isNouveauCRGActif()
                                then ((adbtva.lib-trt = "" and vlReportEtExtract)
                                   or (adbtva.lib-trt = "R" and adbtva.date-trt < &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF))
                                ELSE TRUE))
            and not can-find(first aecrdtva no-lock
                             where aecrdtva.soc-cd    = cecrln.soc-cd
                               and aecrdtva.etab-cd   = cecrln.etab-cd
                               and aecrdtva.jou-cd    = cecrln.jou-cd
                               and aecrdtva.prd-cd    = cecrln.prd-cd
                               and aecrdtva.prd-num   = cecrln.prd-num
                               and aecrdtva.piece-int = cecrln.piece-int
                               and aecrdtva.lig       = cecrln.lig)
            then DO:
                find first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-bail}
                      and tache.nocon = integer(string(ietab.etab-cd, "99999") + csscpt.cpt-cd)
                      and tache.tptac = {&TYPETACHE-TVABail} no-error.
                if available tache then do: /* Bail commercial assujetti à TVA */
                    assign
                        dMtRegl         = ((if cecrln.sens then 1 else -1) * cecrln.mt) / (1 + (vdeTauxBail / 100))
                        dMtRegl-Euro    = ((if cecrln.sens then 1 else -1) * cecrln.mt-euro) / (1 + (vdeTauxBail / 100))
                        dMtReglTva      = ((if cecrln.sens then 1 else -1) * cecrln.mt) - dMtRegl
                        dMtReglTva-Euro = ((if cecrln.sens then 1 else -1) * cecrln.mt-euro) - dMtRegl-euro
                        /* Report de l'arrondi */
                        dMtRegl         = round(dMtRegl, 2)
                        dMtReglTva      = round(dMtReglTva, 2)
                        dMtRegl         = dMtRegl + (((if cecrln.sens then 1 else -1) * cecrln.mt) - (dMtRegl + dMtReglTva))
                    .
                    find first impaye
                        where impaye.Soc-cd = cecrln.soc-cd
                          and impaye.Etab-cd = cecrln.etab-cd
                        &IF DEFINED(REPORT) &THEN
                          and impaye.Compte  = ("0" + csscptcol.sscoll-cpt + csscpt.cpt-cd)
                          and impaye.lettre = cecrln.lettre
                          and impaye.Dacompta = cecrln.dacompta
                        &ENDIF
                          and (string(impaye.CodeRub) begins "77" or string(impaye.CodeRub) begins "78") no-error.
                    /* DM 0809/0042 Détailler les impayés récupérer la période de quitt dans l'état excel */
                    &IF DEFINED(REPORT) &then release impaye. &ENDIF
                    if available impaye then assign
                        impaye.MtRub    = impaye.MtRub    + round(dMtReglTva, 2)
                        impaye.MtRubTva = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 */
                        impaye.Sens     = if impaye.MtRub >= 0 then "+" else "-"
                        impaye.MtEuro   = impaye.MtEuro   + round(dMtReglTva-Euro, 2)
                    .
                    ELSE DO:
                        CREATE impaye.
                        BUFFER-COPY cecrln TO impaye
                        ASSIGN
                            impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb),"99") + "00"
                            impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                            impaye.CodeRub    = (if cecrln.dacompta >= 04/01/2000 then iCdRubTva else iCdRubTva-old)
                            impaye.CodeLib    = iCdLibTva
                            impaye.MtRub      = impaye.MtRub + round(dMtReglTva, 2)
                            impaye.MtRubTva   = impaye.MtRubTva + round(dMtReglTva, 2) /* DM 1106/0030 */
                            impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                            impaye.MtEuro     = impaye.MtEuro + round(dMtReglTva-Euro, 2)
                        .
                    END.
                END.
                else assign
                    dMtRegl      = (if cecrln.sens then cecrln.mt else - cecrln.mt)
                    dMtRegl-Euro = (if cecrln.sens then cecrln.mt-euro else - cecrln.mt-euro)
                .
                find first impaye
                    where impaye.Soc-cd = cecrln.soc-cd
                      and impaye.Etab-cd = cecrln.etab-cd
                      &IF DEFINED(REPORT) &THEN
                      and impaye.Compte  = ("0" + csscptcol.sscoll-cpt + csscpt.cpt-cd)
                      and impaye.lettre = cecrln.lettre
                      and impaye.Dacompta = cecrln.dacompta
                      &ENDIF
                      and string(impaye.CodeRub) begins "1" no-error.
                &IF DEFINED(REPORT) &then release impaye. &ENDIF /* DM 0409/0037 */
                if available impaye then assign
                    impaye.MtRub  = impaye.MtRub + round(dMtRegl, 2)
                    impaye.Sens   = (if impaye.MtRub >= 0 then "+" else "-")
                    impaye.MtEuro = impaye.MtEuro + round(dMtRegl-Euro, 2)
                .
                else do:
                    create impaye.
                    buffer-copy cecrln to impaye
                    assign
                        impaye.DateCompta = string(year(tmp-dadeb), "9999") + string(month(tmp-dadeb), "99") + "00"
                        impaye.Compte     = "0" + csscptcol.sscoll-cpt + csscpt.cpt-cd
                        impaye.CodeRub    = iCdRub
                        impaye.CodeLib    = iCdLib
                        impaye.MtRub      = impaye.MtRub + round(dMtRegl, 2)
                        impaye.Sens       = if impaye.MtRub >= 0 then "+" else "-"
                        impaye.MtEuro     = impaye.MtEuro + round(dMtRegl-Euro, 2)
                    .
                end.
            end.
        end.
    end.
end procedure.

procedure regule:
    /*-----------------------------------------------------------------------------
    Purpose :
    notes   : DM 0508/0177 Rajout des reguls d'eclatement d'encaissement
    -----------------------------------------------------------------------------*/
    define input parameter pdaTva  as date no-undo. /* DM 0109/0232 */
    define input parameter pdaCrg  as date no-undo. /* DM 0109/0232 */
    define input parameter pdaIrf  as date no-undo. /* DM 0109/0232 */
    define input parameter pdaHono as date no-undo. /* DM 0109/0232 */

    define buffer ijou   for ijou.
    define buffer adbtva for adbtva.
    define buffer cecrln for cecrln.

    if goNouveauCrg:isNouveauCRGActif()
    then for each adbtva no-lock
        where adbtva.soc-cd  = mtoken:iCodeSociete
          and adbtva.etab-cd = ietab.etab-cd
          and adbtva.cpt-cd  = csscpt.cpt-cd
          and ((adbtva.lib-trt = "R"
               and adbtva.date-trt >= &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF
               and adbtva.date-trt <= tmp-dafin)
             or ((adbtva.lib-trt = "AR"
               and (&IF DEFINED(REPORT) &then glSimulation &ELSE TRUE &ENDIF)
               and not(tmp-dafin <= pdaTva or tmp-dafin <= pdaIrf or tmp-dafin < pdaHono or tmp-dafin < pdaCrg)))
          )
      , first cecrln no-lock
        where cecrln.soc-cd    = adbtva.soc-cd
          and cecrln.etab-cd   = adbtva.etab-cd
          and cecrln.jou-cd    = adbtva.jou-cd
          and cecrln.prd-cd    = adbtva.prd-cd
          and cecrln.prd-num   = adbtva.prd-num
          and cecrln.piece-int = adbtva.piece-int
          and cecrln.lig       = adbtva.lig
          and cecrln.sscoll-cle = csscpt.sscoll-cle
      , first ijou no-lock
            where ijou.soc-cd = cecrln.soc-cd
              and ijou.etab-cd = cecrln.mandat-cd
              and ijou.jou-cd  = cecrln.jou-cd
              and (ijou.natjou-cd = 2 or ijou.natjou-gi = 46 or ijou.natjou-gi = 93
                   or (ijou.natjou-gi = 40 and mtoken:iCodeSociete <> 3073))
        break by adbtva.prd-cd
              by adbtva.prd-num
              by adbtva.piece-int
              by adbtva.lig:
        if not available cecrln or cecrln.dacompta > tmp-dafin
        or (available ijou and ijou.natjou-gi = 93 and cecrln.dacompta > &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF)
        /* DM 0109/0232  Ne pas prendre les AN postérieurs à la date de début */
        /* DM 0109/0232  Ne pas prendre les réguls si l'ecriture est antérieure aux AN, elles sont reportées dans les AN */
        or cecrln.sscoll-cle <> csscpt.sscoll-cle or cecrln.dacompta < f_DebExeClot(cecrln.soc-cd,cecrln.etab-cd, &IF DEFINED(RLVPRO) &then tmp-dadeb-in &ELSE tmp-dadeb &ENDIF)
        then next.

        if first-of(adbtva.lig) then do:
            find first cecrln-enc
                where cecrln-enc.soc-cd = cecrln.soc-cd
                  and cecrln-enc.etab-cd = cecrln.etab-cd
                  and cecrln-enc.jou-cd = cecrln.jou-cd
                  and cecrln-enc.prd-cd = cecrln.prd-cd
                  and cecrln-enc.prd-num = cecrln.prd-num
                  and cecrln-enc.piece-int = cecrln.piece-int
                  and cecrln-enc.lig = cecrln.lig no-error.
            if not available cecrln-enc
            then do:
                create cecrln-enc.
                buffer-copy cecrln to cecrln-enc.
            end.
            if available ijou and available cecrln and ijou.natjou-gi = 93
            then cecrln-enc.dacompta = cecrln.datecr.
        end.
    end.

end procedure.
