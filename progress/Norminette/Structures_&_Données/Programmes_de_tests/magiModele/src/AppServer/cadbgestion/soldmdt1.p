/*------------------------------------------------------------------------
File        : solmdt1.p
Purpose     : Changement de nature de contrat - Liste des comptes locataires à transférer 
Author(s)   : GGA - 18/01/19
Notes       : reprise cadb/gestion/SoldMdt1.p
todo : programme pas appelé. Peut-être aussi bien en include, puisqu'il n'y un qu'une procédure.
01  01/07/2002  JR    Fiche 0602/1364.
02  25/07/2002  LG    0702/0956
03  06/02/2003  DM    0203/0069  Lenteur
04  27/05/2003  DM    0503/0221  Pb test date resil
05  19/09/2008  DM    0608/0065: Mandat 5 chiffres
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure soldmdt1Controle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe.
             pdaOD = ? si pas OD, pdaArchivage = ? si non archivé.
             piCodeRetour:  0 = Pas d'erreur, 1 = Erreur indefinie, 2 = société compta absente,  3 = Mandat inexistant
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSociete        as integer   no-undo.
    define input  parameter piNumeroMandatSource as integer   no-undo.
    define output parameter piCodeRetour         as integer   no-undo.
    define output parameter pdaOD                as date      no-undo.
    define output parameter pdaArchivage         as date      no-undo.

    define variable viCodeEtablissement as integer   no-undo.
    define variable vdSolde             as decimal   no-undo.
    define variable viCodePeriode       as integer   no-undo.

    define buffer ietab   for ietab.
    define buffer cecrln  for cecrln.
    define buffer csscpt  for csscpt.
    define buffer ccptmvt for ccptmvt.
    define buffer aparm   for aparm.
    define buffer iprd    for iprd.
    define buffer ccptcol for ccptcol.

    if not can-find(first isoc no-lock where isoc.soc-cd = piCodeSociete)
    then do:
        piCodeRetour = 2. /* société compta absente */
        return.
    end.
    find first ietab no-lock
        where ietab.soc-cd  = piCodeSociete
          and ietab.etab-cd = piNumeroMandatSource no-error.
    if not available ietab
    then do:
        piCodeRetour = 3. /* Mandat inexistant */
        return.
    end.
    viCodeEtablissement = ietab.etab-cd.
    /* Recherche des DATES d'OD et d'archivage du mandat */
    if ietab.profil-cd = 21 /* gerance */ 
    then do:
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
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")
              and cecrln.type-cle   = "ODFM" no-error.
        if not available cecrln 
        then find first cecrln no-lock 
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = "M"
              and cecrln.cpt-cd     = "00000"
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")
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
            if viCodeEtablissement <= 9999 
            then for each cecrln no-lock
                where cecrln.soc-cd     = piCodeSociete
                  and cecrln.etab-cd    = viCodeEtablissement 
                  and cecrln.sscoll-cle = csscpt.sscoll-cle
                  and cecrln.cpt-cd     = csscpt.cpt-cd
                  and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")
                  and cecrln.type-cle   = "ODFM"
                by cecrln.dalettrage descending:
                pdaArchivage = maximum(cecrln.dalettrage, pdaArchivage).
                leave.
            end.
            for each cecrln no-lock
                where cecrln.soc-cd     = piCodeSociete
                  and cecrln.etab-cd    = viCodeEtablissement 
                  and cecrln.sscoll-cle = csscpt.sscoll-cle
                  and cecrln.cpt-cd     = csscpt.cpt-cd
                  and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")
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
        if can-find (first ctrat no-lock
                     where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                       and ctrat.nocon = piNumeroMandatSource
                       and ctrat.dtree = ?)
        then return.

        find first aparm no-lock
            where aparm.tppar = "RESOD"
              and aparm.cdpar = "CPT" no-error.
        release cecrln.
        if viCodeEtablissement <= 9999
        then find last cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = aparm.zone2
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")
              and cecrln.type-cle   = "ODFM" no-error.
        if not available cecrln 
        then find last cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = aparm.zone2
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")
              and cecrln.type-cle   = "ODFM" no-error.
        if not available cecrln 
        then do:
            viCodePeriode = ?.
BCL:
            repeat:
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
                release cecrln.
                if viCodeEtablissement <= 9999
                then find first cecrln no-lock 
                    where cecrln.soc-cd   = piCodeSociete
                      and cecrln.etab-cd  = viCodeEtablissement 
                      and cecrln.coll-cle = ""
                      and cecrln.prd-cd   = viCodePeriode
                      and cecrln.ref-num  = "SFM" + string(viCodeEtablissement, "9999")
                      and cecrln.type-cle = "ODFM" 
                    use-index ecrln-ref-num no-error.
                if not available cecrln
                then find first cecrln no-lock  
                    where cecrln.soc-cd   = piCodeSociete
                      and cecrln.etab-cd  = viCodeEtablissement 
                      and cecrln.coll-cle = ""
                      and cecrln.prd-cd   = viCodePeriode
                      and cecrln.ref-num  = "SFM" + string(viCodeEtablissement, "99999")
                      and cecrln.type-cle = "ODFM" 
                    use-index ecrln-ref-num no-error.
                if available cecrln then leave BCL.

                for each ccptcol no-lock
                    where ccptcol.Soc-cd = piCodeSociete:
                    release cecrln.
                    if viCodeEtablissement <= 9999
                    then find first cecrln no-lock 
                        where cecrln.soc-cd   = piCodeSociete
                          and cecrln.etab-cd  = viCodeEtablissement 
                          and cecrln.coll-cle = ccptcol.coll-cle
                          and cecrln.prd-cd   = viCodePeriode
                          and cecrln.ref-num  = "SFM" + string(viCodeEtablissement, "9999")
                          and cecrln.type-cle = "ODFM" 
                        use-index ecrln-ref-num no-error.
                    if not available cecrln 
                    then find first cecrln no-lock  
                        where cecrln.soc-cd   = piCodeSociete
                          and cecrln.etab-cd  = viCodeEtablissement 
                          and cecrln.coll-cle = ccptcol.coll-cle
                          and cecrln.prd-cd   = viCodePeriode
                          and cecrln.ref-num  = "SFM" + string(viCodeEtablissement, "99999")
                          and cecrln.type-cle = "ODFM" 
                        use-index ecrln-ref-num no-error.
                    if available cecrln then leave BCL.
                end. /* for each ccptcol */
            end.
            if not available cecrln then return.
            pdaOD = cecrln.dacompta.
        end.
        else pdaOD = cecrln.dacompta.

        /*** CALCUL DU SOLDE DU COMPTE ***/
/*gga todo revoir avec specialiste compta si possibilite d'utiliser programme calcul de solde plutot que de reprendre l'include
        vdSolde = 0.
        vcListeIn = string(piCodeSociete) + "|" + string(viCodeEtablissement) + "|" + "" + "|" + 
                    aparm.zone2  + "|S|" + string(ietab.dafinex2).   
        run IncludeSolCpt (vcListeIn,output vcListeOut).     
        vdSolde = decimal(entry(2,vcListeOut,"|")) - decimal(entry(3,vcListeOut,"|")).            
        
         if vdSolde ne 0 then do :
             pdaArchivage = ?.
             return.
         end.
gga todo*/        
        /** La derniere ligne 4999 lettrée **/
        pdaArchivage = 01/01/1901.
        if viCodeEtablissement <= 9999
        then for each cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = aparm.zone2
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")
              and cecrln.type-cle   = "ODFM" 
              and cecrln.flag-let   = true
            by cecrln.dalettrage descending:
            pdaArchivage = maximum(cecrln.dalettrage, pdaArchivage).
            leave.
        end.
        for each cecrln no-lock
            where cecrln.soc-cd     = piCodeSociete
              and cecrln.etab-cd    = viCodeEtablissement 
              and cecrln.sscoll-cle = ""
              and cecrln.cpt-cd     = aparm.zone2
              and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")
              and cecrln.type-cle   = "ODFM" 
              and cecrln.flag-let   = true
            by cecrln.dalettrage descending:
            pdaArchivage = maximum(cecrln.dalettrage, pdaArchivage).
            leave.
        end.
        if pdaArchivage = 01/01/1901 and pdaOD <> ? 
        then do:
            release cecrln.
            if viCodeEtablissement <= 9999
            then find first cecrln no-lock
                where cecrln.soc-cd     = piCodeSociete
                  and cecrln.etab-cd    = viCodeEtablissement 
                  and cecrln.sscoll-cle = ""
                  and cecrln.cpt-cd     = aparm.zone2
                  and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "9999")
                  and cecrln.type-cle   = "ODFM" 
                  and cecrln.flag-let   = false no-error.
            if not available cecrln
            then find first cecrln no-lock
                where cecrln.soc-cd     = piCodeSociete
                  and cecrln.etab-cd    = viCodeEtablissement 
                  and cecrln.sscoll-cle = ""
                  and cecrln.cpt-cd     = aparm.zone2
                  and cecrln.ref-num    = "SFM" + string(viCodeEtablissement, "99999")
                  and cecrln.type-cle   = "ODFM" 
                  and cecrln.flag-let   = false no-error.
            /** Lorsque le client a soldé son mandat en règlant le nouveau syndic, l'OD de résiliation
            solde les comptes un à un, mais ne solde pas le mandat car il est déjà soldé.
            D'oû pas lignes sur le 4999 dans l'OD de résiliation . **/
            pdaArchivage = if available cecrln then ? else pdaOD.
        end. 
    end.
    if pdaArchivage = 01/01/1901 then pdaArchivage = ?.
    piCodeRetour = 0.

end procedure.
/* {edigene\solcpt.i} */
