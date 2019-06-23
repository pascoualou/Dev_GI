/*------------------------------------------------------------------------
File        : cpaierep_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpaierep
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpaierep.i}
{application/include/error.i}
define variable ghttcpaierep as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phChrono as handle, output phLibpaie-cd as handle, output phDaech as handle, output phColl-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/chrono/libpaie-cd/daech/coll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'chrono' then phChrono = phBuffer:buffer-field(vi).
            when 'libpaie-cd' then phLibpaie-cd = phBuffer:buffer-field(vi).
            when 'daech' then phDaech = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpaierep private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpaierep.
    run updateCpaierep.
    run createCpaierep.
end procedure.

procedure setCpaierep:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpaierep.
    ghttCpaierep = phttCpaierep.
    run crudCpaierep.
    delete object phttCpaierep.
end procedure.

procedure readCpaierep:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpaierep Fichier Paiement Fournisseur (Repartition)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piChrono     as integer    no-undo.
    define input parameter piLibpaie-cd as integer    no-undo.
    define input parameter pdaDaech      as date       no-undo.
    define input parameter pcColl-cle   as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttCpaierep.
    define variable vhttBuffer as handle no-undo.
    define buffer cpaierep for cpaierep.

    vhttBuffer = phttCpaierep:default-buffer-handle.
    for first cpaierep no-lock
        where cpaierep.soc-cd = piSoc-cd
          and cpaierep.etab-cd = piEtab-cd
          and cpaierep.chrono = piChrono
          and cpaierep.libpaie-cd = piLibpaie-cd
          and cpaierep.daech = pdaDaech
          and cpaierep.coll-cle = pcColl-cle
          and cpaierep.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaierep:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaierep no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpaierep:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpaierep Fichier Paiement Fournisseur (Repartition)
    Notes  : service externe. Critère pcColl-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piChrono     as integer    no-undo.
    define input parameter piLibpaie-cd as integer    no-undo.
    define input parameter pdaDaech      as date       no-undo.
    define input parameter pcColl-cle   as character  no-undo.
    define input parameter table-handle phttCpaierep.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpaierep for cpaierep.

    vhttBuffer = phttCpaierep:default-buffer-handle.
    if pcColl-cle = ?
    then for each cpaierep no-lock
        where cpaierep.soc-cd = piSoc-cd
          and cpaierep.etab-cd = piEtab-cd
          and cpaierep.chrono = piChrono
          and cpaierep.libpaie-cd = piLibpaie-cd
          and cpaierep.daech = pdaDaech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaierep:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpaierep no-lock
        where cpaierep.soc-cd = piSoc-cd
          and cpaierep.etab-cd = piEtab-cd
          and cpaierep.chrono = piChrono
          and cpaierep.libpaie-cd = piLibpaie-cd
          and cpaierep.daech = pdaDaech
          and cpaierep.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaierep:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaierep no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpaierep private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhLibpaie-cd    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cpaierep for cpaierep.

    create query vhttquery.
    vhttBuffer = ghttCpaierep:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpaierep:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhLibpaie-cd, output vhDaech, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaierep exclusive-lock
                where rowid(cpaierep) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaierep:handle, 'soc-cd/etab-cd/chrono/libpaie-cd/daech/coll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhLibpaie-cd:buffer-value(), vhDaech:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpaierep:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpaierep private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpaierep for cpaierep.

    create query vhttquery.
    vhttBuffer = ghttCpaierep:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpaierep:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpaierep.
            if not outils:copyValidField(buffer cpaierep:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpaierep private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhLibpaie-cd    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cpaierep for cpaierep.

    create query vhttquery.
    vhttBuffer = ghttCpaierep:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpaierep:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhLibpaie-cd, output vhDaech, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaierep exclusive-lock
                where rowid(Cpaierep) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaierep:handle, 'soc-cd/etab-cd/chrono/libpaie-cd/daech/coll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhLibpaie-cd:buffer-value(), vhDaech:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpaierep no-error.
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

