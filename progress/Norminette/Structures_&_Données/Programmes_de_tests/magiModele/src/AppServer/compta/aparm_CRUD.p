/*------------------------------------------------------------------------
File        : aparm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aparm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aparm.i}
{application/include/error.i}
define variable ghttaparm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCdpar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/soc-cd/etab-cd/cdpar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cdpar' then phCdpar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAparm.
    run updateAparm.
    run createAparm.
end procedure.

procedure setAparm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAparm.
    ghttAparm = phttAparm.
    run crudAparm.
    delete object phttAparm.
end procedure.

procedure readAparm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aparm 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar   as character  no-undo.
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCdpar   as character  no-undo.
    define input parameter table-handle phttAparm.
    define variable vhttBuffer as handle no-undo.
    define buffer aparm for aparm.

    vhttBuffer = phttAparm:default-buffer-handle.
    for first aparm no-lock
        where aparm.tppar = pcTppar
          and aparm.soc-cd = piSoc-cd
          and aparm.etab-cd = piEtab-cd
          and aparm.cdpar = pcCdpar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aparm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAparm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAparm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aparm 
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar   as character  no-undo.
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttAparm.
    define variable vhttBuffer as handle  no-undo.
    define buffer aparm for aparm.

    vhttBuffer = phttAparm:default-buffer-handle.
    if piEtab-cd = ?
    then for each aparm no-lock
        where aparm.tppar = pcTppar
          and aparm.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aparm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aparm no-lock
        where aparm.tppar = pcTppar
          and aparm.soc-cd = piSoc-cd
          and aparm.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aparm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAparm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer aparm for aparm.

    create query vhttquery.
    vhttBuffer = ghttAparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAparm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhSoc-cd, output vhEtab-cd, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aparm exclusive-lock
                where rowid(aparm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aparm:handle, 'tppar/soc-cd/etab-cd/cdpar: ', substitute('&1/&2/&3/&4', vhTppar:buffer-value(), vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aparm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aparm for aparm.

    create query vhttquery.
    vhttBuffer = ghttAparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAparm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aparm.
            if not outils:copyValidField(buffer aparm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer aparm for aparm.

    create query vhttquery.
    vhttBuffer = ghttAparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAparm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhSoc-cd, output vhEtab-cd, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aparm exclusive-lock
                where rowid(Aparm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aparm:handle, 'tppar/soc-cd/etab-cd/cdpar: ', substitute('&1/&2/&3/&4', vhTppar:buffer-value(), vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aparm no-error.
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

