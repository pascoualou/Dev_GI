/*------------------------------------------------------------------------
File        : suiviFinancier.p
Purpose     : pcTypeCreation = "LISTE":  Création de la table temporaire ttListeSuiviFinancierClient : suivi financier client copro par copro
              pcTypeCreation = "DETAIL": Création de la table temporaire ttDetailSuiviFinancierClient : détail du suivi financier client sur un copro (visdoscl.p)
Author(s)   : OF - 2016/23/11
Notes       :
    ttDetailSuiviFinancierClient
         NOLGN = 10  -> Appels de clotures
         NOLGN = 20  -> Trésoreries
         NOLGN = 30  -> ODT
         NOLGN = 40  -> OD non-ventilées en apbco
         NOLGN = 50  -> Compensation
         NOLGN = 60  -> Achats
         NOLGN = 100 -> Autres
                         -> Appels de fonds manuels
                         -> Appels de fonds émis
                         -> OD ventilées en apbco
         NOLGN = 110 Solde comptable
         NOLGN = 120 Total du copro.
----------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/typeAppel.i}
{preprocesseur/typeAppel2fonds.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{travaux/include/suiviFinancier.i}
{Travaux/include/intervention.i}
{travaux/include/appelDefond.i}

define variable gcEmpruntSubventionAssurance        as character no-undo.
define variable gcTravauxArchitecteDommage          as character no-undo.
define variable gcTravauxArchitecteDommageHonoraire as character no-undo.
define variable gcRoulementReserve                  as character no-undo.

assign
    gcEmpruntSubventionAssurance        = substitute("&1,&2,&3", {&TYPEAPPEL2FONDS-emprunt}, {&TYPEAPPEL2FONDS-subvention}, {&TYPEAPPEL2FONDS-indemniteAssurance})
    gcTravauxArchitecteDommage          = substitute("&1,&2,&3", {&TYPEAPPEL2FONDS-travaux}, {&TYPEAPPEL2FONDS-architecte}, {&TYPEAPPEL2FONDS-dommageOuvrage})
    gcTravauxArchitecteDommageHonoraire = substitute("&1,&2", gcTravauxArchitecteDommage, {&TYPEAPPEL2FONDS-honoraire})
    gcRoulementReserve                  = substitute("&1,&2", {&TYPEAPPEL2FONDS-financementRoulement}, {&TYPEAPPEL2FONDS-financementReserve})
.

procedure getSuiviFinancier:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par beSuiviFinancier.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat           as character no-undo.
    define input  parameter piNumeroMandat         as int64     no-undo.
    define input  parameter piNumeroDossierTravaux as integer   no-undo.
    define input  parameter pcTypeCreation         as character no-undo.
    define input  parameter pdaDateEdition         as date      no-undo.
    define output parameter table for ttListeSuiviFinancierClient.
    define output parameter table for ttDetailSuiviFinancierClient.
    define output parameter table for ttListeSuiviFinancierTravaux.

    define variable vcLibTypeLot         as character no-undo.
    define variable viNumeroCopro        as integer   no-undo.
    define variable vcTypAppTrx          as character no-undo.
    define variable vdTotalCopCle        as decimal   no-undo.
    define variable vlExisteApbco        as logical   no-undo.
    define variable viNum                as integer   no-undo.
    define variable viErreur             as integer   no-undo.
    define variable vdMontantSoldeCompta as decimal   no-undo.

    define buffer cecrln for cecrln.
    define buffer dosEt  for dosEt.
    define buffer dosdt  for dosdt.
    define buffer dosap  for dosap.
    define buffer apbco  for apbco.
    define buffer trdos  for trdos.
    define buffer ctrat  for ctrat.
    define buffer intnt  for intnt.
    define buffer trfpm  for trfpm.
    define buffer ijou   for ijou.
    define buffer clemi  for clemi.
    define buffer local  for local.
    define buffer ietab  for ietab.

message "getSuiviFinancierClient"
        "pcTypeMandat      = " pcTypeMandat
        "piNumeroMandat    = " piNumeroMandat
        "piNumeroDossierTravaux = " piNumeroDossierTravaux
        "pcTypeCreation = " pcTypeCreation.

    if pcTypeCreation = "LISTE"
    then empty temp-table ttListeSuiviFinancierClient.
    find first trdos no-lock
        where trdos.tpcon = pcTypeMandat
          and trdos.nocon = piNumeroMandat
          and trdos.nodos = piNumeroDossierTravaux no-error.
    if not available trdos then return.

    /* Numéro du copro. pour lequel on créé le détail du suivi financier */
    if pcTypeCreation = "DETAIL"
    then do:
        find first ttDetailSuiviFinancierClient
            where ttDetailSuiviFinancierClient.iNumeroEntete = 100
              and ttDetailSuiviFinancierClient.iNumeroLigne = 10 no-error. /** Enregistrement créé par visdoscl.p **/
        if available ttDetailSuiviFinancierClient then viNumeroCopro = integer(ttDetailSuiviFinancierClient.cNumeroCopro).
        if viNumeroCopro = 0 then return.
    end.

    /* MONTANTS APPELES: a partir de dosrp ou apbco */
    /*--> Cumul des montants appelés par copro */
    if pcTypeCreation = "LISTE"
    then for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-titre2copro}
          and ctrat.nocon >= trdos.nocon * 100000          // integer(string(trdos.nocon) + "00000")
          and ctrat.nocon <= trdos.nocon * 100000 + 99999:  // integer(string(trdos.nocon) + "99999"):
        create ttListeSuiviFinancierClient.
        assign
            ttListeSuiviFinancierClient.iNumeroCoproprietaire = ctrat.norol
            ttListeSuiviFinancierClient.cNomCoproprietaire    = outilFormatage:getNomTiers(ctrat.tprol, ctrat.norol)
        .
    end.
    /** Immeuble **/
    find first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = trdos.tpcon
          and intnt.nocon = trdos.nocon no-error.
    /* Appels de fonds émis avant le lot 3 des travaux: 0306/0215 */
    /* Distinction entre appels manuels et appels émis */
    {&_proparse_ prolint-nowarn(sortaccess)}
blocDoset1:
    for each doset no-lock
        where DosEt.TpCon = trdos.tpcon
          and DosEt.NoCon = trdos.nocon
          and DosEt.NoDos = trdos.nodos
          and doset.tpsur = "00001" /** Appels à l'immeuble **/
          and lookup(doset.tpapp, gcRoulementReserve) = 0
      , each dosdt no-lock
        where dosdt.noidt = doset.noidt
          and dosdt.cdapp > ""
      , first DosAp no-lock
        where DosAp.TpCon = trdos.tpcon
           and DosAp.NoCon = trdos.nocon
           and DosAp.NoDos = trdos.nodos
           and dosap.noapp = dosdt.noapp
           and dosap.fgemi = true
           and ((dosap.modetrait <> "M" and can-find (first trfpm no-lock
                                      where trfpm.tptrf = {&TYPETRANSFERT-appel}
                                        and trfpm.nomdt = trdos.nocon
                                        and (trfpm.tpapp = {&TYPEAPPEL-dossierTravaux} or (trfpm.tpapp = {&TYPEAPPEL-clotureTravaux} and trfpm.ettrt = "00099"))
                                        and trfpm.noexe = trdos.nodos
                                        and lookup(trfpm.ettrt, "00003,00013,00099") > 0))
           or (dosap.modetrait = "M" and dosap.FgRepDef))
        break by dosdt.noapp by dosdt.cdapp:
        /** Important : car les apbco sont créés au N° d'appel et à la clé **/
        if first-of (dosdt.cdapp) then do:
            if not can-find(first apbco no-lock
                where apbco.tpbud     = {&TYPEBUDGET-travaux}
                  and apbco.nobud     = trdos.nocon * 100000 + trdos.nodos  // integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
                  and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux}
                  and apbco.noapp     = dosap.noapp
                  and apbco.nomdt     = trdos.nocon
                  and apbco.cdcle     = dosdt.cdapp
                  and apbco.typapptrx = "") then next blocDoset1.

            /** Détail des appels de fonds dans le suivi client **/
            if pcTypeCreation = "DETAIL"
            then do:
                if first-of(dosdt.noapp) then do:
                    vcTypAppTrx = "DETAILS SANS TYPE".
                    run crettDetailSuiviFinancierClient(100, 0, "", substitute("&1- Appels de fonds (&2)", string(dosdt.noapp, "99"), vcTypAppTrx), "", "", "", "", "", "", "").
                end.
                assign
                    vdTotalCopCle = 0
                    vlExisteApbco  = false
                .
                for each apbco  no-lock
                    where apbco.tpbud      = {&TYPEBUDGET-travaux}
                      and apbco.nobud     = integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
                      and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux}
                      and apbco.noapp     = dosap.noapp
                      and apbco.nomdt     = trdos.nocon
                      and apbco.cdcle     = dosdt.cdapp
                      and apbco.typapptrx = ""
                      and apbco.nocop     = viNumeroCopro:
                    assign
                        vdTotalCopCle = vdTotalCopCle + apbco.mtlot
                        vlExisteApbco  = true
                    .
                end.
                if vlExisteApbco then do:
                    find first clemi no-lock
                        where clemi.noimm = intnt.noidt
                          and clemi.cdcle = dosdt.cdapp no-error.
                    run crettDetailSuiviFinancierClient(100, 0, ""
                     , substitute("   &1-&2", string(dosdt.cdapp, "X(3)"), if available clemi then clemi.lbcle else "")
                     , string(vdTotalCopCle, "->>,>>>,>>>,>>9.99")
                     , if dosap.modetrait =  "M" then string (vdTotalCopCle, "->>,>>>,>>>,>>9.99") else ""
                     , if dosap.modetrait <> "M" then string (vdTotalCopCle, "->>,>>>,>>>,>>9.99") else ""
                     , "", "", substitute("&1-&2", string(dosdt.cdapp, "X(3)"), if available clemi then clemi.lbcle else ""), "").
                end.
            end. /** IF pcTypeCreation = "DETAIL" **/
            for each apbco  exclusive-lock
                where apbco.tpbud     = {&TYPEBUDGET-travaux}
                  and apbco.nobud     = trdos.nocon * 100000 + trdos.nodos // integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
                  and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux}
                  and apbco.noapp     = dosap.noapp
                  and apbco.nomdt     = trdos.nocon
                  and apbco.cdcle     = dosdt.cdapp
                  and apbco.typapptrx = "":
                if pcTypeCreation = "DETAIL" and apbco.nocop = viNumeroCopro
                then do:
                    find first local no-lock
                        where local.noimm = intnt.noidt
                          and local.nolot = apbco.nolot no-error.
                    vcLibTypeLot = if available local then outilTraduction:getLibelleProg("NTLOT", local.ntlot) else "".
                    run crettDetailSuiviFinancierClient(100, 0, ""
                        , substitute("     &1-&2", string(apbco.nolot, ">>>9"), vcLibTypeLot), ""
                        , if dosap.modetrait = "M" then string (apbco.mtlot, "->>,>>>,>>>,>>9.99") else ""
                        , if dosap.modetrait <> "M" then string (apbco.mtlot, "->>,>>>,>>>,>>9.99") else ""
                        , "", "", "", substitute("&1-&2", string(apbco.nolot, ">>>9"), vcLibTypeLot)).
                end.
                if pcTypeCreation = "LISTE" then for first ttListeSuiviFinancierClient
                    where ttListeSuiviFinancierClient.iNumeroCoproprietaire = apbco.nocop:
                    if dosap.modetrait <> "M"
                    then ttListeSuiviFinancierClient.dMontantAppelEmis        = ttListeSuiviFinancierClient.dMontantAppelEmis        + apbco.mtlot.
                    else ttListeSuiviFinancierClient.dMontantAppelReconstitue = ttListeSuiviFinancierClient.dMontantAppelReconstitue + apbco.mtlot.
                end.
            end. /* apbco */
        end. /** IF FIRST-OF (dosdt.cdapp) THEN DO: **/
    end. /* doset */

    /* Appels de fonds émis après le lot 3 des travaux : 0306/0215 */
    /** Distinction entre appels manuels et appels émis **/
    {&_proparse_ prolint-nowarn(sortaccess)}
blocDoset2:
    for each doset no-lock
        where doset.tpcon = trdos.tpcon
          and doset.nocon = trdos.nocon
          and doset.nodos = trdos.nodos
          and doset.tpsur = "00001" /** Appels à l'immeuble **/
          and lookup(doset.tpapp, gcRoulementReserve) = 0
      , each dosdt no-lock
        where dosdt.noidt = doset.noidt
          and dosdt.cdapp <> ""
      , first dosap no-lock
        where dosap.tpcon = trdos.tpcon
          and dosap.nocon = trdos.nocon
          and dosap.nodos = trdos.nodos
          and dosap.noapp = dosdt.noapp
          and dosap.fgemi = true
          and ((dosap.modetrait <> "M" and can-find (first trfpm no-lock
                                where trfpm.tptrf = {&TYPETRANSFERT-appel}
                                  and trfpm.nomdt = trdos.nocon
                                  and (trfpm.tpapp = {&TYPEAPPEL-dossierTravaux} or (trfpm.tpapp = {&TYPEAPPEL-clotureTravaux} and trfpm.ettrt = "00099"))
                                  and trfpm.noexe = trdos.nodos
                                  and lookup(trfpm.ettrt, "00003,00013,00099") > 0))
           or (dosap.modetrait = "M" and dosap.FgRepDef) )
        break by doset.tpapp by dosdt.noapp  by dosdt.cdapp:
            /** Important : car les apbco sont créés au type d'appel , au N° d'appel et à la clé **/
        if first-of (dosdt.cdapp) then do:
            if not can-find(first apbco no-lock
                where apbco.tpbud     = {&TYPEBUDGET-travaux}
                  and apbco.nobud     = trdos.nocon * 100000 + trdos.nodos   // integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
                  and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux}
                  and apbco.noapp     = dosap.noapp
                  and apbco.nomdt     = trdos.nocon
                  and apbco.cdcle     = dosdt.cdapp
                  and apbco.typapptrx > "") then next blocDoset2.

            /** Détail des appels de fonds dans le suivi client **/
            if pcTypeCreation = "DETAIL"
            then do:
                if first-of(dosdt.noapp) then do:
                    vcTypAppTrx = "SANS TYPE".
                    /** Libellé du type d'appel **/
                    if available dosEt then vcTypAppTrx = trim(outilTraduction:getLibelleProg("TPDOS", DosEt.TpApp, mtoken:iCodeLangueSession, mtoken:iCodeLangueReference)).
                    run crettDetailSuiviFinancierClient(100, 0, "", substitute('&1-&2 (&3)', string(dosdt.noapp, "99"), dosdt.lbapp[1], vcTypAppTrx), "", "", "", "", "", "", "").
                end.
                assign
                    vdTotalCopCle = 0
                    vlExisteApbco  = false
                .
                for each apbco  no-lock
                    where apbco.tpbud     = {&TYPEBUDGET-travaux}
                      and apbco.nobud     = trdos.nocon * 100000 + trdos.nodos // integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
                      and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux}
                      and apbco.noapp     = dosap.noapp
                      and apbco.nomdt     = trdos.nocon
                      and apbco.cdcle     = dosdt.cdapp
                      and apbco.typapptrx = DosEt.TpApp
                      and apbco.nocop     = viNumeroCopro:
                    assign
                        vdTotalCopCle = vdTotalCopCle + apbco.mtlot
                        vlExisteApbco  = true
                    .
                end.
                if vlExisteApbco then do:
                    find first clemi no-lock
                        where clemi.noimm = intnt.noidt
                          and clemi.cdcle = dosdt.cdapp no-error.
                    run crettDetailSuiviFinancierClient(100, 0, ""
                        , substitute("   &1-&2", string(dosdt.cdapp, "X(3)"), if available clemi then clemi.lbcle else "")
                        , string(vdTotalCopCle, "->>,>>>,>>>,>>9.99")
                        , if dosap.modetrait = "M"  then string(vdTotalCopCle, "->>,>>>,>>>,>>9.99") else ""
                        , if dosap.modetrait <> "M" then string(vdTotalCopCle, "->>,>>>,>>>,>>9.99") else ""
                        , "", "", substitute("&1-&2", string (dosdt.cdapp, "X(3)"), if available clemi then clemi.lbcle else ""), "").
                end.
            end.
            for each apbco  no-lock
                where apbco.tpbud     = {&TYPEBUDGET-travaux}
                  and apbco.nobud     = trdos.nocon * 100000 + trdos.nodos  // integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
                  and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux}
                  and apbco.noapp     = dosap.noapp
                  and apbco.nomdt     = trdos.nocon
                  and apbco.cdcle     = dosdt.cdapp
                  and apbco.typapptrx = DosEt.TpApp:
                if pcTypeCreation = "DETAIL" and apbco.nocop = viNumeroCopro
                then do:
                    find first local no-lock
                        where local.noimm = intnt.noidt
                          and local.nolot = apbco.nolot no-error.
                    vcLibTypeLot = if available local then trim(outilTraduction:getLibelleProg("NTLOT", local.ntlot)) else "".
                    run crettDetailSuiviFinancierClient(100, 0, ""
                        , substitute("     &1-&2", string(apbco.nolot, ">>>9"), vcLibTypeLot), ""
                        , if dosap.modetrait = "M" then string(apbco.mtlot, "->>,>>>,>>>,>>9.99") else ""
                        , if dosap.modetrait <> "M" then string(apbco.mtlot, "->>,>>>,>>>,>>9.99") else ""
                        , "", "", "", substitute("&1-&2", string(apbco.nolot, ">>>9"), vcLibTypeLot)).
                end.
                if pcTypeCreation = "LISTE" then for first ttListeSuiviFinancierClient
                    where ttListeSuiviFinancierClient.iNumeroCoproprietaire = apbco.nocop:
                    if dosap.modetrait <> "M"
                    then ttListeSuiviFinancierClient.dMontantAppelEmis        = ttListeSuiviFinancierClient.dMontantAppelEmis + apbco.mtlot.
                    else ttListeSuiviFinancierClient.dMontantAppelReconstitue = ttListeSuiviFinancierClient.dMontantAppelReconstitue + apbco.mtlot.
                end.
            end.
        end. /** IF FIRST-OF (dosdt.cdapp) THEN DO: **/
    end. /* doset */

    /* Appels de fonds aux matricule */
    /* Pb sur les appels aux matricules sur plusieurs lots - 1210/0007 */
    {&_proparse_ prolint-nowarn(sortaccess)}
blocDoset3:
    for each DosEt no-lock
        where DosEt.TpCon = trdos.tpcon
          and DosEt.NoCon = trdos.nocon
          and DosEt.NoDos = trdos.nodos
          and doset.tpsur = "00002" /** Appels aux matricules **/
          and lookup(doset.tpapp, gcRoulementReserve) = 0
      , each dosdt no-lock
        where dosdt.noidt = doset.noidt
          and dosdt.cdapp <> ""
      , first DosAp no-lock
        where DosAp.TpCon = trdos.tpcon
          and DosAp.NoCon = trdos.nocon
          and DosAp.NoDos = trdos.nodos
          and dosap.noapp = dosdt.noapp
          and dosap.fgemi = true
          and ((dosap.modetrait <> "M" and can-find (first trfpm no-lock
                                 where trfpm.tptrf = {&TYPEBUDGET-travaux}
                                   and trfpm.nomdt = trdos.nocon
                                   and (trfpm.tpapp = {&TYPEAPPEL-dossierTravaux} or (trfpm.tpapp = {&TYPEAPPEL-clotureTravaux} and trfpm.ettrt = "00099"))
                                   and trfpm.noexe = trdos.nodos
                                   and lookup(trfpm.ettrt, "00003,00013,00099") > 0))
            or (dosap.modetrait = "M" and dosap.FgRepDef) )
        break by doset.tpapp
              by dosdt.noapp
              by integer(entry(1, dosdt.cdapp, separ[1]))    // rupture sur copro, lot
              by integer(entry(2, dosdt.cdapp, separ[1])):
        /** Important : car les apbco sont créés au type d'appel , au N° d'appel et à la clé **/
        if not can-find(first apbco no-lock
            where apbco.tpbud = {&TYPEBUDGET-travaux}
              and apbco.nobud = trdos.nocon * 100000 + trdos.nodos     // integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
              and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
              and apbco.noapp = dosap.noapp
              and apbco.nomdt = trdos.nocon
              and apbco.cdcle = "XX") then next blocDoset3.

        /** Détail des appels de fonds dans le suivi client **/
        if pcTypeCreation = "DETAIL" and viNumeroCopro = integer(entry(1, dosdt.cdapp, separ[1]))
            and first-of(integer(entry(1, dosdt.cdapp, separ[1])))
        then do:
            assign
                vdTotalCopCle = 0
                vlExisteApbco  = false
            .
            for each apbco  no-lock
                where apbco.tpbud     = {&TYPEBUDGET-travaux}
                  and apbco.nobud     = trdos.nocon * 100000 + trdos.nodos  // integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
                  and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux}
                  and apbco.noapp     = dosap.noapp
                  and apbco.nomdt     = trdos.nocon
                  and apbco.cdcle     = "XX"
                  and apbco.typapptrx = DosEt.TpApp
                  and apbco.nocop     = viNumeroCopro:
                assign
                    /* enregistrement recap -> cumul du montant sur tous les lots */
                    vdTotalCopCle = vdTotalCopCle + apbco.mtlot
                    vlExisteApbco  = true
                .
            end.
            vcTypAppTrx = outilTraduction:getLibelle(111806, mtoken:iCodeLangueSession, mtoken:iCodeLangueReference). /*"APPEL AU MATRICULE"*/
            run crettDetailSuiviFinancierClient(100, 0, ""
                , substitute('&1-&2 (&3)', string(dosdt.noapp, "99"), dosdt.lbapp[1], vcTypAppTrx)
                , string(vdTotalCopCle, "->>,>>>,>>>,>>9.99")
                , if dosap.modetrait = "M"  then string(vdTotalCopCle, "->>,>>>,>>>,>>9.99") else ""
                , if dosap.modetrait <> "M" then string(vdTotalCopCle, "->>,>>>,>>>,>>9.99") else ""
                , "", "", "", "").
        end.
        if first-of(integer(entry(2, dosdt.cdapp, separ[1])))
        then for each apbco  exclusive-lock
            where apbco.tpbud     = {&TYPEBUDGET-travaux}
              and apbco.nobud     = trdos.nocon * 100000 + trdos.nodos     // integer(string(trdos.nocon) + string(trdos.nodos, "99999"))
              and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux}
              and apbco.noapp     = dosap.noapp
              and apbco.nomdt     = trdos.nocon
              and apbco.cdcle     = "XX"
              and apbco.typapptrx = DosEt.TpApp
              and apbco.nocop     = integer(entry(1, dosdt.cdapp, separ[1]))
              and apbco.nolot     = integer(entry(2, dosdt.cdapp, separ[1])):
            if pcTypeCreation = "DETAIL" and viNumeroCopro = integer(entry(1, dosdt.cdapp, separ[1]))
            then do:
                find first local no-lock
                    where local.noimm = intnt.noidt
                      and local.nolot = apbco.nolot no-error.
                vcLibTypeLot = if available local
                              then trim(outilTraduction:getLibelleProg("NTLOT", local.ntlot, mtoken:iCodeLangueSession, mtoken:iCodeLangueReference))
                              else "".
                run crettDetailSuiviFinancierClient(100, 0, ""
                    , substitute("   &1-&2", string(apbco.nolot, ">>>9"), vcLibTypeLot), ""
                    , if dosap.modetrait =  "M" then string (apbco.mtlot, "->>,>>>,>>>,>>9.99") else ""
                    , if dosap.modetrait <> "M" then string (apbco.mtlot, "->>,>>>,>>>,>>9.99") else ""
                    , "", "", "", substitute("&1-&2", string(apbco.nolot, ">>>9"), vcLibTypeLot)).
            end.
            if pcTypeCreation = "LISTE" then for first ttListeSuiviFinancierClient
                where ttListeSuiviFinancierClient.iNumeroCoproprietaire = apbco.nocop:
                if dosap.modetrait <> "M"
                then ttListeSuiviFinancierClient.dMontantAppelEmis        = ttListeSuiviFinancierClient.dMontantAppelEmis + apbco.mtlot.
                else ttListeSuiviFinancierClient.dMontantAppelReconstitue = ttListeSuiviFinancierClient.dMontantAppelReconstitue + apbco.mtlot.
            end.
        end. /* apbco */
    end. /* doset */

    /* Les écritures CPHB ( Appel de cloture ) sont dans le montant appelé **/
    /* MONTANT ENCAISSE */
    /*--> Montant encaissé par copro */
    viNum = if pcTypeCreation = "LISTE" then 1 else 3.
    run travaux/dossierTravaux/GI_dostrav.p(
        integer(if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance),
        viNum,
        TrDos.nocon,
        TrDos.nodos,
        pdaDateEdition,
        TrDos.tpcon,
        TrDos.tpurg,
        input-output table ttListeSuiviFinancierClient  by-reference,
        input-output table ttDetailSuiviFinancierClient by-reference,
        input-output table ttListeEcriture              by-reference,
        input-output table ttDetailAppelTravauxParLot   by-reference,
        input-output table ttListeSuiviFinancierTravaux by-reference,
        output viErreur).
    if pcTypeCreation = "LISTE"
    then for each ttListeSuiviFinancierClient where ttListeSuiviFinancierClient.iNumeroCoproprietaire > 0:
        assign
        /* Maj du reste Dû */
        /** MtAppTotEmi = Somme des apbco ( quand il n'y en a pas dosrp ) + Somme de CPHB + Les OD ventilées en apbco **/
            ttListeSuiviFinancierClient.dSommeAppelEmis = ttListeSuiviFinancierClient.dMontantAppelEmis + ttListeSuiviFinancierClient.dMontantAppelCloture + ttListeSuiviFinancierClient.dMontantODAvecDetail
        /** MtAppMan = Somme des appels de fonds manuels **/
        /** MtApp = Somme de tous les appels  **/
            ttListeSuiviFinancierClient.dMontantTotalAppele  = ttListeSuiviFinancierClient.dSommeAppelEmis + ttListeSuiviFinancierClient.dMontantAppelReconstitue
        /** La colonne 'Encaissé/Autres' contient tout le reste **/
            ttListeSuiviFinancierClient.dMontantEncaissement = ttListeSuiviFinancierClient.dMontantTresorerie     /** Trésorerie                     **/
                                                             + ttListeSuiviFinancierClient.dMontantODTresorerie   /** ODT                            **/
                                                             + ttListeSuiviFinancierClient.dMontantCompensation   /** La compensation                **/
                                                             + ttListeSuiviFinancierClient.dMontantAchat          /** Achats                         **/
                                                             + ttListeSuiviFinancierClient.dMontantAutre          /** Le reste                       **/
                                                             - (ttListeSuiviFinancierClient.dMontantAppelReconstitue - ttListeSuiviFinancierClient.dMontantODSansDetail)  /*Il faut passer les montants en négatifs car ils sont considérés comme de la trésorerie (crédit)*/
        /** Reste dû **/
            ttListeSuiviFinancierClient.dMontantResteDu      = ttListeSuiviFinancierClient.dMontantTotalAppele + ttListeSuiviFinancierClient.dMontantEncaissement
        /* Solde du CHB */
        /** Calcul des soldes comptables **/
            vdMontantSoldeCompta = 0
        .
        for first ietab no-lock
            where ietab.soc-cd  = integer(if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
              and ietab.etab-cd = piNumeroMandat:
            for each cecrln no-lock
                where cecrln.soc-cd     = ietab.soc-cd
                  and cecrln.etab-cd    = ietab.etab-cd
                  and cecrln.sscoll-cle = "CHB"
                  and cecrln.cpt-cd     = string(ttListeSuiviFinancierClient.iNumeroCoproprietaire, "99999")
                  and cecrln.affair-num = piNumeroDossierTravaux:
                if can-find(first ijou no-lock
                    where ijou.soc-cd    = cecrln.soc-cd
                      and ijou.etab-cd   = cecrln.mandat-cd
                      and ijou.jou-cd    = cecrln.jou-cd
                      and ijou.natjou-gi <> 93)
                then vdMontantSoldeCompta = vdMontantSoldeCompta + (if cecrln.sens then 1 else - 1) * cecrln.mt.
            end.
        end.
        ttListeSuiviFinancierClient.dSoldeCHB = vdMontantSoldeCompta.

        /* Solde du CHB <> Reste Dû */
        /*Pour les dossiers dupliqués, on n'a pas forcément récupéré tous les encaissements.
          Pour afficher le suivi financier client, on est donc obligé de partir du principe que le montant
          des encaissements est la différence entre le solde du copropriétaire et ses appels de fonds*/
        if TrDos.cdcsy matches "*@DUPLI*"
        then assign
            ttListeSuiviFinancierClient.dMontantResteDu      = ttListeSuiviFinancierClient.dSoldeCHB
            ttListeSuiviFinancierClient.dMontantEncaissement = ttListeSuiviFinancierClient.dSommeAppelEmis - ttListeSuiviFinancierClient.dMontantResteDu
        .
        else if ttListeSuiviFinancierClient.dMontantResteDu <> ttListeSuiviFinancierClient.dSoldeCHB
             then ttListeSuiviFinancierClient.lAnomalie = true.
    end. /** FOR EACH ttListeSuiviFinancierClient : **/
    run getSuiviTravaux(pcTypeMandat, piNumeroMandat, piNumeroDossierTravaux).

message "Fin - liste du suivi client: ".
for each ttListeSuiviFinancierClient:
    message "Copro" string(ttListeSuiviFinancierClient.iNumeroCoproprietaire,"99999") string(ttListeSuiviFinancierClient.cNomCoproprietaire,"x(20)")
    " - MtAppEmi = " string(ttListeSuiviFinancierClient.dMontantAppelEmis,"->>,>>9.99")
    " - MtAppMan = " string(ttListeSuiviFinancierClient.dMontantAppelReconstitue,"->>,>>9.99")
    " - MtEnc = " string(ttListeSuiviFinancierClient.dMontantEncaissement,"->>,>>9.99")
    " - MtEncL = " string(ttListeSuiviFinancierClient.dMontantEncaissementLettre,"->>,>>9.99")
    " - MtEncNL = " string(ttListeSuiviFinancierClient.dMontantEncaissementNonLettre,"->>,>>9.99")
    " - MtAppCphb = " string(ttListeSuiviFinancierClient.dMontantAppelCloture,"->>,>>9.99")
    " - MtAutres = " string(ttListeSuiviFinancierClient.dMontantAutre,"->>,>>9.99")
    " - MtApp = " string(ttListeSuiviFinancierClient.dMontantTotalAppele,"->>,>>9.99")
    " - MtAppTotEmi = " string(ttListeSuiviFinancierClient.dSommeAppelEmis,"->>,>>9.99")
    " - MtOdApbco = " string(ttListeSuiviFinancierClient.dMontantOdAvecDetail,"->>,>>9.99")
    " - MtOd = " string(ttListeSuiviFinancierClient.dMontantOdSansDetail,"->>,>>9.99")
    " - MtAchats = " string(ttListeSuiviFinancierClient.dMontantAchat,"->>,>>9.99")
    " - MtOdt = " string(ttListeSuiviFinancierClient.dMontantODTresorerie,"->>,>>9.99")
    " - MtRes = " string(ttListeSuiviFinancierClient.dMontantResteDu,"->>,>>9.99")
    " - MtTreso = " string(ttListeSuiviFinancierClient.dMontantTresorerie,"->>,>>9.99")
    " - solde_chb = " string(ttListeSuiviFinancierClient.dSoldeChb,"->>,>>9.99")
    " - MtCmp = " string(ttListeSuiviFinancierClient.dMontantCompensation,"->>,>>9.99")
    .
end.

end procedure.

procedure crettDetailSuiviFinancierClient private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumEnt      as integer   no-undo.
    define input parameter pinolig       as integer   no-undo.
    define input parameter pcNoCop       as character no-undo.
    define input parameter pcNmCop       as character no-undo.
    define input parameter pcMtApp       as character no-undo.
    define input parameter pcMtAppMan    as character no-undo.
    define input parameter pcMtAppTotEmi as character no-undo.
    define input parameter pcMtEnc       as character no-undo.
    define input parameter pcMtRes       as character no-undo.
    define input parameter pcCle         as character no-undo.
    define input parameter pcLot         as character no-undo.

    if pinolig = 0
    then for last ttDetailSuiviFinancierClient:
        pinolig = ttDetailSuiviFinancierClient.iNumeroLigne + 10.
    end.
    create ttDetailSuiviFinancierClient.
    assign
        ttDetailSuiviFinancierClient.iNumeroEntete         = piNumEnt
        ttDetailSuiviFinancierClient.iNumeroLigne          = pinolig
        ttDetailSuiviFinancierClient.cNumeroCoproprietaire = pcNoCop
        ttDetailSuiviFinancierClient.cNomCoproprietaire    = pcNmCop
        ttDetailSuiviFinancierClient.cMontantAppel         = pcMtApp
        ttDetailSuiviFinancierClient.cMontantAppelManuel   = pcMtAppMan
        ttDetailSuiviFinancierClient.cMontantAppelEmis     = pcMtAppTotEmi
        ttDetailSuiviFinancierClient.cMontantEncaisse      = pcMtEnc
        ttDetailSuiviFinancierClient.cMontantRestant       = pcMtRes
        ttDetailSuiviFinancierClient.cCodeCle              = pcCle
        ttDetailSuiviFinancierClient.cNumeroLot            = pcLot
    .
end procedure.

procedure getSuiviTravaux private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat           as character no-undo.
    define input  parameter piNumeroMandat         as int64     no-undo.
    define input  parameter piNumeroDossierTravaux as integer   no-undo.

    define variable voCollection      as class collection no-undo.
    define variable voArticle         as class collection no-undo.
    define variable vhIntervention    as handle    no-undo.
    define variable vhAppelDeFond     as handle    no-undo.
    define variable vhProcTVA         as handle    no-undo.
    define variable vcTypeAppelFonds  as character no-undo.
    define variable vdMontantReponse  as decimal   no-undo.
    define variable vdMontantOS       as decimal   no-undo.
    define variable vdTotalEmprunt    as decimal   no-undo.
    define variable vdTotalProvision  as decimal   no-undo.
    define variable vdTotalAppel      as decimal   no-undo.
    define variable vdTotalVente      as decimal   no-undo.
    define variable vdCumulVente      as decimal   no-undo.
    define variable vdMontantAppel    as decimal   no-undo.
    define variable vdMontantAppelMan as decimal   no-undo.
    define variable vdAppelEmis       as decimal   no-undo.
    define variable vdMontantFacture  as decimal   no-undo.
    define variable vdMontantEncaisse as decimal   no-undo.
    define variable viErreur          as integer   no-undo.
    define variable vdTotalAppelEmis  as decimal   no-undo.

    define buffer DosAp for DosAp.
    define buffer DtOrd for DtOrd.
    define buffer svdev for svdev.
    define buffer trdos for trdos.

    voCollection = new collection().
    voCollection:set('cTypeMandat', pcTypeMandat) no-error.
    voCollection:set('iNumeroMandat', piNumeroMandat) no-error.
    voCollection:set('iNumeroDossierTravaux', piNumeroDossierTravaux) no-error.
    voCollection:set('cCodeStatutIntervention', "") no-error.

    run travaux/intervention/intervention.p persistent set vhIntervention.
    run getTokenInstance in vhIntervention (mToken:JSessionId).
    run getListeInterventions in vhIntervention(voCollection, output table ttListeIntervention).
    run destroy in vhIntervention.

    run travaux/dossierTravaux/appelDeFond.p persistent set vhAppelDeFond.
    run getTokenInstance in vhAppelDeFond (mToken:JSessionId).
    run getAppelDeFond in vhAppelDeFond (voCollection,
                                         output table ttEnteteAppelDeFond  by-reference,
                                         output table ttAppelDeFond        by-reference,
                                         output table ttAppelDeFondRepCle  by-reference,
                                         output table ttAppelDeFondRepMat  by-reference,
                                         output table ttDossierAppelDeFond by-reference).
    run destroy in vhAppelDeFond.

    run compta/outilsTVA.p persistent set vhProcTVA.
    run getTokenInstance in vhProcTVA (mToken:JSessionId).

    /* Ajout Sy le 16/07/2008 : initialisation type de travaux */
    /* si appel de fonds associé de type provision, honoraires, emprunt, subvention ou indemnité assurance : conserver ce type */
    /* sinon si code article => type de travaux associé (s'il existe) */
    /* sinon  => type de l'appel de fonds */
    /* sinon type par défaut = travaux */
    find first trdos no-lock
        where trdos.tpcon = pcTypeMandat
          and trdos.nocon = piNumeroMandat
          and trdos.nodos = piNumeroDossierTravaux no-error.
    for each ttListeIntervention
        where ttListeIntervention.cCodeTraitement <> {&TYPEINTERVENTION-signalement}:
        vcTypeAppelFonds = "".
        if valid-object(voArticle) then delete object voArticle.
        if integer(ttListeIntervention.cCodeArticle) <> 0  /* recherche si type de travaux paramétré pour cet article */
        then run travaux/intervention/paramArticleIntervention.p(
                trdos.tpcon,
                trdos.TpUrg,
                yes,
                ttListeIntervention.cCodeArticle,
                output voArticle).
        /* recherche si appel lié à cette intervention */
        find first ttEnteteAppelDeFond
            where ttEnteteAppelDeFond.iNumeroIntervention = ttListeIntervention.iNumeroIntervention no-error.
        if available ttEnteteAppelDeFond then vcTypeAppelFonds = trim(ttEnteteAppelDeFond.cCodeTypeAppel).
        /* si appel <> travaux, archi, domm ouvr (provision, honoraires, emprunt, subvention ou indemnité assurance) : conserver ce type */
        if vcTypeAppelFonds > "" and lookup(vcTypeAppelFonds, gcTravauxArchitecteDommage) = 0
        then ttListeIntervention.cCodeTypeTravaux = vcTypeAppelFonds.
        else ttListeIntervention.cCodeTypeTravaux = if valid-object(voArticle) and voArticle:getCharacter('cAnalytiqueTravaux') > ""
                                                    then voArticle:getCharacter('cAnalytiqueTravaux')
                                                    else if vcTypeAppelFonds > ""
                                                         then vcTypeAppelFonds
                                                         else "00001".  /* ni article ni appel => travaux (pas provision car réservé CABINET => ligne unique en fin de tableau ! */
    end.
    /*--> Generation de la table de suivi - intervention */
    for each ttListeIntervention
        where ttListeIntervention.cCodeTraitement <> {&TYPEINTERVENTION-signalement}
          and (ttListeIntervention.cCodeTraitement <> {&TYPEINTERVENTION-reponseDevis}
           or ttListeIntervention.cCodeStatut = {&STATUTINTERVENTION-vote}
           or ttListeIntervention.cCodeStatut = {&STATUTINTERVENTION-voteResp}
           or ttListeIntervention.cCodeStatut = {&STATUTINTERVENTION-VoteProp}
           or ttListeIntervention.cCodeStatut = {&STATUTINTERVENTION-voteCS}
           or ttListeIntervention.cCodeStatut = {&STATUTINTERVENTION-voteAG})
        break by ttListeIntervention.cCodeFournisseur
              by ttListeIntervention.cCodeTypeTravaux
              by ttListeIntervention.cCodeTraitement:
        if first-of(ttListeIntervention.cCodeTypeTravaux)
        then assign
            vdMontantReponse = 0
            vdMontantOS      = 0
        .
        case ttListeIntervention.cCodeTraitement:
            when {&TYPEINTERVENTION-reponseDevis} then for each svdev no-lock
                where svdev.nodev = ttListeIntervention.iNumeroTraitement
                  and svdev.noint = ttListeIntervention.iNumeroIntervention:
                vdMontantReponse = vdMontantReponse + dynamic-function('calculTTCdepuisHT' in vhProcTVA, svdev.cdtva, svdev.mtint).
            end.
            when {&TYPEINTERVENTION-ordre2service} then for each dtord no-lock
                where dtord.noOrd = ttListeIntervention.iNumeroTraitement
                  and dtord.noint = ttListeIntervention.iNumeroIntervention:
                vdMontantOS = vdMontantOS + dynamic-function('calculTTCdepuisHT' in vhProcTVA, dtord.cdtva, dtord.mtint).
            end.
        end case.
        if last-of(ttListeIntervention.cCodeTypeTravaux) then do:
            create ttListeSuiviFinancierTravaux.
            assign
                ttListeSuiviFinancierTravaux.iCodeFournisseur      = integer(ttListeIntervention.cCodeFournisseur)
                ttListeSuiviFinancierTravaux.cLibelleTri           = string(ttListeIntervention.cLibelleFournisseur , "X(50)") + ttListeIntervention.cCodeTypeTravaux
                ttListeSuiviFinancierTravaux.cNomFournisseur       = ttListeIntervention.cLibelleFournisseur
                ttListeSuiviFinancierTravaux.dMontantReponseDevis  = vdMontantReponse
                ttListeSuiviFinancierTravaux.dMontantOrdre2Service = vdMontantOS
                ttListeSuiviFinancierTravaux.cCodeTypeTravaux      = ttListeIntervention.cCodeTypeTravaux
                ttListeSuiviFinancierTravaux.cLibelleTypeTravaux   = outilTraduction:getLibelleParam("TPDOS",ttListeIntervention.cCodeTypeTravaux)
            .
        end.
    end.
    /*-----------------------------------------------------------------------
                    SI LE DOSSIER N'EST PAS CLOTURE
            ttListeSuiviFinancierTravaux.dMontantAppel proraté avec (emprunts / provisions)
          Travaux, Architecte et Dommage Ouvrage seulement : 1,3,4
          Provision, Honoraires, Emprunt, Subvention, Indémnités assurance : 2,5,6,7,8
    -----------------------------------------------------------------------*/
    assign
        vdTotalEmprunt   = 0  /** Montant total des emprunts    **/
        vdTotalProvision = 0  /** Montant total des provisions  **/
        vdTotalAppel     = 0  /** Montant total des appels  : emprunts + provisions  **/
    .
    for each ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.cCodeTypeAppel < {&TYPEAPPEL2FONDS-financementRoulement} /* RF 0306/0215 exclusion FR0 */
        by ttEnteteAppelDeFond.cCodeTypeAppel:
        /*--> Cumul */
        for each ttAppelDeFond
            where ttAppelDeFond.lFlagEmis: /* Appel Emis !!! */
            if lookup(ttEnteteAppelDeFond.cCodeTypeAppel, gcEmpruntSubventionAssurance) > 0
            then vdTotalEmprunt   = vdTotalEmprunt   + ttAppelDeFond.dMontantAppel.
            else vdTotalProvision = vdTotalProvision + ttAppelDeFond.dMontantAppel.
            /* TODO  A VOIR : fonds de roulement/réserve */
            vdTotalAppel = vdTotalAppel + ttAppelDeFond.dMontantAppel.
        end.
    end.
    vdTotalEmprunt = vdTotalEmprunt * -1. /* inversion du signe des emprunts */
    /* OD VENTILEES COMME DES APPELS DE FONDS : elles rentrent dans le total des provisions */
    empty temp-table ttListeEcriture.
    run travaux/dossierTravaux/GI_dostrav.p(
         integer(if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance),
         7,
         piNumeroMandat,
         piNumeroDossierTravaux,
         ?,
         pcTypeMandat,
         trdos.tpurg,
         input-output table ttListeSuiviFinancierClient  by-reference,
         input-output table ttDetailSuiviFinancierClient by-reference,
         input-output table ttListeEcriture              by-reference,
         input-output table ttDetailAppelTravauxParLot   by-reference,
         input-output table ttListeSuiviFinancierTravaux by-reference,
         output viErreur).
    for each ttListeEcriture:
        vdTotalAppel = vdTotalAppel + (if ttListeEcriture.lSensMontant then 1 else - 1) * ttListeEcriture.dMontant.
        find first ttEnteteAppelDeFond
            where ttEnteteAppelDeFond.iNumeroIdentifiant = 99999
              and ttEnteteAppelDeFond.iNumeroOrdre       = 99999
              and ttEnteteAppelDeFond.cCodeTypeAppel     = {&TYPEAPPEL2FONDS-provision}
              and ttEnteteAppelDeFond.cCodeFournisseur   = "2" no-error.
        if not available ttEnteteAppelDeFond then do:
            /** Les od manuelles ventilées avec des apbco sont considérées comme des appels de fonds pour la suite **/
            create ttEnteteAppelDeFond.
            assign
                ttEnteteAppelDeFond.iNumeroIdentifiant = 99999
                ttEnteteAppelDeFond.iNumeroOrdre       = 99999
                ttEnteteAppelDeFond.cCodeTypeAppel     = {&TYPEAPPEL2FONDS-provision}
                ttEnteteAppelDeFond.cCodeFournisseur   = "2"
            .
            create ttAppelDeFond.
            assign
                ttAppelDeFond.iNumeroAppel = ttEnteteAppelDeFond.iNumeroIdentifiant
                ttAppelDeFond.lFlagEmis = true
                ttAppelDeFond.iNumeroAppel = ttEnteteAppelDeFond.iNumeroIdentifiant
                ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
            .
        end.
        ttAppelDeFond.dMontantAppel = ttAppelDeFond.dMontantAppel + (if ttListeEcriture.lSensMontant then 1 else - 1) * ttListeEcriture.dMontant.
    end.
    assign
        vdTotalVente = 0
        vdCumulVente = 0
    .
    /* 0306/0215 - dossier non cloturé */
    if trdos.dtree = ?
    then do:
        /*-------------------------------------------------------------------------------------------------------------
                                                APPELS DE FONDS EN GESTION
        ---------------------------------------------------------------------------------------------------------------*/
        /*Travaux, Architecte et Dommage Ouvrage seulement : 1,3,4 */
        /*-> les provisions 00002 ne sont pas rattachées à une intervention */
        for each ttEnteteAppelDeFond
            where lookup(ttEnteteAppelDeFond.cCodeTypeAppel, gcTravauxArchitecteDommage) > 0
            break by ttEnteteAppelDeFond.cCodeFournisseur
                  by ttEnteteAppelDeFond.cCodeTypeAppel:
            /*--> Initialisation des cumuls */
            if first-of(ttEnteteAppelDeFond.cCodeTypeAppel)
            then assign
                vdMontantAppel    = 0
                vdMontantAppelMan = 0
            .
            /*--> Cumul */
            for each ttAppelDeFond
                where ttAppelDeFond.lFlagEmis
                  and ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
                find first DosAp no-lock
                    where DosAp.TpCon = trdos.tpcon
                      and DosAp.NoCon = trdos.nocon
                      and DosAp.NoDos = trdos.nodos
                      and dosap.noapp = ttAppelDeFond.iNumeroAppel no-error.
                if available dosap and dosap.modetrait = "M"
                then vdMontantAppelMan = vdMontantAppelMan + ttAppelDeFond.dMontantAppel.
                else vdMontantAppel    = vdMontantAppel + ttAppelDeFond.dMontantAppel.
            end.
            /*--> Creation du suivi */
            if last-of(ttEnteteAppelDeFond.cCodeTypeAppel)
            then do:
                find first ttListeSuiviFinancierTravaux
                    where ttListeSuiviFinancierTravaux.iCodeFournisseur = integer(ttEnteteAppelDeFond.cCodeFournisseur)
                      and ttListeSuiviFinancierTravaux.cCodeTypeTravaux = ttEnteteAppelDeFond.cCodeTypeAppel no-error.
                if not available ttListeSuiviFinancierTravaux
                then do:
                    create ttListeSuiviFinancierTravaux.
                    assign
                        ttListeSuiviFinancierTravaux.iCodeFournisseur    = integer(ttEnteteAppelDeFond.cCodeFournisseur)
                        ttListeSuiviFinancierTravaux.cLibelleTri         = string(ttEnteteAppelDeFond.cLibelleFournisseur , "X(50)") + ttEnteteAppelDeFond.cCodeTypeAppel
                        ttListeSuiviFinancierTravaux.cNomFournisseur     = ttEnteteAppelDeFond.cLibelleFournisseur
                        ttListeSuiviFinancierTravaux.cCodeTypeTravaux    = ttEnteteAppelDeFond.cCodeTypeAppel
                        ttListeSuiviFinancierTravaux.cLibelleTypeTravaux = outilTraduction:getLibelleParam("TPDOS", ttEnteteAppelDeFond.cCodeTypeAppel)
                    .
                end.
                /* DM 0907/0182 Montant des appels par fournisseur diminué du montant des emprunts au prorata
                   ttListeSuiviFinancierTravaux.dMontantAppel = vdMontantAppel.
                */
                if vdTotalProvision <> 0 then assign
                    /** Appels émis **/
                    vdAppelEmis                                      = round((vdTotalEmprunt / vdTotalProvision) * vdMontantAppel, 2)
                    vdCumulVente                                     = vdCumulVente + vdAppelEmis
                    ttListeSuiviFinancierTravaux.dMontantAppelEmis   = vdMontantAppel - vdAppelEmis
                    /** Appels manuels **/
                    vdAppelEmis                                      = round((vdTotalEmprunt / vdTotalProvision) * vdMontantAppelMan, 2)
                    vdCumulVente                                     = vdCumulVente + vdAppelEmis
                    ttListeSuiviFinancierTravaux.dMontantAppelManuel = vdMontantAppelMan - vdAppelEmis
                .
                else assign
                    ttListeSuiviFinancierTravaux.dMontantAppelEmis   = vdMontantAppel
                    ttListeSuiviFinancierTravaux.dMontantAppelManuel = vdMontantAppelMan
                .
                vdTotalVente = vdTotalVente + ttListeSuiviFinancierTravaux.dMontantAppelEmis + ttListeSuiviFinancierTravaux.dMontantAppelManuel.
            end.
        end. /** FOR EACH ttEnteteAppelDeFond NO-LOCK   **/

        /* Provision, Honoraires, Emprunt, Subvention, Indémnités assurance : 2,5,6,7,8 */
        for each ttEnteteAppelDeFond
             where lookup(ttEnteteAppelDeFond.cCodeTypeAppel, substitute("&1,&2", gcTravauxArchitecteDommage, gcRoulementReserve)) = 0
             break by ttEnteteAppelDeFond.cCodeTypeAppel:
            /*--> Initialisation des cumuls */
            if first-of(ttEnteteAppelDeFond.cCodeTypeAppel) then assign vdMontantAppel = 0 vdMontantAppelMan = 0.

            /*--> Cumul */
            for each ttAppelDeFond
                where ttAppelDeFond.lFlagEmis
                  and ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
                find first DosAp no-lock
                    where DosAp.TpCon = trdos.tpcon
                      and DosAp.NoCon = trdos.nocon
                      and DosAp.NoDos = trdos.nodos
                      and dosap.noapp = ttAppelDeFond.iNumeroAppel no-error.
                if available dosap
                then if dosap.modetrait = "M"
                     then vdMontantAppelMan = vdMontantAppelMan + ttAppelDeFond.dMontantAppel.
                     else vdMontantAppel = vdMontantAppel + ttAppelDeFond.dMontantAppel.
                else vdMontantAppel = vdMontantAppel + ttAppelDeFond.dMontantAppel.   /** OD manuelle avec ventilation en apbco **/
            end.
            /*--> Creation du suivi */
            if last-of(ttEnteteAppelDeFond.cCodeTypeAppel)
            then do:
                find first ttListeSuiviFinancierTravaux
                    where ttListeSuiviFinancierTravaux.iCodeFournisseur = - integer(ttEnteteAppelDeFond.cCodeTypeAppel) no-error.
                if not available ttListeSuiviFinancierTravaux
                then do:
                    create ttListeSuiviFinancierTravaux.
                    assign
                        ttListeSuiviFinancierTravaux.iCodeFournisseur    = - integer(ttEnteteAppelDeFond.cCodeTypeAppel)
                        ttListeSuiviFinancierTravaux.cLibelleTri         = "zzzzzzzzzzz" + ttEnteteAppelDeFond.cCodeTypeAppel + outilTraduction:getLibelleParam("TPDOS", ttEnteteAppelDeFond.cCodeTypeAppel)
                        ttListeSuiviFinancierTravaux.cNomFournisseur     = ""
                        ttListeSuiviFinancierTravaux.cCodeTypeTravaux    = ttEnteteAppelDeFond.cCodeTypeAppel
                        ttListeSuiviFinancierTravaux.cLibelleTypeTravaux = outilTraduction:getLibelleParam("TPDOS", ttEnteteAppelDeFond.cCodeTypeAppel)
                    .
                end.
                if lookup(ttEnteteAppelDeFond.cCodeTypeAppel, gcEmpruntSubventionAssurance) = 0
                then if vdTotalProvision <> 0
                     then assign
                        /** Appels émis **/
                        vdAppelEmis                                      = round((vdTotalEmprunt / vdTotalProvision) * vdMontantAppel, 2)
                        vdCumulVente                                     = vdCumulVente + vdAppelEmis
                        ttListeSuiviFinancierTravaux.dMontantAppelEmis   = vdMontantAppel - vdAppelEmis
                        /** Appels reconstitués **/
                        vdAppelEmis                                      = round((vdTotalEmprunt / vdTotalProvision) * vdMontantAppelMan, 2)
                        vdCumulVente                                     = vdCumulVente + vdAppelEmis
                        ttListeSuiviFinancierTravaux.dMontantAppelManuel = vdMontantAppelMan - vdAppelEmis
                     .
                     else assign
                        ttListeSuiviFinancierTravaux.dMontantAppelEmis   = vdMontantAppel
                        ttListeSuiviFinancierTravaux.dMontantAppelManuel = vdMontantAppelMan
                     .
                else assign
                    ttListeSuiviFinancierTravaux.dMontantAppelEmis     = - vdMontantAppel
                    ttListeSuiviFinancierTravaux.dMontantAppelManuel   = - vdMontantAppelMan
                .
                vdTotalVente = vdTotalVente + ttListeSuiviFinancierTravaux.dMontantAppelEmis + ttListeSuiviFinancierTravaux.dMontantAppelManuel. /** 0306/0215 **/
            end.
        end. /** FOR EACH ttEnteteAppelDeFond NO-LOCK **/
        /** 0306/0215 arrondi sur le plus montant le plus élevé **/
        if vdTotalVente - vdTotalProvision <> 0
        then for each ttListeSuiviFinancierTravaux
            where ttListeSuiviFinancierTravaux.iCodeFournisseur > 0
              and ttListeSuiviFinancierTravaux.dMontantAppelEmis > 0
            by ttListeSuiviFinancierTravaux.dMontantAppelEmis descending:
            assign
                ttListeSuiviFinancierTravaux.dMontantAppelEmis = ttListeSuiviFinancierTravaux.dMontantAppelEmis - (vdTotalVente - vdTotalProvision)
                vdCumulVente                                   = vdCumulVente + (vdTotalVente - vdTotalProvision)
                vdTotalVente                                   = vdTotalVente - (vdTotalVente - vdTotalProvision)
            .
            {&_proparse_ prolint-nowarn(blocklabel)}
            leave.
        end.
        if vdCumulVente - vdTotalEmprunt <> 0
        then for first ttListeSuiviFinancierTravaux    /* dernier type d'appel hors emprunt */
            where ttListeSuiviFinancierTravaux.iCodeFournisseur >= -8
              and ttListeSuiviFinancierTravaux.iCodeFournisseur <= -6:
            assign
                ttListeSuiviFinancierTravaux.dMontantAppelEmis = ttListeSuiviFinancierTravaux.dMontantAppelEmis - (vdTotalEmprunt - vdCumulVente)
                vdCumulVente                                   = vdCumulVente + (vdTotalEmprunt - vdCumulVente)
            .
        end.
        /*-------------------------------------------------------------------------------------------------------------
                                              TOTAL DES APPELS
        ---------------------------------------------------------------------------------------------------------------*/
        /*--> Total Appelé */ /* exclusion emprunt, subvention, indemnité - RF 30/07/08              */
        /*--  les types fond de roulement/reserve ne sont pas exclu parce qu'ils ne peuvent exister! */
        vdMontantAppel = 0.
        for each ttListeSuiviFinancierTravaux
            where lookup(ttListeSuiviFinancierTravaux.cCodeTypeTravaux, gcEmpruntSubventionAssurance) = 0:
            vdMontantAppel = vdMontantAppel + ttListeSuiviFinancierTravaux.dMontantAppelEmis
                           + ttListeSuiviFinancierTravaux.dMontantAppelManuel.
        end.
        for each ttListeSuiviFinancierTravaux
            where lookup(ttListeSuiviFinancierTravaux.cCodeTypeTravaux, gcEmpruntSubventionAssurance) = 0:
            ttListeSuiviFinancierTravaux.dMontantTotalAppel = vdMontantAppel.
        end.
    end. /* dossier non cloturé */

    /*  --> Montant reglé par fournisseur */
    run travaux/dossierTravaux/GI_dostrav.p (
         integer(if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance),
         2,
         piNumeroMandat,
         piNumeroDossierTravaux,
         ?,
         pcTypeMandat,
         trdos.tpurg,
         input-output table ttListeSuiviFinancierClient  by-reference,
         input-output table ttDetailSuiviFinancierClient by-reference,
         input-output table ttListeEcriture              by-reference,
         input-output table ttDetailAppelTravauxParLot   by-reference,
         input-output table ttListeSuiviFinancierTravaux by-reference,
         output viErreur).
    /*-----------------------------------------------------------------------
                    SI LE DOSSIER EST CLOTURE
            ttListeSuiviFinancierTravaux.dMontantAppel : duplication des factures
            1. emprunt, subvention, indemnités              : 6,7,8
            2. Travaux, Architecte, Dom.Ouvrage, Honoraire  : 1,3,4,5
    -----------------------------------------------------------------------*/
    /* 0306/0215 - dossier cloturé */
    /* Duplication des montants des factures par type dans la colonne appel           */
    /* Le montants sont prorates si il y a des lignes d'Emprunt/subvention/indemnités */
    if trdos.dtree <> ?
    then do:
        /* Mais d'abord création des lignes classiques d'emprunt/subvention/indemnités  */
        for each ttEnteteAppelDeFond
            where lookup(ttEnteteAppelDeFond.cCodeTypeAppel, gcEmpruntSubventionAssurance) > 0
            break by ttEnteteAppelDeFond.cCodeTypeAppel:
            /*--> Initialisation des cumuls */
            if first-of(ttEnteteAppelDeFond.cCodeTypeAppel) then vdMontantAppel = 0.
            /*--> Cumul */
            for each ttAppelDeFond
                where ttAppelDeFond.lFlagEmis
                  and ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
                vdMontantAppel = vdMontantAppel + ttAppelDeFond.dMontantAppel.
            end.
            /*--> Creation du suivi */
            if last-of(ttEnteteAppelDeFond.cCodeTypeAppel)
            then do:
                find first ttListeSuiviFinancierTravaux
                    where ttListeSuiviFinancierTravaux.iCodeFournisseur  = - integer(ttEnteteAppelDeFond.cCodeTypeAppel) no-error.
                if not available ttListeSuiviFinancierTravaux
                then do:
                    create ttListeSuiviFinancierTravaux.
                    assign
                        ttListeSuiviFinancierTravaux.iCodeFournisseur    = - integer(ttEnteteAppelDeFond.cCodeTypeAppel)
                        ttListeSuiviFinancierTravaux.cLibelleTri         = "zzzzzzzzzzz" + ttEnteteAppelDeFond.cCodeTypeAppel + outilTraduction:getLibelleParam("TPDOS",ttEnteteAppelDeFond.cCodeTypeAppel)
                        ttListeSuiviFinancierTravaux.cNomFournisseur     = ""
                        ttListeSuiviFinancierTravaux.cCodeTypeTravaux    = ttEnteteAppelDeFond.cCodeTypeAppel
                        ttListeSuiviFinancierTravaux.cLibelleTypeTravaux = outilTraduction:getLibelleParam("TPDOS", ttEnteteAppelDeFond.cCodeTypeAppel)
                    .
                end.
                ttListeSuiviFinancierTravaux.dMontantAppelEmis = - vdMontantAppel.
            end.
        end.
        /* Ensuite on gère la duplication de la colonne facture dans la colonne appel   */
        /* Calcul total des factures                                                    */
        /* Travaux , Architecte, Dom. Ouvrage, Honoraire                                */
        for each ttListeSuiviFinancierTravaux
           where ttListeSuiviFinancierTravaux.iCodeFournisseur >= 0
              and lookup(ttListeSuiviFinancierTravaux.cCodeTypeTravaux, gcTravauxArchitecteDommageHonoraire) > 0:
            assign
                ttListeSuiviFinancierTravaux.dMontantAppelEmis = ttListeSuiviFinancierTravaux.dMontantFacture
                vdMontantFacture                               = vdMontantFacture + ttListeSuiviFinancierTravaux.dMontantFacture
            .
        end.
        /* application des proratas */
        vdTotalAppelEmis = 0.
        for each ttListeSuiviFinancierTravaux
           where ttListeSuiviFinancierTravaux.iCodeFournisseur >= 0
              and lookup(ttListeSuiviFinancierTravaux.cCodeTypeTravaux, gcTravauxArchitecteDommageHonoraire) > 0:
           assign
               ttListeSuiviFinancierTravaux.dMontantAppelEmis = round(ttListeSuiviFinancierTravaux.dMontantAppelEmis * (1 - vdTotalEmprunt / vdMontantFacture), 2)
               vdTotalAppelEmis                               = vdTotalAppelEmis + ttListeSuiviFinancierTravaux.dMontantAppelEmis
           .
        end.
        /* gestion de l'arrondi */
        if vdMontantFacture - vdTotalAppelEmis <> 0
        then for last ttListeSuiviFinancierTravaux
            where ttListeSuiviFinancierTravaux.iCodeFournisseur >= 0
              and lookup(ttListeSuiviFinancierTravaux.cCodeTypeTravaux, gcTravauxArchitecteDommageHonoraire) > 0:
            ttListeSuiviFinancierTravaux.dMontantAppelEmis = ttListeSuiviFinancierTravaux.dMontantAppelEmis + (vdMontantFacture - vdTotalAppelEmis).
        end.
        /*--> Total Appelé */ /* exclusion emprunt, subvention, indemnité - RF 30/07/08              */
        /*--  les types fond de roulement/reserve ne sont pas exclu parce qu'ils ne peuvent exister! */
        vdMontantAppel = 0.
        for each ttListeSuiviFinancierTravaux
            where lookup(ttListeSuiviFinancierTravaux.cCodeTypeTravaux, gcEmpruntSubventionAssurance) = 0:
            vdMontantAppel = vdMontantAppel + ttListeSuiviFinancierTravaux.dMontantAppelEmis.
        end.
        for each ttListeSuiviFinancierTravaux
            where lookup(ttListeSuiviFinancierTravaux.cCodeTypeTravaux, gcEmpruntSubventionAssurance) = 0:
            ttListeSuiviFinancierTravaux.dMontantTotalAppel = vdMontantAppel.
        end.
    end. /* Appels dossier cloture */
    /*--> Total Montant encaissé emprunt subvention indemnité   */
    vdMontantEncaisse = 0.
    for each ttListeSuiviFinancierClient
        where ttListeSuiviFinancierClient.iNumeroCoproprietaire < 0
          and ttListeSuiviFinancierClient.dMontantEncaissement <> 0:
        find first ttListeSuiviFinancierTravaux
            where ttListeSuiviFinancierTravaux.iCodeFournisseur = ttListeSuiviFinancierClient.iNumeroCoproprietaire no-error.
        if not available ttListeSuiviFinancierTravaux
        then do:
            create ttListeSuiviFinancierTravaux.
            assign
                ttListeSuiviFinancierTravaux.iCodeFournisseur = ttListeSuiviFinancierClient.iNumeroCoproprietaire
                ttListeSuiviFinancierTravaux.cLibelleTri      = substitute("zzzzzzzzzzz&1&2"
                                                                   , string(- ttListeSuiviFinancierClient.iNumeroCoproprietaire, "99999")
                                                                   , outilTraduction:getLibelleParam("TPDOS", string(- ttListeSuiviFinancierClient.iNumeroCoproprietaire, "99999")))
                ttListeSuiviFinancierTravaux.cNomFournisseur  = ""
            .
        end.
        ttListeSuiviFinancierTravaux.dMontantEncaissement = - ttListeSuiviFinancierClient.dMontantEncaissement.
        delete ttListeSuiviFinancierClient.
    end. /* ttListeSuiviFinancierClient */

    vdTotalAppel = 0.
    for each ttListeSuiviFinancierClient:
        assign
            vdMontantEncaisse = vdMontantEncaisse + ttListeSuiviFinancierClient.dMontantEncaissementLettre   /* Lettré seulement */
            vdTotalAppel      = vdTotalAppel + ttListeSuiviFinancierClient.dMontantTotalAppele
        .
    end.
    vdTotalAppel = vdTotalAppel + vdMontantAppel.
    /* RF - 0306/0215 - répartition au prorata des montants lettrés seulement */
    if vdMontantAppel <> 0
    then for each ttListeSuiviFinancierTravaux        /* Ajout de la ligne provision */
        where ttListeSuiviFinancierTravaux.iCodeFournisseur < -8
           or ttListeSuiviFinancierTravaux.iCodeFournisseur > -6: /* sauf ligne emprunt/subv/indemn */
        ttListeSuiviFinancierTravaux.dMontantEncaissement = round((ttListeSuiviFinancierTravaux.dMontantAppelEmis + ttListeSuiviFinancierTravaux.dMontantAppelManuel) * vdMontantEncaisse / vdMontantAppel,2).
    end.

    vdMontantEncaisse = 0.
    for each ttListeSuiviFinancierClient:
        vdMontantEncaisse = vdMontantEncaisse - ttListeSuiviFinancierClient.dMontantEncaissement - ttListeSuiviFinancierClient.dMontantEncaissementLettre.  /* le sens de ttListeSuiviFinancierClient.dMontantEncaissement est inversé */
    end.

    /* RF - 0306/0215 - ajout des encaissements non lettrés à la ligne "provision" */
    if vdMontantEncaisse <> 0
    then do:
        find first ttListeSuiviFinancierTravaux
            where ttListeSuiviFinancierTravaux.iCodeFournisseur = -2 no-error.
        if not available ttListeSuiviFinancierTravaux
        then do:
            create ttListeSuiviFinancierTravaux.
            assign
                ttListeSuiviFinancierTravaux.iCodeFournisseur    = -2
                ttListeSuiviFinancierTravaux.cLibelleTri         = substitute("zzzzzzzzzzz&1&2", {&TYPEAPPEL2FONDS-provision}, outilTraduction:getLibelleParam("TPDOS", {&TYPEAPPEL2FONDS-provision}))
                ttListeSuiviFinancierTravaux.cNomFournisseur     = ""
                ttListeSuiviFinancierTravaux.cCodeTypeTravaux    = {&TYPEAPPEL2FONDS-provision}
                ttListeSuiviFinancierTravaux.cLibelleTypeTravaux = outilTraduction:getLibelleParam("TPDOS", {&TYPEAPPEL2FONDS-provision})
            .
        end.
        ttListeSuiviFinancierTravaux.dMontantEncaissement = ttListeSuiviFinancierTravaux.dMontantEncaissement + vdMontantEncaisse.
    end.
    for each ttListeSuiviFinancierTravaux:
        assign
            ttListeSuiviFinancierTravaux.dMontantResteDu     = ttListeSuiviFinancierTravaux.dMontantEncaissement - ttListeSuiviFinancierTravaux.dMontantRegle
            ttListeSuiviFinancierTravaux.cLibelleTypeTravaux = outilTraduction:getLibelleParam("TPDOS", ttListeSuiviFinancierTravaux.cCodeTypeTravaux)
        .
    end.
    /* FIN COPIER/COLLER */

    find first ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.iNumeroIdentifiant = 99999
          and ttEnteteAppelDeFond.iNumeroOrdre       = 99999
          and ttEnteteAppelDeFond.cCodeTypeAppel     = {&TYPEAPPEL2FONDS-provision}
          and ttEnteteAppelDeFond.cCodeFournisseur   = "2" no-error.
    if available ttEnteteAppelDeFond
    then do:
        find first ttAppelDeFond
            where ttAppelDeFond.iNumeroAppel = ttEnteteAppelDeFond.iNumeroIdentifiant
              and ttAppelDeFond.lFlagEmis = true no-error.
        if available ttAppelDeFond then delete ttAppelDeFond.
        delete ttEnteteAppelDeFond.
    end.
    run destroy in vhProcTVA.

end procedure.
