/*------------------------------------------------------------------------
File        : svtrf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table svtrf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/svtrf.i}
{application/include/error.i}
define variable ghttsvtrf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdtrt as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdtrt/NoOrd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdtrt' then phCdtrt = phBuffer:buffer-field(vi).
            when 'NoOrd' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSvtrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSvtrf.
    run updateSvtrf.
    run createSvtrf.
end procedure.

procedure setSvtrf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSvtrf.
    ghttSvtrf = phttSvtrf.
    run crudSvtrf.
    delete object phttSvtrf.
end procedure.

procedure readSvtrf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table svtrf 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdtrt as character  no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttSvtrf.
    define variable vhttBuffer as handle no-undo.
    define buffer svtrf for svtrf.

    vhttBuffer = phttSvtrf:default-buffer-handle.
    for first svtrf no-lock
        where svtrf.cdtrt = pcCdtrt
          and svtrf.NoOrd = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svtrf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvtrf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSvtrf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table svtrf 
    Notes  : service externe. Critère pcCdtrt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdtrt as character  no-undo.
    define input parameter table-handle phttSvtrf.
    define variable vhttBuffer as handle  no-undo.
    define buffer svtrf for svtrf.

    vhttBuffer = phttSvtrf:default-buffer-handle.
    if pcCdtrt = ?
    then for each svtrf no-lock
        where svtrf.cdtrt = pcCdtrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svtrf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each svtrf no-lock
        where svtrf.cdtrt = pcCdtrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svtrf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvtrf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSvtrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdtrt    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer svtrf for svtrf.

    create query vhttquery.
    vhttBuffer = ghttSvtrf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSvtrf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdtrt, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first svtrf exclusive-lock
                where rowid(svtrf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer svtrf:handle, 'cdtrt/NoOrd: ', substitute('&1/&2', vhCdtrt:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer svtrf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSvtrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer svtrf for svtrf.

    create query vhttquery.
    vhttBuffer = ghttSvtrf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSvtrf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create svtrf.
            if not outils:copyValidField(buffer svtrf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSvtrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdtrt    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer svtrf for svtrf.

    create query vhttquery.
    vhttBuffer = ghttSvtrf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSvtrf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdtrt, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first svtrf exclusive-lock
                where rowid(Svtrf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer svtrf:handle, 'cdtrt/NoOrd: ', substitute('&1/&2', vhCdtrt:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete svtrf no-error.
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

