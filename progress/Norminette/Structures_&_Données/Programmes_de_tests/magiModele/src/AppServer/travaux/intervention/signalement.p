/*------------------------------------------------------------------------
File        : signalement.p
Purpose     :
Author(s)   : kantena - 2016/02/09
Notes       :
Tables      : BASE sadb : intnt imble ctrat signa local dtlot trInt unite cpUni
----------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/actionUtilisateur.i}

using outils.httpClient.
using OpenEdge.Net.URI.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{Travaux/include/signalement.i}
{travaux/include/detailsIntervention.i}
{application/include/glbsepar.i}

define variable ghTiers  as handle  no-undo.

function getNextSignalement returns logical private (output piNumeroNextSignalement as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer signa for signa.

    piNumeroNextSignalement = ((year(today) modulo 100) * 100  + month(today)) * 100000.
    find last signa no-lock
        where signa.nosig > piNumeroNextSignalement no-error.
    if available signa
    then if signa.nosig = piNumeroNextSignalement + 99999
         then do:
             mError:create2Error({&ACTION-creation}, 107713).
             return false.
         end.
         else piNumeroNextSignalement = signa.nosig + 1.
    else piNumeroNextSignalement = piNumeroNextSignalement + 00001.
    return true.

end function.

function controleSignalement returns logical private (phBuffer as handle, output pcLibelleMandat as character, output pcLibelleImmeuble as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    define buffer imble for imble.

    // Le contrat doit exister
    find first ctrat no-lock
        where ctrat.tpcon = phBuffer::cTypeMandat
          and ctrat.nocon = phBuffer::iNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 211669, substitute('&2&1&3', separ[1], phBuffer::cTypeMandat, phBuffer::iNumeroMandat)).
        return false.
    end.
    // L'immeuble doit exister.
    find first imble no-lock
        where imble.noimm = phBuffer::iNumeroImmeuble no-error.
    if not available imble
    then do:
        mError:createError({&error}, 211676, substitute('&1', phBuffer::iNumeroImmeuble)).
        return false.
    end.
    // L'immeuble doit être sur le contrat.
    if not can-find(first intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = imble.noimm)
    then do:
        mError:createError({&error}, 211677, substitute('&2&1&3&1&4', separ[1], imble.noimm, ctrat.tpcon, ctrat.nocon)).
        return false.
    end.
    /* Pas de blocage si signalé par le syndicat de copropriete
    if pcNomSignalant = '' or pcNomSignalant = ?
    then do:
        mError:createError({&error}, 211670, substitute('&1', phBuffer::iNumeroSignalant)).
        return false.
    end.
    */
    assign
        pcLibelleMandat   = ctrat.lbnom
        pcLibelleImmeuble = imble.lbnom
    .
    return true.

end function.

function estCloture returns logical private (piNumeroTraitement as int64):
    /*------------------------------------------------------------------------------
    Purpose: Le signalement est-il clôturé ?
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer trint for TrInt.

    for last trint no-lock
       where trint.notrt = piNumeroTraitement
         and trint.tptrt = {&TYPEINTERVENTION-signalement}:
        if TrInt.CdSta = {&STATUTINTERVENTION-termine} then return true.
    end.
    return false.
end function.

function controleDeleteSignalement returns logical private (piNumeroTraitement as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: Suppression impossible si existence d'un detail devis, d'un suivi devis,
           d'un ordre de service ou d'une facture sur au moins une intervention
    ------------------------------------------------------------------------------*/
    define buffer inter for inter.

    for each inter no-lock
        where inter.nosig = piNumeroTraitement:
        if can-find(first dtdev no-lock where dtdev.noint = inter.noint)
        then do:
            mError:create2Error(104432, 211704).
            return false.
        end.
        if can-find(first svdev no-lock where svdev.noint = inter.noint)
        then do:
            mError:create2Error(104432, 211705).
            return false.
        end.
        if can-find(first dtord no-lock where dtord.noint = inter.noint)
        then do:
            mError:create2Error(104432, 211706).
            return false.
        end.
        if can-find(first dtfac no-lock where dtfac.noint = inter.noint)
        then do:
            mError:create2Error(104432, 211707).
            return false.
        end.
    end.
    return true.

end function.

procedure getSignalementExtranet:
    /*------------------------------------------------------------------------------
    purpose: Récupération des informations extranet pour pouvoir créer des signalements 
             en automatique
    Note   : service pour beSignalement.cls
    ------------------------------------------------------------------------------*/
    define variable voHttpClient as class httpClient no-undo.
    define variable voUri        as class URI        no-undo.
    define variable voJson       as class JsonObject no-undo.
    define variable voJsonSigna  as class JsonObject no-undo.
    define variable voJsonA      as class JsonArray  no-undo.
    define variable viCptJson    as integer          no-undo.
    define variable vcIdTicket   as character        no-undo.
    define output parameter table for ttSignalement.

    assign
        voHttpClient = new outils.httpClient()                    // Création du client HTTP
        voURI        = new Uri('https', 'gi-6.la-gi.fr', 443)     // Construction de la requête pour récupération des tickets  // todo: paramétrage ???!!!
        voURI:path   = 'ws/rest/listTicketOS'                     // todo: paramétrage ???!!!
    .
    voURI:addQuery('ref', '06506').                               // todo: paramétrage ???!!!
    voURI:addQuery('apiKey', 'b0fb933b11b0703c58d948a060376fc2'). // todo: paramétrage ???!!!

    // Exécution du GET http
    voJson = voHttpClient:httpGET(voURI).
    if valid-object(voJson) then do:
        voJsonA = voJson:GetJsonArray("ticket").
        do viCptJson = 1 to voJsonA:length:
            voJsonSigna = voJsonA:getJsonObject(viCptJson).
            create ttSignalement.
            assign
                ttSignalement.CRUD                     = "C"
                ttSignalement.iNumeroMandat            = integer(voJsonSigna:getCharacter("num_mandat"))
                ttSignalement.cTypeMandat              = voJsonSigna:GetCharacter("tpcon")
                ttSignalement.iNumeroImmeuble          = voJsonSigna:getInteger("num_immeuble")
                ttSignalement.cLibelleIntervention     = trim(voJsonSigna:getCharacter("nom"))
                ttSignalement.cCommentaireIntervention = voJsonSigna:getCharacter("commentaire")
                ttSignalement.cCodeRole                = voJsonSigna:getCharacter("norol")
                ttSignalement.iNumeroSignalant         = voJsonSigna:getInteger("nousr")
                ttSignalement.cSysUser                 = mtoken:cUser
                vcIdTicket                             = substitute('&1,&2', vcIdTicket, voJsonSigna:getInteger("id_ticket"))
            .
        end.
    end.
    run createSignalement(input-output table ttSignalement).  // Création des signalements en base
    voURI:addQuery('AddedOS', trim(vcIdTicket, ',')).         // Construction de la requête pour flagger les tickets traités
    voJson = voHttpClient:httpGET(voURI).                     // Exécution du GET http
    delete object voHttpClient.                               // Suppresion du client HTTP

end procedure.

procedure getSignalement:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service pour beSignalement.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttSignalement.
    define output parameter table for ttDetailsIntervention.

    define variable vcTypeMandat         as character no-undo.
    define variable viNumeroMandat       as int64     no-undo.
    define variable viNumeroTraitement   as int64     no-undo.
    define variable viNumeroIntervention as integer   no-undo.

    define buffer Inter for Inter.
    define buffer Signa for Signa.
    define buffer ctrat for ctrat.
    define buffer imble for imble.
    define buffer intnt for intnt.
    define buffer tutil for tutil.

    empty temp-table ttSignalement.
    assign
        vcTypeMandat         = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat       = poCollection:getInt64("iNumeroMandat")
        viNumeroTraitement   = poCollection:getInt64("iNumeroTraitement")
        viNumeroIntervention = poCollection:getInteger("iNumeroIntervention")
    .
    run tiers/tiers.p persistent set ghTiers.
    run getTokenInstance in ghTiers (mToken:JSessionId).

    for each intnt no-lock
        where intnt.tpcon = vcTypeMandat
          and intnt.nocon = viNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first imble no-lock
        where imble.noimm = intnt.noidt
      , first ctrat no-lock
        where ctrat.tpcon = vcTypeMandat
          and ctrat.nocon = viNumeroMandat:

        for first signa no-lock
            where signa.nosig = viNumeroTraitement
          , first inter no-lock
            where inter.nosig = signa.nosig
              and (if viNumeroIntervention <> 0 then inter.noint = viNumeroIntervention else true):
            /* Recherche de l'utilisateur ayant créé le signalement */
            find first tutil no-lock where tutil.ident_u = Signa.CdCsy no-error.
            create ttSignalement.
            assign
                ttSignalement.CRUD                     = 'R'
                ttSignalement.iNumeroIntervention      = inter.noint
                ttSignalement.iNumeroSignalement       = signa.nosig
                ttSignalement.cCodeTheme               = signa.lbdiv1
                ttSignalement.cCodeMode                = signa.mdsig
                ttSignalement.cCodeTraitement          = {&TYPEINTERVENTION-signalement}
                ttSignalement.cTypeMandat              = ctrat.tpcon
                ttSignalement.iNumeroImmeuble          = intnt.noidt
                ttSignalement.cLibelleImmeuble         = imble.lbnom
                ttSignalement.iNumeroMandat            = viNumeroMandat
                ttSignalement.cLibelleMandat           = ctrat.lbnom
                ttSignalement.cCodeRoleSignalant       = inter.tppar
                ttSignalement.cLibelleRoleSignalant    = outilTraduction:getLibelleProg("O_ROL", inter.tppar)
                ttSignalement.iNumeroSignalant         = inter.nopar
                ttSignalement.cLibelleSignalant        = if inter.tppar = "FOU" then outilFormatage:getNomFour("F", inter.nopar, inter.tpcon)
                                                         else outilFormatage:getNomTiers(inter.tppar, inter.nopar)
                ttSignalement.cCommentaireIntervention = inter.lbcom
                ttSignalement.cLibelleIntervention     = inter.lbInt
                ttSignalement.lCloture                 = estCloture(signa.nosig)
                ttSignalement.cSysUser                 = if available tutil then tutil.nom else ""
                ttSignalement.daSysDateCreate          = Signa.dtcsy
                ttSignalement.dtTimestampSigna         = datetime(signa.dtmsy, signa.hemsy)
                ttSignalement.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
                ttSignalement.rRowidSigna              = rowid(signa)
                ttSignalement.rRowidInter              = rowid(inter)
            .
            create ttDetailsIntervention.
            assign
                ttDetailsIntervention.CRUD = 'R'
                ttDetailsIntervention.iNumeroIntervention      = inter.NoInt
                ttDetailsIntervention.iNumeroTraitement        = signa.nosig
                ttDetailsIntervention.cCodeArticle             = inter.cdart
                ttDetailsIntervention.cLibelleIntervention     = inter.lbInt
                ttDetailsIntervention.cCommentaireIntervention = inter.lbcom
                ttDetailsIntervention.cCodeStatut              = inter.cdsta
                ttDetailsIntervention.rRowidInter              = rowid(inter)
                ttDetailsIntervention.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
            .
        end.
    end.
    run destroy in ghTiers.

end procedure.

procedure getSignalementRowid:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beSignalement.cls
    ------------------------------------------------------------------------------*/
    define input  parameter prRowid as rowid no-undo.
    define output parameter table for ttSignalement.
    define output parameter table for ttDetailsIntervention.

    define buffer Inter for Inter.
    define buffer Signa for Signa.
    define buffer ctrat for ctrat.
    define buffer imble for imble.
    define buffer intnt for intnt.
    define buffer tutil for tutil.

    empty temp-table ttSignalement.
    run tiers/tiers.p persistent set ghTiers.
    run getTokenInstance in ghTiers (mToken:JSessionId).

    for first signa no-lock
        where rowid(signa) = prRowid
      , first inter no-lock
        where inter.nosig = signa.nosig
      , first intnt no-lock
        where intnt.tpcon = inter.tpcon
          and intnt.nocon = inter.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first imble no-lock
        where imble.noimm = intnt.noidt
      , first ctrat no-lock
        where ctrat.tpcon = inter.tpcon
          and ctrat.nocon = inter.nocon:

        /* Recherche de l'utilisateur ayant créé le signalement */
        find first tutil no-lock where tutil.ident_u = signa.cdcsy no-error.
        create ttSignalement.
        assign
            ttSignalement.CRUD                     = 'R'
            ttSignalement.iNumeroIntervention      = inter.noint
            ttSignalement.iNumeroSignalement       = signa.nosig
            ttSignalement.cCodeTheme               = signa.lbdiv1
            ttSignalement.cCodeMode                = signa.mdsig
            ttSignalement.cCodeTraitement          = {&TYPEINTERVENTION-signalement}
            ttSignalement.cTypeMandat              = ctrat.tpcon
            ttSignalement.iNumeroImmeuble          = intnt.noidt
            ttSignalement.cLibelleImmeuble         = imble.lbnom
            ttSignalement.iNumeroMandat            = inter.nocon
            ttSignalement.cLibelleMandat           = ctrat.lbnom
            ttSignalement.cCodeRoleSignalant       = inter.tppar
            ttSignalement.cLibelleRoleSignalant    = outilTraduction:getLibelleProg("O_ROL", inter.tppar)
            ttSignalement.iNumeroSignalant         = inter.nopar
            ttSignalement.cLibelleSignalant        = if inter.tppar = "FOU" then outilFormatage:getNomFour("F", inter.nopar, inter.tpcon)
                                                     else outilFormatage:getNomTiers(inter.tppar, inter.nopar)
            ttSignalement.cCommentaireIntervention = inter.lbcom
            ttSignalement.cLibelleIntervention     = inter.lbInt
            ttSignalement.lCloture                 = estCloture(signa.nosig)
            ttSignalement.cSysUser                 = if available tutil then tutil.nom else ""
            ttSignalement.daSysDateCreate          = signa.dtcsy
            ttSignalement.dtTimestampSigna         = datetime(signa.dtmsy, signa.hemsy)
            ttSignalement.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
            ttSignalement.rRowidSigna              = rowid(signa)
            ttSignalement.rRowidInter              = rowid(inter)
        .
        create ttDetailsIntervention.
        assign
            ttDetailsIntervention.CRUD = 'R'
            ttDetailsIntervention.iNumeroIntervention      = inter.NoInt
            ttDetailsIntervention.iNumeroTraitement        = signa.nosig
            ttDetailsIntervention.cCodeArticle             = inter.cdart
            ttDetailsIntervention.cLibelleIntervention     = inter.lbInt
            ttDetailsIntervention.cCommentaireIntervention = inter.lbcom
            ttDetailsIntervention.cCodeStatut              = inter.cdsta
            ttDetailsIntervention.rRowidInter              = rowid(inter)
            ttDetailsIntervention.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
        .
    end.
    run destroy in ghTiers.

end procedure.

procedure createSignalement:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beSignalement.cls
    ------------------------------------------------------------------------------*/
    define input-output parameter table-handle phtt.

    define variable vhbtt               as handle    no-undo.
    define variable vhqtt               as handle    no-undo.
    define variable viNextSignalement   as integer   no-undo.
    define variable viNextIntervention  as integer   no-undo.
    define variable viNextTraitement    as integer   no-undo.
    define variable vcLibelleMandat     as character no-undo.
    define variable vcLibelleImmeuble   as character no-undo.

    define buffer trInt for trInt.
    define buffer signa for signa.
    define buffer inter for inter.

    vhbtt = phtt:default-buffer-handle.
    create query vhqtt.
    vhqtt:set-buffers(vhbtt).
    vhqtt:query-prepare(substitute('for each &1 where &1.CRUD="C"', vhbtt:name)).
    vhqtt:query-open().

    run tiers/tiers.p persistent set ghTiers.
    run getTokenInstance in ghTiers (mToken:JSessionId).

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhqtt:get-next().
            if vhqtt:query-off-end then leave blocRepeat.

            // En création, on autorise un iNumeroSignalement <> 0, pour permettre un lien éventuel
            // if vhbtt::iNumeroSignalement > 0 then next blocRepeat.
            if not controleSignalement(vhbtt, output vcLibelleMandat, output vcLibelleImmeuble)
            or not getNextSignalement(output viNextSignalement)
            then undo blocTransaction, leave blocTransaction.   // erreur créée dans getNextSignalement.

            /*--> Creation du signalement */
            create signa.
            assign
                signa.noref        = integer(if vhbtt::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                signa.nosig        = viNextSignalement
                signa.mdsig        = vhbtt::cCodeMode
                signa.lbdiv1       = vhbtt::cCodeTheme
                signa.cdcsy        = mtoken:cUser
                signa.dtcsy        = today
                signa.hecsy        = mtime
                vhbtt::iNumeroSignalement = signa.nosig    // besoin pour mise à jour lienLot
            .
            mError:createInfoRowid(rowid(signa)).        // enregistrement créé, permet de renvoyer le rowid en réponse.
            /*--> Recherche du prochain n° d'Inter */
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last inter no-lock no-error.
            viNextIntervention = if available inter then inter.noint + 1 else 1.
            create inter.
            assign
                inter.noref = integer(if vhbtt::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                inter.noint = viNextIntervention
                inter.nosig = viNextSignalement
                inter.CdSta = {&STATUTINTERVENTION-initie}
                inter.CdArt = "00000"
                inter.QtInt = 1 // THK : L'utilisateur n'ayant pas de browse de saisie dans la nouvelle ergo il faut forcer la quantité à 1 pour garder une compatibilité des données avec l'ancienne ergonomie.
                inter.tpPar = vhbtt::cCodeRoleSignalant
                inter.noPar = vhbtt::iNumeroSignalant
                inter.tpCon = vhbtt::cTypeMandat
                inter.noCon = vhbtt::iNumeroMandat
                inter.lbCom = vhbtt::cCommentaireIntervention
                inter.lbInt = vhbtt::cLibelleIntervention
                inter.cdcsy = mtoken:cUser
                inter.DtCsy = today
                inter.HeCsy = mtime
            .
            /*--> Creation des historiques de traitements */
            /*--> Recherche prochain n° traitement sur l'intervention */
            find last trint no-lock
                where trint.noint = inter.NoInt no-error.
            viNextTraitement = if available trint then trint.noidt + 1 else 1.
            create trint.
            assign
                trint.noint = viNextIntervention
                trint.noidt = viNextTraitement
                trint.notrt = viNextSignalement
                trint.noref = integer(if vhbtt::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                trint.tptrt = {&TYPEINTERVENTION-signalement}
                trint.cdsta = inter.CdSta
                trint.lbcom = outilTraduction:getLibelle({&ACTION-creation})
                trint.cdcsy = mtoken:cUser
                trint.dtcsy = today
                trint.hecsy = mtime
            .
        end.
    end.
    run destroy in ghTiers.

end procedure.

procedure updateSignalement:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beSignalement.cls
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phtt.

    define variable vhbtt               as handle    no-undo.
    define variable vhqtt               as handle    no-undo.
    define variable viNextTraitement    as integer   no-undo.
    define variable vcLibelleMandat     as character no-undo.
    define variable vcLibelleImmeuble   as character no-undo.

    define buffer trInt for trInt.
    define buffer signa for signa.
    define buffer inter for inter.

    vhbtt = phtt:default-buffer-handle.
    create query vhqtt.
    vhqtt:set-buffers(vhbtt).
    vhqtt:query-prepare(substitute('for each &1 where &1.CRUD="U"', vhbtt:name)).
    vhqtt:query-open().

    run tiers/tiers.p persistent set ghTiers.
    run getTokenInstance in ghTiers (mToken:JSessionId).

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhqtt:get-next().
            if vhqtt:query-off-end then leave blocRepeat.

            find first signa exclusive-lock
                 where rowid(signa) = vhbtt::rRowidSigna no-wait no-error.
            if outils:isUpdated(buffer signa:handle, 'signa: ', string(vhbtt::iNumeroSignalement), vhbtt::dtTimestampSigna)
            or not controleSignalement(vhbtt, output vcLibelleMandat, output vcLibelleImmeuble)
            then undo blocTransaction, leave blocTransaction.

            assign
                signa.mdsig     = vhbtt::cCodeMode
                signa.lbdiv1    = vhbtt::cCodeTheme
                signa.tpidt-fac = ""  /* La zone n'est pas visible dans le proto */
                signa.noidt-fac = 0   /* La zone n'est pas visible dans le proto */
                signa.cdmsy     = mtoken:cUser
                signa.dtmsy     = today
                signa.hemsy     = mtime
            .
            find first inter exclusive-lock
                 where rowid(inter) = vhbtt::rRowidInter no-wait no-error.
            if outils:isUpdated(buffer inter:handle, 'inter: ', string(vhbtt::iNumeroIntervention), vhbtt::dtTimestampInter)
            then undo blocTransaction, leave blocTransaction.

            assign
                inter.CdArt = "00000"
                inter.tpPar = vhbtt::cCodeRoleSignalant
                inter.noPar = vhbtt::iNumeroSignalant
                inter.tpCon = vhbtt::cTypeMandat
                inter.noCon = vhbtt::iNumeroMandat
                inter.lbCom = vhbtt::cCommentaireIntervention
                inter.lbInt = vhbtt::cLibelleIntervention
                inter.cdmsy = mtoken:cUser
                inter.dtmsy = today
                inter.hemsy = mtime
            .
            /*--> Creation des historiques de traitements */
            for each inter no-lock
                where inter.nosig = signa.nosig:
                /*--> Recherche prochain n° traitement sur l'intervention */
                find last trint no-lock
                    where trint.noint = inter.NoInt no-error.
                viNextTraitement = if available trint then trint.noidt + 1 else 1.
                create TrInt.
                assign
                    TrInt.noref = integer(if vhbtt::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                    TrInt.noint = inter.NoInt
                    Trint.noidt = viNextTraitement
                    TrInt.tptrt = {&TYPEINTERVENTION-signalement}
                    TrInt.cdsta = inter.CdSta
                    TrInt.notrt = signa.nosig
                    TrInt.lbcom = outilTraduction:getLibelle({&ACTION-modification})
                    TrInt.cdcsy = mtoken:cUser
                    TrInt.dtcsy = today
                    TrInt.hecsy = mtime
                .
            end.
        end.
    end.
    run destroy in ghTiers.

end procedure.

procedure deleteSignalement:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beSignalement.cls
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable viNumeroTraitement as int64 no-undo.

    define buffer inter for inter.
    define buffer trint for trint.
    define buffer dtlot for dtlot.
    define buffer signa for signa.

    viNumeroTraitement = poCollection:getInt64("iNumeroTraitement").
    if controleDeleteSignalement(viNumeroTraitement)
    then do transaction:
        /*--> Suppression des interventions */
        for each inter exclusive-lock
            where inter.nosig = viNumeroTraitement:
            delete inter.
        end.
        /*--> Suppression des traitements */
        for each trint exclusive-lock
            where trint.tptrt = {&TYPEINTERVENTION-signalement}
              and trint.notrt = viNumeroTraitement:
            delete trint.
        end.
        /*--> Suppression des 'lot' */
        for each dtlot exclusive-lock
            where dtlot.tptrt = {&TYPEINTERVENTION-signalement}
              and dtlot.notrt = viNumeroTraitement:
            delete dtlot.
        end.
        /*--> Suppression du signalement */
        for first signa exclusive-lock
            where signa.nosig = viNumeroTraitement:
            delete signa.
        end.
    end.

end procedure.
