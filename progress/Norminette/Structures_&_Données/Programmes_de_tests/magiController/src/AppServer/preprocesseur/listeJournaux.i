/*------------------------------------------------------------------------
File        : listeJournaux.i
Purpose     : Variables préprocesseur des listes de journaux
Author(s)   : Kantena - 2016/09/12
Notes       : remplace comm/commun.i}, comm/gerance.i, comm/copro.i
commun:  ODT, PP, A, OD, SAL, AN, PPEC , ANC , RELEC, IR (47) et RLC (48), nature GI 5,
         journal ODSAL de nature GI 57 pour les OD SALAIRES
gerance: ASSU, HONO, HL, ODSG , ASSOD , HONOD , CLOC , CLEC , FLEC, 56 (ODEC)
         frais de relance nature GI 48, AFTX nature 65 + AFTXA nature 67
copro:   AFB, AFBA, AFBS, AFBH, AFRL, AFRS, AFTR, AFTRA, CP, CPS, ODSC, CCEC, 68 AFC et 69 AFCA
         AEXT (Nature Gi 73), AFTX 65, HONO (80), frais de relance nature GI 48 
------------------------------------------------------------------------*/

&GLOBAL-DEFINE JOURNAUX-commun  "46,30,40,43,92,99,93,97,47,48,55,57"
&GLOBAL-DEFINE JOURNAUX-gerance "41,44,80,81,82,90,45,94,98,56,65,67"
&GLOBAL-DEFINE JOURNAUX-copro   "50,51,52,60,62,63,64,66,68,69,70,71,73,80,91,96,65"
