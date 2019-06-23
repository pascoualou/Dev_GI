/*------------------------------------------------------------------------
File        : crchln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crchln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crchln.i}
{application/include/error.i}
define variable ghttcrchln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCptrep-repart as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cptrep-repart/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cptrep-repart' then phCptrep-repart = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrchln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrchln.
    run updateCrchln.
    run createCrchln.
end procedure.

procedure setCrchln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrchln.
    ghttCrchln = phttCrchln.
    run crudCrchln.
    delete object phttCrchln.
end procedure.

procedure readCrchln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crchln Table des lignes de repartitions de charges
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd        as integer    no-undo.
    define input parameter piEtab-cd       as integer    no-undo.
    define input parameter pcCptrep-repart as character  no-undo.
    define input parameter piLig           as integer    no-undo.
    define input parameter table-handle phttCrchln.
    define variable vhttBuffer as handle no-undo.
    define buffer crchln for crchln.

    vhttBuffer = phttCrchln:default-buffer-handle.
    for first crchln no-lock
        where crchln.soc-cd = piSoc-cd
          and crchln.etab-cd = piEtab-cd
          and crchln.cptrep-repart = pcCptrep-repart
          and crchln.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrchln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrchln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crchln Table des lignes de repartitions de charges
    Notes  : service externe. Critère pcCptrep-repart = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd        as integer    no-undo.
    define input parameter piEtab-cd       as integer    no-undo.
    define input parameter pcCptrep-repart as character  no-undo.
    define input parameter table-handle phttCrchln.
    define variable vhttBuffer as handle  no-undo.
    define buffer crchln for crchln.

    vhttBuffer = phttCrchln:default-buffer-handle.
    if pcCptrep-repart = ?
    then for each crchln no-lock
        where crchln.soc-cd = piSoc-cd
          and crchln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crchln no-lock
        where crchln.soc-cd = piSoc-cd
          and crchln.etab-cd = piEtab-cd
          and crchln.cptrep-repart = pcCptrep-repart:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrchln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrchln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCptrep-repart    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer crchln for crchln.

    create query vhttquery.
    vhttBuffer = ghttCrchln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrchln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCptrep-repart, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crchln exclusive-lock
                where rowid(crchln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crchln:handle, 'soc-cd/etab-cd/cptrep-repart/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCptrep-repart:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crchln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrchln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crchln for crchln.

    create query vhttquery.
    vhttBuffer = ghttCrchln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrchln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crchln.
            if not outils:copyValidField(buffer crchln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrchln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCptrep-repart    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer crchln for crchln.

    create query vhttquery.
    vhttBuffer = ghttCrchln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrchln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCptrep-repart, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crchln exclusive-lock
                where rowid(Crchln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crchln:handle, 'soc-cd/etab-cd/cptrep-repart/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCptrep-repart:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crchln no-error.
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

