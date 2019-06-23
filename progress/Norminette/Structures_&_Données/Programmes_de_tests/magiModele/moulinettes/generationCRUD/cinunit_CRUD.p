/*------------------------------------------------------------------------
File        : cinunit_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinunit
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinunit.i}
{application/include/error.i}
define variable ghttcinunit as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phUnit-cd as handle, output phLib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur unit-cd/lib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'unit-cd' then phUnit-cd = phBuffer:buffer-field(vi).
            when 'lib' then phLib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinunit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinunit.
    run updateCinunit.
    run createCinunit.
end procedure.

procedure setCinunit:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinunit.
    ghttCinunit = phttCinunit.
    run crudCinunit.
    delete object phttCinunit.
end procedure.

procedure readCinunit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinunit Unités de valeurs immobilisations ifrs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcUnit-cd as character  no-undo.
    define input parameter pcLib     as character  no-undo.
    define input parameter table-handle phttCinunit.
    define variable vhttBuffer as handle no-undo.
    define buffer cinunit for cinunit.

    vhttBuffer = phttCinunit:default-buffer-handle.
    for first cinunit no-lock
        where cinunit.unit-cd = pcUnit-cd
          and cinunit.lib = pcLib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinunit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinunit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinunit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinunit Unités de valeurs immobilisations ifrs
    Notes  : service externe. Critère pcUnit-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcUnit-cd as character  no-undo.
    define input parameter table-handle phttCinunit.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinunit for cinunit.

    vhttBuffer = phttCinunit:default-buffer-handle.
    if pcUnit-cd = ?
    then for each cinunit no-lock
        where cinunit.unit-cd = pcUnit-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinunit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinunit no-lock
        where cinunit.unit-cd = pcUnit-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinunit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinunit no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinunit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhUnit-cd    as handle  no-undo.
    define variable vhLib    as handle  no-undo.
    define buffer cinunit for cinunit.

    create query vhttquery.
    vhttBuffer = ghttCinunit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinunit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhUnit-cd, output vhLib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinunit exclusive-lock
                where rowid(cinunit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinunit:handle, 'unit-cd/lib: ', substitute('&1/&2', vhUnit-cd:buffer-value(), vhLib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinunit:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinunit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinunit for cinunit.

    create query vhttquery.
    vhttBuffer = ghttCinunit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinunit:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinunit.
            if not outils:copyValidField(buffer cinunit:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinunit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhUnit-cd    as handle  no-undo.
    define variable vhLib    as handle  no-undo.
    define buffer cinunit for cinunit.

    create query vhttquery.
    vhttBuffer = ghttCinunit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinunit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhUnit-cd, output vhLib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinunit exclusive-lock
                where rowid(Cinunit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinunit:handle, 'unit-cd/lib: ', substitute('&1/&2', vhUnit-cd:buffer-value(), vhLib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinunit no-error.
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

