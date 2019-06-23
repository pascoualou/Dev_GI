/*------------------------------------------------------------------------
File        : beHeaderFooter.cls
Purpose     : 
Author(s)   : kantena - 2016/06/23
Notes       : 
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beHeaderFooter.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beHeaderFooter", URI="/beHeaderFooter", schemaName="dsbeHeaderFooter", schemaFile="").

using outils.outilHandle.
using outils.collection.
using oerealm.beMagiToken.

block-level on error undo, throw.

class application.beHeaderFooter:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
	define temp-table ttHeaderFooter no-undo
        field userName     as character
        field cleMagi      as character
        field cleNoSesEnc  as character
        field cReference   as character
        field GcVersion    as character
        field dateJour     as date
        field footerStatus as character
        field moisCpta     as character
        field moisQuit     as character
    .
    define dataset dsbeHeaderFooter for ttHeaderFooter.

    constructor public beHeaderFooter():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
        beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readHeader(output dataset dsbeHeaderFooter):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes  :
        ------------------------------------------------------------------------------*/
        dataset dsbeHeaderFooter:empty-dataset().
        create ttHeaderFooter.
        assign 
           ttHeaderFooter.userName     = beMagiToken:mtoken:cUser
           ttHeaderFooter.cleMagi      = "cleMagi"
           ttHeaderFooter.cleNoSesEnc  = "cleNoSesEnc"
           ttHeaderFooter.cReference   = "cReference"
           ttHeaderFooter.GcVersion    = "GcVersion"
           ttHeaderFooter.dateJour     = today
           ttHeaderFooter.footerStatus = ""
           ttHeaderFooter.moisCpta     = ""
           ttHeaderFooter.moisQuit     = ""
        .
        {outils/include/tryCatch.i}
    end method.
	  
	@openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readFooter (output dataset dsbeHeaderFooter):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        dataset dsbeHeaderFooter:empty-dataset().
        create ttHeaderFooter.
        assign 
           ttHeaderFooter.footerStatus = "En cours"
           ttHeaderFooter.moisCpta     = "moisCpta"
           ttHeaderFooter.moisQuit     = "moisQuit"
           ttHeaderFooter.userName     = beMagiToken:mtoken:cUser
        .
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeHeaderFooter(input-output dataset dsbeHeaderFooter):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeHeaderFooter(input-output dataset dsbeHeaderFooter):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeHeaderFooter(input-output dataset dsbeHeaderFooter):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes  :
        ------------------------------------------------------------------------------*/
    end method.

    destructor public beHeaderFooter ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
