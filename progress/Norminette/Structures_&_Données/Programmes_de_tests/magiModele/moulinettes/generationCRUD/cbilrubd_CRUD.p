/*------------------------------------------------------------------------
File        : cbilrubd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbilrubd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbilrubd.i}
{application/include/error.i}
define variable ghttcbilrubd as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phLibpays-cd as handle, output phBilan-cd as handle, output phNum-int as handle, output phColonne-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/libpays-cd/bilan-cd/num-int/colonne-num, 
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
            when 'colonne-num' then phColonne-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbilrubd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbilrubd.
    run updateCbilrubd.
    run createCbilrubd.
end procedure.

procedure setCbilrubd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbilrubd.
    ghttCbilrubd = phttCbilrubd.
    run crudCbilrubd.
    delete object phttCbilrubd.
end procedure.

procedure readCbilrubd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbilrubd cbilrubd
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcLibpays-cd  as character  no-undo.
    define input parameter pcBilan-cd    as character  no-undo.
    define input parameter piNum-int     as integer    no-undo.
    define input parameter piColonne-num as integer    no-undo.
    define input parameter table-handle phttCbilrubd.
    define variable vhttBuffer as handle no-undo.
    define buffer cbilrubd for cbilrubd.

    vhttBuffer = phttCbilrubd:default-buffer-handle.
    for first cbilrubd no-lock
        where cbilrubd.soc-cd = piSoc-cd
          and cbilrubd.etab-cd = piEtab-cd
          and cbilrubd.libpays-cd = pcLibpays-cd
          and cbilrubd.bilan-cd = pcBilan-cd
          and cbilrubd.num-int = piNum-int
          and cbilrubd.colonne-num = piColonne-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilrubd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilrubd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbilrubd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbilrubd cbilrubd
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcLibpays-cd  as character  no-undo.
    define input parameter pcBilan-cd    as character  no-undo.
    define input parameter piNum-int     as integer    no-undo.
    define input parameter table-handle phttCbilrubd.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbilrubd for cbilrubd.

    vhttBuffer = phttCbilrubd:default-buffer-handle.
    if piNum-int = ?
    then for each cbilrubd no-lock
        where cbilrubd.soc-cd = piSoc-cd
          and cbilrubd.etab-cd = piEtab-cd
          and cbilrubd.libpays-cd = pcLibpays-cd
          and cbilrubd.bilan-cd = pcBilan-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilrubd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbilrubd no-lock
        where cbilrubd.soc-cd = piSoc-cd
          and cbilrubd.etab-cd = piEtab-cd
          and cbilrubd.libpays-cd = pcLibpays-cd
          and cbilrubd.bilan-cd = pcBilan-cd
          and cbilrubd.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilrubd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilrubd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbilrubd private:
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
    define variable vhColonne-num    as handle  no-undo.
    define buffer cbilrubd for cbilrubd.

    create query vhttquery.
    vhttBuffer = ghttCbilrubd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbilrubd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibpays-cd, output vhBilan-cd, output vhNum-int, output vhColonne-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilrubd exclusive-lock
                where rowid(cbilrubd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilrubd:handle, 'soc-cd/etab-cd/libpays-cd/bilan-cd/num-int/colonne-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibpays-cd:buffer-value(), vhBilan-cd:buffer-value(), vhNum-int:buffer-value(), vhColonne-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbilrubd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbilrubd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbilrubd for cbilrubd.

    create query vhttquery.
    vhttBuffer = ghttCbilrubd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbilrubd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbilrubd.
            if not outils:copyValidField(buffer cbilrubd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbilrubd private:
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
    define variable vhColonne-num    as handle  no-undo.
    define buffer cbilrubd for cbilrubd.

    create query vhttquery.
    vhttBuffer = ghttCbilrubd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbilrubd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibpays-cd, output vhBilan-cd, output vhNum-int, output vhColonne-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilrubd exclusive-lock
                where rowid(Cbilrubd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilrubd:handle, 'soc-cd/etab-cd/libpays-cd/bilan-cd/num-int/colonne-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibpays-cd:buffer-value(), vhBilan-cd:buffer-value(), vhNum-int:buffer-value(), vhColonne-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbilrubd no-error.
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

