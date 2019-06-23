/*------------------------------------------------------------------------
File        : abur1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table abur1
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttabur1 as handle no-undo.     // le handle de la temp table à mettre à jour

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

procedure crudAbur1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAbur1.
    run updateAbur1.
    run createAbur1.
end procedure.

procedure setAbur1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbur1.
    ghttAbur1 = phttAbur1.
    run crudAbur1.
    delete object phttAbur1.
end procedure.

procedure readAbur1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table abur1 Historique taxe de bureau (entete)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter viMandat   as integer no-undo.
    define input parameter viMandant  as integer no-undo.
    define input parameter viExercice as integer no-undo.
    define input parameter table-handle phttAbur1.
    define variable vhttBuffer    as handle  no-undo.
    define buffer abur1 for abur1.

    vhttBuffer = phttAbur1:default-buffer-handle.
    for first abur1 no-lock
        where abur1.nomdt = viMandat
          and abur1.noman = viMandant
          and abur1.cdexe = viExercice:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbur1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAbur1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table abur1 Historique taxe de bureau (entete)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter piMandat   as integer no-undo.
    define input parameter piMandant  as integer no-undo.
    define input parameter table-handle phttAbur1.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur1 for abur1.

    vhttBuffer = phttAbur1:default-buffer-handle.
    if piMandant = ?
    then for each abur1 no-lock
        where abur1.nomdt = piMandat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each abur1 no-lock
        where abur1.nomdt = piMandat
          and abur1.noman = piMandant:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbur1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAbur1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoman    as handle  no-undo.
    define buffer abur1 for abur1.

    create query vhttquery.
    vhttBuffer = ghttAbur1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAbur1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoman).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abur1 exclusive-lock
                where rowid(abur1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abur1:handle, 'nomdt/noman: ', substitute('&1/&2', vhNomdt:buffer-value(), vhNoman:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer abur1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAbur1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur1 for abur1.

    create query vhttquery.
    vhttBuffer = ghttAbur1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAbur1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create abur1.
            if not outils:copyValidField(buffer abur1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAbur1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoman    as handle  no-undo.
    define buffer abur1 for abur1.

    create query vhttquery.
    vhttBuffer = ghttAbur1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAbur1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoman).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abur1 exclusive-lock
                where rowid(Abur1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abur1:handle, 'nomdt/noman: ', substitute('&1/&2', vhNomdt:buffer-value(), vhNoman:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete abur1 no-error.
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

procedure deleteAbur1SurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.

    define buffer abur1 for abur1.

blocTrans:
    do transaction:
        for each abur1 exclusive-lock               // whole-index corrige par la creation dans la version d'un index sur nomdt
           where abur1.nomdt = piNumeroMandat:
            delete abur1 no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
