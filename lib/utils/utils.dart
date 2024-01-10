
class Utils {

  static int calculateMonthDifference(DateTime startDate, DateTime endDate) {
    return (startDate.year * 12 + startDate.month) - (endDate.year * 12 + endDate.month);
  }

}
