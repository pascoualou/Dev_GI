/*------------------------------------------------------------------------
File        : consultationCompte.p
Purpose     :
Author(s)   :    -  2017/01/19
Notes       :
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/consultationCompte.i}
{compta/include/soldeCompte.i}

define variable giNumeroSociete   as integer   no-undo.
define variable giNumeroMandat    as integer   no-undo.
define variable gcListeCollectif  as character no-undo.
define variable gcNumeroCompte    as character no-undo.
define variable gdaDebut          as date      no-undo.
define variable gdaDateFin        as date      no-undo.
define variable gdaDebutExercice  as date      no-undo.
define variable gdaDebutClasse6   as date      no-undo.
define variable gdTotalDebit      as decimal   no-undo.
define variable gdTotalCredit     as decimal   no-undo.
define variable giLienVentilation as integer   no-undo.

function recLibRub returns character private (piRubrique as integer, piLibelle as integer, piLocataire as integer, piMoisQuitt as integer, pdaQuitt as date):
    /*------------------------------------------------------------------------------
    Purpose: Recuperation du libelle client de la rubrique.
    Notes: On cherche s'il existe un parametrage pour le locataire, puis pour le cabinet.
    ------------------------------------------------------------------------------*/
    define buffer sys_lb for sys_lb.
    define buffer rubqt  for rubqt.
    define buffer prrub  for prrub.

    if piMoisQuitt = 0 and pdaQuitt <> ?
    then piMoisQuitt = year(pdaQuitt) * 100 + month(pdaQuitt).
    /* Libellé specifique locataire/Mois */
    find first prrub no-lock
        where prrub.cdRub = piRubrique
          and prrub.cdLib = piLibelle
          and prrub.noLoc = piLocataire
          and prrub.msQtt = piMoisQuitt
          and prrub.msQtt <> 0 no-error.
    if not available prrub
    then find first prrub no-lock   /* Libellé Cabinet */
        where prrub.cdRub = piRubrique
          and prrub.cdLib = piLibelle
          and prrub.noLoc = 0
          and prrub.msQtt = 0
          and prrub.lbRub > "" no-error.
    if available prrub then return prrub.lbRub.

    /* Récupération du no du libellé de la rubrique */
    for first rubqt no-lock
        where rubqt.cdrub = piRubrique
          and rubqt.cdlib = piLibelle:
        for first sys_lb no-lock
            where sys_lb.cdlng = mtoken:iCodeLangueSession
              and sys_lb.nomes = rubqt.nome1:
            return caps(sys_lb.lbmes).
        end.
        return "".
    end.
    return substitute("Rubrique &1-&2", string(piRubrique, "999"), string(piLibelle, "99")).

end function.

function f_daFinClot returns date private (piNumeroSociete as integer, piNumeroMandat as integer, pdtDate as date):
    /*------------------------------------------------------------------------------
    Purpose: Retourne la date de fin d'exercice s'il est cloturé
    Notes: todo  la même dans extrbbpr.p !!!!!
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

function f_premiersANouveaux returns logical private(piNumeroSociete as integer, piNumeroMandat as integer, pdtDateDebut as date):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer ietab for ietab.
    define buffer iprd  for iprd.

    for first ietab no-lock
        where ietab.soc-cd   = piNumeroSociete
          and ietab.etab-cd  = piNumeroMandat
      , first iprd no-lock
        where iprd.soc-cd   = piNumeroSociete
          and iprd.etab-cd  = piNumeroMandat
          and iprd.dadebprd = pdtDateDebut
          and iprd.prd-num   = 1:
        if (iprd.dadebprd <= ietab.dadebex1 or (iprd.dadebprd = ietab.dadebex2 and ietab.exercice)) then return true.
    end.
    return false.

end function.

procedure getConsultationCompte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par ???
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as class collection no-undo.
    define output parameter table for ttLigneEcriture.
    define output parameter table for ttLigneEcritureDetail.
    define output parameter table for ttVentilationEcriture.
    define output parameter table for ttVentilationDetail.
    define output parameter table for ttSoldeCompte.

    define variable vlPremiersANouveaux   as logical   no-undo.
    define variable vlAvecEcritureLettree as logical   no-undo.
    define variable vlAvecExtraComptable  as logical   no-undo.
    define variable viNumeroDossier       as integer   no-undo.
    define variable vcFormatDate          as character no-undo.
    define variable viBoucle              as integer   no-undo.
    define variable vcCodeCollectif       as character no-undo.
    define variable vda1erMouvement       as date      no-undo.
    define variable vdSoldeAnterieur      as decimal   no-undo.

    define buffer ietab for ietab.
    define buffer iprd  for iprd.

    empty temp-table ttLigneEcriture.
    empty temp-table ttLigneEcritureDetail.
    empty temp-table ttVentilationEcriture.
    empty temp-table ttVentilationDetail.
    empty temp-table ttSoldeCompte.
    assign
        vcFormatDate          = poCollection:getCharacter('cFormatDate')
        giNumeroSociete       = poCollection:getInteger  ('iNumeroSociete')
        giNumeroMandat        = poCollection:getInteger  ('iNumeroMandat')
        gcListeCollectif      = poCollection:getCharacter('cListeCollectif')
        gcNumeroCompte        = poCollection:getCharacter('cNumeroCompte')
        gdaDebut              = poCollection:getDate     ('dtDateDebut')
        gdaDateFin            = poCollection:getDate     ('dtDateFin')
        vlAvecEcritureLettree = poCollection:getLogical  ('lAvecEcritureLettree')
        vlAvecExtraComptable  = poCollection:getLogical  ('lAvecExtraComptable')
        viNumeroDossier       = poCollection:getInteger  ('iNumeroDossier')
    .

message "decodage de poCollection: "
    giNumeroSociete
    giNumeroMandat
    gcListeCollectif
    gcNumeroCompte
    gdaDebut
    gdaDateFin
    vlAvecEcritureLettree
    vlAvecExtraComptable
    viNumeroDossier
    vcFormatDate
.

    /* ==== Reprise de faglcon2.w:Queryconsultation ==== */
    vlPremiersANouveaux = f_PremiersANouveaux(giNumeroSociete, giNumeroMandat, gdaDebut).
    find first ietab no-lock
         where ietab.Soc-cd  = giNumeroSociete
           and ietab.etab-cd = giNumeroMandat no-error.
    if not can-find(first iprd no-lock
         where iprd.soc-cd    = giNumeroSociete
           and iprd.etab-cd   = giNumeroMandat
           and iprd.dadebprd <= gdaDebut
           and iprd.dafinprd >= gdaDebut)
    then for first iprd no-lock
        where iprd.soc-cd    = giNumeroSociete
          and iprd.etab-cd   = giNumeroMandat
          and iprd.dadebprd  > gdaDebut:
        gdaDebut = iprd.dadebprd.
    end.
    if not can-find(first iprd no-lock
        where iprd.soc-cd    = giNumeroSociete
          and iprd.etab-cd   = giNumeroMandat
          and iprd.dadebprd <= gdaDateFin
          and iprd.dafinprd >= gdaDateFin)
    then for last iprd no-lock
        where iprd.soc-cd    = giNumeroSociete
          and iprd.etab-cd   = giNumeroMandat
          and iprd.dadebprd  < gdaDateFin:
        gdaDateFin = iprd.dafinprd.
    end.

    run initTraitement(ietab.exercice, ietab.prd-cd-1, ietab.prd-cd-2, output vda1erMouvement).
    if not vlPremiersANouveaux then run soldeAnterieur(vlAvecExtraComptable, viNumeroDossier).
    do viBoucle = 1 to maximum(1, num-entries(gcListeCollectif)):
        assign
            vcCodeCollectif  = entry(viBoucle, gcListeCollectif)
            vdSoldeAnterieur = 0
        .
        for first ttSoldeAnterieur
            where ttSoldeAnterieur.sscoll-cle = vcCodeCollectif:
            vdSoldeAnterieur = ttSoldeAnterieur.solde-ant.
        end.
        run creerTableTmp(vlPremiersANouveaux, vlAvecEcritureLettree, viNumeroDossier, vcCodeCollectif, vda1erMouvement).
        if vlAvecExtraComptable then run extraComptable(vlAvecEcritureLettree, vcCodeCollectif).

        /* -> on se place en Historique SAUF si la date de début de consultation correspond
              -> à une date de début d'exercice N avec N-1 cloturé.
              -> On extrait alors les A Nouveaux et non les mouvements antérieurs  */
        if vdSoldeAnterieur <> 0 and not vlPremiersANouveaux
        then do:
            create ttLigneEcriture.
            assign
                ttLigneEcriture.cTypeLigne         = "D"
                ttLigneEcriture.cLienDetail        = ""
                ttLigneEcriture.cLienVentilation   = ""
                ttLigneEcriture.cLibelle           = outilTraduction:getLibelleCompta(103731)       /* "MVTS ANTERIEURS AU" */
                ttLigneEcriture.cLibelle2          = outilTraduction:getLibelleCompta(103731)       /* "MVTS ANTERIEURS AU" */
                ttLigneEcriture.cSauvegardeLibelle = outilTraduction:getLibelleCompta(103731)       /* "MVTS ANTERIEURS AU" */
                ttLigneEcriture.cCodeJournal       = caps(outilTraduction:getLibelleCompta(101873)) /* "MVTS"               */
                ttLigneEcriture.cDocument          = outilTraduction:getLibelleCompta(104168)       /* "ANTERIEURS"         */
                ttLigneEcriture.cTypeMouvement     = caps(outilTraduction:getLibelleCompta(100574)) /* "AU"                 */
                ttLigneEcriture.cCollectif         = vcCodeCollectif
                ttLigneEcriture.dtDateDocument     = (if gdaDebut <= vda1erMouvement then vda1erMouvement else gdaDebut) - 1
                ttLigneEcriture.dtDateEcheance     = ttLigneEcriture.dtDateDocument
                ttLigneEcriture.iMouvement         = 0
                ttLigneEcriture.lExtraComptable    = false
            .
            if vdSoldeAnterieur > 0
            then assign
                ttLigneEcriture.dMontantDebit  = absolute(vdSoldeAnterieur)
                ttLigneEcriture.dMontantCredit = 0
            .
            else assign
                ttLigneEcriture.dMontantDebit  = 0
                ttLigneEcriture.dMontantCredit = absolute(vdSoldeAnterieur)
            .
            assign
                gdTotalDebit  = gdTotalDebit  + ttLigneEcriture.dMontantDebit
                gdTotalCredit = gdTotalCredit + ttLigneEcriture.dMontantCredit
            .
        end.
    end.
    if viNumeroDossier = 0 then run regroupementEcriture.
    create ttSoldeCompte.
    assign
        ttSoldeCompte.dDebit  = gdTotalDebit
        ttSoldeCompte.dCredit = gdTotalCredit
        ttSoldeCompte.dSolde  = gdTotalDebit - gdTotalCredit
    .
end procedure.

procedure initTraitement private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter plExercice      as logical no-undo.
    define input  parameter piPrd-cd-1      as integer no-undo.
    define input  parameter piPrd-cd-2      as integer no-undo.
    define output parameter pda1erMouvement as date    no-undo.

    define variable viBoucle          as integer   no-undo.
    define variable vcCodeCollectif   as character no-undo.
    define variable viCodeExerciceFin as integer   no-undo.
    define variable viCodePeriode1    as integer   no-undo.

    define buffer iprd   for iprd.
    define buffer vbIprd for iprd.
    define buffer cecrln for cecrln.
    define buffer cextln for cextln.

    for first iprd no-lock
        where iprd.soc-cd  = giNumeroSociete
          and iprd.etab-cd = giNumeroMandat
          and iprd.prd-cd  = piPrd-cd-1:
        assign
            gdaDebutExercice = iprd.dadebprd
            gdaDebutClasse6  = iprd.dadebprd
        .
    end.
    for first iprd no-lock
        where iprd.soc-cd  = giNumeroSociete
          and iprd.etab-cd = giNumeroMandat
          and iprd.dadeb  <= gdaDateFin
          and iprd.dafin  >= gdaDateFin:
        viCodeExerciceFin = iprd.prd-cd.
        if iprd.prd-cd <> piPrd-cd-1
        then do:
            viCodePeriode1 = iprd.prd-cd.
            for first vbIprd no-lock
                where vbIprd.soc-cd  = giNumeroSociete
                  and vbIprd.etab-cd = giNumeroMandat
                  and vbIprd.prd-cd  = viCodePeriode1:
                if (plExercice and vbIprd.prd-cd = piPrd-cd-2) or vbIprd.prd-cd < piPrd-cd-2
                then assign
                    gdaDebutExercice = vbIprd.dadebprd
                    gdaDebutClasse6  = vbIprd.dadebprd
                .
            end.
        end.
    end.
    /*** Init date du 1er mvt comptable ou extra comptable ***/
boucle:
    do viBoucle = 1 to maximum(1, num-entries(gcListeCollectif, ",")):
        vcCodeCollectif = entry(viBoucle, gcListeCollectif, ",").
        {&_proparse_ prolint-nowarn(use-index)}
        for first cecrln no-lock
            where cecrln.soc-cd     = giNumeroSociete
              and cecrln.etab-cd    = giNumeroMandat
              and cecrln.sscoll-cle = vcCodeCollectif
              and cecrln.cpt-cd     = gcNumeroCompte use-index ecrln-gl:            // par daCompta
            if pda1erMouvement = ? or cecrln.dacompta <= pda1erMouvement then pda1erMouvement = cecrln.dacompta.
        end.
        {&_proparse_ prolint-nowarn(use-index)}
        for first cextln no-lock
            where cextln.soc-cd     = giNumeroSociete
              and cextln.etab-cd    = giNumeroMandat
              and cextln.sscoll-cle = vcCodeCollectif
              and cextln.cpt-cd     = gcNumeroCompte use-index extln-gl:            // par daCompta
            if cextln.dacompta <= pda1erMouvement or pda1erMouvement = ? then pda1erMouvement = cextln.dacompta.
        end.
    end. /* DM 0508/0067 */

    /*** FIN DM 0303/0058  ***/
    for first vbIprd no-lock
         where vbIprd.soc-cd    = giNumeroSociete
           and vbIprd.etab-cd   = giNumeroMandat
           and vbIprd.dadebprd <= gdaDebut
           and vbIprd.dafinprd >= gdaDebut:
        if (vbIprd.prd-cd <> piPrd-cd-1 and vbIprd.prd-cd <> piPrd-cd-2) or vbIprd.prd-cd <> viCodeExerciceFin
        then for first iprd no-lock
            where iprd.soc-cd  = vbIprd.soc-cd
              and iprd.etab-cd = vbIprd.etab-cd
              and iprd.prd-cd  = vbIprd.prd-cd:
            assign
                gdaDebutExercice = iprd.dadebprd
                gdaDebutClasse6  = iprd.dadebprd
            .
        end.
    end.

end procedure.

procedure soldeAnterieur private:
    /*---------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------*/
    define input parameter plAvecExtraComptable as logical no-undo.
    define input parameter piNumeroDossier      as integer no-undo.

    define variable voCollection    as collection no-undo.
    define variable viBoucle        as integer   no-undo.
    define variable vcCodeCollectif as character no-undo.

    empty temp-table ttSoldeAnterieur.
    assign
        voCollection  = new collection()
        gdTotalDebit  = 0
        gdTotalCredit = 0
    .
    voCollection:set('iNumeroSociete'     , giNumeroSociete).
    voCollection:set('iNumeroMandat'      , giNumeroMandat).
    voCollection:set('cNumeroCompte'      , gcNumeroCompte).
    voCollection:set('iNumeroDossier'     , piNumeroDossier).
    voCollection:set('lAvecExtraComptable', plAvecExtraComptable).
    voCollection:set('daDateSolde'        , gdaDebut - 1).
    voCollection:set('cNumeroDocument'    , '').
boucle:
    do viBoucle = 1 to maximum(1, num-entries(gcListeCollectif)):
        vcCodeCollectif = entry(viBoucle, gcListeCollectif).
        voCollection:set('cCodeCollectif', vcCodeCollectif).
        run compta/calculeSolde.p(input-output voCollection).
        create ttSoldeAnterieur.
        assign
            ttSoldeAnterieur.sscoll-cle = vcCodeCollectif
            ttSoldeAnterieur.solde-ant  = voCollection:getDecimal('dSoldeCompte')
            ttSoldeAnterieur.deb-ant    = voCollection:getDecimal('dMouvementsDebit')
            ttSoldeAnterieur.cre-ant    = voCollection:getDecimal('dMouvementsCredit')
        .

message "soldeAnterieur"
        ttSoldeAnterieur.sscoll-cle
        ttSoldeAnterieur.solde-ant
        ttSoldeAnterieur.deb-ant
        ttSoldeAnterieur.cre-ant
.
    end. /* DM 0508/0067 */

end procedure.

procedure creerTableTmp private:
    /*---------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------*/
    define input parameter plPremiersANouveaux   as logical   no-undo.
    define input parameter plAvecEcritureLettree as logical   no-undo.
    define input parameter piNumeroDossier       as integer   no-undo.
    define input parameter pcCodeCollectif       as character no-undo.
    define input parameter pda1erMouvement       as date      no-undo.

    define variable vlCondition as logical no-undo.
    define variable vdaCompta   as date    no-undo.

    define buffer iprd    for iprd.
    define buffer vbIprd  for iprd.
    define buffer ijou    for ijou.
    define buffer cecrln  for cecrln.
    define buffer cecrsai for cecrsai.

    find first iprd no-lock
         where iprd.soc-cd    = giNumeroSociete
           and iprd.etab-cd   = giNumeroMandat
           and iprd.dadebprd <= gdaDebut
           and iprd.dafinprd >= gdaDebut no-error.
    vdaCompta = if (pcCodeCollectif = ? or pcCodeCollectif = "") and gcNumeroCompte >= "6" then gdaDebutClasse6 else gdaDebutExercice.

boucle:
    for each cecrln no-lock
        where cecrln.soc-cd     = giNumeroSociete
          and cecrln.etab-cd    = giNumeroMandat
          and cecrln.sscoll-cle = pcCodeCollectif
          and cecrln.cpt-cd     = gcNumeroCompte
          and cecrln.dacompta  >= vdaCompta
          and cecrln.dacompta  <= gdaDateFin
          and (plAvecEcritureLettree or cecrln.dalettrage = ? or cecrln.dalettrage > gdaDateFin)
          and (piNumeroDossier = 0 or cecrln.affair-num = piNumeroDossier)
          and (plAvecEcritureLettree or cecrln.mt <> 0)
      , first cecrsai no-lock
        where cecrsai.soc-cd    = cecrln.soc-cd
          and cecrsai.etab-cd   = cecrln.mandat-cd
          and cecrsai.jou-cd    = cecrln.jou-cd
          and cecrsai.prd-cd    = cecrln.mandat-prd-cd
          and cecrsai.prd-num   = cecrln.mandat-prd-num
          and cecrsai.piece-int = cecrln.piece-int:

        if cecrln.dacompta < gdaDebut then next boucle.

        find first ijou no-lock
            where ijou.soc-cd  = giNumeroSociete
              and ijou.etab-cd = cecrln.mandat-cd
              and ijou.jou-cd  = cecrln.jou-cd no-error.
        find first vbIprd no-lock
            where vbIprd.soc-cd  = giNumeroSociete
              and vbIprd.etab-cd = cecrln.etab-cd
              and vbIprd.prd-cd  = cecrln.prd-cd no-error.

        vlCondition = (available ijou and ijou.natjou-gi = 93
                  and available vbIprd and cecrln.dacompta = vbIprd.dadebprd
                  and cecrln.dacompta <> pda1erMouvement).
        if  iprd.prd-num  = 1 and iprd.dadebprd = gdaDebut and iprd.prd-cd   = cecrln.prd-cd
        and (not vlCondition or (cecrln.dacompta = gdaDebut and plPremiersAnouveaux))
        then do:
            create ttLigneEcriture.
            run assignttLigneEcriture(buffer ttLigneEcriture, buffer cecrln, buffer cecrsai).
        end.
        else do:
            if vlCondition then next boucle.

            create ttLigneEcriture.
            run assignttLigneEcriture(buffer ttLigneEcriture, buffer cecrln, buffer cecrsai).
        end.
        run creVentilation(buffer ttLigneEcriture, buffer cecrln).
    end. /* for each cecrln */

end procedure.

procedure assignttLigneEcriture private:
    /*---------------------------------------------------------------
    Purpose:
    Notes: Code issu de faglcon2.w
    -----------------------------------------------------------------*/
    define parameter buffer ttLigneEcriture for ttLigneEcriture.
    define parameter buffer cecrln          for cecrln.
    define parameter buffer cecrsai         for cecrsai.

    define variable viNumeroLigneTotal as integer no-undo.

    define buffer cblock     for cblock.
    define buffer pregln     for pregln.
    define buffer ilibnatjou for ilibnatjou.

    find last cblock no-lock
        where cblock.soc-cd    = cecrln.soc-cd
          and cblock.etab-cd   = cecrln.etab-cd
          and cblock.jou-cd    = cecrln.jou-cd
          and cblock.prd-cd    = cecrln.prd-cd
          and cblock.prd-num   = cecrln.prd-num
          and cblock.piece-int = cecrln.piece-int
          and cblock.lig       = cecrln.lig no-error.
    assign
        ttLigneEcriture.cTypeLigne            = "D"
        ttLigneEcriture.cLienDetail           = ""
        ttLigneEcriture.cLienVentilation      = ""
        ttLigneEcriture.cCollectif            = cecrln.sscoll-cle
        ttLigneEcriture.cCodeIndicateur       = if available cblock then cblock.ind-cle else ""
        ttLigneEcriture.cLibelle2             = cecrln.lib-ecr[1]
        ttLigneEcriture.cSauvegardeLibelle    = cecrln.lib-ecr[1] /* DM 0508/0067 */
        ttLigneEcriture.cTypeMouvement        = cecrln.type-cle
        ttLigneEcriture.dtDateDocument        = cecrln.datecr
        ttLigneEcriture.dtDateEcheance        = cecrln.daech
        ttLigneEcriture.cDocument             = cecrln.ref-num
        ttLigneEcriture.cNumeroDocumentLong   = if cecrsai.ref-fac <> ? then cecrsai.ref-fac else ""
        ttLigneEcriture.cCodeJournal          = cecrln.jou-cd
        ttLigneEcriture.iExerciceLigne        = cecrln.prd-cd
        ttLigneEcriture.iPeriodeLigne         = cecrln.prd-num
        ttLigneEcriture.iPieceInterne         = cecrln.piece-int
        ttLigneEcriture.iLigne                = cecrln.lig
        ttLigneEcriture.cLettre               = if cecrln.dalettrage <= gdaDateFin or cecrln.dalettrage = ? then cecrln.lettre else ""
        ttLigneEcriture.lLettrageTotal        = cecrln.flag-lettre
        ttLigneEcriture.iSituation            = cecrsai.situ
        ttLigneEcriture.iMouvement            = 1
        ttLigneEcriture.lExtraComptable       = false
        ttLigneEcriture.rRowid                = rowid(cecrln)
        ttLigneEcriture.dtDateComptable       = cecrln.dacompta
        ttLigneEcriture.cLibelle              = cecrln.lib-ecr[1] + cecrln.lib-ecr[2] /* DM 0508/0067 */
        ttLigneEcriture.cNumeroDossierTravaux = string(cecrln.affair-num,">>>9")
        ttLigneEcriture.cNumeroCRG            = string(cecrln.num-crg, ">>9") when cecrln.num-crg > 0 /**Ajout OF le 28/11/11**/
        ttLigneEcriture.lCumul                = false
    .
    if cecrln.sens
    then assign
        ttLigneEcriture.dMontantDebit  = cecrln.mt
        ttLigneEcriture.dMontantCredit = 0
    .
    else assign
        ttLigneEcriture.dMontantDebit  = 0
        ttLigneEcriture.dMontantCredit = cecrln.mt
    .
    assign
        gdTotalDebit                          = gdTotalDebit  + ttLigneEcriture.dMontantDebit
        gdTotalCredit                         = gdTotalCredit + ttLigneEcriture.dMontantCredit
        ttLigneEcriture.iNumeroPieceComptable = cecrsai.piece-compta
        ttLigneEcriture.iMandatEntete         = cecrsai.etab-cd
        ttLigneEcriture.iExerciceEntete       = cecrsai.prd-cd
        ttLigneEcriture.iPeriodeEntete        = cecrsai.prd-num
    .
    if cecrln.sscoll-cle > "" and cecrln.tot-det <> 0
    then for first ilibnatjou no-lock
        where ilibnatjou.soc-cd    = cecrsai.soc-cd
          and ilibnatjou.etab-cd   = cecrsai.etab-cd
          and ilibnatjou.natjou-cd = cecrsai.natjou-cd
          and ilibnatjou.treso:
        find first pregln no-lock
            where pregln.soc-cd    = cecrln.soc-cd
              and pregln.etab-cd   = cecrln.etab-cd
              and pregln.jou-cd    = cecrln.jou-cd
              and pregln.prd-cd    = cecrln.prd-cd
              and pregln.prd-num   = cecrln.prd-num
              and pregln.piece-int = cecrln.piece-int
              and pregln.lig       = cecrln.lig no-error.
        if available pregln
        then do:
            viNumeroLigneTotal = pregln.lig-tot.
            for first pregln no-lock
                 where pregln.soc-cd         = cecrsai.soc-cd
                   and pregln.mandat-cd      = cecrsai.etab-cd
                   and pregln.jou-cd         = cecrsai.jou-cd
                   and pregln.mandat-prd-cd  = cecrsai.prd-cd
                   and pregln.mandat-prd-num = cecrsai.prd-num
                   and pregln.piece-int      = cecrsai.piece-int
                   and pregln.tot-det        = true
                   and pregln.lig-tot        = viNumeroLigneTotal:
                if pregln.mt <> cecrln.mt
                then assign
                    ttLigneEcriture.cLibelle2     = substitute("&1 &2 &3", string(cecrln.lib-ecr[1], "x(11)"), string(pregln.mt, "->>>>>>>>>>9.99"), pregln.dev-cd)
                    ttLigneEcriture.dMontantTotal = pregln.mt /* DM 0508/0067 */
                .
            end.
        end.
    end.

end procedure.

procedure extraComptable private:
    /*---------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------*/
    define input parameter plAvecEcritureLettree as logical   no-undo.
    define input parameter pcCodeCollectif       as character no-undo.

    define variable viPieceComptable   as integer   no-undo.
    define variable vdMontantDebit     as decimal   no-undo.
    define variable vdMontantCredit    as decimal   no-undo.
    define variable vcLibelle          as character no-undo.
    define variable vdaCompta          as date      no-undo.
    define variable viNumeroLigneTotal as integer   no-undo.

    define buffer pregln     for pregln.
    define buffer cextln     for cextln.
    define buffer cextsai    for cextsai.
    define buffer vbCextsai  for cextsai.
    define buffer ilibnatjou for ilibnatjou.

    vdaCompta = if (pcCodeCollectif = ? or pcCodeCollectif = "") and gcNumeroCompte >= "6" then gdaDebutClasse6 else gdaDebutExercice.
boucle:
    for each cextln no-lock
        where cextln.soc-cd     = giNumeroSociete
          and cextln.etab-cd    = giNumeroMandat
          and cextln.sscoll-cle = pcCodeCollectif
          and cextln.cpt-cd     = gcNumeroCompte
          and cextln.dacompta  >= vdaCompta
          and cextln.dacompta  <= gdaDateFin
          and (plAvecEcritureLettree or cextln.dalettrage = ? or cextln.dalettrage > gdaDateFin):
        assign
            viPieceComptable = 0
            vdMontantDebit   = 0
            vdMontantCredit  = 0
            vcLibelle        = ""
        .
        if cextln.dacompta < gdaDebut then next boucle.

        for first vbCextsai no-lock
            where vbCextsai.soc-cd    = cextln.soc-cd
              and vbCextsai.etab-cd   = cextln.mandat-cd
              and vbCextsai.jou-cd    = cextln.jou-cd
              and vbCextsai.prd-cd    = cextln.mandat-prd-cd
              and vbCextsai.prd-num   = cextln.mandat-prd-num
              and vbCextsai.piece-int = cextln.piece-int:
            if vbCextsai.typenat-cd = 41
            and (month(cextln.dacompta) <> month(gdaDateFin) or year(cextln.dacompta) <> year(gdaDateFin)) then next boucle.

            create ttLigneEcriture.
            assign
                vcLibelle                          = cextln.lib-ecr[1]
                ttLigneEcriture.cSauvegardeLibelle = cextln.lib-ecr[1]
                vdMontantDebit                     = cextln.mt when cextln.sens
                vdMontantCredit                    = cextln.mt when not cextln.sens
            .
            for first cextsai no-lock
                where cextsai.soc-cd    = cextln.soc-cd
                  and cextsai.etab-cd   = cextln.mandat-cd
                  and cextsai.jou-cd    = cextln.jou-cd
                  and cextsai.prd-cd    = cextln.mandat-prd-cd
                  and cextsai.prd-num   = cextln.mandat-prd-num
                  and cextsai.piece-int = cextln.piece-int:
                viPieceComptable = cextsai.piece-compta.
                if cextln.sscoll-cle > "" and cextln.tot-det <> 0
                then for first ilibnatjou no-lock
                    where ilibnatjou.soc-cd    = cextsai.soc-cd
                      and ilibnatjou.etab-cd   = cextsai.etab-cd
                      and ilibnatjou.natjou-cd = cextsai.natjou-cd
                      and ilibnatjou.treso:
                    find first pregln no-lock
                        where pregln.soc-cd    = cextln.soc-cd
                          and pregln.etab-cd   = cextln.etab-cd
                          and pregln.jou-cd    = cextln.jou-cd
                          and pregln.prd-cd    = cextln.prd-cd
                          and pregln.prd-num   = cextln.prd-num
                          and pregln.piece-int = cextln.piece-int
                          and pregln.lig       = cextln.lig no-error.
                    if available pregln
                    then do:
                        viNumeroLigneTotal = pregln.lig-tot.
                        for first pregln no-lock
                            where pregln.soc-cd    = cextsai.soc-cd
                              and pregln.etab-cd   = cextsai.etab-cd
                              and pregln.soc-cd    = cextsai.soc-cd
                              and pregln.jou-cd    = cextsai.jou-cd
                              and pregln.prd-cd    = cextsai.prd-cd
                              and pregln.prd-num   = cextsai.prd-num
                              and pregln.piece-int = cextsai.piece-int
                              and pregln.tot-det
                              and pregln.lig-tot = viNumeroLigneTotal:
                            if pregln.mt <> cextln.mt
                            then vcLibelle = substitute("&1 &2 &3", string(cextln.lib-ecr[1], "x(11)"), string(pregln.mt, ">>>>>>>>>>9.99"), pregln.dev-cd).
                            ttLigneEcriture.dMontantTotal = pregln.mt.
                        end.
                    end.
                end.
                assign
                    ttLigneEcriture.cTypeLigne            = "D"
                    ttLigneEcriture.cLienDetail           = ""
                    ttLigneEcriture.cLienVentilation      = ""
                    ttLigneEcriture.cCollectif            = cextln.sscoll-cle
                    ttLigneEcriture.cLibelle2             = vcLibelle
                    ttLigneEcriture.iNumeroPieceComptable = viPieceComptable
                    ttLigneEcriture.iPieceInterne         = cextln.piece-int
                    ttLigneEcriture.dMontantDebit         = vdMontantDebit
                    ttLigneEcriture.dMontantCredit        = vdMontantCredit
                    ttLigneEcriture.cTypeMouvement        = cextln.type-cle
                    ttLigneEcriture.cCodeJournal          = cextln.jou-cd
                    ttLigneEcriture.dtDateDocument        = cextln.datecr
                    ttLigneEcriture.dtDateEcheance        = cextln.daech
                    ttLigneEcriture.cDocument             = cextln.ref-num
                    ttLigneEcriture.iMouvement            = 1
                    ttLigneEcriture.lExtraComptable       = true
                    ttLigneEcriture.iMandatEntete         = cextln.mandat-cd
                    ttLigneEcriture.iExerciceEntete       = cextln.mandat-prd-cd
                    ttLigneEcriture.iPeriodeEntete        = cextln.mandat-prd-num
                    ttLigneEcriture.rRowid                = rowid(cextln)
                    ttLigneEcriture.dtDateComptable       = cextln.dacompta
                    ttLigneEcriture.cLibelle              = cextln.lib-ecr[1] + cextln.lib-ecr[2]
                    gdTotalDebit                          = gdTotalDebit  + ttLigneEcriture.dMontantDebit
                    gdTotalCredit                         = gdTotalCredit + ttLigneEcriture.dMontantCredit
                    ttLigneEcriture.cLettre               = if cextln.dalettrage <= gdaDateFin or cextln.dalettrage = ? then cextln.lettre else ""
                .
            end.
        end.
    end.
end procedure.

procedure regroupementEcriture private:
    /*------------------------------------------------------------------------------
    Purpose: Regroupement des trésorerie en un Total + création des détails rattachés à ce Total
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viLienRegroupement     as integer no-undo.
    define variable vrRegroupement         as rowid   no-undo.  

    define buffer vbttLigneEcriture       for ttLigneEcriture.
    define buffer vbttVentilationEcriture for ttVentilationEcriture.
    define buffer cecrln                  for cecrln.
    define buffer cecrsai                 for cecrsai.
    define buffer ilibnatjou              for ilibnatjou.
    define buffer pregln                  for pregln.

    {&_proparse_ prolint-nowarn(sortaccess)}
boucle:
    for each ttLigneEcriture
        where ttLigneEcriture.lCumul = false
      , first cecrln no-lock
        where rowid(cecrln) = ttLigneEcriture.rRowid
          and cecrln.tot-det <> 0
      , first cecrsai no-lock
        where cecrsai.soc-cd    = cecrln.soc-cd
          and cecrsai.etab-cd   = cecrln.mandat-cd
          and cecrsai.jou-cd    = cecrln.jou-cd
          and cecrsai.prd-cd    = cecrln.mandat-prd-cd
          and cecrsai.prd-num   = cecrln.mandat-prd-num
          and cecrsai.piece-int = cecrln.piece-int
      , first ilibnatjou no-lock
        where ilibnatjou.soc-cd    = cecrsai.soc-cd
          //and ilibnatjou.etab-cd   = cecrsai.etab-cd
          and ilibnatjou.natjou-cd = cecrsai.natjou-cd
          and ilibnatjou.treso     = true
      , first pregln no-lock
        where pregln.soc-cd    = cecrln.soc-cd
          and pregln.etab-cd   = cecrln.etab-cd
          and pregln.jou-cd    = cecrln.jou-cd
          and pregln.prd-cd    = cecrln.prd-cd
          and pregln.prd-num   = cecrln.prd-num
          and pregln.piece-int = cecrln.piece-int
          and pregln.lig       = cecrln.lig
        break by cecrsai.soc-cd
              by cecrsai.etab-cd
              by cecrsai.jou-cd
              by cecrsai.prd-cd
              by cecrsai.prd-num
              by cecrsai.piece-compta
              by cecrln.coll-cle
              by cecrln.cpt-cd
              by pregln.lig-tot:

        if first-of(pregln.lig-tot) and last-of(pregln.lig-tot) then next boucle.

        if first-of(pregln.lig-tot) then do:
            assign
                viLienRegroupement = viLienRegroupement + 10
                giLienVentilation  = giLienVentilation  + 10
                vrRegroupement     = ?
            .
            /* Cumul des lignes dans le buffer vbttLigneEcriture */
            create vbttLigneEcriture.
            buffer-copy ttLigneEcriture
                     to vbttLigneEcriture
                 assign
                     vbttLigneEcriture.cTypeLigne           = "T"
                     vbttLigneEcriture.cLienDetail          = string(viLienRegroupement, "99999")
                     vbttLigneEcriture.cLienVentilation     = ""
                     vbttLigneEcriture.dMontantDebit        = 0
                     vbttLigneEcriture.dMontantCredit       = 0
                     vbttLigneEcriture.lCumul               = true
                     vbttLigneEcriture.cCodeIndicateur      = "**"
                     vbttLigneEcriture.cDocumentCumul       = vbttLigneEcriture.cDocument
                     vbttLigneEcriture.cDocumentLongCumul   = vbttLigneEcriture.cNumeroDocumentLong
                     vbttLigneEcriture.cLettreCumul         = vbttLigneEcriture.cLettre
                     vbttLigneEcriture.cCollectifCumul      = vbttLigneEcriture.cCollectif
                     vbttLigneEcriture.cDossierTravauxCumul = vbttLigneEcriture.cNumeroDossierTravaux
            .
            vrRegroupement = rowid(vbttLigneEcriture).
        end.
        find  vbttLigneEcriture
        where rowid(vbttLigneEcriture) = vrRegroupement
        no-error.
        assign
            vbttLigneEcriture.dMontantDebit  = vbttLigneEcriture.dMontantDebit  + ttLigneEcriture.dMontantDebit
            vbttLigneEcriture.dMontantCredit = vbttLigneEcriture.dMontantCredit + ttLigneEcriture.dMontantCredit
        .
        if vbttLigneEcriture.dMontantDebit - vbttLigneEcriture.dMontantCredit >= 0
        then assign
            vbttLigneEcriture.dMontantDebit  = vbttLigneEcriture.dMontantDebit - vbttLigneEcriture.dMontantCredit
            vbttLigneEcriture.dMontantCredit = 0
        .
        else assign
            vbttLigneEcriture.dMontantCredit = vbttLigneEcriture.dMontantCredit - vbttLigneEcriture.dMontantDebit
            vbttLigneEcriture.dMontantDebit = 0
        .
        if ttLigneEcriture.cNumeroDossierTravaux <> vbttLigneEcriture.cDossierTravauxCumul then vbttLigneEcriture.cDossierTravauxCumul = "***".
        if ttLigneEcriture.cCollectif            <> vbttLigneEcriture.cCollectifCumul      then vbttLigneEcriture.cCollectifCumul      = "*****".
        if ttLigneEcriture.cLettre               <> vbttLigneEcriture.cLettreCumul         then vbttLigneEcriture.cLettreCumul         = "*****".
        if ttLigneEcriture.cDocument             <> vbttLigneEcriture.cDocumentCumul       then vbttLigneEcriture.cDocumentCumul       = fill("*", 8).
        if ttLigneEcriture.cNumeroDocumentLong   <> vbttLigneEcriture.cDocumentLongCumul   then vbttLigneEcriture.cDocumentLongCumul   = fill("*", 32).

        /* création du détail dans la temp-table ttLigneEcritureDetail */
        create ttLigneEcritureDetail.
        buffer-copy ttLigneEcriture
             except ttLigneEcriture.cTypeLigne
                 to ttLigneEcritureDetail
             assign
                 ttLigneEcritureDetail.cTypeLigne  = "D"
                 ttLigneEcritureDetail.cLienDetail = string(viLienRegroupement,"99999")
        .
        assign
            gdTotalDebit  = gdTotalDebit  - ttLigneEcriture.dMontantDebit
            gdTotalCredit = gdTotalCredit - ttLigneEcriture.dMontantCredit
        .
        /* Deplacement des ttVentilationEcriture (liés à ttLigneEcriture) dans ttVentilationDetail (liés à ttLigneEcritureDetail) */
        for each ttVentilationEcriture
           where ttVentilationEcriture.cLienVentilation = ttLigneEcriture.cLienVentilation:
            create ttVentilationDetail.
            buffer-copy ttVentilationEcriture to ttVentilationDetail.
            /* Nouveau lien temporaire pour identifier et cumuler */
            ttVentilationEcriture.cLienVentilation = "TEMP" + string(giLienVentilation, "99999").
        end.
        delete ttLigneEcriture.

        if last-of(pregln.lig-tot) then do:
            if absolute(vbttLigneEcriture.dMontantDebit - vbttLigneEcriture.dMontantCredit) = vbttLigneEcriture.dMontantTotal and vbttLigneEcriture.dMontantTotal <> ?
            then vbttLigneEcriture.cLibelle2 = vbttLigneEcriture.cSauvegardeLibelle.
            assign
                gdTotalDebit                            = gdTotalDebit  + vbttLigneEcriture.dMontantDebit
                gdTotalCredit                           = gdTotalCredit + vbttLigneEcriture.dMontantCredit
                vbttLigneEcriture.cNumeroDossierTravaux = vbttLigneEcriture.cDossierTravauxCumul
                vbttLigneEcriture.cCollectif            = vbttLigneEcriture.cCollectifCumul
                vbttLigneEcriture.cLettre               = vbttLigneEcriture.cLettreCumul
                vbttLigneEcriture.cDocument             = vbttLigneEcriture.cDocumentCumul
                vbttLigneEcriture.cNumeroDocumentLong   = vbttLigneEcriture.cDocumentLongCumul
            .
            /* Cumul des ventilations des détail à lier au total */
            for each ttVentilationEcriture
                where ttVentilationEcriture.cLienVentilation = "TEMP" + string(giLienVentilation,"99999")
                break by ttVentilationEcriture.cTypeVentilation
                      by ttVentilationEcriture.cCodeVentilation:
                accumulate ttVentilationEcriture.dMontantDebit  (total by ttVentilationEcriture.cCodeVentilation).
                accumulate ttVentilationEcriture.dMontantCredit (total by ttVentilationEcriture.cCodeVentilation).
                accumulate ttVentilationEcriture.dMontantHT     (total by ttVentilationEcriture.cCodeVentilation).
                accumulate ttVentilationEcriture.dMontantTVA    (total by ttVentilationEcriture.cCodeVentilation).
                accumulate ttVentilationEcriture.dMontantTTC    (total by ttVentilationEcriture.cCodeVentilation).

                if last-of(ttVentilationEcriture.cCodeVentilation)
                then do:
                    create vbttVentilationEcriture.
                    {&_proparse_ prolint-nowarn(abbrevkwd)}    // accum n'est pas abbreviated !!!
                    buffer-copy ttVentilationEcriture
                         except ttVentilationEcriture.cLienVentilation
                             to vbttVentilationEcriture
                         assign
                             vbttVentilationEcriture.cLienVentilation = string(giLienVentilation,"99999")
                             vbttVentilationEcriture.dMontantDebit    = (accum total by ttVentilationEcriture.cCodeVentilation ttVentilationEcriture.dMontantDebit )
                             vbttVentilationEcriture.dMontantCredit   = (accum total by ttVentilationEcriture.cCodeVentilation ttVentilationEcriture.dMontantCredit)
                             vbttVentilationEcriture.dMontantHT       = (accum total by ttVentilationEcriture.cCodeVentilation ttVentilationEcriture.dMontantHT    )
                             vbttVentilationEcriture.dMontantTVA      = (accum total by ttVentilationEcriture.cCodeVentilation ttVentilationEcriture.dMontantTVA   )
                             vbttVentilationEcriture.dMontantTTC      = (accum total by ttVentilationEcriture.cCodeVentilation ttVentilationEcriture.dMontantTTC   )
                    .
                end.
            end.
            if can-find(first vbttVentilationEcriture where vbttVentilationEcriture.cLienVentilation = string(giLienVentilation, "99999"))
            then vbttLigneEcriture.cLienVentilation = string(giLienVentilation, "99999").

            /* Suppression de l'ancienne ventilation */
            for each ttVentilationEcriture
               where ttVentilationEcriture.cLienVentilation = "TEMP" + STRING(giLienVentilation,"99999"):
                delete ttVentilationEcriture.
            end.
        end. /* last-of(pregln.lig-tot) */
    end. /* ttLigneEcriture */

end procedure.

procedure creVentilation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer ttLigneEcriture for ttLigneEcriture.
    define parameter buffer cecrln          for cecrln.

    define variable vdVentilationHT  as decimal  no-undo.
    define variable vdVentilationTVA as decimal  no-undo.
    define variable vlLienExiste     as logical  no-undo.

    define buffer alrubhlp  for alrubhlp.
    define buffer aecrdtva  for aecrdtva.
    define buffer cecrlnana for cecrlnana.
    define buffer aligtva   for aligtva.
    define buffer adbtva    for adbtva.
    define buffer pregln    for pregln.
    define buffer ijou      for ijou.

    if cecrln.num-crg > 0 then do:
        /* TODO */
        if not vlLienExiste
        then assign
            giLienVentilation = giLienVentilation + 10
            vlLienExiste      = true
        .
        ttLigneEcriture.cLienVentilation = string(giLienVentilation, "99999").
    end.

    for first pregln no-lock
        where pregln.soc-cd    = cecrln.soc-cd
          and pregln.etab-cd   = cecrln.etab-cd
          and pregln.jou-cd    = cecrln.jou-cd
          and pregln.prd-cd    = cecrln.prd-cd
          and pregln.prd-num   = cecrln.prd-num
          and pregln.piece-int = cecrln.piece-int
          and pregln.lig       = cecrln.lig
          and pregln.num-chq > "":
        if not vlLienExiste
        then assign
            giLienVentilation = giLienVentilation + 10
            vlLienExiste      = true
        .
        ttLigneEcriture.cLienVentilation = string(giLienVentilation, "99999").
    end.
    if can-find(first aecrdtva no-lock
                where aecrdtva.soc-cd    = cecrln.soc-cd
                  and aecrdtva.etab-cd   = cecrln.etab-cd
                  and aecrdtva.jou-cd    = cecrln.jou-cd
                  and aecrdtva.prd-cd    = cecrln.prd-cd
                  and aecrdtva.prd-num   = cecrln.prd-num
                  and aecrdtva.piece-int = cecrln.piece-int
                  and aecrdtva.lig       = cecrln.lig)
    then do:
        /* Ventilation du Quittancement */
        if not vlLienExiste
        then assign
            giLienVentilation = giLienVentilation + 10
            vlLienExiste      = true
        .
        ttLigneEcriture.cLienVentilation = string(giLienVentilation, "99999").
        for each aecrdtva no-lock
            where aecrdtva.soc-cd    = cecrln.soc-cd
              and aecrdtva.etab-cd   = cecrln.etab-cd
              and aecrdtva.jou-cd    = cecrln.jou-cd
              and aecrdtva.prd-cd    = cecrln.prd-cd
              and aecrdtva.prd-num   = cecrln.prd-num
              and aecrdtva.piece-int = cecrln.piece-int
              and aecrdtva.lig       = cecrln.lig:
            accumulate aecrdtva.mtht  (total).
            accumulate aecrdtva.mttva (total).
            accumulate aecrdtva.mtht + aecrdtva.mttva (total).
            create ttVentilationEcriture.
            assign
                ttVentilationEcriture.cTypeVentilation = "QUT"
                ttVentilationEcriture.cLienVentilation = string(giLienVentilation, "99999")
                ttVentilationEcriture.cCodeVentilation = substitute("&1-&2", aecrdtva.cdrub, string(aecrdtva.cdlib, "99"))
                ttVentilationEcriture.dMontantHT       = aecrdtva.mtht
                ttVentilationEcriture.dMontantTVA      = aecrdtva.mttva
                ttVentilationEcriture.dMontantTTC      = aecrdtva.mtht + aecrdtva.mttva
                ttVentilationEcriture.cLibelleRubrique = caps(RecLibRub(aecrdtva.cdrub, aecrdtva.cdlib, integer(string(cecrln.etab-cd) + cecrln.cpt-cd), 0, cecrln.dacompta))
            .
        end.
        create ttVentilationEcriture.
        {&_proparse_ prolint-nowarn(abbrevkwd)}    // accum n'est pas abbreviated !!!
        assign
            ttVentilationEcriture.cTypeVentilation = "QUT"
            ttVentilationEcriture.cLienVentilation = string(giLienVentilation, "99999")
            ttVentilationEcriture.cCodeVentilation = ""
            ttVentilationEcriture.dMontantHT       = accum total(aecrdtva.mtht)
            ttVentilationEcriture.dMontantTVA      = accum total(aecrdtva.mttva)
            ttVentilationEcriture.dMontantTTC      = accum total(aecrdtva.mtht + aecrdtva.mttva)
            ttVentilationEcriture.cLibelleRubrique = "TOTAL"
        .
    end.
    else if can-find(first adbtva no-lock
              where adbtva.soc-cd    = cecrln.soc-cd
                and adbtva.etab-cd   = cecrln.etab-cd
                and adbtva.jou-cd    = cecrln.jou-cd
                and adbtva.prd-cd    = cecrln.prd-cd
                and adbtva.prd-num   = cecrln.prd-num
                and adbtva.piece-int = cecrln.piece-int
                and adbtva.lig       = cecrln.lig)
    then do:
        /* Ventilation des Encaissements */
        if not vlLienExiste
        then assign
            giLienVentilation = giLienVentilation + 10
            vlLienExiste      = true
        .
        assign
            ttLigneEcriture.cLienVentilation = string(giLienVentilation, "99999")
            vdVentilationHT                  = 0
            vdVentilationTVA                 = 0
        .
        for each adbtva no-lock
            where adbtva.soc-cd    = cecrln.soc-cd
              and adbtva.etab-cd   = cecrln.etab-cd
              and adbtva.jou-cd    = cecrln.jou-cd
              and adbtva.prd-cd    = cecrln.prd-cd
              and adbtva.prd-num   = cecrln.prd-num
              and adbtva.piece-int = cecrln.piece-int
              and adbtva.lig       = cecrln.lig:
boucleAligtva:
            for each aligtva no-lock
                where aligtva.soc-cd  = adbtva.soc-cd
                  and aligtva.etab-cd = adbtva.etab-cd
                  and aligtva.num-int = adbtva.num-int:
                /**Ajout OF le 25/04/13**/
                for first ijou no-lock
                     where ijou.soc-cd  = cecrln.soc-cd
                       and ijou.etab-cd = cecrln.mandat-cd
                       and ijou.jou-cd  = cecrln.jou-cd:
                    /* Hors AN : ne prendre les regules >= date de fin d'exercice si exercice cloturé, elles sont reportées en AN et traitées avec les AN */
                    /* DM 0109/0232 24/04/09 la régule n'est pas sur l'exercice de l'écriture : on ne la prend pas */
                    /* AN : ne pas prendre les regules < date de debut d'exercice */
                    if (ijou.natjou-cd <> 9 and adbtva.lib-trt > "" and adbtva.date_decla > f_DaFinClot(cecrln.soc-cd, cecrln.etab-cd, cecrln.dacompta))
                    or (ijou.natjou-cd =  9 and not(adbtva.lib-trt > "" and adbtva.date_decla >= cecrln.dacompta and f_DaFinClot(cecrln.soc-cd, cecrln.etab-cd, cecrln.dacompta) = f_DaFinClot(cecrln.soc-cd, cecrln.etab-cd, adbtva.date_decla)))
                    then next boucleAligtva.
                end.
                create ttVentilationEcriture.
                assign
                    vdVentilationHT                        = vdVentilationHT  + aligtva.mtht
                    vdVentilationTVA                       = vdVentilationTVA + aligtva.mttva
                    ttVentilationEcriture.cTypeVentilation = "ENC"
                    ttVentilationEcriture.cLienVentilation = string(giLienVentilation, "99999")
                    ttVentilationEcriture.cCodeVentilation = substitute("&1-&2", aligtva.cdrub, string(aligtva.cdlib, "99"))
                    ttVentilationEcriture.dMontantHT       = aligtva.mtht
                    ttVentilationEcriture.dMontantTVA      = aligtva.mttva
                    ttVentilationEcriture.dMontantTTC      = aligtva.mtht + aligtva.mttva
                    ttVentilationEcriture.cLibelleRubrique = caps(recLibRub(integer(aligtva.cdrub),
                                                                        integer(aligtva.cdlib),
                                                                        integer(string(cecrln.etab-cd) + cecrln.cpt-cd),
                                                                        0,
                                                                        cecrln.dacompta))
                .
            end.
            /**Ajout OF le 25/04/13**/
            if not can-find(first aligtva no-lock
                            where aligtva.soc-cd  = adbtva.soc-cd
                              and aligtva.etab-cd = adbtva.etab-cd
                              and aligtva.num-int = adbtva.num-int)
            then do:
                create ttVentilationEcriture.
                assign
                    vdVentilationHT                        = vdVentilationHT  + adbtva.mt - adbtva.mttva // vdVentilationHT  + adbtva.mt
                    vdVentilationTVA                       = vdVentilationTVA + adbtva.mttva
                    ttVentilationEcriture.cTypeVentilation = "ENC"
                    ttVentilationEcriture.cLienVentilation = string(giLienVentilation, "99999")
                    ttVentilationEcriture.cCodeVentilation = "999-99"
                    ttVentilationEcriture.dMontantHT       = adbtva.mt - adbtva.mttva // adbtva.mt
                    ttVentilationEcriture.dMontantTVA      = adbtva.mttva
                    ttVentilationEcriture.dMontantTTC      = adbtva.mt // adbtva.mt + adbtva.mttva
                    ttVentilationEcriture.cLibelleRubrique = "NON VENTILE"
                .
            end.
        end.
        /* Total */
        create ttVentilationEcriture.
        assign
            ttVentilationEcriture.cTypeVentilation = "ENC"
            ttVentilationEcriture.cLienVentilation = string(giLienVentilation, "99999")
            ttVentilationEcriture.cCodeVentilation = ""
            ttVentilationEcriture.dMontantHT       = vdVentilationHT
            ttVentilationEcriture.dMontantTVA      = vdVentilationTVA
            ttVentilationEcriture.dMontantTTC      = vdVentilationHT + vdVentilationTVA
            ttVentilationEcriture.cLibelleRubrique = "TOTAL"
        .
    end.
    else if can-find(first cecrlnana no-lock
                    where cecrlnana.soc-cd    = cecrln.soc-cd
                      and cecrlnana.etab-cd   = cecrln.etab-cd
                      and cecrlnana.jou-cd    = cecrln.jou-cd
                      and cecrlnana.prd-cd    = cecrln.prd-cd
                      and cecrlnana.prd-num   = cecrln.prd-num
                      and cecrlnana.piece-int = cecrln.piece-int
                      and cecrlnana.lig       = cecrln.lig)
    then do:
        /* Ventilation Analytique */
        if not vlLienExiste
        then assign
            giLienVentilation = giLienVentilation + 10
            vlLienExiste      = true
        .
        ttLigneEcriture.cLienVentilation = string(giLienVentilation, "99999").
        for each cecrlnana no-lock
            where cecrlnana.soc-cd    = cecrln.soc-cd
              and cecrlnana.etab-cd   = cecrln.etab-cd
              and cecrlnana.jou-cd    = cecrln.jou-cd
              and cecrlnana.prd-cd    = cecrln.prd-cd
              and cecrlnana.prd-num   = cecrln.prd-num
              and cecrlnana.piece-int = cecrln.piece-int
              and cecrlnana.lig       = cecrln.lig:
            find first alrubhlp no-lock
                 where alrubhlp.soc-cd   = cecrlnana.soc-cd
                   and alrubhlp.cdlng    = mtoken:iCodeLangueSession
                   and alrubhlp.rub-cd   = cecrlnana.ana1-cd
                   and alrubhlp.ssrub-cd = cecrlnana.ana2-cd no-error.
            create ttVentilationEcriture.
            assign
                ttVentilationEcriture.cTypeVentilation   = "ANA"
                ttVentilationEcriture.cLienVentilation   = string(giLienVentilation, "99999")
                ttVentilationEcriture.cCodeVentilation   = substitute("&1-&2-&3&4"
                                                                    , string(cecrlnana.ana1-cd)
                                                                    , string(cecrlnana.ana2-cd)
                                                                    , string(cecrlnana.ana3-cd)
                                                                    , if cecrlnana.ana4-cd > "" then "-" + string(cecrlnana.ana4-cd) else "    ")
                ttVentilationEcriture.dMontantDebit      = cecrlnana.mt * if cecrlnana.sens then 1 else 0
                ttVentilationEcriture.dMontantCredit     = cecrlnana.mt * if cecrlnana.sens then 0 else 1
                ttVentilationEcriture.cLibelleAnalytique = substitute("&1 &2", cecrlnana.lib-ecr[1], cecrlnana.lib-ecr[2])
                ttVentilationEcriture.cLibelleRubrique   = if available alrubhlp then alrubhlp.libssrub else ""
            .
        end.
    end.

end procedure.

