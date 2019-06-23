/*------------------------------------------------------------------------
File        : cteur_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cteur
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cteur.i}
{application/include/error.i}
define variable ghttcteur as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phNolot as handle, output phTpcpt as handle, output phNocpt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/nolot/TpCpt/nocpt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'TpCpt' then phTpcpt = phBuffer:buffer-field(vi).
            when 'nocpt' then phNocpt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCteur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCteur.
    run updateCteur.
    run createCteur.
end procedure.

procedure setCteur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCteur.
    ghttCteur = phttCteur.
    run crudCteur.
    delete object phttCteur.
end procedure.

procedure readCteur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cteur 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pcTpcpt as character  no-undo.
    define input parameter pcNocpt as character  no-undo.
    define input parameter table-handle phttCteur.
    define variable vhttBuffer as handle no-undo.
    define buffer cteur for cteur.

    vhttBuffer = phttCteur:default-buffer-handle.
    for first cteur no-lock
        where cteur.noimm = piNoimm
          and cteur.nolot = piNolot
          and cteur.TpCpt = pcTpcpt
          and cteur.nocpt = pcNocpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cteur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCteur no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCteur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cteur 
    Notes  : service externe. Critère pcTpcpt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pcTpcpt as character  no-undo.
    define input parameter table-handle phttCteur.
    define variable vhttBuffer as handle  no-undo.
    define buffer cteur for cteur.

    vhttBuffer = phttCteur:default-buffer-handle.
    if pcTpcpt = ?
    then for each cteur no-lock
        where cteur.noimm = piNoimm
          and cteur.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cteur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cteur no-lock
        where cteur.noimm = piNoimm
          and cteur.nolot = piNolot
          and cteur.TpCpt = pcTpcpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cteur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCteur no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCteur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhTpcpt    as handle  no-undo.
    define variable vhNocpt    as handle  no-undo.
    define buffer cteur for cteur.

    create query vhttquery.
    vhttBuffer = ghttCteur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCteur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNolot, output vhTpcpt, output vhNocpt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cteur exclusive-lock
                where rowid(cteur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cteur:handle, 'noimm/nolot/TpCpt/nocpt: ', substitute('&1/&2/&3/&4', vhNoimm:buffer-value(), vhNolot:buffer-value(), vhTpcpt:buffer-value(), vhNocpt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cteur:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCteur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cteur for cteur.

    create query vhttquery.
    vhttBuffer = ghttCteur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCteur:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cteur.
            if not outils:copyValidField(buffer cteur:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCteur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhTpcpt    as handle  no-undo.
    define variable vhNocpt    as handle  no-undo.
    define buffer cteur for cteur.

    create query vhttquery.
    vhttBuffer = ghttCteur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCteur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNolot, output vhTpcpt, output vhNocpt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cteur exclusive-lock
                where rowid(Cteur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cteur:handle, 'noimm/nolot/TpCpt/nocpt: ', substitute('&1/&2/&3/&4', vhNoimm:buffer-value(), vhNolot:buffer-value(), vhTpcpt:buffer-value(), vhNocpt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cteur no-error.
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

