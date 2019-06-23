/*------------------------------------------------------------------------
File        : LIDES_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table LIDES
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/LIDES.i}
{application/include/error.i}
define variable ghttLIDES as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNochp as handle, output phNodoc as handle, output phTprol as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nochp/nodoc/tprol/norol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
            when 'nodoc' then phNodoc = phBuffer:buffer-field(vi).
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLides private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLides.
    run updateLides.
    run createLides.
end procedure.

procedure setLides:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLides.
    ghttLides = phttLides.
    run crudLides.
    delete object phttLides.
end procedure.

procedure readLides:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table LIDES Lien destinataire & champ
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNochp as integer    no-undo.
    define input parameter piNodoc as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as integer    no-undo.
    define input parameter table-handle phttLides.
    define variable vhttBuffer as handle no-undo.
    define buffer LIDES for LIDES.

    vhttBuffer = phttLides:default-buffer-handle.
    for first LIDES no-lock
        where LIDES.nochp = piNochp
          and LIDES.nodoc = piNodoc
          and LIDES.tprol = pcTprol
          and LIDES.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIDES:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLides no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLides:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table LIDES Lien destinataire & champ
    Notes  : service externe. Critère pcTprol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNochp as integer    no-undo.
    define input parameter piNodoc as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter table-handle phttLides.
    define variable vhttBuffer as handle  no-undo.
    define buffer LIDES for LIDES.

    vhttBuffer = phttLides:default-buffer-handle.
    if pcTprol = ?
    then for each LIDES no-lock
        where LIDES.nochp = piNochp
          and LIDES.nodoc = piNodoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIDES:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each LIDES no-lock
        where LIDES.nochp = piNochp
          and LIDES.nodoc = piNodoc
          and LIDES.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIDES:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLides no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLides private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer LIDES for LIDES.

    create query vhttquery.
    vhttBuffer = ghttLides:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLides:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp, output vhNodoc, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LIDES exclusive-lock
                where rowid(LIDES) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LIDES:handle, 'nochp/nodoc/tprol/norol: ', substitute('&1/&2/&3/&4', vhNochp:buffer-value(), vhNodoc:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer LIDES:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLides private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer LIDES for LIDES.

    create query vhttquery.
    vhttBuffer = ghttLides:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLides:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create LIDES.
            if not outils:copyValidField(buffer LIDES:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLides private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer LIDES for LIDES.

    create query vhttquery.
    vhttBuffer = ghttLides:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLides:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp, output vhNodoc, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LIDES exclusive-lock
                where rowid(Lides) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LIDES:handle, 'nochp/nodoc/tprol/norol: ', substitute('&1/&2/&3/&4', vhNochp:buffer-value(), vhNodoc:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete LIDES no-error.
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

