/*------------------------------------------------------------------------
File        : ifdsfam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdsfam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdsfam.i}
{application/include/error.i}
define variable ghttifdsfam as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phSfam-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/sfam-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'sfam-cle' then phSfam-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdsfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdsfam.
    run updateIfdsfam.
    run createIfdsfam.
end procedure.

procedure setIfdsfam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdsfam.
    ghttIfdsfam = phttIfdsfam.
    run crudIfdsfam.
    delete object phttIfdsfam.
end procedure.

procedure readIfdsfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdsfam Table des sous-familles d'articles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcSfam-cle as character  no-undo.
    define input parameter table-handle phttIfdsfam.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdsfam for ifdsfam.

    vhttBuffer = phttIfdsfam:default-buffer-handle.
    for first ifdsfam no-lock
        where ifdsfam.soc-cd = piSoc-cd
          and ifdsfam.sfam-cle = pcSfam-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdsfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdsfam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdsfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdsfam Table des sous-familles d'articles
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter table-handle phttIfdsfam.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdsfam for ifdsfam.

    vhttBuffer = phttIfdsfam:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifdsfam no-lock
        where ifdsfam.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdsfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdsfam no-lock
        where ifdsfam.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdsfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdsfam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdsfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSfam-cle    as handle  no-undo.
    define buffer ifdsfam for ifdsfam.

    create query vhttquery.
    vhttBuffer = ghttIfdsfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdsfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSfam-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdsfam exclusive-lock
                where rowid(ifdsfam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdsfam:handle, 'soc-cd/sfam-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhSfam-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdsfam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdsfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdsfam for ifdsfam.

    create query vhttquery.
    vhttBuffer = ghttIfdsfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdsfam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdsfam.
            if not outils:copyValidField(buffer ifdsfam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdsfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSfam-cle    as handle  no-undo.
    define buffer ifdsfam for ifdsfam.

    create query vhttquery.
    vhttBuffer = ghttIfdsfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdsfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSfam-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdsfam exclusive-lock
                where rowid(Ifdsfam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdsfam:handle, 'soc-cd/sfam-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhSfam-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdsfam no-error.
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

