/*------------------------------------------------------------------------
File        : tacheBaux.p
Purpose     : tache baux (donne juste la liste des baux)
Author(s)   : GGA - 2017/08/03
Notes       : a partir de adb/tach/SylMtCtt.p adb/lib/formctr6.p adb/comm/dtfapmax.i
------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/codeperiode.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheBaux.i}

procedure getListeBaux:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define input parameter pcTypeContratLie as character no-undo.
    define output parameter table for ttTacheBaux.

    define variable vdaSorLoc as date      no-undo.
    define variable vdaFinUse as date      no-undo.
    define variable vhProc    as handle    no-undo.
    define variable vcCodDur  as character no-undo.
    define variable viMoiDur  as integer   no-undo.

    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.
    define buffer tache for tache.
    define buffer unite for unite.
    define buffer cpuni for cpuni.

    empty temp-table ttTacheBaux.
    run tache/outilsTache.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    for each ctctt no-lock
        where ctctt.tpct1 = pcTypeMandat
          and ctctt.noct1 = piNumeroMandat
          and ctctt.tpct2 = pcTypeContratLie
      , first ctrat no-lock
        where ctrat.tpcon = ctctt.tpct2
          and ctrat.nocon = ctctt.noct2
          and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}:      /* Ajout Sy le 15/02/2007 : filtrer bail spécial vacant */
          
        create ttTacheBaux.
        assign
            ttTacheBaux.cTypeContrat          = ctctt.tpct1
            ttTacheBaux.iNumeroContrat        = ctctt.noct1
            ttTacheBaux.cTypeTache            = {&TYPETACHE-baux}
            ttTacheBaux.cCodeLocataire        = substring(string(ctrat.norol, "9999999999"), 6)
            ttTacheBaux.cNomLocataire         = ctrat.lnom2
            ttTacheBaux.cCodeNatureContrat    = ctrat.ntcon
            ttTacheBaux.cLibelleNatureContrat = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            ttTacheBaux.lTaciteReconduction   = (ctrat.tpren = "00001")
            /* Modif SY le 05/03/2013 : critères détection fin de bail complets */
            vdaFinUse                         = ctrat.dtree
            vdaSorLoc                         = ?
        .
        for first unite no-lock
            where unite.nomdt = piNumeroMandat
              and unite.noact = 0
              and unite.noapp = integer(truncate(ctrat.nocon modulo 100000 / 100, 0))    // integer(substring(string(ctrat.nocon, "9999999999"),6,3))
          , first cpuni no-lock
            where cpuni.nomdt = unite.nomdt
              and cpuni.noapp = unite.noapp
              and cpuni.nocmp = unite.nocmp:
            ttTacheBaux.iNumeroLotPrinc = cpuni.nolot.
        end.
        for last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-quittancement}:
            vdaSorLoc = tache.dtfin.
        end.
        /*--> Date de fin du bail */
        run dtFapMax in vhproc(ctrat.tpren = "00001", ctrat.dtfin, vdaSorLoc, ctrat.dtree, output vdaFinUse).
        ttTacheBaux.lResilie = (vdaFinUse < today).
        /* recherche date debut, fin, annulation, resiliation, sortie */
        if ctrat.dtdeb <> ? then ttTacheBaux.daDebut = ctrat.dtdeb.
        if ctrat.dtree = ? and vdaSorLoc = ? then do:
            if ctrat.dtree = ? then do:
                if ctrat.dtfin <> ? then do:
                    ttTacheBaux.dafin = ctrat.dtfin.
                    for last tache no-lock
                        where tache.tpcon = ctrat.tpcon
                          and tache.nocon = ctrat.nocon
                          and tache.tptac = {&TYPETACHE-renouvellement}
                          and lookup(tache.tpfin, "10,20,30,40") > 0:
                        ttTacheBaux.dafin = tache.dtfin.
                    end.
                end.
                else do:
                    vcCodDur = if ctrat.cddur > "" then ctrat.cddur else {&PERIODICITEBAIL-annuel}.
                    case vcCodDur:
                        when {&PERIODICITEBAIL-annuel}  then viMoiDur = ctrat.nbdur * 12.  //an
                        when {&PERIODICITEBAIL-mensuel} then viMoiDur = ctrat.nbdur.       //mois
                        otherwise viMoiDur = ctrat.nbdur * 12.          //inconnu, on le Force à 'An'.
                    end case.
                    ttTacheBaux.dafin = add-interval(ctrat.dtdeb, viMoiDur, "month").
                end.
            end.
            else ttTacheBaux.dafin = ctrat.dtree.
        end.
        else if ctrat.dtree <> ?
            then if ctrat.fgannul
                then ttTacheBaux.daAnnul = ctrat.dtree.
                else ttTacheBaux.daResil = ctrat.dtree.
            else if vdaSorLoc <> ?
                then ttTacheBaux.daSortie = vdaSorLoc.
    end.
    run destroy in vhproc.

end procedure.
