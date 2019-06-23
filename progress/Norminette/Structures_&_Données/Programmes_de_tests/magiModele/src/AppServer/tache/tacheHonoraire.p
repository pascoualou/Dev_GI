/*------------------------------------------------------------------------
File        : tacheHonoraire.p
Purpose     :
Author(s)   : DM 2017/11/09
Notes       : à partir de adb/src/tach/prmmtho1.p

------------------------------------------------------------------------*/
{preprocesseur/type2honoraire.i}
{preprocesseur/nature2honoraire.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/codePeriode.i}

using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametrageEditionCRG.
using parametre.syspr.syspr.
using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{tache/include/honoraire.i}
{tache/include/tache.i}
{tache/include/baremeHonoraire.i &nomTable=ttHonoraireCabinet}
{tache/include/baremeHonoraire.i}
{tache/include/honoraireCalculeUL.i}
{tache/include/paramBaseRubrique.i}
{adblib/include/honmd.i}
{adblib/include/cttac.i}
{compta/include/tva.i}
{application/include/combo.i}
{application/include/error.i}
{application/include/glbsepar.i}

function fReferenceSocieteCabinet returns integer (piReference as integer):
    /*------------------------------------------------------------------------------
    Purpose: donne la référence cabinet en fonction de la reference ABD
    Notes:
    ------------------------------------------------------------------------------*/
    define variable GiCodeSocCAB as integer no-undo.
    define buffer ifdparam for ifdparam.

    for first ifdparam no-lock where ifdparam.soc-dest = piReference :
        GiCodeSocCAB = ifdparam.soc-cd.
    end.
    return GiCodeSocCAB.
end function.


function fIsNull returns logical(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.
end function.

procedure getChampsSaisissable :
  /*------------------------------------------------------------------------------
    Purpose:  Champs saisissables saisissables selon contexte
    Notes  :  Appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input  parameter plCreationLigne   as logical   no-undo.
    define input  parameter pcTypeHonoraire   as character no-undo.
    define input  parameter pcNatureHonoraire as character no-undo.
    define output parameter table for ttChampsSaisissable.

    empty temp-table ttChampsSaisissable.
    create ttChampsSaisissable.
    assign
        ttChampsSaisissable.lSaisieCodeHonoraire        = lookup(pcTypeHonoraire // no barème non modifiable si barème facturation cabinet ni si Gestion UL (pb avec liste UL)
                                                        , substitute("&1,&2,&3,&4"
                                                                   , {&TYPEHONORAIRE-gestion-UL}
                                                                   , {&TYPEHONORAIRE-fact-cab-locataire}
                                                                   , {&TYPEHONORAIRE-fact-cab-proprietaire}
                                                                   , {&TYPEHONORAIRE-fact-cab-copro})) = 0
        ttChampsSaisissable.lSaisieLibelleCategorieBail = lookup(pcTypeHonoraire, substitute("&1,&2", {&TYPEHONORAIRE-gestion}, {&TYPEHONORAIRE-gestion-UL})) > 0
        ttChampsSaisissable.lSaisieLibellePeriodicite   = lookup(pcTypeHonoraire, substitute("&1,&2,&3,&4"
                                                                                            , {&TYPEHONORAIRE-gestion}
                                                                                            , {&TYPEHONORAIRE-frais-gestion}
                                                                                            , {&TYPEHONORAIRE-gestion-UL}
                                                                                            , {&TYPEHONORAIRE-frais-gest-UL})) > 0
        ttChampsSaisissable.lSaisieforfaitM2            = (pcTypeHonoraire = {&TYPEHONORAIRE-gestion} and pcNatureHonoraire = {&NATUREHONORAIRE-assietteM2})
        ttChampsSaisissable.lSaisieM2Occupe             = ttChampsSaisissable.lSaisieforfaitM2
        ttChampsSaisissable.lSaisieM2Shon               = ttChampsSaisissable.lSaisieforfaitM2
        ttChampsSaisissable.lSaisieM2Vacant             = ttChampsSaisissable.lSaisieforfaitM2
        ttChampsSaisissable.lSaisieDateDebutApplication = plCreationLigne
        ttChampsSaisissable.lSaisieLibelleCle           = (pcTypeHonoraire = {&TYPEHONORAIRE-gestion})
    .
end procedure.


procedure initComboParTypeHonoraire:
  /*------------------------------------------------------------------------------
    Purpose:  Combos selon le type d'honorraire et le contrat
    Notes  :  Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter pcTypeHonoraire as character no-undo.
    define output parameter table for ttCombo.

    define variable vhProcHonoCabinet as handle      no-undo.
    define variable voSyspr           as class syspr no-undo.
    define variable voSyspg           as class syspg no-undo.
    define buffer honor for honor.
    

    voSyspr = new syspr().
    voSyspg = new syspg().
    // Combo catégorie bail
    voSyspr:creationttCombo   ("CMBCATEGORIEBAIL", "00000", outilTraduction:getLibelle(102338), output table ttCombo by-reference). // Tous
    if pcTypeHonoraire = {&TYPEHONORAIRE-gestion} or pcTypeHonoraire = {&TYPEHONORAIRE-gestion-UL} 
    then voSyspr:creationttCombo("CMBCATEGORIEBAIL", "90000", outilTraduction:getLibelle(102629), output table ttCombo by-reference). // Manuel (= blanc)

    if pcTypeHonoraire = {&TYPEHONORAIRE-gestion-UL} then do:
        voSyspr:getComboParametre("NTAPP", "CMBCATEGORIEBAIL", output table ttCombo by-reference).
        for each ttcombo where ttcombo.cNomCombo = "CMBCATEGORIEBAIL" and lookup(ttcombo.cCode,"00003,00004") > 0 : // réservé au mandant, lots non attiibués
            delete ttcombo.
        end.
    end.
    else if pcTypeHonoraire <> {&TYPEHONORAIRE-frais-gest-UL} then do:
        for last ttCombo :
            voSyspg:setgiNumeroItem(ttCombo.iSeqId).
        end.            
        voSyspg:creationComboSysPgZonXX("O_CBA", "CMBCATEGORIEBAIL"    , "", "", output table ttCombo by-reference).        
        for each ttcombo where ttcombo.cNomCombo = "CMBCATEGORIEBAIL" and lookup(ttcombo.cCode,"80000") > 0 : // Vacant
            delete ttcombo.
        end.
    end.
    // periodicite
    voSyspg:creationComboSysPgZonXX("R_TPH", "CMBPERIODICITE", "", pcTypeHonoraire, output table ttCombo by-reference).    
    // Bareme cabinet
    run tache/baremeHonoraire.p persistent set vhProcHonoCabinet.
    run getTokenInstance in vhProcHonoCabinet (mToken:JSessionId).
    run getBaremeHonoraire in vhProcHonoCabinet (pcTypeHonoraire, 0, 0, {&TYPECONTRAT-mandat2Gerance}, true, false, output table ttHonoraireCabinet, output table ttTranche).
    for each ttHonoraireCabinet :
        voSyspg:creationttCombo("CMBBAREMEHONORAIRECABINET"
                                    , string(ttHonoraireCabinet.iCodeHonoraire, "99999")
                                    , string(ttHonoraireCabinet.iCodeHonoraire, "99999") // Libellé = Code
                                    , output table ttCombo by-reference).                                    
    end.
    run destroy in vhProcHonoCabinet.
    delete object voSyspg.
    delete object voSyspr.
end procedure.

procedure affecteNewBareme :
    /*------------------------------------------------------------------------------
    Purpose: Affectation d'un nouveau barème
    Notes  : Appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeHonoraire as character no-undo.
    define input parameter piCodeHonoraire as integer   no-undo.
    define input-output parameter table for ttBaremeHonoraire.
    define input-output parameter table for ttHonoraireUL.

    define variable vDaDebutBareme      as date      no-undo.
    define variable vcCodePeriodicite   as character no-undo.
    define variable vcCodeCategorieBail as character no-undo.
    define variable vcTypeTache         as character no-undo.
    define variable voParametrageDefautMandat  as class parametrageDefautMandat no-undo.

    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.
    define buffer honor for honor.
    define buffer sys_pg for sys_pg.

    run chargeLibelle.
    voParametrageDefautMandat = new parametrageDefautMandat().

bloc :
    do :
        if pcTypeHonoraire <> {&TYPEHONORAIRE-gestion}
        then for first ttBaremeHonoraire
            where ttBaremeHonoraire.cTypeHonoraire = pcTypeHonoraire
              and ttBaremeHonoraire.iCodeHonoraire = piCodeHonoraire :
            mError:createError({&error}, 1000373). // 1000373 "Ce barème existe déjà"
            leave bloc.
        end.
        if pcTypeHonoraire = {&TYPEHONORAIRE-gestion-UL} or pcTypeHonoraire = {&TYPEHONORAIRE-frais-gest-UL}
        then for first tache no-lock // Vérification de non activation des CRG libres sur ce mandat
                where tache.tptac = {&TYPETACHE-compteRenduGestion}
                  and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and tache.nocon = piNumeroContrat:
                if entry(1,tache.lbdiv,"#") = "00003" then do:
                    mError:createError({&error}, 1000369). // 1000369 0 "Le CRG pour ce mandat est 'Libre'. Les honoraires sur UL sont interdits"
                    leave bloc.
                end.
            end.
        find last honor no-lock
            where honor.tphon = pcTypeHonoraire
              and honor.cdhon = piCodeHonoraire
              and (honor.dtdeb = ? or honor.dtdeb <= today)
              and (honor.dtfin = ? or honor.dtfin >= today) no-error.
        if not available honor then do:
            // Fiche 0611/0077 : barème à déclenchement futur !?
            find first honor no-lock
                where honor.tphon = pcTypeHonoraire
                  and honor.cdhon = piCodeHonoraire no-error.
            if not available honor then do:
                mError:createError({&error}, 1000370, string(piCodeHonoraire)). // 1000370 "Le no de barème &1 n'existe pas"
                leave bloc.
            end.
            find last honor no-lock
                where honor.tphon = pcTypeHonoraire
                  and honor.cdhon = piCodeHonoraire
                  and (honor.dtfin = ? or honor.dtfin >= today) no-error.
            if not available honor then do:
                mError:createError({&error}, 1000371, string(piCodeHonoraire)). // 1000371 0 "Le no de barème &1 n'est plus actif"
                leave bloc.
            end.
            else if honor.dtdeb <> ? and honor.dtdeb > today then do:
                vDaDebutBareme = honor.dtdeb.
                mError:createError({&warning}, 1000372, substitute("&1,&2,&3", string(piCodeHonoraire), separ[1], vDaDebutBareme)). // 1000372 0 "ATTENTION : Le no de barème &1 n'est applicable qu'à partir du &2"
            end.
        end.
        // périodicité
        vcCodePeriodicite = "00000".
        find first sys_pg no-lock
            where sys_pg.tppar = "R_TPH"
              and sys_pg.zone1 = pcTypeHonoraire no-error.
        if available sys_pg then vcCodePeriodicite = sys_pg.zone2.
        if pcTypeHonoraire = {&TYPEHONORAIRE-gestion} or pcTypeHonoraire = {&TYPEHONORAIRE-frais-gestion} then do:
            find first vbttBaremeHonoraire where vbttBaremeHonoraire.cTypeHonoraire = pcTypeHonoraire no-error.
            if available vbttBaremeHonoraire
            then vcCodePeriodicite = vbttBaremeHonoraire.cCodePeriodicite.
            else if voParametrageDefautMandat:getHonoraireGestionCodePeriode() > "00000" then vcCodePeriodicite = voParametrageDefautMandat:getHonoraireGestionCodePeriode().
        end.
        // categorie de bail
        vcCodeCategorieBail = "".
        if pcTypeHonoraire = {&TYPEHONORAIRE-gestion} or pcTypeHonoraire = {&TYPEHONORAIRE-frais-gest-UL} then vcCodeCategorieBail = "00000".    /* "Tous" */
        if pcTypeHonoraire = {&TYPEHONORAIRE-gestion-UL} then vcCodeCategorieBail = "90000".  /* "Manuel" */
        // tache associée
        vcTypeTache = "".
        find first sys_pg no-lock
            where sys_pg.tppar = "R_TTH"
            and   sys_pg.zone2 = pcTypeHonoraire no-error.
        if available sys_pg then vcTypeTache = sys_pg.zone1.
        run creationttBaremeHonoraire (input pcTypeContrat,
                                       input piNumeroContrat ,
                                       input vcTypeTache ,
                                       input pcTypeHonoraire ,
                                       input piCodeHonoraire ,
                                       input vcCodeCategorieBail ,
                                       input vcCodePeriodicite ,
                                       input "",
                                       fReferenceSocieteCabinet(integer(mToken:cRefPrincipale)),
                                       input ?,
                                       input ?).
        if available ttBaremeHonoraire
        then assign
                 ttBaremeHonoraire.daDateDebutApplication = (if vDaDebutBareme = ? then today else vDaDebutBareme )
                 ttBaremeHonoraire.CRUD = "C"
             .
    end.
    delete object voParametrageDefautMandat.
end procedure.

procedure getComboFiltreHonoraire :
    /*------------------------------------------------------------------------------
    Purpose: Chargement de la combo des types d'honoraire selon un type de contrat
    Notes  : appelé par baremeHonoraire.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat as character        no-undo.
    define input-output parameter table for ttCombo.
    
    define variable voSyspg as class syspg no-undo.
    voSyspg = new syspg().
    for last ttCombo :
        voSyspg:setgiNumeroItem(ttCombo.iSeqId).
    end.
    run chargeComboFiltreHonoraire(pcTypeContrat, voSyspg).
end procedure.

procedure chargeComboFiltreHonoraire private :
    /*------------------------------------------------------------------------------
    Purpose: Chargement de la combo des types d'honoraire selon un type de contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat as character        no-undo.
    define input parameter voSyspg as class syspg no-undo.

    define buffer sys_pg for sys_pg.

    // Combo filtre
    voSyspg:creationttCombo("CMBFILTREHONORAIRE", "00000", outilTraduction:getLibelle(105477), output table ttCombo by-reference). // Tous
    voSyspg:creationComboSysPgZonXX("R_CLH", "CMBFILTREHONORAIRE", "L", pcTypeContrat, output table ttCombo by-reference).
    for each sys_pg no-lock
        where sys_pg.tppar = "O_TPH"
          and sys_pg.zone8 = "0"
      , each ttcombo where ttcombo.cNomCombo = "CMBFILTREHONORAIRE" and ttcombo.cCode = sys_pg.cdpar :
            delete ttcombo.
    end.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable voSyspg as class syspg no-undo.

    // Combo filtre honoraire
    voSyspg = new syspg().
    run chargeComboFiltreHonoraire(input pcTypeContrat, input voSyspg).
    // Combo cle
    for each clemi no-lock 
        where clemi.tpcon = pcTypeContrat 
          and clemi.nocon = piNumeroContrat :
        voSyspg:creationttCombo("CMBCLEREPARTITION", clemi.cdcle, clemi.lbcle, output table ttCombo by-reference).
    end.        
    delete object voSyspg.
end procedure.

procedure initComboHonoraire :
    /*------------------------------------------------------------------------------
    Purpose: Charge les combos
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttCombo.

    run chargecombo(input piNumeroContrat, input pcTypeContrat).
end procedure.


procedure chargeLibelle private:
    /*------------------------------------------------------------------------------
    Purpose: Charge les libellés
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcTVA as handle no-undo.
    // TVA
    run compta/outilsTVA.p persistent set vhProcTVA.
    run getTokenInstance in vhProcTVA(mToken:JSessionId).
    run getCodeTVA in vhProcTVA(output table ttTVA).
    run destroy in vhProcTVA.
end.

procedure chargeHonoraire private :
    /*------------------------------------------------------------------------------
    Purpose: charge la liste des honoraires et propose les honoraire par défaut si initialisation
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeHonoraire as character no-undo.
    define input parameter piCodeHonoraire as integer   no-undo.
    define input parameter pcTypeEntree    as character no-undo.

    define variable GiCodeSocCab as integer   no-undo.
    define variable voParametrageDefautMandat as class parametrageDefautMandat no-undo.

    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.

    voParametrageDefautMandat = new parametrageDefautMandat().

    GiCodeSocCAB = fReferenceSocieteCabinet(integer(mToken:cRefPrincipale)).
    run chargeLibelle.
    run chgTmpHon (GiCodeSocCab, pcTypeContrat, piNumeroContrat, voParametrageDefautMandat:getHonoraireGestionCodePeriode(), pcTypeHonoraire, piCodeHonoraire).
    find vbttBaremeHonoraire no-error.
    if not available vbttBaremeHonoraire then do: // PL : 0508/0202 : Si on a déjà un barême de saisi on ne fait rien
        if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and pcTypeEntree = "INITIALISATION" then do: // Ajout SY le 22/01/2008 : Honoraires par défaut
            if voParametrageDefautMandat:getIsHonoraireGestion() then do:
                /* Honoraires */
                run creationttBaremeHonoraire (
                                               input pcTypeContrat,
                                               input piNumeroContrat ,
                                               input {&TYPETACHE-Honoraires},
                                               input {&TYPEHONORAIRE-gestion},
                                               input integer(voParametrageDefautMandat:getHonoraireGestionCodeHonoraire()),
                                               input "00000" ,
                                               input voParametrageDefautMandat:getHonoraireGestionCodePeriode(),
                                               input "",
                                               input GiCodeSocCAB,
                                               ?,
                                               ?).
                /* Frais de gestion */
                if voParametrageDefautMandat:getHonoraireGestionCodeFrais() > "00000" then
                    run creationttBaremeHonoraire (
                                                   input pcTypeContrat,
                                                   input piNumeroContrat,
                                                   input {&TYPETACHE-Honoraires},
                                                   input {&TYPEHONORAIRE-frais-gestion},
                                                   input integer(voParametrageDefautMandat:getHonoraireGestionCodeFrais()),
                                                   input "",
                                                   input voParametrageDefautMandat:getHonoraireGestionCodePeriode(),
                                                   input "",
                                                   input GiCodeSocCAB,
                                                   ?,
                                                   ?).
            end.
        end.
    end.
    // GESTION UL : Maj flag sélection des UL
    for each honmd no-lock
        where honmd.tpcon = pcTypeContrat
          and honmd.nocon = piNumeroContrat
          and (honmd.tphon = {&TYPEHONORAIRE-gestion} or honmd.tphon = {&TYPEHONORAIRE-gestion-UL}):
        /* ligne UL à sélectionner */
        for first ttHonoraireUL
            where ttHonoraireUL.cTypeHonoraire = honmd.tphon
              and ttHonoraireUL.iCodeHonoraire = honmd.cdhon
              and ttHonoraireUL.iNumeroUL      = honmd.noapp :
            ttHonoraireUL.lSelection = true.
        end.
    end.
    delete object voParametrageDefautMandat.

end procedure.

procedure getHonoraire :
    /*------------------------------------------------------------------------------
    Purpose: Extrait la liste des honoraires
    Notes  : service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeHonoraire as character no-undo.
    define input parameter piCodeHonoraire as integer   no-undo.
    define output parameter table for ttBaremeHonoraire.
    define output parameter table for ttHonoraireUL.

    run chargeHonoraire(piNumeroContrat, pcTypeContrat, pcTypeHonoraire, piCodeHonoraire, "").
end procedure.


procedure InitHonoraire :
    /*------------------------------------------------------------------------------
    Purpose: Initialisation tache honoraire
    Notes  : service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttBaremeHonoraire.

    run chargeHonoraire(piNumeroContrat, pcTypeContrat, "", ?, "INITIALISATION").
end procedure.

procedure ChgTmpHon private :
    /*------------------------------------------------------------------------------
    Purpose: Chargement bareme honoraire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piGiCodeSocCab  as integer   no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcCodePeriode   as character no-undo.
    define input parameter pcTypeHonoraire as character no-undo.
    define input parameter piCodeHonoraire as integer   no-undo.

    define variable vcListeCodeHonoraire as character no-undo.
    define variable vcListeInfoHonoraire as character no-undo.
    define variable viCodeHonoraire      as integer   no-undo.
    define variable vcCodeCategorieBail  as character no-undo.
    define variable vlCreationHonoraire  as logical   no-undo.
    define variable vcCodeCle            as character no-undo.
    define variable vcCodePeriode        as character no-undo.
    define variable viI1                 as integer   no-undo.

    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.
    define buffer tache  for tache.
    define buffer sys_pg for sys_pg.
    define buffer honmd  for honmd.

    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then do:
        /* Honoraires de la tache Honoraires de gestion 04021 */
        for last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-Honoraires}:
            vcListeCodeHonoraire = tache.lbdiv.
            boucle : do viI1 = 1 to num-entries( vcListeCodeHonoraire , separ[1] ):
                assign
                    vcListeInfoHonoraire = entry(viI1 , vcListeCodeHonoraire, separ[1])
                    viCodeHonoraire      = integer( entry(1, vcListeInfoHonoraire , separ[2]))
                    vcCodeCategorieBail  = entry(2, vcListeInfoHonoraire, separ[2])
                    vcCodeCle            = (if num-entries(vcListeInfoHonoraire, separ[2]) > 2 then entry(3, vcListeInfoHonoraire, separ[2]) else "")
                .
                    vlCreationHonoraire = yes.
                    if viCodeHonoraire = 0 and vcCodeCategorieBail = "00000" // bareme gratuit sur tous les baux : ne le créer qu'une fois
                    then vlCreationHonoraire = not can-find(first ttBaremeHonoraire
                                                            where ttBaremeHonoraire.cTypeHonoraire     = tache.tphon
                                                              and ttBaremeHonoraire.iCodeHonoraire     = viCodeHonoraire
                                                              and ttBaremeHonoraire.cCodeCategorieBail = vcCodeCategorieBail).
                    if vlCreationHonoraire
                       and (pcTypeHonoraire = ?  or pcTypeHonoraire = tache.tphon) and  
                           (piCodeHonoraire = ?  or piCodeHonoraire = viCodeHonoraire)  
                    then do :
                        vcCodePeriode = (if tache.pdges > "00000" then tache.pdges else pcCodePeriode).
                        run creationttBaremeHonoraire (  input pcTypeContrat
                                                       , input piNumeroContrat
                                                       , input Tache.tptac
                                                       , input tache.tphon
                                                       , input viCodeHonoraire
                                                       , input vcCodeCategorieBail
                                                       , input vcCodePeriode
                                                       , input vcCodeCle
                                                       , input piGiCodeSocCab
                                                       , input datetime(tache.dtmsy, tache.hemsy)
                                                       , input rowid(tache)).
                    end.
                    
            end.
            if integer(tache.ntreg) > 0 // Frais de gestion
               and ((pcTypeHonoraire = ? or pcTypeHonoraire = tache.cdreg) and  
                    (piCodeHonoraire = ? or piCodeHonoraire = integer(tache.ntreg)))
            then run creationttBaremeHonoraire (  input pcTypeContrat
                                                , input piNumeroContrat
                                                , input Tache.tptac
                                                , input tache.cdreg
                                                , input integer(tache.ntreg)
                                                , input ""
                                                , input tache.pdges
                                                , input vcCodeCle
                                                , input piGiCodeSocCab
                                                , input datetime(tache.dtmsy, tache.hemsy)
                                                , input rowid(tache)).
            for each ttBaremeHonoraire    // Vu avec Christine : supprimer le barème de gestion "00000" cat bail "00000" si un autre barème de gestion existe
                where ttBaremeHonoraire.cTypeHonoraire     = {&TYPEHONORAIRE-gestion}
                  and ttBaremeHonoraire.iCodeHonoraire     = 0
                  and ttBaremeHonoraire.cCodeCategorieBail = "00000":
                for first vbttBaremeHonoraire
                    where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
                      and vbttBaremeHonoraire.iCodeHonoraire > 0:
                    delete ttBaremeHonoraire.  // ! ttBaremeHonoraire
                end.
            end.
        end.

        // Honoraires Divers
        for each sys_pg no-lock
            where sys_pg.tppar = "R_TTH"
              and sys_pg.zone2 <> {&TYPEHONORAIRE-gestion} /* Tous sauf honoraires de gestion */
              and sys_pg.zone2 <> {&TYPEHONORAIRE-frais-gestion}:
            for last tache no-lock // création du bareme
                where tache.tptac = sys_pg.zone1
                  and tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat:
                if tache.tphon > "" and 
                    ((pcTypeHonoraire = ? or pcTypeHonoraire = tache.tphon) and  
                     (piCodeHonoraire = ? or piCodeHonoraire = integer(tache.cdhon)))
                then run creationttBaremeHonoraire ( input pcTypeContrat
                                                   , input piNumeroContrat
                                                   , input tache.tptac
                                                   , input tache.tphon
                                                   , input tache.cdhon
                                                   , input ""
                                                   , input "00000"
                                                   , input ""
                                                   , input piGiCodeSocCab
                                                   , input datetime(tache.dtmsy, tache.hemsy)
                                                   , input rowid(tache)).
            end.
        end.



        // Honoraires mandat (facturation cabinet et Gestion UL)
        for each honmd no-lock
            where honmd.tpcon = pcTypeContrat
              and honmd.nocon = piNumeroContrat
              and honmd.tphon <> {&TYPEHONORAIRE-gestion}
            break by honmd.tpcon by honmd.nocon /*BY honmd.tptac*/ by honmd.tphon by honmd.cdhon by honmd.catbai by honmd.noapp:
            if first-of (honmd.cdhon) and // création du bareme
               ((pcTypeHonoraire = ?  or pcTypeHonoraire = honmd.tphon) and  
                (piCodeHonoraire = ?  or piCodeHonoraire = integer(honmd.cdhon)))
                then run creationttBaremeHonoraire ( input pcTypeContrat
                                                   , input piNumeroContrat
                                                   , input ""
                                                   , input honmd.tphon
                                                   , input honmd.cdhon
                                                   , input honmd.catbai
                                                   , input honmd.pdges
                                                   , input ""
                                                   , input piGiCodeSocCab
                                                   , input datetime(honmd.dtmsy, honmd.hemsy)
                                                   , input rowid(honmd))
                                                   .
        end.
    end.
    else do:  // Mandat de syndic
        // Honoraires Divers
        for each sys_pg no-lock
            where sys_pg.tppar = "R_TTH":
           for last tache no-lock
                where tache.tptac = sys_pg.zone1
                  and tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat:
               // création du bareme
               if tache.tphon > "" and 
                  ((pcTypeHonoraire = ?  or pcTypeHonoraire = tache.tphon) and  
                   (piCodeHonoraire = ?  or piCodeHonoraire = integer(tache.cdhon)))
               then run creationttBaremeHonoraire ( input pcTypeContrat
                                                  , input piNumeroContrat
                                                  , input Tache.tptac
                                                  , input tache.tphon
                                                  , input tache.cdhon
                                                  , input ""
                                                  , input "00000"
                                                  , input ""
                                                  , input piGiCodeSocCab
                                                  , input datetime(tache.dtmsy, tache.hemsy)
                                                  , input rowid(tache)).
           end.
        end.
        // Honoraires mandat (facturation cabinet)
        for each honmd no-lock
            where honmd.tpcon = pcTypeContrat
              and honmd.nocon = piNumeroContrat
            break by honmd.tpcon by honmd.nocon by honmd.tphon by honmd.cdhon by honmd.catbai by honmd.noapp:
            if first-of (honmd.cdhon) and // création du bareme
               ((pcTypeHonoraire = ?  or pcTypeHonoraire = honmd.tphon) and
                (piCodeHonoraire = ?  or piCodeHonoraire = integer(honmd.cdhon)))
            then run creationttBaremeHonoraire ( input pcTypeContrat
                                               , input piNumeroContrat
                                               , input ""
                                               , input honmd.tphon
                                               , input honmd.cdhon
                                               , input honmd.catbai
                                               , input honmd.pdges
                                               , input ""
                                               , input piGiCodeSocCab
                                               , input datetime(honmd.dtmsy, honmd.hemsy)
                                               , input rowid(honmd)).
        end.
    end.
end procedure.

procedure creationttBaremeHonoraire private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de génération d'un enregistrement d'honoraire mandat en table tempo
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat       as character    no-undo.
    define input parameter piNumeroContrat     as int64        no-undo.
    define input parameter pcTypeTache         as character    no-undo.
    define input parameter pcTypeHonoraire     as character    no-undo.
    define input parameter piCodeHonoraire     as integer      no-undo.
    define input parameter pcCodeCategorieBail as character    no-undo.
    define input parameter pcCodePeriode       as character    no-undo.
    define input parameter pcCodeCle           as character    no-undo.
    define input parameter piGiCodeSocCab      as integer      no-undo.
    define input parameter pdtTimeStamp        as datetime     no-undo.
    define input parameter prRowid             as rowid        no-undo.

    define variable vcLibelleCatBail as character no-undo.

    define buffer ifdfam  for ifdfam.
    define buffer ifdsfam for ifdsfam.
    define buffer ifdlart for ifdlart.
    define buffer ifdart  for ifdart.
    define buffer rubsel  for rubsel.
    define buffer honor   for honor.
    define buffer sys_pg  for sys_pg.

    for last honor no-lock
        where honor.tphon = pcTypeHonoraire
          and honor.cdhon = piCodeHonoraire
          and (honor.dtfin = ? or honor.dtfin >= today) :  // barème applicable dans le futur

        find first ttTVA where ttTVA.cCodeTVA = honor.cdtva no-lock no-error.
        if pcCodeCategorieBail <> ""
        then case pcCodeCategorieBail:
                when "00000" then vcLibelleCatBail = "Tous".
                when "90000" then vcLibelleCatBail = "Manuel".
                otherwise if pcTypeHonoraire = {&TYPEHONORAIRE-gestion-UL}
                          then vcLibelleCatBail = outilTraduction:getLibelleParam("NTAPP", pcCodeCategorieBail, "c").
                          else vcLibelleCatBail = outilTraduction:getLibelleProg ("O_CBA", pcCodeCategorieBail, "c").
        end case.
        else vcLibelleCatBail = "".
        create ttBaremeHonoraire.
        outils:copyValidLabeledField(buffer honor:handle, buffer ttbaremehonoraire:handle).
        assign
            ttBaremeHonoraire.cTypeTache            = pcTypeTache
            ttBaremeHonoraire.cTypeHonoraire        = pcTypeHonoraire
            ttBaremeHonoraire.iCodeHonoraire        = piCodeHonoraire
            ttBaremeHonoraire.cCodeCategorieBail    = pcCodeCategorieBail
            ttBaremeHonoraire.cLibelleCategorieBail = vcLibelleCatBail
            ttBaremeHonoraire.CRUD                  = "R"
            ttBaremeHonoraire.cCodeCle              = pcCodeCle
            ttBaremeHonoraire.cCodePeriodicite      = pcCodePeriode
            ttBaremeHonoraire.cLibellePeriodicite   = outilTraduction:getLibelleProg ("O_PDH", ttBaremeHonoraire.cCodePeriodicite, "l")
            ttBaremeHonoraire.dttimestamp           = pdtTimeStamp
            ttBaremeHonoraire.rRowid                = prRowid
            ttBaremeHonoraire.iNumeroHonoraire      = honor.nohon // no interne honoraire (pour maj)
        .
        if ttBaremeHonoraire.cCodeBaseCalcul >= "30000"
        then find first rubsel no-lock
            where rubsel.tpmdt = ""
              and rubsel.nomdt = 0
              and rubsel.tpct2 = ""
              and rubsel.noct2 = 0
              and rubsel.tptac = {&TYPETACHE-Honoraires}
              and rubsel.tprub = ""
              and rubsel.cdrub = ""
              and rubsel.cdlib = ""
              and rubsel.ixd01 = ttBaremeHonoraire.cCodeBaseCalcul
              no-error.

        assign
            ttBaremeHonoraire.cLibellePresentation  = (if integer(honor.cdtot) = 0 then "-" else trim(outilTraduction:getLibelleParam("TTHON", honor.cdTot)))
            ttBaremeHonoraire.cLibelleTva           = (if available ttTVA then ttTVA.cLibelleTVA else "-")
            ttBaremeHonoraire.cLibelleNature        = (if integer(ttBaremeHonoraire.cCodeBaseCalcul) = 0
                                                       then "-"
                                                       else if available rubsel
                                                                then entry(1, rubsel.lbdiv, separ[2])
                                                                else outilTraduction:getLibelleProg("O_BSH", ttBaremeHonoraire.cCodeBaseCalcul, "l"))
            ttBaremeHonoraire.cLibelleTypeHonoraire = outilTraduction:getLibelleProg ("O_TPH", honor.tphon)
            ttBaremeHonoraire.cLibelleNature        = outilTraduction:getLibelleProg ("O_NTH", honor.nthon, "l")
            ttBaremeHonoraire.dTauxMontant          = (if honor.nthon = "14002" or (honor.nthon >= "14009" and honor.nthon <= "14013")
                                                       then honor.mthon else honor.txhon)
            ttBaremeHonoraire.dforfaitM2            = honor.surfo[1]
            ttBaremeHonoraire.dM2Occupe             = honor.surfo[2]
            ttBaremeHonoraire.dM2Shon               = honor.surfo[3]
            ttBaremeHonoraire.dM2Vacant             = honor.surfo[4]
            ttBaremeHonoraire.cLibelleBaseCalcul    = trim(outilTraduction:getLibelleProg("O_BSH", ttBaremeHonoraire.cCodeBaseCalcul))
        .

        // Libellés des champs fam-cle, sfam-cle et art-cle
        for first ifdart no-lock
            where ifdart.soc-cd  = piGiCodeSocCab
              and ifdart.art-cle = honor.art-cle :
            ttBaremeHonoraire.cLibelleArticle = ifdart.desig1.
        end.
        for first ifdfam no-lock where ifdfam.soc-cd  = piGiCodeSocCab and ifdfam.fam-cle = honor.fam-cle:
            ttBaremeHonoraire.cLibelleFamille = ifdfam.lib.
        end.
        for first ifdsfam no-lock where ifdsfam.soc-cd  = piGiCodeSocCab and ifdsfam.sfam-cle = honor.sfam-cle:
            ttBaremeHonoraire.cLibelleSousFamille = ifdsfam.lib .
        end.
        find sys_pg no-lock
            where sys_pg.tppar = "O_TPH"
              and sys_pg.cdpar = honor.tphon no-error.
        ttBaremeHonoraire.lFactureCabinet = available sys_pg and sys_pg.zone7 begins "FACCAB".
        // Si honoraire GESTION UL : liste des UL
        if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion-UL}
        then do:
            // créer la liste des UL non vides
            for each unite no-lock
                where unite.nomdt = piNumeroContrat
                  and unite.noapp <> 998
                  and unite.noact = 0
              , first cpuni no-lock
                    where cpuni.nomdt = unite.nomdt
                      and cpuni.noapp = unite.noapp
                      and cpuni.nocmp = unite.nocmp:
                create ttHonoraireUL.
                assign
                    ttHonoraireUL.cTypeTache             = ""
                    ttHonoraireUL.cTypeHonoraire         = ttBaremeHonoraire.cTypeHonoraire
                    ttHonoraireUL.iCodeHonoraire         = ttBaremeHonoraire.iCodeHonoraire
                    ttHonoraireUL.cCodeCategorieBail     = ""
                    ttHonoraireUL.iNumeroUL              = unite.noapp
                    ttHonoraireUL.cLibelleNatureLocation = outilTraduction:getLibelleParam("NTAPP", unite.cdcmp)
                    ttHonoraireUL.lSelection             = false
                .
            end.
        end.
    end. // last honor
end procedure.

procedure setTacheHonoraire:
    /*------------------------------------------------------------------------------
    Purpose: Validation des données modifiées/ajoutées/supprimées
    Notes  : service externe appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter table for ttBaremeHonoraire.
    define input parameter table for ttHonoraireUL.
    define input parameter table for ttError.

    define variable viQuestionnaire as integer no-undo.

blocTrans:
    do transaction:
        find first ttBaremeHonoraire where lookup(ttBaremeHonoraire.CRUD, 'C,U,D') > 0 no-error.
        if not available ttBaremeHonoraire then do :
            mError:createError({&error}, 1000331). // 1000331 "Aucune modification à enregistrer"
            undo blocTrans, leave blocTrans.
        end.
        for each ttBaremeHonoraire where ttBaremeHonoraire.crud = "D" :
            run controleSuppression.
            if merror:erreur() then undo blocTrans, leave blocTrans.
        end.
        if mError:erreur() then undo blocTrans, leave blocTrans.
        /* maj de tous les bareme de même type GESTION + FRAIS DE GESTION ou GESTION UL + FRAIS DE GESTION UL */
        for first ttBaremeHonoraire
            where ttBaremeHonoraire.lModificationPeriodicite
              and (ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-frais-gestion})
              and lookup(ttBaremeHonoraire.CRUD, "C,U") > 0 :
            viQuestionnaire = outils:questionnaire(1000336
                                                 , substitute("&1&2&3"
                                                            , outilTraduction:getLibelleProg ("O_TPH", ttBaremeHonoraire.cTypeHonoraire)
                                                            , separ[1]
                                                            , outilTraduction:getLibelleProg ("O_TPH", if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion}
                                                                                                       then {&TYPEHONORAIRE-frais-gestion}
                                                                                                       else {&TYPEHONORAIRE-gestion}))
                                                 , table ttError by-reference).
            if viQuestionnaire <= 2
            then undo blocTrans, leave blocTrans.
            run majBaremeGestion. // Mise à jour des barèmes de gestion
        end.
        run controleGlobal(piNumeroContrat, pcTypeContrat).
        if merror:erreur() then undo blocTrans, leave blocTrans.
        run commit_all_modifications(piNumeroContrat, pcTypeContrat).
        if merror:erreur() then undo blocTrans, leave blocTrans.
    end. // trans
end procedure.

procedure controleGlobal private :
    /*------------------------------------------------------------------------------
    Purpose: Controle intégrité global
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable viNbBareme           as integer   no-undo.
    define variable viNbMaxAutorise      as integer   no-undo.
    define variable ViNbBaremeArticle    as integer   no-undo.
    define variable viNbLigneBareme      as integer   no-undo.
    define variable vcTypeHonoraire      as character no-undo.
    define variable vcPeriodicite        as character no-undo.
    define variable viAncienCode         as integer   no-undo.
    define variable vlFacturationCabinet as logical   no-undo.

    define buffer sys_pg for sys_pg.
    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.

    // Nombre max de barèmes gestion = 5 c.f. sys_pg O_TPH zone8
    for each ttBaremeHonoraire
        where ttBaremeHonoraire.daDateFinApplication = ?
          and ttBaremeHonoraire.crud <> "D"
        break by ttBaremeHonoraire.cTypeHonoraire
              by ttBaremeHonoraire.iCodeHonoraire
              by ttBaremeHonoraire.daDateDebutApplication :
        if first-of(ttBaremeHonoraire.cTypeHonoraire) then viNbBareme = 0.
        viNbBareme = viNbBareme + 1.
        if last-of(ttBaremeHonoraire.cTypeHonoraire)
        then do:
            viNbMaxAutorise = 0.
            for first sys_pg no-lock
                where sys_pg.tppar = "O_TPH"
                  and sys_pg.cdpar = ttBaremeHonoraire.cTypeHonoraire:
                viNbMaxAutorise = (if sys_pg.zone8 = "N" then 999999 else integer(sys_pg.zone8)).
            end.
            if viNbBareme > viNbMaxAutorise
            then do:
                mError:createError({&error}, 1000354
                                           , substitute("&1&2&3"
                                                      , outilTraduction:getLibelleProg("O_TPH", ttBaremeHonoraire.cTypeHonoraire)
                                                      , separ[1]
                                                      , string(viNbMaxAutorise))). // 1000354 0 "Le nombre de barèmes &1 a dépassé la limite autorisée de &2"
                return.

            end.
        end.
    end.

    // Gestion + manuel : on ne peut avoir qu'une seul fois cette combinaison (index honmd)
    for each ttBaremeHonoraire
        where (ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion-UL})
          and ttBaremeHonoraire.cCodeCategorieBail = "90000"
          and ttBaremeHonoraire.crud <> "D"
        break by ttBaremeHonoraire.cTypeHonoraire
              by ttBaremeHonoraire.iCodeHonoraire
              by ttBaremeHonoraire.cCodeCategorieBail:
        if first-of (ttBaremeHonoraire.iCodeHonoraire) then viNbLigneBareme = 0.
        viNbLigneBareme = viNbLigneBareme + 1.
        if last-of (ttBaremeHonoraire.iCodeHonoraire)
        then do:
            if viNbLigneBareme > 1 then do:
                mError:createError({&error}, 1000355
                                           , substitute("&2&1&3&1&4"
                                                      , separ[1]
                                                      , string(viNbLigneBareme)
                                                      , outilTraduction:getLibelleProg("O_TPH" , ttBaremeHonoraire.cTypeHonoraire)
                                                      , string(ttBaremeHonoraire.iCodeHonoraire))). // 1000355 "Vous avez pas sélectionné &1 fois le barème &2 N° &3 Manuel"
                return.

            end.
        end.
    end.

    // Gestion UL + "Manuel" : anomalie si aucune UL sélectionnée
    for each ttBaremeHonoraire
        where (ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion-UL})
          and ttBaremeHonoraire.cCodeCategorieBail = "90000"
          and ttBaremeHonoraire.crud <> "D" :
        find first ttHonoraireUL
            where ttHonoraireUL.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
              and ttHonoraireUL.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
              and ttHonoraireUL.lSelection = yes no-error.
        if not available ttHonoraireUL then do:
            mError:createError({&error}, 1000356
                                       , substitute("&2&1&3&1&4"
                                                  , separ[1]
                                                  , outilTraduction:getLibelleProg("O_TPH", ttBaremeHonoraire.cTypeHonoraire)
                                                  , ttBaremeHonoraire.iCodeHonoraire)). // 1000356 "Vous n'avez pas sélectionné d'UL pour le barème &1 N° &2"
            return.

        end.
    end.

    // Gestion et Gestion UL : Périodicité obligatoire
    // Modif SY le 14/02/2008 : le code "00000" = "-" est interdit aussi
    for each ttBaremeHonoraire
        where (ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion-UL})
          and ttBaremeHonoraire.crud <> "D" :
        if fIsNull(ttBaremeHonoraire.cCodePeriodicite)
        then do :
            mError:createError({&error}, 1000357
                                       , substitute("&2&1&3"
                                                  , separ[1]
                                                  , outilTraduction:getLibelleProg("O_TPH", ttBaremeHonoraire.cTypeHonoraire)
                                                  , ttBaremeHonoraire.iCodeHonoraire)). // 1000357 0 Vous n'avez pas sélectionné la périodicité du barème &1 N° &2
            return.

        end.
    end.

    // Gestion et Frais de Gestion  : Périodicité identique
    for each ttBaremeHonoraire
        where (ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-frais-gestion})
          and ttBaremeHonoraire.crud <> "D"
        break by ttBaremeHonoraire.cCodePeriodicite
              by ttBaremeHonoraire.cTypeHonoraire
              by ttBaremeHonoraire.iCodeHonoraire:
        if first-of (ttBaremeHonoraire.cCodePeriodicite) then
            assign
                vcTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
                vcPeriodicite   = ttBaremeHonoraire.cCodePeriodicite
            .
        else if ttBaremeHonoraire.cCodePeriodicite <> vcPeriodicite
        then do:
            if vcTypeHonoraire <> ttBaremeHonoraire.cTypeHonoraire
            then mError:createError({&error}
                                  , 1000358  // 1000358 0 La périodicité des barèmes GESTION et FRAIS GESTION doit être identique ( &1 # &2 )
                                  , substitute("&2&1&3"
                                             , separ[1]
                                             , outilTraduction:getLibelleProg("O_PDH", vcPeriodicite)
                                             , outilTraduction:getLibelleProg("O_PDH", ttBaremeHonoraire.cCodePeriodicite))).
            else mError:createError({&error}
                                  , 1000359  // 1000359 0 La périodicité des barèmes &1 doit être identique ( &2 # &3 )
                                  , substitute("&2&1&3&1&4"
                                             , separ[1]
                                             , outilTraduction:getLibelleProg("O_TPH", ttBaremeHonoraire.cTypeHonoraire)
                                             , outilTraduction:getLibelleProg("O_PDH", vcPeriodicite)
                                             , outilTraduction:getLibelleProg("O_PDH", ttBaremeHonoraire.cCodePeriodicite))).
            return.

        end.
    end.

    // Gestion UL et Frais de Gestion UL : Périodicité identique
    assign
        vcTypeHonoraire = ""
        vcPeriodicite   = ""
    .
    for each ttBaremeHonoraire
        where (ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion-UL} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-frais-gest-UL})
          and ttBaremeHonoraire.crud <> "D"
        break by ttBaremeHonoraire.cCodePeriodicite
              by ttBaremeHonoraire.cTypeHonoraire
              by ttBaremeHonoraire.iCodeHonoraire:
        if first(ttBaremeHonoraire.cCodePeriodicite) then
            assign
                vcTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
                vcPeriodicite   = ttBaremeHonoraire.cCodePeriodicite
            .
        else if ttBaremeHonoraire.cCodePeriodicite <> vcPeriodicite
        then do:
                if vcTypeHonoraire <> ttBaremeHonoraire.cTypeHonoraire
                then mError:createError({&error}
                                      , 1000358   // 1000358 La périodicité des barèmes GESTION UL et FRAIS GESTION UL doit être identique ( &1 # &2 )
                                      , substitute("&2&1&3"
                                                 , separ[1]
                                                 , outilTraduction:getLibelleProg("O_PDH", vcPeriodicite)
                                                 , outilTraduction:getLibelleProg("O_PDH", ttBaremeHonoraire.cCodePeriodicite))).
                else mError:createError({&error}
                                      , 1000359   // 1000359 0 La périodicité des barèmes &1 doit être identique ( &2 # &3 )
                                      , substitute("&2&1&3&1&4"
                                                 , separ[1]
                                                 , outilTraduction:getLibelleProg("O_TPH", ttBaremeHonoraire.cTypeHonoraire)
                                                 , outilTraduction:getLibelleProg("O_PDH", vcPeriodicite)
                                                 , outilTraduction:getLibelleProg("O_PDH", ttBaremeHonoraire.cCodePeriodicite))).
                return.

        end.
    end.
    // Honoraires <> facturation cabinet ou Gestion : Vérifier qu'il n'y a pas plusieurs fois le même barème
    for each ttBaremeHonoraire
        where ttBaremeHonoraire.cTypeHonoraire <> {&TYPEHONORAIRE-gestion}
          and ttBaremeHonoraire.crud <> "D"
        break by ttBaremeHonoraire.cTypeHonoraire
              by ttBaremeHonoraire.iCodeHonoraire:
        if first-of(ttBaremeHonoraire.cTypeHonoraire)
        then do :
            vlFacturationCabinet = false.
            for first sys_pg no-lock where sys_pg.tppar = "O_TPH" and sys_pg.cdpar = ttBaremeHonoraire.cTypeHonoraire :
                vlFacturationCabinet = (if sys_pg.zone7 begins "FACCAB" then yes else no).
            end.
        end.
        if not vlFacturationCabinet
        then for each vbttBaremeHonoraire no-lock
                where vbttBaremeHonoraire.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
                  and vbttBaremeHonoraire.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
                  and vbttBaremeHonoraire.crud <> "D" :
                if recid(vbttBaremeHonoraire) <> RECID(ttBaremeHonoraire)
                then do:
                    mError:createError({&error}
                                     , 1000362
                                     , substitute("&2&1&3"
                                                , separ[1]
                                                , outilTraduction:getLibelleProg("O_TPH" , ttBaremeHonoraire.cTypeHonoraire)
                                                , ttBaremeHonoraire.iCodeHonoraire)). // 1000362 0 "Vous ne pouvez pas saisir plusieurs fois le même barème : &1  N° &2"
                    return.

                end.
        end.
    end.
    // facturation cabinet : article unique par mandat
    for each ttBaremeHonoraire
        where ttBaremeHonoraire.daDateFinApplication = ?
          and ttBaremeHonoraire.crud <> "D"
        break by ttBaremeHonoraire.cTypeHonoraire
              by ttBaremeHonoraire.cCodeArticle
              by ttBaremeHonoraire.iCodeHonoraire
              by ttBaremeHonoraire.daDateDebutApplication:
        if first-of(ttBaremeHonoraire.cTypeHonoraire)
        then do :
            vlFacturationCabinet = false.
            for first sys_pg no-lock where sys_pg.tppar = "O_TPH" and sys_pg.cdpar = ttBaremeHonoraire.cTypeHonoraire :
                vlFacturationCabinet = (if sys_pg.zone7 begins "FACCAB" then yes else no).
            end.
        end.
        if vlFacturationCabinet
        then do :
            if first-of(ttBaremeHonoraire.cCodeArticle)
            then assign
                    viAncienCode = 0.
                    ViNbBaremeArticle = 0.
                 .
            if viAncienCode <> ttBaremeHonoraire.iCodeHonoraire then ViNbBaremeArticle = ViNbBaremeArticle + 1.
            viAncienCode = ttBaremeHonoraire.iCodeHonoraire.
            if last-of(ttBaremeHonoraire.cCodeArticle) and ViNbBaremeArticle > 1
            then do:
                    mError:createError({&error}
                                     , 1000361 // 1000361 0 "Vous avez sélectionné &1 barèmes &2 associés au code article &3 : Vous ne devez en conserver qu'un seul"
                                     , substitute("&2&1&3&1&4"
                                                , separ[1]
                                                , ViNbBaremeArticle
                                                , outilTraduction:getLibelleProg("O_TPH", ttBaremeHonoraire.cTypeHonoraire)
                                                , ttBaremeHonoraire.cCodeArticle)).
                    return.

            end.
        end.
    end.
end procedure.

procedure getControleTache:
    /*------------------------------------------------------------------------------
    Purpose: Contrôle 1 barème
    Notes  : service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeCOntrat   as character no-undo.

    define input-output parameter table for ttBaremeHonoraire.

    define variable voParametrageEditionCRG as class parametrageEditionCRG no-undo.

    voparametrageEditionCRG = new parametrageEditionCRG().
    for first ttBaremeHonoraire where lookup(ttBaremeHonoraire.CRUD, 'C,U') > 0 and ttBaremeHonoraire.lControle :
        run controleValiditeBareme(piNumeroContrat, pcTypeCOntrat, voparametrageEditionCRG:isTrimesDecalePartielFinAnnee()).
    end.
    for first ttBaremeHonoraire where ttBaremeHonoraire.CRUD = "D" and ttBaremeHonoraire.lControle :
        run controleSuppression.
    end.
    delete object voparametrageEditionCRG.
end procedure.

procedure controleSuppression private:
    /*------------------------------------------------------------------------------
    Purpose: Controle suppression barème
    Notes  :
    ------------------------------------------------------------------------------*/
    // on ne peut pas supprimer les baremes associés à des taches ISF,IRF...
    // sauf bareme gestion ou frais de gestion (tache en cours )
    // ajout SY le 16/02/2010 : suppression nlle tache 04361 dans cet écran
    if not fisnull(ttBaremeHonoraire.cTypeTache)
    and ttBaremeHonoraire.cTypeTache <> {&TYPETACHE-Honoraires}
    and ttBaremeHonoraire.cTypeTache <> {&TYPETACHE-fraisGestion}
    and ttBaremeHonoraire.cTypeTache <> {&TYPETACHE-honoraireLocation}
    then mError:createError({&error}, 1000367). // 1000367 "Vous ne pouvez pas supprimer le barème d'une tâche active"
end procedure.

procedure majBaremeGestion private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour des barèmes du meme type
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.

    // maj de tous les bareme de même type GESTION + FRAIS DE GESTION ou GESTION UL + FRAIS DE GESTION UL
    if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-frais-gestion}
    then for each vbttBaremeHonoraire // Pour avoir une confirmation lors de la validation */
             where vbttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion}  or vbttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-frais-gestion} :
             assign
                 vbttBaremeHonoraire.cLibellePeriodicite = outilTraduction:getLibelleProg ("O_PDH", ttBaremeHonoraire.cCodePeriodicite, "l")
                 vbttBaremeHonoraire.cCodePeriodicite    = ttBaremeHonoraire.cCodePeriodicite
                 vbttBaremeHonoraire.CRUD                = "U" when vbttBaremeHonoraire.CRUD = "R"
             .
    end.
    if ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion-UL} or ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-frais-gest-UL}
    then for each vbttBaremeHonoraire
             where vbttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-gestion-UL}  or vbttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-frais-gest-UL} :
             assign
                vbttBaremeHonoraire.cLibellePeriodicite = outilTraduction:getLibelleProg ("O_PDH", ttBaremeHonoraire.cCodePeriodicite, "l")
                vbttBaremeHonoraire.cCodePeriodicite    = ttBaremeHonoraire.cCodePeriodicite
                vbttBaremeHonoraire.CRUD                = "U" when vbttBaremeHonoraire.CRUD = "R"
            .
    end.
end procedure.

procedure controleValiditeBareme private:
    /*------------------------------------------------------------------------------
    Purpose: controle un enregistrement ttBaremeHonoraire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat      as int64     no-undo.
    define input parameter pcTypeCOntrat        as character no-undo.
    define input parameter plCRGPartielFinAnnee as logical   no-undo.

    define buffer tache for tache.
    define buffer clemi for clemi.

    run majBaremeGestion.
    if ttBaremeHonoraire.cCodePeriodicite <> {&PERIODICITEHONORAIRES-mensuel} and ttBaremeHonoraire.cCodePeriodicite <> "00000" and plCRGPartielFinAnnee
    then for last tache no-lock
             where tache.tpcon = pcTypeCOntrat
               and tache.nocon = piNumeroContrat
               and tache.tptac = {&TYPETACHE-compteRenduGestion}:
            if (tache.pdges = {&PERIODICITEGESTION-trimestrielFevAvril} or tache.pdges = {&PERIODICITEGESTION-trimestrielMarsMai})
                then mError:createError({&info}, 109883). // Attention : Le CRG partiel de fin d'année sera édité sans les honoraires */
    end.
    if not can-find(first clemi where clemi.tpcon = pcTypeCOntrat
                                  and clemi.nocon = piNumeroContrat
                                  and clemi.cdcle = ttBaremeHonoraire.cCodeCle)
    then mError:createError({&info}, 103474, ttBaremeHonoraire.cCodeCle). // La clé %1 n'existe pas dans la liste proposée
end procedure.

procedure commit_all_modifications private:
    /*------------------------------------------------------------------------------
    Purpose: enregistrement en base
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable vhProcHonmd          as handle    no-undo.
    define variable vcListeCodeHonoraire as character no-undo.
    define variable vcCodeFraisGestion   as character no-undo.
    define variable vcPeriodicite        as character no-undo.
    define variable vcCodeHonoraire1     as character no-undo.
    define variable vdtTimeStamp         as datetime  no-undo.

    define buffer honmd for honmd.
    define buffer tache for tache.

    assign
        vcListeCodeHonoraire = ""
        vcCodeFraisGestion   = "00000"
        vcPeriodicite        = "00000"
        vcCodeHonoraire1     = "00000"
    .
    run adblib/honmd_CRUD.p persistent set vhProcHonmd.
    run getTokenInstance in vhProcHonmd(mToken:JSessionId).

blocTrans:
    do transaction:
        /* honoraires mandat: annule et remplace (honmd) */
        empty temp-table ttHonmd.
        run getHonmdContrat in vhProcHonmd(pcTypeContrat, piNumeroContrat, table tthonmd by-reference).
        for each tthonmd: tthonmd.CRUD = "D". end.
        run setHonmd in vhProcHonmd(buffer ttHonmd).
        if mError:erreur() then undo blocTrans,leave blocTrans.

        // mise à jour des honoraires saisis
        for each ttBaremeHonoraire
            where ttBaremeHonoraire.CRUD <> "D"
            break by ttBaremeHonoraire.cTypeHonoraire
                  by ttBaremeHonoraire.iCodeHonoraire
                  by ttBaremeHonoraire.daDateDebutApplication :
            case ttBaremeHonoraire.cTypeHonoraire:
                when  {&TYPEHONORAIRE-gestion} then do:
                    assign
                        vcListeCodeHonoraire = substitute("&1&2&3&4&5&4&6"
                                                        , vcListeCodeHonoraire
                                                        , (if vcListeCodeHonoraire = "" then "" else separ[1])
                                                        , string(ttBaremeHonoraire.iCodeHonoraire, "99999")
                                                        , separ[2]
                                                        , ttBaremeHonoraire.cCodeCategorie
                                                        , ttBaremeHonoraire.cCodeCle)  // Ajout OF le 23/05/16
                        vcPeriodicite        = ttBaremeHonoraire.cCodePeriodicite
                        vcCodeHonoraire1     = (if  vcCodeHonoraire1 = "00000"
                                                and ttBaremeHonoraire.cCodeNature <> {&NATUREHONORAIRE-gratuit}
                                                and ttBaremeHonoraire.dTauxMontant <> 0
                                                then string(ttBaremeHonoraire.iCodeHonoraire, "99999") else vcCodeHonoraire1 ) // Ajout SY 07/01/2008 : mémoriser 1er barème non gratuit
                        vdtTimeStamp         = ttBaremeHonoraire.dtTimeStamp.
                    .
                    if ttBaremeHonoraire.cCodeCategorie = "90000"
                    then for each ttHonoraireUL
                            where ttHonoraireUL.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
                              and ttHonoraireUL.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
                              and ttHonoraireUL.lSelection:
                            run majHonmd (piNumeroContrat
                                        , pcTypeContrat
                                        , {&TYPETACHE-Honoraires}
                                        , ttBaremeHonoraire.cTypeHonoraire
                                        , ttBaremeHonoraire.iCodeHonoraire
                                        , ttBaremeHonoraire.cCodeCategorie
                                        , ttHonoraireUL.iNumeroUL
                                        , ttBaremeHonoraire.cCodePeriodicite).
                    end.
                end.
                when {&TYPEHONORAIRE-frais-gestion} then vcCodeFraisGestion = string(ttBaremeHonoraire.iCodeHonoraire, "99999").
                when {&TYPEHONORAIRE-TVA}         or
                when {&TYPEHONORAIRE-DAS2T}       or
                when {&TYPEHONORAIRE-ISF}         or
                when {&TYPEHONORAIRE-IRF}         or
                when {&TYPEHONORAIRE-taxe-bureau} or
                when {&TYPEHONORAIRE-CRL}
                    then run majTacheDiv (piNumeroContrat
                                        , pcTypeContrat
                                        , ttBaremeHonoraire.cTypeTache
                                        , ttBaremeHonoraire.cTypeHonoraire
                                        , ttBaremeHonoraire.iCodeHonoraire
                                        , ttBaremeHonoraire.dtTimeStamp).
                when {&TYPEHONORAIRE-location}
                    then run creMajtache (piNumeroContrat
                                        , pcTypeContrat
                                        , ttBaremeHonoraire.cTypeTache
                                        , ttBaremeHonoraire.cTypeHonoraire
                                        , ttBaremeHonoraire.iCodeHonoraire
                                        , ttBaremeHonoraire.dtTimeStamp).
                when {&TYPEHONORAIRE-gestion-UL}
                then do:
                    if ttBaremeHonoraire.cCodeCategorie = "90000"
                    then for each ttHonoraireUL
                            where ttHonoraireUL.cTypeHonoraire = ttBaremeHonoraire.cTypeHonoraire
                              and ttHonoraireUL.iCodeHonoraire = ttBaremeHonoraire.iCodeHonoraire
                              and ttHonoraireUL.lSelection:
                            run majHonmd (piNumeroContrat
                                        , pcTypeContrat
                                        , ttBaremeHonoraire.cTypeTache
                                        , ttBaremeHonoraire.cTypeHonoraire
                                        , ttBaremeHonoraire.iCodeHonoraire
                                        , ttBaremeHonoraire.cCodeCategorie
                                        , ttHonoraireUL.iNumeroUL
                                        , ttBaremeHonoraire.cCodePeriodicite).
                    end.
                    else run majHonmd (piNumeroContrat
                                    , pcTypeContrat
                                    , ttBaremeHonoraire.cTypeTache
                                    , ttBaremeHonoraire.cTypeHonoraire
                                    , ttBaremeHonoraire.iCodeHonoraire
                                    , ttBaremeHonoraire.cCodeCategorie
                                    , 0
                                    , ttBaremeHonoraire.cCodePeriodicite).
                end.
                when {&TYPEHONORAIRE-frais-gest-UL}
                    then run majHonmd (piNumeroContrat
                                     , pcTypeContrat
                                     , ttBaremeHonoraire.cTypeTache
                                     , ttBaremeHonoraire.cTypeHonoraire
                                     , ttBaremeHonoraire.iCodeHonoraire
                                     , ttBaremeHonoraire.cCodeCategorie
                                     , 0
                                     , ttBaremeHonoraire.cCodePeriodicite).
                when {&TYPEHONORAIRE-fact-cab-locataire} or when {&TYPEHONORAIRE-fact-cab-proprietaire} or when {&TYPEHONORAIRE-fact-cab-copro}
                then . // Laisser ce code pour ne pas passer dans otherwise
                otherwise mError:createError({&error}, 1000364, outilTraduction:getLibelleProg ("O_TPH", ttBaremeHonoraire.cTypeHonoraire)). // 1000364 type d'honoraire &1 Non géré en mise à jour
            end case.
            if mError:erreur() then undo blocTrans,leave blocTrans.
            if last-of (ttBaremeHonoraire.iCodeHonoraire)
            then case ttBaremeHonoraire.cTypeHonoraire:
                    when {&TYPEHONORAIRE-fact-cab-locataire} or when {&TYPEHONORAIRE-fact-cab-proprietaire} or when {&TYPEHONORAIRE-fact-cab-copro}
                    then run majHonmd (piNumeroContrat
                                     , pcTypeContrat
                                     , ttBaremeHonoraire.cTypeTache
                                     , ttBaremeHonoraire.cTypeHonoraire
                                     , ttBaremeHonoraire.iCodeHonoraire
                                     , ""
                                     , 0
                                     , "00000").
            end case.
            if mError:erreur() then undo blocTrans,leave blocTrans.
        end.
        // Mandat de gérance : Dans tous les cas il faut créer ou mettre à jour la tache honoraires de gestion et frais
        if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then run MajTacheHon (piNumeroContrat
                                                                             , pcTypeContrat
                                                                             , vcListeCodeHonoraire
                                                                             , vcCodeFraisGestion
                                                                             , vcPeriodicite
                                                                             , vcCodeHonoraire1
                                                                             , vdtTimeStamp).
        if mError:erreur() then undo blocTrans,leave blocTrans.
        // Ajout SY le 16/02/2010 : Gestion suppression tache Honoraires de location
        for last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-honoraireLocation} :
            find first ttBaremeHonoraire
                where ttBaremeHonoraire.cTypeHonoraire = {&TYPEHONORAIRE-location}
                  and ttBaremeHonoraire.crud <> "D" no-error.
            if not available ttBaremeHonoraire then run SupTache (input tache.tptac, piNumeroContrat, pcTypeContrat).
        end.
        if mError:erreur() then undo blocTrans,leave blocTrans.
    end.
    run destroy in vhProcHonmd.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure majHonmd private:
    /*------------------------------------------------------------------------------
    Purpose: enregistrement honmd
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat   as int64     no-undo.
    define input parameter pcTypeContrat     as character no-undo.
    define input parameter pcTypeTache       as character no-undo.
    define input parameter pcTypeHonoraire   as character no-undo.
    define input parameter piCodeHonoraire   as integer   no-undo.
    define input parameter pcCodeCategorie   as character no-undo.
    define input parameter piNumeroUL        as integer   no-undo.
    define input parameter pcCodePeriodicite as character no-undo.

    define variable vhProcHonmd as handle    no-undo.
    define variable vcTypeTache as character no-undo.

    run adblib/honmd_CRUD.p persistent set vhProcHonmd.
    run getTokenInstance in vhProcHonmd(mToken:JSessionId).

    vcTypeTache = pcTypeTache. // Ajout Sy le 28/11/2014 : erreur code tache 04021 pour des honos cabinet
    if vcTypeTache = {&TYPETACHE-Honoraires} and lookup(pcTypeHonoraire, substitute("&1,&2", {&TYPEHONORAIRE-gestion}, {&TYPEHONORAIRE-frais-gestion})) = 0
        then vcTypeTache = "". // 1114/0243

blocTrans :
    do transaction:
        empty temp-table ttHonmd.
        create ttHonmd.
        assign
            ttHonmd.tpcon  = pcTypeContrat
            ttHonmd.nocon  = piNumeroContrat
            ttHonmd.tptac  = vcTypeTache
            ttHonmd.tphon  = pcTypeHonoraire
            ttHonmd.cdhon  = piCodeHonoraire
            ttHonmd.catbai = pcCodeCategorie
            ttHonmd.noapp  = piNumeroUL
            ttHonmd.pdges  = pcCodePeriodicite
            ttHonmd.CRUD   = "C"
        .
        run setHonmd in vhProcHonmd(table ttHonmd by-reference). // Création enregistrement de honmd
        if mError:erreur() then undo blocTrans, leave blocTrans.
    end. /* transaction majHonmd */
    run destroy in vhProcHonmd.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure comboTypeHonoraire:
    /*------------------------------------------------------------------------------
    Purpose: Combo par type d'honoraire et contrat
    Notes  : Service Externe beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeHonoraire as character no-undo.
    define output parameter table for ttCombo.

    define variable viNbBareme      as integer  no-undo.
    define variable viNbMaxAutorise as integer  no-undo.
    define variable voSyspg as class syspg no-undo.

    define buffer sys_pg for sys_pg.
    define buffer tache  for tache.
    define buffer vbttBaremeHonoraire for ttBaremeHonoraire.

    voSyspg = new syspg().
    voSyspg:creationComboSysPgZonXX("R_CLH", "CMBTYPEHONORAIRE", "L", pcTypeContrat, output table ttCombo by-reference).
    // suppression des types associés à une tache si tache absente (sauf tache en cours)
    // modif SY le 16/02/2010 : sauf tache 04361 Honoraires de location créée par cet écran
    for each sys_pg no-lock
        where sys_pg.tppar = "R_TTH"
          and sys_pg.zone2 <> {&TYPEHONORAIRE-gestion}
          and sys_pg.zone2 <> {&TYPEHONORAIRE-frais-gestion}
          and sys_pg.zone1 <> {&TYPETACHE-honoraireLocation}:
        find last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = sys_pg.zone1 no-error.
        if not available tache
        then do:
            for each ttcombo where ttcombo.cNomCombo = "CMBTYPEHONORAIRE" and ttcombo.cCode = sys_pg.zone2:
                delete ttcombo.
            end.
            if pcTypeHonoraire = sys_pg.zone2
            then mError:createError({&error}, 1000368, outilTraduction:getLibelleProg ("O_TAE", sys_pg.zone1, "l")). // 1000368 Vous devez créer la tache &1
        end.
    end.
    // suppression des types Cabinet (travaux) => 0 barèmes pour le mandat
    for each sys_pg no-lock
        where sys_pg.tppar = "O_TPH"
        and   sys_pg.zone8 = "0":
        for each ttcombo where ttcombo.cNomCombo = "CMBTYPEHONORAIRE" and ttcombo.cCode = sys_pg.cdpar:
            delete ttcombo.
        end.
    end.
    // suppression des types dont le nombre max est déjà atteint
    for each vbttBaremeHonoraire
        where vbttBaremeHonoraire.crud <> "D"
        break by vbttBaremeHonoraire.cTypeHonoraire
              by vbttBaremeHonoraire.iCodeHonoraire:
        if first-of (vbttBaremeHonoraire.cTypeHonoraire) then viNbBareme = 0.
        viNbBareme = viNbBareme + 1.
        if last-of (vbttBaremeHonoraire.cTypeHonoraire)
        then do:
            viNbMaxAutorise = 0.
            for first sys_pg no-lock
                where sys_pg.tppar = "O_TPH"
                  and sys_pg.cdpar = vbttBaremeHonoraire.cTypeHonoraire:
                viNbMaxAutorise = (if sys_pg.zone8 = "N" then 999999 else integer(sys_pg.zone8)).
            end.
            if viNbBareme >= viNbMaxAutorise
            then for each ttcombo where ttcombo.cNomCombo = "CMBTYPEHONORAIRE" and ttcombo.cCode = vbttBaremeHonoraire.cTypeHonoraire :
                     delete ttcombo.
            end.
        end.
    end.
    // Suppression de tous les types autre que celui selectionné en filtre si <> tous
    if pcTypeHonoraire <> "00000"
    then for each sys_pg no-lock
            where sys_pg.tppar = "R_CLH"
              and sys_pg.zone2 <> pcTypeHonoraire:
            for each ttcombo where ttcombo.cNomCombo = "CMBTYPEHONORAIRE" and ttcombo.cCode = sys_pg.zone2 :
                delete ttcombo.
            end.
    end.
    delete object voSyspg.
end procedure.

procedure majTacheDiv private:
    /*------------------------------------------------------------------------------
    Purpose: enregistrement tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define input parameter pcTypeHonoraire as character no-undo.
    define input parameter piCodeHonoraire as integer   no-undo.
    define input parameter pdtTimeStamp    as datetime  no-undo.

    define variable vhTache as handle no-undo.

    define buffer tache for tache.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

blocTrans :
    do transaction:
        find last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = pcTypeTache no-error.
        if not available tache
        then do:
            mError:createError({&error}, 1000365, outilTraduction:getLibelleProg ("O_TAE", pcTypeTache, "l")). // 1000365 0 "La Tache &1 n'existe plus. Mise à jour impossible"
            undo blocTrans,leave blocTrans.
        end.
        else do:
            empty temp-table ttTache.
            create ttTache.
            if not outils:copyValidField(buffer tache:handle, buffer ttTache:handle) then undo blocTrans, leave blocTrans.
            assign
                ttTache.tpHon = pcTypeHonoraire
                tttache.cdHon = string(piCodeHonoraire,"99999")
                ttTache.CRUD        = "U"
                ttTache.dtTimestamp = pdtTimeStamp
            .
            run setTache in vhTache(table ttTache by-reference).
            if merror:erreur() then undo blocTrans, leave blocTrans.
        end.
    end. /* transaction MajTac */
    run destroy in vhTache.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure creMajtache private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour nouvelle tache Honoraires de location
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define input parameter pcTypeHonoraire as character no-undo.
    define input parameter piCodeHonoraire as integer   no-undo.
    define input parameter pdtTimeStamp    as datetime  no-undo.
    define input parameter prRowid         as rowid     no-undo.

    define variable vhProcCttac as handle no-undo.
    define variable vhProcTache as handle no-undo.

    define buffer cttac for cttac.
    define buffer tache for tache.

    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).

blocTrans:
    do transaction:
        find first cttac no-lock
            where cttac.tpcon = pcTypeContrat
              and cttac.nocon = piNumeroContrat
              and cttac.tptac = pcTypeTache no-error.
        if not available cttac
        then do:
            empty temp-table ttCttac.
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = pcTypeTache
                ttCttac.CRUD  = "C"
            .
            run setCttac in vhProcCttac(table ttCttac by-reference).
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
        find last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = pcTypeTache no-error.
        if not available tache then do:
            empty temp-table ttTache.
            create ttTache.
            assign
                ttTache.CRUD  = "C"
                ttTache.tpcon = pcTypeContrat
                ttTache.nocon = piNumeroContrat
                ttTache.tptac = pcTypeTache
                ttTache.tpHon = pcTypeHonoraire
                ttTache.cdHon = string(piCodeHonoraire, "99999")
                ttTache.dtdeb = today
                ttTache.notac = 1
            .
        end.
        else do: // Mise à jour de la tache
            empty temp-table ttTache.
            create ttTache.
            if not outils:copyValidField(buffer tache:handle, buffer ttTache:handle) then undo blocTrans, leave blocTrans.
            assign
                ttTache.tpHon = pcTypeHonoraire
                tttache.cdHon = string(piCodeHonoraire, "99999")
                ttTache.CRUD        = "U"
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            .
        end.
        run setTache in vhProcTache(table ttTache by-reference).
        if mError:erreur() then undo blocTrans, leave blocTrans.
    end.
    run destroy in vhProcTache.
    run destroy in vhProcCttac.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure MajtacheHon private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour de la tache honoraire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat    as int64     no-undo.
    define input parameter pcTypeContrat      as character no-undo.
    define input parameter pcListeHonoraire   as character no-undo.
    define input parameter pcCodeFraisGestion as character no-undo.
    define input parameter pcPeriodicite      as character no-undo.
    define input parameter pcCodeHonoraire1   as character no-undo.
    define input parameter pdtTimeStamp       as datetime  no-undo.

    define variable viNombreBareme   as integer   no-undo.
    define variable vcListeHonoraire as character no-undo.
    define variable viI1             as integer   no-undo.
    define variable vhProcCttac      as handle    no-undo.
    define variable vhProcTache      as handle    no-undo.

    define buffer tache for tache.
    define buffer cttac for cttac.

    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).

    /* PL : 27/09/2011 (0911/0139) Pour retirer les éventuels barêmes gratuits en tête de lbdiv */
    /* Ce cas se produit si on n'a pas de barême (uniquement 1 gratuit) et que l'on
       fait affecter pour créer un barême. Le barême gratuit n'est plus visible dans la liste
       mais il reste dans la table temporaire et on se retrouve avec le barême gratuit en debut
       de lbdiv */
    pcListeHonoraire = replace(pcListeHonoraire, "00000" + separ[2] + "00000" + separ[1], "").
    pcListeHonoraire = replace(pcListeHonoraire, separ[1] + "00000" + separ[2] + "00000", "").

    viNombreBareme = num-entries(pcListeHonoraire, separ[1]).
    vcListeHonoraire = pcListeHonoraire.
    do viI1 = viNombreBareme + 1 to 5:
        vcListeHonoraire = substitute("&1&2&3&4&5"
                                    , vcListeHonoraire
                                    , (if vcListeHonoraire = "" then "" else separ[1])
                                    , "00000"
                                    , separ[2]
                                    , "00000").
    end.

blocTrans:
    do transaction:
        find last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-Honoraires} no-error.
        if not available tache then do:
            empty temp-table ttTache.
            create ttTache.
            assign
                ttTache.CRUD  = "C"
                ttTache.tpcon = pcTypeContrat
                ttTache.nocon = piNumeroContrat
                ttTache.tptac = {&TYPETACHE-Honoraires}
                ttTache.dtdeb = today
            .
        end.
        else do:
            empty temp-table ttTache.
            create ttTache.
            if not outils:copyValidField(buffer tache:handle, buffer ttTache:handle) then undo blocTrans, leave blocTrans.
            assign
                ttTache.CRUD        = "U"
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            .
        end.
        assign
            ttTache.tptac = {&TYPETACHE-Honoraires}
            ttTache.tpcon = pcTypeContrat
            ttTache.nocon = piNumeroContrat
            ttTache.pdges = pcPeriodicite
            ttTache.cdreg = {&TYPEHONORAIRE-frais-gestion}
            ttTache.ntreg = pcCodeFraisGestion
            ttTache.tphon = {&TYPEHONORAIRE-gestion}
            ttTache.cdhon = pcCodeHonoraire1      // cdhon toujours alimenté avec le 1er barème non nul  /* ENTRY(1, vcListeHonoraire ,separ[2] ) */
            ttTache.lbdiv = vcListeHonoraire
        .
        run setTache in vhProcTache(table ttTache by-reference).
        if mError:erreur() then undo blocTrans, leave blocTrans.

        find first cttac no-lock where cttac.tpcon = pcTypeContrat and cttac.nocon = piNumeroContrat and cttac.tptac = {&TYPETACHE-Honoraires} no-error.
        if not available cttac then
        do:
            empty temp-table ttCttac.
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-Honoraires}
                ttCttac.CRUD  = "C"
            .
            run setCttac in vhProcCttac (table ttCttac by-reference).
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
    end. /* transaction CreTac */
    run destroy in vhProcTache.
    run destroy in vhProcCttac.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure SupTache private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour de la tache honoraire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define variable vhProcCttac as handle no-undo.
    define variable vhProcTache as handle no-undo.

    define buffer tache for tache.
    define buffer cttac for cttac.

    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).

blocTrans:
    do transaction:
        empty temp-table ttTache.
        for each tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = pcTypeTache:
            empty temp-table ttTache.
            create ttTache.
            if not outils:copyValidField(buffer tache:handle, buffer ttTache:handle) then undo blocTrans, leave blocTrans.

            ttTache.CRUD = "D".
        end.
        run setTache in vhProcTache(table ttTache by-reference).
        if merror:erreur() then undo blocTrans, leave blocTrans.

        empty temp-table ttCttac.
        for each cttac no-lock
            where cttac.tpcon = pcTypeContrat
              and cttac.nocon = piNumeroContrat
              and cttac.tptac = pcTypeTache:
            create ttCttac.
            assign
                ttCttac.tpcon       = pcTypeContrat
                ttCttac.nocon       = piNumeroContrat
                ttCttac.tptac       = cttac.tptac
                ttCttac.CRUD        = "D"
                ttCttac.rRowid      = rowid(cttac)
                ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            .
        end.
        run setCttac in vhProcCttac(table ttCttac by-reference).
        if mError:erreur() then undo blocTrans, leave blocTrans.
    end.
    run destroy in vhProcTache.
    run destroy in vhProcCttac.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure getHonoraireCalculeUL:
    /*------------------------------------------------------------------------------
    Purpose: Liste des honoraires calcules par UL
    Notes  : Service externe appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeHonoraire as character no-undo.
    define output parameter table for ttHonoraireCalculeUL.

    define buffer honul for honul.
    define buffer ctrat for ctrat.
    define buffer unite for unite.

    for each honul no-lock
        where honul.nomdt = piNumeroContrat
          and honul.tphon = pcTypeHonoraire
      , first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and ctrat.nocon = honul.nomdt:
        create ttHonoraireCalculeUL.
        outils:copyValidLabeledField(buffer honul:handle, buffer ttHonoraireCalculeUL:handle).

        find last unite no-lock
            where unite.nomdt = honul.nomdt
              and unite.noapp = honul.noapp
              and unite.noact = 0 no-error.
        if available unite then ttHonoraireCalculeUL.cLibelleNatureLocation = outilTraduction:getLibelleParam("NTAPP", unite.cdcmp).
        assign
            ttHonoraireCalculeUL.cLibelleNature = outilTraduction:getLibelleProg ("O_NTH", honul.nthon)
            ttHonoraireCalculeUL.cProrata       = (if honul.fgpro then string(honul.nbjou,      ">>>9") else "")
            ttHonoraireCalculeUL.cJourOccupe    = (if honul.fgpro then string(honul.nbjouocc,   ">>>9") else "")
            ttHonoraireCalculeUL.cJourVacant    = (if honul.fgpro then string(honul.nbjouvac,   ">>>9") else "")
            ttHonoraireCalculeUL.cJourNongere   = (if honul.fgpro then string(honul.nbjouindis, ">>>9") else "")
            ttHonoraireCalculeUL.cMois          = substitute("&1/&2", string(year(honul.dtdeb), "9999"), string(month(honul.dtdeb), "99"))
        .
    end.
end procedure.
