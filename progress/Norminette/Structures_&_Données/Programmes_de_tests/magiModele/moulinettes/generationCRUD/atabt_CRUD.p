/*------------------------------------------------------------------------
File        : atabt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table atabt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/atabt.i}
{application/include/error.i}
define variable ghttatabt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phLib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/lib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'lib' then phLib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAtabt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAtabt.
    run updateAtabt.
    run createAtabt.
end procedure.

procedure setAtabt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAtabt.
    ghttAtabt = phttAtabt.
    run crudAtabt.
    delete object phttAtabt.
end procedure.

procedure readAtabt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table atabt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcLib   as character  no-undo.
    define input parameter table-handle phttAtabt.
    define variable vhttBuffer as handle no-undo.
    define buffer atabt for atabt.

    vhttBuffer = phttAtabt:default-buffer-handle.
    for first atabt no-lock
        where atabt.tppar = pcTppar
          and atabt.lib = pcLib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atabt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtabt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAtabt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table atabt 
    Notes  : service externe. Critère pcTppar = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter table-handle phttAtabt.
    define variable vhttBuffer as handle  no-undo.
    define buffer atabt for atabt.

    vhttBuffer = phttAtabt:default-buffer-handle.
    if pcTppar = ?
    then for each atabt no-lock
        where atabt.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atabt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each atabt no-lock
        where atabt.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atabt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtabt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAtabt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhLib    as handle  no-undo.
    define buffer atabt for atabt.

    create query vhttquery.
    vhttBuffer = ghttAtabt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAtabt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhLib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atabt exclusive-lock
                where rowid(atabt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atabt:handle, 'tppar/lib: ', substitute('&1/&2', vhTppar:buffer-value(), vhLib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer atabt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAtabt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer atabt for atabt.

    create query vhttquery.
    vhttBuffer = ghttAtabt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAtabt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create atabt.
            if not outils:copyValidField(buffer atabt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAtabt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhLib    as handle  no-undo.
    define buffer atabt for atabt.

    create query vhttquery.
    vhttBuffer = ghttAtabt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAtabt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhLib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atabt exclusive-lock
                where rowid(Atabt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atabt:handle, 'tppar/lib: ', substitute('&1/&2', vhTppar:buffer-value(), vhLib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete atabt no-error.
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

