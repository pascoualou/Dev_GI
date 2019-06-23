/*------------------------------------------------------------------------
File        : ifplnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifplnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifplnana.i}
{application/include/error.i}
define variable ghttifplnana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCom-num as handle, output phLig-num as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/com-num/lig-num/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'com-num' then phCom-num = phBuffer:buffer-field(vi).
            when 'lig-num' then phLig-num = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfplnana.
    run updateIfplnana.
    run createIfplnana.
end procedure.

procedure setIfplnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfplnana.
    ghttIfplnana = phttIfplnana.
    run crudIfplnana.
    delete object phttIfplnana.
end procedure.

procedure readIfplnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifplnana Table des lignes analytiques des factures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter piPos     as integer    no-undo.
    define input parameter table-handle phttIfplnana.
    define variable vhttBuffer as handle no-undo.
    define buffer ifplnana for ifplnana.

    vhttBuffer = phttIfplnana:default-buffer-handle.
    for first ifplnana no-lock
        where ifplnana.soc-cd = piSoc-cd
          and ifplnana.etab-cd = piEtab-cd
          and ifplnana.com-num = piCom-num
          and ifplnana.lig-num = piLig-num
          and ifplnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfplnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfplnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifplnana Table des lignes analytiques des factures
    Notes  : service externe. Critère piLig-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter table-handle phttIfplnana.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifplnana for ifplnana.

    vhttBuffer = phttIfplnana:default-buffer-handle.
    if piLig-num = ?
    then for each ifplnana no-lock
        where ifplnana.soc-cd = piSoc-cd
          and ifplnana.etab-cd = piEtab-cd
          and ifplnana.com-num = piCom-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifplnana no-lock
        where ifplnana.soc-cd = piSoc-cd
          and ifplnana.etab-cd = piEtab-cd
          and ifplnana.com-num = piCom-num
          and ifplnana.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfplnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCom-num    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifplnana for ifplnana.

    create query vhttquery.
    vhttBuffer = ghttIfplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfplnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifplnana exclusive-lock
                where rowid(ifplnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifplnana:handle, 'soc-cd/etab-cd/com-num/lig-num/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifplnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifplnana for ifplnana.

    create query vhttquery.
    vhttBuffer = ghttIfplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfplnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifplnana.
            if not outils:copyValidField(buffer ifplnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCom-num    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifplnana for ifplnana.

    create query vhttquery.
    vhttBuffer = ghttIfplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfplnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifplnana exclusive-lock
                where rowid(Ifplnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifplnana:handle, 'soc-cd/etab-cd/com-num/lig-num/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifplnana no-error.
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

