/*------------------------------------------------------------------------
File        : paramTexteCrg.p
Purpose     : Parametrage texte CRG
Author(s)   : GGA 2017/11/06
Notes       : reprise pgm adb/prmcl/pcltxcrg.p
derniere revue: 2018/05/24 - phm: KO
        utiliser les _CRUD (aparm par exemple).
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gerance/include/paramTexteCrg.i}

procedure getParamTexteCrg:
    /*------------------------------------------------------------------------------
    Purpose: Récupération paramètre texte crg du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamTexteCrg.

    empty temp-table ttParamTexteCrg.
    run lectureParamTexteCrg.

end procedure.

procedure setParamTexteCrg:
    /*------------------------------------------------------------------------------
    Purpose: Mise a jour des paramètre texte crg du mandat de gérance
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamTexteCrg.

    run VerZonSai.
    if mError:erreur() then return.
    run savEcrPrm.
 
end procedure.

procedure lectureParamTexteCrg private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération paramètre texte crg du mandat
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer aparm for aparm.

    for first aparm no-lock
        where aparm.soc-cd = integer(mToken:cRefGerance)
          and aparm.tppar = "CPRL":
        create ttParamTexteCrg.
        assign  
            ttParamTexteCrg.cVille           = entry(1, aparm.lib, "|")
            ttParamTexteCrg.cTitreSignataire = if num-entries(aparm.lib, "|") >= 3 then entry(3, aparm.lib, "|") else ""
            ttParamTexteCrg.cNomSignataire   = if num-entries(aparm.lib, "|") >= 4 then entry(4, aparm.lib, "|") else ""
            ttParamTexteCrg.cObjet           = if num-entries(aparm.lib, "|") >= 5 then entry(5, aparm.lib, "|") else "" 
            ttParamTexteCrg.cCourrier        = aparm.zone2
            ttParamTexteCrg.CRUD        = 'R'
            ttParamTexteCrg.dtTimestamp = datetime(aparm.damod, aparm.ihmod)
            ttParamTexteCrg.rRowid      = rowid(aparm)
        .
    end.

end procedure.

procedure VerZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de Vérification des zones saisies.
    Notes  :
    ------------------------------------------------------------------------------*/  
    for first ttParamTexteCrg
        where lookup(ttParamTexteCrg.CRUD, "C,U") > 0:
        if ttParamTexteCrg.cVille = ? or ttParamTexteCrg.cVille = ""
        then mError:createError({&error}, 105964).
        else if ttParamTexteCrg.cTitreSignataire = ? or ttParamTexteCrg.cTitreSignataire = "" 
        then mError:createError({&error}, 1000499).    //Le titre signataire est obligatoire
    end.

end procedure.

procedure SavEcrPrm private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de sauvegarde paramètre 
    Notes  :
    ------------------------------------------------------------------------------*/  
    define buffer aparm for aparm.
    
    for first ttParamTexteCrg
        where lookup(ttParamTexteCrg.CRUD, "C,U") > 0:
        find first aparm exclusive-lock
             where aparm.soc-cd = integer(mToken:cRefGerance)
               and aparm.tppar  = "CPRL" no-wait no-error.
        if not available aparm then do:
            if locked aparm
            then do:
                mError:createError({&error}, 1000496).          //Enregistrement bloqué par un autre utilisateur
                return.
            end.
            create aparm.
            assign
                aparm.soc-cd = integer(mToken:cRefGerance)
                aparm.tppar  = "CPRL"
                aparm.dacrea = today
                aparm.ihcrea = mtime
                aparm.usrid  = mtoken:cUser
                aparm.lib    = fill("|", 5)
            . 
        end.
        else if num-entries(aparm.lib, "|") < 5 then aparm.lib = aparm.lib + "||".
        assign
            entry(1, aparm.lib, "|") = ttParamTexteCrg.cVille 
            entry(3, aparm.lib, "|") = ttParamTexteCrg.cTitreSignataire
            entry(4, aparm.lib, "|") = ttParamTexteCrg.cNomSignataire
            entry(5, aparm.lib, "|") = ttParamTexteCrg.cObjet
            aparm.zone2              = ttParamTexteCrg.cCourrier
            aparm.damod              = today
            aparm.ihmod              = mtime
            aparm.usridmod           = mtoken:cUser
        .
    end.

end procedure.
