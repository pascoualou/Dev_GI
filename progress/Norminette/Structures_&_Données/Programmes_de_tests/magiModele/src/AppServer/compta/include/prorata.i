/*------------------------------------------------------------------------
File        : prorata.i
Purpose     : Pour partager la procédure 'prorata' entre :
                apatcx.p : transfert , annulation des appels de fonds
                fareplst.w : Visualisation de la ventilation des appels de fonds par lot
Author(s)   : JR - 2010/05/12;   gga  -  2017/04/07
Notes       : reprise include comm\prorata.i

| 0001 | 20/11/2012 |  SY  | 1112/0068 Pour la cloture travaux, on ne doit pas annuler les appels de fonds Emprunts, Subvention ou indemnité assurance
| 0002 | 22/11/2013 |  RF  | 1113/0093 Pour les dossiers avec I/E/P (Indemnité/Emprunt/Subvention) -> Il faut intégrer les I/E/P aux calculs de répartition
|      |            |      | Mais séparer distinctement les apbco car on doit les retirer du montant global appelé à la cloture pour obtenir 6+7 = Appels - Dépenses                                      |
----------------------------------------------------------------------*/

/*gga plus utilise
function Arrondir return decimal(pdMtAppUse as decimal,pcTpArrUse as character,pcCdArrUse as character) forward.
gga*/

define temp-table ttApbcoTmp no-undo
  like apbco
index i-noapp noapp cdcle nolot.
define temp-table ttApbcoTmpPro no-undo
  like apbco
index i-noapp noapp cdcle nolot.

procedure prorata private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer trdos for trdos.
    define input parameter pcRpRunLogIn as character no-undo.

    define variable vdTotAppel    as decimal no-undo.
    define variable vdTotCle      as decimal no-undo.
    define variable vdTotLot      as decimal no-undo.
    define variable vdMtAppRep    as decimal no-undo.
    define variable vdMtAppRepTot as decimal no-undo.

    define buffer dosrp for dosrp.

    output to value(substitute("&1apatcx_prorata_&2.01", pcRpRunLogIn, string(trdos.nocon, "99999"))).
    put unformatted skip
        " " skip
        "MANDAT : " trdos.nocon " DOSSIER : " trdos.nodos
    .
    for each ttApbcoTmp
        where lookup(ttApbcoTmp.typapptrx,"00006,00007,00008") = 0            /* Modif SY le 20/11/2012 : exclusion emprunt, subvention, indemnité */
        break by ttApbcoTmp.noapp
              by ttApbcoTmp.cdcle
              by ttApbcoTmp.nolot:

        if first-of (ttApbcoTmp.noapp) then do:
            vdTotAppel = 0.
            put unformatted skip " --> Appel N° " ttApbcoTmp.noapp.
        end.

        if first-of (ttApbcoTmp.cdcle) then do:
            vdTotCle = 0.
            put unformatted skip " ----> Clé " ttApbcoTmp.cdcle.
        end.

        if first-of (ttApbcoTmp.nolot)
        then do:
            vdTotLot = 0.
            put unformatted skip " ------> Lot " ttApbcoTmp.nolot.
        end.

        assign
            vdTotAppel = vdTotAppel + ttApbcoTmp.mtlot
            vdTotCle   = vdTotCle   + ttApbcoTmp.mtlot
            vdTotLot   = vdTotLot   + ttApbcoTmp.mtlot
        .
        put unformatted
            skip "           Cop : " ttApbcoTmp.nocop " " ttApbcoTmp.mtlot format "->>>,>>>,>>9.99".

        if last-of (ttApbcoTmp.nolot) then do:
            put unformatted
                skip " ------> Total Lot       : " vdTotLot format "->>>,>>>,>>9.99"
                skip " ------> Répartition Lot : ".

            vdMtAppRepTot = 0.
            for each dosrp no-lock
                where dosrp.tpcon = trdos.tpcon
                  and dosrp.nocon = trdos.nocon
                  and dosrp.nodos = trdos.nodos
                  and dosrp.nolot = ttApbcoTmp.nolot
                  and dosrp.porep <> 0
                break by dosrp.nolot:
                assign
                    vdMtAppRep = (vdTotLot  * dosrp.porep) / 100
                    vdMtAppRepTot = vdMtAppRepTot + vdMtAppRep
                .
                put unformatted
                    skip "                     Cop " dosrp.nocop " " vdMtAppRep format "->>>,>>>,>>9.99" " quote-part : " dosrp.porep.
                create ttApbcoTmpPro.
                buffer-copy ttApbcoTmp to ttApbcoTmpPro
                    assign
                        ttApbcoTmpPro.nocop = dosrp.nocop
                        ttApbcoTmpPro.mtlot = vdMtAppRep
                .

                if last-of (dosrp.nolot) then do:
                    put unformatted
                        skip "                     Total : " vdMtAppRepTot format "->>>,>>>,>>9.99".

                    if absolute (vdTotLot - vdMtAppRepTot) <> 0
                    then do:
                        put unformatted
                            skip "                     Reliquat : " (vdTotLot - vdMtAppRepTot) format "->>>,>>>,>>9.99" " sur " dosrp.nocop.
                        ttApbcoTmpPro.mtlot = ttApbcoTmpPro.mtlot + (vdTotLot - vdMtAppRepTot).
                    end.
                end.
            end. /** FOR EACH dosrp **/
        end. /** IF LAST-OF (ttApbcoTmp.nolot) THEN DO: **/

        if last-of (ttApbcoTmp.cdcle) then put unformatted
            skip " ----> TOTAL de la clé " ttApbcoTmp.cdcle " = " vdTotCle format "->>>,>>>,>>9.99".

        if last-of (ttApbcoTmp.noapp) then put unformatted
            skip " --> TOTAL de l' Appel N° " ttApbcoTmp.noapp " = " vdTotAppel format "->>>,>>>,>>9.99".

    end. /** FOR EACH ttApbcoTmp **/

    /** Les enregistrement proratés sont à valider dans ttApbcoTmp **/
    for each ttApbcoTmpPro:
        for each ttApbcoTmp
            where ttApbcoTmp.nomdt = ttApbcoTmpPro.nomdt
              and ttApbcoTmp.noapp = ttApbcoTmpPro.noapp
              and ttApbcoTmp.cdcle = ttApbcoTmpPro.cdcle
              and ttApbcoTmp.nolot = ttApbcoTmpPro.nolot
              and lookup(ttApbcoTmp.typapptrx, "00006,00007,00008") = 0:  /* RF 1113/0093 - exclusion I/E/P */
            delete ttApbcoTmp.
        end.
    end.
    for each ttApbcoTmpPro:
        create ttApbcoTmp.
        buffer-copy ttApbcoTmpPro to ttApbcoTmp.
    end.

    empty temp-table ttApbcoTmpPro.     /* 1113/0093 - vidage de la table pour 2nde boucle */
    /* 1113/0093 - 2nde boucle avec I/E/P */
    for each ttApbcoTmp
        where lookup(ttApbcoTmp.typapptrx, "00006,00007,00008") > 0    /* RF 1113/0093 -  I/E/P traité à part */
        break by ttApbcoTmp.noapp by ttApbcoTmp.cdcle by ttApbcoTmp.nolot :

        if first-of (ttApbcoTmp.noapp) then do:
            vdTotAppel = 0.
            put unformatted
                skip " --> Appel N° " ttApbcoTmp.noapp.
        end.

        if first-of (ttApbcoTmp.cdcle) then do:
            vdTotCle = 0.
            put unformatted
                skip " ----> Clé " ttApbcoTmp.cdcle.
        end.

        if first-of (ttApbcoTmp.nolot) then do:
            vdTotLot = 0.
            put unformatted
                skip " ------> Lot " ttApbcoTmp.nolot .
        end.
        assign
            vdTotAppel = vdTotAppel + ttApbcoTmp.mtlot
            vdTotCle   = vdTotCle   + ttApbcoTmp.mtlot
            vdTotLot   = vdTotLot   + ttApbcoTmp.mtlot
        .
        put unformatted
            skip "           Cop : " ttApbcoTmp.nocop " " ttApbcoTmp.mtlot format "->>>,>>>,>>9.99".

        if last-of (ttApbcoTmp.nolot) then do:
            put unformatted
                skip " ------> Total Lot       : " vdTotLot format "->>>,>>>,>>9.99"
                skip " ------> Répartition Lot : ".
            vdMtAppRepTot = 0.
            for each dosrp no-lock
                where dosrp.tpcon = trdos.tpcon
                  and dosrp.nocon = trdos.nocon
                  and dosrp.nodos = trdos.nodos
                  and dosrp.nolot = ttApbcoTmp.nolot
                  and dosrp.porep <> 0
                break by dosrp.nolot:
                assign
                    vdMtAppRep = (vdTotLot  * dosrp.porep) / 100
                    vdMtAppRepTot = vdMtAppRepTot + vdMtAppRep
                .
                put unformatted
                    skip "                     Cop " dosrp.nocop " " vdMtAppRep format "->>>,>>>,>>9.99" " quote-part : " dosrp.porep.
                create ttApbcoTmpPro.
                buffer-copy ttApbcoTmp to ttApbcoTmpPro
                    assign
                        ttApbcoTmpPro.nocop = dosrp.nocop
                        ttApbcoTmpPro.mtlot = vdMtAppRep
                .
                if last-of(dosrp.nolot) then do:
                    put unformatted
                        skip "                     Total : " vdMtAppRepTot format "->>>,>>>,>>9.99" .
                    if absolute (vdTotLot - vdMtAppRepTot) <> 0 then do:
                        put unformatted
                            skip "                     Reliquat : " (vdTotLot - vdMtAppRepTot) format "->>>,>>>,>>9.99" " sur " dosrp.nocop.
                        ttApbcoTmpPro.mtlot = ttApbcoTmpPro.mtlot + (vdTotLot - vdMtAppRepTot).
                    end.
                end.
            end. /** FOR EACH dosrp **/
        end. /** IF LAST-OF (ttApbcoTmp.nolot) THEN DO: **/

        if last-of (ttApbcoTmp.cdcle) then put unformatted
            skip " ----> TOTAL de la clé " ttApbcoTmp.cdcle " = " vdTotCle format "->>>,>>>,>>9.99".

        if last-of (ttApbcoTmp.noapp) then put unformatted
            skip " --> TOTAL de l' Appel N° " ttApbcoTmp.noapp " = " vdTotAppel format "->>>,>>>,>>9.99".
    end. /** FOR EACH ttApbcoTmp **/

    output close.

    /** Les enregistrement proratés sont à valider dans ttApbcoTmp **/
    for each ttApbcoTmpPro
      , each ttApbcoTmp
        where ttApbcoTmp.nomdt = ttApbcoTmpPro.nomdt
          and ttApbcoTmp.noapp = ttApbcoTmpPro.noapp
          and ttApbcoTmp.cdcle = ttApbcoTmpPro.cdcle
          and ttApbcoTmp.nolot = ttApbcoTmpPro.nolot
          and lookup(ttApbcoTmp.typapptrx, "00006,00007,00008") > 0: /* RF 1113/0093 - I/E/P traités à part */
        delete ttApbcoTmp.
    end.
    for each ttApbcoTmpPro:
        create ttApbcoTmp.
        buffer-copy ttApbcoTmpPro to ttApbcoTmp.
    end.

end procedure.

/*gga plus utilise
/*==A R R O N D I R========================================================================================================*/
function Arrondir return decimal(pdMtAppUse as decimal,pcTpArrUse as character,pcCdArrUse as character):

    define variable vcLbTmpPdt as character no-undo.
    define variable viCpUseInc as integer   no-undo.

    case pcTpArrUse:
        /*--> Tronqué */
        when "00001" then
            do:
                case pcCdArrUse:
                    /*--> centime */
                    when "00001" then
                        pdMtAppUse = truncate(pdMtAppUse,2).

                    /*--> unite */
                    when "00002" then
                        pdMtAppUse = truncate(pdMtAppUse,0).

                    /*--> dizaine */
                    when "00003" then
                        assign
                            vcLbTmpPdt = string(integer(pdMtAppUse))
                            vcLbTmpPdt = substring(vcLbTmpPdt,1,length(vcLbTmpPdt) - 1) + "0"
                            pdMtAppUse = integer(vcLbTmpPdt).

                    /*--> centaine */
                    when "00004" then
                        assign
                            vcLbTmpPdt = string(integer(pdMtAppUse))
                            vcLbTmpPdt = substring(vcLbTmpPdt,1,length(vcLbTmpPdt) - 2) + "00"
                            pdMtAppUse = integer(vcLbTmpPdt).

                    /*--> Millier */
                    when "00005" then
                        assign
                            vcLbTmpPdt = string(integer(pdMtAppUse))
                            vcLbTmpPdt = substring(vcLbTmpPdt,1,length(vcLbTmpPdt) - 3) + "000"
                            pdMtAppUse = integer(vcLbTmpPdt).
                end.
            end.

        /*--> Arrondi */
        when "00002" then
            do:
                case pcCdArrUse:
                    /*--> centime */
                    when "00001" then
                        pdMtAppUse = round(pdMtAppUse,2).

                    /*--> unite */
                    when "00002" then
                        pdMtAppUse = round(pdMtAppUse,0).

                    /*--> dizaine */
                    when "00003" then
                        do:
                            assign
                                pdMtAppUse = integer(pdMtAppUse)
                                vcLbTmpPdt = string(pdMtAppUse)
                                viCpUseInc = integer(substring(vcLbTmpPdt,length(vcLbTmpPdt),1)).

                            if viCpUseInc > 5 then
                                pdMtAppUse = pdMtAppUse + (10 - viCpUseInc).
                            else
                                pdMtAppUse = pdMtAppUse - viCpUseInc.
                        end.

                    /*--> centaine */
                    when "00004" then
                        do:
                            assign
                                pdMtAppUse = integer(pdMtAppUse)
                                vcLbTmpPdt = string(pdMtAppUse).

                            if length(vcLbTmpPdt) > 2 then
                            do:
                                viCpUseInc = integer(substring(vcLbTmpPdt,length(vcLbTmpPdt)- 1,2)).

                                if viCpUseInc > 50 then
                                    pdMtAppUse = pdMtAppUse + (100 - viCpUseInc).
                                else
                                    pdMtAppUse = pdMtAppUse - viCpUseInc.
                            end.
                        end.

                    /*--> millier */
                    when "00005" then
                        do:
                            assign
                                pdMtAppUse = integer(pdMtAppUse)
                                vcLbTmpPdt = string(pdMtAppUse).

                            if length(vcLbTmpPdt) > 3 then
                            do:
                                viCpUseInc = integer(substring(vcLbTmpPdt,length(vcLbTmpPdt)- 2,3)).

                                if viCpUseInc > 500 then
                                    pdMtAppUse = pdMtAppUse + (1000 - viCpUseInc).
                                else
                                    pdMtAppUse = pdMtAppUse - viCpUseInc.
                            end.
                        end.
                end.
            end.
    end.

    return pdMtAppUse.
end.
gga*/