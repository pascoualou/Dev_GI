/*------------------------------------------------------------------------
File        : parametre/cabinet/gerance/tarifCirconscription.p
Purpose     : Paramétrage des tarifs par circonscription et usage (taxe sur les bureaux)
Author(s)   : DMI  -  2017/12/19
Notes       : à partir de adb/src/cabt/taxebu00.p

------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{parametre/cabinet/gerance/include/tarifCirconscription.i}
{adblib/include/garan.i}
{application/include/combo.i}

procedure initComboTarifCirconscription :
    /*------------------------------------------------------------------------------
    Purpose: Charge les combos
    Notes  : Service appelé par beParametreGerance.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    define variable voSyspg as class syspg no-undo.
    defin buffer garan for garan.

    voSyspg = new syspg().
    for each garan no-lock
            where garan.TpCtt = {&TYPECONTRAT-TaxeSurBureau}
              and garan.TpBar = "00000" :
        voSyspg:creationttCombo("CMBTARIFCIRCONSCRIPTION", string(garan.noctt), string(garan.noctt), output table ttCombo by-reference).
    end.
    delete object voSyspg.
end procedure.

procedure creTarifCirconscription private :
    /*------------------------------------------------------------------------------
    Purpose: creation de ttAnneeTarifCirconscription (entete) et ttTarifCirconscription (lignes)
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer garan for garan.
    define input parameter piAnnee as integer no-undo.
    define input parameter pcCrud  as character no-undo.

    define variable viI1                   as integer   initial ?       no-undo.
    define variable cTypeTarifBureauNormal as character initial "00001" no-undo.
    define variable cTypeTarifBureauReduit as character initial "00002" no-undo.
    define variable cTypeTarifCommerciaux  as character initial "00003" no-undo.
    define variable cTypeTarifStockage     as character initial "00004" no-undo.
    define variable cTypeTarifParking      as character initial "00005" no-undo.      /* SY 0211/0008 */
    define variable cTypeTarifTaxeAddPkg   as character initial "00006" no-undo.      /* NP 0115/0183 */
    define variable cTypeTarifParcExpo     as character initial "00007" no-undo.      /* NP 0115/0183 */

    define buffer vbGaran for garan.

    create ttAnneeTarifCirconscription.
    assign
        ttAnneeTarifCirconscription.iAnnee = piAnnee
        ttAnneeTarifCirconscription.CRUD   =  pcCRUD
    .
    if pcCRUD <> "C" and available garan
    then assign
            ttAnneeTarifCirconscription.rRowid      = rowid(garan)
            ttAnneeTarifCirconscription.dtTimestamp = datetime(garan.dtmsy, garan.hemsy)
            .
    /* Création d'une ligne par zone */
    do viI1 = 1 to 3:
        create ttTarifCirconscription.
        assign
            ttTarifCirconscription.iAnnee        = piAnnee
            ttTarifCirconscription.iZone         = viI1
            ttTarifCirconscription.dBureauNormal = 0
            ttTarifCirconscription.dBureauReduit = 0
            ttTarifCirconscription.dCommerciaux  = 0
            ttTarifCirconscription.dStockage     = 0
            ttTarifCirconscription.dParcExpo     = 0
            ttTarifCirconscription.dParking      = 0
            ttTarifCirconscription.dTaxeAddPkg   = 0
            ttTarifCirconscription.CRUD          = pcCRUD
        .
        if piAnnee < 2011 then do:
            case ttTarifCirconscription.iZone :
                when 1 then ttTarifCirconscription.cLibelle = outilTraduction:getLibelle(107256).
                when 2 then ttTarifCirconscription.cLibelle = substitute("&1&2"
                                                                       , outilTraduction:getLibelle(107257)
                                                                       , outilTraduction:getLibelle(107258)).
                when 3 then ttTarifCirconscription.cLibelle = outilTraduction:getLibelle(107259).
                otherwise   ttTarifCirconscription.cLibelle =  "".
            end case.
        end.
        else if piAnnee >= 2013
        then case ttTarifCirconscription.iZone : // NP 0113/0048
            when 1 then ttTarifCirconscription.cLibelle = outilTraduction:getLibelle(1000403). // 1000403 "Paris (75), Hauts-de-seine (92)"
            when 2 then ttTarifCirconscription.cLibelle = outilTraduction:getLibelle(1000404). // 1000404 "Unité Urbaine de Paris : Seine-Saint-Denis (93), Val-de-marne (94) et partiellement : Essonne (91), Seine-et-marne (77), Val d'oise (95), Yvelines (78)"
            when 3 then ttTarifCirconscription.cLibelle = outilTraduction:getLibelle(1000405). // 1000405 "3e circonscription : les communes pouvant bénéficier de la DSUCS* (dotation de solidarité urbaine et de cohésion sociale) et du FSRIF* (fonds de solidarité des communes de la région Ile-de-France), ainsi que les communes du 77, du 78, du 91 et du 95 non incluses dans l'unité urbaine de Paris"
            otherwise   ttTarifCirconscription.cLibelle = "".
        end case.
        else case ttTarifCirconscription.iZone:
            when 1 then ttTarifCirconscription.cLibelle = outilTraduction:getLibelle(1000403). // 1000403 "Paris (75), Hauts-de-seine (92)"
            when 2 then ttTarifCirconscription.cLibelle = outilTraduction:getLibelle(1000404). // 1000404 "Unité Urbaine de Paris : Seine-Saint-Denis (93), Val-de-marne (94) et partiellement : Essonne (91), Seine-et-marne (77), Val d'oise (95), Yvelines (78)"
            when 3 then ttTarifCirconscription.cLibelle = outilTraduction:getLibelle(1000406). // 1000406 "Essonne (91), Seine-et-marne (77), Val d'oise (95), Yvelines (78)"
            otherwise   ttTarifCirconscription.cLibelle = "".
        end case.
    end.
    // Chargement de la Table Temporaire de taxes sur bureaux
    if available garan then
    for each vbGaran no-lock
        where vbGaran.tpctt = {&TYPECONTRAT-TaxeSurBureau}
          and vbGaran.noctt = garan.noctt
          and vbGaran.nobar > 0
          by vbGaran.nobar by vbGaran.tpbar:

        for first ttTarifCirconscription
            where ttTarifCirconscription.iAnnee = piAnnee
              and ttTarifCirconscription.iZone = vbGaran.nobar :
            case vbGaran.tpbar:
                when cTypeTarifBureauNormal then ttTarifCirconscription.dBureauNormal = vbGaran.txcot.
                when cTypeTarifBureauReduit then ttTarifCirconscription.dBureauReduit = vbGaran.txcot.
                when cTypeTarifCommerciaux  then ttTarifCirconscription.dCommerciaux  = vbGaran.txcot. /* "00003" */
                when cTypeTarifStockage     then ttTarifCirconscription.dStockage     = vbGaran.txcot. /* "00004" */
                when cTypeTarifParcExpo     then ttTarifCirconscription.dParcExpo     = vbGaran.txcot. /* "00006" */   /* NP 0115/0183 */
                when cTypeTarifParking      then ttTarifCirconscription.dParking      = vbGaran.txcot. /* "00005" */
                when cTypeTarifTaxeAddPkg   then ttTarifCirconscription.dTaxeAddPkg   = vbGaran.txcot. /* "00007" */   /* NP 0115/0183 */
            end.
        end.
        // Commerciaux et stockage avant 2011 : même tarif
        if piAnnee < 2011 and vbGaran.tpbar >= "00003" and vbGaran.nobar = 1 
        then for each ttTarifCirconscription where ttTarifCirconscription.iZone > vbGaran.nobar:
                case vbGaran.tpbar:
                    when cTypeTarifCommerciaux then ttTarifCirconscription.dCommerciaux = vbGaran.txcot.   /* "00003" */
                    when cTypeTarifStockage    then ttTarifCirconscription.dStockage    = vbGaran.txcot.   /* "00004" */
                end.
        end.
    end.
end procedure.

procedure initTarifCirconscription :
    /*------------------------------------------------------------------------------
    Purpose: Initialisation Tarif circonscription (bouton création)
    Notes  : Service appelé par beParametreGerance.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttAnneeTarifCirconscription.
    define output parameter table for ttTarifCirconscription.

    define buffer garan for garan.

    empty temp-table ttTarifCirconscription.
    empty temp-table ttAnneeTarifCirconscription.

    find last garan no-lock
            where garan.TpCtt = {&TYPECONTRAT-TaxeSurBureau}
              and garan.TpBar = "00000"
              no-error.
    run creTarifCirconscription(buffer garan, (if available garan then garan.noctt + 1 else year(today) - 1), "C"). // garan peut ne pas être available
end.

procedure getTarifCirconscription :
    /*------------------------------------------------------------------------------
    Purpose: Extrait les tarifs d'une année
    Notes  : Service appelé par beParametreGerance.cls
    ------------------------------------------------------------------------------*/
    define input  parameter NoAnnChg-IN as integer  no-undo.
    define output parameter table for ttAnneeTarifCirconscription.
    define output parameter table for ttTarifCirconscription.

    define buffer garan for garan.

    empty temp-table ttTarifCirconscription.
    empty temp-table ttAnneeTarifCirconscription.
    for first garan no-lock
            where garan.TpCtt = {&TYPECONTRAT-TaxeSurBureau}
              and garan.TpBar = "00000"
              and garan.noctt = NoAnnChg-IN :
        run creTarifCirconscription(buffer garan, NoAnnChg-IN, "R"). // garan peut ne pas être available
    end.
end procedure.

procedure updateTarifCirconscription :
    /*------------------------------------------------------------------------------
    Purpose: Validation tarif taxe sur bureau
    Notes  : Service appelé par beParametreGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttAnneeTarifCirconscription.
    define input parameter table for ttTarifCirconscription.

blocTrans:
    do transaction:
        run validation.
        if merror:erreur() then undo blocTrans, return.
    end.
end procedure.

procedure Validation private :
    /*------------------------------------------------------------------------------
    Purpose: Validation tarif taxe bureau par circonscription
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcGaran            as handle    no-undo.
    define variable vhProcPrgDat           as handle    no-undo.
    define variable vcLibelleDateDu        as character no-undo.
    define variable vcLibelleDateAu        as character no-undo.
    define variable vcLibelleDateDuAu      as character no-undo.
    define variable viI1                   as integer   no-undo.
    define variable vdMtTarif              as decimal   no-undo.
    define variable vcTypeTarif            as character no-undo.
    define variable cTypeTarifBureauNormal as character initial "00001" no-undo.
    define variable cTypeTarifBureauReduit as character initial "00002" no-undo.
    define variable cTypeTarifCommerciaux  as character initial "00003" no-undo.
    define variable cTypeTarifStockage     as character initial "00004" no-undo.
    define variable cTypeTarifParking      as character initial "00005" no-undo.
    define variable cTypeTarifTaxeAddPkg   as character initial "00006" no-undo.
    define variable cTypeTarifParcExpo     as character initial "00007" no-undo.
    define variable vdtTimeStamp           as datetime  no-undo.
    define variable vcCRUD                 as character no-undo.
    define variable vrRowid                as rowid     no-undo.
    

    define buffer garan for garan.

    run adblib/garan_CRUD.p persistent set vhProcGaran.
    run getTokenInstance in vhProcGaran(mToken:JSessionId).
    run application/l_prgdat.p persistent set vhProcPrgDat.
    run getTokenInstance in vhProcPrgDat(mToken:JSessionId).

blocTrans:
    do transaction:
        for each ttAnneeTarifCirconscription where lookup(ttAnneeTarifCirconscription.CRUD, "U,C") > 0:
            create ttGaran.
            assign // copyvalidfield ecrase ces 3 champs
                vdtTimeStamp = ttAnneeTarifCirconscription.dtTimeStamp
                vcCRUD       = ttAnneeTarifCirconscription.CRUD       
                vrRowid      = ttAnneeTarifCirconscription.rRowid     
            .                
            if outils:copyValidField(buffer ttGaran:handle, buffer ttAnneeTarifCirconscription:handle, "", "")
            then do :
                assign
                    ttGaran.tpctt       = {&TYPECONTRAT-TaxeSurBureau}
                    ttGaran.noctt       = ttAnneeTarifCirconscription.iAnnee
                    ttGaran.tpbar       = "00000"
                    ttGaran.nobar       = 0
                    ttGaran.txcot       = 0
                    ttGaran.txhon       = 0
                    ttGaran.fgtot       = false
                    ttGaran.cdtva       = ""
                    ttGaran.TxRes       = 0
                    ttGaran.dtTimeStamp = vdtTimeStamp
                    ttGaran.CRUD        = vcCRUD
                    ttGaran.rRowid      = vrRowid
                .
                if ttGaran.CRUD = "C" then do :
                    run GetLibDte in vhProcPrgDat(date(01,01,ttAnneeTarifCirconscription.iAnnee),"L", output vcLibelleDateDu).
                    run GetLibDte in vhProcPrgDat(date(12,31,ttAnneeTarifCirconscription.iAnnee),"L", output vcLibelleDateAu).
                    vcLibelleDateDuAu = substitute("&1 &2 &3 &4",outilTraduction:getLibelle(101727), vcLibelleDateDu, outilTraduction:getLibelle(100132), vcLibelleDateAu).
                    ttGaran.cdper = vcLibelleDateDuAu.
                end.
            end.
            else undo blocTrans, leave blocTrans.

            for each ttTarifCirconscription
                where ttTarifCirconscription.iAnnee = ttAnneeTarifCirconscription.iAnnee
                  and lookup(ttTarifCirconscription.crud,"U,C") > 0 :
                do viI1 = 1 to 7:
                    create ttGaran.
                    vdMtTarif = 0.
                    vcTypeTarif = string(viI1, "99999").
                    case vcTypeTarif:
                        when cTypeTarifBureauNormal then vdMtTarif = ttTarifCirconscription.dBureauNormal.
                        when cTypeTarifBureauReduit then vdMtTarif = ttTarifCirconscription.dBureauReduit.
                        when cTypeTarifCommerciaux  then vdMtTarif = ttTarifCirconscription.dCommerciaux.
                        when cTypeTarifStockage     then vdMtTarif = ttTarifCirconscription.dStockage.
                        when cTypeTarifParcExpo     then vdMtTarif = ttTarifCirconscription.dParcExpo.
                        when cTypeTarifParking      then vdMtTarif = ttTarifCirconscription.dParking.
                        when cTypeTarifTaxeAddPkg   then vdMtTarif = ttTarifCirconscription.dTaxeAddPkg.
                    end case.
                    assign
                        ttGaran.tpctt = {&TYPECONTRAT-TaxeSurBureau}
                        ttGaran.noctt = ttAnneeTarifCirconscription.iAnnee
                        ttGaran.tpbar = string(viI1 , "99999")
                        ttGaran.nobar = ttTarifCirconscription.iZone
                        ttGaran.txcot = vdMtTarif
                        ttGaran.txhon = 0
                        ttGaran.fgtot = false
                        ttGaran.cdtva = ""
                        ttGaran.cdper = ""
                        ttGaran.TxRes = 0
                        ttGaran.crud  = ttTarifCirconscription.CRUD
                    .
                    if ttTarifCirconscription.CRUD = "U" // Le crud est géré par ligne
                    then do:
                        find first garan no-lock
                        where garan.tpctt = ttGaran.tpctt
                          and garan.noctt = ttGaran.noctt
                          and garan.tpbar = ttGaran.tpbar
                          and garan.nobar = ttGaran.nobar no-error.
                        if not available garan
                        then ttGaran.crud = "C".
                        else assign
                            ttGaran.dtTimeStamp = datetime(garan.dtmsy, garan.hemsy)
                            ttGaran.rRowid      = rowid(garan)
                        .
                    end.
                end.
            end.
        end.
        run setGaran in vhProcGaran(table ttGaran by-reference).
        if mError:erreur() then undo blocTrans, leave.
    end.
    run destroy in vhProcPrgDat.
    run destroy in vhProcGaran.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.