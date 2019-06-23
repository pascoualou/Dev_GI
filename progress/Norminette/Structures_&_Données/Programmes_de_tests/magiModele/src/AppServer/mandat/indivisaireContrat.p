/*------------------------------------------------------------------------
File        : indivisaireContrat.p
Purpose     : indivisaire d'un contrat
Author(s)   : GGA  -  2017/09/05
Notes       : reprise du pgm adb/cont/gesind00.p
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/nature2contrat.i}

using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{mandat/include/indivisaireMandat.i}
{adblib/include/rlctt.i}
{adblib/include/ctrlb.i}
{application/include/combo.i}
{adblib/include/intnt.i}
{cadb/include/expweb.i}  /* f_ctratactiv  f_ctrat_tiers_actif */

function numeroImmeuble return int64 private(piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du Contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.          
    return 0.
    
end function.

function numeroMandant returns integer private (piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:  recuperation mandant
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    
    for first intnt no-lock                                                          
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-mandant}:
        return intnt.noidt.
    end.
    return 0.

end function.

procedure getIndivisaire:
    /*------------------------------------------------------------------------------
    Purpose: affichage indivisaire d'un mandat
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttIndivisaire.

    empty temp-table ttIndivisaire.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat)
    then mError:createError({&error}, 100057).
    else run chgInfoIndivisaire(pcTypeContrat, piNumeroContrat).
    
end procedure.

procedure setIndivisaire:
    /*------------------------------------------------------------------------------
    Purpose: maj indivisaire d'un mandat
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter table for ttIndivisaire.

    find first ttIndivisaire
    where lookup(ttIndivisaire.CRUD, "C,U,D") > 0 no-error.
    if not available ttIndivisaire
    then return.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = ttIndivisaire.cTypeContrat
                      and ctrat.nocon = ttIndivisaire.iNumeroContrat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.   
    run controlesAvantValidation.
    if mError:erreur() then return.
    run majInfoIndivisaire(pcTypeContrat, piNumeroContrat).

end procedure.

procedure ChgInfoIndivisaire private:
    /*------------------------------------------------------------------------------
    Purpose: chargement info indivisaire dans table de travail
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define variable viContratBanque        as integer   no-undo.
    define variable vcNumeroIban           as character no-undo.
    define variable vcLibelleModeReglement as character no-undo.
    define variable vcCodeModeReglement    as character no-undo.
    define variable vcLibelleModeAccompte  as character no-undo.
    define variable vcCodeModeAccompte     as character no-undo.

    define buffer intnt   for intnt.
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.

    for each intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-coIndivisaire}:
        // Récupération banque
        run rechercheCompteBancaire(pcTypeContrat, piNumeroContrat, intnt.noidt, output viContratBanque, output vcNumeroIban).
        // recuperation mode règlement
        run rechercheModeReglement(pcTypeContrat, piNumeroContrat, intnt.noidt, 1, output vcLibelleModeReglement, output vcCodeModeReglement).
        if intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
        then run rechercheModeReglement(pcTypeContrat, piNumeroContrat, intnt.noidt, 2, output vcLibelleModeAccompte, output vcCodeModeAccompte). /* NP 0714/0296 */
        if vcCodeModeAccompte = ? or vcCodeModeAccompte = ""
        then assign
             vcCodeModeAccompte    = vcCodeModeReglement
             vcLibelleModeAccompte = vcLibelleModeReglement
        .
        create ttIndivisaire.
        assign
            ttIndivisaire.CRUD               = "R"
            ttIndivisaire.dtTimestamp        = datetime(intnt.dtmsy, intnt.hemsy)
            ttIndivisaire.rRowid             = rowid(intnt)
            ttIndivisaire.cTypeContrat       = intnt.tpcon
            ttIndivisaire.iNumeroContrat     = intnt.nocon
            ttIndivisaire.iNumeroIndivisaire = intnt.noidt
            ttIndivisaire.iNumeroBanque      = viContratBanque
            ttIndivisaire.cIban              = vcNumeroIban
            ttIndivisaire.cLibCdReglCrg      = vcLibelleModeReglement
            ttIndivisaire.cLibCdRegltAcc     = vcLibelleModeAccompte
            ttIndivisaire.cCdRegltAcc        = vcCodeModeAccompte
            ttIndivisaire.cCdReglCrg         = vcCodeModeReglement
            ttIndivisaire.iTantieme          = intnt.nbnum
            ttIndivisaire.cModEnvCRG         = if intnt.tpmadisp > "" and intnt.tpmadisp <> "Non" then trim( intnt.tpmadisp) else "00001"
            ttIndivisaire.cLibModEnvCRG      = outilTraduction:getLibelleParam("MDNET", ttIndivisaire.cModEnvCRG )
            ttIndivisaire.iBase              = intnt.nbden
            /*
            ttIndivisaire.cdecom             = LbDecChg  //copro uniquement
            ttIndivisaire.cedapf             = LbEdiApf  //copro uniquement
            */
        .        
        for each vbRoles no-lock
            where vbRoles.tprol = intnt.tpidt
              and vbRoles.norol = intnt.noidt
          , first tiers no-lock
            where tiers.notie = vbRoles.notie:
            assign
                ttIndivisaire.iNumeroTiers = tiers.notie
                ttIndivisaire.cNomTiers    = substitute("&1 &2", tiers.lnom1, tiers.lpre1)            
                ttIndivisaire.lTiersActif  = f_ctrat_tiers_actif(tiers.notie, true)
            .
        end.
    end.
    
end procedure.

procedure controlesAvantValidation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    for first ttIndivisaire
    where lookup(ttIndivisaire.CRUD, "C,U") > 0
    and ttIndivisaire.iTantieme = 0:
        mError:createError({&error}, 1000623).                       //Les tantièmes doivent être different de 0
        return.                                    
    end. 

end procedure.
 
procedure majInfoIndivisaire private:
    /*------------------------------------------------------------------------------
    Purpose: maj base a partir table travail info indivisaire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define variable vcCodeEditionAppelFonds as character no-undo.
    define variable vcCodeDecompte          as character no-undo.
    define variable vhIntnt                 as handle    no-undo.
    define variable vhRlctt                 as handle    no-undo.
    define variable vhCtrlb                 as handle    no-undo.
    define variable vlModifCleIntnt         as logical   no-undo.
    define variable vlModifBanque           as logical   no-undo.
    define variable viContratBanque         as integer   no-undo.
    define variable vcNumeroIban            as character no-undo.
    define variable vlImmeubleCopro         as logical   no-undo.
    define variable viNumeroTitreCopro      as integer   no-undo.

    define buffer intnt for intnt.
    define buffer rlctt for rlctt.

    run rechImmCopro (numeroImmeuble(piNumeroContrat, pcTypeContrat), numeroMandant(piNumeroContrat, pcTypeContrat), output vlImmeubleCopro, output viNumeroTitreCopro). 

    empty temp-table ttIntnt.
    empty temp-table ttRlctt.
    empty temp-table ttCtrlb.
    for each ttIndivisaire
       where lookup(ttIndivisaire.CRUD, "C,U,D") > 0:
            
        find first intnt no-lock
             where rowid(intnt) = ttIndivisaire.rRowid no-error.            
        if lookup(ttIndivisaire.CRUD, "D,U") > 0
        and not available intnt
        then do:
            mError:createError({&error}, 1000624, string(ttIndivisaire.iNumeroIndivisaire)).      //modification (ou suppression) enregistrement indivisaire &1 inexistant" 
            return.
        end.
        //en mode suppression, suppression des infos associés au beneficiaire (banque et beneficiaire)
        if ttIndivisaire.CRUD = "D"
        then do:
            //suppression banque
            for each rlctt no-lock
               where rlctt.tpidt = {&TYPEROLE-coIndivisaire}
                 and rlctt.noidt = ttIndivisaire.iNumeroIndivisaire
                 and rlctt.tpct1 = ttIndivisaire.cTypeContrat
                 and rlctt.noct1 = ttIndivisaire.iNumeroContrat
                 and rlctt.tpct2 = {&TYPECONTRAT-prive}:
                create ttRlctt.
                assign
                    ttRlctt.tpidt       = {&TYPEROLE-coIndivisaire}
                    ttRlctt.noidt       = ttIndivisaire.iNumeroIndivisaire
                    ttRlctt.tpct1       = ttIndivisaire.cTypeContrat
                    ttRlctt.noct1       = ttIndivisaire.iNumeroContrat
                    ttRlctt.tpct2       = {&TYPECONTRAT-prive}
                    ttRlctt.lbdiv       = ""
                    ttRlctt.CRUD        = "D"
                    ttRlctt.dtTimestamp = datetime(rlctt.dtmsy, rlctt.hemsy)
                    ttRlctt.rRowid      = rowid(rlctt)
                .
            end.    
            // suppression beneficiaire
            if ttIndivisaire.cTypeContrat = {&TYPECONTRAT-mandat2Gerance}  
            then do:
                for each ctrlb no-lock
                   where ctrlb.tpctt = ttIndivisaire.cTypeContrat
                     and ctrlb.noctt = ttIndivisaire.iNumeroContrat
                     and ctrlb.tpid1 = {&TYPEROLE-coIndivisaire}
                     and ctrlb.noid1 = ttIndivisaire.iNumeroIndivisaire
                     and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}:
                    create ttCtrlb.
                    assign
                        ttCtrlb.tpctt       = ctrlb.tpctt
                        ttCtrlb.noctt       = ctrlb.noctt
                        ttCtrlb.tpid1       = ctrlb.tpid1
                        ttCtrlb.noid1       = ctrlb.noid1
                        ttCtrlb.tpid2       = ctrlb.tpid2
                        ttCtrlb.noid2       = ctrlb.noid2
                        ttCtrlb.CRUD        = "D"
                        ttCtrlb.dtTimestamp = datetime(ctrlb.dtmsy, ctrlb.hemsy)
                        ttCtrlb.rRowid      = rowid(ctrlb)  
                    .  
                end.
            end.
        end.
        vlModifBanque = no.
        if ttIndivisaire.CRUD = "U"
        then do:
            run rechercheCompteBancaire(pcTypeContrat, piNumeroContrat, intnt.noidt, output viContratBanque, output vcNumeroIban).
            if viContratBanque <> ttIndivisaire.iNumeroBanque
            then vlModifBanque = yes.   
        end.   
        
        if ttIndivisaire.CRUD = "U"
        and ttIndivisaire.iTantieme <> intnt.nbnum
        then do:
            /* cas particulier de la modification. si ttIndivisaire.iTantieme a change alors suppression de intnt suivi de creation (car nbnum est dans la cle) */     
            create ttIntnt.
            assign
                ttIntnt.tpcon       = ttIndivisaire.cTypeContrat
                ttIntnt.nocon       = ttIndivisaire.iNumeroContrat
                ttIntnt.tpidt       = {&TYPEROLE-coIndivisaire}
                ttIntnt.noidt       = ttIndivisaire.iNumeroIndivisaire
                ttIntnt.nbnum       = intnt.nbnum
                ttIntnt.idpre       = 0
                ttIntnt.idsui       = 0
                ttIntnt.CRUD        = "D"
                ttIntnt.rRowid      = ttIndivisaire.rRowid
                ttIntnt.dtTimestamp = ttIndivisaire.dtTimestamp                    
                vlModifCleIntnt     = yes
            .  
        end.
        else vlModifCleIntnt = no. 
        create ttIntnt.
        assign
            ttIntnt.tpcon       = ttIndivisaire.cTypeContrat
            ttIntnt.nocon       = ttIndivisaire.iNumeroContrat
            ttIntnt.tpidt       = {&TYPEROLE-coIndivisaire}
            ttIntnt.noidt       = ttIndivisaire.iNumeroIndivisaire
            ttIntnt.nbnum       = ttIndivisaire.iTantieme
            ttIntnt.idpre       = 0
            ttIntnt.idsui       = 0
            ttIntnt.nbden       = ttIndivisaire.iBase
            ttIntnt.cdreg       = ""
            ttIntnt.lbdiv       = ttIndivisaire.cCdReglCrg + '@' + (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then ttIndivisaire.cCdRegltAcc else "")
            ttIntnt.edapf       = (if pcTypeContrat = {&TYPECONTRAT-titre2copro} then vcCodeEditionAppelFonds else "")
            ttIntnt.lbdiv2      = (if pcTypeContrat = {&TYPECONTRAT-titre2copro} then vcCodeDecompte else "")
            ttIntnt.tpmadisp    = ttIndivisaire.cModEnvCRG
            ttIntnt.CRUD        = (if vlModifCleIntnt then "C" else ttIndivisaire.Crud) 
            ttIntnt.rRowid      = ttIndivisaire.rRowid
            ttIntnt.dtTimestamp = ttIndivisaire.dtTimestamp
        .
        /*--> Mise a jour du no contrat banque */
        if vlModifBanque
        or (ttIndivisaire.CRUD = "C" and ttIndivisaire.iNumeroBanque <> 0)
        then do:
            create ttRlctt.
            assign
                ttRlctt.tpidt = {&TYPEROLE-coIndivisaire}
                ttRlctt.noidt = ttIndivisaire.iNumeroIndivisaire
                ttRlctt.tpct1 = ttIndivisaire.cTypeContrat
                ttRlctt.noct1 = ttIndivisaire.iNumeroContrat
                ttRlctt.tpct2 = {&TYPECONTRAT-prive}
                ttRlctt.noct2 = ttIndivisaire.iNumeroBanque
                ttRlctt.lbdiv = ""
                ttRlctt.CRUD  = ""                                        //pas d'init du crud, sera mis a jour dans rlctt_CRUD.p/bquRlctt
            .
        end.
          
        if vlImmeubleCopro and viNumeroTitreCopro <> 0
        then do:
            create ttIntnt.
            assign
                ttIntnt.tpcon       = {&TYPECONTRAT-titre2copro}
                ttIntnt.nocon       = viNumeroTitreCopro
                ttIntnt.tpidt       = {&TYPEROLE-coIndivisaire}
                ttIntnt.noidt       = ttIndivisaire.iNumeroIndivisaire
                ttIntnt.nbnum       = ttIndivisaire.iTantieme
                ttIntnt.idpre       = 0
                ttIntnt.idsui       = 0
                ttIntnt.CRUD        = ttIndivisaire.CRUD
            .
            if lookup(ttIndivisaire.CRUD, "C,U") > 0
            then assign 
                ttIntnt.nbden    = ttIndivisaire.iBase
                ttIntnt.cdreg    = ""
                ttIntnt.lbdiv    = ""
                ttIntnt.edapf    = vcCodeEditionAppelFonds
                ttIntnt.lbdiv2   = vcCodeDecompte
                ttIntnt.tpmadisp = ttIndivisaire.cModEnvCRG
            .
            if lookup(ttIndivisaire.CRUD, "U,D") > 0
            then for first intnt no-lock
                     where intnt.tpcon = {&TYPECONTRAT-titre2copro}
                       and intnt.nocon = viNumeroTitreCopro
                       and intnt.tpidt = {&TYPEROLE-coIndivisaire}
                       and intnt.noidt = ttIndivisaire.iNumeroIndivisaire:            
                assign
                    ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
                    ttIntnt.rRowid      = rowid(intnt)
                .
            end.     
        end.
    end.
    
    run adblib/intnt_CRUD.p persistent set vhIntnt.
    run getTokenInstance in vhIntnt(mToken:JSessionId).
    run setIntnt in vhIntnt(table ttIntnt by-reference).
    run destroy in vhIntnt.
    if mError:erreur() then return.

    run adblib/rlctt_CRUD.p  persistent set vhRlctt.
    run getTokenInstance in vhRlctt(mToken:JSessionId).    
    run BquRlCtt in vhRlctt(input-output table ttRlctt by-reference).
    
    run setRlctt in vhRlctt(table ttRlctt by-reference).
    run destroy in vhRlctt.
    if mError:erreur() then return.

    run adblib/ctrlb_CRUD.p persistent set vhCtrlb.
    run getTokenInstance in vhCtrlb(mToken:JSessionId).
    run setCtrlb in vhCtrlb(table ttCtrlb by-reference).
    run destroy in vhCtrlb.    
    if mError:erreur() then return.

    //verification apres mise a jour que total tantieme correspond bien à la base saisie et que la base est bien la meme pour tous les indivisaires
    //ajout de ce controle car par rapport a l'appli la maj des infos est differente (on tient compte du CRUD)
    run controlesApresMaj (pcTypeContrat, piNumeroContrat).

end procedure.

procedure controlesApresMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    
    define variable viNbrIndivisaire as integer no-undo.
    define variable viBase           as integer no-undo. 
    define variable viTotalTantieme  as integer no-undo. 
      
    define buffer intnt for intnt.  
      
    for each intnt no-lock
       where intnt.tpcon = pcTypeContrat
         and intnt.nocon = piNumeroContrat
         and intnt.tpidt = {&TYPEROLE-coIndivisaire}:
        viNbrIndivisaire = viNbrIndivisaire + 1.      
        if viBase = 0 then viBase = intnt.nbden.
        if viBase <> intnt.nbden
        then do:
            mError:createError({&error}, 1000625, substitute("&2&1&3", separ[1], intnt.nbden, intnt.noidt)). //La base (&1) d'un des indivisaires (&2) n'est pas correcte
            return.            
        end.        
        viTotalTantieme = viTotalTantieme + intnt.nbnum.   
    end. 
    if viNbrIndivisaire = 0 and pcTypeContrat = {&TYPECONTRAT-titre2copro}
    then .
    else do:
        if viNbrIndivisaire < 2
        then do:
            mError:createError({&error}, 101137).
            return.        
        end.       
        if viBase <> viTotalTantieme
        then do:
            mError:createError({&error}, 1000626, substitute("&2&1&3", separ[1], viTotalTantieme, viBase)). //Le total tantième (&1) ne correspond pas à la base (&2)
            return.        
        end. 
    end.

end procedure.
 
procedure rechercheCompteBancaire private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la recuperation du compte bancaire d'un contrat indivisaire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pctypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter piNumeroRole    as integer   no-undo.
    define output parameter piContratBanque as integer   no-undo.
    define output parameter pcNumeroIban    as character no-undo.

    define buffer rlctt for rlctt.
    define buffer ctanx for ctanx.
    
    /* Récupération d'un compte bancaire pour le contrat s'il en a un */
    for first rlctt no-lock
        where rlctt.tpidt = {&TYPEROLE-coIndivisaire}
          and rlctt.noidt = piNumeroRole
          and rlctt.tpct1 = pctypeContrat
          and rlctt.noct1 = piNumeroContrat
          and rlctt.tpct2 = {&TYPECONTRAT-prive}:
        piContratBanque = rlctt.noct2.
        for first ctanx no-lock
            where ctanx.tpcon = {&TYPECONTRAT-prive}
              and ctanx.nocon = piContratBanque:
            pcNumeroIban = ctanx.iban.
        end.
    end.

end procedure.

procedure rechercheModeReglement private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la recuperation du compte bancaire d'un contrat indivisaire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pctypeContrat          as character no-undo.
    define input  parameter piNumeroContrat        as int64     no-undo.
    define input  parameter piNumeroRole           as integer   no-undo.
    define input  parameter piTypeReglement        as integer   no-undo.
    define output parameter pcLibelleModeReglement as character no-undo.
    define output parameter pcCodeModeReglement    as character no-undo.

    define buffer intnt for intnt.

    // récupération du mode de reglement, Initialisé à cheque
    if piTypeReglement = 1 then pcCodeModeReglement = {&MODEREGLEMENT-cheque}.
    for first intnt no-lock
        where intnt.tpidt = {&TYPEROLE-coIndivisaire}
          and intnt.noidt = piNumeroRole
          and intnt.tpcon = pctypeContrat
          and intnt.nocon = piNumeroContrat:
        if num-entries(intnt.lbdiv, '@') >= 2 and entry(piTypeReglement, intnt.lbdiv, '@') > ""
        then pcCodeModeReglement = entry(piTypeReglement, intnt.lbdiv, '@').
    end.
    pcLibelleModeReglement = outilTraduction:getLibelleProg("O_MDG", pcCodeModeReglement).

end procedure.

procedure rechImmCopro private:
    /*------------------------------------------------------------------------------
    Purpose: recherche si immeuble de copro
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piImmeuble         as int64 no-undo.
    define input  parameter piMandant          as integer no-undo.
    define output parameter plImmeubleCopro    as logical no-undo.
    define output parameter piNumeroTitreCopro as integer no-undo.

    define buffer intnt for intnt.
     
    for first intnt no-lock 
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piImmeuble
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}:
        assign 
            plImmeubleCopro = yes
            piNumeroTitreCopro    = integer(string(intnt.nocon, "99999") + string(piMandant, "99999")) //Constitution du No de Titre de Copropriete
        .
        if not can-find (first ctrat no-lock                                                      //Verifier que ce titre existe en Copropriete
                         where ctrat.tpcon = {&TYPECONTRAT-titre2copro}
                           and ctrat.nocon = piNumeroTitreCopro)
        then piNumeroTitreCopro = 0. 
    end.

end procedure.

procedure initComboIndivisaire:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    define variable voSyspr as class syspr.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("MDNET", "CMBMODEENVOICRG", output table ttCombo by-reference).
    delete object voSyspr. 

end procedure.

procedure controleIndivisaire:
    /*------------------------------------------------------------------------------
    Purpose: controle indivisaire
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer ctrat for ctrat.
    
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if ctrat.ntcon <> {&NATURECONTRAT-mandatAvecIndivision}
    then return.
    run controlesApresMaj (pcTypeContrat, piNumeroContrat).

end procedure.
