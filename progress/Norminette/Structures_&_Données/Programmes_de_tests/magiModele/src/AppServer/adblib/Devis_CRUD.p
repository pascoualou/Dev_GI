/*------------------------------------------------------------------------
File        : Devis_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Devis
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Devis.i}
{application/include/error.i}
define variable ghttDevis as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodev as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoDev, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoDev' then phNodev = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDevis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDevis.
    run updateDevis.
    run createDevis.
end procedure.

procedure setDevis:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDevis.
    ghttDevis = phttDevis.
    run crudDevis.
    delete object phttDevis.
end procedure.

procedure readDevis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Devis Chaine Travaux : Table des Devis
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodev as integer    no-undo.
    define input parameter table-handle phttDevis.
    define variable vhttBuffer as handle no-undo.
    define buffer Devis for Devis.

    vhttBuffer = phttDevis:default-buffer-handle.
    for first Devis no-lock
        where Devis.NoDev = piNodev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Devis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDevis no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDevis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Devis Chaine Travaux : Table des Devis
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDevis.
    define variable vhttBuffer as handle  no-undo.
    define buffer Devis for Devis.

    vhttBuffer = phttDevis:default-buffer-handle.
    for each Devis no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Devis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDevis no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDevis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodev    as handle  no-undo.
    define buffer Devis for Devis.

    create query vhttquery.
    vhttBuffer = ghttDevis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDevis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Devis exclusive-lock
                where rowid(Devis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Devis:handle, 'NoDev: ', substitute('&1', vhNodev:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Devis:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDevis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Devis for Devis.

    create query vhttquery.
    vhttBuffer = ghttDevis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDevis:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Devis.
            if not outils:copyValidField(buffer Devis:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDevis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodev    as handle  no-undo.
    define buffer Devis for Devis.

    create query vhttquery.
    vhttBuffer = ghttDevis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDevis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Devis exclusive-lock
                where rowid(Devis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Devis:handle, 'NoDev: ', substitute('&1', vhNodev:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Devis no-error.
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

procedure deleteDevisSurNofou:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection et des tables dependantes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroFournisseur as integer no-undo.
 
    define buffer devis for devis.
    define buffer dtdev for dtdev.
    define buffer inter for inter.
    define buffer trint for trint.
    define buffer dtlot for dtlot.
    define buffer svdev for svdev.

blocTrans:
    do transaction:
        for each devis exclusive-lock                                  //devis
           where devis.nofou = piNumeroFournisseur:
            for each dtdev exclusive-lock                              //detail devis
               where dtdev.nodev = devis.nodev:
                for first inter exclusive-lock                         //intervention
                    where inter.noint = dtdev.noint:
                    for each trint exclusive-lock                      //traitements intervention
                       where trint.noint = inter.noint:
                        delete trint no-error.
                        if error-status:error then do:
                            mError:createError({&error}, error-status:get-message(1)).
                            undo blocTrans, leave blocTrans.
                        end.                        
                    end.
                    delete inter.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans.
                    end.
                end.
                delete dtdev no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            for each trint exclusive-lock                              //traitement devis
               where trint.tptrt = {&TYPEINTERVENTION-demande2devis}
                 and trint.notrt = devis.nodev:
                delete trint no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                
            end.
            for each dtlot exclusive-lock                               //lot associe
               where dtlot.tptrt = {&TYPEINTERVENTION-demande2devis}
                 and dtlot.notrt = devis.nodev:
                delete dtlot no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                
            end.
            for each svdev exclusive-lock                              //detail reponse devis
               where svdev.nodev = devis.nodev:
                delete svdev no-error.
            end.
            for each trint exclusive-lock
               where trint.tptrt = {&TYPEINTERVENTION-reponseDevis}
                 and trint.notrt = devis.nodev:
                delete trint no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                
            end.
            delete devis no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.


