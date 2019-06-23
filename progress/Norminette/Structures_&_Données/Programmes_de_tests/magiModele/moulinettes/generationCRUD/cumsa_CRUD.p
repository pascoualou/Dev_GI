/*------------------------------------------------------------------------
File        : cumsa_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cumsa
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cumsa.i}
{application/include/error.i}
define variable ghttcumsa as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phAntrt as handle, output phTpmdt as handle, output phNomdt as handle, output phTprol as handle, output phNorol as handle, output phNomod as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur antrt/tpmdt/nomdt/tprol/norol/nomod, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'antrt' then phAntrt = phBuffer:buffer-field(vi).
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'nomod' then phNomod = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCumsa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCumsa.
    run updateCumsa.
    run createCumsa.
end procedure.

procedure setCumsa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCumsa.
    ghttCumsa = phttCumsa.
    run crudCumsa.
    delete object phttCumsa.
end procedure.

procedure readCumsa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cumsa 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piAntrt as integer    no-undo.
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piNomod as integer    no-undo.
    define input parameter table-handle phttCumsa.
    define variable vhttBuffer as handle no-undo.
    define buffer cumsa for cumsa.

    vhttBuffer = phttCumsa:default-buffer-handle.
    for first cumsa no-lock
        where cumsa.antrt = piAntrt
          and cumsa.tpmdt = pcTpmdt
          and cumsa.nomdt = piNomdt
          and cumsa.tprol = pcTprol
          and cumsa.norol = piNorol
          and cumsa.nomod = piNomod:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cumsa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCumsa no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCumsa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cumsa 
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piAntrt as integer    no-undo.
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter table-handle phttCumsa.
    define variable vhttBuffer as handle  no-undo.
    define buffer cumsa for cumsa.

    vhttBuffer = phttCumsa:default-buffer-handle.
    if piNorol = ?
    then for each cumsa no-lock
        where cumsa.antrt = piAntrt
          and cumsa.tpmdt = pcTpmdt
          and cumsa.nomdt = piNomdt
          and cumsa.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cumsa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cumsa no-lock
        where cumsa.antrt = piAntrt
          and cumsa.tpmdt = pcTpmdt
          and cumsa.nomdt = piNomdt
          and cumsa.tprol = pcTprol
          and cumsa.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cumsa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCumsa no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCumsa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAntrt    as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNomod    as handle  no-undo.
    define buffer cumsa for cumsa.

    create query vhttquery.
    vhttBuffer = ghttCumsa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCumsa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAntrt, output vhTpmdt, output vhNomdt, output vhTprol, output vhNorol, output vhNomod).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cumsa exclusive-lock
                where rowid(cumsa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cumsa:handle, 'antrt/tpmdt/nomdt/tprol/norol/nomod: ', substitute('&1/&2/&3/&4/&5/&6', vhAntrt:buffer-value(), vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value(), vhNomod:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cumsa:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCumsa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cumsa for cumsa.

    create query vhttquery.
    vhttBuffer = ghttCumsa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCumsa:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cumsa.
            if not outils:copyValidField(buffer cumsa:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCumsa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAntrt    as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNomod    as handle  no-undo.
    define buffer cumsa for cumsa.

    create query vhttquery.
    vhttBuffer = ghttCumsa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCumsa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAntrt, output vhTpmdt, output vhNomdt, output vhTprol, output vhNorol, output vhNomod).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cumsa exclusive-lock
                where rowid(Cumsa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cumsa:handle, 'antrt/tpmdt/nomdt/tprol/norol/nomod: ', substitute('&1/&2/&3/&4/&5/&6', vhAntrt:buffer-value(), vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value(), vhNomod:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cumsa no-error.
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

