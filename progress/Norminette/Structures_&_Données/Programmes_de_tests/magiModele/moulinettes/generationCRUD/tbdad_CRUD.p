/*------------------------------------------------------------------------
File        : tbdad_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tbdad
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tbdad.i}
{application/include/error.i}
define variable ghtttbdad as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoexo as handle, output phNodec as handle, output phNoent as handle, output phNorev as handle, output phNoper as handle, output phIdtbl as handle, output phNotbl as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noexo/nodec/noent/norev/noper/idtbl/notbl, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'nodec' then phNodec = phBuffer:buffer-field(vi).
            when 'noent' then phNoent = phBuffer:buffer-field(vi).
            when 'norev' then phNorev = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
            when 'idtbl' then phIdtbl = phBuffer:buffer-field(vi).
            when 'notbl' then phNotbl = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTbdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTbdad.
    run updateTbdad.
    run createTbdad.
end procedure.

procedure setTbdad:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTbdad.
    ghttTbdad = phttTbdad.
    run crudTbdad.
    delete object phttTbdad.
end procedure.

procedure readTbdad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tbdad 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNoent as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter pcIdtbl as character  no-undo.
    define input parameter piNotbl as integer    no-undo.
    define input parameter table-handle phttTbdad.
    define variable vhttBuffer as handle no-undo.
    define buffer tbdad for tbdad.

    vhttBuffer = phttTbdad:default-buffer-handle.
    for first tbdad no-lock
        where tbdad.noexo = piNoexo
          and tbdad.nodec = piNodec
          and tbdad.noent = piNoent
          and tbdad.norev = piNorev
          and tbdad.noper = piNoper
          and tbdad.idtbl = pcIdtbl
          and tbdad.notbl = piNotbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbdad no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTbdad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tbdad 
    Notes  : service externe. Critère pcIdtbl = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNoent as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter pcIdtbl as character  no-undo.
    define input parameter table-handle phttTbdad.
    define variable vhttBuffer as handle  no-undo.
    define buffer tbdad for tbdad.

    vhttBuffer = phttTbdad:default-buffer-handle.
    if pcIdtbl = ?
    then for each tbdad no-lock
        where tbdad.noexo = piNoexo
          and tbdad.nodec = piNodec
          and tbdad.noent = piNoent
          and tbdad.norev = piNorev
          and tbdad.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tbdad no-lock
        where tbdad.noexo = piNoexo
          and tbdad.nodec = piNodec
          and tbdad.noent = piNoent
          and tbdad.norev = piNorev
          and tbdad.noper = piNoper
          and tbdad.idtbl = pcIdtbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbdad no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTbdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNodec    as handle  no-undo.
    define variable vhNoent    as handle  no-undo.
    define variable vhNorev    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhIdtbl    as handle  no-undo.
    define variable vhNotbl    as handle  no-undo.
    define buffer tbdad for tbdad.

    create query vhttquery.
    vhttBuffer = ghttTbdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTbdad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoexo, output vhNodec, output vhNoent, output vhNorev, output vhNoper, output vhIdtbl, output vhNotbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbdad exclusive-lock
                where rowid(tbdad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbdad:handle, 'noexo/nodec/noent/norev/noper/idtbl/notbl: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhNoexo:buffer-value(), vhNodec:buffer-value(), vhNoent:buffer-value(), vhNorev:buffer-value(), vhNoper:buffer-value(), vhIdtbl:buffer-value(), vhNotbl:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tbdad:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTbdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tbdad for tbdad.

    create query vhttquery.
    vhttBuffer = ghttTbdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTbdad:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tbdad.
            if not outils:copyValidField(buffer tbdad:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTbdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNodec    as handle  no-undo.
    define variable vhNoent    as handle  no-undo.
    define variable vhNorev    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhIdtbl    as handle  no-undo.
    define variable vhNotbl    as handle  no-undo.
    define buffer tbdad for tbdad.

    create query vhttquery.
    vhttBuffer = ghttTbdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTbdad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoexo, output vhNodec, output vhNoent, output vhNorev, output vhNoper, output vhIdtbl, output vhNotbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbdad exclusive-lock
                where rowid(Tbdad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbdad:handle, 'noexo/nodec/noent/norev/noper/idtbl/notbl: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhNoexo:buffer-value(), vhNodec:buffer-value(), vhNoent:buffer-value(), vhNorev:buffer-value(), vhNoper:buffer-value(), vhIdtbl:buffer-value(), vhNotbl:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tbdad no-error.
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

