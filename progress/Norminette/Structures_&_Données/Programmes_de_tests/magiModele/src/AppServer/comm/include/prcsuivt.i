/*------------------------------------------------------------------------
File        : prcsuivt.i
Purpose     : Procedure pour créer le suivi des traitements dans les transferts
Author(s)   : SY 231/03/2014   -  GGA 2017/11/21
Notes       : reprise comm\prcsuivt.i
derniere revue: 2018/04/10 - phm - KO
              - traiter les todo

----------------------------------------------------------------------*/

procedure prc-Cre-Suivtrf private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter pcNomFichier     as character no-undo.
    define input parameter pcCodeTraitement as character no-undo.
    define input parameter pcUserid         as character no-undo.
    define input parameter piNombreLigne    as integer   no-undo.
    define input  parameter piNoRefTrans    as integer   no-undo.
    define variable viNumeroChrono as integer no-undo.    // TODO variable non initialisée, mais utilisée !!!!!!
    define buffer suivtrf  for suivtrf.
    define buffer demtrait for demtrait.
    define buffer chrono   for chrono.

    {&_proparse_ prolint-nowarn(nowait)}
    find first chrono exclusive-lock
        where chrono.CdTrait = pcCodeTraitement
          and chrono.soc-cd  = piNoRefTrans no-error.
    if not available chrono then do:
        create chrono.
        ASSIGN
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
        suivtrf.nochrogen   = viNumeroChrono
        suivtrf.lberr       = ""
        suivtrf.jtrait      = ?
        suivtrf.ihtrait     = 0
        suivtrf.usridtrt    = ""
        suivtrf.fgdel       = no
    .
END PROCEDURE.
