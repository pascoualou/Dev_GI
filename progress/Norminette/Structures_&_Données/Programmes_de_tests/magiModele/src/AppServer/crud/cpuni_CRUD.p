/*------------------------------------------------------------------------
File        : cpuni_crud.p
Purpose     :
Author(s)   : Kantena  -  2017/03/14
Notes       :
derniere revue: 2018/09/07 - 
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/cpuni.i}

define variable ghttcpuni as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNoapp as handle, output phNocmp as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/noapp/nocmp/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'nocmp' then phNocmp = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpuni private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpuni.
    run updateCpuni.
    run createCpuni.
end procedure.

procedure setCpuni:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpuni.
    ghttCpuni = phttCpuni.
    run crudCpuni.
    delete object phttCpuni.
end procedure.

procedure readCpuni:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpuni 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNocmp as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttCpuni.
    define variable vhttBuffer as handle no-undo.
    define buffer cpuni for cpuni.

    vhttBuffer = phttCpuni:default-buffer-handle.
    for first cpuni no-lock
        where cpuni.nomdt = piNomdt
          and cpuni.noapp = piNoapp
          and cpuni.nocmp = piNocmp
          and cpuni.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpuni:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpuni no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpuni:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpuni 
    Notes  : service externe. Critère piNocmp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNocmp as integer    no-undo.
    define input parameter table-handle phttCpuni.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpuni for cpuni.

    vhttBuffer = phttCpuni:default-buffer-handle.
    if piNocmp = ?
    then for each cpuni no-lock
        where cpuni.nomdt = piNomdt
          and cpuni.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpuni:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpuni no-lock
        where cpuni.nomdt = piNomdt
          and cpuni.noapp = piNoapp
          and cpuni.nocmp = piNocmp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpuni:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpuni no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpuni private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNocmp    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer cpuni for cpuni.

    create query vhttquery.
    vhttBuffer = ghttCpuni:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpuni:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoapp, output vhNocmp, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpuni exclusive-lock
                where rowid(cpuni) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpuni:handle, 'nomdt/noapp/nocmp/noord: ', substitute('&1/&2/&3/&4', vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhNocmp:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpuni:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpuni private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNocmp    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable viNoord    as integer no-undo.
    define buffer cpuni for cpuni.

    create query vhttquery.
    vhttBuffer = ghttCpuni:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpuni:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoapp, output vhNocmp, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            viNoord = vhNoord:buffer-value().
            if viNoord = ? then do:
                run getOrdreSuivant(vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhNocmp:buffer-value(), output viNoord).
                vhNoord:buffer-value() = viNoord.
            end.
            create cpuni.
            if not outils:copyValidField(buffer cpuni:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpuni private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNocmp    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer cpuni for cpuni.

    create query vhttquery.
    vhttBuffer = ghttCpuni:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpuni:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoapp, output vhNocmp, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpuni exclusive-lock
                where rowid(Cpuni) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpuni:handle, 'nomdt/noapp/nocmp/noord: ', substitute('&1/&2/&3/&4', vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhNocmp:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpuni no-error.
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

procedure getOrdreSuivant private:
  /*---------------------------------------------------------------------------------------
    Purpose: recuperation de numero ordre de lot suivant
    Notes  :
   ----------------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat       as integer no-undo.
    define input  parameter piNumeroAppartement  as integer no-undo.
    define input  parameter piNumeroComposition  as integer no-undo.
    define output parameter piNumeroOrdreSuivant as integer no-undo initial 1.

    define buffer cpuni for cpuni.

    for last cpuni fields(noord) no-lock
        where cpuni.nomdt = piNumeroMandat
          and cpuni.noapp = piNumeroAppartement
          and cpuni.nocmp = piNumeroComposition:
        piNumeroOrdreSuivant = cpuni.noord + 1.
    end.
    return.

end procedure.
