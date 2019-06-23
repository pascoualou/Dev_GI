/*------------------------------------------------------------------------
File        : LIMOD_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table LIMOD
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/LIMOD.i}
{application/include/error.i}
define variable ghttLIMOD as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phNomod as handle, output phNodot as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomod/nodot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomod' then phNomod = phBuffer:buffer-field(vi).
            when 'nodot' then phNodot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLimod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLimod.
    run updateLimod.
    run createLimod.
end procedure.

procedure setLimod:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLimod.
    ghttLimod = phttLimod.
    run crudLimod.
    delete object phttLimod.
end procedure.

procedure readLimod:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table LIMOD Lien mod doc & mod ss-dossier
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomod as integer    no-undo.
    define input parameter piNodot as integer    no-undo.
    define input parameter table-handle phttLimod.
    define variable vhttBuffer as handle no-undo.
    define buffer LIMOD for LIMOD.

    vhttBuffer = phttLimod:default-buffer-handle.
    for first LIMOD no-lock
        where LIMOD.nomod = piNomod
          and LIMOD.nodot = piNodot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIMOD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLimod no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLimod:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table LIMOD Lien mod doc & mod ss-dossier
    Notes  : service externe. Crit�re piNomod = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomod as integer    no-undo.
    define input parameter table-handle phttLimod.
    define variable vhttBuffer as handle  no-undo.
    define buffer LIMOD for LIMOD.

    vhttBuffer = phttLimod:default-buffer-handle.
    if piNomod = ?
    then for each LIMOD no-lock
        where LIMOD.nomod = piNomod:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIMOD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each LIMOD no-lock
        where LIMOD.nomod = piNomod:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIMOD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLimod no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLimod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomod    as handle  no-undo.
    define variable vhNodot    as handle  no-undo.
    define buffer LIMOD for LIMOD.

    create query vhttquery.
    vhttBuffer = ghttLimod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLimod:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomod, output vhNodot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LIMOD exclusive-lock
                where rowid(LIMOD) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LIMOD:handle, 'nomod/nodot: ', substitute('&1/&2', vhNomod:buffer-value(), vhNodot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer LIMOD:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLimod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer LIMOD for LIMOD.

    create query vhttquery.
    vhttBuffer = ghttLimod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLimod:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create LIMOD.
            if not outils:copyValidField(buffer LIMOD:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLimod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomod    as handle  no-undo.
    define variable vhNodot    as handle  no-undo.
    define buffer LIMOD for LIMOD.

    create query vhttquery.
    vhttBuffer = ghttLimod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLimod:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomod, output vhNodot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LIMOD exclusive-lock
                where rowid(Limod) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LIMOD:handle, 'nomod/nodot: ', substitute('&1/&2', vhNomod:buffer-value(), vhNodot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete LIMOD no-error.
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

