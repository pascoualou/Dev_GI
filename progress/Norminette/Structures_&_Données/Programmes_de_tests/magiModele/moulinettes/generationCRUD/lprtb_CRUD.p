/*------------------------------------------------------------------------
File        : lprtb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table lprtb
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/lprtb.i}
{application/include/error.i}
define variable ghttlprtb as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoexe as handle, output phNoper as handle, output phNoimm as handle, output phTpcpt as handle, output phNorlv as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noExe/NoPer/NoImm/TpCpt/NoRlv, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noExe' then phNoexe = phBuffer:buffer-field(vi).
            when 'NoPer' then phNoper = phBuffer:buffer-field(vi).
            when 'NoImm' then phNoimm = phBuffer:buffer-field(vi).
            when 'TpCpt' then phTpcpt = phBuffer:buffer-field(vi).
            when 'NoRlv' then phNorlv = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLprtb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLprtb.
    run updateLprtb.
    run createLprtb.
end procedure.

procedure setLprtb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLprtb.
    ghttLprtb = phttLprtb.
    run crudLprtb.
    delete object phttLprtb.
end procedure.

procedure readLprtb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table lprtb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpcpt as character  no-undo.
    define input parameter piNorlv as integer    no-undo.
    define input parameter table-handle phttLprtb.
    define variable vhttBuffer as handle no-undo.
    define buffer lprtb for lprtb.

    vhttBuffer = phttLprtb:default-buffer-handle.
    for first lprtb no-lock
        where lprtb.tpcon = pcTpcon
          and lprtb.nocon = piNocon
          and lprtb.noExe = piNoexe
          and lprtb.NoPer = piNoper
          and lprtb.NoImm = piNoimm
          and lprtb.TpCpt = pcTpcpt
          and lprtb.NoRlv = piNorlv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lprtb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLprtb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLprtb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table lprtb 
    Notes  : service externe. Critère pcTpcpt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpcpt as character  no-undo.
    define input parameter table-handle phttLprtb.
    define variable vhttBuffer as handle  no-undo.
    define buffer lprtb for lprtb.

    vhttBuffer = phttLprtb:default-buffer-handle.
    if pcTpcpt = ?
    then for each lprtb no-lock
        where lprtb.tpcon = pcTpcon
          and lprtb.nocon = piNocon
          and lprtb.noExe = piNoexe
          and lprtb.NoPer = piNoper
          and lprtb.NoImm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lprtb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each lprtb no-lock
        where lprtb.tpcon = pcTpcon
          and lprtb.nocon = piNocon
          and lprtb.noExe = piNoexe
          and lprtb.NoPer = piNoper
          and lprtb.NoImm = piNoimm
          and lprtb.TpCpt = pcTpcpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lprtb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLprtb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLprtb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhTpcpt    as handle  no-undo.
    define variable vhNorlv    as handle  no-undo.
    define buffer lprtb for lprtb.

    create query vhttquery.
    vhttBuffer = ghttLprtb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLprtb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexe, output vhNoper, output vhNoimm, output vhTpcpt, output vhNorlv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lprtb exclusive-lock
                where rowid(lprtb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lprtb:handle, 'tpcon/nocon/noExe/NoPer/NoImm/TpCpt/NoRlv: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexe:buffer-value(), vhNoper:buffer-value(), vhNoimm:buffer-value(), vhTpcpt:buffer-value(), vhNorlv:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer lprtb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLprtb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer lprtb for lprtb.

    create query vhttquery.
    vhttBuffer = ghttLprtb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLprtb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create lprtb.
            if not outils:copyValidField(buffer lprtb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLprtb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhTpcpt    as handle  no-undo.
    define variable vhNorlv    as handle  no-undo.
    define buffer lprtb for lprtb.

    create query vhttquery.
    vhttBuffer = ghttLprtb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLprtb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexe, output vhNoper, output vhNoimm, output vhTpcpt, output vhNorlv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lprtb exclusive-lock
                where rowid(Lprtb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lprtb:handle, 'tpcon/nocon/noExe/NoPer/NoImm/TpCpt/NoRlv: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexe:buffer-value(), vhNoper:buffer-value(), vhNoimm:buffer-value(), vhTpcpt:buffer-value(), vhNorlv:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete lprtb no-error.
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

