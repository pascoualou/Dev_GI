/*------------------------------------------------------------------------
File        : pclie_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pclie
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/
using parametre.pclie.parametrageRoleDefaut.
using parametre.pclie.parametrageRoleTemporaire.

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttpclie as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phZon01 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'zon01' then phZon01 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePclie.
    run updatePclie.
    run createPclie.
end procedure.

procedure setPclie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPclie.
    ghttPclie = phttPclie.
    run crudPclie.
    delete object phttPclie.
end procedure.

procedure readPclie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pclie 
    Notes  : service externe. Attention, pas d'index unique sur pclie!
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character no-undo.
    define input parameter pcZon01 as character no-undo.
    define input parameter table-handle phttPclie.
    define variable vhttBuffer as handle no-undo.
    define buffer pclie for pclie.

    vhttBuffer = phttPclie:default-buffer-handle.
    for first pclie no-lock
        where pclie.tppar = pcTppar
          and pclie.zon01 = pcZon01:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pclie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPclie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPclie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pclie - tppar, zon01
    Notes  : service externe. Attention, pas d'index unique sur pclie!
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character no-undo.
    define input parameter pcZon01 as character no-undo.
    define input parameter table-handle phttPclie.
    define variable vhttBuffer as handle  no-undo.
    define buffer pclie for pclie.

    vhttBuffer = phttPclie:default-buffer-handle.
    if pcZon01 > ""
    then for each pclie no-lock
        where pclie.tppar = pcTppar
          and pclie.zon01 = pcZon01:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pclie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pclie no-lock
        where pclie.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pclie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPclie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhZon01    as handle  no-undo.
    define buffer pclie for pclie.

    create query vhttquery.
    vhttBuffer = ghttPclie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPclie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhZon01).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pclie exclusive-lock
                where rowid(pclie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pclie:handle, 'tppar/Zon01: ', substitute('&1/&2', vhTppar:buffer-value(), vhZon01:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pclie:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer pclie for pclie.

    create query vhttquery.
    vhttBuffer = ghttPclie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPclie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pclie.
            if not outils:copyValidField(buffer pclie:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhZon01    as handle  no-undo.
    define buffer pclie for pclie.

    create query vhttquery.
    vhttBuffer = ghttPclie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPclie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhZon01).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pclie exclusive-lock
                where rowid(Pclie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pclie:handle, 'tppar/Zon01: ', substitute('&1/&2', vhTppar:buffer-value(), vhZon01:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pclie no-error.
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

procedure getRoleParDefaut:
    /*------------------------------------------------------------------------------
    Purpose: recherche role par defaut en fonction type contrat, nature contrat
    Notes  : service externe (anciennement LecDfRol)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole      as character no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter pcNatureContrat as character no-undo.
    define output parameter plTrouveParam   as logical   no-undo.
    define output parameter piNumeroRole    as integer   no-undo.

    define variable voRoleDefaut as class parametrageRoleDefaut no-undo.

    voRoleDefaut = new parametrageRoleDefaut(?, ?, ?, ?).       // instantiation avec parametre inexistant!
    if pcNatureContrat <> ? and pcTypeContrat <> ?              // Recherche d'un defaut pour ce type de role cette nature et ce type de contrat
    then voRoleDefaut:reload(pcTypeContrat, pcNatureContrat, pcTypeRole, true).
    if pcTypeContrat <> ? and not voRoleDefaut:isDbParameter    // Recherche d'un defaut pour ce type de role ce type de contrat
    then voRoleDefaut:reload(pcTypeContrat, "00000", pcTypeRole, true).
    if not voRoleDefaut:isDbParameter                           // Recherche d'un defaut pour ce type de role
    then voRoleDefaut:reload("00000", "00000", pcTypeRole, true).

    if voRoleDefaut:isDbParameter
    then assign
        piNumeroRole = voRoleDefaut:getNumeroRole()
        plTrouveParam = true
    .
end procedure.

procedure getSyndicatParDefaut:
    /*------------------------------------------------------------------------------
    Purpose: recherche role syndicat par defaut en fonction type contrat, nature contrat, type role
    Notes  : service externe (anciennement lecTmRol).
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole      as character no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter pcNatureContrat as character no-undo.
    define output parameter plTrouveParam   as logical   no-undo.
    define output parameter piNumeroRole    as integer   no-undo.

    define variable voRoleTemporaire as class parametrageRoleTemporaire no-undo.

    voRoleTemporaire = new parametrageRoleTemporaire(?, ?, ?, ?).       // instantiation avec parametre inexistant!
    if pcNatureContrat <> ? and pcTypeContrat <> ?              // Recherche d'un defaut pour ce type de role cette nature et ce type de contrat
    then voRoleTemporaire:reload(pcTypeContrat, pcNatureContrat, pcTypeRole, true).

    if pcTypeContrat <> ? and not voRoleTemporaire:isDbParameter    // Recherche d'un defaut pour ce type de role ce type de contrat
    then voRoleTemporaire:reload(pcTypeContrat, "00000", pcTypeRole, true).

    if not voRoleTemporaire:isDbParameter                           // Recherche d'un defaut pour ce type de role
    then voRoleTemporaire:reload("00000", "00000", pcTypeRole, true).

    if voRoleTemporaire:isDbParameter
    then assign
        piNumeroRole = voRoleTemporaire:getNumeroRole()
        plTrouveParam = true
    .
end procedure.
