/*------------------------------------------------------------------------
File        : secte_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table secte
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/secte.i}
{application/include/error.i}
define variable ghttsecte as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdapp as handle, output phCddep as handle, output phCdsec as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdapp/cddep/cdsec, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdapp' then phCdapp = phBuffer:buffer-field(vi).
            when 'cddep' then phCddep = phBuffer:buffer-field(vi).
            when 'cdsec' then phCdsec = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSecte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSecte.
    run updateSecte.
    run createSecte.
end procedure.

procedure setSecte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSecte.
    ghttSecte = phttSecte.
    run crudSecte.
    delete object phttSecte.
end procedure.

procedure readSecte:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table secte 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdapp as character  no-undo.
    define input parameter piCddep as integer    no-undo.
    define input parameter pcCdsec as character  no-undo.
    define input parameter table-handle phttSecte.
    define variable vhttBuffer as handle no-undo.
    define buffer secte for secte.

    vhttBuffer = phttSecte:default-buffer-handle.
    for first secte no-lock
        where secte.cdapp = pcCdapp
          and secte.cddep = piCddep
          and secte.cdsec = pcCdsec:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer secte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSecte no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSecte:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table secte 
    Notes  : service externe. Critère piCddep = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdapp as character  no-undo.
    define input parameter piCddep as integer    no-undo.
    define input parameter table-handle phttSecte.
    define variable vhttBuffer as handle  no-undo.
    define buffer secte for secte.

    vhttBuffer = phttSecte:default-buffer-handle.
    if piCddep = ?
    then for each secte no-lock
        where secte.cdapp = pcCdapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer secte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each secte no-lock
        where secte.cdapp = pcCdapp
          and secte.cddep = piCddep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer secte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSecte no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSecte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdapp    as handle  no-undo.
    define variable vhCddep    as handle  no-undo.
    define variable vhCdsec    as handle  no-undo.
    define buffer secte for secte.

    create query vhttquery.
    vhttBuffer = ghttSecte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSecte:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdapp, output vhCddep, output vhCdsec).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first secte exclusive-lock
                where rowid(secte) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer secte:handle, 'cdapp/cddep/cdsec: ', substitute('&1/&2/&3', vhCdapp:buffer-value(), vhCddep:buffer-value(), vhCdsec:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer secte:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSecte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer secte for secte.

    create query vhttquery.
    vhttBuffer = ghttSecte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSecte:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create secte.
            if not outils:copyValidField(buffer secte:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSecte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdapp    as handle  no-undo.
    define variable vhCddep    as handle  no-undo.
    define variable vhCdsec    as handle  no-undo.
    define buffer secte for secte.

    create query vhttquery.
    vhttBuffer = ghttSecte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSecte:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdapp, output vhCddep, output vhCdsec).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first secte exclusive-lock
                where rowid(Secte) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer secte:handle, 'cdapp/cddep/cdsec: ', substitute('&1/&2/&3', vhCdapp:buffer-value(), vhCddep:buffer-value(), vhCdsec:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete secte no-error.
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

