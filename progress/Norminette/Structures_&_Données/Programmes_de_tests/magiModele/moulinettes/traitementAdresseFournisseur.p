/*------------------------------------------------------------------------
    File        : traitementAdresseFournisseur.p
    Purpose     : 
    Author(s)   : Kantena
    Created     : Thu Sep 21 16:20:20 CEST 2017
    Notes       :
  ----------------------------------------------------------------------*/
using OpenEdge.Net.HTTP.ClientBuilder.
using OpenEdge.Net.HTTP.IHttpClient.
using OpenEdge.Net.HTTP.IHttpRequest.
using OpenEdge.Net.HTTP.RequestBuilder.
using OpenEdge.Net.URI.
using OpenEdge.Net.HTTP.IHttpResponse.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.

/* Objets */
define variable oUri          as URI              no-undo.
define variable oClient       as IHttpClient      no-undo.
define variable oJson         as class JsonObject no-undo.
define variable oResult       as class JsonArray  no-undo.
define variable oAddress      as class JsonObject no-undo.

/* autres variables */
define variable vhHttp        as handle           no-undo.
define variable vcOldAddress  as character        no-undo.
define variable vcQuery       as character        no-undo.
define variable giNombreLigne as integer          no-undo.
define variable lRetour       as logical          no-undo.
define variable vcKey         as character        no-undo initial "mapzen-LUDQw6J".

&SCOPED-DEFINE MAXRETURNEDROWS  10

// Liste des adresses à traiter
define temp-table ttAddress
    field noadr       as integer
    field cdpay       as character
    field voie1old    as character
    field voie2old    as character
    field voie3old    as character
    field cpold       as character format "99999"
    field villeold    as character
    field numero      as character
    field voie1new    as character
    field voie2new    as character
    field cpnew       as character format "99999"
    field villenew    as character
index idx1 is primary unique voie1old voie2old voie3old cpold villeold
index idx2 is unique noadr.

/* Adresses déjà utilises pour un appel au service */
define temp-table ttDoneAddress
    field noadr       as integer
    field address     as character
index idx1 is primary unique address.


function validJson returns logical:
    /*------------------------------------------------------------------------------
    Purpose: Vérifie la validité du JSON retourné par le service
    Notes  :
    -------------------------------------------------------------------------------*/
    if not valid-object(oJson) then return false.

    if not valid-object (oJson:GetJsonArray("features")) 
    or (oJson:GetJsonArray("features"):Length = 0
    or oJson:GetJsonArray("features"):Length > 1) 
    then return false.

    return true.

end function.


/**************************************** MAIN ******************************************/
run loadTTAddress.

run moulinettes/httpClient.p persistent set vhHttp.
oClient = dynamic-function('createHTTPClient' in vhHttp).

// Traitement des adresses 
boucle_address:
for each ttAddress
     by ttAddress.noadr:
    
    if giNombreLigne >= {&MAXRETURNEDROWS} then leave boucle_address.
    // Si l'adresse a déjà été traitée 
    if ttAddress.numero   <> "" 
    or ttAddress.voie1new <> "" 
    or ttAddress.voie2new <> "" 
    or ttAddress.cpnew    <> "" 
    or ttAddress.villenew <> "" then next boucle_address.

    assign
        giNombreLigne = giNombreLigne + 1
        vcOldAddress  = substitute('&1 &2 &3', ttAddress.voie1old, ttAddress.cpold, ttAddress.villeold)
    .

    if int(ttAddress.cdpay) = 1 then do:
        
        create ttDoneAddress.
        assign 
            ttDoneAddress.noadr   = ttAddress.noadr
            ttDoneAddress.address = vcOldAddress
        .
        oURI = new Uri('http', 'search.mapzen.com', 80). // MAPZEN
        oURI:path = 'v1/search'.
        oURI:addQuery('text', vcOldAddress).
        oURI:addQuery('boundary.country', 'FR').
        oURI:addQuery('api_key', vcKey).

        message oURI:QueryString view-as alert-box.
        //oJson = dynamic-function('callGET' in vhHttp, oURI, oClient). 

        if not validJson()
        then do:
            vcOldAddress = substitute('&1 &2 &3', ttAddress.voie2old, ttAddress.cpold, ttAddress.villeold).
            if not can-find(first ttDoneAddress 
                            where ttDoneAddress.address = vcOldAddress) 
            then do:
                oURI:addQuery('text', vcOldAddress).
                //oJson = dynamic-function('callGET' in vhHttp, oURI, oClient).
                message oURI:QueryString view-as alert-box.
            end.
        end.
        //run readJsonMapZen.
    end.
end.
//run exportDataFrance.
//run exportDataInter.
delete procedure vhHttp.

disp "FIN".
/************************************** END MAIN ****************************************/

procedure loadTTAddress:
   /*------------------------------------------------------------------------------
    Purpose: Charge les données dans ttAddress à partir d'un fichier csv
    Notes  :
    -------------------------------------------------------------------------------*/
   input from C:\MAGI\temp\FormatAdresseFour_FRANCE.csv.
   repeat:
      create ttAddress.
      import delimiter ";" ttAddress. 
   end.
   input close.
/*
   input from C:\MAGI\temp\FormatAdresseFour_INTER.csv.
   repeat:
      create ttAddress.
      import delimiter ";" ttAddress. 
   end.
   input close.
*/
end procedure.

procedure exportDataFrance:
   /*------------------------------------------------------------------------------
    Purpose: Exporter les données de ttAddress dans un fichier csv
    Notes  :
    -------------------------------------------------------------------------------*/
    output to C:\MAGI\temp\FormatAdresseFour_FRANCE.csv.
    // export des données
    for each ttAddress
        where int(ttAddress.cdpay) = 1
           by ttAddress.noadr:
        // Gestion des adresses françaises
        put unformatted
                ttAddress.noadr       ";"
                ttAddress.cdpay       ";"
                ttAddress.voie1old    ";"
                ttAddress.voie2old    ";"
                ttAddress.voie3old    ";"
                ttAddress.cpold       ";"
                ttAddress.villeold    ";"
                ttAddress.numero      ";"
                ttAddress.voie1new    ";"
                ttAddress.voie2new    ";"
                ttAddress.cpnew       ";"
                ttAddress.villenew    
        skip.
    end.
    output close.
end procedure.

procedure exportDataInter:
   /*------------------------------------------------------------------------------
    Purpose: Exporter les données de ttAddress dans un fichier csv
    Notes  :
    -------------------------------------------------------------------------------*/
    output to C:\MAGI\temp\FormatAdresseFour_INTER.csv.
    // export des données
    for each ttAddress
        where int(ttAddress.cdpay) <> 1
          by ttAddress.noadr:
        // Gestion des adresses françaises
        put unformatted
                ttAddress.noadr       ";"
                ttAddress.cdpay       ";"
                ttAddress.voie1old    ";"
                ttAddress.voie2old    ";"
                ttAddress.voie3old    ";"
                ttAddress.cpold       ";"
                ttAddress.villeold    ";"
                ttAddress.numero      ";"
                ttAddress.voie1new    ";"
                ttAddress.voie2new    ";"
                ttAddress.cpnew       ";"
                ttAddress.villenew    
        skip.
    end.
    output close.
end procedure.

procedure readJsonMapZen:
   /*------------------------------------------------------------------------------
    Purpose: Lecture des informations au retour du service Gouv
    Notes  : Les propriétés de l'adresse sont contenues dans un jsonArray appelé 'properties' 
    -------------------------------------------------------------------------------*/
    define variable iResponse as integer no-undo.
    
    if not valid-object(oJson) then do:
        assign
            ttAddress.numero   = 'NOT LOCATED (0)'
            ttAddress.voie1new = 'NOT LOCATED (0)'
            ttAddress.voie2new = 'NOT LOCATED (0)'
            ttAddress.cpnew    = 'NOT LOCATED (0)'
            ttAddress.villenew = 'NOT LOCATED (0)'
        .
        return.
    end.
    iResponse = if valid-object(oJson:GetJsonArray("features")) then oJson:GetJsonArray("features"):Length else 0.

    if (iResponse = 0  // pas d'adresse
         or iResponse > 1) // plusieurs adresses
    and available ttAddress 
    then do:
        assign
            ttAddress.numero   = substitute('NOT LOCATED (&1)', iResponse)
            ttAddress.voie1new = substitute('NOT LOCATED (&1)', iResponse)
            ttAddress.voie2new = substitute('NOT LOCATED (&1)', iResponse)
            ttAddress.cpnew    = substitute('NOT LOCATED (&1)', iResponse)
            ttAddress.villenew = substitute('NOT LOCATED (&1)', iResponse)
        .
    end.
    else if oJson:GetJsonArray("features"):Length = 1 // On veut qu'une seule adresse possible
    then do:
        oAddress = oJson:GetJsonArray("features"):GetJsonObject(1):getJsonObject("properties").
        
        if valid-object(oAddress) and available ttAddress
        then do:
            ttAddress.numero   = oAddress:GetCharacter("housenumber") no-error.
            ttAddress.voie1new = oAddress:GetCharacter("label")       no-error.
            ttAddress.voie2new = oAddress:GetCharacter("name")        no-error.
            ttAddress.cpnew    = oAddress:GetCharacter("postalcode")  no-error.
            ttAddress.villenew = oAddress:GetCharacter("locality")    no-error.
        end.
        //delete ttAddress.
    end.
    if valid-object(oAddress) then delete object oAddress.
    if valid-object(oJson)    then delete object oJson.
   
end procedure.

procedure readJsonGouv:
   /*------------------------------------------------------------------------------
    Purpose: Lecture des informations au retour du service Gouv
    Notes  : Les propriétés de l'adresse sont contenues dans un jsonArray appelé 'properties' 
    -------------------------------------------------------------------------------*/
    if valid-object(oJson)
    and oJson:GetJsonArray("features"):Length = 1 // On veut qu'une seule adresse possible
    then do:
        oAddress = oJson:GetJsonArray("features"):GetJsonObject(1):getJsonObject("properties").

        if valid-object(oAddress) and available ttAddress
        then do:
            ttAddress.voie1new = oAddress:GetCharacter("label")       no-error.
            ttAddress.numero   = oAddress:GetCharacter("housenumber") no-error.
            ttAddress.cpnew    = oAddress:GetCharacter("postcode")    no-error.
            ttAddress.villenew = oAddress:GetCharacter("city")        no-error.
        end.
    end.
    giNombreLigne      = giNombreLigne + 1.
    if valid-object(oAddress) then delete object oAddress.
    if valid-object(oJson)    then delete object oJson.
   
end procedure.

procedure readJsonGoogle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des informations au retour du service Google
    Notes  : Les propriétés de l'adresse sont contenues dans un jsonArray appelé 'address_components'
    -------------------------------------------------------------------------------*/
    define variable oAddress      as class JsonArray no-undo.
    define variable oTypes        as class JsonArray no-undo.
    define variable cTypes        as character no-undo.
    define variable vcVille       as character no-undo.
    define variable vcPostalCode  as character no-undo.
    define variable iCptAddress   as integer   no-undo.
    define variable iCptComponent as integer   no-undo.

    oResult = oJson:GetJsonArray("results").
    if oJson:GetCharacter("status") <> "OK" then return.

/*Boucle_adresses:
    do iCptAddress = 1 to oResult:Length: 
       oAddress = oResult:GetJsonObject(iCPtAddress):GetJsonArray("address_components").
       assign 
           vcPostalCode = ""
           vcVille = ""
       .
Boucle_proprietes:
       do iCptComponent = 1 to oAddress:length:
           oTypes = oAddress:GetJsonObject(iCptComponent):getJsonArray("types").
           cTypes = oTypes:GetJsonText().

           if index(cTypes, "postal_code") > 0 then vcPostalCode = oAddress:GetJsonObject(iCptComponent):GetCharacter("short_name").
           if index(cTypes, "locality")    > 0 then vcVille      = oAddress:GetJsonObject(iCptComponent):GetCharacter("short_name").

        end.
    end.
*/
   giNombreLigne      = giNombreLigne + 1.
   if valid-object(oJson)    then delete object oJson.
end procedure.
