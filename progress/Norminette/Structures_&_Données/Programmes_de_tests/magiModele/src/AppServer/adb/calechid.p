/*-----------------------------------------------------------------------------
File        : calechid.p
Purpose     : Création echelle mobile index
Author(s)   : SB - 1999/06/03, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calechid.p
derniere revue: 2018/04/25 - phm: OK

01  19/06/2009  SY    1106/0142: adaptation pour Pré-bail. ATTENTION nouveau param entrée majEchqt.p
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
{adb/include/echlo.i}
define input  parameter pcTypeBail      as character no-undo.
define input  parameter piNumeroBail    as int64     no-undo.
define input  parameter pdeTauxRevision as decimal   no-undo.
define input  parameter pdaFin          as date      no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.

run calechidPrivate.

procedure calechidPrivate private:
    /*------------------------------------------------------------------------------
    Purpose : creation d'une nouvelle echelle mobile avec montants indexés 
    Notes :
    ------------------------------------------------------------------------------*/
    define variable viNumeroCalendrier as integer   no-undo.
    define variable viNumeroPeriode    as integer   no-undo.
    define variable viBoucle           as integer   no-undo.
    define variable vdeDebutTranche    as decimal   no-undo.
    define variable vdeFinTranche      as decimal   no-undo.
    define variable vcCodeRetour       as character no-undo.
    define variable vhProcEchlo        as handle    no-undo.

    define buffer vbttEchlo for ttEchlo.

    empty temp-table ttEchlo.
    run adb/echlo_CRUD.p persistent set vhProcEchlo.
    run getTokenInstance in vhProcEchlo(mToken:JSessionId).
    // recherche du dernier enregistrement de echlo. Derniere periode d'application; dernier no de calcul
    run getDerniereEchenceLoyer in vhProcEchlo(pcTypeBail, piNumeroBail, output viNumeroCalendrier, output viNumeroPeriode).
    run getEchlo in vhProcEchlo(pcTypeBail, piNumeroBail, viNumeroPeriode, ?, viNumeroCalendrier, table ttEchlo by-reference).
    repeat preselect each vbttEchlo where vbttEchlo.CRUD = "R":
        {&_proparse_ prolint-nowarn(noerror)}
        find next vbttEchlo.
        create ttEchlo.
        assign
            ttEchlo.crud  = "C"
            ttEchlo.noper = viNumeroPeriode + 1
            ttEchlo.nocal = 1
            ttEchlo.dtfin = ?
            ttEchlo.idxFx = true
            ttEchlo.idxmg = false
            ttEchlo.idxPl = false
            ttEchlo.idxTc = false
            ttechlo.debtc = 0
            ttechlo.fintc = 0
            ttechlo.prctc = 0
            /* MAJ de la date de fin de période d'application de l'echelle précédente */
            vbttEchlo.dtfin = pdaFin - 1       // Attention, c'est bien vbttEchlo
            vbttEchlo.CRUD  = "U"              // Attention, c'est bien vbttEchlo
            vdeDebutTranche = 0
        .
boucle:
        do viBoucle = 1 to 40:
            if vbttEchlo.fintc[viBoucle] = 0.00 then leave boucle.

            if vbttEchlo.fintc[viBoucle] = 999999999999.00 then do:
                assign
                    ttEchlo.debtc[viBoucle] = vdeDebutTranche
                    ttEchlo.fintc[viBoucle] = vbttEchlo.fintc[viBoucle]
                    ttEchlo.prctc[viBoucle] = vbttEchlo.prctc[viBoucle]
                .
                leave boucle.
            end.
            assign
                vdeFinTranche           = round(vbttEchlo.fintc[viBoucle] + (vbttEchlo.fintc[viBoucle] * pdeTauxRevision) / 100, 2)
                ttEchlo.debtc[viBoucle] = vdeDebutTranche
                ttEchlo.fintc[viBoucle] = vdeFinTranche
                ttEchlo.prctc[viBoucle] = vbttEchlo.prctc[viBoucle]
                vdeDebutTranche         = vdeFinTranche + 0.01
            .
        end.
        assign
            ttEchlo.loyFx = round(vbttEchlo.loyfx + (vbttEchlo.loyfx * pdeTauxRevision) / 100, 2)
            ttEchlo.loymg = round(vbttEchlo.loymg + (vbttEchlo.loymg * pdeTauxRevision) / 100, 2)
            ttEchlo.loyPl = (if vbttEchlo.loypl >= 999999999999.00 then vbttEchlo.loypl else round(vbttEchlo.loypl + (vbttEchlo.loypl * pdeTauxRevision) / 100, 2))
            ttEchlo.prcPl = round((ttEchlo.loyPl / ttEchlo.loymg * 100), 2)
        .
        if ttEchlo.prcPl > 99999.99 then ttEchlo.prcPl = 0.
    end.
    run setEchlo in vhProcEchlo(table ttEchlo by-reference).
    delete object vhProcEchlo no-error.
    /* Lancement du calcul des loyers pour l'echelle mobile */
    run bail/quittancement/majechqt_ext.p(pcTypeBail, piNumeroBail, input-output table ttQtt by-reference, input-output table ttRub by-reference, output vcCodeRetour).
end procedure.
