/*------------------------------------------------------------------------
File        : ladrs_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ladrs
Author(s)   : generation automatique le 01/31/18, reprise de l_ladrs_ext.p
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/05/22 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2adresse.i}

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttladrs as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phTpadr as handle, output phDtdeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index (pas unique, mais presque)
    Notes: si la temp-table contient un mapping de label sur tpidt, noidt, tpadr, dtdeb 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'tpadr' then phTpadr = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLadrs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLadrs.
    run updateLadrs.
    run createLadrs.
end procedure.

procedure setLadrs:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLadrs.
    ghttLadrs = phttLadrs.
    run crudLadrs.
    delete object phttLadrs.
end procedure.

procedure readLadrs:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ladrs 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNolie as int64  no-undo.
    define input parameter table-handle phttLadrs.

    define variable vhttBuffer as handle no-undo.
    define buffer ladrs for ladrs.

    vhttBuffer = phttLadrs:default-buffer-handle.
    for first ladrs no-lock
        where ladrs.nolie = piNolie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ladrs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLadrs no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure readLadrs2:
    /*------------------------------------------------------------------------------
    Purpose: repris de adb/lib/l_adrs_ext.p procedure Lc2Ladrs
    Notes  : service externe (gesind00.p)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdt as character no-undo.
    define input parameter piNumIdt  as integer   no-undo.
    define input parameter table-handle phttLadrs.

    define variable vhttBuffer as handle no-undo.
    define buffer ladrs for ladrs.

    vhttBuffer = phttLadrs:default-buffer-handle.
    for last ladrs no-lock       // index par tpidt, noidt, tpadr, dtdeb
        where ladrs.tpidt = pcTypeIdt
          and ladrs.noidt = piNumIdt
          and ladrs.tpadr = {&TYPEADRESSE-Principale}:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ladrs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLadrs no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLadrs:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ladrs 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeIdentifiant   as character no-undo.
    define input  parameter piNumeroIdentifiant as int64     no-undo.
    define input  parameter pcTypeAdresse       as character no-undo.
    define input parameter table-handle phttLadrs.
    define variable vhttBuffer as handle  no-undo.

    define buffer ladrs for ladrs.

    vhttBuffer = phttLadrs:default-buffer-handle.
    if pcTypeAdresse = ?
    then for each ladrs no-lock
        where ladrs.tpidt = pcTypeIdentifiant
          and ladrs.noidt = piNumeroIdentifiant
        break by ladrs.tpadr by ladrs.dtdeb descending:
        if first-of(ladrs.tpadr) then do:
            vhttBuffer:buffer-create().
            outils:copyValidField(buffer ladrs:handle, vhttBuffer).  // copy table physique vers temp-table
        end.
    end.
    else for last ladrs no-lock
        where ladrs.tpidt = pcTypeIdentifiant
          and ladrs.noidt = piNumeroIdentifiant
          and ladrs.tpadr = pcTypeAdresse:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ladrs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLadrs no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLadrs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhTpadr    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer ladrs for ladrs.

    create query vhttquery.
    vhttBuffer = ghttLadrs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLadrs:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhTpadr, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ladrs exclusive-lock
                where rowid(ladrs) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ladrs:handle, 'tpidt/noidt/tpadr/dtdeb: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhTpadr:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ladrs:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLadrs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolie    as handle   no-undo.
    define variable viNolie    as int64    no-undo.
    define variable vi         as integer  no-undo.
    define buffer ladrs for ladrs.

    create query vhttquery.
    vhttBuffer = ghttLadrs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLadrs:name)).
    vhttquery:query-open().
    do vi = 1 to vhttBuffer:num-fields:
        case vhttBuffer:buffer-field(vi):label:
            when 'nolie' then vhNolie = vhttBuffer:buffer-field(vi).
       end case.
    end.

blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            viNolie = vhNolie:buffer-value().
            if viNolie = ? or viNolie = 0 then do:
                run getNextLadrs(output viNolie).
                vhNolie:buffer-value() = viNolie.
            end.
            create ladrs.
            if not outils:copyValidField(buffer ladrs:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLadrs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhTpadr    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer ladrs for ladrs.

    create query vhttquery.
    vhttBuffer = ghttLadrs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLadrs:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhTpadr, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ladrs exclusive-lock
                where rowid(Ladrs) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ladrs:handle, 'tpidt/noidt/tpadr/dtdeb: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhTpadr:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ladrs no-error.
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

procedure getNextLadrs:
    /*------------------------------------------------------------------------------
    Purpose: repris de adb/lib/l_adrs_ext.p procedure NxtLadrs
    Notes  : service utilisé par l_roles_ext.p
    ------------------------------------------------------------------------------*/
    define output parameter piNumeroLien  as integer no-undo initial 1.
    define buffer ladrs for ladrs.

    {&_proparse_ prolint-nowarn(wholeindex)}
    for last ladrs no-lock:
        piNumeroLien = ladrs.nolie + 1.
    end.
    return.
end procedure.

procedure deleteLadrsSurNoidt:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.
    
    define buffer ladrs for ladrs.

blocTrans:
    do transaction:
        for each ladrs exclusive-lock
           where ladrs.tpidt = pcTypeIdentifiant
             and ladrs.noidt = piNumeroIdentifiant:
            delete ladrs no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
