/*------------------------------------------------------------------------
File        : adres_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table adres
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/
{preprocesseur/nature2voie.i}

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{adresse/include/adresse.i}
{application/include/error.i}
define variable ghttadres as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoadr as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noadr, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noadr' then phNoadr = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

function assignField returns logical private(phNtvoi as handle, phCdpay as handle, phLibelleNatureVoie as handle, phLibellePays as handle):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    if valid-handle(phNtvoi) and valid-handle(phLibelleNatureVoie)
    then phLibelleNatureVoie:buffer-value() = if phNtvoi:buffer-value() = {&NATUREVOIE--} then "" else outilTraduction:getLibelleParam("NTVOI", phNtvoi:buffer-value()) no-error.
    if valid-handle(phCdpay) and valid-handle(phLibellePays)
    then phLibellePays:buffer-value()       = outilTraduction:getLibelleParam("CDPAY", phCdpay:buffer-value()) no-error.
end function.

function getNextAdres returns int64():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer adres for adres.

    {&_proparse_ prolint-nowarn(wholeindex)}
    for last adres no-lock:
        return adres.noadr.
    end.
    return 1.
end function.

procedure crudAdres private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAdres.
    run updateAdres.
    run createAdres.
end procedure.

procedure setAdres:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdres.
    ghttAdres = phttAdres.
    run crudAdres.
    delete object phttAdres.
end procedure.

procedure readAdres:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table adres 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoadr as int64   no-undo.
    define input parameter table-handle phttAdres.

    define variable vhttBuffer          as handle  no-undo.
    define variable vhNtvoi             as handle  no-undo.
    define variable vhCdpay             as handle  no-undo.
    define variable vhLibelleNatureVoie as handle  no-undo.
    define variable vhLibellePays       as handle  no-undo.
    define buffer adres for adres.

    vhttBuffer = phttAdres:default-buffer-handle.
    for first adres no-lock
        where adres.noadr = piNoadr:
        vhttBuffer:buffer-create().
        outils:copyValidField(input buffer adres:handle, vhttBuffer).           // copy table physique vers temp-table
        run getField(input buffer adres:handle, vhttBuffer, output vhNtvoi, output vhCdpay, output vhLibelleNatureVoie, output vhLibellePays).
        assignField(vhNtvoi, vhCdpay, vhLibelleNatureVoie, vhLibellePays).  // récupération de certains libellés.
    end.
    delete object phttAdres no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAdres:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table adres 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdres.

    define variable vhttBuffer          as handle  no-undo.
    define variable vhNtvoi             as handle  no-undo.
    define variable vhCdpay             as handle  no-undo.
    define variable vhLibelleNatureVoie as handle  no-undo.
    define variable vhLibellePays       as handle  no-undo.
    define buffer adres for adres.

    vhttBuffer = phttAdres:default-buffer-handle.
    run getField(input buffer adres:handle, vhttBuffer, output vhNtvoi, output vhCdpay, output vhLibelleNatureVoie, output vhLibellePays).
    for each adres no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adres:handle, vhttBuffer).                // copy table physique vers temp-table
        assignField(vhNtvoi, vhCdpay, vhLibelleNatureVoie, vhLibellePays). // récupération de certains libellés.
    end.
    delete object phttAdres no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAdres private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoadr    as handle  no-undo.
    define buffer adres for adres.

    create query vhttquery.
    vhttBuffer = ghttAdres:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAdres:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoadr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adres exclusive-lock
                where rowid(adres) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adres:handle, 'noadr: ', substitute('&1', vhNoadr:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer adres:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAdres private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoadr    as handle  no-undo.
    define variable viNoadr    as int64   no-undo.
    define buffer adres for adres.

    create query vhttquery.
    vhttBuffer = ghttAdres:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAdres:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoadr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            viNoadr = vhNoadr:buffer-value().
            if viNoadr = ? or viNoadr = 0 then vhNoadr:buffer-value() = getNextAdres().
            create adres.
            if not outils:copyValidField(buffer adres:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAdres private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoadr    as handle  no-undo.
    define buffer adres for adres.

    create query vhttquery.
    vhttBuffer = ghttAdres:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAdres:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoadr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adres exclusive-lock
                where rowid(Adres) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adres:handle, 'noadr: ', substitute('&1', vhNoadr:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete adres no-error.
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

procedure getField:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter phBuffer            as handle  no-undo.
    define input  parameter phttBuffer          as handle  no-undo.
    define output parameter phNtvoi             as handle  no-undo.
    define output parameter phCdpay             as handle  no-undo.
    define output parameter phLibelleNatureVoie as handle  no-undo.
    define output parameter phLibellePays       as handle  no-undo.

    define variable vi  as integer no-undo. 

    do vi = 1 to phBuffer:num-fields:    // table physique
        case phBuffer:buffer-field(vi):label:
            when 'ntvoi' then phNtvoi = phBuffer:buffer-field(vi).
            when 'cdpay' then phCdpay = phBuffer:buffer-field(vi).
       end case.
    end.
    do vi = 1 to phttBuffer:num-fields:    // table temporaire
        case phttBuffer:buffer-field(vi):label:
            when 'cLibelleNatureVoie' then phLibelleNatureVoie = phttBuffer:buffer-field(vi).
            when 'cLibellePays'       then phLibellePays       = phttBuffer:buffer-field(vi).
       end case.
    end.
end procedure.
