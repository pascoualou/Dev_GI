/*------------------------------------------------------------------------
File        : beConsultationCompte.cls
Purpose     :
Author(s)   : devweb1  -  2017/01/18
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

@program FILE(name="beConsultationCompte.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beConsultationCompte", URI="/beConsultationCompte", schemaName="dsbeConsultationCompte", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class compta.beConsultationCompte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {compta/include/consultationCompte.i}
    {compta/include/soldeCompte.i}
    {compta/include/positionComptable.i}
    {application/include/error.i}
    {outils/include/methodConversionDate.i}

    define dataset dsbeConsultationCompte for ttLigneEcriture, ttLigneEcritureDetail, ttVentilationEcriture, ttVentilationDetail, 
                                              ttSoldeCompte, ttPositionComptable, ttError
        data-relation detailTresorerie for ttLigneEcriture, ttLigneEcritureDetail nested foreign-key-hidden
            relation-fields (ttLigneEcriture.cLienDetail, ttLigneEcritureDetail.cLienDetail)
        data-relation ventilation for ttLigneEcriture, ttVentilationEcriture nested foreign-key-hidden
            relation-fields (ttLigneEcriture.cLienVentilation, ttVentilationEcriture.cLienVentilation)
        data-relation ventilationDetail for ttLigneEcritureDetail, ttVentilationDetail nested foreign-key-hidden
            relation-fields (ttLigneEcritureDetail.cLienVentilation, ttVentilationDetail.cLienVentilation).

    constructor public beConsultationCompte():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeConsultationCompte(pcFiltre as longchar, output dataset dsbeConsultationCompte):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc       as handle    no-undo.
        define variable vhttFilter   as handle    no-undo.
        define variable vhBuffer     as handle    no-undo.
        define variable vcFormatDate as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('cFormatDate',          vhBuffer::cFormatDate)             no-error.
                goCollection:set('iNumeroSociete',       integer(vhBuffer::iNumeroSociete)) no-error.
                goCollection:set('iNumeroMandat',        integer(vhBuffer::iNumeroMandat))  no-error.
                goCollection:set('cListeCollectif',      vhBuffer::cListeCollectif)         no-error.
                goCollection:set('cNumeroCompte',        vhBuffer::cNumeroCompte)           no-error.
                goCollection:set('lAvecEcritureLettree', vhBuffer::lAvecEcritureLettree)    no-error.
                goCollection:set('lAvecExtraComptable',  vhBuffer::lAvecExtraComptable)     no-error.
                goCollection:set('iNumeroDossier',       integer(vhBuffer::iNumeroDossier)) no-error.
                vcFormatDate = vhBuffer::cFormatDate no-error.
                goCollection:set('dtDateDebut',conversionDate(vcFormatDate, vhBuffer::dtDateDebut)) no-error.
                goCollection:set('dtDateFin',  conversionDate(vcFormatDate, vhBuffer::dtDateFin))   no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("compta/consultationCompte.p").
        run getConsultationCompte in vhProc(goCollection,
                                            output table ttLigneEcriture,
                                            output table ttLigneEcritureDetail,
                                            output table ttVentilationEcriture,
                                            output table ttVentilationDetail,
                                            output table ttSoldeCompte).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbePositionComptable(pcFiltre as longchar, output dataset dsbeConsultationCompte):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc       as handle    no-undo.
        define variable vhttFilter   as handle    no-undo.
        define variable vhBuffer     as handle    no-undo.
        define variable vcFormatDate as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroSociete', integer(vhBuffer::iNumeroSociete)) no-error.
                goCollection:set('cTypeContrat  ', vhBuffer::cTypeContrat)            no-error.
                goCollection:set('iNumeroContrat', int64  (vhBuffer::iNumeroContrat)) no-error.
                vcFormatDate = vhBuffer::cFormatDate no-error.
                goCollection:set('daDatePosition', conversionDate(vcFormatDate, vhBuffer::daDatePosition)) no-error. 
            end.
        end.
        delete object vhttFilter no-error.
        vhProc = outilHandle:connectMaGIModele("compta/positionComptable.p").
        run getPositionComptable in vhProc(goCollection, output table ttPositionComptable).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    
    end method.

    destructor public beConsultationCompte ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
