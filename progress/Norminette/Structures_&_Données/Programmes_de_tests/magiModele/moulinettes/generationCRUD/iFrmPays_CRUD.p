/*------------------------------------------------------------------------
File        : iFrmPays_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iFrmPays
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iFrmPays.i}
{application/include/error.i}
define variable ghttiFrmPays as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdiso2 as handle, output phCdtrt as handle, output phFgetr as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdiso2/cdtrt/fgEtr, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdiso2' then phCdiso2 = phBuffer:buffer-field(vi).
            when 'cdtrt' then phCdtrt = phBuffer:buffer-field(vi).
            when 'fgEtr' then phFgetr = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfrmpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfrmpays.
    run updateIfrmpays.
    run createIfrmpays.
end procedure.

procedure setIfrmpays:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfrmpays.
    ghttIfrmpays = phttIfrmpays.
    run crudIfrmpays.
    delete object phttIfrmpays.
end procedure.

procedure readIfrmpays:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iFrmPays Table des formats bancaires par pays
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdiso2 as character  no-undo.
    define input parameter pcCdtrt  as character  no-undo.
    define input parameter plFgetr  as logical    no-undo.
    define input parameter table-handle phttIfrmpays.
    define variable vhttBuffer as handle no-undo.
    define buffer iFrmPays for iFrmPays.

    vhttBuffer = phttIfrmpays:default-buffer-handle.
    for first iFrmPays no-lock
        where iFrmPays.cdiso2 = pcCdiso2
          and iFrmPays.cdtrt = pcCdtrt
          and iFrmPays.fgEtr = plFgetr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iFrmPays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfrmpays no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfrmpays:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iFrmPays Table des formats bancaires par pays
    Notes  : service externe. Critère pcCdtrt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdiso2 as character  no-undo.
    define input parameter pcCdtrt  as character  no-undo.
    define input parameter table-handle phttIfrmpays.
    define variable vhttBuffer as handle  no-undo.
    define buffer iFrmPays for iFrmPays.

    vhttBuffer = phttIfrmpays:default-buffer-handle.
    if pcCdtrt = ?
    then for each iFrmPays no-lock
        where iFrmPays.cdiso2 = pcCdiso2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iFrmPays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iFrmPays no-lock
        where iFrmPays.cdiso2 = pcCdiso2
          and iFrmPays.cdtrt = pcCdtrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iFrmPays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfrmpays no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfrmpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdiso2    as handle  no-undo.
    define variable vhCdtrt    as handle  no-undo.
    define variable vhFgetr    as handle  no-undo.
    define buffer iFrmPays for iFrmPays.

    create query vhttquery.
    vhttBuffer = ghttIfrmpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfrmpays:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdiso2, output vhCdtrt, output vhFgetr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iFrmPays exclusive-lock
                where rowid(iFrmPays) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iFrmPays:handle, 'cdiso2/cdtrt/fgEtr: ', substitute('&1/&2/&3', vhCdiso2:buffer-value(), vhCdtrt:buffer-value(), vhFgetr:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iFrmPays:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfrmpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iFrmPays for iFrmPays.

    create query vhttquery.
    vhttBuffer = ghttIfrmpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfrmpays:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iFrmPays.
            if not outils:copyValidField(buffer iFrmPays:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfrmpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdiso2    as handle  no-undo.
    define variable vhCdtrt    as handle  no-undo.
    define variable vhFgetr    as handle  no-undo.
    define buffer iFrmPays for iFrmPays.

    create query vhttquery.
    vhttBuffer = ghttIfrmpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfrmpays:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdiso2, output vhCdtrt, output vhFgetr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iFrmPays exclusive-lock
                where rowid(Ifrmpays) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iFrmPays:handle, 'cdiso2/cdtrt/fgEtr: ', substitute('&1/&2/&3', vhCdiso2:buffer-value(), vhCdtrt:buffer-value(), vhFgetr:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iFrmPays no-error.
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

