/*------------------------------------------------------------------------
File        : majbap.i
Purpose     : Mise à jour flag bap sur reglement d'une ODV
Author(s)   : DM - 2007/11;  gg  -  2017/06/22
Notes       : reprise include cadb\src\batch\majbap.i
              pour le moment seulement reprise de la procedure majbap
              Utilisé par FAODSAI.W, FINTTIP.W, FENCSITU.W, FACPRELN.W, CECRGVA2.P, PROCTRES.P, CTREGVAL.P, CECRGVAL.P

01 | 14/05/2008 |  DM  | 0505/0076 Rajout test du journal + cbap
02 | 28/05/2008 |  DM  | 0505/0076 Sens inversé
03 | 17/03/2011 |  OF  | 1210/0028 Ajout Utilisateur ds cecrsai.usrid des pièces issues de la facturation
----------------------------------------------------------------------*/

procedure majbap private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter prRecno-In as rowid   no-undo.
    define input parameter piCodeSoc  as integer no-undo.

    define variable vcPiece  as character no-undo.
    define variable viFacNum as integer   no-undo.

    define buffer ifdparam   for ifdparam.
    define buffer vbCecrsai  for cecrsai.
    define buffer vb2Cecrsai for cecrsai.
    define buffer ifdsai     for ifdsai.
    define buffer vbCecrln   for cecrln.
    define buffer vb2Cecrln  for cecrln.
    define buffer ijou       for ijou.

    find first ifdparam no-lock where ifdparam.soc-dest = piCodeSoc no-error.
    for first vbCecrsai no-lock
        where rowid(vbCecrsai) = prRecno-In
      , first ijou no-lock
        where ijou.soc-cd  = vbCecrsai.soc-cd
          and ijou.etab-cd = vbCecrsai.etab-cd
          and ijou.jou-cd  = vbCecrsai.jou-cd
          and (ijou.natjou-cd = 2 /* Treso */ or ijou.natjou-gi = 46 /* ODT */)
      , each vbCecrln no-lock
        where vbCecrln.soc-cd         = vbCecrsai.soc-cd
          and vbCecrln.mandat-cd      = vbCecrsai.etab-cd
          and vbCecrln.jou-cd         = vbCecrsai.jou-cd
          and vbCecrln.mandat-prd-cd  = vbCecrsai.prd-cd
          and vbCecrln.mandat-prd-num = vbCecrsai.prd-num
          and vbCecrln.piece-int      = vbCecrsai.piece-int
          and vbCecrln.sscoll-cle     = "LF":

        if vbCecrln.flag-lettre and available ifdparam           /* DM 0505/0076 15/05/200 Rajout du IF */
        then for each vb2Cecrln no-lock    /* on flag le bap de la facture d'honoraire à true */
            where vb2Cecrln.soc-cd     = vbCecrln.soc-cd
              and vb2Cecrln.etab-cd    = vbCecrln.etab-cd
              and vb2Cecrln.sscoll-cle = vbCecrln.sscoll-cle
              and vb2Cecrln.cpt-cd     = vbCecrln.cpt-cd
              and vb2Cecrln.lettre     = vbCecrln.lettre
              and vb2Cecrln.jou-cd     = "ODV":
            assign
                viFacNum = ?
                viFacNum = integer(vb2Cecrln.ref-num)
            no-error.
            {&_proparse_ prolint-nowarn(use-index)}
            for first ifdsai no-lock
                where ifdsai.soc-cd      = ifdparam.soc-cd
                  and ifdsai.etab-cd     = ifdparam.etab-cd
                  and ifdsai.soc-dest    = ifdparam.soc-dest
                  and ifdsai.etab-dest   = vbCecrln.etab-cd
                  and ifdsai.typefac-cle = (if vbCecrln.sscoll-cle = "LF" then "41" else if vbCecrln.sscoll-cle = "PF" then "42" else "51")
                  and ifdsai.facnum-cab  = viFacNum
            use-index fdsai-cab:                          // fdsai-type si pas use-index
                /* recherche de la facture */
                vcPiece = entry(2, ifdsai.cdenr, "¤") no-error.      // todo remplacer par separ[1]
                if error-status:error = false
                and num-entries(vcPiece, "@") >= 6
                then for first vb2Cecrsai exclusive-lock
                    where vb2Cecrsai.soc-cd    = integer(entry(1, vcPiece, "@"))
                      and vb2Cecrsai.etab-cd   = integer(entry(2, vcPiece, "@"))
                      and vb2Cecrsai.jou-cd    = entry(3, vcPiece, "@")
                      and vb2Cecrsai.prd-cd    = integer(entry(4, vcPiece, "@"))
                      and vb2Cecrsai.prd-num   = integer(entry(5, vcPiece, "@"))
                      and vb2Cecrsai.piece-int = integer(entry(6, vcPiece, "@"))
                      and vb2Cecrsai.usrid begins "FACTURE":
                    vb2Cecrsai.bonapaye = true.
                end.
            end.
        end.
        /** DM 0505/0076 14/05/08 Création du paiement **/
        run crecbap(vbCecrln.sens, buffer vbCecrln).
    end.

end procedure.

procedure annbap private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter prRecno-In as rowid no-undo.

    define buffer vbCecrsai for cecrsai.
    define buffer vbCecrln  for cecrln.
    define buffer ijou      for ijou.

    for first vbCecrsai no-lock
        where rowid(vbCecrsai) = prRecno-In
      , first ijou no-lock
        where ijou.soc-cd = vbCecrsai.soc-cd
          and ijou.etab-cd  = vbCecrsai.etab-cd
          and ijou.jou-cd   = vbCecrsai.jou-cd
          and (ijou.natjou-cd = 2 /* Treso */ or ijou.natjou-gi = 46 /* ODT */)
      , each vbCecrln no-lock
        where vbCecrln.soc-cd         = vbCecrsai.soc-cd
          and vbCecrln.mandat-cd      = vbCecrsai.etab-cd
          and vbCecrln.jou-cd         = vbCecrsai.jou-cd
          and vbCecrln.mandat-prd-cd  = vbCecrsai.prd-cd
          and vbCecrln.mandat-prd-num = vbCecrsai.prd-num
          and vbCecrln.piece-int      = vbCecrsai.piece-int
          and vbCecrln.sscoll-cle = "LF":
          run crecbap(not vbCecrln.sens, buffer vbCecrln).             /** Création de l'annulation du paiement **/
    end.

end procedure.

procedure crecbap private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter plSens-In as logical no-undo.
    define parameter buffer pbCecrln for cecrln.

    define variable viManu-Int as integer no-undo.
    define variable vlAchat    as logical no-undo.

    define buffer vb2Cecrln  for cecrln.
    define buffer vb2Cecrsai for cecrsai.
    define buffer ifour      for ifour.
    define buffer cbap       for cbap.
    define buffer ietab      for ietab.

    /* Si l'encaissement est rattaché à un achat, il ne doit pas être pris en compte */
    if pbCecrln.ref-num > "" then
BCL:
    for each vb2Cecrln no-lock
        where vb2Cecrln.soc-cd     = pbCecrln.soc-cd
          and vb2Cecrln.etab-cd    = pbCecrln.etab-cd
          and vb2Cecrln.sscoll-cle = pbCecrln.sscoll-cle
          and vb2Cecrln.cpt-cd     = pbCecrln.cpt-cd
          and vb2Cecrln.ref-num    = pbCecrln.ref-num:
        find first vb2Cecrsai no-lock
            where vb2Cecrsai.soc-cd  = vb2Cecrln.soc-cd
            and vb2Cecrsai.etab-cd   = vb2Cecrln.mandat-cd
            and vb2Cecrsai.jou-cd    = vb2Cecrln.jou-cd
            and vb2Cecrsai.prd-cd    = vb2Cecrln.mandat-prd-cd
            and vb2Cecrsai.prd-num   = vb2Cecrln.mandat-prd-num
            and vb2Cecrsai.piece-int = vb2Cecrln.piece-int no-error.
        if available vb2Cecrsai
        and (vb2Cecrsai.natjou-cd = 3 /* Achat */ or
            (vb2Cecrsai.natjou-cd = 9 and lookup(vb2Cecrsai.type-cle, "A,F") > 0 /* Fact/Avoir en AN */ ))
        then do:
            vlAchat = true.
            leave BCL.
        end.
    end.

    if vlAchat = false
    then do:
        find first ifour no-lock
            where ifour.soc-cd = pbCecrln.soc-cd
              and ifour.coll-cle = "F"
              and ifour.cpt-cd = "00000" no-error.
        {&_proparse_ prolint-nowarn(use-index)}
        find last cbap no-lock
            where cbap.soc-cd = pbCecrln.soc-cd
              and cbap.etab-cd = pbCecrln.etab-cd use-index cbap-int no-error.  // pour avoint le dernier manu-int
        viManu-Int = if available cbap then cbap.manu-int + 1 else 1.
        find first ietab no-lock
            where ietab.Soc-cd = pbCecrln.soc-cd
            and ietab.etab-cd  = pbCecrln.etab-cd no-error.
        create cbap.
        assign
            cbap.soc-cd           = ietab.soc-cd
            cbap.etab-cd          = ietab.etab-cd
            cbap.coll-cle         = if available ifour then ifour.coll-cle else ""
            cbap.sscoll-cle       = "FX"
            cbap.cpt-cd           = ifour.cpt-cd
            cbap.lib              = if available ifour then ifour.nom else ""
            cbap.sens             = plSens-In
            cbap.mt               = pbCecrln.mt
            cbap.fg-statut        = true /* fixe */
            cbap.ref-num          = pbCecrln.ref-num
            cbap.pourcentage      = 0
            cbap.regl-cd          = if available ifour then ifour.regl-cd else 300
            cbap.daech            = pbCecrln.dacompta
            cbap.paie             = false
            cbap.mtdev            = cbap.mt
            cbap.dev-cd           = ietab.dev-cd
            cbap.libtier-cd       = ifour.libtier-cd
            cBap.affair-num       = pbCecrln.affair-num
            cbap.analytique       = false
            cbap.manu-int         = viManu-Int
            cbap.gest-cle         = ietab.gest-cle
            cbap.lib-ecr[1]       = cbap.lib
            cbap.fg-ana100        = false
            cbap.taxe-cd          = 9
            cbap.mttva-dev        = 0
            cbap.tiers-sscoll-cle = ""
            cbap.tiers-cpt-cd     = ""
            cbap.type-reg         = 0 /* paiement divers */
        .
    end.

end procedure.
