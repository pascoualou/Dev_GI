/*------------------------------------------------------------------------
File        : outilColocation.p
Purpose     : procédures et fonctions liées à la colocation
Created     : 08/04/2013 PL / 2018/06/07 GGA
Notes       : ancien include comm/coloc.i
              pour le moment reprise seulement des fonctions ou procedure utiles
derniere revue: 2018/08/16 - phm: 

 0001   13/11/2013  PL  1113/0064 Gestion de la colocation(modifs)  
 0002   03/12/2013  PL  Pb valeur param reprise de solde  
 0003   24/12/2013  SY  Rédution Mlog : traces que si lcolocation 
 0007   23/04/2014  PL  1008/0163 : Différences edition SC/Local 
 0008   24/02/2017  SY  0217/0183 Ajout DO TRANS sur create coloc 
 0009   16/08/2017  SY  #5895 Optimisation temps (Mlog déplacé)
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

function IsColocation returns logical(pcTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : ancienne procedure transforme en fonction
    ------------------------------------------------------------------------------*/
    define buffer tache for tache.
    for first tache no-lock 
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-Colocation}:
        if tache.tpges = "00001"
        then return true.
    end.
    return false.
     
end function.    
