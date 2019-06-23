/*------------------------------------------------------------------------
File        : soldmdt1.i
Purpose     : Changement de nature de contrat - Liste des comptes locataires à transférer 
Author(s)   : GGA - 18/01/19
Notes       : reprise cadb/gestion/SoldMdt1.p
derniere revue: 2018/07/29 - phm: KO
        traiter les todo

01  01/07/2002  JR    Fiche 0602/1364.
02  25/07/2002  LG    0702/0956
03  06/02/2003  DM    0203/0069  Lenteur
04  27/05/2003  DM    0503/0221  Pb test date resil
05  19/09/2008  DM    0608/0065: Mandat 5 chiffres
------------------------------------------------------------------------*/
procedure soldmdt1Controle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service interne/externe.
             pdaOD = ? si pas OD, pdaArchivage = ? si non archivé.
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSociete        as integer   no-undo.
    define input  parameter piNumeroMandatSource as integer   no-undo.
    define output parameter pdaOD                as date      no-undo.
    define output parameter pdaArchivage         as date      no-undo.

    define variable viCodeEtablissement as integer          no-undo.
    define variable vdSolde             as decimal          no-undo.
    define variable viCodePeriode       as integer          no-undo.
    define variable voCollection        as class collection no-undo.

    define buffer ietab   for ietab.
    define buffer cecrln  for cecrln.
    define buffer csscpt  for csscpt.
    define buffer ccptmvt for ccptmvt.
    define buffer aparm   for aparm.
    define buffer iprd    for iprd.
    define buffer ccptcol for ccptcol.

    if not can-find(first isoc no-lock where isoc.soc-cd = piCodeSociete) 
    then return.
    find first ietab no-lock
        where ietab.soc-cd  = piCodeSociete
          and ietab.etab-cd = piNumeroMandatSource no-error.
    if not available ietab
    then return.
    viCodeEtablissement = ietab.etab-cd.
    /* Recherche des DATES d'OD et d'archivage du mandat */
    if ietab.profil-cd = 21 then do:          /* gerance */ 
        if can-find(first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and ctrat.nocon = piNumeroMandatSource
                      and ctrat.dtree = ?) then return.

        if viCodeEtablissement <= 9999
        then find first cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = "M"
              and cecrln.cpt-cd     = "00000"
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")    // 4 positions
              and cecrln.type-cle   = "ODFM" no-error.
        if not available cecrln 
        then find first cecrln no-lock 
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = "M"
              and cecrln.cpt-cd     = "00000"
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")   // 5 positions
              and cecrln.type-cle   = "ODFM" no-error.
        if not available cecrln then return.

        assign
            pdaOD        = cecrln.dacompta
            pdaArchivage = 01/01/1901
        .
        for each csscpt no-lock
           where csscpt.soc-cd     = piCodeSociete
             and csscpt.etab-cd    = viCodeEtablissement
             and csscpt.sscoll-cle = "P":
            {&_proparse_ prolint-nowarn(sortaccess)}
            if viCodeEtablissement <= 9999 
            then for each cecrln no-lock
                where cecrln.soc-cd     = piCodeSociete
                  and cecrln.etab-cd    = viCodeEtablissement 
                  and cecrln.sscoll-cle = csscpt.sscoll-cle
                  and cecrln.cpt-cd     = csscpt.cpt-cd
                  and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")    // 4 positions
                  and cecrln.type-cle   = "ODFM"
                by cecrln.dalettrage descending:
                pdaArchivage = maximum(cecrln.dalettrage, pdaArchivage).
                leave.
            end.
            {&_proparse_ prolint-nowarn(sortaccess)}
            for each cecrln no-lock
                where cecrln.soc-cd     = piCodeSociete
                  and cecrln.etab-cd    = viCodeEtablissement 
                  and cecrln.sscoll-cle = csscpt.sscoll-cle
                  and cecrln.cpt-cd     = csscpt.cpt-cd
                  and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")   // 5 positions
                  and cecrln.type-cle   = "ODFM" 
                  and cecrln.flag-let   = true
                by cecrln.dalettrage descending:
                pdaArchivage = maximum(cecrln.dalettrage, pdaArchivage).
                leave.
            end.
            vdSolde = 0.
            for each ccptmvt no-lock
               where ccptmvt.soc-cd     = piCodeSociete
                 and ccptmvt.etab-cd    = viCodeEtablissement
                 and ccptmvt.sscoll-cle = csscpt.sscoll-cle
                 and ccptmvt.cpt-cd     = csscpt.cpt-cd
                 and (ccptmvt.prd-cd = ietab.prd-cd-1 or ccptmvt.prd-cd = ietab.prd-cd-2):
                vdSolde = vdSolde + ccptmvt.mtdeb + ccptmvt.mtdebp - ccptmvt.mtcre - ccptmvt.mtcrep.
            end.
            if vdSolde <> 0 then do:
                pdaArchivage = ?.
                return.
            end.
        end.
        /* cas ou tous les comptes propriétaires sont soldés sans ODFM */
        if pdaArchivage = 01/01/1901 then pdaArchivage = pdaOD.
    end.
    else if ietab.profil-cd = 91 then do:                       /* copro */
        if can-find(first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and ctrat.nocon = piNumeroMandatSource
                      and ctrat.dtree = ?) then return.

        find first aparm no-lock
            where aparm.tppar = "RESOD"
              and aparm.cdpar = "CPT" no-error.
        {&_proparse_ prolint-nowarn(release)}
        release cecrln.
        if viCodeEtablissement <= 9999
        then find last cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = aparm.zone2
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")    // 4 positions
              and cecrln.type-cle   = "ODFM" no-error.
        if not available cecrln
        then find last cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = aparm.zone2
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")   // 5 positions
              and cecrln.type-cle   = "ODFM" no-error.
        if not available cecrln  then do:
            viCodePeriode = ?.
BCL:
            repeat:
                {&_proparse_ prolint-nowarn(use-index)}
                if viCodePeriode = ?
                then find last iprd no-lock
                    where iprd.soc-cd  = piCodeSociete
                      and iprd.etab-cd = viCodeEtablissement
                    use-index prd-i no-error.
                else find prev iprd no-lock 
                    where iprd.soc-cd = piCodeSociete
                      and iprd.etab-cd = viCodeEtablissement
                      and iprd.prd-cd < viCodePeriode
                    use-index prd-i no-error.
                if not available iprd then leave BCL.
                viCodePeriode = iprd.prd-cd.
                {&_proparse_ prolint-nowarn(release)}
                release cecrln.
                if viCodeEtablissement <= 9999
                then find first cecrln no-lock 
                    where cecrln.soc-cd   = piCodeSociete
                      and cecrln.etab-cd  = viCodeEtablissement 
                      and cecrln.coll-cle = ""
                      and cecrln.prd-cd   = viCodePeriode
                      and cecrln.ref-num  = "SFM" + string(viCodeEtablissement, "9999")    // 4 positions
                      and cecrln.type-cle = "ODFM" no-error.
                if not available cecrln
                then find first cecrln no-lock  
                    where cecrln.soc-cd   = piCodeSociete
                      and cecrln.etab-cd  = viCodeEtablissement 
                      and cecrln.coll-cle = ""
                      and cecrln.prd-cd   = viCodePeriode
                      and cecrln.ref-num  = "SFM" + string(viCodeEtablissement, "99999")   // 5 positions
                      and cecrln.type-cle = "ODFM" no-error.
                if available cecrln then leave BCL.

                for each ccptcol no-lock
                    where ccptcol.Soc-cd = piCodeSociete:
                    {&_proparse_ prolint-nowarn(release)}
                    release cecrln.
                    if viCodeEtablissement <= 9999
                    then find first cecrln no-lock 
                        where cecrln.soc-cd   = piCodeSociete
                          and cecrln.etab-cd  = viCodeEtablissement 
                          and cecrln.coll-cle = ccptcol.coll-cle
                          and cecrln.prd-cd   = viCodePeriode
                          and cecrln.ref-num  = "SFM" + string(viCodeEtablissement, "9999")    // 4 positions
                          and cecrln.type-cle = "ODFM" no-error.
                    if not available cecrln 
                    then find first cecrln no-lock  
                        where cecrln.soc-cd   = piCodeSociete
                          and cecrln.etab-cd  = viCodeEtablissement 
                          and cecrln.coll-cle = ccptcol.coll-cle
                          and cecrln.prd-cd   = viCodePeriode
                          and cecrln.ref-num  = "SFM" + string(viCodeEtablissement, "99999")   // 5 positions
                          and cecrln.type-cle = "ODFM" no-error.
                    if available cecrln then leave BCL.
                end.
            end.
            if not available cecrln then return.

            pdaOD = cecrln.dacompta.
        end.
        else pdaOD = cecrln.dacompta.

        /*** CALCUL DU SOLDE DU COMPTE (aparm.zone2 = 499900000)***/
        voCollection = new collection().
        voCollection:set('iNumeroSociete',      piCodeSociete).
        voCollection:set('iNumeroMandat',       viCodeEtablissement).
        voCollection:set('cNumeroCompte',       aparm.zone2).
        voCollection:set('iNumeroDossier',      0).
        voCollection:set('lAvecExtraComptable', false).
        voCollection:set('daDateSolde',         ietab.dafinex2).
        voCollection:set('cNumeroDocument',     '').
        voCollection:set('cCodeCollectif',      '').
        voCollection:set('dSoldeCompte',        decimal(0)).  // initialisation du solde (input/output)
        run compta/calculeSolde.p(input-output voCollection).
        vdSolde = voCollection:getDecimal('dSoldeCompte').
        delete object voCollection.
        if vdSolde ne 0 then do :
             pdaArchivage = ?.
             return.
             
        end.
        /** La derniere ligne 4999 lettrée **/
        pdaArchivage = 01/01/1901.
        {&_proparse_ prolint-nowarn(sortaccess)}
        if viCodeEtablissement <= 9999
        then for each cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = aparm.zone2
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")    // 4 positions
              and cecrln.type-cle   = "ODFM" 
              and cecrln.flag-let   = true
            by cecrln.dalettrage descending:
            pdaArchivage = maximum(cecrln.dalettrage, pdaArchivage).
            leave.
        end.
        {&_proparse_ prolint-nowarn(sortaccess)}
        for each cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = aparm.zone2
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")   // 5 positions
              and cecrln.type-cle   = "ODFM" 
              and cecrln.flag-let   = true
            by cecrln.dalettrage descending:
            pdaArchivage = maximum(cecrln.dalettrage, pdaArchivage).
            leave.
        end.
        if pdaArchivage = 01/01/1901 and pdaOD <> ? 
        then do:
            {&_proparse_ prolint-nowarn(release)}
            release cecrln.
            if viCodeEtablissement <= 9999
            then find first cecrln no-lock
                where cecrln.soc-cd     = piCodeSociete
                  and cecrln.etab-cd    = viCodeEtablissement 
                  and cecrln.sscoll-cle = ""
                  and cecrln.cpt-cd     = aparm.zone2
                  and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")    // 4 positions
                  and cecrln.type-cle   = "ODFM" 
                  and cecrln.flag-let   = false no-error.
            if not available cecrln
            then find first cecrln no-lock
                where cecrln.soc-cd     = piCodeSociete
                  and cecrln.etab-cd    = viCodeEtablissement 
                  and cecrln.sscoll-cle = ""
                  and cecrln.cpt-cd     = aparm.zone2
                  and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")   // 5 positions
                  and cecrln.type-cle   = "ODFM" 
                  and cecrln.flag-let   = false no-error.
            /** Lorsque le client a soldé son mandat en règlant le nouveau syndic, l'OD de résiliation
            solde les comptes un à un, mais ne solde pas le mandat car il est déjà soldé.
            D'oû pas lignes sur le 4999 dans l'OD de résiliation . **/
            pdaArchivage = if available cecrln then ? else pdaOD.
        end. 
    end.
    if pdaArchivage = 01/01/1901 then pdaArchivage = ?.

end procedure.

