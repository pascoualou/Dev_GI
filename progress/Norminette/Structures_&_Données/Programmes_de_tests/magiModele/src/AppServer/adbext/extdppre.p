/*------------------------------------------------------------------------
File        : extdppre.p
Purpose     : Programme d'extraction pour la liste des depensesprestations
Author(s)   : JC 16/10/1998  -  GGA 2018/01/26
Notes       : reprise adb/ext/extdppre.p. Une collection passée en paramètres.
                     (1): Numero de mandat
                     (2): Numero de periode("0" si hors periode)
                     (3): Date debut de periode, ? si hors periode
                     (4): Date fin de periode, ? si hors periode
                     (5): Edition des imputations particulieres et des releves d'eau (yes/no)
                     (7): Edition des charges non locatives (Code fiscalite <> 2) (yes/no)
01  29/10/1998  JC    Ajout numero de lot
02  16/11/1998  JC    Ajout recherche du libelle: CLE ABSENTE Pb edition des lignes tableaux d'eau et imputations particulieres
03  25/11/1998  SY    Modif édition récup imputation particulière (elle est saisie et peut être nulle)
04  26/11/1998  SY    Modif édition récup Relevés eau/thermies... (elle est saisie et peut être nulle)
05  01/07/1999  SY    Correction clé de récupération eau réchauffée. Correction récupération libellé clé gérance
06  26/10/2000  SL    Gestion de la Devise.
07  11/10/2001  DM    Rajout de 3 entries pour include incchalo.i
08  29/11/2001  NO    Possibilite de regrouper les depenses ventilees par lot (Ajout Input Parameter)
09  10/07/2002  AF    Pb sur fonction dans clé de table temporaire
10  12/02/2004  SG    0104/0451: rajout de la sélection date à date
12  24/04/2006  AF    0406/0259: manquait paranthése sur creation tbedt des lignes regroupemement compensation
13  19/01/2007  AF    0604/0187: Consommation GAZ
14  11/02/2008  OF    0208/0162 Specifique Dauchez: On ne prend plus le Quitt ni ODRT -> Modif incchalo.i
15  20/06/2008  MB    0208/0395: selection cles
16  06/11/2008  SY    1108/0306: suite 0208/0395: selection cles le filtrage n'était pas fait
17  08/02/2010  OF    0408/0029 Edition PDF
18  07/06/2010  JR    0610/0039 Lors de l'édition PDF, la ligne 'Récupération eau' était positive
19  25/08/2010  OF    0810/0071 Recalcul du montant en fonction des millièmes pour les cexmlnana -> Modif incchalo.i
16  03/02/2011  OF    0211/0020 Pb regroupement des dépenses -> Modif incchalo.i
17  17/01/2012  NP    0112/0157 Specifique 03110 comme Dauchez: plus le Quitt ni ODRT  -> Modif incchalo.i
18  26/02/2013  DM    0712/0238 Prorata et dossier travaux
19  09/10/2013  SY    1013/0063 suite Prorata et dossier travaux. 
                      les entry 21 et 22 on été ajoutées sur les lignes d'écriture, il faut aussi les ajouter (vide) sur les lignes tableau d'eau, IP... 
------------------------------------------------------------------------*/

{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2compteur.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{adbext/include/extdppre.i}

/* Attention, quand on définit une Temp-table avec LIKE, définir un index !!!! */
define temp-table ttTempo no-undo like cecrlnana index primaire soc-cd etab-cd.

define input-output parameter pcListeParametre as character no-undo.
define input        parameter plDepenseCumule  as logical   no-undo. 
define input        parameter poCollection     as class collection no-undo.
define input-output parameter table for ttExport.
define input-output parameter table for ttImpression.

define variable giReferenceSociete         as integer   no-undo.
define variable giCodeLangue               as integer   no-undo.
define variable glExportPdfOuXls           as logical   no-undo.
define variable giNumeroMandat             as integer   no-undo.
define variable giNumeroPeriode            as integer   no-undo.
define variable giNumeroImmeuble           as integer   no-undo.
define variable gdaDebutPeriode            as date      no-undo.
define variable gdaFinPeriode              as date      no-undo.
define variable glEditionChargeNonLocative as logical   no-undo.
define variable gcPeriodeOuDate            as character no-undo.
define variable glTableauEau               as logical   no-undo.
define variable glAvecProrataTva           as logical   no-undo.
define variable gcLbTotalReleve            as character no-undo.
define variable gcListeCles                as character no-undo.

function libelleCle return character private(piNumeroMandat as int64, pcCle as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche libelle cle
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer clemi for clemi.
    for first clemi no-lock
        where clemi.noimm = 10000 + piNumeroMandat
          and clemi.cdcle = pcCle:
        return clemi.lbcle.
    end.
    return "".
end function.

function libelleRubrique return character private(pcCodRub as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche libelle rubrique
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer aruba for aruba.
    for first aruba no-lock
        where aruba.soc-cd = giReferenceSociete
          and aruba.cdlng  = giCodeLangue
          and aruba.fg-rub = true
          and aruba.rub-cd = pcCodRub:
        return aruba.lib.
    end.
    return "".
end function.

function formatZoneTri return character private(pcTri01 as character, pcTri02 as character, pdaTriDate as date):
    /*------------------------------------------------------------------------------
    Purpose: formatage zone de tri
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDate as character no-undo.
    if pdaTriDate <> ? 
    then vcdate = string(year(pdaTriDate), "9999") + string(month(pdaTriDate), "99") + string(day(pdaTriDate), "99"). 
    return substitute("&1&2&3&4", string(pcTri01, "X(2)"), substring(pcTri02, 1, 3, "character"), substring(pcTri02, 4, 3, "character"), vcDate).
end function.

run getTokenInstance (poCollection:getCharacter("cJSessionId")). 
assign
    giReferenceSociete         = integer(poCollection:getCharacter("cRefPrincipale"))
    giCodeLangue               = poCollection:getinteger("iCodeLangueSession")
    giNumeroMandat             = integer(entry(1, pcListeParametre, "|"))
    giNumeroPeriode            = integer(entry(2, pcListeParametre, "|"))
    gdaDebutPeriode            = date(entry(3, pcListeParametre, "|"))
    gdaFinPeriode              = date(entry(4, pcListeParametre, "|"))
    glEditionChargeNonLocative = (entry(7, pcListeParametre, "|") = "yes")    
    gcPeriodeOuDate            = entry(8, pcListeParametre, "|") 
    glTableauEau               = (entry(6, pcListeParametre, "|") = "yes")
    glExportPdfOuXls           = (num-entries(pcListeParametre, "|") > 25 and (entry(26, pcListeParametre, "|") = "PDF" or entry(26, pcListeParametre, "|") = "EXC"))
    glAvecProrataTva           = (num-entries(pcListeParametre, "|") > 26 and entry(27, pcListeParametre, "|") = "yes")
    gcLbTotalReleve            = outilTraduction:getLibelle(102808)
    gcListeCles                = (if num-entries(pcListeParametre, "|") > 24 then entry(25, pcListeParametre, "|")
                                                                             else "")   
.
run ExtDpPre.

procedure ExtDpPre private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcLibelleCle                    as character no-undo.
    define variable vcLibelleRubrique               as character no-undo.
    define variable vcRubDebit                      as character no-undo.
    define variable vcRubCredit                     as character no-undo.
    define variable vcSousRub                       as character no-undo.
    define variable vcLbTotalImputationParticuliere as character no-undo.
    define variable vcLbCleAbsente                  as character no-undo.
    define variable vlDebour                        as logical   no-undo.
    define variable vcLibelleCompteur               as character no-undo.
    define variable vcCodeCollectif4110             as character no-undo.
    define variable vcCompte4110                    as character no-undo.
    define variable vhOutilsTva                     as handle    no-undo.
    define variable vdeImputationTTC                as decimal   no-undo.
    define variable vdeImputationTVA                as decimal   no-undo.

    /* variable de l'include incchalo.i */
    define variable vdeMontantDepenseTTC as decimal   no-undo.
    define variable vdeMontantDepenseTVA as decimal   no-undo.
    define variable vcCodeCle            as character no-undo.
    define variable vcCompteFournisseur  as character no-undo.
    define variable vdeTauxProrata       as decimal   no-undo. /* DM 0712/0238 */
    define variable vdeDenominateur      as decimal   no-undo. /* DM 0712/0238 */
    define variable vdeNumerateur        as decimal   no-undo. /* DM 0712/0238 */
    define variable viCpt                as integer   no-undo.
    define variable vdeDepenseTTC        as decimal   no-undo.
    define variable vdeDepenseTVA        as decimal   no-undo.
    define variable vlSensDepense        as logical   no-undo.
    define variable vdeListeTotalTTC     as decimal   no-undo.
    define variable vdeListeTotalTVA     as decimal   no-undo.

    define buffer intnt   for intnt. 
    define buffer ccptcol for ccptcol. 
    define buffer csscpt  for csscpt. 
    define buffer alrub   for alrub. 
    define buffer tache   for tache. 
    define buffer clemi   for clemi. 
    define buffer lprtb   for lprtb. 
    define buffer entip   for entip.
    define buffer aruba   for aruba.
    define buffer cecrln  for cecrln.
    define buffer cexmln  for cexmln.
    define buffer cecrsai for cecrsai.
    define buffer cexmsai for cexmsai.
    define buffer ijou    for ijou.
    define buffer csscptcol for csscptcol.
    define buffer cecrlnana for cecrlnana.

    assign 
        vcLbTotalImputationParticuliere = outilTraduction:getLibelle(102870)
        vcLbCleAbsente                  = outilTraduction:getLibelle(104048)
    .
    /* Recherche de l'immeuble associe au mandat de Gerance */ 
    find first intnt no-lock 
         where intnt.tpidt = {&TYPEBIEN-immeuble}
           and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and intnt.nocon = giNumeroMandat no-error.
    assign 
        giNumeroImmeuble                = if available intnt then intnt.noidt else 0
 /*gga todo voir quand on reprendra edition si vraiment utile de renseigner avec ces infos la zone parametre       
        entry(9, pcListeParametre, "|") = string(giNumeroImmeuble) 
        pcListeParametre              = pcListeParametre + "|" + "|" + "|". /*MB semble inutile (passage à 28 avec cela!!*/   
gga todo*/        
    .
    /* Recherche du compte 4110 */
    for first ccptcol no-lock 
        where ccptcol.soc-cd = giReferenceSociete
          and ccptcol.tprole = 22
      , first csscpt no-lock 
        where csscpt.soc-cd   = giReferenceSociete
          and csscpt.etab-cd  = giNumeroMandat
          and csscpt.coll-cle = ccptcol.coll-cle:
        assign 
            vcCodeCollectif4110 = csscpt.sscoll-cle
            vcCompte4110        = csscpt.cpt-cd
        .
    end.
    /* INITIALISATION REGROUPEMENT DIFFERENCE DE CONVERSION DM 08/11/01 */
    for first alrub no-lock
        where alrub.soc-cd   = giReferenceSociete
          and alrub.type-rub = 10: 
        assign 
            vcRubDebit = alrub.rub-cd
            vcSousRub  = alrub.ssrub-cd
        .
    end.
    for first alrub no-lock
        where alrub.soc-cd   = giReferenceSociete
          and alrub.type-rub = 11:
        assign 
            vcRubCredit = alrub.rub-cd
            vcSousRub   = if vcSousRub > "" then vcSousRub else alrub.ssrub-cd
        .
    end.
    /** DM 0712/0238 **/
    find first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = giNumeroMandat
          and tache.tptac = {&TYPETACHE-TVA} no-error.
    vlDebour = available tache and (if lookup(tache.lbmotif, "ProrataTVAManu,ProrataTVAAuto") > 0 then (tache.lbmotif = "ProrataTVAManu") 
               else can-find(first aparm no-lock where aparm.tppar = "DEBOUR")).
  
    run compta/outilsTVA.p persistent set vhOutilsTva.
    run getTokenInstance in vhOutilsTva(mToken:JSessionId).

    /* Premiere boucle sur les ecritures analytiques */
    {adb/commun/IncChaLo.i "cecr"}
    /* Deuxieme boucle sur les ecritures analytiques extra-comptables */
    {adb/commun/IncChaLo.i "cexm"}
    run destroy in vhOutilsTva.

    /* Traitement du regroupement difference de conversion DBA 25/01/01 */
    for first ttTempo:
        /*Ajout SY le 06/11/2008 (suite fiche 0208/0395) neutralisation ligne si clé non convenue*/
        if gcListeCles > "" and lookup(trim(ttTempo.ana4-cd), gcListeCles, ",") > 0 
        then do:
            /* Recherche du libelle de la cle */
            find first clemi no-lock 
                 where clemi.noimm = 10000 + giNumeroMandat
                   and clemi.cdcle = ttTempo.ana4-cd no-error.
            assign
                vcLibelleCle      = if available clemi
                                    then clemi.lbcle
                                    else (if trim(ttTempo.ana4-cd) > "" then "?.?.?" else vcLbCleAbsente)
                vcLibelleRubrique = libelleRubrique (if vdeListeTotalTTC > 0 then vcRubDebit else vcRubCredit) //Libelle de la rubrique
            .
            if glExportPdfOuXls 
            then do:
                create ttExport.
                assign
                    ttExport.iNomdt   = giNumeroMandat
                    ttExport.iNoExo   = giNumeroPeriode
                    ttExport.cCle     = ttTempo.ana4-cd
                    ttExport.cLbCle   = vcLibelleCle
                    ttExport.cRubCd   = if vdeListeTotalTTC > 0 then vcRubDebit else vcRubCredit
                    ttExport.cLbRub   = string(vcLibelleRubrique, "X(32)")
                    ttExport.cSsRubCd = vcSousRub
                    ttExport.cFisc    = ttTempo.ana3-cd
                    ttExport.daEcr    = ?
                    ttExport.dMt      = vdeListeTotalTTC
                    ttExport.dMtTva   = vdeListeTotalTVA
                    ttExport.lLoc     = integer(ttTempo.ana3-cd) = 2     
                    ttExport.cTri     = string(ttTempo.ana4-cd, "X(2)") 
                                      + string(if vdeListeTotalTTC > 0 then vcRubDebit else vcRubCredit, "999")
                                      + string(vcSousRub, "999")
                .
                do viCpt = 1 to 9:
                    ttExport.cLibEcr[viCpt] = string(ttTempo.lib-ecr[viCpt], "X(32)").
                end.
            end.
            else do:
                create ttImpression.
                assign
                    ttImpression.cClass = substitute("&1&2&300000000",
                                                     string(ttTempo.ana4-cd, "X(2)"),
                                                     string(if vdeListeTotalTTC > 0 then vcRubDebit else vcRubCredit, "999"),
                                                     string(vcSousRub, "999"))
                    ttImpression.cRefer = if integer(ttTempo.ana3-cd) = 2 then "2" else "1"
                    ttImpression.cLigne = substitute("&2&1&3&1&1&1&4&1&1&1&1&5&1&6&1&7&1&8&1&9",
                                              separ[1],
                                              vcLibelleCle,                       /* (1) libelle de la cle */
                                              string(vcLibelleRubrique, "X(32)"), /* (2) libelle de la rubrique */
                                              if vdeListeTotalTVA <> 0 then string(vdeListeTotalTVA, "->>>>>>>>>9.99") else "",    /* (9) Tva */
                                              string(vdeListeTotalTTC, "->>>>>>>>>9.99"),                     /* (10) Dépense */
                                              string(ttTempo.lib-ecr[1], "X(32)"),                          /* (11) */
                                              string(ttTempo.lib-ecr[2], "X(32)"),                          /* (12) */
                                              string(ttTempo.lib-ecr[3], "X(32)"))                          /* (13) */
                                        + substitute("&1&2&1&3&1&4&5&1&6&1&7&1&8",
                                              separ[1],
                                              string(ttTempo.lib-ecr[4], "X(32)"),                          /* (14) */
                                              string(ttTempo.lib-ecr[5], "X(32)"),                          /* (15) */
                                              string(ttTempo.lib-ecr[6], "X(32)"),                          /* (16) */
                                              string(ttTempo.lib-ecr[7], "X(32)"),                          /* (17) */
                                              string(ttTempo.lib-ecr[8], "X(32)"),                          /* (18) */
                                              string(ttTempo.lib-ecr[9], "X(32)"),                          /* (19) */
                                              fill( separ[1], 3))                                      /* (20) à (22) */
                .
            end.
        end.
    end.
    /* Tableaux d'eau et imputations particulieres */
    if glTableauEau = yes 
    then do:
        /* Imputations particulieres */
        for each lprtb no-lock
            where lprtb.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and lprtb.nocon = giNumeroMandat
              and lprtb.noexe = giNumeroPeriode
              and lprtb.noper = 0
              and lprtb.tpcpt = {&TYPETACHE-ImputParticuliereGerance}
          , first entip no-lock
            where entip.noimm = giNumeroImmeuble
              and entip.nocon = lprtb.nocon
              and entip.dtimp = outils:convertionDate("yyyymmdd", string(lprtb.norlv)):
            /* Ligne total imputations particulieres */
            if glExportPdfOuXls 
            then do:
                create ttExport.
                assign
                    ttExport.iNomdt     = giNumeroMandat
                    ttExport.iNoExo     = giNumeroPeriode
                    ttExport.cCle       = entip.nocle
                    ttExport.cLbCle     = libelleCle(giNumeroMandat, entip.nocle)
                    ttExport.cRubCd     = "170"
                    ttExport.cLbRub     = libelleRubrique ("170")
                    ttExport.cSsRubCd   = "672"
                    ttExport.cFisc      = "2"
                    ttExport.daEcr      = entip.dtimp
                    ttExport.dMt        = entip.mtttc
                    ttExport.dMtTva     = entip.mttva
                    ttExport.cLibEcr[1] = vcLbTotalImputationParticuliere
                    ttExport.lLoc       = true
                    ttExport.cTri       = formatZoneTri (entip.nocle, "170672", entip.dtimp)                        
                .
            end.
            else do:
                create ttImpression.
                assign 
                    ttImpression.cClass = formatZoneTri(entip.nocle, "170672", entip.dtimp)  
                    ttImpression.cRefer = "2"
                    ttImpression.cLigne = substitute("&2&1&3&1&4&1&1&5&1&1&1&1&6&1&7&1&8&9",
                                          separ[1],
                                          libelleCle(giNumeroMandat, entip.nocle),
                                          string(libelleRubrique("170"), "X(32)"),                                /* libelle de la rubrique */
                                          if entip.dtimp <> ? then string(entip.dtimp,"99/99/9999") else "",      /* (3),(4) No de piece */
                                          "2",                                                                    /* (5), (6) No de doc, (7) code fournisseur, (8) Code FAP */
                                          if entip.mttva <> 0 then string(entip.mttva, "->>>>>>>>>9.99") else "", /* (9) */
                                          if entip.mtttc <> 0 then string(entip.mtttc, "->>>>>>>>>9.99") else "", /* (10) */
                                          vcLbTotalImputationParticuliere,                                        /* (11) */
                                          fill(separ[1], 11))
                .
            end.
            /* Ligne recuperation imputations particulieres si montant <> 0 */
            assign 
                vdeImputationTTC = decimal(entry(2, entip.lbrec, separ[1]))
                vdeImputationTVA = decimal(entry(3, entip.lbrec, separ[1]))
            .
            if vdeImputationTTC <> 0 then if glExportPdfOuXls 
            then do:
                create ttExport.
                assign
                    ttExport.iNomdt     = giNumeroMandat
                    ttExport.iNoExo     = giNumeroPeriode
                    ttExport.cCle       = string(entip.nocre, "X(2)")
                    ttExport.cLbCle     = libelleCle(giNumeroMandat, entip.nocre)
                    ttExport.cRubCd     = substring(entip.cdana, 1, 3, "character")
                    ttExport.cLbRub     = string(libelleRubrique (substring(entip.cdana, 1, 3, "character")), "X(32)")
                    ttExport.cSsRubCd   = substring(entip.cdana, 4, 3, "character")
                    ttExport.cFisc      = substring(entip.cdana, 7, 1, "character")
                    ttExport.daEcr      = entip.dtimp
                    ttExport.dMt        = - vdeImputationTTC
                    ttExport.dMtTva     = - vdeImputationTVA
                    ttExport.cLibEcr[1] = string(entry(1, entip.lbrec, separ[1]), "X(32)")
                    ttExport.lLoc       = true
                    ttExport.cTri       = formatZoneTri(entip.nocre, entip.cdana, entip.dtimp)                        
                .
            end.
            else do:
                create ttImpression.
                assign
                    ttImpression.cClass = formatZoneTri (entip.nocre, entip.cdana, entip.dtimp)  
                    ttImpression.cRefer = "2"
                    ttImpression.cLigne = substitute("&2&1&3&1&4&1&1&5&1&1&1&1&6&1&7&1&8&9",
                                          separ[1],
                                          libelleCle(giNumeroMandat, entip.nocre),
                                          string(libelleRubrique(substring(entip.cdana, 1, 3, "character")), "X(32)"), /* libelle de la rubrique */
                                          if entip.dtimp <> ? then string(entip.dtimp, "99/99/9999") else "",          /* (3),(4) No de piece */
                                          substring(entip.cdana, 7, 1, "character"),                                   /* (5), (6) No de doc, (7) code fournisseur, (8) Code FAP */
                                          if vdeImputationTVA <> 0 then string(- vdeImputationTVA, "->>>>>>>>>9.99") else "",          /* (9) */
                                          if vdeImputationTTC <> 0 then string(- vdeImputationTTC, "->>>>>>>>>9.99") else "",          /* (10) */
                                          string(entry(1, entip.lbrec, separ[1]), "X(32)"),                            /* (11) */
                                          fill(separ[1], 11))
                .
            end. 
        end.
        /* Tableaux d'eau */
        run generationTableauEau({&TYPECOMPTEUR-EauFroide}       , "020244").
        run generationTableauEau({&TYPECOMPTEUR-EauChaude}       , "080244").
        run generationTableauEau({&TYPECOMPTEUR-Thermie}        , "070235").
        run generationTableauEau({&TYPECOMPTEUR-Electricite}     , "010200").
        run generationTableauEau({&TYPECOMPTEUR-UniteEvaporation}, "070235").
        run generationTableauEau({&TYPECOMPTEUR-Frigorie}       , "670287").
        run generationTableauEau({&TYPECOMPTEUR-TotalGaz}        , "070244").
        run generationTableauEau({&TYPECOMPTEUR-GazDeFrance}     , "070244").
    end.

end procedure.

procedure generationTableauEau private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui genere les enregistrements tableaux d'eau 
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCompteur   as character no-undo.
    define input parameter pcCodeAnalytique as character no-undo.

    define variable vcLibelleCompteur as character no-undo.
    define buffer lprtb for lprtb. 
    define buffer erlet for erlet. 

    vcLibelleCompteur = outilTraduction:getLibelleParam("TPCPT", pcTypeCompteur).
    for each lprtb no-lock
       where lprtb.tpcon = {&TYPECONTRAT-mandat2Gerance}
         and lprtb.nocon = giNumeroMandat
         and lprtb.noexe = giNumeroPeriode
         and lprtb.noper = 0
         and lprtb.noimm = giNumeroImmeuble
         and lprtb.tpcpt = pcTypeCompteur
    , first erlet no-lock
      where erlet.noimm = 10000 + lprtb.nocon
        and erlet.tpcpt = lprtb.tpcpt
        and erlet.norlv = lprtb.norlv:
        /* Ligne total  Ajout OF le 08/02/10**/
        if glExportPdfOuXls 
        then do:
            create ttExport.
            assign
                ttExport.iNomdt     = giNumeroMandat
                ttExport.iNoExo     = giNumeroPeriode
                ttExport.cCle       = erlet.clrep
                ttExport.cLbCle     = libelleCle(giNumeroMandat, erlet.clrep)
                ttExport.cRubCd     = substring(pcCodeAnalytique, 1, 3, "character")
                ttExport.cLbRub     = string(libelleRubrique(substring(pcCodeAnalytique, 1, 3, "character")), "X(32)")
                ttExport.cSsRubCd   = substring(pcCodeAnalytique, 4, 3, "character")
                ttExport.cFisc      = substring(erlet.cdana, 7, 1, "character")
                ttExport.daEcr      = erlet.dtrlv
                ttExport.cNoDoc     = string(lprtb.norlv, "ZZZZZZZZZ")
                ttExport.dMt        = erlet.totrl
                ttExport.dMtTva     = erlet.tvarl
                ttExport.cLibEcr[1] = string(gcLbTotalReleve + " " + vcLibelleCompteur, "X(32)")
                ttExport.lLoc       = true
                ttExport.cTri       = formatZoneTri(erlet.clrep, pcCodeAnalytique, erlet.dtrlv)                        
            .
        end.
        else do:
            create ttImpression.
            assign
                ttImpression.cClass = formatZoneTri (erlet.clrep, pcCodeAnalytique, erlet.dtrlv)  
                ttImpression.cRefer = "2"
                ttImpression.cLigne = substitute("&2&1&3&1&4&1&1&5&1&6&1&1&1&7&1&8&1&9&1&1&1&1&1&1&1&1&1&1&1",
                                      separ[1],
                                      libelleCle(giNumeroMandat, erlet.clrep),
                                      string(libelleRubrique (substring(pcCodeAnalytique, 1, 3, "character")), "X(32)"), /* (2) libelle de la rubrique */
                                      if erlet.dtrlv <> ? then string(erlet.dtrlv, "99/99/9999") else "",              /* (3),(4) No de piece */
                                      substring(erlet.cdana, 7, 1, "character"),                                       /* (5) */
                                      string(lprtb.norlv, "ZZZZZZZZZ"),                                                /* (6) No de doc, (7) code fournisseur, (8) Code FAP */
                                      if erlet.tvarl <> 0 then string(erlet.tvarl, "->>>>>>>>>9.99") else "",         
                                      if erlet.totrl <> 0 then string(erlet.totrl, "->>>>>>>>>9.99") else "",          /* (10) */
                                      string(gcLbTotalReleve + " " + vcLibelleCompteur, "X(32)"))                      /* (11) */
            .
        end.
        if erlet.totrc <> 0 then if glExportPdfOuXls   /* Ligne recuperation */
        then do:
            create ttExport.
            assign
                ttExport.iNomdt     = giNumeroMandat
                ttExport.iNoExo     = giNumeroPeriode
                ttExport.cCle       = erlet.clrec
                ttExport.cLbCle     = libelleCle(giNumeroMandat, erlet.clrec)
                ttExport.cRubCd     = substring(erlet.anarc, 1, 3, "character")
                ttExport.cLbRub     = string(libelleRubrique(substring(erlet.anarc, 1, 3, "character")), "X(32)")
                ttExport.cSsRubCd   = substring(erlet.anarc, 4, 3, "character")
                ttExport.cFisc      = substring(erlet.anarc, 7, 1, "character")
                ttExport.daEcr      = erlet.dtrlv
                ttExport.dMt        = - erlet.totrc
                ttExport.dMtTva     = - erlet.tvarc
                ttExport.cLibEcr[1] = string(erlet.librc, "X(32)")
                ttExport.lLoc       = true
                ttExport.cTri       = formatZoneTri(erlet.clrec, erlet.anarc, erlet.dtrlv)                        
                .
        end.
        else do:
            create ttImpression.
            assign
                ttImpression.cClass = formatZoneTri (erlet.clrec, erlet.anarc, erlet.dtrlv)  
                ttImpression.cRefer = "2"
                ttImpression.cLigne = substitute("&2&1&3&1&4&1&1&5&1&1&1&1&6&1&7&1&8&9",
                                      separ[1],
                                      libelleCle(giNumeroMandat, erlet.clrec),
                                      string(libelleRubrique(substring(erlet.anarc, 1, 3, "character")), "X(32)"), /* (2) libelle de la rubrique */
                                      if erlet.dtrlv <> ? then string(erlet.dtrlv,"99/99/9999") else "",           /* (3), (4) No de piece */
                                      substring(erlet.anarc, 7, 1, "character"),                                   /* (5), (6) No de doc, (7) code fournisseur, (8) Code FAP */
                                      if erlet.tvarc <> 0 then string(- erlet.tvarc, "->>>>>>>>>9.99") else "",    /* (9) */
                                      if erlet.totrc <> 0 then string(- erlet.totrc, "->>>>>>>>>9.99") else "",    /* (10) */
                                      string(erlet.librc, "X(32)"),                                                /* (11) */
                                      fill(separ[1],11))                                                           /* (12) à (22) */
            .
        end.
        /* Cas particulier: eau chaude - enregistrement supplementaire */
        /* si montant eau froide <> 0 */
        if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude} and erlet.pxuer <> 0 and erlet.toter <> 0 
        then if glExportPdfOuXls    /* Ligne récupération eau réchauffée,  Ajout OF le 08/02/10  */ 
        then do:
            create ttExport.
            assign
                ttExport.iNomdt     = giNumeroMandat
                ttExport.iNoExo     = giNumeroPeriode
                ttExport.cCle       = erlet.recer
                ttExport.cLbCle     = libelleCle(giNumeroMandat, erlet.recer)
                ttExport.cRubCd     = substring(erlet.anaer, 1, 3, "character")
                ttExport.cLbRub     = string(libelleRubrique(substring(erlet.anaer, 1, 3, "character")), "X(32)")
                ttExport.cSsRubCd   = substring(erlet.anaer, 4, 3, "character")
                ttExport.cFisc      = substring(erlet.anaer, 7, 1, "character") 
                ttExport.daEcr      = erlet.dtrlv
                ttExport.dMt        = - erlet.toter
                ttExport.dMtTva     = - erlet.tvaer
                ttExport.cLibEcr[1] = string(erlet.liber, "X(32)")
                ttExport.lLoc       = true
                ttExport.cTri       = formatZoneTri (erlet.recer, erlet.anaer, erlet.dtrlv)                        
            .
        end.
        else do:
            create ttImpression.
            assign 
                ttImpression.cClass = formatZoneTri(erlet.recer, erlet.anaer, erlet.dtrlv) 
                ttImpression.cRefer = "2"
                ttImpression.cLigne = substitute("&2&1&3&1&4&1&1&5&1&1&1&1&6&1&7&1&8&9",
                                      separ[1],
                                      libelleCle(giNumeroMandat, erlet.recer), 
                                      string(libelleRubrique(substring(erlet.anaer, 1, 3, "character")), "X(32)"), /* (2) libelle de la rubrique */
                                      if erlet.dtrlv <> ? then string(erlet.dtrlv, "99/99/9999") else "",          /* (3), (4) No de piece */
                                      substring(erlet.anaer, 7, 1, "character"),                                   /* (5), (6) No de doc, (7) code fournisseur, (8) Code FAP */
                                      if erlet.tvaer <> 0 then string(- erlet.tvaer, "->>>>>>>>>9.99") else "",    /* (9) */
                                      if erlet.toter <> 0 then string(- erlet.toter, "->>>>>>>>>9.99") else "",    /* (10) */
                                      string(erlet.liber, "X(32)"),                                                /* (11) */
                                      fill(separ[1],11))
            .
        end.
    end.

end procedure.
