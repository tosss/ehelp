({
	initialize: function(component, event, helper)
    {
        helper.initializeComponent(component, event, helper);
    },
    openEditModal: function(component, event, helper)
    {
        helper.openEditMembershipModal(component, event);
    },
    openDeleteModal: function(component, event, helper)
    {
        helper.openDeleteMemberModal(component, event);
    },
    editMember: function(component, event, helper)
    {
        helper.changeMembership(component, event, helper);
    },
    delMember: function(component, event, helper)
    {
        helper.deleteGrpMember(component, event, helper);
    },
    closeModal: function()
    {
        j$('.editMembershipModal').hide();
        j$('.delMemberModal').hide();
    }
})