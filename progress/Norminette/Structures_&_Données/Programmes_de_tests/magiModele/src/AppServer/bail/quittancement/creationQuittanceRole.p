{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/tmprub.i}
{bail/include/equit.i &nomtable=ttqtt}

procedure createQuittanceRole: 
    /*-------------------------------------------------------------------
    Purpose:
    Notes:
  ----------------------------------------------------------------------*/
    define input  parameter pcTypeRole   as character no-undo.
    define input  parameter piNumeroRole as integer   no-undo.
    define output parameter pcCodeRetour as character no-undo initial "00".

    define variable viNumeroLocataire        as integer no-undo.
    define variable viNumeroMandat           as integer no-undo.
    define variable viNumeroInterneQuittance as integer no-undo.
    define variable viCompteurRubrique       as integer no-undo.

    define buffer pquit for pquit.

    assign 
        viNumeroLocataire = piNumeroRole
        viNumeroMandat    = integer(truncate(viNumeroLocataire / 100000, 0))
    .

    /* Suppression des quit. du locataire dans pquit */
    for each pquit exclusive-lock
       where pquit.noLoc = viNumeroLocataire:
        delete pquit no-error.
    end.

    /* Recherche du prochain nø interne de pquit */
    for last pquit no-lock:
        assign viNumeroInterneQuittance = pquit.NoInt.
    end.
CRpquit:
    do transaction:
        /* Parcours des quit. du locataire dans TmQtt */
        for each ttQtt 
            where ttQtt.NoLoc = viNumeroLocataire:
            create pquit no-error.
            if error-status:error then do:
                assign pcCodeRetour = "01".
                undo CRpquit, leave CRpquit.
            end.
            assign
                viNumeroInterneQuittance = viNumeroInterneQuittance + 1
                pquit.NoInt = viNumeroInterneQuittance
                NO-ERROR
            .
            if error-status:error then do:
                assign pcCodeRetour = "01".
                delete pquit no-error.
                undo CRpquit,leave CRpquit.
            end.
            assign
                pquit.NoLoc = viNumeroLocataire
                pquit.NoQtt = ttQtt.NoQtt
                pquit.MsQtt = ttQtt.MsQtt
                pquit.MsQui = ttQtt.MsQui
                pquit.DtDeb = ttQtt.DtDeb
                pquit.DtFin = ttQtt.DtFin
                pquit.DtDpr = ttQtt.DtDpr
                pquit.DtFpr = ttQtt.DtFpr
                pquit.PdQtt = ttQtt.PdQtt
                pquit.NtBai = ttQtt.NtBai
                pquit.DuBai = ttQtt.DuBai
                pquit.UtDur = ttQtt.UtDur
                pquit.DtEff = ttQtt.DtEff
                pquit.TpIdc = ttQtt.TpIdc
                pquit.PdIdc = ttQtt.PdIdc
                pquit.NoIdc = ttQtt.NoIdc
                pquit.DtRev = ttQtt.DtRev
                pquit.DtPrv = ttQtt.DtPrv
                pquit.MdReg = ttQtt.MdReg
                pquit.CdTer = ttQtt.CdTer
                pquit.DtEnt = ttQtt.DtEnt
                pquit.DtSor = ttQtt.DtSor
                pquit.NoImm = ttQtt.NoImm
                pquit.NbRub = ttQtt.NbRub
                pquit.CdQuo = ttQtt.CdQuo
                pquit.NbNum = ttQtt.NbNum
                pquit.NbDen = ttQtt.NbDen
                pquit.CdDep = ttQtt.CdDep
                pquit.CdSol = ttQtt.CdSol
                pquit.CdRev = ttQtt.CdRev
                pquit.CdPrv = ttQtt.CdPrv
                pquit.CdPrs = ttQtt.CdPrs
                pquit.NbEdt = ttQtt.NbEdt
                pquit.CdCor = "00001"   /* texte sur Avis d'échéance */
                pquit.FgTrf = false /* quittance non transférée */
                pquit.nomdt = viNumeroMandat
                pquit.dtcsy = today
                pquit.hecsy = time
                pquit.cdcsy = mtoken:cUser
            no-error.
            if error-status:error then do:
                assign pcCodeRetour = "01".
                undo CRpquit,leave CRpquit.
            end.
            assign
                pquit.MtQtt        = ttQtt.MtQtt
                pquit.MtQtt-dev    = ttQtt.MtQtt
                viCompteurRubrique = 0 
            no-error.
            /* Parcours des quittances de ttRub */
            for each ttRub  
               where ttRub.NoLoc = ttQtt.NoLoc
                 and ttRub.NoQtt = ttQtt.NoQtt:
                assign
                    viCompteurRubrique = viCompteurRubrique + 1
                    pquit.TbFam[viCompteurRubrique] = ttRub.CdFam
                    pquit.TbSfa[viCompteurRubrique] = ttRub.CdSfa
                    pquit.TbRub[viCompteurRubrique] = ttRub.NoRub
                    pquit.TbLib[viCompteurRubrique] = ttRub.NoLib
                    pquit.TbGen[viCompteurRubrique] = ttRub.CdGen
                    pquit.TbSig[viCompteurRubrique] = ttRub.CdSig
                    pquit.TbDet[viCompteurRubrique] = ttRub.CdDet
                    pquit.TbQte[viCompteurRubrique] = ttRub.VlQte
                    pquit.TbPro[viCompteurRubrique] = ttRub.CdPro
                    pquit.TbNum[viCompteurRubrique] = ttRub.VlNum
                    pquit.TbDen[viCompteurRubrique] = ttRub.VlDen
                    pquit.TbDt1[viCompteurRubrique] = ttRub.DtDap
                    pquit.TbDt2[viCompteurRubrique] = ttRub.DtFap
                    pquit.TbFil[viCompteurRubrique] = ttRub.ChFil
                no-error.
                if error-status:error then do:
                    assign pcCodeRetour = "01".
                    undo CRpquit,leave CRpquit.
                end.
                assign
                    pquit.TbPun[viCompteurRubrique]     = ttRub.VlPun
                    pquit.TbTot[viCompteurRubrique]     = ttRub.MtTot
                    pquit.TbMtq[viCompteurRubrique]     = ttRub.VlMtq
                    pquit.TbPun-dev[viCompteurRubrique] = ttRub.VlPun 
                    pquit.TbTot-dev[viCompteurRubrique] = ttRub.MtTot
                    pquit.TbMtq-dev[viCompteurRubrique] = ttRub.VlMtq
                .
            end. /* Parcours de ttRub */
        end. /* Parcours des quittances du locataire */
    end. /* Transaction */
end procedure.
