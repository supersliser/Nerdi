class Interest {
  Interest(
      {required this.ID,
      required this.Name,
      this.Description = "NULL_DESCRIPTION",
      this.ImageName = "Placeholder",
      this.ImageURL =
          "https://t3.ftcdn.net/jpg/02/68/55/60/360_F_268556012_c1WBaKFN5rjRxR2eyV33znK4qnYeKZjm.jpg"});
  final String ID;
  final String Name;
  final String Description;
  final String ImageURL;
  final String ImageName;
}
