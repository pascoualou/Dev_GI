/*------------------------------------------------------------------------
File        : typol_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table typol
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/typol.i}
{application/include/error.i}
define variable ghtttypol as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoidt as handle, output phCdtrt as handle, output phNtcon as handle, output phNbrev as handle, output phUtrev as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noidt/cdTrt/ntcon/nbrev/utrev, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'cdTrt' then phCdtrt = phBuffer:buffer-field(vi).
            when 'ntcon' then phNtcon = phBuffer:buffer-field(vi).
            when 'nbrev' then phNbrev = phBuffer:buffer-field(vi).
            when 'utrev' then phUtrev = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTypol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTypol.
    run updateTypol.
    run createTypol.
end procedure.

procedure setTypol:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTypol.
    ghttTypol = phttTypol.
    run crudTypol.
    delete object phttTypol.
end procedure.

procedure readTypol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table typol Typologie
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcCdtrt as character  no-undo.
    define input parameter pcNtcon as character  no-undo.
    define input parameter piNbrev as integer    no-undo.
    define input parameter pcUtrev as character  no-undo.
    define input parameter table-handle phttTypol.
    define variable vhttBuffer as handle no-undo.
    define buffer typol for typol.

    vhttBuffer = phttTypol:default-buffer-handle.
    for first typol no-lock
        where typol.noidt = piNoidt
          and typol.cdTrt = pcCdtrt
          and typol.ntcon = pcNtcon
          and typol.nbrev = piNbrev
          and typol.utrev = pcUtrev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer typol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTypol no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTypol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table typol Typologie
    Notes  : service externe. Critère piNbrev = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcCdtrt as character  no-undo.
    define input parameter pcNtcon as character  no-undo.
    define input parameter piNbrev as integer    no-undo.
    define input parameter table-handle phttTypol.
    define variable vhttBuffer as handle  no-undo.
    define buffer typol for typol.

    vhttBuffer = phttTypol:default-buffer-handle.
    if piNbrev = ?
    then for each typol no-lock
        where typol.noidt = piNoidt
          and typol.cdTrt = pcCdtrt
          and typol.ntcon = pcNtcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer typol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each typol no-lock
        where typol.noidt = piNoidt
          and typol.cdTrt = pcCdtrt
          and typol.ntcon = pcNtcon
          and typol.nbrev = piNbrev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer typol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTypol no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTypol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhCdtrt    as handle  no-undo.
    define variable vhNtcon    as handle  no-undo.
    define variable vhNbrev    as handle  no-undo.
    define variable vhUtrev    as handle  no-undo.
    define buffer typol for typol.

    create query vhttquery.
    vhttBuffer = ghttTypol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTypol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoidt, output vhCdtrt, output vhNtcon, output vhNbrev, output vhUtrev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first typol exclusive-lock
                where rowid(typol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer typol:handle, 'noidt/cdTrt/ntcon/nbrev/utrev: ', substitute('&1/&2/&3/&4/&5', vhNoidt:buffer-value(), vhCdtrt:buffer-value(), vhNtcon:buffer-value(), vhNbrev:buffer-value(), vhUtrev:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer typol:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTypol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer typol for typol.

    create query vhttquery.
    vhttBuffer = ghttTypol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTypol:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create typol.
            if not outils:copyValidField(buffer typol:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTypol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhCdtrt    as handle  no-undo.
    define variable vhNtcon    as handle  no-undo.
    define variable vhNbrev    as handle  no-undo.
    define variable vhUtrev    as handle  no-undo.
    define buffer typol for typol.

    create query vhttquery.
    vhttBuffer = ghttTypol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTypol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoidt, output vhCdtrt, output vhNtcon, output vhNbrev, output vhUtrev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first typol exclusive-lock
                where rowid(Typol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer typol:handle, 'noidt/cdTrt/ntcon/nbrev/utrev: ', substitute('&1/&2/&3/&4/&5', vhNoidt:buffer-value(), vhCdtrt:buffer-value(), vhNtcon:buffer-value(), vhNbrev:buffer-value(), vhUtrev:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete typol no-error.
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

