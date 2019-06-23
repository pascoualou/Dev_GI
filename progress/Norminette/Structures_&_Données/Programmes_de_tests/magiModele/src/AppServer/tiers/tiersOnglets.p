/*------------------------------------------------------------------------
File        : tiersOnglets.p
Purpose     :
Author(s)   : OFA - 2018/05/15
Notes       :
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tiers/include/tiersOnglets.i}

/* **********************  Internal Procedures  *********************** */
procedure getListeOnglets :
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeSousFamille as character no-undo.
    define output parameter table for ttOngletsTiers.

    define variable viCompteur as integer     no-undo.
    define buffer vbSys_pg for sys_pg.
    define buffer vbttOngletsTiers for ttOngletsTiers.

    for each sys_pg no-lock
        where sys_pg.tppar = "R_SCL"
        and   sys_pg.zone1 = (if pcCodeSousFamille ne "" then pcCodeSousFamille else sys_pg.zone1), 
        each vbSys_pg no-lock
        where vbSys_pg.tppar = 'O_CLT' 
        and   vbSys_pg.cdpar = sys_pg.zone2
        by sys_pg.cdpar:
       create ttOngletsTiers.
       assign
           ttOngletsTiers.iNumeroOnglet     = viCompteur 
           ttOngletsTiers.iNumeroOrdre      = (if num-entries(vbSys_pg.zone6) >= 2 then integer(entry(2,vbSys_pg.zone6)) else 99)
           ttOngletsTiers.cCodeOnglet       = sys_pg.zone2
           ttOngletsTiers.cCodeSousFamille  = sys_pg.zone1
           //Les onglets "SIRET/Employeur" et "Statut/Employeur" deviennent SIRET car la partie Employeur est obsolète (ancienne paye)
           ttOngletsTiers.cLibelleOnglet    = outilTraduction:getLibelle(if lookup(string(sys_pg.nome1),"701867,701537") > 0 then 102104 else sys_pg.nome1)
           viCompteur                       = viCompteur + 1
           .
    end.
    
    //On ajoute pour chaque sous-famille les onglets Contrats & Adresses qui ne sont pas dans sys_pg car non gérés dans l'ancienne appli Magi
    for each ttOngletsTiers break by ttOngletsTiers.cCodeSousFamille
        :
        if last-of(ttOngletsTiers.cCodeSousFamille) then do:
            create vbttOngletsTiers.
            assign
                vbttOngletsTiers.iNumeroOnglet     = viCompteur 
                vbttOngletsTiers.iNumeroOrdre      = 1000
                vbttOngletsTiers.cCodeOnglet       = ttOngletsTiers.cCodeOnglet 
                vbttOngletsTiers.cCodeSousFamille  = ttOngletsTiers.cCodeSousFamille
                vbttOngletsTiers.cLibelleOnglet    = "Contrats"
                viCompteur                         = viCompteur + 1
                .
            create vbttOngletsTiers.
            assign
                vbttOngletsTiers.iNumeroOnglet     = viCompteur 
                vbttOngletsTiers.iNumeroOrdre      = 1001
                vbttOngletsTiers.cCodeOnglet       = ttOngletsTiers.cCodeOnglet 
                vbttOngletsTiers.cCodeSousFamille  = ttOngletsTiers.cCodeSousFamille
                vbttOngletsTiers.cLibelleOnglet    = "Adresses"
                viCompteur                         = viCompteur + 1
                .
        end.
        
    end.

    return.
end procedure.
