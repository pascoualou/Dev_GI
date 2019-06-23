/*------------------------------------------------------------------------
File        : prevoy_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table prevoy
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/prevoy.i}
{application/include/error.i}
define variable ghttprevoy as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppre as handle, output phNopre as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppre/nopre, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppre' then phTppre = phBuffer:buffer-field(vi).
            when 'nopre' then phNopre = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrevoy private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrevoy.
    run updatePrevoy.
    run createPrevoy.
end procedure.

procedure setPrevoy:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrevoy.
    ghttPrevoy = phttPrevoy.
    run crudPrevoy.
    delete object phttPrevoy.
end procedure.

procedure readPrevoy:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table prevoy Paie : Paramétrage des prévoyances 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppre as character  no-undo.
    define input parameter piNopre as integer    no-undo.
    define input parameter table-handle phttPrevoy.
    define variable vhttBuffer as handle no-undo.
    define buffer prevoy for prevoy.

    vhttBuffer = phttPrevoy:default-buffer-handle.
    for first prevoy no-lock
        where prevoy.tppre = pcTppre
          and prevoy.nopre = piNopre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prevoy:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrevoy no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrevoy:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table prevoy Paie : Paramétrage des prévoyances 
    Notes  : service externe. Critère pcTppre = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppre as character  no-undo.
    define input parameter table-handle phttPrevoy.
    define variable vhttBuffer as handle  no-undo.
    define buffer prevoy for prevoy.

    vhttBuffer = phttPrevoy:default-buffer-handle.
    if pcTppre = ?
    then for each prevoy no-lock
        where prevoy.tppre = pcTppre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prevoy:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each prevoy no-lock
        where prevoy.tppre = pcTppre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prevoy:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrevoy no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrevoy private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppre    as handle  no-undo.
    define variable vhNopre    as handle  no-undo.
    define buffer prevoy for prevoy.

    create query vhttquery.
    vhttBuffer = ghttPrevoy:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrevoy:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppre, output vhNopre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prevoy exclusive-lock
                where rowid(prevoy) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prevoy:handle, 'tppre/nopre: ', substitute('&1/&2', vhTppre:buffer-value(), vhNopre:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer prevoy:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrevoy private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer prevoy for prevoy.

    create query vhttquery.
    vhttBuffer = ghttPrevoy:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrevoy:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create prevoy.
            if not outils:copyValidField(buffer prevoy:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrevoy private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppre    as handle  no-undo.
    define variable vhNopre    as handle  no-undo.
    define buffer prevoy for prevoy.

    create query vhttquery.
    vhttBuffer = ghttPrevoy:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrevoy:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppre, output vhNopre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prevoy exclusive-lock
                where rowid(Prevoy) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prevoy:handle, 'tppre/nopre: ', substitute('&1/&2', vhTppre:buffer-value(), vhNopre:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete prevoy no-error.
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

