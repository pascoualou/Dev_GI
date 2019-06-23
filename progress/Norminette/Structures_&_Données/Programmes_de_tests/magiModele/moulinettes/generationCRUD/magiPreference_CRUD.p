/*------------------------------------------------------------------------
File        : magiPreference_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table magiPreference
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/magiPreference.i}
{application/include/error.i}
define variable ghttmagiPreference as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCtype as handle, output phCsoustype as handle, output phCrefprincipale as handle, output phCuser as handle, output phJsessionid as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cType/cSousType/cRefPrincipale/cUser/jSessionId, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cType' then phCtype = phBuffer:buffer-field(vi).
            when 'cSousType' then phCsoustype = phBuffer:buffer-field(vi).
            when 'cRefPrincipale' then phCrefprincipale = phBuffer:buffer-field(vi).
            when 'cUser' then phCuser = phBuffer:buffer-field(vi).
            when 'jSessionId' then phJsessionid = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMagipreference private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMagipreference.
    run updateMagipreference.
    run createMagipreference.
end procedure.

procedure setMagipreference:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMagipreference.
    ghttMagipreference = phttMagipreference.
    run crudMagipreference.
    delete object phttMagipreference.
end procedure.

procedure readMagipreference:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table magiPreference 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCtype          as character  no-undo.
    define input parameter pcCsoustype      as character  no-undo.
    define input parameter pcCrefprincipale as character  no-undo.
    define input parameter pcCuser          as character  no-undo.
    define input parameter pcJsessionid     as character  no-undo.
    define input parameter table-handle phttMagipreference.
    define variable vhttBuffer as handle no-undo.
    define buffer magiPreference for magiPreference.

    vhttBuffer = phttMagipreference:default-buffer-handle.
    for first magiPreference no-lock
        where magiPreference.cType = pcCtype
          and magiPreference.cSousType = pcCsoustype
          and magiPreference.cRefPrincipale = pcCrefprincipale
          and magiPreference.cUser = pcCuser
          and magiPreference.jSessionId = pcJsessionid:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer magiPreference:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMagipreference no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMagipreference:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table magiPreference 
    Notes  : service externe. Critère pcCuser = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCtype          as character  no-undo.
    define input parameter pcCsoustype      as character  no-undo.
    define input parameter pcCrefprincipale as character  no-undo.
    define input parameter pcCuser          as character  no-undo.
    define input parameter table-handle phttMagipreference.
    define variable vhttBuffer as handle  no-undo.
    define buffer magiPreference for magiPreference.

    vhttBuffer = phttMagipreference:default-buffer-handle.
    if pcCuser = ?
    then for each magiPreference no-lock
        where magiPreference.cType = pcCtype
          and magiPreference.cSousType = pcCsoustype
          and magiPreference.cRefPrincipale = pcCrefprincipale:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer magiPreference:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each magiPreference no-lock
        where magiPreference.cType = pcCtype
          and magiPreference.cSousType = pcCsoustype
          and magiPreference.cRefPrincipale = pcCrefprincipale
          and magiPreference.cUser = pcCuser:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer magiPreference:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMagipreference no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMagipreference private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCtype    as handle  no-undo.
    define variable vhCsoustype    as handle  no-undo.
    define variable vhCrefprincipale    as handle  no-undo.
    define variable vhCuser    as handle  no-undo.
    define variable vhJsessionid    as handle  no-undo.
    define buffer magiPreference for magiPreference.

    create query vhttquery.
    vhttBuffer = ghttMagipreference:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMagipreference:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCtype, output vhCsoustype, output vhCrefprincipale, output vhCuser, output vhJsessionid).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first magiPreference exclusive-lock
                where rowid(magiPreference) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer magiPreference:handle, 'cType/cSousType/cRefPrincipale/cUser/jSessionId: ', substitute('&1/&2/&3/&4/&5', vhCtype:buffer-value(), vhCsoustype:buffer-value(), vhCrefprincipale:buffer-value(), vhCuser:buffer-value(), vhJsessionid:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer magiPreference:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMagipreference private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer magiPreference for magiPreference.

    create query vhttquery.
    vhttBuffer = ghttMagipreference:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMagipreference:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create magiPreference.
            if not outils:copyValidField(buffer magiPreference:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMagipreference private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCtype    as handle  no-undo.
    define variable vhCsoustype    as handle  no-undo.
    define variable vhCrefprincipale    as handle  no-undo.
    define variable vhCuser    as handle  no-undo.
    define variable vhJsessionid    as handle  no-undo.
    define buffer magiPreference for magiPreference.

    create query vhttquery.
    vhttBuffer = ghttMagipreference:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMagipreference:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCtype, output vhCsoustype, output vhCrefprincipale, output vhCuser, output vhJsessionid).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first magiPreference exclusive-lock
                where rowid(Magipreference) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer magiPreference:handle, 'cType/cSousType/cRefPrincipale/cUser/jSessionId: ', substitute('&1/&2/&3/&4/&5', vhCtype:buffer-value(), vhCsoustype:buffer-value(), vhCrefprincipale:buffer-value(), vhCuser:buffer-value(), vhJsessionid:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete magiPreference no-error.
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

