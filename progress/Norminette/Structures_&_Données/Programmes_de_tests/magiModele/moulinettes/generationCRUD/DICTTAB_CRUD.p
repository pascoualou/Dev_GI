/*------------------------------------------------------------------------
File        : DICTTAB_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DICTTAB
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DICTTAB.i}
{application/include/error.i}
define variable ghttDICTTAB as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNmlog as handle, output phNmtab as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NMLOG/NMTAB, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NMLOG' then phNmlog = phBuffer:buffer-field(vi).
            when 'NMTAB' then phNmtab = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDicttab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDicttab.
    run updateDicttab.
    run createDicttab.
end procedure.

procedure setDicttab:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDicttab.
    ghttDicttab = phttDicttab.
    run crudDicttab.
    delete object phttDicttab.
end procedure.

procedure readDicttab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DICTTAB 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNmlog as character  no-undo.
    define input parameter pcNmtab as character  no-undo.
    define input parameter table-handle phttDicttab.
    define variable vhttBuffer as handle no-undo.
    define buffer DICTTAB for DICTTAB.

    vhttBuffer = phttDicttab:default-buffer-handle.
    for first DICTTAB no-lock
        where DICTTAB.NMLOG = pcNmlog
          and DICTTAB.NMTAB = pcNmtab:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DICTTAB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDicttab no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDicttab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DICTTAB 
    Notes  : service externe. Critère pcNmlog = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcNmlog as character  no-undo.
    define input parameter table-handle phttDicttab.
    define variable vhttBuffer as handle  no-undo.
    define buffer DICTTAB for DICTTAB.

    vhttBuffer = phttDicttab:default-buffer-handle.
    if pcNmlog = ?
    then for each DICTTAB no-lock
        where DICTTAB.NMLOG = pcNmlog:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DICTTAB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DICTTAB no-lock
        where DICTTAB.NMLOG = pcNmlog:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DICTTAB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDicttab no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDicttab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmlog    as handle  no-undo.
    define variable vhNmtab    as handle  no-undo.
    define buffer DICTTAB for DICTTAB.

    create query vhttquery.
    vhttBuffer = ghttDicttab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDicttab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmlog, output vhNmtab).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DICTTAB exclusive-lock
                where rowid(DICTTAB) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DICTTAB:handle, 'NMLOG/NMTAB: ', substitute('&1/&2', vhNmlog:buffer-value(), vhNmtab:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DICTTAB:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDicttab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DICTTAB for DICTTAB.

    create query vhttquery.
    vhttBuffer = ghttDicttab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDicttab:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DICTTAB.
            if not outils:copyValidField(buffer DICTTAB:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDicttab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmlog    as handle  no-undo.
    define variable vhNmtab    as handle  no-undo.
    define buffer DICTTAB for DICTTAB.

    create query vhttquery.
    vhttBuffer = ghttDicttab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDicttab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmlog, output vhNmtab).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DICTTAB exclusive-lock
                where rowid(Dicttab) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DICTTAB:handle, 'NMLOG/NMTAB: ', substitute('&1/&2', vhNmlog:buffer-value(), vhNmtab:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DICTTAB no-error.
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

