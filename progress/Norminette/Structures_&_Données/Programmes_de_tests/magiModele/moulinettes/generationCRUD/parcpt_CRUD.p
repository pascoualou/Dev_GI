/*------------------------------------------------------------------------
File        : parcpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table parcpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/parcpt.i}
{application/include/error.i}
define variable ghttparcpt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phJou-cd as handle, output phRub-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/jou-cd/rub-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'rub-cle' then phRub-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudParcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteParcpt.
    run updateParcpt.
    run createParcpt.
end procedure.

procedure setParcpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParcpt.
    ghttParcpt = phttParcpt.
    run crudParcpt.
    delete object phttParcpt.
end procedure.

procedure readParcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table parcpt Fichier Parametres Comptes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcJou-cd  as character  no-undo.
    define input parameter pcRub-cle as character  no-undo.
    define input parameter table-handle phttParcpt.
    define variable vhttBuffer as handle no-undo.
    define buffer parcpt for parcpt.

    vhttBuffer = phttParcpt:default-buffer-handle.
    for first parcpt no-lock
        where parcpt.soc-cd = piSoc-cd
          and parcpt.jou-cd = pcJou-cd
          and parcpt.rub-cle = pcRub-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParcpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getParcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table parcpt Fichier Parametres Comptes
    Notes  : service externe. Critère pcJou-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcJou-cd  as character  no-undo.
    define input parameter table-handle phttParcpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer parcpt for parcpt.

    vhttBuffer = phttParcpt:default-buffer-handle.
    if pcJou-cd = ?
    then for each parcpt no-lock
        where parcpt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each parcpt no-lock
        where parcpt.soc-cd = piSoc-cd
          and parcpt.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParcpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateParcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhRub-cle    as handle  no-undo.
    define buffer parcpt for parcpt.

    create query vhttquery.
    vhttBuffer = ghttParcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttParcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhJou-cd, output vhRub-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parcpt exclusive-lock
                where rowid(parcpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parcpt:handle, 'soc-cd/jou-cd/rub-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhJou-cd:buffer-value(), vhRub-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer parcpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createParcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer parcpt for parcpt.

    create query vhttquery.
    vhttBuffer = ghttParcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttParcpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create parcpt.
            if not outils:copyValidField(buffer parcpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteParcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhRub-cle    as handle  no-undo.
    define buffer parcpt for parcpt.

    create query vhttquery.
    vhttBuffer = ghttParcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttParcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhJou-cd, output vhRub-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parcpt exclusive-lock
                where rowid(Parcpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parcpt:handle, 'soc-cd/jou-cd/rub-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhJou-cd:buffer-value(), vhRub-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete parcpt no-error.
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

