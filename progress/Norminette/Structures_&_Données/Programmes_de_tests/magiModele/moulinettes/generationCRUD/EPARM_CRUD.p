/*------------------------------------------------------------------------
File        : EPARM_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table EPARM
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/EPARM.i}
{application/include/error.i}
define variable ghttEPARM as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phCdpar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TPPAR/CDPAR, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TPPAR' then phTppar = phBuffer:buffer-field(vi).
            when 'CDPAR' then phCdpar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEparm.
    run updateEparm.
    run createEparm.
end procedure.

procedure setEparm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEparm.
    ghttEparm = phttEparm.
    run crudEparm.
    delete object phttEparm.
end procedure.

procedure readEparm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table EPARM 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcCdpar as character  no-undo.
    define input parameter table-handle phttEparm.
    define variable vhttBuffer as handle no-undo.
    define buffer EPARM for EPARM.

    vhttBuffer = phttEparm:default-buffer-handle.
    for first EPARM no-lock
        where EPARM.TPPAR = pcTppar
          and EPARM.CDPAR = pcCdpar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EPARM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEparm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEparm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table EPARM 
    Notes  : service externe. Critère pcTppar = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter table-handle phttEparm.
    define variable vhttBuffer as handle  no-undo.
    define buffer EPARM for EPARM.

    vhttBuffer = phttEparm:default-buffer-handle.
    if pcTppar = ?
    then for each EPARM no-lock
        where EPARM.TPPAR = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EPARM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each EPARM no-lock
        where EPARM.TPPAR = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EPARM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEparm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer EPARM for EPARM.

    create query vhttquery.
    vhttBuffer = ghttEparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEparm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EPARM exclusive-lock
                where rowid(EPARM) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EPARM:handle, 'TPPAR/CDPAR: ', substitute('&1/&2', vhTppar:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer EPARM:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer EPARM for EPARM.

    create query vhttquery.
    vhttBuffer = ghttEparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEparm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create EPARM.
            if not outils:copyValidField(buffer EPARM:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer EPARM for EPARM.

    create query vhttquery.
    vhttBuffer = ghttEparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEparm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EPARM exclusive-lock
                where rowid(Eparm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EPARM:handle, 'TPPAR/CDPAR: ', substitute('&1/&2', vhTppar:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete EPARM no-error.
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

