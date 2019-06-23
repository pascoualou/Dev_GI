/*-----------------------------------------------------------------------------
File        : majrubtm.p
Purpose     : Mise a jour d'une rubrique d'une quittance
Author(s)   : PL - 22/01/1996       GGA - 2018/06/19
Notes       : reprise de adb/quit/majrubtm.p
              l'appel avec beaucoup de parametres est obligatoire (pas possible de passer un buffer en parametre) car selon l'appel les infos
              viennent de sources differentes
derniere revue: 2018/08/14 - phm: 

 Paramètres d'entrée:
     gcTpRolUse  : Tourjours locataire
     giNoLocUse  : Numero de locataire
     giNoQttUse  : Numero de quittance
     giCdRubUse  : Code de la rubrique
     CdFncUse-IN : Code Fonction de la procedure
     giCdFamUse  : Tourjours locataire
     giCdFamUse  : Code famille
     giCdSfaUse  : Code sous famile
     giNoLibUse  : Numero de libelle
     gcLbRubUse  : Libelle de la rubrique
     gcCdGenUse  : Genre de la rubrique
     gcCdSigUse  : signe de la rubrique
     gcCdDetUse  : Code detail : direct ou detaillé
     gdVlQteUse  : Quantité
     gdVlPunUse  : Prix unitaire
     gdMtTotUse  : Montant total brut
     giCdProUse  : Code prorata
     giVlNumUse  : Numerateur du prorata
     giVlDenUse  : Denominateur du prorata
     gdVlMtqUse  : Montant quittanc‚
     gdaDtDapUse : Date de debut d'application
     gdaDtFapUse : Date de fin d'application
     gcChFilUse  : filler
     giNoLigUse  : Numero de la ligne (classement a l'ecran)

 Paramètres de sortie:
     gcCdRetUse  : Code retour de la procedure
     NoErrUse-OU : Numero de l'erreur trouvée dans la procedure
     LbErrUse-OU : Libellé de l'erreur

01  15/02/1996  SP    Suppression du test sur la diff‚rence du montant précédent et du nouveau montant de la rubrique
02  18/06/1996  PL    Modif pour calcul des taxes apres modif.
03  23/04/1997  SP    Pas de lancement de la procédure de calcul des taxes quand noqtt < 0
04  21/05/1997  RT    Ajout variable partagée FgARevis
05  04/06/1999  JC    Ajout variable partagée FgAIndex
06  25/09/2002  SY    Dev389: Gestion du Pré-Bail (01032) & nouveau role candidat locataire (00069)
07  12/12/2006  SY    0905/0335: plusieurs libellés autorisés pour les rubriques loyer si param RUBML
08  13/12/2006  SY    0905/0335: Nouveaux param Entrée/Sortie
09  11/01/2010  SY    1108/0443: 20 rubriques maxi au lieu de 14
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}          // Doit être positionnée juste après using

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

{outils/include/lancementProgramme.i}                // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable goCollectionContrat   as class collection no-undo.
define variable ghProc                as handle no-undo.
define variable giNumeroLocataire     as integer   no-undo.
define variable giNumeroQuittance     as integer   no-undo.
define variable giNumeroRubrique      as integer   no-undo.
define variable gcTypeTraitement      as character no-undo.
define variable giCodeFamille         as integer   no-undo.
define variable giCodeSousFamille     as integer   no-undo.
define variable giNumeroLibelle       as integer   no-undo.
define variable gcLibelle             as character no-undo.
define variable gcCodeGenre           as character no-undo.
define variable gcSigne               as character no-undo.
define variable gcCodeDetail          as character no-undo.
define variable gdQuantite            as decimal   no-undo.
define variable gdPrixUnitaire        as decimal   no-undo.
define variable gdMontantTotalBrut    as decimal   no-undo.
define variable giCodeProrata         as integer   no-undo.
define variable gdNumerateurProrata   as integer   no-undo.
define variable gdDenominateurProrata as integer   no-undo.
define variable gdMontantQuittance    as decimal   no-undo.
define variable gdaDebutApplication   as date      no-undo.
define variable gdaFinApplication     as date      no-undo.
define variable gcFil                 as character no-undo.
define variable giNumeroLigne         as integer   no-undo.
define variable giNoLibNew            as integer   no-undo.        /* cas "03" avec modif libellé */

procedure lancementMajrubtm:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter piNoQuittance         as integer   no-undo.
    define input parameter piNumeroRubrique      as integer   no-undo.
    define input parameter pcTypeTraitement      as character no-undo.
    define input parameter piCodeFamille         as integer   no-undo.
    define input parameter piCodeSousFamille     as integer   no-undo.
    define input parameter piNumeroLibelle       as integer   no-undo.
    define input parameter pcLibelle             as character no-undo.
    define input parameter pcCodeGenre           as character no-undo.
    define input parameter pcSigne               as character no-undo.
    define input parameter pcCodeDetail          as character no-undo.
    define input parameter pdQuantite            as decimal   no-undo.
    define input parameter pdPrixUnitaire        as decimal   no-undo.
    define input parameter pdMontantTotalBrut    as decimal   no-undo.
    define input parameter piCodeProrata         as integer   no-undo.
    define input parameter pdNumerateurProrata   as integer   no-undo.
    define input parameter pdDenominateurProrata as integer   no-undo.
    define input parameter pdMontantQuittance    as decimal   no-undo.
    define input parameter pdaDebutApplication   as date      no-undo.
    define input parameter pdaFinApplication     as date      no-undo.
    define input parameter pcFil                 as character no-undo.
    define input parameter piNumeroLigne         as integer   no-undo.
    define input parameter piNoLibNew            as integer   no-undo.        /* cas "03" avec modif libellé */
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign
        giNumeroLocataire     = poCollectionContrat:getInteger("iNumeroContrat")
        giNumeroQuittance     = piNoQuittance
        giNumeroRubrique      = piNumeroRubrique
        gcTypeTraitement      = pcTypeTraitement
        giCodeFamille         = piCodeFamille
        giCodeSousFamille     = piCodeSousFamille
        giNumeroLibelle       = piNumeroLibelle
        gcLibelle             = pcLibelle
        gcCodeGenre           = pcCodeGenre
        gcSigne               = pcSigne
        gcCodeDetail          = pcCodeDetail
        gdQuantite            = pdQuantite
        gdPrixUnitaire        = pdPrixUnitaire
        gdMontantTotalBrut    = pdMontantTotalBrut
        giCodeProrata         = piCodeProrata
        gdNumerateurProrata   = pdNumerateurProrata
        gdDenominateurProrata = pdDenominateurProrata
        gdMontantQuittance    = pdMontantQuittance
        gdaDebutApplication   = pdaDebutApplication
        gdaFinApplication     = pdaFinApplication
        gcFil                 = pcFil
        giNumeroLigne         = piNumeroLigne
        giNoLibNew            = piNoLibNew
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()
    .
    run trtMajrubtm.
    suppressionPgmPersistent(goCollectionHandlePgm).


end procedure.

procedure trtMajrubtm private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    find first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroLocataire
          and ttQtt.iNoQuittance = giNumeroQuittance no-error.
    if not available ttQtt then do:
        mError:createError({&error}, 100802).    /* quittance absente */
        return.
    end.
    case gcTypeTraitement:
        when "01" then run prcAjoRub.            /* Creation d'une rubrique */
        when "03" then run prcModRub.            /* Modification d'une rubrique */
        when "06" then run prcSupRub.            /* Suppression d'une rubrique */
        otherwise do:
            mError:createError({&error}, 100803).      /* code action inconnu */
            return.
        end.
    end case.

end procedure.

procedure prcAjoRub private:
    /*------------------------------------------------------------------------
    Purpose : Procedure d'ajout d'une rubrique
    Notes   :
    ------------------------------------------------------------------------*/
    find first ttRub
        where ttRub.iNumeroLocataire = giNumeroLocataire
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = giNumeroRubrique
          and ttRub.iNoLibelleRubrique = giNumeroLibelle no-error.
    if available ttRub then do:
        mError:createError({&error}, 100804).      // rubrique existe deja
        return.
    end.
    if ttQtt.iNombreRubrique >= 20 then do:
        mError:createError({&error}, 110863).      // Le nombre maximum de 20 rubriques a été atteint
        return.
    end.
    assign
        ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + gdMontantQuittance
        ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
        ttQtt.cdmaj = 1
    .
    create ttRub.
    assign
        ttRub.iNumeroLocataire = giNumeroLocataire
        ttRub.iNoQuittance = giNumeroQuittance
        ttRub.iFamille = giCodeFamille
        ttRub.iSousFamille = giCodeSousFamille
        ttRub.iNorubrique = giNumeroRubrique
        ttRub.iNoLibelleRubrique = giNumeroLibelle
        ttRub.cLibelleRubrique = gcLibelle
        ttRub.cCodeGenre = gcCodeGenre
        ttRub.cCodeSigne = gcSigne
        ttRub.cddet = gcCodeDetail
        ttRub.dQuantite = gdQuantite
        ttRub.dPrixunitaire = gdPrixUnitaire
        ttRub.dMontantTotal = gdMontantTotalBrut
        ttRub.iProrata = giCodeProrata
        ttRub.iNumerateurProrata = gdNumerateurProrata
        ttRub.iDenominateurProrata = gdDenominateurProrata
        ttRub.dMontantQuittance = gdMontantQuittance
        ttRub.daDebutApplication = gdaDebutApplication
        ttRub.daFinApplication = gdaFinApplication
        ttRub.daDebutApplicationPrecedente = gcFil
        ttRub.iNoOrdreRubrique = giNumeroLigne
    .
    if ttQtt.iNoQuittance > 0 then run prcCalTax.

end procedure.

procedure prcModRub private:
    /*------------------------------------------------------------------------
    Purpose : Procedure de modification d'une rubrique
    Notes   :
    ------------------------------------------------------------------------*/
    find first ttRub
        where ttRub.iNumeroLocataire = giNumeroLocataire
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = giNumeroRubrique
          and ttRub.iNoLibelleRubrique = giNumeroLibelle no-error.           /* ancien libellé */
    if not available ttRub then do:
        mError:createError({&error}, 100808).       /* modif rubrique absente */
        return.
    end.
    if gcCodeGenre <> "00001" and gcCodeGenre <> "00003" then do:
        mError:createError({&error}, 100809).       /* Modif rubrique calcul */
        return.
    end.

    assign
        ttQtt.dMontantQuittance = ttQtt.dMontantQuittance - ttRub.dMontantQuittance + gdMontantQuittance
        ttQtt.cdmaj = 1
    .
    assign
        ttRub.iNumeroLocataire = giNumeroLocataire
        ttRub.iNoQuittance = giNumeroQuittance
        ttRub.iFamille = giCodeFamille
        ttRub.iSousFamille = giCodeSousFamille
        ttRub.iNorubrique = giNumeroRubrique
        ttRub.iNoLibelleRubrique = (if giNoLibNew <> 0 then giNoLibNew else giNumeroLibelle)   /* Modif SY le 13/12/2006 : gestion changement libellé */
        ttRub.cLibelleRubrique = gcLibelle
        ttRub.cCodeGenre = gcCodeGenre
        ttRub.cCodeSigne = gcSigne
        ttRub.cddet = gcCodeDetail
        ttRub.dQuantite = gdQuantite
        ttRub.dPrixunitaire = gdPrixUnitaire
        ttRub.dMontantTotal = gdMontantTotalBrut
        ttRub.iProrata = giCodeProrata
        ttRub.iNumerateurProrata = gdNumerateurProrata
        ttRub.iDenominateurProrata = gdDenominateurProrata
        ttRub.dMontantQuittance = gdMontantQuittance
        ttRub.daDebutApplication = gdaDebutApplication
        ttRub.daFinApplication = gdaFinApplication
        ttRub.daDebutApplicationPrecedente = gcFil
        ttRub.iNoOrdreRubrique = giNumeroLigne
    .
    if ttQtt.iNoQuittance > 0 then run prcCalTax.

end procedure.

procedure PrcSupRub private:
    /*------------------------------------------------------------------------
    Purpose : Procedure de suppression d'une rubrique
    Notes   :
    ------------------------------------------------------------------------*/
    find first ttRub
        where ttRub.iNumeroLocataire = giNumeroLocataire
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = giNumeroRubrique
          and ttRub.iNoLibelleRubrique = giNumeroLibelle no-error.
    if not available ttRub then do:
        mError:createError({&error}, 100812).              /* Supp rubrique absente */
        return.
    end.
    if gcCodeGenre <> "00001" and gcCodeGenre <> "00003" then do:
        mError:createError({&error}, 100813).               /* supp rubrique calcul */
        return.
    end.
    assign
        ttQtt.dMontantQuittance = ttQtt.dMontantQuittance - ttRub.dMontantQuittance
        ttQtt.iNombreRubrique = ttQtt.iNombreRubrique - 1
        ttQtt.cdmaj = 1
    .
    delete ttRub.
    if ttQtt.iNoQuittance > 0
    then run PrcCalTax.

end procedure.

procedure prcCalTax private:
    /*------------------------------------------------------------------------
    Purpose : Procedure de calcul des taxes
    Notes   :
    ------------------------------------------------------------------------*/
    define variable voCollectionQuittance as class collection no-undo.
    assign
        ghProc                = lancementPgm("bail/quittancement/crerubca.p", goCollectionHandlePgm)
        voCollectionQuittance = new collection()
    .
    /* Module de lancement de tous les modules de calcul d'une rubrique */
    voCollectionQuittance:set("cNatureContrat", ttQtt.cNatureBail).
    voCollectionQuittance:set("iNumeroQuittance", ttQtt.iNoQuittance).
    voCollectionQuittance:set("daDebutPeriode", ttQtt.daDebutPeriode).
    voCollectionQuittance:set("daFinPeriode", ttQtt.daFinPeriode).
    voCollectionQuittance:set("daDebutQuittancement", ttQtt.daDebutQuittancement).
    voCollectionQuittance:set("daFinQuittancement", ttQtt.daFinQuittancement).
    voCollectionQuittance:set("iCodePeriodeQuittancement", integer(substring(ttQtt.cPeriodiciteQuittancement, 1, 3, "character"))).
    voCollectionQuittance:set("lRevision", false).
    voCollectionQuittance:set("lIndexationLoyer", false).
    run lancementCrerubca in ghProc(goCollectionContrat, input-output voCollectionQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    delete object voCollectionQuittance no-error.
end procedure.
