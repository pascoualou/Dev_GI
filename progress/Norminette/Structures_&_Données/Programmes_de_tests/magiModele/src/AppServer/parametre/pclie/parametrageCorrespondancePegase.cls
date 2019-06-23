/*------------------------------------------------------------------------
File        : parametrageCorrespondancePegasePegase.cls
Description : 
Author(s)   : gga  -  2017/12/11
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageCorrespondancePegase inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageCorrespondancePegase(pcZon04 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        super("PGCPT", "", "", "", pcZon04).
    end constructor.
    method public character getCptSalPegase ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if zon02 > "" 
        then return zon02 + fill("X", 9 - length(zon02)).
        else return "".
    end method.
    method public character getCptPatPegase ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if zon03 > "" 
        then return zon03 + fill("X", 9 - length(zon03)).
        else return "".
    end method.
        
end class.
