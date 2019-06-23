/*------------------------------------------------------------------------
File        : cttac_CRUD.p
Purpose     : maj des relations contrat - tache
Author(s)   : GGA  -  2017/07/31
Notes       : pour l'instant seulement reprise de procedure creation et suppression
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/referenceClient.i}
{preprocesseur/mode2gestionFournisseurLoyer.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageBudgetLocatif.
using parametre.pclie.parametrageReleveGerance.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define variable ghttCttac as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des 3 champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tptac, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when "tpcon" then phTpcon = phBuffer:buffer-field(vi).
            when "nocon" then phNocon = phBuffer:buffer-field(vi).
            when "tptac" then phTptac = phBuffer:buffer-field(vi).
        end case.
    end.
end function.

procedure crudCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    run deleteCttac.
    run updateCttac.
    run createCttac.
end procedure.

procedure setCttac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe - A appeler avec by-reference.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCttac.
    ghttCttac = phttCttac.
    run crudCttac.
    delete object phttCttac.
end procedure.

procedure readCttac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cttac
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define input parameter table-handle phttCttac.

    define variable vhttBuffer as handle no-undo.
    define buffer cttac for cttac.
    {&_proparse_ prolint-nowarn(noeffect)}
    integer(pcTypeTache) no-error.
    if error-status:error then do:
        mError:createError({&error}, error-status:get-message(1)).
        error-status:error = false no-error.
        return.
    end.
    if length(pcTypeTache, 'character') < 5 then pcTypeTache = string(integer(pcTypeTache), '99999').

    vhttBuffer = phttCttac:default-buffer-handle.
    for first cttac no-lock
        where cttac.tpCon = pcTypeContrat
          and cttac.nocon = piNumeroContrat
          and cttac.tptac = pcTypeTache:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttcttac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCttac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cttac correspondants au critère 
    Notes  : service utilisé par genoffqt.p?
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter table-handle phttCttac.

    define variable vhttBuffer as handle  no-undo.
    define buffer cttac for cttac.

    vhttBuffer = phttCttac:default-buffer-handle.
    if piNumeroContrat = ? or piNumeroContrat = 0
    then for each cttac no-lock
        where cttac.tpCon = pcTypeContrat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cttac no-lock
        where cttac.tpCon = pcTypeContrat
          and cttac.nocon = piNumeroContrat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCttac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCttac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cttac exclusive-lock
                 where rowid(cttac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cttac:handle, 'tpcon/nocon/tptac: ', substitute("&1/&2/&3", vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cttac:handle, vhttBuffer, 'U', mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCttac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cttac.
            if not outils:copyValidField(buffer cttac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCttac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cttac exclusive-lock
                where rowid(cttac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cttac:handle, 'tpcon/nocon/tptac: ', substitute("&1/&2/&3", vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cttac no-error.
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

procedure suppressionCttac:
    /*-----------------------------------------------------------------------------
    Purpose : Suppression d'un Enregistrement de cttac à partir de la clé.
    notes   : service Anciennement SupCttac
    -----------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define buffer cttac for cttac.

blocTrans:
    do transaction:
        find first cttac exclusive-lock
            where cttac.tpcon = pcTypeContrat
                and cttac.nocon = piNumeroContrat
                and cttac.tptac = pcTypeTache no-wait no-error.
        if not available cttac    // enregistrement déjà supprimé (par un autre utilisateur?)
        then mError:createError({&error},
                                if locked cttac then 211652 else 211651,
                                substitute("cttac: &1/&2/&3", pcTypeContrat, piNumeroContrat, pcTypeTache)).
        else do:
            delete cttac no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    assign error-status:error = false no-error.    // reset error-status
    return.

end procedure.

procedure deleteCttacSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer cttac for cttac.

blocTrans:
    do transaction:
        for each cttac exclusive-lock 
            where cttac.tpcon = pcTypeContrat 
              and cttac.nocon = piNumeroContrat:
            delete cttac no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
