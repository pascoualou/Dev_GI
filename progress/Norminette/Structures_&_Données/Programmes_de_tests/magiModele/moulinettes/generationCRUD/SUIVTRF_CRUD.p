/*------------------------------------------------------------------------
File        : SUIVTRF_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SUIVTRF
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SUIVTRF.i}
{application/include/error.i}
define variable ghttSUIVTRF as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phGest-cle as handle, output phCdtrait as handle, output phMoiscpt as handle, output phNochrodis as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/gest-cle/CDTRAIT/MOISCPT/NOCHRODIS, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'gest-cle' then phGest-cle = phBuffer:buffer-field(vi).
            when 'CDTRAIT' then phCdtrait = phBuffer:buffer-field(vi).
            when 'MOISCPT' then phMoiscpt = phBuffer:buffer-field(vi).
            when 'NOCHRODIS' then phNochrodis = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSuivtrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSuivtrf.
    run updateSuivtrf.
    run createSuivtrf.
end procedure.

procedure setSuivtrf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSuivtrf.
    ghttSuivtrf = phttSuivtrf.
    run crudSuivtrf.
    delete object phttSuivtrf.
end procedure.

procedure readSuivtrf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SUIVTRF 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcGest-cle  as character  no-undo.
    define input parameter pcCdtrait   as character  no-undo.
    define input parameter piMoiscpt   as integer    no-undo.
    define input parameter piNochrodis as integer    no-undo.
    define input parameter table-handle phttSuivtrf.
    define variable vhttBuffer as handle no-undo.
    define buffer SUIVTRF for SUIVTRF.

    vhttBuffer = phttSuivtrf:default-buffer-handle.
    for first SUIVTRF no-lock
        where SUIVTRF.soc-cd = piSoc-cd
          and SUIVTRF.gest-cle = pcGest-cle
          and SUIVTRF.CDTRAIT = pcCdtrait
          and SUIVTRF.MOISCPT = piMoiscpt
          and SUIVTRF.NOCHRODIS = piNochrodis:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SUIVTRF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuivtrf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSuivtrf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SUIVTRF 
    Notes  : service externe. Critère piMoiscpt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcGest-cle  as character  no-undo.
    define input parameter pcCdtrait   as character  no-undo.
    define input parameter piMoiscpt   as integer    no-undo.
    define input parameter table-handle phttSuivtrf.
    define variable vhttBuffer as handle  no-undo.
    define buffer SUIVTRF for SUIVTRF.

    vhttBuffer = phttSuivtrf:default-buffer-handle.
    if piMoiscpt = ?
    then for each SUIVTRF no-lock
        where SUIVTRF.soc-cd = piSoc-cd
          and SUIVTRF.gest-cle = pcGest-cle
          and SUIVTRF.CDTRAIT = pcCdtrait:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SUIVTRF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SUIVTRF no-lock
        where SUIVTRF.soc-cd = piSoc-cd
          and SUIVTRF.gest-cle = pcGest-cle
          and SUIVTRF.CDTRAIT = pcCdtrait
          and SUIVTRF.MOISCPT = piMoiscpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SUIVTRF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuivtrf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSuivtrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhGest-cle    as handle  no-undo.
    define variable vhCdtrait    as handle  no-undo.
    define variable vhMoiscpt    as handle  no-undo.
    define variable vhNochrodis    as handle  no-undo.
    define buffer SUIVTRF for SUIVTRF.

    create query vhttquery.
    vhttBuffer = ghttSuivtrf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSuivtrf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhGest-cle, output vhCdtrait, output vhMoiscpt, output vhNochrodis).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SUIVTRF exclusive-lock
                where rowid(SUIVTRF) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SUIVTRF:handle, 'soc-cd/gest-cle/CDTRAIT/MOISCPT/NOCHRODIS: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhGest-cle:buffer-value(), vhCdtrait:buffer-value(), vhMoiscpt:buffer-value(), vhNochrodis:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SUIVTRF:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSuivtrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SUIVTRF for SUIVTRF.

    create query vhttquery.
    vhttBuffer = ghttSuivtrf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSuivtrf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SUIVTRF.
            if not outils:copyValidField(buffer SUIVTRF:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSuivtrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhGest-cle    as handle  no-undo.
    define variable vhCdtrait    as handle  no-undo.
    define variable vhMoiscpt    as handle  no-undo.
    define variable vhNochrodis    as handle  no-undo.
    define buffer SUIVTRF for SUIVTRF.

    create query vhttquery.
    vhttBuffer = ghttSuivtrf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSuivtrf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhGest-cle, output vhCdtrait, output vhMoiscpt, output vhNochrodis).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SUIVTRF exclusive-lock
                where rowid(Suivtrf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SUIVTRF:handle, 'soc-cd/gest-cle/CDTRAIT/MOISCPT/NOCHRODIS: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhGest-cle:buffer-value(), vhCdtrait:buffer-value(), vhMoiscpt:buffer-value(), vhNochrodis:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SUIVTRF no-error.
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

