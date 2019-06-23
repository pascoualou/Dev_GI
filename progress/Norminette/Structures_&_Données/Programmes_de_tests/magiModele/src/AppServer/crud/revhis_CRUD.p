/*------------------------------------------------------------------------
File        : revhis_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table revhis
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}       // Doit �tre positionn�e juste apr�s using
define variable ghttrevhis as handle no-undo.     // le handle de la temp table � mettre � jour

function getIndexField returns logical private(phBuffer as handle, output phNohis as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nohis, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nohis' then phNohis = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRevhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRevhis.
    run updateRevhis.
    run createRevhis.
end procedure.

procedure setRevhis:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRevhis.
    ghttRevhis = phttRevhis.
    run crudRevhis.
    delete object phttRevhis.
end procedure.

procedure readRevhis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table revhis 0908/0110 - histo traitements r�visions 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNohis as integer  no-undo.
    define input parameter table-handle phttRevhis.

    define variable vhttBuffer as handle no-undo.
    define buffer revhis for revhis.

    vhttBuffer = phttRevhis:default-buffer-handle.
    for first revhis no-lock
        where revhis.nohis = piNohis:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revhis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRevhis no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRevhis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table revhis 0908/0110 - histo traitements r�visions 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRevhis.

    define variable vhttBuffer as handle  no-undo.
    define buffer revhis for revhis.

    vhttBuffer = phttRevhis:default-buffer-handle.
    for each revhis no-lock:                                      // fonctionnellement, aucun int�r�t.
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revhis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRevhis no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure getrevhisSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table revhis
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter pcCdtrt as character no-undo.
    define input parameter piNotrt as integer   no-undo.
    define input parameter table-handle phttrevhis.

    define variable vhttBuffer as handle  no-undo.
    define buffer revhis for revhis.

    vhttBuffer = phttrevhis:default-buffer-handle.
    if piNotrt = ? and pcCdtrt = ?
    then for each revhis no-lock
        where revhis.tpcon = pcTpcon
          and revhis.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revhis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else if piNotrt = ?
    then for each revhis no-lock
        where revhis.tpcon = pcTpcon
          and revhis.nocon = piNocon
          and revhis.cdtrt = pcCdtrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revhis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each revhis no-lock
        where revhis.tpcon = pcTpcon
          and revhis.nocon = piNocon
          and revhis.cdtrt = pcCdtrt
          and revhis.notrt = piNotrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revhis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttrevhis no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRevhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNohis    as handle  no-undo.
    define buffer revhis for revhis.

    create query vhttquery.
    vhttBuffer = ghttRevhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRevhis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohis).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first revhis exclusive-lock
                where rowid(revhis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer revhis:handle, 'nohis: ', substitute('&1', vhNohis:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer revhis:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRevhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer revhis for revhis.

    create query vhttquery.
    vhttBuffer = ghttRevhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRevhis:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create revhis.
            if not outils:copyValidField(buffer revhis:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRevhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNohis    as handle  no-undo.
    define buffer revhis for revhis.

    create query vhttquery.
    vhttBuffer = ghttRevhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRevhis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohis).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first revhis exclusive-lock
                where rowid(Revhis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer revhis:handle, 'nohis: ', substitute('&1', vhNohis:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete revhis no-error.
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

procedure deleteRevhisSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer revhis for revhis.

blocTrans:
    do transaction:
        for each revhis exclusive-lock   
            where revhis.tpcon = pcTypeContrat
              and revhis.nocon = piNumeroContrat:
            delete revhis no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
