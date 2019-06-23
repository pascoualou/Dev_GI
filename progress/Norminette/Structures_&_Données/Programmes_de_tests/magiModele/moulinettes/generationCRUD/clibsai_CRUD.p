/*------------------------------------------------------------------------
File        : clibsai_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table clibsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/clibsai.i}
{application/include/error.i}
define variable ghttclibsai as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phOrdre-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/ordre-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudClibsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteClibsai.
    run updateClibsai.
    run createClibsai.
end procedure.

procedure setClibsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClibsai.
    ghttClibsai = phttClibsai.
    run crudClibsai.
    delete object phttClibsai.
end procedure.

procedure readClibsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table clibsai Fichier texte pour les libelles de la saisie d'ecriture
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter table-handle phttClibsai.
    define variable vhttBuffer as handle no-undo.
    define buffer clibsai for clibsai.

    vhttBuffer = phttClibsai:default-buffer-handle.
    for first clibsai no-lock
        where clibsai.soc-cd = piSoc-cd
          and clibsai.etab-cd = piEtab-cd
          and clibsai.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClibsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getClibsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table clibsai Fichier texte pour les libelles de la saisie d'ecriture
    Notes  : service externe. Crit�re piEtab-cd = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter table-handle phttClibsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer clibsai for clibsai.

    vhttBuffer = phttClibsai:default-buffer-handle.
    if piEtab-cd = ?
    then for each clibsai no-lock
        where clibsai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each clibsai no-lock
        where clibsai.soc-cd = piSoc-cd
          and clibsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClibsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateClibsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer clibsai for clibsai.

    create query vhttquery.
    vhttBuffer = ghttClibsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttClibsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clibsai exclusive-lock
                where rowid(clibsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clibsai:handle, 'soc-cd/etab-cd/ordre-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer clibsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createClibsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer clibsai for clibsai.

    create query vhttquery.
    vhttBuffer = ghttClibsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttClibsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create clibsai.
            if not outils:copyValidField(buffer clibsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteClibsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer clibsai for clibsai.

    create query vhttquery.
    vhttBuffer = ghttClibsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttClibsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clibsai exclusive-lock
                where rowid(Clibsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clibsai:handle, 'soc-cd/etab-cd/ordre-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete clibsai no-error.
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

