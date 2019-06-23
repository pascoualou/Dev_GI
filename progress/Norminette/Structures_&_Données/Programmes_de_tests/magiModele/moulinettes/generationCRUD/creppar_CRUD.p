/*------------------------------------------------------------------------
File        : creppar_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table creppar
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/creppar.i}
{application/include/error.i}
define variable ghttcreppar as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCreppar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCreppar.
    run updateCreppar.
    run createCreppar.
end procedure.

procedure setCreppar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCreppar.
    ghttCreppar = phttCreppar.
    run crudCreppar.
    delete object phttCreppar.
end procedure.

procedure readCreppar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table creppar Parametres divers pour la comptabilisation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCreppar.
    define variable vhttBuffer as handle no-undo.
    define buffer creppar for creppar.

    vhttBuffer = phttCreppar:default-buffer-handle.
    for first creppar no-lock
        where creppar.soc-cd = piSoc-cd
          and creppar.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creppar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCreppar no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCreppar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table creppar Parametres divers pour la comptabilisation
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCreppar.
    define variable vhttBuffer as handle  no-undo.
    define buffer creppar for creppar.

    vhttBuffer = phttCreppar:default-buffer-handle.
    if piSoc-cd = ?
    then for each creppar no-lock
        where creppar.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creppar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each creppar no-lock
        where creppar.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creppar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCreppar no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCreppar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer creppar for creppar.

    create query vhttquery.
    vhttBuffer = ghttCreppar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCreppar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first creppar exclusive-lock
                where rowid(creppar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer creppar:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer creppar:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCreppar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer creppar for creppar.

    create query vhttquery.
    vhttBuffer = ghttCreppar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCreppar:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create creppar.
            if not outils:copyValidField(buffer creppar:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCreppar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer creppar for creppar.

    create query vhttquery.
    vhttBuffer = ghttCreppar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCreppar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first creppar exclusive-lock
                where rowid(Creppar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer creppar:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete creppar no-error.
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

