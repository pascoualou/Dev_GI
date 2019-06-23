/*------------------------------------------------------------------------
File        : indcl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table indcl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/indcl.i}
{application/include/error.i}
define variable ghttindcl as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdind as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdind, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdind' then phCdind = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIndcl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIndcl.
    run updateIndcl.
    run createIndcl.
end procedure.

procedure setIndcl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndcl.
    ghttIndcl = phttIndcl.
    run crudIndcl.
    delete object phttIndcl.
end procedure.

procedure readIndcl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table indcl Indices de révision CLIENTS
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdind as character  no-undo.
    define input parameter table-handle phttIndcl.
    define variable vhttBuffer as handle no-undo.
    define buffer indcl for indcl.

    vhttBuffer = phttIndcl:default-buffer-handle.
    for first indcl no-lock
        where indcl.cdind = pcCdind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indcl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndcl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIndcl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table indcl Indices de révision CLIENTS
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndcl.
    define variable vhttBuffer as handle  no-undo.
    define buffer indcl for indcl.

    vhttBuffer = phttIndcl:default-buffer-handle.
    for each indcl no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indcl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndcl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIndcl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdind    as handle  no-undo.
    define buffer indcl for indcl.

    create query vhttquery.
    vhttBuffer = ghttIndcl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIndcl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdind).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indcl exclusive-lock
                where rowid(indcl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indcl:handle, 'cdind: ', substitute('&1', vhCdind:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer indcl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIndcl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer indcl for indcl.

    create query vhttquery.
    vhttBuffer = ghttIndcl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIndcl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create indcl.
            if not outils:copyValidField(buffer indcl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIndcl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdind    as handle  no-undo.
    define buffer indcl for indcl.

    create query vhttquery.
    vhttBuffer = ghttIndcl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIndcl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdind).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indcl exclusive-lock
                where rowid(Indcl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indcl:handle, 'cdind: ', substitute('&1', vhCdind:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete indcl no-error.
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

