/*------------------------------------------------------------------------
File        : alettrau.i
Purpose     : Include de Lettrage automatique
Author(s)   : CC - , Kantena - 2018/01/11
Notes       : vient de cadb/src/batch/alettrau.i
    UTILISE PAR batch\adecla.p, batch\adecla1.p, batch\adecla2.p
------------------------------------------------------------------------*/
    // variables de alettrau.i
    define variable vdeMontantDebit  as decimal   no-undo.
    define variable vdeMontantCredit as decimal   no-undo.
    define variable vcLettre         as character no-undo.
    define variable vdaLettrage      as date      no-undo.
    define variable vlPasseLetAuto   as logical   no-undo.
    define variable viBoucle         as integer   no-undo.
    define buffer cecrln     for cecrln.
    define buffer cecrln-buf for cecrln.
    define buffer cecrsai    for cecrsai.
    define buffer ccpt       for ccpt.

    // variables de flag-let.i, pas dans l'include, car elles ne doivent pas être réinitialisées dans la boucle
    define variable vcSousCollectif as character no-undo.
    define variable vcCompte        as character no-undo.
    define variable vcLettre2       as character no-undo.
    define variable vlInstallTva    as logical   no-undo.
    define variable vlCreation      as logical   no-undo.
    define buffer ilibnatjou for ilibnatjou.
    define buffer csscptcol  for csscptcol.
    define buffer ctvamod for ctvamod.

    {&_proparse_ prolint-nowarn(wholeIndex)}
    assign
        vdeMontantDebit  = 0
        vdeMontantCredit = 0
        vdaLettrage      = 01/01/1901
        vlInstallTva     = can-find(first iparam no-lock where iparam.install-tva = true)
    .
    /*** Calcul du solde ***/
    for each cecrln no-lock
        where cecrln.soc-cd      = giCodesoc
          and cecrln.etab-cd     = giCodeetab
          and cecrln.sscoll-cle  = csscpt.sscoll-cle
          and cecrln.cpt-cd      = csscpt.cpt-cd
          and cecrln.dacompta   >= gdaDebutPeriode
          and cecrln.dacompta   <= gdaDeclaration
          and cecrln.flag-lettre = false:
        // les date étant toutes <> ?, on peut utiliser max.
        assign
            vdaLettrage      = maximum(vdaLettrage, cecrln.dacompta) 
            vlPasseLetAuto   = true
            vdeMontantDebit  = vdeMontantDebit + cecrln.mt when cecrln.sens
            vdeMontantCredit = vdeMontantCredit + cecrln.mt when not cecrln.sens
        .
    end.
    /*** Compte solde ***/
    if (vdeMontantDebit <> 0 or vdeMontantCredit <> 0 or vlPasseLetAuto)
    and vdaLettrage <> 01/01/1901
    and vdeMontantDebit = vdeMontantCredit then do:
        for first ccpt exclusive-lock where rowid(ccpt) = rowid(ccpt-buf):
            {batch/clettre.i "par" giCodeEtab}
        end.
        vcLettre = ccpt-buf.lettre.
        for each cecrln exclusive-lock
            where cecrln.soc-cd = gicodesoc
              and cecrln.etab-cd = gicodeetab
              and cecrln.sscoll-cle =  csscpt.sscoll-cle
              and cecrln.cpt-cd = ccpt-buf.cpt-cd
              and cecrln.dacompta >= gdaDebutPeriode
              and cecrln.dacompta <= gdaDeclaration
              and cecrln.flag-lettre = false:
            cecrln.lettre = caps(vcLettre).
            {batch/flag-let.i vdaLettrage}
            if cecrln.sscoll-cle > ""
            then for first cecrsai exclusive-lock                  /*** MAJ BAP pour Fac/Av ***/
                where cecrsai.soc-cd    = cecrln.soc-cd
                  and cecrsai.etab-cd   = cecrln.mandat-cd
                  and cecrsai.jou-cd    = cecrln.jou-cd
                  and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                  and cecrsai.prd-num   = cecrln.mandat-prd-num
                  and cecrsai.piece-int = cecrln.piece-int
                  and cecrsai.bonapaye  = false
                  and (cecrsai.typenat-cd = 2 or cecrsai.typenat-cd = 3): 
                cecrsai.bonapaye = true.
            end.
        end.
        next COMPTE.
    end.
    else if vdeMontantDebit = 0 and vdeMontantCredit = 0 then next COMPTE.      /*** Pas de mouvement ***/

ECRITURE:
    for each cecrln no-lock
        where cecrln.soc-cd      = gicodesoc
          and cecrln.etab-cd     = gicodeetab
          and cecrln.sscoll-cle  = csscpt.sscoll-cle
          and cecrln.cpt-cd      = ccpt-buf.cpt-cd
          and cecrln.flag-lettre = false
          and cecrln.dacompta   >= gdaDebutPeriode
          and cecrln.dacompta   <= gdaDeclaration
          and cecrln.ref-num     > ""
        break by substring(cecrln.ref-num + "#", 1 , index(cecrln.ref-num + "#", "#") - 1, "character")
              by cecrln.lettre descending:

        if first-of(substring(cecrln.ref-num + "#", 1, index(cecrln.ref-num + "#", "#") - 1, "character"))
        and last-of(substring(cecrln.ref-num + "#", 1, index(cecrln.ref-num + "#", "#") - 1, "character"))
        then do transaction:
            if cecrln.mt = 0 then do:
                /*** Lettrage montant a 0 ***/
                if cecrln.lettre > ""
                then vcLettre = cecrln.lettre.
                else do:
                    for first ccpt exclusive-lock
                        where ccpt.soc-cd   = cecrln.soc-cd
                          and ccpt.coll-cle = cecrln.coll-cle
                          and ccpt.cpt-cd   = cecrln.cpt-cd:
                        {batch/clettre.i "par" giCodeEtab}
                    end.
                    vcLettre = ccpt-buf.lettre.
                end.
                vdaLettrage = cecrln.dacompta.
                for first cecrln-buf exclusive-lock where rowid(cecrln-buf) = rowid(cecrln):
                    cecrln-buf.lettre = caps(vcLettre). 
                    {batch/flag-let.i vdaLettrage -buf}
                end.
            end.
            next ECRITURE. /*** Il n'y a qu'un seul numero de document ***/
        end.
        else do transaction:
            /*** Lettrage partiel ***/
            if first-of(substring(cecrln.ref-num + "#", 1, index(cecrln.ref-num + "#", "#") - 1, "character"))
            then do:
                assign
                    vdeMontantDebit  = 0
                    vdeMontantCredit = 0
                    vdaLettrage      = 01/01/1901
                .
                if cecrln.lettre > ""
                then vcLettre = cecrln.lettre.
                else do:
                    for first ccpt exclusive-lock
                        where ccpt.soc-cd   = cecrln.soc-cd
                          and ccpt.coll-cle = cecrln.coll-cle
                          and ccpt.cpt-cd   = cecrln.cpt-cd:
                        {batch/clettre.i "par" giCodeEtab}
                    end.
                    vcLettre = ccpt-buf.lettre.
                end.
            end.
            if vdaLettrage < cecrln.dacompta then vdaLettrage = cecrln.dacompta.
            if cecrln.sens
            then vdeMontantDebit  = vdeMontantDebit  + cecrln.mt.
            else vdeMontantCredit = vdeMontantCredit + cecrln.mt.
            for first cecrln-buf exclusive-lock where rowid(cecrln-buf) = rowid(cecrln):
                cecrln-buf.lettre = vcLettre.
                {batch/flag-let.i ? -buf}
            end.
        end.
        if last-of(substring(cecrln.ref-num + "#", 1, index(cecrln.ref-num + "#", "#") - 1, "character"))
          and vdaLettrage <> 01/01/1901 then do:
            assign
                vdeMontantDebit  = 0
                vdeMontantCredit = 0
            .
            /*** CALCUL DU SOLDE DE LA LETTRE ***/ 
            for each cecrln-buf no-lock
                where cecrln-buf.soc-cd     = gicodesoc
                  and cecrln-buf.etab-cd    = gicodeetab
                  and cecrln-buf.sscoll-cle = cecrln.sscoll-cle
                  and cecrln-buf.cpt-cd     = cecrln.cpt-cd
                  and cecrln-buf.lettre     = vcLettre
                  and cecrln-buf.dacompta  >= gdaDebutPeriode
                  and cecrln-buf.dacompta  <= gdaDeclaration:
                if cecrln-buf.sens
                then vdeMontantDebit  = vdeMontantDebit  + cecrln-buf.mt.
                else vdeMontantCredit = vdeMontantCredit + cecrln-buf.mt.
            end.
            if vdeMontantDebit = vdeMontantCredit
            then for each cecrln-buf exclusive-lock                 /*** Lettrage total ***/
                where cecrln-buf.soc-cd     = gicodesoc
                  and cecrln-buf.etab-cd    = gicodeetab
                  and cecrln-buf.sscoll-cle = cecrln.sscoll-cle
                  and cecrln-buf.cpt-cd     = cecrln.cpt-cd
                  and cecrln-buf.lettre     = vcLettre
                  and cecrln-buf.dacompta  >= gdaDebutPeriode
                  and cecrln-buf.dacompta  <= gdaDeclaration:
                cecrln-buf.lettre = caps(cecrln-buf.lettre).
                {batch/flag-let.i vdaLettrage -buf}
                for first cecrsai exclusive-lock
                    where cecrsai.soc-cd = cecrln-buf.soc-cd
                      and cecrsai.etab-cd = cecrln-buf.mandat-cd
                      and cecrsai.jou-cd = cecrln-buf.jou-cd
                      and cecrsai.prd-cd = cecrln-buf.mandat-prd-cd
                      and cecrsai.prd-num = cecrln-buf.mandat-prd-num
                      and cecrsai.piece-int = cecrln-buf.piece-int
                      and (cecrsai.typenat-cd = 2 or cecrsai.typenat-cd = 3)
                      and cecrsai.bonapaye = false:
                    cecrsai.bonapaye = true.
                end.
            end.
        end.
    end.
