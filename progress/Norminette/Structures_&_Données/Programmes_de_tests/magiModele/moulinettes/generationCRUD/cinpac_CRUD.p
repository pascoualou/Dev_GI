/*------------------------------------------------------------------------
File        : cinpac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinpac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinpac.i}
{application/include/error.i}
define variable ghttcinpac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-invest as handle, output phInvest-cle as handle, output phAnnee as handle, output phMois as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-invest/invest-cle/annee/mois, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-invest' then phType-invest = phBuffer:buffer-field(vi).
            when 'invest-cle' then phInvest-cle = phBuffer:buffer-field(vi).
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'mois' then phMois = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinpac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinpac.
    run updateCinpac.
    run createCinpac.
end procedure.

procedure setCinpac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinpac.
    ghttCinpac = phttCinpac.
    run crudCinpac.
    delete object phttCinpac.
end procedure.

procedure readCinpac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinpac fichier chrono
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter pcInvest-cle  as character  no-undo.
    define input parameter piAnnee       as integer    no-undo.
    define input parameter piMois        as integer    no-undo.
    define input parameter table-handle phttCinpac.
    define variable vhttBuffer as handle no-undo.
    define buffer cinpac for cinpac.

    vhttBuffer = phttCinpac:default-buffer-handle.
    for first cinpac no-lock
        where cinpac.soc-cd = piSoc-cd
          and cinpac.etab-cd = piEtab-cd
          and cinpac.type-invest = piType-invest
          and cinpac.invest-cle = pcInvest-cle
          and cinpac.annee = piAnnee
          and cinpac.mois = piMois:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinpac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinpac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinpac fichier chrono
    Notes  : service externe. Critère piAnnee = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter pcInvest-cle  as character  no-undo.
    define input parameter piAnnee       as integer    no-undo.
    define input parameter table-handle phttCinpac.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinpac for cinpac.

    vhttBuffer = phttCinpac:default-buffer-handle.
    if piAnnee = ?
    then for each cinpac no-lock
        where cinpac.soc-cd = piSoc-cd
          and cinpac.etab-cd = piEtab-cd
          and cinpac.type-invest = piType-invest
          and cinpac.invest-cle = pcInvest-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinpac no-lock
        where cinpac.soc-cd = piSoc-cd
          and cinpac.etab-cd = piEtab-cd
          and cinpac.type-invest = piType-invest
          and cinpac.invest-cle = pcInvest-cle
          and cinpac.annee = piAnnee:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinpac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinpac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinpac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define buffer cinpac for cinpac.

    create query vhttquery.
    vhttBuffer = ghttCinpac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinpac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest, output vhInvest-cle, output vhAnnee, output vhMois).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinpac exclusive-lock
                where rowid(cinpac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinpac:handle, 'soc-cd/etab-cd/type-invest/invest-cle/annee/mois: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value(), vhInvest-cle:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinpac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinpac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinpac for cinpac.

    create query vhttquery.
    vhttBuffer = ghttCinpac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinpac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinpac.
            if not outils:copyValidField(buffer cinpac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinpac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define buffer cinpac for cinpac.

    create query vhttquery.
    vhttBuffer = ghttCinpac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinpac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest, output vhInvest-cle, output vhAnnee, output vhMois).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinpac exclusive-lock
                where rowid(Cinpac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinpac:handle, 'soc-cd/etab-cd/type-invest/invest-cle/annee/mois: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value(), vhInvest-cle:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinpac no-error.
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

