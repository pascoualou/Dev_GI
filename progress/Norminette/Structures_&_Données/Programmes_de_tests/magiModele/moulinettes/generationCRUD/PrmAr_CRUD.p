/*------------------------------------------------------------------------
File        : PrmAr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table PrmAr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/PrmAr.i}
{application/include/error.i}
define variable ghttPrmAr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdart as handle, output phTpcon as handle, output phFgdos as handle, output phTpurg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CdArt/TpCon/FgDos/TpUrg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CdArt' then phCdart = phBuffer:buffer-field(vi).
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'FgDos' then phFgdos = phBuffer:buffer-field(vi).
            when 'TpUrg' then phTpurg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrmar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrmar.
    run updatePrmar.
    run createPrmar.
end procedure.

procedure setPrmar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrmar.
    ghttPrmar = phttPrmar.
    run crudPrmar.
    delete object phttPrmar.
end procedure.

procedure readPrmar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table PrmAr Chaine Travaux : Table Param Comptable Article
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdart as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter plFgdos as logical    no-undo.
    define input parameter pcTpurg as character  no-undo.
    define input parameter table-handle phttPrmar.
    define variable vhttBuffer as handle no-undo.
    define buffer PrmAr for PrmAr.

    vhttBuffer = phttPrmar:default-buffer-handle.
    for first PrmAr no-lock
        where PrmAr.CdArt = pcCdart
          and PrmAr.TpCon = pcTpcon
          and PrmAr.FgDos = plFgdos
          and PrmAr.TpUrg = pcTpurg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmAr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmar no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrmar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table PrmAr Chaine Travaux : Table Param Comptable Article
    Notes  : service externe. Critère plFgdos = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdart as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter plFgdos as logical    no-undo.
    define input parameter table-handle phttPrmar.
    define variable vhttBuffer as handle  no-undo.
    define buffer PrmAr for PrmAr.

    vhttBuffer = phttPrmar:default-buffer-handle.
    if plFgdos = ?
    then for each PrmAr no-lock
        where PrmAr.CdArt = pcCdart
          and PrmAr.TpCon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmAr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each PrmAr no-lock
        where PrmAr.CdArt = pcCdart
          and PrmAr.TpCon = pcTpcon
          and PrmAr.FgDos = plFgdos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmAr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmar no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrmar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdart    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhFgdos    as handle  no-undo.
    define variable vhTpurg    as handle  no-undo.
    define buffer PrmAr for PrmAr.

    create query vhttquery.
    vhttBuffer = ghttPrmar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrmar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdart, output vhTpcon, output vhFgdos, output vhTpurg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmAr exclusive-lock
                where rowid(PrmAr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmAr:handle, 'CdArt/TpCon/FgDos/TpUrg: ', substitute('&1/&2/&3/&4', vhCdart:buffer-value(), vhTpcon:buffer-value(), vhFgdos:buffer-value(), vhTpurg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer PrmAr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrmar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer PrmAr for PrmAr.

    create query vhttquery.
    vhttBuffer = ghttPrmar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrmar:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create PrmAr.
            if not outils:copyValidField(buffer PrmAr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrmar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdart    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhFgdos    as handle  no-undo.
    define variable vhTpurg    as handle  no-undo.
    define buffer PrmAr for PrmAr.

    create query vhttquery.
    vhttBuffer = ghttPrmar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrmar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdart, output vhTpcon, output vhFgdos, output vhTpurg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmAr exclusive-lock
                where rowid(Prmar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmAr:handle, 'CdArt/TpCon/FgDos/TpUrg: ', substitute('&1/&2/&3/&4', vhCdart:buffer-value(), vhTpcon:buffer-value(), vhFgdos:buffer-value(), vhTpurg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete PrmAr no-error.
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

