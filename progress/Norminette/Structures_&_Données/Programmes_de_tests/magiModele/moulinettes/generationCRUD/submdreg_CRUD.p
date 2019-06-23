/*------------------------------------------------------------------------
File        : submdreg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table submdreg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/submdreg.i}
{application/include/error.i}
define variable ghttsubmdreg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phTptrt as handle, output phTpapp as handle, output phNobud as handle, output phNoapp as handle, output phNocop as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/tptrt/tpapp/nobud/noapp/nocop, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'tptrt' then phTptrt = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'nocop' then phNocop = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSubmdreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSubmdreg.
    run updateSubmdreg.
    run createSubmdreg.
end procedure.

procedure setSubmdreg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSubmdreg.
    ghttSubmdreg = phttSubmdreg.
    run crudSubmdreg.
    delete object phttSubmdreg.
end procedure.

procedure readSubmdreg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table submdreg 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pdeNomdt as decimal    no-undo.
    define input parameter pcTptrt as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNobud as int64      no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter table-handle phttSubmdreg.
    define variable vhttBuffer as handle no-undo.
    define buffer submdreg for submdreg.

    vhttBuffer = phttSubmdreg:default-buffer-handle.
    for first submdreg no-lock
        where submdreg.nomdt = pdeNomdt
          and submdreg.tptrt = pcTptrt
          and submdreg.tpapp = pcTpapp
          and submdreg.nobud = piNobud
          and submdreg.noapp = piNoapp
          and submdreg.nocop = piNocop:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer submdreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSubmdreg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSubmdreg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table submdreg 
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pdeNomdt as decimal    no-undo.
    define input parameter pcTptrt as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNobud as int64      no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttSubmdreg.
    define variable vhttBuffer as handle  no-undo.
    define buffer submdreg for submdreg.

    vhttBuffer = phttSubmdreg:default-buffer-handle.
    if piNoapp = ?
    then for each submdreg no-lock
        where submdreg.nomdt = pdeNomdt
          and submdreg.tptrt = pcTptrt
          and submdreg.tpapp = pcTpapp
          and submdreg.nobud = piNobud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer submdreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each submdreg no-lock
        where submdreg.nomdt = pdeNomdt
          and submdreg.tptrt = pcTptrt
          and submdreg.tpapp = pcTpapp
          and submdreg.nobud = piNobud
          and submdreg.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer submdreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSubmdreg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSubmdreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer submdreg for submdreg.

    create query vhttquery.
    vhttBuffer = ghttSubmdreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSubmdreg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhTptrt, output vhTpapp, output vhNobud, output vhNoapp, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first submdreg exclusive-lock
                where rowid(submdreg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer submdreg:handle, 'nomdt/tptrt/tpapp/nobud/noapp/nocop: ', substitute('&1/&2/&3/&4/&5/&6', vhNomdt:buffer-value(), vhTptrt:buffer-value(), vhTpapp:buffer-value(), vhNobud:buffer-value(), vhNoapp:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer submdreg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSubmdreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer submdreg for submdreg.

    create query vhttquery.
    vhttBuffer = ghttSubmdreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSubmdreg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create submdreg.
            if not outils:copyValidField(buffer submdreg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSubmdreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer submdreg for submdreg.

    create query vhttquery.
    vhttBuffer = ghttSubmdreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSubmdreg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhTptrt, output vhTpapp, output vhNobud, output vhNoapp, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first submdreg exclusive-lock
                where rowid(Submdreg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer submdreg:handle, 'nomdt/tptrt/tpapp/nobud/noapp/nocop: ', substitute('&1/&2/&3/&4/&5/&6', vhNomdt:buffer-value(), vhTptrt:buffer-value(), vhTpapp:buffer-value(), vhNobud:buffer-value(), vhNoapp:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete submdreg no-error.
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

