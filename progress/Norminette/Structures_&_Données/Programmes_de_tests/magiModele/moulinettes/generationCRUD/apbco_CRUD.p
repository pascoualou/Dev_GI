/*------------------------------------------------------------------------
File        : apbco_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table apbco
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/apbco.i}
{application/include/error.i}
define variable ghttapbco as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpbud as handle, output phNobud as handle, output phTpapp as handle, output phNoapp as handle, output phTypapptrx as handle, output phNoimm as handle, output phNolot as handle, output phCdcle as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpbud/nobud/tpapp/noapp/typapptrx/noimm/nolot/cdcle/noord/nocop, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpbud' then phTpbud = phBuffer:buffer-field(vi).
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'typapptrx' then phTypapptrx = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApbco private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApbco.
    run updateApbco.
    run createApbco.
end procedure.

procedure setApbco:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApbco.
    ghttApbco = phttApbco.
    run crudApbco.
    delete object phttApbco.
end procedure.

procedure readApbco:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apbco répartition d'un appel de fonds par copropriétaire/clé/lot
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud     as character  no-undo.
    define input parameter piNobud     as int64      no-undo.
    define input parameter pcTpapp     as character  no-undo.
    define input parameter piNoapp     as integer    no-undo.
    define input parameter pcTypapptrx as character  no-undo.
    define input parameter piNoimm     as integer    no-undo.
    define input parameter piNolot     as integer    no-undo.
    define input parameter pcCdcle     as character  no-undo.
    define input parameter piNoord     as integer    no-undo.
    define input parameter table-handle phttApbco.
    define variable vhttBuffer as handle no-undo.
    define buffer apbco for apbco.

    vhttBuffer = phttApbco:default-buffer-handle.
    for first apbco no-lock
        where apbco.tpbud = pcTpbud
          and apbco.nobud = piNobud
          and apbco.tpapp = pcTpapp
          and apbco.noapp = piNoapp
          and apbco.typapptrx = pcTypapptrx
          and apbco.noimm = piNoimm
          and apbco.nolot = piNolot
          and apbco.cdcle = pcCdcle
          and apbco.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbco:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApbco no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApbco:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apbco répartition d'un appel de fonds par copropriétaire/clé/lot
    Notes  : service externe. Critère piNoord = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud     as character  no-undo.
    define input parameter piNobud     as int64      no-undo.
    define input parameter pcTpapp     as character  no-undo.
    define input parameter piNoapp     as integer    no-undo.
    define input parameter pcTypapptrx as character  no-undo.
    define input parameter piNoimm     as integer    no-undo.
    define input parameter piNolot     as integer    no-undo.
    define input parameter pcCdcle     as character  no-undo.
    define input parameter piNoord     as integer    no-undo.
    define input parameter table-handle phttApbco.
    define variable vhttBuffer as handle  no-undo.
    define buffer apbco for apbco.

    vhttBuffer = phttApbco:default-buffer-handle.
    if piNoord = ?
    then for each apbco no-lock
        where apbco.tpbud = pcTpbud
          and apbco.nobud = piNobud
          and apbco.tpapp = pcTpapp
          and apbco.noapp = piNoapp
          and apbco.typapptrx = pcTypapptrx
          and apbco.noimm = piNoimm
          and apbco.nolot = piNolot
          and apbco.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbco:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apbco no-lock
        where apbco.tpbud = pcTpbud
          and apbco.nobud = piNobud
          and apbco.tpapp = pcTpapp
          and apbco.noapp = piNoapp
          and apbco.typapptrx = pcTypapptrx
          and apbco.noimm = piNoimm
          and apbco.nolot = piNolot
          and apbco.cdcle = pcCdcle
          and apbco.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbco:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApbco no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApbco private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhTypapptrx    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer apbco for apbco.

    create query vhttquery.
    vhttBuffer = ghttApbco:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApbco:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNobud, output vhTpapp, output vhNoapp, output vhTypapptrx, output vhNoimm, output vhNolot, output vhCdcle, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apbco exclusive-lock
                where rowid(apbco) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apbco:handle, 'tpbud/nobud/tpapp/noapp/typapptrx/noimm/nolot/cdcle/noord/nocop: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpbud:buffer-value(), vhNobud:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhTypapptrx:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value(), vhCdcle:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apbco:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApbco private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apbco for apbco.

    create query vhttquery.
    vhttBuffer = ghttApbco:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApbco:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apbco.
            if not outils:copyValidField(buffer apbco:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApbco private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhTypapptrx    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer apbco for apbco.

    create query vhttquery.
    vhttBuffer = ghttApbco:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApbco:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNobud, output vhTpapp, output vhNoapp, output vhTypapptrx, output vhNoimm, output vhNolot, output vhCdcle, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apbco exclusive-lock
                where rowid(Apbco) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apbco:handle, 'tpbud/nobud/tpapp/noapp/typapptrx/noimm/nolot/cdcle/noord/nocop: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpbud:buffer-value(), vhNobud:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhTypapptrx:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value(), vhCdcle:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apbco no-error.
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

