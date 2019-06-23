/*------------------------------------------------------------------------
File        : solcpt.p
Purpose     : Consultation du solde d'un compte
Author(s)   : SP - 1997/04/10;  gga  -  2017/03/21
Notes       : reprise du programme cadb/gestion/solcpt.p
TODO: Remplacer les paramètres par un poCollection
      pour l'instant on ne recode pas ce pgm, a voir plus tard quand richard aura fini son programme de calcul de solde
Paramètres d'entrée:
    pcCompte-In (Informations concernant le compte séparées par des '|')
        - giCodeSoc   : N° de société
        - giCodeEtab  : N° de mandat
        - VcCptg      : Compte
        - VcCssCpt    : Sous-compte
        - VcTypeSolde : Type de solde
        - gdaSolde : Date du solde
        - VcRefNum    : Numéro de document
Paramètres de sorties :
    pcSolde-Ou  (Informations concernant le solde séparées par des '|')
        - VdCptSolde : Solde comptable
        - VdCpDebit : Capital débit
        - VdCpCredit : Capital crédit
01 | 26/05/1997 | PB  | Prise en compte du numéro de document
02 | 11/07/1997 | PB  | Solde exprimé en centimes
03 | 05/10/1998 | OF  | Ajout extra-comptables pour le droit de bail
04 | 23/12/1998 | JR  | Numero de quittance remplacé par mois de quit
05 | 31/03/99   | XS  | modif sur prd-cd (on utilise ietab)
06 | 28/05/99   | OF  | Il faut ignorer le quitt echu en plus du quitt avance
07 | 24/09/99   | JR  | Modif rapidité
08 | 26/04/00   | OF  | Probleme de calcul du solde quand on est a cheval sur 2 exercices -> il faut filtrer les ANC
09 | 12/07/00   | CC  | Filtre sur les anouveaux = il faut gerer les ANC??
10 | 13/07/00   | PL  | Ajout en retour des zones EURO.
11 | 05/01/01   | JR  | Debug dans le solde extra-comptable: Le test portait sur cecrln.jou-cd et non pas sur cextln.jou-cd.
12 | 08/03/01   | PS  | fiche 0301/0522: pb avec avis d'echéance si quit sur prd-cd = 1 et prd-num = 3
                        => solcpt sur M - 2 ==> erreur si iprd de M - 3 n'existe pas
13 | 14/03/2001 | CC  | fiche 0301/0595 : pb lorsque date en entrée pas compris dans une période
14 | 17/12/2002 | CC  | 1202/0133
15 | 12/04/2005 | SY  | 0205/0262: plages mandats copro/gerance
16 | 22/07/2009 | OF  | 0709/0114: Pb Facture locataire du 30 juin pas prise dans Solde antérieur Quitt juillet
17 | 28/12/16   | OF  | 1216/0073 Suppr msg si exercice n'existe pas
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

/* gga
/* +==============================================+
===|  include global standard (ne pas modifier)   |===
   +==============================================+ */
{comm/allincmn.i "NEW" "GLOBAL"}
{comm/glblibpr.i "NEW"}

/* +==============================================+
===|   include global standard pour la compta     |===
   +==============================================+ */

{comm/gstcptdf.i "NEW" }

/* +============+
===| PARAMETRES |===========================================================
   +============+ */
gga */

define input  parameter pcCompte-In as character no-undo.
define output parameter pcSolde-Ou  as character no-undo.

function initialise returns logical private() forwards.

define variable giCodeSoc     as integer   no-undo.
define variable giCodeEtab    as integer   no-undo.
define variable gdaSolde      as date      no-undo.
define variable gcCsscoll-cle as character no-undo.
define variable gcCompte      as character no-undo.
define variable gcColl-cle    as character no-undo.
define variable gcRefNum      as character no-undo.
define variable glExtraCpta   as logical   no-undo.
define variable glFiltreAnc   as logical   no-undo.

if initialise() then run solcpt.
return.

function initialise returns logical private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcCptg   as character no-undo.
    define variable vcCssCpt as character no-undo.

    define buffer csscptcol for csscptcol.

    /**** Décomposition de la chaîne en entrée ****/
    assign
        giCodeSoc   = integer(entry(1, pcCompte-In, "|"))
        giCodeEtab  = integer(entry(2, pcCompte-In, "|"))
        vcCptg      = entry(3, pcCompte-In, "|")
        vcCssCpt    = entry(4, pcCompte-In, "|")
        gdaSolde    = date(entry(6, pcCompte-In, "|"))
        gcRefNum    = entry(7, pcCompte-In, "|")
        glExtraCpta = entry(8, pcCompte-In, "|") = "E" when num-entries(pcCompte-In, "|") >= 8 /**Ajout OF le 05/10/98**/
        pcSolde-Ou  = "|||||"
    .
    /**** Recherche du collectif ****/
    find first csscptcol no-lock
        where csscptcol.soc-cd     = giCodeSoc
          and csscptcol.etab-cd    = giCodeEtab
          and csscptcol.sscoll-cpt = VcCptg no-error.
    if available csscptcol then assign
        gcCsscoll-cle = csscptcol.sscoll-cle
        gcColl-cle   = csscptcol.coll-cle
        gcCompte     = vcCssCpt
    .
    else assign
        gcCsscoll-cle   = ""
        gcColl-cle     = ""
        gcCompte       = vcCptg + vcCssCpt
    .
    /**** Recherche du compte ****/
    return can-find(first ccpt no-lock
        where ccpt.soc-cd   = giCodeSoc
          and ccpt.coll-cle = gcColl-cle
          and ccpt.cpt-cd   = gcCompte).
end function.

procedure solcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable ViPrdCd          as integer  no-undo.
    define variable VdCpDebit        as decimal  no-undo.
    define variable VdCpCredit       as decimal  no-undo.
    define variable VdCpDebit-Euro   as decimal  no-undo.
    define variable VdCpCredit-Euro  as decimal  no-undo.
    define variable VdDebitRec       as decimal  no-undo.
    define variable VdCreditRec      as decimal  no-undo.
    define variable VdDebitRec-Euro  as decimal  no-undo.
    define variable VdCreditRec-Euro as decimal  no-undo.
    define variable vdaPremierSolde  as date     no-undo.
    
    define buffer ietab  for ietab.
    define buffer iprd   for iprd.
    define buffer vbIprd for iprd.
    
    vdaPremierSolde = date(month(gdaSolde), 1, year(gdaSolde)).
    /**** Recherche de la période comprenant la date gdaSolde ****/
    find first iprd no-lock
        where iprd.soc-cd   = giCodeSoc
          and iprd.etab-cd  = giCodeEtab
          and iprd.dadebprd = vdaPremierSolde no-error.
    if not available iprd
    then do:
        /**** Recherche du mandat ****/
        find first ietab no-lock
            where ietab.soc-cd  = giCodeSoc
              and ietab.etab-cd = giCodeEtab no-error.
        if not available ietab then return.

        find last iprd no-lock
            where iprd.soc-cd  = giCodeSoc
              and iprd.etab-cd = giCodeEtab
              and iprd.prd-cd  = ietab.prd-cd-2 no-error.
        if not available iprd or iprd.dafin = ? or iprd.dafin > vdaPremierSolde
        /*MESSAGE "Période comptable non trouvée pour date de solde au " gdaSolde " (iprd)" SKIP
                "pour le mandat " giCodeEtab
                VIEW-AS ALERT-BOX.*/ /**Modif OF le 28/12/16 - On cherche un solde sur un exercice qui n'existe pas -> il faut retourner zéro sans message**/
        then return.
    end.
    viPrdCd = iprd.prd-cd. /**Ajout Of le 26/04/00**/
    /* todo: bug potentiel en passant par  find last iprd no-lock, c'est l'index prd-i1 qui est utilisé !!! */
    /**Ajout OF le 28/05/99 pour Avance/Echu: En effet, il faut pouvoir ignorer le quitt. du dernier jour du mois precedent (Quitt. echu) **/
    find prev iprd no-lock
        where iprd.soc-cd  = giCodeSoc
          and iprd.etab-cd = giCodeEtab
        use-index prd-i2 no-error.
    if not available iprd
    then find first iprd no-lock
        where iprd.soc-cd   = giCodeSoc
          and iprd.etab-cd  = giCodeEtab
          and iprd.dadebprd = vdaPremierSolde no-error.
    else do:
        glFiltreAnc = (ViPrdCd <> iprd.prd-cd). /**Ajout Of le 26/04/00**/
        /* IF iprd.prd-cd >= ietab.prd-cd-1 /** On ignore les exercices cloturés **/
         * AND iprd.prd-num > 1 * THEN DO:*/   /**Modif OF le 26/04/00**/
        if iprd.prd-num > 1
        then do:                    /**** Calcul du solde des périodes précédentes ****/
            run soldExercice(
                iprd.prd-cd,
                iprd.prd-num - 1,
                output vdDebitRec,
                output vdCreditRec,
                output vdDebitRec-Euro,
                output vdCreditRec-Euro
            ).
            assign
                vdCpDebit       = vdCpDebit       + vdDebitRec
                vdCpCredit      = vdCpCredit      + vdCreditRec
                vdCpDebit-Euro  = vdCpDebit-Euro  + vdDebitRec-Euro
                vdCpCredit-Euro = vdCpCredit-Euro + vdCreditRec-Euro
            .
        end.
    end. /* FIN MODIF ps le 08/03/01 */
    /* Calcul du solde de la partie écoulée de la période courante */
    run soldPeriode(
        iprd.dadeb,
        iprd.dafin,
        output vdDebitRec,
        output vdCreditRec,
        output vdDebitRec-Euro,
        output vdCreditRec-Euro
    ).
    assign
        vdCpDebit       = vdCpDebit       + vdDebitRec
        vdCpCredit      = vdCpCredit      + vdCreditRec
        vdCpDebit-Euro  = vdCpDebit-Euro  + vdDebitRec-Euro
        vdCpCredit-Euro = vdCpCredit-Euro + vdCreditRec-Euro
    .
    /**** Test si l'exercie sélectionné est l'exercice 2,
          si l'exercice 1 n'est pas cloturé et si le compte n'est pas un compte de la classe 6 ou 7 ****/
    if  iprd.prd-cd = /* 2 */ ietab.prd-cd-2
    and ietab.exercice = false
    and not (gcColl-cle = "" and gcCompte >= "6")
    then for last vbIprd no-lock    /**** Recherche de la dernière période de l'exercice 1 ****/
        where vbIprd.soc-cd  = giCodeSoc
          and vbIprd.etab-cd = giCodeEtab
          and vbIprd.prd-cd  = /* 1 */ ietab.prd-cd-1:
        run soldExercice(
            vbIprd.prd-cd,
            vbIprd.prd-num,
            output VdDebitRec,
            output VdCreditRec,
            output VdDebitRec-Euro,
            output VdCreditRec-Euro
        ).
        assign
            vdCpDebit       = vdCpDebit       + vdDebitRec
            vdCpCredit      = vdCpCredit      + vdCreditRec
            vdCpDebit-Euro  = vdCpDebit-Euro  + vdDebitRec-Euro
            VdCpCredit-Euro = VdCpCredit-Euro + VdCreditRec-Euro
        .
    end.
    /**** Composition de la chaîne en sortie ****/
    assign
        entry(1, pcSolde-Ou, "|") = string(truncate((vdCpDebit - vdCpCredit) * 100, 0))
        entry(2, pcSolde-Ou, "|") = string(truncate(vdCpDebit * 100, 0))
        entry(3, pcSolde-Ou, "|") = string(truncate(vdCpCredit * 100, 0))
        entry(4, pcSolde-Ou, "|") = string(truncate((vdCpDebit-Euro - vdCpCredit-Euro) * 100, 0))
        entry(5, pcSolde-Ou, "|") = string(truncate(vdCpDebit-Euro * 100, 0))
        entry(6, pcSolde-Ou, "|") = string(truncate(vdCpCredit-Euro * 100, 0))
    .
end procedure.

procedure soldExercice private:
    /*--------------------------------------------------------------------------
    Purpose: Procédure de Calcul de soldes à partir des cumuls de balance
    Note   :
        - piPrdCd-IN     : N° d'exercice
        - piPrdNum-IN    : N° de période
        - pdSoldDeb-OU   : Solde débit
        - pdSoldCre-OU   : Solde crédit
    ---------------------------------------------------------------------------*/
    define input  parameter piPrdCd-IN        as integer   no-undo.
    define input  parameter piPrdNum-IN       as integer   no-undo.
    define output parameter pdSoldDeb-OU      as decimal   no-undo.
    define output parameter pdSoldCre-OU      as decimal   no-undo.
    define output parameter pdSoldDeb-Euro-OU as decimal   no-undo.
    define output parameter pdSoldCre-Euro-OU as decimal   no-undo.

    define buffer ccptmvt for ccptmvt.
    define buffer cextmvt for cextmvt.

    for each ccptmvt no-lock
        where ccptmvt.soc-cd     = giCodeSoc
          and ccptmvt.etab-cd    = giCodeEtab
          and ccptmvt.sscoll-cle = gcCsscoll-cle
          and ccptmvt.cpt-cd     = gcCompte
          and ccptmvt.prd-cd     = piPrdCd-IN
          and ccptmvt.prd-num   <= piPrdNum-IN:
        assign
            pdSoldDeb-OU      = pdSoldDeb-OU      + ccptmvt.mtdeb      + ccptmvt.mtdebp
            pdSoldCre-OU      = pdSoldCre-OU      + ccptmvt.mtcre      + ccptmvt.mtcrep
            pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + ccptmvt.mtdeb-EURO + ccptmvt.mtdebp-EURO
            pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + ccptmvt.mtcre-EURO + ccptmvt.mtcrep-EURO
        .
    end.
    /**Ajout Extra-comptables par OF le 05/10/98 pour Droit de bail **/
    if glExtraCpta
    then for each cextmvt no-lock
        where cextmvt.soc-cd     = giCodeSoc
          and cextmvt.etab-cd    = giCodeEtab
          and cextmvt.sscoll-cle = gcCsscoll-cle
          and cextmvt.cpt-cd     = gcCompte
          and cextmvt.prd-cd     = piPrdCd-IN
          and cextmvt.prd-num   <= piPrdNum-IN:
        assign
            pdSoldDeb-OU      = pdSoldDeb-OU      + cextmvt.mtdeb      + cextmvt.mtdebp
            pdSoldCre-OU      = pdSoldCre-OU      + cextmvt.mtcre      + cextmvt.mtcrep
            pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + cextmvt.mtdeb-Euro + cextmvt.mtdebp-Euro
            pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + cextmvt.mtcre-Euro + cextmvt.mtcrep-Euro
        .
    end.

end procedure.

procedure soldPeriode private:
    /*--------------------------------------------------------------------------
    Purpose: Procédure de Calcul de soldes à partir des lignes d'écriture
    Note   :
        - piCodeSoc-IN   : N° de société
        - piCodeEtab-IN  : N° de mandat
        - pcSsCollCle-IN : Code collectif
        - pcCpt-IN       : compte
        - pdaDeb-IN      : Date de début
        - pdaFin-IN      : Date de fin
        - pcRefNum-IN    : Numéro de document
        - pdSoldDeb-OU   : Solde débit
        - pdSoldCre-OU   : Solde crédit
    ---------------------------------------------------------------------------*/
    define input  parameter pdaDeb-IN         as date      no-undo.
    define input  parameter pdaFin-IN         as date      no-undo.
    define output parameter pdSoldDeb-OU      as decimal   no-undo.
    define output parameter pdSoldCre-OU      as decimal   no-undo.
    define output parameter pdSoldDeb-Euro-OU as decimal   no-undo.
    define output parameter pdSoldCre-Euro-OU as decimal   no-undo.

    define variable vcJouAnc    as character no-undo.
    define variable vcJouACR    as character no-undo.   /** PS LE 27/07/04 -- F 0104/0212 ==> **/
    define variable viMoisQuit  as integer   no-undo.
    define variable viAnneeQuit as integer   no-undo.
    define variable viMdGerGlb  as integer   no-undo.   /** Ajout SY le 12/04/2005 */

    define buffer ietab  for ietab.
    define buffer ijou   for ijou.
    define buffer cecrln for cecrln.
    define buffer cextln for cextln.
    
    /* Recherche mandat gerance globale */
    find first ietab no-lock
        where ietab.soc-cd = integer(mToken:cRefPrincipale)
          and ietab.profil-cd = 20 no-error.
    viMdGerGlb = if available ietab then ietab.etab-cd else 8000.

    find first ijou no-lock
        where ijou.soc-cd    = integer(mToken:cRefPrincipale)
          and ijou.etab-cd   = 0
          and ijou.natjou-gi = 89 no-error.
    if available ijou then vcJouACR = ijou.jou-cd.            /** <== PS LE 27/07/04 -- F 0104/0212 **/
    
    /* Recherche du journal d'ANC */
    find first ijou no-lock
        where ijou.soc-cd    = giCodeSoc
          and ijou.etab-cd   = giCodeEtab
          and ijou.natjou-gi = 93 no-error. /**Ajout Of le 26/04/00**/
    if available ijou then VcJouAnc = substring(ijou.jou-cd, 1, 3, 'character').

    if gcRefNum > "" then do:
        if gcRefNum begins "@"
        then for first ijou no-lock                /* JR 31/12/98 */
            where ijou.soc-cd    = giCodeSoc
              and ijou.etab-cd   = viMdGerGlb /*8000*/  /** JR le 24/09/99 rapidité * 37 **/
              and ijou.natjou-gi = 53:
            assign
                viMoisQuit  = integer(substring(gcRefNum, 6, 2, 'character'))
                viAnneeQuit = integer(substring(gcRefNum, 2, 4, 'character'))
            .
boucle:
            for each cecrln no-lock
                where cecrln.soc-cd     = giCodeSoc
                  and cecrln.etab-cd    = giCodeEtab
                  and cecrln.sscoll-cle = gcCsscoll-cle
                  and cecrln.cpt-cd     = gcCompte
                  and cecrln.dacompta  >= pdaDeb-IN
                  and cecrln.dacompta  <= pdaFin-IN:
                if cecrln.jou-cd begins VcJouAnc and glFiltreAnc then next boucle.

                if cecrln.jou-cd = ijou.jou-cd
                and (cecrln.dacompta = date(viMoisQuit, 1, viAnneeQuit)
                  or cecrln.dacompta = date(viMoisQuit, 1, viAnneeQuit) - 1)  /**Ajout OF le 28/05/99**/
                and not cecrln.ref-num begins "FL"                          /* Ajout SY/OF le 22/07/2009 - fiche 0709/0114 : Pb Facture locataire du 30 juin pas prise dans Quitt de juillet */
                then next boucle.

                if cecrln.sens then assign
                    pdSoldDeb-OU      = pdSoldDeb-OU      + cecrln.mt
                    pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + cecrln.mt-Euro
                .
                else assign
                    pdSoldCre-OU      = pdSoldCre-OU      + cecrln.mt
                    pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + cecrln.mt-Euro
                .
            end.
        end.
        else for each cecrln no-lock
            where cecrln.soc-cd      = giCodeSoc
              and cecrln.etab-cd     = giCodeEtab
              and cecrln.sscoll-cle  = gcCsscoll-cle
              and cecrln.cpt-cd      = gcCompte
              and cecrln.dacompta   >= pdaDeb-IN
              and cecrln.dacompta   <= pdaFin-IN
              and cecrln.ref-num    <> gcRefNum:
            {&_proparse_ prolint-nowarn(blocklabel)}
            if cecrln.jou-cd begins VcJouAnc and glFiltreAnc then next.

            if cecrln.sens then assign
                pdSoldDeb-OU      = pdSoldDeb-OU      + cecrln.mt
                pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + cecrln.mt-Euro
            .
            else assign
                pdSoldCre-OU      = pdSoldCre-OU      + cecrln.mt
                pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + cecrln.mt-Euro
            .
        end. /* IF pcRefNum-IN BEGINS "@" THEN DO : */
    end.
    else for each cecrln no-lock
       where cecrln.soc-cd     = giCodeSoc
         and cecrln.etab-cd    = giCodeEtab
         and cecrln.sscoll-cle = gcCsscoll-cle
         and cecrln.cpt-cd     = gcCompte
         and cecrln.dacompta  >= pdaDeb-IN
         and cecrln.dacompta  <= pdaFin-IN:
        {&_proparse_ prolint-nowarn(blocklabel)}
        if cecrln.jou-cd begins VcJouAnc and glFiltreAnc then next.

        if cecrln.sens
        then assign
            pdSoldDeb-OU      = pdSoldDeb-OU      + cecrln.mt
            pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + cecrln.mt-Euro
        .
        else assign
            pdSoldCre-OU      = pdSoldCre-OU      + cecrln.mt
            pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + cecrln.mt-Euro
        .
    end.

    /**Ajout Extra-comptables par OF le 05/10/98 pour Droit de bail **/
    if glExtraCpta
    then if gcRefNum > ""
    then for each cextln no-lock
        where cextln.soc-cd      = giCodeSoc
          and cextln.etab-cd     = giCodeEtab
          and cextln.sscoll-cle  = gcCsscoll-cle
          and cextln.cpt-cd      = gcCompte
          and cextln.dacompta   >= pdaDeb-IN
          and cextln.dacompta   <= pdaFin-IN
          and cextln.ref-num    <> gcRefNum:
        {&_proparse_ prolint-nowarn(blocklabel)}
        if cextln.jou-cd begins VcJouAnc and glFiltreAnc then next.

        if cextln.sens then assign
            pdSoldDeb-OU      = pdSoldDeb-OU      + cextln.mt
            pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + cextln.mt-Euro
        .
        else assign
            pdSoldCre-OU      = pdSoldCre-OU      + cextln.mt
            pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + cextln.mt-Euro
        .
    end.
    else for each cextln no-lock
        where cextln.soc-cd     = giCodeSoc
          and cextln.etab-cd    = giCodeEtab
          and cextln.sscoll-cle = gcCsscoll-cle
          and cextln.cpt-cd     = gcCompte
          and cextln.dacompta  >= pdaDeb-IN
          and cextln.dacompta  <= pdaFin-IN:
        {&_proparse_ prolint-nowarn(blocklabel)}
        if (cextln.jou-cd begins VcJouAnc and glFiltreAnc)
        or cextln.jou-cd = vcJouACR then next.                  /** PS LE 27/07/04 -- F 0104/0212 **/

        if cextln.sens then assign
            pdSoldDeb-OU      = pdSoldDeb-OU      + cextln.mt
            pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + cextln.mt-Euro
        .
        else assign
            pdSoldCre-OU      = pdSoldCre-OU      + cextln.mt
            pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + cextln.mt-Euro
        .
    end.

end procedure.
