/*------------------------------------------------------------------------
File        : parametreUniteSurface.cls
Purpose     : 
Author(s)   : KANTENA - 2018/01/29
Notes       : 
------------------------------------------------------------------------*/
using outils.outilTraduction.

block-level on error undo, throw.

class parametre.syspr.parametrageUniteSurface inherits parametre.syspr.syspr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property libelleUnite1 as character no-undo get. set.
    define private property libelleUnite2 as character no-undo get. set.
    define private property libelleUnite3 as character no-undo get. set.

    constructor public parametrageUniteSurface(pcCodeSurface as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("UTSUR", pcCodeSurface).
        formateZoneSurface(pcCodeSurface).
    end constructor.

    method public void formateZoneSurface (pcCodeSurface as character):
        /*-------------------------------------------------------------------------
        Purpose : formate une surface
        Notes   : utilisee par bureautique/fusion/immeuble.p
        -------------------------------------------------------------------------*/
        if num-entries(this-object:zone2) = 2
        then assign
            this-object:libelleUnite1 = outilTraduction:getLibelleParam("UTSUR", entry(1, this-object:zone2), "L")
            this-object:libelleUnite2 = outilTraduction:getLibelleParam("UTSUR", entry(2, this-object:zone2), "L").
        else if num-entries(this-object:zone2) = 1 
             then assign libelleUnite2 = outilTraduction:getLibelleParam("UTSUR", entry(1, this-object:zone2), "L").
        this-object:libelleUnite3 = outilTraduction:getLibelleParam("UTSUR", pcCodeSurface, "L").

    end method.

    method public character getLibelleUnite1():
        /*-------------------------------------------------------------------------
        Purpose : 
        Notes   : 
        -------------------------------------------------------------------------*/
        return this-object:libelleUnite1.
    end method.

    method public character getLibelleUnite2():
        /*-------------------------------------------------------------------------
        Purpose : 
        Notes   : 
        -------------------------------------------------------------------------*/
        return this-object:libelleUnite2.

    end method.
    
    method public character getLibelleUnite3():
        /*-------------------------------------------------------------------------
        Purpose : 
        Notes   : 
        -------------------------------------------------------------------------*/
        return this-object:libelleUnite3.

    end method.

end class.
