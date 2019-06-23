/*------------------------------------------------------------------------
File        : cantsru_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cantsru
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cantsru.i}
{application/include/error.i}
define variable ghttcantsru as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAnn-num as handle, output phDate-ant as handle, output phCode-lig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/ann-num/date-ant/code-lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ann-num' then phAnn-num = phBuffer:buffer-field(vi).
            when 'date-ant' then phDate-ant = phBuffer:buffer-field(vi).
            when 'code-lig' then phCode-lig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCantsru private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCantsru.
    run updateCantsru.
    run createCantsru.
end procedure.

procedure setCantsru:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCantsru.
    ghttCantsru = phttCantsru.
    run crudCantsru.
    delete object phttCantsru.
end procedure.

procedure readCantsru:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cantsru 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcAnn-num  as character  no-undo.
    define input parameter pdaDate-ant as date       no-undo.
    define input parameter pcCode-lig as character  no-undo.
    define input parameter table-handle phttCantsru.
    define variable vhttBuffer as handle no-undo.
    define buffer cantsru for cantsru.

    vhttBuffer = phttCantsru:default-buffer-handle.
    for first cantsru no-lock
        where cantsru.soc-cd = piSoc-cd
          and cantsru.etab-cd = piEtab-cd
          and cantsru.ann-num = pcAnn-num
          and cantsru.date-ant = pdaDate-ant
          and cantsru.code-lig = pcCode-lig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cantsru:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCantsru no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCantsru:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cantsru 
    Notes  : service externe. Critère pdaDate-ant = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcAnn-num  as character  no-undo.
    define input parameter pdaDate-ant as date       no-undo.
    define input parameter table-handle phttCantsru.
    define variable vhttBuffer as handle  no-undo.
    define buffer cantsru for cantsru.

    vhttBuffer = phttCantsru:default-buffer-handle.
    if pdaDate-ant = ?
    then for each cantsru no-lock
        where cantsru.soc-cd = piSoc-cd
          and cantsru.etab-cd = piEtab-cd
          and cantsru.ann-num = pcAnn-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cantsru:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cantsru no-lock
        where cantsru.soc-cd = piSoc-cd
          and cantsru.etab-cd = piEtab-cd
          and cantsru.ann-num = pcAnn-num
          and cantsru.date-ant = pdaDate-ant:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cantsru:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCantsru no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCantsru private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAnn-num    as handle  no-undo.
    define variable vhDate-ant    as handle  no-undo.
    define variable vhCode-lig    as handle  no-undo.
    define buffer cantsru for cantsru.

    create query vhttquery.
    vhttBuffer = ghttCantsru:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCantsru:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAnn-num, output vhDate-ant, output vhCode-lig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cantsru exclusive-lock
                where rowid(cantsru) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cantsru:handle, 'soc-cd/etab-cd/ann-num/date-ant/code-lig: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAnn-num:buffer-value(), vhDate-ant:buffer-value(), vhCode-lig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cantsru:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCantsru private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cantsru for cantsru.

    create query vhttquery.
    vhttBuffer = ghttCantsru:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCantsru:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cantsru.
            if not outils:copyValidField(buffer cantsru:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCantsru private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAnn-num    as handle  no-undo.
    define variable vhDate-ant    as handle  no-undo.
    define variable vhCode-lig    as handle  no-undo.
    define buffer cantsru for cantsru.

    create query vhttquery.
    vhttBuffer = ghttCantsru:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCantsru:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAnn-num, output vhDate-ant, output vhCode-lig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cantsru exclusive-lock
                where rowid(Cantsru) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cantsru:handle, 'soc-cd/etab-cd/ann-num/date-ant/code-lig: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAnn-num:buffer-value(), vhDate-ant:buffer-value(), vhCode-lig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cantsru no-error.
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

