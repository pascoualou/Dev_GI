/*------------------------------------------------------------------------
File        : itrt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itrt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itrt.i}
{application/include/error.i}
define variable ghttitrt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phTrt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/trt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'trt-cd' then phTrt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItrt.
    run updateItrt.
    run createItrt.
end procedure.

procedure setItrt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItrt.
    ghttItrt = phttItrt.
    run crudItrt.
    delete object phttItrt.
end procedure.

procedure readItrt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itrt parametrage traitement en local
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter piTrt-cd as integer    no-undo.
    define input parameter table-handle phttItrt.
    define variable vhttBuffer as handle no-undo.
    define buffer itrt for itrt.

    vhttBuffer = phttItrt:default-buffer-handle.
    for first itrt no-lock
        where itrt.soc-cd = piSoc-cd
          and itrt.trt-cd = piTrt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItrt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItrt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itrt parametrage traitement en local
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttItrt.
    define variable vhttBuffer as handle  no-undo.
    define buffer itrt for itrt.

    vhttBuffer = phttItrt:default-buffer-handle.
    if piSoc-cd = ?
    then for each itrt no-lock
        where itrt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itrt no-lock
        where itrt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItrt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTrt-cd    as handle  no-undo.
    define buffer itrt for itrt.

    create query vhttquery.
    vhttBuffer = ghttItrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItrt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTrt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itrt exclusive-lock
                where rowid(itrt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itrt:handle, 'soc-cd/trt-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTrt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itrt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itrt for itrt.

    create query vhttquery.
    vhttBuffer = ghttItrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItrt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itrt.
            if not outils:copyValidField(buffer itrt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTrt-cd    as handle  no-undo.
    define buffer itrt for itrt.

    create query vhttquery.
    vhttBuffer = ghttItrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItrt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTrt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itrt exclusive-lock
                where rowid(Itrt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itrt:handle, 'soc-cd/trt-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTrt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itrt no-error.
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

