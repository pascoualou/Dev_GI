/*------------------------------------------------------------------------
File        : cbaplnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbaplnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbaplnana.i}
{application/include/error.i}
define variable ghttcbaplnana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNum-int as handle, output phLig as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/num-int/lig/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbaplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbaplnana.
    run updateCbaplnana.
    run createCbaplnana.
end procedure.

procedure setCbaplnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbaplnana.
    ghttCbaplnana = phttCbaplnana.
    run crudCbaplnana.
    delete object phttCbaplnana.
end procedure.

procedure readCbaplnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbaplnana Lignes analytiqyes des saisie de paiement rapide
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter piPos     as integer    no-undo.
    define input parameter table-handle phttCbaplnana.
    define variable vhttBuffer as handle no-undo.
    define buffer cbaplnana for cbaplnana.

    vhttBuffer = phttCbaplnana:default-buffer-handle.
    for first cbaplnana no-lock
        where cbaplnana.soc-cd = piSoc-cd
          and cbaplnana.num-int = piNum-int
          and cbaplnana.lig = piLig
          and cbaplnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbaplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbaplnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbaplnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbaplnana Lignes analytiqyes des saisie de paiement rapide
    Notes  : service externe. Critère piLig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter table-handle phttCbaplnana.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbaplnana for cbaplnana.

    vhttBuffer = phttCbaplnana:default-buffer-handle.
    if piLig = ?
    then for each cbaplnana no-lock
        where cbaplnana.soc-cd = piSoc-cd
          and cbaplnana.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbaplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbaplnana no-lock
        where cbaplnana.soc-cd = piSoc-cd
          and cbaplnana.num-int = piNum-int
          and cbaplnana.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbaplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbaplnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbaplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer cbaplnana for cbaplnana.

    create query vhttquery.
    vhttBuffer = ghttCbaplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbaplnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNum-int, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbaplnana exclusive-lock
                where rowid(cbaplnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbaplnana:handle, 'soc-cd/num-int/lig/pos: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbaplnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbaplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbaplnana for cbaplnana.

    create query vhttquery.
    vhttBuffer = ghttCbaplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbaplnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbaplnana.
            if not outils:copyValidField(buffer cbaplnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbaplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer cbaplnana for cbaplnana.

    create query vhttquery.
    vhttBuffer = ghttCbaplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbaplnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNum-int, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbaplnana exclusive-lock
                where rowid(Cbaplnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbaplnana:handle, 'soc-cd/num-int/lig/pos: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbaplnana no-error.
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

