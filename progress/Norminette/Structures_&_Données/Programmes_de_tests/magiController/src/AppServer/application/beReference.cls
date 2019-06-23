/*------------------------------------------------------------------------
File        : beReference.cls
Purpose     : 
Author(s)   : kantena - 2017/12/15
Notes       : 
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beReference.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").

using oerealm.Util.Properties.
block-level on error undo, throw.

class application.beReference: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define private variable goSpaProps as class Properties no-undo.
    define variable glRefPrincipale as character no-undo.
    define variable glRefGerance    as character no-undo.
    define variable glRefCopro      as character no-undo.

    define temp-table ttReference serialize-name "reference"
        field cRefPrincipale as character
        field cRefGerance    as character
        field cRefCopro      as character
    .

    constructor public beReference():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super ().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void readBeReference(output pcReference as longchar):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        create ttReference.
        assign 
            goSpaProps                 = new Properties("spaservice.properties")
            ttReference.cRefPrincipale = goSpaProps:GetCharacterProperty("CodeRefPrincipale", "")
            ttReference.cRefGerance    = goSpaProps:GetCharacterProperty("CodeRefGerance", "")
            ttReference.cRefCopro      = goSpaProps:GetCharacterProperty("CodeRefCopro", "")
        . 
        temp-table ttReference:write-json("LONGCHAR", pcReference, false, ?, true, false, false).
    end method.

end class.