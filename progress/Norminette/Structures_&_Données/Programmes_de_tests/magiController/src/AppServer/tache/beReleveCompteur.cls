/*------------------------------------------------------------------------
File        : beReleveCompteur.cls
Purpose     : Gestion des relevés de compteurs (eau, gaz, électricité, thermie...)
Author(s)   : SPo -2018/06/04 
Notes       : encmtrlv.p/encsyrlv.p/zommtrlv.p/zomsyrlv.p
derniere revue: 2018/04/17 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2compteur.i}

@program FILE(name="beReleveCompteur.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beReleveCompteur", URI="/beReleveCompteur", schemaName="dsbeReleveCompteur", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class tache.beReleveCompteur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    define variable ghProc as handle    no-undo.  // plutôt que définir dans chacune des procédures.
    {application/include/error.i}
    {application/include/combo.i}
    {tache/include/releveDeCompteur.i}  

    define dataset dsbeReleveCompteur for
                   ttReleveDeCompteur,
                   ttLigneReleveDeCompteur,
                   ttCombo, ttError
        data-relation detail for ttReleveDeCompteur, ttLigneReleveDeCompteur nested foreign-key-hidden
            relation-fields (ttReleveDeCompteur.iNumeroIdentifiant, ttLigneReleveDeCompteur.iNumeroIdentifiant )
    .

    constructor public beReleveCompteur():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeReleveCompteur(pcFiltre as longchar, output dataset dsbeReleveCompteur):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable vcTypeContrat   as character no-undo.
        define variable viNumeroContrat as int64     no-undo.
        define variable vcTypeCompteur  as character no-undo.
        define variable vcTypeTrt       as character no-undo.
        define variable viNumeroReleve  as integer   no-undo.
        define variable vcReleveImmBat  as character no-undo.     // relevé au batiment ("BAT") ou tout batiments confondus ("IMM")
        define variable vcCodeBatiment  as character no-undo.     // si "BAT" : code bâtiment        

        dataset dsbeReleveCompteur:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeContrat   = vhBuffer::cTypeContrat   no-error.
                viNumeroContrat = vhBuffer::iNumeroContrat no-error.
                vcTypeCompteur  = vhBuffer::cTypeCompteur  no-error.
                vcTypeTrt       = vhBuffer::cTypeTrt       no-error.
                viNumeroReleve  = vhBuffer::iNumeroReleve  no-error.
                vcReleveImmBat  = vhBuffer::cReleveImmBat  no-error.  
                vcCodeBatiment  = vhBuffer::cCodeBatiment  no-error.  
            end.
        end.
        delete object vhttFilter no-error.

        ghProc = outilHandle:connectMaGIModele("tache/tacheReleve.p").
        case vcTypeTrt:
            when "COMBO"          then run initComboReleveDeCompteur in ghProc(output table ttCombo).
            when "INITIALISATION" then run initReleveDeCompteur      in ghProc(vcTypeContrat, viNumeroContrat, vcTypeCompteur, vcReleveImmBat, vcCodeBatiment, output table ttReleveDeCompteur, output table ttLigneReleveDeCompteur).
            otherwise                  run getReleveCompteur         in ghProc(vcTypeContrat, viNumeroContrat, vcTypeCompteur, viNumeroReleve, output table ttReleveDeCompteur, output table ttLigneReleveDeCompteur).
        end case.
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeReleveCompteur(input-output dataset dsbeReleveCompteur):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        updateReleveCompteur().
        {outils/include/tryCatch.i}
    end method.

    method private logical updateReleveCompteur():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheReleve.p").
        run setReleveCompteur in ghProc(table ttReleveDeCompteur, table ttLigneReleveDeCompteur).
        dataset dsbeReleveCompteur:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    destructor public beReleveCompteur ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
