/*------------------------------------------------------------------------
File        : tbficct_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table tbficct
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/tbficct.i}
{application/include/error.i}
define variable ghtttbficct as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phLbfic as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/LbFic/tpcon/nocon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'LbFic' then phLbfic = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTbficct private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTbficct.
    run updateTbficct.
    run createTbficct.
end procedure.

procedure setTbficct:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTbficct.
    ghttTbficct = phttTbficct.
    run crudTbficct.
    delete object phttTbficct.
end procedure.

procedure readTbficct:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tbficct 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcLbfic as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttTbficct.
    define variable vhttBuffer as handle no-undo.
    define buffer tbficct for tbficct.

    vhttBuffer = phttTbficct:default-buffer-handle.
    for first tbficct no-lock
        where tbficct.tpidt = pcTpidt
          and tbficct.noidt = piNoidt
          and tbficct.LbFic = pcLbfic
          and tbficct.tpcon = pcTpcon
          and tbficct.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbficct:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbficct no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTbficct:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tbficct 
    Notes  : service externe. Crit�re pcTpcon = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcLbfic as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter table-handle phttTbficct.
    define variable vhttBuffer as handle  no-undo.
    define buffer tbficct for tbficct.

    vhttBuffer = phttTbficct:default-buffer-handle.
    if pcTpcon = ?
    then for each tbficct no-lock
        where tbficct.tpidt = pcTpidt
          and tbficct.noidt = piNoidt
          and tbficct.LbFic = pcLbfic:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbficct:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tbficct no-lock
        where tbficct.tpidt = pcTpidt
          and tbficct.noidt = piNoidt
          and tbficct.LbFic = pcLbfic
          and tbficct.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbficct:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbficct no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTbficct private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhLbfic    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer tbficct for tbficct.

    create query vhttquery.
    vhttBuffer = ghttTbficct:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTbficct:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhLbfic, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbficct exclusive-lock
                where rowid(tbficct) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbficct:handle, 'tpidt/noidt/LbFic/tpcon/nocon: ', substitute('&1/&2/&3/&4/&5', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhLbfic:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tbficct:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTbficct private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tbficct for tbficct.

    create query vhttquery.
    vhttBuffer = ghttTbficct:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTbficct:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tbficct.
            if not outils:copyValidField(buffer tbficct:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTbficct private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhLbfic    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer tbficct for tbficct.

    create query vhttquery.
    vhttBuffer = ghttTbficct:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTbficct:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhLbfic, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbficct exclusive-lock
                where rowid(Tbficct) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbficct:handle, 'tpidt/noidt/LbFic/tpcon/nocon: ', substitute('&1/&2/&3/&4/&5', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhLbfic:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tbficct no-error.
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

