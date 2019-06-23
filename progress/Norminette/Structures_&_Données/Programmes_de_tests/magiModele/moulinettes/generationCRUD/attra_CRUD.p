/*------------------------------------------------------------------------
File        : attra_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table attra
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/attra.i}
{application/include/error.i}
define variable ghttattra as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoexo as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noexo/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAttra private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAttra.
    run updateAttra.
    run createAttra.
end procedure.

procedure setAttra:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAttra.
    ghttAttra = phttAttra.
    run crudAttra.
    delete object phttAttra.
end procedure.

procedure readAttra:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table attra 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttAttra.
    define variable vhttBuffer as handle no-undo.
    define buffer attra for attra.

    vhttBuffer = phttAttra:default-buffer-handle.
    for first attra no-lock
        where attra.tpcon = pcTpcon
          and attra.nocon = piNocon
          and attra.noexo = piNoexo
          and attra.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer attra:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAttra no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAttra:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table attra 
    Notes  : service externe. Critère piNoexo = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter table-handle phttAttra.
    define variable vhttBuffer as handle  no-undo.
    define buffer attra for attra.

    vhttBuffer = phttAttra:default-buffer-handle.
    if piNoexo = ?
    then for each attra no-lock
        where attra.tpcon = pcTpcon
          and attra.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer attra:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each attra no-lock
        where attra.tpcon = pcTpcon
          and attra.nocon = piNocon
          and attra.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer attra:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAttra no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAttra private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer attra for attra.

    create query vhttquery.
    vhttBuffer = ghttAttra:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAttra:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first attra exclusive-lock
                where rowid(attra) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer attra:handle, 'tpcon/nocon/noexo/nolig: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer attra:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAttra private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer attra for attra.

    create query vhttquery.
    vhttBuffer = ghttAttra:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAttra:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create attra.
            if not outils:copyValidField(buffer attra:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAttra private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer attra for attra.

    create query vhttquery.
    vhttBuffer = ghttAttra:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAttra:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first attra exclusive-lock
                where rowid(Attra) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer attra:handle, 'tpcon/nocon/noexo/nolig: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete attra no-error.
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

