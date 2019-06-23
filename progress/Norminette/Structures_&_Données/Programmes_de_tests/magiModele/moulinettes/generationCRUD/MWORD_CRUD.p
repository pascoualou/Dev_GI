/*------------------------------------------------------------------------
File        : MWORD_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table MWORD
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/MWORD.i}
{application/include/error.i}
define variable ghttMWORD as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNonat as handle, output phNmdot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NONAT/NMDOT, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NONAT' then phNonat = phBuffer:buffer-field(vi).
            when 'NMDOT' then phNmdot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMword private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMword.
    run updateMword.
    run createMword.
end procedure.

procedure setMword:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMword.
    ghttMword = phttMword.
    run crudMword.
    delete object phttMword.
end procedure.

procedure readMword:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table MWORD 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNonat as integer    no-undo.
    define input parameter pcNmdot as character  no-undo.
    define input parameter table-handle phttMword.
    define variable vhttBuffer as handle no-undo.
    define buffer MWORD for MWORD.

    vhttBuffer = phttMword:default-buffer-handle.
    for first MWORD no-lock
        where MWORD.NONAT = piNonat
          and MWORD.NMDOT = pcNmdot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MWORD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMword no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMword:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table MWORD 
    Notes  : service externe. Critère piNonat = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNonat as integer    no-undo.
    define input parameter table-handle phttMword.
    define variable vhttBuffer as handle  no-undo.
    define buffer MWORD for MWORD.

    vhttBuffer = phttMword:default-buffer-handle.
    if piNonat = ?
    then for each MWORD no-lock
        where MWORD.NONAT = piNonat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MWORD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each MWORD no-lock
        where MWORD.NONAT = piNonat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MWORD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMword no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMword private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNonat    as handle  no-undo.
    define variable vhNmdot    as handle  no-undo.
    define buffer MWORD for MWORD.

    create query vhttquery.
    vhttBuffer = ghttMword:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMword:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNonat, output vhNmdot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MWORD exclusive-lock
                where rowid(MWORD) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MWORD:handle, 'NONAT/NMDOT: ', substitute('&1/&2', vhNonat:buffer-value(), vhNmdot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer MWORD:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMword private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer MWORD for MWORD.

    create query vhttquery.
    vhttBuffer = ghttMword:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMword:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create MWORD.
            if not outils:copyValidField(buffer MWORD:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMword private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNonat    as handle  no-undo.
    define variable vhNmdot    as handle  no-undo.
    define buffer MWORD for MWORD.

    create query vhttquery.
    vhttBuffer = ghttMword:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMword:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNonat, output vhNmdot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MWORD exclusive-lock
                where rowid(Mword) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MWORD:handle, 'NONAT/NMDOT: ', substitute('&1/&2', vhNonat:buffer-value(), vhNmdot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete MWORD no-error.
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

