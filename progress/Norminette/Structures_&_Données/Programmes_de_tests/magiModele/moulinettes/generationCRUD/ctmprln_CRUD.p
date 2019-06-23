/*------------------------------------------------------------------------
File        : ctmprln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ctmprln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ctmprln.i}
{application/include/error.i}
define variable ghttctmprln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phUsrid as handle, output phLig-reg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/usrid/lig-reg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'usrid' then phUsrid = phBuffer:buffer-field(vi).
            when 'lig-reg' then phLig-reg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCtmprln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCtmprln.
    run updateCtmprln.
    run createCtmprln.
end procedure.

procedure setCtmprln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtmprln.
    ghttCtmprln = phttCtmprln.
    run crudCtmprln.
    delete object phttCtmprln.
end procedure.

procedure readCtmprln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ctmprln Fichier Reglements (Gestion des Encaissements)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcUsrid   as character  no-undo.
    define input parameter piLig-reg as integer    no-undo.
    define input parameter table-handle phttCtmprln.
    define variable vhttBuffer as handle no-undo.
    define buffer ctmprln for ctmprln.

    vhttBuffer = phttCtmprln:default-buffer-handle.
    for first ctmprln no-lock
        where ctmprln.soc-cd = piSoc-cd
          and ctmprln.etab-cd = piEtab-cd
          and ctmprln.usrid = pcUsrid
          and ctmprln.lig-reg = piLig-reg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmprln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtmprln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtmprln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ctmprln Fichier Reglements (Gestion des Encaissements)
    Notes  : service externe. Critère pcUsrid = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcUsrid   as character  no-undo.
    define input parameter table-handle phttCtmprln.
    define variable vhttBuffer as handle  no-undo.
    define buffer ctmprln for ctmprln.

    vhttBuffer = phttCtmprln:default-buffer-handle.
    if pcUsrid = ?
    then for each ctmprln no-lock
        where ctmprln.soc-cd = piSoc-cd
          and ctmprln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmprln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ctmprln no-lock
        where ctmprln.soc-cd = piSoc-cd
          and ctmprln.etab-cd = piEtab-cd
          and ctmprln.usrid = pcUsrid:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmprln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtmprln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtmprln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhUsrid    as handle  no-undo.
    define variable vhLig-reg    as handle  no-undo.
    define buffer ctmprln for ctmprln.

    create query vhttquery.
    vhttBuffer = ghttCtmprln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtmprln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhUsrid, output vhLig-reg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctmprln exclusive-lock
                where rowid(ctmprln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctmprln:handle, 'soc-cd/etab-cd/usrid/lig-reg: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhUsrid:buffer-value(), vhLig-reg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctmprln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtmprln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ctmprln for ctmprln.

    create query vhttquery.
    vhttBuffer = ghttCtmprln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtmprln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ctmprln.
            if not outils:copyValidField(buffer ctmprln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtmprln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhUsrid    as handle  no-undo.
    define variable vhLig-reg    as handle  no-undo.
    define buffer ctmprln for ctmprln.

    create query vhttquery.
    vhttBuffer = ghttCtmprln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtmprln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhUsrid, output vhLig-reg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctmprln exclusive-lock
                where rowid(Ctmprln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctmprln:handle, 'soc-cd/etab-cd/usrid/lig-reg: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhUsrid:buffer-value(), vhLig-reg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ctmprln no-error.
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

