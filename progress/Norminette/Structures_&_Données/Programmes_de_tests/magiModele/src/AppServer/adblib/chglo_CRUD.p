/*------------------------------------------------------------------------
File        : chglo_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table chglo
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttchglo as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpmdt as handle, output phNomdt as handle, output phNoexo as handle, output phTpctt as handle, output phNoctt as handle, output phCdcle as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpmdt/nomdt/noexo/tpctt/noctt/cdcle/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'tpctt' then phTpctt = phBuffer:buffer-field(vi).
            when 'noctt' then phNoctt = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudChglo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteChglo.
    run updateChglo.
    run createChglo.
end procedure.

procedure setChglo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttChglo.
    ghttChglo = phttChglo.
    run crudChglo.
    delete object phttChglo.
end procedure.

procedure readChglo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table chglo 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter pcTpctt as character  no-undo.
    define input parameter pdeNoctt as decimal    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttChglo.
    define variable vhttBuffer as handle no-undo.
    define buffer chglo for chglo.

    vhttBuffer = phttChglo:default-buffer-handle.
    for first chglo no-lock
        where chglo.tpmdt = pcTpmdt
          and chglo.nomdt = piNomdt
          and chglo.noexo = piNoexo
          and chglo.tpctt = pcTpctt
          and chglo.noctt = pdeNoctt
          and chglo.cdcle = pcCdcle
          and chglo.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chglo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChglo no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getChglo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table chglo 
    Notes  : service externe. Critère pcCdcle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter pcTpctt as character  no-undo.
    define input parameter pdeNoctt as decimal    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter table-handle phttChglo.
    define variable vhttBuffer as handle  no-undo.
    define buffer chglo for chglo.

    vhttBuffer = phttChglo:default-buffer-handle.
    if pcCdcle = ?
    then for each chglo no-lock
        where chglo.tpmdt = pcTpmdt
          and chglo.nomdt = piNomdt
          and chglo.noexo = piNoexo
          and chglo.tpctt = pcTpctt
          and chglo.noctt = pdeNoctt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chglo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each chglo no-lock
        where chglo.tpmdt = pcTpmdt
          and chglo.nomdt = piNomdt
          and chglo.noexo = piNoexo
          and chglo.tpctt = pcTpctt
          and chglo.noctt = pdeNoctt
          and chglo.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chglo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChglo no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateChglo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNoctt    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer chglo for chglo.

    create query vhttquery.
    vhttBuffer = ghttChglo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttChglo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhNoexo, output vhTpctt, output vhNoctt, output vhCdcle, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first chglo exclusive-lock
                where rowid(chglo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer chglo:handle, 'tpmdt/nomdt/noexo/tpctt/noctt/cdcle/nolig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhTpctt:buffer-value(), vhNoctt:buffer-value(), vhCdcle:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer chglo:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createChglo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer chglo for chglo.

    create query vhttquery.
    vhttBuffer = ghttChglo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttChglo:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create chglo.
            if not outils:copyValidField(buffer chglo:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteChglo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNoctt    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer chglo for chglo.

    create query vhttquery.
    vhttBuffer = ghttChglo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttChglo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhNoexo, output vhTpctt, output vhNoctt, output vhCdcle, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first chglo exclusive-lock
                where rowid(Chglo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer chglo:handle, 'tpmdt/nomdt/noexo/tpctt/noctt/cdcle/nolig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhTpctt:buffer-value(), vhNoctt:buffer-value(), vhCdcle:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete chglo no-error.
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

procedure deleteChgloSurBail:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeBail   as character no-undo.
    define input parameter pdNumeroBail as decimal   no-undo.
    
    define buffer chglo for chglo.

message "deleteChgloSurBail "  pcTypeBail "// " pdNumeroBail.

blocTrans:
    do transaction:
        for each chglo exclusive-lock   
           where chglo.tpctt = pcTypeBail
             and chglo.noctt = pdNumeroBail:
            delete chglo no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteChgloSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.
    
    define buffer chglo for chglo.

message "deleteChgloSurMandat "  pcTypeMandat "// " piNumeroMandat.

blocTrans:
    do transaction:
        for each chglo exclusive-lock 
           where chglo.tpmdt = pcTypeMandat
             and chglo.nomdt = piNumeroMandat:
            delete chglo no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
