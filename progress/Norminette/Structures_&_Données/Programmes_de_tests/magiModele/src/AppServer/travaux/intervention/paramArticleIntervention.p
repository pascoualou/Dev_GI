/*------------------------------------------------------------------------
File        : paramArticleIntervention.p
Purpose     :
Author(s)   : LGI 2015/12/15  -  kantena 2017/01/04
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2Contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define input  parameter pcTypeContrat    as character no-undo.
define input  parameter pcTypeUrgence    as character no-undo.
define input  parameter plDossierTravaux as logical   no-undo.
define input  parameter pcCodeArticle    as character no-undo.
define output parameter poCollection     as class collection no-undo.

define variable gcCodeRubrique as character no-undo.
define variable gcSousRubrique as character no-undo.

define buffer artic     for artic.
define buffer csscptcol for csscptcol.
define buffer prmar     for prmar.
define buffer prmrg     for prmrg.
define buffer prmtv     for prmtv.
define buffer prmAna    for prmAna.

/*--> Recherche du parametrage article */
find first artic no-lock
    where artic.cdart = pcCodeArticle no-error.
if not available artic then return.

if not valid-object(poCollection) then poCollection = new collection().
poCollection:set('cLibelleArticle', artic.lbart).
poCollection:set('cCodeTVA', string(artic.cdtva)).
/*--> affichage des zones de saisie detail du regroupement et du type de contrat selectionnes */
if artic.cdrgt = "00000" or artic.cdrgt = "" or artic.cdrgt = ?
then for first prmar no-lock   /* --> pas de regroupement pour l'article => chargement du parametrage propre a l'article */
    where prmar.cdart = pcCodeArticle
      and prmar.tpcon = pcTypeContrat
      and prmar.fgdos = plDossierTravaux
      and integer(prmar.tpurg) = integer(pcTypeUrgence):
    assign
        gcCodeRubrique = trim(prmar.noRub)
        gcSousRubrique = trim(prmar.noSsr)
    .
    poCollection:set('cCodeCollectif',         prmar.cdCol).
    poCollection:set('cCodeRubrique',          gcCodeRubrique).
    poCollection:set('cSousRubrique',          gcSousRubrique).
    poCollection:set('cCodeFiscalite',         trim(prmar.noFis)).
    poCollection:set('lVentilationAnalytique', not prmar.fgven).
    if prmar.cdCol = "" or prmar.cdCol = ? then do:
        poCollection:set('cCompte',     substring(prmar.cptCd, 1, 4, 'character')).
        poCollection:set('cSousCompte', substring(prmar.cptCd, 5, 5, 'character')).
    end.
    else for first csscptcol no-lock
        where csscptcol.soc-cd = integer(if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} then mToken:cRefCopro else mToken:cRefGerance)
          and csscptcol.etab-cd > 0
          and csscptcol.sscoll-cle = prmar.cdCol:
        poCollection:set('cCompte',     csscptcol.sscoll-cpt).
        poCollection:set('cSousCompte', "00000").
    end.
    /*--> Ventilation
    if prmar.fgven then do:
        /* tableau => impossible de retrouver le type de travaux */
    end.
    */
end.
else for first prmtv no-lock     /* --> inc_article lie a un regroupement => chargement des details du regroupement */
    where prmtv.tppar = "REGRT"
      and prmtv.cdpar = artic.cdrgt:
    for first prmrg no-lock
        where prmrg.cdrgt = prmtv.cdpar
          and prmrg.tpcon = pcTypeContrat
          and prmrg.fgdos = plDossierTravaux
          and integer(prmrg.tpurg) = integer(pcTypeUrgence):
        assign
            gcCodeRubrique = trim(prmrg.noRub)
            gcSousRubrique = trim(prmrg.noSsr)
        .
        poCollection:set('cCodeCollectif',         prmrg.cdCol).
        poCollection:set('cCodeRubrique',          gcCodeRubrique).
        poCollection:set('cSousRubrique',          gcSousRubrique).
        poCollection:set('cCodeFiscalite',         trim(prmrg.noFis)).
        poCollection:set('lVentilationAnalytique', not prmrg.fgven).
        if prmrg.cdCol = "" or prmrg.cdCol = ? then do:
            poCollection:set('cCompte',     substring(prmrg.cptCd, 1, 4, 'character')).
            poCollection:set('cSousCompte', substring(prmrg.cptCd, 5, 5, 'character')).
        end.
        else for first csscptcol no-lock
            where csscptcol.soc-cd     = integer(if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} then mToken:cRefCopro else mToken:cRefGerance)
              and csscptcol.sscoll-cle = prmrg.cdCol
              and csscptcol.etab-cd    > 0:
            poCollection:set('cCompte',     csscptcol.sscoll-cpt).
            poCollection:set('cSousCompte', "00000").
        end.
        /*--> Ventilation
        if prmrg.fgven then do:
            /* tableau => impossible de retrouver le type de travaux */
        end.
        */
    end.
end.
if gcCodeRubrique > ""
then do:
    /* recherche paramétrage type de travaux - analytique */
    find first prmAna no-lock
        where prmAna.tppar = "ANATX"
          and prmAna.tpcon = pcTypeContrat
          and prmAna.fgdos = plDossierTravaux
          and prmAna.norub = gcCodeRubrique
          and prmAna.nossr = gcSousRubrique
          and integer(prmAna.tpurg) = integer(pcTypeUrgence) no-error.
    poCollection:set('cAnalytiqueTravaux', if available prmAna then prmAna.cdpar else "00001").   // par défaut : travaux
end.
assign error-status:error = false no-error. // reset error-status:error
return.
