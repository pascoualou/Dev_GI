/*------------------------------------------------------------------------
File        : crbsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crbsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crbsai.i}
{application/include/error.i}
define variable ghttcrbsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCpt-cd as handle, output phDafin as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cpt-cd/dafin, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'dafin' then phDafin = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrbsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrbsai.
    run updateCrbsai.
    run createCrbsai.
end procedure.

procedure setCrbsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrbsai.
    ghttCrbsai = phttCrbsai.
    run crudCrbsai.
    delete object phttCrbsai.
end procedure.

procedure readCrbsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crbsai Fichier entete rapprochements bancaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter pdaDafin   as date       no-undo.
    define input parameter table-handle phttCrbsai.
    define variable vhttBuffer as handle no-undo.
    define buffer crbsai for crbsai.

    vhttBuffer = phttCrbsai:default-buffer-handle.
    for first crbsai no-lock
        where crbsai.soc-cd = piSoc-cd
          and crbsai.etab-cd = piEtab-cd
          and crbsai.cpt-cd = pcCpt-cd
          and crbsai.dafin = pdaDafin:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrbsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrbsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crbsai Fichier entete rapprochements bancaires
    Notes  : service externe. Critère pcCpt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter table-handle phttCrbsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer crbsai for crbsai.

    vhttBuffer = phttCrbsai:default-buffer-handle.
    if pcCpt-cd = ?
    then for each crbsai no-lock
        where crbsai.soc-cd = piSoc-cd
          and crbsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crbsai no-lock
        where crbsai.soc-cd = piSoc-cd
          and crbsai.etab-cd = piEtab-cd
          and crbsai.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrbsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrbsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhDafin    as handle  no-undo.
    define buffer crbsai for crbsai.

    create query vhttquery.
    vhttBuffer = ghttCrbsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrbsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-cd, output vhDafin).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crbsai exclusive-lock
                where rowid(crbsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crbsai:handle, 'soc-cd/etab-cd/cpt-cd/dafin: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-cd:buffer-value(), vhDafin:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crbsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrbsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crbsai for crbsai.

    create query vhttquery.
    vhttBuffer = ghttCrbsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrbsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crbsai.
            if not outils:copyValidField(buffer crbsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrbsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhDafin    as handle  no-undo.
    define buffer crbsai for crbsai.

    create query vhttquery.
    vhttBuffer = ghttCrbsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrbsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-cd, output vhDafin).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crbsai exclusive-lock
                where rowid(Crbsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crbsai:handle, 'soc-cd/etab-cd/cpt-cd/dafin: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-cd:buffer-value(), vhDafin:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crbsai no-error.
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

