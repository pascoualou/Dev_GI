/*------------------------------------------------------------------------
File        : parametrageCategorieImmeuble.cls
Description : un enregistrement pour chaque code immeuble concerné.
Author(s)   : kantena  -  2017/09/29
Notes       : pclctimm.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageCategorieImmeuble inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageCategorieImmeuble():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CTIMM").
    end constructor.
    constructor public parametrageCategorieImmeuble(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CTIMM", pcZon01).
    end constructor.

end class.
