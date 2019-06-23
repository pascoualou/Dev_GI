/*------------------------------------------------------------------------
File        : crbln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crbln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crbln.i}
{application/include/error.i}
define variable ghttcrbln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle, output phType-op-int as handle, output phDaecr as handle, output phRef-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int/type-op-int/daecr/ref-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'type-op-int' then phType-op-int = phBuffer:buffer-field(vi).
            when 'daecr' then phDaecr = phBuffer:buffer-field(vi).
            when 'ref-num' then phRef-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrbln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrbln.
    run updateCrbln.
    run createCrbln.
end procedure.

procedure setCrbln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrbln.
    ghttCrbln = phttCrbln.
    run crudCrbln.
    delete object phttCrbln.
end procedure.

procedure readCrbln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crbln Fichier lignes rapprochements bancaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piNum-int     as integer    no-undo.
    define input parameter piType-op-int as integer    no-undo.
    define input parameter pdaDaecr       as date       no-undo.
    define input parameter pcRef-num     as character  no-undo.
    define input parameter table-handle phttCrbln.
    define variable vhttBuffer as handle no-undo.
    define buffer crbln for crbln.

    vhttBuffer = phttCrbln:default-buffer-handle.
    for first crbln no-lock
        where crbln.soc-cd = piSoc-cd
          and crbln.etab-cd = piEtab-cd
          and crbln.num-int = piNum-int
          and crbln.type-op-int = piType-op-int
          and crbln.daecr = pdaDaecr
          and crbln.ref-num = pcRef-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrbln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrbln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crbln Fichier lignes rapprochements bancaires
    Notes  : service externe. Critère pdaDaecr = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piNum-int     as integer    no-undo.
    define input parameter piType-op-int as integer    no-undo.
    define input parameter pdaDaecr       as date       no-undo.
    define input parameter table-handle phttCrbln.
    define variable vhttBuffer as handle  no-undo.
    define buffer crbln for crbln.

    vhttBuffer = phttCrbln:default-buffer-handle.
    if pdaDaecr = ?
    then for each crbln no-lock
        where crbln.soc-cd = piSoc-cd
          and crbln.etab-cd = piEtab-cd
          and crbln.num-int = piNum-int
          and crbln.type-op-int = piType-op-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crbln no-lock
        where crbln.soc-cd = piSoc-cd
          and crbln.etab-cd = piEtab-cd
          and crbln.num-int = piNum-int
          and crbln.type-op-int = piType-op-int
          and crbln.daecr = pdaDaecr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrbln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrbln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhType-op-int    as handle  no-undo.
    define variable vhDaecr    as handle  no-undo.
    define variable vhRef-num    as handle  no-undo.
    define buffer crbln for crbln.

    create query vhttquery.
    vhttBuffer = ghttCrbln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrbln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhType-op-int, output vhDaecr, output vhRef-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crbln exclusive-lock
                where rowid(crbln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crbln:handle, 'soc-cd/etab-cd/num-int/type-op-int/daecr/ref-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhType-op-int:buffer-value(), vhDaecr:buffer-value(), vhRef-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crbln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrbln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crbln for crbln.

    create query vhttquery.
    vhttBuffer = ghttCrbln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrbln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crbln.
            if not outils:copyValidField(buffer crbln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrbln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhType-op-int    as handle  no-undo.
    define variable vhDaecr    as handle  no-undo.
    define variable vhRef-num    as handle  no-undo.
    define buffer crbln for crbln.

    create query vhttquery.
    vhttBuffer = ghttCrbln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrbln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhType-op-int, output vhDaecr, output vhRef-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crbln exclusive-lock
                where rowid(Crbln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crbln:handle, 'soc-cd/etab-cd/num-int/type-op-int/daecr/ref-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhType-op-int:buffer-value(), vhDaecr:buffer-value(), vhRef-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crbln no-error.
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

