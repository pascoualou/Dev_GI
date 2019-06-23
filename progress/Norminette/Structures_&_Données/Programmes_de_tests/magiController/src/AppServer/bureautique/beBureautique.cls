/*------------------------------------------------------------------------
File        : beBureautique.cls
Purpose     :
Author(s)   : kantena - 2018/02/26
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beBureautique.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writedatasetBeforeImage="false").
@progress.service.resource FILE(name="beBureautique", URI="/beBureautique", schemaName="dsbeBureautique", schemaFile="magiController/src/AppServer/menu/include/bureautique.i").

using outils.outilHandle.
using outils.collection.
using oerealm.beMagiToken.

block-level on error undo, throw.

class bureautique.beBureautique:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {bureautique/include/fichier.i}
    {travaux/include/intervention.i}
    {preprocesseur/type2intervention.i}
    
    constructor public beBureautique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void fusion(table ttIntervention, output opcCodeRetour as integer):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        define variable vhProcCourrier as handle no-undo.
     
        vhProcCourrier = outilHandle:connectMaGIModele("bureautique/fusion/courrier.p").
        run createDocIntervention in vhProcCourrier(input table ttIntervention).
        run getErrors in vhProcCourrier(output table ttError).
        {outils/include/tryCatch.i &ligne={&line-number} &bypassErreur=false} // catch erreur et commit possible
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void fusionOrdreDeService(piNumeroOrdre as integer, pcTypeFichier as character, output table ttFichier, output opcCodeRetour as integer):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        define variable vhProcCourrier as handle no-undo.

        vhProcCourrier = outilHandle:connectMaGIModele("bureautique/fusion/courrier.p").
        run createDocIntervention in vhProcCourrier({&TYPEINTERVENTION-ordre2service}, piNumeroOrdre, pcTypeFichier, output table ttFichier).
        run getErrors in vhProcCourrier(output table ttError).
        {outils/include/tryCatch.i &ligne={&line-number} &bypassErreur=false} // catch erreur et commit possible
    end method.

    destructor public beBureautique( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
