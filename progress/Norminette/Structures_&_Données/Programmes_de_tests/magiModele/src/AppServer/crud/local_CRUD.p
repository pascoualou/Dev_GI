/*------------------------------------------------------------------------
File        : local_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table local
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
              repris depuis adb/lib/l_local.p
derniere revue: 2018/09/13 - phm: OK
        todo   attention lot_crud est sensé travailler sur local aussi !!! fusionner les programmes
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2contrat.i}

{oerealm/include/instanciateTokenOnModel.i}          // Doit être positionnée juste après using
define variable ghttlocal    as handle no-undo.      // le handle de la temp table à mettre à jour
define variable ghProcAlimaj as handle no-undo.

function getIndexField returns logical private(phBuffer as handle, output phNoloc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noloc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

function getNextLocal returns integer private():
    /* -----------------------------------------------------------------------
    Purpose: Fonction pour récupérer le prochain numéro de local
    Notes  :
    ------------------------------------------------------------------------*/
    define variable viLocalSuivant as integer no-undo.

    viLocalSuivant = next-value(sq_NoLoc01).
    // ON ATTEIND LA BORNE MAXIMALE
    if viLocalSuivant = ? then mError:createError({&error}, 1).
    return viLocalSuivant.

end function.

procedure crudLocal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLocal.
    run updateLocal.
    run createLocal.
end procedure.

procedure setLocal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLocal.
    ghttLocal = phttLocal.
    run application/transfert/GI_alimaj.p persistent set ghProcAlimaj.
    run getTokenInstance in ghProcAlimaj(mToken:JSessionId).
    run crudLocal.
    run destroy in ghProcAlimaj no-error. 
    delete object phttLocal.
end procedure.

procedure readLocal:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table local 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64   no-undo.
    define input parameter table-handle phttLocal.

    define variable vhttBuffer as handle no-undo.
    define buffer local for local.

    vhttBuffer = phttLocal:default-buffer-handle.
    for first local no-lock
        where local.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer local:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLocal no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure readLocalImmeubleLot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table local 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer  no-undo.
    define input parameter piNolot as integer  no-undo.
    define input parameter table-handle phttLocal.

    define variable vhttBuffer as handle no-undo.
    define buffer local for local.

    vhttBuffer = phttLocal:default-buffer-handle.
    for first local no-lock
        where local.noimm = piNoimm
          and local.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer local:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLocal no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLocal:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table local 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer  no-undo.
    define input parameter table-handle phttLocal.
    define variable vhttBuffer as handle  no-undo.
    define buffer local for local.

    vhttBuffer = phttLocal:default-buffer-handle.
    for each local no-lock
        where local.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer local:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLocal no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLocal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer local for local.

    create query vhttquery.
    vhttBuffer = ghttLocal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLocal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first local exclusive-lock
                where rowid(local) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer local:handle, 'noloc: ', substitute('&1', vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer local:handle, vhttBuffer, "", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            run majTabTrf(local.noloc, local.noimm). 
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLocal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle no-undo.
    define variable vhttBuffer as handle no-undo.
    define variable vhNoloc    as handle no-undo.
    define buffer local for local.

    create query vhttquery.
    vhttBuffer = ghttLocal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLocal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc).

blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            assign vhNoloc:buffer-value() = getNextLocal() no-error.
            if error-status:error then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
            create local.
            if not outils:copyValidField(buffer local:handle, vhttBuffer, "", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            run majTabTrf(local.noloc, local.noimm). 
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLocal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer local for local.

    create query vhttquery.
    vhttBuffer = ghttLocal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLocal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first local exclusive-lock
                where rowid(Local) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer local:handle, 'noloc: ', substitute('&1', vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete local no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure majTabTrf private:
    /*------------------------------------------------------------------------------
    Purpose: mise a jour table pour les transferts
    Notes  : local.noloc
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroLocal    as int64 no-undo.
    define input  parameter piNumeroImmeuble as int64 no-undo.

    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}     /* Mandat Gerance */
          and intnt.tpidt = {&TYPEBIEN-lot}                   /* Local */
          and intnt.noidt = piNumeroLocal
      , first ctrat no-lock 
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        run majTrace in ghProcAlimaj(integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
    end.
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}     /* Mandat Copro   */
          and intnt.tpidt = {&TYPEBIEN-immeuble}             /* immeuble */
          and intnt.noidt = piNumeroImmeuble
      , first ctrat no-lock 
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and ctrat.ntcon <> {&NATURECONTRAT-residenceLocataire}:
        run majTrace in ghProcAlimaj(integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
    end.

end procedure.
