/*------------------------------------------------------------------------
File      : oscmd.p
Purpose   : Programme d'envoi/reception de fichiers dtox et telecom
Author(s) : kantena - 2018/02/18
Notes     : reprise de oscmd.w. Les traces sont sur osCommande.err (plus sur copie.err ou suppres.err).
            Rajout de la commande "move" en remplacement de "copy" + suppression = true.
------------------------------------------------------------------------*/

block-level on error undo, throw.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define input  parameter pcCommande          as character no-undo. // copy, delete, dir, compression, decompression, rename
define input  parameter pcSource            as character no-undo. // Fichier Source
define input  parameter pcCibleOuDisque   as character no-undo. // Fichier cible ou Nom du disque télécom 
define output parameter pcCodeOsError       as character no-undo. // os-error de la commande. Erreur si la décompression a échoué
define output parameter pcListeFichier      as character no-undo. // liste des fichiers si "dir", nom fichier si compression
define output parameter pcListeRepertoire   as character no-undo. // liste des sous-répertoires sir "dir"

define stream stGeneral.

define variable gcTrfRpRunTmp   as character no-undo.  // todo  a initialiser !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
define variable gcTrfRpRun      as character no-undo.

run initialisation.

function getTrflb returns character(piNumeroMessage as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer trf_lb for trf_lb.
    for first trf_Lb no-lock
        where trf_Lb.nomes = piNumeroMessage
          and trf_Lb.CdLng = mToken:iCodeLangueSession:
        return trf_Lb.lbmes.
    end.
    return "".
end function.

procedure initialisation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    todo : vérifier l'initialisation de gcTrfRpRun !!!!
    ------------------------------------------------------------------------------*/
    assign
        gcTrfRpRun    = session:temp-directory + "adb~\"
        gcTrfRpRunTmp = gcTrfRpRun + "tmp~\"
    .
    case pcCommande:
        when "copy"          then run copyFile     (pcSource, pcCibleOuDisque, output pcCodeOsError).
        when "move"          then run moveFile     (pcSource, pcCibleOuDisque, output pcCodeOsError).
        when "delete"        then run deleteFile   (pcSource, output pcCodeOsError).
        when "dir"           then run getDirectory (pcSource, output pcListeFichier, output pcListeRepertoire).
        when "compression"   then run compression  (pcSource, pcCibleOuDisque, output pcListeFichier).
        when "decompression" then run decompression(pcSource, pcCibleOuDisque, output pcCodeOsError).
        when "rename"        then run renameFile   (pcSource, pcCibleOuDisque, output pcCodeOsError).
    end case.

end procedure.

procedure compression:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcFichierSource as character no-undo.
    define input  parameter pcDisque        as character no-undo.
    define output parameter pcFichierCible  as character no-undo.

    define variable vcFichierCommande as character no-undo initial "compress.bat".
    
    output stream stGeneral to value(gcTrfRpRunTmp + vcFichierCommande).
    put stream stGeneral unformatted
        "cd " pcDisque skip
        gcTrfRpRun "zc -C " pcFichierSource skip
    .
    output stream stGeneral close.
    os-command silent value(gcTrfRpRunTmp + vcFichierCommande).    
    pcFichierCible = if search(pcFichierSource + "ZZ") <> ? then pcFichierSource + "ZZ" else pcFichierSource.

end procedure.

procedure decompression:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: pcFichierSource ne doit pas contenir de ZZ 
    ------------------------------------------------------------------------------*/
    define input  parameter pcFichierSource as character no-undo.
    define input  parameter pcDisque        as character no-undo.
    define output parameter pcCodeRetour    as character no-undo.

    define variable vcFichierCommande as character no-undo initial "decompre.bat".

    output stream stGeneral to value(gcTrfRpRunTmp + vcFichierCommande).
    put stream stGeneral unformatted
        "cd " pcDisque skip
        gcTrfRpRun "zc -d " pcFichierSource skip
    .
    output stream stGeneral close.
    os-command silent value(gcTrfRpRunTmp + vcFichierCommande).
    pcCodeRetour = if search(pcFichierSource + "ZZ") <> ? then "Erreur" else "Ok".

end procedure.

procedure copyFile:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcFichierSource as character no-undo.
    define input  parameter pcFichierCible  as character no-undo.
    define output parameter pcCodeRetour    as character no-undo.

    define variable vcErrorMessage as character no-undo.

    output stream stGeneral to value(gcTrfRpRunTmp + "osCommande.err") append.
    put stream stGeneral unformatted 
        "Copie de " pcFichierSource " vers " pcFichierCible " le " string(today, "99/99/9999") " à " string(time,"hh:mm:ss") "." skip
    .
    output stream stGeneral close.

    os-copy value(pcFichierSource) value(pcFichierCible).

    output stream stGeneral to value(gcTrfRpRunTmp + "osCommande.err") append.
    if search(pcFichierCible) = ? or os-error > 0 then do:
        assign
            pcCodeRetour   = string(os-error)
            vcErrorMessage = getTrflb(100033)
        .
        if vcErrorMessage = ""
        then vcErrorMessage = "erreur de copie de &1 vers &2 le &3 à &4 (os-erreur:&5).".
        vcErrorMessage = substitute(vcErrorMessage, pcFichierSource, pcFichierCible, string(today, "99/99/9999"), string(time, "hh:mm:ss"), os-error).
        mError:createError({&erreur}, vcErrorMessage).
        put stream stGeneral unformatted vcErrorMessage skip(2).
    end.
    else put stream stGeneral unformatted "Copie effectuée." skip(2).
    output stream stGeneral close.

end procedure.

procedure moveFile:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcFichierSource as character no-undo.
    define input  parameter pcFichierCible  as character no-undo.
    define output parameter pcCodeRetour    as character no-undo.

    define variable vcFichierCommande as character no-undo initial "moveFile.bat".
    define variable vcErrorMessage    as character no-undo.

    output stream stGeneral to value(gcTrfRpRunTmp + "osCommande.err") append.
    put stream stGeneral unformatted 
        "Déplacement de " pcFichierSource " vers " pcFichierCible " le " string(today, "99/99/9999") " à " string(time,"hh:mm:ss") "." skip
    .
    output stream stGeneral close.

    output stream stGeneral to value(gcTrfRpRunTmp + vcFichierCommande).
    put stream stGeneral unformatted 'move /Y "' pcFichierSource '" "' pcFichierCible '"'skip.
    output stream stGeneral close.
    os-command silent value(gcTrfRpRunTmp + vcFichierCommande).

    output stream stGeneral to value(gcTrfRpRunTmp + "osCommande.err") append.
    if search(pcFichierCible) = ? or os-error > 0 then do:
        assign
            pcCodeRetour   = string(os-error)
            vcErrorMessage = "erreur de déplacement de &1 vers &2 le &3 à &4 (os-erreur:&5)."
            vcErrorMessage = substitute(vcErrorMessage, pcFichierSource, pcFichierCible, string(today, "99/99/9999"), string(time, "hh:mm:ss"), os-error)
        .
        mError:createError({&erreur}, vcErrorMessage).
        put stream stGeneral unformatted vcErrorMessage skip(2).
    end.
    else put stream stGeneral unformatted "Déplacement effectué." skip(2).
    output stream stGeneral close.

end procedure.

procedure getDirectory:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcDirectory   as character no-undo.
    define output parameter pcFichiers    as character no-undo.
    define output parameter pcRepertoires as character no-undo.

    define variable vcNom  as character no-undo.
    define variable vcType as character no-undo.

    input stream stGeneral from os-dir(pcDirectory).
boucleRepertoire:
    repeat:
        import stream stGeneral vcNom ^ vcType.
        if vcNom begins "." then next boucleRepertoire.

        if vcType = "D" then pcRepertoires = pcRepertoires + "," + vcNom. // On ne prend pas les DH (hidden directory)
        if vcType = "F" then pcFichiers    = pcFichiers    + "," + vcNom. // On ne prend pas les FH (hidden file)
    end.
    input stream stGeneral close.
    assign
        pcFichiers    = trim(pcFichiers, ",")
        pcRepertoires = trim(pcRepertoires, ",")
    .
end procedure.

procedure renameFile:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcFichierSource as character no-undo.
    define input  parameter pcFichierCible  as character no-undo.
    define output parameter pcCodeRetour    as character no-undo.

    define variable vcErrorMessage as character no-undo.

    output stream stGeneral to value(gcTrfRpRunTmp + "osCommande.err") append.
    put stream stGeneral unformatted 
        "Renommage du fichier " pcFichierSource " en " pcFichierCible " le " string(today, "99/99/9999") " à " string(time,"hh:mm:ss") "." skip
    .
    output stream stGeneral close.

    os-rename value(pcFichierSource) value(pcFichierCible).

    output stream stGeneral to value(gcTrfRpRunTmp + "osCommande.err") append.
    if search(pcFichierCible) = ? or os-error > 0 then do:
        assign
            pcCodeRetour   = string(os-error)
            vcErrorMessage = substitute("Impossible de renommer le fichier &1 en &2 (os-erreur:&3).", pcFichierSource, pcFichierCible, os-error)
        .
        mError:createError({&erreur}, vcErrorMessage).
        put stream stGeneral unformatted vcErrorMessage skip(2).
    end.
    else put stream stGeneral unformatted "Renommage effectué." skip(2).
    output stream stGeneral close.
    
end procedure.

procedure deleteFile:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcFichier    as character no-undo.
    define output parameter pcCodeRetour as character no-undo.

    define variable vcErrorMessage as character no-undo.

    output stream stGeneral to value(gcTrfRpRunTmp + "osCommande.err") append.
    put stream stGeneral unformatted 
        "Suppression de " pcFichier " le " string(today, "99/99/9999") " à " string(time,"hh:mm:ss") "." skip
    .
    output stream stGeneral close.

    os-delete value(pcFichier).

    output stream stGeneral to value(gcTrfRpRunTmp + "osCommande.err") append.
    if os-error > 0 then do:
        assign
            pcCodeRetour   = string(os-error)
            vcErrorMessage = getTrflb(100216)
        .
        if vcErrorMessage = ""
        then vcErrorMessage = "Suppression impossible du fichier &1, le &2 à &3 (os-erreur:&4).".
        vcErrorMessage = substitute(vcErrorMessage, pcFichier, string(today, "99/99/9999"), string(time, "HH:MM:SS"), os-error).
        mError:createError({&erreur}, vcErrorMessage).
        put stream stGeneral unformatted vcErrorMessage skip(2).
    end.
    else put stream stGeneral unformatted "Suppression effectuée." skip(2).
    output stream stGeneral close.

end procedure.
