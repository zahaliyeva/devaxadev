public with sharing class AdminManagement {
    
    public static List<User> checkListOfUsers (List<User> users)  {
        List<User> result = new List<User>();
        List<User> invalidResult = new List<User>();
        UsersToBeVerified__c tobeVerified = UsersToBeVerified__c.getInstance(Userinfo.getUserId());
        if (tobeVerified.ToBeBlocked__c ) {
            // Verificare se sta facendo azioni sugli ADMIN
            Set<String> profileIds = new Set<String>();
            Set<String> profileAdminIds = new Set<String>();
            if (users != null && !users.isEmpty()) {
                for (User u : users) {
                    if (u.ProfileId != null) {
                        profileIds.add(String.valueOf(u.ProfileId));
                    }
                }
                if (profileIds != null && !profileIds.isEmpty()) {
                    List<Profile> profiliAdmin = [SELECT Id FROM Profile WHERE Id IN :profileIds AND
                                                    (Name = 'Administrateur système' 
                                                        OR Name = 'System Administrator'
                                                        OR Name = 'Amministratore del sistema'
                                                        OR Name = 'Systemadministrator'
                                                        OR Name = 'Systemadministratör'
                                                        OR Name = 'Administrador do sistema'
                                                        OR Name = 'Systeembeheerder'
                                                        OR Name = 'Systemadministrator')];
                    if (profiliAdmin != null && !profiliAdmin.isEmpty()) {
                        // Utente sta modificando un Admin - Bisogna Bloccare le modifiche agli admin e inviare una mail di notifica
                        for (Profile p : profiliAdmin) {
                            profileAdminIds.add(String.valueOf(p.Id));
                        }
                        for (User u : users) {
                            if (!profileAdminIds.contains(String.valueOf(u.ProfileId))) {
                                result.add(u);
                            } else {
                                System.debug('### Not Authorized Edits (IS NOT Admin) ');
                                throw new applicationException('Unauthorized Operation. This User cannot manage Admin Users.');
                            }
                        }
                    }
                }
            }
        }
        // Posso procedere, perché sono autorizzato
        result = users;
        System.debug('### Authorized Edits ' + result);
        return result;
    }
    
    public class applicationException extends Exception {}
    
}