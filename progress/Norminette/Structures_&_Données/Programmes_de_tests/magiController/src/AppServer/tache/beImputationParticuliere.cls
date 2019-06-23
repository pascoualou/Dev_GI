/*------------------------------------------------------------------------
File        : beImputationParticuliere.cls
Syntax      : 
Author(s)   : RF - 09/01/2018
Notes       : 
derniere revue: 2018/05/24 - phm: OK
---------------------------------------------------------------------*/
@program FILE(name="beImputationParticuliere.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beImputationParticuliere", URI="/beImputationParticuliere", schemaName="dsbeImputationParticuliere", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class tache.beImputationParticuliere:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    define variable ghProc as handle    no-undo.  // plutôt que définir dans chacune des procédures.
    {application/include/error.i}
    {application/include/combo.i}
    {preprocesseur/type2tache.i}
    {preprocesseur/type2contrat.i}
    {preprocesseur/type2bien.i}
    {tache/include/imputationParticuliere.i}
    {outils/include/methodConversionDate.i}
    
    define dataset dsbeImputationParticuliere
        for ttImputationParticuliere, ttLigneImputationParticuliere, ttLocataire, ttcombo, ttError
        data-relation detail for ttImputationParticuliere, ttLigneImputationParticuliere nested foreign-key-hidden
        relation-fields (ttImputationParticuliere.iNumeroMandat   , ttLigneImputationParticuliere.iNumeroMandat,
                         ttImputationParticuliere.iNumeroImmeuble , ttLigneImputationParticuliere.iNumeroImmeuble,
                         ttImputationParticuliere.daDateImputation, ttLigneImputationParticuliere.daDateImputation).

    constructor public beImputationParticuliere():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.
        
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void ReadbeImputationParticuliere(pcfiltre as longchar, output dataset dsbeImputationParticuliere):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.
        define variable viNumeroMandat    as integer   no-undo.
        define variable vcTypeContrat     as character no-undo.
        define variable viNumeroImmeuble  as integer   no-undo.
        define variable vdaDateImputation as date      no-undo.
        define variable viPeriodeCharge   as integer   no-undo.
        define variable vcTypePeriode     as character no-undo.
        define variable vcTypeTrt         as character no-undo.
        define variable vcFormatDate      as character no-undo.

        dataset dsbeImputationParticuliere:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error. 
            if vhBuffer:available then do:
                vcFormatDate      = vhBuffer::cFormatDate                      no-error.                        
                viNumeroMandat    = integer(vhBuffer::iNumeroMandat)           no-error.
                vcTypeContrat     = vhBuffer::cTypeContrat                     no-error.
                viNumeroImmeuble  = integer(vhBuffer::iNumeroImmeuble)         no-error.                
                vdaDateImputation = conversionDate(vcFormatDate, vhBuffer::daDateImputation) no-error.
                viPeriodeCharge   = integer(vhBuffer::iPeriodeCharge)          no-error.
                vcTypePeriode     = vhBuffer::cTypePeriode                     no-error.
                vcTypeTrt         = vhBuffer::cTypeTrt                         no-error.
                
            end.
        end.
        delete object vhttFilter no-error.   
        ghProc = outilHandle:connectMaGIModele("tache/imputationParticuliere.p").
        case vcTypeTrt:
            when "INITIALISATION" then run initImputationParticuliere in ghProc(viNumeroImmeuble, viNumeroMandat, vcTypeContrat, output table ttImputationParticuliere, output table ttLocataire, output table ttCombo).
            when "COMBOPER" then run initComboPer in ghProc(viNumeroMandat, vcTypeContrat, viPeriodeCharge, vcTypePeriode, vdaDateImputation, output table ttCombo).
            when "COMBOVUE" then run initComboVue in ghProc(viNumeroImmeuble, viNumeroMandat, vcTypeContrat, output table ttLocataire, output table ttCombo). 
            otherwise run getImputationParticuliere in ghProc(viNumeroMandat, viNumeroImmeuble, vdaDateImputation, output table ttImputationParticuliere,output table ttLigneImputationParticuliere).    
        end case.   
        run getErrors in ghProc(output table ttError).             
        {outils/include/tryCatch.i}      
    end method.
      
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void ReadbeListeImputationParticuliere(pcfiltre as longchar, output dataset dsbeImputationParticuliere):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter          as handle    no-undo.
        define variable vhBuffer            as handle    no-undo.
        define variable viNumeroMandat      as integer   no-undo. 
        define variable vcTypeContrat       as character no-undo.
        define variable viPeriodeCharge     as integer   no-undo.
        define variable vcTypePeriode       as character no-undo.

        dataset dsbeImputationParticuliere:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error. 
            if vhBuffer:available then do:
                viNumeroMandat  = integer(vhBuffer::iNumeroMandat)  no-error.
                vcTypeContrat   = vhBuffer::cTypeContrat            no-error.
                viPeriodeCharge = integer(vhBuffer::iPeriodeCharge) no-error.
                vcTypePeriode   = vhBuffer::cTypePeriode            no-error.
            end.
        end.
        delete object vhttFilter no-error.   
        ghProc = outilHandle:connectMaGIModele("tache/imputationParticuliere.p").
        run getListeImputationParticuliere in ghProc(viNumeroMandat, vcTypeContrat, viPeriodeCharge, vcTypePeriode, output table ttImputationParticuliere).                        
        run getErrors in ghProc(output table ttError).             
        {outils/include/tryCatch.i}      
    end method.  

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeImputationParticuliere(input-output dataset dsbeImputationParticuliere):            
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/  
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeImputationParticuliere(input-output dataset dsbeImputationParticuliere):            
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/imputationParticuliere.p").
        run setImputationParticuliere in ghProc(table ttImputationParticuliere, table ttLigneImputationParticuliere, table ttError).
        dataset dsbeImputationParticuliere:empty-dataset().
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeImputationParticuliere(pcfiltre as longchar, output dataset dsbeImputationParticuliere):                    
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.
        define variable viNumeroMandat    as integer   no-undo.
        define variable viNumeroImmeuble  as integer   no-undo. 
        define variable vdaDateImputation as date      no-undo.
        define variable vcFormatDate      as character no-undo.         
        
        dataset dsbeImputationParticuliere:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error. 
            if vhBuffer:available then do:
                vcFormatDate      = vhBuffer::cFormatDate                      no-error.        
                viNumeroMandat    = integer(vhBuffer::iNumeroMandat)           no-error.
                viNumeroImmeuble  = integer(vhBuffer::iNumeroImmeuble)         no-error.                
                vdaDateImputation = conversionDate(vcFormatDate, vhBuffer::daDateImputation) no-error.
            end.
        end.
        delete object vhttFilter no-error.   
        ghProc = outilHandle:connectMaGIModele("tache/imputationParticuliere.p").
        run deleteImputationParticuliere in ghProc(viNumeroMandat, viNumeroImmeuble, vdaDateImputation, output table ttImputationParticuliere,output table ttLigneImputationParticuliere).    
        run getErrors in ghProc(output table ttError).             
        {outils/include/tryCatch.i} 
    end method.
    
    destructor public beImputationParticuliere ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
