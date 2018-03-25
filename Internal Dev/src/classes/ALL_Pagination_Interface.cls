public interface ALL_Pagination_Interface {
    void firstPage();
    void lastPage();
    void previousPage();
    void nextPage();
    Boolean getHasPreviousPage();
    Boolean getHasNextPage();
    Integer getCurrentPageNumber();
    Integer getTotalPageNumber();
}