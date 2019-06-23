/*------------------------------------------------------------------------
File        : gaint_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table gaint
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/gaint.i}
{application/include/error.i}
define variable ghttgaint as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phAgence as handle, output phNotac as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/agence/notac/noord, 
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
       end case.
    end.
end function.

procedure crudGaint private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGaint.
    run updateGaint.
    run createGaint.
end procedure.

procedure setGaint:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGaint.
    ghttGaint = phttGaint.
    run crudGaint.
    delete object phttGaint.
end procedure.

procedure readGaint:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table gaint affectation tache - utilisateur pour la gestion des alertes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt  as character  no-undo.
    define input parameter piNoidt  as int64      no-undo.
    define input parameter piAgence as integer    no-undo.
    define input parameter piNotac  as integer    no-undo.
    define input parameter piNoord  as integer    no-undo.
    define input parameter table-handle phttGaint.
    define variable vhttBuffer as handle no-undo.
    define buffer gaint for gaint.

    vhttBuffer = phttGaint:default-buffer-handle.
    for first gaint no-lock
        where gaint.tpidt = pcTpidt
          and gaint.noidt = piNoidt
          and gaint.agence = piAgence
          and gaint.notac = piNotac
          and gaint.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gaint:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGaint no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGaint:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table gaint affectation tache - utilisateur pour la gestion des alertes
    Notes  : service externe. Critère piNotac = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt  as character  no-undo.
    define input parameter piNoidt  as int64      no-undo.
    define input parameter piAgence as integer    no-undo.
    define input parameter piNotac  as integer    no-undo.
    define input parameter table-handle phttGaint.
    define variable vhttBuffer as handle  no-undo.
    define buffer gaint for gaint.

    vhttBuffer = phttGaint:default-buffer-handle.
    if piNotac = ?
    then for each gaint no-lock
        where gaint.tpidt = pcTpidt
          and gaint.noidt = piNoidt
          and gaint.agence = piAgence:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gaint:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each gaint no-lock
        where gaint.tpidt = pcTpidt
          and gaint.noidt = piNoidt
          and gaint.agence = piAgence
          and gaint.notac = piNotac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gaint:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGaint no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGaint private:
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
    define buffer gaint for gaint.

    create query vhttquery.
    vhttBuffer = ghttGaint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGaint:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhAgence, output vhNotac, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gaint exclusive-lock
                where rowid(gaint) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gaint:handle, 'tpidt/noidt/agence/notac/noord: ', substitute('&1/&2/&3/&4/&5', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhAgence:buffer-value(), vhNotac:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer gaint:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGaint private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer gaint for gaint.

    create query vhttquery.
    vhttBuffer = ghttGaint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGaint:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create gaint.
            if not outils:copyValidField(buffer gaint:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGaint private:
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
    define buffer gaint for gaint.

    create query vhttquery.
    vhttBuffer = ghttGaint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGaint:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhAgence, output vhNotac, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gaint exclusive-lock
                where rowid(Gaint) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gaint:handle, 'tpidt/noidt/agence/notac/noord: ', substitute('&1/&2/&3/&4/&5', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhAgence:buffer-value(), vhNotac:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete gaint no-error.
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

