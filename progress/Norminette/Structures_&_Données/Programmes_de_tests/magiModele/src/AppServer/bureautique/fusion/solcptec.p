/*--------------------------------------------------------------------------+
| Application      : COMPTA-ADB                                             |
| Programme        : gestion/solcptec.p                                     |
| Objet            : Consultation du solde d'un compte par rapport à la     |
|                    date du document (datecr) et non la date comptable     |
|                    Exemple:                                               |
|                    Compta 10/2016 clotûrée le 25/10/2016                  |
|                    Paiement locataire (en retard) le 26/10/2016           |
|                    => date cpta 11/2016 alors que daecr au 26/10/2016     |
|===========================================================================|
|                                                                           |
| Date de cr‚ation : 07/10/2016                                             |
| Auteur(s)        : SY d'après Solcpt.p                                    |
| Fiche            : 1016/0014 ALLIANZ - Etat des impayés locataires        |
|                                                                           |
|===========================================================================|
|                                                                           |
| ParamŠtres d'entrées  :  pcCompte (Informations concernant le compte      |
|                                       separees par des '|')               |
|                          1 - ViCodeSoc : Nø de societe                    |
|                          2 - ViCodeEtab : Nø de mandat                    |
|                          3 - VcCptg : Compte                              |
|                          4 - VcCssCpt : Sous-compte                       |
|                          5 - VcTypeSolde : Type de solde                  |
|                          6 - VjDateSolde : Date du solde                  |
|                          7 - VcRefNum : Numéro de document                |
|                          8 - VlExtraCpta : Insérer les écritures          |
|                                            exta-comptables dans le solde  |
| ParamŠtres de sorties :  pcSolde  (Informations concernant le solde       |
|                                       separees par des '|')               |
|                           - VdCptSolde : Solde comptable                  |
|                           - VdCpDebit  : Capital debit                    |
|                           - VdCpCredit : Capital credit                   |
|                                                                           |
+---------------------------------------------------------------------------+*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define input  parameter pcCompte as character no-undo.
define output parameter pcSolde  as character no-undo.

    define variable VcJouAnc             as character no-undo.
    define variable iMdGerGlb            as integer   no-undo.
    define variable iMoisQuit            as integer   no-undo.
    define variable iAnneeQuit           as integer   no-undo.
    define variable VlFiltreAnc          as logical   no-undo.
    define variable gvlExtraCpta         as logical   no-undo.
    define variable gvcJouACR            as character no-undo.
    define variable gvlDEBUG             as logical   no-undo initial false.

    define variable ViCodeSoc            as integer   no-undo.
    define variable ViCodeEtab           as integer   no-undo.
    define variable VcCptg               as character no-undo.
    define variable VcCssCpt             as character no-undo.
    define variable VcTypeSolde          as character no-undo.
    define variable VjDateSolde          as date      no-undo.
    define variable VdCptSolde           as decimal   no-undo.
    define variable VdCpDebit            as decimal   no-undo.
    define variable VdCpCredit           as decimal   no-undo.
    define variable VdCpDebit-Euro       as decimal   no-undo.
    define variable VdCpCredit-Euro      as decimal   no-undo.
    define variable VcRefNum             as character no-undo.
    define variable csscoll-cle          as character no-undo.
    define variable ccoll-cle            as character no-undo.
    define variable ccompte              as character no-undo.
    define variable VdDebitRec           as decimal   no-undo.
    define variable VdCreditRec          as decimal   no-undo.
    define variable VdDebitRec-Euro      as decimal   no-undo.
    define variable VdCreditRec-Euro     as decimal   no-undo.
    define variable dMois                as integer   no-undo.
    define variable dAnnee               as integer   no-undo.
    define variable ViPrdCd              as integer   no-undo.

    define variable jDateDebSoldePeriode as date      no-undo.
    define variable jDateDebEcr          as date      no-undo.
    define variable iprd-cd-cpta         as integer   no-undo.
    define variable iprd-num-cpta        as integer   no-undo.
    define variable iprd-cd-debdoc       as integer   no-undo.
    define variable iprd-num-debdoc      as integer   no-undo.
    
    define buffer b2_iprd   for iprd.
    define buffer biprd     for iprd.
    define buffer ietab     for ietab.
    define buffer ijou      for ijou.
    define buffer csscptcol for csscptcol.

    /* Recherche mandat gerance globale */
    find first ietab no-lock 
         where ietab.soc-cd = mtoken:iCodeSociete
           and ietab.profil-cd = 20 no-error.
    iMdGerGlb = (if available ietab then ietab.etab-cd else 8000).

    find first ijou no-lock
         where ijou.soc-cd = mtoken:iCodeSociete
           and ijou.etab-cd = 0
           and ijou.natjou-gi = 89 no-error.
    if available ijou then gvcJouACR = ijou.jou-cd.
    /** <== PS LE 27/07/04 -- F 0104/0212 **/

    /**** Decomposition de la chaine en entrée ****/
    assign 
        ViCodeSoc    = integer(entry(1, pcCompte, "|"))
        ViCodeEtab   = integer(entry(2, pcCompte, "|"))
        VcCptg       = entry(3, pcCompte, "|")
        VcCssCpt     = entry(4, pcCompte, "|")
        VcTypeSolde  = entry(5, pcCompte, "|")
        VjDateSolde  = date(entry(6, pcCompte, "|"))
        VcRefNum     = entry(7, pcCompte, "|")
        gvlExtraCpta = entry(8, pcCompte, "|") = "E" when num-entries(pcCompte,"|") > 7 /**Ajout OF le 05/10/98**/
        pcSolde   = "|||||"
    .
    /**IF VcCssCpt  = "00601" AND VcCptg = "4112" THEn FGDEBUG = TRUE.  **/
//    if FgDEBUG then MLog ( "solcptec.p : Ref" + string(ViCodeSoc) + " Etab :" + string(ViCodeEtab) + " VcCssCpt " + VcCssCpt + " VcCptg = " + VcCptg + " VcCssCpt = " + VcCssCpt + " VcTypeSolde = " + VcTypeSolde + " Date du solde : " + string(VjDateSolde) + " Flag Extra-cpta = " + string(VlExtraCpta) ).
    /**** Recherche du mandat ****/
    find first ietab no-lock 
         where ietab.soc-cd  = ViCodeSoc
           and ietab.etab-cd = ViCodeEtab no-error.
    if not available ietab then return.

// if FgDEBUG then Mlog ( "ViCodeSoc = " + STRING(ViCodeSoc) + " mandat " + STRING(ViCodeEtab) + " locataire " + VcCssCpt + " Compte " + VcCptg + " Solde au " + STRING(VjDateSolde) + " Doc VcRefNum = " + VcRefNum + " VlExtraCpta = " + STRING(VlExtraCpta) ).

    /**** Recherche du collectif ****/
    find first csscptcol no-lock
         where csscptcol.soc-cd      = ViCodeSoc
           and csscptcol.etab-cd     = ViCodeEtab
           and csscptcol.sscoll-cpt  = VcCptg no-error.
    if available csscptcol 
    then assign
        csscoll-cle   = csscptcol.sscoll-cle
        ccoll-cle     = csscptcol.coll-cle
        ccompte       = VcCssCpt
    .
    else assign
        csscoll-cle   = ""
        ccoll-cle     = ""
        ccompte       = VcCptg + VcCssCpt
    .

    /**** Recherche du compte ****/
    find first ccpt no-lock
         where ccpt.soc-cd   = ViCodeSoc
           and ccpt.coll-cle = ccoll-cle
           and ccpt.cpt-cd   = ccompte no-error.
    if not available ccpt then return.

    assign 
        dMois  = month(VjDateSolde)
        dAnnee = year(VjDateSolde)
    .

    /**** Recherche de la période comprenant la date VjDateSolde ****/
    find first iprd no-lock
         where iprd.soc-cd   = ViCodeSoc
           and iprd.etab-cd  = ViCodeEtab
           and iprd.dadebprd = date(dMois, 1, dAnnee) no-error.

    /**** JR le 24/09/99 rapidité *3  <= VjDateSolde AND    iprd.dafinprd >= VjDateSolde  ***/
    if not available iprd then do:
           find last iprd no-lock
               where iprd.soc-cd  = ViCodeSoc
                 and iprd.etab-cd = ViCodeEtab
                 and iprd.prd-cd  = ietab.prd-cd-2 use-index prd-i no-error.
           if available iprd and date(dMois, 1, dAnnee) >= iprd.dafin then.
           else do:
                message "Période comptable non trouvée pour date de solde au " VjDateSolde " (iprd)" skip
                        "pour le mandat " ViCodeEtab 
                        view-as alert-box.
            return.
        end.
    end.
    ViPrdCd = iprd.prd-cd. /**Ajout of le 26/04/00**/

    jDateDebSoldePeriode = add-interval(iprd.dadebprd, -1, "months").
    find first iprd no-lock
         where iprd.soc-cd   = ViCodeSoc
           and iprd.etab-cd  = ViCodeEtab
           and iprd.dadebprd = jDateDebSoldePeriode no-error.
    if not available iprd then do:
        VlFiltreAnc = false.
        find first iprd no-lock
             where iprd.soc-cd   = ViCodeSoc
               and iprd.etab-cd  = ViCodeEtab
               and iprd.dadebprd = DATE (dMois,1,dAnnee) no-error.
    end.
    else do:
        VlFiltreAnc = (ViPrdCd ne iprd.prd-cd). /**Ajout Of le 26/04/00**/

        /*IF iprd.prd-cd >= ietab.prd-cd-1 /** On ignore les exercices cloturés **/
         * AND iprd.prd-num > 1 
         * THEN DO:*/   /**Modif OF le 26/04/00**/
    
        if iprd.prd-num > 1 
        then do:
            /**** Calcul du solde des p‚riodes pr‚c‚dentes ****/ 
            run SoldExercice(input  ViCodeSoc,
                             input  ViCodeEtab,
                             input  csscoll-cle,
                             input  ccompte,
                             input  iprd.prd-cd,
                             input  iprd.prd-num - 1,
                             output VdDebitRec,
                             output VdCreditRec,
                             output VdDebitRec-Euro,
                             output VdCreditRec-Euro).
            // if FgDEBUG then MLog ( "Locataire :" + STRING(ViCodeEtab) + VcCssCpt + " solde des périodes précédentes ( -> prd-num " + STRING(iprd.prd-cd) + "." + STRING(iprd.prd-num - 1) + ") = DB " + STRING(VdDebitRec) + " CR " + STRING(VdCreditRec) ).     
            assign
                VdCpDebit       = VdCpDebit       + VdDebitRec
                VdCpCredit      = VdCpCredit      + VdCreditRec
                VdCpDebit-Euro  = VdCpDebit-Euro  + VdDebitRec-Euro
                VdCpCredit-Euro = VdCpCredit-Euro + VdCreditRec-Euro
            .
        end.
    end. /* FIN MODIF ps le 08/03/01 */
    assign
        jDateDebSoldePeriode = iprd.dadebprd 
        iprd-cd-cpta         = iprd.prd-cd
        iprd-num-cpta        = iprd.prd-num 
        jDateDebEcr          = iprd.dadebprd
        iprd-cd-debdoc       = iprd.prd-cd
        iprd-num-debdoc      = iprd.prd-num
    .

    /* Calcul du solde de la partie écoulée de la période courante */
    /* SY 10/10/2016                                                     */
    /* Cas concret Mois cpta Juin 2016 - écriture Doc = 26/05/2016, dacompta = 01/01/2016                                                          */
    /*      lorsque l'on ne fait le balayage qu'à partir de la période en cours :                                                                                     */
    /*               Solde "Doc" au 15/06 : OK     (Solde au 30/04 puis balayage écritures avec datecr entre 01/05 - 15/06 et dacompta >= 01/05)                        */                                            
    /*               Solde "Doc" au 15/07 = 0 FAUX (Solde au 31/05 puis balayage écritures avec datecr entre 01/06 - 15/07 et dacompta >= 01/06) => écriture jamais vue */
    /* il faut rebalayer le dernier mois pour les écritures avec date ecr < iprd.dadeb */    
    find first b2_iprd no-lock
         where b2_iprd.soc-cd  = ViCodeSoc
           and b2_iprd.etab-cd   = ViCodeEtab
           and b2_iprd.dadebprd = add-interval(iprd.dadebprd, -1, "months") no-error.
    if available b2_iprd 
    then assign
        jDateDebEcr     = b2_iprd.dadebprd
        iprd-cd-debdoc  = b2_iprd.prd-cd
        iprd-num-debdoc = b2_iprd.prd-num
    .
    run SoldDocPeriode(input  ViCodeSoc,
                       input  ViCodeEtab,
                       input  csscoll-cle,
                       input  ccompte,
                       input  iprd.dadeb,
                       input  VjDateSolde,
                       input  iprd.dadeb,
                       input  iprd-cd-debdoc,
                       input  iprd-num-debdoc,
                       input  VcRefNum,
                       output VdDebitRec,
                       output VdCreditRec,
                       output VdDebitRec-Euro,
                       output VdCreditRec-Euro).
//    if FgDEBUG then MLog ( "Locataire :" + STRING(ViCodeEtab) + VcCssCpt + " Coll " + csscoll-cle + " solde jusqu'à la date de solde : DOC du " + STRING(jDateDebEcr) + " au " + STRING(VjDateSolde) + " et date comptable >= " + STRING(jDateDebSoldePeriode) + " = DB " + STRING(VdDebitRec) + " CR " + STRING(VdCreditRec) ).     
    assign
        VdCpDebit  = VdCpDebit + VdDebitRec
        VdCpCredit = VdCpCredit + VdCreditRec
        VdCpDebit-Euro  = VdCpDebit-Euro + VdDebitRec-Euro
        VdCpCredit-Euro = VdCpCredit-Euro + VdCreditRec-Euro
    .

    /**** Test si l'exercice s‚lectionn‚ est l'exercice 2,
          si l'exercice 1 n'est pas clotur‚ et
          si le compte n'est pas un compte de la classe 6 ou 7 ****/ 
    if iprd.prd-cd = /* 2 */ ietab.prd-cd-2 
    and ietab.exercice = false 
    and not (ccoll-cle = "" and ccompte >= "6") 
    then do:
        /**** Recherche de la derniŠre p‚riode de l'exercice 1 ****/
        find last biprd no-lock
            where biprd.soc-cd  = ViCodeSoc
              and biprd.etab-cd = ViCodeEtab
              and biprd.prd-cd  = /* 1 */ ietab.prd-cd-1 no-error.
        if available biprd then do:
            run SoldExercice(input  ViCodeSoc,
                             input  ViCodeEtab,
                             input  csscoll-cle,
                             input  ccompte,
                             input  biprd.prd-cd,
                             input  biprd.prd-num,
                             output VdDebitRec,
                             output VdCreditRec,
                             output VdDebitRec-Euro,
                             output VdCreditRec-Euro).
//            if FgDEBUG then MLog ( "Locataire :" + STRING(ViCodeEtab) + VcCssCpt + " solde de la derniere période de l'exercice 1 = DB " + STRING(VdDebitRec) + " CR " + STRING(VdCreditRec) ).     
            assign
                VdCpDebit       = VdCpDebit       + VdDebitRec
                VdCpCredit      = VdCpCredit      + VdCreditRec
                VdCpDebit-Euro  = VdCpDebit-Euro  + VdDebitRec-Euro
                VdCpCredit-Euro = VdCpCredit-Euro + VdCreditRec-Euro
            .
        end.
    end.
    /* Composition de la chaine en sortie */
    assign
        entry(1, pcSolde, "|") = string(truncate((VdCpDebit - VdCpCredit) * 100, 0))
        entry(2, pcSolde, "|") = string(truncate(VdCpDebit  * 100, 0))
        entry(3, pcSolde, "|") = string(truncate(VdCpCredit * 100, 0))
        entry(4, pcSolde, "|") = string(truncate((VdCpDebit-Euro - VdCpCredit-Euro) * 100, 0))
        entry(5, pcSolde, "|") = string(truncate(VdCpDebit-Euro  * 100, 0))
        entry(6, pcSolde, "|") = string(truncate(VdCpCredit-Euro * 100, 0))
    .
    // if FgDEBUG then MLog ( "Locataire : " + STRING(ViCodeEtab) + " " + ccompte + " pcSolde = " + pcSolde ).

procedure SoldExercice:
    /*------------------------------------------------------------------------------
     Purpose: Procedure de Calcul de soldes à partir des cumuls de balance
     Notes:
     Parametres : piCodeSociete  : Nø de societe
                  piCodeEtab     : Nø de mandat
                  pcSSCollCle    : Code collectif
                  piCompte       : compte
                  piPrdCd        : Nø d'exercice
                  piPrdNum       : Nø de pEriode
                  pdSoldeDeb     : Solde debit
                  pdSoldeCre     : Solde credit
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSociete   as integer   no-undo.
    define input  parameter piCodeEtab      as integer   no-undo.
    define input  parameter pcSSCollCle     as character no-undo.
    define input  parameter piCompte        as character no-undo.
    define input  parameter piPrdCd         as integer   no-undo.
    define input  parameter piPrdNum        as integer   no-undo.
    define output parameter pdSoldeDeb      as decimal   no-undo.
    define output parameter pdSoldeCre      as decimal   no-undo.
    define output parameter pdSoldeDeb-Euro as decimal   no-undo.
    define output parameter pdSoldeCre-Euro as decimal   no-undo.

    assign
        pdSoldeDeb = 0
        pdSoldeCre = 0
        pdSoldeDeb-Euro = 0
        pdSoldeCre-Euro = 0
    .
    for each ccptmvt no-lock
       where ccptmvt.soc-cd      = piCodeSociete
         and ccptmvt.etab-cd     = piCodeEtab
         and ccptmvt.sscoll-cle  = pcSSCollCle
         and ccptmvt.cpt-cd      = piCompte
         and ccptmvt.prd-cd      = piPrdCd
         and ccptmvt.prd-num    <= piPrdNum:
        assign
            pdSoldeDeb = pdSoldeDeb 
                       + ccptmvt.mtdeb 
                       + ccptmvt.mtdebp
            pdSoldeCre = pdSoldeCre 
                       + ccptmvt.mtcre 
                       + ccptmvt.mtcrep
            pdSoldeDeb-Euro = pdSoldeDeb-Euro 
                            + ccptmvt.mtdeb-EURO 
                            + ccptmvt.mtdebp-EURO
            pdSoldeCre-Euro = pdSoldeCre-Euro 
                            + ccptmvt.mtcre-EURO 
                            + ccptmvt.mtcrep-EURO
        .
    end.

    /**Ajout Extra-comptables par OF le 05/10/98 pour Droit de bail **/
    if gvlExtraCpta 
    then for each cextmvt no-lock
           where cextmvt.soc-cd     =  piCodeSociete
             and cextmvt.etab-cd    =  piCodeEtab
             and cextmvt.sscoll-cle =  pcSSCollCle
             and cextmvt.cpt-cd     =  piCompte
             and cextmvt.prd-cd     =  piPrdCd
             and cextmvt.prd-num    <= piPrdNum:
        assign
            pdSoldeDeb      = pdSoldeDeb 
                            + cextmvt.mtdeb 
                            + cextmvt.mtdebp
            pdSoldeCre      = pdSoldeCre 
                            + cextmvt.mtcre 
                            + cextmvt.mtcrep
            pdSoldeDeb-Euro = pdSoldeDeb-Euro 
                            + cextmvt.mtdeb-Euro 
                            + cextmvt.mtdebp-Euro
            pdSoldeCre-Euro = pdSoldeCre-Euro 
                            + cextmvt.mtcre-Euro 
                            + cextmvt.mtcrep-Euro
        .
    end.

end procedure.

procedure SoldDocPeriode:
    /*------------------------------------------------------------------------------
     Purpose: Procedure de Calcul de soldes a partir des lignes d'ecriture
     Notes:
     Parametres : piCodeSociete  : Nø de societe
                  piCodeEtab     : Nø de mandat
                  pcSSCollCle    : Code collectif
                  piCompte       : compte
                  pdaDateDeb     : Date de debut DOC
                  pdaDateFin     : Date de fin (date de solde)
                  pdaComptaMin   : Date compta min
                  piPrdCd     : Nø d'exercice date deb DOC
                  piPrdNum    : Nø de période date deb DOC
                  VcRefNum-IN    : Numéro de document
                  pdSoldeDeb   : Solde debit
                  pdSoldeCre   : Solde credit
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSociete     as integer   no-undo.
    define input  parameter piCodeEtab        as integer   no-undo.
    define input  parameter pcSSCollCle       as character no-undo.
    define input  parameter piCompte          as character no-undo.
    define input  parameter pdaDateDeb        as date      no-undo.
    define input  parameter pdaDateFin        as date      no-undo.
    define input  parameter pdaComptaMin      as date      no-undo.
    define input  parameter piPrdCdDebDoc     as integer   no-undo.
    define input  parameter piPrdNumDebDoc as integer   no-undo.
    define input  parameter VcRefNum-IN       as character no-undo.
    define output parameter pdSoldeDeb      as decimal   no-undo.
    define output parameter pdSoldeCre      as decimal   no-undo.
    define output parameter pdSoldeDeb-Euro as decimal   no-undo.
    define output parameter pdSoldeCre-Euro as decimal   no-undo.

   /*IF FgDEBUG THEN Mlog ("SolcptEc.p : SoldDocPeriode " + STRING(piCodeEtab,"99999") + piCompte + " Coll = " + pcSSCollCle + " du " + STRING(pdaDateDeb) +  " au " + STRING(pdaDateFin)).*/

   /* Recherche du journal d'ANC */
    find first ijou no-lock
         where ijou.soc-cd    = piCodeSociete 
           and ijou.etab-cd   = piCodeEtab 
           and ijou.natjou-gi = 93 no-error. /**Ajout Of le 26/04/00**/
    if available ijou then VcJouAnc = substring(ijou.jou-cd, 1, 3).
    release ijou.
    assign
        pdSoldeDeb      = 0
        pdSoldeCre      = 0
        pdSoldeDeb-Euro = 0
        pdSoldeCre-Euro = 0
    .
    if VcRefNum-IN > "" then do:
        if VcRefNum-IN begins "@" then do :
            /* JR 31/12/98 */
            find first ijou no-lock
                 where ijou.soc-cd  = piCodeSociete 
                   and ijou.etab-cd = iMdGerGlb 
                   and ijou.natjou-gi = 53 no-error.
            assign 
                iMoisQuit  = integer(substring(VcRefNum-IN, 6, 2))
                iAnneeQuit = integer(substring(VcRefNum-IN, 2, 4))
            .
            for each cecrln no-lock 
               where cecrln.soc-cd     = piCodeSociete
                 and cecrln.etab-cd    = piCodeEtab
                 and cecrln.sscoll-cle = pcSSCollCle
                 and cecrln.cpt-cd     = piCompte
                 and cecrln.dacompta   >= pdaComptaMin
                 and cecrln.datecr     <= pdaDateFin:
                     /*
                       IF cecrln.prd-cd = piPrdCdDebDoc AND cecrln.prd-num < piPrdNumDebDoc THEn NEXT.
                       IF cecrln.prd-cd > piPrdCdDebDoc THEN VlFiltreAnc = TRUE.
                     */
                if cecrln.jou-cd begins VcJouAnc and VlFiltreAnc then next.
/*                     if FgDEBUG then do:
                        message "SoldDocPeriode - Ecriture - mandat " piCodeEtab " locataire " piCompte " coll " pcSSCollCle   skip
                            " cecrln.jou-cd = " cecrln.jou-cd " cecrln.dacompta = " cecrln.dacompta " cecrln.datecr = " cecrln.datecr skip
                            "Sauf " date(iMoisQuit,1,iAnneeQuit) " ou " date(iMoisQuit,1,iAnneeQuit) - 1 skip
                            "cecrln.ref-num = " cecrln.ref-num
                            view-as alert-box.  
                     end.
*/
                if cecrln.jou-cd = ijou.jou-cd 
                and (cecrln.dacompta = DATE(iMoisQuit,1,iAnneeQuit) 
                     or cecrln.dacompta = DATE(iMoisQuit,1,iAnneeQuit) - 1) /**Ajout OF le 28/05/99**/
                and not cecrln.ref-num begins "FL"         /* Ajout SY/OF le 22/07/2009 - fiche 0709/0114 : Pb Facture locataire du 30 juin pas prise dans Quitt de juillet */                              
                then next.

                if cecrln.sens = true 
                then assign 
                    pdSoldeDeb      = pdSoldeDeb      + cecrln.mt
                    pdSoldeDeb-Euro = pdSoldeDeb-Euro + cecrln.mt-Euro
                .
                 else assign 
                     pdSoldeCre      = pdSoldeCre      + cecrln.mt
                     pdSoldeCre-Euro = pdSoldeCre-Euro + cecrln.mt-Euro
                 .
            end. /* FOR EACH cecrln */
        end.
        else for each cecrln no-lock
                where cecrln.soc-cd     =  piCodeSociete
                  and cecrln.etab-cd    =  piCodeEtab
                  and cecrln.sscoll-cle =  pcSSCollCle
                  and cecrln.cpt-cd     =  piCompte
                  and cecrln.dacompta   >= pdaComptaMin
                  and cecrln.datecr     >= pdaDateDeb
                  and cecrln.datecr     <= pdaDateFin
                  and cecrln.ref-num    <> VcRefNum-IN :
                  /*
                     IF cecrln.prd-cd = piPrdCdDebDoc AND cecrln.prd-num < piPrdNumDebDoc THEn NEXT.
                     IF cecrln.prd-cd > piPrdCdDebDoc THEN VlFiltreAnc = TRUE.
                  */
            if cecrln.jou-cd begins VcJouAnc and VlFiltreAnc then next.
            if cecrln.sens = true 
            then assign 
                pdSoldeDeb      = pdSoldeDeb      + cecrln.mt
                pdSoldeDeb-Euro = pdSoldeDeb-Euro + cecrln.mt-Euro
            .
            else assign 
                pdSoldeCre      = pdSoldeCre      + cecrln.mt
                pdSoldeCre-Euro = pdSoldeCre-Euro + cecrln.mt-Euro
            .
        end. /* FOR EACH cecrln */
    end. /* IF VcRefNum-IN BEGINS "@" THEN DO : */
    else for each cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = piCodeEtab
              and cecrln.sscoll-cle = pcSSCollCle
              and cecrln.cpt-cd     = piCompte
              and cecrln.dacompta   >= pdaComptaMin
              and cecrln.datecr     <= pdaDateFin:
        if cecrln.jou-cd begins VcJouAnc and VlFiltreAnc then next.
/*                if FgDEBUG 
                then message "SoldDocPeriode - Ecriture - mandat " piCodeEtab " locataire " piCompte " coll " pcSSCollCle   skip
                            " cecrln.jou-cd = " cecrln.jou-cd " prd = " cecrln.prd-num "." cecrln.prd-cd " cecrln.dacompta = " cecrln.dacompta " cecrln.datecr = " cecrln.datecr cecrln.sens cecrln.mt skip
                            /*"Sauf " DATE(iMoisQuit,1,iAnneeQuit) " ou " DATE(iMoisQuit,1,iAnneeQuit) - 1 SKIP
                            "cecrln.ref-num = " cecrln.ref-num*/ view-as alert-box.
*/
        if cecrln.sens = true 
        then assign 
            pdSoldeDeb      = pdSoldeDeb      + cecrln.mt
            pdSoldeDeb-Euro = pdSoldeDeb-Euro + cecrln.mt-Euro
        .
        else assign 
            pdSoldeCre      = pdSoldeCre      + cecrln.mt
            pdSoldeCre-Euro = pdSoldeCre-Euro + cecrln.mt-Euro
        .
    end.
    /**Ajout Extra-comptables par OF le 05/10/98 pour Droit de bail **/
    if gvlExtraCpta then do: 
        if VcRefNum-IN > "" 
        then for each cextln no-lock
                where cextln.soc-cd     = piCodeSociete
                  and cextln.etab-cd    = piCodeEtab
                  and cextln.sscoll-cle = pcSSCollCle
                  and cextln.cpt-cd     = piCompte
                  and cextln.dacompta   >= pdaComptaMin
                  and cextln.datecr     <= pdaDateFin
                  and cextln.ref-num    <> VcRefNum-IN:
            if cextln.jou-cd begins VcJouAnc and VlFiltreAnc then next.
            if cextln.sens = true 
            then assign 
                pdSoldeDeb      = pdSoldeDeb      + cextln.mt
                pdSoldeDeb-Euro = pdSoldeDeb-Euro + cextln.mt-Euro
            .
            else assign 
                pdSoldeCre      = pdSoldeCre      + cextln.mt
                pdSoldeCre-Euro = pdSoldeCre-Euro + cextln.mt-Euro
            .
        end.
        else for each cextln no-lock
                where cextln.soc-cd     = piCodeSociete
                  and cextln.etab-cd    = piCodeEtab
                  and cextln.sscoll-cle = pcSSCollCle
                  and cextln.cpt-cd     = piCompte
                  and cextln.dacompta   >= pdaComptaMin
                  and cextln.datecr     <= pdaDateFin:
            if cextln.jou-cd begins VcJouAnc and VlFiltreAnc then next.
            if cextln.jou-cd = gvcJouACR then next. /** PS LE 27/07/04 -- F 0104/0212 **/
            if cextln.sens = true 
            then assign 
                pdSoldeDeb      = pdSoldeDeb      + cextln.mt
                pdSoldeDeb-Euro = pdSoldeDeb-Euro + cextln.mt-Euro
            .
            else assign
                pdSoldeCre      = pdSoldeCre      + cextln.mt
                pdSoldeCre-Euro = pdSoldeCre-Euro + cextln.mt-Euro
            .
        end.
   end.

end procedure.
 