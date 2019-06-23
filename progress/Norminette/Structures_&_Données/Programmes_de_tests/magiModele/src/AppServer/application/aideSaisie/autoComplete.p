/*------------------------------------------------------------------------
File        : autocomplete.p
Purpose     :
Author(s)   : Kantena 2017/10/14
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/autocomplete.i}
{Application/include/glbsepar.i}

&SCOPED-DEFINE MAXRETURNEDROWS  50

function formatteNumeroContrat returns character private(piNumeroContrat as integer, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    case pcTypeContrat:
        when {&TYPECONTRAT-Salarie}     then return substring(string(piNumeroContrat, "9999999"), 1, 5, 'character').
        when {&TYPECONTRAT-titre2copro} then return substring(string(piNumeroContrat, "9999999999"), 1, 5, 'character').
        when {&TYPECONTRAT-bail}        then return substring(string(piNumeroContrat, "9999999999"), 1, 5, 'character').
        otherwise                            return string(piNumeroContrat, "99999").
    end case.

end function.

procedure geAutoCompletetListe:
    /*------------------------------------------------------------------------------
    Purpose: requête dynamique sur une table
    Notes  : service utilisé par beAutoCompleteGeneric.cls
             . pcNomTable = table de la requête.
             . pcPreCondition = précondition (champ_1 = valeur_1) permettant un AND sur les critères.
             . pcChampsRecherche = les champs qui doivent remplir le critère matches pcFiltre.
             . pcChampCode = champ considéré comme étant le code pour l'utilisateur.
             . pcFiltre = filtre appliqué aux champs de recherche.
             . pcChampsRetour = limité à 3 champs.
    ------------------------------------------------------------------------------*/
    define input  parameter pcNomTable        as character no-undo.
    define input  parameter pcPreCondition    as character no-undo.
    define input  parameter pcChampsRecherche as character no-undo.
    define input  parameter pcChampCode       as character no-undo.
    define input  parameter pcFiltre          as character no-undo.
    define input  parameter pcChampsRetour    as character no-undo.
    define output parameter table for ttAutoCompleteGeneric.

    define variable vhQuery  as handle    no-undo.
    define variable vhbuffer as handle    no-undo.
    define variable vcQuery  as character no-undo.
    define variable viNumSeq as integer   no-undo.
    define variable vcEntry  as character no-undo.
    define variable vi       as integer   no-undo.
    define variable vi2      as integer   no-undo.

    empty temp-table ttAutoCompleteGeneric.
    if pcFiltre = ? then pcFiltre = "".
    create buffer vhbuffer for table pcNomTable.
    create query vhQuery.
    vhQuery:set-buffers(vhbuffer).
    if num-entries(pcChampsRecherche) >= 1
    then do:
        vcQuery = substitute("FOR EACH &1 WHERE (", pcNomTable).
        do vi = 1 to num-entries(pcChampsRecherche):
            vcEntry = entry(vi, pcChampsRecherche).
            if vhbuffer:buffer-field(vcEntry):extent > 1
            then do vi2 = 1 to vhbuffer:buffer-field(vcEntry):extent:
                case vhbuffer:buffer-field(vcEntry):data-type:
                    when "integer"   then vcQuery = vcQuery + substitute("string(&1.&2[&4]) matches '*&3*'", pcNomTable, vcEntry, if pcFiltre = ? then "" else pcFiltre, vi2).
                    when "int64"     then vcQuery = vcQuery + substitute("string(&1.&2[&4]) matches '*&3*'", pcNomTable, vcEntry, if pcFiltre = ? then "" else pcFiltre, vi2).
                    when "character" then vcQuery = vcQuery + substitute("&1.&2[&4] matches '*&3*'",         pcNomTable, vcEntry, if pcFiltre = ? then "" else pcFiltre, vi2).
                end case.
                if vi2 <> vhbuffer:buffer-field(vcEntry):extent then vcQuery = vcQuery + " OR ".
            end.
            else case vhbuffer:buffer-field(vcEntry):data-type:
                when "integer"   then vcQuery = vcQuery + substitute("string(&1.&2) matches '*&3*'", pcNomTable, vcEntry, if pcFiltre = ? then "" else pcFiltre).
                when "int64"     then vcQuery = vcQuery + substitute("string(&1.&2) matches '*&3*'", pcNomTable, vcEntry, if pcFiltre = ? then "" else pcFiltre).
                when "character" then vcQuery = vcQuery + substitute("&1.&2 matches '*&3*'",         pcNomTable, vcEntry, if pcFiltre = ? then "" else pcFiltre).
            end case.
            vcQuery = vcQuery + if vi <> num-entries(pcChampsRecherche) then " OR " else ")".
        end.
    end.

    if pcPreCondition > ""
    then do:
        vcEntry = entry(1, pcPreCondition, "=").
        case vhbuffer:buffer-field(vcEntry):data-type:
            when "integer"   then vcQuery = substitute('&1 and &2 = &3',   vcQuery, vcEntry, entry(2, pcPreCondition, "=")).
            when "int64"     then vcQuery = substitute('&1 and &2 = &3',   vcQuery, vcEntry, entry(2, pcPreCondition, "=")).
            when "character" then vcQuery = substitute('&1 and &2 = "&3"', vcQuery, vcEntry, entry(2, pcPreCondition, "=")).
        end case.
    end.

    mLogger:writeLog(2, substitute("getListe: &1", vcQuery)).
    vhQuery:query-prepare(vcQuery).
    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.

        create ttAutoCompleteGeneric.
        assign
            viNumSeq                        = viNumSeq + 1
            ttAutoCompleteGeneric.iSeqId    = viNumSeq
            ttAutoCompleteGeneric.cCode     = vhbuffer:buffer-field(pcChampCode):buffer-value
            ttAutoCompleteGeneric.cLibelle1 = vhbuffer:buffer-field(entry(1, pcChampsRetour)):Buffer-value
                                            + (if num-entries(pcChampsRetour) > 1
                                               then " " + vhbuffer:buffer-field(entry(2, pcChampsRetour)):Buffer-value
                                               else "")
                                            + (if num-entries(pcChampsRetour) > 2
                                               then " " + vhbuffer:buffer-field(entry(3, pcChampsRetour)):Buffer-value
                                               else "")
            ttAutoCompleteGeneric.cLibelle2 = vhbuffer:buffer-field(entry(1, pcChampsRetour)):Buffer-value
            ttAutoCompleteGeneric.cLibelle3 = (if num-entries(pcChampsRetour) > 1
                                               then vhbuffer:buffer-field(entry(2, pcChampsRetour)):Buffer-value
                                               else "")
            ttAutoCompleteGeneric.cLibelle4 = (if num-entries(pcChampsRetour) > 2
                                               then vhbuffer:buffer-field(entry(3, pcChampsRetour)):Buffer-value
                                               else "")
        .
        if viNumSeq >= {&MAXRETURNEDROWS} then do:
            mError:createError({&information}, 211684, "{&MAXRETURNEDROWS}").
            leave boucle.
        end.
    end.
    vhQuery:query-close().
    delete object vhQuery.

    assign error-status:error = false no-error. // reset error-status
    return.                            // reset return-value

end procedure.

procedure getAutoCompleteRole:
    /*------------------------------------------------------------------------------
     Purpose: Permet d'avoir la liste des enregistrements roles filtrés par type et 
              sur une valeur donnée 
     Notes: appelé par beAutoComplete
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole as character no-undo.
    define input parameter pcFiltre   as character no-undo.
    define output parameter table for ttAutoCompleteGeneric.
    
    define variable viNumSeq as integer no-undo.
    
    for each roles no-lock
       where roles.tprol = pcTypeRole
         and roles.lbrech matches substitute('*&1*', pcFiltre):

        create ttAutoCompleteGeneric. 
        assign
            viNumSeq                        = viNumSeq + 1
            ttAutoCompleteGeneric.iSeqId    = viNumSeq
            ttAutoCompleteGeneric.cCode     = string(roles.norol)
            ttAutoCompleteGeneric.cLibelle1 = trim(entry(1, roles.lbrech, SEPAR[1]))
            ttAutoCompleteGeneric.cLibelle2 = (if num-entries(roles.lbrech, SEPAR[1]) > 1
                                               then trim(entry(2, roles.lbrech, SEPAR[1]))
                                               else "")
            ttAutoCompleteGeneric.cLibelle3 = (if num-entries(roles.lbrech, SEPAR[1]) > 2
                                               then trim(entry(3, roles.lbrech, SEPAR[1]))
                                               else "")
       .
   end.
end procedure.

procedure getAutoCompletePays:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAutoCompleteGeneric.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcFiltre as character no-undo.
    define output parameter table for ttAutoCompleteGeneric.

    define variable viNumSeq  as integer   no-undo.
    define variable vcLibelle as character no-undo.
    define buffer sys_pr for sys_pr.

    for each sys_pr no-lock
       where sys_pr.tppar = "CDPAY":
        vcLibelle = outilTraduction:getLibelle(sys_pr.nome1).
        if vcLibelle begins pcfiltre
        then do:
            create ttAutoCompleteGeneric.
            assign
                viNumSeq                        = viNumSeq + 1
                ttAutoCompleteGeneric.iSeqId    = viNumSeq
                ttAutoCompleteGeneric.cCode     = sys_pr.cdpar
                ttAutoCompleteGeneric.cLibelle1 = vcLibelle
                ttAutoCompleteGeneric.cLibelle2 = sys_pr.zone2
            .
        end.
    end.

    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value

end procedure.

procedure getAutoCompleteMandat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAutoCompleteGeneric.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcChampsRecherche as character no-undo.
    define input  parameter pcFiltre          as character no-undo.
    define input  parameter plFiltreGestion   as logical   no-undo.
    define output parameter table for ttAutoCompleteGeneric.

    define variable vhQuery       as handle    no-undo.
    define variable vhbIetab      as handle    no-undo.
    define variable vhbCtctt      as handle    no-undo.
    define variable vhbIntnt      as handle    no-undo.
    define variable vcQuery       as character no-undo.
    define variable vcTypeContrat as character no-undo.
    define variable vcCodeSociete as character no-undo.
    define variable viNumSeq      as integer   no-undo.

    empty temp-table ttAutoCompleteGeneric.
    create buffer vhbIetab for table "ietab".
    create buffer vhbCtctt for table "ctctt".
    create buffer vhbIntnt for table "intnt".
    create query vhQuery.

    /* Recherche de la reference Placement provisoire */
    assign
        vcCodeSociete = string(mToken:getSociete(""), "99999")
        vcTypeContrat = substitute('&1/&2', {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-mandat2Syndic})
    .
    if plFiltreGestion and mtoken:iGestionnaire <> 0 and mtoken:iGestionnaire <> 4
    then do:
        vhQuery:set-buffers(vhbIetab, vhbCtctt, vhbIntnt).
        vcQuery = substitute(
'for each ietab no-lock where ietab.soc-cd &1 and &2 and ietab.profil-cd modulo 10 <> 0
,first ctctt no-lock where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion} and ctctt.tpct2 = string(ietab.profil-cd = 21, &3) and ctctt.noct2 = ietab.etab-cd
,first intnt no-lock where intnt.tpcon = ctctt.tpct1 and intnt.nocon = ctctt.noct1',
                      if mtoken:cRefCopro = mtoken:cRefGerance then (' = ' + vcCodeSociete) else (' <= ' + mtoken:cRefCopro),
                      /*
                      if pcChampsRecherche > ''
                      then substitute("ietab.etab-cd = '&1'", pcFiltre)
                      else */ substitute("(ietab.etab-cd = '&1' or ietab.lbrech matches '*&1*')", pcFiltre),
                      vcTypeContrat).
    end.
    else do:
         vhQuery:set-buffers(vhbIetab).
         vcQuery = substitute('for each ietab no-lock where ietab.soc-cd &1 and &2',
                      if mtoken:cRefCopro = mtoken:cRefGerance then (' = ' + vcCodeSociete) else (' <= ' + mtoken:cRefCopro),
                      /*
                      if pcChampsRecherche > ''
                      then substitute("ietab.etab-cd = '&1'", pcFiltre)
                      else */
                      substitute("(ietab.etab-cd = '&1' or ietab.lbrech matches '*&1*')", pcFiltre)).
    end.

    vhQuery:query-prepare(vcQuery).
    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.

        create ttAutoCompleteGeneric.
        assign
            viNumSeq                        = viNumSeq + 1
            ttAutoCompleteGeneric.iSeqId    = viNumSeq
            ttAutoCompleteGeneric.cCode     = string(vhbIetab::etab-cd, "99999")     /* Numéro du mandat */
            ttAutoCompleteGeneric.cLibelle1 = substitute('&1 - &2', string(vhbIetab::etab-cd, "99999"), trim(substring(vhbIetab::lbrech, 1, 60, 'character'))) /* Libelle de recherche */
            ttAutoCompleteGeneric.cLibelle2 = string(vhbIetab::profil-cd = 21, vcTypeContrat)
        .
        if viNumSeq >= {&MAXRETURNEDROWS} then do:
            mError:createError({&information}, 211684, "{&MAXRETURNEDROWS}").
            leave boucle.
        end.
    end.
    vhQuery:query-close().
    delete object vhQuery  no-error.
    delete object vhbIetab no-error.
    delete object vhbCtctt no-error.
    delete object vhbIntnt no-error.

    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value

end procedure.

procedure getAutoCompleteSignalant:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAutoCompleteGeneric.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcChampsRecherche as character no-undo.
    define input parameter pcFiltre          as character no-undo.
    define input parameter pcFiltre2         as character no-undo.
    define output parameter table for ttAutoCompleteGeneric.

    define variable viNumSeq            as integer   no-undo.
    define variable cListeTypeRole      as character no-undo.
    define variable cListeTypeContrat   as character no-undo.
    define variable vcLibelleRole       as character no-undo.
    define variable vcAdresseImbl       as character no-undo.
    define variable vcNumeroMandatCourt as character no-undo.
    define variable vcNomTiers          as character no-undo.

    define buffer vbroles   for roles.
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    define buffer ctrat   for ctrat.
    define buffer imble   for imble.
    
    empty temp-table ttAutoCompleteGeneric.
    
    assign
        cListeTypeRole    = substitute('&1,&2,&3,&4,&5', {&TYPEROLE-coproprietaire}, {&TYPEROLE-locataire}, {&TYPEROLE-mandant}, {&TYPEROLE-syndic2copro}, {&TYPEROLE-salarie})
        cListeTypeContrat = substitute('&1,&2,&3,&4,&5', {&TYPECONTRAT-titre2copro}, {&TYPECONTRAT-bail}, {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-mandat2Syndic}, {&TYPECONTRAT-Salarie})
    .
boucle:
    for each vbroles no-lock 
       where vbroles.lbrech contains trim(pcFiltre)
         and vbroles.fg-princ = true 
         and lookup(vbroles.tprol, cListeTypeRole) > 0
      , each Intnt no-lock 
       where intnt.tpidt = vbroles.tprol 
         and intnt.noidt = vbroles.norol 
         and lookup(intnt.tpcon, cListeTypeContrat) = lookup(vbroles.tprol, cListeTypeRole)
     , first ctrat no-lock 
       where ctrat.tpcon = intnt.tpcon 
         and ctrat.nocon = intnt.nocon break by vbroles.notie:

        vcLibelleRole   = "".
        /* Immeuble lié */
        find first vbintnt no-lock
             where vbintnt.tpidt = {&TYPEBIEN-immeuble}
               and vbintnt.tpcon = ctrat.tpcon
               and vbintnt.nocon = ctrat.nocon no-error.
        find first Imble no-lock
            where imble.noimm = vbintnt.noidt no-error.
        assign
            vcLibelleRole       = outilTraduction:getLibelleProg("O_ROL", vbroles.tprol)
            vcAdresseImbl       = if available imble then outilFormatage:formatageAdresse({&TYPEBIEN-immeuble}, imble.noImm) else ""
            vcNumeroMandatCourt = formatteNumeroContrat(ctrat.nocon, ctrat.tpcon)
        .
        if pcChampsRecherche = "Contrat" and vcNumeroMandatCourt <> pcFiltre2 then next boucle.
        create ttAutoCompleteGeneric.
        assign
            viNumSeq                         = viNumSeq + 1
            ttAutoCompleteGeneric.iSeqId     = viNumSeq
            vcNomTiers                       = trim(outilFormatage:getNomTiers(vbRoles.tprol, vbRoles.norol))
            ttAutoCompleteGeneric.cCode      = string(vbroles.notie) //substitute('&1,&2', string(hbRoles::notie), cNumeroMandatCourt)  /* Numéro du tiers   */
            ttAutoCompleteGeneric.cLibelle1  = substitute('&1 - &2 - &3', string(vbroles.notie), vcNomTiers, vcNumeroMandatCourt)  /* Libelle de recherche */
            ttAutoCompleteGeneric.cLibelle2  = vcNomTiers                                                    /* Nom signalant           */
            ttAutoCompleteGeneric.cLibelle3  = outilFormatage:formatageAdresse(vbRoles.tprol, vbRoles.norol) /* Adresse signalant       */
            ttAutoCompleteGeneric.cLibelle4  = vcNumeroMandatCourt                                           /* Numéro de contrat court */
            ttAutoCompleteGeneric.cLibelle5  = trim(ctrat.lbnom)                                             /* Libelle du contrat      */
            ttAutoCompleteGeneric.cLibelle6  = string(Imble.noImm) when available imble                      /* Numéro de l'immeuble    */
            ttAutoCompleteGeneric.cLibelle7  = trim(imble.lbnom)   when available imble                      /* Libelle de l'immeuble   */
            ttAutoCompleteGeneric.cLibelle8  = vcLibelleRole             /* Libelle du role */
            ttAutoCompleteGeneric.cLibelle9  = string(vbroles.tprol)       /* Type du role */
            ttAutoCompleteGeneric.cLibelle10 = string(ctrat.tpcon)       /* Type de contrat */
            ttAutoCompleteGeneric.cLibelle11 = vcAdresseImbl
            ttAutoCompleteGeneric.cLibelle12 = string(vbroles.norol)
            ttAutoCompleteGeneric.cLibelle13 = string(ctrat.nocon)   /* Numéro de contrat complet */
        .
        if viNumSeq >= {&MAXRETURNEDROWS} then do:
            mError:createError({&information}, 211684, "{&MAXRETURNEDROWS}").
            leave boucle.
        end.
    end.
    
    assign error-status:error = false no-error. // reset error-status
    return.                                     // reset return-value

end procedure.

procedure getAutoCompleteMandatImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: Inspiré de getMandat
    Notes  : service utilisé par beAutoCompleteGeneric.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcChampsRecherche as character no-undo.
    define input  parameter pcFiltre          as character no-undo.
    define input  parameter pcFiltre2         as character no-undo. // reference société
    define input  parameter pcFiltre3         as character no-undo. // numéro immeuble
    define output parameter table for ttAutoCompleteGeneric.

    define variable vhQuery          as handle    no-undo.
    define variable vhbIetab         as handle    no-undo.
    define variable vhbIntnt         as handle    no-undo.
    define variable vcQuery          as character no-undo.
    define variable viNumSeq         as integer   no-undo.
    define variable vcCodeSociete    as character no-undo.
    define variable vcTypeContrat    as character no-undo.
    define variable viNumeroImmeuble as integer   no-undo.
    define buffer ctctt  for ctctt.

    empty temp-table ttAutoCompleteGeneric.
    create buffer vhbIetab for table "ietab".
    create buffer vhbIntnt for table "intnt".
    create query vhQuery.
    assign
        vcCodeSociete    = pcFiltre2
        viNumeroImmeuble = integer(pcFiltre3)
        vcTypeContrat    = substitute('&1/&2', {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-mandat2Syndic})
    .

    if viNumeroImmeuble = 0 then do : /* Tous les mandats */
        vhQuery:set-buffers(vhbIetab).
        vcQuery = substitute(
                      'for each ietab no-lock where ietab.soc-cd &1 and (ietab.profil-cd = 21 or ietab.profil-cd = 91) and &2',
                      ' = ' + vcCodeSociete,
                      if pcChampsRecherche > ''
                      then substitute("ietab.etab-cd = '&1'", pcFiltre)
                      else substitute("(string(ietab.etab-cd) matches '*&1*' or ietab.lbrech matches '*&1*')", pcFiltre)).
    end.
    else do : /* Immeuble renseigné */
        vhQuery:set-buffers(vhbIntnt, vhbIetab).
        vcQuery = substitute(
                      'for each intnt no-lock where intnt.tpidt = {&TYPEBIEN-immeuble} and intnt.noidt = &3 and (intnt.tpcon = {&TYPECONTRAT-mandat2Syndic} or intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}), first ietab no-lock where ietab.soc-cd &1 and ietab.etab-cd = intnt.nocon and &2',
                      ' = ' + vcCodeSociete,
                      if pcChampsRecherche > ''
                      then substitute("ietab.etab-cd = '&1'", pcFiltre)
                      else substitute("(string(ietab.etab-cd) matches '*&1*' or ietab.lbrech matches '*&1*')", pcFiltre),
                      string(viNumeroImmeuble)).
    end.

    vhQuery:query-prepare(vcQuery).
    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.

        find first ctctt no-lock
            where ctctt.tpct2 = string(vhbIetab::profil-cd = 21, vcTypeContrat)
              and ctctt.noct2 = vhbIetab::etab-cd no-error.
        create ttAutoCompleteGeneric.
        assign
            viNumSeq                        = viNumSeq + 1
            ttAutoCompleteGeneric.iSeqId    = viNumSeq
            ttAutoCompleteGeneric.cCode     = string(vhbIetab::etab-cd, "99999")     /* Numéro du mandat */
            ttAutoCompleteGeneric.cLibelle1 = substitute('&1 - &2', string(vhbIetab::etab-cd, "99999"), trim(substring(vhbIetab::lbrech, 1, 60, 'character'))) /* Libelle de recherche */
            ttAutoCompleteGeneric.cLibelle2 = string(ctctt.tpct2) when available ctctt
        .
        if viNumSeq >= {&MAXRETURNEDROWS} then do:
            mError:createError({&information}, 211684, "{&MAXRETURNEDROWS}").
            leave boucle.
        end.
    end.
    vhQuery:query-close().
    delete object vhQuery  no-error.
    delete object vhbIetab no-error.
    delete object vhbIntnt no-error.

    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value

end procedure.

procedure getAutoCompleteFournisseur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAutoCompleteGeneric.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcFiltre as character no-undo.
    define input  parameter pcTypeMandat as character no-undo.
    define output parameter table for ttAutoCompleteGeneric.

    define variable viNumSeq           as integer   no-undo.
    define variable viNumeroRef        as integer   no-undo.
    define variable vccoll-cle-Fou     as character no-undo.
    define variable vlBlocageReference as logical   no-undo.
    define buffer ccptcol for ccptcol.

    empty temp-table ttAutoCompleteGeneric.

    /* Gestion du code société */
    viNumeroRef = mtoken:getSociete(pcTypeMandat).

    /* Gestion du référencement */
    if  can-find(first iparm no-lock where iparm.tppar = "REFERF" and iparm.cdpar = "01") /* Gestion referencement */
    and can-find(first iparm no-lock where iparm.tppar = "REFERB" and iparm.cdpar = "01") /* avec blocage */
    then vlBlocageReference = true.

    /* Recherche du regroupement fournisseur */
    find first ccptcol no-lock
         where ccptcol.soc-cd = viNumeroRef
           and ccptcol.tprole = 12 no-error.
    if available ccptcol then vccoll-cle-Fou = ccptcol.coll-cle.

boucle:
    for each ifour no-lock 
       where ifour.soc-cd   = viNumeroRef 
         and ifour.coll-cle = vccoll-cle-Fou 
         and ifour.cpt-cd   > '00000' 
         and ifour.cpt-cd   < '99999'
         and ifour.fg-actif
         and (if vlBlocageReference then ifour.refer-cd <> '' else true)
         and (ifour.four-cle matches '*' + pcFiltre
               or ifour.nom matches '*' + pcFiltre + '*'):
        create ttAutoCompleteGeneric.
        assign
            viNumSeq                        = viNumSeq + 1
            ttAutoCompleteGeneric.iSeqId    = viNumSeq
            ttAutoCompleteGeneric.cCode     = ifour.cpt-cd
            ttAutoCompleteGeneric.cLibelle1 = substitute('&1 - &2', ifour.cpt-cd, trim(ifour.nom)) /* Libelle de recherche */
            ttAutoCompleteGeneric.cLibelle2 = string(viNumeroRef, "99999")
            ttAutoCompleteGeneric.cLibelle3 = trim(ifour.nom)       /* nom fournisseur */
        .
        if viNumSeq >= {&MAXRETURNEDROWS} then do:
            mError:createError({&information}, 211684, "{&MAXRETURNEDROWS}").
            leave boucle.
        end.
    end.
     
    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value

end procedure.


procedure getAutoCompleteProximite:
    /*------------------------------------------------------------------------------
    Purpose: recherche libelle proximite (commercialisation)
    Notes: service utilisé par beAutoCompleteGeneric.cls
           todo: attention, whole index sur gl_proximite
    ------------------------------------------------------------------------------*/
    define input parameter pcFiltre  as character no-undo.
    define input parameter pcFiltre2 as character no-undo.
    define output parameter table for ttAutoCompleteGeneric.

    define variable viNumSeq as integer no-undo.
    define query vqProximite for gl_proximite.

    define buffer gl_proximite for gl_proximite.
    define buffer gl_libelle   for gl_libelle.

    empty temp-table ttAutoCompleteGeneric.
    {&_proparse_ prolint-nowarn(wholeindex)}
    open query vqProximite for each gl_proximite no-lock
        where (if pcFiltre2 > "" then gl_proximite.tpproximite = integer(pcFiltre2) else true).

boucle:
    repeat:
        get next vqProximite.
        if not available gl_proximite then leave boucle.

        for first gl_libelle no-lock
            where gl_libelle.nolibelle = gl_proximite.nomes
              and gl_libelle.libellelibre begins pcFiltre:
            create ttAutoCompleteGeneric.
            assign
                viNumSeq                        = viNumSeq + 1
                ttAutoCompleteGeneric.iSeqId    = viNumSeq
                ttAutoCompleteGeneric.cCode     = string(gl_proximite.noproximite)
                ttAutoCompleteGeneric.cLibelle1 = gl_libelle.libellelibre
                ttAutoCompleteGeneric.cLibelle2 = string(gl_proximite.nomes)
            .
        end.
    end.
    error-status:error = false no-error. // reset error-status
    return.                              // reset return-value

end procedure.