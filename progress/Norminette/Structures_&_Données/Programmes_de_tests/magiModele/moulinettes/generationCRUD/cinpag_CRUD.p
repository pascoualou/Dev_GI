/*------------------------------------------------------------------------
File        : cinpag_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinpag
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinpag.i}
{application/include/error.i}
define variable ghttcinpag as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phInvest-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/invest-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'invest-cle' then phInvest-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinpag private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinpag.
    run updateCinpag.
    run createCinpag.
end procedure.

procedure setCinpag:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinpag.
    ghttCinpag = phttCinpag.
    run crudCinpag.
    delete object phttCinpag.
end procedure.

procedure readCinpag:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinpag fichier parametre generaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter table-handle phttCinpag.
    define variable vhttBuffer as handle no-undo.
    define buffer cinpag for cinpag.

    vhttBuffer = phttCinpag:default-buffer-handle.
    for first cinpag no-lock
        where cinpag.soc-cd = piSoc-cd
          and cinpag.etab-cd = piEtab-cd
          and cinpag.invest-cle = pcInvest-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpag:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinpag no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinpag:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinpag fichier parametre generaux
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCinpag.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinpag for cinpag.

    vhttBuffer = phttCinpag:default-buffer-handle.
    if piEtab-cd = ?
    then for each cinpag no-lock
        where cinpag.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpag:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinpag no-lock
        where cinpag.soc-cd = piSoc-cd
          and cinpag.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpag:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinpag no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinpag private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define buffer cinpag for cinpag.

    create query vhttquery.
    vhttBuffer = ghttCinpag:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinpag:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinpag exclusive-lock
                where rowid(cinpag) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinpag:handle, 'soc-cd/etab-cd/invest-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinpag:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinpag private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinpag for cinpag.

    create query vhttquery.
    vhttBuffer = ghttCinpag:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinpag:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinpag.
            if not outils:copyValidField(buffer cinpag:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinpag private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define buffer cinpag for cinpag.

    create query vhttquery.
    vhttBuffer = ghttCinpag:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinpag:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinpag exclusive-lock
                where rowid(Cinpag) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinpag:handle, 'soc-cd/etab-cd/invest-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinpag no-error.
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

