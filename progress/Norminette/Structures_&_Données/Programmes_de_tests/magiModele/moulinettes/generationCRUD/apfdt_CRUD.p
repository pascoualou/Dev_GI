/*------------------------------------------------------------------------
File        : apfdt_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table apfdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/apfdt.i}
{application/include/error.i}
define variable ghttapfdt as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phTpapp as handle, output phNofon as handle, output phNoapp as handle, output phNoecr as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/tpapp/nofon/noapp/noecr/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'nofon' then phNofon = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'noecr' then phNoecr = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApfdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApfdt.
    run updateApfdt.
    run createApfdt.
end procedure.

procedure setApfdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApfdt.
    ghttApfdt = phttApfdt.
    run crudApfdt.
    delete object phttApfdt.
end procedure.

procedure readApfdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apfdt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNofon as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNoecr as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttApfdt.
    define variable vhttBuffer as handle no-undo.
    define buffer apfdt for apfdt.

    vhttBuffer = phttApfdt:default-buffer-handle.
    for first apfdt no-lock
        where apfdt.noimm = piNoimm
          and apfdt.tpapp = pcTpapp
          and apfdt.nofon = piNofon
          and apfdt.noapp = piNoapp
          and apfdt.noecr = piNoecr
          and apfdt.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apfdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApfdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApfdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apfdt 
    Notes  : service externe. Crit�re piNoecr = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNofon as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNoecr as integer    no-undo.
    define input parameter table-handle phttApfdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer apfdt for apfdt.

    vhttBuffer = phttApfdt:default-buffer-handle.
    if piNoecr = ?
    then for each apfdt no-lock
        where apfdt.noimm = piNoimm
          and apfdt.tpapp = pcTpapp
          and apfdt.nofon = piNofon
          and apfdt.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apfdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apfdt no-lock
        where apfdt.noimm = piNoimm
          and apfdt.tpapp = pcTpapp
          and apfdt.nofon = piNofon
          and apfdt.noapp = piNoapp
          and apfdt.noecr = piNoecr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apfdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApfdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApfdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNofon    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNoecr    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer apfdt for apfdt.

    create query vhttquery.
    vhttBuffer = ghttApfdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApfdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhTpapp, output vhNofon, output vhNoapp, output vhNoecr, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apfdt exclusive-lock
                where rowid(apfdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apfdt:handle, 'noimm/tpapp/nofon/noapp/noecr/nolig: ', substitute('&1/&2/&3/&4/&5/&6', vhNoimm:buffer-value(), vhTpapp:buffer-value(), vhNofon:buffer-value(), vhNoapp:buffer-value(), vhNoecr:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apfdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApfdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apfdt for apfdt.

    create query vhttquery.
    vhttBuffer = ghttApfdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApfdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apfdt.
            if not outils:copyValidField(buffer apfdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApfdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNofon    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNoecr    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer apfdt for apfdt.

    create query vhttquery.
    vhttBuffer = ghttApfdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApfdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhTpapp, output vhNofon, output vhNoapp, output vhNoecr, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apfdt exclusive-lock
                where rowid(Apfdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apfdt:handle, 'noimm/tpapp/nofon/noapp/noecr/nolig: ', substitute('&1/&2/&3/&4/&5/&6', vhNoimm:buffer-value(), vhTpapp:buffer-value(), vhNofon:buffer-value(), vhNoapp:buffer-value(), vhNoecr:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apfdt no-error.
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

