/*------------------------------------------------------------------------
File        : montantDeclareOrgSociaux.p
Purpose     : Visualisation des lignes déclaration reçues par Mandat/Organisme/période
Author(s)   : GGA - 2017/11/14
Notes       : a partir de adb/paie/visecorg.p
derniere revue : 2018/04/11  - phm - OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adb/paie/include/montantDeclareOrgSociaux.i}
{application/include/glbsepar.i}

procedure getMontantDeclareOrgSociaux:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeMandat   as character no-undo.
    define input  parameter pcOrganisme    as character no-undo. 
    define input  parameter pdaDebPer      as date      no-undo.
    define input  parameter pdaFinPer      as date      no-undo.
    define output parameter table for ttMontantDeclareOrgSociaux.
 
    define buffer etabl for etabl.  
    
    empty temp-table ttMontantDeclareOrgSociaux.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeMandat
                      and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    for first etabl no-lock
        where etabl.tpcon = pcTypeMandat
          and etabl.nocon = piNumeroMandat
          and etabl.tptac = {&TYPETACHE-organismesSociaux}:
        run chgMontantPegase(buffer etabl, pcOrganisme, pdaDebPer, pdaFinPer). 
    end.

end procedure.

procedure ChgMontantPegase private:
    /*------------------------------------------------------------------------------
    Purpose: chargement montant declare sous pegase 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer etabl for etabl.    
    define input parameter pcOrganisme as character no-undo. 
    define input parameter pdaDebPer   as date no-undo.
    define input parameter pdaFinPer   as date no-undo.
    
    define variable vcLienPaiement as character no-undo.
    define buffer detail for detail.
    define buffer cecrln for cecrln.
 
    for each detail no-lock
       where detail.cddet    begins "PZ_DECLA" 
         and detail.nodet    = etabl.nocon
         and detail.ixd01    = pcOrganisme
         and detail.tbdat[2] >= pdaDebPer
         and detail.tbdat[3] <= pdaFinPer:
        create ttMontantDeclareOrgSociaux.
        assign
            ttMontantDeclareOrgSociaux.daDebut        = detail.tbdat[2]
            ttMontantDeclareOrgSociaux.daFin          = detail.tbdat[3]
            ttMontantDeclareOrgSociaux.cNoDeclarant   = detail.tbchr[2]
            ttMontantDeclareOrgSociaux.dMontant       = detail.tbdec[1]
            ttMontantDeclareOrgSociaux.lRegle         = detail.tblog[1]
            ttMontantDeclareOrgSociaux.cInfoReglement = (if detail.tbchr[12] <> ? then detail.tbchr[12] else "") 
            vcLienPaiement                            = detail.tbchr[11]
        .
        /* libellé infos extraction Pégase à partir de TYPPERIODICITE / CODPERIODE  */      
        if num-entries(detail.tbchr[1], ";") >= 9 
        then ttMontantDeclareOrgSociaux.cPeriodeExtr = substitute('&1-&2', trim(entry(8, detail.tbchr[1], ";")), trim(entry(9, detail.tbchr[1], ";"))).
        /* décodage lienpaiement : CECRLN@BQU6@18@10@32@10 = "CECRLN" + "@" + cecrln.jou-cd + "@" + STRING(cecrln.prd-cd) + "@" + STRING(cecrln.prd-num) + "@" + STRING(cecrln.piece-int) + "@" + STRING(cecrln.lig) */
        if vcLienPaiement begins "CECRLN" and num-entries(vcLienPaiement , "@") >= 6 
        then do:
            find first cecrln no-lock
                 where cecrln.soc-cd    = integer((if etabl.tpcon = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance else mtoken:cRefCopro))
                   and cecrln.etab-cd   = etabl.nocon
                   and cecrln.jou-cd    = entry(2, vcLienPaiement, "@")
                   and cecrln.prd-cd    = integer(entry(3, vcLienPaiement, "@"))
                   and cecrln.prd-num   = integer(entry(4, vcLienPaiement, "@"))
                   and cecrln.piece-int = integer(entry(5, vcLienPaiement, "@"))
                   and cecrln.lig       = integer(entry(6, vcLienPaiement, "@")) no-error.
            if available cecrln
            then ttMontantDeclareOrgSociaux.cInfoReglement = outilFormatage:fSubst(outilTraduction:getLibelle(1000641), substitute("&2&1&3", separ[1], cecrln.dacompta, cecrln.lib-ecr[1])). //Paiement organisme comptabilisé au &1: &2
            else mLogger:writeLog(1, substitute("Mandat &1 Organisme &2 No chrono Cbap: &3 : Ecriture de paiement non trouvée: &4", etabl.nocon, pcOrganisme, replace(detail.tbchr[10], "cbap.chrono=", ""), vcLienPaiement)).
        end.
    end.

end procedure.
