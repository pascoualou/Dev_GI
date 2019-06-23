/*------------------------------------------------------------------------
File        : itcana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itcana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itcana.i}
{application/include/error.i}
define variable ghttitcana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNature-cd as handle, output phNiv-cd as handle, output phType as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/nature-cd/niv-cd/type, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'nature-cd' then phNature-cd = phBuffer:buffer-field(vi).
            when 'niv-cd' then phNiv-cd = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItcana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItcana.
    run updateItcana.
    run createItcana.
end procedure.

procedure setItcana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItcana.
    ghttItcana = phttItcana.
    run crudItcana.
    delete object phttItcana.
end procedure.

procedure readItcana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itcana Transfert compta - parametres compta analytique
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNature-cd as character  no-undo.
    define input parameter piNiv-cd    as integer    no-undo.
    define input parameter pcType      as character  no-undo.
    define input parameter table-handle phttItcana.
    define variable vhttBuffer as handle no-undo.
    define buffer itcana for itcana.

    vhttBuffer = phttItcana:default-buffer-handle.
    for first itcana no-lock
        where itcana.soc-cd = piSoc-cd
          and itcana.etab-cd = piEtab-cd
          and itcana.nature-cd = pcNature-cd
          and itcana.niv-cd = piNiv-cd
          and itcana.type = pcType:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItcana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItcana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itcana Transfert compta - parametres compta analytique
    Notes  : service externe. Critère piNiv-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNature-cd as character  no-undo.
    define input parameter piNiv-cd    as integer    no-undo.
    define input parameter table-handle phttItcana.
    define variable vhttBuffer as handle  no-undo.
    define buffer itcana for itcana.

    vhttBuffer = phttItcana:default-buffer-handle.
    if piNiv-cd = ?
    then for each itcana no-lock
        where itcana.soc-cd = piSoc-cd
          and itcana.etab-cd = piEtab-cd
          and itcana.nature-cd = pcNature-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itcana no-lock
        where itcana.soc-cd = piSoc-cd
          and itcana.etab-cd = piEtab-cd
          and itcana.nature-cd = pcNature-cd
          and itcana.niv-cd = piNiv-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItcana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItcana private:
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
    define variable vhType    as handle  no-undo.
    define buffer itcana for itcana.

    create query vhttquery.
    vhttBuffer = ghttItcana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItcana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNature-cd, output vhNiv-cd, output vhType).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itcana exclusive-lock
                where rowid(itcana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itcana:handle, 'soc-cd/etab-cd/nature-cd/niv-cd/type: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNature-cd:buffer-value(), vhNiv-cd:buffer-value(), vhType:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itcana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItcana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itcana for itcana.

    create query vhttquery.
    vhttBuffer = ghttItcana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItcana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itcana.
            if not outils:copyValidField(buffer itcana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItcana private:
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
    define variable vhType    as handle  no-undo.
    define buffer itcana for itcana.

    create query vhttquery.
    vhttBuffer = ghttItcana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItcana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNature-cd, output vhNiv-cd, output vhType).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itcana exclusive-lock
                where rowid(Itcana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itcana:handle, 'soc-cd/etab-cd/nature-cd/niv-cd/type: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNature-cd:buffer-value(), vhNiv-cd:buffer-value(), vhType:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itcana no-error.
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

