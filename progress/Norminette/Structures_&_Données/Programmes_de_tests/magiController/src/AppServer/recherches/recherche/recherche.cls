/*------------------------------------------------------------------------
File        : recherche.cls
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

class recherches.recherche.recherche:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/error.i}

    constructor public recherche():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void rechercheEtendue(pcCritere as character, pcFilter as longchar, output dataset-handle phDataset):
        /*------------------------------------------------------------------------------
        Purpose: recherche etendue à immeuble, lot et intervention
        Notes  : en cas de rajout, ne pas oublier la variable vcRepertoire
        ------------------------------------------------------------------------------*/
        define variable voObject     as Progress.Lang.Object no-undo.
        define variable vcClassName  as character no-undo.
        define variable viCpt        as integer   no-undo.
        define variable vcRepertoire as character no-undo initial 'compta,immeubleEtLot,travaux/intervention,commercialisation,travaux/dossierTravaux,mandat/gerance,tiers'.
        define variable vcItem       as character no-undo.

        do viCpt = 1 to num-entries(vcRepertoire):
            vcItem = entry(viCpt, vcRepertoire, ',').
            if search(substitute('&1/be&2.r', vcItem, pcCritere)) > ''
            then do:
                vcClassName = substitute('&1.be&2', replace(vcItem, '/', '.'), pcCritere).
                leave.
            end.
        end.
        // Permet de désactiver le ménage intensif lors du destructeur de l'objet appelé. Sinon, détruit aussi l'environnement courant!
        voObject = dynamic-new vcClassName().
        dynamic-property(voObject, "selfDestroy") = false no-error.
        dynamic-invoke(voObject, "recherche" + pcCritere, pcFilter, output dataset-handle phDataset).
        {outils/include/tryCatch.i}
    end method.

    destructor public recherche():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle(). 
    end destructor.

end class.
