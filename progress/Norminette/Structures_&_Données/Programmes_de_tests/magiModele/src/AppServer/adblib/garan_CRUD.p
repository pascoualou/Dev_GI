/*------------------------------------------------------------------------
File        : garan_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table garan
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
              vient de adb/lib/l_garan_ext.p 
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
// {adblib/include/garant.i}
{application/include/error.i}
define variable ghttgaran as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpctt as handle, output phNoctt as handle, output phTpbar as handle, output phNobar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpctt/noctt/tpbar/nobar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpctt' then phTpctt = phBuffer:buffer-field(vi).
            when 'noctt' then phNoctt = phBuffer:buffer-field(vi).
            when 'tpbar' then phTpbar = phBuffer:buffer-field(vi).
            when 'nobar' then phNobar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGaran private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGaran.
    run updateGaran.
    run createGaran.
end procedure.

procedure setGaran:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGaran.
    ghttGaran = phttGaran.
    run crudGaran.
    delete object phttGaran.
end procedure.

procedure readGaran:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table garan 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNoctt as integer    no-undo.
    define input parameter pcTpbar as character  no-undo.
    define input parameter piNobar as integer    no-undo.
    define input parameter table-handle phttGaran.
    define variable vhttBuffer as handle no-undo.
    define buffer garan for garan.

    vhttBuffer = phttGaran:default-buffer-handle.
    for first garan no-lock
        where garan.tpctt = pcTpctt
          and garan.noctt = piNoctt
          and garan.tpbar = pcTpbar
          and garan.nobar = piNobar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer garan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGaran no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGaran:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table garan 
    Notes  : service externe. Critère pcTpbar = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNoctt as integer    no-undo.
    define input parameter pcTpbar as character  no-undo.
    define input parameter table-handle phttGaran.
    define variable vhttBuffer as handle  no-undo.
    define buffer garan for garan.

    vhttBuffer = phttGaran:default-buffer-handle.
    if pcTpbar = ?
    then for each garan no-lock
        where garan.tpctt = pcTpctt
          and garan.noctt = piNoctt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer garan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each garan no-lock
        where garan.tpctt = pcTpctt
          and garan.noctt = piNoctt
          and garan.tpbar = pcTpbar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer garan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGaran no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGaran private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNoctt    as handle  no-undo.
    define variable vhTpbar    as handle  no-undo.
    define variable vhNobar    as handle  no-undo.
    define buffer garan for garan.

    create query vhttquery.
    vhttBuffer = ghttGaran:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGaran:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNoctt, output vhTpbar, output vhNobar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.
 
            find first garan exclusive-lock
                where rowid(garan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer garan:handle, 'tpctt/noctt/tpbar/nobar: ', substitute('&1/&2/&3/&4', vhTpctt:buffer-value(), vhNoctt:buffer-value(), vhTpbar:buffer-value(), vhNobar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer garan:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGaran private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer garan for garan.

    create query vhttquery.
    vhttBuffer = ghttGaran:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGaran:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create garan.
            if not outils:copyValidField(buffer garan:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGaran private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNoctt    as handle  no-undo.
    define variable vhTpbar    as handle  no-undo.
    define variable vhNobar    as handle  no-undo.
    define buffer garan for garan.

    create query vhttquery.
    vhttBuffer = ghttGaran:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGaran:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNoctt, output vhTpbar, output vhNobar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first garan exclusive-lock
                where rowid(Garan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer garan:handle, 'tpctt/noctt/tpbar/nobar: ', substitute('&1/&2/&3/&4', vhTpctt:buffer-value(), vhNoctt:buffer-value(), vhTpbar:buffer-value(), vhNobar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete garan no-error.
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
