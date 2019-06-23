/*------------------------------------------------------------------------
File        : parametrageCorrespondance.cls
Description : 
Author(s)   : gga  -  2017/12/11
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageCorrespondance inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageCorrespondance(pcZon01 as character, pcZon02 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        super("PGCOR", pcZon01, pcZon02).
    end constructor.
    
    constructor public parametrageCorrespondance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        super("PGCOR").
    end constructor.
    
    method public character getCollGi ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon05.
    end method.
    method public character getCompteFournisseur ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon06.
    end method.
    method public character getNomOrganisme ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon07.
    end method.
    method public character getAdresseOrganisme ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
         return substitute('&1 &2', trim(zon08), trim(zon09)).
    end method.
    method public character getNomCentre (pcCollCle as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcNomcentre as character no-undo.
        define buffer pclie for pclie.
        boucle:
        for each pclie no-lock
           where pclie.tppar = tppar
             and pclie.zon01 = zon01
             and pclie.zon02 = zon02
             and pclie.zon05 = (if pcCollCle > "" then pcCollCle else pclie.zon05):
            vcNomcentre = pclie.zon07.
            if pclie.zon06 > "" then leave boucle.
        end.
        return vcNomcentre.
    end method.
    
    method public int64 getTypeDucs():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return int01.
    end method.

    method override public void reload(pczon01 as character, pczon02 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        reload("PGCOR", pczon01, pczon02).
    end method.
    

end class.
