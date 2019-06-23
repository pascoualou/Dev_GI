/*------------------------------------------------------------------------
File        : cptaprov.p
Purpose     : Creation/modification/suppression des OD de provisions
              (appels de tréso) dans les dossiers travaux en gérance
Author(s)   : OF - 13/09/11  :  gga - 2017/04/07
Notes       : reprise du pgm cadb\src\batch\cptaprov.p

01  |  27/01/14  |  OF    | 0114/0097 Pb rembt provisions en retirage
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/flagLettre-cLettre-inumpiec.i}
{compta/include/tbcptaprov.i}
{compta/include/tbdelettrage.i}

define temp-table tmp-erreur no-undo
    field ctype  as character
    field champ as character
    field lib   as character.

define variable giCodeSoc        as integer   no-undo.
define variable gdaDaCompta      as date      no-undo.
define variable giDossierTravaux as integer   no-undo.
define variable giNoAppUse       as integer   no-undo.
define variable gcAnaProv        as character no-undo.

procedure cptaprovMajOdProv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par appelDeFond.p et dossierTravaux.p
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define input parameter table for ttTmpProv.

    define variable viNumeroMandat as integer   no-undo.
    define variable vcTpTrait      as character no-undo.
    define variable vrRowidPiece   as rowid     no-undo.
    define variable vdMtApp        as decimal   no-undo.

    define buffer ietab   for ietab.
    define buffer iprd    for iprd.
    define buffer ijou    for ijou.
    define buffer isoc    for isoc.
    define buffer ijouprd for ijouprd.

    assign
        viNumeroMandat   = poCollection:getInteger("iNumeroMandat")
        giDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        vcTpTrait        = poCollection:getCharacter("cTypeTrait")
        vrRowidPiece     = poCollection:getRowid("rRowidPiece")
        vdMtApp          = poCollection:getDecimal("dMtApp")
        gcAnaProv        = "191,704,4"
    .
    /*Modification/suppression de la pièce de provision*/
    if vcTpTrait = "MODIF"
    then do:
        run modifProv(vrRowidPiece, vdMtApp).
        return.
    end.
    else if vcTpTrait = "SUPPR"
    then do:
        run delProv(vrRowidPiece).
        return.
    end.

    empty temp-table cecrsai-tmp.
    empty temp-table cecrln-tmp.
    empty temp-table cecrlnana-tmp.

message "gga cptaprov avant recherche vcGiCodeSoc : " viNumeroMandat "//" giDossierTravaux "//" giCodeSoc .
    /*--> Recherche de la référence */
    {&_proparse_ prolint-nowarn(wholeindex)}
    if giDossierTravaux <> 0
    then for first isoc no-lock
        where isoc.specif-cle = 1000
          and can-find(first ietab no-lock
                 where ietab.soc-cd  = isoc.soc-cd
                   and ietab.etab-cd = viNumeroMandat):
        giCodeSoc = isoc.soc-cd.
    end.
message "gga cptaprov vcGiCodeSoc : " giCodeSoc.

    for each ttTmpProv:
message "gga cptaprov dans boucle ttTmpProv " ttTmpProv.etab-cd.
        assign
            gdaDaCompta = /*IF ttTmpProv.dacompta < agest.dadeb THEN agest.dadeb
                         ELSE IF ttTmpProv.dacompta > agest.dafin THEN agest.dafin
                         ELSE*/ ttTmpProv.dacompta /**Modif OF le 27/01/14 - Pour ne pas comptabiliser en dehors de la période du CRG**/
            giNoAppUse = integer(entry(5,ttTmpProv.cdenr)) when num-entries(ttTmpProv.cdenr) > 4
        .
        find first ijou no-lock
            where ijou.soc-cd    = giCodeSoc
              and ijou.etab-cd   = ttTmpProv.etab-cd
              and ijou.natjou-gi = ttTmpProv.natjou-gi no-error.
        if not available ijou then return.

        find first iprd no-lock
            where iprd.soc-cd   = giCodeSoc
              and iprd.etab-cd  = ttTmpProv.etab-cd
              and iprd.dadebprd <= gdaDaCompta
              and iprd.dafinprd >= gdaDaCompta no-error.
        if not available iprd then return.

        find first ietab no-lock
            where ietab.soc-cd = giCodeSoc
              and ietab.etab-cd = ttTmpProv.etab-cd no-error.
        if not available ietab then return.

        for first ijouprd exclusive-lock
            where ijouprd.soc-cd  = giCodeSoc
              and ijouprd.etab-cd = ttTmpProv.etab-cd
              and ijouprd.jou-cd  = ijou.jou-cd
              and ijouprd.prd-cd  = iprd.prd-cd
              and ijouprd.prd-num = iprd.prd-num
              and ijouprd.statut  = "N":
            ijouprd.statut = "O".
        end.
message "gga avant appel creation-entete " .
        run creation-Entete (buffer ietab, buffer iprd, buffer ijou, buffer ttTmpProv).
message "gga apres appel creation-entete " return-value.

        if return-value <> "TRUE" then return.
    end.

message "avant test validation ou edt ".

    if can-find(first cecrln-tmp) and not can-find(first tmp-erreur)
    then run Validation-Piece.
    else run edtpiec.

end procedure.

procedure Creation-Entete private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab for ietab.
    define parameter buffer iprd for iprd.
    define parameter buffer ijou for ijou.
    define parameter buffer ttTmpProv for ttTmpProv.

    define buffer cnumpiec for cnumpiec.
    define buffer csscpt   for csscpt.

    create cecrsai-tmp.
    assign
        cecrsai-tmp.soc-cd         = giCodeSoc
        cecrsai-tmp.etab-cd        = ijou.etab-cd
        cecrsai-tmp.jou-cd         = ijou.jou-cd
        cecrsai-tmp.scen-cle       = ""
        cecrsai-tmp.daecr          = ttTmpProv.datecr
        cecrsai-tmp.sscoll-cle     = ""
        cecrsai-tmp.cpt-cd         = ""
        cecrsai-tmp.lib            = "PROVISIONS"
        cecrsai-tmp.dacrea         = today
        cecrsai-tmp.dalivr         = ?
        cecrsai-tmp.regl-cd        = 0
        cecrsai-tmp.daech          = ?
        cecrsai-tmp.dev-cd         = ijou.dev-cd
        cecrsai-tmp.barre-cd       = ""
        cecrsai-tmp.usrid          = mtoken:cUser
        cecrsai-tmp.consol         = false
        cecrsai-tmp.bonapaye       = true
        cecrsai-tmp.situ           = ?
        cecrsai-tmp.cours          = 1
        cecrsai-tmp.mtregl         = 0
        cecrsai-tmp.type-cle       = "ODTX"
        cecrsai-tmp.dossier-num    = 0
        cecrsai-tmp.affair-num     = 0
        cecrsai-tmp.prd-cd         = iprd.Prd-cd
        cecrsai-tmp.prd-num        = iprd.Prd-num
        cecrsai-tmp.mtdev          = 0
        cecrsai-tmp.natjou-cd      = ijou.natjou-cd
        cecrsai-tmp.dadoss         = ?
        cecrsai-tmp.daaff          = ?
        cecrsai-tmp.dacompta       = gdaDaCompta
        cecrsai-tmp.ref-num        = substitute('&1&2&3&4', cecrsai-tmp.jou-cd, fill(".", 5 - length(cecrsai-tmp.jou-cd, 'character')), string(giDossierTravaux, "99"), string(giNoAppUse, "99"))
        cecrsai-tmp.coll-cle       = ""
        cecrsai-tmp.mtimput        = 0
        cecrsai-tmp.acompte        = false
        cecrsai-tmp.acpt-jou-cd    = ""
        cecrsai-tmp.acpt-type      = ""
        cecrsai-tmp.adr-cd         = 0
        cecrsai-tmp.typenat-cd     = 1
        cecrsai-tmp.usrid-eff      = ""
        cecrsai-tmp.daeff          = ?
        cecrsai-tmp.profil-cd      = ietab.profil-cd
        cecrsai-tmp.regl-mandat-cd = 0
        cecrsai-tmp.regl-jou-cd    = ""
        cecrsai-tmp.cdenr          = ttTmpProv.cdenr
    .
    /* Numérotation de la piece si c'est une création */
    {&_proparse_ prolint-nowarn(nowait)}
    find first cnumpiec exclusive-lock
        where cnumpiec.soc-cd = cecrsai-tmp.soc-cd
          and cnumpiec.etab-cd  = cecrsai-tmp.etab-cd
          and cnumpiec.jou-cd   = cecrsai-tmp.jou-cd
          and cnumpiec.prd-cd   = cecrsai-tmp.prd-cd
          and cnumpiec.prd-num  = cecrsai-tmp.prd-num no-error.
    if available cnumpiec
    then cnumpiec.piece-int = cnumpiec.piece-int + 1.
    else do:
        create cnumpiec.
        assign
            cnumpiec.soc-cd       = cecrsai-tmp.soc-cd
            cnumpiec.etab-cd      = cecrsai-tmp.etab-cd
            cnumpiec.jou-cd       = cecrsai-tmp.jou-cd
            cnumpiec.prd-cd       = cecrsai-tmp.prd-cd
            cnumpiec.prd-num      = cecrsai-tmp.prd-num
            cnumpiec.piece-int    = 1
            cnumpiec.piece-compta = inumpiecNumerotationPiece(ijou.fpiece, cecrsai-tmp.dacompta)
        .

message "gga apres appel inumpiec.p " cnumpiec.piece-compta.

    end.
    assign
        cecrsai-tmp.piece-int    = cnumpiec.piece-int
        cecrsai-tmp.piece-compta = - cnumpiec.piece-int
    .
    run Creation-Ligne (buffer ietab,
                        buffer iprd,
                        buffer ttTmpProv,
                        buffer cecrsai-tmp,
                        "",
                        "106000000",
                        ttTmpProv.sens,
                        ttTmpProv.mt,
                        10,
                        "",
                        cnumpiec.piece-int).
    find first csscpt no-lock
        where csscpt.soc-cd = giCodeSoc
          and csscpt.coll-cle = "M"
          and csscpt.cpt-cd = "00000" no-error.
    run Creation-Ligne (buffer ietab,
                        buffer iprd,
                        buffer ttTmpProv,
                        buffer cecrsai-tmp,
                        "M",
                        "00000",
                        not ttTmpProv.sens,
                        ttTmpProv.mt,
                        20,
                        if available csscpt then csscpt.coll-cle else "",
                        cnumpiec.piece-int).
    return "TRUE".

end procedure.

procedure Creation-Ligne private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ietab       for ietab.
    define parameter buffer iprd        for iprd.
    define parameter buffer ttTmpProv   for ttTmpProv.
    define parameter buffer cecrsai-tmp for cecrsai-tmp.
    define input parameter pcSscoll-In     as character no-undo.
    define input parameter pcCpt-In        as character no-undo.
    define input parameter plSens-In       as logical   no-undo.
    define input parameter pdMt-In         as decimal   no-undo.
    define input parameter piLig-In        as integer   no-undo.
    define input parameter pcCollCle       as character no-undo.
    define input parameter piTmp-piece-int as integer   no-undo.

    define variable viPos as integer no-undo.

    create cecrln-tmp.
    assign
        cecrln-tmp.soc-cd      = giCodeSoc
        cecrln-tmp.etab-cd     = ietab.etab-cd
        cecrln-tmp.jou-cd      = cecrsai-tmp.jou-cd
        cecrln-tmp.piece-int   = cecrsai-tmp.piece-int
        cecrln-tmp.sscoll-cle  = pcSscoll-In
        cecrln-tmp.cpt-cd      = pcCpt-In
        cecrln-tmp.lib         = ttTmpProv.lib-ecr[1]
        cecrln-tmp.sens        = plSens-In
        cecrln-tmp.mt          = absolute ( pdMt-In  )
        cecrln-tmp.mt-EURO     = 0
        cecrln-tmp.dev-cd      = cecrsai-tmp.Dev-cd
        cecrln-tmp.num-crg     = ttTmpProv.num-crg
        cecrln-tmp.analytique  = pcSscoll-In = "M"
        cecrln-tmp.lettre      = ""
        cecrln-tmp.type-cle    = cecrsai-tmp.Type-cle
        cecrln-tmp.datecr      = cecrsai-tmp.daecr
        cecrln-tmp.prd-cd      = iprd.Prd-cd
        cecrln-tmp.prd-num     = iprd.Prd-num
        cecrln-tmp.lig         = piLig-In
        cecrln-tmp.mtdev       = 0
        cecrln-tmp.devetr-cd   = ""
        cecrln-tmp.taux        = 0
        cecrln-tmp.coll-cle    = pcCollCle
        cecrln-tmp.paie-regl   = false
        cecrln-tmp.taxe-cd     = 0
        cecrln-tmp.tva-enc-deb = false
        cecrln-tmp.anclettre   = ""
        cecrln-tmp.dacompta         = cecrsai-tmp.dacompta
        cecrln-tmp.ref-num          = cecrsai-tmp.ref-num
        cecrln-tmp.tot-det          = 0
        cecrln-tmp.affair-num       = if cecrln-tmp.sscoll-cle > "" then 0 else ttTmpProv.nodos
        cecrln-tmp.daaff            = ?
        cecrln-tmp.flag-lettre      = false
        cecrln-tmp.daech            = cecrsai-tmp.dacompta
        cecrln-tmp.dalettrage       = ?
        cecrln-tmp.zone1            = ""
        cecrln-tmp.zone2            = ""
        cecrln-tmp.zone3            = ""
        cecrln-tmp.type-ecr         = (if cecrln-tmp.analytique then 2 else 1)
        cecrln-tmp.lien-lig         = 0
        cecrln-tmp.mandat-cd        = cecrsai-tmp.etab-cd
        cecrln-tmp.mandat-prd-cd    = cecrsai-tmp.Prd-cd
        cecrln-tmp.mandat-prd-num   = cecrsai-tmp.Prd-num
        cecrln-tmp.fourn-sscoll-cle = ""
        cecrln-tmp.fourn-cpt-cd     = ""
        cecrln-tmp.mttva            = 0
        cecrln-tmp.mttva-EURO       = 0
        cecrln-tmp.mttva-dev        = 0
        cecrln-tmp.fg-ana100        = cecrln-tmp.analytique
        cecrln-tmp.profil-cd        = ietab.profil-cd
        cecrln-tmp.regl-cd          = 0
        cecrln-tmp.lib-ecr[1]       = cecrln-tmp.lib
        cecrln-tmp.lib-ecr[2]       = ttTmpProv.lib-ecr[2]
        cecrln-tmp.natscen-cd       = 0
    .
    /* Creation ligne analytique */
    if cecrln-tmp.analytique
    then do:
        create cecrlnana-tmp.
        assign
            cecrlnana-tmp.soc-cd    = cecrln-tmp.soc-cd
            cecrlnana-tmp.etab-cd   = cecrln-tmp.etab-cd
            cecrlnana-tmp.jou-cd    = cecrln-tmp.Jou-cd
            cecrlnana-tmp.prd-cd    = cecrln-tmp.Prd-cd
            cecrlnana-tmp.prd-num   = cecrln-tmp.Prd-num
            cecrlnana-tmp.type-cle  = cecrln-tmp.Type-cle
            cecrlnana-tmp.doss-num  = ""
            cecrlnana-tmp.datecr    = cecrln-tmp.datecr
            cecrlnana-tmp.cpt-cd    = cecrln-tmp.cpt-cd
            cecrlnana-tmp.lib       = cecrln-tmp.lib
            cecrlnana-tmp.sens      = cecrln-tmp.sens
            cecrlnana-tmp.mt        = cecrln-tmp.mt
            cecrlnana-tmp.pourc     = 100
            cecrlnana-tmp.report-cd = 0
            cecrlnana-tmp.budg-cd   = 0
            cecrlnana-tmp.lig       = cecrln-tmp.lig
            cecrlnana-tmp.piece-int = piTmp-piece-int
            cecrlnana-tmp.ana1-cd   = entry(1, gcAnaProv)
            cecrlnana-tmp.ana2-cd   = entry(2, gcAnaProv)
            cecrlnana-tmp.ana3-cd   = entry(3, gcAnaProv)
            cecrlnana-tmp.ana4-cd   = ttTmpProv.Cdcle
            cecrlnana-tmp.ana-cd     = cecrlnana-tmp.ana1-cd + cecrlnana-tmp.ana2-cd + cecrlnana-tmp.ana3-cd + cecrlnana-tmp.ana4-cd
            viPos                    = viPos + 10
            cecrlnana-tmp.pos        = viPos
            cecrlnana-tmp.typeventil = true
            cecrlnana-tmp.sscoll-cle = cecrln-tmp.sscoll-cle
            cecrlnana-tmp.cpt-cd     = cecrln-tmp.cpt-cd
            cecrlnana-tmp.dacompta   = cecrln-tmp.dacompta
            cecrlnana-tmp.dev-cd     = cecrln-tmp.dev-cd
            cecrlnana-tmp.taxe-cd    = cecrln-tmp.taxe-cd
            cecrlnana-tmp.analytique = cecrln-tmp.analytique
            cecrlnana-tmp.mtdev      = 0
            cecrlnana-tmp.devetr-cd  = ""
            cecrlnana-tmp.affair-num = 0
            cecrlnana-tmp.tva-cd     = 0
            cecrlnana-tmp.mttva      = cecrln-tmp.mttva
            cecrlnana-tmp.taux-cle   = 100
            cecrlnana-tmp.tantieme   = 0
            cecrlnana-tmp.mttva-dev  = 0
            cecrlnana-tmp.lib-ecr[1] = cecrln-tmp.lib-ecr[1]
            cecrlnana-tmp.lib-ecr[2] = cecrln-tmp.lib-ecr[2]
            cecrlnana-tmp.regrp      = ""
        .
    end.

end procedure.

procedure Validation-Piece private:
    /*------------------------------------------------------------------------------
    purpose: Passage des tables temporaires aux tables reelles pour les tables cecrsai, cecrln et cecrlnana
    Note   :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    define variable vrRecno-sai as rowid no-undo.

    define buffer cecrsai for cecrsai.
    define buffer dosap for dosap.

    run compta/souspgm/cecrgval.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    for each cecrsai-tmp:
        vrRecno-sai = ?.

message "avant appel cecrgval.p" .
        run cecrgvalValEcrOdAchat in vhProc(
            input-output table cecrsai-tmp   by-reference,
            input-output table cecrln-tmp    by-reference,
            input-output table cecrlnana-tmp by-reference,
            input-output table aecrdtva-tmp  by-reference,
            input-output table ttDelettrage  by-reference,
            cecrsai-tmp.soc-cd,
            cecrsai-tmp.etab-cd,
            input-output vrRecno-sai,
            rowid(cecrsai-tmp),
            ?,
            false,
            cecrsai-tmp.jou-cd,
            cecrsai-tmp.Prd-cd,
            cecrsai-tmp.Prd-num,
            cecrsai-tmp.piece-int,
            ?,
            ?,
            ""
        ).
        for first cecrsai no-lock
            where rowid(cecrsai) = vrRecno-sai:
            for first dosap exclusive-lock
                where dosap.tpcon = entry(2, cecrsai.cdenr, "@")
                  and dosap.nocon = integer(entry(3, cecrsai.cdenr, "@"))
                  and dosap.nodos = integer(entry(4, cecrsai.cdenr, "@"))
                  and dosap.noapp = integer(entry(5, cecrsai.cdenr, "@")):
                assign
                    dosap.FgEmi  = true
                    dosap.lbdiv1 = substitute("CECRSAI@&1@&2@&3@&4@&5@&6",
                                       cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd,cecrsai.prd-num, cecrsai.piece-int)
                .
            end.
        end.
        delete cecrsai-tmp.
    end.
    run destroy in vhProc.

end procedure.

procedure edtpiec private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define variable vdCre     as decimal no-undo.
    define variable vdDeb     as decimal no-undo.

    output to value(session:temp-directory + "adb~\tmp~\cptaprov.lg").
    for each cecrsai-tmp:
        put unformatted
            "Soc " string(cecrsai-tmp.soc-cd, ">>>>9")
            " - Mdt " trim(string(cecrsai-tmp.etab-cd, ">>>>9"))
            " - Piece no " trim(string(cecrsai-tmp.piece-compta, "->>>>>>>>9") )
            " - Num int " trim(string(cecrsai-tmp.piece-int, "->>>>9"))
            " - au " string(cecrsai-tmp.dacompta, "99/99/9999")
            " - Periode " string(cecrsai-tmp.prd-cd) " " string(cecrsai-tmp.prd-num)
            " - Journal " cecrsai-tmp.jou-cd
            " - TpMvt " cecrsai-tmp.type-cle
            skip
            "Piece cree le " string(cecrsai-tmp.dacrea, "99/99/9999")
            " par " cecrsai-tmp.usrid
            " - Envoi DPS le " (if cecrsai-tmp.dadoss = ? then "" else string(cecrsai-tmp.dadoss, "99/99/9999"))
            "  " cecrsai-tmp.cdenr
            skip(1)
            "TABLE CECRLN"
            skip.
        assign
            vdDeb = 0
            vdCre = 0
        .
        for each cecrln-tmp
            where cecrln-tmp.soc-cd         = cecrsai-tmp.soc-cd
              and cecrln-tmp.mandat-cd      = cecrsai-tmp.etab-cd
              and cecrln-tmp.jou-cd         = cecrsai-tmp.jou-cd
              and cecrln-tmp.mandat-prd-cd  = cecrsai-tmp.prd-cd
              and cecrln-tmp.mandat-prd-num = cecrsai-tmp.prd-num
              and cecrln-tmp.piece-int      = cecrsai-tmp.piece-int:
            put unformatted
                    string(cecrln-tmp.etab-cd, ">>>>9")
                " " string(cecrln-tmp.lig, ">>>>>>9")
                " " string(cecrln-tmp.coll-cle, "x(4)")
                " " string(cecrln-tmp.sscoll-cle, "x(4)")
                " " string(cecrln-tmp.cpt-cd, "x(9)")
                " " string(cecrln-tmp.lib-ecr[1], "x(32)")
                " " if cecrln-tmp.sens then string(cecrln-tmp.mt, ">>>,>>>,>>9.99") else fill(" ", 14)
                " " if not cecrln-tmp.sens then string(cecrln-tmp.mt, ">>>,>>>,>>9.99") else fill(" ", 14)
                if cecrln-tmp.mttva <> 0 then " " + string(cecrln-tmp.mttva, ">>>,>>>,>>9.99") else ""
                " " string(cecrln-tmp.prd-cd,">9") "-" trim(string(cecrln-tmp.prd-num,">9"))
                skip.
            if cecrln-tmp.sens
            then vdDeb = vdDeb + cecrln-tmp.mt.
            else vdCre = vdCre + cecrln-tmp.mt.
            for each cecrlnana-tmp
                where cecrlnana-tmp.soc-cd    = cecrln-tmp.soc-cd
                  and cecrlnana-tmp.etab-cd   = cecrln-tmp.etab-cd
                  and cecrlnana-tmp.jou-cd    = cecrln-tmp.jou-cd
                  and cecrlnana-tmp.prd-cd    = cecrln-tmp.prd-cd
                  and cecrlnana-tmp.prd-num   = cecrln-tmp.prd-num
                  and cecrlnana-tmp.piece-int = cecrln-tmp.piece-int
                  and cecrlnana-tmp.lig       = cecrln-tmp.lig:
                put unformatted
                    "    ANA: "
                    " " string(cecrlnana-tmp.etab-cd, ">>>>9")
                    " " string(cecrlnana-tmp.pos, ">>9")
                    " " string(cecrlnana-tmp.ana1-cd, "999")
                    " " string(cecrlnana-tmp.ana2-cd, "999")
                    " " string(cecrlnana-tmp.ana3-cd, "9")
                    " " string(cecrlnana-tmp.ana4-cd, "x(2)")
                    " " string(cecrlnana-tmp.lib-ecr[1], "x(32)")
                    " " string(cecrlnana-tmp.mt, "->>>,>>>,>>9.99")
                    skip.
            end.
        end.
        put unformatted
            skip(1)
            fill(" ", 47) string("TOTAUX : ", "x(13)")
            " " string(vdDeb, ">>>,>>>,>>9.99")
            " " string(vdCre, ">>>,>>>,>>9.99")
            skip.
        put unformatted
            skip(1)
            fill(" ", 47) string("SOLDE : ", "x(13)")
            " " if vdDeb - vdCre >= 0 then string(vdDeb - vdCre, ">>>,>>>,>>9.99") else fill(" ", 14)
            " " if vdDeb - vdCre < 0  then string(vdCre - vdDeb, ">>>,>>>,>>9.99") else fill(" ", 14)
            skip.
    end.
    output close.

end procedure.

procedure ModifProv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter prRowSai-In as rowid no-undo.
    define input parameter pdNewMt-In as decimal no-undo.

    define variable vhProc as handle no-undo.

    define buffer cecrsai   for cecrsai.
    define buffer cecrln    for cecrln.
    define buffer cecrlnana for cecrlnana.

message "pppppppppppppppppppppppppppppppppppp ".

    for first cecrsai exclusive-lock
        where rowid(cecrsai) = prRowSai-In:

message "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr ".

message "avant appel cptmvtu.p" .
        run compta/souspgm/cptmvtu.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run cptmvtuUndoMvtCpt in vhProc (input prRowSai-In).
        run destroy in vhProc.
        for each cecrln exclusive-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int:
            for each cecrlnana exclusive-lock
                where cecrlnana.soc-cd    = cecrln.soc-cd
                  and cecrlnana.etab-cd   = cecrln.etab-cd
                  and cecrlnana.jou-cd    = cecrln.jou-cd
                  and cecrlnana.prd-cd    = cecrln.prd-cd
                  and cecrlnana.prd-num   = cecrln.prd-num
                  and cecrlnana.piece-int = cecrln.piece-int
                  and cecrlnana.lig       = cecrln.lig:
                cecrlnana.mt = pdNewMt-In.
            end.
            cecrln.mt = pdNewMt-In.
        end.
        assign
            cecrsai.mtdev = pdNewMt-In
            cecrsai.lib   = substitute('&1 - Modification par &2 (cptaprov.p)', cecrsai.lib, mtoken:cUser)
        .
message "avant appel cptmvtgi.p" .
        run compta/souspgm/cptmvtgi.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run cptmvtgiMajBalDispo in vhProc (prRowSai-In).        
        run destroy in vhProc.
    end.

end procedure.

procedure DelProv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter prRowSai-In as rowid   no-undo.

    define variable vhProc as handle no-undo.

    define buffer cecrsai   for cecrsai.
    define buffer cecrln    for cecrln.
    define buffer cecrlnana for cecrlnana.
    define buffer cblock    for cblock.

    for first cecrsai exclusive-lock
        where rowid(cecrsai) = prRowSai-In:
        run compta/souspgm/cptmvtu.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run cptmvtuUndoMvtCpt in vhProc(prRowSai-In).
        run destroy in vhProc.

message "apres appel cptmvtu.p" .

        for each cecrln exclusive-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int:
            for each cecrlnana exclusive-lock
                where cecrlnana.soc-cd    = cecrln.soc-cd
                  and cecrlnana.etab-cd   = cecrln.etab-cd
                  and cecrlnana.jou-cd    = cecrln.jou-cd
                  and cecrlnana.prd-cd    = cecrln.prd-cd
                  and cecrlnana.prd-num   = cecrln.prd-num
                  and cecrlnana.piece-int = cecrln.piece-int
                  and cecrlnana.lig       = cecrln.lig:
                cecrlnana.soc-cd = - cecrlnana.soc-cd.
            end.
            for each cblock exclusive-lock
                where cblock.soc-cd    = cecrln.soc-cd
                  and cblock.etab-cd   = cecrln.etab-cd
                  and cblock.jou-cd    = cecrln.jou-cd
                  and cblock.prd-cd    = cecrln.prd-cd
                  and cblock.prd-num   = cecrln.prd-num
                  and cblock.piece-int = cecrln.piece-int
                  and cblock.lig       = cecrln.lig:
                cblock.soc-cd = - cblock.soc-cd.
            end.
            cecrln.soc-cd = - cecrln.soc-cd.
        end.
        assign
            cecrsai.mtdev = 0
            cecrsai.lib   = substitute('&1 - Suppression par &2 (cptaprov.p)', cecrsai.lib, mtoken:cUser)
        .
    end.

end procedure.
