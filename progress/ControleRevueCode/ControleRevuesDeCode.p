/* controlerevuesdecode.p */
/* DevWeb: outil de controle dez revues de code */
/* pl : 18/05/2018 */

/*-------------------------------------------------------------------------*
   Communication
 *-------------------------------------------------------------------------*/
define input parameter cParametres-in as character no-undo.

{dfvarenv.i}
{asvarenv.i}

&SCOPED-DEFINE fichiersanalyses     "p,w,cls,i"    /* fichiers à analyser */     
&scoped-define separateurexcel      ";"              

define variable crepertoirepere         as character no-undo.
define variable crepertoireencours      as character no-undo.
define variable crepertoiretempo        as character no-undo.
define variable cfichierliste           as character no-undo.
define variable cfichiersortie          as character no-undo.
define variable cfichierexclusion       as character no-undo.
define variable ccommande               as character no-undo.
define variable cligne                  as character no-undo.
define variable cfichier                as character no-undo.
define variable cextension              as character no-undo.
define variable clisteextensionsexclues as character no-undo.
define variable iligne                  as integer   no-undo.
define variable cetatrevue              as character no-undo.
define variable chorodatage             as character no-undo.
DEFINE VARIABLE lCodeTrouve             AS LOGICAL   NO-UNDO.
DEFINE VARIABLE iBoucle                 AS INTEGER   NO-UNDO. 
DEFINE VARIABLE cChaineRecherchee       AS CHARACTER NO-UNDO.

define stream sentree.
define stream sfichier.
define stream ssortie.
define stream sexclusion.

/* chaines à rechercher dans les programmes (pb d'orthographes) */
cChaineRecherchee = "derniere revue,code revue,deerniere revue,derneire revue,dernière revue,deniere revue".   

chorodatage = string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + replace(string(time,"hh:mm:ss"),":",""). 

/* standard */
crepertoirepere = "Z:\Disque_D\modernisation\repository\magi_reference". /*"c:\magi\workspace".*/
crepertoiretempo = session:temp-directory.
cfichierliste = crepertoiretempo + "\controlerevuesdecode-" + chorodatage + ".lst".
cfichiersortie = crepertoiretempo + "\controlerevuesdecode-" + chorodatage + ".csv".
cfichierexclusion = crepertoiretempo + "\controlerevuesdecode-" + chorodatage + ".exc".

file-info:file-name = crepertoirepere.
if file-info:file-type = ? then do:
    message "Environnement introuvable! Vous devriez peut-être executer ce module sur la machine virtuelle !" view-as alert-box.
    quit.
end.

/* partie controler */
crepertoireencours = crepertoirepere + "\magicontroller\src\appserver".
ccommande = "dir /s/b/a:-d " + crepertoireencours + " > " + cfichierliste.
os-command silent value(ccommande).

/* partie modele */
crepertoireencours = crepertoirepere + "\magimodele\src\appserver".
ccommande = "dir /s/b/a:-d " + crepertoireencours + " >> " + cfichierliste.
os-command silent value(ccommande).

/* traitement de la liste */
output stream ssortie to value(cfichiersortie).
output stream sexclusion to value(cfichierexclusion).
put stream ssortie unformatted "Contrôle de revue de code du " + string(today,"99/99/9999") + " à " + string(time,"hh:mm") + "   :   Programme" + {&separateurexcel} + "Revue" skip.
input stream sentree from value(cfichierliste).
repeat:
    import stream sentree unformatted cfichier.
    /* filtres */
    if trim(cfichier) = "" then next.
    cextension = (if num-entries(cfichier,".") > 1 then entry(2,cfichier,".") else "").
    if cextension = "" then next.
    if lookup(cextension,{&fichiersanalyses}) = 0 then do:
        clisteextensionsexclues = clisteextensionsexclues + (if clisteextensionsexclues <> "" then "," else "") + cextension.
        next.
    end.
    /*  ici on peut controler le fichier */
    /* dans tous les cas on ne traitera que les 10 premières lignes pour accelerer le traitement */
    /* il y a peu de chance que la revue de code se trouve en plein milieu du programme !!! */
    iligne = 0.
    cetatrevue = "".
    input stream sfichier from value(cfichier).
    cetatrevue = "".
    repeat:
        iligne = iligne + 1.
        if iligne > 10 then leave.
        import stream sfichier unformatted cligne.
        lCodeTrouve = FALSE.
        RECHERCHE:
        DO iBoucle = 1 TO NUM-ENTRIES(cChaineRecherchee):
            IF cligne matches("*" + ENTRY(iBoucle,cChaineRecherchee) + "*") THEN DO:
                lCodeTrouve = TRUE.
                LEAVE RECHERCHE.
            END.
        END.
        if lCodeTrouve then do:
            cetatrevue = "??".
            if cligne matches("*ok*") OR cligne matches("*0k*") then cetatrevue = "ok".
            if cligne matches("*ko*") OR cligne matches("*k0*") then cetatrevue = "ko".
            leave.
        end.
    end.
    put stream ssortie unformatted cfichier + {&separateurexcel} + cetatrevue skip.
    input stream sfichier close.
end.
put stream sexclusion unformatted "Extensions de fichier ignorées : " + clisteextensionsexclues skip(1).
output stream sexclusion close.
output stream ssortie close.
input stream sentree close.

/* affichage du résultat */
os-command no-wait value(cfichiersortie).
quit.
