/*------------------------------------------------------------------------
File        : FreReEt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table FreReEt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/FreReEt.i}
{application/include/error.i}
define variable ghttFreReEt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoexo as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noexo, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFrereet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFrereet.
    run updateFrereet.
    run createFrereet.
end procedure.

procedure setFrereet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFrereet.
    ghttFrereet = phttFrereet.
    run crudFrereet.
    delete object phttFrereet.
end procedure.

procedure readFrereet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table FreReEt RIE : tableau  des fréquentations réelles (entete)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter table-handle phttFrereet.
    define variable vhttBuffer as handle no-undo.
    define buffer FreReEt for FreReEt.

    vhttBuffer = phttFrereet:default-buffer-handle.
    for first FreReEt no-lock
        where FreReEt.tpcon = pcTpcon
          and FreReEt.nocon = piNocon
          and FreReEt.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer FreReEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrereet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFrereet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table FreReEt RIE : tableau  des fréquentations réelles (entete)
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttFrereet.
    define variable vhttBuffer as handle  no-undo.
    define buffer FreReEt for FreReEt.

    vhttBuffer = phttFrereet:default-buffer-handle.
    if piNocon = ?
    then for each FreReEt no-lock
        where FreReEt.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer FreReEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each FreReEt no-lock
        where FreReEt.tpcon = pcTpcon
          and FreReEt.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer FreReEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrereet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFrereet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define buffer FreReEt for FreReEt.

    create query vhttquery.
    vhttBuffer = ghttFrereet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFrereet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first FreReEt exclusive-lock
                where rowid(FreReEt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer FreReEt:handle, 'tpcon/nocon/noexo: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer FreReEt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFrereet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer FreReEt for FreReEt.

    create query vhttquery.
    vhttBuffer = ghttFrereet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFrereet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create FreReEt.
            if not outils:copyValidField(buffer FreReEt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFrereet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define buffer FreReEt for FreReEt.

    create query vhttquery.
    vhttBuffer = ghttFrereet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFrereet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first FreReEt exclusive-lock
                where rowid(Frereet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer FreReEt:handle, 'tpcon/nocon/noexo: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete FreReEt no-error.
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

