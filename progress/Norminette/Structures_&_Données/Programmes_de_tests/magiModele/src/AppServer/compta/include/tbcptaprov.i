/*------------------------------------------------------------------------
File        : cptaprov.i
Purpose     : Comptabilisation des provisions travaux gérance
Author(s)   : OF - 2011/09/13,  gg  -  2017/04/07
Notes       : reprise include comm\cptaprov.def. Utilisé dans les programmes:
              CADB\SRC\EDIGENE\XRLVPROP.P et XVENTENC.P
              CADB\SRC\BATCH\CPTAPROV.P
              ADB\SRC\TRAV\VISDOAPP.P
----------------------------------------------------------------------*/

define temp-table ttTmpProv no-undo
    field etab-cd   as integer   format ">9"
    field nodos     as integer
    field dacompta  as date
    field datecr    as date
    field sens      as logical
    field mt        as decimal   decimals 2 format ">>>,>>>,>>>,>>9.99"
    field natjou-gi as integer   format "->>>>>>9"
    field lib-ecr   as character format "x(32)" extent 20
    field num-crg   as integer
    field cdcle     as character
    field cdenr     as character format "X(50)"
    index id1 etab-cd nodos
.
define temp-table cecrsai-tmp no-undo like cecrsai
    index primaire soc-cd etab-cd jou-cd prd-cd prd-num piece-compta  // définir un index  pour ne pas reprendre tous les index de la table
.
define temp-table cecrln-tmp no-undo like cecrln
    index primaire     soc-cd etab-cd   jou-cd prd-cd        prd-num        piece-int lig  // définir un index  pour ne pas reprendre tous les index de la table
    index ecrln-mandat soc-cd mandat-cd jou-cd mandat-prd-cd mandat-prd-num piece-int lig  // définir un index  pour ne pas reprendre tous les index de la table
.
define temp-table cecrlnana-tmp no-undo like cecrlnana
    index primaire soc-cd etab-cd jou-cd prd-cd prd-num piece-int lig pos ana-cd // définir un index  pour ne pas reprendre tous les index de la table
.
define temp-table aecrdtva-tmp no-undo like aecrdtva
    index primaire soc-cd etab-cd jou-cd prd-cd prd-num piece-int lig cdrub cdlib // définir un index  pour ne pas reprendre tous les index de la table
.
