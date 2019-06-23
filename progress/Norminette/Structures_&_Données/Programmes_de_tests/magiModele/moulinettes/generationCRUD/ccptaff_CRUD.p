/*------------------------------------------------------------------------
File        : ccptaff_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccptaff
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccptaff.i}
{application/include/error.i}
define variable ghttccptaff as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAffimp-cd as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/affimp-cd/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'affimp-cd' then phAffimp-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcptaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcptaff.
    run updateCcptaff.
    run createCcptaff.
end procedure.

procedure setCcptaff:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcptaff.
    ghttCcptaff = phttCcptaff.
    run crudCcptaff.
    delete object phttCcptaff.
end procedure.

procedure readCcptaff:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccptaff Imputation des affaires par compte
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piAffimp-cd as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter table-handle phttCcptaff.
    define variable vhttBuffer as handle no-undo.
    define buffer ccptaff for ccptaff.

    vhttBuffer = phttCcptaff:default-buffer-handle.
    for first ccptaff no-lock
        where ccptaff.soc-cd = piSoc-cd
          and ccptaff.etab-cd = piEtab-cd
          and ccptaff.affimp-cd = piAffimp-cd
          and ccptaff.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptaff:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptaff no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcptaff:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccptaff Imputation des affaires par compte
    Notes  : service externe. Critère piAffimp-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piAffimp-cd as integer    no-undo.
    define input parameter table-handle phttCcptaff.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccptaff for ccptaff.

    vhttBuffer = phttCcptaff:default-buffer-handle.
    if piAffimp-cd = ?
    then for each ccptaff no-lock
        where ccptaff.soc-cd = piSoc-cd
          and ccptaff.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptaff:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccptaff no-lock
        where ccptaff.soc-cd = piSoc-cd
          and ccptaff.etab-cd = piEtab-cd
          and ccptaff.affimp-cd = piAffimp-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptaff:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptaff no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcptaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAffimp-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer ccptaff for ccptaff.

    create query vhttquery.
    vhttBuffer = ghttCcptaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcptaff:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAffimp-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptaff exclusive-lock
                where rowid(ccptaff) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptaff:handle, 'soc-cd/etab-cd/affimp-cd/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAffimp-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccptaff:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcptaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccptaff for ccptaff.

    create query vhttquery.
    vhttBuffer = ghttCcptaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcptaff:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccptaff.
            if not outils:copyValidField(buffer ccptaff:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcptaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAffimp-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer ccptaff for ccptaff.

    create query vhttquery.
    vhttBuffer = ghttCcptaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcptaff:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAffimp-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptaff exclusive-lock
                where rowid(Ccptaff) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptaff:handle, 'soc-cd/etab-cd/affimp-cd/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAffimp-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccptaff no-error.
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

