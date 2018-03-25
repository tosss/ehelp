trigger ISVC_FeedItem on FeedItem (after insert) {
    ALL_TriggerDispatcher.run(new ISVC_FeedItem_Handler());
}