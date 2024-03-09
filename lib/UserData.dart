class UserData {
  UserData(this.UUID, this.Username, this.Birthday, this.Gender, this.Description, this.ProfilePictureURL);

  final String UUID;
  final String Username;
  final DateTime Birthday;
  final String Gender;
  final String Description;
  final String ProfilePictureURL;

  int getAge() {
    return (DateTime.now().difference(this.Birthday).inDays / 365).floor();
  }
}