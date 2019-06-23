/*------------------------------------------------------------------------
File        : ibqjou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ibqjou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ibqjou.i}
{application/include/error.i}
define variable ghttibqjou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTpregl as handle, output phCdregl as handle, output phColl-cle as handle, output phType as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/tpregl/cdregl/coll-cle/type, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'tpregl' then phTpregl = phBuffer:buffer-field(vi).
            when 'cdregl' then phCdregl = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIbqjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIbqjou.
    run updateIbqjou.
    run createIbqjou.
end procedure.

procedure setIbqjou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIbqjou.
    ghttIbqjou = phttIbqjou.
    run crudIbqjou.
    delete object phttIbqjou.
end procedure.

procedure readIbqjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ibqjou Paramètres banque par défaut
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcTpregl   as character  no-undo.
    define input parameter pcCdregl   as character  no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter piType     as integer    no-undo.
    define input parameter table-handle phttIbqjou.
    define variable vhttBuffer as handle no-undo.
    define buffer ibqjou for ibqjou.

    vhttBuffer = phttIbqjou:default-buffer-handle.
    for first ibqjou no-lock
        where ibqjou.soc-cd = piSoc-cd
          and ibqjou.etab-cd = piEtab-cd
          and ibqjou.tpregl = pcTpregl
          and ibqjou.cdregl = pcCdregl
          and ibqjou.coll-cle = pcColl-cle
          and ibqjou.type = piType:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibqjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIbqjou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIbqjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ibqjou Paramètres banque par défaut
    Notes  : service externe. Critère pcColl-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcTpregl   as character  no-undo.
    define input parameter pcCdregl   as character  no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter table-handle phttIbqjou.
    define variable vhttBuffer as handle  no-undo.
    define buffer ibqjou for ibqjou.

    vhttBuffer = phttIbqjou:default-buffer-handle.
    if pcColl-cle = ?
    then for each ibqjou no-lock
        where ibqjou.soc-cd = piSoc-cd
          and ibqjou.etab-cd = piEtab-cd
          and ibqjou.tpregl = pcTpregl
          and ibqjou.cdregl = pcCdregl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibqjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ibqjou no-lock
        where ibqjou.soc-cd = piSoc-cd
          and ibqjou.etab-cd = piEtab-cd
          and ibqjou.tpregl = pcTpregl
          and ibqjou.cdregl = pcCdregl
          and ibqjou.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibqjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIbqjou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIbqjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTpregl    as handle  no-undo.
    define variable vhCdregl    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define buffer ibqjou for ibqjou.

    create query vhttquery.
    vhttBuffer = ghttIbqjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIbqjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTpregl, output vhCdregl, output vhColl-cle, output vhType).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ibqjou exclusive-lock
                where rowid(ibqjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ibqjou:handle, 'soc-cd/etab-cd/tpregl/cdregl/coll-cle/type: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTpregl:buffer-value(), vhCdregl:buffer-value(), vhColl-cle:buffer-value(), vhType:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ibqjou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIbqjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ibqjou for ibqjou.

    create query vhttquery.
    vhttBuffer = ghttIbqjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIbqjou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ibqjou.
            if not outils:copyValidField(buffer ibqjou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIbqjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTpregl    as handle  no-undo.
    define variable vhCdregl    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define buffer ibqjou for ibqjou.

    create query vhttquery.
    vhttBuffer = ghttIbqjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIbqjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTpregl, output vhCdregl, output vhColl-cle, output vhType).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ibqjou exclusive-lock
                where rowid(Ibqjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ibqjou:handle, 'soc-cd/etab-cd/tpregl/cdregl/coll-cle/type: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTpregl:buffer-value(), vhCdregl:buffer-value(), vhColl-cle:buffer-value(), vhType:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ibqjou no-error.
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

