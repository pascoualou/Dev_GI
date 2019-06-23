/*------------------------------------------------------------------------
File        : crepbiln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crepbiln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crepbiln.i}
{application/include/error.i}
define variable ghttcrepbiln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRub-cd as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/rub-cd/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrepbiln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrepbiln.
    run updateCrepbiln.
    run createCrepbiln.
end procedure.

procedure setCrepbiln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrepbiln.
    ghttCrepbiln = phttCrepbiln.
    run crudCrepbiln.
    delete object phttCrepbiln.
end procedure.

procedure readCrepbiln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crepbiln ligne de code reporting bilan
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piRub-cd  as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter table-handle phttCrepbiln.
    define variable vhttBuffer as handle no-undo.
    define buffer crepbiln for crepbiln.

    vhttBuffer = phttCrepbiln:default-buffer-handle.
    for first crepbiln no-lock
        where crepbiln.soc-cd = piSoc-cd
          and crepbiln.etab-cd = piEtab-cd
          and crepbiln.rub-cd = piRub-cd
          and crepbiln.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepbiln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrepbiln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrepbiln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crepbiln ligne de code reporting bilan
    Notes  : service externe. Critère piRub-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piRub-cd  as integer    no-undo.
    define input parameter table-handle phttCrepbiln.
    define variable vhttBuffer as handle  no-undo.
    define buffer crepbiln for crepbiln.

    vhttBuffer = phttCrepbiln:default-buffer-handle.
    if piRub-cd = ?
    then for each crepbiln no-lock
        where crepbiln.soc-cd = piSoc-cd
          and crepbiln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepbiln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crepbiln no-lock
        where crepbiln.soc-cd = piSoc-cd
          and crepbiln.etab-cd = piEtab-cd
          and crepbiln.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepbiln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrepbiln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrepbiln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer crepbiln for crepbiln.

    create query vhttquery.
    vhttBuffer = ghttCrepbiln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrepbiln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRub-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crepbiln exclusive-lock
                where rowid(crepbiln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crepbiln:handle, 'soc-cd/etab-cd/rub-cd/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crepbiln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrepbiln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crepbiln for crepbiln.

    create query vhttquery.
    vhttBuffer = ghttCrepbiln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrepbiln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crepbiln.
            if not outils:copyValidField(buffer crepbiln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrepbiln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer crepbiln for crepbiln.

    create query vhttquery.
    vhttBuffer = ghttCrepbiln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrepbiln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRub-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crepbiln exclusive-lock
                where rowid(Crepbiln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crepbiln:handle, 'soc-cd/etab-cd/rub-cd/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crepbiln no-error.
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

