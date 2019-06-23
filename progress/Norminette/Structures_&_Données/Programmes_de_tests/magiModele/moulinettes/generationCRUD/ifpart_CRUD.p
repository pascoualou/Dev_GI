/*------------------------------------------------------------------------
File        : ifpart_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpart
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpart.i}
{application/include/error.i}
define variable ghttifpart as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfpart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpart.
    run updateIfpart.
    run createIfpart.
end procedure.

procedure setIfpart:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpart.
    ghttIfpart = phttIfpart.
    run crudIfpart.
    delete object phttIfpart.
end procedure.

procedure readIfpart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpart Table des articles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcArt-cle as character  no-undo.
    define input parameter table-handle phttIfpart.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpart for ifpart.

    vhttBuffer = phttIfpart:default-buffer-handle.
    for first ifpart no-lock
        where ifpart.soc-cd = piSoc-cd
          and ifpart.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpart no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpart Table des articles
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIfpart.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpart for ifpart.

    vhttBuffer = phttIfpart:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifpart no-lock
        where ifpart.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpart no-lock
        where ifpart.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpart no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define buffer ifpart for ifpart.

    create query vhttquery.
    vhttBuffer = ghttIfpart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhArt-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpart exclusive-lock
                where rowid(ifpart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpart:handle, 'soc-cd/art-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhArt-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpart:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpart for ifpart.

    create query vhttquery.
    vhttBuffer = ghttIfpart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpart:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpart.
            if not outils:copyValidField(buffer ifpart:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define buffer ifpart for ifpart.

    create query vhttquery.
    vhttBuffer = ghttIfpart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhArt-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpart exclusive-lock
                where rowid(Ifpart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpart:handle, 'soc-cd/art-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhArt-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpart no-error.
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

