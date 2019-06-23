/*------------------------------------------------------------------------
File        : loadMagiMenuEtTraduction.p
Purpose     :
Description : 
Author(s)   : kantena - 2016/02/09
Notes       :
Tables      : BASE ladb : sys_lb sys_rf
              BASE magi : menuWeb
----------------------------------------------------------------------*/
/*
define variable cMessageImmeuble as character no-undo initial "
211637,0,Tous les lots du copropri�taire sont vendus: Date de fin [&1] incorrecte.;
211638,0,Sur les lots du copropri�taire: Date d'achat [&1] incorrecte.;
211639,0,Immeuble: [&1] Erreur chargement travaux manuels (04259)[&2][&3]/[&4];
211641,0,LuMaMeJeVeSaDi;
211641,1,MoTuWeThFrSaSu;
211650,0,modification de l'enregistrement [&1] impossible. Une modification a �t� faite par un autre utilisateur [&2].;
211651,0,modification de l'enregistrement [&1] impossible. Enregistrement supprim� par un autre utilisateur.;
211652,0,modification de l'enregistrement [&1] impossible. Enregistrement verrouill� par un autre utilisateur.;
211653,0,Enregistrement &1 non trouv�.;
211654,0,Pas de b�timent pour l'immeuble [&1].;
211655,0,Ne peut pas cr�er un nouvel immeuble. Dernier N� de s�quence atteint.;
211656,0,Mandat %1 introuvable.;
211657,0,Nature de Contrat Mandat inconnue: [&1].;
211658,0,Impossible de trouver une s�quence valide pour [&1].;
211659,0,Echec de la proc�dure [&1].;
211660,0,Proc�dure [&1] non trouv�e.;
211661,0,Probl�me de suppression dossier travaux [&1].;
211662,0,Suppression impossible. Il y a des �critures comptables sur ce dossier ([&1] [&2] du [&3]);
211663,0,Gestion des fournisseurs de loyer. La tranche immeuble de cette r�f�rence commence � 2001.;
211664,0,Gestion des fournisseurs de loyer. Ce n� immeuble est trop grand. Le mandat location associ� � ce n� immeuble serait [&1]. Il faut modifier le param�trage des fournisseurs de loyer (max = [&2]);
211665,0,Gestion des fournisseurs de loyer. Ce n� immeuble est trop grand. Le mandat location associ� � ce n� immeuble serait [&1]. Il faut ouvrir le module optionnel de gestion des mandats sur 5 chiffres.;                                 
211666,0,Gestion des fournisseurs de loyer. N� immeuble interdit. Le mandat location associ� � ce n� immeuble serait [&1]. Mais ce n� mandat exite d�j� en comptabilit� Gestion ADB.;                                      
211667,0,Gestion des fournisseurs de loyer. Le N� immeuble [&1] est r�serv� aux mandats de sous-location. Confirmez-vous ?;
211668,0,Nombre maximum d'enregistrements atteint (maxi [&1]).;
211669,0,Contrat non trouv� pour type/num�ro ([&1]/[&2]) de mandat.;
211670,0,Signalant N� [&1] non trouv�.;
211671,0,Immeuble N� [&1] non trouv�.;
211672,0,Le montant [&1] de la ligne d�tail ne correspond pas au prixUnitaire[&2] * quantit�[&3] * (1 + tauxTVA[&4]).;
211673,0,Vous n'�tes pas habilit� � cr�er/modifier un OS d'un montant [&1]. Votre plafond est de [&2].\rSouhaitez-vous malgr� tout initialiser l'OS ?;
211674,0,Modification impossible d'un ordre de service bon � payer.;
211675,0,Le Prix Unitaire d'une ligne OS doit �tre sup�rieur � z�ro.;
211676,0,Immeuble non trouv� pour num�ro [&1] d'immeuble.;
211677,0,L'immeuble [&1] n'est pas celui du mandat de type[&2], de num�ro [&3].;
211678,0,Le fournisseur [&1] [&2] est inactif. Saisie impossible.;
211679,0,Impossible d'utiliser un fournisseur [&1] [&2] non r�f�renc�.;
211680,0,Le fournisseur [&1] [&2] n'est pas r�f�renc�.;
211681,0,Modification/Suppression impossible car il existe une facture sur cet ordre de service.;
211682,0,Suppression d'un ordre de service impossible s'il existe un appel sans r�ponse vot�.;
211683,0,Format date incorrect pour la date [&1], en format [&2], objet:[&3].;
211684,0,Les �l�ments saisis renvoient trop de lignes. Les [&1] premi�res lignes sont affich�es.;
211685,0,Vous n'avez pas les droits vous permettant de voter cette r�ponse de devis.;
211686,0,Attention un autre devis a �t� accept�. Confirmez-vous votre choix ?;
211687,0,Ce devis a-t-il �t� vot� par l'Assembl�e G�n�rale ?;
211688,0,Ce devis a-t-il �t� vot� par le Conseil Syndical ?;
211689,0,Ce devis a-t-il �t� accept� par le Propri�taire ?;
211690,0,Ce devis a-t-il �t� accept� par le Gestionnaire du mandat ?;
211691,0,La vue demand�e [&1] est inexistante.;
211692,0,Attention date d'ach�vement inf�rieur � 2 ans. Voulez-vous forcer pour travaux urgent et appliquer la TVA � [&1] ?|Non:Non#Oui;
211700,0,Il existe un suivi devis sur ce devis.;
211701,0,Il existe un ordre de service sur ce devis.;
211702,0,Il existe une facture sur ce devis.;
211703,0,Il existe une reponse vot� avec un appel de fonds.;
211704,0,Il existe un detail devis sur au moins une intervention.;
211705,0,Il existe un suivi devis sur au moins une intervention.;
211706,0,Il existe un ordre de service sur au moins une intervention.;
211707,0,Il existe une facture sur au moins une intervention.;
211708,0,Le format horaire est xx:yy avec xx entre [00,23] et yy entre [00,59];
211709,0,Mandat &1 ou Unit� de Location &2 inconnu.;
1000177,0,Th�me;
1000086,0,Utilisateur &1 inexistant;
1000094,0,BAP;
1000101,0,Cl�turer;
1000119,0,Effacer;
1000132,0,Libell� Dossier;
1000143,0,N� Dossier;
1000149,0,N� Devis;
1000150,0,N� Traitement;
1000167,0,Recherche avanc�e;
1000168,0,Rechercher;
1000190,0,Le fournisseur &1 est inactif.;
1000191,0,Le fournisseur &1 n'est pas r�f�renc�, voulez-vous continuer ?;
1000192,0,Impossible d'utiliser un fournisseur non r�f�renc�.;
1000193,0,Vot� par le gestionnaire du mandat;
1000194,0,Vot� par le propri�taire;
1000195,0,Vote gest.;
1000196,0,Vot� par le conseil syndical;
1000197,0,Vot� en assembl�e g�n�rale;
1000200,0,Param�tre &1 incorrect;
1000201,0,Suppression non autoris�e;
1000202,0,Modification non autoris�e;
1000203,0,Th�me ged &1 inexistant;
1000204,0,Th�me Giextranet &1 inexistant;
1000205,0,Objet obligatoire;
1000206,0,Tiers &1 introuvable;
1000207,0,&1 obligatoire;
1000208,0,Role &1 inexistant;
1000209,0,Contrat &1 inexistant;
1000210,0,&1 inexistant;
1000211,0,Ce mandat n'est pas rattach� � cet immeuble;
1000212,0,Le lot est renseign� mais pas l'immeuble;
1000213,0,Ce lot n'est pas rattach� � cet immeuble;
1000214,0,Type de document;
1000215,0,&1 inexistante;
1000216,0,Le contrat fournisseur est renseign� mais pas le mandat;
1000217,0,L'identifiant-mot de passe de Gidemat n'est pas param�tr�;
1000218,0,Connection � gidemat impossible avec l'utilisateur &1;
1000219,0,Erreur WS updateResource : &1;
1000220,0,Resid &1 Champs &2 non modifiable dans gidemat;
1000228,0,Mise � jour impossible de [&1];
1000229,0,Cr�ation non autoris�e;
1000230,0,Erreur identifiant ged &1 &2 &3;
1000231,0,R�f�rence client Gidemat non renseign�e;
1000232,0,Contenu du fichier vide;
1000233,0,Fichier &1 extension non autoris�e;
1000234,0,Erreur de copie du fichier &1 vers &2 &3;
1000235,0,Impossible de cr�er le fichier &1;
1000236,0,Le r�pertoire &1 n'existe pas;
1000237,0,Erreur en suppression du fichier &1;
1000238,0,Erreur en suppression du r�pertoire &1;
1000239,0,Erreur en cr�ation du dossier &1;
1000240,0,Erreur en cr�ation de l'archive &1;
1000241,0,Commande &1;
1000242,0,Type de document &1 inexistant;
1000243,0,Le fichier &1 est inexistant;
1000244,0,Taille du fichier &1 (&2 Mo) sup�rieure au maximum autoris� (&3 Mo);
1000245,0,ID GED &1 inexistant;
1000246,0,Taille du fichier � transf�rer &1 (&2 Mo) sup�rieure au maximum autoris� (&3 Mo);
1000247,0,L'identifiant et le mot de passe de l'acc�s Gidemat ne sont pas param�tr�s;
1000248,0,Connection � gidemat impossible avec l'utilisateur &1;
1000249,0,Erreur fichier &1 Identifiant &2;
1000250,0,Erreur &1 &2 &3;
1000251,0,Identifiant GED &1 fichier &2 transf�r�;
1000252,0,Fichier GED &1 supprim�;
1000253,0,Impossible d'acc�der au fichier &1;
1000254,0,Mise � jour effectu�e;
1000255,0,Le param�tre &1 n'est pas renseign� &2 &3;
1000256,0,Mise � jour effectu�e &1;
1000257,0,Identifiant GED &1;
1000258,0,R�pertoire de scan &1 d�j� existant;
1000259,0,Nom du r�pertoire de scan non renseign�;
1000260,0,Chemin scanner du dossier &1 non renseign�;
1000261,0,Chemin de la corbeille dossier &1 non renseign�;
1000262,0,Dossier &1 d�j� existant;
1000263,0,Suppression effectu�e;
1000264,0,Dossier scanner &1 inexistant;
1000265,0,Ce traitement est d�j� cl�tur�.;
1000266,0,Vous n'�tes pas habilit� � passer les OS en Bon � Payer;
1000267,0,Confirmez-vous la r�ception des travaux ?;
1000268,0,num�ro de proximit� &1 inexistant;
1000269,0,proximit� &1 d�j� existante avec num�ro de libell� &2 diff�rent;
1000270,0,proximit� &1 d�j� existante avec type de proximit� &2 diff�rent;
1000271,0,libell� obligatoire pour cr�ation proximit�;
1000272,0,proximit� obligatoire en cas d'utilisation de libell� existant;
1000273,0,site web &1 inexistant;
1000274,0,attribut divers &1 inexistant;
1000275,0,la limite du nombre d'appel pour une fiche par jour est atteinte;
1000276,0,adresse obligatoire pour appel service encadrement loyer;
1000277,0,nombre de pi�ce obligatoire pour appel service encadrement loyer;
1000278,0,ann�e de construction obligatoire pour appel service encadrement loyer;
1000279,0,loyer au m�tre carr� obligatoire pour appel service encadrement loyer;
1000280,0,code famille de r�le inexistant pour famille &1 et r�le &2;
1000281,0,creation interdite loyer &1 deja existant cette fiche;
1000282,0,id champ finance &1 inexistant;
1000283,0,id champ finance &1 deja existant sous cette fiche;
1000284,0,id champ finance &1 plusieurs fois dans table mise � jour;
1000285,0,supression enregistrement table &1 impossible. Enregistrement verrouill� par un autre utilisateur;
1000286,0,creation interdite d�p�t &1 deja existant cette fiche;
1000287,0,en cr�ation de d�tail finance le num�ro doit �tre � 0;
1000288,0,numero de d�pot inexistant;
1000289,0,numero de loyer inexistant;
1000290,0,numero d'honoraire inexistant;
1000291,0,creation interdite honoraire &1 deja existant cette fiche;
1000292,0,les informations en retour du webservice ne sont pas de type json;
1000293,0,le chargement du json a echou�;
1000294,0,probl�me sur l'appel du web service;
1000295,0,code retour appel websevice incorrect : &1;
1000296,0,type de tiers &1 deja existant pour cette fiche; 
1000297,0,combinaison type r�le num�ro r�le inexistante;
1000298,0,tiers &1 inexistant;
1000299,0,fournisseur &1 inexistant;
1000300,0,Dossier corbeille &1 inexistant;
1000302,0,Versement effectu�;
1000303,0,&1 versements effectu�s
"
.
*/
/*
define variable cMessageLot as character no-undo initial " 
211653,0,Erreur de date.
".

define variable cheader as longchar no-undo initial '
901955,0,"Retour accueil","web_header";
901956,0,"Mon profil","web_header";
901957,0,"D�connexion","web_header"
'.
define variable cintervention as longchar no-undo initial '
100768,0,"Code","web_interventions";
901944,0,"Libell� intervention","web_interventions";
901946,0,"Fin pr�vue","web_interventions";
101609,0,"Commentaire","web_interventions";
100745,0,"Quantit�","web_interventions";
100778,0,"P.U.","web_interventions";
103508,0,"h.t.","web_interventions";
901947,0,"T.V.A","web_interventions";
400002,0,"T.T.C","web_interventions";
901948,0,"Total HT","web_interventions";
168   ,0,"TVA","web_interventions";
901949,0,"Total TTC","web_interventions";
901950,0,"Motif de cl�ture","web_interventions";
100114,0,"Type","web_interventions";
103265,0,"Statut","web_interventions";
100302,0,"Mandat","web_interventions";
101206,0,"Immeuble","web_interventions";
100067,0,"Dur�e","web_interventions";
100124,0,"Fournisseur","web_interventions";
107561,0,"Utilisateur","web_interventions";
901951,0,"Upload","web_interventions";
107605,0,"Fichier","web_interventions";
900337,0,"Fermer","web_interventions";
107601,0,"Signalement","web_interventions";
107729,0,"Demande de Devis","web_interventions";
901952,0,"Cl�ture intervention","web_interventions";
901953,0,"R�ponse du fournisseur","web_interventions";
901954,0,"Duplication du devis","web_interventions"
'.
define variable cddedevis as longchar no-undo initial '
107729,0,"Demande de Devis","web_demandedevis";
901958,0,"Concern�","web_demandedevis";
901959,0,"Personne � contacter","web_demandedevis";
100124,0,"Fournisseur","web_demandedevis";
102645,0,"D�tail","web_demandedevis";
901960,0,"Code Intervention","web_demandedevis";
901961,0,"Titre Intervention","web_demandedevis";
101408,0,"Compl�ment","web_demandedevis";
103037,0,"d�lai","web_demandedevis";
110465,0,"Facturable �","web_demandedevis";
101985,0,"Liste des Copropri�taires","web_demandedevis";
901962,0,"Liste des Locataires","web_demandedevis";
104956,0,"Gestionnaire","web_demandedevis";
100032,0,"Cl�","web_demandedevis";
100465,0,"Mode","web_demandedevis";
901963,0,"Lots disponibles","web_demandedevis";
901964,0,"Valider","web_demandedevis";
900125,0,"Annuler","web_demandedevis";
901965,0,"S�lection Fournisseur","web_demandedevis";
104141,0,"Nom fournisseur","web_demandedevis";
248   ,0,"Adresse","web_demandedevis";
901966,0,"Coordonn�es","web_demandedevis";
901967,0,"Domaine Activit�","web_demandedevis";
901968,0,"R�f.","web_demandedevis";
901969,0,"Fournisseurs S�lectionn�s","web_demandedevis";
48    ,0,"N�","web_demandedevis";
100101,0,"Nom","web_demandedevis";
266   ,0,"Cp","web_demandedevis";
100555,0,"Ville","web_demandedevis";
104668,0,"Domaine","web_demandedevis";
901964,0,"Valider","web_demandedevis";
901970,0,"R�ponse Fournisseur","web_demandedevis";
901971,0,"N� suivi de devis","web_demandedevis";
107600,0,"Intervention","web_demandedevis"
'.
define variable cOrdreDeService as longchar no-undo initial '
702040,0,"Ordre de Service","web_ordredeservice";
901958,0,"Concern�","web_ordredeservice";
100124,0,"Fournisseur","web_ordredeservice";
110465,0,"Facturable �","web_ordredeservice";
701005,0,"R�le","web_ordredeservice";
101985,0,"Liste des Copropri�taires","web_ordredeservice";
901962,0,"Liste des Locataires","web_ordredeservice";
104956,0,"Gestionnaire","web_ordredeservice";
100032,0,"Cl�","web_ordredeservice";
100465,0,"Mode","web_ordredeservice";
901963,0,"Lots disponibles","web_ordredeservice";
901964,0,"Valider","web_ordredeservice";
900125,0,"Annuler","web_ordredeservice";
103037,0,"d�lai","web_ordredeservice";
107600,0,"Intervention","web_ordredeservice"
'.
define variable cSignalement as longchar no-undo initial '
107601,0,"Signalement","web_signalement";
901958,0,"Concern�","web_signalement";
901972,0,"Type Signalant","web_signalement";
900318,0,"COMPLEMENT","web_signalement";
100100,0,"Titre","web_signalement"
'.
define variable cLoginweb as longchar no-undo initial '
101600,0,"Identifiant","web_login";
704408,0,"Mot de Passe","web_login"
'.
/* attention, delimiter = : */
define variable cMenuweb as longchar no-undo initial '
0:0:"":0:0:yes:"":"":"":0:"":"";
1:101:"":?:10:yes:"men,sys":"":"newmnTI.png":0:"":"";
2:663:"":?:20:no:"men,sys":"":"newmnGM.png":0:"":"";
3:664:"":?:30:no:"men,sys":"":"newmnGB.png":0:"":"";
4:24:"":?:40:no:"men,sys":"":"newmnCo.png":0:"":"";
5:26:"":?:50:no:"men,sys":"":"newmnPa.png":0:"":"";
6:475:"":?:60:yes:"men,sys":"":"newmnTI.png":0:"":"";
11:101:"":1:0:yes:"men,sys":"":"":0:"":"";
15:611:"":?:150:yes:"men,sys":"Commercialisation/ListeUL":"":0:"":"";
61:475:"":6:10:yes:"men,sys":"":"":0:"":"";
62:796:"":6:20:no:"adb,com":"":"":0:"":"";
63:819:"":6:30:no:"adb,com":"":"":0:"":"";
111:103:"":11:0:yes:"men,sys":"TiersImmeubles/Immeuble/RepertoireImmeuble":"":0:"":"";
112:102:"":11:10:yes:"men,sys":"TiersImmeubles/Lot/GestionLot":"":0:"":"";
611:476:"":61:10:yes:"men,sys":"Travaux/Intervention/ListeIntervention":"":0:"":""
'.
*/
/* CHARGEMENT TABLE DES TRADUCTIONS PAR FICHIER EXTERNE */
define variable cfichierData as character no-undo.
define variable lOKpressed   as logical   no-undo.

system-dialog get-file cfichierData 
    title   "S�lectionner un fichier de messages ..."
    filters "fichiers donnees (*.d)"   "*.d"
    must-exist
    use-filename
    update lOKpressed.
if lOKpressed then run importSysLb(cfichierData).
/*
/* CHARGEMENT TABLE DES TRADUCTIONS */
message "chargement de cMessageImmeuble" view-as alert-box.
run createSysLb(cMessageImmeuble).

/* CHARGEMENT TABLE DES TRADUCTIONS ECRANS */
message "chargement de cheader" view-as alert-box.
run createSysLbRef(cheader).
        
message "chargement de cintervention" view-as alert-box.
run createSysLbRef(cintervention).
        
message "chargement de cddedevis" view-as alert-box.
run createSysLbRef(cddedevis).
        
message "chargement de cOrdreDeService" view-as alert-box.
run createSysLbRef(cOrdreDeService).
        
message "chargement de cSignalement" view-as alert-box.
run createSysLbRef(cSignalement).
        
message "chargement de cLoginweb" view-as alert-box.
run createSysLbRef(cLoginweb).
        
/* CHARGEMENT TABLE DES MENUS MAGIWEB */
message "chargement de cMenuweb" view-as alert-box.
run createmenuWeb(cMenuweb).
*/

procedure createSysLbRef:
/*------------------------------------------------------------------------------
Purpose:
Notes  :
------------------------------------------------------------------------------*/
define input parameter pcEcran as longchar no-undo.
    define variable pcLigne as character no-undo.
    define variable i       as integer   no-undo.
    
    do i = 1 to num-entries(pcEcran, ';'):
        pcLigne = entry(i, pcEcran, ';').
        find first sys_lb exclusive-lock
            where sys_lb.nomes = integer(entry( 1, pcLigne , ','))
              and sys_lb.cdlng = integer(entry( 2, pcLigne , ',')) no-error.
        if not available sys_lb
        then do:
            create sys_lb.
            assign
                sys_lb.nomes = integer(entry( 1, pcLigne , ','))
                sys_lb.cdlng = integer(entry( 2, pcLigne , ','))
            .
        end.
        assign
            sys_lb.lbmes = trim(entry( 3, pcLigne , ','), '"')
            sys_lb.lgmes = length(sys_lb.lbmes)
        .
        find first sys_rf exclusive-lock
            where sys_rf.tpmes = trim(entry( 4, pcLigne , ','), '"')
              and sys_rf.nomes = sys_lb.nomes no-error.
        if not available sys_rf
        then do:
            create sys_rf.
            assign
                sys_rf.tpmes = trim(entry( 4, pcLigne , ','), '"')
                sys_rf.nomes = sys_lb.nomes
            .  
        end.
    end.
end procedure.

procedure createSysLb:
/*------------------------------------------------------------------------------
Purpose:
Notes  :
------------------------------------------------------------------------------*/
define input parameter pcTexte as longchar no-undo.
    define variable pcLigne as character no-undo.
    define variable i       as integer   no-undo.
    
    do i = 1 to num-entries(pcTexte, ';'):
        pcLigne = entry(i, pcTexte, ';').
        find first sys_lb exclusive-lock
            where sys_lb.nomes = integer(entry( 1, pcLigne , ','))
              and sys_lb.cdlng = integer(entry( 2, pcLigne , ',')) no-error.
        if not available sys_lb
        then do:
            create sys_lb.
            assign
                sys_lb.nomes = integer(entry( 1, pcLigne , ','))
                sys_lb.cdlng = integer(entry( 2, pcLigne , ','))
            .
        end.
        assign
            sys_lb.lbmes = trim(entry( 3, pcLigne , ','), '"')
            sys_lb.lgmes = length(sys_lb.lbmes)
        .
    end.
end procedure.

procedure importSysLb:
/*------------------------------------------------------------------------------
Purpose:
Notes  :
------------------------------------------------------------------------------*/
define input parameter pcFile as character no-undo.

    input from value(pcFile) no-echo.
    define variable inomes as integer   no-undo.
    define variable idlng  as integer   no-undo.
    define variable clbmes as character no-undo.
    
    repeat:
        import inomes idlng clbmes.
        find first sys_lb exclusive-lock
            where sys_lb.nomes = inomes
              and sys_lb.cdlng = idlng no-error.
        if not available sys_lb
        then do:
            create sys_lb.
            assign
                sys_lb.nomes = inomes
                sys_lb.cdlng = idlng
            .
        end.
        assign
            sys_lb.lbmes = clbmes
            sys_lb.lgmes = length(sys_lb.lbmes)
        .
    end.
    input close.
end procedure.
    
procedure createmenuWeb:
/*------------------------------------------------------------------------------
Purpose:
Notes  :
------------------------------------------------------------------------------*/
define input parameter pcEcran as character no-undo.
    define variable pcLigne as character no-undo.
    define variable i       as integer   no-undo.

    do i = 1 to num-entries(pcEcran, ';'):
        pcLigne = entry(i, pcEcran, ';').
        find first menuWeb exclusive-lock
            where menuWeb.IdMenu = integer(entry( 1, pcLigne, ':')) no-error.
        if not available menuWeb
        then do:
            create menuWeb.
            menuWeb.IdMenu = integer(entry( 1, pcLigne, ':')).
        end.
        assign
            menuWeb.iNumeroItem      = integer(entry( 2, pcLigne, ':'))
            menuWeb.cTypeMenu        = trim(entry( 3, pcLigne, ':'), '"')
            menuWeb.IdParent         = integer(entry( 4, pcLigne, ':'))
            menuWeb.iOrdre           = integer(entry( 5, pcLigne, ':'))
            menuWeb.lItemActif       = entry( 6, pcLigne, ':') = "yes"
            menuWeb.cPrefixe         = trim(entry( 7, pcLigne, ':'), '"')
            menuWeb.cLienURL         = trim(entry( 8, pcLigne, ':'), '"')
            menuWeb.cLienImage       = trim(entry( 9, pcLigne, ':'), '"')
            menuWeb.iNumeroRecherche = integer(entry(10, pcLigne, ':'))
            menuWeb.cProfilItem      = trim(entry(11, pcLigne, ':'), '"')
            menuWeb.cDivers          = trim(entry(12, pcLigne, ':'), '"')
        .
    end.
end procedure.
