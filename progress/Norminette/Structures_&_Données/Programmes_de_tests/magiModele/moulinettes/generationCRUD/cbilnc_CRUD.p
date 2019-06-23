/*------------------------------------------------------------------------
File        : cbilnc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbilnc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbilnc.i}
{application/include/error.i}
define variable ghttcbilnc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phEtat-cd as handle, output phRub-cd as handle, output phRubln-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
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

procedure crudCbilnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbilnc.
    run updateCbilnc.
    run createCbilnc.
end procedure.

procedure setCbilnc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbilnc.
    ghttCbilnc = phttCbilnc.
    run crudCbilnc.
    delete object phttCbilnc.
end procedure.

procedure readCbilnc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbilnc Fichier des lignes de bilan colonne C
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcEtat-cd  as character  no-undo.
    define input parameter piRub-cd   as integer    no-undo.
    define input parameter piRubln-cd as integer    no-undo.
    define input parameter table-handle phttCbilnc.
    define variable vhttBuffer as handle no-undo.
    define buffer cbilnc for cbilnc.

    vhttBuffer = phttCbilnc:default-buffer-handle.
    for first cbilnc no-lock
        where cbilnc.soc-cd = piSoc-cd
          and cbilnc.etab-cd = piEtab-cd
          and cbilnc.etat-cd = pcEtat-cd
          and cbilnc.rub-cd = piRub-cd
          and cbilnc.rubln-cd = piRubln-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilnc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbilnc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbilnc Fichier des lignes de bilan colonne C
    Notes  : service externe. Critère piRub-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcEtat-cd  as character  no-undo.
    define input parameter piRub-cd   as integer    no-undo.
    define input parameter table-handle phttCbilnc.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbilnc for cbilnc.

    vhttBuffer = phttCbilnc:default-buffer-handle.
    if piRub-cd = ?
    then for each cbilnc no-lock
        where cbilnc.soc-cd = piSoc-cd
          and cbilnc.etab-cd = piEtab-cd
          and cbilnc.etat-cd = pcEtat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbilnc no-lock
        where cbilnc.soc-cd = piSoc-cd
          and cbilnc.etab-cd = piEtab-cd
          and cbilnc.etat-cd = pcEtat-cd
          and cbilnc.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilnc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbilnc private:
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
    define buffer cbilnc for cbilnc.

    create query vhttquery.
    vhttBuffer = ghttCbilnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbilnc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhRub-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilnc exclusive-lock
                where rowid(cbilnc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilnc:handle, 'soc-cd/etab-cd/etat-cd/rub-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhRub-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbilnc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbilnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbilnc for cbilnc.

    create query vhttquery.
    vhttBuffer = ghttCbilnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbilnc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbilnc.
            if not outils:copyValidField(buffer cbilnc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbilnc private:
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
    define buffer cbilnc for cbilnc.

    create query vhttquery.
    vhttBuffer = ghttCbilnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbilnc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhRub-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilnc exclusive-lock
                where rowid(Cbilnc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilnc:handle, 'soc-cd/etab-cd/etat-cd/rub-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhRub-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbilnc no-error.
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

