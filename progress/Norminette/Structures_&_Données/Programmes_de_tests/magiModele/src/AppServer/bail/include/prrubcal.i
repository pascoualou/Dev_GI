/*------------------------------------------------------------------------
File        : prrubcal.i
Purpose     : Procedures pour les rubriques calculées (tache 04360)
Author(s)   : SY 2009/12/03, kantena 2017/11/27 
Notes       : vient de comm/prrubcal.i
Fiche       : 1108/0397, Quittancement\QuitRubriqueCalculeeV02.doc
 ENVIRONNEMENT NECESSAIRE:
 - include : {isTaxCRL.i}    : recherche si bail soumis à CRL
 - FUNCTION f_librubqt RETURNS CHARACTER
      ( INPUT NoRubUse-IN AS INTEGER , INPUT NoLibUse-IN AS INTEGER
      , INPUT NoRolUse-IN AS INTEGER , INPUT MsQttUse-IN AS INTEGER)
 - PROCEDURE CalMntRub(1 si rub ou 2 si base de calcul
                     , no rub ou code base de calcul (O_BSH)
                     , no lib ou blanc
                     , OUTPUT vdeTotalCum
                     , OUTPUT vdeMontantCum).
 01  01/03/2012  SY    0212/0264 Gestion du code signe rubrique
 02  07/11/2013  SY    1013/0167 Filtrer Nlle rub TVA 10% et 20%
------------------------------------------------------------------------*/

procedure chgRubcal:
    /*------------------------------------------------------------------------
    Purpose : Procedure de création de la table des rubriques calculées du bail 
    Notes   :
    ------------------------------------------------------------------------*/
    define input  parameter pcTypeBail          as character no-undo.
    define input  parameter piNumeroBail        as int64     no-undo.
    define input  parameter piMoisQuittancement as integer   no-undo.
    define input  parameter pdeLoyerMensuel     as decimal   no-undo.
    define input  parameter pdeLoyerMinimum     as decimal   no-undo.
    define output parameter plCreation          as logical   no-undo.

    define variable voSyspr        as class syspr no-undo.    
    define variable vdeTotalCum    as decimal   no-undo.
    define variable vdeMontantCum  as decimal   no-undo.
    define variable vdeTotalCal    as decimal   no-undo.
    define variable vdeMontantCal  as decimal   no-undo.
    define variable vdeTauxTva     as decimal   no-undo.
    define variable vdeTauxCrl     as decimal   no-undo.
    define variable vdePcLocCrl    as decimal   no-undo.
    define variable vdeTotalCrl    as decimal   no-undo.
    define variable vdeMontantCrl  as decimal   no-undo.
    define variable vcCodeSigne    as character no-undo.
    define variable viCodeRubrique as integer   no-undo.
    define variable viCodeLibelle  as integer   no-undo.

    define buffer detail     for detail.
    define buffer vbRubqt    for rubqt.
    define buffer vbttRubCal for ttRubCal.
    
    voSyspr = new syspr("CDQPL", "").    // instancié avant boucle.
boucleDetail:
    for each detail no-lock
        where detail.cddet = pcTypeBail
          and detail.nodet = piNumeroBail
          and detail.iddet = integer({&TYPETACHE-quittancementRubCalculees})
        by detail.cddet by detail.nodet by detail.iddet by detail.ixd01:
        assign
            plCreation     = true
            viCodeRubrique = integer(substring(detail.ixd01, 1, 3, "character"))
            viCodeLibelle  = integer(substring(detail.ixd01, 4, 2, "character"))
        .
        find first rubqt no-lock
            where rubqt.cdrub = viCodeRubrique
              and rubqt.cdlib = viCodeLibelle no-error.
        if not available rubqt then next boucleDetail.

        find first ttRubCal
            where ttRubCal.cdrub = viCodeRubrique
              and ttRubCal.cdlib = viCodeLibelle no-error.
        if not available ttRubCal then do:
            create ttRubCal.
            assign
                ttRubCal.cdrub    = viCodeRubrique
                ttRubCal.cdlib    = viCodeLibelle
                ttRubCal.lib      = f_libRubQt(ttRubCal.cdrub, ttRubCal.cdlib, piNumeroBail, 0)
                ttRubCal.fg-rubtva= false
                ttRubCal.fg-calc  = true                  /* rubrique calculée */
                ttRubCal.cdfam    = rubqt.cdfam
                ttRubCal.cdsfa    = rubqt.cdsfa
            .                                       
        end.
        /* calcul à partir d'une rubrique ou d'une base de calcul */    
        assign
            vdeTotalCum   = 0
            vdeMontantCum = 0
            vcCodeSigne   = "00000"  /* Positif */
        .     
        if detail.tbint[1] = 1 then do:
            assign
                viCodeRubrique = integer(substring(detail.ixd02, 1, 3, "character"))
                viCodeLibelle  = integer(substring(detail.ixd02, 4, 2, "character"))
            .
            run calMntRub(detail.tbint[1],
                          string(viCodeRubrique, "999"),   // cdrub
                          string(viCodeLibelle, "99"),     // cdlib
                          output vdeTotalCum, 
                          output vdeMontantCum).
            for first vbRubqt no-lock
                where vbRubqt.cdrub = viCodeRubrique
                  and vbRubqt.cdlib = viCodeLibelle:
                vcCodeSigne = vbRubqt.cdsig.
            end.
        end.
        else run calMntRub(
            detail.tbint[1],
            detail.tbchr[1],  /* code O_BSH */ 
            "",
            output vdeTotalCum,
            output vdeMontantCum).        
        assign
            vdeTotalCal   = round(vdeTotalCum   * detail.tbdec[1] / 100, 2)
            vdeMontantCal = round(vdeMontantCum * detail.tbdec[1] / 100, 2)
        .
        if rubqt.cdsig = "00000" or rubqt.cdsig = "00003" or rubqt.cdsig = "00006" then do:    
            /* positif */
            if vdeTotalCal < 0
            and (vcCodeSigne = "00000" or vcCodeSigne = "00003" or vcCodeSigne = "00006")
            then assign
                vdeTotalCal   = 0           /* pas de calcul sur Avoir loyer */
                vdeMontantCal = 0
            .
        end.
        else if rubqt.cdsig = "00001" or rubqt.cdsig = "00004" or rubqt.cdsig = "00007" then do:
            /* negatif */
            if vdeTotalCal < 0 then do:    
                if vcCodeSigne = "00000" or vcCodeSigne = "00003" or vcCodeSigne = "00006"
                then assign
                    vdeTotalCal   = 0       /* pas de remise sur Avoir loyer */
                    vdeMontantCal = 0
                .
            end. 
            else assign
                vdeTotalCal   = - vdeTotalCal
                vdeMontantCal = - vdeMontantCal
            .
        end.
        /* rappel (lib < 50) / avoir (lib > 50) */
        /* SY le 01/03/2012 : là je ne sais pas quoi faire ...*/        
        else if (rubqt.cdsig = "00005" or rubqt.cdsig = "00008")
        and ((vdeTotalCal < 0 and rubqt.cdlib < 50) or (vdeTotalCal > 0 and rubqt.cdlib > 50))
        then assign
            vdeTotalCal   = - vdeTotalCal
            vdeMontantCal = - vdeMontantCal
        .
        assign
            ttRubCal.MtTot = ttRubCal.MtTot + vdeTotalCal            /* Montant total rubrique */
            ttRubCal.vlmtq = ttRubCal.vlmtq + vdeMontantCal          /* Montant rubrique quittancé*/
        .                    
        if not detail.tblog[1] then do:
            if detail.ixd03 = {&TYPETACHE-TVABail} then do:
                /* Recherche du taux de tva à appliquer => no rubrique associée */
                voSyspr:reload(detail.tbchr[2], detail.tbchr[3]).
                if voSyspr:isDbParameter then do:
                    vdeTauxTva = voSyspr:zone1.
                    /* Recherche de la rubrique tva associée au taux */
                    if not can-find(first rubqt no-lock
                        where rubqt.cdfam = 05
                          and rubqt.cdsfa = 02
                          and rubqt.cdrub < 770
                          and rubqt.cdlib > 00
                          and rubqt.cdlib < 99
                          and rubqt.cdgen = {&GenreRubqt-Variable} /* Variable (pas la TVA Calcul) */    /* SY 1013/0167 */
                          and rubqt.cdsig = "00002"                /* positif/négatif */
                          and rubqt.prg04 = string(vdeTauxTva * 100)) then next boucleDetail.

                    find first vbttRubCal
                        where vbttRubCal.cdrub = rubqt.cdrub
                          and vbttRubCal.cdlib = rubqt.cdlib no-error.
                    if not available vbttRubCal then do:
                        create vbttRubCal.
                        assign
                            vbttRubCal.cdrub     = rubqt.cdrub
                            vbttRubCal.cdlib     = rubqt.cdlib
                            vbttRubCal.lib       = f_libRubQt(vbttRubCal.cdrub, vbttRubCal.cdlib, piNumeroBail, 0)    
                            vbttRubCal.fg-rubtva = yes
                            vbttRubCal.fg-calc   = yes                    /* rubrique calculée */
                            vbttRubCal.cdfam     = rubqt.cdfam
                            vbttRubCal.cdsfa     = rubqt.cdsfa
                            vbttRubCal.taux      = vdeTauxTva                /* taux TVA */
                        .                                                                        
                    end.
                     /* cumul à la rubrique */
                    assign                    
                        vbttRubCal.mttot = vbttRubCal.mttot + round(vdeTotalCal   * vdeTauxTva / 100 , 2)    
                        vbttRubCal.VlMtq = vbttRubCal.VlMtq + round(vdeMontantCal * vdeTauxTva / 100 , 2)    
                        ttRubCal.rubtva  = vbttRubCal.cdrub    /* rub TVA associée */
                        ttRubCal.taux    = vdeTauxTva          /* taux TVA */    
                    .
                end.
            end.    /* TVA */

            if detail.ixd03 = "04055" then do:               /* CRL ? */
                if not isTaxCRL(integer(truncate(piNumeroBail / 100000, 0)),    // Numero contrat
                                piMoisQuittancement,
                                pdeLoyerMensuel,
                                pdeLoyerMinimum) then next boucleDetail.

                /* Recherche du taux de CRL à appliquer  */
                assign
                    vdeTauxCrl  = 0
                    vdePcLocCrl = 0
                .
                voSyspr:reload(detail.tbchr[2], detail.tbchr[3]).
                if voSyspr:isDbParameter then vdeTauxCrl = voSyspr:Zone1.
                voSyspr:reload("CDQPL", detail.tbchr[4]).
                if voSyspr:isDbParameter then vdePcLocCrl = voSyspr:Zone1.                        

                find first vbttRubCal
                    where vbttRubCal.cdrub = 751
                      and vbttRubCal.cdlib = 02 no-error.
                if not available vbttRubCal then do:
                    find first rubqt no-lock  
                        where rubqt.cdrub = 751
                          and rubqt.cdlib = 02 no-error.                
                    create vbttRubCal.
                    assign
                        vbttRubCal.cdrub     = 751
                        vbttRubCal.cdlib     = 02
                        vbttRubCal.lib       = f_libRubQt(vbttRubCal.cdrub, vbttRubCal.cdlib, piNumeroBail, 0)
                        vbttRubCal.fg-rubtva = false
                        vbttRubCal.fg-calc   = true              /* rubrique calculée */
                        vbttRubCal.cdfam     = rubqt.cdfam
                        vbttRubCal.cdsfa     = rubqt.cdsfa
                    .                                             
                end.
                assign
                    vdeTotalCrl   = round(vdeTotalCal   * vdeTauxCrl / 100, 2) /* taux + quote-part */
                    vdeMontantCrl = round(vdeMontantCal * vdeTauxCrl / 100, 2)
                    vdeTotalCrl   = round(vdeTotalCrl   * vdePcLocCrl / 100, 2)
                    vdeMontantCrl = round(vdeMontantCrl * vdePcLocCrl / 100, 2)
                    vbttRubCal.mttot = vbttRubCal.mttot + vdeTotalCrl          /* cumul à la rubrique */
                    vbttRubCal.VlMtq = vbttRubCal.VlMtq + vdeMontantCrl    
                .
            end.    /* CRL */                
        end.    /* ne suit pas la fiscalité du bail */
    end.
    delete object voSyspr no-error.
end procedure.
