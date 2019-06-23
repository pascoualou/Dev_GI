/*------------------------------------------------------------------------
File        : parametrageAgenceService.cls
Description : Gestion des Agences
Author(s)   : kantena  -  2017/09/29
Notes       : pclcdage.p
------------------------------------------------------------------------*/
using outils.outilTraduction.

class parametre.pclie.parametrageAgenceService inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageAgenceService():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDAGE").
    end constructor.
    method public logical isGestActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon02 > "" and zon02 <> "00002".
    end method.
    
    method public character getLibelleGestionnaire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        if zon02 > "" then return zon02.
        return outilTraduction:getLibelle(701790).
    end method.
    method public logical isParametrageAgence():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon03 = "00001".
    end method.
    method public logical isFiltrageImmeuble():
        /*------------------------------------------------------------------------------
        Purpose: Paramétrage client filtrage ou non des immeubles par Agence
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return zon05 = "00001".
    end method.
    method public logical isVisibleListeAgence():
        /*------------------------------------------------------------------------------
        Purpose: Paramétrage client filtrage ou non des immeubles par Agence
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return entry(1, zon04, "¤") = "00001" or (num-entries(zon04, "¤") >= 2 and entry(2, zon04, "¤") = "00001").
    end method.
    method override public void create():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            tppar = "CDAGE"
            zon01 = if zon01 > "" then zon01 else "00001"
            zon02 = if zon02 > "" then zon02 else outilTraduction:getLibelle(701790)
            zon03 = if zon03 > "" then zon03 else string(true)
            zon04 = if zon04 > "" then zon04 else "00002¤00002"
            fgact = if fgact > "" then fgact else "yes"
        .
        super:create().
    end method.

end class.
