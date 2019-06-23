
/* PAS DE REVUE POUR LE MOMENT */

/*---------------------------------------------------------------------------
File        : supinter.p
Purpose     : Suppression d'une Intervention (Travaux)
Author(s)   : SY 13/04/2006  -  GGA 2018/02/12
Notes       : reprise adb/lib/supinter.p

---------------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure SupInter:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat         as character no-undo.
    define input parameter piNumeroMandat       as integer   no-undo.
    define input parameter piNumeroIntervention as int64     no-undo.

    define buffer inter for inter.
    define buffer dtven for dtven.
    define buffer dtfac for dtfac.
    define buffer factu for factu.
    define buffer dtord for dtord.
    define buffer ordse for ordse.
    define buffer svdev for svdev.
    define buffer devis for devis.
    define buffer dtdev for dtdev.
    define buffer trint for trint.
    define buffer signa for signa.

    for each inter exclusive-lock
       where inter.tpcon = pcTypeMandat
         and inter.nocon = piNumeroMandat
         and inter.noint = piNumeroIntervention:
        /*--> Suppression des ventilations analytique */
        for each dtven exclusive-lock
           where dtven.noint = inter.noint:
            delete dtven.
        end.
        /*--> Suppression des factures */
        for each dtfac exclusive-lock
           where dtfac.noint = inter.noint:
            for first factu exclusive-lock
                where factu.nofac = dtfac.nofac:
                run supEvenementiel({&TYPEINTERVENTION-facture}, factu.nofac).
                delete factu.
            end.
            delete dtfac.
        end.
        /*--> Suppression des ordres de services */
        for each dtord exclusive-lock
           where dtord.noint = inter.noint:
            for first ordse exclusive-lock
                where ordse.noord = dtord.noord:
                run supEvenementiel({&TYPEINTERVENTION-ordre2service}, ordse.noord).
                delete ordse.
            end.
            delete dtord.
        end.
        /*--> Suppression des réponses fournisseurs */
        for each svdev exclusive-lock
           where svdev.noint = inter.noint:
            for first devis exclusive-lock
                where devis.nodev = svdev.nodev:
                run supEvenementiel({&TYPEINTERVENTION-reponseDevis}, devis.nodev).    // todo vérifier la modif à gauche run supEvenementiel("01061", devis.nodev).
                delete devis.
            end.
            delete svdev.
        end.
        /*--> Suppression des devis */
        for each dtdev exclusive-lock
           where dtdev.noint = inter.noint:
            for first devis exclusive-lock
                where devis.nodev = dtdev.nodev:
                run supEvenementiel({&TYPEINTERVENTION-demande2devis}, devis.nodev).
                delete devis.
            end.
            delete dtdev.
        end.
        /*--> Suppression du suivi travaux */
        for each trint exclusive-lock
           where trint.noint = inter.noint:
            delete trint.
        end.
        /*--> Suppression du signalement */
        for each signa exclusive-lock
           where signa.nosig = inter.nosig:
            run supEvenementiel({&TYPEINTERVENTION-signalement}, signa.nosig).
            delete signa.
        end.
        delete inter.
    end.

end procedure.

procedure supEvenementiel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter TpIdtUse as character no-undo.
    define input parameter NoIdtUse as integer   no-undo.
/*
    {RunPgExp.i &Path       = RpRunEve
                &Prog       = "'SupIdent.p'"
                &Parameter  = "TpIdtUse,NoIdtUse    "}
*/

end procedure.
