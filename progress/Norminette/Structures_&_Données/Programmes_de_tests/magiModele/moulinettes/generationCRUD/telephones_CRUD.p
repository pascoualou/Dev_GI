/*------------------------------------------------------------------------
File        : telephones_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table telephones
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/telephones.i}
{application/include/error.i}
define variable ghtttelephones as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phSoc-cd as handle, output phLibadr-cd as handle, output phAdr-cd as handle, output phNumero as handle, output phNopos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/soc-cd/libadr-cd/adr-cd/numero/nopos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'libadr-cd' then phLibadr-cd = phBuffer:buffer-field(vi).
            when 'adr-cd' then phAdr-cd = phBuffer:buffer-field(vi).
            when 'numero' then phNumero = phBuffer:buffer-field(vi).
            when 'nopos' then phNopos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTelephones private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTelephones.
    run updateTelephones.
    run createTelephones.
end procedure.

procedure setTelephones:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTelephones.
    ghttTelephones = phttTelephones.
    run crudTelephones.
    delete object phttTelephones.
end procedure.

procedure readTelephones:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table telephones 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt     as character  no-undo.
    define input parameter piNoidt     as integer    no-undo.
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter piAdr-cd    as integer    no-undo.
    define input parameter piNumero    as integer    no-undo.
    define input parameter piNopos     as integer    no-undo.
    define input parameter table-handle phttTelephones.
    define variable vhttBuffer as handle no-undo.
    define buffer telephones for telephones.

    vhttBuffer = phttTelephones:default-buffer-handle.
    for first telephones no-lock
        where telephones.tpidt = pcTpidt
          and telephones.noidt = piNoidt
          and telephones.soc-cd = piSoc-cd
          and telephones.libadr-cd = piLibadr-cd
          and telephones.adr-cd = piAdr-cd
          and telephones.numero = piNumero
          and telephones.nopos = piNopos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer telephones:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTelephones no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTelephones:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table telephones 
    Notes  : service externe. Critère piNumero = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt     as character  no-undo.
    define input parameter piNoidt     as integer    no-undo.
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter piAdr-cd    as integer    no-undo.
    define input parameter piNumero    as integer    no-undo.
    define input parameter table-handle phttTelephones.
    define variable vhttBuffer as handle  no-undo.
    define buffer telephones for telephones.

    vhttBuffer = phttTelephones:default-buffer-handle.
    if piNumero = ?
    then for each telephones no-lock
        where telephones.tpidt = pcTpidt
          and telephones.noidt = piNoidt
          and telephones.soc-cd = piSoc-cd
          and telephones.libadr-cd = piLibadr-cd
          and telephones.adr-cd = piAdr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer telephones:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each telephones no-lock
        where telephones.tpidt = pcTpidt
          and telephones.noidt = piNoidt
          and telephones.soc-cd = piSoc-cd
          and telephones.libadr-cd = piLibadr-cd
          and telephones.adr-cd = piAdr-cd
          and telephones.numero = piNumero:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer telephones:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTelephones no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTelephones private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibadr-cd    as handle  no-undo.
    define variable vhAdr-cd    as handle  no-undo.
    define variable vhNumero    as handle  no-undo.
    define variable vhNopos    as handle  no-undo.
    define buffer telephones for telephones.

    create query vhttquery.
    vhttBuffer = ghttTelephones:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTelephones:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhSoc-cd, output vhLibadr-cd, output vhAdr-cd, output vhNumero, output vhNopos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first telephones exclusive-lock
                where rowid(telephones) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer telephones:handle, 'tpidt/noidt/soc-cd/libadr-cd/adr-cd/numero/nopos: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhSoc-cd:buffer-value(), vhLibadr-cd:buffer-value(), vhAdr-cd:buffer-value(), vhNumero:buffer-value(), vhNopos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer telephones:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTelephones private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer telephones for telephones.

    create query vhttquery.
    vhttBuffer = ghttTelephones:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTelephones:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create telephones.
            if not outils:copyValidField(buffer telephones:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTelephones private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibadr-cd    as handle  no-undo.
    define variable vhAdr-cd    as handle  no-undo.
    define variable vhNumero    as handle  no-undo.
    define variable vhNopos    as handle  no-undo.
    define buffer telephones for telephones.

    create query vhttquery.
    vhttBuffer = ghttTelephones:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTelephones:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhSoc-cd, output vhLibadr-cd, output vhAdr-cd, output vhNumero, output vhNopos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first telephones exclusive-lock
                where rowid(Telephones) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer telephones:handle, 'tpidt/noidt/soc-cd/libadr-cd/adr-cd/numero/nopos: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhSoc-cd:buffer-value(), vhLibadr-cd:buffer-value(), vhAdr-cd:buffer-value(), vhNumero:buffer-value(), vhNopos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete telephones no-error.
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

