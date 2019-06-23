/*------------------------------------------------------------------------
File        : parametrageChaineTravaux.cls
Description : 
Author(s)   : kantena  -  2017/09/29
Notes       : pclcdtrv.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageChaineTravaux inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageChaineTravaux():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDTRV").
    end constructor.
    method override public void create():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: zon02, zon03: objet du contrat, zon04: Numero contrat
        ------------------------------------------------------------------------------*/
        assign
            this-object:tppar = "CDTRV"
            this-object:zon01 = if this-object:zon01 > "" then this-object:zon01 else "00001"
            this-object:zon02 = if this-object:zon02 > "" then this-object:zon02 else "00002"
            this-object:zon03 = if this-object:zon03 > "" then this-object:zon03 else "00002"
            this-object:zon04 = if this-object:zon04 > "" then this-object:zon04 else "00002"
            this-object:zon05 = if this-object:zon05 > "" then this-object:zon05 else "00001"
            this-object:zon06 = if this-object:zon06 > "" then this-object:zon06 else "00002"
            this-object:zon07 = if this-object:zon07 > "" then this-object:zon07 else "00002|00002|00002|00002|"
            this-object:fgact = if this-object:fgact > "" then this-object:fgact else "yes"
        .
        super:create().
    end method.

    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon01 = "00001".
    end method.
    method public logical isFactureHonoraire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon06 = "00001".
    end method.
    method public logical isPrixUnitaire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return entry(1, this-object:zon07, '|') = "00001".
    end method.
    method public logical isPlafond():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return num-entries(this-object:zon07, "|") >= 2 and entry(2, this-object:zon07, "|") = "00001".
    end method.
    method public logical isGestionDelegation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return num-entries(this-object:zon07, '|') >= 3 and entry(3, this-object:zon07, '|') = "00001".
    end method.
    method public logical isGestionFusion():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return num-entries(this-object:zon07, '|') >= 4 and entry(4, this-object:zon07, '|') = "00001".
    end method.
end class.
