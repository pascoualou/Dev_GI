/*------------------------------------------------------------------------
File        : cptmvtu.p
Purpose     : Undo mouvement des comptes
Author(s)   : master - 04/09/91 : gga - 2017/04/07
Notes       : reprise du pgm cadb\src\batch\cptmvtu.p

01 |  29/04/99  |  OF  | Plus de mise a jour des mouvements pour les comptes de cumul collectifs
02 |  23/05/00  |  OF  | Gestion des plantages pendant la mise a jour des balances (Creation aparm)
                         Suppr. de la maj des balances analytiques
-------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/majdispo.i}

procedure cptmvtuUndoMvtCpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par cptagli.p, cptaprov.p, cptmvtu.p et supodtx.p
    ------------------------------------------------------------------------------*/
    define input parameter prRecnoSai as rowid no-undo.

    define buffer cecrsai for cecrsai.
    define buffer aparm for aparm.
    define buffer cecrln for cecrln.
    define buffer ccptmvt for ccptmvt.

message "gga debut cptmvtu.p" .

    for first cecrsai no-lock
        where rowid(cecrsai) = prRecnoSai:
        {&_proparse_ prolint-nowarn(nowait)}
        find first aparm exclusive-lock
             where aparm.tppar  = "BALANCE"
               and aparm.cdpar  = string(prRecnoSai)
               and aparm.soc-cd = cecrsai.soc-cd no-error.
        if not available aparm
        then do:
            create aparm.
            assign
                aparm.tppar  = "BALANCE"
                aparm.cdpar  = string(prRecnoSai)
                aparm.soc-cd = cecrsai.soc-cd
                aparm.lib    = "INTERRUPTION DE LA BALANCE"
            .
        end.
        if cecrsai.situ <> ?
        then for each cecrln no-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int
          , first ccptmvt exclusive-lock
            where ccptmvt.soc-cd     = cecrln.soc-cd
              and ccptmvt.etab-cd    = cecrln.etab-cd
              and ccptmvt.sscoll-cle = cecrln.sscoll-cle
              and ccptmvt.cpt-cd     = cecrln.cpt-cd
              and ccptmvt.prd-cd     = cecrln.prd-cd
              and ccptmvt.prd-num    = cecrln.prd-num:
            if cecrsai.situ
            then if cecrln.sens                                                   /* Situation definitiv */
                 then assign                                                      /* DEBIT */
                     ccptmvt.mtdeb      = ccptmvt.mtdeb      - cecrln.mt
                     ccptmvt.mtdeb-EURO = ccptmvt.mtdeb-EURO - cecrln.mt-EURO     /**  XS le 12/02/99  **/
                 .
                 else assign                                                      /* CREDIT */
                     ccptmvt.mtcre      = ccptmvt.mtcre      - cecrln.mt
                     ccptmvt.mtcre-EURO = ccptmvt.mtcre-EURO - cecrln.mt-EURO     /**  XS le 12/02/99  **/
                 .
            else if cecrln.sens                                                   /* Situation provisoire */
                 then assign                                                      /* DEBIT */
                     ccptmvt.mtdebp      = ccptmvt.mtdebp      - cecrln.mt
                     ccptmvt.mtdebp-EURO = ccptmvt.mtdebp-EURO - cecrln.mt-EURO   /**  XS le 12/02/99  **/
                 .
                 else assign                                                      /* CREDIT */
                     ccptmvt.mtcrep      = ccptmvt.mtcrep      - cecrln.mt
                     ccptmvt.mtcrep-EURO = ccptmvt.mtcrep-EURO - cecrln.mt-EURO   /**  XS le 12/02/99  **/
                 .
            run majdispo (buffer cecrln, false, "cecrln").                        /* MAJ du disponible */
        end.
    end.

end procedure.
