/*------------------------------------------------------------------------
File        : parametrageLibelleMoyen.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pcltellb.p
------------------------------------------------------------------------*/
using outils.outilTraduction.
block-level on error undo, throw.

class parametre.pclie.parametrageLibelleMoyen inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    define public property ghttTable     as handle  no-undo get. set.

 define temp-table ttTypesCodesTelephones no-undo
    field cType        as character
    field cLibelleType as character
    field cCode        as character
    field cLibelleCode as character
    field lGI          as logical
    field cLibelleGI   as character
.

    constructor public parametrageLibelleMoyen():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("TELLB").
        ghttTable = temp-table ttTypesCodesTelephones:handle.
    end constructor.
    constructor public parametrageLibelleMoyen(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("TELLB", pcZon01).
        ghttTable = temp-table ttTypesCodesTelephones:handle.
    end constructor.

    method public character getTelephone():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:zon01 <> "00000" then this-object:zon02 else "-".
    end method.

    method public void chargeTypesCodesTelephones(output table-handle phttTable):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        empty temp-table ttTypesCodesTelephones.
        for each pclie no-lock
            where pclie.tppar = "TELLB"
            by pclie.int02:
            create ttTypesCodesTelephones.
            assign
                ttTypesCodesTelephones.cType        = pclie.zon03
                ttTypesCodesTelephones.cCode        = pclie.zon01
                ttTypesCodesTelephones.lGI          = (pclie.int02 = 0)
                ttTypesCodesTelephones.cLibelleGI   = string(ttTypesCodesTelephones.lGI, "Oui/Non")    // todo Traduction ???
                ttTypesCodesTelephones.cLibelleType = outilTraduction:getLibelleParam("CDTE2", pclie.zon03)
                ttTypesCodesTelephones.cLibelleCode = if pclie.zon01 <> "00000" then pclie.zon02 else "-"
            .
        end.
        phttTable = ghttTable.
    end method.

end class.
