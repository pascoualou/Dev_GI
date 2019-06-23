/*------------------------------------------------------------------------
File        : ccptdat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccptdat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccptdat.i}
{application/include/error.i}
define variable ghttccptdat as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phColl-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/coll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcptdat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcptdat.
    run updateCcptdat.
    run createCcptdat.
end procedure.

procedure setCcptdat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcptdat.
    ghttCcptdat = phttCcptdat.
    run crudCcptdat.
    delete object phttCcptdat.
end procedure.

procedure readCcptdat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccptdat 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter pcCpt-cd   as character  no-undo.
    define input parameter table-handle phttCcptdat.
    define variable vhttBuffer as handle no-undo.
    define buffer ccptdat for ccptdat.

    vhttBuffer = phttCcptdat:default-buffer-handle.
    for first ccptdat no-lock
        where ccptdat.soc-cd = piSoc-cd
          and ccptdat.etab-cd = piEtab-cd
          and ccptdat.coll-cle = pcColl-cle
          and ccptdat.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptdat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptdat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcptdat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccptdat 
    Notes  : service externe. Critère pcColl-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter table-handle phttCcptdat.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccptdat for ccptdat.

    vhttBuffer = phttCcptdat:default-buffer-handle.
    if pcColl-cle = ?
    then for each ccptdat no-lock
        where ccptdat.soc-cd = piSoc-cd
          and ccptdat.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptdat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccptdat no-lock
        where ccptdat.soc-cd = piSoc-cd
          and ccptdat.etab-cd = piEtab-cd
          and ccptdat.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptdat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptdat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcptdat private:
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
    define buffer ccptdat for ccptdat.

    create query vhttquery.
    vhttBuffer = ghttCcptdat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcptdat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptdat exclusive-lock
                where rowid(ccptdat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptdat:handle, 'soc-cd/etab-cd/coll-cle/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccptdat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcptdat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccptdat for ccptdat.

    create query vhttquery.
    vhttBuffer = ghttCcptdat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcptdat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccptdat.
            if not outils:copyValidField(buffer ccptdat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcptdat private:
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
    define buffer ccptdat for ccptdat.

    create query vhttquery.
    vhttBuffer = ghttCcptdat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcptdat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptdat exclusive-lock
                where rowid(Ccptdat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptdat:handle, 'soc-cd/etab-cd/coll-cle/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccptdat no-error.
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

