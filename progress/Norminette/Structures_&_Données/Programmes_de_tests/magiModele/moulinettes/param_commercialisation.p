/*****************************************************************************/
/* Programme    : param_commercialisation.p                                  */
/* Auteurs      : SY                                                         */
/* Date         : 27/01/2017                                                 */
/* Objet        : Moulinette pour modifier ladb ( libell‚s & paramŠtres)     */
/*                MODERNISATION - Module COMMERCIALISATION (ex GIRELOC)      */
/*****************************************************************************/

/*
*-------------------------------------------------------------------------------------*
| Historique des modifications                                                        |
|-------------------------------------------------------------------------------------|
|  No  |    Date    | Auteur |                  Objet                                 |
|------+------------+--------+--------------------------------------------------------|
| 0001 | 08/03/2017 |   SY   | Ajout paramètre GLMRC Modalité récupération des charges|
| 0002 | 21/03/2017 |   NP   | Ajout worflow                                          |
| 0003 | 19/04/2017 |   GG   | Ajout initialisation table gl_worflow et gl_libelle    |
|      |            |        | pour workflow                                          |
| 0004 | 18/05/2017 | GG/SY  | Ajout paramètre GLMCR mode de création fiche           |
|      |            |        |                                                        |
|      |            |        |                                                        |
|      |            |        |                                                        |
|      |            |        |                                                        |
|      |            |        |                                                        |
*-------------------------------------------------------------------------------------*/

/* gga le 19/04/17 debut ajout */ 
function igetNextSequence returns integer (pcNomTable as character,
                                           pcIndexTable as character, 
                                           pcChampSequence as character):
    /*------------------------------------------------------------------------------
    Purpose: calcul prochain numero de sequence 
    Notes  :
    ------------------------------------------------------------------------------*/        
    define variable vhBuffer as handle no-undo. 
    define variable vhQuery as handle no-undo. 
    define variable vcQuery as character no-undo. 
    define variable viSequence as integer no-undo. 
    
    create buffer vhBuffer for table pcNomTable.
    
    vcQuery = substitute("for each &1 ", pcNomTable). 
    if pcIndexTable <> ""
    then vcQuery  = vcQuery + substitute("use-index &1 ", pcIndexTable).    
    
    create query vhQuery.
    vhQuery:set-buffers(vhBuffer).
    vhQuery:query-prepare(vcQuery).
    vhQuery:query-open().
    
    vhQuery:get-last(). 
    if not vhQuery:query-off-end
    then viSequence = vhBuffer:buffer-field(pcChampSequence):buffer-value + 1. 
    else viSequence  = 1.       
   
    vhQuery:query-close().
    delete object vhQuery.
    delete object vhBuffer. 

    return viSequence.      
      
end function. 

define temp-table trelation no-undo
field nowk1 as integer
field nowk2 as integer. 
/* gga le 19/04/17 fin ajout */ 

DEFINE VARIABLE CpUseInc    AS INTEGER  NO-UNDO.
DEFINE VARIABLE NbEnrGen    AS INTEGER  NO-UNDO.

DEFINE VARIABLE NoOrdUSe    AS INTEGER  NO-UNDO.

DEFINE VARIABLE CdRetUse    AS CHARACTER    No-UNDO.

RUN CreModLib ( INPUT 0, INPUT 705750, INPUT "Attributs divers de la fiche de commercialisation",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705753, INPUT "Bien Premium",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705751, INPUT "Fiche coup de coeur",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705752, INPUT "Location meublée",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705757, INPUT "Résidence Services Seniors",INPUT "SYS_PR").

RUN CreModLib ( INPUT 0, INPUT 705740, INPUT "Catégories de lieux à proximité de la location",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705741, INPUT "Commerce(s)",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705742, INPUT "Ecole(s",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705743, INPUT "Transport(s)",INPUT "SYS_PR").

RUN CreModLib ( INPUT 0, INPUT 705754, INPUT "Types de barème honoraire de location",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705755, INPUT "Standard",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705756, INPUT "BNP REIM",INPUT "SYS_PR").

/*gga
RUN CreModLib ( INPUT 0, INPUT 705744, INPUT "Liste des sites WEB gérés pour la commercialisation",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705748, INPUT "BellesDemeures.com",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705747, INPUT "BienIci.com",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705746, INPUT "Explorimmo.com",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705749, INPUT "Logic-immo.com",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705745, INPUT "SeLoger.com",INPUT "SYS_PR").
gga*/

RUN CreModLib ( INPUT 0, INPUT 705736, INPUT "zones ALUR",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705739, INPUT "Reste du territoire",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705737, INPUT "Tendue",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705738, INPUT "Très tendue",INPUT "SYS_PR").

RUN CreModLib ( INPUT 0, INPUT 705758, INPUT "Liste des champs détail financier (ex GL_chpfinance)",INPUT "SYS_PR").
/* 08/03/2017 */
RUN CreModLib ( INPUT 0, INPUT 705768, INPUT "Modalités de récupération des charges",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705769, INPUT "Provisions avec régularisation annuelle",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705770, INPUT "Au forfait",INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705771, INPUT "Remboursement sur justificatifs",INPUT "SYS_PR").

/* WORKFLOW */
RUN CreModLib ( INPUT 0, INPUT 705761, INPUT "Workflow",	INPUT "SYS_PR"). 
RUN CreModLib ( INPUT 0, INPUT 705762, INPUT "Préco. Loyer",	INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705763, INPUT "A louer",			INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705764, INPUT "A valider",		INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705765, INPUT "Validé",			INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705766, INPUT "En attente",		INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705767, INPUT "Lot neutralisé", 	INPUT "SYS_PR").

/* type creation fiche */ 
RUN CreModLib ( INPUT 0, INPUT 705775, INPUT "Mode de création fiche commercialisation", INPUT "SYS_PR"). 
RUN CreModLib ( INPUT 0, INPUT 705776, INPUT "Automatique",         INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705777, INPUT "Manuelle",            INPUT "SYS_PR").
RUN CreModLib ( INPUT 0, INPUT 705778, INPUT "UL Vacante",          INPUT "SYS_PR").

RUN CreModspr("#####", "GLATB", 705750, 705750, 0 , "X(5)").
RUN CreModspr ( INPUT "GLATB", INPUT "00001", INPUT 705753, INPUT 705753, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLATB", INPUT "00002", INPUT 705751, INPUT 705751, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLATB", INPUT "00003", INPUT 705752, INPUT 705752, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLATB", INPUT "00004", INPUT 705757, INPUT 705757, INPUT 0, INPUT "").
RUN CreModspr("#####", "GLPRO", 705740, 705740, 0 , "X(5)").
RUN CreModspr ( INPUT "GLPRO", INPUT "00001", INPUT 705741, INPUT 705741, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLPRO", INPUT "00002", INPUT 705742, INPUT 705742, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLPRO", INPUT "00003", INPUT 705743, INPUT 705743, INPUT 0, INPUT "").
RUN CreModspr("#####", "GLTHO", 705754, 705754, 0 , "X(10)").
RUN CreModspr ( INPUT "GLTHO", INPUT "00001", INPUT 705755, INPUT 705755, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLTHO", INPUT "00002", INPUT 705756, INPUT 705756, INPUT 0, INPUT "03073,06505,06506").	/* BNP REIM : spécifique DAUCHEZ */

/*gga
RUN CreModspr("#####", "GLWEB", 705744, 705744, 0 , "X(20)").
RUN CreModspr ( INPUT "GLWEB", INPUT "00001", INPUT 705753, INPUT 705753, INPUT 0, INPUT "").	/* site du cabinet */
RUN CreModspr ( INPUT "GLWEB", INPUT "00002", INPUT 705748, INPUT 705748, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLWEB", INPUT "00003", INPUT 705747, INPUT 705747, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLWEB", INPUT "00004", INPUT 705746, INPUT 705746, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLWEB", INPUT "00005", INPUT 705749, INPUT 705749, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLWEB", INPUT "00006", INPUT 705745, INPUT 705745, INPUT 0, INPUT "").
gga*/ 

RUN CreModspr("#####", "GLZON", 705736, 705736, 0 , "X(5)"). /* zones ALUR */
RUN CreModspr ( INPUT "GLZON", INPUT "00001", INPUT 705739, INPUT 705739, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLZON", INPUT "00002", INPUT 705737, INPUT 705737, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLZON", INPUT "00003", INPUT 705738, INPUT 705738, INPUT 0, INPUT "").

/* Ajout 26/01/2017 : GL_CHPFINANCE remplacé par paramètre sys_pr : "GLCHF" avec tpfinance dans zone1 et tphonoraire2 dans zone2 (vide ou 00019 ou 00022) */
RUN CreModspr("#####", "GLCHF", 705758, 705758, 999999999.99 , "X(5)").
RUN CreModspr ( INPUT "GLCHF", INPUT "10001", INPUT 000170, INPUT 000170, INPUT 10, INPUT "").    /* Loyer              */
RUN CreModspr ( INPUT "GLCHF", INPUT "10002", INPUT 703635, INPUT 703635, INPUT 10, INPUT "").	  /* Provision charges  */
RUN CreModspr ( INPUT "GLCHF", INPUT "10003", INPUT 701787, INPUT 701787, INPUT 10, INPUT "").	  /* Franchise */
RUN CreModspr ( INPUT "GLCHF", INPUT "10004", INPUT 703985, INPUT 703985, INPUT 10, INPUT "").    /* Loyer Stationnement */
RUN CreModspr ( INPUT "GLCHF", INPUT "10005", INPUT 700181, INPUT 700181, INPUT 10, INPUT "").    /* Complément loyer */

RUN CreModspr ( INPUT "GLCHF", INPUT "20001", INPUT 704284, INPUT 704284, INPUT 20, INPUT "").    /* Dépôt              */
RUN CreModspr ( INPUT "GLCHF", INPUT "20002", INPUT 703246, INPUT 703246, INPUT 20, INPUT "").	  /* Annexe             */
RUN CreModspr ( INPUT "GLCHF", INPUT "20003", INPUT 701973, INPUT 701973, INPUT 20, INPUT "").	  /* Clé Magnétique     */
/* champs de finance honoraire locataire */
RUN CreModspr ( INPUT "GLCHF", INPUT "50101", INPUT 1000068, INPUT 1000068, INPUT 50, INPUT "00019").  /* Visite + constitution du dossier  */
RUN CreModspr ( INPUT "GLCHF", INPUT "50102", INPUT  703756, INPUT  703756, INPUT 50, INPUT "00019").  /* Frais d'acte                      */
RUN CreModspr ( INPUT "GLCHF", INPUT "50103", INPUT 1000067, INPUT 1000067, INPUT 50, INPUT "00019").  /* Etat des lieux                    */
/* champs de finance honoraire propriétaire */
RUN CreModspr ( INPUT "GLCHF", INPUT "50201", INPUT  901802, INPUT  901802, INPUT 50, INPUT "00022").  /* Commercialisation                 */
RUN CreModspr ( INPUT "GLCHF", INPUT "50202", INPUT  703756, INPUT  703756, INPUT 50, INPUT "00022").  /* Frais d'acte                      */
RUN CreModspr ( INPUT "GLCHF", INPUT "50203", INPUT 1000067, INPUT 1000067, INPUT 50, INPUT "00022").  /* Etat des lieux                    */

/* Ajout SY le 27/01/2017 : nouveaux type de roles (commercial existe déjà avec le code "00072" mais pour pack AFEDIM Desport => ne pas réutiliser */
RUN CreModLib ( INPUT 0, INPUT 702507, INPUT "Agence délégataire",INPUT "SYS_PG").
RUN CreSysPg("O_ROL","00081",702507, 0, "", "", "", "", "", "", 1, 1).
RUN CreSysPg("R_FRL","00054",702507, 0, "12002", "00081", "", "", "", "", 1, 1).
RUN CreSysPg("R_RFR","00081",702507, 0, "00081", "12002", "", "", "", "", 1, 1).

RUN CreSysPg("O_ROL","00082",702197, 0, "", "", "", "", "", "", 1, 1).
RUN CreSysPg("R_FRL","00055",702197, 0, "12002", "00082", "", "", "", "", 1, 1).
RUN CreSysPg("R_RFR","00082",702197, 0, "00082", "12002", "", "", "", "", 1, 1).

RUN CreModLib ( INPUT 0, INPUT 702508, INPUT "Responsable commercial",INPUT "SYS_PG").
RUN CreSysPg("O_ROL","00083",702508, 0, "", "", "", "", "", "", 1, 1).
RUN CreSysPg("R_FRL","00056",702508, 0, "12002", "00083", "", "", "", "", 1, 1).
RUN CreSysPg("R_RFR","00083",702508, 0, "00083", "12002", "", "", "", "", 1, 1).

/* 08/03/2017 */
RUN CreModspr("#####", "GLMRC", 705768, 705768, 0 , "X(5)"). /* Modalité récupération des charges  */
RUN CreModspr ( INPUT "GLMRC", INPUT "00001", INPUT 705769, INPUT 705769, INPUT 0, INPUT "DEFAUT").
RUN CreModspr ( INPUT "GLMRC", INPUT "00002", INPUT 705770, INPUT 705770, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLMRC", INPUT "00003", INPUT 705771, INPUT 705771, INPUT 0, INPUT "").

/* WORKFLOW */
RUN CreModspr("#####", "GLWFW", 705761, 705761, 0 , "X(5)").										/* Workflow */
RUN CreModspr ( INPUT "GLWFW", INPUT "00001", INPUT 705408, INPUT 705408, INPUT 0, INPUT ""). 		/* Vacant */
RUN CreModspr ( INPUT "GLWFW", INPUT "00010", INPUT 705762, INPUT 705762, INPUT 0, INPUT "").		/* Préco. Loyer */
RUN CreModspr ( INPUT "GLWFW", INPUT "00020", INPUT 705763, INPUT 705763, INPUT 0, INPUT "").		/* A louer */			
RUN CreModspr ( INPUT "GLWFW", INPUT "00030", INPUT 705764, INPUT 705764, INPUT 0, INPUT "").		/* A valider */			
RUN CreModspr ( INPUT "GLWFW", INPUT "00040", INPUT 705765, INPUT 705765, INPUT 0, INPUT "").		/* Validé */			
RUN CreModspr ( INPUT "GLWFW", INPUT "00050", INPUT 705766, INPUT 705766, INPUT 0, INPUT "").		/* En attente */		
RUN CreModspr ( INPUT "GLWFW", INPUT "00999", INPUT 705406, INPUT 705406, INPUT 0, INPUT "").		/* Loué */				
RUN CreModspr ( INPUT "GLWFW", INPUT "00099", INPUT 705767, INPUT 705767, INPUT 0, INPUT "").		/* Lot neutralisé */	

RUN CreModspr ( INPUT "#####", INPUT "GLMCR", INPUT 705775, INPUT 705775, INPUT 0, INPUT "X(5)").
RUN CreModspr ( INPUT "GLMCR", INPUT "00001", INPUT 705776, INPUT 705776, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLMCR", INPUT "00002", INPUT 705777, INPUT 705777, INPUT 0, INPUT "").
RUN CreModspr ( INPUT "GLMCR", INPUT "00003", INPUT 705778, INPUT 705778, INPUT 0, INPUT "").

/* WORKFLOW relation possible entre les etapes */ 
def var relationwk as character no-undo. 
relationwk = "00001,00010" + ";" + 
             "00001,00099" + ";" + 
             "00010,00020" + ";" + 
             "00010,00099" + ";" +              
             "00020,00030" + ";" + 
             "00020,00099" + ";" + 
             "00030,00020" + ";" + 
             "00030,00040" + ";" + 
             "00030,00099" + ";" +              
             "00040,00050" + ";" + 
             "00040,00099" + ";" +              
             "00050,00999" + ";" + 
             "00050,00099" + ";" + 
             "00999,00001" + ";" +              
             "00999,00099" + ";" +  
             "00099,00001". 

/* Sy 10/04/2017 : Tiers apporteur (par défaut : le cabinet */
RUN CreModLib ( INPUT 0, INPUT 702510, INPUT "Tiers apporteur",INPUT "SYS_PG").
RUN CreSysPg("O_ROL","00084",702510, 0, "", "", "", "", "", "", 1, 1).
RUN CreSysPg("R_FRL","00057",702510, 0, "12002", "00084", "", "", "", "", 1, 1).
RUN CreSysPg("R_RFR","00084",702510, 0, "00084", "12002", "", "", "", "", 1, 1).

/*gga le 19/04/17 */ 
run initrelationworkflow. 
run initsiteweb. 
run initbareme.

RETURN "1". /* <== dernière ligne du main block */

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Procedure de cr‚ation d'un libell‚
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
PROCEDURE CreModLib:
DEFINE INPUT PARAMETER	CdLngUse-IN	AS INTEGER	NO-UNDO.
DEFINE INPUT PARAMETER	NoMesUse-IN	AS INTEGER	NO-UNDO.
DEFINE INPUT PARAMETER	LbMesUse-IN	AS CHARACTER	NO-UNDO.
DEFINE INPUT PARAMETER	LbTypUse-IN	AS CHARACTER	NO-UNDO.

	FIND sys_lb
	    WHERE   sys_lb.CdLng = CdLngUse-IN
	    AND     sys_lb.NoMes = NoMesUse-IN
	    NO-ERROR.
	IF NOT AVAILABLE sys_lb THEN DO TRANSACTION:

	    CREATE sys_lb.
	    ASSIGN
		sys_lb.CdLng = CdLngUse-IN
		sys_lb.NoMes = NoMesUse-IN
		sys_lb.LbMes = LbMesUse-IN
		sys_lb.LgMes = LENGTH(sys_lb.LbMes)
		.
	
/*gga ajout not can find */ 	
		if not can-find(sys_rf
		                where sys_rf.NoMes = sys_lb.NoMes
		                and sys_rf.TpMes = LbTypUse-IN)
	    then do:	                  
            CREATE sys_rf.
	        ASSIGN
		    sys_rf.NoMes = sys_lb.NoMes
		    sys_rf.TpMes = LbTypUse-IN
		    .
		end. 
	    
	END.
	ELSE DO TRANSACTION:
	    ASSIGN
		sys_lb.LbMes = LbMesUse-IN
		sys_lb.LgMes = LENGTH(sys_lb.LbMes)
		.
	END.
END PROCEDURE.

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Procedure de cr‚ation d'un enregistrement de sys_pg
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
PROCEDURE CreSysPg:
    DEF INPUT PARAMETER TpParUse-IN    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER CdParUse-IN    AS CHARACTER format "x(5)"    NO-UNDO.
    DEF INPUT PARAMETER NoMesUse-IN    AS INTEGER      NO-UNDO.
    DEF INPUT PARAMETER NoMe2Use-IN    AS INTEGER      NO-UNDO.
    DEF INPUT PARAMETER LbZo1Use-IN    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbZo2Use-IN    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbZo3Use-IN    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbZo9Use-IN    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbRunUse-IN    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbPrgUse-IN    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbMinUse-IN    AS INTEGER    NO-UNDO.
    DEF INPUT PARAMETER LbMaxUse-IN    AS INTEGER    NO-UNDO.
    
    IF NoMe2Use-IN = 0 THEN NoMe2Use-In = NoMesUse-IN.
    DO TRANSACTION:
         FIND sys_pg WHERE sys_pg.tppar = tpparuse-IN
                     AND sys_pg.cdpar = cdparuse-IN
                     EXCLUSIVE-LOCK NO-ERROR.
         IF NOT AVAILABLE sys_pg THEN DO:
             CREATE sys_pg.
             ASSIGN
             sys_pg.tppar = tpparuse-IN
             sys_pg.cdpar = cdparuse-IN
             .
         END.
         ASSIGN
             sys_pg.nome1 = nomesuse-IN
             sys_pg.nome2 = nome2use-IN
             sys_pg.zone1 = LbZo1Use-IN
             sys_pg.zone2 = LbZo2Use-IN
             sys_pg.zone3 = LbZo3Use-IN
             sys_pg.zone9 = LbZo9Use-IN
             sys_pg.rprun = LbRunUse-IN
             sys_pg.nmprg = LbPrgUse-IN
             sys_pg.minim = LbMinUse-IN
             sys_pg.maxim = LbMaxUse-IN
     	       .
        
    END.
END PROCEDURE.

/* -------------------------------------------------------------------------
   Procedure de cr‚ation d'un menu de l'application
   ----------------------------------------------------------------------- */

PROCEDURE CreAppMenu:
    DEF INPUT PARAMETER NoLibUse    AS INTEGER      NO-UNDO.
    DEF INPUT PARAMETER LbLibUse    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER TpMenUse    AS CHARACTER    NO-UNDO.
    
    DEF INPUT PARAMETER NoMenUse    AS INTEGER      NO-UNDO.
    DEF INPUT PARAMETER NoOrdUse    AS INTEGER      NO-UNDO.
    DEF INPUT PARAMETER NoIteUSe    AS INTEGER      NO-UNDO.
    
    DEF INPUT PARAMETER NoMenSel    AS INTEGER      NO-UNDO.
    DEF INPUT PARAMETER LbCleUse    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbPrgUse    AS CHARACTER    NO-UNDO.
    
    RUN CreModLib ( INPUT 0, INPUT NoLibUse, INPUT LbLibUse, INPUT "MENUS").

    FIND FIRST men_cm   WHERE men_cm.nomen = NoMenUse
                        AND men_cm.noord = NoOrdUse
                        AND men_cm.noite = NoIteUse
                        EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE men_cm THEN
    DO:
        CREATE men_cm.
        ASSIGN
        men_cm.nomen = NoMenUse
        men_cm.noord = NoOrdUse
        men_cm.noite = NoIteUse
        men_cm.cdmsp = "0000"
        men_cm.cdisp = "0000" .
    END. 
        
    FIND FIRST men_it   WHERE men_it.noite = NoIteUse
                        EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE men_it THEN
    DO:
        CREATE men_it.
        men_it.noite = NoIteUse.
    END.
    
    ASSIGN
    men_it.nomes = NoLibUse
    men_it.mtcle = LbCleUse
    men_it.lbrun = IF TpMenUse = "M" THEN "menuscnd:" + STRING(NoMenSel) ELSE LbPrgUse
    men_it.tprun = TpMenUse
    men_it.cdisp = "0000".
        
    IF TpMenUse = "M" THEN
    DO:
        FIND FIRST men_mn   WHERE men_mn.nomen = NoMenSel
                            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE men_mn THEN
        DO:
            CREATE men_mn.
            ASSIGN 
            men_mn.nomen = NoMenSel
            men_mn.lbmen = STRING(NoLibUse) + ":" + LbLibUse.
        END.
    END.
END.

/*===========================================================================
   Procedure qui Annule et remplace un item
 ===========================================================================*/
PROCEDURE CreItem:
    DEF INPUT PARAMETER NoIteUse    AS INTEGER      NO-UNDO.
    DEF INPUT PARAMETER NoMesUse    AS INTEGER      NO-UNDO.
    DEF INPUT PARAMETER LbCleUse    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbRacUse    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbCheUse    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER LbRunUse    AS CHARACTER    NO-UNDO.
    DEF INPUT PARAMETER TpRunUse    AS CHARACTER    NO-UNDO.
    
    /*--> Creation de l'item */
    FIND sys_it WHERE sys_it.noite = NoIteUse
                EXCLUSIVE-LOCK NO-ERROR.
    IF AVAILABLE sys_it THEN
        DELETE sys_it.
    
    CREATE sys_it.
    ASSIGN
    sys_it.noite = NoIteUse
    sys_it.nomes = NoMesUse
    sys_it.mtcle = LbCleUse
    sys_it.rcclv = LbRacUse
    sys_it.lbpth = LbCheUse
    sys_it.lbrun = LbRunUse
    sys_it.tprun = TpRunUse.
END.

/*===========================================================================
   Procedure qui annule et remplace une ligne de composition
 ===========================================================================*/
PROCEDURE CreCompo:
    DEF INPUT PARAMETER NoMenUse    AS INTEGER      NO-UNDO.    /* N° Menu                  */
    DEF INPUT PARAMETER NoOrdUse    AS INTEGER      NO-UNDO.    /* N° Ordre                 */
    DEF INPUT PARAMETER NoIteUse    AS INTEGER      NO-UNDO.    /* N° Item                  */
    DEF INPUT PARAMETER TpSepUse    AS CHARACTER    NO-UNDO.    /* Separateur               */
    DEF INPUT PARAMETER TpEcrUse    AS CHARACTER    NO-UNDO.    /* Attribut                 */
    DEF INPUT PARAMETER LbImgaUp    AS CHARACTER    NO-UNDO.    /* Image Up                 */
    DEF INPUT PARAMETER LbImgDow    AS CHARACTER    NO-UNDO.    /* Image Down               */
    DEF INPUT PARAMETER LbImgSen    AS CHARACTER    NO-UNDO.    /* Image insensitive        */
    DEF INPUT PARAMETER LbImgCom    AS CHARACTER    NO-UNDO.    /* Image complete           */
    DEF INPUT PARAMETER LbPrmUse    AS CHARACTER    NO-UNDO.    /* Données complementaires  */
    
    
    FIND sys_cm WHERE sys_cm.nomen = nomenuse
                AND sys_cm.noord = noorduse
                EXCLUSIVE-LOCK NO-ERROR.
    IF AVAILABLE sys_cm THEN
        DELETE sys_cm.
    
    CREATE sys_cm.
    ASSIGN
    sys_cm.nomen = nomenuse
    sys_cm.noord = noorduse
    sys_cm.noite = noiteuse
    sys_cm.tpsep = tpsepuse
    sys_cm.tpecr = tpecruse
    sys_cm.lbimg = lbimgaup
    sys_cm.lbimd = lbimgdow
    sys_cm.lbins = lbimgsen
    sys_cm.lbcmp = lbimgcom
    sys_cm.zone1 = lbprmuse.
    
END.

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Procedure de cr‚ation d'un paramŠtre dans sys_pr
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
PROCEDURE CreModspr:
DEFINE INPUT PARAMETER	TpParUse-IN	AS CHARACTER	NO-UNDO.
DEFINE INPUT PARAMETER	CdParUse-IN	AS CHARACTER	NO-UNDO.
DEFINE INPUT PARAMETER	NoMe1Use-IN	AS INTEGER	NO-UNDO.
DEFINE INPUT PARAMETER	NoMe2Use-IN	AS INTEGER	NO-UNDO.
DEFINE INPUT PARAMETER	Zon01Use-IN	AS DECIMAL	NO-UNDO.
DEFINE INPUT PARAMETER	Zon02Use-IN	AS CHARACTER	NO-UNDO.

DO TRANSACTION:
	FIND sys_pr
	    WHERE   sys_pr.tppar = tpparUse-IN
	    AND     sys_pr.cdpar = cdparUse-IN
	    NO-ERROR.
	IF NOT AVAILABLE sys_pr THEN DO:

	    CREATE sys_pr.
	    ASSIGN
		sys_pr.tppar = tpparUse-IN
		sys_pr.cdpar = cdparUse-IN
	    .
	END.
		
	ASSIGN
		sys_pr.nome1 = NoMe1Use-IN
		sys_pr.nome2 = NoMe2Use-IN
		sys_pr.zone1 = zon01Use-IN
		sys_pr.zone2 = zon02Use-IN
	    .
END.	

END PROCEDURE.

procedure initrelationworkflow. 

    define variable i as integer no-undo. 

    empty temp-table trelation. 
    do i = 1 to num-entries(relationwk,";"):
        create trelation.
        assign trelation.nowk1 = integer(entry(1,entry(i,relationwk,";")))
               trelation.nowk2 = integer(entry(2,entry(i,relationwk,";"))).
    end. 

    for each gl_libelle
    where gl_libelle.tpidt = 4:
        delete gl_libelle.
    end.
    for each gl_workflow:
        delete gl_workflow.
    end. 
 
    /* creation dans la table des libelles commercialisation a partir de la table sys_pr charge plus haut */
    for each sys_pr no-lock  
    where sys_pr.tppar = "GLWFW":  
        create gl_libelle. 
        assign gl_libelle.nolibelle    = igetNextSequence ("gl_libelle","ix_gl_libelle01","nolibelle")  
               gl_libelle.dtcsy        = today
               gl_libelle.hecsy        = mtime
               gl_libelle.cdcsy        = "initworkflow" 
               gl_libelle.dtmsy        = today
               gl_libelle.hemsy        = mtime
               gl_libelle.cdmsy        = "initworkflow"
               gl_libelle.tpidt        = 4
               gl_libelle.nomes        = sys_pr.nome1
               gl_libelle.noidt        = int(sys_pr.cdpar)
               gl_libelle.libelleLibre = "".  
        if sys_pr.cdpar = "00001"
        then gl_libelle.noordre = 10.
        else          
        if sys_pr.cdpar = "00010"
        then gl_libelle.noordre = 20.
        else          
        if sys_pr.cdpar = "00020"
        then gl_libelle.noordre = 30.
        else          
        if sys_pr.cdpar = "00030"
        then gl_libelle.noordre = 40.
        else          
        if sys_pr.cdpar = "00040"
        then gl_libelle.noordre = 50.
        else          
        if sys_pr.cdpar = "00050"
        then gl_libelle.noordre = 60.
        else          
        if sys_pr.cdpar = "00999"
        then gl_libelle.noordre = 70.
        else          
        if sys_pr.cdpar = "00099"
        then gl_libelle.noordre = 80.
               
    end. 
             
    /* creation table des relations possible entre etape */ 
    for each trelation:
        create gl_workflow. 
        assign gl_workflow.noworkflow1  = trelation.nowk1
               gl_workflow.noworkflow2  = trelation.nowk2
               gl_workflow.dtcsy        = today
               gl_workflow.hecsy        = mtime
               gl_workflow.cdcsy        = "initworkflow" 
               gl_workflow.dtmsy        = today
               gl_workflow.hemsy        = mtime
               gl_workflow.cdmsy        = "initworkflow". 
    end.     

end procedure. 

procedure initsiteweb. 

    def var wsite as character no-undo. 
    def var i as integer no-undo. 
    
    wsite = " 00001 , la-gi.fr           ,                    " + ";" + 
            " 00002 , BellesDemeures.com , bellesdemeures.png " + ";" + 
            " 00003 , BienIci.com        , bienici.png        " + ";" + 
            " 00004 , Explorimmo.com     , explorimmo.png     " + ";" + 
/*          " 00005 , Logic-immo.com     , logicimmo.png      " + ";" +    */ 
            " 00006 , SeLoger.com        , seloger.png        "
    .  
  
    for each gl_siteweb:
        delete gl_siteweb.
    end. 

    do i = 1 to 5: 

        create gl_siteweb. 
        assign gl_siteweb.nositeweb    = integer(entry(1 ,entry(i ,wsite ,";"))) 
               gl_siteweb.dtcsy        = today
               gl_siteweb.hecsy        = mtime
               gl_siteweb.cdcsy        = "initsiteweb" 
               gl_siteweb.dtmsy        = today
               gl_siteweb.hemsy        = mtime
               gl_siteweb.cdmsy        = "initsiteweb"
               gl_siteweb.nom          = trim(entry(2 ,entry(i ,wsite ,";")))      
               gl_siteweb.cheminlogo   = trim(entry(3 ,entry(i ,wsite ,";"))).   
                      
    end. 
             
end procedure. 

procedure initbareme:

    def var wbareme as character no-undo.
    def var wcalcbar as character no-undo. 
    def var i as integer no-undo. 
    wbareme = "1 , 22 , Standard  " + ";" + 
              "2 , 22 , BNPP REIM " + ";" + 
              "3 , 19 , Standard  " + ";" + 
              "4 , 19 , BNPP REIM "
    . 
    wcalcbar = "1 , 3 , 20 , 0 , 3.333*[surfm2]    , 4.00*[surfm2] , ttc , 50202 " + ";" +
               "1 , 2 , 20 , 0 , 2.50*[surfm2]     , 3.00*[surfm2] , ttc , 50202 " + ";" +
               "1 , 1 , 20 , 0 , 1.666*[surfm2]    , 2.00*[surfm2] , ttc , 50202 " + ";" +
               "1 ,   , 20 , 0 , 2.50*[surfm2]     , 3.00*[surfm2] , ttc , 50203 " + ";" +
               "1 ,   , 20 , 1 , 3.25*[surfm2]     , 3.90*[surfm2] , ttc , 50203 " + ";" +     
               "1 ,   , 20 , 0 , 0.07*[loyerhc_an] ,               , ttc , 50201 " + ";" +       
               "3 , 3 , 20 , 0 , 3.333*[surfm2]    , 4.00*[surfm2] , ttc , 50102 " + ";" +
               "3 , 2 , 20 , 0 , 2.50*[surfm2]     , 3.00*[surfm2] , ttc , 50102 " + ";" +           
               "3 , 1 , 20 , 0 , 1.666*[surfm2]    , 2.00*[surfm2] , ttc , 50102 " + ";" +           
               "3 , 3 , 20 , 0 , 6.666*[surfm2]    , 8.00*[surfm2] , ttc , 50101 " + ";" +           
               "3 , 2 , 20 , 0 , 5.83*[surfm2]     , 7.00*[surfm2] , ttc , 50101 " + ";" +           
               "3 , 1 , 20 , 0 , 5.00*[surfm2]     , 6.00*[surfm2] , ttc , 50101 " + ";" +           
               "3 ,   , 20 , 0 , 2.50*[surfm2]     , 3.00*[surfm2] , ttc , 50103 " + ";" +                 
               "2 , 3 , 20 , 0 , 3.333*[surfm2]    , 4.00*[surfm2] , ttc , 50202 " + ";" +           
               "2 , 2 , 20 , 0 , 2.50*[surfm2]     , 3.00*[surfm2] , ttc , 50202 " + ";" +           
               "2 , 1 , 20 , 0 , 1.666*[surfm2]    , 2.00*[surfm2] , ttc , 50202 " + ";" +           
               "2 ,   , 20 , 0 , 0*[surfm2]        , 0*[surfm2]    , ttc , 50203 " + ";" +           
               "2 ,   , 20 , 1 , 0*[surfm2]        , 0*[surfm2]    , ttc , 50203 " + ";" +           
               "2 , 3 , 20 , 0 , 6.666*[surfm2]    , 8.00*[surfm2] , ttc , 50201 " + ";" +           
               "2 , 2 , 20 , 0 , 5.83*[surfm2]     , 7.00*[surfm2] , ttc , 50201 " + ";" +           
               "2 , 1 , 20 , 0 , 5.00*[surfm2]     , 6.00*[surfm2] , ttc , 50201 " + ";" +                  
               "4 , 3 , 20 , 0 , 3.333*[surfm2]    , 4.00*[surfm2] , ttc , 50102 " + ";" +                 
               "4 , 2 , 20 , 0 , 2.50*[surfm2]     , 3.00*[surfm2] , ttc , 50102 " + ";" +             
               "4 , 1 , 20 , 0 , 1.666*[surfm2]    , 2.00*[surfm2] , ttc , 50102 " + ";" +             
               "4 , 3 , 20 , 0 , 6.666*[surfm2]    , 8.00*[surfm2] , ttc , 50101 " + ";" +                 
               "4 , 2 , 20 , 0 , 5.83*[surfm2]     , 7.00*[surfm2] , ttc , 50101 " + ";" +             
               "4 , 1 , 20 , 0 , 5.00*[surfm2]     , 6.00*[surfm2] , ttc , 50101 " + ";" +             
               "4 ,   , 20 , 0 , 0*[surfm2]        , 0*[surfm2]    , ttc , 50103 "
    .              
                        
    for each gl_bareme:
        delete gl_bareme. 
    end. 
    for each gl_calcul_bareme:
        delete gl_calcul_bareme. 
    end. 

    do i = 1 to 4: 
        create gl_bareme.
        assign gl_bareme.dtcsy        = today
               gl_bareme.hecsy        = mtime
               gl_bareme.cdcsy        = "initbareme" 
               gl_bareme.dtmsy        = today
               gl_bareme.hemsy        = mtime
               gl_bareme.cdmsy        = "initbareme"
               gl_bareme.nobareme     = i
               gl_bareme.tphonoraire2 = integer(entry(2 ,entry(i ,wbareme ,";")))        
               gl_bareme.nom          = trim(entry(3 ,entry(i ,wbareme ,";")))     
        .
    end. 
    do i = 1 to 28:
        create gl_calcul_bareme. 
        assign gl_calcul_bareme.dtcsy           = today
               gl_calcul_bareme.hecsy           = mtime
               gl_calcul_bareme.cdcsy           = "initbareme" 
               gl_calcul_bareme.dtmsy           = today
               gl_calcul_bareme.hemsy           = mtime
               gl_calcul_bareme.cdmsy           = "initbareme"
               gl_calcul_bareme.nocalcul_bareme = i
               gl_calcul_bareme.nobareme        = integer(entry(1 ,entry(i ,wcalcbar,";"))) 
               gl_calcul_bareme.nozonealur      = integer(entry(2 ,entry(i ,wcalcbar ,";"))) 
               gl_calcul_bareme.notaxe          = integer(entry(3 ,entry(i ,wcalcbar ,";")))  
               gl_calcul_bareme.fgmeuble        = trim(entry(4 ,entry(i ,wcalcbar ,";"))) = "1"
               gl_calcul_bareme.baremeht        = trim(entry(5 ,entry(i ,wcalcbar ,";")))  
               gl_calcul_bareme.baremettc       = trim(entry(6 ,entry(i ,wcalcbar ,";")))  
               gl_calcul_bareme.typcalcul       = trim(entry(7 ,entry(i ,wcalcbar ,";")))
               gl_calcul_bareme.nochpfinance    = integer(entry(8 ,entry(i ,wcalcbar,";")))
        .  
    end. 
        
end procedure. 
    
