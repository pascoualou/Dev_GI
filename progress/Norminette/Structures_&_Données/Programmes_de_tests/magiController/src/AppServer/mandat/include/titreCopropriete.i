/*------------------------------------------------------------------------
File        : periodeChargesCopro.i
Purpose     : 
Author(s)   : OFA  -  2019/01/07
Notes       : Table TbPecCop dans chgmdtsy.p découpée en 2 tables temporaires
derniere revue: 2019/01/25 npo ok
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTitreCopropriete
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroMandat                    as int64     initial ? //TbPecCop.Nosyn
    field iNumeroCoproprietaire            as integer   initial ? //TbPecCop.Nocop
    field cTypeRoleDestinataireTraitement  as character initial ? //TbPecCop.dest-trt
    field cLibRoleDestinataireTraitement   as character initial ?
    field cTypeRoleDestinataireAG          as character initial ? //TbPecCop.dest-AG
    field cLibelleRoleDestinataireAG       as character initial ?
    field lExemplairesSupplemCopro         as logical   initial ? //TbPecCop.cdexcop
    field lExemplairesSupplemMandataire    as logical   initial ? //TbPecCop.cdexman
    field lExemplairesSupplemGerant        as logical   initial ? //TbPecCop.cdexger
    field cEnvoiGardienAgence              as character initial ? //TbPecCop.cdtri

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

define temp-table ttIntervenantsTitreCopropriete no-undo
    field iNumeroMandat                    as int64     initial ? //TbPecCop.Nosyn
    field iNumeroCoproprietaire            as integer   initial ? //TbPecCop.Nocop
    field cTypeRoleIntervenant             as character initial ? //TbPecCop.tprol
    field iNumeroRoleIntervenant           as integer   initial ? //TbPecCop.norol
    field iTantiemeIndivisaire             as integer   initial ? //TbPecCop.ttind
    field iBaseIndivisaire                 as integer   initial ? //TbPecCop.deind
    field iNumeroTiersIntervenant          as integer   initial ? //TbPecCop.notie
    field cLibelleRoleIntervenant          as character initial ? //TbPecCop.lbrol
    field cNomRoleIntervenant              as character initial ? //TbPecCop.nmrol
    field cCodeExemplaireAdFIndivis        as character initial ? //TbPecCop.edapf
    field cLibelleExemplaireAdFIndivis     as character initial ? //TbPecCop.lbapf
    field cCodeExemplaireChargesIndivis    as character initial ? //TbPecCop.decom
    field cLibelleExemplaireChargesIndivis as character initial ? //TbPecCop.lbDec
    field cTypeServiceGestion              as character initial ? //TbPecCop.CabAg
    field iCodeServiceGestion              as integer   initial ? //TbPecCop.NoAge
    field cLibelleServiceGestion           as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
