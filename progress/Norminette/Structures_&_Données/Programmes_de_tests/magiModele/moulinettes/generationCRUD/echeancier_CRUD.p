/*------------------------------------------------------------------------
File        : echeancier_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table echeancier
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/echeancier.i}
{application/include/error.i}
define variable ghttecheancier as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpct1 as handle, output phNoct1 as handle, output phTpct2 as handle, output phNoct2 as handle, output phTptac as handle, output phTpech as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur Tpct1/Noct1/Tpct2/noct2/tptac/TpEch/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'Tpct1' then phTpct1 = phBuffer:buffer-field(vi).
            when 'Noct1' then phNoct1 = phBuffer:buffer-field(vi).
            when 'Tpct2' then phTpct2 = phBuffer:buffer-field(vi).
            when 'noct2' then phNoct2 = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
            when 'TpEch' then phTpech = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEcheancier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEcheancier.
    run updateEcheancier.
    run createEcheancier.
end procedure.

procedure setEcheancier:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEcheancier.
    ghttEcheancier = phttEcheancier.
    run crudEcheancier.
    delete object phttEcheancier.
end procedure.

procedure readEcheancier:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table echeancier Table de stockage d'échéanciers divers
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpct1 as character  no-undo.
    define input parameter piNoct1 as int64      no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter piNoct2 as int64      no-undo.
    define input parameter pcTptac as character  no-undo.
    define input parameter pcTpech as character  no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttEcheancier.
    define variable vhttBuffer as handle no-undo.
    define buffer echeancier for echeancier.

    vhttBuffer = phttEcheancier:default-buffer-handle.
    for first echeancier no-lock
        where echeancier.Tpct1 = pcTpct1
          and echeancier.Noct1 = piNoct1
          and echeancier.Tpct2 = pcTpct2
          and echeancier.noct2 = piNoct2
          and echeancier.tptac = pcTptac
          and echeancier.TpEch = pcTpech
          and echeancier.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer echeancier:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEcheancier no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEcheancier:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table echeancier Table de stockage d'échéanciers divers
    Notes  : service externe. Critère pcTpech = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpct1 as character  no-undo.
    define input parameter piNoct1 as int64      no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter piNoct2 as int64      no-undo.
    define input parameter pcTptac as character  no-undo.
    define input parameter pcTpech as character  no-undo.
    define input parameter table-handle phttEcheancier.
    define variable vhttBuffer as handle  no-undo.
    define buffer echeancier for echeancier.

    vhttBuffer = phttEcheancier:default-buffer-handle.
    if pcTpech = ?
    then for each echeancier no-lock
        where echeancier.Tpct1 = pcTpct1
          and echeancier.Noct1 = piNoct1
          and echeancier.Tpct2 = pcTpct2
          and echeancier.noct2 = piNoct2
          and echeancier.tptac = pcTptac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer echeancier:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each echeancier no-lock
        where echeancier.Tpct1 = pcTpct1
          and echeancier.Noct1 = piNoct1
          and echeancier.Tpct2 = pcTpct2
          and echeancier.noct2 = piNoct2
          and echeancier.tptac = pcTptac
          and echeancier.TpEch = pcTpech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer echeancier:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEcheancier no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEcheancier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpct1    as handle  no-undo.
    define variable vhNoct1    as handle  no-undo.
    define variable vhTpct2    as handle  no-undo.
    define variable vhNoct2    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhTpech    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer echeancier for echeancier.

    create query vhttquery.
    vhttBuffer = ghttEcheancier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEcheancier:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpct1, output vhNoct1, output vhTpct2, output vhNoct2, output vhTptac, output vhTpech, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first echeancier exclusive-lock
                where rowid(echeancier) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer echeancier:handle, 'Tpct1/Noct1/Tpct2/noct2/tptac/TpEch/noord: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value(), vhTptac:buffer-value(), vhTpech:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer echeancier:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEcheancier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer echeancier for echeancier.

    create query vhttquery.
    vhttBuffer = ghttEcheancier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEcheancier:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create echeancier.
            if not outils:copyValidField(buffer echeancier:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEcheancier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpct1    as handle  no-undo.
    define variable vhNoct1    as handle  no-undo.
    define variable vhTpct2    as handle  no-undo.
    define variable vhNoct2    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhTpech    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer echeancier for echeancier.

    create query vhttquery.
    vhttBuffer = ghttEcheancier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEcheancier:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpct1, output vhNoct1, output vhTpct2, output vhNoct2, output vhTptac, output vhTpech, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first echeancier exclusive-lock
                where rowid(Echeancier) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer echeancier:handle, 'Tpct1/Noct1/Tpct2/noct2/tptac/TpEch/noord: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value(), vhTptac:buffer-value(), vhTpech:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete echeancier no-error.
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

