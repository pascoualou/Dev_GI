/*------------------------------------------------------------------------
File        : SvDev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SvDev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SvDev.i}
{application/include/error.i}
define variable ghttSvDev as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodev as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoDev/NoInt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoDev' then phNodev = phBuffer:buffer-field(vi).
            when 'NoInt' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSvdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSvdev.
    run updateSvdev.
    run createSvdev.
end procedure.

procedure setSvdev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSvdev.
    ghttSvdev = phttSvdev.
    run crudSvdev.
    delete object phttSvdev.
end procedure.

procedure readSvdev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SvDev Chaine Travaux : Table du Suivi des Devis
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodev as integer    no-undo.
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttSvdev.
    define variable vhttBuffer as handle no-undo.
    define buffer SvDev for SvDev.

    vhttBuffer = phttSvdev:default-buffer-handle.
    for first SvDev no-lock
        where SvDev.NoDev = piNodev
          and SvDev.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SvDev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvdev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSvdev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SvDev Chaine Travaux : Table du Suivi des Devis
    Notes  : service externe. Critère piNodev = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNodev as integer    no-undo.
    define input parameter table-handle phttSvdev.
    define variable vhttBuffer as handle  no-undo.
    define buffer SvDev for SvDev.

    vhttBuffer = phttSvdev:default-buffer-handle.
    if piNodev = ?
    then for each SvDev no-lock
        where SvDev.NoDev = piNodev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SvDev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SvDev no-lock
        where SvDev.NoDev = piNodev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SvDev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvdev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSvdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodev    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer SvDev for SvDev.

    create query vhttquery.
    vhttBuffer = ghttSvdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSvdev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodev, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SvDev exclusive-lock
                where rowid(SvDev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SvDev:handle, 'NoDev/NoInt: ', substitute('&1/&2', vhNodev:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SvDev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSvdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SvDev for SvDev.

    create query vhttquery.
    vhttBuffer = ghttSvdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSvdev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SvDev.
            if not outils:copyValidField(buffer SvDev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSvdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodev    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer SvDev for SvDev.

    create query vhttquery.
    vhttBuffer = ghttSvdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSvdev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodev, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SvDev exclusive-lock
                where rowid(Svdev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SvDev:handle, 'NoDev/NoInt: ', substitute('&1/&2', vhNodev:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SvDev no-error.
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

