/*------------------------------------------------------------------------
File        : aloyd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aloyd
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttaloyd as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phMsqtt as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur msqtt/tpcon/nocon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'msqtt' then phMsqtt = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAloyd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAloyd.
    run updateAloyd.
    run createAloyd.
end procedure.

procedure setAloyd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAloyd.
    ghttAloyd = phttAloyd.
    run crudAloyd.
    delete object phttAloyd.
end procedure.

procedure readAloyd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aloyd 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piMsqtt  as integer   no-undo.
    define input parameter pcTpcon  as character no-undo.
    define input parameter pdeNocon as decimal   no-undo.
    define input parameter table-handle phttAloyd.

    define variable vhttBuffer as handle no-undo.
    define buffer aloyd for aloyd.

    vhttBuffer = phttAloyd:default-buffer-handle.
    for first aloyd no-lock
        where aloyd.msqtt = piMsqtt
          and aloyd.tpcon = pcTpcon
          and aloyd.nocon = pdeNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aloyd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAloyd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAloyd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aloyd 
    Notes  : service externe. Critère pcTpcon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piMsqtt as integer   no-undo.
    define input parameter pcTpcon as character no-undo.
    define input parameter table-handle phttAloyd.

    define variable vhttBuffer as handle  no-undo.
    define buffer aloyd for aloyd.

    vhttBuffer = phttAloyd:default-buffer-handle.
    if pcTpcon = ?
    then for each aloyd no-lock
        where aloyd.msqtt = piMsqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aloyd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aloyd no-lock
        where aloyd.msqtt = piMsqtt
          and aloyd.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aloyd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAloyd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAloyd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer aloyd for aloyd.

    create query vhttquery.
    vhttBuffer = ghttAloyd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAloyd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhMsqtt, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aloyd exclusive-lock
                where rowid(aloyd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aloyd:handle, 'msqtt/tpcon/nocon: ', substitute('&1/&2/&3', vhMsqtt:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aloyd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAloyd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer aloyd for aloyd.

    create query vhttquery.
    vhttBuffer = ghttAloyd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAloyd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aloyd.
            if not outils:copyValidField(buffer aloyd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAloyd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer aloyd for aloyd.

    create query vhttquery.
    vhttBuffer = ghttAloyd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAloyd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhMsqtt, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aloyd exclusive-lock
                where rowid(Aloyd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aloyd:handle, 'msqtt/tpcon/nocon: ', substitute('&1/&2/&3', vhMsqtt:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aloyd no-error.
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

procedure deleteAloydSurBail:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pdNumeroBail    as decimal   no-undo.

    define buffer aloyd for aloyd.
      
blocTrans:
    do transaction:
        for each aloyd exclusive-lock 
            where aloyd.tpcon = pcTypeContrat 
              and aloyd.nocon = pdNumeroBail:
            delete aloyd no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
