/*------------------------------------------------------------------------
File        : bureau_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table bureau
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/bureau.i}
{application/include/error.i}
define variable ghttbureau as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBur-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/bur-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'bur-cd' then phBur-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBureau private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBureau.
    run updateBureau.
    run createBureau.
end procedure.

procedure setBureau:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBureau.
    ghttBureau = phttBureau.
    run crudBureau.
    delete object phttBureau.
end procedure.

procedure readBureau:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table bureau Table des bureaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piBur-cd  as integer    no-undo.
    define input parameter table-handle phttBureau.
    define variable vhttBuffer as handle no-undo.
    define buffer bureau for bureau.

    vhttBuffer = phttBureau:default-buffer-handle.
    for first bureau no-lock
        where bureau.soc-cd = piSoc-cd
          and bureau.etab-cd = piEtab-cd
          and bureau.bur-cd = piBur-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bureau:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBureau no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBureau:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table bureau Table des bureaux
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttBureau.
    define variable vhttBuffer as handle  no-undo.
    define buffer bureau for bureau.

    vhttBuffer = phttBureau:default-buffer-handle.
    if piEtab-cd = ?
    then for each bureau no-lock
        where bureau.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bureau:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each bureau no-lock
        where bureau.soc-cd = piSoc-cd
          and bureau.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bureau:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBureau no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBureau private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBur-cd    as handle  no-undo.
    define buffer bureau for bureau.

    create query vhttquery.
    vhttBuffer = ghttBureau:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBureau:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBur-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first bureau exclusive-lock
                where rowid(bureau) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer bureau:handle, 'soc-cd/etab-cd/bur-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBur-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer bureau:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBureau private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer bureau for bureau.

    create query vhttquery.
    vhttBuffer = ghttBureau:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBureau:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create bureau.
            if not outils:copyValidField(buffer bureau:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBureau private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBur-cd    as handle  no-undo.
    define buffer bureau for bureau.

    create query vhttquery.
    vhttBuffer = ghttBureau:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBureau:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBur-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first bureau exclusive-lock
                where rowid(Bureau) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer bureau:handle, 'soc-cd/etab-cd/bur-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBur-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete bureau no-error.
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

