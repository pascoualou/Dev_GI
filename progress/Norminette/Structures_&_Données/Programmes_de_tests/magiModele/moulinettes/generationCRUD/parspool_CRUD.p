/*------------------------------------------------------------------------
File        : parspool_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table parspool
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/parspool.i}
{application/include/error.i}
define variable ghttparspool as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSpool-pref as handle, output phSpool-prog as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur spool-pref/spool-prog, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'spool-pref' then phSpool-pref = phBuffer:buffer-field(vi).
            when 'spool-prog' then phSpool-prog = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudParspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteParspool.
    run updateParspool.
    run createParspool.
end procedure.

procedure setParspool:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParspool.
    ghttParspool = phttParspool.
    run crudParspool.
    delete object phttParspool.
end procedure.

procedure readParspool:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table parspool Parametrage Spool G.I.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcSpool-pref as character  no-undo.
    define input parameter pcSpool-prog as character  no-undo.
    define input parameter table-handle phttParspool.
    define variable vhttBuffer as handle no-undo.
    define buffer parspool for parspool.

    vhttBuffer = phttParspool:default-buffer-handle.
    for first parspool no-lock
        where parspool.spool-pref = pcSpool-pref
          and parspool.spool-prog = pcSpool-prog:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parspool:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParspool no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getParspool:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table parspool Parametrage Spool G.I.
    Notes  : service externe. Critère pcSpool-pref = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcSpool-pref as character  no-undo.
    define input parameter table-handle phttParspool.
    define variable vhttBuffer as handle  no-undo.
    define buffer parspool for parspool.

    vhttBuffer = phttParspool:default-buffer-handle.
    if pcSpool-pref = ?
    then for each parspool no-lock
        where parspool.spool-pref = pcSpool-pref:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parspool:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each parspool no-lock
        where parspool.spool-pref = pcSpool-pref:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parspool:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParspool no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateParspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSpool-pref    as handle  no-undo.
    define variable vhSpool-prog    as handle  no-undo.
    define buffer parspool for parspool.

    create query vhttquery.
    vhttBuffer = ghttParspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttParspool:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSpool-pref, output vhSpool-prog).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parspool exclusive-lock
                where rowid(parspool) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parspool:handle, 'spool-pref/spool-prog: ', substitute('&1/&2', vhSpool-pref:buffer-value(), vhSpool-prog:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer parspool:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createParspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer parspool for parspool.

    create query vhttquery.
    vhttBuffer = ghttParspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttParspool:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create parspool.
            if not outils:copyValidField(buffer parspool:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteParspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSpool-pref    as handle  no-undo.
    define variable vhSpool-prog    as handle  no-undo.
    define buffer parspool for parspool.

    create query vhttquery.
    vhttBuffer = ghttParspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttParspool:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSpool-pref, output vhSpool-prog).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parspool exclusive-lock
                where rowid(Parspool) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parspool:handle, 'spool-pref/spool-prog: ', substitute('&1/&2', vhSpool-pref:buffer-value(), vhSpool-prog:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete parspool no-error.
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

