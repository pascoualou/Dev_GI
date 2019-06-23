/*------------------------------------------------------------------------
File        : garlofl.i
Purpose     :
Author(s)   : kantena - 2018/01/02
Notes       : vient de adb/comm/garlofl.i
------------------------------------------------------------------------*/
function montantAnnuelLoyer returns decimal private(piBail as int64):
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui calcul le montant annuel (indexé) garanti pour un F.L.
    Notes   : vient de {garlofl.i} procedure calMtAnnGar
    ---------------------------------------------------------------------------*/
    define variable vdeMontantAnnuelLoyer as decimal  no-undo.
    define variable viNumeroMandat        as integer  no-undo.
    define variable viNumeroAppartement   as integer  no-undo.
    define buffer tache for tache.
    define buffer intnt for intnt.
    define buffer local for local.
    define buffer unite for unite.
    define buffer cpuni for cpuni.

    assign
        viNumeroMandat      = truncate(piBail / 100000, 0)               // INT( substring( string(piBail, "9999999999"), 1 , 5))
        viNumeroAppartement = truncate((piBail modulo 100000) / 100, 0)  //  INT( substring( string(piBail, "9999999999"), 6 , 3))
    .
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = viNumeroMandat
          and tache.tptac = {&TYPETACHE-garantieLoyerFL}
      , first intnt no-lock
        where intnt.tpcon = tache.tpcon
          and intnt.nocon = tache.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first local no-lock
        where local.noimm = intnt.noidt
          and local.nolot = integer(tache.notac)
      , each unite no-lock
        where unite.nomdt = viNumeroMandat
          and unite.noapp = viNumeroAppartement
          and unite.noact = 0
      , first cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.nolot = local.nolot:
        vdeMontantAnnuelLoyer = vdeMontantAnnuelLoyer + tache.mtreg.
    end.
    return vdeMontantAnnuelLoyer.
end function.
