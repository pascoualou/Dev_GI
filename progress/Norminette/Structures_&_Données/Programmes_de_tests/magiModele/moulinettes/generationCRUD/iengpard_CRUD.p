/*------------------------------------------------------------------------
File        : iengpard_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iengpard
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iengpard.i}
{application/include/error.i}
define variable ghttiengpard as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIengpard private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIengpard.
    run updateIengpard.
    run createIengpard.
end procedure.

procedure setIengpard:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIengpard.
    ghttIengpard = phttIengpard.
    run crudIengpard.
    delete object phttIengpard.
end procedure.

procedure readIengpard:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iengpard 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttIengpard.
    define variable vhttBuffer as handle no-undo.
    define buffer iengpard for iengpard.

    vhttBuffer = phttIengpard:default-buffer-handle.
    for first iengpard no-lock
        where iengpard.soc-cd = piSoc-cd
          and iengpard.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengpard:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengpard no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIengpard:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iengpard 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIengpard.
    define variable vhttBuffer as handle  no-undo.
    define buffer iengpard for iengpard.

    vhttBuffer = phttIengpard:default-buffer-handle.
    if piSoc-cd = ?
    then for each iengpard no-lock
        where iengpard.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengpard:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iengpard no-lock
        where iengpard.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengpard:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengpard no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIengpard private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer iengpard for iengpard.

    create query vhttquery.
    vhttBuffer = ghttIengpard:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIengpard:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengpard exclusive-lock
                where rowid(iengpard) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengpard:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iengpard:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIengpard private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iengpard for iengpard.

    create query vhttquery.
    vhttBuffer = ghttIengpard:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIengpard:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iengpard.
            if not outils:copyValidField(buffer iengpard:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIengpard private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer iengpard for iengpard.

    create query vhttquery.
    vhttBuffer = ghttIengpard:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIengpard:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengpard exclusive-lock
                where rowid(Iengpard) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengpard:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iengpard no-error.
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

