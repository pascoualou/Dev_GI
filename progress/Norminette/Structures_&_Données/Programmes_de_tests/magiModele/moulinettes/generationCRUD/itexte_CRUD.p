/*------------------------------------------------------------------------
File        : itexte_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itexte
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itexte.i}
{application/include/error.i}
define variable ghttitexte as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phLibtexte-cd as handle, output phTexte-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/libtexte-cd/texte-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'libtexte-cd' then phLibtexte-cd = phBuffer:buffer-field(vi).
            when 'texte-cd' then phTexte-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItexte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItexte.
    run updateItexte.
    run createItexte.
end procedure.

procedure setItexte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItexte.
    ghttItexte = phttItexte.
    run crudItexte.
    delete object phttItexte.
end procedure.

procedure readItexte:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itexte Fichier de lettre
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piLibtexte-cd as integer    no-undo.
    define input parameter piTexte-cd    as integer    no-undo.
    define input parameter table-handle phttItexte.
    define variable vhttBuffer as handle no-undo.
    define buffer itexte for itexte.

    vhttBuffer = phttItexte:default-buffer-handle.
    for first itexte no-lock
        where itexte.soc-cd = piSoc-cd
          and itexte.etab-cd = piEtab-cd
          and itexte.libtexte-cd = piLibtexte-cd
          and itexte.texte-cd = piTexte-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itexte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItexte no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItexte:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itexte Fichier de lettre
    Notes  : service externe. Critère piLibtexte-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piLibtexte-cd as integer    no-undo.
    define input parameter table-handle phttItexte.
    define variable vhttBuffer as handle  no-undo.
    define buffer itexte for itexte.

    vhttBuffer = phttItexte:default-buffer-handle.
    if piLibtexte-cd = ?
    then for each itexte no-lock
        where itexte.soc-cd = piSoc-cd
          and itexte.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itexte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itexte no-lock
        where itexte.soc-cd = piSoc-cd
          and itexte.etab-cd = piEtab-cd
          and itexte.libtexte-cd = piLibtexte-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itexte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItexte no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItexte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhLibtexte-cd    as handle  no-undo.
    define variable vhTexte-cd    as handle  no-undo.
    define buffer itexte for itexte.

    create query vhttquery.
    vhttBuffer = ghttItexte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItexte:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibtexte-cd, output vhTexte-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itexte exclusive-lock
                where rowid(itexte) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itexte:handle, 'soc-cd/etab-cd/libtexte-cd/texte-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibtexte-cd:buffer-value(), vhTexte-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itexte:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItexte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itexte for itexte.

    create query vhttquery.
    vhttBuffer = ghttItexte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItexte:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itexte.
            if not outils:copyValidField(buffer itexte:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItexte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhLibtexte-cd    as handle  no-undo.
    define variable vhTexte-cd    as handle  no-undo.
    define buffer itexte for itexte.

    create query vhttquery.
    vhttBuffer = ghttItexte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItexte:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhLibtexte-cd, output vhTexte-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itexte exclusive-lock
                where rowid(Itexte) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itexte:handle, 'soc-cd/etab-cd/libtexte-cd/texte-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhLibtexte-cd:buffer-value(), vhTexte-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itexte no-error.
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

