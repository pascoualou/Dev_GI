/*------------------------------------------------------------------------
File        : ifplncom_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifplncom
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifplncom.i}
{application/include/error.i}
define variable ghttifplncom as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfplncom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfplncom.
    run updateIfplncom.
    run createIfplncom.
end procedure.

procedure setIfplncom:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfplncom.
    ghttIfplncom = phttIfplncom.
    run crudIfplncom.
    delete object phttIfplncom.
end procedure.

procedure readIfplncom:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifplncom Table des designations complementaires des factures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter piPos     as integer    no-undo.
    define input parameter table-handle phttIfplncom.
    define variable vhttBuffer as handle no-undo.
    define buffer ifplncom for ifplncom.

    vhttBuffer = phttIfplncom:default-buffer-handle.
    for first ifplncom no-lock
        where ifplncom.soc-cd = piSoc-cd
          and ifplncom.etab-cd = piEtab-cd
          and ifplncom.com-num = piCom-num
          and ifplncom.lig-num = piLig-num
          and ifplncom.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplncom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfplncom no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfplncom:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifplncom Table des designations complementaires des factures
    Notes  : service externe. Critère piLig-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter table-handle phttIfplncom.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifplncom for ifplncom.

    vhttBuffer = phttIfplncom:default-buffer-handle.
    if piLig-num = ?
    then for each ifplncom no-lock
        where ifplncom.soc-cd = piSoc-cd
          and ifplncom.etab-cd = piEtab-cd
          and ifplncom.com-num = piCom-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplncom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifplncom no-lock
        where ifplncom.soc-cd = piSoc-cd
          and ifplncom.etab-cd = piEtab-cd
          and ifplncom.com-num = piCom-num
          and ifplncom.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplncom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfplncom no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfplncom private:
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
    define buffer ifplncom for ifplncom.

    create query vhttquery.
    vhttBuffer = ghttIfplncom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfplncom:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifplncom exclusive-lock
                where rowid(ifplncom) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifplncom:handle, 'soc-cd/etab-cd/com-num/lig-num/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifplncom:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfplncom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifplncom for ifplncom.

    create query vhttquery.
    vhttBuffer = ghttIfplncom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfplncom:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifplncom.
            if not outils:copyValidField(buffer ifplncom:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfplncom private:
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
    define buffer ifplncom for ifplncom.

    create query vhttquery.
    vhttBuffer = ghttIfplncom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfplncom:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifplncom exclusive-lock
                where rowid(Ifplncom) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifplncom:handle, 'soc-cd/etab-cd/com-num/lig-num/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifplncom no-error.
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

