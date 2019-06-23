/*------------------------------------------------------------------------
File        : fusionHonoraire.cls
Description : 
Author(s)   : kantena - 2018/01/23
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.
class bureautique.fusion.classe.fusionHonoraire: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define property HonoraireCabinet        as character no-undo get. set.
    define property HonoraireLettreCabinet  as character no-undo get. set.
    
    constructor public fusionHonoraire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
    end constructor.

end class.