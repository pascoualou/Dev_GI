/*------------------------------------------------------------------------
File        : ilibsolv_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table ilibsolv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/ilibsolv.i}
{application/include/error.i}
define variable ghttilibsolv as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phLibsolv-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libsolv-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libsolv-cd' then phLibsolv-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibsolv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibsolv.
    run updateIlibsolv.
    run createIlibsolv.
end procedure.

procedure setIlibsolv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibsolv.
    ghttIlibsolv = phttIlibsolv.
    run crudIlibsolv.
    delete object phttIlibsolv.
end procedure.

procedure readIlibsolv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibsolv Liste des libelles de solvabilite
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibsolv-cd as integer    no-undo.
    define input parameter table-handle phttIlibsolv.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibsolv for ilibsolv.

    vhttBuffer = phttIlibsolv:default-buffer-handle.
    for first ilibsolv no-lock
        where ilibsolv.libsolv-cd = piLibsolv-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibsolv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibsolv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibsolv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibsolv Liste des libelles de solvabilite
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibsolv.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibsolv for ilibsolv.

    vhttBuffer = phttIlibsolv:default-buffer-handle.
    for each ilibsolv no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibsolv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibsolv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibsolv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibsolv-cd    as handle  no-undo.
    define buffer ilibsolv for ilibsolv.

    create query vhttquery.
    vhttBuffer = ghttIlibsolv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibsolv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibsolv-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibsolv exclusive-lock
                where rowid(ilibsolv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibsolv:handle, 'libsolv-cd: ', substitute('&1', vhLibsolv-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibsolv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibsolv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibsolv for ilibsolv.

    create query vhttquery.
    vhttBuffer = ghttIlibsolv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibsolv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibsolv.
            if not outils:copyValidField(buffer ilibsolv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibsolv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibsolv-cd    as handle  no-undo.
    define buffer ilibsolv for ilibsolv.

    create query vhttquery.
    vhttBuffer = ghttIlibsolv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibsolv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibsolv-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibsolv exclusive-lock
                where rowid(Ilibsolv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibsolv:handle, 'libsolv-cd: ', substitute('&1', vhLibsolv-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibsolv no-error.
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

