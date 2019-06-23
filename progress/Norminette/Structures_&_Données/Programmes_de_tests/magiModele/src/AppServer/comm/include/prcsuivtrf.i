/*------------------------------------------------------------------------
File        : prcsuivtrf.i
Purpose     : diverse procedure de traitement table suivtrf
Author(s)   : SY 231/03/2014   -  GGA 2017/11/21
Notes       : reprise comm\prcsuivt.i
derniere revue: 2018/04/10 - phm - 
----------------------------------------------------------------------*/

procedure creSuivtrf private:
    /*------------------------------------------------------------------------------
    purpose: Procedure pour créer le suivi des traitements dans les transferts
    Note   : reprise comm\prcsuivt.i
    ------------------------------------------------------------------------------*/
    define input parameter pcNomFichier     as character no-undo.
    define input parameter pcCodeTraitement as character no-undo.
    define input parameter pcUserid         as character no-undo.
    define input parameter piNombreLigne    as integer   no-undo.
    define input  parameter piNoRefTrans    as integer   no-undo.

    define buffer suivtrf  for suivtrf.
    define buffer demtrait for demtrait.
    define buffer chrono   for chrono.

    {&_proparse_ prolint-nowarn(nowait)}
    find first chrono exclusive-lock
        where chrono.CdTrait = pcCodeTraitement
          and chrono.soc-cd  = piNoRefTrans no-error.
    if not available chrono then do:
        create chrono.
        assign
            chrono.cdTrait    = pcCodeTraitement
            chrono.soc-cd     = piNoRefTrans
            chrono.nochrodisq = 1
        .
    end.
    else chrono.noChroDisq = if chrono.noChroDisq <> 9999 then chrono.noChroDisq + 1 else 1.

    find first demtrait no-lock
        where demtrait.cdtrait = pcCodeTraitement no-error.
    create suivtrf.
    assign
        suivtrf.soc-cd      = piNoRefTrans
        suivtrf.moiscpt     = 0
        suivtrf.nmfichier   = pcNomFichier
        suivtrf.cdtrait     = pcCodeTraitement
        suivtrf.jcretrf     = today
        suivtrf.ihcretrf    = integer(replace(string(time, "HH:MM:SS"), ":", ""))
        suivtrf.usrid       = pcUserid
        suivtrf.nochrotel   = 0
        suivtrf.nochrodis   = chrono.NoChroDisq
        suivtrf.normsup     = ""
        suivtrf.fgregen     = no
        suivtrf.support     = "T"
        suivtrf.fgencours   = no
        suivtrf.nocr        = 0
        suivtrf.lbsuivtrf   = ""
        suivtrf.nblig       = piNombreLigne
        suivtrf.gest-cle    = ""
        suivtrf.accretour   = no
        suivtrf.nochroretour= 0
        suivtrf.cdretour    = ""
        suivtrf.sens        = (if available demtrait then demtrait.sens else "E")
        suivtrf.nochrogen   = 0
        suivtrf.lberr       = ""
        suivtrf.jtrait      = ?
        suivtrf.ihtrait     = 0
        suivtrf.usridtrt    = ""
        suivtrf.fgdel       = no
    .
end procedure.

procedure majSuivTrf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:    reprise comm\majsuivi.i
    
    
pas de revue les procedures de transfert de fichier sont a revoir 


derniere revue: 2018/04/10 - phm - KO
             - traiter les todo
    
    
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
              and suivtrf.nochrotel  = (if vlDejaCompresse then 0 else integer(entry(2, vcNomFichier, ".")))
        use-index suivtrf_idx3:
            for last vbSuivtrf no-lock 
            use-index suivtrf_idx1:
                suivtrf.nocr = vbSuivtrf.nocr + 1.
            end.
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
                mLogger:writeLog(1, "majSuivTrf : delete fichier " + pcRepertoireGI + vcNomFichier).
                os-delete value(pcRepertoireGI + vcNomFichier).
            end.
        end.
    end.

end procedure.
