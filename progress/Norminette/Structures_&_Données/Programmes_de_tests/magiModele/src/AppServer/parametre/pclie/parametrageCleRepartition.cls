/*------------------------------------------------------------------------
File        : parametrageCleRepartition.cls
Description :
Author(s)   : DM -  12/15/2017
Notes       :
------------------------------------------------------------------------*/
using outils.outilTraduction.
using outils.outils.

block-level on error undo, throw.

class parametre.pclie.parametrageCleRepartition inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    {parametre/cabinet/gestionImmobiliere/include/libelleCleRepartition.i &nomtable=ttLibelleCleRepartition &serialName=ttLibelleCleRepartition}

    constructor public parametrageCleRepartition():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("LBCLE").
    end constructor.

    method public void getLibelleCleRepartition (input pcCodeCle as character, output table ttLibelleCleRepartition):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        empty temp-table ttLibelleCleRepartition.
        for each pclie no-lock 
            where pclie.tppar = tppar 
             and (if pcCodeCle > "" then pclie.zon01 = pcCodeCle else true) :
            create ttLibelleCleRepartition.
            outils:copyValidField(buffer pclie:handle, buffer ttLibelleCleRepartition:handle).
            assign
                ttLibelleCleRepartition.cLibelleNatureCle = outilTraduction:getLibelleParam("TPCLE", ttLibelleCleRepartition.cNatureCle)
                ttLibelleCleRepartition.lActif            = (pclie.fgact = "YES")
            .
        end.
    end method.
end class.
