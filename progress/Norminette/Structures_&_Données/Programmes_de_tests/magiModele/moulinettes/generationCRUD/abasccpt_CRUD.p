/*------------------------------------------------------------------------
File        : abasccpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table abasccpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/abasccpt.i}
{application/include/error.i}
define variable ghttabasccpt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType as handle, output phCpt-anc as handle, output phSscoll-anc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type/cpt-anc/sscoll-anc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
            when 'cpt-anc' then phCpt-anc = phBuffer:buffer-field(vi).
            when 'sscoll-anc' then phSscoll-anc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAbasccpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAbasccpt.
    run updateAbasccpt.
    run createAbasccpt.
end procedure.

procedure setAbasccpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbasccpt.
    ghttAbasccpt = phttAbasccpt.
    run crudAbasccpt.
    delete object phttAbasccpt.
end procedure.

procedure readAbasccpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table abasccpt Table de correspondance compte de banque
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcType       as character  no-undo.
    define input parameter pcCpt-anc    as character  no-undo.
    define input parameter pcSscoll-anc as character  no-undo.
    define input parameter table-handle phttAbasccpt.
    define variable vhttBuffer as handle no-undo.
    define buffer abasccpt for abasccpt.

    vhttBuffer = phttAbasccpt:default-buffer-handle.
    for first abasccpt no-lock
        where abasccpt.soc-cd = piSoc-cd
          and abasccpt.etab-cd = piEtab-cd
          and abasccpt.type = pcType
          and abasccpt.cpt-anc = pcCpt-anc
          and abasccpt.sscoll-anc = pcSscoll-anc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abasccpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbasccpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAbasccpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table abasccpt Table de correspondance compte de banque
    Notes  : service externe. Critère pcCpt-anc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcType       as character  no-undo.
    define input parameter pcCpt-anc    as character  no-undo.
    define input parameter table-handle phttAbasccpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer abasccpt for abasccpt.

    vhttBuffer = phttAbasccpt:default-buffer-handle.
    if pcCpt-anc = ?
    then for each abasccpt no-lock
        where abasccpt.soc-cd = piSoc-cd
          and abasccpt.etab-cd = piEtab-cd
          and abasccpt.type = pcType:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abasccpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each abasccpt no-lock
        where abasccpt.soc-cd = piSoc-cd
          and abasccpt.etab-cd = piEtab-cd
          and abasccpt.type = pcType
          and abasccpt.cpt-anc = pcCpt-anc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abasccpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbasccpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAbasccpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhCpt-anc    as handle  no-undo.
    define variable vhSscoll-anc    as handle  no-undo.
    define buffer abasccpt for abasccpt.

    create query vhttquery.
    vhttBuffer = ghttAbasccpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAbasccpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType, output vhCpt-anc, output vhSscoll-anc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abasccpt exclusive-lock
                where rowid(abasccpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abasccpt:handle, 'soc-cd/etab-cd/type/cpt-anc/sscoll-anc: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType:buffer-value(), vhCpt-anc:buffer-value(), vhSscoll-anc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer abasccpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAbasccpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer abasccpt for abasccpt.

    create query vhttquery.
    vhttBuffer = ghttAbasccpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAbasccpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create abasccpt.
            if not outils:copyValidField(buffer abasccpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAbasccpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhCpt-anc    as handle  no-undo.
    define variable vhSscoll-anc    as handle  no-undo.
    define buffer abasccpt for abasccpt.

    create query vhttquery.
    vhttBuffer = ghttAbasccpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAbasccpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType, output vhCpt-anc, output vhSscoll-anc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abasccpt exclusive-lock
                where rowid(Abasccpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abasccpt:handle, 'soc-cd/etab-cd/type/cpt-anc/sscoll-anc: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType:buffer-value(), vhCpt-anc:buffer-value(), vhSscoll-anc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete abasccpt no-error.
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

