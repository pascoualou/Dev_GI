/*------------------------------------------------------------------------
File        : listeCategorieContrat.p
Purpose     : creation liste categorie de contrat (en fonction du type de contrat)
Author(s)   : GGA  -  2017/08/24
Notes       : reprise du pgm adb/objet/frmlpg00.p mais en simplifiant le code pour ne sortir que cette liste categorie
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageImmobilierEntreprise.
using parametre.pclie.parametrageDefautBail.
using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}

procedure getListeCategorieContrat:
    /*------------------------------------------------------------------------------
    Purpose: creation d'une liste des categories contrat pour un type de mandat
    Notes  : service appel externe (mandat.p)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat as character no-undo.
    define output parameter table for ttCombo.

    define variable voFournisseurLoyer     as class parametrageFournisseurLoyer     no-undo.
    define variable voImmobilierEntreprise as class parametrageImmobilierEntreprise no-undo.
    define variable voDefautBail           as class parametrageDefautBail           no-undo.
    define variable voSyspg                as class syspg                           no-undo.

    define buffer sys_pg for sys_pg.

    assign
        voFournisseurLoyer     = new parametrageFournisseurLoyer()
        voImmobilierEntreprise = new parametrageImmobilierEntreprise()
        voDefautBail           = new parametrageDefautBail()
        voSyspg                = new syspg()
    .
    boucleSyspg:
    for each sys_pg no-lock
       where sys_pg.tppar = "R_CRC"
         and sys_pg.zone1 = pcTypeContrat:

        if sys_pg.zone1 = {&TYPECONTRAT-bail}
        then do:  
            voDefautBail:reload(voDefautBail:tppar, sys_pg.zone2).
            if not voDefautBail:isNatureBailActive()
            then next boucleSyspg.
        end.

        if lookup(sys_pg.zone1, substitute ("&1,&2", {&TYPECONTRAT-preBail}, {&TYPECONTRAT-bail})) > 0 
        and sys_pg.zone2 = {&NATURECONTRAT-specialVacant}
        then next boucleSyspg.
         
        if sys_pg.zone1 = {&TYPECONTRAT-mandat2Syndic}
        and sys_pg.zone2 = {&NATURECONTRAT-restaurantInterEntreprise}
        and not voImmobilierEntreprise:isActif() 
        then next boucleSyspg.

        if sys_pg.zone1 = {&TYPECONTRAT-mandat2Gerance}
        then do:
            if sys_pg.zone2 = {&NATURECONTRAT-mandatGestionRevenusGarantis} 
            then next boucleSyspg.
            if voFournisseurLoyer:isGesFournisseurLoyer()
            then case voFournisseurLoyer:getCodeModele():
                when "00002" then if sys_pg.zone2 <> {&NATURECONTRAT-mandatSousLocation}
                                  then next boucleSyspg.
                when "00003" then if lookup(sys_pg.zone2, substitute("&1,&2,&3", {&NATURECONTRAT-mandatSousLocation}, {&NATURECONTRAT-mandatLocationDelegue}, {&NATURECONTRAT-mandatSousLocationDelegue})) > 0
                                  then next boucleSyspg.
                when "00004" then if lookup(sys_pg.zone2, substitute("&1,&2", {&NATURECONTRAT-mandatSousLocation}, {&NATURECONTRAT-mandatSousLocationDelegue})) > 0
                                  then next boucleSyspg.
                otherwise if lookup(sys_pg.zone2, substitute("&1,&2,&3,&4,&5", {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatSousLocation}, {&NATURECONTRAT-mandatLocationDelegue}, {&NATURECONTRAT-mandatSousLocationDelegue}, {&NATURECONTRAT-mandatLocationIndivision})) > 0
                          then next boucleSyspg.
            end case.
            else if lookup(sys_pg.zone2, substitute("&1,&2,&3,&4,&5", {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatSousLocation}, {&NATURECONTRAT-mandatLocationDelegue}, {&NATURECONTRAT-mandatSousLocationDelegue}, {&NATURECONTRAT-mandatLocationIndivision})) > 0
                 then next boucleSyspg.
            voSyspg:creationttCombo("CMBCATEGORIECONTRAT", trim(sys_pg.zone2), trim(outilTraduction:getLibelleProg(sys_pg.tppar, sys_pg.cdpar)), output table ttCombo by-reference).
        end.
        else 
        if voFournisseurLoyer:isGesFournisseurLoyer() = false and sys_pg.zone1 = {&TYPECONTRAT-mandat2Syndic}
        then do:
            if sys_pg.zone2 <> {&NATURECONTRAT-residenceLocataire}
            then voSyspg:creationttCombo("CMBCATEGORIECONTRAT", trim(sys_pg.zone2), trim(outilTraduction:getLibelleProg(sys_pg.tppar, sys_pg.cdpar)), output table ttCombo by-reference).
        end.
        else voSyspg:creationttCombo("CMBCATEGORIECONTRAT", trim(sys_pg.zone2), trim(outilTraduction:getLibelleProg(sys_pg.tppar, sys_pg.cdpar)), output table ttCombo by-reference).
    
    end.
    delete object voFournisseurLoyer.
    delete object voImmobilierEntreprise.
    delete object voDefautBail.
    delete object voSyspg.

end procedure.
