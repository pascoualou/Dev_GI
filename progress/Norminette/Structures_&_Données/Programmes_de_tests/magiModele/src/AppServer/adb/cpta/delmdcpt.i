/*---------------------------------------------------------------------------
File      : delmdcpt.i
Purpose   : Suppression d'un mandat de gérance 
Author(s) : SG 06/03/2003   -  GGA 2018/02/12
Notes     : reprise du pgm adb/cpta/delmdcpt.p

01  17/12/2003  DM   1103/0259 Suppression dispo HB
02  09/11/2007  SY   1007/0022: DAUCHEZ séparation ref Copr/gérance => ajour ref en param entrée
03  17/05/2016  DM   0516/0068: Activation auto mdt syndic
---------------------------------------------------------------------------*/

procedure suppressionMandatGerance:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/   
    define input parameter piSociete      as integer no-undo.
    define input parameter piNumeroMandat as integer no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define variable vhProc       as handle    no-undo.
    define variable vcParametre2 as character no-undo.

    define buffer ietab for ietab.
    define buffer aparm for aparm.

    for first ietab no-lock 
        where ietab.soc-cd  = piSociete
          and ietab.etab-cd = piNumeroMandat:

        /*== Suppression des comptes ==*/
        if can-find(first csscptcol no-lock 
                    where csscptcol.soc-cd  = piSociete
                      and csscptcol.etab-cd = piNumeroMandat) 
        then do:     
            vhProc = lancementPgm("compta/csscptcol_CRUD.p", poCollectionHandlePgm).
            run deleteCsscptcolSurEtabCd in vhProc(piSociete, piNumeroMandat).
            if mError:erreur() then return.
        end.

        /*== Suppression des journaux ==*/
        if can-find(first ijou no-lock
                    where ijou.soc-cd  = piSociete
                      and ijou.etab-cd = piNumeroMandat)  
        then do:    
            vhProc = lancementPgm ("compta/ijou_CRUD.p", poCollectionHandlePgm).
            run deleteIjouSurEtabCd in vhProc(piSociete, piNumeroMandat).
            if mError:erreur() then return.
        end.

        if can-find(first ijouprd no-lock
                    where ijouprd.soc-cd  = piSociete
                      and ijouprd.etab-cd = piNumeroMandat)
        then do:
            vhProc = lancementPgm ("compta/ijouprd_CRUD.p", poCollectionHandlePgm).
            run deleteIjouprdSurEtabCd in vhProc(piSociete, piNumeroMandat).
            if mError:erreur() then return.
        end.

        /*== Suppression des periodes ==*/
        if can-find(first iprd no-lock
                    where iprd.soc-cd  = piSociete
                      and iprd.etab-cd = piNumeroMandat) 
        then do:     
            vhProc = lancementPgm ("compta/iprd_CRUD.p", poCollectionHandlePgm).
            run deleteIprdSurEtabCd in vhProc(piSociete, piNumeroMandat).
            if mError:erreur() then return.
        end.
 
        if can-find(first idispohb no-lock
                    where idispohb.soc-cd  = piSociete
                      and idispohb.etab-cd = piNumeroMandat) 
        then do:
            vhProc = lancementPgm ("compta/idispohb_CRUD.p", poCollectionHandlePgm).
            run deleteIdispohbSurEtabCd in vhProc(piSociete, piNumeroMandat).
            if mError:erreur() then return.
        end.

        if can-find(first itypemvt no-lock
                    where itypemvt.soc-cd  = piSociete
                      and itypemvt.etab-cd = piNumeroMandat) 
        then do:
            vhProc = lancementPgm ("compta/itypemvt_CRUD.p", poCollectionHandlePgm).
            run deleteItypemvtSurEtabCd in vhProc(piSociete, piNumeroMandat).
            if mError:erreur() then return.
        end.

        if can-find(first parenc no-lock
                    where parenc.soc-cd  = piSociete
                      and parenc.etab-cd = piNumeroMandat)
        then do:
            vhProc = lancementPgm ("compta/parenc_CRUD.p", poCollectionHandlePgm).
            run deleteParencSurEtabCd in vhProc(piSociete, piNumeroMandat).
            if mError:erreur() then return.
        end.
        
        if ietab.profil-cd = 91 
        then for first aparm no-lock
            where aparm.tppar   = "TWEB2"
              and aparm.cdpar   = "ETAT95"
              and aparm.soc-cd  = 0
              and aparm.etab-cd = 0:
            if aparm.zone2 matches substitute("*@&1@*", string(ietab.etab-cd, ">>>>9"))
            then vcParametre2 = replace(aparm.zone2, "@" + string(ietab.etab-cd, ">>>>9") + "@", "").
            else if aparm.zone2 matches string(ietab.etab-cd, ">>>>9") + "@*"
                 then vcParametre2 = replace(aparm.zone2, string(ietab.etab-cd, ">>>>9") + "@", "").
                 else if aparm.zone2 matches "*@" + string(ietab.etab-cd, ">>>>9")
                      then vcParametre2 = replace(aparm.zone2, "@" + string(ietab.etab-cd, ">>>>9"), "").
            if vcParametre2 > "" and vcParametre2 <> aparm.zone2
            then do:
                empty temp-table ttAparm.
                create ttAparm.
                assign
                    ttAparm.tppar       = aparm.tppar
                    ttAparm.soc-cd      = aparm.soc-cd
                    ttAparm.etab-cd     = aparm.etab-cd
                    ttAparm.cdpar       = aparm.cdpar
                    ttAparm.CRUD        = "U"
                    ttAparm.dtTimestamp = datetime(aparm.damod, aparm.ihmod) 
                    ttAparm.rRowid      = rowid(aparm) 
                    ttAparm.zone2       = vcParametre2 
                .
                vhProc = lancementPgm("compta/aparm_CRUD.p", poCollectionHandlePgm).
                run setAparm in vhProc(table ttAparm by-reference).
                if mError:erreur() then return.
            end.
        end.
        if can-find(first ietab no-lock 
                    where ietab.soc-cd  = piSociete
                      and ietab.etab-cd = piNumeroMandat) 
        then do:      
            vhProc = lancementPgm("compta/ietab_CRUD.p", poCollectionHandlePgm).
            run deleteIetabSurEtabCd in vhProc(piSociete, piNumeroMandat).
            if mError:erreur() then return.
        end.
    end.

end procedure.
