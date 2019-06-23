/*-----------------------------------------------------------------------------
File        : parametrageDossierLocataire
Syntax      : 
Author(s)   : npo - 2017/10/26
Notes       : pcldoloc.p
derniere revue: 2018/03/20 - phm
-----------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageDossierLocataire inherits parametre.pclie.pclie:

    constructor public parametrageDossierLocataire():
    /*------------------------------------------------------------------------------
    Purpose:                                                                      
    Notes:                                                                        
    ------------------------------------------------------------------------------*/
        super("DOLOC").
    end constructor.

    method public integer getNombrePieces():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:  Donne le nombre de pièces à fournir
        ------------------------------------------------------------------------------*/
        return integer(int01).
    end method.

    method public character getListePiecesObligatoires(pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:  Liste des flag pour les pièces fournies (oui="00001", non="00002")
        ------------------------------------------------------------------------------*/
        if pcTypeContrat = "HAB"      then return zon05.
        else if pcTypeContrat = "COM" then return zon06.
        else return zon04.
    end method.

end class.
