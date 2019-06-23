/*------------------------------------------------------------------------
File        : cd12_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cd12
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cd12.i}
{application/include/error.i}
define variable ghttcd12 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCpt-d12 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cpt-d12, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cpt-d12' then phCpt-d12 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCd12 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCd12.
    run updateCd12.
    run createCd12.
end procedure.

procedure setCd12:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCd12.
    ghttCd12 = phttCd12.
    run crudCd12.
    delete object phttCd12.
end procedure.

procedure readCd12:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cd12 table de conversion dps --> gest
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCpt-d12 as character  no-undo.
    define input parameter table-handle phttCd12.
    define variable vhttBuffer as handle no-undo.
    define buffer cd12 for cd12.

    vhttBuffer = phttCd12:default-buffer-handle.
    for first cd12 no-lock
        where cd12.soc-cd = piSoc-cd
          and cd12.etab-cd = piEtab-cd
          and cd12.cpt-d12 = pcCpt-d12:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd12:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd12 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCd12:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cd12 table de conversion dps --> gest
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCd12.
    define variable vhttBuffer as handle  no-undo.
    define buffer cd12 for cd12.

    vhttBuffer = phttCd12:default-buffer-handle.
    if piEtab-cd = ?
    then for each cd12 no-lock
        where cd12.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd12:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cd12 no-lock
        where cd12.soc-cd = piSoc-cd
          and cd12.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd12:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd12 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCd12 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCpt-d12    as handle  no-undo.
    define buffer cd12 for cd12.

    create query vhttquery.
    vhttBuffer = ghttCd12:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCd12:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-d12).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd12 exclusive-lock
                where rowid(cd12) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd12:handle, 'soc-cd/etab-cd/cpt-d12: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-d12:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cd12:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCd12 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cd12 for cd12.

    create query vhttquery.
    vhttBuffer = ghttCd12:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCd12:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cd12.
            if not outils:copyValidField(buffer cd12:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCd12 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCpt-d12    as handle  no-undo.
    define buffer cd12 for cd12.

    create query vhttquery.
    vhttBuffer = ghttCd12:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCd12:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-d12).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd12 exclusive-lock
                where rowid(Cd12) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd12:handle, 'soc-cd/etab-cd/cpt-d12: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-d12:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cd12 no-error.
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

