/*------------------------------------------------------------------------
File        : parametrageMAD
Purpose     : 
Author(s)   : kantena  -  2017/11/08
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/type2telephone.i}
using outils.outilTraduction.

block-level on error undo, throw.

class parametre.syspr.parametrageMAD inherits parametre.syspr.syspr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}

    constructor public parametrageMAD():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            this-object:tppar     = "MDNET"
            this-object:cNomCombo = "CMBMAD"
        .
    end constructor.

    method public void getComboMAD (output table ttCombo):
        /*------------------------------------------------------------------------------
        Purpose: Cas particulier si colocation, 'Email' Interdit
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        define variable viNumeroItem as integer no-undo.

        for each sys_pr no-lock
            where sys_pr.tppar = this-object:tppar
               by sys_pr.cdpar:
            if sys_pr.cdpar = {&TYPETELEPHONE-mail} then next.
            create ttCombo.
            assign 
                viNumeroItem      = viNumeroItem + 1
                ttcombo.iSeqId    = viNumeroItem            
                ttCombo.cNomCombo = this-object:cNomCombo
                ttCombo.cCode     = sys_pr.cdpar
                ttCombo.cLibelle  = outilTraduction:getLibelle(sys_pr.nome1)
            .
        end.
    end method.

end class.
