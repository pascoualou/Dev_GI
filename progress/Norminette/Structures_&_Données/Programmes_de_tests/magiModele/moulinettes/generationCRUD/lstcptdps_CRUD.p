/*------------------------------------------------------------------------
File        : lstcptdps_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table lstcptdps
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/lstcptdps.i}
{application/include/error.i}
define variable ghttlstcptdps as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phMandat-cd as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/mandat-cd/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'mandat-cd' then phMandat-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLstcptdps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLstcptdps.
    run updateLstcptdps.
    run createLstcptdps.
end procedure.

procedure setLstcptdps:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLstcptdps.
    ghttLstcptdps = phttLstcptdps.
    run crudLstcptdps.
    delete object phttLstcptdps.
end procedure.

procedure readLstcptdps:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table lstcptdps 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piMandat-cd as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter table-handle phttLstcptdps.
    define variable vhttBuffer as handle no-undo.
    define buffer lstcptdps for lstcptdps.

    vhttBuffer = phttLstcptdps:default-buffer-handle.
    for first lstcptdps no-lock
        where lstcptdps.soc-cd = piSoc-cd
          and lstcptdps.mandat-cd = piMandat-cd
          and lstcptdps.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstcptdps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLstcptdps no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLstcptdps:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table lstcptdps 
    Notes  : service externe. Critère piMandat-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piMandat-cd as integer    no-undo.
    define input parameter table-handle phttLstcptdps.
    define variable vhttBuffer as handle  no-undo.
    define buffer lstcptdps for lstcptdps.

    vhttBuffer = phttLstcptdps:default-buffer-handle.
    if piMandat-cd = ?
    then for each lstcptdps no-lock
        where lstcptdps.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstcptdps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each lstcptdps no-lock
        where lstcptdps.soc-cd = piSoc-cd
          and lstcptdps.mandat-cd = piMandat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstcptdps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLstcptdps no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLstcptdps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhMandat-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer lstcptdps for lstcptdps.

    create query vhttquery.
    vhttBuffer = ghttLstcptdps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLstcptdps:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhMandat-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lstcptdps exclusive-lock
                where rowid(lstcptdps) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lstcptdps:handle, 'soc-cd/mandat-cd/cpt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhMandat-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer lstcptdps:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLstcptdps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer lstcptdps for lstcptdps.

    create query vhttquery.
    vhttBuffer = ghttLstcptdps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLstcptdps:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create lstcptdps.
            if not outils:copyValidField(buffer lstcptdps:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLstcptdps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhMandat-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer lstcptdps for lstcptdps.

    create query vhttquery.
    vhttBuffer = ghttLstcptdps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLstcptdps:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhMandat-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lstcptdps exclusive-lock
                where rowid(Lstcptdps) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lstcptdps:handle, 'soc-cd/mandat-cd/cpt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhMandat-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete lstcptdps no-error.
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

