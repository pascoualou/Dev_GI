/*-----------------------------------------------------------------------------
File        : erldt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table erldt
Author(s)   : generation automatique le 01/31/18 + modifications SPo 03/22/18 
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/04/12 - phm: OK
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghtterldt as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNorli as handle, output phNolot as handle, output phNocpt as handle, output phNocop as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norli/nolot/nocpt/nocop, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'norli' then phNorli = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'nocpt' then phNocpt = phBuffer:buffer-field(vi).
            when 'nocop' then phNocop = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudErldt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteErldt.
    run updateErldt.
    run createErldt.
end procedure.

procedure setErldt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttErldt.
    ghttErldt = phttErldt.
    run crudErldt.
    delete object phttErldt.
end procedure.

procedure readErldt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table erldt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorli as integer   no-undo.
    define input parameter piNolot as integer   no-undo.
    define input parameter pcNocpt as character no-undo.
    define input parameter piNocop as integer   no-undo.
    define input parameter table-handle phttErldt.
    define variable vhttBuffer as handle no-undo.
    define buffer erldt for erldt.

    vhttBuffer = phttErldt:default-buffer-handle.
    for first erldt no-lock
        where erldt.norli = piNorli
          and erldt.nolot = piNolot
          and erldt.nocpt = pcNocpt
          and erldt.nocop = piNocop:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erldt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttErldt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getErldt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table erldt 
    Notes  : service externe. Critère pcNocpt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNorli as integer   no-undo.
    define input parameter piNolot as integer   no-undo.
    define input parameter pcNocpt as character no-undo.
    define input parameter table-handle phttErldt.
    define variable vhttBuffer as handle  no-undo.
    define buffer erldt for erldt.

    vhttBuffer = phttErldt:default-buffer-handle.
    if pcNocpt = ?
    then for each erldt no-lock
        where erldt.norli = piNorli
          and erldt.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erldt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each erldt no-lock
        where erldt.norli = piNorli
          and erldt.nolot = piNolot
          and erldt.nocpt = pcNocpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erldt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttErldt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateErldt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNorli    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocpt    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer erldt for erldt.

    create query vhttquery.
    vhttBuffer = ghttErldt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttErldt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorli, output vhNolot, output vhNocpt, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first erldt exclusive-lock
                where rowid(erldt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer erldt:handle, 'norli/nolot/nocpt/nocop: ', substitute('&1/&2/&3/&4', vhNorli:buffer-value(), vhNolot:buffer-value(), vhNocpt:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer erldt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createErldt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer erldt for erldt.

    create query vhttquery.
    vhttBuffer = ghttErldt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttErldt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create erldt.
            if not outils:copyValidField(buffer erldt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteErldt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNorli    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocpt    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer erldt for erldt.

    create query vhttquery.
    vhttBuffer = ghttErldt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttErldt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorli, output vhNolot, output vhNocpt, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first erldt exclusive-lock
                where rowid(Erldt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer erldt:handle, 'norli/nolot/nocpt/nocop: ', substitute('&1/&2/&3/&4', vhNorli:buffer-value(), vhNolot:buffer-value(), vhNocpt:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete erldt no-error.
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
