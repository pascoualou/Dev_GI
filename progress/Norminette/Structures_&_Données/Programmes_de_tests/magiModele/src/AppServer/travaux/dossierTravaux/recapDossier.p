/*------------------------------------------------------------------------
File        : recapdossier.p
Purpose     :
Author(s)   : gga - 2017/06/28
Notes       : a partir de gesclotu.p
Tables      : BASE sadb :   
----------------------------------------------------------------------*/
{preprocesseur/typeAppel2fonds.i} 
{preprocesseur/typeAppel.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{travaux/include/dossierTravaux.i}
{travaux/include/suiviFinancier.i}
{travaux/include/appelDefond.i}
{compta/include/TbTmpAna.i}
  
/* declaration en global de ces variables car initialisées dans la procedure getRecapDossier et ensuite utilisées uniquement en lecture */ 
define variable giNoRefUse             as integer   no-undo. 
define variable gcTypeMandat           as character no-undo.
define variable giNumeroMandat         as integer   no-undo.
define variable giNumeroDossierTravaux as integer   no-undo.

define temp-table ttProrata no-undo 
    field cdCle as character
    field poCle as decimal        
    index cdCle is unique primary cdCle.
            
/** Tous les Honoraires facturés (comptabilisés ou non-comptabilisés) dans l'écran selhono.p: par la chaine des travaux **/
define temp-table ttHonFact no-undo 
    field cdCle as character
    field mtCle as decimal
    field mtTva as decimal     
index CdCle is unique primary CdCle.

/** Honoraires facturés et non-comptabilisés dans l'écran selhono.p: par la chaine des travaux **/
define temp-table ttHonFactNonCompt no-undo 
    field cdCle as character
    field mtCle as decimal
    field mtTva as decimal               
    field mtht  as decimal
    field rRwd  as character /** Rowid du ifdhono **/
index CdCle is unique primary CdCle.

/** Honoraires facturés et comptabilisés dans l'écran selhono.p: par la chaine des travaux **/
define temp-table ttHonFactCompt no-undo 
    field cdCle as character
    field mtCle as decimal
    field mtTva as decimal        
index CdCle is unique primary CdCle.

/** Honoraires restant à facturer **/
define temp-table ttHonRestAFact no-undo 
    field cdCle as character
    field mtCle as decimal
    field fgAff as logical       
    field mtht  as decimal
    field mttva as decimal
index CdCle is unique primary CdCle.

procedure getRecapDossier:
    /*------------------------------------------------------------------------------
    Purpose: extrait pgm gesclotu.p (procedure initialisation)  
    Notes  : service externe (beRecapDossier.cls, dossiertravaux.p) 
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.    
    define output parameter table for ttRecapDossierTravaux.

    define variable vcCptAppel   as character no-undo.
    define variable vcCptHonor   as character no-undo.
    define variable vcCptDepen   as character no-undo.
    define variable vcAnaHonoTvx as character no-undo. 
    
    define buffer trdos for trdos. 

    assign
        gcTypeMandat           = poCollection:getCharacter("cTypeMandat")
        giNumeroMandat         = poCollection:getinteger("iNumeroMandat")
        giNumeroDossierTravaux = poCollection:getinteger("iNumeroDossierTravaux")
    . 
  
message "gga getRecapDossier " gcTypeMandat "//" giNumeroMandat "//"  giNumeroDossierTravaux. 
    
    empty temp-table ttRecapDossierTravaux. 
    create ttRecapDossierTravaux. 
    assign
        ttRecapDossierTravaux.iNumeroDossierTravaux = giNumeroDossierTravaux  
        ttRecapDossierTravaux.iNumeroMandat         = giNumeroMandat
        ttRecapDossierTravaux.iNumeroImmeuble       = ?
        ttRecapDossierTravaux.CRUD                  = 'R'
        /* gga todo a voir si on ne peut pas utiliser directement mtoken:cRefPrincipale */  
        giNoRefUse = integer(if gcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance) 
    .
    for first trdos no-lock 
        where trdos.tpcon = gcTypeMandat
          and trdos.nocon = giNumeroMandat
          and trdos.nodos = giNumeroDossierTravaux:
        /**Ajout OF le 13/09/11**/
        if gcTypeMandat = {&TYPECONTRAT-mandat2Gerance}
        then assign 
            vcCptDepen = "Factures"
            vcCptHonor = "Honoraires"
            vcCptAppel = "106000000" 
            vcAnaHonoTvx = "116262"
        .
        else if trdos.tpurg <> "00001" 
        then assign 
            vcCptDepen = "671000000"
            vcCptHonor = "671100000"
            vcCptAppel = "702100000"
        .
        else assign 
            vcCptDepen = "672000000"
            vcCptHonor = "672200000"
            vcCptAppel = "702200000"
        .           
    end.
    run calculMontants(poCollection, vcCptAppel, vcCptHonor, vcCptDepen, vcAnaHonoTvx).       

/*ggg
    /*--> Impossible de comptabiliser des honoraires en comptabilisation par OD 1006/0177 */
    find first ifdparam 
    where ifdparam.soc-dest = integer(if vcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
    no-lock no-error.
    if available ifdparam 
    and not ifdparam.fg-od
    then HwBtnHonAuto:SENSITIVE = true.                   
    else HwBtnHonAuto:SENSITIVE = false.                  
        /*--> Ouverture de la query des interventions */
        run GestTrie.
        /*--> Sensitivité */
        run GestSensitive.
        /*--> Afficher en premier plan la frame */
        frame HwFrmUse:MOVE-TO-TOP().
        HwBtnHonAuto:VISIBLE in frame HwFrmUse = not(FgCloture).
ggg*/

end procedure. 
 
procedure CalculMontants private:
    /*------------------------------------------------------------------------------
    Purpose: extrait pgm gesclotu.p (procedure CalculMontants)  
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.    
    define input parameter pcCptAppel   as character no-undo.
    define input parameter pcCptHonor   as character no-undo.
    define input parameter pcCptDepen   as character no-undo.
    define input parameter pcAnaHonoTvx as character no-undo.

    define variable vdMtFTAUse as decimal no-undo.
    define variable vdSldAppel as decimal no-undo.
    define variable vdSldHonor as decimal no-undo.
    define variable vdSldDepen as decimal no-undo.
    define variable vdMtRepUse as decimal no-undo.
    define variable vdMtOrdUse as decimal no-undo.
    define variable vdMtFacUse as decimal no-undo.
    define variable vdMtAppUse as decimal no-undo.
    define variable vdMtEncUse as decimal no-undo.
    define variable vdMtRegUse as decimal no-undo.
    define variable vdMtResUse as decimal no-undo.
    define variable vhProc     as handle  no-undo. 

    define buffer apbco for apbco. 

    run calculSolde(if gcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then "M" else "", pcCptDepen, pcAnaHonoTvx, output vdSldDepen).
    run calculSolde(if gcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then "M" else "", pcCptHonor, pcAnaHonoTvx, output vdSldHonor).
    run calculSolde("",                                                               pcCptAppel, pcAnaHonoTvx, output vdSldAppel).

    assign
        vdSldAppel = - vdSldAppel
        vdMtFTAUse = 0
    .
    for each apbco fields (apbco.mtlot) no-lock
        where apbco.tpbud     = {&TYPEBUDGET-travaux}
          and apbco.nobud     = giNumeroMandat * 100000 + giNumeroDossierTravaux
          and apbco.tpapp     = "TX"
          and apbco.nomdt     = giNumeroMandat
          and apbco.typapptrx = {&TYPEAPPEL2FONDS-fondtravauxAlur}:       
        vdMtFTAUse = vdMtFTAUse + apbco.mtlot.              
    end.
    assign 
        vdMtFacUse = vdSldHonor + vdSldDepen
        vdMtAppUse = vdSldAppel - vdMtFTAUse
        vdMtRepUse = 0
        vdMtOrdUse = 0         
        vdMtEncUse = 0
        vdMtRegUse = 0
        vdMtResUse = 0
    .
    run travaux/dossierTravaux/suiviFinancier.p persistent set vhProc. 
    run getTokenInstance in vhProc(mToken:JSessionId).  
    run getSuiviFinancier in vhProc (gcTypeMandat,                  
                                     giNumeroMandat, 
                                     giNumeroDossierTravaux, 
                                     "LISTE", 
                                     ?,
                                     output table ttListeSuiviFinancierClient by-reference,
                                     output table ttDetailSuiviFinancierClient by-reference,
                                     output table ttListeSuiviFinancierTravaux by-reference).                                      
    run destroy in vhProc.     
 
    for each ttListeSuiviFinancierTravaux: 
        assign 
            vdMtRepUse = vdMtRepUse + ttListeSuiviFinancierTravaux.dMontantReponseDevis
            vdMtOrdUse = vdMtOrdUse + ttListeSuiviFinancierTravaux.dMontantOrdre2Service
            vdMtEncUse = vdMtEncUse + ttListeSuiviFinancierTravaux.dMontantEncaissement
            vdMtRegUse = vdMtRegUse + ttListeSuiviFinancierTravaux.dMontantRegle
            vdMtResUse = vdMtResUse + ttListeSuiviFinancierTravaux.dMontantResteDu
        .
    end.
    assign 
        ttRecapDossierTravaux.dRepDev = vdMtRepUse
        ttRecapDossierTravaux.dOrdSer = vdMtOrdUse
        ttRecapDossierTravaux.dFac    = vdMtFacUse
        ttRecapDossierTravaux.dAppApp = vdMtAppUse
        ttRecapDossierTravaux.dAppEnc = vdMtEncUse
        ttRecapDossierTravaux.dDepReg = vdMtRegUse
        ttRecapDossierTravaux.dTotHon = vdSldHonor
        ttRecapDossierTravaux.dSldDos = vdMtAppUse - vdMtFacUse
        ttRecapDossierTravaux.dSldTre = vdMtEncUse - vdMtRegUse
        ttRecapDossierTravaux.dAppFTA = vdMtFTAUse
    . 
    run Charge_Honoraires (poCollection).        /** Honoraires **/

end procedure.
 
procedure CalculSolde private:
    /*------------------------------------------------------------------------------
    Purpose: extrait pgm gesclotu.p (procedure CalculSolde)  
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcColl-in    as character no-undo.
    define input parameter pcCpt-in     as character no-undo.
    define input parameter pcAnaHonoTvx as character no-undo.    
    define output parameter pdsld-ou    as decimal   no-undo.

    define buffer cecrln    for cecrln. 
    define buffer cecrlnana for cecrlnana.  

    for each cecrln no-lock 
        where cecrln.soc-cd     = giNoRefUse
          and cecrln.etab-cd    = giNumeroMandat
          and cecrln.sscoll-cle = pcColl-in
          and cecrln.cpt-cd     = (if pcColl-in = "M" then "00000" else pcCpt-in)
          and cecrln.affair-num = giNumeroDossierTravaux:
        /*En gérance, on distingue les honoraires et les factures par l'analytique utilisée*/
        if cecrln.sscoll-cle = "M" 
        then for each cecrlnana no-lock
            where cecrlnana.soc-cd    = cecrln.soc-cd
              and cecrlnana.etab-cd   = cecrln.etab-cd
              and cecrlnana.jou-cd    = cecrln.jou-cd
              and cecrlnana.prd-cd    = cecrln.prd-cd
              and cecrlnana.prd-num   = cecrln.prd-num
              and cecrlnana.piece-int = cecrln.piece-int
              and cecrlnana.lig       = cecrln.lig:
            if (pcCpt-in = "Honoraires" and cecrlnana.ana1-cd + cecrlnana.ana2-cd =  pcAnaHonoTvx)
            or (pcCpt-in = "Factures"   and cecrlnana.ana1-cd + cecrlnana.ana2-cd <> pcAnaHonoTvx) 
            then pdsld-ou = pdsld-ou + (if cecrln.sens then 1 else - 1) * cecrln.mt.
        end.
        /*On ne tient pas compte des remboursements de provisions en gérance*/
        else if cecrln.cpt-cd = "106000000" 
        and can-find(first ijou no-lock  
                     where ijou.soc-cd    = cecrln.soc-cd
                       and ijou.etab-cd   = cecrln.mandat-cd
                       and ijou.jou-cd    = cecrln.jou-cd
                       and ijou.natjou-gi = 67 /*AFTXA*/) 
        then .
        else pdsld-ou = pdsld-ou + (if cecrln.sens then 1 else - 1) * cecrln.mt.
    end.

end procedure.
 
procedure Charge_Honoraires private:
    /*------------------------------------------------------------------------------
    Purpose: extrait pgm gesclotu.p (procedure Charge_Honoraires)  
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.         

    define variable vdMtTotIfdhonoCpt            as decimal   no-undo.
    define variable vdMtTotHonoIfdhono           as decimal   no-undo.
    define variable vdMtTotHonoIfdhonoNonCpt     as decimal   no-undo.
    define variable vdMtTotHonoAutoResteAFacture as decimal   no-undo.

    run Facturation_Automatique (poCollection,
                                 output vdMtTotIfdhonoCpt, 
                                 output vdMtTotHonoIfdhono, 
                                 output vdMtTotHonoIfdhonoNonCpt,
                                 output vdMtTotHonoAutoResteAFacture).
  
    /** Gestion des arrondis **/
    if absolute (vdMtTotHonoAutoResteAFacture) < 0.05 
    and vdMtTotHonoIfdhonoNonCpt = 0 
    and vdMtTotIfdhonoCpt = vdMtTotHonoIfdhono 
    then do:
        vdMtTotHonoAutoResteAFacture = 0.    
        empty temp-table ttHonRestAFact.  
    end.
    assign 
        ttRecapDossierTravaux.dHonAuto                    = vdMtTotIfdhonoCpt
        ttRecapDossierTravaux.dHonAutoFacturer            = vdMtTotHonoIfdhono
        ttRecapDossierTravaux.dHonAutoResteAComptabiliser = vdMtTotHonoIfdhonoNonCpt
        ttRecapDossierTravaux.dHonAutoResteAFacturer      = vdMtTotHonoAutoResteAFacture
    .
    run Facturation_Manuelle (vdMtTotIfdhonoCpt).

end procedure.
 
procedure Facturation_Manuelle private:
    /*------------------------------------------------------------------------------
    Purpose: extrait pgm gesclotu.p (procedure Facturation_Manuelle)  
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pdMtTotIfdhonoCpt-in as decimal no-undo.

    define variable vdMtTotHonoIfdsaiCpt    as decimal    no-undo.
    define variable vdMtTotHonoIfdsaiNonCpt as decimal    no-undo.

    define buffer ifdsai for ifdsai.  
    define buffer ifdln for ifdln.  

    /*-------------------------------------------------------------------------------------------------
    FACTURES HONORAIRES PAR LA FACTURATION MANUELLE IFDSAI
    -------------------------------------------------------------------------------------------------*/
    for each ifdsai no-lock  
        where ifdsai.soc-dest       = giNoRefUse
          and ifdsai.etab-dest      = giNumeroMandat
          and ifdsai.typefac-cle    = (if gcTypeMandat = "01030" then "14" else "13")
          and ifdsai.soc-cd         > 0 /* RF 30/11/2010 - filtre facture supprimées */
      , each ifdln no-lock 
        where ifdln.soc-cd  = ifdsai.soc-cd
          and ifdln.etab-cd = ifdsai.etab-cd
          and ifdln.com-num = ifdsai.com-num
          and ifdln.affair-num = giNumeroDossierTravaux:
        if ifdsai.fg-cpta-adb 
        then vdMtTotHonoIfdsaiCpt    = vdMtTotHonoIfdsaiCpt    + (ifdln.puht * ifdln.qtefac + ifdln.mttva) * (if ifdsai.typenat-cd = 2 then 1 else - 1).
        else vdMtTotHonoIfdsaiNonCpt = vdMtTotHonoIfdsaiNonCpt + (ifdln.puht * ifdln.qtefac + ifdln.mttva) * (if ifdsai.typenat-cd = 2 then 1 else - 1).
    end.
    /** Pour extraire les factures manuelles comptabilisées, il faut retirer de la totalité des factures 13 comptabilisées 
           celles provenant des ifdhono de la chaine des travaux **/
    assign 
        vdMtTotHonoIfdsaiCpt                   = vdMtTotHonoIfdsaiCpt - pdMtTotIfdhonoCpt-in
        ttRecapDossierTravaux.dHonManu         = vdMtTotHonoIfdsaiCpt
        ttRecapDossierTravaux.dHonManuFacturer = vdMtTotHonoIfdsaiNonCpt
    .

end procedure.
 
procedure Facturation_Automatique private:
    /*------------------------------------------------------------------------------
    Purpose: extrait pgm gesclotu.p tbdoshon.i (procedure Facturation_Automatique)  
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection                 as collection no-undo.         
    define output parameter pdMtTotIfdhonoCpt            as decimal no-undo.
    define output parameter pdMtTotHonoIfdhono           as decimal no-undo.
    define output parameter pdpdMtTotHonoIfdhonoNonCpt   as decimal no-undo.
    define output parameter pdMtTotHonoAutoResteAFacture as decimal no-undo.
    
    define variable vcCdCp6700          as character no-undo initial "670000000".
    define variable vdMtTotCle          as decimal   no-undo.
    define variable vdMtTotTva          as decimal   no-undo.
    define variable viInb               as integer   no-undo.
    define variable vdMtEcart           as decimal   no-undo.
    define variable vdMtCle             as decimal   no-undo.
    define variable vhTva               as handle    no-undo.
    define variable viCdTvaUse          as integer   no-undo.
    define variable vdMtTotApp          as decimal   no-undo.
    define variable vcTotHono           as character no-undo. /** HwFilTot:SCREEN-VALUE de selhono.p **/
    define variable vcHonoTva           as character no-undo. /** HwFilTva:SCREEN-VALUE de selhono.p **/
    define variable vdMontantTVAFacture as decimal   no-undo.
    define variable vhProc              as handle    no-undo. 

    define buffer ifdhono for ifdhono.     
    define buffer ietab   for ietab.  
                     
    empty temp-table ttProrata.
    empty temp-table ttHonFact.
    empty temp-table ttHonFactNonCompt.
    empty temp-table ttHonFactCompt.
    empty temp-table ttHonRestAFact.
    empty temp-table tmp-ana.

    run compta/outilsTVA.p persistent set vhTva.
    run getTokenInstance in vhTva(mToken:JSessionId).

    /*-------------------------------------------------------------------------------------------------
    FACTURES HONORAIRES PAR LA CHAINE DES TRAVAUX IFDHONO
    -------------------------------------------------------------------------------------------------*/
    /*--> Chargement des factures d'honoraires automatiques **/
    for each ifdhono no-lock     
        where ifdhono.soc-cd      = giNoRefUse
          and ifdhono.etab-cd     = giNumeroMandat
          and ifdhono.affair-num  = giNumeroDossierTravaux
          and ifdhono.typefac-cle = "13":
        vdMontantTVAFacture = dynamic-function("calculTVAdepuisHT" in vhTva, ifdhono.taxe-cd, ifdhono.mt). 
        if ifdhono.fg-compta 
        then pdMtTotIfdhonoCpt          = pdMtTotIfdhonoCpt  + ifdhono.mt + vdMontantTVAFacture.                 // Honoraires automatiques déjà comptabilisés   
        else pdpdMtTotHonoIfdhonoNonCpt = pdpdMtTotHonoIfdhonoNonCpt + ifdhono.mt + vdMontantTVAFacture. // Honoraires automatiques facturés non-comptabilisés
        pdMtTotHonoIfdhono = pdMtTotHonoIfdhono + ifdhono.mt + vdMontantTVAFacture.                      // Tous les Honoraires automatiques facturés
    end.

    /*--> Chargement des factures d'honoraires et répartition par clé */
    /** Tous les Honoraires **/
    {&_proparse_ prolint-nowarn(sortaccess)}
    for each ifdhono no-lock     
        where ifdhono.soc-cd      = giNoRefUse
          and ifdhono.etab-cd     = giNumeroMandat
          and ifdhono.affair-num  = giNumeroDossierTravaux
          and ifdhono.typefac-cle = "13"
        break by ifdhono.ana4-cd:

        if first-of(ifdhono.ana4-cd) 
        then assign 
            vdMtTotCle = 0
            vdMtTotTva = 0
        .
        assign 
            vdMtTotCle = vdMtTotCle + ifdhono.mt
            vdMtTotTva = vdMtTotTva + dynamic-function("calculTVAdepuisHT" in vhTva, ifdhono.taxe-cd, ifdhono.mt)
        .
        if last-of(ifdhono.ana4-cd) 
        then do:
            create ttHonFact.
            assign 
                vdMtTotTva      = round(vdMtTotTva, 2)
                ttHonFact.CdCle = ifdhono.ana4-cd
                ttHonFact.mtCle = round(vdMtTotCle + vdMtTotTva, 2)
                ttHonFact.MtTva = vdMtTotTva
                viCdTvaUse      = ifdhono.taxe-cd
            .
        end.                        
    end.
    
    /** Honoraires facturés, mais non-comptabilisés **/
    {&_proparse_ prolint-nowarn(sortaccess)}
    for each ifdhono no-lock    
        where ifdhono.soc-cd      = giNoRefUse
          and ifdhono.etab-cd     = giNumeroMandat
          and ifdhono.affair-num  = giNumeroDossierTravaux
          and ifdhono.typefac-cle = "13"
          and not ifdhono.fg-compta
        break by ifdhono.ana4-cd:
        if first-of(ifdhono.ana4-cd) 
        then assign 
            vdMtTotCle = 0
            vdMtTotTva = 0
        .
        assign 
            vdMtTotCle = vdMtTotCle + ifdhono.mt
            vdMtTotTva = vdMtTotTva + dynamic-function("calculTVAdepuisHT" in vhTva, ifdhono.taxe-cd, ifdhono.mt)
        .
/*gga todo maj ici mais jamais utilise a verifier 
        if last-of(ifdhono.ana4-cd) 
        then do:
            create ttHonFactNonCompt.
            assign 
                ttHonFactNonCompt.CdCle = ifdhono.ana4-cd
                ttHonFactNonCompt.MtCle = vdMtTotCle + vdMtTotTva
                ttHonFactNonCompt.MtTva = vdMtTotTva           
                ttHonFactNonCompt.Mtht  = vdMtTotCle
                ttHonFactNonCompt.Mttva = vdMtTotTva
                ttHonFactNonCompt.rRwd  = string(rowid(ifdhono)).
        end.                        
gga*/ 
    end.
  
    /** Honoraires facturés et comptabilisés **/
    {&_proparse_ prolint-nowarn(sortaccess)}
    for each ifdhono no-lock     
        where ifdhono.soc-cd      = giNoRefUse
          and ifdhono.etab-cd     = giNumeroMandat
          and ifdhono.affair-num  = giNumeroDossierTravaux
          and ifdhono.typefac-cle = "13"
          and ifdhono.fg-compta
        break by ifdhono.ana4-cd:
        if first-of(ifdhono.ana4-cd) 
        then assign 
            vdMtTotCle = 0
            vdMtTotTva = 0
        .
        assign 
            vdMtTotCle = vdMtTotCle + ifdhono.mt
            vdMtTotTva = vdMtTotTva + dynamic-function("calculTVAdepuisHT" in vhTva, ifdhono.taxe-cd, ifdhono.mt)
        .
        if last-of(ifdhono.ana4-cd) 
        then do:
            vdMtTotTva = round(vdMtTotTva, 2).
/*gga todo maj ici mais jamais utilise a verifier 
            create ttHonFactCompt.
            assign 
                ttHonFactCompt.CdCle = ifdhono.ana4-cd
                ttHonFactCompt.MtCle = vdMtTotCle + vdMtTotTva
                ttHonFactCompt.MtTva = vdMtTotTva.
gga*/ 
        end.      
    end.

    vdMtTotApp = 0.
    for each ttHonFact:
        vdMtTotApp = vdMtTotApp + ttHonFact.MtCle.
    end.
    assign
        vcTotHono = string(vdMtTotApp, "->,>>>,>>9.99")
        vcHonoTva = string(dynamic-function("calculTTCdepuisHT" in vhTva, viCdTvaUse, vdMtTotApp), "->,>>>,>>9.99")
    .
    /*--> Creation de la table des proratas clé */
    for each ttHonFact:
        create ttProrata.
        assign 
            ttProrata.CdCle = ttHonFact.CdCle
            ttProrata.PoCle = ttHonFact.MtCle * 100 / vdMtTotApp
        .
    end.
    /*--> Si aucun prorata se baser sur les appels */
    find first ttProrata no-error.
    if not available ttProrata 
    then do:
        /*--> Montant total des appels */
        vdMtTotApp = 0.
        for each ttAppelDeFondRepCle:
            vdMtTotApp = vdMtTotApp + ttAppelDeFondRepCle.dMontantAppel.
        end.
        /*--> Cumul des repartitions par clé */
        for each ttAppelDeFondRepCle
            break by ttAppelDeFondRepCle.cCodeCle:
            
            if first-of(ttAppelDeFondRepCle.cCodeCle) then vdMtTotCle = 0.

            vdMtTotCle = vdMtTotCle + ttAppelDeFondRepCle.dMontantAppel.

            if last-of(ttAppelDeFondRepCle.cCodeCle) 
            then do:
                create ttProrata.
                assign
                    ttProrata.CdCle = ttAppelDeFondRepCle.cCodeCle
                    ttProrata.PoCle = vdMtTotCle * 100 / vdMtTotApp
                .
            end.
        end.
    end.

    /*--> Chargement des dépenses réelles */
    for first ietab no-lock  
        where ietab.soc-cd  = giNoRefUse
          and ietab.etab-cd = giNumeroMandat:  
        /*--> Chargement de la table des analytiques du dossier */ 
        poCollection:set('dtDatFin', ietab.dafinex2) no-error.
        poCollection:set('cCpt', vcCdCp6700) no-error.
        run compta/souspgm/extraihb.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run extraihbExtraitAnalytique in vhProc (poCollection, output table tmp-ana by-reference).
        run destroy in vhProc.                                 
    end.                                                  
    run CalHono(output vdMtTotApp).

    /*************************** Calcul du Reste A Facturer automatiquement entre les appels et les dépenses réelles ********************************/
    if vdMtTotApp > 0 
    then do:
        assign 
            vcHonoTva = string(dynamic-function("calculTVAdepuisHT" in vhTva, viCdTvaUse, vdMtTotApp), "->,>>>,>>9.99")
            vcTotHono = string(vdMtTotApp + decimal (vcHonoTva), "->,>>>,>>9.99")
        .
        
        empty temp-table ttProrata. // Suppression répartition
        /*--> Montant total des frais */
        vdMtTotApp = 0.
        for each tmp-ana:
            vdMtTotApp = vdMtTotApp + tmp-ana.mt.
        end.
        for each tmp-ana 
            break by tmp-ana.cle:
        
            if first-of(tmp-ana.cle) then vdMtTotCle = 0.

            vdMtTotCle = vdMtTotCle + tmp-ana.mt.

            if last-of(tmp-ana.cle) 
            then do:
                create ttProrata.
                assign 
                    ttProrata.CdCle = tmp-ana.cle
                    ttProrata.PoCle = vdMtTotCle * 100 / vdMtTotApp
                .
            end.
        end.                    
        empty temp-table ttHonRestAFact.
        for each ttProrata:
            vdMtCle = round(decimal(vcTotHono) * ttProrata.PoCle / 100, 2).
            find first ttHonFact 
                where ttHonFact.CdCle = ttProrata.CdCle no-error.
            if available ttHonFact then vdMtCle = vdMtCle - ttHonFact.MtCle.
            if round(vdMtCle, 2) <> 0 
            then do:
                create ttHonRestAFact.
                assign 
                    ttHonRestAFact.CdCle = ttProrata.CdCle
                    ttHonRestAFact.MtCle = round(vdMtCle, 2) 
                    ttHonRestAFact.FgAff = true
                .
            end.
        end. 
        vdMtTotApp = 0.
        for each ttHonRestAFact
            where ttHonRestAFact.FgAff:
            vdMtTotApp = vdMtTotApp + ttHonRestAFact.Mtcle.
            if ttHonRestAFact.Mtcle = 0 then delete ttHonRestAFact.
        end.
        for each ttHonFact:
            vdMtTotApp = vdMtTotApp + ttHonFact.Mtcle.
        end.
        vdMtEcart = decimal( vcTotHono) - vdMtTotApp.
        if vdMtEcart <> 0 
        then do:
            find last ttHonRestAFact no-error.
            if available ttHonRestAFact 
            then do :
                ttHonRestAFact.MtCle = ttHonRestAFact.MtCle + vdMtEcart.
                if ttHonRestAFact.mtcle = 0 then delete ttHonRestAFact.
            end.
        end.
        vdMtTotApp = 0.
        for each ttHonRestAFact:
            assign
                vdMtTotApp = vdMtTotApp + ttHonRestAFact.mtcle
                ttHonRestAFact.mttva = dynamic-function("calculTTCdepuisHT" in vhTva, viCdTvaUse, ttHonRestAFact.mtCle)
                ttHonRestAFact.mtht  = ttHonRestAFact.mtCle - ttHonRestAFact.mttva
            .
        end.

        /** Reste à facturer **/
        viInb = 0.
        for each ttHonRestAFact:
            viInb = viInb + 1.
        end.
        if viInb = 1 
        then do:
            if vdMtTotApp = 0 or absolute(vdMtTotApp) < 0.05 
            then do:                                   
                for each ttHonRestAFact:
                    delete ttHonRestAFact.
                end.                 
                vdMtTotApp = 0.
            end.
        end.
        pdMtTotHonoAutoResteAFacture = vdMtTotApp.
    end.
    run destroy in vhTva.

end procedure.

procedure CalHono private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define output parameter pdMtTotHon as decimal no-undo.

    define variable vdMtTotTtc as decimal   no-undo.
    define variable vdMtTotHht as decimal   no-undo.
    define variable vdMtBasUse as decimal   no-undo.

    define buffer trdos for trdos. 
    define buffer honor for honor. 
    define buffer trhon for trhon. 
           
    /*--> Calculer les frais réel */
    for each tmp-ana:
        assign 
            vdMtTotTtc = vdMtTotTtc + (if tmp-ana.sens then 1 else - 1) * tmp-ana.mt
            vdMtTotHht = vdMtTotHht + (if tmp-ana.sens then 1 else - 1) * (tmp-ana.mt - tmp-ana.mttva)
        .
    end.
    /*--> Enlever des frais réel les factures d'honoraires déjà comptabilisé */
    for each ttHonFact:
        assign 
            vdMtTotTtc = vdMtTotTtc - ttHonFact.MtCle
            vdMtTotHht = vdMtTotHht - (ttHonFact.mtCle - ttHonFact.mtTva)
        .
    end.

    for first trdos no-lock
        where trdos.tpcon = gcTypeMandat
          and trdos.nocon = giNumeroMandat
          and trdos.nodos = giNumeroDossierTravaux
      , first honor no-lock      
        where honor.nohon = integer(trdos.NoHon):
        case honor.bshon:
            when "15001" then vdMtBasUse = vdMtTotTtc.
            when "15004" then vdMtBasUSe = vdMtTotHht.
            otherwise         vdMtBasUse = vdMtTotHht.
        end case.
        /* todo : a supprimer ou trouver ou sert viCdTvaUse !!!
        define variable viCdTvaUse as integer   no-undo.
        case honor.cdtva:
            when "00202" then viCdTvaUse = 5.
            when "00204" then viCdTvaUse = 1.
            when "00205" then viCdTvaUse = 6.
            when "00207" then viCdTvaUse = 8.
            when "00209" then viCdTvaUse = 20.        /* SY 1013/0167 */
            when "00210" then viCdTvaUse = 10.        /* SY 1013/0167 */
            otherwise         viCdTvaUse = 0.
        end case.
        */
        for each trhon no-lock   
            where trhon.tphon = honor.tphon
              and trhon.nohon = honor.cdhon   
              and trhon.vlmin <= vdMtBasUse:
            case honor.nthon:
                when "14002" then pdMtTotHon = pdMtTotHon + trhon.mttrc.                                                            // Honoraire au forfait
                when "14004" then pdMtTotHon = pdMtTotHon + ((minimum(trhon.vlmax, vdMtBasUse) - trhon.vlmin) * trhon.mttrc) / 100. // Honoraire au taux
            end case.
        end.                        
    end.  
    pdMtTotHon = round(pdMtTotHon,2).  

end procedure.
 