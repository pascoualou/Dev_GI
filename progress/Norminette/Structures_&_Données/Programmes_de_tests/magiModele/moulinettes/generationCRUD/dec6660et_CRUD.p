/*------------------------------------------------------------------------
File        : dec6660et_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table dec6660et
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/dec6660et.i}
{application/include/error.i}
define variable ghttdec6660et as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phAnnee as handle, output phTpmdt as handle, output phNomdt as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur annee/tpmdt/nomdt/noapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDec6660et private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDec6660et.
    run updateDec6660et.
    run createDec6660et.
end procedure.

procedure setDec6660et:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDec6660et.
    ghttDec6660et = phttDec6660et.
    run crudDec6660et.
    delete object phttDec6660et.
end procedure.

procedure readDec6660et:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table dec6660et Table entete de la declaration 6660
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttDec6660et.
    define variable vhttBuffer as handle no-undo.
    define buffer dec6660et for dec6660et.

    vhttBuffer = phttDec6660et:default-buffer-handle.
    for first dec6660et no-lock
        where dec6660et.annee = piAnnee
          and dec6660et.tpmdt = pcTpmdt
          and dec6660et.nomdt = piNomdt
          and dec6660et.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dec6660et:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDec6660et no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDec6660et:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table dec6660et Table entete de la declaration 6660
    Notes  : service externe. Critère piNomdt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttDec6660et.
    define variable vhttBuffer as handle  no-undo.
    define buffer dec6660et for dec6660et.

    vhttBuffer = phttDec6660et:default-buffer-handle.
    if piNomdt = ?
    then for each dec6660et no-lock
        where dec6660et.annee = piAnnee
          and dec6660et.tpmdt = pcTpmdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dec6660et:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each dec6660et no-lock
        where dec6660et.annee = piAnnee
          and dec6660et.tpmdt = pcTpmdt
          and dec6660et.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dec6660et:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDec6660et no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDec6660et private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer dec6660et for dec6660et.

    create query vhttquery.
    vhttBuffer = ghttDec6660et:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDec6660et:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhTpmdt, output vhNomdt, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first dec6660et exclusive-lock
                where rowid(dec6660et) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer dec6660et:handle, 'annee/tpmdt/nomdt/noapp: ', substitute('&1/&2/&3/&4', vhAnnee:buffer-value(), vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer dec6660et:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDec6660et private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer dec6660et for dec6660et.

    create query vhttquery.
    vhttBuffer = ghttDec6660et:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDec6660et:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create dec6660et.
            if not outils:copyValidField(buffer dec6660et:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDec6660et private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer dec6660et for dec6660et.

    create query vhttquery.
    vhttBuffer = ghttDec6660et:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDec6660et:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhTpmdt, output vhNomdt, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first dec6660et exclusive-lock
                where rowid(Dec6660et) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer dec6660et:handle, 'annee/tpmdt/nomdt/noapp: ', substitute('&1/&2/&3/&4', vhAnnee:buffer-value(), vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete dec6660et no-error.
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

