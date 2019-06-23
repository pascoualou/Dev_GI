/*------------------------------------------------------------------------
File        : apfet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table apfet
Author(s)   : generation automatique le 08/08/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttapfet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phTpapp as handle, output phNofon as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/tpapp/nofon/noapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'nofon' then phNofon = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApfet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApfet.
    run updateApfet.
    run createApfet.
end procedure.

procedure setApfet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApfet.
    ghttApfet = phttApfet.
    run crudApfet.
    delete object phttApfet.
end procedure.

procedure readApfet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apfet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNofon as int64      no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttApfet.
    define variable vhttBuffer as handle no-undo.
    define buffer apfet for apfet.

    vhttBuffer = phttApfet:default-buffer-handle.
    for first apfet no-lock
        where apfet.noimm = piNoimm
          and apfet.tpapp = pcTpapp
          and apfet.nofon = piNofon
          and apfet.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apfet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApfet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApfet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apfet 
    Notes  : service externe. Critère piNofon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNofon as int64      no-undo.
    define input parameter table-handle phttApfet.
    define variable vhttBuffer as handle  no-undo.
    define buffer apfet for apfet.

    vhttBuffer = phttApfet:default-buffer-handle.
    if piNofon = ?
    then for each apfet no-lock
        where apfet.noimm = piNoimm
          and apfet.tpapp = pcTpapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apfet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apfet no-lock
        where apfet.noimm = piNoimm
          and apfet.tpapp = pcTpapp
          and apfet.nofon = piNofon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apfet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApfet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApfet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhNoimm as handle  no-undo.
    define variable vhTpapp as handle  no-undo.
    define variable vhNofon as handle  no-undo.
    define variable vhNoapp as handle  no-undo.
    define buffer apfet for apfet.

    create query vhttquery.
    vhttBuffer = ghttApfet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApfet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhTpapp, output vhNofon, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apfet exclusive-lock
                where rowid(apfet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apfet:handle, 'noimm/tpapp/nofon/noapp: ', substitute('&1/&2/&3/&4', vhNoimm:buffer-value(), vhTpapp:buffer-value(), vhNofon:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apfet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApfet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apfet for apfet.

    create query vhttquery.
    vhttBuffer = ghttApfet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApfet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apfet.
            if not outils:copyValidField(buffer apfet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApfet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm as handle  no-undo.
    define variable vhTpapp as handle  no-undo.
    define variable vhNofon as handle  no-undo.
    define variable vhNoapp as handle  no-undo.
    define buffer apfet for apfet.

    create query vhttquery.
    vhttBuffer = ghttApfet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApfet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhTpapp, output vhNofon, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apfet exclusive-lock
                where rowid(Apfet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apfet:handle, 'noimm/tpapp/nofon/noapp: ', substitute('&1/&2/&3/&4', vhNoimm:buffer-value(), vhTpapp:buffer-value(), vhNofon:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apfet no-error.
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

