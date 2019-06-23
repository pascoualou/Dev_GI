/*------------------------------------------------------------------------
File        : aprmcrg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aprmcrg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aprmcrg.i}
{application/include/error.i}
define variable ghttaprmcrg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phScen-cle as handle, output phEntete1-mes as handle, output phEntete2-mes as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/scen-cle/entete1-mes/entete2-mes, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
            when 'entete1-mes' then phEntete1-mes = phBuffer:buffer-field(vi).
            when 'entete2-mes' then phEntete2-mes = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAprmcrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAprmcrg.
    run updateAprmcrg.
    run createAprmcrg.
end procedure.

procedure setAprmcrg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAprmcrg.
    ghttAprmcrg = phttAprmcrg.
    run crudAprmcrg.
    delete object phttAprmcrg.
end procedure.

procedure readAprmcrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aprmcrg Parametrage du CRG
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter pcScen-cle    as character  no-undo.
    define input parameter pcEntete1-mes as character  no-undo.
    define input parameter pcEntete2-mes as character  no-undo.
    define input parameter table-handle phttAprmcrg.
    define variable vhttBuffer as handle no-undo.
    define buffer aprmcrg for aprmcrg.

    vhttBuffer = phttAprmcrg:default-buffer-handle.
    for first aprmcrg no-lock
        where aprmcrg.soc-cd = piSoc-cd
          and aprmcrg.scen-cle = pcScen-cle
          and aprmcrg.entete1-mes = pcEntete1-mes
          and aprmcrg.entete2-mes = pcEntete2-mes:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprmcrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAprmcrg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAprmcrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aprmcrg Parametrage du CRG
    Notes  : service externe. Critère pcEntete1-mes = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter pcScen-cle    as character  no-undo.
    define input parameter pcEntete1-mes as character  no-undo.
    define input parameter table-handle phttAprmcrg.
    define variable vhttBuffer as handle  no-undo.
    define buffer aprmcrg for aprmcrg.

    vhttBuffer = phttAprmcrg:default-buffer-handle.
    if pcEntete1-mes = ?
    then for each aprmcrg no-lock
        where aprmcrg.soc-cd = piSoc-cd
          and aprmcrg.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprmcrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aprmcrg no-lock
        where aprmcrg.soc-cd = piSoc-cd
          and aprmcrg.scen-cle = pcScen-cle
          and aprmcrg.entete1-mes = pcEntete1-mes:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprmcrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAprmcrg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAprmcrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhEntete1-mes    as handle  no-undo.
    define variable vhEntete2-mes    as handle  no-undo.
    define buffer aprmcrg for aprmcrg.

    create query vhttquery.
    vhttBuffer = ghttAprmcrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAprmcrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhScen-cle, output vhEntete1-mes, output vhEntete2-mes).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aprmcrg exclusive-lock
                where rowid(aprmcrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aprmcrg:handle, 'soc-cd/scen-cle/entete1-mes/entete2-mes: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhScen-cle:buffer-value(), vhEntete1-mes:buffer-value(), vhEntete2-mes:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aprmcrg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAprmcrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aprmcrg for aprmcrg.

    create query vhttquery.
    vhttBuffer = ghttAprmcrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAprmcrg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aprmcrg.
            if not outils:copyValidField(buffer aprmcrg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAprmcrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhEntete1-mes    as handle  no-undo.
    define variable vhEntete2-mes    as handle  no-undo.
    define buffer aprmcrg for aprmcrg.

    create query vhttquery.
    vhttBuffer = ghttAprmcrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAprmcrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhScen-cle, output vhEntete1-mes, output vhEntete2-mes).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aprmcrg exclusive-lock
                where rowid(Aprmcrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aprmcrg:handle, 'soc-cd/scen-cle/entete1-mes/entete2-mes: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhScen-cle:buffer-value(), vhEntete1-mes:buffer-value(), vhEntete2-mes:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aprmcrg no-error.
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

