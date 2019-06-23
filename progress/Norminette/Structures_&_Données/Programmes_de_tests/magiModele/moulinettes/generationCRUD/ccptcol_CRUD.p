/*------------------------------------------------------------------------
File        : ccptcol_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccptcol
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccptcol.i}
{application/include/error.i}
define variable ghttccptcol as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phColl-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/coll-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcptcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcptcol.
    run updateCcptcol.
    run createCcptcol.
end procedure.

procedure setCcptcol:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcptcol.
    ghttCcptcol = phttCcptcol.
    run crudCcptcol.
    delete object phttCcptcol.
end procedure.

procedure readCcptcol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccptcol Fichier Comptes collectifs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter table-handle phttCcptcol.
    define variable vhttBuffer as handle no-undo.
    define buffer ccptcol for ccptcol.

    vhttBuffer = phttCcptcol:default-buffer-handle.
    for first ccptcol no-lock
        where ccptcol.soc-cd = piSoc-cd
          and ccptcol.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptcol no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcptcol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccptcol Fichier Comptes collectifs
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter table-handle phttCcptcol.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccptcol for ccptcol.

    vhttBuffer = phttCcptcol:default-buffer-handle.
    if piSoc-cd = ?
    then for each ccptcol no-lock
        where ccptcol.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccptcol no-lock
        where ccptcol.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptcol no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcptcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define buffer ccptcol for ccptcol.

    create query vhttquery.
    vhttBuffer = ghttCcptcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcptcol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptcol exclusive-lock
                where rowid(ccptcol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptcol:handle, 'soc-cd/coll-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccptcol:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcptcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccptcol for ccptcol.

    create query vhttquery.
    vhttBuffer = ghttCcptcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcptcol:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccptcol.
            if not outils:copyValidField(buffer ccptcol:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcptcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define buffer ccptcol for ccptcol.

    create query vhttquery.
    vhttBuffer = ghttCcptcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcptcol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptcol exclusive-lock
                where rowid(Ccptcol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptcol:handle, 'soc-cd/coll-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccptcol no-error.
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

