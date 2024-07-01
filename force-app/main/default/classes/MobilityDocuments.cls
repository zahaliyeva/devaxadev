public with sharing class MobilityDocuments {

    public class MobilityDocumentsException extends Exception {}
    public class MobilityDocumentsResponse extends MobilityResponse {}

    @AuraEnabled
    public static List < ContentVersion > getFilesList(String recordId) {
        List < ContentDocumentLink > contentDocumentLinkList = [
            Select Id, ContentDocumentId
            From ContentDocumentLink
            Where LinkedEntityId =: recordId
        ];

        Set < Id > contentDocumentIdSet = new Set < Id > ();
        for (ContentDocumentLink link: contentDocumentLinkList) {
            contentDocumentIdSet.add(link.ContentDocumentId);
        }

        List < ContentVersion > contentVersionList = [
            Select Title, FileExtension, CreatedDate, VersionData, ContentUrl, PathOnClient, ContentDocumentId, ContentSize
            From ContentVersion
            Where ContentDocumentId =: contentDocumentIdSet
            Order By CreatedDate Desc
        ];

        System.debug(contentVersionList);
        return contentVersionList;
    }

    @AuraEnabled
    public static MobilityDocumentsResponse deleteContentDocuments(List < String > recordIdList) {
        MobilityDocumentsResponse response = new MobilityDocumentsResponse();
        try {
            delete[
                Select Id From ContentDocument Where Id in: recordIdList
            ];
            response.isSuccess = true;
        } catch (MobilityException ex) {
            response.errorMessage = ex.getMessage();
        } catch (Exception ex) {
            response.errorMessage = ex.getMessage();
        }
        System.debug(response);
        return response;
    }

    @AuraEnabled
    public static MobilityDocumentsResponse uploadFile(String parentId, String base64, String title) {
        MobilityDocumentsResponse response = new MobilityDocumentsResponse();

        try {
            Blob versionData = EncodingUtil.base64Decode(EncodingUtil.urlDecode(base64, 'UTF-8'));
            ContentVersion newContentVersion = new ContentVersion();
            newContentVersion.VersionData = versionData;
            newContentVersion.Title = title;
            newContentVersion.FirstPublishLocationId = parentId;
            newContentVersion.PathOnClient = title;

            insert newContentVersion;
            response.isSuccess = true;
        } catch (Exception ex) {
            response.errorMessage = ex.getMessage();
        }
        System.debug(response);
        return response;
    }

    @AuraEnabled
    public static SObjectTable.TablePagination getUploadFilePage(String recordId, Integer total, Integer page, Integer perPage, Integer maxPerPage, Integer lengthList) {

        List < ContentVersion > fileList = MobilityDocuments.getFilesList(recordId);

        System.debug(fileList);

        SObjectTable.TablePagination pagination = new SObjectTable.TablePagination(
            fileList, //elements
            fileList.size(), //total
            page,
            perPage,
            maxPerPage,
            lengthList,
            true //hasFullData
        );

        System.debug(JSON.serialize(pagination));
        return pagination;
    }
}