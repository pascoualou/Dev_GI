/*------------------------------------------------------------------------
File        : cblocalt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cblocalt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cblocalt.i}
{application/include/error.i}
define variable ghttcblocalt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAlerte-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/alerte-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'alerte-cle' then phAlerte-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCblocalt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCblocalt.
    run updateCblocalt.
    run createCblocalt.
end procedure.

procedure setCblocalt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCblocalt.
    ghttCblocalt = phttCblocalt.
    run crudCblocalt.
    delete object phttCblocalt.
end procedure.

procedure readCblocalt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cblocalt alerte du bloc note
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcAlerte-cle as character  no-undo.
    define input parameter table-handle phttCblocalt.
    define variable vhttBuffer as handle no-undo.
    define buffer cblocalt for cblocalt.

    vhttBuffer = phttCblocalt:default-buffer-handle.
    for first cblocalt no-lock
        where cblocalt.soc-cd = piSoc-cd
          and cblocalt.etab-cd = piEtab-cd
          and cblocalt.alerte-cle = pcAlerte-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblocalt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCblocalt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCblocalt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cblocalt alerte du bloc note
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCblocalt.
    define variable vhttBuffer as handle  no-undo.
    define buffer cblocalt for cblocalt.

    vhttBuffer = phttCblocalt:default-buffer-handle.
    if piEtab-cd = ?
    then for each cblocalt no-lock
        where cblocalt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblocalt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cblocalt no-lock
        where cblocalt.soc-cd = piSoc-cd
          and cblocalt.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblocalt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCblocalt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCblocalt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAlerte-cle    as handle  no-undo.
    define buffer cblocalt for cblocalt.

    create query vhttquery.
    vhttBuffer = ghttCblocalt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCblocalt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAlerte-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cblocalt exclusive-lock
                where rowid(cblocalt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cblocalt:handle, 'soc-cd/etab-cd/alerte-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAlerte-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cblocalt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCblocalt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cblocalt for cblocalt.

    create query vhttquery.
    vhttBuffer = ghttCblocalt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCblocalt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cblocalt.
            if not outils:copyValidField(buffer cblocalt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCblocalt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAlerte-cle    as handle  no-undo.
    define buffer cblocalt for cblocalt.

    create query vhttquery.
    vhttBuffer = ghttCblocalt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCblocalt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAlerte-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cblocalt exclusive-lock
                where rowid(Cblocalt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cblocalt:handle, 'soc-cd/etab-cd/alerte-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAlerte-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cblocalt no-error.
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

