/*------------------------------------------------------------------------
File        : imputationParticuliere.p
Purpose     : tache Imputation Particuliere (Mandat de G閞ance / Mandat de Syndic)
Author(s)   : RF  -  08/01/2018
Notes       : a partir de adb\src\tach\synmtimp.p
------------------------------------------------------------------------*/
using parametre.pclie.parametrageDefautMandat.
using parametre.syspg.syspg.
using parametre.syspg.parametrageTache.
using parametre.pclie.parametrageArchivageCle.
using parametre.pclie.parametrageChargeLocative.
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit 阾re positionn閑 juste apr鑣 using */

{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/famille2tiers.i}
{application/include/error.i}
{compta/include/tva.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{tache/include/imputationParticuliere.i}

define temp-table TbTmpRlv  no-undo
    field   cdExo   as  character
    field   Noexo   as  integer
    field   Dtint   as  integer
index Ix_TbTmpRlv01 is primary unique
DtInt
Cdexo descending
.

define variable viNumeroItem as integer no-undo.

define buffer arcClemi for clemi.

function dateToInteger    returns integer(pdaDate as date) forward.
function integerToDate    returns date(piDate  as integer) forward.
function FctCleArc        returns logical(piNumeroImmeuble as integer, piNumeroMandat as integer, pcTypeContrat as character, pcCle as character) forward.
function libellePeriode   returns character(piPeriodeCharge as integer, pdaDateDebut as date, pdaDateFin as date) forward.
function typeDeTache      returns character(pcTypeContrat as character) forward.
function periodeParDefaut returns integer (buffer entip for entip, pcTypeTache as character) forward.

procedure getListeImputationParticuliere:
    define input  parameter piNumeroMandat  as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piPeriodeCharge as integer   no-undo.
    define input  parameter pcTypePeriode   as character no-undo.

    define output parameter table for ttImputationParticuliere.

    define variable viNumeroReleve        as integer   no-undo.
    define variable vcTypeTache           as character no-undo.
    define variable vlLienPeriodeSuivante as logical   no-undo.

    define buffer lprtbbuf for lprtb.

    //case pcTypeContrat:
    //    when {&TYPECONTRAT-mandat2Gerance} then vcTypeTache = {&TYPETACHE-imputationParticuliereGerance}.
    //    when {&TYPECONTRAT-mandat2Syndic}  then vcTypeTache = {&TYPETACHE-imputationParticuliereSyndic}.
    //end case.
    
    vcTypeTache = typeDeTache(pcTypeContrat).
    
    for first intnt no-lock

        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble},

         each entip no-lock
        where entip.nocon = piNumeroMandat
          and entip.noimm = intnt.noidt:

        viNumeroReleve = DateToInteger(entip.dtimp).

        find  lprtb no-lock
        where lprtb.Tpcon = pcTypeContrat
          and lprtb.Nocon = piNumeroMandat
          and lprtb.TpCpt = vcTypeTache
          and lprtb.norlv = viNumeroReleve
        no-error.
        if not available lprtb
        then do transaction:
             // cr閍tion des liens manquants le cas 閏h閍nt

             create lprtb.
             assign
                lprtb.tpcon  = pcTypeContrat
                lprtb.nocon  = piNumeroMandat
                lprtb.noexe  = 99
                lprtb.noper  = 0
                lprtb.noimm  = intnt.noidt
                lprtb.tpcpt  = vcTypeTache
                lprtb.norlv  = viNumeroReleve
                lprtb.cdtrt  = "00001"

                lprtb.dtcsy  = today
                lprtb.hecsy  = time
                lprtb.cdcsy  = mToken:cUser
                .
        end.
    end.

    if pcTypePeriode = "ENCOU"
    then do:
        if piPeriodeCharge ne 0
        then do:
            find first lprtbbuf no-lock
                 where lprtbbuf.Tpcon = pcTypeContrat
                   and lprtbbuf.Nocon = piNumeroMandat
                   and lprtbBuf.NoExe > piPeriodeCharge
                   and lprtbbuf.TpCpt = vcTypeTache
                   and lprtbbuf.cdtrt <> "00000"
                   and lprtbbuf.cdtrt <> "00003"
            no-error .
            if available lprtbbuf
            then do:
                if lprtbbuf.Noexe <> 99
                then do:
                    vlLienPeriodeSuivante = yes.

                    for each lprtb
                       where lprtb.Tpcon = pcTypeContrat
                         and lprtb.Nocon = piNumeroMandat
                         and lprtb.noexe < lprtbbuf.noexe
                         and lprtb.TpCpt = vcTypeTache
                         and lprtb.cdtrt <> "00000"
                         and lprtb.cdtrt <> "00003"
                    no-lock:
                        find  entip no-lock
                        where entip.nocon = lprtb.Nocon
                          and entip.Noimm = lprtb.noimm
                          and entip.dtimp = integerToDate(lprtb.norlv)
                        no-error.

                        if available entip
                        then run chargeReleve(buffer entip,lprtb.noexe).
                    end.
                end.
                else do:
                    vlLienPeriodeSuivante = no.
                end.
            end.
        end.
        else do:
            vlLienPeriodeSuivante = no.
        end.

        if not vlLienPeriodeSuivante
        then do:
            for each lprtb
               where lprtb.Tpcon = pcTypeContrat
                 and lprtb.Nocon = piNumeroMandat
                 and lprtb.TpCpt = vcTypeTache
                 and lprtb.cdtrt <> "00000"
                 and lprtb.cdtrt <> "00003"
            no-lock:
                find  entip no-lock
                where entip.nocon = lprtb.Nocon
                  and entip.Noimm = lprtb.noimm
                  and entip.dtimp = integerToDate(lprtb.norlv)
                no-error.

                if available entip
                then run chargeReleve(buffer entip,lprtb.noexe).
            end.
        end.
    end.
    else do:
        if piPeriodeCharge ne 0
        then do:
            for each lprtb
               where lprtb.Tpcon = pcTypeContrat
                 and lprtb.Nocon = piNumeroMandat
                 and lprtb.Noexe = piPeriodeCharge
                 and lprtb.TpCpt = vcTypeTache
                 and lprtb.cdtrt = "00003"
            no-lock:
                find  entip no-lock
                where entip.nocon = lprtb.Nocon
                  and entip.Noimm = lprtb.noimm
                  and entip.dtimp = integerToDate(lprtb.norlv)
                no-error.

                if available entip
                then run chargeReleve(buffer entip,lprtb.noexe).
            end.
        end.
        else do:
            for each lprtb
               where lprtb.Tpcon = pcTypeContrat
                 and lprtb.Nocon = piNumeroMandat
                 and lprtb.TpCpt = vcTypeTache
                 and lprtb.cdtrt = "00003"
            no-lock:
                find  entip no-lock
                where entip.nocon = lprtb.Nocon
                  and entip.Noimm = lprtb.noimm
                  and entip.dtimp = integerToDate(lprtb.norlv)
                no-error.

                if available entip
                then run chargeReleve(buffer entip,lprtb.noexe).
            end.
        end.
    end.

end procedure.



procedure initImputationParticuliere:
    define input parameter piNumeroImmeuble  as integer   no-undo.
    define input parameter piNumeroMandat    as integer   no-undo.
    define input parameter pcTypeContrat     as character no-undo.

    define output parameter table for ttImputationParticuliere.
    define output parameter table for ttLocataire.
    define output parameter table for ttCombo.

    define variable voParametreArchivageCle as class parametrageArchivageCle no-undo.

    voParametreArchivageCle = new parametrageArchivageCle().


    create ttImputationParticuliere.
    assign
        ttImputationParticuliere.cTypeContrat         = pcTypeContrat
        ttImputationParticuliere.iNumeroMandat        = piNumeroMandat
        ttImputationParticuliere.iNumeroImmeuble      = piNumeroImmeuble
        ttImputationParticuliere.iNumeroPeriodeCharge = 0
        ttImputationParticuliere.cLibelleImputation   = ""
        ttImputationParticuliere.daDateImputation     = ?
        //ttImputationParticuliere.cCleRecuperation     =
        //ttImputationParticuliere.cCleImputation       =
        ttImputationParticuliere.cRubrique            = "170"
        ttImputationParticuliere.cSousRubrique        = "674"
        ttImputationParticuliere.cCodeFiscalite       = "2"
        ttImputationParticuliere.cLibellePeriode      = ""

        ttImputationParticuliere.dtTimestamp          = ?
        ttImputationParticuliere.CRUD                 = "R"
        .

    // cl閟 imputation
    for each clemi no-lock
       where clemi.noimm = piNumeroImmeuble
         and clemi.tpcle = "00007"   /* IP */
         and clemi.cdeta = "V"
    by clemi.cdcle :
        if voParametreArchivageCle:isOuvert() and voParametreArchivageCle:isArchivageActif()
        and FctCleArc(piNumeroImmeuble,piNumeroMandat,pcTypeContrat,clemi.cdcle)
        then next.

        ttImputationParticuliere.cCleRecuperation = clemi.cdcle.
        leave.

    end.

    // cl閟 r閏up閞ation
    for each clemi no-lock
       where clemi.noimm = piNumeroImmeuble
         and clemi.nbtot > 0    /* IP */
         and clemi.cdeta = "V"
    by clemi.cdcle :
        if voParametreArchivageCle:isArchivageActif()
        and FctCleArc(piNumeroImmeuble,piNumeroMandat,pcTypeContrat,clemi.cdcle)
        then next.

        ttImputationParticuliere.cCleImputation = clemi.cdcle.
        leave.
    end.

    run initComboVue(piNumeroImmeuble,piNumeroMandat,pcTypeContrat, output table ttLocataire, output table ttCombo).

end procedure.



procedure getImputationParticuliere:
    define input parameter piNumeroMandat    as integer no-undo.
    define input parameter piNumeroImmeuble  as integer no-undo.
    define input parameter pdaDateImputation as date    no-undo.

    define output parameter table for ttImputationParticuliere.
    define output parameter table for ttLigneImputationParticuliere.

    define variable viNumeroReleve as integer     no-undo.
    define variable vcTypeTache    as character   no-undo.


    for first entip no-lock
        where entip.nocon = piNumeroMandat
          and entip.noimm = piNumeroImmeuble
          and entip.dtimp = pdaDateImputation:

        //case entip.tpcon:
        //     when {&TYPECONTRAT-mandat2Gerance} then vcTypeTache = {&TYPETACHE-imputationParticuliereGerance}.
        //     when {&TYPECONTRAT-mandat2Syndic}  then vcTypeTache = {&TYPETACHE-imputationParticuliereSyndic}.
        //end case.
        
        vcTypeTache = typeDeTache(entip.tpcon).
        viNumeroReleve = DateToInteger(entip.dtimp).

        find  lprtb no-lock
        where lprtb.Tpcon = entip.tpcon
          and lprtb.Nocon = piNumeroMandat
          and lprtb.TpCpt = {&TYPETACHE-ImputParticuliereGerance}
          and lprtb.norlv = viNumeroReleve
        no-error.

        if not available lprtb
        then do transaction:
            // cr閍tion du lien manquants le cas 閏h閍nt
            // a eventuellement d閜lacer dans le case selon le type de contrat
            create lprtb.
            assign
               lprtb.tpcon  = entip.tpcon
               lprtb.nocon  = piNumeroMandat
               lprtb.noexe  = 99
               lprtb.noper  = 0
               lprtb.noimm  = intnt.noidt
               lprtb.tpcpt  = {&TYPETACHE-ImputParticuliereGerance}
               lprtb.norlv  = viNumeroReleve
               lprtb.cdtrt  = "00001"

               lprtb.dtcsy  = today
               lprtb.hecsy  = time
               lprtb.cdcsy  = mToken:cUser
               .
        end.

        run chargeReleve(buffer entip,lprtb.noexe).
        run chargeDetailReleve(buffer entip).

    end.

end procedure.

procedure setImputationParticuliere:
    
    define input parameter table for ttImputationParticuliere.
    define input parameter table for ttLigneImputationParticuliere.
    define input parameter table for ttError.

    define buffer entip for entip.
    define buffer detip for detip.

    for first ttImputationParticuliere
        where lookup(ttImputationParticuliere.CRUD, "C,U,D") > 0:
        
        // recherche de l'existant - pas de for first !! > la cr閍tion serait difficile!   
        find first entip no-lock
             where entip.nocon = ttImputationParticuliere.iNumeroMandat
               and entip.noimm = ttImputationParticuliere.iNumeroImmeuble
               and entip.dtimp = ttImputationParticuliere.daDateImputation
        no-error.

        run controlesAvantValidation (buffer entip, buffer ttImputationParticuliere, table ttLigneImputationParticuliere).
        if mError:erreur() = yes then return.

        run deleteImputationParticuliere.
        run updateImputationParticuliere.
        run createImputationParticuliere.
        
    end.

end procedure.

procedure deleteImputationParticuliere:
    define buffer entip for entip.
    define buffer detip for detip.

    define variable viNumeroReleve as integer     no-undo.
    define variable vcTypeTache    as character   no-undo.

    bloc:
    do transaction:
        for first ttImputationParticuliere where ttImputationParticuliere.CRUD = "D":
            find first entip exclusive-lock
                where entip.nocon = ttImputationParticuliere.iNumeroMandat
                  and entip.noimm = ttImputationParticuliere.iNumeroImmeuble
                  and entip.dtimp = ttImputationParticuliere.daDateImputation
            no-wait no-error.

            if  outils:isUpdated(buffer entip:handle, 'entip/imputation particuli鑢e: ', substitute('&1/&2/&3', ttImputationParticuliere.iNumeroMandat, ttImputationParticuliere.iNumeroImmeuble, string(ttImputationParticuliere.daDateImputation)),ttImputationParticuliere.dtTimestamp)                 
            then undo bloc, leave bloc.

            //case entip.tpcon:
            //    when {&TYPECONTRAT-mandat2Gerance} then vcTypeTache = {&TYPETACHE-imputationParticuliereGerance}.
            //    when {&TYPECONTRAT-mandat2Syndic}  then vcTypeTache = {&TYPETACHE-imputationParticuliereSyndic}.
            //end case.
            
            vcTypeTache = typeDeTache(entip.tpcon). 
            viNumeroReleve = DateToInteger(entip.dtimp).
            
            for each lprtb exclusive-lock
               where lprtb.Tpcon = entip.tpcon
                 and lprtb.Nocon = entip.nocon
                 and lprtb.TpCpt = vcTypeTache
                 and lprtb.norlv = viNumeroReleve:
            
                delete lprtb.
            end.
            
            for each detip exclusive-lock
               where detip.noimm = entip.noimm
                 and detip.nocon = entip.nocon
                 and detip.dtimp = entip.dtimp:
            
                delete detip.
            end.
            
            delete entip.

        end.
    end.

end procedure.

procedure updateImputationParticuliere:
   
    define buffer entip for entip.
    define buffer detip for detip.
    define buffer lprtb for lprtb.

    define variable viNumeroReleve     as integer   no-undo.
    define variable vcTypeTache        as character no-undo.
    define variable viIndice           as integer   no-undo.
    define variable viPeriodeParDefaut as integer   no-undo. 
    
    bloc:
    do transaction:    
     
        for first ttImputationParticuliere where ttImputationParticuliere.CRUD = "U":
            
            message "***************************************" ttImputationParticuliere.cLibelleImputation ttImputationParticuliere.iNumeroPeriodeCharge.
            
            find first entip exclusive-lock
                 where entip.nocon = ttImputationParticuliere.iNumeroMandat
                   and entip.noimm = ttImputationParticuliere.iNumeroImmeuble
                   and entip.dtimp = ttImputationParticuliere.daDateImputation
            no-wait no-error.
            
            if  outils:isUpdated(buffer entip:handle, 'entip/imputation particuli鑢e: ', substitute('&1/&2/&3', ttImputationParticuliere.iNumeroMandat, ttImputationParticuliere.iNumeroImmeuble, string(ttImputationParticuliere.daDateImputation)),ttImputationParticuliere.dtTimestamp)                 
            then undo bloc, leave bloc.
             
            assign
              //entip.nocon = ttImputationParticuliere.iNumeroMandat
              //entip.noimm = ttImputationParticuliere.iNumeroImmeuble
                entip.lbimp = ttImputationParticuliere.cLibelleImputation 
                entip.nocre = ttImputationParticuliere.cCleRecuperation
                entip.nocle = ttImputationParticuliere.cCleImputation
              //entip.dtimp = ttImputationParticuliere.daDateImputation
                entip.cdtva = ""
                entip.cdana = ttImputationParticuliere.cRubrique + ttImputationParticuliere.cSousRubrique + ttImputationParticuliere.cCodeFiscalite
              //entip.mtttc =
              //entip.mttva =
                entip.lbrec =  "񍦾" // � creuser ?
                entip.tpcon = ttImputationParticuliere.cTypeContrat
               
                entip.dtcsy = today           
                entip.hecsy = mtime           
                entip.cdcsy = mtoken:cUser          
                entip.dtmsy = today
                entip.hemsy = mtime 
                entip.cdmsy = mtoken:cUser          
                .
            
            for each detip exclusive-lock
               where detip.nocon = entip.nocon
                 and detip.noimm = entip.noimm
                 and detip.dtimp = entip.dtimp:
            
               delete detip.
                     
            end.          
                     
            for each ttLigneImputationParticuliere
               where ttLigneImputationParticuliere.iNumeroMandat      = ttImputationParticuliere.iNumeroMandat     
                 and ttLigneImputationParticuliere.iNumeroImmeuble    = ttImputationParticuliere.iNumeroImmeuble   
                 and ttLigneImputationParticuliere.daDateImputation   = ttImputationParticuliere.daDateImputation:
             
                create detip.
                assign
                    detip.nocon = entip.nocon  
                    detip.noimm = entip.noimm
                  
                    detip.dtimp = entip.dtimp
                    detip.cdana = entip.cdana
                    detip.mtttc = ttLigneImputationParticuliere.dMontantTTC 
                    detip.mttva = ttLigneImputationParticuliere.dMontantTVA
                    detip.nolot = 0 
                    detip.nocop = int(string(entip.nocon,"99999") + string(ttLigneImputationParticuliere.iNumeroLocataire,"99999"))
                    detip.nochr = ttLigneImputationParticuliere.iChronoLocataire 
                    detip.lbdiv = ttLigneImputationParticuliere.cCodeTVA
                                
                    detip.dtcsy = entip.dtcsy 
                    detip.hecsy = entip.hecsy
                    detip.cdcsy = entip.cdcsy
                    detip.dtmsy = entip.dtmsy
                    detip.hemsy = entip.hemsy
                    detip.cdmsy = entip.cdmsy
                    .
                do viIndice = 1 to 9:
                   
                   detip.lbcom = detip.lbcom + if  ttLigneImputationParticuliere.cLibelleImputation[viIndice] ne ""
                                               and ttLigneImputationParticuliere.cLibelleImputation[viIndice] ne ?
                                               then ttLigneImputationParticuliere.cLibelleImputation[viIndice] + chr(10) 
                                               else "".    
                end.  
                
                detip.lbcom = right-trim(detip.lbcom,chr(10)).
                
                assign
                entip.mtttc = entip.mtttc + detip.mtttc
                entip.mttva = entip.mttva + detip.mttva
                .
                      
            end.
            
            // V閞ification du lien avec p閞iode de charge
            assign
                vcTypeTache        = typeDeTache(entip.tpcon)
                viNumeroReleve     = dateToInteger(entip.dtimp)
                .
                
            find first lprtb exclusive-lock
                 where lprtb.tpcon = entip.tpcon
                   and lprtb.nocon = entip.nocon
                   and lprtb.noper = 0
                   and lprtb.noimm = entip.noimm
                   and lprtb.Tpcpt = vcTypeTache
                   and lprtb.norlv = viNumeroReleve
            no-error.
            
            if available lprtb and lprtb.noexe ne ttImputationParticuliere.iNumeroPeriodeCharge
            then lprtb.noexe = ttImputationParticuliere.iNumeroPeriodeCharge.          
             
        end.    
    end.
end procedure.    




procedure createImputationParticuliere:
    define buffer entip for entip.
    define buffer detip for detip.
    define buffer lprtb for lprtb.

    define variable viNumeroReleve     as integer   no-undo.
    define variable vcTypeTache        as character no-undo.
    define variable viIndice           as integer   no-undo.
    define variable viPeriodeParDefaut as integer   no-undo. 
    
    
    bloc:
    do transaction:     
        for first ttImputationParticuliere where ttImputationParticuliere.CRUD = "C":
            create entip.
            assign
                entip.nocon = ttImputationParticuliere.iNumeroMandat
                entip.noimm = ttImputationParticuliere.iNumeroImmeuble
                entip.lbimp = ttImputationParticuliere.cLibelleImputation 
                entip.nocre = ttImputationParticuliere.cCleRecuperation
                entip.nocle = ttImputationParticuliere.cCleImputation
                entip.dtimp = ttImputationParticuliere.daDateImputation
                entip.cdtva = ""
                entip.cdana = ttImputationParticuliere.cRubrique + ttImputationParticuliere.cSousRubrique + ttImputationParticuliere.cCodeFiscalite
              //entip.mtttc =
              //entip.mttva =
                entip.lbrec =  "񍦾" // � creuser ?
                entip.tpcon = ttImputationParticuliere.cTypeContrat
               
                entip.dtcsy = today           
                entip.hecsy = mtime           
                entip.cdcsy = mtoken:cUser          
                entip.dtmsy = today
                entip.hemsy = mtime 
                entip.cdmsy = mtoken:cUser          
                .
        
             
            for each ttLigneImputationParticuliere
               where ttLigneImputationParticuliere.iNumeroMandat      = ttImputationParticuliere.iNumeroMandat     
                 and ttLigneImputationParticuliere.iNumeroImmeuble    = ttImputationParticuliere.iNumeroImmeuble   
                 and ttLigneImputationParticuliere.daDateImputation   = ttImputationParticuliere.daDateImputation:
             
                create detip.
                assign
                    detip.nocon = entip.nocon  
                    detip.noimm = entip.noimm
                  
                    detip.dtimp = entip.dtimp
                    detip.cdana = entip.cdana
                    detip.mtttc = ttLigneImputationParticuliere.dMontantTTC 
                    detip.mttva = ttLigneImputationParticuliere.dMontantTVA
                    detip.nolot = 0 
                    detip.nocop = int(string(entip.nocon,"99999") + string(ttLigneImputationParticuliere.iNumeroLocataire,"99999"))
                    detip.nochr = ttLigneImputationParticuliere.iChronoLocataire 
                    detip.lbdiv = ttLigneImputationParticuliere.cCodeTVA
                                
                    detip.dtcsy = entip.dtcsy 
                    detip.hecsy = entip.hecsy
                    detip.cdcsy = entip.cdcsy
                    detip.dtmsy = entip.dtmsy
                    detip.hemsy = entip.hemsy
                    detip.cdmsy = entip.cdmsy
                    .
                do viIndice = 1 to 9:
                   
                   detip.lbcom = detip.lbcom + if  ttLigneImputationParticuliere.cLibelleImputation[viIndice] ne ""
                                               and ttLigneImputationParticuliere.cLibelleImputation[viIndice] ne ?
                                               then ttLigneImputationParticuliere.cLibelleImputation[viIndice] + chr(10) 
                                               else "".    
                end.  
                
                detip.lbcom = right-trim(detip.lbcom,chr(10)).
                
                assign
                entip.mtttc = entip.mtttc + detip.mtttc
                entip.mttva = entip.mttva + detip.mttva
                .
                      
            end. 
            
            // A quelle p閞iode par d閒aut rattacher l'imputation ?
            assign
                vcTypeTache        = typeDeTache(entip.tpcon)
                viNumeroReleve     = dateToInteger(entip.dtimp)
                viPeriodeParDefaut = periodeParDefaut(buffer entip, vcTypetache). 
            
            // Creation du lien
            // 1 - Destruction d'un 関entuel parasite
            for each lprtb exclusive-lock
               where lprtb.tpcon = entip.tpcon
                 and lprtb.nocon = entip.nocon
                 and lprtb.Tpcpt = vcTypeTache
                 and lprtb.norlv = viNumeroReleve:
                delete lprtb.
            end.
            
            create lprtb.
            assign
                lprtb.tpcon = entip.tpcon
                lprtb.nocon = entip.nocon
                lprtb.noexe = viPeriodeParDefaut
                lprtb.noper = 0
                lprtb.noimm = entip.noimm
                lprtb.tpcpt = vcTypeTache
                lprtb.norlv = viNumeroReleve
                lprtb.cdtrt = "00001"
        
                lprtb.dtcsy = entip.dtcsy
                lprtb.hecsy = entip.hecsy
                lprtb.cdcsy = entip.cdcsy
                lprtb.dtmsy = entip.dtmsy
                lprtb.hemsy = entip.hemsy
                lprtb.cdmsy = entip.cdmsy
                .                  
        end.    
    end.
end procedure.    

/*
procedure deleteImputationParticuliere:
    define input parameter piNumeroMandat    as integer no-undo.
    define input parameter piNumeroImmeuble  as integer no-undo.
    define input parameter pdaDateImputation as date    no-undo.

    define output parameter table for ttImputationParticuliere.
    define output parameter table for ttLigneImputationParticuliere.

    define variable viNumeroReleve as integer     no-undo.
    define variable vcTypeTache    as character   no-undo.

    //
    // Contr鬺es
    //

    for first entip exclusive-lock
        where entip.nocon = piNumeroMandat
          and entip.noimm = piNumeroImmeuble
          and entip.dtimp = pdaDateImputation
    transaction:

        case entip.tpcon:
             when {&TYPECONTRAT-mandat2Gerance} then vcTypeTache = {&TYPETACHE-imputationParticuliereGerance}.
             when {&TYPECONTRAT-mandat2Syndic}  then vcTypeTache = {&TYPETACHE-imputationParticuliereSyndic}.
        end case.

        viNumeroReleve = DateToInteger(entip.dtimp).

        for first lprtb exclusive-lock
            where lprtb.Tpcon = entip.tpcon
              and lprtb.Nocon = piNumeroMandat
              and lprtb.TpCpt = {&TYPETACHE-imputationParticuliereGerance}
              and lprtb.norlv = viNumeroReleve:

            delete lprtb.
        end.

        for each detip exclusive-lock
           where detip.noimm = entip.noimm
             and detip.nocon = entip.nocon
             and detip.dtimp = entip.dtimp:

            delete detip.
        end.

        delete entip.
    end.

end procedure.
*/

procedure chargeReleve:

    define parameter buffer entip for entip.
    define input parameter piPeriodeCharge   as integer no-undo.

    case entip.tpcon:
         when {&TYPECONTRAT-mandat2Gerance} then do:
             create ttImputationParticuliere.
             assign
                 ttImputationParticuliere.cTypeContrat         = entip.tpcon
                 ttImputationParticuliere.iNumeroMandat        = entip.nocon
                 ttImputationParticuliere.iNumeroImmeuble      = entip.noimm
                 ttImputationParticuliere.iNumeroPeriodeCharge = piPeriodeCharge
                 ttImputationParticuliere.cLibelleImputation   = entip.lbimp
                 ttImputationParticuliere.daDateImputation     = entip.dtimp
                 ttImputationParticuliere.cCleRecuperation     = entip.nocre
                 ttImputationParticuliere.cCleImputation       = entip.nocle
                 ttImputationParticuliere.cRubrique            = substring(entip.cdana,1,3)
                 ttImputationParticuliere.cSousRubrique        = substring(entip.cdana,4,3)
                 ttImputationParticuliere.cCodeFiscalite       = substring(entip.cdana,7,1)
                 ttImputationParticuliere.cLibellePeriode      = "" // initialis� � blanc si hors p閞iode

                 ttImputationParticuliere.dtTimestamp          = datetime(entip.dtmsy,entip.hemsy)
                 ttImputationParticuliere.CRUD                 = "R"
                 ttImputationParticuliere.rRowid               = rowid(entip)
                 .


             if piPeriodeCharge = 99
             then ttImputationParticuliere.cLibellePeriode = "99 - " + outilTraduction:getLibelle(102632).
             else
             for first perio no-lock
                 where perio.TpCtt = entip.tpcon
                   and perio.Nomdt = entip.nocon
                   and perio.Noexo = piPeriodeCharge:

                 ttImputationParticuliere.cLibellePeriode = libellePeriode(perio.noexo, perio.dtdeb, perio.dtfin).

             end.

         end.
         when {&TYPECONTRAT-mandat2Syndic}  then do:
             // TODO: mandat de syndic
         end.
    end case.

end procedure.


procedure chargeDetailReleve:
    define parameter buffer entip for entip.

    define variable viIndice as integer no-undo.
    define variable voSyspr as class syspr no-undo.

    if available entip then do:

        for each detip no-lock
           where detip.noimm = entip.noimm
             and detip.nocon = entip.nocon
             and detip.dtimp = entip.dtimp:

            case entip.tpcon:
                when {&TYPECONTRAT-mandat2Gerance} then do:
                    create ttLigneImputationParticuliere.
                    assign
                        ttLigneImputationParticuliere.iNumeroMandat       = detip.nocon
                        ttLigneImputationParticuliere.iNumeroImmeuble     = detip.noimm
                        ttLigneImputationParticuliere.daDateImputation    = detip.dtimp
                        ttLigneImputationParticuliere.iNumeroLocataire    = detip.nocop mod 100000
                        ttLigneImputationParticuliere.iChronoLocataire    = detip.nochr
                        ttLigneImputationParticuliere.dMontantTTC         = detip.mtttc
                        ttLigneImputationParticuliere.dMontantTVA         = detip.mttva
                        ttLigneImputationParticuliere.cCodeTVA            = detip.lbdiv
                        
                        ttLigneImputationParticuliere.dtTimestamp         = datetime(detip.dtmsy,detip.hemsy)
                        ttLigneImputationParticuliere.CRUD                = "R"                              
                        ttLigneImputationParticuliere.rRowid              = rowid(detip)                     
                        .

                    do viIndice = 1 to 9:
                        if num-entries(detip.LbCom,chr(10)) >= viIndice
                        then ttLigneImputationParticuliere.cLibelleImputation[viIndice] = entry(viIndice,detip.LbCom,chr(10)).
                    end.

                    //TODO

                    for first roles no-lock
                        where roles.tprol = {&TYPEROLE-locataire}
                          and roles.norol = detip.nocop,
                        first tiers no-lock
                        where tiers.notie = roles.notie,
                        first ctrat no-lock
                        where ctrat.tpcon = {&TYPECONTRAT-bail}
                          and ctrat.norol = roles.norol:

                        ttLigneImputationParticuliere.cNomLocataire = (if tiers.cdfat = {&FAMILLETIERS-personneMorale}
                                                                       or tiers.cdfat = {&FAMILLETIERS-personneCivile}
                                                                       then trim(tiers.lnom1 + tiers.lpre1)
                                                                       else trim(tiers.lnom1) + " " + trim(tiers.lpre1))
                        .

                        if ctrat.ntcon = {&NATURECONTRAT-specialVacant} then ttLocataire.cNomLocataire = ttLocataire.cNomLocataire  + " (sp閏ial vacant propri閠aire)".

                    end.

                    voSyspr = new syspr("CDTVA",detip.lbdiv).
                    ttLigneImputationParticuliere.dTauxTVA = if voSyspr:isDbParameter then voSyspr:zone1 else 0.

                end.

                when {&TYPECONTRAT-mandat2Syndic} then do:

                end.

            end case.
        end.
    end.

end procedure.


procedure initReleve:
    define input  parameter piNumeroMandat  as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piPeriodeCharge as integer   no-undo.
    define input  parameter pcTypePeriode   as character no-undo.

    define variable viNumeroReleve        as integer   no-undo.
    define variable vcTypeTache           as character no-undo.
    define variable vlLienPeriodeSuivante as logical   no-undo.

    define buffer lprtbbuf for lprtb.

    empty temp-table TbTmpRlv.

    //case pcTypeContrat:
    //    when {&TYPECONTRAT-mandat2Gerance} then vcTypeTache = {&TYPETACHE-imputationParticuliereGerance}.
    //    when {&TYPECONTRAT-mandat2Syndic}  then vcTypeTache = {&TYPETACHE-imputationParticuliereSyndic}.
    //end case.
    vcTypeTache = typeDeTache(pcTypeContrat).

    if pcTypePeriode = "ENCOU"
    then do:
        if piPeriodeCharge ne 0
        then do:
            find first lprtbbuf no-lock
                 where lprtbbuf.Tpcon = pcTypeContrat
                   and lprtbbuf.Nocon = piNumeroMandat
                   and lprtbBuf.NoExe > piPeriodeCharge
                   and lprtbbuf.TpCpt = vcTypeTache
                   and lprtbbuf.cdtrt <> "00000"
                   and lprtbbuf.cdtrt <> "00003"
            no-error .
            if available lprtbbuf
            then do:
                if lprtbbuf.Noexe <> 99
                then do:
                    vlLienPeriodeSuivante = yes.

                    for each lprtb
                       where lprtb.Tpcon = pcTypeContrat
                         and lprtb.Nocon = piNumeroMandat
                         and lprtb.noexe < lprtbbuf.noexe
                         and lprtb.TpCpt = vcTypeTache
                         and lprtb.cdtrt <> "00000"
                         and lprtb.cdtrt <> "00003"
                    no-lock:
                        find  entip no-lock
                        where entip.nocon = lprtb.Nocon
                          and entip.Noimm = lprtb.noimm
                          and entip.dtimp = integerToDate(lprtb.norlv)
                        no-error.

                        if available entip
                        then do:
                             create TbTmpRlv.
                             assign
                                 TbTmpRlv.cdExo = string(lprtb.noexe,"99")
                                 TbTmpRlv.Noexo = Lprtb.noexe
                                 TbTmpRlv.Dtint = Lprtb.norlv
                                 .
                        end.
                    end.
                end.
                else do:
                    vlLienPeriodeSuivante = no.
                end.
            end.
        end.
        else do:
            vlLienPeriodeSuivante = no.
        end.

        if not vlLienPeriodeSuivante
        then do:
            for each lprtb
               where lprtb.Tpcon = pcTypeContrat
                 and lprtb.Nocon = piNumeroMandat
                 and lprtb.TpCpt = vcTypeTache
                 and lprtb.cdtrt <> "00000"
                 and lprtb.cdtrt <> "00003"
            no-lock:
                find  entip no-lock
                where entip.nocon = lprtb.Nocon
                  and entip.Noimm = lprtb.noimm
                  and entip.dtimp = integerToDate(lprtb.norlv)
                no-error.

                if available entip
                then do:
                     create TbTmpRlv.
                     assign
                         TbTmpRlv.cdExo = string(lprtb.noexe,"99")
                         TbTmpRlv.Noexo = Lprtb.noexe
                         TbTmpRlv.Dtint = Lprtb.norlv
                         .
                end.
            end.
        end.
    end.
    else do:
        if piPeriodeCharge ne 0
        then do:
            for each lprtb
               where lprtb.Tpcon = pcTypeContrat
                 and lprtb.Nocon = piNumeroMandat
                 and lprtb.Noexe = piPeriodeCharge
                 and lprtb.TpCpt = vcTypeTache
                 and lprtb.cdtrt = "00003"
            no-lock:
                find  entip no-lock
                where entip.nocon = lprtb.Nocon
                  and entip.Noimm = lprtb.noimm
                  and entip.dtimp = integerToDate(lprtb.norlv)
                no-error.

                if available entip
                then do:
                     create TbTmpRlv.
                     assign
                         TbTmpRlv.cdExo = string(lprtb.noexe,"99")
                         TbTmpRlv.Noexo = Lprtb.noexe
                         TbTmpRlv.Dtint = Lprtb.norlv
                         .
                end.
            end.
        end.
        else do:
            for each lprtb
               where lprtb.Tpcon = pcTypeContrat
                 and lprtb.Nocon = piNumeroMandat
                 and lprtb.TpCpt = vcTypeTache
                 and lprtb.cdtrt = "00003"
            no-lock:
                find  entip no-lock
                where entip.nocon = lprtb.Nocon
                  and entip.Noimm = lprtb.noimm
                  and entip.dtimp = integerToDate(lprtb.norlv)
                no-error.

                if available entip
                then do:
                     create TbTmpRlv.
                     assign
                         TbTmpRlv.cdExo = string(lprtb.noexe,"99")
                         TbTmpRlv.Noexo = Lprtb.noexe
                         TbTmpRlv.Dtint = Lprtb.norlv
                         .
                end.
            end.
        end.
    end.
end.


procedure initComboPer:
    // Contenu dynamique, d閜endant de l'enregistrement en cours

    define input parameter piNumeroMandat    as int64     no-undo.
    define input parameter pcTypeContrat     as character no-undo.
    define input parameter piPeriodeCharge   as integer   no-undo.
    define input parameter pcTypePeriode     as character no-undo.
    define input parameter pdaDateImputation as date      no-undo.

    define output parameter table for ttcombo.

    define variable NoExoMin as integer no-undo.
    define variable NoExoMax as integer no-undo.
    define variable NbEntCmb as integer no-undo.

    def var LsCmbPer as char.
    def var LsCodRlv as char.
    def var FgSuiDes as log.
    def var NoRlvUse as int.

    def var FgLieSui as log.
    def var lbMesZon as char.

    // Chargement Liste Releve

    run initReleve(piNumeroMandat, pcTypeContrat, piPeriodeCharge, pcTypePeriode).

    //for each TbTmpRlv: message TbTmpRlv.cdExo TbTmpRlv.Noexo TbTmpRlv.Dtint. end.

    // Chargement Combo

    assign
        LsCmbPer = ""
        LsCodRlv = ""
        FgSuiDes = false
        NoExoMin = 0
        NoExoMax = 0
        NoRlvUse = dateToInteger(pdaDateImputation).


    find  TbTmpRlv
    where TbTmpRlv.Dtint = NoRlvUse
    no-error.

    if available TbTmpRlv
    then do:
        find prev TbTmpRlv no-error.
        if not available TbTmpRlv
        then NoExoMin = 0.
        else do:
            if  piPeriodeCharge <> 0
            then do:
                // Ligne pr閏閐ente non rattach閑 => rattachement 99 obligatoire */
                if TbTmpRlv.NoExo = 99
                then NoExoMin = 99 .
                else
                // Ligne pr閏閐ente rattach閑 � l'exercice courant => rattachement Exo -> 99
                if TbTmpRlv.noexo = piPeriodeCharge
                then NoExoMin  = tbTmpRlv.NoExo.
                // Ligne pr閏閐ente rattach閑 � un exercice ant閞ieur => rattachement Exo -> 99
                else NoExoMin = piPeriodeCharge.
            end.
            else NoExoMin  = tbTmpRlv.NoExo.
        end.
    end. /* Fin available enregistrement courant */

    find  TbTmpRlv
    where TbTmpRlv.DtInt = NoRlvUse
    no-error.

    if available TbTmpRlv
    then do:
        find next TbTmpRlv no-error.
        if not available TbTmpRlv
        then do:
            NoExoMax = 99 .
            if FgLieSui = false
            then FgSuides = true.
        end.
        else do:
            if Noexo = 99
            then FgSuides = true.
            else FgSuides = false.

            NoExoMax  = tbTmpRlv.NoExo.
        end.
    end.

    if piPeriodeCharge = 0
    then do:
        for each perio no-lock
           where perio.TpCtt = pcTypeContrat
            and perio.Nomdt  = piNumeroMandat
            and perio.Noper  = 0
        use-index ix_perio02:


            // ne pas prendre les p閞iodes 'Historique' ni les p閞iodes trait閑s
            if perio.cdtrt = "00000" or perio.cdtrt = "00003"
            then next.

            // Ne prendre que les exercices concern閟

            if Perio.NoExo < NoExoMin or Perio.NoExo > NoExoMax
            then next.

            if Perio.Noexo = NoExoMin
            then do:
                 run chargeComboPeriode(buffer perio).
                 next.
            end.

            if Perio.Noexo = NoExoMax
            then do:
                run chargeComboPeriode(buffer perio).
                next.
            end.

            if Perio.Noexo <> NoExoMin and Perio.noexo <> NoExoMax
            then do:
                run chargeComboPeriode(buffer perio).
            end.
        end.
    end.
    else do:
        for each perio no-lock
           where perio.TpCtt = pcTypeContrat
             and perio.Nomdt = piNumeroMandat
             and perio.Noexo = piPeriodeCharge
             and perio.Noper = 0
        use-index Ix_Perio02:

            // ne pas prendre les p閞iodes 'Historique' ni les p閞iodes trait閑s
            if perio.cdtrt = "00000" or perio.cdtrt = "00003"
            then next.

            run chargeComboPeriode(buffer perio).
        end.
    end.

    if FgLieSui = false  and fgSuiDes
    then do:
        create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBPERIODE"
            ttCombo.cCode            = "99"
            ttCombo.cLibelle         = "99 - " + outilTraduction:getLibelle(102632)
            .
    end.

end procedure.



procedure chargeComboPeriode:
    define parameter buffer perio for perio.

    create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBPERIODE"
            ttCombo.cCode            = string(perio.noexo,"99")
            ttCombo.cLibelle         = libellePeriode(perio.noexo, perio.dtdeb, perio.dtfin).
            .

end procedure.


procedure initComboVue:
    define input parameter piNumeroImmeuble  as integer   no-undo.
    define input parameter piNumeroMandat    as integer   no-undo.
    define input parameter pcTypeContrat     as character no-undo.

    define output parameter table for ttLocataire.
    define output parameter table for ttCombo.

    define variable vhProcTVA    as handle  no-undo.
    define variable voParametreArchivageCle as class parametrageArchivageCle no-undo.

    voParametreArchivageCle = new parametrageArchivageCle().

    // cl閟 imputation
    for each clemi no-lock
       where clemi.noimm = piNumeroImmeuble
         and clemi.tpcle = "00007"   /* IP */
         and clemi.cdeta = "V"
    by clemi.cdcle :
        if voParametreArchivageCle:isOuvert() and voParametreArchivageCle:isArchivageActif()
        and FctCleArc(piNumeroImmeuble,piNumeroMandat,pcTypeContrat,clemi.cdcle)
        then next.

        create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBCLEIMPUTATION"
            ttCombo.cCode            = clemi.cdcle
            ttCombo.cLibelle         = clemi.cdcle + " - " + clemi.lbcle
            .
    end.

    // cl閟 r閏up閞ation
    for each clemi no-lock
       where clemi.noimm = piNumeroImmeuble
         and clemi.nbtot > 0    /* IP */
         and clemi.cdeta = "V"
    by clemi.cdcle :
        if voParametreArchivageCle:isArchivageActif()
        and FctCleArc(piNumeroImmeuble,piNumeroMandat,pcTypeContrat,clemi.cdcle)
        then next.

        create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBCLERECUPERATION"
            ttCombo.cCode            = clemi.cdcle
            ttCombo.cLibelle         = clemi.cdcle + " - " + clemi.lbcle
            .
    end.

    // Taux de TVA
    run compta/outilsTVA.p persistent set vhProcTVA.
    run getTokenInstance in vhProcTVA(mToken:JSessionId).
    run getCodeTVA in vhProcTVA(output table ttTVA).

    for each ttTva by ttTva.iCodeTva :
        create ttCombo.
        assign
            viNumeroItem             = viNumeroItem + 1
            ttCombo.iSeqId           = viNumeroItem
            ttCombo.cNomCombo        = "CMBTVA"
            ttCombo.cCode            = ttTVA.cCodeTVA
            ttCombo.cLibelle         = ttTVA.cLibelleTVA
            .
    end.

    run destroy in vhProcTVA.

    // Liste des locataires + sp閏ifique charges locative

    run chargeListeLocataire(piNumeroMandat, output table ttLocataire).

end procedure.


procedure chargeListeLocataire:
    define input parameter piNumeroMandat as integer   no-undo.
    define output parameter table for ttLocataire.

    define variable iNumeroLocMin as int64  no-undo.
    define variable iNumeroLocMax as int64  no-undo.

    define variable voparametrageChargeLocative as class parametrageChargeLocative no-undo.

    voparametrageChargeLocative = new parametrageChargeLocative().
    assign
        iNumeroLocMin = integer( string(piNumeroMandat , "99999") + "001" + "00" )
        iNumeroLocMax = integer( string(piNumeroMandat , "99999") + "995" + "99" )
        .

    for each roles no-lock
       where roles.tprol = {&TYPEROLE-locataire}
         and roles.norol  >= iNumeroLocMin and roles.norol <= iNumeroLocMax,
        each tiers no-lock
       where tiers.notie = roles.notie,
       first ctrat no-lock
       where ctrat.tpcon = {&TYPECONTRAT-bail}
         and ctrat.norol = roles.norol:


        if ctrat.ntcon = {&NATURECONTRAT-specialVacant} and not voparametrageChargeLocative:IsChargeLocativeSurULVacante() then next.

        create ttLocataire.
        assign
            ttLocataire.iNumeroBail      = roles.norol
            ttLocataire.iNumeroLocataire = roles.norol mod 100000
            ttLocataire.cNomLocataire    = (if tiers.cdfat = {&FAMILLETIERS-personneMorale}
                                            or tiers.cdfat = {&FAMILLETIERS-personneCivile}
                                            then trim(tiers.lnom1 + tiers.lpre1)
                                            else trim(tiers.lnom1) + " " + trim(tiers.lpre1))
            .

        if ctrat.ntcon = {&NATURECONTRAT-specialVacant} then ttLocataire.cNomLocataire = ttLocataire.cNomLocataire  + " (sp閏ial vacant propri閠aire)".

    end.
end procedure.

procedure controlesAvantValidation:
    define parameter buffer entip for entip.
    define parameter buffer ttImputationParticuliere for ttImputationParticuliere.
    define input parameter table for ttLigneImputationParticuliere.
     
    if lookup(ttImputationParticuliere.CRUD, "U,D") > 0 and not available entip
    then do:
        mError:createError({&error}, "modification/supression d'une imputation inexistante").
        return.  
    end.         
     
end procedure.    


function dateToInteger return integer (pdaDate as date):
    /*------------------------------------------------------------------------------
    Purpose: transforme une date en un entier aaaammjj
    ------------------------------------------------------------------------------*/
    if pdaDate = ?
    then return 0.
    else return year(pdaDate) * 10000 + month(pdaDate) * 100 + day(pdaDate).

end function.


function integerToDate return date (piDate as integer):
    /*------------------------------------------------------------------------------
    Purpose: transforme un entier format aaaammjj en date
    ------------------------------------------------------------------------------*/
    define variable daDateOut as date no-undo.

    daDateOut = date(int(trunc((piDate mod 10000) / 100,0)), int(piDate mod 100), int(trunc(piDate / 10000,0))) no-error.
    if error-status:error
    then return ?.
    else return daDateOut.

end function.


function FctCleArc returns logical (piNumeroImmeuble as integer, piNumeroMandat as integer, pcTypeContrat as character, pcCle as character):

        // L'immeuble est renseign�, on l'utilise en priorit� sur le mandat
        if piNumeroImmeuble <> 0
        then do:
            find first arcClemi no-lock
                 where arcClemi.noimm = piNumeroImmeuble
                   and arcClemi.cdcle = pcCle
            no-error.
        end.
        // Sinon on utilise le mandat si rensign�
        else if piNumeroMandat <> 0
        then do:
            find first arcClemi no-lock
                 where arcClemi.tpcon = pcTypeContrat
                   and arcClemi.nocon = piNumeroMandat
                   and arcClemi.cdcle = pcCle
            no-error.
        end.
        // Sinon on ne fait rien
        else do:
            return (?).
        end.

        // retour de la valeur
        if not available(arcClemi) then return (?).      // Cl� nconnue
        if arcClemi.cdarc = "00000" or arcClemi.cdarc = ? then return (false).
        if arcClemi.cdarc = "00099" then return (true).

end function.


function libellePeriode returns character (piPeriodeCharge as integer, pdaDateDebut as date, pdaDateFin as date):

    return string(piPeriodeCharge,"99")
         + " - "
         + outilTraduction:getLibelle(100780)
         + " "
         + outilFormatage:getDateFormat(pdaDateDebut,"C")
         + " "
         + outilTraduction:getLibelle(100132)
         + " "
         + outilFormatage:getDateFormat(pdaDateFin,"C").
end function.


function typeDeTache returns character(pcTypeContrat as character):
    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} then return {&TYPETACHE-imputParticuliereGerance}.
        when {&TYPECONTRAT-mandat2Syndic}  then return {&TYPETACHE-imputParticuliereSyndic}.
        otherwise return "".
    end case.
end function.    

function periodeParDefaut returns integer (buffer entip for entip, pcTypeTache as character):
    define variable viPeriodeParDefaut as integer   no-undo init 99.
    
    find first perio no-lock
         where perio.tpctt = entip.tpcon
           and perio.nomdt = entip.nocon
           and perio.noper = 0
           and perio.cdtrt <> "00000" 
           and perio.cdtrt <> "00003"
    no-error.
    
    if available perio then viPeriodeParDefaut = perio.noexo.

    find last lprtb no-lock
        where lprtb.tpcon = entip.tpcon
          and Lprtb.nocon = entip.nocon
          and lprtb.tpcpt = pcTypeTache
          and lprtb.noexe <> 99
          and lprtb.noper = 0
    no-error.

    if available lprtb 
    then do:
        find  perio no-lock
        where perio.tpctt = lprtb.tpcon
          and perio.Nomdt = lprtb.nocon
          and perio.noexo = lprtb.noexe
          and perio.noper = lprtb.noper
        no-error.

        if available perio and perio.cdtrt <> "00000" and perio.cdtrt <> "00003" then viPeriodeParDefaut = perio.noexo.
    
    end. 
    
    return viPeriodeParDefaut.
   
  
end function.    
    