/*------------------------------------------------------------------------
File        : mutuel_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table mutuel
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/mutuel.i}
{application/include/error.i}
define variable ghttmutuel as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpmut as handle, output phNomut as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpmut/nomut, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpmut' then phTpmut = phBuffer:buffer-field(vi).
            when 'nomut' then phNomut = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMutuel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMutuel.
    run updateMutuel.
    run createMutuel.
end procedure.

procedure setMutuel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMutuel.
    ghttMutuel = phttMutuel.
    run crudMutuel.
    delete object phttMutuel.
end procedure.

procedure readMutuel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table mutuel Paie : Paramétrage des mutuelles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmut as character  no-undo.
    define input parameter piNomut as integer    no-undo.
    define input parameter table-handle phttMutuel.
    define variable vhttBuffer as handle no-undo.
    define buffer mutuel for mutuel.

    vhttBuffer = phttMutuel:default-buffer-handle.
    for first mutuel no-lock
        where mutuel.tpmut = pcTpmut
          and mutuel.nomut = piNomut:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mutuel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMutuel no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMutuel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table mutuel Paie : Paramétrage des mutuelles
    Notes  : service externe. Critère pcTpmut = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmut as character  no-undo.
    define input parameter table-handle phttMutuel.
    define variable vhttBuffer as handle  no-undo.
    define buffer mutuel for mutuel.

    vhttBuffer = phttMutuel:default-buffer-handle.
    if pcTpmut = ?
    then for each mutuel no-lock
        where mutuel.tpmut = pcTpmut:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mutuel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each mutuel no-lock
        where mutuel.tpmut = pcTpmut:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mutuel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMutuel no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMutuel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmut    as handle  no-undo.
    define variable vhNomut    as handle  no-undo.
    define buffer mutuel for mutuel.

    create query vhttquery.
    vhttBuffer = ghttMutuel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMutuel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmut, output vhNomut).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first mutuel exclusive-lock
                where rowid(mutuel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer mutuel:handle, 'tpmut/nomut: ', substitute('&1/&2', vhTpmut:buffer-value(), vhNomut:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer mutuel:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMutuel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer mutuel for mutuel.

    create query vhttquery.
    vhttBuffer = ghttMutuel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMutuel:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create mutuel.
            if not outils:copyValidField(buffer mutuel:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMutuel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmut    as handle  no-undo.
    define variable vhNomut    as handle  no-undo.
    define buffer mutuel for mutuel.

    create query vhttquery.
    vhttBuffer = ghttMutuel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMutuel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmut, output vhNomut).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first mutuel exclusive-lock
                where rowid(Mutuel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer mutuel:handle, 'tpmut/nomut: ', substitute('&1/&2', vhTpmut:buffer-value(), vhNomut:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete mutuel no-error.
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

