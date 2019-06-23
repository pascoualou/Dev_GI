/*------------------------------------------------------------------------
File        : rcpertrt.i
Purpose     : Recherche des dates de début et fin de période pour les CRG (04008) ou les Honoraires (04021)
              Selon leur périodicité et le mois comptable + paramètre client EDCRG (MARNEZ) <Trimestriels décalés partiels en fin d'année>
Author(s)   : SY 2006/01/10 - GGA 2017/11/03
Notes       : reprise include comm\rcpertrt.i

Fiche       : 0305/0246 : CRG specif MARNEZ
Analyse     : \doc_analyseetudes\CRG\01543_Marnez\Trt_annuel_special_V01.doc
01  06/12/2006  JR    1206/0073
----------------------------------------------------------------------*/

procedure RcPerTrt private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/  
    define input  parameter plCRGDecale      as logical   no-undo.
    define input  parameter pcTypeContrat    as character no-undo.
    define input  parameter piNumeroContrat  as int64     no-undo.
    define input  parameter pcTypeTache      as character no-undo.
    define input  parameter pcTypeParam      as character no-undo.
    define input  parameter pdaDateComptable as date      no-undo.
    define output parameter plPerATraiter    as logical   no-undo.
    define output parameter pdaDebPer        as date      no-undo.
    define output parameter pdaFinPer        as date      no-undo.

    define variable viNbMoiPer as integer no-undo.
    define variable viNoPreMoi as integer no-undo.
    define variable viNoPerCal as integer no-undo.
    define variable viNoAnnCpt as integer no-undo.
    define variable viNoMoiCpt as integer no-undo.
    define variable viDtMoiRef as integer no-undo.
    define variable viDtPerIni as integer no-undo.
    define variable viDtPerDeb as integer no-undo.
    define variable viDtPerFin as integer no-undo.
    define variable viNoMoiDeb as integer no-undo.
    define variable viNoAnnDeb as integer no-undo.
    define variable viNoJouFin as integer no-undo.
    define variable viNoMoiFin as integer no-undo.
    define variable viNoMoiSui as integer no-undo.
    define variable viNoAnnFin as integer no-undo.

    define buffer tache  for tache.
    define buffer sys_pg for sys_pg.
        
    /* Récupération dans sys_pg de la Périodicité. */
    find last tache no-lock  
        where tache.TpTac = pcTypeTache
          and tache.TpCon = pcTypeContrat
          and tache.Nocon = piNumeroContrat no-error.
    if not available tache then return.
    
    find first sys_pg no-lock 
         where sys_pg.tppar = pcTypeParam
           and sys_pg.cdpar = tache.pdges no-error.
    if not available sys_pg then return.

    /* Récupération des infos sur la Périodicité. */
    assign
        viNbMoiPer = integer(sys_pg.zone6)
        viNoPreMoi = integer(sys_pg.zone7)
    .
    /* Récupération Nb de Mois et 1er Mois Période. */
    if viNbMoiPer = 0 or viNoPreMoi = 0 then return.

    /* Initialiser les Variables de Bornes pour commencer à rechercher à quelle période correspond le Mois Comptable passé en paramètre. */
    assign
        viNoAnnCpt = year(pdaDateComptable)
        viNoMoiCpt = month(pdaDateComptable)
        viNoPerCal = viNbMoiPer - 1
        viDtMoiRef = viNoAnnCpt * 12 + viNoMoiCpt
        viDtPerIni = viNoAnnCpt - 1
        viDtPerDeb = viDtPerIni * 12 + viNoPreMoi 
        viDtPerFin = viDtPerDeb + viNoPerCal 
    .
    do while viDtMoiRef < viDtPerDeb or viDtMoiRef > viDtPerFin:
        assign
            viDtPerDeb = viDtPerDeb + viNbMoiPer
            viDtPerFin = viDtPerDeb + viNoPerCal
        .
    end.
    /* Conversion Nb mois -> Date */
    assign
        viNoMoiDeb = viDtPerDeb modulo 12
        viNoAnnDeb = truncate(viDtPerDeb / 12, 0)
        viNoMoiFin = viDtPerFin modulo 12
        viNoAnnFin = truncate(viDtPerFin / 12, 0)
    .
    if viNoMoiDeb = 0 
    then assign
        viNoMoiDeb = 12
        viNoAnnDeb = viNoAnnDeb - 1
    .
    if viNoMoiFin = 0 
    then assign
        viNoMoiFin = 12
        viNoAnnFin = viNoAnnFin - 1     
        viNoMoiSui = 01
    .
    else viNoMoiSui = viNoMoiFin + 1.
    /* Détermination du Jour de Fin de la période. */
    assign
        viNoJouFin = day(date(viNoMoiSui, 01, viNoAnnFin) - 1)
        pdaDebPer  = date(viNoMoiDeb, 01, viNoAnnDeb)
        pdaFinPer  = date(viNoMoiFin, viNoJouFin, viNoAnnFin)
    . 
    /* <Trimestriels décalés partiels en fin d'année> */
    if pcTypeTache = {&TYPETACHE-compteRenduGestion} 
    and pcTypeParam  = "O_PRD"
    and (tache.pdges = {&PERIODICITEGESTION-trimestrielFevAvril}
      or tache.pdges = {&PERIODICITEGESTION-trimestrielMarsMai}) 
    and (viNoMoiCpt = 11 or viNoMoiCpt = 12 or viNoMoiCpt = 01 or viNoMoiCpt = 02) 
    and plCRGDecale
    then case tache.pdges:
        when {&PERIODICITEGESTION-trimestrielFevAvril}
        then case viNoMoiCpt:
            when 12 then assign 
                 pdaDebPer     = date(11, 01, viNoAnnCpt)
                 pdaFinPer     = date(12, 31, viNoAnnCpt)
                 plPerATraiter = true
            .
            when 01 then assign 
                 pdaDebPer     = date(01, 01, viNoAnnCpt)
                 pdaFinPer     = date(01, 31, viNoAnnCpt)
                 plPerATraiter = true
            .
            when 02 then if viDtMoiRef = viDtPerFin then plPerATraiter = true. /* Traitement Normal */
        end case.
        when {&PERIODICITEGESTION-trimestrielMarsMai}
        then case viNoMoiCpt:
            when 11 then if viDtMoiRef = viDtPerFin then plPerATraiter = true. /* Traitement Normal */
            when 12 then assign 
                 pdaDebPer     = date(12, 01, viNoAnnCpt)
                 pdaFinPer     = date(12, 31, viNoAnnCpt)
                 plPerATraiter = true
            .
            when 02 then assign
                 pdaDebPer     = date(01, 01, viNoAnnCpt)
                 pdaFinPer     = date(03, 01, viNoAnnCpt) - 1       /* fin février */
                 plPerATraiter = true
            .
        end case.
    end case.
    else if viDtMoiRef = viDtPerFin then plPerATraiter = true.            /* Traitement à effectuer pour ce mois comptable */

end procedure.
