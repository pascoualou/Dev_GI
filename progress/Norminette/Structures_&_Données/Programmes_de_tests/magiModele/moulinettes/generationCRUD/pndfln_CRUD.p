/*------------------------------------------------------------------------
File        : pndfln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pndfln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pndfln.i}
{application/include/error.i}
define variable ghttpndfln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPndfln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePndfln.
    run updatePndfln.
    run createPndfln.
end procedure.

procedure setPndfln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPndfln.
    ghttPndfln = phttPndfln.
    run crudPndfln.
    delete object phttPndfln.
end procedure.

procedure readPndfln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pndfln Fichier lignes notes de frais
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter table-handle phttPndfln.
    define variable vhttBuffer as handle no-undo.
    define buffer pndfln for pndfln.

    vhttBuffer = phttPndfln:default-buffer-handle.
    for first pndfln no-lock
        where pndfln.soc-cd = piSoc-cd
          and pndfln.etab-cd = piEtab-cd
          and pndfln.num-int = piNum-int
          and pndfln.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pndfln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPndfln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPndfln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pndfln Fichier lignes notes de frais
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttPndfln.
    define variable vhttBuffer as handle  no-undo.
    define buffer pndfln for pndfln.

    vhttBuffer = phttPndfln:default-buffer-handle.
    if piNum-int = ?
    then for each pndfln no-lock
        where pndfln.soc-cd = piSoc-cd
          and pndfln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pndfln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pndfln no-lock
        where pndfln.soc-cd = piSoc-cd
          and pndfln.etab-cd = piEtab-cd
          and pndfln.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pndfln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPndfln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePndfln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer pndfln for pndfln.

    create query vhttquery.
    vhttBuffer = ghttPndfln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPndfln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pndfln exclusive-lock
                where rowid(pndfln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pndfln:handle, 'soc-cd/etab-cd/num-int/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pndfln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPndfln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pndfln for pndfln.

    create query vhttquery.
    vhttBuffer = ghttPndfln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPndfln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pndfln.
            if not outils:copyValidField(buffer pndfln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePndfln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer pndfln for pndfln.

    create query vhttquery.
    vhttBuffer = ghttPndfln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPndfln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pndfln exclusive-lock
                where rowid(Pndfln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pndfln:handle, 'soc-cd/etab-cd/num-int/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pndfln no-error.
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

