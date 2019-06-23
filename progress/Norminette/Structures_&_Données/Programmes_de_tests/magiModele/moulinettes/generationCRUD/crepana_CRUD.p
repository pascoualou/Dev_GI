/*------------------------------------------------------------------------
File        : crepana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crepana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crepana.i}
{application/include/error.i}
define variable ghttcrepana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRepart-cle as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/repart-cle/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'repart-cle' then phRepart-cle = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrepana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrepana.
    run updateCrepana.
    run createCrepana.
end procedure.

procedure setCrepana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrepana.
    ghttCrepana = phttCrepana.
    run crudCrepana.
    delete object phttCrepana.
end procedure.

procedure readCrepana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crepana Fichier des repartitions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcRepart-cle as character  no-undo.
    define input parameter piLig        as integer    no-undo.
    define input parameter table-handle phttCrepana.
    define variable vhttBuffer as handle no-undo.
    define buffer crepana for crepana.

    vhttBuffer = phttCrepana:default-buffer-handle.
    for first crepana no-lock
        where crepana.soc-cd = piSoc-cd
          and crepana.etab-cd = piEtab-cd
          and crepana.repart-cle = pcRepart-cle
          and crepana.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrepana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrepana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crepana Fichier des repartitions
    Notes  : service externe. Critère pcRepart-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcRepart-cle as character  no-undo.
    define input parameter table-handle phttCrepana.
    define variable vhttBuffer as handle  no-undo.
    define buffer crepana for crepana.

    vhttBuffer = phttCrepana:default-buffer-handle.
    if pcRepart-cle = ?
    then for each crepana no-lock
        where crepana.soc-cd = piSoc-cd
          and crepana.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crepana no-lock
        where crepana.soc-cd = piSoc-cd
          and crepana.etab-cd = piEtab-cd
          and crepana.repart-cle = pcRepart-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrepana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrepana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRepart-cle    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer crepana for crepana.

    create query vhttquery.
    vhttBuffer = ghttCrepana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrepana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRepart-cle, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crepana exclusive-lock
                where rowid(crepana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crepana:handle, 'soc-cd/etab-cd/repart-cle/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRepart-cle:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crepana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrepana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crepana for crepana.

    create query vhttquery.
    vhttBuffer = ghttCrepana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrepana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crepana.
            if not outils:copyValidField(buffer crepana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrepana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRepart-cle    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer crepana for crepana.

    create query vhttquery.
    vhttBuffer = ghttCrepana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrepana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRepart-cle, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crepana exclusive-lock
                where rowid(Crepana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crepana:handle, 'soc-cd/etab-cd/repart-cle/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRepart-cle:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crepana no-error.
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

