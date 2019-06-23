/*------------------------------------------------------------------------
File        : iscrl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iscrl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iscrl.i}
{application/include/error.i}
define variable ghttiscrl as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRefcli as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/refcli, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'refcli' then phRefcli = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIscrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIscrl.
    run updateIscrl.
    run createIscrl.
end procedure.

procedure setIscrl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIscrl.
    ghttIscrl = phttIscrl.
    run crudIscrl.
    delete object phttIscrl.
end procedure.

procedure readIscrl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iscrl fichier reponse.txt (gft)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcRefcli  as character  no-undo.
    define input parameter table-handle phttIscrl.
    define variable vhttBuffer as handle no-undo.
    define buffer iscrl for iscrl.

    vhttBuffer = phttIscrl:default-buffer-handle.
    for first iscrl no-lock
        where iscrl.soc-cd = piSoc-cd
          and iscrl.etab-cd = piEtab-cd
          and iscrl.refcli = pcRefcli:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscrl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscrl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIscrl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iscrl fichier reponse.txt (gft)
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttIscrl.
    define variable vhttBuffer as handle  no-undo.
    define buffer iscrl for iscrl.

    vhttBuffer = phttIscrl:default-buffer-handle.
    if piEtab-cd = ?
    then for each iscrl no-lock
        where iscrl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscrl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iscrl no-lock
        where iscrl.soc-cd = piSoc-cd
          and iscrl.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscrl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscrl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIscrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRefcli    as handle  no-undo.
    define buffer iscrl for iscrl.

    create query vhttquery.
    vhttBuffer = ghttIscrl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIscrl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRefcli).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscrl exclusive-lock
                where rowid(iscrl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscrl:handle, 'soc-cd/etab-cd/refcli: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRefcli:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iscrl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIscrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iscrl for iscrl.

    create query vhttquery.
    vhttBuffer = ghttIscrl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIscrl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iscrl.
            if not outils:copyValidField(buffer iscrl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIscrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRefcli    as handle  no-undo.
    define buffer iscrl for iscrl.

    create query vhttquery.
    vhttBuffer = ghttIscrl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIscrl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRefcli).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscrl exclusive-lock
                where rowid(Iscrl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscrl:handle, 'soc-cd/etab-cd/refcli: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRefcli:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iscrl no-error.
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

