/*------------------------------------------------------------------------
File        : ttEdition.i
Purpose     : Table temporaire qui contient toutes les informations a editer
Author(s)   : Kantena  -  2017/12/15
Notes       : reprise de adb/comm/tbtmpedt.i
------------------------------------------------------------------------*/
define temp-table ttEdition no-undo
   field Classe    as character format "X(250)"
   field Reference as character format "X(250)"
   field Ligne     as character format "X(500)"
//   index TbEdt-i Class
.
/*
define {1} shared variable ChNomImp as character no-undo.
define {1} shared variable InNbrCop as integer   no-undo.

define {1} shared variable ChEspDeb as character no-undo.
define {1} shared variable ChEspFin as character no-undo.
define {1} shared variable ChTmpIni as character no-undo.
define {1} shared variable ChTmp6lp as character no-undo.
define {1} shared variable ChTmp8lp as character no-undo.
define {1} shared variable ChTmpDeb as character no-undo.
define {1} shared variable ChTmpFin as character no-undo.
define {1} shared variable ChSauLig as character no-undo.
define {1} shared variable ChSauPag as character no-undo.
define {1} shared variable ChHauGau as character no-undo.
define {1} shared variable ChTrtHon as character no-undo.
define {1} shared variable ChIntHau as character no-undo.
define {1} shared variable ChHauDrt as character no-undo.
define {1} shared variable ChTrtVer as character no-undo.
define {1} shared variable ChIntGau as character no-undo.
define {1} shared variable ChTmpCrx as character no-undo.
define {1} shared variable ChIntDrt as character no-undo.
define {1} shared variable ChBasGau as character no-undo.
define {1} shared variable ChIntBas as character no-undo.
define {1} shared variable ChBasDrt as character no-undo.
define {1} shared variable ChFnt001 as character no-undo.
define {1} shared variable ChFnt002 as character no-undo.
define {1} shared variable ChFnt003 as character no-undo.
define {1} shared variable ChFnt005 as character no-undo.
define {1} shared variable ChFnt007 as character no-undo.
define {1} shared variable ChFnt014 as character no-undo.
define {1} shared variable ChFnt015 as character no-undo.
define {1} shared variable ChFnt016 as character no-undo.
define {1} shared variable ChFnt020 as character no-undo.
define {1} shared variable ChFnt021 as character no-undo.
define {1} shared variable ChFnt022 as character no-undo.
define {1} shared variable ChFnt023 as character no-undo.
define {1} shared variable ChFnt024 as character no-undo.
define {1} shared variable ChFnt025 as character no-undo.
define {1} shared variable ChFnt026 as character no-undo.
define {1} shared variable ChFnt027 as character no-undo.
define {1} shared variable ChFnt028 as character no-undo.
define {1} shared variable ChFnt029 as character no-undo.
define {1} shared variable ChFnt030 as character no-undo.
define {1} shared variable ChFnt031 as character no-undo.
define {1} shared variable ChFnt032 as character no-undo.
define {1} shared variable ChFnt033 as character no-undo.
define {1} shared variable ChFnt034 as character no-undo.
define {1} shared variable ChFnt035 as character no-undo.
define {1} shared variable ChFnt036 as character no-undo.
define {1} shared variable ChFnt037 as character no-undo.
define            variable InNumTit as integer   no-undo.
*/
