/*------------------------------------------------------------------------
File        : itcrgt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itcrgt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itcrgt.i}
{application/include/error.i}
define variable ghttitcrgt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNature-cd as handle, output phRgt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/nature-cd/rgt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'nature-cd' then phNature-cd = phBuffer:buffer-field(vi).
            when 'rgt-cd' then phRgt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItcrgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItcrgt.
    run updateItcrgt.
    run createItcrgt.
end procedure.

procedure setItcrgt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItcrgt.
    ghttItcrgt = phttItcrgt.
    run crudItcrgt.
    delete object phttItcrgt.
end procedure.

procedure readItcrgt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itcrgt Transfert compta - codes de regroupements
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcNature-cd as character  no-undo.
    define input parameter pcRgt-cd    as character  no-undo.
    define input parameter table-handle phttItcrgt.
    define variable vhttBuffer as handle no-undo.
    define buffer itcrgt for itcrgt.

    vhttBuffer = phttItcrgt:default-buffer-handle.
    for first itcrgt no-lock
        where itcrgt.soc-cd = piSoc-cd
          and itcrgt.nature-cd = pcNature-cd
          and itcrgt.rgt-cd = pcRgt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcrgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItcrgt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItcrgt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itcrgt Transfert compta - codes de regroupements
    Notes  : service externe. Critère pcNature-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcNature-cd as character  no-undo.
    define input parameter table-handle phttItcrgt.
    define variable vhttBuffer as handle  no-undo.
    define buffer itcrgt for itcrgt.

    vhttBuffer = phttItcrgt:default-buffer-handle.
    if pcNature-cd = ?
    then for each itcrgt no-lock
        where itcrgt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcrgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itcrgt no-lock
        where itcrgt.soc-cd = piSoc-cd
          and itcrgt.nature-cd = pcNature-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcrgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItcrgt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItcrgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNature-cd    as handle  no-undo.
    define variable vhRgt-cd    as handle  no-undo.
    define buffer itcrgt for itcrgt.

    create query vhttquery.
    vhttBuffer = ghttItcrgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItcrgt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNature-cd, output vhRgt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itcrgt exclusive-lock
                where rowid(itcrgt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itcrgt:handle, 'soc-cd/nature-cd/rgt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhNature-cd:buffer-value(), vhRgt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itcrgt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItcrgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itcrgt for itcrgt.

    create query vhttquery.
    vhttBuffer = ghttItcrgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItcrgt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itcrgt.
            if not outils:copyValidField(buffer itcrgt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItcrgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNature-cd    as handle  no-undo.
    define variable vhRgt-cd    as handle  no-undo.
    define buffer itcrgt for itcrgt.

    create query vhttquery.
    vhttBuffer = ghttItcrgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItcrgt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNature-cd, output vhRgt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itcrgt exclusive-lock
                where rowid(Itcrgt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itcrgt:handle, 'soc-cd/nature-cd/rgt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhNature-cd:buffer-value(), vhRgt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itcrgt no-error.
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

