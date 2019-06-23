/*------------------------------------------------------------------------
File        : ifdart_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdart
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdart.i}
{application/include/error.i}
define variable ghttifdart as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phArt-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/art-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'art-cle' then phArt-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdart.
    run updateIfdart.
    run createIfdart.
end procedure.

procedure setIfdart:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdart.
    ghttIfdart = phttIfdart.
    run crudIfdart.
    delete object phttIfdart.
end procedure.

procedure readIfdart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdart Table des articles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcArt-cle as character  no-undo.
    define input parameter table-handle phttIfdart.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdart for ifdart.

    vhttBuffer = phttIfdart:default-buffer-handle.
    for first ifdart no-lock
        where ifdart.soc-cd = piSoc-cd
          and ifdart.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdart no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdart Table des articles
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIfdart.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdart for ifdart.

    vhttBuffer = phttIfdart:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifdart no-lock
        where ifdart.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdart no-lock
        where ifdart.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdart no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define buffer ifdart for ifdart.

    create query vhttquery.
    vhttBuffer = ghttIfdart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhArt-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdart exclusive-lock
                where rowid(ifdart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdart:handle, 'soc-cd/art-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhArt-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdart:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdart for ifdart.

    create query vhttquery.
    vhttBuffer = ghttIfdart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdart:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdart.
            if not outils:copyValidField(buffer ifdart:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define buffer ifdart for ifdart.

    create query vhttquery.
    vhttBuffer = ghttIfdart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhArt-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdart exclusive-lock
                where rowid(Ifdart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdart:handle, 'soc-cd/art-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhArt-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdart no-error.
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

