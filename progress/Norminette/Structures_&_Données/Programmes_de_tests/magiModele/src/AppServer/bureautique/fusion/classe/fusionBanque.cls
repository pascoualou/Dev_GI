/*------------------------------------------------------------------------
File        : fusionBanque.cls
Description : 
Author(s)   : kantena - 2018/01/23
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class bureautique.fusion.classe.fusionBanque: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define property BanqueCabinet           as character no-undo get. set.
    define property NoCompteBancaireCabinet as character no-undo get. set.
    define property HonoraireCabinet        as character no-undo get. set.
    define property HonoraireLettreCabinet  as character no-undo get. set.
    define property Banque-Domiciliation    as character no-undo get. set.
    define property Banque-Titulaire        as character no-undo get. set.
    define property Banque-IBAN             as character no-undo get. set.
    define property Banque-BIC              as character no-undo get. set.

    constructor public fusionBanque():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/

    end constructor.

end class.