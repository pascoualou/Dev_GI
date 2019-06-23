/*--------------------------------------------------------------------------*
| Programme        : i_gi.i                                                 |
| Objet            : Gestion de l'environnement GI                          |
|---------------------------------------------------------------------------|
| Date de création : 12/05/2010                                             |
| Auteur(s)        : PL                                                     |
*---------------------------------------------------------------------------*
*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  Nø  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| .... | ../../.... |  ....  | .                                            |
|      |            |        |                                              |
*--------------------------------------------------------------------------*/

DEFINE {1} SHARED VARIABLE  Util            As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Disque          As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Reseau          As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  nfs             As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  dlc             As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  windows         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Serveur         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Ser_appli       As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Ser_outils      As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Ser_outils_Son  As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Ser_dat         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Ser_outadb      As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Ser_tmp         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Ser_log         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Ser_intf        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Loc_outils      As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Loc_dat         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Loc_outadb      As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Loc_appli       As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Loc_tmp         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Loc_log         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  Loc_intf        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpOriGi         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpDesGi         As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpOriadb        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpDesadb        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpOriges        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpDesges        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpOritrf        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpDestrf        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpOricad        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  RpDescad        As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  imprimante      As CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE  cRepertoireIni  As CHARACTER NO-UNDO.


/* Lecture d'une clé dans le fichier .ini */
FUNCTION Lit_cle RETURNS CHARACTER (cFichierIni AS CHARACTER, cSection AS CHARACTER, cCle AS CHARACTER):
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.

	LOAD cFichierIni DIR cRepertoireIni NO-ERROR.
	USE cFichierIni .
    
    cRetour = "".
    
    GET-KEY-VALUE SECTION cSection KEY cCle	VALUE cRetour.
    
    RETURN cRetour.
    
END FUNCTION.

/* Récupération de l'environnement de développement Progress-GI */
PROCEDURE RecupereEnvironnementGI:
    
    Disque = OS-GETENV("disque").
    Reseau = OS-GETENV("reseau").
    Util = OS-GETENV("devusr").
    dlc = OS-GETENV("DLC").
    windows = OS-GETENV("windir").
    cRepertoireIni = windows.
    Serveur = Lit_cle("outilsgi.ini", "Outils", "Serveur").
    nfs = Lit_cle("outilsgi.ini", "Outils", "nfs").
    Ser_appli = Lit_cle("outilsgi.ini", "Outils", "Rep_Appli").
    Ser_outils = Lit_cle("outilsgi.ini", "Outils", "Rep_outils").
    Ser_tmp = Lit_cle("outilsgi.ini", "Outils", "Rep_tmp").
    Ser_log = Lit_cle("outilsgi.ini", "Outils", "Rep_log").
    Ser_intf = Lit_cle("outilsgi.ini", "Outils", "Rep_intf").
    Ser_dat = Lit_cle("outilsgi.ini", "Outils", "Rep_dat").
    Loc_outils = Lit_cle("outilsgi.ini", "Outils", "Rep_outils").
    Loc_appli = Lit_cle("outilsgi.ini", "Outils", "Rep_Appli").
    Loc_tmp = Lit_cle("outilsgi.ini", "Outils", "Rep_tmp").
    Loc_log = Lit_cle("outilsgi.ini", "Outils", "Rep_log").
    Loc_intf = Lit_cle("outilsgi.ini", "Outils", "Rep_intf").
    imprimante = Lit_cle("outilsgi.ini", "Outils", "imp_dev").

    ASSIGN
    Ser_outils = Reseau + Ser_outils
    Ser_outadb = Ser_outils + "\adb"
    Ser_appli = Reseau + Ser_appli
    Ser_tmp = Reseau + Ser_tmp
    Ser_log = Reseau + Ser_log
    Ser_intf = Reseau + Ser_intf
    Ser_dat = Reseau + Ser_dat
    Loc_outils = Disque + Loc_outils
    Loc_outadb = Loc_outils + "\adb"
    Loc_appli = Disque + Loc_appli
    Loc_tmp = Disque + Loc_tmp
    Loc_log = Disque + Loc_log
    Loc_intf = Disque + Loc_intf
    RpOriGi = Ser_appli
    RpDesGi = Loc_appli
    RpOriadb = Ser_appli + "\adb"
    RpDesadb = Loc_appli + "\adb"
    RpOriges = Ser_appli + "\gest"
    RpDesges = Loc_appli + "\gest"
    RpOricad = Ser_appli + "\cadb"
    RpDescad = Loc_appli + "\cadb"
    RpOritrf = Ser_appli + "\trans"
    RpDestrf = Loc_appli + "\trans"
    
    Ser_outils_Son = Ser_outils + "\sons"
    .
    
 END PROCEDURE.
