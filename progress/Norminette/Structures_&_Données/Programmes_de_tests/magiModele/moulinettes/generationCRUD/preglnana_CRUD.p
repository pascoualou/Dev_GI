/*------------------------------------------------------------------------
File        : preglnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table preglnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/preglnana.i}
{application/include/error.i}
define variable ghttpreglnana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle, output phRecno-reg as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int/recno-reg/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'recno-reg' then phRecno-reg = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPreglnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePreglnana.
    run updatePreglnana.
    run createPreglnana.
end procedure.

procedure setPreglnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPreglnana.
    ghttPreglnana = phttPreglnana.
    run crudPreglnana.
    delete object phttPreglnana.
end procedure.

procedure readPreglnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table preglnana Fichier Tampon ecritures analytiques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piNum-int   as integer    no-undo.
    define input parameter piRecno-reg as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter table-handle phttPreglnana.
    define variable vhttBuffer as handle no-undo.
    define buffer preglnana for preglnana.

    vhttBuffer = phttPreglnana:default-buffer-handle.
    for first preglnana no-lock
        where preglnana.soc-cd = piSoc-cd
          and preglnana.etab-cd = piEtab-cd
          and preglnana.num-int = piNum-int
          and preglnana.recno-reg = piRecno-reg
          and preglnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer preglnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPreglnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPreglnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table preglnana Fichier Tampon ecritures analytiques
    Notes  : service externe. Critère piRecno-reg = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piNum-int   as integer    no-undo.
    define input parameter piRecno-reg as integer    no-undo.
    define input parameter table-handle phttPreglnana.
    define variable vhttBuffer as handle  no-undo.
    define buffer preglnana for preglnana.

    vhttBuffer = phttPreglnana:default-buffer-handle.
    if piRecno-reg = ?
    then for each preglnana no-lock
        where preglnana.soc-cd = piSoc-cd
          and preglnana.etab-cd = piEtab-cd
          and preglnana.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer preglnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each preglnana no-lock
        where preglnana.soc-cd = piSoc-cd
          and preglnana.etab-cd = piEtab-cd
          and preglnana.num-int = piNum-int
          and preglnana.recno-reg = piRecno-reg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer preglnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPreglnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePreglnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhRecno-reg    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer preglnana for preglnana.

    create query vhttquery.
    vhttBuffer = ghttPreglnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPreglnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhRecno-reg, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first preglnana exclusive-lock
                where rowid(preglnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer preglnana:handle, 'soc-cd/etab-cd/num-int/recno-reg/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhRecno-reg:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer preglnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPreglnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer preglnana for preglnana.

    create query vhttquery.
    vhttBuffer = ghttPreglnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPreglnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create preglnana.
            if not outils:copyValidField(buffer preglnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePreglnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhRecno-reg    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer preglnana for preglnana.

    create query vhttquery.
    vhttBuffer = ghttPreglnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPreglnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhRecno-reg, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first preglnana exclusive-lock
                where rowid(Preglnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer preglnana:handle, 'soc-cd/etab-cd/num-int/recno-reg/pos: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhRecno-reg:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete preglnana no-error.
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

