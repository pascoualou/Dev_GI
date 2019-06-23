/*------------------------------------------------------------------------
File        : parelan.i
Purpose     : Parametrage des relances
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParelan
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field catbx            as character  initial ? 
    field cdsigna01        as character  initial ? 
    field cdsigna02        as character  initial ? 
    field coll-cle         as character  initial ? 
    field coll-sauf        as character  initial ? 
    field contact-num      as integer    initial ? 
    field date-interet     as logical    initial ? 
    field dev-cd           as character  initial ? 
    field divers           as character  initial ? 
    field etab-cd          as integer    initial ? 
    field fdate            as character  initial ? 
    field fg-anterio       as logical    initial ? 
    field fg-autper        as logical    initial ? 
    field fg-autregl       as logical    initial ? 
    field fg-bloq          as logical    initial ? 
    field fg-bloqnon       as logical    initial ? 
    field fg-chqptf        as logical    initial ? 
    field fg-coloc         as logical    initial ? 
    field fg-cptbloq       as logical    initial ? 
    field fg-cptbloqnon    as logical    initial ? 
    field fg-credit        as logical    initial ? 
    field fg-cum           as logical    initial ? 
    field fg-datanni       as logical    initial ? 
    field fg-debit         as logical    initial ? 
    field fg-detquit       as logical    initial ? 
    field fg-devedt        as logical    initial ? 
    field fg-devtiers      as logical    initial ? 
    field fg-effets        as logical    initial ? 
    field fg-frais         as logical    initial ? 
    field fg-garant        as logical    initial ? 
    field fg-gtie          as logical    initial ? 
    field fg-gtiesans      as logical    initial ? 
    field fg-interets      as logical    initial ? 
    field fg-locat         as logical    initial ? 
    field fg-locmens       as logical    initial ? 
    field fg-NomProp       as logical    initial ? 
    field fg-notes         as logical    initial ? 
    field fg-prel          as logical    initial ? 
    field fg-prep          as logical    initial ? 
    field fg-prop          as logical    initial ? 
    field fg-RaisSoc       as logical    initial ? 
    field fg-recquit       as logical    initial ? 
    field fg-resil         as logical    initial ? 
    field fg-resilnon      as logical    initial ? 
    field fg-SoldChrg      as logical    initial ? 
    field fg-taux          as logical    initial ? 
    field fg-tel           as logical    initial ? 
    field fgtie            as logical    initial ? 
    field flag-sens        as character  initial ? 
    field flag-tel         as logical    initial ? 
    field lib              as character  initial ? 
    field libcli-cd        as integer    initial ? 
    field libstatut-cd     as integer    initial ? 
    field mt-CoefMax       as decimal    initial ?  decimals 2
    field mt-CoefMin       as decimal    initial ?  decimals 2
    field mt-frais         as decimal    initial ?  decimals 2
    field mt-frais-EURO    as decimal    initial ?  decimals 2
    field mt-min           as decimal    initial ?  decimals 2
    field mt-min-EURO      as decimal    initial ?  decimals 2
    field mtmax            as decimal    initial ?  decimals 2
    field mtmin            as decimal    initial ?  decimals 2
    field nbex             as integer    initial ? 
    field nbfact           as integer    initial ? 
    field noact            as character  initial ? 
    field piece-bloquee    as logical    initial ? 
    field recommande       as logical    initial ? 
    field relan-niv        as integer    initial ? 
    field relance-cd       as integer    initial ? 
    field retard           as integer    initial ? 
    field soc-cd           as integer    initial ? 
    field taux-frais       as decimal    initial ?  decimals 2
    field taux-interet     as decimal    initial ?  decimals 2
    field texte-entete     as character  initial ? 
    field texte-pied       as character  initial ? 
    field texte-signataire as character  initial ? 
    field texte2-entete    as character  initial ? 
    field titre-relance    as character  initial ? 
    field tri              as character  initial ? 
    field type-interet     as logical    initial ? 
    field type-recommande  as logical    initial ? 
    field type-relance     as logical    initial ? 
    field type-retard      as logical    initial ? 
    field type-texte       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
