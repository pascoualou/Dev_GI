/*------------------------------------------------------------------------
File        : PrmTv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table PrmTv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/PrmTv.i}
{application/include/error.i}
define variable ghttPrmTv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phCdpar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpPar/CdPar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpPar' then phTppar = phBuffer:buffer-field(vi).
            when 'CdPar' then phCdpar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrmtv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrmtv.
    run updatePrmtv.
    run createPrmtv.
end procedure.

procedure setPrmtv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrmtv.
    ghttPrmtv = phttPrmtv.
    run crudPrmtv.
    delete object phttPrmtv.
end procedure.

procedure readPrmtv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table PrmTv Chaine Travaux : Parametrage des Travaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcCdpar as character  no-undo.
    define input parameter table-handle phttPrmtv.
    define variable vhttBuffer as handle no-undo.
    define buffer PrmTv for PrmTv.

    vhttBuffer = phttPrmtv:default-buffer-handle.
    for first PrmTv no-lock
        where PrmTv.TpPar = pcTppar
          and PrmTv.CdPar = pcCdpar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmTv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmtv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrmtv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table PrmTv Chaine Travaux : Parametrage des Travaux
    Notes  : service externe. Critère pcTppar = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter table-handle phttPrmtv.
    define variable vhttBuffer as handle  no-undo.
    define buffer PrmTv for PrmTv.

    vhttBuffer = phttPrmtv:default-buffer-handle.
    if pcTppar = ?
    then for each PrmTv no-lock
        where PrmTv.TpPar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmTv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each PrmTv no-lock
        where PrmTv.TpPar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmTv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmtv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrmtv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer PrmTv for PrmTv.

    create query vhttquery.
    vhttBuffer = ghttPrmtv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrmtv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmTv exclusive-lock
                where rowid(PrmTv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmTv:handle, 'TpPar/CdPar: ', substitute('&1/&2', vhTppar:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer PrmTv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrmtv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer PrmTv for PrmTv.

    create query vhttquery.
    vhttBuffer = ghttPrmtv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrmtv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create PrmTv.
            if not outils:copyValidField(buffer PrmTv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrmtv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer PrmTv for PrmTv.

    create query vhttquery.
    vhttBuffer = ghttPrmtv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrmtv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmTv exclusive-lock
                where rowid(Prmtv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmTv:handle, 'TpPar/CdPar: ', substitute('&1/&2', vhTppar:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete PrmTv no-error.
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

