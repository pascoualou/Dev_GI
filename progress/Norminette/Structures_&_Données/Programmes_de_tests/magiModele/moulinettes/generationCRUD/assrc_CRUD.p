/*------------------------------------------------------------------------
File        : assrc_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table assrc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/assrc.i}
{application/include/error.i}
define variable ghttassrc as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phCdrub as handle, output phCdlib as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/cdrub/cdlib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdlib' then phCdlib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAssrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAssrc.
    run updateAssrc.
    run createAssrc.
end procedure.

procedure setAssrc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAssrc.
    ghttAssrc = phttAssrc.
    run crudAssrc.
    delete object phttAssrc.
end procedure.

procedure readAssrc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table assrc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter piCdlib as integer    no-undo.
    define input parameter table-handle phttAssrc.
    define variable vhttBuffer as handle no-undo.
    define buffer assrc for assrc.

    vhttBuffer = phttAssrc:default-buffer-handle.
    for first assrc no-lock
        where assrc.nomdt = piNomdt
          and assrc.cdrub = piCdrub
          and assrc.cdlib = piCdlib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAssrc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAssrc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table assrc 
    Notes  : service externe. Crit�re piCdrub = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter table-handle phttAssrc.
    define variable vhttBuffer as handle  no-undo.
    define buffer assrc for assrc.

    vhttBuffer = phttAssrc:default-buffer-handle.
    if piCdrub = ?
    then for each assrc no-lock
        where assrc.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each assrc no-lock
        where assrc.nomdt = piNomdt
          and assrc.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAssrc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAssrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define buffer assrc for assrc.

    create query vhttquery.
    vhttBuffer = ghttAssrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAssrc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first assrc exclusive-lock
                where rowid(assrc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer assrc:handle, 'nomdt/cdrub/cdlib: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer assrc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAssrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer assrc for assrc.

    create query vhttquery.
    vhttBuffer = ghttAssrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAssrc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create assrc.
            if not outils:copyValidField(buffer assrc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAssrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define buffer assrc for assrc.

    create query vhttquery.
    vhttBuffer = ghttAssrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAssrc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first assrc exclusive-lock
                where rowid(Assrc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer assrc:handle, 'nomdt/cdrub/cdlib: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete assrc no-error.
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

