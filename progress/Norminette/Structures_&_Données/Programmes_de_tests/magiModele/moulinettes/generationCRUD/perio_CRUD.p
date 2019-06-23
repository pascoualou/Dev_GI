/*------------------------------------------------------------------------
File        : perio_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table perio
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/perio.i}
{application/include/error.i}
define variable ghttperio as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpctt as handle, output phNomdt as handle, output phNoexo as handle, output phNoper as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpctt/nomdt/noexo/noper, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpctt' then phTpctt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPerio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePerio.
    run updatePerio.
    run createPerio.
end procedure.

procedure setPerio:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPerio.
    ghttPerio = phttPerio.
    run crudPerio.
    delete object phttPerio.
end procedure.

procedure readPerio:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table perio 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter table-handle phttPerio.
    define variable vhttBuffer as handle no-undo.
    define buffer perio for perio.

    vhttBuffer = phttPerio:default-buffer-handle.
    for first perio no-lock
        where perio.tpctt = pcTpctt
          and perio.nomdt = piNomdt
          and perio.noexo = piNoexo
          and perio.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer perio:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPerio no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPerio:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table perio 
    Notes  : service externe. Critère piNoexo = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter table-handle phttPerio.
    define variable vhttBuffer as handle  no-undo.
    define buffer perio for perio.

    vhttBuffer = phttPerio:default-buffer-handle.
    if piNoexo = ?
    then for each perio no-lock
        where perio.tpctt = pcTpctt
          and perio.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer perio:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each perio no-lock
        where perio.tpctt = pcTpctt
          and perio.nomdt = piNomdt
          and perio.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer perio:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPerio no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePerio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer perio for perio.

    create query vhttquery.
    vhttBuffer = ghttPerio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPerio:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNomdt, output vhNoexo, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first perio exclusive-lock
                where rowid(perio) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer perio:handle, 'tpctt/nomdt/noexo/noper: ', substitute('&1/&2/&3/&4', vhTpctt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer perio:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPerio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer perio for perio.

    create query vhttquery.
    vhttBuffer = ghttPerio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPerio:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create perio.
            if not outils:copyValidField(buffer perio:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePerio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer perio for perio.

    create query vhttquery.
    vhttBuffer = ghttPerio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPerio:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNomdt, output vhNoexo, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first perio exclusive-lock
                where rowid(Perio) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer perio:handle, 'tpctt/nomdt/noexo/noper: ', substitute('&1/&2/&3/&4', vhTpctt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete perio no-error.
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

