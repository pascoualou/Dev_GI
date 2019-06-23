/*------------------------------------------------------------------------
File        : cbilrub_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbilrub
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbilrub.i}
{application/include/error.i}
define variable ghttcbilrub as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phLibpays-cd as handle, output phBilan-cd as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/libpays-cd/bilan-cd/num-int, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'libpays-cd' then phLibpays-cd = phBuffer:buffer-field(vi).
            when 'bilan-cd' then phBilan-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbilrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbilrub.
    run updateCbilrub.
    run createCbilrub.
end procedure.

procedure setCbilrub:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbilrub.
    ghttCbilrub = phttCbilrub.
    run crudCbilrub.
    delete object phttCbilrub.
end procedure.

procedure readCbilrub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbilrub Rubrique pour les bilans
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcLibpays-cd as character  no-undo.
    define input parameter pcBilan-cd   as character  no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter table-handle phttCbilrub.
    define variable vhttBuffer as handle no-undo.
    define buffer cbilrub for cbilrub.

    vhttBuffer = phttCbilrub:default-buffer-handle.
    for first cbilrub no-lock
        where cbilrub.soc-cd = piSoc-cd
          and cbilrub.etab-cd = piEtab-cd
          and cbilrub.libpays-cd = pcLibpays-cd
          and cbilrub.bilan-cd = pcBilan-cd
          and cbilrub.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilrub no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbilrub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbilrub Rubrique pour les bilans
    Notes  : service externe. Critère pcBilan-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcLibpays-cd as character  no-undo.
    define input parameter pcBilan-cd   as character  no-undo.
    define input parameter table-handle phttCbilrub.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbilrub for cbilrub.

    vhttBuffer = phttCbilrub:default-buffer-handle.
    if pcBilan-cd = ?
    then for each cbilrub no-lock
        where cbilrub.soc-cd = piSoc-cd
          and cbilrub.etab-cd = piEtab-cd
          and cbilrub.libpays-cd = pcLibpays-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbilrub no-lock
        where cbilrub.soc-cd = piSoc-cd
          and cbilrub.etab-cd = piEtab-cd
          and cbilrub.libpays-cd = pcLibpays-cd
          and cbilrub.bilan-cd = pcBilan-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilrub no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbilrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhLibpays-cd    as handle  no-undo.
    define variable vhBilan-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer cbilrub for cbilrub.

    create query vhttquery.
    vhttBuffer = ghttCbilrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbilrub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibpays-cd, output vhBilan-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilrub exclusive-lock
                where rowid(cbilrub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilrub:handle, 'soc-cd/etab-cd/libpays-cd/bilan-cd/num-int: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibpays-cd:buffer-value(), vhBilan-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbilrub:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbilrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbilrub for cbilrub.

    create query vhttquery.
    vhttBuffer = ghttCbilrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbilrub:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbilrub.
            if not outils:copyValidField(buffer cbilrub:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbilrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhLibpays-cd    as handle  no-undo.
    define variable vhBilan-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer cbilrub for cbilrub.

    create query vhttquery.
    vhttBuffer = ghttCbilrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbilrub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibpays-cd, output vhBilan-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilrub exclusive-lock
                where rowid(Cbilrub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilrub:handle, 'soc-cd/etab-cd/libpays-cd/bilan-cd/num-int: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibpays-cd:buffer-value(), vhBilan-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbilrub no-error.
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

