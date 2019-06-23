/*------------------------------------------------------------------------
File        : image_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table image
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/image.i}
{application/include/error.i}
define variable ghttimage as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phNmrep as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/nmrep/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'nmrep' then phNmrep = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudImage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteImage.
    run updateImage.
    run createImage.
end procedure.

procedure setImage:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImage.
    ghttImage = phttImage.
    run crudImage.
    delete object phttImage.
end procedure.

procedure readImage:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table image 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcNmrep as character  no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttImage.
    define variable vhttBuffer as handle no-undo.
    define buffer image for image.

    vhttBuffer = phttImage:default-buffer-handle.
    for first image no-lock
        where image.tpidt = pcTpidt
          and image.noidt = piNoidt
          and image.nmrep = pcNmrep
          and image.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer image:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImage no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getImage:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table image 
    Notes  : service externe. Critère pcNmrep = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcNmrep as character  no-undo.
    define input parameter table-handle phttImage.
    define variable vhttBuffer as handle  no-undo.
    define buffer image for image.

    vhttBuffer = phttImage:default-buffer-handle.
    if pcNmrep = ?
    then for each image no-lock
        where image.tpidt = pcTpidt
          and image.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer image:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each image no-lock
        where image.tpidt = pcTpidt
          and image.noidt = piNoidt
          and image.nmrep = pcNmrep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer image:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImage no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateImage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNmrep    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer image for image.

    create query vhttquery.
    vhttBuffer = ghttImage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttImage:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNmrep, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first image exclusive-lock
                where rowid(image) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer image:handle, 'tpidt/noidt/nmrep/noord: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNmrep:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer image:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createImage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer image for image.

    create query vhttquery.
    vhttBuffer = ghttImage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttImage:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create image.
            if not outils:copyValidField(buffer image:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteImage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNmrep    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer image for image.

    create query vhttquery.
    vhttBuffer = ghttImage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttImage:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNmrep, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first image exclusive-lock
                where rowid(Image) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer image:handle, 'tpidt/noidt/nmrep/noord: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNmrep:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete image no-error.
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

