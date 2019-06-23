/*------------------------------------------------------------------------
File        : cregana3_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cregana3
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cregana3.i}
{application/include/error.i}
define variable ghttcregana3 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phGrp-cd as handle, output phReg-cd as handle, output phAna3-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/grp-cd/reg-cd/ana3-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'grp-cd' then phGrp-cd = phBuffer:buffer-field(vi).
            when 'reg-cd' then phReg-cd = phBuffer:buffer-field(vi).
            when 'ana3-cd' then phAna3-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCregana3 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCregana3.
    run updateCregana3.
    run createCregana3.
end procedure.

procedure setCregana3:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCregana3.
    ghttCregana3 = phttCregana3.
    run crudCregana3.
    delete object phttCregana3.
end procedure.

procedure readCregana3:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cregana3 Regroupement analytique 3
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcGrp-cd  as character  no-undo.
    define input parameter pcReg-cd  as character  no-undo.
    define input parameter pcAna3-cd as character  no-undo.
    define input parameter table-handle phttCregana3.
    define variable vhttBuffer as handle no-undo.
    define buffer cregana3 for cregana3.

    vhttBuffer = phttCregana3:default-buffer-handle.
    for first cregana3 no-lock
        where cregana3.soc-cd = piSoc-cd
          and cregana3.etab-cd = piEtab-cd
          and cregana3.grp-cd = pcGrp-cd
          and cregana3.reg-cd = pcReg-cd
          and cregana3.ana3-cd = pcAna3-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cregana3:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCregana3 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCregana3:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cregana3 Regroupement analytique 3
    Notes  : service externe. Critère pcReg-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcGrp-cd  as character  no-undo.
    define input parameter pcReg-cd  as character  no-undo.
    define input parameter table-handle phttCregana3.
    define variable vhttBuffer as handle  no-undo.
    define buffer cregana3 for cregana3.

    vhttBuffer = phttCregana3:default-buffer-handle.
    if pcReg-cd = ?
    then for each cregana3 no-lock
        where cregana3.soc-cd = piSoc-cd
          and cregana3.etab-cd = piEtab-cd
          and cregana3.grp-cd = pcGrp-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cregana3:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cregana3 no-lock
        where cregana3.soc-cd = piSoc-cd
          and cregana3.etab-cd = piEtab-cd
          and cregana3.grp-cd = pcGrp-cd
          and cregana3.reg-cd = pcReg-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cregana3:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCregana3 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCregana3 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhGrp-cd    as handle  no-undo.
    define variable vhReg-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define buffer cregana3 for cregana3.

    create query vhttquery.
    vhttBuffer = ghttCregana3:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCregana3:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhGrp-cd, output vhReg-cd, output vhAna3-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cregana3 exclusive-lock
                where rowid(cregana3) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cregana3:handle, 'soc-cd/etab-cd/grp-cd/reg-cd/ana3-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhGrp-cd:buffer-value(), vhReg-cd:buffer-value(), vhAna3-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cregana3:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCregana3 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cregana3 for cregana3.

    create query vhttquery.
    vhttBuffer = ghttCregana3:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCregana3:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cregana3.
            if not outils:copyValidField(buffer cregana3:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCregana3 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhGrp-cd    as handle  no-undo.
    define variable vhReg-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define buffer cregana3 for cregana3.

    create query vhttquery.
    vhttBuffer = ghttCregana3:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCregana3:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhGrp-cd, output vhReg-cd, output vhAna3-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cregana3 exclusive-lock
                where rowid(Cregana3) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cregana3:handle, 'soc-cd/etab-cd/grp-cd/reg-cd/ana3-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhGrp-cd:buffer-value(), vhReg-cd:buffer-value(), vhAna3-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cregana3 no-error.
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

