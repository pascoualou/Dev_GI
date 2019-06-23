/*------------------------------------------------------------------------
File        : aprmirf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aprmirf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aprmirf.i}
{application/include/error.i}
define variable ghttaprmirf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phAnnee as handle, output phOrdre as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur annee/ordre, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'ordre' then phOrdre = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAprmirf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAprmirf.
    run updateAprmirf.
    run createAprmirf.
end procedure.

procedure setAprmirf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAprmirf.
    ghttAprmirf = phttAprmirf.
    run crudAprmirf.
    delete object phttAprmirf.
end procedure.

procedure readAprmirf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aprmirf Table des codes IRF (2044, 2044S & 2072)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter piOrdre as integer    no-undo.
    define input parameter table-handle phttAprmirf.
    define variable vhttBuffer as handle no-undo.
    define buffer aprmirf for aprmirf.

    vhttBuffer = phttAprmirf:default-buffer-handle.
    for first aprmirf no-lock
        where aprmirf.annee = piAnnee
          and aprmirf.ordre = piOrdre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprmirf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAprmirf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAprmirf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aprmirf Table des codes IRF (2044, 2044S & 2072)
    Notes  : service externe. Critère piAnnee = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter table-handle phttAprmirf.
    define variable vhttBuffer as handle  no-undo.
    define buffer aprmirf for aprmirf.

    vhttBuffer = phttAprmirf:default-buffer-handle.
    if piAnnee = ?
    then for each aprmirf no-lock
        where aprmirf.annee = piAnnee:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprmirf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aprmirf no-lock
        where aprmirf.annee = piAnnee:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprmirf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAprmirf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAprmirf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhOrdre    as handle  no-undo.
    define buffer aprmirf for aprmirf.

    create query vhttquery.
    vhttBuffer = ghttAprmirf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAprmirf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhOrdre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aprmirf exclusive-lock
                where rowid(aprmirf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aprmirf:handle, 'annee/ordre: ', substitute('&1/&2', vhAnnee:buffer-value(), vhOrdre:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aprmirf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAprmirf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aprmirf for aprmirf.

    create query vhttquery.
    vhttBuffer = ghttAprmirf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAprmirf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aprmirf.
            if not outils:copyValidField(buffer aprmirf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAprmirf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhOrdre    as handle  no-undo.
    define buffer aprmirf for aprmirf.

    create query vhttquery.
    vhttBuffer = ghttAprmirf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAprmirf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhOrdre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aprmirf exclusive-lock
                where rowid(Aprmirf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aprmirf:handle, 'annee/ordre: ', substitute('&1/&2', vhAnnee:buffer-value(), vhOrdre:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aprmirf no-error.
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

