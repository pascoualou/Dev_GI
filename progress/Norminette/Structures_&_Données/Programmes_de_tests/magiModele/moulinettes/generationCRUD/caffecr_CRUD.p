/*------------------------------------------------------------------------
File        : caffecr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table caffecr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/caffecr.i}
{application/include/error.i}
define variable ghttcaffecr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phGi-ttyid as handle, output phSscoll-cle as handle, output phCpt-cd as handle, output phDacompta as handle, output phDatecr as handle, output phJou-cd as handle, output phPiece-compta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur gi-ttyid/sscoll-cle/cpt-cd/dacompta/datecr/jou-cd/piece-compta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'gi-ttyid' then phGi-ttyid = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'dacompta' then phDacompta = phBuffer:buffer-field(vi).
            when 'datecr' then phDatecr = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'piece-compta' then phPiece-compta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCaffecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCaffecr.
    run updateCaffecr.
    run createCaffecr.
end procedure.

procedure setCaffecr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCaffecr.
    ghttCaffecr = phttCaffecr.
    run crudCaffecr.
    delete object phttCaffecr.
end procedure.

procedure readCaffecr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table caffecr Table de consultation des affaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid     as character  no-undo.
    define input parameter pcSscoll-cle   as character  no-undo.
    define input parameter pcCpt-cd       as character  no-undo.
    define input parameter pdaDacompta     as date       no-undo.
    define input parameter pdaDatecr       as date       no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter table-handle phttCaffecr.
    define variable vhttBuffer as handle no-undo.
    define buffer caffecr for caffecr.

    vhttBuffer = phttCaffecr:default-buffer-handle.
    for first caffecr no-lock
        where caffecr.gi-ttyid = pcGi-ttyid
          and caffecr.sscoll-cle = pcSscoll-cle
          and caffecr.cpt-cd = pcCpt-cd
          and caffecr.dacompta = pdaDacompta
          and caffecr.datecr = pdaDatecr
          and caffecr.jou-cd = pcJou-cd
          and caffecr.piece-compta = piPiece-compta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCaffecr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCaffecr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table caffecr Table de consultation des affaires
    Notes  : service externe. Critère pcJou-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid     as character  no-undo.
    define input parameter pcSscoll-cle   as character  no-undo.
    define input parameter pcCpt-cd       as character  no-undo.
    define input parameter pdaDacompta     as date       no-undo.
    define input parameter pdaDatecr       as date       no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter table-handle phttCaffecr.
    define variable vhttBuffer as handle  no-undo.
    define buffer caffecr for caffecr.

    vhttBuffer = phttCaffecr:default-buffer-handle.
    if pcJou-cd = ?
    then for each caffecr no-lock
        where caffecr.gi-ttyid = pcGi-ttyid
          and caffecr.sscoll-cle = pcSscoll-cle
          and caffecr.cpt-cd = pcCpt-cd
          and caffecr.dacompta = pdaDacompta
          and caffecr.datecr = pdaDatecr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each caffecr no-lock
        where caffecr.gi-ttyid = pcGi-ttyid
          and caffecr.sscoll-cle = pcSscoll-cle
          and caffecr.cpt-cd = pcCpt-cd
          and caffecr.dacompta = pdaDacompta
          and caffecr.datecr = pdaDatecr
          and caffecr.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCaffecr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCaffecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhDatecr    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define buffer caffecr for caffecr.

    create query vhttquery.
    vhttBuffer = ghttCaffecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCaffecr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhSscoll-cle, output vhCpt-cd, output vhDacompta, output vhDatecr, output vhJou-cd, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first caffecr exclusive-lock
                where rowid(caffecr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer caffecr:handle, 'gi-ttyid/sscoll-cle/cpt-cd/dacompta/datecr/jou-cd/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhGi-ttyid:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhDacompta:buffer-value(), vhDatecr:buffer-value(), vhJou-cd:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer caffecr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCaffecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer caffecr for caffecr.

    create query vhttquery.
    vhttBuffer = ghttCaffecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCaffecr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create caffecr.
            if not outils:copyValidField(buffer caffecr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCaffecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhDatecr    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define buffer caffecr for caffecr.

    create query vhttquery.
    vhttBuffer = ghttCaffecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCaffecr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhSscoll-cle, output vhCpt-cd, output vhDacompta, output vhDatecr, output vhJou-cd, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first caffecr exclusive-lock
                where rowid(Caffecr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer caffecr:handle, 'gi-ttyid/sscoll-cle/cpt-cd/dacompta/datecr/jou-cd/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhGi-ttyid:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhDacompta:buffer-value(), vhDatecr:buffer-value(), vhJou-cd:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete caffecr no-error.
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

