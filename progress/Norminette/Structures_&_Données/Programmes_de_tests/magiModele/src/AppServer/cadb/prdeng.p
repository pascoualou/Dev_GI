// todo  PhM  à reprendre
/*-----------------------------------------------------------------------------
File        : prdeng.p
Purpose     : Recherche de la periode des charges en cours
Author(s)   : OF - 1997/06/12, Kantena - 2018/01/11
Notes       : reprise cadb/src/gene/prdeng.p
01  22/04/1998  CD    extraction de la date
-----------------------------------------------------------------------------*/
define input  parameter piCodeSociete   as integer  no-undo.
define input  parameter piNumeroMandat  as integer  no-undo.
define input  parameter pdaReference    as date     no-undo.
define output parameter piRetour        as integer  no-undo.
define output parameter pdaDebutPeriode as date     no-undo.
define output parameter pdaFinPeriode   as date     no-undo.

define variable vcListePeriode as character no-undo.
define variable vcRetour       as character no-undo.
define variable viCompteur     as integer   no-undo.
define variable viDate         as integer   no-undo.
define variable vcItem         as character no-undo.

viDate = year(pdaReference) * 100 + month(pdaReference).
find first ietab no-lock
    where ietab.soc-cd  = piCodeSociete
      and ietab.etab-cd = piNumeroMandat no-error.
if available ietab and (ietab.profil-cd = 20 or ietab.profil-cd = 21)
then do:                                                               /* Cas Gerance */
    run mandat/commun/chargementPeriodesMandat.p(
        piCodeSociete,
        piNumeroMandat,
        viDate,
        "",
        output vcRetour,
        output vcListePeriode
    ).
    if vcRetour = "000" then assign
        /*** CD le 22/04/98 extraction des dates Mois,jour,annee ***/
        vcItem          = entry(1, vcListePeriode, "@")
        pdaDebutPeriode = date(integer(substring(vcItem, 3, 2, "character")),  /** Mois  **/
                               integer(substring(vcItem, 1, 2, "character")),  /** jour  **/
                               integer(substring(vcItem, 5, 4, "character")) ) /** Annee **/
        vcItem          = entry(2, vcListePeriode, "@")
        pdaFinPeriode   = date(integer(substring(vcItem, 3, 2, "character")),  /** Mois  **/
                               integer(substring(vcItem, 1, 2, "character")),  /** jour  **/
                               integer(substring(vcItem, 5, 4, "character")) ) /** Annee **/
        piRetour        = 1
    .
    else assign
        pdaDebutPeriode = ?
        pdaFinPeriode   = ?
        piRetour        = 1
    .
end.
else do:                                                               /* Cas Copropriete */
    run mandat/commun/chargementPeriodesMandat.p(
        piCodeSociete,
        piNumeroMandat,
        viDate,
        "T",
        output vcRetour,
        output vcListePeriode
    ).
    if vcRetour = "000" then do viCompteur = 1 to num-entries(vcListePeriode, "|"):
        assign
            vcItem          = entry(viCompteur, vcListePeriode, "|")
            pdaDebutPeriode = date(entry(2, vcItem, "@"))
            pdaFinPeriode   = date(entry(3, vcItem, "@"))
            piRetour        = integer(entry(4, vcItem, "@"))
        .
        if pdaFinPeriode >= pdaReference then leave.
    end.
    else assign
        pdaDebutPeriode = ?
        pdaFinPeriode   = ?
        piRetour        = 1
    .
end.
