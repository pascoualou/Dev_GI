/*------------------------------------------------------------------------
File        : tacheTvaEdi.p
Purpose     : tache tva EDI
Author(s)   : GGA  2017/08/17
Notes       : a partir de adb/tach/prmmttv3.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}

using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tache.i}
{adblib/include/cttac.i}
{tache/include/tacheTvaEdi.i}
{application/include/combo.i}
{application/include/error.i}

define variable ghTache     as handle no-undo.
define variable ghCttac     as handle no-undo.
define variable giNoMandant as integer no-undo.
  
function NoMandant returns integer private(pcTypeMandat as character, piNumeroMandat as integer):
    /*------------------------------------------------------------------------
    Purpose: retourne numero du mandant du mandat
    Notes  :
    ------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.tpidt = {&TYPEROLE-mandant}
          and intnt.nocon = piNumeroMandat:
        return intnt.noidt.
    end.
    return ?.

end function.
      
procedure getTvaEdi:
    /*------------------------------------------------------------------------------
    Purpose: lecture infos tvaedi du mandat
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define output parameter table for ttTacheTvaEdi.

    define buffer tache for tache.

    empty temp-table ttTacheTvaEdi.
    for first tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-TVAEDI}
          and tache.notac = 1:
        create ttTacheTvaEdi.
        assign
            ttTacheTvaEdi.dtTimestamp           = datetime(tache.dtmsy, tache.hemsy)
            ttTacheTvaEdi.CRUD                  = 'R'
            ttTacheTvaEdi.rRowid                = rowid(tache)
            ttTacheTvaEdi.iNumeroTache          = tache.noita
            ttTacheTvaEdi.cTypeContrat          = tache.tpcon
            ttTacheTvaEdi.iNumeroContrat        = tache.nocon
            ttTacheTvaEdi.cTypeTache            = tache.tptac
            ttTacheTvaEdi.iChronoTache          = tache.notac
            ttTacheTvaEdi.daActivation          = tache.dtdeb
            ttTacheTvaEdi.daFin                 = tache.dtfin
            ttTacheTvaEdi.cRefOblFisc           = tache.dcreg
            ttTacheTvaEdi.cNoFrp                = tache.utreg
            ttTacheTvaEdi.daAdhesion            = tache.dtreg
            ttTacheTvaEdi.cMoyenPaiement        = tache.cdreg
            ttTacheTvaEdi.cLibelleMoyenPaiement = outilTraduction:getLibelleProgZone2("R_MDG", {&TYPETACHE-TVAEDI}, tache.cdreg)
            ttTacheTvaEdi.cIbanPremierCompte    = if num-entries(tache.lbdiv , "@") >= 1 then entry(1, tache.lbdiv , "@") else ""
            ttTacheTvaEdi.cBicPremierCompte     = if num-entries(tache.lbdiv , "@") >= 2 then entry(2, tache.lbdiv , "@") else ""
            ttTacheTvaEdi.cTitPremierCompte     = if num-entries(tache.lbdiv , "@") >= 3 then entry(3, tache.lbdiv , "@") else ""
            ttTacheTvaEdi.cIbanDeuxiemeCompte   = if num-entries(tache.lbdiv2, "@") >= 1 then entry(1, tache.lbdiv2, "@") else ""
            ttTacheTvaEdi.cBicDeuxiemeCompte    = if num-entries(tache.lbdiv2, "@") >= 2 then entry(2, tache.lbdiv2, "@") else ""
            ttTacheTvaEdi.cTitDeuxiemeCompte    = if num-entries(tache.lbdiv2, "@") >= 3 then entry(3, tache.lbdiv2, "@") else ""
            ttTacheTvaEdi.cIbanTroisiemeCompte  = if num-entries(tache.lbdiv3, "@") >= 1 then entry(1, tache.lbdiv3, "@") else ""
            ttTacheTvaEdi.cBicTroisiemeCompte   = if num-entries(tache.lbdiv3, "@") >= 2 then entry(2, tache.lbdiv3, "@") else ""
            ttTacheTvaEdi.cTitTroisiemeCompte   = if num-entries(tache.lbdiv3, "@") >= 3 then entry(3, tache.lbdiv3, "@") else ""
        .
    end.

end procedure.

procedure setTvaEdi:
    /*------------------------------------------------------------------------------
    Purpose: maj infos tvaedi du mandat
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheTvaEdi.
    define input parameter table for ttError.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    for first ttTacheTvaEdi
    where lookup(ttTacheTvaEdi.CRUD, "C,U,D") > 0:
        find first ctrat no-lock                                             //recherche mandat
             where ctrat.tpcon = ttTacheTvaEdi.cTypeContrat
               and ctrat.nocon = ttTacheTvaEdi.iNumeroContrat no-error.
        if not available ctrat
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        find first tache no-lock
        where tache.tpcon = ttTacheTvaEdi.cTypeContrat
          and tache.nocon = ttTacheTvaEdi.iNumeroContrat
          and tache.tptac = {&TYPETACHE-TVAEDI} 
          and tache.notac = 1 no-error.
        if not available tache
        and lookup(ttTacheTvaEdi.CRUD, "U,D") > 0
        then do:
            mError:createError({&error}, 1000413).            //modification d'une tache inexistante
            return.
        end.
        if available tache
        and ttTacheTvaEdi.CRUD = "C" 
        then do:
            mError:createError({&error}, 1000412).             //création d'une tache existante
            return.
        end.       
        run verZonSai (buffer ttTacheTvaEdi).
        if mError:erreur() = yes then return.
        run majtbltch (buffer ttTacheTvaEdi).
    end.

end procedure.

procedure initTvaEdi:
    /*------------------------------------------------------------------------------
    Purpose: appel procedure creation tache pour retour des valeurs par defaut (pas encore de maj)
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheTvaEdi.

    define variable viNoMandant as integer no-undo.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer tache for tache.

    empty temp-table ttTacheTvaEdi.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeMandat
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-TVAEDI}
                  and tache.notac = 1)
    then do: 
        mError:createError({&error}, 1000410).                 //demande d'initialisation d'une tache existante
        return.
    end.
    if not can-find (first tache no-lock
                     where tache.tpcon = pcTypeMandat
                       and tache.nocon = piNumeroMandat
                       and tache.tptac = {&TYPETACHE-TVA})
    then do:
        mError:createError({&error}, 1000464).                 //Tache TVA obligatoire pour création tache TVAEDI
        return.
    end.
    if not can-find(first iparm no-lock 
                    where iparm.soc-cd  = integer(mtoken:cRefGerance)
                      and iparm.etab-cd = 0
                      and iparm.tppar   = "TVAEDI"
                      and iparm.cdpar   = "ACTIV"
                      and iparm.zone2   = "O") 
    then do:
        mError:createError({&error}, 1000465).                //demande d'initialisation mais module TVA-EDI non ouvert
        return.
    end.
    create ttTacheTvaEdi.
    assign
        ttTacheTvaEdi.CRUD           = 'C'
        ttTacheTvaEdi.cTypeContrat   = pcTypeMandat
        ttTacheTvaEdi.iNumeroContrat = piNumeroMandat
        ttTacheTvaEdi.cTypeTache     = {&TYPETACHE-TVAEDI}
        ttTacheTvaEdi.cMoyenPaiement = "00000"
    .
    // on recherche si il existe deja une tache TVAEDI sur un des mandats du mandant
    viNoMandant = NoMandant(pcTypeMandat, piNumeroMandat). 
    
initDepuisAutreContrat:     
    for each intnt no-lock
       where intnt.tpcon = pcTypeMandat
         and intnt.tpidt = {&TYPEROLE-mandant}
         and intnt.noidt = viNoMandant
    , first tache no-lock
      where tache.tpcon = intnt.tpcon
        and tache.nocon = intnt.nocon
        and tache.tptac = {&TYPETACHE-TVAEDI}:
        assign
            ttTacheTvaEdi.daActivation          = tache.dtdeb
            ttTacheTvaEdi.daFin                 = tache.dtfin
            ttTacheTvaEdi.cRefOblFisc           = tache.dcreg
            ttTacheTvaEdi.cNoFrp                = tache.utreg
            ttTacheTvaEdi.daAdhesion            = tache.dtreg
            ttTacheTvaEdi.cMoyenPaiement        = tache.cdreg
            ttTacheTvaEdi.cLibelleMoyenPaiement = outilTraduction:getLibelleProgZone2("R_MDG", {&TYPETACHE-TVAEDI}, tache.cdreg)
            ttTacheTvaEdi.cIbanPremierCompte    = if num-entries(tache.lbdiv , "@") >= 1 then entry(1, tache.lbdiv , "@") else ""
            ttTacheTvaEdi.cBicPremierCompte     = if num-entries(tache.lbdiv , "@") >= 2 then entry(2, tache.lbdiv , "@") else ""
            ttTacheTvaEdi.cTitPremierCompte     = if num-entries(tache.lbdiv , "@") >= 3 then entry(3, tache.lbdiv , "@") else ""            
            ttTacheTvaEdi.cIbanDeuxiemeCompte   = if num-entries(tache.lbdiv2, "@") >= 1 then entry(1, tache.lbdiv2, "@") else ""
            ttTacheTvaEdi.cBicDeuxiemeCompte    = if num-entries(tache.lbdiv2, "@") >= 2 then entry(2, tache.lbdiv2, "@") else ""
            ttTacheTvaEdi.cTitDeuxiemeCompte    = if num-entries(tache.lbdiv2, "@") >= 3 then entry(3, tache.lbdiv2, "@") else ""
            ttTacheTvaEdi.cIbanTroisiemeCompte  = if num-entries(tache.lbdiv3, "@") >= 1 then entry(1, tache.lbdiv3, "@") else ""
            ttTacheTvaEdi.cBicTroisiemeCompte   = if num-entries(tache.lbdiv3, "@") >= 2 then entry(2, tache.lbdiv3, "@") else ""
            ttTacheTvaEdi.cTitTroisiemeCompte   = if num-entries(tache.lbdiv3, "@") >= 3 then entry(3, tache.lbdiv3, "@") else ""
        .
        leave initDepuisAutreContrat.
    end.
    
end procedure.

procedure majtbltch private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheTvaEdi for ttTacheTvaEdi.

    define variable viRetQuestion          as integer   no-undo.
    define variable vlMajTacheAutreContrat as logical   no-undo.

    define buffer tache   for tache.
    define buffer vbtache for tache.
    define buffer cttac   for cttac.
    define buffer intnt   for intnt.

bloc-maj: 
    do:
        giNoMandant = NoMandant(ttTacheTvaEdi.cTypeContrat, ttTacheTvaEdi.iNumeroContrat). 
        if ttTacheTvaEdi.CRUD = "D"
        then do:
rechTacheAutreContrat: 
            for each intnt no-lock
                where intnt.tpcon = ttTacheTvaEdi.cTypeContrat
                  and intnt.tpidt = {&TYPEROLE-mandant}
                  and intnt.noidt = giNoMandant
                  and intnt.nocon <> ttTacheTvaEdi.iNumeroContrat
              , first vbtache no-lock
                where vbtache.tpcon = intnt.tpcon
                  and vbtache.nocon = intnt.nocon
                  and vbtache.tptac = {&TYPETACHE-TVA}                   // tache TVA
              , first tache no-lock
                where tache.tpcon = intnt.tpcon
                  and tache.nocon = vbtache.nocon
                  and tache.tptac = {&TYPETACHE-TVAEDI}:
                //Voulez-vous supprimer la tâche TVA-EDI sur tous les mandats du mandant dont la tâche 'TVA' est active ?      
                viRetQuestion = outils:questionnaire(1000468, table ttError by-reference).
                if viRetQuestion < 2 then return.
                leave rechTacheAutreContrat.
            end.
        end.
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.noita       = ttTacheTvaEdi.iNumeroTache
            ttTache.tpcon       = ttTacheTvaEdi.cTypeContrat
            ttTache.nocon       = ttTacheTvaEdi.iNumeroContrat
            ttTache.tptac       = ttTacheTvaEdi.cTypeTache
            ttTache.notac       = ttTacheTvaEdi.iChronoTache
            ttTache.dtdeb       = ttTacheTvaEdi.daActivation
            ttTache.dtfin       = ttTacheTvaEdi.daFin
            ttTache.dcreg       = ttTacheTvaEdi.cRefOblFisc
            ttTache.utreg       = ttTacheTvaEdi.cNoFrp
            ttTache.dtreg       = ttTacheTvaEdi.daAdhesion
            ttTache.cdreg       = ttTacheTvaEdi.cMoyenPaiement
            ttTache.lbdiv       = "@@@"
            ttTache.lbdiv2      = "@@@"
            ttTache.lbdiv3      = "@@@"
            ttTache.CRUD        = ttTacheTvaEdi.CRUD
            ttTache.dtTimestamp = ttTacheTvaEdi.dtTimestamp
            ttTache.rRowid      = ttTacheTvaEdi.rRowid
        .
        if ttTacheTvaEdi.cIbanPremierCompte > ""
        then assign
            entry(1, ttTache.lbdiv, "@") = ttTacheTvaEdi.cIbanPremierCompte
            entry(2, ttTache.lbdiv, "@") = ttTacheTvaEdi.cBicPremierCompte
            entry(3, ttTache.lbdiv, "@") = ttTacheTvaEdi.cTitPremierCompte
        .
        if ttTacheTvaEdi.cIbanDeuxiemeCompte > ""
        then assign
            entry(1, ttTache.lbdiv2, "@") = ttTacheTvaEdi.cIbanDeuxiemeCompte
            entry(2, ttTache.lbdiv2, "@") = ttTacheTvaEdi.cBicDeuxiemeCompte
            entry(3, ttTache.lbdiv2, "@") = ttTacheTvaEdi.cTitDeuxiemeCompte
        .
        if ttTacheTvaEdi.cIbanTroisiemeCompte > ""
        then assign
            entry(1, ttTache.lbdiv3, "@") = ttTacheTvaEdi.cIbanTroisiemeCompte
            entry(2, ttTache.lbdiv3, "@") = ttTacheTvaEdi.cBicTroisiemeCompte
            entry(3, ttTache.lbdiv3, "@") = ttTacheTvaEdi.cTitTroisiemeCompte
        .
        run tache/tache.p persistent set ghTache.
        run getTokenInstance in ghTache(mToken:JSessionId).
        run setTache in ghTache(table ttTache by-reference).
        find first ttTache.                   //on se repositionne sur l'enregistrement de ttTache car not available apres l'appel de setTache  
        if mError:erreur() then leave bloc-maj.
        empty temp-table ttCttac. 
        find first cttac no-lock
             where cttac.tpcon = ttTacheTvaEdi.cTypeContrat
               and cttac.nocon = ttTacheTvaEdi.iNumeroContrat
               and cttac.tptac = {&TYPETACHE-TVAEDI} no-error.
        if not available cttac and lookup(ttTacheTvaEdi.CRUD, "U,C") > 0
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = ttTacheTvaEdi.cTypeContrat
                ttCttac.nocon = ttTacheTvaEdi.iNumeroContrat
                ttCttac.tptac = {&TYPETACHE-TVAEDI}
                ttCttac.CRUD  = "C"
            .
            run adblib/cttac_CRUD.p persistent set ghCttac.
            run getTokenInstance in ghCttac(mToken:JSessionId).        
            run setCttac in ghCttac(table ttCttac by-reference).
            if mError:erreur() then leave bloc-maj.
        end.
        if available cttac and ttTacheTvaEdi.CRUD = "D"
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon       = cttac.tpcon
                ttCttac.nocon       = cttac.nocon
                ttCttac.tptac       = cttac.tptac
                ttCttac.CRUD        = "D"
                ttCttac.rRowid      = rowid(cttac)
                ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            .
            run adblib/cttac_CRUD.p persistent set ghCttac.
            run getTokenInstance in ghCttac(mToken:JSessionId).                
            run setCttac in ghCttac(table ttCttac by-reference).
            if mError:erreur() then leave bloc-maj.
        end.
        if lookup(ttTacheTvaEdi.CRUD,"C,U") > 0
        then run majTacheSurAutreContrat (buffer ttTache, input-output vlMajTacheAutreContrat).
        if mError:erreur() then leave bloc-maj.

        if ttTacheTvaEdi.CRUD = "C"
        then run creSupmajTacheSurAutreContrat (buffer ttTache, "C", input-output vlMajTacheAutreContrat).
        if mError:erreur() then leave bloc-maj.

        if ttTacheTvaEdi.CRUD = "D" and viRetQuestion = 3
        then run creSupmajTacheSurAutreContrat (buffer ttTache, "D", input-output vlMajTacheAutreContrat).
        if mError:erreur() then leave bloc-maj.

        if vlMajTacheAutreContrat = yes and lookup(ttTacheTvaEdi.CRUD,"C,U") > 0
        then do:  
            mError:createError({&information}, 1000466).         //Ces informations sont aussi dupliquées pour toutes les tâches TVA-EDI des autres mandats du mandant
            if ttTache.dtfin <> ?
            then mError:createError({&information}, 1000467).    //Ainsi sont aussi déactivées toutes les tâches TVA-EDI des autres mandats du mandant
        end.
    end.

    if valid-handle(ghTache) then run destroy in ghTache.
    if valid-handle(ghCttac) then run destroy in ghCttac.

end procedure.

procedure verZonSai private:  
    /*------------------------------------------------------------------------------
    Purpose: controle
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheTvaEdi for ttTacheTvaEdi.
    
    define variable vlRetour as logical no-undo.
    define variable vhProc   as handle  no-undo.
    define variable voSyspg  as class syspg no-undo.

    if not can-find (first tache no-lock                                // Existence de la tâche TVA du mandat ("04040")
                     where tache.tptac = {&TYPETACHE-TVA}
                       and tache.tpcon = ttTacheTvaEdi.cTypeContrat
                       and tache.nocon = ttTacheTvaEdi.iNumeroContrat)
    then do:
        mError:createError({&error}, 1000459).                      //Tache TVA obligatoire
        return.
    end.
    if not can-find(first iparm no-lock 
                    where iparm.soc-cd  = integer(mtoken:cRefGerance)
                      and iparm.etab-cd = 0
                      and iparm.tppar   = "TVAEDI"
                      and iparm.cdpar   = "ACTIV"
                      and iparm.zone2   = "O") 
    then do:  
        mError:createError({&error}, 1000460).                  //Module TVA-EDI non ouvert
        return.
    end.
    if ttTacheTvaEdi.daActivation = ?
    then do:
        mError:createError({&error}, 100299).
        return.
    end.
    if ttTacheTvaEdi.daFin <> ?
    and ttTacheTvaEdi.daFin <= ttTacheTvaEdi.daActivation
    then do:
        mError:createError({&error}, 1000461).                 //La date de fin doit être supérieure à la date d'application
        return.
    end.
    if ttTacheTvaEdi.cNoFrp = ? or ttTacheTvaEdi.cNoFrp = ""
    then do:
        mError:createError({&error}, 1000462).                //Le numéro 'FRP' est à renseigner obligatoirement
        return.
    end.
    voSyspg = new syspg().
    if voSyspg:isParamExist("R_MDG", {&TYPETACHE-TVAEDI}, ttTacheTvaEdi.cMoyenPaiement) = no     
    then do:
        mError:createError({&error}, 1000469).                      //type moyen paiement invalide
        delete object voSyspg.
        return.
    end.
    delete object voSyspg.
    if ttTacheTvaEdi.cMoyenPaiement = "22016"     // telereglement
    and (ttTacheTvaEdi.cIbanPremierCompte = ? or ttTacheTvaEdi.cIbanPremierCompte = "")
    then do:
        mError:createError({&error}, 1000463).    //Le compte bancaire est obligatoire quand on choisit le télérèglement
        return.
    end.
    if ttTacheTvaEdi.cIbanPremierCompte > ""
    or ttTacheTvaEdi.cIbanDeuxiemeCompte > ""
    or ttTacheTvaEdi.cIbanTroisiemeCompte > ""
    then do:
        run outils/controleBancaire.p persistent set vhproc.
        run getTokenInstance in vhproc(mToken:JSessionId).
        vlRetour =      (ttTacheTvaEdi.cIbanPremierCompte = ""   or dynamic-function('controleIbanBic' in vhproc, ttTacheTvaEdi.cBicPremierCompte  , ttTacheTvaEdi.cIbanPremierCompte  ))
                    and (ttTacheTvaEdi.cIbanDeuxiemeCompte = ""  or dynamic-function('controleIbanBic' in vhproc, ttTacheTvaEdi.cBicDeuxiemeCompte , ttTacheTvaEdi.cIbanDeuxiemeCompte ))
                    and (ttTacheTvaEdi.cIbanTroisiemeCompte = "" or dynamic-function('controleIbanBic' in vhproc, ttTacheTvaEdi.cBicTroisiemeCompte, ttTacheTvaEdi.cIbanTroisiemeCompte)).
        run destroy in vhproc.
        if vlRetour then return.
    end.

end procedure.

procedure creSupmajTacheSurAutreContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTache for ttTache.
    define input        parameter pcTypmaj    as character no-undo.
    define input-output parameter plmajtache  as logical   no-undo.

    define variable viNoMandatInit as int64 no-undo. 

    define buffer intnt   for intnt.
    define buffer tache   for tache.
    define buffer vbtache for tache.
    define buffer cttac   for cttac.

    viNoMandatInit = ttTache.nocon.  

boucle:
    for each intnt no-lock
        where intnt.tpcon = ttTache.tpcon
          and intnt.tpidt = {&TYPEROLE-mandant}
          and intnt.noidt = giNoMandant
          and intnt.nocon <> viNoMandatInit
      , first vbtache no-lock
        where vbtache.tpcon = intnt.tpcon
          and vbtache.nocon = intnt.nocon
          and vbtache.tptac = {&TYPETACHE-TVA}:                              // tache TVA
        find first tache no-lock
             where tache.tpcon = intnt.tpcon
               and tache.nocon = vbtache.nocon
               and tache.tptac = {&TYPETACHE-TVAEDI} no-error.
        if pcTypmaj = "C"
        then do:
            if available tache then next boucle.
            assign
                ttTache.CRUD  = "C"
                ttTache.noita = 0
                ttTache.notac = 0
                ttTache.nocon = vbtache.nocon
            .
        end.
        if pcTypmaj = "D"
        then do:
            if not available tache then next boucle.
            assign
                ttTache.CRUD        = "D"
                ttTache.noita       = tache.noita
                ttTache.notac       = tache.notac
                ttTache.nocon       = tache.nocon
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            .
        end.
        run setTache in ghTache(table ttTache by-reference).
        find first ttTache.                   //on se repositionne sur l'enregistrement de ttTache car not available apres l'appel de setTache                  
        if mError:erreur() then return.

        plmajtache = yes.
        empty temp-table ttCttac. 
        find first cttac no-lock
             where cttac.tpcon = ttTache.tpcon
               and cttac.nocon = ttTache.nocon
               and cttac.tptac = {&TYPETACHE-TVAEDI} no-error.
        if pcTypmaj = "C" and not available cttac
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = ttTache.tpcon
                ttCttac.nocon = ttTache.nocon
                ttCttac.tptac = {&TYPETACHE-TVAEDI}
                ttCttac.CRUD  = "C"
            .
            if not valid-handle(ghCttac)
            then do:
                run adblib/cttac_CRUD.p persistent set ghCttac.
                run getTokenInstance in ghCttac(mToken:JSessionId).        
            end.
            run setCttac in ghCttac(table ttCttac by-reference).
            if mError:erreur() then return.
        end.
        if pcTypmaj = "D" and available cttac
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon       = cttac.tpcon
                ttCttac.nocon       = cttac.nocon
                ttCttac.tptac       = cttac.tptac
                ttCttac.CRUD        = "D"
                ttCttac.rRowid      = rowid(cttac)
                ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            .
            if not valid-handle(ghCttac)
            then do:
                run adblib/cttac_CRUD.p persistent set ghCttac.
                run getTokenInstance in ghCttac(mToken:JSessionId).        
            end.
            run setCttac in ghCttac(table ttCttac by-reference).
            if mError:erreur() then return.
        end.
    end.

end procedure.

procedure majTacheSurAutreContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTache for ttTache.
    define input-output parameter plmajtache as logical no-undo.

    define variable viNoMandatInit as int64 no-undo. 

    define buffer intnt for intnt.
    define buffer tache for tache.

    viNoMandatInit = ttTache.nocon.  
    for each intnt no-lock
        where intnt.tpcon = ttTache.tpcon
          and intnt.tpidt = {&TYPEROLE-mandant}
          and intnt.noidt = giNoMandant
          and intnt.nocon <> ttTache.nocon
      , first tache no-lock
        where tache.tpcon = intnt.tpcon
          and tache.nocon = intnt.nocon
          and tache.tptac = {&TYPETACHE-TVAEDI}:
        assign
            ttTache.noita       = tache.noita
            ttTache.notac       = tache.notac
            ttTache.nocon       = tache.nocon
            ttTache.CRUD        = "U"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.rRowid      = rowid(tache)
        .
        run setTache in ghTache(table ttTache by-reference).
        find first ttTache.                   //on se repositionne sur l'enregistrement de ttTache car not available apres l'appel de setTache          
        if mError:erreur() then return.
        plmajtache = yes.
    end.

end procedure.

procedure initComboTvaEdi:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo. 

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg as class syspg no-undo.

    empty temp-table ttCombo.
    voSyspg = new syspg().
    voSyspg:creationttCombo("MOYENPAIEMENT", "00000", "-", output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_MDG", "MOYENPAIEMENT", "L", {&TYPETACHE-TVAEDI}, output table ttCombo by-reference).
    delete object voSyspg.

end procedure.
