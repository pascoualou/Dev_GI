/*------------------------------------------------------------------------
File        : ifdln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdln.i}
{application/include/error.i}
define variable ghttifdln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCom-num as handle, output phLig-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/com-num/lig-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'com-num' then phCom-num = phBuffer:buffer-field(vi).
            when 'lig-num' then phLig-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdln.
    run updateIfdln.
    run createIfdln.
end procedure.

procedure setIfdln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdln.
    ghttIfdln = phttIfdln.
    run crudIfdln.
    delete object phttIfdln.
end procedure.

procedure readIfdln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdln Table des lignes de facturation diverse
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter table-handle phttIfdln.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdln for ifdln.

    vhttBuffer = phttIfdln:default-buffer-handle.
    for first ifdln no-lock
        where ifdln.soc-cd = piSoc-cd
          and ifdln.etab-cd = piEtab-cd
          and ifdln.com-num = piCom-num
          and ifdln.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdln Table des lignes de facturation diverse
    Notes  : service externe. Critère piCom-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piCom-num as integer    no-undo.
    define input parameter table-handle phttIfdln.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdln for ifdln.

    vhttBuffer = phttIfdln:default-buffer-handle.
    if piCom-num = ?
    then for each ifdln no-lock
        where ifdln.soc-cd = piSoc-cd
          and ifdln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdln no-lock
        where ifdln.soc-cd = piSoc-cd
          and ifdln.etab-cd = piEtab-cd
          and ifdln.com-num = piCom-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdln private:
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
    define buffer ifdln for ifdln.

    create query vhttquery.
    vhttBuffer = ghttIfdln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdln exclusive-lock
                where rowid(ifdln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdln:handle, 'soc-cd/etab-cd/com-num/lig-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdln for ifdln.

    create query vhttquery.
    vhttBuffer = ghttIfdln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdln.
            if not outils:copyValidField(buffer ifdln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdln private:
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
    define buffer ifdln for ifdln.

    create query vhttquery.
    vhttBuffer = ghttIfdln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCom-num, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdln exclusive-lock
                where rowid(Ifdln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdln:handle, 'soc-cd/etab-cd/com-num/lig-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCom-num:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdln no-error.
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

