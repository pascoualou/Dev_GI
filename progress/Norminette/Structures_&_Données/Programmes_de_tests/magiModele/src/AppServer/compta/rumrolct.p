/*--------------------------------------------------------------------------*
|                                                                           |
| Application      : A.D.B. Progress version graphique                      |
| Programme        : rumrolct.p                                             |
| Objet            : Extraction ICS + Nom créancier + RUM                   |
|                    pour un mandat + role + contrat                        |
|---------------------------------------------------------------------------|
|                                                                           |
| Date de création : 22/07/2013                                             |
| Auteur(s)        : SY                                                     |
| Fiche            : 0511/0023                                              |
|                                                                           |
| Utilisé par      : cgLocat.i,destinat.p,bail.p,prebail.p...               |
|                                                                           |
*---------------------------------------------------------------------------*

*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  No  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| 0001 | 24/07/2013 |   SY   | Ajout infos banque de prélèvement en sortie  |
|      |            |        | dans LbDivPar-OU                             |
| 0002 | 25/07/2013 |   SY   | Sortir les infos du créancier même si pas    |
|      |            |        | (encore) en prélèvement (pour les courriers) |
| 0003 | 26/07/2013 |   SY   | Nouvelle table ibqics pour nom du créancier  |
|      |            |        | à partir de version V11.07                   |
| 0004 | 06/09/2013 |   SY   | 0511/0023 Ajout adresse créancier (ibqics)   |
|      |            |        |(demande Geneviève et Christine le 04/09/2013)|
|      |            |        | à partir de version V11.08                   |
| 0005 | 15/11/2013 |   SY   | 1113/0097 renvoyer la RUM même si mandat pas |
|      |            |        | encore valide                                |
| 0006 | 22/04/2015 |   SY   | 0315/0193 renvoyer code journal + banque de  |
|      |            |        | prélèvement du compte même si ijou absent    |
|      |            |        | pour pouvoir gérer l'erreur au retour        |
| 0007 | 08/07/2015 |   SY   | 1013/0126 Prélèvement mensuel des locataires |
|      |            |        | quittancés au Trimestre                      |
|      |            |        |                                              |
*--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
| LbDivPar-OU :  séparateur = "|"                                          |
| (1) Journal Banque prel                                                  |
| (2) Mandat Banque prel                                                   |
| (3)                                                                      |
*--------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}

/*-------------------------------------------------------------------------*
   PROCEDURES
 *-------------------------------------------------------------------------*/
//{compta/include/prcmsepa.i}        /* PROCEDURE IsMandatSepaValide: */
{compta/include/BquePrel.i}        /* PROCEDURE Banque_Du_Compte : */
{compta/include/bqudfmdt.i}        /* PROCEDURE BquDfMdt: */

procedure rumRoleContrat:
    /*------------------------------------------------------------------------------
        Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter iNoRef-IN         as integer   no-undo.
    define input  parameter piNumeroMandat    as integer   no-undo.
    define input  parameter pcTypeRole        as character no-undo.
    define input  parameter piNumeroRole      as int64     no-undo.
    define input  parameter pcTypeContrat     as character no-undo.
    define input  parameter piNumeroContrat   as int64     no-undo.
    define input  parameter pdDatePrelevement as date      no-undo.
    define output parameter iNomandatSEPA-OU  as int64     no-undo.
    define output parameter cRUM-OU           as character no-undo.
    define output parameter cICS-OU           as character no-undo.
    define output parameter cNomCreancier-OU  as character no-undo.
    define output parameter LbDivPar-OU       as character no-undo.

//    {glbgi_df.i}    /* partie générale toutes applications */

    /* No ref */
    define variable GicodeSoc    as integer   no-undo.
    define variable GiCodeEtab   as integer   no-undo.

    define variable cdSAERRret          as character no-undo.
    define variable LbMesErr            as character no-undo.
    define variable cJournalBanque      as character no-undo.
    define variable iMandatBanque       as integer   no-undo.
    define variable iProfilBanque       as integer   no-undo.
    define variable ccpt-cd             as character no-undo.
    define variable FgPrelev            as logical   no-undo.
    define variable NoErrUse            as integer   no-undo.
    define variable LsInfoBqu           as character no-undo.
    define variable csscoll-cle         as character no-undo.
    define variable LsModReg            as character no-undo.
    define variable cAdresseCreancier   as character no-undo.

//    {fctadb.i}

    define buffer bmandatSepa for mandatSepa.
    define buffer btache for tache.
    define buffer bietab for ietab.
    define buffer bctrat for ctrat.

    find last bmandatSepa no-lock
        where bmandatSepa.Tpmandat = "01052"        /* mandat prélèvement SEPA */
          and bmandatSepa.ntcon    = "03107"           /* récurrent */
          and bmandatSepa.nomdt    = piNumeroMandat
          and bmandatSepa.tpcon    = pcTypeContrat
          and bmandatSepa.nocon    = piNumeroContrat
          and bmandatSepa.tprol    = pcTypeRole
          and bmandatSepa.norol    = piNumeroRole
        use-index ix_mandatSepa07 no-error.
    if available bmandatSepa 
    then assign
        iNomandatSEPA-OU = bmandatSepa.noMPrelSEPA
        cRUM-OU          = bmandatSepa.codeRUM
    .
    case pcTypeContrat:
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-preBail} then do:
            csscoll-cle = "L".
            ccpt-cd = substring(string(piNumeroContrat, "9999999999"), 6, 5).
            find last btache no-lock 
                where btache.tpcon = pcTypeContrat /* bail */ 
                  and btache.nocon = piNumeroContrat
                  and btache.tptac = {&TYPETACHE-quittancement}      /* Quittancement */ no-error.
            if available btache and LOOKUP(btache.cdreg , "22003,22013,22002") > 0 then FgPrelev = true.    /* SY 1013/0126 */
        end.
        when {&TYPECONTRAT-titre2copro} then do:
            csscoll-cle = "C".
            find bctrat no-lock
                where bctrat.tpcon = pcTypeContrat 
                  and bctrat.nocon = piNumeroContrat no-error.
            if available bctrat and num-entries(bctrat.lbdiv, "@") >= 2 then do:
                ccpt-cd  = string(bctrat.norol , "99999").
                LsModReg = entry(2,bctrat.lbdiv,"@").
                if lookup("22003", LsModReg, "#" ) > 0  or lookup("22006", LsModReg, "#" ) > 0 then FgPrelev = true.
            end.
        end.
        otherwise do:
            message "Type de contrat non géré (rumrolct.p): " pcTypeContrat.
            return.
        end.
    end case.

    /** banque par défaut du compte **/
    run Banque_Du_Compte(input  iNoRef-IN
                       , input  piNumeroMandat
                       , input  csscoll-cle
                       , input  ccpt-cd
                       , output cJournalBanque
                       , output iMandatBanque
                       , output iProfilBanque).
    
    /** Pas de banque rattachée au compte : On prends alors celle du mandat **/
    if cJournalBanque = "" or cJournalBanque = "-" 
    then run BquDfMdt(iNoRef-IN, piNumeroMandat, output NoErrUse, output cJournalBanque, output iMandatBanque, input-output LsInfoBqu). /** Banque par défaut du mandat **/

    /* SY 0315/0193 renvoyer le journal de banque de prélèvement du compte */
    LbDivPar-OU = cJournalBanque + "|" + string(iMandatBanque, "99999").
                
    for first ijou no-lock
        where ijou.soc-cd  = iNoRef-IN
          and ijou.etab-cd = iMandatBanque
          and ijou.jou-cd  = cJournalBanque
      , first ibque no-lock
        where ibque.soc-cd  = ijou.soc-cd
          and ibque.etab-cd = ijou.etab-cd
          and ibque.cpt-cd  = ijou.cpt-cd:
        assign
            cICS-OU           = ibque.ics
            cNomCreancier-OU  = ibque.domicil[1]
            cAdresseCreancier = "" 
                                + separ[4] + "" 
                                + separ[4] + ""
                                + separ[4] + ""
                                + separ[4] + ""
                                + separ[4] + ""
        .
        /** 21/08/2013 V11.07 **/
        find first ibqics no-lock
             where ibqics.soc-cd = ibque.soc-cd 
               and ibqics.cdics = ibque.ics no-error.
        if available ibqics then do:
            if ibqics.nomics <> "" then cNomCreancier-OU = ibqics.nomics.   /*  version >= V11.07 */  
            assign
                cAdresseCreancier = ibqics.adr[1] 
                                  + separ[4] + ibqics.adr[2] 
                                  + separ[4] + ibqics.adr[3]
                                  + separ[4] + ibqics.cp
                                  + separ[4] + ibqics.ville
                                  + separ[4] + ibqics.libpays-cd
            .
        end.
        assign    /* Ajout SY le 24/07/2013 */
            LbDivPar-OU = cJournalBanque 
                        + "|" + string(iMandatBanque, "99999")
                        + "|" + ibque.iban
                        + "|" + ibque.bic
                        + "|" + cAdresseCreancier               /* Ajout SY le 06/09/2013 */
        .
    end.

end procedure.
