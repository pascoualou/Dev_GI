/*------------------------------------------------------------------------
File        : iengin_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iengin
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iengin.i}
{application/include/error.i}
define variable ghttiengin as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phEngin-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/engin-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'engin-num' then phEngin-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIengin private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIengin.
    run updateIengin.
    run createIengin.
end procedure.

procedure setIengin:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIengin.
    ghttIengin = phttIengin.
    run crudIengin.
    delete object phttIengin.
end procedure.

procedure readIengin:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iengin 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piEngin-num as integer    no-undo.
    define input parameter table-handle phttIengin.
    define variable vhttBuffer as handle no-undo.
    define buffer iengin for iengin.

    vhttBuffer = phttIengin:default-buffer-handle.
    for first iengin no-lock
        where iengin.soc-cd = piSoc-cd
          and iengin.etab-cd = piEtab-cd
          and iengin.engin-num = piEngin-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengin:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengin no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIengin:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iengin 
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter table-handle phttIengin.
    define variable vhttBuffer as handle  no-undo.
    define buffer iengin for iengin.

    vhttBuffer = phttIengin:default-buffer-handle.
    if piEtab-cd = ?
    then for each iengin no-lock
        where iengin.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengin:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iengin no-lock
        where iengin.soc-cd = piSoc-cd
          and iengin.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengin:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengin no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIengin private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEngin-num    as handle  no-undo.
    define buffer iengin for iengin.

    create query vhttquery.
    vhttBuffer = ghttIengin:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIengin:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEngin-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengin exclusive-lock
                where rowid(iengin) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengin:handle, 'soc-cd/etab-cd/engin-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEngin-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iengin:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIengin private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iengin for iengin.

    create query vhttquery.
    vhttBuffer = ghttIengin:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIengin:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iengin.
            if not outils:copyValidField(buffer iengin:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIengin private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEngin-num    as handle  no-undo.
    define buffer iengin for iengin.

    create query vhttquery.
    vhttBuffer = ghttIengin:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIengin:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEngin-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengin exclusive-lock
                where rowid(Iengin) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengin:handle, 'soc-cd/etab-cd/engin-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEngin-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iengin no-error.
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

