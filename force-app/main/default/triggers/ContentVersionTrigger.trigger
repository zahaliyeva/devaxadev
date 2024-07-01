trigger ContentVersionTrigger on Contentversion (after insert, after update) {

    if(Trigger.isInsert && FileUploadHelper.isEnabledOnTriggerLightning()){
        for(Contentversion content : Trigger.new){
                for(String invalidExtension: FileUploadHelper.getBadExtensions()){
                    if(String.isnotBlank(content.PathOnClient) && content.PathOnClient.endsWithIgnoreCase(invalidExtension)){
                            content.addError('Estensione del file non valida ' + content.PathOnClient);
                        }
                }
                if(String.isnotBlank(content.PathOnClient) && !FileUploadHelper.isFilePathAllowed(content.PathOnClient)){
                        content.addError('Estensione del file non valida ' + content.PathOnClient);
                }
        }
    }

}