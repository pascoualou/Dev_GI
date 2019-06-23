/*------------------------------------------------------------------------
File        : repartitionAV.p
Purpose     :
Author(s)   : gga  -  2017/03/07
Notes       : extrait programme visdoach.p
Tables      :
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

/* todo a voir pour ajout dans include */
&SCOPED-DEFINE NATCONTRAT-forfait       "00001"
&SCOPED-DEFINE MTHARRONDI-tronque       "00001"
&SCOPED-DEFINE MTHARRONDI-arrondi       "00001"
&SCOPED-DEFINE TYPARRONDI-centime       "00001"
&SCOPED-DEFINE TYPARRONDI-unite         "00002"
&SCOPED-DEFINE TYPARRONDI-dizaine       "00003"
&SCOPED-DEFINE TYPARRONDI-centaine      "00004"
&SCOPED-DEFINE TYPARRONDI-millier       "00005"
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/typeAppel.i}

{application/include/error.i}
{application/include/glbsepar.i}
{travaux/include/dossierTravaux.i}
{travaux/include/appelDefond.i}
{travaux/include/repartitionAV.i}
{travaux/include/editionAno.i}
{compta/include/TbTmpAna.i}
{application/include/combo.i}

define temp-table ttImmCle no-undo
    field nolot as integer
    field cdcle as character
    field nbpar as decimal
    field nbtot as decimal
    index primaire noLot cdCle
.
define variable giNumeroItem as integer no-undo.

function createttCombo returns logical (pcNom as character, pcCode as character, pcLibelle as character):
/*------------------------------------------------------------------------------
Purpose: todo a voir si possibilite appel car function deja existante
Notes  :
------------------------------------------------------------------------------*/
    create ttCombo.
    assign
        giNumeroItem      = giNumeroItem + 1
        ttcombo.iSeqId    = giNumeroItem
        ttCombo.cNomCombo = pcNom
        ttCombo.cCode     = pcCode
        ttCombo.cLibelle  = pcLibelle
    .
end function.

function inte2Date return date(piDate as integer):
    /*------------------------------------------------------------------------------
    Purpose: todo a voir gestion des dates
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdaRetour as date      no-undo.

    vdaRetour = date(truncate(piDate / 100, 0) modulo 100, piDate modulo 100, integer(truncate(piDate / 10000, 0))) no-error.
    error-status:error = false no-error.
    return vdaRetour.

end function.

procedure getRepartitionAV:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : appel service exterieur (beRepartition.cls, dossiertravaux.p)
    ------------------------------------------------------------------------------*/
    define input        parameter poCollection as collection no-undo.
    define input-output parameter table for ttDossierTravaux.
    define output       parameter table for ttRepartitionAV.
    define output       parameter table for ttInfSelRepartitionAV.
    define output       parameter table for ttCombo.

    define variable vcTypeMandat           as character no-undo.
    define variable viNumeroMandat         as integer   no-undo.
    define variable viNumeroDossierTravaux as integer   no-undo.
    define variable viNumeroImmeuble       as integer   no-undo.
    define variable viNoLotDis             as integer   no-undo.
    define variable vlFgRepLot             as logical   no-undo.
    define variable viNoColDis             as integer   no-undo initial 52.
    define variable viNoAppEmi             as integer   no-undo.
    define variable vdTTRepLot             as decimal   no-undo.
    define variable vdaAchLot              as date      no-undo.
    define variable vdaVenLot              as date      no-undo.
    define variable vdMtEmiApp             as decimal   no-undo.
    define variable vdTotRegule            as decimal   no-undo.
    define variable vhProc                 as handle    no-undo.
    define variable viCpUseInc             as integer   no-undo.
    define variable viActifLotArrondi      as integer   no-undo.
    define variable vdMtArrondi            as decimal   no-undo.

    define buffer dosap for dosap.
    define buffer trdos for trdos.
    define buffer intnt for intnt.
    define buffer local for local.
    define buffer dosrp for dosrp.
    define buffer apbco for apbco.
    define buffer clemi for clemi.
    define buffer milli for milli.
    define buffer vbttRepartitionAV for ttRepartitionAV.

    assign
        vcTypeMandat           = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        viNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        viNumeroImmeuble       = poCollection:getInteger("iNumeroImmeuble")
    .

message "getRepartitionAV"
        " vcTypeMandat " vcTypeMandat
        " viNumeroMandat " viNumeroMandat
        " viNumeroDossierTravaux " viNumeroDossierTravaux
        " viNumeroImmeuble " viNumeroImmeuble.

    empty temp-table ttRepartitionAV.
    /* si table ttDossierTravaux n'est pas presente a l'appel de cette procedure, alors appel pour la charger */
    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then do:
        run travaux/dossierTravaux/dossierTravaux.p persistent set vhProc.
        run getTokenInstance  in vhproc(mToken:JSessionId).
        run getDossierTravaux in vhProc(poCollection, output table ttDossierTravaux by-reference).
        run destroy in vhproc.
        find first ttDossierTravaux no-error.
        if not available ttDossierTravaux
        then do:
            /* chargement dossier travaux impossible */
            mError:createError({&error}, 4000054).
            return.
        end.
    end.

    /* appel procedure chargement des tables de travail dossier travaux (utilise dans procedure creation
    table repartition et calcul */ /* todo a voir si il ne vaut mieux pas un dataset plus complet avec toutes les tables */
    run travaux/dossierTravaux/appelDeFond.p persistent set vhProc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run getAppelDeFond   in vhProc(poCollection,
                                   output table ttEnteteAppelDeFond  by-reference,
                                   output table ttAppelDeFond        by-reference,
                                   output table ttAppelDeFondRepCle  by-reference,
                                   output table ttAppelDeFondRepMat  by-reference,
                                   output table ttDossierAppelDeFond by-reference).
    run destroy in vhproc.
    /*--> Recherche du dernier appel emis */
    for last dosap no-lock
        where dosap.tpCon = vcTypeMandat
          and dosap.noCon = viNumeroMandat
          and dosap.noDos = viNumeroDossierTravaux
          and dosap.fgEmi:
        viNoAppEmi = dosap.Noapp.
    end.
    /** Modif Sy le 17/04/2007 - 0407/0148: on ne peut pas trier par copropriétaire sinon on perd l'ordre des achats */
    for each intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-titre2copro}
          and intnt.nocon >= viNumeroMandat * 100000
          and intnt.nocon <= viNumeroMandat * 100000 + 99999
          and intnt.tpidt = {&TYPEBIEN-lot}
      , first local
        fields (local.noloc local.nolot local.cdbat)  no-lock
        where local.noloc = intnt.noidt
        break by intnt.tpidt
              by intnt.noidt
              by intnt.nbnum:

        /*--> Initialisation de la repartition */
        if first-of(intnt.noidt) then assign
            vlFgRepLot = false
            vdTTRepLot = 0
        .
        find first ttRepartitionAV
            where ttRepartitionAV.iNoLot = Local.nolot
              and ttRepartitionAV.iNoCop = intnt.nocon modulo 100000 no-error. // integer(substring(string(intnt.nocon, "999999999"), 5, 5, 'character'))
        if not available ttRepartitionAV
        then do:
            /*--> Creation de la ligne de repartition */
            create ttRepartitionAV.
            assign
                ttRepartitionAV.iNoLot = Local.nolot
                ttRepartitionAV.cCdBat = if local.cdbat > "" then local.cdbat else "*"
                ttRepartitionAV.iNoCop = intnt.nocon modulo 100000    // integer(substring(string(intnt.nocon, "999999999"), 5, 5, 'character'))
                ttRepartitionAV.CRUD   = "R"
                ttRepartitionAV.cNmCop = outilFormatage:getNomTiers({&TYPEROLE-coproprietaire}, ttRepartitionAV.iNoCop)
            .
            /*--> 1) Chargement de la repartition stockée pour le lot */
            for first dosrp no-lock
                where dosrp.TpCon = vcTypeMandat
                  and dosrp.NoCon = viNumeroMandat
                  and dosrp.NoDos = viNumeroDossierTravaux
                  and dosrp.NoLot = local.nolot
                  and dosrp.NoCop = ttRepartitionAV.iNoCop:
                assign
                    ttRepartitionAV.iPoLot = dosrp.PoRep
                    vlFgRepLot             = true
                .
                do viCpUseInc = 1 to viNoAppEmi:
                    run montantEmisAppelTravaux(vcTypeMandat,
                                   viNumeroMandat,
                                   viNumeroDossierTravaux,
                                   viCpUseInc,
                                   dosrp.NoCop,
                                   dosrp.NoLot,
                                   output vdMtEmiApp).
                    ttRepartitionAV.dMtEmi = ttRepartitionAV.dMtEmi + vdMtEmiApp.
                end.
            end.
        end. /* if not available ttRepartitionAV */

        /* todo pour l'instant mis la fonction dans le pgm */
        assign
            vdaAchLot               = inte2Date(intnt.nbnum)
            vdaVenLot               = inte2Date(intnt.nbden)
            ttRepartitionAV.cTpLot  = if intnt.nbden = 0 then "A" else "V"
            ttRepartitionAV.dtDtLot = if intnt.nbden = 0 then vdaAchLot else vdaVenLot
        .
        /*--> 2) Init si pas de valeur stockée **/
        /*IF (vdaAchLot <= TbTmpDos.DtSig AND (vdaVenLot = ? OR vdaVenLot <> ? AND vdaVenLot > TbTmpDos.DtSig)) AND NOT vlFgRepLot THEN*/
        /*IF (vdaAchLot <= TbTmpDos.DtDeb AND (vdaVenLot = ? OR vdaVenLot <> ? AND vdaVenLot > TbTmpDos.DtDeb)) AND NOT vlFgRepLot THEN*/
        if not vlFgRepLot then ttRepartitionAV.iPoLot = 0.

        if last-of(intnt.noidt)
        then do:
            if not vlFgRepLot then ttRepartitionAV.iPoLot = 100.
            /* Ajout SY le 06/09/2005 : calcul de l'écart */
            for each vbttRepartitionAV
                where vbttRepartitionAV.iNoLot = local.NoLot:
                assign
                    vdTTRepLot             = vdTTRepLot + vbttRepartitionAV.iPoLot
                    ttRepartitionAV.dEcLot = 100 - vdTTRepLot
                .
            end.
        end.
    end. /*for each intnt */

    /** 0909/0014 Gestion des régule pour les vieux appels de fonds **/
    if can-find(first apbco no-lock
                where apbco.tpbud     = {&TYPEBUDGET-travaux}
                  and apbco.nobud     = viNumeroMandat * 100000 + viNumeroDossierTravaux    // integer(string(viNumeroMandat) + string(viNumeroDossierTravaux, "99999"))
                  and apbco.tpapp     = {&TYPEAPPEL-dossierTravaux} /* "TX" */
                  and apbco.nomdt     = viNumeroMandat
                  and apbco.nolot     = 0
                  and apbco.typapptrx = ""
                  and apbco.cdcle     = ""
                  and apbco.cdcsy matches "*apatcx.p*")
    then do:
        /**Ajout du test pour optimisation par OF le 04/03/13**/
        for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-titre2copro}
              and intnt.nocon >= viNumeroMandat * 100000         // integer(string(viNumeroMandat) + "00000")
              and intnt.nocon <= viNumeroMandat * 100000 + 99999 // integer(string(viNumeroMandat) + "99999")
              and intnt.tpidt = {&TYPEBIEN-lot}
          , first local
            fields (local.noloc) no-lock
            where local.noloc = intnt.noidt
               by intnt.tpidt by intnt.noidt by intnt.nbnum:
            vdTotRegule = 0.
            find first ttRepartitionAV
                where ttRepartitionAV.iNoLot = 0
                  and ttRepartitionAV.iNoCop = intnt.nocon modulo 100000 no-error. // integer(substring(string(intnt.nocon, "999999999"), 5, 5, 'character')) 
            if not available ttRepartitionAV
            then do:
                do viCpUseInc = 1 to viNoAppEmi:
                    for each apbco
                        fields (apbco.mtlot) no-lock
                        where apbco.tpbud = {&TYPEBUDGET-travaux} /* "01080" */
                          and apbco.nobud = viNumeroMandat * 100000 + viNumeroDossierTravaux // integer(string(viNumeroMandat) + string(viNumeroDossierTravaux, "99999"))
                          and apbco.tpapp = {&TYPEAPPEL-dossierTravaux} /* "TX" */
                          and apbco.noapp = viCpUseInc
                          and apbco.nomdt = viNumeroMandat
                          and apbco.nocop = intnt.nocon modulo 100000 // integer(substring(string(intnt.nocon, "999999999"), 5, 5, 'character'))
                          and apbco.nolot = 0
                          and apbco.typapptrx = ""
                          and apbco.cdcle = ""
                          and apbco.cdcsy matches "*apatcx.p*":
                        vdTotRegule = vdTotRegule + apbco.mtlot.
                    end.
                end.
                if vdTotRegule <> 0
                then do:
                    /*--> Creation de la ligne de repartition */
                    create ttRepartitionAV.
                    assign
                        ttRepartitionAV.iNoLot  = 0
                        ttRepartitionAV.cCdBat  = ""
                        ttRepartitionAV.iNoCop  = intnt.nocon modulo 100000  // integer(substring(string(intnt.nocon, "999999999"), 5, 5, 'character'))
                        ttRepartitionAV.iPoLot  = 0
                        ttRepartitionAV.cTpLot  = "A"
                        ttRepartitionAV.dtDtLot = ?
                        ttRepartitionAV.dMtEmi  = vdTotRegule
                        ttRepartitionAV.cNmCop  = outilFormatage:getNomTiers({&TYPEROLE-coproprietaire}, ttRepartitionAV.iNoCop)
                    .
                end.
            end.
        end. /** for each intnt **/
    end. /** if can-find(first apbco **/

    /*--> Si dossier au forfait : repartition via les factures */
    if ttDossierTravaux.cCdNat = {&NATCONTRAT-forfait}
    then do:
        run chargement-tmpana(poCollection).
        for each tmp-ana
          , first clemi no-lock
            where clemi.noimm = viNumeroImmeuble
              and clemi.cdcle = tmp-ana.cle
          , each milli no-lock
            where milli.noimm = viNumeroImmeuble
              and milli.cdcle = clemi.cdcle
          , each ttRepartitionAV
            where ttRepartitionAV.iNoLot = milli.nolot:
            ttRepartitionAV.dMtApp = ttRepartitionAV.dMtApp + ((tmp-ana.mt * milli.nbpar / clemi.nbtot) * ttRepartitionAV.iPoLot) / 100.
        end.
        /*--> Affecter le lot de l'arrondi si non existant */
        if ttDossierTravaux.iLoRep = 0
        then for each ttRepartitionAV 
            where ttRepartitionAV.dMtApp > 0
               by ttRepartitionAV.dMtApp descending:    // on recherche le plus grand montant !!!! ????
            for first trdos exclusive-lock
                where trdos.nocon = viNumeroMandat
                  and trdos.nodos = viNumeroDossierTravaux:
                trdos.lorep = ttRepartitionAV.iNoLot.
            end.
            {&_proparse_ prolint-nowarn(blocklabel)}
            leave.
        end.
    end.

    for each ttRepartitionAV:
        if viNoLotDis <> ttRepartitionAV.inolot
        then assign
            viNoLotDis = ttRepartitionAV.inolot
            viNoColDis = if viNoColDis = 51 then 52 else 51
        .
        ttRepartitionAV.iNoCol = viNoColDis.
    end. /* for each ttRepartitionAV */
    run chargeCleImmeuble(buffer ttDossierTravaux).
    for each vbttRepartitionAV
        break by vbttRepartitionAV.iNoLot:
        if first-of(vbttRepartitionAV.iNoLot) then createttCombo('LOT', string(vbttRepartitionAV.iNoLot), '').

        run calculAppel (buffer ttDossierTravaux, buffer vbttRepartitionAV).
    end.

    if ttDossierTravaux.iLoRep <> 0
    then viActifLotArrondi = ttDossierTravaux.iLoRep.
    else for first ttEnteteAppelDeFond
      , each ttRepartitionAV 
          by ttRepartitionAV.dMtApp descending:    // on recherche le plus grand montant !!!! ????
        assign
            viActifLotArrondi       = ttRepartitionAV.iNoLot
            ttDossierTravaux.iLoRep = ttRepartitionAV.iNoLot /* NP 0613/0177 */
        .
        {&_proparse_ prolint-nowarn(blocklabel)}
        leave.
    end.
    run calculArrondi (viActifLotArrondi, buffer ttDossierTravaux, output vdMtArrondi).
    create ttInfSelRepartitionAV.
    assign
        ttInfSelRepartitionAV.iActifLotArrondi = viActifLotArrondi
        ttInfSelRepartitionAV.dMtArrondi       = vdMtArrondi
        ttInfSelRepartitionAV.dtPresentDepuis  = ttDossierTravaux.daDateDebut
        ttInfSelRepartitionAV.CRUD             = "R"
    .
end procedure.

procedure montantEmisAppelTravaux private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de recherche du montant émis pour un appel travaux/copro/lot
             extrait include d:/gidev/comm/aptxemi.i
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTpConUseIN as character no-undo.
    define input  parameter piNoConUseIN as integer no-undo.
    define input  parameter piNoDosUseIN as integer no-undo.
    define input  parameter piNoAppUseIN as integer no-undo.
    define input  parameter piNoCopUseIN as integer no-undo.
    define input  parameter piNoLotUseIN as integer no-undo.
    define output parameter pdMtEmiAppOU as decimal no-undo.

    define variable vlUseapbco as logical no-undo.
    define variable viNoBudUse as integer no-undo.

    define buffer dosap for dosap.
    define buffer dosrp for dosrp.
    define buffer apbco for apbco.

message "montantEmisAppelTravaux "
        " pcTpConUseIN " pcTpConUseIN
        " piNoConUseIN " piNoConUseIN
        " piNoDosUseIN " piNoDosUseIN
        " piNoAppUseIN " piNoAppUseIN
        " piNoCopUseIN " piNoCopUseIN
        " piNoLotUseIN " piNoLotUseIN.

    /* si le détail appel de fonds par appel/type d'appel/cle/lot/copro (apbco) existe et est validé : on le prend */
    /* sinon on utilise dosrp.mtemi */
    viNoBudUse = piNoConUseIN * 100000 + piNoDosUseIN.  // integer(string(piNoConUseIN) + string(piNoDosUseIN, "99999")).
    for first dosap no-lock
        where dosap.TpCon = pcTpConUseIN
          and dosap.NoCon = piNoConUseIN
          and dosap.NoDos = piNoDosUseIN
          and dosap.Noapp = piNoAppUseIN:
        if dosap.ModeTrait = "M"
        then assign vlUseapbco = true when dosap.FgRepDef.
        else for first apbco no-lock
            where apbco.tpbud = {&TYPEBUDGET-travaux} /* "01080" */
              and apbco.nobud = viNoBudUse
              and apbco.tpapp = {&TYPEAPPEL-dossierTravaux} /* "TX" */
              and apbco.noapp = piNoAppUseIN
              and apbco.nomdt = piNoConUseIN
              and apbco.typapptrx <> "":
            vlUseapbco = yes.
        end.
    end.

    if vlUseapbco
    then for each apbco no-lock
        where apbco.tpbud = {&TYPEBUDGET-travaux} /* "01080" */
          and apbco.nobud = viNoBudUse
          and apbco.tpapp = {&TYPEAPPEL-dossierTravaux} /* "TX" */
          and apbco.noapp = piNoAppUseIN
          and apbco.nomdt = piNoConUseIN
          and apbco.nocop = piNoCopUseIN
          and apbco.nolot = piNoLotUseIN:
        pdMtEmiAppOU = pdMtEmiAppOU + apbco.mtlot.
    end.
    else for first dosrp no-lock
        where dosrp.tpCon = pcTpConUseIN
          and dosrp.noCon = piNoConUseIN
          and dosrp.noDos = piNoDosUseIN
          and dosrp.noLot = piNoLotUseIN
          and dosrp.noCop = piNoCopUseIN
          and num-entries(dosrp.MtEmi, separ[1]) >= piNoAppUseIN:
        pdMtEmiAppOU = decimal(entry(piNoAppUseIN, dosrp.MtEmi, separ[1])).
    end.

end procedure.

procedure CalculArrondi private:
    /*------------------------------------------------------------------------------
    Purpose: extrait pgm D:\gidev\adb\src\trav\visdoach.p
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piActifLotArrondi as integer no-undo.
    define parameter buffer pbttDossierTravaux for ttDossierTravaux.
    define output parameter pdMtArrondi as decimal no-undo.

message " CalculArrondi "
        " piActifLotArrondi " piActifLotArrondi
        " ttDossierTravaux.cCodeTypeMandat " pbttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " pbttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " pbttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " pbttDossierTravaux.iNumeroImmeuble.

    define variable vdMtAppArr as decimal no-undo.
    define variable vdMtAppTot as decimal no-undo.

    define buffer dosap for dosap.

    /*--> Dossier au Forfait */
    if pbttDossierTravaux.cCdNat = {&NATCONTRAT-forfait}
    then do:
        for each tmp-ana:
            vdMtAppTot = vdMtAppTot + tmp-ana.mt.
        end.
        for each ttRepartitionAV:
            vdMtAppArr = vdMtAppArr + ttRepartitionAV.dMtApp.
        end.
        pdMtArrondi = vdMtAppTot - vdMtAppArr.
        for first ttRepartitionAV
            where ttRepartitionAV.iNoLot = piActifLotArrondi
              and ttRepartitionAV.iPoLot <> 0:
            ttRepartitionAV.dMtApp = ttRepartitionAV.dMtApp + vdMtAppTot - vdMtAppArr.
        end.
    end.
    else for first dosap no-lock     /*--> Dossier Normal */
        where dosap.TpCon = pbttDossierTravaux.cCodeTypeMandat
          and dosap.NoCon = pbttDossierTravaux.iNumeroMandat
          and dosap.NoDos = pbttDossierTravaux.iNumeroDossierTravaux
          and dosap.FgEmi = no:
        for each ttRepartitionAV:
            vdMtAppArr = vdMtAppArr + ttRepartitionAV.dMtApp.
        end.
        pdMtArrondi = dosap.MtTot - vdMtAppArr.
        for first ttRepartitionAV
            where ttRepartitionAV.iNoLot = piActifLotArrondi
              and ttRepartitionAV.iPoLot <> 0:
            ttRepartitionAV.dMtApp = ttRepartitionAV.dMtApp + dosap.MtTot - vdMtAppArr.
        end.
    end.

end procedure.

procedure chargeCleImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose: extrait pgm D:\gidev\adb\src\trav\visdoach.p
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer pbttDossierTravaux for ttDossierTravaux.

message " chargeCleImmeuble "
        " ttDossierTravaux.cCodeTypeMandat " pbttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " pbttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " pbttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " pbttDossierTravaux.iNumeroImmeuble.

    define buffer dosap for dosap.
    define buffer clemi for clemi.
    define buffer milli for milli.

    empty temp-table ttImmCle.
    for first dosap no-lock
        where dosap.TpCon = pbttDossierTravaux.cCodeTypeMandat
          and dosap.NoCon = pbttDossierTravaux.iNumeroMandat
          and dosap.NoDos = pbttDossierTravaux.iNumeroDossierTravaux
          and dosap.FgEmi = no:
        for each ttEnteteAppelDeFond
          , each ttAppelDeFondRepCle
            where ttAppelDeFondRepCle.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
              and ttAppelDeFondRepCle.iNumeroAppel       = dosap.NoApp
            break by ttAppelDeFondRepCle.cCodeCle:

            if first-of(ttAppelDeFondRepCle.cCodeCle)
            then for first clemi no-lock
                where clemi.noimm = integer(pbttDossierTravaux.iNumeroImmeuble)
                  and clemi.cdcle = ttAppelDeFondRepCle.cCodeCle
              , each milli no-lock
                where milli.noimm = clemi.noimm
                  and milli.cdcle = ttAppelDeFondRepCle.cCodeCle
                  and milli.norep = clemi.norep:
                create ttImmCle.
                assign
                    ttImmCle.nolot = milli.nolot
                    ttImmCle.cdcle = milli.cdcle
                    ttImmCle.nbpar = milli.nbpar
                    ttImmCle.nbtot = clemi.nbtot
                .
            end.
        end.
    end.

end procedure.

procedure CalculAppel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : extrait pgm D:\gidev\adb\src\trav\visdoach.p
    ------------------------------------------------------------------------------*/
    define parameter buffer pbttDossierTravaux for ttDossierTravaux.
    define parameter buffer pbttRepartitionAV for ttRepartitionAV.

    define variable vdMtAppArr as decimal no-undo.

    define buffer clemi for clemi.
    define buffer milli for milli.
    define buffer dosap for dosap.

message " CalculAppel "
        " ttDossierTravaux.cCodeTypeMandat " pbttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " pbttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " pbttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravaux.iNumeroImmeuble " pbttDossierTravaux.iNumeroImmeuble.

    /*--> Montant de l'appel à zero */
    pbttRepartitionAV.dMtApp = 0.
    /*--> Dossier au forfait */
    if pbttDossierTravaux.cCdNat = {&NATCONTRAT-forfait}
    then for each tmp-ana
      , first clemi no-lock
        where clemi.noimm = integer(pbttDossierTravaux.iNumeroImmeuble)
          and clemi.cdcle = tmp-ana.cle
      , each milli no-lock
        where milli.noimm = clemi.noimm
          and milli.nolot = pbttRepartitionAV.iNoLot
          and milli.cdcle = clemi.cdcle:
        vdMtAppArr = ((tmp-ana.mt * milli.nbpar / clemi.nbtot) * pbttRepartitionAV.iPoLot) / 100.
        run arrondir(input-output vdMtAppArr, buffer pbttDossierTravaux).
        pbttRepartitionAV.dMtApp = pbttRepartitionAV.dMtApp + vdMtAppArr.
    end.
    else for first dosap no-lock    /*--> Dossier Normal */
        where dosap.TpCon = pbttDossierTravaux.cCodeTypeMandat
          and dosap.NoCon = pbttDossierTravaux.iNumeroMandat
          and dosap.NoDos = pbttDossierTravaux.iNumeroDossierTravaux
          and dosap.fgEmi = no
      , each ttEnteteAppelDeFond:
        /*--> Repartition par clé */
        for each ttAppelDeFondRepCle
            where ttAppelDeFondRepCle.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
              and ttAppelDeFondRepCle.iNumeroAppel = dosap.NoApp
          , first ttImmCle
            where ttImmCle.nolot = pbttRepartitionAV.iNoLot
              and ttImmCle.cdcle = ttAppelDeFondRepCle.cCodeCle:
            vdMtAppArr = ((ttAppelDeFondRepCle.dMontantAppel * ttImmCle.nbpar / ttImmCle.nbtot) * pbttRepartitionAV.iPoLot / 100).
            run arrondir(input-output vdMtAppArr, buffer pbttDossierTravaux).
            pbttRepartitionAV.dMtApp = pbttRepartitionAV.dMtApp + vdMtAppArr.
        end.
        /*--> Repartition par matricule */
        for each ttAppelDeFondRepMat
            where ttAppelDeFondRepMat.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
              and ttAppelDeFondRepMat.iNumeroAppel = dosap.NoApp
              and ttAppelDeFondRepMat.iNumeroCopro = pbttRepartitionAV.iNoCop
              and ttAppelDeFondRepMat.iNumeroLot = pbttRepartitionAV.iNoLot:
            pbttRepartitionAV.dMtApp = pbttRepartitionAV.dMtApp + ttAppelDeFondRepMat.dMontantAppel.
        end.
    end.

end procedure.

procedure Arrondir private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : extrait pgm D:\gidev\adb\src\trav\visdoach.p
    ------------------------------------------------------------------------------*/
    define input-output parameter pdMtAppArr as decimal no-undo.
    define parameter buffer pbttDossierTravaux for ttDossierTravaux.

message " Arrondir "
        " ttDossierTravaux.cCodeTypeMandat " pbttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " pbttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " pbttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " pbttDossierTravaux.iNumeroImmeuble
        " ttDossierTravaux.cTpArr " pbttDossierTravaux.cTpArr
        " ttDossierTravaux.cCdArr " pbttDossierTravaux.cCdArr.

    /* */
    case pbttDossierTravaux.cTpArr:
        when {&MTHARRONDI-tronque} then case pbttDossierTravaux.cCdArr:
            when {&TYPARRONDI-centime}  then pdMtAppArr = truncate(pdMtAppArr, 2).
            when {&TYPARRONDI-unite}    then pdMtAppArr = truncate(pdMtAppArr, 0).
            when {&TYPARRONDI-dizaine}  then pdMtAppArr = truncate(pdMtAppArr / 10, 0) * 10.
            when {&TYPARRONDI-centaine} then pdMtAppArr = truncate(pdMtAppArr / 100, 0) * 100.
            when {&TYPARRONDI-millier}  then pdMtAppArr = truncate(pdMtAppArr / 1000, 0) * 1000.
        end case.
        when {&MTHARRONDI-arrondi}
        then case pbttDossierTravaux.cCdArr:
            when {&TYPARRONDI-centime}  then pdMtAppArr = round(pdMtAppArr, 2).
            when {&TYPARRONDI-unite}    then pdMtAppArr = round(pdMtAppArr, 0).
            when {&TYPARRONDI-dizaine}  then pdMtAppArr = round(pdMtAppArr / 10, 0) * 10.
            when {&TYPARRONDI-centaine} then pdMtAppArr = round(pdMtAppArr / 100, 0) * 100.
            when {&TYPARRONDI-millier}  then pdMtAppArr = round(pdMtAppArr / 1000, 0) * 1000.
        end case.
    end case.

end procedure.

procedure validationrepartition:
    /*------------------------------------------------------------------------------
    Purpose: correspond a procedure gesdossi.p Validation pour la partie repartition
    Notes  : appel service exterieur (beRepartition.cls)
    ------------------------------------------------------------------------------*/
    define input        parameter table for ttError.
    define input-output parameter table for ttDossierTravaux.
    define input-output parameter table for ttRepartitionAV.
    define input-output parameter table for ttInfSelRepartitionAV.
    define input-output parameter table for ttCombo.
    define output       parameter table for ttEdtAno.

    define variable vlRetCtrl as logical no-undo.

message " validationrepartition ".

    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then do:
        mError:createError({&information}, 4000054).
        return.
    end.

message " validationrepartition parametres "
        " ttDossierTravaux.cCodeTypeMandat " ttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " ttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " ttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " ttDossierTravaux.iNumeroImmeuble.

    find first ttInfSelRepartitionAV no-error.
    if not available ttInfSelRepartitionAV
    then do:
        mError:createError({&information}, 4000055).
        return.
    end.
    run CtrlValidationInfoRepartition (buffer ttInfSelRepartitionAV,
                                       buffer ttDossierTravaux,
                                       table ttRepartitionAV by-reference,
                                       table ttError         by-reference,
                                       output table ttEdtAno by-reference,
                                       output vlRetCtrl).
    if vlRetCtrl then return.

    /* correspond a gesdossi/Validation pour la partie appel de fond */
    run validationInfoRepartition(buffer ttDossierTravaux,
                                  table ttRepartitionAV by-reference,
                                  output vlRetCtrl).

end procedure.

procedure ValidationInfoRepartition:
    /*------------------------------------------------------------------------------
    Purpose: correspond a procedure gesdossi.p Validation pour la partie repartition
    Notes  : appel interne ou service exterieur (dossiertravaux.p)
    ------------------------------------------------------------------------------*/
    define parameter buffer pbttDossierTravaux for ttDossierTravaux.
    define input-output parameter table for ttRepartitionAV.
    define output       parameter plValidOk as logical no-undo.

    define buffer dosrp for dosrp.

message " ValidationInfoRepartition parametres "
        " ttDossierTravaux.cCodeTypeMandat " pbttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " pbttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " pbttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " pbttDossierTravaux.iNumeroImmeuble.

    if pbttDossierTravaux.cCodeTypeMandat <> {&TYPECONTRAT-mandat2Gerance}
    then do:
        for each ttRepartitionAV
            where ttRepartitionAV.iNoLot <> 0:        /** 0909/0014 Gestion des régules pour les vieux appels de fonds **/
            {&_proparse_ prolint-nowarn(nowait)}
            find first dosrp exclusive-lock
                where dosrp.TpCon = pbttDossierTravaux.cCodeTypeMandat
                  and dosrp.NoCon = pbttDossierTravaux.iNumeroMandat
                  and dosrp.NoDos = pbttDossierTravaux.iNumeroDossierTravaux
                  and dosrp.NoLot = ttRepartitionAV.iNoLot
                  and dosrp.NoCop = ttRepartitionAV.iNoCop no-error.
            if not available dosrp
            then do:
                create dosrp.
                assign
                    dosrp.TpCon = pbttDossierTravaux.cCodeTypeMandat
                    dosrp.NoCon = pbttDossierTravaux.iNumeroMandat
                    dosrp.NoDos = pbttDossierTravaux.iNumeroDossierTravaux
                    dosrp.NoLot = ttRepartitionAV.iNoLot
                    dosrp.NoCop = ttRepartitionAV.iNoCop
                    dosrp.cdcsy = mToken:cUser
                    dosrp.dtcsy = today
                    dosrp.HeCsy = mtime
                .
            end.
            assign
                dosrp.PoRep = (if ttRepartitionAV.iPoLot <> ? then ttRepartitionAV.iPoLot else dosrp.PoRep)
                dosrp.cdmsy = mToken:cUser
                dosrp.dtmsy = today
                dosrp.Hemsy = mtime
            .
        end.
        /*--> Suppression */
        for each dosrp exclusive-lock
            where dosrp.TpCon = pbttDossierTravaux.cCodeTypeMandat
              and dosrp.NoCon = pbttDossierTravaux.iNumeroMandat
              and dosrp.NoDos = pbttDossierTravaux.iNumeroDossierTravaux
              and not can-find (first ttRepartitionAV
                                where ttRepartitionAV.iNoLot = dosrp.NoLot
                                  and ttRepartitionAV.iNoCop = dosrp.NoCop):
            delete dosrp.
        end.
    end.
    /*--> Retour bon */
    plValidOk = yes.

end procedure.

procedure CalculPrctRepartitionAV:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service extrait pgm D:\gidev\adb\src\trav\gesdossi.p
             appele si modif d'un pourcentage, du numero de lot ou repercuter arrondi
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.
    define input parameter table for ttDossierTravaux.
    define input-output parameter table for ttRepartitionAV.
    define input-output parameter table for ttInfSelRepartitionAV.

    define variable vcTypeMandat           as character no-undo.
    define variable viNumeroMandat         as integer   no-undo.
    define variable viNumeroDossierTravaux as integer   no-undo.
    define variable viTotPoLot             as integer   no-undo.
    define variable vhProc                 as handle    no-undo.
    define variable vdMtArrondi            as decimal   no-undo.

    define buffer vbttRepartitionAV for ttRepartitionAV.

    assign
        vcTypeMandat           = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        viNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
    .

message " RefreshPrctRepartitionAV "
        " vcTypeMandat " vcTypeMandat
        " viNumeroMandat " viNumeroMandat
        " viNumeroDossierTravaux " viNumeroDossierTravaux.

    /* lecture ligne de selection */
    find first ttInfSelRepartitionAV no-error.
    if not available ttInfSelRepartitionAV
    then do:
        /* table ttInfSelRepartitionAV inexistante */
        mError:createError({&error},4000055).
        return.
    end.

    /* si table ttDossierTravaux n'est pas presente a l'appel de cette procedure, alors appel pour la charger */
    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then do:
        run travaux/dossierTravaux/dossierTravaux.p persistent set vhProc.
        run getTokenInstance in vhproc(mToken:JSessionId).
        run getDossierTravaux in vhProc(vcTypeMandat,
                                        viNumeroMandat,
                                        viNumeroDossierTravaux,
                                        output table ttDossierTravaux by-reference).
        run destroy in vhproc.
        find first ttDossierTravaux no-error.
        if not available ttDossierTravaux
        then do:
            /* chargement dossier travaux impossible */
            mError:createError({&error},4000054).
            return.
        end.
    end.

    /* appel procedure chargement des tables de travail dossier travaux (utilise dans procedure creation
    table repartition et calcul */ /* todo a voir si il ne vaut mieux pas un dataset plus complet avec toutes les tables */
    run travaux/dossierTravaux/appelDeFond.p persistent set vhProc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run getAppelDeFond in vhProc (poCollection,
                                  output table ttEnteteAppelDeFond  by-reference,
                                  output table ttAppelDeFond        by-reference,
                                  output table ttAppelDeFondRepCle  by-reference,
                                  output table ttAppelDeFondRepMat  by-reference,
                                  output table ttDossierAppelDeFond by-reference).
    run destroy in vhproc.
    run chargement-tmpana (poCollection).
    /* lecture ligne modifie sur l'ecran (si modif lot cet enregistrement n'existe pas) */
    for first ttRepartitionAV
        where ttRepartitionAV.CRUD = "U":
        ttRepartitionAV.CRUD = "R".
        for each vbttRepartitionAV
            where vbttRepartitionAV.iNoLot = ttRepartitionAV.iNoLot
            break by vbttRepartitionAV.iNoLot
                  by vbttRepartitionAV.dtDtLot:
            viTotPoLot = viTotPoLot + vbttRepartitionAV.iPoLot.

            if last(vbttRepartitionAV.dtDtLot) then vbttRepartitionAV.dEclot = 100 - viTotPoLot.

            run calculAppel(buffer ttDossierTravaux, buffer vbttRepartitionAV).
        end.
    end.

    if ttInfSelRepartitionAV.CRUD = "U"
    then for each vbttRepartitionAV
        by vbttRepartitionAV.iNoLot
        by vbttRepartitionAV.dtDtLot:
        run calculAppel(buffer ttDossierTravaux, buffer vbttRepartitionAV).
    end.
    run calculArrondi (ttInfSelRepartitionAV.iActifLotArrondi, buffer ttDossierTravaux, output vdMtArrondi).
    ttInfSelRepartitionAV.dMtArrondi = vdMtArrondi.

end procedure.

procedure CtrlValidationInfoRepartition:
    /*------------------------------------------------------------------------------
    Purpose: correspond a gesdossi/CtrlValidation pour la partie repartition
    Notes  : appel interne ou service exterieur (dossierTravaux.p)
    ------------------------------------------------------------------------------*/
    define parameter buffer pbttInfSelRepartitionAV for ttInfSelRepartitionAV.
    define parameter buffer pbttDossierTravaux for ttDossierTravaux.
    define input  parameter table for ttRepartitionAV.
    define input  parameter table for ttError.
    define output parameter table for ttEdtAno.
    define output parameter plCtrlOk as logical no-undo.

message " CtrlValidationInfoRepartition "
        " ttDossierTravaux.cCodeTypeMandat " pbttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " pbttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " pbttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " pbttDossierTravaux.iNumeroImmeuble.

    define variable viNoLgn       as integer   no-undo.
    define variable viRetQuestion as integer   no-undo.
    define variable vcFichier     as character no-undo.

    empty temp-table ttEdtAno.
    if pbttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic}
    then do:
        /*--> Controle lot de recuperation si existence d'appel */
        if pbttInfSelRepartitionAV.iActifLotArrondi = 0
        or pbttInfSelRepartitionAV.iActifLotArrondi = ?
        then do:
            if can-find (first ttEnteteAppelDeFond)
            then do:
                mError:createError({&error}, 108149).
                return.
            end.
        end.
        else if not can-find (first ttRepartitionAV)
        then do:
            pbttDossierTravaux.iLoRep = 0.
            mError:createError({&error}, 108149).
            return.
        end.

        if can-find(first ttRepartitionAV
                    where ttRepartitionAV.cTpLot = "V"
                      and ttRepartitionAV.iPoLot <> 0)
        then do:
            /* controle si la question "Voulez-vous corriger les anomalies non-bloquantes ?" a deja ete pose */
            viRetQuestion = outils:questionnaire(4000051, table ttError by-reference).
            if viRetQuestion < 2
            then do:
                /* Le programme a détecté des anomalies non-bloquantes. */
                mError:createError({&information}, 4000050).
                /* la question n'a pas encore éte pose, on sort la liste des anomalies */
                assign
                    viNoLgn   = 1
                    vcFichier = session:temp-directory + "adb/tmp/gesdossi_info.lg"
                .
                output to value (vcFichier).
                create ttEdtAno.
                assign
                    ttEdtAno.cClass = string(viNoLgn, "9999999999")
                    ttEdtAno.cLigne = "INFORMATIONS AU NIVEAU DES MUTATIONS:"
                    viNoLgn         = viNoLgn + 1
                .
                create ttEdtAno.
                assign
                    ttEdtAno.cClass = string(viNoLgn, "9999999999")
                    ttEdtAno.cLigne = substitute("Mandat: &1 - Dossier n° &2", string(pbttDossierTravaux.iNumeroMandat, ">>>>9"), trim(string(pbttDossierTravaux.iNumeroDossierTravaux, ">>>>9")))
                    viNoLgn         = viNoLgn + 1
                .
                create ttEdtAno.
                assign
                    ttEdtAno.cClass = string(viNoLgn,"9999999999")
                    ttEdtAno.cLigne = "Il existe des lignes sur des vendeurs avec un pourcentage non-nul."
                    viNoLgn         = viNoLgn + 1
                .
                create ttEdtAno.
                assign
                    ttEdtAno.cClass = string(viNoLgn,"9999999999")
                    ttEdtAno.cLigne = "Liste des lots concernés :"
                    viNoLgn         = viNoLgn + 1
                .
                for each ttRepartitionAV
                    where ttRepartitionAV.cTpLot = "V"
                      and ttRepartitionAV.iPoLot <> 0:
                    create ttEdtAno.
                    assign
                        ttEdtAno.cClass = string(viNoLgn, "9999999999")
                        ttEdtAno.cLigne = substitute(" LOT : &1 COPRO : &2", string(ttRepartitionAV.iNoLot, ">>>>>>>9"), string(ttRepartitionAV.inocop))
                        viNoLgn         = viNoLgn + 1
                    .
                    put unformatted
                        "LOT : " ttRepartitionAV.iNoLot " COPRO : " ttRepartitionAV.inocop " , LE VENDEUR N'EST PAS A ZERO." skip
                    .
                end.
                output close.
                return.
            end.
            /* on fait ce test mais normalement si la réponse utilisateur est oui, le trt ne doit plus etre appelle */
            else if viRetQuestion = 3 then return.
        end.

        if can-find (first ttRepartitionAV where ttRepartitionAV.dEcLot <> 0)
        then do:
            /* la question n'a pas encore éte pose, on sort la liste des anomalies */
            assign
                viNoLgn   = 1
                vcFichier = session:temp-directory + "adb/tmp/gesdossi_err.lg"
            .
            output to value (vcFichier).
            create ttEdtAno.
            assign
                ttEdtAno.cClass = string(viNoLgn, "9999999999")
                ttEdtAno.cLigne = substitute("Mandat: &1 - Dossier n° &2", string(pbttDossierTravaux.iNumeroMandat, ">>>>9"), trim(string(pbttDossierTravaux.iNumeroDossierTravaux, ">>>>9")))
                viNoLgn         = viNoLgn + 1
            .
            for each ttRepartitionAV where ttRepartitionAV.dEcLot <> 0:
                create ttEdtAno.
                assign
                    ttEdtAno.cClass = string(viNoLgn,"9999999999")
                    ttEdtAno.cLigne = "ECARTS DETECTES SUR LE LOT : " + string(ttRepartitionAV.iNoLot, ">>>>>>>>9")
                    viNoLgn         = viNoLgn + 1
                .
                put unformatted
                    "ECARTS DETECTES SUR LE LOT : " ttRepartitionAV.iNoLot skip
                .
            end.
            output close.
            /* IL y a des écarts entre la répartition Acheteur / Vendeur. */
            mError:createError({&information}, 4000052).
            /* Veuillez corriger le pourcentage de répartition (cliquer dans la zone %). */
            mError:createError({&information}, 4000053).
            return.
        end. /* if can-find (first ttRepartitionAV where ttRepartitionAV.dEcLot <> 0) */
    end.
    /*--> Retour bon */
    plCtrlOk = yes.

end procedure.

procedure chargement-tmpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : appel sous programme pour chargement de la table tmp-ana
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable vcTypeMandat   as character no-undo.
    define variable viNumeroMandat as integer   no-undo.
    define variable vcCdCp6700     as character no-undo initial "670000000".
    define variable vhProc         as handle    no-undo. 

    define buffer ietab for ietab.

message "debut chargement-tmpana".

    empty temp-table tmp-ana.
    assign
        vcTypeMandat   = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat = poCollection:getInteger("iNumeroMandat")
    .
    for first ietab no-lock
        where ietab.soc-cd  = integer(if vcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
          and ietab.etab-cd = viNumeroMandat:
        /*--> Chargement de la table des analytiques du dossier */ 
        poCollection:set('dtDatFin', ietab.dafinex2) no-error.
        poCollection:set('cCpt', vcCdCp6700) no-error.
        run compta/souspgm/extraihb.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run extraihbExtraitAnalytique in vhProc (poCollection, output table tmp-ana by-reference).
        run destroy in vhProc.                                 
    end.

end procedure.
