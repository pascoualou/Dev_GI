/*------------------------------------------------------------------------
File        : parametrageCarnetEntretien.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclctent.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageCarnetEntretien inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}

    constructor public parametrageCarnetEntretien():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CTENT").
    end constructor.
    constructor public parametrageCarnetEntretien(pcZon01 as character, pcZon02 as character, pcZon03 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CTENT", pcZon01, pcZon02, pcZon03).
    end constructor.
    method override public void create():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: zon02, zon03: objet du contrat, zon04: Numero contrat
        ------------------------------------------------------------------------------*/
        assign
            tppar = "CTENT"
            zon01 = if zon01 > "" then zon01 else "00001"
            zon05 = if zon05 > "" then zon05 else "00002#00002" + fill("#", 30)
            zon07 = if zon07 > "" then zon07 else fill("#", 10)
            fgact = if fgact > "" then fgact else "yes"
        .
        super:create().
    end method.

    method public integer getComboParametreCarnet(pcNomCombo as character, pcZon02 as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        return getComboParametre(pcNomCombo, 'and pclie.zon02 = "' + pcZon02 + '"', 'zon03', 'zon04', output table ttCombo by-reference).
    end method.
    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon01 = "00001".
    end method.
    method public character getNatureContrat():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if this-object:isDbParameter then return this-object:zon04.
        return "".
    end method.
    method public integer getColorRed():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        integer(entry(1, this-object:zon06, ",")) no-error.
        if not error-status:error then return integer(entry(1, this-object:zon06, ",")).
        error-status:error = false no-error.
        return 192.
    end method.
    method public integer getColorGreen():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon06, ",") >= 2 then do:
            integer(entry(2, this-object:zon06, ",")) no-error.
            if not error-status:error then return integer(entry(2, this-object:zon06, ",")).
            error-status:error = false no-error.
        end.
        return 192.
    end method.
    method public integer getColorBlue():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon06, ",") >= 3 then do:
            integer(entry(3, this-object:zon06, ",")) no-error.
            if not error-status:error then return integer(entry(3, this-object:zon06, ",")).
            error-status:error = false no-error.
        end.
        return 192.
    end method.
end class.
