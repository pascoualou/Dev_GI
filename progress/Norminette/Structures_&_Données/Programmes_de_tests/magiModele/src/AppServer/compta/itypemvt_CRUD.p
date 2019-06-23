/*------------------------------------------------------------------------
File        : itypemvt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itypemvt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itypemvt.i}
{application/include/error.i}
define variable ghttitypemvt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNatjou-cd as handle, output phType-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/natjou-cd/type-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'natjou-cd' then phNatjou-cd = phBuffer:buffer-field(vi).
            when 'type-cle' then phType-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItypemvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItypemvt.
    run updateItypemvt.
    run createItypemvt.
end procedure.

procedure setItypemvt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItypemvt.
    ghttItypemvt = phttItypemvt.
    run crudItypemvt.
    delete object phttItypemvt.
end procedure.

procedure readItypemvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itypemvt Type de mouvement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piNatjou-cd as integer    no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter table-handle phttItypemvt.
    define variable vhttBuffer as handle no-undo.
    define buffer itypemvt for itypemvt.

    vhttBuffer = phttItypemvt:default-buffer-handle.
    for first itypemvt no-lock
        where itypemvt.soc-cd = piSoc-cd
          and itypemvt.etab-cd = piEtab-cd
          and itypemvt.natjou-cd = piNatjou-cd
          and itypemvt.type-cle = pcType-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypemvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypemvt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItypemvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itypemvt Type de mouvement
    Notes  : service externe. Critère piNatjou-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piNatjou-cd as integer    no-undo.
    define input parameter table-handle phttItypemvt.
    define variable vhttBuffer as handle  no-undo.
    define buffer itypemvt for itypemvt.

    vhttBuffer = phttItypemvt:default-buffer-handle.
    if piNatjou-cd = ?
    then for each itypemvt no-lock
        where itypemvt.soc-cd = piSoc-cd
          and itypemvt.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypemvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itypemvt no-lock
        where itypemvt.soc-cd = piSoc-cd
          and itypemvt.etab-cd = piEtab-cd
          and itypemvt.natjou-cd = piNatjou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypemvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypemvt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItypemvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNatjou-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define buffer itypemvt for itypemvt.

    create query vhttquery.
    vhttBuffer = ghttItypemvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItypemvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-cd, output vhType-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypemvt exclusive-lock
                where rowid(itypemvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypemvt:handle, 'soc-cd/etab-cd/natjou-cd/type-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-cd:buffer-value(), vhType-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itypemvt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItypemvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itypemvt for itypemvt.

    create query vhttquery.
    vhttBuffer = ghttItypemvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItypemvt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itypemvt.
            if not outils:copyValidField(buffer itypemvt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItypemvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNatjou-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define buffer itypemvt for itypemvt.

    create query vhttquery.
    vhttBuffer = ghttItypemvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItypemvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-cd, output vhType-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypemvt exclusive-lock
                where rowid(Itypemvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypemvt:handle, 'soc-cd/etab-cd/natjou-cd/type-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-cd:buffer-value(), vhType-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itypemvt no-error.
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

procedure deleteItypemvtSurEtabCd:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSociete   as integer no-undo.
    define input parameter piCodeEtabl as integer no-undo.
    
    define buffer itypemvt for itypemvt.

message "deleteItypemvtSurEtabCd " piSociete "// " piCodeEtabl. 

blocTrans:
    do transaction:
        for each itypemvt exclusive-lock
           where itypemvt.soc-cd  = piSociete
             and itypemvt.etab-cd = piCodeEtabl:
            delete itypemvt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

