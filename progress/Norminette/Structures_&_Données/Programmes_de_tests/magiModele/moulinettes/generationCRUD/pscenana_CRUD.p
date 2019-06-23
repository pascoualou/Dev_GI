/*------------------------------------------------------------------------
File        : pscenana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pscenana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pscenana.i}
{application/include/error.i}
define variable ghttpscenana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phType-cle as handle, output phScen-cle as handle, output phOrdre-num as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/type-cle/scen-cle/ordre-num/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'type-cle' then phType-cle = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPscenana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePscenana.
    run updatePscenana.
    run createPscenana.
end procedure.

procedure setPscenana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPscenana.
    ghttPscenana = phttPscenana.
    run crudPscenana.
    delete object phttPscenana.
end procedure.

procedure readPscenana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pscenana Fichier scenario analytique
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter pcScen-cle  as character  no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter table-handle phttPscenana.
    define variable vhttBuffer as handle no-undo.
    define buffer pscenana for pscenana.

    vhttBuffer = phttPscenana:default-buffer-handle.
    for first pscenana no-lock
        where pscenana.soc-cd = piSoc-cd
          and pscenana.etab-cd = piEtab-cd
          and pscenana.jou-cd = pcJou-cd
          and pscenana.type-cle = pcType-cle
          and pscenana.scen-cle = pcScen-cle
          and pscenana.ordre-num = piOrdre-num
          and pscenana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pscenana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPscenana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPscenana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pscenana Fichier scenario analytique
    Notes  : service externe. Critère piOrdre-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter pcScen-cle  as character  no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter table-handle phttPscenana.
    define variable vhttBuffer as handle  no-undo.
    define buffer pscenana for pscenana.

    vhttBuffer = phttPscenana:default-buffer-handle.
    if piOrdre-num = ?
    then for each pscenana no-lock
        where pscenana.soc-cd = piSoc-cd
          and pscenana.etab-cd = piEtab-cd
          and pscenana.jou-cd = pcJou-cd
          and pscenana.type-cle = pcType-cle
          and pscenana.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pscenana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pscenana no-lock
        where pscenana.soc-cd = piSoc-cd
          and pscenana.etab-cd = piEtab-cd
          and pscenana.jou-cd = pcJou-cd
          and pscenana.type-cle = pcType-cle
          and pscenana.scen-cle = pcScen-cle
          and pscenana.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pscenana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPscenana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePscenana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer pscenana for pscenana.

    create query vhttquery.
    vhttBuffer = ghttPscenana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPscenana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhType-cle, output vhScen-cle, output vhOrdre-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pscenana exclusive-lock
                where rowid(pscenana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pscenana:handle, 'soc-cd/etab-cd/jou-cd/type-cle/scen-cle/ordre-num/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhType-cle:buffer-value(), vhScen-cle:buffer-value(), vhOrdre-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pscenana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPscenana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pscenana for pscenana.

    create query vhttquery.
    vhttBuffer = ghttPscenana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPscenana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pscenana.
            if not outils:copyValidField(buffer pscenana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePscenana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer pscenana for pscenana.

    create query vhttquery.
    vhttBuffer = ghttPscenana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPscenana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhType-cle, output vhScen-cle, output vhOrdre-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pscenana exclusive-lock
                where rowid(Pscenana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pscenana:handle, 'soc-cd/etab-cd/jou-cd/type-cle/scen-cle/ordre-num/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhType-cle:buffer-value(), vhScen-cle:buffer-value(), vhOrdre-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pscenana no-error.
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

