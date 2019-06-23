/*------------------------------------------------------------------------
File        : ACTIO_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ACTIO
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ACTIO.i}
{application/include/error.i}
define variable ghttACTIO as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoaff as handle, output phNoact as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NOAFF/NOACT, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NOAFF' then phNoaff = phBuffer:buffer-field(vi).
            when 'NOACT' then phNoact = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudActio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteActio.
    run updateActio.
    run createActio.
end procedure.

procedure setActio:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttActio.
    ghttActio = phttActio.
    run crudActio.
    delete object phttActio.
end procedure.

procedure readActio:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ACTIO 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoaff as integer    no-undo.
    define input parameter piNoact as integer    no-undo.
    define input parameter table-handle phttActio.
    define variable vhttBuffer as handle no-undo.
    define buffer ACTIO for ACTIO.

    vhttBuffer = phttActio:default-buffer-handle.
    for first ACTIO no-lock
        where ACTIO.NOAFF = piNoaff
          and ACTIO.NOACT = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ACTIO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttActio no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getActio:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ACTIO 
    Notes  : service externe. Critère piNoaff = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoaff as integer    no-undo.
    define input parameter table-handle phttActio.
    define variable vhttBuffer as handle  no-undo.
    define buffer ACTIO for ACTIO.

    vhttBuffer = phttActio:default-buffer-handle.
    if piNoaff = ?
    then for each ACTIO no-lock
        where ACTIO.NOAFF = piNoaff:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ACTIO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ACTIO no-lock
        where ACTIO.NOAFF = piNoaff:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ACTIO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttActio no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateActio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoaff    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define buffer ACTIO for ACTIO.

    create query vhttquery.
    vhttBuffer = ghttActio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttActio:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoaff, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ACTIO exclusive-lock
                where rowid(ACTIO) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ACTIO:handle, 'NOAFF/NOACT: ', substitute('&1/&2', vhNoaff:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ACTIO:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createActio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ACTIO for ACTIO.

    create query vhttquery.
    vhttBuffer = ghttActio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttActio:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ACTIO.
            if not outils:copyValidField(buffer ACTIO:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteActio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoaff    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define buffer ACTIO for ACTIO.

    create query vhttquery.
    vhttBuffer = ghttActio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttActio:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoaff, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ACTIO exclusive-lock
                where rowid(Actio) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ACTIO:handle, 'NOAFF/NOACT: ', substitute('&1/&2', vhNoaff:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ACTIO no-error.
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

