/*------------------------------------------------------------------------
File        : cptmvtgi.p
Purpose     : Programme de maj des balances et du dispo
Author(s)   : master - 1991/09/04;  gga -  2017/07/04
Notes       : reprise du pgm cadb\src\batch\cptmvtgi.p

01  |  08/04/98  |  CD  | calcul de cecrlnana.mt en fonction du type de repartition
02  |  29/04/99  |  OF  | Plus de mise a jour des mouvements pour les comptes de cumul collectifs
03  |  20/05/99  |  OF  | Mise a jour du solde euro pour la difference de conversion
04  |  23/05/00  |  OF  | Gestion des plantages pendant la mise a jour des balances (Creation aparm)
    |            |      | Suppr. de la maj des balances analytiques
05  |  14/06/01  |  PZ  | ijou n'était jamais available
06  |  12/10/01  |  CC  | Arrondis analytiques
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/majdispo.i}

procedure cptmvtgiMajBalDispo:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service utilisé par codlet.p, cptagli.p, cptaprov.p, cptmvtgi.p et cnummvt.i
    ------------------------------------------------------------------------------*/
    define input parameter prRecnoSai as rowid no-undo.

    define variable vdSolde     as decimal no-undo.
    define variable vdSoldeEuro as decimal no-undo.
    define variable vdTot       as decimal no-undo.
    define variable viI         as integer no-undo.
    define variable tmp-cron    as logical no-undo.  /*gga todo pourquoi cette variable et d'ou vient elle (trt batch ?) */

    define buffer cecrsai   for cecrsai.
    define buffer ietab     for ietab.
    define buffer isoc      for isoc.
    define buffer cecrln    for cecrln.
    define buffer ijou      for ijou.
    define buffer cecrlnana for cecrlnana.
    define buffer ccptmvt   for ccptmvt.
    define buffer aparm     for aparm.

    /*** Problemes d'arrondis devise ***/
    find first cecrsai no-lock where prRecnoSai = rowid(cecrsai) no-error.
    find first ietab no-lock
         where ietab.soc-cd = cecrsai.soc-cd
           and ietab.etab-cd = cecrsai.etab-cd no-error.
    find first isoc no-lock where isoc.soc-cd = cecrsai.soc-cd no-error.
    for each cecrln no-lock
        where cecrln.soc-cd         = cecrsai.soc-cd
          and cecrln.mandat-cd      = cecrsai.etab-cd
          and cecrln.jou-cd         = cecrsai.jou-cd
          and cecrln.mandat-prd-cd  = cecrsai.prd-cd
          and cecrln.mandat-prd-num = cecrsai.prd-num
          and cecrln.piece-int      = cecrsai.piece-int:
        assign
            viI         = viI + 1
            vdSolde     = vdSolde     + (if cecrln.sens then cecrln.mt      else - cecrln.mt)
            vdSoldeEuro = vdSoldeEuro + (if cecrln.sens then cecrln.mt-EURO else - cecrln.mt-EURO)
        .
    end.
    find first ijou no-lock
         where ijou.soc-cd    = cecrsai.soc-cd
           and ijou.etab-cd   = cecrsai.etab-cd
           and ijou.jou-cd    = cecrsai.jou-cd
           and ijou.natjou-gi = 93 no-error.
    if cecrsai.dev-cd <> ietab.dev-cd
    then do:
        {&_proparse_ prolint-nowarn(use-index)}
        if viI = 1 and available ijou then.                    /*** AVAILABLE ilibnatjou AND ilibnatjou.anouveau AND ***/
        else if vdSolde < 1 and vdSolde > -1
        then for last cecrln exclusive-lock
           where cecrln.soc-cd         = cecrsai.soc-cd
             and cecrln.mandat-cd      = cecrsai.etab-cd
             and cecrln.jou-cd         = cecrsai.jou-cd
             and cecrln.mandat-prd-cd  = cecrsai.prd-cd
             and cecrln.mandat-prd-num = cecrsai.prd-num
             and cecrln.piece-int      = cecrsai.piece-int
          use-index ecrln-mandat: // dans l'ordre lig, evite ecrln-sci
            /**Ajout OF le 20/05/99 : On soustrait le montant en euro du solde puis on le rajoute
            apres l'assignation du montant donc apres le declenchement du trigger afin d'avoir
            un solde en euro correct **/
            if cecrln.sens
            then assign
                vdSoldeEuro = vdSoldeEuro - cecrln.mt-euro
                cecrln.mt   = cecrln.mt   - vdSolde
                vdSoldeEuro = vdSoldeEuro + cecrln.mt-euro
            .
            else assign
                vdSoldeEuro = vdSoldeEuro + cecrln.mt-euro
                cecrln.mt   = cecrln.mt   + vdSolde
                vdSoldeEuro = vdSoldeEuro - cecrln.mt-euro
            .
            if cecrln.analytique
            then do:
                vdTot = 0.
                for each cecrlnana exclusive-lock
                    where cecrlnana.soc-cd    = cecrln.soc-cd
                      and cecrlnana.etab-cd   = cecrln.etab-cd
                      and cecrlnana.jou-cd    = cecrln.jou-cd
                      and cecrlnana.prd-cd    = cecrln.prd-cd
                      and cecrlnana.prd-num   = cecrln.prd-num
                      and cecrlnana.piece-int = cecrln.piece-int
                      and cecrlnana.lig       = cecrln.lig
                    break by cecrlnana.pos:
                    /*=========================================================+
                    | CD le 08/04/98                                           |
                    | le mt en Fr est recalculee differement si la repartition |
                    | est en montant ou en pourcentage car en repartition en   |
                    | montant les pourcentages ne sont pas tjs renseignes      |
                    | De plus, il faut tenir compte de taux-cle en pourcentage |
                    +=========================================================*/
                    if cecrlnana.typeventil
                    then cecrlnana.mt = {compta/include/iconvfrf.i cecrln.dacompta cecrsai.dev-cd cecrlnana.mtdev cecrsai.cours}. /*** montant ***/
                    /*gga todo a revoir pourquoi conv euro ???? */
                    else cecrlnana.mt = cecrln.mt * cecrlnana.pourc / 100 * cecrlnana.taux-cle / 100. /*** pourcentage ***/
                    /****     ACCUM cecrlnana.mt (TOTAL).  006 ***/
                    vdTot = vdTot + (if cecrlnana.sens = cecrln.sens then cecrlnana.mt else - cecrlnana.mt).
                    if last(cecrlnana.pos) and absolute(vdTot - cecrln.mt) < 1
                    then do:
                        cecrlnana.mt = cecrlnana.mt + ((cecrln.mt - vdTot) * (if cecrlnana.sens = cecrln.sens then 1 else - 1)).
                        if cecrlnana.mt < 0
                        then assign
                            cecrlnana.sens = not cecrlnana.sens
                            cecrlnana.mt   = absolute(cecrlnana.mt)
                        .
                    end.
                end.
            end.
        end.
    end.

    if vdSoldeEuro <> 0 and ietab.maj-batch > 0 and not tmp-cron and not available ijou and isoc.tx-euro <> 1
    then /*gga todo a revoir quand j'aurais l'appli et voir si necessaire run value(RpRunBat + "crelock.p") ("E", string(vdSoldeEuro) + "|" + string(iLig), prRecnoSai).   */ .
    else if vdSoldeEuro <> 0 and not available ijou and isoc.tx-euro <> 1
    then do:
        /*gga todo a revoir quand j'aurais l'appli et voir si necessaire  {comm/appelspe.i RpRunBat "otelocka.p" "string(vdSoldeEuro) + '|' + string(iLig)" "prRecnoSai" }    */
    end.

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

    for each cecrln no-lock
       where cecrln.soc-cd         = cecrsai.soc-cd
         and cecrln.mandat-cd      = cecrsai.etab-cd
         and cecrln.jou-cd         = cecrsai.jou-cd
         and cecrln.mandat-prd-cd  = cecrsai.prd-cd
         and cecrln.mandat-prd-num = cecrsai.prd-num
         and cecrln.piece-int      = cecrsai.piece-int:
        find first ccptmvt exclusive-lock
             where ccptmvt.soc-cd     = cecrln.soc-cd
               and ccptmvt.etab-cd    = cecrln.etab-cd
               and ccptmvt.sscoll-cle = cecrln.sscoll-cle
               and ccptmvt.cpt-cd     = cecrln.cpt-cd
               and ccptmvt.prd-cd     = cecrln.prd-cd
               and ccptmvt.prd-num    = cecrln.prd-num no-error.
        {compta/include/cptmvt.i cecrln.sscoll-cle cecrln.cpt-cd}        /* MAJ de mouvement de compte ou creation */
        run majdispo (buffer cecrln, true, "cecrln").                     /* MAJ du disponible */
    end.

    for first aparm exclusive-lock
        where aparm.tppar = "BALANCE"
          and aparm.cdpar = string(prRecnoSai)
          and aparm.soc-cd = cecrsai.soc-cd:
        delete aparm.
    end.

end procedure.
