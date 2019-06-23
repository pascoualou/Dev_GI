/*------------------------------------------------------------------------
File        : PrmVt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table PrmVt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/PrmVt.i}
{application/include/error.i}
define variable ghttPrmVt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpven as handle, output phCdven as handle, output phTpcon as handle, output phFgdos as handle, output phTpurg as handle, output phCdtva as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpVen/CdVen/TpCon/FgDos/TpUrg/CdTva/NoOrd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpVen' then phTpven = phBuffer:buffer-field(vi).
            when 'CdVen' then phCdven = phBuffer:buffer-field(vi).
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'FgDos' then phFgdos = phBuffer:buffer-field(vi).
            when 'TpUrg' then phTpurg = phBuffer:buffer-field(vi).
            when 'CdTva' then phCdtva = phBuffer:buffer-field(vi).
            when 'NoOrd' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrmvt.
    run updatePrmvt.
    run createPrmvt.
end procedure.

procedure setPrmvt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrmvt.
    ghttPrmvt = phttPrmvt.
    run crudPrmvt.
    delete object phttPrmvt.
end procedure.

procedure readPrmvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table PrmVt Chaine travaux : parametrage de la ventilation analytique
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTpven as integer    no-undo.
    define input parameter pcCdven as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter plFgdos as logical    no-undo.
    define input parameter pcTpurg as character  no-undo.
    define input parameter piCdtva as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttPrmvt.
    define variable vhttBuffer as handle no-undo.
    define buffer PrmVt for PrmVt.

    vhttBuffer = phttPrmvt:default-buffer-handle.
    for first PrmVt no-lock
        where PrmVt.TpVen = piTpven
          and PrmVt.CdVen = pcCdven
          and PrmVt.TpCon = pcTpcon
          and PrmVt.FgDos = plFgdos
          and PrmVt.TpUrg = pcTpurg
          and PrmVt.CdTva = piCdtva
          and PrmVt.NoOrd = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmVt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmvt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrmvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table PrmVt Chaine travaux : parametrage de la ventilation analytique
    Notes  : service externe. Critère piCdtva = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piTpven as integer    no-undo.
    define input parameter pcCdven as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter plFgdos as logical    no-undo.
    define input parameter pcTpurg as character  no-undo.
    define input parameter piCdtva as integer    no-undo.
    define input parameter table-handle phttPrmvt.
    define variable vhttBuffer as handle  no-undo.
    define buffer PrmVt for PrmVt.

    vhttBuffer = phttPrmvt:default-buffer-handle.
    if piCdtva = ?
    then for each PrmVt no-lock
        where PrmVt.TpVen = piTpven
          and PrmVt.CdVen = pcCdven
          and PrmVt.TpCon = pcTpcon
          and PrmVt.FgDos = plFgdos
          and PrmVt.TpUrg = pcTpurg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmVt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each PrmVt no-lock
        where PrmVt.TpVen = piTpven
          and PrmVt.CdVen = pcCdven
          and PrmVt.TpCon = pcTpcon
          and PrmVt.FgDos = plFgdos
          and PrmVt.TpUrg = pcTpurg
          and PrmVt.CdTva = piCdtva:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmVt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmvt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpven    as handle  no-undo.
    define variable vhCdven    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhFgdos    as handle  no-undo.
    define variable vhTpurg    as handle  no-undo.
    define variable vhCdtva    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer PrmVt for PrmVt.

    create query vhttquery.
    vhttBuffer = ghttPrmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrmvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpven, output vhCdven, output vhTpcon, output vhFgdos, output vhTpurg, output vhCdtva, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmVt exclusive-lock
                where rowid(PrmVt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmVt:handle, 'TpVen/CdVen/TpCon/FgDos/TpUrg/CdTva/NoOrd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpven:buffer-value(), vhCdven:buffer-value(), vhTpcon:buffer-value(), vhFgdos:buffer-value(), vhTpurg:buffer-value(), vhCdtva:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer PrmVt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer PrmVt for PrmVt.

    create query vhttquery.
    vhttBuffer = ghttPrmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrmvt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create PrmVt.
            if not outils:copyValidField(buffer PrmVt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpven    as handle  no-undo.
    define variable vhCdven    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhFgdos    as handle  no-undo.
    define variable vhTpurg    as handle  no-undo.
    define variable vhCdtva    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer PrmVt for PrmVt.

    create query vhttquery.
    vhttBuffer = ghttPrmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrmvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpven, output vhCdven, output vhTpcon, output vhFgdos, output vhTpurg, output vhCdtva, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmVt exclusive-lock
                where rowid(Prmvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmVt:handle, 'TpVen/CdVen/TpCon/FgDos/TpUrg/CdTva/NoOrd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpven:buffer-value(), vhCdven:buffer-value(), vhTpcon:buffer-value(), vhFgdos:buffer-value(), vhTpurg:buffer-value(), vhCdtva:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete PrmVt no-error.
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

