/*------------------------------------------------------------------------
File        : etage_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table etage
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/etage.i}
{application/include/error.i}
define variable ghttetage as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobat as handle, output phCdeta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobat/cdeta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobat' then phNobat = phBuffer:buffer-field(vi).
            when 'cdeta' then phCdeta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEtage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEtage.
    run updateEtage.
    run createEtage.
end procedure.

procedure setEtage:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEtage.
    ghttEtage = phttEtage.
    run crudEtage.
    delete object phttEtage.
end procedure.

procedure readEtage:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table etage 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobat as integer    no-undo.
    define input parameter pcCdeta as character  no-undo.
    define input parameter table-handle phttEtage.
    define variable vhttBuffer as handle no-undo.
    define buffer etage for etage.

    vhttBuffer = phttEtage:default-buffer-handle.
    for first etage no-lock
        where etage.nobat = piNobat
          and etage.cdeta = pcCdeta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtage no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEtage:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table etage 
    Notes  : service externe. Critère piNobat = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNobat as integer    no-undo.
    define input parameter table-handle phttEtage.
    define variable vhttBuffer as handle  no-undo.
    define buffer etage for etage.

    vhttBuffer = phttEtage:default-buffer-handle.
    if piNobat = ?
    then for each etage no-lock
        where etage.nobat = piNobat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each etage no-lock
        where etage.nobat = piNobat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtage no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEtage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobat    as handle  no-undo.
    define variable vhCdeta    as handle  no-undo.
    define buffer etage for etage.

    create query vhttquery.
    vhttBuffer = ghttEtage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEtage:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobat, output vhCdeta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etage exclusive-lock
                where rowid(etage) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etage:handle, 'nobat/cdeta: ', substitute('&1/&2', vhNobat:buffer-value(), vhCdeta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer etage:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEtage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer etage for etage.

    create query vhttquery.
    vhttBuffer = ghttEtage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEtage:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create etage.
            if not outils:copyValidField(buffer etage:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEtage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobat    as handle  no-undo.
    define variable vhCdeta    as handle  no-undo.
    define buffer etage for etage.

    create query vhttquery.
    vhttBuffer = ghttEtage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEtage:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobat, output vhCdeta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etage exclusive-lock
                where rowid(Etage) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etage:handle, 'nobat/cdeta: ', substitute('&1/&2', vhNobat:buffer-value(), vhCdeta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete etage no-error.
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

