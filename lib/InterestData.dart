class Interest {
  Interest(
      {required this.ID,
      required this.Name,
      this.Description = "NULL_DESCRIPTION",
      this.ImageURL =
          "https://www.svgrepo.com/show/508699/landscape-placeholder.svg"});
  final String ID;
  final String Name;
  final String Description;
  final String ImageURL;
}
