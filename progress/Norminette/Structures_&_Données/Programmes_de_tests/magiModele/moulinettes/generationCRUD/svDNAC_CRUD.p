/*------------------------------------------------------------------------
File        : svDNAC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table svDNAC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/svDNAC.i}
{application/include/error.i}
define variable ghttsvDNAC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNorol as handle, output phNoatt as handle, output phNodec as handle, output phNorev as handle, output phNoact as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norol/noatt/nodec/norev/noact, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'noatt' then phNoatt = phBuffer:buffer-field(vi).
            when 'nodec' then phNodec = phBuffer:buffer-field(vi).
            when 'norev' then phNorev = phBuffer:buffer-field(vi).
            when 'noact' then phNoact = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSvdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSvdnac.
    run updateSvdnac.
    run createSvdnac.
end procedure.

procedure setSvdnac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSvdnac.
    ghttSvdnac = phttSvdnac.
    run crudSvdnac.
    delete object phttSvdnac.
end procedure.

procedure readSvdnac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table svDNAC 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoatt as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoact as integer    no-undo.
    define input parameter table-handle phttSvdnac.
    define variable vhttBuffer as handle no-undo.
    define buffer svDNAC for svDNAC.

    vhttBuffer = phttSvdnac:default-buffer-handle.
    for first svDNAC no-lock
        where svDNAC.norol = piNorol
          and svDNAC.noatt = piNoatt
          and svDNAC.nodec = piNodec
          and svDNAC.norev = piNorev
          and svDNAC.noact = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvdnac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSvdnac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table svDNAC 
    Notes  : service externe. Critère piNorev = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoatt as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter table-handle phttSvdnac.
    define variable vhttBuffer as handle  no-undo.
    define buffer svDNAC for svDNAC.

    vhttBuffer = phttSvdnac:default-buffer-handle.
    if piNorev = ?
    then for each svDNAC no-lock
        where svDNAC.norol = piNorol
          and svDNAC.noatt = piNoatt
          and svDNAC.nodec = piNodec:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each svDNAC no-lock
        where svDNAC.norol = piNorol
          and svDNAC.noatt = piNoatt
          and svDNAC.nodec = piNodec
          and svDNAC.norev = piNorev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvdnac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSvdnac private:
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
    define variable vhNoact    as handle  no-undo.
    define buffer svDNAC for svDNAC.

    create query vhttquery.
    vhttBuffer = ghttSvdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSvdnac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhNoatt, output vhNodec, output vhNorev, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first svDNAC exclusive-lock
                where rowid(svDNAC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer svDNAC:handle, 'norol/noatt/nodec/norev/noact: ', substitute('&1/&2/&3/&4/&5', vhNorol:buffer-value(), vhNoatt:buffer-value(), vhNodec:buffer-value(), vhNorev:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer svDNAC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSvdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer svDNAC for svDNAC.

    create query vhttquery.
    vhttBuffer = ghttSvdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSvdnac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create svDNAC.
            if not outils:copyValidField(buffer svDNAC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSvdnac private:
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
    define variable vhNoact    as handle  no-undo.
    define buffer svDNAC for svDNAC.

    create query vhttquery.
    vhttBuffer = ghttSvdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSvdnac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhNoatt, output vhNodec, output vhNorev, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first svDNAC exclusive-lock
                where rowid(Svdnac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer svDNAC:handle, 'norol/noatt/nodec/norev/noact: ', substitute('&1/&2/&3/&4/&5', vhNorol:buffer-value(), vhNoatt:buffer-value(), vhNodec:buffer-value(), vhNorev:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete svDNAC no-error.
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

