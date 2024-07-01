@IsTest
public class ZTestFeedCommentTrigger {
    static testMethod void insertNewChatterPostTest() {
        Test.StartTest();
        FeedItem f = new FeedItem();
        f.ParentId = UserInfo.getUserId();
        f.body = 'test';
        insert f;
        FeedComment fc = new FeedComment();
        fc.CommentBody = 'legal test';
        fc.FeedItemId = f.Id;
        insert fc;
        Test.StopTest();
        System.assertEquals ('legal test', fc.commentbody);
    }
}