/*-----------------------------------------------------------------------------
File        : calechid.p
Purpose     : Cr�ation echelle mobile index
Author(s)   : SB - 1999/06/03, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calechid.p
derniere revue: 2018/08/13 - phm: OK

01  19/06/2009  SY    1106/0142: adaptation pour Pr�-bail. ATTENTION nouveau param entr�e majEchqt.p
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}  // Doit �tre positionn�e juste apr�s using
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{crud/include/echlo.i}

{outils/include/lancementProgramme.i}        // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghProc                as handle    no-undo.
define variable gcTypeBail            as character no-undo.
define variable giNumeroBail          as int64     no-undo.
define variable gdTauxRevision        as decimal   no-undo.
define variable gdaFin                as date      no-undo.

procedure lancementCalechid:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input  parameter gcTypeBail     as character no-undo.
    define input  parameter giNumeroBail   as int64     no-undo.
    define input  parameter gdTauxRevision as decimal   no-undo.
    define input  parameter gdaFin         as date      no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign   
        gcTypeBail     = gcTypeBail
        giNumeroBail   = giNumeroBail
        gdTauxRevision = gdTauxRevision
        gdaFin         = gdaFin
        goCollectionHandlePgm = new collection()   
    .        

message "lancementCalechid " gcTypeBail "/" giNumeroBail "/" gdTauxRevision "/" gdaFin.

    run calechidPrivate.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure calechidPrivate private:
    /*------------------------------------------------------------------------------
    Purpose : creation d'une nouvelle echelle mobile avec montants index�s 
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
    vhProcEchlo = lancementPgm("crud/echlo_CRUD.p", goCollectionHandlePgm).
    // recherche du dernier enregistrement de echlo. Derniere periode d'application; dernier no de calcul
    run getDerniereEcheanceLoyer in vhProcEchlo(gcTypeBail, giNumeroBail, output viNumeroCalendrier, output viNumeroPeriode).
    run getEchlo in vhProcEchlo(gcTypeBail, giNumeroBail, viNumeroPeriode, ?, viNumeroCalendrier, table ttEchlo by-reference).
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
            /* MAJ de la date de fin de p�riode d'application de l'echelle pr�c�dente */
            vbttEchlo.dtfin = gdaFin - 1       // Attention, c'est bien vbttEchlo
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
                vdeFinTranche           = round(vbttEchlo.fintc[viBoucle] + (vbttEchlo.fintc[viBoucle] * gdTauxRevision) / 100, 2)
                ttEchlo.debtc[viBoucle] = vdeDebutTranche
                ttEchlo.fintc[viBoucle] = vdeFinTranche
                ttEchlo.prctc[viBoucle] = vbttEchlo.prctc[viBoucle]
                vdeDebutTranche         = vdeFinTranche + 0.01
            .
        end.
        assign
            ttEchlo.loyFx = round(vbttEchlo.loyfx + (vbttEchlo.loyfx * gdTauxRevision) / 100, 2)
            ttEchlo.loymg = round(vbttEchlo.loymg + (vbttEchlo.loymg * gdTauxRevision) / 100, 2)
            ttEchlo.loyPl = (if vbttEchlo.loypl >= 999999999999.00 then vbttEchlo.loypl else round(vbttEchlo.loypl + (vbttEchlo.loypl * gdTauxRevision) / 100, 2))
            ttEchlo.prcPl = round((ttEchlo.loyPl / ttEchlo.loymg * 100), 2)
        .
        if ttEchlo.prcPl > 99999.99 then ttEchlo.prcPl = 0.
    end.
    run setEchlo in vhProcEchlo(table ttEchlo by-reference).
    delete object vhProcEchlo no-error.
    /* Lancement du calcul des loyers pour l'echelle mobile */
    ghProc = lancementPgm("bail/quittancement/majechqt.p", goCollectionHandlePgm).
    run lancementMajechqt in ghProc(gcTypeBail, giNumeroBail, input-output table ttQtt by-reference, input-output table ttRub by-reference).

end procedure.
