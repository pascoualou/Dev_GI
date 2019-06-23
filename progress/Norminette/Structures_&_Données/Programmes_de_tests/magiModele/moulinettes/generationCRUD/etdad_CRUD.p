/*------------------------------------------------------------------------
File        : etdad_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table etdad
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/etdad.i}
{application/include/error.i}
define variable ghttetdad as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoexo as handle, output phNodec as handle, output phNoent as handle, output phNorev as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noexo/nodec/noent/norev, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'nodec' then phNodec = phBuffer:buffer-field(vi).
            when 'noent' then phNoent = phBuffer:buffer-field(vi).
            when 'norev' then phNorev = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEtdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEtdad.
    run updateEtdad.
    run createEtdad.
end procedure.

procedure setEtdad:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEtdad.
    ghttEtdad = phttEtdad.
    run crudEtdad.
    delete object phttEtdad.
end procedure.

procedure readEtdad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table etdad 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNoent as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter table-handle phttEtdad.
    define variable vhttBuffer as handle no-undo.
    define buffer etdad for etdad.

    vhttBuffer = phttEtdad:default-buffer-handle.
    for first etdad no-lock
        where etdad.noexo = piNoexo
          and etdad.nodec = piNodec
          and etdad.noent = piNoent
          and etdad.norev = piNorev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtdad no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEtdad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table etdad 
    Notes  : service externe. Critère piNoent = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNoent as integer    no-undo.
    define input parameter table-handle phttEtdad.
    define variable vhttBuffer as handle  no-undo.
    define buffer etdad for etdad.

    vhttBuffer = phttEtdad:default-buffer-handle.
    if piNoent = ?
    then for each etdad no-lock
        where etdad.noexo = piNoexo
          and etdad.nodec = piNodec:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each etdad no-lock
        where etdad.noexo = piNoexo
          and etdad.nodec = piNodec
          and etdad.noent = piNoent:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtdad no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEtdad private:
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
    define buffer etdad for etdad.

    create query vhttquery.
    vhttBuffer = ghttEtdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEtdad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoexo, output vhNodec, output vhNoent, output vhNorev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etdad exclusive-lock
                where rowid(etdad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etdad:handle, 'noexo/nodec/noent/norev: ', substitute('&1/&2/&3/&4', vhNoexo:buffer-value(), vhNodec:buffer-value(), vhNoent:buffer-value(), vhNorev:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer etdad:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEtdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer etdad for etdad.

    create query vhttquery.
    vhttBuffer = ghttEtdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEtdad:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create etdad.
            if not outils:copyValidField(buffer etdad:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEtdad private:
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
    define buffer etdad for etdad.

    create query vhttquery.
    vhttBuffer = ghttEtdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEtdad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoexo, output vhNodec, output vhNoent, output vhNorev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etdad exclusive-lock
                where rowid(Etdad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etdad:handle, 'noexo/nodec/noent/norev: ', substitute('&1/&2/&3/&4', vhNoexo:buffer-value(), vhNodec:buffer-value(), vhNoent:buffer-value(), vhNorev:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete etdad no-error.
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

