/*------------------------------------------------------------------------
File        : indtx_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table indtx
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/indtx.i}
{application/include/error.i}
define variable ghttindtx as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdind as handle, output phAnper as handle, output phNoper as handle, output phAnpe0 as handle, output phNope0 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdind/anper/noper/anpe0/nope0, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdind' then phCdind = phBuffer:buffer-field(vi).
            when 'anper' then phAnper = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
            when 'anpe0' then phAnpe0 = phBuffer:buffer-field(vi).
            when 'nope0' then phNope0 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIndtx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIndtx.
    run updateIndtx.
    run createIndtx.
end procedure.

procedure setIndtx:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndtx.
    ghttIndtx = phttIndtx.
    run crudIndtx.
    delete object phttIndtx.
end procedure.

procedure readIndtx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table indtx 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdind as character  no-undo.
    define input parameter piAnper as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piAnpe0 as integer    no-undo.
    define input parameter piNope0 as integer    no-undo.
    define input parameter table-handle phttIndtx.
    define variable vhttBuffer as handle no-undo.
    define buffer indtx for indtx.

    vhttBuffer = phttIndtx:default-buffer-handle.
    for first indtx no-lock
        where indtx.cdind = pcCdind
          and indtx.anper = piAnper
          and indtx.noper = piNoper
          and indtx.anpe0 = piAnpe0
          and indtx.nope0 = piNope0:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indtx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndtx no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIndtx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table indtx 
    Notes  : service externe. Critère piAnpe0 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdind as character  no-undo.
    define input parameter piAnper as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piAnpe0 as integer    no-undo.
    define input parameter table-handle phttIndtx.
    define variable vhttBuffer as handle  no-undo.
    define buffer indtx for indtx.

    vhttBuffer = phttIndtx:default-buffer-handle.
    if piAnpe0 = ?
    then for each indtx no-lock
        where indtx.cdind = pcCdind
          and indtx.anper = piAnper
          and indtx.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indtx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each indtx no-lock
        where indtx.cdind = pcCdind
          and indtx.anper = piAnper
          and indtx.noper = piNoper
          and indtx.anpe0 = piAnpe0:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indtx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndtx no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIndtx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdind    as handle  no-undo.
    define variable vhAnper    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhAnpe0    as handle  no-undo.
    define variable vhNope0    as handle  no-undo.
    define buffer indtx for indtx.

    create query vhttquery.
    vhttBuffer = ghttIndtx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIndtx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdind, output vhAnper, output vhNoper, output vhAnpe0, output vhNope0).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indtx exclusive-lock
                where rowid(indtx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indtx:handle, 'cdind/anper/noper/anpe0/nope0: ', substitute('&1/&2/&3/&4/&5', vhCdind:buffer-value(), vhAnper:buffer-value(), vhNoper:buffer-value(), vhAnpe0:buffer-value(), vhNope0:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer indtx:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIndtx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer indtx for indtx.

    create query vhttquery.
    vhttBuffer = ghttIndtx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIndtx:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create indtx.
            if not outils:copyValidField(buffer indtx:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIndtx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdind    as handle  no-undo.
    define variable vhAnper    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhAnpe0    as handle  no-undo.
    define variable vhNope0    as handle  no-undo.
    define buffer indtx for indtx.

    create query vhttquery.
    vhttBuffer = ghttIndtx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIndtx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdind, output vhAnper, output vhNoper, output vhAnpe0, output vhNope0).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indtx exclusive-lock
                where rowid(Indtx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indtx:handle, 'cdind/anper/noper/anpe0/nope0: ', substitute('&1/&2/&3/&4/&5', vhCdind:buffer-value(), vhAnper:buffer-value(), vhNoper:buffer-value(), vhAnpe0:buffer-value(), vhNope0:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete indtx no-error.
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

