/*------------------------------------------------------------------------
File        : reparub_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table reparub
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/reparub.i}
{application/include/error.i}
define variable ghttreparub as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTptyp as handle, output phNogrp as handle, output phNolig as handle, output phTprub as handle, output phCdrub as handle, output phCdsrb as handle, output phFisc-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tptyp/nogrp/nolig/tprub/cdrub/cdsrb/fisc-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tptyp' then phTptyp = phBuffer:buffer-field(vi).
            when 'nogrp' then phNogrp = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
            when 'tprub' then phTprub = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdsrb' then phCdsrb = phBuffer:buffer-field(vi).
            when 'fisc-cle' then phFisc-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudReparub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteReparub.
    run updateReparub.
    run createReparub.
end procedure.

procedure setReparub:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttReparub.
    ghttReparub = phttReparub.
    run crudReparub.
    delete object phttReparub.
end procedure.

procedure readReparub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table reparub Présentation généralisée  des rubriques : répartition des rubriques analytique et de quittancement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTptyp    as character  no-undo.
    define input parameter piNogrp    as integer    no-undo.
    define input parameter piNolig    as integer    no-undo.
    define input parameter pcTprub    as character  no-undo.
    define input parameter piCdrub    as integer    no-undo.
    define input parameter piCdsrb    as integer    no-undo.
    define input parameter pcFisc-cle as character  no-undo.
    define input parameter table-handle phttReparub.
    define variable vhttBuffer as handle no-undo.
    define buffer reparub for reparub.

    vhttBuffer = phttReparub:default-buffer-handle.
    for first reparub no-lock
        where reparub.tptyp = pcTptyp
          and reparub.nogrp = piNogrp
          and reparub.nolig = piNolig
          and reparub.tprub = pcTprub
          and reparub.cdrub = piCdrub
          and reparub.cdsrb = piCdsrb
          and reparub.fisc-cle = pcFisc-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer reparub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttReparub no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getReparub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table reparub Présentation généralisée  des rubriques : répartition des rubriques analytique et de quittancement
    Notes  : service externe. Critère piCdsrb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTptyp    as character  no-undo.
    define input parameter piNogrp    as integer    no-undo.
    define input parameter piNolig    as integer    no-undo.
    define input parameter pcTprub    as character  no-undo.
    define input parameter piCdrub    as integer    no-undo.
    define input parameter piCdsrb    as integer    no-undo.
    define input parameter table-handle phttReparub.
    define variable vhttBuffer as handle  no-undo.
    define buffer reparub for reparub.

    vhttBuffer = phttReparub:default-buffer-handle.
    if piCdsrb = ?
    then for each reparub no-lock
        where reparub.tptyp = pcTptyp
          and reparub.nogrp = piNogrp
          and reparub.nolig = piNolig
          and reparub.tprub = pcTprub
          and reparub.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer reparub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each reparub no-lock
        where reparub.tptyp = pcTptyp
          and reparub.nogrp = piNogrp
          and reparub.nolig = piNolig
          and reparub.tprub = pcTprub
          and reparub.cdrub = piCdrub
          and reparub.cdsrb = piCdsrb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer reparub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttReparub no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateReparub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptyp    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhTprub    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define variable vhFisc-cle    as handle  no-undo.
    define buffer reparub for reparub.

    create query vhttquery.
    vhttBuffer = ghttReparub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttReparub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptyp, output vhNogrp, output vhNolig, output vhTprub, output vhCdrub, output vhCdsrb, output vhFisc-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first reparub exclusive-lock
                where rowid(reparub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer reparub:handle, 'tptyp/nogrp/nolig/tprub/cdrub/cdsrb/fisc-cle: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTptyp:buffer-value(), vhNogrp:buffer-value(), vhNolig:buffer-value(), vhTprub:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value(), vhFisc-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer reparub:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createReparub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer reparub for reparub.

    create query vhttquery.
    vhttBuffer = ghttReparub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttReparub:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create reparub.
            if not outils:copyValidField(buffer reparub:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteReparub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptyp    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhTprub    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define variable vhFisc-cle    as handle  no-undo.
    define buffer reparub for reparub.

    create query vhttquery.
    vhttBuffer = ghttReparub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttReparub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptyp, output vhNogrp, output vhNolig, output vhTprub, output vhCdrub, output vhCdsrb, output vhFisc-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first reparub exclusive-lock
                where rowid(Reparub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer reparub:handle, 'tptyp/nogrp/nolig/tprub/cdrub/cdsrb/fisc-cle: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTptyp:buffer-value(), vhNogrp:buffer-value(), vhNolig:buffer-value(), vhTprub:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value(), vhFisc-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete reparub no-error.
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

