/*------------------------------------------------------------------------
File        : cptagli.p
Purpose     : Creation OD de suivi des indemnités relatives à la gli
Author(s)   : OF - 2014/02/18;  gga - 2017/05/12
Notes       : reprise du pgm cadb\src\batch\cptagli.p

    SCHEMAS COMPTABLES DES PIECES CREEES:
    - ETAPE 1 - Encaissement de l'indemnité d'assurance sur le fournisseur Assureur (Remise de chèques ou Trésorerie sur le compte FGLI XXXXX)
        -> Création d'une pièce sur le journal OD du montant de l'encaissement du FGli:
        FGli XXXXX             LGli YYYYY                M 00000             2761 00000
    -----------------      -----------------      -----------------      -----------------
    100 (1a)|                      | 100 (1b)     100 (1b)|              100 (1b)|

    - ETAPE 2 - Encaissement éventuel du locataire (Saisie d'une facture sur le compte FGli XXXXX)
        -> Création d'une pièce sur le journal OD du montant de l'avoir:
        LGli YYYYY             2761 00000
    -----------------      -----------------
    100 (2) |                      | 100 (2)

    - ETAPE 3 - Sortie du locataire (Saisie d'une facture de sortie)
        -> Création d'une pièce sur le journal ODT pour solder le compte LGli et remettre la somme sur le L:
          L  XXXXX             LGli YYYYY                M 00000             2761 00000
    -----------------      -----------------      -----------------      -----------------
            |100 (3a)      100 (3b)|              100 (3a)|                      |100 (3b)


01 | 20/01/15  |  OF  | 0114/0041 Ajout du compte fournisseur dans le champ tiers sur la ligne "M" pour la base dwh
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{compta/include/tbcptaprov.i}
{compta/include/flagLettre-cLettre-inumpiec.i}
{compta/include/tbdelettrage.i}

define input parameter pgiNoEtape    as integer no-undo.
define input parameter pgrRowid-In   as rowid   no-undo.
define input parameter pgiGiCodeSoc  as integer no-undo.
define input parameter pgiGiCodeEtab as integer no-undo.

define temp-table ttPieceGli no-undo
    field etab-cd   as integer
    field cpt-cd    as character
    field cdenr     as character
    field fgGli     as logical
.
define temp-table tmp-erreur no-undo
    field ctype as character
    field champ as character
    field lib   as character
.
define variable gcLibGli       as character no-undo.
define variable gcAnaGli       as character no-undo.
define variable gcLibEcr       as character no-undo extent 2.
define variable gdMtGli        as decimal   no-undo.
define variable glSensGli      as logical   no-undo.
define variable gcEntree       as character no-undo.
define variable gcRetour       as character no-undo.
define variable gcTemp         as character no-undo.
define variable giCpt          as integer   no-undo.
define variable glRetOk        as logical   no-undo.
define variable gcCdEnr        as character no-undo.
define variable ghProcCecrgval as handle    no-undo.
define variable ghProcCptmvtu  as handle    no-undo.
define variable ghProcCptmvtgi as handle    no-undo.

define buffer cecrsai for cecrsai.

message "debut cptagli.p ".

run initialisation.
run creationPiece.
run destroy in ghProcCecrgval.
run destroy in ghProcCptmvtu.
run destroy in ghProcCptmvtgi.

procedure initialisation private:
    /*--------------------------------------------------------------------------
    Purpose:
    Note   :
    ---------------------------------------------------------------------------*/
    define buffer alrub   for alrub.
    define buffer aparm   for aparm.

    find first aparm no-lock
        where aparm.tppar = "PRMGLI"
          and aparm.cdpar = string(pgiNoEtape, "99") no-error.
    gcLibGli = if available aparm then aparm.zone2 else "INDEMNITES GTIE LOYERS IMPAYES".
    find first aparm no-lock
        where aparm.tppar = "PRMGLI"
          and aparm.cdpar = string(pgiNoEtape + 3, "99") no-error.
    gcAnaGli = if available aparm and num-entries(aparm.zone2) > 1
               then aparm.zone2
               else if pgiNoEtape = 1 then "130,875" else "120,876".
    find first alrub no-lock
        where alrub.soc-cd   = pgiGiCodeSoc
          and alrub.rub-cd   = entry(1, gcAnaGli)
          and alrub.ssrub-cd = entry(2, gcAnaGli) no-error.
    gcAnaGli = gcAnaGli + "," + (if available alrub then string(lookup("O", alrub.fisc-cle)) else "4").

    run compta/souspgm/cecrgval.p persistent set ghProcCecrgval.
    run getTokenInstance in ghProcCecrgval(mToken:JSessionId).
    run compta/souspgm/cptmvtu.p persistent set ghProcCptmvtu.
    run getTokenInstance in ghProcCptmvtu(mToken:JSessionId).
    run compta/souspgm/cptmvtgi.p persistent set ghProcCptmvtgi.
    run getTokenInstance in ghProcCptmvtgi(mToken:JSessionId).

end procedure.

procedure creationPiece private:
    /*--------------------------------------------------------------------------
    Purpose:
    Note   :
    ---------------------------------------------------------------------------*/
    define variable vlRetour as logical no-undo.

    define buffer iftsai  for iftsai.
    define buffer ccpt    for ccpt.
    define buffer cecrsai for cecrsai.
    define buffer csscpt  for csscpt.
    define buffer cecrln  for cecrln.

    if pgiNoEtape < 3
    then do:
        find first cecrsai no-lock where rowid(cecrsai) = pgrRowid-In no-error.
        if not available cecrsai then return.
        /*En cas de modification, le champ cdenr est renseigné avec la liste des pièces générées par la 1ère création.
          Il faut donc modifier ou supprimer ces pièces*/
        if cecrsai.cdenr begins "CECRSAI-GLI"
        then do:
            empty temp-table ttPieceGli.
            do giCpt = 1 to num-entries(cecrsai.cdenr, separ[1]):
                create ttPieceGli.
                assign
                    gcTemp             = entry(giCpt, cecrsai.cdenr, separ[1])
                    ttPieceGli.etab-cd = integer(entry(3, gcTemp, "@"))
                    ttPieceGli.cpt-cd  = entry(8, gcTemp, "@")
                    ttPieceGli.cdenr   = gcTemp
                    ttPieceGli.fgGli   = can-find(first cecrln no-lock
                                                  where cecrln.soc-cd         = cecrsai.soc-cd
                                                    and cecrln.mandat-cd      = cecrsai.etab-cd
                                                    and cecrln.jou-cd         = cecrsai.jou-cd
                                                    and cecrln.mandat-prd-cd  = cecrsai.prd-cd
                                                    and cecrln.mandat-prd-num = cecrsai.prd-num
                                                    and cecrln.piece-int      = cecrsai.piece-int
                                                    and cecrln.etab-cd        = integer(entry(3, gcTemp, "@"))
                                                    and cecrln.sscoll-cle     = "FGLI"
                                                    and cecrln.fourn-cpt-cd   = entry(8, gcTemp, "@"))
                .
            end.
/*gga todo include pour vidage table dans le fichier log
        {comm/vidage.i ttPieceGli}
gga*/
            for each ttPieceGli:
                if ttPieceGli.fgGli = false
                then do:
                    run delPiece (ttPieceGli.cdenr).
                    return.
                end.
                for first cecrln no-lock
                    where cecrln.soc-cd         = cecrsai.soc-cd
                      and cecrln.mandat-cd      = cecrsai.etab-cd
                      and cecrln.jou-cd         = cecrsai.jou-cd
                      and cecrln.mandat-prd-cd  = cecrsai.prd-cd
                      and cecrln.mandat-prd-num = cecrsai.prd-num
                      and cecrln.piece-int      = cecrsai.piece-int
                      and cecrln.etab-cd        = ttPieceGli.etab-cd
                      and cecrln.sscoll-cle     = "FGLI"
                      and cecrln.fourn-cpt-cd   = ttPieceGli.cpt-cd:
                    run modifPiece(ttPieceGli.cdenr, cecrln.mt, output vlRetour).
                    /*Si la pièce n'est pas vide, on sort maintenant puisque les montants ont été mis à jour
                      Si la pièce est vide, il faut continuer pour la refaire*/
                    if vlRetour then return.
                end.
            end.
        end.

        for each cecrln no-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int
              and cecrln.sscoll-cle     = "FGLI"
              and cecrln.fourn-cpt-cd   > "":
            find first csscpt no-lock
                where csscpt.soc-cd     = cecrln.soc-cd
                  and csscpt.etab-cd    = cecrln.etab-cd
                  and csscpt.sscoll-cle = "L"
                  and csscpt.cpt-cd     = cecrln.fourn-cpt-cd no-error.
            if pgiNoEtape = 1
            then assign
                gcLibEcr[1] = if cecrln.lib-ecr[2] > "" then cecrln.lib-ecr[2] else cecrln.lib-ecr[1]
                gcLibEcr[2] = cecrln.lib-ecr[1] when cecrln.lib-ecr[2] > ""
            .
            else assign
                gcLibEcr[1] = if available csscpt then string(substitute(gcLibGli, csscpt.lib), "x(32)") else gcLibGli
                gcLibEcr[2] = ""
            .
            gcCdEnr = substitute("CECRSAI-GLI@&1@&2@&3@&4@&5@&6@&7"
                                , cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-int, cecrln.fourn-cpt-cd).
            run creation-Entete (buffer cecrsai-tmp, cecrsai.dacompta, gcLibEcr, gcCdEnr, cecrln.mt, cecrln.etab-cd, output glRetOk).
            if glRetOk = no then return.

            if pgiNoEtape <> 2
            then do:
                if pgiNoEtape = 1
                then do:
                    /*Ligne sur le compte FGLI*/
                    create cecrln-tmp.
                    buffer-copy cecrln to cecrln-tmp
                    assign
                        cecrln-tmp.mandat-cd      = cecrsai-tmp.etab-cd
                        cecrln-tmp.jou-cd         = cecrsai-tmp.jou-cd
                        cecrln-tmp.mandat-prd-cd  = cecrsai-tmp.prd-cd
                        cecrln-tmp.mandat-prd-num = cecrsai-tmp.prd-num
                        cecrln-tmp.sens           = not cecrln.sens
                        cecrln-tmp.piece-int      = cecrsai-tmp.piece-int
                        cecrln-tmp.lib-ecr[1]     = gcLibEcr[1]
                        cecrln-tmp.lib-ecr[2]     = gcLibEcr[2]
                        cecrln-tmp.lib            = gcLibEcr[1]
                        cecrln-tmp.lig            = 10
                    .
                end.
                else for first csscpt no-lock             /*Ligne sur le compte L*/
                    where csscpt.soc-cd     = cecrln.soc-cd
                      and csscpt.etab-cd    = cecrln.etab-cd
                      and csscpt.sscoll-cle = "L"
                      and csscpt.cpt-cd     = cecrln.fourn-cpt-cd:
                    run creation-Ligne(csscpt.sscoll-cle,
                                       csscpt.cpt-cd,
                                       cecrln.sens,
                                       cecrln.mt,
                                       10,
                                       cecrsai.dacompta,
                                       gcLibEcr,
                                       cecrln.cpt-cd,
                                       cecrsai-tmp.piece-int,
                                       cecrln.etab-cd,
                                       csscpt.coll-cle).
                end.
                /*Ligne sur le compte M*/
                find first csscpt no-lock
                    where csscpt.soc-cd     = cecrln.soc-cd
                      and csscpt.etab-cd    = cecrln.etab-cd
                      and csscpt.sscoll-cle = "M"
                      and csscpt.cpt-cd     = "00000" no-error.
                run creation-Ligne ("M",
                                    "00000",
                                    if pgiNoEtape = 1 then cecrln.sens else not cecrln.sens,
                                    cecrln.mt,
                                    20,
                                    cecrsai.dacompta,
                                    gcLibEcr,
                                    cecrln.cpt-cd,
                                    cecrsai-tmp.piece-int,
                                    cecrln.etab-cd,
                                    if available csscpt then csscpt.coll-cle else "").
            end.
            /*Ligne sur le compte LGli*/
            for first csscpt no-lock
                where csscpt.soc-cd     = cecrln.soc-cd
                  and csscpt.etab-cd    = cecrln.etab-cd
                  and csscpt.sscoll-cle = "LGLI"
                  and csscpt.cpt-cd     = cecrln.fourn-cpt-cd:
                run creation-Ligne(csscpt.sscoll-cle,
                                   csscpt.cpt-cd,
                                   if pgiNoEtape = 1 then cecrln.sens else not cecrln.sens,
                                   cecrln.mt,
                                   if pgiNoEtape <> 2 then 30 else 10,
                                   cecrsai.dacompta,
                                   gcLibEcr,
                                   cecrln.cpt-cd,
                                   cecrsai-tmp.piece-int,
                                   cecrln.etab-cd,
                                   csscpt.coll-cle).
                /*Ligne sur le compte 2761*/
                find first ccpt no-lock
                    where ccpt.soc-cd = pgiGiCodeSoc
                      and ccpt.coll-cle = ""
                      and ccpt.cpt-cd = "276100000" no-error.
                run creation-Ligne ("",
                                if available ccpt then ccpt.cpt-cd else "276100000",
                                if pgiNoEtape = 1 then not cecrln.sens else cecrln.sens,
                                cecrln.mt,
                                if pgiNoEtape <> 2 then 40 else 20,
                                cecrsai.dacompta,
                                gcLibEcr,
                                cecrln.cpt-cd,
                                cecrsai-tmp.piece-int,
                                cecrln.etab-cd,
                                if available csscpt then csscpt.coll-cle else "").
            end.
        end.
    end. /* IF pgiNoEtape < 3 */
    else do:
        find first iftsai no-lock where rowid(iftsai) = pgrRowid-In no-error.
        if not available iftsai then return.

        find first csscpt no-lock
            where csscpt.soc-cd     = iftsai.soc-cd
              and csscpt.etab-cd    = iftsai.etab-cd
              and csscpt.sscoll-cle = "L"
              and csscpt.cpt-cd     = iftsai.sscptg-cd no-error.
        assign
            gcLibEcr[1] = if available csscpt then string(substitute(gcLibGli, csscpt.lib), "x(32)") else gcLibGli

/*gga todo pour l'instant on ne recode pas cette partie, a voir plus tard quand richard aura fini son programme de
calcul de solde */
        /*Montant des écritures = Solde du compte LGli*/
            gcEntree = substitute("&1|&2|4119|&3|S|&4", iftsai.soc-cd, iftsai.etab-cd, iftsai.sscptg-cd, iftsai.dafac)
        .
        run compta/souspgm/solcpt.p (gcEntree, output gcRetour).
        assign
            glSensGli = decimal(entry(1, gcRetour, "|")) > 0
            gdMtGli   = absolute(decimal(entry(1, gcRetour, "|")))
        .
        if gdMtGli = 0 then return.
/*gga todo fin pour l'instant on ne recode pas cette partie, a voir plus tard quand richard aura fini son programme de
calcul de solde */

        gcCdEnr = substitute("IFTSAI-GLI@&1@&2@&3@&4@&5@&6", iftsai.soc-cd, iftsai.etab-cd, iftsai.tprole, iftsai.sscptg-cd, iftsai.num-int, iftsai.sscptg-cd).
        run creation-Entete (buffer cecrsai-tmp, iftsai.dafac, gcLibEcr, gcCdEnr, gdMtGli, iftsai.etab-cd, output glRetOk).
        if glRetOk = no then return.

        /* Ligne sur le compte L */
        for first csscpt no-lock
            where csscpt.soc-cd     = iftsai.soc-cd
              and csscpt.etab-cd    = iftsai.etab-cd
              and csscpt.sscoll-cle = "L"
              and csscpt.cpt-cd     = iftsai.sscptg-cd:
            run creation-Ligne(csscpt.sscoll-cle,
                               csscpt.cpt-cd,
                               glSensGli,
                               gdMtGli,
                               10,
                               iftsai.dafac,
                               gcLibEcr,
                               "",
                               cecrsai-tmp.piece-int,
                               iftsai.etab-cd,
                               csscpt.coll-cle).
        end.
        /* Ligne sur le compte M */
        find first csscpt no-lock
            where csscpt.soc-cd = iftsai.soc-cd
              and csscpt.etab-cd = iftsai.etab-cd
              and csscpt.sscoll-cle = "M"
              and csscpt.cpt-cd = "00000" no-error.
        run creation-Ligne("M",
                           "00000",
                           if pgiNoEtape = 1 then glSensGli else not glSensGli,
                           gdMtGli,
                           20,
                           iftsai.dafac,
                           gcLibEcr,
                           "",
                           cecrsai-tmp.piece-int,
                           iftsai.etab-cd,
                           if available csscpt then csscpt.coll-cle else "").
        /* Ligne sur le compte LGli */
        for first csscpt no-lock
            where csscpt.soc-cd     = iftsai.soc-cd
              and csscpt.etab-cd    = iftsai.etab-cd
              and csscpt.sscoll-cle = "LGLI"
              and csscpt.cpt-cd     = iftsai.sscptg-cd:
            run creation-Ligne(csscpt.sscoll-cle,
                               csscpt.cpt-cd,
                               not glSensGli,
                               gdMtGli,
                               30,
                               iftsai.dafac,
                               gcLibEcr,
                               "",
                               cecrsai-tmp.piece-int,
                               iftsai.etab-cd,
                               csscpt.coll-cle).
            /*Ligne sur le compte 2761*/
            find first ccpt no-lock
                where ccpt.soc-cd   = pgiGiCodeSoc
                  and ccpt.coll-cle = ""
                  and ccpt.cpt-cd   = "276100000" no-error.
            run creation-Ligne("",
                               if available ccpt then ccpt.cpt-cd else "276100000",
                               glSensGli,
                               gdMtGli,
                               40,
                               iftsai.dafac,
                               gcLibEcr,
                               "",
                               cecrsai-tmp.piece-int,
                               iftsai.etab-cd,
                               if available csscpt then csscpt.coll-cle else "").
        end.
    end.
    run edtpiec.

    if can-find(first cecrln-tmp) and not can-find(first tmp-erreur)
    then run validation-Piece.

end procedure.


procedure edtpiec private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define variable vdCre as decimal no-undo.
    define variable vdDeb as decimal no-undo.

    output to value(session:temp-directory + "adb~\tmp~\cptagli.lg").
    for each cecrsai-tmp:
        put unformatted
            "Soc " string(cecrsai-tmp.soc-cd,">>>>9")
            " - Mdt " trim(string(cecrsai-tmp.etab-cd,">>>>9"))
            " - Piece no " + trim(string(cecrsai-tmp.piece-compta,"->>>>>>>>9") )
            " - Num int " + trim(string(cecrsai-tmp.piece-int,"->>>>9"))
            " - au " + string(cecrsai-tmp.dacompta,"99/99/9999")
            " - Periode " string(cecrsai-tmp.prd-cd) " " string(cecrsai-tmp.prd-num)
            " - Journal " cecrsai-tmp.jou-cd
            " - TpMvt " cecrsai-tmp.type-cle
            skip
            "Piece cree le " + string(cecrsai-tmp.dacrea,"99/99/9999")
            " par " cecrsai-tmp.usrid
            " - Piece origine: " + cecrsai-tmp.cdenr
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
                string(cecrln-tmp.etab-cd, ">>>>9") " "
                string(cecrln-tmp.lig, ">>>>>>9") " "
                string(cecrln-tmp.coll-cle, "x(4)") " "
                string(cecrln-tmp.sscoll-cle, "x(4)") " "
                string(cecrln-tmp.cpt-cd, "x(9)") " "
                string(cecrln-tmp.lib-ecr[1], "x(32)") " "
                if cecrln-tmp.sens then string(cecrln-tmp.mt, ">>>,>>>,>>9.99") else fill(" ",14) " "
                if not cecrln-tmp.sens then string(cecrln-tmp.mt, ">>>,>>>,>>9.99") else fill(" ",14) " "
                if cecrln-tmp.mttva <> 0 then string(cecrln-tmp.mttva, ">>>,>>>,>>9.99") else "" " "
                string(cecrln-tmp.prd-cd, ">9") "-" trim(string(cecrln-tmp.prd-num, ">9"))
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
            fill(" ", 47)
            string("TOTAUX : ", "x(13)") " "
            string(vdDeb, ">>>,>>>,>>9.99") " "
            string(vdCre, ">>>,>>>,>>9.99")
            skip(2)
            fill(" ", 47)
            string("SOLDE : ", "x(13)") " "
            if vdDeb - vdCre >= 0 then string(vdDeb - vdCre , ">>>,>>>,>>9.99") else fill(" ", 14) " "
            if vdDeb - vdCre < 0 then string(vdCre - vdDeb, ">>>,>>>,>>9.99") else fill(" ", 14)
            skip.
    end.
    output close.

end procedure.

procedure Validation-Piece private:
    /*------------------------------------------------------------------------------
    purpose: Passage des tables temporaires aux tables reelles pour les tables cecrsai, cecrln et cecrlnana
    Note   :
    ------------------------------------------------------------------------------*/
    define variable vcCdEnr     as character no-undo.
    define variable vcCptLoc    as character no-undo.
    define variable vrRecno-sai as rowid     no-undo.
    define variable viCpt       as integer   no-undo.

    define buffer cecrsai for cecrsai.
    define buffer iftsai for iftsai.

    for each cecrsai-tmp:
        assign
            vrRecno-sai = ?
            vcCptLoc = entry(8, cecrsai-tmp.cdenr, "@")
        .
        run compta/souspgm/cecrgvalValEcrOdAchat in ghProcCecrgval(
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
            "").
        find first cecrsai no-lock
            where rowid(cecrsai) = vrRecno-sai no-error.
        /*Origine = Pièce comptable*/
        if pgiNoEtape < 3
        then vcCdEnr = substitute('&1&2CECRSAI-GLI@&3@&4@&5@&6@&7@&8@&9'
                                 , vcCdEnr, separ[1]
                                 , cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-int, vcCptLoc).
        /*Origine = Facture locataire*/
        else vcCdEnr = substitute('&1&2C@&3@&4@&5@&6@&7@&8@&9'
                                 , vcCdEnr, separ[1]
                                 , cecrsai.soc-cd, cecrsai.etab-cd, cecrsai.jou-cd, cecrsai.prd-cd, cecrsai.prd-num, cecrsai.piece-int, vcCptLoc).
        vcCdEnr = trim(vcCdEnr, separ[1]).
        delete cecrsai-tmp.
    end.

    /*Mise à jour du lien avec la pièce comptable ou la facture d'origine*/
    if pgiNoEtape < 3
    then for first cecrsai exclusive-lock
        where rowid(cecrsai) = pgrRowid-In:
        cecrsai.cdenr = vcCdEnr.
    end.
    else for first iftsai exclusive-lock
        where rowid(iftsai) = pgrRowid-In:
boucle:
        do viCpt = 1 to 5:
            if iftsai.cdenr[viCpt] = ? or iftsai.cdenr[viCpt] = ""
            then do:
                iftsai.cdenr[viCpt] = vcCdEnr.
                leave boucle.
            end.
        end.
    end.

/*gga todo creation message + appel programme compta ?
    if pgiNoEtape = 3
    then do:
        LbMess = "Une pièce comptable a été créée pour solder le compte LGLI (Locataire Gtie Loyers Impayés). Voulez-vous l'imprimer ?".
        {comm/message.i "0" "'QO'" "'c' + LbMess"}
        if return-value = "TRUE" then do:
            {comm/appelMDI.i RpRunEdiGen "fediajou.w" "string(vrRecno-sai) + '¤Directe'"}
        end.
    end.
gga*/

end procedure.

procedure ouverture private:
    /*------------------------------------------------------------------------------
    purpose: Ouverture journal si non cloture
    Note   :
    ------------------------------------------------------------------------------*/
    define parameter buffer ijou for ijou.
    define parameter buffer iprd for iprd.

    define buffer ijouprd for ijouprd.

    for first ijouprd exclusive-lock
        where ijouprd.soc-cd  = iprd.soc-cd
          and ijouprd.etab-cd = iprd.etab-cd
          and ijouprd.jou-cd  = ijou.jou-cd
          and ijouprd.prd-cd  = iprd.prd-cd
          and ijouprd.prd-num = iprd.prd-num
          and ijouprd.statut = "N":
        ijouprd.statut = "O".
    end.

end procedure.

procedure Creation-Entete private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define parameter buffer cecrsai-tmp for cecrsai-tmp.
    define input  parameter pdaCompta as date      no-undo.
    define input  parameter pcLibEcr  as character no-undo extent 2.
    define input  parameter pcCdEnr   as character no-undo.
    define input  parameter pdMtGli   as decimal   no-undo.
    define input  parameter piMdt     as integer   no-undo.
    define output parameter plRetOk   as logical   no-undo.

    define variable viTmpPieceInt as integer no-undo.

    define buffer ijou     for ijou.
    define buffer iprd     for iprd.
    define buffer ietab    for ietab.
    define buffer cnumpiec for cnumpiec.

    if pgiNoEtape <= 2
    then find first ijou no-lock
        where ijou.soc-cd    = pgiGiCodeSoc
          and ijou.etab-cd   = piMdt
          and ijou.natjou-gi = 40 no-error.
    else find first ijou no-lock
        where ijou.soc-cd    = pgiGiCodeSoc
          and ijou.etab-cd   = 8000
          and ijou.natjou-gi = 46 no-error.
    if not available ijou then return.

    find first iprd no-lock
        where iprd.soc-cd   = ijou.soc-cd
          and iprd.etab-cd  = ijou.etab-cd
          and iprd.dadebprd <= pdaCompta
          and iprd.dafinprd >= pdaCompta no-error.
    if not available iprd then return.

    run ouverture (buffer ijou, buffer iprd).
    find first ietab no-lock
        where ietab.soc-cd  = pgiGiCodeSoc
          and ietab.etab-cd = ijou.etab-cd no-error.
    if not available ietab then return.

    create cecrsai-tmp.
    assign
        cecrsai-tmp.soc-cd      = pgiGiCodeSoc
        cecrsai-tmp.etab-cd     = ijou.etab-cd
        cecrsai-tmp.jou-cd      = ijou.jou-cd
        cecrsai-tmp.scen-cle    = ""
        cecrsai-tmp.daecr       = pdaCompta
        cecrsai-tmp.sscoll-cle  = ""
        cecrsai-tmp.cpt-cd      = ""
        cecrsai-tmp.lib         = pcLibEcr[2]
        cecrsai-tmp.dacrea      = today
        cecrsai-tmp.dalivr      = ?
        cecrsai-tmp.regl-cd     = 0
        cecrsai-tmp.daech       = ?
        cecrsai-tmp.dev-cd      = ijou.dev-cd
        cecrsai-tmp.barre-cd    = ""
        cecrsai-tmp.usrid       = mToken:cUser
        cecrsai-tmp.consol      = false
        cecrsai-tmp.bonapaye    = true
        cecrsai-tmp.situ        = ?
        cecrsai-tmp.cours       = 1
        cecrsai-tmp.mtregl      = 0
        cecrsai-tmp.type-cle    = "OD"
        cecrsai-tmp.dossier-num = 0
        cecrsai-tmp.affair-num  = 0
        cecrsai-tmp.prd-cd       = iprd.Prd-cd
        cecrsai-tmp.prd-num        = iprd.Prd-num
        cecrsai-tmp.mtdev          = pdMtGli
        cecrsai-tmp.natjou-cd      = ijou.natjou-cd
        cecrsai-tmp.dadoss         = ?
        cecrsai-tmp.daaff          = ?
        cecrsai-tmp.dacompta       = pdaCompta
        cecrsai-tmp.ref-num        = ""
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
        cecrsai-tmp.cdenr          = pcCdEnr
    .
    /*+==============================================+
    | Numérotation de la piece si c'est une création |
    +==============================================+*/
    find first cnumpiec exclusive-lock
        where cnumpiec.soc-cd = cecrsai-tmp.soc-cd
          and cnumpiec.etab-cd  = cecrsai-tmp.etab-cd
          and cnumpiec.jou-cd   = cecrsai-tmp.jou-cd
          and cnumpiec.prd-cd   = cecrsai-tmp.prd-cd
          and cnumpiec.prd-num  = cecrsai-tmp.prd-num no-error.
    if available cnumpiec
    then assign
        viTmpPieceInt      = cnumpiec.piece-int + 1
        cnumpiec.piece-int = viTmpPieceInt
    .
    else do:
        create cnumpiec.
        assign
            cnumpiec.soc-cd       = cecrsai-tmp.soc-cd
            cnumpiec.etab-cd      = cecrsai-tmp.etab-cd
            cnumpiec.jou-cd       = cecrsai-tmp.jou-cd
            cnumpiec.prd-cd       = cecrsai-tmp.prd-cd
            cnumpiec.prd-num      = cecrsai-tmp.prd-num
            cnumpiec.piece-compta = inumpiecNumerotationPiece(ijou.fpiece, cecrsai-tmp.dacompta)
            cnumpiec.piece-int    = 1
            viTmpPieceInt         = 1
        .
    end.
    assign
        cecrsai-tmp.piece-int    = viTmpPieceInt
        cecrsai-tmp.piece-compta = - viTmpPieceInt
        plRetOk                  = yes
    .
end procedure.

procedure Creation-Ligne private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter pcSscollIn    as character no-undo.
    define input parameter pcCptIn       as character no-undo.
    define input parameter plSensIn      as logical   no-undo.
    define input parameter pdMtIn        as decimal   no-undo.
    define input parameter piLigIn       as integer   no-undo.
    define input parameter pdaCompta     as date      no-undo.
    define input parameter pcLibEcr      as character no-undo extent 2.
    define input parameter pcCptFour     as character no-undo.
    define input parameter piTmpPieceInt as integer   no-undo.
    define input parameter piMdt         as integer   no-undo.
    define input parameter pcCollCle     as character no-undo.

    define variable viPos as integer no-undo.

    define buffer ietab for ietab.
    define buffer iprd for iprd.

    find first ietab no-lock
        where ietab.soc-cd = cecrsai-tmp.soc-cd
          and ietab.etab-cd = piMdt no-error.
    find first iprd no-lock
        where iprd.soc-cd = cecrsai-tmp.soc-cd
          and iprd.etab-cd = piMdt
          and iprd.dadebprd <= pdaCompta
          and iprd.dafinprd >= pdaCompta no-error.
    create cecrln-tmp.
    assign
        cecrln-tmp.soc-cd      = cecrsai-tmp.soc-cd
        cecrln-tmp.etab-cd     = ietab.etab-cd
        cecrln-tmp.jou-cd      = cecrsai-tmp.jou-cd
        cecrln-tmp.piece-int   = cecrsai-tmp.piece-int
        cecrln-tmp.sscoll-cle  = pcSscollIn
        cecrln-tmp.cpt-cd      = pcCptIn
        cecrln-tmp.lib         = pcLibEcr[1]
        cecrln-tmp.sens        = plSensIn
        cecrln-tmp.mt          = absolute (pdMtIn)
        cecrln-tmp.mt-EURO     = 0
        cecrln-tmp.dev-cd      = cecrsai-tmp.Dev-cd
        cecrln-tmp.analytique  = pcSscollIn = "M"
        cecrln-tmp.lettre      = ""
        cecrln-tmp.type-cle    = cecrsai-tmp.Type-cle
        cecrln-tmp.datecr      = cecrsai-tmp.daecr
        cecrln-tmp.prd-cd      = iprd.Prd-cd
        cecrln-tmp.prd-num     = iprd.Prd-num
        cecrln-tmp.lig         = piLigIn
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
        cecrln-tmp.affair-num       = 0
        cecrln-tmp.daaff            = ?
        cecrln-tmp.flag-lettre      = false
        cecrln-tmp.daech            = cecrsai-tmp.dacompta
        cecrln-tmp.dalettrage       = ?
        cecrln-tmp.zone1            = ""
        cecrln-tmp.zone2            = ""
        cecrln-tmp.zone3            = ""
        cecrln-tmp.type-ecr         = ( if cecrln-tmp.analytique then 2 else 1 )
        cecrln-tmp.lien-lig         = 0
        cecrln-tmp.mandat-cd        = cecrsai-tmp.etab-cd
        cecrln-tmp.mandat-prd-cd    = cecrsai-tmp.Prd-cd
        cecrln-tmp.mandat-prd-num   = cecrsai-tmp.Prd-num
        cecrln-tmp.fourn-sscoll-cle = if pcSscollIn = "M" and pcCptFour > "" then "FGLI" else ""
        cecrln-tmp.fourn-cpt-cd     = if pcSscollIn = "M" and pcCptFour > "" then pcCptFour else ""
        cecrln-tmp.mttva            = 0
        cecrln-tmp.mttva-EURO       = 0
        cecrln-tmp.mttva-dev        = 0
        cecrln-tmp.fg-ana100        = cecrln-tmp.analytique
        cecrln-tmp.profil-cd        = ietab.profil-cd
        cecrln-tmp.regl-cd          = 0
        cecrln-tmp.lib-ecr[1]       = pcLibEcr[1]
        cecrln-tmp.lib-ecr[2]       = pcLibEcr[2]
        cecrln-tmp.natscen-cd       = 0
   .
    /* Creation ligne analytique */
    if cecrln-tmp.analytique
    then do:
        create cecrlnana-tmp.
        assign
            cecrlnana-tmp.soc-cd     = cecrln-tmp.soc-cd
            cecrlnana-tmp.etab-cd    = cecrln-tmp.etab-cd
            cecrlnana-tmp.jou-cd     = cecrln-tmp.Jou-cd
            cecrlnana-tmp.prd-cd     = cecrln-tmp.Prd-cd
            cecrlnana-tmp.prd-num    = cecrln-tmp.Prd-num
            cecrlnana-tmp.type-cle   = cecrln-tmp.Type-cle
            cecrlnana-tmp.doss-num   = ""
            cecrlnana-tmp.datecr     = cecrln-tmp.datecr
            cecrlnana-tmp.cpt-cd     = cecrln-tmp.cpt-cd
            cecrlnana-tmp.lib        = cecrln-tmp.lib
            cecrlnana-tmp.sens       = cecrln-tmp.sens
            cecrlnana-tmp.mt         = cecrln-tmp.mt
            cecrlnana-tmp.pourc      = 100
            cecrlnana-tmp.report-cd  = 0
            cecrlnana-tmp.budg-cd    = 0
            cecrlnana-tmp.lig        = cecrln-tmp.lig
            cecrlnana-tmp.piece-int  = piTmpPieceInt
            cecrlnana-tmp.ana1-cd    = entry(1,gcAnaGli)
            cecrlnana-tmp.ana2-cd    = entry(2,gcAnaGli)
            cecrlnana-tmp.ana3-cd    = entry(3,gcAnaGli)
            cecrlnana-tmp.ana4-cd    = ""
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

procedure ModifPiece private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input  parameter pcCdEnrIn as character no-undo.
    define input  parameter pdNewMtIn as decimal   no-undo.
    define output parameter plTrouve  as logical   no-undo.

    define buffer cecrsai   for cecrsai.
    define buffer cecrln    for cecrln.
    define buffer cecrlnana for cecrlnana.

    for first cecrsai exclusive-lock
        where cecrsai.soc-cd    = integer(entry(2, pcCdEnrIn, "@"))
          and cecrsai.etab-cd   = integer(entry(3, pcCdEnrIn, "@"))
          and cecrsai.jou-cd    = entry(4, pcCdEnrIn, "@")
          and cecrsai.prd-cd    = integer(entry(5, pcCdEnrIn, "@"))
          and cecrsai.prd-num   = integer(entry(6, pcCdEnrIn, "@"))
          and cecrsai.piece-int = integer(entry(7, pcCdEnrIn, "@")):
        run cptmvtuUndoMvtCpt in ghProcCptmvtu(rowid(cecrsai)).
        for each cecrln exclusive-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int:
            plTrouve = true.
            for each cecrlnana exclusive-lock
                where cecrlnana.soc-cd    = cecrln.soc-cd
                  and cecrlnana.etab-cd   = cecrln.etab-cd
                  and cecrlnana.jou-cd    = cecrln.jou-cd
                  and cecrlnana.prd-cd    = cecrln.prd-cd
                  and cecrlnana.prd-num   = cecrln.prd-num
                  and cecrlnana.piece-int = cecrln.piece-int
                  and cecrlnana.lig       = cecrln.lig:
                cecrlnana.mt = pdNewMtIn.
            end.
            cecrln.mt = pdNewMtIn.
        end.
        assign
            cecrsai.mtdev = pdNewMtIn
            cecrsai.lib   = substitute("&1 - Modification par &2 (cptagli.p)", cecrsai.lib, mToken:cUser)
        .
message "avant appel cptmvtgi.p" .
        run cptmvtgiMajBalDispo in ghProcCptmvtgi(rowid(cecrsai)).        
    end.

end procedure.

procedure DelPiece private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter pcCdEnrIn as character no-undo.

    define buffer cecrsai   for cecrsai.
    define buffer cecrln    for cecrln.
    define buffer cecrlnana for cecrlnana.
    define buffer cblock    for cblock.

    for first cecrsai exclusive-lock
        where cecrsai.soc-cd    = integer(entry(2, pcCdEnrIn, "@"))
          and cecrsai.etab-cd   = integer(entry(3, pcCdEnrIn, "@"))
          and cecrsai.jou-cd    = entry(4, pcCdEnrIn, "@")
          and cecrsai.prd-cd    = integer(entry(5, pcCdEnrIn, "@"))
          and cecrsai.prd-num   = integer(entry(6, pcCdEnrIn, "@"))
          and cecrsai.piece-int = integer(entry(7, pcCdEnrIn, "@")):
        run cptmvtuUndoMvtCpt in ghProcCptmvtu (rowid(cecrsai)).
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
            cecrsai.lib   = substitute("&1 - Suppression par &2 (cptagli.p)", cecrsai.lib, mToken:cUser)
        .
    end.

end procedure.
