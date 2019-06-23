/*------------------------------------------------------------------------
File        : tiers_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tiers
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/04/24 - phm: OK
            peut-être à fusionner avec tiers.p ???
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghtttiers as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNotie as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notie, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notie' then phNotie = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

function getNextTiers returns int64 private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer tiers for tiers.
    {&_proparse_ prolint-nowarn(wholeIndex)}
    for last tiers no-lock:
        return tiers.notie + 1.
    end.
    return 1.
end function.

procedure crudTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTiers.
    run updateTiers.
    run createTiers.
end procedure.

procedure setTiers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTiers.
    ghttTiers = phttTiers.
    run crudTiers.
    delete object phttTiers.
end procedure.

procedure readTiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tiers 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotie as int64   no-undo.
    define input parameter table-handle phttTiers.

    define variable vhttBuffer as handle no-undo.
    define buffer tiers for tiers.

    vhttBuffer = phttTiers:default-buffer-handle.
    for first tiers no-lock
        where tiers.notie = piNotie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTiers no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tiers 
    Notes  : service externe.
    todo     soit supprimer (pas de sens de faire un getTiers global, soit rajouter des criteres
             numerofiscal, cdfat+cdsft, fgct4+lnom4, nocon, cdcv1, lnom2, cdext, lnom1
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTiers.

    define variable vhttBuffer as handle  no-undo.
    define buffer tiers for tiers.

    vhttBuffer = phttTiers:default-buffer-handle.
    for each tiers no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTiers no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotie    as handle  no-undo.
    define buffer tiers for tiers.
    define buffer ctanx for ctanx.
    define buffer tutil for tutil.

    create query vhttquery.
    vhttBuffer = ghttTiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tiers exclusive-lock
                where rowid(tiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tiers:handle, 'notie: ', substitute('&1', vhNotie:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tiers:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            // Si modification collaborateur alors mettre à jour tutil associé
            {&_proparse_ prolint-nowarn(wholeIndex)}
            for each tutil exclusive-lock
                where tutil.notie = tiers.notie:
                assign
                    tutil.nom      = tiers.lNom1
                    tutil.lnom1    = tiers.lnom1
                    tutil.lpre1    = tiers.lpre1
                    tutil.damod    = today
                    tutil.ihmod    = time
                    tutil.usridmod = tiers.cdmsy
                . 
            end.
            // Mise à jour du contrat annexe pour le numéro d'immatriculation
            if vhttBuffer::cNumeroImmatriculation > "" then do:
                find first ctanx exclusive-lock
                    where ctanx.tpcon = {&TYPECONTRAT-Association}
                      and ctanx.nocon = tiers.nocon no-error.
                if not available ctanx then do:
                    create ctanx.
                    assign
                        ctanx.cdcsy = tiers.cdmsy
                        ctanx.dtcsy = today
                        ctanx.hecsy = time
                    .
                end.
                assign
                    ctanx.tpcon = {&TYPECONTRAT-Association}
                    ctanx.nocon = tiers.nocon
                    ctanx.lbdiv = vhttBuffer::cNumeroImmatriculation
                    ctanx.cdmsy = tiers.cdmsy
                    ctanx.dtmsy = today
                    ctanx.hemsy = time
                .
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable viNotie    as int64   no-undo.
    define variable vhNotie    as handle  no-undo.
    define buffer tiers for tiers.

    create query vhttquery.
    vhttBuffer = ghttTiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            viNotie = vhNotie:buffer-value().
            if viNoTie = 0 then viNoTie = getNextTiers().
            vhNotie:buffer-value() = viNotie.

            create tiers.
            if not outils:copyValidField(buffer tiers:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNotie    as handle  no-undo.
    define buffer tiers for tiers.

    create query vhttquery.
    vhttBuffer = ghttTiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tiers exclusive-lock
                where rowid(Tiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tiers:handle, 'notie: ', substitute('&1', vhNotie:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tiers no-error.
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

procedure supTie01:
    /*------------------------------------------------------------------------------
    Purpose: a partir de adb/lib/suptie01.p
             Suppression d'un Tiers après contrôle (lib\ctsuptie.p) (en gestion uniquement)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroTiers as int64 no-undo.

    define buffer tiers for tiers.
    define buffer ctanx for ctanx. 
    define buffer tier2 for tier2.
    define buffer litie for litie.
 
message "supTie01 " piNumeroTiers. 
//gga todo voir pour les valeurs de tpcon ???????????????????? 
blocTrans:
    do transaction:
        for each tiers exclusive-lock
           where tiers.notie = piNumeroTiers:
            /* contrat annexe (contrat de mariage ou statut st‚) */
            for each ctanx exclusive-lock 
               where ctanx.tpcon = "01002" 
                 and ctanx.nocon = tiers.nocon:
                delete ctanx no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                
            end.
            /* banques           */
            for each ctanx exclusive-lock 
                where ctanx.tpcon = "01038" 
                  and ctanx.tprol = "99999" 
                  and ctanx.norol = piNumeroTiers:
                delete ctanx no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                                
            end.
            /* NP 0416/0226 : RIB en attente de validation */
            for each ctanx exclusive-lock 
                where ctanx.tpcon = "01138" 
                  and ctanx.tprol = {&TYPEROLE-tiers} 
                  and ctanx.norol = piNumeroTiers:
                delete ctanx no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                                
            end.
            /* contrat employeur */
            for each ctanx exclusive-lock 
                where ctanx.tpcon = "01047" 
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = piNumeroTiers:
                delete ctanx no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                                
            end.
            /* Infos mobiles */
            for each tier2 exclusive-lock
               where tier2.notie = piNumeroTiers:
                delete tier2 no-error.
            end.
            /* liens couple */
            for each litie exclusive-lock
               where litie.notie = piNumeroTiers:
                delete litie.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                                
            end.
            delete tiers no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.                            
        end.
    end.        
    error-status:error = false no-error.  // reset error-status

end procedure.
