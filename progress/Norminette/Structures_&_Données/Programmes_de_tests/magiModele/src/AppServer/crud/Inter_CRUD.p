/*------------------------------------------------------------------------
File        : Inter_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Inter
Author(s)   : generation automatique le 08/08/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
{outils/include/lancementProgramme.i}

define variable ghttInter as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoInt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoInt' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudInter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteInter.
    run updateInter.
    run createInter.
end procedure.

procedure setInter:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttInter.
    ghttInter = phttInter.
    run crudInter.
    delete object phttInter.
end procedure.

procedure readInter:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Inter Chaine Travaux : Tables des Interventions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttInter.
    define variable vhttBuffer as handle no-undo.
    define buffer Inter for Inter.

    vhttBuffer = phttInter:default-buffer-handle.
    for first Inter no-lock
        where Inter.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Inter:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInter no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getInter:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Inter Chaine Travaux : Tables des Interventions
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttInter.
    define variable vhttBuffer as handle  no-undo.
    define buffer Inter for Inter.

    vhttBuffer = phttInter:default-buffer-handle.
    for each Inter no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Inter:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInter no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateInter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhNoint as handle  no-undo.
    define buffer Inter for Inter.

    create query vhttquery.
    vhttBuffer = ghttInter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttInter:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Inter exclusive-lock
                where rowid(Inter) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Inter:handle, 'NoInt: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Inter:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createInter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Inter for Inter.

    create query vhttquery.
    vhttBuffer = ghttInter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttInter:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Inter.
            if not outils:copyValidField(buffer Inter:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteInter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint as handle  no-undo.
    define buffer Inter for Inter.

    create query vhttquery.
    vhttBuffer = ghttInter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttInter:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Inter exclusive-lock
                where rowid(Inter) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Inter:handle, 'NoInt: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Inter no-error.
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

procedure deleteInterventionContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression des interventions pour un contrat 
    Notes  : service externe
             a partir de adb/lib/supinter.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define variable vhProc as handle no-undo.

    define buffer inter for inter.
    define buffer dtven for dtven.
    define buffer dtfac for dtfac.
    define buffer factu for factu.
    define buffer dtord for dtord.
    define buffer ordse for ordse.
    define buffer svdev for svdev.
    define buffer devis for devis.
    define buffer dtdev for dtdev.
    define buffer trint for trint.
    define buffer signa for signa.

    vhProc = lancementPgm ("evenementiel/supEvenementiel.p", poCollectionHandlePgm).
    for each inter exclusive-lock
       where inter.tpcon = pcTypeContrat
         and inter.nocon = piNumeroContrat:
        /*--> Suppression des ventilations analytique */
        for each dtven exclusive-lock
           where dtven.noint = inter.noint:
            delete dtven.
        end.
        /*--> Suppression des factures */
        for each dtfac exclusive-lock
           where dtfac.noint = inter.noint:
            for first factu exclusive-lock
                where factu.nofac = dtfac.nofac:
                run supEvenementiel in vhProc({&TYPEINTERVENTION-facture}, factu.nofac, input-output poCollectionHandlePgm).
                delete factu.
            end.
            delete dtfac.
        end.
        /*--> Suppression des ordres de services */
        for each dtord exclusive-lock
           where dtord.noint = inter.noint:
            for first ordse exclusive-lock
                where ordse.noord = dtord.noord:
                run supEvenementiel in vhProc({&TYPEINTERVENTION-ordre2service}, ordse.noord, input-output poCollectionHandlePgm).    
                delete ordse.
            end.
            delete dtord.
        end.
        /*--> Suppression des réponses fournisseurs */
        for each svdev exclusive-lock
           where svdev.noint = inter.noint:
            for first devis exclusive-lock
                where devis.nodev = svdev.nodev:
                run supEvenementiel in vhProc({&TYPEINTERVENTION-reponseDevis}, devis.nodev, input-output poCollectionHandlePgm).    
                delete devis.
            end.
            delete svdev.
        end.
        /*--> Suppression des devis */
        for each dtdev exclusive-lock
           where dtdev.noint = inter.noint:
            for first devis exclusive-lock
                where devis.nodev = dtdev.nodev:
                run supEvenementiel in vhProc({&TYPEINTERVENTION-demande2devis}, devis.nodev, input-output poCollectionHandlePgm).    
                delete devis.
            end.
            delete dtdev.
        end.
        /*--> Suppression du suivi travaux */
        for each trint exclusive-lock
           where trint.noint = inter.noint:
            delete trint.
        end.
        /*--> Suppression du signalement */
        for each signa exclusive-lock
           where signa.nosig = inter.nosig:
            run supEvenementiel in vhProc({&TYPEINTERVENTION-signalement}, signa.nosig, input-output poCollectionHandlePgm).   
            delete signa.
        end.
        delete inter.
    end.

end procedure.
