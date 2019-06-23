/*------------------------------------------------------------------------
File        : honul_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table honul
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/honul.i}
{application/include/error.i}
define variable ghtthonul as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phTphon as handle, output phCdhon as handle, output phDtdeb as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/tphon/cdhon/dtdeb/noapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'tphon' then phTphon = phBuffer:buffer-field(vi).
            when 'cdhon' then phCdhon = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudHonul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteHonul.
    run updateHonul.
    run createHonul.
end procedure.

procedure setHonul:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttHonul.
    ghttHonul = phttHonul.
    run crudHonul.
    delete object phttHonul.
end procedure.

procedure readHonul:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table honul 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTphon as character  no-undo.
    define input parameter piCdhon as integer    no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttHonul.
    define variable vhttBuffer as handle no-undo.
    define buffer honul for honul.

    vhttBuffer = phttHonul:default-buffer-handle.
    for first honul no-lock
        where honul.nomdt = piNomdt
          and honul.tphon = pcTphon
          and honul.cdhon = piCdhon
          and honul.dtdeb = pdaDtdeb
          and honul.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHonul no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getHonul:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table honul 
    Notes  : service externe. Critère pdaDtdeb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTphon as character  no-undo.
    define input parameter piCdhon as integer    no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter table-handle phttHonul.
    define variable vhttBuffer as handle  no-undo.
    define buffer honul for honul.

    vhttBuffer = phttHonul:default-buffer-handle.
    if pdaDtdeb = ?
    then for each honul no-lock
        where honul.nomdt = piNomdt
          and honul.tphon = pcTphon
          and honul.cdhon = piCdhon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each honul no-lock
        where honul.nomdt = piNomdt
          and honul.tphon = pcTphon
          and honul.cdhon = piCdhon
          and honul.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHonul no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateHonul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer honul for honul.

    create query vhttquery.
    vhttBuffer = ghttHonul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttHonul:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhTphon, output vhCdhon, output vhDtdeb, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first honul exclusive-lock
                where rowid(honul) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer honul:handle, 'nomdt/tphon/cdhon/dtdeb/noapp: ', substitute('&1/&2/&3/&4/&5', vhNomdt:buffer-value(), vhTphon:buffer-value(), vhCdhon:buffer-value(), vhDtdeb:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer honul:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createHonul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer honul for honul.

    create query vhttquery.
    vhttBuffer = ghttHonul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttHonul:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create honul.
            if not outils:copyValidField(buffer honul:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteHonul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer honul for honul.

    create query vhttquery.
    vhttBuffer = ghttHonul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttHonul:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhTphon, output vhCdhon, output vhDtdeb, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first honul exclusive-lock
                where rowid(Honul) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer honul:handle, 'nomdt/tphon/cdhon/dtdeb/noapp: ', substitute('&1/&2/&3/&4/&5', vhNomdt:buffer-value(), vhTphon:buffer-value(), vhCdhon:buffer-value(), vhDtdeb:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete honul no-error.
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

