/*------------------------------------------------------------------------
File        : iempl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iempl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/04 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghttiempl as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phColl-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/coll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'   then phSoc-cd = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd'   then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIempl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIempl.
    run updateIempl.
    run createIempl.
end procedure.

procedure setIempl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIempl.
    ghttIempl = phttIempl.
    run crudIempl.
    delete object phttIempl.
end procedure.

procedure readIempl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iempl Fichier employe
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer   no-undo.
    define input parameter pcColl-cle as character no-undo.
    define input parameter pcCpt-cd   as character no-undo.
    define input parameter table-handle phttIempl.

    define variable vhttBuffer as handle no-undo.
    define buffer iempl for iempl.

    vhttBuffer = phttIempl:default-buffer-handle.
    for first iempl no-lock
        where iempl.soc-cd = piSoc-cd
          and iempl.coll-cle = pcColl-cle
          and iempl.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iempl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIempl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIempl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iempl Fichier employe
    Notes  : service externe. Critère pcColl-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer   no-undo.
    define input parameter pcColl-cle as character no-undo.
    define input parameter table-handle phttIempl.

    define variable vhttBuffer as handle  no-undo.
    define buffer iempl for iempl.

    vhttBuffer = phttIempl:default-buffer-handle.
    if pcColl-cle = ?
    then for each iempl no-lock
        where iempl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iempl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iempl no-lock
        where iempl.soc-cd = piSoc-cd
          and iempl.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iempl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIempl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIempl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhColl-cle as handle  no-undo.
    define variable vhCpt-cd   as handle  no-undo.
    define buffer iempl for iempl.

    create query vhttquery.
    vhttBuffer = ghttIempl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIempl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iempl exclusive-lock
                where rowid(iempl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iempl:handle, 'soc-cd/coll-cle/cpt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iempl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIempl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iempl for iempl.

    create query vhttquery.
    vhttBuffer = ghttIempl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIempl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iempl.
            if not outils:copyValidField(buffer iempl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIempl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhColl-cle as handle  no-undo.
    define variable vhCpt-cd   as handle  no-undo.
    define buffer iempl for iempl.

    create query vhttquery.
    vhttBuffer = ghttIempl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIempl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iempl exclusive-lock
                where rowid(Iempl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iempl:handle, 'soc-cd/coll-cle/cpt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iempl no-error.
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
