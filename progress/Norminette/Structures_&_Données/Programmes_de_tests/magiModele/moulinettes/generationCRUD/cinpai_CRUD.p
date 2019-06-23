/*------------------------------------------------------------------------
File        : cinpai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinpai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinpai.i}
{application/include/error.i}
define variable ghttcinpai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-invest as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-invest, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-invest' then phType-invest = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinpai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinpai.
    run updateCinpai.
    run createCinpai.
end procedure.

procedure setCinpai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinpai.
    ghttCinpai = phttCinpai.
    run crudCinpai.
    delete object phttCinpai.
end procedure.

procedure readCinpai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinpai fichier des parametres investissement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter table-handle phttCinpai.
    define variable vhttBuffer as handle no-undo.
    define buffer cinpai for cinpai.

    vhttBuffer = phttCinpai:default-buffer-handle.
    for first cinpai no-lock
        where cinpai.soc-cd = piSoc-cd
          and cinpai.etab-cd = piEtab-cd
          and cinpai.type-invest = piType-invest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinpai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinpai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinpai fichier des parametres investissement
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter table-handle phttCinpai.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinpai for cinpai.

    vhttBuffer = phttCinpai:default-buffer-handle.
    if piEtab-cd = ?
    then for each cinpai no-lock
        where cinpai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinpai no-lock
        where cinpai.soc-cd = piSoc-cd
          and cinpai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinpai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinpai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define buffer cinpai for cinpai.

    create query vhttquery.
    vhttBuffer = ghttCinpai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinpai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinpai exclusive-lock
                where rowid(cinpai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinpai:handle, 'soc-cd/etab-cd/type-invest: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinpai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinpai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinpai for cinpai.

    create query vhttquery.
    vhttBuffer = ghttCinpai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinpai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinpai.
            if not outils:copyValidField(buffer cinpai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinpai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define buffer cinpai for cinpai.

    create query vhttquery.
    vhttBuffer = ghttCinpai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinpai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinpai exclusive-lock
                where rowid(Cinpai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinpai:handle, 'soc-cd/etab-cd/type-invest: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinpai no-error.
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

