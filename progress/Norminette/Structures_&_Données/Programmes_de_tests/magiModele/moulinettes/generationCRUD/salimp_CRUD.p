/*------------------------------------------------------------------------
File        : salimp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table salimp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/salimp.i}
{application/include/error.i}
define variable ghttsalimp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phCdenr as handle, output phCdcle as handle, output phCdrub as handle, output phCdsru as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/cdenr/cdcle/cdrub/cdsru, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'cdenr' then phCdenr = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdsru' then phCdsru = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSalimp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSalimp.
    run updateSalimp.
    run createSalimp.
end procedure.

procedure setSalimp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSalimp.
    ghttSalimp = phttSalimp.
    run crudSalimp.
    delete object phttSalimp.
end procedure.

procedure readSalimp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table salimp Imputation comptable par salarié,clé, rub et sous-rub ana
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter pcCdenr as character  no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter piCdsru as integer    no-undo.
    define input parameter table-handle phttSalimp.
    define variable vhttBuffer as handle no-undo.
    define buffer salimp for salimp.

    vhttBuffer = phttSalimp:default-buffer-handle.
    for first salimp no-lock
        where salimp.tprol = pcTprol
          and salimp.norol = piNorol
          and salimp.cdenr = pcCdenr
          and salimp.cdcle = pcCdcle
          and salimp.cdrub = piCdrub
          and salimp.cdsru = piCdsru:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salimp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalimp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSalimp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table salimp Imputation comptable par salarié,clé, rub et sous-rub ana
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter pcCdenr as character  no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter table-handle phttSalimp.
    define variable vhttBuffer as handle  no-undo.
    define buffer salimp for salimp.

    vhttBuffer = phttSalimp:default-buffer-handle.
    if piCdrub = ?
    then for each salimp no-lock
        where salimp.tprol = pcTprol
          and salimp.norol = piNorol
          and salimp.cdenr = pcCdenr
          and salimp.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salimp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each salimp no-lock
        where salimp.tprol = pcTprol
          and salimp.norol = piNorol
          and salimp.cdenr = pcCdenr
          and salimp.cdcle = pcCdcle
          and salimp.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salimp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalimp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSalimp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhCdenr    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsru    as handle  no-undo.
    define buffer salimp for salimp.

    create query vhttquery.
    vhttBuffer = ghttSalimp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSalimp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhCdenr, output vhCdcle, output vhCdrub, output vhCdsru).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salimp exclusive-lock
                where rowid(salimp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salimp:handle, 'tprol/norol/cdenr/cdcle/cdrub/cdsru: ', substitute('&1/&2/&3/&4/&5/&6', vhTprol:buffer-value(), vhNorol:buffer-value(), vhCdenr:buffer-value(), vhCdcle:buffer-value(), vhCdrub:buffer-value(), vhCdsru:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer salimp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSalimp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer salimp for salimp.

    create query vhttquery.
    vhttBuffer = ghttSalimp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSalimp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create salimp.
            if not outils:copyValidField(buffer salimp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSalimp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhCdenr    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsru    as handle  no-undo.
    define buffer salimp for salimp.

    create query vhttquery.
    vhttBuffer = ghttSalimp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSalimp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhCdenr, output vhCdcle, output vhCdrub, output vhCdsru).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salimp exclusive-lock
                where rowid(Salimp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salimp:handle, 'tprol/norol/cdenr/cdcle/cdrub/cdsru: ', substitute('&1/&2/&3/&4/&5/&6', vhTprol:buffer-value(), vhNorol:buffer-value(), vhCdenr:buffer-value(), vhCdcle:buffer-value(), vhCdrub:buffer-value(), vhCdsru:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete salimp no-error.
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

