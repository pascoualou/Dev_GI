/*------------------------------------------------------------------------
File        : beAutoCompleteGeneric.cls
Purpose     :
Author(s)   : kantena - 2016/02/11
Notes       :
derniere revue: 2018/05/03 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}

@program FILE(name="beAutoComplete.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beAutoComplete", URI="/beAutoComplete", schemaName="dsbeAutoComplete", schemaFile="magiController/src/AppServer/application/include/autoCompleteGeneric.i").

using outils.outilHandle.
using outils.collection.
block-level on error undo, throw.

class application.autoComplete.beAutoComplete:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}

    constructor public beAutoComplete():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void ReadbeAutoComplete(pcFiltre as longchar, output pcAutoComplete as longchar):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a pcFiltre string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc            as handle    no-undo.
        define variable vhttFilter        as handle    no-undo.
        define variable vhBuffer          as handle    no-undo.
        define variable vhttAutoComplete  as handle    no-undo.
        define variable vhDynamicDataSet  as handle    no-undo.
        define variable vcNomTable        as character no-undo.
        define variable vcPreCondition    as character no-undo.
        define variable vcChampsRecherche as character no-undo.
        define variable vcChampsCode      as character no-undo.
        define variable vcFilter          as character no-undo.
        define variable vcFilter2         as character no-undo.
        define variable vcFilter3         as character no-undo.
        define variable vcChampsRetour    as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcNomTable        = vhBuffer::cNomTable        no-error.
                vcPreCondition    = vhBuffer::cPreCondition    no-error.
                vcChampsRecherche = vhBuffer::cChampsRecherche no-error.
                vcChampsCode      = vhBuffer::cChampsCode      no-error.
                vcFilter          = vhBuffer::cFilter          no-error.
                vcFilter2         = vhBuffer::cFilter2         no-error.
                vcFilter3         = vhBuffer::cFilter3         no-error.
                vcChampsRetour    = vhBuffer::cChampsRetour    no-error.
            end.
        end.
        delete object vhttFilter no-error.

        create dataset vhDynamicDataSet.
        assign 
            vhDynamicDataSet:name = "dsbeAutoCompleteGeneric"
            vhProc = outilHandle:connectMaGIModele("application/aideSaisie/autoComplete.p")
        .
        case vcNomtable:
            // roles.lbrech contains cfilter. Si cChampsRecherche = "Contrat", pcFiltre2 doit être cNumeroMandatCourt.
            when "signalant"        then run getAutoCompleteSignalant in vhProc(vcChampsRecherche, vcfilter, vcfilter2, output table-handle vhttAutoComplete).
            // si cChampsRecherche = '', cFilter -> matches etab-cd, sinon cfilter = etab-cd.
            when "ctrat"            then run getAutoCompleteMandat    in vhProc(vcChampsRecherche, vcfilter, false, output table-handle vhttAutoComplete).
            // si cChampsRecherche = '', cFilter  -> matches etab-cd, sinon cfilter = etab-cd
            //                           cFilter2 -> reference société
            //                           cFilter3 -> numéro immeuble
            when "ctratImmeuble"    then run getAutoCompleteMandatImmeuble in vhProc(vcChampsRecherche, vcfilter, vcfilter2, vcfilter3, output table-handle vhttAutoComplete).
            // ifour.four-cle matches ou ifour.nom matches cfilter
            when "fournisseur"      then run getAutoCompleteFournisseur    in vhProc(vcfilter, vcFilter2, output table-handle vhttAutoComplete).
            // cfilter = debut du libelle proximite 
            when "libelleproximite" then run getAutoCompleteProximite      in vhProc(vcfilter, vcFilter2, output table-handle vhttAutoComplete).
            // cfilter = debut du libellé pays.
            when "pays"             then run getAutoCompletePays  in vhProc (vcfilter, output table-handle vhttAutoComplete).
            // requête rôles
            when "notaire"          then run getAutoCompleteRole  in vhProc({&TYPEROLE-notaire},    vcFilter, output table-handle vhttAutoComplete).
            when "architecte"       then run getAutoCompleteRole  in vhProc({&TYPEROLE-architecte}, vcFilter, output table-handle vhttAutoComplete).
            when "locataire"        then run getAutoCompleteRole  in vhProc({&TYPEROLE-locataire},  vcFilter, output table-handle vhttAutoComplete).
            // requête dynamique sur une table
            otherwise                    run geAutoCompletetListe in vhProc (vcNomTable, vcPreCondition, vcChampsRecherche, vcChampsCode, vcfilter, vcChampsRetour, output table-handle vhttAutoComplete).
        end case.
        run getErrors in vhProc(output table ttError).
        vhDynamicDataSet:set-buffers(vhttAutoComplete, buffer ttError:handle).
        // permet de générer le Json sans les champs ayant leur valeur par défaut - réduit la taille du flux!
        vhDynamicDataSet:write-json("LONGCHAR", pcAutoComplete, false, ?, true, false, false).
        {outils/include/tryCatch.i}
    end method.

    destructor public beAutoComplete( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
