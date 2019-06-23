/*------------------------------------------------------------------------
File        : icmc7_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table icmc7
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/icmc7.i}
{application/include/error.i}
define variable ghtticmc7 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phColl-cle as handle, output phTiers-cle as handle, output phOrdre-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/coll-cle/tiers-cle/ordre-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'tiers-cle' then phTiers-cle = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIcmc7 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIcmc7.
    run updateIcmc7.
    run createIcmc7.
end procedure.

procedure setIcmc7:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIcmc7.
    ghttIcmc7 = phttIcmc7.
    run crudIcmc7.
    delete object phttIcmc7.
end procedure.

procedure readIcmc7:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table icmc7 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcColl-cle  as character  no-undo.
    define input parameter pcTiers-cle as character  no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter table-handle phttIcmc7.
    define variable vhttBuffer as handle no-undo.
    define buffer icmc7 for icmc7.

    vhttBuffer = phttIcmc7:default-buffer-handle.
    for first icmc7 no-lock
        where icmc7.soc-cd = piSoc-cd
          and icmc7.coll-cle = pcColl-cle
          and icmc7.tiers-cle = pcTiers-cle
          and icmc7.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icmc7:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcmc7 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIcmc7:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table icmc7 
    Notes  : service externe. Critère pcTiers-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcColl-cle  as character  no-undo.
    define input parameter pcTiers-cle as character  no-undo.
    define input parameter table-handle phttIcmc7.
    define variable vhttBuffer as handle  no-undo.
    define buffer icmc7 for icmc7.

    vhttBuffer = phttIcmc7:default-buffer-handle.
    if pcTiers-cle = ?
    then for each icmc7 no-lock
        where icmc7.soc-cd = piSoc-cd
          and icmc7.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icmc7:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each icmc7 no-lock
        where icmc7.soc-cd = piSoc-cd
          and icmc7.coll-cle = pcColl-cle
          and icmc7.tiers-cle = pcTiers-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icmc7:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcmc7 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIcmc7 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhTiers-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer icmc7 for icmc7.

    create query vhttquery.
    vhttBuffer = ghttIcmc7:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIcmc7:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle, output vhTiers-cle, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icmc7 exclusive-lock
                where rowid(icmc7) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icmc7:handle, 'soc-cd/coll-cle/tiers-cle/ordre-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value(), vhTiers-cle:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer icmc7:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIcmc7 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer icmc7 for icmc7.

    create query vhttquery.
    vhttBuffer = ghttIcmc7:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIcmc7:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create icmc7.
            if not outils:copyValidField(buffer icmc7:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIcmc7 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhTiers-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer icmc7 for icmc7.

    create query vhttquery.
    vhttBuffer = ghttIcmc7:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIcmc7:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle, output vhTiers-cle, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icmc7 exclusive-lock
                where rowid(Icmc7) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icmc7:handle, 'soc-cd/coll-cle/tiers-cle/ordre-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value(), vhTiers-cle:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete icmc7 no-error.
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

