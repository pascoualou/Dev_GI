/*------------------------------------------------------------------------
File        : phisodp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table phisodp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/phisodp.i}
{application/include/error.i}
define variable ghttphisodp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/prd-cd/prd-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPhisodp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePhisodp.
    run updatePhisodp.
    run createPhisodp.
end procedure.

procedure setPhisodp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPhisodp.
    ghttPhisodp = phttPhisodp.
    run crudPhisodp.
    delete object phttPhisodp.
end procedure.

procedure readPhisodp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table phisodp Fichier Histo O.D. PAIE
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter piPrd-num as integer    no-undo.
    define input parameter table-handle phttPhisodp.
    define variable vhttBuffer as handle no-undo.
    define buffer phisodp for phisodp.

    vhttBuffer = phttPhisodp:default-buffer-handle.
    for first phisodp no-lock
        where phisodp.soc-cd = piSoc-cd
          and phisodp.etab-cd = piEtab-cd
          and phisodp.prd-cd = piPrd-cd
          and phisodp.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer phisodp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPhisodp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPhisodp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table phisodp Fichier Histo O.D. PAIE
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter table-handle phttPhisodp.
    define variable vhttBuffer as handle  no-undo.
    define buffer phisodp for phisodp.

    vhttBuffer = phttPhisodp:default-buffer-handle.
    if piPrd-cd = ?
    then for each phisodp no-lock
        where phisodp.soc-cd = piSoc-cd
          and phisodp.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer phisodp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each phisodp no-lock
        where phisodp.soc-cd = piSoc-cd
          and phisodp.etab-cd = piEtab-cd
          and phisodp.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer phisodp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPhisodp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePhisodp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer phisodp for phisodp.

    create query vhttquery.
    vhttBuffer = ghttPhisodp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPhisodp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first phisodp exclusive-lock
                where rowid(phisodp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer phisodp:handle, 'soc-cd/etab-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer phisodp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPhisodp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer phisodp for phisodp.

    create query vhttquery.
    vhttBuffer = ghttPhisodp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPhisodp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create phisodp.
            if not outils:copyValidField(buffer phisodp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePhisodp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer phisodp for phisodp.

    create query vhttquery.
    vhttBuffer = ghttPhisodp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPhisodp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first phisodp exclusive-lock
                where rowid(Phisodp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer phisodp:handle, 'soc-cd/etab-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete phisodp no-error.
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

