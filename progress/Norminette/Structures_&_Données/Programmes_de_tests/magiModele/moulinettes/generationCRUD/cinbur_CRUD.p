/*------------------------------------------------------------------------
File        : cinbur_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinbur
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinbur.i}
{application/include/error.i}
define variable ghttcinbur as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBureau-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/bureau-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'bureau-cle' then phBureau-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinbur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinbur.
    run updateCinbur.
    run createCinbur.
end procedure.

procedure setCinbur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinbur.
    ghttCinbur = phttCinbur.
    run crudCinbur.
    delete object phttCinbur.
end procedure.

procedure readCinbur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinbur fichier bureaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcBureau-cle as character  no-undo.
    define input parameter table-handle phttCinbur.
    define variable vhttBuffer as handle no-undo.
    define buffer cinbur for cinbur.

    vhttBuffer = phttCinbur:default-buffer-handle.
    for first cinbur no-lock
        where cinbur.soc-cd = piSoc-cd
          and cinbur.etab-cd = piEtab-cd
          and cinbur.bureau-cle = pcBureau-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinbur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinbur no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinbur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinbur fichier bureaux
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCinbur.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinbur for cinbur.

    vhttBuffer = phttCinbur:default-buffer-handle.
    if piEtab-cd = ?
    then for each cinbur no-lock
        where cinbur.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinbur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinbur no-lock
        where cinbur.soc-cd = piSoc-cd
          and cinbur.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinbur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinbur no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinbur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBureau-cle    as handle  no-undo.
    define buffer cinbur for cinbur.

    create query vhttquery.
    vhttBuffer = ghttCinbur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinbur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBureau-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinbur exclusive-lock
                where rowid(cinbur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinbur:handle, 'soc-cd/etab-cd/bureau-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBureau-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinbur:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinbur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinbur for cinbur.

    create query vhttquery.
    vhttBuffer = ghttCinbur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinbur:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinbur.
            if not outils:copyValidField(buffer cinbur:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinbur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBureau-cle    as handle  no-undo.
    define buffer cinbur for cinbur.

    create query vhttquery.
    vhttBuffer = ghttCinbur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinbur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBureau-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinbur exclusive-lock
                where rowid(Cinbur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinbur:handle, 'soc-cd/etab-cd/bureau-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBureau-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinbur no-error.
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

