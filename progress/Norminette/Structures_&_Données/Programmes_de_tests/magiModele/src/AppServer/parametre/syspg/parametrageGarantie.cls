/*------------------------------------------------------------------------
File        : parametrageGarantie.cls
Purpose     : 
Author(s)   : GGA  -  2018/03/01
Notes       : 
------------------------------------------------------------------------*/

using outils.outilTraduction.

block-level on error undo, throw.

class parametre.syspg.parametrageGarantie inherits parametre.syspg.syspg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define public property ghttTable as handle no-undo get. set.

    define temp-table ttGarantie no-undo
           field cCodeTypeGarantie as character
    .

    constructor public parametrageGarantie():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        this-object:tppar = "R_CTI".
    end constructor.

    method public void listeGarantie (pcNatureContrat as character, output pcCode as character, output pclibelle as character):
        /*------------------------------------------------------------------------------
         Purpose: 
         Notes  : 
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.
        for each sys_pg no-lock
        where sys_pg.tppar = this-object:tppar
        and sys_pg.zone1 = pcNatureContrat:
            assign 
                pcCode    = pcCode    + trim(sys_pg.zone2)                                     + '@'  
                pclibelle = pclibelle + trim(outilTraduction:getLibelle(string(sys_pg.noMe2))) + '@'
            .
        end. 
        assign
            pcCode    = trim(pcCode, '@')
            pclibelle = trim(pclibelle, '@')
        .
    end method.
end class.
