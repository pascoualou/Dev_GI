/*------------------------------------------------------------------------
File        : tantieme.p
Purpose     :
Author(s)   : kantena - 2017/06/01
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/tantieme.i}

procedure getCleImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttCleTantieme.
    define output parameter table for ttTantieme.

    define buffer clemi for clemi.

    empty temp-table ttCleTantieme.
    empty temp-table ttTantieme.
    for each clemi no-lock
        where clemi.noimm = piNumeroImmeuble
          and (clemi.tpcon <> {&TYPECONTRAT-mandat2gerance} or clemi.nocon = 0) 
          and clemi.cdeta <> "S":
        create ttCleTantieme.
        assign
            ttCleTantieme.iNumeroImmeuble = piNumeroImmeuble
            ttCleTantieme.cCodeCle        = string(clemi.cdcle)
            ttCleTantieme.cCodeBatiment   = clemi.cdbat
            ttCleTantieme.cLibelleCLe     = clemi.lbcle
            ttCleTantieme.iNombreTantieme = clemi.nbtot
            ttCleTantieme.CRUD            = 'R'
            ttCleTantieme.dtTimestamp     = datetime(clemi.dtmsy, clemi.hemsy)
            ttCleTantieme.rRowid          = rowid(clemi)
        .
        run getTantiemeImmeuble(piNumeroImmeuble, ttCleTantieme.cCodeCle).
    end.
end procedure.

procedure getTantiemeLot:
/*------------------------------------------------------------------------------
Purpose:
Notes: service utilisé par beLot.cls
------------------------------------------------------------------------------*/
    define input parameter piNumeroBien as int64 no-undo.
    define output parameter table for ttTantiemeLot.

    define variable viNumeroMandatSyndic as integer no-undo.
    define buffer local   for local.
    define buffer ctrat   for ctrat.
    define buffer intnt   for intnt.
    define buffer milli   for milli.
    define buffer clemi   for clemi.

    find first local no-lock where local.noloc = piNumeroBien no-error.
    if not available local then return.

    // Rechercher si immeuble de copro
boucle:
    for each intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = local.noimm
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and ctrat.Dtree = ?:
        viNumeroMandatSyndic = intnt.nocon.
        leave boucle.
    end.

    for each milli no-lock
        where milli.noimm = local.noimm
          and milli.nolot = local.nolot:
        for each clemi no-lock
           where clemi.noimm = local.noimm
             and clemi.cdcle = milli.cdcle
             and clemi.cdeta <> "S":
            create ttTantiemeLot.
            assign
                ttTantiemeLot.iNumeroBien     = local.noloc
                ttTantiemeLot.iOrdre          = 0
                ttTantiemeLot.iNumeroMandat   = viNumeroMandatSyndic
                ttTantiemeLot.cCodeCle        = string(clemi.cdcle)
                ttTantiemeLot.iNombreTantieme = milli.nbpar
                ttTantiemeLot.dTotalImmeuble  = clemi.nbtot
                ttTantiemeLot.cLibelleCle     = trim(clemi.lbcle)
                ttTantiemeLot.CRUD            = "R"
                ttTantiemeLot.dtTimestamp     = datetime(local.dtmsy, local.hemsy)
                ttTantiemeLot.rRowid          = rowid(local)
            .
        end.
        /* clés de gérance */
        if milli.cdcle < "A"
        then for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.noidt = local.noloc
              and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.dtree = ?
          , each clemi no-lock
            where clemi.tpcon = ctrat.tpcon
              and clemi.nocon = ctrat.nocon
              and clemi.cdcle = milli.cdcle:
            create ttTantiemeLot.
            assign
                ttTantiemeLot.iNumeroBien     = local.noloc
                ttTantiemeLot.iOrdre          = 1
                ttTantiemeLot.iNumeroMandat   = ctrat.nocon
                ttTantiemeLot.cCodeCle        = string(clemi.cdcle)
                ttTantiemeLot.iNombreTantieme = milli.nbpar
                ttTantiemeLot.dTotalMandat    = clemi.nbtot
                ttTantiemeLot.cLibelleCle     = trim(clemi.lbcle)
                ttTantiemeLot.CRUD            = "R"
                ttTantiemeLot.dtTimestamp     = datetime(local.dtmsy, local.hemsy)
                ttTantiemeLot.rRowid          = rowid(local)
            .
        end.
    end.

end procedure.

procedure getTantiemeImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer   no-undo.
    define input parameter pcLibelleCle     as character no-undo.

    define buffer milli for milli.
    define buffer local for local.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    for each milli no-lock
        where milli.noimm = piNumeroImmeuble
          and milli.cdcle = pcLibelleCle
      , first local no-lock
        where local.noimm = piNumeroImmeuble
          and local.nolot = milli.nolot
      , first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-acte2propriete}
          and intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.noidt = local.noloc
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        create ttTantieme.
        assign
            ttTantieme.iNUmeroImmeuble = piNumeroImmeuble
            ttTantieme.cCodeCle        = pcLibelleCle
            ttTantieme.iNumeroLot      = milli.nolot
            ttTantieme.cCodeBatiment   = milli.cdbat
            ttTantieme.cProprietaire   = ctrat.lbnom
            ttTantieme.iNombreTantieme = milli.nbpar
            ttTantieme.CRUD            = 'R'
            ttTantieme.dtTimestamp     = datetime(milli.dtmsy, milli.hemsy)
            ttTantieme.rRowid          = rowid(milli)
        .
        // TODO Ajouter mandat
    end.
end procedure.
