/*------------------------------------------------------------------------
File        : ifama_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifama
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifama.i}
{application/include/error.i}
define variable ghttifama as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFam-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/fam-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'fam-cd' then phFam-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfama.
    run updateIfama.
    run createIfama.
end procedure.

procedure setIfama:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfama.
    ghttIfama = phttIfama.
    run crudIfama.
    delete object phttIfama.
end procedure.

procedure readIfama:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifama fichier des familles des affaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter piFam-cd as integer    no-undo.
    define input parameter table-handle phttIfama.
    define variable vhttBuffer as handle no-undo.
    define buffer ifama for ifama.

    vhttBuffer = phttIfama:default-buffer-handle.
    for first ifama no-lock
        where ifama.soc-cd = piSoc-cd
          and ifama.fam-cd = piFam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfama no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfama:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifama fichier des familles des affaires
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttIfama.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifama for ifama.

    vhttBuffer = phttIfama:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifama no-lock
        where ifama.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifama no-lock
        where ifama.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfama no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define buffer ifama for ifama.

    create query vhttquery.
    vhttBuffer = ghttIfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfama:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifama exclusive-lock
                where rowid(ifama) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifama:handle, 'soc-cd/fam-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhFam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifama:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifama for ifama.

    create query vhttquery.
    vhttBuffer = ghttIfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfama:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifama.
            if not outils:copyValidField(buffer ifama:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define buffer ifama for ifama.

    create query vhttquery.
    vhttBuffer = ghttIfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfama:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifama exclusive-lock
                where rowid(Ifama) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifama:handle, 'soc-cd/fam-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhFam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifama no-error.
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

