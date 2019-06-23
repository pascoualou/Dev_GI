/*------------------------------------------------------------------------
File        : mutexo_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table mutexo
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/mutexo.i}
{application/include/error.i}
define variable ghttmutexo as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoexo as handle, output phNoper as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noexo/noper, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMutexo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMutexo.
    run updateMutexo.
    run createMutexo.
end procedure.

procedure setMutexo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMutexo.
    ghttMutexo = phttMutexo.
    run crudMutexo.
    delete object phttMutexo.
end procedure.

procedure readMutexo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table mutexo Suivi des mutations par exercice
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter table-handle phttMutexo.
    define variable vhttBuffer as handle no-undo.
    define buffer mutexo for mutexo.

    vhttBuffer = phttMutexo:default-buffer-handle.
    for first mutexo no-lock
        where mutexo.tpcon = pcTpcon
          and mutexo.nocon = piNocon
          and mutexo.noexo = piNoexo
          and mutexo.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mutexo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMutexo no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMutexo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table mutexo Suivi des mutations par exercice
    Notes  : service externe. Critère piNoexo = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter table-handle phttMutexo.
    define variable vhttBuffer as handle  no-undo.
    define buffer mutexo for mutexo.

    vhttBuffer = phttMutexo:default-buffer-handle.
    if piNoexo = ?
    then for each mutexo no-lock
        where mutexo.tpcon = pcTpcon
          and mutexo.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mutexo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each mutexo no-lock
        where mutexo.tpcon = pcTpcon
          and mutexo.nocon = piNocon
          and mutexo.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mutexo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMutexo no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMutexo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer mutexo for mutexo.

    create query vhttquery.
    vhttBuffer = ghttMutexo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMutexo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first mutexo exclusive-lock
                where rowid(mutexo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer mutexo:handle, 'tpcon/nocon/noexo/noper: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer mutexo:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMutexo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer mutexo for mutexo.

    create query vhttquery.
    vhttBuffer = ghttMutexo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMutexo:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create mutexo.
            if not outils:copyValidField(buffer mutexo:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMutexo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer mutexo for mutexo.

    create query vhttquery.
    vhttBuffer = ghttMutexo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMutexo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first mutexo exclusive-lock
                where rowid(Mutexo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer mutexo:handle, 'tpcon/nocon/noexo/noper: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete mutexo no-error.
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

