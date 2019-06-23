/*************************************************************************************/
/* Nom    	: ini_erlet_nocon.p                                                      */ 
/* Auteur 	: SY                                                                     */ 
/* Date		: 13/04/2018                                                             */ 
/* Objet	: Moulinette de correction des champs tpcon/nocon dans erlet             */ 
/*		      pour les relevés de gérance créés par la copropriété (genrlger.p)      */
/*************************************************************************************/

define variable fgMajTab as LOGICAL INIT YES no-undo.

DEFINE VARIABLE TpMdtUse	AS CHARACTER	NO-UNDO.
DEFINE VARIABLE NoMdtUse	AS INTEGER		NO-UNDO.

DEFINE BUFFER maj_erlet FOR erlet.
		
FOR EACH erlet NO-LOCK
	WHERE erlet.noimm > 10000 
	and   erlet.tpcon <> "01030"
	BREAK BY erlet.noimm:

	IF FIRST-OF (erlet.noimm) THEn Do: 
		ASSIGN
			TpMdtUse = "01030"
			NoMdtUse = erlet.noimm - 10000
		.
	END.

	IF FgMajTab AND NoMdtUse > 0 THEN DO TRANSACTION:
		FIND maj_erlet WHERE ROWID(maj_erlet) = ROWID(erlet) NO-ERROR.
		IF AVAILABLE maj_erlet THEn DO:	
			ASSIGN
				maj_erlet.tpcon = TpMdtUse
				maj_erlet.nocon = NoMdtUse
				maj_erlet.dtmsy = TODAY
				maj_erlet.hemsy = time
				maj_erlet.cdmsy = "ini_erlet_nocon.p"
			.
		END.
	END.					
END.	


RETURN "1". /* <== dernière ligne du main block */
