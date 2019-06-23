/*------------------------------------------------------------------------
File        : parametrageChargeLocative.cls
Description : 
Author(s)   : gga  -  2017/12/21
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageChargeLocative inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageChargeLocative():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        super("TRCHL").
    end constructor.
    method public character getCodeCritereExtractionPeriodeChargeLocative():
        /*------------------------------------------------------------------------------
        Purpose: Critères d'extraction des périodes de charges locatives en demande de tirage
        Notes  : code associé au paramètre sys_pr TRCHL
        ------------------------------------------------------------------------------*/
        return if this-object:zon01 > "" then trim(this-object:zon01) else "00001".     // par défaut limitée aux périodes complètement terminées
    end method.        
    method public character getCodeCritereExtractionRubriqueChargeLocative():
        /*------------------------------------------------------------------------------
        Purpose: Critères d'extraction des rubriques de provisions/consommations quittancées
        Notes  : code associé au paramètre sys_pr TRCH2
        ------------------------------------------------------------------------------*/
        return if this-object:zon02 > "" then trim(this-object:zon02) else "00001".     // par défaut Quittances dont les dates sont incluses dans la période de charges (Standard)
    end method.    
    method public character getPresentationChargeLocative ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon03.
    end method.
    method public logical IsChargeLocativeSurULVacante():
        /*------------------------------------------------------------------------------
        Purpose: Gestion des charges locatives sur UL vacantes (= bail de rang 00 nature "03094")
        Notes  : 
        ------------------------------------------------------------------------------*/
        return this-object:zon07 = "00001".
    end method.    
    method public character getPresentationEtatDepense ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon08.
    end method.

end class.
