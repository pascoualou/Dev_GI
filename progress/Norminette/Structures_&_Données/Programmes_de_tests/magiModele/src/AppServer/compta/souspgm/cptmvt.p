/*------------------------------------------------------------------------
File        : cptmvt.p
Purpose     : Mouvement dans les comptes generaux, individuels et cumuls CPTMVT.P
Author(s)   : master - 04/09/91  :  gga - 2017/05/15
Notes       : reprise du pgm cadb\src\batch\cptmvt.p

01 | OF | 29/04/99 | Plus de mise a jour des mouvements pour les comptes de cumul collectifs
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/majdispo.i}

procedure cptmvtMajMvtCpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par odreltx.p et supodtx.p
    ------------------------------------------------------------------------------*/
    define input parameter prRecnoSai as rowid no-undo.

    define buffer cecrsai    for cecrsai.
    define buffer cecrln     for cecrln.
    define buffer ccptmvt    for ccptmvt.
    define buffer cecrlnana  for cecrlnana.
    define buffer ccptmvtana for ccptmvtana.

    {&_proparse_ prolint-nowarn(use-index)}
    for first cecrsai no-lock
        where rowid(cecrsai) = prRecnoSai
      , each cecrln no-lock
        where cecrln.soc-cd         = cecrsai.soc-cd
          and cecrln.mandat-cd      = cecrsai.etab-cd
          and cecrln.jou-cd         = cecrsai.jou-cd
          and cecrln.mandat-prd-cd  = cecrsai.prd-cd
          and cecrln.mandat-prd-num = cecrsai.prd-num
          and cecrln.piece-int      = cecrsai.piece-int
        use-index ecrln-mandat:
        {&_proparse_ prolint-nowarn(nowait)}
        find first ccptmvt exclusive-lock
             where ccptmvt.soc-cd     = cecrln.soc-cd
               and ccptmvt.etab-cd    = cecrln.etab-cd
               and ccptmvt.sscoll-cle = cecrln.sscoll-cle
               and ccptmvt.cpt-cd     = cecrln.cpt-cd
               and ccptmvt.prd-cd     = cecrln.prd-cd
               and ccptmvt.prd-num    = cecrln.prd-num no-error.
        {compta/include/cptmvt.i cecrln.sscoll-cle cecrln.cpt-cd}    /* MAJ de mouvement de compte ou creation */
        {compta/include/cptmvta.i cecrln cecrsai}
        run majdispo (buffer cecrln, true, "cecrln").                /* MAJ du disponible */
    end.

end procedure.
