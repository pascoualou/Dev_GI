/*------------------------------------------------------------------------
File        : ijouscen_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ijouscen
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ijouscen.i}
{application/include/error.i}
define variable ghttijouscen as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phType-cle as handle, output phScen-cle as handle, output phOrdre-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/type-cle/scen-cle/ordre-num, 
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
       end case.
    end.
end function.

procedure crudIjouscen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIjouscen.
    run updateIjouscen.
    run createIjouscen.
end procedure.

procedure setIjouscen:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIjouscen.
    ghttIjouscen = phttIjouscen.
    run crudIjouscen.
    delete object phttIjouscen.
end procedure.

procedure readIjouscen:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ijouscen Scenario de journal
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter pcScen-cle  as character  no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter table-handle phttIjouscen.
    define variable vhttBuffer as handle no-undo.
    define buffer ijouscen for ijouscen.

    vhttBuffer = phttIjouscen:default-buffer-handle.
    for first ijouscen no-lock
        where ijouscen.soc-cd = piSoc-cd
          and ijouscen.etab-cd = piEtab-cd
          and ijouscen.jou-cd = pcJou-cd
          and ijouscen.type-cle = pcType-cle
          and ijouscen.scen-cle = pcScen-cle
          and ijouscen.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ijouscen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIjouscen no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIjouscen:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ijouscen Scenario de journal
    Notes  : service externe. Critère pcScen-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter pcScen-cle  as character  no-undo.
    define input parameter table-handle phttIjouscen.
    define variable vhttBuffer as handle  no-undo.
    define buffer ijouscen for ijouscen.

    vhttBuffer = phttIjouscen:default-buffer-handle.
    if pcScen-cle = ?
    then for each ijouscen no-lock
        where ijouscen.soc-cd = piSoc-cd
          and ijouscen.etab-cd = piEtab-cd
          and ijouscen.jou-cd = pcJou-cd
          and ijouscen.type-cle = pcType-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ijouscen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ijouscen no-lock
        where ijouscen.soc-cd = piSoc-cd
          and ijouscen.etab-cd = piEtab-cd
          and ijouscen.jou-cd = pcJou-cd
          and ijouscen.type-cle = pcType-cle
          and ijouscen.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ijouscen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIjouscen no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIjouscen private:
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
    define buffer ijouscen for ijouscen.

    create query vhttquery.
    vhttBuffer = ghttIjouscen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIjouscen:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhType-cle, output vhScen-cle, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ijouscen exclusive-lock
                where rowid(ijouscen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ijouscen:handle, 'soc-cd/etab-cd/jou-cd/type-cle/scen-cle/ordre-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhType-cle:buffer-value(), vhScen-cle:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ijouscen:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIjouscen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ijouscen for ijouscen.

    create query vhttquery.
    vhttBuffer = ghttIjouscen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIjouscen:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ijouscen.
            if not outils:copyValidField(buffer ijouscen:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIjouscen private:
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
    define buffer ijouscen for ijouscen.

    create query vhttquery.
    vhttBuffer = ghttIjouscen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIjouscen:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhType-cle, output vhScen-cle, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ijouscen exclusive-lock
                where rowid(Ijouscen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ijouscen:handle, 'soc-cd/etab-cd/jou-cd/type-cle/scen-cle/ordre-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhType-cle:buffer-value(), vhScen-cle:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ijouscen no-error.
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

