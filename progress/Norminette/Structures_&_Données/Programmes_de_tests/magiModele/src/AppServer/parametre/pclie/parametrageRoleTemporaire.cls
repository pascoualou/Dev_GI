/*------------------------------------------------------------------------
File        : parametrageRoleTemporaire.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageRoleTemporaire inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageRoleTemporaire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("TMROL").
    end constructor.
    constructor public parametrageRoleTemporaire(pcZon01 as character, pcZon02 as character, pcZon03 as character, plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: pcZon01=pcTypeContrat, pcZon02=pcNatureContrat, pcZon03=pcTypeRole
        ------------------------------------------------------------------------------*/
        super("TMROL", pcZon01, pcZon02, pcZon03, plActif).
    end constructor.
    method public void reload(pcZon01 as character, pcZon02 as character, pcZon03 as character, plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        reload("TMROL", pcZon01, pcZon02, pcZon03, plActif).
    end method.
    method public integer getNumeroRole():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        integer(zon04) no-error.
        if not error-status:error then return integer(zon04).
        error-status:error = false no-error.
        return 0.
    end method.
    
    method public integer getSyndicatParDefaut(pcTypeRole as character, pcTypeContrat as character, pcNatureContrat as character):
        /*------------------------------------------------------------------------------
        Purpose: recherche role syndicat par defaut en fonction type contrat, nature contrat, type role
        Notes  : anciennement lecTmRol.
        ------------------------------------------------------------------------------*/
        define variable viNumeroRole as integer no-undo.

        if pcNatureContrat <> ? and pcTypeContrat <> ?              // Recherche d'un defaut pour ce type de role cette nature et ce type de contrat
        then reload(pcTypeContrat, pcNatureContrat, pcTypeRole, true).
        if pcTypeContrat <> ? and not isDbParameter    // Recherche d'un defaut pour ce type de role ce type de contrat
        then reload(pcTypeContrat, "00000", pcTypeRole, true).
        if not isDbParameter                           // Recherche d'un defaut pour ce type de role
        then reload("00000", "00000", pcTypeRole, true).
        if isDbParameter
        then assign
                viNumeroRole = getNumeroRole()
            .
        return viNumeroRole.
    end method.

end class.
