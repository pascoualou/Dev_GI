/*------------------------------------------------------------------------
File        : cinfis_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinfis
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinfis.i}
{application/include/error.i}
define variable ghttcinfis as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phDuree as handle, output phDadeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur duree/dadeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'duree' then phDuree = phBuffer:buffer-field(vi).
            when 'dadeb' then phDadeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinfis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinfis.
    run updateCinfis.
    run createCinfis.
end procedure.

procedure setCinfis:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinfis.
    ghttCinfis = phttCinfis.
    run crudCinfis.
    delete object phttCinfis.
end procedure.

procedure readCinfis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinfis fichier des coefficients fiscaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pdeDuree as decimal    no-undo.
    define input parameter pdaDadeb as date       no-undo.
    define input parameter table-handle phttCinfis.
    define variable vhttBuffer as handle no-undo.
    define buffer cinfis for cinfis.

    vhttBuffer = phttCinfis:default-buffer-handle.
    for first cinfis no-lock
        where cinfis.duree = pdeDuree
          and cinfis.dadeb = pdaDadeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinfis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinfis no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinfis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinfis fichier des coefficients fiscaux
    Notes  : service externe. Critère pdeDuree = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pdeDuree as decimal    no-undo.
    define input parameter table-handle phttCinfis.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinfis for cinfis.

    vhttBuffer = phttCinfis:default-buffer-handle.
    if pdeDuree = ?
    then for each cinfis no-lock
        where cinfis.duree = pdeDuree:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinfis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinfis no-lock
        where cinfis.duree = pdeDuree:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinfis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinfis no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinfis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhDuree    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer cinfis for cinfis.

    create query vhttquery.
    vhttBuffer = ghttCinfis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinfis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhDuree, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinfis exclusive-lock
                where rowid(cinfis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinfis:handle, 'duree/dadeb: ', substitute('&1/&2', vhDuree:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinfis:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinfis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinfis for cinfis.

    create query vhttquery.
    vhttBuffer = ghttCinfis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinfis:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinfis.
            if not outils:copyValidField(buffer cinfis:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinfis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhDuree    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer cinfis for cinfis.

    create query vhttquery.
    vhttBuffer = ghttCinfis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinfis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhDuree, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinfis exclusive-lock
                where rowid(Cinfis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinfis:handle, 'duree/dadeb: ', substitute('&1/&2', vhDuree:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinfis no-error.
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

