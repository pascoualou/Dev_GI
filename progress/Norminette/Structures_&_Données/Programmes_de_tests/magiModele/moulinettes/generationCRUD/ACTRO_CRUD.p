/*------------------------------------------------------------------------
File        : ACTRO_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ACTRO
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ACTRO.i}
{application/include/error.i}
define variable ghttACTRO as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoaff as handle, output phNoact as handle, output phTprol as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NOAFF/NOACT/TPROL/NOROL, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NOAFF' then phNoaff = phBuffer:buffer-field(vi).
            when 'NOACT' then phNoact = phBuffer:buffer-field(vi).
            when 'TPROL' then phTprol = phBuffer:buffer-field(vi).
            when 'NOROL' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudActro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteActro.
    run updateActro.
    run createActro.
end procedure.

procedure setActro:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttActro.
    ghttActro = phttActro.
    run crudActro.
    delete object phttActro.
end procedure.

procedure readActro:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ACTRO 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoaff as integer    no-undo.
    define input parameter piNoact as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as integer    no-undo.
    define input parameter table-handle phttActro.
    define variable vhttBuffer as handle no-undo.
    define buffer ACTRO for ACTRO.

    vhttBuffer = phttActro:default-buffer-handle.
    for first ACTRO no-lock
        where ACTRO.NOAFF = piNoaff
          and ACTRO.NOACT = piNoact
          and ACTRO.TPROL = pcTprol
          and ACTRO.NOROL = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ACTRO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttActro no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getActro:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ACTRO 
    Notes  : service externe. Critère pcTprol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoaff as integer    no-undo.
    define input parameter piNoact as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter table-handle phttActro.
    define variable vhttBuffer as handle  no-undo.
    define buffer ACTRO for ACTRO.

    vhttBuffer = phttActro:default-buffer-handle.
    if pcTprol = ?
    then for each ACTRO no-lock
        where ACTRO.NOAFF = piNoaff
          and ACTRO.NOACT = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ACTRO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ACTRO no-lock
        where ACTRO.NOAFF = piNoaff
          and ACTRO.NOACT = piNoact
          and ACTRO.TPROL = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ACTRO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttActro no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateActro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoaff    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer ACTRO for ACTRO.

    create query vhttquery.
    vhttBuffer = ghttActro:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttActro:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoaff, output vhNoact, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ACTRO exclusive-lock
                where rowid(ACTRO) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ACTRO:handle, 'NOAFF/NOACT/TPROL/NOROL: ', substitute('&1/&2/&3/&4', vhNoaff:buffer-value(), vhNoact:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ACTRO:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createActro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ACTRO for ACTRO.

    create query vhttquery.
    vhttBuffer = ghttActro:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttActro:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ACTRO.
            if not outils:copyValidField(buffer ACTRO:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteActro private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoaff    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer ACTRO for ACTRO.

    create query vhttquery.
    vhttBuffer = ghttActro:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttActro:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoaff, output vhNoact, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ACTRO exclusive-lock
                where rowid(Actro) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ACTRO:handle, 'NOAFF/NOACT/TPROL/NOROL: ', substitute('&1/&2/&3/&4', vhNoaff:buffer-value(), vhNoact:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ACTRO no-error.
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

