/*------------------------------------------------------------------------
File        : Sys_ev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Sys_ev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Sys_ev.i}
{application/include/error.i}
define variable ghttSys_ev as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phCle1 as handle, output phCle2 as handle, output phCle3 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpPar/Cle1/Cle2/Cle3, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpPar' then phTppar = phBuffer:buffer-field(vi).
            when 'Cle1' then phCle1 = phBuffer:buffer-field(vi).
            when 'Cle2' then phCle2 = phBuffer:buffer-field(vi).
            when 'Cle3' then phCle3 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_ev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_ev.
    run updateSys_ev.
    run createSys_ev.
end procedure.

procedure setSys_ev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_ev.
    ghttSys_ev = phttSys_ev.
    run crudSys_ev.
    delete object phttSys_ev.
end procedure.

procedure readSys_ev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Sys_ev 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcCle1  as character  no-undo.
    define input parameter pcCle2  as character  no-undo.
    define input parameter pcCle3  as character  no-undo.
    define input parameter table-handle phttSys_ev.
    define variable vhttBuffer as handle no-undo.
    define buffer Sys_ev for Sys_ev.

    vhttBuffer = phttSys_ev:default-buffer-handle.
    for first Sys_ev no-lock
        where Sys_ev.TpPar = pcTppar
          and Sys_ev.Cle1 = pcCle1
          and Sys_ev.Cle2 = pcCle2
          and Sys_ev.Cle3 = pcCle3:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Sys_ev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_ev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_ev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Sys_ev 
    Notes  : service externe. Critère pcCle2 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcCle1  as character  no-undo.
    define input parameter pcCle2  as character  no-undo.
    define input parameter table-handle phttSys_ev.
    define variable vhttBuffer as handle  no-undo.
    define buffer Sys_ev for Sys_ev.

    vhttBuffer = phttSys_ev:default-buffer-handle.
    if pcCle2 = ?
    then for each Sys_ev no-lock
        where Sys_ev.TpPar = pcTppar
          and Sys_ev.Cle1 = pcCle1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Sys_ev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each Sys_ev no-lock
        where Sys_ev.TpPar = pcTppar
          and Sys_ev.Cle1 = pcCle1
          and Sys_ev.Cle2 = pcCle2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Sys_ev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_ev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_ev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCle1    as handle  no-undo.
    define variable vhCle2    as handle  no-undo.
    define variable vhCle3    as handle  no-undo.
    define buffer Sys_ev for Sys_ev.

    create query vhttquery.
    vhttBuffer = ghttSys_ev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_ev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCle1, output vhCle2, output vhCle3).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Sys_ev exclusive-lock
                where rowid(Sys_ev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Sys_ev:handle, 'TpPar/Cle1/Cle2/Cle3: ', substitute('&1/&2/&3/&4', vhTppar:buffer-value(), vhCle1:buffer-value(), vhCle2:buffer-value(), vhCle3:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Sys_ev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_ev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Sys_ev for Sys_ev.

    create query vhttquery.
    vhttBuffer = ghttSys_ev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_ev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Sys_ev.
            if not outils:copyValidField(buffer Sys_ev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_ev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCle1    as handle  no-undo.
    define variable vhCle2    as handle  no-undo.
    define variable vhCle3    as handle  no-undo.
    define buffer Sys_ev for Sys_ev.

    create query vhttquery.
    vhttBuffer = ghttSys_ev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_ev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCle1, output vhCle2, output vhCle3).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Sys_ev exclusive-lock
                where rowid(Sys_ev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Sys_ev:handle, 'TpPar/Cle1/Cle2/Cle3: ', substitute('&1/&2/&3/&4', vhTppar:buffer-value(), vhCle1:buffer-value(), vhCle2:buffer-value(), vhCle3:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Sys_ev no-error.
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

