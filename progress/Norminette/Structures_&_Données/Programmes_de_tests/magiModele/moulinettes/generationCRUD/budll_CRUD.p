/*------------------------------------------------------------------------
File        : budll_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table budll
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/budll.i}
{application/include/error.i}
define variable ghttbudll as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpbud as handle, output phNomdt as handle, output phNobud as handle, output phNoavt as handle, output phTprub as handle, output phCdrub as handle, output phCdsrb as handle, output phCdfisc as handle, output phCdcle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpbud/nomdt/nobud/noavt/tprub/cdrub/cdsrb/cdfisc/cdcle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpbud' then phTpbud = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'noavt' then phNoavt = phBuffer:buffer-field(vi).
            when 'tprub' then phTprub = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdsrb' then phCdsrb = phBuffer:buffer-field(vi).
            when 'cdfisc' then phCdfisc = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBudll private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBudll.
    run updateBudll.
    run createBudll.
end procedure.

procedure setBudll:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBudll.
    ghttBudll = phttBudll.
    run crudBudll.
    delete object phttBudll.
end procedure.

procedure readBudll:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table budll 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud  as character  no-undo.
    define input parameter piNomdt  as integer    no-undo.
    define input parameter piNobud  as int64      no-undo.
    define input parameter piNoavt  as integer    no-undo.
    define input parameter pcTprub  as character  no-undo.
    define input parameter piCdrub  as integer    no-undo.
    define input parameter piCdsrb  as integer    no-undo.
    define input parameter pcCdfisc as character  no-undo.
    define input parameter pcCdcle  as character  no-undo.
    define input parameter table-handle phttBudll.
    define variable vhttBuffer as handle no-undo.
    define buffer budll for budll.

    vhttBuffer = phttBudll:default-buffer-handle.
    for first budll no-lock
        where budll.tpbud = pcTpbud
          and budll.nomdt = piNomdt
          and budll.nobud = piNobud
          and budll.noavt = piNoavt
          and budll.tprub = pcTprub
          and budll.cdrub = piCdrub
          and budll.cdsrb = piCdsrb
          and budll.cdfisc = pcCdfisc
          and budll.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budll:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBudll no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBudll:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table budll 
    Notes  : service externe. Critère pcCdfisc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud  as character  no-undo.
    define input parameter piNomdt  as integer    no-undo.
    define input parameter piNobud  as int64      no-undo.
    define input parameter piNoavt  as integer    no-undo.
    define input parameter pcTprub  as character  no-undo.
    define input parameter piCdrub  as integer    no-undo.
    define input parameter piCdsrb  as integer    no-undo.
    define input parameter pcCdfisc as character  no-undo.
    define input parameter table-handle phttBudll.
    define variable vhttBuffer as handle  no-undo.
    define buffer budll for budll.

    vhttBuffer = phttBudll:default-buffer-handle.
    if pcCdfisc = ?
    then for each budll no-lock
        where budll.tpbud = pcTpbud
          and budll.nomdt = piNomdt
          and budll.nobud = piNobud
          and budll.noavt = piNoavt
          and budll.tprub = pcTprub
          and budll.cdrub = piCdrub
          and budll.cdsrb = piCdsrb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budll:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each budll no-lock
        where budll.tpbud = pcTpbud
          and budll.nomdt = piNomdt
          and budll.nobud = piNobud
          and budll.noavt = piNoavt
          and budll.tprub = pcTprub
          and budll.cdrub = piCdrub
          and budll.cdsrb = piCdsrb
          and budll.cdfisc = pcCdfisc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budll:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBudll no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBudll private:
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
    define variable vhTprub    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define variable vhCdfisc    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define buffer budll for budll.

    create query vhttquery.
    vhttBuffer = ghttBudll:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBudll:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNomdt, output vhNobud, output vhNoavt, output vhTprub, output vhCdrub, output vhCdsrb, output vhCdfisc, output vhCdcle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first budll exclusive-lock
                where rowid(budll) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer budll:handle, 'tpbud/nomdt/nobud/noavt/tprub/cdrub/cdsrb/cdfisc/cdcle: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpbud:buffer-value(), vhNomdt:buffer-value(), vhNobud:buffer-value(), vhNoavt:buffer-value(), vhTprub:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value(), vhCdfisc:buffer-value(), vhCdcle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer budll:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBudll private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer budll for budll.

    create query vhttquery.
    vhttBuffer = ghttBudll:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBudll:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create budll.
            if not outils:copyValidField(buffer budll:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBudll private:
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
    define variable vhTprub    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define variable vhCdfisc    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define buffer budll for budll.

    create query vhttquery.
    vhttBuffer = ghttBudll:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBudll:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNomdt, output vhNobud, output vhNoavt, output vhTprub, output vhCdrub, output vhCdsrb, output vhCdfisc, output vhCdcle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first budll exclusive-lock
                where rowid(Budll) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer budll:handle, 'tpbud/nomdt/nobud/noavt/tprub/cdrub/cdsrb/cdfisc/cdcle: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpbud:buffer-value(), vhNomdt:buffer-value(), vhNobud:buffer-value(), vhNoavt:buffer-value(), vhTprub:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value(), vhCdfisc:buffer-value(), vhCdcle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete budll no-error.
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

