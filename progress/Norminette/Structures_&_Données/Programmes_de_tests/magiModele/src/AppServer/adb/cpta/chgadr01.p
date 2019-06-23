


//gga todo pour l'instant reprise de adb/cpta/chgadr01.p avec le minimum de modification  


/*ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª
∫                                                                           ∫
∫ Application      : A.D.B. Progress version graphique                      ∫
∫ Programme        : ChgAdr01.p                                             ∫
∫ Objet            : Interface de chargement d'une adresse d'un rìle        ∫
∫                                                                           ∫
∫---------------------------------------------------------------------------∫
∫                                                                           ∫
∫ Date de crÇation : 10/03/1997                                             ∫
∫ Auteur(s)        : CG                                                     ∫
∫ Dossier analyse  : .                                                      ∫
∫                                                                           ∫
∫---------------------------------------------------------------------------∫
∫                                                                           ∫
∫ Paramätres d'entrÇes  :                                                   ∫
∫                                                                           ∫
∫ Paramätres de sorties :                                                   ∫
∫                                                                           ∫
∫ Exemple d'appel       :                                                   ∫
∫                                                                           ∫
»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº


…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª
∫ Historique des modifications                                              ∫
∫------¬------------¬--------¬----------------------------------------------∫
∫  N¯  |    Date    | Auteur |                  Objet                       ∫
∫------≈------------≈--------≈----------------------------------------------∫
∫ 0001 | 18/03/1997 |   TM   | Normalisation                                ∫
∫ 0002 | 07/05/1997 |   SC   | Pour le Mandant, rechercher NoRol via INTNT  ∫
∫      |            |        | car dans ce cas NoRolUse-IN contient 0.      ∫
∫      |            |        | Changement de nom TpCttUse-IN => NoCttUse-IN.∫
∫ 0003 | 16/07/1997 |   SC   | Ajout du Code Pays en derniäre position.     ∫
∫ 0004 | 04/12/1997 |   BV   | Test si le role passÇ en paramätre a bien    ∫
∫      |            |        | un lien dans intnt avec le contrat passÇ     ∫
∫      |            |        | en paramätre, si le type de role est Çgal    ∫
∫      |            |        | Ö "00016".                                   ∫
∫ 0005 | 11/12/1997 |   BV   | Suppression des "-" dans l'adresse (lorsque  ∫
∫      |            |        | la civilitÇ, la particula ou le code voie de ∫
∫      |            |        | la rue ne sont pas renseignÇs).              ∫
∫ 0006 | 15/12/1997 |   BV   | Ajout de trois ÇlÇments dans la chaine       ∫
∫      |            |        | LbAdrUse-OU:                                 ∫
∫      |            |        | - CdCvtTie(H,F ou M),                        ∫
∫      |            |        | - LbCvtTie (CivilitÇ du tiers 1),            ∫
∫      |            |        | - CdCodTie (Code correspondant: tiers.cdcv1).∫
∫ 0007 | 16/12/1997 |   BV   | Dans le cas d'une indivision de type "femme",∫
∫      |            |        | foráage de LbCvtTie Ö "Madame" et de CdCodTie∫
∫      |            |        | Ö "1000600000".                              ∫
∫ 0008 | 05/03/1998 |   SC   | Passage du Nom formatÇ du Tiers2 et du Nom  ,∫
∫      |            |        | + PrÇnom du ReprÇsentant si existe...        ∫
∫ 0009 | 16/04/1998 |   SC   | Passage du Nom formatÇ du Tiers2 = ReprÇsen- ∫
∫      |            |        | tant si Personne Morale + Ajout zone C/O.    ∫
∫ 0010 | 28/04/1998 |   JC   | Ajout dans la chaine de caracteres retour de ∫
∫      |            |        | la date de resilation,de sortie ou de vente  ∫
∫ 0011 | 14/08/1998 |   JC   | Si tiers = mademoiselle CdCvtTie = "L "      ∫
∫ 0012 | 28/01/1999 |   LG   | Ajout noms tiers avec civilitÇ contractÇe    ∫
∫      |            |        |  pour lettres chäques banalisÇes.            ∫
∫ 0013 | 12/03/1999 |   LG   | Gestion de l'Çtat du tiers "00036" (membre du∫
∫      |            |        | conseil syndical)                            ∫
∫ 0014 | 16/03/1999 |   LG   | Changement du dÇlimiteur : plus @ mais       ∫
∫      |            |        | CHR(164) Ö cause de la possibilitÇ de saisir ∫
∫      |            |        | un email.                                    ∫
∫ 0015 | 15/04/1999 |   LG   | Si mandataire au niveau du copro. il faut    ∫
∫      |            |        | le forcer car prime sur le C/O.   envoyer son∫
∫      |            |        | adresse et non celle du copro mais seulement ∫
∫      |            |        | si Çtiquette.                                ∫
∫ 0016 | 20/08/1999 |   CE   | si pas mandataire au niveau du copro         ∫
∫      |            |        | prendre le C/O du copro                      ∫
∫ 0017 | 27/09/1999 |   LG   | Pb qd un copro. n'a pas du tout de lot ni de ∫
∫      |            |        | titre, il n'existe qu'en tant que role, la   ∫
∫      |            |        | date dtvensor = ?.                           ∫
∫ 0018 | 17/09/1999 |   LG   | GÇrer nouveau role "00034" syndicat de copro.∫
∫ 0019 | 03/08/2000 |   SY   | DEV223 : Ajout adresse de räglement pour les ∫
∫      |            |        | propriÇtaires ou les bÇnÇficiaires           ∫
∫      |            |        |                                              ∫
∫ 0020 | 29/08/00   |   FR   | recuperation cd C/O du copro dans l'entree 30∫
∫      |            |        | meme s'il a un mandaire - fiche 0900/0398    ∫
∫ 0021 | 03/10/2000 |   SY   | DEV223 : Correction gestion beneficiaires    ∫
∫ 0022 | 22/05/2001 |   SY   | Ajout suppression des blancs du code postal  ∫
∫ 0023 | 05/10/2001 |   SG   | Rajout du cas ou tproluse ="02001" afin      ∫
∫      |            |        | d'affecter la bonne adresse immeuble         ∫
∫ 0024 | 08/02/2002 |   SY   | Fiche 0202/0066 : correction formatage du    ∫
∫      |            |        | nom pour une sociÇtÇ ou association          ∫
∫ 0025 | 05/04/2002 |   JB   | Fiche 0501/0784 Edition Coindivisaires ajoute∫
∫ 0026 | 28/05/2002 |   SY   | Fiche 0402/0975 : le formatage nom+prÇnom    ∫
∫      |            |        | ne se limite pas aux sous-familles sociÇtÇ   ∫
∫      |            |        | et association mais concerne les familles    ∫
∫      |            |        | P.civile (09003) et P.morale (09004)         ∫
∫ 0027 | 03/06/2002 |   SY   | Fiche 0502/1163 : Correction recherche tel.  ∫
∫      |            |        | on envoyait le dernier et non le 1er trouvÇ  ∫
∫ 0028 | 27/10/2003 |   AF   | Ajout entry 27 de la TVA intracommunautaire  ∫
∫      |            |        | uniquement pour les roles                    ∫
∫ 0029 | 06/01/2004 |   SY   | Correction recherche TVA intracommunautaire  ∫
∫      |            |        |                                              ∫
∫ 0030 | 02/09/2004 |   DM   | 0604/0164 Rajout de l'email dans l'entry 2   ∫
∫      |            |        |           de NoTelTie                        ∫
∫ 0031 | 30/09/2004 |   SY   | 0904/0319 Ajout formatage court pour le      ∫
∫      |            |        | reprÇsentant                                 ∫
∫ 0032 | 10/10/2005 |   AF   | 0205/0300 Roles 00071 - Gerant               ∫ 
∫ 0033 | 17/02/2006 |   SY   | 0206/0223 Retour arriËre sur modif prÈcedente∫ 
∫      |            |        | il ne faut pas se servir du destinataire des ∫
∫      |            |        | AR des AG (ctrat.cddur) pour le C/O du       ∫
∫      |            |        | copropriÈtaire.                              ∫
| 0034 | 01/02/2007 |   SY   | 0106/0210 : Ajout etiquettes gÈrant ("EG")   |
|      |            |        | + Nlles zones mandataire et gÈrant           |
| 0035 | 07/09/2007 |   SY   | 0106/0210 : correction entry(19)             |
|      |            |        | LbNomCO (= C/O ou Mandataire ou GÈrant)      |
|      |            |        | et non pas C/O uniquement                    |
| 0036 | 07/12/2007 |   JR   | FIND FIRST et NON PAS FIND sur intnt depuis  |
|      |            |        | la gestion des indivisions successives. Un indivisaire|
|      |            |        | peut Ítre prÈsent plusieurs fois dans une indivision.|
| 0037 |  26/03/08  |   OF   | 1206/0220 Ajout Siret et NAF (Entrees 35/36) |
| 0038 |  12/08/08  |   OF   |0708/0169 Cas o˘ il y a 2 adresses principales|
| 0039 |  20/08/08  |  OF    |1206/0220 - suite fiche 0507/0195 les numÈros |
|      |            |        |de tel + email + fax sont gÈrÈs diffÈremment  |
| 0040 | 16/09/2008 |   SY   | 0608/0065 Gestion mandats 5 chiffres         |
| 0041 | 10/11/2008 |   SY   | 0908/0162 modification FrmTitLettre pour     |
|      |            |        | Titre si tiers.lbdiv2 vide (dev FOPOL)       |
| 0042 | 05/01/2010 |   DM   | 1209/0086 litie pour les couples             |
| 0043 | 16/03/2010 |   SY   | 0310/0065 DÈplacement DecodeTelephone apres  |
|      |            |        | recherche No Identifiant (NoRolUse)          |
| 0044 | 26/05/2010 |   NP   | 0510/0160 Pb avec litie pour les couples     |
| 0045 | 11/08/2010 |   NP   | 0810/0037 Pb litie multiple pour les couples |
| 0046 | 27/03/2013 |   OF   | 1209/0091 Mauvaise rÈcupÈration des emails   |
|      |            |        | + Ajout du mode d'envoi                      |
| 0047 | 20/07/2015 |   SY   | Modification index table telephones pour V12.3|
| 0048 | 22/02/2018 |   JPM  | #13031  champs passÈs en INT64               |
|      |            |        |                                              |
+---------------------------------------------------------------------------*/
 
/*--------------------------------------------------------------------------*
|  Chaine de sortie LbAdrUse-OU (sÈparateurs = CHR(164))                    |
|      01 : Nom complet tiers 1                                             |
|      02 : adresse ligne 1                                                 |
|      03 : adresse ligne 2                                                 |
|      04 : Code postal                                                     |
|      05 : Ville                                                           |
|      06 : Tel                                                             |
|      07 : email                                                           |
|      08 : Fax                                                             |
|      09 : nom du contact (tiers 4)                                        |
|      10 : (tel contact ?)                                                 |
|      11 : (tel contact ?)                                                 |
|      12 : (tel contact ?)                                                 |
|      13 : code Pays                                                       |
|      14 : code sexe tiers : H/HF/L/HL ...                                 |
|      15 : LibellÈ civilitÈ                                                |
|      16 : tiers.cdcv1 + tiers.cdcv2                                       |
|      17 : Nom complet tiers 2                                             |
|      18 : Nom prÈnom reprÈsentant une P.morale                            |
|      19 : LbNomCO (= C/O ou Mandataire ou GÈrant)                         |
|      20 : CdRolAct : A (actif)/V (vendeur)/R (rÈsiliÈ) / ? = sans objet   |
|      21 : date de fin                                                     |
|      22 : Nom tiers 1 formatÈ avec civilitÈ abrÈgÈe                       |
|      23 : Nom tiers 2 formatÈ avec civilitÈ abrÈgÈe                       |
|      24 : "1" si adresse de rËglement sinon "0"                           |
|      25 : adresse de reglement ligne 1                                    |
|      26 : adresse de reglement ligne 2                                    |
|      27 : Code postal adr de reglement                                    |
|      28 : Ville adr de reglement                                          |
|      29 : code pays adr de reglement                                      |
|      30 : cocopro = C/O                                                   |
|      31 : TVA intracommunautaire                                          |
|      32 : LbNomMan nom Mandataire (role 00014)                            |
|      33 : LbNomGer nom GÈrant (role 00071)                                |
|      34 : LbTitLet = Titre Lettre du role                                 |
|      35 : CdSiret  = NumÈro de Siret                                      |
|      36 : CdNAF    = Code NAF                                             |
|      37 : Portable (Ajout OF le 20/08/08)                                 |
|      38 : Mode d'envoi (Ajout OF le 27/03/13)                             |
|                                                                           |
|                                                                           |
*---------------------------------------------------------------------------*/


/* #s 'Section DEFINITION'
 €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 €€€ S e c t i o n  €€€€€€€€€€€€€€€€€  D E F I N I T I O N  €€€€€€€€€€€€€€€€€
 €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ */

/* ⁄-----------------ø
---¥  Fonctions      √--------------------------------------------------------
   ¿-----------------Ÿ */
FUNCTION FrmTitLettre RETURNS CHARACTER(NoTieUse AS INTEGER) FORWARD.


/* ⁄-----------------ø
---¥  Paramätres     √--------------------------------------------------------
   ¿-----------------Ÿ */

DEFINE INPUT PARAMETER      CdLngSes    LIKE sys_lb.cdlng NO-UNDO.
DEFINE INPUT PARAMETER      CdFndUse-IN AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER      CdSocUse-IN AS INTEGER  NO-UNDO.
DEFINE INPUT PARAMETER      NoCttUse-IN AS INTEGER  NO-UNDO.
DEFINE INPUT PARAMETER      TpRolUse-IN AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER      NoRolUse-IN AS INT64    NO-UNDO.

DEFINE OUTPUT PARAMETER     CdRetUse-OU AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER     LbAdrUse-OU AS CHARACTER    NO-UNDO.

/* ⁄-----------------ø
---¥ Var Globales    √--------------------------------------------------------
   ¿-----------------Ÿ */

/* ⁄-----------------ø
---¥  Variables      √--------------------------------------------------------
   ¿-----------------Ÿ */

    DEFINE VARIABLE NmTieCpl        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE NmTieCrt        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE NmCntCpl        AS CHARACTER    NO-UNDO.
    
    DEFINE VARIABLE LbAdr001        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbAdr002        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbCodPos        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbNomVil        AS CHARACTER    NO-UNDO.
    
    DEFINE VARIABLE LbNumVoi        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE CdNatVoi        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE CdCodVoi        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE CdCodPay        AS CHARACTER    NO-UNDO.
    
    DEFINE VARIABLE NoTelTie        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE NoTelCnt        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE NoRolUse        AS INT64        NO-UNDO.
    
    DEFINE VARIABLE CdCvtTie        AS CHARACTER    FORMAT "X(2)"   NO-UNDO.
    DEFINE VARIABLE LbCvtTie        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE CdCodTie        AS CHARACTER    FORMAT "X(10)"  NO-UNDO.
    
    DEFINE VARIABLE CdRolAct        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE DtVenSor        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE DtDatRee        AS DATE         NO-UNDO.
    DEFINE VARIABLE NbDenOld        AS INTEGER      NO-UNDO.
    DEFINE VARIABLE NbLotUse        AS INTEGER      NO-UNDO.
    DEFINE VARIABLE FgRolAct        AS LOGICAL  NO-UNDO.
    
    DEFINE VARIABLE LbNomTi2        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE NmTi2Crt        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbNomRep        AS CHARACTER    NO-UNDO.    
    DEFINE VARIABLE LbNomCO         AS CHARACTER    NO-UNDO.    
    DEFINE VARIABLE LbNomMan        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbNomGer        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbTitLet        AS CHARACTER    NO-UNDO.
    
    DEFINE VARIABLE LbParLng-OU AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbParCrt-OU AS CHARACTER    NO-UNDO.
        
    DEFINE VARIABLE FgAdrReg        AS LOGICAL  INIT NO NO-UNDO.
    DEFINE VARIABLE LbAd1Reg        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbAd2Reg        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbCPoReg        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LbVilReg        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE CdPayReg        AS CHARACTER    NO-UNDO.
    
    DEFINE VARIABLE cocopro         AS CHARACTER  NO-UNDO. /**fr le 28/09/00**/
    DEFINE VARIABLE CdTvaInt        AS CHARACTER  NO-UNDO. /**fr le 28/09/00**/
    DEFINE VARIABLE CdSiret         AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE CdNAF           AS CHARACTER  NO-UNDO.
    
    DEFINE VARIABLE TpRolCab        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE NoRolCab        AS INTEGER  NO-UNDO.
    DEFINE VARIABLE TpRolUse        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE TpMdtUse        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE FgAdrCab        AS LOGICAL  INIT NO NO-UNDO.
    
    DEFINE VARIABLE TpRolTmp        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE NoPorTie        AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE CdModEnv        LIKE tiers.tpmod NO-UNDO. /**Ajout OF le 27/03/13**/

    DEFINE VARIABLE clNom2 LIKE tiers.lnom2. /* DM 1209/0086 */
    DEFINE VARIABLE clPre2 LIKE tiers.lpre2. /* DM 1209/0086 */
    DEFINE VARIABLE ccdcv2 LIKE tiers.cdcv2. /* DM 1209/0086 */
    DEFINE VARIABLE ccdpr2 LIKE tiers.cdpr2. /* DM 1209/0086 */
    DEFINE VARIABLE iNum   AS INT.           /* DM 1209/0086 */
    
    DEFINE BUFFER bintnt FOR intnt.
    DEFINE BUFFER btiers FOR tiers.



/* #s 'Section MAIN BLOCK'
 €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 €€€ S e c t i o n  €€€€€€€€€€€€€€€€€  M A I N   B L O C K  €€€€€€€€€€€€€€€€€
 €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ */
 
    ASSIGN
    CdRetUse-OU     = "000"
    LbAdrUse-OU     = ""
    NoTelTie        = CHR(164) + CHR(164)
    NoTelCnt        = CHR(164) + CHR(164) 
    NoRolUse        = NoRolUse-IN.


/*RUN DecodeTelephone.*/    /* Modif SY la 16/03/2010 : dÈplacÈ car NoRolUse-IN ‡ 0 pour mandant...*/

/*-----------------------------------------------ø
| Sort l'adresse du service                     |
¿-----------------------------------------------*/
IF TpRolUse-IN = "01049" THEN DO:
            
    CASE CdFndUse-IN :
        WHEN "G" THEN
            ASSIGN 
            NoRolCab = 1
            TpRolCab = "00014"
            TpRolUse = "00022"
            TpMdtUse = "01030".
        WHEN "C" THEN
            ASSIGN 
            NoRolCab = 1
            TpRolCab = "00027"
            TpRolUse = "00034"
            TpMdtUse = "01003".
    END CASE.
    
    /*--> Recherche de l'objet du contrat => nom du service */
    FIND ctrat  WHERE ctrat.tpcon = TpRolUse-IN
                AND   ctrat.nocon = NoRolUse-IN
                NO-LOCK NO-ERROR.
                
    IF AVAILABLE ctrat THEN
    DO:
        NmTieCpl = ctrat.noree.
        
        FIND FIRST ladrs WHERE ladrs.tpidt = TpRolUse-IN
                         AND   ladrs.noidt = NoRolUse-IN
                   NO-LOCK NO-ERROR.
                   
        IF AVAILABLE ladrs THEN 
        DO:
            FIND FIRST adres WHERE adres.noadr =ladrs.noadr 
                             NO-LOCK NO-ERROR.
                             
            IF AVAILABLE adres THEN 
            DO:
                ASSIGN
                    LbCodPos    = adres.cdpos
                    LbNomVil    = adres.lbvil
                    LbAdr002    = adres.cpvoi
                    CdCodPay    = adres.cdpay
                .
                RUN DecodeSys_pr ("NTVOI", adres.ntvoi, OUTPUT CdNatVoi).
            END.
    
            RUN DecodeSys_pr ("CDADR", ladrs.cdadr, OUTPUT CdCodVoi).
                        
            IF CdCodVoi = "-" THEN 
                ASSIGN CdCodVoi = "".
                       
            /*RUN DecodeTelephone (ladrs.cdte1, ladrs.note1, INPUT-OUTPUT NoTelTie).
            RUN DecodeTelephone (ladrs.cdte2, ladrs.note2, INPUT-OUTPUT NoTelTie).
            RUN DecodeTelephone (ladrs.cdte3, ladrs.note3, INPUT-OUTPUT NoTelTie).*/
    
            ASSIGN
                LbNumVoi    = (IF ladrs.novoi <> "0" THEN ladrs.novoi + " " ELSE "")
                LbAdr001    = LbNumVoi + TRIM (TRIM (CdCodVoi + " " + CdNatVoi) + " " + adres.lbvoi)
            .
        END.
    END.                   
    ELSE FgAdrCab = TRUE.

    /* recuperation identite et adresse cabinet */                 
    IF FgAdrCab = TRUE THEN
    DO:
        FIND roles WHERE roles.tprol = TpRolCab
                AND roles.norol = NoRolCab
                    NO-LOCK NO-ERROR.
                        
        IF AVAILABLE roles THEN 
        DO:
            FIND btiers WHERE btiers.notie = roles.notie
                        NO-LOCK NO-ERROR.
    
            IF AVAILABLE btiers THEN
            DO:
                RUN DecodeNom (btiers.cdfat, btiers.cdcv1, btiers.cdpr1, btiers.lnom1, btiers.lpre1, OUTPUT NmTieCpl).
                LbTitLet = FRMTITLETTRE(btiers.notie).
            END.
            ELSE
            DO:  
                /* Tiers inexistant */
                ASSIGN CdRetUse-OU = "002".
                RETURN.
            END.        
        END.                
        ELSE
        DO:
           /* role inexistant */
           ASSIGN CdRetUse-OU = "001".  
           RETURN.
        END.       

        FIND FIRST ladrs WHERE ladrs.tpidt = TpRolCab
                         AND   ladrs.noidt = NoRolCab
                   NO-LOCK NO-ERROR.
                   
        IF AVAILABLE ladrs THEN 
        DO:
            FIND FIRST adres WHERE adres.noadr =ladrs.noadr 
                             NO-LOCK NO-ERROR.
                             
            IF AVAILABLE adres THEN 
            DO:
                ASSIGN
                    LbCodPos    = adres.cdpos
                    LbNomVil    = adres.lbvil
                    LbAdr002    = adres.cpvoi
                    CdCodPay    = adres.cdpay
                .
                RUN DecodeSys_pr ("NTVOI", adres.ntvoi, OUTPUT CdNatVoi).
            END.
    
            RUN DecodeSys_pr ("CDADR", ladrs.cdadr, OUTPUT CdCodVoi).
                        
            IF CdCodVoi = "-" THEN 
                ASSIGN CdCodVoi = "".
                       
            /*RUN DecodeTelephone (ladrs.cdte1, ladrs.note1, INPUT-OUTPUT NoTelTie).
            RUN DecodeTelephone (ladrs.cdte2, ladrs.note2, INPUT-OUTPUT NoTelTie).
            RUN DecodeTelephone (ladrs.cdte3, ladrs.note3, INPUT-OUTPUT NoTelTie).*/
    
            ASSIGN
                LbNumVoi    = (IF ladrs.novoi <> "0" THEN ladrs.novoi + " " ELSE "")
                LbAdr001    = LbNumVoi + TRIM (TRIM (CdCodVoi + " " + CdNatVoi) + " " + adres.lbvoi)
            .
        END.
    END.                 
    
    LbAdrUse-OU = TRIM (NmTieCpl)                   + CHR(164) +
                  TRIM (LbAdr001)                   + CHR(164) +
                  TRIM (LbAdr002)                   + CHR(164) +
                  TRIM (LbCodPos)                   + CHR(164) +
                  TRIM (LbNomVil)                   + CHR(164) +
                  NoTelTie                          + CHR(164) +
                  TRIM (NmCntCpl)                   + CHR(164) +
                  NoTelCnt                          + CHR(164) +
                  CdCodPay                          + CHR(164) +
                  CdCvtTie                          + CHR(164) +
                  LbCvtTie                          + CHR(164) +
                  CdCodTie                          + CHR(164) +
                  LbNomTi2                          + CHR(164) +
                  LbNomRep                          + CHR(164) +
                  LbNomCO                           + CHR(164) +
                  CdRolAct                          + CHR(164) +
                  DtVenSor                          + CHR(164) +
                  NmTieCrt                          + CHR(164) +
                  NmTi2Crt                          + CHR(164) +
                  (IF FgAdrReg THEN "1" ELSE "0")   + CHR(164) +
                  TRIM (LbAd1Reg)                   + CHR(164) +
                  TRIM (LbAd2Reg)                   + CHR(164) +
                  LbCPoReg                          + CHR(164) +
                  TRIM (LbVilReg)                   + CHR(164) +
                  CdPayReg                          + CHR(164) +
                  cocopro                           + CHR(164) +
                  CdTvaInt                          + CHR(164) +
                  LbNomMan                          + CHR(164) +
                  LbNomGer                          + CHR(164) +
                  LbTitLet                          + CHR(164) +
                  CdSiret                           + CHR(164) +
                  CdNAF                             + CHR(164) +
                  NoPorTie                          + CHR(164) +
                  CdModEnv /**Ajout OF le 27/03/13**/
                  .
    RETURN.             
END. /* IF TpRolUse-IN = "01049" */


 /*-----------------------------------------------ø
 | Sort l'adresse de l'immeuble considÈrÈ        |
 ¿-----------------------------------------------*/

IF TpRolUse-IN = "02001" THEN DO:
    FIND FIRST ladrs 
        WHERE ladrs.tpidt ="02001"
                AND   ladrs.noidt = INT(CdFndUse-IN)
        NO-LOCK NO-ERROR.
    IF AVAILABLE ladrs THEN DO:
                 
        FIND FIRST adres WHERE adres.noadr =ladrs.noadr NO-LOCK NO-ERROR.
        IF AVAILABLE adres THEN DO:
            ASSIGN
                LbCodPos    = adres.cdpos
                LbNomVil    = adres.lbvil
                LbAdr002    = adres.cpvoi
                CdCodPay    = adres.cdpay
            .
            RUN DecodeSys_pr ("NTVOI", adres.ntvoi, OUTPUT CdNatVoi).
        END.

        RUN DecodeSys_pr ("CDADR", ladrs.cdadr, OUTPUT CdCodVoi).
                    
        IF CdCodVoi = "-" THEN 
            ASSIGN CdCodVoi = "".
                   
        /*RUN DecodeTelephone (ladrs.cdte1, ladrs.note1, INPUT-OUTPUT NoTelTie).
        RUN DecodeTelephone (ladrs.cdte2, ladrs.note2, INPUT-OUTPUT NoTelTie).
        RUN DecodeTelephone (ladrs.cdte3, ladrs.note3, INPUT-OUTPUT NoTelTie).*/

        ASSIGN
            LbNumVoi    = (IF ladrs.novoi <> "0" THEN ladrs.novoi + " " ELSE "")
            LbAdr001    = LbNumVoi + TRIM (TRIM (CdCodVoi + " " + CdNatVoi) + " " + adres.lbvoi)
        .
    END.

    LbAdrUse-OU = TRIM (NmTieCpl)                   + CHR(164) +
                  TRIM (LbAdr001)                   + CHR(164) +
                  TRIM (LbAdr002)                   + CHR(164) +
                  TRIM (LbCodPos)                   + CHR(164) +
                  TRIM (LbNomVil)                   + CHR(164) +
                  NoTelTie                          + CHR(164) +
                  TRIM(NmCntCpl)                    + CHR(164) +
                  NoTelCnt                          + CHR(164) +
                  CdCodPay                          + CHR(164) +
                  CdCvtTie                          + CHR(164) +
                  LbCvtTie                          + CHR(164) +
                  CdCodTie                          + CHR(164) +
                  LbNomTi2                          + CHR(164) +
                  LbNomRep                          + CHR(164) +
                  LbNomCO                           + CHR(164) +
                  CdRolAct                          + CHR(164) +
                  DtVenSor                          + CHR(164) +
                  NmTieCrt                          + CHR(164) +
                  NmTi2Crt                          + CHR(164) +
                  (IF FgAdrReg THEN "1" ELSE "0")   + CHR(164) +
                  TRIM (LbAd1Reg)                   + CHR(164) +
                  TRIM (LbAd2Reg)                   + CHR(164) +
                  LbCPoReg                          + CHR(164) +
                  TRIM (LbVilReg)                   + CHR(164) +
                  CdPayReg                          + CHR(164) +
                  cocopro                           + CHR(164) +
                  CdTvaInt                          + CHR(164) +
                  LbNomMan                          + CHR(164) +
                  LbNomGer                          + CHR(164) +
                  LbTitLet                          + CHR(164) +
                  CdSiret                           + CHR(164) +
                  CdNAF                             + CHR(164) +                    
                  NoPorTie                          + CHR(164) +
                  CdModEnv /**Ajout OF le 27/03/13**/
                  .
     
END. /* IF TpRolUse-IN = "02001" */
ELSE DO:
    /*-----------------------------------------------ø
     | Tester le cas particulier du Mandant (00022): |
     | Dans ce cas NoRolUse-IN = 0 donc aller le     |
     | rechercher dans INTNT (lien unique).          |
     ¿-----------------------------------------------*/
    IF TpRolUse-IN = "00022" THEN DO:

        /*-----------------------------------------------ø
         | RÇcupÇration du No de Rìle dans INTNT.        |
         ¿-----------------------------------------------*/
        FIND FIRST /** JR 07/12/2007 **/ intnt
            WHERE   intnt.tpidt = TpRolUse-IN
            AND intnt.tpcon = "01030"
            AND     intnt.nocon = NoCttUse-IN
            NO-LOCK NO-ERROR.
    
        IF NOT AVAILABLE INTNT THEN DO:
    
            /* Role inexistant */
            ASSIGN CdRetUse-OU = "001". 
            RETURN.
    
        END.
        ASSIGN NoRolUse = intnt.noidt.
    
    END.    /* Fin Test Cas particulier Mandant. */


    /*-----------------------------------------------ø
     | Si TpRolUse-IN = "00016", test si le role a   |
     | un lien avec le contrat dans intnt, sinon     |
     | recherche avec type de role = "00022".        |
     ¿-----------------------------------------------*/
    IF TpRolUse-IN = "00016" AND NOT CdFndUse-IN = "INDIVISAIRE" THEN DO:   /* JBR */
        FIND FIRST /** JR 07/12/2007 **/ intnt WHERE intnt.TpCon = "01030" 
               AND   intnt.NoCon = NoCttUse-IN
               AND   intnt.TpIdt = TpRolUse-IN
               AND   intnt.NoIdt = NoRolUse-IN
        NO-LOCK NO-ERROR.
    
        IF AVAILABLE intnt THEN DO:
            ASSIGN NoRolUse = intnt.NoIdt
                   .
        END. 
    
        ELSE DO:
            FIND FIRST /** JR 07/12/2007 **/ intnt WHERE intnt.TpCon = "01030" 
                   AND   intnt.NoCon = NoCttUse-IN
                   AND   intnt.TpIdt = "00022"
                   AND   intnt.NoIdt = NoRolUse-IN
            NO-LOCK NO-ERROR.
    
            IF AVAILABLE intnt THEN DO:
                ASSIGN NoRolUse    = intnt.NoIdt
                       TpRolUse-IN = intnt.TpIdt
                       . 
            END. 
    
            ELSE DO:
    
                /* role inexistant */
                ASSIGN CdRetUse-OU = "001".  
                RETURN.
    
            END.
    
        END. /* fin ELSE AVAILABLE intnt */
            
    END. /* fin IF TpRolUse-IN = "00016" */


    FIND roles
        WHERE roles.tprol = TpRolUse-IN
           AND   roles.norol = NoRolUse
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE roles THEN DO:
    
        /* Role inexistant */
        ASSIGN CdRetUse-OU= "001".
        RETURN. 
    END.
    /* Modif Sy le 16/03/2010 */
    RUN DecodeTelephone.
    
    FIND tiers
        WHERE tiers.notie = roles.notie
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE tiers THEN DO :
        /* Tiers inexistant */
        ASSIGN CdRetUse-OU = "002".
        RETURN.
    END.
    
    CdModEnv = tiers.tpmod. /**Ajout OF le 27/03/13**/
   
    /*--> Recherche de la TVA intracommunautaire */
    FIND FIRST ctanx    WHERE ctanx.tpcon = "01047"
                AND ctanx.tprol = "99999"
                AND ctanx.norol = tiers.notie
                NO-LOCK NO-ERROR.
    IF AVAILABLE ctanx THEN 
        ASSIGN
            CdTvaInt = ctanx.liexe
            /**Ajout OF le 26/03/08**/
            CdSiret = STRING(ctanx.nosir)
            CdNAF = ctanx.cdape
            /** **/
            .
    
    RUN DecodeNom (tiers.cdfat,tiers.cdcv1, tiers.cdpr1, tiers.lnom1, tiers.lpre1, OUTPUT NmTieCpl).
    LbTitLet = FRMTITLETTRE(tiers.notie).
    
    /* Formatage du tiers 1 avec une civilitÇ courte pour les cheques banalisÇs*/
    RUN ForNmTie  (tiers.cdfat,tiers.cdcv1, tiers.cdpr1, tiers.lnom1, tiers.lpre1, OUTPUT NmTieCrt).

    IF tiers.fgct4 = TRUE THEN DO:
        RUN DecodeNom ("", tiers.cdcv4, tiers.cdpr4, tiers.lnom4, tiers.lpre4, OUTPUT NmCntCpl).
    END.

    FIND FIRST ladrs   /**Ajout du FIRST par OF le 12/08/08**/
        WHERE ladrs.tpidt = TpRolUse-IN
            AND ladrs.noidt = NoRolUse
            AND ladrs.tpadr = "00001"
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE ladrs THEN DO :

        /* Lien adresse inexistant */
        ASSIGN CdRetUse-OU = "003".
        RETURN.

    END.
    ELSE DO:

        FIND adres
            WHERE adres.noadr = ladrs.noadr
            NO-LOCK NO-ERROR.

        IF NOT AVAILABLE adres THEN DO:

            /* Adresse inexistante */
            ASSIGN CdRetUse-OU = "004".  
            RETURN.
            
        END.
        ELSE DO:

            RUN DecodeSys_pr ("CDADR", ladrs.cdadr, OUTPUT CdCodVoi).
            IF CdCodVoi = "-" THEN 
                ASSIGN CdCodVoi = "".
            RUN DecodeSys_pr ("NTVOI", adres.ntvoi, OUTPUT CdNatVoi).

            /*RUN DecodeTelephone (ladrs.cdte1, ladrs.note1, INPUT-OUTPUT NoTelTie).
            RUN DecodeTelephone (ladrs.cdte2, ladrs.note2, INPUT-OUTPUT NoTelTie).
            RUN DecodeTelephone (ladrs.cdte3, ladrs.note3, INPUT-OUTPUT NoTelTie).*/

            ASSIGN
                LbNumVoi    = (IF ladrs.novoi <> "0" THEN ladrs.novoi + " " ELSE "")
                LbCodPos    = adres.cdpos
                LbNomVil    = adres.lbvil
                LbAdr001    = LbNumVoi + TRIM (TRIM (CdCodVoi + " " + CdNatVoi) + " " + adres.lbvoi)
                LbAdr002    = adres.cpvoi
                CdCodPay    = adres.cdpay
                .

        END. /* fin ELSE NOT AVAILABLE adres */
    END. /* fin ELSE NOT AVAILABLE ladrs */

    /*-----------------------------------------------ø
     | Tester la Famille du Tiers.                   |
     ¿-----------------------------------------------*/
    CASE tiers.CdFat:

        /*-----------------------------------------------ø
         | Cas d'un individu.                            |
         ¿-----------------------------------------------*/
        WHEN "09001" THEN DO:

            RUN DecodeSys_Pg (INPUT "O_CVT", INPUT tiers.cdcv1, OUTPUT LbParLng-OU).  
            CASE tiers.cdsx1:

                WHEN "00001" THEN ASSIGN CdCvtTie = "H ".
                WHEN "00002" THEN
                   CdCvtTie = IF tiers.cdcv1 = "10006" THEN "F " ELSE "L ".
                OTHERWISE ASSIGN CdCvtTie = "  ".

            END CASE.

            /*-----------------------------------------------ø
             |Si l'individu est de type "indivision" et      |
             | "femme",on le force Ö "Madame".               |
             ¿-----------------------------------------------*/
            IF CdCvtTie = "F " AND tiers.cdcv1 <> "10005" AND tiers.cdcv1 <> "10006" THEN DO:
            RUN DecodeSys_Pg (INPUT "O_CVT", INPUT "10006", OUTPUT LbParLng-OU).  
                ASSIGN LbCvtTie = LbParLng-OU 
                       CdCodTie = "100060000".
            END.

            ELSE DO:
                ASSIGN LbCvtTie = LbParLng-OU 
                       CdCodTie = STRING(tiers.cdcv1, "99999") + "00000".   
            END.

        END.    /* Fin Cas individu. */

        /*-----------------------------------------------ø
         | Cas d'un Couple.                              |
         ¿-----------------------------------------------*/
        WHEN "09002" THEN DO:

            RUN DecodeSys_Pg (INPUT "O_CVT", INPUT tiers.cdcv1, OUTPUT LbParLng-OU).  
            CASE tiers.cdsx1:

                WHEN "00001" THEN ASSIGN CdCvtTie = "H".
                WHEN "00002" THEN
                   CdCvtTie = IF tiers.cdcv1 = "10006" THEN "F" ELSE "L".
                OTHERWISE ASSIGN CdCvtTie = " ".

            END CASE.

            CASE tiers.cdsx2:

                WHEN "00001" THEN ASSIGN CdCvtTie = CdCvtTie + "H".
                WHEN "00002" THEN
                   CdCvtTie = CdCvtTie 
                                                + (IF tiers.cdcv2 = "10006" THEN "F" ELSE "L").
                OTHERWISE ASSIGN CdCvtTie = CdCvtTie + " ".

            END CASE.

            ASSIGN LbCvtTie = LbParLng-OU 
                   CdCodTie = STRING(tiers.cdcv1, "99999") + tiers.cdcv2.   

            /*-----------------------------------------------ø
             | DÇcodage du Nom du Tiers 2.                   |
             ¿----------------------------------------------*/
             
            /* DM 1209/0086 gÈrÈ avec la table litie
*            
*           RUN DecodeNom ("",tiers.cdcv2, tiers.cdpr2, tiers.lnom2, tiers.lpre2, OUTPUT LbNomTi2).
*           /* Formatage du tiers 2 avec une civilitÇ courte pour les cheques banalisÇs*/
*           RUN ForNmTie  ("",tiers.cdcv2, tiers.cdpr2, tiers.lnom2, tiers.lpre2, OUTPUT NmTi2Crt). */
            
            iNum = 0.
            clNom2 = "".
            clPre2 = "".
            ccdcv2 = "".
            ccdpr2 = "".
            
            /**** NP 0810/0037
            BCL : FOR EACH litie
                    WHERE litie.notie = tiers.notie 
                    BY litie.nopos :    /* NP 0510/0160 */
                
                iNum = iNum + 1.
                
                IF iNum = 2 THEN DO : /* Conjoint */
                    FIND btiers 
                    WHERE btiers.notie = litie.noind.
                    IF AVAILABLE btiers THEN DO :
                        clNom2 = btiers.lnom1.
                        clPre2 = btiers.lpre1.
                        ccdcv2 = btiers.cdcv1.
                        ccdpr2 = btiers.cdpr1.
                        LEAVE BCL.
                    END.
                END.                    
            END.****/
            FIND LAST litie
                WHERE litie.notie = tiers.notie
                  AND litie.nopos = 2 NO-LOCK NO-ERROR.
            IF AVAILABLE litie THEN
            DO:
                FIND btiers 
                    WHERE btiers.notie = litie.noind.
                IF AVAILABLE btiers THEN
                    ASSIGN
                        clNom2 = btiers.lnom1
                        clPre2 = btiers.lpre1
                        ccdcv2 = btiers.cdcv1
                        ccdpr2 = btiers.cdpr1
                        .
            END.

            IF clNom2 + clPre2 = "" OR clNom2 + clPre2 = "" /* pas trouvÈ de litie ou litie non renseignÈ */
            THEN DO :
                clNom2 = tiers.lnom2.
                clPre2 = tiers.lpre2.
                ccdcv2 = tiers.cdcv2.
                ccdpr2 = tiers.cdpr2.
            END.
            
            RUN DecodeNom ("",ccdcv2, ccdpr2, clnom2, clpre2, OUTPUT LbNomTi2).
            /* Formatage du tiers 2 avec une civilitÇ courte pour les cheques banalisÇs*/
            RUN ForNmTie  ("",ccdcv2, ccdpr2, clnom2, clpre2, OUTPUT NmTi2Crt).
            
            /* FIN DM */

        END.    /* Fin Cas Couple. */

        /*-----------------------------------------------ø
         | Autres Cas que Individu ou Couple.            |
         ¿-----------------------------------------------*/
        OTHERWISE DO:

            RUN DecodeSys_Pg (INPUT "O_CVT", INPUT tiers.cdcv1, OUTPUT LbParLng-OU).  
            ASSIGN CdCvtTie = "M "
                   LbCvtTie =LbParLng-OU 
                   CdCodTie = STRING(tiers.cdcv1, "99999") + "00000". 

            /*-----------------------------------------------ø
             | Si personne morale, passer le rep. a la Compta|
             ¿-----------------------------------------------*/
            ASSIGN LbNomRep = TRIM(tiers.LNom2 + " " + tiers.LPre2).

            /*-----------------------------------------------ø
             | DÇcodage du Nom du Tiers 2 = ReprÇsentant.    |
             ¿-----------------------------------------------*/
            RUN DecodeNom ("",tiers.cdcv2, tiers.cdpr2, tiers.lnom2, tiers.lpre2, OUTPUT LbNomTi2).
            /* Formatage du tiers 2 avec une civilitÇ courte pour les cheques banalisÇs*/
            RUN ForNmTie  ("",tiers.cdcv2, tiers.cdpr2, tiers.lnom2, tiers.lpre2, OUTPUT NmTi2Crt).

        END.    /* Fin Cas Personne Morale et Civile. */

    END CASE. /* fin CASE sur Famille du Tiers. */


    /*-----------------------------------------------ø
     | Quelque soit la Famille du Tiers, s'il y a un |
     | C/O, le passer Ö la Compta (Nom FormatÇ).     |
     ¿-----------------------------------------------*/
    IF tiers.FgCo3 THEN DO:
        RUN DecodeNom ("", tiers.cdcv3, tiers.cdpr3, tiers.lnom3, tiers.lpre3, OUTPUT LbNomCO).
        cocopro = LbNomCO. /**fr le 28/09/00**/
    END.


    /*----------------------------------------------------*/
    /*-- Cas Role COPROPRIETAIRE                        --*/
    /*-- On recherche d'abord le Mandataire (00014)     --*/
    /*-- sinon le gÈrant (00071)                        --*/
    /*----------------------------------------------------*/
    IF TpRolUse-In = "00008" THEN DO:
        FIND intnt WHERE intnt.tpcon = "01004"
                AND intnt.NoCon = INTEGER(STRING(NoCttUse-IN, "99999") + STRING(NoRolUse, "99999"))
                AND intnt.tpidt = TpRolUse-IN 
                AND intnt.noidt = NoRolUse
        NO-LOCK NO-ERROR.
                   
        IF AVAILABLE intnt THEN DO:
            /*--> Recherche Mandataire */                           
            FIND bintnt WHERE bintnt.tpcon = "01004"
                AND bintnt.nocon = intnt.nocon
                AND bintnt.tpidt = "00014"
            NO-LOCK NO-ERROR.

            IF AVAILABLE bintnt THEN DO:
                FIND roles WHERE roles.tprol = bintnt.tpidt
                         AND roles.norol = bintnt.noidt
                NO-LOCK NO-ERROR.
                
                IF AVAILABLE roles THEN DO:
                    FIND btiers WHERE btiers.notie = roles.notie
                    NO-LOCK NO-ERROR.
                    IF AVAILABLE btiers THEN
                        /*-----------------------------------------------ø
                         | DÇcodage du Nom du Mandataire en copro.       |
                         ¿-----------------------------------------------*/
                        RUN DecodeNom (btiers.cdfat, btiers.cdcv1, btiers.cdpr1, btiers.lnom1, btiers.lpre1, OUTPUT LbNomMan).
                        /* Modif SY le 07/09/2007 */
                        IF LbNomCO = "" THEN LbNomCO = LbNomMan.
                    
                    /*-----------------------------------------------ø
                     | ADRESSE MANDATAIRE SI ce sont des Etiquettes. |
                     ¿-----------------------------------------------*/
                    IF CdFndUse-IN = "E" THEN DO:
                        LbNomCO = LbNomMan.
                        FIND ladrs
                            WHERE ladrs.tpidt = roles.tprol 
                            AND ladrs.noidt = Roles.norol
                            AND ladrs.tpadr = "00001"
                        NO-LOCK NO-ERROR.
                        IF NOT AVAILABLE ladrs THEN DO :
                            /* Lien adresse inexistant */
                            ASSIGN CdRetUse-OU = "003".
                            RETURN.
                        END.
                        ELSE DO:
                            FIND adres
                                WHERE adres.noadr = ladrs.noadr
                                NO-LOCK NO-ERROR.           
                            IF NOT AVAILABLE adres THEN DO:
                                /* Adresse inexistante */
                                ASSIGN CdRetUse-OU = "004".  
                                RETURN.                             
                            END.                        
                            ELSE DO:
                                RUN DecodeSys_pr ("CDADR", ladrs.cdadr, OUTPUT CdCodVoi).
                                IF CdCodVoi = "-" THEN 
                                    ASSIGN CdCodVoi = "".
                                RUN DecodeSys_pr ("NTVOI", adres.ntvoi, OUTPUT CdNatVoi).

                                /*RUN DecodeTelephone (ladrs.cdte1, ladrs.note1, INPUT-OUTPUT NoTelTie).
                                RUN DecodeTelephone (ladrs.cdte2, ladrs.note2, INPUT-OUTPUT NoTelTie).
                                RUN DecodeTelephone (ladrs.cdte3, ladrs.note3, INPUT-OUTPUT NoTelTie).*/

                                ASSIGN
                                    LbNumVoi    = (IF ladrs.novoi <> "0" THEN ladrs.novoi + " " ELSE "")
                                    LbCodPos    = adres.cdpos
                                    LbNomVil    = adres.lbvil
                                    LbAdr001    = LbNumVoi + TRIM (TRIM (CdCodVoi + " " + CdNatVoi) + " " + adres.lbvoi)
                                    LbAdr002    = adres.cpvoi
                                    CdCodPay    = adres.cdpay
                                .

                            END. /* fin ELSE NOT AVAILABLE adres */
                        END.
                    END.  
                END.
            END.    /*--> Fin Recherche Mandataire */  
            
            /*--> Recherche GÈrant */                           
            FIND bintnt WHERE bintnt.tpcon = "01004"
                AND bintnt.nocon = intnt.nocon
                AND bintnt.tpidt = "00071"
            NO-LOCK NO-ERROR.

            IF AVAILABLE bintnt THEN DO:
                FIND roles WHERE roles.tprol = bintnt.tpidt
                         AND roles.norol = bintnt.noidt
                NO-LOCK NO-ERROR.
                
                IF AVAILABLE roles THEN DO:
                    FIND btiers WHERE btiers.notie = roles.notie
                    NO-LOCK NO-ERROR.
                    IF AVAILABLE btiers THEN
                        /*-----------------------------------------------ø
                         | DÇcodage du Nom du GÈrant en copro.          |
                         ¿-----------------------------------------------*/
                        RUN DecodeNom (btiers.cdfat, btiers.cdcv1, btiers.cdpr1, btiers.lnom1, btiers.lpre1, OUTPUT LbNomGer).
                        /* Modif SY le 07/09/2007 */
                        IF LbNomCO = "" THEN LbNomCO = LbNomGer.
                    
                    /*-----------------------------------------------ø
                     | ADRESSE GÈrant SI ce sont des Etiquettes "GÈrant" |
                     ¿-----------------------------------------------*/
                    IF CdFndUse-IN = "EG" THEN DO:
                        LbNomCO = LbNomGer.
                        FIND ladrs
                            WHERE ladrs.tpidt = roles.tprol 
                            AND ladrs.noidt = Roles.norol
                            AND ladrs.tpadr = "00001"
                        NO-LOCK NO-ERROR.
                        IF NOT AVAILABLE ladrs THEN DO :
                            /* Lien adresse inexistant */
                            ASSIGN CdRetUse-OU = "003".
                            RETURN.
                        END.
                        ELSE DO:
                            FIND adres
                                WHERE adres.noadr = ladrs.noadr
                                NO-LOCK NO-ERROR.           
                            IF NOT AVAILABLE adres THEN DO:
                                /* Adresse inexistante */
                                ASSIGN CdRetUse-OU = "004".  
                                RETURN.                             
                            END.                        
                            ELSE DO:
                                RUN DecodeSys_pr ("CDADR", ladrs.cdadr, OUTPUT CdCodVoi).
                                IF CdCodVoi = "-" THEN 
                                    ASSIGN CdCodVoi = "".
                                RUN DecodeSys_pr ("NTVOI", adres.ntvoi, OUTPUT CdNatVoi).

                                /*RUN DecodeTelephone (ladrs.cdte1, ladrs.note1, INPUT-OUTPUT NoTelTie).
                                RUN DecodeTelephone (ladrs.cdte2, ladrs.note2, INPUT-OUTPUT NoTelTie).
                                RUN DecodeTelephone (ladrs.cdte3, ladrs.note3, INPUT-OUTPUT NoTelTie).*/

                                ASSIGN
                                    LbNumVoi    = (IF ladrs.novoi <> "0" THEN ladrs.novoi + " " ELSE "")
                                    LbCodPos    = adres.cdpos
                                    LbNomVil    = adres.lbvil
                                    LbAdr001    = LbNumVoi + TRIM (TRIM (CdCodVoi + " " + CdNatVoi) + " " + adres.lbvoi)
                                    LbAdr002    = adres.cpvoi
                                    CdCodPay    = adres.cdpay
                                .

                            END. /* fin ELSE NOT AVAILABLE adres */
                        END.
                    END.  
                END.
            END.    /*--> Fin Recherche GÈrant */                        
        END.
    END.    /* Cas Role COPROPRIETAIRE */                   

    /*-----------------------------------------------ø
     | Indiquer l'Çtat du Rìle...                    |
     ¿-----------------------------------------------*/
    CdRolAct = "A".     
    CASE TpRolUse-IN:

        WHEN "00008" THEN DO:

            /* Tester si le Mandat de Syndic n'est pas rÇsiliÇ... */
            RUN IsCttRes("01003", NoCttUse-IN, OUTPUT DtDatRee, OUTPUT FgRolAct).
            IF FgRolAct THEN 
                ASSIGN 
                CdRolAct = "R"
                DtVenSor = STRING(DtDatRee,"99/99/9999").
            ELSE DO:
                ASSIGN 
                    NbLotUse = 0
                    NbDenOld = 0.
                /* Rechercher si ce copropriÇtaire a encore un lot. */
                FOR EACH intnt NO-LOCK
                    WHERE   intnt.TpCon = "01004"     
                    AND intnt.NoCon = INTEGER(STRING(NoCttUse-IN, "99999") + STRING(NoRolUse, "99999"))
                    AND intnt.TpIdt = "02002":
    
                    /* nb de lots du copro*/
                    ASSIGN NbLotUse = NbLotUse + 1.
                    
                    IF intnt.NbDen = 0 THEN DO:
                    
                        ASSIGN FgRolAct = TRUE.
                        LEAVE.
                        
                    END.
                    ELSE DO :
                    
                        IF NbDenOld = 0 THEN
                           NbDenOld = intnt.nbden.
                        ELSE DO :
                           IF intnt.nbden > NbDenOld THEN
                              NbDenOld = intnt.nbden.
                        END.
    
                    END.
                                   
                END.    /* Fin Recherche des Lots du CopropriÇtaire (via Titre Copro). */

                IF NbDenOld <> 0 THEN
                       DtDatRee = DATE(INTEGER(SUBSTRING(STRING(NbDenOld,"99999999"),5,2)),
                               INTEGER(SUBSTRING(STRING(NbDenOld,"99999999"),7,2)),
                               INTEGER(SUBSTRING(STRING(NbDenOld,"99999999"),1,4))).
                    
                    ASSIGN CdRolAct = (IF FgRolAct THEN "A" ELSE "V")
                .
                /* tester le nombre de lots car si aucuns lots
                    => ? dans dtvensor*/
                IF NbLotUse > 0 THEN
                       DtVenSor = (IF FgRolAct THEN "" ELSE STRING(DtDatRee,"99/99/9999")).
                ELSE ASSIGN DtVenSor = ""
                    CdRolAct = "V".

            END.    /* Fin Mandat Syndc non rÇsiliÇ. */

        END.    /* Fin Gestion copropriÇtaire Actif. */

        WHEN "00022" OR WHEN "00016" THEN DO:

            /* Rechercher si le Mandat n'est pas rÇsiliÇ... */
            RUN IsCttRes("01030", NoCttUse-IN, OUTPUT DtDatRee, OUTPUT FgRolAct).
            ASSIGN CdRolAct = (IF FgRolAct THEN "R" ELSE "A")
               DtVenSor = (IF FgRolAct THEN STRING(DtDatRee,"99/99/9999") ELSE "").

        END.

        WHEN "00019" THEN DO:

            /* Rechercher si le Bail n'est pas rÇsiliÇ... */
            RUN IsCttRes("01033", NoRolUse-IN, OUTPUT DtDatRee, OUTPUT FgRolAct).
            ASSIGN CdRolAct = (IF FgRolAct THEN "R" ELSE "A")
               DtVenSor = (IF FgRolAct THEN STRING(DtDatRee,"99/99/9999") ELSE "").

        END.

        WHEN "00036" THEN DO:

            FIND taint WHERE taint.Tpcon = "01003"
                     AND taint.nocon = NoCttUse-IN
                     AND taint.tptac = "04047"
                     AND taint.tpidt = TpRoluse-IN
                     AND taint.noidt = NoRoluse-IN
            NO-LOCK NO-ERROR.
            IF AVAILABLE taint THEN DO:     
                /* Tester si le Mandat de Syndic n'est pas rÇsiliÇ... */
                RUN IsCttRes("01003", NoCttUse-IN, OUTPUT DtDatRee, OUTPUT FgRolAct).
                IF FgRolAct THEN 
                   ASSIGN CdRolAct = "R"
                      DtVenSor = STRING(DtDatRee,"99/99/9999").
            END.
        END.
        WHEN "00034" THEN DO:
            /* Tester si le Mandat de Syndic n'est pas rÇsiliÇ... */
            RUN IsCttRes("01003", NoCttUse-IN, OUTPUT DtDatRee, OUTPUT FgRolAct).
            IF FgRolAct THEN 
               ASSIGN CdRolAct = "R"
                  DtVenSor = STRING(DtDatRee,"99/99/9999").
        END.
        WHEN "00006" THEN DO:
            /* BÇnÇficiaire : ras */
            CdRolAct = "?".
        END.
        
        WHEN "00014" OR WHEN "00071" THEN DO:
            /* Mandataire/gÈrant : ras */
            CdRolAct = "?".
        END.        
            
        OTHERWISE DO:
            /* Type de Rìle non gÇrÇ. */
            ASSIGN CdRetUse-OU = "05".
            RETURN.
        END.

    END CASE.   /* Fin Recherche si Rìle actif. */

    /*-----------------------------------------------ø
     | Chargement adresse de räglement propriÇtaire  |
     | ou bÇnÇficiaire                               |
     ¿-----------------------------------------------*/
    IF TpRolUse-IN = "00022" OR TpRolUse-IN = "00016" OR TpRolUse-IN = "00006" THEN DO:
    RUN ChgAdrReg.
END.

/*-----------------------------------------------ø
 | Construction de la Chaine de Retour.          |
 ¿-----------------------------------------------*/
LbAdrUse-OU = TRIM (NmTieCpl)                   + CHR(164) +
              TRIM (LbAdr001)                   + CHR(164) +
              TRIM (LbAdr002)                   + CHR(164) +
              TRIM (LbCodPos)                   + CHR(164) +
              TRIM (LbNomVil)                   + CHR(164) +
              NoTelTie                          + CHR(164) +
              TRIM (NmCntCpl)                   + CHR(164) +
              NoTelCnt                          + CHR(164) +
              CdCodPay                          + CHR(164) +
              CdCvtTie                          + CHR(164) +
              LbCvtTie                          + CHR(164) +
              CdCodTie                          + CHR(164) +
              LbNomTi2                          + CHR(164) +
              LbNomRep                          + CHR(164) +
              LbNomCO                           + CHR(164) +
              CdRolAct                          + CHR(164) +
              DtVenSor                          + CHR(164) +
              NmTieCrt                          + CHR(164) +
              NmTi2Crt                          + CHR(164) +
              (IF FgAdrReg THEN "1" ELSE "0")   + CHR(164) +
              TRIM (LbAd1Reg)                   + CHR(164) +
              TRIM (LbAd2Reg)                   + CHR(164) +
              LbCPoReg                          + CHR(164) +
              TRIM (LbVilReg)                   + CHR(164) +
              CdPayReg                          + CHR(164) +
              cocopro                           + CHR(164) +
              CdTvaInt                          + CHR(164) +
              LbNomMan                          + CHR(164) +
              LbNomGer                          + CHR(164) +
              LbTitLet                          + CHR(164) +
              CdSiret                           + CHR(164) +
              CdNAF                             + CHR(164) +                    
              NoPorTie                          + CHR(164) +
              CdModEnv /**Ajout OF le 27/03/13**/
              .
/** DEBUG 
MESSAGE "chgadr01.p " CdFndUse-IN CdSocUse-IN NoCttUse-IN TpRolUse-IN NoRolUse-IN " =>" NoRolUse  SKIP
LbAdrUse-OU SKIP
 "1 " entry(1, LbAdrUse-OU, "§")     SKIP
 "2 " entry(2, LbAdrUse-OU, "§")     SKIP
 "3 " entry(3, LbAdrUse-OU, "§")     SKIP
 "4 " entry(4, LbAdrUse-OU, "§")     SKIP
 "5 " entry(5, LbAdrUse-OU, "§")     SKIP
 "6 " entry(6, LbAdrUse-OU, "§")     SKIP
 "7 " entry(7, LbAdrUse-OU, "§")     SKIP
 "8 " entry(8, LbAdrUse-OU, "§")     SKIP
 "9 " entry(9, LbAdrUse-OU, "§")     SKIP
 "10 " entry(10, LbAdrUse-OU, "§")     SKIP
 "11 " entry(11, LbAdrUse-OU, "§")     SKIP
 "12 " entry(12, LbAdrUse-OU, "§")     SKIP
 "13 " entry(13, LbAdrUse-OU, "§")     SKIP
 "14 " entry(14, LbAdrUse-OU, "§")     SKIP
 "15 " entry(15, LbAdrUse-OU, "§")     SKIP
 "16 " entry(16, LbAdrUse-OU, "§")     SKIP
 "17 " entry(17, LbAdrUse-OU, "§")     SKIP
 "18 " entry(18, LbAdrUse-OU, "§")     SKIP
 "19 " entry(19, LbAdrUse-OU, "§")     SKIP
 "20 " entry(20, LbAdrUse-OU, "§")     SKIP
 "21 " entry(21, LbAdrUse-OU, "§")     SKIP
 view-as alert-box. 
**/           
END.            

/* #s 'Section PROCEDURES'
 €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 €€€ S e c t i o n  €€€€€€€€€€€€€€€€€  P R O C E D U R E S  €€€€€€€€€€€€€€€€€
 €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ */

/*----------------------------------------------------------------------------
   DÇcodage du tÇlÇphone
 ----------------------------------------------------------------------------*/

PROCEDURE DecodeTelephone :

/*  DEFINE INPUT PARAMETER      CdTelUse-IN AS CHARACTER NO-UNDO.
*   DEFINE INPUT PARAMETER      NoTelUse-IN AS CHARACTER NO-UNDO.
*   DEFINE INPUT-OUTPUT PARAMETER   NoTelUse-IO AS CHARACTER NO-UNDO.
* 
*   CASE CdTelUse-IN:
*       /* Telex */
*       WHEN "00011" OR
*       WHEN "00010" /* DM 0604/0164 Email */ 
*       THEN DO:
*           IF TRIM(ENTRY (2, NoTelUse-IO, CHR(164))) = "" THEN ENTRY (2, NoTelUse-IO, CHR(164)) = NoTelUse-IN.
*       END.
*       /* Fax */
*       WHEN "00003" THEN DO:
*           IF TRIM( ENTRY (3, NoTelUse-IO, CHR(164))) = "" THEN ENTRY (3, NoTelUse-IO, CHR(164)) = NoTelUse-IN.
*       END.
*       OTHERWISE DO:
*           IF CdTelUse-IN <> "00000" THEN DO:
*               IF TRIM(ENTRY (1, NoTelUse-IO, CHR(164))) = "" THEN ENTRY (1, NoTelUse-IO, CHR(164)) = NoTelUse-IN.
*           END.
*       END.
*   END. */  /**Modif OF le 20/08/08**/

    FOR EACH telephones NO-LOCK
        WHERE telephones.tpidt = TpRolUse-IN
            AND telephones.noidt = NoRolUse /*NoRolUse-IN*/
        BY telephones.tptel BY telephones.nopos: /*Dans l'ordre saisi*/
        /*Type tÈlÈphone*/
        IF telephones.tptel = "00001" THEN DO:
            IF telephones.cdtel = "00012" THEN DO: /*Portable*/
                NoPorTie = telephones.notel.
            END.
            ELSE DO: /*Autre tÈlÈphone (le 1er tÈlÈphone autre que portable)*/
                IF TRIM(ENTRY (1, NoTelTie, CHR(164))) = "" THEN ENTRY (1, NoTelTie, CHR(164)) = telephones.notel.
            END.
        END.
        ELSE DO:
            /*IF telephones.cdtel = "00010" THEN DO: /*Email*/*/ /**Modif OF le 27/03/13**/
            IF telephones.tptel = "00003" THEN DO: /*Email*/
                IF TRIM(ENTRY (2, NoTelTie, CHR(164))) = "" THEN ENTRY (2, NoTelTie, CHR(164)) = telephones.notel.
            END.
            /*ELSE IF telephones.cdtel = "00003" THEN DO: /*Fax*/*/ /**Modif OF le 27/03/13**/
            ELSE IF telephones.tptel = "00002" THEN DO: /*Fax*/
                IF TRIM(ENTRY (3, NoTelTie, CHR(164))) = "" THEN ENTRY (3, NoTelTie, CHR(164)) = telephones.notel.
            END.
        END.

    END.

    /*** DEBUG 
/*IF NoRolUse-IN = 2505 THEN */
MESSAGE "TpRolUse-IN" TpRolUse-IN SKIP "NoRolUse-IN" NoRolUse-IN " =>" NoRolUse
SKIP "NoTelTie" NoTelTie SKIP "NoPorTie" NoPorTie VIEW-AS ALERT-BOX.
***/
END PROCEDURE.

/*----------------------------------------------------------------------------
   Recherche code dans sys_pg
 ----------------------------------------------------------------------------*/

PROCEDURE DecodeSys_pg :

    DEFINE INPUT PARAMETER cTypeParam LIKE sys_pg.tppar NO-UNDO.
    DEFINE INPUT PARAMETER cCdParam   LIKE sys_pg.cdpar NO-UNDO.

    DEFINE OUTPUT PARAMETER cLibLong  LIKE sys_lb.lbmes NO-UNDO.

    ASSIGN
        cLibLong    = ""
        .

    IF cCdParam <> "00000" THEN DO:
        FIND sys_pg
            WHERE sys_pg.tppar = cTypeParam
                AND sys_pg.cdpar = cCdParam
            NO-LOCK NO-ERROR.

        IF AVAILABLE sys_pg THEN DO :
            RUN ADBRecupLib (sys_pg.nome1, OUTPUT cLibLong).
        END.
    END.

END.

/*----------------------------------------------------------------------------
   Recherche code dans sys_pr
 ----------------------------------------------------------------------------*/

PROCEDURE DecodeSys_pr :

    DEFINE INPUT PARAMETER cTypeParam LIKE sys_pg.tppar NO-UNDO.
    DEFINE INPUT PARAMETER cCdParam   LIKE sys_pg.cdpar NO-UNDO.

    DEFINE OUTPUT PARAMETER cLibLong  LIKE sys_lb.lbmes NO-UNDO.

    ASSIGN
        cLibLong    = ""
        .

    FIND sys_pr
        WHERE sys_pr.tppar = cTypeParam
            AND sys_pr.cdpar = cCdParam
        NO-LOCK NO-ERROR.

    IF AVAILABLE sys_pr THEN DO :
        RUN ADBRecupLib (Sys_pr.nome1,OUTPUT cLibLong).
    END.

END.

/*----------------------------------------------------------------------------
   Traduction
 ----------------------------------------------------------------------------*/

PROCEDURE ADBRecupLib:

    DEFINE INPUT PARAMETER iNoMes LIKE sys_lb.nomes NO-UNDO.
    DEFINE OUTPUT PARAMETER clbmes LIKE sys_lb.lbmes NO-UNDO.

    FIND sys_lb
        WHERE sys_lb.nomes = iNomes
            AND sys_lb.cdlng = cdlngses
        NO-LOCK NO-ERROR.

    cLbMes = (IF AVAILABLE sys_lb THEN sys_lb.lbmes ELSE "").

END.

/*----------------------------------------------------------------------------
   DÇcodification du nom
 ----------------------------------------------------------------------------*/

PROCEDURE DecodeNom:

    DEFINE INPUT PARAMETER  cdFamille   LIKE tiers.cdfat NO-UNDO.
    DEFINE INPUT PARAMETER  cdcivilite  LIKE tiers.cdcv1 NO-UNDO.
    DEFINE INPUT PARAMETER  cdQualite   LIKE tiers.cdpr1 NO-UNDO.
    DEFINE INPUT PARAMETER  cNom        LIKE tiers.lnom1 NO-UNDO.
    DEFINE INPUT PARAMETER  cPrenom     LIKE tiers.lpre1 NO-UNDO.

    DEFINE OUTPUT PARAMETER NmTieCpl-OU AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cCivilite LIKE tiers.cdcv1 NO-UNDO.
    DEFINE VARIABLE cQualite  LIKE tiers.cdpr1 NO-UNDO.

    RUN DecodeSys_pg ("O_CVT", cdCivilite, OUTPUT cCivilite).
    RUN DecodeSys_pg ("O_PAT", cdQualite, OUTPUT cQualite).

    IF cdfamille = "09003" OR cdfamille = "09004" THEN
        NmTieCpl-OU = TRIM(TRIM(cCivilite + " " + cQualite) + " " + cNom + cPrenom).
    ELSE
        NmTieCpl-OU = TRIM(TRIM(TRIM(cCivilite + " " + cQualite) + " " + cNom) 
                + " " + cPrenom).


END.

/*----------------------------------------------------------------------------
   DÇcodification du nom court
 ----------------------------------------------------------------------------*/

PROCEDURE ForNmtie:

    DEFINE INPUT PARAMETER  cdfamille   LIKE tiers.cdfat NO-UNDO.
    DEFINE INPUT PARAMETER  cdcivilite  LIKE tiers.cdcv1 NO-UNDO.
    DEFINE INPUT PARAMETER  cdQualite   LIKE tiers.cdpr1 NO-UNDO.
    DEFINE INPUT PARAMETER  cNom        LIKE tiers.lnom1 NO-UNDO.
    DEFINE INPUT PARAMETER  cPrenom     LIKE tiers.lpre1 NO-UNDO.

    DEFINE OUTPUT PARAMETER NmTieCpl-OU AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cCivilite LIKE tiers.cdcv1 NO-UNDO.
    DEFINE VARIABLE cQualite  LIKE tiers.cdpr1 NO-UNDO.

    IF cdcivilite <> "00000" THEN DO:
        FIND sys_pg
            WHERE sys_pg.tppar = "O_CVT"
                AND sys_pg.cdpar = CdCivilite
            NO-LOCK NO-ERROR.

        IF AVAILABLE sys_pg THEN DO :
            FIND sys_lb
                WHERE sys_lb.nomes = Sys_pg.nome2
                    AND sys_lb.cdlng = cdlngses
                NO-LOCK NO-ERROR.

            cCivilite = (IF AVAILABLE sys_lb THEN sys_lb.lbmes ELSE "").
        END.
    END.
    RUN DecodeSys_pg ("O_PAT", cdQualite, OUTPUT cQualite).

    IF cdfamille = "09003" OR cdfamille = "09004" THEN
        NmTieCpl-OU = TRIM(TRIM(cCivilite + " " + cQualite) + " " + cNom + cPrenom).
    ELSE
        NmTieCpl-OU = TRIM(TRIM(TRIM(cCivilite + " " + cQualite) + " " + cNom) + " " + cPrenom).

END.

/*----------------------------------------------------------------------------
   Procedure pour savoir si un contrat est rÇsiliÇ ou non.
 ----------------------------------------------------------------------------*/
PROCEDURE IsCttRes:

    DEFINE INPUT    PARAMETER   TpConUse-IN AS CHARACTER    NO-UNDO.
    DEFINE INPUT    PARAMETER   NoConUse-IN AS INT64    NO-UNDO.

    DEFINE OUTPUT   PARAMETER   DtDatRee-OU     AS DATE     NO-UNDO.
    DEFINE OUTPUT   PARAMETER   FgCttRes-OU AS LOGICAL  NO-UNDO.

    FIND ctrat 
            WHERE   ctrat.TpCon = TpConUse-IN
            AND ctrat.NoCon = NoConUse-IN
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE ctrat THEN DO:

            /* Anomalie => ConsidÇrer le Contrat comme Çtant rÇsiliÇ. */
            ASSIGN FgCttRes-OU = YES
               DtDatRee-OU = 01/01/1980. 
            RETURN.

        END.

        ASSIGN FgCttRes-OU = (IF ctrat.DtRee <> ? THEN TRUE ELSE FALSE)
           DtDatRee-OU = ctrat.dtree
    .

END PROCEDURE.


/*----------------------------------------------------------------------------
   Procedure de rÇcupÇration de l'adresse de räglament
 ----------------------------------------------------------------------------*/
PROCEDURE ChgAdrReg:

    FIND FIRST ladrs WHERE Ladrs.Tpidt = TpRolUse-IN
             AND Ladrs.noidt = NoRolUse
             AND Ladrs.Tpadr = "00005"  
        NO-LOCK NO-ERROR.
    IF AVAILABLE Ladrs THEN DO:
        FIND Adres WHERE Adres.noadr = Ladrs.noadr
            NO-LOCK NO-ERROR.
        IF AVAILABLE Adres THEN DO:
            RUN DecodeSys_pr ("CDADR", ladrs.cdadr, OUTPUT CdCodVoi).
            IF CdCodVoi = "-" THEN 
                ASSIGN CdCodVoi = "".
            RUN DecodeSys_pr ("NTVOI", adres.ntvoi, OUTPUT CdNatVoi).

            ASSIGN
                FgAdrReg = YES
                LbNumVoi    = (IF TRIM(ladrs.novoi) <> "0" AND TRIM(ladrs.novoi) <> "" THEN ladrs.novoi + " " ELSE "")
                LbAd1Reg    = LbNumVoi + TRIM (TRIM (CdCodVoi + " " + CdNatVoi) + " " + adres.lbvoi)
                LbAd2Reg    = adres.cpvoi
                LbCPoReg    = adres.cdpos
                LbVilReg    = adres.lbvil
                CdPayReg    = adres.cdpay
                .
        END.
    END.

END.
 
/*==F R M T I T L E T T R E================================================================================================*/
    /*--> Formattage des zones TitreLettre */

FUNCTION FrmTitLettre RETURNS CHARACTER(NoTieUse AS INTEGER):
                                        
    DEF VAR LbRetUse    AS CHARACTER    NO-UNDO.
    DEF VAR LbDiv2Use   AS CHARACTER    NO-UNDO.
    DEF BUFFER btiers FOR tiers.
    
    FIND FIRST btiers   WHERE btiers.notie = NoTieUse
                        NO-LOCK NO-ERROR.
    IF AVAILABLE btiers THEN
    DO:
        /* Ajout Sy le 10/11/2008 - fiche 0908/0162 */
        LbDiv2Use = btiers.lbdiv2.
        IF TRIM(LbDiv2Use) = "" THEN LbDiv2Use = "00001#".
        IF NUM-ENTRIES(LbDiv2Use,"#") >= 2 THEN
        DO:
            IF ENTRY(1,LbDiv2Use,"#") = "00003" THEN
                LbRetUse = ENTRY(2,LbDiv2Use,"#").
            ELSE
            DO:
                FIND FIRST pclie    WHERE pclie.tppar = "FOPOL"
                                    AND pclie.zon01 = btiers.CdSft
                                    AND pclie.zon02 = btiers.cdcv1
                                    AND pclie.zon03 = btiers.cdcv2
                                    NO-LOCK NO-ERROR.
                IF NOT AVAILABLE pclie THEN
                    FIND FIRST pclie    WHERE pclie.tppar = "FOPOL"
                                        AND pclie.zon01 = btiers.CdSft
                                        AND pclie.zon02 = btiers.cdcv1
                                        NO-LOCK NO-ERROR.
                
                IF AVAILABLE pclie THEN
                DO:
                    CASE ENTRY(1,LbDiv2Use,"#"):
                        WHEN "00001" THEN LbRetUse = pclie.zon04.
                        WHEN "00002" THEN LbRetUse = pclie.zon05.
                    END.
                END.
            END.
        END.
    END.
    
    RETURN LbRetUse.
END.

/*----------------------------------------------------------------------------
   Fin
 ----------------------------------------------------------------------------*/
 
