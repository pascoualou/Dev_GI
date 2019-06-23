/*------------------------------------------------------------------------
File        : taffcoul_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table taffcoul
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/taffcoul.i}
{application/include/error.i}
define variable ghtttaffcoul as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phPalette as handle, output phCode_affcoul as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur palette/code_affcoul, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'palette' then phPalette = phBuffer:buffer-field(vi).
            when 'code_affcoul' then phCode_affcoul = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTaffcoul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTaffcoul.
    run updateTaffcoul.
    run createTaffcoul.
end procedure.

procedure setTaffcoul:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTaffcoul.
    ghttTaffcoul = phttTaffcoul.
    run crudTaffcoul.
    delete object phttTaffcoul.
end procedure.

procedure readTaffcoul:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table taffcoul 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piPalette      as integer    no-undo.
    define input parameter pcCode_affcoul as character  no-undo.
    define input parameter table-handle phttTaffcoul.
    define variable vhttBuffer as handle no-undo.
    define buffer taffcoul for taffcoul.

    vhttBuffer = phttTaffcoul:default-buffer-handle.
    for first taffcoul no-lock
        where taffcoul.palette = piPalette
          and taffcoul.code_affcoul = pcCode_affcoul:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer taffcoul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTaffcoul no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTaffcoul:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table taffcoul 
    Notes  : service externe. Critère piPalette = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piPalette      as integer    no-undo.
    define input parameter table-handle phttTaffcoul.
    define variable vhttBuffer as handle  no-undo.
    define buffer taffcoul for taffcoul.

    vhttBuffer = phttTaffcoul:default-buffer-handle.
    if piPalette = ?
    then for each taffcoul no-lock
        where taffcoul.palette = piPalette:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer taffcoul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each taffcoul no-lock
        where taffcoul.palette = piPalette:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer taffcoul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTaffcoul no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTaffcoul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPalette    as handle  no-undo.
    define variable vhCode_affcoul    as handle  no-undo.
    define buffer taffcoul for taffcoul.

    create query vhttquery.
    vhttBuffer = ghttTaffcoul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTaffcoul:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPalette, output vhCode_affcoul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first taffcoul exclusive-lock
                where rowid(taffcoul) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer taffcoul:handle, 'palette/code_affcoul: ', substitute('&1/&2', vhPalette:buffer-value(), vhCode_affcoul:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer taffcoul:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTaffcoul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer taffcoul for taffcoul.

    create query vhttquery.
    vhttBuffer = ghttTaffcoul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTaffcoul:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create taffcoul.
            if not outils:copyValidField(buffer taffcoul:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTaffcoul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPalette    as handle  no-undo.
    define variable vhCode_affcoul    as handle  no-undo.
    define buffer taffcoul for taffcoul.

    create query vhttquery.
    vhttBuffer = ghttTaffcoul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTaffcoul:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPalette, output vhCode_affcoul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first taffcoul exclusive-lock
                where rowid(Taffcoul) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer taffcoul:handle, 'palette/code_affcoul: ', substitute('&1/&2', vhPalette:buffer-value(), vhCode_affcoul:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete taffcoul no-error.
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

