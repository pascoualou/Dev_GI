/*-----------------------------------------------------------------------------
File        : majofflc.p
Purpose     : mise a jour des offres de location
Author(s)   : SP 21/02/1996      -     GGA 2018/09/18
Notes       : reprise de adb/src/bien/majofflc.p
              pour reprise de la maj sur table obslc (observatoire), ObsLc.NoObs = 0
------------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{outils/include/lancementProgramme.i}        // fonctions lancementPgm, suppressionPgmPersistent
{crud/include/detlc.i}
{crud/include/offlc.i}

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghProc          as handle    no-undo.
define variable giNumeroMandat  as int64     no-undo.
define variable giNumeroUL      as integer   no-undo.
define variable gcListeRubrique as character no-undo.
define variable giNbMoisPeriode as integer   no-undo. 

procedure lancementMajofflc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat  as int64     no-undo.
    define input parameter piNumeroUL      as integer   no-undo.
    define input parameter pcListeRubrique as character no-undo.
    define input parameter piNbMoisPeriode as integer   no-undo. 

    assign
        giNumeroMandat  = piNumeroMandat 
        giNumeroUL      = piNumeroUL     
        gcListeRubrique = pcListeRubrique
        giNbMoisPeriode = piNbMoisPeriode
        goCollectionHandlePgm = new collection()
    .
    run trtMajofflc.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure trtMajofflc private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable viI                         as integer   no-undo.
    define variable vcTempo                     as character no-undo.
    define variable vcTableauRubriqueParFamille as integer   extent 4 no-undo.
    define variable vcTableauLibelleParFamille  as integer   extent 4 no-undo.
    define variable vdTableauMontantParFamille  as decimal   extent 4 format "->>,>>>,>>9.99" init 0 no-undo.
    define variable vdTotalRubrique             as decimal   no-undo.
    define variable vlModifRubrique             as logical   no-undo.

    define buffer offlc for offlc.
    define buffer detlc for detlc.
    define buffer rubqt for rubqt.
 
    empty temp-table ttOfflc. 
    find first offlc no-lock
         where offlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and offlc.nocon = giNumeroMandat
           and offlc.noapp = giNumeroUL no-error.
    if not available offlc 
    then return.
    
    create ttOfflc.
    assign
        ttOfflc.tpcon       = offlc.tpcon
        ttOfflc.nocon       = offlc.nocon
        ttOfflc.noapp       = offlc.noapp
        ttOfflc.CRUD        = "U"
        ttOfflc.rRowid      = rowid(offlc)
        ttOfflc.dtTimestamp = datetime(offlc.dtmsy, offlc.hemsy)        
    .

    /* Verification s'il y a eu une modif de l'offre ou qu'il y a une rubrique de l'offre a 0 */
    do viI = 1 to num-entries(gcListeRubrique, '|'):
        assign
            vcTempo       = entry(viI, gcListeRubrique, '|')
            vcTableauRubriqueParFamille[viI] = integer(entry(1, vcTempo, '@'))
            vcTableauLibelleParFamille[viI] = integer(entry(2, vcTempo, '@'))
            vdTableauMontantParFamille[viI] = decimal(entry(3, vcTempo, '@')) 
            .
        if viI <> 4                                                        /* Calcul du montant MENSUEL sauf pour les Rub Administratives (Famille 4) */ 
        then vdTableauMontantParFamille[viI] = vdTableauMontantParFamille[viI] / giNbMoisPeriode .        
        vdTotalRubrique = vdTotalRubrique + vdTableauMontantParFamille[viI].
        if vdTableauMontantParFamille[viI] <> decimal(offlc.tbfam[viI]) or vdTableauMontantParFamille[viI] = 0 
        then vlModifRubrique = yes.
    end.
    /* Si les montants passes en parametre sont = aux montants de l'offre alors aucune modification */
    if gcListeRubrique <> "" and not vlModifRubrique and vdTotalRubrique = offlc.tbfam[6] 
    then return.
    assign
        ttofflc.nomaj = offlc.nomaj + 1
        ttofflc.dtmaj = integer(string(year(today), "9999") + string(month(today), "99"))
    .   
    empty temp-table ttdetlc.  
    do viI = 1 to num-entries(gcListeRubrique, '|'):
        if vdTableauMontantParFamille[viI] = 0 then next.
        find first detlc no-lock
             where detlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
               and detlc.nocon = giNumeroMandat
               and detlc.noapp = giNumeroUL
               and detlc.norub = vcTableauRubriqueParFamille[viI] no-error.
        if available detlc
        then do:
            create ttdetlc.
            assign
                ttdetlc.tpcon       = detlc.tpcon
                ttdetlc.nocon       = detlc.nocon
                ttdetlc.noapp       = detlc.noapp
                ttdetlc.norub       = detlc.norub
                ttdetlc.CRUD        = "U"
                ttdetlc.rRowid      = rowid(detlc)
                ttdetlc.dtTimestamp = datetime(detlc.dtmsy, detlc.hemsy)        
                ttdetlc.mtrub       = vdTableauMontantParFamille[viI]
                ttdetlc.nomaj       = ttofflc.nomaj
            .
        end.
        else do:
            /* Test du genre de la rubrique (seule les fixes sont acceptees) */
            for first rubqt no-lock
                where rubqt.cdrub = vcTableauRubriqueParFamille[viI]
                  and rubqt.cdlib = 0
                  and rubqt.cdgen = "00001":
                create ttdetlc.
                assign
                    ttdetlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
                    ttdetlc.nocon = giNumeroMandat
                    ttdetlc.noapp = giNumeroUL
                    ttdetlc.norub = vcTableauRubriqueParFamille[viI]
                    ttdetlc.CRUD  = "C"
                    ttdetlc.cdfam = rubqt.cdfam
                    ttdetlc.nolib = vcTableauLibelleParFamille[viI]
                    ttdetlc.nomaj = ttofflc.nomaj
                    ttdetlc.mtrub = vdTableauMontantParFamille[viI]
                .
            end.
        end.
    end.
    ghProc = lancementPgm("crud/detlc_CRUD.p", goCollectionHandlePgm).
    run setDetlc in ghProc (table ttDetlc by-reference).
    if mError:erreur() then return.

    empty temp-table ttdetlc. 
    for each detlc no-lock                                         /* Parcours des rubriques non rectifiees dans detlc */
       where detlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
         and detlc.nocon = giNumeroMandat
         and detlc.noapp = giNumeroUL
         and detlc.nomaj <> ttofflc.nomaj: 
        create ttdetlc.
        assign 
            ttdetlc.tpcon       = detlc.tpcon
            ttdetlc.nocon       = detlc.nocon
            ttdetlc.noapp       = detlc.noapp
            ttdetlc.norub       = detlc.norub
            ttdetlc.CRUD        = "D"
            ttdetlc.rRowid      = rowid(detlc)
            ttdetlc.dtTimestamp = datetime(detlc.dtmsy, detlc.hemsy)                    
        .
    end.
    ghProc = lancementPgm("crud/detlc_CRUD.p", goCollectionHandlePgm).
    run setDetlc in ghProc (table ttDetlc by-reference).
    if mError:erreur() then return.

    vdtotalRubrique = 0.
    do viI = 1 to 6:
        ttofflc.tbfam[viI] = 0.
    end.    
    for each detlc no-lock
       where detlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
         and detlc.nocon = giNumeroMandat
         and detlc.noapp = giNumeroUL:
        assign
            ttofflc.tbfam[detlc.cdfam] = ttofflc.tbfam[detlc.cdfam] + detlc.mtrub     
            vdtotalRubrique            = vdtotalRubrique + detlc.mtrub         
        .     
    end.             
    ttofflc.tbfam[6] = vdtotalRubrique.
    ghProc = lancementPgm("crud/offlc_CRUD.p", goCollectionHandlePgm).
    run setOfflc in ghProc(table ttOfflc by-reference).
    if mError:erreur() then return.

end procedure.

