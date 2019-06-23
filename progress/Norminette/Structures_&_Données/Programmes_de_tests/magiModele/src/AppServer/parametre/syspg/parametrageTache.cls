/*------------------------------------------------------------------------
File        : parametrageTache.cls
Purpose     : 
Author(s)   : GGA  -  2017/11/08
Notes       : 
------------------------------------------------------------------------*/

using outils.outilTraduction.

block-level on error undo, throw.

class parametre.syspg.parametrageTache inherits parametre.syspg.syspg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}
    {preprocesseur/nature2contrat.i}

    constructor public parametrageTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        this-object:tppar = "R_CTA".
    end constructor.

    method public logical tacheObligatoire (piNumeroMandat as int64, pcTypeMandat as character, pcTypeTache as character):
        /*------------------------------------------------------------------------------
         Purpose: Retourne si la tâche est obligatoire ou non
         Notes  : 
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.
        define buffer ctrat  for ctrat.
        for first ctrat no-lock
            where ctrat.tpcon = pcTypeMandat
              and ctrat.nocon = piNumeroMandat
          , first sys_pg no-lock
            where sys_pg.tppar = this-object:tppar
              and sys_pg.zone1 = ctrat.ntcon
              and sys_pg.zone2 = pcTypeTache
              and sys_pg.maxim = 1
              and sys_pg.maxim = sys_pg.minim:
            return yes.
        end.
        return no.
    end method.

    method public void delLienPrestationMandat (piNumeroMandat as int64, pcTypeMandat as character):
        /*------------------------------------------------------------------------------
         Purpose: Suppression des liens taches prestation-mandat (Imputations particulieres...)
         Notes  : extrait de adb/tach/prmobchl.p procedure SupTblCtt
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.
        define buffer cttac  for cttac.
        for each sys_pg no-lock
           where sys_pg.tppar = this-object:tppar
             and (sys_pg.zone1 = {&NATURECONTRAT-chargeLocative} or sys_pg.zone1 = {&NATURECONTRAT-chargeChauffage}) //nature contrat
        , each cttac exclusive-lock
         where cttac.tpcon = pcTypeMandat
           and cttac.nocon = piNumeroMandat
           and cttac.tptac = sys_pg.zone2
        by sys_pg.zone2:
            delete cttac.
        end.        
    end method.
end class.
