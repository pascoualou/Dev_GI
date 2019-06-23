/*------------------------------------------------------------------------
File        : svgepaie_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table svgepaie
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/svgepaie.i}
{application/include/error.i}
define variable ghttsvgepaie as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosvg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosvg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosvg' then phNosvg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSvgepaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSvgepaie.
    run updateSvgepaie.
    run createSvgepaie.
end procedure.

procedure setSvgepaie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSvgepaie.
    ghttSvgepaie = phttSvgepaie.
    run crudSvgepaie.
    delete object phttSvgepaie.
end procedure.

procedure readSvgepaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table svgepaie 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosvg as integer    no-undo.
    define input parameter table-handle phttSvgepaie.
    define variable vhttBuffer as handle no-undo.
    define buffer svgepaie for svgepaie.

    vhttBuffer = phttSvgepaie:default-buffer-handle.
    for first svgepaie no-lock
        where svgepaie.nosvg = piNosvg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svgepaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvgepaie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSvgepaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table svgepaie 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSvgepaie.
    define variable vhttBuffer as handle  no-undo.
    define buffer svgepaie for svgepaie.

    vhttBuffer = phttSvgepaie:default-buffer-handle.
    for each svgepaie no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svgepaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvgepaie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSvgepaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosvg    as handle  no-undo.
    define buffer svgepaie for svgepaie.

    create query vhttquery.
    vhttBuffer = ghttSvgepaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSvgepaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosvg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first svgepaie exclusive-lock
                where rowid(svgepaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer svgepaie:handle, 'nosvg: ', substitute('&1', vhNosvg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer svgepaie:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSvgepaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer svgepaie for svgepaie.

    create query vhttquery.
    vhttBuffer = ghttSvgepaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSvgepaie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create svgepaie.
            if not outils:copyValidField(buffer svgepaie:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSvgepaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosvg    as handle  no-undo.
    define buffer svgepaie for svgepaie.

    create query vhttquery.
    vhttBuffer = ghttSvgepaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSvgepaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosvg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first svgepaie exclusive-lock
                where rowid(Svgepaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer svgepaie:handle, 'nosvg: ', substitute('&1', vhNosvg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete svgepaie no-error.
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

