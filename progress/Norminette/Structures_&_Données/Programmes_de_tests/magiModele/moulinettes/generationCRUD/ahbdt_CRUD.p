/*------------------------------------------------------------------------
File        : ahbdt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ahbdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ahbdt.i}
{application/include/error.i}
define variable ghttahbdt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phNoapp as handle, output phNocpt as handle, output phNoscp as handle, output phCdeta as handle, output phNoecr as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/noapp/nocpt/noscp/cdeta/noecr/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'nocpt' then phNocpt = phBuffer:buffer-field(vi).
            when 'noscp' then phNoscp = phBuffer:buffer-field(vi).
            when 'cdeta' then phCdeta = phBuffer:buffer-field(vi).
            when 'noecr' then phNoecr = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAhbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAhbdt.
    run updateAhbdt.
    run createAhbdt.
end procedure.

procedure setAhbdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAhbdt.
    ghttAhbdt = phttAhbdt.
    run crudAhbdt.
    delete object phttAhbdt.
end procedure.

procedure readAhbdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ahbdt Appels Hors-Budget : Détail
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNocpt as integer    no-undo.
    define input parameter piNoscp as integer    no-undo.
    define input parameter piCdeta as integer    no-undo.
    define input parameter piNoecr as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttAhbdt.
    define variable vhttBuffer as handle no-undo.
    define buffer ahbdt for ahbdt.

    vhttBuffer = phttAhbdt:default-buffer-handle.
    for first ahbdt no-lock
        where ahbdt.noimm = piNoimm
          and ahbdt.noapp = piNoapp
          and ahbdt.nocpt = piNocpt
          and ahbdt.noscp = piNoscp
          and ahbdt.cdeta = piCdeta
          and ahbdt.noecr = piNoecr
          and ahbdt.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhbdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAhbdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ahbdt Appels Hors-Budget : Détail
    Notes  : service externe. Critère piNoecr = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNocpt as integer    no-undo.
    define input parameter piNoscp as integer    no-undo.
    define input parameter piCdeta as integer    no-undo.
    define input parameter piNoecr as integer    no-undo.
    define input parameter table-handle phttAhbdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ahbdt for ahbdt.

    vhttBuffer = phttAhbdt:default-buffer-handle.
    if piNoecr = ?
    then for each ahbdt no-lock
        where ahbdt.noimm = piNoimm
          and ahbdt.noapp = piNoapp
          and ahbdt.nocpt = piNocpt
          and ahbdt.noscp = piNoscp
          and ahbdt.cdeta = piCdeta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ahbdt no-lock
        where ahbdt.noimm = piNoimm
          and ahbdt.noapp = piNoapp
          and ahbdt.nocpt = piNocpt
          and ahbdt.noscp = piNoscp
          and ahbdt.cdeta = piCdeta
          and ahbdt.noecr = piNoecr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhbdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAhbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNocpt    as handle  no-undo.
    define variable vhNoscp    as handle  no-undo.
    define variable vhCdeta    as handle  no-undo.
    define variable vhNoecr    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer ahbdt for ahbdt.

    create query vhttquery.
    vhttBuffer = ghttAhbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAhbdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNoapp, output vhNocpt, output vhNoscp, output vhCdeta, output vhNoecr, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahbdt exclusive-lock
                where rowid(ahbdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahbdt:handle, 'noimm/noapp/nocpt/noscp/cdeta/noecr/nolig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhNoimm:buffer-value(), vhNoapp:buffer-value(), vhNocpt:buffer-value(), vhNoscp:buffer-value(), vhCdeta:buffer-value(), vhNoecr:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ahbdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAhbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ahbdt for ahbdt.

    create query vhttquery.
    vhttBuffer = ghttAhbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAhbdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ahbdt.
            if not outils:copyValidField(buffer ahbdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAhbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNocpt    as handle  no-undo.
    define variable vhNoscp    as handle  no-undo.
    define variable vhCdeta    as handle  no-undo.
    define variable vhNoecr    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer ahbdt for ahbdt.

    create query vhttquery.
    vhttBuffer = ghttAhbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAhbdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNoapp, output vhNocpt, output vhNoscp, output vhCdeta, output vhNoecr, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahbdt exclusive-lock
                where rowid(Ahbdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahbdt:handle, 'noimm/noapp/nocpt/noscp/cdeta/noecr/nolig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhNoimm:buffer-value(), vhNoapp:buffer-value(), vhNocpt:buffer-value(), vhNoscp:buffer-value(), vhCdeta:buffer-value(), vhNoecr:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ahbdt no-error.
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

