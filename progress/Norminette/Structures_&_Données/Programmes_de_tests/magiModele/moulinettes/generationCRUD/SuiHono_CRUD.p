/*------------------------------------------------------------------------
File        : SuiHono_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SuiHono
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SuiHono.i}
{application/include/error.i}
define variable ghttSuiHono as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phTphon as handle, output phCdhon as handle, output phNoper as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/tphon/cdhon/noper, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'tphon' then phTphon = phBuffer:buffer-field(vi).
            when 'cdhon' then phCdhon = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSuihono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSuihono.
    run updateSuihono.
    run createSuihono.
end procedure.

procedure setSuihono:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSuihono.
    ghttSuihono = phttSuihono.
    run crudSuihono.
    delete object phttSuihono.
end procedure.

procedure readSuihono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SuiHono Suivi des honoraires (0513/0067)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTphon as character  no-undo.
    define input parameter piCdhon as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter table-handle phttSuihono.
    define variable vhttBuffer as handle no-undo.
    define buffer SuiHono for SuiHono.

    vhttBuffer = phttSuihono:default-buffer-handle.
    for first SuiHono no-lock
        where SuiHono.nomdt = piNomdt
          and SuiHono.tphon = pcTphon
          and SuiHono.cdhon = piCdhon
          and SuiHono.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiHono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuihono no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSuihono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SuiHono Suivi des honoraires (0513/0067)
    Notes  : service externe. Critère piCdhon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTphon as character  no-undo.
    define input parameter piCdhon as integer    no-undo.
    define input parameter table-handle phttSuihono.
    define variable vhttBuffer as handle  no-undo.
    define buffer SuiHono for SuiHono.

    vhttBuffer = phttSuihono:default-buffer-handle.
    if piCdhon = ?
    then for each SuiHono no-lock
        where SuiHono.nomdt = piNomdt
          and SuiHono.tphon = pcTphon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiHono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SuiHono no-lock
        where SuiHono.nomdt = piNomdt
          and SuiHono.tphon = pcTphon
          and SuiHono.cdhon = piCdhon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiHono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuihono no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSuihono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer SuiHono for SuiHono.

    create query vhttquery.
    vhttBuffer = ghttSuihono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSuihono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhTphon, output vhCdhon, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SuiHono exclusive-lock
                where rowid(SuiHono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SuiHono:handle, 'nomdt/tphon/cdhon/noper: ', substitute('&1/&2/&3/&4', vhNomdt:buffer-value(), vhTphon:buffer-value(), vhCdhon:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SuiHono:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSuihono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SuiHono for SuiHono.

    create query vhttquery.
    vhttBuffer = ghttSuihono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSuihono:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SuiHono.
            if not outils:copyValidField(buffer SuiHono:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSuihono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer SuiHono for SuiHono.

    create query vhttquery.
    vhttBuffer = ghttSuihono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSuihono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhTphon, output vhCdhon, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SuiHono exclusive-lock
                where rowid(Suihono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SuiHono:handle, 'nomdt/tphon/cdhon/noper: ', substitute('&1/&2/&3/&4', vhNomdt:buffer-value(), vhTphon:buffer-value(), vhCdhon:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SuiHono no-error.
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

