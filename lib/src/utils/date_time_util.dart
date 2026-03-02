/// DateTime関連メソッド
class DateTimeUtil {
  // 指定した日の週の月曜日を取得
  static DateTime lastMonday(DateTime date) =>
      date.subtract(Duration(days: (date.weekday - 1) % 7)).to12am();
  // 指定した日の週の日曜日を取得
  static DateTime nextSunday(DateTime date) =>
      date.add(Duration(days: 6 - (date.weekday - 1) % 7)).to12am();
}

extension DateTimeExtensions on DateTime {
  DateTime to12am() => copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
}
