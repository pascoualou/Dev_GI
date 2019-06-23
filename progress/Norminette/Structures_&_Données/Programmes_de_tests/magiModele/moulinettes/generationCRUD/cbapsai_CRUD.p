/*------------------------------------------------------------------------
File        : cbapsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbapsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbapsai.i}
{application/include/error.i}
define variable ghttcbapsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/num-int, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbapsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbapsai.
    run updateCbapsai.
    run createCbapsai.
end procedure.

procedure setCbapsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbapsai.
    ghttCbapsai = phttCbapsai.
    run crudCbapsai.
    delete object phttCbapsai.
end procedure.

procedure readCbapsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbapsai Entete des saisie de paiement rapide
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttCbapsai.
    define variable vhttBuffer as handle no-undo.
    define buffer cbapsai for cbapsai.

    vhttBuffer = phttCbapsai:default-buffer-handle.
    for first cbapsai no-lock
        where cbapsai.soc-cd = piSoc-cd
          and cbapsai.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbapsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbapsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbapsai Entete des saisie de paiement rapide
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCbapsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbapsai for cbapsai.

    vhttBuffer = phttCbapsai:default-buffer-handle.
    if piSoc-cd = ?
    then for each cbapsai no-lock
        where cbapsai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbapsai no-lock
        where cbapsai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbapsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbapsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer cbapsai for cbapsai.

    create query vhttquery.
    vhttBuffer = ghttCbapsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbapsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbapsai exclusive-lock
                where rowid(cbapsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbapsai:handle, 'soc-cd/num-int: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbapsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbapsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbapsai for cbapsai.

    create query vhttquery.
    vhttBuffer = ghttCbapsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbapsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbapsai.
            if not outils:copyValidField(buffer cbapsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbapsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer cbapsai for cbapsai.

    create query vhttquery.
    vhttBuffer = ghttCbapsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbapsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbapsai exclusive-lock
                where rowid(Cbapsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbapsai:handle, 'soc-cd/num-int: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbapsai no-error.
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

