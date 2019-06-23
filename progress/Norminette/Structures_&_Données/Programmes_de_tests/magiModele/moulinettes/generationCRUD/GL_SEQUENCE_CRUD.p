/*------------------------------------------------------------------------
File        : GL_SEQUENCE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_SEQUENCE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_SEQUENCE.i}
{application/include/error.i}
define variable ghttGL_SEQUENCE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosequence as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosequence, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosequence' then phNosequence = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_sequence private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_sequence.
    run updateGl_sequence.
    run createGl_sequence.
end procedure.

procedure setGl_sequence:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_sequence.
    ghttGl_sequence = phttGl_sequence.
    run crudGl_sequence.
    delete object phttGl_sequence.
end procedure.

procedure readGl_sequence:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_SEQUENCE 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosequence as integer    no-undo.
    define input parameter table-handle phttGl_sequence.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_SEQUENCE for GL_SEQUENCE.

    vhttBuffer = phttGl_sequence:default-buffer-handle.
    for first GL_SEQUENCE no-lock
        where GL_SEQUENCE.nosequence = piNosequence:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_SEQUENCE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_sequence no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_sequence:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_SEQUENCE 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_sequence.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_SEQUENCE for GL_SEQUENCE.

    vhttBuffer = phttGl_sequence:default-buffer-handle.
    for each GL_SEQUENCE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_SEQUENCE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_sequence no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_sequence private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosequence    as handle  no-undo.
    define buffer GL_SEQUENCE for GL_SEQUENCE.

    create query vhttquery.
    vhttBuffer = ghttGl_sequence:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_sequence:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosequence).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_SEQUENCE exclusive-lock
                where rowid(GL_SEQUENCE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_SEQUENCE:handle, 'nosequence: ', substitute('&1', vhNosequence:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_SEQUENCE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_sequence private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_SEQUENCE for GL_SEQUENCE.

    create query vhttquery.
    vhttBuffer = ghttGl_sequence:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_sequence:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_SEQUENCE.
            if not outils:copyValidField(buffer GL_SEQUENCE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_sequence private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosequence    as handle  no-undo.
    define buffer GL_SEQUENCE for GL_SEQUENCE.

    create query vhttquery.
    vhttBuffer = ghttGl_sequence:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_sequence:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosequence).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_SEQUENCE exclusive-lock
                where rowid(Gl_sequence) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_SEQUENCE:handle, 'nosequence: ', substitute('&1', vhNosequence:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_SEQUENCE no-error.
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

