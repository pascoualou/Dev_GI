/*------------------------------------------------------------------------
File        : offlc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table offlc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/offlc.i}
{application/include/error.i}
define variable ghttofflc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudOfflc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteOfflc.
    run updateOfflc.
    run createOfflc.
end procedure.

procedure setOfflc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttOfflc.
    ghttOfflc = phttOfflc.
    run crudOfflc.
    delete object phttOfflc.
end procedure.

procedure readOfflc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table offlc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttOfflc.
    define variable vhttBuffer as handle no-undo.
    define buffer offlc for offlc.

    vhttBuffer = phttOfflc:default-buffer-handle.
    for first offlc no-lock
        where offlc.tpcon = pcTpcon
          and offlc.nocon = piNocon
          and offlc.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer offlc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOfflc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getOfflc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table offlc 
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter table-handle phttOfflc.
    define variable vhttBuffer as handle  no-undo.
    define buffer offlc for offlc.

    vhttBuffer = phttOfflc:default-buffer-handle.
    if piNocon = ?
    then for each offlc no-lock
        where offlc.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer offlc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each offlc no-lock
        where offlc.tpcon = pcTpcon
          and offlc.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer offlc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOfflc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateOfflc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer offlc for offlc.

    create query vhttquery.
    vhttBuffer = ghttOfflc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttOfflc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first offlc exclusive-lock
                where rowid(offlc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer offlc:handle, 'tpcon/nocon/noapp: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer offlc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createOfflc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer offlc for offlc.

    create query vhttquery.
    vhttBuffer = ghttOfflc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttOfflc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create offlc.
            if not outils:copyValidField(buffer offlc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteOfflc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer offlc for offlc.

    create query vhttquery.
    vhttBuffer = ghttOfflc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttOfflc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first offlc exclusive-lock
                where rowid(Offlc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer offlc:handle, 'tpcon/nocon/noapp: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete offlc no-error.
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

