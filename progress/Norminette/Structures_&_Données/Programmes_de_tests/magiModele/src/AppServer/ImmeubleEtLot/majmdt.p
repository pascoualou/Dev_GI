/*------------------------------------------------------------------------
File        : majmdt.p
Purpose     : Mise à jour des mandats
Author(s)   : LGI/JR 1997/03/28 - kantena - 2016/12/20
Notes       : remise en forme
11/10/2011  SY  Correction Erreur create ijou (CreJournaux)
26/04/2013  OF  On relance la création des journaux même si le mandat existe déjà,
                au cas où il y ait eu un plantage à la création
11/06/2013  OF  0113/0242 Gestion nouveau champ ietab.lbrech
14/11/2013  OF  Modif n°041 incomplète (champ ietab.lbrech)
19/11/2013  OF  Ajout du numéro de mandat dans ietab.lbrech
+--------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/listeJournaux.i}
{preprocesseur/nature2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define temp-table ttParam no-undo
    field iCodeSoc   as integer
    field iCodeEtab  as integer
    field cNomEtab   as character
    field cAdr1Etab  as character
    field cAdr2Etab  as character
    field cCpEtab    as character
    field cVilleEtab as character
    field cCodePays  as character
    field iPeriode   as integer   initial 99
    field cDateDebut as character initial "999"
    field cDateFin   as character initial "999"
    field cSiret     as character initial "00000000000000"
    field cSiren     as character initial "000000000"
    field cApe       as character
    field iSoumis    as integer   initial 1
    field iInd       as integer   initial 1
    field iTyperec   as integer   initial 1
    field iTypedep   as integer   initial 0
    field iRegime    as integer   initial 1
    field cNatMdt    as character
    field cFourn     as character
    field cModReg    as character
    field cLstMdt    as character
.
{application/include/glbsepar.i}

/*** Liste de fonctions SADB : Numéro de l'agence à laquelle est rattachée le mandat en cours de création ***/
/*{c:\magi\appli_v11\gidev\comm\LibSadb.i}*/
define variable giPeriode            as integer   no-undo.
define variable giReference          as integer   no-undo.
define variable gdaDebutExercice1    as date      no-undo.
define variable gdaDebutExercice2    as date      no-undo.
define variable gdaFinExercice1      as date      no-undo.
define variable gdaFinExercice2      as date      no-undo.
define variable giNombreMoisPrd      as integer   no-undo.
define variable giNombreExercice     as integer   no-undo.
define variable gcCodeDevise         as character no-undo.
define variable gcCodeDeviseEuro     as character no-undo.
define variable gcLibellePays        as character no-undo.
define variable glComptaParImmeuble  as logical   no-undo.
define variable giprofil             as integer   no-undo.
define variable gdLongCompteCumul    as decimal   no-undo.
define variable gdLongCompteGeneral  as decimal   no-undo.
define variable gdLongAnalytique1    as decimal   no-undo.
define variable gdLongAnalytique2    as decimal   no-undo.
define variable gdLongAnalytique3    as decimal   no-undo.
define variable gdLongAnalytique4    as decimal   no-undo.
define variable gcLibelleAnalytique1 as character no-undo.
define variable gcLibelleAnalytique2 as character no-undo.
define variable gcLibelleAnalytique3 as character no-undo.
define variable gcLibelleAnalytique4 as character no-undo.
define variable gdaJdate             as date      no-undo.

    function noAgence returns character private(piContratSecondaire as integer, piProfilMandat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne le numéro d'agence d'un mandat + Lib de l'agence + banque de l'agence liée au profil du mandat
    Notes  : vient de la fonction NoAgence de gidev\comm\LibSadb.i
    ------------------------------------------------------------------------------*/
    define variable vcLibelle as character no-undo.
    define buffer ctrat for ctrat.
    define buffer ctctt for ctctt.

    case piProfilMandat:
        when 21 then find first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.noct2 = piContratSecondaire no-error.
        when 91 then find first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = {&TYPECONTRAT-mandat2Syndic}
              and ctctt.noct2 = piContratSecondaire no-error.
    end case.
    if available ctctt
    then for first ctrat no-lock
        where ctrat.tpcon = ctctt.tpct1
          and ctrat.nocon = ctctt.noct1:
        vcLibelle = substitute("&2&1&3&1", separ[1], string(ctrat.nocon), ctrat.noree).
        if num-entries(ctrat.lbdiv, separ[1]) > 1
        then case piProfilMandat:
            when 21 then vcLibelle = vcLibelle + entry(1, ctrat.lbdiv, separ[1]).
            when 91 then vcLibelle = vcLibelle + entry(2, ctrat.lbdiv, separ[1]).
        end case.
    end.
    return vcLibelle.

end function.

function rattachementBanque returns logical private(piCodeSociete as integer, piEtablissement as integer, piProfilMandat as integer, pcJournalBanque as character):
    /*------------------------------------------------------------------------------
    Purpose: Crée le rattachement bancaire 'défaut-autre' à une banque globale
    Notes  : vient de la fonction RchtBque de gidev\comm\ModCpta.i
    ------------------------------------------------------------------------------*/
    define buffer ietab   for ietab.
    define buffer vbIetab for ietab.
    define buffer ijou    for ijou.
    define buffer aetabln for aetabln.

    find first vbIetab no-lock
        where vbIetab.soc-cd    = piCodeSociete
          and vbIetab.profil-cd = piProfilMandat no-error.
    find first ijou no-lock
        where ijou.soc-cd  = piCodeSociete
          and ijou.etab-cd = vbIetab.etab-cd
          and ijou.jou-cd  = pcJournalBanque no-error.
    if available vbIetab and available ijou
    then for first ietab exclusive-lock
        where ietab.soc-cd  = piCodeSociete
          and ietab.etab-cd = piEtablissement:
        if not can-find(first aetabln no-lock
            where aetabln.soc-cd    = ietab.soc-cd
              and aetabln.etab-cd   = ietab.etab-cd
              and aetabln.mandat-cd = vbIetab.etab-cd
              and aetabln.jou-cd    = ijou.jou-cd)
        then do:
            create aetabln.
            assign
                aetabln.soc-cd    = ietab.soc-cd
                aetabln.etab-cd   = ietab.etab-cd
                aetabln.mandat-cd = vbIetab.etab-cd
                aetabln.jou-cd    = ijou.jou-cd
            .
        end.
        assign
            ietab.bqjou-cd    = ijou.jou-cd
            ietab.bqprofil-cd = vbIetab.profil-cd
        .
        return true.
    end.
    return false.

end function.

procedure rpRunLie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par pontImmeubleCompta.p
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttParam.
    define output parameter piRetour as integer no-undo.

    define variable viCompteur  as integer  no-undo.
    define buffer ctrat    for ctrat.
    define buffer aprof    for aprof.
    define buffer ilibpays for ilibpays.
    define buffer ietab    for ietab.
    define buffer iparmdt  for iparmdt.

    /* Lecture du parametre d'entree et chargement des variables contenant les infos sur le mandat  */
    find first ttParam no-error.
    if not available ttParam then do:
        piRetour = 3.
        return.
    end.
    /* Recherche du profil du mandat cree */
    {&_proparse_ prolint-nowarn(wholeindex)}
    find first aprof no-lock
        where aprof.mandatdeb <= ttParam.iCodeEtab
          and aprof.mandatfin >= ttParam.iCodeEtab no-error.
    if not available aprof then do:
        piRetour = 3.
        return.
    end.
    giprofil = aprof.profil-cd.

    /* Code Pays */
    find first ilibpays no-lock
        where ilibpays.soc-cd     = ttParam.iCodeSoc
          and ilibpays.libpays-cd = ttParam.cCodePays no-error.
    if not available ilibpays then do:
        piRetour = 4.
        return.
    end.
    assign
        gcLibellePays = ilibpays.lib
        giPeriode     = ttParam.iPeriode       /* Mise a jour de la periodicite pour les mandats de gerance */
    .
    if giprofil = 91 and giPeriode = 0 then do:
        piRetour = 40.
        return.
    end.
    find first ctrat no-lock
        where ctrat.tpcon = (if giprofil = 21 then {&TYPECONTRAT-mandat2Gerance} else {&TYPECONTRAT-mandat2Syndic})
          and ctrat.nocon = ttParam.iCodeEtab no-error.
    if available ctrat and ctrat.fgprov then do:
        piRetour = 0.
        return.
    end.

    {&_proparse_ prolint-nowarn(nowait)}
    find first ietab exclusive-lock
        where ietab.soc-cd  = ttParam.iCodeSoc
          and ietab.etab-cd = ttParam.iCodeEtab no-error.
    if available ietab
    then do:          /*  Mise à jour du mandat  */
        assign
            ietab.nom    = ttParam.cNomEtab
            ietab.adr[1] = ttParam.cAdr1Etab
            ietab.adr[2] = ttParam.cAdr2Etab
            ietab.ville  = ttParam.cVilleEtab
            ietab.cp     = ttParam.cCpEtab
            ietab.pays   = gcLibellePays
            ietab.period = giPeriode
            ietab.siret  = ttParam.cSiret
            ietab.siren  = ttParam.cSiren
            ietab.ape    = ttParam.cApe
            ietab.lbrech = substitute('&1 - &2 &3 &4&5 (&6)',
                               if available ctrat then ctrat.lbnom else ttParam.cNomEtab,
                               ttParam.cAdr1Etab,
                               ttParam.cCpEtab,
                               ttParam.cVilleEtab,
                               fill(" ", 150),
                               string(ietab.etab-cd))
            ietab.damod    = today
            ietab.ihmod    = mtime
            ietab.usridmod = mtoken:cUser                                              
        .
        if giprofil = 21 then do:
            {&_proparse_ prolint-nowarn(nowait)}
            find first iparmdt exclusive-lock
                where iparmdt.soc-cd  = ietab.soc-cd
                  and iparmdt.etab-cd = ietab.etab-cd no-error.
            if not available iparmdt then do:
                create iparmdt.
                assign
                    iparmdt.soc-cd  = ietab.soc-cd
                    iparmdt.etab-cd = ietab.etab-cd
                .
            end.
            assign
                iparmdt.fg-mandat-ind     = (ttParam.iInd = 0)
                iparmdt.fg-soumis         = (ttParam.iSoumis = 0)
                iparmdt.fg-type-decla-rec = (ttParam.iTyperec = 0)
                iparmdt.fg-type-decla-dep = (ttParam.iTypedep = 0)
                iparmdt.fg-regime         = (ttParam.iRegime = 0)
            .
        end.
        run creFour.
        run creJournaux ({&JOURNAUX-commun}, "").
        case giprofil:
            when 21 then do:
                run CreJournaux ({&JOURNAUX-gerance}, "").
                run CreJournaux ("", "CPG").
            end.
            when 91 then  do:
                run CreJournaux ({&JOURNAUX-copro}, "").
                run CreJournaux ("", "CPC").
            end.
        end case.
   end. /* Mise a jour mandat */
   else do:
        run CtrlParam(output piRetour).
        if piRetour > 0 then return.

        run SupTables. /* Suppression de certaines tables avant re-creation */
        run CreMdt(if available ctrat then ctrat.lbnom else ttParam.cNomEtab).
        run creFour.
        run creJournaux ({&JOURNAUX-commun}, "").
        case giprofil:
            when 21 then do:
                run CreJournaux ({&JOURNAUX-gerance}, "").
                run CreJournaux ("", input "CPG").
            end.
            when 91 then  do:
                run CreJournaux ({&JOURNAUX-copro}, "").
                run CreJournaux ("", "CPC").
            end.
        end case.
    end.

    /* Mise a jour du fournisseur AFUL sur tous les mandats coproprietaires**/
    if (ttParam.cNatMdt = {&NATURECONTRAT-AFUL} or ttParam.cNatMdt = {&NATURECONTRAT-ASL})
    and trim(ttParam.cFourn) > ""
    then do viCompteur = 1 to num-entries(ttParam.cLstMdt, "@"):
        run creationFournisseur(if available ietab then ietab.dev-cd else '', integer(entry(viCompteur, ttParam.cLstMdt, "@")) - 90000).
    end.

end procedure.

procedure ctrlParam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter piRetour as integer no-undo.

    define variable viCompteur as integer no-undo.
    define variable vdaFin1    as date    no-undo.
    define variable vdaDebut2  as date    no-undo.
    define variable vdaFin2    as date    no-undo.

    define buffer isoc    for isoc.
    define buffer ietab   for ietab.
    define buffer aparm   for aparm.
    define buffer idev    for idev.
    define buffer cttac   for cttac.
    define buffer ifour   for ifour.
    define buffer ccptcol for ccptcol.

    /* contrôle sur la cohérence des paramètres */
    if giprofil = 91 then do:
        if ttParam.cDateDebut = "999" then do:
            piRetour = 30.
            return.
        end.
        if ttParam.cDateFin = "999" then do:
            piRetour = 31.
            return.
        end.
        gdaDebutExercice1 = date(ttParam.cDateDebut) no-error.
        if error-status:error
        then do:
            piRetour = 33.
            return.
        end.
        gdaFinExercice1 = date(ttParam.cDateFin) no-error.
        if error-status:error then do:
            piRetour = 34.
            return.
        end.
        if gdaDebutExercice1 > gdaFinExercice1 then do:
            piRetour = 32.
            return.
        end.
        gdaJdate = gdaDebutExercice1 - 1.
        if month(gdaJdate) = month(gdaDebutExercice1) then do:
            piRetour = 33.
            return.
        end.
        gdaJdate = gdaFinExercice1 + 1.
        if month(gdaJdate) = month(gdaFinExercice1) then do:
            piRetour = 34.
            return.
        end.
    end.

    /* recherche du cabinet associé à la société du mandat */
    find first isoc no-lock
        where isoc.soc-cd = ttParam.iCodeSoc no-error.
    if not available isoc then do:
        piRetour = 1.
        return.
    end.
    find first isoc no-lock
        where isoc.soc-cd = ttParam.iCodeSoc + 10000 no-error.
    if not available isoc then do:
        piRetour = 11.
        return.
    end.
    /* Recherche du seul etablissement dependant du cabinet; On se base sur la Gérance Globale */
    find first ietab no-lock
        where ietab.soc-cd    = ttParam.iCodeSoc
          and ietab.profil-cd = 20 no-error.
    if not available ietab then do:
        piRetour = 12.
        return.
    end.
    giNombreExercice = ietab.nbex.
    if giprofil = 21
    then assign
        gdaDebutExercice1 = ietab.dadebex1
        gdaFinExercice1   = ietab.dafinex1
        gdaDebutExercice2 = ietab.dadebex2
        gdaFinExercice2   = ietab.dafinex2
    .
    else do:
        assign
            gdaDebutExercice2 = gdaFinExercice1 + 1
            vdaFin1           = gdaFinExercice1
        .
        do viCompteur = 1 to 12:
            run calculDate(vdaFin1, output vdaDebut2, output vdaFin2).
            vdaFin1 = vdaFin2.
        end.
        gdaFinExercice2 = vdaFin2.
    end.
    giNombreMoisPrd = month(gdaFinExercice1) - month(gdaDebutExercice1) + 12 * (year(gdaFinExercice1) - year(gdaDebutExercice1)) + 1.

    /* Recherche du mandat de profil 10 pour la devise du mandat créé */
    find first ietab no-lock
        where ietab.soc-cd    = ttParam.iCodeSoc
          and ietab.profil-cd = 10 no-error.
    if not available ietab then do:
        piRetour = 2.
        return.
    end.
    assign
        gcCodeDevise     = ietab.dev-cd
        gcCodeDeviseEuro = ietab.dev-euro
    .
    /* controle de la devise de contre valeur */
    find first idev no-lock
        where idev.soc-cd = ttParam.iCodeSoc
          and idev.dev-cd = gcCodeDevise no-error.
    if available idev and idev.fg-euro and (gcCodeDeviseEuro = ? or gcCodeDeviseEuro = "") then do:
        piRetour = 2.
        return.
    end.
    /* Longueur du compte de cumul */
    find first aparm no-lock
        where aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and aparm.tppar   = "TETAB"
          and aparm.cdpar   = "1" no-error.
    if not available aparm then do:
        piRetour = 21.
        return.
    end.
    gdLongCompteCumul = aparm.zone1.
    /* Longueur comptes generaux */
    find first aparm no-lock
        where aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and aparm.tppar   = "TETAB"
          and aparm.cdpar   = "2" no-error.
    if not available aparm then do:
        piRetour = 22.
        return.
    end.
    gdLongCompteGeneral = aparm.zone1.
    /* Longueur et libelle niveau analytique 1 */
    find first aparm no-lock
        where aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and aparm.tppar   = "TETAB"
          and aparm.cdpar   = "3" no-error.
    if not available aparm then do:
        piRetour = 23.
        return.
    end.
    assign
        gdLongAnalytique1    = aparm.zone1
        gcLibelleAnalytique1 = outilTraduction:getLibelleCompta(aparm.nome2)
    .
    /* Longueur et libelle niveau analytique 2 */
    find first aparm no-lock
        where aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and aparm.tppar   = "TETAB"
          and aparm.cdpar   = "4" no-error.
    if not available aparm then do:
        piRetour = 24.
        return.
    end.
    assign
        gdLongAnalytique2    = aparm.zone1
        gcLibelleAnalytique2 = outilTraduction:getLibelleCompta(aparm.nome2)
    .
    /* Longueur et libelle niveau analytique 3 */
    find first aparm no-lock
        where aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and aparm.tppar   = "TETAB"
          and aparm.cdpar   = "5" no-error.
    if not available aparm then do:
        piRetour = 25.
        return.
    end.
    assign
        gdLongAnalytique3    = aparm.zone1
        gcLibelleAnalytique3 = outilTraduction:getLibelleCompta(aparm.nome2)
    .
    /* Longueur et libelle niveau analytique 4 */
    find first aparm no-lock
        where aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and aparm.tppar   = "TETAB"
          and aparm.cdpar   = "6" no-error.
    if not available aparm then do:
        piRetour = 26.
        return.
    end.
    assign
        gdLongAnalytique4    = aparm.zone1
        gcLibelleAnalytique4 = outilTraduction:getLibelleCompta(aparm.nome2)
    .
    if giprofil = 91 then do:
        /* Paramètrage standard : visiblement plus utilisé */
        find first aparm no-lock
            where aparm.soc-cd  = 0
              and aparm.etab-cd = 0
              and aparm.tppar   = "TCPIM" no-error.
        if available aparm then glComptaParImmeuble = true.
        /* Paramètrage tache cloture manuelle */
        find first cttac no-lock
            where cttac.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and cttac.nocon = ttParam.iCodeEtab
              and cttac.tptac = "04157" no-error.
        if available cttac then glComptaParImmeuble = true.
    end.

    /* recherche du mandat de reference */
    find first ietab no-lock
        where ietab.soc-cd = ttParam.iCodeSoc
          and ietab.profil-cd = (giprofil - 1) no-error.
    if not available ietab then do:
        piRetour = 10.
        return.
    end.
    giReference = ietab.etab-cd.
    /* Recherche du regroupement fournisseur */
    find first ccptcol no-lock
        where ccptcol.soc-cd = ttParam.iCodeSoc
          and ccptcol.tprole = 12 no-error.
    if not available ccptcol then do:
        piRetour = 51.
        return.
    end.
    /* Recherche du fournisseur cabinet */
    find first ifour no-lock
        where ifour.soc-cd   = ttParam.iCodeSoc
          and ifour.four-cle = "00000" no-error.
    if not available ifour then do:
        piRetour = 52.
        return.
    end.
    /* Recherche du fournisseur divers */
    find first ifour no-lock
        where ifour.soc-cd   = ttParam.iCodeSoc
          and ifour.four-cle = "99999" no-error.
    if not available ifour then do:
        piRetour = 53.
        return.
    end.

end procedure.

procedure creMdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcLibelle as character no-undo.

    define variable vcAgence as character no-undo.
    define buffer ietab   for ietab.
    define buffer iparmdt for iparmdt.

//gga toto ATTENTION il existe un programme trigger trans/gene/inter.p pour la maj de cette table 
    create ietab.
    assign
        ietab.soc-cd        = ttParam.iCodeSoc
        ietab.etab-cd       = ttParam.iCodeEtab
        ietab.nom           = ttParam.cNomEtab
        ietab.adr[1]        = ttParam.cAdr1Etab
        ietab.adr[2]        = ttParam.cAdr2Etab
        ietab.ville         = ttParam.cVilleEtab
        ietab.pays          = gcLibellePays
        ietab.cp            = ttParam.cCpEtab
        ietab.reference     = string(ttParam.iCodeSoc)
        ietab.exercice      = false
        ietab.dadebex1      = gdaDebutExercice1
        ietab.dafinex1      = gdaFinExercice1
        ietab.dadebex2      = gdaDebutExercice2
        ietab.dafinex2      = gdaFinExercice2
        ietab.nbprd         = giNombreMoisPrd
        ietab.nbex          = giNombreExercice
        ietab.fg-cptim      = glComptaParImmeuble
        ietab.dev-cd        = gcCodeDevise
        ietab.dev-euro      = gcCodeDeviseEuro
        ietab.profil-cd     = giprofil
        ietab.comptabilite  = true
        ietab.commercial    = false
        ietab.tresorerie    = true
        ietab.general       = true
        ietab.analytique    = true
        ietab.budgetaire    = false
        ietab.budget1a5     = false
        ietab.budget6a9     = false
        ietab.rappro-dsq    = true
        ietab.souscol       = true
        ietab.valecr        = false
        ietab.invest        = false
        ietab.conso-ana     = false
        ietab.flag-rs-relan = true
        ietab.lgcum         = gdLongCompteCumul
        ietab.lgcpt         = gdLongCompteGeneral
        ietab.lgniv1        = gdLongAnalytique1
        ietab.lgniv2        = gdLongAnalytique2
        ietab.lgniv3        = gdLongAnalytique3
        ietab.lgniv4        = gdLongAnalytique4
        ietab.libniv1       = gcLibelleAnalytique1
        ietab.libniv2       = gcLibelleAnalytique2
        ietab.libniv3       = gcLibelleAnalytique3
        ietab.libniv4       = gcLibelleAnalytique4
        ietab.siret         = ttParam.cSiret
        ietab.siren         = ttParam.cSiren
        ietab.ape           = ttParam.cApe
        ietab.period        = giPeriode
        ietab.prd-cd-1      = 5
        ietab.prd-cd-2      = 6
        ietab.lbrech        = substitute('&1 - &2 &3 &4&5 (&6)',
                                  pcLibelle,
                                  ttParam.cAdr1Etab,
                                  ttParam.cCpEtab,
                                  ttParam.cVilleEtab,
                                  fill(" ", 150),
                                  string(ietab.etab-cd))
        ietab.dacrea        = today
        ietab.ihcrea        = mtime
        ietab.usrid         = mtoken:cUser
        ietab.damod         = today
        ietab.ihmod         = mtime
        ietab.usridmod      = mtoken:cUser                          
    .
    if giprofil = 21 then do:
        /* Création interface mandat  */
        {&_proparse_ prolint-nowarn(nowait)}
        find first iparmdt exclusive-lock
            where iparmdt.soc-cd = ietab.soc-cd
             and iparmdt.etab-cd = ietab.etab-cd no-error.
        if not available iparmdt then do:
            create iparmdt.
            assign
                iparmdt.soc-cd  = ietab.soc-cd
                iparmdt.etab-cd = ietab.etab-cd
            .
        end.
        assign
            iparmdt.fg-mandat-ind     = (ttParam.iInd = 0)
            iparmdt.fg-soumis         = (ttParam.iSoumis = 0)
            iparmdt.fg-type-decla-rec = (ttParam.iTyperec = 0)
            iparmdt.fg-type-decla-dep = (ttParam.iTypedep = 0)
            iparmdt.fg-regime         = (ttParam.iRegime = 0)
        .
    end.
    
    if giprofil = 21
    then run crePeriode (ietab.prd-cd-1 - 1, date(month(gdaDebutExercice1), 1, year(gdaDebutExercice1) - 1), gdaDebutExercice1 - 1).
    run crePeriode (ietab.prd-cd-1, gdaDebutExercice1, gdaFinExercice1).
    run crePeriode (ietab.prd-cd-2, gdaDebutExercice2, gdaFinExercice2).
    run duplication('parenc').
    run duplication('csscptcol').
    run duplication('itypemvt').
    run duplication('cbilna').
    run duplication('cbilnb').
    run duplication('cbilnc').
    run duplication('cbilnd').
    run duplication('ccdbilan').
    run duplication('crepbil').
    run duplication('crepbiln').
    if giprofil = 21 or giprofil = 91 then do:
        /***************************** Ce mandat est-il rattaché à une agence ?  **********************
        La fonction NoAgence retourne : 'N°' + | 'Lib Agence' + 'Code journal de la banque de l'agence'
        La fonction rattachementBanque rattache le mandat en cours de création à la banque par défaut de l'agence
        **********************************************************************************************/
        vcAgence = noAgence(ietab.etab-cd, ietab.profil-cd).
        if vcAgence > "" and num-entries(vcAgence, separ[1]) >= 3 and entry(3, vcAgence, separ[1]) > ""
        then rattachementBanque(ttParam.iCodeSoc, ietab.etab-cd, ietab.profil-cd - 1, entry(3, vcAgence, separ[1])). // Rattachement à la banque de l'agence
    end.

end procedure.

procedure crefour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer iFour for iFour.

    /* Recherche du fournisseur cabinet */
    find first ifour no-lock
        where ifour.soc-cd     = ttParam.iCodeSoc
          and ifour.four-cle   = "00000" no-error.
    if available ifour then run crecptfour ("00000", ifour.nom).
    /* Recherche du fournisseur divers */
    find first ifour no-lock
        where ifour.soc-cd     = ttParam.iCodeSoc
          and ifour.four-cle   = "99999" no-error.
    if available ifour then run crecptfour ("99999", ifour.nom).

end procedure.

procedure crecptfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcCompte  as character no-undo.
    define input parameter pcLibelle as character no-undo.

    define variable viType-cd  as integer no-undo.
    define variable vlFg-conf  as logical no-undo.
    define variable vlFg-tiers as logical no-undo.
    define variable vlExiste   as logical no-undo.
    define buffer ccptcol   for ccptcol.
    define buffer csscptcol for csscptcol.
    define buffer csscpt    for csscpt.
    define buffer actrc     for actrc.
    define buffer ccpt      for ccpt.

    for first ccptcol no-lock    /* pour le regroupement fournisseur */
        where ccptcol.soc-cd = ttParam.iCodeSoc
          and ccptcol.tprole = 12
      , each csscptcol no-lock    /* Pour tous les mandats de la société */
        where csscptcol.soc-cd  = ttParam.iCodeSoc
          and csscptcol.etab-cd = ttParam.iCodeEtab:
        if csscptcol.coll-cle = ccptcol.coll-cle
        then do:
boucle:
            for each actrc no-lock
                where actrc.cptdeb = csscptcol.sscoll-cpt:
                if actrc.fg-coll-cle and actrc.cptdeb <= csscptcol.sscoll-cpt
                                     and actrc.cptfin >= csscptcol.sscoll-cpt
                                     and actrc.tprole  = ccptcol.tprole
                then do:
                    assign
                        viType-cd  = actrc.type-cd
                        vlFg-conf  = actrc.fg-conf
                        vlFg-tiers = actrc.fg-tiers
                        vlExiste   = true
                    .
                    leave boucle.
                end.
            end.
            if not vlExiste
            then for first actrc no-lock
                where actrc.fg-coll-cle
                  and actrc.cptdeb <= csscptcol.sscoll-cpt
                  and actrc.cptfin >= csscptcol.sscoll-cpt
                  and actrc.tprole  = ccptcol.tprole:
                assign
                    viType-cd  = actrc.type-cd
                    vlFg-conf  = actrc.fg-conf
                    vlFg-tiers = actrc.fg-tiers
                .
            end.
            /* Test si existence du compte général       */
            find first ccpt no-lock
                where ccpt.soc-cd   = ttParam.iCodeSoc
                  and ccpt.coll-cle = ccptcol.coll-cle
                  and ccpt.cpt-cd   = pcCompte no-error.
            if not available ccpt then do:
                create ccpt.
                assign
                    ccpt.soc-cd      = ttParam.iCodeSoc
                    ccpt.etab-cd     = 0
                    ccpt.cpt-cd      = pcCompte
                    ccpt.libtype-cd  = ccptcol.libtype-cd
                    ccpt.centra      = ccptcol.centra
                    ccpt.libcat-cd   = ccptcol.libcat-cd
                    ccpt.cptaffect   = ccptcol.cptaffect
                    ccpt.tva-oblig   = false
                    ccpt.cptprov-num = ccptcol.cptprov-num
                    ccpt.cpt-int     = ccptcol.coll-cle + pcCompte
                    ccpt.coll-cle    = ccptcol.coll-cle
                    ccpt.taxe-cd     = 0
                    ccpt.libimp-cd   = ccptcol.libimp-cd
                    ccpt.libsens-cd  = ccptcol.libsens-cd
                    ccpt.type-cd     = viType-cd
                    ccpt.fg-conf     = vlFg-conf
                    ccpt.fg-tiers    = vlFg-tiers
                    ccpt.sscpt-cd    = pcCompte
                    ccpt.fg-libsoc   = ccptcol.fg-libsoc
                    ccpt.lib         = pcLibelle
                .
            end.

            /* Test si existence du compte individuel     */
            find first csscpt no-lock
                where csscpt.soc-cd     = ttParam.iCodeSoc
                  and csscpt.etab-cd    = ttParam.iCodeEtab
                  and csscpt.coll-cle   = csscptcol.coll-cle
                  and csscpt.sscoll-cle = csscptcol.sscoll-cle
                  and csscpt.cpt-cd     = pcCompte no-error.
            if not available csscpt then do:
                create csscpt.
                assign
                    csscpt.soc-cd     = ttParam.iCodeSoc
                    csscpt.etab-cd    = ttParam.iCodeEtab
                    csscpt.sscoll-cle = csscptcol.sscoll-cle
                    csscpt.cpt-cd     = pcCompte
                    csscpt.cpt-int    = csscptcol.sscoll-cpt + pcCompte
                    csscpt.coll-cle   = csscptcol.coll-cle
                    csscpt.facturable = csscptcol.facturable
                    csscpt.douteux    = csscptcol.douteux
                    csscpt.lib        = pcLibelle
                .
            end.
        end. /* IF csscptcol.coll-cle = ccptcol.coll-cle THEN DO : */
    end.

end procedure.

procedure creJournaux private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcListe as character no-undo.
    define input parameter pcCode  as character no-undo.

    define variable viCompteur as integer   no-undo.
    define variable vcJournal  as character no-undo.
    define buffer ijouprd for ijouprd.
    define buffer ijou    for ijou.
    define buffer vbIjou  for ijou.
    define buffer iprd    for iprd.

    if pcListe > ""
    then for each vbIjou no-lock
        where vbIjou.soc-cd  = ttParam.iCodeSoc
          and vbIjou.etab-cd = 0:
        if lookup(string(vbIjou.natjou-gi), pcListe ) > 0
        and not can-find (first ijou no-lock
                          where ijou.soc-cd  = vbIjou.soc-cd
                            and ijou.etab-cd = ttParam.iCodeEtab
                            and ijou.jou-cd  = vbIjou.jou-cd)
        then do:
            create ijou.
            buffer-copy vbIjou to ijou
                assign
                    ijou.etab-cd = ttParam.iCodeEtab.
            for each iprd no-lock
                where iprd.soc-cd  = ttParam.iCodeSoc
                  and iprd.etab-cd = ttParam.iCodeEtab :
                create ijouprd.
                assign
                    ijouprd.soc-cd  = iprd.soc-cd
                    ijouprd.etab-cd = iprd.etab-cd
                    ijouprd.jou-cd  = ijou.jou-cd
                    ijouprd.prd-cd  = iprd.prd-cd
                    ijouprd.prd-num = iprd.prd-num
                    ijouprd.statut  = "O"
                .
            end.
        end.
    end.
    else do viCompteur = 1 to num-entries(pcCode):
        vcJournal = entry(viCompteur, pcCode).
        find first vbIjou no-lock
            where vbIjou.soc-cd  = ttParam.iCodeSoc
              and vbIjou.etab-cd = 0
              and vbIjou.jou-cd  = vcJournal no-error.
        if available vbIjou
        and not can-find(first ijou no-lock
                         where ijou.soc-cd  = vbIjou.soc-cd
                           and ijou.etab-cd = ttParam.iCodeEtab
                           and ijou.jou-cd  = vbIjou.jou-cd)
        then do:
            create ijou.
            buffer-copy vbIjou to ijou
                assign
                    ijou.etab-cd = ttParam.iCodeEtab.
            for each iprd no-lock
                where iprd.soc-cd  = ttParam.iCodeSoc
                  and iprd.etab-cd = ttParam.iCodeEtab:
                create ijouprd.
                assign
                    ijouprd.soc-cd  = iprd.soc-cd
                    ijouprd.etab-cd = iprd.etab-cd
                    ijouprd.jou-cd  = ijou.jou-cd
                    ijouprd.prd-cd  = iprd.prd-cd
                    ijouprd.prd-num = iprd.prd-num
                    ijouprd.statut  = "N"
                .
            end.
        end.
    end.

end procedure.

procedure calculDate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pdaFin1   as date no-undo.
    define output parameter pdaDebut2 as date no-undo.
    define output parameter pdaFin2   as date no-undo.

    assign
        pdaDebut2 = pdaFin1 + 1
        gdaJdate  = pdaDebut2 + 31
        gdaJdate  = date(month(gdaJdate), 01, year(gdaJdate))
        pdaFin2   = gdaJdate - 1
    .
end procedure.

procedure crePeriode private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piCodePeriode   as integer no-undo.
    define input parameter pdaDebutPeriode as date    no-undo.
    define input parameter pdaFinPeriode   as date    no-undo.

    define variable viNumeroPeriode as integer no-undo.
    define variable vdaFin1         as date    no-undo.
    define variable vdaDebut2       as date    no-undo.
    define variable vdaFin2         as date    no-undo.
    define buffer iprd for iprd.

    vdaFin1 = pdaDebutPeriode - 1.
    vdaFin2 = date("01/01/1000").
    do while vdaFin2 < pdaFinPeriode:
        run calculDate(vdaFin1, output vdaDebut2, output vdaFin2).
        create iprd.
        assign
            viNumeroPeriode = viNumeroPeriode + 1
            iprd.soc-cd     = ttParam.iCodeSoc
            iprd.etab-cd    = ttParam.iCodeEtab
            iprd.prd-cd     = piCodePeriode
            iprd.prd-num    = viNumeroPeriode
            iprd.dadebprd   = vdaDebut2
            iprd.dafinprd   = vdaFin2
            iprd.val        = true
            iprd.mvt        = false
            iprd.dispo      = 0
            vdaFin1         = vdaFin2
        .
    end.

end procedure.

procedure supTables private:
    /*------------------------------------------------------------------------------
    Purpose: Si le mandat n'existe pas, on supprime les tables rattachees pour eviter les messages d'erreur du type "iprd existe deja".
    Cela permet aussi de pouvoir recreer correctement ces tables en cas d'anomalie (plantage a la creation d'un nouveau mandat par exemple).
    Il suffit de supprimer ietab et d'aller en modification du mandat en gestion
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ijou      for ijou.
    define buffer ijouprd   for ijouprd.
    define buffer iprd      for iprd.
    define buffer idispohb  for idispohb.
    define buffer itypemvt  for itypemvt.
    define buffer parenc    for parenc.
    define buffer csscptcol for csscptcol.

    for each ijou exclusive-lock
        where ijou.soc-cd  = ttParam.iCodeSoc
          and ijou.etab-cd = ttParam.iCodeEtab:
         delete ijou.
    end.
    for each ijouprd exclusive-lock
        where ijouprd.soc-cd  = ttParam.iCodeSoc
          and ijouprd.etab-cd = ttParam.iCodeEtab:
         delete ijouprd.
    end.
    for each iprd exclusive-lock
        where iprd.soc-cd  = ttParam.iCodeSoc
          and iprd.etab-cd = ttParam.iCodeEtab:
         delete iprd.
    end.
    for each idispohb exclusive-lock
        where idispohb.soc-cd = ttParam.iCodeSoc
         and idispohb.etab-cd = ttParam.iCodeEtab:
         delete idispohb.
    end.
    for each itypemvt exclusive-lock
        where itypemvt.soc-cd  = ttParam.iCodeSoc
          and itypemvt.etab-cd = ttParam.iCodeEtab:
         delete itypemvt.
    end.
    for each parenc exclusive-lock
        where parenc.soc-cd  = ttParam.iCodeSoc
          and parenc.etab-cd = ttParam.iCodeEtab:
         delete parenc.
    end.
    for each csscptcol exclusive-lock
        where csscptcol.soc-cd  = ttParam.iCodeSoc
          and csscptcol.etab-cd = ttParam.iCodeEtab:
         delete csscptcol.
    end.

end procedure.

procedure creationFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcDevise        as character no-undo.
    define input parameter piEtablissement as integer   no-undo.

    define buffer aparm     for aparm.
    define buffer ccptcol   for ccptcol.
    define buffer ifour     for ifour.
    define buffer ifouetab  for ifouetab.
    define buffer ccpt      for ccpt.
    define buffer csscptcol for csscptcol.
    define buffer csscpt    for csscpt.

    if ttParam.cModReg = ? or ttParam.cModReg = "" then ttParam.cModReg = "C".
    find first aparm no-lock
        where aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and aparm.tppar   = "tregp"
          and aparm.cdpar   = ttParam.cModReg no-error.
    find first ccptcol no-lock
        where ccptcol.soc-cd = ttParam.iCodeSoc
          and ccptcol.tprole = 0012 no-error.
    {&_proparse_ prolint-nowarn(nowait)}
    find first ifour exclusive-lock
        where ifour.soc-cd   = ttParam.iCodeSoc
          and ifour.coll-cle = ccptcol.coll-cle
          and ifour.cpt-cd   = ttParam.cFourn no-error.
    if not available ifour
    then do:
        create ifour.
        assign
            ifour.soc-cd       = ttParam.iCodeSoc
            ifour.etab-cd      = 0
            ifour.coll-cle     = ccptcol.coll-cle
            ifour.cpt-cd       = ttParam.cFourn
            ifour.four-cle     = ttParam.cFourn
            ifour.type-four    = "F"
            ifour.librais-cd   = 1
            ifour.categ-cd     = 999 /* SANS CATEGORIES */
            ifour.telex        = ""
            ifour.tel          = ""
            ifour.fax          = ""
            ifour.contrat      = ""
            ifour.clegroup     = ""
            ifour.adrcom       = false
            ifour.adrregl      = false
            ifour.affact-cle   = ""
            ifour.dev-cd       = pcDevise
            ifour.fam-cd       = 1
            ifour.ssfam-cd     = 1
            ifour.solde        = 0
            ifour.trt          = 0
            ifour.cliref       = ""
            ifour.remarq       = ""
            ifour.dacreat      = today
            ifour.damodif      = today
            ifour.releve       = false
            ifour.rib          = false
            ifour.contact      = ""
            ifour.libpays-cd   = "001"
            ifour.old-ape      = 0
            ifour.libtier-cd   = 2
            ifour.livfac       = false
            ifour.tva-enc-deb  = false
            ifour.libass-cd    = 1
            ifour.liblang-cd   = 1
            ifour.rel-cd       = 0
            ifour.code-client  = ""
            ifour.siren        = ttParam.cSiren
            ifour.tvacee-cle   = ""
            ifour.tiers-declar = ""
            ifour.siret        = ttParam.cSiret
            ifour.ape          = ""
            ifour.port-cd      = 0
            ifour.livr-cd      = 0
            ifour.txremex      = 0
            ifour.txescpt      = 0
            ifour.caa          = 0
            ifour.caap         = 0
            ifour.mini-cde     = 0
            ifour.transp       = false
            ifour.effacable    = false
            ifour.fg-compens   = true
        .
    end.
    assign
        ifour.nom     = ttParam.cNomEtab
        ifour.ville   = ttParam.cVilleEtab
        ifour.cp      = ttParam.cCpEtab
        ifour.adr[1]  = ttParam.cAdr1Etab
        ifour.adr[2]  = ttParam.cAdr2Etab
        ifour.adr[3]  = ""
        ifour.regl-cd = if available aparm then aparm.zone1 else 300
    .
    if not can-find(first ifouetab no-lock
        where ifouetab.soc-cd   = ifour.soc-cd
          and ifouetab.etab-cd  = ifour.etab-cd
          and ifouetab.four-cle = ifour.four-cle)
    then do:
        create ifouetab.
        assign
            ifouetab.soc-cd   = ifour.soc-cd
            ifouetab.etab-cd  = ifour.etab-cd
            ifouetab.four-cle = ifour.four-cle
            ifouetab.solde    = 0
            ifouetab.trt      = 0
            ifouetab.encour   = 0
            ifouetab.lfacture = 0
            ifouetab.cde      = 0
            ifouetab.risque   = 0
            ifouetab.caec     = 0
            ifouetab.caep     = 0
        .
    end.
    find first ccpt no-lock
        where ccpt.soc-cd   = ttParam.iCodeSoc
          and ccpt.coll-cle = ccptcol.coll-cle
          and ccpt.cpt-cd   = ttParam.cFourn no-error.
    if not available ccpt
    then do:
        create ccpt.
        assign
            ccpt.soc-cd        = ttParam.iCodeSoc
            ccpt.etab-cd       = 0
            ccpt.coll-cle      = ccptcol.coll-cle
            ccpt.cpt-cd        = ttParam.cFourn
            ccpt.cpt-int       = ccptcol.coll-cle + ttParam.cFourn
            ccpt.cpt2-cd       = ""
            ccpt.lib           = ifour.nom
            ccpt.lib2          = ""
            ccpt.libtype-cd    = ccptcol.libtype-cd
            ccpt.libcat-cd     = ccptcol.libcat-cd
            ccpt.libimp-cd     = ccptcol.libimp-cd
            ccpt.libsens-cd    = ccptcol.libsens-cd
            ccpt.centra        = ccptcol.centra
            ccpt.reciproq      = false
            ccpt.cptaffect     = ccptcol.cptaffect
            ccpt.tva-oblig     = false
            ccpt.cptprov-num   = ccptcol.cptprov-num
            ccpt.cpt2-int      = ""
            ccpt.taxe-cd       = 0
            ccpt.type          = false
            ccpt.tva-compte    = ""
            ccpt.lettre-int[1] = 0
            ccpt.lettre-int[2] = 0
            ccpt.lettre-int[3] = 0
            ccpt.lettre-int[4] = 0
            ccpt.lettre-int[5] = 0
            ccpt.lettre        = ""
            ccpt.sens-oblig    = false
            ccpt.detail-tres   = false
            ccpt.dadeb         = ?
            ccpt.dafin         = ?
            ccpt.cpt-tri       = ""
            ccpt.type-cd       = 0
            ccpt.fg-conf       = false
            ccpt.fg-tiers      = true
            ccpt.cptg-cd       = ""
            ccpt.sscpt-cd      = ttParam.cFourn
            ccpt.fg-libsoc     = true
            ccpt.fg-mandat     = ccptcol.fg-mandat
        .
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each csscptcol no-lock
        where csscptcol.soc-cd   = ttParam.iCodeSoc
          and csscptcol.etab-cd  = piEtablissement
          and csscptcol.coll-cle = ccptcol.coll-cle
        use-index sscptcol-i:          // evite l'index sscptcol-col
        find first csscpt no-lock
            where csscpt.soc-cd     = ttParam.iCodeSoc
              and csscpt.etab-cd    = piEtablissement
              and csscpt.sscoll-cle = csscptcol.sscoll-cle
              and csscpt.cpt-cd     = ttParam.cFourn no-error.
        if not available csscpt
        then do:
            create csscpt.
            assign
                csscpt.soc-cd       = ttParam.iCodeSoc
                csscpt.etab-cd      = piEtablissement
                csscpt.sscoll-cle   = csscptcol.sscoll-cle
                csscpt.cpt-cd       = ttParam.cFourn
                csscpt.cpt-int      = csscptcol.sscoll-cpt + ttParam.cFourn
                csscpt.cpt2-int     = ""
                csscpt.cpt2-cd      = ""
                csscpt.lib          = ifour.nom
                csscpt.lib2         = ""
                csscpt.coll-cle     = ccptcol.coll-cle
                csscpt.rep-cle      = ""
                csscpt.facturable   = true
                csscpt.libcli-cd    = 0
                csscpt.libpays-cd   = ifour.libpays-cd
                csscpt.douteux      = false
                csscpt.numerateur   = 0
                csscpt.denominateur = 0
                csscpt.regl-cd      = ifour.regl-cd
            .
        end.
    end.
    run foumref (rowid(ifour)).

end procedure.

procedure foumref private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter prFour as rowid no-undo.

    define buffer ietab       for ietab.
    define buffer vbIetab     for ietab.
    define buffer ifour       for ifour.
    define buffer vbIfour     for ifour.
    define buffer csscpt      for csscpt.
    define buffer vbCsscpt    for csscpt.
    define buffer csscptcol   for csscptcol.
    define buffer vbCsscptcol for csscptcol.
    define buffer isoc        for isoc.

    if not can-find(first aparm no-lock where aparm.tppar = "FMREF" and aparm.cdpar = "01") then return.

    find first ifour no-lock where rowid(ifour) = prFour no-error.
    if not available ifour then return.

    {&_proparse_ prolint-nowarn(wholeindex)}
    for each isoc no-lock
        where isoc.soc-cd <> ifour.soc-cd
          and isoc.specif-cle = 1000:
        /* Boucle sur les autres références */
        {&_proparse_ prolint-nowarn(nowait)}
        find first vbIfour exclusive-lock
            where vbIfour.soc-cd   = isoc.soc-cd
              and vbIfour.four-cle = ifour.four-cle no-error.
        if not available vbIfour then do:
            create vbIfour.
            assign
                vbIfour.soc-cd   = isoc.soc-cd
                vbIfour.four-cle = ifour.four-cle
            .
        end.
        /* 1 - copy de la fiche sur la/les autres references */
        buffer-copy ifour except ifour.soc-cd ifour.four-cle to vbIfour.
boucleIetab:
        for each ietab no-lock
            where ietab.soc-cd  = isoc.soc-cd:
            /* RECHERCHE DES MANDATS COMMUNS */
            if not can-find(first vbIetab no-lock
                where vbIetab.soc-cd  = ifour.soc-cd
                  and vbIetab.etab-cd = ietab.etab-cd) then next boucleIetab.

            {&_proparse_ prolint-nowarn(sortaccess)}
            for each csscpt no-lock
                 where csscpt.soc-cd   = ifour.soc-cd
                   and csscpt.etab-cd  = ietab.etab-cd
                   and csscpt.coll-cle = ifour.coll-cle
                   and csscpt.cpt-cd   = ifour.cpt-cd
                 break by csscpt.sscoll-cle
                       by csscpt.cpt-cd:
                /* Cpt indiv rattachés au fournisseur sur réf de départ */
                if first-of(csscpt.sscoll-cle)
                then do:
                    find first csscptcol no-lock
                        where csscptcol.soc-cd = csscpt.soc-cd
                          and csscptcol.etab-cd = csscpt.etab-cd
                          and csscptcol.sscoll-cle = csscpt.sscoll-cle no-error.
                    if available csscptcol
                    then do:
                        {&_proparse_ prolint-nowarn(nowait)}
                        find first vbCsscptcol exclusive-lock
                            where vbCsscptcol.soc-cd     = isoc.soc-cd
                              and vbCsscptcol.etab-cd    = ietab.etab-cd
                              and vbCsscptcol.sscoll-cle = csscptcol.sscoll-cle no-error.
                        if not available vbCsscptcol then do:
                            create vbCsscptcol.
                            assign
                                vbCsscptcol.soc-cd     = isoc.soc-cd
                                vbCsscptcol.etab-cd    = ietab.etab-cd
                                vbCsscptcol.sscoll-cle = csscptcol.sscoll-cle
                            .
                        end.
                        buffer-copy csscptcol except csscptcol.soc-cd csscptcol.etab-cd csscptcol.sscoll-cle to vbCsscptcol.
                    end.
                end.
                {&_proparse_ prolint-nowarn(nowait)}
                find first vbCsscpt exclusive-lock
                    where vbCsscpt.soc-cd     = isoc.soc-cd
                      and vbCsscpt.etab-cd    = ietab.etab-cd
                      and vbCsscpt.sscoll-cle = csscpt.sscoll-cle
                      and vbCsscpt.cpt-cd     = csscpt.cpt-cd no-error.
                if not available vbCsscpt then do:
                      create vbCsscpt.
                      assign
                          vbCsscpt.soc-cd     = isoc.soc-cd
                          vbCsscpt.etab-cd    = ietab.etab-cd
                          vbCsscpt.sscoll-cle = csscpt.sscoll-cle
                          vbCsscpt.cpt-cd     = csscpt.cpt-cd
                      .
                end.
                buffer-copy csscpt except csscpt.soc-cd csscpt.etab-cd csscpt.sscoll-cle csscpt.cpt-cd to vbCsscpt.
            end.
        end.
    end.

end procedure.

procedure duplication private:
    /*------------------------------------------------------------------------------
    Purpose: Duplication de la table passée en paramètre du mandat giReference sur le mandat iCodeEtab
    Notes  : remplace batch/pdupfic.i
    ------------------------------------------------------------------------------*/
    define input  parameter pcNomTable as character no-undo.

    define variable vhBuffer  as handle no-undo.
    define variable vhBuffer2 as handle no-undo.
    define variable vhQuery  as handle no-undo.

    create buffer vhBuffer  for table pcNomTable.
    create buffer vhBuffer2 for table pcNomTable.
    create query vhQuery.
    vhQuery:set-buffers(vhBuffer).
    vhQuery:query-prepare(substitute('for each &1 no-lock where &1.soc-cd = &2 and &1.etab-cd = &3',
                         pcNomTable, ttParam.iCodeSoc, giReference)).
    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.

        vhBuffer2:buffer-create().
        vhBuffer2:buffer-copy(vhBuffer, 'etab-cd').
        vhBuffer2::etab-cd = ttParam.iCodeEtab.
        vhBuffer2:buffer-release().
    end.
    vhQuery:query-close().
    vhBuffer:buffer-release().
    delete object vhBuffer.
    delete object vhBuffer2.
    delete object vhQuery.

end procedure.
