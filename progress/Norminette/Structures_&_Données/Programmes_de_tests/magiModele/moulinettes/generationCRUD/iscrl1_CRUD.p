/*------------------------------------------------------------------------
File        : iscrl1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iscrl1
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iscrl1.i}
{application/include/error.i}
define variable ghttiscrl1 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phScrl-num as handle, output phSiren-num as handle, output phNic-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/scrl-num/siren-num/nic-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'scrl-num' then phScrl-num = phBuffer:buffer-field(vi).
            when 'siren-num' then phSiren-num = phBuffer:buffer-field(vi).
            when 'nic-num' then phNic-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIscrl1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIscrl1.
    run updateIscrl1.
    run createIscrl1.
end procedure.

procedure setIscrl1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIscrl1.
    ghttIscrl1 = phttIscrl1.
    run crudIscrl1.
    delete object phttIscrl1.
end procedure.

procedure readIscrl1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iscrl1 avis d'office
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piScrl-num  as integer    no-undo.
    define input parameter piSiren-num as integer    no-undo.
    define input parameter piNic-num   as integer    no-undo.
    define input parameter table-handle phttIscrl1.
    define variable vhttBuffer as handle no-undo.
    define buffer iscrl1 for iscrl1.

    vhttBuffer = phttIscrl1:default-buffer-handle.
    for first iscrl1 no-lock
        where iscrl1.soc-cd = piSoc-cd
          and iscrl1.scrl-num = piScrl-num
          and iscrl1.siren-num = piSiren-num
          and iscrl1.nic-num = piNic-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscrl1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscrl1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIscrl1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iscrl1 avis d'office
    Notes  : service externe. Critère piSiren-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piScrl-num  as integer    no-undo.
    define input parameter piSiren-num as integer    no-undo.
    define input parameter table-handle phttIscrl1.
    define variable vhttBuffer as handle  no-undo.
    define buffer iscrl1 for iscrl1.

    vhttBuffer = phttIscrl1:default-buffer-handle.
    if piSiren-num = ?
    then for each iscrl1 no-lock
        where iscrl1.soc-cd = piSoc-cd
          and iscrl1.scrl-num = piScrl-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscrl1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iscrl1 no-lock
        where iscrl1.soc-cd = piSoc-cd
          and iscrl1.scrl-num = piScrl-num
          and iscrl1.siren-num = piSiren-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscrl1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscrl1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIscrl1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhScrl-num    as handle  no-undo.
    define variable vhSiren-num    as handle  no-undo.
    define variable vhNic-num    as handle  no-undo.
    define buffer iscrl1 for iscrl1.

    create query vhttquery.
    vhttBuffer = ghttIscrl1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIscrl1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhScrl-num, output vhSiren-num, output vhNic-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscrl1 exclusive-lock
                where rowid(iscrl1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscrl1:handle, 'soc-cd/scrl-num/siren-num/nic-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhScrl-num:buffer-value(), vhSiren-num:buffer-value(), vhNic-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iscrl1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIscrl1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iscrl1 for iscrl1.

    create query vhttquery.
    vhttBuffer = ghttIscrl1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIscrl1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iscrl1.
            if not outils:copyValidField(buffer iscrl1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIscrl1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhScrl-num    as handle  no-undo.
    define variable vhSiren-num    as handle  no-undo.
    define variable vhNic-num    as handle  no-undo.
    define buffer iscrl1 for iscrl1.

    create query vhttquery.
    vhttBuffer = ghttIscrl1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIscrl1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhScrl-num, output vhSiren-num, output vhNic-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscrl1 exclusive-lock
                where rowid(Iscrl1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscrl1:handle, 'soc-cd/scrl-num/siren-num/nic-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhScrl-num:buffer-value(), vhSiren-num:buffer-value(), vhNic-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iscrl1 no-error.
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

