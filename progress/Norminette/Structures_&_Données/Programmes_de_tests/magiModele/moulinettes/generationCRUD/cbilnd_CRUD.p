/*------------------------------------------------------------------------
File        : cbilnd_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table cbilnd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/cbilnd.i}
{application/include/error.i}
define variable ghttcbilnd as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phEtat-cd as handle, output phRub-cd as handle, output phRubln-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/etat-cd/rub-cd/rubln-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'etat-cd' then phEtat-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'rubln-cd' then phRubln-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbilnd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbilnd.
    run updateCbilnd.
    run createCbilnd.
end procedure.

procedure setCbilnd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbilnd.
    ghttCbilnd = phttCbilnd.
    run crudCbilnd.
    delete object phttCbilnd.
end procedure.

procedure readCbilnd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbilnd Fichier des lignes de bilan colonne D
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcEtat-cd  as character  no-undo.
    define input parameter piRub-cd   as integer    no-undo.
    define input parameter piRubln-cd as integer    no-undo.
    define input parameter table-handle phttCbilnd.
    define variable vhttBuffer as handle no-undo.
    define buffer cbilnd for cbilnd.

    vhttBuffer = phttCbilnd:default-buffer-handle.
    for first cbilnd no-lock
        where cbilnd.soc-cd = piSoc-cd
          and cbilnd.etab-cd = piEtab-cd
          and cbilnd.etat-cd = pcEtat-cd
          and cbilnd.rub-cd = piRub-cd
          and cbilnd.rubln-cd = piRubln-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilnd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilnd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbilnd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbilnd Fichier des lignes de bilan colonne D
    Notes  : service externe. Crit�re piRub-cd = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcEtat-cd  as character  no-undo.
    define input parameter piRub-cd   as integer    no-undo.
    define input parameter table-handle phttCbilnd.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbilnd for cbilnd.

    vhttBuffer = phttCbilnd:default-buffer-handle.
    if piRub-cd = ?
    then for each cbilnd no-lock
        where cbilnd.soc-cd = piSoc-cd
          and cbilnd.etab-cd = piEtab-cd
          and cbilnd.etat-cd = pcEtat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilnd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbilnd no-lock
        where cbilnd.soc-cd = piSoc-cd
          and cbilnd.etab-cd = piEtab-cd
          and cbilnd.etat-cd = pcEtat-cd
          and cbilnd.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilnd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilnd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbilnd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhRubln-cd    as handle  no-undo.
    define buffer cbilnd for cbilnd.

    create query vhttquery.
    vhttBuffer = ghttCbilnd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbilnd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhRub-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilnd exclusive-lock
                where rowid(cbilnd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilnd:handle, 'soc-cd/etab-cd/etat-cd/rub-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhRub-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbilnd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbilnd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbilnd for cbilnd.

    create query vhttquery.
    vhttBuffer = ghttCbilnd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbilnd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbilnd.
            if not outils:copyValidField(buffer cbilnd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbilnd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhRubln-cd    as handle  no-undo.
    define buffer cbilnd for cbilnd.

    create query vhttquery.
    vhttBuffer = ghttCbilnd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbilnd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhRub-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilnd exclusive-lock
                where rowid(Cbilnd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilnd:handle, 'soc-cd/etab-cd/etat-cd/rub-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhRub-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbilnd no-error.
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

