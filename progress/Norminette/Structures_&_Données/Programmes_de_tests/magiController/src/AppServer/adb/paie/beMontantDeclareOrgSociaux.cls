/*------------------------------------------------------------------------
File        : beMontantDeclareOrgSociaux.cls
Purpose     :
Author(s)   : GGA - 2017/04/19
Notes       :   
------------------------------------------------------------------------*/

@program FILE(name="beMontantDeclareOrgSociaux.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beMontantDeclareOrgSociaux", URI="/beMontantDeclareOrgSociaux", schemaName="dsbeMontantDeclareOrgSociaux", schemaFile="").

using outils.outilHandle.

block-level on error undo, throw.

class adb.paie.beMontantDeclareOrgSociaux:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {adb/paie/include/montantDeclareOrgSociaux.i}
    {adb/paie/include/organismesSociauxPegase.i}
    {tache/include/tachePaiePegase.i}
    {application/include/error.i}

    define dataset dsbeMontantDeclareOrgSociaux for ttTachePaiePegase, ttOrganismeSociauxPegase, ttMontantDeclareOrgSociaux, ttError.

    constructor public beMontantDeclareOrgSociaux():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/

    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeMontantDeclareOrgSociaux (pcFiltre as longchar, output dataset dsbeMontantDeclareOrgSociaux):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhPegase        as handle    no-undo.
        define variable vhMontant       as handle    no-undo.
        define variable vhOrgSociaux    as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable vcTypeMandat    as character no-undo.
        define variable viNumeroMandat  as int64     no-undo.
        define variable vcOrganisme     as character no-undo.
        define variable vdaDebPer       as date      no-undo.
        define variable vdaFinPer       as date      no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeMandat    = vhBuffer::cTypeContrat            no-error.
                viNumeroMandat  = integer(vhBuffer::iNumeroContrat) no-error.
                vcOrganisme     = vhBuffer::cOrganisme              no-error.
                vdaDebPer       = date(vhBuffer::daDebPer)          no-error.
                vdaFinPer       = date(vhBuffer::daFinPer)          no-error. 
            end.
        end. 
        delete object vhttFilter no-error.

blocLect:
        do:
            vhMontant = outilHandle:connectMaGIModele("adb/paie/montantDeclareOrgSociaux.p").
            run getMontantDeclareOrgSociaux in vhMontant(viNumeroMandat, vcTypeMandat, vcOrganisme, vdaDebPer, vdaFinPer, output table ttMontantDeclareOrgSociaux).
            run getErrors in vhMontant(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocLect.

            vhPegase = outilHandle:connectMaGIModele("tache/tachePaiePegase.p").
            run getPaiePegase in vhPegase(viNumeroMandat, vcTypeMandat, output table ttTachePaiePegase).
            run getErrors in vhPegase(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocLect.

            vhOrgSociaux = outilHandle:connectMaGIModele("adb/paie/organismesSociauxPegase.p").
            run getOrganisme in vhOrgSociaux(vcOrganisme, viNumeroMandat, vcTypeMandat, output table ttOrganismeSociauxPegase).
            run getErrors in vhOrgSociaux(output table ttError).
        end.
        {outils/include/tryCatch.i}

    end method.

    destructor public beMontantDeclareOrgSociaux ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().

    end destructor.

end class.
