/*------------------------------------------------------------------------
File        : igedlien_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table igedlien
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/igedlien.i}
{application/include/error.i}
define variable ghttigedlien as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phCdpar1 as handle, output phCdpar2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/cdpar1/cdpar2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'cdpar1' then phCdpar1 = phBuffer:buffer-field(vi).
            when 'cdpar2' then phCdpar2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIgedlien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIgedlien.
    run updateIgedlien.
    run createIgedlien.
end procedure.

procedure setIgedlien:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedlien.
    ghttIgedlien = phttIgedlien.
    run crudIgedlien.
    delete object phttIgedlien.
end procedure.

procedure readIgedlien:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table igedlien Table de liens ged
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar  as character  no-undo.
    define input parameter pcCdpar1 as character  no-undo.
    define input parameter pcCdpar2 as character  no-undo.
    define input parameter table-handle phttIgedlien.
    define variable vhttBuffer as handle no-undo.
    define buffer igedlien for igedlien.

    vhttBuffer = phttIgedlien:default-buffer-handle.
    for first igedlien no-lock
        where igedlien.tppar = pcTppar
          and igedlien.cdpar1 = pcCdpar1
          and igedlien.cdpar2 = pcCdpar2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedlien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedlien no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIgedlien:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table igedlien Table de liens ged
    Notes  : service externe. Critère pcCdpar1 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar  as character  no-undo.
    define input parameter pcCdpar1 as character  no-undo.
    define input parameter table-handle phttIgedlien.
    define variable vhttBuffer as handle  no-undo.
    define buffer igedlien for igedlien.

    vhttBuffer = phttIgedlien:default-buffer-handle.
    if pcCdpar1 = ?
    then for each igedlien no-lock
        where igedlien.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedlien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each igedlien no-lock
        where igedlien.tppar = pcTppar
          and igedlien.cdpar1 = pcCdpar1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedlien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedlien no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIgedlien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar1    as handle  no-undo.
    define variable vhCdpar2    as handle  no-undo.
    define buffer igedlien for igedlien.

    create query vhttquery.
    vhttBuffer = ghttIgedlien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIgedlien:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar1, output vhCdpar2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedlien exclusive-lock
                where rowid(igedlien) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedlien:handle, 'tppar/cdpar1/cdpar2: ', substitute('&1/&2/&3', vhTppar:buffer-value(), vhCdpar1:buffer-value(), vhCdpar2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer igedlien:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIgedlien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer igedlien for igedlien.

    create query vhttquery.
    vhttBuffer = ghttIgedlien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIgedlien:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create igedlien.
            if not outils:copyValidField(buffer igedlien:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIgedlien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar1    as handle  no-undo.
    define variable vhCdpar2    as handle  no-undo.
    define buffer igedlien for igedlien.

    create query vhttquery.
    vhttBuffer = ghttIgedlien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIgedlien:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar1, output vhCdpar2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedlien exclusive-lock
                where rowid(Igedlien) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedlien:handle, 'tppar/cdpar1/cdpar2: ', substitute('&1/&2/&3', vhTppar:buffer-value(), vhCdpar1:buffer-value(), vhCdpar2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete igedlien no-error.
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

