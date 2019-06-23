/*------------------------------------------------------------------------
File        : loadNouvelleAdresse.p
Purpose     : chargement des adresses dans nouvelle table iLienAdresse et iBaseAdresse  
Description : 
Author(s)   : GGA 2018/10/16
Notes       :
----------------------------------------------------------------------*/

def var viIdentifiantFournisseur  as int64     no-undo.
def var viNumeroAdresseMaxi       as int64     no-undo.
def var viNumeroAdresse           as int64     no-undo.
def var viLienAdresseFournisseur  as integer   no-undo.
def var vcVoie                    as character no-undo.

function libparam return character (pcTypeParametre as character, pcCodeParametre as character):
    for first sys_pr no-lock
    where sys_pr.tppar = pcTypeParametre
    and sys_pr.cdpar = pcCodeParametre,
    first sys_lb no-lock
    where sys_lb.nomes = sys_pr.nome1
    and sys_lb.cdlng = 0:
        return sys_lb.lbmes.
    end.
    return "".
end function.

for each iBaseAdresse: delete iBaseAdresse. end.
for each iLienAdresse: delete iLienAdresse. end.

for each ladrs no-lock,
first adres no-lock
where adres.noadr = ladrs.noadr:

    vcVoie = if ladrs.tpfrt = "00001" 
             then "" 
                  + (if ladrs.novoi <> "0" then (string(ladrs.novoi) + " ") else "")  
                  + (if ladrs.cdadr = "00000" then "" else libparam("CDADR", ladrs.cdadr) + " ")  
                  + libparam("NTVOI", adres.ntvoi) + " " 
                  + adres.lbvoi
             else adres.lbvoi.
    find first iBaseAdresse no-lock
    where iBaseAdresse.cVoie                   = vcVoie
      and iBaseAdresse.cComplementDistribution = adres.cpvoi
      and iBaseAdresse.cCodePostal             = adres.cdpos
      and iBaseAdresse.cCodeInsee              = adres.cdins
      and iBaseAdresse.cVille                  = adres.lbvil
      and iBaseAdresse.cCodePays               = adres.cdpay no-error.
    if available iBaseAdresse
    then viNumeroAdresse = iBaseAdresse.iNumeroAdresse.
    else assign
             viNumeroAdresseMaxi = viNumeroAdresseMaxi + 1
             viNumeroAdresse     = viNumeroAdresseMaxi.
    
    viLienAdresseFournisseur = 1.
    for last iLienAdresse 
       where iLienAdresse.cTypeAdresse       = ladrs.tpadr
         and iLienAdresse.cTypeIdentifiant   = ladrs.tpidt
         and iLienAdresse.iNumeroIdentifiant = ladrs.noidt:
        viLienAdresseFournisseur = iLienAdresse.iLienAdresseFournisseur + 1.     
    end.
    
    create iLienAdresse.
    assign 
        iLienAdresse.cTypeAdresse              = ladrs.tpadr
        iLienAdresse.cTypeIdentifiant          = ladrs.tpidt        
        iLienAdresse.iNumeroIdentifiant        = ladrs.noidt
        iLienAdresse.iNumeroAdresse            = viNumeroAdresse
        iLienAdresse.iLienAdresseFournisseur   = viLienAdresseFournisseur
        iLienAdresse.cComplementDestinataire   = ""
        iLienAdresse.cComplementGeographique   = ""     

        iLienAdresse.cdcsy                   = ladrs.cdcsy
        iLienAdresse.dtcsy                   = ladrs.dtcsy
        iLienAdresse.hecsy                   = ladrs.hecsy
        iLienAdresse.cdmsy                   = ladrs.cdmsy
        iLienAdresse.dtmsy                   = ladrs.dtmsy
        iLienAdresse.hemsy                   = ladrs.hemsy        
    .    
    
    if not available iBaseAdresse
    then do:
        create iBaseAdresse.
        assign 
            iBaseAdresse.iNumeroAdresse          = viNumeroAdresse
            iBaseAdresse.cVoie                   = vcVoie
            iBaseAdresse.cComplementDistribution = adres.cpvoi
            iBaseAdresse.cCodePostal             = adres.cdpos
            iBaseAdresse.cCodeInsee              = adres.cdins
            iBaseAdresse.cVille                  = adres.lbvil
            iBaseAdresse.cCodePays               = adres.cdpay
            iBaseAdresse.dLongitude              = 0   
            iBaseAdresse.dLatitude               = 0        
            iBaseAdresse.cIdBAN                  = ""   
  
            iBaseAdresse.cdcsy                   = adres.cdcsy
            iBaseAdresse.dtcsy                   = adres.dtcsy
            iBaseAdresse.hecsy                   = adres.hecsy
            iBaseAdresse.cdmsy                   = adres.cdmsy
            iBaseAdresse.dtmsy                   = adres.dtmsy
            iBaseAdresse.hemsy                   = adres.hemsy
        .      
    end.
    
end.

for each ifour no-lock
where ifour.soc-cd = 6506:

    if length (ifour.cpt-cd) > 6 
    then do:
        message "cpt-cd trop long " ifour.four-cle "// " ifour.cpt-cd.
        next.
    end.
    viIdentifiantFournisseur = ifour.soc-cd * 1000000 + integer(ifour.cpt-cd).
     
    viNumeroAdresseMaxi = viNumeroAdresseMaxi + 1.
    create iLienAdresse.
    assign 
        iLienAdresse.cTypeAdresse              = "0"
        iLienAdresse.cTypeIdentifiant          = ifour.coll-cle     
        iLienAdresse.iNumeroIdentifiant        = viIdentifiantFournisseur
        iLienAdresse.iLienAdresseFournisseur   = 0

        iLienAdresse.iNumeroAdresse            = viNumeroAdresseMaxi
        iLienAdresse.cComplementDestinataire   = ""
        iLienAdresse.cComplementGeographique   = ""      

        iLienAdresse.cdcsy                     = ifour.cdcsy
        iLienAdresse.dtcsy                     = ifour.dtcsy
        iLienAdresse.hecsy                     = ifour.hecsy
        iLienAdresse.cdmsy                     = ifour.cdmsy
        iLienAdresse.dtmsy                     = ifour.dtmsy
        iLienAdresse.hemsy                     = ifour.hemsy

    .    
    create iBaseAdresse.
    assign 
        iBaseAdresse.iNumeroAdresse          = viNumeroAdresseMaxi
        iBaseAdresse.cVoie                   = trim(ifour.adr[1])
        iBaseAdresse.cComplementDistribution = trim(ifour.adr[2])
                                               + trim(ifour.adr[3]) 
        iBaseAdresse.cCodePostal             = ifour.cp
        iBaseAdresse.cCodeInsee              = ""
        iBaseAdresse.cVille                  = ifour.ville
        iBaseAdresse.cCodePays               = ifour.libpays-cd
        iBaseAdresse.dLongitude              = 0   
        iBaseAdresse.dLatitude               = 0        
        iBaseAdresse.cIdBAN                  = ""     

        iBaseAdresse.cdcsy                   = ifour.cdcsy
        iBaseAdresse.dtcsy                   = ifour.dtcsy
        iBaseAdresse.hecsy                   = ifour.hecsy
        iBaseAdresse.cdmsy                   = ifour.cdmsy
        iBaseAdresse.dtmsy                   = ifour.dtmsy
        iBaseAdresse.hemsy                   = ifour.hemsy

    .    
 
    for each iadrfour no-lock
       where iadrfour.soc-cd   = ifour.soc-cd
         and iadrfour.four-cle = ifour.four-cle:
        viNumeroAdresseMaxi = viNumeroAdresseMaxi + 1.
        create iLienAdresse.
        assign 
            iLienAdresse.cTypeAdresse              = string(iadrfour.libadr-cd)
            iLienAdresse.cTypeIdentifiant          = ifour.coll-cle     
            iLienAdresse.iNumeroIdentifiant        = viIdentifiantFournisseur
            iLienAdresse.iLienAdresseFournisseur   = iadrfour.adr-cd

            iLienAdresse.iNumeroAdresse            = viNumeroAdresseMaxi
            iLienAdresse.cComplementDestinataire   = ""
            iLienAdresse.cComplementGeographique   = ""     
 
            iLienAdresse.cdcsy                     = iadrfour.cdcsy
            iLienAdresse.dtcsy                     = iadrfour.dtcsy
            iLienAdresse.hecsy                     = iadrfour.hecsy
            iLienAdresse.cdmsy                     = iadrfour.cdmsy
            iLienAdresse.dtmsy                     = iadrfour.dtmsy
            iLienAdresse.hemsy                     = iadrfour.hemsy      
        .    
        create iBaseAdresse.
        assign 
            iBaseAdresse.iNumeroAdresse          = viNumeroAdresseMaxi
            iBaseAdresse.cVoie                   = trim(iadrfour.adr[1])
            iBaseAdresse.cComplementDistribution = trim(iadrfour.adr[2])
                                                   + trim(iadrfour.adr[3]) 
            iBaseAdresse.cCodePostal             = iadrfour.cp
            iBaseAdresse.cCodeInsee              = ""
            iBaseAdresse.cVille                  = iadrfour.ville
            iBaseAdresse.cCodePays               = iadrfour.libpays-cd
            iBaseAdresse.dLongitude              = 0   
            iBaseAdresse.dLatitude               = 0        
            iBaseAdresse.cIdBAN                  = ""       

            iBaseAdresse.cdcsy                   = iadrfour.cdcsy
            iBaseAdresse.dtcsy                   = iadrfour.dtcsy
            iBaseAdresse.hecsy                   = iadrfour.hecsy
            iBaseAdresse.cdmsy                   = iadrfour.cdmsy
            iBaseAdresse.dtmsy                   = iadrfour.dtmsy
            iBaseAdresse.hemsy                   = iadrfour.hemsy
        .    
    end.
 
    for each icontacf no-lock
       where icontacf.soc-cd   = ifour.soc-cd
         and icontacf.four-cle = ifour.four-cle:
        viNumeroAdresseMaxi = viNumeroAdresseMaxi + 1.
        create iLienAdresse.
        assign 
            iLienAdresse.cTypeAdresse              = "contactF"
            iLienAdresse.cTypeIdentifiant          = ifour.coll-cle     
            iLienAdresse.iNumeroIdentifiant        = viIdentifiantFournisseur
            iLienAdresse.iLienAdresseFournisseur   = icontacf.numero

            iLienAdresse.iNumeroAdresse            = viNumeroAdresseMaxi
            iLienAdresse.cComplementDestinataire   = ""
            iLienAdresse.cComplementGeographique   = ""    
  
            iLienAdresse.cdcsy                     = icontacf.cdcsy
            iLienAdresse.dtcsy                     = icontacf.dtcsy
            iLienAdresse.hecsy                     = icontacf.hecsy
            iLienAdresse.cdmsy                     = icontacf.cdmsy
            iLienAdresse.dtmsy                     = icontacf.dtmsy
            iLienAdresse.hemsy                     = icontacf.hemsy                       
        .    
        create iBaseAdresse.
        assign 
            iBaseAdresse.iNumeroAdresse          = viNumeroAdresseMaxi
            iBaseAdresse.cVoie                   = trim(icontacf.adr[1])
            iBaseAdresse.cComplementDistribution = trim(icontacf.adr[2])
                                                   + trim(icontacf.adr[3]) 
            iBaseAdresse.cCodePostal             = icontacf.cp
            iBaseAdresse.cCodeInsee              = ""
            iBaseAdresse.cVille                  = icontacf.ville
            iBaseAdresse.cCodePays               = icontacf.libpays-cd
            iBaseAdresse.dLongitude              = 0   
            iBaseAdresse.dLatitude               = 0        
            iBaseAdresse.cIdBAN                  = ""       

            iBaseAdresse.cdcsy                   = icontacf.cdcsy
            iBaseAdresse.dtcsy                   = icontacf.dtcsy
            iBaseAdresse.hecsy                   = icontacf.hecsy
            iBaseAdresse.cdmsy                   = icontacf.cdmsy
            iBaseAdresse.dtmsy                   = icontacf.dtmsy
            iBaseAdresse.hemsy                   = icontacf.hemsy           
        .    
    end.
 
end.
