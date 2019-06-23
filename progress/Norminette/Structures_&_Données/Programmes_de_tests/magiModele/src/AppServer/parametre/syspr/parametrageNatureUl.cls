/*------------------------------------------------------------------------
File        : parametrageNatureUl
Purpose     : 
Author(s)   : GGA  -  2018/09/10
Notes       : 
------------------------------------------------------------------------*/
using outils.outilTraduction.

block-level on error undo, throw.

class parametre.syspr.parametrageNatureUl inherits parametre.syspr.syspr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}

    constructor public parametrageNatureUl():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        this-object:tppar = "NTAPP".
    end constructor.

    method public character getNatureParUl (piZone1 as decimal, pcZone2 as character):
        /*------------------------------------------------------------------------------
        Purpose: Cas particulier si colocation, 'Email' Interdit
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        for first sys_pr no-lock
            where sys_pr.tppar = this-object:tppar
              and (sys_pr.zone1 = piZone1 or piZone1 = 0)
              and (sys_pr.zone2 = pcZone2 or pcZone2 = ""):
            return trim(sys_pr.cdpar).
        end.
        return "".

    end method.

end class.
