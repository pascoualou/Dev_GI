/*------------------------------------------------------------------------
File        : glbsepar2.i
Purpose     : assignation des valeurs du séparateur selon le code page.
Author(s)   : kantena - 2016/08/16
Notes       :
derniere revue: 2018/05/03 - phm: OK
------------------------------------------------------------------------*/
    case session:cpinternal:
        when 'iso8859-1' then assign 
            separ[1] = chr(164) // chr(49828)  "¤"
            separ[2] = chr(177) // chr(49841)  "±"
            separ[3] = chr(197) //             "Å"
            separ[4] = chr(165) //             "¥"
            separ[5] = chr(186) //             "º"
        .
        when 'utf-8' then assign 
            separ[1] = chr(49828)  // chr(164) 
            separ[2] = chr(49841)  // chr(177)  
            separ[3] = chr(197)
            separ[4] = chr(165)
            separ[5] = chr(186)
        .
    end case.
