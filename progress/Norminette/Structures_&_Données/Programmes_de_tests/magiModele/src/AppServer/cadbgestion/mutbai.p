/*------------------------------------------------------------------------
File        : mutbai.p
Purpose     : comptabilisation des mutations de bail (dérivé de cesbai.p)
Author(s)   : RF 13/08/10   -  GGA  2018/05/14
Notes       : a partir de cadb/gestion/mutbai.p

+---------------------------------------------------------------------------+
| Historique des modifications                                              |
|======+============+========+==============================================|
|  Nø  |    Date    | Auteur |                  Objet                       |
|======+============+========+==============================================|
|  001 | 23/11/2010 |   RF   |1110/0072 - Traitement à part du QUIT L à M   |
|      |            |        |en ODSG / ODQTT                               |
|  002 | 31/03/2011 |   RF   |0311/0235 - Ne pas passer les écritures au    |
|      |            |        |M pour les dépot de garantie reversés         |
|  003 | 08/04/2011 |   RF   |0411/0064 - Affectation correcte des journaux |
|      |            |        |lors de mutations successives                 |
|  004 | 12/04/2011 |   RF   |0411/0067 - Si pas de DG, aucune ecriture     |
|      |            |        |n'est basculée (bogue)                        |
|  005 | 12/04/2011 |   RF   |0411/0084 - On prend la date d'achat - 1 jour |
|  006 | 13/04/2011 |   RF   |0411/0084 - Annulation modif précédente       |
|  007 | 06/05/2011 |   PL   |0411/0155 - Pb raz tmp-cron                   |
|  008 | 26/07/2011 |   DM   |0711/0122 - Pb détermination date comptable   |
|  009 | 20/01/2011 |   RF   |0711/0122 - Suite, nelle regle dates compta   |
|  010 | 28/05/2012 |   OF   |0512/0085 Ne pas basculer les ANC sur le nou- |
|      |            |        |veau mandat                                   |
|  011 | 16/05/2013 |   PL   |0313/0071 Pb valorisation RpRunGene sur gi et |
|      |            |        |non gidev en new ergo.                        |
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{cadbgestion/include/TbLstRub.i NEW}

{compta/include/flagLettre-cLettre-inumpiec.i}
{compta/include/faletaut.i}
{application/include/glbsepar.i}

define variable giSociete          as integer   no-undo.
define variable gcDevMdt           as character no-undo.
define variable grRowidCecrsai     as rowid     no-undo.
define variable gicodeetab         as integer   no-undo.
define variable gdaAchatNotaire    as date      no-undo.
define variable giAncienMandat     as integer   no-undo.
define variable giAncienLocataire  as integer   no-undo.
define variable giNouveauMandat    as integer   no-undo.
define variable giNouveauLocataire as integer   no-undo.
define variable ghProc             as handle    no-undo.
define variable gdDaCompta         as date      no-undo.
define variable giLig              as integer   no-undo.
define variable giMoisUse          as integer   no-undo.

define temp-table ttCpt no-undo
    field cpt-cd     like cecrln.cpt-cd
    field coll-cle   like cecrln.coll-cle
    field sscoll-cle like cecrln.sscoll-cle
    field etab-cd    as integer
.
define temp-table ttCecrln no-undo like cecrln
    field cdtrt    as integer
    field dacptdup as date
    field rcecrln  as rowid
    index primaire cdtrt dacptdup
.
define temp-table ttCecrsai no-undo like cecrsai
    index primaire soc-cd
.

function dateCompta returns date private (pjDaLoc as date, pjGestDeb as date, pjGestFin as date, pjDaCptRef as date):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    if pjGestDeb <= today and today <= pjGestFin            /* Date dans jour dans période gestionnaire */
    then do:
        if gdaAchatNotaire <= pjDaLoc and pjDaloc <= today
        then return today.
        if today < pjDaloc
        then return pjDaloc.
    end.
    else if pjGestFin < today                             /* Date du jour > date de fin du gestionnaire */
    then do:
        if gdaAchatNotaire <= pjDaLoc and pjDaloc <= pjGestFin
        then return pjGestFin.
        if pjGestFin < pjDaloc
        then return pjDaloc.
    end.
    return pjDaCptRef.

end function.

procedure lancementMutbai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piSociete          as integer no-undo.
    define input  parameter piAncienMandat     as integer no-undo.
    define input  parameter piAncienLocataire  as integer no-undo.
    define input  parameter piNouveauMandat    as integer no-undo.
    define input  parameter piNouveauLocataire as integer no-undo.
    define input  parameter pdaAchatNotaire    as date no-undo.

    define variable viIndice     as integer   no-undo.
    define variable dSolde-LDG   as decimal   no-undo extent 6.
    define variable vcSscoll-LDG as character no-undo extent 6 init ["LDG","LBIP","LCAU","LDGR","LDGRB","LDGRC"].
    define variable vcCptG-LDG   as character no-undo extent 6 init ["","","","275300000","275700000","275900000"].
    define variable vjGestDeb    as date      no-undo.
    define variable vjGestFin    as date      no-undo.
    define variable vjDaCptRef   as date      no-undo.

    define buffer isoc      for isoc.
    define buffer ietab     for ietab.
    define buffer idev      for idev.
    define buffer agest     for agest.
    define buffer vbietab   for ietab.
    define buffer csscpt    for csscpt.
    define buffer ccpt      for ccpt.
    define buffer cecrln    for cecrln.
    define buffer csscptcol for csscptcol.
    define buffer vbcsscpt  for csscpt.
    define buffer cecrsai   for cecrsai.

    assign
        giSociete         = piSociete
        giAncienMandat    = piAncienMandat
        giAncienLocataire  = piAncienLocataire
        giNouveauMandat    = piNouveauMandat
        giNouveauLocataire = piNouveauLocataire
        gdaAchatNotaire    = pdaAchatNotaire
    .

    find first isoc no-lock where isoc.soc-cd = piSociete no-error.
    if not available isoc
    then do:
        mError:createError({&error}, 1000725).               //enregistrement société inexistant
        return.
    end.
    find first ietab no-lock
         where ietab.soc-cd    = isoc.soc-cd
           and ietab.profil-cd = 20 no-error.
    if not available ietab
    then do:
        mError:createError({&error}, 1000726).              //enregistrement etablissement société inexistant
        return.
    end.
    GiCodeEtab = ietab.etab-cd.
    find first idev no-lock
         where idev.soc-cd = giSociete
           and idev.dev-cd = ietab.dev-cd no-error.
    gcDevMdt = if available idev then idev.dev-cd else "EUR".
    for first agest no-lock of ietab:
        assign
            vjGestDeb  = agest.dadeb
            vjGestFin  = agest.dafin
            vjDaCptRef = today
            vjDaCptRef = max(vjDaCptRef,agest.dadeb)
            vjDaCptRef = min(vjDaCptRef,agest.dafin)
            gdDaCompta = vjDaCptRef
            giMoisUse  = year(gdDaCompta) * 100 + month(gdDaCompta)
        .
    end.
    if not can-find(first iprd no-lock
                    where iprd.soc-cd   = giSociete
                      and iprd.etab-cd  = GiCodeEtab
                      and iprd.dadebprd <= gdDaCompta
                      and iprd.dafinprd >= gdDaCompta)
    then do:
        mError:createError({&error}, 1000727).           //La période du mandat de gérance globale est inexistante
        return.
    end.
    if gdDaCompta < (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1)
    then do:
        mError:createError({&error}, 1000728).            //La comptabilisation est impossible sur un exercice clôturé
        return.
    end.
    /* Tests relatifs à l'ancien Mandat                */
    find first ietab no-lock
         where ietab.soc-cd  = isoc.soc-cd
           and ietab.etab-cd = giAncienMandat no-error.
    if not available ietab
    then do:
        mError:createError({&error}, 1000729).          //Le Mandat d'origine est inexistant
        return.
    end.
    if not can-find (first iprd no-lock
                     where iprd.soc-cd   = giSociete
                       and iprd.etab-cd  = giAncienMandat
                       and iprd.dadebprd <= gdDaCompta
                       and iprd.dafinprd >= gdDaCompta)
    then do:
        mError:createError({&error}, 1000730).        //La période du mandat d'origine est inexistante
        return.
    end.
    if gdDaCompta < (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1)
    then do:
        mError:createError({&error}, 1000731).        //La comptabilisation est impossible sur un exercice clôturé
        return.
    end.
    /* Tests relatif au nouveau Mandat                 */
    find first ietab no-lock
         where ietab.soc-cd  = isoc.soc-cd
           and ietab.etab-cd = giNouveauMandat no-error.
    if not available ietab
    then do:
        mError:createError({&error}, 1000732).            //Le Mandat de destination est inexistant
        return.
    end.
    if not can-find(first iprd no-lock
                    where iprd.soc-cd    = giSociete
                      and iprd.etab-cd   = giNouveauMandat
                      and iprd.dadebprd <= gdDaCompta
                      and iprd.dafinprd >= gdDaCompta)
    then do:
        mError:createError({&error}, 1000733).          //La période du mandat de destination est inexistante
        return.
    end.
    if gdDaCompta < (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1)
    then do:
        mError:createError({&error}, 1000734).        //La comptabilisation est impossible sur un exercice clôturé
        return.
    end.

    /* Assignation du gestionnaire par défaut pour le nouveau mandat / Obligatoire pour traçage - RF 17/08/2010  */
    find first agest of ietab no-lock no-error.
    if not available agest
    then do:
boucleMajGestionnaire:
        for each vbietab no-lock of isoc
           where vbietab.profil-cd = 21:
            for first agest no-lock of vbietab:
                for first ietab exclusive-lock
                    where ietab.soc-cd  = isoc.soc-cd
                      and ietab.etab-cd = giNouveauMandat:
                    ietab.gest-cle = agest.gest-cle.
                end.
                leave boucleMajGestionnaire.
            end.
        end.
    end.

    /* Calcul des soldes                               */
    /* Un solde LDG débiteur ie > 0 est-il bloquant ?? */
    do viIndice = 1 to 6:
        run SoldeCpt (giAncienMandat, vcSscoll-LDG[viIndice], string(giAncienLocataire,"99999"), today, output dSolde-LDG[viIndice]).
        if dSolde-LDG[viIndice] <> 0
        then do:
            /* Solde non nul -> passage des écritures -> test de l'existence des comptes du nouveau mandat */
            /*               -> je ne peux imaginer que les comptes de l'ancien n'existent pas...          */
            /*               -> un peu comme la référence, quoi...                                         */
            /* Dans tous les cas, recherche du LDGXX / Nouveau Loc */
            if not can-find(first csscpt no-lock
                            where csscpt.soc-cd     = giSociete
                              and csscpt.etab-cd    = giNouveauMandat
                              and csscpt.sscoll-cle = vcSscoll-LDG[viIndice]
                              and csscpt.cpt-cd     = string(giNouveauLocataire,"99999"))
            then do:
                mError:createError({&error}, 1000736, substitute('&2&1&3', separ[1], vcSscoll-LDG[viIndice], string(giNouveauLocataire,"99999"))). //Le compte &1 &2 n'existe pas sur le mandat de destination
                return.
            end.
            /* Pour les LDGR, recherche du M 0000 et 275X 00000 */
            if viIndice >= 4
            then do:
                if not can-find (first ccpt no-lock
                                 where ccpt.soc-cd     = giSociete
                                   and ccpt.coll-cle   = ""
                                   and ccpt.libtype-cd <= 2
                                   and ccpt.cpt-cd     = vcCptG-LDG[viIndice])
                then do:
                    mError:createError({&error}, 1000737, vcCptG-LDG[viIndice]). //Le compte &1 n'existe pas sur le mandat de destination
                    return.
                end.
                if not can-find(first csscpt no-lock
                                where csscpt.soc-cd   = giSociete
                                and csscpt.etab-cd    = giNouveauMandat
                                and csscpt.sscoll-cle = "M"
                                and csscpt.cpt-cd     = "00000")
                then do:
                    mError:createError({&error}, 1000735).              //Le compte M 00000 n'existe pas sur le mandat de destination
                    return.
                end.
            end.
        end.
    end.

    /* Test préliminaires pour existance des comptes L* XXXXX du nouveau mandat */
    for each csscptcol no-lock
        where csscptcol.soc-cd                          = giSociete
          and csscptcol.etab-cd                         = giAncienMandat
          and csscptcol.coll-cle                        = "L"
          and lookup(csscptcol.sscoll-cle,"L,LA,LC,LF") > 0
    , first csscpt no-lock
      where csscpt.soc-cd     = giSociete
        and csscpt.etab-cd    = giAncienMandat
        and csscpt.sscoll-cle = csscptcol.sscoll-cle
        and csscpt.cpt-cd     = string(giAncienLocataire,"99999")
    , first cecrln no-lock
      where cecrln.soc-cd     = giSociete
        and cecrln.etab-cd    = giAncienMandat
        and cecrln.sscoll-cle = csscpt.sscoll-cle
        and cecrln.cpt-cd     = csscpt.cpt-cd
        and cecrln.dacompta   >= gdaAchatNotaire:
        if not can-find(first vbcsscpt no-lock
                        where vbcsscpt.soc-cd     = giSociete
                          and vbcsscpt.etab-cd    = giNouveauMandat
                          and vbcsscpt.sscoll-cle = csscpt.sscoll-cle
                          and vbcsscpt.cpt-cd     = string(giNouveauLocataire,"99999"))
        then do:
            mError:createError({&error}, 1000736, substitute('&2&1&3', separ[1], csscpt.sscoll-cle, string(giNouveauLocataire,"99999"))). //Le compte &1 &2 n'existe pas sur le mandat de destination
            return.
        end.
    end.

    run creation-entete (GiCodeEtab, "ODGG", "OD", "DG").
    do viIndice = 1 to 6:
        if dSolde-LDG[viIndice] = 0 then next.
        /* 1 - Pour tous dépôts                                            */
        /*     > Transférer le solde LDG de l'ancien mandat sur le nouveau */
        for first csscpt no-lock
            where csscpt.soc-cd     = giSociete
              and csscpt.etab-cd    = giAncienMandat
              and csscpt.sscoll-cle = vcSscoll-LDG[viIndice]
              and csscpt.cpt-cd     = string(giAncienLocataire,"99999"):
            run ligne-generale (giAncienMandat,
                                (dSolde-LDG[viIndice] < 0),
                                vcSscoll-LDG[viIndice],
                                string(giAncienLocataire,"99999"),
                                "Virt DG " + csscpt.lib,
                                abs(dSolde-LDG[viIndice]),
                                "",  /* zone1                */
                                "",  /* Collectif info tiers */
                                "",  /* Compte info tiers    */
                                ""). /* Rub ana              */
        end.
        for first csscpt no-lock
            where csscpt.soc-cd     = giSociete
              and csscpt.etab-cd    = giNouveauMandat
              and csscpt.sscoll-cle = vcSscoll-LDG[viIndice]
              and csscpt.cpt-cd     = string(giNouveauLocataire,"99999"):
            run ligne-generale (giNouveauMandat,
                                (dSolde-LDG[viIndice] > 0),
                                vcSscoll-LDG[viIndice],
                                string(giNouveauLocataire,"99999"),
                                "Virt DG " + csscpt.lib,
                                abs(dSolde-LDG[viIndice]),
                                "",  /* zone1                */
                                "",  /* Collectif info tiers */
                                "",  /* Compte info tiers    */
                                ""). /* Rub ana              */
        end.
        if viIndice >= 4
        then do:
            /* 2 - Pour les dépôts reversés */
            /*     > Transférer les soldes correspondant du compte 275X 00000 de l'ancien mandat vers le nouveau */
            /*     > Constater la dépense sur l'ancien mandat et passer en recette sur le nouveau                */
            /*     > Rubrique ana vu avec DM, utiliser 730-519-1                                                 */
            for first ccpt no-lock
                where ccpt.soc-cd     = giSociete
                  and ccpt.coll-cle   = ""
                  and ccpt.libtype-cd <= 2
                  and ccpt.cpt-cd     = vcCptG-LDG[viIndice]:
                run ligne-generale (giAncienMandat,
                                    (dSolde-LDG[viIndice] > 0),
                                    "",
                                    ccpt.cpt-cd,
                                    "Virt DG " + ccpt.lib,
                                    abs(dSolde-LDG[viIndice]),
                                    "", /* zone1                */
                                    "", /* Collectif info tiers */
                                    "", /* Compte info tiers    */
                                    ""). /* Rub ana              */
                run ligne-generale (giNouveauMandat,
                                    (dSolde-LDG[viIndice] < 0),
                                    "",
                                    ccpt.cpt-cd,
                                    "Virt DG " + ccpt.lib,
                                    abs(dSolde-LDG[viIndice]),
                                    "", /* zone1                */
                                    "", /* Collectif info tiers */
                                    "", /* Compte info tiers    */
                                    ""). /* Rub ana              */
            end.
        end.
    end.

    run comptabilisation.
    /*       TRANSFERT DES ECRITURES COMPTABLES     */
    /* 0711/0122 - RF -020/01/2011 - Nouvelles règles pour date comptables */
    /* 1 - Extraction des écritures en table tempo avec assignation des critères */
    /*     - CdTrt    (0 = Quittancement / 1 = OD simple / 2 = Tréso )           */
    /*     - dacptdup (Date Comptable écriture de mutation)                      */
    for each csscptcol no-lock
       where csscptcol.soc-cd                          = giSociete
         and csscptcol.etab-cd                         = giAncienMandat
         and csscptcol.coll-cle                        = "L"
         and lookup(csscptcol.sscoll-cle,"L,LA,LC,LF") > 0
    , first csscpt no-lock
      where csscpt.soc-cd     = giSociete
        and csscpt.etab-cd    = giAncienMandat
        and csscpt.sscoll-cle = csscptcol.sscoll-cle
        and csscpt.cpt-cd     = string(giAncienLocataire,"99999"):
        for each cecrln no-lock
           where cecrln.soc-cd     = giSociete
             and cecrln.etab-cd    = giAncienMandat
             and cecrln.sscoll-cle = csscpt.sscoll-cle
             and cecrln.cpt-cd     = csscpt.cpt-cd
             and cecrln.dacompta   >= gdaAchatNotaire
        , first cecrsai no-lock
          where cecrsai.soc-cd    = cecrln.soc-cd
            and cecrsai.etab-cd   = cecrln.mandat-cd
            and cecrsai.jou-cd    = cecrln.jou-cd
            and cecrsai.prd-cd    = cecrln.mandat-prd-cd
            and cecrsai.prd-num   = cecrln.mandat-prd-num
            and cecrsai.piece-int = cecrln.piece-int
            and not can-find(first ijou of cecrsai where ijou.natjou-gi = 93):                    /**Ajout OF le 28/05/12**/
            create ttCecrln.
            buffer-copy cecrln to ttCecrln
            assign
                ttCecrln.rcecrln = rowid(cecrln)
                ttCecrln.dacptdup = dateCompta(ttCecrln.dacompta, vjGestDeb, vjGestFin, vjDaCptRef)
            .
            if cecrsai.natjou-cd = 2 or cecrsai.jou-cd begins "ODT"     /* Trésorerie ou OD trésorerie -> ODTGG   */
            then ttCecrln.cdtrt = 2.                                    /* BEGINS "ODT" > Mutation successive OK! */
            else do:
                if cecrln.sscoll-cle = "L"
                and (cecrln.jou-cd = "QUIT" or cecrln.jou-cd = "ODSG")
                and cecrln.type-cle = "ODQTT"
                then do:
                    create ttCecrsai.
                    buffer-copy cecrsai to ttCecrsai.
                end.
                else ttCecrln.cdtrt = 1.
            end.
        end.
    end.
    /* 2 - Géneration des écritures Hors Quit */
    for each ttCecrln
       where ttCecrln.cdtrt > 0
    break by ttCecrln.cdtrt
          by ttCecrln.dacptdup:
        if first-of(ttCecrln.dacptdup)
        then do:
            gdDaCompta = ttCecrln.dacptdup.
            run creation-entete (GiCodeEtab, (if ttCecrln.cdtrt = 2 then "ODTGG" else "ODGG"), "OD", "ECR").
        end.
        run Ligne-dup(giNouveauMandat, ttCecrln.sscoll-cle, string(giNouveauLocataire,"99999"), ttCecrln.rcecrln).
        if last-of(ttCecrln.dacptdup)
        then run comptabilisation.
    end.
    /* 3 - Traitement du Quit */
    for each ttCecrsai:
        /* 3-1 - Copie de la pièce sur le nouveau mandat       */
        find first ttCecrln
             where ttCecrln.soc-cd         = ttCecrsai.soc-cd
               and ttCecrln.mandat-cd      = ttCecrsai.etab-cd
               and ttCecrln.jou-cd         = ttCecrsai.jou-cd
               and ttCecrln.mandat-prd-cd  = ttCecrsai.prd-cd
               and ttCecrln.mandat-prd-num = ttCecrsai.prd-num
               and ttCecrln.piece-int      = ttCecrsai.piece-int
               and ttCecrln.etab-cd        = giAncienMandat
               and ttCecrln.sscoll-cle     = "L"
               and ttCecrln.cpt-cd         = string(giAncienLocataire,"99999")
               and ttCecrln.dacompta       >= gdaAchatNotaire no-error.
        assign
            gdDaCompta = (if available ttCecrln then ttCecrln.dacptdup else vjDaCptRef)
            giMoisUse  = year(gdDaCompta) * 100 + month(gdDaCompta)
        .
        run CreRubQt (integer(string(giNouveauMandat) + string(giNouveauLocataire,"99999"))).
        run creation-entete (giNouveauMandat, "ODSG", "ODQTT", "ECR").
        for each cecrln no-lock
           where cecrln.soc-cd         = ttCecrsai.soc-cd
             and cecrln.mandat-cd      = ttCecrsai.etab-cd
             and cecrln.jou-cd         = ttCecrsai.jou-cd
             and cecrln.mandat-prd-cd  = ttCecrsai.prd-cd
             and cecrln.mandat-prd-num = ttCecrsai.prd-num
             and cecrln.piece-int      = ttCecrsai.piece-int
             and cecrln.etab-cd        = giAncienMandat
             and cecrln.sscoll-cle     = "L"
             and cecrln.cpt-cd         = string(giAncienLocataire,"99999")
             and cecrln.dacompta       >= gdaAchatNotaire:
            run Ligne-dup2(giNouveauMandat, cecrln.sscoll-cle, string(giNouveauLocataire,"99999"), true, rowid(cecrln)).
        end.
        run comptabilisation.
    end.
    for each ttCecrsai:
        /* 3-2 - Annulation sur l'ancien mandat       */
        find first ttCecrln
             where ttCecrln.soc-cd         = ttCecrsai.soc-cd
               and ttCecrln.mandat-cd      = ttCecrsai.etab-cd
               and ttCecrln.jou-cd         = ttCecrsai.jou-cd
               and ttCecrln.mandat-prd-cd  = ttCecrsai.prd-cd
               and ttCecrln.mandat-prd-num = ttCecrsai.prd-num
               and ttCecrln.piece-int      = ttCecrsai.piece-int
               and ttCecrln.etab-cd        = giAncienMandat
               and ttCecrln.sscoll-cle     = "L"
               and ttCecrln.cpt-cd         = string(giAncienLocataire,"99999")
               and ttCecrln.dacompta       >= gdaAchatNotaire no-error.
        assign
            gdDaCompta = (if available ttCecrln then ttCecrln.dacptdup else vjDaCptRef)
            giMoisUse  = year(gdDaCompta) * 100 + month(gdDaCompta)
        .
        run CreRubQt (integer(string(giAncienMandat) + string(giAncienLocataire,"99999"))).
        run creation-entete (giAncienMandat, "ODSG", "ODQTT", "ECR").
        for each cecrln no-lock
           where cecrln.soc-cd         = ttCecrsai.soc-cd
             and cecrln.mandat-cd      = ttCecrsai.etab-cd
             and cecrln.jou-cd         = ttCecrsai.jou-cd
             and cecrln.mandat-prd-cd  = ttCecrsai.prd-cd
             and cecrln.mandat-prd-num = ttCecrsai.prd-num
             and cecrln.piece-int      = ttCecrsai.piece-int
             and cecrln.etab-cd        = giAncienMandat
             and cecrln.sscoll-cle     = "L"
             and cecrln.cpt-cd         = string(giAncienLocataire,"99999")
             and cecrln.dacompta       >= gdaAchatNotaire:
            run Ligne-dup2(giAncienMandat, cecrln.sscoll-cle, cecrln.cpt-cd, false, rowid(cecrln)).
        end.
        run comptabilisation.
    end.
    run lettrage.

end procedure.

procedure creation-entete private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piMdt      as integer   no-undo.
    define input parameter pcJou-cd   as character no-undo.
    define input parameter pcType-cle as character no-undo.
    define input parameter pcLib      as character no-undo.

    define buffer ietab    for ietab.
    define buffer ijou     for ijou.
    define buffer idev     for idev.
    define buffer itypemvt for itypemvt.
    define buffer iprd     for iprd.
    define buffer cecrsai  for cecrsai.
    define buffer cnumpiec for cnumpiec.

    giLig = 0.
    find first ietab no-lock
         where ietab.soc-cd  = giSociete
           and ietab.etab-cd = piMdt no-error.
    find first ijou no-lock
         where ijou.soc-cd  = giSociete
           and ijou.etab-cd = piMdt
           and ijou.jou-cd  = pcJou-cd no-error                      /* (IF lOdt THEN "ODTGG" ELSE "ODGG")*/ .
    find first idev no-lock
         where idev.soc-cd = giSociete
           and idev.dev-cd = gcDevMdt no-error.                        /* Devise mandat */
    find first itypemvt no-lock
         where itypemvt.soc-cd    = giSociete
           and itypemvt.etab-cd   = piMdt
           and itypemvt.natjou-cd = ijou.natjou-cd
           and itypemvt.type-cle  = pcType-cle no-error.
    find first iprd no-lock
         where iprd.soc-cd   = giSociete
           and iprd.etab-cd  = piMdt
           and iprd.dadebprd <= gdDaCompta
           and iprd.dafinprd >= gdDaCompta no-error.
    create cecrsai.
    assign
        cecrsai.soc-cd     = giSociete
        cecrsai.etab-cd    = piMdt
        cecrsai.jou-cd     = ijou.jou-cd
        cecrsai.daecr      = gdaAchatNotaire
        cecrsai.lib        = "Mutation de Bail - " + pcLib
        cecrsai.dacrea     = today
        cecrsai.dev-cd     = gcDevMdt
        cecrsai.usrid      = mtoken:cUser
        cecrsai.consol     = false
        cecrsai.bonapaye   = true
        cecrsai.situ       = false
        cecrsai.cours      = idev.cours
        cecrsai.mtregl     = 0
        cecrsai.type-cle   = pcType-cle /* "OD" */
        cecrsai.prd-cd     = iprd.prd-cd
        cecrsai.prd-num    = iprd.prd-num
        cecrsai.mtdev      = 0
        cecrsai.natjou-cd  = ijou.natjou-cd
        cecrsai.dadoss     = ?
        cecrsai.dacompta   = gdDaCompta
        cecrsai.ref-num    = ""
        cecrsai.coll-cle   = ""
        cecrsai.mtimput    = 0
        cecrsai.acompte    = false
        cecrsai.adr-cd     = 0
        cecrsai.typenat-cd = itypemvt.typenat-cd
        cecrsai.profil-cd  = ietab.profil-cd
        grRowidCecrsai     = rowid (cecrsai)
    .
    find first cnumpiec exclusive-lock
         where cnumpiec.soc-cd   = cecrsai.soc-cd
           and cnumpiec.etab-cd  = cecrsai.etab-cd
           and cnumpiec.jou-cd   = cecrsai.jou-cd
           and cnumpiec.prd-cd   = cecrsai.prd-cd
           and cnumpiec.prd-num  = cecrsai.prd-num no-error.
    if available cnumpiec
    then assign
             cecrsai.piece-int     = cnumpiec.piece-int + 1
             cnumpiec.piece-int    = cecrsai.piece-int
             cnumpiec.piece-compta = cnumpiec.piece-compta + 1
             cecrsai.piece-compta  = cnumpiec.piece-compta
    .
    else do:
        create cnumpiec.
        assign
            cnumpiec.soc-cd  = cecrsai.soc-cd
            cnumpiec.etab-cd = cecrsai.etab-cd
            cnumpiec.jou-cd  = cecrsai.jou-cd
            cnumpiec.prd-cd  = cecrsai.prd-cd
            cnumpiec.prd-num = cecrsai.prd-num
            cnumpiec.piece-compta = inumpiecNumerotationPiece(ijou.fpiece, cecrsai.dacompta)
        .
        assign
            cnumpiec.piece-int    = 1
            cecrsai.piece-int     = 1
            cnumpiec.piece-compta = cnumpiec.piece-compta + 1
            cecrsai.piece-compta  = cnumpiec.piece-compta
        .
    end.

end procedure.

procedure ligne-generale private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piMdt        as integer.
    define input parameter plSns-in     as logical.
    define input parameter pcCol-in     as character.
    define input parameter pcCpt-in     as character.
    define input parameter pcLib-in     as character.
    define input parameter piMt-in      as decimal.
    define input parameter pcZone1-in   as character.
    define input parameter pcSsColl-in  as character.
    define input parameter pcFournCptCd as character.
    define input parameter pcRubana     as character.

    define buffer csscpt    for csscpt.
    define buffer ccpt      for ccpt.
    define buffer cecrln    for cecrln.
    define buffer cecrlnana for cecrlnana.
    define buffer biprd     for iprd.

    if pcCol-in <> ""
    then do :
        find first csscpt no-lock
             where csscpt.soc-cd     = giSociete
               and csscpt.etab-cd    = piMdt
               and csscpt.sscoll-cle = pcCol-in
               and csscpt.cpt-cd     = pcCpt-in no-error.
        find first ccptcol no-lock
             where ccptcol.soc-cd   = giSociete
               and ccptcol.coll-cle = csscpt.coll-cle no-error.
    end.
    else find first ccpt no-lock
              where ccpt.soc-cd   = giSociete
                and ccpt.coll-cle = ""
                and ccpt.cpt-cd   = pcCpt-in no-error.
    find first biprd no-lock
         where biprd.soc-cd    = giSociete
           and biprd.etab-cd   = piMdt
           and biprd.dadebprd <= gdDaCompta
           and biprd.dafinprd >= gdDaCompta no-error.
    find first cecrsai exclusive-lock where rowid(cecrsai) = grRowidCecrsai no-error.
    giLig = giLig + 10.
    create cecrln.
    assign
        cecrln.soc-cd           = giSociete
        cecrln.etab-cd          = piMdt
        cecrln.jou-cd           = cecrsai.jou-cd
        cecrln.piece-int        = cecrsai.piece-int
        cecrln.sscoll-cle       = pcCol-in
        cecrln.cpt-cd           = pcCpt-in
        cecrln.lib              = pcLib-in
        cecrln.sens             = plSns-in
        cecrln.analytique       = (if available ccptcol
                                   then ccptcol.libimp-cd
                                   else ccpt.libimp-cd) = 1
        cecrln.type-cle         = cecrsai.type-cle
        cecrln.datecr           = cecrsai.daecr
        cecrln.prd-cd           = biprd.prd-cd
        cecrln.prd-num          = biprd.prd-num
        cecrln.lig              = giLig
        cecrln.dev-cd           = gcDevMdt
        cecrln.devetr-cd        = ""
        cecrln.mtdev            = 0
        cecrln.mt               = piMt-in
        cecrln.taux             = 0
        cecrln.coll-cle         = (if pcCol-in <> "" then csscpt.coll-cle else "")
        cecrln.paie-regl        = false
        cecrln.taxe-cd          = 0
        cecrln.tva-enc-deb      = false
        cecrln.dacompta         = cecrsai.dacompta
        cecrln.ref-num          = ""
        cecrln.flag-lettre      = false
        cecrln.daech            = ?
        cecrln.type-ecr         = 1
        cecrln.mandat-cd        = GiCodeEtab
        cecrln.mandat-prd-cd    = cecrsai.prd-cd
        cecrln.mandat-prd-num   = cecrsai.prd-num
        cecrln.fg-ana100        = (if cecrln.analytique then true else false)
        cecrln.lib-ecr[1]       = pcLib-in
        cecrln.profil-cd        = 21
        cecrln.zone1            = pcZone1-in
        cecrln.fourn-sscoll-cle = pcSsColl-in
        cecrln.fourn-cpt-cd     = pcFournCptCd
    .
    if cecrln.analytique
    then do:
        create cecrlnana.
        assign
            cecrlnana.soc-cd     = giSociete
            cecrlnana.etab-cd    = cecrln.etab-cd
            cecrlnana.jou-cd     = cecrln.jou-cd
            cecrlnana.prd-cd     = cecrln.prd-cd
            cecrlnana.prd-num    = cecrln.prd-num
            cecrlnana.piece-int  = cecrln.piece-int
            cecrlnana.type-cle   = cecrln.type-cle
            cecrlnana.lig        = cecrln.lig
            cecrlnana.pos        = 10
            cecrlnana.sscoll-cle = cecrln.sscoll-cle
            cecrlnana.cpt-cd     = cecrln.cpt-cd
            cecrlnana.dacompta   = cecrln.dacompta
            cecrlnana.datecr     = cecrln.datecr
            cecrlnana.sscoll-cle = cecrln.sscoll-cle
            cecrlnana.lib        = cecrln.lib
            cecrlnana.lib-ecr[1] = cecrln.lib-ecr[1]
            cecrlnana.lib-ecr[2] = cecrln.lib-ecr[2]
            cecrlnana.taxe-cd    = cecrln.taxe-cd
            cecrlnana.dev-cd     = cecrln.dev-cd
            cecrlnana.devetr-cd  = cecrln.devetr-cd
            cecrlnana.typeventil = false
            cecrlnana.ana1-cd    = entry(1,pcRubana,"|")
            cecrlnana.ana2-cd    = entry(2,pcRubana,"|")
            cecrlnana.ana3-cd    = entry(3,pcRubana,"|")
            cecrlnana.ana4-cd    = ""
            cecrlnana.budg-cd    = 0
            cecrlnana.sens       = cecrln.sens
            cecrlnana.mt         = cecrln.mt
            cecrlnana.mttva      = cecrln.mttva
            cecrlnana.ana-cd     = cecrlnana.ana1-cd +
                                              cecrlnana.ana2-cd +
                                              cecrlnana.ana3-cd +
                                              cecrlnana.ana4-cd
            cecrlnana.pourc      = 100
        .
    end. /* cecrln.analytique */
    find first ttCpt
         where ttCpt.cpt-cd     = cecrln.cpt-cd
           and ttCpt.sscoll-cle = cecrln.sscoll-cle
           and ttCpt.etab-cd    = cecrln.etab-cd no-error.
    if not available ttCpt
    then do :
        create ttCpt.
        assign
            ttCpt.sscoll-cle = cecrln.sscoll-cle
            ttCpt.coll-cle   = cecrln.coll-cle
            ttCpt.cpt-cd     = cecrln.cpt-cd
            ttCpt.etab-cd    = cecrln.etab-cd
        .
    end.

end procedure. /* PROCEDURE ligne-generale : */

procedure ligne-dup :
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piMdt       as integer.
    define input parameter pcCol-in     as character.
    define input parameter pcCpt-in     as character.
    define input parameter prb2crln    as rowid.

    define variable viNum-int as integer no-undo.

    define buffer b2crln     for cecrln.
    define buffer cecrsai    for cecrsai.
    define buffer iprd      for iprd.
    define buffer vbiprd      for iprd.
    define buffer cecrlnana  for cecrlnana.
    define buffer vbcecrlnana for cecrlnana.
    define buffer aecrdtva   for aecrdtva.
    define buffer vbaecrdtva  for aecrdtva.
    define buffer aecrdet    for aecrdet.
    define buffer vbaecrdet   for aecrdet.
    define buffer adbtva     for adbtva.
    define buffer vbadbtva    for adbtva.
    define buffer aligtva    for aligtva.
    define buffer vbaligtva   for aligtva.
    define buffer cecrln     for cecrln.

    find first b2crln no-lock where rowid(b2crln) = prb2crln no-error.
    find first cecrsai no-lock where rowid(cecrsai) = grRowidCecrsai no-error.
    if not available b2crln or not available cecrsai then return.
    /* période ancien mandat */
    find first iprd no-lock
         where iprd.soc-cd    = giSociete
           and iprd.etab-cd   = b2crln.etab-cd
           and iprd.dadebprd <= gdDaCompta
           and iprd.dafinprd >= gdDaCompta no-error.
    /* période nouveau mandat */
    find first vbiprd no-lock
         where vbiprd.soc-cd    = giSociete
           and vbiprd.etab-cd   = piMdt
           and vbiprd.dadebprd <= gdDaCompta
           and vbiprd.dafinprd >= gdDaCompta no-error.
    if giLig = 0 then giLig = 10.
                else giLig = giLig + 20.
    /* Analytique lié */
    for each cecrlnana no-lock
          of b2crln:
        /* ancien mandat */
        create vbcecrlnana.
        buffer-copy cecrlnana to vbcecrlnana
        assign
            vbcecrlnana.jou-cd         = cecrsai.jou-cd
            vbcecrlnana.piece-int      = cecrsai.piece-int
            vbcecrlnana.prd-cd         = iprd.prd-cd
            vbcecrlnana.prd-num        = iprd.prd-num
            vbcecrlnana.lig            = giLig
            vbcecrlnana.sens           = not cecrlnana.sens
            vbcecrlnana.dacompta       = cecrsai.dacompta
            vbcecrlnana.datecr         = cecrsai.daecr
            vbcecrlnana.type-cle       = cecrsai.type-cle
            vbcecrlnana.lib-ecr[1]     = "MUT. " + cecrlnana.lib-ecr[1]
            vbcecrlnana.lib            = "MUT. " + cecrlnana.lib
        .

        /* nouveau mandat */
        create vbcecrlnana.
        buffer-copy cecrlnana to vbcecrlnana
        assign
            vbcecrlnana.etab-cd        = piMdt
            vbcecrlnana.jou-cd         = cecrsai.jou-cd
            vbcecrlnana.piece-int      = cecrsai.piece-int
            vbcecrlnana.prd-cd         = vbiprd.prd-cd
            vbcecrlnana.prd-num        = vbiprd.prd-num
            vbcecrlnana.lig            = giLig + 10
            vbcecrlnana.sens           = cecrlnana.sens
            vbcecrlnana.dacompta       = cecrsai.dacompta
            vbcecrlnana.datecr         = cecrsai.daecr
            vbcecrlnana.sscoll-cle     = pcCol-in
            vbcecrlnana.cpt-cd         = pcCpt-in
            vbcecrlnana.type-cle       = cecrsai.type-cle
            vbcecrlnana.lib-ecr[1]     = cecrlnana.lib-ecr[1]
            vbcecrlnana.lib            = cecrlnana.lib
        .
    end.

    for each aecrdtva no-lock
          of b2crln:
        /* ancien mandat */
        create vbaecrdtva.
        buffer-copy aecrdtva to vbaecrdtva
        assign
            vbaecrdtva.jou-cd      = cecrsai.jou-cd
            vbaecrdtva.prd-cd      = iprd.prd-cd
            vbaecrdtva.prd-num     = iprd.prd-num
            vbaecrdtva.piece-int   = cecrsai.piece-int
            vbaecrdtva.lig         = giLig

            vbaecrdtva.mtht        = - aecrdtva.mtht
            vbaecrdtva.mttva       = - aecrdtva.mttva
        .
        /* nouveau mandat */
        create vbaecrdtva.
        buffer-copy aecrdtva to vbaecrdtva
        assign
            vbaecrdtva.etab-cd     = piMdt
            vbaecrdtva.jou-cd      = cecrsai.jou-cd
            vbaecrdtva.prd-cd      = vbiprd.prd-cd
            vbaecrdtva.prd-num     = vbiprd.prd-num
            vbaecrdtva.piece-int   = cecrsai.piece-int
            vbaecrdtva.lig         = giLig + 10
        .
    end.
    for each aecrdet no-lock
          of cecrln:
        /* ancien mandat */
        create vbaecrdet.
        buffer-copy aecrdet to vbaecrdet
        assign
            vbaecrdet.jou-cd      = cecrsai.jou-cd
            vbaecrdet.prd-cd      = iprd.prd-cd
            vbaecrdet.prd-num     = iprd.prd-num
            vbaecrdet.piece-int   = cecrsai.piece-int
            vbaecrdet.lig         = giLig
            vbaecrdet.mt          = - aecrdet.mt
        .
        /* nouveau mandat */
        create vbaecrdet.
        buffer-copy aecrdet to vbaecrdet
        assign
            vbaecrdet.etab-cd   = piMdt
            vbaecrdet.jou-cd    = cecrsai.jou-cd
            vbaecrdet.prd-cd    = vbiprd.prd-cd
            vbaecrdet.prd-num   = vbiprd.prd-num
            vbaecrdet.piece-int = cecrsai.piece-int
            vbaecrdet.lig       = giLig + 10
        .
    end.
    for each adbtva no-lock
          of cecrln:
        run NumAdbTva(input b2crln.etab-cd, output viNum-int).
        /* Ancien Mandat */
        for each aligtva no-lock
              of adbtva:
            create vbaligtva.
            buffer-copy aligtva to vbaligtva
            assign
                vbaligtva.num-int = viNum-int
                vbaligtva.mtht    = - aligtva.mtht
                vbaligtva.mttva   = - aligtva.mttva
            .
        end.
        create vbadbtva.
        buffer-copy adbtva to vbadbtva
        assign
            vbadbtva.jou-cd      = cecrsai.jou-cd
            vbadbtva.prd-cd      = iprd.prd-cd
            vbadbtva.prd-num     = iprd.prd-num
            vbadbtva.piece-int   = cecrsai.piece-int
            vbadbtva.lig         = giLig
            vbadbtva.num-int     = viNum-int
            vbadbtva.mt          = - adbtva.mt
        .
        /* Nouveau Mandat */
        run NumAdbTva(input piMdt, output viNum-int).
        for each aligtva no-lock
              of adbtva:
            create vbaligtva.
            buffer-copy aligtva to vbaligtva
            assign
                vbaligtva.etab-cd = piMdt
                vbaligtva.num-int = viNum-int
            .
        end.
        create vbadbtva.
        buffer-copy adbtva to vbadbtva
        assign
            vbadbtva.etab-cd     = cecrsai.etab-cd
            vbadbtva.jou-cd      = cecrsai.jou-cd
            vbadbtva.prd-cd      = vbiprd.prd-cd
            vbadbtva.prd-num     = vbiprd.prd-num
            vbadbtva.piece-int   = cecrsai.piece-int
            vbadbtva.lig         = giLig + 10
            vbadbtva.num-int     = viNum-int
        .
    end.
    /* ancien mandat */
    create cecrln.
    buffer-copy b2crln to cecrln
    assign
        cecrln.jou-cd           = cecrsai.jou-cd
        cecrln.prd-cd           = iprd.prd-cd
        cecrln.prd-num          = iprd.prd-num
        cecrln.mandat-cd        = cecrsai.etab-cd
        cecrln.mandat-prd-cd    = cecrsai.prd-cd
        cecrln.mandat-prd-num   = cecrsai.prd-num
        cecrln.piece-int        = cecrsai.piece-int
        cecrln.lig              = giLig
        cecrln.sens             = not b2crln.sens
        cecrln.dacompta         = cecrsai.dacompta
        cecrln.datecr           = cecrsai.daecr
        cecrln.type-cle         = cecrsai.type-cle
        cecrln.lib-ecr[1]       = "MUT. " + b2crln.lib-ecr[1]
        cecrln.lib              = "MUT. " + b2crln.lib
        cecrln.dalettrage       = ?
        cecrln.lettre           = ""
        cecrln.flag-let         = false
        cecrln.fg-sci           = false
        cecrln.fg-reac          = false
        cecrln.daaff            = ?
        cecrln.num-crg          = ?
    .
    find first ttCpt
         where ttCpt.cpt-cd     = cecrln.cpt-cd
           and ttCpt.sscoll-cle = cecrln.sscoll-cle
           and ttCpt.etab-cd    = cecrln.etab-cd no-error.
    if not available ttCpt
    then do:
        create ttCpt.
        assign
            ttCpt.sscoll-cle = cecrln.sscoll-cle
            ttCpt.coll-cle   = cecrln.coll-cle
            ttCpt.cpt-cd     = cecrln.cpt-cd
            ttCpt.etab-cd    = cecrln.etab-cd
        .
    end.
    /* nouveau mandat */
    create cecrln.
    buffer-copy b2crln to cecrln
    assign
        cecrln.etab-cd          = piMdt
        cecrln.jou-cd           = cecrsai.jou-cd
        cecrln.prd-cd           = vbiprd.prd-cd
        cecrln.prd-num          = vbiprd.prd-num
        cecrln.mandat-cd        = cecrsai.etab-cd
        cecrln.mandat-prd-cd    = cecrsai.prd-cd
        cecrln.mandat-prd-num   = cecrsai.prd-num
        cecrln.piece-int        = cecrsai.piece-int
        cecrln.lig              = giLig + 10
        cecrln.sens             = b2crln.sens
        cecrln.dacompta         = cecrsai.dacompta
        cecrln.datecr           = cecrsai.daecr
        cecrln.sscoll-cle       = pcCol-in
        cecrln.cpt-cd           = pcCpt-in
        cecrln.type-cle         = cecrsai.type-cle
        cecrln.lib-ecr[1]       = b2crln.lib-ecr[1]
        cecrln.lib              = b2crln.lib
        cecrln.dalettrage       = ?
        cecrln.lettre           = ""
        cecrln.flag-let         = false
        cecrln.fg-sci           = false
        cecrln.fg-reac          = false
        cecrln.daaff            = ?
        cecrln.num-crg          = ?
    .
    find first ttCpt
         where ttCpt.cpt-cd     = cecrln.cpt-cd
           and ttCpt.sscoll-cle = cecrln.sscoll-cle
           and ttCpt.etab-cd    = cecrln.etab-cd no-error.
    if not available ttCpt
    then do:
        create ttCpt.
        assign
            ttCpt.sscoll-cle = cecrln.sscoll-cle
            ttCpt.coll-cle   = cecrln.coll-cle
            ttCpt.cpt-cd     = cecrln.cpt-cd
            ttCpt.etab-cd    = cecrln.etab-cd
        .
    end.
end procedure.

procedure effaparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer aparm for aparm.

    find first aparm exclusive-lock
         where aparm.tppar = "BALANCE"
           and aparm.cdpar = string(grRowidCecrsai)
           and aparm.soc-cd = giSociete no-error.
    if not available aparm
    then do:
        create aparm.
        assign
            aparm.tppar  = "BALANCE"
            aparm.cdpar  = string(grRowidCecrsai)
            aparm.soc-cd = giSociete
            aparm.lib    = "INTERRUPTION DE LA BALANCE"
        .
    end.
    if available aparm then delete aparm. /* PS LE 19/09/00 */

end procedure.

procedure SoldeCpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  piMdt       as integer   no-undo.
    define input parameter  cSscoll-cle as character no-undo.
    define input parameter  cCpt-cd     as character no-undo.
    define input parameter  jDate       as date      no-undo.
    define output parameter dSolde      as decimal   no-undo.

    define variable voCollection    as collection no-undo.

    find first csscptcol no-lock
         where csscptcol.soc-cd     = giSociete
           and csscptcol.etab-cd    = piMdt
           and csscptcol.sscoll-cle = cSscoll-cle no-error.
    if not available csscptcol
    then return.
    voCollection = new collection().
    voCollection:set('iNumeroSociete'     , giSociete).
    voCollection:set('iNumeroMandat'      , piMdt).
    voCollection:set('cCodeCollectif'     , cSscoll-cle).
    voCollection:set('cNumeroCompte'      , cCpt-cd).
    voCollection:set('iNumeroDossier'     , 0).
    voCollection:set('lAvecExtraComptable', false).
    voCollection:set('daDateSolde'        , jDate).
    voCollection:set('cNumeroDocument'    , '').
    run compta/calculeSolde.p(input-output voCollection).
    dSolde = voCollection:getDecimal('dSoldeCompte').
    delete object voCollection.

end procedure.

procedure comptabilisation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer cecrsai for cecrsai.

    find first cecrsai exclusive-lock where rowid(cecrsai) = grRowidCecrsai .
    if not can-find(first cecrln no-lock
                    where cecrln.soc-cd         = cecrsai.soc-cd
                      and cecrln.mandat-cd      = cecrsai.etab-cd
                      and cecrln.jou-cd         = cecrsai.jou-cd
                      and cecrln.mandat-prd-cd  = cecrsai.prd-cd
                      and cecrln.mandat-prd-num = cecrsai.prd-num
                      and cecrln.piece-int      = cecrsai.piece-int)
    then do:
        delete cecrsai.
    end.
    else do:
        run compta/souspgm/cptmvt.p persistent set ghProc.
        run getTokenInstance in ghProc(mToken:JSessionId).
        run cptmvtMajMvtCpt in ghProc (grRowidCecrsai).
        run destroy in ghProc.
        run effaparm.
        cecrsai.mtdev = 0.
    end.
end procedure.

procedure lettrage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ietab for ietab.
    define buffer ccpt  for ccpt.

    for each ttCpt
    , first ietab no-lock
      where ietab.soc-cd  = giSociete
        and ietab.etab-cd = ttCpt.etab-cd
    , first ccpt no-lock
      where ccpt.soc-cd   = giSociete
        and ccpt.coll-cle = ttCpt.coll-cle
        and ccpt.cpt-cd   = ttCpt.cpt-cd:
        if ccpt.libtype-cd = 1
        then run faletaut (buffer ccpt, ttCpt.etab-cd, true, ttCpt.sscoll-cle, if ietab.exercice then ietab.dadebex2 else ietab.dadebex1, ietab.dafinex2).
    end.

end procedure.

procedure NumAdbTva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piMandat as integer no-undo.
    define output parameter piNumero as integer no-undo.

    define buffer adbtva for adbtva.

    piNumero = 1.
    find last adbtva exclusive-lock
        where adbtva.soc-cd  = giSociete
          and adbtva.etab-cd = piMandat no-error no-wait.
    if available adbtva then piNumero = adbtva.num-int + 1.

end procedure.

procedure Ligne-dup2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piMdt    as integer.
    define input parameter pcCol-in as character.
    define input parameter pcCpt-in as character.
    define input parameter plsens   as logical.   /* TRUE=Conservation du sens / FALSE=sens opposé */
    define input parameter prb2crln as rowid.

    define variable viNum-int       as integer   no-undo.
    define variable viPos   as integer no-undo.
    define variable vdMtTVA as decimal no-undo.

    define buffer b2crln     for cecrln.
    define buffer b3crln     for cecrln.
    define buffer biprd      for iprd.
    define buffer cecrlnana for cecrlnana.
    define buffer vbcecrlnana for cecrlnana.
    define buffer aecrdtva for aecrdtva.
    define buffer vbaecrdtva  for aecrdtva.
    define buffer aecrdet for aecrdet.
    define buffer vbaecrdet   for aecrdet.
    define buffer aligtva for aligtva.
    define buffer vbaligtva   for aligtva.
    define buffer adbtva for adbtva.
    define buffer vbadbtva    for adbtva.
    define buffer itaxe for itaxe.
    define buffer cecrsai for cecrsai.

    find first b2crln no-lock where rowid(b2crln) = prb2crln no-error.
    find first cecrsai no-lock where rowid(cecrsai) = grRowidCecrsai no-error.
    find first b3crln no-lock
         where b3crln.soc-cd     = b2crln.soc-cd
           and b3crln.etab-cd    = b2crln.etab-cd
           and b3crln.jou-cd     = b2crln.jou-cd
           and b3crln.prd-cd     = b2crln.prd-cd
           and b3crln.prd-num    = b2crln.prd-num
           and b3crln.piece-int  = b2crln.piece-int
           and b3crln.sscoll-cle = "M" no-error.
    if not available b2crln or not available b3crln or not available cecrsai then return.
    /* période du mandat */
    find first biprd no-lock
         where biprd.soc-cd   = giSociete
           and biprd.etab-cd  = piMdt
           and biprd.dadebprd <= gdDaCompta
           and biprd.dafinprd >= gdDaCompta no-error.
    /*** --- *** LIGNE LOCATAIRE *** --- ***/
    giLig = giLig + 10.
    /* Analytique lié */
    for each cecrlnana no-lock of b2crln:
        create vbcecrlnana.
        buffer-copy cecrlnana to vbcecrlnana
        assign
            vbcecrlnana.etab-cd        = piMdt
            vbcecrlnana.jou-cd         = cecrsai.jou-cd
            vbcecrlnana.piece-int      = cecrsai.piece-int
            vbcecrlnana.prd-cd         = biprd.prd-cd
            vbcecrlnana.prd-num        = biprd.prd-num
            vbcecrlnana.lig            = giLig
            vbcecrlnana.sens           = (if plsens then cecrlnana.sens else not cecrlnana.sens)
            vbcecrlnana.dacompta       = cecrsai.dacompta
            vbcecrlnana.datecr         = cecrsai.daecr
            vbcecrlnana.type-cle       = cecrsai.type-cle
            vbcecrlnana.lib-ecr[1]     = (if plsens then "" else "MUT. ") + cecrlnana.lib-ecr[1]
            vbcecrlnana.lib            = (if plsens then "" else "MUT. ") + cecrlnana.lib
            vbcecrlnana.sscoll-cle     = pcCol-in
            vbcecrlnana.cpt-cd         = pcCpt-in
        .
    end.
    for each aecrdtva no-lock of b2crln:
        create vbaecrdtva.
        buffer-copy aecrdtva to vbaecrdtva
        assign
            vbaecrdtva.etab-cd     = piMdt
            vbaecrdtva.jou-cd      = cecrsai.jou-cd
            vbaecrdtva.prd-cd      = biprd.prd-cd
            vbaecrdtva.prd-num     = biprd.prd-num
            vbaecrdtva.piece-int   = cecrsai.piece-int
            vbaecrdtva.lig         = giLig
            vbaecrdtva.mtht        = aecrdtva.mtht  * (if plsens then 1 else -1)
            vbaecrdtva.mttva       = aecrdtva.mttva * (if plsens then 1 else -1)
        .
    end.
    for each aecrdet no-lock of cecrln:
        create vbaecrdet.
        buffer-copy aecrdet to vbaecrdet
        assign
            vbaecrdet.etab-cd   = piMdt
            vbaecrdet.jou-cd    = cecrsai.jou-cd
            vbaecrdet.prd-cd    = biprd.prd-cd
            vbaecrdet.prd-num   = biprd.prd-num
            vbaecrdet.piece-int = cecrsai.piece-int
            vbaecrdet.lig       = giLig
            vbaecrdet.mt        = aecrdet.mt * (if plsens then 1 else -1)
        .
    end.
    for each adbtva no-lock of cecrln :
        run NumAdbTva(input piMdt, output viNum-int).
        for each aligtva no-lock of adbtva:
            create vbaligtva.
            buffer-copy aligtva to vbaligtva
            assign
                vbaligtva.etab-cd = piMdt
                vbaligtva.num-int = viNum-int
                vbaligtva.mtht    = aligtva.mtht  * (if plsens then 1 else -1)
                vbaligtva.mttva   = aligtva.mttva * (if plsens then 1 else -1)
            .
        end.
        create vbadbtva.
        buffer-copy adbtva to vbadbtva
        assign
            vbadbtva.etab-cd     = cecrsai.etab-cd
            vbadbtva.jou-cd      = cecrsai.jou-cd
            vbadbtva.prd-cd      = biprd.prd-cd
            vbadbtva.prd-num     = biprd.prd-num
            vbadbtva.piece-int   = cecrsai.piece-int
            vbadbtva.lig         = giLig
            vbadbtva.num-int     = viNum-int
            vbadbtva.mt          = adbtva.mt * (if plsens then 1 else -1)
        .
    end.
    create cecrln.
    buffer-copy b2crln to cecrln
    assign
        cecrln.etab-cd          = piMdt
        cecrln.jou-cd           = cecrsai.jou-cd
        cecrln.prd-cd           = biprd.prd-cd
        cecrln.prd-num          = biprd.prd-num
        cecrln.mandat-cd        = cecrsai.etab-cd
        cecrln.mandat-prd-cd    = cecrsai.prd-cd
        cecrln.mandat-prd-num   = cecrsai.prd-num
        cecrln.piece-int        = cecrsai.piece-int
        cecrln.lig              = giLig
        cecrln.sens             = (if plsens then b2crln.sens else not b2crln.sens)
        cecrln.dacompta         = cecrsai.dacompta
        cecrln.datecr           = cecrsai.daecr
        cecrln.sscoll-cle       = pcCol-in
        cecrln.cpt-cd           = pcCpt-in
        cecrln.type-cle         = cecrsai.type-cle
        cecrln.lib-ecr[1]       = (if plsens then "" else "MUT. ") + b2crln.lib-ecr[1]
        cecrln.lib              = (if plsens then "" else "MUT. ") + b2crln.lib
        cecrln.dalettrage       = ?
        cecrln.lettre           = ""
        cecrln.flag-let         = false
        cecrln.fg-sci           = false
        cecrln.fg-reac          = false
        cecrln.daaff            = ?
        cecrln.num-crg          = ?
        cecrln.profil-cd        = cecrsai.profil-cd
    .
    find first ttCpt
         where ttCpt.cpt-cd     = cecrln.cpt-cd
           and ttCpt.sscoll-cle = cecrln.sscoll-cle
           and ttCpt.etab-cd    = cecrln.etab-cd no-error.
    if not available ttCpt
    then do :
        create ttCpt.
        assign
            ttCpt.sscoll-cle = cecrln.sscoll-cle
            ttCpt.coll-cle   = cecrln.coll-cle
            ttCpt.cpt-cd     = cecrln.cpt-cd
            ttCpt.etab-cd    = cecrln.etab-cd
        .
    end.
    /*** --- ***   LIGNE AU MANDAT   *** --- ***/
    assign
        giLig    = giLig + 10
        vdMtTVA = 0
    .
    find first cecrlnana no-lock of b3crln no-error.
    /* Recréation des lignes analytiques avec rub de quitt */
    for each aecrdtva no-lock of b2crln
    break by aecrdtva.taux
          by aecrdtva.cat-cd
          by aecrdtva.cdrub:
        vdMtTVA = vdMtTVA + aecrdtva.mttva.
        if first-of(aecrdtva.taux)
        then do:
            viPos = viPos + 10.
            find first tmp-rubqt no-lock
                 where tmp-rubqt.rubqt-cd   = string(aecrdtva.cdrub,"999")
                   and tmp-rubqt.ssrubqt-cd = string(aecrdtva.cdlib,"99") no-error.
            find first itaxe no-lock
                 where itaxe.soc-cd = giSociete
                   and itaxe.taux   = aecrdtva.taux no-error.
            create vbcecrlnana.
            assign
                vbcecrlnana.soc-cd    = cecrsai.soc-cd
                vbcecrlnana.etab-cd   = cecrsai.etab-cd
                vbcecrlnana.jou-cd    = cecrsai.jou-cd
                vbcecrlnana.prd-cd    = biprd.prd-cd
                vbcecrlnana.prd-num   = biprd.prd-num
                vbcecrlnana.type-cle  = cecrsai.type-cle
                vbcecrlnana.doss-num  = ""
                vbcecrlnana.datecr    = cecrsai.daecr
                vbcecrlnana.cpt-cd    = "00000"
                vbcecrlnana.ana1-cd   = (if available tmp-rubqt then tmp-rubqt.ana1-cd else "")
                vbcecrlnana.ana2-cd   = (if available tmp-rubqt then tmp-rubqt.ana2-cd else "")
                vbcecrlnana.ana3-cd   = (if available tmp-rubqt then tmp-rubqt.ana3-cd else "")
                vbcecrlnana.ana4-cd   = ""
                vbcecrlnana.sens      = (if not plsens then b2crln.sens else not b2crln.sens)
                vbcecrlnana.mt        = aecrdtva.mtht + aecrdtva.mttva
                vbcecrlnana.pourc     = 0
                vbcecrlnana.report-cd = 0
                vbcecrlnana.budg-cd   = 1
                vbcecrlnana.lig       = giLig
                vbcecrlnana.pos       = viPos
                vbcecrlnana.piece-int = cecrsai.piece-int
            .
            assign
                vbcecrlnana.ana-cd     = vbcecrlnana.ana1-cd +
                                        vbcecrlnana.ana2-cd +
                                        vbcecrlnana.ana3-cd +
                                        vbcecrlnana.ana4-cd
                vbcecrlnana.typeventil = true
                vbcecrlnana.sscoll-cle = "M"
                vbcecrlnana.dacompta   = cecrsai.dacompta
                vbcecrlnana.dev-cd     = cecrsai.dev-cd
                vbcecrlnana.taxe-cd    = (if available itaxe then itaxe.taxe-cd else 0)
                vbcecrlnana.analytique = true
                vbcecrlnana.mtdev      = 0
                vbcecrlnana.devetr-cd  = ""
                vbcecrlnana.affair-num = 0
                vbcecrlnana.tva-cd     = (if available itaxe then itaxe.taxe-cd else 0)
                vbcecrlnana.mttva      = aecrdtva.mttva
                vbcecrlnana.taux-cle   = 0
                vbcecrlnana.tantieme   = 0
                vbcecrlnana.mttva-dev  = 0
                vbcecrlnana.lib-ecr[1] = (if plsens or cecrlnana.lib-ecr[1] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[1]
                vbcecrlnana.lib-ecr[2] = (if plsens or cecrlnana.lib-ecr[2] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[2]
                vbcecrlnana.lib-ecr[3] = (if plsens or cecrlnana.lib-ecr[3] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[3]
                vbcecrlnana.lib-ecr[4] = (if plsens or cecrlnana.lib-ecr[4] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[4]
                vbcecrlnana.lib-ecr[5] = (if plsens or cecrlnana.lib-ecr[5] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[5]
                vbcecrlnana.lib-ecr[6] = (if plsens or cecrlnana.lib-ecr[6] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[6]
                vbcecrlnana.lib-ecr[7] = (if plsens or cecrlnana.lib-ecr[7] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[7]
                vbcecrlnana.lib-ecr[8] = (if plsens or cecrlnana.lib-ecr[8] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[8]
                vbcecrlnana.lib-ecr[9] = (if plsens or cecrlnana.lib-ecr[9] = "" then "" else "MUT. ") + cecrlnana.lib-ecr[9]
                vbcecrlnana.lib        = cecrlnana.lib-ecr[1]
                vbcecrlnana.regrp      = ""
            .
        end.
        else assign
                 vbcecrlnana.mt    = vbcecrlnana.mt    + aecrdtva.mtht + aecrdtva.mttva
                 vbcecrlnana.mttva = vbcecrlnana.mttva + aecrdtva.mttva
        .
    end.
    create cecrln.
    buffer-copy b2crln to cecrln
    assign
        cecrln.etab-cd          = piMdt
        cecrln.jou-cd           = cecrsai.jou-cd
        cecrln.prd-cd           = biprd.prd-cd
        cecrln.prd-num          = biprd.prd-num
        cecrln.mandat-cd        = cecrsai.etab-cd
        cecrln.mandat-prd-cd    = cecrsai.prd-cd
        cecrln.mandat-prd-num   = cecrsai.prd-num
        cecrln.piece-int        = cecrsai.piece-int
        cecrln.lig              = giLig
        cecrln.sens             = (if not plsens then b2crln.sens else not b2crln.sens)
        cecrln.dacompta         = cecrsai.dacompta
        cecrln.datecr           = cecrsai.daecr
        cecrln.coll-cle         = "M"
        cecrln.sscoll-cle       = "M"
        cecrln.cpt-cd           = "00000"
        cecrln.mttva            = vdMtTVA
        cecrln.type-cle         = cecrsai.type-cle
        cecrln.lib-ecr[1]       = (if plsens or b3crln.lib-ecr[1] = "" then "" else "MUT. ") + b3crln.lib-ecr[1]
        cecrln.lib-ecr[2]       = (if plsens or b3crln.lib-ecr[2] = "" then "" else "MUT. ") + b3crln.lib-ecr[2]
        cecrln.lib-ecr[3]       = (if plsens or b3crln.lib-ecr[3] = "" then "" else "MUT. ") + b3crln.lib-ecr[3]
        cecrln.lib-ecr[4]       = (if plsens or b3crln.lib-ecr[4] = "" then "" else "MUT. ") + b3crln.lib-ecr[4]
        cecrln.lib-ecr[5]       = (if plsens or b3crln.lib-ecr[5] = "" then "" else "MUT. ") + b3crln.lib-ecr[5]
        cecrln.lib-ecr[6]       = (if plsens or b3crln.lib-ecr[6] = "" then "" else "MUT. ") + b3crln.lib-ecr[6]
        cecrln.lib-ecr[7]       = (if plsens or b3crln.lib-ecr[7] = "" then "" else "MUT. ") + b3crln.lib-ecr[7]
        cecrln.lib-ecr[8]       = (if plsens or b3crln.lib-ecr[8] = "" then "" else "MUT. ") + b3crln.lib-ecr[8]
        cecrln.lib-ecr[9]       = (if plsens or b3crln.lib-ecr[9] = "" then "" else "MUT. ") + b3crln.lib-ecr[9]
        cecrln.lib              = (if plsens or b3crln.lib = "" then "" else "MUT. ") + b3crln.lib
        cecrln.dalettrage       = ?
        cecrln.lettre           = ""
        cecrln.flag-let         = false
        cecrln.fg-sci           = false
        cecrln.fg-reac          = false
        cecrln.daaff            = ?
        cecrln.num-crg          = ?
        cecrln.analytique       = true
        cecrln.fg-ana100        = (viPos = 10)
        cecrln.profil-cd        = cecrsai.profil-cd
    .

end procedure.

procedure CreRubQt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter iLoc as integer no-undo. /* integer(string(iftsai.etab-cd) + iftsai.sscptg-cd) */

    empty temp-table tmp-rubqt.

/*gga todo a reprendre plus tard pour creation de la table tmp-rubqt pour le moment pas moyen de tester
  {comm/appelspe.i RpRunFdiv "tfacRbQt.r" "iLoc"
                                          "string(iMoisUse)"}
gga*/

end procedure.

