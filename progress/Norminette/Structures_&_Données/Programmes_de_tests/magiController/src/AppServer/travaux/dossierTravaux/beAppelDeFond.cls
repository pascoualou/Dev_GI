/*------------------------------------------------------------------------
File        : beAppelDeFond.cls
Purpose     :
Author(s)   : kantena - 2016/11/09
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/

@program FILE(name="beAppelDeFond.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beAppelDeFond", URI="/beAppelDeFond", schemaName="dsbeAppelDeFond", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class travaux.dossierTravaux.beAppelDeFond:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {travaux/include/dossierTravaux.i}
    {travaux/include/appelDefond.i}
    {application/include/error.i}
    {application/include/combo.i}

    define buffer gbttError                 for ttError.
    define buffer gbttInfoSaisieAppelDeFond for ttInfoSaisieAppelDeFond.
    define buffer gbttDossierAppelDeFond    for ttDossierAppelDeFond.

    define dataset dsbeAppelDeFond for ttDossierTravaux,
                                       ttEnteteAppelDeFond,
                                       ttAppelDeFond,
                                       ttAppelDeFondRepCle,
                                       ttAppelDeFondRepMat,
                                       ttRepartitionCle,
                                       ttRepartitionCopro,
                                       ttRepartitionPourcentage,
                                       ttDossierAppelDeFond,
                                       ttInfoSaisieAppelDeFond,
                                       ttError
        data-relation EnteteEcheance for ttEnteteAppelDeFond, ttAppelDeFond nested /*gga foreign-key-hidden gga*/
            relation-fields (ttEnteteAppelDeFond.iNumeroIdentifiant,
                             ttAppelDeFond.iNumeroIdentifiant)
        data-relation EnteteRepartitionCle for ttAppelDeFond, ttAppelDeFondRepCle nested /*gga foreign-key-hidden gga*/
            relation-fields (ttAppelDeFond.iNumeroIdentifiant,
                             ttAppelDeFondRepCle.iNumeroIdentifiant,
                             ttAppelDeFond.iNumeroAppel,
                             ttAppelDeFondRepCle.iNumeroAppel)
        data-relation EnteteRepartitionMatricule for ttAppelDeFond, ttAppelDeFondRepMat nested /*gga foreign-key-hidden gga*/
            relation-fields (ttAppelDeFond.iNumeroIdentifiant,
                             ttAppelDeFondRepMat.iNumeroIdentifiant,
                             ttAppelDeFond.iNumeroAppel,
                             ttAppelDeFondRepMat.iNumeroAppel).

    define dataset dsbeInfoSaisieAppelDeFond for gbttInfoSaisieAppelDeFond,
                                                 gbttDossierAppelDeFond,
                                                 ttCombo,
                                                 gbttError.

    constructor public beAppelDeFond():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeAppelDeFond(pcFiltre as longchar, output dataset dsbeAppelDeFond):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
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
                goCollection:set('cTypeMandat',           vhBuffer::cTypeMandat)          no-error.
                goCollection:set('iNumeroMandat',         int64(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroDossierTravaux', integer(vhBuffer::iNumeroDossierTravaux)) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/appelDeFond.p").
        run getAppelDeFond in vhProc (goCollection,
                                      output table ttEnteteAppelDeFond,
                                      output table ttAppelDeFond,
                                      output table ttAppelDeFondRepCle,
                                      output table ttAppelDeFondRepMat,
                                      output table ttDossierAppelDeFond).
        run getErrors in vhProc (output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeInfoSaisieAppelDeFond(pcFiltre as longchar, output dataset dsbeInfoSaisieAppelDeFond):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
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
                goCollection:set('cTypeMandat',           vhBuffer::cTypeMandat)          no-error.
                goCollection:set('iNumeroMandat',         int64(vhBuffer::iNumeroMandat)) no-error.
                goCollection:set('iNumeroDossierTravaux', integer(vhBuffer::iNumeroDossierTravaux)) no-error.
                goCollection:set('cTypeAppel',            vhBuffer::cTypeAppel)   no-error.
                goCollection:set('cTypeDemande',          vhBuffer::cTypeDemande) no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/appelDeFond.p").
        run getInfoSaisieAppelDeFond in vhProc (goCollection,
                                                output table ttInfoSaisieAppelDeFond,
                                                output table ttDossierAppelDeFond,
                                                output table ttCombo).
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeAppelDeFond(pcFiltre as longchar, input-output dataset dsbeAppelDeFond):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc     as handle    no-undo.
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcTypeTrt  as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeTrt = vhBuffer::cTypeTrt no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("travaux/dossierTravaux/appelDeFond.p").
        case vcTypeTrt:
            when "validdetailappel" then run validDetailAppel in vhProc(
                table ttError,
                input-output table ttDossierTravaux,
                input-output table ttEnteteAppelDeFond,
                input-output table ttAppelDeFond,
                input-output table ttAppelDeFondRepCle,
                input-output table ttAppelDeFondRepMat,
                input-output table ttInfoSaisieAppelDeFond,
                input-output table ttRepartitionCle,
                input-output table ttRepartitionCopro,
                input-output table ttRepartitionPourcentage,
                input-output table ttDossierAppelDeFond
            ).
            when "modifbaremehono" then run calAppHonoExterne in vhProc(
                input-output table ttDossierTravaux,
                input-output table ttEnteteAppelDeFond,
                input-output table ttAppelDeFond,
                input-output table ttAppelDeFondRepCle,
                input-output table ttAppelDeFondRepMat,
                input-output table ttInfoSaisieAppelDeFond,
                input-output table ttRepartitionCle,
                input-output table ttRepartitionCopro,
                input-output table ttDossierAppelDeFond
            ).
            when "validdossierappel" then run validDossierAppel in vhProc(
                input-output table ttDossierTravaux,
                input-output table ttEnteteAppelDeFond,
                input-output table ttAppelDeFond,
                input-output table ttAppelDeFondRepCle,
                input-output table ttAppelDeFondRepMat,
                input-output table ttInfoSaisieAppelDeFond,
                input-output table ttRepartitionCle,
                input-output table ttRepartitionCopro,
                input-output table ttDossierAppelDeFond
            ).
            otherwise run createError in vhProc({&error}, 999999, vcTypeTrt).    /* todo creer message */
        end case.
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    destructor public beAppelDeFond ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
