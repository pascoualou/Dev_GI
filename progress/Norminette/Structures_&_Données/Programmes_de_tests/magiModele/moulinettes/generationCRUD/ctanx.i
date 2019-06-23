/*------------------------------------------------------------------------
File        : ctanx.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtanx
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bicod     as character  initial ? 
    field cdape     as character  initial ? 
    field cdbqu     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdgui     as character  initial ? 
    field cdjur     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdnic     as character  initial ? 
    field cdobj     as character  initial ? 
    field cdreg     as character  initial ? 
    field cdsie     as character  initial ? 
    field cptbq     as integer    initial ? 
    field cptetr    as character  initial ? 
    field cSIREN    as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtder-sep as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtree     as date       initial ? 
    field dtree-sep as date       initial ? 
    field dtsig     as date       initial ? 
    field dtsig-sep as date       initial ? 
    field duree     as integer    initial ? 
    field fgetr     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field iban      as character  initial ? 
    field ics       as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbdiv4    as character  initial ? 
    field lbdiv5    as character  initial ? 
    field lbdiv6    as character  initial ? 
    field lbdom     as character  initial ? 
    field lbprf     as character  initial ? 
    field lbreg     as character  initial ? 
    field lbtit     as character  initial ? 
    field Liexe     as character  initial ? 
    field lisig     as character  initial ? 
    field lnnot     as character  initial ? 
    field mtcap     as character  initial ? 
    field mtcau     as decimal    initial ?  decimals 2
    field mtcau-dev as decimal    initial ?  decimals 2
    field nbres     as integer    initial ? 
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field nocpt     as character  initial ? 
    field nodoc     as int64      initial ? 
    field noree     as integer    initial ? 
    field noref     as integer    initial ? 
    field norib     as integer    initial ? 
    field norol     as integer    initial ? 
    field norol-dec as decimal    initial ?  decimals 0
    field norum-anc as character  initial ? 
    field norum-cop as character  initial ? 
    field norum-ger as character  initial ? 
    field nosir     as integer    initial ? 
    field ntcau     as character  initial ? 
    field pcpte     as integer    initial ? 
    field scpte     as integer    initial ? 
    field smnda     as logical    initial ? 
    field tpact     as character  initial ? 
    field tpbqu     as character  initial ? 
    field tpcon     as character  initial ? 
    field tpfin     as character  initial ? 
    field tpren     as character  initial ? 
    field tprol     as character  initial ? 
    field tpuni     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
