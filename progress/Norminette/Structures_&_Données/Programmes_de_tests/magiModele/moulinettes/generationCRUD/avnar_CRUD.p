/*------------------------------------------------------------------------
File        : avnar_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table avnar
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/avnar.i}
{application/include/error.i}
define variable ghttavnar as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoann as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noann, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noann' then phNoann = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAvnar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAvnar.
    run updateAvnar.
    run createAvnar.
end procedure.

procedure setAvnar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAvnar.
    ghttAvnar = phttAvnar.
    run crudAvnar.
    delete object phttAvnar.
end procedure.

procedure readAvnar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table avnar Avantages en nature (entete)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoann as integer    no-undo.
    define input parameter table-handle phttAvnar.
    define variable vhttBuffer as handle no-undo.
    define buffer avnar for avnar.

    vhttBuffer = phttAvnar:default-buffer-handle.
    for first avnar no-lock
        where avnar.noann = piNoann:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer avnar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAvnar no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAvnar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table avnar Avantages en nature (entete)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAvnar.
    define variable vhttBuffer as handle  no-undo.
    define buffer avnar for avnar.

    vhttBuffer = phttAvnar:default-buffer-handle.
    for each avnar no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer avnar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAvnar no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAvnar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoann    as handle  no-undo.
    define buffer avnar for avnar.

    create query vhttquery.
    vhttBuffer = ghttAvnar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAvnar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoann).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first avnar exclusive-lock
                where rowid(avnar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer avnar:handle, 'noann: ', substitute('&1', vhNoann:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer avnar:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAvnar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer avnar for avnar.

    create query vhttquery.
    vhttBuffer = ghttAvnar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAvnar:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create avnar.
            if not outils:copyValidField(buffer avnar:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAvnar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoann    as handle  no-undo.
    define buffer avnar for avnar.

    create query vhttquery.
    vhttBuffer = ghttAvnar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAvnar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoann).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first avnar exclusive-lock
                where rowid(Avnar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer avnar:handle, 'noann: ', substitute('&1', vhNoann:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete avnar no-error.
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

