/*------------------------------------------------------------------------
File        : cdpaycab.i
Purpose     : recherche Code pays du Cabinet (Gérance par défaut)
Author(s)   : JR - 2003/10/30     GGA - 2017/11/29
Notes       : reprise include adb\comm\cdpaycab.i
derniere revue: 2018/04/27 - phm: KO
           traiter les todo
----------------------------------------------------------------------*/
{preprocesseur/type2role.i}

function getPaysCabinet returns character private():
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : ex procédure rechPaysCabinet
    ------------------------------------------------------------------------------*/
    define buffer vbroles  for roles.
    define buffer vb2roles for roles.
    define buffer adres    for adres.
    define buffer ladrs    for ladrs.
    define buffer vbLadrs  for ladrs.

// todo  commentaire "gérant", utilisé "mandataire" ???
// todo  faut-il imbriquer les 2 for first vbroles??? ou d'abord rechercher {&TYPEROLE-mandataire}, puis {&TYPEROLE-syndic2copro} sinon???
    for first vbroles no-lock                         /* Gerant */ 
        where vbroles.tprol = {&TYPEROLE-mandataire}
          and vbroles.norol = 1
      , first ladrs no-lock 
        where ladrs.tpidt = vbroles.tprol 
          and ladrs.noidt = vbroles.norol:
        find first adres no-lock 
             where adres.noadr = ladrs.noadr no-error.
        if available adres then return adres.cdpay.

        for first vb2roles no-lock                /* Syndic de copro */ 
            where vb2roles.tprol = {&TYPEROLE-syndic2copro}
              and vb2roles.norol = 1
          , first vbLadrs no-lock  
            where vbLadrs.tpidt = vb2roles.tprol 
              and vbLadrs.noidt = vb2roles.norol
          , first adres no-lock
            where adres.noadr = vbLadrs.noadr:
            return adres.cdpay.
        end.
    end.
    return "".
end function.
