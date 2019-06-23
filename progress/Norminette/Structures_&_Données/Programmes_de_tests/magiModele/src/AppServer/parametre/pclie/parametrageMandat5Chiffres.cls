/*------------------------------------------------------------------------
File        : parametrageActivationEuro.cls
Description : Parametrage Gestion des mandats 5 chiffres
Author(s)   : kantena  -  2017/09/29
Notes       : pclmd5ch.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageMandat5Chiffres inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageMandat5Chiffres():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("MD5CH", "00001").
    end constructor.

end class.
