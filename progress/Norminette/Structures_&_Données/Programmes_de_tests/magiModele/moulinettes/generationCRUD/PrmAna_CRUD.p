/*------------------------------------------------------------------------
File        : PrmAna_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table PrmAna
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/PrmAna.i}
{application/include/error.i}
define variable ghttPrmAna as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phCdpar as handle, output phTpcon as handle, output phFgdos as handle, output phTpurg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/Cdpar/TpCon/FgDos/TpUrg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'Cdpar' then phCdpar = phBuffer:buffer-field(vi).
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'FgDos' then phFgdos = phBuffer:buffer-field(vi).
            when 'TpUrg' then phTpurg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrmana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrmana.
    run updatePrmana.
    run createPrmana.
end procedure.

procedure setPrmana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrmana.
    ghttPrmana = phttPrmana.
    run crudPrmana.
    delete object phttPrmana.
end procedure.

procedure readPrmana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table PrmAna Chaine Travaux : Table Param Analytique/type travaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcCdpar as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter plFgdos as logical    no-undo.
    define input parameter pcTpurg as character  no-undo.
    define input parameter table-handle phttPrmana.
    define variable vhttBuffer as handle no-undo.
    define buffer PrmAna for PrmAna.

    vhttBuffer = phttPrmana:default-buffer-handle.
    for first PrmAna no-lock
        where PrmAna.tppar = pcTppar
          and PrmAna.Cdpar = pcCdpar
          and PrmAna.TpCon = pcTpcon
          and PrmAna.FgDos = plFgdos
          and PrmAna.TpUrg = pcTpurg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmAna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrmana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table PrmAna Chaine Travaux : Table Param Analytique/type travaux
    Notes  : service externe. Critère plFgdos = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcCdpar as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter plFgdos as logical    no-undo.
    define input parameter table-handle phttPrmana.
    define variable vhttBuffer as handle  no-undo.
    define buffer PrmAna for PrmAna.

    vhttBuffer = phttPrmana:default-buffer-handle.
    if plFgdos = ?
    then for each PrmAna no-lock
        where PrmAna.tppar = pcTppar
          and PrmAna.Cdpar = pcCdpar
          and PrmAna.TpCon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmAna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each PrmAna no-lock
        where PrmAna.tppar = pcTppar
          and PrmAna.Cdpar = pcCdpar
          and PrmAna.TpCon = pcTpcon
          and PrmAna.FgDos = plFgdos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmAna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrmana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhFgdos    as handle  no-undo.
    define variable vhTpurg    as handle  no-undo.
    define buffer PrmAna for PrmAna.

    create query vhttquery.
    vhttBuffer = ghttPrmana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrmana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar, output vhTpcon, output vhFgdos, output vhTpurg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmAna exclusive-lock
                where rowid(PrmAna) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmAna:handle, 'tppar/Cdpar/TpCon/FgDos/TpUrg: ', substitute('&1/&2/&3/&4/&5', vhTppar:buffer-value(), vhCdpar:buffer-value(), vhTpcon:buffer-value(), vhFgdos:buffer-value(), vhTpurg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer PrmAna:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrmana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer PrmAna for PrmAna.

    create query vhttquery.
    vhttBuffer = ghttPrmana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrmana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create PrmAna.
            if not outils:copyValidField(buffer PrmAna:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrmana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhFgdos    as handle  no-undo.
    define variable vhTpurg    as handle  no-undo.
    define buffer PrmAna for PrmAna.

    create query vhttquery.
    vhttBuffer = ghttPrmana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrmana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar, output vhTpcon, output vhFgdos, output vhTpurg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmAna exclusive-lock
                where rowid(Prmana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmAna:handle, 'tppar/Cdpar/TpCon/FgDos/TpUrg: ', substitute('&1/&2/&3/&4/&5', vhTppar:buffer-value(), vhCdpar:buffer-value(), vhTpcon:buffer-value(), vhFgdos:buffer-value(), vhTpurg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete PrmAna no-error.
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

