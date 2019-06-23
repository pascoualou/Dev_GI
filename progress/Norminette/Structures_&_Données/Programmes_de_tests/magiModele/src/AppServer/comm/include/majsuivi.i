/*------------------------------------------------------------------------
File        : majsuivi.i
Purpose     : Procedure pour maj suivi des envois (SuivTrf)
Author(s)   : SY 25/11/2015  -  GGA 2017/11/21
              1115/0254 transfert automatisé
              Réunion du 16/09/2015 Charles/Eric Marchand
Notes       : reprise comm\majsuivi.i
derniere revue: 2018/04/10 - phm - KO
             - traiter les todo
----------------------------------------------------------------------*/

PROCEDURE Maj_SuivTrf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcListefichier       as character no-undo.
    define input parameter piReferenceTransfert as integer   no-undo.
    define input parameter pcRepertoireGI       as character no-undo.
    define input parameter pcComment            as character no-undo.
    define input parameter pcUserid             as character no-undo.
    define input parameter plModeCopie          as logical   no-undo.
    define input parameter pcRepertoireSVG      as character no-undo.       /* répertoire de sauvegarde si on veut garder une copie */

    define variable viCompteur      as integer   no-undo.
    define variable vcNomFichier    as character no-undo.
    define variable vlDejaCompresse as logical   no-undo.
    define buffer suivtrf   for suivtrf.
    define buffer vbSuivtrf for suivtrf.

    if plModeCopie then do:
        file-info:file-name = pcRepertoireSVG.
        if file-info:file-type = ? then plModeCopie = false.
    end.
    do viCompteur = 1 to num-entries(pcListefichier, ","):
        assign
            vcNomFichier    = entry(viCompteur, pcListefichier, ",")
            vlDejaCompresse = num-entries(vcNomFichier,".") > 1 and entry(2, vcNomFichier, ".") = "7z"
        .
        for each suivtrf exclusive-lock
            where suivtrf.soc-cd     = piReferenceTransfert
              and suivtrf.jTrait     = ?
              and suivtrf.ihTrait    = 0
              and suivtrf.sens       = "E"
              and suivtrf.nmfichier  = (if vlDejaCompresse then vcNomFichier else entry(1, vcNomFichier, "."))
              and suivtrf.nochrotel  = (if vlDejaCompresse then 0 else integer(entry(2, vcNomFichier, "."))):
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last vbSuivtrf no-lock use-index suivtrf_idx1 no-error.
            if available vbSuivtrf
            then suivtrf.nocr = vbSuivtrf.nocr + 1.
            assign
                suivtrf.jTrait    = today
                suivtrf.ihTrait   = integer(replace(string(time, "HH:MM:SS"), ":", ""))
                suivtrf.lbsuivtrf = suivtrf.lbsuivtrf + (if suivtrf.lbsuivtrf > "" then "|" else "") + pcComment
                suivtrf.usridtrt  = pcUserid
            .
            if search(pcRepertoireGI + vcNomFichier) <> ? then do:
                /*TODO : A GARDER????   */
                /* Sauvegarde du fichier dans le répertoire donné en entrée */
                /*IF plModeCopie THEN DO:
                    { oscopy.i &SOURCE = "pcRepertoireGI + vcNomFichier" &TARGET = "pcRepertoireSVG" }
                END.*/  /* à développer plus tard... */
                mLogger:writeLog(1, "Maj_suivtrf : delete fichier " + pcRepertoireGI + vcNomFichier).
                os-delete value(pcRepertoireGI + vcNomFichier).
            END.
        end.
    end.

END PROCEDURE.
