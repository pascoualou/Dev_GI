/*------------------------------------------------------------------------
File        : ctrltrav.p
Purpose     : Controles pour cloture travaux
Author(s)   : PL - 2008/05/13;  gga  -  2017/04/07
Notes       : reprise du pgm trans\src\gene\ctrltrav.p

01 | 03/06/2008 | SY   | Fichier suivi apipcx.lg déplacé dans disque/gi/trans/tmp
02 | 07/04/2009 | JR   | 0309/0299 modification de l'appel de apatcx.p
03 | 04/09/2009 | JR   | 0909/0004
04 | 07/10/2010 | JR   | 1010/0045, Modification du calcul du montant du tirage de cloture lors d'un retirage
05 | 20/02/2013 | SY   | 0911/0112 table tempo en include tbTmpSld.i et ttTmpErr.i
06 |  05/10/15  | cartu| migration
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/error.i}
{compta/include/tbtmpsld.i}
{travaux/include/editionAno.i}
{application/include/glbsepar.i}

message "gga debut ctrltrav.p".

procedure controleTrav:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par dossierTravaux.p
    ------------------------------------------------------------------------------*/
    define input        parameter poCollection as collection no-undo.
    define input-output parameter table for ttTmpSld.
    define input        parameter table for ttError.
    define output       parameter table for ttTmpErr.
    define output       parameter plRetour as logical no-undo.

    define variable viNumeroMandat   as integer   no-undo.
    define variable viDossierTravaux as integer   no-undo.
    define variable vdMontantCphb    as decimal   no-undo.
    define variable vdMontantSolde67 as decimal   no-undo.
    define variable vdMontantOut     as decimal   no-undo.
    define variable vdMontantAppel   as decimal   no-undo.
    define variable vdMontantDepense as decimal   no-undo.
    define variable vcFichier        as character no-undo.
    define variable vlRetour         as logical   no-undo.
    define variable vcTrfRpRunTmp    as character no-undo.
    define variable vhProc           as handle    no-undo.

    define buffer ietab   for ietab.
    define buffer cecrln  for cecrln.
    define buffer ijou    for ijou.
    define buffer cecrsai for cecrsai.

    assign
        viNumeroMandat   = poCollection:getInteger("iNumeroMandat")
        viDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        vcTrfRpRunTmp    = session:temp-directory + "adb~\tmp~\"
        vcFichier        = vcTrfRpRunTmp + "apipcx.lg"
    .

message "gga ctrltrav.p 01 " viNumeroMandat "//" viDossierTravaux "//".

    poCollection:set('lTest', true) no-error.
    poCollection:set('cFichier', vcFichier) no-error.
    run compta/souspgm/apipcx.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run apipcxPrepaControle in vhProc(poCollection,
                                      input-output table ttTmpSld by-reference,
                                      output vlRetour, output vdMontantOut).
    run destroy in vhProc.

message "gga ctrltrav.p apres appel apipcx.p : " vdMontantOut "//" vlRetour.

    if vlRetour = no then return.

    assign
        vdMontantCphb    = vdMontantCphb + vdMontantOut
        vdMontantDepense = - vdMontantOut
    .
    run compta/souspgm/apatcx.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run apatcxTrtApat in vhProc (poCollection,
                       input-output table ttTmpSld by-reference,
                       table ttError by-reference,
                       output vdMontantOut,
                       output vlRetour,
                       output table ttTmpErr by-reference).
    run destroy in vhProc.

message "gga ctrltrav.p apres appel apatcx.p : " vdMontantOut "//" vlRetour  .

    if vlRetour = no then do:
        vcFichier = vcTrfRpRunTmp + "apipcx_err.lg".
        output to value(vcFichier).
        for each ttTmpErr
            by ttTmpErr.noerr
            by ttTmpErr.nomdt
            by ttTmpErr.nodos
            by ttTmpErr.noapp:
            case ttTmpErr.noerr:
                when 1 or when 3 then put unformatted
                        skip " "
                        skip ttTmpErr.lberr[1]
                        skip ttTmpErr.lberr[2]
                        skip ttTmpErr.lberr[3]
                        skip ttTmpErr.lberr[4]
                        skip ttTmpErr.lberr[5].
                when 2 then put unformatted
                        skip " "
                        skip ttTmpErr.lberr[1]
                        skip ttTmpErr.lberr[2].
                when 4 then put unformatted
                        skip " "
                        skip ttTmpErr.lberr[1]
                        skip ttTmpErr.lberr[2]
                        skip ttTmpErr.lberr[3].
            end case.
        end.
        put unformatted skip " " skip.
        output close.
        return.
    end.
    else do:
        assign
            vdMontantCphb    = vdMontantCphb + vdMontantOut
            vdMontantAppel   = - vdMontantOut
            vdMontantSolde67 = 0
        .
        for first ietab no-lock
            where ietab.soc-cd  = integer(mToken:cRefCopro)
              and ietab.etab-cd = viNumeroMandat:
            /* solde 6/7 */
            for each cecrln no-lock
                where cecrln.soc-cd = ietab.soc-cd
                  and cecrln.etab-cd = ietab.etab-cd
                  and cecrln.sscoll-cle  = ""
                  and cecrln.cpt-cd >= "6"
                  and cecrln.affair-num  = viDossierTravaux
                  and cecrln.dacompta >= (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1):
                vdMontantSolde67 = vdMontantSolde67 + (if cecrln.sens then cecrln.mt else - cecrln.mt).
            end.
            /* Déduction de la piece de cloture (si retirage) */
            for each ijou no-lock
                where ijou.soc-cd = integer(mToken:cRefCopro)
                  and ijou.etab-cd = ietab.etab-cd
                  and ijou.natjou-gi = 72
              , each cecrsai no-lock
                where cecrsai.soc-cd = ijou.soc-cd
                  and cecrsai.etab-cd = ijou.etab-cd
                  and cecrsai.jou-cd = ijou.jou-cd
              , each cecrln no-lock
                where cecrln.soc-cd         = cecrsai.soc-cd
                  and cecrln.mandat-cd      = cecrsai.etab-cd
                  and cecrln.jou-cd         = cecrsai.jou-cd
                  and cecrln.mandat-prd-cd  = cecrsai.prd-cd
                  and cecrln.mandat-prd-num = cecrsai.prd-num
                  and cecrln.piece-int      = cecrsai.piece-int
                  and cecrln.etab-cd        = ietab.etab-cd
                  and cecrln.sscoll-cle     = ""
                  and cecrln.cpt-cd         >= "6"
                  and cecrln.affair-num     = viDossierTravaux:
                vdMontantSolde67 = vdMontantSolde67 - (if cecrln.sens then cecrln.mt else - cecrln.mt).
            end.
        end.
        if vdMontantSolde67 <> vdMontantCphb
        then do:
            mError:createError({&error}, 4000025, substitute('&2&1&3&1&4&1&5&1&6&1&7&1&8',
                                                  separ[1],
                                                  viDossierTravaux,
                                                  viNumeroMandat,
                                                  string(vdMontantSolde67, "->>>>>>>9.99"),
                                                  string(vdMontantAppel, "->>>>>>>9.99"),
                                                  string(vdMontantDepense, "->>>>>>>9.99"),
                                                  string(vdMontantAppel + vdMontantDepense, "->>>>>>>9.99"),
                                                  string(vdMontantSolde67 - vdMontantCphb, "->>>>>>>9.99"))).
            return.
        end.
    end.
    plRetour = yes.

end procedure.
