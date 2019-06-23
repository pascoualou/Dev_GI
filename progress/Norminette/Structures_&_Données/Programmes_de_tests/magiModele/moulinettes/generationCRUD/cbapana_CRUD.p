/*------------------------------------------------------------------------
File        : cbapana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbapana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbapana.i}
{application/include/error.i}
define variable ghttcbapana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phManu-int as handle, output phPos as handle, output phAna-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/manu-int/pos/ana-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'manu-int' then phManu-int = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
            when 'ana-cd' then phAna-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbapana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbapana.
    run updateCbapana.
    run createCbapana.
end procedure.

procedure setCbapana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbapana.
    ghttCbapana = phttCbapana.
    run crudCbapana.
    delete object phttCbapana.
end procedure.

procedure readCbapana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbapana Fichier des lignes analytiques BAP
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piManu-int as integer    no-undo.
    define input parameter piPos      as integer    no-undo.
    define input parameter pcAna-cd   as character  no-undo.
    define input parameter table-handle phttCbapana.
    define variable vhttBuffer as handle no-undo.
    define buffer cbapana for cbapana.

    vhttBuffer = phttCbapana:default-buffer-handle.
    for first cbapana no-lock
        where cbapana.soc-cd = piSoc-cd
          and cbapana.etab-cd = piEtab-cd
          and cbapana.manu-int = piManu-int
          and cbapana.pos = piPos
          and cbapana.ana-cd = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbapana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbapana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbapana Fichier des lignes analytiques BAP
    Notes  : service externe. Critère piPos = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piManu-int as integer    no-undo.
    define input parameter piPos      as integer    no-undo.
    define input parameter table-handle phttCbapana.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbapana for cbapana.

    vhttBuffer = phttCbapana:default-buffer-handle.
    if piPos = ?
    then for each cbapana no-lock
        where cbapana.soc-cd = piSoc-cd
          and cbapana.etab-cd = piEtab-cd
          and cbapana.manu-int = piManu-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbapana no-lock
        where cbapana.soc-cd = piSoc-cd
          and cbapana.etab-cd = piEtab-cd
          and cbapana.manu-int = piManu-int
          and cbapana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbapana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbapana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhManu-int    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define buffer cbapana for cbapana.

    create query vhttquery.
    vhttBuffer = ghttCbapana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbapana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhManu-int, output vhPos, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbapana exclusive-lock
                where rowid(cbapana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbapana:handle, 'soc-cd/etab-cd/manu-int/pos/ana-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhManu-int:buffer-value(), vhPos:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbapana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbapana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbapana for cbapana.

    create query vhttquery.
    vhttBuffer = ghttCbapana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbapana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbapana.
            if not outils:copyValidField(buffer cbapana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbapana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhManu-int    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define buffer cbapana for cbapana.

    create query vhttquery.
    vhttBuffer = ghttCbapana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbapana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhManu-int, output vhPos, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbapana exclusive-lock
                where rowid(Cbapana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbapana:handle, 'soc-cd/etab-cd/manu-int/pos/ana-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhManu-int:buffer-value(), vhPos:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbapana no-error.
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

