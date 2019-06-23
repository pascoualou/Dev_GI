/*------------------------------------------------------------------------
File        : ibquope_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ibquope
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ibquope.i}
{application/include/error.i}
define variable ghttibquope as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phColl-cle as handle, output phCpt-cd as handle, output phType-cle as handle, output phLibope-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/coll-cle/cpt-cd/type-cle/libope-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'type-cle' then phType-cle = phBuffer:buffer-field(vi).
            when 'libope-cd' then phLibope-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIbquope private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIbquope.
    run updateIbquope.
    run createIbquope.
end procedure.

procedure setIbquope:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIbquope.
    ghttIbquope = phttIbquope.
    run crudIbquope.
    delete object phttIbquope.
end procedure.

procedure readIbquope:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ibquope Fichier codes operation par banque
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcColl-cle  as character  no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter pcLibope-cd as character  no-undo.
    define input parameter table-handle phttIbquope.
    define variable vhttBuffer as handle no-undo.
    define buffer ibquope for ibquope.

    vhttBuffer = phttIbquope:default-buffer-handle.
    for first ibquope no-lock
        where ibquope.soc-cd = piSoc-cd
          and ibquope.etab-cd = piEtab-cd
          and ibquope.coll-cle = pcColl-cle
          and ibquope.cpt-cd = pcCpt-cd
          and ibquope.type-cle = pcType-cle
          and ibquope.libope-cd = pcLibope-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibquope:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIbquope no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIbquope:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ibquope Fichier codes operation par banque
    Notes  : service externe. Critère pcType-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcColl-cle  as character  no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter table-handle phttIbquope.
    define variable vhttBuffer as handle  no-undo.
    define buffer ibquope for ibquope.

    vhttBuffer = phttIbquope:default-buffer-handle.
    if pcType-cle = ?
    then for each ibquope no-lock
        where ibquope.soc-cd = piSoc-cd
          and ibquope.etab-cd = piEtab-cd
          and ibquope.coll-cle = pcColl-cle
          and ibquope.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibquope:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ibquope no-lock
        where ibquope.soc-cd = piSoc-cd
          and ibquope.etab-cd = piEtab-cd
          and ibquope.coll-cle = pcColl-cle
          and ibquope.cpt-cd = pcCpt-cd
          and ibquope.type-cle = pcType-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibquope:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIbquope no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIbquope private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define variable vhLibope-cd    as handle  no-undo.
    define buffer ibquope for ibquope.

    create query vhttquery.
    vhttBuffer = ghttIbquope:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIbquope:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhColl-cle, output vhCpt-cd, output vhType-cle, output vhLibope-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ibquope exclusive-lock
                where rowid(ibquope) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ibquope:handle, 'soc-cd/etab-cd/coll-cle/cpt-cd/type-cle/libope-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value(), vhType-cle:buffer-value(), vhLibope-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ibquope:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIbquope private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ibquope for ibquope.

    create query vhttquery.
    vhttBuffer = ghttIbquope:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIbquope:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ibquope.
            if not outils:copyValidField(buffer ibquope:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIbquope private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define variable vhLibope-cd    as handle  no-undo.
    define buffer ibquope for ibquope.

    create query vhttquery.
    vhttBuffer = ghttIbquope:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIbquope:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhColl-cle, output vhCpt-cd, output vhType-cle, output vhLibope-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ibquope exclusive-lock
                where rowid(Ibquope) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ibquope:handle, 'soc-cd/etab-cd/coll-cle/cpt-cd/type-cle/libope-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value(), vhType-cle:buffer-value(), vhLibope-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ibquope no-error.
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

