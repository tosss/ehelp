public Class GenerateCSV {
    public List<Contact> getContacts() {
          return [select Id,Title,FirstName,LastName from Contact limit 20];
    }
}