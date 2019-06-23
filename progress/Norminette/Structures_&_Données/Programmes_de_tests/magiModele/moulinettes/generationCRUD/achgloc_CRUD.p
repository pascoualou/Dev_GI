/*------------------------------------------------------------------------
File        : achgloc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table achgloc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/achgloc.i}
{application/include/error.i}
define variable ghttachgloc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCptg-cd as handle, output phSscpt-cd as handle, output phNoexo as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cptg-cd/sscpt-cd/noexo, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cptg-cd' then phCptg-cd = phBuffer:buffer-field(vi).
            when 'sscpt-cd' then phSscpt-cd = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAchgloc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAchgloc.
    run updateAchgloc.
    run createAchgloc.
end procedure.

procedure setAchgloc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAchgloc.
    ghttAchgloc = phttAchgloc.
    run crudAchgloc.
    delete object phttAchgloc.
end procedure.

procedure readAchgloc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table achgloc quote-part charges locatives
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcCptg-cd  as character  no-undo.
    define input parameter pcSscpt-cd as character  no-undo.
    define input parameter piNoexo    as integer    no-undo.
    define input parameter table-handle phttAchgloc.
    define variable vhttBuffer as handle no-undo.
    define buffer achgloc for achgloc.

    vhttBuffer = phttAchgloc:default-buffer-handle.
    for first achgloc no-lock
        where achgloc.soc-cd = piSoc-cd
          and achgloc.etab-cd = piEtab-cd
          and achgloc.cptg-cd = pcCptg-cd
          and achgloc.sscpt-cd = pcSscpt-cd
          and achgloc.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer achgloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAchgloc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAchgloc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table achgloc quote-part charges locatives
    Notes  : service externe. Critère pcSscpt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcCptg-cd  as character  no-undo.
    define input parameter pcSscpt-cd as character  no-undo.
    define input parameter table-handle phttAchgloc.
    define variable vhttBuffer as handle  no-undo.
    define buffer achgloc for achgloc.

    vhttBuffer = phttAchgloc:default-buffer-handle.
    if pcSscpt-cd = ?
    then for each achgloc no-lock
        where achgloc.soc-cd = piSoc-cd
          and achgloc.etab-cd = piEtab-cd
          and achgloc.cptg-cd = pcCptg-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer achgloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each achgloc no-lock
        where achgloc.soc-cd = piSoc-cd
          and achgloc.etab-cd = piEtab-cd
          and achgloc.cptg-cd = pcCptg-cd
          and achgloc.sscpt-cd = pcSscpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer achgloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAchgloc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAchgloc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCptg-cd    as handle  no-undo.
    define variable vhSscpt-cd    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define buffer achgloc for achgloc.

    create query vhttquery.
    vhttBuffer = ghttAchgloc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAchgloc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCptg-cd, output vhSscpt-cd, output vhNoexo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first achgloc exclusive-lock
                where rowid(achgloc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer achgloc:handle, 'soc-cd/etab-cd/cptg-cd/sscpt-cd/noexo: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCptg-cd:buffer-value(), vhSscpt-cd:buffer-value(), vhNoexo:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer achgloc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAchgloc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer achgloc for achgloc.

    create query vhttquery.
    vhttBuffer = ghttAchgloc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAchgloc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create achgloc.
            if not outils:copyValidField(buffer achgloc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAchgloc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCptg-cd    as handle  no-undo.
    define variable vhSscpt-cd    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define buffer achgloc for achgloc.

    create query vhttquery.
    vhttBuffer = ghttAchgloc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAchgloc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCptg-cd, output vhSscpt-cd, output vhNoexo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first achgloc exclusive-lock
                where rowid(Achgloc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer achgloc:handle, 'soc-cd/etab-cd/cptg-cd/sscpt-cd/noexo: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCptg-cd:buffer-value(), vhSscpt-cd:buffer-value(), vhNoexo:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete achgloc no-error.
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

