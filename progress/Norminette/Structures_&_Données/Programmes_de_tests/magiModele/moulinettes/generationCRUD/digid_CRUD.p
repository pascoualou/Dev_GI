/*------------------------------------------------------------------------
File        : digid_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table digid
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/digid.i}
{application/include/error.i}
define variable ghttdigid as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phCdbat as handle, output phNodig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/cdbat/nodig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'cdbat' then phCdbat = phBuffer:buffer-field(vi).
            when 'nodig' then phNodig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDigid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDigid.
    run updateDigid.
    run createDigid.
end procedure.

procedure setDigid:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDigid.
    ghttDigid = phttDigid.
    run crudDigid.
    delete object phttDigid.
end procedure.

procedure readDigid:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table digid 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcCdbat as character  no-undo.
    define input parameter piNodig as integer    no-undo.
    define input parameter table-handle phttDigid.
    define variable vhttBuffer as handle no-undo.
    define buffer digid for digid.

    vhttBuffer = phttDigid:default-buffer-handle.
    for first digid no-lock
        where digid.noimm = piNoimm
          and digid.cdbat = pcCdbat
          and digid.nodig = piNodig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer digid:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDigid no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDigid:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table digid 
    Notes  : service externe. Critère pcCdbat = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcCdbat as character  no-undo.
    define input parameter table-handle phttDigid.
    define variable vhttBuffer as handle  no-undo.
    define buffer digid for digid.

    vhttBuffer = phttDigid:default-buffer-handle.
    if pcCdbat = ?
    then for each digid no-lock
        where digid.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer digid:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each digid no-lock
        where digid.noimm = piNoimm
          and digid.cdbat = pcCdbat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer digid:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDigid no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDigid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhCdbat    as handle  no-undo.
    define variable vhNodig    as handle  no-undo.
    define buffer digid for digid.

    create query vhttquery.
    vhttBuffer = ghttDigid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDigid:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhCdbat, output vhNodig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first digid exclusive-lock
                where rowid(digid) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer digid:handle, 'noimm/cdbat/nodig: ', substitute('&1/&2/&3', vhNoimm:buffer-value(), vhCdbat:buffer-value(), vhNodig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer digid:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDigid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer digid for digid.

    create query vhttquery.
    vhttBuffer = ghttDigid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDigid:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create digid.
            if not outils:copyValidField(buffer digid:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDigid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhCdbat    as handle  no-undo.
    define variable vhNodig    as handle  no-undo.
    define buffer digid for digid.

    create query vhttquery.
    vhttBuffer = ghttDigid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDigid:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhCdbat, output vhNodig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first digid exclusive-lock
                where rowid(Digid) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer digid:handle, 'noimm/cdbat/nodig: ', substitute('&1/&2/&3', vhNoimm:buffer-value(), vhCdbat:buffer-value(), vhNodig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete digid no-error.
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

