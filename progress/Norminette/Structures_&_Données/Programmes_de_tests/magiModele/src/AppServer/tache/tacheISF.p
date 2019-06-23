/*------------------------------------------------------------------------
File        : tacheISF.p
Purpose     : tache Impot Solidarité sur la Fortune
Author(s)   : DM 20180111
Notes       : a partir de adb/tach/prmobstd.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2honoraire.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/nature2contrat.i}

using parametre.syspg.syspg.
using parametre.syspr.syspr.
using parametre.syspg.parametrageTache.
using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametrageISF.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gerance/include/paramIsf.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{tache/include/tacheISF.i}
{tache/include/tacheEmpruntISF.i}
{tache/include/empruntISFAnnee.i}
{tache/include/tache.i}
{adblib/include/cttac.i}

function cptAna return decimal(piNoCpt as integer, piNumeroMandat as integer, pDaDebut as date, pDaFin as date):
    /*------------------------------------------------------------------------------
    Purpose: Total d'une rubrique analytique (fonction cptAna de adb\src\tach\synmtisf.p)
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdRetour as decimal      no-undo.

    define buffer cecrlnana for cecrlnana.

    for each cecrlnana no-lock
      where cecrlnana.soc-cd    = integer(mToken:cRefGerance)
        and cecrlnana.etab-cd   = piNumeroMandat
        and cecrlnana.ana1-cd   = substring(string(piNoCpt,"999999"),1,3)
        and cecrlnana.ana2-cd   = substring(string(piNoCpt,"999999"),4,3)
        and cecrlnana.dacompta >= pDaDebut
        and cecrlnana.dacompta <= pDaFin :
        vdRetour = vdRetour + ((if cecrlnana.sens then 1 else -1) * cecrlnana.mt).
    end.
    return vdRetour.
end.

function fSolde return decimal(pcCompteCollectif as character, piNoMandat as integer, pcNumeroCompte as character):
    /*------------------------------------------------------------------------------
    Purpose: Solde d'un compte (fonction Solde de adb\src\tach\synmtisf.p)
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcCodeCollectif as character  no-undo.
    define variable vdsolde         as decimal    no-undo.
    define variable voCollection    as collection no-undo.

    define buffer csscptcol for csscptcol.

    for first csscptcol no-lock
        where csscptcol.soc-cd     = integer(mtoken:cRefGerance)
          and csscptcol.etab-cd    = piNoMandat
          and csscptcol.sscoll-cpt = pcCompteCollectif :
        vcCodeCollectif = csscptcol.sscoll-cle.
    end.

    voCollection = new collection().
    voCollection:set('iNumeroSociete'     , integer(mToken:cRefGerance)).
    voCollection:set('iNumeroMandat'      , piNoMandat).
    voCollection:set('cCodeCollectif'     , vcCodeCollectif).
    voCollection:set('cNumeroCompte'      , pcNumeroCompte).
    voCollection:set('iNumeroDossier'     , 0).
    voCollection:set('lAvecExtraComptable', false).
    voCollection:set('daDateSolde'        , date(12, 31 , year(today) - 1)).
    voCollection:set('cNumeroDocument'    , '').

    run compta/calculeSolde.p(input-output voCollection).
    vdSolde = voCollection:getDecimal('dSoldeCompte').
    delete object voCollection.
    return vdSolde.
end.

procedure getISF:
    /*------------------------------------------------------------------------------
    Purpose: Extraction de la tache ISF
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheISF.
    define output parameter table for ttSoldeProprietaireISF.
    define output parameter table for ttTacheEmpruntISF.

    define variable voParametrageISF as class parametrageISF no-undo.
    define variable vhproc           as handle               no-undo.    

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttTacheISF.
    empty temp-table ttSoldeProprietaireISF.
    empty temp-table ttTacheEmpruntISF.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057). // Numéro de contrat introuvable
        return.
    end.
    voParametrageISF = new parametrageISF().
    for last tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-ImpotSolidariteFortune} :
        create ttTacheISF.
        assign
            ttTacheISF.iNumeroTache      = tache.noita
            ttTacheISF.cTypeContrat      = tache.tpcon
            ttTacheISF.iNumeroContrat    = tache.nocon
            ttTacheISF.cTypeTache        = tache.tptac
            ttTacheISF.iChronoTache      = tache.notac
            ttTacheISF.daActivation      = tache.dtdeb
            ttTacheISF.cTypeDeclaration  = tache.tpges
            ttTacheISF.cTypePeriode      = tache.pdges
            ttTacheISF.lCalculSituFi     = (if lookup(tache.cdreg,"00001,00002") = 0 then voParametrageISF:getCalculSituFi() else tache.cdreg = "00001")
            ttTacheISF.iCodeHonoraire    = integer(tache.cdhon)
            ttTacheISF.iAnneeISF         = year(today) - 1
            ttTacheISF.dtTimestamp       = datetime(tache.dtmsy, tache.hemsy)
            ttTacheISF.CRUD              = 'R'
            ttTacheISF.rRowid            = rowid(tache)
        .
        run getSoldeProprioEmprunt.
        run tache/tacheEmpruntISF.p persistent set vhproc.
        run getTokenInstance in vhproc(mToken:JSessionId).
        run getEmpruntISF in vhProc(ttTacheISF.iNumeroContrat, ttTacheISF.cTypeContrat, 0, 0, output table ttTacheEmpruntISF by-reference, output table ttEmpruntISFAnnee by-reference).        
        run destroy in vhproc.        
    end.
    delete object voParametrageISF.
end procedure.

procedure initComboISF:
    /*------------------------------------------------------------------------------
    Purpose: Contenu des combos
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo.
end procedure.


procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg as class syspg no-undo.
    define variable voSyspr as class syspr no-undo.

    empty temp-table ttCombo.
    voSyspg = new syspg().
    voSyspg:creationComboSysPgZonXX("R_TAD", "TYPEDECLARATION", "L", {&TYPETACHE-ImpotSolidariteFortune}, output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_TPR", "TYPEPERIODE"    , "L", {&TYPETACHE-ImpotSolidariteFortune}, output table ttCombo by-reference).
    voSyspr = new syspr().
    for last ttCombo :
        voSyspr:setgiNumeroItem(ttCombo.iSeqId).
    end.
    voSyspr:getComboParametre("CDOUI","SITUFI", output table ttCombo by-reference).
    delete object voSyspg.
    delete object voSyspr.
end procedure.

procedure initISF:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation de la tache ISF
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define output parameter table for ttTacheISF.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find(last tache no-lock
                where tache.tpcon = pcTypeMandat
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-ImpotSolidariteFortune})
    then do:
        mError:createError({&error}, 1000410). // 1000410 demande d'initialisation pour une tache deja existante
        return.
    end.
    run InfoParDefautISF (buffer ctrat).
end procedure.

procedure InfoParDefautISF private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttTacheISF avec les informations par defaut pour creation de la tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable vhproc           as handle               no-undo.
    define variable voParametrageISF as class parametrageISF no-undo.

    run parametre/cabinet/gerance/defautMandatGerance.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run getParamISF in vhproc(output table ttParamISF by-reference).
    run destroy in vhproc.

    voParametrageISF = new parametrageISF().
    empty temp-table ttTacheISF.
    create ttTacheISF.
    assign
        ttTacheISF.iNumeroTache     = 0
        ttTacheISF.cTypeContrat     = ctrat.tpcon
        ttTacheISF.iNumeroContrat   = ctrat.nocon
        ttTacheISF.cTypeTache       = {&TYPETACHE-ImpotSolidariteFortune}
        ttTacheISF.iChronoTache     = 0
        ttTacheISF.daActivation     = ctrat.dtdeb
        ttTacheISF.lCalculSituFi    = voParametrageISF:getCalculSituFi().
        ttTacheISF.CRUD             = 'C'
    .
    for first ttParamISF :
        assign
            ttTacheISF.cTypeDeclaration = ttParamISF.cCodeDeclaration
            ttTacheISF.cTypePeriode     = ttParamISF.cCodePeriode
            ttTacheISF.iCodeHonoraire   = integer(ttParamISF.cCodeHonoraire)
        .
    end.
    delete object voParametrageISF.
end procedure.

procedure getSoldeProprioEmprunt private :
    /*------------------------------------------------------------------------------
    Purpose: Solde des comptes (procedure IniPrgUse de adb\src\tach\synmtisf.p)
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDateDebut   as character no-undo.
    define variable vcDateFin     as character no-undo.
    define variable vcDateDebutQP as character no-undo.
    define variable vcDateFinQP   as character no-undo.
    define variable vdSolde4112   as decimal   no-undo.
    define variable vdSolde4161   as decimal   no-undo.
    define variable vdEmprunt     as decimal   no-undo.
    define variable viNoMandant   as integer   no-undo.
    define variable viI1          as integer   no-undo.

    define buffer ctrat for ctrat.
    define buffer ctctt for ctctt.
    define buffer intnt for intnt.
    define buffer tache for tache.

    /*--> Initialisation des vairiables d'extraction */
    assign
        vcDateDebut               = "01/01/" + string(ttTacheISF.ianneeISF)
        vcDateFin                 = "31/12/" + string(ttTacheISF.ianneeISF)
        vcDateDebutQP             = "01/01/" + string(ttTacheISF.ianneeISF + 1)
        vcDateFinQP               = "31/12/" + string(ttTacheISF.ianneeISF + 1)
        ttTacheISF.dDepotGarantie = 0
    .

    for first ctrat no-lock
        where ctrat.tpcon = ttTacheISF.cTypeContrat
          and Ctrat.nocon   = ttTacheISF.iNumeroContrat :
        for each ctctt  where ctctt.tpct1 = ctrat.tpcon
                        and ctctt.noct1 = ctrat.nocon
                        and ctctt.tpct2 = {&TYPECONTRAT-bail}
                        no-lock:
            for first intnt no-lock
                where intnt.tpidt = {&TYPEROLE-locataire}
                  and intnt.tpcon = ctctt.tpct2
                  and intnt.nocon = ctctt.noct2 :
                assign
                    vdSolde4112 = vdSolde4112 + fSolde("4112",ctrat.nocon,substring(string(intnt.noidt,"9999999999"),6,5))
                    vdSolde4161 = vdSolde4161 + fSolde("4161",ctrat.nocon,substring(string(intnt.noidt,"9999999999"),6,5))
                    ttTacheISF.dDepotGarantie = ttTacheISF.dDepotGarantie + ABS(fSolde("2752",ctrat.nocon,substring(string(intnt.noidt,"9999999999"),6,5))).
            end.
        end.
        assign
            ttTacheISF.dTaxeFonciere       = cptAna(100500,ctrat.nocon,date(vcDateDebut),date(vcDateFin))
            ttTacheISF.dTaxeOrdureMenagere = cptAna(100510,ctrat.nocon,date(vcDateDebut),date(vcDateFin))
            ttTacheISF.dTaxeBalayage       = cptAna(100508,ctrat.nocon,date(vcDateDebut),date(vcDateFin))
            ttTacheISF.dTaxeBureau         = cptAna(100524,ctrat.nocon,date(vcDateDebut),date(vcDateFin))
            ttTacheISF.dQuotePart          = cptAna(120612,ctrat.nocon,date(vcDateDebutQP),date(vcDateFinQP))
        .
        if   (ctrat.ntCon = {&NATURECONTRAT-mandatSansIndivision}
           or ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
           or ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue})
        then do :
            for first intnt no-lock                                                          //recuperation mandant
                where intnt.tpcon = ttTacheISF.cTypeContrat
                  and intnt.nocon = ttTacheISF.iNumeroContrat
                  and intnt.tpidt = {&TYPEROLE-mandant}:
                viNoMandant = intnt.noidt.
            end.
            create ttSoldeProprietaireISF.
            assign
                ttSoldeProprietaireISF.iNumeroTache     =   ttTacheISF.iNumeroTache
                ttSoldeProprietaireISF.cNomProprietaire =   outilFormatage:getNomTiers( {&TYPEROLE-mandant},viNoMandant)
                ttSoldeProprietaireISF.dSolde           =   fSolde("4110",ctrat.nocon,"00000")
                                                          + vdSolde4112
                                                          + vdSolde4161
                                                          + fSolde("4111",ctrat.nocon,string(ctrat.norol,"99999"))
            .
        end.
        else for each intnt where intnt.tpidt = {&TYPEROLE-coIndivisaire}
                              and intnt.tpcon = ctrat.tpcon
                              and intnt.nocon = ctrat.nocon
                              no-lock:
                create ttSoldeProprietaireISF.
                assign
                    ttSoldeProprietaireISF.iNumeroTache     =   ttTacheISF.iNumeroTache
                    ttSoldeProprietaireISF.cNomProprietaire =   outilFormatage:getNomTiers({&TYPEROLE-coIndivisaire},intnt.noidt)
                    ttSoldeProprietaireISF.dSolde           =   ((fSolde("4110",ctrat.nocon,"00000") + vdSolde4112 + vdSolde4161) * intnt.nbnum / nbden)
                                                                + fSolde("4111",ctrat.nocon,string(intnt.noidt,"99999"))
                .
        end.
    end.
end.

procedure setISF:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheISF.

    define buffer tache for tache.
    define buffer ctrat for ctrat.

    for first ttTacheISF
    where lookup(ttTacheISF.CRUD, "C,U,D") > 0:
        find first ctrat no-lock
             where ctrat.tpcon = ttTacheISF.cTypeContrat
               and ctrat.nocon = ttTacheISF.iNumeroContrat no-error.
        if not available ctrat
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        find last tache no-lock
        where tache.tpcon = ttTacheISF.cTypeContrat
          and tache.nocon = ttTacheISF.iNumeroContrat
          and tache.tptac = {&TYPETACHE-ImpotSolidariteFortune} no-error.
        if not available tache
        and lookup(ttTacheISF.CRUD, "U,D") > 0
        then do:
            mError:createError({&error}, 1000413). // modification d'une tache inexistante
            return.
        end.
        if available tache
        and ttTacheISF.CRUD = "C" 
        then do:
            mError:createError({&error}, 1000412). //création d'une tache existante
            return.
        end.
        run verZonSai (buffer ctrat, buffer ttTacheISF).
        if mError:erreur() = yes then return.
        run majTache (buffer ttTacheISF, buffer ctrat).
    end.
end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat      for ctrat.
    define parameter buffer ttTacheISF for ttTacheISF.

    define variable voSyspg as class syspg no-undo.
    define variable voTache as class parametrageTache no-undo.

    define buffer honor for honor.

    if ttTacheISF.CRUD = "D"
    then do:
        voTache = new parametrageTache().
        if voTache:tacheObligatoire(ttTacheISF.iNumeroContrat, ttTacheISF.cTypeContrat, {&TYPETACHE-ImpotSolidariteFortune}) = yes
        then do:
            mError:createError({&error}, 100372).
            delete object voTache.
            return.
        end.
        delete object voTache.
    end.
    else do:
        if ttTacheISF.daActivation = ?
        then do:
            mError:createError({&error}, 100299).
            return.
        end.
        if ttTacheISF.daActivation < ctrat.dtini
        then do:
            mError:createErrorGestion({&error}, 100678, "").
            return.
        end.
        voSyspg = new syspg("R_TAD"). // Type de déclaration
        if not voSyspg:isDbParameter({&TYPETACHE-ImpotSolidariteFortune}, ttTacheISF.cTypeDeclaration)
        then do :
            mError:createError({&error}, 1000408). // 1000408 "Le type de déclaration n'existe pas"
            delete object voSyspg.
            return.
        end.
        delete object voSyspg.
        voSyspg = new syspg("R_TPR"). // Périodicité
        if not voSyspg:isDbParameter({&TYPETACHE-ImpotSolidariteFortune}, ttTacheISF.cTypePeriode)
        then do :
            mError:createError({&error}, 108039). // 108039 Période inexistante
            delete object voSyspg.
            return.
        end.
        delete object voSyspg.
        find first honor no-lock where honor.tphon = "13003" and honor.cdhon = ttTacheISF.iCodeHonoraire no-error.
        if not available honor then do :
            mError:createError({&error}, 1000409). // 1000409 "Barème d'honoraire inexistant"
            return.
        end.
    end.
end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache (creation table ttTache a partir table specifique tache (ici ttTacheISF)
             et appel du programme commun de maj des taches (tache/tache.p)
             si maj tache correcte appel maj table relation contrat tache (cttac).
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheISF for ttTacheISF.
    define parameter buffer ctrat      for ctrat.

    define variable vhProc   as handle  no-undo.
    define variable vlRetour as logical no-undo.
    define buffer cttac for cttac.

    empty temp-table ttTache.
    create ttTache.
    assign
        ttTache.noita = ttTacheISF.iNumeroTache
        ttTache.tpcon = ttTacheISF.cTypeContrat
        ttTache.nocon = ttTacheISF.iNumeroContrat
        ttTache.tptac = ttTacheISF.cTypeTache
        ttTache.notac = ttTacheISF.iChronoTache
        tttache.dtdeb = ttTacheISF.daActivation
        tttache.dtfin = ctrat.dtfin
        tttache.tpges = ttTacheISF.cTypeDeclaration
        tttache.pdges = ttTacheISF.cTypePeriode
        tttache.cdreg = string(ttTacheISF.lCalculSituFi,"00001/00002")
        tttache.tphon = {&TYPEHONORAIRE-ISF}
        tttache.cdhon = string(ttTacheISF.iCodeHonoraire,"99999")
        ttTache.CRUD        = ttTacheISF.CRUD
        ttTache.dtTimestamp = ttTacheISF.dtTimestamp
        ttTache.rRowid      = ttTacheISF.rRowid
    .
    run tache/tache.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run setTache in vhproc(table ttTache by-reference).
    run destroy in vhproc.
    if mError:erreur() then return.

    find first cttac no-lock
         where cttac.tpcon = ttTacheISF.cTypeContrat
           and cttac.nocon = ttTacheISF.iNumeroContrat
           and cttac.tptac = ttTacheISF.cTypeTache no-error.
    if available cttac and ttTacheISF.CRUD = "D" then do:
        run adblib/cttac_CRUD.p persistent set vhproc.
        run getTokenInstance in vhproc(mToken:JSessionId).
        empty temp-table ttCttac.
        create ttCttac.
        assign
            ttCttac.tpcon = cttac.tpcon
            ttCttac.nocon = cttac.nocon
            ttCttac.tptac = cttac.tptac
            ttCttac.CRUD  = "D"
            ttCttac.rRowid      = rowid(cttac)
            ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
        .
        run setCttac in vhproc(table ttCttac by-reference).
        run destroy in vhproc.
    end.
    else if not available cttac and lookup(ttTacheISF.CRUD, "C,U") > 0
    then do:
        run adblib/cttac_CRUD.p persistent set vhproc.
        run getTokenInstance in vhproc(mToken:JSessionId).
        empty temp-table ttCttac.
        create ttCttac.
        assign
            ttCttac.tpcon = ttTacheISF.cTypeContrat
            ttCttac.nocon = ttTacheISF.iNumeroContrat
            ttCttac.tptac = ttTacheISF.cTypeTache
            ttCttac.CRUD  = "C"
        .
        run setCttac in vhproc(table ttCttac by-reference).
        run destroy in vhproc.
    end.
end procedure.

procedure creationAutoTache:
    /*------------------------------------------------------------------------------
    Purpose: creation automatique de la tache isf
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.
 
    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.    
    run InfoParDefautISF(buffer ctrat).
    if mError:erreur() then return.
    for first ttTacheISF where ttTacheISF.CRUD = "C":
        if mError:erreur() = yes then return.
        run majTache (buffer ttTacheISF, buffer ctrat).
    end.

end procedure.
