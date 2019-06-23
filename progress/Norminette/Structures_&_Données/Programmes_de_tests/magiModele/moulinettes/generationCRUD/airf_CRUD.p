/*------------------------------------------------------------------------
File        : airf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table airf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/airf.i}
{application/include/error.i}
define variable ghttairf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-cd as handle, output phAnnee as handle, output phIrf-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-cd/annee/irf-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-cd' then phType-cd = phBuffer:buffer-field(vi).
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'irf-cd' then phIrf-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAirf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAirf.
    run updateAirf.
    run createAirf.
end procedure.

procedure setAirf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAirf.
    ghttAirf = phttAirf.
    run crudAirf.
    delete object phttAirf.
end procedure.

procedure readAirf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table airf Recap IRF
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piType-cd as integer    no-undo.
    define input parameter piAnnee   as integer    no-undo.
    define input parameter pcIrf-cd  as character  no-undo.
    define input parameter table-handle phttAirf.
    define variable vhttBuffer as handle no-undo.
    define buffer airf for airf.

    vhttBuffer = phttAirf:default-buffer-handle.
    for first airf no-lock
        where airf.soc-cd = piSoc-cd
          and airf.etab-cd = piEtab-cd
          and airf.type-cd = piType-cd
          and airf.annee = piAnnee
          and airf.irf-cd = pcIrf-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer airf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAirf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAirf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table airf Recap IRF
    Notes  : service externe. Critère piAnnee = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piType-cd as integer    no-undo.
    define input parameter piAnnee   as integer    no-undo.
    define input parameter table-handle phttAirf.
    define variable vhttBuffer as handle  no-undo.
    define buffer airf for airf.

    vhttBuffer = phttAirf:default-buffer-handle.
    if piAnnee = ?
    then for each airf no-lock
        where airf.soc-cd = piSoc-cd
          and airf.etab-cd = piEtab-cd
          and airf.type-cd = piType-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer airf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each airf no-lock
        where airf.soc-cd = piSoc-cd
          and airf.etab-cd = piEtab-cd
          and airf.type-cd = piType-cd
          and airf.annee = piAnnee:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer airf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAirf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAirf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-cd    as handle  no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhIrf-cd    as handle  no-undo.
    define buffer airf for airf.

    create query vhttquery.
    vhttBuffer = ghttAirf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAirf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-cd, output vhAnnee, output vhIrf-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first airf exclusive-lock
                where rowid(airf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer airf:handle, 'soc-cd/etab-cd/type-cd/annee/irf-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-cd:buffer-value(), vhAnnee:buffer-value(), vhIrf-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer airf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAirf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer airf for airf.

    create query vhttquery.
    vhttBuffer = ghttAirf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAirf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create airf.
            if not outils:copyValidField(buffer airf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAirf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-cd    as handle  no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhIrf-cd    as handle  no-undo.
    define buffer airf for airf.

    create query vhttquery.
    vhttBuffer = ghttAirf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAirf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-cd, output vhAnnee, output vhIrf-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first airf exclusive-lock
                where rowid(Airf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer airf:handle, 'soc-cd/etab-cd/type-cd/annee/irf-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-cd:buffer-value(), vhAnnee:buffer-value(), vhIrf-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete airf no-error.
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

