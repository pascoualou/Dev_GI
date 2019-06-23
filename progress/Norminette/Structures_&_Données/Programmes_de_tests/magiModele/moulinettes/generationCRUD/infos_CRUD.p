/*------------------------------------------------------------------------
File        : infos_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table infos
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/infos.i}
{application/include/error.i}
define variable ghttinfos as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpinf as handle, output phCdinf as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpinf/cdinf, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpinf' then phTpinf = phBuffer:buffer-field(vi).
            when 'cdinf' then phCdinf = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudInfos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteInfos.
    run updateInfos.
    run createInfos.
end procedure.

procedure setInfos:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttInfos.
    ghttInfos = phttInfos.
    run crudInfos.
    delete object phttInfos.
end procedure.

procedure readInfos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table infos 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpinf as character  no-undo.
    define input parameter pcCdinf as character  no-undo.
    define input parameter table-handle phttInfos.
    define variable vhttBuffer as handle no-undo.
    define buffer infos for infos.

    vhttBuffer = phttInfos:default-buffer-handle.
    for first infos no-lock
        where infos.tpinf = pcTpinf
          and infos.cdinf = pcCdinf:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer infos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInfos no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getInfos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table infos 
    Notes  : service externe. Critère pcTpinf = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpinf as character  no-undo.
    define input parameter table-handle phttInfos.
    define variable vhttBuffer as handle  no-undo.
    define buffer infos for infos.

    vhttBuffer = phttInfos:default-buffer-handle.
    if pcTpinf = ?
    then for each infos no-lock
        where infos.tpinf = pcTpinf:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer infos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each infos no-lock
        where infos.tpinf = pcTpinf:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer infos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInfos no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateInfos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpinf    as handle  no-undo.
    define variable vhCdinf    as handle  no-undo.
    define buffer infos for infos.

    create query vhttquery.
    vhttBuffer = ghttInfos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttInfos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpinf, output vhCdinf).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first infos exclusive-lock
                where rowid(infos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer infos:handle, 'tpinf/cdinf: ', substitute('&1/&2', vhTpinf:buffer-value(), vhCdinf:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer infos:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createInfos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer infos for infos.

    create query vhttquery.
    vhttBuffer = ghttInfos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttInfos:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create infos.
            if not outils:copyValidField(buffer infos:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteInfos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpinf    as handle  no-undo.
    define variable vhCdinf    as handle  no-undo.
    define buffer infos for infos.

    create query vhttquery.
    vhttBuffer = ghttInfos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttInfos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpinf, output vhCdinf).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first infos exclusive-lock
                where rowid(Infos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer infos:handle, 'tpinf/cdinf: ', substitute('&1/&2', vhTpinf:buffer-value(), vhCdinf:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete infos no-error.
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

