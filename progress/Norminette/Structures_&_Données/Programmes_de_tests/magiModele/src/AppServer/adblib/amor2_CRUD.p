/*------------------------------------------------------------------------
File        : amor2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table amor2
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttamor2 as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNofic as handle, output phAnnep as handle, output phMoisp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/nofic/annep/moisp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'nofic' then phNofic = phBuffer:buffer-field(vi).
            when 'annep' then phAnnep = phBuffer:buffer-field(vi).
            when 'moisp' then phMoisp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAmor2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAmor2.
    run updateAmor2.
    run createAmor2.
end procedure.

procedure setAmor2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAmor2.
    ghttAmor2 = phttAmor2.
    run crudAmor2.
    delete object phttAmor2.
end procedure.

procedure readAmor2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table amor2 EchÃ©ancier amort. locataires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNofic as integer    no-undo.
    define input parameter piAnnep as integer    no-undo.
    define input parameter piMoisp as integer    no-undo.
    define input parameter table-handle phttAmor2.
    define variable vhttBuffer as handle no-undo.
    define buffer amor2 for amor2.

    vhttBuffer = phttAmor2:default-buffer-handle.
    for first amor2 no-lock
        where amor2.tpcon = pcTpcon
          and amor2.nocon = piNocon
          and amor2.nofic = piNofic
          and amor2.annep = piAnnep
          and amor2.moisp = piMoisp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amor2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAmor2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAmor2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table amor2 EchÃ©ancier amort. locataires
    Notes  : service externe. Critère piAnnep = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNofic as integer    no-undo.
    define input parameter piAnnep as integer    no-undo.
    define input parameter table-handle phttAmor2.
    define variable vhttBuffer as handle  no-undo.
    define buffer amor2 for amor2.

    vhttBuffer = phttAmor2:default-buffer-handle.
    if piAnnep = ?
    then for each amor2 no-lock
        where amor2.tpcon = pcTpcon
          and amor2.nocon = piNocon
          and amor2.nofic = piNofic:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amor2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each amor2 no-lock
        where amor2.tpcon = pcTpcon
          and amor2.nocon = piNocon
          and amor2.nofic = piNofic
          and amor2.annep = piAnnep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amor2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAmor2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAmor2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNofic    as handle  no-undo.
    define variable vhAnnep    as handle  no-undo.
    define variable vhMoisp    as handle  no-undo.
    define buffer amor2 for amor2.

    create query vhttquery.
    vhttBuffer = ghttAmor2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAmor2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNofic, output vhAnnep, output vhMoisp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first amor2 exclusive-lock
                where rowid(amor2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer amor2:handle, 'tpcon/nocon/nofic/annep/moisp: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNofic:buffer-value(), vhAnnep:buffer-value(), vhMoisp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer amor2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAmor2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer amor2 for amor2.

    create query vhttquery.
    vhttBuffer = ghttAmor2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAmor2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create amor2.
            if not outils:copyValidField(buffer amor2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAmor2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNofic    as handle  no-undo.
    define variable vhAnnep    as handle  no-undo.
    define variable vhMoisp    as handle  no-undo.
    define buffer amor2 for amor2.

    create query vhttquery.
    vhttBuffer = ghttAmor2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAmor2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNofic, output vhAnnep, output vhMoisp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first amor2 exclusive-lock
                where rowid(Amor2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer amor2:handle, 'tpcon/nocon/nofic/annep/moisp: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNofic:buffer-value(), vhAnnep:buffer-value(), vhMoisp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete amor2 no-error.
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

procedure deleteAmor2SurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer amor2 for amor2.

blocTrans:
    do transaction:
        for each amor2 exclusive-lock 
            where amor2.tpcon = pcTypeContrat 
              and amor2.nocon = piNumeroContrat:
            delete amor2 no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
