/*------------------------------------------------------------------------
File        : CHRONO_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table CHRONO
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/CHRONO.i}
{application/include/error.i}
define variable ghttCHRONO as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdtrait as handle, output phSoc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CDTRAIT/soc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CDTRAIT' then phCdtrait = phBuffer:buffer-field(vi).
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudChrono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteChrono.
    run updateChrono.
    run createChrono.
end procedure.

procedure setChrono:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttChrono.
    ghttChrono = phttChrono.
    run crudChrono.
    delete object phttChrono.
end procedure.

procedure readChrono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table CHRONO 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdtrait as character  no-undo.
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttChrono.
    define variable vhttBuffer as handle no-undo.
    define buffer CHRONO for CHRONO.

    vhttBuffer = phttChrono:default-buffer-handle.
    for first CHRONO no-lock
        where CHRONO.CDTRAIT = pcCdtrait
          and CHRONO.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer CHRONO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChrono no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getChrono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table CHRONO 
    Notes  : service externe. Critère pcCdtrait = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdtrait as character  no-undo.
    define input parameter table-handle phttChrono.
    define variable vhttBuffer as handle  no-undo.
    define buffer CHRONO for CHRONO.

    vhttBuffer = phttChrono:default-buffer-handle.
    if pcCdtrait = ?
    then for each CHRONO no-lock
        where CHRONO.CDTRAIT = pcCdtrait:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer CHRONO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each CHRONO no-lock
        where CHRONO.CDTRAIT = pcCdtrait:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer CHRONO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChrono no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateChrono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdtrait    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer CHRONO for CHRONO.

    create query vhttquery.
    vhttBuffer = ghttChrono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttChrono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdtrait, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first CHRONO exclusive-lock
                where rowid(CHRONO) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer CHRONO:handle, 'CDTRAIT/soc-cd: ', substitute('&1/&2', vhCdtrait:buffer-value(), vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer CHRONO:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createChrono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer CHRONO for CHRONO.

    create query vhttquery.
    vhttBuffer = ghttChrono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttChrono:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create CHRONO.
            if not outils:copyValidField(buffer CHRONO:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteChrono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdtrait    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer CHRONO for CHRONO.

    create query vhttquery.
    vhttBuffer = ghttChrono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttChrono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdtrait, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first CHRONO exclusive-lock
                where rowid(Chrono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer CHRONO:handle, 'CDTRAIT/soc-cd: ', substitute('&1/&2', vhCdtrait:buffer-value(), vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete CHRONO no-error.
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

