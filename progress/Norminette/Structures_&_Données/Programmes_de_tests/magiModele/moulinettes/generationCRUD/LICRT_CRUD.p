/*------------------------------------------------------------------------
File        : LICRT_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table LICRT
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/LICRT.i}
{application/include/error.i}
define variable ghttLICRT as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodot as handle, output phCdcrt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodot/cdcrt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nodot' then phNodot = phBuffer:buffer-field(vi).
            when 'cdcrt' then phCdcrt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLicrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLicrt.
    run updateLicrt.
    run createLicrt.
end procedure.

procedure setLicrt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLicrt.
    ghttLicrt = phttLicrt.
    run crudLicrt.
    delete object phttLicrt.
end procedure.

procedure readLicrt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table LICRT Lien critère & modèle document
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodot as integer    no-undo.
    define input parameter pcCdcrt as character  no-undo.
    define input parameter table-handle phttLicrt.
    define variable vhttBuffer as handle no-undo.
    define buffer LICRT for LICRT.

    vhttBuffer = phttLicrt:default-buffer-handle.
    for first LICRT no-lock
        where LICRT.nodot = piNodot
          and LICRT.cdcrt = pcCdcrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LICRT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLicrt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLicrt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table LICRT Lien critère & modèle document
    Notes  : service externe. Critère piNodot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNodot as integer    no-undo.
    define input parameter table-handle phttLicrt.
    define variable vhttBuffer as handle  no-undo.
    define buffer LICRT for LICRT.

    vhttBuffer = phttLicrt:default-buffer-handle.
    if piNodot = ?
    then for each LICRT no-lock
        where LICRT.nodot = piNodot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LICRT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each LICRT no-lock
        where LICRT.nodot = piNodot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LICRT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLicrt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLicrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodot    as handle  no-undo.
    define variable vhCdcrt    as handle  no-undo.
    define buffer LICRT for LICRT.

    create query vhttquery.
    vhttBuffer = ghttLicrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLicrt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodot, output vhCdcrt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LICRT exclusive-lock
                where rowid(LICRT) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LICRT:handle, 'nodot/cdcrt: ', substitute('&1/&2', vhNodot:buffer-value(), vhCdcrt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer LICRT:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLicrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer LICRT for LICRT.

    create query vhttquery.
    vhttBuffer = ghttLicrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLicrt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create LICRT.
            if not outils:copyValidField(buffer LICRT:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLicrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodot    as handle  no-undo.
    define variable vhCdcrt    as handle  no-undo.
    define buffer LICRT for LICRT.

    create query vhttquery.
    vhttBuffer = ghttLicrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLicrt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodot, output vhCdcrt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LICRT exclusive-lock
                where rowid(Licrt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LICRT:handle, 'nodot/cdcrt: ', substitute('&1/&2', vhNodot:buffer-value(), vhCdcrt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete LICRT no-error.
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

