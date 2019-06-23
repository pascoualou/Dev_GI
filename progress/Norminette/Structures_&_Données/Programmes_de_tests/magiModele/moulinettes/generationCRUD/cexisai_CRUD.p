/*------------------------------------------------------------------------
File        : cexisai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cexisai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cexisai.i}
{application/include/error.i}
define variable ghttcexisai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNoimm as handle, output phJou-cd as handle, output phAnnee as handle, output phMois as handle, output phOrder-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/noimm/jou-cd/annee/mois/order-num, 
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
       end case.
    end.
end function.

procedure crudCexisai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCexisai.
    run updateCexisai.
    run createCexisai.
end procedure.

procedure setCexisai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCexisai.
    ghttCexisai = phttCexisai.
    run crudCexisai.
    delete object phttCexisai.
end procedure.

procedure readCexisai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cexisai Entete Charges locatives par immeuble
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piNoimm     as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piAnnee     as integer    no-undo.
    define input parameter piMois      as integer    no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter table-handle phttCexisai.
    define variable vhttBuffer as handle no-undo.
    define buffer cexisai for cexisai.

    vhttBuffer = phttCexisai:default-buffer-handle.
    for first cexisai no-lock
        where cexisai.soc-cd = piSoc-cd
          and cexisai.noimm = piNoimm
          and cexisai.jou-cd = pcJou-cd
          and cexisai.annee = piAnnee
          and cexisai.mois = piMois
          and cexisai.order-num = piOrder-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexisai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexisai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCexisai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cexisai Entete Charges locatives par immeuble
    Notes  : service externe. Critère piMois = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piNoimm     as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piAnnee     as integer    no-undo.
    define input parameter piMois      as integer    no-undo.
    define input parameter table-handle phttCexisai.
    define variable vhttBuffer as handle  no-undo.
    define buffer cexisai for cexisai.

    vhttBuffer = phttCexisai:default-buffer-handle.
    if piMois = ?
    then for each cexisai no-lock
        where cexisai.soc-cd = piSoc-cd
          and cexisai.noimm = piNoimm
          and cexisai.jou-cd = pcJou-cd
          and cexisai.annee = piAnnee:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexisai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cexisai no-lock
        where cexisai.soc-cd = piSoc-cd
          and cexisai.noimm = piNoimm
          and cexisai.jou-cd = pcJou-cd
          and cexisai.annee = piAnnee
          and cexisai.mois = piMois:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexisai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexisai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCexisai private:
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
    define buffer cexisai for cexisai.

    create query vhttquery.
    vhttBuffer = ghttCexisai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCexisai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNoimm, output vhJou-cd, output vhAnnee, output vhMois, output vhOrder-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexisai exclusive-lock
                where rowid(cexisai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexisai:handle, 'soc-cd/noimm/jou-cd/annee/mois/order-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhNoimm:buffer-value(), vhJou-cd:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value(), vhOrder-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cexisai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCexisai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cexisai for cexisai.

    create query vhttquery.
    vhttBuffer = ghttCexisai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCexisai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cexisai.
            if not outils:copyValidField(buffer cexisai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCexisai private:
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
    define buffer cexisai for cexisai.

    create query vhttquery.
    vhttBuffer = ghttCexisai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCexisai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNoimm, output vhJou-cd, output vhAnnee, output vhMois, output vhOrder-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexisai exclusive-lock
                where rowid(Cexisai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexisai:handle, 'soc-cd/noimm/jou-cd/annee/mois/order-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhNoimm:buffer-value(), vhJou-cd:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value(), vhOrder-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cexisai no-error.
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

