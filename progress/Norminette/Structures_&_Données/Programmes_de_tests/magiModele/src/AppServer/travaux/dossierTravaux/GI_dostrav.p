/*------------------------------------------------------------------------
File        : gi_dostrav.p
Purpose     : Calcul du montant réglé par fournisseur
              Calcul du montant encaissé par copropriétaire
Author(s)   : LGI - 2016/08/03
Notes       : issu de dostrav.p
    - Suivi financier client
        piCodeEntree = 1: modification de ttListeSuiviFinancierClient
        piCodeEntree = 3: création de ttDetailSuiviFinancierClient , permet d'éditer les appels de fonds (+ od ventilée) dans l'écran 'détail par copro'
        piCodeEntree = 4: création de ttListeEcriture , liste les od avec ventilation et les appels de fonds dans l'écran 'détail par copro'
                           quand le 'reste du' du copro est différent du solde du copro.
    - Suivi financier travaux
        piCodeEntree = 5: création de ttListeEcriture , pour justifier la colonne 'Encaissé' = Trésorerie lettrée
        piCodeEntree = 6: création de ttListeEcriture , pour justifier la colonne 'Encaissé' = Trésorerie non-lettrée , ligne Provisions
        piCodeEntree = 7: création de ttListeEcriture , liste les od avec ventilation pour la colonne 'Appels reconstitués'
    ttDetailSuiviFinancierClient
         NOLGN = 10  -> Appels de clotures
         NOLGN = 20  -> Trésoreries
         NOLGN = 30  -> ODT
         NOLGN = 40  -> OD non-ventilées en apbco
         NOLGN = 50  -> Compensation
         NOLGN = 60  -> Achats
         NOLGN = 100 -> Autres
                         -> Appels de fonds manuels
                         -> Appels de fonds émis
                         -> OD ventilées en apbco
         NOLGN = 110 Solde comptable
         NOLGN = 120 Total du copro.
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/typeAppel.i}
{preprocesseur/typeAppel2fonds.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{travaux/include/suiviFinancier.i}

define input        parameter piNumeroSociete as integer   no-undo.
define input        parameter piCodeEntree    as integer   no-undo initial 1. /* 2 = Montant réglé fournisseur, 1 = Montant encaissé copropriétaire , 3 = ttDetailSuiviFinancierClient */
define input        parameter piNumeroMandat  as integer   no-undo.
define input        parameter piNumeroDossier as integer   no-undo.
define input        parameter pdaDateEdition  as date      no-undo.
define input        parameter pcTypeMandat    as character no-undo.
define input        parameter pcTypeTravaux   as character no-undo.
define input-output parameter table for ttListeSuiviFinancierClient.
define input-output parameter table for ttDetailSuiviFinancierClient.
define input-output parameter table for ttListeEcriture.
define input-output parameter table for ttDetailAppelTravauxParLot.
define input-output parameter table for ttListeSuiviFinancierTravaux.
define output       parameter piErreur        as integer   no-undo initial 1.

define variable gdeMontantLettre     as decimal   no-undo.          /* RF 0306/0215 - Lettré pour prorata       */
define variable gdeMontantNonLettre  as decimal   no-undo.          /* RF 0306/0215 - Non lettré pour provision */
define variable gcListeTypeMouvement as character no-undo.
define variable gcUserId             as character no-undo.
define variable glApbco              as logical   no-undo.

define temp-table ttRepartitionOD no-undo
    field cCleRepartition as character
    field deMontantCle    as decimal
index primaire cCleRepartition.

message "Entrée GI_dostrav.p, piNumeroSociete " piNumeroSociete " piCodeEntree " piCodeEntree " piNumeroMandat" piNumeroMandat "piNumeroDossier " piNumeroDossier.

run initialize(output gcUserId, output gcListeTypeMouvement).
case piCodeEntree:
    when 2                                                   then run mtReglFournisseur.        /* Montant réglé / fournisseur */
    when 1 or when 3 or when 4 or when 5 or when 6 or when 7 then run mtCopEnc-OD.              /* Montant encaissé / copropriétaire + OD dans montant appelé */
end case.
piErreur = 0.

function deMontantEncaisse returns decimal (pcListeCompte as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Note   :
    -------------------------------------------------------------------------------*/
    define variable vdMontant  as decimal   no-undo.
    define variable vcCompte   as character no-undo.
    define variable viCompteur as integer   no-undo.

    define buffer ilibnatjou for ilibnatjou.
    define buffer ccpt       for ccpt.
    define buffer ijou       for ijou.
    define buffer cecrln     for cecrln.

    do viCompteur = 1 to num-entries(pcListeCompte):
        vcCompte = entry(viCompteur, pcListeCompte).
        {&_proparse_ prolint-nowarn(use-index)}
        for each ccpt no-lock
            where ccpt.soc-cd   = piNumeroSociete
              and ccpt.coll-cle = ""
              and ccpt.cpt-cd begins vcCompte
          , each cecrln no-lock
            where cecrln.soc-cd     = piNumeroSociete
              and cecrln.etab-cd    = piNumeroMandat
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = ccpt.cpt-cd
              and cecrln.affair-num = piNumeroDossier
              and (if pdaDateEdition = ? then true else cecrln.dacompta <= pdaDateEdition)
            use-index ecrln-consul:            // par défaut, ecrln-affn
            for first ijou no-lock
                where ijou.soc-cd = piNumeroSociete
                  and ijou.etab-cd = cecrln.mandat-cd
                  and ijou.jou-cd = cecrln.jou-cd:
                if ijou.natjou-gi = 42 or ijou.natjou-gi = 46 /* odt  */
                or (ijou.natjou-gi = 92 and lookup(cecrln.type-cle, gcListeTypeMouvement) > 0) /* Il faut prendre les AN de "démarrage" (journal AN) mais pas les AN de clôture (journal ANC) */
                then vdMontant = vdMontant + (if cecrln.sens then cecrln.mt else - cecrln.mt).
                else for first ilibnatjou no-lock
                    where ilibnatjou.soc-cd    = ijou.soc-cd
                      and ilibnatjou.natjou-cd = ijou.natjou-cd
                      and ilibnatjou.treso:
                    vdMontant = vdMontant + (if cecrln.sens then cecrln.mt else - cecrln.mt).
                end.
            end.
        end.
    end.
    return vdMontant.

end function.

function DonneTypeTrav returns character
    (pcTypeContrat as character, pcUrgence as character, pcCodeRubrique as character, pcSousRubrique as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Note   :
    -------------------------------------------------------------------------------*/
    define buffer PrmAna for PrmAna.

    for first prmAna no-lock
        where PrmAna.tppar = "ANATX"
          and PrmAna.tpcon = pcTypeContrat
          and PrmAna.fgdos = true
          and PrmAna.TpUrg = pcUrgence
          and PrmAna.NoRub = pcCodeRubrique
          and prmAna.noSsr = pcSousRubrique:
        return prmAna.cdPar.
    end.
    return "00001".

end function.

procedure initialize:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter pcUserId             as character no-undo.
    define output parameter pcListeTypeMouvement as character no-undo.

    define buffer ietab    for ietab.
    define buffer itypemvt for itypemvt.

    for first ietab no-lock
        where ietab.soc-cd  = piNumeroSociete
          and ietab.etab-cd = piNumeroMandat:
        pcUserId = ietab.usrid.
    end.
    for each itypemvt no-lock
        where itypemvt.soc-cd    = piNumeroSociete
          and itypemvt.etab-cd   = piNumeroMandat
          and itypemvt.natjou-cd = 9
          and (itypemvt.typenat-cd = 50 or itypemvt.typenat-cd = 51 or itypemvt.type-cle = "ODT"):
          pcListeTypeMouvement = pcListeTypeMouvement + "," + itypemvt.type-cle.
    end.
    pcListeTypeMouvement = trim(pcListeTypeMouvement, ",").

end procedure.

procedure MtCopEnc-OD:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdMontantTot        as decimal   no-undo extent 8. /* DM 0907/0182 */
    define variable vdMontantApp        as decimal   no-undo.
    define variable vdMontantAppCphb    as decimal   no-undo.
    define variable vdMontantOd         as decimal   no-undo.
    define variable vdMontantOdApbco    as decimal   no-undo.
    define variable vdMontantAutres     as decimal   no-undo.
    define variable vdMontantTreso      as decimal   no-undo.
    define variable vdMontantOdt        as decimal   no-undo.
    define variable vdMontantCmp        as decimal   no-undo.
    define variable vdMontantAchats     as decimal   no-undo.
    define variable vcLienApbcoCecrsai  as character no-undo.
    define variable vcLienApbcoCecrln   as character no-undo.
    define variable vlExisteApbco       as logical   no-undo.
    define variable viNumeroImmeuble    as integer   no-undo.
    define variable vdMontantTmp        as decimal   no-undo.
    define variable viNocop             as integer   no-undo.
    define variable vdaDateDep          as date      no-undo.
    define variable vdaDatePremEcriture as date      no-undo.
    define variable viCompteur          as integer   no-undo.
    define variable vdTotalApbco        as decimal   no-undo.
    define variable vdTotalAftx         as decimal   no-undo.
    define variable vlMvt               as logical   no-undo.          /* DM 0106/0195 */

    define buffer sys_lb     for sys_lb.
    define buffer sys_pr     for sys_pr.
    define buffer local      for local.
    define buffer csscpt     for csscpt.
    define buffer apbco      for apbco.
    define buffer dosap      for dosap.
    define buffer clemi      for clemi.
    define buffer cecrsai    for cecrsai.
    define buffer ijou       for ijou.
    define buffer ilibnatjou for ilibnatjou.
    define buffer cecrln     for cecrln.
    define buffer vbCecrln   for cecrln.
    define buffer intnt      for intnt.

    if piCodeEntree = 3 or piCodeEntree = 4
    then do:
        find first ttDetailSuiviFinancierClient
            where ttDetailSuiviFinancierClient.iNumeroEntete = 100
              and ttDetailSuiviFinancierClient.iNumeroLigne  = 10 no-error. /** Enregistrement créé par visdoscl.p **/
        if available ttDetailSuiviFinancierClient then viNocop = integer(ttDetailSuiviFinancierClient.cNumeroCoproprietaire).
        if viNocop = 0 then return.
    end.

    /** Immeuble **/
    find first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat no-error.
    if not available intnt then return.

    viNumeroImmeuble = intnt.noidt.
    if piCodeEntree = 1
    then for each ttListeSuiviFinancierClient
        where ttListeSuiviFinancierClient.iNumeroCoproprietaire > 0:
        ttListeSuiviFinancierClient.dMontantResteDu = ttListeSuiviFinancierClient.dMontantTotalAppele - ttListeSuiviFinancierClient.dMontantEncaissement.
    end.
    /**Modif OF le 02/05/16 - Optimisation: initialisation dates sortie de la boucle csscpt + changt index FOR EACH cecrln**/
    if num-entries(gcUserId, "|") >= 2 and entry(2, gcUserId, "|") begins "DUPLICATION" and piCodeEntree = 1
    then do:
boucle1:
        for each cecrln fields(dacompta) no-lock
            where cecrln.soc-cd     = piNumeroSociete
              and cecrln.etab-cd    = piNumeroMandat
              and cecrln.affair-num = piNumeroDossier
            by cecrln.dacompta:
            vdaDatePremEcriture = cecrln.dacompta.
            leave boucle1.
        end.
boucle2:
        for each cecrln fields (dacompta) no-lock
            where cecrln.soc-cd     = piNumeroSociete
              and cecrln.etab-cd    = piNumeroMandat
              and cecrln.affair-num = piNumeroDossier
              and cecrln.jou-cd     begins "AN"
            by cecrln.dacompta:
            vdaDateDep = cecrln.dacompta.
            leave boucle2.
        end.
    end.
    if vdaDateDep > vdaDatePremEcriture then vdaDateDep = vdaDatePremEcriture.
    /* On fait la différence entre lettré/non lettrés pour la ligne provision */
    /* Mais si, mais si, c'est simple et utile....                            */
boucleCsscpt:
    for each csscpt no-lock
        where csscpt.soc-cd     = piNumeroSociete
          and csscpt.etab-cd    = piNumeroMandat
          and csscpt.sscoll-cle = "CHB":
        if (piCodeEntree = 3 or piCodeEntree = 4) and integer(csscpt.cpt-cd) <> viNocop then next boucleCsscpt.

        assign
            gdeMontantLettre    = 0
            gdeMontantNonLettre = 0
            vdMontantApp        = 0
            vlMvt               = false
            vdMontantAppCphb    = 0
            vdMontantOd         = 0
            vdMontantOdt        = 0
            vdMontantOdApbco    = 0
            vdMontantAutres     = 0
            vdMontantTreso      = 0
            vdMontantCmp        = 0
            vdMontantAchats     = 0
        .
        {&_proparse_ prolint-nowarn(use-index)}
boucleCecrln:
        for each cecrln no-lock
            where cecrln.soc-cd     = piNumeroSociete
              and cecrln.etab-cd    = piNumeroMandat
              and cecrln.sscoll-cle = "CHB"
              and cecrln.cpt-cd     = csscpt.cpt-cd
              and cecrln.affair-num = piNumeroDossier
              and (pdaDateEdition = ? or cecrln.dacompta <= pdaDateEdition)
            use-index ecrln-consul
          , first ijou no-lock
            where ijou.soc-cd  = piNumeroSociete
              and ijou.etab-cd = cecrln.mandat-cd
              and ijou.jou-cd  = cecrln.jou-cd:
            find first ilibnatjou no-lock
                where ilibnatjou.soc-cd    = ijou.soc-cd
                  and ilibnatjou.natjou-cd = ijou.natjou-cd  no-error.
            /* Appels de fond: ils apparaissent dans les apbco de l'appel de fonds.
               Ils sont déjà dans le champ ttListeSuiviFinancierClient.dMontantTotalAppele */
            if ijou.natjou-gi = 65
            then do:
                if piCodeEntree = 5 or piCodeEntree = 6 or piCodeEntree = 7 then next boucleCecrln.

                if piCodeEntree = 4 then do:
                    run createListeEcriture(buffer cecrln).
                    if cecrln.ref-num begins "AFTX."      // ttListeEcriture.cNumeroDocument
                    and can-find(first ttDetailAppelTravauxParLot
                        where ttDetailAppelTravauxParLot.iNumeroMandat = cecrln.etab-cd
                          and ttDetailAppelTravauxParLot.iNumeroCopro  = integer(cecrln.cpt-cd)
                          and ttDetailAppelTravauxParLot.cTypeBudget   = {&TYPEBUDGET-travaux}
                          and ttDetailAppelTravauxParLot.iNumeroBudget = cecrln.etab-cd * 100000 + cecrln.affair-num
                          and ttDetailAppelTravauxParLot.cTypeAppel    = {&TYPEAPPEL-dossierTravaux}
                          and ttDetailAppelTravauxParLot.iNumeroAppel  = integer(substring(entry(2, cecrln.ref-num, "."), 3, 2, 'character')))
                    then for first cecrsai no-lock
                        where cecrsai.soc-cd    = cecrln.soc-cd
                          and cecrsai.etab-cd   = cecrln.mandat-cd
                          and cecrsai.jou-cd    = cecrln.jou-cd
                          and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                          and cecrsai.prd-num   = cecrln.mandat-prd-num
                          and cecrsai.piece-int = cecrln.piece-int:
                        vcLienApbcoCecrsai = substitute('&1|&2|&3|&4|&5|&6', cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-compta).
                        for each apbco no-lock
                            where apbco.nomdt = cecrln.etab-cd
                              and apbco.nocop = integer(cecrln.cpt-cd)
                              and apbco.tpbud = {&TYPEBUDGET-travaux}
                              and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
                              and apbco.nobud = cecrln.etab-cd * 100000 + cecrln.affair-num
                              and apbco.noapp = integer(substring(entry(2, cecrln.ref-num, "."), 3, 2, 'character')):
                            run createDetailAppelTravauxParLot(buffer apbco, vcLienApbcoCecrsai).
                        end.
                    end.
                    next boucleCecrln.
                end.
            end.
            /* OD: Colonne 'Encaissements' dans le suivi financier client si OD non ventilée en apbco
                   Colonne 'Appels émis' dans le suivi financier client si OD ventilée en apbco */
            else if ijou.natjou-gi = 40  /* OD */
            then do:
                if piCodeEntree = 5 or piCodeEntree = 6 then next boucleCecrln.
                find first cecrsai no-lock
                    where cecrsai.soc-cd    = cecrln.soc-cd
                      and cecrsai.etab-cd   = cecrln.mandat-cd
                      and cecrsai.jou-cd    = cecrln.jou-cd
                      and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                      and cecrsai.prd-num   = cecrln.mandat-prd-num
                      and cecrsai.piece-int = cecrln.piece-int no-error.
                if not available cecrsai then next boucleCecrln.
                assign
                    vcLienApbcoCecrsai = substitute('&1|&2|&3|&4|&5|&6', cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-compta)
                    vcLienApbcoCecrln  = substitute('&1|&2', vcLienApbcoCecrsai, cecrln.lig)
                    vlMvt = true
                .
                find first apbco no-lock
                    where apbco.tpbud  = {&TYPEBUDGET-travaux}
                      and apbco.nobud  = cecrln.etab-cd * 100000 + cecrln.affair-num
                      and apbco.nomdt  = cecrln.etab-cd
                      and apbco.noimm  = viNumeroImmeuble
                      and apbco.tpapp  = "OD"
                      and apbco.lbdiv2 = vcLienApbcoCecrln
                      and apbco.nocop  = integer(csscpt.cpt-cd) no-error.
                /** OD sans Ventilation dans APBCO **/
                if not available apbco
                then do:
                    vdMontantOd = vdMontantOd + (if cecrln.sens then cecrln.mt else - cecrln.mt).
                    /** Les OD non-ventilées entrent dans la colonne Encaissement **/
                    run flagLettrage(cecrln.lettre, cecrln.sens, cecrln.mt).
                end.
                /** OD avec Ventilation dans APBCO **/
                else do:
                    if piCodeEntree = 4 or piCodeEntree = 7
                    then do:
                        run createListeEcriture(buffer cecrln).
                        if piCodeEntree = 7 then next boucleCecrln.
                    end.
                    empty temp-table ttRepartitionOD.
                    vdMontantTmp = 0.
                    for each apbco no-lock
                        where apbco.tpbud  = {&TYPEBUDGET-travaux}
                          and apbco.nobud  = cecrln.etab-cd * 100000 + cecrln.affair-num
                          and apbco.nomdt  = cecrln.etab-cd
                          and apbco.noimm  = viNumeroImmeuble
                          and apbco.tpapp  = "OD"
                          and apbco.lbdiv2 = vcLienApbcoCecrln
                          and apbco.nocop  = integer(csscpt.cpt-cd):
                        if piCodeEntree = 4 then run createDetailAppelTravauxParLot(buffer apbco, vcLienApbcoCecrln).
                        assign
                            vdMontantOdApbco = vdMontantOdApbco + apbco.mtlot
                            vdMontantTmp     = vdMontantTmp     + apbco.mtlot
                            vlExisteApbco     = true
                        .
                        find first ttRepartitionOD
                            where ttRepartitionOD.cCleRepartition = apbco.cdcle no-error.
                        if not available ttRepartitionOD
                        then do:
                            create ttRepartitionOD.
                            ttRepartitionOD.cCleRepartition = apbco.cdcle.
                        end.
                        ttRepartitionOD.deMontantCle = ttRepartitionOD.deMontantCle + apbco.mtlot.
                    end.
                    if vlExisteApbco and piCodeEntree <> 4
                    then do:
                        run crettDetailSuiviFinancierClient(100, 0, "", substitute("OD Manuelle (&1 &2)", string(cecrsai.piece-compta), string(cecrsai.dacompta, "99/99/9999")), "", "", "", "", "", "", "").
                        for each ttRepartitionOD
                            by ttRepartitionOD.cCleRepartition:
                            find first clemi no-lock
                                where clemi.noimm = intnt.noidt
                                  and clemi.cdcle = ttRepartitionOD.cCleRepartition no-error.
                            run crettDetailSuiviFinancierClient(100, 0, "", substitute("   &1-&2", string(ttRepartitionOD.cCleRepartition, "X(3)"), if available clemi then clemi.lbcle else ""),
                                                    string(ttRepartitionOD.deMontantCle, "->,>>>,>>>,>>9.99"), "", string(ttRepartitionOD.deMontantCle, "->,>>>,>>>,>>9.99"), "", "",
                                                    substitute("&1-&2", string(ttRepartitionOD.cCleRepartition, "X(3)"), if available clemi then clemi.lbcle else ""), "").
                            for each apbco no-lock
                                where apbco.tpbud  = {&TYPEBUDGET-travaux}
                                  and apbco.nobud  = cecrln.etab-cd * 100000 + cecrln.affair-num
                                  and apbco.nomdt  = cecrln.etab-cd
                                  and apbco.noimm  = viNumeroImmeuble
                                  and apbco.tpapp  = "OD"
                                  and apbco.lbdiv2 = vcLienApbcoCecrln
                                  and apbco.nocop  = integer(csscpt.cpt-cd)
                                by apbco.cdcle by apbco.nolot:
                                {&_proparse_ prolint-nowarn(release)}
                                release sys_lb no-error.
                                for first local no-lock
                                    where local.noimm = intnt.noidt
                                      and local.nolot = apbco.nolot:
                                    /** Type de lot **/
                                    find first sys_pr no-lock
                                        where sys_pr.tppar = "NTLOT"
                                          and sys_pr.cdpar = local.ntlot no-error.
                                    if available sys_pr
                                    then find first sys_lb no-lock
                                        where sys_lb.cdlng = 0
                                          and sys_lb.nomes = sys_pr.nome1 no-error.
                                end.
                                /**Modif OF le 25/11/10 - Format N° Lot sur 5 digits ci-dessous**/
                                run crettDetailSuiviFinancierClient(100, 0, "", substitute("     &1-&2", string(apbco.nolot, ">>>>9"), if available sys_lb then trim(sys_lb.lbmes) else ""),
                                                                    "", "", string (apbco.mtlot, "->,>>>,>>>,>>9.99"), "", "", "",
                                                                    substitute('&1-&2', string(apbco.nolot, ">>>>9"), if available sys_lb then trim(sys_lb.lbmes) else "")).
                            end.
                        end. /** FOR EACH ttRepartitionOD **/
                    end. /** IF vlExisteApbco **/
                end. /** IF NOT AVAILABLE apbco THEN DO: **/
            end. /** IF ijou.natjou-gi  = 40 **/

            /* ENCAISSEMENTS: Colonne 'Encaissements' dans le suivi financier client */
            else if (available ilibnatjou and ilibnatjou.treso)
                 or ijou.natjou-gi = 42 /* compensation */
                 or ijou.natjou-gi = 46 /* odt */
                 or (ijou.natjou-gi = 92 and lookup(cecrln.type-cle, gcListeTypeMouvement) > 0) /**Ajout OF le 19/04/16 - Il faut prendre les AN de "démarrage" (journal AN) mais pas les AN de clôture (journal ANC) **/
            then do:
                if piCodeEntree = 4 or piCodeEntree = 7 then next boucleCecrln.

                if (piCodeEntree = 5 and cecrln.lettre > "")
                or (piCodeEntree = 6 and cecrln.lettre = "")
                then do:
                    run createListeEcriture(buffer cecrln).
                    next boucleCecrln.
                end.
                run flagLettrage(cecrln.lettre, cecrln.sens, cecrln.mt).
                vlMvt = true.
                if ijou.natjou-gi = 46
                then vdMontantOdt   = vdMontantOdt   + (if cecrln.sens then cecrln.mt else - cecrln.mt).
                else if ijou.natjou-gi = 42
                then vdMontantCmp   = vdMontantCmp   + (if cecrln.sens then cecrln.mt else - cecrln.mt).
                else vdMontantTreso = vdMontantTreso + (if cecrln.sens then cecrln.mt else - cecrln.mt).
            end.

            /* APPELS DE CLOTURE ET OD DE MUTATIONS: Colonne 'Appels Emis' dans le suivi financier client   */
            else if ijou.natjou-gi  = 72  /* Cloture Travaux CPHB 0505/0112 */
                 or (ijou.natjou-gi = 91 and cecrln.type-cle = "ODB") /** 0308/0239 **/
            then do:
                if piCodeEntree >= 4 and piCodeEntree <= 7 then next boucleCecrln.

                if ijou.natjou-gi = 91 and cecrln.type-cle = "ODB"
                then do:
                    /** Est-ce une OD de mutation ?
                    Les od de mutation possèdent du détail par lot (apbco) , elles ne doivent pas être prises en compte ici.
                    Elles apparaissent dans les apbco de l'appel de fonds.
                    Elles sont déjà dans le champ ttListeSuiviFinancierClient.dMontantTotalAppele,
                    **/
                    find first cecrsai no-lock
                        where cecrln.soc-cd         = cecrsai.soc-cd
                          and cecrln.mandat-cd      = cecrsai.etab-cd
                          and cecrln.jou-cd         = cecrsai.jou-cd
                          and cecrln.mandat-prd-cd  = cecrsai.prd-cd
                          and cecrln.mandat-prd-num = cecrsai.prd-num
                          and cecrln.piece-int      = cecrsai.piece-int no-error.
                    if available cecrsai and cecrsai.lib begins "Mutations"
                    then do:
                        run rechercheApbco(buffer cecrsai).
                        if glApbco then next boucleCecrln.
                    end.
                    else do:
                        assign
                            vlMvt      = true
                            vdMontantAutres = vdMontantAutres + (if cecrln.sens then cecrln.mt else - cecrln.mt)
                        .
                        run flagLettrage(cecrln.lettre, cecrln.sens, cecrln.mt).
                    end.
                end.
                /* Appels */
                assign
                    vdMontantApp = vdMontantApp + (if cecrln.sens then cecrln.mt else - cecrln.mt)
                    vlMvt   = true
                .
                if ijou.natjou-gi  = 72 then vdMontantAppCphb = vdMontantAppCphb + (if cecrln.sens then cecrln.mt else - cecrln.mt).
            end.
            /* ACHATS:  Colonne 'Encaissements' dans le suivi financier client */
            else if (available ilibnatjou and ilibnatjou.achat)
            then do:
                if piCodeEntree >= 4 and piCodeEntree <= 7 then next boucleCecrln.

                assign
                    vlMvt      = true
                    vdMontantAchats = vdMontantAchats + (if cecrln.sens then cecrln.mt else - cecrln.mt)
                .
                /** Les Achats entrent dans la colonne Encaissement pour le suivi financier **/
                run flagLettrage(cecrln.lettre, cecrln.sens, cecrln.mt).
            end.
            /* AUTRES: Colonne 'Encaissements' dans le suivi financier client */
            else do:
                if piCodeEntree >= 4 and piCodeEntree <= 7 then next boucleCecrln.

                vlMvt = true.
                if ijou.natjou-cd <> 9  /** ANouveaux de cloture */
                then do:
                    vdMontantAutres = vdMontantAutres + (if cecrln.sens then cecrln.mt else - cecrln.mt).
                    /** Les Achats entrent dans la colonne Encaissement pour le suivi financier **/
                    run flagLettrage(cecrln.lettre, cecrln.sens, cecrln.mt).
                end.
            end.
        end. /** FOR EACH cecrln **/

        /* Rajout des mutations d'appel FRS et FRL */
        for each apbco no-lock
            where apbco.tpbud  = {&TYPEBUDGET-travaux}
              and apbco.nobud  = csscpt.etab-cd * 100000 + piNumeroDossier
              and apbco.nomdt  = csscpt.etab-cd
              and apbco.noimm  = viNumeroImmeuble
              and (apbco.typapptrx = {&TYPEAPPEL2FONDS-financementRoulement} or apbco.typapptrx = {&TYPEAPPEL2FONDS-financementReserve})
              and num-entries(apbco.lbdiv2, "|") >= 6
              and apbco.nocop  = integer(csscpt.cpt-cd)
              and apbco.noord >= 1
          , first cecrsai no-lock
            where cecrsai.soc-cd       = integer(entry(1, apbco.lbdiv2, "|"))
              and cecrsai.etab-cd      = integer(entry(2, apbco.lbdiv2, "|"))
              and cecrsai.jou-cd       =         entry(3, apbco.lbdiv2, "|")
              and cecrsai.prd-cd       = integer(entry(4, apbco.lbdiv2, "|"))
              and cecrsai.prd-num      = integer(entry(5, apbco.lbdiv2, "|"))
              and cecrsai.piece-compta = integer(entry(6, apbco.lbdiv2, "|"))
              and cecrsai.type-cle = "ODB"
              and cecrsai.lib begins "MUTATION"
           , first ijou no-lock
                where ijou.soc-cd  = piNumeroSociete
                  and ijou.etab-cd = cecrsai.etab-cd
                  and ijou.jou-cd  = cecrsai.jou-cd
                  and ijou.natjou-gi = 91:
            assign
                vlMvt           = true
                vdMontantAutres = vdMontantAutres + apbco.mtlot
            .
        end.

        /* DM 1209/0068 Cas mandats dupliqués */
        if num-entries(gcUserId, "|") >= 2 and entry(2, gcUserId, "|") begins "DUPLICATION" and piCodeEntree = 1
        then do:
            assign
                vdaDateDep          = ?     /* Recherche AN de  départ */
                vdaDatePremEcriture = ?     /* Recherche de la première écriture */
            .
            if vdaDateDep <> ?
            then for each cecrln no-lock
                where cecrln.soc-cd     = piNumeroSociete
                  and cecrln.etab-cd    = piNumeroMandat
                  and cecrln.jou-cd     begins "AN"
                  and cecrln.sscoll-cle = "CHB"
                  and cecrln.cpt-cd     = csscpt.cpt-cd
                  and cecrln.dacompta   = vdaDateDep
                  and cecrln.affair-num = piNumeroDossier
                  and lookup(cecrln.type-cle, gcListeTypeMouvement) > 0:          /* AN d'encaissement, de depense ou d'odt */
                find last vbCecrln no-lock
                    where vbCecrln.soc-cd     = cecrln.soc-cd
                      and vbCecrln.etab-cd    = cecrln.etab-cd
                      and vbCecrln.jou-cd     begins "AN"
                      and vbCecrln.sscoll-cle = cecrln.cpt-cd
                      and vbCecrln.cpt-cd     = cecrln.cpt-cd
                      and vbCecrln.dacompta   > cecrln.dacompta
                      and vbCecrln.ref-num    = cecrln.ref-num
                      and vbCecrln.mt         = cecrln.mt
                      and vbCecrln.sens       = cecrln.sens
                      and vbCecrln.affair-num = piNumeroDossier no-error.
                run flagLettrage(if (available vbCecrln and vbCecrln.lettre > "") or (not available vbCecrln and cecrln.lettre > "") then 'L' else '', cecrln.sens, cecrln.mt).
                vlMvt = true.
            end.
            /* Rajout du montant des trésos lettrées qui n'ont pas été reprises par la duplication = somme apbco - somme aftx */
            vdTotalApbco = 0.
            for each apbco no-lock
                where apbco.tpbud = {&TYPEBUDGET-travaux}
                  and apbco.nobud = integer(string(piNumeroMandat, "99999") + string(piNumeroDossier, "99999"))
                  and apbco.nomdt = piNumeroMandat
                  and apbco.noimm = intnt.noidt
                  and apbco.tpapp = "TX"
                  and apbco.nocop = integer(csscpt.cpt-cd)
              , first dosap no-lock
                    where dosap.tpCon = pcTypeMandat
                      and dosap.noCon = piNumeroMandat
                      and dosap.noDos = piNumeroDossier
                      and dosap.noapp = apbco.NOapp
                      and dosap.fgemi = true:
                vdTotalApbco = vdTotalApbco + apbco.mtlot.
            end.
            vdTotalAftx = 0.
            for each cecrln no-lock
                where cecrln.soc-cd     = piNumeroSociete
                  and cecrln.etab-cd    = piNumeroMandat
                  and cecrln.jou-cd     = "AFTX"
                  and cecrln.type-cle   = "ODTX"
                  and cecrln.sscoll-cle = "CHB"
                  and cecrln.cpt-cd     = csscpt.cpt-cd
                  and cecrln.affair-num = piNumeroDossier:
                  vdTotalAftx = vdTotalAftx + (if cecrln.sens then cecrln.mt else - cecrln.mt).
            end.
            if vdaDateDep <> ?
            then for each cecrln no-lock
                where cecrln.soc-cd     = piNumeroSociete
                  and cecrln.etab-cd    = piNumeroMandat
                  and cecrln.jou-cd     begins "AN"
                  and ((cecrln.type-cle  = "ODTX" and cecrln.ref-num begins "AFTX") or cecrln.type-cle = "OD")
                  and cecrln.sscoll-cle = "CHB"
                  and cecrln.cpt-cd     = csscpt.cpt-cd
                  and cecrln.dacompta   = vdaDateDep
                  and cecrln.affair-num = piNumeroDossier:
                vdTotalAftx = vdTotalAftx + (if cecrln.sens then cecrln.mt else - cecrln.mt).
            end.
            if vdTotalAftx + vdTotalApbco <> 0 then assign
                vlMvt            = true
                gdeMontantLettre = gdeMontantLettre  + (vdTotalApbco - vdTotalAftx)
            .
        end. /* mandats dupliques */

        if vlMvt and piCodeEntree = 1
        then do:
            find first ttListeSuiviFinancierClient
                where ttListeSuiviFinancierClient.iNumeroCoproprietaire = integer(csscpt.cpt-cd) no-error.
            if not available ttListeSuiviFinancierClient
            then do:
                create ttListeSuiviFinancierClient.
                assign
                    ttListeSuiviFinancierClient.iNumeroCoproprietaire = integer(csscpt.cpt-cd)
                    ttListeSuiviFinancierClient.cNomCoproprietaire    = csscpt.lib
                .
            end.
            assign
                ttListeSuiviFinancierClient.dMontantEncaissementLettre    = gdeMontantLettre
                ttListeSuiviFinancierClient.dMontantEncaissementNonLettre = gdeMontantNonLettre
                ttListeSuiviFinancierClient.dMontantAppelCloture          = vdMontantAppCphb
                ttListeSuiviFinancierClient.dMontantAutre                 = vdMontantAutres
                ttListeSuiviFinancierClient.dMontantOdSansDetail          = vdMontantOd
                ttListeSuiviFinancierClient.dMontantOdAvecDetail          = vdMontantOdApbco
                ttListeSuiviFinancierClient.dMontantTresorerie            = vdMontantTreso
                ttListeSuiviFinancierClient.dMontantODTresorerie          = vdMontantOdt
                ttListeSuiviFinancierClient.dMontantCompensation          = vdMontantCmp
                ttListeSuiviFinancierClient.dMontantAchat                 = vdMontantAchats
            .
        end.
        if piCodeEntree = 3 then do:
            run crettDetailSuiviFinancierClient(200,  10, "", "Appel de clôture", string(vdMontantAppCphb, "->,>>>,>>>,>>9.99"), "", string(vdMontantAppCphb,"->,>>>,>>>,>>9.99"), "", "", "", "").
            run crettDetailSuiviFinancierClient(200,  20, "", "Trésorerie",       "", "", "", string(vdMontantTreso, "->,>>>,>>>,>>9.99"), "", "", "").
            run crettDetailSuiviFinancierClient(200,  30, "", "ODT",              "", "", "", string(vdMontantOdt, "->,>>>,>>>,>>9.99"), "", "", "").
            run crettDetailSuiviFinancierClient(200,  40, "", "OD non-ventilées", "", "", "", string(vdMontantOd, "->,>>>,>>>,>>9.99"), "", "", "").
            run crettDetailSuiviFinancierClient(200,  50, "", "Compensation",     "", "", "", string(vdMontantCmp, "->,>>>,>>>,>>9.99"), "", "", "").
            run crettDetailSuiviFinancierClient(200,  60, "", "Achats",           "", "", "", string(vdMontantAchats, "->,>>>,>>>,>>9.99"), "", "", "").
            run crettDetailSuiviFinancierClient(200, 100, "", "Autres",           "", "", "", string(vdMontantAutres, "->,>>>,>>>,>>9.99"), "", "", "").
            find first ttListeSuiviFinancierClient where ttListeSuiviFinancierClient.iNumeroCoproprietaire = viNocop no-error.
            if available ttListeSuiviFinancierClient
            then do:
                run crettDetailSuiviFinancierClient(200, 110, "", "Solde Comptable", "", "", "", "", string(ttListeSuiviFinancierClient.dSoldeChb,"->,>>>,>>>,>>9.99"), "", "").
                run crettDetailSuiviFinancierClient(200, 120, "", "TOTAL",
                                   string(ttListeSuiviFinancierClient.dMontantTotalAppele,      "->,>>>,>>>,>>9.99"),
                                   string(ttListeSuiviFinancierClient.dMontantAppelReconstitue, "->,>>>,>>>,>>9.99"),
                                   string(ttListeSuiviFinancierClient.dMontantAppelEmis + ttListeSuiviFinancierClient.dMontantODAvecDetail + ttListeSuiviFinancierClient.dMontantAppelCloture,"->,>>>,>>>,>>9.99"),
                                   string(ttListeSuiviFinancierClient.dMontantEncaissement,     "->,>>>,>>>,>>9.99"),
                                   string(ttListeSuiviFinancierClient.dMontantResteDu,          "->,>>>,>>>,>>9.99"), "", "").
            end.
            else do:
                run crettDetailSuiviFinancierClient(200, 110, "", "Solde Comptable", "", "", "", "", "", "", "").
                run crettDetailSuiviFinancierClient(200, 120, "", "TOTAL", "", "", "", "", "", "", "").
            end.
        end. /** IF piCodeEntree = 3 THEN DO: **/
    end.  /* csscpt */

    if piCodeEntree = 1 then do:
        /* DM 0907/0182 Montant encaissé sur 7022-7021 7122-7121 7112-7111 */
        assign
            vdMontantTot[6] = deMontantEncaisse("7122,7121") /* Emprunt */
            vdMontantTot[7] = deMontantEncaisse("7112,7111") /* Subvention */
            vdMontantTot[8] = deMontantEncaisse("7132,7131") /* Indemnité */
        .
        do viCompteur = 1 to 8:
            if vdMontantTot[viCompteur] <> 0 then do:
                create ttListeSuiviFinancierClient.
                assign
                    ttListeSuiviFinancierClient.iNumeroCoproprietaire = - viCompteur
                    ttListeSuiviFinancierClient.dMontantEncaissement  = vdMontanttot[viCompteur]
                .
            end.
        end.
    end.

end procedure.

procedure FlagLettrage:
    /*------------------------------------------------------------------------------
    Purpose: Encaissements
    Notes  : 0306/0215 séparation lettrés/non lettrés
    ------------------------------------------------------------------------------*/
    define input parameter pcLettre   as character no-undo.
    define input parameter plSens     as logical   no-undo.
    define input parameter pdeMontant as decimal   no-undo.

    if pcLettre > ""
    then gdeMontantLettre    = gdeMontantLettre    + (if plSens then - pdeMontant else pdeMontant).
    else gdeMontantNonLettre = gdeMontantNonLettre + (if plSens then - pdeMontant else pdeMontant).

end procedure.

procedure MtReglFournisseur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vlPassage  as logical   no-undo.
    define variable vcTypeTrav as character no-undo.          /* "00001" - Travaux, "00003" - Architecte, "00004" - Dommage Ouvrage */

    define buffer cecrlnana  for cecrlnana.
    define buffer csscpt     for csscpt.
    define buffer cecrln     for cecrln.
    define buffer ijou       for ijou.
    define buffer vbIjou     for ijou.
    define buffer vbCecrln   for cecrln.
    define buffer cecrsai    for cecrsai.
    define buffer ilibnatjou for ilibnatjou.

    for each ttListeSuiviFinancierTravaux
       where ttListeSuiviFinancierTravaux.iCodeFournisseur > 0:
        /* Le fournisseur compte 00000 n'est pas autorisé en gestion */
        /* -> HONORAIRES                                             */
        assign
            ttListeSuiviFinancierTravaux.dMontantRegle   = 0
            ttListeSuiviFinancierTravaux.dMontantResteDu = ttListeSuiviFinancierTravaux.dMontantEncaissement - ttListeSuiviFinancierTravaux.dMontantRegle
        .
    end.
    /* RF - Lot 3 - 0306/0215 */
    // On part de la compta, et pas des interventions, car des réguls peuvent être saisies Et les honoraires ne passent pas en intervention
    //   > Achat + OD  ---> colonne facture
    //   > Treso + ODT ---> colonne règlement
    // On prend maitenant en compte le type de travaux, en partant de l'analytique quand c'est possible (factures/avoirs)
    for each csscpt no-lock
       where csscpt.soc-cd      = piNumeroSociete
         and csscpt.etab-cd     = piNumeroMandat
         and (csscpt.sscoll-cle = "FHB" or csscpt.sscoll-cle = "FNPHB"):
        {&_proparse_ prolint-nowarn(use-index)}
        for each cecrln no-lock
            where cecrln.soc-cd      = piNumeroSociete
               and cecrln.etab-cd    = piNumeroMandat
               and cecrln.sscoll-cle = csscpt.sscoll-cle
               and cecrln.cpt-cd     = csscpt.cpt-cd
               and cecrln.affair-num = piNumeroDossier
               and (if pdaDateEdition = ? then true else cecrln.dacompta <= pdaDateEdition)
            use-index ecrln-consul              // par défaut ecrln-aff
          , first ijou no-lock
            where ijou.soc-cd  = piNumeroSociete
              and ijou.etab-cd = cecrln.mandat-cd
              and ijou.jou-cd  = cecrln.jou-cd:
            find first ilibnatjou no-lock
                where ilibnatjou.soc-cd    = ijou.soc-cd
                  and ilibnatjou.natjou-cd = ijou.natjou-cd no-error.
            /*-------------------------------------------------------------------------------------
                            TRESO + ODT : ttListeSuiviFinancierTravaux.dMontantRegle
            -------------------------------------------------------------------------------------*/
            if (available ilibnatjou and ilibnatjou.treso)
            or ijou.natjou-gi = 46
            or (ijou.natjou-gi = 92 and lookup(cecrln.type-cle, gcListeTypeMouvement) > 0)   /**Ajout OF le 19/04/16 - Il faut prendre les AN de "démarrage" (journal AN) mais pas les AN de clôture (journal ANC) **/
            then do:
                /* Treso et/ou ODT -> règlement fournisseur */
                if cecrln.lettre > ""
                then do:
                    /* Lettré -> recherche à partir de la lettre de la facture d'origine et affectation du montant
                       au type de travaux correspondant, avec prorata si plusieurs types dans facture.              */
                    /* Si pas de facture -> type "Travaux" par défaut                    */
                    vlPassage = false.
boucle:
                    for each vbCecrln no-lock
                        where vbCecrln.soc-cd     = piNumeroSociete
                          and vbCecrln.etab-cd    = piNumeroMandat
                          and vbCecrln.sscoll-cle = "FHB"
                          and vbCecrln.cpt-cd     = csscpt.cpt-cd
                          and vbCecrln.affair-num = piNumeroDossier
                          and vbCecrln.lettre     = cecrln.lettre
                          and rowid(vbCecrln)     <> rowid(cecrln)
                      , first vbIjou no-lock
                        where vbIjou.soc-cd  = piNumeroSociete
                          and vbIjou.etab-cd = vbCecrln.etab-cd
                          and vbIjou.jou-cd  = vbCecrln.jou-cd
                      , first ilibnatjou no-lock
                        where ilibnatjou.soc-cd    = vbIjou.soc-cd
                          and ilibnatjou.natjou-cd = vbIjou.natjou-cd
                          and ilibnatjou.achat
                      , first cecrsai no-lock
                        where cecrsai.soc-cd = vbCecrln.soc-cd
                          and cecrsai.etab-cd = vbCecrln.etab-cd
                          and cecrsai.jou-cd = vbCecrln.jou-cd
                          and cecrsai.prd-cd = vbCecrln.prd-cd
                          and cecrsai.prd-num = vbCecrln.prd-num
                          and cecrsai.piece-int = vbCecrln.piece-int:
                        for each cecrlnana no-lock
                            where cecrlnana.soc-cd    = cecrsai.soc-cd
                              and cecrlnana.etab-cd   = cecrsai.etab-cd
                              and cecrlnana.jou-cd    = cecrsai.jou-cd
                              and cecrlnana.prd-cd    = cecrsai.prd-cd
                              and cecrlnana.prd-num   = cecrsai.prd-num
                              and cecrlnana.piece-int = cecrsai.piece-int:
                            vcTypeTrav = if csscpt.cpt-cd <> "00000"
                                        then DonneTypeTrav(pcTypeMandat, pcTypeTravaux, cecrlnana.ana1-cd, cecrlnana.ana2-cd)
                                        else "00005".           /* Fournisseur cabinet -> Honoraires */
                            find first ttListeSuiviFinancierTravaux
                                where ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                                  and ttListeSuiviFinancierTravaux.cCodeTypeTravaux = vcTypeTrav no-error.
                            if not available ttListeSuiviFinancierTravaux
                            then do:
                                create ttListeSuiviFinancierTravaux.
                                assign
                                    ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                                    ttListeSuiviFinancierTravaux.cCodeTypeTravaux = vcTypeTrav
                                    ttListeSuiviFinancierTravaux.cLibelleTri      = csscpt.lib
                                    ttListeSuiviFinancierTravaux.cNomFournisseur  = csscpt.lib
                                .
                            end.
                            assign
                                ttListeSuiviFinancierTravaux.dMontantRegle = ttListeSuiviFinancierTravaux.dMontantRegle
                                                         + (if vbCecrln.mt <> 0
                                                            then round((if cecrln.sens then cecrln.mt else - cecrln.mt) * cecrlnana.mt / vbCecrln.mt, 2)
                                                            else 0)
                                ttListeSuiviFinancierTravaux.dMontantResteDu = ttListeSuiviFinancierTravaux.dMontantEncaissement - ttListeSuiviFinancierTravaux.dMontantRegle
                            .
                        end.
                        vlPassage = true.
                        leave boucle.
                    end.
                    if not vlPassage
                    then do:
                        find first ttListeSuiviFinancierTravaux
                            where ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                              and ttListeSuiviFinancierTravaux.cCodeTypeTravaux = (if csscpt.cpt-cd = "00000" then "00005" else "00001") no-error.
                        if not available ttListeSuiviFinancierTravaux
                        then do:
                            create ttListeSuiviFinancierTravaux.
                            assign
                                ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                                ttListeSuiviFinancierTravaux.cCodeTypeTravaux = (if csscpt.cpt-cd = "00000" then "00005" else "00001")
                                ttListeSuiviFinancierTravaux.cLibelleTri      = csscpt.lib
                                ttListeSuiviFinancierTravaux.cNomFournisseur  = csscpt.lib
                            .
                        end.
                        assign
                            ttListeSuiviFinancierTravaux.dMontantRegle = ttListeSuiviFinancierTravaux.dMontantRegle + (if cecrln.sens then cecrln.mt else - cecrln.mt)
                            ttListeSuiviFinancierTravaux.dMontantResteDu = ttListeSuiviFinancierTravaux.dMontantEncaissement - ttListeSuiviFinancierTravaux.dMontantRegle
                        .
                    end.
                end.
                else do:
                    /* Non Lettré -> type "Provision" par défaut */
                    find first ttListeSuiviFinancierTravaux
                        where ttListeSuiviFinancierTravaux.iCodeFournisseur = -2 no-error.
                    if not available ttListeSuiviFinancierTravaux
                    then do:
                        create ttListeSuiviFinancierTravaux.
                        assign
                            ttListeSuiviFinancierTravaux.iCodeFournisseur    = -2
                            ttListeSuiviFinancierTravaux.cLibelleTri         = "zzzzzzzzzzz00002Provision"
                            ttListeSuiviFinancierTravaux.cNomFournisseur     = "Provision"
                            ttListeSuiviFinancierTravaux.cCodeTypeTravaux    = "00002"
                            ttListeSuiviFinancierTravaux.cLibelleTypeTravaux = "Provision"
                        .
                    end.
                    assign
                        ttListeSuiviFinancierTravaux.dMontantRegle   = ttListeSuiviFinancierTravaux.dMontantRegle + (if cecrln.sens then cecrln.mt else - cecrln.mt)
                        ttListeSuiviFinancierTravaux.dMontantResteDu = ttListeSuiviFinancierTravaux.dMontantEncaissement - ttListeSuiviFinancierTravaux.dMontantRegle
                    .
                end.
            end. /** IF (AVAILABLE ilibnatjou AND ilibnatjou.treso)          **/
            else do:
                /*-------------------------------------------------------------------------------------
                                            ACHATS : ttListeSuiviFinancierTravaux.dMontantFacture
                -------------------------------------------------------------------------------------*/
                if available ilibnatjou and ilibnatjou.achat
                then do:
                    /* -> Type travaux grâce à analytique contrepartie                    */
                    /* -> Sauf si le fournisseur est "00000" - Cabinet -> type Honoraires */
                    if csscpt.cpt-cd = "00000"
                    then do:
                        find first ttListeSuiviFinancierTravaux
                            where ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                              and ttListeSuiviFinancierTravaux.cCodeTypeTravaux = "00005" no-error.
                        if not available ttListeSuiviFinancierTravaux
                        then do:
                            create ttListeSuiviFinancierTravaux.
                            assign
                                ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                                ttListeSuiviFinancierTravaux.cCodeTypeTravaux = "00005"
                                ttListeSuiviFinancierTravaux.cLibelleTri  = csscpt.lib
                                ttListeSuiviFinancierTravaux.cNomFournisseur  = csscpt.lib
                            .
                        end.
                        ttListeSuiviFinancierTravaux.dMontantFacture = ttListeSuiviFinancierTravaux.dMontantFacture + (if cecrln.sens then - cecrln.mt else cecrln.mt).
                    end.
                    else for first cecrsai no-lock
                        where cecrsai.soc-cd    = cecrln.soc-cd
                          and cecrsai.etab-cd   = cecrln.etab-cd
                          and cecrsai.jou-cd    = cecrln.jou-cd
                          and cecrsai.prd-cd    = cecrln.prd-cd
                          and cecrsai.prd-num   = cecrln.prd-num
                          and cecrsai.piece-int = cecrln.piece-int
                      , each cecrlnana no-lock
                        where cecrlnana.soc-cd    = cecrsai.soc-cd
                          and cecrlnana.etab-cd   = cecrsai.etab-cd
                          and cecrlnana.jou-cd    = cecrsai.jou-cd
                          and cecrlnana.prd-cd    = cecrsai.prd-cd
                          and cecrlnana.prd-num   = cecrsai.prd-num
                          and cecrlnana.piece-int = cecrsai.piece-int:
                        vcTypeTrav = DonneTypeTrav(pcTypeMandat, pcTypeTravaux, cecrlnana.ana1-cd, cecrlnana.ana2-cd).
                        find first ttListeSuiviFinancierTravaux
                             where ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                               and ttListeSuiviFinancierTravaux.cCodeTypeTravaux = vcTypeTrav no-error.
                        if not available ttListeSuiviFinancierTravaux
                        then do:
                            create ttListeSuiviFinancierTravaux.
                            assign
                                ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                                ttListeSuiviFinancierTravaux.cCodeTypeTravaux = vcTypeTrav
                                ttListeSuiviFinancierTravaux.cLibelleTri  = csscpt.lib
                                ttListeSuiviFinancierTravaux.cNomFournisseur  = csscpt.lib
                            .
                        end.
                        /* ATTENTION !! Inversion des sens, je regarde l'analytique de la contrepartie !! */
                        ttListeSuiviFinancierTravaux.dMontantFacture = ttListeSuiviFinancierTravaux.dMontantFacture + (if cecrlnana.sens then cecrlnana.mt else - cecrlnana.mt).
                    end.
                end.
                /*-------------------------------------------------------------------------------------
                                            OD
                -------------------------------------------------------------------------------------*/
                if available ilibnatjou and ilibnatjou.od
                then do:
                    find first ttListeSuiviFinancierTravaux
                        where ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                          and ttListeSuiviFinancierTravaux.cCodeTypeTravaux = (if csscpt.cpt-cd = "00000" then "00001" else "00005") no-error.
                    if not available ttListeSuiviFinancierTravaux
                    then do:
                        create ttListeSuiviFinancierTravaux.
                        assign
                            ttListeSuiviFinancierTravaux.iCodeFournisseur   = integer(csscpt.cpt-cd)
                            ttListeSuiviFinancierTravaux.cCodeTypeTravaux   = (if csscpt.cpt-cd = "00000" then "00005" else "00001")
                            ttListeSuiviFinancierTravaux.cLibelleTri        = csscpt.lib
                            ttListeSuiviFinancierTravaux.cNomFournisseur    = csscpt.lib
                        .
                    end.
                    /* Ici les sens sont conservés, je regarde l'écriture du FHB */
                    ttListeSuiviFinancierTravaux.dMontantFacture = ttListeSuiviFinancierTravaux.dMontantFacture + (if cecrln.sens then - cecrln.mt else cecrln.mt).
                end.
            end.  /** IF (AVAILABLE ilibnatjou AND ilibnatjou.treso) **/
        end. /** FOR EACH cecrln **/

        /* DM 0710/0001 Mandat dupliqué : Rajout dans le montant facturé des OD/OD de reprise de dépenses */
        if num-entries(gcUserId, "|") >= 2 and entry(2, gcUserId, "|") begins "DUPLICATION"
        then for each cecrln no-lock
             where cecrln.soc-cd           = piNumeroSociete
               and cecrln.etab-cd          = piNumeroMandat
               and cecrln.jou-cd           = "OD"
               and cecrln.type-cle         = "OD"
               and cecrln.fourn-sscoll-cle = csscpt.sscoll-cle
               and cecrln.fourn-cpt-cd     = csscpt.cpt-cd
               and cecrln.affair-num       = piNumeroDossier
          , first cecrsai no-lock
            where cecrsai.soc-cd    = cecrln.soc-cd
              and cecrsai.etab-cd   = cecrln.etab-cd
              and cecrsai.jou-cd    = cecrln.jou-cd
              and cecrsai.prd-cd    = cecrln.prd-cd
              and cecrsai.prd-num   = cecrln.prd-num
              and cecrsai.piece-int = cecrln.piece-int:
            {&_proparse_ prolint-nowarn(blocklabel)}
            if cecrsai.lib <> "duplication mandat : reprise depenses travaux" and not cecrsai.usrid matches "*|duplication" then next.

boucleCecrlnana:
            for each cecrlnana no-lock
                where cecrlnana.soc-cd    = cecrln.soc-cd
                  and cecrlnana.etab-cd   = cecrln.etab-cd
                  and cecrlnana.jou-cd    = cecrln.jou-cd
                  and cecrlnana.prd-cd    = cecrln.prd-cd
                  and cecrlnana.prd-num   = cecrln.prd-num
                  and cecrlnana.piece-int = cecrln.piece-int
                  and cecrlnana.lig       = cecrln.lig:
                if not can-find(first alrub no-lock
                    where alrub.soc-cd = cecrlnana.soc-cd
                      and alrub.rub-cd = cecrlnana.ana1-cd
                      and alrub.ssrub-cd = cecrlnana.ana2-cd) then next boucleCecrlnana.       /* POur filtrer les 999-999 de l'OD */

                vcTypeTrav = DonneTypeTrav(pcTypeMandat, pcTypeTravaux, cecrlnana.ana1-cd, cecrlnana.ana2-cd).
                find first ttListeSuiviFinancierTravaux
                     where ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                       and ttListeSuiviFinancierTravaux.cCodeTypeTravaux = vcTypeTrav no-error.
                if not available ttListeSuiviFinancierTravaux
                then do:
                    create ttListeSuiviFinancierTravaux.
                    assign
                        ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(csscpt.cpt-cd)
                        ttListeSuiviFinancierTravaux.cCodeTypeTravaux = vcTypeTrav
                        ttListeSuiviFinancierTravaux.cLibelleTri      = csscpt.lib
                        ttListeSuiviFinancierTravaux.cNomFournisseur  = csscpt.lib
                    .
                end.
                /* ATTENTION !! Inversion des sens, je regarde l'analytique de la contrepartie !! */
                ttListeSuiviFinancierTravaux.dMontantFacture = ttListeSuiviFinancierTravaux.dMontantFacture + (if cecrlnana.sens then cecrlnana.mt else - cecrlnana.mt).
            end.
        end.

        /*********************************************************************************************
        *********************** D E B U T   C O M M E N T A I R E ************************************
        **********************************************************************************************
        /* DM 0605/0335 */

        find first ttListeSuiviFinancierTravaux
            where ttListeSuiviFinancierTravaux.iNumeroFournisseur = integer(csscpt.cpt-cd) no-error.
        if available ttListeSuiviFinancierTravaux then ttListeSuiviFinancierTravaux.dMontantFacture = 0.
        /* FIN DM 0605/0335 */
        for each cecrln no-lock
            where cecrln.soc-cd     = piNumeroSociete
              and cecrln.etab-cd    = piNumeroMandat
              and cecrln.sscoll-cle = "FHB"
              and cecrln.cpt-cd     = csscpt.cpt-cd
              and cecrln.affair-num = piNumeroDossier
              and (if pdaDateEdition = ? then true else cecrln.dacompta <= pdaDateEdition)
            use-index ecrln-consul:
            find first ijou no-lock
                where ijou.soc-cd  = piNumeroSociete
                  and ijou.etab-cd = cecrln.mandat-cd
                  and ijou.jou-cd  = cecrln.jou-cd no-error.
            if available ijou
            then do:
                find first ilibnatjou of ijou no-lock no-error.
                if (available ilibnatjou and ilibnatjou.treso)
                /** DM 0106/0195 OR LOOKUP(STRING(ijou.natjou-gi,"99"),"40,46") > 0 /* DM 0605/0335  OD et ODT*/ */
                or ijou.natjou-gi = 46 /* odt uniquement DM 0106/0195 */
                then do:
                    find first ttListeSuiviFinancierTravaux
                        where ttListeSuiviFinancierTravaux.iNumeroFournisseur = integer(csscpt.cpt-cd) no-error.
                    if not available ttListeSuiviFinancierTravaux
                    then do:
                        create ttListeSuiviFinancierTravaux.
                        assign
                            ttListeSuiviFinancierTravaux.iNumeroFournisseur = integer(csscpt.cpt-cd)
                            ttListeSuiviFinancierTravaux.cLibelleTri        = csscpt.lib
                            ttListeSuiviFinancierTravaux.cNomFournisseur    = csscpt.lib
                        .
                    end.
                    assign
                        ttListeSuiviFinancierTravaux.dMontantRegle   = ttListeSuiviFinancierTravaux.dMontantRegle + (if cecrln.sens then cecrln.mt else - cecrln.mt)
                        ttListeSuiviFinancierTravaux.dMontantResteDu = ttListeSuiviFinancierTravaux.dMontantEncaissement - ttListeSuiviFinancierTravaux.dMontantRegle
                    .
                end.

                /* DM 0605/0335 */
                else /* DM 0106/0195 Rajout du else */
                if (available ilibnatjou and ilibnatjou.achat) or (available ilibnatjou and ilibnatjou.od) /* DM 0106/0195 */
                then do:
                    find first ttListeSuiviFinancierTravaux
                        where ttListeSuiviFinancierTravaux.iNumeroFournisseur = integer(csscpt.cpt-cd) no-error.
                    if not available ttListeSuiviFinancierTravaux
                    then do:
                        create ttListeSuiviFinancierTravaux.
                        assign
                            ttListeSuiviFinancierTravaux.iNumeroFournisseur = integer(csscpt.cpt-cd)
                            ttListeSuiviFinancierTravaux.cLibelleTri        = csscpt.lib
                            ttListeSuiviFinancierTravaux.cNomFournisseur    = csscpt.lib
                        .
                    end.
                    ttListeSuiviFinancierTravaux.dMontantFacture = ttListeSuiviFinancierTravaux.dMontantFacture + (if cecrln.sens then - cecrln.mt else cecrln.mt).
                end.
                /* FIN DM 0605/0335 */
            end.
        END.
        ************************************************************************************************
        ************************* F I N    C O M M E N T A I R E ***************************************
        ************************************************************************************************/
    end. /* ttListeSuiviFinancierTravaux */

end procedure.

procedure RechercheApbco:
    /*------------------------------------------------------------------------------
    Purpose:
    Note   :
    -------------------------------------------------------------------------------*/
    define parameter buffer cecrsai for cecrsai.
    define buffer apbco for apbco.

    define variable vcLienApbcoCecrsai as character no-undo.
    define variable vcNumeroReference  as character no-undo.
    define variable vcNumeroExe        as character no-undo.
    define variable vcNumeroAppel      as character no-undo.
    define variable viNumeroImmeuble   as integer   no-undo.
    define variable vcTypeBudget       as character no-undo.
    define variable viNumeroBudget     as integer   no-undo.
    define variable vcTypeAppel        as character no-undo.
    define variable vlErreur           as logical   no-undo.
    define buffer ijou  for ijou.
    define buffer intnt for intnt.

    glApbco = false.
    run criteresDetailParLot(
        buffer cecrsai,
        output vlErreur,
        output vcLienApbcoCecrsai,
        output vcNumeroReference,
        output vcNumeroExe,
        output vcNumeroAppel,
        output viNumeroImmeuble,
        output vcTypeBudget,
        output viNumeroBudget,
        output vcTypeAppel
    ).
    if vlErreur then return.

    find first ijou no-lock
        where ijou.soc-cd  = cecrsai.soc-cd
          and ijou.etab-cd = cecrsai.etab-cd
          and ijou.jou-cd  = cecrsai.jou-cd no-error.
    if not available ijou then return.

    find first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat no-error.
    case ijou.natjou-gi:
        when 50 or when 60 or when 65 then do:   /** AFB , AFHB , AFTX **/
            for first apbco no-lock
                where apbco.tpbud  = vcTypeBudget
                  and apbco.nobud  = viNumeroBudget
                  and apbco.nomdt  = intnt.nocon
                  and apbco.noimm  = viNumeroImmeuble
                  and apbco.tpapp  = vcTypeAppel
                  and apbco.noapp  = integer(vcNumeroAppel)
                  and apbco.lbdiv2 = vcLienApbcoCecrsai:
                glApbco = true.
            end.
            if not glApbco
            then for first apbco no-lock
                where apbco.tpbud = vcTypeBudget
                  and apbco.nobud = viNumeroBudget
                  and apbco.nomdt = intnt.nocon
                  and apbco.noimm = viNumeroImmeuble
                  and apbco.tpapp = vcTypeAppel
                  and apbco.noapp = integer(vcNumeroAppel)
                  and apbco.noord = 0:
                glApbco = true.
            end.
        end.
        otherwise for first apbco no-lock
            where apbco.tpbud = vcTypeBudget
              and apbco.nobud = viNumeroBudget
              and apbco.nomdt = intnt.nocon
              and apbco.noimm = viNumeroImmeuble
              and apbco.tpapp = vcTypeAppel
              and apbco.noapp = integer(vcNumeroAppel)
              and apbco.noord <> 0
              and apbco.lbdiv2 = vcLienApbcoCecrsai:
            glApbco = true.
        end.
    end case.

end procedure.

procedure criteresDetailParLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Note   :
    -------------------------------------------------------------------------------*/
    define parameter buffer cecrsai for cecrsai.
    define output parameter plErreur           as logical   no-undo initial true.
    define output parameter pcLienApbcoCecrsai as character no-undo.
    define output parameter pcNumeroReference  as character no-undo.
    define output parameter pcNumeroExe        as character no-undo.
    define output parameter pcNumeroAppel      as character no-undo.
    define output parameter piNumeroImmeuble   as int64     no-undo.
    define output parameter pcTypeBudget       as character no-undo.
    define output parameter piNumeroBudget     as integer   no-undo.
    define output parameter pcTypeAppel        as character no-undo.

    define buffer cecrln for cecrln.
    define buffer intnt  for intnt.

    pcLienApbcoCecrsai = substitute('&1|&2|&3|&4|&5|&6', cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-compta).
    /*---- Recherche de l'appel de fonds régularisé lors de la mutation ----*/
    find first cecrln  no-lock
        where cecrln.soc-cd         = cecrsai.soc-cd
          and cecrln.mandat-cd      = cecrsai.etab-cd
          and cecrln.mandat-prd-cd  = cecrsai.prd-cd
          and cecrln.mandat-prd-num = cecrsai.prd-num
          and cecrln.jou-cd         = cecrsai.jou-cd
          and cecrln.piece-int      = cecrsai.piece-int no-error.
    if not available cecrln then return.

    if  not cecrln.ref-num matches "*AFB..*"
    and not cecrln.ref-num matches "*AFTX.*"
    and not cecrln.ref-num matches "*AFHB.*" then return.

    case entry(1, cecrln.ref-num, "."):
        when "AFTX" then pcTypeAppel = {&TYPEAPPEL-dossierTravaux}.
        when "AFHB" then pcTypeAppel = {&TYPEAPPEL-horsBudget}.
        otherwise pcTypeAppel = {&TYPEAPPEL-budget}.
    end case.

    /** si cecrln.ref-num = AFB..1301 alors pcNumeroReference = 1301, pcNumeroExe = 13 et pcNumeroAppel = 01 **/
    pcNumeroReference = trim(entry(num-entries(cecrln.ref-num, "."), cecrln.ref-num, ".")).
    if length(pcNumeroReference, 'character') <> 4 then return.

    assign
        pcNumeroExe   = substring(pcNumeroReference, 1, 2, 'character')
        pcNumeroAppel = substring(pcNumeroReference, 3, 2, 'character')
    .
    /* Recherche de l'immeuble du mandat */
    find first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and intnt.nocon = cecrsai.etab-cd no-error.
    if not available intnt then return.

    piNumeroImmeuble = intnt.noidt.
    case pcTypeAppel:
        when {&TYPEAPPEL-horsBudget} then assign
            pcTypeBudget   = {&TYPEBUDGET-horsBudget}
            piNumeroBudget = integer(string(intnt.nocon, "99999") + string(0, "99999"))
        .
        when {&TYPEAPPEL-budget} then assign
            pcTypeBudget   = {&TYPEBUDGET-budget}
            piNumeroBudget = integer(string(intnt.nocon, "99999") + string(integer(pcNumeroExe), "99999"))
        .
        otherwise assign
            pcTypeBudget   = {&TYPEBUDGET-travaux}
            piNumeroBudget = integer(string(intnt.nocon, "99999") + string(integer(pcNumeroExe), "99999"))
        .
    end case.
    plErreur = false.

end procedure.

procedure crettDetailSuiviFinancierClient:
    /*------------------------------------------------------------------------------
    Purpose:
    Note   :
    -------------------------------------------------------------------------------*/
    define input parameter piNumeroEntete         as integer   no-undo.
    define input parameter piNumeroLigne          as integer   no-undo.
    define input parameter pcNumeroCoproprietaire as character no-undo.
    define input parameter pcNomCoproprietaire    as character no-undo.
    define input parameter pcMontantAppel         as character no-undo.
    define input parameter pcMontantAppelManuel   as character no-undo.
    define input parameter pcMontantAppelEmis     as character no-undo.
    define input parameter pcMontantEncaisse      as character no-undo.
    define input parameter pcMontantRestant       as character no-undo.
    define input parameter pcCodeCle              as character no-undo.
    define input parameter pcNumeroLot            as character no-undo.

    if piNumeroLigne = 0
    then for last ttDetailSuiviFinancierClient:
        piNumeroLigne = ttDetailSuiviFinancierClient.iNumeroLigne + 10.
    end.
    create ttDetailSuiviFinancierClient.
    assign
        ttDetailSuiviFinancierClient.iNumeroEntete         = piNumeroEntete
        ttDetailSuiviFinancierClient.iNumeroLigne          = piNumeroLigne
        ttDetailSuiviFinancierClient.cNumeroCoproprietaire = pcNumeroCoproprietaire
        ttDetailSuiviFinancierClient.cNomCoproprietaire    = pcNomCoproprietaire
        ttDetailSuiviFinancierClient.cMontantAppel         = pcMontantAppel
        ttDetailSuiviFinancierClient.cMontantAppelManuel   = pcMontantAppelManuel
        ttDetailSuiviFinancierClient.cMontantAppelEmis     = pcMontantAppelEmis
        ttDetailSuiviFinancierClient.cMontantEncaisse      = pcMontantEncaisse
        ttDetailSuiviFinancierClient.cMontantRestant       = pcMontantRestant
        ttDetailSuiviFinancierClient.cCodeCle              = pcCodeCle
        ttDetailSuiviFinancierClient.cNumeroLot            = pcNumeroLot
    .
end procedure.

procedure createListeEcriture:
    /*--------------------------------------------------------------------------------
    Purpose:
    note   :
    --------------------------------------------------------------------------------*/
    define parameter buffer cecrln for cecrln.
    create ttListeEcriture.
    assign
        ttListeEcriture.iNumeroSociete        = cecrln.soc-cd
        ttListeEcriture.iNumeroMandat         = cecrln.etab-cd
        ttListeEcriture.cCodeJournal          = cecrln.jou-cd
        ttListeEcriture.iNumeroExercice       = cecrln.prd-cd
        ttListeEcriture.iNumeroPeriode        = cecrln.prd-num
        ttListeEcriture.iNumeroMandatEntete   = cecrln.mandat-cd
        ttListeEcriture.iNumeroExerciceEntete = cecrln.mandat-prd-cd
        ttListeEcriture.iNumeroPeriodeEntete  = cecrln.mandat-prd-num
        ttListeEcriture.iNumeroPieceInterne   = cecrln.piece-int
        ttListeEcriture.iNumeroLigne          = cecrln.lig
        ttListeEcriture.lSensMontant          = cecrln.sens
        ttListeEcriture.dMontant              = cecrln.mt
        ttListeEcriture.daDateComptable       = cecrln.dacompta
        ttListeEcriture.cLibelle              = cecrln.lib-ecr[1]
        ttListeEcriture.cNumeroDocument       = cecrln.ref-num
        ttListeEcriture.cLettre               = cecrln.lettre
    .
end procedure.

procedure createDetailAppelTravauxParLot:
    /*--------------------------------------------------------------------------------
    Purpose:
    note   :
    --------------------------------------------------------------------------------*/
    define parameter buffer apbco for apbco.
    define input parameter pcLienApbcoCecrsai as character no-undo.

    create ttDetailAppelTravauxParLot.
    assign
        ttDetailAppelTravauxParLot.iNumeroMandat       = apbco.nomdt
        ttDetailAppelTravauxParLot.iNumeroCopro        = apbco.nocop
        ttDetailAppelTravauxParLot.iNumeroBudget       = apbco.nobud
        ttDetailAppelTravauxParLot.cTypeAppel          = apbco.tpapp
        ttDetailAppelTravauxParLot.cTypeBudget         = apbco.tpbud
        ttDetailAppelTravauxParLot.iNumeroAppel        = apbco.noapp
        ttDetailAppelTravauxParLot.iNumeroLot          = apbco.nolot
        ttDetailAppelTravauxParLot.dMontantLot         = apbco.mtlot
        ttDetailAppelTravauxParLot.cLienPieceComptable = apbco.lbdiv2
        ttDetailAppelTravauxParLot.cTypeTravaux        = apbco.typapptrx
        ttDetailAppelTravauxParLot.daDateAppel         = apbco.dtapp
        ttDetailAppelTravauxParLot.dMontantTotal       = apbco.mttot
        ttDetailAppelTravauxParLot.iNumeroImmeuble     = apbco.noimm
        ttDetailAppelTravauxParLot.iNumeroOrdre        = apbco.noord
        ttDetailAppelTravauxParLot.cLienPieceComptable = pcLienApbcoCecrsai
    .
end procedure.
