/*------------------------------------------------------------------------
File        : rechercheTiers.p
Purpose     :
Author(s)   : NPO - 2017/06/28
notes       :
------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/nature2voie.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2telephone.i}
&SCOPED-DEFINE nombreMaxTiers 500
&SCOPED-DEFINE NoRolMax       9999999999
&SCOPED-DEFINE NoCttMax       9999999999

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{tiers/include/tiers.i}
define variable giNombreTiers as integer no-undo.

define temp-table ttListeImmeubleEntree no-undo
    field cTypeContrat    as character
    field iNumeroContrat  as integer
    field cCodeTypeRole   as character
    field iNumeroRole     as integer
    index NoId1 cCodeTypeRole iNumeroRole
    index NoId2 cTypeContrat iNumeroContrat
.
define variable ghTelephone as handle    no-undo.

function fIsNull returns logical private(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:       
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.

end function.

function fIsAcheteurVendeur returns logical private(pcLstRoleTiers as character, pcTypeRole as character):
    /*------------------------------------------------------------------------------
    Purpose: filtre acheteur/vendeur
    Notes:       
    ------------------------------------------------------------------------------*/
    return fIsNull(pcLstRoleTiers)
      and (pcTypeRole = {&TYPEROLE-vendeur} or pcTypeRole = {&TYPEROLE-acheteur}).
end function.

function fIsSalarie returns logical private(pcNumeroSecu as character, pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: filtre salarie
    Notes:       
    ------------------------------------------------------------------------------*/
    pcNumeroSecu = trim(pcNumeroSecu).
    if not fIsNull(pcNumeroSecu)
    and (pcTypeRole = {&TYPEROLE-salarie} or pcTypeRole = {&TYPEROLE-salariePegase}
      or not can-find (first salar no-lock
                       where salar.norol = piNumeroRole
                         and salar.nosec = pcNumeroSecu))
    then return false.
    return true.
end function.

function fIsImmeuble returns logical private(plFlagRechrcheImmeuble as logical, pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: filtre immeuble
    Notes:       
    ------------------------------------------------------------------------------*/
    return plFlagRechrcheImmeuble
      and not can-find(first ttListeImmeubleEntree
                       where ttListeImmeubleEntree.cTypeContrat   = pcTypeContrat
                         and ttListeImmeubleEntree.iNumeroContrat = piNumeroContrat).
end function.

function fIsContrat returns logical private(piDebut as int64, piFin as int64, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose: filtre contrat
    Notes:       
    ------------------------------------------------------------------------------*/
    return (piDebut > 0 or piFin < {&NoCttMax})
       and (piNumeroContrat < piDebut or piNumeroContrat > piFin).
end function.

function rechercheDansAdresses returns logical private(pcRecherche as character, pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: fonction de recherche dans toutes les adresses d'un role
    notes:
    ------------------------------------------------------------------------------*/
    define variable vlAdresseOK as logical   no-undo.
    define variable vcAdresse   as character no-undo.
    define variable viBoucle    as integer   no-undo.

    define buffer ladrs for ladrs.

     if fIsNull(pcRecherche) then return true.

     /* Balayage des adresses du role */
BALAYAGE_ADRESSES:
    for each ladrs no-lock
        where ladrs.tpidt = pcTypeRole
          and ladrs.noidt = piNumeroRole:
        assign 
            vcAdresse = outilFormatage:formatageAdresse(pcTypeRole, piNumeroRole, ladrs.nolie)
            vlAdresseOK = true
        .
CONTROLE_ADRESSE:
        do viBoucle = 1 to num-entries(pcRecherche, " "):
            if not vcAdresse matches substitute("*&1*", entry(viBoucle, pcRecherche," ")) then do:
                vlAdresseOK = false.
                leave CONTROLE_ADRESSE.
            end.
        end.
        if vlAdresseOK then leave BALAYAGE_ADRESSES.
    end.
    return vlAdresseOK.

end function.

function createttTiers returns logical private(pcTypeRechercheTiers as character, phTiers as handle, phRoles as handle, phContrat as handle):
    /*------------------------------------------------------------------------------
    Purpose: fonction de creation d'un ListeTiers
    notes:
    ------------------------------------------------------------------------------*/
    create ttListeTiers.
    assign
        giNombreTiers                    = giNombreTiers + 1
        ttListeTiers.iNumeroTiers        = phTiers::notie
        ttListeTiers.cCodeFamille        = phTiers::cdfat
        ttListeTiers.cCodeSituation      = phTiers::cdst1
        ttListeTiers.lWebFgOuvert        = phTiers::web-fgouvert
        ttListeTiers.daWebdateouverture  = phTiers::web-dateouverture
        ttListeTiers.lWebFgOuvert        = phTiers::web-fgouvert
        ttListeTiers.daWebdateouverture  = phTiers::web-dateouverture
        ttListeTiers.cLibelleProfession1 = phTiers::lprf1
    .
    if valid-handle(phRoles)
    then assign
        ttListeTiers.cCodeTypeRole       = if pcTypeRechercheTiers = "T" then "" else phRoles::tprol
        ttListeTiers.iNumeroRole         = if pcTypeRechercheTiers = "T" then 0  else phRoles::norol
        ttListeTiers.cCodeExterneMpwRol  = phRoles::cdext
    no-error.
    if valid-handle(phContrat)
    then assign
        ttListeTiers.cTypeContrat        = phContrat::tpcon
        ttListeTiers.iNumeroContrat      = phContrat::nocon
        ttListeTiers.cCodeExterneMpwCtt  = phContrat::cdext
    no-error.
    error-status:error = false no-error.
    return true.
end function.


procedure rechercheTiersTroncCommun:
    /*------------------------------------------------------------------------------
    Purpose: Recherche Tronc commun
    notes: utilisé par service beTiers.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttListeTiers.

    // Critères en entrée
    define variable vcTypRoleEntree       as character no-undo.  /* TpRolSel */
    define variable vcLstTpRolEntree      as character no-undo.  /* LstTprol */
    define variable vcLstTpCttEntree      as character no-undo.  /* LstTpCtt */
    define variable viNoImmEntree         as integer   no-undo.
    // Critères de recherche
    define variable vcNomTiers            as character no-undo.
    define variable viNoTiers             as int64     no-undo.
    define variable viNoTiersDeb          as int64     no-undo.
    define variable viNoTiersFin          as int64     no-undo.
    define variable vcLstRoleTiers        as character no-undo.
    define variable vcNomImm              as character no-undo.
    define variable viNoImmDeb            as integer   no-undo.
    define variable viNoImmFin            as integer   no-undo.
    define variable vcAdrImm              as character no-undo.
    define variable viNoCon               as int64     no-undo.
    define variable viNoConDeb            as int64     no-undo.
    define variable viNoConFin            as int64     no-undo.
    define variable vcTypCtrat            as character no-undo.
    define variable vcNomRecherchebegins  as character no-undo.
    define variable vcNomRecherchematches as character no-undo.
    define variable vcListeRolesCSynd     as character no-undo.  /* Liste des roles du conseil syndical */
    define variable vlVientDeImmeuble     as logical   no-undo.
    /* RechercheTiers */
    define variable viCpUseInc            as integer   no-undo.
    define variable vlFgRchCsynd          as logical   no-undo.
    define variable vcLbAdrRol            as character no-undo.

    define buffer sys_pg  for sys_pg.
    define buffer imble   for imble.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctctt   for ctctt.
    define buffer taint   for taint.

    assign
        vcTypRoleEntree  = poCollection:getCharacter("cTypRoleEntree")
        vcLstTpRolEntree = poCollection:getCharacter("cLstTpRolEntree")
        vcLstTpCttEntree = poCollection:getCharacter("cLstTpCttEntree")
        viNoImmEntree    = poCollection:getInteger("iNumeroImmeuble")
        vcNomTiers       = poCollection:getCharacter("cNomTiers")
        viNoTiers        = poCollection:getInt64("iNumeroTiers")
        viNoTiersDeb     = poCollection:getInt64("iNumeroTiers1")
        viNoTiersFin     = poCollection:getInt64("iNumeroTiers2")
        vcLstRoleTiers   = poCollection:getCharacter("cListeRoleFicheTiers")
        vcNomImm         = poCollection:getCharacter("cNomImmeuble")
        viNoImmDeb       = poCollection:getInteger("iNumeroImmeuble1")
        viNoImmFin       = poCollection:getInteger("iNumeroImmeuble2")
        vcAdrImm         = poCollection:getCharacter("cAdresseImmeuble")
        viNoCon          = poCollection:getInt64("iNumeroContrat")
        viNoConDeb       = poCollection:getInt64("iNumeroContrat1")
        viNoConFin       = poCollection:getInt64("iNumeroContrat2")
        vcTypCtrat       = poCollection:getCharacter("cTypeContrat")
    .
    {&_proparse_ prolint-nowarn(when)}
    assign  // ne pas fusionner les assign, when utilisé plus bas !!!
        vcTypRoleEntree  = '' when vcTypRoleEntree = ?
        vcLstTpRolEntree = '' when vcLstTpRolEntree = ?
        vcLstTpCttEntree = '' when vcLstTpCttEntree = ?
        viNoImmEntree    = 0 when viNoImmEntree = ?
        vcNomTiers       = '' when vcNomTiers = ?
        vcNomImm         = '' when vcNomImm = ?
        vcAdrImm         = '' when vcAdrImm = ?
        vcTypCtrat       = '' when vcTypCtrat = ?
        viNoImmDeb       = 0 when viNoImmDeb = ?
        viNoImmFin       = 0 when viNoImmFin = ?
        viNoImmDeb       = if viNoImmEntree <> 0 then viNoImmEntree else viNoImmDeb
        viNoImmFin       = if viNoImmDeb = 0 and viNoImmFin = 0 then 99999 else if viNoImmFin <> 0 then viNoImmFin else viNoImmDeb
        //if vcNoImmEntree <> '0' then vcNoImmEntree else vcNoImmFin
        viNoTiers        = 0 when viNoTiers = ?
        viNoTiersDeb     = 0 when viNoTiersDeb = ?
        viNoTiersFin     = 0 when viNoTiersFin = ?
        viNoTiersFin     = if viNoTiersDeb = 0 and viNoTiersFin = 0 then 9999999999 else if viNoTiersFin > 0 then viNoTiersFin else viNoTiersDeb
        viNoCon          = 0 when viNoCon = ?
        viNoConDeb       = 0 when viNoConDeb = ?
        viNoConFin       = 0 when viNoConFin = ?
        viNoConFin       = if viNoConDeb = 0 and viNoConFin = 0 then 9999999999 else if viNoConFin <> 0 then viNoConFin else viNoConDeb
    .

    for each sys_pg no-lock
       where sys_pg.tppar = "R_TFR"
         and sys_pg.zone1 = {&TYPETACHE-conseilSyndical}
         and sys_pg.zone2 = "00001":
        vcListeRolesCSynd = vcListeRolesCSynd + "," + sys_pg.zone3.
    end.
    vcListeRolesCSynd = if not fIsNull(vcListeRolesCSynd) 
                        then substring(vcListeRolesCSynd, 2)
                        else substitute('&1,&2,&3,&4,&5,&6,&7,&8,&9', 
                                   {&TYPEROLE-presidentConseilSyndical},
                                   {&TYPEROLE-membreConseilSyndical},
                                   {&TYPEROLE-adjointConseilSyndical},
                                   {&TYPEROLE-bienfaiteurConseilSyndical},
                                   {&TYPEROLE-respTravauxConseilSyndical},
                                   {&TYPEROLE-benevole},
                                   {&TYPEROLE-responsableSecurite},
                                   {&TYPEROLE-responsableComptabilite},
                                   {&TYPEROLE-coPresident}).

    /* Initialisation */
    if viNoImmEntree <> 0 
    then for first imble no-lock
        where imble.noimm = viNoImmEntree:
        assign
            viNoImmDeb        = imble.noimm
            viNoImmFin        = imble.noimm
            vlVientDeImmeuble = true.
        .
    end.

    /* Si la liste des type de role ne contient pas le role en entrée, on le rajoute */
    if not(fIsNull(vcLstTpRolEntree)) and lookup(vcTypRoleEntree, vcLstTpRolEntree) <= 0
    then assign
        vcLstTpRolEntree = vcLstTpRolEntree + "," + vcTypRoleEntree
        vcLstTpCttEntree = vcLstTpCttEntree + ","

// Todo : npo à vérifier s'il faut maintenir
// Todo : npo à revoir car ramène les résiliés

        vcTypCtrat = if not fIsNull(vcTypRoleEntree) then "Tous" else "00001"

    /* Cas particulier pour la recherche du "." car sinon progress considère le "." comme un jocker */
        vcNomRecherchebegins  = vcNomTiers
        vcNomRecherchematches = replace(vcNomTiers, ".", "~~.")
        /* Construction de la liste des rôles */
        vcLstRoleTiers        = replace(replace(vcLstRoleTiers, "[", ""), "]", "")
    .
    /* Lancement de la recherche = TRONC COMMUN */ /* proc RechercheTiers */
/* Todo ??? npo
    /* Recupération du mode de recherche par défaut de l'utilisateur */
    find first tutil
        where tutil.ident_u = mtoken:cUser no-lock no-error.
    if available(tutil) then do:
        vcTypRchTiers = tutil.cTypeRecherche.
        /* Mémorisation du mode de recherche */
        //cMemoTypeRecherche = vcTypRchTiers.
    end.
*/

    /* Suppression des tables temporaires de recherche */
    empty temp-table ttListeTiers.
    empty temp-table ttListeImmeubleEntree.

    /* Construction de la liste des roles sur l'immeuble */
    if not fIsNull(vcNomImm) or viNoImmDeb > 0 or viNoImmFin < 99999 or not fIsNull(vcAdrImm) then do:
boucleImmeuble:
        for each imble no-lock
           where imble.noimm >= viNoImmDeb
             and imble.noimm <= viNoImmFin
             and imble.lbnom matches (vcNomImm + "*")
          , each intnt no-lock
           where intnt.tpidt = {&TYPEBIEN-immeuble}
             and intnt.noidt = imble.noimm
          , each vbIntnt no-lock
           where vbIntnt.tpcon = intnt.tpcon
             and vbIntnt.nocon = intnt.nocon
             and (fIsNull(vcLstRoleTiers) or lookup(vbIntnt.tpidt, vcLstRoleTiers) > 0)
             and vbIntnt.noidt >= viNoTiersDeb
             and vbIntnt.noidt <= viNoTiersFin:
            /* Filtre sur l'adresse de l'immeuble */
            if not rechercheDansAdresses(vcAdrImm, {&TYPEBIEN-immeuble}, imble.noimm) then next boucleImmeuble.

            create ttListeImmeubleEntree.
            assign
                ttListeImmeubleEntree.cTypeContrat   = vbIntnt.tpcon
                ttListeImmeubleEntree.iNumeroContrat = vbIntnt.nocon
                viCpUseInc                           = integer(vbIntnt.tpidt)
            no-error.
            if error-status:error or viCpUseInc <= 1000
            then assign
                ttListeImmeubleEntree.cCodeTypeRole = vbIntnt.tpidt
                ttListeImmeubleEntree.iNumeroRole   = vbIntnt.noidt
            .
        end.

        if fIsNull(vcLstRoleTiers) or lookup({&TYPEROLE-vendeur}, vcLstRoleTiers) > 0
        or lookup({&TYPEROLE-acheteur}, vcLstRoleTiers) > 0 or lookup({&TYPEROLE-coproprietaire}, vcLstRoleTiers) > 0 
        then for each imble no-lock
            where imble.noimm >= viNoImmDeb
              and imble.noimm <= viNoImmFin
              and imble.lbnom matches (vcNomImm + "*")
           , each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = imble.noimm
              and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
           , each ctctt no-lock
            where ctctt.tpct1 = intnt.tpcon
              and ctctt.noct1 = intnt.nocon
              and ctctt.tpct2 = {&TYPECONTRAT-titre2copro}
           , each vbIntnt no-lock
            where vbIntnt.tpcon = ctctt.tpct2
              and vbIntnt.nocon = ctctt.noct2
              and (fIsNull(vcLstRoleTiers) or lookup(vbIntnt.tpidt, vcLstRoleTiers) > 0)
              and vbIntnt.noidt >= viNoTiersDeb
              and vbIntnt.noidt <= viNoTiersFin:
            /* Filtre sur l'adresse de l'immeuble */
            {&_proparse_ prolint-nowarn(blocklabel)}
            if not rechercheDansAdresses(vcAdrImm, {&TYPEBIEN-immeuble}, imble.noimm) then next.

            create ttListeImmeubleEntree.
            assign
                ttListeImmeubleEntree.cTypeContrat   = vbIntnt.tpcon
                ttListeImmeubleEntree.iNumeroContrat = vbIntnt.nocon
                viCpUseInc                           = integer(vbIntnt.tpidt)
            no-error.
            if error-status:error or viCpUseInc <= 1000 
            then assign
                 ttListeImmeubleEntree.cCodeTypeRole = vbIntnt.tpidt
                 ttListeImmeubleEntree.iNumeroRole   = vbIntnt.noidt
            .
        end.

        vlFgRchCsynd = false.
boucle:
        do viCpUseInc = 1 to num-entries(vcLstRoleTiers):
            if lookup(entry(viCpUseInc, vcLstRoleTiers ), vcListeRolesCSynd) > 0 then do:
                vlFgRchCsynd = true.
                leave boucle.
            end.
        end.
        if fIsNull(vcLstRoleTiers) or vlFgRchCsynd 
        then for each imble no-lock
            where imble.noimm >= viNoImmDeb
              and imble.noimm <= viNoImmFin
              and imble.lbnom matches (vcNomImm + "*")
           , each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = imble.noimm
              and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
           , each taint no-lock
            where taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and taint.nocon = intnt.nocon
              and (fIsNull(vcLstRoleTiers) or lookup(taint.tpidt, vcLstRoleTiers) > 0)
              and taint.noidt >= viNoTiersDeb
              and taint.noidt <= viNoTiersFin
              and taint.tptac = {&TYPETACHE-conseilSyndical}:

            /* Filtre sur l'adresse de l'immeuble */
            {&_proparse_ prolint-nowarn(blocklabel)}
            if not rechercheDansAdresses(vcAdrImm, {&TYPEBIEN-immeuble}, imble.noimm) then next.

            create ttListeImmeubleEntree.
            assign
                ttListeImmeubleEntree.cTypeContrat   = intnt.tpcon
                ttListeImmeubleEntree.iNumeroContrat = intnt.nocon
                viCpUseInc                           = integer(taint.tpidt)
            no-error.
            if error-status:error or viCpUseInc <= 1000 
            then assign
                ttListeImmeubleEntree.cCodeTypeRole = taint.tpidt
                ttListeImmeubleEntree.iNumeroRole   = taint.noidt
            .
        end.
    end.

    /* Rechargement dans la collection des variables modifiées */
    poCollection:set('cNomTiers', vcNomTiers) no-error.
    poCollection:set('cNomImm', vcNomImm) no-error.
    poCollection:set('cAdrImm', vcAdrImm) no-error.
    poCollection:set('cTypCtrat', vcTypCtrat) no-error.
    poCollection:set('iNumeroTiers1', viNoTiersDeb) no-error.
    poCollection:set('iNumeroTiers2', viNoTiersFin) no-error.
    poCollection:set('iNumeroImmeuble1', viNoImmDeb) no-error.
    poCollection:set('iNumeroImmeuble2', viNoImmFin) no-error.
    poCollection:set('iNumeroContrat1', viNoConDeb) no-error.
    poCollection:set('iNumeroContrat2', viNoConFin) no-error.
    poCollection:set('cTypeContrat', vcTypCtrat) no-error.
    poCollection:set('cListeRoleFicheTiers', vcLstRoleTiers) no-error.
    poCollection:set('cNomRecherchebegins', vcNomRecherchebegins) no-error.
    poCollection:set('cNomRecherchematches', vcNomRecherchematches) no-error.
    poCollection:set('cListeRolesCSynd', vcListeRolesCSynd) no-error.
    poCollection:set('lVientDeImmeuble', vlVientDeImmeuble) no-error.

    /* Recherche sur les tiers */
    if vlVientDeImmeuble
    then run rechercheTiersVientDeImmeuble(poCollection).
    else run rechercheTiersNotVientDeImmeuble(poCollection).

    /* Générer les informations sur les tiers générés */
    for each ttListeTiers
       break by ttListeTiers.cCodeTypeRole
             by ttListeTiers.iNumeroRole
             by ttListeTiers.iNumeroTiers:
        if first-of(ttListeTiers.iNumeroTiers) then vcLbAdrRol = "".

        run infoTiers(input-output vcLbAdrRol).
    end.

end procedure.

procedure RechercheTiersNotVientDeImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche lorsque l'on ne vient pas de l'immeuble
    notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.

    // Critères de recherche
    define variable vcPrenomTiers              as character no-undo.
    define variable viNoTiersDeb               as int64     no-undo.
    define variable viNoTiersFin               as int64     no-undo.
    define variable vcAdresTiers               as character no-undo.
    define variable vcTypRchTiers              as character no-undo.
    define variable vcLstRoleTiers             as character no-undo.
    define variable vcNomImm                   as character no-undo.
    define variable viNoImmDeb                 as integer   no-undo.
    define variable viNoImmFin                 as integer   no-undo.
    define variable vcAdrImm                   as character no-undo.
    define variable viNoConDeb                 as int64     no-undo.
    define variable viNoConFin                 as int64     no-undo.
    define variable vcTypCtrat                 as character no-undo.
    define variable vcDomaineFour              as character no-undo.
    define variable vcCategorieFour            as character no-undo.
    define variable vcStatutFour               as character no-undo.
    define variable vcFourReferencmt           as character no-undo.
    define variable vcCodeSociete              as character no-undo.
    define variable vcNomRecherchebegins       as character no-undo.
    define variable vcNomRecherchematches      as character no-undo.
    define variable vlUniquementAdresseSaisi   as logical   no-undo.
    define variable vlUniquementRoleSaisi      as logical   no-undo.
    define variable vlRechercheNumeroRole      as logical   no-undo.
    define variable viBoucle                   as integer   no-undo.
    define variable vlFgImmRch                 as logical   no-undo.
    define variable vcLbCrtCtt                 as character no-undo.
    define variable vclstFour                  as character no-undo.
    define variable vcTypeContratFournisseur   as character no-undo.
    define variable viNumeroBN                 as integer   no-undo.
    define variable viNumeroContratFournisseur as integer   no-undo.
    define variable vcTempo1                   as character no-undo.
    define variable vlAdresseOK                as logical   no-undo.
    define variable vlFgExeMth                 as logical   no-undo.

    define buffer vbRoles  for roles.
    define buffer tiers    for tiers.
    define buffer adres    for adres.
    define buffer ladrs    for ladrs.
    define buffer isoc     for isoc.
    define buffer ccptcol  for ccptcol.
    define buffer icontacf for icontacf.
    define buffer ifour    for ifour.
    define buffer idomfour for idomfour.
    define buffer ccpt     for ccpt.
    define buffer csscpt   for csscpt.

   /* Chargement des critères */
    assign
        vcPrenomTiers         = poCollection:getCharacter("cPrenomTiers")
        viNoTiersDeb          = poCollection:getInt64("iNumeroTiers1")
        viNoTiersFin          = poCollection:getInt64("iNumeroTiers2")
        vcAdresTiers          = poCollection:getCharacter("cAdresseTiers")
        vcTypRchTiers         = poCollection:getCharacter("cTypeRechercheTiers")
        vcLstRoleTiers        = poCollection:getCharacter("cListeRoleFicheTiers")
        vcNomImm              = poCollection:getCharacter("cNomImmeuble")
        viNoImmDeb            = poCollection:getInteger("iNumeroImmeuble1")
        viNoImmFin            = poCollection:getInteger("iNumeroImmeuble2")
        vcAdrImm              = poCollection:getCharacter("cAdresseImmeuble")
        viNoConDeb            = poCollection:getInt64("iNumeroContrat1")
        viNoConFin            = poCollection:getInt64("iNumeroContrat2")
        vcTypCtrat            = poCollection:getCharacter("cTypeContrat")
        vcDomaineFour         = poCollection:getCharacter("cDomaineFournisseur")
        vcCategorieFour       = poCollection:getCharacter("cCategorieFournisseur")
        vcStatutFour          = poCollection:getCharacter("cStatutFournisseur")
        vcFourReferencmt      = poCollection:getCharacter("cFournisseurReferencmt")
        vcCodeSociete         = poCollection:getCharacter("cCodeSociete")
        vcNomRecherchebegins  = poCollection:getCharacter("cNomRecherchebegins")
        vcNomRecherchematches = poCollection:getCharacter("cNomRecherchematches")
    .
    {&_proparse_ prolint-nowarn(when)}
    assign
        vcPrenomTiers    = '' when vcPrenomTiers = ?
        vcAdresTiers     = '' when vcAdresTiers = ?
        vcTypRchTiers    = '' when vcTypRchTiers = ?
        vcLstRoleTiers   = '' when vcLstRoleTiers = ?
        vcNomImm         = '' when vcNomImm = ?
        vcAdrImm         = '' when vcAdrImm = ?
        vcTypCtrat       = '' when vcTypCtrat = ?
        vcDomaineFour    = if vcDomaineFour = "all" or vcDomaineFour = ? then "0" else vcDomaineFour
        vcCategorieFour  = if vcCategorieFour = "all" or vcCategorieFour = ? then "0" else vcCategorieFour
        vcStatutFour     = '' when vcStatutFour = ?
        vcFourReferencmt = '' when vcFourReferencmt = ?
        vcCodeSociete    = mToken:cRefPrincipale when vcCodeSociete = ? or vcCodeSociete = '0'
        vcLbCrtCtt       = string(viNoConDeb, "9999999999") + string(viNoConFin, "9999999999"). // Constitution de la liste des critères pour les contrats 
    .

    if fIsNull(vcNomRecherchebegins) and fIsNull(vcPrenomTiers) and fIsNull(vcAdresTiers)
    and fIsNull(vcNomImm) and fIsNull(vcAdrImm)  and viNoImmDeb = 0 and viNoImmFin = 99999
    and viNoConDeb = 0  and viNoConFin = {&NoCttMax}
    and fIsNull(vcLstRoleTiers)    // and not (can-find(first bTbTmpTro where bTbTmpTro.fgsel = "X"))
    and (viNoTiersDeb <> 0 or viNoTiersFin <> {&NoRolMax})
    then vlUniquementRoleSaisi = true.

    vlUniquementAdresseSaisi = false.
    if fIsNull(vcNomRecherchebegins) and fIsNull(vcPrenomTiers) and not(fIsNull(vcAdresTiers))
    and fIsNull(vcNomImm) and fIsNull(vcAdrImm) and viNoImmDeb = 0 and viNoImmFin = 99999
    and viNoConDeb = 0 and viNoConFin = {&NoCttMax}
    and fIsNull(vcLstRoleTiers)    // and not (can-find(first bTbTmpTro where bTbTmpTro.fgsel = "X"))
    and viNoTiersDeb = 0 and viNoTiersFin = {&NoRolMax}
    then vlUniquementAdresseSaisi = true.

    /* On a saisi que le numero de role : Cas particulier pour aller plus vite */
    if vlRechercheNumeroRole and vlUniquementRoleSaisi 
    then for each vbroles no-lock /* Balayage des roles sur le numéro */
        where vbroles.norol >= viNoTiersDeb
          and vbroles.norol <= viNoTiersFin
        /* Positionnement sur le tiers + appel procedure commune */
      , first tiers no-lock
        where tiers.notie = vbRoles.notie:
        run rechercheTiersCreation(tiers.notie, poCollection).
        {&_proparse_ prolint-nowarn(blocklabel)}    // on limite le nombre de tiers
        if giNombreTiers > {&nombreMaxTiers} then leave.
    end.
    else if vlUniquementAdresseSaisi
    then for each adres no-lock:      // Parcours des adresses plutot que des tiers
        vlAdresseOK = true.
RECHERCHE_ADRESSE_UNIQUE:
        do viboucle = 1 to num-entries(vcAdresTiers, " "):
            vcTempo1 = substitute("*&1*", entry(viboucle, vcAdresTiers," ")).
            if not(adres.lbvoi matches vcTempo1 or adres.cpvoi matches vcTempo1 or adres.cdpos matches vcTempo1 or adres.lbvil matches vcTempo1)
            then do:
                vlAdresseOk = false.
                leave RECHERCHE_ADRESSE_UNIQUE.
            end.
        end.
        if vlAdresseOK 
        then for each ladrs no-lock
             where ladrs.noadr = adres.noadr
           , each vbroles no-lock
             where vbroles.tprol = ladrs.tpidt
               and vbroles.norol = ladrs.noidt
           , first tiers no-lock
             where tiers.notie = vbroles.notie:
            run RechercheTiersCreation(tiers.notie, poCollection).
            {&_proparse_ prolint-nowarn(blocklabel)}    // on limite le nombre de tiers
            if giNombreTiers > {&nombreMaxTiers} then leave.
        end.
    end.
    else do:

/*  TODO  --- quelle recherche ?????
        for each tiers fields(notie lnom1 lnom2 lnom4 lPre1 lPre2 lPre4) no-lock:
            if (vcTypRchTiers = "CTC" and tiers.lnom4 matches vcNomRecherchematches + "*"
              and vcTypRchTiers = "CTC" and tiers.lPre4 matches vcPrenomTiers + "*")
            or (tiers.lnom1 matches vcNomRecherchematches + "*" and tiers.lPre1 matches vcPrenomTiers + "*")
            or (tiers.lnom2 matches vcNomRecherchematches +  "*" and tiers.lPre2 matches vcPrenomTiers +  "*") then next.
            run rechercheTiersCreation(tiers.notie, poCollection).
            if giNombreTiers > {&nombreMaxTiers} then leave.
        end.
*/

        /* Sinon : recherche "normale" */
        if vcNomRecherchebegins begins "*" and vcPrenomTiers begins "*" 
        then for each tiers fields(notie lnom1 lnom2 lnom4 lPre1 lPre2 lPre4) no-lock
            where ((vcTypRchTiers = "CTC" and tiers.lnom4 matches vcNomRecherchematches + "*")
                or tiers.lnom1 matches vcNomRecherchematches + "*"
                or tiers.lnom2 matches vcNomRecherchematches +  "*")
              and ((vcTypRchTiers = "CTC" and tiers.lPre4 matches vcPrenomTiers + "*")
                or tiers.lPre1 matches vcPrenomTiers + "*"
                or tiers.lPre2 matches vcPrenomTiers + "*"):
            /* Lancement de la procedure commune */
            run RechercheTiersCreation(tiers.notie, poCollection).
            {&_proparse_ prolint-nowarn(blocklabel)}    // on limite le nombre de tiers
            if giNombreTiers > {&nombreMaxTiers} then leave.
        end.
        if not vcNomRecherchebegins begins "*" and vcPrenomTiers begins "*" 
        then for each tiers fields(notie lnom1 lnom2 lnom4 lPre1 lPre2 lPre4) no-lock
            where ((vcTypRchTiers = "CTC" and tiers.lnom4 begins vcNomRecherchebegins)
                or tiers.lnom1 begins vcNomRecherchebegins
                or tiers.lnom2 begins vcNomRecherchebegins)
              and ((vcTypRchTiers = "CTC" and tiers.lPre4 matches vcPrenomTiers + "*")
                or tiers.lPre1 matches vcPrenomTiers + "*"
                or tiers.lPre2 matches vcPrenomTiers +  "*"):
            /* Lancement de la procedure commune */
            run RechercheTiersCreation(tiers.notie, poCollection).
            {&_proparse_ prolint-nowarn(blocklabel)}    // on limite le nombre de tiers
            if giNombreTiers > {&nombreMaxTiers} then leave.
        end.
        if not vcNomRecherchebegins begins "*" and not vcPrenomTiers begins "*" 
        then for each tiers fields(notie lnom1 lnom2 lnom4 lPre1 lPre2 lPre4) no-lock
            where ((vcTypRchTiers = "CTC" and tiers.lnom4 begins vcNomRecherchematches)
                or tiers.lnom1 begins vcNomRecherchebegins
                or tiers.lnom2 begins vcNomRecherchebegins)
              and ((vcTypRchTiers = "CTC" and tiers.lPre4 begins vcPrenomTiers)
                or tiers.lPre1 begins vcPrenomTiers
                or tiers.lPre2 begins vcPrenomTiers):
                /* Lancement de la procedure commune */
            run rechercheTiersCreation(tiers.notie, poCollection).
            {&_proparse_ prolint-nowarn(blocklabel)}    // on limite le nombre de tiers
            if giNombreTiers > {&nombreMaxTiers} then leave.
        end.
        if vcNomRecherchebegins begins "*" and not vcPrenomTiers begins "*" 
        then for each tiers fields(notie lnom1 lnom2 lnom4 lPre1 lPre2 lPre4) no-lock
            where ((vcTypRchTiers = "CTC" and tiers.lnom4 matches vcNomRecherchematches + "*")
                or tiers.lnom1 matches vcNomRecherchematches + "*"
                or tiers.lnom2 matches vcNomRecherchematches + "*")
              and ((vcTypRchTiers = "CTC" and tiers.lPre4 begins vcPrenomTiers)
                or tiers.lPre1 begins vcPrenomTiers
                or tiers.lPre2 begins vcPrenomTiers):
            /* Lancement de la procedure commune */
            run RechercheTiersCreation(tiers.notie, poCollection).
            {&_proparse_ prolint-nowarn(blocklabel)}    // on limite le nombre de tiers
            if giNombreTiers > {&nombreMaxTiers} then leave.
        end.
    end.

    /*--RECHERCHE FOURNISSEURS-------------------------------------------------------------------------------------------------*/
    /* Recherche sur les fournisseurs */ /* si pas de critère sur le contrat : PL demande de CB le 23/01/2008 */
    if (fIsNull(vcLstRoleTiers) or lookup({&TYPEROLE-fournisseur}, vcLstRoleTiers) > 0) and vcLbCrtCtt = "0000000000" + string({&NoCttMax})
    /* and DonneParametre("RECHERCHE-PAS-FOURNISSEUR") = ""*/ 
    then do:   // todo:   NPO  ???
        for first isoc no-lock
            where isoc.soc-cd = integer(vcCodeSociete)
          , first ccptcol no-lock
            where ccptcol.soc-cd = isoc.soc-cd
              and ccptcol.tprole = 12:
            if vcTypRchTiers = "CTC" 
            then for each icontacf no-lock
                where icontacf.soc-cd = isoc.soc-cd
                  and icontacf.nom matches vcNomRecherchematches + "*":
                vclstFour = vclstFour + "," + icontacf.four-cle.
            end.
            vclstFour = trim(vclstFour, ",").
            /* Extraction */
boucleIfour:
            for each ifour no-lock
               where ifour.soc-cd   = isoc.soc-cd
                 and ifour.coll-cle = ccptcol.coll-cle
                 and ifour.cpt-cd >= string(viNoTiersDeb, "99999")
                 and ifour.cpt-cd <= string(viNoTiersFin, "99999")
                 and ifour.cpt-cd <> "99999":

                /* Filtre sur le nom et le prenom */
                if (vcTypRchTiers = "CTC"  and lookup(ifour.four-cle, vclstFour) = 0)
                or (not fIsNull(vcNomRecherchematches) and not ifour.nom matches vcNomRecherchematches + "*")
                or (not fIsNull(vcPrenomTiers)         and not ifour.nom matches vcPrenomTiers + "*")
                or (vcDomaineFour <> "0" and not can-find(first idomfour no-lock
                                 where idomfour.soc-cd   = isoc.soc-cd
                                   and idomfour.dom-cd   = integer(vcDomaineFour)
                                   and idomfour.four-cle = ifour.four-cle))     then next boucleIfour.

                if (vcCategorieFour <> "0" and ifour.categ-cd <> integer(vcCategorieFour))
                or (vcStatutFour = "00001" and ifour.fg-actif = false)                              /* Actif/inactif */ /* DM 0615/0237 */
                or (vcStatutFour = "00002" and ifour.fg-actif = true)
                /* Tous,tous,Référencés,00001,Non référencés,00002,Sans,00003" */
                or (vcFourReferencmt = "00001" and not ifour.refer-cd > "")                         /* referencé/Sans */
                or (vcFourReferencmt = "00002" and     ifour.refer-cd > "") then next boucleIfour.  /* non referencé */

                /* Présents / Résilié */
                if vcTypCtrat = "00001" or vcTypCtrat = "00002" then do:
                    find first ccpt no-lock
                         where ccpt.soc-cd   = ifour.soc-cd
                           and ccpt.coll-cle = ifour.coll-cle
                           and ccpt.cpt-cd   = ifour.cpt-cd no-error.
                    if available ccpt then do:
                        if (vcTypCtrat = "00001" and ccpt.dafin <> ? and ccpt.dafin < today)   /* Present uniquement */
                        or (vcTypCtrat = "00002" and (ccpt.dafin = ? or ccpt.dafin >= today))  /* Résilié uniquement */
                        then next boucleIfour.
                    end.
                    else if vcTypCtrat = "00002" then next boucleIfour.                        /* Résilié uniquement */
                end.

                /* Filtre sur l'immeuble */
                if vlFgImmRch then do:
                    vlFgExeMth = false.
                    /* Le filtre sur l'immeuble est fait en ammont, on peut l'utiliser */
boucleEntree:
                    for each ttListeImmeubleEntree
                        where ttListeImmeubleEntree.cTypeContrat = {&TYPECONTRAT-mandat2Gerance}
                           or ttListeImmeubleEntree.cTypeContrat = {&TYPECONTRAT-mandat2Syndic}
                      , first csscpt no-lock
                        where csscpt.soc-cd   = ifour.soc-cd
                          and csscpt.etab-cd  = ttListeImmeubleEntree.iNumeroContrat
                          and csscpt.coll-cle = ifour.coll-cle
                          and csscpt.cpt-cd   = ifour.cpt-cd:
                        /* Mémorisation des informations sur le contrat */
                        assign
                            vcTypeContratFournisseur   = ttListeImmeubleEntree.cTypeContrat
                            viNumeroContratFournisseur = ttListeImmeubleEntree.iNumeroContrat
                            vlFgExeMth = true
                        .
                        leave boucleEntree.
                    end.
                    if not vlFgExeMth then next boucleIfour.
                end.

                if viNumeroContratFournisseur = 0 then do:
                    /* Si pas de contrat alors on utilise le pseudo-contrat bloc-note */
                    run CreationBlocNote("FOU", integer(ifour.cpt-cd), output viNumeroBN).
                    assign
                        vcTypeContratFournisseur   = {&TYPECONTRAT-blocNote}
                        viNumeroContratFournisseur = viNumeroBN
                    .
                end.
                if not can-find(first ttListeTiers where ttListeTiers.iNumeroTiers = vbRoles.notie)
                then run createTiersFournisseur(vcTypeContratFournisseur, viNumeroContratFournisseur, buffer ifour).
            end.
        end.
    end.
    if valid-handle(ghTelephone) then run destroy in ghTelephone.

end procedure.

procedure RechercheTiersCreation private:
    /*------------------------------------------------------------------------------
    Purpose: Partie commune tiers/role
    notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNoTiersACreer as integer no-undo.
    define input parameter poCollection as collection no-undo.

    // Critères de recherche
    define variable viNoTiersDeb             as int64     no-undo.
    define variable viNoTiersFin             as int64     no-undo.
    define variable vcAdresTiers             as character no-undo.
    define variable vcLstRoleTiers           as character no-undo.
    define variable vcNomImm                 as character no-undo.
    define variable viNoImmDeb               as integer   no-undo.
    define variable viNoImmFin               as integer   no-undo.
    define variable viNoConDeb               as int64     no-undo.
    define variable viNoConFin               as int64     no-undo.
    define variable vcTypCtrat               as character no-undo.
    define variable vcTypRchTiers            as character no-undo.
    define variable vlTiersSansRole          as logical   no-undo.
    define variable vlRolesAssocies          as logical   no-undo.
    define variable vlCtratsAssocies         as logical   no-undo.
    define variable vcNoGesUse               as character no-undo.
    define variable vcNomJFilleTiers         as character no-undo.
    define variable viNumeroSiret            as integer   no-undo.
    define variable vcNumeroSecu             as character no-undo.
    define variable vcListeRolesCSynd        as character no-undo.
    define variable vlVientDeImmeuble        as logical   no-undo.
    define variable vlUniquementAdresseSaisi as logical   no-undo.
    define variable viBoucle                 as integer   no-undo.
    define variable vcLsCttAss               as character no-undo.
    define variable vcTpCttAss               as character no-undo.
    define variable viNumeroBN               as integer   no-undo.
    define variable viCpUseInc               as integer   no-undo.
    define variable vlFgImmRch               as logical   no-undo.

    define buffer vbroles  for roles.
    define buffer vbRoles2 for roles.
    define buffer taint    for taint.
    define buffer ctrat    for ctrat.
    define buffer intnt    for intnt.
    define buffer vbIntnt  for intnt.
    define buffer ctctt    for ctctt.
    define buffer vbCtrat  for ctrat.
    define buffer tiers    for tiers.
    define buffer vbTiers  for tiers.

    /* Chargement des critères */
    assign
        viNoTiersDeb     = poCollection:getInt64("iNumeroTiers1")
        viNoTiersFin     = poCollection:getInt64("iNumeroTiers2")
        vcAdresTiers     = poCollection:getCharacter("cAdresseTiers")
        vcLstRoleTiers   = poCollection:getCharacter("cListeRoleFicheTiers")
        vcNomImm         = poCollection:getCharacter("cNomImmeuble")
        viNoImmDeb       = poCollection:getInteger("iNumeroImmeuble1")
        viNoImmFin       = poCollection:getInteger("iNumeroImmeuble2")
        viNoConDeb       = poCollection:getInt64("iNumeroContrat1")
        viNoConFin       = poCollection:getInt64("iNumeroContrat2")
        vcTypCtrat       = poCollection:getCharacter("cTypeContrat")
        vcTypRchTiers    = poCollection:getCharacter("cTypeRechercheTiers")
        vlTiersSansRole  = poCollection:getLogical("lTiersSansRole")
        vlRolesAssocies  = poCollection:getLogical("lRolesAssocies")
        vlCtratsAssocies = poCollection:getLogical("lContratsAssocies")
        vcNoGesUse       = poCollection:getCharacter("cCodeService")
        vcNomJFilleTiers = poCollection:getCharacter("cNomJeuneFilleTiers")
        viNumeroSiret    = poCollection:getInteger("iNumeroSiret")
        vcNumeroSecu     = poCollection:getCharacter("cNumeroSecu")
        vcListeRolesCSynd = poCollection:getCharacter("cListeRolesCSynd")
        vlVientDeImmeuble = poCollection:getLogical("lVientDeImmeuble")
    .
    {&_proparse_ prolint-nowarn(when)}
    assign
        vcAdresTiers     = ''  when vcAdresTiers = ?
        vcLstRoleTiers   = ''  when vcLstRoleTiers = ?
        vcNomImm         = ''  when vcNomImm = ?
        vcTypCtrat       = ''  when vcTypCtrat = ?
        vcTypRchTiers    = ''  when vcTypRchTiers = ?
        vcNoGesUse       = '0' when vcNoGesUse = ?
        vcNomJFilleTiers =''   when vcNomJFilleTiers = ?
        viNumeroSiret    = 0   when viNumeroSiret = ?
        vcNumeroSecu     = ''  when vcNumeroSecu = ?
        vcNoGesUse       = if vcNoGesUse = "all" or vcNoGesUse = ? then "0" else vcNoGesUse
    .

    for first tiers no-lock
        where tiers.notie = piNoTiersACreer:
        /* Filtre sur le nom de jeune fille */
        if not tiers.lnjf1 matches (vcNomJFilleTiers + "*") and not tiers.lnjf2 matches (vcNomJFilleTiers + "*") then return.

        /* Filtre sur le n° de SIRET */
        if integer(viNumeroSiret) <> 0
        and not can-find(first ctanx no-lock
                         where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                           and ctanx.tprol = {&TYPEROLE-tiers}
                           and ctanx.norol = tiers.notie
                           and ctanx.nosir = integer(viNumeroSiret)) then return.

        if not can-find(first roles no-lock where roles.notie = tiers.notie)
        then do:
            if fIsNull(vcLstRoleTiers) and vlTiersSansRole
            and viNoTiersDeb = 0 and viNoTiersFin = {&NoRolMax} and fIsNull(vcAdresTiers)
            and fIsNull(vcNomImm) and viNoImmDeb = 0 and viNoImmFin = 99999
            and vcNoGesUse = "0"
            and viNoConDeb = 0 and viNoConFin = {&NoCttMax}
            then createttTiers(vcTypRchTiers, input buffer tiers:handle, ?, ?).
        end.
        else for each vbroles no-lock
            where vbRoles.notie = tiers.notie
              and vbRoles.norol >= viNoTiersDeb
              and vbRoles.norol <= viNoTiersFin:

            {&_proparse_ prolint-nowarn(blocklabel)}
            if not (fIsNull(vcLstRoleTiers) or lookup(vbRoles.tprol, vcLstRoleTiers) > 0)
            or fIsImmeuble(vlFgImmRch, vbRoles.tprol, vbRoles.norol)
            or fIsAcheteurVendeur(vcLstRoleTiers, vbRoles.tprol)    /* Ajout Sy le 25/03/2008 : filtre acheteur/vendeur */
            or not fIsSalarie(vcNumeroSecu, vbroles.tprol, vbroles.norol)
            then next.

            /* Filtrage sur le gestionnaire */
            if vcNoGesUse <> "0" then do:
                run application/envt/gesflges.p (mToken, integer(vcNoGesUse), input-output viCpUseInc, 'Direct', vbroles.tprol + '|' + string(vbroles.norol)).
                {&_proparse_ prolint-nowarn(blocklabel)}
                if viCpUseInc <> 0 then next.
            end.

            /* Recherche sur l'adresse */
            {&_proparse_ prolint-nowarn(blocklabel)}
            if not vlVientDeImmeuble and not vlUniquementAdresseSaisi 
            and not rechercheDansAdresses(vcAdresTiers, vbroles.tprol, vbroles.norol) then next.

            /* ajout SY le 02/12/2010 : président du conseil syndical , membre du conseil etc... */
            if lookup(vbroles.tprol, vcListeRolesCSynd) > 0 
            then for each taint no-lock
                where taint.tpidt = vbroles.tprol
                  and taint.noidt = vbroles.noRol
                  and taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and taint.tptac = {&TYPETACHE-conseilSyndical}
                  and (taint.dtfin = ? or (taint.dtfin <> ? and taint.dtfin > today))
              , first ctrat no-lock
                where ctrat.tpcon = taint.tpcon
                  and ctrat.nocon = taint.nocon
                  and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}:

                {&_proparse_ prolint-nowarn(blocklabel)}
                if (vcTypCtrat = "00001" and ctrat.dtree <> ?)                  /* Les présents uniquement */
                or (vcTypCtrat = "00002" and ctrat.dtree = ?)                   /* Les résiliés uniquement */
                or fIsContrat(viNoConDeb, viNoConFin, ctrat.nocon)
                or fIsImmeuble(vlFgImmRch, ctrat.tpcon, ctrat.nocon)
                then next.

                if vcNoGesUse <> "0" then do:
                    run application/envt/gesflges.p (mToken, integer(vcNoGesUse), input-output viCpUseInc, 'Direct', ctrat.tpcon + '|' + string(ctrat.nocon)).
                    {&_proparse_ prolint-nowarn(blocklabel)}
                    if viCpUseInc <> 0 then next.
                end.
                if vcTypRchTiers = "T" then do:
                    if not can-find(first ttListeTiers
                                    where ttListeTiers.iNumeroTiers = vbroles.notie)
                    then createttTiers(vcTypRchTiers, input buffer tiers:handle, ?, ?).
                end.
                else if not can-find(first ttListeTiers
                                    where ttListeTiers.iNumeroTiers   = vbroles.notie
                                      and ttListeTiers.cCodeTypeRole  = vbroles.tprol
                                      and ttListeTiers.iNumeroRole    = vbroles.norol
                                      and ttListeTiers.cTypeContrat   = ctrat.tpcon
                                      and ttListeTiers.iNumeroContrat = ctrat.nocon) 
                then createttTiers(vcTypRchTiers, input buffer tiers:handle, input buffer vbRoles:handle, input buffer ctrat:handle).
            end.
            else do:
                /* Lien contrat - roles */
                case vbRoles.tprol:
                    when {&TYPEROLE-compagnie}           then vcLsCttAss = {&TYPECONTRAT-assuranceGerance}.
                    when {&TYPEROLE-vendeur}             then vcLsCttAss = {&TYPECONTRAT-mutation}.
                    when {&TYPEROLE-acheteur}            then vcLsCttAss = {&TYPECONTRAT-mutation}.
                    when {&TYPEROLE-coproprietaire}       then vcLsCttAss = {&TYPECONTRAT-titre2copro}.
                    when {&TYPEROLE-locataire}           then vcLsCttAss = {&TYPECONTRAT-bail}.
                    when {&TYPEROLE-candidatLocataire}   then vcLsCttAss = {&TYPECONTRAT-preBail}.   /* ajout PL 0309/0284 */
                    when {&TYPEROLE-colocataire}         then vcLsCttAss = {&TYPECONTRAT-bail}.   /* ajout PL 0309/0284 */
                    when {&TYPEROLE-coIndivisaire}       then vcLsCttAss = substitute("&1,&2", {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-titre2copro}).   /* ajout PL 0309/0284 */
                    when {&TYPEROLE-garant}              then vcLsCttAss = {&TYPECONTRAT-bail}.   /* ajout SY le 10/05/2007 : garant associé au Bail pour test Tous/présent/résilié */
                    when {&TYPEROLE-mandant}             then vcLsCttAss = if mToken:cRefPrincipale = "00010" then {&TYPECONTRAT-bail} else {&TYPECONTRAT-mandat2Gerance}.
                    when {&TYPEROLE-syndicat2copro}      then vcLsCttAss = {&TYPECONTRAT-mandat2Syndic}.
                    when {&TYPEROLE-salarie}             then vcLsCttAss = {&TYPECONTRAT-Salarie}.
                    when {&TYPEROLE-salariePegase}       then vcLsCttAss = {&TYPECONTRAT-SalariePegase}.    /* SY 0114/0244 Paie Pégase */
                    when {&TYPEROLE-directeurAgence}     then vcLsCttAss = {&TYPECONTRAT-serviceGestion}.   /* SY 0115/0282 directeur d'agence */
                    when {&TYPEROLE-societeActionnaires} then vcLsCttAss = {&TYPECONTRAT-societe}.
                    otherwise                                 vcLsCttAss = {&TYPECONTRAT-blocNote}.         /* PL : Pour pouvoir stocker le bloc note sur les "fournisseurs" et autre roles sans contrat associé */
                end case.

                do viBoucle = 1 to num-entries(vcLsCttAss):
                    vcTpCttAss = entry(viBoucle, vcLsCttAss).
                    /* Création du contrat bloc-note si inexistant */
                    if vcTpCttAss = {&TYPECONTRAT-blocNote} then run CreationBlocNote(vbRoles.tprol, vbRoles.norol, output viNumeroBN).

                    find first intnt no-lock
                         where intnt.tpidt = vbroles.tprol
                           and intnt.noidt = vbroles.norol
                           and intnt.tpcon = vcTpCttAss no-error.
                    if not available intnt then do:
                        /* modif SY le 10/05/2007 pour les roles sans contrat associé => présent/résilié sans objet */
                        if vcTypCtrat = "tous" or fIsNull(vcTpCttAss) then do:
                            if vcTypRchTiers = "T" then do: 
                                if not can-find(first ttListeTiers
                                                where ttListeTiers.iNumeroTiers = vbRoles.notie)
                                then createttTiers(vcTypRchTiers, input buffer tiers:handle, ?, ?).
                            end.
                            else createttTiers(vcTypRchTiers, input buffer tiers:handle, input buffer vbroles:handle, ?).
                        end.
                    end.
                    else for each intnt no-lock
                        where intnt.tpidt = vbroles.tprol
                          and intnt.noidt = vbroles.norol
                          and intnt.tpcon = vcTpCttAss
                      , first ctrat no-lock
                        where ctrat.tpcon = intnt.tpcon
                          and ctrat.nocon = intnt.nocon
                          and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}:
                        {&_proparse_ prolint-nowarn(blocklabel)}
                        if (vcTypCtrat = "00001" and ctrat.dtree <> ?)    /* Les présents uniquement */
                        or (not (ctrat.tpcon = {&TYPECONTRAT-titre2copro} and intnt.tpidt = {&TYPEROLE-coproprietaire})
                          and vcTypCtrat = "00002" and ctrat.dtree = ?)
                        then next.

                        /* Si copro mais plus de lot sur ce contrat on by-pass si "present" */
                        if intnt.tpidt = {&TYPEROLE-coproprietaire} and intnt.tpcon = {&TYPECONTRAT-titre2copro} then do:
                            find first vbIntnt no-lock
                                where vbIntnt.tpcon = intnt.tpcon
                                  and vbIntnt.nocon = intnt.nocon
                                  and vbIntnt.tpidt = {&TYPEBIEN-lot}
                                  and vbIntnt.nbden = 0 no-error.
                            {&_proparse_ prolint-nowarn(blocklabel)}
                            if (not available vbIntnt and vcTypCtrat = "00001")
                            or (available vbIntnt     and vcTypCtrat = "00002") then next.
                        end.
                        {&_proparse_ prolint-nowarn(blocklabel)}
                        if fIsContrat(viNoConDeb, viNoConFin, ctrat.nocon)
                        or fIsImmeuble(vlFgImmRch, intnt.tpcon, intnt.nocon) 
                        then next.

                        /* Ajout SY le 27/02/2008 : Filtrage sur le gestionnaire */
                        if vcNoGesUse <> "0" then do:
                            run application/envt/gesflges.p (mToken, integer(vcNoGesUse), input-output viCpUseInc, 'Direct', ctrat.tpcon + '|' + string(ctrat.nocon)).
                            {&_proparse_ prolint-nowarn(blocklabel)}
                            if viCpUseInc <> 0 then next.
                        end.
                        if vcTypRchTiers = "T" then do:
                            if not can-find(first ttListeTiers
                                            where ttListeTiers.iNumeroTiers = vbroles.notie)
                            then createttTiers(vcTypRchTiers, input buffer tiers:handle, ?, ?).
                        end.
                        else if not can-find(first ttListeTiers                     // todo: a vérifier entre roles et vbRoles
                                            where ttListeTiers.iNumeroTiers   = vbroles.notie
                                              and ttListeTiers.cCodeTypeRole  = vbroles.tprol
                                              and ttListeTiers.iNumeroRole    = vbroles.norol
                                              and ttListeTiers.cTypeContrat   = intnt.tpcon
                                              and ttListeTiers.iNumeroContrat = intnt.nocon) 
                        then do:
                            createttTiers(vcTypRchTiers, input buffer tiers:handle, input buffer vbRoles:handle, input buffer ctrat:handle).
                            if vlRolesassocies    /* Ajout Sy le 27/03/2008: roles associés (au contrat principal) */ 
                            then for each vbIntnt no-lock
                                where vbIntnt.tpcon = intnt.tpcon
                                  and vbIntnt.nocon = intnt.nocon
                                  and vbIntnt.tpidt <> vbroles.tprol
                                  and vbIntnt.noidt <> vbroles.norol
                                  and vbIntnt.tpidt <> {&TYPEROLE-mandant}       /* sauf role principal du contrat maitre */
                                  and vbIntnt.tpidt <> {&TYPEROLE-syndicat2copro}
                                  and not can-find(first ttListeTiers
                                                where ttListeTiers.cCodeTypeRole  = vbIntnt.tpidt
                                                  and ttListeTiers.iNumeroRole    = vbIntnt.noidt
                                                  and ttListeTiers.cTypeContrat   = vbIntnt.tpcon
                                                  and ttListeTiers.iNumeroContrat = vbIntnt.nocon)
                              , first vbroles2 no-lock
                                where vbroles2.tprol = vbIntnt.tpidt
                                  and vbroles2.norol = vbIntnt.noidt
                              , first vbTiers no-lock
                                where vbTiers.notie = vbroles2.notie:
                                createttTiers(vcTypRchTiers, input buffer vbTiers:handle, input buffer vbroles2:handle, input buffer ctrat:handle).
                            end.
                        end.

                        if vlCtratsassocies then do:
                            for each ctctt no-lock
                                where ctctt.tpct1 = intnt.tpcon
                                  and ctctt.noct1 = intnt.nocon
                                  and ctctt.tpct2 <> {&TYPECONTRAT-mutation}          /* Ajout SY le 25/03/2008 : pas les mutations */
                                  and ctctt.tpct2 <> {&TYPECONTRAT-DossierMutation}
                              , first vbCtrat no-lock
                                where vbCtrat.tpcon = ctctt.tpct2
                                  and vbCtrat.nocon = ctctt.noct2
                              , first vbroles2 no-lock
                                where vbroles2.tprol = vbCtrat.tprol
                                  and vbroles2.norol = vbCtrat.norol
                              , first vbTiers no-lock
                                where vbTiers.notie = vbroles2.notie:
                                if (vcTypRchTiers <> "T" or not can-find(first ttListeTiers where ttListeTiers.iNumeroTiers = vbroles2.notie))
                                and not can-find(first ttListeTiers
                                            where ttListeTiers.iNumeroTiers   = vbroles2.notie
                                              and ttListeTiers.cCodeTypeRole  = (if vcTypRchTiers = "T" then "" else vbroles2.tprol)
                                              and ttListeTiers.iNumeroRole    = (if vcTypRchTiers = "T" then 0  else vbroles2.norol)
                                              and ttListeTiers.cTypeContrat   = vbCtrat.tpcon
                                              and ttListeTiers.iNumeroContrat = vbCtrat.nocon)
                                then createttTiers(vcTypRchTiers, input buffer vbTiers:handle, input buffer vbroles2:handle, input buffer vbCtrat:handle).
                            end.
                            for each ctctt no-lock
                                where ctctt.tpct2 = intnt.tpcon
                                  and ctctt.noct2 = intnt.nocon
                              , first vbCtrat no-lock
                                where vbCtrat.tpcon = ctctt.tpct1
                                  and vbCtrat.nocon = ctctt.noct1
                              , first vbroles2 no-lock
                                where vbroles2.tprol = vbCtrat.tprol
                                  and vbroles2.norol = vbCtrat.norol
                              , first vbTiers no-lock
                                where vbTiers.notie = vbroles2.notie:
                                if (vcTypRchTiers <> "T" or not can-find(first ttListeTiers where ttListeTiers.iNumeroTiers = vbroles2.notie))
                                and not can-find(first ttListeTiers
                                            where ttListeTiers.iNumeroTiers   = vbroles2.notie
                                              and ttListeTiers.cCodeTypeRole  = (if vcTypRchTiers = "T" then "" else vbroles2.tprol)
                                              and ttListeTiers.iNumeroRole    = (if vcTypRchTiers = "T" then 0  else vbroles2.norol)
                                              and ttListeTiers.cTypeContrat   = vbCtrat.tpcon
                                              and ttListeTiers.iNumeroContrat = vbCtrat.nocon)
                                then createttTiers(vcTypRchTiers, input buffer vbTiers:handle, input buffer vbroles2:handle, input buffer vbCtrat:handle).
                            end.
                        end.
                    end.
                end.
            end. /* contrats existent sur le role */
        end. /* for each roles */
    end.

end procedure.

procedure RechercheTiersVientDeImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche si on vient de l'immeuble
    notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.

    // Critères de recherche
    define variable vcAdresTiers      as character no-undo.
    define variable vcLstRoleTiers    as character no-undo.
    define variable viNoImmDeb        as integer   no-undo.
    define variable viNoConDeb        as int64     no-undo.
    define variable viNoConFin        as int64     no-undo.
    define variable vcTypCtrat        as character no-undo.
    define variable vcTypRchTiers     as character no-undo.
    define variable vlRolesAssocies   as logical   no-undo.
    define variable vlCtratsAssocies  as logical   no-undo.
    define variable vcNoGesUse        as character no-undo.
    define variable vcNumeroSecu      as character no-undo.
    define variable vcDomaineFour     as character no-undo.
    define variable vcCategorieFour   as character no-undo.
    define variable vcStatutFour      as character no-undo.
    define variable vcFourReferencmt  as character no-undo.
    define variable vcCodeSociete     as character no-undo.
    define variable vcListeRolesCSynd as character no-undo.
    define variable vlVientDeImmeuble as logical   no-undo.
    define variable viBoucle          as integer   no-undo.
    define variable vcLsCttAss        as character no-undo.
    define variable vcTpCttAss        as character no-undo.
    define variable viNumeroBN        as integer   no-undo.
    define variable viCpUseInc        as integer   no-undo.
    define variable vlFgImmRch        as logical   no-undo.

    define buffer vbroles   for roles.
    define buffer tiers     for tiers. 
    define buffer vbTiers   for tiers. 
    define buffer taint     for taint.
    define buffer ctrat     for ctrat.
    define buffer intnt     for intnt.
    define buffer vbIntnt   for intnt.
    define buffer vbroles2  for roles.
    define buffer ctctt     for ctctt.
    define buffer vbCtrat   for ctrat.
    define buffer imble     for imble.
    define buffer isoc      for isoc.
    define buffer ccptcol   for ccptcol.
    define buffer ifour     for ifour.
    define buffer ccpt      for ccpt.
    define buffer csscpt    for csscpt.

    /* Chargement des critères */
    assign
        vcAdresTiers      = poCollection:getCharacter("cAdresseTiers")
        vcLstRoleTiers    = poCollection:getCharacter("cListeRoleFicheTiers")
        viNoImmDeb        = poCollection:getInteger("iNumeroImmeuble1")
        viNoConDeb        = poCollection:getInt64("iNumeroContrat1")
        viNoConFin        = poCollection:getInt64("iNumeroContrat2")
        vcTypCtrat        = poCollection:getCharacter("cTypeContrat")
        vcTypRchTiers     = poCollection:getCharacter("cTypeRechercheTiers")
        vlRolesAssocies   = poCollection:getLogical("lRolesAssocies")
        vlCtratsAssocies  = poCollection:getLogical("lContratsAssocies")
        vcNoGesUse        = poCollection:getCharacter("cCodeService")
        vcNumeroSecu      = poCollection:getCharacter("cNumeroSecu")
        vcDomaineFour     = poCollection:getCharacter("cDomaineFournisseur")
        vcCategorieFour   = poCollection:getCharacter("cCategorieFournisseur")
        vcStatutFour      = poCollection:getCharacter("cStatutFournisseur")
        vcFourReferencmt  = poCollection:getCharacter("cFournisseurReferencmt")
        vcCodeSociete     = poCollection:getCharacter("cCodeSociete")
        vcListeRolesCSynd = poCollection:getCharacter("cListeRolesCSynd")
        vlVientDeImmeuble = poCollection:getLogical("lVientDeImmeuble")
    .
    {&_proparse_ prolint-nowarn(when)}
    assign
        vcAdresTiers     = '' when vcAdresTiers = ?
        vcLstRoleTiers   = '' when vcLstRoleTiers = ?
        vcTypCtrat       = '' when vcTypCtrat = ?
        vcTypRchTiers    = '' when vcTypRchTiers = ?
        vcNoGesUse       = if vcNoGesUse = "all" or vcNoGesUse = ? then "0" else vcNoGesUse
        vcNumeroSecu     = '' when vcNumeroSecu = ?
        vcDomaineFour    = if vcDomaineFour = "all" or vcDomaineFour = ? then "0" else vcDomaineFour
        vcCategorieFour  = if vcCategorieFour = "all" or vcCategorieFour = ? then "0" else vcCategorieFour
        vcStatutFour     = '' when vcStatutFour = ?
        vcFourReferencmt = '' when vcFourReferencmt = ?
        vcCodeSociete    = mToken:cRefPrincipale when vcCodeSociete = ? or vcCodeSociete = '0'
    .
boucleImmeuble:
    for each ttListeImmeubleEntree
      , first vbRoles no-lock        /* Positionnement sur le role */
        where vbRoles.tprol = ttListeImmeubleEntree.cCodeTypeRole
          and vbRoles.norol = ttListeImmeubleEntree.iNumeroRole
      , first tiers no-lock
        where tiers.notie = vbRoles.notie:

        
        if fIsAcheteurVendeur(vcLstRoleTiers, vbRoles.tprol)    /* Ajout Sy le 25/03/2008 : filtre acheteur/vendeur */
        or not fIsSalarie(vcNumeroSecu, vbroles.tprol, vbroles.norol) then next boucleImmeuble.

        /* Filtrage sur le gestionnaire */
        if vcNoGesUse <> "0" then do:
            run application/envt/gesflges.p (mToken, integer(vcNoGesUse), input-output viCpUseInc, 'Direct', vbRoles.tprol + '|' + string(vbRoles.norol)).
            if viCpUseInc <> 0 then next boucleImmeuble.
        end.
        /* Recherche sur l'adresse */
        if not vlVientDeImmeuble and not rechercheDansAdresses(vcAdresTiers, vbRoles.tprol, vbRoles.norol) then next boucleImmeuble.

        /* ajout SY le 06/12/2010 : président du conseil syndical , membre du conseil etc... */
        {&_proparse_ prolint-nowarn(do1)}
        if lookup(vbroles.tprol, vcListeRolesCSynd) > 0 then do:
boucleTache:
            for each taint no-lock
               where taint.tpidt = vbroles.tprol
                 and taint.noidt = vbroles.NoRol
                 and taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
                 and taint.tptac = {&TYPETACHE-conseilSyndical}
                 and (taint.dtfin = ? or (taint.dtfin <> ? and taint.dtfin > today) )
             , first ctrat no-lock
               where ctrat.tpcon = taint.tpcon
                 and ctrat.nocon = taint.nocon
                 and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}
             , first intnt no-lock
               where intnt.tpcon = ctrat.tpcon
                 and intnt.nocon = ctrat.nocon
                 and intnt.tpidt = {&TYPEBIEN-immeuble}
                 and intnt.noidt = (if vlVientDeImmeuble then viNoImmDeb else intnt.noidt):

                if (vcTypCtrat = "00001" and ctrat.dtree <> ?)  /* Les présents uniquement */
                or (vcTypCtrat = "00002" and ctrat.dtree  = ?)  /* Les résiliés uniquement */
                or fIsImmeuble(vlFgImmRch, intnt.tpcon, intnt.nocon) then next boucleTache.

                if vcNoGesUse <> "0" then do:
                    run application/envt/gesflges.p (mToken, integer(vcNoGesUse), input-output viCpUseInc, 'Direct', substitute('&1|&2', ctrat.tpcon, ctrat.nocon)).
                    if viCpUseInc <> 0 then next boucleTache.
                end.

                if vcTypRchTiers = "T" then do:
                    if not can-find(first ttListeTiers
                                    where ttListeTiers.iNumeroTiers = vbroles.notie)
                    then createttTiers(vcTypRchTiers, input buffer tiers:handle, ?, ?).
                end.
                else if not can-find(first ttListeTiers
                                     where ttListeTiers.iNumeroTiers   = vbRoles.notie
                                       and ttListeTiers.cCodeTypeRole  = vbRoles.tprol
                                       and ttListeTiers.iNumeroRole    = vbRoles.norol
                                       and ttListeTiers.cTypeContrat   = ctrat.tpcon
                                       and ttListeTiers.iNumeroContrat = ctrat.nocon)
                then createttTiers(vcTypRchTiers, input buffer tiers:handle, input buffer vbroles:handle, input buffer ctrat:handle).
            end.
        end.
        else do:
            /* Lien contrat - roles */
            case vbroles.tprol:
                when {&TYPEROLE-compagnie}           then vcLsCttAss = {&TYPECONTRAT-assuranceGerance}.
                when {&TYPEROLE-vendeur}             then vcLsCttAss = {&TYPECONTRAT-mutation}.
                when {&TYPEROLE-acheteur}            then vcLsCttAss = {&TYPECONTRAT-mutation}.
                when {&TYPEROLE-coproprietaire}       then vcLsCttAss = {&TYPECONTRAT-titre2copro}.
                when {&TYPEROLE-locataire}           then vcLsCttAss = {&TYPECONTRAT-bail}.
                when {&TYPEROLE-candidatLocataire}   then vcLsCttAss = {&TYPECONTRAT-preBail}.   /* ajout PL 0309/0284 */
                when {&TYPEROLE-colocataire}         then vcLsCttAss = {&TYPECONTRAT-bail}.      /* ajout PL 0309/0284 */
                when {&TYPEROLE-coIndivisaire}       then vcLsCttAss = substitute("&1,&2", {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-titre2copro}).   /* ajout PL 0309/0284 */
                when {&TYPEROLE-garant}              then vcLsCttAss = {&TYPECONTRAT-bail}.      /* ajout SY le 10/05/2007 : garant associé au Bail pour test Tous/présent/résilié */
                when {&TYPEROLE-mandant}             then vcLsCttAss = if mToken:cRefPrincipale = "00010" then {&TYPECONTRAT-bail} else {&TYPECONTRAT-mandat2Gerance}. 
                when {&TYPEROLE-syndicat2copro}      then vcLsCttAss = {&TYPECONTRAT-mandat2Syndic}.
                when {&TYPEROLE-salarie}             then vcLsCttAss = {&TYPECONTRAT-Salarie}.
                when {&TYPEROLE-salariePegase}       then vcLsCttAss = {&TYPECONTRAT-SalariePegase}.    /* SY 0114/0244 Paie Pégase */
                when {&TYPEROLE-directeurAgence}     then vcLsCttAss = {&TYPECONTRAT-serviceGestion}.   /* SY 0115/0282 directeur d'agence */
                when {&TYPEROLE-societeActionnaires} then vcLsCttAss = {&TYPECONTRAT-societe}.
                otherwise                                 vcLsCttAss = {&TYPECONTRAT-blocNote}.         /* PL le 29/06/2007 : Pour pouvoir stocker le bloc note sur les "fournisseurs" et autre roles sans contrat associé */
            end case.

            do viBoucle = 1 to num-entries(vcLsCttAss):
                vcTpCttAss = entry(viBoucle, vcLsCttAss).
                /* Création du contrat bloc-note si inexistant */
                if vcTpCttAss = {&TYPECONTRAT-blocNote} then run CreationBlocNote(vbroles.tprol, vbroles.norol, output viNumeroBN).

                find first intnt no-lock
                     where intnt.tpidt = vbroles.tprol
                       and intnt.noidt = vbroles.norol
                       and intnt.tpcon = vcTpCttAss no-error.
                if not available intnt then do:
                    /* modif SY le 10/05/2007 pour les roles sans contrat associé => présent/résilié sans objet */
                    if vcTypCtrat = "tous" or fIsNull(vcTpCttAss) then do:
                        if vcTypRchTiers = "T" then do:
                            if not can-find(first ttListeTiers
                                            where ttListeTiers.iNumeroTiers = vbroles.notie)
                            then createttTiers(vcTypRchTiers, input buffer tiers:handle, ?, ?).
                        end.
                        else createttTiers(vcTypRchTiers, input buffer tiers:handle, input buffer vbroles:handle, ?).
                    end.
                end.
                else do:
boucleContrat:
                    for each intnt no-lock
                       where intnt.tpidt = vbroles.tprol
                         and intnt.noidt = vbroles.norol
                         and intnt.tpcon = vcTpCttAss
                     , first ctrat no-lock
                       where ctrat.tpcon = intnt.tpcon
                         and ctrat.nocon = intnt.nocon
                         and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}:

                        if (vcTypCtrat = "00001" and ctrat.dtree <> ?)    /* Les présents uniquement */
                        or (vcTypCtrat = "00002" and ctrat.dtree = ?)     /* Les présents uniquement */
                        or fIsContrat(viNoConDeb, viNoConFin, ctrat.nocon)
                        or fIsImmeuble(vlFgImmRch, intnt.tpcon, intnt.nocon)
                        then next boucleContrat.

                         /* Ajout SY le 27/02/2008 : Filtrage sur le gestionnaire */
                        if vcNoGesUse <> "0" then do:
                            run application/envt/gesflges.p (mToken, integer(vcNoGesUse), input-output viCpUseInc, 'Direct', ctrat.tpcon + '|' + string(ctrat.nocon)).
                            if viCpUseInc <> 0 then next boucleContrat.
                        end.

                        if vcTypRchTiers = "T" then do:
                            if not can-find(first ttListeTiers
                                            where ttListeTiers.iNumeroTiers = vbroles.notie)
                            then createttTiers(vcTypRchTiers, input buffer tiers:handle, ?, ?).
                        end.
                        else do:
                            if not can-find(first ttListeTiers
                                            where ttListeTiers.iNumeroTiers   = vbroles.notie
                                              and ttListeTiers.cCodeTypeRole  = vbroles.tprol
                                              and ttListeTiers.iNumeroRole    = vbroles.norol
                                              and ttListeTiers.cTypeContrat   = intnt.tpcon
                                              and ttListeTiers.iNumeroContrat = intnt.nocon) then do:
                                createttTiers(vcTypRchTiers, input buffer tiers:handle, input buffer vbroles:handle, input buffer ctrat:handle).
                                /* Ajout Sy le 27/03/2008 : roles associés (au contrat principal) */
                                if vlRolesassocies then do:
                                    for each vbIntnt no-lock
                                        where vbIntnt.tpcon = intnt.tpcon
                                          and vbIntnt.nocon = intnt.nocon
                                          and vbIntnt.tpidt <> vbRoles.tprol
                                          and vbIntnt.noidt <> vbRoles.norol
                                          and vbIntnt.tpidt <> {&TYPEROLE-mandant}       /* sauf role principal du contrat maitre */
                                          and vbIntnt.tpidt <> {&TYPEROLE-syndicat2copro}
                                      , first vbroles2 no-lock
                                        where vbRoles2.tprol = vbIntnt.tpidt
                                          and vbRoles2.norol = vbIntnt.noidt
                                      , first vbTiers no-lock
                                        where vbTiers.notie = vbRoles2.notie:
                                        if not can-find(first ttListeTiers
                                                        where ttListeTiers.cCodeTypeRole  = vbIntnt.tpidt
                                                          and ttListeTiers.iNumeroRole    = vbIntnt.noidt
                                                          and ttListeTiers.cTypeContrat   = vbIntnt.tpcon
                                                          and ttListeTiers.iNumeroContrat = vbIntnt.nocon)
                                        then createttTiers(vcTypRchTiers, input buffer vbTiers:handle, input buffer vbroles2:handle, input buffer ctrat:handle).
                                    end.
                                end.
                            end.
                        end.

                        if vlCtratsassocies then do:
                            for each ctctt no-lock
                               where ctctt.tpct1 = intnt.tpcon
                                 and ctctt.noct1 = intnt.nocon
                                 and ctctt.tpct2 <> {&TYPECONTRAT-mutation}          /* Ajout SY le 25/03/2008 : pas les mutations */
                                 and ctctt.tpct2 <> {&TYPECONTRAT-DossierMutation}
                             , first vbCtrat no-lock
                               where vbCtrat.tpcon = ctctt.tpct2
                                 and vbCtrat.nocon = ctctt.noct2
                             , first vbRoles2 no-lock
                               where vbRoles2.tprol = vbCtrat.tprol
                                 and vbRoles2.norol = vbCtrat.norol
                             , first vbTiers no-lock
                               where vbTiers.notie = vbRoles2.notie:
                                if (vcTypRchTiers = "T" and can-find(first ttListeTiers where ttListeTiers.iNumeroTiers = vbRoles2.notie))
                                or can-find(first ttListeTiers
                                            where ttListeTiers.iNumeroTiers   = vbRoles2.notie
                                              and ttListeTiers.cCodeTypeRole  = (if vcTypRchTiers = "T" then "" else vbroles2.tprol)
                                              and ttListeTiers.iNumeroRole    = (if vcTypRchTiers = "T" then 0  else vbroles2.norol)
                                              and ttListeTiers.cTypeContrat   = vbCtrat.tpcon
                                              and ttListeTiers.iNumeroContrat = vbCtrat.nocon) then.
                                else createttTiers(vcTypRchTiers, input buffer vbTiers:handle, input buffer vbroles2:handle, input buffer vbCtrat:handle).
                            end.

                            for each ctctt no-lock
                                where ctctt.tpct2 = intnt.tpcon
                                  and ctctt.noct2 = intnt.nocon
                              , first vbCtrat no-lock
                                where vbCtrat.tpcon = ctctt.tpct1
                                  and vbCtrat.nocon = ctctt.noct1
                              , first vbRoles2 no-lock
                                where vbRoles2.tprol = vbCtrat.tprol
                                  and vbRoles2.norol = vbCtrat.norol
                              , first vbTiers no-lock
                                where vbTiers.notie = vbRoles2.notie:
                                if (vcTypRchTiers = "T" and can-find(first ttListeTiers where ttListeTiers.iNumeroTiers = vbRoles2.notie))
                                or can-find(first ttListeTiers
                                            where ttListeTiers.iNumeroTiers   = vbRoles2.notie
                                              and ttListeTiers.cCodeTypeRole  = (if vcTypRchTiers = "T" then "" else vbroles2.tprol)
                                              and ttListeTiers.iNumeroRole    = (if vcTypRchTiers = "T" then 0  else vbroles2.norol)
                                              and ttListeTiers.cTypeContrat   = vbCtrat.tpcon
                                              and ttListeTiers.iNumeroContrat = vbCtrat.nocon) then.
                                else createttTiers(vcTypRchTiers, input buffer vbTiers:handle, input buffer vbroles2:handle, input buffer vbCtrat:handle).
                            end.
                        end.
                    end.
                end. /* contrats existent sur le role */
            end. /* do viBoucle = 1 to num-entries(vcLsCttAss) */
        end.
    end.

    /*--RECHERCHE FOURNISSEURS-------------------------------------------------------------------------------------------------*/
    /*if DonneParametre("RECHERCHE-PAS-FOURNISSEUR") = "" then do:*/    // npo ???
    for first isoc no-lock
         where isoc.soc-cd = integer(vcCodeSociete)
        //where isoc.specif-cle = 1000 no-lock no-error.  npo code actuel
      , first ccptcol no-lock
        where ccptcol.soc-cd = isoc.soc-cd
          and ccptcol.tprole = 12:

        /* On cherche les tiers/roles de l'immeuble, autant partir de l'immeuble que l'on sait unique */
        /* Extraction */
boucleImmeuble:
        for each imble no-lock
           where imble.noimm = viNoImmDeb
          , each intnt no-lock
           where intnt.tpidt  = {&TYPEBIEN-immeuble}
             and intnt.noidt  = imble.noimm
             and (intnt.tpcon = {&TYPECONTRAT-mandat2Gerance} or intnt.tpcon = {&TYPECONTRAT-mandat2Syndic})
         , first csscpt no-lock
           where csscpt.soc-cd   = ccptcol.soc-cd
             and csscpt.etab-cd  = intnt.nocon
             and csscpt.coll-cle = ccptcol.coll-cle
         , first ifour no-lock
           where ifour.soc-cd   = csscpt.soc-cd
             and ifour.coll-cle = csscpt.coll-cle
             and ifour.cpt-cd   = csscpt.cpt-cd
             and ifour.cpt-cd  <> "99999":

            if vcDomaineFour <> "0"
            and not can-find(first idomfour no-lock
                     where idomfour.soc-cd = isoc.soc-cd
                       and idomfour.dom-cd = INTEGER(vcDomaineFour)
                       and idomfour.four-cle = ifour.four-cle) then next boucleImmeuble.

            if (vcCategorieFour <> "0" and ifour.categ-cd <> integer(vcCategorieFour))
            or (vcStatutFour = "00001" and ifour.fg-actif = false)    /* actif/inactif */ /* DM 0615/0237 */
            or (vcStatutFour = "00002" and ifour.fg-actif = true)
            /* Tous,tous,Référencés,00001,Non référencés,00002,Sans,00003" */
            or (vcFourReferencmt = "00001" and not ifour.refer-cd > "")     /* referencé/Sans */
            or (vcFourReferencmt = "00002" and     ifour.refer-cd > "")     /* non referencé */
            then next boucleImmeuble.

            /* Présents / Résilié */
            if vcTypCtrat = "00001" or vcTypCtrat = "00002" then do:
                find first ccpt no-lock
                     where ccpt.soc-cd   = ifour.soc-cd
                       and ccpt.coll-cle = ifour.coll-cle
                       and ccpt.cpt-cd   = ifour.cpt-cd no-error.
                if available ccpt then do:
                    if (vcTypCtrat = "00001" and ccpt.dafin <> ? and ccpt.dafin < today)                             /* Present uniquement */
                    or (vcTypCtrat = "00002" and (ccpt.dafin = ? or ccpt.dafin >= today)) then next boucleImmeuble.  /* Résilié uniquement */
                end.
                else if vcTypCtrat = "00002" then next boucleImmeuble.                                               /* Résilié uniquement */
            end.

            if not can-find(first ttListeTiers where ttListeTiers.iNumeroTiers = integer(ifour.cpt-cd))
            then run createTiersFournisseur('', 0, buffer ifour).
        end.
    end.
    if valid-handle(ghTelephone) then run destroy in ghTelephone.

end procedure.

procedure CreationBlocNote private:
    /*------------------------------------------------------------------------------
    Purpose: Création du pseudo-contrat bloc-note
    notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole   as character no-undo.
    define input  parameter piNumeroRole as integer   no-undo.
    define output parameter piNumeroBN  as integer   no-undo.

    define variable viNumeroDocument     as integer   no-undo.
    define variable viNumeroContrat      as integer   no-undo.

    define buffer ctrat  for ctrat.
    define buffer intnt  for intnt.

    /*--> NP 1110/0053 : Vérif si le bloc-notes existe déjà **/
    for first intnt no-lock
         where intnt.tpcon = {&TYPECONTRAT-blocNote}
           and intnt.tpidt = pcTypeRole
           and intnt.noidt = piNumeroRole:
        piNumeroBN = intnt.nocon.
        return.
    end.
    assign
        viNumeroDocument = 1
        viNumeroContrat  = 1
    .
    {&_proparse_ prolint-nowarn(wholeindex)}
    find last ctrat no-lock no-error.
    if available ctrat then viNumeroDocument = ctrat.nodoc + 1.
    find last ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-blocNote}
          and ctrat.nocon < 90000 no-error.
    if available ctrat then viNumeroContrat = ctrat.nocon + 1.
    /* création du contrat */
    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-blocNote}
           and ctrat.nocon = piNumeroRole no-error.
    if not available ctrat then do:
        create ctrat.
        assign
            ctrat.nodoc = viNumeroDocument
            ctrat.tpcon = {&TYPECONTRAT-blocNote}
            ctrat.nocon = viNumeroContrat
            ctrat.dtcsy = today
            ctrat.hecsy = mtime
            ctrat.cdcsy = "RchTieOb"
        .
    end.
    else viNumeroContrat = piNumeroRole. /* Pour ne pas "trop" casser l'ancienne numérotation */

    if not can-find(first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-blocNote}
                      and intnt.nocon = viNumeroContrat
                      and intnt.tpidt = pcTypeRole
                      and intnt.noidt = piNumeroRole)
    then do:
        create intnt.
        assign
            intnt.tpidt = pcTypeRole
            intnt.noidt = piNumeroRole
            intnt.tpcon = ctrat.tpcon
            intnt.nocon = ctrat.nocon
            intnt.dtcsy = ctrat.dtcsy
            intnt.hecsy = ctrat.hecsy
            intnt.cdcsy = ctrat.cdcsy
        .
    end.
    piNumeroBN = viNumeroContrat.

end procedure.

procedure DonneRoleTiers private:
    /*------------------------------------------------------------------------------
    Purpose: Renseigne les variables pcTypeRoleTiers et piNumeroRoleTiers suivant que le
             role du tiers est un "vrai" role ou le premier role trouvé pour ce tiers
    notes  :
    ------------------------------------------------------------------------------*/
    define output parameter pcTypeRoleTiers   as character no-undo.
    define output parameter piNumeroRoleTiers as integer   no-undo.
    define output parameter plRoleParDefaut   as logical   no-undo.

    if not available ttListeTiers
    then assign
        pcTypeRoleTiers   = ""
        piNumeroRoleTiers = 0
        plRoleParDefaut   = false
    .
    /* Savoir si c'est le role ou le role par défaut du tiers */
    if not fIsNull(ttListeTiers.cCodeTypeRole)
    then assign
        pcTypeRoleTiers   = ttListeTiers.cCodeTypeRole
        piNumeroRoleTiers = ttListeTiers.iNumeroRole
        plRoleParDefaut   = false
    .
    else assign
        pcTypeRoleTiers   = ttListeTiers.cCodeTypRoleDefaut
        piNumeroRoleTiers = ttListeTiers.iNumeroRoleDefaut
        plRoleParDefaut   = true
    .
end procedure.

procedure InfoTiers private:
    /*------------------------------------------------------------------------------
    Purpose:  Renseigner les informations concernant la liste des tiers générés
    notes  :  Ajout infos bancaires pour la modernisation
    ------------------------------------------------------------------------------*/
    define input-output parameter pcLbAdrRole as character no-undo.

    define variable vcTypeRoleTiers         as character no-undo.
    define variable viNumeroRoleTiers       as integer   no-undo.
    define variable vlRoleParDefaut         as logical   no-undo.
    define variable vhTiers                 as handle    no-undo.
    define variable vcInformationsBancaires as character no-undo.

    define buffer vbroles    for roles.
    define buffer intnt      for intnt.
    define buffer ctrat      for ctrat.
    define buffer ladrs      for ladrs.
    define buffer telephones for telephones.
    define buffer ctctt      for ctctt.
    define buffer imble      for imble.

    if not available ttListeTiers then return.

    if ttListeTiers.cCodeTypeRole <> "FOU" then do:
        run tiers/tiers.p persistent set vhTiers. //pour récupérer les informations bancaires
        run getTokenInstance in vhTiers(mToken:JSessionId).

        // Info tiers
        assign 
            ttListeTiers.cNomTiers         = outilFormatage:getNomSocieteTiers(ttListeTiers.iNumeroTiers) // Nom Complet et representant
            ttListeTiers.cLibelleCivilite  = outilFormatage:getCiviliteTiers(ttListeTiers.iNumeroTiers) // Civilité
            ttListeTiers.cLibelleSituation = (if ttListetiers.cCodeFamille = {&FAMILLETIERS-personneIndividu} then ttListetiers.cLibelleProfession1 else outilTraduction:getLibelleProg("O_SIT", ttListetiers.cCodeSituation))
        .
        // Si le type de role est vide, il faut aller chercher le premier rôle dispo dans l'ordre : Mandant, copro, locataire
        if fIsNull(ttListeTiers.cCodeTypeRole) then do:
boucleRoles:
            for each vbroles no-lock
               where vbroles.tprol = {&TYPEROLE-mandant}
                 and vbroles.notie = ttListeTiers.iNumeroTiers
              , each intnt no-lock
               where intnt.tpidt = vbRoles.tprol
                 and intnt.noidt = vbRoles.norol
                 and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
             , first ctrat no-lock
               where ctrat.tpcon = intnt.tpcon
                 and ctrat.nocon = intnt.nocon
                 and ctrat.dtree = ?:
                assign
                    ttListeTiers.cCodeTypRoleDefaut = vbroles.tprol
                    ttListeTiers.iNumeroRoleDefaut  = vbroles.norol
                .
                leave boucleRoles.
            end.
            if fIsNull(ttListeTiers.cCodeTypRoleDefaut)
            then for first vbRoles no-lock
                 where vbRoles.tprol = {&TYPEROLE-coproprietaire}
                   and vbRoles.notie = ttListeTiers.iNumeroTiers:
                assign
                    ttListeTiers.cCodeTypRoleDefaut = vbRoles.tprol
                    ttListeTiers.iNumeroRoleDefaut  = vbRoles.norol
                .
            end.
            if fIsNull(ttListeTiers.cCodeTypRoleDefaut)
            then for each vbRoles no-lock
                where vbRoles.tprol = {&TYPEROLE-locataire}
                  and vbRoles.notie = ttListeTiers.iNumeroTiers
              , each intnt no-lock
                where intnt.tpidt = vbRoles.tprol
                  and intnt.noidt = vbRoles.norol
                  and intnt.tpcon = {&TYPECONTRAT-bail}
              , first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                  and ctrat.nocon = intnt.nocon
                  and ctrat.dtree = ?:
                assign
                    ttListeTiers.cCodeTypRoleDefaut = vbroles.tprol
                    ttListeTiers.iNumeroRoleDefaut  = vbroles.norol
                .
                {&_proparse_ prolint-nowarn(blockLabel)}
                leave.
            end.

            if fIsNull(ttListeTiers.cCodeTypRoleDefaut) 
            then for first vbroles no-lock
                where vbroles.notie = ttListeTiers.iNumeroTiers:
                assign
                    ttListeTiers.cCodeTypRoleDefaut = vbroles.tprol
                    ttListeTiers.iNumeroRoleDefaut  = vbroles.norol
                .
            end.
        end.

        // Info roles
        run DonneRoleTiers(output vcTypeRoleTiers, output viNumeroRoleTiers, output vlRoleParDefaut).

        for first vbroles no-lock
            where vbroles.tprol = vcTypeRoleTiers
              and vbroles.norol = viNumeroRoleTiers:
            if fIsNull(pcLbAdrRole) 
            then pcLbAdrRole = outilFormatage:getAdresseTelephonesRole(vcTypeRoleTiers, viNumeroRoleTiers). /* ancien frmadr4 dans fctgene.i */
            assign
                ttListeTiers.cAdresseTiers    = entry(1, pcLbAdrRole, separ[1])
                ttListeTiers.cCodePostalTiers = entry(2, pcLbAdrRole, separ[1])
                ttListeTiers.cVilleTiers      = entry(3, pcLbAdrRole, separ[1])
                ttListeTiers.cPaysTiers       = entry(7, pcLbAdrRole, separ[1])
            .
            if not vlRoleParDefaut then ttListeTiers.cLibelleTypeRole = outilTraduction:getLibelleProg("O_ROL", vcTypeRoleTiers).

            find first ladrs no-lock
                 where ladrs.tpidt = vcTypeRoleTiers
                   and ladrs.noidt = viNumeroRoleTiers
                   and ladrs.tpadr = {&TYPEADRESSE-Principale} no-error.
            if available ladrs then do:
                ttListeTiers.iNumeroLienAdresse = ladrs.nolie.
                find first telephones no-lock
                    where telephones.tpidt = ladrs.tpidt
                      and telephones.noidt = ladrs.noidt no-error.
                if not available telephones then do:
                   if      ladrs.cdte1 = {&CODETELEPHONE-mail} then ttListeTiers.cEmailTiers = ladrs.note1.
                   else if ladrs.cdte2 = {&CODETELEPHONE-mail} then ttListeTiers.cEmailTiers = ladrs.note2.
                   else if ladrs.cdte3 = {&CODETELEPHONE-mail} then ttListeTiers.cEmailTiers = ladrs.note3.
                    
                   if      ladrs.cdte1 <> {&CODETELEPHONE-mail} and ladrs.cdte1 <> {&CODETELEPHONE-fax} then ttListeTiers.cTelephoneTiers = ladrs.note1.
                   else if ladrs.cdte2 <> {&CODETELEPHONE-mail} and ladrs.cdte2 <> {&CODETELEPHONE-fax} then ttListeTiers.cTelephoneTiers = ladrs.note2.
                   else if ladrs.cdte3 <> {&CODETELEPHONE-mail} and ladrs.cdte3 <> {&CODETELEPHONE-fax} then ttListeTiers.cTelephoneTiers = ladrs.note3.
                end.
                else do:
                    if not valid-handle(ghTelephone) then do:
                        run adresse/fcttelep.p persistent set ghTelephone.
                        run getTokenInstance in ghTelephone (mToken:JSessionId).
                    end.
                    assign
                        ttListeTiers.cTelephoneTiers = dynamic-function('getPremierTelephone' in ghTelephone, ladrs.tpidt, ladrs.noidt)
                        ttListeTiers.cEmailTiers     = dynamic-function('getPremierMail'      in ghTelephone, ladrs.tpidt, ladrs.noidt)
                    .
                end.
            end.
        end.
        vcInformationsBancaires = dynamic-function("getInformationsBancairesTiers" in vhTiers ,
                                                  if not(fIsNull(ttListeTiers.cCodeTypeRole)) then ttListeTiers.cCodeTypeRole else ttListeTiers.cCodeTypRoleDefaut,
                                                  if not(fIsNull(ttListeTiers.cCodeTypeRole)) then ttListeTiers.iNumeroRole else ttListeTiers.iNumeroRoleDefaut,
                                                  ttListeTiers.cTypeContrat,
                                                  ttListeTiers.iNumeroContrat,
                                                  ttListeTiers.iNumeroTiers
                                                  ).
        run destroy in vhTiers.
        assign
            ttListeTiers.cIBAN          = if entry(1, vcInformationsBancaires, separ[1]) > "" then string(entry(1, vcInformationsBancaires, separ[1]), "XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XX") else ""
            ttListeTiers.cBIC           = entry(2, vcInformationsBancaires, separ[1])
            ttListeTiers.cTitulaire     = entry(3, vcInformationsBancaires, separ[1])
            ttListeTiers.cDomiciliation = entry(4, vcInformationsBancaires, separ[1])
        .
    end.

    /* Information contrat */
    find first ctrat no-lock
         where ctrat.tpcon = ttListeTiers.cTypeContrat
           and ctrat.nocon = ttListeTiers.iNumeroContrat no-error.
    if available ctrat then do:
        ttListeTiers.cLibelleContrat = outilTraduction:getLibelleProg("O_CLC", ctrat.tpcon).

        case ctrat.tpcon:
            when {&TYPECONTRAT-mutation} or when {&TYPECONTRAT-titre2copro} then do:
                for first ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.tpct2 = ctrat.tpcon
                      and ctctt.noct2 = ctrat.nocon
                  , first intnt no-lock
                    where intnt.tpcon = ctctt.tpct1
                      and intnt.nocon = ctctt.noct1
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                  , first imble no-lock
                    where imble.noimm = intnt.noidt:

                    assign
                        ttListeTiers.iNumeroImmeuble = imble.noimm
                        ttListeTiers.cNomImmeuble    = imble.lbnom
                    .
/* Todo ??? Plus besoin : en attente confirmation
                    LbTmpPdt = FRMADR4({&TYPEBIEN-immeuble}, imble.noimm).
                    assign
                        ttListeTiers.AdImm = entry(1, LbTmpPdt, separ[1])
                        ttListeTiers.CpImm = entry(2, LbTmpPdt, separ[1])
                        ttListeTiers.ViImm = entry(3, LbTmpPdt, separ[1])
                    .
                    /* Agence du mandat */
                    run RchAgeMdt (input ctctt.tpct1, input ctctt.noct1, output ttListeTiers.noage, output ttListeTiers.lbage).
*/
                end.
            end.
            otherwise do:
                for first intnt no-lock
                    where intnt.tpcon = ttListeTiers.cTypeContrat
                      and intnt.nocon = ttListeTiers.iNumeroContrat
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                  , first imble no-lock
                    where imble.noimm = intnt.noidt:

                    assign
                        ttListeTiers.iNumeroImmeuble = imble.noimm
                        ttListeTiers.cNomImmeuble    = imble.lbnom
                    .
/* Todo ??? Plus besoin : en attente confirmation
                    LbTmpPdt = FRMADR4({&TYPEBIEN-immeuble}, imble.noimm).
                    assign
                        ttListeTiers.AdImm = entry(1,LbTmpPdt,SEPAR[1])
                        ttListeTiers.CpImm = entry(2,LbTmpPdt,SEPAR[1])
                        ttListeTiers.ViImm = entry(3,LbTmpPdt,SEPAR[1])
                    .
*/
                end.
/* Todo ??? Plus besoin : en attente confirmation
                find first b2_ctctt
                    where b2_ctctt.tpct1 >= "01003"
                      and b2_ctctt.tpct1 <= "01030"
                      and b2_ctctt.tpct2 = ctrat.tpcon
                      and b2_ctctt.noct2 = ctrat.nocon no-lock no-error.
                if available b2_ctctt then do:
                    /* Agence du mandat */
                    run RchAgeMdt (input b2_ctctt.tpct1, b2_ctctt.noct1, output ttListeTiers.noage, output ttListeTiers.lbage).
                end.
                else do:
                    /* Agence du mandat */
                    run RchAgeMdt (input ctrat.tpcon, ctrat.nocon, output ttListeTiers.noage, output ttListeTiers.lbage).
                end.
*/
            end.
        end case.
    end.
    if valid-handle(ghTelephone) then run destroy in ghTelephone.

end procedure.

procedure createTiersFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContratFournisseur   as character no-undo.
    define input parameter piNumeroContratFournisseur as integer   no-undo.
    define parameter buffer ifour for ifour.

    define buffer ilibrais for ilibrais.
    define buffer ilibpays for ilibpays.
    define buffer iribfour for iribfour.

    if not valid-handle(ghTelephone)  // comme on est dans une boucle, un seul chargement, c'est mieux !!
    then do:
        run adresse/fcttelep.p persistent set ghTelephone.
        run getTokenInstance in ghTelephone (mToken:JSessionId).
    end.
    create ttListeTiers.
    assign
        giNombreTiers                 = giNombreTiers + 1
        ttListeTiers.iNumeroTiers     = integer(ifour.cpt-cd)
        ttListeTiers.cCodeTypeRole    = "FOU"
        ttListeTiers.iNumeroRole      = integer(ifour.cpt-cd)
        ttListeTiers.cNomTiers        = ifour.nom
        ttListeTiers.cAdresseTiers    = ifour.adr[1]
        ttListeTiers.cCodePostalTiers = ifour.cp
        ttListeTiers.cVilleTiers      = ifour.ville
        ttListeTiers.cLibelleTypeRole = "Fournisseur"
        ttListeTiers.lFgActif         = ifour.fg-actif /* DM 0615/0237 */
        ttListeTiers.cCodeReference   = ifour.refer-cd /* DM 0615/0237 */
        ttListeTiers.cTelephoneTiers  = dynamic-function('getPremierTelephoneFournisseur' in ghTelephone, ifour.soc-cd, integer(ifour.cpt-cd), ifour.four-cle)
        ttListeTiers.cEmailTiers      = dynamic-function('getPremierMailFournisseur'      in ghTelephone, ifour.soc-cd, integer(ifour.cpt-cd), ifour.four-cle)
        ttListeTiers.cTypeContrat     = pcTypeContratFournisseur
        ttListeTiers.iNumeroContrat   = piNumeroContratFournisseur
    .
    for first ilibrais no-lock
        where ilibrais .soc-cd    = ifour.soc-cd
          and ilibrais.librais-cd = ifour.librais-cd:
        ttListeTiers.cLibelleCivilite = ilibrais.lib.
    end.
    for first ilibpays no-lock
        where ilibpays .soc-cd    = ifour.soc-cd
          and ilibpays.libpays-cd = ifour.libpays-cd:
        ttListeTiers.cPaysTiers = ilibpays.lib.
    end.
    /* Infos bancaires */
    for first iribfour no-lock
        where iribfour.soc-cd = ifour.soc-cd
          and iribfour.four-cle = ifour.four-cle 
          and not can-find(first iadrfour no-lock
                           where iadrfour.soc-cd    = iribfour.soc-cd
                             and iadrfour.four-cle  = iribfour.four-cle
                             and iadrfour.libadr-cd = 8
                             and iadrfour.ordre-num = iribfour.ordre-num):
        if not iribfour.etr 
        then assign
            ttListeTiers.cDomiciliation = iribfour.domicil[1]
            ttListeTiers.cTitulaire     = iribfour.domicil[2]
        .
        if iribfour.iban > "" then ttListeTiers.cIBAN = string(iribfour.iban, "XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XX").
        if iribfour.bic  > "" then ttListeTiers.cBIC  = iribfour.bic.
    end.

end procedure.
