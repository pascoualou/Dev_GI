/*------------------------------------------------------------------------
File        : ifdlncom_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdlncom
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdlncom.i}
{application/include/error.i}
define variable ghttifdlncom as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfdlncom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdlncom.
    run updateIfdlncom.
    run createIfdlncom.
end procedure.

procedure setIfdlncom:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdlncom.
    ghttIfdlncom = phttIfdlncom.
    run crudIfdlncom.
    delete object phttIfdlncom.
end procedure.

procedure readIfdlncom:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdlncom Table des designations complementaires des factures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter piPos     as integer    no-undo.
    define input parameter table-handle phttIfdlncom.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdlncom for ifdlncom.

    vhttBuffer = phttIfdlncom:default-buffer-handle.
    for first ifdlncom no-lock
        where ifdlncom.soc-cd = piSoc-cd
          and ifdlncom.etab-cd = piEtab-cd
          and ifdlncom.com-num = piCom-num
          and ifdlncom.lig-num = piLig-num
          and ifdlncom.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdlncom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdlncom no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdlncom:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdlncom Table des designations complementaires des factures
    Notes  : service externe. Critère piLig-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter table-handle phttIfdlncom.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdlncom for ifdlncom.

    vhttBuffer = phttIfdlncom:default-buffer-handle.
    if piLig-num = ?
    then for each ifdlncom no-lock
        where ifdlncom.soc-cd = piSoc-cd
          and ifdlncom.etab-cd = piEtab-cd
          and ifdlncom.com-num = piCom-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdlncom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdlncom no-lock
        where ifdlncom.soc-cd = piSoc-cd
          and ifdlncom.etab-cd = piEtab-cd
          and ifdlncom.com-num = piCom-num
          and ifdlncom.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdlncom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdlncom no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdlncom private:
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
    define buffer ifdlncom for ifdlncom.

    create query vhttquery.
    vhttBuffer = ghttIfdlncom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdlncom:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdlncom exclusive-lock
                where rowid(ifdlncom) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdlncom:handle, 'soc-cd/etab-cd/com-num/lig-num/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdlncom:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdlncom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdlncom for ifdlncom.

    create query vhttquery.
    vhttBuffer = ghttIfdlncom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdlncom:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdlncom.
            if not outils:copyValidField(buffer ifdlncom:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdlncom private:
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
    define buffer ifdlncom for ifdlncom.

    create query vhttquery.
    vhttBuffer = ghttIfdlncom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdlncom:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdlncom exclusive-lock
                where rowid(Ifdlncom) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdlncom:handle, 'soc-cd/etab-cd/com-num/lig-num/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdlncom no-error.
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

