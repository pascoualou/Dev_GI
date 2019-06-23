/*------------------------------------------------------------------------
File        : iscensai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iscensai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iscensai.i}
{application/include/error.i}
define variable ghttiscensai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phType-cle as handle, output phScen-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/type-cle/scen-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'type-cle' then phType-cle = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIscensai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIscensai.
    run updateIscensai.
    run createIscensai.
end procedure.

procedure setIscensai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIscensai.
    ghttIscensai = phttIscensai.
    run crudIscensai.
    delete object phttIscensai.
end procedure.

procedure readIscensai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iscensai Entete saisie de scenarii de journal
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcJou-cd   as character  no-undo.
    define input parameter pcType-cle as character  no-undo.
    define input parameter pcScen-cle as character  no-undo.
    define input parameter table-handle phttIscensai.
    define variable vhttBuffer as handle no-undo.
    define buffer iscensai for iscensai.

    vhttBuffer = phttIscensai:default-buffer-handle.
    for first iscensai no-lock
        where iscensai.soc-cd = piSoc-cd
          and iscensai.etab-cd = piEtab-cd
          and iscensai.jou-cd = pcJou-cd
          and iscensai.type-cle = pcType-cle
          and iscensai.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscensai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscensai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIscensai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iscensai Entete saisie de scenarii de journal
    Notes  : service externe. Critère pcType-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcJou-cd   as character  no-undo.
    define input parameter pcType-cle as character  no-undo.
    define input parameter table-handle phttIscensai.
    define variable vhttBuffer as handle  no-undo.
    define buffer iscensai for iscensai.

    vhttBuffer = phttIscensai:default-buffer-handle.
    if pcType-cle = ?
    then for each iscensai no-lock
        where iscensai.soc-cd = piSoc-cd
          and iscensai.etab-cd = piEtab-cd
          and iscensai.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscensai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iscensai no-lock
        where iscensai.soc-cd = piSoc-cd
          and iscensai.etab-cd = piEtab-cd
          and iscensai.jou-cd = pcJou-cd
          and iscensai.type-cle = pcType-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscensai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscensai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIscensai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define buffer iscensai for iscensai.

    create query vhttquery.
    vhttBuffer = ghttIscensai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIscensai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhType-cle, output vhScen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscensai exclusive-lock
                where rowid(iscensai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscensai:handle, 'soc-cd/etab-cd/jou-cd/type-cle/scen-cle: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhType-cle:buffer-value(), vhScen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iscensai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIscensai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iscensai for iscensai.

    create query vhttquery.
    vhttBuffer = ghttIscensai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIscensai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iscensai.
            if not outils:copyValidField(buffer iscensai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIscensai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define buffer iscensai for iscensai.

    create query vhttquery.
    vhttBuffer = ghttIscensai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIscensai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhType-cle, output vhScen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscensai exclusive-lock
                where rowid(Iscensai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscensai:handle, 'soc-cd/etab-cd/jou-cd/type-cle/scen-cle: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhType-cle:buffer-value(), vhScen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iscensai no-error.
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

