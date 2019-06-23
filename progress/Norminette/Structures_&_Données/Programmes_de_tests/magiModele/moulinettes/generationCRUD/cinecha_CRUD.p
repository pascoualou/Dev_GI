/*------------------------------------------------------------------------
File        : cinecha_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinecha
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinecha.i}
{application/include/error.i}
define variable ghttcinecha as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCinecha private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinecha.
    run updateCinecha.
    run createCinecha.
end procedure.

procedure setCinecha:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinecha.
    ghttCinecha = phttCinecha.
    run crudCinecha.
    delete object phttCinecha.
end procedure.

procedure readCinecha:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinecha analytique investissement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-num as character  no-undo.
    define input parameter piRecno-reg  as integer    no-undo.
    define input parameter piPos        as integer    no-undo.
    define input parameter table-handle phttCinecha.
    define variable vhttBuffer as handle no-undo.
    define buffer cinecha for cinecha.

    vhttBuffer = phttCinecha:default-buffer-handle.
    for first cinecha no-lock
        where cinecha.soc-cd = piSoc-cd
          and cinecha.etab-cd = piEtab-cd
          and cinecha.invest-num = pcInvest-num
          and cinecha.recno-reg = piRecno-reg
          and cinecha.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinecha:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinecha no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinecha:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinecha analytique investissement
    Notes  : service externe. Critère piRecno-reg = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-num as character  no-undo.
    define input parameter piRecno-reg  as integer    no-undo.
    define input parameter table-handle phttCinecha.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinecha for cinecha.

    vhttBuffer = phttCinecha:default-buffer-handle.
    if piRecno-reg = ?
    then for each cinecha no-lock
        where cinecha.soc-cd = piSoc-cd
          and cinecha.etab-cd = piEtab-cd
          and cinecha.invest-num = pcInvest-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinecha:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinecha no-lock
        where cinecha.soc-cd = piSoc-cd
          and cinecha.etab-cd = piEtab-cd
          and cinecha.invest-num = pcInvest-num
          and cinecha.recno-reg = piRecno-reg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinecha:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinecha no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinecha private:
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
    define buffer cinecha for cinecha.

    create query vhttquery.
    vhttBuffer = ghttCinecha:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinecha:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-num, output vhRecno-reg, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinecha exclusive-lock
                where rowid(cinecha) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinecha:handle, 'soc-cd/etab-cd/invest-num/recno-reg/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-num:buffer-value(), vhRecno-reg:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinecha:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinecha private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinecha for cinecha.

    create query vhttquery.
    vhttBuffer = ghttCinecha:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinecha:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinecha.
            if not outils:copyValidField(buffer cinecha:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinecha private:
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
    define buffer cinecha for cinecha.

    create query vhttquery.
    vhttBuffer = ghttCinecha:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinecha:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-num, output vhRecno-reg, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinecha exclusive-lock
                where rowid(Cinecha) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinecha:handle, 'soc-cd/etab-cd/invest-num/recno-reg/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-num:buffer-value(), vhRecno-reg:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinecha no-error.
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

