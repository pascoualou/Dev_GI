/*------------------------------------------------------------------------
File        : XPAMOD.i
Purpose     : Paramétrage des modules de calcul de la Paie (IBM)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttXpamod
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field analytique as integer    initial ? 
    field cdbul      as character  initial ? 
    field cdconf     as character  initial ? 
    field cdcpta     as character  initial ? 
    field cdcsy      as character  initial ? 
    field cdliv1     as character  initial ? 
    field cdliv2     as character  initial ? 
    field cdliv3     as character  initial ? 
    field cdliv4     as character  initial ? 
    field cdmsy      as character  initial ? 
    field cdnat      as character  initial ? 
    field cdop1      as character  initial ? 
    field cdop2      as character  initial ? 
    field cdop3      as character  initial ? 
    field cdop4      as character  initial ? 
    field cdsig      as character  initial ? 
    field compteur1  as integer    initial ? 
    field compteur2  as integer    initial ? 
    field compteur3  as integer    initial ? 
    field dtcsy      as date       initial ? 
    field dtmsy      as date       initial ? 
    field filler     as character  initial ? 
    field filler2    as character  initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field hiscar     as integer    initial ? 
    field histo      as character  initial ? 
    field lbdiv      as character  initial ? 
    field libcrt     as character  initial ? 
    field liblng     as character  initial ? 
    field modul      as character  initial ? 
    field nbdec      as integer    initial ? 
    field nolig      as integer    initial ? 
    field nouti      as integer    initial ? 
    field op1mod     as character  initial ? 
    field op2mod     as character  initial ? 
    field op3mod     as character  initial ? 
    field op4mod     as character  initial ? 
    field optana     as character  initial ? 
    field valeur     as decimal    initial ?  decimals 2
    field valmax     as decimal    initial ?  decimals 2
    field valmin     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
