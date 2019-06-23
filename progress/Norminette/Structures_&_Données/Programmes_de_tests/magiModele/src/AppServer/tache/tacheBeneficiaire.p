/*------------------------------------------------------------------------
File        : tacheBeneficiaire.p
Purpose     : gestion beneficiaire mandat
Author(s)   : GGA 2017/09/11
Notes       : a partir de adb/tach/prmmtben.p
              ce programme est utilise pour tache beneficiaire du mandat mais aussi depuis objet indivisaire du mandat
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/nature2contrat.i}

using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{adblib/include/ctrlb.i}
{tache/include/tacheBeneficiaire.i}

function numeroMandant returns integer private (piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:  recuperation mandant
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    
    find first intnt no-lock                                                          
         where intnt.tpcon = pcTypeContrat
           and intnt.nocon = piNumeroContrat
           and intnt.tpidt = {&TYPEROLE-mandant} no-error.
    if available intnt
    then return intnt.noidt.
    else return 0.

end function.

procedure getBeneficiaire:
    /*------------------------------------------------------------------------------
    Purpose: affichage beneficiaire pour un indivisaire
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat     as int64     no-undo.
    define input parameter pcTypeContrat       as character no-undo.    
    define input parameter piNumeroIndivisaire as integer   no-undo.
    define output parameter table for ttTacheBeneficiaire.

    define variable vcTypeRole as character no-undo.

    define buffer ctrat for ctrat.

    empty temp-table ttTacheBeneficiaire.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.   
    if ctrat.ntcon = {&NATURECONTRAT-mandatSansIndivision}
    then do:
        assign
            piNumeroIndivisaire = numeroMandant(piNumeroContrat, pcTypeContrat)          
            vcTypeRole = {&TYPEROLE-mandant}
        . 
    end.
    else do:
        if not can-find(first intnt no-lock                                          //controle existence indivisaire pour le mandat
                        where intnt.tpidt = {&TYPEROLE-coIndivisaire}
                          and intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.noidt = piNumeroIndivisaire)
        then do:
            mError:createError({&error}, 1000478, string(piNumeroIndivisaire)). //indivisaire &1 inexistant
            return.        
        end.
        vcTypeRole = {&TYPEROLE-coIndivisaire}. 
    end.
    run chgInfoBeneficiaire (pcTypeContrat, piNumeroContrat, piNumeroIndivisaire, vcTypeRole).

end procedure.

procedure setBeneficiaire:
    /*------------------------------------------------------------------------------
    Purpose: maj beneficiaire
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheBeneficiaire.

    define variable vcTypeRole as character no-undo.

    define buffer ctrat for ctrat.

    find first ttTacheBeneficiaire
    where lookup(ttTacheBeneficiaire.CRUD, "C,U,D") > 0 no-error.
    if not available ttTacheBeneficiaire
    then do:
        mError:createError({&information}, 1000479).   //Aucune information à mettre a jour
        return.        
    end.
    find first ctrat no-lock
         where ctrat.tpcon = ttTacheBeneficiaire.cTypeContrat
           and ctrat.nocon = ttTacheBeneficiaire.iNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.   
    if ctrat.ntcon = {&NATURECONTRAT-mandatSansIndivision}
    then vcTypeRole = {&TYPEROLE-mandant}.
    else vcTypeRole = {&TYPEROLE-coIndivisaire}. 

    run controlesAvantValidation (vcTypeRole).
    if mError:erreur() = yes then return.
    run majInfoBeneficiaire (buffer ctrat, ttTacheBeneficiaire.iNumeroIndivisaire, vcTypeRole).

end procedure.

procedure chgInfoBeneficiaire private:
    /*------------------------------------------------------------------------------
    Purpose: chargement info beneficiaire dans table de travail
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat       as character no-undo.
    define input parameter piNumeroContrat     as int64     no-undo.
    define input parameter piNumeroIndivisaire as integer   no-undo.
    define input parameter pcTypeRole          as character no-undo.

    define variable vcTpRolMai  as character no-undo.
    
    define buffer ctrlb   for ctrlb.
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.
    
    for each ctrlb no-lock
        where ctrlb.tpctt = pcTypeContrat
          and ctrlb.noctt = piNumeroContrat
          and ctrlb.tpid1 = pcTypeRole
          and ctrlb.noid1 = piNumeroIndivisaire
          and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
          and ctrlb.nbnum <> 0
      , first vbRoles no-lock
        where vbRoles.tprol = ctrlb.tpid2
          and vbRoles.norol = ctrlb.noid2:
        create ttTacheBeneficiaire.
        assign
            ttTacheBeneficiaire.CRUD                = "R"
            ttTacheBeneficiaire.dtTimestamp         = datetime(ctrlb.dtmsy, ctrlb.hemsy)
            ttTacheBeneficiaire.rRowid              = rowid(ctrlb)
            ttTacheBeneficiaire.cTypeContrat        = ctrlb.tpctt
            ttTacheBeneficiaire.iNumeroContrat      = ctrlb.noctt
            ttTacheBeneficiaire.iNumeroIndivisaire  = ctrlb.noid1
            ttTacheBeneficiaire.cTypeIndivisaire    = ctrlb.tpid1
            ttTacheBeneficiaire.iNumeroBeneficiaire = vbRoles.norol
            ttTacheBeneficiaire.iNumeroTiers        = vbRoles.notie
            ttTacheBeneficiaire.iNumeroBanque       = ctrlb.noct2
            ttTacheBeneficiaire.cModeReglement      = ctrlb.mdreg
            ttTacheBeneficiaire.cLibModeReglement   = outilTraduction:getLibelleProg("O_MDG", ctrlb.mdreg)            
            ttTacheBeneficiaire.iTantieme           = ctrlb.nbnum
            ttTacheBeneficiaire.iBase               = ctrlb.nbden 
        .
        for first tiers no-lock
            where tiers.notie = vbRoles.notie:
            ttTacheBeneficiaire.cNom = substitute("&1 &2", tiers.lnom1, tiers.lpre1).
        end.
        if ttTacheBeneficiaire.iNumeroBanque <> 0
        then run recupCompte ({&TYPECONTRAT-prive}, ttTacheBeneficiaire.iNumeroBanque, output ttTacheBeneficiaire.cIbanBq, output ttTacheBeneficiaire.cDomiciliationBq, output ttTacheBeneficiaire.cTitulairebq).
    end.
    
end procedure.

procedure majInfoBeneficiaire private:
    /*------------------------------------------------------------------------------
    Purpose: maj base a partir table travail info beneficiaire
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.
    define input parameter piNumeroIndivisaire as integer   no-undo.    
    define input parameter pcTypeRole          as character no-undo.

    define variable vhProc          as handle  no-undo.
    define variable viTotalTantieme as integer no-undo. 
    define variable viBase          as integer no-undo. 
    
    define buffer ctrlb for ctrlb.

    empty temp-table ttCtrlb. 
    for each ttTacheBeneficiaire
    where lookup(ttTacheBeneficiaire.CRUD, "C,U,D") > 0:
        create ttCtrlb.     
        assign
            ttCtrlb.tpctt       = ttTacheBeneficiaire.cTypeContrat
            ttCtrlb.noctt       = ttTacheBeneficiaire.iNumeroContrat
            ttCtrlb.tpid1       = pcTypeRole
            ttCtrlb.noid1       = ttTacheBeneficiaire.iNumeroIndivisaire
            ttCtrlb.tpid2       = {&TYPEROLE-beneficiaire}
            ttCtrlb.noid2       = ttTacheBeneficiaire.iNumeroBeneficiaire
            ttCtrlb.CRUD        = ttTacheBeneficiaire.CRUD
            ttCtrlb.dtTimestamp = ttTacheBeneficiaire.dtTimestamp
            ttCtrlb.rRowid      = ttTacheBeneficiaire.rRowid  
        .  
        if lookup(ttTacheBeneficiaire.CRUD, "C,U") > 0
        then assign 
                 ttCtrlb.nbnum  = ttTacheBeneficiaire.iTantieme
                 ttCtrlb.nbden  = ttTacheBeneficiaire.iBase
                 ttCtrlb.mdreg  = ttTacheBeneficiaire.cModeReglement
                 ttCtrlb.tpct2  = {&TYPECONTRAT-prive}
                 ttCtrlb.noct2  = ttTacheBeneficiaire.iNumeroBanque
                 ttCtrlb.lbdiv  = "lbdivTmp"
        .    
    end.
    run adblib/ctrlb_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCtrlb in vhProc(table ttCtrlb by-reference).
    run destroy in vhProc.
    if mError:erreur() then return.
    
    //verification apres mise a jour que total tantieme correspond bien à la base saisie et que la base est bien la meme pour tous les beneficiaires
    // ajout de ce controle car par rapport a l'appli la maj des infos est differente (on tient compte du CRUD)
    for each ctrlb no-lock
       where ctrlb.tpctt = ctrat.tpcon
         and ctrlb.noctt = ctrat.nocon
         and ctrlb.tpid1 = pcTypeRole
         and ctrlb.noid1 = piNumeroIndivisaire
         and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}:
        if viBase = 0 then viBase = ctrlb.nbden.
        if viBase <> ctrlb.nbden
        then do:
            mError:createError({&error}, 1000480, substitute("&2&1&3", separ[1], ctrlb.nbden, ctrlb.noid2)). //La base (&1) d'un des bénéficiaires (&2) n'est pas correcte
            return.            
        end.        
        viTotalTantieme = viTotalTantieme + ctrlb.nbnum.   
    end. 
    if viBase <> viTotalTantieme
    then do:
        mError:createError({&error}, 1000481, substitute("&2&1&3", separ[1], viTotalTantieme, viBase)). //Le total tantième (&1) ne correspond pas à la base (&2)
        return.        
    end.                 
    
    run application/transfert/GI_alimaj.p persistent set vhproc.
    run getTokenInstance in vhproc (mToken:JSessionId).
    run majTrace in vhproc (integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).    
    run destroy in vhproc.  

end procedure.

procedure initComboBeneficiaire:
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
    
    voSyspg = new syspg("R_MDC", "tstpopup").
    voSyspg:creationComboSysPgZonXX("C", {&TYPECONTRAT-mandat2Gerance}, output table ttCombo by-reference).

end procedure.

procedure controlesAvantValidation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole as character no-undo.
         
    define buffer vbttTacheBeneficiaire for ttTacheBeneficiaire. 
    
    for each ttTacheBeneficiaire
    where lookup(ttTacheBeneficiaire.CRUD, "C,U,D") > 0
    break by ttTacheBeneficiaire.iNumeroIndivisaire:  
        if first-of(ttTacheBeneficiaire.iNumeroIndivisaire)                                              //on ne traite qu'un seul indivisaire a la fois
        then do:
            if can-find(first vbttTacheBeneficiaire
                        where vbttTacheBeneficiaire.iNumeroIndivisaire <> ttTacheBeneficiaire.iNumeroIndivisaire 
                          and lookup(ttTacheBeneficiaire.CRUD, "C,U,D") > 0)
            then do:
                mError:createError({&error}, 1000482). //mise à jour de plusieurs bénéficiaires impossible
                return.                
            end.
        end.
        if ttTacheBeneficiaire.CRUD = "C"
        and can-find (first ctrlb no-lock
                      where ctrlb.tpctt = ttTacheBeneficiaire.cTypeContrat
                        and ctrlb.noctt = ttTacheBeneficiaire.iNumeroContrat
                        and ctrlb.tpid1 = pcTypeRole
                        and ctrlb.noid1 = ttTacheBeneficiaire.iNumeroIndivisaire
                        and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                        and ctrlb.noid2 = ttTacheBeneficiaire.iNumeroBeneficiaire)
        then do:
            mError:createError({&error}, 1000483, string(ttTacheBeneficiaire.iNumeroBeneficiaire)). //création d'un bénéficiaire &1 déjà existant
            return.                        
        end.
        else if not can-find (first ctrlb no-lock
                              where ctrlb.tpctt = ttTacheBeneficiaire.cTypeContrat
                                 and ctrlb.noctt = ttTacheBeneficiaire.iNumeroContrat
                                 and ctrlb.tpid1 = pcTypeRole
                                 and ctrlb.noid1 = ttTacheBeneficiaire.iNumeroIndivisaire
                                 and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                                 and ctrlb.noid2 = ttTacheBeneficiaire.iNumeroBeneficiaire)
        then do:
            mError:createError({&error}, 1000484, string(ttTacheBeneficiaire.iNumeroBeneficiaire)). //modification ou suppression d'un bénéficiaire &1 inexistant
            return.                        
        end.       
    end. 

end procedure.
 
procedure recupCompte private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la recuperation d'un compte bancaire ( compte / dom )
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTpCtaUse-IN as character no-undo.
    define input  parameter piNoCtaUse-IN as integer   no-undo.
    define output parameter pcNoCptBqu-OU as character no-undo.
    define output parameter pcLbDomBqu-OU as character no-undo.
    define output parameter pcLbTitBqu-OU as character no-undo.

    define buffer ctanx for ctanx.

    for first ctanx no-lock
        where ctanx.tpcon = pcTpCtaUse-IN
          and ctanx.nocon = piNoCtaUse-IN:
        assign
            pcNoCptBqu-OU = ctanx.iban
            pcLbDomBqu-OU = ctanx.lbdom
            pcLbTitBqu-OU = ctanx.lbtit
        .
    end.

end procedure.
 
/*gga a voir plus tard si necessaire 
procedure completerBeneficiaire:
    /*------------------------------------------------------------------------------
    Purpose: recherche infos par defaut suite ajout d'un tiers beneficiaire dans la liste
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttTacheBeneficiaire.

    for each ttTacheBeneficiaire
        where ttTacheBeneficiaire.lACompleter:
        assign
            ttTacheBeneficiaire.lACompleter    = no
            ttTacheBeneficiaire.cModeReglement = {&MODEREGLEMENT-cheque}
        .
        run recupBanque (ttTacheBeneficiaire.iNumeroBeneficiaire, output ttTacheBeneficiaire.iNumeroBanque).
        if ttTacheBeneficiaire.iNumeroBanque <> 0
        then run recupCompte ({&TYPECONTRAT-prive}, ttTacheBeneficiaire.iNumeroBanque, output ttTacheBeneficiaire.cIbanBq, output ttTacheBeneficiaire.cDomiciliationBq, output ttTacheBeneficiaire.cTitulairebq).
        ttTacheBeneficiaire.cLibModeReglement = outilTraduction:getLibelleProg("O_MDG", ttTacheBeneficiaire.cModeReglement).
    end.

end procedure.
 
procedure recupBanque private:
    /*------------------------------------------------------------------------------
    Purpose: recuperation banque
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNoRolSel-IN as integer no-undo.
    define output parameter piNoConBqu-OU as integer no-undo.

    define buffer vbRoles for roles.
    define buffer ctanx   for ctanx.

    for first vbRoles no-lock
        where vbRoles.tprol = {&TYPEROLE-beneficiaire}
          and vbRoles.norol = piNoRolSel-IN:
        for each ctanx no-lock                                    /* Récuperation d'un compte bancaire s'il en a un*/
            where ctanx.tpcon = {&TYPECONTRAT-prive}
              and ctanx.tprol = {&TYPEROLE-tiers}
              and ctanx.norol = vbRoles.notie
            break by ctanx.nocon:
            if first(ctanx.nocon) or ctanx.tpact = "DEFAU" then piNoConBqu-OU = ctanx.nocon.
        end.
    end.

end procedure.
gga fin a voir plus tard si necessaire*/ 

 
