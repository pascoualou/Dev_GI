/*------------------------------------------------------------------------
File        : cblocsce_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cblocsce
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cblocsce.i}
{application/include/error.i}
define variable ghttcblocsce as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phScen-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/scen-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCblocsce private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCblocsce.
    run updateCblocsce.
    run createCblocsce.
end procedure.

procedure setCblocsce:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCblocsce.
    ghttCblocsce = phttCblocsce.
    run crudCblocsce.
    delete object phttCblocsce.
end procedure.

procedure readCblocsce:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cblocsce Scenario du bloc note
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcScen-cle as character  no-undo.
    define input parameter table-handle phttCblocsce.
    define variable vhttBuffer as handle no-undo.
    define buffer cblocsce for cblocsce.

    vhttBuffer = phttCblocsce:default-buffer-handle.
    for first cblocsce no-lock
        where cblocsce.soc-cd = piSoc-cd
          and cblocsce.etab-cd = piEtab-cd
          and cblocsce.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblocsce:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCblocsce no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCblocsce:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cblocsce Scenario du bloc note
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter table-handle phttCblocsce.
    define variable vhttBuffer as handle  no-undo.
    define buffer cblocsce for cblocsce.

    vhttBuffer = phttCblocsce:default-buffer-handle.
    if piEtab-cd = ?
    then for each cblocsce no-lock
        where cblocsce.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblocsce:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cblocsce no-lock
        where cblocsce.soc-cd = piSoc-cd
          and cblocsce.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblocsce:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCblocsce no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCblocsce private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define buffer cblocsce for cblocsce.

    create query vhttquery.
    vhttBuffer = ghttCblocsce:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCblocsce:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhScen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cblocsce exclusive-lock
                where rowid(cblocsce) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cblocsce:handle, 'soc-cd/etab-cd/scen-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhScen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cblocsce:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCblocsce private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cblocsce for cblocsce.

    create query vhttquery.
    vhttBuffer = ghttCblocsce:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCblocsce:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cblocsce.
            if not outils:copyValidField(buffer cblocsce:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCblocsce private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define buffer cblocsce for cblocsce.

    create query vhttquery.
    vhttBuffer = ghttCblocsce:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCblocsce:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhScen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cblocsce exclusive-lock
                where rowid(Cblocsce) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cblocsce:handle, 'soc-cd/etab-cd/scen-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhScen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cblocsce no-error.
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

