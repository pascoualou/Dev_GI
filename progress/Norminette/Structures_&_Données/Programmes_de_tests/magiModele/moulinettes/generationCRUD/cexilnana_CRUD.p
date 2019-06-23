/*------------------------------------------------------------------------
File        : cexilnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cexilnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cexilnana.i}
{application/include/error.i}
define variable ghttcexilnana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNoimm as handle, output phJou-cd as handle, output phAnnee as handle, output phMois as handle, output phOrder-num as handle, output phLig as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/noimm/jou-cd/annee/mois/order-num/lig/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'mois' then phMois = phBuffer:buffer-field(vi).
            when 'order-num' then phOrder-num = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCexilnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCexilnana.
    run updateCexilnana.
    run createCexilnana.
end procedure.

procedure setCexilnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCexilnana.
    ghttCexilnana = phttCexilnana.
    run crudCexilnana.
    delete object phttCexilnana.
end procedure.

procedure readCexilnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cexilnana Analytique charges locatives immeuble
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piNoimm     as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piAnnee     as integer    no-undo.
    define input parameter piMois      as integer    no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter table-handle phttCexilnana.
    define variable vhttBuffer as handle no-undo.
    define buffer cexilnana for cexilnana.

    vhttBuffer = phttCexilnana:default-buffer-handle.
    for first cexilnana no-lock
        where cexilnana.soc-cd = piSoc-cd
          and cexilnana.noimm = piNoimm
          and cexilnana.jou-cd = pcJou-cd
          and cexilnana.annee = piAnnee
          and cexilnana.mois = piMois
          and cexilnana.order-num = piOrder-num
          and cexilnana.lig = piLig
          and cexilnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexilnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexilnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCexilnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cexilnana Analytique charges locatives immeuble
    Notes  : service externe. Critère piLig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piNoimm     as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piAnnee     as integer    no-undo.
    define input parameter piMois      as integer    no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttCexilnana.
    define variable vhttBuffer as handle  no-undo.
    define buffer cexilnana for cexilnana.

    vhttBuffer = phttCexilnana:default-buffer-handle.
    if piLig = ?
    then for each cexilnana no-lock
        where cexilnana.soc-cd = piSoc-cd
          and cexilnana.noimm = piNoimm
          and cexilnana.jou-cd = pcJou-cd
          and cexilnana.annee = piAnnee
          and cexilnana.mois = piMois
          and cexilnana.order-num = piOrder-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexilnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cexilnana no-lock
        where cexilnana.soc-cd = piSoc-cd
          and cexilnana.noimm = piNoimm
          and cexilnana.jou-cd = pcJou-cd
          and cexilnana.annee = piAnnee
          and cexilnana.mois = piMois
          and cexilnana.order-num = piOrder-num
          and cexilnana.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexilnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexilnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCexilnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer cexilnana for cexilnana.

    create query vhttquery.
    vhttBuffer = ghttCexilnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCexilnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNoimm, output vhJou-cd, output vhAnnee, output vhMois, output vhOrder-num, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexilnana exclusive-lock
                where rowid(cexilnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexilnana:handle, 'soc-cd/noimm/jou-cd/annee/mois/order-num/lig/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhNoimm:buffer-value(), vhJou-cd:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value(), vhOrder-num:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cexilnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCexilnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cexilnana for cexilnana.

    create query vhttquery.
    vhttBuffer = ghttCexilnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCexilnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cexilnana.
            if not outils:copyValidField(buffer cexilnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCexilnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer cexilnana for cexilnana.

    create query vhttquery.
    vhttBuffer = ghttCexilnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCexilnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNoimm, output vhJou-cd, output vhAnnee, output vhMois, output vhOrder-num, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexilnana exclusive-lock
                where rowid(Cexilnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexilnana:handle, 'soc-cd/noimm/jou-cd/annee/mois/order-num/lig/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhNoimm:buffer-value(), vhJou-cd:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value(), vhOrder-num:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cexilnana no-error.
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

