/*------------------------------------------------------------------------
File        : creportln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table creportln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/creportln.i}
{application/include/error.i}
define variable ghttcreportln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRub-cd as handle, output phCpt-cd as handle, output phRubln-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/rub-cd/cpt-cd/rubln-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'rubln-cd' then phRubln-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCreportln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCreportln.
    run updateCreportln.
    run createCreportln.
end procedure.

procedure setCreportln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCreportln.
    ghttCreportln = phttCreportln.
    run crudCreportln.
    delete object phttCreportln.
end procedure.

procedure readCreportln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table creportln Ficher des lignes de codes reportings
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piRub-cd   as integer    no-undo.
    define input parameter pcCpt-cd   as character  no-undo.
    define input parameter piRubln-cd as integer    no-undo.
    define input parameter table-handle phttCreportln.
    define variable vhttBuffer as handle no-undo.
    define buffer creportln for creportln.

    vhttBuffer = phttCreportln:default-buffer-handle.
    for first creportln no-lock
        where creportln.soc-cd = piSoc-cd
          and creportln.etab-cd = piEtab-cd
          and creportln.rub-cd = piRub-cd
          and creportln.cpt-cd = pcCpt-cd
          and creportln.rubln-cd = piRubln-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creportln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCreportln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCreportln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table creportln Ficher des lignes de codes reportings
    Notes  : service externe. Critère pcCpt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piRub-cd   as integer    no-undo.
    define input parameter pcCpt-cd   as character  no-undo.
    define input parameter table-handle phttCreportln.
    define variable vhttBuffer as handle  no-undo.
    define buffer creportln for creportln.

    vhttBuffer = phttCreportln:default-buffer-handle.
    if pcCpt-cd = ?
    then for each creportln no-lock
        where creportln.soc-cd = piSoc-cd
          and creportln.etab-cd = piEtab-cd
          and creportln.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creportln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each creportln no-lock
        where creportln.soc-cd = piSoc-cd
          and creportln.etab-cd = piEtab-cd
          and creportln.rub-cd = piRub-cd
          and creportln.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creportln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCreportln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCreportln private:
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
    define variable vhRubln-cd    as handle  no-undo.
    define buffer creportln for creportln.

    create query vhttquery.
    vhttBuffer = ghttCreportln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCreportln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRub-cd, output vhCpt-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first creportln exclusive-lock
                where rowid(creportln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer creportln:handle, 'soc-cd/etab-cd/rub-cd/cpt-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer creportln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCreportln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer creportln for creportln.

    create query vhttquery.
    vhttBuffer = ghttCreportln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCreportln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create creportln.
            if not outils:copyValidField(buffer creportln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCreportln private:
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
    define variable vhRubln-cd    as handle  no-undo.
    define buffer creportln for creportln.

    create query vhttquery.
    vhttBuffer = ghttCreportln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCreportln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRub-cd, output vhCpt-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first creportln exclusive-lock
                where rowid(Creportln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer creportln:handle, 'soc-cd/etab-cd/rub-cd/cpt-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete creportln no-error.
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

