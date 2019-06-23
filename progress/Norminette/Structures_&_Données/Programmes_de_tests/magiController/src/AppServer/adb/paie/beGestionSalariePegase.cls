/*------------------------------------------------------------------------
File        : beGestionSalariePegase.cls
Purpose     :
Author(s)   : GGA - 2017/04/19
Notes       :
derniere revue: 2018/05/22 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}

@program FILE(name="beGestionSalariePegase.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beGestionSalariePegase", URI="/beGestionSalariePegase", schemaName="dsbeGestionSalariePegase", schemaFile="").

using outils.outilHandle.

block-level on error undo, throw.

class adb.paie.beGestionSalariePegase:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {adresse/include/adresse.i}
    {adresse/include/coordonnee.i}
    {adresse/include/moyenCommunication.i}
    {adb/paie/include/salariePegase.i}
    {adb/paie/include/organismesSociauxPegase.i}
    {application/include/error.i}  
  
    define dataset dsbeGestionSalariePegase for ttSalariePegase, ttAdresse, ttMoyenCommunication, ttOrganismeSociauxPegase, ttError
            data-relation SalariePegaseAdresse         for ttSalariePegase, ttAdresse         nested //foreign-key-hidden
                relation-fields (ttSalariePegase.iNumeroIdentifiant, ttAdresse.iNumeroIdentifiant)
            data-relation SalariePegaseMoyenComm       for ttSalariePegase, ttMoyenCommunication    nested //foreign-key-hidden
                relation-fields (ttSalariePegase.iNumeroIdentifiant, ttMoyenCommunication.iNumeroIdentifiant)
    .

    constructor public beGestionSalariePegase():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/

    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeGestionSalariePegase (pcFiltre as longchar, output dataset dsbeGestionSalariePegase):
        /*------------------------------------------------------------------------------
        Purpose: get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhAdresse       as handle    no-undo. 
        define variable vhSalarie       as handle    no-undo.
        define variable vhOrgSociaux    as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable vcTypeMandat    as character no-undo.
        define variable viNumeroSalarie as int64     no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcTypeMandat    = vhBuffer::cTypeMandat no-error.
                viNumeroSalarie = integer(vhBuffer::iNumeroSalarie) no-error.
            end.
        end. 
        delete object vhttFilter no-error.

blocLect:
        do:
            vhAdresse = outilHandle:connectMaGIModele("adresse/adresse.p").
            run getAdresse in vhAdresse ({&TYPEROLE-salariePegase}, viNumeroSalarie, "", "1", output table ttAdresse, output table ttCoordonnee, output table ttMoyenCommunication).        
            run getErrors in vhAdresse(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocLect.

            vhSalarie = outilHandle:connectMaGIModele("adb/paie/salariePegase.p").
            run getSalarie in vhSalarie(viNumeroSalarie, output table ttSalariePegase).
            run getErrors in vhSalarie(output table ttError).
            if can-find(first ttError where ttError.iType >= {&error}) then leave blocLect.

            vhOrgSociaux = outilHandle:connectMaGIModele("adb/paie/organismesSociauxPegase.p").
            run getOrgSociauxSalarie in vhOrgSociaux(vcTypeMandat, viNumeroSalarie, output table ttOrganismeSociauxPegase).
            run getErrors in vhOrgSociaux(output table ttError).
        end.
        {outils/include/tryCatch.i}

    end method.

    destructor public beGestionSalariePegase ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().

    end destructor.

end class.
