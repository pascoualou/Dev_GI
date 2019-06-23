/*------------------------------------------------------------------------
File        : cinimo_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinimo
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinimo.i}
{application/include/error.i}
define variable ghttcinimo as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle, output phInvest-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int/invest-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'invest-cle' then phInvest-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinimo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinimo.
    run updateCinimo.
    run createCinimo.
end procedure.

procedure setCinimo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinimo.
    ghttCinimo = phttCinimo.
    run crudCinimo.
    delete object phttCinimo.
end procedure.

procedure readCinimo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinimo fichier immobilisation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter table-handle phttCinimo.
    define variable vhttBuffer as handle no-undo.
    define buffer cinimo for cinimo.

    vhttBuffer = phttCinimo:default-buffer-handle.
    for first cinimo no-lock
        where cinimo.soc-cd = piSoc-cd
          and cinimo.etab-cd = piEtab-cd
          and cinimo.num-int = piNum-int
          and cinimo.invest-cle = pcInvest-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinimo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinimo no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinimo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinimo fichier immobilisation
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter table-handle phttCinimo.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinimo for cinimo.

    vhttBuffer = phttCinimo:default-buffer-handle.
    if piNum-int = ?
    then for each cinimo no-lock
        where cinimo.soc-cd = piSoc-cd
          and cinimo.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinimo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinimo no-lock
        where cinimo.soc-cd = piSoc-cd
          and cinimo.etab-cd = piEtab-cd
          and cinimo.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinimo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinimo no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinimo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define buffer cinimo for cinimo.

    create query vhttquery.
    vhttBuffer = ghttCinimo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinimo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhInvest-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinimo exclusive-lock
                where rowid(cinimo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinimo:handle, 'soc-cd/etab-cd/num-int/invest-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhInvest-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinimo:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinimo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinimo for cinimo.

    create query vhttquery.
    vhttBuffer = ghttCinimo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinimo:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinimo.
            if not outils:copyValidField(buffer cinimo:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinimo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define buffer cinimo for cinimo.

    create query vhttquery.
    vhttBuffer = ghttCinimo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinimo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhInvest-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinimo exclusive-lock
                where rowid(Cinimo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinimo:handle, 'soc-cd/etab-cd/num-int/invest-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhInvest-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinimo no-error.
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

