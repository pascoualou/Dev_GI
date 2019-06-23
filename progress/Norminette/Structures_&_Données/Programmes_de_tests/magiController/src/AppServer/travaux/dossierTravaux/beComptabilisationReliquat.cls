/*------------------------------------------------------------------------
File        : beComptabilisationReliquat.cls
Purpose     :
Author(s)   : gga - 2017/05/17
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/

@program FILE(name="beComptabilisationReliquat.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beComptabilisationReliquat", URI="/beComptabilisationReliquat", schemaName="dsbeComptabilisationReliquat", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.dossierTravaux.beComptabilisationReliquat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: selfDestroy est positionné à faux par la classe qui aura instancié cette classe.
           Sinon, le destructeur de classe fait un 'ménage' intensif et détruit aussi l'appelant!!
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.    
    define public  property selfDestroy as logical no-undo initial true private get. public set.
    
    {travaux/include/ComptabilisationReliquat.i}
    {application/include/error.i}
    define dataset dsbeComptabilisationReliquat for ttComptabilisationReliquat, ttError.

    constructor public beComptabilisationReliquat():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeComptabilisationReliquat(pcFiltre as longchar, input-output dataset dsbeComptabilisationReliquat):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('cTypeMandat',   vhBuffer::cTypeMandat) no-error.
                goCollection:set('iNumeroMandat', integer(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('cNoRefUse',     vhBuffer::cNoRefUse) no-error.                
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("compta/souspgm/comptabilisationReliquat.p").
        run validation in vhProc(goCollection, table ttComptabilisationReliquat).
        dataset dsbeComptabilisationReliquat:empty-dataset().
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beComptabilisationReliquat ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
