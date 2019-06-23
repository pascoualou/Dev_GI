/*------------------------------------------------------------------------
File        : quittanceHistorique.p
Purpose     : 
Author(s)   : kantena  -  2017/22/11 
Notes       : Reprise de chghisqt_ext.p
              Chargement d'une quittance anterieure d'un locataire ou de toutes ses quittances anterieures (NoQttUse = 0)
              a partir de la table AQUIT, dans les tables temporaires tmQtt et TmRub
------------------------------------------------------------------------*/
using parametre.pclie.parametrageRubriqueLibelleMultiple.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/tmprub.i}
{bail/include/equit.i &nomtable=ttqtt}

function flagDeChargement returns logical private (piNumeroRole as integer, piNumeroQuittance as integer):
    /*------------------------------------------------------------------------------
    Purpose: Procedure de determination du flag de chargement
    Notes:
    ------------------------------------------------------------------------------*/
    // Quittance deja chargee ?
    for first ttQtt 
         where ttQtt.NoLoc = piNumeroRole
           and ttQtt.NoQtt = piNumeroQuittance:
        // La quittance a deja chargee
        if ttQtt.CdMaj = 0 then return true. // Elle n'a pas ete modifiee
        /* Elle est modifiee.  
           Suppression de tous les enreg concernant la quittance dans ttQtt et ttRub
        */
        delete ttQtt no-error.
        for each ttRub 
           where ttRub.NoLoc = piNumeroRole
             and ttRub.NoQtt = piNumeroQuittance:
            delete ttRub no-error.
        end.
    end.
    return false. // Quittance non chargee
end function.

procedure getQuittance:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes: service
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroRole as integer   no-undo.
    define input  parameter piNumeroQtt  as integer   no-undo.
    define output parameter table for ttQtt.
    define output parameter table for ttRub.

    define variable voRubriqueLibelleMultiple as class parametrageRubriqueLibelleMultiple no-undo.
    define buffer aquit for aquit.

    voRubriqueLibelleMultiple = new parametrageRubriqueLibelleMultiple().
    // Recherche param Multi libellé rubriques
    for first aquit no-lock  // Recherche de la quittance du locataire
        where aquit.noLoc = piNumeroRole
          and aquit.noQtt = piNumeroQtt:
        if not flagDeChargement(piNumeroRole, aquit.noqtt)
        then run chargeTableTempo(buffer aquit, voRubriqueLibelleMultiple:isLibelleMultiple()).
    end.
    delete object voRubriqueLibelleMultiple no-error.

end procedure.

procedure getListeQuittance:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes: service
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroRole as integer no-undo.
    define output parameter table for ttQtt.
    define output parameter table for ttRub.

    define variable voRubriqueLibelleMultiple as class parametrageRubriqueLibelleMultiple no-undo.
    define buffer aquit for aquit.

    voRubriqueLibelleMultiple = new parametrageRubriqueLibelleMultiple().
    // Recherche param Multi libellé rubriques
    for each aquit no-lock                       // Parcours des quittances du locataire
       where aquit.noLoc = piNumeroRole:
        if not flagDeChargement(piNumeroRole, aquit.noqtt)
        then run chargeTableTempo(buffer aquit, voRubriqueLibelleMultiple:isLibelleMultiple()).
    end.
    delete object voRubriqueLibelleMultiple no-error.

end procedure.

procedure ChargeTableTempo private:
    /*------------------------------------------------------------------------------
      Purpose:  Procedure de chargement de ttQtt et ttRub
      Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer aquit for aquit.
    define input parameter plRubMul as logical no-undo.

    define variable viCodeFamilleRubrique  as integer   no-undo.
    define variable viCodeSousFamilleRub   as integer   no-undo.
    define variable vcCodeGenreRubrique    as character no-undo.
    define variable vcCodeSigneRubrique    as character no-undo.
    define variable viNombreRubriqueChange as integer   no-undo.
    define variable vhRubrique             as handle    no-undo.
    define variable vcLibelleRubrique      as character no-undo.
    define variable viNumeroRubrique       as integer   no-undo.
    define variable viNumeroLoc            as integer   no-undo.
    define variable viCpt                  as integer   no-undo.

    define buffer iftsai for iftsai.
    define buffer rubqt  for rubqt.

    // Chargement de ttQtt
    create ttQtt.
    assign
        ttQtt.NoLoc = Aquit.NoLoc
        ttQtt.NoQtt = Aquit.NoQtt
        ttQtt.MsQtt = Aquit.MsQtt
        ttQtt.MsQui = Aquit.MsQui
        ttQtt.DtDeb = Aquit.DtDeb
        ttQtt.DtFin = Aquit.DtFin
        ttQtt.DtDpr = Aquit.DtDpr
        ttQtt.DtFpr = Aquit.DtFpr
        ttQtt.PdQtt = Aquit.PdQtt
        ttQtt.NtBai = Aquit.NtBai
        ttQtt.DuBai = Aquit.DuBai
        ttQtt.UtDur = Aquit.UtDur
        ttQtt.DtEff = Aquit.DtEff
        ttQtt.DtRev = Aquit.DtRev
        ttQtt.MdReg = Aquit.MdReg
        ttQtt.CdTer = Aquit.CdTer
        ttQtt.DtEnt = Aquit.DtEnt
        ttQtt.DtSor = Aquit.DtSor
        ttQtt.DtEms = Aquit.DtEms
        ttQtt.NoImm = Aquit.NoImm
        ttQtt.NbRub = Aquit.NbRub
        ttQtt.Cdquo = Aquit.CdQuo
        ttQtt.NbNum = Aquit.NbNum
        ttQtt.NbDen = Aquit.NbDen
        ttQtt.CdOri = "H"
        ttQtt.fgfac       = aquit.fgfac
        ttQtt.type-fac    = aquit.type-fac
        ttQtt.num-int-fac = aquit.num-int-fac 
    .
    if aquit.fgfac and aquit.num-int-fac > 0
    then for first iftsai no-lock       /* Recherche de la Facture en compta */
        where iftsai.soc-cd    = integer(mtoken:cRefGerance)
          and iftsai.etab-cd   = integer(truncate(aquit.noloc / 100000, 0))  // substring(string(aquit.noloc,"9999999999"), 1 , 5))
          and iftsai.tprole    = 19
          and iftsai.sscptg-cd = substring(string(aquit.noloc, "9999999999"), 6 , 5, "character")
          and iftsai.num-int   = aquit.num-int-fac:
        assign
            ttQtt.dafac    = iftsai.dafac
            ttQtt.Lbtypfac = iftsai.typefac-cle
            ttQtt.fac-num  = iftsai.fac-num
            ttQtt.dacompta = iftsai.dacompta
            ttQtt.type-cle = iftsai.type-cle
        .
    end.
    // Chargement de ttRub
    viNombreRubriqueChange = 0.
    run bail/quittancement/rubriqueQuitt.p persistent set vhRubrique.
    run getTokenInstance in vhRubrique (mToken:JSessionId).
   
    /* modif SY le 24/12/2009 - fiche 1209/0212 : gestion 20 rubriques utilisées */
BOUCLE:
    do viCpt = 1 to 20:    // remplacer par extent du champ 
        viNumeroRubrique = integer(entry(1, aquit.tbRub[viCpt], '|')).
        if viNumeroRubrique = 0 then leave BOUCLE.

        if viNumeroRubrique <> ? then do:
            assign
                viNumeroLoc = integer(entry(2, aquit.tbRub[viCpt], '|'))
                // Recuperation du libelle de la rubrique
                vcLibelleRubrique = dynamic-function('getLibelleRubrique' in vhRubrique,
                                           viNumeroRubrique,
                                           viNumeroLoc,
                                           aquit.noloc,
                                           aquit.msqtt,
                                           ?,                    /* date comptable */
                                           integer(mtoken:cRefGerance),
                                           if aquit.type-fac > "" and aquit.type-fac <> "E" then aquit.num-int-fac else 0)
                viCodeFamilleRubrique = 0
                viCodeSousFamilleRub  = 0
                vcCodeGenreRubrique   = "00001"
                vcCodeSigneRubrique   = "00001"
            .
            for first rubqt no-lock
                 where rubqt.cdrub = viNumeroRubrique
                   and rubqt.cdlib = viNumeroLoc:
                assign
                    viCodeFamilleRubrique = RubQt.CdFam
                    viCodeSousFamilleRub  = RubQt.CdSfa
                    vcCodeGenreRubrique   = RubQt.CdGen
                    vcCodeSigneRubrique   = RubQt.CdSig
                .
            end.
            /* Modif SY le 05/12/2007 - fiche 1207/0066 - DAUCHEZ : ils ont créé des factures diverses avec plusieurs libellé pour la rub 200 */
            /* => laisser passer en affichage histo */
            /*RUN IsMulAut (INPUT "01033",INPUT Aquit.NoLoc, INPUT NoRubQtt, OUTPUT FgMulAut, OUTPUT LbMesInf).*/
            if not (plRubMul /*AND FgMulAut*/)
            then for first ttRub             // 22/01/2004 : verifier que la rubrique n'existe pas deja  (cas possible si transpo)
                where ttRub.NoLoc = aquit.noLoc
                  and ttRub.NoQtt = aquit.noQtt
                  and ttRub.NoRub = viNumeroRubrique:
                /* TODO THK : Remplacer par un ttError d'info ?
                message "Anomalie Locataire" string(aquit.noloc)
                        "Quittance no"       string(aquit.noqtt)
                        "rubrique"           string(NoRubQtt) "en doublon "
                    view-as alert-box
                    title "Erreur Chargement Quittance " + STRING(aquit.msqtt,"999999").
                */
            end.
            /* modif SY le 11/09/2009 pour éviter plantage avec boucle sans fin */
            find first ttRub 
                where ttRub.NoLoc = Aquit.NoLoc
                  and ttRub.NoQtt = Aquit.NoQtt
                  and ttRub.NoRub = viNumeroRubrique
                  and ttRub.NoLib = viNumeroLoc no-error.
            if not available ttRub then do:
                create ttRub.
                assign
                    ttRub.NoLoc = Aquit.NoLoc
                    ttRub.NoQtt = Aquit.NoQtt
                    ttRub.CdFam = viCodeFamilleRubrique
                    ttRub.CdSfa = viCodeSousFamilleRub
                    ttRub.NoRub = viNumeroRubrique
                    ttRub.NoLib = viNumeroLoc
                    ttRub.LbRub = vcLibelleRubrique
                    ttRub.CdGen = vcCodeGenreRubrique
                    ttRub.CdSig = vcCodeSigneRubrique
                    ttRub.NoLig = viCpt
                    viNombreRubriqueChange = viNombreRubriqueChange + 1
                .
                if num-entries(aquit.tbRub[viCpt], '|') >= 11
                then assign
                    ttRub.VlQte = decimal(entry(3, aquit.tbRub[viCpt], '|'))
                    ttRub.VlNum = integer(entry(7, aquit.tbRub[viCpt], '|'))
                    ttRub.VlDen = integer(entry(8, aquit.tbRub[viCpt], '|'))
                    ttRub.VlPun = decimal(entry(4, aquit.tbRub[viCpt], '|'))
                    ttRub.MtTot = decimal(entry(5, aquit.tbRub[viCpt], '|'))
                    ttRub.vlMtq = decimal(entry(6, aquit.tbRub[viCpt], '|'))
                    ttRub.dtDap = date(entry(10, aquit.tbRub[viCpt], '|'))
                    ttRub.dtFap = date(entry(11, aquit.tbRub[viCpt], '|'))
                    // AFA Mise à jour du flag prorata
                    ttRub.cdPro = if decimal(entry(7, aquit.tbRub[viCpt], '|')) = 0 
                                  or decimal(entry(8, aquit.tbRub[viCpt], '|')) = 0
                                  then 0 else 1 
                no-error.
            end.
        end.
    end.
    // Maj nombre reel de rubriques
    ttQtt.nbRub = viNombreRubriqueChange.
    if valid-handle(vhRubrique) then run destroy in vhRubrique.

end procedure.
