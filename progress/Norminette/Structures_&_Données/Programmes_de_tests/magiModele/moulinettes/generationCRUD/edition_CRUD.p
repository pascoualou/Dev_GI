/*------------------------------------------------------------------------
File        : edition_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table edition
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/edition.i}
{application/include/error.i}
define variable ghttedition as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNoprog as handle, output phLig-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/noprog/lig-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'noprog' then phNoprog = phBuffer:buffer-field(vi).
            when 'lig-num' then phLig-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEdition private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEdition.
    run updateEdition.
    run createEdition.
end procedure.

procedure setEdition:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEdition.
    ghttEdition = phttEdition.
    run crudEdition.
    delete object phttEdition.
end procedure.

procedure readEdition:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table edition 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcNoprog  as character  no-undo.
    define input parameter piLig-num as integer    no-undo.
    define input parameter table-handle phttEdition.
    define variable vhttBuffer as handle no-undo.
    define buffer edition for edition.

    vhttBuffer = phttEdition:default-buffer-handle.
    for first edition no-lock
        where edition.soc-cd = piSoc-cd
          and edition.etab-cd = piEtab-cd
          and edition.noprog = pcNoprog
          and edition.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer edition:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEdition no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEdition:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table edition 
    Notes  : service externe. Critère pcNoprog = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcNoprog  as character  no-undo.
    define input parameter table-handle phttEdition.
    define variable vhttBuffer as handle  no-undo.
    define buffer edition for edition.

    vhttBuffer = phttEdition:default-buffer-handle.
    if pcNoprog = ?
    then for each edition no-lock
        where edition.soc-cd = piSoc-cd
          and edition.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer edition:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each edition no-lock
        where edition.soc-cd = piSoc-cd
          and edition.etab-cd = piEtab-cd
          and edition.noprog = pcNoprog:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer edition:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEdition no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEdition private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNoprog    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define buffer edition for edition.

    create query vhttquery.
    vhttBuffer = ghttEdition:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEdition:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNoprog, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first edition exclusive-lock
                where rowid(edition) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer edition:handle, 'soc-cd/etab-cd/noprog/lig-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNoprog:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer edition:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEdition private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer edition for edition.

    create query vhttquery.
    vhttBuffer = ghttEdition:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEdition:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create edition.
            if not outils:copyValidField(buffer edition:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEdition private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNoprog    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define buffer edition for edition.

    create query vhttquery.
    vhttBuffer = ghttEdition:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEdition:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNoprog, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first edition exclusive-lock
                where rowid(Edition) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer edition:handle, 'soc-cd/etab-cd/noprog/lig-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNoprog:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete edition no-error.
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

