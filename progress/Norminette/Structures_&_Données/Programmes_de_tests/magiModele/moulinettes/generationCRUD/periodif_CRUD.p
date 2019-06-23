/*------------------------------------------------------------------------
File        : periodif_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table periodif
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/periodif.i}
{application/include/error.i}
define variable ghttperiodif as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpmdt as handle, output phNomdt as handle, output phNoexo as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpmdt/nomdt/noexo, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPeriodif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePeriodif.
    run updatePeriodif.
    run createPeriodif.
end procedure.

procedure setPeriodif:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPeriodif.
    ghttPeriodif = phttPeriodif.
    run crudPeriodif.
    delete object phttPeriodif.
end procedure.

procedure readPeriodif:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table periodif 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter table-handle phttPeriodif.
    define variable vhttBuffer as handle no-undo.
    define buffer periodif for periodif.

    vhttBuffer = phttPeriodif:default-buffer-handle.
    for first periodif no-lock
        where periodif.tpmdt = pcTpmdt
          and periodif.nomdt = piNomdt
          and periodif.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer periodif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPeriodif no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPeriodif:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table periodif 
    Notes  : service externe. Critère piNomdt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttPeriodif.
    define variable vhttBuffer as handle  no-undo.
    define buffer periodif for periodif.

    vhttBuffer = phttPeriodif:default-buffer-handle.
    if piNomdt = ?
    then for each periodif no-lock
        where periodif.tpmdt = pcTpmdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer periodif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each periodif no-lock
        where periodif.tpmdt = pcTpmdt
          and periodif.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer periodif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPeriodif no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePeriodif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define buffer periodif for periodif.

    create query vhttquery.
    vhttBuffer = ghttPeriodif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPeriodif:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhNoexo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first periodif exclusive-lock
                where rowid(periodif) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer periodif:handle, 'tpmdt/nomdt/noexo: ', substitute('&1/&2/&3', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer periodif:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPeriodif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer periodif for periodif.

    create query vhttquery.
    vhttBuffer = ghttPeriodif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPeriodif:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create periodif.
            if not outils:copyValidField(buffer periodif:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePeriodif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define buffer periodif for periodif.

    create query vhttquery.
    vhttBuffer = ghttPeriodif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPeriodif:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhNoexo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first periodif exclusive-lock
                where rowid(Periodif) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer periodif:handle, 'tpmdt/nomdt/noexo: ', substitute('&1/&2/&3', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete periodif no-error.
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

