/*------------------------------------------------------------------------
File        : cinvana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinvana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinvana.i}
{application/include/error.i}
define variable ghttcinvana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phInvest-num as handle, output phRecno-reg as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/invest-num/recno-reg/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'invest-num' then phInvest-num = phBuffer:buffer-field(vi).
            when 'recno-reg' then phRecno-reg = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinvana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinvana.
    run updateCinvana.
    run createCinvana.
end procedure.

procedure setCinvana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinvana.
    ghttCinvana = phttCinvana.
    run crudCinvana.
    delete object phttCinvana.
end procedure.

procedure readCinvana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinvana ventilation ana inventaire
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-num as character  no-undo.
    define input parameter piRecno-reg  as integer    no-undo.
    define input parameter piPos        as integer    no-undo.
    define input parameter table-handle phttCinvana.
    define variable vhttBuffer as handle no-undo.
    define buffer cinvana for cinvana.

    vhttBuffer = phttCinvana:default-buffer-handle.
    for first cinvana no-lock
        where cinvana.soc-cd = piSoc-cd
          and cinvana.etab-cd = piEtab-cd
          and cinvana.invest-num = pcInvest-num
          and cinvana.recno-reg = piRecno-reg
          and cinvana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinvana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinvana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinvana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinvana ventilation ana inventaire
    Notes  : service externe. Critère piRecno-reg = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-num as character  no-undo.
    define input parameter piRecno-reg  as integer    no-undo.
    define input parameter table-handle phttCinvana.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinvana for cinvana.

    vhttBuffer = phttCinvana:default-buffer-handle.
    if piRecno-reg = ?
    then for each cinvana no-lock
        where cinvana.soc-cd = piSoc-cd
          and cinvana.etab-cd = piEtab-cd
          and cinvana.invest-num = pcInvest-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinvana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinvana no-lock
        where cinvana.soc-cd = piSoc-cd
          and cinvana.etab-cd = piEtab-cd
          and cinvana.invest-num = pcInvest-num
          and cinvana.recno-reg = piRecno-reg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinvana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinvana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinvana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhInvest-num    as handle  no-undo.
    define variable vhRecno-reg    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer cinvana for cinvana.

    create query vhttquery.
    vhttBuffer = ghttCinvana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinvana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-num, output vhRecno-reg, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinvana exclusive-lock
                where rowid(cinvana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinvana:handle, 'soc-cd/etab-cd/invest-num/recno-reg/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-num:buffer-value(), vhRecno-reg:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinvana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinvana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinvana for cinvana.

    create query vhttquery.
    vhttBuffer = ghttCinvana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinvana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinvana.
            if not outils:copyValidField(buffer cinvana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinvana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhInvest-num    as handle  no-undo.
    define variable vhRecno-reg    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer cinvana for cinvana.

    create query vhttquery.
    vhttBuffer = ghttCinvana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinvana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-num, output vhRecno-reg, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinvana exclusive-lock
                where rowid(Cinvana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinvana:handle, 'soc-cd/etab-cd/invest-num/recno-reg/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-num:buffer-value(), vhRecno-reg:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinvana no-error.
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

