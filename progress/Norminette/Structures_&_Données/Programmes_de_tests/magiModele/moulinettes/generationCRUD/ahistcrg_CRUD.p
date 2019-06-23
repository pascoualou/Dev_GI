/*------------------------------------------------------------------------
File        : ahistcrg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ahistcrg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ahistcrg.i}
{application/include/error.i}
define variable ghttahistcrg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCpt-cd as handle, output phDtdeb as handle, output phDtfin as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cpt-cd/dtdeb/dtfin, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
            when 'dtfin' then phDtfin = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAhistcrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAhistcrg.
    run updateAhistcrg.
    run createAhistcrg.
end procedure.

procedure setAhistcrg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAhistcrg.
    ghttAhistcrg = phttAhistcrg.
    run crudAhistcrg.
    delete object phttAhistcrg.
end procedure.

procedure readAhistcrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ahistcrg Historique des CRG
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter pdaDtdeb   as date       no-undo.
    define input parameter pdaDtfin   as date       no-undo.
    define input parameter table-handle phttAhistcrg.
    define variable vhttBuffer as handle no-undo.
    define buffer ahistcrg for ahistcrg.

    vhttBuffer = phttAhistcrg:default-buffer-handle.
    for first ahistcrg no-lock
        where ahistcrg.soc-cd = piSoc-cd
          and ahistcrg.etab-cd = piEtab-cd
          and ahistcrg.cpt-cd = pcCpt-cd
          and ahistcrg.dtdeb = pdaDtdeb
          and ahistcrg.dtfin = pdaDtfin:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahistcrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhistcrg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAhistcrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ahistcrg Historique des CRG
    Notes  : service externe. Critère pdaDtdeb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter pdaDtdeb   as date       no-undo.
    define input parameter table-handle phttAhistcrg.
    define variable vhttBuffer as handle  no-undo.
    define buffer ahistcrg for ahistcrg.

    vhttBuffer = phttAhistcrg:default-buffer-handle.
    if pdaDtdeb = ?
    then for each ahistcrg no-lock
        where ahistcrg.soc-cd = piSoc-cd
          and ahistcrg.etab-cd = piEtab-cd
          and ahistcrg.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahistcrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ahistcrg no-lock
        where ahistcrg.soc-cd = piSoc-cd
          and ahistcrg.etab-cd = piEtab-cd
          and ahistcrg.cpt-cd = pcCpt-cd
          and ahistcrg.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahistcrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhistcrg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAhistcrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhDtfin    as handle  no-undo.
    define buffer ahistcrg for ahistcrg.

    create query vhttquery.
    vhttBuffer = ghttAhistcrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAhistcrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-cd, output vhDtdeb, output vhDtfin).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahistcrg exclusive-lock
                where rowid(ahistcrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahistcrg:handle, 'soc-cd/etab-cd/cpt-cd/dtdeb/dtfin: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-cd:buffer-value(), vhDtdeb:buffer-value(), vhDtfin:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ahistcrg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAhistcrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ahistcrg for ahistcrg.

    create query vhttquery.
    vhttBuffer = ghttAhistcrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAhistcrg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ahistcrg.
            if not outils:copyValidField(buffer ahistcrg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAhistcrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhDtfin    as handle  no-undo.
    define buffer ahistcrg for ahistcrg.

    create query vhttquery.
    vhttBuffer = ghttAhistcrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAhistcrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-cd, output vhDtdeb, output vhDtfin).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahistcrg exclusive-lock
                where rowid(Ahistcrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahistcrg:handle, 'soc-cd/etab-cd/cpt-cd/dtdeb/dtfin: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-cd:buffer-value(), vhDtdeb:buffer-value(), vhDtfin:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ahistcrg no-error.
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

