/*------------------------------------------------------------------------
File        : beParametreGestionImmo.cls
Purpose     :
Author(s)   : DMI - 2017/12/15
Notes       :
derniere revue: 2018/04/23 - phm: OK
------------------------------------------------------------------------*/
@program FILE(name="beParametreGestionImmo.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beParametreGestionImmo", URI="/beParametreGestionImmo", schemaName="dsbeParametreGestionImmo", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class parametre.cabinet.gestionImmobiliere.beParametreGestionImmo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.

    define variable ghProc as handle    no-undo.  // plutôt que définir dans chacune des procédures.

    {parametre/cabinet/gestionImmobiliere/include/libelleCleRepartition.i &nomtable=ttlibelleCleRepartition &serialName=ttlibelleCleRepartition}
    {parametre/cabinet/gestionImmobiliere/include/paramMutation.i}
    {parametre/cabinet/gestionImmobiliere/include/modeleBudgetLocatif.i &nomtable=ttModeleBudgetaire &serialName=ttModeleBudgetaire}
    {parametre/cabinet/gestionImmobiliere/include/posteBudgetLocatif.i &nomtable=ttPosteBudgetaire &serialName=ttPosteBudgetaire}
    {parametre/cabinet/gestionImmobiliere/include/paramBudgetLocatif.i &nomtable=ttParametreBudgetLocatif &serialName=ttParametreBudgetLocatif}
    {bail/include/rubriqueQuitt.i &NomTable=ttRubriqueQuittExcBudget &SerialName=ttRubriqueQuittExcBudget}
    {bail/include/rubriqueQuitt.i &NomTable=ttRubriqueQuittExcPresHT &SerialName=ttRubriqueQuittExcPresHT}
    {compta/include/rubriqueAnalytique.i &NomTable=ttRubriqueAnaExcBudget &SerialName=ttRubriqueAnaExcBudget}
    {compta/include/rubriqueAnalytique.i &NomTable=ttRubriqueAnaExcPresHT &SerialName=ttRubriqueAnaExcPresHT}
    {application/include/error.i}
    {application/include/combo.i}

    define dataset dsbeParametreGestionImmo for
    ttLibelleCleRepartition,
    ttParamMutation,
    ttModeleBudgetaire, ttPosteBudgetaire, ttRubriqueBudgetaire, ttAffectRubriqueAnalytique, ttAffectRubriqueQuittancement,
    ttParametreBudgetLocatif, ttRubriqueQuittExcBudget, ttRubriqueAnaExcBudget, ttRubriqueQuittExcPresHT, ttRubriqueAnaExcPresHT,
    ttCombo, ttError
    data-relation posteBudgetaire for ttModeleBudgetaire, ttPosteBudgetaire nested
        relation-fields(ttModeleBudgetaire.iNumeroModele, ttPosteBudgetaire.iNumeroModele)
    data-relation rubriqueBudgetaire for ttPosteBudgetaire, ttRubriqueBudgetaire nested
        relation-fields(ttPosteBudgetaire.iNumeroModele, ttRubriqueBudgetaire.iNumeroModele,
                        ttPosteBudgetaire.iNumeroPoste, ttRubriqueBudgetaire.iNumeroPoste)
    .

    constructor public beParametreGestionImmo():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeParametreGestionImmo(pcFiltre as longchar, output dataset dsbeParametreGestionImmo):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.
        define variable vcTypeTrt  as character no-undo.

        dataset dsbeParametreGestionImmo:empty-dataset().
        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcVue     = vhBuffer::cVue     no-error.
                vcTypeTrt = vhBuffer::cTypeTrt no-error.
            end.
        end.
        case vcVue:
            when 'LIBELLECLEREPARTITION' then readLibelleCleRepartition(vhBuffer, vcTypeTrt).
            when 'BUDGETLOCATIF'         then readBudgetLocatif(vhBuffer, vcTypeTrt).
            when 'PARAMBUDGETLOCATIF'    then readParamBudgetLocatif(vhBuffer, vcTypeTrt).
            when 'MUTATION'              then readMutation().
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        delete object vhttFilter no-error.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update",  URI="", alias="", mediaType="application/json").
    method public void updatebeParametreGestionImmo(pcFiltre as longchar, input-output dataset dsbeParametreGestionImmo):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter as handle    no-undo.
        define variable vhBuffer   as handle    no-undo.
        define variable vcVue      as character no-undo.
        define variable vcTypeTrt  as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                vcVue     = vhBuffer::cVue     no-error.
                vcTypeTrt = vhBuffer::cTypeTrt no-error.
            end.
        end.
        case vcVue:
            when 'LIBELLECLEREPARTITION' then updateLibelleCleRepartition().
            when 'BUDGETLOCATIF'         then updateBudgetLocatif(vcTypeTrt).
            when 'PARAMBUDGETLOCATIF'    then updateParamBudgetLocatif(vcTypeTrt).
            when 'MUTATION'              then updateMutation().
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        delete object vhttFilter no-error.
        {outils/include/tryCatch.i}
    end method.

    method private logical readLibelleCleRepartition(phBuffer as handle, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vcCodeCle as character no-undo.

        ghProc = outilHandle:connectMaGIModele("parametre/cabinet/gestionImmobiliere/libelleCleRepartition.p").
        if phBuffer:available then vcCodeCle = phBuffer::cCodeCle no-error.
        case pcTypeTrt:
            when "COMBO" then run initCombo in ghProc(output table ttCombo).
            otherwise         run getLibelleCleRepartition in ghProc(vcCodeCle, output table ttLibelleCleRepartition).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readBudgetLocatif(phBuffer as handle, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viNumeroModele as integer initial ? no-undo.
        define variable viNumeroPoste  as integer initial ? no-undo.
        define variable vlFiscalite1   as logical initial ? no-undo.
        define variable vlFiscalite2   as logical initial ? no-undo.
        define variable vlFiscalite3   as logical initial ? no-undo.
        define variable vlFiscalite4   as logical initial ? no-undo.

        if phBuffer:available then do:
            viNumeroModele = phBuffer::iNumeroModele no-error.
            viNumeroPoste  = phBuffer::iNumeroPoste  no-error.
            vlFiscalite1   = phBuffer::lFiscalite1   no-error.
            vlFiscalite2   = phBuffer::lFiscalite2   no-error.
            vlFiscalite3   = phBuffer::lFiscalite3   no-error.
            vlFiscalite4   = phBuffer::lFiscalite4   no-error.
        end.
        ghProc = outilHandle:connectMaGIModele("parametre/cabinet/gestionImmobiliere/modeleBudgetLocatif.p").
        case pcTypeTrt:
            when "MODELE"             then run getModeleBudgetaire      in ghProc(viNumeroModele, output table ttModeleBudgetaire).
            when "POSTE"              then run getPosteBudgetaire       in ghProc(viNumeroModele, viNumeroPoste, output table ttModeleBudgetaire, output table ttPosteBudgetaire).
            when "RUBRIQUEBUDGETAIRE" then run getRubriqueBudgetaire    in ghProc(viNumeroModele, viNumeroPoste, output table ttModeleBudgetaire, output table ttPosteBudgetaire, output table ttRubriqueBudgetaire).
            when "ANALYTIQUE"         then run getRubriqueAnalytique    in ghProc(viNumeroModele, viNumeroPoste, vlFiscalite1, vlFiscalite2, vlFiscalite3, vlFiscalite4, output table ttAffectRubriqueAnalytique).
            when "QUITTANCEMENT"      then run getRubriqueQuittancement in ghProc(viNumeroModele, viNumeroPoste, output table ttAffectRubriqueQuittancement).
            when "CONTROLEGLOBAL"     then run getControleGlobal        in ghProc.
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readParamBudgetLocatif(phBuffer as handle, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viNumeroModele as integer initial ? no-undo.

        if phBuffer:available then viNumeroModele = phBuffer::iNumeroModele no-error.
        ghProc = outilHandle:connectMaGIModele("parametre/cabinet/gestionImmobiliere/paramBudgetLocatif.p").
        case pcTypeTrt:
            when "COMBO" then run initCombo in ghProc(output table ttCombo).
            otherwise         run getParametrageBudgetLocatif in ghProc(
                                  viNumeroModele,
                                  output table ttParametreBudgetLocatif,
                                  output table ttRubriqueQuittExcPresHT,
                                  output table ttRubriqueAnaExcPresHT,
                                  output table ttRubriqueQuittExcBudget,
                                  output table ttRubriqueAnaExcBudget).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateLibelleCleRepartition():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("parametre/cabinet/gestionImmobiliere/libelleCleRepartition.p").
        run updateLibelleCleRepartition in ghProc(table ttLibelleCleRepartition).
        dataset dsbeParametreGestionImmo:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateBudgetLocatif(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("parametre/cabinet/gestionImmobiliere/modeleBudgetLocatif.p").
        case pcTypeTrt:
            when "CONTROLE"   then do:
                run verBudgetLocatif in ghProc(table ttModeleBudgetaire, table ttPosteBudgetaire, table ttRubriqueBudgetaire).
                dataset dsbeParametreGestionImmo:empty-dataset().
            end.
            when "INITMODELE" then run initModeleBudgetaire in ghProc(table ttModeleBudgetaire, output       table ttPosteBudgetaire).
            when "INITPOSTE"  then run initPosteBudgetaire  in ghProc(table ttModeleBudgetaire, input-output table ttPosteBudgetaire).
            otherwise do:
                run updateBudgetLocatif in ghProc(table ttModeleBudgetaire, table ttPosteBudgetaire, table ttRubriqueBudgetaire).
                dataset dsbeParametreGestionImmo:empty-dataset().
            end.
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateParamBudgetLocatif(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("parametre/cabinet/gestionImmobiliere/paramBudgetLocatif.p").
        case pcTypeTrt:
            when "CREATIONLIEN" then run setCreationLien in ghProc(table ttError).
            otherwise                run setParametrageBudgetLocatif in ghProc(
                                         table ttParametreBudgetLocatif,
                                         table ttRubriqueQuittExcPresHT,
                                         table ttRubriqueAnaExcPresHT,
                                         table ttRubriqueQuittExcBudget,
                                         table ttRubriqueAnaExcBudget).
        end case.
        dataset dsbeParametreGestionImmo:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readMutation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("parametre/cabinet/gestionImmobiliere/paramMutation.p").
        run getParamMutation in ghProc(output table ttParamMutation).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateMutation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("parametre/cabinet/gestionImmobiliere/paramMutation.p").
        run setParamMutation in ghProc(table ttParamMutation).
        dataset dsbeParametreGestionImmo:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    destructor public beParametreGestionImmo():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
