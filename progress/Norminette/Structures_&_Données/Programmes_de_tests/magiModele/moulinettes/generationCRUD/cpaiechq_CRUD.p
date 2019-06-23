/*------------------------------------------------------------------------
File        : cpaiechq_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpaiechq
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpaiechq.i}
{application/include/error.i}
define variable ghttcpaiechq as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phChrono as handle, output phNum-int as handle, output phNum-chq as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/chrono/num-int/num-chq, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'chrono' then phChrono = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'num-chq' then phNum-chq = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpaiechq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpaiechq.
    run updateCpaiechq.
    run createCpaiechq.
end procedure.

procedure setCpaiechq:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpaiechq.
    ghttCpaiechq = phttCpaiechq.
    run crudCpaiechq.
    delete object phttCpaiechq.
end procedure.

procedure readCpaiechq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpaiechq Pied des cheques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piChrono  as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piNum-chq as integer    no-undo.
    define input parameter table-handle phttCpaiechq.
    define variable vhttBuffer as handle no-undo.
    define buffer cpaiechq for cpaiechq.

    vhttBuffer = phttCpaiechq:default-buffer-handle.
    for first cpaiechq no-lock
        where cpaiechq.soc-cd = piSoc-cd
          and cpaiechq.etab-cd = piEtab-cd
          and cpaiechq.chrono = piChrono
          and cpaiechq.num-int = piNum-int
          and cpaiechq.num-chq = piNum-chq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiechq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiechq no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpaiechq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpaiechq Pied des cheques
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piChrono  as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttCpaiechq.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpaiechq for cpaiechq.

    vhttBuffer = phttCpaiechq:default-buffer-handle.
    if piNum-int = ?
    then for each cpaiechq no-lock
        where cpaiechq.soc-cd = piSoc-cd
          and cpaiechq.etab-cd = piEtab-cd
          and cpaiechq.chrono = piChrono:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiechq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpaiechq no-lock
        where cpaiechq.soc-cd = piSoc-cd
          and cpaiechq.etab-cd = piEtab-cd
          and cpaiechq.chrono = piChrono
          and cpaiechq.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiechq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiechq no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpaiechq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhNum-chq    as handle  no-undo.
    define buffer cpaiechq for cpaiechq.

    create query vhttquery.
    vhttBuffer = ghttCpaiechq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpaiechq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhNum-int, output vhNum-chq).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiechq exclusive-lock
                where rowid(cpaiechq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiechq:handle, 'soc-cd/etab-cd/chrono/num-int/num-chq: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhNum-int:buffer-value(), vhNum-chq:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpaiechq:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpaiechq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpaiechq for cpaiechq.

    create query vhttquery.
    vhttBuffer = ghttCpaiechq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpaiechq:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpaiechq.
            if not outils:copyValidField(buffer cpaiechq:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpaiechq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhNum-chq    as handle  no-undo.
    define buffer cpaiechq for cpaiechq.

    create query vhttquery.
    vhttBuffer = ghttCpaiechq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpaiechq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhNum-int, output vhNum-chq).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiechq exclusive-lock
                where rowid(Cpaiechq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiechq:handle, 'soc-cd/etab-cd/chrono/num-int/num-chq: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhNum-int:buffer-value(), vhNum-chq:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpaiechq no-error.
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

