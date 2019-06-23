/*------------------------------------------------------------------------
File        : FreReDt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table FreReDt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/FreReDt.i}
{application/include/error.i}
define variable ghttFreReDt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoexo as handle, output phMois as handle, output phNoadh as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noexo/mois/noadh, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'mois' then phMois = phBuffer:buffer-field(vi).
            when 'noadh' then phNoadh = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFreredt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFreredt.
    run updateFreredt.
    run createFreredt.
end procedure.

procedure setFreredt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFreredt.
    ghttFreredt = phttFreredt.
    run crudFreredt.
    delete object phttFreredt.
end procedure.

procedure readFreredt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table FreReDt RIE : tableau  des fréquentations réelles (détail)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piMois  as integer    no-undo.
    define input parameter piNoadh as integer    no-undo.
    define input parameter table-handle phttFreredt.
    define variable vhttBuffer as handle no-undo.
    define buffer FreReDt for FreReDt.

    vhttBuffer = phttFreredt:default-buffer-handle.
    for first FreReDt no-lock
        where FreReDt.tpcon = pcTpcon
          and FreReDt.nocon = piNocon
          and FreReDt.noexo = piNoexo
          and FreReDt.mois = piMois
          and FreReDt.noadh = piNoadh:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer FreReDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFreredt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFreredt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table FreReDt RIE : tableau  des fréquentations réelles (détail)
    Notes  : service externe. Critère piMois = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piMois  as integer    no-undo.
    define input parameter table-handle phttFreredt.
    define variable vhttBuffer as handle  no-undo.
    define buffer FreReDt for FreReDt.

    vhttBuffer = phttFreredt:default-buffer-handle.
    if piMois = ?
    then for each FreReDt no-lock
        where FreReDt.tpcon = pcTpcon
          and FreReDt.nocon = piNocon
          and FreReDt.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer FreReDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each FreReDt no-lock
        where FreReDt.tpcon = pcTpcon
          and FreReDt.nocon = piNocon
          and FreReDt.noexo = piNoexo
          and FreReDt.mois = piMois:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer FreReDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFreredt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFreredt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define variable vhNoadh    as handle  no-undo.
    define buffer FreReDt for FreReDt.

    create query vhttquery.
    vhttBuffer = ghttFreredt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFreredt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhMois, output vhNoadh).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first FreReDt exclusive-lock
                where rowid(FreReDt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer FreReDt:handle, 'tpcon/nocon/noexo/mois/noadh: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhMois:buffer-value(), vhNoadh:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer FreReDt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFreredt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer FreReDt for FreReDt.

    create query vhttquery.
    vhttBuffer = ghttFreredt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFreredt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create FreReDt.
            if not outils:copyValidField(buffer FreReDt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFreredt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define variable vhNoadh    as handle  no-undo.
    define buffer FreReDt for FreReDt.

    create query vhttquery.
    vhttBuffer = ghttFreredt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFreredt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhMois, output vhNoadh).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first FreReDt exclusive-lock
                where rowid(Freredt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer FreReDt:handle, 'tpcon/nocon/noexo/mois/noadh: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhMois:buffer-value(), vhNoadh:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete FreReDt no-error.
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

