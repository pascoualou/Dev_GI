/*-----------------------------------------------------------------------------
File        : prrubass.i
Purpose     : Procedures de recherche d'une rubrique associée pour la régul de Quittancement (Facture Sortie, Annulation
Author(s)   : SY 2009/12/03 - GGA 2018/06/18
Notes       : reprise de comm/PrRubAss.i
derniere revue: 2018/07/28 - phm: OK

01  17/01/2014  SY    1113/0188 REGUL TVA de Janvier 2014 (ALLIANZ)
02  21/01/2014  SY    1113/0188 Ajout rub 211 -> 260
03  30/05/2014  SY    MERGE CARTURIS lot 8-501
-----------------------------------------------------------------------------*/

procedure rchRubRegul private:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define input  parameter piRubrique         as integer  no-undo.
    define input  parameter piLibelle          as integer  no-undo.
    define input  parameter pdeMontantRubrique as decimal  no-undo.
    define output parameter plExisteRubrique   as logical  no-undo.
    define output parameter piRubriqueAssociee as integer  no-undo.
    define output parameter piLibelleAssocie   as integer  no-undo.

    define variable viCodeFamille      as integer   no-undo.
    define variable viCodeSousFamille  as integer   no-undo.
    define variable vcCodeSigne        as character no-undo.
    define variable viRubriqueAssociee as integer   no-undo.
    define variable viLibelleAssocie   as integer   no-undo.
    define variable vcCodeSigneAssocie as character no-undo.

    define buffer vbRubqt  for rubqt.
    define buffer vb2Rubqt for rubqt.

    for first vbRubqt no-lock
        where vbRubqt.cdrub = piRubrique
          and vbRubqt.cdlib = piLibelle:
        assign
            viCodeFamille     = vbRubqt.cdfam
            viCodeSousFamille = vbRubqt.cdsfa
            vcCodeSigne       = vbRubqt.cdsig
        .
        case piRubrique:
            when 771 then for first vb2Rubqt no-lock   /* Rub 751 CRL Variable Pos/neg */
                where vb2Rubqt.cdfam = viCodeFamille
                  and vb2Rubqt.cdsfa = viCodeSousFamille
                  and vb2Rubqt.cdlib = piLibelle
                  and vb2Rubqt.cdgen = "00003"
                  and vb2Rubqt.cdrub = 751:
                assign
                    viRubriqueAssociee = vb2Rubqt.cdrub
                    viLibelleAssocie = vb2Rubqt.cdLib
                .
            end.
            when 111 then assign                  /* SY le 21/05/2007: cas particulier rub MEH 111 calculée */
                viRubriqueAssociee = 107          /* Divers */
                viLibelleAssocie   = 01
                vcCodeSigneAssocie = "00002"
            .
            when 102 then assign                  /* SY le 12/06/2013 : cas particulier rub remise loyer */
                viRubriqueAssociee = 107          /* Divers */
                viLibelleAssocie   = piLibelle
                vcCodeSigneAssocie = "00002"
            .
            when 108 then assign
                viRubriqueAssociee = 107          /* Divers */
                viLibelleAssocie   = (if piLibelle = 01 then 01 else 99)
                vcCodeSigneAssocie = "00002"
            .
            when 104 then assign                  /* Ajout SY le 17/01/2014 - 1113/0188 REGUL TVA de Janvier 2014 (ALLIANZ) (Franchise) */
                viRubriqueAssociee = 107          /* Divers */
                viLibelleAssocie   = (if piLibelle = 01 then 01 else 99)
                vcCodeSigneAssocie = "00002"
            .
            when 152 then assign                  /* Ajout SY le 17/01/2014 - 1113/0188 REGUL TVA de Janvier 2014 (ALLIANZ) (Loyer RIE) */
                viRubriqueAssociee = 153          /* Autre recettes  */
                viLibelleAssocie   = piLibelle
                vcCodeSigneAssocie = "00002"
            .
            when 211 then assign                  /* Ajout SY le 21/01/2014 - 1113/0188 REGUL TVA de Janvier 2014 (ALLIANZ)  */
                viRubriqueAssociee = 260
                viLibelleAssocie   = piLibelle
                vcCodeSigneAssocie = "00002"
            .
            when 635 then assign                  /* Ajout SY le 17/01/2014 - 1113/0188 REGUL TVA de Janvier 2014 (ALLIANZ) */
                viRubriqueAssociee = 636          /* Honoraires sur loyer */
                viLibelleAssocie   = piLibelle
                vcCodeSigneAssocie = "00002"
            .
            otherwise do:
                /** TVA **/
                if piRubrique >= 770 and piRubrique < 800       /* ajout SY le 22/03/2010, 771 traité plus haut. */
                then do:
                    if pdeMontantRubrique >= 0
                    then for first vb2Rubqt no-lock    /* RAPPEL */
                        where vb2Rubqt.cdfam = viCodeFamille
                          and vb2Rubqt.cdsfa = viCodeSousFamille
                          and vb2Rubqt.cdlib = piLibelle
                          and vb2Rubqt.cdgen = "00003"
                          and vb2Rubqt.cdrub = (piRubrique - (if piRubrique < 782 then 10 else 20))
                          and not (vb2Rubqt.cdrub >= 750 and vb2Rubqt.cdrub < 760):
                        assign
                            viRubriqueAssociee = vb2Rubqt.cdrub
                            viLibelleAssocie   = vb2Rubqt.cdLib
                        .
                    end.
                end.
                else for first vb2Rubqt no-lock  /*  SY le 10/03/2005: RECHERCHE DE LA RUBRIQUE ASSOCIEE POUR FAIRE UN RAPPEL/AVOIR ou RUB POS/NEG */
                    where vb2Rubqt.asrub = piRubrique
                      and vb2Rubqt.aslib = piLibelle
                      and vb2Rubqt.cdgen <> "00007":         /* Ajout SY le 10/03/2006: ne pas prendre la rub rappel/avoir Révision (642, 105...) */
                    assign
                        viRubriqueAssociee = vb2Rubqt.cdrub
                        viLibelleAssocie   = vb2Rubqt.cdLib
                        vcCodeSigneAssocie = vb2Rubqt.cdsig
                    .
                end.
            end.
        end case.

        if viRubriqueAssociee = 0 then do:
            /* rubrique associée non trouvée */
            if                              (vcCodeSigne = "00002" or vcCodeSigne = "00005" or vcCodeSigne = "00008")
            or (pdeMontantRubrique >= 0 and (vcCodeSigne = "00000" or vcCodeSigne = "00003" or vcCodeSigne = "00006"))
            or (pdeMontantRubrique < 0  and (vcCodeSigne = "00001" or vcCodeSigne = "00004" or vcCodeSigne = "00007"))
            then assign                             /* on garde la même rubrique */
                viRubriqueAssociee = piRubrique
                viLibelleAssocie   = piLibelle
                vcCodeSigneAssocie = vcCodeSigne
            .
            else do:
                /* impossible de trouver une rubrique associée pour régularisation */
                plExisteRubrique = false.
                return.
            end.
        end.
        if viRubriqueAssociee > 0 then do:
            if (vcCodeSigneAssocie = "00005" or vcCodeSigneAssocie = "00008")
            then if pdeMontantRubrique < 0
                then find first vb2Rubqt no-lock         /* rub Avoir */
                    where vb2Rubqt.cdrub = viRubriqueAssociee
                    and vb2Rubqt.cdlib = (if piLibelle < 50 then piLibelle + 50 else piLibelle) no-error.
                else find first vb2Rubqt no-lock   /* rub Rappel */
                    where vb2Rubqt.cdrub = viRubriqueAssociee
                      and vb2Rubqt.cdlib = (if piLibelle > 50 then piLibelle - 50 else piLibelle) no-error.
            else find first vb2Rubqt no-lock
                where vb2Rubqt.cdrub = viRubriqueAssociee
                  and vb2Rubqt.cdlib = viLibelleAssocie no-error.
            if available vb2Rubqt
            then viLibelleAssocie = vb2Rubqt.cdlib.
        end.
    end.
    assign
        plExisteRubrique   = (viRubriqueAssociee > 0)
        piRubriqueAssociee = viRubriqueAssociee
        piLibelleAssocie   = viLibelleAssocie
    .
end procedure.
