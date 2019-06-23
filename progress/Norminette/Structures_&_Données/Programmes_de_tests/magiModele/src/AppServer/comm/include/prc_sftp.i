/*------------------------------------------------------------------------
File        : prc_sftp.i
Purpose     : Procedure pour envoi automatique des fichiers par SFTP (d'après envrecep.w)
Author(s)   : SY 25/11/2015  -  GGA 2017/11/21
              1115/0254 transfert automatisé
              Réunion du 16/09/2015 Charles/Eric Marchand
Notes       : reprise comm/prc_sftp.i
derniere revue: 2018/04/10 - phm - KO
               - procedure operation_envoi_telecom:
               - remplacer os-getenv("telecomGI")
               - traiter les todo

----------------------------------------------------------------------*/

{comm/include/majsuivi.i}    /* PROCEDURE Maj_SuivTrf: */

function sftp-Verif-install returns logical(pcRepertoireTransfert as character, output pcMessageErreur as character):
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    /* vérifier si option SFTP */
    if not can-find(first iparm no-lock
                    where iparm.tppar = "TTEL"
                      and iparm.zone2 = "3") then return false.

    if search(pcRepertoireTransfert + "winscp.com") = ?
    then do:
        pcMessageErreur = replace(outilTraduction:getLibelleTransfert(101070), "&1", pcRepertoireTransfert + 'winscp.com'). /** "Le programme n'existe pas." **/
        return false.
    end.
    if search(pcRepertoireTransfert + "winscp.exe") = ?
    then do:
        pcMessageErreur = replace(outilTraduction:getLibelleTransfert(101070), "&1", pcRepertoireTransfert + 'winscp.exe'). /** "Le programme n'existe pas." **/
        return false.
    end.
    if search(pcRepertoireTransfert + "zc.exe") = ?
    then do:
        pcMessageErreur = replace(outilTraduction:getLibelleTransfert(101070), "&1", pcRepertoireTransfert + 'zc.exe'). /** "Le programme n'existe pas." **/
        return false.
    end.
    return true.

end function.

procedure sftp-envoi:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : c.f. Envoi-sftp dans envrecep.w
    ------------------------------------------------------------------------------*/
    define input  parameter piReferenceTransfert   as integer   no-undo.
    define input  parameter pcListeEnvoi           as character no-undo.
    define input  parameter pcListeTelecom         as character no-undo.
    define input  parameter plModeDebug            as logical   no-undo.
    define input  parameter plModeCopie            as logical   no-undo.
    define input  parameter pcRepertoireSauvegarde as character no-undo.   /* répertoire de sauvegarde si on veut garder une copie */
    define input  parameter pcRepertoireTransfert  as character no-undo.
    define input  parameter pcRepertoireGI         as character no-undo.
    define input  parameter pcRepertoireTMP        as character no-undo.
    define output parameter piNumeroErreur         as integer   no-undo.
    define output parameter pcMessageErreur        as character no-undo.

    define variable vcListeCgi     as character no-undo.
    define variable vcListeCgi-OK  as character no-undo.
    define variable vcListeTelecom as character no-undo.
    define variable vcItem         as character no-undo.
    define variable viCompteur     as integer   no-undo.
    define variable viEntree       as integer   no-undo.

    /* Copie des fichiers dans tel_cgi */
    run operation_Envoi_telecom(piReferenceTransfert, pcListeEnvoi, pcListeTelecom, pcRepertoireGI, pcRepertoireTMP, output vcListeCgi).
    /* Lancement du transfert SFTP */
    run sftp-envoi-2(
        piReferenceTransfert,
        pcListeTelecom,
        plModeDebug,
        pcRepertoireTransfert,
        output piNumeroErreur,
        output pcMessageErreur,
        output vcListeTelecom        /* liste des fichiers avec envoi OK */
    ).
    /* Suppression des fichiers de TELECOM/tel_cgi dans tous les cas */
    run sftp-operation("SFTPE", pcListeTelecom).
    if piNumeroErreur > 0 then return.

    // vcListeCgi est la liste des fichiers dont la télélcom a réussi (liste est sous la forme q06505.01,e06505.02).
    do viCompteur = 1 to num-entries(vcListeTelecom):
        assign
            vcItem   = entry(viCompteur, vcListeTelecom)
            viEntree = lookup(vcItem, pcListeTelecom)
        .
        if viEntree > 0 then vcListeCgi-OK = vcListeCgi-OK + "," + entry(viEntree , vcListeCgi).
    END.
    vcListeCgi-OK = trim(vcListeCgi-OK, ",").

     /*******************************************************************
     Pour tous les fichiers bien envoyés (vcListeCgi):
        - Mise a jour du suivi
        - copie éventuelle de sauvegarde
        - suppression de trans/cgi.
     ********************************************************************/
    run maj_SuivTrf(
        vcListeCgi-OK,
        piReferenceTransfert,
        pcRepertoireGI,
        "",
        mToken:cUser,
        plModeCopie,
        pcRepertoireSauvegarde   /* répertoire de sauvegarde si on veut garder une copie */
    ).
    if num-entries(pcListeTelecom) > num-entries(vcListeTelecom) then do:
        assign
            piNumeroErreur  = 40
            pcMessageErreur = substitute("Transfert incomplet (&1/&2)", num-entries(vcListeTelecom), num-entries(pcListeTelecom))
        .
        return.
    end.
end procedure.

procedure operation_envoi_telecom:
    /*------------------------------------------------------------------------------
    Purpose: Copie des fichiers dans tel_cgi
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piReferenceTransfert as integer   no-undo.
    define input  parameter pcListeTelcgi        as character no-undo.
    define input  parameter pcListeTelecom       as character no-undo.
    define input  parameter pcRepertoireGI       as character no-undo.
    define input  parameter pcRepertoireTMP      as character no-undo.
    define output parameter pcListeUnite99       as character no-undo.

    define variable viCompteur            as integer no-undo.
    define variable vcItem                as character no-undo.
    define variable vcNomFichier          as character no-undo.
    define variable viNumeroFichier       as integer   no-undo.
    define variable vcNomCompresse        as character no-undo.
    define variable vlDejaCompresse       as logical   no-undo.
    define variable vcRepertoireTelecomGI as character no-undo.
    define variable vcDisqueTelecomGI     as character no-undo.
    define variable vcFichierCommande     as character no-undo.
    define variable vcOsError             as character no-undo.
    define variable vcListe               as character no-undo.
    define variable vcListeFic            as character no-undo.

    vcRepertoireTelecomGI = replace(os-getenv("telecomGI"), "~\", "/").  // todo remplacer os-getenv.
    if vcRepertoireTelecomGI <> ? and substring(vcRepertoireTelecomGI, length(vcRepertoireTelecomGI, "character"), 1, "character") <> "/"
    then vcRepertoireTelecomGI = vcRepertoireTelecomGI + "/".
    assign
        vcDisqueTelecomGI = substring(vcRepertoireTelecomGI, 1, 2, "character")
        vcFichierCommande = "tel-cgi.bat"
    .
    do viNumeroFichier = 1 to num-entries(pcListeTelcgi):
        assign
            vcNomFichier    = entry(viNumeroFichier, pcListeTelcgi, ",")
            vlDejaCompresse = num-entries(vcNomFichier, ".") > 1 and entry(2, vcNomFichier, ".") = "7z"
            vcItem          = if vlDejaCompresse then vcNomFichier else entry(viNumeroFichier, pcListeTelecom, ",")
            vcNomCompresse  = vcItem + (if vlDejaCompresse then "" else "ZZ")
        .
        /* Le fichier vcItem est-il deja present dans le repertoire d'envoi ?
           Si oui, il faut l'effacer. Le nom telecom est unique pour chaque traitement. Donc
           si le fichier est toujours pr‚sent dans le repertoire d'envoi, cela signifie que
           l'on souhaite renvoyer le mˆme fichier car il y a eu un probleme … la transmission.
           Il faut verifier le cas ou le fichier telecom a ete compresse‚.
        */
        if search(vcRepertoireTelecomGI + 'tel_cgi/' + vcItem) <> ?
        then run comm/oscmd.p(
            "delete",
            vcRepertoireTelecomGI + 'tel_cgi/' + vcItem,
            "",
            output vcOsError,
            output vcListe,
            output vcListeFic).
        if search(vcRepertoireTelecomGI + 'tel_cgi/' + vcNomCompresse) <> ?
        then run comm/oscmd.p(
            "delete",
            vcRepertoireTelecomGI + 'tel_cgi/' + vcNomCompresse,
            "",
            output vcOsError,
            output vcListe,
            output vcListeFic).
        /* copie vers tel_cgi */
        run comm/oscmd.p(
            "copy",
            pcRepertoireGI + vcNomFichier,
            vcRepertoireTelecomGI + "tel_cgi/" + vcItem,
            output vcOsError,
            output vcListe,
            output vcListeFic).
        /* compression */
        if not vlDejaCompresse
        then run comm/oscmd.p(
            "compression",
            vcRepertoireTelecomGI + "tel_cgi/" + vcItem,
            vcDisqueTelecomGI,
            output vcOsError,
            output vcListe,
            output vcListeFic).
        pcListeUnite99 = pcListeUnite99 + "," + vcItem.
    end.
    pcListeUnite99 = trim(pcListeUnite99, ",").
    output to value(pcRepertoireTMP + vcFichierCommande).
    put unformatted
        "cd " vcRepertoireTelecomGI "tel_cgi" skip
        vcDisqueTelecomGI skip.
    if search(pcRepertoireTMP + "compress.bat") <> ?
    then put unformatted
        "copy " pcRepertoireTMP "compress.bat " pcRepertoireTMP + string(piReferenceTransfert, "99999") ".txt" skip.
    output close.

    /* Execution du .bat */
    os-command silent value(pcRepertoireTMP + vcFichierCommande).
    if search(pcRepertoireTMP + "compress.bat") = ? then do:
        output to value(pcRepertoireTMP + string(piReferenceTransfert, "99999" ) + ".txt").
        put unformatted "copie terminée" skip.
        output close.
    end.

    /* temporisation avant de lancer le modem pour l'envoi télécom.
       Il faut attendre que la copie des fichiers dans tel_cgi soit complètement terminée. */
boucle:
    do viCompteur = 1 to 10:
        if search(pcRepertoireTMP + string(piReferenceTransfert, "99999") + ".txt") <> ?
        then do:
            /*** Le fichier 99999.txt existe donc la copie des fichiers est finie ***/
            os-delete value(pcRepertoireTMP + string(piReferenceTransfert, "99999") + ".txt").
            leave boucle.
        end.
        pause 1 no-message.
    end.
end procedure.

procedure sftp-operation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTransfert as character no-undo.
    define input  parameter pcListeTelcgi   as character no-undo.

    define variable vcItem                as character no-undo.
    define variable viNumeroFichier       as integer   no-undo.
    define variable vcRepertoireTelecomGI as character no-undo.
    define variable vcOsError             as character no-undo.
    define variable vcListe               as character no-undo.
    define variable vcListeFic            as character no-undo.

    vcRepertoireTelecomGI = replace(os-getenv("telecomGI"), "~\", "/").
    if vcRepertoireTelecomGI <> ? and substring(vcRepertoireTelecomGI, length(vcRepertoireTelecomGI, "character"), 1, "character") <> "/"
    then vcRepertoireTelecomGI = vcRepertoireTelecomGI + "/".
    case pcTypeTransfert:
        when "SFTPE" then do viNumeroFichier = 1 to num-entries(pcListeTelcgi):
            vcItem = entry(viNumeroFichier, pcListeTelcgi).
            if vcItem begins "BDF" then do:
                if search(substitute("&1tel_cgi/&2ZZ", vcRepertoireTelecomGI, vcItem)) <> ? then do:
                    mLogger:writeLog(1, substitute("sftp-operation: delete fichier &1tel_cgi/&2ZZ", vcRepertoireTelecomGI, vcItem)).
                    run comm/oscmd.p(
                        "delete",
                        substitute('&1tel_cgi/&2ZZ', vcRepertoireTelecomGI, vcItem),
                        "",
                        output vcOsError,
                        output vcListe,
                        output vcListeFic).
                end.
            end.
            else if search(vcRepertoireTelecomGI + 'tel_cgi/' + vcItem) <> ? then do:
                mLogger:writeLog(1, substitute("sftp-operation: delete fichier &1tel_cgi/&2", vcRepertoireTelecomGI, vcItem)).
                run comm/oscmd.p(
                    "delete",
                    vcRepertoireTelecomGI + 'tel_cgi/' + vcItem,
                    "",
                    output vcOsError,
                    output vcListe,
                    output vcListeFic).
            end.
        end.
    end case.
end procedure.

procedure sftp-envoi-2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piReferenceTransfert   as integer   no-undo.
    define input  parameter pcListeTelecomIN       as character no-undo.
    define input  parameter plModeDebug            as logical   no-undo.
    define input  parameter  pcRepertoireTransfert as character no-undo.
    define output parameter piNumeroErreur         as integer   no-undo.
    define output parameter pcMessageErreur        as character no-undo.
    define output parameter pcListeTelecomOUT      as character no-undo.

    define variable viNumeroFichier       as integer   no-undo.
    define variable viNombreFichier       as integer   no-undo.
    define variable vcItem                as character no-undo.
    define variable viReferenceFTP        as integer   no-undo.
    define variable vcRepertoireTelecomGI as character no-undo.
    define variable vcLigne               as character no-undo.

    define buffer isoc  for isoc.
    define buffer vbIsoc for isoc.

    vcRepertoireTelecomGI = replace(os-getenv("telecomGI"), "~\", "/").    // todo remplacer os-getenv
    if vcRepertoireTelecomGI <> ? and substring(vcRepertoireTelecomGI, length(vcRepertoireTelecomGI, "character"), 1, "character") <> "/"
    then vcRepertoireTelecomGI = vcRepertoireTelecomGI + "/".

    /** Suppression des fichiers log du transfert précédent ,
    si le tranfert précédent a échoué, les fichiers .log ne peuvent être supprimés **/
    if search(session:temp-directory + "sputfile1.log" ) <> ?
    then os-delete value(session:temp-directory + "sputfile1.log").
    if search(session:temp-directory + "sputfile2.log" ) <> ?
    then os-delete value(session:temp-directory + "sputfile2.log").
    if search(session:temp-directory + "sputfile3.log" ) <> ?
    then os-delete value(session:temp-directory + "sputfile3.log").

    if search(session:temp-directory + "sputfile1.log" ) <> ? or search(session:temp-directory + "sputfile2.log" ) <> ?
    then do:
        assign
            piNumeroErreur  = 20
            pcMessageErreur = substitute("Le transfert précédent ne s'est pas correctement terminé. Veuillez redémarrer l'ordinateur. (Erreur no &1)", piNumeroErreur)
        .
        return.
    end.
    /*gga pour le moment pas de reprise de osdelete.i mais reprise du code
        { osdelete.i &fichier = "SESSION:TEMP-DIRECTORY + 'log-putfile'" }
    gga*/
    os-delete value(session:temp-directory + 'log-putfile').
    empty temp-table w_file.
    viReferenceFTP = piReferenceTransfert.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for first isoc no-lock
        where isoc.soc-cd = viReferenceFTP
          and isoc.specif-cle <> 1000
      , first vbIsoc no-lock                 // TODO   Dauchez = 2 réf à 1000, laquelle on prend?????????
        where vbIsoc.specif-cle = 1000:
        viReferenceFTP = vbIsoc.soc-cd.
    end.

    /* Génération du script */
    /*--------------------------------------------------------------------------
    #Generate temporary script to upload
    option batch on
    option confirm off
    open "la-gi_06505"
    put "C:/TELECOM/tel_cgi/PZ_06505_RATORG_20151126_43005.7zZZ" ./IN/
    close
    exit
    -----------------------------------------------------------------------------*/
    output to value(os-getenv("TMP") + "/putfile.ssh").    // todo  remplacer os-getenv
    put unformatted
        "#Generate temporary script to upload" skip
        "option batch on" skip
        "option confirm off" skip
    /*PUT UNFORMATTED 'open "la-gi_99998"'  SKIP. */
        'open "la-gi_' string(viReferenceFTP, "99999") '"' skip
    .
    do viNumeroFichier = 1 to num-entries(pcListeTelecomIN):
        vcItem = entry(viNumeroFichier, pcListeTelecomIN, ",").
        if search(vcRepertoireTelecomGI + "tel_cgi/" + vcItem) <> ?
        then put unformatted 'put "' vcRepertoireTelecomGI 'tel_cgi/' vcItem '" ./in/"'  skip.
        else put unformatted 'put "' vcRepertoireTelecomGI 'tel_cgi/' vcItem 'ZZ" ./in/' skip.
        viNombreFichier = viNombreFichier + 1.
    end.
    put unformatted
        "close" skip
        "exit"  skip.
    output close.
    output to value(os-getenv("TMP") + "/sputfile.bat").
    put unformatted
        skip(1)
        "REM Execute script" skip
/*   PUT UNFORMATTED SUBSTRING(RpRunTrf,1,2) SKIP. */
        pcRepertoireTransfert "winscp.com /script=" os-getenv("TMP") "/putfile.ssh /log=" session:temp-directory "log-putfile" skip
        "echo %errorlevel% > %tmp%/sputfile3.log" skip
        "exit" skip
    .
    output close.
    if plModeDebug
    then os-command        value(os-getenv("TMP") + "/sputfile.bat 1>sputfile1.log 2>sputfile2.log").    // todo  remplacer os-getenv
    else os-command silent value(os-getenv("TMP") + "/sputfile.bat 1>sputfile1.log 2>sputfile2.log").

    /* errorlevel n'est utilisable que pour le transfert d'un seul fichier (à confirmer ?)*/
    if viNombreFichier = 1 then do:
        /* C:/Users/devsp/AppData/Local/Temp/sputfile3.log  */
        run errorlevel-SFTP(os-getenv("tmp") + "/sputfile3.log", plModeDebug, output piNumeroErreur, output pcMessageErreur).
        if piNumeroErreur > 0 then do:
            if plModeDebug then mLogger:writeLog(1, "sftp-envoi-2 : errorlevel-SFTP " + pcMessageErreur).
            return.
        end.
    end.
    file-info:file-name = session:temp-directory + "log-putfile".
    if file-info:file-size = 0 or file-info:file-size = ? then do:
        assign
            piNumeroErreur  = 22
            pcMessageErreur = substitute("Fichier &1log-putfile vide ou inexistant (Erreur no &2)", session:temp-directory, piNumeroErreur)
        .
        if plModeDebug then mLogger:writeLog(1, "sftp-envoi-2 : " + pcMessageErreur).
        return.
    end.
    file-info:file-name = session:temp-directory + "sputfile1.log".
    if file-info:file-size = 0 or file-info:file-size = ? then do:
        assign
            piNumeroErreur  = 23
            pcMessageErreur = substitute("Fichier &1sputfile1.log vide ou inexistant (Erreur no &2)", session:temp-directory, piNumeroErreur)
        .
        if plModeDebug then mLogger:writeLog(1, "sftp-envoi-2 : " + pcMessageErreur).
        return.
    end.
    if plModeDebug
    then os-command value(substitute("start /w notepad &1log-putfile", session:temp-directory)).

    input from value(session:temp-directory + "sputfile1.log").
    repeat:
        import unformatted vcLigne no-error.
        /* C:/TELECOM/tel_cgi/PZ_06505_EXPORTSAL_20151130_54399.7z |          0 KiB |    0,0 KiB/s | binary | 100% */
        if vcLigne matches "*|*" and num-entries(vcLigne, "|") >= 5
        then do:
            find first w_file where w_file.putfile matches substitute("*&1*", entry(1, vcLigne, "|")) no-error.
            if not available w_file
            then create w_file.
            assign
                w_file.putfile = substring(entry(1, vcLigne, "|"), index(entry(1, vcLigne, "|"), "tel_cgi"))
                w_file.transfer = trim(entry(5, vcLigne, "|"))
            .
            if w_file.transfert = "100%"
            then pcListeTelecomOUT = pcListeTelecomOUT + "," + trim(replace(w_file.putfile, "tel_cgi/", "")).
        end.
        else if vcLigne matches "Host does not exist*" then do:
            assign
                piNumeroErreur  = 24
                pcMessageErreur = substitute("Erreur de paramétrage winscp (&1) (Erreur no &2)", vcLigne, piNumeroErreur)
            .
            if plModeDebug then mLogger:writeLog(1, "sftp-envoi-2 : " + pcMessageErreur).
        end.
    end.
    input close.
    pcListeTelecomOUT = trim(pcListeTelecomOUT, ",").
    if plModeDebug then mLogger:writeLog(1, substitute("sftp-envoi-2: piNumeroErreur = &1 pcListeTelecomOUT = &2", piNumeroErreur, pcListeTelecomOUT)).
/*    {vidage.i w_file}*/
    if piNumeroErreur > 0 then return.
/*
    if not plModeDebug then do:
         { osdelete.i &fichier = "OS-GETENV('TMP') + '/putfile.ssh'" }
         { osdelete.i &fichier = "SESSION:TEMP-DIRECTORY + 'log-putfile'" }

    end.
*/
end procedure.

procedure errorlevel-SFTP:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    todo : traduction
    ------------------------------------------------------------------------------*/
    define input  parameter pcTempFilename  as character no-undo.
    define input  parameter plModeDebug     as logical   no-undo.
    define output parameter piNumeroErreur  as integer   no-undo.
    define output parameter pcMessageErreur as character no-undo.

    define variable vcLigne as character no-undo.

    if search(pcTempFilename) <> ? then do:
        input from value(pcTempFilename) no-echo.
        import unformatted vcLigne.
        case vcLigne:
            when "4" then assign
                piNumeroErreur  = 34
                pcMessageErreur = substitute("Erreur SFTP no &1 - consulter le fichier log.xml (Erreur GI no &2)", vcLigne, piNumeroErreur)
            .
            when "3" then assign
                piNumeroErreur  = 33
                pcMessageErreur = "Erreur SFTP - consulter le fichier log.xml"
            .
            when "2" then assign
                piNumeroErreur  = 32
                pcMessageErreur = substitute("Erreur SFTP no &1 - consulter le fichier log.xml (Erreur GI no &2)", vcLigne, piNumeroErreur)
            .
            when "1" then assign
                piNumeroErreur  = 31
                pcMessageErreur = substitute("Erreur SFTP no &1 - Le site de connexion est inconnu (Erreur GI no &2)", vcLigne, piNumeroErreur)
            .
        end case.
        input close.
    end.
    if plModeDebug
    then mLogger:writeLog(1, substitute("errorlevel-SFTP: &1 => &2", pcTempFilename, if piNumeroErreur = 0 then "OK" else pcMessageErreur)).
end procedure.
