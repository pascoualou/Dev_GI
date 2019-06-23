/*------------------------------------------------------------------------
File        : iformat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iformat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iformat.i}
{application/include/error.i}
define variable ghttiformat as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phGi-client as handle, output phChamps as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur gi-client/champs, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'gi-client' then phGi-client = phBuffer:buffer-field(vi).
            when 'champs' then phChamps = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIformat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIformat.
    run updateIformat.
    run createIformat.
end procedure.

procedure setIformat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIformat.
    ghttIformat = phttIformat.
    run crudIformat.
    delete object phttIformat.
end procedure.

procedure readIformat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iformat Fichier format des champs standard
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-client as character  no-undo.
    define input parameter pcChamps    as character  no-undo.
    define input parameter table-handle phttIformat.
    define variable vhttBuffer as handle no-undo.
    define buffer iformat for iformat.

    vhttBuffer = phttIformat:default-buffer-handle.
    for first iformat no-lock
        where iformat.gi-client = pcGi-client
          and iformat.champs = pcChamps:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iformat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIformat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIformat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iformat Fichier format des champs standard
    Notes  : service externe. Critère pcGi-client = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-client as character  no-undo.
    define input parameter table-handle phttIformat.
    define variable vhttBuffer as handle  no-undo.
    define buffer iformat for iformat.

    vhttBuffer = phttIformat:default-buffer-handle.
    if pcGi-client = ?
    then for each iformat no-lock
        where iformat.gi-client = pcGi-client:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iformat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iformat no-lock
        where iformat.gi-client = pcGi-client:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iformat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIformat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIformat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-client    as handle  no-undo.
    define variable vhChamps    as handle  no-undo.
    define buffer iformat for iformat.

    create query vhttquery.
    vhttBuffer = ghttIformat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIformat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-client, output vhChamps).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iformat exclusive-lock
                where rowid(iformat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iformat:handle, 'gi-client/champs: ', substitute('&1/&2', vhGi-client:buffer-value(), vhChamps:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iformat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIformat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iformat for iformat.

    create query vhttquery.
    vhttBuffer = ghttIformat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIformat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iformat.
            if not outils:copyValidField(buffer iformat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIformat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-client    as handle  no-undo.
    define variable vhChamps    as handle  no-undo.
    define buffer iformat for iformat.

    create query vhttquery.
    vhttBuffer = ghttIformat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIformat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-client, output vhChamps).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iformat exclusive-lock
                where rowid(Iformat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iformat:handle, 'gi-client/champs: ', substitute('&1/&2', vhGi-client:buffer-value(), vhChamps:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iformat no-error.
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

