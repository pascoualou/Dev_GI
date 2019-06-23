/*------------------------------------------------------------------------
File        : abur2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table abur2
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttabur2 as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNoman as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when "nomdt" then phNomdt = phBuffer:buffer-field(vi).
            when "noman" then phNoman = phBuffer:buffer-field(vi).
        end case.
    end.
end function.

procedure crudabur2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteabur2.
    run updateabur2.
    run createabur2.
end procedure.

procedure setabur2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttabur2.
    ghttabur2 = phttabur2.
    run crudabur2.
    delete object phttabur2.
end procedure.

procedure readabur2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table abur2 Historique taxe de bureau (entete)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter viMandat   as integer no-undo.
    define input parameter viMandant  as integer no-undo.
    define input parameter viExercice as integer no-undo.
    define input parameter table-handle phttabur2.
    define variable vhttBuffer    as handle  no-undo.
    define buffer abur2 for abur2.

    vhttBuffer = phttabur2:default-buffer-handle.
    for first abur2 no-lock
        where abur2.nomdt = viMandat
          and abur2.noman = viMandant
          and abur2.cdexe = viExercice:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttabur2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getabur2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table abur2 Historique taxe de bureau (entete)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter piMandat   as integer no-undo.
    define input parameter piMandant  as integer no-undo.
    define input parameter table-handle phttabur2.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur2 for abur2.

    vhttBuffer = phttabur2:default-buffer-handle.
    if piMandant = ?
    then for each abur2 no-lock
        where abur2.nomdt = piMandat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each abur2 no-lock
        where abur2.nomdt = piMandat
          and abur2.noman = piMandant:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttabur2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateabur2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoman    as handle  no-undo.
    define buffer abur2 for abur2.

    create query vhttquery.
    vhttBuffer = ghttabur2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttabur2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoman).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abur2 exclusive-lock
                where rowid(abur2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abur2:handle, 'nomdt/noman: ', substitute('&1/&2', vhNomdt:buffer-value(), vhNoman:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer abur2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createabur2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur2 for abur2.

    create query vhttquery.
    vhttBuffer = ghttabur2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttabur2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create abur2.
            if not outils:copyValidField(buffer abur2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteabur2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoman    as handle  no-undo.
    define buffer abur2 for abur2.

    create query vhttquery.
    vhttBuffer = ghttabur2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttabur2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoman).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abur2 exclusive-lock
                where rowid(abur2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abur2:handle, 'nomdt/noman: ', substitute('&1/&2', vhNomdt:buffer-value(), vhNoman:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete abur2 no-error.
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

procedure deleteabur2SurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.

    define buffer abur2 for abur2.

blocTrans:
    do transaction:
        for each abur2 exclusive-lock                         // whole-index corrige par la creation dans la version d'un index sur nomdt
           where abur2.nomdt = piNumeroMandat:
            delete abur2 no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
