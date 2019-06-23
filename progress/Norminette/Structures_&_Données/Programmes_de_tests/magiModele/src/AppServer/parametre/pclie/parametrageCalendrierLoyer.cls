/*------------------------------------------------------------------------
File        : parametrageCalendrierLoyer.cls
Description :
Author(s)   : DM -  12/15/2017
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.

class parametre.pclie.parametrageCalendrierLoyer inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageCalendrierLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CALOY").
    end constructor.

    method public logical isCalendrierEvolution():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon02 = "00001".
    end method.
    method public logical isIndexationParDefaut():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon01 = "00001".
    end method.
    method public logical isSeulementCalendrie1erBail():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon03 = "00001".
    end method.
    method public character getNaturesBailAutorise():
        /*------------------------------------------------------------------------------
        Purpose: si retourne ? qui est une erreur,
        Notes:  Anomalie d'installation. La moulinette 01070373.p n'a pas été passée. Veuillez contacter la Gestion Intégrale.
        ------------------------------------------------------------------------------*/
        return if this-object:isDbParameter then this-object:zon05 else "".
    end method.

end class.


