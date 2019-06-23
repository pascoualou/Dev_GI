/*------------------------------------------------------------------------
File        : fctdacpt.i
Purpose     : Fonction pour la date comptable des Avis d'échéance du Quittancement
Author(s)   : SY 14/11/2013  -  GGA 2018/09/04 
Notes       : a partir de comm/fctdacpt.i
              Fiche : 1013/0167 
------------------------------------------------------------------------*/
{preprocesseur/codeRubrique.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/param2locataire.i}

function f_donnedacomptaqtt returns date(piMoisQuittancement as integer, pcCodeTerme as character, plComptaEchuMoisPrecedent as logical):
    /*------------------------------------------------------------------------------
    Purpose: Date comptable pour une quittance selon mois de quitt, Avance ou Echu et Param cabinet
              <comptabilisation des echus dans le mois précédent> Locataire OU Fournisseur de loyer
    Notes  : vient de comm/fctdacpt.i
    -------------------------------------------------------------------------------*/
    define variable vdaComptable as date     no-undo.
    define variable viAnnee      as integer  no-undo.
    define variable viMois       as integer  no-undo.

    assign
        viAnnee      = truncate(piMoisQuittancement / 100, 0)
        viMois       = piMoisQuittancement modulo 100
        vdaComptable = date(viMois, 01, viAnnee)
    .
    if pcCodeTerme = {&TERMEQUITTANCEMENT-echu} and plComptaEchuMoisPrecedent then vdaComptable = vdaComptable - 1.
    return vdaComptable.
end function.
