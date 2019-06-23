/*------------------------------------------------------------------------
File        : ifpsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpsai.i}
{application/include/error.i}
define variable ghttifpsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCom-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/com-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'com-num' then phCom-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpsai.
    run updateIfpsai.
    run createIfpsai.
end procedure.

procedure setIfpsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpsai.
    ghttIfpsai = phttIfpsai.
    run crudIfpsai.
    delete object phttIfpsai.
end procedure.

procedure readIfpsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpsai Table des entetes de factures diverses
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter table-handle phttIfpsai.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpsai for ifpsai.

    vhttBuffer = phttIfpsai:default-buffer-handle.
    for first ifpsai no-lock
        where ifpsai.soc-cd = piSoc-cd
          and ifpsai.etab-cd = piEtab-cd
          and ifpsai.com-num = piCom-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpsai Table des entetes de factures diverses
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttIfpsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpsai for ifpsai.

    vhttBuffer = phttIfpsai:default-buffer-handle.
    if piEtab-cd = ?
    then for each ifpsai no-lock
        where ifpsai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpsai no-lock
        where ifpsai.soc-cd = piSoc-cd
          and ifpsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCom-num    as handle  no-undo.
    define buffer ifpsai for ifpsai.

    create query vhttquery.
    vhttBuffer = ghttIfpsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpsai exclusive-lock
                where rowid(ifpsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpsai:handle, 'soc-cd/etab-cd/com-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpsai for ifpsai.

    create query vhttquery.
    vhttBuffer = ghttIfpsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpsai.
            if not outils:copyValidField(buffer ifpsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCom-num    as handle  no-undo.
    define buffer ifpsai for ifpsai.

    create query vhttquery.
    vhttBuffer = ghttIfpsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpsai exclusive-lock
                where rowid(Ifpsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpsai:handle, 'soc-cd/etab-cd/com-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpsai no-error.
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

