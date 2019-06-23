/*------------------------------------------------------------------------
File        : ahono_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ahono
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/08/08 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttahono as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpmdt as handle, output phNomdt as handle, output phDtcpt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpmdt/nomdt/dtcpt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'dtcpt' then phDtcpt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAhono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAhono.
    run updateAhono.
    run createAhono.
end procedure.

procedure setAhono:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAhono.
    ghttAhono = phttAhono.
    run crudAhono.
    delete object phttAhono.
end procedure.

procedure readAhono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ahono 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piDtcpt as integer    no-undo.
    define input parameter table-handle phttAhono.
    define variable vhttBuffer as handle no-undo.
    define buffer ahono for ahono.

    vhttBuffer = phttAhono:default-buffer-handle.
    for first ahono no-lock
        where ahono.tpmdt = pcTpmdt
          and ahono.nomdt = piNomdt
          and ahono.dtcpt = piDtcpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhono no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAhono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ahono 
    Notes  : service externe. Critère piNomdt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttAhono.
    define variable vhttBuffer as handle  no-undo.
    define buffer ahono for ahono.

    vhttBuffer = phttAhono:default-buffer-handle.
    if piNomdt = ?
    then for each ahono no-lock
        where ahono.tpmdt = pcTpmdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ahono no-lock
        where ahono.tpmdt = pcTpmdt
          and ahono.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhono no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAhono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhDtcpt    as handle  no-undo.
    define buffer ahono for ahono.

    create query vhttquery.
    vhttBuffer = ghttAhono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAhono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhDtcpt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahono exclusive-lock
                where rowid(ahono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahono:handle, 'tpmdt/nomdt/dtcpt: ', substitute('&1/&2/&3', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhDtcpt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ahono:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAhono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ahono for ahono.

    create query vhttquery.
    vhttBuffer = ghttAhono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAhono:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ahono.
            if not outils:copyValidField(buffer ahono:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAhono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhDtcpt    as handle  no-undo.
    define buffer ahono for ahono.

    create query vhttquery.
    vhttBuffer = ghttAhono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAhono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhDtcpt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahono exclusive-lock
                where rowid(Ahono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahono:handle, 'tpmdt/nomdt/dtcpt: ', substitute('&1/&2/&3', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhDtcpt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ahono no-error.
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

procedure deleteAhonoSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.
    
    define buffer ahono for ahono.

blocTrans:
    do transaction:
        for each ahono exclusive-lock
           where ahono.tpmdt = pcTypeMandat
             and ahono.nomdt = piNumeroMandat:
            delete ahono no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
