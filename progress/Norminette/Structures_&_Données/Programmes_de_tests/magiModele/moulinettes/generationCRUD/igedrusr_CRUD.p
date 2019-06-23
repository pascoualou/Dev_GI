/*------------------------------------------------------------------------
File        : igedrusr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table igedrusr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/igedrusr.i}
{application/include/error.i}
define variable ghttigedrusr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phIdent_u as handle, output phNom-doss as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur ident_u/nom-doss, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'ident_u' then phIdent_u = phBuffer:buffer-field(vi).
            when 'nom-doss' then phNom-doss = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIgedrusr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIgedrusr.
    run updateIgedrusr.
    run createIgedrusr.
end procedure.

procedure setIgedrusr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedrusr.
    ghttIgedrusr = phttIgedrusr.
    run crudIgedrusr.
    delete object phttIgedrusr.
end procedure.

procedure readIgedrusr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table igedrusr 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcIdent_u  as character  no-undo.
    define input parameter pcNom-doss as character  no-undo.
    define input parameter table-handle phttIgedrusr.
    define variable vhttBuffer as handle no-undo.
    define buffer igedrusr for igedrusr.

    vhttBuffer = phttIgedrusr:default-buffer-handle.
    for first igedrusr no-lock
        where igedrusr.ident_u = pcIdent_u
          and igedrusr.nom-doss = pcNom-doss:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedrusr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedrusr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIgedrusr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table igedrusr 
    Notes  : service externe. Critère pcIdent_u = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcIdent_u  as character  no-undo.
    define input parameter table-handle phttIgedrusr.
    define variable vhttBuffer as handle  no-undo.
    define buffer igedrusr for igedrusr.

    vhttBuffer = phttIgedrusr:default-buffer-handle.
    if pcIdent_u = ?
    then for each igedrusr no-lock
        where igedrusr.ident_u = pcIdent_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedrusr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each igedrusr no-lock
        where igedrusr.ident_u = pcIdent_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedrusr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedrusr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIgedrusr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIdent_u    as handle  no-undo.
    define variable vhNom-doss    as handle  no-undo.
    define buffer igedrusr for igedrusr.

    create query vhttquery.
    vhttBuffer = ghttIgedrusr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIgedrusr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIdent_u, output vhNom-doss).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedrusr exclusive-lock
                where rowid(igedrusr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedrusr:handle, 'ident_u/nom-doss: ', substitute('&1/&2', vhIdent_u:buffer-value(), vhNom-doss:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer igedrusr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIgedrusr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer igedrusr for igedrusr.

    create query vhttquery.
    vhttBuffer = ghttIgedrusr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIgedrusr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create igedrusr.
            if not outils:copyValidField(buffer igedrusr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIgedrusr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIdent_u    as handle  no-undo.
    define variable vhNom-doss    as handle  no-undo.
    define buffer igedrusr for igedrusr.

    create query vhttquery.
    vhttBuffer = ghttIgedrusr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIgedrusr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIdent_u, output vhNom-doss).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedrusr exclusive-lock
                where rowid(Igedrusr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedrusr:handle, 'ident_u/nom-doss: ', substitute('&1/&2', vhIdent_u:buffer-value(), vhNom-doss:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete igedrusr no-error.
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

