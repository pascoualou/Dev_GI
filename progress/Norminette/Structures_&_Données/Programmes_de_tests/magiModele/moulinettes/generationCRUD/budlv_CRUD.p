/*------------------------------------------------------------------------
File        : budlv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table budlv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/budlv.i}
{application/include/error.i}
define variable ghttbudlv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpbud as handle, output phNomdt as handle, output phNobud as handle, output phNoavt as handle, output phCdrub as handle, output phCdsrb as handle, output phCdfisc as handle, output phCdcle as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpbud/nomdt/nobud/noavt/cdrub/cdsrb/cdfisc/cdcle/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpbud' then phTpbud = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'noavt' then phNoavt = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdsrb' then phCdsrb = phBuffer:buffer-field(vi).
            when 'cdfisc' then phCdfisc = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBudlv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBudlv.
    run updateBudlv.
    run createBudlv.
end procedure.

procedure setBudlv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBudlv.
    ghttBudlv = phttBudlv.
    run crudBudlv.
    delete object phttBudlv.
end procedure.

procedure readBudlv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table budlv Ventilation des dépenses locatives des Budgets Locatifs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud  as character  no-undo.
    define input parameter piNomdt  as integer    no-undo.
    define input parameter piNobud  as int64      no-undo.
    define input parameter piNoavt  as integer    no-undo.
    define input parameter piCdrub  as integer    no-undo.
    define input parameter piCdsrb  as integer    no-undo.
    define input parameter pcCdfisc as character  no-undo.
    define input parameter pcCdcle  as character  no-undo.
    define input parameter piNolot  as integer    no-undo.
    define input parameter table-handle phttBudlv.
    define variable vhttBuffer as handle no-undo.
    define buffer budlv for budlv.

    vhttBuffer = phttBudlv:default-buffer-handle.
    for first budlv no-lock
        where budlv.tpbud = pcTpbud
          and budlv.nomdt = piNomdt
          and budlv.nobud = piNobud
          and budlv.noavt = piNoavt
          and budlv.cdrub = piCdrub
          and budlv.cdsrb = piCdsrb
          and budlv.cdfisc = pcCdfisc
          and budlv.cdcle = pcCdcle
          and budlv.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budlv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBudlv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBudlv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table budlv Ventilation des dépenses locatives des Budgets Locatifs
    Notes  : service externe. Critère pcCdcle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud  as character  no-undo.
    define input parameter piNomdt  as integer    no-undo.
    define input parameter piNobud  as int64      no-undo.
    define input parameter piNoavt  as integer    no-undo.
    define input parameter piCdrub  as integer    no-undo.
    define input parameter piCdsrb  as integer    no-undo.
    define input parameter pcCdfisc as character  no-undo.
    define input parameter pcCdcle  as character  no-undo.
    define input parameter table-handle phttBudlv.
    define variable vhttBuffer as handle  no-undo.
    define buffer budlv for budlv.

    vhttBuffer = phttBudlv:default-buffer-handle.
    if pcCdcle = ?
    then for each budlv no-lock
        where budlv.tpbud = pcTpbud
          and budlv.nomdt = piNomdt
          and budlv.nobud = piNobud
          and budlv.noavt = piNoavt
          and budlv.cdrub = piCdrub
          and budlv.cdsrb = piCdsrb
          and budlv.cdfisc = pcCdfisc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budlv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each budlv no-lock
        where budlv.tpbud = pcTpbud
          and budlv.nomdt = piNomdt
          and budlv.nobud = piNobud
          and budlv.noavt = piNoavt
          and budlv.cdrub = piCdrub
          and budlv.cdsrb = piCdsrb
          and budlv.cdfisc = pcCdfisc
          and budlv.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budlv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBudlv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBudlv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhNoavt    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define variable vhCdfisc    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer budlv for budlv.

    create query vhttquery.
    vhttBuffer = ghttBudlv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBudlv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNomdt, output vhNobud, output vhNoavt, output vhCdrub, output vhCdsrb, output vhCdfisc, output vhCdcle, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first budlv exclusive-lock
                where rowid(budlv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer budlv:handle, 'tpbud/nomdt/nobud/noavt/cdrub/cdsrb/cdfisc/cdcle/nolot: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpbud:buffer-value(), vhNomdt:buffer-value(), vhNobud:buffer-value(), vhNoavt:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value(), vhCdfisc:buffer-value(), vhCdcle:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer budlv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBudlv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer budlv for budlv.

    create query vhttquery.
    vhttBuffer = ghttBudlv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBudlv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create budlv.
            if not outils:copyValidField(buffer budlv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBudlv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhNoavt    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define variable vhCdfisc    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer budlv for budlv.

    create query vhttquery.
    vhttBuffer = ghttBudlv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBudlv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNomdt, output vhNobud, output vhNoavt, output vhCdrub, output vhCdsrb, output vhCdfisc, output vhCdcle, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first budlv exclusive-lock
                where rowid(Budlv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer budlv:handle, 'tpbud/nomdt/nobud/noavt/cdrub/cdsrb/cdfisc/cdcle/nolot: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpbud:buffer-value(), vhNomdt:buffer-value(), vhNobud:buffer-value(), vhNoavt:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value(), vhCdfisc:buffer-value(), vhCdcle:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete budlv no-error.
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

