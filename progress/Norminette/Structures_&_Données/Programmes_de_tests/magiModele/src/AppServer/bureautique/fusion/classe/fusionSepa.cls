/*------------------------------------------------------------------------
File        : fusionSepa.cls
Description : 
Author(s)   : kantena - 2018/01/23
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class bureautique.fusion.classe.fusionSepa: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define property HonoraireCabinet               as character no-undo get. set.
    define property HonoraireLettreCabinet         as character no-undo get. set.
    define property DatePassagePrelSEPACopropriete as character no-undo get. set.
    define property DelaiNotifPrelSEPACopropriete  as character no-undo get. set.
    define property NomReclamPrelSEPACopropriete   as character no-undo get. set.
    define property NomModifPrelSEPACopropriete    as character no-undo get. set.
    define property DatePassagePrelSEPAGerance     as character no-undo get. set.
    define property DelaiNotifPrelSEPAGerance      as character no-undo get. set.
    define property NomReclamPrelSEPAGerance       as character no-undo get. set.
    define property NomModifPrelSEPAGerance        as character no-undo get. set.
    
    constructor public fusionSepa():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
    end constructor.

end class.