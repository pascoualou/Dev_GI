/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ATTENTION : 
Ce fichier doit être recopié dans le repertoire d'intallation de progress
sur chaque machine 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

/* Affectations des variables */
ASSIGN
	Disque 	= os-getenv("disque")
	Reseau 	= os-getenv("reseau")
	Util	= os-getenv("devusr")
	dlc	= os-getenv("DLC")
	windows	= os-getenv("windir")
	.

GET-KEY-VALUE SECTION "Outils" KEY "Serveur" 		VALUE Serveur.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_Appli" 		VALUE Ser_appli.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_Appdev"		VALUE Ser_appdev.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_outils" 	VALUE Ser_Outils.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_tmp" 		VALUE Ser_tmp.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_log" 		VALUE Ser_Log.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_intf" 		VALUE Ser_intf.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_dat" 		VALUE ser_dat.

GET-KEY-VALUE SECTION "Outils" KEY "Rep_outils" 	VALUE Loc_Outils.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_Appli" 		VALUE Loc_appli.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_Appdev"		VALUE Loc_appdev.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_tmp" 		VALUE Loc_tmp.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_log" 		VALUE Loc_Log.
GET-KEY-VALUE SECTION "Outils" KEY "Rep_intf" 		VALUE Loc_intf.

GET-KEY-VALUE SECTION "Outils" KEY "imp_dev" 		VALUE imprimante.

ASSIGN
	ser_outils = reseau + ser_outils
	ser_outadb = ser_outils + "\adb"
	ser_outgest = ser_outils + "\gest"
	ser_outcadb = ser_outils + "\cadb"
	ser_outtrans = ser_outils + "\trans"
	ser_appli = reseau + ser_appli
	ser_appdev = reseau + ser_appdev
	ser_tmp = reseau + ser_tmp
	ser_log = reseau + ser_log
	ser_intf = reseau + ser_intf
	ser_dat = reseau + ser_dat
	loc_outils = Disque + loc_outils
	loc_outadb = loc_outils + "\adb"
	loc_outgest = loc_outils + "\gest"
	loc_outcadb = loc_outils + "\cadb"
	loc_outtrans = loc_outils + "\trans"
	loc_appli = disque + loc_appli
	loc_appdev = disque + loc_appdev
	loc_tmp = disque + loc_tmp
	loc_log = disque + loc_log
	loc_intf = disque + loc_intf
	.

ASSIGN
	RpOriGi = ser_appli
	RpDesGi = Loc_appli
	RpOriadb = ser_appli + "\adb"
	RpDesadb = Loc_appli + "\adb"
	RpOriges = ser_appli + "\gest"
	RpDesges = Loc_appli + "\gest"
	RpOricad = ser_appli + "\cadb"
	RpDescad = Loc_appli + "\cadb"
	RpOritrf = ser_appli + "\trans"
	RpDestrf = Loc_appli + "\trans"
	.

/* le propath est retravaillé apres pour remplacer LOC par le disque local courant et SRV avec le disque serveur courant */
ASSIGN
	PMEPATH = "" +
		"LOC:\gidev," +
		"SRV:\gidev," +
		"LOC:\gidev\gest," +
		"LOC:\gidev\gest\src," +
		"LOC:\gidev\gest\comm," +
		"LOC:\gidev\gest\exe," +
		"LOC:\gidev\gest\src\batch," +
		"SRV:\gidev\gest," +
		"SRV:\gidev\gest\src," +
		"SRV:\gidev\gest\comm," +
		"SRV:\gidev\gest\exe," +
		"SRV:\gidev\gest\src\batch"
	CDBPATH = "" +
		"LOC:\gidev," +
		"SRV:\gidev," +
		"LOC:\gidev\cadb," +
		"LOC:\gidev\cadb\src," +
		"LOC:\gidev\cadb\comm," +
		"LOC:\gidev\cadb\exe," +
		"SRV:\gidev\cadb," +
		"SRV:\gidev\cadb\src," +
		"SRV:\gidev\cadb\comm," +
		"SRV:\gidev\cadb\exe," +
		"LOC:\gidev\gest," +
		"LOC:\gidev\gest\src," +
		"LOC:\gidev\gest\comm," +
		"LOC:\gidev\gest\exe," +
		"LOC:\gidev\cadb\src\batch," +
		"LOC:\gidev\gest\src\batch," +
		"SRV:\gidev\gest," +
		"SRV:\gidev\gest\src," +
		"SRV:\gidev\gest\comm," +
		"SRV:\gidev\gest\exe," +
		"SRV:\gidev\cadb\src\batch," +
		"SRV:\gidev\gest\src\batch"
/*------
	ADBPATH = "" +
		"DLC:\src," +
		"DLC:\src\prodict.pl," +
		"LOC:\gidev," +
		"LOC:\gidev\src," +
		"LOC:\gidev\gest," +
		"LOC:\gidev\comm," +
		"LOC:\gidev\trans\comm," +
		"LOC:\gidev\adb\comm," +
		"LOC:\gidev\dwh\comm," +
		"LOC:\gidev\trans\src\incl," +
		"LOC:\gidev\adb\objet," +
		"LOC:\gidev\adb\src\envt," +
		"LOC:\gidev\trans\src\edigene," +
		"LOC:\gidev\trans\src\lecture," +
		"LOC:\gidev\cadb," +
		"LOC:\gidev\cadb\src," +
		"LOC:\gidev\cadb\src\batch," +
		"SRV:\gidev\trans\src\incl," +
		"SRV:\gidev\cadb," +
		"SRV:\gidev\cadb\src," +
		"SRV:\gidev\cadb\src\batch," +
		"LOC:\gidev\adb," +
		"LOC:\gidev\dwh," + 
		"LOC:\gidev\gest\src," +
		"LOC:\gidev\adb," +
		"LOC:\gidev\adb\src"
----*/
	ADBPATH = "" +
		"DLC:\src," +
		"DLC:\src\prodict.pl," +
		"LOC:\gidev," +
		"SRV:\gidev," +
		"LOC:\gidev\src," +
		"SRV:\gidev\src," +
		"LOC:\gidev\gest," +
		"SRV:\gidev\gest," +
		"LOC:\gidev\comm," +
		"SRV:\gidev\comm," +
		"LOC:\gidev\trans\comm," +
		"SRV:\gidev\trans\comm," +
		"LOC:\gidev\adb\comm," +
		"SRV:\gidev\adb\comm," +
		"LOC:\gidev\dwh\comm," +
		"SRV:\gidev\dwh\comm," +
		"LOC:\gidev\trans\src\incl," +
		"SRV:\gidev\trans\src\incl," +
		"LOC:\gidev\adb\objet," +
		"SRV:\gidev\adb\objet," +
		"LOC:\gidev\adb\src\envt," +
		"SRV:\gidev\adb\src\envt," +
		"LOC:\gidev\trans\src\edigene," +
		"SRV:\gidev\trans\src\edigene," +
		"LOC:\gidev\trans\src\lecture," +
		"SRV:\gidev\trans\src\lecture," +
		"LOC:\gidev\cadb," +
		"SRV:\gidev\cadb," +
		"LOC:\gidev\cadb\src," +
		"SRV:\gidev\cadb\src," +
		"LOC:\gidev\cadb\src\batch," +
		"SRV:\gidev\cadb\src\batch," +
		"LOC:\gidev\adb," +
		"SRV:\gidev\adb," +
		"LOC:\gidev\dwh," + 
		"SRV:\gidev\dwh," + 
		"LOC:\gidev\gest\src," +
		"SRV:\gidev\gest\src," +
		"LOC:\gidev\adb\src," +
		"SRV:\gidev\adb\src"
	DROITPATH = "" +
		"DLC:\src," +
		"DLC:\src\prodict.pl," +
		"LOC:\gidev\src," +
		"LOC:\gidev\gest," +
		"LOC:\gidev\gest\src," +
		"LOC:\gidev\gest\comm," +
		"LOC:\gidev\gest\src\batch," +
		"LOC:\gidev\comm," +
		"SRV:\gidev\src," +
		"SRV:\gidev\gest," +
		"SRV:\gidev\gest\src," +
		"SRV:\gidev\gest\comm," +
		"SRV:\gidev\gest\src\batch," +
		"SRV:\gidev\comm," +
		"LOC:\gidev," +
		"SRV:\gidev"
		.
ASSIGN
	PMEPATH = REPLACE(PMEPATH,"LOC:\",disque).
	PMEPATH = REPLACE(PMEPATH,"SRV:\",reseau).
	PMEPATH = REPLACE(PMEPATH,"DLC:",dlc).
	CDBPATH = REPLACE(CDBPATH,"LOC:\",disque).
	CDBPATH = REPLACE(CDBPATH,"SRV:\",reseau).
	CDBPATH = REPLACE(CDBPATH,"DLC:",dlc).
	ADBPATH = REPLACE(ADBPATH,"LOC:\",disque).
	ADBPATH = REPLACE(ADBPATH,"SRV:\",reseau).
	ADBPATH = REPLACE(ADBPATH,"DLC:",dlc).
	DROITPATH = REPLACE(DROITPATH,"LOC:\",disque).
	DROITPATH = REPLACE(DROITPATH,"SRV:\",reseau).
	DROITPATH = REPLACE(DROITPATH,"DLC:",dlc).
	.
