public class LeadValidation{
    public static String auto(String line, Set<String> allAgencies){
        System.debug('--------- '+line);
        try{
            String incorrect = '';
            List<String> part= line.split(';');
            //File standardization
            while(part.size()<=36) part.add('');
            
            if(!allRequired(part)) incorrect += 'Campi obbligatori mancanti, ';
            if(!isMail(part[3])) incorrect += 'Mail, ';
            if(!isFiscalID(part[4])) incorrect += 'Codice fiscale, ';
            if(!isAgency(part[5],AllAgencies)) incorrect += 'Codice agenzia, ';
            if(!isDate(part[8])) incorrect += 'Data di nascita intestatario, ';
            if(!isCheck(part[9])) incorrect += 'Consenso attivita, ';
            if(!isLineAuto(part[10])) incorrect += 'Tipologia polizza, ';
            if(!isPrice(part[11])) incorrect += 'Prezzo RCAuto, ';
            if(!isPrice(part[12])) incorrect += 'Prezzo furto, ';
            if(!isPrice(part[13])) incorrect += 'Prezzo incendio, ';
            if(!isPrice(part[14])) incorrect  += 'Prezzo infortuni conducente, '; 
            if(!isPrice(part[15])) incorrect  += 'Prezzo assistenza, ';
            if(!isPrice(part[16])) incorrect  += 'Scoperti RCAuto, ';
            if(!isPrice(part[20])) incorrect += 'Massimale RCAuto, ';
            if(!isPrice(part[21])) incorrect += 'Massimale furto, ';
            if(!isPrice(part[22])) incorrect += 'Massimale incendio, ';
            if(!isPrice(part[23])) incorrect += 'Massimale infortuni, ';
            if(!isInt(part[24])) incorrect += 'N. di sinistri con colpa ultimi 5 anni, ';
            if(!isInt(part[25])) incorrect += 'N. di sinistri con colpa ultimi 2 anni ';
            if(!isDate(part[26])) incorrect += 'Data scadenza polizza, ';
            if(!isUniversalClass(part[27])) incorrect += 'Classe universale, ';
            if(!isPIVA(part[32])) incorrect += 'P.IVA, ';
            if(!isDateTime(part[34])) incorrect += 'Data richiesta quotazione, ';
            if(!isDettaglioFonteLead(part[35])) incorrect += 'Dettaglio fonte lead, ';
            if(!isSubAgency(part[36])) incorrect += 'Codice sub-agenzia, '; //CAPOBIANCO_A 11/07/2017 SPRINT 46
            if(!isZip(part[37])) incorrect += 'CAP '; //BOVOLENTA_D 21072017 ADDED CAP TO AUTO
            if(incorrect == '') return line;
            return line + ';' + incorrect;
            }
        catch(Exception e){
            System.debug('@@@@@@@'+e);
            return line + ';' + 'Eccezione non controllata';
            }
                
            
        }
     public static String nonAuto(String line, Set<String> allAgencies, Set<String> allState){
        System.debug('--------- '+line);
        try{            
            List<String> part= line.split(';');
            //File standardization
            while(part.size()<=37) part.add('');
            
            String incorrect = '';
            if(!allRequired(part)) incorrect += 'Campi obbligatori mancanti, ';
            if(!isMail(part[3])) incorrect += 'Mail, ';
            if(!isFiscalID(part[4])) incorrect += 'Codice fiscale, ';
            if(!isGender(part[5])) incorrect += 'Sesso, ';
            if(!isAgency(part[6], allAgencies)) incorrect += 'Codice Agenzia, ';
            if(!isDate(part[9])) incorrect += 'Data di nascita Lead, ';
            if(!isAvailable(part[10])) incorrect += 'Orario di contatto, ';
            if(!isCheck(part[11])) incorrect += 'Consenso attivita, ';
            if(!isCheck(part[12])) incorrect += 'Privacy, ';
            if(!isLineNonAuto(part[13])) incorrect += 'Tipologia polizza, ';
            if(!isState(part[15],allState)) incorrect += 'Provincia, ';
            if(!isZip(part[16])) incorrect += 'CAP, ';
            if(!isOrigineLead(part[18])) incorrect += 'Origine lead, ';
            if(!isPIVA(part[19])) incorrect += 'P.IVA, ';
            if(!isDateTime(part[21])) incorrect += 'Data richiesta quotazione, ';
            if(!isDettaglioFonteLead(part[22])) incorrect += 'Dettaglio fonte lead, ';
            if(!isDecimale(part[23])) incorrect += 'Prezzo annuo Confido,';
            if(!isDecimale(part[24])) incorrect += 'Premio in promozione,';
            if(!isEtaAnimale(part[28])) incorrect += 'Età animale,';
            if(!isSpuntaSioNo(part[29])) incorrect += 'Razza pericolosa,';
            if(!isSpuntaSioNo(part[30])) incorrect += 'RC cani e gatti plus,';
            if(!isDecimale(part[31])) incorrect += 'Massimale Tutela medica e sanitaria,';
            if(!isSpuntaSioNo(part[32])) incorrect += 'Tutela legale,';
            if(!isSpuntaSioNo(part[33])) incorrect += 'Assistenza H24,';
            if(!isState(part[34],allState)) incorrect += 'Stato/Provincia-bene da assicurare,';
            if(!isZip(part[36])) incorrect += 'CAP-bene da assicurare,';
            if(!isSubAgency(part[37])) incorrect += 'Codice sub-agenzia '; //CAPOBIANCO_A 11/07/2017 SPRINT 46
            
            if(incorrect == '') return line;
            return line + ';' + incorrect;
            }
        catch(Exception e){
            //Maybe a List out of buond, it's false cause the last part is a required field
            return line + ';' + 'Eccezione non controllata';
            }
        }
        
     public static String previdenza(String line, Set<String> allAgencies, Set<String> allState){
        System.debug('--------- '+line);
        try{            
            List<String> part= line.split(';');
            //File standardization
            while(part.size()<=37) part.add('');
            
            String incorrect = '';
            if(!allRequired(part)) incorrect += 'Campi obbligatori mancanti, ';
            if(!isMail(part[3])) incorrect += 'Mail, ';
            if(!isFiscalID(part[4])) incorrect += 'Codice fiscale, ';
            if(!isGender(part[5])) incorrect += 'Sesso, ';
            if(!isAgency(part[6], allAgencies)) incorrect += 'Codice Agenzia, ';
            if(!isDate(part[9])) incorrect += 'Data di nascita Lead, ';
            if(!isAvailable(part[10])) incorrect += 'Orario di contatto, ';
            if(!isCheck(part[11])) incorrect += 'Consenso attivita, ';
            if(!isCheck(part[12])) incorrect += 'Privacy, ';
            if(!isLineNonAuto(part[13])) incorrect += 'Tipologia polizza, ';
            if(!isState(part[15],allState)) incorrect += 'Provincia, ';
            if(!isZip(part[16])) incorrect += 'CAP, ';
            if(!isOrigineLead(part[18])) incorrect += 'Origine lead, ';
            if(!isPIVA(part[19])) incorrect += 'P.IVA, ';
            if(!isDateTime(part[21])) incorrect += 'Data richiesta quotazione, ';
            if(!isDettaglioFonteLead(part[22])) incorrect += 'Dettaglio fonte lead, ';
            if(!isSubAgency(part[23])) incorrect += 'Codice sub-agenzia '; //CAPOBIANCO_A 11/07/2017 SPRINT 46

            
            if(incorrect == '') return line;
            return line + ';' + incorrect;
            }
        catch(Exception e){
            //Maybe a List out of buond, it's false cause the last part is a required field
            return line + ';' + 'Eccezione non controllata';
            }
        }
     public static String protezione(String line, Set<String> allAgencies, Set<String> allState){
        System.debug('--------- '+line);
        try{            
            List<String> part= line.split(';');
            //File standardization
            while(part.size()<=37) part.add('');
            
            String incorrect = '';
            if(!allRequired(part)) incorrect += 'Campi obbligatori mancanti, ';
            if(!isMail(part[3])) incorrect += 'Mail, ';
            if(!isFiscalID(part[4])) incorrect += 'Codice fiscale, ';
            if(!isGender(part[5])) incorrect += 'Sesso, ';
            if(!isAgency(part[6], allAgencies)) incorrect += 'Codice Agenzia, ';
            if(!isDate(part[9])) incorrect += 'Data di nascita Lead, ';
            if(!isAvailable(part[10])) incorrect += 'Orario di contatto, ';
            if(!isCheck(part[11])) incorrect += 'Consenso attivita, ';
            if(!isCheck(part[12])) incorrect += 'Privacy, ';
            if(!isLineNonAuto(part[13])) incorrect += 'Tipologia polizza, ';
            if(!isState(part[15],allState)) incorrect += 'Provincia, ';
            if(!isZip(part[16])) incorrect += 'CAP, ';
            if(!isOrigineLead(part[18])) incorrect += 'Origine lead, ';
            if(!isPIVA(part[19])) incorrect += 'P.IVA, ';
            if(!isDateTime(part[21])) incorrect += 'Data richiesta quotazione, ';
            if(!isDettaglioFonteLead(part[22])) incorrect += 'Dettaglio fonte lead, ';
            if(!isSubAgency(part[23])) incorrect += 'Codice sub-agenzia '; //CAPOBIANCO_A 11/07/2017 SPRINT 46

            
            if(incorrect == '') return line;
            return line + ';' + incorrect;
            }
        catch(Exception e){
            //Maybe a List out of buond, it's false cause the last part is a required field
            return line + ';' + 'Eccezione non controllata';
            }
        }
        
        
        //Obbligatori
        public static Boolean allRequired(List<String> x){
                    system.debug('++++Required_ALLstring'+x);
            for(Integer i = 0; i <= 3; i++) {
                if(x[i]==null || x[i]=='') {
                system.debug('++++THISRequired '+x[i]);
                return false;
                }
            }
            return true;
        }
            
        //Mail
        public static Boolean isMail(String x){
           if(x.contains('@') && x.contains('.')){
               system.debug('++++Mail '+x);
               return true;
           }
           return false;
        }
   
        //Fiscal ID
        public static Boolean isFiscalID(String x){
          system.debug('++++FiscalID'+x);
            if(x.length() == 16 || x=='') return true;
            return false;
            }
       
        //Agency Code
        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- START - the agency code is not mandatory anymore
        public static Boolean isAgency(String x, Set<String> allAgencies){
        //To modify
            if(String.isNotBlank(x))
            {
                while(x.length()<6) x = '0' + x;
                if( x!='' && !(allAgencies.contains(x)) ) return false;
            }
            return true;
        }
        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- END

        /*public static Boolean isAgency(String x, Set<String> allAgencies){
        //To modify
            while(x.length()<6) x = '0' + x;
            if( x!='' && !(allAgencies.contains(x)) ) return false;
            return true;
            }*/
        
        //Line
        public static Boolean isLineAuto(String x){
            if(x == '' || x.toUpperCase() == 'AUTO') 
                    return true;
            return false;
            }
            
        public static Boolean isLineNonAuto(String x){
            if(x.toUpperCase() == '' || x.toUpperCase() == 'ALTRO' || x.toUpperCase() == 'FAMIGLIA' || x.toUpperCase() == 'INVESTIMENTO' 
               || x.toUpperCase() == 'PREVIDENZA' || x.toUpperCase() == 'PROTEZIONE' || x.toUpperCase() == 'RISPARMIO' || x.toUpperCase() == 'SALUTE') 
                    return true;
            return false;
            }
            
        //Origine lead
        
            public static Boolean isOrigineLead(String x){
            if(x.toUpperCase() == '' || x.toUpperCase() == 'ConFido' || x.toUpperCase() == 'Preventivo veloce' || x.toUpperCase() == 'Semplicemente casa' 
               || x.toUpperCase() == 'Infortunio h24' || x.toUpperCase() == 'Preventivo Impresa' || x.toUpperCase() == 'Tutta la vita' || x.toUpperCase() == 'Previsio' || x.toUpperCase() == 'Siti Agenti'|| x.toUpperCase() == 'Employees Benefit'  || x.toUpperCase() == 'Protezione Turismo' || x.toUpperCase() == 'Centri Diagnostici') 
                    return true;
            return false;
            } 
            
            
         //Dettaglio Fonte Lead
         public static Boolean isDettaglioFonteLead(String x){
            //if(x == '' || x.toUpperCase() == 'Salva quotazione')
            if(x == '' || x.toUpperCase() == 'Salva quotazione' || x.toUpperCase() == 'Visualizza quotazione')  //CAPOBIANCO_A 28/07/2017
                    return true;
            return false;
            }
        
        //Price
        public static Boolean isPrice(String x){
            if(x =='') return true;
            try{
                Decimal.valueOf(x);
                return true;
                }
            catch(Exception e){
                return false;
            }
       }
        
        //Date
        public static Boolean isDate(String x){
            if(x == null || x == '') 
                return true;
            try{
                Date d = Date.parse(x);
                return true;
            }
            catch(Exception e){
                return false;
            }
        }
        
        //DataTime
        public static Boolean isDateTime(String x){
            if(x == null || x == '') 
                return true;
            try{
                DateTime dt = DateTime.parse(x);
                return true;
            }
            catch(Exception e){
                return false;
            }
        }
        
       
        
        
        //Universal Class
        public static Boolean isUniversalClass(String x){
            if(x == '') return true;
            return Pattern.matches('[CU]{2} [0-9]{2}', x);
        }
        
        //Gender
        public static Boolean isGender(String x){
            if(x == '' || x.toUpperCase() == 'FEMMINA' || x.toUpperCase() == 'MASCHIO' || x.toUpperCase() == 'M' || x.toUpperCase()=='F') return true;
            return false;
        }
        
        //Boolean
        public static Boolean isCheck(String x){
            if(x == '') return true;
            if(x.toUpperCase() == 'VERO' || x.toUpperCase() == 'FALSO') return true;
            return false;
           } 
        // EtaAnimale
         public static Boolean isEtaAnimale(String x){
         if(x == '') return true;
         if(x.toUpperCase() == 'Meno di 6 mesi' ||x.toUpperCase() == 'Compreso tra 6 mesi e 10 anni' || x.toUpperCase()== 'Più di 10 anni' ) return true;
            return false;
        }
        
        
        
        //Int
        public static Boolean isInt(String x){
            if(x == '') return true;
            try{
                Integer.valueOf(x);
                return true;
                }
            catch(Exception e){
                return false;
                } 
           }   
       //Decimale
       public static Boolean isDecimale(String x){
            if(x == '') return true;
            try{
                Decimal.valueOf(x);
                return true;
                }
            catch(Exception e){
                return false;
                } 
           } 
         
       
       //Available Hour
       public static Boolean isAvailable(String x){
           if(x=='' || x=='9 - 11' || x=='11 - 13' || x=='13 - 15' || x=='15 - 17' || x=='17 - 19') 
               return true;
           return false;
           } 
       
       
              
           
           
       
       //State/Province
       public static Boolean isState(String x, Set<String> allState){
           if(x == '') return true;
           return allState.contains(x) || allState.contains(x.toUpperCase());          
           } 
       
       //Zip/PostalCode
       public static Boolean isZip(String x){
           if(x == '') return true;
           if(x.trim().length()!=5) return false;
           try{
               Integer.valueOf(x);
               return true;
               }
           catch(Exception e ){
               return false;
               }
           }
        //P.IVA
        public static Boolean isPIVA(String x){
          system.debug('++++PIVA'+x);
            if(x.length() == 11 || x=='') return true;
            return false;
            }
            
            
          //  PrezzoFido
    public static Boolean isPrezzoFido(String x){
           if(x == '') return true;
           if(x.trim().length()>4) return false;
           try{
               Integer.valueOf(x);
               return true;
               }
           catch(Exception e ){
               return false;
               }
           }
           
       
           //SpuntaSioNo
           public static Boolean isSpuntaSioNo(String x){
            if(x == '') return true;
            if(x.toUpperCase() == 'VERO' || x.toUpperCase() == 'FALSO') return true;
            return false;
           } 

        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- START
        //Sub-Agency Code
        public static Boolean isSubAgency(String x){
            if( x=='' || x.length() == 12) return true;
            return false;
        }
        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- START
}