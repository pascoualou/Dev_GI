/*------------------------------------------------------------------------
File        : scinddet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scinddet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scinddet.i}
{application/include/error.i}
define variable ghttscinddet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoind as handle, output phNolig as handle, output phNopos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noind/nolig/nopos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noind' then phNoind = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
            when 'nopos' then phNopos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScinddet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScinddet.
    run updateScinddet.
    run createScinddet.
end procedure.

procedure setScinddet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScinddet.
    ghttScinddet = phttScinddet.
    run crudScinddet.
    delete object phttScinddet.
end procedure.

procedure readScinddet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scinddet Décomposition d'une indivision
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoind as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter piNopos as integer    no-undo.
    define input parameter table-handle phttScinddet.
    define variable vhttBuffer as handle no-undo.
    define buffer scinddet for scinddet.

    vhttBuffer = phttScinddet:default-buffer-handle.
    for first scinddet no-lock
        where scinddet.noind = piNoind
          and scinddet.nolig = piNolig
          and scinddet.nopos = piNopos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scinddet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScinddet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScinddet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scinddet Décomposition d'une indivision
    Notes  : service externe. Critère piNolig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoind as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttScinddet.
    define variable vhttBuffer as handle  no-undo.
    define buffer scinddet for scinddet.

    vhttBuffer = phttScinddet:default-buffer-handle.
    if piNolig = ?
    then for each scinddet no-lock
        where scinddet.noind = piNoind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scinddet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scinddet no-lock
        where scinddet.noind = piNoind
          and scinddet.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scinddet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScinddet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScinddet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoind    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhNopos    as handle  no-undo.
    define buffer scinddet for scinddet.

    create query vhttquery.
    vhttBuffer = ghttScinddet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScinddet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoind, output vhNolig, output vhNopos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scinddet exclusive-lock
                where rowid(scinddet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scinddet:handle, 'noind/nolig/nopos: ', substitute('&1/&2/&3', vhNoind:buffer-value(), vhNolig:buffer-value(), vhNopos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scinddet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScinddet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scinddet for scinddet.

    create query vhttquery.
    vhttBuffer = ghttScinddet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScinddet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scinddet.
            if not outils:copyValidField(buffer scinddet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScinddet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoind    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhNopos    as handle  no-undo.
    define buffer scinddet for scinddet.

    create query vhttquery.
    vhttBuffer = ghttScinddet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScinddet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoind, output vhNolig, output vhNopos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scinddet exclusive-lock
                where rowid(Scinddet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scinddet:handle, 'noind/nolig/nopos: ', substitute('&1/&2/&3', vhNoind:buffer-value(), vhNolig:buffer-value(), vhNopos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scinddet no-error.
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

