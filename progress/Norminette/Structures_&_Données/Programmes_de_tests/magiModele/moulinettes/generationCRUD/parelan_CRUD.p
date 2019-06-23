/*------------------------------------------------------------------------
File        : parelan_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table parelan
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/parelan.i}
{application/include/error.i}
define variable ghttparelan as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRelance-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/relance-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'relance-cd' then phRelance-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudParelan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteParelan.
    run updateParelan.
    run createParelan.
end procedure.

procedure setParelan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParelan.
    ghttParelan = phttParelan.
    run crudParelan.
    delete object phttParelan.
end procedure.

procedure readParelan:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table parelan Parametrage des relances
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piRelance-cd as integer    no-undo.
    define input parameter table-handle phttParelan.
    define variable vhttBuffer as handle no-undo.
    define buffer parelan for parelan.

    vhttBuffer = phttParelan:default-buffer-handle.
    for first parelan no-lock
        where parelan.soc-cd = piSoc-cd
          and parelan.etab-cd = piEtab-cd
          and parelan.relance-cd = piRelance-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parelan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParelan no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getParelan:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table parelan Parametrage des relances
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttParelan.
    define variable vhttBuffer as handle  no-undo.
    define buffer parelan for parelan.

    vhttBuffer = phttParelan:default-buffer-handle.
    if piEtab-cd = ?
    then for each parelan no-lock
        where parelan.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parelan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each parelan no-lock
        where parelan.soc-cd = piSoc-cd
          and parelan.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parelan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParelan no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateParelan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRelance-cd    as handle  no-undo.
    define buffer parelan for parelan.

    create query vhttquery.
    vhttBuffer = ghttParelan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttParelan:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRelance-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parelan exclusive-lock
                where rowid(parelan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parelan:handle, 'soc-cd/etab-cd/relance-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRelance-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer parelan:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createParelan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer parelan for parelan.

    create query vhttquery.
    vhttBuffer = ghttParelan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttParelan:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create parelan.
            if not outils:copyValidField(buffer parelan:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteParelan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRelance-cd    as handle  no-undo.
    define buffer parelan for parelan.

    create query vhttquery.
    vhttBuffer = ghttParelan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttParelan:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRelance-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parelan exclusive-lock
                where rowid(Parelan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parelan:handle, 'soc-cd/etab-cd/relance-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRelance-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete parelan no-error.
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

