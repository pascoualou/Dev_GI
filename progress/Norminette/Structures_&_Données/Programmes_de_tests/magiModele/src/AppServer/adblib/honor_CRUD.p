/*------------------------------------------------------------------------
File        : honor_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table honor
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
              issu de adb/src/lib/l_honor.p
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
// {adblib/include/honor.i}
{application/include/error.i}
define variable ghtthonor as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTphon as handle, output phCdhon as handle, output phDtdeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tphon/cdhon/dtdeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tphon' then phTphon = phBuffer:buffer-field(vi).
            when 'cdhon' then phCdhon = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudHonor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteHonor.
    run updateHonor.
    run createHonor.
end procedure.

procedure setHonor:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttHonor.
    ghttHonor = phttHonor.
    run crudHonor.
    delete object phttHonor.
end procedure.

procedure readHonor:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table honor 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTphon  as character no-undo.
    define input parameter piCdhon  as integer   no-undo.
    define input parameter pdaDtdeb as date      no-undo.
    define input parameter table-handle phttHonor.

    define variable vhttBuffer as handle no-undo.
    define buffer honor for honor.

    vhttBuffer = phttHonor:default-buffer-handle.
    for first honor no-lock
        where honor.tphon = pcTphon
          and honor.cdhon = piCdhon
          and honor.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHonor no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getHonor:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table honor 
    Notes  : service externe. Critère piCdhon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTphon as character  no-undo.
    define input parameter piCdhon as integer    no-undo.
    define input parameter table-handle phttHonor.

    define variable vhttBuffer as handle  no-undo.
    define buffer honor for honor.

    vhttBuffer = phttHonor:default-buffer-handle.
    if piCdhon = ?
    then for each honor no-lock
        where honor.tphon = pcTphon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each honor no-lock
        where honor.tphon = pcTphon
          and honor.cdhon = piCdhon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHonor no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateHonor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer honor for honor.

    create query vhttquery.
    vhttBuffer = ghttHonor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttHonor:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTphon, output vhCdhon, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first honor exclusive-lock
                where rowid(honor) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer honor:handle, 'tphon/cdhon/dtdeb: ', substitute('&1/&2/&3', vhTphon:buffer-value(), vhCdhon:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer honor:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createHonor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer honor for honor.

    create query vhttquery.
    vhttBuffer = ghttHonor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttHonor:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create honor.
            if not outils:copyValidField(buffer honor:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteHonor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer honor for honor.

    create query vhttquery.
    vhttBuffer = ghttHonor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttHonor:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTphon, output vhCdhon, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first honor exclusive-lock
                where rowid(Honor) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer honor:handle, 'tphon/cdhon/dtdeb: ', substitute('&1/&2/&3', vhTphon:buffer-value(), vhCdhon:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete honor no-error.
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

procedure nxtHonor:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui permet de connaitre le prochain numéro d'honoraire pour un type donné
    Notes  : Service appelé par baremeHonoraire.p
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeHonoraire   as character no-undo.
    define output parameter piCodeHonoraire   as integer   no-undo initial 1.
    define output parameter piNumeroHonoraire as integer   no-undo initial 1.
    define buffer honor for honor.

    {&_proparse_ prolint-nowarn(use-index)}
    for last honor no-lock
        where honor.tphon = pcTypeHonoraire
          and honor.cdhon < 10000           // ignorer les barèmes spécifiques
        use-index ix_honor00:
        piCodeHonoraire = honor.cdhon + 1.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for last honor no-lock
        use-index ix_honor03:
        piNumeroHonoraire = honor.nohon + 1.
    end.
end procedure.

procedure deleteHonorSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    
    define buffer honor for honor.

blocTrans:
    do transaction:
        for each honor exclusive-lock
           where honor.tpcon = pcTypeContrat
             and honor.nocon = piNumeroContrat:
            delete honor no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.


