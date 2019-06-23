/*------------------------------------------------------------------------
File        : chdad_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table chdad
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/chdad.i}
{application/include/error.i}
define variable ghttchdad as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoexo as handle, output phNodec as handle, output phNoent as handle, output phNorev as handle, output phNoper as handle, output phIdtbl as handle, output phNotbl as handle, output phIdchp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noexo/nodec/noent/norev/noper/idtbl/notbl/idchp, 
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
            when 'idchp' then phIdchp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudChdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteChdad.
    run updateChdad.
    run createChdad.
end procedure.

procedure setChdad:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttChdad.
    ghttChdad = phttChdad.
    run crudChdad.
    delete object phttChdad.
end procedure.

procedure readChdad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table chdad 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNoent as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter pcIdtbl as character  no-undo.
    define input parameter piNotbl as integer    no-undo.
    define input parameter pcIdchp as character  no-undo.
    define input parameter table-handle phttChdad.
    define variable vhttBuffer as handle no-undo.
    define buffer chdad for chdad.

    vhttBuffer = phttChdad:default-buffer-handle.
    for first chdad no-lock
        where chdad.noexo = piNoexo
          and chdad.nodec = piNodec
          and chdad.noent = piNoent
          and chdad.norev = piNorev
          and chdad.noper = piNoper
          and chdad.idtbl = pcIdtbl
          and chdad.notbl = piNotbl
          and chdad.idchp = pcIdchp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChdad no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getChdad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table chdad 
    Notes  : service externe. Critère piNotbl = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNoent as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter pcIdtbl as character  no-undo.
    define input parameter piNotbl as integer    no-undo.
    define input parameter table-handle phttChdad.
    define variable vhttBuffer as handle  no-undo.
    define buffer chdad for chdad.

    vhttBuffer = phttChdad:default-buffer-handle.
    if piNotbl = ?
    then for each chdad no-lock
        where chdad.noexo = piNoexo
          and chdad.nodec = piNodec
          and chdad.noent = piNoent
          and chdad.norev = piNorev
          and chdad.noper = piNoper
          and chdad.idtbl = pcIdtbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each chdad no-lock
        where chdad.noexo = piNoexo
          and chdad.nodec = piNodec
          and chdad.noent = piNoent
          and chdad.norev = piNorev
          and chdad.noper = piNoper
          and chdad.idtbl = pcIdtbl
          and chdad.notbl = piNotbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChdad no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateChdad private:
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
    define variable vhIdchp    as handle  no-undo.
    define buffer chdad for chdad.

    create query vhttquery.
    vhttBuffer = ghttChdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttChdad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoexo, output vhNodec, output vhNoent, output vhNorev, output vhNoper, output vhIdtbl, output vhNotbl, output vhIdchp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first chdad exclusive-lock
                where rowid(chdad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer chdad:handle, 'noexo/nodec/noent/norev/noper/idtbl/notbl/idchp: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhNoexo:buffer-value(), vhNodec:buffer-value(), vhNoent:buffer-value(), vhNorev:buffer-value(), vhNoper:buffer-value(), vhIdtbl:buffer-value(), vhNotbl:buffer-value(), vhIdchp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer chdad:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createChdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer chdad for chdad.

    create query vhttquery.
    vhttBuffer = ghttChdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttChdad:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create chdad.
            if not outils:copyValidField(buffer chdad:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteChdad private:
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
    define variable vhIdchp    as handle  no-undo.
    define buffer chdad for chdad.

    create query vhttquery.
    vhttBuffer = ghttChdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttChdad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoexo, output vhNodec, output vhNoent, output vhNorev, output vhNoper, output vhIdtbl, output vhNotbl, output vhIdchp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first chdad exclusive-lock
                where rowid(Chdad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer chdad:handle, 'noexo/nodec/noent/norev/noper/idtbl/notbl/idchp: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhNoexo:buffer-value(), vhNodec:buffer-value(), vhNoent:buffer-value(), vhNorev:buffer-value(), vhNoper:buffer-value(), vhIdtbl:buffer-value(), vhNotbl:buffer-value(), vhIdchp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete chdad no-error.
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

