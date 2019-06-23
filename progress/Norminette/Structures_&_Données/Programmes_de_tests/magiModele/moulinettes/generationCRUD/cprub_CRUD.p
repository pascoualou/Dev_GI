/*------------------------------------------------------------------------
File        : cprub_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cprub
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cprub.i}
{application/include/error.i}
define variable ghttcprub as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-ord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-ord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-ord' then phNum-ord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCprub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCprub.
    run updateCprub.
    run createCprub.
end procedure.

procedure setCprub:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCprub.
    ghttCprub = phttCprub.
    run crudCprub.
    delete object phttCprub.
end procedure.

procedure readCprub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cprub 

    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNum-ord as integer    no-undo.
    define input parameter table-handle phttCprub.
    define variable vhttBuffer as handle no-undo.
    define buffer cprub for cprub.

    vhttBuffer = phttCprub:default-buffer-handle.
    for first cprub no-lock
        where cprub.soc-cd = piSoc-cd
          and cprub.etab-cd = piEtab-cd
          and cprub.num-ord = piNum-ord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cprub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCprub no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCprub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cprub 

    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCprub.
    define variable vhttBuffer as handle  no-undo.
    define buffer cprub for cprub.

    vhttBuffer = phttCprub:default-buffer-handle.
    if piEtab-cd = ?
    then for each cprub no-lock
        where cprub.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cprub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cprub no-lock
        where cprub.soc-cd = piSoc-cd
          and cprub.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cprub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCprub no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCprub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-ord    as handle  no-undo.
    define buffer cprub for cprub.

    create query vhttquery.
    vhttBuffer = ghttCprub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCprub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-ord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cprub exclusive-lock
                where rowid(cprub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cprub:handle, 'soc-cd/etab-cd/num-ord: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-ord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cprub:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCprub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cprub for cprub.

    create query vhttquery.
    vhttBuffer = ghttCprub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCprub:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cprub.
            if not outils:copyValidField(buffer cprub:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCprub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-ord    as handle  no-undo.
    define buffer cprub for cprub.

    create query vhttquery.
    vhttBuffer = ghttCprub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCprub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-ord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cprub exclusive-lock
                where rowid(Cprub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cprub:handle, 'soc-cd/etab-cd/num-ord: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-ord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cprub no-error.
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

