/*------------------------------------------------------------------------
File        : freThDt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table freThDt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/freThDt.i}
{application/include/error.i}
define variable ghttfreThDt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoexo as handle, output phCdcleapp as handle, output phMois as handle, output phNoadh as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noexo/cdcleapp/mois/noadh, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'cdcleapp' then phCdcleapp = phBuffer:buffer-field(vi).
            when 'mois' then phMois = phBuffer:buffer-field(vi).
            when 'noadh' then phNoadh = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFrethdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFrethdt.
    run updateFrethdt.
    run createFrethdt.
end procedure.

procedure setFrethdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFrethdt.
    ghttFrethdt = phttFrethdt.
    run crudFrethdt.
    delete object phttFrethdt.
end procedure.

procedure readFrethdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table freThDt RIE : tableau  des fréquentations Théoriques (détail)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon    as character  no-undo.
    define input parameter piNocon    as int64      no-undo.
    define input parameter piNoexo    as integer    no-undo.
    define input parameter pcCdcleapp as character  no-undo.
    define input parameter piMois     as integer    no-undo.
    define input parameter piNoadh    as integer    no-undo.
    define input parameter table-handle phttFrethdt.
    define variable vhttBuffer as handle no-undo.
    define buffer freThDt for freThDt.

    vhttBuffer = phttFrethdt:default-buffer-handle.
    for first freThDt no-lock
        where freThDt.tpcon = pcTpcon
          and freThDt.nocon = piNocon
          and freThDt.noexo = piNoexo
          and freThDt.cdcleapp = pcCdcleapp
          and freThDt.mois = piMois
          and freThDt.noadh = piNoadh:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer freThDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrethdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFrethdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table freThDt RIE : tableau  des fréquentations Théoriques (détail)
    Notes  : service externe. Critère piMois = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon    as character  no-undo.
    define input parameter piNocon    as int64      no-undo.
    define input parameter piNoexo    as integer    no-undo.
    define input parameter pcCdcleapp as character  no-undo.
    define input parameter piMois     as integer    no-undo.
    define input parameter table-handle phttFrethdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer freThDt for freThDt.

    vhttBuffer = phttFrethdt:default-buffer-handle.
    if piMois = ?
    then for each freThDt no-lock
        where freThDt.tpcon = pcTpcon
          and freThDt.nocon = piNocon
          and freThDt.noexo = piNoexo
          and freThDt.cdcleapp = pcCdcleapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer freThDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each freThDt no-lock
        where freThDt.tpcon = pcTpcon
          and freThDt.nocon = piNocon
          and freThDt.noexo = piNoexo
          and freThDt.cdcleapp = pcCdcleapp
          and freThDt.mois = piMois:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer freThDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrethdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFrethdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhCdcleapp    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define variable vhNoadh    as handle  no-undo.
    define buffer freThDt for freThDt.

    create query vhttquery.
    vhttBuffer = ghttFrethdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFrethdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhCdcleapp, output vhMois, output vhNoadh).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first freThDt exclusive-lock
                where rowid(freThDt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer freThDt:handle, 'tpcon/nocon/noexo/cdcleapp/mois/noadh: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhCdcleapp:buffer-value(), vhMois:buffer-value(), vhNoadh:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer freThDt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFrethdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer freThDt for freThDt.

    create query vhttquery.
    vhttBuffer = ghttFrethdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFrethdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create freThDt.
            if not outils:copyValidField(buffer freThDt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFrethdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhCdcleapp    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define variable vhNoadh    as handle  no-undo.
    define buffer freThDt for freThDt.

    create query vhttquery.
    vhttBuffer = ghttFrethdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFrethdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhCdcleapp, output vhMois, output vhNoadh).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first freThDt exclusive-lock
                where rowid(Frethdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer freThDt:handle, 'tpcon/nocon/noexo/cdcleapp/mois/noadh: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhCdcleapp:buffer-value(), vhMois:buffer-value(), vhNoadh:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete freThDt no-error.
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

