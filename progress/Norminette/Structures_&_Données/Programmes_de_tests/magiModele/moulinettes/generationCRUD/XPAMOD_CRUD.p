/*------------------------------------------------------------------------
File        : XPAMOD_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table XPAMOD
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/XPAMOD.i}
{application/include/error.i}
define variable ghttXPAMOD as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNouti as handle, output phNolig as handle, output phModul as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nouti/nolig/modul, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nouti' then phNouti = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
            when 'modul' then phModul = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudXpamod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteXpamod.
    run updateXpamod.
    run createXpamod.
end procedure.

procedure setXpamod:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttXpamod.
    ghttXpamod = phttXpamod.
    run crudXpamod.
    delete object phttXpamod.
end procedure.

procedure readXpamod:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table XPAMOD Paramétrage des modules de calcul de la Paie (IBM)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNouti as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter pcModul as character  no-undo.
    define input parameter table-handle phttXpamod.
    define variable vhttBuffer as handle no-undo.
    define buffer XPAMOD for XPAMOD.

    vhttBuffer = phttXpamod:default-buffer-handle.
    for first XPAMOD no-lock
        where XPAMOD.nouti = piNouti
          and XPAMOD.nolig = piNolig
          and XPAMOD.modul = pcModul:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer XPAMOD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttXpamod no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getXpamod:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table XPAMOD Paramétrage des modules de calcul de la Paie (IBM)
    Notes  : service externe. Critère piNolig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNouti as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttXpamod.
    define variable vhttBuffer as handle  no-undo.
    define buffer XPAMOD for XPAMOD.

    vhttBuffer = phttXpamod:default-buffer-handle.
    if piNolig = ?
    then for each XPAMOD no-lock
        where XPAMOD.nouti = piNouti:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer XPAMOD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each XPAMOD no-lock
        where XPAMOD.nouti = piNouti
          and XPAMOD.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer XPAMOD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttXpamod no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateXpamod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNouti    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhModul    as handle  no-undo.
    define buffer XPAMOD for XPAMOD.

    create query vhttquery.
    vhttBuffer = ghttXpamod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttXpamod:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNouti, output vhNolig, output vhModul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first XPAMOD exclusive-lock
                where rowid(XPAMOD) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer XPAMOD:handle, 'nouti/nolig/modul: ', substitute('&1/&2/&3', vhNouti:buffer-value(), vhNolig:buffer-value(), vhModul:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer XPAMOD:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createXpamod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer XPAMOD for XPAMOD.

    create query vhttquery.
    vhttBuffer = ghttXpamod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttXpamod:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create XPAMOD.
            if not outils:copyValidField(buffer XPAMOD:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteXpamod private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNouti    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhModul    as handle  no-undo.
    define buffer XPAMOD for XPAMOD.

    create query vhttquery.
    vhttBuffer = ghttXpamod:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttXpamod:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNouti, output vhNolig, output vhModul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first XPAMOD exclusive-lock
                where rowid(Xpamod) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer XPAMOD:handle, 'nouti/nolig/modul: ', substitute('&1/&2/&3', vhNouti:buffer-value(), vhNolig:buffer-value(), vhModul:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete XPAMOD no-error.
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

