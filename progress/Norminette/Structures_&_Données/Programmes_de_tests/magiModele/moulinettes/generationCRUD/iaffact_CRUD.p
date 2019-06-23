/*------------------------------------------------------------------------
File        : iaffact_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iaffact
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iaffact.i}
{application/include/error.i}
define variable ghttiaffact as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phAffact-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/affact-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'affact-cle' then phAffact-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIaffact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIaffact.
    run updateIaffact.
    run createIaffact.
end procedure.

procedure setIaffact:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIaffact.
    ghttIaffact = phttIaffact.
    run crudIaffact.
    delete object phttIaffact.
end procedure.

procedure readIaffact:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iaffact fichier affactureur
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcAffact-cle as character  no-undo.
    define input parameter table-handle phttIaffact.
    define variable vhttBuffer as handle no-undo.
    define buffer iaffact for iaffact.

    vhttBuffer = phttIaffact:default-buffer-handle.
    for first iaffact no-lock
        where iaffact.soc-cd = piSoc-cd
          and iaffact.affact-cle = pcAffact-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaffact:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIaffact no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIaffact:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iaffact fichier affactureur
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter table-handle phttIaffact.
    define variable vhttBuffer as handle  no-undo.
    define buffer iaffact for iaffact.

    vhttBuffer = phttIaffact:default-buffer-handle.
    if piSoc-cd = ?
    then for each iaffact no-lock
        where iaffact.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaffact:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iaffact no-lock
        where iaffact.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaffact:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIaffact no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIaffact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhAffact-cle    as handle  no-undo.
    define buffer iaffact for iaffact.

    create query vhttquery.
    vhttBuffer = ghttIaffact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIaffact:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhAffact-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iaffact exclusive-lock
                where rowid(iaffact) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iaffact:handle, 'soc-cd/affact-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhAffact-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iaffact:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIaffact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iaffact for iaffact.

    create query vhttquery.
    vhttBuffer = ghttIaffact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIaffact:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iaffact.
            if not outils:copyValidField(buffer iaffact:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIaffact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhAffact-cle    as handle  no-undo.
    define buffer iaffact for iaffact.

    create query vhttquery.
    vhttBuffer = ghttIaffact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIaffact:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhAffact-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iaffact exclusive-lock
                where rowid(Iaffact) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iaffact:handle, 'soc-cd/affact-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhAffact-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iaffact no-error.
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

