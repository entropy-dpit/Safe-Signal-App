/// Class for reports generated when panic mode is active
/// 
/// Author: David Pescariu @davidp-ro
class Report {
  double lat;
  double long;
  String type;
  String niceAddress;

  /// Param [lat] - [double] Latitude
  /// Param [long] - [double] Longitude
  /// Param [type] - [String] Type of marker (ie. "unsafe")
  /// Param [niceAddress] - [optional, String] Address gotten if user had internet
  Report(double lat, double long, String type, String niceAddress) {
    this.lat = lat;
    this.long = long;
    this.type = type;
    this.niceAddress = niceAddress;
  }

  /// Overriding default eq operator to use it when deleting
  @override
  bool operator ==(o) =>
      o is Report &&
      o.lat == this.lat &&
      o.long == this.long &&
      o.type == this.type;

  /// Overriding default hashCode beacuse dart requires it...
  @override
  int get hashCode => lat.hashCode ^ long.hashCode ^ type.hashCode;
}
