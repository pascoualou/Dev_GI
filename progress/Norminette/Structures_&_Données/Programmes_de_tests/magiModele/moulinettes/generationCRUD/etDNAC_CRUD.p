/*------------------------------------------------------------------------
File        : etDNAC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table etDNAC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/etDNAC.i}
{application/include/error.i}
define variable ghttetDNAC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNorol as handle, output phNoatt as handle, output phNodec as handle, output phNorev as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norol/noatt/nodec/norev, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'noatt' then phNoatt = phBuffer:buffer-field(vi).
            when 'nodec' then phNodec = phBuffer:buffer-field(vi).
            when 'norev' then phNorev = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEtdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEtdnac.
    run updateEtdnac.
    run createEtdnac.
end procedure.

procedure setEtdnac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEtdnac.
    ghttEtdnac = phttEtdnac.
    run crudEtdnac.
    delete object phttEtdnac.
end procedure.

procedure readEtdnac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table etDNAC 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoatt as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter table-handle phttEtdnac.
    define variable vhttBuffer as handle no-undo.
    define buffer etDNAC for etDNAC.

    vhttBuffer = phttEtdnac:default-buffer-handle.
    for first etDNAC no-lock
        where etDNAC.norol = piNorol
          and etDNAC.noatt = piNoatt
          and etDNAC.nodec = piNodec
          and etDNAC.norev = piNorev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtdnac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEtdnac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table etDNAC 
    Notes  : service externe. Critère piNodec = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoatt as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter table-handle phttEtdnac.
    define variable vhttBuffer as handle  no-undo.
    define buffer etDNAC for etDNAC.

    vhttBuffer = phttEtdnac:default-buffer-handle.
    if piNodec = ?
    then for each etDNAC no-lock
        where etDNAC.norol = piNorol
          and etDNAC.noatt = piNoatt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each etDNAC no-lock
        where etDNAC.norol = piNorol
          and etDNAC.noatt = piNoatt
          and etDNAC.nodec = piNodec:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtdnac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEtdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define variable vhNodec    as handle  no-undo.
    define variable vhNorev    as handle  no-undo.
    define buffer etDNAC for etDNAC.

    create query vhttquery.
    vhttBuffer = ghttEtdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEtdnac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhNoatt, output vhNodec, output vhNorev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etDNAC exclusive-lock
                where rowid(etDNAC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etDNAC:handle, 'norol/noatt/nodec/norev: ', substitute('&1/&2/&3/&4', vhNorol:buffer-value(), vhNoatt:buffer-value(), vhNodec:buffer-value(), vhNorev:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer etDNAC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEtdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer etDNAC for etDNAC.

    create query vhttquery.
    vhttBuffer = ghttEtdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEtdnac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create etDNAC.
            if not outils:copyValidField(buffer etDNAC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEtdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define variable vhNodec    as handle  no-undo.
    define variable vhNorev    as handle  no-undo.
    define buffer etDNAC for etDNAC.

    create query vhttquery.
    vhttBuffer = ghttEtdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEtdnac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhNoatt, output vhNodec, output vhNorev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etDNAC exclusive-lock
                where rowid(Etdnac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etDNAC:handle, 'norol/noatt/nodec/norev: ', substitute('&1/&2/&3/&4', vhNorol:buffer-value(), vhNoatt:buffer-value(), vhNodec:buffer-value(), vhNorev:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete etDNAC no-error.
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

