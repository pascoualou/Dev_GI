/*------------------------------------------------------------------------
File        : afair_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table afair
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttafair as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoaff as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noaff, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noaff' then phNoaff = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAfair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAfair.
    run updateAfair.
    run createAfair.
end procedure.

procedure setAfair:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAfair.
    ghttAfair = phttAfair.
    run crudAfair.
    delete object phttAfair.
end procedure.

procedure readAfair:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table afair 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoaff as integer    no-undo.
    define input parameter table-handle phttAfair.
    define variable vhttBuffer as handle no-undo.
    define buffer afair for afair.

    vhttBuffer = phttAfair:default-buffer-handle.
    for first afair no-lock
        where afair.noaff = piNoaff:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afair:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAfair no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAfair:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table afair 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAfair.
    define variable vhttBuffer as handle  no-undo.
    define buffer afair for afair.

    vhttBuffer = phttAfair:default-buffer-handle.
    for each afair no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afair:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAfair no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAfair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoaff    as handle  no-undo.
    define buffer afair for afair.

    create query vhttquery.
    vhttBuffer = ghttAfair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAfair:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoaff).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first afair exclusive-lock
                where rowid(afair) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer afair:handle, 'noaff: ', substitute('&1', vhNoaff:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer afair:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAfair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer afair for afair.

    create query vhttquery.
    vhttBuffer = ghttAfair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAfair:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create afair.
            if not outils:copyValidField(buffer afair:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAfair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoaff    as handle  no-undo.
    define buffer afair for afair.

    create query vhttquery.
    vhttBuffer = ghttAfair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAfair:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoaff).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first afair exclusive-lock
                where rowid(Afair) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer afair:handle, 'noaff: ', substitute('&1', vhNoaff:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete afair no-error.
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

procedure deleteAfairSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.

    define buffer afair for afair.

blocTrans:
    do transaction:
        // whole-index corrige par la creation dans la version d'un index sur nomdt
        for each afair exclusive-lock
           where afair.nomdt = piNumeroMandat:
            run deleteDependantAfair(afair.noaff).
            if mError:erreur()      
            then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.     
            delete afair no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteAfairSurDemandeur:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat    as integer   no-undo.
    define input parameter pcTypeDemandeur   as character no-undo.
    define input parameter piNumeroDemandeur as integer   no-undo.

    define buffer afair for afair.
    define buffer actio for actio.

blocTrans:
    do transaction:
        // whole-index corrige par la creation dans la version d'un index sur nomdt
        for each afair exclusive-lock
           where afair.nomdt > piNumeroMandat
             and afair.tpdem = pcTypeDemandeur
             and afair.nodem = piNumeroDemandeur:
            run deleteDependantAfair(afair.noaff).
            if mError:erreur()      
            then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.     
            delete afair no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteDependantAfair private:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements des tables dependantes de la table afair 
    Notes  : creation de cette procedure, car dans le dictionnaire il existe un controle pour interdire suppression si enregistrement actio 
             existe (bouton validation: NOT (CAN-FIND(FIRST ACTIO OF AFAIR))
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroAfair as integer no-undo.

    define buffer actro for actro.
    define buffer actio for actio.

blocTrans:
    do transaction:
        for each actro exclusive-lock 
           where actro.noaff = piNumeroAfair:
            delete actro no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.     
        for each actio exclusive-lock
           where actio.noaff = piNumeroAfair:
            delete actio no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
