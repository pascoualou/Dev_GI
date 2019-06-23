/*------------------------------------------------------------------------
File        : cexiln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cexiln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cexiln.i}
{application/include/error.i}
define variable ghttcexiln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNoimm as handle, output phJou-cd as handle, output phAnnee as handle, output phMois as handle, output phOrder-num as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/noimm/jou-cd/annee/mois/order-num/lig, 
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
       end case.
    end.
end function.

procedure crudCexiln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCexiln.
    run updateCexiln.
    run createCexiln.
end procedure.

procedure setCexiln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCexiln.
    ghttCexiln = phttCexiln.
    run crudCexiln.
    delete object phttCexiln.
end procedure.

procedure readCexiln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cexiln Lignes charges locatives immeuble
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piNoimm     as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piAnnee     as integer    no-undo.
    define input parameter piMois      as integer    no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttCexiln.
    define variable vhttBuffer as handle no-undo.
    define buffer cexiln for cexiln.

    vhttBuffer = phttCexiln:default-buffer-handle.
    for first cexiln no-lock
        where cexiln.soc-cd = piSoc-cd
          and cexiln.noimm = piNoimm
          and cexiln.jou-cd = pcJou-cd
          and cexiln.annee = piAnnee
          and cexiln.mois = piMois
          and cexiln.order-num = piOrder-num
          and cexiln.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexiln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexiln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCexiln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cexiln Lignes charges locatives immeuble
    Notes  : service externe. Critère piOrder-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piNoimm     as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piAnnee     as integer    no-undo.
    define input parameter piMois      as integer    no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter table-handle phttCexiln.
    define variable vhttBuffer as handle  no-undo.
    define buffer cexiln for cexiln.

    vhttBuffer = phttCexiln:default-buffer-handle.
    if piOrder-num = ?
    then for each cexiln no-lock
        where cexiln.soc-cd = piSoc-cd
          and cexiln.noimm = piNoimm
          and cexiln.jou-cd = pcJou-cd
          and cexiln.annee = piAnnee
          and cexiln.mois = piMois:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexiln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cexiln no-lock
        where cexiln.soc-cd = piSoc-cd
          and cexiln.noimm = piNoimm
          and cexiln.jou-cd = pcJou-cd
          and cexiln.annee = piAnnee
          and cexiln.mois = piMois
          and cexiln.order-num = piOrder-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexiln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexiln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCexiln private:
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
    define buffer cexiln for cexiln.

    create query vhttquery.
    vhttBuffer = ghttCexiln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCexiln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNoimm, output vhJou-cd, output vhAnnee, output vhMois, output vhOrder-num, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexiln exclusive-lock
                where rowid(cexiln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexiln:handle, 'soc-cd/noimm/jou-cd/annee/mois/order-num/lig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhNoimm:buffer-value(), vhJou-cd:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value(), vhOrder-num:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cexiln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCexiln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cexiln for cexiln.

    create query vhttquery.
    vhttBuffer = ghttCexiln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCexiln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cexiln.
            if not outils:copyValidField(buffer cexiln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCexiln private:
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
    define buffer cexiln for cexiln.

    create query vhttquery.
    vhttBuffer = ghttCexiln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCexiln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNoimm, output vhJou-cd, output vhAnnee, output vhMois, output vhOrder-num, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexiln exclusive-lock
                where rowid(Cexiln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexiln:handle, 'soc-cd/noimm/jou-cd/annee/mois/order-num/lig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhNoimm:buffer-value(), vhJou-cd:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value(), vhOrder-num:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cexiln no-error.
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

