/*------------------------------------------------------------------------
File        : salar_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table salar
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/salar.i}
{application/include/error.i}
define variable ghttsalar as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSalar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSalar.
    run updateSalar.
    run createSalar.
end procedure.

procedure setSalar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSalar.
    ghttSalar = phttSalar.
    run crudSalar.
    delete object phttSalar.
end procedure.

procedure readSalar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table salar 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter table-handle phttSalar.
    define variable vhttBuffer as handle no-undo.
    define buffer salar for salar.

    vhttBuffer = phttSalar:default-buffer-handle.
    for first salar no-lock
        where salar.tprol = pcTprol
          and salar.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalar no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSalar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table salar 
    Notes  : service externe. Critère pcTprol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter table-handle phttSalar.
    define variable vhttBuffer as handle  no-undo.
    define buffer salar for salar.

    vhttBuffer = phttSalar:default-buffer-handle.
    if pcTprol = ?
    then for each salar no-lock
        where salar.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each salar no-lock
        where salar.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalar no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSalar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer salar for salar.

    create query vhttquery.
    vhttBuffer = ghttSalar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSalar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salar exclusive-lock
                where rowid(salar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salar:handle, 'tprol/norol: ', substitute('&1/&2', vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer salar:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSalar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer salar for salar.

    create query vhttquery.
    vhttBuffer = ghttSalar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSalar:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create salar.
            if not outils:copyValidField(buffer salar:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSalar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer salar for salar.

    create query vhttquery.
    vhttBuffer = ghttSalar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSalar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salar exclusive-lock
                where rowid(Salar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salar:handle, 'tprol/norol: ', substitute('&1/&2', vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete salar no-error.
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

