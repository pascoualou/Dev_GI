/*------------------------------------------------------------------------
File        : parndf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table parndf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/parndf.i}
{application/include/error.i}
define variable ghttparndf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudParndf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteParndf.
    run updateParndf.
    run createParndf.
end procedure.

procedure setParndf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParndf.
    ghttParndf = phttParndf.
    run crudParndf.
    delete object phttParndf.
end procedure.

procedure readParndf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table parndf Parametrage des notes de frais
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttParndf.
    define variable vhttBuffer as handle no-undo.
    define buffer parndf for parndf.

    vhttBuffer = phttParndf:default-buffer-handle.
    for first parndf no-lock
        where parndf.soc-cd = piSoc-cd
          and parndf.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parndf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParndf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getParndf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table parndf Parametrage des notes de frais
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttParndf.
    define variable vhttBuffer as handle  no-undo.
    define buffer parndf for parndf.

    vhttBuffer = phttParndf:default-buffer-handle.
    if piSoc-cd = ?
    then for each parndf no-lock
        where parndf.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parndf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each parndf no-lock
        where parndf.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parndf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParndf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateParndf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer parndf for parndf.

    create query vhttquery.
    vhttBuffer = ghttParndf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttParndf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parndf exclusive-lock
                where rowid(parndf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parndf:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer parndf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createParndf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer parndf for parndf.

    create query vhttquery.
    vhttBuffer = ghttParndf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttParndf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create parndf.
            if not outils:copyValidField(buffer parndf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteParndf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer parndf for parndf.

    create query vhttquery.
    vhttBuffer = ghttParndf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttParndf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parndf exclusive-lock
                where rowid(Parndf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parndf:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete parndf no-error.
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

