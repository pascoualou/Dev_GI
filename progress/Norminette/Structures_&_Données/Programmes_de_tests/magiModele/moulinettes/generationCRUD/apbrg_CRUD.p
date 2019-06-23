/*------------------------------------------------------------------------
File        : apbrg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table apbrg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/apbrg.i}
{application/include/error.i}
define variable ghttapbrg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpbud as handle, output phNobud as handle, output phTparg as handle, output phNoarg as handle, output phTplig as handle, output phTpapp as handle, output phNoapp as handle, output phCdcle as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpbud/nobud/tparg/noarg/tplig/tpapp/noapp/cdcle/noord/noimm/nolot/nocop/noecr, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpbud' then phTpbud = phBuffer:buffer-field(vi).
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'tparg' then phTparg = phBuffer:buffer-field(vi).
            when 'noarg' then phNoarg = phBuffer:buffer-field(vi).
            when 'tplig' then phTplig = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApbrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApbrg.
    run updateApbrg.
    run createApbrg.
end procedure.

procedure setApbrg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApbrg.
    ghttApbrg = phttApbrg.
    run crudApbrg.
    delete object phttApbrg.
end procedure.

procedure readApbrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apbrg appel de fonds de régularisation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud as character  no-undo.
    define input parameter piNobud as int64      no-undo.
    define input parameter pcTparg as character  no-undo.
    define input parameter piNoarg as integer    no-undo.
    define input parameter pcTplig as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttApbrg.
    define variable vhttBuffer as handle no-undo.
    define buffer apbrg for apbrg.

    vhttBuffer = phttApbrg:default-buffer-handle.
    for first apbrg no-lock
        where apbrg.tpbud = pcTpbud
          and apbrg.nobud = piNobud
          and apbrg.tparg = pcTparg
          and apbrg.noarg = piNoarg
          and apbrg.tplig = pcTplig
          and apbrg.tpapp = pcTpapp
          and apbrg.noapp = piNoapp
          and apbrg.cdcle = pcCdcle
          and apbrg.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApbrg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApbrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apbrg appel de fonds de régularisation
    Notes  : service externe. Critère piNoord = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud as character  no-undo.
    define input parameter piNobud as int64      no-undo.
    define input parameter pcTparg as character  no-undo.
    define input parameter piNoarg as integer    no-undo.
    define input parameter pcTplig as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttApbrg.
    define variable vhttBuffer as handle  no-undo.
    define buffer apbrg for apbrg.

    vhttBuffer = phttApbrg:default-buffer-handle.
    if piNoord = ?
    then for each apbrg no-lock
        where apbrg.tpbud = pcTpbud
          and apbrg.nobud = piNobud
          and apbrg.tparg = pcTparg
          and apbrg.noarg = piNoarg
          and apbrg.tplig = pcTplig
          and apbrg.tpapp = pcTpapp
          and apbrg.noapp = piNoapp
          and apbrg.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apbrg no-lock
        where apbrg.tpbud = pcTpbud
          and apbrg.nobud = piNobud
          and apbrg.tparg = pcTparg
          and apbrg.noarg = piNoarg
          and apbrg.tplig = pcTplig
          and apbrg.tpapp = pcTpapp
          and apbrg.noapp = piNoapp
          and apbrg.cdcle = pcCdcle
          and apbrg.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApbrg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApbrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhTparg    as handle  no-undo.
    define variable vhNoarg    as handle  no-undo.
    define variable vhTplig    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer apbrg for apbrg.

    create query vhttquery.
    vhttBuffer = ghttApbrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApbrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNobud, output vhTparg, output vhNoarg, output vhTplig, output vhTpapp, output vhNoapp, output vhCdcle, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apbrg exclusive-lock
                where rowid(apbrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apbrg:handle, 'tpbud/nobud/tparg/noarg/tplig/tpapp/noapp/cdcle/noord/noimm/nolot/nocop/noecr: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpbud:buffer-value(), vhNobud:buffer-value(), vhTparg:buffer-value(), vhNoarg:buffer-value(), vhTplig:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhCdcle:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apbrg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApbrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apbrg for apbrg.

    create query vhttquery.
    vhttBuffer = ghttApbrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApbrg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apbrg.
            if not outils:copyValidField(buffer apbrg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApbrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhTparg    as handle  no-undo.
    define variable vhNoarg    as handle  no-undo.
    define variable vhTplig    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer apbrg for apbrg.

    create query vhttquery.
    vhttBuffer = ghttApbrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApbrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNobud, output vhTparg, output vhNoarg, output vhTplig, output vhTpapp, output vhNoapp, output vhCdcle, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apbrg exclusive-lock
                where rowid(Apbrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apbrg:handle, 'tpbud/nobud/tparg/noarg/tplig/tpapp/noapp/cdcle/noord/noimm/nolot/nocop/noecr: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpbud:buffer-value(), vhNobud:buffer-value(), vhTparg:buffer-value(), vhNoarg:buffer-value(), vhTplig:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhCdcle:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apbrg no-error.
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

