/*------------------------------------------------------------------------
File        : eaget_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table eaget
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/eaget.i}
{application/include/error.i}
define variable ghtteaget as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phDtass as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/dtass/noint, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'dtass' then phDtass = phBuffer:buffer-field(vi).
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEaget private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEaget.
    run updateEaget.
    run createEaget.
end procedure.

procedure setEaget:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEaget.
    ghttEaget = phttEaget.
    run crudEaget.
    delete object phttEaget.
end procedure.

procedure readEaget:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table eaget 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pdaDtass as date       no-undo.
    define input parameter piNoint as integer    no-undo.
    define input parameter table-handle phttEaget.
    define variable vhttBuffer as handle no-undo.
    define buffer eaget for eaget.

    vhttBuffer = phttEaget:default-buffer-handle.
    for first eaget no-lock
        where eaget.tpcon = pcTpcon
          and eaget.nocon = piNocon
          and eaget.dtass = pdaDtass
          and eaget.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eaget:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEaget no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEaget:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table eaget 
    Notes  : service externe. Critère pdaDtass = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pdaDtass as date       no-undo.
    define input parameter table-handle phttEaget.
    define variable vhttBuffer as handle  no-undo.
    define buffer eaget for eaget.

    vhttBuffer = phttEaget:default-buffer-handle.
    if pdaDtass = ?
    then for each eaget no-lock
        where eaget.tpcon = pcTpcon
          and eaget.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eaget:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each eaget no-lock
        where eaget.tpcon = pcTpcon
          and eaget.nocon = piNocon
          and eaget.dtass = pdaDtass:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eaget:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEaget no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEaget private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhDtass    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer eaget for eaget.

    create query vhttquery.
    vhttBuffer = ghttEaget:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEaget:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhDtass, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eaget exclusive-lock
                where rowid(eaget) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eaget:handle, 'tpcon/nocon/dtass/noint: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhDtass:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer eaget:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEaget private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer eaget for eaget.

    create query vhttquery.
    vhttBuffer = ghttEaget:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEaget:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create eaget.
            if not outils:copyValidField(buffer eaget:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEaget private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhDtass    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer eaget for eaget.

    create query vhttquery.
    vhttBuffer = ghttEaget:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEaget:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhDtass, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eaget exclusive-lock
                where rowid(Eaget) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eaget:handle, 'tpcon/nocon/dtass/noint: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhDtass:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete eaget no-error.
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

