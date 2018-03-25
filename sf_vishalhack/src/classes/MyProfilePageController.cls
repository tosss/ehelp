/**
 * This class was automatically created (from SFDC) when Customer Portal (Community) was turned on. 
 * If errors occur we may consider deleting it because it is generally not used.
 * 
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
 * Guest users are never able to access this page.
 */
//2016-06-15- anirudh.singh@cdk.com- Commented the Phone and Fax fields on Contact, as they are now moved to Contact Relationship.
public with sharing class MyProfilePageController {

    private User user;
    private boolean isEdit = false;

    public User getUser() {
        return user;
    }

    public MyProfilePageController() {
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }

    public Boolean getIsEdit() {
        return isEdit;
    }

    public void edit() {
        isEdit=true;
    }

    public void save() {
        if (user.contact != null) {
            setContactFields(user.contact, user);
        }

        try {
            update user;
            if (user.contact != null) {
                update user.contact;
            }
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public PageReference changePassword() {
        return Page.ChangePassword;
    }

    public void cancel() {
        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }

    public static void setContactFields(Contact c, User u) {
        c.title = u.title;
        c.firstname = u.firstname;
        c.lastname = u.lastname;
        c.email = u.email;
        //2016-06-15- anirudh.singh@cdk.com- Commented the Phone and Fax fields on Contact, as they are now moved to Contact Relationship.
        //c.phone = u.phone;
        //c.fax = u.fax;
        c.mobilephone = u.mobilephone;
        c.mailingstreet = u.street;
        c.mailingcity = u.city;
        c.mailingstate = u.state;
        c.mailingpostalcode = u.postalcode;
        c.mailingcountry = u.country;
    }
}