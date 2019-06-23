/*------------------------------------------------------------------------
File        : znumtiers_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table znumtiers
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/znumtiers.i}
{application/include/error.i}
define variable ghttznumtiers as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLibtiers-cd as handle, output phTiers-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/libtiers-cd/tiers-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'libtiers-cd' then phLibtiers-cd = phBuffer:buffer-field(vi).
            when 'tiers-num' then phTiers-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudZnumtiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteZnumtiers.
    run updateZnumtiers.
    run createZnumtiers.
end procedure.

procedure setZnumtiers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZnumtiers.
    ghttZnumtiers = phttZnumtiers.
    run crudZnumtiers.
    delete object phttZnumtiers.
end procedure.

procedure readZnumtiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table znumtiers 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piLibtiers-cd as integer    no-undo.
    define input parameter piTiers-num   as integer    no-undo.
    define input parameter table-handle phttZnumtiers.
    define variable vhttBuffer as handle no-undo.
    define buffer znumtiers for znumtiers.

    vhttBuffer = phttZnumtiers:default-buffer-handle.
    for first znumtiers no-lock
        where znumtiers.soc-cd = piSoc-cd
          and znumtiers.libtiers-cd = piLibtiers-cd
          and znumtiers.tiers-num = piTiers-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer znumtiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZnumtiers no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getZnumtiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table znumtiers 
    Notes  : service externe. Critère piLibtiers-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piLibtiers-cd as integer    no-undo.
    define input parameter table-handle phttZnumtiers.
    define variable vhttBuffer as handle  no-undo.
    define buffer znumtiers for znumtiers.

    vhttBuffer = phttZnumtiers:default-buffer-handle.
    if piLibtiers-cd = ?
    then for each znumtiers no-lock
        where znumtiers.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer znumtiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each znumtiers no-lock
        where znumtiers.soc-cd = piSoc-cd
          and znumtiers.libtiers-cd = piLibtiers-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer znumtiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZnumtiers no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateZnumtiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtiers-cd    as handle  no-undo.
    define variable vhTiers-num    as handle  no-undo.
    define buffer znumtiers for znumtiers.

    create query vhttquery.
    vhttBuffer = ghttZnumtiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttZnumtiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtiers-cd, output vhTiers-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first znumtiers exclusive-lock
                where rowid(znumtiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer znumtiers:handle, 'soc-cd/libtiers-cd/tiers-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhLibtiers-cd:buffer-value(), vhTiers-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer znumtiers:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createZnumtiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer znumtiers for znumtiers.

    create query vhttquery.
    vhttBuffer = ghttZnumtiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttZnumtiers:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create znumtiers.
            if not outils:copyValidField(buffer znumtiers:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteZnumtiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtiers-cd    as handle  no-undo.
    define variable vhTiers-num    as handle  no-undo.
    define buffer znumtiers for znumtiers.

    create query vhttquery.
    vhttBuffer = ghttZnumtiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttZnumtiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtiers-cd, output vhTiers-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first znumtiers exclusive-lock
                where rowid(Znumtiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer znumtiers:handle, 'soc-cd/libtiers-cd/tiers-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhLibtiers-cd:buffer-value(), vhTiers-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete znumtiers no-error.
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

