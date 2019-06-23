/*------------------------------------------------------------------------
File        : DETAF_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DETAF
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DETAF.i}
{application/include/error.i}
define variable ghttDETAF as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodet as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NODET, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NODET' then phNodet = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDetaf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDetaf.
    run updateDetaf.
    run createDetaf.
end procedure.

procedure setDetaf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDetaf.
    ghttDetaf = phttDetaf.
    run crudDetaf.
    delete object phttDetaf.
end procedure.

procedure readDetaf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DETAF 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodet as integer    no-undo.
    define input parameter table-handle phttDetaf.
    define variable vhttBuffer as handle no-undo.
    define buffer DETAF for DETAF.

    vhttBuffer = phttDetaf:default-buffer-handle.
    for first DETAF no-lock
        where DETAF.NODET = piNodet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DETAF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDetaf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDetaf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DETAF 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDetaf.
    define variable vhttBuffer as handle  no-undo.
    define buffer DETAF for DETAF.

    vhttBuffer = phttDetaf:default-buffer-handle.
    for each DETAF no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DETAF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDetaf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDetaf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodet    as handle  no-undo.
    define buffer DETAF for DETAF.

    create query vhttquery.
    vhttBuffer = ghttDetaf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDetaf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodet).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DETAF exclusive-lock
                where rowid(DETAF) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DETAF:handle, 'NODET: ', substitute('&1', vhNodet:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DETAF:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDetaf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DETAF for DETAF.

    create query vhttquery.
    vhttBuffer = ghttDetaf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDetaf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DETAF.
            if not outils:copyValidField(buffer DETAF:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDetaf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodet    as handle  no-undo.
    define buffer DETAF for DETAF.

    create query vhttquery.
    vhttBuffer = ghttDetaf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDetaf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodet).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DETAF exclusive-lock
                where rowid(Detaf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DETAF:handle, 'NODET: ', substitute('&1', vhNodet:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DETAF no-error.
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

