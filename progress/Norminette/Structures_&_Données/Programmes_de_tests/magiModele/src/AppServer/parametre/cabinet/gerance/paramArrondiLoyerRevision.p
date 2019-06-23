
/*------------------------------------------------------------------------
    File        : paramArrondiLoyerRevision.p
    Purpose     : Paramétrage Client Type d'arrondi des loyers et révisions loyer
    Author(s)   : npo
    Created     : Tue Nov 28 14:35:25 CET 2017
    Notes       : reprise pgm adb/prmcl/pclcdarr.p
  ----------------------------------------------------------------------*/

using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gerance/include/paramTypeArrondiLoyerRevision.i}

{application/include/combo.i}
{application/include/error.i}

procedure getParamTypeArrondiLoyerRevision:
    /*------------------------------------------------------------------------------
    Purpose: Récupération paramètre Type d'arrondi des loyers et révisions loyer
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamTypeArrondiLoyerRevision.
      
    empty temp-table ttParamTypeArrondiLoyerRevision.
    run lectureParamTypeArrondiLoyerRevision. 

end procedure.

procedure lectureParamTypeArrondiLoyerRevision private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération paramètre Type d'arrondi des loyers et révisions loyer
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer pclie for pclie.

    for first pclie no-lock
        where pclie.tppar = "CDARR":

        create ttParamTypeArrondiLoyerRevision.          
        assign  
            ttParamTypeArrondiLoyerRevision.CRUD                         = 'R'
            ttParamTypeArrondiLoyerRevision.cCodeTypeArrondiLoyer        = pclie.zon01
            ttParamTypeArrondiLoyerRevision.cLibelleTypeArrondiLoyer     = if pclie.zon01 = "1" then outilTraduction:getLibelle(102060) /* Tronqué */
                                                                                                else outilTraduction:getLibelle(102061) /* Arrondi */
            ttParamTypeArrondiLoyerRevision.cCodeDigitArrondiLoyer       = pclie.zon02
            ttParamTypeArrondiLoyerRevision.cLibelleDigitArrondiLoyer    = outilTraduction:getLibelleParam("CDARR", pclie.zon02)

            ttParamTypeArrondiLoyerRevision.cCodeTypeArrondiRevision     = pclie.zon03
            ttParamTypeArrondiLoyerRevision.cLibelleTypeArrondiRevision  = if pclie.zon03 = "1" then outilTraduction:getLibelle(102060) /* Tronqué */
                                                                                                else outilTraduction:getLibelle(102061) /* Arrondi */
            ttParamTypeArrondiLoyerRevision.cCodeDigitArrondiRevision    = pclie.zon04
            ttParamTypeArrondiLoyerRevision.cLibelleDigitArrondiRevision = outilTraduction:getLibelleParam("CDARR", pclie.zon04)
        .
    end.
    
end procedure.

procedure getCombo:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des combos
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.
    
    run chargeCombo.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspr as class syspr no-undo.

    /* Combo Type arrondi Loyer */
    voSyspr = new syspr().
    voSyspr:getComboParametre("CDARR", "DIGITARRLOYER", output table ttCombo by-reference).

    /* Combo Type arrondi Révision */
    voSyspr:getComboParametre("CDARR", "DIGITARRREVISION", output table ttCombo by-reference).

end procedure.

procedure setParamTypeArrondiLoyerRevision:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètre Type d'arrondi des loyers et révisions loyer
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamTypeArrondiLoyerRevision.
   
    run SavEcrPrm. 
 
end procedure.

procedure SavEcrPrm private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de sauvegarde paramètre 
    Notes  :
    ------------------------------------------------------------------------------*/

    define buffer pclie for pclie.
 
    find first ttParamTypeArrondiLoyerRevision where ttParamTypeArrondiLoyerRevision.CRUD = "U".

    find first pclie exclusive-lock
         where pclie.tppar = "CDARR" no-error.
    if not available pclie then
    do:
        if locked pclie then
        do:
            mError:createError({&error}, "Enregistrement bloqué par un autre utilisateur").
            return.    
        end.     
        create pclie.
        assign
            pclie.tppar = "CDARR"     
            pclie.dtcsy = today    
            pclie.hecsy = mtime
            pclie.cdcsy = mtoken:cUser
        .
    end.
    assign    
        pclie.dtmsy = today    
        pclie.hemsy = mtime
        pclie.cdmsy = mtoken:cUser
        pclie.zon01 = ttParamTypeArrondiLoyerRevision.cCodeTypeArrondiLoyer
        pclie.zon02 = ttParamTypeArrondiLoyerRevision.cCodeDigitArrondiLoyer
        pclie.zon03 = ttParamTypeArrondiLoyerRevision.cCodeTypeArrondiRevision
        pclie.zon04 = ttParamTypeArrondiLoyerRevision.cCodeDigitArrondiRevision
        pclie.fgact = "YES"
    .

end procedure.  