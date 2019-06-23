/*------------------------------------------------------------------------
File        : hello.cls
Purpose     : Une seule méthode readhello
Author(s)   : kantena - 2016/05/06
Notes       : Renvoie la chaîne HELLO si déjà connecté.
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="hello.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").

block-level on error undo, throw.

class application.hello:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readhello(pcFiltre as character, output pcHello as character):
        /*------------------------------------------------------------------------------
        Purpose: Renvoie la chaîne HELLO si déjà connecté.
        Notes  :
        ------------------------------------------------------------------------------*/
        pcHello = if valid-handle(session:current-request-info:getClientPrincipal()) then "HELLO" else "".
        delete object this-object.
    end method.

end class.
