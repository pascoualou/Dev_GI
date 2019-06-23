/*------------------------------------------------------------------------
File        : tardt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tardt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tardt.i}
{application/include/error.i}
define variable ghtttardt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdart as handle, output phNofou as handle, output phNoimm as handle, output phNomdt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CdArt/NoFou/NoImm/nomdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CdArt' then phCdart = phBuffer:buffer-field(vi).
            when 'NoFou' then phNofou = phBuffer:buffer-field(vi).
            when 'NoImm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTardt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTardt.
    run updateTardt.
    run createTardt.
end procedure.

procedure setTardt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTardt.
    ghttTardt = phttTardt.
    run crudTardt.
    delete object phttTardt.
end procedure.

procedure readTardt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tardt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdart as character  no-undo.
    define input parameter piNofou as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttTardt.
    define variable vhttBuffer as handle no-undo.
    define buffer tardt for tardt.

    vhttBuffer = phttTardt:default-buffer-handle.
    for first tardt no-lock
        where tardt.CdArt = pcCdart
          and tardt.NoFou = piNofou
          and tardt.NoImm = piNoimm
          and tardt.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tardt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTardt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTardt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tardt 
    Notes  : service externe. Critère piNoimm = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdart as character  no-undo.
    define input parameter piNofou as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttTardt.
    define variable vhttBuffer as handle  no-undo.
    define buffer tardt for tardt.

    vhttBuffer = phttTardt:default-buffer-handle.
    if piNoimm = ?
    then for each tardt no-lock
        where tardt.CdArt = pcCdart
          and tardt.NoFou = piNofou:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tardt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tardt no-lock
        where tardt.CdArt = pcCdart
          and tardt.NoFou = piNofou
          and tardt.NoImm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tardt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTardt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTardt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdart    as handle  no-undo.
    define variable vhNofou    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer tardt for tardt.

    create query vhttquery.
    vhttBuffer = ghttTardt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTardt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdart, output vhNofou, output vhNoimm, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tardt exclusive-lock
                where rowid(tardt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tardt:handle, 'CdArt/NoFou/NoImm/nomdt: ', substitute('&1/&2/&3/&4', vhCdart:buffer-value(), vhNofou:buffer-value(), vhNoimm:buffer-value(), vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tardt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTardt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tardt for tardt.

    create query vhttquery.
    vhttBuffer = ghttTardt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTardt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tardt.
            if not outils:copyValidField(buffer tardt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTardt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdart    as handle  no-undo.
    define variable vhNofou    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer tardt for tardt.

    create query vhttquery.
    vhttBuffer = ghttTardt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTardt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdart, output vhNofou, output vhNoimm, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tardt exclusive-lock
                where rowid(Tardt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tardt:handle, 'CdArt/NoFou/NoImm/nomdt: ', substitute('&1/&2/&3/&4', vhCdart:buffer-value(), vhNofou:buffer-value(), vhNoimm:buffer-value(), vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tardt no-error.
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

