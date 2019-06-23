/*------------------------------------------------------------------------
File        : LSTSOCPROF_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table LSTSOCPROF
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/LSTSOCPROF.i}
{application/include/error.i}
define variable ghttLSTSOCPROF as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCdprofil as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/CDPROFIL, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'CDPROFIL' then phCdprofil = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLstsocprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLstsocprof.
    run updateLstsocprof.
    run createLstsocprof.
end procedure.

procedure setLstsocprof:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLstsocprof.
    ghttLstsocprof = phttLstsocprof.
    run crudLstsocprof.
    delete object phttLstsocprof.
end procedure.

procedure readLstsocprof:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table LSTSOCPROF 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcCdprofil as character  no-undo.
    define input parameter table-handle phttLstsocprof.
    define variable vhttBuffer as handle no-undo.
    define buffer LSTSOCPROF for LSTSOCPROF.

    vhttBuffer = phttLstsocprof:default-buffer-handle.
    for first LSTSOCPROF no-lock
        where LSTSOCPROF.soc-cd = piSoc-cd
          and LSTSOCPROF.CDPROFIL = pcCdprofil:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LSTSOCPROF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLstsocprof no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLstsocprof:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table LSTSOCPROF 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter table-handle phttLstsocprof.
    define variable vhttBuffer as handle  no-undo.
    define buffer LSTSOCPROF for LSTSOCPROF.

    vhttBuffer = phttLstsocprof:default-buffer-handle.
    if piSoc-cd = ?
    then for each LSTSOCPROF no-lock
        where LSTSOCPROF.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LSTSOCPROF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each LSTSOCPROF no-lock
        where LSTSOCPROF.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LSTSOCPROF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLstsocprof no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLstsocprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCdprofil    as handle  no-undo.
    define buffer LSTSOCPROF for LSTSOCPROF.

    create query vhttquery.
    vhttBuffer = ghttLstsocprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLstsocprof:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCdprofil).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LSTSOCPROF exclusive-lock
                where rowid(LSTSOCPROF) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LSTSOCPROF:handle, 'soc-cd/CDPROFIL: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCdprofil:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer LSTSOCPROF:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLstsocprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer LSTSOCPROF for LSTSOCPROF.

    create query vhttquery.
    vhttBuffer = ghttLstsocprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLstsocprof:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create LSTSOCPROF.
            if not outils:copyValidField(buffer LSTSOCPROF:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLstsocprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCdprofil    as handle  no-undo.
    define buffer LSTSOCPROF for LSTSOCPROF.

    create query vhttquery.
    vhttBuffer = ghttLstsocprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLstsocprof:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCdprofil).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LSTSOCPROF exclusive-lock
                where rowid(Lstsocprof) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LSTSOCPROF:handle, 'soc-cd/CDPROFIL: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCdprofil:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete LSTSOCPROF no-error.
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

