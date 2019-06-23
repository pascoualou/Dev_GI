/*------------------------------------------------------------------------
File        : beUtilisateur.cls
Purpose     :
Author(s)   : kantena - 2016/03/18
Notes       :
------------------------------------------------------------------------*/

@program FILE(name="beUtilisateur.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beUtilisateur", URI="/beUtilisateur", schemaName="dsbeUtilisateur", schemaFile="magiController/src/AppServer/oerealm/include/utilisateur.i").

using outils.outilHandle.

block-level on error undo, throw.

class oerealm.beUtilisateur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/error.i}
	{oerealm/include/utilisateur.i}
    define dataset dsbeUtilisateur for ttUtilisateur.

    constructor public beUtilisateur( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super ().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeUtilisateur(pcFiltre as longchar, output dataset dsbeUtilisateur):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc            as handle    no-undo.
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.
        define variable vcMode            as character no-undo.
        define variable vcCodeUtilisateur as character no-undo.
        define variable viNumeroTiers     as integer   no-undo.

        dataset dsbeUtilisateur:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcMode            = vhBuffer::cMode            no-error.
                vcCodeUtilisateur = vhBuffer::cCodeUtilisateur no-error.
                viNumeroTiers     = vhBuffer::iNumeroTiers     no-error.
            end.
        end.
        delete object vhttFilter no-error.

        vhProc = outilHandle:connectMaGIModele("oerealm/utilisateur.p").
        case vcMode:
            when "Selection" then run getUtilisateur      in vhProc(vcCodeUtilisateur, viNumeroTiers, output table ttUtilisateur).
            when "Connecte"  then run getUtilisateur      in vhProc("", 0, output table ttUtilisateur).
            when "Liste"     then run getListeUtilisateur in vhProc(output table ttUtilisateur).
        end case.
        run getErrors in vhProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.
    
    destructor public beUtilisateur( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
