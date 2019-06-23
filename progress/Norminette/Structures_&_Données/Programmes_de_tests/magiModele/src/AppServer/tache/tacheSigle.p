/*------------------------------------------------------------------------
File        : tacheSigle.p
Purpose     : tache Sigle (Cabinet/Mandant/Mandat/Service)
Author(s)   : OFA - 2017/10/23
Notes       : a partir de adb/tach/prmmtsig.p
derniere revue: 2018/05/28 - ofa: OK
  ----------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{tache/include/tache.i}
{adblib/include/cttac.i}
{tache/include/tacheSigle.i}
{application/include/combo.i}
{application/include/error.i}

&SCOPED-DEFINE TYPESIGLE-Cabinet    "00000"
&SCOPED-DEFINE TYPESIGLE-Mandant    "00001"
&SCOPED-DEFINE TYPESIGLE-Mandat     "00002"
&SCOPED-DEFINE TYPESIGLE-Service    "00003"
&SCOPED-DEFINE INFOSIGLE-Pied2Page  "00001"
&SCOPED-DEFINE INFOSIGLE-Entete     "00002"
&SCOPED-DEFINE INFOSIGLE-Logo       "00003"

function decoupageAdresse returns character extent 9 private(
    pcCodeTypeRole as character, piNumeroRole as integer, pcListeAdresseTiers as character):
    /*------------------------------------------------------------------------------
    Purpose: découpage de l'adresse dans un tableau de 9 lignes
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcTableauAdresseTiers as character no-undo extent 9.
    define variable vcTelephoneRole as character no-undo.
    define buffer ctanx   for ctanx.
    define buffer tiers   for tiers.
    define buffer vbRoles for roles.

    if pcListeAdresseTiers begins "?" or num-entries(pcListeAdresseTiers, "|") <= 2 then return vcTableauAdresseTiers.

    assign
        vcTableauAdresseTiers[2] = entry(1, pcListeAdresseTiers, "|")
        vcTelephoneRole          = if num-entries(pcListeAdresseTiers, "|") >= 4 then entry(4, pcListeAdresseTiers, "|") else ""
        vcTableauAdresseTiers[5] = ""
        vcTableauAdresseTiers[6] = ""
        vcTableauAdresseTiers[7] = ""
        vcTableauAdresseTiers[8] = vcTelephoneRole
        vcTableauAdresseTiers[9] = ""
    .
    if entry(2, pcListeAdresseTiers, "|") > ""
    then assign
        vcTableauAdresseTiers[3] = entry(2, pcListeAdresseTiers, "|")   /* complt adresse */
        vcTableauAdresseTiers[4] = entry(3, pcListeAdresseTiers, "|")   /* cp ville       */
    .
    else assign
        vcTableauAdresseTiers[3] = entry(3, pcListeAdresseTiers, "|")   /* cp ville       */
        vcTableauAdresseTiers[4] = ""
    .
    /*--> Recherche du registre du commerce*/
    for first vbRoles no-lock
        where vbRoles.tprol = pcCodeTypeRole
          and vbRoles.norol = piNumeroRole
      , first tiers no-lock
        where tiers.notie = vbRoles.notie
      , first ctanx no-lock
        where ctanx.tpcon = {&TYPECONTRAT-Association}
          and ctanx.nocon =  tiers.nocon:
        if ctanx.lbprf > ""
        then vcTableauAdresseTiers[6] = substitute("&1 : &2", outilTraduction:getLibelle(102452), ctanx.lbprf).
    end.
    return vcTableauAdresseTiers.
end function.

procedure initTacheSigle:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation de la tâche Sigle lorsqu'elle n'existe pas
    Notes: service utilisé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64 no-undo.
    define output parameter table for ttTacheSigle.

    define variable vcListeAdresseTiers as character no-undo.
    define variable vcType2Role         as character no-undo.
    define variable viNumeroRole        as integer   no-undo.
    define buffer intnt for intnt.
    define buffer sigle for sigle.

    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEROLE-mandant}:
        run getRole({&TYPESIGLE-Mandat}, piNumeroMandat, output vcType2Role, output viNumeroRole). /*Sigle mandat par défaut*/
        create ttTacheSigle.
        assign
            ttTacheSigle.CRUD           = 'R'
            ttTacheSigle.cTypeContrat   =  {&TYPECONTRAT-mandat2Gerance}
            ttTacheSigle.iNumeroContrat = piNumeroMandat
            ttTacheSigle.cCodeTypeRole  = vcType2Role
            ttTacheSigle.iNumeroRole    = viNumeroRole
            ttTacheSigle.cCodeTypeSigle = {&TYPESIGLE-Mandat}
            ttTacheSigle.cTypeTache     = {&TYPETACHE-Sigle}
        .
        // On récupère les informations du sigle s'il a déjà été créé
        find first sigle no-lock
            where sigle.tprol = vcType2Role
              and sigle.norol = viNumeroRole no-error.
        if available sigle
        then assign
            ttTacheSigle.cLigneSigle[1] = sigle.sig01
            ttTacheSigle.cLigneSigle[2] = sigle.sig02
            ttTacheSigle.cLigneSigle[3] = sigle.sig03
            ttTacheSigle.cLigneSigle[4] = sigle.sig04
            ttTacheSigle.cLigneSigle[5] = sigle.sig05
            ttTacheSigle.cLigneSigle[6] = sigle.sig06
            ttTacheSigle.cLigneSigle[7] = sigle.sig07
            ttTacheSigle.cLigneSigle[8] = sigle.sig08
            ttTacheSigle.cLigneSigle[9] = sigle.sig09
        .
        else assign               //Sinon, on récupère l'adresse du mandat/mandant/service
            ttTacheSigle.cLigneSigle[1] = outilFormatage:getNomTiers1Ligne('TYPE',
                                                                           if vcType2Role = {&TYPECONTRAT-mandat2Gerance} then {&TYPEROLE-mandant} else ttTacheSigle.cCodeTypeRole,
                                                                           if vcType2Role = {&TYPECONTRAT-mandat2Gerance} then integer(intnt.noidt) else ttTacheSigle.iNumeroRole,
                                                                           32)
            vcListeAdresseTiers         = outilFormatage:getAdresse14Lignes('TYPE',
                                                                           if vcType2Role = {&TYPECONTRAT-mandat2Gerance} then {&TYPEROLE-mandant} else ttTacheSigle.cCodeTypeRole,
                                                                           if vcType2Role = {&TYPECONTRAT-mandat2Gerance} then integer(intnt.noidt) else ttTacheSigle.iNumeroRole,
                                                                           32)
            ttTacheSigle.cLigneSigle    = decoupageAdresse(vcType2Role, viNumeroRole, vcListeAdresseTiers)
        .
    end.
end procedure.

procedure initSigles:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation des différents sigles (Cabinet, mandant, mandat, service)
    Notes: service utilisé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64 no-undo.
    define output parameter table for ttSigle.

    define variable vcListeAdresseTiers   as character no-undo.
    define buffer ctrat   for ctrat.
    define buffer vbCtrat for ctrat.
    define buffer intnt   for intnt.
    define buffer ctctt   for ctctt.
    define buffer sigle   for sigle.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and   ctrat.nocon = piNumeroMandat
      , first intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = {&TYPEROLE-mandant}:
        create ttSigle.        //Sigle du cabinet
        assign
            ttSigle.CRUD           = 'R'
            ttSigle.cCodeTypeRole  = {&TYPEROLE-mandataire}
            ttSigle.iNumeroRole    = 1
            ttSigle.cCodeTypeSigle = {&TYPESIGLE-Cabinet}
        .
        find first sigle no-lock
            where sigle.tprol = ttSigle.cCodeTypeRole
              and sigle.norol = ttSigle.iNumeroRole no-error.
        if available sigle
        then assign
            ttSigle.cLigneSigle[1] = sigle.sig01
            ttSigle.cLigneSigle[2] = sigle.sig02
            ttSigle.cLigneSigle[3] = sigle.sig03
            ttSigle.cLigneSigle[4] = sigle.sig04
            ttSigle.cLigneSigle[5] = sigle.sig05
            ttSigle.cLigneSigle[6] = sigle.sig06
            ttSigle.cLigneSigle[7] = sigle.sig07
            ttSigle.cLigneSigle[8] = sigle.sig08
            ttSigle.cLigneSigle[9] = sigle.sig09
        .
        else assign
            ttSigle.cLigneSigle[1] = outilFormatage:getNomTiers1Ligne('TYPE', ttSigle.cCodeTypeRole, ttSigle.iNumeroRole, 32)
            vcListeAdresseTiers    = outilFormatage:getAdresse14Lignes('TYPE', ttSigle.cCodeTypeRole, ttSigle.iNumeroRole, 32)
            ttSigle.cLigneSigle    = decoupageAdresse(ttSigle.cCodeTypeRole, ttSigle.iNumeroRole, vcListeAdresseTiers)
        .

        create ttSigle.        //Sigle du mandant
        assign
            ttSigle.CRUD           = 'R'
            ttSigle.cCodeTypeRole  = intnt.tpidt
            ttSigle.iNumeroRole    = intnt.noidt
            ttSigle.cCodeTypeSigle = {&TYPESIGLE-Mandant}
        .
        find first sigle no-lock
            where sigle.tprol = ttSigle.cCodeTypeRole
              and sigle.norol = ttSigle.iNumeroRole no-error.
        if available sigle
        then assign
            ttSigle.cLigneSigle[1] = sigle.sig01
            ttSigle.cLigneSigle[2] = sigle.sig02
            ttSigle.cLigneSigle[3] = sigle.sig03
            ttSigle.cLigneSigle[4] = sigle.sig04
            ttSigle.cLigneSigle[5] = sigle.sig05
            ttSigle.cLigneSigle[6] = sigle.sig06
            ttSigle.cLigneSigle[7] = sigle.sig07
            ttSigle.cLigneSigle[8] = sigle.sig08
            ttSigle.cLigneSigle[9] = sigle.sig09
        .
        else assign
            ttSigle.cLigneSigle[1] = outilFormatage:getNomTiers1Ligne('TYPE', ttSigle.cCodeTypeRole, ttSigle.iNumeroRole, 32)
            vcListeAdresseTiers    = outilFormatage:getAdresse14Lignes('TYPE', ttSigle.cCodeTypeRole, ttSigle.iNumeroRole, 32)
            ttSigle.cLigneSigle    = decoupageAdresse(ttSigle.cCodeTypeRole, ttSigle.iNumeroRole, vcListeAdresseTiers)
        .

        create ttSigle.        //Sigle du mandat
        assign
            ttSigle.CRUD           = 'R'
            ttSigle.cCodeTypeRole  = ctrat.tpcon
            ttSigle.iNumeroRole    = ctrat.nocon
            ttSigle.cCodeTypeSigle = {&TYPESIGLE-Mandat}
        .
        find first sigle no-lock
            where sigle.tprol = ttSigle.cCodeTypeRole
              and sigle.norol = ttSigle.iNumeroRole no-error.
        if available sigle
        then assign
            ttSigle.cLigneSigle[1] = sigle.sig01
            ttSigle.cLigneSigle[2] = sigle.sig02
            ttSigle.cLigneSigle[3] = sigle.sig03
            ttSigle.cLigneSigle[4] = sigle.sig04
            ttSigle.cLigneSigle[5] = sigle.sig05
            ttSigle.cLigneSigle[6] = sigle.sig06
            ttSigle.cLigneSigle[7] = sigle.sig07
            ttSigle.cLigneSigle[8] = sigle.sig08
            ttSigle.cLigneSigle[9] = sigle.sig09
        .
        else assign
            ttSigle.cLigneSigle[1] = outilFormatage:getNomTiers1Ligne('TYPE', intnt.tpidt, integer(intnt.noidt), 32) //Dans ce contexte(no mandant), noidt est sur 5 digits
            vcListeAdresseTiers    = outilFormatage:getAdresse14Lignes('TYPE', intnt.tpidt, integer(intnt.noidt), 32)
            ttSigle.cLigneSigle    = decoupageAdresse(ttSigle.cCodeTypeRole, ttSigle.iNumeroRole, vcListeAdresseTiers)
        .
        for first ctctt no-lock
            where ctctt.tpct2 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.noct2 = piNumeroMandat
              and ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
          , first vbCtrat no-lock
            where vbCtrat.tpcon = ctctt.tpct1
              and vbCtrat.nocon = ctctt.noct1:
            //Sigle du dervice de gestion - Attention, le type et le numéro de role stockés dans la table sigle sont ceux du service de gestion (rôle "01049")
            //mais le type et le numéro de rôle permettant de récupérer l'adresse sont ceux du gestionnaire du service (rôle "00047")
            create ttSigle.
            assign
                ttSigle.CRUD           = 'R'
                ttSigle.cCodeTypeRole  = ctctt.tpct1
                ttSigle.iNumeroRole    = ctctt.noct1
                ttSigle.cCodeTypeSigle = {&TYPESIGLE-Service}
            .
            find first sigle no-lock
                where sigle.tprol = ttSigle.cCodeTypeRole
                  and sigle.norol = ttSigle.iNumeroRole no-error.
            if available sigle
            then assign
                ttSigle.cLigneSigle[1] = sigle.sig01
                ttSigle.cLigneSigle[2] = sigle.sig02
                ttSigle.cLigneSigle[3] = sigle.sig03
                ttSigle.cLigneSigle[4] = sigle.sig04
                ttSigle.cLigneSigle[5] = sigle.sig05
                ttSigle.cLigneSigle[6] = sigle.sig06
                ttSigle.cLigneSigle[7] = sigle.sig07
                ttSigle.cLigneSigle[8] = sigle.sig08
                ttSigle.cLigneSigle[9] = sigle.sig09
            .
            else assign
                ttSigle.cLigneSigle[1] = outilFormatage:getNomTiers1Ligne('TYPE', {&TYPEROLE-gestionnaire}, vbCtrat.norol, 32)
                vcListeAdresseTiers    = outilFormatage:getAdresse14Lignes('TYPE', {&TYPEROLE-gestionnaire}, vbCtrat.norol, 32)
                ttSigle.cLigneSigle    = decoupageAdresse(ttSigle.cCodeTypeRole, ttSigle.iNumeroRole, vcListeAdresseTiers)
            .
        end.
    end.

end procedure.

procedure miseAJourTableTache private:
    /*------------------------------------------------------------------------------
     Purpose: Mise à jour de la table tache à partir du dataset
     Notes:
    ------------------------------------------------------------------------------*/
    define variable vhTache     as handle   no-undo.
    define variable vhProcCttac as handle   no-undo.

    define buffer cttac for cttac.
    define buffer sigle for sigle.

    empty temp-table ttTache.
    empty temp-table ttCttac.
blocTrans:
    do transaction:
        create ttTache.
        assign
            ttTache.noita = ttTacheSigle.iNumeroTache
            ttTache.tpcon = ttTacheSigle.cTypeContrat
            ttTache.nocon = ttTacheSigle.iNumeroContrat
            ttTache.tptac = ttTacheSigle.cTypeTache
            ttTache.notac = ttTacheSigle.iChronoTache
            ttTache.ntges = ttTacheSigle.cCodeTypeSigle
            ttTache.lbdiv = substitute("&1&2&3&2&4",ttTacheSigle.cCodePied2Page,SEPAR[1],ttTacheSigle.cCodeEntete,ttTacheSigle.cCodeLogo)
            ttTache.CRUD        = ttTacheSigle.CRUD
            ttTache.dtTimestamp = ttTacheSigle.dtTimestamp
            ttTache.rRowid      = ttTacheSigle.rRowid
        .
        run tache/tache.p persistent set vhTache.
        run getTokenInstance in vhTache(mToken:JSessionId).
        run setTache in vhTache(table ttTache by-reference).
        if mError:erreur() then undo blocTrans, leave blocTrans.

        run adblib/cttac_CRUD.p persistent set vhProcCttac.
        run getTokenInstance in vhProcCttac(mToken:JSessionId).
        if lookup(ttTacheSigle.CRUD, "U,C") > 0
        and not can-find(first cttac no-lock
                         where cttac.tpcon = ttTacheSigle.cTypeContrat
                           and cttac.nocon = ttTacheSigle.iNumeroContrat
                           and cttac.tptac = ttTacheSigle.cTypeTache) then do:
            create ttCttac.
            assign
                ttCttac.tpcon = ttTacheSigle.cTypeContrat
                ttCttac.nocon = ttTacheSigle.iNumeroContrat
                ttCttac.tptac = ttTacheSigle.cTypeTache
                ttCttac.CRUD  = "C"
            .
        end.
        else if ttTacheSigle.CRUD = "D" then for first cttac no-lock
            where cttac.tpcon = ttTacheSigle.cTypeContrat
              and cttac.nocon = ttTacheSigle.iNumeroContrat
              and cttac.tptac = ttTacheSigle.cTypeTache:
            create ttCttac.
            assign
                ttCttac.tpcon       = cttac.tpcon
                ttCttac.nocon       = cttac.nocon
                ttCttac.tptac       = cttac.tptac
                ttCttac.CRUD        = "D"
                ttCttac.rRowid      = rowid(cttac)
                ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            .
        end.
        if can-find(first ttCttac where ttCttac.CRUD <> "R")
        then do:
            run setCttac in vhProcCttac(table ttCttac by-reference).
            if mError:erreur() then  undo blocTrans, leave blocTrans.
        end.

        // Mise à jour table sigle - N.B.: on ne supprime pas l'enregistrement lorsqu'on supprime la tâche
        find first sigle exclusive-lock
            where sigle.tprol = ttTacheSigle.cCodeTypeRole
              and sigle.norol = ttTacheSigle.iNumeroRole no-error.
        if not available sigle then create sigle.
        assign
            sigle.tprol = ttTacheSigle.cCodeTypeRole
            sigle.norol = ttTacheSigle.iNumeroRole
            sigle.sig01 = ttTacheSigle.cLigneSigle[1]
            sigle.sig02 = ttTacheSigle.cLigneSigle[2]
            sigle.sig03 = ttTacheSigle.cLigneSigle[3]
            sigle.sig04 = ttTacheSigle.cLigneSigle[4]
            sigle.sig05 = ttTacheSigle.cLigneSigle[5]
            sigle.sig06 = ttTacheSigle.cLigneSigle[6]
            sigle.sig07 = ttTacheSigle.cLigneSigle[7]
            sigle.sig08 = ttTacheSigle.cLigneSigle[8]
            sigle.sig09 = ttTacheSigle.cLigneSigle[9]
        .
    end.
    if valid-handle(vhTache) then run destroy in vhTache.
    if valid-handle(vhProcCttac) then run destroy in vhProcCttac.
end procedure.

procedure getRole private:
    /*------------------------------------------------------------------------------
    Purpose: récupération du type et du numéro de rôle en fonction du type de sigle
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeTypeSigle as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcType2Role     as character no-undo.
    define output parameter piNumeroRole    as integer   no-undo.

    define buffer ctctt for ctctt.
    define buffer intnt for intnt.

    case pcCodeTypeSigle:
        when {&TYPESIGLE-Cabinet} then assign                         // Sigle Mandataire (Cabinet)
            pcType2Role = {&TYPEROLE-mandataire}
            piNumeroRole = 1
        .
        when {&TYPESIGLE-Mandant} then for first intnt no-lock        // Sigle Mandant
            where intnt.tpcon = pcCodeTypeSigle
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEROLE-mandant}:
            assign
                pcType2Role  = intnt.tpidt
                piNumeroRole = intnt.noidt
            .
        end.
        when {&TYPESIGLE-Mandat} then assign                           // Sigle Mandat
            pcType2Role = {&TYPECONTRAT-mandat2Gerance}
            piNumeroRole = piNumeroContrat
        .
        when {&TYPESIGLE-Service} then for first ctctt no-lock         // Sigle Service de Gestion, recherche du service du mandat
            where ctctt.tpct2 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.noct2 = piNumeroContrat
              and ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}:
            assign
                pcType2Role = ctctt.tpct1
                piNumeroRole = ctctt.noct1
            .
        end.
    end case.

end procedure.

procedure setTacheSigle:
    /*------------------------------------------------------------------------------
    Purpose: Update de la tâche Sigle
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheSigle.

    for first ttTacheSigle
        where lookup(ttTacheSigle.CRUD, "C,U,D") > 0:
        run miseAJourTableTache.
    end.

end procedure.

procedure getTacheSigle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define output parameter table for ttTacheSigle.

    define variable vcType2Role  as character no-undo.
    define variable viNumeroRole as integer   no-undo.
    define buffer tache for tache.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer sigle for sigle.
    define buffer tbent for tbent.

    empty temp-table ttTacheSigle.
    for first tache no-lock
        where tache.tpcon =  {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-Sigle}
          and tache.notac = 1:
        create ttTacheSigle.
        assign
            ttTacheSigle.dtTimestamp       = datetime(tache.dtmsy, tache.hemsy)
            ttTacheSigle.CRUD              = 'R'
            ttTacheSigle.rRowid            = rowid(tache)
            ttTacheSigle.cTypeTache        = {&TYPETACHE-Sigle}
            ttTacheSigle.iNumeroTache      = tache.noita
            ttTacheSigle.cTypeContrat      = tache.tpcon
            ttTacheSigle.iNumeroContrat    = tache.nocon
            ttTacheSigle.cCodeTypeSigle    = tache.ntges
            ttTacheSigle.cLibelleTypeSigle = outilTraduction:getLibelleParam("CDSIG", ttTacheSigle.cCodeTypeSigle)
            ttTacheSigle.cCodePied2Page    = entry(1, tache.lbdiv, SEPAR[1])
            ttTacheSigle.cCodeEntete       = if num-entries(tache.lbdiv,SEPAR[1]) >= 2 then entry(2, tache.lbdiv, SEPAR[1]) else ""
            ttTacheSigle.cCodeLogo         = if num-entries(tache.lbdiv,SEPAR[1]) >= 3 then entry(3, tache.lbdiv, SEPAR[1]) else ""
        .
        run getRole(ttTacheSigle.cCodeTypeSigle, ttTacheSigle.iNumeroContrat, output vcType2Role, output viNumeroRole).
        assign
            ttTacheSigle.cCodeTypeRole = vcType2Role
            ttTacheSigle.iNumeroRole   = viNumeroRole
        .
        // Récupération des libellés
        for first tbent no-lock
            where tbent.cdent = string(integer(ttTacheSigle.cCodeTypeSigle) + 3, "99999")
              and tbent.iden1 = {&INFOSIGLE-Pied2Page}
              and tbent.iden2 = ttTacheSigle.cCodePied2Page:
            ttTacheSigle.cLibellePied2Page = tbent.lben2.
        end.
        for first tbent no-lock
            where tbent.cdent = string(integer(ttTacheSigle.cCodeTypeSigle) + 3, "99999")
              and tbent.iden1 = {&INFOSIGLE-Entete}
              and tbent.iden2 = ttTacheSigle.cCodeEntete:
            ttTacheSigle.cLibelleEntete = tbent.lben2.
        end.
        for first tbent no-lock
            where tbent.cdent = string(integer(ttTacheSigle.cCodeTypeSigle) + 3, "99999")
              and tbent.iden1 = {&INFOSIGLE-Logo}
              and tbent.iden2 = ttTacheSigle.cCodeLogo:
            ttTacheSigle.cLibelleLogo = tbent.lben2.
        end.
        // Récupération du sigle
        for first sigle no-lock
            where sigle.tprol = vcType2Role
              and sigle.norol = viNumeroRole:
            assign
                ttTacheSigle.cLigneSigle[1] = sigle.sig01
                ttTacheSigle.cLigneSigle[2] = sigle.sig02
                ttTacheSigle.cLigneSigle[3] = sigle.sig03
                ttTacheSigle.cLigneSigle[4] = sigle.sig04
                ttTacheSigle.cLigneSigle[5] = sigle.sig05
                ttTacheSigle.cLigneSigle[6] = sigle.sig06
                ttTacheSigle.cLigneSigle[7] = sigle.sig07
                ttTacheSigle.cLigneSigle[8] = sigle.sig08
                ttTacheSigle.cLigneSigle[9] = sigle.sig09
            .
        end.
    end.
    if not can-find(first ttTacheSigle)
    then for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroMandat
      , first intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = {&TYPEROLE-mandant}:
        mError:createError({&question}, 1000397, substitute("&1 &2", outilTraduction:getLibelleProg('O_ROL', intnt.tpidt), intnt.noidt)). //Il n'y a pas de sigle pour le &1. Voulez-vous le créer ?
    end.
end procedure.

procedure initComboTacheSigle:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos de l'écran depuis la vue
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeTypeSigle as character no-undo.
    define output parameter table for ttcombo.

    run chargeCombo(pcCodeTypeSigle).

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeTypeSigle as character no-undo.

    define variable viLastCombo as integer   no-undo.
    define variable voSyspr     as class syspr no-undo.
    define buffer tbent for tbent.

    assign
        voSyspr     = new syspr()
        viLastCombo = voSyspr:getComboParametre("CDSIG", "TYPESIGLE", output table ttCombo by-reference)
    .
    delete object voSyspr.
    /*--> Pied de page */
    for each tbent no-lock
        where tbent.cdent = string(integer(pcCodeTypeSigle) + 3,"99999")
          and tbent.iden1 = {&INFOSIGLE-Pied2Page}:
        create ttCombo.
        assign
            viLastCombo       = viLastCombo + 1
            ttCombo.iSeqId    = viLastCombo
            ttCombo.cNomCombo = "PIEDDEPAGESIGLE"
            ttCombo.cCode     = tbent.iden2
            ttCombo.cLibelle  = tbent.lben2
        .
    end.
    /*--> Entete */
    for each tbent no-lock
        where tbent.cdent = string(integer(pcCodeTypeSigle) + 3, "99999")
          and tbent.iden1 = {&INFOSIGLE-Entete}:
        create ttCombo.
        assign
            viLastCombo       = viLastCombo + 1
            ttCombo.iSeqId    = viLastCombo
            ttCombo.cNomCombo = "ENTETESIGLE"
            ttCombo.cCode     = tbent.iden2
            ttCombo.cLibelle  = tbent.lben2
        .
    end.
    /*--> Logo */
    for each tbent no-lock
        where tbent.cdent = string(integer(pcCodeTypeSigle) + 3, "99999")
          and tbent.iden1 = {&INFOSIGLE-Logo}:
        create ttCombo.
        assign
            viLastCombo       = viLastCombo + 1
            ttCombo.iSeqId    = viLastCombo
            ttCombo.cNomCombo = "LOGOSIGLE"
            ttCombo.cCode     = tbent.iden2
            ttCombo.cLibelle  = tbent.lben2
        .
    end.
end procedure.
