/*------------------------------------------------------------------------
File        : TbFic_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TbFic
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TbFic.i}
{application/include/error.i}
define variable ghttTbFic as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phLbfic as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/LbFic, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'LbFic' then phLbfic = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTbfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTbfic.
    run updateTbfic.
    run createTbfic.
end procedure.

procedure setTbfic:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTbfic.
    ghttTbfic = phttTbfic.
    run crudTbfic.
    delete object phttTbfic.
end procedure.

procedure readTbfic:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TbFic 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcLbfic as character  no-undo.
    define input parameter table-handle phttTbfic.
    define variable vhttBuffer as handle no-undo.
    define buffer TbFic for TbFic.

    vhttBuffer = phttTbfic:default-buffer-handle.
    for first TbFic no-lock
        where TbFic.tpidt = pcTpidt
          and TbFic.noidt = piNoidt
          and TbFic.LbFic = pcLbfic:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TbFic:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbfic no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTbfic:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TbFic 
    Notes  : service externe. Critère piNoidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttTbfic.
    define variable vhttBuffer as handle  no-undo.
    define buffer TbFic for TbFic.

    vhttBuffer = phttTbfic:default-buffer-handle.
    if piNoidt = ?
    then for each TbFic no-lock
        where TbFic.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TbFic:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each TbFic no-lock
        where TbFic.tpidt = pcTpidt
          and TbFic.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TbFic:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbfic no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTbfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhLbfic    as handle  no-undo.
    define buffer TbFic for TbFic.

    create query vhttquery.
    vhttBuffer = ghttTbfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTbfic:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhLbfic).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TbFic exclusive-lock
                where rowid(TbFic) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TbFic:handle, 'tpidt/noidt/LbFic: ', substitute('&1/&2/&3', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhLbfic:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TbFic:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTbfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TbFic for TbFic.

    create query vhttquery.
    vhttBuffer = ghttTbfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTbfic:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TbFic.
            if not outils:copyValidField(buffer TbFic:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTbfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhLbfic    as handle  no-undo.
    define buffer TbFic for TbFic.

    create query vhttquery.
    vhttBuffer = ghttTbfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTbfic:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhLbfic).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TbFic exclusive-lock
                where rowid(Tbfic) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TbFic:handle, 'tpidt/noidt/LbFic: ', substitute('&1/&2/&3', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhLbfic:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TbFic no-error.
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

