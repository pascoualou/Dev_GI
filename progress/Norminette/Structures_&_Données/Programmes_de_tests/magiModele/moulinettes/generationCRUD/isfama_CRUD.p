/*------------------------------------------------------------------------
File        : isfama_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table isfama
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/isfama.i}
{application/include/error.i}
define variable ghttisfama as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFam-cd as handle, output phSfam-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/fam-cd/sfam-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'fam-cd' then phFam-cd = phBuffer:buffer-field(vi).
            when 'sfam-cd' then phSfam-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIsfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIsfama.
    run updateIsfama.
    run createIsfama.
end procedure.

procedure setIsfama:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIsfama.
    ghttIsfama = phttIsfama.
    run crudIsfama.
    delete object phttIsfama.
end procedure.

procedure readIsfama:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table isfama fichier des sous-familles d'affaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piFam-cd  as integer    no-undo.
    define input parameter piSfam-cd as integer    no-undo.
    define input parameter table-handle phttIsfama.
    define variable vhttBuffer as handle no-undo.
    define buffer isfama for isfama.

    vhttBuffer = phttIsfama:default-buffer-handle.
    for first isfama no-lock
        where isfama.soc-cd = piSoc-cd
          and isfama.fam-cd = piFam-cd
          and isfama.sfam-cd = piSfam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isfama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIsfama no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIsfama:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table isfama fichier des sous-familles d'affaires
    Notes  : service externe. Critère piFam-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piFam-cd  as integer    no-undo.
    define input parameter table-handle phttIsfama.
    define variable vhttBuffer as handle  no-undo.
    define buffer isfama for isfama.

    vhttBuffer = phttIsfama:default-buffer-handle.
    if piFam-cd = ?
    then for each isfama no-lock
        where isfama.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isfama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each isfama no-lock
        where isfama.soc-cd = piSoc-cd
          and isfama.fam-cd = piFam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isfama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIsfama no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIsfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define variable vhSfam-cd    as handle  no-undo.
    define buffer isfama for isfama.

    create query vhttquery.
    vhttBuffer = ghttIsfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIsfama:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cd, output vhSfam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first isfama exclusive-lock
                where rowid(isfama) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer isfama:handle, 'soc-cd/fam-cd/sfam-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhFam-cd:buffer-value(), vhSfam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer isfama:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIsfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer isfama for isfama.

    create query vhttquery.
    vhttBuffer = ghttIsfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIsfama:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create isfama.
            if not outils:copyValidField(buffer isfama:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIsfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define variable vhSfam-cd    as handle  no-undo.
    define buffer isfama for isfama.

    create query vhttquery.
    vhttBuffer = ghttIsfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIsfama:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cd, output vhSfam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first isfama exclusive-lock
                where rowid(Isfama) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer isfama:handle, 'soc-cd/fam-cd/sfam-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhFam-cd:buffer-value(), vhSfam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete isfama no-error.
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

