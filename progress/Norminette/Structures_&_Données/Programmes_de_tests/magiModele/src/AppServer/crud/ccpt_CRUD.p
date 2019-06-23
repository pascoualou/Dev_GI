/*------------------------------------------------------------------------
File        : ccpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/05 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttccpt as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phColl-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/coll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'   then phSoc-cd   = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd'   then phCpt-cd   = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcpt.
    run updateCcpt.
    run createCcpt.
end procedure.

procedure setCcpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcpt.
    ghttCcpt = phttCcpt.
    run crudCcpt.
    delete object phttCcpt.
end procedure.

procedure readCcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccpt Fichiers comptes Generaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer   no-undo.
    define input parameter pcColl-cle as character no-undo.
    define input parameter pcCpt-cd   as character no-undo.
    define input parameter table-handle phttCcpt.

    define variable vhttBuffer as handle no-undo.
    define buffer ccpt for ccpt.

    vhttBuffer = phttCcpt:default-buffer-handle.
    for first ccpt no-lock
        where ccpt.soc-cd = piSoc-cd
          and ccpt.coll-cle = pcColl-cle
          and ccpt.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccpt Fichiers comptes Generaux
    Notes  : service externe. Critère pcColl-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer   no-undo.
    define input parameter pcColl-cle as character no-undo.
    define input parameter table-handle phttCcpt.

    define variable vhttBuffer as handle  no-undo.
    define buffer ccpt for ccpt.

    vhttBuffer = phttCcpt:default-buffer-handle.
    if pcColl-cle = ?
    then for each ccpt no-lock
        where ccpt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccpt no-lock
        where ccpt.soc-cd = piSoc-cd
          and ccpt.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhColl-cle as handle  no-undo.
    define variable vhCpt-cd   as handle  no-undo.
    define buffer ccpt for ccpt.

    create query vhttquery.
    vhttBuffer = ghttCcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccpt exclusive-lock
                where rowid(ccpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccpt:handle, 'soc-cd/coll-cle/cpt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccpt for ccpt.

    create query vhttquery.
    vhttBuffer = ghttCcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccpt.
            if not outils:copyValidField(buffer ccpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhColl-cle as handle  no-undo.
    define variable vhCpt-cd   as handle  no-undo.
    define buffer ccpt for ccpt.

    create query vhttquery.
    vhttBuffer = ghttCcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccpt exclusive-lock
                where rowid(Ccpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccpt:handle, 'soc-cd/coll-cle/cpt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccpt no-error.
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
