/*------------------------------------------------------------------------
File        : cinemp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinemp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinemp.i}
{application/include/error.i}
define variable ghttcinemp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phInvest-cle as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/invest-cle/num-int, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'invest-cle' then phInvest-cle = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinemp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinemp.
    run updateCinemp.
    run createCinemp.
end procedure.

procedure setCinemp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinemp.
    ghttCinemp = phttCinemp.
    run crudCinemp.
    delete object phttCinemp.
end procedure.

procedure readCinemp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinemp fichier emprunt/leasing/location
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter table-handle phttCinemp.
    define variable vhttBuffer as handle no-undo.
    define buffer cinemp for cinemp.

    vhttBuffer = phttCinemp:default-buffer-handle.
    for first cinemp no-lock
        where cinemp.soc-cd = piSoc-cd
          and cinemp.etab-cd = piEtab-cd
          and cinemp.invest-cle = pcInvest-cle
          and cinemp.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinemp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinemp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinemp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinemp fichier emprunt/leasing/location
    Notes  : service externe. Critère pcInvest-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter table-handle phttCinemp.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinemp for cinemp.

    vhttBuffer = phttCinemp:default-buffer-handle.
    if pcInvest-cle = ?
    then for each cinemp no-lock
        where cinemp.soc-cd = piSoc-cd
          and cinemp.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinemp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinemp no-lock
        where cinemp.soc-cd = piSoc-cd
          and cinemp.etab-cd = piEtab-cd
          and cinemp.invest-cle = pcInvest-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinemp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinemp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinemp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer cinemp for cinemp.

    create query vhttquery.
    vhttBuffer = ghttCinemp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinemp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-cle, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinemp exclusive-lock
                where rowid(cinemp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinemp:handle, 'soc-cd/etab-cd/invest-cle/num-int: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-cle:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinemp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinemp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinemp for cinemp.

    create query vhttquery.
    vhttBuffer = ghttCinemp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinemp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinemp.
            if not outils:copyValidField(buffer cinemp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinemp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer cinemp for cinemp.

    create query vhttquery.
    vhttBuffer = ghttCinemp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinemp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-cle, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinemp exclusive-lock
                where rowid(Cinemp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinemp:handle, 'soc-cd/etab-cd/invest-cle/num-int: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-cle:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinemp no-error.
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

