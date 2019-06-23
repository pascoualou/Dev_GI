/*------------------------------------------------------------------------
File        : majRefacDepense.p
Purpose     : Moulinette de formatage du numero de contrat sur 10 caractères (tbdet.iden1)
Author(s)   : DM 15/12/2017
Notes       : 
------------------------------------------------------------------------*/
for each tbdet 
    where tbdet.cdent begins "REFAC-01030" TRANS :
    tbdet.iden1 = string(int64(tbdet.iden1),"9999999999").
end.
for each tbdet 
    where tbdet.cdent begins "REFAC-01033" TRANS :
    tbdet.iden1 = string(int64(tbdet.iden1),"9999999999").
end.


