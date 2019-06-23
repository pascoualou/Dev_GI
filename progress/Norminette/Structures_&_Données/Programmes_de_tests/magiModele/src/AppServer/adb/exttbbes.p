/*-----------------------------------------------------------------------------
File        : exttbbes.p
Purpose     : Extraction table partagé Loi Perissol et Besson   
Author(s)   : AF - 2001/10/08, GGA - 2018/01/15 
Notes       : reprise de adb/src/cpta/exttbbes.p
derniere revue: 2018/04/26 - phm: OK

01 12/11/2003  AF    Loi Robien
02 03/12/2004  AF    Pb format numeric avec le taux
03 24/11/2006  PL    0106/0018: suppression format american ADB
04 01/12/2006  AF    0306/0249 modification loi irf 2006
05 21/12/2006  PL    forçage format européen car taux loi stocké au format européen
06 29/12/2009  OF    0709/0062 IRF 2009 Ajout loi Scellier
07 06/01/2014  NP    1213/0171 Add Loi Duflot + Loi Duflot Outre-mer 
08 10/11/2014  PL    1014/0145 Add Loi Pinel 
09 24/02/2015  CC    0215/0223
10 13/03/2015  SY    0215/0223 Editer TOUTES les lois même celles sans amortissement
                     + ignorer les mandats résiliés depuis plus de 2 ans  
------------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.syspr.parametrageLoi.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adb/include/ttPerissolBesson.i}

function jourFinMois returns date private(pdaDate as date):
    /*-------------------------------------------------------------------------
    Purpose : retourne dernier jour du mois 
    Notes   : 
    -------------------------------------------------------------------------*/
    return add-interval(date(substitute("01/&1/&2", month(pdaDate), year(pdaDate))), 1, "months") - 1.
end function.
function jourDebutMois returns date private(pdaDate as date):
    /*-------------------------------------------------------------------------
    Purpose : retourne premier jour du mois 
    Notes   : 
    -------------------------------------------------------------------------*/
    return date(substitute("01/&1/&2", month(pdaDate), year(pdaDate))).
end function.
function ajoutAnnee returns date private(piNombreAnnee as integer, pdaDate as date):
    /*-------------------------------------------------------------------------
    Purpose : ajout nombre annee a une date 
    Notes   : 
    -------------------------------------------------------------------------*/
    return add-interval(pdaDate, piNombreAnnee, "year").
end function.

procedure getTabPerissolBesson:
    /*--------------------------------------------------------------------------- 
    Purpose : 
    Notes   : service externe appelé par tacheLoiDefiscalisationIRF.p
    ---------------------------------------------------------------------------*/ 
    define input parameter piNumeroMandatDebut   as int64   no-undo.
    define input parameter piNumeroMandatFin     as int64   no-undo.
    define input parameter piNumeroExerciceDebut as integer no-undo.
    define input parameter piNumeroExerciceFin   as integer no-undo.
    define output parameter table for ttPerissolBesson.
 
    define variable voParametrageLoi as class parametrageLoi no-undo. 
    define variable vcCdLoiUse as character no-undo.
    define variable vdaVenUse  as date      no-undo.
    define variable vdaFinUse  as date      no-undo.
    define variable vdaDebExo  as date      no-undo.
    define variable vdaFinExo  as date      no-undo.
    define variable viNbMoiUse as integer   no-undo.
    define variable viI        as integer   no-undo.
    define variable vdMtAchUse as decimal   no-undo.
    define variable vdTxLoiUs1 as decimal   no-undo.
    define variable viNbLoiUs1 as integer   no-undo.
    define variable vdTxLoiUs2 as decimal   no-undo.
    define variable viNbLoiUs2 as integer   no-undo.
    define variable vdTxLoiUs3 as decimal   no-undo.
    define variable viNbLoiUs3 as integer   no-undo.
    define variable vdTxTrxUse as decimal   no-undo.
    define variable viNbTrxUse as integer   no-undo.
    define variable vdaDebPe1  as date      no-undo.
    define variable vdaFinPe1  as date      no-undo.
    define variable vdaDebPe2  as date      no-undo.
    define variable vdaFinPe2  as date      no-undo.
    define variable vdaDebPe3  as date      no-undo.
    define variable vdaFinPe3  as date      no-undo.
    define variable vdaDebTrx  as date      no-undo.
    define variable vdaFinTrx  as date      no-undo.
    define variable vcLbCalUse as character no-undo.
    define variable vdMtDecUse as decimal   no-undo.
     
    define buffer ctrat  for ctrat. 
    define buffer etxdt  for etxdt. 
    define buffer local  for local. 

    empty temp-table ttPerissolBesson.
    voParametrageLoi = new parametrageLoi().
    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon >= piNumeroMandatDebut
          and ctrat.nocon <= piNumeroMandatFin
          and (ctrat.dtree = ? or (ctrat.dtree <> ? and ctrat.dtree > add-interval(today, -2, "year")))      /* Ajout SY le 13/03/2015 ignorer mandat résilié depuis plus de 2 ans */
      , each etxdt no-lock
        where etxdt.notrx = ctrat.nocon
      , first local no-lock
        where local.noloc = etxdt.nolot
        break by etxdt.notrx by etxdt.nolot by etxdt.tpapp by etxdt.noapp:

        if first-of(etxdt.noapp) then do:
            /*--> Parametrage du lot */
            if etxdt.tpapp = "00000" then do:
                voParametrageLoi:reload(etxdt.lbdiv3).
                assign
                    vcCdLoiUse = etxdt.lbdiv3
                    vdaVenUse  = if num-entries(etxdt.lbdiv2, "@") >= 2 then date(entry(2, etxdt.lbdiv2, "@")) else ?
                    vdaVenUse  = if vdaVenUse = ? then date("31/12/9999") else jourFinMois(vdaVenUse)
                    vdaFinUse  = if num-entries(etxdt.lbdiv2,"@") >= 3 then date(entry(3, etxdt.lbdiv2, "@")) else ?
                    vdaFinUse  = if vdaFinUse = ? then date("31/12/9999") else jourFinMois(vdaFinUse)
                    vdaFinUse  = minimum(vdaFinUse, vdaVenUse)
                    vdTxLoiUs1 = voParametrageLoi:dTauxAmmortissementPer1
                    viNbLoiUs1 = voParametrageLoi:iNbAmmortissementPer1
                    vdTxLoiUs2 = voParametrageLoi:dTauxAmmortissementPer2
                    viNbLoiUs2 = voParametrageLoi:iNbAmmortissementPer2 
                    vdTxLoiUs3 = voParametrageLoi:dTauxAmmortissementPer3
                    viNbLoiUs3 = voParametrageLoi:iNbAmmortissementPer3 
                    vdTxTrxUse = voParametrageLoi:dTauxAmmortissementTravaux
                    viNbTrxUse = voParametrageLoi:iNbAmmortissementTravaux
                .
                if voParametrageLoi:lParamExistPer2 = yes
                then assign
                    viNbLoiUs2 = if etxdt.vltan <> 0 and viNbLoiUs1 + viNbLoiUs2 > etxdt.vltan then etxdt.vltan - viNbLoiUs1 else viNbLoiUs2
                    viNbLoiUs2 = if viNbLoiUs2 < 0 then 0 else viNbLoiUs2
                .
                if voParametrageLoi:lParamExistPer3 = yes
                then assign
                    viNbLoiUs3 = if etxdt.vltan <> 0 and viNbLoiUs1 + viNbLoiUs2 + viNbLoiUs3 > etxdt.vltan then etxdt.vltan - viNbLoiUs1 - viNbLoiUs2 else viNbLoiUs3
                    viNbLoiUs3 = if viNbLoiUs3 < 0 then 0 else viNbLoiUs3
                .
            end.
            /*--> Achat / Frais d'acquisition / Trx reconstruction / Trx Agrandissement */
            if etxdt.tpapp = "00000" or etxdt.tpapp = "00001" or etxdt.tpapp = "00002" or etxdt.tpapp = "00003" 
            then do:
                assign
                    vdMtAchUse = etxdt.mtlot + etxdt.ttlot
                    vdaDebPe1  = jourDebutMois(date(entry(1, etxdt.lbdiv2, "@")))
                    vdaFinPe1  = jourFinMois(ajoutAnnee(viNbLoiUs1, vdaDebPe1 - 1))
                    vdaFinPe1  = if vdaFinPe1 > vdaFinUse then vdaFinUse else vdaFinPe1
                    vdaDebPe2  = vdaFinPe1 + 1
                    vdaFinPe2  = jourFinMois(ajoutAnnee(viNbLoiUs2, vdaDebPe2 - 1))
                    vdaFinPe2  = if vdaFinPe2 > vdaFinUse then vdaFinUse else vdaFinPe2
                    vdaDebPe3  = vdaFinPe2 + 1
                    vdaFinPe3  = jourFinMois(ajoutAnnee(viNbLoiUs3, vdaDebPe3 - 1))
                    vdaFinPe3  = if vdaFinPe3 > vdaFinUse then vdaFinUse else vdaFinPe3
                .
                do viI = piNumeroExerciceDebut to piNumeroExerciceFin:
                    assign
                        vcLbCalUse = ""
                        vdMtDecUse = 0
                        vdaDebExo = maximum(vdaDebPe1,date("01/01/" + string(viI)))
                        vdaFinExo = minimum(vdaFinPe1,date("31/12/" + string(viI)))
                    .
                    if year(vdaDebExo) = viI and year(vdaFinExo) = viI
                    then assign
                        viNbMoiUse = month(vdaFinExo) - month(vdaDebExo) + 1
                        vcLbCalUse = substitute("&1% sur &2", vdTxLoiUs1, viNbMoiUse)
                        vdMtDecUse = (vdMtAchUse * vdTxLoiUs1 / 100) * viNbMoiUse / 12
                    .
                    /*--> Calcul sur le 2eme type de période */
                    assign
                        vdaDebExo = maximum(vdaDebPe2,date("01/01/" + string(viI)))
                        vdaFinExo = minimum(vdaFinPe2,date("31/12/" + string(viI)))
                    .
                    if year(vdaDebExo) = viI and year(vdaFinExo) = viI 
                    then assign
                         viNbMoiUse = month(vdaFinExo) - month(vdaDebExo) + 1
                         vcLbCalUse = substitute("&1&2% sur &3", if vcLbCalUse > "" then vcLbCalUse + " " else "", vdTxLoiUs2, viNbMoiUse)                
                         vdMtDecUse = vdMtDecUse + (vdMtAchUse * vdTxLoiUs2 / 100) * viNbMoiUse / 12
                    .
                    /*--> Calcul sur le 3eme type de période */
                    assign
                        vdaDebExo = maximum(vdaDebPe3, date("01/01/" + string(viI)))
                        vdaFinExo = minimum(vdaFinPe3, date("31/12/" + string(viI)))
                    .
                    if year(vdaDebExo) = viI and year(vdaFinExo) = viI 
                    then assign
                        viNbMoiUse = month(vdaFinExo) - month(vdaDebExo) + 1
                        vcLbCalUse = substitute("&1&2% sur &3", if vcLbCalUse > "" then vcLbCalUse + " " else "", vdTxLoiUs3, viNbMoiUse)                         
                        vdMtDecUse = vdMtDecUse + (vdMtAchUse * vdTxLoiUs3 / 100) * viNbMoiUse / 12
                    .
                    create ttPerissolBesson.
                    assign
                        vdMtDecUse = round(vdMtDecUse, 2)
                        ttPerissolBesson.iNoMdt = etxdt.notrx
                        ttPerissolBesson.iNoImm = local.noimm
                        ttPerissolBesson.iNoLot = local.nolot
                        ttPerissolBesson.cTpAct = etxdt.tpapp
                        ttPerissolBesson.iNoExo = viI
                        ttPerissolBesson.cCdLoi = vcCdLoiUse
                        ttPerissolBesson.daAch  = date(entry(1, etxdt.lbdiv2, "@"))
                        ttPerissolBesson.daVen  = if num-entries(etxdt.lbdiv2, "@") >= 2 then date(entry(2, etxdt.lbdiv2, "@")) else ?
                        ttPerissolBesson.daFin  = if num-entries(etxdt.lbdiv2, "@") >= 3 then date(entry(3, etxdt.lbdiv2, "@")) else ?
                        ttPerissolBesson.dMtAch = vdMtAchUse
                        ttPerissolBesson.cLbCal = vcLbCalUse
                        ttPerissolBesson.dMtDec = vdMtDecUse
                    .
                end.
            end.
            /*--> Trx Amelioration */
            else do:
                assign
                    vdMtAchUse = etxdt.mtlot
                    vdaDebTrx  = jourDebutMois(date(entry(1, etxdt.lbdiv2, "@")))
                    vdaFinTrx  = jourFinMois(ajoutAnnee(viNbTrxUse, vdaDebTrx - 1))
                    vdaFinTrx  = if vdaFinTrx > vdaFinUse then vdaFinUse else vdaFinTrx
                .
                do viI = piNumeroExerciceDebut to piNumeroExerciceFin:
                    assign
                        vcLbCalUse = ""
                        vdMtDecUse = 0
                        vdaDebExo = maximum(vdaDebTrx, date("01/01/" + string(viI)))
                        vdaFinExo = minimum(vdaFinTrx, date("31/12/" + string(viI)))
                    .  
                    if year(vdaDebExo) = viI and year(vdaFinExo) = viI 
                    then assign
                        viNbMoiUse = month(vdaFinExo) - month(vdaDebExo) + 1
                        vcLbCalUse = substitute("&1% sur &2", vdTxTrxUse, viNbMoiUse)         
                        vdMtDecUse = (vdMtAchUse * vdTxTrxUse / 100) * viNbMoiUse / 12
                        vdMtDecUse = round(vdMtDecUse, 2)                             
                    .
                    create ttPerissolBesson.
                    assign
                        ttPerissolBesson.iNoMdt = etxdt.notrx
                        ttPerissolBesson.iNoImm = local.noimm
                        ttPerissolBesson.iNoLot = local.nolot
                        ttPerissolBesson.cTpAct = etxdt.tpapp
                        ttPerissolBesson.iNoExo = viI
                        ttPerissolBesson.cCdLoi = vcCdLoiUse
                        ttPerissolBesson.daAch  = date(entry(1, etxdt.lbdiv2, "@"))
                        ttPerissolBesson.dMtAch = vdMtAchUse
                        ttPerissolBesson.cLbCal = vcLbCalUse
                        ttPerissolBesson.dMtDec = vdMtDecUse
                    .
                end.
            end.
        end.
    end.
    delete object voParametrageLoi.

end procedure.
