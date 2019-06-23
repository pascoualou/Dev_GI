/*------------------------------------------------------------------------
File        : tachePaiePegase.p
Purpose     : tache paie pegase
Author(s)   : GGA - 2017/11/13
Notes       : a partir de adb/tach/prmmtpeg.p
code revue  : adb-paie20171201.00
------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/codePeriode.i}
{preprocesseur/type2role.i}

using parametre.syspg.syspg. 
using parametre.pclie.parametrageCorrespondance.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/etabl.i}
{adblib/include/ctanx.i}
{adblib/include/cttac.i}
{tache/include/tachePaiePegase.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{comm/include/prccoros.i}      // function getLibelleTypeOrganisme, getNomOrganisme
{comm/include/prclbdiv.i}      // function majParamLbdiv, getValeurParametre
{adblib/include/incctrpa.i}    // function controleSiren

function NoMandant returns integer private(pcTypeMandat as character, piNumeroMandat as int64):
    /*------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.tpidt = {&TYPEROLE-mandant}
          and intnt.nocon = piNumeroMandat:
        return intnt.noidt.
    end.
    return ?.

end function.
         
procedure getPaiePegase:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTachePaiePegase.
 
    define variable viI              as integer                         no-undo.
    define variable vcTempo          as character                       no-undo.
    define variable vcTempo2         as character                       no-undo.
    define variable vcListeOrgSoc    as character                       no-undo.
    define variable voCorrespondance as class parametrageCorrespondance no-undo.

    define buffer etabl  for etabl.
    define buffer detail for detail.

    empty temp-table ttTachePaiePegase.
    empty temp-table ttCombo.
    if not can-find (first ctrat no-lock
                     where ctrat.tpcon = pcTypeMandat
                       and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    voCorrespondance = new parametrageCorrespondance().
    create ttTachePaiePegase.
    assign 
        ttTachePaiePegase.CRUD           = 'R'
        ttTachePaiePegase.cTypeContrat   = pcTypeMandat
        ttTachePaiePegase.iNumeroContrat = piNumeroMandat
        ttTachePaiePegase.cTypeTache     = {&TYPETACHE-paiePegase}
        ttTachePaiePegase.cCodeSiret     = "000000000"
        ttTachePaiePegase.cCodeNic       = "00000"
    .
    for first etabl no-lock
        where etabl.tpcon = pcTypeMandat
          and etabl.nocon = piNumeroMandat
          and etabl.tptac = {&TYPETACHE-organismesSociaux}:
        assign
            ttTachePaiePegase.cCodeSiret        = string(etabl.siren,"999999999")
            ttTachePaiePegase.cCodeNic          = string(etabl.nonic,"99999")
            ttTachePaiePegase.cCodeApe          = etabl.cdape
            ttTachePaiePegase.lAssujettissement = etabl.fgtax 
            ttTachePaiePegase.iTauxTaxe         = etabl.txtax
            ttTachePaiePegase.dtTimestamp       = datetime(etabl.dtmsy, etabl.hemsy)
            ttTachePaiePegase.rRowid            = rowid(etabl)
        .
boucleLbdiv4:
        do viI = 1 to num-entries(etabl.lbdiv4, separ[2]):
            vcTempo = entry(viI, etabl.lbdiv4, separ[2]).
            if num-entries(vcTempo, "=") < 2 then next boucleLbdiv4.

            case entry(1, vcTempo, "="):
                when "PEGASE"  then                                           ttTachePaiePegase.lGestionPaieExternePegase = (entry(2, vcTempo, "=") = "OUI").
                when "DTDEB"   then if date(entry(2, vcTempo, "=")) <> ? then ttTachePaiePegase.daDebutPaiePegase         = date(entry(2, vcTempo, "=")).
                when "DTFIN"   then if date(entry(2, vcTempo, "=")) <> ? then ttTachePaiePegase.daFinPaiePegase           = date(entry(2, vcTempo, "=")).
                when "MODCPTA" then                                           ttTachePaiePegase.cModeComptabilisation     = entry(2, vcTempo, "=").
                when "CLEARD"  then                                           ttTachePaiePegase.cClePourOd                = entry(2, vcTempo, "=").
            end case.     
        end.
        assign
            ttTachePaiePegase.cCodeSociete            = getValeurParametre("CODSOCIETE", "=", separ[2], etabl.lbdiv4)
            vcTempo                                   = getValeurParametre("DT1EXPOR", "=", separ[2], etabl.lbdiv4)
            vcTempo2                                  = getValeurParametre("HE1EXPOR", "=", separ[2], etabl.lbdiv4)
            ttTachePaiePegase.cDateHeurePremierExport = (if vcTempo > "" then substitute("&1 à &2", vcTempo, vcTempo2) else "")
            vcTempo                                   = getValeurParametre ("FLGMONOETAB", "=", separ[2], etabl.lbdiv5)
            ttTachePaiePegase.lMonoEtablissement      = (vcTempo = "1") 
            vcTempo                                   = getValeurParametre("FLGDECLARANTTSAL", "=", separ[2], etabl.lbdiv5)
            ttTachePaiePegase.lEtablissementDeclarant = (vcTempo = "1") 
            ttTachePaiePegase.cEtablissementPrincipal = getValeurParametre("CODETABPRINCIPAL", "=", separ[2], etabl.lbdiv5)
            ttTachePaiePegase.cEtablissementPrincipal = (if integer(ttTachePaiePegase.cEtablissementPrincipal) > 0
                                                         then string(integer(ttTachePaiePegase.cEtablissementPrincipal), "99999")
                                                         else "")            
            ttTachePaiePegase.cCentrePaiementInit     = getValeurParametre("ORPINI", "=", separ[2], etabl.lbdiv4)
            vcListeOrgSoc                             = getValeurParametre("ORGSOC", "=", separ[2], etabl.lbdiv5)
            ttTachePaiePegase.cLibelleModeComptabilisation = (if ttTachePaiePegase.cModeComptabilisation = "2"
                                                              then outilTraduction:getLibelle(107963)   //brut
                                                              else outilTraduction:getLibelle(1000487)) //Net (= mode Magi)
        .
boucl-rech-etsdecl:
        do viI = 1 to num-entries(vcListeOrgSoc):
            voCorrespondance:reload(if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance else mtoken:cRefCopro
                                  , entry(viI, vcListeOrgSoc)).
            if voCorrespondance:isDbParameter and voCorrespondance:getTypeDucs() = 18
            then for first detail no-lock 
                where detail.cddet = substitute("PZ_ORGSC_&1", pcTypeMandat)
                  and detail.nodet = piNumeroMandat
                  and detail.ixd01 = entry(viI, vcListeOrgSoc):
                ttTachePaiePegase.cEtablissementDeclarant = (if integer(detail.tbchr[5]) > 0 then string(integer(detail.tbchr[5]) , "99999") else "").                  
                leave boucl-rech-etsdecl. 
            end.
        end.
    end. 
    // si siret pour l'etablissement inexistant alors recherche si siret pour l'entreprise
    if ttTachePaiePegase.cCodeSiret = "000000000"
    then run Lec_SIRET_Entreprise(ttTachePaiePegase.cTypeContrat, ttTachePaiePegase.iNumeroContrat, 
                                  output ttTachePaiePegase.cCodeSiret, output ttTachePaiePegase.cCodeNic, output ttTachePaiePegase.cCodeApe).
    delete object voCorrespondance.                                           
end procedure.

procedure setPaiePegase:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTachePaiePegase.
    
    define variable vhEntrpadp                 as handle    no-undo.
    define variable viI                        as integer   no-undo.
    define variable vcTempo                    as character no-undo.
    define variable vlGestionPaiePegaseInitial as logical   no-undo.
    define variable viNbFic                    as integer   no-undo.
    define variable vlRetExp                   as logical   no-undo.
    
    define buffer etabl for etabl.      

    for first ttTachePaiePegase
        where lookup(ttTachePaiePegase.CRUD, "C,U") > 0:
        if not can-find (first ctrat no-lock
                         where ctrat.tpcon = ttTachePaiePegase.cTypeContrat
                           and ctrat.nocon = ttTachePaiePegase.iNumeroContrat)
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        //on recherche la valeur initiale du flag gestion de la paie en externe sous pegase  
        for first etabl no-lock
            where etabl.tpcon = ttTachePaiePegase.cTypeContrat
              and etabl.nocon = ttTachePaiePegase.iNumeroContrat
              and etabl.tptac = {&TYPETACHE-organismesSociaux}:
boucleLbdiv4:
            do viI = 1 to num-entries(etabl.lbdiv4, separ[2]):
                vcTempo = entry(viI, etabl.lbdiv4, separ[2]).
                if num-entries(vcTempo, "=") < 2 then next boucleLbdiv4.

                case entry(1, vcTempo, "="):
                    when "PEGASE"  then vlGestionPaiePegaseInitial = (entry(2, vcTempo, "=") = "OUI").
                end case.     
            end.
        end.
        run verZonSai(buffer ttTachePaiePegase).
        if mError:erreur() then return.
        
        run MajTabEts (buffer ttTachePaiePegase).
        if mError:erreur() then return.
  
        if vlGestionPaiePegaseInitial = no
        and ttTachePaiePegase.lGestionPaieExternePegase = yes
        then do:
            run adb/paie/entrpadp.p persistent set vhEntrpadp.
            run getTokenInstance in vhEntrpadp(mToken:JSessionId).     
            run entrpadpLanceExport in vhEntrpadp ("MAJPEGASE", ttTachePaiePegase.cTypeContrat, ttTachePaiePegase.iNumeroContrat, integer(mtoken:cRefPrincipale) , output viNbFic, output vlRetExp).
            run destroy in vhEntrpadp.   
        end.
    end.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTachePaiePegase for ttTachePaiePegase.

    define variable vcSiretEnt as character no-undo.
    define variable vcNicEnt   as character no-undo.
    define variable vcApeEnt   as character no-undo.
    
    if ttTachePaiePegase.lGestionPaieExternePegase
    then do:
        //Code Siret obligatoire si gestion paie externe sous Pégase
        if integer(ttTachePaiePegase.cCodeSiret) = 0                              then mError:createError({&error}, 1000485).
        //Code complément Siret obligatoire si gestion paie externe sous Pégase
        else if integer(ttTachePaiePegase.cCodeNic) = 0                           then mError:createError({&error}, 1000486).
        // Code APE Absent
        else if ttTachePaiePegase.cCodeApe = "" or ttTachePaiePegase.cCodeApe = ? then mError:createError({&error}, 103524).
        // Code APE Invalide
        else if length(ttTachePaiePegase.cCodeApe, "character") <> 5              then mError:createError({&error}, 103532).
        if mError:erreur() then return.
    end.
    if integer(ttTachePaiePegase.cCodeSiret) <> 0
    then do:
        run Lec_SIRET_Entreprise(ttTachePaiePegase.cTypeContrat, ttTachePaiePegase.iNumeroContrat, 
                                 output vcSiretEnt, output vcNicEnt, output vcApeEnt).
        // Le no SIREN de l'établissement doit etre identique à celui de l'entreprise (mandat ou syndicat)
        if integer(vcSiretEnt) <> 0 and vcSiretEnt <> ttTachePaiePegase.cCodeSiret then mError:createError({&error}, 103628).
        else if controleSiren(ttTachePaiePegase.cCodeSiret, ttTachePaiePegase.cCodeNic) = no
             then mError:createError({&error}, 103519).
        if mError:erreur() then return.
    end.
    if  ttTachePaiePegase.daDebutPaiePegase <> ?
    and ttTachePaiePegase.daFinPaiePegase   <= ttTachePaiePegase.daDebutPaiePegase
    then mError:createError({&error}, 104177).         //La date de fin doit être supérieur à la date de début
    else if ttTachePaiePegase.cClePourOd = "" or  ttTachePaiePegase.cClePourOd = ?
    then mError:createError({&error}, 1000539).        //clé pour OD obligatoire
    else if not can-find(first clemi no-lock
                    where clemi.tpcon = ttTachePaiePegase.cTypeContrat 
                      and clemi.nocon = ttTachePaiePegase.iNumeroContrat
                      and clemi.cdcle = ttTachePaiePegase.cClePourOd
                      and clemi.nbtot <> 0)
    then mError:createError({&error}, 1000540). //Clé pour OD doit être une clé affectée au mandat avec des millièmes

end procedure.               
        
procedure MajTabEts private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTachePaiePegase for ttTachePaiePegase.

    define variable vhEtabl   as handle    no-undo.
    define variable vhCttac   as handle    no-undo.
    define variable vcZonLib4 as character no-undo.
    define variable vcTempo   as character no-undo.
    define variable viI       as integer   no-undo.

    define buffer etabl for etabl.

    find first etabl no-lock
        where etabl.tpcon = ttTachePaiePegase.cTypeContrat
          and etabl.nocon = ttTachePaiePegase.iNumeroContrat
          and etabl.tptac = {&TYPETACHE-organismesSociaux} no-error.
    if available etabl and etabl.lbdiv4 begins "PEGASE=" then do:
        vcZonLib4 = etabl.lbdiv4.
boucleLbdiv4:
        do viI = 1 to num-entries(vcZonLib4, separ[2]):
            vcTempo = entry(viI, vcZonLib4, separ[2]).
            if num-entries(vcTempo, "=") < 2 then next boucleLbdiv4.

            case entry(1, vcTempo, "="):
                when "PEGASE" then assign
                    entry(2, vcTempo, "=")          = (string(ttTachePaiePegase.lGestionPaieExternePegase, "OUI/NON"))
                    entry(viI, vcZonLib4, separ[2]) = vcTempo
                . 
                when "DTDEB" then assign
                    entry(2, vcTempo, "=")          = string(ttTachePaiePegase.daDebutPaiePegase)
                    entry(viI, vcZonLib4, separ[2]) = vcTempo
                . 
                when "DTFIN" then assign
                    entry(2, vcTempo, "=")          = string(ttTachePaiePegase.daFinPaiePegase)
                    entry(viI, vcZonLib4, separ[2]) = vcTempo
                . 
                when "MODCPTA" then assign
                    entry(2, vcTempo, "=")          = ttTachePaiePegase.cModeComptabilisation
                    entry(viI, vcZonLib4, separ[2]) = vcTempo
                . 
                when "CLEARD" then assign
                    entry(2, vcTempo, "=")          = ttTachePaiePegase.cClePourOd
                    entry(viI, vcZonLib4, separ[2]) = vcTempo
                .                
            end case.                           
        end.                 
    end.    
    else vcZonLib4 = substitute("PEGASE=&1&2DTDEB=&3&2DTFIN=&4&2MODCPTA=&5&2CLEARD=&6&2DT1EXPOR=&2HE1EXPOR="
                              , string(ttTachePaiePegase.lGestionPaieExternePegase, "OUI/NON")
                              , separ[2]
                              , string(ttTachePaiePegase.daDebutPaiePegase)
                              , string(ttTachePaiePegase.daFinPaiePegase)
                              , ttTachePaiePegase.cModeComptabilisation
                              , ttTachePaiePegase.cClePourOd).
    empty temp-table ttEtabl.
    create ttEtabl.
    assign
        ttEtabl.tpcon  = ttTachePaiePegase.cTypeContrat
        ttEtabl.nocon  = ttTachePaiePegase.iNumeroContrat
        ttEtabl.tptac  = {&TYPETACHE-organismesSociaux}
        ttEtabl.siren  = integer(ttTachePaiePegase.cCodeSiret)
        ttEtabl.nonic  = integer(ttTachePaiePegase.cCodeNic) 
        ttEtabl.cdape  = ttTachePaiePegase.cCodeApe 
        ttEtabl.lbdiv4 = vcZonLib4
    .
    if available etabl
    then assign 
         ttEtabl.CRUD        = "U"
         ttEtabl.dtTimestamp = ttTachePaiePegase.dtTimestamp
         ttEtabl.rRowid      = ttTachePaiePegase.rRowid
    .
    else ttEtabl.CRUD        = "C". 
    run adblib/etabl_CRUD.p persistent set vhEtabl.
    run getTokenInstance in vhEtabl(mToken:JSessionId).     
    run setEtabl in vhEtabl (table ttEtabl by-reference).
    run destroy in vhEtabl.            
    if mError:erreur() then return.
     
    if not can-find(first cttac no-lock
                    where cttac.tpcon = ttTachePaiePegase.cTypeContrat
                      and cttac.nocon = ttTachePaiePegase.iNumeroContrat
                      and cttac.tptac = {&TYPETACHE-paiePegase})
    then do:
        empty temp-table ttCttac. 
        create ttCttac.
        assign
            ttCttac.tpcon = ttTachePaiePegase.cTypeContrat
            ttCttac.nocon = ttTachePaiePegase.iNumeroContrat
            ttCttac.tptac = {&TYPETACHE-paiePegase}
            ttCttac.CRUD  = "C"
        .
        run adblib/cttac_CRUD.p persistent set vhCttac.
        run getTokenInstance in vhCttac(mToken:JSessionId).        
        run setCttac in vhCttac (table ttCttac by-reference).
        run destroy in vhCttac.            
        if mError:erreur() then return.
    end.

    if integer(ttTachePaiePegase.cCodeSiret) <> 0 and integer(ttTachePaiePegase.cCodeNic) <> 0
    then do: 
        run Maj_SIRET_Entreprise (ttTachePaiePegase.cTypeContrat, ttTachePaiePegase.iNumeroContrat, integer(ttTachePaiePegase.cCodeSiret), integer(ttTachePaiePegase.cCodeNic), ttTachePaiePegase.cCodeApe).
        if mError:erreur() = yes then return. 
    end.

end procedure.

procedure Lec_SIRET_Entreprise private:
    /*------------------------------------------------------------------------------
    Purpose: recherche code siret entreprise
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter  pcTypeMandat   as character no-undo.
    define input parameter  piNumeroMandat as int64     no-undo.    
    define output parameter pcCodeSiret    as character no-undo. 
    define output parameter pcCodeNic      as character no-undo. 
    define output parameter pcCodeApe      as character no-undo. 

    define variable viNoMandant as integer no-undo.

    define buffer vbroles for roles.
    define buffer ctanx   for ctanx.

    viNoMandant = NoMandant(pcTypeMandat, piNumeroMandat). 
    for first vbroles no-lock
        where vbroles.tprol = {&TYPEROLE-mandant}
          and vbroles.norol = viNoMandant
      , first ctanx no-lock
        where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
          and ctanx.tprol = {&TYPEROLE-tiers}
          and ctanx.norol = vbroles.notie:
        assign
            pcCodeSiret = string(ctanx.nosir, "999999999")
            pcCodeNic   = string(ctanx.cptbq, "99999")
            pcCodeApe   = ctanx.cdape
        .
    end.

end procedure.
   
procedure Maj_SIRET_Entreprise private:
    /*------------------------------------------------------------------------------
    Purpose: recherche code siret entreprise
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.    
    define input parameter piCodeSiret    as integer   no-undo. 
    define input parameter piCodeNic      as integer   no-undo. 
    define input parameter pcCodeApe      as character no-undo. 
 
    define variable vhCtanx     as handle  no-undo.
    define variable viNoMandant as integer no-undo.
 
    define buffer vbroles for roles.
    define buffer ctanx   for ctanx.    
    define buffer tiers   for tiers.
 
    viNoMandant = NoMandant(pcTypeMandat, piNumeroMandat).
    empty temp-table ttCtanx.
    for first vbroles no-lock
        where vbroles.tprol = {&TYPEROLE-mandant}
          and vbroles.norol = viNoMandant:
        for first ctanx no-lock
            where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}  
              and ctanx.tprol = {&TYPEROLE-tiers}
              and ctanx.norol = vbroles.notie:
            if ctanx.nosir = 0
            then do:         
                create ttCtanx.
                assign
                    ttCtanx.nodoc  = ctanx.nodoc
                    ttCtanx.nosir  = piCodeSiret
                    ttCtanx.cptbq  = piCodeNic
                    ttCtanx.cdape  = pcCodeApe
                .
            end.
        end.
        for first tiers no-lock
            where tiers.notie = vbroles.notie
              and tiers.nocon <> 0
          , first ctanx no-lock
            where ctanx.tpcon = {&TYPECONTRAT-Association}
              and ctanx.nocon = tiers.nocon:
            if ctanx.nosir = 0 then do:
                create ttCtanx.
                assign
                    ttCtanx.nodoc  = ctanx.nodoc
                    ttCtanx.nosir  = piCodeSiret
                    ttCtanx.cptbq  = piCodeNic
                    ttCtanx.cdape  = pcCodeApe
                .
            end.
        end.
        run adblib/ctanx_CRUD.p persistent set vhCtanx.
        run getTokenInstance in vhCtanx(mToken:JSessionId).        
        run setCtanx in vhCtanx(table ttCtanx by-reference).
        run destroy in vhCtanx.
    end.   
end procedure.  

procedure initCombo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    
    define output parameter table for ttCombo.

    run chargeCombo (piNumeroMandat, pcTypeMandat). 
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    
    define variable voSyspg as class syspg  no-undo.

    define buffer clemi for clemi.

    voSyspg = new syspg().
    voSyspg:creationttCombo("MODECOMPTABILISATION", "1", outilTraduction:getLibelle(1000487), output table ttCombo by-reference). //Net (= mode Magi)  
    voSyspg:creationttCombo("MODECOMPTABILISATION", "2", outilTraduction:getLibelle(107963), output table ttCombo by-reference). //brut
    for each clemi no-lock
       where clemi.tpcon = pcTypeMandat
         and clemi.nocon = piNumeroMandat
         and clemi.nbtot <> 0 :
        voSyspg:creationttCombo("CLE-OD", clemi.cdcle, clemi.lbcle, output table ttCombo by-reference).             
    end.
    delete object voSyspg. 
end procedure.
