/*------------------------------------------------------------------------
File        : ctrlclot.p
Purpose     : Visualisation de la clôture d'un dossier au niveau de chaque copro.
              avant la validation définitive de la clôture
Author(s)   : gga -  2017/05/17
Notes       : reprise du pgm adb\src\trav\ctrlclot.p
Tables      :
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/tbTmpSld.i}
{compta/include/ctrlclot.i}

function lstcpthb returns character private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : gga todo fonction identique dans dossiertravaux.p comment rendre commun
    ------------------------------------------------------------------------------*/
    define variable vcLstCptHb as character no-undo.
    define buffer aparm for aparm.

    for each aparm no-lock
        where aparm.tppar = "TSIFC"
          and aparm.cdpar begins "HB":
        vcLstCptHb = substitute('&1,&2', vcLstCptHb, aparm.zone2).
    end.
    return trim(vcLstCptHb, ',').

end function.

procedure ctrlclotControleLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par dossierTravaux.p
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define input  parameter table for ttTmpSld.
    define output parameter table for ttTmpCop.
    define output parameter table for ttApatTmp.
    define output parameter table for ttApipTmp.

    define variable vcFicEntree    as character no-undo.
    define variable vcLigne01      as character no-undo.
    define variable vcLigne02      as character no-undo.
    define variable vdAppelCopro   as decimal   no-undo.
    define variable vdTotApipCopro as decimal   no-undo.

    vcFicEntree = substitute('&1adb/tmp/apipcx.lg', session:temp-directory).

message "debut ctrlclot.p "   " vcFicEntree " vcFicEntree.

    for each ttTmpSld:
        create ttTmpCop.
        buffer-copy ttTmpSld to ttTmpCop.
    end.
    run soldeAvantCloture(poCollection).

message "Charge_Temp_Table avant lecture fichier " vcFicEntree.

    /* gga todo ici lecture du fichier cree dans apipcx.p, pourquoi pas une table ????? */
    input from value (vcFicEntree).
    repeat:
        import unformatted vcLigne01.
        import unformatted vcLigne02.
        case substring (vcLigne01, 7, 4, 'character'):
            when "APAT" then do:
                create ttApatTmp.
                assign
                    ttApatTmp.cpt-cd   = substring(vcLigne01, 25, 5, 'character')
                    ttApatTmp.NumAppel = substring(vcLigne01, 21, 4, 'character')
                    ttApatTmp.mt       = decimal (substring(vcLigne01, 30, 11, 'character') ) / 100
                    ttApatTmp.nocop    = integer(ttApatTmp.cpt-cd)
                .
                if substring(vcLigne01, 41, 1, 'character') = "-" then ttApatTmp.mt = - ttApatTmp.mt.
            end.
            when "APIP" then do:
                create ttApipTmp.
                assign
                    ttApipTmp.cpt-cd = substring(vcLigne01, 22, 5, 'character')
                    ttApipTmp.nolot  = integer (substring(vcLigne01, 27, 5, 'character'))
                    ttApipTmp.cle    = substring(vcLigne01, 32, 2, 'character')
                    ttApipTmp.mt     = decimal (substring(vcLigne01, 69, 11, 'character')) / 100
                    ttApipTmp.nocop  = integer(ttApipTmp.cpt-cd)
                    ttApipTmp.lib    = substring(vcLigne01, 34, 35, 'character')
                .
                if substring(vcLigne02, 7, 1, 'character') = "-" then ttApipTmp.mt = - ttApipTmp.mt.
            end.
        end case.
    end.
    input close.

    for each ttApatTmp
        break by ttApatTmp.nocop
              by ttApatTmp.NumAppel:
        if first-of (ttApatTmp.nocop) then vdAppelCopro = 0.
        vdAppelCopro = vdAppelCopro + ttApatTmp.mt.
        if last-of (ttApatTmp.nocop) then ttApatTmp.annulation = vdAppelCopro.
    end.

    for each ttApipTmp
        break by ttApipTmp.nocop
              by ttApipTmp.nolot
              by ttApipTmp.cle:
        if first-of (ttApipTmp.nocop) then vdTotApipCopro = 0.
        vdTotApipCopro = vdTotApipCopro + ttApipTmp.mt.
        if last-of (ttApipTmp.nocop) then ttApipTmp.cumul = vdTotApipCopro.
    end.

end procedure.

procedure soldeAvantCloture private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.

    define variable viNumeroMandat         as integer   no-undo.
    define variable viNumeroDossierTravaux as integer   no-undo.
    define variable vcLstCptHb             as character no-undo.
    define variable viNoRefUse             as integer   no-undo.
    define variable vcChb                  as character no-undo.

    define buffer trdos      for trdos.
    define buffer cecrsai   for cecrsai.
    define buffer vbcecrsai for cecrsai.
    define buffer csscptcol for csscptcol.
    define buffer ietab     for ietab.
    define buffer aeappel   for aeappel.
    define buffer cecrln    for cecrln.

    assign
        viNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        viNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        vcLstCptHb             = lstCptHb()
        viNoRefUse             = integer(mtoken:cRefPrincipale)
    .
    for first csscptcol no-lock
        where csscptcol.soc-cd   = viNoRefUse
          and csscptcol.etab-cd  = viNumeroMandat
          and csscptcol.coll-cle = "C"
          and lookup(csscptcol.sscoll-cpt, vcLstCptHb) > 0:
        vcChb = csscptcol.sscoll-cpt.
    end.
    find first trdos no-lock
        where trdos.nodos = viNumeroDossierTravaux
          and trdos.nocon = viNumeroMandat no-error.
    if not available trdos then return.

    find first ietab no-lock
        where ietab.soc-cd  = viNoRefUse
          and ietab.etab-cd = viNumeroMandat no-error.
    if not available ietab then return.

    /** Pièce ODT **/
    if num-entries(trDos.lbdiv2, "|") >= 6
    then find first vbcecrsai no-lock
        where vbcecrsai.soc-cd       = integer(entry(1, TrDos.lbdiv2, "|"))
          and vbcecrsai.etab-cd      = integer(entry(2, TrDos.lbdiv2, "|"))
          and vbcecrsai.jou-cd       = entry(3, TrDos.lbdiv2, "|")
          and vbcecrsai.prd-cd       = integer(entry(4, TrDos.lbdiv2, "|"))
          and vbcecrsai.prd-num      = integer(entry(5, TrDos.lbdiv2, "|"))
          and vbcecrsai.piece-compta = integer(entry(6, TrDos.lbdiv2, "|")) no-error.

    for each ttTmpCop:
        poCollection:set('iCodeSoc', viNoRefUse) no-error.
        poCollection:set('cCpt',     vcChb) no-error.
        poCollection:set('cCssCpt', string(ttTmpCop.nocop,"99999")) no-error.
        poCollection:set('daDateSolde', ietab.dafinex2) no-error.
        poCollection:set('lExtraCpta', false) no-error.
        run compta/souspgm/solcptch.p (input-output poCollection).
        ttTmpCop.mtsolde = poCollection:getDecimal("dSolde").
        // DM 0409/0131 Pour un retirage, la pièce CPHB/ODCP2 sera supprimée au retour, il faut donc la déduire du calcul du solde
        for last aeappel no-lock
            where aeappel.soc-cd   = viNoRefUse
              and aeappel.etab-cd   = ietab.etab-cd
              and aeappel.natjou-gi = "72"     /* CPHB */
              and aeappel.appel-num begins string(viNumeroDossierTravaux, "99")
          , first cecrsai no-lock
            where cecrsai.soc-cd    = aeappel.soc-cd
              and cecrsai.etab-cd   = aeappel.etab-cd
              and cecrsai.jou-cd    = aeappel.jou-cd
              and cecrsai.prd-cd    = aeappel.prd-cd
              and cecrsai.prd-num   = aeappel.prd-num
              and cecrsai.piece-int = aeappel.piece-int
          , each cecrln no-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int
              and cecrln.etab-cd        = ietab.etab-cd
              and cecrln.sscoll-cle     = "CHB"
              and cecrln.cpt-cd         = string(ttTmpCop.nocop,"99999")
              and cecrln.affair-num     = viNumeroDossierTravaux:
            ttTmpCop.mtsolde = ttTmpCop.mtsolde + (cecrln.mt * (if cecrln.sens then -1 else 1)).
        end.
        /** L'ODT du tirage **/
        if available vbcecrsai
        then for each cecrln no-lock
            where cecrln.soc-cd         = vbcecrsai.soc-cd
              and cecrln.mandat-cd      = vbcecrsai.etab-cd
              and cecrln.jou-cd         = vbcecrsai.jou-cd
              and cecrln.mandat-prd-cd  = vbcecrsai.prd-cd
              and cecrln.mandat-prd-num = vbcecrsai.prd-num
              and cecrln.piece-int      = vbcecrsai.piece-int
              and cecrln.sscoll-cle     = "CHB"
              and cecrln.cpt-cd         = string(ttTmpCop.nocop, "99999"):
            ttTmpCop.mtsolde = ttTmpCop.mtsolde + (cecrln.mt * (if cecrln.sens then -1 else 1)).
        end.
        ttTmpCop.mtfinal = ttTmpCop.mtsolde + ttTmpCop.mtappcx - ttTmpCop.mtappan.
    end.

end procedure.
