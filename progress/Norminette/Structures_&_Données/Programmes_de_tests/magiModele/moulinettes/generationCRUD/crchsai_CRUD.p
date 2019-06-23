/*------------------------------------------------------------------------
File        : crchsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crchsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crchsai.i}
{application/include/error.i}
define variable ghttcrchsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCptrep as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cptrep, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cptrep' then phCptrep = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrchsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrchsai.
    run updateCrchsai.
    run createCrchsai.
end procedure.

procedure setCrchsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrchsai.
    ghttCrchsai = phttCrchsai.
    run crudCrchsai.
    delete object phttCrchsai.
end procedure.

procedure readCrchsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crchsai Table des entetes de repartitions de charges
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCptrep  as character  no-undo.
    define input parameter table-handle phttCrchsai.
    define variable vhttBuffer as handle no-undo.
    define buffer crchsai for crchsai.

    vhttBuffer = phttCrchsai:default-buffer-handle.
    for first crchsai no-lock
        where crchsai.soc-cd = piSoc-cd
          and crchsai.etab-cd = piEtab-cd
          and crchsai.cptrep = pcCptrep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrchsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrchsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crchsai Table des entetes de repartitions de charges
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCrchsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer crchsai for crchsai.

    vhttBuffer = phttCrchsai:default-buffer-handle.
    if piEtab-cd = ?
    then for each crchsai no-lock
        where crchsai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crchsai no-lock
        where crchsai.soc-cd = piSoc-cd
          and crchsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrchsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrchsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCptrep    as handle  no-undo.
    define buffer crchsai for crchsai.

    create query vhttquery.
    vhttBuffer = ghttCrchsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrchsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCptrep).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crchsai exclusive-lock
                where rowid(crchsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crchsai:handle, 'soc-cd/etab-cd/cptrep: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCptrep:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crchsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrchsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crchsai for crchsai.

    create query vhttquery.
    vhttBuffer = ghttCrchsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrchsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crchsai.
            if not outils:copyValidField(buffer crchsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrchsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCptrep    as handle  no-undo.
    define buffer crchsai for crchsai.

    create query vhttquery.
    vhttBuffer = ghttCrchsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrchsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCptrep).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crchsai exclusive-lock
                where rowid(Crchsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crchsai:handle, 'soc-cd/etab-cd/cptrep: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCptrep:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crchsai no-error.
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

