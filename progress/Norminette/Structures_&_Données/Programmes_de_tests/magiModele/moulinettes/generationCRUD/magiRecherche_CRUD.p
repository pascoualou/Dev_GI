/*------------------------------------------------------------------------
File        : magiRecherche_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table magiRecherche
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/magiRecherche.i}
{application/include/error.i}
define variable ghttmagiRecherche as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCtype as handle, output phIcdlng as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cType/iCdLng, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cType' then phCtype = phBuffer:buffer-field(vi).
            when 'iCdLng' then phIcdlng = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMagirecherche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMagirecherche.
    run updateMagirecherche.
    run createMagirecherche.
end procedure.

procedure setMagirecherche:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMagirecherche.
    ghttMagirecherche = phttMagirecherche.
    run crudMagirecherche.
    delete object phttMagirecherche.
end procedure.

procedure readMagirecherche:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table magiRecherche Table de recherche pour auto completion.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCtype  as character  no-undo.
    define input parameter piIcdlng as int64      no-undo.
    define input parameter table-handle phttMagirecherche.
    define variable vhttBuffer as handle no-undo.
    define buffer magiRecherche for magiRecherche.

    vhttBuffer = phttMagirecherche:default-buffer-handle.
    for first magiRecherche no-lock
        where magiRecherche.cType = pcCtype
          and magiRecherche.iCdLng = piIcdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer magiRecherche:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMagirecherche no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMagirecherche:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table magiRecherche Table de recherche pour auto completion.
    Notes  : service externe. Critère pcCtype = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCtype  as character  no-undo.
    define input parameter table-handle phttMagirecherche.
    define variable vhttBuffer as handle  no-undo.
    define buffer magiRecherche for magiRecherche.

    vhttBuffer = phttMagirecherche:default-buffer-handle.
    if pcCtype = ?
    then for each magiRecherche no-lock
        where magiRecherche.cType = pcCtype:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer magiRecherche:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each magiRecherche no-lock
        where magiRecherche.cType = pcCtype:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer magiRecherche:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMagirecherche no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMagirecherche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCtype    as handle  no-undo.
    define variable vhIcdlng    as handle  no-undo.
    define buffer magiRecherche for magiRecherche.

    create query vhttquery.
    vhttBuffer = ghttMagirecherche:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMagirecherche:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCtype, output vhIcdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first magiRecherche exclusive-lock
                where rowid(magiRecherche) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer magiRecherche:handle, 'cType/iCdLng: ', substitute('&1/&2', vhCtype:buffer-value(), vhIcdlng:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer magiRecherche:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMagirecherche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer magiRecherche for magiRecherche.

    create query vhttquery.
    vhttBuffer = ghttMagirecherche:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMagirecherche:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create magiRecherche.
            if not outils:copyValidField(buffer magiRecherche:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMagirecherche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCtype    as handle  no-undo.
    define variable vhIcdlng    as handle  no-undo.
    define buffer magiRecherche for magiRecherche.

    create query vhttquery.
    vhttBuffer = ghttMagirecherche:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMagirecherche:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCtype, output vhIcdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first magiRecherche exclusive-lock
                where rowid(Magirecherche) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer magiRecherche:handle, 'cType/iCdLng: ', substitute('&1/&2', vhCtype:buffer-value(), vhIcdlng:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete magiRecherche no-error.
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

