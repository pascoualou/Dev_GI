/*------------------------------------------------------------------------
File        : cnummvt.i
Purpose     : include utilisé par Avis de domiciliation le 31/07/1996
              include utilisé par Fin d'exercice le 09/08/1996
              Numerotation & Mouvement dans les comptes recno-sai doit etre renseigne = recid(cecrsai)
              JR le 08/09/2003 0903/0059 : Gestion du situ
Author(s)   : gga -  2017/06/23
Notes       : reprise include cadb\src\batch\cnummvt.i
              mais creation d'une procedure cnummvt
----------------------------------------------------------------------*/

procedure cnummvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter prRecnoSai as rowid no-undo.

    define buffer cecrsai  for cecrsai.
    define buffer cnumpiec for cnumpiec.
    define buffer ijou     for ijou.
    define buffer iprd     for iprd.
    
    define variable vhProc as handle no-undo. 

message "gga debut cnummvt".

    find first cecrsai no-lock
        where rowid(cecrsai) = prRecnoSai no-error.
    if available cecrsai then do:

message "gga cnummvt " cecrsai.situ.

        if cecrsai.situ = ? or cecrsai.situ = false
        then do:
            {&_proparse_ prolint-nowarn(nowait)}
            find current cecrsai exclusive-lock no-error.
            find first ijou no-lock
                where ijou.soc-cd  = cecrsai.soc-cd
                  and ijou.etab-cd = cecrsai.etab-cd
                  and ijou.jou-cd  = cecrsai.jou-cd no-error.
            /* Recherche du numero de piece compta selon soc-cd etab-cd jou-cd prd-cd prd-num */
            if cecrsai.situ = ? and available ijou and ijou.numpiec = false
            then for first cnumpiec exclusive-lock
                where cnumpiec.soc-cd  = cecrsai.soc-cd
                  and cnumpiec.etab-cd = cecrsai.etab-cd
                  and cnumpiec.jou-cd  = cecrsai.jou-cd
                  and cnumpiec.prd-cd  = cecrsai.prd-cd
                  and cnumpiec.prd-num = cecrsai.prd-num:
                assign
                    cecrsai.piece-compta  = cnumpiec.piece-compta + 1
                    cnumpiec.piece-compta = cecrsai.piece-compta
                .
            end.
            /* Set the situation depending on journal Definitiv = true/ Provisoire = false */
            if (cecrsai.situ = ? or cecrsai.situ = false) and available ijou then cecrsai.situ = ijou.valecr.    /* Situation du journal */
            for first iprd exclusive-lock
                where iprd.soc-cd   = cecrsai.soc-cd
                  and iprd.etab-cd  = cecrsai.etab-cd
                  and iprd.prd-cd   = cecrsai.prd-cd
                  and iprd.prd-num  = cecrsai.prd-num:
                iprd.mvt = true.
            end.
        end.
        /* Mouvements dans les compte generaux, individuels et cumuls */
        run compta/souspgm/cptmvtgi.p persistent set vhProc.
        run getTokenInstance    in vhProc(mToken:JSessionId).
        run cptmvtgiMajBalDispo in vhProc (prRecnoSai).        
        run destroy in vhProc.
    end.

end procedure.
