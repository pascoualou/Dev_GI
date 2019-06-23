/*------------------------------------------------------------------------
File        : iclietab_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iclietab
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iclietab.i}
{application/include/error.i}
define variable ghtticlietab as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCli-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cli-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIclietab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIclietab.
    run updateIclietab.
    run createIclietab.
end procedure.

procedure setIclietab:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIclietab.
    ghttIclietab = phttIclietab.
    run crudIclietab.
    delete object phttIclietab.
end procedure.

procedure readIclietab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iclietab 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCli-cle as character  no-undo.
    define input parameter table-handle phttIclietab.
    define variable vhttBuffer as handle no-undo.
    define buffer iclietab for iclietab.

    vhttBuffer = phttIclietab:default-buffer-handle.
    for first iclietab no-lock
        where iclietab.soc-cd = piSoc-cd
          and iclietab.etab-cd = piEtab-cd
          and iclietab.cli-cle = pcCli-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iclietab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIclietab no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIclietab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iclietab 
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttIclietab.
    define variable vhttBuffer as handle  no-undo.
    define buffer iclietab for iclietab.

    vhttBuffer = phttIclietab:default-buffer-handle.
    if piEtab-cd = ?
    then for each iclietab no-lock
        where iclietab.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iclietab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iclietab no-lock
        where iclietab.soc-cd = piSoc-cd
          and iclietab.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iclietab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIclietab no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIclietab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define buffer iclietab for iclietab.

    create query vhttquery.
    vhttBuffer = ghttIclietab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIclietab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCli-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iclietab exclusive-lock
                where rowid(iclietab) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iclietab:handle, 'soc-cd/etab-cd/cli-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCli-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iclietab:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIclietab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iclietab for iclietab.

    create query vhttquery.
    vhttBuffer = ghttIclietab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIclietab:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iclietab.
            if not outils:copyValidField(buffer iclietab:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIclietab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define buffer iclietab for iclietab.

    create query vhttquery.
    vhttBuffer = ghttIclietab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIclietab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCli-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iclietab exclusive-lock
                where rowid(Iclietab) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iclietab:handle, 'soc-cd/etab-cd/cli-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCli-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iclietab no-error.
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

