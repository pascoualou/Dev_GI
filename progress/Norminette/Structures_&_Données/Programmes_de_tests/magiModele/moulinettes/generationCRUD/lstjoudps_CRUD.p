/*------------------------------------------------------------------------
File        : lstjoudps_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table lstjoudps
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/lstjoudps.i}
{application/include/error.i}
define variable ghttlstjoudps as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phMandat-cd as handle, output phJou-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/mandat-cd/jou-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'mandat-cd' then phMandat-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLstjoudps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLstjoudps.
    run updateLstjoudps.
    run createLstjoudps.
end procedure.

procedure setLstjoudps:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLstjoudps.
    ghttLstjoudps = phttLstjoudps.
    run crudLstjoudps.
    delete object phttLstjoudps.
end procedure.

procedure readLstjoudps:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table lstjoudps 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piMandat-cd as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter table-handle phttLstjoudps.
    define variable vhttBuffer as handle no-undo.
    define buffer lstjoudps for lstjoudps.

    vhttBuffer = phttLstjoudps:default-buffer-handle.
    for first lstjoudps no-lock
        where lstjoudps.soc-cd = piSoc-cd
          and lstjoudps.mandat-cd = piMandat-cd
          and lstjoudps.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstjoudps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLstjoudps no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLstjoudps:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table lstjoudps 
    Notes  : service externe. Critère piMandat-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piMandat-cd as integer    no-undo.
    define input parameter table-handle phttLstjoudps.
    define variable vhttBuffer as handle  no-undo.
    define buffer lstjoudps for lstjoudps.

    vhttBuffer = phttLstjoudps:default-buffer-handle.
    if piMandat-cd = ?
    then for each lstjoudps no-lock
        where lstjoudps.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstjoudps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each lstjoudps no-lock
        where lstjoudps.soc-cd = piSoc-cd
          and lstjoudps.mandat-cd = piMandat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstjoudps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLstjoudps no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLstjoudps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhMandat-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define buffer lstjoudps for lstjoudps.

    create query vhttquery.
    vhttBuffer = ghttLstjoudps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLstjoudps:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhMandat-cd, output vhJou-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lstjoudps exclusive-lock
                where rowid(lstjoudps) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lstjoudps:handle, 'soc-cd/mandat-cd/jou-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhMandat-cd:buffer-value(), vhJou-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer lstjoudps:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLstjoudps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer lstjoudps for lstjoudps.

    create query vhttquery.
    vhttBuffer = ghttLstjoudps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLstjoudps:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create lstjoudps.
            if not outils:copyValidField(buffer lstjoudps:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLstjoudps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhMandat-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define buffer lstjoudps for lstjoudps.

    create query vhttquery.
    vhttBuffer = ghttLstjoudps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLstjoudps:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhMandat-cd, output vhJou-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lstjoudps exclusive-lock
                where rowid(Lstjoudps) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lstjoudps:handle, 'soc-cd/mandat-cd/jou-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhMandat-cd:buffer-value(), vhJou-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete lstjoudps no-error.
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

