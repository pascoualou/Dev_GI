/*------------------------------------------------------------------------
File        : faletaut.i
Purpose     : Include de Lettrage automatique
Author(s)   : OF - 1997/07/24; gga  -  2017/05/12
Notes       : reprise include cadb\src\gene\faletaut.i, creation d'une procedure faletaut
              Ce programme est utilise par faletaut.w, cletauto.p et edigene\applance.p
17/11/2000, SE: Fiche 1000/0896 : problème de lettrage des écritures à 0.
                Ajout de la variable vlPasseLetAuto.
                Demande CC : utiliser cet include aussi pour applance.p (remplace faletau2.i).
                Ajout des preprocesseurs.
20/11/2000, CC: Suppression prise en compte desequilibre EURO
19/09/2008, DM: 0608/0065 : Mandat 5 chiffres
----------------------------------------------------------------------*/

procedure faletaut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer pbccpt for ccpt.
    define input parameter piCodeEtab   as integer   no-undo.
    define input parameter plTrtSolde   as logical   no-undo.
    define input parameter pcSsColl-cle as character no-undo.
    define input parameter pdaDaDeb-ex  as date      no-undo.
    define input parameter pdaDaFin-ex  as date      no-undo.

    define variable vlPasseLetAuto  as logical   no-undo.
    define variable vdMontantDebit  as decimal   no-undo.
    define variable vdMontantCredit as decimal   no-undo.
    define variable vdSoldeEuro     as decimal   no-undo.
    define variable vdaLettrage     as date      no-undo initial 01/01/1901.
    define variable vcLettre        as character no-undo.

    define buffer cecrln     for cecrln.
    define buffer vbCecrln for cecrln.
    define buffer cecrsai    for cecrsai.
    define buffer ccpt       for ccpt.

    if plTrtSolde
    then do:
        /*** Calcul du solde ***/
        for each cecrln no-lock
            where cecrln.soc-cd      = pbccpt.soc-cd
              and cecrln.etab-cd     = piCodeEtab
              and cecrln.sscoll-cle  = pcSsColl-cle
              and cecrln.cpt-cd      = pbccpt.cpt-cd
              and cecrln.flag-lettre = false
              and cecrln.dacompta    >= pdaDaDeb-ex
              and cecrln.dacompta    <= pdaDaFin-ex:
            vlPasseLetAuto = true.
            if vdaLettrage < cecrln.dacompta then vdaLettrage = cecrln.dacompta.
            if cecrln.sens
            then assign
                vdMontantDebit = vdMontantDebit + cecrln.mt
                vdSoldeEuro    = vdSoldeEuro + cecrln.mt-euro
            .
            else assign
                vdMontantCredit = vdMontantCredit + cecrln.mt
                vdSoldeEuro     = vdSoldeEuro - cecrln.mt-euro
            .
        end.
        /*** Compte solde ***/
        if (vdMontantDebit <> 0 or vdMontantCredit <> 0 or vlPasseLetAuto)
        and vdaLettrage <> 01/01/1901          /* Ceci est un controle, vdaLettrage doit etre ici different de 01/01/1901 */
        and vdMontantDebit = vdMontantCredit
        then do:
            vcLettre = clettre(rowid(pbccpt), "par").
            for each vbCecrln exclusive-lock
                where vbCecrln.soc-cd     = pbccpt.soc-cd
                  and vbCecrln.etab-cd    = piCodeEtab
                  and vbCecrln.sscoll-cle = pcSsColl-cle
                  and vbCecrln.cpt-cd     = pbccpt.cpt-cd
                  and vbCecrln.flag-lettre = false
                  and vbCecrln.dacompta   >= pdaDaDeb-ex
                  and vbCecrln.dacompta   <= pdaDaFin-ex:
                vbCecrln.lettre = caps(vcLettre).
                flag-let(buffer vbCecrln, vdaLettrage).
                if vbCecrln.sscoll-cle > ""
                then for first cecrsai exclusive-lock           /*** MAJ BAP pour Fac/Av ***/
                    where cecrsai.soc-cd    = vbCecrln.soc-cd
                      and cecrsai.etab-cd   = vbCecrln.mandat-cd
                      and cecrsai.jou-cd    = vbCecrln.jou-cd
                      and cecrsai.prd-cd    = vbCecrln.mandat-prd-cd
                      and cecrsai.prd-num   = vbCecrln.mandat-prd-num
                      and cecrsai.piece-int = vbCecrln.piece-int
                      and (cecrsai.typenat-cd = 2 or cecrsai.typenat-cd = 3)
                      and not cecrsai.bonapaye:
                    cecrsai.bonapaye = true.
                end.
            end.
            return.
        end.
        else if vdMontantDebit = 0 and vdMontantCredit = 0   /*** Pas de mouvement ***/
             then return.
    end.

    {&_proparse_ prolint-nowarn(sortaccess)}
ecriture:
    for each cecrln exclusive-lock
        where cecrln.soc-cd      = pbccpt.soc-cd
          and cecrln.etab-cd     = piCodeEtab
          and cecrln.sscoll-cle  = pcSsColl-cle
          and cecrln.cpt-cd      = pbccpt.cpt-cd
          and cecrln.flag-lettre = false
          and cecrln.dacompta    >= pdaDaDeb-ex
          and cecrln.dacompta    <= pdaDaFin-ex
          and cecrln.ref-num     > ""
        break by entry(1, cecrln.ref-num, "#")
              by cecrln.lettre descending:
        if first-of(entry(1, cecrln.ref-num, "#")) and last-of(entry(1, cecrln.ref-num, "#"))
        then do:
            if cecrln.mt = 0 then do:
                vcLettre = cecrln.lettre.
                /*** Lettrage montant a 0 ***/
                {&_proparse_ prolint-nowarn(weakchar)}
                if vcLettre = ""
                then for first ccpt no-lock
                    where ccpt.soc-cd   = cecrln.soc-cd
                      and ccpt.etab-cd  = cecrln.etab-cd
                      and ccpt.coll-cle = cecrln.coll-cle
                      and ccpt.cpt-cd   = cecrln.cpt-cd:
                    assign
                        vcLettre      = clettre(rowid(ccpt), "par")
                        cecrln.lettre = caps(vcLettre)
                    .
                end.
                vdaLettrage = cecrln.dacompta.
                flag-let(buffer cecrln, vdaLettrage).
            end.
            next ecriture. /*** Il n'y a qu'un seul numero de document ***/
        end.
        else do:                            /*** Lettrage partiel ***/
            if first-of(entry(1, cecrln.ref-num, "#"))
            then do:
                assign
                    vdMontantDebit  = 0
                    vdMontantCredit = 0
                    vdaLettrage     = 01/01/1901
                    vcLettre        = cecrln.lettre
                .
                {&_proparse_ prolint-nowarn(weakchar)}
                if vcLettre = ""
                then for first ccpt no-lock
                    where ccpt.soc-cd   = cecrln.soc-cd
                      and ccpt.etab-cd  = cecrln.etab-cd
                      and ccpt.coll-cle = cecrln.coll-cle
                      and ccpt.cpt-cd   = cecrln.cpt-cd:
                    vcLettre = clettre(rowid(ccpt), "par").
                end.

            end.
            if vdaLettrage < cecrln.dacompta then vdaLettrage = cecrln.dacompta.
            if cecrln.sens
            then vdMontantDebit  = vdMontantDebit + cecrln.mt.
            else vdMontantCredit = vdMontantCredit + cecrln.mt.
            cecrln.lettre = caps(vcLettre).
            flag-let (buffer cecrln, ?).
        end.
        if last-of(entry(1, cecrln.ref-num, "#")) and vdaLettrage <> 01/01/1901
        then do:
            assign
                vdMontantDebit  = 0
                vdMontantCredit = 0
                vdSoldeEuro     = 0
            .
            /*** CALCUL DU SOLDE DE LA LETTRE ***/
            for each vbCecrln no-lock
                where vbCecrln.soc-cd  = pbccpt.soc-cd
                  and vbCecrln.etab-cd    = piCodeEtab
                  and vbCecrln.sscoll-cle = cecrln.sscoll-cle
                  and vbCecrln.cpt-cd     = cecrln.cpt-cd
                  and vbCecrln.lettre     = vcLettre
                  and vbCecrln.dacompta  >= pdaDaDeb-ex
                  and vbCecrln.dacompta  <= pdaDaFin-ex:
                if vbCecrln.sens
                then assign
                    vdMontantDebit = vdMontantDebit + vbCecrln.mt
                    vdSoldeEuro    = vdSoldeEuro + vbCecrln.mt-euro
                .
                else assign
                    vdMontantCredit = vdMontantCredit + vbCecrln.mt
                    vdSoldeEuro     = vdSoldeEuro - vbCecrln.mt-euro
                .
            end.
            if vdMontantDebit = vdMontantCredit
            then do:
                /*** Lettrage total ***/
                for each vbCecrln exclusive-lock
                    where vbCecrln.soc-cd     = pbccpt.soc-cd
                      and vbCecrln.etab-cd    = piCodeEtab
                      and vbCecrln.sscoll-cle = cecrln.sscoll-cle
                      and vbCecrln.cpt-cd     = cecrln.cpt-cd
                      and vbCecrln.lettre     = vcLettre
                      and vbCecrln.dacompta   >= pdaDaDeb-ex
                      and vbCecrln.dacompta   <= pdaDaFin-ex:
                    vbCecrln.lettre = caps(vbCecrln.lettre).
                    flag-let (buffer vbCecrln, vdaLettrage).
                    for first cecrsai exclusive-lock
                        where cecrsai.soc-cd    = vbCecrln.soc-cd
                          and cecrsai.etab-cd   = vbCecrln.mandat-cd
                          and cecrsai.jou-cd    = vbCecrln.jou-cd
                          and cecrsai.prd-cd    = vbCecrln.mandat-prd-cd
                          and cecrsai.prd-num   = vbCecrln.mandat-prd-num
                          and cecrsai.piece-int = vbCecrln.piece-int
                          and (cecrsai.typenat-cd = 2 or cecrsai.typenat-cd = 3)
                          and not cecrsai.bonapaye:
                        cecrsai.bonapaye = true.
                    end.
                end.
            end. /* solde de la lettre a zero */
        end. /** LAST-OF **/
    end. /** FOR EACH cecrln **/

end procedure.
