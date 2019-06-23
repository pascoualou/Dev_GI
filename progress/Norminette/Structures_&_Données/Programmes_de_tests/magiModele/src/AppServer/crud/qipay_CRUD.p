/*------------------------------------------------------------------------
File        : qipay_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table qipay
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/05 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttqipay as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpmdt as handle, output phNomdt as handle, output phNolot as handle, output phTpchg as handle, output phDtdeb as handle, output phTprol as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpmdt/nomdt/nolot/tpchg/dtdeb/tprol/norol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'tpchg' then phTpchg = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudQipay private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteQipay.
    run updateQipay.
    run createQipay.
end procedure.

procedure setQipay:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttQipay.
    ghttQipay = phttQipay.
    run crudQipay.
    delete object phttQipay.
end procedure.

procedure readQipay:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table qipay Nu-propriÃ©tÃ©/Usufruit : qui paye quoi?
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pcTpchg as character  no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter table-handle phttQipay.
    define variable vhttBuffer as handle no-undo.
    define buffer qipay for qipay.

    vhttBuffer = phttQipay:default-buffer-handle.
    for first qipay no-lock
        where qipay.tpmdt = pcTpmdt
          and qipay.nomdt = piNomdt
          and qipay.nolot = piNolot
          and qipay.tpchg = pcTpchg
          and qipay.dtdeb = pdaDtdeb
          and qipay.tprol = pcTprol
          and qipay.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer qipay:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttQipay no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getQipay:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table qipay Nu-propriÃ©tÃ©/Usufruit : qui paye quoi?
    Notes  : service externe. Critère pcTprol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pcTpchg as character  no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter table-handle phttQipay.
    define variable vhttBuffer as handle  no-undo.
    define buffer qipay for qipay.

    vhttBuffer = phttQipay:default-buffer-handle.
    if pcTprol = ?
    then for each qipay no-lock
        where qipay.tpmdt = pcTpmdt
          and qipay.nomdt = piNomdt
          and qipay.nolot = piNolot
          and qipay.tpchg = pcTpchg
          and qipay.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer qipay:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each qipay no-lock
        where qipay.tpmdt = pcTpmdt
          and qipay.nomdt = piNomdt
          and qipay.nolot = piNolot
          and qipay.tpchg = pcTpchg
          and qipay.dtdeb = pdaDtdeb
          and qipay.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer qipay:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttQipay no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateQipay private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhTpchg    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer qipay for qipay.

    create query vhttquery.
    vhttBuffer = ghttQipay:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttQipay:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhNolot, output vhTpchg, output vhDtdeb, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first qipay exclusive-lock
                where rowid(qipay) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer qipay:handle, 'tpmdt/nomdt/nolot/tpchg/dtdeb/tprol/norol: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNolot:buffer-value(), vhTpchg:buffer-value(), vhDtdeb:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer qipay:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createQipay private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer qipay for qipay.

    create query vhttquery.
    vhttBuffer = ghttQipay:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttQipay:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create qipay.
            if not outils:copyValidField(buffer qipay:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteQipay private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhTpchg    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer qipay for qipay.

    create query vhttquery.
    vhttBuffer = ghttQipay:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttQipay:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhNolot, output vhTpchg, output vhDtdeb, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first qipay exclusive-lock
                where rowid(Qipay) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer qipay:handle, 'tpmdt/nomdt/nolot/tpchg/dtdeb/tprol/norol: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNolot:buffer-value(), vhTpchg:buffer-value(), vhDtdeb:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete qipay no-error.
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

procedure deleteQipaySurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.

    define buffer qipay for qipay.

blocTrans:
    do transaction:
        for each qipay exclusive-lock 
            where qipay.tpmdt = pcTypeMandat
              and qipay.nomdt = piNumeroMandat:
            delete qipay no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
