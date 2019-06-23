/*------------------------------------------------------------------------
File        : chaff_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table chaff
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/chaff.i}
{application/include/error.i}
define variable ghttchaff as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoper as handle, output phNoact as handle, output phNocal as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noper/noact/nocal, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
            when 'noact' then phNoact = phBuffer:buffer-field(vi).
            when 'nocal' then phNocal = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudChaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteChaff.
    run updateChaff.
    run createChaff.
end procedure.

procedure setChaff:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttChaff.
    ghttChaff = phttChaff.
    run crudChaff.
    delete object phttChaff.
end procedure.

procedure readChaff:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table chaff 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piNoact as integer    no-undo.
    define input parameter piNocal as integer    no-undo.
    define input parameter table-handle phttChaff.
    define variable vhttBuffer as handle no-undo.
    define buffer chaff for chaff.

    vhttBuffer = phttChaff:default-buffer-handle.
    for first chaff no-lock
        where chaff.tpcon = pcTpcon
          and chaff.nocon = piNocon
          and chaff.noper = piNoper
          and chaff.noact = piNoact
          and chaff.nocal = piNocal:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chaff:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChaff no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getChaff:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table chaff 
    Notes  : service externe. Critère piNoact = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piNoact as integer    no-undo.
    define input parameter table-handle phttChaff.
    define variable vhttBuffer as handle  no-undo.
    define buffer chaff for chaff.

    vhttBuffer = phttChaff:default-buffer-handle.
    if piNoact = ?
    then for each chaff no-lock
        where chaff.tpcon = pcTpcon
          and chaff.nocon = piNocon
          and chaff.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chaff:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each chaff no-lock
        where chaff.tpcon = pcTpcon
          and chaff.nocon = piNocon
          and chaff.noper = piNoper
          and chaff.noact = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chaff:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChaff no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateChaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define variable vhNocal    as handle  no-undo.
    define buffer chaff for chaff.

    create query vhttquery.
    vhttBuffer = ghttChaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttChaff:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoper, output vhNoact, output vhNocal).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first chaff exclusive-lock
                where rowid(chaff) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer chaff:handle, 'tpcon/nocon/noper/noact/nocal: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoper:buffer-value(), vhNoact:buffer-value(), vhNocal:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer chaff:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createChaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer chaff for chaff.

    create query vhttquery.
    vhttBuffer = ghttChaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttChaff:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create chaff.
            if not outils:copyValidField(buffer chaff:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteChaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define variable vhNocal    as handle  no-undo.
    define buffer chaff for chaff.

    create query vhttquery.
    vhttBuffer = ghttChaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttChaff:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoper, output vhNoact, output vhNocal).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first chaff exclusive-lock
                where rowid(Chaff) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer chaff:handle, 'tpcon/nocon/noper/noact/nocal: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoper:buffer-value(), vhNoact:buffer-value(), vhNocal:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete chaff no-error.
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

