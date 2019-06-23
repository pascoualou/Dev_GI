/*------------------------------------------------------------------------
File        : tacheRisqueLocatif.p
Purpose     : tache Risque locatif
Author(s)   : PL  -  15/05/2018
Notes       : a partir de adb/tach/prmobgrl.p
derniere revue: 2018/05/24 - phm: KO
        traiter les todo et en particulier la procédure infoAutorisationMaj
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/categorie2bail.i}

using parametre.pclie.parametrageDefautBail.
using parametre.syspg.syspg.
using parametre.syspg.parametrageTache.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
/*&scoped-define turlututu titi*/
{application/include/combo.i}
{application/include/glbsepar.i}
{tache/include/tacheRisqueLocatif.i}
{adblib/include/cttac.i}
{bail/include/outilBail.i}

function donneDateApplicationMinimum returns date(piNumeroContrat as int64, piMsQttNxtCLo-Deb as integer):
    /*------------------------------------------------------------------------
    Purpose : recherche la date d'application minimum en fonction du prochain
    Notes   : traitement de garantie loyer
    ------------------------------------------------------------------------*/
    define variable vdaApplicationMin as date no-undo.

    define buffer aquit for aquit.
    define buffer equit for equit.

    {&_proparse_ prolint-nowarn(use-index)}
    for each aquit no-lock
        where aquit.noloc = piNumeroContrat
          and aquit.msqtt >= piMsQttNxtCLo-Deb
          and aquit.fgfac = no
        use-index ix_aquit10:    // sinon ix_aquit08
        vdaApplicationMin = aquit.dtdeb.
    end.
    if vdaApplicationMin = ?
    then for first equit no-lock
        where equit.noloc = piNumeroContrat
          and equit.msqtt >= piMsQttNxtCLo-Deb:
        vdaApplicationMin = equit.dtdeb.
    end.
    if false then os-command silent value("toto.exe").
    return vdaApplicationMin.
end function.

procedure getTacheRisqueLocatif:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des infos de la tache Risque locatif d'un bail donné
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroBail  as int64     no-undo.
    define input  parameter pcTypeContrat as character no-undo.
    define output parameter table for ttTacheRisqueLocatif.

    define variable vhProc as handle  no-undo.
    define buffer tache for tache.
    define buffer ctrat for ctrat.

    empty temp-table ttTacheRisqueLocatif.
    find first ctrat no-lock                       // Positionnement sur le bon contrat bail
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroBail no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    find last tache no-lock                        // Positionnement sur la bonne tache
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroBail
          and tache.tptac = {&TYPETACHE-garantieRisqueLocatif} no-error.
    if not available tache then do:
        mError:createError({&error}, 1000471).     // tache inexistante
        return.
    end.
    run tache/tache.p persistent set vhproc.
    run readTache in vhproc(pcTypeContrat, piNumeroBail, {&TYPETACHE-garantieRisqueLocatif}, tache.notac, table ttTacheRisqueLocatif by-reference).
    if mError:erreur() then do:
        mError:createError({&error}, 1000471).     // tache inexistante
        return.
    end.
    // Ajout de l'information sur la catégorie de bail
    ttTacheRisqueLocatif.cCategoriebail = donneCategorieBail(pcTypeContrat,piNumeroBail).
    run infoAutorisationMaj.
end procedure.

procedure setTacheRisqueLocatif:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheRisqueLocatif.
    define buffer vbttTacheRisqueLocatif for ttTacheRisqueLocatif.

    for first ttTacheRisqueLocatif
        where lookup(ttTacheRisqueLocatif.CRUD, "C,U,D") > 0:
        if can-find(first vbttTacheRisqueLocatif
                    where lookup(vbttTacheRisqueLocatif.CRUD, "C,U,D") > 0
                      and vbttTacheRisqueLocatif.iNumeroTache <> ttTacheRisqueLocatif.iNumeroTache) then do:
            mError:createError({&error}, 1000589). //Vous ne pouvez traiter en maj qu'un enregistrement à la fois
            return.
        end.
        run controlesAvantValidation.
        if not mError:erreur() then run majTache(ttTacheRisqueLocatif.iNumeroContrat, ttTacheRisqueLocatif.cTypeContrat).
    end.
end procedure.

procedure initTacheRisqueLocatif:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation de la tache lors de la création
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroBail  as int64     no-undo.
    define input  parameter pcTypeContrat as character no-undo.
    define output parameter table for ttTacheRisqueLocatif.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroBail no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroBail
                  and tache.tptac =  {&TYPETACHE-garantieRisqueLocatif}) then do:
        mError:createError({&error}, 1000410).          // demande d'initialisation d'une tache existante
        return.
    end.
    run InfoParDefautTacheRisqueLocatif(buffer ctrat).
end procedure.

procedure InfoParDefautTacheRisqueLocatif private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttTacheRisqueLocatif avec les informations par defaut
             pour creation de la tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable viGarantieParDefaut   as integer no-undo.
    define variable vhProcGarantie        as handle  no-undo.
    define variable vdaDebutApplication   as date    no-undo.
    define variable viMoisMax             as integer no-undo.
    define variable vdaApplicationMinimum as date    no-undo.

    empty temp-table ttTacheRisqueLocatif.
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhProcGarantie.
    run getTokenInstance in vhProcGarantie(mToken:JSessionId).
    run ParametreGarantieMandat in vhProcGarantie(ctrat.tpcon,ctrat.nocon,{&TYPETACHE-garantieRisqueLocatif},output viGarantieParDefaut).
    run calculeDateApplication(ctrat.dtdeb, output vdaDebutApplication, output viMoisMax, output vdaApplicationMinimum).
    run destroy in vhProcGarantie.

    message "j'ai mal au dos" .
    create ttTacheRisqueLocatif.
    assign
        ttTacheRisqueLocatif.iNumeroTache   = 0
        ttTacheRisqueLocatif.cTypeContrat   = ctrat.tpcon
        ttTacheRisqueLocatif.iNumeroContrat = ctrat.nocon
        ttTacheRisqueLocatif.cTypeTache     = {&TYPETACHE-garantieRisqueLocatif}
        ttTacheRisqueLocatif.iChronoTache   = 0
        ttTacheRisqueLocatif.daActivation   = today
        ttTacheRisqueLocatif.iNumeroGarantie = viGarantieParDefaut
        ttTacheRisqueLocatif.daApplication   = vdaApplicationMinimum
        ttTacheRisqueLocatif.CRUD           = 'C'
    .
    run infoAutorisationMaj.

end procedure.

procedure CombosTacheRisqueLocatif:
    /*------------------------------------------------------------------------------
    Purpose: initialise les combos Garantie loyer et Bareme
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroBail     as int64     no-undo.
    define input  parameter pcTypeContrat    as character no-undo.
    define input  parameter piNumeroGarantie as integer   no-undo.
    define output parameter table for ttcombo.

    define variable vhoutilRisqueLocatif as handle    no-undo.
    define variable vcTypeBareme         as character no-undo.
    define variable viNumeroItem         as integer   no-undo.

    define buffer garan for garan.

    empty temp-table ttCombo.
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhoutilRisqueLocatif.
    run getTokenInstance in vhoutilRisqueLocatif(mToken:JSessionId).
    // Combo Vacance Locative = Garantie
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-garantieRisqueLocatif}
          and garan.nobar = 0:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBRISQUELOCATIF"
            ttCombo.cCode     = string(garan.noctt, "99")
        .
    /*run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhProcGarantie.*/
        run nomAdresseAssureur in vhoutilRisqueLocatif(
            mtoken:cRefGerance,
            garan.tpctt,
            garan.noctt,
            garan.lbdiv,
            garan.cdass,
            output ttCombo.cLibelle,
            output ttCombo.cLibelle2
        ).
    end.
    // Gestion Autres combo
    for last ttCombo:
        viNumeroItem = ttCombo.iSeqId.
    end.
    // Récupération de la categorie du bail
    vcTypeBareme = (if donneCategorieBail(pcTypeContrat,piNumeroBail) = "COM" then "00001" else "00002").
    if piNumeroGarantie = ? then piNumeroGarantie = 1.
    // Combo Barème par type 'HAB/COM'
    for each garan no-lock
        where garan.Tpctt = {&TYPECONTRAT-garantieRisqueLocatif}
          and garan.noctt = piNumeroGarantie
          and garan.tpbar = vcTypeBareme
          and (garan.txcot <> 0 or garan.txhon <> 0)    // PBP 06/03/2002: recuperation du bareme si non nul
        by garan.noctt:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBBAREMERISQUELOCATIF"
            ttCombo.cCode     = string(garan.nobar)
            ttCombo.cLibelle  = 'Barème ' + ttCombo.cCode
            ttCombo.cParent   = string(garan.noctt, "99")
        .
    end.
    run destroy in vhoutilRisqueLocatif.
end procedure.

procedure DateApplicationRisqueLocatif:
    /*------------------------------------------------------------------------------
    Purpose: Service de récupération de la date d'application en cas de changement
             de garantie
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter  piNumeroContrat  as int64     no-undo.
    define input parameter  pcTypeContrat    as character no-undo.
    define output parameter table for ttEchangesGRL.

    define variable vdaDebutBail          as date    no-undo.
    define variable vdaDebutApplication   as date    no-undo.
    define variable viMoisMax             as integer no-undo.
    define variable vdaApplicationMinimum as date    no-undo.
    define buffer ctrat for ctrat.

    for first ctrat no-lock                    // positionnement sur le bon bail
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        vdaDebutBail = ctrat.dtdeb.
    end.
    empty temp-table ttEchangesGRL.
    run getTacheRisqueLocatif(piNumeroContrat, pcTypeContrat, output table ttTacheRisqueLocatif by-reference).
    if vdaDebutBail <> ?
    then run calculeDateApplication(vdaDebutBail, output vdaDebutApplication, output viMoisMax, output vdaApplicationMinimum).
    create ttEchangesGRL.
    assign
        ttEchangesGRL.cCode   = "DATE_APPLICATION"
        ttEchangesGRL.cValeur = if vdaApplicationMinimum <> ? then string(vdaApplicationMinimum, "99/99/9999") else ""
    .
    run infoAutorisationMaj.
end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache (creation table ttTache a partir table specifique tache (ici ttTacheRisqueLocatif)
             et appel du programme commun de maj des taches (tache/tache.p)
             si maj tache correcte appel maj table relation contrat tache (cttac).
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable vhTache as handle no-undo.
    define variable vhCttac as handle no-undo.
    define buffer cttac for cttac.

    empty temp-table ttCttac.
    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTacheRisqueLocatif by-reference).
    run destroy in vhTache.
    if mError:erreur() then return.

    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-garantieRisqueLocatif}) then do:
        if not can-find(first cttac no-lock
                        where cttac.tpcon = pcTypeContrat
                          and cttac.nocon = piNumeroContrat
                          and cttac.tptac = {&TYPETACHE-garantieRisqueLocatif}) 
                          then do:
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-garantieRisqueLocatif}
                ttCttac.CRUD  = "C"
            .
        end.
    end.
    else for first cttac no-lock
             where cttac.tpcon = pcTypeContrat
               and cttac.nocon = piNumeroContrat
               and cttac.tptac = {&TYPETACHE-garantieRisqueLocatif}:
        create ttCttac.
        assign
            ttCttac.tpcon       = cttac.tpcon
            ttCttac.nocon       = cttac.nocon
            ttCttac.tptac       = cttac.tptac
            ttCttac.CRUD        = "D"
            ttCttac.rRowid      = rowid(cttac)
            ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
        .
    end.

    run adblib/cttac_CRUD.p persistent set vhCttac.
    run getTokenInstance in vhCttac(mToken:JSessionId).
/*
    run setCttac in vhCttac(table ttCttac by-reference).    
*/
    run destroy in vhCttac.
end procedure.
procedure ControlesAvantValidation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voTache as class parametrageTache no-undo.
    define variable vdaDebutApplication   as date    no-undo.
    define variable viMoisMax             as integer no-undo.
    define variable vdaApplicationMinimum as date    no-undo.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.tpcon = ttTacheRisqueLocatif.cTypeContrat
          and ctrat.nocon = ttTacheRisqueLocatif.iNumeroContrat no-error.
    if not(available(ctrat)) then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if ttTacheRisqueLocatif.CRUD = "D" then do:
        voTache = new parametrageTache().
        /*
        if voTache:tacheObligatoire(ttTacheRisqueLocatif.iNumeroContrat, ttTacheRisqueLocatif.cTypeContrat, {&TYPETACHE-garantieRisqueLocatif}) = yes 
        then mError:createError({&error}, 100372).*/
        delete object voTache.
    end.
    else if ttTacheRisqueLocatif.daActivation = ?
         then mError:createError({&error}, 100299).
    else if ttTacheRisqueLocatif.daActivation < ctrat.dtini
         then mError:createErrorGestion({&error}, 100678, "").
    else if (ttTacheRisqueLocatif.iNumeroBareme = ? or ttTacheRisqueLocatif.iNumeroBareme = 0)
         then mError:createErrorGestion({&error}, 107724, "").
    else do:
        // Le controle du bareme à 0 n'est peut-être pas obligatoire car on ne charge dans la combo que les baremes non nuls

        // Controle de la date d'application en fonction du quittancement
        /* controles par rapport au mois de quitt  */
        /* date application dans quitt futur : OK */
        /* sinon elle doit être dans une quittance prise en compte dans le prochain traitement de Garantie loyer */
        if ctrat.dtdeb <> ?
        then run calculeDateApplication(ctrat.dtdeb, output vdaDebutApplication, output viMoisMax, output vdaApplicationMinimum).
        if vdaApplicationMinimum <> ? and ttTacheRisqueLocatif.daApplication < vdaApplicationMinimum
        then mError:createErrorGestion({&question}, 1000701, substitute('&2&1&3/&4&1&5', separ[1],
            //Date d'application incorrecte. Le calcul de la garantie loyer ne peut pas commencer avant le &1 avec le traitement du quittancement de &2. %sConfirmez-vous quand même la date du &3
                                                                       string(vdaApplicationMinimum, "99/99/9999"),
                                                                       string(viMoisMax modulo 100, "99"),
                                                                       string(truncate(viMoisMax / 100, 0), "9999"),
                                                                       ttTacheRisqueLocatif.daApplication)).
    end.
end procedure.

procedure infoAutorisationMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    assign
        ttTacheRisqueLocatif.lModifAutorise = not isBailResilie(ttTacheRisqueLocatif.cTypeContrat, ttTacheRisqueLocatif.iNumeroContrat)
        ttTacheRisqueLocatif.lSupprAutorise = true
        .
end procedure.

procedure calculeDateApplication private:
    /*------------------------------------------------------------------------------
    Purpose: Calcul date d'application initiale si option activée
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pdaDateDebutContrat   as date    no-undo.
    define output parameter pdaDebutApplication   as date    no-undo.
    define output parameter piMoisMax             as integer no-undo.
    define output parameter pdaApplicationMinimum as date    no-undo.

    define variable voCollectionCarence as class collection no-undo.
    define variable voCollectionQuitt   as class collection no-undo.
    define variable vdaDebutApplication as date      no-undo.
    define variable vhProcBareme        as handle    no-undo.
    define variable vhProcTransfert     as handle    no-undo.
    define variable viNombreMoisPeriode as integer   no-undo.
    define variable vcListe1erMois      as character no-undo.
    define variable vcListeDerMois      as character no-undo.
    define variable viMoisMin           as integer   no-undo.
    define variable viGlMoiMdf          as integer   no-undo.

    /*
    run donneInfosCarence(ttTacheRisqueLocatif.iNumeroGarantie, output voCollectionCarence).
    */
    // donne Date Fin de Carence
/*
    vdaDebutApplication = add-interval(pdaDateDebutContrat, voCollectionCarence:getInteger('iNombreMoisCarence'), 'months').
    run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert.
    run getTokenInstance in vhProcTransfert(mToken:JSessionId).
    voCollectionQuitt = new collection().
    voCollectionQuitt:set("cCodeTraitement", "QUIT").
    run calculTransfertAppelExterne in vhProcTransfert(input-output voCollectionQuitt).
    viGlMoiMdf = voCollectionQuitt:getInteger("GlMoiMdf").
    run destroy in vhProcTransfert.
*/
    delete object voCollectionQuitt.
    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhProcBareme.
    run getTokenInstance in vhProcbareme(mToken:JSessionId).
    run infosPeriodeGarantieLoyer in vhProcBareme(voCollectionCarence:getCharacter('cCodePeriodeCarence'), viGlMoiMdf
                                                , output viNombreMoisPeriode, output vcListe1erMois, output vcListeDerMois, output viMoisMin, output piMoisMax).
    run destroy in vhProcBareme.
    pdaApplicationMinimum = donneDateApplicationMinimum(ttTacheRisqueLocatif.iNumeroContrat, viMoisMin).
    if vdaDebutApplication <> ? and pdaApplicationMinimum <> ? and vdaDebutApplication < pdaApplicationMinimum
    then vdaDebutApplication = pdaApplicationMinimum.
    pdaDebutApplication = vdaDebutApplication.

end procedure.


procedure donneInfosCarence private:
    define input  parameter piNumeroVacanceLocative as integer  no-undo.
    define output parameter poCollection            as class collection no-undo.

    define variable viNombreMoisCarence  as integer   no-undo.
    define variable vcCodePeriodeCarence as character no-undo.
    define buffer garan for garan.

    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-GarantieRisqueLocatif}
          and garan.noctt = piNumeroVacanceLocativ2e
          and garan.tpbar = ""
          and garan.nobar = 0
          break by garan.tpctt
          :
        assign
            /*viNombreMoisCarence  = integer(garan.cddev)*/
            vcCodePeriodeCarence = garan.cdper
        .
        if first-of(garan.noctt) then do:
        end.
    end.
    /* todo : a faire */    poCollection = new collection().
   /* poCollection:set("iNombreMoisCarence",    viNombreMoisCarence).    */





    poCollection:set("cCodePeriodeCarence",   vcCodePeriodeCarence).
end procedure.










