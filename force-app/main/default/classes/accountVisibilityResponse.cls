public with sharing class accountVisibilityResponse {
    public returnWrapper risposta; //in the sample reponses we receive return, but it is a reserved keyword!
/*    public String NDG;
    public List<OutputNodo> ListaNodiOutput;
    public nodesList listaNodiAggiornata;*/
    public accountVisibilityResponse() {
    }

    public with sharing class OutputNodo {
        public List<String> Nodo;
        public String Esito;
        public String descrizioneEsito;
        public OutputNodo() {
        }
    }

    public with sharing class returnWrapper{
        public String NDG;
        public List<OutputNodo> ListaNodiOutput;
        public nodesList listaNodiAggiornata;
        public returnWrapper(){

        }
    }

    public with sharing class nodesList{
        public list<String> Nodo;
    }
}