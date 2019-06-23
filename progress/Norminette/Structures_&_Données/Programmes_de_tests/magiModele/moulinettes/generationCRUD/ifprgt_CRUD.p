/*------------------------------------------------------------------------
File        : ifprgt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifprgt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifprgt.i}
{application/include/error.i}
define variable ghttifprgt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phRgt-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/rgt-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'rgt-cle' then phRgt-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfprgt.
    run updateIfprgt.
    run createIfprgt.
end procedure.

procedure setIfprgt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfprgt.
    ghttIfprgt = phttIfprgt.
    run crudIfprgt.
    delete object phttIfprgt.
end procedure.

procedure readIfprgt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifprgt Table des regroupements
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcRgt-cle as character  no-undo.
    define input parameter table-handle phttIfprgt.
    define variable vhttBuffer as handle no-undo.
    define buffer ifprgt for ifprgt.

    vhttBuffer = phttIfprgt:default-buffer-handle.
    for first ifprgt no-lock
        where ifprgt.soc-cd = piSoc-cd
          and ifprgt.rgt-cle = pcRgt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprgt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfprgt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifprgt Table des regroupements
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIfprgt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifprgt for ifprgt.

    vhttBuffer = phttIfprgt:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifprgt no-lock
        where ifprgt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifprgt no-lock
        where ifprgt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprgt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRgt-cle    as handle  no-undo.
    define buffer ifprgt for ifprgt.

    create query vhttquery.
    vhttBuffer = ghttIfprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfprgt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRgt-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprgt exclusive-lock
                where rowid(ifprgt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprgt:handle, 'soc-cd/rgt-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhRgt-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifprgt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifprgt for ifprgt.

    create query vhttquery.
    vhttBuffer = ghttIfprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfprgt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifprgt.
            if not outils:copyValidField(buffer ifprgt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRgt-cle    as handle  no-undo.
    define buffer ifprgt for ifprgt.

    create query vhttquery.
    vhttBuffer = ghttIfprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfprgt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRgt-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprgt exclusive-lock
                where rowid(Ifprgt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprgt:handle, 'soc-cd/rgt-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhRgt-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifprgt no-error.
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

