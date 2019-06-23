/*------------------------------------------------------------------------
File        : iutilana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iutilana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iutilana.i}
{application/include/error.i}
define variable ghttiutilana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNiv-num as handle, output phAna-cd as handle, output phType as handle, output phIdent_u as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/niv-num/ana-cd/type/ident_u, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'niv-num' then phNiv-num = phBuffer:buffer-field(vi).
            when 'ana-cd' then phAna-cd = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
            when 'ident_u' then phIdent_u = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIutilana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIutilana.
    run updateIutilana.
    run createIutilana.
end procedure.

procedure setIutilana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIutilana.
    ghttIutilana = phttIutilana.
    run crudIutilana.
    delete object phttIutilana.
end procedure.

procedure readIutilana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iutilana 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter piType    as integer    no-undo.
    define input parameter pcIdent_u as character  no-undo.
    define input parameter table-handle phttIutilana.
    define variable vhttBuffer as handle no-undo.
    define buffer iutilana for iutilana.

    vhttBuffer = phttIutilana:default-buffer-handle.
    for first iutilana no-lock
        where iutilana.soc-cd = piSoc-cd
          and iutilana.etab-cd = piEtab-cd
          and iutilana.niv-num = piNiv-num
          and iutilana.ana-cd = pcAna-cd
          and iutilana.type = piType
          and iutilana.ident_u = pcIdent_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iutilana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIutilana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIutilana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iutilana 
    Notes  : service externe. Critère piType = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter piType    as integer    no-undo.
    define input parameter table-handle phttIutilana.
    define variable vhttBuffer as handle  no-undo.
    define buffer iutilana for iutilana.

    vhttBuffer = phttIutilana:default-buffer-handle.
    if piType = ?
    then for each iutilana no-lock
        where iutilana.soc-cd = piSoc-cd
          and iutilana.etab-cd = piEtab-cd
          and iutilana.niv-num = piNiv-num
          and iutilana.ana-cd = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iutilana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iutilana no-lock
        where iutilana.soc-cd = piSoc-cd
          and iutilana.etab-cd = piEtab-cd
          and iutilana.niv-num = piNiv-num
          and iutilana.ana-cd = pcAna-cd
          and iutilana.type = piType:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iutilana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIutilana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIutilana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhIdent_u    as handle  no-undo.
    define buffer iutilana for iutilana.

    create query vhttquery.
    vhttBuffer = ghttIutilana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIutilana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhType, output vhIdent_u).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iutilana exclusive-lock
                where rowid(iutilana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iutilana:handle, 'soc-cd/etab-cd/niv-num/ana-cd/type/ident_u: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhType:buffer-value(), vhIdent_u:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iutilana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIutilana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iutilana for iutilana.

    create query vhttquery.
    vhttBuffer = ghttIutilana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIutilana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iutilana.
            if not outils:copyValidField(buffer iutilana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIutilana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhIdent_u    as handle  no-undo.
    define buffer iutilana for iutilana.

    create query vhttquery.
    vhttBuffer = ghttIutilana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIutilana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhType, output vhIdent_u).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iutilana exclusive-lock
                where rowid(Iutilana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iutilana:handle, 'soc-cd/etab-cd/niv-num/ana-cd/type/ident_u: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhType:buffer-value(), vhIdent_u:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iutilana no-error.
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

