/*------------------------------------------------------------------------
File        : tbent_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tbent
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/05/14 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghtttbent as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phCdent as handle, output phIden1 as handle, output phIden2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdent/iden1/iden2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdent' then phCdent = phBuffer:buffer-field(vi).
            when 'iden1' then phIden1 = phBuffer:buffer-field(vi).
            when 'iden2' then phIden2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTbent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTbent.
    run updateTbent.
    run createTbent.
end procedure.

procedure setTbent:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTbent.
    ghttTbent = phttTbent.
    run crudTbent.
    delete object phttTbent.
end procedure.

procedure readTbent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tbent 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdent as character no-undo.
    define input parameter pcIden1 as character no-undo.
    define input parameter pcIden2 as character no-undo.
    define input parameter table-handle phttTbent.

    define variable vhttBuffer as handle no-undo.
    define buffer tbent for tbent.

    vhttBuffer = phttTbent:default-buffer-handle.
    for first tbent no-lock
        where tbent.cdent = pcCdent
          and tbent.iden1 = pcIden1
          and tbent.iden2 = pcIden2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbent no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTbent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tbent 
    Notes  : service externe. Critère pcIden1 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdent as character no-undo.
    define input parameter pcIden1 as character no-undo.
    define input parameter table-handle phttTbent.

    define variable vhttBuffer as handle  no-undo.
    define buffer tbent for tbent.

    vhttBuffer = phttTbent:default-buffer-handle.
    if pcIden1 = ?
    then for each tbent no-lock
        where tbent.cdent = pcCdent:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tbent no-lock
        where tbent.cdent = pcCdent
          and tbent.iden1 = pcIden1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbent no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTbent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhCdent    as handle  no-undo.
    define variable vhIden1    as handle  no-undo.
    define variable vhIden2    as handle  no-undo.
    define buffer tbent for tbent.

    create query vhttquery.
    vhttBuffer = ghttTbent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTbent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdent, output vhIden1, output vhIden2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbent exclusive-lock
                where rowid(tbent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbent:handle, 'cdent/iden1/iden2: ', substitute('&1/&2/&3', vhCdent:buffer-value(), vhIden1:buffer-value(), vhIden2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tbent:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTbent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer tbent for tbent.

    create query vhttquery.
    vhttBuffer = ghttTbent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTbent:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tbent.
            if not outils:copyValidField(buffer tbent:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTbent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhCdent    as handle  no-undo.
    define variable vhIden1    as handle  no-undo.
    define variable vhIden2    as handle  no-undo.
    define buffer tbent for tbent.

    create query vhttquery.
    vhttBuffer = ghttTbent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTbent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdent, output vhIden1, output vhIden2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbent exclusive-lock
                where rowid(Tbent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbent:handle, 'cdent/iden1/iden2: ', substitute('&1/&2/&3', vhCdent:buffer-value(), vhIden1:buffer-value(), vhIden2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tbent no-error.
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
