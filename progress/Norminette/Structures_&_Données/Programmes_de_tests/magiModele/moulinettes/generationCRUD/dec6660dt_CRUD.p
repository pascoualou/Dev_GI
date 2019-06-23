/*------------------------------------------------------------------------
File        : dec6660dt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table dec6660dt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/dec6660dt.i}
{application/include/error.i}
define variable ghttdec6660dt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phAnnee as handle, output phTpmdt as handle, output phNomdt as handle, output phNoapp as handle, output phNoimm as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur annee/tpmdt/nomdt/noapp/noimm/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDec6660dt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDec6660dt.
    run updateDec6660dt.
    run createDec6660dt.
end procedure.

procedure setDec6660dt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDec6660dt.
    ghttDec6660dt = phttDec6660dt.
    run crudDec6660dt.
    delete object phttDec6660dt.
end procedure.

procedure readDec6660dt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table dec6660dt Table detail de la declaration 6660
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttDec6660dt.
    define variable vhttBuffer as handle no-undo.
    define buffer dec6660dt for dec6660dt.

    vhttBuffer = phttDec6660dt:default-buffer-handle.
    for first dec6660dt no-lock
        where dec6660dt.annee = piAnnee
          and dec6660dt.tpmdt = pcTpmdt
          and dec6660dt.nomdt = piNomdt
          and dec6660dt.noapp = piNoapp
          and dec6660dt.noimm = piNoimm
          and dec6660dt.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dec6660dt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDec6660dt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDec6660dt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table dec6660dt Table detail de la declaration 6660
    Notes  : service externe. Critère piNoimm = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttDec6660dt.
    define variable vhttBuffer as handle  no-undo.
    define buffer dec6660dt for dec6660dt.

    vhttBuffer = phttDec6660dt:default-buffer-handle.
    if piNoimm = ?
    then for each dec6660dt no-lock
        where dec6660dt.annee = piAnnee
          and dec6660dt.tpmdt = pcTpmdt
          and dec6660dt.nomdt = piNomdt
          and dec6660dt.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dec6660dt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each dec6660dt no-lock
        where dec6660dt.annee = piAnnee
          and dec6660dt.tpmdt = pcTpmdt
          and dec6660dt.nomdt = piNomdt
          and dec6660dt.noapp = piNoapp
          and dec6660dt.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dec6660dt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDec6660dt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDec6660dt private:
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
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer dec6660dt for dec6660dt.

    create query vhttquery.
    vhttBuffer = ghttDec6660dt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDec6660dt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhTpmdt, output vhNomdt, output vhNoapp, output vhNoimm, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first dec6660dt exclusive-lock
                where rowid(dec6660dt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer dec6660dt:handle, 'annee/tpmdt/nomdt/noapp/noimm/nolot: ', substitute('&1/&2/&3/&4/&5/&6', vhAnnee:buffer-value(), vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer dec6660dt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDec6660dt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer dec6660dt for dec6660dt.

    create query vhttquery.
    vhttBuffer = ghttDec6660dt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDec6660dt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create dec6660dt.
            if not outils:copyValidField(buffer dec6660dt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDec6660dt private:
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
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer dec6660dt for dec6660dt.

    create query vhttquery.
    vhttBuffer = ghttDec6660dt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDec6660dt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhTpmdt, output vhNomdt, output vhNoapp, output vhNoimm, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first dec6660dt exclusive-lock
                where rowid(Dec6660dt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer dec6660dt:handle, 'annee/tpmdt/nomdt/noapp/noimm/nolot: ', substitute('&1/&2/&3/&4/&5/&6', vhAnnee:buffer-value(), vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete dec6660dt no-error.
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

