/*------------------------------------------------------------------------
File        : tdroit-fnc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tdroit-fnc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tdroit-fnc.i}
{application/include/error.i}
define variable ghtttdroit-fnc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdapp as handle, output phProfil_u as handle, output phNoite as handle, output phCode_fonction as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdapp/profil_u/noite/code_fonction, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdapp' then phCdapp = phBuffer:buffer-field(vi).
            when 'profil_u' then phProfil_u = phBuffer:buffer-field(vi).
            when 'noite' then phNoite = phBuffer:buffer-field(vi).
            when 'code_fonction' then phCode_fonction = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTdroit-fnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTdroit-fnc.
    run updateTdroit-fnc.
    run createTdroit-fnc.
end procedure.

procedure setTdroit-fnc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTdroit-fnc.
    ghttTdroit-fnc = phttTdroit-fnc.
    run crudTdroit-fnc.
    delete object phttTdroit-fnc.
end procedure.

procedure readTdroit-fnc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tdroit-fnc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdapp         as character  no-undo.
    define input parameter pcProfil_u      as character  no-undo.
    define input parameter piNoite         as integer    no-undo.
    define input parameter pcCode_fonction as character  no-undo.
    define input parameter table-handle phttTdroit-fnc.
    define variable vhttBuffer as handle no-undo.
    define buffer tdroit-fnc for tdroit-fnc.

    vhttBuffer = phttTdroit-fnc:default-buffer-handle.
    for first tdroit-fnc no-lock
        where tdroit-fnc.cdapp = pcCdapp
          and tdroit-fnc.profil_u = pcProfil_u
          and tdroit-fnc.noite = piNoite
          and tdroit-fnc.code_fonction = pcCode_fonction:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tdroit-fnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTdroit-fnc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTdroit-fnc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tdroit-fnc 
    Notes  : service externe. Critère piNoite = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdapp         as character  no-undo.
    define input parameter pcProfil_u      as character  no-undo.
    define input parameter piNoite         as integer    no-undo.
    define input parameter table-handle phttTdroit-fnc.
    define variable vhttBuffer as handle  no-undo.
    define buffer tdroit-fnc for tdroit-fnc.

    vhttBuffer = phttTdroit-fnc:default-buffer-handle.
    if piNoite = ?
    then for each tdroit-fnc no-lock
        where tdroit-fnc.cdapp = pcCdapp
          and tdroit-fnc.profil_u = pcProfil_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tdroit-fnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tdroit-fnc no-lock
        where tdroit-fnc.cdapp = pcCdapp
          and tdroit-fnc.profil_u = pcProfil_u
          and tdroit-fnc.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tdroit-fnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTdroit-fnc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTdroit-fnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdapp    as handle  no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define variable vhNoite    as handle  no-undo.
    define variable vhCode_fonction    as handle  no-undo.
    define buffer tdroit-fnc for tdroit-fnc.

    create query vhttquery.
    vhttBuffer = ghttTdroit-fnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTdroit-fnc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdapp, output vhProfil_u, output vhNoite, output vhCode_fonction).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tdroit-fnc exclusive-lock
                where rowid(tdroit-fnc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tdroit-fnc:handle, 'cdapp/profil_u/noite/code_fonction: ', substitute('&1/&2/&3/&4', vhCdapp:buffer-value(), vhProfil_u:buffer-value(), vhNoite:buffer-value(), vhCode_fonction:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tdroit-fnc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTdroit-fnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tdroit-fnc for tdroit-fnc.

    create query vhttquery.
    vhttBuffer = ghttTdroit-fnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTdroit-fnc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tdroit-fnc.
            if not outils:copyValidField(buffer tdroit-fnc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTdroit-fnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdapp    as handle  no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define variable vhNoite    as handle  no-undo.
    define variable vhCode_fonction    as handle  no-undo.
    define buffer tdroit-fnc for tdroit-fnc.

    create query vhttquery.
    vhttBuffer = ghttTdroit-fnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTdroit-fnc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdapp, output vhProfil_u, output vhNoite, output vhCode_fonction).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tdroit-fnc exclusive-lock
                where rowid(Tdroit-fnc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tdroit-fnc:handle, 'cdapp/profil_u/noite/code_fonction: ', substitute('&1/&2/&3/&4', vhCdapp:buffer-value(), vhProfil_u:buffer-value(), vhNoite:buffer-value(), vhCode_fonction:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tdroit-fnc no-error.
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

