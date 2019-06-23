/*------------------------------------------------------------------------
File        : regcop_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table regcop
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/regcop.i}
{application/include/error.i}
define variable ghttregcop as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phIordre as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/iOrdre, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'iOrdre' then phIordre = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRegcop private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRegcop.
    run updateRegcop.
    run createRegcop.
end procedure.

procedure setRegcop:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRegcop.
    ghttRegcop = phttRegcop.
    run crudRegcop.
    delete object phttRegcop.
end procedure.

procedure readRegcop:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table regcop Registre des copropriétés
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon  as character  no-undo.
    define input parameter piNocon  as int64      no-undo.
    define input parameter piIordre as integer    no-undo.
    define input parameter table-handle phttRegcop.
    define variable vhttBuffer as handle no-undo.
    define buffer regcop for regcop.

    vhttBuffer = phttRegcop:default-buffer-handle.
    for first regcop no-lock
        where regcop.tpcon = pcTpcon
          and regcop.nocon = piNocon
          and regcop.iOrdre = piIordre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer regcop:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRegcop no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRegcop:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table regcop Registre des copropriétés
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon  as character  no-undo.
    define input parameter piNocon  as int64      no-undo.
    define input parameter table-handle phttRegcop.
    define variable vhttBuffer as handle  no-undo.
    define buffer regcop for regcop.

    vhttBuffer = phttRegcop:default-buffer-handle.
    if piNocon = ?
    then for each regcop no-lock
        where regcop.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer regcop:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each regcop no-lock
        where regcop.tpcon = pcTpcon
          and regcop.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer regcop:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRegcop no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRegcop private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhIordre    as handle  no-undo.
    define buffer regcop for regcop.

    create query vhttquery.
    vhttBuffer = ghttRegcop:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRegcop:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhIordre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first regcop exclusive-lock
                where rowid(regcop) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer regcop:handle, 'tpcon/nocon/iOrdre: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhIordre:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer regcop:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRegcop private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer regcop for regcop.

    create query vhttquery.
    vhttBuffer = ghttRegcop:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRegcop:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create regcop.
            if not outils:copyValidField(buffer regcop:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRegcop private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhIordre    as handle  no-undo.
    define buffer regcop for regcop.

    create query vhttquery.
    vhttBuffer = ghttRegcop:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRegcop:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhIordre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first regcop exclusive-lock
                where rowid(Regcop) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer regcop:handle, 'tpcon/nocon/iOrdre: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhIordre:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete regcop no-error.
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

