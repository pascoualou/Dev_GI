/*------------------------------------------------------------------------
File        : parametragePayePegase.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclPEGAZ.p
derniere revue: 2018/06/01 - phm: KO
        todo à quoi sert iNiveauPaiePegase alors que l'on a un egtNiveau??
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametragePayePegase inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    define public property iNiveauPaiePegase  as integer no-undo get. private set.
    define public property daDebutPegase      as date    no-undo get. private set.
    define public property daFinPegase        as date    no-undo get. private set.
    define public property daFinPaieMaGI      as date    no-undo get. private set.
    define public property lModCptaFinExoBrut as logical no-undo get. private set.

    constructor public parametragePayePegase():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        super("PEGAZ", "00001").  // Pegaz et actif
        assign
            this-object:iNiveauPaiePegase  = this-object:int01
            this-object:lModCptaFinExoBrut = (this-object:int03 = 1)
            this-object:daDebutPegase      = date(this-object:zon02)
        no-error.
        this-object:daFinPegase   = date(this-object:zon03) no-error.
        this-object:daFinPaieMaGI = date(this-object:zon04) no-error.
    end constructor.
    method public logical isActif():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: agence/service
    ------------------------------------------------------------------------------*/
        return this-object:zon01 = "00001".
    end method.
    
    method public int64 getNiveauPegase():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:int01.
    end method.
    
end class.
