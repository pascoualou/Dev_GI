/*------------------------------------------------------------------------
File        : tacheService.p
Purpose     : gestionnaire du mandat
Author(s)   : GGA  2017/08/17
Notes       : a partir de adb/tach/prmbxges.p
------------------------------------------------------------------------*/

{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/cttac.i}
{adblib/include/ctctt.i}
{tache/include/tacheService.i}

function libelleAdresse returns character private (piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    return substitute("&1 &2", outilFormatage:getNomTiers2({&TYPEROLE-gestionnaire}, piNumeroRole, false),
                               outilFormatage:formatageAdresse({&TYPEROLE-gestionnaire}, piNumeroRole)).      
   
end function.

procedure getService:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheService.
    define output parameter table for ttListeService.

    define buffer cttac for cttac.
    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.

    empty temp-table ttTacheService.
    for first cttac no-lock
        where cttac.tpcon = pcTypeMandat
          and cttac.nocon = piNumeroMandat
          and cttac.tptac = {&TYPETACHE-services}:
        create ttTacheService.
        assign
            ttTacheService.CRUD           = 'R'
            ttTacheService.cTypeContrat   = cttac.tpcon
            ttTacheService.iNumeroContrat = cttac.nocon
            ttTacheService.cTypeTache     = {&TYPETACHE-services}
        .
        run listeService.
        find first ctctt no-lock                   //l'enregistrement cttac peut exister sans l enregistrement ctctt si service selectionne est 0 (aucun)
             where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
               and ctctt.tpct2 = cttac.tpcon
               and ctctt.noct2 = cttac.nocon no-error.
        if available ctctt
        then assign
                 ttTacheService.dtTimestamp = datetime(ctctt.dtmsy, ctctt.hemsy)
                 ttTacheService.rRowid      = rowid(ctctt)
                 ttTacheService.iService    = ctctt.noct1
        .
        else ttTacheService.iService = 0.
        run ctrlMandatService(buffer ttTacheService).
    end.

end procedure.

procedure setService:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheService.

    for first ttTacheService
    where lookup(ttTacheService.CRUD, "C,U") > 0:
        if not can-find (first ctrat no-lock
                         where ctrat.tpcon = ttTacheService.cTypeContrat
                           and ctrat.nocon = ttTacheService.iNumeroContrat)
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        find first cttac no-lock
             where cttac.tpcon = ttTacheService.cTypeContrat
               and cttac.nocon = ttTacheService.iNumeroContrat
               and cttac.tptac = {&TYPETACHE-services} no-error.
        if not available cttac
        and ttTacheService.CRUD = "U"
        then do:
            mError:createError({&error}, 1000413).    //modification d'une tache inexistante
            return.
        end.
        if available cttac
        and ttTacheService.CRUD = "C" 
        then do:
            mError:createError({&error}, 1000412).    //création d'une tache existante
            return.
        end.       
        run majtbltch (buffer ttTacheService).        
    end.

end procedure.

procedure initService:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define output parameter table for ttTacheService.
    define output parameter table for ttListeService.

    empty temp-table ttTacheService.
    empty temp-table ttListeService.

    if not can-find (first ctrat no-lock
                     where ctrat.tpcon = pcTypeMandat
                       and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find (first cttac no-lock
                 where cttac.tpcon = pcTypeMandat
                   and cttac.nocon = piNumeroMandat
                   and cttac.tptac = {&TYPETACHE-services})
    then do:
        mError:createError({&error}, 1000410).             //demande d'initialisation d'une tache existante
        return.
    end.
    create ttTacheService.
    assign
        ttTacheService.CRUD           = 'C'
        ttTacheService.cTypeContrat   = pcTypeMandat
        ttTacheService.iNumeroContrat = piNumeroMandat
        ttTacheService.cTypeTache     = {&TYPETACHE-services}
    .
    run listeService.
    for first ttListeService 
    by ttListeService.iNocon:
        ttTacheService.iService = ttListeService.iNocon.
    end.
    run ctrlMandatService(buffer ttTacheService).
             
end procedure.

procedure ctrlMandatService private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheService for ttTacheService.
    
    define variable vlServiceTrouve as logical no-undo. 
    
    define buffer ctrat for ctrat.
  
    for first ttListeService
        where ttListeService.iNocon = ttTacheService.iService:
        assign
            ttTacheService.cLibelleService = ttListeService.cNoree
            ttTacheService.cLibelleAdresse = ttListeService.cLibelleAdresse 
            vlServiceTrouve                = yes
        .
    end.
    if vlServiceTrouve = no                 //Sy 18/12/2009 pas de modif possible si le mandat appartient à un autre service
    then do:
        empty temp-table ttListeService.
        for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-serviceGestion}
              and ctrat.nocon = ttTacheService.iService:
            create ttListeService.
            assign
                ttListeService.CRUD            = "R"
                ttListeService.iNocon          = ctrat.nocon
                ttListeService.iNorol          = ctrat.norol
                ttListeService.cNoree          = ctrat.noree
                ttListeService.cLibelleAdresse = libelleAdresse(ctrat.norol)
                ttTacheService.cLibelleService = ttListeService.cNoree
                ttTacheService.cLibelleAdresse = ttListeService.cLibelleAdresse 
            .
        end.
    end.
          
end procedure.

procedure listeService private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    empty temp-table ttListeService.
    case mToken:iGestionnaire:
        when 0 then do:                                                  // Administrateur
            create ttListeService.
            assign
                ttListeService.CRUD            = "R"
                ttListeService.iNocon          = 0                                 // Service de Gestion : Aucun
                ttListeService.iNorol          = 0
                ttListeService.cNoree          = outilTraduction:getLibelle(102281)
                ttListeService.cLibelleAdresse = libelleAdresse(0)
            .
            for each ctrat no-lock                                       // on liste l'ensemble des services de gestion
               where ctrat.tpcon = {&TYPECONTRAT-serviceGestion}:
                create ttListeService.
                assign
                    ttListeService.CRUD            = "R"
                    ttListeService.iNocon          = ctrat.nocon
                    ttListeService.iNorol          = ctrat.norol
                    ttListeService.cNoree          = ctrat.noree
                    ttListeService.cLibelleAdresse = libelleAdresse(ctrat.norol)
                .
            end.
        end.
        when 1 then for each ctrat no-lock                                        // Gestionnaire, on liste l'ensemble des services de gestion
            where ctrat.tpcon = {&TYPECONTRAT-serviceGestion}:
            create ttListeService.
            assign
                ttListeService.CRUD            = "R"
                ttListeService.iNocon          = ctrat.nocon
                ttListeService.iNorol          = ctrat.norol
                ttListeService.cNoree          = ctrat.noree
                ttListeService.cLibelleAdresse = libelleAdresse(ctrat.norol)
            .
        end.
        when 2 or when 3 then for each intnt no-lock                              // Collaborateur
            where intnt.tpcon = {&TYPECONTRAT-serviceGestion}                    // On liste uniquement ses services de gestion */
              and intnt.tpidt = {&TYPEROLE-gestionnaire}
              and intnt.noidt = mToken:iCollaborateur
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon:
            create ttListeService.
            assign
                ttListeService.CRUD            = "R"
                ttListeService.iNocon          = ctrat.nocon
                ttListeService.iNorol          = ctrat.norol
                ttListeService.cNoree          = ctrat.noree
                ttListeService.cLibelleAdresse = libelleAdresse(ctrat.norol)
            .
        end.
        when 4 then do:                                                     // Sans gestionnaire
            create ttListeService.
            assign
                ttListeService.CRUD            = "R"
                ttListeService.iNocon          = 0                                 // Service de Gestion : Aucun
                ttListeService.iNorol          = 0
                ttListeService.cNoree          = outilTraduction:getLibelle(102281)
                ttListeService.cLibelleAdresse = libelleAdresse(ctrat.norol)
            .
        end.
    end case.

end procedure.

procedure majtbltch private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheService for ttTacheService.
    
    define variable vhCttac        as handle  no-undo.
    define variable vhCtctt        as handle  no-undo.
    define variable vhAlimaj       as handle  no-undo.
    define variable vlMajTransfert as logical no-undo.

    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.

    if ttTacheService.CRUD = "C"
    then do:
        empty temp-table ttCttac.
        create ttCttac.
        assign
            ttCttac.tpcon = ttTacheService.cTypeContrat
            ttCttac.nocon = ttTacheService.iNumeroContrat
            ttCttac.tptac = {&TYPETACHE-services}
            ttCttac.CRUD  = "C"
        .
        run adblib/cttac_CRUD.p persistent set vhCttac.
        run getTokenInstance in vhCttac(mToken:JSessionId).
        run setCttac in vhCttac (table ttCttac by-reference).
        run destroy in vhCttac.
        if mError:erreur() = yes then return.
    end.    
    find first ctctt no-lock
         where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
           and ctctt.tpct2 = ttTacheService.cTypeContrat
           and ctctt.noct2 = ttTacheService.iNumeroContrat no-error.
    if available ctctt 
    then do:
        if ctctt.noct1 = ttTacheService.iService then return.

        empty temp-table ttCtctt.
        create ttCtctt.
        assign
            ttCtctt.tpct1       = {&TYPECONTRAT-serviceGestion}
            ttCtctt.noct1       = ctctt.noct1
            ttCtctt.tpct2       = ttTacheService.cTypeContrat
            ttCtctt.noct2       = ttTacheService.iNumeroContrat
            ttCtctt.CRUD        = "D"
            ttCtctt.dtTimestamp = ttTacheService.dtTimestamp
            ttCtctt.rRowid      = ttTacheService.rRowid  
            vlMajTransfert      = yes
        .
        run adblib/ctctt_CRUD.p persistent set vhCtctt.
        run getTokenInstance in vhCtctt(mToken:JSessionId).
        run setCtctt in vhCtctt(table ttCtctt by-reference).
        run destroy in vhCtctt.
        if mError:erreur() then return.
    end.
    if ttTacheService.iService <> 0
    then do: 
        empty temp-table ttCtctt.
        create ttCtctt.
        assign
            ttCtctt.tpct1  = {&TYPECONTRAT-serviceGestion}
            ttCtctt.noct1  = ttTacheService.iService
            ttCtctt.tpct2  = ttTacheService.cTypeContrat
            ttCtctt.noct2  = ttTacheService.iNumeroContrat
            ttCtctt.CRUD   = "C"
            vlMajTransfert = yes
        .
        run adblib/ctctt_CRUD.p persistent set vhCtctt.
        run getTokenInstance in vhCtctt(mToken:JSessionId).
        run setCtctt in vhCtctt(table ttCtctt by-reference).
        run destroy in vhCtctt.
        if mError:erreur() then return.
    end.

    if vlMajTransfert = yes  
    then for first ctrat no-lock
        where ctrat.tpcon = ttTacheService.cTypeContrat
          and ctrat.nocon = ttTacheService.iNumeroContrat:
        run application/transfert/GI_alimaj.p persistent set vhAlimaj.
        run getTokenInstance in vhAlimaj (mToken:JSessionId).
        run majTrace in vhAlimaj (integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).    
        run destroy in vhAlimaj.  
    end.
    
end procedure.

