/*------------------------------------------------------------------------
File        : cbloclib_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbloclib
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbloclib.i}
{application/include/error.i}
define variable ghttcbloclib as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phLib-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/lib-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'lib-cd' then phLib-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbloclib private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbloclib.
    run updateCbloclib.
    run createCbloclib.
end procedure.

procedure setCbloclib:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbloclib.
    ghttCbloclib = phttCbloclib.
    run crudCbloclib.
    delete object phttCbloclib.
end procedure.

procedure readCbloclib:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbloclib Parametrage de libelle du bloc note
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcLib-cd  as character  no-undo.
    define input parameter table-handle phttCbloclib.
    define variable vhttBuffer as handle no-undo.
    define buffer cbloclib for cbloclib.

    vhttBuffer = phttCbloclib:default-buffer-handle.
    for first cbloclib no-lock
        where cbloclib.soc-cd = piSoc-cd
          and cbloclib.etab-cd = piEtab-cd
          and cbloclib.lib-cd = pcLib-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbloclib:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbloclib no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbloclib:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbloclib Parametrage de libelle du bloc note
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCbloclib.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbloclib for cbloclib.

    vhttBuffer = phttCbloclib:default-buffer-handle.
    if piEtab-cd = ?
    then for each cbloclib no-lock
        where cbloclib.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbloclib:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbloclib no-lock
        where cbloclib.soc-cd = piSoc-cd
          and cbloclib.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbloclib:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbloclib no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbloclib private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhLib-cd    as handle  no-undo.
    define buffer cbloclib for cbloclib.

    create query vhttquery.
    vhttBuffer = ghttCbloclib:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbloclib:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLib-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbloclib exclusive-lock
                where rowid(cbloclib) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbloclib:handle, 'soc-cd/etab-cd/lib-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLib-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbloclib:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbloclib private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbloclib for cbloclib.

    create query vhttquery.
    vhttBuffer = ghttCbloclib:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbloclib:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbloclib.
            if not outils:copyValidField(buffer cbloclib:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbloclib private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhLib-cd    as handle  no-undo.
    define buffer cbloclib for cbloclib.

    create query vhttquery.
    vhttBuffer = ghttCbloclib:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbloclib:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLib-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbloclib exclusive-lock
                where rowid(Cbloclib) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbloclib:handle, 'soc-cd/etab-cd/lib-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLib-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbloclib no-error.
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

