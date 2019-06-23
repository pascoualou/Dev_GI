/*------------------------------------------------------------------------
File        : majMilliemeImmeuble.i
Purpose     : Include contenant les procédures de mise à jour des millièmes immeuble (lot d'ajustement...)
Author(s)   : SY - 19981119   -   DMI - 20180215
Notes       : issu de adb/comm/pgmajmil.i
------------------------------------------------------------------------*/
procedure majLotAjustement4geranceAlpha private:
   /*------------------------------------------------------------------------------
    Purpose: Procedure de mise à jour du lot d'ajustement pour les clés gérance Alpha
    Notes  : anciennement prcMajMil
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer   no-undo.

    define variable viTotalCle  as integer  no-undo.
    define variable vhProcMilli as handle   no-undo.
    define buffer clemi for clemi.
    define buffer milli for milli.

    run adblib/milli_CRUD.p persistent set vhProcMilli.
    run getTokenInstance in vhProcMilli(mToken:JSessionId).

    empty temp-table ttMilli.
    for each clemi no-lock
        where clemi.noimm = piNumeroImmeuble
         and (clemi.tpcon <> {&TYPECONTRAT-mandat2Gerance} or clemi.nocon = 0)
         and clemi.cdcle  >= "A"
         and clemi.cdeta  <> "S":
        // Calcul du total des lots de l'immeuble
        viTotalCle = 0.
        for each milli no-lock
          where milli.Noimm = piNumeroImmeuble
            and milli.cdcle = clemi.cdcle
            and milli.nolot > 0 :
            viTotalCle = viTotalCle + milli.nbpar.
        end.
        // Mise à jour du lot d'ajustement
        find first milli no-lock
          where milli.Noimm = piNumeroImmeuble
            and milli.cdcle = clemi.cdcle
            and milli.nolot = 0 no-error.
        create ttMilli.
        assign
            ttMilli.noimm       = piNumeroImmeuble
            ttMilli.nolot       = 0
            ttMilli.cdcle       = clemi.cdcle
            ttMilli.nbpar       = clemi.nbtot - viTotalCle
            ttMilli.CRUD        = string(available milli, "U/C")
            ttMilli.rRowid      = rowid(milli) when available milli
            ttMilli.dtTimeStamp = datetime(milli.dtmsy, milli.hemsy) when available milli
        .
    end.
    run setMilli in vhProcMilli(table ttMilli by-reference).
    run destroy in vhProcMilli.
end procedure.
