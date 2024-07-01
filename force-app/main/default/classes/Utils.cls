/** 
* @author	unkW
* @description NON prsente
* @date 25-02-2015
* Maintenance History: 14-04-2023 pmd fix
*/
public inherited sharing class Utils {
    
      public static String getCF(String surname, String firstname, String bornDate, String Gender, String bornCity, String bornState) {
          System.debug('### surname:'+surname);
          System.debug('### firstName:'+firstname);
          System.debug('### bornDate:'+bornDate);
          System.debug('### Gender:'+Gender);
		  System.debug('### bornCity:'+bornCity);
           System.debug('### bornState:'+bornState);


        String countryCode = '';
        try {
            if (bornState != null && bornCity != null) {

                List<FiscalCodeParameter__c> param = [SELECT CFNationalCode__c, CFCity__c, CFProvince__c FROM FiscalCodeParameter__c WHERE CFCity__c = :bornCity];
                if (!param.isEmpty() && param.size() == 1) {
                    countryCode = param.get(0).CFNationalCode__c;
                }
            }


            //creazione set delle vocali
            Set<String> vocali = new Set<String> {'A', 'E', 'I', 'O', 'U'};


            //creazione mappa numero mese -> lettera da inserire
            map<String, String> mese2char = new map<String, String> {'01' => 'A', '02' => 'B', '03' => 'C', '04' => 'D', '05' => 'E',
                    '06' => 'H', '07' => 'L', '08' => 'M', '09' => 'P', '10' => 'R', '11' => 'S', '12' => 'T'
                                                                    };


            //creazione mappa caratteri dispari per calcolo carattere di controllo
            map<String, integer> mapDispari = new map<String, integer> {'0' => 1, '1' => 0, '2' => 5, '3' => 7, '4' => 9, '5' => 13, '6' => 15,
                    '7' => 17, '8' => 19, '9' => 21, 'A' => 1, 'B' => 0, 'C' => 5, 'D' => 7, 'E' => 9, 'F' => 13, 'G' => 15, 'H' => 17, 'I' => 19, 'J' => 21,
                    'K' => 2, 'L' => 4, 'M' => 18, 'N' => 20, 'O' => 11, 'P' => 3, 'Q' => 6, 'R' => 8, 'S' => 12, 'T' => 14, 'U' => 16, 'V' => 10, 'W' => 22,
                    'X' => 25, 'Y' => 24, 'Z' => 23
                                                                       };

            //creazione mappa caratteri pari per calcolo carattere di controllo
            map<String, integer> mapPari = new map<String, integer> {'0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5,
                    '6' => 6, '7' => 7, '8' => 8, '9' => 9, 'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3, 'E' => 4, 'F' => 5, 'G' => 6, 'H' => 7,
                    'I' => 8, 'J' => 9, 'K' => 10, 'L' => 11, 'M' => 12, 'N' => 13, 'O' => 14, 'P' => 15, 'Q' => 16, 'R' => 17, 'S' => 18,
                    'T' => 19, 'U' => 20, 'V' => 21, 'W' => 22, 'X' => 23, 'Y' => 24, 'Z' => 25
                                                                    };

            //tabella mapping resto per calcolo carattere di controllo
            map<integer, String> mapResto = new map<integer, String> {0 => 'A', 1 => 'B', 2 => 'C', 3 => 'D', 4 => 'E',
                    5 => 'F', 6 => 'G', 7 => 'H', 8 => 'I', 9 => 'J', 10 => 'K', 11 => 'L', 12 => 'M', 13 => 'N', 14 => 'O',
                    15 => 'P', 16 => 'Q', 17 => 'R', 18 => 'S', 19 => 'T', 20 => 'U', 21 => 'V', 22 => 'W', 23 => 'X', 24 => 'Y', 25 => 'Z'
                                                                     };

            //parsing della data di nascita - forma in input yyyy/mm/dd
            System.debug('-----> Data di nascita: ' + bornDate);
            String[] bornDateSplit = bornDate.split('-');
            String CF = '';
            System.debug('-----> Split data di nascita: ' + bornDateSplit);

            //prima fase: elaborazione del surname
            surname = surname.replace(' ', '');
            surname = surname.replace('\'', '');
            surname = surname.toUpperCase();

            //ciclo sulle consonanti
            for (integer i = 0; i < surname.length() && CF.length() < 3; i++) {
                if (!vocali.contains(surname.substring(i, i + 1))) {
                    CF = CF + surname.substring(i, i + 1);
                }
            }
            //se non ci sono abbastanza consonanti, ciclo sulle vocali
            if (CF.length() < 3) {
                for (integer i = 0; i < surname.length() && CF.length() < 3; i++) {
                    if (vocali.contains(surname.substring(i, i + 1))) {
                        CF = CF + surname.substring(i, i + 1);
                    }
                }
            }
            //se il surname è più corto di 3 lettere, aggiungo delle X in coda come da specifica
            if (CF.length() < 3)
                while (CF.length() < 3)
                    CF = CF + 'X';


            //seconda fase: elaborazione del firstname
            //calcolo il numero di consonanti nel firstname: se >= 4 si prendono la prima la terza e la quarta, altrimenti le prime 3 in fila(se esistono)
            firstname = firstname.replace(' ', '');
            firstname = firstname.replace('\'', '');
            firstname = firstname.toUpperCase();

            List<String> consonantifirstname = new List<String>();
            for (integer i = 0; i < firstname.length(); i++) {
                if (!vocali.contains(firstname.substring(i, i + 1))) {
                    consonantifirstname.add(firstname.substring(i, i + 1));
                }
            }
            if (consonantifirstname.size() >= 4)
                CF = CF + consonantifirstname.get(0) + consonantifirstname.get(2) + consonantifirstname.get(3);
            else {
                for (integer i = 0; i < consonantifirstname.size(); i++) {
                    CF = CF + consonantifirstname.get(i);
                }
            }
            //se la lunghezza del codice è inferiore a 6 (3 firstname, 3 surname), aggiungo le eventuali vocali del firstname
            if (CF.length() < 6) {
                for (integer i = 0; i < firstname.length() && CF.length() < 6; i++) {
                    if (vocali.contains(firstname.substring(i, i + 1))) {
                        CF = CF + firstname.substring(i, i + 1);
                    }
                }
            }
            //se la lunghezza del codice è inferiore a 6 (3 firstname, 3 surname), aggiungo X come da specifica
            if (CF.length() < 6)
                while (CF.length() < 6)
                    CF = CF + 'X';

            //vengono aggiunte le ultime due cifre dell'anno di nascita
            CF = CF + bornDateSplit[0].substring(2, 3);
            CF = CF + bornDateSplit[0].substring(3, 4);

            //viene aggiunto il carattere relativo al mese di nascita
            CF = CF + mese2char.get(bornDateSplit[1]);

            //viene aggiunto il giorno di nascita. senza variazione se intestatario maschio, giorno nascita + 40 se femmina
            gender = gender.toUpperCase();
            if (gender.equals('M'))
                CF = CF + bornDateSplit[2];
            else {
                integer app = Integer.valueOf(bornDateSplit[2]);
                app = app + 40;
                bornDateSplit[2] = String.valueOf(app);
                CF = CF + bornDateSplit[2];
            }

            //viene aggiunto il codice nazionale (passato come parametro della funzione)
            CF = CF + countryCode;

            //calcolo del carattere ci controllo (si veda http://it.wikipedia.org/wiki/Codice_fiscale#Generazione_del_codice_fiscale)
            integer controlValue = 0;
            for (integer i = 0; i < CF.length(); i++) {
                if (math.mod((i + 1), 2) == 0)
                    controlValue = controlValue + mapPari.get(CF.substring(i, i + 1));
                else
                    controlValue = controlValue + mapDispari.get(CF.substring(i, i + 1));

            }
            CF = CF + mapResto.get(math.mod(controlValue, 26));
            System.debug('####CF: '+CF);
            return CF;
        }

        catch (Exception e) {
            return '0';

        }
    }
}