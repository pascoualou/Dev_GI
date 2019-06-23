/*------------------------------------------------------------------------
File        : cgrpana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cgrpana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cgrpana.i}
{application/include/error.i}
define variable ghttcgrpana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNiv as handle, output phGrp-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/niv/grp-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'niv' then phNiv = phBuffer:buffer-field(vi).
            when 'grp-cd' then phGrp-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCgrpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCgrpana.
    run updateCgrpana.
    run createCgrpana.
end procedure.

procedure setCgrpana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCgrpana.
    ghttCgrpana = phttCgrpana.
    run crudCgrpana.
    delete object phttCgrpana.
end procedure.

procedure readCgrpana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cgrpana Fichiers des differents groupements analytiques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv     as integer    no-undo.
    define input parameter pcGrp-cd  as character  no-undo.
    define input parameter table-handle phttCgrpana.
    define variable vhttBuffer as handle no-undo.
    define buffer cgrpana for cgrpana.

    vhttBuffer = phttCgrpana:default-buffer-handle.
    for first cgrpana no-lock
        where cgrpana.soc-cd = piSoc-cd
          and cgrpana.etab-cd = piEtab-cd
          and cgrpana.niv = piNiv
          and cgrpana.grp-cd = pcGrp-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cgrpana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCgrpana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCgrpana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cgrpana Fichiers des differents groupements analytiques
    Notes  : service externe. Critère piNiv = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv     as integer    no-undo.
    define input parameter table-handle phttCgrpana.
    define variable vhttBuffer as handle  no-undo.
    define buffer cgrpana for cgrpana.

    vhttBuffer = phttCgrpana:default-buffer-handle.
    if piNiv = ?
    then for each cgrpana no-lock
        where cgrpana.soc-cd = piSoc-cd
          and cgrpana.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cgrpana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cgrpana no-lock
        where cgrpana.soc-cd = piSoc-cd
          and cgrpana.etab-cd = piEtab-cd
          and cgrpana.niv = piNiv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cgrpana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCgrpana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCgrpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv    as handle  no-undo.
    define variable vhGrp-cd    as handle  no-undo.
    define buffer cgrpana for cgrpana.

    create query vhttquery.
    vhttBuffer = ghttCgrpana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCgrpana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv, output vhGrp-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cgrpana exclusive-lock
                where rowid(cgrpana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cgrpana:handle, 'soc-cd/etab-cd/niv/grp-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv:buffer-value(), vhGrp-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cgrpana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCgrpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cgrpana for cgrpana.

    create query vhttquery.
    vhttBuffer = ghttCgrpana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCgrpana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cgrpana.
            if not outils:copyValidField(buffer cgrpana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCgrpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv    as handle  no-undo.
    define variable vhGrp-cd    as handle  no-undo.
    define buffer cgrpana for cgrpana.

    create query vhttquery.
    vhttBuffer = ghttCgrpana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCgrpana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv, output vhGrp-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cgrpana exclusive-lock
                where rowid(Cgrpana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cgrpana:handle, 'soc-cd/etab-cd/niv/grp-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv:buffer-value(), vhGrp-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cgrpana no-error.
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

