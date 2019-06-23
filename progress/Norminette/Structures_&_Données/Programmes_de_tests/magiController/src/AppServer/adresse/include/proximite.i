/*------------------------------------------------------------------------
File        : proximite.i
Purpose     : Table associée à gl_fiche_proximite, relative aux adresses
Author(s)   : KANTENA - 2016/08/11
Notes       :
derniere revue: 2018/05/22 - phm: KO
        pourquoi pas le champ rRowid? pourquoi les champs dtTimestamp, CRUD?
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttProximite
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroProximite      as integer   initial ? label 'noproximite'
    field iNumeroFiche          as integer   initial ? label 'nofiche'
    field iTypeProximite        as integer   initial ?
    field cCodeTypeProximite    as character initial ?
    field cLibelleTypeProximite as character initial ?
    field iNumeroLibelle        as integer   initial ?              // = gl_proximite.nomes = gl_libelle.nolibelle
    field cLibelleProximite     as character initial ?

    field dtTimestamp           as datetime
    field CRUD                  as character
.
