/*------------------------------------------------------------------------
File        : psecven_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table psecven
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/psecven.i}
{application/include/error.i}
define variable ghttpsecven as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phSecven-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/secven-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'secven-cd' then phSecven-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPsecven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePsecven.
    run updatePsecven.
    run createPsecven.
end procedure.

procedure setPsecven:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPsecven.
    ghttPsecven = phttPsecven.
    run crudPsecven.
    delete object phttPsecven.
end procedure.

procedure readPsecven:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table psecven Fichier secteur de vente
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piSecven-cd as integer    no-undo.
    define input parameter table-handle phttPsecven.
    define variable vhttBuffer as handle no-undo.
    define buffer psecven for psecven.

    vhttBuffer = phttPsecven:default-buffer-handle.
    for first psecven no-lock
        where psecven.soc-cd = piSoc-cd
          and psecven.secven-cd = piSecven-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer psecven:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPsecven no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPsecven:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table psecven Fichier secteur de vente
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter table-handle phttPsecven.
    define variable vhttBuffer as handle  no-undo.
    define buffer psecven for psecven.

    vhttBuffer = phttPsecven:default-buffer-handle.
    if piSoc-cd = ?
    then for each psecven no-lock
        where psecven.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer psecven:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each psecven no-lock
        where psecven.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer psecven:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPsecven no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePsecven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSecven-cd    as handle  no-undo.
    define buffer psecven for psecven.

    create query vhttquery.
    vhttBuffer = ghttPsecven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPsecven:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSecven-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first psecven exclusive-lock
                where rowid(psecven) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer psecven:handle, 'soc-cd/secven-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhSecven-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer psecven:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPsecven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer psecven for psecven.

    create query vhttquery.
    vhttBuffer = ghttPsecven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPsecven:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create psecven.
            if not outils:copyValidField(buffer psecven:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePsecven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSecven-cd    as handle  no-undo.
    define buffer psecven for psecven.

    create query vhttquery.
    vhttBuffer = ghttPsecven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPsecven:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSecven-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first psecven exclusive-lock
                where rowid(Psecven) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer psecven:handle, 'soc-cd/secven-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhSecven-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete psecven no-error.
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

