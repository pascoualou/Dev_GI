/*------------------------------------------------------------------------
File        : igedctr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table igedctr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/igedctr.i}
{application/include/error.i}
define variable ghttigedctr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIgedctr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIgedctr.
    run updateIgedctr.
    run createIgedctr.
end procedure.

procedure setIgedctr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedctr.
    ghttIgedctr = phttIgedctr.
    run crudIgedctr.
    delete object phttIgedctr.
end procedure.

procedure readIgedctr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table igedctr contrats associés aux docs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttIgedctr.
    define variable vhttBuffer as handle no-undo.
    define buffer igedctr for igedctr.

    vhttBuffer = phttIgedctr:default-buffer-handle.
    for first igedctr no-lock
        where igedctr.tpcon = pcTpcon
          and igedctr.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedctr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedctr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIgedctr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table igedctr contrats associés aux docs
    Notes  : service externe. Critère pcTpcon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter table-handle phttIgedctr.
    define variable vhttBuffer as handle  no-undo.
    define buffer igedctr for igedctr.

    vhttBuffer = phttIgedctr:default-buffer-handle.
    if pcTpcon = ?
    then for each igedctr no-lock
        where igedctr.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedctr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each igedctr no-lock
        where igedctr.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedctr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedctr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIgedctr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer igedctr for igedctr.

    create query vhttquery.
    vhttBuffer = ghttIgedctr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIgedctr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedctr exclusive-lock
                where rowid(igedctr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedctr:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer igedctr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIgedctr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer igedctr for igedctr.

    create query vhttquery.
    vhttBuffer = ghttIgedctr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIgedctr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create igedctr.
            if not outils:copyValidField(buffer igedctr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIgedctr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer igedctr for igedctr.

    create query vhttquery.
    vhttBuffer = ghttIgedctr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIgedctr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedctr exclusive-lock
                where rowid(Igedctr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedctr:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete igedctr no-error.
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

