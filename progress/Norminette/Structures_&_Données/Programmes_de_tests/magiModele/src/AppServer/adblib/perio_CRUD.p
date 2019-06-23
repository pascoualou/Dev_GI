/*------------------------------------------------------------------------
File        : perio_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table perio
Author(s)   : generation automatique le 01/24/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
// {include/perio.i}
//{application/include/error.i}
define variable ghttperio as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpctt as handle, output phNomdt as handle, output phNoexo as handle, output phNoper as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpctt/nomdt/noexo/noper, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpctt' then phTpctt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPerio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePerio.
    run updatePerio.
    run createPerio.
end procedure.

procedure setPerio:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPerio.
    ghttPerio = phttPerio.
    run crudPerio.
    delete object phttPerio.
end procedure.

procedure readPerio:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table perio 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter table-handle phttPerio.

    define variable vhttBuffer as handle no-undo.
    define buffer perio for perio.

    vhttBuffer = phttPerio:default-buffer-handle.
    for first perio no-lock
        where perio.tpctt = pcTpctt
          and perio.nomdt = piNomdt
          and perio.noexo = piNoexo
          and perio.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer perio:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPerio no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPerio:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table perio 
    Notes  : service externe. Critère piNoexo = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define output parameter table-handle phttPerio.

    define variable vhttBuffer as handle  no-undo.
    define buffer perio for perio.

    vhttBuffer = phttPerio:default-buffer-handle.
    if piNoexo = ?
    then for each perio no-lock
        where perio.tpctt = pcTpctt
          and perio.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer perio:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each perio no-lock
        where perio.tpctt = pcTpctt
          and perio.nomdt = piNomdt
          and perio.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer perio:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPerio no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePerio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer perio for perio.

    create query vhttquery.
    vhttBuffer = ghttPerio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPerio:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNomdt, output vhNoexo, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first perio exclusive-lock
                where rowid(perio) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer perio:handle, 'tpctt/nomdt/noexo/noper: ', substitute('&1/&2/&3/&4', vhTpctt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer perio:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPerio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer perio for perio.

    create query vhttquery.
    vhttBuffer = ghttPerio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPerio:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create perio.
            if not outils:copyValidField(buffer perio:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePerio private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer perio for perio.

    create query vhttquery.
    vhttBuffer = ghttPerio:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPerio:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNomdt, output vhNoexo, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first perio exclusive-lock
                where rowid(Perio) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer perio:handle, 'tpctt/nomdt/noexo/noper: ', substitute('&1/&2/&3/&4', vhTpctt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete perio no-error.
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

procedure deletePeriodeCharge:
    /*------------------------------------------------------------------------------
    Purpose: lecture des periodes de charge pour appel suppression
             reprise adb/lib/supchloc.p
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat    as character no-undo.
    define input parameter piNumeroMandat  as int64     no-undo.
    define input parameter piNumeroPeriode as integer   no-undo.

    define buffer perio for perio.
     
    for each perio no-lock
       where perio.tpctt = pcTypeMandat  
         and perio.nomdt = piNumeroMandat
         and perio.noper = piNumeroPeriode:
        run trtSupPeriodeCharge (pcTypeMandat, piNumeroMandat, piNumeroPeriode, perio.noexo). 
        if mError:erreur() then return.
    end.

end procedure.

procedure trtSupPeriodeCharge private:
    /*------------------------------------------------------------------------------
    Purpose: Suppression d'une période de charge locative et des infos associées
             reprise adb/lib/supchloc.p
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat     as character no-undo.
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter piNumeroPeriode  as integer   no-undo.    
    define input parameter piNumeroExercice as integer   no-undo.

    define variable vdaReleve                 as date    no-undo.
    define variable viNoPseudoCtratPrestation as integer no-undo.

    define buffer perio   for perio.
    define buffer vbperio for perio.
    define buffer lprtb   for lprtb. 
    define buffer entip   for entip. 
    define buffer detip   for detip. 
    define buffer erlet   for erlet. 
    define buffer erldt   for erldt. 
    define buffer eprov   for eprov. 
    define buffer cttac   for cttac. 
    define buffer ctrat   for ctrat. 
    define buffer trfpm   for trfpm. 
    define buffer trfev   for trfev. 
    define buffer regul   for regul. 
    define buffer chglo   for chglo. 
    define buffer solps   for solps. 

message "trtSupPeriodeCharge " pcTypeMandat "// " piNumeroMandat "// " piNumeroPeriode "// " piNumeroExercice. 

blocTrans:
    do transaction:
        
        for first perio exclusive-lock
           where perio.tpctt = pcTypeMandat   
             and perio.nomdt = piNumeroMandat
             and perio.noper = piNumeroPeriode
             and perio.noexo = piNumeroExercice:
    
            // Suppression des rattachements éventuels avec IP et relevés d'eau
            for each lprtb exclusive-lock
               where lprtb.tpcon = pcTypeMandat 
                 and lprtb.nocon = piNumeroMandat
                 and lprtb.noexe = piNumeroExercice:
                case lprtb.tpcpt:
                    when {&TYPETACHE-ImputParticuliereGerance} 
                    then do:
                        vdaReleve = date(integer(truncate(lprtb.norlv modulo 10000 / 100, 0)),
                                         lprtb.norlv modulo 100,
                                         integer(truncate(lprtb.norlv / 10000, 0))).
                        for each entip exclusive-lock
                            where entip.nocon = piNumeroMandat
                              and entip.dtimp = vdaReleve:
                            for each detip exclusive-lock
                               where detip.nocon = entip.nocon
                                 and detip.dtimp = entip.dtimp:
                                delete detip no-error.
                                if error-status:error then do:
                                    mError:createError({&error}, error-status:get-message(1)).
                                    undo blocTrans, leave blocTrans.
                                end.    
                            end.
                            delete entip no-error.
                            if error-status:error then do:
                                mError:createError({&error}, error-status:get-message(1)).
                                undo blocTrans, leave blocTrans.
                            end.                            
                        end.
                    end.
                    otherwise for first erlet exclusive-lock
                        where erlet.noimm = 10000 + lprtb.nocon
                          and erlet.tpcpt = lprtb.tpcpt
                          and erlet.norlv = lprtb.norlv:
                        for each erldt exclusive-lock
                           where erldt.norli = erlet.norli:
                            delete erldt no-error.
                            if error-status:error then do:
                                mError:createError({&error}, error-status:get-message(1)).
                                undo blocTrans, leave blocTrans.
                            end.                            
                        end.
                        delete erlet no-error.
                        if error-status:error then do:
                            mError:createError({&error}, error-status:get-message(1)).
                            undo blocTrans, leave blocTrans.
                        end.                   
                    end.
                end case.
                delete lprtb no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                               
            end.
            
            // Suppression des provisions & conso de l'exo
            for each eprov exclusive-lock
               where eprov.tpctt = pcTypeMandat
                 and eprov.nomdt = piNumeroMandat
                 and eprov.noexo = piNumeroPeriode:
                delete eprov no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.    
            end.
            
            // Suppression des liens taches
            viNoPseudoCtratPrestation = piNumeroMandat * 100 + piNumeroPeriode.     //integer( string(piNumeroMandat,"99999") + STRING(piNumeroPeriode,"99") )  
            for each cttac exclusive-lock 
               where cttac.tpcon = {&TYPECONTRAT-prestations}
                 and cttac.nocon = viNoPseudoCtratPrestation:
                delete cttac no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                
            end.
            
            //Suppression du pseudo-contrat
            for first ctrat exclusive-lock
               where ctrat.tpcon = {&TYPECONTRAT-prestations} 
                 and ctrat.nocon = viNoPseudoCtratPrestation:
                delete ctrat no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                            
            end.
            
            //Suppression des traces de transfert
            for each trfpm exclusive-lock 
               where trfpm.tptrf = "PS" 
                 and trfpm.nomdt = piNumeroMandat
                 and trfpm.noexe = piNumeroPeriode:
                delete trfpm no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                            
            end.
            for each trfev exclusive-lock
                where trfev.tptrf = "PS" 
                  and trfev.nomdt = piNumeroMandat
                  and trfev.noexe = piNumeroPeriode:
                delete trfev no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                            
            end.
            
            // regularisation des provisions
            for each regul exclusive-lock
               where regul.nomdt = piNumeroMandat
                 and regul.noper = piNumeroPeriode:
                delete regul no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                            
            end.
            
            // détail charges locatives
            for each chglo exclusive-lock
               where chglo.tpmdt = pcTypeMandat
                 and chglo.nomdt = piNumeroMandat
                 and chglo.noexo = piNumeroPeriode:
                delete chglo no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                            
            end.      
            for each solps exclusive-lock
                where solps.tpctt = pcTypeMandat 
                  and solps.nomdt = piNumeroMandat
                  and solps.noexo = piNumeroPeriode:
                delete solps no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                            
            end.
            
            // Suppression des période de chauffe
            for each vbperio exclusive-lock
               where vbperio.TpCtt = pcTypeMandat  
                 and vbperio.Nomdt = piNumeroMandat
                 and vbperio.Noexo = piNumeroPeriode
                 and vbperio.Noper > 0:
                delete vbperio no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                            
            end.
            
            //Suppression de l'exercice
            delete perio no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.                
                
        end.
    
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

