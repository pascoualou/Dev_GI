/*------------------------------------------------------------------------
File        : cbudmodl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbudmodl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbudmodl.i}
{application/include/error.i}
define variable ghttcbudmodl as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phModele-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/modele-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'modele-cd' then phModele-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbudmodl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbudmodl.
    run updateCbudmodl.
    run createCbudmodl.
end procedure.

procedure setCbudmodl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbudmodl.
    ghttCbudmodl = phttCbudmodl.
    run crudCbudmodl.
    delete object phttCbudmodl.
end procedure.

procedure readCbudmodl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbudmodl 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcModele-cd as character  no-undo.
    define input parameter table-handle phttCbudmodl.
    define variable vhttBuffer as handle no-undo.
    define buffer cbudmodl for cbudmodl.

    vhttBuffer = phttCbudmodl:default-buffer-handle.
    for first cbudmodl no-lock
        where cbudmodl.soc-cd = piSoc-cd
          and cbudmodl.etab-cd = piEtab-cd
          and cbudmodl.modele-cd = pcModele-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbudmodl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbudmodl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbudmodl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbudmodl 
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter table-handle phttCbudmodl.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbudmodl for cbudmodl.

    vhttBuffer = phttCbudmodl:default-buffer-handle.
    if piEtab-cd = ?
    then for each cbudmodl no-lock
        where cbudmodl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbudmodl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbudmodl no-lock
        where cbudmodl.soc-cd = piSoc-cd
          and cbudmodl.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbudmodl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbudmodl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbudmodl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhModele-cd    as handle  no-undo.
    define buffer cbudmodl for cbudmodl.

    create query vhttquery.
    vhttBuffer = ghttCbudmodl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbudmodl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhModele-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbudmodl exclusive-lock
                where rowid(cbudmodl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbudmodl:handle, 'soc-cd/etab-cd/modele-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhModele-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbudmodl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbudmodl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbudmodl for cbudmodl.

    create query vhttquery.
    vhttBuffer = ghttCbudmodl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbudmodl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbudmodl.
            if not outils:copyValidField(buffer cbudmodl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbudmodl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhModele-cd    as handle  no-undo.
    define buffer cbudmodl for cbudmodl.

    create query vhttquery.
    vhttBuffer = ghttCbudmodl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbudmodl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhModele-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbudmodl exclusive-lock
                where rowid(Cbudmodl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbudmodl:handle, 'soc-cd/etab-cd/modele-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhModele-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbudmodl no-error.
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

