/*------------------------------------------------------------------------
File        : tdroit-it_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tdroit-it
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tdroit-it.i}
{application/include/error.i}
define variable ghtttdroit-it as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoite as handle, output phProfil_u as handle, output phCdapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noite/profil_u/cdapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noite' then phNoite = phBuffer:buffer-field(vi).
            when 'profil_u' then phProfil_u = phBuffer:buffer-field(vi).
            when 'cdapp' then phCdapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTdroit-it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTdroit-it.
    run updateTdroit-it.
    run createTdroit-it.
end procedure.

procedure setTdroit-it:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTdroit-it.
    ghttTdroit-it = phttTdroit-it.
    run crudTdroit-it.
    delete object phttTdroit-it.
end procedure.

procedure readTdroit-it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tdroit-it 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoite    as integer    no-undo.
    define input parameter pcProfil_u as character  no-undo.
    define input parameter pcCdapp    as character  no-undo.
    define input parameter table-handle phttTdroit-it.
    define variable vhttBuffer as handle no-undo.
    define buffer tdroit-it for tdroit-it.

    vhttBuffer = phttTdroit-it:default-buffer-handle.
    for first tdroit-it no-lock
        where tdroit-it.noite = piNoite
          and tdroit-it.profil_u = pcProfil_u
          and tdroit-it.cdapp = pcCdapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tdroit-it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTdroit-it no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTdroit-it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tdroit-it 
    Notes  : service externe. Critère pcProfil_u = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoite    as integer    no-undo.
    define input parameter pcProfil_u as character  no-undo.
    define input parameter table-handle phttTdroit-it.
    define variable vhttBuffer as handle  no-undo.
    define buffer tdroit-it for tdroit-it.

    vhttBuffer = phttTdroit-it:default-buffer-handle.
    if pcProfil_u = ?
    then for each tdroit-it no-lock
        where tdroit-it.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tdroit-it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tdroit-it no-lock
        where tdroit-it.noite = piNoite
          and tdroit-it.profil_u = pcProfil_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tdroit-it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTdroit-it no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTdroit-it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define variable vhCdapp    as handle  no-undo.
    define buffer tdroit-it for tdroit-it.

    create query vhttquery.
    vhttBuffer = ghttTdroit-it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTdroit-it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite, output vhProfil_u, output vhCdapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tdroit-it exclusive-lock
                where rowid(tdroit-it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tdroit-it:handle, 'noite/profil_u/cdapp: ', substitute('&1/&2/&3', vhNoite:buffer-value(), vhProfil_u:buffer-value(), vhCdapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tdroit-it:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTdroit-it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tdroit-it for tdroit-it.

    create query vhttquery.
    vhttBuffer = ghttTdroit-it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTdroit-it:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tdroit-it.
            if not outils:copyValidField(buffer tdroit-it:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTdroit-it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define variable vhCdapp    as handle  no-undo.
    define buffer tdroit-it for tdroit-it.

    create query vhttquery.
    vhttBuffer = ghttTdroit-it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTdroit-it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite, output vhProfil_u, output vhCdapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tdroit-it exclusive-lock
                where rowid(Tdroit-it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tdroit-it:handle, 'noite/profil_u/cdapp: ', substitute('&1/&2/&3', vhNoite:buffer-value(), vhProfil_u:buffer-value(), vhCdapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tdroit-it no-error.
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

