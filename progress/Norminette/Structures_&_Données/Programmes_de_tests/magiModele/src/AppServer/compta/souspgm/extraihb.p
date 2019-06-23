/*------------------------------------------------------------------------
File        : extraihb.p
Purpose     : Extraction des analytiques dossier
Author(s)   : OF - 2004/02/23;  gga  -  2017/03/10
Notes       : creation a partir gidev\cadb\src\gestion\extraihb.p

01  |  01/09/05  |  OF   | 0505/0074 Nouveau plan comptable
02  |  23/12/05  |  JR   | 1205/0098
03  |  10/01/06  |  JR   | 0106/0115 Quand les dépenses d'un dossier sont à cheval sur deux exercices l'un Non-SRU et
04  |  21/02/06  |  JR   | Complément de 1205/0098 Requete sur ijou (72) fausse pour piece globale
05  |  12/07/06  |  JR   | 0706/0104
06  |  24/10/06  |  JR   | 1006/0084: La recherche de la date de début des exercices étaient fausses.(vdaDateSRU)
07  |  05/03/07  |  OF   | 0307/0062 On ne borne plus la date de fin d'extraction des analytiques
08  |  21/03/07  |  JR   | 0307/0182 On borne la date de fin d' extraction des analytiques
09  |  19/07/10  |  JR   | 0508/0072 Modif de facorhb.def
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}

{compta/include/TbTmpAna.i}
define temp-table ttRegrptCecrlnana no-undo like cecrlnana index primaire soc-cd etab-cd.
define variable giRefPrincipale as integer   no-undo.
define variable gdTotal         as decimal   no-undo.
define variable gdTotalEuro     as decimal   no-undo.
define variable gdTotalTva      as decimal   no-undo.
define variable gdTotalTvaEuro  as decimal   no-undo.
define variable gcTmpRefNum     as character no-undo.
define variable gcTmpJouCd      as character no-undo.
define variable gcTmpTypeCle    as character no-undo.
define variable gdaTmpDate      as date      no-undo.
define variable gcTmpPiece      as character no-undo.
define variable gcTmpLibEcr     as character no-undo extent 20.
define variable gcTmpLib        as character no-undo.

&SCOPED-DEFINE Condition-ana cecrlnana.soc-cd = giRefPrincipale~
                         and cecrlnana.etab-cd = viNumeroMandat~
                         AND cecrlnana.sscoll-cle = ""~
                         and cecrlnana.cpt-cd = vcCompte~
                         and cecrlnana.dacompta <= vdaDateFinIn~
                         and cecrlnana.type-cle <> "ODFE"

&SCOPED-DEFINE Condition-ana2 cecrlnana.soc-cd = giRefPrincipale~
                          and cecrlnana.etab-cd = viNumeroMandat~
                          AND cecrlnana.sscoll-cle = ""~
                          and cecrlnana.dacompta <= vdaDateFinIn~
                          and cecrlnana.dacompta >= vdaDateSRU~
                          and cecrlnana.type-cle <> "ODFE"

&SCOPED-DEFINE Condition-alrub alrub.soc-cd = giRefPrincipale~
                           AND alrub.rub-cd = cecrlnana.ana1-cd~
                           AND alrub.ssrub-cd = cecrlnana.ana2-cd~
                           and alrub.type-rub <> 3

&SCOPED-DEFINE Condition-alrub2 alrub.soc-cd = giRefPrincipale~
                           AND alrub.rub-cd = cecrlnana.ana1-cd~
                           AND alrub.ssrub-cd = cecrlnana.ana2-cd~
                           and alrub.type-chg <> "CHG"~
                           and alrub.type-rub <> 3

&SCOPED-DEFINE Condition-cecrln cecrln.affair-num = viNumeroDossierTravaux~
                               and CAN-FIND(FIRST ijou no-lock where ijou.soc-cd = giRefPrincipale~
                                  AND ijou.etab-cd = cecrln.mandat-cd~
                                  AND ijou.jou-cd = cecrln.jou-cd~
                                  and ijou.natjou-gi <> 93)

procedure extraihbExtraitAnalytique:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.
    define output parameter table for tmp-ana.

    define variable viNumeroMandat         as integer   no-undo.
    define variable viNumeroDossierTravaux as integer   no-undo.
    define variable vdaDateFinIn           as date      no-undo.
    define variable vcCompte               as character no-undo.
    define variable vdaDateSRU             as date      no-undo.
    define variable vdaDateFin             as date      no-undo.
    define variable vdTotalAna             as decimal   no-undo.

/*gga de cet include on ne conserve que TbTmpAna.i.
Le reste ne sert plus (regdifco.def conversion euro)
{gene\facorhb.def "" /** "SHARED" **/ }
gga*/

    define buffer isoc      for isoc.
    define buffer ietab     for ietab.
    define buffer cecrlnana for cecrlnana.
    define buffer cecrln    for cecrln.
    define buffer ijou      for ijou.
    define buffer alrub     for alrub.

/*gga plus utilise on est toujours en mode
apres bascule avec date >= isoc.dat-decret
/**Ajout OF le 01/09/05**/
{comm/dadecret.i giCodeSoc} gga*/

    empty temp-table tmp-ana.
    empty temp-table ttRegrptCecrlnana.
    assign
        viNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        viNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        vdaDateFinIn           = poCollection:getDate("dtDatFin")
        vdaDateFin             = vdaDateFinIn
        vcCompte               = poCollection:getCharacter("cCpt")
        giRefPrincipale        = integer(mToken:cRefPrincipale)
    .

message "gga extraihb debut " viNumeroMandat "//" viNumeroDossierTravaux "//" mToken:cRefPrincipale .

    find first isoc no-lock
        where isoc.soc-cd = integer(mToken:cRefPrincipale) no-error.
    if not available isoc
    then do:
        mError:createError({&error}, "enregistrement isoc inexistant"). /*gga todo normalement impossible creer message */
        return.
    end.
    find first ietab no-lock
        where ietab.soc-cd  = isoc.soc-cd
          and ietab.etab-cd = viNumeroMandat no-error.
    if not available isoc
    then do:
        mError:createError({&error}, "enregistrement ietab inexistant"). /*gga todo normalement impossible creer message */
        return.
    end.
    /** Recherche de la date début des exercices SRU **/
    run Recherche_Date_Debut_Sru(isoc.dat-decret, buffer ietab, vdaDateFinIn, output vdaDateSRU).
    /* Premiere boucle sur l'analytique sans code regroupement */

message "gga extraihb 01 "  vdaDateFinIn "//" vdaDateSRU "//" ietab.soc-cd "//" ietab.etab-cd.

    /** Saisie Apres SRu **/
    for each cecrlnana no-lock
        where {&Condition-ana2}
          and cecrlnana.regrp = ""
      , first cecrln no-lock
        where cecrln.soc-cd    = cecrlnana.soc-cd
          and cecrln.etab-cd   = cecrlnana.etab-cd
          and cecrln.jou-cd    = cecrlnana.jou-cd
          and cecrln.prd-cd    = cecrlnana.prd-cd
          and cecrln.prd-num   = cecrlnana.prd-num
          and cecrln.piece-int = cecrlnana.piece-int
          and cecrln.lig       = cecrlnana.lig
          and {&Condition-cecrln}
      , first ijou no-lock
        where ijou.soc-cd  = cecrln.soc-cd
          and ijou.etab-cd = cecrln.mandat-cd
          and ijou.jou-cd  = cecrln.jou-cd
          and ijou.natjou-gi <> 72
      , first alrub no-lock
        where {&Condition-alrub2}:
        if (alrub.type-rub <> 10 and alrub.type-rub <> 11) or cecrlnana.mt <> 0
        then run creation-tmp-ana1 (buffer cecrln, buffer cecrlnana, input-output vdTotalAna).
    end.
    /** Saisie Avant SRu **/
    vdaDateFinIn = vdaDateSRU - 1.
    for each cecrlnana no-lock
        where {&Condition-ana}
          and cecrlnana.regrp = ""
      , first cecrln no-lock
        where cecrln.soc-cd    = cecrlnana.soc-cd
          and cecrln.etab-cd   = cecrlnana.etab-cd
          and cecrln.jou-cd    = cecrlnana.jou-cd
          and cecrln.prd-cd    = cecrlnana.prd-cd
          and cecrln.prd-num   = cecrlnana.prd-num
          and cecrln.piece-int = cecrlnana.piece-int
          and cecrln.lig       = cecrlnana.lig
          and {&Condition-cecrln}
      , first ijou no-lock
        where ijou.soc-cd  = cecrln.soc-cd
          and ijou.etab-cd = cecrln.mandat-cd
          and ijou.jou-cd  = cecrln.jou-cd
          and ijou.natjou-gi <> 72
      , first alrub no-lock
        where {&Condition-alrub}:
        if (alrub.type-rub <> 10 and alrub.type-rub <> 11) or cecrlnana.mt <> 0
        then run creation-tmp-ana1(buffer cecrln, buffer cecrlnana, input-output vdTotalAna).
    end.
    vdaDateFinIn = vdaDateFin.

/*gga plus utilise conversion euro)
    {gene/regdifco.i
        &liste="tmp-ana"
        &Mt="mt"
        &MtEuro="mt-euro"
        &MtTva="mttva"
        &MtTvaEuro="mttva-euro"
        &Lib="Lib"}    /*<- Regroupement de la difference de conversion DBA 24/01/01*/
    /* PS LE 20/02/02 */      gga*/

    /* Deuxieme boucle sur l'analytique avec code regroupement */
    /** Saisie Apres SRu **/
    for each cecrlnana no-lock
        where {&Condition-ana2}
          and cecrlnana.regrp > ""
      , first cecrln no-lock
        where cecrln.soc-cd    = cecrlnana.soc-cd
          and cecrln.etab-cd   = cecrlnana.etab-cd
          and cecrln.jou-cd    = cecrlnana.jou-cd
          and cecrln.prd-cd    = cecrlnana.prd-cd
          and cecrln.prd-num   = cecrlnana.prd-num
          and cecrln.piece-int = cecrlnana.piece-int
          and cecrln.lig       = cecrlnana.lig
          and {&Condition-cecrln}
      , first ijou no-lock
        where ijou.soc-cd  = cecrln.soc-cd
          and ijou.etab-cd = cecrln.mandat-cd
          and ijou.jou-cd  = cecrln.jou-cd
          and ijou.natjou-gi <> 72
      , first alrub no-lock
        where {&Condition-alrub2}:
        create ttRegrptCecrlnana.
        buffer-copy cecrlnana to ttRegrptCecrlnana.
    end.
    /** Saisie Avant SRu **/
    vdaDateFinIn = vdaDateSRU - 1.
    for each cecrlnana no-lock
        where {&Condition-ana}
          and cecrlnana.regrp > ""
      , first cecrln no-lock
        where cecrln.soc-cd    = cecrlnana.soc-cd
          and cecrln.etab-cd   = cecrlnana.etab-cd
          and cecrln.jou-cd    = cecrlnana.jou-cd
          and cecrln.prd-cd    = cecrlnana.prd-cd
          and cecrln.prd-num   = cecrlnana.prd-num
          and cecrln.piece-int = cecrlnana.piece-int
          and cecrln.lig       = cecrlnana.lig
          and {&Condition-cecrln}
      , first ijou no-lock
        where ijou.soc-cd  = cecrln.soc-cd
          and ijou.etab-cd = cecrln.mandat-cd
          and ijou.jou-cd  = cecrln.jou-cd
          and ijou.natjou-gi <> 72
      , first alrub no-lock
        where {&Condition-alrub}:
        create ttRegrptCecrlnana.
        buffer-copy cecrlnana to ttRegrptCecrlnana.
    end.
    vdaDateFinIn = vdaDateFin.
    for each ttRegrptCecrlnana
        break by ttRegrptCecrlnana.regrp:
        find first cecrlnana no-lock
            where cecrlnana.soc-cd    = ttRegrptCecrlnana.soc-cd
              and cecrlnana.etab-cd   = ttRegrptCecrlnana.etab-cd
              and cecrlnana.jou-cd    = ttRegrptCecrlnana.jou-cd
              and cecrlnana.piece-int = ttRegrptCecrlnana.piece-int
              and cecrlnana.prd-cd    = ttRegrptCecrlnana.prd-cd
              and cecrlnana.prd-num   = ttRegrptCecrlnana.prd-num
              and cecrlnana.lig       = ttRegrptCecrlnana.lig
              and cecrlnana.pos       = ttRegrptCecrlnana.pos
              and cecrlnana.ana-cd    = ttRegrptCecrlnana.ana-cd no-error.
        find first cecrln no-lock
            where cecrln.soc-cd    = cecrlnana.soc-cd
              and cecrln.etab-cd   = cecrlnana.etab-cd
              and cecrln.jou-cd    = cecrlnana.jou-cd
              and cecrln.prd-cd    = cecrlnana.prd-cd
              and cecrln.prd-num   = cecrlnana.prd-num
              and cecrln.piece-int = cecrlnana.piece-int
              and cecrln.lig       = cecrlnana.lig no-error.
        find first ijou no-lock
            where ijou.soc-cd = cecrln.soc-cd
              and ijou.etab-cd = cecrln.mandat-cd
              and ijou.jou-cd  = cecrln.jou-cd no-error.
        find first alrub no-lock
            where alrub.soc-cd   = cecrlnana.soc-cd
              and alrub.rub-cd   = cecrlnana.ana1-cd
              and alrub.ssrub-cd = cecrlnana.ana2-cd
              and alrub.type-rub <> 3 no-error.
        run creation-tmp-ana2(buffer cecrln,
                              buffer alrub,
                              buffer cecrlnana,
                              first-of(ttRegrptCecrlnana.regrp),
                              last-of(ttRegrptCecrlnana.regrp),
                              input-output vdTotalAna).
    end.
// return string(vdTotalAna,"->>>,>>>,>>9.99"). /* gga todo a revoir pourquoi ce return au retour de ce pgm on veut la table tmp-ana */
end procedure.

procedure Recherche_Date_Debut_Sru private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pdaDateDecret as date no-undo.
    define parameter buffer ietab for ietab.
    define input  parameter pdaDateSoldeIn as date no-undo.
    define output parameter pdaDateSruOut  as date no-undo.

    define buffer iprd   for iprd.
    define buffer vbIprd for iprd.

    define variable vicompteur as integer no-undo.

    for first iprd no-lock
        where iprd.soc-cd = ietab.soc-cd
          and iprd.etab-cd = ietab.etab-cd
          and iprd.dadebprd <= pdaDateSoldeIn
          and iprd.dafinprd >= pdaDateSoldeIn
      , first vbIprd no-lock
        where vbIprd.soc-cd  = ietab.soc-cd
          and vbIprd.etab-cd = ietab.etab-cd
          and vbIprd.prd-cd  = iprd.prd-cd:
        pdaDateSruOut = vbIprd.dadebprd.
    end.

    if pdaDateSruOut >= pdaDateDecret
    then
boucle: repeat:
        vicompteur = vicompteur + 1. /** Compteur de sortie par prudence **/
        if vicompteur = 40 then leave boucle.

        find first iprd no-lock
            where iprd.soc-cd   = ietab.soc-cd
              and iprd.etab-cd  = ietab.etab-cd
              and iprd.dafinprd = pdaDateSruOut - 1 no-error.
        if available iprd
        then for first vbIprd no-lock
            where vbIprd.soc-cd  = ietab.soc-cd
              and vbIprd.etab-cd = ietab.etab-cd
              and vbIprd.prd-cd  = iprd.prd-cd:
            if vbIprd.dadebprd >= pdaDateDecret
            then pdaDateSruOut = vbIprd.dadebprd.
            else leave boucle.
        end.
        else leave boucle.
    end.

end procedure.

procedure Creation-tmp-ana1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer cecrln    for cecrln.
    define parameter buffer cecrlnana for cecrlnana.
    define input-output parameter pdTotAna as decimal no-undo.

    define variable viCpt as integer no-undo.

    define buffer cecrsai     for cecrsai.
    define buffer vbCecrlnana for cecrlnana.

    for first cecrsai no-lock
        where cecrsai.soc-cd    = giRefPrincipale
          and cecrsai.etab-cd   = cecrln.mandat-cd
          and cecrsai.jou-cd    = cecrln.jou-cd
          and cecrsai.prd-cd    = cecrln.mandat-prd-cd
          and cecrsai.prd-num   = cecrln.mandat-prd-num
          and cecrsai.piece-int = cecrln.piece-int:
        create tmp-ana.
        assign
            tmp-ana.recno        = string(rowid(cecrlnana))
            tmp-ana.rub-cd       = cecrlnana.ana1-cd
            tmp-ana.ssrub-cd     = cecrlnana.ana2-cd
            tmp-ana.fisc         = cecrlnana.ana3-cd
            tmp-ana.cle          = cecrlnana.ana4-cd
            tmp-ana.ana-cd       = cecrlnana.ana1-cd + cecrlnana.ana2-cd + cecrlnana.ana3-cd + cecrlnana.ana4-cd
            tmp-ana.datecr       = cecrlnana.datecr
            tmp-ana.piece-compta = string(cecrsai.piece-compta)
            tmp-ana.jou-cd       = cecrlnana.jou-cd
            tmp-ana.type-cle     = cecrlnana.type-cle
            tmp-ana.lib          = cecrlnana.lib-ecr[1]
            tmp-ana.sens         = cecrlnana.sens
            tmp-ana.mttva        = cecrlnana.mttva
            tmp-ana.mttva-euro   = cecrlnana.mttva-euro
            tmp-ana.mt           = cecrlnana.mt
            tmp-ana.mt-euro      = cecrlnana.mt-euro
            tmp-ana.rgt          = cecrlnana.regrp
            tmp-ana.fourn-cpt-cd = cecrln.fourn-cpt-cd
            tmp-ana.ref-num      = cecrln.ref-num
            tmp-ana.recno-ecr    = string(rowid(cecrln))
            tmp-ana.lig          = cecrlnana.lig
            tmp-ana.pos          = cecrlnana.pos
            pdTotAna             = pdTotAna + if tmp-ana.sens then tmp-ana.mt else - tmp-ana.mt
        .
        do viCpt = 1 to extent(cecrlnana.lib-ecr):
            tmp-ana.lib-ecr[viCpt] = cecrlnana.lib-ecr[viCpt].
        end.
        if cecrlnana.cpt-cd begins "6711" or cecrlnana.cpt-cd begins "6722"
        then tmp-ana.tphono = if can-find (first ifdsai no-lock
                                  where ifdsai.soc-dest  = cecrlnana.soc-cd
                                    and ifdsai.etab-dest = cecrlnana.etab-cd
                                    and ifdsai.cdenr     = substitute('&1@&2@&3@&4@&5@&6',
                                                             cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-int))
                              then "Fac13" else "Manu".
    end.
    if cecrlnana.ana-cd <> cecrlnana.ana1-cd + cecrlnana.ana2-cd + cecrlnana.ana3-cd + cecrlnana.ana4-cd
    then for first vbCecrlnana exclusive-lock
        where rowid(vbCecrlnana) = rowid(cecrlnana):
        vbCecrlnana.ana-cd = cecrlnana.ana1-cd + cecrlnana.ana2-cd + cecrlnana.ana3-cd + cecrlnana.ana4-cd.
    end.

end procedure.

procedure Creation-tmp-ana2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer cecrln    for cecrln.
    define parameter buffer alrub     for alrub.
    define parameter buffer cecrlnana for cecrlnana.
    define input parameter plPremier as logical no-undo.
    define input parameter plDernier as logical no-undo.
    define input-output parameter pdTotAna as decimal no-undo.

    define variable viCpt as integer no-undo.

    define buffer cecrsai     for cecrsai.
    define buffer vbCecrlnana for cecrlnana.

    for first cecrsai no-lock
        where cecrsai.soc-cd    = giRefPrincipale
          and cecrsai.etab-cd   = cecrln.mandat-cd
          and cecrsai.jou-cd    = cecrln.jou-cd
          and cecrsai.prd-cd    = cecrln.mandat-prd-cd
          and cecrsai.prd-num   = cecrln.mandat-prd-num
          and cecrsai.piece-int = cecrln.piece-int:
        if cecrlnana.sens
        then assign
            gdTotal        = gdTotal        + cecrlnana.mt
            gdTotalEuro    = gdTotalEuro    + cecrlnana.mt-euro
            gdTotaltva     = gdTotalTva     + cecrlnana.mttva
            gdTotaltvaEuro = gdTotalTvaEuro + cecrlnana.mttva-euro
        .
        else assign
            gdTotal        = gdTotal        - cecrlnana.mt
            gdTotalEuro    = gdTotalEuro    - cecrlnana.mt-euro
            gdTotaltva     = gdTotalTva     - cecrlnana.mttva
            gdTotaltvaEuro = gdTotalTvaEuro - cecrlnana.mttva-euro
        .
        if plPremier
        then do:
            assign
                gcTmpLib     = cecrlnana.lib-ecr[1]
                gdaTmpDate   = cecrlnana.datecr
                gcTmpPiece   = string(cecrsai.piece-compta)
                gcTmpJouCd   = cecrlnana.jou-cd
                gcTmpTypeCle = cecrlnana.type-cle
                gcTmpRefNum  = cecrln.ref-num
            .
            do viCpt = 1 to extent(cecrlnana.lib-ecr):
                gcTmpLibEcr[viCpt] = cecrlnana.lib-ecr[viCpt].
            end.
        end.
        if plDernier
        and ((alrub.type-rub <> 10 and alrub.type-rub <> 11) or cecrlnana.mt <> 0)
        then do:
            create tmp-ana.
            assign
                tmp-ana.recno        = string(rowid(cecrlnana))
                tmp-ana.rub-cd       = cecrlnana.ana1-cd
                tmp-ana.ssrub-cd     = cecrlnana.ana2-cd
                tmp-ana.fisc         = cecrlnana.ana3-cd
                tmp-ana.cle          = cecrlnana.ana4-cd
                tmp-ana.ana-cd       = cecrlnana.ana1-cd + cecrlnana.ana2-cd + cecrlnana.ana3-cd + cecrlnana.ana4-cd
                tmp-ana.datecr       = gdaTmpDate
                tmp-ana.piece-compta = gcTmpPiece
                tmp-ana.jou-cd       = gcTmpJouCd
                tmp-ana.type-cle     = gcTmpTypeCle
                tmp-ana.lib          = gcTmpLib
                tmp-ana.sens         = (gdTotal > 0)
                tmp-ana.mttva        = absolute(gdTotalTva)
                tmp-ana.mttva-euro   = absolute(gdTotalTvaEuro)
                tmp-ana.mt           = absolute(gdTotal)
                tmp-ana.mt-euro      = absolute(gdTotalEuro)
                tmp-ana.rgt          = cecrlnana.regrp
                tmp-ana.fourn-cpt-cd = cecrln.fourn-cpt-cd
                tmp-ana.ref-num      = gcTmpRefNum
                tmp-ana.recno-ecr    = string(rowid(cecrln))
                tmp-ana.lig          = cecrlnana.lig
                tmp-ana.pos          = cecrlnana.pos
                pdTotAna             = pdTotAna + if tmp-ana.sens then tmp-ana.mt else - tmp-ana.mt
                gdTotal             = 0
                gdTotalEuro         = 0
                gdTotalTva          = 0
                gdTotalTvaEuro      = 0
            .
            do viCpt = 1 to extent(cecrlnana.lib-ecr):
                tmp-ana.lib-ecr[viCpt] = gcTmpLibEcr[viCpt].
            end.
        end.
    end.
    if cecrlnana.ana-cd <> cecrlnana.ana1-cd + cecrlnana.ana2-cd + cecrlnana.ana3-cd + cecrlnana.ana4-cd
    then for first vbCecrlnana exclusive-lock
         where rowid(vbCecrlnana) = rowid(cecrlnana):
        vbCecrlnana.ana-cd = cecrlnana.ana1-cd + cecrlnana.ana2-cd + cecrlnana.ana3-cd + cecrlnana.ana4-cd.
    end.

end procedure.
