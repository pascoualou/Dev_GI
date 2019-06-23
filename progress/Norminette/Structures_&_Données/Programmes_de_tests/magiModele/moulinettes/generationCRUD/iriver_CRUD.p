/*------------------------------------------------------------------------
File        : iriver_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iriver
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iriver.i}
{application/include/error.i}
define variable ghttiriver as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCle1 as handle, output phCle2 as handle, output phCle3 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cle1/cle2/cle3, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cle1' then phCle1 = phBuffer:buffer-field(vi).
            when 'cle2' then phCle2 = phBuffer:buffer-field(vi).
            when 'cle3' then phCle3 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIriver private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIriver.
    run updateIriver.
    run createIriver.
end procedure.

procedure setIriver:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIriver.
    ghttIriver = phttIriver.
    run crudIriver.
    delete object phttIriver.
end procedure.

procedure readIriver:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iriver Tables des parametres RIVERMAP
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCle1 as character  no-undo.
    define input parameter pcCle2 as character  no-undo.
    define input parameter pcCle3 as character  no-undo.
    define input parameter table-handle phttIriver.
    define variable vhttBuffer as handle no-undo.
    define buffer iriver for iriver.

    vhttBuffer = phttIriver:default-buffer-handle.
    for first iriver no-lock
        where iriver.cle1 = pcCle1
          and iriver.cle2 = pcCle2
          and iriver.cle3 = pcCle3:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iriver:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIriver no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIriver:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iriver Tables des parametres RIVERMAP
    Notes  : service externe. Critère pcCle2 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCle1 as character  no-undo.
    define input parameter pcCle2 as character  no-undo.
    define input parameter table-handle phttIriver.
    define variable vhttBuffer as handle  no-undo.
    define buffer iriver for iriver.

    vhttBuffer = phttIriver:default-buffer-handle.
    if pcCle2 = ?
    then for each iriver no-lock
        where iriver.cle1 = pcCle1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iriver:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iriver no-lock
        where iriver.cle1 = pcCle1
          and iriver.cle2 = pcCle2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iriver:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIriver no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIriver private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCle1    as handle  no-undo.
    define variable vhCle2    as handle  no-undo.
    define variable vhCle3    as handle  no-undo.
    define buffer iriver for iriver.

    create query vhttquery.
    vhttBuffer = ghttIriver:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIriver:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCle1, output vhCle2, output vhCle3).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iriver exclusive-lock
                where rowid(iriver) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iriver:handle, 'cle1/cle2/cle3: ', substitute('&1/&2/&3', vhCle1:buffer-value(), vhCle2:buffer-value(), vhCle3:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iriver:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIriver private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iriver for iriver.

    create query vhttquery.
    vhttBuffer = ghttIriver:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIriver:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iriver.
            if not outils:copyValidField(buffer iriver:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIriver private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCle1    as handle  no-undo.
    define variable vhCle2    as handle  no-undo.
    define variable vhCle3    as handle  no-undo.
    define buffer iriver for iriver.

    create query vhttquery.
    vhttBuffer = ghttIriver:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIriver:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCle1, output vhCle2, output vhCle3).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iriver exclusive-lock
                where rowid(Iriver) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iriver:handle, 'cle1/cle2/cle3: ', substitute('&1/&2/&3', vhCle1:buffer-value(), vhCle2:buffer-value(), vhCle3:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iriver no-error.
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

