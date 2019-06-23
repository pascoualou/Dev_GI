/*------------------------------------------------------------------------
File        : adbtvah_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table adbtvah
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/adbtvah.i}
{application/include/error.i}
define variable ghttadbtvah as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phDahist as handle, output phChrono as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/dahist/chrono, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'dahist' then phDahist = phBuffer:buffer-field(vi).
            when 'chrono' then phChrono = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAdbtvah private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAdbtvah.
    run updateAdbtvah.
    run createAdbtvah.
end procedure.

procedure setAdbtvah:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdbtvah.
    ghttAdbtvah = phttAdbtvah.
    run crudAdbtvah.
    delete object phttAdbtvah.
end procedure.

procedure readAdbtvah:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table adbtvah 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pdaDahist  as date       no-undo.
    define input parameter piChrono  as integer    no-undo.
    define input parameter table-handle phttAdbtvah.
    define variable vhttBuffer as handle no-undo.
    define buffer adbtvah for adbtvah.

    vhttBuffer = phttAdbtvah:default-buffer-handle.
    for first adbtvah no-lock
        where adbtvah.soc-cd = piSoc-cd
          and adbtvah.etab-cd = piEtab-cd
          and adbtvah.dahist = pdaDahist
          and adbtvah.chrono = piChrono:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adbtvah:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdbtvah no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAdbtvah:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table adbtvah 
    Notes  : service externe. Critère pdaDahist = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pdaDahist  as date       no-undo.
    define input parameter table-handle phttAdbtvah.
    define variable vhttBuffer as handle  no-undo.
    define buffer adbtvah for adbtvah.

    vhttBuffer = phttAdbtvah:default-buffer-handle.
    if pdaDahist = ?
    then for each adbtvah no-lock
        where adbtvah.soc-cd = piSoc-cd
          and adbtvah.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adbtvah:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each adbtvah no-lock
        where adbtvah.soc-cd = piSoc-cd
          and adbtvah.etab-cd = piEtab-cd
          and adbtvah.dahist = pdaDahist:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adbtvah:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdbtvah no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAdbtvah private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDahist    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define buffer adbtvah for adbtvah.

    create query vhttquery.
    vhttBuffer = ghttAdbtvah:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAdbtvah:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDahist, output vhChrono).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adbtvah exclusive-lock
                where rowid(adbtvah) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adbtvah:handle, 'soc-cd/etab-cd/dahist/chrono: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDahist:buffer-value(), vhChrono:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer adbtvah:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAdbtvah private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer adbtvah for adbtvah.

    create query vhttquery.
    vhttBuffer = ghttAdbtvah:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAdbtvah:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create adbtvah.
            if not outils:copyValidField(buffer adbtvah:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAdbtvah private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDahist    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define buffer adbtvah for adbtvah.

    create query vhttquery.
    vhttBuffer = ghttAdbtvah:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAdbtvah:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDahist, output vhChrono).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adbtvah exclusive-lock
                where rowid(Adbtvah) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adbtvah:handle, 'soc-cd/etab-cd/dahist/chrono: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDahist:buffer-value(), vhChrono:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete adbtvah no-error.
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

