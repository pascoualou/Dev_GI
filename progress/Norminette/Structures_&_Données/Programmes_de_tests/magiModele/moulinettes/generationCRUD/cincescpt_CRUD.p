/*------------------------------------------------------------------------
File        : cincescpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cincescpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cincescpt.i}
{application/include/error.i}
define variable ghttcincescpt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCpt-ori as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cpt-ori, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cpt-ori' then phCpt-ori = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCincescpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCincescpt.
    run updateCincescpt.
    run createCincescpt.
end procedure.

procedure setCincescpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCincescpt.
    ghttCincescpt = phttCincescpt.
    run crudCincescpt.
    delete object phttCincescpt.
end procedure.

procedure readCincescpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cincescpt compte de cession
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcCpt-ori as character  no-undo.
    define input parameter table-handle phttCincescpt.
    define variable vhttBuffer as handle no-undo.
    define buffer cincescpt for cincescpt.

    vhttBuffer = phttCincescpt:default-buffer-handle.
    for first cincescpt no-lock
        where cincescpt.soc-cd = piSoc-cd
          and cincescpt.cpt-ori = pcCpt-ori:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cincescpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCincescpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCincescpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cincescpt compte de cession
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCincescpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer cincescpt for cincescpt.

    vhttBuffer = phttCincescpt:default-buffer-handle.
    if piSoc-cd = ?
    then for each cincescpt no-lock
        where cincescpt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cincescpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cincescpt no-lock
        where cincescpt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cincescpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCincescpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCincescpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCpt-ori    as handle  no-undo.
    define buffer cincescpt for cincescpt.

    create query vhttquery.
    vhttBuffer = ghttCincescpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCincescpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCpt-ori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cincescpt exclusive-lock
                where rowid(cincescpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cincescpt:handle, 'soc-cd/cpt-ori: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCpt-ori:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cincescpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCincescpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cincescpt for cincescpt.

    create query vhttquery.
    vhttBuffer = ghttCincescpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCincescpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cincescpt.
            if not outils:copyValidField(buffer cincescpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCincescpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCpt-ori    as handle  no-undo.
    define buffer cincescpt for cincescpt.

    create query vhttquery.
    vhttBuffer = ghttCincescpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCincescpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCpt-ori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cincescpt exclusive-lock
                where rowid(Cincescpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cincescpt:handle, 'soc-cd/cpt-ori: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCpt-ori:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cincescpt no-error.
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

