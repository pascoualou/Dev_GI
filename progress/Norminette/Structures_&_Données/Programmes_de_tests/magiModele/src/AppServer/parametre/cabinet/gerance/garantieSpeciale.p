
/*------------------------------------------------------------------------
    File        : garantieSpeciale.p
    Purpose     : Paramétrage Garantie Speciale - 01020 à 01023
    Author(s)   : RF
    Created     : Fri Nov 10 11:47:01 CET 2017
    Notes       :
  ----------------------------------------------------------------------*/
using parametre.pclie.pclie.
using parametre.syspg.syspg.
using parametre.syspr.syspr.

{preprocesseur/type2contrat.i}
{preprocesseur/type2bareme.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/tva.i}
{parametre/cabinet/gerance/include/garantieSpeciale.i}
{application/include/combo.i}
{application/include/error.i}

define variable vlGestionCommerciauxActive  as logical   no-undo initial false.
define variable vlComptaCabinetActive       as logical   no-undo initial false.
define variable vcCollectifAssureurADB      as character no-undo.
define variable vcCodeAssureurADB           as character no-undo.
define variable vcLibelleAssureurADB        as character no-undo.
define variable vcCodeAssureurCabinet       as character no-undo.
define variable vcLibelleAssureurCabinet    as character no-undo.
define variable vcCompteComptableADB        as character no-undo.
define variable vcCompteComptableCabinet    as character no-undo.

function premierTypeAssuranceSpeciale returns character forward.

procedure getGarantieSpeciale:

    define input  parameter pcTypeAssuranceSpeciale as character no-undo.

    define output parameter table for ttGarantieSpeciale.
    define output parameter table for ttBaremeGarantieSpeciale.
    define output parameter table for ttRubriqueGarantieSpeciale.
    //define output parameter table for ttCombo.

    define buffer garan    for garan.
    define buffer bgaran   for garan.


    // Valeur non spécifiée - > positionnement sur le premier type valide

    if pctypeAssuranceSpeciale = "" or pctypeAssuranceSpeciale = ?
    then pcTypeAssuranceSpeciale = premierTypeAssuranceSpeciale().

    run chargeParametres(pcTypeAssuranceSpeciale).
    run chargeCombo(output table ttCombo).

    for first garan no-lock
        where garan.tpctt = pcTypeAssuranceSpeciale
          and garan.noctt = 1
          and garan.tpbar = "":

        run createTTGarantieSpeciale(buffer garan).
        run createTTBaremeGarantieSpeciale(garan.tpctt).
        run createTTRubriqueGarantieSpeciale(garan.tpctt).

    end.

    //outilCombo:getLibellesCombos(buffer ttGarantieSpeciale:handle,"", table ttCombo by-reference).

end procedure.

procedure setGarantieSpeciale:

    define input parameter table for ttGarantieSpeciale.
    define input parameter table for ttBaremeGarantieSpeciale.
    define input parameter table for ttRubriqueGarantieSpeciale.
    define input parameter table for ttError.

    define buffer garan   for garan.
    define buffer bgaran  for garan.
    define buffer pclie   for pclie.

    for first ttGarantieSpeciale
        where ttGarantieSpeciale.CRUD = "U":

        // Recherche Garantie Existante si modification
        find  garan no-lock
        where garan.tpctt = ttGarantieSpeciale.cTypeContrat
          and garan.tpbar = ""
        no-error.

        run controlesAvantValidation (buffer garan, buffer ttGarantieSpeciale).
        if mError:erreur() = yes then return.
    end.

    for first ttGarantieSpeciale
        where ttGarantieSpeciale.CRUD = "U":

        blocTransaction:
        do transaction:

            find garan exclusive-lock
            where rowid(garan) = ttGarantieSpeciale.rRowid no-wait no-error.

            if outils:isUpdated(buffer garan:handle, 'garan/garantie loyer: ', ttGarantieSpeciale.ctypeContrat, ttGarantieSpeciale.dtTimestamp)
            then undo blocTransaction, leave blocTransaction.

            assign
                garan.tpctt       = ttGarantieSpeciale.cTypeContrat
                garan.noctt       = 1
                garan.tpbar       = ""
                garan.nobar       = 0
                garan.cdper       = ttGarantieSpeciale.cCodePeriodicite
                garan.lbdiv       = ttGarantieSpeciale.cCodeModeleEdition
                garan.lbdiv2      = ttGarantieSpeciale.cModeComptabilisation
                garan.nbmca       = ttGarantieSpeciale.iNombreMoisMax
                garan.cdmsy       = mToken:cUser
                garan.dtmsy       = today
                garan.hemsy       = mtime
                .

            for each ttBaremeGarantieSpeciale
               where ttBaremeGarantieSpeciale.cTypeContrat   = ttGarantieSpeciale.cTypeContrat
                 and ttBaremeGarantieSpeciale.iNumeroContrat = ttGarantieSpeciale.iNumeroContrat:

                find  bgaran exclusive-lock
                where bgaran.tpctt = ttBaremeGarantieSpeciale.cTypeContrat
                  and bgaran.noctt = ttBaremeGarantieSpeciale.iNumeroContrat
                  and bgaran.nobar = ttBaremeGarantieSpeciale.iNumeroBareme
                no-wait no-error.

                if not available bgaran then undo blocTransaction, leave blocTransaction.

                assign
                    bgaran.txcot = ttBaremeGarantieSpeciale.dTauxCotisation
                    bgaran.txhon = ttBaremeGarantieSpeciale.dTauxHonoraire
                    bgaran.txRes = ttBaremeGarantieSpeciale.dTauxResultat
                    bgaran.cdmsy = garan.cdmsy
                    bgaran.dtmsy = garan.dtmsy
                    bgaran.hemsy = garan.hemsy
                    .
            end.

            for each ttRubriqueGarantieSpeciale
               where ttRubriqueGarantieSpeciale.cTypeContrat   = ttGarantieSpeciale.cTypeContrat
                 and ttRubriqueGarantieSpeciale.iNumeroContrat = ttGarantieSpeciale.iNumeroContrat:

                case ttRubriqueGarantieSpeciale.lSelectionRubrique:

                    when true then do:
                        // Créer pclie si inexistant
                        find  pclie no-lock
                        where pclie.tppar = "RUGAR"
                          and pclie.zon01 = ttGarantieSpeciale.cTypeContrat
                          and pclie.int01 = ttRubriqueGarantieSpeciale.iCodeRubrique
                        no-error.

                        if not available pclie
                        then do:
                            create pclie.
                            assign
                                pclie.tppar = "RUGAR"
                                pclie.zon01 = ttGarantieSpeciale.cTypeContrat
                                pclie.int01 = ttRubriqueGarantieSpeciale.iCodeRubrique
                                .
                        end.
                    end.

                    when false then do:
                        // supprimer pclie si existant
                        find first pclie exclusive-lock
                             where pclie.tppar = "RUGAR"
                               and pclie.zon01 = ttGarantieSpeciale.cTypeContrat
                               and pclie.int01 = ttRubriqueGarantieSpeciale.iCodeRubrique
                        no-wait no-error.

                        if locked(pclie) then undo blocTransaction, leave blocTransaction.
                        if available pclie then delete pclie.

                    end.

                end case.
            end.
        end.
    end.

end procedure.

procedure controlesAvantValidation private:

    /*------------------------------------------------------------------------------
    Purpose: Contrôle des informations saisies par l'utilisateur avant de faire l'update
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer garan for garan.
    define parameter buffer ttGarantieSpeciale for ttGarantieSpeciale.

    // à priori aucun contrôle, le contenu des combo suffit et n'interragit pas
    // je laisse la procédure en place au cas où...

end procedure.


procedure createTTGarantieSpeciale:
    define parameter buffer garan for garan.

    create ttGarantieSpeciale.

    assign
        ttGarantieSpeciale.cTypeContrat          = garan.tpctt
        ttGarantieSpeciale.iNumeroContrat        = 1

        ttGarantieSpeciale.cCodePeriodicite      = garan.cdper

        ttGarantieSpeciale.cModeComptabilisation = if garan.lbdiv2 ne "" then garan.lbdiv2 else "00000"

        ttGarantieSpeciale.cCodeModeleEdition    = if garan.lbdiv ne "" then garan.lbdiv else "00001"

        ttGarantieSpeciale.iNombreMoisMax        = garan.nbmca

        ttGarantieSpeciale.dtTimestamp           = datetime(garan.dtmsy,garan.hemsy)
        ttGarantieSpeciale.CRUD                  = "R"
        ttGarantieSpeciale.rRowid                = rowid(garan)
        .
        
    run chargeLibelle(buffer ttGarantieSpeciale).   

    case ttGarantieSpeciale.cModeComptabilisation:
        when "00001" then assign
                              ttGarantieSpeciale.cEntiteComptabilisation = outilTraduction:getLibelle(106399) // ADB
                              ttGarantieSpeciale.cNumeroCompte           = vcCompteComptableADB
                              ttGarantieSpeciale.cCodeFournisseur        = vcCodeAssureurADB
                              ttGarantieSpeciale.cLibelleFournisseur     = vcLibelleAssureurADB
                              .
        when "00002" then assign
                              ttGarantieSpeciale.cEntiteComptabilisation = outilTraduction:getLibelle(102975) // CABINET
                              ttGarantieSpeciale.cNumeroCompte           = vcCompteComptablecABINET
                              ttGarantieSpeciale.cCodeFournisseur        = vcCodeAssureurCabinet
                              ttGarantieSpeciale.cLibelleFournisseur     = vcLibelleAssureurCabinet
                              .

        otherwise         assign
                              ttGarantieSpeciale.cEntiteComptabilisation = ""
                              ttGarantieSpeciale.cNumeroCompte           = ""
                              ttGarantieSpeciale.cCodeFournisseur        = ""
                              ttGarantieSpeciale.cLibelleFournisseur     = ""
                              .
    end case.

end procedure.

procedure createTTBaremeGarantieSpeciale:
    define input  parameter pcTypeAssuranceSpeciale as character no-undo.

    empty temp-table ttBaremeGarantieSpeciale.

    for each garan no-lock
       where garan.tpctt = pcTypeAssuranceSpeciale
         and garan.nobar > 0:

        create ttBaremeGarantieSpeciale.
        assign
            ttBaremeGarantieSpeciale.cTypeContrat    = pcTypeAssuranceSpeciale
            ttBaremeGarantieSpeciale.iNumeroContrat  = 1

            ttBaremeGarantieSpeciale.iNumeroBareme   = garan.nobar
            ttBaremeGarantieSpeciale.dTauxCotisation = garan.txcot
            ttBaremeGarantieSpeciale.dTauxHonoraire  = garan.txhon
            ttBaremeGarantieSpeciale.dTauxResultat   = garan.txRes
            .
    end.
end procedure.


procedure createTTRubriqueGarantieSpeciale:
    define input  parameter pcTypeAssuranceSpeciale as character no-undo.

    empty temp-table ttRubriqueGarantieSpeciale.

    for each rubqt no-lock
       where rubqt.cdlib = 0
    break by rubqt.cdrub:

       create ttRubriqueGarantieSpeciale.
       assign
           ttRubriqueGarantieSpeciale.cTypeContrat       = pcTypeAssuranceSpeciale
           ttRubriqueGarantieSpeciale.iNumeroContrat     = 1

           ttRubriqueGarantieSpeciale.iCodeRubrique      = rubqt.CdRub
           ttRubriqueGarantieSpeciale.cLibelleRubrique   = outilTraduction:getLibelle(rubqt.nome1)
           ttRubriqueGarantieSpeciale.lSelectionRubrique = can-find(pclie no-lock
                                                              where pclie.tppar = "RUGAR"
                                                                and pclie.zon01 = pcTypeAssuranceSpeciale
                                                                and pclie.int01 = rubqt.CdRub)
           .
    end.
end.

procedure initComboGarantieSpeciale:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos de l'écran depuis la vue
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttcombo.

    run chargeParametres("").
    run chargeCombo(output table ttCombo).

end procedure.

procedure chargeCombo private:

    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumeroItem as integer no-undo.
    define variable vhproc       as handle  no-undo.
    define variable vlretour     as logical no-undo.
    define variable vhProcTVA    as handle  no-undo.
    define variable voSyspr            as class syspr.

    //define input  parameter pcTypeAssurance as character no-undo.
    define output parameter table for ttCombo.

    empty temp-table ttCombo.

    voSyspr = new syspr().


    // Périodicité
    voSyspr:getComboParametre("PDGAR","CMBPERIODICITE",output table ttCombo by-reference).

    // Comptabilisation
    voSyspr:getComboParametre("CPPIE","CMBCOMPTABILISATION",output table ttCombo by-reference).

    if not vlComptaCabinetActive then  // exclusion code "00002
    for first ttcombo
        where ttCombo.cNomCombo = "CMBCOMPTABILISATION"
          and ttCombo.cCode     = "00002":
        delete ttcombo.
    end.

    // Modèle édition
    voSyspr:getComboParametre("MDGAR","CMBMODELEEDITION", output table ttCombo by-reference).

    if not vlGestionCommerciauxActive then // exclusion code "00002"
    // exclusion code "00002"
    for first ttcombo
        where ttCombo.cNomCombo = "CMBMODELEEDITION"
          and ttCombo.cCode     = "00002":
        delete ttcombo.
    end.

    delete object voSyspr.

    for last ttCombo:
        viNumeroItem = ttCombo.iSeqId.
    end.

    // ASsurances Spéciales
    for first ifdparam no-lock
        where ifdparam.soc-dest = INT(mtoken:cRefGerance):

        for each ifdtpfac no-lock
           where ifdtpfac.soc-cd = ifdparam.soc-cd
             and ifdtpfac.typefac-cle >= "20" and ifdtpfac.typefac-cle <= "29"
        by INT(ifdtpfac.typefac-cle):
            //voOutilCombo:CreationCombo("CMBGARANTIESPECIALE","010" + ifdtpfac.typefac-cle,ifdtpfac.lib,"cTypeContrat","cLibelleTypeContrat", output table ttCombo by-reference).
            create ttCombo.
            assign
                viNumeroItem             = viNumeroItem + 1
                ttCombo.iSeqId           = viNumeroItem
                ttCombo.cNomCombo        = "CMBGARANTIESPECIALE"
                ttCombo.cCode            = "010" + ifdtpfac.typefac-cle
                ttCombo.cLibelle         = ifdtpfac.lib
                .
        end.

    end.


end procedure.


procedure chargeParametres private:

    define input  parameter pcTypeAssuranceSpeciale as character no-undo.

    define variable viSocieteCabinet       as integer no-undo.
    define variable viEtablissementCabinet as integer no-undo.


    for first ifdparam no-lock
        where soc-dest            = INT(mtoken:cRefGerance)
          and ifdparam.fg-facture = true:

        assign
            vlComptaCabinetActive = yes
            viSocieteCabinet       = ifdparam.soc-cd
            viEtablissementCabinet = ifdparam.etab-cd
            .
    end.

    for first  pclie no-lock
         where pclie.tppar = "GESCO"
           and pclie.zon01 = "00001":

        vlGestionCommerciauxActive = true.

    end.

    for first aparm no-lock
        where aparm.soc-cd  = INT(mtoken:cRefGerance)
          and aparm.etab-cd = 0
          and aparm.tppar   = "TGS"
          and aparm.cdpar   = substring(pcTypeAssuranceSpeciale,4,2):

        vcCollectifAssureurADB = entry(1, aparm.zone2, "|").
        if num-entries(aparm.zone2, "|")>= 2 then vcCodeAssureurADB        = entry(2, aparm.zone2, "|").
        if num-entries(aparm.zone2, "|")>= 4 then vcCodeAssureurCabinet    = entry(4, aparm.zone2, "|").
        if num-entries(aparm.zone2, "|")>= 5 then vcCompteComptableADB     = entry(5, aparm.zone2, "|").
        if num-entries(aparm.zone2, "|")>= 6 then vcCompteComptableCabinet = entry(6, aparm.zone2, "|").

        // Libelle Assureur ADB
        for first csscptcol no-lock
            where csscptcol.soc-cd     = INT(mtoken:cRefGerance)
              and csscptcol.etab-cd    = 8500
              and csscptcol.sscoll-cle = vcCollectifAssureurADB:

            for first ccpt no-lock
                where ccpt.soc-cd   = csscptcol.soc-cd
                  and ccpt.coll-cle = csscptcol.coll-cle
                  and ccpt.cpt-cd   = vcCodeAssureurADB:

                vcLibelleAssureurADB = ccpt.lib.

            end.
        end.

        // Libelle Assureur Cabinet
        for first csscpt no-lock
            where csscpt.soc-cd  = viSocieteCabinet
              and csscpt.etab-cd = viEtablissementCabinet
              and csscpt.cpt-cd  = vcCodeAssureurCabinet:

            vcLibelleAssureurCabinet = csscpt.lib.
        end.
    end.
end procedure.

procedure chargeLibelle:
    define parameter buffer ttGarantieSpeciale for ttGarantieSpeciale.
    
    assign
        ttGarantieSpeciale.cLibellePeriodicite      = outilTraduction:getLibelleParam("PDGAR",ttGarantieSpeciale.cCodePeriodicite)
        ttGarantieSpeciale.cLibelleComptabilisation = outilTraduction:getLibelleParam("CPPIE",ttGarantieSpeciale.cModeComptabilisation)
        ttGarantieSpeciale.cLibelleModeleEdition    = outilTraduction:getLibelleParam("MDGAR",ttGarantieSpeciale.cCodeModeleEdition)
        .
    
     for first ifdparam no-lock
         where ifdparam.soc-dest = INT(mtoken:cRefGerance):

        for first ifdtpfac no-lock
            where ifdtpfac.soc-cd      = ifdparam.soc-cd
              and ifdtpfac.typefac-cle = substring(ttGarantieSpeciale.cTypeContrat,4,2):
          
            ttGarantieSpeciale.cLibelleTypeContrat = ifdtpfac.lib.
                  
        end.         
     end.
end procedure.

function premierTypeAssuranceSpeciale returns character ():

    for first ifdparam no-lock
        where ifdparam.soc-dest = INT(mtoken:cRefGerance):

        for first ifdtpfac no-lock
           where ifdtpfac.soc-cd = ifdparam.soc-cd
             and ifdtpfac.typefac-cle >= "20" and ifdtpfac.typefac-cle <= "29"
        by INT(ifdtpfac.typefac-cle):
            return "010" + ifdtpfac.typefac-cle.
        end.
    end.

end function.

