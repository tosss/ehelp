({
    fireDataChangeEvent: function (dataProvider, data, currentPage) {
        var dataChangeEvent = dataProvider.getEvent("onchange");
        dataChangeEvent.setParams({
            data : data,
            currentPage : currentPage
        }).fire();
    }
})