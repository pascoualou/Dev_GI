/*------------------------------------------------------------------------
File        : crepsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crepsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crepsai.i}
{application/include/error.i}
define variable ghttcrepsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRepart-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/repart-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'repart-cle' then phRepart-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrepsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrepsai.
    run updateCrepsai.
    run createCrepsai.
end procedure.

procedure setCrepsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrepsai.
    ghttCrepsai = phttCrepsai.
    run crudCrepsai.
    delete object phttCrepsai.
end procedure.

procedure readCrepsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crepsai Fichier entetes des cles de
repartition
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcRepart-cle as character  no-undo.
    define input parameter table-handle phttCrepsai.
    define variable vhttBuffer as handle no-undo.
    define buffer crepsai for crepsai.

    vhttBuffer = phttCrepsai:default-buffer-handle.
    for first crepsai no-lock
        where crepsai.soc-cd = piSoc-cd
          and crepsai.etab-cd = piEtab-cd
          and crepsai.repart-cle = pcRepart-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrepsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrepsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crepsai Fichier entetes des cles de
repartition
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCrepsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer crepsai for crepsai.

    vhttBuffer = phttCrepsai:default-buffer-handle.
    if piEtab-cd = ?
    then for each crepsai no-lock
        where crepsai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crepsai no-lock
        where crepsai.soc-cd = piSoc-cd
          and crepsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrepsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrepsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRepart-cle    as handle  no-undo.
    define buffer crepsai for crepsai.

    create query vhttquery.
    vhttBuffer = ghttCrepsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrepsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRepart-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crepsai exclusive-lock
                where rowid(crepsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crepsai:handle, 'soc-cd/etab-cd/repart-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRepart-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crepsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrepsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crepsai for crepsai.

    create query vhttquery.
    vhttBuffer = ghttCrepsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrepsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crepsai.
            if not outils:copyValidField(buffer crepsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrepsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRepart-cle    as handle  no-undo.
    define buffer crepsai for crepsai.

    create query vhttquery.
    vhttBuffer = ghttCrepsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrepsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRepart-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crepsai exclusive-lock
                where rowid(Crepsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crepsai:handle, 'soc-cd/etab-cd/repart-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRepart-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crepsai no-error.
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

