/*------------------------------------------------------------------------
File        : codlet.p
Purpose     : Lettrage auto OD
Author(s)   : JR - ;  gga -  2017/05/12
Notes       : reprise du pgm cadb\src\batch\codlet.p
Paramètres d'entrées:
      VcGestion-In (Creation,Modification,Visualisation)
      VcDefaut-In  (Fiche,Liste)
      VcIjoucd-In  Code journal ("" si abandon ) ijou.jou-cd
      VcPrd-cd-In  Numero exercice iprd.prd-cd
      VcPrd-num-In Numero periode iprd.prd-num

01  |  12/01/00  |   FR   | Seulement lettrage des écritures pour lesquelles il y a plusieurs ref-num identiques                                   |
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/flagLettre-cLettre-inumpiec.i}

define temp-table ttLettre no-undo
    field lettre as character format "x(5)"
    field valeur as decimal   format ">>>>,>>>,>>>,>>9.99-".

procedure codletLettrageAuto:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service utilisé par cecrgval.p
    ------------------------------------------------------------------------------*/
    define input parameter prRowidEcr   as rowid   no-undo.
    define input parameter piCodeSoc    as integer no-undo.
    define input parameter piCodeEtab   as integer no-undo.
    define input parameter piCodePerDeb as integer no-undo.
    define input parameter piCodePerFin as integer no-undo.

    define buffer vbCecrln  for cecrln.
    define buffer vb2Cecrln for cecrln.
    define buffer cecrsai   for cecrsai.
    define buffer cecrln    for cecrln.
    define buffer ietab     for ietab.
    define buffer ccpt      for ccpt.

    define variable vdMtLettre  as decimal   no-undo format ">>>>,>>>,>>>,>>9.99-".
    define variable vdMtTot     as decimal   no-undo format ">>>>,>>>,>>>,>>9.99-".
    define variable vcStLettre  as character no-undo format "x(5)".
    define variable vcStRefNum  as character no-undo.
    define variable viNb        as integer   no-undo.
    define variable vdSolde     as decimal   no-undo format "->>>,>>>,>>>,>>9.99".
    define variable vdaLettrage as date      no-undo.

boucle:
    for first cecrsai no-lock
        where rowid(cecrsai) = prRowidEcr
      , each cecrln exclusive-lock
        where cecrln.soc-cd         = cecrsai.soc-cd
          and cecrln.mandat-cd      = cecrsai.etab-cd
          and cecrln.jou-cd         = cecrsai.jou-cd
          and cecrln.mandat-prd-cd  = cecrsai.prd-cd
          and cecrln.mandat-prd-num = cecrsai.prd-num
          and cecrln.piece-int      = cecrsai.piece-int:
        if cecrln.ref-num = ""
        then do:
            assign
                cecrln.ecrln-jou-cd    = ""
                cecrln.ecrln-prd-cd    = 0
                cecrln.ecrln-prd-num   = 0
                cecrln.ecrln-piece-int = 0
                cecrln.ecrln-lig       = 0
            .
            next boucle.
        end.

        if substring(cecrln.ref-num, 1, 1, 'character') <> "R"
        then do:
            /*** LETTRAGE ***/
            {compta/include/pregln-let.i cecrln}
        end.
        else do:
            /** SI RELEVE **/
            {&_proparse_ prolint-nowarn(nowhere)}
            empty temp-table ttLettre.
            vcStRefNum = cecrln.ref-num + "#".
            {&_proparse_ prolint-nowarn(sortaccess)}
            for each vbCecrln no-lock
                where vbCecrln.soc-cd      = piCodeSoc
                  and vbCecrln.etab-cd     = cecrln.etab-cd
                  and vbCecrln.sscoll-cle  = cecrln.sscoll-cle
                  and vbCecrln.cpt-cd      = cecrln.cpt-cd
                  and vbCecrln.flag-lettre = false
                  and vbCecrln.prd-cd      >= piCodePerDeb
                  and vbCecrln.prd-cd      <= piCodePerFin
                  and vbCecrln.ref-num     begins cecrln.ref-num
                  and (vbCecrln.ref-num    = cecrln.ref-num or vbCecrln.ref-num = vcStRefNum)
                break by vbCecrln.lettre:
                if vbCecrln.lettre = ""
                then assign
                    vdMtLettre = vdMtLettre + if vbCecrln.sens then vbCecrln.mt else - vbCecrln.mt
                    vdMtTot    = vdMtTot    + if vbCecrln.sens then vbCecrln.mt else - vbCecrln.mt
                    viNb       = viNb + 1
                .
                if last-of(vbCecrln.lettre) and vbCecrln.lettre > ""
                then for each vb2Cecrln no-lock
                    where vb2Cecrln.soc-cd     = piCodeSoc
                      and vb2Cecrln.etab-cd    = cecrln.etab-cd
                      and vb2Cecrln.sscoll-cle = cecrln.sscoll-cle
                      and vb2Cecrln.cpt-cd     = cecrln.cpt-cd
                      and vb2Cecrln.lettre     = cecrln.lettre
                      and vb2Cecrln.prd-cd     >= piCodePerDeb
                      and vb2Cecrln.prd-cd     <= piCodePerFin:
                    assign
                        vdMtLettre = vdMtLettre + if vb2Cecrln.sens then vb2Cecrln.mt else - vb2Cecrln.mt
                        vdMtTot    = vdMtTot    + if vb2Cecrln.sens then vb2Cecrln.mt else - vb2Cecrln.mt
                        viNb       = viNb + 1
                    .
                end.

                if last-of(vbCecrln.lettre) then do:
                    create ttLettre.
                    assign
                        vcStLettre     = vbCecrln.lettre
                        ttLettre.lettre = vbCecrln.lettre
                        ttLettre.valeur = vdMtLettre
                        vdMtLettre     = 0
                    .
                end.
            end. /* for each vbCecrln */
            if vcStLettre = ""
            then for first ccpt no-lock
                where ccpt.soc-cd   = piCodeSoc
                  and ccpt.coll-cle = cecrln.coll-cle
                  and ccpt.cpt-cd   = cecrln.cpt-cd:
                vcStLettre = clettre(rowid(ccpt), "par").
            end.
            {&_proparse_ prolint-nowarn(nowhere)}
            for each ttLettre:
                {&_proparse_ prolint-nowarn(use-index)}
                if vdMtTot = 0 and ttLettre.lettre > "" and viNb <> 1
                then for each vbCecrln exclusive-lock
                    where vbCecrln.soc-cd      = piCodeSoc
                      and vbCecrln.etab-cd     = cecrln.etab-cd
                      and vbCecrln.sscoll-cle  = cecrln.sscoll-cle
                      and vbCecrln.cpt-cd      = cecrln.cpt-cd
                      and vbCecrln.lettre      = ttLettre.lettre
                      and vbCecrln.prd-cd      >= piCodePerDeb
                      and vbCecrln.prd-cd      <= piCodePerFin
                      and vbCecrln.flag-lettre = false
                    use-index ecrln-lettre3:                // Progress prend  ecrln-flag-lettre
                    vbCecrln.lettre = if vdMtTot = 0 then caps(vcStLettre) else vcStLettre.
                    flag-let (buffer vbCecrln, today).
                end.
                if (vdMtTot = 0 or ttLettre.lettre = ? or ttLettre.lettre = "") and viNb <> 1
                then for each vbCecrln exclusive-lock
                    where vbCecrln.soc-cd      = piCodeSoc
                      and vbCecrln.etab-cd     = cecrln.etab-cd
                      and vbCecrln.sscoll-cle  = cecrln.sscoll-cle
                      and vbCecrln.cpt-cd      = cecrln.cpt-cd
                      and vbCecrln.flag-lettre = false
                      and vbCecrln.prd-cd      >= piCodePerDeb
                      and vbCecrln.prd-cd      <= piCodePerFin
                      and vbCecrln.ref-num     begins cecrln.ref-num
                      and (vbCecrln.ref-num    = cecrln.ref-num or vbCecrln.ref-num = vcStRefNum):
                    vbCecrln.lettre = if vdMtTot = 0 then caps(vcStLettre) else vcStLettre.
                    flag-let (buffer vbCecrln, today).
                end.
            end.
        end.
    end.
    
end procedure.