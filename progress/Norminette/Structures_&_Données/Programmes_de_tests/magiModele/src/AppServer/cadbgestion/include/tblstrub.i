/*--------------------------------------------------------------------------+
|                                                                           |
| Application      : Comptabilite                                           |
| Programme        : tblstrub.i                                             |
| Objet            : Include de definition commun aux programmes suivants:  |
|                    CADB/SRC/GENE/FAANOUV.W + FAANOUV2.W + FAANOUV3.W      |
|                    CADB/SRC/GENE/FAENQUIT.W + HLRUBQT2.W                  |
|                    CADB/SRC/FDIV/FTFAC.W + CPTATFAC.P + TFACRBQT.P        |
|                                                                           |
|===========================================================================|
|                                                                           |
| Date de création : 09/05/05   Fiche 0405/0409                             |
| Auteur(s)        : OF                                                     |
|                                                                           |
 +---------------------------------------------------------------------------+


+---------------------------------------------------------------------------+
| Historique des modifications                                              |
|======+============+========+==============================================|
|  Nø  |    Date    | Auteur |                  Objet                       |
|======+============+========+==============================================|
|      |            |        |                                              |
+--------------------------------------------------------------------------*/


/*==Table Partagee===========================================================*/
DEFINE {1} SHARED TEMP-TABLE tmp-rubqt NO-UNDO
   FIELD rubqt-cd   AS CHAR
   FIELD ssrubqt-cd AS CHAR
   FIELD lib        AS CHAR FORMAT "X(32)" 
   FIELD ana1-cd    AS CHAR
   FIELD ana2-cd    AS CHAR
   FIELD ana3-cd    AS CHAR
   FIELD typeTva-cd AS CHAR                           
   FIELD fg-calc    AS LOGICAL
   FIELD cdfam      LIKE rubqt.cdfam
   FIELD cdsfa      LIKE rubqt.cdsfa
   FIELD rubtva     LIKE rubqt.cdrub
   FIELD taux       AS DECIMAL
   INDEX i-rubqt IS PRIMARY UNIQUE rubqt-cd ssrubqt-cd 
   INDEX i-librubqt lib
   INDEX i-rubcalc  fg-calc
   .
