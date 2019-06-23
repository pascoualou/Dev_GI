/*------------------------------------------------------------------------
File        : parametrageMutation.cls
Description :
Author(s)   : GGA  -  2018/02/05
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageMutation inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageMutation ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("MUTAG").
    end constructor.    
    method public logical MutationGeranceDepuisCoproAutorise ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        if isDbParameter
        then return zon01 = "00001".
        else return false.
    end method.
    method public void updateParamMutation (plMutationGeranceDepuisCoproAutorise as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            zon01 = string(plMutationGeranceDepuisCoproAutorise,"00001/00002")
            fgact = "YES"
        .
        super:update().
    end method.   
    method public void createParamMutation (plMutationGeranceDepuisCoproAutorise as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            tppar = "MUTAG"
            zon01 = string(plMutationGeranceDepuisCoproAutorise,"00001/00002")
            fgact = "YES"
        .
        super:create().
    end method.         
end class.
