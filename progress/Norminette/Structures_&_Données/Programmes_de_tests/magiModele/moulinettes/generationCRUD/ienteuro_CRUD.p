/*------------------------------------------------------------------------
File        : ienteuro_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ienteuro
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ienteuro.i}
{application/include/error.i}
define variable ghttienteuro as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNom as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/nom, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'nom' then phNom = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIenteuro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIenteuro.
    run updateIenteuro.
    run createIenteuro.
end procedure.

procedure setIenteuro:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIenteuro.
    ghttIenteuro = phttIenteuro.
    run crudIenteuro.
    delete object phttIenteuro.
end procedure.

procedure readIenteuro:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ienteuro table a convertir en euro
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter pcNom    as character  no-undo.
    define input parameter table-handle phttIenteuro.
    define variable vhttBuffer as handle no-undo.
    define buffer ienteuro for ienteuro.

    vhttBuffer = phttIenteuro:default-buffer-handle.
    for first ienteuro no-lock
        where ienteuro.soc-cd = piSoc-cd
          and ienteuro.nom = pcNom:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ienteuro:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIenteuro no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIenteuro:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ienteuro table a convertir en euro
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttIenteuro.
    define variable vhttBuffer as handle  no-undo.
    define buffer ienteuro for ienteuro.

    vhttBuffer = phttIenteuro:default-buffer-handle.
    if piSoc-cd = ?
    then for each ienteuro no-lock
        where ienteuro.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ienteuro:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ienteuro no-lock
        where ienteuro.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ienteuro:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIenteuro no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIenteuro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNom    as handle  no-undo.
    define buffer ienteuro for ienteuro.

    create query vhttquery.
    vhttBuffer = ghttIenteuro:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIenteuro:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ienteuro exclusive-lock
                where rowid(ienteuro) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ienteuro:handle, 'soc-cd/nom: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNom:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ienteuro:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIenteuro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ienteuro for ienteuro.

    create query vhttquery.
    vhttBuffer = ghttIenteuro:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIenteuro:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ienteuro.
            if not outils:copyValidField(buffer ienteuro:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIenteuro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNom    as handle  no-undo.
    define buffer ienteuro for ienteuro.

    create query vhttquery.
    vhttBuffer = ghttIenteuro:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIenteuro:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ienteuro exclusive-lock
                where rowid(Ienteuro) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ienteuro:handle, 'soc-cd/nom: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNom:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ienteuro no-error.
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

