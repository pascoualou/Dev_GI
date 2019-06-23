/*------------------------------------------------------------------------
File        : pcorsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pcorsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pcorsai.i}
{application/include/error.i}
define variable ghttpcorsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAnacor-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/anacor-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'anacor-cle' then phAnacor-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPcorsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePcorsai.
    run updatePcorsai.
    run createPcorsai.
end procedure.

procedure setPcorsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPcorsai.
    ghttPcorsai = phttPcorsai.
    run crudPcorsai.
    delete object phttPcorsai.
end procedure.

procedure readPcorsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pcorsai Fichier table de correspondance
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcAnacor-cle as character  no-undo.
    define input parameter table-handle phttPcorsai.
    define variable vhttBuffer as handle no-undo.
    define buffer pcorsai for pcorsai.

    vhttBuffer = phttPcorsai:default-buffer-handle.
    for first pcorsai no-lock
        where pcorsai.soc-cd = piSoc-cd
          and pcorsai.etab-cd = piEtab-cd
          and pcorsai.anacor-cle = pcAnacor-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcorsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcorsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPcorsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pcorsai Fichier table de correspondance
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttPcorsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer pcorsai for pcorsai.

    vhttBuffer = phttPcorsai:default-buffer-handle.
    if piEtab-cd = ?
    then for each pcorsai no-lock
        where pcorsai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcorsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pcorsai no-lock
        where pcorsai.soc-cd = piSoc-cd
          and pcorsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcorsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcorsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePcorsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAnacor-cle    as handle  no-undo.
    define buffer pcorsai for pcorsai.

    create query vhttquery.
    vhttBuffer = ghttPcorsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPcorsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAnacor-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcorsai exclusive-lock
                where rowid(pcorsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcorsai:handle, 'soc-cd/etab-cd/anacor-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAnacor-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pcorsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPcorsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pcorsai for pcorsai.

    create query vhttquery.
    vhttBuffer = ghttPcorsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPcorsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pcorsai.
            if not outils:copyValidField(buffer pcorsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePcorsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAnacor-cle    as handle  no-undo.
    define buffer pcorsai for pcorsai.

    create query vhttquery.
    vhttBuffer = ghttPcorsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPcorsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAnacor-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcorsai exclusive-lock
                where rowid(Pcorsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcorsai:handle, 'soc-cd/etab-cd/anacor-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAnacor-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pcorsai no-error.
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

