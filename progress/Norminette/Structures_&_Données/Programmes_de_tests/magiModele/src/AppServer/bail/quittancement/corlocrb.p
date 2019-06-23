/*------------------------------------------------------------------------
File        : corlocrb.p
Purpose     : Correction des rubriques FIXES d'un locataire sur les quittances POSTERIEURES a la quittance modifiee
              suite a modification et avant repercussion (MajLocRb.p)              
Author(s)   : SY 25/07/2000    -  GGA 2018/07/16
Notes       : reprise adb/quit/corlocrb.p
derniere revue: 2018/08/14 - phm: OK

 Cas traites :                                                             
  1) Rub absente dans une quittance normalement concern‚e                  
  2) Date de fin d'application qtt futures < dt deb appl 1Šre quittance    
     en cours                                                              

 Paramètres d'entrées:
   - piNumeroRole        : Numero de locataire (Nø Mandat + Nø Apt + Rang)         
   - piNumeroQuittance   : Numero de quittance corrigee                            
   - piNumeroRubrique    : Numero de rubrique modifiee                             
   - piNumeroLibelle     : Numero de libellé rubrique modifiee ou cree(12/12/2006)
   - pdaDebutApplication : Ancienne date de debut d'application                    
   - pdaFinApplication   : Ancienne date de fin d'application                      
   - pcDiversParametre   : Param divers (12/12/2006)                               
                                                                           
 Parametres de sorties :                                                   
   - pcCodeRetour : Code retour                                             

 0001  12/12/2006    SY    0905/0335 : plusieurs libellés autorisés pour
                           les rubriques loyer si param RUBML           
                           ATTENTION : nouveaux param entrée/sortie     
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{bail/include/tbtmprub.i &nomTable=ttRub2}

procedure trtCorlocrb:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter piNumeroRole        as integer   no-undo.
    define input parameter piNumeroQuittance   as integer   no-undo.
    define input parameter piNumeroRubrique    as integer   no-undo.
    define input parameter piNumeroLibelle     as integer   no-undo.
    define input parameter pdaDebutApplication as date      no-undo.
    define input parameter pdaFinApplication   as date      no-undo.
    define input parameter pcDiversParametre   as character no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    define variable viNumeroLibelleOld as integer no-undo.

    viNumeroLibelleOld = integer(entry(1, pcDiversParametre, "@")).       /* ajout SY le 13/12/2006: gestion changement no libellé */
    find first ttQtt
        where ttQtt.iNumeroLocataire = piNumeroRole
          and ttQtt.iNoQuittance = piNumeroQuittance no-error.
    if not available ttQtt then do:
        mError:createError({&error}, 1000852, string(piNumeroQuittance)).   //problème génération quittance &1, erreur sur table quittance
        return.
    end.
    empty temp-table ttRub2.
    for first ttRub
        where ttRub.iNumeroLocataire = piNumeroRole
          and ttRub.iNoQuittance = piNumeroQuittance
          and ttRub.iNorubrique = piNumeroRubrique
          and ttRub.iNoLibelleRubrique = piNumeroLibelle:
        create ttRub2.
        buffer-copy ttRub to ttRub2.
    end.
    /* redressement des rub fixes uniquement */
    if available ttRub2 and ttRub2.cCodeGenre <> "00001" then do:
        mError:createError({&error}, 1000855).            //redressement des rubriques fixes uniquement     
        return.
    end.
    /* 1) Trous dans la chaine de quittancement, Parcours des quittances qui devraient contenir la rubrique  */
    for each ttQtt
       where ttQtt.iNumeroLocataire = piNumeroRole
         and ttQtt.iNoQuittance > piNumeroQuittance
         and ttQtt.daDebutPeriode >= pdaDebutApplication and ttQtt.daDebutPeriode <  pdaFinApplication
         and ttQtt.daFinPeriode >  pdaDebutApplication and ttQtt.daDebutPeriode <= pdaFinApplication:
        find first ttRub
            where ttRub.iNumeroLocataire = piNumeroRole
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.iNorubrique = piNumeroRubrique
              and ttRub.iNoLibelleRubrique = (if viNumeroLibelleOld <> 0 then viNumeroLibelleOld else piNumeroLibelle) no-error.
        if not available ttRub then do:
            create ttRub.
            if available ttRub2
            then assign
                ttRub.dMontantQuittance            = if ttQtt.iProrata = 1 then ttRub2.dMontantTotal * ttQtt.iNumerateurProrata / ttQtt.iDenominateurProrata else ttRub2.dMontantTotal
                ttRub.iFamille                     = ttRub2.iFamille
                ttRub.iSousFamille                 = ttRub2.iSousFamille
                ttRub.cLibelleRubrique             = ttRub2.cLibelleRubrique
                ttRub.cCodeGenre                   = ttRub2.cCodeGenre
                ttRub.cCodeSigne                   = ttRub2.cCodeSigne
                ttRub.CdDet                        = ttRub2.CdDet
                ttRub.dQuantite                    = ttRub2.dQuantite
                ttRub.dPrixunitaire                = ttRub2.dPrixunitaire
                ttRub.dMontantTotal                = ttRub2.dMontantTotal
                ttRub.daDebutApplicationPrecedente = ttRub2.daDebutApplicationPrecedente
                ttRub.iNoOrdreRubrique             = ttRub2.iNoOrdreRubrique
            .
            assign
                ttRub.iNumeroLocataire = piNumeroRole
                ttRub.iNoQuittance = ttQtt.iNoQuittance
                ttRub.iProrata = ttQtt.iProrata
                ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata
                ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata
                ttRub.iNorubrique = piNumeroRubrique
                ttRub.iNoLibelleRubrique = piNumeroLibelle
                ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + ttRub.dMontantQuittance
                ttRub.daDebutApplication = pdaDebutApplication
                ttRub.daFinApplication = pdaFinApplication
                ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
                ttQtt.CdMaj = 1
            .
        end.
    end.
    /* 2) Redressement dates de debut des quittances suivantes */
    for each ttRub
        where ttRub.iNumeroLocataire = piNumeroRole
          and ttRub.iNoQuittance > piNumeroQuittance
          and ttRub.iNorubrique = piNumeroRubrique
          and ttRub.iNoLibelleRubrique = (if viNumeroLibelleOld <> 0 then viNumeroLibelleOld else piNumeroLibelle)    /* ajout SY le 13/12/2006 : gestion changement no libellé */
          and ttRub.daDebutApplication < pdaDebutApplication
      , first ttQtt
        where ttQtt.iNumeroLocataire = piNumeroRole
          and ttQtt.iNoQuittance = ttRub.iNoQuittance:
        assign
            ttRub.daDebutApplication = pdaDebutApplication
            ttQtt.CdMaj = 1
        .
    end.

end procedure.
