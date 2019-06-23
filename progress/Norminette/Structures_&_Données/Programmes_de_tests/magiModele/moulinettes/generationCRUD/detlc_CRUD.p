/*------------------------------------------------------------------------
File        : detlc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table detlc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/detlc.i}
{application/include/error.i}
define variable ghttdetlc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoapp as handle, output phNorub as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noapp/norub, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'norub' then phNorub = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDetlc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDetlc.
    run updateDetlc.
    run createDetlc.
end procedure.

procedure setDetlc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDetlc.
    ghttDetlc = phttDetlc.
    run crudDetlc.
    delete object phttDetlc.
end procedure.

procedure readDetlc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table detlc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter table-handle phttDetlc.
    define variable vhttBuffer as handle no-undo.
    define buffer detlc for detlc.

    vhttBuffer = phttDetlc:default-buffer-handle.
    for first detlc no-lock
        where detlc.tpcon = pcTpcon
          and detlc.nocon = piNocon
          and detlc.noapp = piNoapp
          and detlc.norub = piNorub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detlc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDetlc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDetlc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table detlc 
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttDetlc.
    define variable vhttBuffer as handle  no-undo.
    define buffer detlc for detlc.

    vhttBuffer = phttDetlc:default-buffer-handle.
    if piNoapp = ?
    then for each detlc no-lock
        where detlc.tpcon = pcTpcon
          and detlc.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detlc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each detlc no-lock
        where detlc.tpcon = pcTpcon
          and detlc.nocon = piNocon
          and detlc.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detlc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDetlc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDetlc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define buffer detlc for detlc.

    create query vhttquery.
    vhttBuffer = ghttDetlc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDetlc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoapp, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first detlc exclusive-lock
                where rowid(detlc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer detlc:handle, 'tpcon/nocon/noapp/norub: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoapp:buffer-value(), vhNorub:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer detlc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDetlc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer detlc for detlc.

    create query vhttquery.
    vhttBuffer = ghttDetlc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDetlc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create detlc.
            if not outils:copyValidField(buffer detlc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDetlc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define buffer detlc for detlc.

    create query vhttquery.
    vhttBuffer = ghttDetlc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDetlc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoapp, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first detlc exclusive-lock
                where rowid(Detlc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer detlc:handle, 'tpcon/nocon/noapp/norub: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoapp:buffer-value(), vhNorub:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete detlc no-error.
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

