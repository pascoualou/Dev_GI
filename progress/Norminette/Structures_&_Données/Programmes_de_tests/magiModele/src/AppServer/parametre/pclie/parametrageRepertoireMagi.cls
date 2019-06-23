/*------------------------------------------------------------------------
File        : parametrageRepertoireMagi.cls
Description : Parametrage client: Stockage des Fichiers Joints
Author(s)   : kantena  -  2017/09/29
Notes       : pclstfic.p
------------------------------------------------------------------------*/
using oerealm.magiToken.
block-level on error undo, throw.

class parametre.pclie.parametrageRepertoireMagi inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageRepertoireMagi():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("STFIC").
    end constructor.

    method public character getRepertoireMagi():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon01.
    end method.
    
    method public character getRepertoireDisque():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if MagiToken:mtoken:getValeur("DISQUE") > "" then MagiToken:mtoken:getValeur("DISQUE") else "D:\". 
    end method.

    method public character getRepertoireReseau():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcReseau as character no-undo.

        vcReseau = if valid-object(MagiToken:mtoken) then MagiToken:mtoken:getValeur("RESEAU") else "".
        if vcReseau = ? or vcReseau = ""
        then vcReseau = getRepertoireDisque().

        return vcReseau.
    end method.

    method public character getRepertoireWord():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return substitute('&1&2'
                         , getRepertoireReseau()
                         , if valid-object(MagiToken:mtoken) then MagiToken:mtoken:getValeur("REPWORD") else "").
    end method.

end class.
