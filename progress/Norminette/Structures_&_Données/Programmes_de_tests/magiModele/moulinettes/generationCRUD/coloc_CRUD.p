/*------------------------------------------------------------------------
File        : coloc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table coloc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/coloc.i}
{application/include/error.i}
define variable ghttcoloc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phMsqtt as handle, output phNoord as handle, output phTpidt as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/msqtt/noord/tpidt/noidt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'msqtt' then phMsqtt = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudColoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteColoc.
    run updateColoc.
    run createColoc.
end procedure.

procedure setColoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttColoc.
    ghttColoc = phttColoc.
    run crudColoc.
    delete object phttColoc.
end procedure.

procedure readColoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table coloc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piMsqtt as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttColoc.
    define variable vhttBuffer as handle no-undo.
    define buffer coloc for coloc.

    vhttBuffer = phttColoc:default-buffer-handle.
    for first coloc no-lock
        where coloc.tpcon = pcTpcon
          and coloc.nocon = piNocon
          and coloc.msqtt = piMsqtt
          and coloc.noord = piNoord
          and coloc.tpidt = pcTpidt
          and coloc.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer coloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttColoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getColoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table coloc 
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piMsqtt as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttColoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer coloc for coloc.

    vhttBuffer = phttColoc:default-buffer-handle.
    if pcTpidt = ?
    then for each coloc no-lock
        where coloc.tpcon = pcTpcon
          and coloc.nocon = piNocon
          and coloc.msqtt = piMsqtt
          and coloc.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer coloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each coloc no-lock
        where coloc.tpcon = pcTpcon
          and coloc.nocon = piNocon
          and coloc.msqtt = piMsqtt
          and coloc.noord = piNoord
          and coloc.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer coloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttColoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateColoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer coloc for coloc.

    create query vhttquery.
    vhttBuffer = ghttColoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttColoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhMsqtt, output vhNoord, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first coloc exclusive-lock
                where rowid(coloc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer coloc:handle, 'tpcon/nocon/msqtt/noord/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhMsqtt:buffer-value(), vhNoord:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer coloc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createColoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer coloc for coloc.

    create query vhttquery.
    vhttBuffer = ghttColoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttColoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create coloc.
            if not outils:copyValidField(buffer coloc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteColoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer coloc for coloc.

    create query vhttquery.
    vhttBuffer = ghttColoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttColoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhMsqtt, output vhNoord, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first coloc exclusive-lock
                where rowid(Coloc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer coloc:handle, 'tpcon/nocon/msqtt/noord/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhMsqtt:buffer-value(), vhNoord:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete coloc no-error.
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

