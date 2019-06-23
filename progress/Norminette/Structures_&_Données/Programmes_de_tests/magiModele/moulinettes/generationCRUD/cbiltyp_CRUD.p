/*------------------------------------------------------------------------
File        : cbiltyp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbiltyp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbiltyp.i}
{application/include/error.i}
define variable ghttcbiltyp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phLibpays-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/libpays-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'libpays-cd' then phLibpays-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbiltyp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbiltyp.
    run updateCbiltyp.
    run createCbiltyp.
end procedure.

procedure setCbiltyp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbiltyp.
    ghttCbiltyp = phttCbiltyp.
    run crudCbiltyp.
    delete object phttCbiltyp.
end procedure.

procedure readCbiltyp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbiltyp Type de bilan
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcLibpays-cd as character  no-undo.
    define input parameter table-handle phttCbiltyp.
    define variable vhttBuffer as handle no-undo.
    define buffer cbiltyp for cbiltyp.

    vhttBuffer = phttCbiltyp:default-buffer-handle.
    for first cbiltyp no-lock
        where cbiltyp.soc-cd = piSoc-cd
          and cbiltyp.etab-cd = piEtab-cd
          and cbiltyp.libpays-cd = pcLibpays-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbiltyp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbiltyp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbiltyp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbiltyp Type de bilan
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCbiltyp.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbiltyp for cbiltyp.

    vhttBuffer = phttCbiltyp:default-buffer-handle.
    if piEtab-cd = ?
    then for each cbiltyp no-lock
        where cbiltyp.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbiltyp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbiltyp no-lock
        where cbiltyp.soc-cd = piSoc-cd
          and cbiltyp.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbiltyp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbiltyp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbiltyp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhLibpays-cd    as handle  no-undo.
    define buffer cbiltyp for cbiltyp.

    create query vhttquery.
    vhttBuffer = ghttCbiltyp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbiltyp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibpays-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbiltyp exclusive-lock
                where rowid(cbiltyp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbiltyp:handle, 'soc-cd/etab-cd/libpays-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibpays-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbiltyp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbiltyp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbiltyp for cbiltyp.

    create query vhttquery.
    vhttBuffer = ghttCbiltyp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbiltyp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbiltyp.
            if not outils:copyValidField(buffer cbiltyp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbiltyp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhLibpays-cd    as handle  no-undo.
    define buffer cbiltyp for cbiltyp.

    create query vhttquery.
    vhttBuffer = ghttCbiltyp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbiltyp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibpays-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbiltyp exclusive-lock
                where rowid(Cbiltyp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbiltyp:handle, 'soc-cd/etab-cd/libpays-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibpays-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbiltyp no-error.
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

