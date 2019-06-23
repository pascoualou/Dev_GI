/*---------------------------------------------------------------------------
 Programme        : norminette.p    (PL : 25/05/2018)
 Objet            : outil de controle d'un programme en fonction des normes
 Notes            : ...
 Modifications :
 ....   ../../....  ... ...................................................
 0001   12/09/2018  PL  De Gilles : pb de dététection de la gestion des locks
                        dans les for each...., each..., each
                        
*--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
   Préprocess
 *-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*
   Communication
 *-------------------------------------------------------------------------*/
define input parameter cParametres-in as character no-undo.

/*-------------------------------------------------------------------------*
   Environnement de l'application Norminette
 *-------------------------------------------------------------------------*/
{includes\i_fichier.i}
{Norminette\includes\Norminette.i}

/*-------------------------------------------------------------------------*
   Variables
 *-------------------------------------------------------------------------*/
define variable gcProgrammeControle         as character no-undo.
define variable gcFichierDebug              as character no-undo.
define variable gcNomVariableScoped         as character no-undo.
define variable gcNomBloc                   as character no-undo.
define variable gcFichierXRef               as character no-undo.
define variable gcListeDesFichiers          as character no-undo.
define variable gcAncienLibelleDebug        as character no-undo.

define variable giNombreLignesCommentaire   as integer   no-undo.
define variable giLigne                     as integer   no-undo.
define variable giCompteurLignesVides       as integer   no-undo.
define variable giCompteurLignesVidesSvg    as integer   no-undo.
define variable giNiveauCommentaire         as integer   no-undo.
define variable giPositionDebutCommentaire  as integer   no-undo.
define variable giPositionFinCommentaire    as integer   no-undo.
define variable giFinDefinitions            as integer   no-undo.
define variable giAncienneLigneDebug        as integer   no-undo.
define variable giLigneEnCours              as integer   no-undo.

define variable glLigneBloc                 as logical   no-undo.
define variable glBloc                      as logical   no-undo.
define variable glBanniereProgramme         as logical   no-undo.
define variable glBanniereProcedure         as logical   no-undo.
define variable glLignesInutiles            as logical   no-undo.
define variable glLigneAssign               as logical   no-undo.
define variable glProgrammeOriginal         as logical   no-undo.
define variable glProcedureOriginale        as logical   no-undo.
define variable glDebutCode                 as logical   no-undo.

/*-------------------------------------------------------------------------*
   tables temporaires
 *-------------------------------------------------------------------------*/

define temp-table gttLigne
    field iLigne    as integer
    field cLigne    as character
    field cErreur   as character
    index ix_iLigne is primary unique iLigne
    .

define temp-table gttXref
    field iLigne    as integer
    field cLigne    as character
    field cErreur   as character
    index ix_iLigne is primary unique iLigne
    .

define temp-table gttInstance no-undo
    field cBloc     as character
    field cCle      as character
    field cValeur   as character
    field iLigne    as integer
    .

define temp-table gttBloc no-undo
    field cBloc     as character
    field iDebut    as integer
    field iFin      as integer
    .

define temp-table gttRepere
    field cType     as character
    field cNom      as character
    field iLigne    as integer
    .

/*-------------------------------------------------------------------------*
   Streams
 *-------------------------------------------------------------------------*/
define stream sEntree.
define stream sDebug.

/*-------------------------------------------------------------------------*
   Fonctions (Prototypes)
 *-------------------------------------------------------------------------*/
function isVariableUtilisee returns logical(pcVariable as character, piLigneEncours as integer, plBloc as logical) forward.
function isInstanceExiste returns logical(pcBloc as character, pcCle as character, pcValeur as character) forward.
function isTableTemporaire returns logical(pcTable as character) forward.
function isPositionOkEtHorsCommentaire returns logical(piPosition as integer) forward.
function isUnSeulOutput returns logical(pcNomProcedure as character, piLigneEncours as integer) forward.
function isOutputCombo returns integer(pcNomProcedure as character, piLigneEncours as integer) forward.
function isDebutBloc returns logical(pcLigne as character) forward.
function isFinBloc returns logical(pcLigne as character) forward.
function isProcedureUtilisee returns logical(gcNomProcedure as character) forward.
function isProcedurePersistente returns integer(piLigneEncours as integer) forward.
function isElseSurLigneSuivante returns logical(piLigneEncours as integer) forward.
function isLookupDansForEach returns integer(piLigneEncours as integer) forward.
function isParametreUtilise returns logical(pcVariable as character, piLigneEncours as integer, plBloc as logical) forward.
function isNotAvailablePresent returns logical(piLigneEncours as integer, pcTable as character, plBloc as logical) forward.
function isTraitementExclus returns logical(vcCodeTraitemet as character) forward.
function isTestSurPlusieursLignes returns logical(piLigneEncours as integer) forward.
function CompilationXref returns logical() forward.
function donneDebutBloc returns integer(pcBloc as character) forward.
function donneFinBloc returns integer(pcBloc as character) forward.
function donneHorodatage returns character(pcType as character) forward.
function donneNomBloc returns character(piLigne as integer) forward.

/*=========================================================================*

                                  MAIN

 *=========================================================================*/
/* Parametres */
gcProgrammeControle = entry(1,cParametres-in,"#").
gcRepertoireTempo = disque + "tmp\".

/* Ouverture du fichier de debug */
gcFichierDebug = gcRepertoireTempo + "\Norminette.dbg".
if glModeDebug then do:
    output stream sDebug to value(gcFichierDebug) unbuffered.
end.

/* 1 seul fichier ou bien traitement d'un répertoire */
file-info:file-name = gcProgrammeControle.
if file-info:file-type = ? then do:
    /* Programme inexistant! Vous devriez peut-être executer ce module sur la machine virtuelle ! */
    run EcritAnomalie("STD",0,"","#010",""). 
    if glModeDebug then do:
        output stream sDebug close.
    end.
    run FinDeTraitements.
    return.
end.

if file-info:file-type begins "F" then do:
    run Traitements.
end.
if file-info:file-type begins "D" then do:
    /* Génération de la liste des fichiers */
    gcListeDesFichiers = gcRepertoireTempo + "Norminette.lst".
    os-command silent value("dir /s/b/a:-d " + gcProgrammeControle + " > " + gcListeDesFichiers).
end.

/* Suppression des fichiers de travail */
if glModeDebug then do:
    output stream sDebug close.
end.

return.

/*=========================================================================*

                                  FONCTIONS

 *=========================================================================*/
 
function donneHorodatage returns character(pcType as character):
/*-------------------------------------------------------------------------*
   Objet : Formattage de la date et heure suivant les besoins
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    case pctype:
        when "F" then /* File */
            vcRetour = string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + replace(string(time,"hh:mm:ss"),":","").
        when "S" then /* String */
            vcRetour = string(today,"99/99/9999") + " à " + string(time,"hh:mm").
    end case.
        
    return vcRetour.

end function.

function donneNomBloc returns character(piLigne as integer):
/*-------------------------------------------------------------------------*
   Objet : Récupération du nom du bloc en fonction de la ligne de code
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    
    define buffer bgttBloc for gttBloc.

    for first   bgttBloc
        where   bgttBloc.iDebut <= piLigne
        and     bgttBloc.iFin   >= piLigne
        :
        vcRetour = bgttBloc.cBloc.
    end.

    return vcRetour.

end function.

function donneDebutBloc returns integer(pcBloc as character):
/*-------------------------------------------------------------------------*
   Objet : Récupération du debut du bloc en fonction son nom
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viRetour as integer no-undo.

    define buffer bgttBloc for gttBloc.

    for first   bgttBloc
        where   bgttBloc.cBloc = pcBloc
        :
        viRetour = bgttBloc.iDebut.
    end.

    return viRetour.

end function.
    
function donneFinBloc returns integer(pcBloc as character):
/*-------------------------------------------------------------------------*
   Objet : Récupération de la fin du bloc en fonction son nom
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viRetour as integer no-undo.

    define buffer bgttBloc for gttBloc.

    for first   bgttBloc
        where   bgttBloc.cBloc = pcBloc
        :
        viRetour = bgttBloc.iFin.
    end.

    return viRetour.

end function.

function isDebutBloc returns logical(pcLigne as character):
/*-------------------------------------------------------------------------*
   Objet : Determiner si la ligne en cours est le début d'un bloc pour une
           procedure, fonction, methode
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlRetour as logical no-undo.

    vlRetour = (pcLigne begins("procedure") or pcLigne begins("function") or pcLigne begins("method")) and not pcLigne matches "*forward*".

    return vlRetour.

end function.

function isTestSurPlusieursLignes returns logical(piLigneEncours as integer):
/*-------------------------------------------------------------------------*
   Objet : Determiner si un test est effectuer sur plusieurs ligne pour savoir
           si le then do: doit être au debut de la ligne ou à la fin
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlRetour as logical no-undo.
    
    define buffer bgttLigne for gttLigne.

    for first bgttLigne
        where bgttLigne.iLigne = piLigneEncours - 1
        :
        vlRetour = (bgttLigne.cLigne begins "or " or bgttLigne.cLigne begins "and ").
    end.
    
    return vlRetour.

end function.

function isFinBloc returns logical(pcLigne as character):
/*-------------------------------------------------------------------------*
   Objet : Determiner si la ligne en cours est la fin d'un bloc pour une
           procedure, fonction, methode
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlRetour as logical no-undo.

    vlRetour = (pcLigne begins("end procedure") or pcLigne begins("end function") or pcLigne begins("end method")).

    return vlRetour.

end function.

function isUnSeulOutput returns logical(piNomProcedure as character,piLigneEncours as integer):
/*-------------------------------------------------------------------------*
   Objet : Déterminer si la procédure n'a q'un parametre en output
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour            as logical no-undo.
    define variable viCompteurOutput    as integer no-undo.

    define buffer bgttLigne for gttLigne.

    RECHERCHE_OUTPUT:
    for each bgttLigne
        where bgttLigne.iLigne > piLigneEncours
        :
        if bgttLigne.cLigne matches "*define output parameter*" and not bgttLigne.cLigne matches "*define output parameter table*" then do:
            viCompteurOutput = viCompteurOutput + 1.
        end.
        if viCompteurOutput > 1 or bgttLigne.cLigne matches "*end procedure*" then do:
            leave RECHERCHE_OUTPUT.
        end.
    end.
    vlretour = (viCompteurOutput = 1).
	run EcritDebug(false,true,"isUnSeulOutput : " + piNomProcedure + " -> " + string(vlretour,"oui/non")).

    return vlretour.

end function.

function isLookupDansForEach returns integer(piLigneEncours as integer):
/*-------------------------------------------------------------------------*
   Objet : Rechercher un lookup dans la clause where d'un for each
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viretour                as integer no-undo.
    define variable viIndentation           as integer no-undo init 1.
    define variable viNiveauCommentaire     as integer no-undo.
    define variable vlDiminuerCommentaire   as logical no-undo.

    define buffer bgttLigne for gttLigne.
        
    RECHERCHE_LOOKUP:
    for each bgttLigne
        where bgttLigne.iLigne >= piLigneEncours
        :
        
        /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.

        if bgttLigne.cLigne matches "*:" then do:
            viIndentation = viIndentation - 1.
        end.

        if bgttLigne.cLigne matches "*lookup*" and not bgttLigne.cLigne matches "*CRUD*" then do:
            viRetour = bgttLigne.iLigne.
        end.
        
        if viIndentation <= 0 or viRetour <> 0 then do:
            leave RECHERCHE_LOOKUP.
        end.
    end.
	run EcritDebug(false,true,"isLookupDansForEach : " + string(viIndentation) + " / " + string(viRetour) + " / " + string((viRetour <> 0),"oui/non")).

    return viRetour.

end function.

function isLockPresent returns logical(piLigneEncours as integer):
/*-------------------------------------------------------------------------*
   Objet : Rechercher un look dans la clause where d'un for each
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour                as logical no-undo.
    define variable vlVirgule               as logical no-undo.
    define variable viIndentation           as integer no-undo init 1.
    define variable viNiveauCommentaire     as integer no-undo.
    define variable vlDiminuerCommentaire   as logical no-undo.

    define buffer bgttLigne for gttLigne.

    RECHERCHE_LOCK:
    for each bgttLigne
        where bgttLigne.iLigne >= piLigneEncours
        :
        /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.

        if bgttLigne.iLigne = piLigneEncours and bgttLigne.cLigne begins "find" and bgttLigne.cLigne matches "*." then do:
	        run EcritDebug(false,true,"isLockPresent : Find sur une ligne trouvé").
            viIndentation = viIndentation - 1.
        end.
    
        if bgttLigne.cLigne matches "*:" then do:
	        run EcritDebug(false,true,"isLockPresent : '*:' trouvé").
            viIndentation = viIndentation - 1.
        end.
    
        /* Gestion syntaxe  ", each table no-lock" */
        if bgttLigne.cLigne begins "," and bgttLigne.iLigne > piLigneEncours then do:
	        run EcritDebug(false,true,"isLockPresent : ',' trouvé sur une ligne suivante").
            leave RECHERCHE_LOCK.
        end.
        
        /* Gestion de la virgule en fin de ligne */
        if bgttLigne.cLigne matches "*," then do:
	        run EcritDebug(false,true,"isLockPresent : ',' trouvé en fin de ligne").
            leave RECHERCHE_LOCK.
        end.
        
        /* Gestion syntaxe  "......-lock" */
        if bgttLigne.cLigne matches "*-lock*" then do:
	        run EcritDebug(false,true,"isLockPresent : '*-lock*' trouvé").
            vlretour = true.
        end.
        if viIndentation <= 0 or vlretour then do:
	        run EcritDebug(false,true,"isLockPresent : 'viIndentation <= 0 or vlretour'").
            leave RECHERCHE_LOCK.
        end.
    end.
	run EcritDebug(false,true,"isLockPresent : " + string(vlretour,"oui/non")).

    return vlretour.

end function.

function isElseSurLigneSuivante returns logical(piLigneEncours as integer):
/*-------------------------------------------------------------------------*
   Objet : Rechercher un 'else' sur la ligne suivante la ligne en cours
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour                as logical no-undo.
    define variable viNiveauCommentaire     as integer no-undo.
    define variable vlDiminuerCommentaire   as logical no-undo.
 
    define buffer bgttLigne for gttLigne.

    RECHERCHE_ELSE:
    for each bgttLigne
        where bgttLigne.iLigne > piLigneEncours
        :
        if trim(bgttLigne.cLigne) = "" then next.
        
        /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.
    
        if bgttLigne.cLigne matches "*~~." or bgttLigne.cLigne matches "*~~. *" then leave RECHERCHE_ELSE.
        
        if bgttLigne.cLigne matches "*else*" then do:
            vlretour = true.
            leave RECHERCHE_ELSE.
        end.
    end.
    run EcritDebug(false,true,"isElseSurLigneSuivante : Else sur la ligne suivante (Ligne en cours : " + string(piLigneEncours) + ") -> " + string(vlretour,"oui/non")).
    
    return vlretour.

end function.

function isProcedurePersistente returns integer(piLigneEncours as integer):
/*-------------------------------------------------------------------------*
   Objet : Rechercher les procedures persistentes lancées dans les for each
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viretour                as integer no-undo.
    define variable viIndentation           as integer no-undo init 1.
    define variable viNiveauCommentaire     as integer no-undo.
    define variable vlDiminuerCommentaire   as logical no-undo.

    define buffer bgttLigne for gttLigne.

    RECHERCHE_PERSISTENT:
    for each bgttLigne
        where bgttLigne.iLigne > piLigneEncours
        :
        /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.

        if bgttLigne.cLigne matches "*do:"
        or bgttLigne.cLigne matches "*for each*"
        or bgttLigne.cLigne matches "*for first*"
        or bgttLigne.cLigne matches "*for last*"
        then do:
            viIndentation = viIndentation + 1.
        end.
        if bgttLigne.cLigne matches "*end.*"
        or bgttLigne.cLigne matches "*end .*"
        then do:
            viIndentation = viIndentation - 1.
        end.
        if bgttLigne.cLigne matches "*run*" and bgttLigne.cLigne matches "*persistent set*" then do:
            viRetour = bgttLigne.iLigne.
        end.
        if viIndentation <= 0 or viRetour <> 0 then do:
            leave RECHERCHE_PERSISTENT.
        end.
    end.
	run EcritDebug(false,true,"isProcedurePersistente : " + string((viRetour <> 0),"oui/non")).

    return viRetour.

end function.

function isOutputCombo returns integer(piNomProcedure as character,piLigneEncours as integer):
/*-------------------------------------------------------------------------*
   Objet : Déterminer si la procédure a un parametre output ttcombo interdit
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viretour as integer no-undo.

    define buffer bgttLigne for gttLigne.

    RECHERCHE_TTCOMBO:
    for each bgttLigne
        where bgttLigne.iLigne > piLigneEncours
        :
        if bgttLigne.cLigne matches "*define output parameter table*" and bgttLigne.cLigne matches "*ttcombo*" then do:
            viretour = bgttLigne.iLigne.
        end.
        if viretour > 0 or bgttLigne.cLigne matches "*end procedure*" then do:
            leave RECHERCHE_TTCOMBO.
        end.
    end.
	run EcritDebug(false,true,"isOutputCombo : " + piNomProcedure + " -> " + string((viRetour > 0),"oui/non")).

    return viretour.

end function.

function isPositionOkEtHorsCommentaire returns logical(piPosition as integer):
/*-------------------------------------------------------------------------*
   Objet : La position de la chaine cherchée est-elle bonne par rapport à un
           éventuel commentaire en cours de ligne
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour as logical no-undo.

    vlretour = (piPosition > 0).
    if giPositionDebutCommentaire > 0 and giPositionFinCommentaire > 0 then do:
        vlRetour = (vlRetour and (piPosition < giPositionDebutCommentaire or piPosition > giPositionFinCommentaire)).
    end.

    return vlretour.

end function.

function isVariableUtilisee returns logical(pcVariable as character, piLigneEncours as integer, plBloc as logical):
/*-------------------------------------------------------------------------*
   Objet : Recherche de l'utilisation d'une variable donnée
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour                as logical      no-undo.
    define variable viNiveauCommentaire     as integer      no-undo.
    define variable vlDiminuerCommentaire   as logical      no-undo.

    define buffer bgttLigne for gttLigne.

    RECHERCHE_VARIABLE:
    for each bgttLigne
        where bgttLigne.iLigne > piLigneEncours
        :
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.

       vlretour = (bgttLigne.cLigne matches("*" + pcVariable + "*")).
        /* S'il s'agit d'une variable d'un bloc, on doit s'arreter à la fin du bloc */
        if vlretour or (plBloc and isFinBloc(bgttLigne.cLigne)) then do:
            leave RECHERCHE_VARIABLE.
        end.
    end.

	run EcritDebug(false,true,"isVariableUtilisee : " + pcVariable + " -> " + string(vlretour,"oui/non")).

    return vlretour.

end function.

function isParametreUtilise returns logical(pcVariable as character, piLigneEncours as integer, plBloc as logical):
/*-------------------------------------------------------------------------*
   Objet : Recherche de l'utilisation d'un parametre donné
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour                as logical      no-undo.
    define variable viNiveauCommentaire     as integer      no-undo.
    define variable vlDiminuerCommentaire   as logical      no-undo.

    define buffer bgttLigne for gttLigne.

    RECHERCHE_PARAMETRE:
    for each bgttLigne
        where bgttLigne.iLigne > piLigneEncours
        :
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        vlretour = (bgttLigne.cLigne matches("*" + pcVariable + "*")).
        /* S'il s'agit d'un paramètre d'un bloc, on doit s'arreter à la fin du bloc */
        if vlretour or (plBloc and isFinBloc(bgttLigne.cLigne)) then do:
            leave RECHERCHE_PARAMETRE.
        end.
    end.

	run EcritDebug(false,true,"isParametreUtilise : " + pcVariable + " -> " + string(vlretour,"oui/non")).

    return vlretour.

end function.

function isNotAvailablePresent returns logical(piLigneEncours as integer, pcTable as character, plBloc as logical):
/*-------------------------------------------------------------------------*
   Objet : Recherche d'un not available apres un find pour savoir si on peut
           éventuellement le remplacer pas un for first
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour                as logical      no-undo.
    define variable viNiveauCommentaire     as integer      no-undo.
    define variable vlDiminuerCommentaire   as logical      no-undo.

    define buffer bgttLigne for gttLigne.

    RECHERCHE_NOT_AVAILABLE:
    for each bgttLigne
        where bgttLigne.iLigne > piLigneEncours
        :
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then do:
            next.
        end.
        vlretour = (bgttLigne.cLigne matches("*not available *" + pcTable + "*")).
        /* S'il s'agit d'un paramètre d'un bloc, on doit s'arreter à la fin du bloc */
        if vlretour or (plBloc and isFinBloc(bgttLigne.cLigne)) then do:
            leave RECHERCHE_NOT_AVAILABLE.
        end.
    end.

	run EcritDebug(false,true,"isNotAvailablePresent : " + pcTable + " -> " + string(vlretour,"oui/non")).

    return vlretour.

end function.

function isProcedureUtilisee returns logical(pcProcedure as character):
/*-------------------------------------------------------------------------*
   Objet : Recherche de l'utilisation d'une procedure private
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour                as logical      no-undo.
    define variable viNiveauCommentaire     as integer      no-undo.
    define variable vlDiminuerCommentaire   as logical      no-undo.

    define buffer bgttLigne for gttLigne.

    RECHERCHE_PRIVATE:
    for each bgttLigne
        :
        /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then do:
            next.
        end.
        vlretour = (bgttLigne.cLigne matches("*run " + pcProcedure + "*")).
        if vlretour then do:
            leave RECHERCHE_PRIVATE.
        end.
    end.

	run EcritDebug(false,true,"isProcedureUtilisee : " + pcProcedure + " -> " + string(vlretour,"oui/non")).

    return vlretour.

end function.

function isInstanceExiste returns logical(pcBloc as character, pcCle as character, pcValeur as character):
/*-------------------------------------------------------------------------*
   Objet : Recherche de la définition dune instance
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlretour as logical no-undo.

    /* Ne pas tenir compte des tables temporaires */
    if (pcCle = "BUFFER" and isTableTemporaire(pcValeur)) then do:
        return true.
    end.
    
    /* pour le debug */
    /*---
    for each gttInstance
        where   gttInstance.cBloc = pcBloc
        and     gttInstance.cCle = pcCle
        :
	    run EcritDebug(false,true,"isInstanceExiste : Liste des instances demandées - bloc / cle / valeur = " + gttInstance.cBloc + " / " + gttInstance.cCle + " / " + gttInstance.cValeur).
    end.
    -- */
    
    for first   gttInstance
        where   gttInstance.cBloc = pcBloc
        and     gttInstance.cCle = pcCle
        and     gttInstance.cValeur = pcValeur
        :
        vlRetour = true.
    end.
	run EcritDebug(false,true,"isInstanceExiste : " + pcValeur + " -> " + string(vlretour,"oui/non")).

    return vlretour.

end function.

function isTableTemporaire returns logical(pcTable as character):
/*-------------------------------------------------------------------------*
   Objet : Savoir si une table est temporaire ou réelle
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlRetour as logical no-undo.
    define variable iBoucle as integer no-undo.

    do iBoucle = 1 to num-entries(gcListePrefixesTablesTemporaires):
        if pcTable begins entry(iBoucle,gcListePrefixesTablesTemporaires) then do:
            vlRetour = true.
            leave.
        end.
    end.
	run EcritDebug(false,true,"isTableTemporaire : " + pcTable + " -> " + string(vlretour,"oui/non")).

    return vlRetour.

end function.

function isTraitementExclus returns logical(vcCodeTraitemet as character):
/*-------------------------------------------------------------------------*
   Objet : Savoir si un traitement est exclus
   Notes : ...
 *-------------------------------------------------------------------------*/

    define variable vlRetour as logical no-undo.

    vlRetour = (lookup(vcCodeTraitemet,gcCriteresIgnores) > 0).

    return vlRetour.

end function.

function CompilationXref returns logical():
/*-------------------------------------------------------------------------*
   Objet : Compilation du programme en mode X-Ref
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlRetour            as logical   no-undo.
    define variable vcCompilateur       as character no-undo.
    define variable vcErreurCompilation as character no-undo.
    define variable vcFichier           as character no-undo. 

    run EcritDebug(false,true,"CompilationXref : Compilation du fichier -> '" + gcProgrammeControle + "'en mode xref").
    vcFichier = gcProgrammeControle.
    gcFichierXRef = vcFichier + ".xref".
    vcErreurCompilation = disque + "tmp\Norminette-ErreurCompile.txt".

    os-delete value(gcFichierXRef).
    os-delete value(vcErreurCompilation).

    vcCompilateur = reseau + "dev\outils\UE_Fichiers\UE_compile_" + (IF os-getenv("DEVUSR") BEGINS "VM" THEN "WebGI" ELSE "V11") + ".pf".
    if os-getenv("DEVUSR") = "devgg" then vcCompilateur = reseau + "dev\outils\UE_Fichiers\UE_compile_WebGI-GGA.pf".
    os-command silent value("%DLC%\bin\" + prowin + " -ininame c:\windows\outilsgi" + Suffixe + " -param """ + vcFichier + ",NORMINETTE-XREF" + """ -pf " + vcCompilateur).

    if search(vcErreurCompilation) = ? then do:
        run EcritDebug(false,true,"CompilationXref : Compilation du fichier terminée dans le fichier -> " + gcFichierXRef).
        vlRetour = true.
    end.
    else do:
        run EcritDebug(false,true,"CompilationXref : Erreur lors de la Compilation du fichier").
        vlRetour = false.
    end.

    return vlRetour.

end function.

/*=========================================================================*

                                  PROCEDURES

 *=========================================================================*/
procedure Traitements:
/*-------------------------------------------------------------------------*
   Objet : Lancement de tous les traitements
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viPositionTempo             as integer   no-undo.
    define variable vlDemandeArretControles     as logical   no-undo.
    define variable vlControlesAFaire           as logical   no-undo.

    if not isTraitementExclus("C10") then do:
        /* Compilation du fichier en mode xref pour controler les indexes */
        if not CompilationXref() then do:
            if glModeDebug then do:
                output stream sDebug close.
            end.
            return.
        end.

        /* Chargement du fichier xref en table temporaire */
        run ChargementFichierXref.

        /* Analyse de la table temporaire du fichier XREF */
        for each gttXref:
            run EcritDebug(true,false,gttXref.cLigne).
            /* Whole-index */
            run TraiteWholeIndex.
        end.
    end.

    run EcritDebug(true,false,"%s%sAnalyse du programme : " + gcProgrammeControle).
    run EcritDebug(true,false,"Ligne - Niveau commentaire -> Contenu ligne ou -----------> Action de la norminette sur la ligne%s").
    
    /* Chargement du fichier en table temporaire avec certains controles qu'on ne peut pas faire plus loin */
    run ChargementFichier.

    if glModeDebugChargement then do:
        run EcritDebug(true,false," ").
        run EcritDebug(true,false,fill("=",80) + "%s").
        run EcritDebug(true,false," ").
    end.
    
    /* Analyse de la table temporaire du fichier */
    giLigneEnCours = 0.
    for each gttLigne:
        /* Raz des variables de travail */
        glLignesInutiles = false.
        glLigneBloc = false.
        giLigneEnCours = giLigneEnCours + 1.
        
    	/* Gestion debut commentaire */
    	run TraiteCommentairesDebut.

        run EcritDebug(false,false,gttLigne.cLigne).

        /* Prise en compte des exclusions de controle */
        if gttLigne.cLigne = gcArretControlesDebut then do:
            run EcritDebug(false,true,"Traitements : Arrêt des controles").
            vlDemandeArretControles = true.
        end.
        if gttLigne.cLigne = gcArretControlesFin then do:
            run EcritDebug(false,true,"Traitements : Reprise des controles").
            vlDemandeArretControles = false.
        end.
        if vlDemandeArretControles then do:
            next.
        end.
        
        /* Determiner si le code a commencé */
        run TraiteDebutCode.

        /* lignes blanches superflues : Le message dans le fichier de sortie est déporté plus loin, car ici on n'a pas encore le nom de la procedure */
        run TraiteLignesBlanches.

        run TraiteBannieres.

        /* Todos : a faire ici, avant le bypass du code en commentaire */
        run TraiteTodos.
        
        /* A ce niveau on peut by-passer les lignes de commentaires */
        vlControlesAFaire = true.
        if giNiveauCommentaire > 0
        or gttLigne.cLigne begins "//"
        then do:
            if giNiveauCommentaire > 0 then giNombreLignesCommentaire = giNombreLignesCommentaire + 1.
            vlControlesAFaire = false.
        end.

        if vlControlesAFaire then do:

            /* Gestion entrée sortie d'une procedure ou d'une fonction ou methode SAUF si zone en commentaire */
            /* Au passage on récupère le nom de la procédure/fonction/methode */
            run TraiteProcedures.

            /* Stockage des repères (Etiquettes, etc....) */
            run TraiteReperes.

            /* Lignes et espaces inutiles */
            run TraiteLignesEtEspaces.

            /* A partir d'ici Il faut tenir compte d'un éventuel commentaire en milieu de ligne */
            giPositionDebutCommentaire = 0.
            viPositionTempo = lookup("//",gttLigne.cLigne," ").
            if viPositionTempo > 0 then do:
                giPositionDebutCommentaire = viPositionTempo.
            end.

            /* Recherche de la fin des définitions pour pouvoir localiser les Empty des tables temporaires */
            if not gttLigne.cLigne begins "define"
            and not gttLigne.cLigne begins "empty"
            and not trim(gttLigne.cLigne) = ""
            and not glLigneBloc
            and giFinDefinitions = 0
            then do:
                giFinDefinitions = gttLigne.iLigne.
                run EcritDebug(false,true,"Traitements : Fin des définitions").
            end.

            /* Actions d'ordre général sur la ligne */
            run TraiteGeneralites.

            /* Controle du typage des variable */
            run TraiteTypages.

            /* Controle du typage des paramètres */
            run TraiteRunInput.
            run TraiteFunctionInput.
            
            /* Parametres inutilisés */
            run TraiteParametres.

            /* variable inutilisées */
            run TraiteVariables.

            /* scoped-defined inutilisées */
            run TraiteScoped.

            /* Empty */
            run TraiteTablesTemporaires.

            /* Messages */
            run TraiteMessages.

            /* find, for : controle des buffers */
            run TraiteFindFor.

            /* then do: en début de ligne */
            run TraiteThenDo.

            /* Parenthèse sur la fonction available et not */
            run TraiteParentheses.

            /* Virgules en début de ligne */
            run TraiteVirgules.

            /* Valeurs des booléen inutiles */
            run TraiteLogicals.

            /* Libellés à créer : A alimenter à l'usage avec les autres possibilités */
            run TraiteLibellesEnDur.

            /* Gestion des buffers */
            run TraiteBuffers.

            /* Gestion des break et first/last-of */
            run TraiteRuptures.

            /* Gestion des .exe et .bat */
            run TraiteCommandesOS.

            /* Assign no-error sans traitement de l'erreur */
            run TraiteAssignNoError.

            /* find no-error sans traitement de l'erreur */
            run TraiteFindNoError.

            /* Traitement des procedures persistentes */
            run TraitePersistentSet.
            run TraiteDestroy.

            /* Traitement des substring avec la clause 'character' */
            run TraiteSubstring.

            /* Traitement des next & leave sans étiquette */
            run TraiteNextLeave.

            /* Analyse des createError & questionnaires */
            run TraiteCreateError.
            
            /* Traitement des Collections */
            run TraiteCollection.
            run TraiteDeleteObject.
        end.

    	/* Gestion fin et longueur commentaire */
    	run TraiteCommentairesFin.
    end.

    /* Traitement finaux */
    run FinDeTraitements.

end procedure.

procedure EcritAnomalie:
/*-------------------------------------------------------------------------*
   Objet : Ecriture d'un enregistrement dans la table des anomalies
   Notes : ...
 *-------------------------------------------------------------------------*/
    define input parameter pcCodeLigne      as character no-undo.
    define input parameter piLigne          as integer   no-undo.
    define input parameter pcProcFct        as character no-undo.
    define input parameter pcAnomalie       as character no-undo.
    define input parameter pcInsert         as character no-undo.

    define variable vcAnomalie as character no-undo.
    define variable vcAide as character no-undo.

    if isTraitementExclus(pcAnomalie) then return.

    /* Recherche du libellé de l'anomalie */
    for first  gttCriteres
        where   gttCriteres.cCode = pcAnomalie
        :
        vcAnomalie = gttCriteres.cDetail.
        vcAide = gttCriteres.cAide.
    end.
    create gttAnomalies.
    assign
        gttAnomalies.iLigne       = piLigne
        gttAnomalies.iOrdre       = 99
        gttAnomalies.cCodeLigne   = pcCodeLigne
        gttAnomalies.cBloc        = pcProcFct
        gttAnomalies.cAnomalie    = replace(vcAnomalie,"%1",pcInsert)
        gttAnomalies.cAide        = vcAide
        gttAnomalies.cCritere     = pcAnomalie
        .
    RUN EcritDebug(FALSE,FALSE,"Création anomalie pour ligne : " + STRING(piLigne) + " -> " + gttAnomalies.cAnomalie).

end procedure.

procedure EcritDebug:
/*-------------------------------------------------------------------------*
   Objet : Ecriture d'une dans le fichier debug.
   Notes : ...
 *-------------------------------------------------------------------------*/
    define input parameter plForcage        as logical      no-undo.
    define input parameter plCommentaire    as logical      no-undo.
    define input parameter pcLibelle        as character    no-undo.

    define variable vcLigne as character  no-undo.

    if not glModeDebug then do:
        return.
    end.
    
    /* Pour ne pas afficher 2 fois le même libellé pour la même ligne */
    if gcAncienLibelleDebug = pcLibelle and giAncienneLigneDebug = giLigneEnCours then do:
        return.    
    end.
    gcAncienLibelleDebug = pcLibelle.
    giAncienneLigneDebug = giLigneEnCours.
    
    if plForcage then do:
        vcLigne = pcLibelle.
    end.
    else do:
        if plCommentaire then do:
            vcLigne = "" + fill("-",11) + "> " + pcLibelle.
        end.
        else do:
            vcLigne = ""
                + (if available gttLigne then string(gttLigne.iLigne,">>>>9") else fill(" ",5))
                + " - " + string(giNiveauCommentaire,"9")
                + " -> "
                + pcLibelle
                .
        end.
    end.
    vcLigne = replace(vcLigne,"%s",chr(10)).

    put stream sDebug unformatted vcLigne skip.

end procedure.

procedure AjouteBloc:
/*-------------------------------------------------------------------------*
   Objet : Ecriture d'un bloc
   Notes : ...
 *-------------------------------------------------------------------------*/
    define input parameter pcBloc   as character    no-undo.
    define input parameter piLigne  as integer      no-undo.

    create gttBloc.
    assign
        gttBloc.cBloc   = pcBloc
        gttBloc.iDebut  = piLigne
        gttBloc.iFin    = ?
        .

end procedure.

procedure ModifieBloc:
/*-------------------------------------------------------------------------*
   Objet : Modification d'un bloc
   Notes : ...
 *-------------------------------------------------------------------------*/
    define input parameter pcBloc   as character    no-undo.
    define input parameter piLigne  as integer      no-undo.

    for first   gttBloc
        where   gttBloc.cBloc = pcBloc
        :
        gttBloc.iFin = piLigne.
    end.

end procedure.

procedure AjouteInstance:
/*-------------------------------------------------------------------------*
   Objet : Ecriture d'une instance
   Notes : ...
 *-------------------------------------------------------------------------*/
    define input parameter pcBloc   as character no-undo.
    define input parameter pcCle    as character no-undo.
    define input parameter pcValeur as character no-undo.
    define input parameter piLigne  as integer   no-undo.

    /* Ne pas tenir compte des table temporaires */
    if (pcCle = "BUFFER" and isTableTemporaire(pcValeur)) then do:
        return.
    end.

    run EcritDebug(false,true,"AjouteInstance : Bloc - Clé - Valeur - Ligne = " + pcBloc + " - " + pcCle + " - " + pcValeur + " - " + string(piLigne)).

    for first   gttInstance
        where   gttInstance.cBloc   = pcBloc
        and     gttInstance.cCle    = pcCle
        and     gttInstance.cValeur = pcValeur
        and     gttInstance.iLigne  = piLigne
        :
        return.
    end.

    create gttInstance.
    assign
        gttInstance.cBloc   = pcBloc
        gttInstance.cCle    = pcCle
        gttInstance.cValeur = pcValeur 
        gttInstance.iLigne  = piLigne
        .

end procedure.

procedure SuppressionInstance:
/*-------------------------------------------------------------------------*
   Objet : suppression d'une ou plusieurs instances
   Notes : ...
 *-------------------------------------------------------------------------*/
    define input parameter pcBloc   as character no-undo.
    define input parameter pcCle    as character no-undo.
    define input parameter pcValeur as character no-undo.

    define variable vTempo                  as character no-undo.
    define variable vcListeClesASupprimer   as character no-undo.

    /* Liste des cles à supprimer si la cle n'est pas précisée. Car certaines clés doivent demeurer dans tous les cas */
    vcListeClesASupprimer = "BUFFER,BREAK".

    vTempo = "SuppressionInstance - Instance (Bloc - clé - Valeur) -> " + pcBloc
           + " - " + (if pcCle = "" then "Toutes" else pcCle)
           + " - " + (if pcValeur = "" then "Toutes" else pcValeur)
           .
    run EcritDebug(false,true,vTempo).

    for each    gttInstance
        where   gttInstance.cBloc = pcBloc
        or      pcValeur begins "g" /* un objet global peut très bien être supprimé dans une procédure*/
        :
        if (pcCle = "" and lookup(gttInstance.cCle,vcListeClesASupprimer) = 0) then next.
        if (pcCle <> "" and gttInstance.cCle <> pcCle) then next.
        if (pcValeur <> "" and gttInstance.cValeur <> pcValeur) then next.
        delete gttInstance.

    end.

end procedure.

procedure controleBlocCommentaire:
/*-------------------------------------------------------------------------*
   Objet : Suivi des blocs de commentaires
   Notes : ...
 *-------------------------------------------------------------------------*/
    define input        parameter pcLigne               as character    no-undo.
    define input-output parameter piNiveauCommentaire   as integer      no-undo.
    define input-output parameter plDiminuerCommentaire as logical      no-undo.

    /* Execution des commandes liées à la ligne d'avant */
    if plDiminuerCommentaire then do:
        piNiveauCommentaire = piNiveauCommentaire - 1.
    end.
    if piNiveauCommentaire < 0 then do:
        piNiveauCommentaire = 0.
    end.
    plDiminuerCommentaire = false.

	if pcLigne matches "*/~~**" then do:
	    piNiveauCommentaire = piNiveauCommentaire + 1.
	end.
	if pcLigne matches "*~~*/*" then do:
	    piNiveauCommentaire = piNiveauCommentaire - 1.
	    /*plDiminuerCommentaire = true. /* Pour garder la ligne en cours en commentaire et faire le traitement à la prochaine ligne */*/
	end.

end procedure.

procedure ChargementFichierXref:
/*-------------------------------------------------------------------------*
   Objet : Chargement du fichier XREF en table temporaire
   Notes : ...
 *-------------------------------------------------------------------------*/
    input stream sEntree from value(gcFichierXRef).
    repeat:
        import stream sEntree unformatted gcLigne.
        giLigne = giLigne + 1.
    	create gttXref.
    	gttXref.iLigne = giLigne.
    	entry(1,gcLigne," ") = "".
    	/*entry(2,gcLigne," ") = "".*/
    	gttXref.cLigne = trim(gcLigne).
    end.
    input stream sEntree close.
    if glMenage then do:
        os-delete value(gcFichierXRef).
    end.
end procedure.

procedure ChargementFichier:
/*-------------------------------------------------------------------------*
   Objet : Chargement du fichier en table temporaire
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcLignesvg                  as character no-undo.
    define variable vcLigneTempo                as character no-undo.
    define variable viCompteur                  as integer   no-undo.
    define variable viBoucle                    as integer   no-undo.
    define variable viNombreMots                as integer   no-undo.
    define variable vcCopie                     as character no-undo.
    define variable vcCommentaire               as character no-undo.
    
    /* Copie du fichier source. On ne travaille pas sur l'original */
    vcCopie = gcProgrammeControle + ".trt".
    os-command silent value("copy """ + gcProgrammeControle + """ """ + vcCopie + """").
    /* Ajout d'une ligne pour prendre en compte la dernière ligne du fichier */
    output to value(vcCopie) append.
    put unformatted skip "FIN" skip.
    output close.
    
    if glModeDebugChargement then do:
        run EcritDebug(true,false,"ChargementFichier : Le log au chargement du fichier est activé.").
        run EcritDebug(true,false,"ChargementFichier : Les commentaires ne sont pas pris en compte lors du chargement du fichier").
    end.
    
    input stream sEntree from value(vcCopie).
    giLigne = 0.
    repeat:
        import stream sEntree unformatted gcLigne.

        giLigne = giLigne + 1.
    	create gttLigne.
    	gttLigne.iLigne = giLigne.

        vcCommentaire = "" + string(giLigne,">>>>9") + " - " + "*" + " -> " + gcLigne.
        if glModeDebugChargement then run EcritDebug(true,false,vcCommentaire).

        /* Ne pas controler un bloc assign */
        if trim(gcLigne) begins "assign" or gcLigne matches "*assign" or gcLigne matches "*assign*/~~**" then do:
            glLigneAssign = true.
            if glModeDebugChargement then run EcritDebug(false,true,"ChargementFichier : Début assign").
        end.
        if trim(gcLigne) = "." or gcLigne matches "*~~." then do:
            if glLigneAssign and glModeDebugChargement then run EcritDebug(false,true,"ChargementFichier : fin assign").
            glLigneAssign = false.
        end.

        /* Controle des espaces en cours de ligne sauf les lignes de define et celles contenant un // ou les bloc assign
        ou :set pour affecter les items d'une collection */
        /* Si le nombre de mots est inférieur au nombre d'entrées, c'est qu'il y a des entrées vides et donc des espaces qui se suivent */
        if not gcLigne matches "*//*"
        and not gcligne matches "*define*"
        and not gcligne matches "*:set*"
        and not gcligne matches "*find *"
        and not gcligne matches "*for last *"
        and not gcligne matches "*for first *"
        and not gcligne matches "*for each *"
        and not gcligne matches "*where*"
        and not gcligne matches "* and *"
        and not gcligne matches "* or *"
        and not gcligne matches "*when *"
        and not gcligne matches "*field *"
        and not gcligne matches "*index *"
        and not glLigneAssign
        then do:
            vcLigneTempo = trim(gcLigne).
            viNombreMots = num-entries(vcLigneTempo," ").
            viCompteur = 0.
            do viBoucle = 1 to viNombreMots:
                if entry(viBoucle,vcLigneTempo," ") <> "" then do:
                    viCompteur = viCompteur + 1.
                end.
            end.
        	if (viCompteur < viNombreMots) and not isTraitementExclus("G60") then do:
        	    gttLigne.cErreur = gttLigne.cErreur + (if gttLigne.cErreur <> "" then "|" else "") + "G60". /* Espace(s) apparemment inutile(s) en cours de ligne */
                if glModeDebugChargement then run EcritDebug(false,true,"ChargementFichier : Espaces en cours de ligne").
        	end.
        end.

    	/* remplacement des espaces et tab tant que necessaire pour continuer les controles */
    	boucle_remplace :
    	repeat :
    		assign
    			vcLignesvg  = gcLigne
    			gcLigne     = replace(gcLigne,chr(9)," ")
    			gcLigne     = replace(gcLigne,"   "," ")
    			gcLigne     = replace(gcLigne,"  "," ")
    			.
    		if (gcLigne = vcLignesvg) then do:
    		    leave boucle_remplace.
    		end.
    	end.

        /* Controle des espaces en fin de ligne (Les lignes entièrement vides seront trappées plus loin) */
    	if (gcLigne matches "* " and trim(gcLigne) <> "" ) and not isTraitementExclus("G50") then do:
    	    gttLigne.cErreur = gttLigne.cErreur + (if gttLigne.cErreur <> "" then "|" else "") + "G50". /* Espace(s) apparemment inutile(s) en fin de ligne */
            if glModeDebugChargement then run EcritDebug(false,true,"ChargementFichier : Espaces en fin de ligne").
    	end.

    	gttLigne.cLigne = trim(gcLigne).
    end.
    input stream sEntree close.
    
    /* Suppression du fichier de traitement ..... .trt */
    os-delete value(vcCopie).

end procedure.

procedure TraiteDebutCode:
/*-------------------------------------------------------------------------*
   Objet : Traitement de la recherche du debut du code
   Notes : ...
 *-------------------------------------------------------------------------*/

    if trim(gttLigne.cLigne) begins "~{" and not glDebutCode then do:
        glDebutCode = true.
    end.

end procedure.

procedure TraiteLignesBlanches:
/*-------------------------------------------------------------------------*
   Objet : Traitement des lignes blanches superflues
   Notes : ...
 *-------------------------------------------------------------------------*/
    if giNiveauCommentaire > 0 then do:
        giCompteurLignesVides = 0.
        return.
    end.

    if trim(gttLigne.cLigne) <> "" then do:
        if giCompteurLignesVides > 1 then do:
            glLignesInutiles = true.
            giCompteurLignesVidesSvg = giCompteurLignesVides.
        end.
        giCompteurLignesVides = 0.
    end.
    if trim(gttLigne.cLigne) = "" then do:
        giCompteurLignesVides = giCompteurLignesVides + 1.
    end.

end procedure.

procedure TraiteCommentairesDebut:
/*-------------------------------------------------------------------------*
   Objet : Traitement des commentaires superflus
   Notes : ...
 *-------------------------------------------------------------------------*/

	/* Gestion debut/fin et longueur commentaire */
	if gttLigne.cLigne matches "*/~~**" then do:
	    giNiveauCommentaire = giNiveauCommentaire + 1.
        run EcritDebug(false,true,"TraiteCommentairesDebut : Début commentaire niveau -> " + string(giNiveauCommentaire)).
	end.

end procedure.

procedure TraiteCommentairesFin:
/*-------------------------------------------------------------------------*
   Objet : Traitement des commentaires superflus
   Notes : ...
 *-------------------------------------------------------------------------*/

	/* Gestion debut/fin et longueur commentaire */
	if gttLigne.cLigne matches "*~~*/*" then do:
        run EcritDebug(false,true,"TraiteCommentairesFin : Fin commentaire niveau -> " + string(giNiveauCommentaire)).
        giNiveauCommentaire = giNiveauCommentaire - 1.
        if giNiveauCommentaire < 0 then giNiveauCommentaire = 0.
	    if glDebutCode and giNombreLignesCommentaire >= giMaxLignesCommentaire and not isTraitementExclus("C120") and giNiveauCommentaire = 0 then do:
            run EcritAnomalie("STD",gttLigne.iLigne - giNombreLignesCommentaire + 1,gcNomBloc,"C120","").
	    end.
	    if giNiveauCommentaire = 0 then giNombreLignesCommentaire = 0.
	end.

end procedure.

procedure TraiteReperes:
/*-------------------------------------------------------------------------*
   Objet : Recherche et stockge des étiquettes des for each                 
          SAUF si zone en commentaire
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable cTypeRepere as character no-undo init "".
    define variable cNomRepere  as character no-undo init "".

    if giNiveauCommentaire <> 0 then return.
        
    if num-entries(gttLigne.cLigne," ") = 1 and gttLigne.cLigne matches "*:" then do:
        cTypeRepere = "ETIQUETTE".
        cNomRepere = entry(1,gttLigne.cLigne,":").            
    end.

    if cTypeRepere <> "" then do:
    
        /* Il s'agit d'une étiquette, on doit la stocker */
        create gttRepere.
        assign 
            gttRepere.cType = cTypeRepere
            gttRepere.cNom = cNomRepere
            gttRepere.iLigne = gttLigne.iLigne
            .
        run EcritDebug(false,true,"TraiteReperes : Repere '" + cTypeRepere + "' -> " + cNomRepere).
    
    end.
        
end procedure.

procedure TraiteProcedures:
/*-------------------------------------------------------------------------*
   Objet : Gestion entrée sortie d'une procedure ou d'une fonction ou methode
          SAUF si zone en commentaire
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viLigneTemporaire           as integer   no-undo.
    define variable viNombreLignesProcedure     as integer   no-undo.

    if giNiveauCommentaire = 0 then do:
        if glbloc then do:
            viNombreLignesProcedure = viNombreLignesProcedure + 1.
        end.
        if isDebutBloc(gttLigne.cLigne) then do:
            gcNomBloc = entry(2,gttLigne.cLigne," ").
            gcNomBloc = replace(gcNomBloc,":","").
            run AjouteBloc(gcNomBloc,gttLigne.iLigne).
            glLigneBloc = true.
            glBloc = true.
            glBanniereProcedure = false.
            giFinDefinitions = 0.
            viNombreLignesProcedure = 0.
            if gttLigne.cLigne begins("procedure") then do:
                /* procedure private non utilisée */
                if gttLigne.cLigne matches "*private*" then do:
                    if  not isProcedureUtilisee(gcNomBloc) then do:
                        run EcritAnomalie("TOP",gttLigne.iLigne,gcNomBloc,"P60",""). /* Procédure private apparemment non utilisée */
                    end.
                end.
                /* Procédure remplaçable par une fonction */
                if isUnSeulOutput(gcNomBloc,gttLigne.iLigne) then do:
                    run EcritAnomalie("TOP",gttLigne.iLigne,gcNomBloc,"P40",""). /* Cette procédure pourrait apparemment être remplacée pas une fonction */
                end.
                /* Paramètres interdits en sortie d'une procedure. */
                viLigneTemporaire = isOutputCombo(gcNomBloc,gttLigne.iLigne).
                if viLigneTemporaire > 0 and gttLigne.cLigne matches "*private*" then do:
                    run EcritAnomalie("STD",viLigneTemporaire,gcNomBloc,"P50",""). /* Paramètre output ttcombo interdit */
                end.
            end.
            /*  rechercher tout de suite la fin du bloc pour les controles suivants */
            run ChercheFinBloc(gcNomBloc,gttLigne.iLigne).
        end.
        if isFinBloc(gttLigne.cLigne) then do:
            /*run ModifieBloc(gcNomBloc,gttLigne.iLigne).*/ /* 21/08/2018 : fait au moment du isDebutBloc */ 
            /* Bloc sans bannière */
            if not glBanniereProcedure then do:
                run EcritAnomalie("IMP",gttLigne.iLigne,gcNomBloc,"P80",""). /* Cette procédure/fonction/méthode n'a apparemment pas de bannière */
            end.
            /* Bloc sans procedure originale */
            if not glProcedureOriginale then do:
                run EcritAnomalie("IMP",gttLigne.iLigne,gcNomBloc,"P90",""). /* Cette procédure/fonction/méthode n'a apparemment pas d'origine renseignée dans la bannière */
            end.
            /* Bloc trop long */
            if viNombreLignesProcedure > giMaxLignesProcedure then do:
                 run EcritAnomalie("IMP",gttLigne.iLigne,gcNomBloc,"P30",""). /* Cette procédure/fonction/méthode est apparemment trop longue */
            end.
            /* Suppression des instances de la procedure */
            run SuppressionInstance(gcNomBloc,"","").
            /* RAZ des indicateurs */
            gcNomBloc = "".
            glBloc = false.
        end.
    end.

    /* Banniere programme et procedure : a faire ici, avant le bypass du code en commentaire */
    if (gttLigne.cLigne begins "Purpose" or gttLigne.cLigne begins "Objet" or gttLigne.cLigne begins "Description") then do:
        if not glBloc then do:
            glBanniereProgramme = true.
        end.
        else do:
            glBanniereProcedure = true.
        end.
    end.

    /* Programme/Procedure originals : a faire ici, avant le bypass du code en commentaire */
    if (gttLigne.cLigne begins "Notes" and num-entries(gttLigne.cLigne,":") > 1 and trim(entry(2,gttLigne.cLigne,":")) <> "") then do:
        if not glBloc then do:
            glProgrammeOriginal = true.
        end.
        else do:
            glProcedureOriginale = true.
        end.
    end.

end procedure.

procedure TraiteBannieres:
/*-------------------------------------------------------------------------*
   Objet : Recherche la présence des bannière
   Notes : ...
 *-------------------------------------------------------------------------*/

    /* Inutile de faire les tests si pas en cours de commentaire */
    if giNiveauCommentaire = 0 then return.

    /* Banniere programme et procedure : a faire ici, avant le bypass du code en commentaire */
    if (gttLigne.cLigne begins "Purpose" or gttLigne.cLigne begins "Objet" or gttLigne.cLigne begins "Description") then do:
        if not glBloc then do:
            glBanniereProgramme = true.
        end.
        else do:
            glBanniereProcedure = true.
        end.
    end.

    /* Programme/Procedure originals : a faire ici, avant le bypass du code en commentaire */
    if (gttLigne.cLigne begins "Notes" and num-entries(gttLigne.cLigne,":") > 1 and trim(entry(2,gttLigne.cLigne,":")) <> "") then do:
        if not glBloc then do:
            glProgrammeOriginal = true.
        end.
        else do:
            glProcedureOriginale = true.
        end.
    end.

end procedure.

procedure TraiteTodos:
/*-------------------------------------------------------------------------*
   Objet : Traitement des Todos : a faire avant le bypass du code en commentaire
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viPosition  as integer   no-undo.

    viPosition = lookup("todo",gttLigne.cLigne," ").
    if viPosition > 0 then do:
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G10",""). /* "Todo" encore présent */
    end.

end procedure.

procedure TraiteLignesEtEspaces:
/*-------------------------------------------------------------------------*
   Objet : Traitement des Lignes et espaces inutiles
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viBoucle                    as integer   no-undo.

    /* Lignes et espaces inutiles */
	if glLignesInutiles then do:
	    run EcritAnomalie("STD",gttLigne.iLigne - giCompteurLignesVidesSvg,gcNomBloc,"G30",""). /* Ligne(s) vide(s) apparemment inutile(s) */
    end.
	if gttLigne.cErreur <> "" then do:
	    do viBoucle = 1 to num-entries(gttLigne.cErreur,"|"):
	        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,entry(viBoucle,gttLigne.cErreur,"|"),"").
	    end.
	end.

end procedure.

procedure TraiteParametres:
/*-------------------------------------------------------------------------*
   Objet : Traitement des Parametres inutilisés
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viPosition  as integer   no-undo.

    viPosition = lookup("define input parameter",gttLigne.cLigne," ").
    if viPosition = 0 then do:
        viPosition = lookup("define output parameter",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup("define input-output parameter",gttLigne.cLigne," ").
    end.
    if viPosition > 0 and not gttLigne.cLigne matches "*parameter table for*" then do:
        if isPositionOkEtHorsCommentaire(viPosition) then do:
            gcNomVariableScoped = (if gttLigne.cLigne matches "*table-handle*" then entry(5,gttLigne.cLigne," ") else entry(4,gttLigne.cLigne," ")).
            if  not isParametreUtilise(gcNomVariableScoped,gttLigne.iLigne,glBloc) then do:
                run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G100",gcNomVariableScoped). /* Paramètre < ... > apparemment inutilisé */
            end.
            if glBloc and not gcNomVariableScoped begins "p" then do:
                run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G90",gcNomVariableScoped). /* Paramètre < ... > apparemment mal nommé dans une procédure */
            end.
        end.
    end.
end procedure.

procedure TraiteVariables:
/*-------------------------------------------------------------------------*
   Objet : Traitement des variables inutilisées
   Notes : ...
 *-------------------------------------------------------------------------*/

    define variable viPosition  as integer   no-undo.

    viPosition = lookup("define variable",gttLigne.cLigne," ").
    if isPositionOkEtHorsCommentaire(viPosition) then do:
        gcNomVariableScoped = entry(3,gttLigne.cLigne," ").
        if  not isVariableUtilisee(gcNomVariableScoped,gttLigne.iLigne,glBloc) then do:
            run EcritAnomalie("TOP",gttLigne.iLigne,gcNomBloc,"G110",gcNomVariableScoped). /* Variable < ... > apparemment inutilisée */
        end.
        if glBloc and not gcNomVariableScoped begins "v" then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G80",gcNomVariableScoped). /* Variable < ... > apparemment mal nommée dans une procédure */
        end.
        if not glBloc and not gcNomVariableScoped begins "g" then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G70",gcNomVariableScoped). /* Variable < ... > apparemment mal nommée dans le corps du programme */
        end.
        if gttLigne.cLigne matches "*as date*" and gttLigne.cLigne matches "*init ?*" then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G160",gcNomVariableScoped). /* Variable < ... > : ""init ?"" inutile pour une date */
        end.
        if gttLigne.cLigne matches "*as logical*" and gttLigne.cLigne matches "*init false*" then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G170",gcNomVariableScoped). /* Variable < ... > : ""init false"" inutile pour un logical */
        end.

    end.

end procedure.

procedure TraiteScoped:
/*-------------------------------------------------------------------------*
   Objet : Traitement des scoped-defined inutilisées
   Notes : ...
 *-------------------------------------------------------------------------*/

    define variable viPosition  as integer   no-undo.

    viPosition = lookup("&scoped-define",gttLigne.cLigne," ").
    if isPositionOkEtHorsCommentaire(viPosition) then do:
        gcNomVariableScoped = entry(2,gttLigne.cLigne," ").
        if not isVariableUtilisee(gcNomVariableScoped,gttLigne.iLigne,glBloc) then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G120",gcNomVariableScoped). /* Scoped-defined < ... > apparemment inutilisé */
        end.
    end.

end procedure.

procedure TraiteTablesTemporaires:
/*-------------------------------------------------------------------------*
   Objet : Traitement des empty des tables temporaires
   Notes : ...
 *-------------------------------------------------------------------------*/

    define variable viPosition  as integer   no-undo.

    viPosition = lookup("empty temp-table",gttLigne.cLigne," ").
    if isPositionOkEtHorsCommentaire(viPosition) and (giFinDefinitions > 0 and gttLigne.iLigne > giFinDefinitions) then do:
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C110",""). /* Empty temp-table apparemment mal placé */
    end.

end procedure.

procedure TraiteMessages:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des Messages oubliés
   Notes : ...
 *-------------------------------------------------------------------------*/

    define variable viPosition  as integer   no-undo.

    viPosition = lookup("message",gttLigne.cLigne," ").
    if isPositionOkEtHorsCommentaire(viPosition) then do:
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G20",""). /* Message encore présent */
    end.

end procedure.

procedure TraiteFindFor:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des find, for : controle des buffers sur les tables
          réelles
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlLockPresent       as logical no-undo.
    define variable vlTableTemporaire   as logical no-undo.
    define variable viPosition          as integer no-undo.
    define variable vcNomTable                  as character no-undo.
    define variable viLigneTemporaire           as integer   no-undo.

    viPosition = lookup("find first",gttLigne.cLigne," ").
    if viPosition = 0 then do:
        viPosition = lookup("find last",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup("for first",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup("for last",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup("for each",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup(", last",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup(", first",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup(", each",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup(",last",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup(",first",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup(",each",gttLigne.cLigne," ").
    end.
    if isPositionOkEtHorsCommentaire(viPosition) then do:
        vcNomTable = entry(viPosition + 2,gttLigne.cLigne," ").
        vlLockPresent = isLockPresent(gttLigne.iLigne).
        vlTableTemporaire = isTableTemporaire(vcNomTable).
        if vlLockPresent then do:
            if vlTableTemporaire then do:
                run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C150",vcNomTable). /* Utilisation d'une clause 'Lock' sur la table temporaire %1 */
            end.
        end.
        else do:
            if not vlTableTemporaire then do:
                run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C160",vcNomTable). /* Aucune clause 'Lock' précisée pour la table %1 */
            end.
        end.
        if not isInstanceExiste(gcNomBloc,"BUFFER",vcNomTable) then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C20",vcNomTable). /* Buffer < ... > apparemment non défini pour la table */
        end.
        /* Spécifique pour le find first / Last */
        if lookup("find first",gttLigne.cLigne," ") > 0 or lookup("find last",gttLigne.cLigne," ") > 0 then do:
            if not isNotAvailablePresent(gttLigne.iLigne,vcNomTable,glbloc) then do:
                run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C130",""). /* Find first/last potentiellement remplaçable par un for first/last */
            end.
        end.

        /* Spécifique pour les for each */
        if lookup("for each",gttLigne.cLigne," ") > 0 then do:
            viLigneTemporaire = isProcedurePersistente(gttLigne.iLigne).
            if viLigneTemporaire <> 0 then do:
                run EcritAnomalie("STD",viLigneTemporaire,gcNomBloc,"P10",""). /* Appel d'une procédure persistente dans un for each */
            end.
            viLigneTemporaire = isLookupDansForEach(gttLigne.iLigne).
            if viLigneTemporaire <> 0 then do:
                run EcritAnomalie("STD",viLigneTemporaire,gcNomBloc,"C100",""). /* Attention : Lookup dans la clause where d'un for each */
            end.
            find first  gttRepere   no-lock
                where   gttRepere.cType = "ETIQUETTE"
                and     gttRepere.iLigne = (gttLigne.iLigne - 1)
                no-error.
            if not available gttRepere then do:
                run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C200",""). /* Bloc 'For' sans étiquette */
            end.
        end.
    end.

end procedure.

procedure TraiteThenDo:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des then do: en debut de ligne
   Notes : ...
 *-------------------------------------------------------------------------*/

    if gttLigne.cLigne begins "then do:" and not isTestSurPlusieursLignes(gttLigne.iLigne) then do:
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C30",""). /* Then do: apparemment mal placé */
    end.

end procedure.

procedure TraiteParentheses:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des Parenthèses sur la fonction available et not
   Notes : ...
 *-------------------------------------------------------------------------*/

    if gttLigne.cLigne matches "*available(*" then do: 
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C50","available"). /* Retirer les () du mot clé available */
    end.

    if gttLigne.cLigne matches "*not(*" then do: 
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C50","not"). /* Retirer les () du mot clé not */
    end.

end procedure.

procedure TraiteVirgules:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des virgules en début de ligne
   Notes : ...
 *-------------------------------------------------------------------------*/

    if  gttLigne.cLigne begins "," 
    and not gttLigne.cLigne begins ",first"
    and not gttLigne.cLigne begins ", first"
    and not gttLigne.cLigne begins ",last"
    and not gttLigne.cLigne begins ", last"
    then do:
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C140",""). /* Instruction sur plusieurs lignes : la virgule devrait être à la fin de la ligne précédente */
    end.

end procedure.

procedure TraiteLogicals:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des Valeurs des booléen inutiles
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viNiveauCommentaire     as integer no-undo.
    define variable vlDiminuerCommentaire   as logical no-undo.
    define variable viPositionif            as integer no-undo.
    define variable viPositionthen          as integer no-undo.
    define variable viPositionDebut         as integer no-undo.
    define variable viPositionFin           as integer no-undo.
    define variable viPosition              as integer no-undo.
    
    define buffer bgttLigne for gttLigne.

   /* Bypass des commentaires */
    run controleBlocCommentaire(gttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
    if gttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.

    /* Valeurs des booléens inutiles */
    viPositionif = lookup("if",gttLigne.cLigne," ").
    /* Le test peut se faire sur plusieurs lignes */
    if viPositionif = 0 then viPositionif = lookup("and",gttLigne.cLigne," ").
    if viPositionif = 0 then viPositionif = lookup("or",gttLigne.cLigne," ").
    if viPositionif = 0 then return.
    
    /* le test peut être fait sur plusieurs lignes */
    viPositionthen = lookup("then",gttLigne.cLigne," ").
    viPositionDebut = viPositionif.
    viPositionFin = (if viPositionthen > 0 then viPositionthen else 1000). 
    
    viPosition = lookup("= true",gttLigne.cLigne," ").
    if viPosition = 0 then do:
        viPosition = lookup("= false",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup("= yes",gttLigne.cLigne," ").
    end.
    if viPosition = 0 then do:
        viPosition = lookup("= no",gttLigne.cLigne," ").
    end.
    if viPosition > 0 and viPosition > viPositionDebut and viPosition < viPositionFin then do:
        run EcritDebug(false,true,"TraiteLogicals : valeur(s) logical inutile(s)").
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C40",""). /* Retirer la valeur du logical apparemment inutile */
    end.    

end procedure.

procedure TraiteLibellesEnDur:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des Libellés à créer : A alimenter à l'usage avec les
          autres possibilités
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlAnomalie          as logical      no-undo.
    define variable viPosition          as integer      no-undo.
    define variable viPositionDebut     as integer      no-undo.
    define variable viPositionFin       as integer      no-undo.
    define variable vcChaine            as character    no-undo.
    define variable vcCaractere         as character    no-undo.
    define variable viBoucle            as integer      no-undo.
    define variable cChaineRecherchee   as character    no-undo.
    define variable cCaractereRecherche as character    no-undo.

    cCaractereRecherche = "'".
    cChaineRecherchee = "ttCombo.cLibelle = " + cCaractereRecherche. 
    viPosition = index(gttLigne.cLigne,cChaineRecherchee).
    if viPosition = 0 then do:
        cCaractereRecherche = chr(34).
        cChaineRecherchee = "ttCombo.cLibelle = " + cCaractereRecherche.
        viPosition = index(gttLigne.cLigne,cChaineRecherchee).
    end.
    
    if (viPosition <> 0) then do:
        /* Rcupération de la chaine */
        viPositionDebut = viPosition + length(cChaineRecherchee) - 1.
        viPositionFin = index(gttLigne.cLigne,cCaractereRecherche,viPositionDebut + 1).
        vcChaine = substring(gttLigne.cLigne,viPositionDebut,(viPositionFin - viPositionDebut) + 1).
        run EcritDebug(false,true,"TraiteLibellesEnDur : Analyse de la chaine -> " + vcChaine).
        
        /* Vérification qu'il n'y a pas de caractère alphabétique */
        do viBoucle = 1 to length(vcChaine):
            vcCaractere = substring(vcChaine,viBoucle,1).
            if index("abcdefghijklmnopqrstuvwxyz",vcCaractere) > 0 then vlAnomalie = true.   
        end.
        if vlAnomalie then do:
            run EcritDebug(false,true,"TraiteLibellesEnDur : Libellé en dur -> " + vcChaine).
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G150",""). /* Libellé apparemment en dur à créer */
        end.
    end.

end procedure.
    
procedure TraiteCreateError:
 /*-------------------------------------------------------------------------*
   Objet : analyse des mError:createError
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vlTempo     as logical      no-undo.
    define variable vcTempo     as character    no-undo.
    define variable viTempo     as integer      no-undo.
    define variable vcRecherche as character    no-undo.

    if gttLigne.cLigne matches "*mError:createError(*" then do:
        vcRecherche = "mError:createError".   
    end. 
    if vcRecherche = "" then do:
        if gttLigne.cLigne matches "*mError:createErrorGestion(*" then do:
            vcRecherche = "mError:createErrorGestion".
        end.   
    end.
    if vcRecherche = "" then do:
        if gttLigne.cLigne matches "*mError:createErrorCompta(*" then do:
            vcRecherche = "mError:createErrorCompta".
        end.   
    end.
    if vcRecherche <> "" then do:
        vlTempo = (gttLigne.cLigne matches "*&error*" 
                or gttLigne.cLigne matches "*&erreur*" 
                or gttLigne.cLigne matches "*&information*" 
                or gttLigne.cLigne matches "*&info*" 
                or gttLigne.cLigne matches "*&warning*"
                or gttLigne.cLigne matches "*&question*"
                or gttLigne.cLigne matches "*&NIVEAU-*"
                ). 
        run EcritDebug(false,true,"TraiteCreateError : mError:createError - flag -> " + string(vlTempo,"oui/non")).
        if not vlTempo then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C180",""). /* la fonction 'mError:createError' sans type (error, information...) */
        end.
        viTempo = index(gttLigne.cLigne,vcRecherche).
        vcTempo = substring(gttLigne.cLigne,viTempo).
        if trim(entry(2,vcTempo)) matches "*" + chr(34) + "*" + chr(34) + "*" then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C190",""). /* la fonction 'mError:createError' à un libellé en dur en paramètre */
        end.
    end.

end procedure.

procedure TraiteBuffers:
 /*-------------------------------------------------------------------------*
   Objet : Gestion des buffers sur les tables réelle (repérage)
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable iPosition as integer no-undo.

    /* Gestion des buffers */
    if gttLigne.cLigne begins "define buffer" then iPosition = 3.
    if gttLigne.cLigne begins "define parameter buffer" then iPosition = 4.
    if iPosition <> 0 then do:
        run AjouteInstance(gcNomBloc,"BUFFER",entry(iPosition,gttLigne.cLigne," "),gttLigne.iLigne).
    end.

end procedure.

procedure TraiteRuptures:
 /*-------------------------------------------------------------------------*
   Objet : Trzitement des break et first/last-of
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcChamp     as character no-undo.
    define variable viBoucle    as integer   no-undo.

    /* Gestion des break et first/last-of */
    if gttLigne.cLigne begins "break" then do:
        run EcritDebug(false,true,"TraiteRuptures : BREAK détecté").
        /* Recherche des champs du break */
        do viBoucle = 3 to num-entries(gttLigne.cLigne," ") by 2 :
            vcChamp = entry(viBoucle,gttLigne.cLigne," ").
            vcChamp = replace(vcChamp,":","").
            vcChamp = trim(vcChamp).
            run AjouteInstance(gcNomBloc,"BREAK",vcChamp,gttLigne.iLigne).
            run EcritDebug(false,true,"TraiteRuptures : BREAK -> " + vcChamp).
        end.
    end.

    /* Gestion des first/last-of */
    if (gttLigne.cLigne matches "*first-of*"
    or gttLigne.cLigne matches "*last-of*")
    then do:
        run EcritDebug(false,true,"TraiteRuptures : first/last-of détecté").
        vcChamp = entry(2,gttLigne.cLigne,"(").
        vcChamp = entry(1,vcChamp,")").
        run EcritDebug(false,true,"TraiteRuptures : first/last-of -> " + vcChamp).
        if not isInstanceExiste(gcNomBloc,"BREAK",vcChamp) then do:
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C60",vcChamp). /* First-of/last-of < ... > sans break correspondant */
        end.
    end.

end procedure.

procedure TraiteCommandesOS:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des commandes spécifiques à Windows qui vont nous poser
          des problèmes plus tard
   Notes : ...
 *-------------------------------------------------------------------------*/

    /* Gestion des .exe et .bat */
    if gttLigne.cLigne matches "*~~.exe*" or gttLigne.cLigne matches "*~~.bat*"
    or (gttLigne.cLigne matches "*dos*" and gttLigne.cLigne matches "*value*")
    then do:
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"O10",""). /* Utilisation d'un programme spécifique à windows */
    end.

end procedure.

procedure TraiteSubstring:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des commandes substring 
   Notes : ...
 *-------------------------------------------------------------------------*/

    if gttLigne.cLigne matches "*substring(*"  then do:
        run EcritDebug(false,true,"TraiteSubstring : substring détecté").
        if replace(gttLigne.cLigne,"""","'") matches "*'character')*" then do:
            run EcritDebug(false,true,"TraiteSubstring : 'character' détecté").
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C170",""). /* La clause 'character' est inutile car par défaut pour l'nstruction 'substring' */
        end.
    end.

end procedure.

procedure TraiteNextLeave:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des commandes Next & leave 
   Notes : ...
 *-------------------------------------------------------------------------*/

    if gttLigne.cLigne matches "*next." or gttLigne.cLigne matches "*leave." then do:
        run EcritDebug(false,true,"TraiteNextLeave : next ou leave sans étiquette détecté").
        run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C210",""). /* Les instructions 'Leave' et 'Next' doivent toujours être suivies par une étiquette */
    end.

end procedure.

procedure TraiteAssignNoError:
 /*-------------------------------------------------------------------------*
   Objet : Recherche des assign ...no-error sans traitement de l'erreur
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viFinAssign             as integer no-undo.
    define variable vlNoError               as logical no-undo.
    define variable vlErrorStatus           as logical no-undo .
    define variable viNiveauCommentaire     as integer no-undo.
    define variable vlDiminuerCommentaire   as logical no-undo.

    define buffer bgttLigne for gttLigne.

    if not gttLigne.cLigne matches "*assign*" then return.
    if gttLigne.cLigne matches "*assign error-status:error =*" then return.

    /* Recherche si no-error */
    RECHERCHE_FIND_NO_ERROR:
    for each bgttLigne
        where bgttLigne.iLigne >= gttLigne.iLigne
        :
       /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.

        if bgttLigne.cLigne matches "*~~." then do:
            viFinAssign = bgttLigne.iLigne.
        end.

        if bgttLigne.cLigne matches "*no-error*" then do:
           vlNoError = true.
        end.
        if viFinAssign <> 0 then do:
            leave RECHERCHE_FIND_NO_ERROR.
        end.
    end.

    if vlNoError then do:
        run EcritDebug(false,true,"TraiteAssignNoError : Assign avec no-error détecté").

        /* si no-error, il doit y avoir un error-status juste après (avec peut-être un commentaire ou une ligne blanche) */
        RECHERCHE_ERROR_STATUS:
        for each bgttLigne
            where bgttLigne.iLigne > viFinAssign
            :
            /* Bypass des commentaires */
            run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
            if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.

            /* Ligne blanche */
            if trim(bgttLigne.cLigne) = "" then next.

            if bgttLigne.cLigne matches "*error-status*" then do:
                vlErrorStatus = true.
            end.
            leave RECHERCHE_ERROR_STATUS.
        end.

        if vlNoError then do:
            if vlErrorStatus then do:
                run EcritDebug(false,true,"TraiteAssignNoError : Gestion de l'erreur trouvée").
            end.
            else do:
                run EcritDebug(false,true,"TraiteAssignNoError : Gestion de l'erreur non trouvée").
                run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C70",""). /* Assign no-error apparemment sans gestion de l'erreur ou gérée trop loin */
            end.
        end.
    end.

end procedure.

procedure TraiteFindNoError:
 /*-------------------------------------------------------------------------*
   Objet : Recherche des find ...no-error sans traitement de l'erreur
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viFinFind               as integer      no-undo.
    define variable vlNoError               as logical      no-undo.
    define variable vlAvailable             as logical      no-undo .
    define variable viNiveauCommentaire     as integer      no-undo.
    define variable vlDiminuerCommentaire   as logical      no-undo.
    define variable vNomTable               as character    no-undo.
    define variable viPositionFind          as integer      no-undo.
    define variable viLigneFinBloc          as integer      no-undo.
    define variable vcBloc                  as character    no-undo.

    define buffer bgttLigne for gttLigne.

    if not gttLigne.cLigne matches "*find *" then return.

    /* Récupération du nom de la table */
    viPositionFind = lookup("find",gttLigne.cLigne," ").
    vNomTable = entry(viPositionFind + 1,gttLigne.cLigne," ").
    if lookup(vNomTable,"first,last,next,prev,current") > 0 then do:
        vNomTable = entry(viPositionFind + 2,gttLigne.cLigne," ").
    end.
    
    /* Recherche si no-error */
    RECHERCHE_NO_ERROR:
    for each bgttLigne
        where bgttLigne.iLigne >= gttLigne.iLigne
        :
       /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.
               
        /* Recherche de la fin du find */
        if bgttLigne.cLigne matches "*~~." or bgttLigne.cLigne matches "*~~. *" then do:
            run EcritDebug(false,true,"TraiteFindNoError : Fin du find trouvé ligne " + string(bgttLigne.iLigne)).
            viFinFind = bgttLigne.iLigne.
        end.

        if bgttLigne.cLigne matches "*no-error*" then do:
            run EcritDebug(false,true,"TraiteFindNoError : '*no-error*' trouvé ligne " + string(bgttLigne.iLigne)).
           vlNoError = true.
        end.
        if viFinFind <> 0 then do:
            run EcritDebug(false,true,"TraiteFindNoError : Sortie car fin find trouvée").
            leave RECHERCHE_NO_ERROR.
        end.
    end.

    if vlNoError then do:
        vcBloc = DonneNomBloc(viFinFind).
        viLigneFinBloc = DonneFinBloc(vcBloc).
        run EcritDebug(false,true,"TraiteFindNoError : no-error détecté sur la table -> " + vNomTable).
        run EcritDebug(false,true,"TraiteFindNoError : Recherche available sur la portion de lignes -> " + string(viFinFind) + " - " + string(viLigneFinBloc) + " - Bloc -> " + vcBloc).
        
        /* Recherche de l'utilisation de la table et du available. Si l'un sans l'autre, : erreur */
        RECHERCHE_AVAILABLE:
        for each bgttLigne
            where bgttLigne.iLigne > viFinFind
            and   bgttLigne.iLigne < viLigneFinBloc
            :
            /* Bypass des commentaires */
            run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
            if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.

            /* Ligne blanche */
            if trim(bgttLigne.cLigne) = "" then next.

            if bgttLigne.cLigne matches("*available* " + vNomTable + "*") or bgttLigne.cLigne matches "*outils:isUpdated*" then do:
                run EcritDebug(false,true,"TraiteFindNoError : '*available* ' ou '*outils:isUpdated*' trouvé").
                vlAvailable = true.
                leave RECHERCHE_AVAILABLE.
            end.
        end.

        if vlAvailable then do:
            run EcritDebug(false,true,"TraiteFindNoError : Gestion de l'erreur trouvée en ligne -> " + string(bgttLigne.iLigne)).
        end.
        else do:
            run EcritDebug(false,true,"TraiteFindNoError : Gestion de l'erreur non trouvée").
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"C80",""). /* Find no-error sans gestion de l'erreur ou gérée trop loin */
        end.
    end.
end procedure.

procedure TraiteWholeIndex:
 /*-------------------------------------------------------------------------*
   Objet : Recherche des whole-index dans le fichier xref
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viLigne     as integer      no-undo.
    define variable vcTable     as character    no-undo.
    define variable vcIndex     as character    no-undo.
    define variable vcTempo     as character    no-undo.
    define variable vcProgramme as character    no-undo.

    if gttXref.cLigne matches "*WHOLE-INDEX*" and not gttXref.cLigne matches "*TEMPTABLE*" then do:
        run EcritDebug(false,true,"TraiteWholeIndex : WHOLE-INDEX détecté").
        viLigne = int(entry(2,gttXref.cLigne," ")).
        vcTable = entry(4,gttXref.cLigne," ").
        vcIndex = entry(5,gttXref.cLigne," ").
        vcTempo = entry(1,gttXref.cLigne," ").
        vcProgramme = entry(num-entries(vcTempo,"\"),vcTempo,"\").
        /* Le nom de la procedure sera récupéré lors du traitement avant édition */
        run EcritAnomalie("W-I",viLigne,"","C10",vcProgramme + " / " + vcTable + " / " + vcIndex). /* Whole-index < ... > détecté sur une requête */
    end.

end procedure.

procedure TraitePersistentSet:
 /*-------------------------------------------------------------------------*
   Objet : Enregistrement des Persistent set
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcTempo     as character no-undo.
    define variable viPosition  as integer   no-undo.

    viPosition = lookup("persistent set", gttLigne.cLigne ," ").
    if viPosition > 0 then do:
        run EcritDebug(false,true,"TraitePersistentSet : persistent trouvé").
        vcTempo = entry(viPosition + 2,gttLigne.cLigne," ").
        vcTempo = replace(vcTempo,".","").
        run AjouteInstance(gcNomBloc,"PERSISTENT",vcTempo,gttLigne.iLigne).
    end.

end procedure.

procedure TraiteDestroy:
 /*-------------------------------------------------------------------------*
   Objet : suppression d'une instance destroy
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcTempo     as character no-undo.
    define variable viPosition  as integer   no-undo.

    viPosition = lookup("run destroy in", gttLigne.cLigne ," ").
    if viPosition > 0 then do:
        vcTempo = entry(viPosition + 3,gttLigne.cLigne," ").
        vcTempo = replace(vcTempo,".","").
        run SuppressionInstance(gcNomBloc,"PERSISTENT",vcTempo).
    end.

end procedure.

procedure TraiteGeneralites:
 /*-------------------------------------------------------------------------*
   Objet : Traitement des généralités sur les lignes
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcTempo     as character no-undo.
    define variable viPosition  as integer   no-undo.

    /* Ne traiter que les return de fin de bloc, pas celui des fonctions */
    if gttLigne.cLigne begins "Function" then return.
    viPosition = lookup("return", gttLigne.cLigne ," ").
    if viPosition > 0 and lookup("return.", gttLigne.cLigne ," ") = 0 then do:
        vcTempo = entry(viPosition + 1,gttLigne.cLigne," ").
        vcTempo = replace(vcTempo,".","").
        run SuppressionInstance(gcNomBloc,"COLLECTION",vcTempo).
    end.

end procedure.

procedure TraiteCollection:
 /*-------------------------------------------------------------------------*
   Objet : Enregistrement des collections
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcTempo     as character no-undo.
    define variable viPosition  as integer   no-undo.


    viPosition = lookup("as class collection", gttLigne.cLigne ," ").
    if viPosition > 0 then do:
        vcTempo = entry(viPosition - 1,gttLigne.cLigne," ").
        /* Ne pas en tenir compte s'il s'agit d'un parametre */
        if not vcTempo begins "p" then do:
            run AjouteInstance(gcNomBloc,"COLLECTION",vcTempo,gttLigne.iLigne).
        end.
    end.

end procedure.

procedure TraiteDeleteObject:
 /*-------------------------------------------------------------------------*
   Objet : suppression d'une instance Delete object
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable vcTempo     as character no-undo.
    define variable viPosition  as integer   no-undo.
    define variable viPositionCommentaire as integer no-undo.

    viPosition = lookup("delete object", gttLigne.cLigne ," ").
    viPositionCommentaire = lookup("//", gttLigne.cLigne ," ").
    if viPosition > 0 then run EcritDebug(false,true,"TraiteDeleteObject : Position / Position commentaire = " + string(viPosition) + " / " + string(viPositionCommentaire)).
    if viPositionCommentaire <> 0 and viPositionCommentaire < viPosition then return.
    if viPosition > 0 then do:
        vcTempo = entry(viPosition + 2,gttLigne.cLigne," ").
        vcTempo = replace(vcTempo,".","").
        run SuppressionInstance(gcNomBloc,"COLLECTION",vcTempo).
    end.

end procedure.

procedure FinDeTraitements:
 /*-------------------------------------------------------------------------*
   Objet : Traitement finaux sur les infos récupérées au cours du controle
   Notes : ...
 *-------------------------------------------------------------------------*/

    define variable vcLibelleTempo  as character  no-undo.
    define variable vcLigne         as character  no-undo.

    /* Fin de lecture du fichier : si le compteur de lignes blanches n'est pas à 0 alors il y a une ou plusieurs lignes blanches en fin de programme */
    if giCompteurLignesVides <> 0 then do:
        run EcritAnomalie("STD",giLigne - giCompteurLignesVides + 1,"","G40",""). /* Ligne(s) vide(s) apparemment inutile(s) en fin de programme */
    end.

    /* Fin de lecture du fichier : si l'indicateur de bannière est à false = bannière programme manquante */
    if not glBanniereProgramme then do:
        run EcritAnomalie("TOP",0,"","G130",""). /* Ce programme n'a apparemment pas de bannière */
    end.

    /* Fin de lecture du fichier : Origine programme manquante */
    if not glProgrammeOriginal then do:
        run EcritAnomalie("TOP",0,"","G140",""). /* Ce programme n'a apparemment pas d'origine renseignée dans la bannière */
    end.

    for each gttBloc
        where gttBloc.iFin = ?
        :
        run EcritAnomalie("TOP",gttBloc.iDebut,cBloc,"G180",cBloc). /* Problème potentiel sur le bloc < ... > qui n'a pas de ligne de fin */
    end.


    run EcritDebug(false,true,"FinDeTraitements : Début gttInstance").
    for each gttInstance:
        vcLibelleTempo = ""
            + "cBloc : " + gttInstance.cBloc
            + " / cCle : " + gttInstance.cCle
            + " / cValeur : " + gttInstance.cValeur
            + " / iLigne : " + string(gttInstance.iLigne)
            .
        run EcritDebug(false,true,vcLibelleTempo).
    end.
    run EcritDebug(false,true,"FinDeTraitements : Fin gttInstance").

    /* Recherche des run persistent restant = ceux qui n'ont pas de destroy */
    for each    gttInstance
        where   (gttInstance.cCle = "PERSISTENT" or gttInstance.cCle = "COLLECTION")
        :
        if gttInstance.cCle = "PERSISTENT" then DO:
            run EcritAnomalie("STD",gttInstance.iLigne,gttInstance.cBloc,"P20",gttInstance.cValeur). /* Procédure persistente < ... > apparemment non détruite */
        END.
        if gttInstance.cCle = "COLLECTION" then DO:
            run EcritAnomalie("STD",gttInstance.iLigne,gttInstance.cBloc,"C90",gttInstance.cValeur). /* Objet < ... > créé mais apparemment non détruit */
        END.

    end.

    /* Classement correct des lignes en fonction du code de la ligne + Récupération du nom de bloc pour les whole-index */
    for each    gttAnomalies
        where   gttAnomalies.iOrdre = 99
        and     gttAnomalies.cCodeLigne <> "STD"  /* Standard */
        :
        if gttAnomalies.cCodeLigne = "TOP" or gttAnomalies.cCodeLigne = "IMP" then do:  /* TOP & IMPORTANT */
            gttAnomalies.iLigne = (if gttAnomalies.cBloc <> "" then donneDebutBloc(gttAnomalies.cBloc) else gttAnomalies.iLigne).
            gttAnomalies.iOrdre = (if gttAnomalies.cCodeLigne = "TOP" then 10 else 20).
        end.

        /* Récupération des procédure/fonction/methode pour les Whole-index */
        if gttAnomalies.cCodeLigne = "W-I" then do:   /* WHOLE-INDEX */
            gttAnomalies.cBloc = donneNomBloc(gttAnomalies.iLigne).
        end.
    end.

    run EcritDebug(TRUE,false,"%s%sCONTENU DE LA TABLE DES ANOMALIES%s").

    /* Génération des libellés de filtrage */
    for each    gttAnomalies
        :
        /* Composition des filtres */
        if gttAnomalies.cAnomalie matches "*<*" and gttAnomalies.cAnomalie matches "*>*" then do:
            gttAnomalies.cLibelleFiltre = entry(1,gttAnomalies.cAnomalie,"<") + "< ... >" + entry(2,gttAnomalies.cAnomalie,">").
        end.
        else do:
            gttAnomalies.cLibelleFiltre = gttAnomalies.cAnomalie.
        end.
        vcLigne = ""
            + string(gttAnomalies.iLigne,">>>>9")
            + " | " + string(gttAnomalies.cBloc,"x(32)")
            + " | " + string(gttAnomalies.cAnomalie,"x(135)")
            + " | " + gttAnomalies.cAide.

        run EcritDebug(TRUE,false,string(gttAnomalies.iOrdre) + "|" + vcLigne).
    end.
    
    /* Liste des procédures/functions/methodes */
    run EcritDebug(false,false,"%s%sLISTE DES BLOCS AVEC LIGNE DÉBUT ET FIN %s").
    for each gttBloc:
        vcLigne = ""
            + (if gttBloc.cBloc <> ? then string(gttBloc.cBloc,"x(32)") else "???")
            + " - " + (if gttBloc.iDebut <> ? then string(gttBloc.iDebut,">>>>>9") else "???")
            + " - " + (if gttBloc.iFin <> ? then string(gttBloc.iFin,">>>>>9") else "???")
            .
        run EcritDebug(TRUE,false,vcLigne).
    end.

end procedure.
    
procedure ChercheFinBloc:
 /*-------------------------------------------------------------------------*
   Objet : Recherche de la fin du bloc en cours
   Notes : ...
 *-------------------------------------------------------------------------*/
    define input parameter pcBloc   as character    no-undo.
    define input parameter piLigne  as integer      no-undo.
 
    define variable viLigneFin              as integer      no-undo.
    define variable viNiveauCommentaire     as integer      no-undo.
    define variable vlDiminuerCommentaire   as logical      no-undo.
 
    define buffer bgttLigne for gttLigne.
    
    RECHERCHE_FIN_BLOC:
    for each bgttLigne
        where bgttLigne.iLigne > piLigne
        :
        /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then do:
            run EcritDebug(false,true,"ChercheFinBloc : Commentaire ligne -> " + string(bgttLigne.iLigne)).
            next.
        end.
               
        if bgttLigne.cLigne begins("end procedure") 
        or bgttLigne.cLigne begins("end function") 
        or bgttLigne.cLigne begins("end method") 
        or bgttLigne.cLigne matches("*forward*") 
        then do:
            run EcritDebug(false,true,"ChercheFinBloc : Fin bloc trouvé ligne -> " + string(bgttLigne.iLigne)).
            viLigneFin = bgttLigne.iLigne.
            leave RECHERCHE_FIN_BLOC.
        end.
    end.

    if viLigneFin <> 0 then do:
        run EcritDebug(false,true,"ChercheFinBloc : Modification bloc").
        run ModifieBloc(pcBloc,viLigneFin).    
    end.
    
    run EcritDebug(false,true,"ChercheFinBloc : Fin de bloc à la ligne -> " + string(viLigneFin)).
    
end procedure.
    
procedure TraiteTypages:
 /*-------------------------------------------------------------------------*
   Objet : Vérification des typage des variables
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viBoucle as integer no-undo.
    define variable vcVariable as character no-undo. 
    define variable vcCodeType as character no-undo. 
    define variable vlTrouvee as logical no-undo.  

    if not gttLigne.cLigne begins "Define" then return.
    
    do viBoucle = 1 to num-entries(gcListeVariablesInt64):
        vcCodeType = "*as*int64*".
        vcVariable = "gi" + entry(viBoucle,gcListeVariablesInt64).
        vlTrouvee = gttLigne.cLigne matches "*" + vcVariable + "*".
        if not vlTrouvee then do:
            vcVariable = "vi" + entry(viBoucle,gcListeVariablesInt64).
             vlTrouvee = gttLigne.cLigne matches "*" + vcVariable + "*".
        end.
        if not vlTrouvee then do:
            vcVariable = "pi" + entry(viBoucle,gcListeVariablesInt64).
            vlTrouvee = gttLigne.cLigne matches "*" + vcVariable + "*".
        end.
        if vlTrouvee and not gttLigne.cLigne matches vcCodeType then do:
            run EcritDebug(false,true,"TraiteTypages : Variable numéro pas en int64 -> " + vcVariable).
            run EcritAnomalie("STD",gttLigne.iLigne,gcNomBloc,"G190",vcVariable). /* La variable < ... > n'est pas définie en int64 alors qu'elle le devrait */
        end.  
    end.
end procedure.
    
procedure TraiteRunInput:
 /*-------------------------------------------------------------------------*
   Objet : Recherche des occurence run....(INPUT ...
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viLigneFin              as integer      no-undo.
    define variable viNiveauCommentaire     as integer      no-undo.
    define variable vlDiminuerCommentaire   as logical      no-undo.
 
    define buffer bgttLigne for gttLigne.
    
    if not gttLigne.cLigne matches "*run *" then return.
    
    RECHERCHE_FIN_RUN:
    for each bgttLigne
        where bgttLigne.iLigne >= gttLigne.iLigne
        :
        /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.
        
        if bgttLigne.cLigne matches "*input *" then do:
            run EcritDebug(false,true,"TraiteRunInput : Input inutile").
            run EcritAnomalie("STD",bgttLigne.iLigne,gcNomBloc,"P100",""). /* La précision du type 'input' pour un paramètre de procédure/fonction/methode est inutile */
        end.
               
        /* Recherche de la fin du run */
        if bgttLigne.cLigne matches "*~~." or bgttLigne.cLigne matches "*~~. *" then do:
            leave RECHERCHE_FIN_RUN.
        end.

    end.
    
end procedure.

procedure TraiteFunctionInput:
 /*-------------------------------------------------------------------------*
   Objet : Recherche des occurence function....(INPUT ...
   Notes : ...
 *-------------------------------------------------------------------------*/
    define variable viLigneFin              as integer      no-undo.
    define variable viNiveauCommentaire     as integer      no-undo.
    define variable vlDiminuerCommentaire   as logical      no-undo.
 
    define buffer bgttLigne for gttLigne.
    
    if not gttLigne.cLigne matches "*function *" then return.
    
    RECHERCHE_FIN_FUNCTION:
    for each bgttLigne
        where bgttLigne.iLigne >= gttLigne.iLigne
        :
        /* Bypass des commentaires */
        run controleBlocCommentaire(bgttLigne.cLigne, input-output viNiveauCommentaire,input-output vlDiminuerCommentaire).
        if bgttLigne.cLigne begins "//" or viNiveauCommentaire > 0 then next.
        
        if bgttLigne.cLigne matches "*input *" then do:
            run EcritDebug(false,true,"TraiteFunctionInput : Input inutile").
            run EcritAnomalie("STD",bgttLigne.iLigne,gcNomBloc,"P110",""). /* La précision du type 'input' pour un paramètre de procédure/fonction/methode est inutile */
        end.
               
        /* Recherche de la fin de la déclaration de la fonction */
        if bgttLigne.cLigne matches "*:" or bgttLigne.cLigne matches "*: *" then do:
            leave RECHERCHE_FIN_FUNCTION.
        end.

        /* Recherche de la fin du prototype de la fonction */
        if bgttLigne.cLigne matches "*forward*" then do:
            leave RECHERCHE_FIN_FUNCTION.
        end.

    end.
    
end procedure.
    
