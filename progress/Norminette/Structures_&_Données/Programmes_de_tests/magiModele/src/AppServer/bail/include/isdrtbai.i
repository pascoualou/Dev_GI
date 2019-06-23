/*-----------------------------------------------------------------------------
File        : isdrtbai.i
Purpose     :
Author(s)   :               , Kantena - 2017/12/15 
Notes       : reprise de isdrtbai.i dans adb/src/lib/l_prguti_ext.p
-----------------------------------------------------------------------------*/
procedure isdrtbai:
    /*------------------------------------------------------------------------
    Purpose : Procedure d�terminant si le locataire est soumis au droit de Bail � partir 
            (1) des t�ches associ�es au bail           
            (2) soit du fichier ebail pour une p�riode donn�e 
                soit du montant mensuel pour une quittance en cours
           Exon�rations possibles du droit de bail:
            - Bail soumis � TVA
            - Exon�ration "manuelle" dans la t�che droit de bail (UA,RD,SL...)
            - 0 <= Loyer annuel <= 12000 Frs
    parametre de sortie:
        (2) = Flag si calcul ou non taxe          
        (3) = Si pas calcul: Code du type d'exon�ration (param TPEXO)
    ------------------------------------------------------------------------*/
    define input  parameter piContratBail      as integer   no-undo.
    define input  parameter pcModeCalcul      as character no-undo.
    define input  parameter pdeLoyerMensuel   as decimal   no-undo.
    define output parameter plCalculTaxe      as logical   no-undo initial true.
    define output parameter pcTypeExoneration as character no-undo.
    
    define variable vdeMontantLoyerMinimum as decimal   no-undo.
    define variable vdeMontantLoyerAnnuel  as decimal   no-undo.
    define buffer cttac for cttac.
    define buffer tache for tache.
    /* Recherche si lien contrat Bail-t�che TVA existe */
    find first cttac no-lock
        where cttac.tpcon = "01033"
          and cttac.nocon = piContratBail
          and cttac.tptac = "04039" no-error.
    if available cttac then assign 
        plCalculTaxe      = false
        pcTypeExoneration = "00007"  /* exon�ration 'TVA' */
    .
    else do:
        /* Recherche si lien contrat Bail-t�che Dba existe */
        find first cttac no-lock
            where cttac.tpcon = "01033"
              and cttac.nocon = piContratBail
              and cttac.tptac = "04036" no-error.
        if available cttac then do:
            /* Recherche s'il y a exon�ration "Manuelle" */
            find first tache no-lock
                where tache.tpcon = "01033" 
                  and tache.nocon = piContratBail
                  and tache.tptac = "04036" no-error.
            if available tache then do:
                if tache.tpges = "YES" then assign    /* exon�r� ? */
                     pcTypeExoneration = tache.pdges           /* motif exon�ration   */
                     plCalculTaxe      = false
                .
                else do:
                    if tache.dcreg = "A" then do:       /* motif exon�ration   */
                        /* Recherche du loyer mini forfaitaire (12000) */
                        goSyspr:reload("MTFIS", "00001").
                        vdeMontantLoyerMinimum = goSyspr:zone1.
                        /* Exon�ration A49: Loyer Annuel <= 12000 Frs */
                        if pcModeCalcul = "2"
                        then vdeMontantLoyerAnnuel = pdeLoyerMensuel * 12.  /* Estimation � partir du Loyer Mensuel */
                        if absolute(vdeMontantLoyerAnnuel) <= vdeMontantLoyerMinimum
                        then assign 
                            plCalculTaxe      = false
                            pcTypeExoneration = "00002"  /* exon�ration 'A49' */
                        .
                    end.
                    else assign
                        plCalculTaxe      = false
                        pcTypeExoneration = "00002" /* exon�ration 'A49' */
                    .
                end.
            end.
        end.
    end.
end procedure.

