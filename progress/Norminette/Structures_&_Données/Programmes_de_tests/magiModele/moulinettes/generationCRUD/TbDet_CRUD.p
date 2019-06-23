/*------------------------------------------------------------------------
File        : TbDet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TbDet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TbDet.i}
{application/include/error.i}
define variable ghttTbDet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdent as handle, output phIden1 as handle, output phIden2 as handle, output phIdde1 as handle, output phIdde2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdent/iden1/iden2/idde1/idde2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdent' then phCdent = phBuffer:buffer-field(vi).
            when 'iden1' then phIden1 = phBuffer:buffer-field(vi).
            when 'iden2' then phIden2 = phBuffer:buffer-field(vi).
            when 'idde1' then phIdde1 = phBuffer:buffer-field(vi).
            when 'idde2' then phIdde2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTbdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTbdet.
    run updateTbdet.
    run createTbdet.
end procedure.

procedure setTbdet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTbdet.
    ghttTbdet = phttTbdet.
    run crudTbdet.
    delete object phttTbdet.
end procedure.

procedure readTbdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TbDet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdent as character  no-undo.
    define input parameter pcIden1 as character  no-undo.
    define input parameter pcIden2 as character  no-undo.
    define input parameter pcIdde1 as character  no-undo.
    define input parameter pcIdde2 as character  no-undo.
    define input parameter table-handle phttTbdet.
    define variable vhttBuffer as handle no-undo.
    define buffer TbDet for TbDet.

    vhttBuffer = phttTbdet:default-buffer-handle.
    for first TbDet no-lock
        where TbDet.cdent = pcCdent
          and TbDet.iden1 = pcIden1
          and TbDet.iden2 = pcIden2
          and TbDet.idde1 = pcIdde1
          and TbDet.idde2 = pcIdde2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TbDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbdet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTbdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TbDet 
    Notes  : service externe. Critère pcIdde1 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdent as character  no-undo.
    define input parameter pcIden1 as character  no-undo.
    define input parameter pcIden2 as character  no-undo.
    define input parameter pcIdde1 as character  no-undo.
    define input parameter table-handle phttTbdet.
    define variable vhttBuffer as handle  no-undo.
    define buffer TbDet for TbDet.

    vhttBuffer = phttTbdet:default-buffer-handle.
    if pcIdde1 = ?
    then for each TbDet no-lock
        where TbDet.cdent = pcCdent
          and TbDet.iden1 = pcIden1
          and TbDet.iden2 = pcIden2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TbDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each TbDet no-lock
        where TbDet.cdent = pcCdent
          and TbDet.iden1 = pcIden1
          and TbDet.iden2 = pcIden2
          and TbDet.idde1 = pcIdde1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TbDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbdet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTbdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdent    as handle  no-undo.
    define variable vhIden1    as handle  no-undo.
    define variable vhIden2    as handle  no-undo.
    define variable vhIdde1    as handle  no-undo.
    define variable vhIdde2    as handle  no-undo.
    define buffer TbDet for TbDet.

    create query vhttquery.
    vhttBuffer = ghttTbdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTbdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdent, output vhIden1, output vhIden2, output vhIdde1, output vhIdde2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TbDet exclusive-lock
                where rowid(TbDet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TbDet:handle, 'cdent/iden1/iden2/idde1/idde2: ', substitute('&1/&2/&3/&4/&5', vhCdent:buffer-value(), vhIden1:buffer-value(), vhIden2:buffer-value(), vhIdde1:buffer-value(), vhIdde2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TbDet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTbdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TbDet for TbDet.

    create query vhttquery.
    vhttBuffer = ghttTbdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTbdet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TbDet.
            if not outils:copyValidField(buffer TbDet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTbdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdent    as handle  no-undo.
    define variable vhIden1    as handle  no-undo.
    define variable vhIden2    as handle  no-undo.
    define variable vhIdde1    as handle  no-undo.
    define variable vhIdde2    as handle  no-undo.
    define buffer TbDet for TbDet.

    create query vhttquery.
    vhttBuffer = ghttTbdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTbdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdent, output vhIden1, output vhIden2, output vhIdde1, output vhIdde2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TbDet exclusive-lock
                where rowid(Tbdet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TbDet:handle, 'cdent/iden1/iden2/idde1/idde2: ', substitute('&1/&2/&3/&4/&5', vhCdent:buffer-value(), vhIden1:buffer-value(), vhIden2:buffer-value(), vhIdde1:buffer-value(), vhIdde2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TbDet no-error.
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

