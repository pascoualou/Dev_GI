/*------------------------------------------------------------------------
File        : tiersMultiple.cls
Purpose     : 
Author(s)   : kantena - 2018/01/17
Notes       : 
------------------------------------------------------------------------*/
using tiers.classe.tiersPrincipal.
using tiers.classe.tiersSecondaire.
using tiers.classe.tiersCareOf.
using tiers.classe.tiersContact.
using outils.outilTraduction.
block-level on error undo, throw.

class tiers.classe.tiersMultiple: 

    define public property tiersPrincipal  as class tiersPrincipal  no-undo get. set.
    define public property tiersSecondaire as class tiersSecondaire no-undo get. set.
    define public property tiersCareOf     as class tiersCareOf     no-undo get. set.
    define public property tiersContact    as class tiersContact    no-undo get. set.

    constructor public tiersMultiple(piNumeroTiers as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            tiersPrincipal  = new tiersPrincipal (piNumeroTiers)
            tiersSecondaire = new tiersSecondaire(piNumeroTiers)
            tiersCareOf     = new tiersCareOf    (piNumeroTiers)
            tiersContact    = new tiersContact   (piNumeroTiers)
        .
    end constructor.

end class.
