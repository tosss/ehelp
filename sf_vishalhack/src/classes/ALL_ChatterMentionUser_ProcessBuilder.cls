/*******************************************************
* Author: Hemanth.Kesapragada@cdk.com
* Description: Class to mention users
* Test Class: ALL_ChatterMentionUser_Test
* 
* History:
* 2015-08-19 	Hemanth Kesapragada		Created
* 2015-08-19	Hemanth Kesapragada		Added addChatterMention method
* *************************************************** */
public class ALL_ChatterMentionUser_ProcessBuilder 
{
    public class ChatterMentionWrapper
    {
        @InvocableVariable
        public String userId;
        
        @InvocableVariable
        public String recordId;
        
        @InvocableVariable
        public String text;
    }
    
    @InvocableMethod(label='Creates Mention' description='Requires userId, recordId and text')
    public static void addChatterMention(List<ChatterMentionWrapper> mentionWrapperList)
    {
        if(mentionWrapperList.size()!=0)
        {
            ConnectApi.FeedItemInput feedItemInput;
            ConnectApi.MentionSegmentInput mentionSegmentInput;
            ConnectApi.MessageBodyInput messageBodyInput;
            ConnectApi.TextSegmentInput textSegmentInput;
            for(ChatterMentionWrapper wrapperObj : mentionWrapperList)
            {
                feedItemInput = new ConnectApi.FeedItemInput();
                mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                messageBodyInput = new ConnectApi.MessageBodyInput();
                textSegmentInput = new ConnectApi.TextSegmentInput();
                
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                mentionSegmentInput.id = wrapperObj.userId;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                
                textSegmentInput.text = ' '+wrapperObj.text;
                messageBodyInput.messageSegments.add(textSegmentInput);
                
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = wrapperObj.recordId;
                
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput, null);    
            }
        }
    }
}