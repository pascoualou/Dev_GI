/*------------------------------------------------------------------------
File        : solps_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table solps
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/solps.i}
{application/include/error.i}
define variable ghttsolps as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpctt as handle, output phNomdt as handle, output phNoexo as handle, output phNoloc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpctt/nomdt/noexo/noloc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpctt' then phTpctt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSolps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSolps.
    run updateSolps.
    run createSolps.
end procedure.

procedure setSolps:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSolps.
    ghttSolps = phttSolps.
    run crudSolps.
    delete object phttSolps.
end procedure.

procedure readSolps:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table solps Stockage des soldes prestations quittancés suite à D11
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter table-handle phttSolps.
    define variable vhttBuffer as handle no-undo.
    define buffer solps for solps.

    vhttBuffer = phttSolps:default-buffer-handle.
    for first solps no-lock
        where solps.tpctt = pcTpctt
          and solps.nomdt = piNomdt
          and solps.noexo = piNoexo
          and solps.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer solps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSolps no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSolps:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table solps Stockage des soldes prestations quittancés suite à D11
    Notes  : service externe. Critère piNoexo = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter table-handle phttSolps.
    define variable vhttBuffer as handle  no-undo.
    define buffer solps for solps.

    vhttBuffer = phttSolps:default-buffer-handle.
    if piNoexo = ?
    then for each solps no-lock
        where solps.tpctt = pcTpctt
          and solps.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer solps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each solps no-lock
        where solps.tpctt = pcTpctt
          and solps.nomdt = piNomdt
          and solps.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer solps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSolps no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSolps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer solps for solps.

    create query vhttquery.
    vhttBuffer = ghttSolps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSolps:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNomdt, output vhNoexo, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first solps exclusive-lock
                where rowid(solps) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer solps:handle, 'tpctt/nomdt/noexo/noloc: ', substitute('&1/&2/&3/&4', vhTpctt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer solps:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSolps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer solps for solps.

    create query vhttquery.
    vhttBuffer = ghttSolps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSolps:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create solps.
            if not outils:copyValidField(buffer solps:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSolps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer solps for solps.

    create query vhttquery.
    vhttBuffer = ghttSolps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSolps:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNomdt, output vhNoexo, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first solps exclusive-lock
                where rowid(Solps) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer solps:handle, 'tpctt/nomdt/noexo/noloc: ', substitute('&1/&2/&3/&4', vhTpctt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete solps no-error.
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

