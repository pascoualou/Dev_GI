/*------------------------------------------------------------------------
File        : calev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table calev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttcalev as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phCdrub as handle, output phCdlib as handle, output phNocal as handle, output phNoper as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/cdrub/cdlib/nocal/noper, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdlib' then phCdlib = phBuffer:buffer-field(vi).
            when 'nocal' then phNocal = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCalev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCalev.
    run updateCalev.
    run createCalev.
end procedure.

procedure setCalev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCalev.
    ghttCalev = phttCalev.
    run crudCalev.
    delete object phttCalev.
end procedure.

procedure readCalev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table calev Calendrier d'evolution des loyers
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter piCdrub as integer   no-undo.
    define input parameter piCdlib as integer   no-undo.
    define input parameter piNocal as integer   no-undo.
    define input parameter piNoper as integer   no-undo.
    define input parameter table-handle phttCalev.

    define variable vhttBuffer as handle no-undo.
    define buffer calev for calev.

    vhttBuffer = phttCalev:default-buffer-handle.
    for first calev no-lock
        where calev.tpcon = pcTpcon
          and calev.nocon = piNocon
          and calev.cdrub = piCdrub
          and calev.cdlib = piCdlib
          and calev.nocal = piNocal
          and calev.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer calev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCalev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCalev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table calev Calendrier d'evolution des loyers
    Notes  : service externe. Critère piNocal = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter piCdrub as integer   no-undo.
    define input parameter piCdlib as integer   no-undo.
    define input parameter piNocal as integer   no-undo.
    define input parameter table-handle phttCalev.

    define variable vhttBuffer as handle  no-undo.
    define buffer calev for calev.

    vhttBuffer = phttCalev:default-buffer-handle.
    if piNocal = ?
    then for each calev no-lock
        where calev.tpcon = pcTpcon
          and calev.nocon = piNocon
          and calev.cdrub = piCdrub
          and calev.cdlib = piCdlib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer calev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each calev no-lock
        where calev.tpcon = pcTpcon
          and calev.nocon = piNocon
          and calev.cdrub = piCdrub
          and calev.cdlib = piCdlib
          and calev.nocal = piNocal:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer calev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCalev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCalev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define variable vhNocal    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer calev for calev.

    create query vhttquery.
    vhttBuffer = ghttCalev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCalev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCdrub, output vhCdlib, output vhNocal, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first calev exclusive-lock
                where rowid(calev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer calev:handle, 'tpcon/nocon/cdrub/cdlib/nocal/noper: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value(), vhNocal:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer calev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCalev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer calev for calev.

    create query vhttquery.
    vhttBuffer = ghttCalev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCalev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create calev.
            if not outils:copyValidField(buffer calev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCalev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define variable vhNocal    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer calev for calev.

    create query vhttquery.
    vhttBuffer = ghttCalev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCalev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCdrub, output vhCdlib, output vhNocal, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first calev exclusive-lock
                where rowid(Calev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer calev:handle, 'tpcon/nocon/cdrub/cdlib/nocal/noper: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value(), vhNocal:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete calev no-error.
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

procedure deleteCalevSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    
    define buffer calev for calev.

blocTrans:
    do transaction:
        for each calev exclusive-lock   
            where calev.tpcon = pcTypeContrat
              and calev.nocon = piNumeroContrat:
            delete calev no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
