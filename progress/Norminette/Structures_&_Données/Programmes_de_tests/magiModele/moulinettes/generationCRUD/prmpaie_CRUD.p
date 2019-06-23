/*------------------------------------------------------------------------
File        : prmpaie_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table prmpaie
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/prmpaie.i}
{application/include/error.i}
define variable ghttprmpaie as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phDtdeb as handle, output phCoeff as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/dtdeb/coeff, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
            when 'coeff' then phCoeff = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrmpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrmpaie.
    run updatePrmpaie.
    run createPrmpaie.
end procedure.

procedure setPrmpaie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrmpaie.
    ghttPrmpaie = phttPrmpaie.
    run crudPrmpaie.
    delete object phttPrmpaie.
end procedure.

procedure readPrmpaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table prmpaie 0208/0323 : avenant 69 de Paie
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter pcCoeff as character  no-undo.
    define input parameter table-handle phttPrmpaie.
    define variable vhttBuffer as handle no-undo.
    define buffer prmpaie for prmpaie.

    vhttBuffer = phttPrmpaie:default-buffer-handle.
    for first prmpaie no-lock
        where prmpaie.tppar = pcTppar
          and prmpaie.dtdeb = pdaDtdeb
          and prmpaie.coeff = pcCoeff:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prmpaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmpaie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrmpaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table prmpaie 0208/0323 : avenant 69 de Paie
    Notes  : service externe. Critère pdaDtdeb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter table-handle phttPrmpaie.
    define variable vhttBuffer as handle  no-undo.
    define buffer prmpaie for prmpaie.

    vhttBuffer = phttPrmpaie:default-buffer-handle.
    if pdaDtdeb = ?
    then for each prmpaie no-lock
        where prmpaie.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prmpaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each prmpaie no-lock
        where prmpaie.tppar = pcTppar
          and prmpaie.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prmpaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmpaie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrmpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhCoeff    as handle  no-undo.
    define buffer prmpaie for prmpaie.

    create query vhttquery.
    vhttBuffer = ghttPrmpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrmpaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhDtdeb, output vhCoeff).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prmpaie exclusive-lock
                where rowid(prmpaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prmpaie:handle, 'tppar/dtdeb/coeff: ', substitute('&1/&2/&3', vhTppar:buffer-value(), vhDtdeb:buffer-value(), vhCoeff:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer prmpaie:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrmpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer prmpaie for prmpaie.

    create query vhttquery.
    vhttBuffer = ghttPrmpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrmpaie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create prmpaie.
            if not outils:copyValidField(buffer prmpaie:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrmpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhCoeff    as handle  no-undo.
    define buffer prmpaie for prmpaie.

    create query vhttquery.
    vhttBuffer = ghttPrmpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrmpaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhDtdeb, output vhCoeff).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prmpaie exclusive-lock
                where rowid(Prmpaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prmpaie:handle, 'tppar/dtdeb/coeff: ', substitute('&1/&2/&3', vhTppar:buffer-value(), vhDtdeb:buffer-value(), vhCoeff:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete prmpaie no-error.
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

