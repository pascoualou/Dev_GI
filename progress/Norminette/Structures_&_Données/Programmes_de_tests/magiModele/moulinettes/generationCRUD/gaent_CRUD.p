/*------------------------------------------------------------------------
File        : gaent_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table gaent
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/gaent.i}
{application/include/error.i}
define variable ghttgaent as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phAgence as handle, output phNotac as handle, output phNoord as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/agence/notac/noord/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'agence' then phAgence = phBuffer:buffer-field(vi).
            when 'notac' then phNotac = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGaent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGaent.
    run updateGaent.
    run createGaent.
end procedure.

procedure setGaent:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGaent.
    ghttGaent = phttGaent.
    run crudGaent.
    delete object phttGaent.
end procedure.

procedure readGaent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table gaent 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt  as character  no-undo.
    define input parameter piNoidt  as int64      no-undo.
    define input parameter piAgence as integer    no-undo.
    define input parameter piNotac  as integer    no-undo.
    define input parameter piNoord  as integer    no-undo.
    define input parameter piNolig  as integer    no-undo.
    define input parameter table-handle phttGaent.
    define variable vhttBuffer as handle no-undo.
    define buffer gaent for gaent.

    vhttBuffer = phttGaent:default-buffer-handle.
    for first gaent no-lock
        where gaent.tpidt = pcTpidt
          and gaent.noidt = piNoidt
          and gaent.agence = piAgence
          and gaent.notac = piNotac
          and gaent.noord = piNoord
          and gaent.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gaent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGaent no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGaent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table gaent 
    Notes  : service externe. Critère piNoord = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt  as character  no-undo.
    define input parameter piNoidt  as int64      no-undo.
    define input parameter piAgence as integer    no-undo.
    define input parameter piNotac  as integer    no-undo.
    define input parameter piNoord  as integer    no-undo.
    define input parameter table-handle phttGaent.
    define variable vhttBuffer as handle  no-undo.
    define buffer gaent for gaent.

    vhttBuffer = phttGaent:default-buffer-handle.
    if piNoord = ?
    then for each gaent no-lock
        where gaent.tpidt = pcTpidt
          and gaent.noidt = piNoidt
          and gaent.agence = piAgence
          and gaent.notac = piNotac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gaent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each gaent no-lock
        where gaent.tpidt = pcTpidt
          and gaent.noidt = piNoidt
          and gaent.agence = piAgence
          and gaent.notac = piNotac
          and gaent.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gaent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGaent no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGaent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhAgence    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer gaent for gaent.

    create query vhttquery.
    vhttBuffer = ghttGaent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGaent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhAgence, output vhNotac, output vhNoord, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gaent exclusive-lock
                where rowid(gaent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gaent:handle, 'tpidt/noidt/agence/notac/noord/nolig: ', substitute('&1/&2/&3/&4/&5/&6', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhAgence:buffer-value(), vhNotac:buffer-value(), vhNoord:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer gaent:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGaent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer gaent for gaent.

    create query vhttquery.
    vhttBuffer = ghttGaent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGaent:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create gaent.
            if not outils:copyValidField(buffer gaent:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGaent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhAgence    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer gaent for gaent.

    create query vhttquery.
    vhttBuffer = ghttGaent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGaent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhAgence, output vhNotac, output vhNoord, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gaent exclusive-lock
                where rowid(Gaent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gaent:handle, 'tpidt/noidt/agence/notac/noord/nolig: ', substitute('&1/&2/&3/&4/&5/&6', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhAgence:buffer-value(), vhNotac:buffer-value(), vhNoord:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete gaent no-error.
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

