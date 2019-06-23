/*------------------------------------------------------------------------
File        : pregln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pregln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pregln.i}
{application/include/error.i}
define variable ghttpregln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle, output phLig-reg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int/lig-reg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'lig-reg' then phLig-reg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPregln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePregln.
    run updatePregln.
    run createPregln.
end procedure.

procedure setPregln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPregln.
    ghttPregln = phttPregln.
    run crudPregln.
    delete object phttPregln.
end procedure.

procedure readPregln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pregln Fichier Reglements (Gestion des Encaissements)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piLig-reg as integer    no-undo.
    define input parameter table-handle phttPregln.
    define variable vhttBuffer as handle no-undo.
    define buffer pregln for pregln.

    vhttBuffer = phttPregln:default-buffer-handle.
    for first pregln no-lock
        where pregln.soc-cd = piSoc-cd
          and pregln.etab-cd = piEtab-cd
          and pregln.num-int = piNum-int
          and pregln.lig-reg = piLig-reg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pregln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPregln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPregln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pregln Fichier Reglements (Gestion des Encaissements)
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttPregln.
    define variable vhttBuffer as handle  no-undo.
    define buffer pregln for pregln.

    vhttBuffer = phttPregln:default-buffer-handle.
    if piNum-int = ?
    then for each pregln no-lock
        where pregln.soc-cd = piSoc-cd
          and pregln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pregln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pregln no-lock
        where pregln.soc-cd = piSoc-cd
          and pregln.etab-cd = piEtab-cd
          and pregln.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pregln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPregln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePregln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig-reg    as handle  no-undo.
    define buffer pregln for pregln.

    create query vhttquery.
    vhttBuffer = ghttPregln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPregln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhLig-reg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pregln exclusive-lock
                where rowid(pregln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pregln:handle, 'soc-cd/etab-cd/num-int/lig-reg: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhLig-reg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pregln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPregln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pregln for pregln.

    create query vhttquery.
    vhttBuffer = ghttPregln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPregln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pregln.
            if not outils:copyValidField(buffer pregln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePregln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig-reg    as handle  no-undo.
    define buffer pregln for pregln.

    create query vhttquery.
    vhttBuffer = ghttPregln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPregln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhLig-reg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pregln exclusive-lock
                where rowid(Pregln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pregln:handle, 'soc-cd/etab-cd/num-int/lig-reg: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhLig-reg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pregln no-error.
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

