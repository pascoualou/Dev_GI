/*------------------------------------------------------------------------
File        : detip_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table detip
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/detip.i}
{application/include/error.i}
define variable ghttdetip as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNocon as handle, output phNoimm as handle, output phDtimp as handle, output phNolot as handle, output phNocop as handle, output phNochr as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nocon/noimm/dtimp/nolot/nocop/nochr, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'dtimp' then phDtimp = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'nocop' then phNocop = phBuffer:buffer-field(vi).
            when 'nochr' then phNochr = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDetip private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDetip.
    run updateDetip.
    run createDetip.
end procedure.

procedure setDetip:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDetip.
    ghttDetip = phttDetip.
    run crudDetip.
    delete object phttDetip.
end procedure.

procedure readDetip:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table detip 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter pdaDtimp as date       no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter piNochr as integer    no-undo.
    define input parameter table-handle phttDetip.
    define variable vhttBuffer as handle no-undo.
    define buffer detip for detip.

    vhttBuffer = phttDetip:default-buffer-handle.
    for first detip no-lock
        where detip.nocon = piNocon
          and detip.noimm = piNoimm
          and detip.dtimp = pdaDtimp
          and detip.nolot = piNolot
          and detip.nocop = piNocop
          and detip.nochr = piNochr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detip:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDetip no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDetip:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table detip 
    Notes  : service externe. Critère piNocop = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter pdaDtimp as date       no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter table-handle phttDetip.
    define variable vhttBuffer as handle  no-undo.
    define buffer detip for detip.

    vhttBuffer = phttDetip:default-buffer-handle.
    if piNocop = ?
    then for each detip no-lock
        where detip.nocon = piNocon
          and detip.noimm = piNoimm
          and detip.dtimp = pdaDtimp
          and detip.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detip:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each detip no-lock
        where detip.nocon = piNocon
          and detip.noimm = piNoimm
          and detip.dtimp = pdaDtimp
          and detip.nolot = piNolot
          and detip.nocop = piNocop:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detip:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDetip no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDetip private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhDtimp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define variable vhNochr    as handle  no-undo.
    define buffer detip for detip.

    create query vhttquery.
    vhttBuffer = ghttDetip:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDetip:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocon, output vhNoimm, output vhDtimp, output vhNolot, output vhNocop, output vhNochr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first detip exclusive-lock
                where rowid(detip) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer detip:handle, 'nocon/noimm/dtimp/nolot/nocop/nochr: ', substitute('&1/&2/&3/&4/&5/&6', vhNocon:buffer-value(), vhNoimm:buffer-value(), vhDtimp:buffer-value(), vhNolot:buffer-value(), vhNocop:buffer-value(), vhNochr:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer detip:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDetip private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer detip for detip.

    create query vhttquery.
    vhttBuffer = ghttDetip:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDetip:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create detip.
            if not outils:copyValidField(buffer detip:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDetip private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhDtimp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define variable vhNochr    as handle  no-undo.
    define buffer detip for detip.

    create query vhttquery.
    vhttBuffer = ghttDetip:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDetip:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocon, output vhNoimm, output vhDtimp, output vhNolot, output vhNocop, output vhNochr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first detip exclusive-lock
                where rowid(Detip) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer detip:handle, 'nocon/noimm/dtimp/nolot/nocop/nochr: ', substitute('&1/&2/&3/&4/&5/&6', vhNocon:buffer-value(), vhNoimm:buffer-value(), vhDtimp:buffer-value(), vhNolot:buffer-value(), vhNocop:buffer-value(), vhNochr:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete detip no-error.
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

