/*------------------------------------------------------------------------
File        : cbilcol_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbilcol
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbilcol.i}
{application/include/error.i}
define variable ghttcbilcol as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phLibpays-cd as handle, output phBilan-cd as handle, output phColonne-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/libpays-cd/bilan-cd/colonne-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'libpays-cd' then phLibpays-cd = phBuffer:buffer-field(vi).
            when 'bilan-cd' then phBilan-cd = phBuffer:buffer-field(vi).
            when 'colonne-num' then phColonne-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbilcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbilcol.
    run updateCbilcol.
    run createCbilcol.
end procedure.

procedure setCbilcol:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbilcol.
    ghttCbilcol = phttCbilcol.
    run crudCbilcol.
    delete object phttCbilcol.
end procedure.

procedure readCbilcol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbilcol Detail colonne des bilans
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcLibpays-cd  as character  no-undo.
    define input parameter pcBilan-cd    as character  no-undo.
    define input parameter pcColonne-num as character  no-undo.
    define input parameter table-handle phttCbilcol.
    define variable vhttBuffer as handle no-undo.
    define buffer cbilcol for cbilcol.

    vhttBuffer = phttCbilcol:default-buffer-handle.
    for first cbilcol no-lock
        where cbilcol.soc-cd = piSoc-cd
          and cbilcol.etab-cd = piEtab-cd
          and cbilcol.libpays-cd = pcLibpays-cd
          and cbilcol.bilan-cd = pcBilan-cd
          and cbilcol.colonne-num = pcColonne-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilcol no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbilcol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbilcol Detail colonne des bilans
    Notes  : service externe. Critère pcBilan-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcLibpays-cd  as character  no-undo.
    define input parameter pcBilan-cd    as character  no-undo.
    define input parameter table-handle phttCbilcol.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbilcol for cbilcol.

    vhttBuffer = phttCbilcol:default-buffer-handle.
    if pcBilan-cd = ?
    then for each cbilcol no-lock
        where cbilcol.soc-cd = piSoc-cd
          and cbilcol.etab-cd = piEtab-cd
          and cbilcol.libpays-cd = pcLibpays-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbilcol no-lock
        where cbilcol.soc-cd = piSoc-cd
          and cbilcol.etab-cd = piEtab-cd
          and cbilcol.libpays-cd = pcLibpays-cd
          and cbilcol.bilan-cd = pcBilan-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilcol no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbilcol private:
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
    define variable vhColonne-num    as handle  no-undo.
    define buffer cbilcol for cbilcol.

    create query vhttquery.
    vhttBuffer = ghttCbilcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbilcol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibpays-cd, output vhBilan-cd, output vhColonne-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilcol exclusive-lock
                where rowid(cbilcol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilcol:handle, 'soc-cd/etab-cd/libpays-cd/bilan-cd/colonne-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibpays-cd:buffer-value(), vhBilan-cd:buffer-value(), vhColonne-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbilcol:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbilcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbilcol for cbilcol.

    create query vhttquery.
    vhttBuffer = ghttCbilcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbilcol:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbilcol.
            if not outils:copyValidField(buffer cbilcol:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbilcol private:
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
    define variable vhColonne-num    as handle  no-undo.
    define buffer cbilcol for cbilcol.

    create query vhttquery.
    vhttBuffer = ghttCbilcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbilcol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibpays-cd, output vhBilan-cd, output vhColonne-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilcol exclusive-lock
                where rowid(Cbilcol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilcol:handle, 'soc-cd/etab-cd/libpays-cd/bilan-cd/colonne-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibpays-cd:buffer-value(), vhBilan-cd:buffer-value(), vhColonne-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbilcol no-error.
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

