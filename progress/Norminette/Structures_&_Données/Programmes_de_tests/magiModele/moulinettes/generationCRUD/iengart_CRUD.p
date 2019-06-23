/*------------------------------------------------------------------------
File        : iengart_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iengart
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iengart.i}
{application/include/error.i}
define variable ghttiengart as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phArt-cle as handle, output phLib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/art-cle/lib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'art-cle' then phArt-cle = phBuffer:buffer-field(vi).
            when 'lib' then phLib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIengart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIengart.
    run updateIengart.
    run createIengart.
end procedure.

procedure setIengart:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIengart.
    ghttIengart = phttIengart.
    run crudIengart.
    delete object phttIengart.
end procedure.

procedure readIengart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iengart 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcArt-cle as character  no-undo.
    define input parameter pcLib     as character  no-undo.
    define input parameter table-handle phttIengart.
    define variable vhttBuffer as handle no-undo.
    define buffer iengart for iengart.

    vhttBuffer = phttIengart:default-buffer-handle.
    for first iengart no-lock
        where iengart.soc-cd = piSoc-cd
          and iengart.etab-cd = piEtab-cd
          and iengart.art-cle = pcArt-cle
          and iengart.lib = pcLib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengart no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIengart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iengart 
    Notes  : service externe. Critère pcArt-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcArt-cle as character  no-undo.
    define input parameter table-handle phttIengart.
    define variable vhttBuffer as handle  no-undo.
    define buffer iengart for iengart.

    vhttBuffer = phttIengart:default-buffer-handle.
    if pcArt-cle = ?
    then for each iengart no-lock
        where iengart.soc-cd = piSoc-cd
          and iengart.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iengart no-lock
        where iengart.soc-cd = piSoc-cd
          and iengart.etab-cd = piEtab-cd
          and iengart.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengart no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIengart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhLib    as handle  no-undo.
    define buffer iengart for iengart.

    create query vhttquery.
    vhttBuffer = ghttIengart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIengart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhArt-cle, output vhLib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengart exclusive-lock
                where rowid(iengart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengart:handle, 'soc-cd/etab-cd/art-cle/lib: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhArt-cle:buffer-value(), vhLib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iengart:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIengart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iengart for iengart.

    create query vhttquery.
    vhttBuffer = ghttIengart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIengart:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iengart.
            if not outils:copyValidField(buffer iengart:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIengart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhLib    as handle  no-undo.
    define buffer iengart for iengart.

    create query vhttquery.
    vhttBuffer = ghttIengart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIengart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhArt-cle, output vhLib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengart exclusive-lock
                where rowid(Iengart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengart:handle, 'soc-cd/etab-cd/art-cle/lib: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhArt-cle:buffer-value(), vhLib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iengart no-error.
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

