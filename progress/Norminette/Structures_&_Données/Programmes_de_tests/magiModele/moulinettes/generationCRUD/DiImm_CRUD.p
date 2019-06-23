/*------------------------------------------------------------------------
File        : DiImm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DiImm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DiImm.i}
{application/include/error.i}
define variable ghttDiImm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phTpdis as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/TpDis, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'TpDis' then phTpdis = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDiimm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDiimm.
    run updateDiimm.
    run createDiimm.
end procedure.

procedure setDiimm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDiimm.
    ghttDiimm = phttDiimm.
    run crudDiimm.
    delete object phttDiimm.
end procedure.

procedure readDiimm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DiImm Dispositions Légales sur l'Immeuble
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpdis as character  no-undo.
    define input parameter table-handle phttDiimm.
    define variable vhttBuffer as handle no-undo.
    define buffer DiImm for DiImm.

    vhttBuffer = phttDiimm:default-buffer-handle.
    for first DiImm no-lock
        where DiImm.noimm = piNoimm
          and DiImm.TpDis = pcTpdis:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DiImm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDiimm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDiimm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DiImm Dispositions Légales sur l'Immeuble
    Notes  : service externe. Critère piNoimm = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttDiimm.
    define variable vhttBuffer as handle  no-undo.
    define buffer DiImm for DiImm.

    vhttBuffer = phttDiimm:default-buffer-handle.
    if piNoimm = ?
    then for each DiImm no-lock
        where DiImm.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DiImm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DiImm no-lock
        where DiImm.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DiImm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDiimm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDiimm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhTpdis    as handle  no-undo.
    define buffer DiImm for DiImm.

    create query vhttquery.
    vhttBuffer = ghttDiimm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDiimm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhTpdis).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DiImm exclusive-lock
                where rowid(DiImm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DiImm:handle, 'noimm/TpDis: ', substitute('&1/&2', vhNoimm:buffer-value(), vhTpdis:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DiImm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDiimm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DiImm for DiImm.

    create query vhttquery.
    vhttBuffer = ghttDiimm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDiimm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DiImm.
            if not outils:copyValidField(buffer DiImm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDiimm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhTpdis    as handle  no-undo.
    define buffer DiImm for DiImm.

    create query vhttquery.
    vhttBuffer = ghttDiimm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDiimm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhTpdis).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DiImm exclusive-lock
                where rowid(Diimm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DiImm:handle, 'noimm/TpDis: ', substitute('&1/&2', vhNoimm:buffer-value(), vhTpdis:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DiImm no-error.
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

