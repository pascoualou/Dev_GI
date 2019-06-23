/*------------------------------------------------------------------------
File        : iscicoll_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iscicoll
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iscicoll.i}
{application/include/error.i}
define variable ghttiscicoll as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phSscoll-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/sscoll-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIscicoll private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIscicoll.
    run updateIscicoll.
    run createIscicoll.
end procedure.

procedure setIscicoll:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIscicoll.
    ghttIscicoll = phttIscicoll.
    run crudIscicoll.
    delete object phttIscicoll.
end procedure.

procedure readIscicoll:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iscicoll Table des correspondances collectifs SCI
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter table-handle phttIscicoll.
    define variable vhttBuffer as handle no-undo.
    define buffer iscicoll for iscicoll.

    vhttBuffer = phttIscicoll:default-buffer-handle.
    for first iscicoll no-lock
        where iscicoll.soc-cd = piSoc-cd
          and iscicoll.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscicoll:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscicoll no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIscicoll:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iscicoll Table des correspondances collectifs SCI
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter table-handle phttIscicoll.
    define variable vhttBuffer as handle  no-undo.
    define buffer iscicoll for iscicoll.

    vhttBuffer = phttIscicoll:default-buffer-handle.
    if piSoc-cd = ?
    then for each iscicoll no-lock
        where iscicoll.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscicoll:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iscicoll no-lock
        where iscicoll.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscicoll:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscicoll no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIscicoll private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define buffer iscicoll for iscicoll.

    create query vhttquery.
    vhttBuffer = ghttIscicoll:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIscicoll:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSscoll-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscicoll exclusive-lock
                where rowid(iscicoll) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscicoll:handle, 'soc-cd/sscoll-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhSscoll-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iscicoll:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIscicoll private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iscicoll for iscicoll.

    create query vhttquery.
    vhttBuffer = ghttIscicoll:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIscicoll:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iscicoll.
            if not outils:copyValidField(buffer iscicoll:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIscicoll private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define buffer iscicoll for iscicoll.

    create query vhttquery.
    vhttBuffer = ghttIscicoll:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIscicoll:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSscoll-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscicoll exclusive-lock
                where rowid(Iscicoll) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscicoll:handle, 'soc-cd/sscoll-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhSscoll-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iscicoll no-error.
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

