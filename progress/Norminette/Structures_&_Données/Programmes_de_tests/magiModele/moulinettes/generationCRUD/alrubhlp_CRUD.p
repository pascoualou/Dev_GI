/*------------------------------------------------------------------------
File        : alrubhlp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table alrubhlp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/alrubhlp.i}
{application/include/error.i}
define variable ghttalrubhlp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCdlng as handle, output phRub-cd as handle, output phSsrub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cdlng/rub-cd/ssrub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'ssrub-cd' then phSsrub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAlrubhlp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAlrubhlp.
    run updateAlrubhlp.
    run createAlrubhlp.
end procedure.

procedure setAlrubhlp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAlrubhlp.
    ghttAlrubhlp = phttAlrubhlp.
    run crudAlrubhlp.
    delete object phttAlrubhlp.
end procedure.

procedure readAlrubhlp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table alrubhlp Table des liens Rub/Ssrub pour les listes surgissantes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piCdlng    as integer    no-undo.
    define input parameter pcRub-cd   as character  no-undo.
    define input parameter pcSsrub-cd as character  no-undo.
    define input parameter table-handle phttAlrubhlp.
    define variable vhttBuffer as handle no-undo.
    define buffer alrubhlp for alrubhlp.

    vhttBuffer = phttAlrubhlp:default-buffer-handle.
    for first alrubhlp no-lock
        where alrubhlp.soc-cd = piSoc-cd
          and alrubhlp.cdlng = piCdlng
          and alrubhlp.rub-cd = pcRub-cd
          and alrubhlp.ssrub-cd = pcSsrub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer alrubhlp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAlrubhlp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAlrubhlp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table alrubhlp Table des liens Rub/Ssrub pour les listes surgissantes
    Notes  : service externe. Critère pcRub-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piCdlng    as integer    no-undo.
    define input parameter pcRub-cd   as character  no-undo.
    define input parameter table-handle phttAlrubhlp.
    define variable vhttBuffer as handle  no-undo.
    define buffer alrubhlp for alrubhlp.

    vhttBuffer = phttAlrubhlp:default-buffer-handle.
    if pcRub-cd = ?
    then for each alrubhlp no-lock
        where alrubhlp.soc-cd = piSoc-cd
          and alrubhlp.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer alrubhlp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each alrubhlp no-lock
        where alrubhlp.soc-cd = piSoc-cd
          and alrubhlp.cdlng = piCdlng
          and alrubhlp.rub-cd = pcRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer alrubhlp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAlrubhlp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAlrubhlp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSsrub-cd    as handle  no-undo.
    define buffer alrubhlp for alrubhlp.

    create query vhttquery.
    vhttBuffer = ghttAlrubhlp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAlrubhlp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCdlng, output vhRub-cd, output vhSsrub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first alrubhlp exclusive-lock
                where rowid(alrubhlp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer alrubhlp:handle, 'soc-cd/cdlng/rub-cd/ssrub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhCdlng:buffer-value(), vhRub-cd:buffer-value(), vhSsrub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer alrubhlp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAlrubhlp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer alrubhlp for alrubhlp.

    create query vhttquery.
    vhttBuffer = ghttAlrubhlp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAlrubhlp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create alrubhlp.
            if not outils:copyValidField(buffer alrubhlp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAlrubhlp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSsrub-cd    as handle  no-undo.
    define buffer alrubhlp for alrubhlp.

    create query vhttquery.
    vhttBuffer = ghttAlrubhlp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAlrubhlp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCdlng, output vhRub-cd, output vhSsrub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first alrubhlp exclusive-lock
                where rowid(Alrubhlp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer alrubhlp:handle, 'soc-cd/cdlng/rub-cd/ssrub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhCdlng:buffer-value(), vhRub-cd:buffer-value(), vhSsrub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete alrubhlp no-error.
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

