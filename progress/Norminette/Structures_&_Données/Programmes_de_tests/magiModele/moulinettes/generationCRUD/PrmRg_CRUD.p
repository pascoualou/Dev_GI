/*------------------------------------------------------------------------
File        : PrmRg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table PrmRg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/PrmRg.i}
{application/include/error.i}
define variable ghttPrmRg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdrgt as handle, output phTpcon as handle, output phFgdos as handle, output phTpurg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CdRgt/TpCon/FgDos/TpUrg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CdRgt' then phCdrgt = phBuffer:buffer-field(vi).
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'FgDos' then phFgdos = phBuffer:buffer-field(vi).
            when 'TpUrg' then phTpurg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrmrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrmrg.
    run updatePrmrg.
    run createPrmrg.
end procedure.

procedure setPrmrg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrmrg.
    ghttPrmrg = phttPrmrg.
    run crudPrmrg.
    delete object phttPrmrg.
end procedure.

procedure readPrmrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table PrmRg Chaine Travaux : Table Param Regoupement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdrgt as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter plFgdos as logical    no-undo.
    define input parameter pcTpurg as character  no-undo.
    define input parameter table-handle phttPrmrg.
    define variable vhttBuffer as handle no-undo.
    define buffer PrmRg for PrmRg.

    vhttBuffer = phttPrmrg:default-buffer-handle.
    for first PrmRg no-lock
        where PrmRg.CdRgt = pcCdrgt
          and PrmRg.TpCon = pcTpcon
          and PrmRg.FgDos = plFgdos
          and PrmRg.TpUrg = pcTpurg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmRg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmrg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrmrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table PrmRg Chaine Travaux : Table Param Regoupement
    Notes  : service externe. Critère plFgdos = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdrgt as character  no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter plFgdos as logical    no-undo.
    define input parameter table-handle phttPrmrg.
    define variable vhttBuffer as handle  no-undo.
    define buffer PrmRg for PrmRg.

    vhttBuffer = phttPrmrg:default-buffer-handle.
    if plFgdos = ?
    then for each PrmRg no-lock
        where PrmRg.CdRgt = pcCdrgt
          and PrmRg.TpCon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmRg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each PrmRg no-lock
        where PrmRg.CdRgt = pcCdrgt
          and PrmRg.TpCon = pcTpcon
          and PrmRg.FgDos = plFgdos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PrmRg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmrg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrmrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdrgt    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhFgdos    as handle  no-undo.
    define variable vhTpurg    as handle  no-undo.
    define buffer PrmRg for PrmRg.

    create query vhttquery.
    vhttBuffer = ghttPrmrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrmrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrgt, output vhTpcon, output vhFgdos, output vhTpurg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmRg exclusive-lock
                where rowid(PrmRg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmRg:handle, 'CdRgt/TpCon/FgDos/TpUrg: ', substitute('&1/&2/&3/&4', vhCdrgt:buffer-value(), vhTpcon:buffer-value(), vhFgdos:buffer-value(), vhTpurg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer PrmRg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrmrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer PrmRg for PrmRg.

    create query vhttquery.
    vhttBuffer = ghttPrmrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrmrg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create PrmRg.
            if not outils:copyValidField(buffer PrmRg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrmrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdrgt    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhFgdos    as handle  no-undo.
    define variable vhTpurg    as handle  no-undo.
    define buffer PrmRg for PrmRg.

    create query vhttquery.
    vhttBuffer = ghttPrmrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrmrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrgt, output vhTpcon, output vhFgdos, output vhTpurg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PrmRg exclusive-lock
                where rowid(Prmrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PrmRg:handle, 'CdRgt/TpCon/FgDos/TpUrg: ', substitute('&1/&2/&3/&4', vhCdrgt:buffer-value(), vhTpcon:buffer-value(), vhFgdos:buffer-value(), vhTpurg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete PrmRg no-error.
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

