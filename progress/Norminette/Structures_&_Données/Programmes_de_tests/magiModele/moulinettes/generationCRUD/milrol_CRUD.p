/*------------------------------------------------------------------------
File        : milrol_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table milrol
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/milrol.i}
{application/include/error.i}
define variable ghttmilrol as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phCdcle as handle, output phNorep as handle, output phTpidt as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/cdcle/norep/tpidt/noidt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'norep' then phNorep = phBuffer:buffer-field(vi).
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMilrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMilrol.
    run updateMilrol.
    run createMilrol.
end procedure.

procedure setMilrol:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMilrol.
    ghttMilrol = phttMilrol.
    run crudMilrol.
    delete object phttMilrol.
end procedure.

procedure readMilrol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table milrol 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNorep as integer    no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttMilrol.
    define variable vhttBuffer as handle no-undo.
    define buffer milrol for milrol.

    vhttBuffer = phttMilrol:default-buffer-handle.
    for first milrol no-lock
        where milrol.tpcon = pcTpcon
          and milrol.nocon = piNocon
          and milrol.cdcle = pcCdcle
          and milrol.norep = piNorep
          and milrol.tpidt = pcTpidt
          and milrol.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer milrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMilrol no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMilrol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table milrol 
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNorep as integer    no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttMilrol.
    define variable vhttBuffer as handle  no-undo.
    define buffer milrol for milrol.

    vhttBuffer = phttMilrol:default-buffer-handle.
    if pcTpidt = ?
    then for each milrol no-lock
        where milrol.tpcon = pcTpcon
          and milrol.nocon = piNocon
          and milrol.cdcle = pcCdcle
          and milrol.norep = piNorep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer milrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each milrol no-lock
        where milrol.tpcon = pcTpcon
          and milrol.nocon = piNocon
          and milrol.cdcle = pcCdcle
          and milrol.norep = piNorep
          and milrol.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer milrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMilrol no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMilrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNorep    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer milrol for milrol.

    create query vhttquery.
    vhttBuffer = ghttMilrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMilrol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCdcle, output vhNorep, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first milrol exclusive-lock
                where rowid(milrol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer milrol:handle, 'tpcon/nocon/cdcle/norep/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCdcle:buffer-value(), vhNorep:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer milrol:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMilrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer milrol for milrol.

    create query vhttquery.
    vhttBuffer = ghttMilrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMilrol:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create milrol.
            if not outils:copyValidField(buffer milrol:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMilrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNorep    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer milrol for milrol.

    create query vhttquery.
    vhttBuffer = ghttMilrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMilrol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCdcle, output vhNorep, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first milrol exclusive-lock
                where rowid(Milrol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer milrol:handle, 'tpcon/nocon/cdcle/norep/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCdcle:buffer-value(), vhNorep:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete milrol no-error.
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

