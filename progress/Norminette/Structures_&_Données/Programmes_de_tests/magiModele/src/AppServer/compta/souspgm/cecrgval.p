/*------------------------------------------------------------------------
File        : cecrgval.p
Purpose     : Validation globale des écritures OD et Achats
Author(s)   : OF - 1997/05/27;  gga -  2017/04/07
Notes       : reprise du pgm cadb\src\batch\cecrgval.p
    PROGRAMME DUPLIQUE EN CECRGVA2.P
    TOUTE MODIFICATION DANS L'UN DOIT ETRE REPORTEE DANS L'AUTRE
01  |  15/06/98  | OF | Dans le cas des OD on n'ecrase pas les dates de document et d'echeance par celles de la piece                                        |
02  |  30/12/98  | OF | Mise a jour du flag 100% analytique de cecrln (Fiche T98121693)
03  |  10/08/99  | OF | Remplacement des ".asg" par des BUFFER-COPY, et Ajout de la fenetre d'evolution "attente.w"
04  |  27/12/99  | MG | Fiche 3703 cecrlnana.taxe-cd non renseigné dans écritures Achats, OD, AN crées par scen.
05  |  26/04/00  | JR | Fiche : 5061 / patch 7.3.05
06  |  23/05/00  | OF | La piece n'est plus supprimee puis recrée pour pouvoir gerer les plantages
07  |  17/07/00  | CC | Suppression des cantva
08  |  19/09/00  | OF | Dev 356: automatisme saisie DG
09  |  23/10/00  | PS | prise en compte de aligtva ( pour journal odt)
10  |  31/10/00  | MP | Annulation modif du 23/10, prise en compte de aligtva (pour journal ODT) dans cecrgva2.p
11  |  16/01/01  | OF | Ajout suppression des aecrdet
12  |  12/07/01  | DM | Triggers sur montants euro
13  |  06/05/02  | PS | 0301/0423 analytique mensuel
14  |  13/09/02  | OF | 0902/0120 On reporte le no doc, les dates d'écriture et echeance dans les lignes
15  |  21/01/03  | CC | Maj cecrln.analytique
16  |  18/04/05  | DM | 0405/0194 Pb delettrage
17  |  27/05/05  | DM | 0305/0251 - Modif type de mouvement
18  |  03/03/06  | OF | 0106/0457 Ne pas ecraser le code TVA des ecritures analytiques (pour les Garanties Loyers)
19  |  19/09/08  | DM | 0608/0065 : Mandat 5 chiffres
20  |  12/03/09  | DM | 0607/0250 Compensation locataire/proprietaire
21  |  17/03/11  | OF | 1210/0028 Ajout Utilisateur ds cecrsai.usrid des pièces issues de la facturation -> Modif majbap.i
22  |  19/01/12  | RF | 1211/0159 nature de scénarios dans les lignes
23  |  31/12/12  | OF | 1212/0222 Natscen à 0 suite modif précédente
24  |  18/01/13  | OF | 0113/0134 pour créer les paiements du FX/LF
25  |  18/02/14  | OF | 0114/0041 Suivi indemnités relatives à la GLI
26  |  03/06/14  | OF | Merge Carturis
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/flagLettre-cLettre-inumpiec.i}
{compta/include/tbcptaprov.i}
{compta/include/tbdelettrage.i}
{compta/include/tbtmpcana.i}
{compta/include/majbap.i}
{compta/include/cnummvt.i}

procedure cecrgvalValEcrOdAchat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé parcptagli.p et cptaprov.p
    ------------------------------------------------------------------------------*/
    define input-output parameter table for cecrsai-tmp.
    define input-output parameter table for cecrln-tmp.
    define input-output parameter table for cecrlnana-tmp.
    define input-output parameter table for aecrdtva-tmp.
    define input-output parameter table for ttDelettrage.
    define input        parameter piCodeSoc      as integer   no-undo.
    define input        parameter piCodeEtab     as integer   no-undo.
    define input-output parameter prRecnoSai     as rowid     no-undo.
    define input        parameter prRecnoSaiTmp  as rowid     no-undo.
    define input        parameter prRecnoCec     as rowid     no-undo.
    define input        parameter plExisteEnt    as logical   no-undo.
    define input        parameter pcTmpJouCd     as character no-undo.
    define input        parameter piTmpPrdCd     as integer   no-undo.
    define input        parameter piTmpPrdNum    as integer   no-undo.
    define input        parameter piTmpPieceInt  as integer   no-undo.
    define input        parameter piTmpPrdCdDeb  as integer   no-undo.
    define input        parameter piTmpPrdCdFin  as integer   no-undo.
    define input        parameter pcTmpFperiod   as character no-undo.

    define variable vcTypeCle as character no-undo.
    define variable vcUsrId   as character no-undo.
    define variable vlFgGLI   as logical   no-undo.
    define variable viNature  as integer   no-undo.
    define variable vhProc    as handle    no-undo.
    define variable vlCompare as logical   no-undo. /* variable precisant si le tracage doit etre realisé */

    define buffer ilibnatjou for ilibnatjou.
    define buffer cecrsai    for cecrsai.
    define buffer iscensai   for iscensai.
    define buffer cecrln     for cecrln.
    define buffer cecrlnana  for cecrlnana.
    define buffer cblock     for cblock.
    define buffer aecrdtva   for aecrdtva.
    define buffer aecrdet    for aecrdet.
    define buffer adbtva     for adbtva.
    define buffer aligtva    for aligtva.
    define buffer csscpt     for csscpt.

    if plExisteEnt = true
    then do:
        {&_proparse_ prolint-nowarn(nowait)}
        find first cecrsai exclusive-lock where rowid(cecrsai) = prRecnoSai no-error.
        /**Modif OF le 23/05/00 : On ne supprime plus systematiquement la piece pour la recreer
            car sinon le Rowid change et on ne peut plus gerer les plantages **/
        /*     IF AVAILABLE cecrsai THEN DELETE cecrsai. */
        if not available cecrsai
        then create cecrsai.
    end.
    else create cecrsai.
    find first cecrsai-tmp where rowid(cecrsai-tmp) = prRecnoSaiTmp no-error.

    /* +================================================================================+
    ===| Creation automatique des ecritures de depot de garantie (Ajout OF le 19/09/00) |==================================
    +================================================================================+ */
    /*On cree les lignes seulement en creation d'une piece, pas en modif */
    if not plExisteEnt
    then do:
        run compta/souspgm/cecrdgr.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        {&_proparse_ prolint-nowarn(use-index)}
        for each cecrln-tmp
            where cecrln-tmp.soc-cd         = cecrsai-tmp.soc-cd
              and cecrln-tmp.mandat-cd      = cecrsai-tmp.etab-cd
              and cecrln-tmp.jou-cd         = cecrsai-tmp.jou-cd
              and cecrln-tmp.mandat-prd-cd  = cecrsai-tmp.prd-cd
              and cecrln-tmp.mandat-prd-num = cecrsai-tmp.prd-num
              and cecrln-tmp.piece-int      = cecrsai-tmp.piece-int
              and cecrln-tmp.zone1          = "DGR0"
            use-index ecrln-mandat:
            run cecrdgrCreLgDepotGar in vhProc (rowid(cecrln-tmp), input-output table cecrln-tmp by-reference).
        end.
        run destroy in vhProc.
    end.

    find first ilibnatjou no-lock
        where ilibnatjou.soc-cd    = piCodeSoc
          and ilibnatjou.natjou-cd = cecrsai-tmp.natjou-cd no-error.
    assign
        prRecnoSai = rowid(cecrsai)
        vcTypeCle  = cecrsai.type-cle
        vcUsrId    = cecrsai.usrid
    .
    buffer-copy cecrsai-tmp to cecrsai.
        assign
            cecrsai.usrid = vcUsrId
            entry(1, cecrsai.usrid) = entry(1, cecrsai-tmp.usrid)     /* Id du User en modif */
    .
    if vcTypeCle > "" and vcTypeCle <> cecrsai-tmp.type-cle
    then cecrsai.usrid = cecrsai.usrid + ",Typ:" + vcTypeCle.
    if cecrsai.scen-cle > ""
    then do:
        find first iscensai no-lock
            where iscensai.soc-cd   = cecrsai.soc-cd
              and iscensai.etab-cd  = cecrsai.etab-cd
              and iscensai.jou-cd   = cecrsai.jou-cd
              and iscensai.type-cle = cecrsai.type-cle
              and iscensai.scen-cle = cecrsai.scen-cle no-error.
        if not available iscensai
        then find first iscensai no-lock
            where iscensai.soc-cd   = cecrsai.soc-cd
              and iscensai.etab-cd  = cecrsai.etab-cd
              and iscensai.jou-cd   = cecrsai.jou-cd
              and iscensai.scen-cle = cecrsai.scen-cle no-error.
        if available iscensai then viNature = iscensai.natscen-cd.
    end.

    vlCompare = cecrsai.dadoss <> ?.
    empty temp-table ttCompAna.

    /* Mise à jour des enregistrements de ttDelettrage suite à une modification d'une écriture lettrée.*/
    for each ttDelettrage
        where ttDelettrage.flag > "":
        for first cecrln no-lock
        where cecrln.soc-cd         = piCodeSoc
          and cecrln.etab-cd        = ttDelettrage.etab-cd
          and cecrln.jou-cd         = pcTmpJouCd
          and cecrln.mandat-prd-cd  = piTmpPrdCd
          and cecrln.mandat-prd-num = piTmpPrdNum
          and cecrln.piece-int      = piTmpPieceInt
          and cecrln.lig            = integer(ttDelettrage.flag):
            ttDelettrage.lettre = cecrln.lettre.
        end.
        if ttDelettrage.lettre = "" then delete ttDelettrage.
    end.

    for each ttDelettrage
        where ttDelettrage.flag = "":
        for first cecrln no-lock
            where rowid(cecrln) = prRecnoCec:
            ttDelettrage.lettre = cecrln.lettre.
        end.
        if ttDelettrage.lettre = ? or ttDelettrage.lettre = "" then delete ttDelettrage.
    end.

    for each cecrln exclusive-lock
        where cecrln.soc-cd         = cecrsai.soc-cd
          and cecrln.mandat-cd      = cecrsai.etab-cd
          and cecrln.jou-cd         = cecrsai.jou-cd
          and cecrln.mandat-prd-cd  = cecrsai.prd-cd
          and cecrln.mandat-prd-num = cecrsai.prd-num
          and cecrln.piece-int      = cecrsai.piece-int
          and not can-find(first cecrln-tmp
                       where cecrln-tmp.soc-cd    = piCodeSoc
                         and cecrln-tmp.etab-cd   = cecrln.etab-cd
                         and cecrln-tmp.jou-cd    = cecrln.jou-cd
                         and cecrln-tmp.prd-cd    = cecrln.prd-cd
                         and cecrln-tmp.prd-num   = cecrln.prd-num
                         and cecrln-tmp.piece-int = cecrln.piece-int
                         and cecrln-tmp.lig       = cecrln.lig):
                             
        if cecrln.lettre > ""
        then do :
            find first ttDelettrage
                where ttDelettrage.etab-cd = cecrln.etab-cd
                  and ttDelettrage.sscoll-cle = cecrln.sscoll-cle
                  and ttDelettrage.cpt-cd = cecrln.cpt-cd
                  and ttDelettrage.lettre = cecrln.lettre no-error.
            if not available ttDelettrage
            then do :
                create ttDelettrage.
                assign
                    ttDelettrage.etab-cd = cecrln.etab-cd
                    ttDelettrage.sscoll-cle = cecrln.sscoll-cle
                    ttDelettrage.cpt-cd = cecrln.cpt-cd
                    ttDelettrage.lettre = cecrln.lettre
                    ttDelettrage.flag = string(cecrln.lig)
                .
            end.
        end.

        /* delete cecrlnana */
        for each cecrlnana exclusive-lock
            where cecrlnana.soc-cd    = cecrln.soc-cd
              and cecrlnana.etab-cd   = cecrln.etab-cd
              and cecrlnana.jou-cd    = cecrln.jou-cd
              and cecrlnana.prd-cd    = cecrln.prd-cd
              and cecrlnana.prd-num   = cecrln.prd-num
              and cecrlnana.piece-int = cecrln.piece-int
              and cecrlnana.lig       = cecrln.lig:
            delete cecrlnana.
        end.
        for each cblock exclusive-lock
            where cblock.soc-cd   = cecrln.soc-cd
              and cblock.etab-cd  = cecrln.etab-cd
              and cblock.jou-cd   = cecrln.jou-cd
              and cblock.prd-cd   = cecrln.prd-cd
              and cblock.prd-num  = cecrln.prd-num
              and cblock.piece-int = cecrln.piece-int
              and cblock.lig       = cecrln.lig:
            delete cblock.
        end.
        for each aecrdtva exclusive-lock
            where aecrdtva.soc-cd    = cecrln.soc-cd
              and aecrdtva.etab-cd   = cecrln.etab-cd
              and aecrdtva.jou-cd    = cecrln.jou-cd
              and aecrdtva.prd-cd    = cecrln.prd-cd
              and aecrdtva.prd-num   = cecrln.prd-num
              and aecrdtva.piece-int = cecrln.piece-int
              and aecrdtva.lig       = cecrln.lig:
            delete aecrdtva.
        end.
        for each aecrdet exclusive-lock                      /**Ajout OF le 16/01/01**/
            where aecrdet.soc-cd    = cecrln.soc-cd
              and aecrdet.etab-cd   = cecrln.etab-cd
              and aecrdet.jou-cd    = cecrln.jou-cd
              and aecrdet.prd-cd    = cecrln.prd-cd
              and aecrdet.prd-num   = cecrln.prd-num
              and aecrdet.piece-int = cecrln.piece-int
              and aecrdet.lig       = cecrln.lig:
            delete aecrdet.
        end.
        for each adbtva exclusive-lock                              /* PS LE 23/10/00 */
            where adbtva.soc-cd    = cecrln.soc-cd
              and adbtva.etab-cd   = cecrln.etab-cd
              and adbtva.jou-cd    = cecrln.jou-cd
              and adbtva.prd-cd    = cecrln.prd-cd
              and adbtva.prd-num   = cecrln.prd-num
              and adbtva.piece-int = cecrln.piece-int
              and adbtva.lig       = cecrln.lig:
            for each aligtva exclusive-lock
                where aligtva.soc-cd  = adbtva.soc-cd
                  and aligtva.etab-cd = adbtva.etab-cd
                  and aligtva.num-int = adbtva.num-int:
                delete aligtva.
            end.
            delete adbtva.
        end.

/*gga todo ce programme ne fait rien (lecture table pour appel include vide, donc plus d'appel
        if available ilibnatjou
        and ilibnatjou.od
        and piTmpPrdCdDeb <> 0
        then do:
         {comm\appelspe.i RpRunBat  "MajMtrgl.p"
                                     ROWID(cecrln)}.
        end.
gga*/

        delete cecrln.

    end. /* for each cecrln exclusive-lock */

    /**Ajout OF le 18/02/14**/
    if cecrsai-tmp.cdenr begins "CECRSAI-GLI"
    and not can-find(first cecrln-tmp
                     where cecrln-tmp.soc-cd         = cecrsai-tmp.soc-cd
                       and cecrln-tmp.mandat-cd      = cecrsai-tmp.etab-cd
                       and cecrln-tmp.jou-cd         = cecrsai-tmp.jou-cd
                       and cecrln-tmp.mandat-prd-cd  = cecrsai-tmp.prd-cd
                       and cecrln-tmp.mandat-prd-num = cecrsai-tmp.prd-num
                       and cecrln-tmp.piece-int      = cecrsai-tmp.piece-int)
    then vlFgGLI = true.

    for each cecrln-tmp
        where cecrln-tmp.soc-cd         = piCodeSoc
          and cecrln-tmp.mandat-cd      = piCodeEtab
          and cecrln-tmp.jou-cd         = pcTmpJouCd
          and cecrln-tmp.mandat-prd-cd  = piTmpPrdCd
          and cecrln-tmp.mandat-prd-num = piTmpPrdNum
          and cecrln-tmp.piece-int      = piTmpPieceInt:
        if cecrsai-tmp.type-cle = "F"
        and cecrln-tmp.sscoll-cle = "FGLI"
        and cecrln-tmp.fourn-cpt-cd > ""
        then vlFgGLI = true.           /**Ajout OF le 18/02/14**/
        {&_proparse_ prolint-nowarn(nowait)}
        find first cecrln exclusive-lock
            where cecrln.soc-cd    = piCodeSoc
              and cecrln.etab-cd   = cecrln-tmp.etab-cd
              and cecrln.jou-cd    = cecrln-tmp.jou-cd
              and cecrln.prd-cd    = cecrln-tmp.prd-cd
              and cecrln.prd-num   = cecrln-tmp.prd-num
              and cecrln.piece-int = cecrln-tmp.piece-int
              and cecrln.lig       = cecrln-tmp.lig no-error.
        if available cecrln
        then for each cblock exclusive-lock
            where cblock.soc-cd    = cecrln-tmp.soc-cd
              and cblock.etab-cd   = cecrln-tmp.etab-cd
              and cblock.jou-cd    = cecrln-tmp.jou-cd
              and cblock.prd-cd    = cecrln-tmp.prd-cd
              and cblock.prd-num   = cecrln-tmp.prd-num
              and cblock.piece-int = cecrln-tmp.piece-int
              and cblock.lig       = cecrln-tmp.lig:
            assign
                cblock.daech-prev = cecrln-tmp.daech
                cblock.type-cle   = cecrln-tmp.type-cle /* DM 0305/0251 */
            .
        end.
        else create cecrln.

        if available ilibnatjou
        and (ilibnatjou.achat or ilibnatjou.extra-cpta)
        then assign
                 cecrln-tmp.daech   = cecrsai.daech
                 cecrln-tmp.datecr  = cecrsai.daecr
                 cecrln-tmp.ref-num = cecrsai.ref-num /**Ajout OF le 13/09/02**/
        .
        {&_proparse_ prolint-nowarn(findstate-tt)}
        find cecrlnana-tmp           // Attention, pas de find first, on teste l'unicité
            where cecrlnana.soc-cd    = cecrln.soc-cd
              and cecrlnana.etab-cd   = cecrln.etab-cd
              and cecrlnana.jou-cd    = cecrln.jou-cd
              and cecrlnana.prd-cd    = cecrln.prd-cd
              and cecrlnana.prd-num   = cecrln.prd-num
              and cecrlnana.piece-int = cecrln.piece-int
              and cecrlnana.lig       = cecrln.lig no-error. /**Ajout OF le 30/12/98**/
        assign
            cecrln-tmp.dacompta = cecrsai.dacompta
            cecrln-tmp.fg-ana100  = available cecrlnana-tmp    /**Ajout OF le 30/12/98**/
            cecrln-tmp.analytique = available cecrlnana-tmp or ambiguous cecrlnana-tmp  // un ou plusieurs enregistrement(s) 
        .
        buffer-copy cecrln-tmp to cecrln
            assign cecrln.natscen-cd = if viNature <> 0 then viNature else cecrln-tmp.natscen-cd
        .
        for each aecrdtva exclusive-lock
            where aecrdtva.soc-cd    = cecrln.soc-cd
              and aecrdtva.etab-cd   = cecrln.etab-cd
              and aecrdtva.jou-cd    = cecrln.jou-cd
              and aecrdtva.prd-cd    = cecrln.prd-cd
              and aecrdtva.prd-num   = cecrln.prd-num
              and aecrdtva.piece-int = cecrln.piece-int
              and aecrdtva.lig       = cecrln.lig:
            delete aecrdtva.
        end.
        for each adbtva exclusive-lock
            where adbtva.soc-cd    = cecrln.soc-cd
              and adbtva.etab-cd   = cecrln.etab-cd
              and adbtva.jou-cd    = cecrln.jou-cd
              and adbtva.prd-cd    = cecrln.prd-cd
              and adbtva.prd-num   = cecrln.prd-num
              and adbtva.piece-int = cecrln.piece-int
              and adbtva.lig       = cecrln.lig:
            for each aligtva exclusive-lock
                where aligtva.soc-cd  = adbtva.soc-cd
                  and aligtva.etab-cd = adbtva.etab-cd
                  and aligtva.num-int = adbtva.num-int:
                delete aligtva.
            end.
            delete adbtva.
        end.
        for each aecrdtva-tmp
            where aecrdtva-tmp.soc-cd    = cecrln-tmp.soc-cd
              and aecrdtva-tmp.etab-cd   = cecrln-tmp.etab-cd
              and aecrdtva-tmp.jou-cd    = cecrln-tmp.jou-cd
              and aecrdtva-tmp.prd-cd    = cecrln.prd-cd
              and aecrdtva-tmp.prd-num   = cecrln-tmp.prd-num
              and aecrdtva-tmp.piece-int = cecrln-tmp.piece-int
              and aecrdtva-tmp.lig       = cecrln-tmp.lig:
            create aecrdtva.
            buffer-copy aecrdtva-tmp to aecrdtva.
        end.
    end. /* for each cecrln-tmp */

    /* DM 0607/0250 */
    if not plExisteEnt /*AND cecrsai.usrid = "COMPENSATION LOCATAIRES"*/
    then run majbap (rowid(cecrsai), piCodeSoc).

    /* delettrage des lignes associées a la ligne d'écriture suupprimée */
    for each ttDelettrage
      , each cecrln exclusive-lock
        where cecrln.soc-cd     = piCodeSoc
          and cecrln.etab-cd    = ttDelettrage.etab-cd
          and cecrln.sscoll-cle = ttDelettrage.sscoll-cle
          and cecrln.cpt-cd     = ttDelettrage.cpt-cd
          and (cecrln.lettre    = ttDelettrage.lettre or cecrln.lettre = ttDelettrage.lettre + "*"): /* DM 0405/0194 */
        cecrln.lettre = "".
        flag-let (buffer cecrln, today).
    end.

    empty temp-table ttDelettrage.
    /* table cecrlnana */
    for each cecrln-tmp
        where cecrln-tmp.soc-cd         = piCodeSoc
          and cecrln-tmp.mandat-cd      = piCodeEtab
          and cecrln-tmp.jou-cd         = pcTmpJouCd
          and cecrln-tmp.mandat-prd-cd  = piTmpPrdCd
          and cecrln-tmp.mandat-prd-num = piTmpPrdNum
          and cecrln-tmp.piece-int      = piTmpPieceInt:
        for each cecrlnana exclusive-lock
            where cecrlnana.soc-cd    = cecrln-tmp.soc-cd
              and cecrlnana.etab-cd   = cecrln-tmp.etab-cd
              and cecrlnana.jou-cd    = cecrln-tmp.jou-cd
              and cecrlnana.prd-cd    = cecrln-tmp.prd-cd
              and cecrlnana.prd-num   = cecrln-tmp.prd-num
              and cecrlnana.piece-int = cecrln-tmp.piece-int
              and cecrlnana.lig       = cecrln-tmp.lig:
            if vlCompare then do:                                     /* PS LE 06/05/02 */
                create ttCompAna.
                buffer-copy cecrlnana to ttCompAna
                    assign
                        ttCompAna.etat = false
                .
            end.
            delete cecrlnana.
        end.
        for each cecrlnana-tmp
            where cecrlnana-tmp.soc-cd    = cecrln-tmp.soc-cd
              and cecrlnana-tmp.etab-cd   = cecrln-tmp.etab-cd
              and cecrlnana-tmp.jou-cd    = cecrln-tmp.jou-cd
              and cecrlnana-tmp.prd-cd    = cecrln-tmp.prd-cd
              and cecrlnana-tmp.prd-num   = cecrln-tmp.prd-num
              and cecrlnana-tmp.piece-int = cecrln-tmp.piece-int
              and cecrlnana-tmp.lig       = cecrln-tmp.lig:
            create cecrlnana.
            buffer-copy cecrlnana-tmp
                except mt-euro mttva-euro to cecrlnana
                assign
                    cecrlnana.dacompta = cecrsai.dacompta
                    cecrlnana.datecr   = cecrsai.daecr
                    cecrlnana.taxe-cd  = cecrln-tmp.taxe-cd
                    cecrlnana.tva-cd   = cecrln-tmp.taxe-cd
           .

/*gga todo
            {batch/tcana.i "cecrlnana" } /* PS LE 06/05/02 : tracage CANA */
gga*/
        end.
/*gga todo
        {batch/tcans.i "cecrln-tmp.dacompta" } /* PS LE 06/05/02 : tracage CANS */
gga*/
    end.

    if not plExisteEnt and cecrsai.scen-cle > "" and pcTmpFperiod > ""
    then for first iscensai exclusive-lock
        where iscensai.soc-cd   = piCodeSoc
          and iscensai.etab-cd  = cecrsai.etab-cd
          and iscensai.jou-cd   = cecrsai.jou-cd
          and iscensai.type-cle = cecrsai.type-cle
          and iscensai.scen-cle = cecrsai.scen-cle:
        iscensai.fperiod = pcTmpFperiod.
    end.

    run cnummvt (prRecnoSai).

    /******* LETTRAGE AUTOMATIQUE EN OD **********/
    find first ilibnatjou no-lock
        where ilibnatjou.soc-cd = piCodeSoc
          and ilibnatjou.natjou-cd = cecrsai.natjou-cd no-error.
    if available ilibnatjou and ilibnatjou.od and piTmpPrdCdDeb <> 0
    then do:
        run compta/souspgm/codlet.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run codletLettrageAuto in vhProc (rowid(cecrsai), piCodeSoc, piCodeEtab, piTmpPrdCdDeb, piTmpPrdCdFin).        
        run destroy in vhProc.
    end.

    for first cecrsai exclusive-lock
        where rowid(cecrsai) = prRecnoSai:
        if cecrsai.ref-num = ? or cecrsai.ref-num = ""
        then do:
            cecrsai.ref-num = string(cecrsai.piece-compta).
            {&_proparse_ prolint-nowarn(use-index)}
            for first ilibnatjou no-lock
                where ilibnatjou.soc-cd    = piCodeSoc
                  and ilibnatjou.natjou-cd = cecrsai.natjou-cd
                  and (ilibnatjou.achat or ilibnatjou.extra-cpta)
              , each cecrln exclusive-lock
                where cecrln.soc-cd         = piCodeSoc
                  and cecrln.mandat-cd      = cecrsai.etab-cd
                  and cecrln.jou-cd         = cecrsai.jou-cd
                  and cecrln.mandat-prd-cd  = cecrsai.Prd-cd
                  and cecrln.mandat-prd-num = cecrsai.Prd-num
                  and cecrln.piece-int      = cecrsai.piece-int
                use-index ecrln-mandat:
                cecrln.ref-num = cecrsai.ref-num.
            end.
        end.
        {&_proparse_ prolint-nowarn(use-index)}
        if cecrsai.sscoll-cle > "" or cecrsai.acompte
        then for first cecrln no-lock
            where cecrln.soc-cd         = piCodeSoc
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.Prd-cd
              and cecrln.mandat-prd-num = cecrsai.Prd-num
              and cecrln.piece-int      = cecrsai.piece-int
              and cecrln.sscoll-cle     > ""
            use-index ecrln-mandat:
            assign
                cecrsai.sscoll-cle = cecrln.sscoll-cle
                cecrsai.cpt-cd = cecrln.cpt-cd
            .
            for first csscpt no-lock
                where csscpt.soc-cd    = cecrsai.soc-cd
                  and csscpt.etab-cd   = cecrsai.etab-cd
                  and csscpt.sscoll-cle = cecrsai.sscoll-cle
                  and csscpt.cpt-cd     = cecrsai.cpt-cd:
                cecrsai.coll-cle = csscpt.coll-cle.
            end.
        end.
    end.

     /**Ajout OF le 18/02/14**/
    if vlFgGLI
    then do:
        run compta/souspgm/cptagli.p (2, rowid(cecrsai), piCodeSoc, piCodeEtab).
    end.

end procedure.