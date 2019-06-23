/*------------------------------------------------------------------------
File        : avnad_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table avnad
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttavnad as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoann as handle, output phCdmat as handle, output phNomdt as handle, output phNoapp as handle, output phCduni as handle, output phCdreg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noann/cdmat/nomdt/noapp/cduni/cdreg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noann' then phNoann = phBuffer:buffer-field(vi).
            when 'cdmat' then phCdmat = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'cduni' then phCduni = phBuffer:buffer-field(vi).
            when 'cdreg' then phCdreg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAvnad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAvnad.
    run updateAvnad.
    run createAvnad.
end procedure.

procedure setAvnad:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAvnad.
    ghttAvnad = phttAvnad.
    run crudAvnad.
    delete object phttAvnad.
end procedure.

procedure readAvnad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table avnad Avantages en nature (dÃ©tail)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoann as integer    no-undo.
    define input parameter pcCdmat as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter pcCduni as character  no-undo.
    define input parameter pcCdreg as character  no-undo.
    define input parameter table-handle phttAvnad.
    define variable vhttBuffer as handle no-undo.
    define buffer avnad for avnad.

    vhttBuffer = phttAvnad:default-buffer-handle.
    for first avnad no-lock
        where avnad.noann = piNoann
          and avnad.cdmat = pcCdmat
          and avnad.nomdt = piNomdt
          and avnad.noapp = piNoapp
          and avnad.cduni = pcCduni
          and avnad.cdreg = pcCdreg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer avnad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAvnad no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAvnad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table avnad Avantages en nature (dÃ©tail)
    Notes  : service externe. Critère pcCduni = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoann as integer    no-undo.
    define input parameter pcCdmat as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter pcCduni as character  no-undo.
    define input parameter table-handle phttAvnad.
    define variable vhttBuffer as handle  no-undo.
    define buffer avnad for avnad.

    vhttBuffer = phttAvnad:default-buffer-handle.
    if pcCduni = ?
    then for each avnad no-lock
        where avnad.noann = piNoann
          and avnad.cdmat = pcCdmat
          and avnad.nomdt = piNomdt
          and avnad.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer avnad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each avnad no-lock
        where avnad.noann = piNoann
          and avnad.cdmat = pcCdmat
          and avnad.nomdt = piNomdt
          and avnad.noapp = piNoapp
          and avnad.cduni = pcCduni:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer avnad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAvnad no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAvnad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoann    as handle  no-undo.
    define variable vhCdmat    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhCduni    as handle  no-undo.
    define variable vhCdreg    as handle  no-undo.
    define buffer avnad for avnad.

    create query vhttquery.
    vhttBuffer = ghttAvnad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAvnad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoann, output vhCdmat, output vhNomdt, output vhNoapp, output vhCduni, output vhCdreg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first avnad exclusive-lock
                where rowid(avnad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer avnad:handle, 'noann/cdmat/nomdt/noapp/cduni/cdreg: ', substitute('&1/&2/&3/&4/&5/&6', vhNoann:buffer-value(), vhCdmat:buffer-value(), vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhCduni:buffer-value(), vhCdreg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer avnad:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAvnad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer avnad for avnad.

    create query vhttquery.
    vhttBuffer = ghttAvnad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAvnad:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create avnad.
            if not outils:copyValidField(buffer avnad:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAvnad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoann    as handle  no-undo.
    define variable vhCdmat    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhCduni    as handle  no-undo.
    define variable vhCdreg    as handle  no-undo.
    define buffer avnad for avnad.

    create query vhttquery.
    vhttBuffer = ghttAvnad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAvnad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoann, output vhCdmat, output vhNomdt, output vhNoapp, output vhCduni, output vhCdreg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first avnad exclusive-lock
                where rowid(Avnad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer avnad:handle, 'noann/cdmat/nomdt/noapp/cduni/cdreg: ', substitute('&1/&2/&3/&4/&5/&6', vhNoann:buffer-value(), vhCdmat:buffer-value(), vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhCduni:buffer-value(), vhCdreg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete avnad no-error.
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

procedure deleteAvnadSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    
    define buffer avnad for avnad.

blocTrans:
    do transaction:
// whole-index corrige par la creation dans la version d'un index sur nomdt
        for each avnad exclusive-lock
            where avnad.nomdt = piNumeroMandat:
            delete avnad no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
