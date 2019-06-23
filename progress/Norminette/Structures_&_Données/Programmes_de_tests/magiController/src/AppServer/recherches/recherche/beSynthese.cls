/*------------------------------------------------------------------------
File        : beSynthese
Syntax      : 
Author(s)   : devweb1 - 2017/08/08
Notes       : 
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
  
@program FILE(name="beSynthese.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beSynthese", URI="/beSynthese", schemaName="dsbeSynthese", schemaFile="").

using outils.outilHandle.
block-level on error undo, throw.

class recherches.recherche.beSynthese:
    {application/include/error.i}
    
    constructor public beSynthese():
        /*------------------------------------------------------------------------------
        Purpose:                                                                      
        Notes:                                                                        
        ------------------------------------------------------------------------------*/
    end constructor.
        
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void ReadbeSynthese(input pcCritere as character, output pcSynthese as longchar):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a filter string                                                                     
        Notes:                                                                        
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("recherches/recherche/critere2recherche.p").
        run getPreferenceJson in vhProc("S", pcCritere, output pcSynthese) no-error.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeSynhese(pcCritere as character, input-output pcSynthese as longchar): 
        /*------------------------------------------------------------------------------
        Purpose: Update
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("recherches/recherche/critere2Recherche.p").
        run setPreferenceJson in vhProc("S", false, pcCritere, input-output pcSynthese).
        {outils/include/tryCatch.i}
    end method.    
      
    destructor public beSynthese():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle(). 
    end destructor.
    
end class.
