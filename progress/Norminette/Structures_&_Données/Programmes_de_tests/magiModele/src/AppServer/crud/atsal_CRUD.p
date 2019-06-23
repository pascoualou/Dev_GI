/*------------------------------------------------------------------------
File        : atsal_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table atsal
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttatsal as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phTpatt as handle, output phNoatt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/tpatt/noatt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'tpatt' then phTpatt = phBuffer:buffer-field(vi).
            when 'noatt' then phNoatt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAtsal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAtsal.
    run updateAtsal.
    run createAtsal.
end procedure.

procedure setAtsal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAtsal.
    ghttAtsal = phttAtsal.
    run crudAtsal.
    delete object phttAtsal.
end procedure.

procedure readAtsal:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table atsal attestations de salaire pour la SS
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter pcTpatt as character no-undo.
    define input parameter piNoatt as integer   no-undo.
    define input parameter table-handle phttAtsal.

    define variable vhttBuffer as handle no-undo.
    define buffer atsal for atsal.

    vhttBuffer = phttAtsal:default-buffer-handle.
    for first atsal no-lock
        where atsal.tprol = pcTprol
          and atsal.norol = piNorol
          and atsal.tpatt = pcTpatt
          and atsal.noatt = piNoatt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atsal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtsal no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAtsal:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table atsal attestations de salaire pour la SS
    Notes  : service externe. Critère pcTpatt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter pcTpatt as character no-undo.
    define input parameter table-handle phttAtsal.

    define variable vhttBuffer as handle  no-undo.
    define buffer atsal for atsal.

    vhttBuffer = phttAtsal:default-buffer-handle.
    if pcTpatt = ?
    then for each atsal no-lock
        where atsal.tprol = pcTprol
          and atsal.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atsal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each atsal no-lock
        where atsal.tprol = pcTprol
          and atsal.norol = piNorol
          and atsal.tpatt = pcTpatt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atsal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtsal no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAtsal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhTpatt    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define buffer atsal for atsal.

    create query vhttquery.
    vhttBuffer = ghttAtsal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAtsal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhTpatt, output vhNoatt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atsal exclusive-lock
                where rowid(atsal) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atsal:handle, 'tprol/norol/tpatt/noatt: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhTpatt:buffer-value(), vhNoatt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer atsal:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAtsal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer atsal for atsal.

    create query vhttquery.
    vhttBuffer = ghttAtsal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAtsal:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create atsal.
            if not outils:copyValidField(buffer atsal:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAtsal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhTpatt    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define buffer atsal for atsal.

    create query vhttquery.
    vhttBuffer = ghttAtsal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAtsal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhTpatt, output vhNoatt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atsal exclusive-lock
                where rowid(Atsal) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atsal:handle, 'tprol/norol/tpatt/noatt: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhTpatt:buffer-value(), vhNoatt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete atsal no-error.
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

procedure deleteAtsalSurMandatRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    define input parameter piNumeroRole   as int64   no-undo.
    
    define buffer atsal for atsal.

blocTrans:
    do transaction:
// whole-index corrige par la creation dans la version d'un index sur nomdt
        for each atsal exclusive-lock
            where atsal.nomdt = piNumeroMandat
              and atsal.norol = piNumeroRole:  
            delete atsal no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
