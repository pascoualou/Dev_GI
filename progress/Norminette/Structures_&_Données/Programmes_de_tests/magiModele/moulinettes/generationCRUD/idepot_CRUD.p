/*------------------------------------------------------------------------
File        : idepot_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table idepot
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/idepot.i}
{application/include/error.i}
define variable ghttidepot as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phDepot-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/depot-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'depot-cd' then phDepot-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIdepot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIdepot.
    run updateIdepot.
    run createIdepot.
end procedure.

procedure setIdepot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIdepot.
    ghttIdepot = phttIdepot.
    run crudIdepot.
    delete object phttIdepot.
end procedure.

procedure readIdepot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table idepot Fichier Depot
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piDepot-cd as integer    no-undo.
    define input parameter table-handle phttIdepot.
    define variable vhttBuffer as handle no-undo.
    define buffer idepot for idepot.

    vhttBuffer = phttIdepot:default-buffer-handle.
    for first idepot no-lock
        where idepot.soc-cd = piSoc-cd
          and idepot.etab-cd = piEtab-cd
          and idepot.depot-cd = piDepot-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idepot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdepot no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIdepot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table idepot Fichier Depot
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter table-handle phttIdepot.
    define variable vhttBuffer as handle  no-undo.
    define buffer idepot for idepot.

    vhttBuffer = phttIdepot:default-buffer-handle.
    if piEtab-cd = ?
    then for each idepot no-lock
        where idepot.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idepot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each idepot no-lock
        where idepot.soc-cd = piSoc-cd
          and idepot.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idepot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdepot no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIdepot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDepot-cd    as handle  no-undo.
    define buffer idepot for idepot.

    create query vhttquery.
    vhttBuffer = ghttIdepot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIdepot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDepot-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idepot exclusive-lock
                where rowid(idepot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idepot:handle, 'soc-cd/etab-cd/depot-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDepot-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer idepot:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIdepot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer idepot for idepot.

    create query vhttquery.
    vhttBuffer = ghttIdepot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIdepot:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create idepot.
            if not outils:copyValidField(buffer idepot:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIdepot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDepot-cd    as handle  no-undo.
    define buffer idepot for idepot.

    create query vhttquery.
    vhttBuffer = ghttIdepot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIdepot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDepot-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idepot exclusive-lock
                where rowid(Idepot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idepot:handle, 'soc-cd/etab-cd/depot-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDepot-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete idepot no-error.
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

