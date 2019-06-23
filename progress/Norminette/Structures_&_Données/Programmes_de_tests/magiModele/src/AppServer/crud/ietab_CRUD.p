/*------------------------------------------------------------------------
File        : ietab_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ietab
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/07/04 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttietab as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'  then phSoc-cd  = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIetab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIetab.
    run updateIetab.
    run createIetab.
end procedure.

procedure setIetab:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIetab.
    ghttIetab = phttIetab.
    run crudIetab.
    delete object phttIetab.
end procedure.

procedure readIetab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ietab Informations relatives a un etablissement pour une societe.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer  no-undo.
    define input parameter piEtab-cd as integer  no-undo.
    define input parameter table-handle phttIetab.

    define variable vhttBuffer as handle no-undo.
    define buffer ietab for ietab.

    vhttBuffer = phttIetab:default-buffer-handle.
    for first ietab no-lock
        where ietab.soc-cd = piSoc-cd
          and ietab.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ietab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIetab no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIetab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ietab Informations relatives a un etablissement pour une societe.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer  no-undo.
    define input parameter table-handle phttIetab.

    define variable vhttBuffer as handle  no-undo.
    define buffer ietab for ietab.

    vhttBuffer = phttIetab:default-buffer-handle.
    if piSoc-cd = ?
    then for each ietab no-lock
        where ietab.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ietab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ietab no-lock
        where ietab.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ietab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIetab no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIetab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhEtab-cd  as handle  no-undo.
    define buffer ietab for ietab.

    create query vhttquery.
    vhttBuffer = ghttIetab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIetab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ietab exclusive-lock
                where rowid(ietab) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ietab:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ietab:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIetab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer ietab for ietab.

    create query vhttquery.
    vhttBuffer = ghttIetab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIetab:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ietab.
            if not outils:copyValidField(buffer ietab:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIetab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhEtab-cd  as handle  no-undo.
    define buffer ietab for ietab.

    create query vhttquery.
    vhttBuffer = ghttIetab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIetab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ietab exclusive-lock
                where rowid(Ietab) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ietab:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ietab no-error.
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

procedure deleteIetabSurEtabCd:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSociete   as integer no-undo.
    define input parameter piCodeEtabl as integer no-undo.

    define buffer ietab for ietab.

blocTrans:
    for first ietab exclusive-lock 
        where ietab.soc-cd  = piSociete
          and ietab.etab-cd = piCodeEtabl:
        delete ietab no-error.
        if error-status:error then do:
            mError:createError({&error}, error-status:get-message(1)).
            undo blocTrans, leave blocTrans.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.
