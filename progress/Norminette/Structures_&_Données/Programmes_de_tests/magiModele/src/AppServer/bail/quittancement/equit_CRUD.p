/*------------------------------------------------------------------------
File        : equit_CRUD.p
Purpose     : 
Author(s)   : 
Created     : Fri Dec 22 10:49:11 CET 2017
Notes       : reprise de L_Equit_ext.p
  ----------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageComptabilisationEchus.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define variable ghttequit as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoloc as handle, output phNoqtt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'noqtt' then phNoqtt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEquit.
    run updateEquit.
    run createEquit.
end procedure.

procedure setEquit:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEquit.
    ghttEquit = phttEquit.
    run crudEquit.
    delete object phttEquit.
end procedure.
/**** npo ancien code en attente de suppression
procedure readEquit:
    /*------------------------------------------------------------------------------
    Purpose: Procedure Qui recupere un enregistrement de la table equit
    Notes  : service utilisé par ???
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire     as integer no-undo.
    define input parameter piNumeroQuittance     as integer no-undo.
    define input parameter piNumeroMoisQuittance as integer no-undo.
    define output parameter table for ttEquit.

    define buffer equit for equit.

    /* Si NoQttSel <> 0 : On Recherche sur le numero 
       Sinon  sur le mois de quittancement */
    if (piNumeroQuittance <> ? and piNumeroMoisQuittance <> 0) 
    then find first equit no-lock
        where equit.noloc = piNumeroLocataire
          and equit.noqtt = piNumeroQuittance no-error.
    else find first equit no-lock
             where equit.noloc = piNumeroLocataire
               and equit.msqtt = piNumeroQuittance no-error.
    if not available equit then return.

    create ttEquit.
    outils:copyValidField(buffer equit:handle, buffer ttEquit:handle).

end procedure.
****/
procedure readEquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table equit 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64    no-undo.
    define input parameter piNoqtt as integer  no-undo.
    define input parameter table-handle phttEquit.
    define variable vhttBuffer as handle no-undo.
    define buffer equit for equit.

    vhttBuffer = phttEquit:default-buffer-handle.
    for first equit no-lock
        where equit.noloc = piNoloc
          and equit.noqtt = piNoqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.
procedure getEquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table equit 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64    no-undo.
    define input parameter piNoqtt as integer  no-undo.
    define input parameter table-handle phttEquit.

    define variable vhttBuffer as handle  no-undo.
    define buffer equit for equit.

    vhttBuffer = phttEquit:default-buffer-handle.
    if piNoqtt = ?
    then for each equit no-lock
        where equit.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each equit no-lock
        where equit.noloc = piNoloc
          and equit.noqtt = piNoqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquit no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first equit exclusive-lock
                where rowid(equit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer equit:handle, 'noloc/noqtt: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer equit:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEquit:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create equit.
            if not outils:copyValidField(buffer equit:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first equit exclusive-lock
                where rowid(Equit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer equit:handle, 'noloc/noqtt: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete equit no-error.
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

procedure LstEncQtt:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui genere La liste des quittances d'un locataire
    Notes  : service. Reprise de LstEncQtt dans l_equit_ext.p
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroLocataire as integer   no-undo.
    define input  parameter piGlMflMdf        as integer   no-undo.
    define input  parameter piGlMoiMdf        as integer   no-undo.
    define input  parameter piGlMoiMEc        as integer   no-undo.
    define output parameter pcRetour          as character no-undo initial "0".
    define output parameter piNombreQuittance as integer   no-undo.
    define output parameter pcListeQuittance  as character no-undo.

    define variable vcLbLstQtt                as character no-undo.
    define variable viNbLstQtt                as integer   no-undo.
    define variable vlGesFourLoyer            as logical   no-undo.
    define variable vcCodeModele              as character no-undo.
    define variable viNumeroFourLoyerDebut    as integer   no-undo.
    define variable viNumeroFourLoyerFin      as integer   no-undo.
    define variable viNombreMoisGesfl         as integer   no-undo.
    define variable voFournisseurLoyer         as class parametrageFournisseurLoyer      no-undo.
    define variable voComptabilisationEchus    as class parametrageComptabilisationEchus no-undo.
    define variable vlBaiFlo   as logical   no-undo.
    define variable vlCptEch   as logical   no-undo.
    define variable vlValEch   as logical   no-undo.
    define variable viCpUseInc as integer   no-undo.

    define buffer equit for equit.
// todo  on récupère des valeurs pour en faire quoi ??? (vlCptEch, viCpUseInc, viNombreMoisGesfl, viNumeroFourLoyerDebut, viNumeroFourLoyerFin, vcCodeModele
    assign
        voFournisseurLoyer      = new parametrageFournisseurLoyer()             /* Recuperation du parametre GESFL */
        voComptabilisationEchus = new parametrageComptabilisationEchus()        /* Recuperation du parametre CPECH */
        vlGesFourLoyer          = voFournisseurLoyer:isGesFournisseurLoyer()
        vcCodeModele            = voFournisseurLoyer:getCodeModele()
        viNumeroFourLoyerDebut  = voFournisseurLoyer:getFournisseurLoyerDebut()
        viNumeroFourLoyerFin    = voFournisseurLoyer:getFournisseurLoyerFin()
        viNombreMoisGesfl       = voFournisseurLoyer:getNombreMoisQuittance()
        vlCptEch                = voComptabilisationEchus:isOuvert()
        vlValEch                = voComptabilisationEchus:isValidationEchuSepare()
        vlBaiFlo                = can-find(first ctrat no-lock 
                                           where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                             and ctrat.nocon = integer(truncate(piNumeroLocataire / 100000, 0))
                                             and (ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
                                               or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision})) 
        viCpUseInc              = etime(true)
    .
    delete object voFournisseurLoyer.
    delete object voComptabilisationEchus.
boucleEquit:
    for each equit no-lock
        where equit.noloc = piNumeroLocataire
        by equit.msqtt:
        if vlGesFourLoyer and vlBaiFlo then do:
            if equit.msqtt < piGlMflMdf then next boucleEquit.
        end.
        /* Validation séparée des échus */
        else if vlValEch then do:
            if ((equit.cdter = "00001" and equit.msqtt < piGlMoiMdf)
             or (equit.cdter = "00002" and equit.msqtt < piGlMoiMEc)) then next boucleEquit.
        end.
        else if equit.msqtt < piGlMoiMdf then next boucleEquit.

        assign 
            vcLbLstQtt = substitute("&1@&2#&3#E", vcLbLstQtt, equit.noqtt, equit.msqtt)
            viNbLstQtt = viNbLstQtt + 1
        .
    end.

    if viNbLstQtt > 0 
    then assign
        vcLbLstQtt        = substring(vcLbLstQtt, 2)
        pcRetour          = "3"
        piNombreQuittance = viNbLstQtt
        pcListeQuittance  = vcLbLstQtt
    .

end procedure.

procedure deleteEquitSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer equit for equit.

message "deleteEquitSurMandat " piNumeroMandat. 

blocTrans:
    do transaction:
        for each equit no-lock
           where equit.nomdt = piNumeroMandat:
            find current equit exclusive-lock.      
            delete equit no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteEquitSurLocataire:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire as int64 no-undo.
    
    define buffer equit for equit.

message "deleteEquitSurLocataire " piNumeroLocataire. 

blocTrans:
    do transaction:
        for each equit exclusive-lock
           where equit.noloc = piNumeroLocataire:
            delete equit no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
