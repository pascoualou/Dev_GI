/*------------------------------------------------------------------------
File        : calculeSolde.p
Purpose     : calcul universel du solde d'un compte
Author(s)   : RF  -  2017/06/27
Notes       :
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}

{preprocesseur/type2contrat.i}

define input-output parameter poCollection as collection no-undo.

// pour le décodage de poCollection - Entrée
define variable giNumeroSociete      as integer   no-undo.
define variable giNumeroMandat       as integer   no-undo.
define variable gcCodeCollectif      as character no-undo.
define variable gcNumeroCompte       as character no-undo.
define variable gdaDateSolde         as date      no-undo.
define variable giNumeroDossier      as integer   no-undo.
define variable gcNumeroDocument     as character no-undo.
define variable glAvecExtraComptable as logical   no-undo.
// Sortie
define variable gdSoldeCompte      as decimal    no-undo.
define variable gdMouvementsDebit  as decimal    no-undo.
define variable gdMouvementsCredit as decimal    no-undo.

define variable glFiltreANouveaux  as logical   no-undo.
define variable gcJournalANC       as character no-undo. // A Nouveaux de clôture automatique
define variable gcJournalACR       as character no-undo. // Accord de règlement

run calculSolde.

procedure calculSolde private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viExercice         as integer   no-undo.
    define variable viProfilMandat     as integer   no-undo.
    define variable vcTypeContrat      as character no-undo.
    define variable vdSousTotalDebit   as decimal   no-undo.
    define variable vdSousTotalCredit  as decimal   no-undo.

    define buffer vbIprd for iprd.
    define buffer ietab  for ietab.
    define buffer iprd   for iprd.
    define buffer ijou   for ijou.
    define buffer cecrln for cecrln.

    assign
        giNumeroSociete      = poCollection:getInteger  ("iNumeroSociete")
        giNumeroMandat       = poCollection:getInteger  ("iNumeroMandat")
        gcCodeCollectif      = poCollection:getCharacter("cCodeCollectif")
        gcNumeroCompte       = poCollection:getCharacter("cNumeroCompte")
        gdaDateSolde         = poCollection:getDate     ("daDateSolde")
        giNumeroDossier      = poCollection:getInteger  ("iNumeroDossier")
        gcNumeroDocument     = poCollection:getCharacter("cNumeroDocument")
        glAvecExtraComptable = poCollection:getLogical  ("lAvecExtraComptable")
    .
    poCollection:set('dSoldeCompte'     ,gdSoldeCompte     ).
    poCollection:set('dMouvementsDebit' ,gdMouvementsDebit ).
    poCollection:set('dMouvementsCredit',gdMouvementsCredit).


    for first ietab no-lock
        where ietab.soc-cd  = giNumeroSociete
          and ietab.etab-cd = giNumeroMandat:
        viProfilMandat = ietab.profil-cd.
    end.
    case viProfilMandat:
        when 0 then return.
        when 10 or when 20 or when 90 then giNumeroDossier = 0.
        when 21 then vcTypeContrat = {&TYPECONTRAT-mandat2Gerance}.
        when 91 then vcTypeContrat = {&TYPECONTRAT-mandat2Syndic}.
    end case.
    find first iprd no-lock
        where iprd.soc-cd   = giNumeroSociete
          and iprd.etab-cd  = giNumeroMandat
          and iprd.dadebprd = date(month(gdaDateSolde), 1, year(gdaDateSolde)) no-error.
    if not available iprd // Pas de période comptable correspondante -> dernière période antérieure à la date demandée
    then do :
        for last iprd no-lock
        where iprd.soc-cd   = giNumeroSociete
          and iprd.etab-cd  = giNumeroMandat
          and iprd.dadebprd <= date(month(gdaDateSolde), 1, year(gdaDateSolde)) :
          gdaDateSolde = iprd.dafinprd.
        end.                
    end.          
    if not available iprd then return. // Pas de période comptable correspondante -> retour simple sans erreur ni message
    

    viExercice = iprd.prd-cd.
    // Recherche des journaux QUIT + A Nouveaux de cloture + Accord de règlement
    for first ijou no-lock
        where ijou.soc-cd    = giNumeroSociete
          and ijou.etab-cd   = giNumeroMandat
          and ijou.natjou-gi = 93:
        gcJournalANC = ijou.jou-cd.
    end.
    for first ijou no-lock
        where ijou.soc-cd    = giNumeroSociete
          and ijou.etab-cd   = 0
          and ijou.natjou-gi = 89:
        gcJournalACR = ijou.jou-cd.
    end.

    // Dossier Travaux renseigné ET cohérent -> calcul à part
    // Extraction de toutes les écritures comptables du compte
    if can-find (first trdos no-lock
                 where trdos.tpcon = vcTypeContrat
                   and trdos.nocon = giNumeroMandat
                   and trdos.nodos = giNumeroDossier)
    then do:
        {&_proparse_ prolint-nowarn(use-index)}
        for each cecrln no-lock
           where cecrln.soc-cd     = giNumeroSociete
             and cecrln.etab-cd    = giNumeroMandat
             and cecrln.sscoll-cle = gcCodeCollectif
             and cecrln.cpt-cd     = gcNumeroCompte
             and cecrln.dacompta  <= gdaDateSolde
             and cecrln.affair-num = giNumeroDossier use-index ecrln-aff:    // TODO choisir en celui-ci ou celui plus bas
            if cecrln.sens
            then gdMouvementsDebit  = gdMouvementsDebit  + cecrln.mt.
            else gdMouvementsCredit = gdMouvementsCredit + cecrln.mt.
        end.
        {&_proparse_ prolint-nowarn(use-index)}
        if glAvecExtraComptable
        then for each cecrln no-lock
            where cecrln.soc-cd     = giNumeroSociete
              and cecrln.etab-cd    = giNumeroMandat
              and cecrln.sscoll-cle = gcCodeCollectif
              and cecrln.cpt-cd     = gcNumeroCompte
              and cecrln.dacompta  <= gdaDateSolde
              and cecrln.affair-num = giNumeroDossier use-index ecrln-gl:    // TODO choisir en celui-ci ou celui plus haut
            if cecrln.sens
            then gdMouvementsDebit  = gdMouvementsDebit  + cecrln.mt.
            else gdMouvementsCredit = gdMouvementsCredit + cecrln.mt.
        end.
    end.
    else do:
        // Dans quel cas filtrer les A Nouveaux ?
        {&_proparse_ prolint-nowarn(use-index)}
        find prev iprd no-lock
            where iprd.soc-cd  = giNumeroSociete
              and iprd.etab-cd = giNumeroMandat use-index prd-i2 no-error.   // par Date de début de période 'dadeprd'
        if not available iprd
        then do:
            glFiltreANouveaux = false.
            find first iprd no-lock
                 where iprd.soc-cd   = giNumeroSociete
                   and iprd.etab-cd  = giNumeroMandat
                   and iprd.dadebprd = date(month(gdaDateSolde), 1, year(gdaDateSolde)) no-error.
        end.
        else do :
            glFiltreANouveaux = (viExercice <> iprd.prd-cd).
            if iprd.prd-num > 1
            then do:
                // Calcul du solde des périodes complètes précédentes
                run soldeExercice(iprd.prd-cd, iprd.prd-num - 1, output vdSousTotalDebit, output vdSousTotalCredit).
                assign
                    gdMouvementsDebit  = gdMouvementsDebit  + vdSousTotalDebit
                    gdMouvementsCredit = gdMouvementsCredit + vdSousTotalCredit
                .
            end.
        end.

        // Calcul du solde de la période correspondante à la DATE
        run soldePeriode(iprd.dadeb, ijou.jou-cd, output vdSousTotalDebit, output vdSousTotalCredit).
        assign
            gdMouvementsDebit  = gdMouvementsDebit  + vdSousTotalDebit
            gdMouvementsCredit = gdMouvementsCredit + vdSousTotalCredit
        .

        // Si la date de consultation de solde est dans l'exercice '2' (et pas dans la première période)
        // et l'exercice '1' n'est pas cloturé
        // et la classe du compte est < 6 (bilan)
        // alors ajouter le solde de l'exercice 1
        if iprd.prd-cd = ietab.prd-cd-2
        and ietab.exercice = false
        and not ((gcCodeCollectif = ? or gcCodeCollectif = "") and gcNumeroCompte >= "6")
        then for last vbIprd no-lock /**** Recherche de la dernière période de l'exercice 1 ****/
            where vbIprd.soc-cd  = giNumeroSociete
              and vbIprd.etab-cd = giNumeroMandat
              and vbIprd.prd-cd  = ietab.prd-cd-1:
            run soldeExercice(vbIprd.prd-cd, vbIprd.prd-num, output vdSousTotalDebit, output vdSousTotalCredit).
            assign
                gdMouvementsDebit  = gdMouvementsDebit  + vdSousTotalDebit
                gdMouvementsCredit = gdMouvementsCredit + vdSousTotalCredit
            .
        end.
    end.
    gdSoldeCompte = gdMouvementsDebit - gdMouvementsCredit.

message "Fin calculSolde"
    gdSoldeCompte
    gdMouvementsDebit
    gdMouvementsCredit
.

    poCollection:set('dSoldeCompte'     ,gdSoldeCompte).
    poCollection:set('dMouvementsDebit' ,gdMouvementsDebit).
    poCollection:set('dMouvementsCredit',gdMouvementsCredit).

end procedure.

procedure soldeExercice private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  piNumeroExercice  as integer   no-undo.
    define input parameter  piNumeroPeriode   as integer   no-undo.
    define output parameter pdSousTotalDebit  as decimal   no-undo.
    define output parameter pdSousTotalCredit as decimal   no-undo.

    define buffer cextmvt for cextmvt.
    define buffer ccptmvt for ccptmvt.

    for each ccptmvt no-lock
       where ccptmvt.soc-cd     = giNumeroSociete
         and ccptmvt.etab-cd    = giNumeroMandat
         and ccptmvt.sscoll-cle = gcCodeCollectif
         and ccptmvt.cpt-cd     = gcNumeroCompte
         and ccptmvt.prd-cd     = piNumeroExercice
         and ccptmvt.prd-num   <= piNumeroPeriode:
        assign
            pdSousTotalDebit  = pdSousTotalDebit  + ccptmvt.mtdeb + ccptmvt.mtdebp
            pdSousTotalCredit = pdSousTotalCredit + ccptmvt.mtcre + ccptmvt.mtcrep
        .
    end.
    if glAvecExtraComptable
    then for each cextmvt no-lock
       where cextmvt.soc-cd     = giNumeroSociete
         and cextmvt.etab-cd    = giNumeroMandat
         and cextmvt.sscoll-cle = gcCodeCollectif
         and cextmvt.cpt-cd     = gcNumeroCompte
         and cextmvt.prd-cd     = piNumeroExercice
         and cextmvt.prd-num   <= piNumeroPeriode:
        assign
            pdSousTotalDebit  = pdSousTotalDebit  + cextmvt.mtdeb + cextmvt.mtdebp
            pdSousTotalCredit = pdSousTotalCredit + cextmvt.mtcre + cextmvt.mtcrep
        .
    end.
end procedure.

procedure soldePeriode private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  pdaDateDebut      as date      no-undo.
    define input  parameter pcJou-cd          as character no-undo.
    define output parameter pdSousTotalDebit  as decimal   no-undo.
    define output parameter pdSousTotalCredit as decimal   no-undo.

    define variable viMoisQuit  as integer no-undo.
    define variable viAnneeQuit as integer no-undo.

    define buffer cecrln for cecrln.
    define buffer cextln for cextln.

    if gcNumeroDocument > ""
    then do:
        if gcNumeroDocument begins "@"
        then do:
            assign
                viMoisQuit  = integer(substring(gcNumeroDocument, 6, 2, 'character'))
                viAnneeQuit = integer(substring(gcNumeroDocument, 2, 4, 'character'))
            .
boucle:
            for each cecrln no-lock
                where cecrln.soc-cd      = giNumeroSociete
                  and cecrln.etab-cd     = giNumeroMandat
                  and cecrln.sscoll-cle  = gcCodeCollectif
                  and cecrln.cpt-cd      = gcNumeroCompte
                  and cecrln.dacompta   >= pdaDateDebut
                  and cecrln.dacompta   <= gdaDateSolde:
                if cecrln.jou-cd begins gcJournalANC and glFiltreANouveaux then next boucle.

                if cecrln.jou-cd = pcJou-cd
                and (cecrln.dacompta = date(viMoisQuit, 1, viAnneeQuit) or cecrln.dacompta = date(viMoisQuit, 1, viAnneeQuit) - 1)
                and not cecrln.ref-num begins "FL"
                then next boucle.

                if cecrln.sens
                then pdSousTotalDebit  = pdSousTotalDebit  + cecrln.mt.
                else pdSousTotalCredit = pdSousTotalCredit + cecrln.mt.
            end.
        end.
        else for each cecrln no-lock
            where cecrln.soc-cd      = giNumeroSociete
              and cecrln.etab-cd     = giNumeroMandat
              and cecrln.sscoll-cle  = gcCodeCollectif
              and cecrln.cpt-cd      = gcNumeroCompte
              and cecrln.dacompta   >= pdaDateDebut
              and cecrln.dacompta   <= gdaDateSolde
              and cecrln.ref-num    <> gcNumeroDocument:
            if cecrln.jou-cd begins gcJournalANC and glFiltreANouveaux then next.

            if cecrln.sens
            then pdSousTotalDebit  = pdSousTotalDebit  + cecrln.mt.
            else pdSousTotalCredit = pdSousTotalCredit + cecrln.mt.
        end.
    end.
    else for each cecrln no-lock
        where cecrln.soc-cd      = giNumeroSociete
          and cecrln.etab-cd     = giNumeroMandat
          and cecrln.sscoll-cle  = gcCodeCollectif
          and cecrln.cpt-cd      = gcNumeroCompte
          and cecrln.dacompta   >= pdaDateDebut
          and cecrln.dacompta   <= gdaDateSolde:
        if cecrln.jou-cd begins gcJournalANC and glFiltreANouveaux then next.

        if cecrln.sens
        then pdSousTotalDebit  = pdSousTotalDebit  + cecrln.mt.
        else pdSousTotalCredit = pdSousTotalCredit + cecrln.mt.
    end.

    if glAvecExtraComptable
    then do:
        if gcNumeroDocument > ""
        then for each cextln no-lock
            where cextln.soc-cd      = giNumeroSociete
              and cextln.etab-cd     = giNumeroMandat
              and cextln.sscoll-cle  = gcCodeCollectif
              and cextln.cpt-cd      = gcNumeroCompte
              and cextln.dacompta   >= pdaDateDebut
              and cextln.dacompta   <= gdaDateSolde
              and cextln.ref-num    <> gcNumeroDocument:
            if cextln.jou-cd begins gcJournalANC and glFiltreANouveaux then next.

            if cextln.sens
            then pdSousTotalDebit  = pdSousTotalDebit  + cextln.mt.
            else pdSousTotalCredit = pdSousTotalCredit + cextln.mt.
        end.
        else for each cextln no-lock
            where cextln.soc-cd      = giNumeroSociete
              and cextln.etab-cd     = giNumeroMandat
              and cextln.sscoll-cle  = gcCodeCollectif
              and cextln.cpt-cd      = gcNumeroCompte
              and cextln.dacompta   >= pdaDateDebut
              and cextln.dacompta   <= gdaDateSolde:
            if (cextln.jou-cd begins gcJournalANC and glFiltreANouveaux) or cextln.jou-cd = gcJournalACR then next.

            if cextln.sens
            then pdSousTotalDebit  = pdSousTotalDebit  + cextln.mt.
            else pdSousTotalCredit = pdSousTotalCredit + cextln.mt.
        end.
    end.

end procedure.
