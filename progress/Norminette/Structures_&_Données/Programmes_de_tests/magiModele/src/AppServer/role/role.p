/*------------------------------------------------------------------------
File        : role.p
Description :
Created     : Wed May 10 14:59:54 CEST 2017
Notes       :
derniere revue: 2018/04/16 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2contrat.i}

using parametre.pclie.parametrageTriRole.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{role/include/typeRole.i}
{role/include/role.i}
{role/include/role.i &nomTable=ttRoleTri}
{role/include/roleContrat.i}
{role/include/roleVersement.i}
{mandat/include/coloc.i &nomTable=ttColoc}
{application/include/glbsepar.i}

&SCOPED-DEFINE MAXRETURNEDROWS  200

function f_ctrass returns character private (piReference as integer, pcRole as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcListeContrat as character no-undo.

    case pcRole:
        when {&TYPEROLE-compagnie}           then vcListeContrat = {&TYPECONTRAT-assuranceGerance}.
        when {&TYPEROLE-vendeur}             then vcListeContrat = {&TYPECONTRAT-mutation}.
        when {&TYPEROLE-acheteur}            then vcListeContrat = {&TYPECONTRAT-mutation}.
        when {&TYPEROLE-coproprietaire}       then vcListeContrat = {&TYPECONTRAT-titre2copro}.
        when {&TYPEROLE-locataire}           then vcListeContrat = {&TYPECONTRAT-bail}.
        when {&TYPEROLE-candidatLocataire}   then vcListeContrat = {&TYPECONTRAT-preBail}.
        when {&TYPEROLE-colocataire}         then vcListeContrat = {&TYPECONTRAT-bail}.
        when {&TYPEROLE-coIndivisaire}       then vcListeContrat = substitute("&1,&2", {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-titre2copro}).
        when {&TYPEROLE-garant}              then vcListeContrat = {&TYPECONTRAT-bail}.
        when {&TYPEROLE-mandant}             then vcListeContrat = if piReference = 10 then {&TYPECONTRAT-bail} else {&TYPECONTRAT-mandat2Gerance}.
        when {&TYPEROLE-syndicat2copro}      then vcListeContrat = {&TYPECONTRAT-mandat2Syndic}.
        when {&TYPEROLE-salarie}             then vcListeContrat = {&TYPECONTRAT-Salarie}.
        when {&TYPEROLE-salariePegase}       then vcListeContrat = {&TYPECONTRAT-SalariePegase}.
        when {&TYPEROLE-societeActionnaires} then vcListeContrat = {&TYPECONTRAT-societe}.
        otherwise vcListeContrat = {&TYPECONTRAT-blocNote}.
    end case.
    return vcListeContrat.

end function.

function f_LstCabinet returns character ():
    /*------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par versement.p, rechercheGed.p, ...
    ------------------------------------------------------------------------*/
    define variable vcLstCabinet as character no-undo.
    define buffer vbRoles for roles.

    for first vbRoles no-lock
        where vbRoles.norol = 1
          and vbRoles.tprol = {&TYPEROLE-mandataire}            /* cabinet  de Gérance */
          and lookup(string(vbRoles.notie), vcLstCabinet) = 0:
        vcLstCabinet = vcLstCabinet + "," + string(vbRoles.notie).
    end.
    for first vbRoles no-lock
        where vbRoles.norol = 1
          and vbRoles.tprol = {&TYPEROLE-syndic2copro}          /* cabinet de Copro */
          and lookup(string(vbRoles.notie), vcLstCabinet) = 0:
        vcLstCabinet = vcLstCabinet + "," + string(vbRoles.notie).
    end.
    for first vbRoles no-lock
        where vbRoles.norol = 90000
          and vbRoles.tprol = {&TYPEROLE-cabinet}               /* cabinet */
          and lookup(string(vbRoles.notie), vcLstCabinet) = 0:
        vcLstCabinet = vcLstCabinet + "," + string(vbRoles.notie).
    end.
    return trim(vcLstCabinet, ',').

end function.

function f_RoleCabinet returns logical private(pcTypeRole as character, piNoRole as int64):
    /*------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------*/
    return (piNoRole = 1 and lookup(pcTypeRole, substitute("&1,&2,&3", {&TYPEROLE-mandataire}, {&TYPEROLE-syndic2copro}, {&TYPEROLE-cabinet})) > 0)
        or (piNoRole = 90000 and pcTypeRole = {&TYPEROLE-cabinet}).

end function.

procedure getTypeRoleParReference:
    /*------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------*/
    define input  parameter piReference as integer no-undo.
    define output parameter table for ttTypeRole.

    define variable vcLibelleFournisseur as character no-undo.
    define variable vcListeTypeCopro     as character no-undo.
    define variable vcListeTypeGerance   as character no-undo.
    define variable vlGerance            as logical   no-undo.
    define variable vlCopro              as logical   no-undo.
    define variable vhProcMandat         as handle    no-undo.

    define buffer sys_pg  for sys_pg.
    define buffer aparm   for aparm.
    define buffer ccptcol for ccptcol.

    empty temp-table ttTypeRole.
    run mandat/mandat.p persistent set vhProcMandat.
    run getTokenInstance in vhProcMandat(mToken:JSessionId).

    assign               // substitute est limité à 9 valeurs !!
        vlGerance          = dynamic-function('f_existe_mandat' in vhProcMandat, piReference, 21)
        vlCopro            = dynamic-function('f_existe_mandat' in vhProcMandat, piReference, 91)
        vcListeTypeGerance = substitute('&1,&2'
                               , substitute('&1,&2,&3,&4,&5,&6', {&TYPEROLE-beneficiaire}, {&TYPEROLE-garant}, {&TYPEROLE-nuProprietaire}, {&TYPEROLE-locataire}, {&TYPEROLE-mandant}, {&TYPEROLE-usufruitier})
                               , substitute('&1,&2,&3,&4,&5,&6', {&TYPEROLE-colocataire}, {&TYPEROLE-bailleur}, {&TYPEROLE-candidatLocataire}, {&TYPEROLE-prospect}, {&TYPEROLE-societeActionnaires}, {&TYPEROLE-mandataire}))
        vcListeTypeCopro   = substitute('&1,&2'
                               , substitute('&1,&2,&3,&4,&5,&6,&7,&8', {&TYPEROLE-coproprietaire}, {&TYPEROLE-presidentConseilSyndical}, {&TYPEROLE-membreConseilSyndical}, {&TYPEROLE-vendeur}, {&TYPEROLE-acheteur}, {&TYPEROLE-adjointConseilSyndical}, {&TYPEROLE-bienfaiteurConseilSyndical})
                               , substitute('&1,&2,&3,&4,&5,&6,&7,&8', {&TYPEROLE-respTravauxConseilSyndical}, {&TYPEROLE-benevole}, {&TYPEROLE-responsableSecurite}, {&TYPEROLE-responsableComptabilite}, {&TYPEROLE-coPresident}, {&TYPEROLE-coUsufruitier}, {&TYPEROLE-coNuProprietaire}, {&TYPEROLE-syndic2copro}))
    .
    run destroy in vhProcMandat.
    /* roles copro/gerance */
    for each sys_pg no-lock
        where sys_pg.tppar = 'O_rol':
        create ttTypeRole.
        assign
            ttTypeRole.ctypeRole        = sys_pg.cdpar
            ttTypeRole.cLibelleTypeRole = outilTraduction:getLibelle(sys_pg.nome2)
            ttTypeRole.lAutorise        = if (sys_pg.cdpar = {&TYPEROLE-acheteur} or sys_pg.cdpar = {&TYPEROLE-vendeur})
                                          or (not vlGerance and lookup(sys_pg.cdpar, vcListeTypeGerance) > 0)
                                          or (not vlCopro   and lookup(sys_pg.cdpar, vcListeTypeCopro) > 0)
                                          then false else true
        .
    end.
    /* roles fournisseurs */
    vcLibelleFournisseur = outilTraduction:getLibelle(701060).
    for each aparm no-lock
        where aparm.tppar = "GEDFOU":
        create ttTypeRole.
        assign
            ttTypeRole.ctypeRole        = aparm.lib
            ttTypeRole.cLibelleTypeRole = substitute('&1 &2', vcLibelleFournisseur, aparm.cdpar)
            ttTypeRole.lAutorise        = (integer(piReference) = 0 or aparm.cdpar = string(piReference,"99999"))
        .
    end.
    /* roles organismes sociaux */
    for each ccptcol no-lock
        where ccptcol.soc-cd = piReference
          and ccptcol.tprol >= 4000
          and ccptcol.tprol <= 4999:
        if not can-find(first ttTypeRole
                        where ttTypeRole.ctypeRole = string(ccptcol.tprol, "99999"))
        then do:
            create ttTypeRole.
            assign
                ttTypeRole.ctypeRole        = string(ccptcol.tprol, "99999")
                ttTypeRole.cLibelleTypeRole = caps(substring(string(ccptcol.lib), 1, 1, 'character')) + lc(substring(string(ccptcol.lib), 2))
                ttTypeRole.cCodeCollectif   = ccptcol.coll-cle
            .
        end.
    end.

end procedure.

procedure getListeRoleContrat :
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beRole.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piReference      as integer   no-undo.
    define input  parameter pcRechercheTiers as character no-undo.
    define input  parameter table for ttTypeRole.
    define input  parameter table for ttRoleContrat.
    define output parameter table for ttRoleVersement.

    define variable vcListeTypeRole   as character no-undo.
    define variable vcListeRolesCSynd as character no-undo.
    define variable viNumSeq          as integer   no-undo.
    define variable vcfiltre          as character no-undo.
    define variable vhQuery           as handle    no-undo.
    define variable vhbroles          as handle    no-undo.
    define variable vcQuery           as character no-undo.
    define variable vlttRoleContrat   as logical   no-undo.
    define variable vhProcAdresse     as handle    no-undo.

    define buffer vbRoles for roles.
    define buffer sys_pg for sys_pg.

    if not can-find(first isoc no-lock where isoc.soc-cd = piReference and isoc.specif-cle = 1000)
    then do:
        mError:createError({&erreur}, 1000198, string(piReference)). /* La référence  &1 n'existe pas. */
        return.
    end.

    run adresse/adresse.p persistent set vhProcAdresse.
    run getTokenInstance in vhProcAdresse(mToken:JSessionId).

    for each ttTypeRole where ttTypeRole.lAutorise:
        vcListeTypeRole = vcListeTypeRole + ttTypeRole.cTypeRole + ",".
    end.
    vcListeTypeRole = trim(vcListeTypeRole, ",").

    for each sys_pg no-lock
       where sys_pg.tppar = "R_TFR"
         and sys_pg.zone1 = {&TYPETACHE-conseilSyndical}
         and sys_pg.zone2 = "00001":
        vcListeRolesCSynd = vcListeRolesCSynd + "," + sys_pg.zone3.
    end.
    assign
        vcListeRolesCSynd = if vcListeRolesCSynd > ""
                            then trim(vcListeRolesCSynd, ",")
                            else substitute("&1,&2,&3,&4,&5,&6,&7,&8,&9",
                                            {&TYPEROLE-presidentConseilSyndical}, {&TYPEROLE-membreConseilSyndical}, {&TYPEROLE-adjointConseilSyndical}, {&TYPEROLE-bienfaiteurConseilSyndical}, {&TYPEROLE-respTravauxConseilSyndical}, {&TYPEROLE-benevole}, {&TYPEROLE-responsableSecurite}, {&TYPEROLE-responsableComptabilite}, {&TYPEROLE-coPresident})
        vcfiltre          = replace(pcRechercheTiers, "-", " ")           /* Nettoyage */
        vcfiltre          = replace(vcfiltre, ",", " ")
    .
    /* Supprimer les doubles espaces */
boucle:
    repeat:
        if vcfiltre matches "*  *"
        then vcfiltre = replace(vcfiltre, "  ", " ").
        else leave boucle.
    end.
    assign
        vcfiltre = replace(vcfiltre, "'", "''")
        vcfiltre = trim(vcfiltre)
        vcfiltre = replace(vcfiltre, " ", "*&") + "* "    /* Ajout *& à la fin de chaque mot */
        vcfiltre = left-trim(vcfiltre, "*")
    .
    if can-find(first ttRoleContrat)
    then do:
        assign
            vlttRoleContrat = true
            vcQuery         = substitute("for each TABLE no-lock where &1 lookup(TABLE.cCodeTypeRole,'&3') > 0 and (TABLE.soc-cd = 0 or TABLE.soc-cd = &2)"
                               , if trim(vcfiltre) > "" then substitute("TABLE.lbrech contains '&1' and ", vcfiltre) else ""
                               , string(piReference)
                               , vcListeTypeRole)
            vcQuery         = replace(vcQuery, 'TABLE', 'ttRoleContrat')
        .
        create buffer vhbroles for table "ttRoleContrat".
    end.
    else do:
        assign
            vlttRoleContrat = false
            vcQuery         = substitute("for each TABLE no-lock where &1 lookup(TABLE.tprol,'&3') > 0 and (TABLE.soc-cd = 0 or TABLE.soc-cd = &2)"
                               , if trim(vcfiltre) > "" then substitute("TABLE.lbrech contains '&1' and ", vcfiltre) else ""
                               , string(piReference)
                               , vcListeTypeRole)
            vcQuery         = replace(vcQuery, 'TABLE', 'roles')
        .
        create buffer vhbroles for table "roles".
    end.

    create query vhQuery.
    vhQuery:set-buffers(vhbroles).
    vhQuery:query-prepare(vcQuery).
    vhQuery:query-open().

boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.
        for first vbRoles no-lock
            where vbRoles.tprol = (if vlttRoleContrat then vhbroles::cCodeTypeRole else vhbroles::tprol)
              and vbRoles.norol = (if vlttRoleContrat then vhbroles::iNumeroRole   else vhbroles::norol) :
            run getRoleTiers(piReference, vbRoles.tprol, vbRoles.norol, vcListeRolesCSynd, vhProcAdresse).
            if viNumSeq >= {&MAXRETURNEDROWS} then do:               /* > {&MAXRETURNEDROWS} tiers trouvés */
                mError:createError({&information}, 211684, "{&MAXRETURNEDROWS}").
                leave boucle.
            end.
        end.
    end.
    vhQuery:query-close() no-error.
    delete object vhQuery no-error.

    if valid-handle(vhProcAdresse) then run destroy in vhProcAdresse.

end procedure.


procedure getRoleMandatImmeuble:
/*------------------------------------------------------------------------------
Purpose: liste des roles d'un mandat / immeuble
Notes: Utilisé par le service BeVersement.cls
------------------------------------------------------------------------------*/
    define input  parameter piReference      as integer no-undo.
    define input  parameter piNumeroMandat   as integer no-undo.
    define input  parameter piNumeroImmeuble as integer no-undo.
    define input  parameter table for ttTypeRole.
    define output parameter table for ttRoleContrat.

    define variable vcListeMandat   as character no-undo.
    define variable viNumeroContrat as integer   no-undo.
    define variable viTmp           as integer   no-undo.
    define variable viCpuseinc      as integer   no-undo.
    define variable vhUniteLocation as handle    no-undo.

    define buffer intnt  for intnt.
    define buffer vbRoles  for roles.
    define buffer ctrat  for ctrat.
    define buffer taint  for taint.
    define buffer aparm  for aparm.
    define buffer csscpt for csscpt.

    run mandat/uniteLocation.p persistent set vhUniteLocation.
    run getTokenInstance in vhUniteLocation (mToken:JSessionId).

//    empty temp-table ttColoc.
    if piNumeroMandat > 0
    then vcListeMandat = string(piNumeroMandat).
    else if piNumeroImmeuble > 0 then do:            /* Liste des mandats de l'immeuble */
        for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.noidt = piNumeroImmeuble:
            vcListeMandat = vcListeMandat + ',' + string(intnt.nocon).
        end.
        for each intnt no-lock
            where INTnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and intnt.noidt = piNumeroImmeuble:
            vcListeMandat = vcListeMandat + ',' + string(intnt.nocon).
        end.
        vcListeMandat = trim(vcListeMandat, ",").
    end.
    if vcListeMandat > ""
    then do:
        do viTmp = 1 to num-entries(vcListeMandat):
            viNumeroContrat = integer(entry(viTmp, vcListeMandat)).
            for first ctrat no-lock
                where ctrat.nocon = viNumeroContrat
                  and (ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance} or ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}):
                for each intnt no-lock
                    where intnt.tpcon = ctrat.tpcon
                      and intnt.nocon = viNumeroContrat
                      and intnt.tpidt > ""
                      and intnt.noidt > 0
                  , first vbRoles no-lock
                    where vbRoles.tprol = intnt.tpidt
                      and vbRoles.norol = intnt.noidt
                      and not can-find(first ttRoleContrat
                                       where ttRoleContrat.cCodeTypeRole = vbRoles.tprol
                                         and ttRoleContrat.iNumeroRole   = vbRoles.norol):
                    create ttRoleContrat.
                    assign
                        ttRoleContrat.cCodeTypeRole = vbRoles.tprol
                        ttRoleContrat.iNumeroRole   = vbRoles.norol
                        ttRoleContrat.lbrech        = vbRoles.lbrech
//                      ttRoleContrat.fg-princ      = vbRoles.fg-princ
//                      ttRoleContrat.notie         = vbRoles.notie
                        ttRoleContrat.soc-cd        = vbRoles.soc-cd
                    .
                end.

                if ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                then for each taint no-lock
                    where taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and taint.nocon = viNumeroContrat
                      and taint.tptac = {&TYPETACHE-conseilSyndical}:
                    viCpuseinc = integer(taint.tpidt) no-error.
                    if (error-status:error or viCpuseinc <= 1000)
                    and taint.tpidt > "" and taint.noidt > 0
                    then for first vbRoles no-lock
                        where vbRoles.tprol = taint.tpidt
                          and vbRoles.norol = taint.noidt
                          and not can-find(first ttRoleContrat
                                           where ttRoleContrat.cCodeTypeRole = vbRoles.tprol
                                             and ttRoleContrat.iNumeroRole   = vbRoles.norol):
                        create ttRoleContrat.
                        assign
                            ttRoleContrat.cCodeTypeRole = vbRoles.tprol
                            ttRoleContrat.iNumeroRole   = vbRoles.norol
                            ttRoleContrat.lbrech        = vbRoles.lbrech
//                          ttRoleContrat.fg-princ      = vbRoles.fg-princ
//                          ttRoleContrat.notie         = vbRoles.notie
                            ttRoleContrat.soc-cd        = vbRoles.soc-cd
                        .
                    end.
                end.
            end.

            {&_proparse_ prolint-nowarn(use-index)}
            for each ctrat no-lock
                where ctrat.nocon >= integer(string(viNumeroContrat, "99999") + '00000')
                  and ctrat.nocon <= integer(string(viNumeroContrat, "99999") + '99999')
                  and ctrat.tprol > ""
                  and ctrat.norol > 0 use-index ix_ctrat10
              , first vbRoles no-lock
                where vbRoles.tprol = ctrat.tprol
                  and vbRoles.norol = ctrat.norol:
                if not can-find(first ttRoleContrat where ttRoleContrat.cCodeTypeRole = vbRoles.tprol and ttRoleContrat.iNumeroRole = vbRoles.norol)
                then do:
                    create ttRoleContrat.
                    assign
                        ttRoleContrat.cCodeTypeRole = vbRoles.tprol
                        ttRoleContrat.iNumeroRole   = vbRoles.norol
                        ttRoleContrat.lbrech        = vbRoles.lbrech
//                      ttRoleContrat.fg-princ      = vbRoles.fg-princ
//                      ttRoleContrat.notie         = vbRoles.notie
                        ttRoleContrat.soc-cd        = vbRoles.soc-cd
                    .
                end.
                if ctrat.tpcon = {&TYPECONTRAT-bail}
                then run getListeColoc in vhUniteLocation(ctrat.tpcon, ctrat.nocon, ctrat.tprol, ctrat.norol, table ttTypeRole by-reference, output table ttColoc append).
            end.
        end.   /* do viTmp... vcListeMandat */

        /* fournisseurs */
        do viTmp = 1 to num-entries(vcListeMandat):
            viNumeroContrat = integer(entry(viTmp, vcListeMandat)).
            for first aparm no-lock
                where aparm.tppar = "GEDFOU"
                  and aparm.cdpar = string(piReference,"99999")
              , each csscpt no-lock
                where csscpt.soc-cd     = piReference
                  and csscpt.etab-cd    = viNumeroContrat
                  and csscpt.coll-cle   = "F"
                  and csscpt.sscoll-cle = "F"
              , first vbRoles no-lock
                where vbRoles.tprol = aparm.lib
                  and vbRoles.norol = integer(csscpt.cpt-cd)
                  and not can-find(first ttRoleContrat
                                   where ttRoleContrat.cCodeTypeRole = vbRoles.tprol
                                     and ttRoleContrat.iNumeroRole   = vbRoles.norol):
                create ttRoleContrat.
                assign
                    ttRoleContrat.cCodeTypeRole = vbRoles.tprol
                    ttRoleContrat.iNumeroRole   = vbRoles.norol
                    ttRoleContrat.lbrech        = vbRoles.lbrech
//                  ttRoleContrat.notie         = vbRoles.notie
//                  ttRoleContrat.fg-princ      = vbRoles.fg-princ
                    ttRoleContrat.soc-cd        = vbRoles.soc-cd
                .
            end.
        end. /* do viTmp... vcListeMandat */
    end. /* vcListeMandat > "" */

    for each ttColoc
      , first vbRoles no-lock
        where vbRoles.tprol = ttColoc.cTypeRole
          and vbRoles.norol = int64(ttcoloc.cNumeroRole):
        if not can-find(first ttRoleContrat where ttRoleContrat.cCodeTypeRole = ttColoc.cTypeRole
                                             and ttRoleContrat.iNumeroRole = int64(ttcoloc.cNumeroRole))
        then do:
            create ttRoleContrat.
            assign
                ttRoleContrat.cCodeTypeRole = ttColoc.cTypeRole
                ttRoleContrat.iNumeroRole   = int64(ttcoloc.cNumeroRole)
                ttRoleContrat.lbrech        = vbRoles.lbrech
//              ttRoleContrat.fg-princ      = vbRoles.fg-princ
//              ttRoleContrat.notie         = vbRoles.notie
                ttRoleContrat.soc-cd        = vbRoles.soc-cd
            .
        end.
    end.
    run destroy in vhUniteLocation.
end procedure.

procedure getRoleTiers private:
    /*------------------------------------------------------------------------------
    Purpose: liste des roles d'un tiers
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pireference       as integer   no-undo.
    define input parameter pcTypeRole        as character no-undo.
    define input parameter piNumeroRole      as int64     no-undo.
    define input parameter pcListeRolesCSynd as character no-undo.
    define input parameter phProcAdresse     as handle    no-undo.

    define variable viTypeRole         as integer no-undo.
    define variable vlPlageOS          as logical no-undo.
    define variable vlPlageFournisseur as logical no-undo.
    define buffer vbRoles for roles.

    for first vbRoles no-lock
        where vbRoles.tprol = pcTypeRole
          and vbRoles.norol = piNumeroRole:
        assign
            viTypeRole         = integer(vbRoles.tprol)
            vlPlageOS          = viTypeRole >= 4000 and viTypeRole <= 4999
            vlPlageFournisseur = viTypeRole >= 9980 and viTypeRole <= 9999
        .
        /*** charge browse ***/
        if not vlPlageOS and not vlPlageFournisseur
        then run getContratGestion(piReference, pcListeRolesCSynd, phProcAdresse, buffer vbRoles). /* = roles de gestion */
        else do: /* fournisseur de compta */
            create ttRoleVersement.
            assign
                ttRoleVersement.rRowid         = rowid(vbRoles)
                ttRoleVersement.iNumeroTiers   = if vlPlageFournisseur and lookup(string(vbRoles.notie), f_LstCabinet()) > 0 then vbRoles.notie else 0
                ttRoleVersement.cTypeRole      = vbRoles.tprol
                ttRoleVersement.cNumeroRole    = string(vbRoles.norol, "99999")
                ttRoleVersement.cTypeContrat   = ""
                ttRoleVersement.iNumeroContrat = 0
                ttRoleVersement.iNumeroMandat  = 0
                ttRoleVersement.cAdresseTiers  = if vlPlageOS
                                                 then outilFormatage:getAdresseFour(vbroles.norol, viTypeRole)
                                                 else outilFormatage:getAdresseFour("F", vbroles.norol, vbRoles.soc-cd)
                ttRoleVersement.cLibelleTiers  = if vlPlageOS
                                                 then outilFormatage:getNomFour(vbroles.norol, viTypeRole)
                                                 else outilFormatage:getNomFour("F", vbroles.norol, vbRoles.soc-cd)
                ttRoleVersement.lCabinet       = f_RoleCabinet(vbRoles.tprol, vbRoles.norol)
            .
            run getInfoContrat(phProcAdresse, buffer ttRoleVersement, buffer vbRoles).
        end.
    end.

end procedure.

procedure getContratGestion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piReference       as integer   no-undo.
    define input parameter pcListeRolesCSynd as character no-undo.
    define input parameter phProcAdresse     as handle    no-undo.
    define parameter buffer pbRoles for roles.

    define variable vcListeContratAssocie as character no-undo.
    define variable vcTypeContratAssocie  as character no-undo.
    define variable viBoucle              as integer   no-undo.

    define buffer taint   for taint.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.

    if lookup(pbRoles.tprol, pcListeRolesCSynd) > 0
    then for each taint no-lock
        where taint.tpidt = pbRoles.tprol
          and taint.noidt = pbRoles.NoRol
          and taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and taint.tptac = {&TYPETACHE-conseilSyndical}
          and (Taint.dtfin = ? or (Taint.dtfin <> ? and Taint.dtfin > today))
      , first ctrat no-lock
        where ctrat.tpcon = taint.tpcon
          and ctrat.nocon = taint.nocon
          and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}
          and not can-find(first ttRoleVersement
                           where ttRoleVersement.rRowid         = rowid(pbRoles)
                             and ttRoleVersement.iNumeroTiers   = pbRoles.notie
                             and ttRoleVersement.cTypeContrat   = ctrat.tpcon
                             and ttRoleVersement.iNumeroContrat = ctrat.nocon):
        create ttRoleVersement.
        assign
            ttRoleVersement.iNumeroTiers   = pbRoles.notie
            ttRoleVersement.cTypeRole      = pbRoles.tprol
            ttRoleVersement.cNumeroRole    = string(pbRoles.norol, "99999")
            ttRoleVersement.rRowid         = rowid(pbRoles)
            ttRoleVersement.cTypeContrat   = ctrat.tpcon
            ttRoleVersement.iNumeroContrat = ctrat.nocon
            ttRoleVersement.cAdresseTiers  = outilFormatage:formatageAdresse(pbRoles.tprol, pbRoles.norol)
            ttRoleVersement.cLibelleTiers  = outilFormatage:getNomTiers(pbRoles.tprol, pbRoles.norol)
            ttRoleVersement.iNumeroMandat  = 0
            ttRoleVersement.lCabinet       = f_RoleCabinet(pbRoles.tprol, pbRoles.norol)
        .
        run getInfoContrat(phProcAdresse, buffer ttRoleVersement, buffer pbRoles).
    end.
    else do:
        vcListeContratAssocie = f_ctrass(piReference, pbRoles.tprol).
        /* Si role par défaut: création d'un bloc note */
        do viBoucle = 1 to num-entries(vcListeContratAssocie):
            vcTypeContratAssocie = entry(viBoucle, vcListeContratAssocie).
            if not can-find(first intnt no-lock
                        where intnt.tpidt = pbRoles.tprol
                          and intnt.noidt = pbRoles.norol
                          and intnt.tpcon = vcTypeContratAssocie)
            then do:                                                              /* Création du contrat bloc-note si inexistant */
                if lookup(string(pbRoles.notie), f_LstCabinet()) > 0 and (integer(pbRoles.tprol) >= 9980 and integer(pbRoles.tprol) <= 9999)
                then do: /* fournisseur cabinet */
                    create ttRoleVersement.
                    assign
                        ttRoleVersement.rRowid         = rowid(pbRoles)
                        ttRoleVersement.iNumeroTiers   = pbRoles.notie
                        ttRoleVersement.cTypeRole      = pbRoles.tprol
                        ttRoleVersement.cNumeroRole    = trim(string(pbRoles.norol, ">>>>99999"))
                        ttRoleVersement.cTypeContrat   = ""
                        ttRoleVersement.iNumeroContrat = 0
                        ttRoleVersement.cAdresseTiers  = outilFormatage:formatageAdresse(pbRoles.tprol, pbRoles.norol)
                        ttRoleVersement.cLibelleTiers  = outilFormatage:getNomTiers(pbRoles.tprol, pbRoles.norol)
                        ttRoleVersement.iNumeroMandat  = 0
                        ttRoleVersement.lCabinet       = f_RoleCabinet(pbRoles.tprol, pbRoles.norol)
                    .
                    run getInfoContrat(phProcAdresse, buffer ttRoleVersement, buffer pbRoles).
                end.
            end.
            else for each intnt no-lock                          /* contrats existent sur le role */
                where intnt.tpidt = pbRoles.tprol
                  and intnt.noidt = pbRoles.norol
                  and intnt.tpcon = vcTypeContratAssocie
              , first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                  and ctrat.nocon = intnt.nocon
                  and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}
                  and not can-find(first ttRoleVersement
                                   where ttRoleVersement.iNumeroTiers   = pbRoles.notie
                                     and ttRoleVersement.rRowid         = rowid(pbRoles)
                                     and ttRoleVersement.cTypeContrat   = intnt.tpcon
                                     and ttRoleVersement.iNumeroContrat = intnt.nocon):
                create ttRoleVersement.
                assign
                    ttRoleVersement.rRowid         = rowid(pbRoles)
                    ttRoleVersement.iNumeroTiers   = pbRoles.notie
                    ttRoleVersement.cTypeRole      = pbRoles.tprol
                    ttRoleVersement.cNumeroRole    = trim(string(pbRoles.norol, ">>>>>99999"))
                    ttRoleVersement.cTypeContrat   = intnt.tpcon
                    ttRoleVersement.iNumeroContrat = intnt.nocon
                    ttRoleVersement.cAdresseTiers  = outilFormatage:formatageAdresse(pbRoles.tprol, pbRoles.norol)
                    ttRoleVersement.cLibelleTiers  = outilFormatage:getNomTiers(pbRoles.tprol, pbRoles.norol)
                    ttRoleVersement.iNumeroMandat  = 0
                    ttRoleVersement.lCabinet       = f_RoleCabinet(pbRoles.tprol, pbRoles.norol)
                .
                run getInfoContrat(phProcAdresse, buffer ttRoleVersement, buffer pbRoles).
            end.
        end.  /* DO viBoucle = 1 TO NUM-ENTRIES(vcListeContratAssocie): */
    end.  /* else */

end procedure.

procedure getInfoContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter phProcAdresse as handle no-undo.
    define parameter buffer ttRoleVersement for ttRoleVersement.
    define parameter buffer pbRoles         for roles.

    define buffer vbRoles for roles.
    define buffer ctrat   for ctrat.
    define buffer ctctt   for ctctt.

    /* Regroupement */
    find first ttTypeRole
        where ttTypeRole.cTypeRole = ttRoleVersement.cTypeRole
          and ttTypeRole.lAutorise = true no-error.
    if not available ttTypeRole and ttRoleVersement.iNumeroTiers <> 0 /* Sauf les fournisseurs */
    then do:
        delete ttRoleVersement.
        return.
    end.

    assign
        ttRoleVersement.cLibelleTypeRole  = if available ttTypeRole then ttTypeRole.cLibelleTypeRole else "???"
        ttRoleVersement.cTypeRole         = if available ttTypeRole then ttTypeRole.cTypeRole else ttRoleVersement.cTypeRole
        ttRoleVersement.cAdresseContrat   = ""
        ttRoleVersement.cLibelleContrat   = ""
    .
    if ttRoleVersement.iNumeroContrat > 0 then do:
        /* Libellé du contrat */
        find first ctrat no-lock
            where ctrat.tpcon = ttRoleVersement.cTypeContrat
              and ctrat.nocon = ttRoleVersement.iNumeroContrat no-error.
        if available ctrat
        then do:
            ttRoleVersement.cLibelleContrat = outilTraduction:getLibelleProg("O_CLC", ctrat.tpcon).
            find first vbRoles no-lock
                where vbRoles.tprol = ctrat.tprol
                  and vbRoles.norol = ctrat.norol no-error.
            ttRoleVersement.cAdresseContrat = dynamic-function("f_AdresseContrat" in phProcAdresse, ttRoleVersement.cTypeContrat, ttRoleVersement.iNumeroContrat).
            if ttRoleVersement.cAdresseContrat = "" and available vbRoles then ttRoleVersement.cAdresseContrat = entry(1, vbRoles.lbrech, separ[1]). /* adresse */
        end.
        else ttRoleVersement.cAdresseContrat = entry(1, pbRoles.lbrech, separ[1]). /* adresse */
    end.
    else ttRoleVersement.cAdresseContrat = entry(1, pbRoles.lbrech, separ[1]). /* adresse */

    /* Recherche du mandat */
    if ttRoleVersement.cTypeContrat = {&TYPECONTRAT-mandat2Syndic} or ttRoleVersement.cTypeContrat = {&TYPECONTRAT-mandat2gerance}
    then ttRoleVersement.iNumeroMandat = ttRoleVersement.iNumeroContrat.
    else do:
         find first ctctt no-lock
             where ctctt.tpct1 >= {&TYPECONTRAT-mandat2Syndic} and ctctt.tpct1 <= {&TYPECONTRAT-mandat2gerance}
               and ctctt.tpct2 = ttRoleVersement.cTypeContrat
               and ctctt.noct2 = ttRoleVersement.iNumeroContrat no-error.
         ttRoleVersement.iNumeroMandat = if available ctctt then ctctt.noct1 else 0.
    end.

end procedure.

procedure getListeRoleFicheTiers:
    /*------------------------------------------------------------------------------
    Purpose: Liste des rôles pour la recherche des tiers
    Notes: service utilisé notamment par beFournisseur.cls, beTiers.cls...
    ------------------------------------------------------------------------------*/
    define variable viNoord       as integer   no-undo.
    define variable vcRolesExclus as character no-undo.  //  init "00007,00031,00032,00033,00075"
    define variable voTriRole     as class parametrageTriRole no-undo.
    define buffer sys_pg for sys_pg.

    vcRolesExclus = substitute('&1,&2,&3,&4,&5', {&TYPEROLE-centrePerceptionImmeuble}, {&TYPEROLE-centreAssiettes}, {&TYPEROLE-centreImpots}, {&TYPEROLE-centreRecettes}, {&TYPEROLE-centreSIE}).
    empty temp-table ttRole.
    empty temp-table ttRoleTri.
    for each sys_pg no-lock
       where sys_pg.tppar = "O_ROL"
         and sys_pg.zone7 > ""
         and sys_pg.cdpar <> {&TYPEROLE-vendeur}    /* modif SY le 21/03/2008 - fiche 1007/0003 */
         and sys_pg.cdpar <> {&TYPEROLE-acheteur}
         and lookup(sys_pg.cdpar, vcRolesExclus) = 0
       by sys_pg.zone7:
        create ttRole.
        assign
            viNoord                 = viNoord + 1
            ttRole.iNumeroOrdre     = viNoord
            ttRole.cCodeTypeRole    = sys_pg.cdpar
            ttRole.cLibelleTypeRole = outilTraduction:getLibelleProg("O_ROL", sys_pg.cdpar)
        .
    end.
    for each sys_pg no-lock
       where sys_pg.tppar = "O_ROL"
         and sys_pg.zone7 = "":
        create ttRoleTri.
        assign
            ttRoleTri.cCodeTypeRole    = sys_pg.cdpar
            ttRoleTri.cLibelleTypeRole = outilTraduction:getLibelleProg("O_ROL", sys_pg.cdpar)
        .
    end.
    for each ttRoleTri
        where ttRoleTri.cCodeTypeRole <> {&TYPEROLE-vendeur}
          and ttRoleTri.cCodeTypeRole <> {&TYPEROLE-acheteur}
          and lookup(ttRoleTri.cCodeTypeRole, vcRolesExclus) = 0:
        create ttRole.
        assign
            viNoord                 = viNoord + 1
            ttRole.iNumeroOrdre     = viNoord
            ttRole.cCodeTypeRole    = ttRoleTri.cCodeTypeRole
            ttRole.cLibelleTypeRole = ttRoleTri.cLibelleTypeRole
        .
    end.
    /* ordre d'affichage */
    voTriRole = new parametrageTriRole().  // Une seule instanciation = meilleurs performances!!
    for each ttRole:
        voTriRole:reload(mtoken:cUser, ttRole.cCodeTypeRole).
        ttRole.iNumeroOrdre = voTriRole:getNumeroOrdre().
    end.
    delete object voTriRole.
end procedure.

procedure getRoleParType:
    /*------------------------------------------------------------------------------
    Purpose: liste des roles par type
    Notes: service utilisé par beRole.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole as character no-undo.
    define output parameter table for ttRole.

    define buffer vbRoles for roles.
    define buffer tiers for tiers.
        
    for each vbRoles no-lock
        where vbRoles.tprol = pcTypeRole
      , first tiers no-lock where tiers.notie = vbRoles.notie:
        create ttRole.
        assign 
            ttRole.iNumeroRole       = vbRoles.norol
            ttRole.cLibelleRecherche = entry(1, vbRoles.lbrech, SEPAR[1])              
            ttRole.dtTimestamp       = datetime(vbRoles.dtmsy, vbRoles.hemsy)
            ttRole.rRowid            = rowid(vbRoles)
            ttRole.CRUD              = "R"                           
        .
    end.
end procedure.
