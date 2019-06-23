/*------------------------------------------------------------------------
File        : scindhist_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scindhist
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scindhist.i}
{application/include/error.i}
define variable ghttscindhist as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoind as handle, output phNolgn as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noind/nolgn, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noind' then phNoind = phBuffer:buffer-field(vi).
            when 'nolgn' then phNolgn = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScindhist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScindhist.
    run updateScindhist.
    run createScindhist.
end procedure.

procedure setScindhist:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScindhist.
    ghttScindhist = phttScindhist.
    run crudScindhist.
    delete object phttScindhist.
end procedure.

procedure readScindhist:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scindhist Historisation de la décomposition d'une indivision
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoind as integer    no-undo.
    define input parameter piNolgn as integer    no-undo.
    define input parameter table-handle phttScindhist.
    define variable vhttBuffer as handle no-undo.
    define buffer scindhist for scindhist.

    vhttBuffer = phttScindhist:default-buffer-handle.
    for first scindhist no-lock
        where scindhist.noind = piNoind
          and scindhist.nolgn = piNolgn:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scindhist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScindhist no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScindhist:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scindhist Historisation de la décomposition d'une indivision
    Notes  : service externe. Critère piNoind = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoind as integer    no-undo.
    define input parameter table-handle phttScindhist.
    define variable vhttBuffer as handle  no-undo.
    define buffer scindhist for scindhist.

    vhttBuffer = phttScindhist:default-buffer-handle.
    if piNoind = ?
    then for each scindhist no-lock
        where scindhist.noind = piNoind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scindhist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scindhist no-lock
        where scindhist.noind = piNoind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scindhist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScindhist no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScindhist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoind    as handle  no-undo.
    define variable vhNolgn    as handle  no-undo.
    define buffer scindhist for scindhist.

    create query vhttquery.
    vhttBuffer = ghttScindhist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScindhist:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoind, output vhNolgn).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scindhist exclusive-lock
                where rowid(scindhist) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scindhist:handle, 'noind/nolgn: ', substitute('&1/&2', vhNoind:buffer-value(), vhNolgn:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scindhist:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScindhist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scindhist for scindhist.

    create query vhttquery.
    vhttBuffer = ghttScindhist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScindhist:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scindhist.
            if not outils:copyValidField(buffer scindhist:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScindhist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoind    as handle  no-undo.
    define variable vhNolgn    as handle  no-undo.
    define buffer scindhist for scindhist.

    create query vhttquery.
    vhttBuffer = ghttScindhist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScindhist:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoind, output vhNolgn).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scindhist exclusive-lock
                where rowid(Scindhist) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scindhist:handle, 'noind/nolgn: ', substitute('&1/&2', vhNoind:buffer-value(), vhNolgn:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scindhist no-error.
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

