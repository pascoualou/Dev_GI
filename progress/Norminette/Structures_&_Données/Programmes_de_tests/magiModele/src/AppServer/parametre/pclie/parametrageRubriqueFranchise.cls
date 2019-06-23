/*------------------------------------------------------------------------
File        : parametrageRubriqueFranchise.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

class parametre.pclie.parametrageRubriqueFranchise inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageRubriqueFranchise():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RBFRA").
    end constructor.
    method public character getRubriquesFranchise():
        /*------------------------------------------------------------------------------
        Purpose: les rubriques Loyer paramétrées pour le calcul de la franchise 1009/0179
        Notes  : Attetion, liste avec ";" !!!
        ------------------------------------------------------------------------------*/
        if this-object:isDbparameter then return this-object:zon01.
        return "101".
    end method.

end class.
