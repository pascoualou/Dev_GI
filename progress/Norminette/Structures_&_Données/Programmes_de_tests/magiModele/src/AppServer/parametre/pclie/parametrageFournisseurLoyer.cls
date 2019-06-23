/*------------------------------------------------------------------------
File        : parametrageFournisseurLoyer.cls
Description : Mise a jour du code Gestion des fournisseurs loyer
Author(s)   : kantena  -  2017/09/29
Notes       : pclgesfl.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageFournisseurLoyer inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageFournisseurLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("GESFL").
    end constructor.
    constructor public parametrageFournisseurLoyer(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("GESFL", pczon01).
    end constructor.

    method public logical isGesFournisseurLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon01 = "00001".
    end method.
    method public integer getNumeroMandant():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        integer(this-object:zon02) no-error.
        if not error-status:error then return integer(this-object:zon02).
        error-status:error = false no-error.
        return 0.
    end method.
    method public character getCodeModele():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : valeur par défaut Réside Etude: "00001"
        ------------------------------------------------------------------------------*/
        return if this-object:zon03 > "" then trim(this-object:zon03) else "00001".
    end method.
    method public integer getImmeubleDebut():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        integer(this-object:zon04) no-error.
        if not error-status:error and this-object:zon04 > "" then return integer(this-object:zon04).
        error-status:error = false no-error.
        return 1.
    end method.

    method public integer getImmeubleFin():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable viFin as integer no-undo.

        /* Cas particulier: Sous-location déléguée (pour sauter la tranche des mandats sous-location déléguée */
        if this-object:zon03 = "00004" and this-object:int04 > 0 then return integer(this-object:int04).

        viFin = integer(this-object:zon05) no-error.
        error-status:error = false no-error.
        return if viFin > 0 then viFin else 200.

    end method.

    method public integer getFournisseurLoyerDebut():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : valeur par défaut Réside Etude: 8001
        ------------------------------------------------------------------------------*/
        integer(this-object:zon06) no-error.
        if not error-status:error
        then return if this-object:zon06 > "" then integer(this-object:zon06) else 8001.
        error-status:error = false no-error.
        return 8001.
    end method.
    method public integer getFournisseurLoyerFin():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : valeur par défaut Réside Etude: 8200
        ------------------------------------------------------------------------------*/
        integer(this-object:zon07) no-error.
        if not error-status:error
        then return if this-object:zon07 > "" then integer(this-object:zon07) else 8200.
        error-status:error = false no-error.
        return 8200.
    end method.
    method public integer getNombreMoisQuittance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : valeur par défaut Réside Etudes: 3
        ------------------------------------------------------------------------------*/
        if this-object:isDbParameter
        then return if this-object:zon08 = "00001" then 1 else 3.      // Quitt FL mensuel
        return 3.                                                      // défaut 3
    end method.
    method public logical isQuittanceMensuel():
        /*------------------------------------------------------------------------------
        Purpose: Quittancement FL Mensuel
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon08 = "00001".
    end method.
    method public logical isComptabilisationEchu():
        /*------------------------------------------------------------------------------
        Purpose: comptabilisation des echus dans le mois precedent 
        Notes:
        ------------------------------------------------------------------------------*/
        return not this-object:isDbParameter or this-object:zon01 = "00001".
    end method.
    method public integer getNumeroMandantSousLocDelegue():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : 
        ------------------------------------------------------------------------------*/
        if this-object:isDbParameter
        then return integer(this-object:int05).
    end method.
    method public integer getDebutSLD():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : 
        ------------------------------------------------------------------------------*/
        if this-object:isDbParameter
        then return integer(this-object:int03).
    end method.
    method public integer getIncrementSLDeleguee():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : 
        ------------------------------------------------------------------------------*/
message "getIncrementSLDeleguee " getCodeModele() "// " getDebutSLD().        
        
        if getCodeModele() = "00004"
        then return getDebutSLD() - 1.
        return 0. 
    end method.
end class.
