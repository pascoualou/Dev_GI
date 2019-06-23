/*------------------------------------------------------------------------
File        : supodtx.p
Purpose     : Retirage cloture dossier Annulation OD solde CHB
Author(s)   : RF - 21/07/08  :  gga - 2017/04/07
Notes       : reprise du pgm cadb\src\gestion\supodtx.p

01 | 04/09/2009 |  JR  | 0909/0004
02 | 25/01/2010 |  JR  | Modification suppiece.i
03 | 15/04/2010 |  JR  | Modif de TbTmpDos.i
04 | 06/05/2011 |  PL  | 0411/0155 : pb raz tmp-cron
05 | 02/12/2015 |  NP  | 1215/0002 modif suppiece.i
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

&SCOPED-DEFINE NomProg odreltx.p
/*gga pas de reprise, include vide
{gene/faletaut.def}  gga*/

/** Procédure Sup_Comptabilisation **/
{compta/include/suppiece.i}

procedure supodtxAnnulOd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par dossierTravaux.p
    ------------------------------------------------------------------------------*/
    define input parameter  poCollection as collection no-undo.
    define output parameter piNumErr     as integer no-undo.

    define variable viTmpPieceInt    as integer   no-undo.
    define variable viTmpPieceCompta as integer   no-undo.
    define variable viNumeroMandat   as integer   no-undo.
    define variable vcRefIn          as character no-undo.
    define variable vdaDatCompta     as date      no-undo.
    define variable vhProc           as handle    no-undo.

    define buffer cecrlnana   for cecrlnana.
    define buffer vbCecrlnana for cecrlnana.
    define buffer cecrln      for cecrln.
    define buffer vbCecrln    for cecrln.
    define buffer cecrsai     for cecrsai.
    define buffer vbCecrsai   for cecrsai.
    define buffer cnumpiec    for cnumpiec.
    define buffer isoc        for isoc.
    define buffer iprd        for iprd.
    define buffer ijou        for ijou.
    define buffer ietab       for ietab.
    define buffer idev        for idev.
    define buffer agest       for agest.

    assign
        viNumeroMandat = poCollection:getInteger("iNumeroMandat")
        vcRefIn        = poCollection:getCharacter("trdos-lbdiv2")
    .

message "gga debut supodtx  " viNumeroMandat "//" vcRefIn "//"  mtoken:cRefPrincipale .

    find first isoc no-lock
        where isoc.soc-cd = integer(mtoken:cRefPrincipale) no-error.
    if not available isoc then do:
        piNumErr = 3. /* société compta absente */
        return.
    end.
    find first ietab no-lock
        where ietab.soc-cd = isoc.soc-cd
          and ietab.profil-cd = 10 no-error.
    if not available ietab then do:
        piNumErr = 6. /* Mandat 8500 inexistant */
        return.
    end.
    find first idev no-lock
        where idev.soc-cd = isoc.soc-cd
          and idev.dev-cd = ietab.dev-cd no-error.
    if not available idev then do:
        piNumErr = 9. /* Devise Cabinet inexistante */
        return.
    end.
    find first ietab no-lock
        where ietab.soc-cd = isoc.soc-cd
          and ietab.etab-cd = viNumeroMandat no-error.
    if not available ietab then do:
        piNumErr = 4. /* Mandat absent */
        return.
    end.
    find first idev no-lock
        where idev.soc-cd = isoc.soc-cd
          and idev.dev-cd = ietab.dev-cd no-error.
    if not available idev then do:
        piNumErr = 10. /* Devise Mandat inexistante */
        return.
    end.
    find first agest no-lock
        where agest.soc-cd   = ietab.soc-cd
          and agest.gest-cle = ietab.gest-cle no-error.
    if not available agest then do:
        piNumErr = 5. /* Gestionnaire Absent */
        return.
    end.
    /* 1 - Recherche de l'ODT de solde */
    {&_proparse_ prolint-nowarn(nowait)}
    find first cecrsai exclusive-lock
        where cecrsai.soc-cd       = integer(entry(1, vcRefIn, "|"))
          and cecrsai.etab-cd      = integer(entry(2, vcRefIn, "|"))
          and cecrsai.jou-cd       =         entry(3, vcRefIn, "|")
          and cecrsai.prd-cd       = integer(entry(4, vcRefIn, "|"))
          and cecrsai.prd-num      = integer(entry(5, vcRefIn, "|"))
          and cecrsai.piece-compta = integer(entry(6, vcRefIn, "|")) no-error.
    if not available cecrsai then return.

message "gga supodtx apres lecture cecrsai".
    if cecrsai.dacompta  >= agest.dadeb and cecrsai.dacompta <= agest.dafin
    then do:
        /** Suppression de la piece, elle fait partie du gestionnaire **/
        run compta/souspgm/cptmvtu.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run cptmvtuUndoMvtCpt in vhProc (rowid(cecrsai)).
        run destroy in vhProc.

        for each cecrln exclusive-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int:
            /** ANALYTIQUE **/
            for each cecrlnana exclusive-lock
                where cecrlnana.soc-cd    = cecrln.soc-cd
                  and cecrlnana.etab-cd   = cecrln.etab-cd
                  and cecrlnana.jou-cd    = cecrln.jou-cd
                  and cecrlnana.prd-cd    = cecrln.prd-cd
                  and cecrlnana.prd-num   = cecrln.prd-num
                  and cecrlnana.piece-int = cecrln.piece-int
                  and cecrlnana.lig       = cecrln.lig:
                if cecrlnana.regrp > ""
                then for each vbCecrlnana exclusive-lock
                    where vbCecrlnana.soc-cd  = cecrlnana.soc-cd
                      and vbCecrlnana.etab-cd = cecrlnana.etab-cd
                      and vbCecrlnana.regrp   = cecrlnana.regrp:
                    vbCecrlnana.regrp = "".
                end.
                delete cecrlnana.
            end.
            /** LETTRAGE **/
            if cecrln.lettre > ""
            then for each vbCecrln exclusive-lock
                where vbCecrln.soc-cd     = cecrln.soc-cd
                  and vbCecrln.etab-cd    = cecrln.etab-cd
                  and vbCecrln.sscoll-cle = cecrln.sscoll-cle
                  and vbCecrln.cpt-cd     = cecrln.cpt-cd
                  and vbCecrln.dacompta   >= (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1)
                  and vbCecrln.lettre     = cecrln.lettre:
                assign
                    vbCecrln.lettre     = ""
                    vbCecrln.flag-let   = false
                    vbCecrln.dalettrage = ?
                .
            end.
            if not can-find(first tmp-cpt
                where tmp-cpt.cpt-cd     = cecrln.cpt-cd
           	      and tmp-cpt.sscoll-cle = cecrln.sscoll-cle)
            then do:
                create tmp-cpt.
                assign
                    tmp-cpt.sscoll-cle = cecrln.sscoll-cle
                    tmp-cpt.coll-cle   = cecrln.coll-cle
                    tmp-cpt.cpt-cd     = cecrln.cpt-cd
                    tmp-cpt.etab-cd    = cecrln.etab-cd
                .
            end.
            delete cecrln.
        end.
        run effaparm (rowid(cecrsai), cecrsai.soc-cd).
        assign
            cecrsai.lib   = substitute("SUPPRESSION LE &1 &2 RETIRAGE CLOTURE DOSSIER", string(today,"99/99/9999"), string(time, "HH:MM:SS"))
            cecrsai.mtdev = 0
        .
    end.
    else do:
        if agest.dafin < today
        then vdaDatCompta = agest.dafin.
        else if agest.dadeb > today
        then vdaDatCompta = agest.dadeb.
        else vdaDatCompta = today.
        /** 0909/0004 **/
        find first ijou no-lock
            where ijou.soc-cd  = cecrsai.soc-cd
              and ijou.etab-cd = cecrsai.etab-cd
              and ijou.jou-cd  = cecrsai.jou-cd no-error.
        find first iprd no-lock
            where iprd.soc-cd   = isoc.soc-cd
              and iprd.etab-cd  = ietab.etab-cd
              and iprd.dadebprd <= vdaDatCompta
              and iprd.dafinprd >= vdaDatCompta no-error.
        /****************************************
         AFFECTATION piece-int et piece-compta
        ****************************************/
        {&_proparse_ prolint-nowarn(nowait)}
        find first cnumpiec exclusive-lock
            where cnumpiec.soc-cd  = isoc.soc-cd
              and cnumpiec.etab-cd = ietab.etab-cd
              and cnumpiec.jou-cd  = cecrsai.jou-cd
              and cnumpiec.prd-cd  = iprd.prd-cd
              and cnumpiec.prd-num = iprd.prd-num no-error.
        if available cnumpiec
        then assign
            viTmpPieceInt         = cnumpiec.piece-int + 1
            cnumpiec.piece-int    = viTmpPieceInt
            cnumpiec.piece-compta = cnumpiec.piece-compta + 1
            viTmpPieceCompta      = cnumpiec.piece-compta
        .
        else do:
            create cnumpiec.
            assign
                cnumpiec.soc-cd       = isoc.soc-cd
                cnumpiec.etab-cd      = ietab.etab-cd
                cnumpiec.jou-cd       = cecrsai.jou-cd
                cnumpiec.prd-cd       = iprd.prd-cd
                cnumpiec.prd-num      = iprd.prd-num
                cnumpiec.piece-compta = inumpiecNumerotationPiece(ijou.fpiece, vdaDatCompta) + 1
                cnumpiec.piece-int    = 1
                viTmpPieceInt         = 1
                viTmpPieceCompta      = cnumpiec.piece-compta
            .
        end.
        create vbCecrsai.
        buffer-copy cecrsai to vbCecrsai
            assign
                vbCecrsai.usrid        = "supdodtx.p"
                vbCecrsai.prd-cd       = iprd.prd-cd
                vbCecrsai.prd-num      = iprd.prd-num
                vbCecrsai.dadoss       = ?
                vbCecrsai.dacompta     = vdaDatCompta
                vbCecrsai.piece-int    = viTmpPieceInt
                vbCecrsai.piece-compta = viTmpPieceCompta
        .
        for each cecrln exclusive-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int:
            create vbCecrln.
            buffer-copy cecrln to vbCecrln
                assign
                    vbCecrln.piece-int      = vbCecrsai.piece-int
                    vbCecrln.sens           = not cecrln.sens
                    vbCecrln.prd-cd         = vbCecrsai.prd-cd
                 	vbCecrln.prd-num        = vbCecrsai.prd-num
                 	vbCecrln.dacompta       = vbCecrsai.dacompta
                	vbCecrln.mandat-prd-cd  = vbCecrsai.prd-cd
                	vbCecrln.mandat-prd-num = vbCecrsai.prd-num
                 	vbCecrln.lib-ecr[1]     = "SUP " + vbCecrln.lib-ecr [1]
                	vbCecrln.lib            = "SUP " + vbCecrln.lib
                	vbCecrln.lettre         = ""
                 	vbCecrln.dalettrage     = ?
                	vbCecrln.flag-let       = false
            .
            find first tmp-cpt
                where tmp-cpt.cpt-cd     = vbCecrln.cpt-cd
         	      and tmp-cpt.sscoll-cle = vbCecrln.sscoll-cle no-error.
            if not available tmp-cpt
            then do:
                create tmp-cpt.
                assign
                    tmp-cpt.sscoll-cle = vbCecrln.sscoll-cle
                    tmp-cpt.coll-cle   = vbCecrln.coll-cle
                    tmp-cpt.cpt-cd     = vbCecrln.cpt-cd
                    tmp-cpt.etab-cd    = vbCecrln.etab-cd
                .
            end.
        end.
        cecrsai.lib = substitute("SUPPRESSION LE &1 &2 RETIRAGE CLOTURE", string(today, "99/99/9999"), string(time, "HH:MM:SS")).
        {&_proparse_ prolint-nowarn(nowait)}
        find first cecrsai where rowid(cecrsai) = rowid(vbCecrsai) exclusive-lock no-error.
        cecrsai.situ = true.
        run compta/souspgm/cptmvt.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run cptmvtMajMvtCpt in vhProc (rowid(cecrsai)).
        run destroy in vhProc.
        run effaparm (rowid(cecrsai), cecrsai.soc-cd).
    end.

message "supodtx avant appel lettrage ".
    run lettrage (isoc.soc-cd, ietab.etab-cd, if ietab.exercice then ietab.dadebex2 else ietab.dadebex1, agest.dafin).

end procedure.
