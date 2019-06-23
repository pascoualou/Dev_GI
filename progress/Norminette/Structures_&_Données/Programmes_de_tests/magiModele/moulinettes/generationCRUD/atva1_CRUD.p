/*------------------------------------------------------------------------
File        : atva1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table atva1
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/atva1.i}
{application/include/error.i}
define variable ghttatva1 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofor as handle, output phNocha as handle, output phNosch as handle, output phNorub as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nofor/nocha/nosch/norub, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nofor' then phNofor = phBuffer:buffer-field(vi).
            when 'nocha' then phNocha = phBuffer:buffer-field(vi).
            when 'nosch' then phNosch = phBuffer:buffer-field(vi).
            when 'norub' then phNorub = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAtva1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAtva1.
    run updateAtva1.
    run createAtva1.
end procedure.

procedure setAtva1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAtva1.
    ghttAtva1 = phttAtva1.
    run crudAtva1.
    delete object phttAtva1.
end procedure.

procedure readAtva1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table atva1 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofor as integer    no-undo.
    define input parameter piNocha as integer    no-undo.
    define input parameter piNosch as integer    no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter table-handle phttAtva1.
    define variable vhttBuffer as handle no-undo.
    define buffer atva1 for atva1.

    vhttBuffer = phttAtva1:default-buffer-handle.
    for first atva1 no-lock
        where atva1.nofor = piNofor
          and atva1.nocha = piNocha
          and atva1.nosch = piNosch
          and atva1.norub = piNorub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtva1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAtva1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table atva1 
    Notes  : service externe. Critère piNosch = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNofor as integer    no-undo.
    define input parameter piNocha as integer    no-undo.
    define input parameter piNosch as integer    no-undo.
    define input parameter table-handle phttAtva1.
    define variable vhttBuffer as handle  no-undo.
    define buffer atva1 for atva1.

    vhttBuffer = phttAtva1:default-buffer-handle.
    if piNosch = ?
    then for each atva1 no-lock
        where atva1.nofor = piNofor
          and atva1.nocha = piNocha:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each atva1 no-lock
        where atva1.nofor = piNofor
          and atva1.nocha = piNocha
          and atva1.nosch = piNosch:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtva1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAtva1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofor    as handle  no-undo.
    define variable vhNocha    as handle  no-undo.
    define variable vhNosch    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define buffer atva1 for atva1.

    create query vhttquery.
    vhttBuffer = ghttAtva1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAtva1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofor, output vhNocha, output vhNosch, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atva1 exclusive-lock
                where rowid(atva1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atva1:handle, 'nofor/nocha/nosch/norub: ', substitute('&1/&2/&3/&4', vhNofor:buffer-value(), vhNocha:buffer-value(), vhNosch:buffer-value(), vhNorub:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer atva1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAtva1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer atva1 for atva1.

    create query vhttquery.
    vhttBuffer = ghttAtva1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAtva1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create atva1.
            if not outils:copyValidField(buffer atva1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAtva1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofor    as handle  no-undo.
    define variable vhNocha    as handle  no-undo.
    define variable vhNosch    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define buffer atva1 for atva1.

    create query vhttquery.
    vhttBuffer = ghttAtva1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAtva1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofor, output vhNocha, output vhNosch, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atva1 exclusive-lock
                where rowid(Atva1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atva1:handle, 'nofor/nocha/nosch/norub: ', substitute('&1/&2/&3/&4', vhNofor:buffer-value(), vhNocha:buffer-value(), vhNosch:buffer-value(), vhNorub:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete atva1 no-error.
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

