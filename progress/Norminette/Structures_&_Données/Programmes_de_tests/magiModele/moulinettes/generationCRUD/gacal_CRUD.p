/*------------------------------------------------------------------------
File        : gacal_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table gacal
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/gacal.i}
{application/include/error.i}
define variable ghttgacal as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phAnnee as handle, output phTpidt as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur annee/tpidt/noidt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGacal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGacal.
    run updateGacal.
    run createGacal.
end procedure.

procedure setGacal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGacal.
    ghttGacal = phttGacal.
    run crudGacal.
    delete object phttGacal.
end procedure.

procedure readGacal:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table gacal 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttGacal.
    define variable vhttBuffer as handle no-undo.
    define buffer gacal for gacal.

    vhttBuffer = phttGacal:default-buffer-handle.
    for first gacal no-lock
        where gacal.annee = piAnnee
          and gacal.tpidt = pcTpidt
          and gacal.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gacal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGacal no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGacal:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table gacal 
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttGacal.
    define variable vhttBuffer as handle  no-undo.
    define buffer gacal for gacal.

    vhttBuffer = phttGacal:default-buffer-handle.
    if pcTpidt = ?
    then for each gacal no-lock
        where gacal.annee = piAnnee:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gacal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each gacal no-lock
        where gacal.annee = piAnnee
          and gacal.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gacal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGacal no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGacal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer gacal for gacal.

    create query vhttquery.
    vhttBuffer = ghttGacal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGacal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gacal exclusive-lock
                where rowid(gacal) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gacal:handle, 'annee/tpidt/noidt: ', substitute('&1/&2/&3', vhAnnee:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer gacal:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGacal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer gacal for gacal.

    create query vhttquery.
    vhttBuffer = ghttGacal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGacal:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create gacal.
            if not outils:copyValidField(buffer gacal:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGacal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer gacal for gacal.

    create query vhttquery.
    vhttBuffer = ghttGacal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGacal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gacal exclusive-lock
                where rowid(Gacal) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gacal:handle, 'annee/tpidt/noidt: ', substitute('&1/&2/&3', vhAnnee:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete gacal no-error.
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

