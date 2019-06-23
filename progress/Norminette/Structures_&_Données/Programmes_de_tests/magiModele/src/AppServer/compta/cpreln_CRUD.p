/*------------------------------------------------------------------------
File        : cpreln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpreln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
{compta/include/cpreln.i}
{application/include/error.i}
define variable ghttcpreln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFg-valid as handle, output phMandat-cd as handle, output phJou-cd as handle, output phDaech as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/fg-valid/mandat-cd/jou-cd/daech/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'fg-valid' then phFg-valid = phBuffer:buffer-field(vi).
            when 'mandat-cd' then phMandat-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'daech' then phDaech = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpreln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpreln.
    run updateCpreln.
    run createCpreln.
end procedure.

procedure setCpreln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpreln.
    ghttCpreln = phttCpreln.
    run crudCpreln.
    delete object phttCpreln.
end procedure.

procedure readCpreln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpreln Table des prelevement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter plFg-valid  as logical    no-undo.
    define input parameter piMandat-cd as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter pdaDaech     as date       no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter table-handle phttCpreln.
    define variable vhttBuffer as handle no-undo.
    define buffer cpreln for cpreln.

    vhttBuffer = phttCpreln:default-buffer-handle.
    for first cpreln no-lock
        where cpreln.soc-cd = piSoc-cd
          and cpreln.fg-valid = plFg-valid
          and cpreln.mandat-cd = piMandat-cd
          and cpreln.jou-cd = pcJou-cd
          and cpreln.daech = pdaDaech
          and cpreln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpreln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpreln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpreln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpreln Table des prelevement
    Notes  : service externe. Critère pdaDaech = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter plFg-valid  as logical    no-undo.
    define input parameter piMandat-cd as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter pdaDaech     as date       no-undo.
    define input parameter table-handle phttCpreln.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpreln for cpreln.

    vhttBuffer = phttCpreln:default-buffer-handle.
    if pdaDaech = ?
    then for each cpreln no-lock
        where cpreln.soc-cd = piSoc-cd
          and cpreln.fg-valid = plFg-valid
          and cpreln.mandat-cd = piMandat-cd
          and cpreln.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpreln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpreln no-lock
        where cpreln.soc-cd = piSoc-cd
          and cpreln.fg-valid = plFg-valid
          and cpreln.mandat-cd = piMandat-cd
          and cpreln.jou-cd = pcJou-cd
          and cpreln.daech = pdaDaech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpreln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpreln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpreln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFg-valid    as handle  no-undo.
    define variable vhMandat-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer cpreln for cpreln.

    create query vhttquery.
    vhttBuffer = ghttCpreln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpreln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFg-valid, output vhMandat-cd, output vhJou-cd, output vhDaech, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpreln exclusive-lock
                where rowid(cpreln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpreln:handle, 'soc-cd/fg-valid/mandat-cd/jou-cd/daech/etab-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhFg-valid:buffer-value(), vhMandat-cd:buffer-value(), vhJou-cd:buffer-value(), vhDaech:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpreln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpreln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpreln for cpreln.

    create query vhttquery.
    vhttBuffer = ghttCpreln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpreln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpreln.
            if not outils:copyValidField(buffer cpreln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpreln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFg-valid    as handle  no-undo.
    define variable vhMandat-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer cpreln for cpreln.

    create query vhttquery.
    vhttBuffer = ghttCpreln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpreln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFg-valid, output vhMandat-cd, output vhJou-cd, output vhDaech, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpreln exclusive-lock
                where rowid(Cpreln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpreln:handle, 'soc-cd/fg-valid/mandat-cd/jou-cd/daech/etab-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhFg-valid:buffer-value(), vhMandat-cd:buffer-value(), vhJou-cd:buffer-value(), vhDaech:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpreln no-error.
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

