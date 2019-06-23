/*------------------------------------------------------------------------
File        : beMenu.cls
Purpose     :
Author(s)   : kantena - 2016/03/20
Notes       :
------------------------------------------------------------------------*/

@program FILE(name="beMenu.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writedatasetBeforeImage="false").
@progress.service.resource FILE(name="beMenu", URI="/beMenu", schemaName="dsbeMenu", schemaFile="magiController/src/AppServer/menu/include/menu.i").

using outils.outilHandle.
using outils.collection.
using oerealm.beMagiToken.

block-level on error undo, throw.

class menu.beMenu:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {menu/include/menu.i}
    define dataset dsbeMenu for ttMenuNiv0, ttMenuNiv1, ttMenuNiv2
        data-relation relNiv0 for ttMenuNiv0, ttMenuNiv1
            relation-fields (ttMenuNiv0.cid, ttMenuNiv1.cParentid) nested
        data-relation relNiv1 for ttMenuNiv1, ttMenuNiv2 
            relation-fields (ttMenuNiv1.cid, ttMenuNiv2.cParentid) nested
    .

    constructor public beMenu():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void readbeMenu(pcFiltre as character, output dataset dsbeMenu):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProcMenu as handle    no-undo.

        empty temp-table ttMenuNiv0.
        empty temp-table ttMenuNiv1.
        empty temp-table ttMenuNiv2.
        vhProcMenu = outilHandle:connectMaGIModele("menu/menu.p").
        run getMenu   in vhProcMenu(output table ttMenuNiv0, output table ttMenuNiv1, output table ttMenuNiv2).
        run getErrors in vhProcMenu(output table ttError).
        {outils/include/tryCatch.i &ligne={&line-number} &bypassErreur=false} // catch erreur et commit possible
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeMenu(input-output dataset dsbeMenu):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        {outils/include/tryCatch.i &ligne={&line-number} &bypassErreur}     // non prise en compte du catch et commit automatique.
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writedatasetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeMenu(input-output dataset dsbeMenu):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        {outils/include/tryCatch.i &ligne={&line-number} &bypassErreur}     // non prise en compte du catch et commit automatique.
    end method.

    destructor public beMenu( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
