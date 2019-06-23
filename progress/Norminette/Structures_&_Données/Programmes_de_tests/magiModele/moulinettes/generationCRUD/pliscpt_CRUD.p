/*------------------------------------------------------------------------
File        : pliscpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pliscpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pliscpt.i}
{application/include/error.i}
define variable ghttpliscpt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phGi-ttyid as handle, output phJou-cd as handle, output phDacompta as handle, output phPiece-compta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur gi-ttyid/jou-cd/dacompta/piece-compta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'gi-ttyid' then phGi-ttyid = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'dacompta' then phDacompta = phBuffer:buffer-field(vi).
            when 'piece-compta' then phPiece-compta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPliscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePliscpt.
    run updatePliscpt.
    run createPliscpt.
end procedure.

procedure setPliscpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPliscpt.
    ghttPliscpt = phttPliscpt.
    run crudPliscpt.
    delete object phttPliscpt.
end procedure.

procedure readPliscpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pliscpt Fichier temporaire des pieces comptabilisees
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid     as character  no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter pdaDacompta     as date       no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter table-handle phttPliscpt.
    define variable vhttBuffer as handle no-undo.
    define buffer pliscpt for pliscpt.

    vhttBuffer = phttPliscpt:default-buffer-handle.
    for first pliscpt no-lock
        where pliscpt.gi-ttyid = pcGi-ttyid
          and pliscpt.jou-cd = pcJou-cd
          and pliscpt.dacompta = pdaDacompta
          and pliscpt.piece-compta = piPiece-compta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pliscpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPliscpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPliscpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pliscpt Fichier temporaire des pieces comptabilisees
    Notes  : service externe. Critère pdaDacompta = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid     as character  no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter pdaDacompta     as date       no-undo.
    define input parameter table-handle phttPliscpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer pliscpt for pliscpt.

    vhttBuffer = phttPliscpt:default-buffer-handle.
    if pdaDacompta = ?
    then for each pliscpt no-lock
        where pliscpt.gi-ttyid = pcGi-ttyid
          and pliscpt.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pliscpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pliscpt no-lock
        where pliscpt.gi-ttyid = pcGi-ttyid
          and pliscpt.jou-cd = pcJou-cd
          and pliscpt.dacompta = pdaDacompta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pliscpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPliscpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePliscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define buffer pliscpt for pliscpt.

    create query vhttquery.
    vhttBuffer = ghttPliscpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPliscpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhJou-cd, output vhDacompta, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pliscpt exclusive-lock
                where rowid(pliscpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pliscpt:handle, 'gi-ttyid/jou-cd/dacompta/piece-compta: ', substitute('&1/&2/&3/&4', vhGi-ttyid:buffer-value(), vhJou-cd:buffer-value(), vhDacompta:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pliscpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPliscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pliscpt for pliscpt.

    create query vhttquery.
    vhttBuffer = ghttPliscpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPliscpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pliscpt.
            if not outils:copyValidField(buffer pliscpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePliscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define buffer pliscpt for pliscpt.

    create query vhttquery.
    vhttBuffer = ghttPliscpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPliscpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhJou-cd, output vhDacompta, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pliscpt exclusive-lock
                where rowid(Pliscpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pliscpt:handle, 'gi-ttyid/jou-cd/dacompta/piece-compta: ', substitute('&1/&2/&3/&4', vhGi-ttyid:buffer-value(), vhJou-cd:buffer-value(), vhDacompta:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pliscpt no-error.
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

