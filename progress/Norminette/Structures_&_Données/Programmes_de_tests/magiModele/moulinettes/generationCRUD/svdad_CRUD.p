/*------------------------------------------------------------------------
File        : svdad_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table svdad
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/svdad.i}
{application/include/error.i}
define variable ghttsvdad as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoexo as handle, output phNodec as handle, output phNoent as handle, output phNorev as handle, output phNoact as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noexo/nodec/noent/norev/noact, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'nodec' then phNodec = phBuffer:buffer-field(vi).
            when 'noent' then phNoent = phBuffer:buffer-field(vi).
            when 'norev' then phNorev = phBuffer:buffer-field(vi).
            when 'noact' then phNoact = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSvdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSvdad.
    run updateSvdad.
    run createSvdad.
end procedure.

procedure setSvdad:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSvdad.
    ghttSvdad = phttSvdad.
    run crudSvdad.
    delete object phttSvdad.
end procedure.

procedure readSvdad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table svdad 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNoent as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoact as integer    no-undo.
    define input parameter table-handle phttSvdad.
    define variable vhttBuffer as handle no-undo.
    define buffer svdad for svdad.

    vhttBuffer = phttSvdad:default-buffer-handle.
    for first svdad no-lock
        where svdad.noexo = piNoexo
          and svdad.nodec = piNodec
          and svdad.noent = piNoent
          and svdad.norev = piNorev
          and svdad.noact = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvdad no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSvdad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table svdad 
    Notes  : service externe. Critère piNorev = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNoent as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter table-handle phttSvdad.
    define variable vhttBuffer as handle  no-undo.
    define buffer svdad for svdad.

    vhttBuffer = phttSvdad:default-buffer-handle.
    if piNorev = ?
    then for each svdad no-lock
        where svdad.noexo = piNoexo
          and svdad.nodec = piNodec
          and svdad.noent = piNoent:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each svdad no-lock
        where svdad.noexo = piNoexo
          and svdad.nodec = piNodec
          and svdad.noent = piNoent
          and svdad.norev = piNorev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer svdad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSvdad no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSvdad private:
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
    define variable vhNoact    as handle  no-undo.
    define buffer svdad for svdad.

    create query vhttquery.
    vhttBuffer = ghttSvdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSvdad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoexo, output vhNodec, output vhNoent, output vhNorev, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first svdad exclusive-lock
                where rowid(svdad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer svdad:handle, 'noexo/nodec/noent/norev/noact: ', substitute('&1/&2/&3/&4/&5', vhNoexo:buffer-value(), vhNodec:buffer-value(), vhNoent:buffer-value(), vhNorev:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer svdad:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSvdad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer svdad for svdad.

    create query vhttquery.
    vhttBuffer = ghttSvdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSvdad:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create svdad.
            if not outils:copyValidField(buffer svdad:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSvdad private:
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
    define variable vhNoact    as handle  no-undo.
    define buffer svdad for svdad.

    create query vhttquery.
    vhttBuffer = ghttSvdad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSvdad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoexo, output vhNodec, output vhNoent, output vhNorev, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first svdad exclusive-lock
                where rowid(Svdad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer svdad:handle, 'noexo/nodec/noent/norev/noact: ', substitute('&1/&2/&3/&4/&5', vhNoexo:buffer-value(), vhNodec:buffer-value(), vhNoent:buffer-value(), vhNorev:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete svdad no-error.
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

