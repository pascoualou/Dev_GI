/*------------------------------------------------------------------------
File        : solcptch.p
Purpose     : Calcul du solde d'un compte CHB 99999 par N° Dossier
Author(s)   : JR - 2004/01/06;  gga  -  2017/04/07
Notes       : reprise du pgm cadb\src\gestion\solcptch.p

Paramètres d'entrée: VvcCompte-In (Informations concernant le compte séparées par des '|')
    - ViCodeSoc : N° de société
    - ViCodeEtab : N° de mandat
    - VcCptg : Compte
    - VcCssCpt : Sous-compte
    - VcTypeSolde : Type de solde
    - VjDateSolde : Date du solde
    - VcRefNum : Numéro de document

Paramètres de sortie: VcSolde-Ou  (Informations concernant le solde séparées par des '|')
    - VdCptSolde : Solde comptable
    - VdCpDebit : Capital débit
    - VdCpCredit : Capital crédit

01  | 24/03/06  |  DM  | 0306/0474 Pb solde CHB par dossier si compte soldé
02  | 11/05/06  |  JR  | 0506/0106 corr fiche 0306/0474
03  | 13/11/06  |  OF  | 1106/0058 On prend les ecritures des exercices anterieurs + les ANC dans le solde
04  | 04/05/08  |  DM  | 0408/0058 Pb odfe sur compte avant sru
05  | 05/08/08  |  OF  | 0808/0015 Pb odfe sur ecriture ayant un n° de dossier qui n'existe pas
06  | 09/09/09  |  JR  | 0909/0014 Debug erreur 600 pour les travaux
07  | 11/05/10  |  DM  | 0510/0027 pb solde dossier dans les travaux
08  | 18/10/11  |  DM  | ????/???? verrue 3103
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{preprocesseur/type2contrat.i}

define variable giNumeroMandat   as integer   no-undo.
define variable giCodeSoc        as integer   no-undo.
define variable gdaDateSolde     as date      no-undo.
define variable glExtraCpta      as logical   no-undo.
define variable giNumeroDossier  as integer   no-undo.

function filtreDossier returns logical private(piDossierIn as integer):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    if giNumeroDossier = 0
    then do:
        if piDossierIn <> 0
        and can-find(first trdos no-lock
                     where trdos.tpcon = {&TYPECONTRAT-mandat2Syndic}
                       and trdos.nocon = giNumeroMandat
                       and trdos.nodos = piDossierIn) then return true.
    end.
    else if piDossierIn <> giNumeroDossier then return true.
    return false.

end function.

procedure solcptchCalculSolde:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par dossierTravaux.p
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as collection no-undo.

    define variable vcSsCollCle    as character no-undo.
    define variable vcCollCle      as character no-undo.
    define variable vcCompte       as character no-undo.
    define variable viMois         as integer   no-undo.
    define variable viAnnee        as integer   no-undo.
    define variable vdaDateDeb     as date      no-undo.
    define variable vcCpt          as character no-undo.
    define variable vcCssCpt       as character no-undo.
    define variable vdSolde        as decimal   no-undo.
    define variable vdCpDebit      as decimal   no-undo.
    define variable vdCpCredit     as decimal   no-undo.
    define variable vdSoldeEuro    as decimal   no-undo.
    define variable vdCpDebitEuro  as decimal   no-undo.
    define variable vdCpCreditEuro as decimal   no-undo.

    define buffer ietab     for ietab.
    define buffer iprd      for iprd.
    define buffer vbIprd    for iprd.
    define buffer csscptcol for csscptcol.
    define buffer ccpt      for ccpt.

    assign
        giNumeroMandat  = poCollection:getInteger("iNumeroMandat")
        giNumeroDossier = poCollection:getInteger("iNumeroDossierTravaux")
        giCodeSoc       = poCollection:getInteger("iCodeSoc")
        vcCpt           = poCollection:getCharacter("cCpt")
        vcCssCpt        = poCollection:getCharacter("cCssCpt")
        gdaDateSolde    = poCollection:getDate("daDateSolde")
        glExtraCpta     = poCollection:getLogical("lExtraCpta")
    .

message "debut solcptchCalculSolde" .

    /* initialisation a zero des variables en retour */
    poCollection:set('dSolde'        , decimal(0)) no-error.
    poCollection:set('dCpDebit'      , decimal(0)) no-error.
    poCollection:set('dCpCredit'     , decimal(0)) no-error.
    poCollection:set('dSolde-euro'   , decimal(0)) no-error.
    poCollection:set('dCpDebit-Euro' , decimal(0)) no-error.
    poCollection:set('dCpCredit-Euro', decimal(0)) no-error.

    /**** Recherche du mandat ****/
    find first ietab no-lock
         where ietab.soc-cd  = giCodeSoc
           and ietab.etab-cd = giNumeroMandat no-error.
    if not available ietab then return.

    if gdaDateSolde >= ietab.dadebex2
    then vdaDateDeb = if ietab.exercice then ietab.dadebex2 else ietab.dadebex1.
    else if gdaDateSolde >= ietab.dadebex1
    then vdaDateDeb = ietab.dadebex1.
    else for first iprd no-lock
        where iprd.soc-cd   = ietab.soc-cd
          and iprd.etab-cd  = ietab.etab-cd
          and iprd.dadebprd <= gdaDateSolde
          and iprd.dafinprd >= gdaDateSolde
      , first vbIprd no-lock
        where vbIprd.Soc-cd  = iprd.soc-cd
          and vbIprd.etab-cd = iprd.etab-cd
          and vbIprd.prd-cd  = iprd.prd-cd:
        vdaDateDeb = vbIprd.dadebprd.
    end.
    /**** Recherche du collectif ****/
    find first csscptcol no-lock
        where csscptcol.soc-cd     = giCodeSoc
          and csscptcol.etab-cd    = giNumeroMandat
          and csscptcol.sscoll-cpt = vcCpt no-error.
    if available csscptcol
    then assign
        vcSsCollCle = csscptcol.sscoll-cle
        vcCollCle   = csscptcol.coll-cle
        vcCompte    = vcCssCpt
    .
    else assign
        vcSsCollCle = ""
        vcCollCle   = ""
        vcCompte    = vcCpt + vcCssCpt
     .
    /**** Recherche du compte ****/
    find first ccpt no-lock
         where ccpt.soc-cd   = giCodeSoc
           and ccpt.coll-cle = vcCollCle
           and ccpt.cpt-cd   = vcCompte no-error.
    if not available ccpt then return.

    /**** Recherche de la période comprenant la date gdaDateSolde ****/
    assign
        viMois  = month(gdaDateSolde)
        viAnnee = year(gdaDateSolde)
    .
    find first iprd no-lock
        where iprd.soc-cd   = giCodeSoc
          and iprd.etab-cd  = giNumeroMandat
          and iprd.dadebprd = date(viMois, 1, viAnnee) no-error.
    if not available iprd
    then do:
        find last iprd no-lock
            where iprd.soc-cd  = giCodeSoc
              and iprd.etab-cd = giNumeroMandat
              and iprd.prd-cd  = ietab.prd-cd-2 no-error.
        if not available iprd or date(viMois, 1, viAnnee) < iprd.dafin then return.
    end.

/*** DM 0306/0474 Pour le solde d'un CHB par dossier, il faut prendre les écritures de tous les exercices
                  car un CHB peut être soldé globalement (donc par reporté en A nouveau) mais avoir ces dossiers
                  non soldés ***/

    /*IF AVAILABLE csscptcol THEN*/  /**Modif OF le 13/11/06**/
    run SoldIndiv(vcSsCollCle, vcCompte, vdaDateDeb,
                  output vdCpDebit, output vdCpCredit, output vdCpDebitEuro, output vdCpCreditEuro).
    assign
        vdSolde     = vdCpDebit - vdCpCredit
        vdSoldeEuro = vdCpDebitEuro - vdCpCreditEuro
    .
    /* maj des variables de retour */
    poCollection:set('dSolde'        , decimal(vdSolde))        no-error.
    poCollection:set('dCpDebit'      , decimal(vdCpDebit))      no-error.
    poCollection:set('dCpCredit'     , decimal(vdCpCredit))     no-error.
    poCollection:set('dSolde-euro'   , decimal(vdSoldeEuro))    no-error.
    poCollection:set('dCpDebit-Euro' , decimal(vdCpDebitEuro))  no-error.
    poCollection:set('dCpCredit-Euro', decimal(vdCpCreditEuro)) no-error.

end procedure.

procedure SoldIndiv private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter  pcSsCollCle-IN    as character  no-undo.
    define input parameter  pcCpt-IN          as character no-undo.
    define input parameter  pdaDateDeb-IN     as date no-undo.
    define output parameter pdSoldDeb-OU      as decimal no-undo.
    define output parameter pdSoldCre-OU      as decimal no-undo.
    define output parameter pdSoldDeb-Euro-OU as decimal no-undo.
    define output parameter pdSoldCre-Euro-OU as decimal no-undo.

    define variable vdaTmpDa1erAN as date      no-undo.
    define variable vcJouAnc      as character no-undo.

    define buffer iprd for iprd.
    define buffer ijou for ijou.
    define buffer cecrln for cecrln.
    define buffer cecrsai for cecrsai.
    define buffer cextln for cextln.

    {&_proparse_ prolint-nowarn(use-index)}
    find first iprd no-lock
         where iprd.soc-cd  = giCodeSoc
           and iprd.etab-cd = giNumeroMandat
    use-index prd-i2 no-error.
    if not available iprd
    then return.

    /* Recherche du journal d'ANC */
    for first ijou no-lock
        where ijou.soc-cd    = giCodeSoc
          and ijou.etab-cd   = giNumeroMandat
          and ijou.natjou-gi = 93:
        vcJouAnc = substring(ijou.jou-cd, 1, 3, 'character').
    end.

    assign
        pdSoldDeb-OU      = 0
        pdSoldCre-OU      = 0
        pdSoldDeb-Euro-OU = 0
        pdSoldCre-Euro-OU = 0
    .
    for first cecrln no-lock
        where cecrln.soc-cd     = giCodeSoc
          and cecrln.etab-cd    = giNumeroMandat
          and cecrln.sscoll-cle = pcSsCollCle-IN
          and cecrln.cpt-cd     = pcCpt-IN
          and cecrln.dacompta   <= gdaDateSolde
          and cecrln.jou-cd     = vcJouAnc:
        vdaTmpDa1erAN = cecrln.dacompta.
    end.
boucle:
    for each cecrln no-lock
       where cecrln.soc-cd     = giCodeSoc
         and cecrln.etab-cd    = giNumeroMandat
         and cecrln.sscoll-cle = pcSsCollCle-IN
         and cecrln.cpt-cd     = pcCpt-IN
         and cecrln.dacompta <= gdaDateSolde
         and (if pcSsCollCle-IN = "" and pcCpt-IN >= "6" and pdaDateDeb-IN <> ? then cecrln.dacompta >= pdaDateDeb-IN
                                                                                else true):
        find first cecrsai no-lock
             where cecrsai.soc-cd    = cecrln.soc-cd
               and cecrsai.etab-cd   = cecrln.mandat-cd
               and cecrsai.jou-cd    = cecrln.jou-cd
               and cecrsai.prd-cd    = cecrln.mandat-prd-cd
               and cecrsai.prd-num   = cecrln.mandat-prd-num
               and cecrsai.piece-int = cecrln.piece-int no-error.
        if cecrln.jou-cd begins vcJouAnc
        and not (cecrln.prd-cd = iprd.prd-cd and cecrln.prd-num = iprd.prd-num) /* Ne pas filtrer les 1ers a-nouveaux */
        /* DM ????/???? On prend les 1er AN de migration*/
        and not (giCodeSoc = 3103 and available cecrsai and cecrsai.usrid matches "*MIGRATION*" and cecrsai.dacompta = vdaTmpDa1erAN)
        /* FIN DM ????/???? */
        then next boucle.

        /** Filtre sur N° Dossier Travaux **/
        if FiltreDossier(cecrln.affair-num) = true then next boucle.

        if cecrln.sens = true
        then assign
            pdSoldDeb-OU      = pdSoldDeb-OU      + cecrln.mt
            pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + cecrln.mt-Euro
        .
        else assign
            pdSoldCre-OU      = pdSoldCre-OU      + cecrln.mt
            pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + cecrln.mt-Euro
        .
    end.

    if glExtraCpta
    then for each cextln no-lock
       where cextln.soc-cd     = giCodeSoc
         and cextln.etab-cd    = giNumeroMandat
         and cextln.sscoll-cle = pcSsCollCle-IN
         and cextln.cpt-cd     = pcCpt-IN
         and cextln.dacompta   <= gdaDateSolde:
        /** Filtre sur N° Dossier Travaux **/
        if FiltreDossier(cextln.affair-num) then next.

        if cextln.sens = true
        then assign
            pdSoldDeb-OU      = pdSoldDeb-OU      + cextln.mt
            pdSoldDeb-Euro-OU = pdSoldDeb-Euro-OU + cextln.mt-Euro
        .
        else assign
            pdSoldCre-OU      = pdSoldCre-OU      + cextln.mt
            pdSoldCre-Euro-OU = pdSoldCre-Euro-OU + cextln.mt-Euro
        .
    end.

end procedure.
