/*------------------------------------------------------------------------
File        : honmd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table honmd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
              code issu de adb/src/lib/l_honmd.p
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
// {adblib/include/honmd.i}
{application/include/error.i}
define variable ghtthonmd as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle, output phTphon as handle, output phCdhon as handle, output phCatbai as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tptac/tphon/cdhon/catbai/noapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
            when 'tphon' then phTphon = phBuffer:buffer-field(vi).
            when 'cdhon' then phCdhon = phBuffer:buffer-field(vi).
            when 'catbai' then phCatbai = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudHonmd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteHonmd.
    run updateHonmd.
    run createHonmd.
end procedure.

procedure setHonmd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttHonmd.
    ghttHonmd = phttHonmd.
    run crudHonmd.
    delete object phttHonmd.
end procedure.

procedure readHonmd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table honmd lien mandat - bareme hono (+ categ ou UL)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon  as character  no-undo.
    define input parameter piNocon  as integer    no-undo.
    define input parameter pcTptac  as character  no-undo.
    define input parameter pcTphon  as character  no-undo.
    define input parameter piCdhon  as integer    no-undo.
    define input parameter pcCatbai as character  no-undo.
    define input parameter piNoapp  as integer    no-undo.
    define input parameter table-handle phttHonmd.
    define variable vhttBuffer as handle no-undo.
    define buffer honmd for honmd.

    vhttBuffer = phttHonmd:default-buffer-handle.
    for first honmd no-lock
        where honmd.tpcon = pcTpcon
          and honmd.nocon = piNocon
          and honmd.tptac = pcTptac
          and honmd.tphon = pcTphon
          and honmd.cdhon = piCdhon
          and honmd.catbai = pcCatbai
          and honmd.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honmd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHonmd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getHonmd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table honmd lien mandat - bareme hono (+ categ ou UL)
    Notes  : service externe. Critère pcCatbai = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon  as character  no-undo.
    define input parameter piNocon  as integer    no-undo.
    define input parameter pcTptac  as character  no-undo.
    define input parameter pcTphon  as character  no-undo.
    define input parameter piCdhon  as integer    no-undo.
    define input parameter pcCatbai as character  no-undo.
    define input parameter table-handle phttHonmd.
    define variable vhttBuffer as handle  no-undo.
    define buffer honmd for honmd.

    vhttBuffer = phttHonmd:default-buffer-handle.
    if pcCatbai = ?
    then for each honmd no-lock
        where honmd.tpcon = pcTpcon
          and honmd.nocon = piNocon
          and honmd.tptac = pcTptac
          and honmd.tphon = pcTphon
          and honmd.cdhon = piCdhon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honmd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each honmd no-lock
        where honmd.tpcon = pcTpcon
          and honmd.nocon = piNocon
          and honmd.tptac = pcTptac
          and honmd.tphon = pcTphon
          and honmd.cdhon = piCdhon
          and honmd.catbai = pcCatbai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honmd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHonmd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure getHonmdContrat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table honmd lien mandat - bareme hono (+ categ ou UL)
    Notes  : service externe. Critère pcCatbai = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon  as character  no-undo.
    define input parameter piNocon  as integer    no-undo.
    define input parameter table-handle phttHonmd.
    define variable vhttBuffer as handle  no-undo.
    define buffer honmd for honmd.

    vhttBuffer = phttHonmd:default-buffer-handle.
    for each honmd no-lock
        where honmd.tpcon = pcTpcon
          and honmd.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer honmd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHonmd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateHonmd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhCatbai    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer honmd for honmd.

    create query vhttquery.
    vhttBuffer = ghttHonmd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttHonmd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhTphon, output vhCdhon, output vhCatbai, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first honmd exclusive-lock
                where rowid(honmd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer honmd:handle, 'tpcon/nocon/tptac/tphon/cdhon/catbai/noapp: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhTphon:buffer-value(), vhCdhon:buffer-value(), vhCatbai:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer honmd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createHonmd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer honmd for honmd.

    create query vhttquery.
    vhttBuffer = ghttHonmd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttHonmd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create honmd.
            if not outils:copyValidField(buffer honmd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteHonmd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : appelé par tachehonoraire.p
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhCatbai    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer honmd for honmd.

    create query vhttquery.
    vhttBuffer = ghttHonmd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttHonmd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhTphon, output vhCdhon, output vhCatbai, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first honmd exclusive-lock
                where rowid(Honmd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer honmd:handle, 'tpcon/nocon/tptac/tphon/cdhon/catbai/noapp: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhTphon:buffer-value(), vhCdhon:buffer-value(), vhCatbai:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete honmd no-error.
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

procedure deleteHonmdSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    
    define buffer honmd for honmd.

blocTrans:
    do transaction:
        for each honmd exclusive-lock
           where honmd.tpcon = pcTypeContrat
             and honmd.nocon = piNumeroContrat:
            delete honmd no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.


