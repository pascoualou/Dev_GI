/*------------------------------------------------------------------------
File        : icatfour_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table icatfour
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/icatfour.i}
{application/include/error.i}
define variable ghtticatfour as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCateg-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/categ-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'categ-cd' then phCateg-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIcatfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIcatfour.
    run updateIcatfour.
    run createIcatfour.
end procedure.

procedure setIcatfour:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIcatfour.
    ghttIcatfour = phttIcatfour.
    run crudIcatfour.
    delete object phttIcatfour.
end procedure.

procedure readIcatfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table icatfour Fichier des categories fournisseurs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piCateg-cd as integer    no-undo.
    define input parameter table-handle phttIcatfour.
    define variable vhttBuffer as handle no-undo.
    define buffer icatfour for icatfour.

    vhttBuffer = phttIcatfour:default-buffer-handle.
    for first icatfour no-lock
        where icatfour.soc-cd = piSoc-cd
          and icatfour.etab-cd = piEtab-cd
          and icatfour.categ-cd = piCateg-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icatfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcatfour no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIcatfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table icatfour Fichier des categories fournisseurs
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter table-handle phttIcatfour.
    define variable vhttBuffer as handle  no-undo.
    define buffer icatfour for icatfour.

    vhttBuffer = phttIcatfour:default-buffer-handle.
    if piEtab-cd = ?
    then for each icatfour no-lock
        where icatfour.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icatfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each icatfour no-lock
        where icatfour.soc-cd = piSoc-cd
          and icatfour.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icatfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcatfour no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIcatfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCateg-cd    as handle  no-undo.
    define buffer icatfour for icatfour.

    create query vhttquery.
    vhttBuffer = ghttIcatfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIcatfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCateg-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icatfour exclusive-lock
                where rowid(icatfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icatfour:handle, 'soc-cd/etab-cd/categ-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCateg-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer icatfour:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIcatfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer icatfour for icatfour.

    create query vhttquery.
    vhttBuffer = ghttIcatfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIcatfour:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create icatfour.
            if not outils:copyValidField(buffer icatfour:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIcatfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCateg-cd    as handle  no-undo.
    define buffer icatfour for icatfour.

    create query vhttquery.
    vhttBuffer = ghttIcatfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIcatfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCateg-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icatfour exclusive-lock
                where rowid(Icatfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icatfour:handle, 'soc-cd/etab-cd/categ-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCateg-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete icatfour no-error.
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

