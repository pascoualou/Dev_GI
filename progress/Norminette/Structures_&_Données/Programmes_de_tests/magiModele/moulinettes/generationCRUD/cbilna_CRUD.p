/*------------------------------------------------------------------------
File        : cbilna_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbilna
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbilna.i}
{application/include/error.i}
define variable ghttcbilna as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCbilna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbilna.
    run updateCbilna.
    run createCbilna.
end procedure.

procedure setCbilna:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbilna.
    ghttCbilna = phttCbilna.
    run crudCbilna.
    delete object phttCbilna.
end procedure.

procedure readCbilna:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbilna Fichier des lignes de bilan colonne A
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcEtat-cd  as character  no-undo.
    define input parameter piRub-cd   as integer    no-undo.
    define input parameter piRubln-cd as integer    no-undo.
    define input parameter table-handle phttCbilna.
    define variable vhttBuffer as handle no-undo.
    define buffer cbilna for cbilna.

    vhttBuffer = phttCbilna:default-buffer-handle.
    for first cbilna no-lock
        where cbilna.soc-cd = piSoc-cd
          and cbilna.etab-cd = piEtab-cd
          and cbilna.etat-cd = pcEtat-cd
          and cbilna.rub-cd = piRub-cd
          and cbilna.rubln-cd = piRubln-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilna no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbilna:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbilna Fichier des lignes de bilan colonne A
    Notes  : service externe. Critère piRub-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcEtat-cd  as character  no-undo.
    define input parameter piRub-cd   as integer    no-undo.
    define input parameter table-handle phttCbilna.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbilna for cbilna.

    vhttBuffer = phttCbilna:default-buffer-handle.
    if piRub-cd = ?
    then for each cbilna no-lock
        where cbilna.soc-cd = piSoc-cd
          and cbilna.etab-cd = piEtab-cd
          and cbilna.etat-cd = pcEtat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbilna no-lock
        where cbilna.soc-cd = piSoc-cd
          and cbilna.etab-cd = piEtab-cd
          and cbilna.etat-cd = pcEtat-cd
          and cbilna.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbilna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbilna no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbilna private:
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
    define buffer cbilna for cbilna.

    create query vhttquery.
    vhttBuffer = ghttCbilna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbilna:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhRub-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilna exclusive-lock
                where rowid(cbilna) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilna:handle, 'soc-cd/etab-cd/etat-cd/rub-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhRub-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbilna:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbilna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbilna for cbilna.

    create query vhttquery.
    vhttBuffer = ghttCbilna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbilna:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbilna.
            if not outils:copyValidField(buffer cbilna:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbilna private:
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
    define buffer cbilna for cbilna.

    create query vhttquery.
    vhttBuffer = ghttCbilna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbilna:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhRub-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbilna exclusive-lock
                where rowid(Cbilna) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbilna:handle, 'soc-cd/etab-cd/etat-cd/rub-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhRub-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbilna no-error.
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

