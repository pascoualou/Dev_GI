/*------------------------------------------------------------------------
File        : honoraireCommercialisation.i
Purpose     : Commercialisation : honoraires Locataire/Propriétaire
Author(s)   : SPo  -  17/01/2017
Notes       :
derniere revue: 2018/05/23 - phm: OK
        en fait KO, il manque les champs rRowid sur ttHonoraireCommercialisation et ttCalculBareme
------------------------------------------------------------------------*/
define temp-table ttHonoraireCommercialisation no-undo
    field iNumeroHonoraire      as integer   initial ? label 'nohonoraire'
    field iNumeroElementFinance as integer   initial ? label 'nofinance'
    field iNumeroFiche          as integer   initial ?
    field iTypeHonoraire1       as integer   initial ? label 'tphonoraire1'   // honoraires (STD), ALUR (chez DAUCHEZ), ...
    field iTypeHonoraire2       as integer   initial ? label 'tphonoraire2'   // Locataire/Propriétaire
    field iNumeroBareme         as integer   initial ? label 'nobareme'
    field dMontantTotalHT       as decimal   initial ? label 'totalht'
    field dMontantTotalTTC      as decimal   initial ? label 'totalttc'

    field dtTimestamp as datetime
    field CRUD        as character
index idx_NumeroHonoraire is unique primary iNumeroHonoraire
index idx_NumeroFiche iNumeroFiche 
.
// liste des barèmes honoraires ALUR 
define temp-table ttBaremeHonoraireComm no-undo                                 // libellé ne doit pas dépasser 32 caractères
    field iNumeroBareme   as integer   initial ? label 'nobareme'
    field iTypeHonoraire2 as integer   initial ? label 'tphonoraire2'   // Locataire/Propriétaire
    field cNomBareme      as character initial ? label 'nom'      

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttCalculBareme no-undo
    field iNumeroCalculBareme  as integer   initial ? label 'nocalcul_bareme'
    field iNumeroBareme        as integer   initial ? label 'nobareme'
    field iNumeroZoneALUR      as integer   initial ? label 'nozonalur'
    field iCodeTVA             as integer   initial ? label 'cdtva'
    field dTauxTVA             as decimal   initial ?
    field iNumeroChampFinance  as integer   initial ? label 'nochpfinance'   // sissi : pb structure GL_CALCUL_BAREME : nochpfinance à créer
    field lLocationMeuble      as logical   initial ? label 'fgmeuble'
    field cCalculBaremeHT      as character initial ? label 'baremeht'       // exemple : 6.666[surfm2]
    field cCalculBaremeTTC     as character initial ? label 'baremettc' 
    field cCalculBaremeMiniHT  as character initial ? label 'baremeht_min'
    field cCalculBaremeMiniTTC as character initial ? label 'baremettc_min'
    field cCalculBaremeMaxiHT  as character initial ? label 'baremeht_max'
    field cCalculBaremeMaxiTTC as character initial ? label 'baremettc_max'   
    field cTypeCalcul          as character initial ? label 'typcalcul'     // TTC ou HT (calcul sur le HT ou TTC)

    field dtTimestamp as datetime
    field CRUD        as character
.
