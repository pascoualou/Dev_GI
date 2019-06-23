/*------------------------------------------------------------------------
File        : cind_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cind
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cind.i}
{application/include/error.i}
define variable ghttcind as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phInd-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/ind-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'ind-cle' then phInd-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCind private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCind.
    run updateCind.
    run createCind.
end procedure.

procedure setCind:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCind.
    ghttCind = phttCind.
    run crudCind.
    delete object phttCind.
end procedure.

procedure readCind:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cind 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcInd-cle as character  no-undo.
    define input parameter table-handle phttCind.
    define variable vhttBuffer as handle no-undo.
    define buffer cind for cind.

    vhttBuffer = phttCind:default-buffer-handle.
    for first cind no-lock
        where cind.soc-cd = piSoc-cd
          and cind.ind-cle = pcInd-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cind:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCind no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCind:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cind 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCind.
    define variable vhttBuffer as handle  no-undo.
    define buffer cind for cind.

    vhttBuffer = phttCind:default-buffer-handle.
    if piSoc-cd = ?
    then for each cind no-lock
        where cind.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cind:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cind no-lock
        where cind.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cind:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCind no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCind private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhInd-cle    as handle  no-undo.
    define buffer cind for cind.

    create query vhttquery.
    vhttBuffer = ghttCind:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCind:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhInd-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cind exclusive-lock
                where rowid(cind) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cind:handle, 'soc-cd/ind-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhInd-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cind:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCind private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cind for cind.

    create query vhttquery.
    vhttBuffer = ghttCind:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCind:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cind.
            if not outils:copyValidField(buffer cind:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCind private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhInd-cle    as handle  no-undo.
    define buffer cind for cind.

    create query vhttquery.
    vhttBuffer = ghttCind:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCind:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhInd-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cind exclusive-lock
                where rowid(Cind) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cind:handle, 'soc-cd/ind-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhInd-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cind no-error.
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

