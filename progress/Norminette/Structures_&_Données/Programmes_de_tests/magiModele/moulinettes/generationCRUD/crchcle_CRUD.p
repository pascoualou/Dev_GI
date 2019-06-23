/*------------------------------------------------------------------------
File        : crchcle_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table crchcle
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/crchcle.i}
{application/include/error.i}
define variable ghttcrchcle as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRepart-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/repart-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'repart-cle' then phRepart-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrchcle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrchcle.
    run updateCrchcle.
    run createCrchcle.
end procedure.

procedure setCrchcle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrchcle.
    ghttCrchcle = phttCrchcle.
    run crudCrchcle.
    delete object phttCrchcle.
end procedure.

procedure readCrchcle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crchcle Table cle de repartition
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcRepart-cle as character  no-undo.
    define input parameter table-handle phttCrchcle.
    define variable vhttBuffer as handle no-undo.
    define buffer crchcle for crchcle.

    vhttBuffer = phttCrchcle:default-buffer-handle.
    for first crchcle no-lock
        where crchcle.soc-cd = piSoc-cd
          and crchcle.etab-cd = piEtab-cd
          and crchcle.repart-cle = pcRepart-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchcle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrchcle no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrchcle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crchcle Table cle de repartition
    Notes  : service externe. Crit�re piEtab-cd = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCrchcle.
    define variable vhttBuffer as handle  no-undo.
    define buffer crchcle for crchcle.

    vhttBuffer = phttCrchcle:default-buffer-handle.
    if piEtab-cd = ?
    then for each crchcle no-lock
        where crchcle.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchcle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crchcle no-lock
        where crchcle.soc-cd = piSoc-cd
          and crchcle.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crchcle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrchcle no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrchcle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRepart-cle    as handle  no-undo.
    define buffer crchcle for crchcle.

    create query vhttquery.
    vhttBuffer = ghttCrchcle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrchcle:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRepart-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crchcle exclusive-lock
                where rowid(crchcle) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crchcle:handle, 'soc-cd/etab-cd/repart-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRepart-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crchcle:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrchcle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crchcle for crchcle.

    create query vhttquery.
    vhttBuffer = ghttCrchcle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrchcle:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crchcle.
            if not outils:copyValidField(buffer crchcle:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrchcle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRepart-cle    as handle  no-undo.
    define buffer crchcle for crchcle.

    create query vhttquery.
    vhttBuffer = ghttCrchcle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrchcle:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRepart-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crchcle exclusive-lock
                where rowid(Crchcle) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crchcle:handle, 'soc-cd/etab-cd/repart-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRepart-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crchcle no-error.
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

