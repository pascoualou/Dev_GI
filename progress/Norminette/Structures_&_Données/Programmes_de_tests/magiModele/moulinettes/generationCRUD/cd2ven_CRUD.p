/*------------------------------------------------------------------------
File        : cd2ven_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cd2ven
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cd2ven.i}
{application/include/error.i}
define variable ghttcd2ven as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phZone-cd as handle, output phD2ven-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur zone-cd/d2ven-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'zone-cd' then phZone-cd = phBuffer:buffer-field(vi).
            when 'd2ven-cle' then phD2ven-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCd2ven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCd2ven.
    run updateCd2ven.
    run createCd2ven.
end procedure.

procedure setCd2ven:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCd2ven.
    ghttCd2ven = phttCd2ven.
    run crudCd2ven.
    delete object phttCd2ven.
end procedure.

procedure readCd2ven:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cd2ven Ventilations DAS2
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piZone-cd   as integer    no-undo.
    define input parameter pcD2ven-cle as character  no-undo.
    define input parameter table-handle phttCd2ven.
    define variable vhttBuffer as handle no-undo.
    define buffer cd2ven for cd2ven.

    vhttBuffer = phttCd2ven:default-buffer-handle.
    for first cd2ven no-lock
        where cd2ven.zone-cd = piZone-cd
          and cd2ven.d2ven-cle = pcD2ven-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2ven:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2ven no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCd2ven:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cd2ven Ventilations DAS2
    Notes  : service externe. Critère piZone-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piZone-cd   as integer    no-undo.
    define input parameter table-handle phttCd2ven.
    define variable vhttBuffer as handle  no-undo.
    define buffer cd2ven for cd2ven.

    vhttBuffer = phttCd2ven:default-buffer-handle.
    if piZone-cd = ?
    then for each cd2ven no-lock
        where cd2ven.zone-cd = piZone-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2ven:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cd2ven no-lock
        where cd2ven.zone-cd = piZone-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2ven:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2ven no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCd2ven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhZone-cd    as handle  no-undo.
    define variable vhD2ven-cle    as handle  no-undo.
    define buffer cd2ven for cd2ven.

    create query vhttquery.
    vhttBuffer = ghttCd2ven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCd2ven:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhZone-cd, output vhD2ven-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2ven exclusive-lock
                where rowid(cd2ven) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2ven:handle, 'zone-cd/d2ven-cle: ', substitute('&1/&2', vhZone-cd:buffer-value(), vhD2ven-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cd2ven:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCd2ven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cd2ven for cd2ven.

    create query vhttquery.
    vhttBuffer = ghttCd2ven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCd2ven:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cd2ven.
            if not outils:copyValidField(buffer cd2ven:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCd2ven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhZone-cd    as handle  no-undo.
    define variable vhD2ven-cle    as handle  no-undo.
    define buffer cd2ven for cd2ven.

    create query vhttquery.
    vhttBuffer = ghttCd2ven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCd2ven:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhZone-cd, output vhD2ven-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2ven exclusive-lock
                where rowid(Cd2ven) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2ven:handle, 'zone-cd/d2ven-cle: ', substitute('&1/&2', vhZone-cd:buffer-value(), vhD2ven-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cd2ven no-error.
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

