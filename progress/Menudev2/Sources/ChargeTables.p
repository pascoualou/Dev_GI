/*---------------------------------------------------------------------------
 Application      : MENUDEV2
 Programme        : ChargeTables.p
 Objet            : Chargement des tables d'une base via le métaschema
*---------------------------------------------------------------------------
 Date de création : 16/03/2009
 Auteur(s)        : PL
 Dossier analyse  : 
*---------------------------------------------------------------------------
 Entrée :
 Sortie :
 Appel  :
*---------------------------------------------------------------------------
 Modifications :
 ....   ../../....    ....  

*--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
DEFINE VARIABLE cLibelleTempo           AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cLibelle1               AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cLibelle2               AS CHARACTER    NO-UNDO.
DEFINE VARIABLE rcIndexPrimaire	        AS RECID	    NO-UNDO.
DEFINE VARIABLE cLibelleIndexTempo      AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cLibelleIndexTempo2     AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cLibelleIndexEnCours    AS CHARACTER    NO-UNDO.

{menudev2\includes\tables.i}

/*-------------------------------------------------------------------------*
 | MAIN BLOCK                                                              |
 *-------------------------------------------------------------------------*/
/* Chargement des tables */
FOR EACH _file WHERE NOT(_file._hidden):
    CREATE ttTables.
    /* Au passage, on conserve le recid de l'index primaire */
	rcIndexPrimaire = _file._prime-index.
	
    ttTables.cBase = LDBNAME("dictdb").
    ttTables.cnom = CAPS(_file._file-name).
	cLibelle1 = TRIM(_file._file-label).
	cLibelle2 = TRIM(_file._desc).
	IF cLibelle1 = ? THEN cLibelle1 = "".
	IF cLibelle2 = ? THEN cLibelle2 = "".
	IF cLibelle1 = "" OR cLibelle1 = cLibelle2 THEN DO:
	    cLibelle1 = cLibelle2.
	    cLibelle2 = "".
	END.
	cLibelle1 = REPLACE(cLibelle1,CHR(10)," ").
	cLibelle1 = REPLACE(cLibelle1,CHR(13)," ").
	cLibelle1 = REPLACE(cLibelle1,"  "," ").
	cLibelle2 = REPLACE(cLibelle2,CHR(10)," ").
	cLibelle2 = REPLACE(cLibelle2,CHR(13)," ").
	cLibelle2 = REPLACE(cLibelle2,"  "," ").
    tttables.clibelle = (IF cLibelle1 <> "" THEN cLibelle1 + (IF clibelle2 <> "" THEN " - " ELSE "") ELSE "") + (IF clibelle2 <> "" THEN cLibelle2 ELSE "").

    /* Chargement des champs */    
    FOR EACH _field OF _file BY _field._order :
        CREATE ttChamps.
        ASSIGN
        ttchamps.ctable = _file._file-name
        ttchamps.cnom = _field._field-name
        ttchamps.iordre = _field._order
        ttchamps.clabel = _field._label
        ttchamps.ctype = STRING(_field._data-type,"xxxx") +
    		(IF (_field._decimals <> ? and _field._decimals <> 0) THEN "-" + STRING(_field._decimals) ELSE "") +
    		(IF (_field._extent <> ? and _field._extent <> 0) THEN "[" + STRING(_field._extent) + "]" ELSE "")
        
        ttchamps.cFormat = STRING(_field._format,"x(20)") 
        ttchamps.cInitial = STRING((IF _field._initial <> ? THEN _field._initial ELSE "?"),"x(10)")
        .
        IF ttchamps.clabel = ? OR ttchamps.clabel = "" THEN ttchamps.clabel = _field._desc.
        IF ttchamps.clabel = ? OR ttchamps.clabel = "" THEN ttchamps.clabel = "?.?.?".
        
        IF NOT(ttchamps.clabel = _field._desc) THEN 
            ttchamps.cRemarque = _field._desc.
            
        ttchamps.iextent = (IF (_field._extent <> ? and _field._extent <> 0) THEN _field._extent ELSE 0).
    END.

    /* Chargement des indexes */
    FOR EACH _index WHERE _index._file-recid = recid(_file) BY _index._index-name:
    	CREATE ttindexes.
        ttindexes.ctable = _file._file-name.
    	ttindexes.cnom = STRING(_index._index-name ,"x(21)").
    	cLibelleIndexTempo = "" 
        	+ " (" 
    		+ (IF rcIndexPrimaire = RECID(_index) THEN "P" ELSE "")
    		+ (IF _index._unique = TRUE THEN "U" ELSE "")
    		+ (IF _index._active = TRUE THEN "A" ELSE "")
    		+ ") =".
    	ttindexes.cDescription = cLibelleIndexTempo.
    	cLibelleIndexTempo2 = "".
    	FOR each _index-field WHERE _index-field._index-recid = recid(_index):
    		FIND FIRST _field WHERE recid(_field) = _index-field._field-recid
    		NO-ERROR.
    		IF AVAILABLE(_field) THEN DO:
    			cLibelleIndexEnCours = _field._field-name + "(" + (IF _index-field._ascending = TRUE THEN "A" ELSE "D") + ") ".
    			cLibelleIndexTempo2 = cLibelleIndexTempo2 + "+ " + cLibelleIndexEnCours.
    		END.
    	END.
    	ttindexes.cDescription = ttindexes.cDescription + SUBSTRING(cLibelleIndexTempo2,2).
    END.
END.
