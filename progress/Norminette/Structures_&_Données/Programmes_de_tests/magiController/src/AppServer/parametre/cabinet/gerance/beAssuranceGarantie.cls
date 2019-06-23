/*-----------------------------------------------------------------------------
File        : beAssuranceGarantie.cls
Author(s)   : devweb1 - 2017/11/09
Notes       : Paramétrage des assurances garantie utilisées dans les baux:
              Garantie Loyer            01007
              Garantie Risque Locatif   01013
              Protection Juridique      01017
              Propriétaire Non Occupant 01018
              Vacance Locative          01087
              Garantie Spéciale         01020 - 01023
derniere revue: 2018/05/23 - phm: OK
-----------------------------------------------------------------------------*/

@program FILE(name="beAssuranceGarantie.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beAssuranceGarantie", URI="/beAssuranceGarantie", schemaName="dsbeAssuranceGarantie", schemaFile="").

using OpenEdge.BusinessLogic.BusinessEntity.
using outils.outilHandle.
using oerealm.beMagiToken.
using outils.logHandler.
using outils.collection.

block-level on error undo, throw.

class parametre.cabinet.gerance.beAssuranceGarantie inherits BusinessEntity:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/error.i}
    {application/include/combo.i}
    {parametre/cabinet/gerance/include/garantieLoyer.i}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeGarantieLoyerCom &serialName=ttbaremeGarantieLoyerCom}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeGarantieLoyerHab &serialName=ttbaremeGarantieLoyerHab}
    {parametre/cabinet/gerance/include/protectionJuridique.i}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeProtectionJuridiqueCom &serialName=ttbaremeProtectionJuridiqueCom}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeProtectionJuridiqueHab &serialName=ttbaremeProtectionJuridiqueHab}
    {parametre/cabinet/gerance/include/garantieRisqueLocatif.i}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeGRLCom &serialName=ttbaremeGRLCom}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeGRLHab &serialName=ttbaremeGRLHab}
    {parametre/cabinet/gerance/include/proprietaireNonOccupant.i}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremePNOCom &serialName=ttbaremePNOCom}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremePNOHab &serialName=ttbaremePNOHab}
    {parametre/cabinet/gerance/include/vacanceLocative.i}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeVacLocCom &serialName=ttbaremeVacLocCom}
    {parametre/cabinet/gerance/include/baremeGarantieLoyer.i &nomTable=ttbaremeVacLocHab &serialName=ttbaremeVacLocHab}
    {parametre/cabinet/gerance/include/garantieSpeciale.i}

    define private property mLogger      as class logHandler no-undo private get. private set.
    define private property gocollection as class collection no-undo get. set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.

    define dataset dsbeAssuranceGarantie
        for ttGarantieLoyer, ttbaremeGarantieLoyerCom, ttbaremeGarantieLoyerHab,
            ttProtectionJuridique, ttbaremeProtectionJuridiqueCom, ttbaremeProtectionJuridiqueHab,
            ttGarantieRisqueLocatif, ttbaremeGRLCom, ttbaremeGRLHab,
            ttProprietaireNonOccupant, ttbaremePNOCom, ttbaremePNOHab,
            ttVacanceLocative, ttbaremeVacLocCom, ttbaremeVacLocHab,
            ttGarantieSpeciale, ttBaremeGarantieSpeciale, ttRubriqueGarantieSpeciale,
            ttCombo, ttError

        data-relation garantieLoyerCommercial for ttGarantieLoyer, ttbaremeGarantieLoyerCom nested foreign-key-hidden
            relation-fields (ttGarantieLoyer.cTypeContrat,  ttbaremeGarantieLoyerCom.cTypeContrat,
                             ttGarantieLoyer.iNumeroContrat,ttbaremeGarantieLoyerCom.iNumeroContrat)

        data-relation garantieLoyerHabitation for ttGarantieLoyer, ttbaremeGarantieLoyerHab nested foreign-key-hidden
            relation-fields (ttGarantieLoyer.cTypeContrat,  ttbaremeGarantieLoyerHab.cTypeContrat,
                             ttGarantieLoyer.iNumeroContrat,ttbaremeGarantieLoyerHab.iNumeroContrat)

        data-relation protectionJuridiqueCommercial for ttProtectionJuridique, ttbaremeProtectionJuridiqueCom nested foreign-key-hidden
            relation-fields (ttProtectionJuridique.cTypeContrat,  ttbaremeProtectionJuridiqueCom.cTypeContrat,
                             ttProtectionJuridique.iNumeroContrat,ttbaremeProtectionJuridiqueCom.iNumeroContrat)

        data-relation protectionJuridiqueHabitation for ttProtectionJuridique, ttbaremeProtectionJuridiqueHab nested foreign-key-hidden
            relation-fields (ttProtectionJuridique.cTypeContrat,  ttbaremeProtectionJuridiqueHab.cTypeContrat,
                             ttProtectionJuridique.iNumeroContrat,ttbaremeProtectionJuridiqueHab.iNumeroContrat)

        data-relation garantieRisqueLocatifCommercial for ttGarantieRisqueLocatif, ttbaremeGRLCom nested foreign-key-hidden
            relation-fields (ttGarantieRisqueLocatif.cTypeContrat,  ttbaremeGRLCom.cTypeContrat,
                             ttGarantieRisqueLocatif.iNumeroContrat,ttbaremeGRLCom.iNumeroContrat)

        data-relation garantieRisqueLocatifHabitation for ttGarantieRisqueLocatif, ttbaremeGRLHab nested foreign-key-hidden
            relation-fields (ttGarantieRisqueLocatif.cTypeContrat,  ttbaremeGRLHab.cTypeContrat,
                             ttGarantieRisqueLocatif.iNumeroContrat,ttbaremeGRLHab.iNumeroContrat)

        data-relation proprietaireNonOccupantCommercial for ttProprietaireNonOccupant, ttbaremePNOCom nested foreign-key-hidden
            relation-fields (ttProprietaireNonOccupant.cTypeContrat,  ttbaremePNOCom.cTypeContrat,
                             ttProprietaireNonOccupant.iNumeroContrat,ttbaremePNOCom.iNumeroContrat)

        data-relation proprietaireNonOccupantHabitation for ttProprietaireNonOccupant, ttbaremePNOHab nested foreign-key-hidden
            relation-fields (ttProprietaireNonOccupant.cTypeContrat,  ttbaremePNOHab.cTypeContrat,
                             ttProprietaireNonOccupant.iNumeroContrat,ttbaremePNOHab.iNumeroContrat)

        data-relation vacanceLocativeCommercial for ttVacanceLocative, ttbaremeVacLocCom nested foreign-key-hidden
            relation-fields (ttVacanceLocative.cTypeContrat,  ttbaremeVacLocCom.cTypeContrat,
                             ttVacanceLocative.iNumeroContrat,ttbaremeVacLocCom.iNumeroContrat)

        data-relation vacanceLocativeHabitation for ttVacanceLocative, ttbaremeVacLocHab nested foreign-key-hidden
            relation-fields (ttVacanceLocative.cTypeContrat,  ttbaremeVacLocHab.cTypeContrat,
                             ttVacanceLocative.iNumeroContrat,ttbaremeVacLocHab.iNumeroContrat)

        data-relation garantieSpecialeBareme for ttgarantieSpeciale, ttBaremeGarantieSpeciale nested foreign-key-hidden
            relation-fields (ttgarantieSpeciale.cTypeContrat,  ttBaremeGarantieSpeciale.cTypeContrat,
                             ttgarantieSpeciale.iNumeroContrat,ttBaremeGarantieSpeciale.iNumeroContrat)

        data-relation garantieSpecialeRubrique for ttgarantieSpeciale, ttRubriqueGarantieSpeciale nested foreign-key-hidden
            relation-fields (ttgarantieSpeciale.cTypeContrat,  ttRubriqueGarantieSpeciale.cTypeContrat,
                             ttgarantieSpeciale.iNumeroContrat,ttRubriqueGarantieSpeciale.iNumeroContrat).                     .

    constructor public beAssuranceGarantie():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super (dataset dsbeAssuranceGarantie:handle).
        beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
        assign
            mLogger      = beMagiToken:mLogger
            goCollection = new collection ()
        .
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void ReadbeAssuranceGarantie(pcFiltre as longchar, output dataset dsbeAssuranceGarantie):
        /*------------------------------------------------------------------------------
        Purpose:  Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc                  as handle    no-undo.
        define variable vhttFilter              as handle    no-undo.
        define variable vhBuffer                as handle    no-undo.
        define variable vrRowId                 as rowid     no-undo.
        define variable vcTypeAssurance         as character no-undo.
        define variable vcTypeAssuranceSpeciale as character no-undo.
        define variable viNumeroAssurance       as integer   no-undo.
        define variable vcTypeTraitement        as character no-undo.

        dataset dsbeAssuranceGarantie:empty-dataset().
        if pcFiltre begins "~{" and pcFiltre <> "~{~}" then do:
            create temp-table vhttFilter.
            vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
            if not error-status:error then do:
                vhBuffer = vhttFilter:default-buffer-handle.
                vhBuffer:find-first() no-error.
                if vhBuffer:available then do:
                    vrRowId                 = to-rowid(vhBuffer::rRowid)          no-error.
                    vcTypeAssurance         = vhBuffer::cTypeAssurance            no-error.
                    vcTypeAssuranceSpeciale = vhBuffer::cTypeAssuranceSpeciale    no-error.
                    viNumeroAssurance       = integer(vhBuffer::iNumeroAssurance) no-error.
                    vcTypeTraitement        = vhBuffer::cTypeTraitement           no-error.
                end.
            end.
            delete object vhttFilter.
        end.
        case vcTypeAssurance:
            when "GARANTIELOYER"           then readGarantieLoyer          (viNumeroAssurance, vcTypeTraitement, vrRowId).
            when "PROTECTIONJURIDIQUE"     then readProtectionJuridique    (viNumeroAssurance, vcTypeTraitement, vrRowId).
            when "GARANTIERISQUELOCATIF"   then readGarantieRisqueLocatif  (viNumeroAssurance, vcTypeTraitement, vrRowId).
            when "PROPRIETAIRENONOCCUPANT" then readProprietaireNonOccupant(viNumeroAssurance, vcTypeTraitement, vrRowId).
            when "VACANCELOCATIVE"         then readVacanceLocative        (viNumeroAssurance, vcTypeTraitement, vrRowId).
            when "GARANTIESPECIALE"        then readGarantieSpeciale       (vcTypeAssuranceSpeciale, vcTypeTraitement).
            otherwise do:
                vhProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProc({&error}, 211691, vcTypeAssurance).  // vue demandée inexistante.
                run getErrors   in vhProc(output table ttError).
            end.
        end case.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void UpdatebeAssuranceGarantie(pcFiltre as longchar, input-output dataset dsbeAssuranceGarantie):
        /*------------------------------------------------------------------------------
        Purpose:  Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc          as handle    no-undo.
        define variable vhttFilter      as handle    no-undo.
        define variable vhBuffer        as handle    no-undo.
        define variable vcTypeAssurance as character no-undo.

        if pcFiltre begins "~{" and pcFiltre <> "~{~}" then do:
            create temp-table vhttFilter.
            vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
            if not error-status:error then do:
                vhBuffer = vhttFilter:default-buffer-handle.
                vhBuffer:find-first() no-error.
                if vhBuffer:available then do:
                    vcTypeAssurance  = vhBuffer::cTypeAssurance  no-error.
                end.
            end.
            delete object vhttFilter.
        end.
        case vcTypeAssurance:
            when "GARANTIELOYER"           then updateGarantieLoyer().
            when "PROTECTIONJURIDIQUE"     then updateProtectionJuridique().
            when "GARANTIERISQUELOCATIF"   then updateGarantieRisqueLocatif().
            when "PROPRIETAIRENONOCCUPANT" then updateProprietaireNonOccupant().
            when "VACANCELOCATIVE"         then updateVacanceLocative().
            when "GARANTIESPECIALE"        then updateGarantieSpeciale().
            otherwise do:
                vhProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in vhProc({&error}, 211691, vcTypeAssurance).  // vue demandée inexistante.
                run getErrors   in vhProc(output table ttError).
            end.
        end case.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void createbeAssuranceGarantie(input-output dataset dsbeAssuranceGarantie):
        /*------------------------------------------------------------------------------
        Purpose: Create one or more new records
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void deletebeAssuranceGarantie(input-output dataset dsbeAssuranceGarantie):
        /*------------------------------------------------------------------------------
        Purpose: Delete a record
        Notes:
        ------------------------------------------------------------------------------*/
        super:DeleteData(dataset dsbeAssuranceGarantie by-reference).
        {outils/include/tryCatch.i}
    end method.

    method private logical readGarantieLoyer(piNumeroAssurance as integer, pcTypeTraitement as character, prRowId as rowid):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/garantieLoyer.p").
        case pcTypeTraitement:
            when "INITIALISATION" then run initGarantieLoyer      in vhProc(output table ttGarantieLoyer, output table ttbaremeGarantieLoyerCom, output table ttbaremeGarantieLoyerHab).
            when "COMBO"          then run initComboGarantieLoyer in vhProc(output table ttCombo).
            otherwise do:
                if prRowid <> ?
                then run getGarantieLoyerByRowid in vhProc(prRowid, output table ttGarantieLoyer, output table ttbaremeGarantieLoyerCom, output table ttbaremeGarantieLoyerHab).
                else run getGarantieLoyer        in vhProc(piNumeroAssurance, output table ttGarantieLoyer, output table ttbaremeGarantieLoyerCom, output table ttbaremeGarantieLoyerHab).
            end.
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateGarantieLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/garantieLoyer.p").
        run setGarantieLoyer in vhProc(table ttGarantieLoyer, table ttbaremeGarantieLoyerCom, table ttbaremeGarantieLoyerHab, table ttError).
        dataset dsbeAssuranceGarantie:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readProtectionJuridique(piNumeroAssurance as integer, pcTypeTraitement as character, prRowId as rowid):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/protectionJuridique.p").
        case pcTypeTraitement:
            when "INITIALISATION" then run initProtectionJuridique      in vhProc(output table ttProtectionJuridique, output table ttbaremeProtectionJuridiqueCom, output table ttbaremeProtectionJuridiqueHab).
            when "COMBO"          then run initComboProtectionJuridique in vhProc(output table ttCombo).
            otherwise do:
                if prRowid <> ?
                then run getProtectionJuridiqueByRowid in vhProc(prRowid, output table ttProtectionJuridique, output table ttbaremeProtectionJuridiqueCom, output table ttbaremeProtectionJuridiqueHab).
                else run getProtectionJuridique        in vhProc(piNumeroAssurance, output table ttProtectionJuridique, output table ttbaremeProtectionJuridiqueCom, output table ttbaremeProtectionJuridiqueHab).
                run getErrors in vhProc(output table ttError).
            end.
        end case.
    end method.

    method private logical updateProtectionJuridique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/protectionJuridique.p").
        run setProtectionJuridique in vhProc(table ttProtectionJuridique, table ttbaremeProtectionJuridiqueCom, table ttbaremeProtectionJuridiqueHab, table ttError).
        dataset dsbeAssuranceGarantie:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readGarantieRisqueLocatif(piNumeroAssurance as integer, pcTypeTraitement as character, prRowId as rowid):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/garantieRisqueLocatif.p").
        case pcTypeTraitement:
            when "INITIALISATION" then run initGarantieRisqueLocatif      in vhProc(output table ttGarantieRisqueLocatif, output table ttbaremeGRLCom, output table ttbaremeGRLHab).
            when "COMBO"          then run initComboGarantieRisqueLocatif in vhProc(output table ttCombo).
            otherwise do:
                if prRowid <> ?
                then run getGarantieRisqueLocatifByRowid in vhProc(prRowid, output table ttGarantieRisqueLocatif, output table ttbaremeGRLCom, output table ttbaremeGRLHab).
                else run getGarantieRisqueLocatif        in vhProc(piNumeroAssurance, output table ttGarantieRisqueLocatif, output table ttbaremeGRLCom, output table ttbaremeGRLHab).
            end.
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateGarantieRisqueLocatif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/garantieRisqueLocatif.p").
        run setGarantieRisqueLocatif in vhProc(table ttGarantieRisqueLocatif, table ttbaremeGRLCom, table ttbaremeGRLHab, table ttError).
        dataset dsbeAssuranceGarantie:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readProprietaireNonOccupant(piNumeroAssurance as integer, pcTypeTraitement as character, prRowId as rowid):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/proprietaireNonOccupant.p").
        case pcTypeTraitement:
            when "INITIALISATION" then run initProprietaireNonOccupant      in vhProc(output table ttProprietaireNonOccupant, output table ttbaremePNOCom, output table ttbaremePNOHab).
            when "COMBO"          then run initComboProprietaireNonOccupant in vhProc(output table ttCombo).
            otherwise do:
                if prRowid <> ?
                then run getProprietaireNonOccupantByRowid in vhProc(prRowid, output table ttProprietaireNonOccupant, output table ttbaremePNOCom, output table ttbaremePNOHab).
                else run getProprietaireNonOccupant        in vhProc(piNumeroAssurance, output table ttProprietaireNonOccupant, output table ttbaremePNOCom, output table ttbaremePNOHab).
            end.
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateProprietaireNonOccupant():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/proprietaireNonOccupant.p").
        run setProprietaireNonOccupant in vhProc(table ttProprietaireNonOccupant, table ttbaremePNOCom, table ttbaremePNOHab, table ttError).
        dataset dsbeAssuranceGarantie:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical readVacanceLocative(piNumeroAssurance as integer, pcTypeTraitement as character, prRowId as rowid):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/vacanceLocative.p").
        case pcTypeTraitement:
            when "INITIALISATION" then run initVacanceLocative      in vhProc(output table ttVacanceLocative, output table ttbaremeVacLocCom, output table ttbaremeVacLocHab).
            when "COMBO"          then run initComboVacanceLocative in vhProc(output table ttCombo).
            otherwise do:
                if prRowid <> ?
                then run getVacanceLocativeByRowid in vhProc(prRowid, output table ttVacanceLocative, output table ttbaremeVacLocCom, output table ttbaremeVacLocHab).
                else run getVacanceLocative        in vhProc(piNumeroAssurance, output table ttVacanceLocative, output table ttbaremeVacLocCom, output table ttbaremeVacLocHab).
            end.
        end case.
        run getErrors in vhProc(output table ttError).
    end method.

    method private logical updateVacanceLocative():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/vacanceLocative.p").
        run setVacanceLocative in vhProc(table ttVacanceLocative, table ttbaremeVacLocCom, table ttbaremeVacLocHab, table ttError).
        dataset dsbeAssuranceGarantie:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

   method private logical readGarantieSpeciale(pcTypeAssuranceSpeciale as character, pcTypeTraitement as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : pas d'initialisation, il n'y a jamais de création (ni suppression) de garantie spéciale dans l'ihm, lecture/màj seulement
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/garantieSpeciale.p").
        case pcTypeTraitement:
             when "COMBO" then run initComboGarantieSpeciale     in vhProc(output table ttCombo).
             otherwise run getGarantieSpeciale in vhProc(pcTypeAssuranceSpeciale, output table ttGarantieSpeciale, output table ttBaremeGarantieSpeciale, output table ttRubriqueGarantieSpeciale).
        end case.
        run getErrors in vhProc(output table ttError).
    end method.
    
    method private logical updateGarantieSpeciale():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModele("parametre/cabinet/gerance/garantieSpeciale.p").
        run setGarantieSpeciale in vhProc(table ttGarantieSpeciale, table ttBaremeGarantieSpeciale, table ttRubriqueGarantieSpeciale, table ttError).
        dataset dsbeAssuranceGarantie:empty-dataset().
        run getErrors in vhProc(output table ttError).
    end method.

    destructor public beAssuranceGarantie ( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
