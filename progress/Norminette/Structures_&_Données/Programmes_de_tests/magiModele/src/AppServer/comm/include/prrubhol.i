/*-----------------------------------------------------------------------------
File        : prrubhol.i
Purpose     : Procedures pour les rubriques Honoraires Cabinet quittancé LF à FX avec % ventilation (ICADE)
Author(s)   : SY 2009/12/03, Kantena - 2017/12/15
Notes       : reprise de comm/prrubhol.i
01  19/03/2010  SY    1108/0443 Si Hono Loc par le quit alors Rub 8xx doivent se prorater/cumuler comme les anciennes Rubriques Extournables (IsRubProCum)
02  22/03/2010  SY    1108/0443 Modif IsRubProCum pour ajouter tous les cas filtrés en facture de sortie
03  09/06/2010  SY    0610/0058 Modif IsRubProCum : PAS de proratas pour Prime Assurance (506 & 821)
04  07/07/2010  SY    0710/0034 Modif IsRubProCum : PAS de proratas pour Pack Services (834)
05  21/09/2012  SY    BNP: Ajout proratas à faire sur Rub 865.xx services para-hoteliers
06  24/09/2012  SY    BNP: Ajout proratas entrée/sortie sur Toutes les Rub 8xx FIXES
07  25/09/2012  SY    BNP: Pb variable NoRefGer inconnue
08  04/10/2012  SY    0912/0114 Pas de proratas sur Rub 705 Taxes de bureau (prrubhol.i)
09  04/10/2012  SY    BNP: Cumul pour Toutes les Rub 8xx lors du regroupement Quitt de la Facture d'entrée
10  09/01/2013  SY    0113/0028 retour arrière sur prorata et cumul Rub 8xx : QUE pour BNP en attendant DEV
11  18/01/2013  SY    0113/0028 DEV colonne prorata et cumul 8xx (pclie HOLOQ zon05 et zon06)
12  08/11/2013  SY    1013/0167 Utilisation de rubqt.prg04 pour reconnaitre une rub TVA
13  30/07/2014  PL    0714/0324 Pb maj carturis. manque des params à la procédure ValDefProCum8xx
-----------------------------------------------------------------------------*/

procedure isRubEcla:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   : Inserer les éléments suivant pour pouvoir utiliser l'include
        using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
        define variable goRubriqueQuittHonoCabinet     as class parametrageRubriqueQuittHonoCabinet     no-undo.
        goRubriqueQuittHonoCabinet     = new parametrageRubriqueQuittHonoCabinet().
        delete object goRubriqueQuittHonoCabinet.
    ---------------------------------------------------------------------------*/
    define input  parameter piCodeRubrique      as integer   no-undo. 
    define input  parameter piCodeLibelle       as integer   no-undo. 
    define output parameter plEclatement        as logical   no-undo.
    define output parameter pcTypeRetour        as character no-undo.  
    define output parameter piRubriqueRetour    as integer   no-undo.  
    define output parameter piCodeLibelleRetour as integer   no-undo.  
    define output parameter pdeCabinetRetour    as decimal   no-undo.
    
    define variable vcCodeArticle as character no-undo.
    define variable vdeMnt01      as decimal   no-undo.
    define buffer rubqt for rubqt.

    find first rubqt no-lock
        where rubqt.cdrub = piCodeRubrique 
          and rubqt.cdlib = piCodeLibelle no-error.
    if not available rubqt then return.
    
    if rubqt.cdfam = 08 then do:
        assign
            vcCodeArticle = goRubriqueQuittHonoCabinet:getCodeArticleProprietaire(piCodeRubrique, piCodeLibelle)
            vdeMnt01      = goRubriqueQuittHonoCabinet:getMnt1()
        .
        if vcCodeArticle > "" and vdeMnt01 > 0 and vdeMnt01 < 100
        then assign
            plEclatement        = yes
            pcTypeRetour = "P"                /* propriétaire */
            piRubriqueRetour    = goRubriqueQuittHonoCabinet:getRubriqueProprietaire()
            piCodeLibelleRetour = goRubriqueQuittHonoCabinet:getLibelleProprietaire()
            pdeCabinetRetour    = vdeMnt01
        .
    end.
    else do:
        assign
            vcCodeArticle = goRubriqueQuittHonoCabinet:getCodeArticleLocataire(piCodeRubrique, piCodeLibelle)
            vdeMnt01      = goRubriqueQuittHonoCabinet:getMnt1()
        .
        if vcCodeArticle > "" and vdeMnt01 > 0 and vdeMnt01 < 100
        then assign
            plEclatement        = yes
            pcTypeRetour = "HL"                /* Honoraires locataire (pour le cabinet) */
            piRubriqueRetour    = goRubriqueQuittHonoCabinet:getRubriqueLocataire()
            piCodeLibelleRetour = goRubriqueQuittHonoCabinet:getLibelleLocataire()
            pdeCabinetRetour    = vdeMnt01
        .
    end.
end procedure.

procedure isRubProCum:
    /*---------------------------------------------------------------------------
    Purpose : Procedure pour savoir si une rubrique est "proratisable" si entrée/sortie locataire et cumulable dans la facture d'entrée
    Notes   : procédure issue de gidev/comm/PrRubHol.i, PROCEDURE IsRubProCum
/* Ajout Sy le 09/06/2010 */
    ---------------------------------------------------------------------------*/
    define input  parameter piCodeRubrique  as integer  no-undo.
    define input  parameter piCodeLibelle   as integer  no-undo.
    define output parameter plProratisation as logical  no-undo initial true.
    define output parameter plCumul         as logical  no-undo initial true.

    define buffer rubqt for rubqt.
    define buffer isoc  for isoc.
    define buffer pclie for pclie.

    {&_proparse_ prolint-nowarn(wholeindex)}
    for first isoc no-lock
        where isoc.specif-cle = 1000
        /* Pas de prorata pour les rubriques de type frais admnistratifs  sauf exception (650,651,652...) */
        /* Les frais administratifs fixes ne doivent pas être cumules sur la facture*/
        /* PB: que faire pour les TVA 9xx si rub 8xx sont mélangées ??? */
      , first rubqt no-lock
        where rubqt.cdrub = piCodeRubrique
          and rubqt.cdlib = piCodeLibelle:
        if rubqt.cdfam = 4 then do:
            if rubqt.CdSfa = 1 then plCumul = no.
            if lookup(string(rubqt.cdrub), {&proratisation-avant-fiche}, ",") = 0 then plProratisation = no.
        end.
        else if rubqt.CdFam = 8 then do:
            /* Sy le 17/01/2013 - 0113/0028 */
            find first pclie no-lock
                where pclie.tppar = "HOLOQ"
                  and pclie.int01 = piCodeRubrique
                  and pclie.int02 = piCodeLibelle no-error.
            if available pclie and pclie.zon05 > ""
            then assign   /* Nouvelles colonnes dans Ecran Paramétrage Client <Quittancement en masse...LF à FX> */
                plProratisation = (pclie.zon05 = "PRORATA")
                plCumul = (pclie.zon06 = "CUMUL")
            .
            else run ValDefProCum8xx(isoc.soc-cd, piCodeRubrique, piCodeLibelle, rubqt.cdgen, output plProratisation, output plCumul).
        end.
        /* Ajout Sy le 22/03/2010 */
        if (rubqt.cdfam = 2 and rubqt.cdsfa = 3)    /* PAS DE PRORATAS POUR LES RUBRIQUES REGUL DE CHARGES ****/
          or (rubqt.cdfam = 3 and rubqt.cdsfa = 3)  /* PAS DE PRORATAS POUR LES RUBRIQUES DEPOT DE GARANTIE ***/
          or (rubqt.cdsig = "00003" or rubqt.cdsig = "00004" or rubqt.cdsig = "00005") /* PAS DE PRORATAS POUR LES RUBRIQUES RAPPEL OU AVOIR  *****/
          or (rubqt.cdrub = 777)                        /* PAS DE PRORATAS POUR LES RUBRIQUES RAPPEL OU AVOIR C.R.D.B.*******/
          or (rubqt.cdrub = 102)                        /* PAS DE PRORATAS POUR LES RUBRIQUES REMISE LOYER     *****/
          or (rubqt.cdrub = 104)                        /* PAS DE PRORATAS POUR LES RUBRIQUES FRANCHISE LOYER *****/
          or (rubqt.cdrub = 270)                        /* PAS DE PRORATAS POUR LES RUBRIQUES REMBOURSEMENT QTE PART CHARGES*/
          or (rubqt.cdrub = 503)                        /* PAS DE PRORATAS POUR LES RUBRIQUES REMBOURSEMENT PRET **/
          or (rubqt.cdrub = 540)                        /* PAS DE PRORATAS POUR LES RUBRIQUES INTERPHONES, TRAVAUX     *******/
          or (rubqt.cdrub = 551)                        /* PAS DE PRORATAS POUR LES RUBRIQUES REMBOURSEMENT QTE PART LOYER  */
          /*OR (rubqt.cdfam = 5 AND rubqt.cdsfa = 2 AND rubqt.cdgen = "00004" AND buf_rubqt.cdrub > 771)*/               /* PAS DE PRORATAS POUR LES RUBRIQUES TAXES CALCULEES (TVA) ***/
          or (rubqt.cdfam = 05 and rubqt.cdsfa = 02 and rubqt.cdgen = "00004" and decimal(rubqt.prg04) > 0 )    /* SY 1013/0167 */  /* PAS DE PRORATAS POUR LES RUBRIQUES TAXES CALCULEES (TVA) ***/
          or (rubqt.cdrub = 506 )                       /* PAS DE PRORATAS POUR LES RUBRIQUES PRIME ASSURANCE ICADE    *******/
          or (rubqt.cdfam = 9 )                         /* PAS DE PRORATAS POUR LES RUBRIQUES TAXES CALCULEES (TVA sur Honoraires ) Ajout SY le 22/03/2010 ***/
          or rubqt.cdrub = 705                          /* PAS DE PRORATAS POUR LA RUBRIQUE Taxes de Bureau    (Ajout SY le 04/10/2012 - fiche 0912/0114) *******/
        then plProratisation = no.
    end.
end procedure.

procedure valDefProCum8xx:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   : procédure issue de gidev/comm/PrRubHol.i, PROCEDURE valDefProCum8xx
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroReference as integer   no-undo.
    define input  parameter piCodeRubrique    as integer   no-undo.
    define input  parameter pcCodeGen         as character no-undo.
    define output parameter plProrataRubrique as logical   no-undo initial true.
    define output parameter plCumulRubrique   as logical   no-undo initial true.

    define buffer pclie for pclie.
    define buffer rubqt for rubqt.
    /* Ajout SY le 21/09/2012 : Rub 865.xx à prorater si entrée/sortie */
    /* Modif SY le 24/09/2012 : Toutes les Rub Fixes 8xx à prorater pour BNP */
    /* NB : il faudrait une évolution pour ajouter une colonne "prorata e/s" dans le paramétrage Quitt LF à FX */
    /*IF GiCodeSoc <> 02053 THEN DO:*/  /* variable noref inconnues => comme le code était pour ICADE on l'enlève pour BNP ... */
    if piNumeroReference = 02053
    then plCumulRubrique = true.     /* Cumuler les rubriques pour BNP */
    else do:
        /* Pas de prorata pour rub Honoraires Cabinet si ancienne rub associé = Famille frais adm. et non "proratisable" */
        for first pclie no-lock
            where pclie.tppar = "HOLOQ"
              and pclie.int01 = piCodeRubrique
              and pclie.int03 > 000
              and pclie.zon02 > ""
          , first rubqt no-lock
            where rubqt.cdrub = integer(pclie.int03)
              and rubqt.cdlib = integer(pclie.int04):
            if rubqt.cdfam = 4 then do:
                if rubqt.CdSfa = 1 then plCumulRubrique = no.
                if lookup(string(rubqt.cdrub), {&proratisation-avant-fiche}, ",") = 0 then plProrataRubrique = no.
            end.
        end.
        if piCodeRubrique = 821      /* PAS DE PRORATAS POUR LES RUBRIQUES PRIME ASSURANCE ICADE    *******/
        or piCodeRubrique = 834      /* PAS DE PRORATAS POUR LES RUBRIQUES PACK SERVICES ICADE  (07/07/2010) *******/
        then plProrataRubrique = no.
    end.
    /* pas de proratas ni cumul si Rub 8xx pas Fixe */
    if pcCodeGen <> "00001"
    then assign
        plProrataRubrique = no
        plCumulRubrique   = no       /* Ajout SY le 18/01/2013 */
    .
end procedure.
