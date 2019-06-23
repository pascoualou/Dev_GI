/*------------------------------------------------------------------------
File        : itccdt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itccdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itccdt.i}
{application/include/error.i}
define variable ghttitccdt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNature-cd as handle, output phNiv-cd as handle, output phGsc-cd as handle, output phCode-cd as handle, output phType as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/nature-cd/niv-cd/gsc-cd/code-cd/type, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'nature-cd' then phNature-cd = phBuffer:buffer-field(vi).
            when 'niv-cd' then phNiv-cd = phBuffer:buffer-field(vi).
            when 'gsc-cd' then phGsc-cd = phBuffer:buffer-field(vi).
            when 'code-cd' then phCode-cd = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItccdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItccdt.
    run updateItccdt.
    run createItccdt.
end procedure.

procedure setItccdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItccdt.
    ghttItccdt = phttItccdt.
    run crudItccdt.
    delete object phttItccdt.
end procedure.

procedure readItccdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itccdt Transfert compta - parametres compta analytique - conditions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNature-cd as character  no-undo.
    define input parameter piNiv-cd    as integer    no-undo.
    define input parameter piGsc-cd    as integer    no-undo.
    define input parameter pcCode-cd   as character  no-undo.
    define input parameter pcType      as character  no-undo.
    define input parameter table-handle phttItccdt.
    define variable vhttBuffer as handle no-undo.
    define buffer itccdt for itccdt.

    vhttBuffer = phttItccdt:default-buffer-handle.
    for first itccdt no-lock
        where itccdt.soc-cd = piSoc-cd
          and itccdt.etab-cd = piEtab-cd
          and itccdt.nature-cd = pcNature-cd
          and itccdt.niv-cd = piNiv-cd
          and itccdt.gsc-cd = piGsc-cd
          and itccdt.code-cd = pcCode-cd
          and itccdt.type = pcType:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itccdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItccdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItccdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itccdt Transfert compta - parametres compta analytique - conditions
    Notes  : service externe. Critère pcCode-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNature-cd as character  no-undo.
    define input parameter piNiv-cd    as integer    no-undo.
    define input parameter piGsc-cd    as integer    no-undo.
    define input parameter pcCode-cd   as character  no-undo.
    define input parameter table-handle phttItccdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer itccdt for itccdt.

    vhttBuffer = phttItccdt:default-buffer-handle.
    if pcCode-cd = ?
    then for each itccdt no-lock
        where itccdt.soc-cd = piSoc-cd
          and itccdt.etab-cd = piEtab-cd
          and itccdt.nature-cd = pcNature-cd
          and itccdt.niv-cd = piNiv-cd
          and itccdt.gsc-cd = piGsc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itccdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itccdt no-lock
        where itccdt.soc-cd = piSoc-cd
          and itccdt.etab-cd = piEtab-cd
          and itccdt.nature-cd = pcNature-cd
          and itccdt.niv-cd = piNiv-cd
          and itccdt.gsc-cd = piGsc-cd
          and itccdt.code-cd = pcCode-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itccdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItccdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItccdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNature-cd    as handle  no-undo.
    define variable vhNiv-cd    as handle  no-undo.
    define variable vhGsc-cd    as handle  no-undo.
    define variable vhCode-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define buffer itccdt for itccdt.

    create query vhttquery.
    vhttBuffer = ghttItccdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItccdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNature-cd, output vhNiv-cd, output vhGsc-cd, output vhCode-cd, output vhType).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itccdt exclusive-lock
                where rowid(itccdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itccdt:handle, 'soc-cd/etab-cd/nature-cd/niv-cd/gsc-cd/code-cd/type: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNature-cd:buffer-value(), vhNiv-cd:buffer-value(), vhGsc-cd:buffer-value(), vhCode-cd:buffer-value(), vhType:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itccdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItccdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itccdt for itccdt.

    create query vhttquery.
    vhttBuffer = ghttItccdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItccdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itccdt.
            if not outils:copyValidField(buffer itccdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItccdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNature-cd    as handle  no-undo.
    define variable vhNiv-cd    as handle  no-undo.
    define variable vhGsc-cd    as handle  no-undo.
    define variable vhCode-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define buffer itccdt for itccdt.

    create query vhttquery.
    vhttBuffer = ghttItccdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItccdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNature-cd, output vhNiv-cd, output vhGsc-cd, output vhCode-cd, output vhType).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itccdt exclusive-lock
                where rowid(Itccdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itccdt:handle, 'soc-cd/etab-cd/nature-cd/niv-cd/gsc-cd/code-cd/type: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNature-cd:buffer-value(), vhNiv-cd:buffer-value(), vhGsc-cd:buffer-value(), vhCode-cd:buffer-value(), vhType:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itccdt no-error.
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

