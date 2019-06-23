/*------------------------------------------------------------------------
File        : compenslot_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table compenslot
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/05 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}           // Doit être positionnée juste après using
define variable ghttcompenslot as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpctp as handle, output phNoctp as handle, output phTpct1 as handle, output phNoct1 as handle, output phTpct2 as handle, output phNoct2 as handle, output phNoimm as handle, output phNolot as handle, output phDtdeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpctp/noctp/tpct1/noct1/tpct2/noct2/noimm/nolot/dtdeb/tpidt/noidt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpctp' then phTpctp = phBuffer:buffer-field(vi).
            when 'noctp' then phNoctp = phBuffer:buffer-field(vi).
            when 'tpct1' then phTpct1 = phBuffer:buffer-field(vi).
            when 'noct1' then phNoct1 = phBuffer:buffer-field(vi).
            when 'tpct2' then phTpct2 = phBuffer:buffer-field(vi).
            when 'noct2' then phNoct2 = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCompenslot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCompenslot.
    run updateCompenslot.
    run createCompenslot.
end procedure.

procedure setCompenslot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCompenslot.
    ghttCompenslot = phttCompenslot.
    run crudCompenslot.
    delete object phttCompenslot.
end procedure.

procedure readCompenslot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table compenslot BNP 2014 : Compensations par lot
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctp as character  no-undo.
    define input parameter piNoctp as int64      no-undo.
    define input parameter pcTpct1 as character  no-undo.
    define input parameter piNoct1 as int64      no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter piNoct2 as int64      no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter table-handle phttCompenslot.
    define variable vhttBuffer as handle no-undo.
    define buffer compenslot for compenslot.

    vhttBuffer = phttCompenslot:default-buffer-handle.
    for first compenslot no-lock
        where compenslot.tpctp = pcTpctp
          and compenslot.noctp = piNoctp
          and compenslot.tpct1 = pcTpct1
          and compenslot.noct1 = piNoct1
          and compenslot.tpct2 = pcTpct2
          and compenslot.noct2 = piNoct2
          and compenslot.noimm = piNoimm
          and compenslot.nolot = piNolot
          and compenslot.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer compenslot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCompenslot no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCompenslot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table compenslot BNP 2014 : Compensations par lot
    Notes  : service externe. Critère pdaDtdeb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctp as character  no-undo.
    define input parameter piNoctp as int64      no-undo.
    define input parameter pcTpct1 as character  no-undo.
    define input parameter piNoct1 as int64      no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter piNoct2 as int64      no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter table-handle phttCompenslot.
    define variable vhttBuffer as handle  no-undo.
    define buffer compenslot for compenslot.

    vhttBuffer = phttCompenslot:default-buffer-handle.
    if pdaDtdeb = ?
    then for each compenslot no-lock
        where compenslot.tpctp = pcTpctp
          and compenslot.noctp = piNoctp
          and compenslot.tpct1 = pcTpct1
          and compenslot.noct1 = piNoct1
          and compenslot.tpct2 = pcTpct2
          and compenslot.noct2 = piNoct2
          and compenslot.noimm = piNoimm
          and compenslot.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer compenslot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each compenslot no-lock
        where compenslot.tpctp = pcTpctp
          and compenslot.noctp = piNoctp
          and compenslot.tpct1 = pcTpct1
          and compenslot.noct1 = piNoct1
          and compenslot.tpct2 = pcTpct2
          and compenslot.noct2 = piNoct2
          and compenslot.noimm = piNoimm
          and compenslot.nolot = piNolot
          and compenslot.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer compenslot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCompenslot no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCompenslot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpctp    as handle  no-undo.
    define variable vhNoctp    as handle  no-undo.
    define variable vhTpct1    as handle  no-undo.
    define variable vhNoct1    as handle  no-undo.
    define variable vhTpct2    as handle  no-undo.
    define variable vhNoct2    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer compenslot for compenslot.

    create query vhttquery.
    vhttBuffer = ghttCompenslot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCompenslot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctp, output vhNoctp, output vhTpct1, output vhNoct1, output vhTpct2, output vhNoct2, output vhNoimm, output vhNolot, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first compenslot exclusive-lock
                where rowid(compenslot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer compenslot:handle, 'tpctp/noctp/tpct1/noct1/tpct2/noct2/noimm/nolot/dtdeb/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpctp:buffer-value(), vhNoctp:buffer-value(), vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer compenslot:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCompenslot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer compenslot for compenslot.

    create query vhttquery.
    vhttBuffer = ghttCompenslot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCompenslot:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create compenslot.
            if not outils:copyValidField(buffer compenslot:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCompenslot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpctp    as handle  no-undo.
    define variable vhNoctp    as handle  no-undo.
    define variable vhTpct1    as handle  no-undo.
    define variable vhNoct1    as handle  no-undo.
    define variable vhTpct2    as handle  no-undo.
    define variable vhNoct2    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer compenslot for compenslot.

    create query vhttquery.
    vhttBuffer = ghttCompenslot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCompenslot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctp, output vhNoctp, output vhTpct1, output vhNoct1, output vhTpct2, output vhNoct2, output vhNoimm, output vhNolot, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first compenslot exclusive-lock
                where rowid(Compenslot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer compenslot:handle, 'tpctp/noctp/tpct1/noct1/tpct2/noct2/noimm/nolot/dtdeb/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpctp:buffer-value(), vhNoctp:buffer-value(), vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete compenslot no-error.
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

procedure deleteCompenslotSurContrat1:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat1   as character no-undo.
    define input parameter piNumeroContrat1 as int64     no-undo.
    
    define buffer compenslot for compenslot.

blocTrans:
    do transaction:
        for each compenslot exclusive-lock
            where compenslot.tpct1 = pcTypeContrat1
              and compenslot.noct1 = piNumeroContrat1:
            delete compenslot no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteCompenslotSurContrat2:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat2   as character no-undo.
    define input parameter piNumeroContrat2 as int64     no-undo.
    
    define buffer compenslot for compenslot.

blocTrans:
    do transaction:
        for each compenslot exclusive-lock
            where compenslot.tpct2 = pcTypeContrat2
              and compenslot.noct2 = piNumeroContrat2:
            delete compenslot no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
