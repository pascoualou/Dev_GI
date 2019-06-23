/*------------------------------------------------------------------------
File        : unite_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table unite
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
              Pour l'instant, reprise de procedure maj (cf l_unite_ext.p pour reprendre les autres (blcUnite, RecDatFinMax, SupAveRen)
derniere revue: 2018/08/08 - phm: KO
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/referenceClient.i}

{oerealm/include/instanciateTokenOnModel.i}          // Doit être positionnée juste après using

define variable ghttunite    as handle no-undo.      // le handle de la temp table à mettre à jour
define variable ghProcAlimaj as handle no-undo.

function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNoapp as handle, output phNoact as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/noapp/noact, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'noact' then phNoact = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudUnite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteUnite.
    run updateUnite.
    run createUnite.
end procedure.

procedure setUnite:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttUnite.

    ghttUnite = phttUnite.
    run application/transfert/GI_alimaj.p persistent set ghProcAlimaj.
    run getTokenInstance in ghProcAlimaj(mToken:JSessionId).
    run crudUnite.
    run destroy in ghProcAlimaj no-error. 
    delete object phttUnite.
end procedure.

procedure readUnite:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table unite unite  - Unite de location (Appartement)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer   no-undo.
    define input parameter piNoapp as integer   no-undo.
    define input parameter piNoact as integer   no-undo.
    define input parameter table-handle phttUnite.

    define variable vhttBuffer as handle no-undo.
    define buffer unite for unite.

    vhttBuffer = phttUnite:default-buffer-handle.
    for first unite no-lock
        where unite.nomdt = piNomdt
          and unite.noapp = piNoapp
          and unite.noact = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer unite:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUnite no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getUnite:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table unite unite  - Unite de location (Appartement)
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttUnite.
    define variable vhttBuffer as handle  no-undo.
    define buffer unite for unite.

    vhttBuffer = phttUnite:default-buffer-handle.
    if piNoapp = ?
    then for each unite no-lock
        where unite.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer unite:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each unite no-lock
        where unite.nomdt = piNomdt
          and unite.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer unite:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUnite no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateUnite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define buffer unite for unite.

    create query vhttquery.
    vhttBuffer = ghttUnite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttUnite:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoapp, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first unite exclusive-lock
                where rowid(unite) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer unite:handle, 'nomdt/noapp/noact: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer unite:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            if integer(mToken:cRefGerance) <> {&REFCLIENT-MANPOWER} then run majTabTrf(unite.nomdt).
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createUnite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer unite for unite.

    create query vhttquery.
    vhttBuffer = ghttUnite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttUnite:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create unite.
            if not outils:copyValidField(buffer unite:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
            
            if integer(mToken:cRefGerance) <> {&REFCLIENT-MANPOWER} then run majTabTrf(unite.nomdt).
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteUnite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define buffer unite for unite.

    create query vhttquery.
    vhttBuffer = ghttUnite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttUnite:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoapp, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first unite exclusive-lock
                where rowid(Unite) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer unite:handle, 'nomdt/noapp/noact: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNoapp:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

// todo pourquoi pas de suppression des cpuni comme dans deleteUniteEtLienSurMandat????
// todo rien sur local ???

            delete unite no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.

// todo  pourquoi en mode suppression, pas de if integer(mToken:cRefGerance) <> 10 then run majTabTrf(unite.nomdt). ???

        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure majTabTrf private:
    /*------------------------------------------------------------------------------
    Purpose: mise a jour table pour les transferts
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter piNocon as int64 no-undo.
    define buffer ctrat for ctrat.

    for first ctrat no-lock 
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNocon:
        run majTrace in ghProcAlimaj(integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
    end.

end procedure.

procedure deleteUniteEtLienSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
             et des enregistrements des tables dependantes 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.

    define buffer unite for unite.
    define buffer cpuni for cpuni.

blocTrans:
    do transaction:
        for each unite no-lock
            where unite.nomdt = piNumeroMandat:
            for each cpuni exclusive-lock
               where cpuni.nomdt = unite.nomdt
                 and cpuni.noapp = unite.noapp
                 and cpuni.nocmp = unite.nocmp:
                delete cpuni no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                   undo blocTrans, leave blocTrans.
                end.
            end.
            delete unite no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.

// todo  pourquoi en mode suppression, pas de if integer(mToken:cRefGerance) <> 10 then run majTabTrf(unite.nomdt). ???

        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
