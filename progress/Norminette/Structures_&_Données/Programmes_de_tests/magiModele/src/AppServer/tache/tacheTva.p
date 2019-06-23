/*------------------------------------------------------------------------
File        : tacheTva.p
Purpose     : tache tva
Author(s)   : GGA - 2017/08/03
Notes       : a partir de adb/tach/SynmttTacheTva.p adb/tach/prmmttac.p adb/tach/prmobstd.p
------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/codePeriode.i}
{preprocesseur/type2role.i}
{preprocesseur/type2honoraire.i}
{preprocesseur/type2bien.i}

using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tache.i}
{adblib/include/cttac.i}
{tache/include/tacheTva.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{application/include/error.i}
{adblib/include/incctrpa.i}
{parametre/cabinet/gerance/include/paramTva.i}
{comm/include/declatva.i}
define variable gcCentrePaiementImmeuble as character no-undo.

procedure getTva:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define output parameter table for ttTacheTva.
    define output parameter table for ttProrataParExercice.

    define variable vcInfoDepRec as character no-undo.
    define variable vhProc       as handle    no-undo.
    define variable vlretour     as logical   no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttTacheTva.
    empty temp-table ttProrataParExercice.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run rechCentrePaiementImmeuble (ctrat.tpcon, ctrat.nocon, ctrat.ntcon).    
    for last tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-TVA}:
        create ttTacheTva.
        assign
            ttTacheTva.iNumeroTache            = tache.noita
            ttTacheTva.cTypeContrat            = tache.tpcon
            ttTacheTva.iNumeroContrat          = tache.nocon
            ttTacheTva.cTypeTache              = tache.tptac
            ttTacheTva.iChronoTache            = tache.notac
            ttTacheTva.daActivation            = tache.dtdeb
            ttTacheTva.daFin                   = tache.dtree
            ttTacheTva.cTypeRegime             = tache.ntges
            ttTacheTva.cLibelleRegime          = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-tva}, tache.ntges)
            ttTacheTva.cTypeDeclaration        = tache.tpges
            ttTacheTva.cLibelleDeclaration     = outilTraduction:getLibelleProgZone2("R_TAD", {&TYPETACHE-tva}, tache.tpges)
            ttTacheTva.cTypePeriode            = tache.pdges
            ttTacheTva.cLibellePeriode         = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-tva}, tache.pdges)
            ttTacheTva.lReglement              = (tache.cdreg = "21001")
            ttTacheTva.cCentreImpot            = tache.dcreg
            ttTacheTva.cCentreRecette          = tache.utreg           
            ttTacheTva.iCodeHonoraire          = integer(tache.cdhon)
            ttTacheTva.iDepotAuPlusTard        = tache.joumax
            ttTacheTva.cActivitePrinc          = tache.lbdiv4
            ttTacheTva.cCodeTvaConsRev         = tache.ntreg
            ttTacheTva.cLibelleTvaConsRev      = (if ttTacheTva.cCodeTvaConsRev = "1" then outilTraduction:getLibelle(701268) /*Conservé*/ else outilTraduction:getLibelle(701270) /*Reversé*/ )
            ttTacheTva.cNoSie01                = substring(tache.nosie, 1 , 3, 'character')
            ttTacheTva.cNoSie02                = substring(tache.nosie, 4 , 2, 'character')
            ttTacheTva.cNoSie03                = substring(tache.nosie, 6 , 2, 'character')
            ttTacheTva.iNoDossier              = integer(tache.dossier)
            ttTacheTva.iNoCle                  = integer(tache.nocle)
            ttTacheTva.iCodeCdir               = integer(tache.cdir)
            ttTacheTva.iCodeService            = integer(tache.service)
            ttTacheTva.lSaisieManuelleProrata  = (if tache.lbmotif <> "" then tache.lbmotif = "ProrataTVAManu"
                                                                         else can-find(first aparm no-lock where aparm.tppar = "DEBOUR"))
            ttTacheTva.iMandatDeclaration      = (if tache.etab-cd <> ? then tache.etab-cd else 0)
            ttTacheTva.cCentrePaiementImmeuble = gcCentrePaiementImmeuble
            ttTacheTva.cTypeCentreImpot        = "CDI" 
            ttTacheTva.cTypeCentreRecette      = "ODB"
            ttTacheTva.dtTimestamp             = datetime(tache.dtmsy, tache.hemsy)
            ttTacheTva.CRUD                    = 'R'
            ttTacheTva.rRowid                  = rowid(tache)
        .
        /*les libelles sont forces apres chargement combo dans le pgm initial */ 
        if ttTacheTva.cTypeRegime = "18001" then ttTacheTva.cLibelleRegime = outilTraduction:getLibelle(1000440).   //Simplifié
        if ttTacheTva.cTypeRegime = "18002" then ttTacheTva.cLibelleRegime = outilTraduction:getLibelle(1000441).   //Réel normal

        if trim(entry(1, tache.pdreg, "#")) > ""
        then assign
             ttTacheTva.cCodeSiret  = entry(1,tache.pdreg,"#")
             ttTacheTva.cCodeNic    = if num-entries(tache.pdreg,"#") >= 2 then entry(2,tache.pdreg,"#") else ""
             ttTacheTva.cCodeApe    = if num-entries(tache.pdreg,"#") >= 3 then entry(3,tache.pdreg,"#") else ""
             ttTacheTva.cTvaIntra   = if num-entries(tache.pdreg,"#") >= 4 then entry(4,tache.pdreg,"#") else ""
        .
        vcInfoDepRec = tache.lbdiv.
        if vcInfoDepRec > ""
        then if num-entries(vcInfoDepRec, "#") = 4
            then assign
                ttTacheTva.cCodeRecette = entry(3, vcInfoDepRec, "#")
                ttTacheTva.cCodeDepense = entry(4, vcInfoDepRec, "#")
            .
            else assign
                ttTacheTva.cCodeRecette = "1"
                ttTacheTva.cCodeDepense = "2"
            .
        else assign
            ttTacheTva.cCodeRecette = "2"
            ttTacheTva.cCodeDepense = "1"
        .
        assign
            ttTacheTva.cLibelleRecette = (if ttTacheTva.cCodeRecette = "1" then outilTraduction:getLibelle(100169) /*Débit*/ else outilTraduction:getLibelle(701217) /*Encaissement*/ )
            ttTacheTva.cLibelleDepense = (if ttTacheTva.cCodeDepense = "1" then outilTraduction:getLibelle(100169) /*Débit*/ else outilTraduction:getLibelle(103781) /*Décaissement*/ )
        .  
        for first honor no-lock
            where honor.tphon = {&TYPEHONORAIRE-TVA}
              and honor.cdhon = ttTacheTva.iCodeHonoraire:
            if honor.lbhon <> ""
            then ttTacheTva.cLibelleCodeHonoraire = substitute('&1-&2', outilTraduction:getLibelleProg("O_NTH", honor.nthon), honor.lbhon). 
            else ttTacheTva.cLibelleCodeHonoraire = outilTraduction:getLibelleProg("O_NTH", honor.nthon). 
        end.
        run lectInfoProrata (buffer tache).
        run rechSiTvaDecl (integer(mtoken:cRefGerance), piNumeroMandat, output ttTacheTva.lTvaTraite).
    end.

end procedure.

procedure lectInfoProrata private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer tache for tache.

    define variable viCompteur as integer   no-undo.
    define variable viPcTvaExo as integer   no-undo.
    define variable vcEntry    as character no-undo.

    define buffer vbttProrataParExercice for ttProrataParExercice.

    empty temp-table ttProrataParExercice.

    if tache.lbdiv2 > "" and num-entries(tache.lbdiv2, separ[1]) >= 3
    then do viCompteur = 1 to num-entries(tache.lbdiv2, separ[2]):      /* Nouveau stockage */
        vcEntry = entry(viCompteur, tache.lbdiv2, separ[2]).
        if num-entries(vcEntry, separ[1] ) >= 3
        then do:
            create ttProrataParExercice.
            if integer(entry(3, vcEntry, separ[1])) <> 100             /* ajout SY le 05/06/2009 : si encore ancien proratas stockés (année 2004) */
            then viPcTvaExo = integer(entry(2, vcEntry, separ[1])) * 100 / integer(entry(3, vcEntry, separ[1])).
            else viPcTvaExo = integer(entry(2, vcEntry, separ[1])).
            assign
                ttProrataParExercice.iExercice = integer(entry(1, vcEntry, separ[1]))
                ttProrataParExercice.iNumerateur = viPcTvaExo
                ttProrataParExercice.iDenominateur = 100
                ttProrataParExercice.dPrctAssujettissement = integer(entry(4, vcEntry, separ[1])) / 100
            no-error.
            if error-status:error then ttProrataParExercice.dPrctAssujettissement = 100.
            ttProrataParExercice.dPrctTaxation = integer(entry(5, vcEntry, separ[1])) / 100 no-error.
            if error-status:error then ttProrataParExercice.dPrctTaxation = ttProrataParExercice.iNumerateur.                  /* initialisé à l'ancien prorata */
        end.
    end.
    else do:                                                                                 /*Ancien stockage -> remis en pourcentage*/
        create ttProrataParExercice.
        assign
            ttProrataParExercice.iExercice = 2004
            ttProrataParExercice.iNumerateur = integer(entry(1, tache.lbdiv, "#")) * 100 / integer(entry(2, tache.lbdiv, "#"))
            ttProrataParExercice.iDenominateur = 100
            ttProrataParExercice.dPrctAssujettissement = 100
            ttProrataParExercice.dPrctTaxation = ttProrataParExercice.iNumerateur
        .
    end.
    do viCompteur = (if num-entries(tache.lbdiv2, separ[1]) > 1 then integer(entry(1, tache.lbdiv2, separ[1])) else 2004) to year(today):
        if not can-find(first ttProrataParExercice where ttProrataParExercice.iExercice = viCompteur)
        then do:
            find last ttProrataParExercice where ttProrataParExercice.iExercice < viCompteur no-error.
            create vbttProrataParExercice.
            assign
                vbttProrataParExercice.iExercice = viCompteur
                vbttProrataParExercice.iNumerateur    = ttProrataParExercice.iNumerateur
                vbttProrataParExercice.iDenominateur = 100
                vbttProrataParExercice.dPrctAssujettissement  = ttProrataParExercice.dPrctAssujettissement
                vbttProrataParExercice.dPrctTaxation     = ttProrataParExercice.dPrctTaxation
            .
        end.
    end.

end procedure.

procedure initComboTva:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo. 

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg as class syspg no-undo.
  
    empty temp-table ttCombo.
    voSyspg = new syspg().
    voSyspg:creationComboSysPgZonXX("R_TAG", "TYPEREGIME"     , "L", {&TYPETACHE-tva}, output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_TAD", "TYPEDECLARATION", "L", {&TYPETACHE-tva}, output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_TPR", "TYPEPERIODE"    , "L", {&TYPETACHE-tva}, output table ttCombo by-reference).
    voSyspg:creationttCombo("TVA-CONSERVE", "1", outilTraduction:getLibelle(701268), output table ttCombo by-reference).  //Conservé
    voSyspg:creationttCombo("TVA-CONSERVE", "2", outilTraduction:getLibelle(701270), output table ttCombo by-reference).  //Reversé
    voSyspg:creationttCombo("TVA-RECETTE",  "1", outilTraduction:getLibelle(100169), output table ttCombo by-reference).  //Débit
    voSyspg:creationttCombo("TVA-RECETTE",  "2", outilTraduction:getLibelle(701217), output table ttCombo by-reference). //Encaissement
    voSyspg:creationttCombo("TVA-DEPENSE",  "1", outilTraduction:getLibelle(100169), output table ttCombo by-reference).  //Débit
    voSyspg:creationttCombo("TVA-DEPENSE",  "2", outilTraduction:getLibelle(103781), output table ttCombo by-reference). //Décaissement
    if mtoken:cRefGerance <> "01501"                                    // DM 1010/0218 supprimer annuel forfait si pas icade
    then for first ttCombo
       where ttCombo.cNomCombo = "TYPEPERIODE"
         and ttCombo.cCode = "20032":
        delete ttCombo.
    end.
    /*les libelles sont forces apres chargement combo dans le pgm initial */ 
    for first ttCombo
       where ttCombo.cNomCombo = "TYPEREGIME"
         and ttCombo.cCode = "18001":
        ttCombo.cLibelle = outilTraduction:getLibelle(1000440).   //Simplifié
    end.
    for first ttCombo
       where ttCombo.cNomCombo = "TYPEREGIME"
         and ttCombo.cCode = "18002":
        ttCombo.cLibelle = outilTraduction:getLibelle(1000441).   //Réel normal
    end.
    delete object voSyspg.

end procedure.

procedure setTva:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheTva.
    define input parameter table for ttProrataParExercice.
    define input parameter table for ttError.

    define variable voSyspg as class syspg no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    for first ttTacheTva
    where lookup(ttTacheTva.CRUD, "C,U,D") > 0:
        find first ctrat no-lock                                             //recherche mandat
             where ctrat.tpcon = ttTacheTva.cTypeContrat
               and ctrat.nocon = ttTacheTva.iNumeroContrat no-error.
        if not available ctrat
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        find last tache no-lock
        where tache.tpcon = ttTacheTva.cTypeContrat
          and tache.nocon = ttTacheTva.iNumeroContrat
          and tache.tptac = {&TYPETACHE-TVA} no-error.
        if not available tache
        and lookup(ttTacheTva.CRUD, "U,D") > 0
        then do:
            mError:createError({&error}, 1000413). //modification d'une tache inexistante
            return.
        end.
        if available tache
        and ttTacheTva.CRUD = "C" 
        then do:
            mError:createError({&error}, 1000412). //création d'une tache existante
            return.
        end.       
        run rechCentrePaiementImmeuble (ctrat.tpcon, ctrat.nocon, ctrat.ntcon).     
        voSyspg = new syspg().
        run verZonSai (buffer ctrat, buffer ttTacheTva, voSyspg).
        delete object voSyspg.
        if mError:erreur() = yes then return.
        run majtbltch (buffer ttTacheTva).
    end.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat      for ctrat.
    define parameter buffer ttTacheTva for ttTacheTva.
    define input parameter poSyspg as class syspg no-undo.

    define variable viNoMandant as integer no-undo.
    define variable vlMandatOK  as logical no-undo.
    define variable vlSiretOk   as logical no-undo.
  
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    define buffer vbtache for tache.

    if ttTacheTva.daActivation = ?
    then do:
        mError:createError({&error}, 100299).
        return.
    end.
    if ttTacheTva.daActivation < ctrat.dtini
    then do:
        mError:createErrorGestion({&error}, 100678, "").
        return.
    end.
    if poSyspg:isParamExist("R_TAG", {&TYPETACHE-tva}, ttTacheTva.cTypeRegime) = no     
    then do:
        mError:createError({&error}, 1000457).                      //type régime invalide   
        return.
    end.
    if poSyspg:isParamExist("R_TAD", {&TYPETACHE-tva}, ttTacheTva.cTypeDeclaration) = no     
    then do:
        mError:createError({&error}, 1000458).                  //type déclaration invalide
        return.
    end.
    if ttTacheTva.cTypeDeclaration = "19002"
    and ttTacheTva.cCentreImpot > ""
    then do:
        mError:createError({&error}, 1000442).           //centre impôt doit être blanc si déclaration partielle
        return.    
    end.
    if ttTacheTva.cTypeDeclaration = "19001"
    and (ttTacheTva.cCentreImpot = ? or ttTacheTva.cCentreImpot = "")
    then do:
        mError:createError({&error}, 100337).
        return.
    end.
    if ttTacheTva.cCentreImpot > "" 
    and not can-find(first orsoc no-lock
                     where orsoc.tporg = "CDI"
                       and orsoc.ident = ttTacheTva.cCentreImpot)
    then do:
        mError:createError({&error}, 1000443).         //Centre des impôts inconnu 
        return.
    end.
    if poSyspg:isParamExist("R_TPR", {&TYPETACHE-tva}, ttTacheTva.cTypePeriode) = no  
    then do:  
        mError:createError({&error}, 1000456).                 //période invalide
        return.
    end.
    if ttTacheTva.cTypePeriode = "20032" and mtoken:cRefGerance <> "01501"        /* DM 1010/0218 annuel forfait/normal autorisé uniquement pour icade */
    then do:
        mError:createError({&error}, 1000444).              //Période annuel forfait non autorisée
        return.
    end.
    /* Controle régime et periode */
    if ttTacheTva.cTypeRegime = "18002"
    and lookup(ttTacheTva.cTypePeriode, "20032,20031") > 0                       /* Annuel forfait/normal */
    then do:
        mError:createError({&error}, 1000445).       //Période annuel forfait/annuel normal non autorisé avec le régime réel normal
        return.
    end.
    if ttTacheTva.cTypeRegime = "18001"
    and lookup(ttTacheTva.cTypePeriode, "20001,20002") > 0                       /* Mensuelle/Trimestrielle */
    then do:
        mError:createError({&error}, 1000446).        //Période mensuelle/trimestrielle non autorisé avec le régime simplifié
        return.
    end.
    for first sys_pg no-lock
        where sys_pg.tppar = "O_PRD"
          and sys_pg.cdpar = ttTacheTva.cTypePeriode:
        if integer(sys_pg.zone6) <> 12
        and ttTacheTva.iDepotAuPlusTard = 0
        then do:
            mError:createError({&error}, 1000447).        //Vous devez saisir le jour limite de dépôt de la déclaration
            return.
        end.
    end.
    if ttTacheTva.lReglement = no
    and ttTacheTva.cCentreRecette > ""
    then do:
        mError:createError({&error}, 1000448).           //centre recette doit être blanc si règlement est à non
        return.    
    end.
    if ttTacheTva.lReglement = yes
    and (ttTacheTva.cCentreRecette = ? or ttTacheTva.cCentreRecette = "")
    then do:
        mError:createError({&error}, 100340).
        return.
    end.
    if ttTacheTva.cCentreRecette > "" 
    and not can-find(first orsoc no-lock
                     where orsoc.tporg = "ODB"
                       and orsoc.ident = ttTacheTva.cCentreRecette)
    then do:
        mError:createError({&error}, 1000449).              //Centre recette inconnu
        return.
    end.
    
    if (ctrat.ntcon = {&NATURECONTRAT-mandatLocation} or ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue})
    and gcCentrePaiementImmeuble <> "" 
    and ttTacheTva.cCentreRecette <> gcCentrePaiementImmeuble 
    then do:
        if outils:questionnaire(109007, table ttError by-reference) <= 2
        then return.
    end.
    if not can-find (first honor no-lock
                     where honor.tphon = {&TYPEHONORAIRE-TVA}
                       and honor.cdhon = ttTacheTva.iCodeHonoraire)
    then do:
        mError:createError({&error}, 1000450).            //Code honoraire inexistant
        return.
    end.
    if ttTacheTva.cCodeSiret = ? or ttTacheTva.cCodeNic = ""
    then do:
        mError:createError({&error}, 103776).
        return.
    end.
    if ttTacheTva.cTvaIntra = ? or ttTacheTva.cTvaIntra = ""
    then do:
        mError:createErrorGestion({&information}, 108060, "").
    end.
    if ttTacheTva.cCodeSiret = ? or ttTacheTva.cCodeSiret = ""
    then do:
        mError:createError({&error}, 103776).
        return.    
    end.  
    if ttTacheTva.cCodeSiret > ""
    and ttTacheTva.cTvaIntra > ""
    and substring(ttTacheTva.cTvaIntra, 5, 9, 'character') <> ttTacheTva.cCodeSiret
    then do:
        mError:createError({&error}, 108059).
        return.
    end.
    // Verification du NIC
    if ttTacheTva.cCodeNic = ? or ttTacheTva.cCodeNic = ""
    then do:
        mError:createError({&error}, 103777).
        return.    
    end.  
    // Verification du code APE
    if ttTacheTva.cCodeApe = ? or ttTacheTva.cCodeApe = ""
    then do:
        mError:createError({&error}, 103778).
        return.    
    end.  
    if length(ttTacheTva.cCodeApe) < 5
    then do:
        mError:createError({&error}, 103532).     //Code APE invalide (5 caractères)
        return.    
    end.  
    vlSiretOk = controleSiren(ttTacheTva.cCodeSiret, ttTacheTva.cCodeNic).
    if vlSiretOk = no
    then do:
        mError:createError({&error}, 103519).
        return.    
    end.    
    if ttTacheTva.cTypeRegime = "18002"
    and ttTacheTva.cCodeRecette = "1"
    and ttTacheTva.cCodeDepense = "2"
    then do:
        mError:createErrorGestion({&error}, 103789, "").
        return.    
    end.   
    if ttTacheTva.cTypeRegime = "18001"
    and (ttTacheTva.cCodeRecette = "1" and ttTacheTva.cCodeDepense = "2" or ttTacheTva.cCodeRecette = "1" and ttTacheTva.cCodeDepense = "1")
    then do:
        mError:createErrorGestion({&error}, 103789, "").
        return.    
    end.   
    //Verification des proratas de TVA par exercice
    for each ttProrataParExercice:
        if ttProrataParExercice.dPrctTaxation <> ttProrataParExercice.iNumerateur
        then do:
            mError:createError({&error}, 1000451).            //Le taux de taxation doit être égal au prorata
            return.    
        end.
        if ttProrataParExercice.iNumerateur > ttProrataParExercice.iDenominateur 
        then do:
            /* Le numérateur doit être inférieur ou égal au dénominateur*/
            mError:createError({&error}, 102581).
            return.    
        end.
        if ttProrataParExercice.dPrctTaxation > 100 
        then do:
            mError:createError({&error}, 1000452).          //Le taux de taxation doit être inférieur ou égal à 100%
            return.    
        end.
        if ttProrataParExercice.dPrctTaxation = ? 
        then do:
            mError:createError({&error}, 1000453).       //Le taux de taxation doit être compris entre 0% et 100%
            return.    
        end.
    end.        
    if ttTacheTva.lSaisieManuelleProrata = yes and can-find(first iscimdt no-lock where iscimdt.etab-cd = integer(mtoken:cRefPrincipale)) 
    then do:
        mError:createError({&error}, 1000454).           //Ce mandat est paramétré dans les transferts SCI. Vous ne pouvez pas activer le prorata de TVA manuel.
        return.
    end.
    if ttTacheTva.iMandatDeclaration <> 0 
    then do:
        /* Ce mandat a-t-il une tache tva et est-il rattaché au mandant ? */
        for first intnt no-lock                                                          //recuperation mandant
            where intnt.tpcon = ttTacheTva.cTypeContrat
              and intnt.nocon = ttTacheTva.iNumeroContrat
              and intnt.tpidt = {&TYPEROLE-mandant}:
            viNoMandant = intnt.noidt.
        end.
        vlMandatOK = no.
        for first intnt no-lock  
            where intnt.tpcon = ttTacheTva.cTypeContrat
              and intnt.tpidt = {&TYPEROLE-mandant}
              and intnt.noidt = viNoMandant
              and intnt.nocon = ttTacheTva.iMandatDeclaration 
        , first vbtache no-lock
          where vbtache.tpcon = intnt.tpcon
            and vbtache.nocon = intnt.nocon
            and vbtache.tptac = {&TYPETACHE-TVA}:
            vlMandatOK = yes.
        end.
        if vlMandatOK = no
        then do :
            mError:createError({&error}, 1000455).         //La tache TVA de ce mandat de déclaration n'est pas activée ou le mandat de déclaration n'est pas rattaché à ce mandant
            return.
        end.
    end.

end procedure.

procedure majtbltch private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheTva for ttTacheTva.

    define variable vhTache     as handle    no-undo.
    define variable vhCttac     as handle    no-undo.
    define variable vcLbTmppdt2 as character no-undo.
    define variable viNoTvaUse  as integer   no-undo.
    define variable vdTxAssUse  as decimal   no-undo.
    define variable vdTxTaxUse  as decimal   no-undo.
    define variable vcCdTvaNum  as character no-undo. 
    define variable vcCdTvaDen  as character no-undo. 

    define buffer tache for tache.

    /* en modification il faut garder en memoire les anciennes valeurs dans lbdiv */
    for last tache no-lock
       where tache.tpcon = ttTacheTva.cTypeContrat
         and tache.nocon = ttTacheTva.iNumeroContrat
         and tache.tptac = {&TYPETACHE-TVA}:
        assign
            vcCdTvaNum = entry(1, tache.lbdiv, "#")
            vcCdTvaDen = entry(2, tache.lbdiv, "#")
        .  
    end.

    /* TVA / année */
    for each ttProrataParExercice:
        if viNoTvaUse <> ttProrataParExercice.iNumerateur
        or vdTxAssUse <> ttProrataParExercice.dPrctAssujettissement
        or vdTxTaxUse <> ttProrataParExercice.dPrctTaxation
        then vcLbTmppdt2 = vcLbTmppdt2 + string(ttProrataParExercice.iExercice) + separ[1]
                                       + string(ttProrataParExercice.iNumerateur) + separ[1]
                                       + string(ttProrataParExercice.iDenominateur) + separ[1]
                                       + string(ttProrataParExercice.dPrctAssujettissement * 100) + separ[1]
                                       + string(ttProrataParExercice.dPrctTaxation * 100)
                                       + separ[2].
        assign
            viNoTvaUse = ttProrataParExercice.iNumerateur.
            vdTxAssUse = ttProrataParExercice.dPrctAssujettissement.
            vdTxTaxUse = ttProrataParExercice.dPrctTaxation.
    end.
    vcLbTmppdt2 = trim(vcLbTmppdt2, separ[2]).

    empty temp-table ttTache.
    create ttTache.
    assign
        ttTache.noita   = ttTacheTva.iNumeroTache
        ttTache.tpcon   = ttTacheTva.cTypeContrat
        ttTache.nocon   = ttTacheTva.iNumeroContrat
        ttTache.tptac   = ttTacheTva.cTypeTache
        ttTache.notac   = ttTacheTva.iChronoTache
        ttTache.dtdeb   = ttTacheTva.daActivation
        ttTache.ntges   = ttTacheTva.cTypeRegime
        ttTache.tpges   = ttTacheTva.cTypeDeclaration
        ttTache.pdges   = ttTacheTva.cTypePeriode
        ttTache.cdreg   = string(ttTacheTva.lReglement, "21001/21002")
        ttTache.ntreg   = ttTacheTva.cCodeTvaConsRev
        ttTache.pdreg   = substitute("&1#&2#&3#&4", ttTacheTva.cCodeSiret, ttTacheTva.cCodeNic, ttTacheTva.cCodeApe, ttTacheTva.cTvaIntra) 
        ttTache.dcreg   = ttTacheTva.cCentreImpot
        ttTache.utreg   = ttTacheTva.cCentreRecette
        ttTache.tphon   = {&TYPEHONORAIRE-TVA} when ttTacheTva.CRUD = "C"
        ttTache.cdhon   = string(ttTacheTva.iCodeHonoraire,"99999")
        ttTache.lbdiv   = substitute("&1#&2#&3#&4", vcCdTvaNum, vcCdTvaDen, ttTacheTva.cCodeRecette, ttTacheTva.cCodeDepense)    
        ttTache.lbdiv2  = vcLbTmpPdt2
        ttTache.nosie   = substitute("&1&2&3", string(ttTacheTva.cNoSie01, "X(3)"), string(ttTacheTva.cNoSie02, "X(2)"), string(ttTacheTva.cNoSie03, "X(2)"))
        ttTache.dossier = (if ttTacheTva.iNoDossier <> ? then string(ttTacheTva.iNoDossier) else "")
        ttTache.nocle   = (if ttTacheTva.iNoCle <> ? then string(ttTacheTva.iNoCle) else "")
        ttTache.cdir    = (if ttTacheTva.iCodeCdir <> ? then string(ttTacheTva.iCodeCdir) else "")
        ttTache.service = (if ttTacheTva.iCodeService <> ? then string(ttTacheTva.iCodeService) else "")
        ttTache.joumax  = ttTacheTva.iDepotAuPlusTard
        ttTache.dtree   = ttTacheTva.daFin
        ttTache.Lbdiv4  = ttTacheTva.cActivitePrinc
        ttTache.lbmotif = string(ttTacheTva.lSaisieManuelleProrata, "ProrataTVAManu/ProrataTVAAuto") 
        ttTache.etab-cd = ttTacheTva.iMandatDeclaration       
        ttTache.CRUD        = ttTacheTva.CRUD
        ttTache.dtTimestamp = ttTacheTva.dtTimestamp
        ttTache.rRowid      = ttTacheTva.rRowid
    .
    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).
    run destroy in vhTache.
    if mError:erreur() then return.

    empty temp-table ttCttac. 
    find first cttac no-lock
         where cttac.tpcon = ttTacheTva.cTypeContrat
           and cttac.nocon = ttTacheTva.iNumeroContrat
           and cttac.tptac = {&TYPETACHE-TVA} no-error.
    if not available cttac and lookup(ttTacheTva.CRUD, "U,C") > 0
    then do:
        create ttCttac.
        assign
            ttCttac.tpcon = ttTacheTva.cTypeContrat
            ttCttac.nocon = ttTacheTva.iNumeroContrat
            ttCttac.tptac = {&TYPETACHE-TVA}
            ttCttac.CRUD  = "C"
        .
        run adblib/cttac_CRUD.p persistent set vhCttac.
        run getTokenInstance in vhCttac(mToken:JSessionId).        
        run setCttac in vhCttac (table ttCttac by-reference).
        run destroy in vhCttac.            
        if mError:erreur() = yes then return.
    end.
    if available cttac and ttTacheTva.CRUD = "D"
    then do:
        create ttCttac.
        assign
            ttCttac.tpcon       = cttac.tpcon
            ttCttac.nocon       = cttac.nocon
            ttCttac.tptac       = cttac.tptac
            ttCttac.CRUD        = "D"
            ttCttac.rRowid      = rowid(cttac)
            ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
        .
        run adblib/cttac_CRUD.p persistent set vhCttac.
        run getTokenInstance in vhCttac(mToken:JSessionId).                
        run setCttac in vhCttac(table ttCttac by-reference).
        run destroy in vhCttac.
        if mError:erreur() then return.
    end.

end procedure.

procedure rechCentrePaiementImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose: recherche centre paiement immeuble
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define input parameter pcNatureMandat   as character no-undo.
    
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    define buffer tache   for tache.
  
    if pcNatureMandat = {&NATURECONTRAT-mandatLocation} or pcNatureMandat = {&NATURECONTRAT-mandatLocationDelegue}
    then for first intnt no-lock
             where intnt.tpcon = pcTypeMandat
               and intnt.nocon = piNumeroMandat
               and intnt.tpidt = {&TYPEBIEN-immeuble}
         , first vbintnt no-lock
           where vbintnt.tpcon = {&TYPECONTRAT-construction}
             and vbintnt.tpidt = intnt.tpidt
             and vbintnt.noidt = intnt.noidt
         , last tache no-lock
          where tache.tpcon = vbintnt.tpcon
            and tache.nocon = vbintnt.nocon
            and tache.tptac = {&TYPETACHE-organismesSociaux}
            and tache.tpfin = "ODB":
        gcCentrePaiementImmeuble = tache.ntges. 
    end.

end procedure.

procedure initTva:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define output parameter table for ttTacheTva.
    define output parameter table for ttProrataParExercice.

    define variable vhproc         as handle  no-undo.
    define variable viNumerateur   as integer no-undo. 
    define variable viDenominateur as integer no-undo.
    define variable viNoMandant    as integer no-undo.

    define buffer ctrat   for ctrat.
    define buffer tache   for tache.
    define buffer cttac   for cttac.
    define buffer intnt   for intnt.
    define buffer vbroles for roles.
    define buffer ctanx   for ctanx.

    empty temp-table ttTacheTva.
    empty temp-table ttProrataParExercice.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find (last tache no-lock
                where tache.tpcon = pcTypeMandat
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-TVA})
    then do:
        mError:createError({&error}, 1000410).               //demande d'initialisation d'une tache inexistante
        return.
    end.
    run parametre/cabinet/gerance/defautMandatGerance.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run getParamTva in vhproc (output table ttParamTva by-reference).
    run destroy in vhproc.    
    run rechCentrePaiementImmeuble (ctrat.tpcon, ctrat.nocon, ctrat.ntcon).    
    
    create ttTacheTva.
    assign
        ttTacheTva.iNumeroTache            = 0
        ttTacheTva.cTypeContrat            = pcTypeMandat
        ttTacheTva.iNumeroContrat          = piNumeroMandat
        ttTacheTva.cTypeTache              = {&TYPETACHE-TVA}
        ttTacheTva.iChronoTache            = 0
        ttTacheTva.CRUD                    = 'C'
        ttTacheTva.daActivation            = ctrat.dtdeb
        ttTacheTva.lSaisieManuelleProrata  = (can-find (first aparm no-lock where aparm.tppar = "DEBOUR"))
        ttTacheTva.iMandatDeclaration      = 0
        ttTacheTva.cNoSie01                = "000"
        ttTacheTva.cNoSie02                = "00"
        ttTacheTva.cNoSie03                = "00"
        ttTacheTva.iDepotAuPlusTard        = 0
        ttTacheTva.cCentrePaiementImmeuble = gcCentrePaiementImmeuble
    .
    for first ttParamTva:
        assign 
            ttTacheTva.cTypeRegime         = ttParamTva.cCodeRegime
            ttTacheTva.cLibelleRegime      = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-tva}, ttTacheTva.cTypeRegime)
            ttTacheTva.cTypeDeclaration    = ttParamTva.cCodeDeclaration
            ttTacheTva.cLibelleDeclaration = outilTraduction:getLibelleProgZone2("R_TAD", {&TYPETACHE-tva}, ttTacheTva.cTypeDeclaration)
            ttTacheTva.cTypePeriode        = ttParamTva.cCodePeriode
            ttTacheTva.cLibellePeriode     = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-tva}, ttTacheTva.cTypePeriode)
            ttTacheTva.lReglement          = ttParamTva.lReglement
            ttTacheTva.cCodeTvaConsRev     = ttParamTva.cCodeConserve
            ttTacheTva.cLibelleTvaConsRev  = (if ttTacheTva.cCodeTvaConsRev = "1" then outilTraduction:getLibelle(701268) /*Conservé*/ else outilTraduction:getLibelle(701270) /*Reversé*/ )
            viNumerateur                   = ttParamTva.iProrataNumerateur
            viDenominateur                 = ttParamTva.iProrataDenominateur
            ttTacheTva.cCodeRecette        = ttParamTva.cCodeRecette
            ttTacheTva.cLibelleRecette     = (if ttTacheTva.cCodeRecette = "1" then outilTraduction:getLibelle(100169) /*Débit*/ else outilTraduction:getLibelle(701217) /*Encaissement*/ )         
            ttTacheTva.cCodeDepense        = ttParamTva.cCodeDepense  
            ttTacheTva.cLibelleDepense     = (if ttTacheTva.cCodeDepense = "1" then outilTraduction:getLibelle(100169) /*Débit*/ else outilTraduction:getLibelle(103781) /*Décaissement*/ )       
            ttTacheTva.iCodeHonoraire      = integer(ttParamTva.cCodeHonoraire)
        .  
        /*les libelles sont forces apres chargement combo dans le pgm initial */ 
        if ttTacheTva.cTypeRegime = "18001" then ttTacheTva.cLibelleRegime = outilTraduction:getLibelle(1000440).   //Simplifié
        if ttTacheTva.cTypeRegime = "18002" then ttTacheTva.cLibelleRegime = outilTraduction:getLibelle(1000441).   //Réel normal
    end.     
    
    for first intnt no-lock                                                          
        where intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEROLE-mandant}:
        viNoMandant = intnt.noidt.
    end.
    for first vbroles no-lock
        where vbroles.tprol = {&TYPEROLE-mandant}     
          and vbroles.norol = viNoMandant
    , first ctanx no-lock
      where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
        and ctanx.tprol = {&TYPEROLE-tiers}
        and ctanx.norol = vbroles.notie:
        assign
            ttTacheTva.cCodeSiret  = string(ctanx.nosir,"999999999")
            ttTacheTva.cCodeNic    = string(ctanx.cptbq,"99999")
            ttTacheTva.cCodeApe    = ctanx.cdape
            ttTacheTva.cTvaIntra   = ctanx.liexe
        .
    end.           

    create ttProrataParExercice.
    assign
        ttProrataParExercice.iExercice = year(today) - 1
        ttProrataParExercice.iNumerateur = viNumerateur
        ttProrataParExercice.iDenominateur = viDenominateur
        ttProrataParExercice.dPrctAssujettissement = 100
        ttProrataParExercice.dPrctTaxation = viNumerateur
    .
    create ttProrataParExercice.
    assign
        ttProrataParExercice.iExercice = year(today)
        ttProrataParExercice.iNumerateur = viNumerateur
        ttProrataParExercice.iDenominateur = viDenominateur
        ttProrataParExercice.dPrctAssujettissement = 100
        ttProrataParExercice.dPrctTaxation = viNumerateur
    .
          
end procedure.

procedure rechSiTvaDecl private:
    /*------------------------------------------------------------------------------
    Purpose: regarde si tva deja traite (declare)
             reprise cadb/gestion/atvadecl.p mais seulement appele par prmobstd.p donc report ici
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSoc       as integer no-undo.
    define input  parameter piNumeroContrat as int64   no-undo.
    define output parameter plTvaTraite     as logical no-undo.
 
    define buffer ietab   for ietab.
    define buffer iprd    for iprd.
    define buffer vbiprd  for iprd.
    define buffer vb2iprd for iprd.
    define buffer adbtva  for adbtva.
 
    for first ietab no-lock
        where ietab.soc-cd = piCodeSoc
          and ietab.etab-cd = piNumeroContrat:
        for first iprd no-lock
            where iprd.soc-cd   = piCodeSoc
              and iprd.etab-cd  = piNumeroContrat
              and iprd.dadebprd <= today
              and iprd.dafinprd >= today:
            for first vbiprd no-lock
                where vbiprd.soc-cd  = piCodeSoc
                  and vbiprd.etab-cd = piNumeroContrat
                  and vbiprd.prd-cd  = (if iprd.prd-cd = /* 1 */ ietab.prd-cd-1 
                                        or (iprd.prd-cd = /* 2 */ ietab.prd-cd-2 and not ietab.exercice)
                                        then 1
                                        else 2):
                for each vb2iprd no-lock
                   where vb2iprd.soc-cd   = piCodeSoc
                     and vb2iprd.etab-cd  = piNumeroContrat
                     and vb2iprd.dadebprd >= vbiprd.dafinprd:
                    if f_tva_valid(piNumeroContrat, vb2iprd.dadebprd, piCodeSoc)
                    then for first adbtva no-lock
                             where adbtva.soc-cd     = piCodeSoc
                               and adbtva.etab-cd    = piNumeroContrat
                               and adbtva.date_decla = vb2iprd.dafinprd: 
                        plTvaTraite = yes.                              
                        return.
                    end.
                end.
            end.    
        end.
    end. 
      
end procedure.
 