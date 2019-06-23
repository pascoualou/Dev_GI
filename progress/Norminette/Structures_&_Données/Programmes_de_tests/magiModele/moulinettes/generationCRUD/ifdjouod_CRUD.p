/*------------------------------------------------------------------------
File        : ifdjouod_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdjouod
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdjouod.i}
{application/include/error.i}
define variable ghttifdjouod as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypefac-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typefac-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdjouod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdjouod.
    run updateIfdjouod.
    run createIfdjouod.
end procedure.

procedure setIfdjouod:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdjouod.
    ghttIfdjouod = phttIfdjouod.
    run crudIfdjouod.
    delete object phttIfdjouod.
end procedure.

procedure readIfdjouod:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdjouod 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter table-handle phttIfdjouod.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdjouod for ifdjouod.

    vhttBuffer = phttIfdjouod:default-buffer-handle.
    for first ifdjouod no-lock
        where ifdjouod.soc-cd = piSoc-cd
          and ifdjouod.etab-cd = piEtab-cd
          and ifdjouod.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdjouod:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdjouod no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdjouod:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdjouod 
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter table-handle phttIfdjouod.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdjouod for ifdjouod.

    vhttBuffer = phttIfdjouod:default-buffer-handle.
    if piEtab-cd = ?
    then for each ifdjouod no-lock
        where ifdjouod.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdjouod:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdjouod no-lock
        where ifdjouod.soc-cd = piSoc-cd
          and ifdjouod.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdjouod:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdjouod no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdjouod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define buffer ifdjouod for ifdjouod.

    create query vhttquery.
    vhttBuffer = ghttIfdjouod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdjouod:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdjouod exclusive-lock
                where rowid(ifdjouod) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdjouod:handle, 'soc-cd/etab-cd/typefac-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdjouod:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdjouod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdjouod for ifdjouod.

    create query vhttquery.
    vhttBuffer = ghttIfdjouod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdjouod:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdjouod.
            if not outils:copyValidField(buffer ifdjouod:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdjouod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define buffer ifdjouod for ifdjouod.

    create query vhttquery.
    vhttBuffer = ghttIfdjouod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdjouod:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdjouod exclusive-lock
                where rowid(Ifdjouod) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdjouod:handle, 'soc-cd/etab-cd/typefac-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdjouod no-error.
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

