/*------------------------------------------------------------------------
File        : parametrageUniteReleve.cls
Description : Si le paramètre client Unités d'oeuvre est ouvert, unité pour les relevés Thermies, Gaz, U.E 
Author(s)   : SPo  -  2018/03/30
Notes       :
derniere revue: 2018/04/12 - phm: OK
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageUniteReleve inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageUniteReleve():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDUNI").
    end constructor.
    method public void reload():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload("CDUNI").
    end method.
    method override public void reload(pczon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        reload("CDUNI", pczon01).
    end method.
    method public character getLibelleUnite():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        return this-object:zon02.
    end method.
    method public character getOrigineUnite():
        /*------------------------------------------------------------------------------
        Purpose: si unité standard GI : "GI" sinon blanc (= origine Client) 
        Notes: 
        ------------------------------------------------------------------------------*/
        return this-object:zon04.
    end method.
end class.
