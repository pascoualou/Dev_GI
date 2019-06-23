/*------------------------------------------------------------------------
File        : beCritere2Recherche.cls
Purpose     :
Author(s)   : kantena - 2016/03/01
Notes       : 
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/

@program FILE(name="beRechercheIntervention.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beRechercheIntervention", URI="/beRechercheIntervention", schemaName="dsbeRechInter", schemaFile="magiController/src/AppServer/recherches/include/rechercheIntervention.i").

using outils.outilHandle.

block-level on error undo, throw.

class recherches.recherche.beCritere2Recherche:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/error.i}
    define temp-table ttDummy no-undo field cDummy as character.
    define dataset dsbeCritere for ttDummy.

    constructor public beCritere2Recherche():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void readbeCritere2Recherche(pcCritere as character, output pcFiltre as longchar):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("recherches/recherche/critere2recherche.p").
        run getPreferenceJson in vhProc("R", pcCritere, output pcFiltre) no-error.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeCritere2Recherche(pcCritere as character, input-output pcFiltre as longchar): 
        /*------------------------------------------------------------------------------
        Purpose: Update
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("recherches/recherche/critere2Recherche.p").
        run setPreferenceJson in vhProc("R", false, pcCritere, input-output pcFiltre).
        {outils/include/tryCatch.i}
    end method.

    destructor public beCritere2Recherche():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle(). 
    end destructor.

end class.
