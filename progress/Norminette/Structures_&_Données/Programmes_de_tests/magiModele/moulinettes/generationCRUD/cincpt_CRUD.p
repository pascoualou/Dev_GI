/*------------------------------------------------------------------------
File        : cincpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cincpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cincpt.i}
{application/include/error.i}
define variable ghttcincpt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-invest as handle, output phCpt-ori as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-invest/cpt-ori, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-invest' then phType-invest = phBuffer:buffer-field(vi).
            when 'cpt-ori' then phCpt-ori = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCincpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCincpt.
    run updateCincpt.
    run createCincpt.
end procedure.

procedure setCincpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCincpt.
    ghttCincpt = phttCincpt.
    run crudCincpt.
    delete object phttCincpt.
end procedure.

procedure readCincpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cincpt comptes comptables
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter pcCpt-ori     as character  no-undo.
    define input parameter table-handle phttCincpt.
    define variable vhttBuffer as handle no-undo.
    define buffer cincpt for cincpt.

    vhttBuffer = phttCincpt:default-buffer-handle.
    for first cincpt no-lock
        where cincpt.soc-cd = piSoc-cd
          and cincpt.etab-cd = piEtab-cd
          and cincpt.type-invest = piType-invest
          and cincpt.cpt-ori = pcCpt-ori:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cincpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCincpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCincpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cincpt comptes comptables
    Notes  : service externe. Critère piType-invest = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter table-handle phttCincpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer cincpt for cincpt.

    vhttBuffer = phttCincpt:default-buffer-handle.
    if piType-invest = ?
    then for each cincpt no-lock
        where cincpt.soc-cd = piSoc-cd
          and cincpt.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cincpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cincpt no-lock
        where cincpt.soc-cd = piSoc-cd
          and cincpt.etab-cd = piEtab-cd
          and cincpt.type-invest = piType-invest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cincpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCincpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCincpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define variable vhCpt-ori    as handle  no-undo.
    define buffer cincpt for cincpt.

    create query vhttquery.
    vhttBuffer = ghttCincpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCincpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest, output vhCpt-ori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cincpt exclusive-lock
                where rowid(cincpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cincpt:handle, 'soc-cd/etab-cd/type-invest/cpt-ori: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value(), vhCpt-ori:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cincpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCincpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cincpt for cincpt.

    create query vhttquery.
    vhttBuffer = ghttCincpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCincpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cincpt.
            if not outils:copyValidField(buffer cincpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCincpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define variable vhCpt-ori    as handle  no-undo.
    define buffer cincpt for cincpt.

    create query vhttquery.
    vhttBuffer = ghttCincpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCincpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest, output vhCpt-ori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cincpt exclusive-lock
                where rowid(Cincpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cincpt:handle, 'soc-cd/etab-cd/type-invest/cpt-ori: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value(), vhCpt-ori:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cincpt no-error.
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

