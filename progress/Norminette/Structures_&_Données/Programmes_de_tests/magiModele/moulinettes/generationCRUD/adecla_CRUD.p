/*------------------------------------------------------------------------
File        : adecla_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table adecla
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/adecla.i}
{application/include/error.i}
define variable ghttadecla as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phGest-cle as handle, output phDate_decla as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/gest-cle/date_decla, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'gest-cle' then phGest-cle = phBuffer:buffer-field(vi).
            when 'date_decla' then phDate_decla = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAdecla private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAdecla.
    run updateAdecla.
    run createAdecla.
end procedure.

procedure setAdecla:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdecla.
    ghttAdecla = phttAdecla.
    run crudAdecla.
    delete object phttAdecla.
end procedure.

procedure readAdecla:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table adecla 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcGest-cle   as character  no-undo.
    define input parameter pdaDate_decla as date       no-undo.
    define input parameter table-handle phttAdecla.
    define variable vhttBuffer as handle no-undo.
    define buffer adecla for adecla.

    vhttBuffer = phttAdecla:default-buffer-handle.
    for first adecla no-lock
        where adecla.soc-cd = piSoc-cd
          and adecla.gest-cle = pcGest-cle
          and adecla.date_decla = pdaDate_decla:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adecla:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdecla no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAdecla:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table adecla 
    Notes  : service externe. Critère pcGest-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcGest-cle   as character  no-undo.
    define input parameter table-handle phttAdecla.
    define variable vhttBuffer as handle  no-undo.
    define buffer adecla for adecla.

    vhttBuffer = phttAdecla:default-buffer-handle.
    if pcGest-cle = ?
    then for each adecla no-lock
        where adecla.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adecla:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each adecla no-lock
        where adecla.soc-cd = piSoc-cd
          and adecla.gest-cle = pcGest-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adecla:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdecla no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAdecla private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhGest-cle    as handle  no-undo.
    define variable vhDate_decla    as handle  no-undo.
    define buffer adecla for adecla.

    create query vhttquery.
    vhttBuffer = ghttAdecla:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAdecla:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhGest-cle, output vhDate_decla).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adecla exclusive-lock
                where rowid(adecla) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adecla:handle, 'soc-cd/gest-cle/date_decla: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhGest-cle:buffer-value(), vhDate_decla:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer adecla:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAdecla private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer adecla for adecla.

    create query vhttquery.
    vhttBuffer = ghttAdecla:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAdecla:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create adecla.
            if not outils:copyValidField(buffer adecla:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAdecla private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhGest-cle    as handle  no-undo.
    define variable vhDate_decla    as handle  no-undo.
    define buffer adecla for adecla.

    create query vhttquery.
    vhttBuffer = ghttAdecla:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAdecla:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhGest-cle, output vhDate_decla).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adecla exclusive-lock
                where rowid(Adecla) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adecla:handle, 'soc-cd/gest-cle/date_decla: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhGest-cle:buffer-value(), vhDate_decla:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete adecla no-error.
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

