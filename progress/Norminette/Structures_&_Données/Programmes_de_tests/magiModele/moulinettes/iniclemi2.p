/*************************************************************************************/
/* Nom    	: IniCleMi2.p   (d'après IniCleMi.p du 05/11/2003 Fiche AGF : 0503/0068) */ 
/* Auteur 	: SY                                                                     */ 
/* Date		: 03/03/2017                                                             */ 
/* Objet	: Moulinette d'initialisation des champs tpcon/nocon dans clemi          */ 
/*		                                                                             */
/*************************************************************************************/

define variable fgMajTab as LOGICAL INIT YES no-undo.

DEFINE VARIABLE TpMdtUse	AS CHARACTER	NO-UNDO.
DEFINE VARIABLE NoMdtUse	AS INTEGER		NO-UNDO.

DEFINE BUFFER maj_clemi FOR clemi.

/* nettoyage clemi sans noimm */
IF FgMajTab THEn DO:
	FOR EACH clemi WHERE noimm = 0:
		DELETE clemi.
	END.
END.
		
FOR EACH clemi NO-LOCK
	WHERE clemi.tpcon = ""
	BREAK BY clemi.noimm:

	IF FIRST-OF (clemi.noimm) THEn Do: 
		ASSIGN
			TpMdtUse = ""
			NoMdtUse = 0
		.
		IF clemi.noimm > 10000 THEN DO:
			ASSIGN
				TpMdtUse = "01030"
				NoMdtUse = clemi.noimm - 10000
			.
		END.
		ELSE DO:
			TpMdtUse = "01003".
			FOR EACH intnt NO-LOCK 
				WHERE intnt.tpidt = "02001"
				AND   intnt.noidt = clemi.noimm
				AND   intnt.tpcon = TpMdtUse
				,FIRST ctrat NO-LOCK
				WHERE ctrat.tpcon = intnt.tpcon
				AND   ctrat.nocon = intnt.nocon
				BREAK BY ctrat.dtini:
				NoMdtUse = ctrat.nocon.
			END.			
		END.
	END.

	IF FgMajTab AND NoMdtUse > 0 THEN DO TRANSACTION:
		FIND maj_clemi WHERE ROWID(maj_clemi) = ROWID(clemi) NO-ERROR.
		IF AVAILABLE maj_clemi THEn DO:	
			ASSIGN
				maj_clemi.tpcon = TpMdtUse
				maj_clemi.nocon = NoMdtUse 
			.
		END.
	END.					
END.	


RETURN "1". /* <== dernière ligne du main block */
