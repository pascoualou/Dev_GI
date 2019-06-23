/*------------------------------------------------------------------------
File        : ifdlnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdlnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdlnana.i}
{application/include/error.i}
define variable ghttifdlnana as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfdlnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdlnana.
    run updateIfdlnana.
    run createIfdlnana.
end procedure.

procedure setIfdlnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdlnana.
    ghttIfdlnana = phttIfdlnana.
    run crudIfdlnana.
    delete object phttIfdlnana.
end procedure.

procedure readIfdlnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdlnana Table des lignes analytiques des factures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter piPos     as integer    no-undo.
    define input parameter table-handle phttIfdlnana.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdlnana for ifdlnana.

    vhttBuffer = phttIfdlnana:default-buffer-handle.
    for first ifdlnana no-lock
        where ifdlnana.soc-cd = piSoc-cd
          and ifdlnana.etab-cd = piEtab-cd
          and ifdlnana.com-num = piCom-num
          and ifdlnana.lig-num = piLig-num
          and ifdlnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdlnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdlnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdlnana Table des lignes analytiques des factures
    Notes  : service externe. Critère piLig-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter table-handle phttIfdlnana.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdlnana for ifdlnana.

    vhttBuffer = phttIfdlnana:default-buffer-handle.
    if piLig-num = ?
    then for each ifdlnana no-lock
        where ifdlnana.soc-cd = piSoc-cd
          and ifdlnana.etab-cd = piEtab-cd
          and ifdlnana.com-num = piCom-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdlnana no-lock
        where ifdlnana.soc-cd = piSoc-cd
          and ifdlnana.etab-cd = piEtab-cd
          and ifdlnana.com-num = piCom-num
          and ifdlnana.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdlnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdlnana private:
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
    define buffer ifdlnana for ifdlnana.

    create query vhttquery.
    vhttBuffer = ghttIfdlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdlnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdlnana exclusive-lock
                where rowid(ifdlnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdlnana:handle, 'soc-cd/etab-cd/com-num/lig-num/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdlnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdlnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdlnana for ifdlnana.

    create query vhttquery.
    vhttBuffer = ghttIfdlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdlnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdlnana.
            if not outils:copyValidField(buffer ifdlnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdlnana private:
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
    define buffer ifdlnana for ifdlnana.

    create query vhttquery.
    vhttBuffer = ghttIfdlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdlnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdlnana exclusive-lock
                where rowid(Ifdlnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdlnana:handle, 'soc-cd/etab-cd/com-num/lig-num/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdlnana no-error.
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

