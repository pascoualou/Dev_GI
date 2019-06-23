/*------------------------------------------------------------------------
File        : paretabln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table paretabln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/paretabln.i}
{application/include/error.i}
define variable ghttparetabln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAnnee as handle, output phMois as handle, output phOrder as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/annee/mois/order, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'mois' then phMois = phBuffer:buffer-field(vi).
            when 'order' then phOrder = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudParetabln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteParetabln.
    run updateParetabln.
    run createParetabln.
end procedure.

procedure setParetabln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParetabln.
    ghttParetabln = phttParetabln.
    run crudParetabln.
    delete object phttParetabln.
end procedure.

procedure readParetabln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table paretabln Fichier Parametres (Compteur / Mois)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piAnnee   as integer    no-undo.
    define input parameter piMois    as integer    no-undo.
    define input parameter piOrder   as integer    no-undo.
    define input parameter table-handle phttParetabln.
    define variable vhttBuffer as handle no-undo.
    define buffer paretabln for paretabln.

    vhttBuffer = phttParetabln:default-buffer-handle.
    for first paretabln no-lock
        where paretabln.soc-cd = piSoc-cd
          and paretabln.etab-cd = piEtab-cd
          and paretabln.annee = piAnnee
          and paretabln.mois = piMois
          and paretabln.order = piOrder:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer paretabln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParetabln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getParetabln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table paretabln Fichier Parametres (Compteur / Mois)
    Notes  : service externe. Critère piMois = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piAnnee   as integer    no-undo.
    define input parameter piMois    as integer    no-undo.
    define input parameter table-handle phttParetabln.
    define variable vhttBuffer as handle  no-undo.
    define buffer paretabln for paretabln.

    vhttBuffer = phttParetabln:default-buffer-handle.
    if piMois = ?
    then for each paretabln no-lock
        where paretabln.soc-cd = piSoc-cd
          and paretabln.etab-cd = piEtab-cd
          and paretabln.annee = piAnnee:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer paretabln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each paretabln no-lock
        where paretabln.soc-cd = piSoc-cd
          and paretabln.etab-cd = piEtab-cd
          and paretabln.annee = piAnnee
          and paretabln.mois = piMois:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer paretabln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParetabln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateParetabln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define variable vhOrder    as handle  no-undo.
    define buffer paretabln for paretabln.

    create query vhttquery.
    vhttBuffer = ghttParetabln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttParetabln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAnnee, output vhMois, output vhOrder).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first paretabln exclusive-lock
                where rowid(paretabln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer paretabln:handle, 'soc-cd/etab-cd/annee/mois/order: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value(), vhOrder:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer paretabln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createParetabln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer paretabln for paretabln.

    create query vhttquery.
    vhttBuffer = ghttParetabln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttParetabln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create paretabln.
            if not outils:copyValidField(buffer paretabln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteParetabln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhMois    as handle  no-undo.
    define variable vhOrder    as handle  no-undo.
    define buffer paretabln for paretabln.

    create query vhttquery.
    vhttBuffer = ghttParetabln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttParetabln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAnnee, output vhMois, output vhOrder).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first paretabln exclusive-lock
                where rowid(Paretabln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer paretabln:handle, 'soc-cd/etab-cd/annee/mois/order: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAnnee:buffer-value(), vhMois:buffer-value(), vhOrder:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete paretabln no-error.
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

