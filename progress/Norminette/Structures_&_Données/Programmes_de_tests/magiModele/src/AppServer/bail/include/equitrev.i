/*------------------------------------------------------------------------
File        : equitrev.i
Purpose     : sauvegarde equit avant revision
Author(s)   : SY - 2011/04/05,  kantena - 2018/01/02 
Notes       : vient de adb/comm/equitrev.i
              rajouter using parametre.pclie.parametrageProlongationExpiration.
------------------------------------------------------------------------*/

procedure savEquitrev:
    /*--------------------------------------------------------------------------
    Purpose : Procedure de sauvegarde du quitt avant révision
    Notes   : vient de adb/comm/equitrev.i
   ---------------------------------------------------------------------------*/
    define input parameter piBail      as int64     no-undo.
    define input parameter piQuittance as integer   no-undo.
    define input parameter pdaRevision       as date      no-undo.
    define input parameter piIndice          as integer   no-undo.
    define input parameter piAnneePeriode    as integer   no-undo.
    define input parameter piNumeroPeriode   as integer   no-undo.
    define input parameter pdeIndice         as decimal   no-undo.
    define input parameter pdeTaux           as decimal   no-undo.

    define variable viNextNumero   as integer no-undo initial 1.
    define buffer equit    for equit.
    define buffer equitrev for equitrev.

    for first equit no-lock
        where equit.noloc = piBail
          and equit.noqtt = piQuittance:
        {&_proparse_ prolint-nowarn(use-index)}
        find last equitrev no-lock
            where equitrev.noloc = piBail
            use-index ix_equitrev01 no-error.    // par equitrev.noloc
        if available equitrev then viNextNumero = equitrev.noord + 1.
        create equitrev.
        buffer-copy equit
            except noloc dtcsy hecsy cdcsy dtmsy hemsy cdmsy to equitrev
            assign
            equitrev.noord     = viNextNumero
            equitrev.noloc     = equit.noloc
            equitrev.daterevis = pdaRevision
            equitrev.cdirv     = piIndice
            equitrev.anper     = piAnneePeriode
            equitrev.noper     = piNumeroPeriode
            equitrev.vlirv     = pdeIndice
            equitrev.txirv     = pdeTaux
            equitrev.dtcsy     = today
            equitrev.hecsy     = time
            equitrev.cdcsy     = mToken:cUser + "@" + program-name(1)
        .
    end.
end procedure.
