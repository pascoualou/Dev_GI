/*------------------------------------------------------------------------
File        : methodConversionDate.i
Description : 
Author(s)   : Kantena - 2017/05/09 
Notes       :
derniere revue: 2018/03/23 - phm
------------------------------------------------------------------------*/

    method public static date conversionDate(pcFormatDate as character, pcDateIn as character): 
        /*------------------------------------------------------------------------------
        Purpose: transforme un format date en dmy. On accepte d, dd; m,mm; y, yy, yyyy.
        Notes  : slashes(/), periods(.), and hyphens(-) are accepted as separator
        ------------------------------------------------------------------------------*/
        define variable vdaOut   as date      no-undo.
        define variable vcFormat as character no-undo.

        assign
            pcFormatDate = replace(pcFormatDate, '/', '')
            pcFormatDate = replace(pcFormatDate, '.', '')
            pcFormatDate = replace(pcFormatDate, '-', '')
            pcFormatDate = replace(pcFormatDate, 'dd', 'd')
            pcFormatDate = replace(pcFormatDate, 'mm', 'm')
            pcFormatDate = replace(pcFormatDate, 'yy', 'y')
            pcFormatDate = replace(pcFormatDate, 'yy', 'y')
            pcFormatDate = replace(pcFormatDate, 'yy', 'y')
        .
        if pcFormatDate <> session:date-format and can-do('mdy,myd,ymd,ydm,myd,mdy', pcFormatDate)
        then do:
            assign
                vcFormat            = session:date-format
                session:date-format = pcFormatDate
                vdaOut              = date(pcDateIn)
             no-error.
             session:date-format = vcFormat.
        end.
        else vdaOut = date(pcDateIn) no-error.
        return vdaOut.

    end method.
    
    method public static integer DateToInteger(pdaDate as date): 
        /*------------------------------------------------------------------------------
        Purpose: transforme un format date en dmy. On accepte d, dd; m,mm; y, yy, yyyy.
        Notes  : slashes(/), periods(.), and hyphens(-) are accepted as separator
        ------------------------------------------------------------------------------*/
        if pdaDate = ? 
        then return 0.
        else return year(pdaDate) * 10000 + month(pdaDate) * 100 + day(pdaDate).
       
    end method.
    
    method public static date IntegerToDate(piDate as integer): 
        /*------------------------------------------------------------------------------
        Purpose: transforme un format date en dmy. On accepte d, dd; m,mm; y, yy, yyyy.
        Notes  : slashes(/), periods(.), and hyphens(-) are accepted as separator
        ------------------------------------------------------------------------------*/        
        define variable vdaDateOut as date no-undo.
        
        vdaDateOut = date(integer(truncate((piDate modulo 10000) / 100, 0)),
                         integer(piDate modulo 100),
                         integer(truncate(piDate / 10000, 0))) no-error. 
        if error-status:error then do:
            error-status:error = false no-error.
            return ?.
        end.
        return vdaDateOut.

    end method.
